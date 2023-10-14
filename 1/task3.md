# Program uruchamiajacy procesy w pętli

Celem zadania jest implementacja programu, którego głównym zadaniem będzie
ponowne uruchamianie procesów wykonujących wskazany program.

Użytkownik musi mieć możliwość wskazania jaki program będzie uruchamiany w pętli,
poprzez przekazanie jego nazwy jako pierwszy argument do implementowanego
w tym zadaniu programu.

# Funkcjonalność

W przykładach `runner` to nazwa tworzonego w tym zadaniu programu.

## Zwracanie kodu błędu w przypadku niepoprawnego wywołania programu

Jeżeli użytkownik uruchomi program bez argumentów, to powinien on natychmiast się
zakończyć z kodem błędu o wartości `1` oraz wypisując komunikat o błędzie.
Kod błędu można zobaczyć po uruchomieniu wpisując `echo $?`.

```console
$ ./runner
runner: error: nothing to run
$ echo $?
1
```

## Uruchamianie wzkazanego programu w pętli

Jeżeli użytkownik uruchomi program `./runner` z jednym argumentem,
będącym nazwą innego programu, to program `./runner` musi zacząć uruchamiać go
w pętli stosując sekundę przerwy.

Przykład działania dla argumentu wskazującego program `date`:

```console
$ ./runner date
pon  2 paź 21:30:10 2023 CEST
pon  2 paź 21:30:11 2023 CEST
pon  2 paź 21:30:12 2023 CEST
pon  2 paź 21:30:13 2023 CEST
pon  2 paź 21:30:14 2023 CEST
pon  2 paź 21:30:15 2023 CEST
^C
```

Przykład działania dla argumentu wskazującego program `who`:

```console
$ ./runner who
czarnota         console      13 kwi 21:33
czarnota         ttys000       7 wrz 00:40
czarnota         console      13 kwi 21:33
czarnota         ttys000       7 wrz 00:40
czarnota         console      13 kwi 21:33
czarnota         ttys000       7 wrz 00:40
czarnota         console      13 kwi 21:33
czarnota         ttys000       7 wrz 00:40
^C
```

## Przekazywanie argumentów do wskazanego programu

Użytkownik powinien mieć możliwość przekazywania argumentów do
uruchamianego co sekundę programu. Na przykład:

Kompilowanie kodu co sekundę:
```console
$ ./runner gcc main.c -o out
```

Tworzenie archiwum o nazwie `code.zip` zawierające plik źródłowy `main.c`
co sekundę:

```
$ ./runner zip code.zip main.c
```

Dopuszczalne jest wsparcie ograniczonej liczby argumentów.
W takim przypadku, program powinien wyświetlić błąd gdy liczba
podanych argumentów jest zbyt duża.

Na przykład, jeżeli zostało zaimplementowane wsparcie tylko dla 5 argumentów to
program powinien wyświetlić komunikat o błędzie i zwrócić kod błędu:

```
$ ./runner echo a b c d e f g h i j k
runner: error: too many arguments
$ echo $?
1
```

# Wskazówki

## Odczytywanie argumentów przekazanych do programu

W celu odczytania argumentów przekazanych do programu należy zdefiniować funkcję `main()` w następujący sposób:

```c
int main(int argc, char **argv)
{
    /* ... */
}
```

Zmienna `argc` zawiera liczbę argumentów z którymi został uruchomiony proces, natomiast
`argv` to tablica ciągów znaków będącymi argumentami do programu. Należy pamiętać,
że `argv[0]` oznacza zawsze nazwę programu, natomiast pierwszy argument przekazany
do programu będzie dostępny pod `argv[1]`. Na przykład, jeżeli uruchomimy program
`./foo` z argumentami `bar` oraz `baz`, to wtedy:

```c
int main(int argc, char **argv)
{
    printf("%d\n", argc);
    printf("%s\n", argv[0]);
    printf("%s\n", argv[1]);
    printf("%s\n", argv[2]);
    return 0;
}
```

```console
$ ./foo bar baz
3
./foo
baz
baz
```

## Przydatne strony `man`

W zadaniu przydadzą się następujące funkcje:

- `man fork` - tworzenie procesów,
- `man 3 exec` - podmiana kodu obecnego procesu,
- `man 2 wait` - oczekiwanie na zakończenie procesu potomnego,
- `man 3 sleep` - zatrzymanie wykonywania programu na wskazaną liczbę sekund;

