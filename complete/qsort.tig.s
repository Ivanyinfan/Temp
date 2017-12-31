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
L17:
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
call dosort
movl %eax, %eax
movl %eax, %eax
jmp L16
L16:
movl %edi, %edi
movl %esi, %esi
movl -12(%ebp), %ebx

movl %ebx, %ebx

leave
ret

.text
.global dosort
.type dosort, @function
dosort:
pushl %ebp
movl %esp,%ebp
subl $8,%esp
movl %ebx, %ebx
movl %ebx, -4(%ebp)

movl %esi, %esi
movl %esi, -8(%ebp)

movl %edi, %edi
L19:
movl 8(%ebp), %eax
pushl %eax
call init
movl %eax, %eax
movl 8(%ebp), %eax
movl -4(%eax), %eax
movl $1, %ebx
movl %eax, %eax
subl %ebx, %eax
pushl %eax
movl $0, %eax
pushl %eax
movl 8(%ebp), %eax
pushl %eax
call quicksort
movl %eax, %eax
movl $0, %ebx
movl %ebx, %ebx
movl 8(%ebp), %eax
movl -4(%eax), %esi
movl $1, %eax
movl %esi, %esi
subl %eax, %esi
movl %esi, %esi
cmp %esi, %ebx
jg L11
L13:
movl 8(%ebp), %eax
movl -8(%eax), %ecx
movl $4, %edx
movl %ebx, %eax
imul %edx, %eax
movl %ecx, %ecx
addl %eax, %ecx
movl (%ecx), %eax
pushl %eax
call printi
movl %eax, %eax
movl $L12, %eax
pushl %eax
call print
movl %eax, %eax
cmp %esi, %ebx
je L11
L14:
movl $1, %eax
movl %ebx, %ebx
addl %eax, %ebx
movl %ebx, %ebx
jmp L13
L11:
movl $L15, %eax
pushl %eax
call print
movl %eax, %eax
movl %eax, %eax
jmp L18
L18:
movl %edi, %edi
movl -8(%ebp), %esi

movl %esi, %esi
movl -4(%ebp), %ebx

movl %ebx, %ebx

leave
ret

.section .rodata
L15:
.int 1
.string "\n"
.section .rodata
L12:
.int 1
.string " "
.text
.global quicksort
.type quicksort, @function
quicksort:
pushl %ebp
movl %esp,%ebp
subl $20,%esp
movl %ebx, %ebx
movl %ebx, -4(%ebp)

movl %esi, %esi
movl %esi, -8(%ebp)

movl %edi, %edi
movl %edi, -16(%ebp)

L21:
movl 12(%ebp), %ebx
movl %ebx, -20(%ebp)

movl 16(%ebp), %ebx
movl %ebx, -12(%ebp)

movl 8(%ebp), %ebx
movl -8(%ebx), %ecx
movl 12(%ebp), %ebx
movl $4, %edx
movl %ebx, %ebx
imul %edx, %ebx
movl %ecx, %ecx
addl %ebx, %ecx
movl (%ecx), %ebx
movl %ebx, %ebx
movl 12(%ebp), %ecx
movl 16(%ebp), %edx
cmp %edx, %ecx
jl ifTrueL2
ifFalseL2:
movl $0, %eax
movl %eax, %eax
jmp L20
ifTrueL2:
wTestL2:
movl -12(%ebp), %ecx

movl -20(%ebp), %edx

cmp %ecx, %edx
jl wLoopL2
wDoneL0:
movl 8(%ebp), %eax
movl -8(%eax), %ecx
movl $4, %edx
movl -20(%ebp), %eax

movl %eax, %eax
imul %edx, %eax
movl %ecx, %ecx
addl %eax, %ecx
movl %ebx, (%ecx)
movl $1, %ecx
movl -20(%ebp), %eax

movl %eax, %eax
subl %ecx, %eax
pushl %eax
movl 12(%ebp), %eax
pushl %eax
movl 8(%ebp), %eax
pushl %eax
call quicksort
movl %eax, %eax
movl 16(%ebp), %eax
pushl %eax
movl $1, %ecx
movl -20(%ebp), %eax

