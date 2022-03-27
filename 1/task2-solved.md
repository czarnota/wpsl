# Sleep sort - rozwiązanie

## Krok 1

Pierwszym krokiem jest napisanie funkcji `main` i załączenie odpowiednich nagłówków:

```c
#include <unistd.h> /* potrzebne do fork() */
#include <stdio.h> /* potrzebne do printf() */
#include <sys/wait.h> /* potrzebne do wait() */

int main(int argc, char **argv)
{
	return 0;
}
```

## Krok 2

Napiszmy kawałek kodu, który sprawdzi czy każdy argument jest liczbą nieujemną. Możemy
do tego wykorzystać funkcję `sscanf()`, która działa identycznie do `scanf()`,
tylko zamiast odczytywać liczby ze standardowego wejscia, odczytuje sie z
ciągu znaków.

```c
#include <unistd.h> /* potrzebne do fork() */
#include <stdio.h> /* potrzebne do printf() */
#include <sys/wait.h> /* potrzebne do wait() */

int main(int argc, char **argv)
{
	for (int i = 1; i < argc; ++i) {
		int number;
		if (1 != sscanf(argv[i], "%d", &number)) {
			fprintf(stderr, "wrong arguments\n");
			return 1;
		}
		if (number < 0) {
			fprintf(stderr, "wrong arguments\n");
			return 1;
		}
	}

	return 0;
}
```

## Krok 3

Ile potrzebujemy procesów potomnych? Tyle ile jest argumentów do programu.
Więc musimy utworzyć tyle procesów potomnych, ile jest argumentów.
Możemy to zrobic za pomocą wywołania systemowego `fork()`.

```c
#include <unistd.h> /* potrzebne do fork() */
#include <stdio.h> /* potrzebne do printf() */
#include <sys/wait.h> /* potrzebne do wait() */

int main(int argc, char **argv)
{
	for (int i = 1; i < argc; ++i) {
		int number;
		if (1 != sscanf(argv[i], "%d", &number)) {
			fprintf(stderr, "wrong arguments\n");
			return 1;
		}
		if (number < 0) {
			fprintf(stderr, "wrong arguments\n");
			return 1;
		}
	}

	for (int i = 1; i < argc; ++i) {
		int pid = fork();
		if (pid == 0) {
			/* Jesteśmy w procesie potomnym */
			return 0;
		}
		/* Jesteśmy w procesie rodzica */
	}

	return 0;
}
```

# Krok 4

Utworzyliśmy `argc - 1` procesów potomnych. Powinniśmy na nie zaczekać, aż się zakończą
w procesie rodzica. Zaczekać możemy za pomocą wywołania systemowego `wait()`.

Ile razy powinniśmy wywołać to wywołanie systemowe? Tyle ile jest procesów
potomnych. Można to zrobić na 2 sposoby:

Sposób 1 - wołamy `wait()` tyle razy ile jest dzieci:
```c
for (int i = 1; i < argc; ++i) {
	int ret = wait(NULL);
	if (ret < 0)
		fprintf(stderr, "error\n");
}
```

Sposób 2 - wołamy `wait()` dopóki nie zwróci ono informacji, że nie ma już dzieci.
```c
while (true) {
	int ret = wait(NULL);
	if (ret < 0) {
		/* Jeżeli wystąpił błąd, że nie ma już dzieci */
		if (errno != ECHILD)
			fprintf(stderr, "error\n");
		break;
	}
}
```

Pełny kod, wraz z oczekiwaniem na dzieci:

```c
#include <unistd.h> /* potrzebne do fork() */
#include <stdio.h> /* potrzebne do printf() */
#include <sys/wait.h> /* potrzebne do wait() */

int main(int argc, char **argv)
{
	for (int i = 1; i < argc; ++i) {
		int number;
		if (1 != sscanf(argv[i], "%d", &number)) {
			fprintf(stderr, "wrong arguments\n");
			return 1;
		}
		if (number < 0) {
			fprintf(stderr, "wrong arguments\n");
			return 1;
		}
	}

	for (int i = 1; i < argc; ++i) {
		int pid = fork();
		if (pid == 0) {
			/* Jesteśmy w procesie potomnym */
			return 0;
		}
		/* Jesteśmy w procesie rodzica */
	}

	for (int i = 1; i < argc; ++i) {
		int ret = wait(NULL);
		if (ret < 0)
			fprintf(stderr, "error\n");
	}

	return 0;
}
```

# Krok 5

Odczytanie w procesie potomnym argumentu.

Poprzednio użyliśmy `sscanf()` tylko do walidacji. Musimy jej jeszcze raz użyć
w celu odczytania liczby w procesie potomnym.

```c
#include <unistd.h> /* potrzebne do fork() */
#include <stdio.h> /* potrzebne do printf() */
#include <sys/wait.h> /* potrzebne do wait() */

int main(int argc, char **argv)
{
	for (int i = 1; i < argc; ++i) {
		int number;
		if (1 != sscanf(argv[i], "%d", &number)) {
			fprintf(stderr, "wrong arguments\n");
			return 1;
		}
		if (number < 0) {
			fprintf(stderr, "wrong arguments\n");
			return 1;
		}
	}

	for (int i = 1; i < argc; ++i) {
		int pid = fork();
		if (pid == 0) {
			int number;
			if (1 != sscanf(argv[i], "%d", &number)) {
				fprintf(stderr, "wrong arguments\n");
				return 1;
			}
			/* Jesteśmy w procesie potomnym */
			return 0;
		}
		/* Jesteśmy w procesie rodzica */
	}

	for (int i = 1; i < argc; ++i) {
		int ret = wait(NULL);
		if (ret < 0)
			fprintf(stderr, "error\n");
	}

	return 0;
}
```

## Krok 6

Finalnym krokiem powinno być zatrzymanie procesu potomnego na tyle czasu
ile wynosi wartość liczby i następnie ją wypisać:

Finalne kod:
```
#include <unistd.h> /* potrzebne do fork() */
#include <stdio.h> /* potrzebne do printf() */
#include <sys/wait.h> /* potrzebne do wait() */

int main(int argc, char **argv)
{
	for (int i = 1; i < argc; ++i) {
		int number;
		if (1 != sscanf(argv[i], "%d", &number)) {
			fprintf(stderr, "wrong arguments\n");
			return 1;
		}
		if (number < 0) {
			fprintf(stderr, "wrong arguments\n");
			return 1;
		}
	}

	for (int i = 1; i < argc; ++i) {
		int pid = fork();
		if (pid == 0) {
			int number;
			if (1 != sscanf(argv[i], "%d", &number)) {
				fprintf(stderr, "wrong arguments\n");
				return 1;
			}
			/* Jesteśmy w procesie potomnym */
			sleep(number);
			printf("%d\n", number);
			return 0;
		}
		/* Jesteśmy w procesie rodzica */
	}

	for (int i = 1; i < argc; ++i) {
		int ret = wait(NULL);
		if (ret < 0)
			fprintf(stderr, "error\n");
	}

	return 0;
}
```

Kompilacja i wywołanie:
```
$ gcc main.c -o sleepsort
$ ./sleepsort 7 5 4 1 0
0
1
4
5
7
```

