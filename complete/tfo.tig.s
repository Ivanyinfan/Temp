.text
.globl tigermain
.type tigermain, @function
tigermain:
pushl %ebp

movl %esp,%ebp

subl $8,%esp

movl %ebx, %ebx

movl %ebx, -4(%ebp)

movl %esi, %esi

movl %esi, -8(%ebp)

movl %edi, %edi

L7:
movl $4, %esi

movl %esi, %esi

movl $0, %ebx

movl %ebx, %ebx

movl %esi, %esi

cmp %esi, %ebx

jg L0

L4:
pushl %ebx

call printi

movl %eax, %eax

movl $3, %eax

cmp %eax, %ebx

je L1

L2:
cmp %esi, %ebx

je L0

L5:
movl $1, %eax

movl %ebx, %ebx

addl %eax, %ebx

movl %ebx, %ebx

jmp L4

L1:
L0:
movl $0, %eax

movl %eax, %eax

jmp L6

L6:
movl %edi, %edi

movl -8(%ebp), %esi

movl %esi, %esi

movl -4(%ebp), %ebx

movl %ebx, %ebx



leave

ret


