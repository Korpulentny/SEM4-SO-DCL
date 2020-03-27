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

section .text

_exit1:
  mov rax, SYS_EXIT
  mov rdi, 1
  syscall

_checkPermutation:
  mov al, [rdx + ALPHABET_SIZE]
  cmp al, 0
  jne _exit1
  mov rcx, 0

_checkCharLoop:
  checkChar [rdx + rcx]
  inc rcx
  mov al, [rdx + rcx]
  cmp al, 0
  jne _checkCharLoop
  ret


  global _start

_start:
  mov rcx, [rsp]
  cmp rcx, 5
  jne _exit1
  mov rdx, [rsp + 16]
  call _checkPermutation
  mov rdx, [rsp + 24]
  call _checkPermutation
  mov rdx, [rsp + 32]
  call _checkPermutation

  mov rdx, [rsp + 40]
  mov al, [rdx + 2]
  cmp al, 0
  jne _exit1


  mov rax, SYS_EXIT
  mov rdi, 0
  syscall



