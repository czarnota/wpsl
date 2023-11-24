---
title: Komunikacja sieciowa
---

# Zagadnienie 5: Gniazda

## Gniazda

Gniazda pozwalają na komunikację pomiędzy procesami działającymi na tej
samej maszynie oraz działającymi na różnych maszynach.

Systemy uniksowe oferują wiele różnych typów gniazd, jednak ustandaryzowane przez
POSIX są:

- gniazda lokalne (ang. Unix domain sockets), `AF_UNIX`;
- gniazda sieciowe (ang. network sockets), `AF_INET` i `AF_INET6`.

## Gniazda - tworzenie

Do tworzenia gniazd sieciowych służy wywołanie systemowe `socket()`.

```c
#include <sys/socket.h>

int socket(int domain, int type, int protocol);
```

```c
int fd = -1;
/* Lokalny, niezawodny, połączeniowy strumień danych */
fd = socket(AF_UNIX, SOCK_STREAM, 0);
/* Lokalne, zawodne, bezpołączeniowe wiadomości */
fd = socket(AF_UNIX, SOCK_DGRAM, 0);
/* Lokalne, niezawodne, połączeniowe wiadomości */
fd = socket(AF_UNIX, SOCK_SEQPACKET, 0);
/* Sieciowy, IPv4, niezawodny, połączeniowy strumień danych oparty o protokół TCP */
fd = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
/* Sieciowe, IPv4, zawodne, bezpołączeniowe wiadomości oparte o protokół UDP */
fd = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
/* Sieciowe, IPv4, niezawodne, połączeniowe wiadomości oparte o protokół SCTP */
fd = socket(AF_INET, SOCK_SEQPACKET, IPPROTO_SCTP);
/* Sieciowy, IPv6, niezawodny, połączeniowy strumień danych oparty o protokół TCP */
fd = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
/* Sieciowe, IPv6, zawodne, bezpołączeniowe wiadomości oparte o protokół UDP */
fd = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
/* Sieciowe, IPv6, niezawodne, połączeniowe wiadomości oparte o protokół SCTP */
fd = socket(AF_INET, SOCK_SEQPACKET, IPPROTO_SCTP);
```


## Gniazda


Do operacji na gniazdach służy następujący zestaw wywołań systemowych:

```c
#include <sys/types.h>
#include <sys/socket>
#include <unistd.h>

/* Po obu stronach */
int socket(int domain, int type, int protocol);

/* Po stronie klienta */
int connect(int socket, const struct sockaddr *address, socklen_t address_len);

/* Po strinie serwera */
int bind(int socket, const struct sockaddr *address, socklen_t address_len);
int listen(int socket, int backlog);
int accept(int socket, struct sockaddr *restrict address, socklen_t *restrict address_len);

/* Po obu stronach */
ssize_t read(int fd, void *data, size_t count);
ssize_t write(int fd, const void *data, size_t count);
int close(int fd);
```

## Gniazda lokalne - struktura adresu

```c
#include <sys/un.h>

struct sockaddr_un {
	sa_family_t sun_family;               /* AF_UNIX */
	char        sun_path[108];            /* Ścieżka */
};
```

## Gniazda sieciowe - struktura adresu

```c
#include <netinet/in.h>

struct sockaddr_in {
	short            sin_family;   // e.g. AF_INET
	unsigned short   sin_port;     // e.g. htons(3490)
	struct in_addr   sin_addr;     // see struct in_addr, below
	char             sin_zero[8];  // zero this if you want to
};

struct in_addr {
	unsigned long s_addr;  // load with inet_aton()
};

struct sockaddr_in6 {
	sa_family_t     sin6_family;   /* AF_INET6 */
	in_port_t       sin6_port;     /* port number */
	uint32_t        sin6_flowinfo; /* IPv6 flow information */
	struct in6_addr sin6_addr;     /* IPv6 address */
	uint32_t        sin6_scope_id; /* Scope ID (new in Linux 2.4) */
};

struct in6_addr {
	unsigned char   s6_addr[16];   /* IPv6 address */
};
```

## Komunikacja klienta z serwerem

![](assets/communication.png)


## Przesyłanie danych przez gniazda 

Oprócz `read()` i `write()` można wykorzystać też `recv()` lub `recvfrom()` oraz
`send()` lub `sendto()`.

