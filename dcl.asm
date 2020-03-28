SYS_EXIT equ 60
PERMUTATION_BUFFER_SIZE equ 43
ALPHABET_SIZE equ 42

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

  permL resb 42
  permR resb 42
  permT resb 42
  permLT resb 42
  permRT resb 42
  permTT resb 42

section .text


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
  call _checkPermutation
  mov rdx, QWORD [rsp + 24]
  mov r8, permR
  mov r9, permRT
  add r10, 10
  call _checkPermutation
  mov rdx, QWORD [rsp + 32]
  mov r8, permT
;  mov r9, permTT
  add r10, 10
  call _checkPermutation

  mov rdx, QWORD [rsp + 40]            ;sprawdzamy czy ostatni argument to dwa znaki z odpowiedniego przedziału
  mov al, BYTE [rdx + 2]
  cmp al, 0
  jne _exit1
  cmp r10, 33                           ;sprawdzamy czy '1' wystąpiło w każdej permutacji dokładnie raz
  jne _exit1
  checkChar BYTE [rdx]
  checkChar BYTE [rdx+1]


  mov rax, SYS_EXIT
  mov rdi, 0
  syscall



