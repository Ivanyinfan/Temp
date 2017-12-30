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

L24:
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

jmp L23

L23:
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

subl $8,%esp

movl %ebx, %ebx

movl %ebx, -4(%ebp)

movl %esi, %esi

movl %esi, -8(%ebp)

movl %edi, %edi

L26:
movl 8(%ebp), %eax

pushl %eax

call L1

movl %eax, %eax

movl 8(%ebp), %eax

movl -4(%eax), %eax

movl $1, %ebx

movl %eax, %eax

subl %ebx, %eax

pushl %eax

movl $0, %eax

pushl %eax

movl 8(%ebp), %eax

pushl %eax

call L2

movl %eax, %eax

movl $0, %ebx

movl %ebx, %ebx

movl 8(%ebp), %eax

movl -4(%eax), %esi

movl $1, %eax

movl %esi, %esi

subl %eax, %esi

movl %esi, %esi

cmp %esi, %ebx

jg L18

L20:
movl 8(%ebp), %eax

movl -8(%eax), %ecx

movl $4, %edx

movl %ebx, %eax

imul %edx, %eax

movl %ecx, %ecx

addl %eax, %ecx

movl (%ecx), %eax

pushl %eax

call printi

movl %eax, %eax

movl $L19, %eax

pushl %eax

call print

movl %eax, %eax

cmp %esi, %ebx

je L18

L21:
movl $1, %eax

movl %ebx, %ebx

addl %eax, %ebx

movl %ebx, %ebx

jmp L20

L18:
movl $L22, %eax

pushl %eax

call print

movl %eax, %eax

movl %eax, %eax

jmp L25

L25:
movl %edi, %edi

movl -8(%ebp), %esi

movl %esi, %esi

movl -4(%ebp), %ebx

movl %ebx, %ebx



leave

ret


.section .rodata
L22:
.int 1
.string "\n"
.section .rodata
L19:
.int 1
.string " "
.text
.globl L2
.type L2, @function
L2:
pushl %ebp

movl %esp,%ebp

subl $20,%esp

movl %ebx, %ebx

movl %ebx, -4(%ebp)

movl %esi, %esi

movl %esi, -8(%ebp)

movl %edi, %edi

movl %edi, -16(%ebp)

L28:
movl 12(%ebp), %ebx

movl %ebx, -20(%ebp)

movl 16(%ebp), %ebx

movl %ebx, -12(%ebp)

movl 8(%ebp), %ebx

movl -8(%ebx), %ecx

movl 12(%ebp), %ebx

movl $4, %edx

movl %ebx, %ebx

imul %edx, %ebx

movl %ecx, %ecx

addl %ebx, %ecx

movl (%ecx), %ebx

movl %ebx, %ebx

movl 12(%ebp), %ecx

movl 16(%ebp), %edx

cmp %edx, %ecx

jl ifTrueL2

ifFalseL2:
movl $0, %eax

movl %eax, %eax

jmp L27

ifTrueL2:
L16:
movl -12(%ebp), %ecx

movl -20(%ebp), %edx

cmp %ecx, %edx

jl wLoopL2

wDoneL0:
movl 8(%ebp), %eax

movl -8(%eax), %ecx

movl $4, %edx

movl -20(%ebp), %eax

movl %eax, %eax

imul %edx, %eax

movl %ecx, %ecx

addl %eax, %ecx

movl %ebx, (%ecx)

movl $1, %ecx

movl -20(%ebp), %eax

movl %eax, %eax

subl %ecx, %eax

pushl %eax

movl 12(%ebp), %eax

pushl %eax

movl 8(%ebp), %eax

pushl %eax

call L2

movl %eax, %eax

movl 16(%ebp), %eax

pushl %eax

movl $1, %ecx

movl -20(%ebp), %eax

movl %eax, %eax

addl %ecx, %eax

pushl %eax

movl 8(%ebp), %eax

pushl %eax

call L2

movl %eax, %eax

jmp ifFalseL2

wLoopL2:
L11:
movl -12(%ebp), %ecx

movl -20(%ebp), %edx

cmp %ecx, %edx

jl ifTrueL0

ifFalseL0:
movl $0, %ecx

movl %ecx, %ecx

L8:
movl $0, %edx

cmp %edx, %ecx

jne wLoopL0

wDoneL1:
movl 8(%ebp), %ecx

movl -8(%ecx), %edx

movl $4, %esi

movl -12(%ebp), %ecx

movl %ecx, %ecx

imul %esi, %ecx

movl %edx, %edx

addl %ecx, %edx

movl (%edx), %edx

movl 8(%ebp), %ecx

movl -8(%ecx), %esi

movl $4, %ecx

movl -20(%ebp), %edi

movl %edi, %edi

imul %ecx, %edi

movl %esi, %esi

addl %edi, %esi

movl %edx, (%esi)

L15:
movl -12(%ebp), %ecx

movl -20(%ebp), %edx

cmp %ecx, %edx

jl ifTrueL1

ifFalseL1:
movl $0, %ecx

movl %ecx, %ecx

L12:
movl $0, %edx

cmp %edx, %ecx

jne wLoopL1

wDoneL2:
movl 8(%ebp), %ecx

movl -8(%ecx), %edx

movl $4, %esi

movl -20(%ebp), %ecx

movl %ecx, %ecx

imul %esi, %ecx

movl %edx, %edx

addl %ecx, %edx

movl (%edx), %edx

movl 8(%ebp), %ecx

movl -8(%ecx), %esi

movl $4, %ecx

movl -12(%ebp), %edi

movl %edi, %edi

imul %ecx, %edi

movl %esi, %esi

addl %edi, %esi

movl %edx, (%esi)

jmp L16

ifTrueL0:
movl $1, %ecx

movl %ecx, %ecx

movl 8(%ebp), %edx

movl -8(%edx), %esi

movl $4, %edx

movl -12(%ebp), %edi

movl %edi, %edi

imul %edx, %edi

movl %esi, %esi

addl %edi, %esi

movl (%esi), %edx

cmp %edx, %ebx

jle L9

L10:
movl $0, %ecx

movl %ecx, %ecx

L9:
movl %ecx, %ecx

jmp L8

wLoopL0:
movl $1, %edx

movl -12(%ebp), %ecx

movl %ecx, %ecx

subl %edx, %ecx

movl %ecx, %ecx

movl %ecx, -12(%ebp)

jmp L11

ifTrueL1:
movl $1, %ecx

movl %ecx, %ecx

movl 8(%ebp), %edx

movl -8(%edx), %esi

movl $4, %edx

movl -20(%ebp), %edi

movl %edi, %edi

imul %edx, %edi

movl %esi, %esi

addl %edi, %esi

movl (%esi), %edx

cmp %edx, %ebx

jge L13

L14:
movl $0, %ecx

movl %ecx, %ecx

L13:
movl %ecx, %ecx

jmp L12

wLoopL1:
movl $1, %edx

movl -20(%ebp), %ecx

movl %ecx, %ecx

addl %edx, %ecx

movl %ecx, %ecx

movl %ecx, -20(%ebp)

jmp L15

L27:
movl -16(%ebp), %edi

movl %edi, %edi

movl -8(%ebp), %esi

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

L30:
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
movl 8(%ebp), %eax

movl -4(%eax), %eax

movl %eax, %eax

subl %ebx, %eax

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

jmp L29

L29:
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

L32:
movl $L4, %eax

pushl %eax

call print

movl %eax, %eax

movl %eax, %eax

jmp L31

L31:
movl %edi, %edi

movl %esi, %esi

movl %ebx, %ebx



leave

ret


.section .rodata
L4:
.int 0
.string ""
