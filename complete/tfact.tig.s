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

L5:
movl $10, %eax

pushl %eax

pushl %ebp

call L0

movl %eax, %eax

movl %eax, %eax

pushl %eax

call printi

movl %eax, %eax

movl %eax, %eax

jmp L4

L4:
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

subl $4,%esp

movl %ebx, %ebx

movl %ebx, -4(%ebp)

movl %esi, %esi

movl %edi, %edi

L7:
movl 12(%ebp), %ebx

movl $0, %ecx

cmp %ecx, %ebx

je L1

L2:
movl 12(%ebp), %ebx

movl 12(%ebp), %eax

movl $1, %ecx

movl %eax, %eax

subl %ecx, %eax

pushl %eax

movl 8(%ebp), %eax

pushl %eax

call L0

movl %eax, %eax

movl %eax, %eax

movl %ebx, %ebx

imul %eax, %ebx

movl %ebx, %ebx

L3:
movl %ebx, %eax

jmp L6

L1:
movl $1, %ebx

movl %ebx, %ebx

jmp L3

L6:
movl %edi, %edi

movl %esi, %esi

movl -4(%ebp), %ebx

movl %ebx, %ebx



leave

ret


