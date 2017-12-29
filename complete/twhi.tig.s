.text
.globl tigermain
.type tigermain, @function
tigermain:
pushl %ebp

movl %esp,%ebp

subl $4,%esp

movl %ebx, %ebx

movl %ebx, -4(%ebp)

movl %esi, %esi

movl %edi, %edi

L7:
movl $10, %ebx

movl %ebx, %ebx

L4:
movl $0, %eax

cmp %eax, %ebx

jge L5

L0:
movl $0, %eax

movl %eax, %eax

jmp L6

L5:
pushl %ebx

call printi

movl %eax, %eax

movl $1, %ecx

movl %ebx, %ebx

subl %ecx, %ebx

movl %ebx, %ebx

movl $2, %ecx

cmp %ecx, %ebx

je L1

L2:
jmp L4

L1:
jmp L0

L6:
movl %edi, %edi

movl %esi, %esi

movl -4(%ebp), %ebx

movl %ebx, %ebx



leave

ret


