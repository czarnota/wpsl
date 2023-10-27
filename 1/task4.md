# Dashboard tekstowej konsoli do gier

Celem zadania jest implementacja prostej aplikacji pełniącej rolę dashboardu
tekstowej konsoli do gier.

Zadaniem aplikacji będzie wyświetlanie użytkownikowi menu z wyborem gier do
uruchomienia. Po wyborze opcji z menu przez użytkownika zostanie uruchomiona
wskazana przez niego gra.

# Funkcjonalność

Po uruchomieniu aplikacji, wyświetla ona użytkownikowi menu wyboru gier:

```
$ ./dashboard
 _____ _____ ____  __  __ ____   _____  __
|_   _| ____|  _ \|  \/  | __ ) / _ \ \/ /
  | | |  _| | |_) | |\/| |  _ \| | | \  /
  | | | |___|  _ <| |  | | |_) | |_| /  \
  |_| |_____|_| \_\_|  |_|____/ \___/_/\_\

            terminal gaming console

1) nudoku
2) greed
3) moon-buggy
4) ninvaders
5) nsnake

type '0' to exit

SELECT>
```

- Gdy użytkownik wybierze określoną opcję, zostanie uruchomiona wskazana
przez niego gra.
- Po wyjściu z gry użytkownik zostanie przeniesiony z powrotem
do menu głównego. Wpisanie przez użytkownika `0`, powinno zakończyć "dashboard".
- Przed wyświetleniem menu ekran powinien zostać wyczyszczony.

# Wskazówki

## Instalacja gier

Gdy tekstowe, które będa uruchamiane w aplikacji można zainstalować w
następujący sposób:

```console
sudo apt install nudoku greed moon-buggy ninvaders nsnake
```

## Czyszczenie ekranu

Ekran terminala można wyczyścić na kilka sposobów.

Jednym z nich jest wypisanie kodu kontrolnego "Erase in Display"
oraz przeniesienie kursora na pozycję `(0, 0)` używając kodu kontrolnego "Cursor position"
za pomocą funkcji `printf()`. (<https://en.wikipedia.org/wiki/ANSI_escape_code>) 

```c
printf("%c[2J", 0x1b); /* Erase in Display */
printf("%c[0;0H", 0x1b); /* Set cursor position to (0, 0) */
```

Kolejnym sposobem, może być utworzenie procesu potomnego, który wykona program
`clear`.

```c
pid_t pid = fork();
if (pid == 0) {
    execlp("clear", "clear", NULL);
    return 0;
}

while (1) {
    pid_t child = wait(NULL);
    if (child < 0) {
        if (child == ECHILD)
            break;
        perror("wait");
    }
}
```

Zamiast `clear`, można posłużyć się również programem `tput`.

```c
execlp("tput", "tput", "clear", NULL);
```

## Przydatne strony `man`

W zadaniu przydadzą się następujące funkcje:

- `man fork` - tworzenie procesów,
- `man 3 exec` - podmiana kodu obecnego procesu,
- `man 2 wait` - oczekiwanie na zakończenie procesu potomnego,
- `man 3 sleep` - zatrzymanie wykonywania programu na wskazaną liczbę sekund;
- `man clear` - wyczyszczenie ekranu
- `man tput` - narzędzie wypisujące instrukcje sterujące terminala

