# Prosta interaktywna powłoka systemowa

Celem zadania jest implementacja bardzo prostej interaktywnej powłoki systemowej (ang. Shell),
której celem jest uruchamianie procesów, wykorzystującej wywołania systemowe
`fork()` i `exec()`

Zakres funkcjonalności:

1. Interaktywna pętla wykonująca polecenia
2. Uruchamianie dowolnych procesów (bez obsługi uruchamiania procesów w tle)

# Przykład działania

Po uruchomieniu powłoka systemowa powinna wyświetlać znak zachęty oraz umożliwiać
uruchamianie procesów.

Przykład: wpisanie `ls`, powinno za pomocą wywołania systemowego
`fork()` utworzyć proces potomny i wykonać program `ls` za pomocą `execvp()`:
```
$ ./shell
> ls
Desktop Documents Downloads Pictures Public
```

Próba uruchomienia nie istniejącego programu powinna wyświetlić komunikat o
błędzie:
```
> dss
shell: 'dss': No such file or directory
```

Wpisanie `exit` powinno zakończyć powłokę:
```
> exit
$
```

Wpisanie pustej linii powinno nic nie robić:
```
>
>
>
>
```

# Przydatne funkcje

W zadaniu przydadzą się następujące funkcje:

- `fork()` - tworzenie procesu potomnego
- `execvp()` - podmiana kodu wykonującego sie procesu
- `strerror()` - zamiana kodu błędu komunikat o błędzie
- `fgets()` lub `scanf()` - odczytanie linii ze standardowego wejścia
- `wait()` - czekanie na zakończenie procesu potomnego
- `strcmp()` - porównanie ciągów znaków
- `strlen()` - zwraca długość ciągu znaków
