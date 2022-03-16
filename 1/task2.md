# Sleep sort

Celem zadania jest implementacja programu realizującego algorytm
sleep sort przy użyciu wywołania systemowego `fork()` i `sleep()`.

Algorytm sleep sort polega na wystartowaniu osobnego zadania dla
każdego sortowanego elementu. Każde wystartowane zadanie następnie
czeka określoną ilość czasu, która jest zależna od klucza po którym
są sortowane elementy.

W naszym przypadku klucz to po prostu wartość sortowanego elementu, a
każdy wystartowany proces może po prostu czekać tyle sekund ile wynosi
wartość elementu. Np. proces powinien czekać 2 sekundy jeżeli element jest
równy 2, 10 sekund jeżeli element jest równy 10 i tak dalej.

# Możliwa struktura programu

1. Odczytanie liczb z linii komend (`argc` i `argv`)
2. Uruchomienie procesów potomnych, które będą wypisywać liczby po określonej długości czasu
3. Czekanie na zakończenie procesów potomnych
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

**Opcjonalnie**: sortowanie liczb ujemnych
```
$ ./sleep_sort 6 5 4 -2 -1 3
-2
-1
3
4
5
6
```

Sortowanie liczb ujemnych może stanowić pewne wyzwanie z racji tego,
że nie potrafimy czekać przez ujemny czas. Problem może zostać rozwiązany
poprzez dodanie pewnego przesunięcia do czasu oczekiwania, tak aby był dodatni.

Proszę zauważyć że nie musimy czekać pełnych sekund, można wykorzystać
funkcję `nanosleep()`, aby czekać mniejsze ilości czasu (opcjonalnie).

# Przydatne funkcje

W zadaniu przydadzą się następujące funkcje:

- `fork()` - klonuje aktualny proces
- `wait()` - czeka do momentu zakończenie procesu potomnego
- `printf()` - wypisuje ciąg znaków na standardowe wyjście (deskryptor 1)
- `sleep()`, `nanosleep()` - czeka zadana liczbę sekund
- `nanosleep()` - czeka zadaną liczbę sekund i nanosekund
- `sscanf()`, `atoi()`, `strtol()`, `strtoul()` - pozwala przekonwertować ciąg znaków na liczbę
- `perror()` - wyświetla wartość zmiennej `errno`, można wykorzystać do raportowania o błędach

# Wymagania jakościowe

- Wszystkie wartości zwracane w funkcjach powinny być sprawdzone pod kątem błędów
i należy na nie odpowiednio zareagować (np. zakończyć program, kontynuować program
z informacją o błędzie).
- Proszę pamiętać o poczekaniu na wszystkie procesy potomne wywołaniem systemowym `wait()`.
- Proszę poinformować użytkownika jeśli jakaś liczba nie jest wspierana (np. ujemna)

# Zagadki

- W jaki sposób można zaimplementować sortowanie imion w kolejności alfabetycznej?
- W jaki sposób można zaimplementować sortowanie w odwrotnej kolejności?
