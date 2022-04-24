# Wyświetlanie plików

Celem zadania jest implementacja własnej uproszczonej wersji programu `cat`.
Program powinien umożliwiać wypisanie pliku podanego jako pierwszy
argument na standardowe wyjście.

# Przykład działania

Wypisanie pliku o nazwie `plik.txt`:

```bash
$ echo x > plik.txt
$ ./printfile plik.txt
x
```

Jeżeli uruchomimy program bez argumentów, lub więcej
niż z jednym argumentam to powinien on wypisać na standardowy
strumień błędów informację o tym jak się go używa.

```bash
$ ./printfile
usage: printfile FILE
$ ./printfile plik1.txt plik3 abc
usage: printfile FILE
```

Jeżeli plik źródłowy nie istnieje powinien wyświetlić się błąd
```
$ ./prinfile foo
printfile: err: file 'foo' does not exist
```

Przykładowy kompletny test działania programu:
```bash
$ rm x
$ echo hello world > x
$ ./printfile x
hello world
```

# Możliwa struktura programu

1. Walidacja liczby argumentów
2. Otwarcie pliku źródłowego do odczytu - jak nie istnieje to wypisanie błędu
3. W pętli: odczytywanie kawałka danych z jednego pliku do bufora (tablicy) i wypisywanie na deskryptor `1` (standardowe wyjście)
4. Zamknięcie otwartego pliku

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
