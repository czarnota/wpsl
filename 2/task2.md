# Sleep sort na wątkach

Celem zadania jest implementacja programu realizującego algorytm
sleep sort przy użyciu wątków pthread i wywołanie systemowego `sleep()`.

Algorytm sleep sort polega na wystartowaniu osobnego zadania dla
każdego sortowanego elementu. Każde wystartowane zadanie następnie
czeka określoną ilość czasu, która jest zależna od klucza po którym
są sortowane elementy.

W naszym przypadku klucz to po prostu wartość sortowanego elementu, a
każdy wystartowany wątek może po prostu czekać tyle sekund ile wynosi
wartość elementu. Np. wątek powinien czekać 2 sekundy jeżeli element jest
równy 2, 10 sekund jeżeli element jest równy 10 i tak dalej.

# Możliwa struktura programu

1. Odczytanie liczb z linii komend (`argc` i `argv`)
2. Uruchomienie wątków, które będą wypisywać liczby po określonej długości czasu
3. Czekanie na zakończenie wątków
4. Zakończenie programu

# Wymagania funkcjonalne

Program powinien sortować rosnąco liczby całkowite nieujemne
(obsługa liczb ujemnych jest opcjonalna)

Przykładowe wywołanie programu:
```
$ ./sleep_sort 6 5 4 2 1 3
1
2
3
4
5
6
```

Wywołanie programu bez argumentów, nie powinno nic robić:
```
$ ./sleep_sort
```

# Przydatne funkcje

W zadaniu przydadzą się następujące funkcje:

- `pthread_create()` - tworzy nowy wątek
- `pthread_join()` - czeka do momentu zakończenia wątku
- `printf()` - wypisuje ciąg znaków na standardowe wyjście (deskryptor 1)
- `sleep()`, `nanosleep()` - czeka zadana liczbę sekund
- `nanosleep()` - czeka zadaną liczbę sekund i nanosekund
- `sscanf()`, `atoi()`, `strtol()`, `strtoul()` - pozwala przekonwertować ciąg znaków na liczbę
- `perror()` - wyświetla wartość zmiennej `errno`, można wykorzystać do raportowania o błędach

# Przekazywanie argumentów do funkcji wątku

Każdemu wątkowi możemy przekazać argument przez wskaźnik:

```c
#include <pthread.h>

void *fn(void *arg)
{
	/* Argument będzie zawierał argv[1] */
	const char *argument = arg;
	int value;
	if (sscanf(argument, "%s", &value) != 1)
		return NULL;

	/* ... */

	return NULL;
}

int main(int argc, char **argv)
{
	pthread_t thread;

	/* Wystartowanie wątku i przekazanie argumentu do funkcji wątku */
	pthread_create(&thread, NULL, fn, argv[1]);

	/* Łączenie wątku */
	pthread_join(thread, NULL);
}
```