```c
#include <sys/socket.h>

ssize_t
recv(int socket, void *buffer, size_t length, int flags);
ssize_t
send(int socket, const void *buffer, size_t length, int flags);

ssize_t
recvfrom(int socket, void *restrict buffer, size_t length, int flags,
 struct sockaddr *restrict address, socklen_t *restrict address_len);
ssize_t
sendto(int socket, const void *buffer, size_t length, int flags,
 const struct sockaddr *dest_addr, socklen_t dest_len);
```

## Gniazda lokalne - serwer
```c
	int fd = socket(AF_UNIX, SOCK_STREAM, 0);
	if (fd < 0)
		return 1;

	unlink(addr.sun_path);
	const struct sockaddr_un addr = {
		.sun_family = AF_UNIX, .sun_path = "foo",
	};
	if (bind(fd, (const struct sockaddr *)&addr, sizeof(addr)))
		goto err_close;
	if (listen(fd, 8))
		goto err_close;

	while (1) {
		int client_fd = accept(fd, NULL, NULL);
		if (client_fd < 0)
			break;
		char msg[256] = {0};
		ssize_t num_read = read(client_fd, msg, sizeof(msg) - 1);
		if (num_read)
			printf("%s\n", msg);
		close(client_fd);
	}
err_close:
	close(fd);
	unlink(addr.sun_path);
```

## Gniazda lokalne - klient

```c
	int fd = socket(AF_UNIX, SOCK_STREAM, 0);
	if (fd < 0)
		return 1;

	const struct sockaddr_un addr = {
		.sun_family = AF_UNIX,
		.sun_path = "foo",
	};

	int err = connect(fd, (const struct sockaddr *)&addr, sizeof(addr));
	if (err)
		goto err_close;

	ssize_t num_written = write(fd, "Hello world", strlen("Hello world"));
	if (num_written <= 0) {
		/* error */
	}

err_close:
	close(fd);

```

## Gniazda sieciowe - serwer
```c
	#include <netinet/in.h>
	...

	int fd = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
	if (fd < 0)
		return 1;

	const struct sockaddr_in addr = {
		.sin_family = AF_INET,
		.sin_port = htons(2000),
	};
	if (bind(fd, (const struct sockaddr *)&addr, sizeof(addr)))
		goto err_close;

	...
```

## Gniazda sieciowe - klient

```c
	#include <netinet/in.h>
	...

	int fd = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
	if (fd < 0)
		return 1;

	struct sockaddr_in addr = {
		.sin_family = AF_INET,
		.sin_port = htons(2000),
	};
	if (!inet_aton("127.0.0.1", &addr.sin_addr))
		goto err_close;

	int err = connect(fd, (const struct sockaddr *)&addr, sizeof(addr));
	if (err)
		goto err_close;

	...
```

# Protokół HTTP

## Każda strona internetowa to dokument hipertekstowy

![](assets/onet.png)

## Hipertekstowy język znaczników (HTML)

Język HTML, służy do formułowania dokumentów hipertekstowych, które
następnie są prezentowane przez przeglądarke jako strona internetowa.

```html
<!doctype html>
<html lang="pl">
    <head>
        <meta charset="utf-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>Title</title>
    </head>
    <body>
        <h1>Witaj świecie</h1>
        <p>Oto pierwszy akapit</p>
    </body>
</html>
```

## Hipertekstowy język znaczników - efekt

Po wyrenderowaniu HTML, przez przeglądarke otrzymujemy następujący efekt:

![](assets/htmlhello.png)

## Protokół przesyłania dokumentów hipertekstowych (HTTP)

Do przesyłania dokumentów HTML poprzez sieć służy protokół HTTP.
Gdy użytkownik chce wejśc na daną stronę internetową, to przeglądarka
wysyła żądanie HTTP do serwera HTTP. Następnie serwer odsyła przeglądarce
odpowiedź.

![](assets/http.svg)

## Żądanie HTTP
Żądanie HTTP ma format tekstowy. Składa się z nagłówków zapytania oraz
opcjonalnego ciała.
```
METODA ZASÓB WERSJA_HTTP
Nagłówek1: Wartość1
Nagłówek2: Wartość2

<opcjonalne ciało>
```

Przykład:
```
GET /index.html HTTP/1.1
Host: example.com
User-Agent: Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:98.0) Gecko/20100101 Firefox/98.0
Accept: */*


```
W `HTTP/1.1` wymaganym nagłówkiem jest `Host`, reszta jest opcjonalna.

