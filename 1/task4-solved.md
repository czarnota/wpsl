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

Napiszmy kawałek kodu, który wczyta wybór opcji od użytkownika:

```c
#include <unistd.h>
#include <stdio.h>
#include <sys/wait.h>

int main(int argc, char **argv)
{
    while (1) {
		int option;
		int ret = scanf("%d", &option);
		if (ret != 1) {
			if (scanf("%*s") != 0)
				return -1;
			continue;
		}

		if (option == 0)
			break;

		if (option <= 0 || 5 < option)
			continue;
    }

    return 0;
}
```

## Krok 3

Następnie w zależności od wybranej opcji niech uruchamiana będzie konktretna gra

```c
#include <unistd.h>
#include <stdio.h>
#include <sys/wait.h>

int main(int argc, char **argv)
{
    while (1) {
		int option;
		int ret = scanf("%d", &option);
		if (ret != 1) {
			if (scanf("%*s") != 0)
				return -1;
			continue;
		}

		if (option == 0)
			break;

		if (option <= 0 || 5 < option)
			continue;

		pid_t pid = fork();
		if (pid == 0) {
			if (option == 1)
				return execlp("nudoku", "nudoku", NULL);
			if (option == 2)
				return execlp("greed", "greed", NULL);
			if (option == 3)
				return execlp("moon-buggy", "moon-buggy", NULL);
			if (option == 4)
				return execlp("ninvaders", "ninvaders", NULL);
			if (option == 5)
				return execlp("nsnake", "nsnake", NULL);
			return -1;
		}

		pid = wait(NULL);
		if (pid < 0)
			return -1;
    }

    return 0;
}
```

## Krok 4

Czyszczenie ekranu i wypisywanie banera:

```c
#include <stdio.h>
#include <unistd.h>
#include <sys/wait.h>

int main(int argc, char **argv)
{
	while (1) {
		printf("%c[2J", 0x1b);
		printf("%c[0;0H", 0x1b);
		printf(" _____ _____ ____  __  __ ____   _____  __\n");
		printf("|_   _| ____|  _ \\|  \\/  | __ ) / _ \\ \\/ /\n");
		printf("  | | |  _| | |_) | |\\/| |  _ \\| | | \\  / \n");
		printf("  | | | |___|  _ <| |  | | |_) | |_| /  \\ \n");
		printf("  |_| |_____|_| \\_\\_|  |_|____/ \\___/_/\\_\\\n");
		printf("                                          \n");
		printf("            terminal gaming console       \n");
		printf("                                          \n");
		printf("1) nudoku\n");
		printf("2) greed\n");
		printf("3) moon-buggy\n");
		printf("4) ninvaders\n");
		printf("5) nsnake\n");
		printf("\n");
		printf("type '0' to exit");
		printf("\n");
		printf("SELECT> ");

		int option;
		int ret = scanf("%d", &option);
		if (ret != 1) {
			if (scanf("%*s") != 0)
				return -1;
			continue;
		}

		if (option == 0)
			break;

		if (option <= 0 || 5 < option)
			continue;

		pid_t pid = fork();
		if (pid == 0) {
			if (option == 1)
				return execlp("nudoku", "nudoku", NULL);
			if (option == 2)
				return execlp("greed", "greed", NULL);
			if (option == 3)
				return execlp("moon-buggy", "moon-buggy", NULL);
			if (option == 4)
				return execlp("ninvaders", "ninvaders", NULL);
			if (option == 5)
				return execlp("nsnake", "nsnake", NULL);
			return -1;
		}

		pid = wait(NULL);
		if (pid < 0)
			return -1;
	}

	return 0;
}
```

Kompilacja i wywołanie:
```
$ gcc main.c -o dashboard
$ ./dashboard
```
