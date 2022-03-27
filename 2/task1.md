# Minutnik

Celem zadania jest implementacja interaktywnego minutnika, który będzie pozwalał
na:

1. Ustawienia czasu do wystąpienia alarmu
2. Wyświetlenie pozostałego czasu do wystąpienia alarmu

# Przykład działania

Jeżeli uruchomimy program powinien on wyświetlić znak zachęty `>`

```
$ ./program
> 
```

Użytkownik może wpisać liczbę - co ustawia minutnik chodzący w tle w takie sposób,
że zasygnalizuje on alarm po upłynięciu ustawionego czasu.

```
$ ./program
> 10
<<ALARM>>      <---- Po upłynieciu 10 sekund
```

Użytkownik może edytować minutnik w trakcie jego działania. Na przykład:

```
$ ./program
> 30                 # Ustawiamy minutnik na 30 sekund (minutnik zaczyna działać w tle)
> 10                 # Nadpisujemy minutnik ustawiając czas na 10 sekund (minutnik zaczyna działać w tle)
<<ALARM>>            
```

Użytkownik może sprawdzić ile czasu pozostało do wystąpienia alarmu wpisując
znak zapytania `?`.

```
$ ./program
> 30

... # Mija 5 sekund

> ?
remaining: 25

... # Mija 10 sekund

> ?
remaining: 15
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

# Szkielet programu

- Program powinien zawierać 2 wątki
  - Wątek główny z interfejsem użytkownika
  - Wątek minutnika, który będzie odliczał czas i wyświetlał `<<ALARM>>`
  - Wątki mogą się komunikować przez zmienne globalne - proszę o zabezpieczenie
    dostępu do tych zmiennych mutexem.

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

	/* Jeżeli odczytaliśmy liczbę ustawiamy sekundy */
	int seconds;
	if (sscanf(line, "%d", &seconds) == 1) {
		/* Ustaw czas */
		...
		continue;
	}

	/* Jeżeli odczytaliśmy znak zapytania */
	char option;
	if (sscanf(line, "%c", &option) == 1 && option == '?') {
		/* Wyświetl czas */
		...
		continue;
	}
}
```

# Uwagi

- Proszę poczekać na zakończenie wątku minutnika.
- Proszę zabezpieczyć dostęp do współdzielonych danych pomiędzy wątkami mutexem.
