# Budzik - rozwiązanie

## Krok 1

Pierwszym krokiem jest napisanie funkcji main i załączenie odpowiednich nagłówków:

```c
#include <pthread.h>
#include <stdio.h>
#include <unistd.h>
#include <time.h>

int main(void)
{
    return 0;
}
```

## Krok 2 

Napiszmy program który będzie odczytywał jedną linię (max 80 znaków) i 
wyświetlał znak zachęty.

```c
#include <pthread.h>
#include <stdio.h>
#include <unistd.h>
#include <time.h>

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

1. Ustawianie budzika - `set`
2. Sprawdzenie stanu budzika - `get`
3. Wyjście z budzika - `exit`
4. Czyszczenie budzik - `clear`

```c
#include <pthread.h>
#include <stdio.h>
#include <unistd.h>
#include <time.h>
#include <string.h>

int main(void)
{
    while (1) {
        printf("> ");

        /* Odczytanie jednej linii - max 80 znaków */
        char line[80];
        if (!fgets(line, sizeof(line), stdin))
            break;

        int h, m;
        if (sscanf(line, "set %d:%d", &h, &m) == 2) {
            /* Ustaw czas */
        }

        if (strcmp("clear\n", line) == 0) {
            /* Wyczyść czas */
        }

        if (strcmp("get\n", line) == 0) {
            /* Wyświetl ustawiony czas */
        }

        if (strcmp("exit\n", line) == 0) {
            break;
        }
    }
    return 0;
}
```

## Krok 4

Potrzebujemy zmiennych, które będą przechowywać ustawiony czas.
Nazwijmy je `hour` i `minute`. Będą ona zmiennymi globalnymi
tak aby drugi wątek miał do nich łatwy dostęp.

```c
#include <pthread.h>
#include <stdio.h>
#include <unistd.h>
#include <time.h>
#include <string.h>

int minute = -1;
int hour = -1;

int main(void)
{
    while (1) {
        printf("> ");

        /* Odczytanie jednej linii - max 80 znaków */
        char line[80];
        if (!fgets(line, sizeof(line), stdin))
            break;

        int h, m;
        if (sscanf(line, "set %d:%d", &h, &m) == 2) {
            /* Ustaw czas */
            minute = m;
            hour = h;
        }

        if (strcmp("clear\n", line) == 0) {
            /* Wyczyść czas */
            minute = -1;
            hour = -1;
        }

        if (strcmp("get\n", line) == 0) {
            /* Wyświetl ustawiony czas */
            if (minute < 0 || hour < 0)
                printf("alarm is not set\n");
            else 
                printf("%02d:%02d\n", hour, minute);
        }

        if (strcmp("exit\n", line) == 0) {
            break;
        }
    }
    return 0;
}
```

## Krok 5

Mając napisany interfejs użytkownika oraz stan naszego "budzika", potrzebujemy
teraz mechanizmu, który "w tle" będzie sprawdzał czy aktualna godzina jest równa
tej ustawionej i ostatecznie wypisze `"<<ALARM>>"`. Potrzebujemy drugiego wątku.
Zacznijmy od napisania funkcji wątku, która będzie sprawdzać godzinę.

```c
#include <pthread.h>
#include <stdio.h>
#include <unistd.h>
#include <time.h>
#include <string.h>

int minute = -1;
int hour = -1;
int done;

