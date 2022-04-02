# Zagadnienie 3: Obsługa plików

## Komunikacja międzyprocesowa

Metody komunikacji międzyprocesowej:

- pliki
- potoki nienazwane
- potoki nazwane
- semafory
- pamięc współdzielona
- sockety
- kolejki komunikatów
- sygnały

# Obsługa plików - standard C

## Obsługa plików według standardu języka C

Biblioteka standardowa języka dostarcza funkcję do obsługi plików:

- `fopen()` - otwiera plik
- `fclose()` - zamyka plik
- `fread()` - odczytuje porcję danych z pliku
- `fwrite()` - wpisuje porcję danych do pliku

## Standard C - otwieranie pliku do odczytu

Do otwierenia pliku służy funkcja `fopen()`.
```c
/**
 * @path: ścieżka do pliku
 * @mode: tryb w jakim otwierany jest plik
 */
FILE *fopen(const char *path, const char *mode);
```

Przykład:
```c
FILE *file = fopen("plik.txt", "r");
if (!file)
    fprintf(stderr, "err: can't open file\n");
```

## Standard C - otwieranie pliku do zapisu

Otwieranie pliku od zapisu:
```c
FILE *file = fopen("plik.txt", "w");
if (!file)
    fprintf(stderr, "err: can't open file\n");
```

Otwieranie pliku do zapisu binarnego:
```c
FILE *file = fopen("plik.txt", "wb");
if (!file)
    fprintf(stderr, "err: can't open file\n");
```

Jeśli plik nie istnieje - zostanie utworzony. Jeżeli plik istnieje
jego zawartosć zostanie usunięta.

## Standard C - zamykanie pliku

Do zamykania pliku służy funkcja `fclose()`
```c
/**
 * @file: wskaźnik do pliku
 */
int fclose(FILE *file);
```

Przykład:
```c
fclose(file);
```

## Standard C - odczytywanie danych z pliku

```c
/**
 * @ptr: wskaźnik do miejsca w pamięci gdzie mamy wczytać dane
 * @size: rozmiar elementu
 * @nitems: liczba elementów
 * @file: plik z którego odczytujemy
 */
size_t fread(void *ptr, size_t size, size_t nitems, FILE *file);
```

Przykład - odczytanie z pliku do 32 bajtów:
```c
char bytes[32];
size_t count = fread(bytes, 1, sizeof(bytes), file);
if (count == 0) {
    /* Koniec pliku */
}
```

Plik `file` musi być otwarty do odczytu.

## Standard C - zapisanie danych do pliku

```c
/**
 * @ptr: wskaźnik do miejsca w pamięci z którego mamy zapisać dane
 * @size: rozmiar elementu
 * @nitems: liczba elementów
 * @file: plik do którego zapisujemy
 */
size_t fwrite(const void *ptr, size_t size, size_t nitems, FILE *file);
```

Przykład - zapisanie ciągu znaków `"Hello world"` w pliku:
```c
char text[] = "Hello world";

size_t count = fwrite(text, 1, sizeof(text), file);
```

Plik `file` musi być otwarty do zapisu.

## Standard C - sformatowany zapis i odczyt

Na plikach możemy wywoływać funkcję analogiczne do `printf()` i `scanf()`,
czyli `fprintf()` i `fscanf()`.

Przykład - funkcja `fscanf()`:
```c
float x, y, z;
if (3 != fscanf(file, "%f %f %f", &x, &y, &z)) {
    /* Nie udało się odczytać */
}
```

Przykład - funkcja `fprintf()`:
```c
const char *name = "Antoni";

fprintf(file, "Witaj %s\n", name);
```

## Standard C - standardowe wyjście jest plikiem

Standardowe wyjście jest plikiem. Jest on otwarty pod zmienną globalną
o nazwie `stdout`.

```c
char text[] = "Hello world";
fwrite(text, 1, sizeof(text), stdout);
```

```c
const char *name = "Antoni";
fprintf(stdout, "Witaj %s\n", name);
```

## Standard C - standardowe wejście jest plikiem

Standardowe wejście jest plikiem. Jest ono otwarte pod zmienną globalną
o nazwie `stdin`.

```c
int number;
if (1 != fscanf(stdin, "%d", &number)) {
    /* Nie udało się odczytać */
}
```
```c
char bytes[32];
size_t count = fread(bytes, 1, sizeof(bytes), stdin);
if (count == 0) {
    /* Koniec pliku */
}
```

## Standard C - standardowy strumień błędów jest plikiem

