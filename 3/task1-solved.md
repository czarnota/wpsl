# Kopiowanie plików - rozwiązanie

## Krok 1

Pierwszym krokiem jest napisanie funkcji `main()` i załączenie odpowiednich
nagłówków:

```c
#include <stdio.h>

int main(int argc, char **argv)
{
	return 0;
}
```

## Krok 2

Nasz program do kopiowania plików, wymaga podania dokładnie dwóch argumentów.
Sprawdźmy zatem, czy użytkownik podał dokładnie dwa argumenty.

```c
#include <stdio.h>

int main(int argc, char **argv)
{
	if (argc != 3) {
		fprintf(stderr, "usage: %s SRC DST\n", argv[0]);
		return 1;
	}

	return 0;
}
```

## Krok 3

Następnym krokiem jest otwarcie dwóch plików: źródłowego i docelowego.
Plik źródłowy powinien być otwarty tylko do odczytu, natomiast plik docelowy
powinien być otwarty tylko do zapisu:

```
#include <stdio.h>

int main(int argc, char **argv)
{
	if (argc != 3) {
		fprintf(stderr, "usage: %s SRC DST\n", argv[0]);
		return 1;
	}


	FILE *src = fopen(argv[1], "rb");
	FILE *dst = fopen(argv[2], "wb");

	fclose(dst);
	fclose(src);

	return 0;
}
```

## Krok 4

Plik źródłowy może nie istnieć. Podobnie, mogą wystąpić problemy z otwarciem
pliku docelowego. Dopiszmy więc detekcje takich przypadków. Jeżeli coś poszło
nie tak to `fopen()` zwraca `NULL`.

```c
#include <stdio.h>

int main(int argc, char **argv)
{
	if (argc != 3) {
		fprintf(stderr, "usage: %s SRC DST\n", argv[0]);
		return 1;
	}


	FILE *src = fopen(argv[1], "rb");
	if (!src) {
		fprintf(stderr, "%s: error: can't open '%s'\n", argv[0],
			argv[1]);
		return 1;
	}

	FILE *dst = fopen(argv[2], "wb");
	if (!dst) {
		fprintf(stderr, "%s: error: can't open '%s'\n", argv[0],
			argv[2]);
		fclose(src);
		return 1;
	}

	fclose(dst);
	fclose(src);

	return 0;
}
```

## Krok 5

Mamy już otwarte dwa pliki - źródłowy i docelowy. Co musimy zrobić dalej?
Jeżeli chcemy przekopiować plik źródłówy do docelowego to warto by zacząć
właśnie od odczytywania danych z pliku źródłowego.

Napiszmy więc pętle która będzie odczytywać dane z pliku tak długo jak
jeszcze są jakiekolwiek dane do odczytania.

```c
#include <stdio.h>

int main(int argc, char **argv)
{
	if (argc != 3) {
		fprintf(stderr, "usage: %s SRC DST\n", argv[0]);
		return 1;
	}


	FILE *src = fopen(argv[1], "rb");
	if (!src) {
		fprintf(stderr, "%s: error: can't open '%s'\n", argv[0],
			argv[1]);
		return 1;
	}

	FILE *dst = fopen(argv[2], "wb");
	if (!dst) {
		fprintf(stderr, "%s: error: can't open '%s'\n", argv[0],
			argv[2]);
		fclose(src);
		return 1;
	}

	while (1) {
		char buffer[128];

		size_t count = fread(buffer, 1, sizeof(buffer), src);
		if (count == 0)
			break;
	}

	fclose(dst);
	fclose(src);

	return 0;
}
```

## Krok 6

Skoro odczytujemy dane z pliku źródłowego, to pozostało umieścić je w pliku
docelowym. Dodajmy zatem do naszej pętli kawałek kodu, który odczytany fragment
pliku natychmiast umieści w pliku docelowym.

```c
#include <stdio.h>

int main(int argc, char **argv)
{
	if (argc != 3) {
		fprintf(stderr, "usage: %s SRC DST\n", argv[0]);
		return 1;
	}


	FILE *src = fopen(argv[1], "rb");
	if (!src) {
		fprintf(stderr, "%s: error: can't open '%s'\n", argv[0],
			argv[1]);
		return 1;
	}

	FILE *dst = fopen(argv[2], "wb");
	if (!dst) {
		fprintf(stderr, "%s: error: can't open '%s'\n", argv[0],
			argv[2]);
		fclose(src);
		return 1;
	}

	while (1) {
		char buffer[128];

		size_t count = fread(buffer, 1, sizeof(buffer), src);
		if (count == 0)
			break;

		fwrite(buffer, 1, count, dst);
	}

	fclose(dst);
	fclose(src);

	return 0;
}
```

## Krok 7

Wszystko działa doskonale - brakuje tylko obsługi błędów dla `fwrite()`.
Nie zawsze dane uda się zapisać pomyślnie. Jest to rzadki przypadek, ale
warto byłoby poinformować o nim użytkownika naszej aplikacji.

Finalny program do kopiowania wygląda w następujący sposób:
```c
#include <stdio.h>

int main(int argc, char **argv)
{
	if (argc != 3) {
		fprintf(stderr, "usage: %s SRC DST\n", argv[0]);
		return 1;
	}


	FILE *src = fopen(argv[1], "rb");
	if (!src) {
		fprintf(stderr, "%s: error: can't open '%s'\n", argv[0],
			argv[1]);
		return 1;
	}

	FILE *dst = fopen(argv[2], "wb");
	if (!dst) {
		fprintf(stderr, "%s: error: can't open '%s'\n", argv[0],
			argv[2]);
		fclose(src);
		return 1;
	}

	while (1) {
		char buffer[128];

		size_t count = fread(buffer, 1, sizeof(buffer), src);
		if (count == 0)
			break;

		size_t written = fwrite(buffer, 1, count, dst);
		if (written != count) {
			fprintf(stderr, "%s: error: can't write to '%s'\n",
				argv[0], argv[2]);
			fclose(dst);
			fclose(src);
			return 1;
		}
	}

	fclose(dst);
	fclose(src);

	return 0;
}
```

## Weryfikacja

Zbudujmy nasz znakomity program i sprawdźmy czy działa.

Kompilacja:

```c
$ gcc copy.c -o copy
```

Najlepszym testem będzie skopiowanie samego siebie:

```c
$ ./copy copy copy_clone
$ ./copy_clone
$ chmod u+x copy_clone
usage: ./copy_clone SRC DST
```

Jak widzimy skopiowany program działa. Jak sprawdzić czy na pewno
plik jest identyczny? Można obliczyć sumę kontrolną:
```
$ md5 copy
MD5 (copy) = 0612fd76a38846115372560ed1db0644
$ md5 copy_clone
MD5 (copy_clone) = 0612fd76a38846115372560ed1db0644
```

Sumy kontrolne sie zgadzają. Odnieśliśmy sukces.

Gratulacje 🤝
