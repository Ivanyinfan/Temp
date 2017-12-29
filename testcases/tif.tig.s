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

L6:
movl $9, %eax

pushl %eax

movl $4, %eax

pushl %eax

pushl %ebp

call L1

movl %eax, %eax

movl %eax, %eax

pushl %eax

call printi

movl %eax, %eax

movl %eax, %eax

jmp L5

L5:
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

L8:
movl 8(%ebp), %ecx

movl 12(%ebp), %edx

cmp %edx, %ecx

jg L2

L3:
movl 12(%ebp), %ecx

L4:
movl %ecx, %eax

jmp L7

L2:
movl 8(%ebp), %ecx

jmp L4

L7:
movl %edi, %edi

movl %esi, %esi

movl %ebx, %ebx



leave

ret


