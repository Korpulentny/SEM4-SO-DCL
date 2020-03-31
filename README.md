# SEM4-SO-DCL
Zdanie zaliczeniowe nr 1. z SO

# Treść
## DCL

Napisać w asemblerze program symulujący działanie maszyny szyfrującej <b>DCL</b>. <b>Maszyna DCL</b> działa na zbiorze dopuszczalnych znaków zawierającym: <b>duże litery alfabetu angielskiego, cyfry 1 do 9, dwukropek, średnik, pytajnik, znak równości, znak mniejszości, znak większości, małpę</b>. Jedynie znaki z tego zbioru mogą się pojawić w poprawnych parametrach programu oraz w poprawnym wejściu i wyjściu programu.

Maszyna składa się z trzech bębenków szyfrujących: <b>lewego L, prawego R i odwracającego T</b>. Bębenki <b>L</b> i <b>R</b> mogą się obracać i każdy z nich może znajdować się w jednej z <b>42</b> pozycji oznaczanych znakami z dopuszczalnego zbioru. Maszyna zamienia tekst wejściowy na wyjściowy, wykonując dla każdego znaku ciąg permutacji. Jeśli bębenek <b>L</b> jest w pozycji <b>l</b>, a bębenek <b>R</b> w pozycji <b>r</b>, to maszyna wykonuje permutację

<b>Qr-1R-1Qr Ql-1L-1Ql T Ql-1LQl Qr-1RQr</b>

gdzie <b>L, R i T</b> są permutacjami bębenków zadanymi przez parametry programu. Procesy szyfrowania i deszyfrowania są ze sobą zamienne.

Permutacje <b>Q</b> dokonują <b>cyklicznego przesunięcia znaków zgodnie z ich kodami ASCII</b>. Przykładowo <b>Q5</b> zamienia <b>1 na 5, 2 na 6, 9 na =, = na A, A na E, B na F, Z na 4</b>, a <b>Q=</b> zamienia <b>1 na =, 2 na >, ? na K</b>. Permutacja <b>Q1 jest identycznością</b>. Permutacja <b>T jest złożeniem 21 rozłącznych cykli dwuelementowych</b> (złożenie TT jest identycznością). <b>X<sup>-1</sup> oznacza permutację odwrotną do permutacji X. Złożenie permutacji wykonuje się od prawej do lewej</b>.

Przed zaszyfrowaniem każdego znaku bębenek <b>R obraca się o jedną pozycję</b> (cyklicznie zgodnie z kodami ASCII pozycji), czyli jego pozycja zmienia się na przykład <b>z 1 na 2, z ? na @, z A na B, z B na C, z Z na 1</b>. Jeśli bębenek <b>R </b>osiągnie tzw. <b>pozycję obrotową</b>, to również bębenek <b>L obraca się o jedną pozycję. Pozycje obrotowe to L, R, T</b>.

Kluczem szyfrowania jest para znaków oznaczająca początkowe pozycje bębenków L i R.

Program przyjmuje cztery parametry: <b>permutację L, permutację R, permutację T, klucz szyfrowania</b>. Program czyta szyfrowany lub deszyfrowany tekst ze standardowego wejścia, a wynik zapisuje na standardowe wyjście. Po przetworzeniu całego wejścia program kończy się <b>kodem 0</b>. Program powinien sprawdzać poprawność parametrów i danych wejściowych, a po wykryciu błędu powinien natychmiast zakończyć się <b>kodem 1</b>. Czytanie i zapisywanie powinno odbywać się w blokach, a nie znak po znaku.

Oceniane będą poprawność i szybkość działania programu, zajętość pamięci (rozmiary poszczególnych sekcji), styl kodowania. Tradycyjny styl programowania w asemblerze polega na rozpoczynaniu etykiet od pierwszej kolumny, mnemoników od dziewiątej kolumny, a listy argumentów od siedemnastej kolumny. Inny akceptowalny styl prezentowany jest w przykładach pokazywanych na zajęciach. Kod powinien być dobrze skomentowany, co oznacza między innymi, że każda procedura powinna być opatrzona informacją, co robi, jak przekazywane są do niej parametry, jak przekazywany jest jej wynik, jakie rejestry modyfikuje. To samo dotyczy makr. Komentarza wymagają także wszystkie kluczowe lub nietrywialne linie wewnątrz procedur lub makr. W przypadku asemblera nie jest przesadą komentowania prawie każdej linii kodu, ale należy jak ognia unikać komentarzy typu „zwiększenie wartości rejestru rax o 1”.

Dołączone do zadania przykłady składają się z trójek plików. Plik `*.key` zawiera parametry wywołania programu, a pliki `*.a` i `*.b` zawierają parę tekstów odpowiadających sobie przy szyfrowaniu i deszyfrowaniu.

Jako rozwiązanie należy oddać plik `dcl.asm`. Program będzie kompilowany poleceniami:

    nasm -f elf64 -w+all -w+error -o dcl.o dcl.asm
    ld --fatal-warnings -o dcl dcl.o
