# Tablica odjazdów autobusów

Celem zadania jest implementacja tablicy wyświetlającej czasy odjazdów
autobusów korzystając z API ZDiTM w Szczecinie <https://www.zditm.szczecin.pl/pl/zditm/dla-programistow/api-tablice-odjazdow>.

![](assets/tablica.png)

# Funkcjonalność

## Wyświetlanie tablicy odjazdów

Program po uruchomieniu z jednym argumentem wyświetla tablice odjazdów autobusów
z przystanku o identyfikatorze przekazanym jako pierwszy argument.

```c
$ ./program 32621
 60  2 min Stocznia Szczecińska
 75  3 min Osiedle Zawadzkiego
222  20:10 Kościno
 53  20:12 Stocznia Szczecińska
 75 13 min Osiedle Zawadzkiego
 75 21 min Osiedle Zawadzkiego
 60  20:27 Stocznia Szczecińska
 75 29 min Osiedle Zawadzkiego
 53  20:36 Stocznia Szczecińska
 80  20:38 Ludowa
227  20:40 Głębokie
 75  20:43 Osiedle Zawadzkiego
 53  20:46 Zawadzkiego
 60  20:54 Stocznia Szczecińska
 75  20:58 Osiedle Zawadzkiego
```

## Pusta tablica

Jeżeli w danym momencie nie ma żadnych zaplanowanych autobusów to program powinien
niz nie wyświetlić.

```c
$ ./program 32621
```

# Podpowiedzi

## Parsowanie JSON za pomocą cJSON

Pliki biblioteki cJSON można pobrać w następujący sposób:

```
wget https://raw.githubusercontent.com/DaveGamble/cJSON/master/cJSON.c
wget https://raw.githubusercontent.com/DaveGamble/cJSON/master/cJSON.h
```

Dokumentacja: <https://github.com/DaveGamble/cJSON#parsing>.

Przykład:

```c
#include <stdio.h>

#include "cJSON.h"

void parse_json(const char *str)
{
	cJSON *root = cJSON_Parse(str);
	if (!root)
		return;
	if (!cJSON_IsObject(root))
		goto err;

	cJSON *products = cJSON_GetObjectItem(root, "products");
	if (!cJSON_IsArray(products))
		goto err;

	cJSON *product;
	cJSON_ArrayForEach(product, products) {
		if (!cJSON_IsObject(product))
			goto err;

		cJSON *name = cJSON_GetObjectItem(product, "name");
		if (!cJSON_IsString(name))
			goto err;

		cJSON *amount = cJSON_GetObjectItem(product, "amount");
		if (!cJSON_IsNumber(amount))
			goto err;

		printf("%s %d\n", name->valuestring, amount->valueint);
	}
err:
	cJSON_Delete(root);
}

int main(void)
{
	parse_json("{\"products\": [{\"name\": \"Strawberry\", \"amount\": 2}, {\"name\": \"Milk\", \"amount\": 10}]}");
	return 0;
}
```

## Instalacja openssl

Bibliotekę openssl można zainstalować w następujący sposób.

```
sudo apt install libssl-dev
```

## Kompilacja

Kompilując program należy zlinkować go z bilioteką libssl i libcrypto.

```
gcc main.c cJSON.c -lcrypto -lssl -o program
```

## Żądanie GET do ZDiTM

Dla przystanku o numerze 32621.

```c
static const char *request =
    "GET /api/v1/displays/32621 HTTP/1.1\r\n"
    "Host: www.zditm.szczecin.pl\r\n"
    "Connection: close\r\n"
    "accept: text/xml\r\n"
    "\r\n"
;
```

## Przydatne funkcje

- `man socket` - otwiera gniazdo
- `man inet_aton` - konwersja ciągu znaków będącym adresem IP do struktury `struct in_addr`
- `man connect` - nawiązanie połączenia z serwerem
- `man 2 read` - odczyt z gniazda
- `man 2 write` - zapis do gniazda
- `man close` - zamyka gniazd

- `SSL_CTX_new()` - utworzenie konteksu openssl <https://www.openssl.org/docs/man3.0/man3/SSL_CTX_new.html>
- `SSL_new()` - utworzenie połączenia openssl <https://www.openssl.org/docs/man3.0/man3/SSL_new.html>  
- `SSL_set_fd()` - związanie połączenia openssl z gniazdem. Gniazdo może być już po wywołaniu connect() <https://www.openssl.org/docs/man3.0/man3/SSL_set_fd.html> 
- `SSL_connect()` - wykonanie "handshake" <https://www.openssl.org/docs/man3.0/man3/SSL_connect.html>
- `SSL_write()` - zapis danych <https://www.openssl.org/docs/man3.0/man3/SSL_write.html>
- `SSL_read()` - odczyt danych <https://www.openssl.org/docs/man3.0/man3/SSL_read.html>
- `SSL_free()` - usunięcie połączenia openssl <https://www.openssl.org/docs/man3.0/man3/SSL_free.html>
- `SSL_CTX_free()` - usunięcie kontekstu openssl <https://www.openssl.org/docs/man3.0/man3/SSL_CTX_free.html>

## Kroki

1. Otwarcie socketu `AF_INET`, `SOCK_STREAM`.
2. Połączenie socketu z IP ZDiTM (46.41.138.133) i portem 443. Ip można sprawdzić za pomocą `ping www.zditm.szczecin.pl`.
3. Utworzenie kontekstu openssl.
4. Utworzenie połączenia openssl.
5. Związanie połączenia openssl z gniazdem.
6. Wykonanie handshake.
7. Wysłanie żądania (zapis za pomocą SSL\_write()).
8. Odczytanie odpowiedzi (odczyt za pomocą SSL\_read()).
9. Odszukanie początku JSON w odpowiedzi (można użyć `man strstr` z ciągiem `\r\n\r\n`).
10. Użycie cJSON do sparsowania odpowiedzi i wyświetlenia rozkładu jazdy.
11. Usunięcie połęczenia SSL.
12. Usunięcie konteksu SSL.
13. Zamknięcie gniazda.
