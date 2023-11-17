# Lista przypomnień zapisująca stan

Celem zadania jest rozszerzenie (Zadania 2.4 [html](https://czarnota.github.io/wpsl/2/task4), [md](https://github.com/czarnota/wpsl/tree/main/2/task4.md))
o możliwość przechowywania stanu listy przypomnień pomiędzy uruchomieniami programu.

# Przykład działania

Użytkownik może dodać przypomnienie `23:00 pora na sen` - co zapisze przypomnienie na liście
tak, że zasygnalizuje ona wystąpienie go o ustawionej godzinie. Ustawienie powinno przetrwać ponowne
uruchomienie programu.

```
$ ./program
>>> 23:00 pora na sen
>>> 22:00 pora na relaks
>>> list
23:00 pora na sen
22:00 pora na relaks
>>> exit
```

Po ponownym uruchomieniu programu lista przypomnień powinna dalej posiadać ustawione
wpisy.

```
$ ./program
>>> list
23:00 pora na sen
22:00 pora na relaks
```

Gdy wybije ustawiona godzina przypomnienie powinno zostać usunięte z listy.
```
$ ./program
22:00 pora na relaks <--- alarm
>>> list
23:00 pora na sen
>>> exit
```

Po uruchomieniu ponownym programu powinno to zostać odzwierciedlone.

```
$ ./program
>>> list
23:00 pora na sen
```

Jeżeli plik ze stanem listy przypomnień nie istnieje to po uruchomieniu programu lista powinna
być pusta.

# Podpowiedzi

- Można zdefiniować funkcje `save()` i `load()` zapisujące i wczytujące listę
  przypomnien do i z pliku.
- Funkcję `load()` można wywołać na początku programu w celu załadowania listy,
  a funkcję `save()` w momencie zakończenia programu.
- Do wpisywania listy do pliku najłatwiej użyc `fprintf()` a do odczytywania z pliku
  `fgets()` lub `fscanf()`.

# Przydatne funkcje

Można zastosować funkcje dostarczane przez standard języka C:

- `man fopen` - otwiera plik
- `man fclose` - zamyka plik
- `man fwrite` - zapisuje dane do pliku
- `man fread` - odczytuje dane z pliku
- `man fscanf` - odczytuje dane według wzorca
- `man fgets` - odczytuje linijkę z pliku
- `man fprintf` - wpisuje dane do pliku, zgodnie z określonym formatem

# Na co zwrócić uwagę

- Jeżeli plik został otwarty to proszę zadbać o to, żeby w każdym przypadku
  został zamknięty.
