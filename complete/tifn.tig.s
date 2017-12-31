.text
.global tigermain
.type tigermain, @function
tigermain:
pushl %ebp
movl %esp,%ebp
subl $4,%esp
movl %ebx, %ebx
movl %esi, %esi
movl %edi, %edi
L6:
movl $5, %eax
movl %eax, -4(%ebp)
movl -4(%ebp), %eax
pushl %eax
call printi
movl %eax, %eax
movl $L4, %eax
pushl %eax
call print
movl %eax, %eax
movl $2, %eax
pushl %eax
pushl %ebp
call g
movl %eax, %eax
movl -4(%ebp), %eax
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

.section .rodata
L4:
.int 1
.string "\n"
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
L8:
movl $1, %eax
movl %eax, %eax
movl 12(%ebp), %ecx
movl $3, %edx
cmp %edx, %ecx
jg L0
L1:
movl $0, %eax
movl %eax, %eax
L0:
movl $0, %ecx
cmp %ecx, %eax
jne ifTrueL0
ifFalseL0:
movl $4, %eax
movl 8(%ebp), %ecx
movl %eax, -4(%ecx)
movl $0, %ecx
movl %ecx, %ecx
L3:
movl %ecx, %eax
jmp L7
ifTrueL0:
movl $L2, %eax
pushl %eax
call print
movl %eax, %ecx
movl %ecx, %ecx
jmp L3
L7:
movl %edi, %edi
movl %esi, %esi
movl %ebx, %ebx

leave
ret

.section .rodata
L2:
.int 20
.string "hey! Bigger than 3!\n"
