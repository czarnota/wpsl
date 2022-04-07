# Zagadnienie 4: Komunikacja sieciowa

## Informacje wstępne - tablice

Tablicą nazwywamy ciąg elementów takiego samego typu.

Przykłady tablic:
```c
float numbers[4] = {1.0f, -1.0f, -2.0f, -3.0f};
int a[] = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10};
char name[] = { 'S', 't', 'e', 'f', 'a', 'n', 0 };
char name2[] = "Stefan";
```

Elementy tablicy są ułożone pod kolejnymi adresami w pamięci:
```c
int values[] = {1, 2, 3};
```

```
0x4 0x8 0xb
  +---+---+---+
  | 1 | 2 | 3 |
  +---+---+---+
```

## Informacje wstępne - nazwa tablicy jest wskaźnikiem do pierwszego elementu

```c
int values[] = {1, 2, 3};
int *p = values;
```

```
0x4 0x8 0xb             p
  +---+---+---+          +---+
  | 1 | 2 | 3 |          |0x4|
  +---+---+---+          +---+
  ^------------------------'
```

## Informacje wstępne - struktury

O ile tablice reprezentowały ciąg elementów takiego samego typu, to struktury
reprezentują zbiór elementów o możliwie różnych typach.

Definicja struktury:
```c
struct person {
    int age;
    float salary;
    char name[16];
};
```

Utworzenie obiektu struktury i wypełnienie pól:
```c
struct person p;
p.age = 46;
p.salary = 1029384732.0f;
snprintf(p.name, sizeof(name), "%s", "Daniel");
```

## Informacje wstępne - struktury - inicjalizacja

Strukturę można zainicjalizować podając kolejno jej elementy.
```c
struct person p = { 46, 1029384732.0f, "Daniel" };

/* Rekomendowaną praktyką jest stosowanie "designated initializers" z C99 */
struct person p2 = {
    .age = 46,
    .salary = 1029384732.0f,
    .name = "Daniel",
    /* Pola pominięte bedą zainicjalizowane zerami */
};
```

Inicjalizacja struktury samymi zerami:
```c
struct person p = {0}
```

## Informacje wstępne - struktury układ w pamięci

```c
struct foo {
    char a;
    int b;
    int c;
};
```
Jeżeli kompilujemy program na architekturę, gdzie `sizeof(int) == 4`, to wtedy
struktura może wyglądać w pamięci następujący sposób:
```
+---+---+---+---+---+---+---+---+---+
| a |       b       |       c       |
+---+---+---+---+---+---+---+---+---+
```
**Czy aby na pewno?**

## Informacje wstępne - padding

Niestety, w praktyce najprawdopodobniej kompilator wyrówna pola struktury tak
aby adresy były podzielne np. przez 4, ponieważ w ten sposób procesor może
je szybciej zaadresować:
```c
struct foo {
    char a;
    int b;
    int c;
};
```
```
+---+---+---+---+---+---+---+---+---+---+---+---+
| a |  padding  |       b       |       c       |
+---+---+---+---+---+---+---+---+---+---+---+---+
```
Wartość `sizeof(struct foo)` najprawdopodobniej wyniesie `12`, a nie  `9`.

**Jak pozbyć się/ograniczyć padding?**


## Informacje wstępne - ograniczenie paddingu

Padding można ograniczyć zamieniając kolejność pól. Optymalizując struktury w
ten sposób, można zaoszczędzić pamięć.

```c
struct foo {
    int b;
    int c;
    char a;
};
```
```
+---+---+---+---+---+---+---+---+---+
|       b       |       c       | a |
+---+---+---+---+---+---+---+---+---+
```

Alternatywnie, kompilatory oferują **niestandardowe** rozszerzenia umożliwiające
wyłączenie paddingu: `#pragma pack` w MSVC i `__attribute__((packed))` w `gcc`.

## Informacje wstępne - operacje na strukturach

Struktury obsługują operator przypisania `=`, który powoduje przekopiowanie
wartości każdego pola.

```c
struct vec2 {
    float x;
    float y;
};

struct vec2 position_a = { 2.0f, 10.0f };
struct vec2 position_b = position_a;

printf("%f %f", position_b.x, position_b.y);
```

## Informacje wstępne - definicja i utworzenie obiektu w jednym

Strukturę możemy zdefiniować i od razu utworzyć zmienną jej typu:

```c
struct player_config {
    struct vec2 velocity;
    char name[32];
    int max_hp;
} configuration = {
    .velocity = { 0.0f, 1.0f },
    .name = "Marian",
    .max_hp = 200,
};

printf("%s", configuration.name);
```

## Informacje wstępne - anonimowe struktury

Gdy od razu tworzymy zmienną możemy pominąć nazwę typu:

```c
struct {
    struct vec2 velocity;
    char name[32];
    int max_hp;
} configuration = {
    .velocity = { 0.0f, 1.0f },
    .name = "Marian",
    .max_hp = 200,
};

printf("%s", configuration.name);
```

## Informacje wstępne - tablice struktur

Nic nie stoi na przeszkodzie aby łączyć tablice i struktury:
```c
struct month_info {
    int number;
    int days;
    char name[32];
};
struct month_info months[] = {
    { .number = 1, .days = 31, .name = "January" },
    { .number = 2, .days = 28, .name = "February" },
    { .number = 3, .days = 31, .name = "March" },
    { .number = 4, .days = 30, .name = "April" },
    { .number = 5, .days = 31, .name = "May" },
    { .number = 6, .days = 30, .name = "June" },
    { .number = 7, .days = 31, .name = "July" },
    { .number = 8, .days = 31, .name = "August" },
    { .number = 9, .days = 30, .name = "September" },
    { .number = 10, .days = 31, .name = "October" },
    { .number = 11, .days = 30, .name = "November" },
    { .number = 12, .days = 31, .name = "December" },
};
```

