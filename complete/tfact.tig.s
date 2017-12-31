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
movl $10, %eax
pushl %eax
pushl %ebp
call nfactor
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
.global nfactor
.type nfactor, @function
nfactor:
pushl %ebp
movl %esp,%ebp
subl $4,%esp
movl %ebx, %ebx
movl %ebx, -4(%ebp)

movl %esi, %esi
movl %edi, %edi
L4:
movl 12(%ebp), %ebx
movl $0, %ecx
cmp %ecx, %ebx
je ifTrueL0
ifFalseL0:
movl 12(%ebp), %ebx
movl 12(%ebp), %eax
movl $1, %ecx
movl %eax, %eax
subl %ecx, %eax
pushl %eax
movl 8(%ebp), %eax
pushl %eax
call nfactor
movl %eax, %eax
movl %eax, %eax
movl %ebx, %ebx
imul %eax, %ebx
movl %ebx, %ebx
L0:
movl %ebx, %eax
jmp L3
ifTrueL0:
movl $1, %ebx
movl %ebx, %ebx
jmp L0
L3:
movl %edi, %edi
movl %esi, %esi
movl -4(%ebp), %ebx

movl %ebx, %ebx

leave
ret

