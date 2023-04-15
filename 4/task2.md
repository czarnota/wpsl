# Serwer HTTP z podstronami

Celem zadania jest rozszerzenie rozwiązania Zadania 4.1 [html](https://czarnota.github.io/wpsl/4/task1-solved), [md](https://github.com/czarnota/wpsl/tree/main/4/task1-solved.md))
o możliwość serwowania podstron.

Jeżeli użytkownik wejdzie na stronę `http://localhost/foo.html`, to serwer powinien
otworzyć plik o nazwie `foo.html` i wysłać jego zawartość do użytkownika.

# Podpowiedź

Można rozpocząć wykorzystując poniższy kod:
```c
#include <sys/types.h>
#include <sys/socket.h>
#include <netdb.h>
#include <unistd.h>
#include <stdio.h>
#include <string.h>

/* Zwraca gniazdo sieciowe nasłuchujące na zadanym porcie */
int listening_socket(const char *port)
{
	struct addrinfo hints = {
		.ai_family = AF_INET,
		.ai_socktype = SOCK_STREAM,
		.ai_protocol = IPPROTO_TCP,
		.ai_flags = AI_PASSIVE,
	};

	struct addrinfo *result;
	int ret = getaddrinfo(NULL, port, &hints, &result);
	if (ret)
		return -1;

	int fd = -1;
	for (struct addrinfo *i = result; i != NULL; i = i->ai_next) {
		fd = socket(i->ai_family, i->ai_socktype, i->ai_protocol);
		if (fd < 0)
			continue;

		ret = bind(fd, i->ai_addr, i->ai_addrlen);
		if (ret) {
			close(fd);
			fd = -1;
			continue;
		}

		ret = listen(fd, 16);
		if (ret) {
			close(fd);
			fd = -1;
			continue;
		}


		break;
	}

	return fd;
}

/* Wysyła odpowiedź 404 Not Found poprzez gniazdo sieciowe
   wskazywane przez fd */
int write_404(int fd)
{
    char http_response_template[] =
        "HTTP/1.1 404 Not Found\r\n"
        "Content-Type: text/html\r\n"
        "Connection: close\r\n"
        "Content-Length: %d\r\n"
        "\r\n"
        "%s"
    ;

    char html[] =
        "<!doctype html>\n"
        "<html lang=\"pl\">\n"
        "    <head>\n"
        "        <meta charset=\"utf-8\">\n"
        "        <meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge\">\n"
        "        <meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">\n"
        "        <title>Title</title>\n"
        "    </head>\n"
        "    <body>\n"
        "        <h1>Error 404</h1>\n"
        "    </body>\n"
        "</html>\n"
    ;

    char response[4096];
    snprintf(response, sizeof(response), http_response_template, strlen(html), html);

    ssize_t len = strlen(response);

    if (write(fd, response, len) != len)
        return -1;
    return 0;
}

int main(int argc, char **argv)
{
	int server_fd = listening_socket("8080");
	if (server_fd < 0)
		return 1;

	while (1) {
		int fd = accept(server_fd, NULL, NULL);
		if (fd < 0)
			continue;

		char buf[9000] = {0};
		int count = read(fd, buf, sizeof(buf) - 1);
		if (count <= 0)
			break;

        write_404(fd);

		close(fd);
	}

	close(server_fd);

    return 1;
}
```

W tym celu należy rozszerzyć kawałek kodu odpowiedzialny za odczytywanie żądania
od klienta o odczytywanie żądanej podstrony.

```c
/* Odczytanie żądania z gniazda sieciowego */
char buf[9000] = {0};
int count = read(fd, buf, sizeof(buf) - 1);
if (count <= 0)
    break;

/* Odczytanie ciągu znaków wskazującego podstonę */
char page[255];
if (sscanf(buf, "GET %254s", page) != 1) {
    write_404(fd);
    close(fd);
    continue;
}

/* Usunięcie początkowych / */
char file_path[255];
while (page[0] == '/')
    snprintf(file_path, sizeof(result), "%s", &page[1]);
```

Następnie należy otworzyć plik wskazywany przez odczytaną scieżkę.
```c
FILE *f = fopen(file_path, "r");
if (!f) {
    write_404(fd);
    close(fd);
    continue;
}
```

Żeby wysłać plik, musimy znać jego rozmiar, aby poprawnie wypełnić
nagłówek `Content-Length`.

```c
int filesize(FILE *f)
{
    fseek(f, 0, SEEK_END);
    int size = (int)ftell(f);
    fseek(f, 0, SEEK_SET);
    return size;
}
```

Do wysyłania nagłówku można użyc poniższej funkcji:
```c
int send_header(int fd, int content_length)
{
    char header[256];
    snprintf(header, sizeof(header),
                "HTTP/1.1 200 OK\r\n"
                "Content-Type: text/html\r\n"
                "Connection: close\r\n"
                "Content-Length: %d\r\n"
                "\r\n", content_length);

    ssize_t len = strlen(header);

    if (write(fd, header, sizeof(header)) != len)
        return -1;
    return 0;
}
```
```c
if (send_header(fd, filesize(f))) {
    close(fd);
    continue;
}
```

Ostatecznym krokiem jest wysłanie zawartości pliku za pomocą `write()`. W tym
celu można odczytywać plik `f` w pętli za pomocą funkcji `fread()` i zapisywać
do gniazda sieciowego za pomocą `write()`, tak długo dopóki `fread()` zwraca
wartość większą od `0`.

Prosze pamiętać o zamknięciu połączenie za pomocą `close()`.
