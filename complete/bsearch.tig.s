.text
.globl tigermain
.type tigermain, @function
tigermain:
pushl %ebp

movl %esp,%ebp

subl $12,%esp

movl %ebx, %ebx

movl %ebx, -12(%ebp)

movl %esi, %esi

movl %edi, %edi

L16:
movl $16, %eax

movl %eax, -4(%ebp)

movl $-8, %ebx

movl %ebp, %eax

addl %ebx, %eax

movl %eax, %eax

movl $0, %ebx

pushl %ebx

movl -4(%ebp), %ebx

pushl %ebx

call initArray

movl %eax, %eax

movl %eax, %eax

movl %eax, (%eax)

pushl %ebp

call L3

movl %eax, %eax

movl %eax, %eax

jmp L15

L15:
movl %edi, %edi

movl %esi, %esi

movl -12(%ebp), %ebx

movl %ebx, %ebx



leave

ret


.text
.globl L3
.type L3, @function
L3:
pushl %ebp

movl %esp,%ebp

subl $0,%esp

movl %ebx, %ebx

movl %esi, %esi

movl %edi, %edi

L18:
movl 8(%ebp), %eax

pushl %eax

call L1

movl %eax, %eax

movl $7, %eax

pushl %eax

movl 8(%ebp), %eax

movl -4(%eax), %eax

movl $1, %ecx

movl %eax, %eax

subl %ecx, %eax

pushl %eax

movl $0, %eax

pushl %eax

movl 8(%ebp), %eax

pushl %eax

call L2

movl %eax, %eax

movl %eax, %eax

pushl %eax

call printi

movl %eax, %eax

movl $L14, %eax

pushl %eax

call print

movl %eax, %eax

movl %eax, %eax

jmp L17

L17:
movl %edi, %edi

movl %esi, %esi

movl %ebx, %ebx



leave

ret


.section .rodata
L14:
.int 1
.string "\n"
.text
.globl L2
.type L2, @function
L2:
pushl %ebp

movl %esp,%ebp

subl $4,%esp

movl %ebx, %ebx

movl %ebx, -4(%ebp)

movl %esi, %esi

movl %edi, %ebx

L20:
movl 12(%ebp), %eax

movl 16(%ebp), %ecx

cmp %ecx, %eax

je L11

L12:
movl 12(%ebp), %eax

movl 16(%ebp), %ecx

movl %eax, %eax

addl %ecx, %eax

movl $2, %ecx

movl %eax, %eax

cltd

idivl %ecx

movl %eax, %edi

movl %edi, %edi

movl 8(%ebp), %eax

movl -8(%eax), %ecx

movl $4, %edx

movl %edi, %eax

imul %edx, %eax

movl %ecx, %ecx

addl %eax, %ecx

movl (%ecx), %eax

movl 20(%ebp), %ecx

cmp %ecx, %eax

jl L8

L9:
movl 20(%ebp), %eax

pushl %eax

pushl %edi

movl 12(%ebp), %eax

pushl %eax

movl 8(%ebp), %eax

pushl %eax

call L2

movl %eax, %ecx

movl %ecx, %ecx

L10:
movl %ecx, %eax

L13:
movl %eax, %eax

jmp L19

L11:
movl 12(%ebp), %eax

jmp L13

L8:
movl 20(%ebp), %eax

pushl %eax

movl 16(%ebp), %eax

pushl %eax

movl $1, %ecx

movl %edi, %eax

addl %ecx, %eax

pushl %eax

movl 8(%ebp), %eax

pushl %eax

call L2

movl %eax, %ecx

movl %ecx, %ecx

jmp L10

L19:
movl %ebx, %edi

movl %esi, %esi

movl -4(%ebp), %ebx

movl %ebx, %ebx



leave

ret


.text
.globl L1
.type L1, @function
L1:
pushl %ebp

movl %esp,%ebp

subl $12,%esp

movl %ebx, %ebx

movl %ebx, -4(%ebp)

movl %esi, %esi

movl %esi, -8(%ebp)

movl %edi, %edi

movl %edi, -12(%ebp)

L22:
movl $0, %ebx

movl %ebx, %ebx

movl 8(%ebp), %eax

movl -4(%eax), %esi

movl $1, %eax

movl %esi, %esi

subl %eax, %esi

movl %esi, %esi

cmp %esi, %ebx

jg L5

L6:
movl $2, %ecx

movl %ebx, %eax

imul %ecx, %eax

movl $1, %ecx

movl %eax, %eax

addl %ecx, %eax

movl 8(%ebp), %ecx

movl -8(%ecx), %edx

movl $4, %edi

movl %ebx, %ecx

imul %edi, %ecx

movl %edx, %edx

addl %ecx, %edx

movl %eax, (%edx)

movl 8(%ebp), %eax

pushl %eax

call L0

movl %eax, %eax

cmp %esi, %ebx

je L5

L7:
movl $1, %eax

movl %ebx, %ebx

addl %eax, %ebx

movl %ebx, %ebx

jmp L6

L5:
movl $0, %eax

movl %eax, %eax

jmp L21

L21:
movl -12(%ebp), %edi

movl %edi, %edi

movl -8(%ebp), %esi

movl %esi, %esi

movl -4(%ebp), %ebx

movl %ebx, %ebx



leave

ret


.text
.globl L0
.type L0, @function
L0:
pushl %ebp

movl %esp,%ebp

subl $0,%esp

movl %ebx, %ebx

movl %esi, %esi

movl %edi, %edi

L24:
movl $L4, %eax

pushl %eax

call print

movl %eax, %eax

movl %eax, %eax

jmp L23

L23:
movl %edi, %edi

movl %esi, %esi

movl %ebx, %ebx



leave

ret


.section .rodata
L4:
.int 0
.string ""
