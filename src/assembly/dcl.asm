SYS_EXIT equ 60
SYS_READ equ 0
SYS_WRITE equ 1
STDIN equ 0
STDOUT equ 1
PERMUTATION_BUFFER_SIZE equ 43
ALPHABET_SIZE equ 42
INPUT_BUFFER_SIZE equ 4096
ROTOR_POSITION_1 equ 27
ROTOR_POSITION_2 equ 33
ROTOR_POSITION_3 equ 35

section .data

%macro checkChar 1                  ;sprawdzamy czy argument jest pomiędzy 1 a Z w ascii
  mov         al, %1
  cmp         al, 49
  jl          _exit1
  cmp         al, 90
  jg          _exit1
%endmacro

section .bss

permL resb ALPHABET_SIZE
permR resb ALPHABET_SIZE
permT resb ALPHABET_SIZE
permLT resb ALPHABET_SIZE
permRT resb ALPHABET_SIZE
  inputBuffer resb INPUT_BUFFER_SIZE
identity resb ALPHABET_SIZE*3
leftKey resb 1
rightKey resb 1

section .text

global _start

_start:
  cmp         QWORD [rsp], 5        ;sprawdzamy czy otrzymaliśmy poprawną liczbę argumentów
  jne         _exit1
  xor         r10d, r10d            ;na r10 trzymamy liczbę wystąpienia znaku '1' w permutacjach
  xor         eax, eax              ;zerujemy rax, gdyż będziemy chcieli kiedyś dodawać wartość w al do większego rejestru

  mov         rdx, QWORD [rsp + 16]
  mov         r8, permL
  mov         r9, permLT
  add         r10d, 10              ;Zwiększenie r10 o 10 sygnalizuje rozpoczęcie sprawdzania następnej permutacji

  call        _checkPermutation     ;Sprawdzam czy pierwszy argument to permutacja dopuszczalnych znaków
  mov         rdx, QWORD [rsp + 24]
  mov         r8, permR
  mov         r9, permRT
  add         r10d, 10              ;Sygnalizujemy sprawdzanie następnej permutacji
  call        _checkPermutation     ;Sprawdzam czy drugi argument to permutacja dopuszczalnych znaków

  mov         rdx, QWORD [rsp + 32]
  mov         r8, permT
  add         r10d, 10              ;Wiemy, że r10 jest już większe niż 30, więc musimy sprawdzić warunek na T
  call        _checkPermutation     ;Sprawdzam czy trzeci to zlożenie 21 cykli dlugości 2

  mov         rdx, QWORD [rsp + 40] ;Sprawdzam czy ostatni argument sklada się z dwóch dopuszczalnych znaków
  cmp         BYTE [rdx +2], 0      ;Sprawdzam czy klucz jest nie dłuższy niż 2 znaki
  jne         _exit1

  cmp         r10d, 33              ;Sprawdzam czy '1' wystąpiło w każdej permutacji dokładnie raz
  jne         _exit1

  xor         r12, r12              ;Zeruję r12 pod przechowywanie klucza
  xor         r13, r13              ;Zeruję r13 pod przechowywanie klucza
  mov         r12b, BYTE [rdx]      ;Zapisuję klucz l fo r12
  mov         r13b, BYTE [rdx + 1]  ;Zapisuję klucz r do r13
  checkChar   r12b
  checkChar   r13b
  sub         r12b, 49              ;Chcę przechowywać przesunięcie a nie znak
  sub         r13b, 49              ;Chcę przechowywać przesunięcie a nie znak

  xor         r14, r14              ;Będzie to rejestr pomocniczy jako 0 przy cmov
  mov         r15, identity         ;Uzupełnimy identity potrojonym alfabetem
  xor         rcx, rcx              ;Zerujemy iterator do fillIdentityLoop

_fillIdentityLoop:
  mov         BYTE [r15 + rcx], cl
  mov         BYTE [r15 + ALPHABET_SIZE + rcx], cl
  mov         BYTE [r15 + 2 * ALPHABET_SIZE + rcx], cl
  inc         ecx
  cmp         ecx, ALPHABET_SIZE
  jne         _fillIdentityLoop

_readInput:
  mov         rax, SYS_READ
  mov         rdi, STDIN
  mov         rsi, inputBuffer
  mov         rdx, INPUT_BUFFER_SIZE
  syscall
  cmp         rax, 0                ;Jeśli nie wczytaliśmy nic, to kończymy
  jl          _exit1
  je          _exit0
  mov         r9, rax               ;r9 będzie przechowywało liczbę ostatnio wczytanych znaków
  xor         rcx, rcx              ;przygotowuję rcx pod licznik iterator po wczytanych znakach

_processInputCharLoop:
  checkChar   BYTE [inputBuffer + rcx]
  inc         r13b
  cmp         r13b, ALPHABET_SIZE   ;Cykliczne przesunięcie Z -> 1 gdy bębenek R osiągnie pozycję 'Z'
  jne         _checkRotorPositions
  xor         r13b, r13b
  jmp         _beginCypher

_checkRotorPositions:
  cmp         r13b, ROTOR_POSITION_1
  je          _incrementingLeft
  cmp         r13b, ROTOR_POSITION_2
  je          _incrementingLeft
  cmp         r13b, ROTOR_POSITION_3
  je          _incrementingLeft
  jmp         _beginCypher

