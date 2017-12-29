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
movl $4, %eax

pushl %eax

movl $9, %eax

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

subl $0,%esp

movl %ebx, %ebx

movl %esi, %esi

movl %edi, %edi

L7:
movl 12(%ebp), %ecx

movl 16(%ebp), %edx

cmp %edx, %ecx

jg L1

L2:
movl 16(%ebp), %ecx

L3:
movl %ecx, %eax

jmp L6

L1:
movl 12(%ebp), %ecx

jmp L3

L6:
movl %edi, %edi

movl %esi, %esi

movl %ebx, %ebx



leave

ret


