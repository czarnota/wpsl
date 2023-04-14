# Prosta interaktywna powłoka systemowa

## Krok 1

Pierwszym krokiem jest napisanie funkcji `main` i załączenie odpowiednich nagłówków:

```c
#include <unistd.h>
#include <stdio.h>
#include <sys/wait.h>

int main(int argc, char **argv)
{
    return 0;
}
```

## Krok 2

Napiszmy kawałek kodu, który wczyta linię tekstu ze standardowego wejścia:

```c
#include <unistd.h>
#include <stdio.h>
#include <sys/wait.h>

int main(int argc, char **argv)
{
    while (1) {
        char line[128];

        printf(">>> ");

        if (!fgets(line, sizeof(line), stdin))
            break;

        printf("%s", line);
    }

    return 0;
}
```

## Krok 3

Usuńmy znak końca linii.

```c
#include <unistd.h>
#include <stdio.h>
#include <sys/wait.h>
#include <string.h>
#include <stdbool.h>

bool remove_new_line(char *line)
{
        int len = strlen(line);
        if (line[len - 1] == '\n') {
            line[len - 1] = 0;
            return true;
        }
        return false;
}

int main(int argc, char **argv)
{
    while (1) {
        char line[12];

        printf(">>> ");

        if (!fgets(line, sizeof(line), stdin))
            break;

        remove_new_line(line);

        printf("%s", line);
    }

    return 0;
}
```

## Krok 4

Poinformujmy użytkownika, gdy linia jest zbyt długa:

```c
#include <unistd.h>
#include <stdio.h>
#include <sys/wait.h>
#include <string.h>
#include <stdbool.h>

bool remove_new_line(char *line)
{
        int len = strlen(line);
        if (line[len - 1] == '\n') {
            line[len - 1] = 0;
            return true;
        }
        return false;
}

int main(int argc, char **argv)
{
    while (1) {
        char line[12];

        printf(">>> ");

        if (!fgets(line, sizeof(line), stdin))
            return 0;

        bool removed = remove_new_line(line);
        if (!removed) {
            while (1) {
                if (!fgets(line, sizeof(line), stdin))
                    return 0;
                if (remove_new_line(line))
                    break;
            }
            fprintf(stderr, "err: line too long\n");
            continue;
        }

        printf("%s", line);
    }

    return 0;
}
```

## Krok 5

Następnie należy utworzyć proces potomny

```c
#include <unistd.h>
#include <stdio.h>
#include <sys/wait.h>
#include <string.h>
#include <stdbool.h>

bool remove_new_line(char *line)
{
        int len = strlen(line);
        if (line[len - 1] == '\n') {
            line[len - 1] = 0;
            return true;
        }
        return false;
}

int main(int argc, char **argv)
{
    while (1) {
        char line[12];

        printf(">>> ");

        if (!fgets(line, sizeof(line), stdin))
            return 0;

        bool removed = remove_new_line(line);
        if (!removed) {
            while (1) {
                if (!fgets(line, sizeof(line), stdin))
                    return 0;
                if (remove_new_line(line))
                    break;
            }
            fprintf(stderr, "err: line too long\n");
            continue;
        }

        pid_t pid = fork();
        if (pid == -1) {
            fprintf(stderr, "err: fork() failed\n");
            return 1;
        }

        if (pid == 0) {
            // child
            printf("hello world\n");
            return 0;
        }

        int ret = wait(NULL);
        if (ret == -1) {
            fprintf(stderr, "err: wait failed\n");
            return 1;
        }
    }

    return 0;
}
```

## Krok 6

Podmieńmy kod procesu potomnego wybranym poleceniem

