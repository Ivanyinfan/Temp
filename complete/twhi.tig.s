.text
.global tigermain
.type tigermain, @function
tigermain:
pushl %ebp
movl %esp,%ebp
subl $4,%esp
movl %ebx, %ebx
movl %ebx, -4(%ebp)

movl %esi, %esi
movl %edi, %edi
L2:
movl $10, %ebx
movl %ebx, %ebx
wTestL0:
movl $0, %eax
cmp %eax, %ebx
jge wLoopL0
wDoneL0:
movl $0, %eax
movl %eax, %eax
jmp L1
wLoopL0:
pushl %ebx
call printi
movl %eax, %eax
movl $1, %ecx
movl %ebx, %ebx
subl %ecx, %ebx
movl %ebx, %ebx
movl $2, %ecx
cmp %ecx, %ebx
je ifTrueL0
ifFalseL0:
jmp wTestL0
ifTrueL0:
jmp wDoneL0
L1:
movl %edi, %edi
movl %esi, %esi
movl -4(%ebp), %ebx

movl %ebx, %ebx

leave
ret