## Odpowiedź HTTP

Odpowiedź HTTP ma format tekstowy. Składa się z linii statusu, nagłówków 
zapytania oraz opcjonalnego ciała:

```
HTTP/1.1 KOD_ODPOWIEDZI NAZWA_KODU
Nagłówek1: Wartość1
Nagłówek2: Wartość2

<opcjonalne ciało>
```

## Odpowiedź HTTP - przykład

Przykładowa odpowiedź HTTP:
```
HTTP/1.1 200 OK
Content-Type: text/html; charset=UTF-8
Date: Thu, 07 Apr 2022 15:32:42 GMT
Content-Length: 353

<!doctype html>
<html lang="pl">
    <head>
        <meta charset="utf-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>Title</title>
    </head>
    <body>
        <h1>Witaj świecie</h1>
        <p>Oto pierwszy akapit</p>
    </body>
</html>
```

## Prosty klient HTTP

Zacznijmy od napisania funkcji która zwróci gniazdo połączone z
serwerem http.

```c
#include <netinet/in.h>
#include <arpa/inet.h>

int connected_socket(const char *ip, unsigned short port)
{
	int fd = socket(AF_INET, SOCK_STREAM, 0);
	if (fd < 0)
		return -1;

	struct sockaddr_in addr = {
		.sin_family = AF_INET,
		.sin_port = htons(port),
	};
	if (!inet_aton(ip, &addr.sin_addr))
		goto err_close;

	if (connect(fd, (const struct sockaddr *)&addr, sizeof(addr)))
		goto err_close;

	return fd;

err_close:
	close(fd);
	return -1;
}
```

## Prosty klient HTTP - treść żądania

```c
...

int connected_socket(const char *addr, const char *port) { ... }

static const char *http_request =
	"GET / HTTP/1.1\r\n"
	"Host: example.com\r\n"
	"Connection: close\r\n"
	"\r\n";

int main(void) { ... }
```

## Prosty klient HTTP - wysyłanie żądania

```c
...
#include <errno.h>
#include <unistd.h>

int write_all(int fd, const void *buf, size_t len)
{
	unsigned char *bytes = buf;
	size_t remaining = len;

	/* Jeżeli jest jeszcze coś do wpisania */
	while (remaining) {
		/* Wpisz ile się da */
		ssize_t num_written = write(fd, bytes, remaining);
		if (num_written <= 0)
			return errno;

		/* Zauktualizuj ile jeszcze mamy wpisać */
		remaining -= (size_t)num_written;

		/* Przesuń wskaźnik do jeszcze nie wpisanych danych */
		bytes += (size_t)num_written;
	}
	return 0;
}
```

## Prosty klient HTTP - odbieranie odpowiedzi

```c
...
int read_all(int fd, void *buf, size_t len)
{
	int ret = 0;
	unsigned char *bytes = buf;
	size_t remaining = len;
	while (1) {
		/* Odczytaj blok danych */
		char buf[1024];
		ssize_t num_read = read(fd, buf, sizeof(buf));
		if (num_read < 0)
			return errno;
		if (num_read == 0)
			break;
		/* Oceń czy można skopiować cały blok, czy tylko tyle ile sie zmieści */
		size_t to_copy = remaining < num_read ? remaining : num_read;
		if (!to_copy) {
			ret = ENOBUFS;
			continue;
		}

		/* Skopiuj odczytany kawałek do bufora */
		memcpy(bytes, buf, to_copy);
		remaining -= to_copy;
		bytes += to_copy;
	}
	return ret;
}
```

## Prosty klient HTTP - żądanie i odpowiedź

```c
...
#include <sys/types.h>
#include <sys/socket.h>
#include <unistd.h>
#include <stdio.h>

int connected_socket(const char *addr, const char *port) { ... }
int read_all(int fd, void *buf, size_t len) { ... }
int write_all(int fd, const void *buf, size_t len) { ... }

static const char *http_request = ...

int main(void)
{
	int fd = connected_socket("93.184.216.34", 80);
	if (fd < 0)
		return 1;

	if (write_all(fd, http_request, strlen(http_request)))
		goto err_close_fd;

	char response[9000] = {0};
	if (read_all(fd, response, sizeof(response) - 1));
		goto err_close_fr;

	printf("%s", buf);

err_close_fd:
	close(fd);

	return 0;
}
```

## Prosty klient HTTP - efekt

