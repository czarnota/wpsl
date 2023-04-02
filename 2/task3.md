# Budzik

Celem zadania jest implementacja interaktywnego budzika, który będzie pozwalał
na:

1. Ustawienia godziny o której ma wystąpić alarm 
2. Wyłączania alarmu

# Przykład działania

Jeżeli uruchomimy program powinien on wyświetlić znak zachęty `>`

```
$ ./program
> 
```

Użytkownik może wpisać `set 23:00` - co ustawia budzik chodzący w tle w taki sposób,
że zasygnalizuje on alarm o ustawionej godzinie.

```
$ ./program
>>> set 23:00
<<ALARM>>      <---- O godzinie 23:00
```

Użytkownik może edytować budzik w trakcie jego działania. Na przykład:

```
$ ./program
> set 23:30                 # Ustawiamy budzik na 23:30
> set 10:00                 # Ustawiamy budzik na 10:00
```

Użytkownik może sprawdzić czy budzik jest ustawiony wpisując `get`

```
$ ./program
> get
alarm is not set
> set 23:30
> get
alarm is set to 23:30
```

# Przydatne funkcje

- `pthread_create()` - tworzy wątek
- `pthread_join()` - czeka na zakończenie wątku
- `fgets(..., ..., stdin)` - odczytuje znaki ze standardowego wejścia
- `sscanf()` - może posłużyc do konwersji ciągu znaków na liczbę
- `pthread_mutex_init()` - tworzy mutex
- `pthread_mutex_destroy()` - usuwa mutex
- `pthread_mutex_lock()` - blokuje mutex
- `pthread_mutex_unlock()` - odblokowywuje mutex
- `time()` - pobiera aktualny czas
- `localtime()`, `localtime_r()` - konwertuje `time_t` do struktury `struct tm`.
- `sleep(n)` - zatrzymuje wątek na `n` sekund

# Szkielet programu

- Program powinien zawierać 2 wątki:
  - Wątek główny z interfejsem użytkownika
  - Wątek budzika, który będzie sprawdzał czas i wyświetlał `<<ALARM>>` jeżeli wystąpi ustawiona godzina
  - Wątki mogą się komunikować przez zmienne globalne - proszę o zabezpieczenie
    dostępu do tych zmiennych mutexem.

## Pętla z interfejsem użytkownika

Oto przykładowa pętla realizująca interfejs użytkownika:

```c
/* Pętla z interfejsem użytkownika, wykonywana w wątku głównym */
while (1) {
	/* Znak zachęty */
	printf("> ");

	/* Odczytywanie linii - maksymalnie wspieramy 80 znaków */
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

	if (strcmp("exit\n", str) == 0) {
		break;
	}
}
```

## Pobieranie aktualnej godziny

Żeby pobrać aktualną godzinę można wykorzystać funkcję `time()` oraz
`localtime_r()`.

```
#include <time.h>

time_t current_time = time(NULL);
struct tm tm;
localtime_r(&current_time, &tm);

int current_hour = tm.tm_hour;
int current_minute = tm.tm_min;
```

# Uwagi

- Proszę poczekać na zakończenie wątku budzika (`pthread_join()`).
- Proszę zabezpieczyć dostęp do współdzielonych danych pomiędzy wątkami mutexem (`pthread_mutex_lock()`, `pthread_mutex_unlock()`).
