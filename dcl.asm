SYS_EXIT equ 60
SYS_READ equ 0
SYS_WRITE equ 1
STDIN equ 0
STDOUT equ 1
PERMUTATION_BUFFER_SIZE equ 43
ALPHABET_SIZE equ 42
INPUT_BUFFER_SIZE equ 4096

section .data

%macro checkChar 1                     ;sprawdzamy czy argument jest pomiędzy 1 a Z w ascii
  mov al, %1
  cmp al, 49
  jl _exit1
  cmp al, 90
  jg _exit1
%endmacro


%macro exit 1
  mov rax, SYS_EXIT
  mov rdi, %1
  syscall
%endmacro

section .bss

  permL resb ALPHABET_SIZE
  permR resb ALPHABET_SIZE
  permT resb ALPHABET_SIZE
  permLT resb ALPHABET_SIZE
  permRT resb ALPHABET_SIZE
  inputBuffer resb INPUT_BUFFER_SIZE

section .text




  global _start

_start:
  cmp QWORD [rsp], 5                  ;sprawdzamy czy otrzymaliśmy poprawną liczbę argumentów
  jne _exit1
  xor r10, r10                        ;na r10 trzymamy wystąpienia znaku '1' w permutacjach
  xor rax, rax                        ;zerujemy rax, gdyż będziemy chcieli kiedyś dodawać wartość w al do większego rejestru

  mov rdx, QWORD [rsp + 16]
  mov r8, permL
  mov r9, permLT
  add r10, 10
  call _checkPermutation              ;Sprawdzam czy pierwszy argument to permutacja dopszuczalnych znaków
  mov rdx, QWORD [rsp + 24]
  mov r8, permR
  mov r9, permRT
  add r10, 10
  call _checkPermutation              ;Sprawdzam czy drugi argument to permutacja dopszuczalnych znaków
  mov rdx, QWORD [rsp + 32]
  mov r8, permT
  add r10, 10
  call _checkPermutation              ;Sprawdzam czy trzeci to zlozenie 21 cykli dlugosci 2

  mov rdx, QWORD [rsp + 40]            ;sprawdzamy czy ostatni argument sklada się z dwóch dopuszczalnych znaków
  mov al, BYTE [rdx + 2]
  cmp al, 0
  jne _exit1
  cmp r10, 33                           ;sprawdzamy czy '1' wystąpiło w każdej permutacji dokładnie raz
  jne _exit1
  checkChar BYTE [rdx]
  checkChar BYTE [rdx+1]

;  1.Wczytuje na bufor i sprawdzam czy rax!=0 bo jak nie jest różny to exit
;  2.Mam jakis counter ktory zwiekszam z każdą literką
;  3.Wczytuje literkę, sprawdzam czy jest z dopuszczalnego przedzialu, bo jak nie to elo nara exit
;  4.Jak jest z dopuszczalnego przedzialu to super pusczam na niej szyfrowanie, zaszfrowaną literką nadpisuje pierwotną w buforze
;  5.inkrementuje counter, sprawdzam czy przeorałem już tyle literek co wczytałem bajtów, jesli nie to ide do 3.
;  6.jesli przeorałem już wszystkie literki to wypisuje bufor i moge cofnąć się do punktu 1.



_readInput:
  mov rax, SYS_READ
  mov rdi, STDIN
  mov rsi, inputBuffer
  mov rdx, INPUT_BUFFER_SIZE
  syscall
  cmp rax, 0                           ;jeśli nie wczytaliśmy nic, to kończymy
  je _exit0
  mov r10, rax                         ;r10 będzie przechowywało liczbę ostatnio wczytanych znaków
  dec r10
  xor rcx, rcx                         ;przygotowuję rcx pod licznik wczytanych znaków
_processInputCharLoop:
  checkChar BYTE [inputBuffer + rcx]
  ;tutaj wleci szyfrowanko pyk pyk bedzie super, nie wiem jak to zrobic
  inc rcx
  cmp rcx, r10
  jne _processInputCharLoop
  mov rax, SYS_WRITE
  mov rdi, STDOUT
  mov rsi, inputBuffer
  mov rdx, r10
  syscall

  jmp _readInput













_exit0:
  mov rax, SYS_EXIT
  mov rdi, 0
  syscall

_checkPermutation:
  mov al, BYTE [rdx + ALPHABET_SIZE]
  cmp al, 0
  jne _exit1

  xor rcx, rcx

_checkCharLoop:
  checkChar BYTE [rdx + rcx]
  mov al, BYTE [rdx + rcx]
  sub al, 49
  cmp al, 0
  jne _notIncrementing
  inc r10

_notIncrementing:
  mov BYTE [r8 + rcx], al
  cmp r10, 30                           ;poprawic na nie magic number
  jg _checkPermutationT
  cmp BYTE [r9 + rax], 0               ;jesli juz wystąpił ten znak, to znaczy, że to ciąg nie jest permutacją
  jne _exit1
  mov BYTE [r9 + rax], cl
  jmp _checkAllPermutations

_checkPermutationT:
  add cl, 49;
  cmp BYTE [rdx + rax], cl
  jne _exit1
  sub cl, 49
  cmp cl, al
  je _exit1

_checkAllPermutations:
  inc cl
  mov al, BYTE [rdx + rcx]
  cmp al, 0

  jne _checkCharLoop
  cmp cl, ALPHABET_SIZE
  jne _exit1
  ret




_exit1:
  mov rax, SYS_EXIT
  mov rdi, 1
  syscall

_exit2:
  xor rcx, rcx
  mov cl, BYTE [rdx + rax]
;  mov rcx, rax
  exit rcx

_exit3:
  mov rax, SYS_EXIT
  mov rdi, 3
  syscall


