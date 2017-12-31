.text
.global tigermain
.type tigermain, @function
tigermain:
pushl %ebp
movl %esp,%ebp
subl $0,%esp
movl %ebx, %ebx
movl %esi, %esi
movl %edi, %edi
L2:
movl $4, %eax
pushl %eax
movl $9, %eax
pushl %eax
pushl %ebp
call g
movl %eax, %eax
movl %eax, %eax
pushl %eax
call printi
movl %eax, %eax
movl %eax, %eax
jmp L1
L1:
movl %edi, %edi
movl %esi, %esi
movl %ebx, %ebx

leave
ret

.text
.global g
.type g, @function
g:
pushl %ebp
movl %esp,%ebp
subl $0,%esp
movl %ebx, %ebx
movl %esi, %esi
movl %edi, %edi
L4:
movl 12(%ebp), %ecx
movl 16(%ebp), %edx
cmp %edx, %ecx
jg ifTrueL0
ifFalseL0:
movl 16(%ebp), %ecx
L0:
movl %ecx, %eax
jmp L3
ifTrueL0:
movl 12(%ebp), %ecx
jmp L0
L3:
movl %edi, %edi
movl %esi, %esi
movl %ebx, %ebx

leave
ret