Standardowy strumień błędów jest plikiem. Jest on otwarty pod zmienną globalną
o nazwie `stderr`.

```c
fprintf(stderr, "error: serious bug number %d\n", 123);
```

## Przykład - zapisanie standardowego wejscia do pliku

```c
FILE *file = fopen("out.txt", "wb");
if (!file) {
    fprintf(stderr, "err: failed to open file 'out.txt'\n");
    return 1;
}

unsigned char chunk[128];
while (1) {
    size_t count = fread(chunk, 1, sizeof(chunk), stdin);
    if (!count)
        break;
    size_t count_wr = fwrite(chunk, 1, count, file);
    if (count_wr != count)
        break;
}
fclose(file);
```

```
$ echo ten_tekst_bedzie_w_out.txt | ./program
```

## Przykład - zapisanie 2 zmiennych do pliku

```c
FILE *file = fopen("out.txt", "wb");
if (!file) {
    fprintf(stderr, "err: failed to open file 'out.txt'\n");
    return 1;
}

int a;
float b;
size_t count = fwrite(&a, sizeof(a), 1, file);
if (count != 1) {
    fclose(file);
    return 1;
}
count = fwrite(&b, sizeof(b), 1, file);
if (count != 1) {
    fclose(file);
    return 1;
}
fclose(file);
```

## Przykład - odczytanie 2 zmiennych z pliku

```c
FILE *file = fopen("out.txt", "rb");
if (!file) {
    fprintf(stderr, "err: failed to open file 'out.txt'\n");
    return 1;
}

int a;
float b;
size_t count = fread(&a, sizeof(a), 1, file);
if (count != 1) {
    fclose(file);
    return 1;
}
count = fread(&b, sizeof(b), 1, file);
if (count != 1) {
    fclose(file);
    return 1;
}
fclose(file);
```

# Obsługa plików - wywołania systemowe

## Obsługa plików za pomocą wywołań systemowych POSIX

POSIX definiuje między innymi następujące wywołania systemowe do obsługi plików:

- `open()` - otwiera plik
- `close()` - zamyka plik
- `read()` - odczytuje porcję danych z pliku
- `write()` - wpisuje porcję danych do pliku

## Wywołania systemowe - otwieranie pliku do odczytu

Do otwierenia pliku służy funkcja `open()`.
```c
/**
 * @path: ścieżka do pliku
 * @oflag: flagi określający tryb otwarcia pliku
 * @mode: uprawnienia do pliku - w przypadku tworzenia pliku
 */
int open(const char *path, int oflag);
int open(const char *path, int oflag, mode_t mode);
```

Przykład:
```c
int fd = open("plik.txt", O_RDONLY)
if (fd < 0)
    fprintf(stderr, "err: can't open file\n");
```

## Wywołania systemowe - otwieranie pliku do zapisu

```c
int fd = open("plik.txt", O_WRONLY | O_CREAT | O_TRUNC, 0644)
if (fd < 0)
    fprintf(stderr, "err: can't open file\n");
```

Jeżeli plik nie istnieje - zostanie utworzony. Jeżeli istnieje, jego zawartość
zostanie usunięta.

Nie ma podziału na tryb binarny i tryb tekstowy. Jest tylko tryb binarny.

## Wywołania systemowe - zamykanie pliku

Do zamykania pliku służy funkcja `close()`
```c
/**
 * @fd: deskryptor pliku
 */
int close(int fd);
```

Przykład:
```c
close(file_fd);
```

## Wywołania systemowe - wczytywanie danych z pliku

```c
/**
 * @fd: deskryptor pliku
 * @buf: miejsce w pamięci gdzie zostaną zapisane dane z pliku
 * @count: liczba bajtów do odczytania
 */
ssize_t read(int fd, void *buf, size_t count);
```

Przykład - odczytanie z pliku do 32 bajtów:
```c
char bytes[32];
ssize_t count = read(fd, bytes, sizeof(bytes));
if (count == 0) {
    /* Koniec pliku */
}
if (count < 0) {
    /* Bląd odczytu */
}
```

Plik `fd` musi być otwarty do odczytu.

## Wywołania systemowe - zapisywanie danych do pliku

```c
/**
 * @fd: deskryptor pliku
 * @buf: miejsce w pamięci z którego zostaną zapisane dane do pliku
 * @count: liczba bajtów do zapisu
 */
ssize_t write(int fd, const void *buf, size_t count);
```

Przykład - zapisanie ciągu znaków `"Hello world"` w pliku

