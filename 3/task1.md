# Kopiowanie plików

Celem zadania jest implementacja własnej wersji programu `cp`.
Program powinien umożliwiać skopiowanie pliku z jednej lokalizacji do
drugiej lokalizacji.

# Przykład działania

Kopiowanie pliku o nazwie `readme.txt` do `czytaj.txt`:

```bash
$ ./copy readme.txt czytaj.txt
```

Jeżeli uruchomimy program bez argumentów, z jednym argumentem lub więcej
niż dwoma argumentami to powinien on wypisać na standardowy
strumień błędów informację o tym jak się go używa.

```bash
$ ./copy
usage: copy SRC DST
$ ./copy plik1.txt
usage: copy SRC DST
$ ./copy plik1.txt plik3 abc
usage: copy SRC DST
```

Jeżeli plik źródłowy nie istnieje powinien wyświetlić się błąd
```
$ ./copy hello world
copy: err: file 'hello' does not exist
```

Przykładowy kompletny test działania programu:
```bash
$ rm x y
$ echo hello world > x
$ ./copy x y
$ cat y
hello world
```

Jeżeli plik docelowy już istnieje to powinien zostać nadpisany:
```bash
$ echo tekst1 > plik1
$ echo tekst2 > plik2
$ ./copy plik1 plik2
$ cat plik2
tekst1
```

# Możliwa struktura programu

1. Walidacja liczby argumentów
2. Otwarcie pliku źródłowego do odczytu - jak nie istnieje to wypisanie błędu
3. Otwarcie pliku docelowego do zapisu
4. W pętli: odczytywanie kawałka danych z jednego pliku do bufora (tablicy) i zapisywanie do drugiego pliku
5. Zamknięcie obu plików

# Przydatne funkcję

Można zastosować funkcję dostarczane przez standard języka C:

- `fopen()` - otwiera plik
- `fclose()` - zamyka plik
- `fwrite()` - zapisuje dane do pliku
- `fread()` - odczytuje dane z pliku

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