movl %eax, %eax
addl %ecx, %eax
pushl %eax
movl 8(%ebp), %eax
pushl %eax
call quicksort
movl %eax, %eax
jmp ifFalseL2
wLoopL2:
wTestL0:
movl -12(%ebp), %ecx

movl -20(%ebp), %edx

cmp %ecx, %edx
jl ifTrueL0
ifFalseL0:
movl $0, %ecx
movl %ecx, %ecx
L4:
movl $0, %edx
cmp %edx, %ecx
jne wLoopL0
wDoneL1:
movl 8(%ebp), %ecx
movl -8(%ecx), %edx
movl $4, %esi
movl -12(%ebp), %ecx

movl %ecx, %ecx
imul %esi, %ecx
movl %edx, %edx
addl %ecx, %edx
movl (%edx), %edx
movl 8(%ebp), %ecx
movl -8(%ecx), %esi
movl $4, %ecx
movl -20(%ebp), %edi

movl %edi, %edi
imul %ecx, %edi
movl %esi, %esi
addl %edi, %esi
movl %edx, (%esi)
wTestL1:
movl -12(%ebp), %ecx

movl -20(%ebp), %edx

cmp %ecx, %edx
jl ifTrueL1
ifFalseL1:
movl $0, %ecx
movl %ecx, %ecx
L7:
movl $0, %edx
cmp %edx, %ecx
jne wLoopL1
wDoneL2:
movl 8(%ebp), %ecx
movl -8(%ecx), %edx
movl $4, %esi
movl -20(%ebp), %ecx

movl %ecx, %ecx
imul %esi, %ecx
movl %edx, %edx
addl %ecx, %edx
movl (%edx), %edx
movl 8(%ebp), %ecx
movl -8(%ecx), %esi
movl $4, %ecx
movl -12(%ebp), %edi

movl %edi, %edi
imul %ecx, %edi
movl %esi, %esi
addl %edi, %esi
movl %edx, (%esi)
jmp wTestL2
ifTrueL0:
movl $1, %ecx
movl %ecx, %ecx
movl 8(%ebp), %edx
movl -8(%edx), %esi
movl $4, %edx
movl -12(%ebp), %edi

movl %edi, %edi
imul %edx, %edi
movl %esi, %esi
addl %edi, %esi
movl (%esi), %edx
cmp %edx, %ebx
jle L5
L6:
movl $0, %ecx
movl %ecx, %ecx
L5:
movl %ecx, %ecx
jmp L4
wLoopL0:
movl $1, %edx
movl -12(%ebp), %ecx

movl %ecx, %ecx
subl %edx, %ecx
movl %ecx, %ecx
movl %ecx, -12(%ebp)

jmp wTestL0
ifTrueL1:
movl $1, %ecx
movl %ecx, %ecx
movl 8(%ebp), %edx
movl -8(%edx), %esi
movl $4, %edx
movl -20(%ebp), %edi

movl %edi, %edi
imul %edx, %edi
movl %esi, %esi
addl %edi, %esi
movl (%esi), %edx
cmp %edx, %ebx
jge L8
L9:
movl $0, %ecx
movl %ecx, %ecx
L8:
movl %ecx, %ecx
jmp L7
wLoopL1:
movl $1, %edx
movl -20(%ebp), %ecx

movl %ecx, %ecx
addl %edx, %ecx
movl %ecx, %ecx
movl %ecx, -20(%ebp)

jmp wTestL1
L20:
movl -16(%ebp), %edi

movl %edi, %edi
movl -8(%ebp), %esi

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

L23:
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
movl 8(%ebp), %eax
movl -4(%eax), %eax
movl %eax, %eax
subl %ebx, %eax
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
jmp L22
L22:
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
L25:
movl $L0, %eax
pushl %eax
call print
movl %eax, %eax
movl %eax, %eax
jmp L24
L24:
movl %edi, %edi
movl %esi, %esi
movl %ebx, %ebx

leave
ret

.section .rodata
L0:
.int 0
.string ""