```c
#include <unistd.h>
#include <stdio.h>
#include <sys/wait.h>
#include <string.h>
#include <stdbool.h>

bool remove_new_line(char *line)
{
        int len = strlen(line);
        if (line[len - 1] == '\n') {
            line[len - 1] = 0;
            return true;
        }
        return false;
}

int main(int argc, char **argv)
{
    while (1) {
        char line[12];

        printf(">>> ");

        if (!fgets(line, sizeof(line), stdin))
            return 0;

        bool removed = remove_new_line(line);
        if (!removed) {
            while (1) {
                if (!fgets(line, sizeof(line), stdin))
                    return 0;
                if (remove_new_line(line))
                    break;
            }
            fprintf(stderr, "err: line too long\n");
            continue;
        }

        pid_t pid = fork();
        if (pid == -1) {
            fprintf(stderr, "err: fork() failed\n");
            continue;
        }

        if (pid == 0) {
            int ret = execlp(line, line, NULL);
            if (ret) {
                fprintf(stderr, "err: command \"%s\" does not exist\n", line);
                return 1;
            }
            return 1;
        }

        int ret = wait(NULL);
        if (ret == -1) {
            fprintf(stderr, "err: wait failed\n");
            return 1;
        }
    }

    return 0;
}
```

## Krok 7

Ostateczne poprawki - dodanie obsługi `exit` oraz brak wykonowania pustej lini.

```c
#include <unistd.h>
#include <stdio.h>
#include <sys/wait.h>
#include <string.h>
#include <stdbool.h>

bool remove_new_line(char *line)
{
        int len = strlen(line);
        if (line[len - 1] == '\n') {
            line[len - 1] = 0;
            return true;
        }
        return false;
}

int main(int argc, char **argv)
{
    while (1) {
        char line[12];

        printf(">>> ");

        if (!fgets(line, sizeof(line), stdin))
            return 0;

        bool removed = remove_new_line(line);
        if (!removed) {
            while (1) {
                if (!fgets(line, sizeof(line), stdin))
                    return 0;
                if (remove_new_line(line))
                    break;
            }
            fprintf(stderr, "err: line too long\n");
            continue;
        }

        if (strcmp("exit", line) == 0)
            return 1;

        if (strcmp("", line) == 0)
            continue;

        pid_t pid = fork();
        if (pid == -1) {
            fprintf(stderr, "err: fork() failed\n");
            continue;
        }

        if (pid == 0) {
            int ret = execlp(line, line, NULL);
            if (ret) {
                fprintf(stderr, "err: command \"%s\" does not exist\n", line);
                return 1;
            }
            return 1;
        }

        int ret = wait(NULL);
        if (ret == -1) {
            fprintf(stderr, "err: wait failed\n");
            return 1;
        }
    }

    return 0;
}
```

Kompilacja i wywołanie:
```
$ gcc main.c -o shell
$ ./shell
>>> ls
assets  README.md  slides.html  task1.md  task1-solved.md  task2.md  task2-solved.md
>>> ps
    PID TTY          TIME CMD
 726708 pts/3    00:00:00 bash
 726722 pts/3    00:00:00 gctpmYP
 726724 pts/3    00:00:00 ps
2498788 pts/3    00:00:04 bash
>>> exit
1 main% •• p | crun -
>>> ls
assets  README.md  slides.html  task1.md  task1-solved.md  task2.md  task2-solved.md
>>> df
System plików      1K-bl     użyte dostępne %uż. zamont. na
tmpfs            1626552      2268  1624284   1% /run
/dev/sda2      479079112 384629564 70040156  85% /
tmpfs            8132740    105232  8027508   2% /dev/shm
tmpfs               5120         4     5116   1% /run/lock
/dev/sda1         523244      5364   517880   2% /boot/efi
tmpfs            1626548       152  1626396   1% /run/user/1000
>>> ps
    PID TTY          TIME CMD
 726743 pts/3    00:00:00 bash
 726757 pts/3    00:00:00 5U5Ta57
 726781 pts/3    00:00:00 ps
2498788 pts/3    00:00:04 bash
>>>
>>>
>>> ls
assets  README.md  slides.html  task1.md  task1-solved.md  task2.md  task2-solved.md
>>> exit
```

