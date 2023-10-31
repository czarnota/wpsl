# Lista przypomnień

Celem zadania jest implementacja listy przypomnień z użyciem wątków.

# Funkcjonalność

## Znak zachęty

Jeżeli uruchomimy program powinien on wyświetlić znak zachęty `>`
```
$ ./program
>
```

## Dodawanie przypomnień

Użytkownik może wpisać `HH:MM Tresc przypomnienia`, gdzie `HH` to godzina, a `MM`
to minuta o której ma zostać wyświetlona treść przypomnienia. Spowoduje to dodanie
przypomnienia do listy przypomnień.

```
$ ./program
> 13:00 koniec zajec
Added reminder "13:00 koniec zajec" at 13:00
```

Nie jest konieczne rozdzielanie linijki na czas i wiadomość - jako treść przymomnienia
można przyjąć całą linijkę jaką wpisał użytkownik.

## Maksymalna liczba przypomnień

Użytkownik musi mieć możliwość dodania 5 przypomnień. Dodanie większej liczby
spowoduje wyświetlenie informacji o niemożności dodania przypomnienia.

```
$ ./program
> 8:00 start zajec
Added reminder "8:00 start zajec" at 8:00
> 9:30 koniec zajec
Added reminder "9:30 koniec zajec" at 9:30
> 9:35 start zajec 2
Added reminder "9:35 start zajec" at 9:35
> 11:05 koniec zajec 2
Added reminder "11:05 start zajec 2" at 11:05
> 11:10 start zajec 3
Added reminder "11:10 start zajec 3" at 11:10
> 12:40 koniec zajec 3
Can't add reminder "12:40 koniec zajec 3" at 12:40
```

## Wyświetlanie listy przypomnień

Użytkownik musi mieć możliwość wyświetlenia listy dodanych przypomnień, wpisując
komendę `list`.

```
> list
8:00 start zajec
9:30 koniec zajec
9:35 start zajec 2
11:05 koniec zajec 2
11:10 start zajec 3
```

## Przypominanie

Program musi wyświetlić użytkownikowi treść przypomnienia w momencie, gdy nadejdzie
czas na który dane przyponienie zostało zaplanowane.

W tym celu program powinien w osobnym wątku odpytywać system operacyjny o aktualną
godzinę oraz minutę i jeżeli będzie ona równa godzinie, na którą zostało zaplanowane
jedno z przypomnień, to treść przypomnienia musi wyswietlić się użytkownikowi.

```
>
9:30 koniec zajęć           <---- Gdy wybiła godzina 9:30
```

## Usuwanie przypomnienia po jego wystąpieniu

Jeżeli użytkownik dodał przypomnienie, to po wystąpieniu musi zostać ono usunięte
z listy przypomnień.

```
> 12:00 kupic mleko
> 13:00 zrobic obiad
> list
12:00 kupic mleko
13:00 kupic mleko
>
>
12:00 kupic mleko           <---- Gdy wybiła godzina 12:00
> list
13:00 kupic mleko
```

## Zakończenie programu

Jeżeli użytkownik wpisze `exit`, to program powinien się zakończyć, kończąć przy tym
uruchamiony wątek odpytywania aktualnego czasu.

```
> exit
```

## Nieznane komendy

Program musi wspierać następujące komendy:
- `list` - wyświetlanie przypomnień,
- `exit` - kończenie programu,
- `HH:MM Text` - dodawanie przypomnień;

Jeżeli użytkownik wpisze komendę, która nie jest znana, to program po prostu ją ignoruje
i odczytuje następną linie

```
> sadas
> sadas
> asasassa
>
>
> test
>
```

## Długość treści przypomnienia

Użytkownik musi mieć możliwość wprowadzenia treści przypomnienia o długości co najmniej 48 znaków.

# Podpowiedzi

## Przydatne strony podręcznika

- `man pthread` - opis biblioteki pthread
- `man pthread_create` - tworzenie wątku
- `man pthread_join` - łączenie wątku
- `man pthread_mutex_lock` - blokowanie mutexu
- `man pthread_mutex_unlock` - odblokowanie mutexu
- `man pthread_mutex_init` - inicjalizacja mutexu
- `man pthread_mutex_destroy` - deinicjalizacja mutexu
- `man snprintf` - kopiowanie i formatowanie ciągów znaków
- `man fgets` - odczytywanie linii z wejścia
- `man 3 time` - pobieranie aktualnego czasu
- `man localtime_r` - konwersja `time_t` na `struct tm`, w celu wydobycia godziny i minuty
- `man strcmp` - porównywanie ciągów znaków
- `man sscanf` - skanowanie ciągu znaków

## Pobieranie aktualnego czasu

W celu pobrania aktualnej godziny i minuty można wykorzystać funkcję `time()` oraz
`localtime_r`. Można wykorzystać następujący przykład:

```c
#include <stdio.h>
#include <time.h>

int main(void)
{
    time_t current_time = time(NULL);

    struct tm tm;
    localtime_r(&current_time, &tm);

    printf("godzina %d minuta %d", tm.tm_hour, tm.tm_min);

    return 0;
}
```

## Kopiowanie ciągów znaków

Do bezpiecznego kopiowania ciągów znaków można użyć funkcji `snprintf()`.

```c
#include <stdio.h>

int main(void)
{
    char source[32] = "Hello world";
    char destination[64];

    snprintf(destination, sizeof(destination), "%s", source);

    printf("%s", destination);

    return 0;
}
```