_incrementingLeft:
  inc         r12b
  cmp         r12b, ALPHABET_SIZE   ;Cykliczne przesunięcie Z -> 1 gdy bębenek L osiągnie pozycję 'Z'
  cmove       r12d, r14d

_beginCypher:
  xor         r8, r8                ;W r8 będzie przechowywana aktualna wartość zmienianego znaku
  mov         r8b, BYTE [inputBuffer + rcx]
  sub         r8b, 49

  mov         rax, ALPHABET_SIZE    ;Zaczynamy od środkowej kopii alfabetu
  add         rax, r8               ;Znajdujemy pozycję pierwotną
  add         al, r13b              ;Dokonujemy cyklicznego przesunięcia w prawo o pozycję bębenka R
  mov         r8b, BYTE [r15 + rax] ;Nadpisujemy aktualny znak przesuniętym cyklicznie

  mov         r8b, BYTE [permR + r8];Nakładamy na nasz znak permutację R

  mov         rax, ALPHABET_SIZE
  add         rax, r8
  sub         al, r13b              ;Dokonujemy cyklicznego przesunięcia w lewo o pozycję bębenka R
  mov         r8b, BYTE [r15 + rax]


  mov         rax, ALPHABET_SIZE
  add         rax, r8
  add         al, r12b              ;Dokonujemy cyklicznego przesunięcia w prawo o pozycję bębenka L
  mov         r8b, BYTE [r15 + rax]

  mov         r8b, BYTE [permL + r8]

  mov         rax, ALPHABET_SIZE
  add         rax, r8
  sub         al, r12b              ;Dokonujemy cyklicznego przesunięcia w lewo o pozycję bębenka L
  mov         r8b, BYTE [r15 + rax]

  mov         r8b, BYTE [permT + r8]

  mov         rax, ALPHABET_SIZE
  add         rax, r8
  add         al, r12b
  mov         r8b, BYTE [r15 + rax]

  mov         r8b, BYTE [permLT + r8]

  mov         rax, ALPHABET_SIZE
  add         rax, r8
  sub         al, r12b
  mov         r8b, BYTE [r15 + rax]

  mov         rax, ALPHABET_SIZE
  add         rax, r8
  add         al, r13b
  mov         r8b, BYTE [r15 + rax]

  mov         r8b, BYTE [permRT + r8]

  mov         rax, ALPHABET_SIZE
  add         rax, r8
  sub         al, r13b
  mov         r8b, BYTE [r15 + rax]

  add         r8b, 49
  mov         BYTE [inputBuffer + rcx], r8b

  inc         ecx
  cmp         ecx, r9d
  jne         _processInputCharLoop

  mov         rax, SYS_WRITE
  mov         rdi, STDOUT
  mov         rsi, inputBuffer
  mov         rdx, r9
  syscall
  cmp         rax, 0
  jl          _exit1

  jmp         _readInput

_exit0:
  mov         rax, SYS_EXIT
  mov         rdi, 0
  syscall

_checkPermutation:
  mov         al, BYTE [rdx + ALPHABET_SIZE]
  cmp         al, 0                 ;Sprawdzamy czy argument jest nie dłuższy niż alfabet
  jne         _exit1
  xor         ecx, ecx

_checkCharLoop:
  checkChar   BYTE [rdx + rcx]      ;Sprawdzamy poprawność znaku
  sub         al, 49
  cmp         al, 0                 ;Sprawdzamy, czy obsługiwany znak to '1'
  jne         _notIncrementing      ;Jeśli nie to nie zwiększamy licznika znaków '1' - r10
  inc         r10d

_notIncrementing:
  mov         BYTE [r8 + rcx], al
  cmp         r10d, 30              ;Sprawdzamy, czy obsługujemy permutację T, przed każdą dodawaliśmy 10 do r10
  jg          _checkPermutationT
  cmp         BYTE [r9 + rax], 0    ;Jeżeli juz wystąpił ten znak, to znaczy, że argument nie jest permutacją
  jne         _exit1
  mov         BYTE [r9 + rax], cl
  jmp         _checkAllPermutations

_checkPermutationT:
  add         cl, 49
  cmp         BYTE [rdx + rax], cl  ;Sprawdzamy czy istnieje cykl w permutacji o długości 1 lub 2
  jne         _exit1
  sub         cl, 49
  cmp         cl, al                ;Jeśli cykl był długości 1, zwracamy błąd
  je          _exit1

_checkAllPermutations:
  inc         cl
  mov         al, BYTE [rdx + rcx]  ;Sprawdzamy kolejny znak
  cmp         al, 0                 ;Sprawdzamy, czy to znak końca napisu
  jne         _checkCharLoop        ;Jeśli nie, to sprawdzamy warunki permutacji ponownie
  cmp         cl, ALPHABET_SIZE     ;Jeśli to był ostatni znak, to sprawdzamy czy argument był wielkości alfabetu
  jne         _exit1                ;Jeśli nie to zwracamy błąd
  ret

_exit1:
  mov         rax, SYS_EXIT
  mov         rdi, 1
  syscall