## Informacje wstępne - wskaźniki na struktury

```c
struct foo { int a; };
```
Do pól struktury odnosimy się używając operatora `.`:
```c
struct foo foo = {0, 1}:

printf("%d\n", foo.a);
```

Do pól struktury poprzez wskaźnik odnosimy się używając operatora `->`:
```c
struct foo foo = {0, 1}:
struct foo *bar = &foo;

printf("%d\n", bar->a);
```

## Informacje wstępne - lista jednokierunkowa
Lista jednokierunkowa, podobnie jak tablica pozwala na utworzenie kolekcji elementów
takiego samego typu - z tą różnicą że elementy nie będą ułożone kolejno w pamięci.
```c
struct book {
    /* Wskaźnik do następnego elementu */
    struct book *next;
    char title[128];
};
```

```c
struct book book1 = { .next = NULL, .title = "Harry Potter i Tablica Charów" };
struct book book2 = { .next = &book1, .title = "Harry Router i Maska Podsieci" };
struct book book3 = { .next = &book2, .title = "Alicja na Wydziale Informatyki" };
```

```c
for (struct book *book = &book3; book != NULL; book = book->next)
    printf("tytul: %s\n", book->title);
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
Żądanie HTTP ma również format tekstowy. Składa się z nagłówków zapytania oraz
opcjonalnego ciała
```
METODA WERSJA_HTTP
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

Odpowiedź HTTP również format tekstowy. Składa się z linii statusu, nagłówków 
zapytania oraz opcjonalnego ciała:

```
HTTP/1.1 KOD_ODPOWIEDZI NAZWA_KODU
Nagłówek1: Wartość1
Nagłówek2: Wartość2

<opcjonalne ciało>
```

## Odpowiedź HTTP - przykład

Przykładowa odpowiedź HTTP
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

## Droga pakietu - wysłanie pakietu

![](assets/5.anim.svg)

## Droga pakietu - switch

![](assets/6.anim.svg)

## Droga pakietu - router

![](assets/7.anim.svg)

## Droga pakietu - serwer

![](assets/8.anim.svg)

## Droga pakietu - odebranie pakietu

![](assets/9.anim.svg)

# Gniazda sieciowe POSIX

## Funkcje/wywołania systemowe po stronie klienta

Po stronie klienta:

- `socket()`
- `bind()`
- `connect()`
- `read()`
- `write()`
- `close()`
- `getaddrinfo()`

## Funkcja `getaddrinfo()`

Funkcja `getaddrinfo()` służy do odpytywania usługi DNS.

```c
#include <sys/types.h>
#include <sys/socket.h>
#include <netdb.h>

/**
 * @node: nazwa docelowa np. "onet.pl"
 * @service: nazwa ułsugi np "http" lub "80"
 * @hints: podpowiedzi
 * @res: wynik odpytania usługi DNS
 */
int getaddrinfo(const char *node, const char *service,
               const struct addrinfo *hints,
               struct addrinfo **res);
```
Otrzymany wynik należy "zwolnić" za pomocą `freeaddrinfo()`
```c
void freeaddrinfo(struct addrinfo *res);
```

## Funkcja `getaddrinfo()` przykład

```c
struct addrinfo hints = {
    .ai_family = AF_INET,
    .ai_socktype = SOCK_STREAM,
    .ai_protocol = IPPROTO_TCP,
};

struct addrinfo *result = NULL;
int ret = getaddrinfo("onet.pl", "80", &hints, &result);
if (ret) {
    /* Nie udało się przetłumaczyć nazwy */
}

/* Iterujemy się po każdyn znalezionym adresie */
for (struct addrinfo *i = result; i != NULL; i = i->ai_next) {
    char ip[NI_MAXHOST] = {0};
    /* i->ai_addr i i->ai_addrlen zawierają adres ip */
    getnameinfo(i->ai_addr, i->ai_addrlen, ip, sizeof(ip), NULL, 0, NI_NUMERICHOST);
    printf("IP serwisu onet.pl: %s\n", ip);
}

freeaddrinfo(result);
```

## Wywołanie systemowe `socket()`

Wywołanie systemowe `socket()` otwiera gniazdo sieciowe, za pomocą
którego możemy komunikować się poprzez sieć.

```c
#include <sys/types.h>
#include <sys/socket.h>

/**
 * @domain: Rodzina socketu np. AF_INET, AF_INET6
 * @type: Typ socketu np. SOCK_STREAM, SOCK_DGRAM
 * @protocol: Protokół np. IPPROTO_TCP, IPPROTO_UDP
 */
int socket(int domain, int type, int protocol);
```

Na przykład możemy utrzowyć gniazdo TCP:
```c
int fd = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
if (fd < 0) {
    /* Wystąpił błąd */
}
```

## Wywołanie systemowe `close()`

Wywołanie systemowe `close()` zamyka gniazdo sieciowe.
```c
#include <unistd.h>

int close(int fd);
```

Przykład:
```
close(fd);
```

## Wywołanie systemowe `bind()`

## Wywołanie systemowe `connect()`

## Wywołanie systemowe `read()`

## Wywołanie systemowe `write()`

## Wywołanie systemowe `close()`


## Prosty klient HTTP

## Funkcje/wywołania systemowe po stronie serwera

Po stronie serwera, oprócz:

- `socket()`
- `bind()`
- `read()`
- `write()`
- `close()`
- `getaddrinfo()`

Wykorzystywane są 2 dodatkowe:

- `listen()`
- `accept()`

## Wywołanie systemowe `listen()`

## Wywołanie systemowe `accept()`

# Dziękuję za uwagę
