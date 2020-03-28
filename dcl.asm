SYS_EXIT equ 60
PERMUTATION_BUFFER_SIZE equ 43
ALPHABET_SIZE equ 42

section .data

%macro checkChar 1
  mov al, %1
  cmp al, 49
  jl _exit1
  cmp al, 90
  jg _exit1
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

_checkPermutation:
  mov al, BYTE [rdx + ALPHABET_SIZE]
  cmp al, 0
  jne _exit1

  xor rcx, rcx

;bez duplikatow pierwszego elelmetnu
_checkCharLoop:
  checkChar BYTE [rdx + rcx]
  mov al, BYTE [rdx + rcx]
  sub al, 49
  cmp al, 0
  jne _notIncrementing
  inc r10
_notIncrementing:
  mov BYTE [r8 + rcx], al
  cmp BYTE [r9 + rax], 0
  jne _exit1
  mov [r9 + rax], cl

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
  xor r10, r10
  xor rax, rax
  mov rdx, QWORD [rsp + 16]
  mov r8, permL
  mov r9, permLT
  call _checkPermutation
  mov rdx, QWORD [rsp + 24]
  mov r8, permR
  mov r9, permRT
  call _checkPermutation
  mov rdx, QWORD [rsp + 32]
  mov r8, permT
  mov r9, permTT
  call _checkPermutation

  mov rdx, QWORD [rsp + 40]
  mov al, BYTE [rdx + 2]
  cmp al, 0
  jne _exit1
  cmp r10, 3
  jne _exit1
  checkChar BYTE [rdx]
  checkChar BYTE [rdx+1]

  mov rax, SYS_EXIT
  mov rdi, 0
  syscall



