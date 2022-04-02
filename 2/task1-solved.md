# Minutnik - rozwiązanie

## Krok 1

Pierwszym krokiem jest napisanie funkcji main i załączenie odpowiednich nagłówków:

```c
#include <pthread.h> /* pthread_create() i inne */
#include <stdio.h> /* printf() i inne */
#include <unistd.h> /* sleep() */

int main(void)
{
    return 0;
}
```

## Krok 2 

Napiszmy program który będzie odczytywał jedną linię (max 80 znaków) i 
wyświetlał znak zachęty.

```c
#include <pthread.h> /* pthread_create() i inne */
#include <stdio.h> /* printf() i inne */
#include <unistd.h> /* sleep() */

int main(void)
{
    while (1) {
        printf("> ");

        /* Odczytanie jednej linii - max 80 znaków */
        char line[80];
        if (!fgets(line, sizeof(line), stdin))
            break;
    }
    return 0;
}
```

## Krok 3

Pora dodać przetwarzanie wejścia. Jakie 2 przypadki musimy obsłużyć?

1. Wpisanie liczby
2. Wpisanie znaku zapytania

```c
#include <pthread.h> /* pthread_create() i inne */
#include <stdio.h> /* printf() i inne */
#include <unistd.h> /* sleep() */

int main(void)
{
    while (1) {
        printf("> ");

        /* Odczytanie jednej linii - max 80 znaków */
        char line[80];
        if (!fgets(line, sizeof(line), stdin))
            break;

        int seconds;
        if (sscanf(line, "%d", &seconds) == 1) {
            /* Użytkownik podał liczbę sekund */
            continue;
        }

        char option;
        if (sscanf(line, "%c", &option) == 1 && option == '?') {
            /* Użytkownik podał znak zapytania */
            continue;
        }
    }
    return 0;
}
```

## Krok 4

Potrzebujemy zmiennej, które będzie przechowywać liczbę sekund pozostałych
do wystąpienia alarmu. Nazwijmy ją `time_left`. Będzie ona zmienną globalną
tak aby drugi wątek miał do niej łatwy dostęp.

Jeżeli użytkownik podał liczbę - ustawił czas pozostały do wystąpienia alarmu.
Musimy wpisać ten czas do zmiennej `time_left`. Jeżeli użytkownik
podał znak zapytania to powinniśmy mu wyświetlić ile czasu pozostało do wystąpienia
alarmu - wartość zmiennej `time_left`.

```c
#include <pthread.h> /* pthread_create() i inne */
#include <stdio.h> /* printf() i inne */
#include <unistd.h> /* sleep() */

int time_left;

int main(void)
{
    while (1) {
        printf("> ");

        /* Odczytanie jednej linii - max 80 znaków */
        char line[80];
        if (!fgets(line, sizeof(line), stdin))
            break;

        int seconds;
        if (sscanf(line, "%d", &seconds) == 1) {
            /* Użytkownik podał liczbę sekund */
            time_left = seconds;
            continue;
        }

        char option;
        if (sscanf(line, "%c", &option) == 1 && option == '?') {
            /* Użytkownik podał znak zapytania */
            printf("remaining: %d\n", time_left);
            continue;
        }
    }
    return 0;
}
```

## Krok 5

Mając napisany interfejs użytkownika oraz stan naszego "minutnika", potrzebujemy
teraz mechanizmu, który "w tle" będzie zmniejszał pozostały czas do wystąpienia
alarmu i ostatecznie wypisze `"<<ALARM>>"`. Potrzebujemy drugiego wątku.
Zacznijmy od napisania funkcji wątku, która będzie odejmować `1` co sekundę
od `time_left`.

```c
#include <pthread.h> /* pthread_create() i inne */
#include <stdio.h> /* printf() i inne */
#include <unistd.h> /* sleep() */

int time_left;

void *timer(void *arg)
{
    while (1) {
        /* Czekamy sekundę */
        sleep(1);

        /* Aktualizujemy stan "minutnika" */
        if (time_left > 0) {
            time_left--;
            if (time_left == 0)
                printf("<<ALARM>>\n");
        }
    }

    return NULL;
}

int main(void)
{
    while (1) {
        printf("> ");

        /* Odczytanie jednej linii - max 80 znaków */
        char line[80];
        if (!fgets(line, sizeof(line), stdin))
            break;

        int seconds;
        if (sscanf(line, "%d", &seconds) == 1) {
            /* Użytkownik podał liczbę sekund */
            time_left = seconds;
            continue;
        }

        char option;
        if (sscanf(line, "%c", &option) == 1 && option == '?') {
            /* Użytkownik podał znak zapytania */
            printf("remaining: %d\n", time_left);
            continue;
        }
    }
    return 0;
}
```

## Krok 6

Nasza funkcja nie wykonuje się jeszcze w tle. Musimy utworzyć wątek, który
będzie ją wykonywał.

