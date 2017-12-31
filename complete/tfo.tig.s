.text
.global tigermain
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
L5:
movl $4, %esi
movl %esi, %esi
movl $0, %ebx
movl %ebx, %ebx
movl %esi, %esi
cmp %esi, %ebx
jg L0
L2:
pushl %ebx
call printi
movl %eax, %eax
movl $3, %eax
cmp %eax, %ebx
je ifTrueL0
ifFalseL0:
cmp %esi, %ebx
je L0
L3:
movl $1, %eax
movl %ebx, %ebx
addl %eax, %ebx
movl %ebx, %ebx
jmp L2
ifTrueL0:
L0:
movl $0, %eax
movl %eax, %eax
jmp L4
L4:
movl %edi, %edi
movl -8(%ebp), %esi

movl %esi, %esi
movl -4(%ebp), %ebx

movl %ebx, %ebx

leave
ret

