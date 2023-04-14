# Budzik zapisujący stan

Celem zadania jest rozszerzenie (Zadania 2.3 [html](https://czarnota.github.io/wpsl/2/task3), [md](https://github.com/czarnota/wpsl/tree/main/2/task3.md))
o możliwość przechowywania stanu ustawionego budzika pomiędzy uruchomieniami programu.

# Przykład działania

Użytkownik może wpisać `set 23:00` - co ustawia budzik chodzący w tle w taki sposób,
że zasygnalizuje on alarm o ustawionej godzinie. Ustawienie powinno przetrwać ponowne
uruchomienie programu.

```
$ ./program
>>> set 23:00
<Ctrl-C>
```

Po ponownym uruchomieniu budzik powinien być dalej ustawiony:

```
$ ./program
>>> get
alarm is set to 23:00
```

Gdy wybije ustawiona godzina program powinien wyłączyć ustawienie budzika
```
$ ./program
<<ALARM>>
>>> get
alarm is not set
<Ctrl-C>
```

Ten fakt, że budzik nie jest ustawiony, również powinien być w tym momencie zapisany.

```
$ ./program
>>> get
alarm is not set
```

# Przydatne funkcję

Można zastosować funkcję dostarczane przez standard języka C:

- `fopen()` - otwiera plik
- `fclose()` - zamyka plik
- `fwrite()` - zapisuje dane do pliku
- `fread()` - odczytuje dane z pliku

W przypadku funkcji dostarczanych przez standard języka C, możemy skorzystać 
z globalnej zmiennej `stdout`, reprezentującej standardowe wyjście.

Alternatywnie można wywoływać wywołania systemowe ustandaryzowane przez
POSIX:

- `open()` - otwiera plik
- `close()` - zamyka plik
- `write()` - zapisuje dane do pliku
- `read()` - odczytuje dane z pliku

Do wypisywanie informacji na standardowy strumień błędów można użyć:

- `fprintf(stderr, ...)` - wpisuje ciąg znaków do pliku będącego standardowym strumieniem błędów

# Uwagi

- Jeżeli plik został otwarty to proszę zadbać o to, żeby w każdym przypadku
  został zamknięty.