void *alarm_thread(void *arg)
{
    while (1) {
        sleep(1);

        if (done) {
            break;
        }

        struct tm tm;
        time_t t = time(NULL);
        localtime_r(&t, &tm);

        if (minute == tm.tm_min && hour == tm.tm_hour) {
            printf("<<ALARM>>\n");
            minute = -1;
            hour = -1;
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

        int h, m;
        if (sscanf(line, "set %d:%d", &h, &m) == 2) {
            /* Ustaw czas */
            minute = m;
            hour = h;
        }

        if (strcmp("clear\n", line) == 0) {
            /* Wyczyść czas */
            minute = -1;
            hour = -1;
        }

        if (strcmp("get\n", line) == 0) {
            /* Wyświetl ustawiony czas */
            if (minute < 0 || hour < 0)
                printf("alarm is not set\n");
            else 
                printf("%02d:%02d\n", hour, minute);
        }

        if (strcmp("exit\n", line) == 0) {
            break;
        }
    }
    return 0;
}
```

## Krok 6

Nasza funkcja nie wykonuje się jeszcze w tle. Musimy utworzyć wątek, który
będzie ją wykonywał.

```c
#include <pthread.h>
#include <stdio.h>
#include <unistd.h>
#include <time.h>
#include <string.h>

int minute = -1;
int hour = -1;
int done;

void *alarm_thread(void *arg)
{
    while (1) {
        sleep(1);

        if (done) {
            break;
        }

        struct tm tm;
        time_t t = time(NULL);
        localtime_r(&t, &tm);

        if (minute == tm.tm_min && hour == tm.tm_hour) {
            printf("<<ALARM>>\n");
            minute = -1;
            hour = -1;
        }
    }

    return NULL;
}

int main(void)
{
    pthread_t thread;
    
    int ret = pthread_create(&thread, NULL, alarm_thread, NULL);
    if (ret)
        return -1;

    while (1) {
        printf("> ");

        /* Odczytanie jednej linii - max 80 znaków */
        char line[80];
        if (!fgets(line, sizeof(line), stdin))
            break;

        int h, m;
        if (sscanf(line, "set %d:%d", &h, &m) == 2) {
            /* Ustaw czas */
            minute = m;
            hour = h;
        }

        if (strcmp("clear\n", line) == 0) {
            /* Wyczyść czas */
            minute = -1;
            hour = -1;
        }

        if (strcmp("get\n", line) == 0) {
            /* Wyświetl ustawiony czas */
            if (minute < 0 || hour < 0)
                printf("alarm is not set\n");
            else 
                printf("%02d:%02d\n", hour, minute);
        }

        if (strcmp("exit\n", line) == 0) {
            break;
        }
    }

    done = 1;

    pthread_join(thread, NULL);

    return 0;
}
```

## Krok 8

Wątek "budzika" może dostać się do współdzielonych
danych `minute` `hour` i `done` w tym samym momencie co wątek główny.
Potrzebujemy zabezpieczyć dostępy mutexem.

Finalny kod:
```c
#include <pthread.h>
#include <stdio.h>
#include <unistd.h>
#include <time.h>
#include <string.h>

int minute = -1;
int hour = -1;
int done;
pthread_mutex_t lock;

void *alarm_thread(void *arg)
{
    while (1) {
        sleep(1);

        pthread_mutex_lock(&lock);
        if (done) {
            pthread_mutex_unlock(&lock);
            break;
        }
        pthread_mutex_unlock(&lock);

        struct tm tm;
        time_t t = time(NULL);
        localtime_r(&t, &tm);

        pthread_mutex_lock(&lock);
        if (minute == tm.tm_min && hour == tm.tm_hour) {
            printf("<<ALARM>>\n");
            minute = -1;
            hour = -1;
        }
        pthread_mutex_unlock(&lock);
    }

    return NULL;
}

int main(void)
{
    pthread_t thread;

    int ret = pthread_mutex_init(&lock, NULL);
    if (ret)
        return ret;
    
    ret = pthread_create(&thread, NULL, alarm_thread, NULL);
    if (ret)
        goto err_destroy_mutex;

    while (1) {
        printf("> ");

        /* Odczytanie jednej linii - max 80 znaków */
        char line[80];
        if (!fgets(line, sizeof(line), stdin))
            break;

        int h, m;
        if (sscanf(line, "set %d:%d", &h, &m) == 2) {
            /* Ustaw czas */
            pthread_mutex_lock(&lock);
            minute = m;
            hour = h;
            pthread_mutex_unlock(&lock);
        }

        if (strcmp("clear\n", line) == 0) {
            /* Wyczyść czas */
            pthread_mutex_lock(&lock);
            minute = -1;
            hour = -1;
            pthread_mutex_unlock(&lock);
        }

        if (strcmp("get\n", line) == 0) {
            /* Wyświetl ustawiony czas */
            pthread_mutex_lock(&lock);
            if (minute < 0 || hour < 0)
                printf("alarm is not set\n");
            else 
                printf("%02d:%02d\n", hour, minute);
            pthread_mutex_unlock(&lock);
        }

        if (strcmp("exit\n", line) == 0) {
            break;
        }
    }

    pthread_mutex_lock(&lock);
    done = 1;
    pthread_mutex_unlock(&lock);

    ret = pthread_join(thread, NULL);
    if (ret)
        fprintf(stderr, "pthread_join() error");

err_destroy_mutex:
    pthread_mutex_destroy(&lock);

    return ret;
}
```






