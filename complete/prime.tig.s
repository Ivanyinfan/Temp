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

L20:
pushl %ebp

call L1

movl %eax, %eax

movl %eax, %eax

jmp L19

L19:
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

L22:
movl $56, %eax

pushl %eax

movl 8(%ebp), %eax

pushl %eax

call L0

movl %eax, %eax

movl %eax, %eax

pushl %eax

call printi

movl %eax, %eax

movl $L8, %eax

pushl %eax

call print

movl %eax, %eax

movl $23, %eax

pushl %eax

movl 8(%ebp), %eax

pushl %eax

call L0

movl %eax, %eax

movl %eax, %eax

pushl %eax

call printi

movl %eax, %eax

movl $L9, %eax

pushl %eax

call print

movl %eax, %eax

movl $71, %eax

pushl %eax

movl 8(%ebp), %eax

pushl %eax

call L0

movl %eax, %eax

movl %eax, %eax

pushl %eax

call printi

movl %eax, %eax

movl $L10, %eax

pushl %eax

call print

movl %eax, %eax

movl $72, %eax

pushl %eax

movl 8(%ebp), %eax

pushl %eax

call L0

movl %eax, %eax

movl %eax, %eax

pushl %eax

call printi

movl %eax, %eax

movl $L11, %eax

pushl %eax

call print

movl %eax, %eax

movl $173, %eax

pushl %eax

movl 8(%ebp), %eax

pushl %eax

call L0

movl %eax, %eax

movl %eax, %eax

pushl %eax

call printi

movl %eax, %eax

movl $L12, %eax

pushl %eax

call print

movl %eax, %eax

movl $181, %eax

pushl %eax

movl 8(%ebp), %eax

pushl %eax

call L0

movl %eax, %eax

movl %eax, %eax

pushl %eax

call printi

movl %eax, %eax

movl $L13, %eax

pushl %eax

call print

movl %eax, %eax

movl $281, %eax

pushl %eax

movl 8(%ebp), %eax

pushl %eax

call L0

movl %eax, %eax

movl %eax, %eax

pushl %eax

call printi

movl %eax, %eax

movl $L14, %eax

pushl %eax

call print

movl %eax, %eax

movl $659, %eax

pushl %eax

movl 8(%ebp), %eax

pushl %eax

call L0

movl %eax, %eax

movl %eax, %eax

pushl %eax

call printi

movl %eax, %eax

movl $L15, %eax

pushl %eax

call print

movl %eax, %eax

movl $729, %eax

pushl %eax

movl 8(%ebp), %eax

pushl %eax

call L0

movl %eax, %eax

movl %eax, %eax

pushl %eax

call printi

movl %eax, %eax

movl $L16, %eax

pushl %eax

call print

movl %eax, %eax

movl $947, %eax

pushl %eax

movl 8(%ebp), %eax

pushl %eax

call L0

movl %eax, %eax

movl %eax, %eax

pushl %eax

call printi

movl %eax, %eax

movl $L17, %eax

pushl %eax

call print

movl %eax, %eax

movl $945, %eax

pushl %eax

movl 8(%ebp), %eax

pushl %eax

call L0

movl %eax, %eax

movl %eax, %eax

pushl %eax

call printi

movl %eax, %eax

movl $L18, %eax

pushl %eax

call print

movl %eax, %eax

movl %eax, %eax

jmp L21

L21:
movl %edi, %edi

movl %esi, %esi

movl %ebx, %ebx



leave

ret


.section .rodata
L18:
.int 1
.string "\n"
.section .rodata
L17:
.int 1
.string "\n"
.section .rodata
L16:
.int 1
.string "\n"
.section .rodata
L15:
.int 1
.string "\n"
.section .rodata
L14:
.int 1
.string "\n"
.section .rodata
L13:
.int 1
.string "\n"
.section .rodata
L12:
.int 1
.string "\n"
.section .rodata
L11:
.int 1
.string "\n"
.section .rodata
L10:
.int 1
.string "\n"
.section .rodata
L9:
.int 1
.string "\n"
.section .rodata
L8:
.int 1
.string "\n"
.text
.globl L0
.type L0, @function
L0:
pushl %ebp

movl %esp,%ebp

subl $8,%esp

movl %ebx, %ebx

movl %ebx, -4(%ebp)

movl %esi, %esi

movl %esi, -8(%ebp)

movl %edi, %edi

L24:
movl $1, %ecx

movl %ecx, %ecx

movl $2, %ebx

movl %ebx, %ebx

movl 12(%ebp), %eax

movl $2, %esi

movl %eax, %eax

cltd

idivl %esi

movl %eax, %esi

movl %esi, %esi

cmp %esi, %ebx

jg L2

L6:
movl 12(%ebp), %eax

movl %eax, %eax

cltd

idivl %ebx

movl %eax, %eax

movl %eax, %eax

imul %ebx, %eax

movl 12(%ebp), %edx

cmp %edx, %eax

je L3

L4:
cmp %esi, %ebx

je L2

L7:
movl $1, %eax

movl %ebx, %ebx

addl %eax, %ebx

movl %ebx, %ebx

jmp L6

L3:
movl $0, %ecx

movl %ecx, %ecx

L2:
movl %ecx, %eax

jmp L23

L23:
movl %edi, %edi

movl -8(%ebp), %esi

movl %esi, %esi

movl -4(%ebp), %ebx

movl %ebx, %ebx



leave

ret