```
$ ./a.out
HTTP/1.1 200 OK
Accept-Ranges: bytes
Age: 482357
Cache-Control: max-age=604800
Content-Type: text/html; charset=UTF-8
Date: Thu, 07 Apr 2022 19:42:28 GMT
Etag: "3147526947"
Expires: Thu, 14 Apr 2022 19:42:28 GMT
Last-Modified: Thu, 17 Oct 2019 07:18:26 GMT
Server: ECS (nyb/1D1B)
Vary: Accept-Encoding
X-Cache: HIT
Content-Length: 1256
Connection: close

<!doctype html>
<html>
<head>
    <title>Example Domain</title>
    ...
```

## Prosty klient HTTPS - SSL

```c
...
#include<openssl/ssl.h>

int main(void)
{
	SSL_CTX* ctx = SSL_CTX_new(SSLv23_client_method());
	if (!ctx)
		return 1;

	int fd = connected_socket("93.184.216.34", 80);
	if (fd < 0)
		goto err_ssl_ctx_free;

	...

err_ssl_ctx_free:
	SSL_CTX_free(ctx);
	return 0;
}
```

## Prosty klient HTTPS - SSL

```c
...
int main(void)
{
	SSL_CTX* ctx = SSL_CTX_new(SSLv23_client_method());
	if (!ctx)
		return 1;

	int fd = connected_socket("93.184.216.34", 80);
	if (fd < 0)
		goto err_ssl_ctx_free;

	SSL* ssl = SSL_new(ctx);
	if (!ssl)
		goto err_close;
	if (SSL_set_fd(ssl, fd) != 1 || SSL_connect(ssl) != 1)
		goto err_free_ssl;

	...

err_free_ssl
	SSL_free(ssl);
err_close_fd:
	close(fd);
err_ssl_ctx_free:
	SSL_CTX_free(ctx);
	return 0;
}
```

## Prosty klient HTTPS - wysyłanie żądania

```c
...

int write_all(SSL *ssl, const void *buf, size_t len)
{
	unsigned char *bytes = buf;
	int remaining = (int)len;

	/* Jeżeli jest jeszcze coś do wpisania */
	while (remaining) {
		/* Wpisz ile się da */
		int num_written = SSL_write(ssl, bytes, remaining);
		if (num_written <= 0)
			return 1;

		/* Zauktualizuj ile jeszcze mamy wpisać */
		remaining -= num_written;

		/* Przesuń wskaźnik do jeszcze nie wpisanych danych */
		bytes += num_written;
	}
	return 0;
}
```

## Prosty klient HTTPS - odbieranie odpowiedzi

```c
...
int read_all(SSL *ssl, void *buf, size_t len)
{
	int ret = 0;
	unsigned char *bytes = buf;
	int remaining = (int)len;
	while (1) {
		/* Odczytaj blok danych */
		char buf[1024];
		int num_read = SSL_read(ssl, buf, sizeof(buf));
		if (num_read < 0)
			return errno;
		if (num_read == 0)
			break;
		/* Oceń czy można skopiować cały blok, czy tylko tyle ile sie zmieści */
		int to_copy = remaining < num_read ? remaining : num_read;
		if (!to_copy) {
			ret = ENOBUFS;
			continue;
		}

		/* Skopiuj odczytany kawałek do bufora */
		memcpy(bytes, buf, to_copy);
		remaining -= to_copy;
		bytes += to_copy;
	}
	return ret;
}
```

## Prosty klient HTTPS - żądanie i odpowiedź

```c
int main(void)
{
	SSL_CTX* ctx = SSL_CTX_new(SSLv23_client_method());
	if (!ctx)
		return 1;

	int fd = connected_socket("93.184.216.34", 80);
	if (fd < 0)
		goto err_ssl_ctx_free;

	SSL* ssl = SSL_new(ctx);
	if (!ssl)
		goto err_close;
	if (SSL_set_fd(ssl, fd) != 1 || SSL_connect(ssl) != 1)
		goto err_free_ssl;

	if (write_all(ssl, http_request, strlen(http_request)))
		goto err_free_ssl;

	char response[9000] = {0};
	if (read_all(ssl, response, sizeof(response) - 1));
		goto err_free_ssl;

err_free_ssl
	SSL_free(ssl);
err_close_fd:
	close(fd);
err_ssl_ctx_free:
	SSL_CTX_free(ctx);
	return 0;
}
```


# Dziękuję za uwagę
