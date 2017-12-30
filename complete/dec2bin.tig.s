.text
.globl tigermain
.type tigermain, @function
tigermain:
pushl %ebp

movl %esp,%ebp

subl $0,%esp

movl %ebx, %ebx

movl %esi, %esi

movl %edi, %edi

L14:
pushl %ebp

call L1

movl %eax, %eax

movl %eax, %eax

jmp L13

L13:
movl %edi, %edi

movl %esi, %esi

movl %ebx, %ebx



leave

ret


.text
.globl L1
.type L1, @function
L1:
pushl %ebp

movl %esp,%ebp

subl $0,%esp

movl %ebx, %ebx

movl %esi, %esi

movl %edi, %edi

L16:
movl $100, %eax

pushl %eax

call printi

movl %eax, %eax

movl $L5, %eax

pushl %eax

call print

movl %eax, %eax

movl $100, %eax

pushl %eax

movl 8(%ebp), %eax

pushl %eax

call L0

movl %eax, %eax

movl $L6, %eax

pushl %eax

call print

movl %eax, %eax

movl $200, %eax

pushl %eax

call printi

movl %eax, %eax

movl $L7, %eax

pushl %eax

call print

movl %eax, %eax

movl $200, %eax

pushl %eax

movl 8(%ebp), %eax

pushl %eax

call L0

movl %eax, %eax

movl $L8, %eax

pushl %eax

call print

movl %eax, %eax

movl $789, %eax

pushl %eax

call printi

movl %eax, %eax

movl $L9, %eax

pushl %eax

call print

movl %eax, %eax

movl $789, %eax

pushl %eax

movl 8(%ebp), %eax

pushl %eax

call L0

movl %eax, %eax

movl $L10, %eax

pushl %eax

call print

movl %eax, %eax

movl $567, %eax

pushl %eax

call printi

movl %eax, %eax

movl $L11, %eax

pushl %eax

call print

movl %eax, %eax

movl $567, %eax

pushl %eax

movl 8(%ebp), %eax

pushl %eax

call L0

movl %eax, %eax

movl $L12, %eax

pushl %eax

call print

movl %eax, %eax

movl %eax, %eax

jmp L15

L15:
movl %edi, %edi

movl %esi, %esi

movl %ebx, %ebx



leave

ret


.section .rodata
L12:
.int 1
.string "\n"
.section .rodata
L11:
.int 4
.string "\t->\t"
.section .rodata
L10:
.int 1
.string "\n"
.section .rodata
L9:
.int 4
.string "\t->\t"
.section .rodata
L8:
.int 1
.string "\n"
.section .rodata
L7:
.int 4
.string "\t->\t"
.section .rodata
L6:
.int 1
.string "\n"
.section .rodata
L5:
.int 4
.string "\t->\t"
.text
.globl L0
.type L0, @function
L0:
pushl %ebp

movl %esp,%ebp

subl $4,%esp

movl %ebx, %ebx

movl %ebx, -4(%ebp)

movl %esi, %esi

movl %edi, %edi

L18:
movl 12(%ebp), %eax

movl $0, %ebx

cmp %ebx, %eax

jg L2

L3:
movl $0, %eax

movl %eax, %eax

jmp L17

L2:
movl 12(%ebp), %eax

movl $2, %ebx

movl %eax, %eax

cltd

idivl %ebx

movl %eax, %eax

pushl %eax

movl 8(%ebp), %eax

pushl %eax

call L0

movl %eax, %eax

movl 12(%ebp), %ecx

movl 12(%ebp), %eax

movl $2, %ebx

movl %eax, %eax

cltd

idivl %ebx

movl %eax, %eax

movl $2, %ebx

movl %eax, %eax

imul %ebx, %eax

movl %ecx, %ecx

subl %eax, %ecx

pushl %ecx

call printi

movl %eax, %eax

jmp L3

L17:
movl %edi, %edi

movl %esi, %esi

movl -4(%ebp), %ebx

movl %ebx, %ebx



leave

ret