```c
#include <pthread.h> /* pthread_create() i inne */
#include <stdio.h> /* printf() i inne */
#include <unistd.h> /* sleep() */

int time_left;

void *timer(void *arg)
{
    while (1) {
        /* Czekamy sekundę */
        sleep(1);

        /* Aktualizujemy stan "minutnika" */
        if (time_left > 0) {
            time_left--;
            if (time_left == 0)
                printf("<<ALARM>>\n");
        }
    }

    return NULL;
}

int main(void)
{
    /* Tworzenie wątku */
    pthread_t thread;
    ret = pthread_create(&thread, NULL, timer, NULL);
    if (ret)
        return 1;

    while (1) {
        printf("> ");

        /* Odczytanie jednej linii - max 80 znaków */
        char line[80];
        if (!fgets(line, sizeof(line), stdin))
            break;

        int seconds;
        if (sscanf(line, "%d", &seconds) == 1) {
            /* Użytkownik podał liczbę sekund */
            time_left = seconds;
            continue;
        }

        char option;
        if (sscanf(line, "%c", &option) == 1 && option == '?') {
            /* Użytkownik podał znak zapytania */
            printf("remaining: %d\n", time_left);
            continue;
        }
    }

    /* Oczekiwanie na zakończenie wątku */
    pthread_join(thread, NULL);

    return 0;
}
```

## Krok 7

Mamy problem. Nigdy nie doczekamy się zakończenia wywołania `pthread_join()`,
ponieważ funkcja wątku będzie bez końca działać w pętli `while (1)`.
Musimy dodać warunek stopu, który ustawimy na `1` przed wywołaniem `pthread_join()`
tak żeby wątek zakończył pracę.

```c
#include <pthread.h> /* pthread_create() i inne */
#include <stdio.h> /* printf() i inne */
#include <unistd.h> /* sleep() */

int time_left;
int stop;

void *timer(void *arg)
{
    while (1) {
        /* Czekamy sekundę */
        sleep(1);

        if (stop)
            break;

        /* Aktualizujemy stan "minutnika" */
        if (time_left > 0) {
            time_left--;
            if (time_left == 0)
                printf("<<ALARM>>\n");
        }
    }

    return NULL;
}

int main(void)
{
    /* Tworzenie wątku */
    pthread_t thread;
    ret = pthread_create(&thread, NULL, timer, NULL);
    if (ret)
        return 1;

    while (1) {
        printf("> ");

        /* Odczytanie jednej linii - max 80 znaków */
        char line[80];
        if (!fgets(line, sizeof(line), stdin))
            break;

        int seconds;
        if (sscanf(line, "%d", &seconds) == 1) {
            /* Użytkownik podał liczbę sekund */
            time_left = seconds;
            continue;
        }

        char option;
        if (sscanf(line, "%c", &option) == 1 && option == '?') {
            /* Użytkownik podał znak zapytania */
            printf("remaining: %d\n", time_left);
            continue;
        }
    }

    /* Informujemy wątek że powinień już kończyć pracę */
    stop = 1;

    /* Oczekiwanie na zakończenie wątku */
    pthread_join(thread, NULL);

    return 0;
}
```

## Krok 8

Mamy jeszcze jeden problem. Wątek "minutnika" może dostać się do współdzielonych
danych `time_left` i `stop` w tym samym momencie co wątek główny.
Potrzebujemy zabezpieczyć dostępy mutexem.

Finalny kod:
```c
#include <pthread.h>
#include <stdio.h>
#include <unistd.h>

int time_left;
int stop;
pthread_mutex_t lock;

void *timer(void *arg)
{
    while (1) {
        /* Czekamy sekundę */
        sleep(1);

        pthread_mutex_lock(&lock);
        int tmp = stop;
        pthread_mutex_unlock(&lock);
        if (tmp)
            break;

        pthread_mutex_lock(&lock);
        /* Aktualizujemy stan "minutnika" */
        if (time_left > 0) {
            time_left--;
            if (time_left == 0)
                printf("<<ALARM>>\n");
        }
        pthread_mutex_unlock(&lock);
    }

    return NULL;
}

int main(void)
{
    int ret = pthread_mutex_init(&lock, NULL);
    if (ret)
        return 1;

    /* Tworzenie wątku */
    pthread_t thread;
    ret = pthread_create(&thread, NULL, timer, NULL);
    if (ret) {
        pthread_mutex_destroy(&lock);
        return 1;
    }

    while (1) {
        printf("> ");

        /* Odczytanie jednej linii - max 80 znaków */
        char line[80];
        if (!fgets(line, sizeof(line), stdin))
            break;

        int seconds;
        if (sscanf(line, "%d", &seconds) == 1) {
            /* Użytkownik podał liczbę sekund */
            pthread_mutex_lock(&lock);
            time_left = seconds;
            pthread_mutex_unlock(&lock);
            continue;
        }

        char option;
        if (sscanf(line, "%c", &option) == 1 && option == '?') {
            /* Użytkownik podał znak zapytania */
            pthread_mutex_lock(&lock);
            printf("remaining: %d\n", time_left);
            pthread_mutex_unlock(&lock);
            continue;
        }
    }
    pthread_mutex_lock(&lock);
    /* Informujemy wątek że powinień już kończyć pracę */
    stop = 1;
    pthread_mutex_unlock(&lock);

    /* Oczekiwanie na zakończenie wątku */
    pthread_join(thread, NULL);

    pthread_mutex_destroy(&lock);

    return 0;
}
```
