# Prosta interaktywna powłoka systemowa

Celem zadania jest implementacja bardzo prostej interaktywnej powłoki systemowej (ang. Shell),
której celem jest uruchamianie procesów. Fundamentem implementacji będą wywołania systemowe
`fork()` i `exec()`

Zakres funkcjonalności:

1. REPL (ang. Read-Eval print loop) - to po prostu interaktywna pętla wykonująca polecenia
2. Uruchamianie dowolnych procesów (bez obsługi uruchamiania procesów w tle)
3. Implementacja komendy `cd` (która akurat nie może zostać zaimplementowana jako proces)

# Wymagania funkcjonalne

Po uruchomieniu powłoka systemowa powinna wyświetlać znak zachęty oraz umożliwiać
uruchamianie procesów

Przykład: wpisanie `ls`, powinno za pomocą wywołania systemowego
`fork()` utworzyć proces potomny i wykonać program `ls` za pomocą `execvp()`
```
$ ./shell
> ls
foo bar baz
```

Próba uruchomienia nie istniejącego programu powinna wyświetlić komunikat o
błędzie
```
> dss
shell: 'dss': No such file or directory
```

Wpisanie `exit` powinno zakończyć powłokę
```
> exit
$
```

Wpisanie pustej linii powinno nic nie robić
```
>
>
>
>
```

Powinna być możliwe przekazanie argumentów
```
> echo x y z
x y z
```

# Przetwarzanie argumentów

Aby przekazać argumenty do procesu potomnego, należy podzielić
odczytaną linie na części. Każda z części jest odseparowana białymi znakami

W tym celu można użyc następującej funkcji, którą nadpisze spacje zerami oraz
zapisze wskaźniki do początków "słów" w tablicy wskaźników `argv`:
```
int parse_line(char *line, char **argv, unsigned int max_args)
{
	int argc = 0;
	int len = strlen(line);
	for (unsigned int i = 0; i < len; ++i) {
		if (line[i] == ' ')
			line[i] = 0;

		if ((i == 0 || line[i - 1] == 0) && line[i] != 0) {
			if (argc < max_args) {
				argv[argc] = &line[i];
				argc++;
			}
		}
	}

	return argc;
}
```

Przykład użycia funkcji:

```
/* Odczytujemy linie ze standardowego wejścia */
char *line = readline("$ ");

/* Wspieramy max 11 argumentów, ostatni musi być NULLem na potrzeby execvp() */
char *my_argv[12] = { 0 };
int my_argc = parse_line(line, my_argv, 11);

/* Wynik parsowanie można przekazać do execvp */
int ret = execvp(my_argv[0], my_argv);
```

Alternatywą do powyższej funkcji może być `strtok()`, `strtok_r()` lub
`strsep()`

# Pseudokod

Działanie programu ilustruje poniższy pseudokod

```
while true:
	linia = readline()

	my_argv[12] = {0};
	liczba_arg = parse_line(line, my_argv, 12)

	if liczba_arg == 0
		continue

	if my_argv[0] == "exit":
		break

	if my_argv[0] == "cd":
		if liczba_arg != 2:
			continue
		chdir(my_argv[1])
		continue

	pid = fork()
	if pid == 0:
		ret = execvp(my_argv[0], my_argv)
		if ret:
			wypisz blad
			return errno

	wait(NULL);
```

# Przydatne funkcje

W zadaniu przydadzą się następujące funkcje:

- `fork()` - tworzenie procesu potomnego
- `execvp()` - podmiana kodu wykonującego sie procesu
- `strerror()` - zamiana kodu błędu komunikat o błędzie
- `readline()` - odczytanie linii ze standardowego wejścia
- `wait()` - czekanie na zakończenie procesu potomnego
- `chdir()` - zmiana katalogu roboczego
- `strcmp()` - porównanie ciągów znaków
- `strlen()` - zwraca długość ciągu znaków


# Zagadki

- Jak zaimplementować uruchamianie procesów w tle? (odpowiednik operatora `&` w Bash'u)
- Skąd procesy potomne wiedzą, gdzie wypisywać wyjście? 
