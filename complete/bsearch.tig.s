.text
.global tigermain
.type tigermain, @function
tigermain:
pushl %ebp
movl %esp,%ebp
subl $12,%esp
movl %ebx, %ebx
movl %ebx, -12(%ebp)

movl %esi, %esi
movl %edi, %edi
L8:
movl $16, %eax
movl %eax, -4(%ebp)
movl $-8, %ebx
movl %ebp, %eax
addl %ebx, %eax
movl %eax, %eax
movl $0, %ebx
pushl %ebx
movl -4(%ebp), %ebx
pushl %ebx
call initArray
movl %eax, %eax
movl %eax, %eax
movl %eax, (%eax)
pushl %ebp
call try
movl %eax, %eax
movl %eax, %eax
jmp L7
L7:
movl %edi, %edi
movl %esi, %esi
movl -12(%ebp), %ebx

movl %ebx, %ebx

leave
ret

.text
.global try
.type try, @function
try:
pushl %ebp
movl %esp,%ebp
subl $0,%esp
movl %ebx, %ebx
movl %esi, %esi
movl %edi, %edi
L10:
movl 8(%ebp), %eax
pushl %eax
call init
movl %eax, %eax
movl $7, %eax
pushl %eax
movl 8(%ebp), %eax
movl -4(%eax), %eax
movl $1, %ecx
movl %eax, %eax
subl %ecx, %eax
pushl %eax
movl $0, %eax
pushl %eax
movl 8(%ebp), %eax
pushl %eax
call bsearch
movl %eax, %eax
movl %eax, %eax
pushl %eax
call printi
movl %eax, %eax
movl $L6, %eax
pushl %eax
call print
movl %eax, %eax
movl %eax, %eax
jmp L9
L9:
movl %edi, %edi
movl %esi, %esi
movl %ebx, %ebx

leave
ret

.section .rodata
L6:
.int 1
.string "\n"
.text
.global bsearch
.type bsearch, @function
bsearch:
pushl %ebp
movl %esp,%ebp
subl $4,%esp
movl %ebx, %ebx
movl %ebx, -4(%ebp)

movl %esi, %esi
movl %edi, %ebx
L12:
movl 12(%ebp), %eax
movl 16(%ebp), %ecx
cmp %ecx, %eax
je ifTrueL1
ifFalseL1:
movl 12(%ebp), %eax
movl 16(%ebp), %ecx
movl %eax, %eax
addl %ecx, %eax
movl $2, %ecx
movl %eax, %eax
cltd
idivl %ecx
movl %eax, %edi
movl %edi, %edi
movl 8(%ebp), %eax
movl -8(%eax), %ecx
movl $4, %edx
movl %edi, %eax
imul %edx, %eax
movl %ecx, %ecx
addl %eax, %ecx
movl (%ecx), %eax
movl 20(%ebp), %ecx
cmp %ecx, %eax
jl ifTrueL0
ifFalseL0:
movl 20(%ebp), %eax
pushl %eax
pushl %edi
movl 12(%ebp), %eax
pushl %eax
movl 8(%ebp), %eax
pushl %eax
call bsearch
movl %eax, %ecx
movl %ecx, %ecx
L4:
movl %ecx, %eax
L5:
movl %eax, %eax
jmp L11
ifTrueL1:
movl 12(%ebp), %eax
jmp L5
ifTrueL0:
movl 20(%ebp), %eax
pushl %eax
movl 16(%ebp), %eax
pushl %eax
movl $1, %ecx
movl %edi, %eax
addl %ecx, %eax
pushl %eax
movl 8(%ebp), %eax
pushl %eax
call bsearch
movl %eax, %ecx
movl %ecx, %ecx
jmp L4
L11:
movl %ebx, %edi
movl %esi, %esi
movl -4(%ebp), %ebx

movl %ebx, %ebx

leave
ret

.text
.global init
.type init, @function
init:
pushl %ebp
movl %esp,%ebp
subl $12,%esp
movl %ebx, %ebx
movl %ebx, -4(%ebp)

movl %esi, %esi
movl %esi, -8(%ebp)

movl %edi, %edi
movl %edi, -12(%ebp)

L14:
movl $0, %ebx
movl %ebx, %ebx
movl 8(%ebp), %eax
movl -4(%eax), %esi
movl $1, %eax
movl %esi, %esi
subl %eax, %esi
movl %esi, %esi
cmp %esi, %ebx
jg L1
L2:
movl $2, %ecx
movl %ebx, %eax
imul %ecx, %eax
movl $1, %ecx
movl %eax, %eax
addl %ecx, %eax
movl 8(%ebp), %ecx
movl -8(%ecx), %edx
movl $4, %edi
movl %ebx, %ecx
imul %edi, %ecx
movl %edx, %edx
addl %ecx, %edx
movl %eax, (%edx)
movl 8(%ebp), %eax
pushl %eax
call nop
movl %eax, %eax
cmp %esi, %ebx
je L1
L3:
movl $1, %eax
movl %ebx, %ebx
addl %eax, %ebx
movl %ebx, %ebx
jmp L2
L1:
movl $0, %eax
movl %eax, %eax
jmp L13
L13:
movl -12(%ebp), %edi

movl %edi, %edi
movl -8(%ebp), %esi

movl %esi, %esi
movl -4(%ebp), %ebx

movl %ebx, %ebx

leave
ret

.text
.global nop
.type nop, @function
nop:
pushl %ebp
movl %esp,%ebp
subl $0,%esp
movl %ebx, %ebx
movl %esi, %esi
movl %edi, %edi
L16:
movl $L0, %eax
pushl %eax
call print
movl %eax, %eax
movl %eax, %eax
jmp L15
L15:
movl %edi, %edi
movl %esi, %esi
movl %ebx, %ebx

leave
ret

.section .rodata
L0:
.int 0
.string ""