```c
char text[] = "Hello world";

ssize_t count = write(fd, text, sizeof(text));
if (count != sizeof(text)) {
    /* Nie wszystko się udało zapisać - błąd */
}
```

## Wywołanie systemowe - standardowe wyjście jest plikiem

Standardowe wyjście jest plikiem. Jest ono otwarte pod deskryptorem `1`.

```c
char text[] = "Hello world";
write(1, text, sizeof(text));
```

## Wywołanie systemowe - standardowe wejście jest plikiem

Standardowe wejście jest plikiem. Jest ono otwarte pod deskryptorem `0`.

```c
char character;
ssize_t ret = read(0, &character, 1);
if (ret <= 0) {
    /* Koniec wejścia albo błąd */
}
```


## Wywołanie systemowe - standardowy strumień błędów jest plikiem

Standardowy strumień błędów jest plikiem. Jest on otwarty pod deskryptorem `2`.

```c
write(2, "error: successfully failed\n", strlen("error: successfully failed\n") + 1);
```

## Przykład - zapisanie standardowego wejscia do pliku

```c
int fd = open("out.txt", O_CREATE | O_WRONLY | O_TRUNC, 0664);
if (fd < 0) {
    fprintf(stderr, "err: failed to open file 'out.txt'");
    return 1;
}

unsigned char chunk[128];
while (1) {
    ssize_t count = read(0, chunk, sizeof(chunk));
    if (count <= 0)
        break;
    ssize_t count_wr = write(fd, chunk, count);
    if (count_wr != count)
        break;
}
close(file);
```

```
$ echo ten_tekst_bedzie_w_out.txt | ./program
```


## Przykład - zapisanie 2 zmiennych do pliku

```c
int fd = open("out.txt", O_CREAT | O_WRONLY | O_TRUC, 0664);
if (fd < 0) {
    fprintf(stderr, "err: failed to open file 'out.txt'");
    return 1;
}
int a;
float b;
ssize_t count = write(fd, &a, sizeof(a));
if (count != sizeof(a)) {
    close(fd);
    return 1;
}
count = write(fd, &b, sizeof(b));
if (count != sizeof(a)) {
    close(fd);
    return 1;
}
close(fd);
```

## Przykład - odczytanie 2 zmiennych z pliku

```c
int fd = open("out.txt", O_RDONLY);
if (!file) {
    fprintf(stderr, "err: failed to open file 'out.txt'");
    return 1;
}
int a;
float b;
ssize_t count = read(fd, &a, sizeof(a));
if (count != sizeof(a)) {
    close(fd);
    return 1;
}
count = read(fd, &b, sizeof(b));
if (count != sizeof(b)) {
    close(fd);
    return 1;
}
close(fd);
```

## Endianowość

Poprzednie 2 przykłady (zapis i odczyt zmiennych wielobajtowych z pliku) będą działać tylko i wyłącznie
jeżeli plik jest zapisany i odczytany na maszynie z taką samą endianowością.

Jeżeli zapisujemy plik na maszynie z procesorem pracującym w trybie little endian (x86, ARM, ...)
i przeniesiemy go na inną maszyne z procesorem pracującym w trybie big endian (MIPS, ARM, ...),
i tam odczytamy, to kolejność bajtów się nie będzie zgadzać i dostaniemy inne wartości.
Przykład:

```
Liczba całkowita czterobajtowa 64048 = 0x0000FA30

Little endian:
+----+----+----+----+
| 30 | FA | 00 | 00 | ---- kierunek adresów ---->
+----+----+----+----+

Big endian:
+----+----+----+----+
| 00 | 00 | FA | 30 | ---- kierunek adresów ---->
+----+----+----+----+
```

## Jak radzić sobie z endianowością?

Z endianowością można poradzić sobie:

- Zapisując dane po prostu jako tekst.
- Zamieniając kolejność bajtów na jedną ustaloną endianowość (np. Big Endian) i zapisując
  ją w ten sposób do pliku. Następnie wykonywać operację odwrotną przy odczytywaniu - jeżeli
  jesteśmy na innej endianowości.

Nagłówek `<arpa/inet.h>` definiuje funkcje pozwalające zamienić endianowość liczby.

```c
#include <arpa/inet.h>
uint32_t htonl(uint32_t hostlong);
uint16_t htons(uint16_t hostshort);
uint32_t ntohl(uint32_t netlong);
uint16_t ntohs(uint16_t netshort);
```

```c
uint32_t n_host_endian = 0xFA30;
uint32_t big_endian = htonl(n_host_endian);
```

# Dziękuję za uwagę
