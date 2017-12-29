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

L9:
movl $5, %eax

movl %eax, -4(%ebp)

movl -4(%ebp), %eax

pushl %eax

call printi

movl %eax, %eax

movl $L7, %eax

pushl %eax

call print

movl %eax, %eax

movl $2, %eax

pushl %eax

pushl %ebp

call L0

movl %eax, %eax

movl -4(%ebp), %eax

pushl %eax

call printi

movl %eax, %eax

movl %eax, %eax

jmp L8

L8:
movl %edi, %edi

movl %esi, %esi

movl %ebx, %ebx



leave

ret


.section .rodata
L7:
.int 1
.string "\n"
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

L11:
movl $1, %eax

movl %eax, %eax

movl 12(%ebp), %ecx

movl $3, %edx

cmp %edx, %ecx

jg L1

L2:
movl $0, %eax

movl %eax, %eax

L1:
movl $0, %ecx

cmp %ecx, %eax

jne L4

L5:
movl $4, %eax

movl 8(%ebp), %ecx

movl %eax, -4(%ecx)

movl $0, %ecx

movl %ecx, %ecx

L6:
movl %ecx, %eax

jmp L10

L4:
movl $L3, %eax

pushl %eax

call print

movl %eax, %ecx

movl %ecx, %ecx

jmp L6

L10:
movl %edi, %edi

movl %esi, %esi

movl %ebx, %ebx



leave

ret


.section .rodata
L3:
.int 20
.string "hey! Bigger than 3!\n"
