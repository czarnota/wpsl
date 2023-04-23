# Budzik zapisujący stan - rozwiązanie

# Krok 1

Pierwszym krokiem jest rozpoczęcie z kodem z Zadania 2.3 [link](https://czarnota.github.io/wpsl/2/task3-solved)

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

# Krok 2

Kolejnym krokiem jest napisanie funkcji zapisującej czas do pliku:

```c
void save(void)
{
    // Otworz plik o nazwie 'state'
    FILE *f = fopen("state", "w");
    if (!f) {
        fprintf(stderr, "unable to open file for writing\n");
        return;
    }

    // Wpisz do niego minutę i godzinę
    if (fprintf(f, "%d %d", hour, minute) < 0) {
        fprintf(stderr, "unable to save file\n");
        fclose(f);
        return;
    }

    fclose(f);
}
```

# Krok 3

Po napisaniu funkcji do zapisywania danych do pliku, następnym krokiem jest
napisanie funkcji do odczytywania danych z pliku

```c
void load(void)
{
    FILE *f = fopen("state", "r");
    if (!f) {
        hour = -1;
        minute = -1;
        return;
    }

    if (fscanf(f, "%d %d", &hour, &minute) != 2) {
        fprintf(stderr, "unable to parse state file\n");
        hour = -1;
        minute = -1;
        fclose(f);
        return;
    }

    fclose(f);
}
```

# Krok 4

Należy rozszerzyć program o wywołania funkcji `load()` i `save()`.

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

void save(void)
{
    // Otworz plik o nazwie 'state'
    FILE *f = fopen("state", "w");
    if (!f) {
        fprintf(stderr, "unable to open file for writing\n");
        return;
    }

    // Wpisz do niego minutę i godzinę
    if (fprintf(f, "%d %d", hour, minute) < 0) {
        fprintf(stderr, "unable to save file\n");
        fclose(f);
        return;
    }

    fclose(f);
}

void load(void)
{
    FILE *f = fopen("state", "r");
    if (!f) {
        hour = -1;
        minute = -1;
        return;
    }

    if (fscanf(f, "%d %d", &hour, &minute) != 2) {
        fprintf(stderr, "unable to parse state file\n");
        hour = -1;
        minute = -1;
        fclose(f);
        return;
    }

    fclose(f);
}

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
            save();
        }
        pthread_mutex_unlock(&lock);
    }

    return NULL;
}

int main(void)
{
    load();

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
            save();
            pthread_mutex_unlock(&lock);
        }

        if (strcmp("clear\n", line) == 0) {
            /* Wyczyść czas */
            pthread_mutex_lock(&lock);
            minute = -1;
            hour = -1;
            save();
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

    save();

err_destroy_mutex:
    pthread_mutex_destroy(&lock);

    return ret;
}
```