## Sprawdzanie czy ciąg znaków jest pusty

```c
#include <string.h>

int main(void)
{
    char name[32] = "";

    /* Sposób 1 */
    if (strlen(name) == 0)
        printf("ciag znakow name jest pusty\n");

    /* Sposób 2 */
    if (strcmp(name, "") == 0)
        printf("ciag znakow name jest pusty\n");

    /* Sposób 3 - sprawdzenie czy pierwszy bajt to 0, co jest tożsame z pustym ciągiem znaków */
    if (name[0] == 0)
        printf("ciag znakow name jest pusty\n");

    return 0;
}
```

## Inicjalizacja muteksu

Do inicjalizacji mutexu można użyć stałej `PTHREAD_MUTEX_INITIALIZER`;

```c
#include <pthread.h>

pthread_mutex_t lock = PTHREAD_MUTEX_INITIALIZER;

int main(void)
{
    pthread_mutex_lock(&lock);
    /* sekcja krytyczna */
    pthread_mutex_unlock(&lock);

    return 0;
}
```

Alternatywnie, można użyć `pthread_mutex_init()` i `pthread_mutex_destroy()`

```c
#include <pthread.h>
#include <stdio.h>

pthread_mutex_t lock;

int main(void)
{
    int ret = pthread_mutex_init(&lock, NULL);
    if (ret) {
        fprintf(stderr, "pthread_mutex_init failed with %d", ret);
        return -1;
    }

    pthread_mutex_lock(&lock);
    /* sekcja krytyczna */
    pthread_mutex_unlock(&lock);

    ret = pthread_mutex_destroy(&lock);
    if (ret) {
        fprintf(stderr, "pthread_mutex_destroy failed with %d", ret);
        return -1;
    }

    return 0;
}
```

## Reprezentacja listy przypomnień w pamięci

Lista przypomnień musi pomieścić 5 elementów. Wobec tego będziemy przechowywać:
- 5 godzin, o których ma wystąpić przypomnienie
- 5 minut, o których ma wystąpić przypomnienie
- 5 treści przypomnien, które będą wyświetlane

```c
#include <stdio.h>
#include <string.h>

int hours[5];
int minutes[5];
char reminder_texts[5][64];

int main(void)
{
    /* Utworzenie pierwszego przypomnienia o 23:00 */
    snprintf(reminder_texts[0], sizeof(reminder_texts[0]), "%s", "23:00 tresc pierwszego przypomnienia");
    hours[0] = 23;
    minutes[0] = 0;

    /* Utworzenie drugiego przypomnienia o 23:30 */
    snprintf(reminder_texts[1], sizeof(reminder_texts[1]), "%s", "23:30 tresc drugiego przypomnienia");
    hours[1] = 23;
    minutes[1] = 30;

    /* Wyszukanie wolnego miejsca na przypomnienie */
    int i = 0;
    for (i = 0; i < 5; ++i) {
        if (strlen(reminder_texts[i]) == 0) {
            snprintf(reminder_texts[i], sizeof(reminder_texts[i]), "%s", "21:36 tresc trzeciego przypomnienia");
            hours[i] = 21;
            minutes[i] = 36;
            break;
        }
    }
    if (i == 5) {
        /** doszliśmy do końca = brak miejsca */
    }

    /* Usunięcie przypomnienia o indeksie 1 */
    snprintf(reminder_texts[1], sizeof(reminder_texts[1]), "%s", "");

    /* Wyświetlenie wszystkich przypomnień */
    for (int i = 0; i < 5; ++i) {
        if (strlen(reminder_texts[i]) == 0)
            continue;

        printf("%s\n", reminder_texts[i]);
    }

    return 0;
}
```

## Pętla z interfejsem użytkownika

Oto przykładowa pętla realizująca interfejs użytkownika:

```c
#include <stdio.h>
#include <string.h>
#include <errno.h>

int main(void)
{
    /* Pętla z interfejsem użytkownika, wykonywana w wątku głównym */
    while (1) {
        /* Znak zachęty */
        printf("> ");

        /* Odczytywanie linii - maksymalnie wspieramy 80 znaków */
        char line[80];
        if (!fgets(line, sizeof(line), stdin)) {
            if (errno)
                perror("fgets");
            break;
        }

        /* Nie oczekujemy pustego ciągu znaków of fgets() */
        size_t len = strlen(line);
        if (len == 0) {
            fprintf(stderr, "unexpected empty string returned by fgets\n");
            break;
        }

        /* Jeżeli ciąg znaków nie kończy się znakiem nowej linii, oznacza
           to że część linii pozostała jeszcze nieodczytana */
        if (line[len - 1] != '\n') {
        
            /* W takim przypadku odczytaj reszte linii i zgłoś użytkowikowi
               że wpisał za dużo znaków */
            do {
                if (!fgets(line, sizeof(line), stdin)) {
                    perror("fgets");
                    break;
                }
            } while (line[strlen(line)] != '\n');

            fprintf(stderr, "line too long\n");
            continue;
        }

        line[len - 1] = 0;

        int h, m;
        if (sscanf(line, "%d:%d", &h, &m) == 2) {
            /* Dodaj przypomnienie */
        }

        if (strcmp("list", line) == 0) {
            /* Wyświetl liste przypomnień */
        }

        if (strcmp("exit", line) == 0) {
            /* Zakończ program */
            break;
        }
    }
}
```
