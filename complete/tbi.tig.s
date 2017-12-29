.text
.globl tigermain
.type tigermain, @function
tigermain:
pushl %ebp

movl %esp,%ebp

subl $4,%esp

movl %ebx, %ebx

movl %esi, %esi

movl %edi, %edi

L15:
movl $8, %eax

movl %eax, -4(%ebp)

pushl %ebp

call L0

movl %eax, %eax

movl %eax, %eax

jmp L14

L14:
movl %edi, %edi

movl %esi, %esi

movl %ebx, %ebx



leave

ret


.text
.globl L0
.type L0, @function
L0:
pushl %ebp

movl %esp,%ebp

subl $16,%esp

movl %ebx, %ebx

movl %ebx, -4(%ebp)

movl %esi, %esi

movl %esi, -8(%ebp)

movl %edi, %edi

movl %edi, -12(%ebp)

L17:
movl $0, %eax

movl %eax, %eax

movl %eax, -16(%ebp)

movl 8(%ebp), %eax

movl -4(%eax), %ebx

movl $1, %eax

movl %ebx, %ebx

subl %eax, %ebx

movl %ebx, %ebx

movl -16(%ebp), %eax

cmp %ebx, %eax

jg L1

L11:
movl $0, %esi

movl %esi, %esi

movl 8(%ebp), %eax

movl -4(%eax), %edi

movl $1, %eax

movl %edi, %edi

subl %eax, %edi

movl %edi, %edi

cmp %edi, %esi

jg L2

L8:
movl -16(%ebp), %eax

cmp %esi, %eax

jg L5

L6:
movl $L4, %eax

movl %eax, %eax

L7:
pushl %eax

call print

movl %eax, %eax

cmp %edi, %esi

je L2

L9:
movl $1, %eax

movl %esi, %esi

addl %eax, %esi

movl %esi, %esi

jmp L8

L5:
movl $L3, %eax

movl %eax, %eax

jmp L7

L2:
movl $L10, %eax

pushl %eax

call print

movl %eax, %eax

movl -16(%ebp), %eax

cmp %ebx, %eax

je L1

L12:
movl $1, %ecx

movl -16(%ebp), %eax

movl %eax, %eax

addl %ecx, %eax

movl %eax, %eax

movl %eax, -16(%ebp)

jmp L11

L1:
movl $L13, %eax

pushl %eax

call print

movl %eax, %eax

movl %eax, %eax

jmp L16

L16:
movl -12(%ebp), %edi

movl %edi, %edi

movl -8(%ebp), %esi

movl %esi, %esi

movl -4(%ebp), %ebx

movl %ebx, %ebx



leave

ret


.section .rodata
L13:
.int 1
.string "\n"
.section .rodata
L10:
.int 1
.string "\n"
.section .rodata
L4:
.int 1
.string "y"
.section .rodata
L3:
.int 1
.string "x"
