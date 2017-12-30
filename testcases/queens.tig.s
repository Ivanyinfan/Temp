.text
.global tigermain
.type tigermain, @function
tigermain:
pushl %ebp
movl %esp,%ebp
subl $24,%esp
movl %ebx, %ebx
movl %ebx, -24(%ebp)

movl %esi, %esi
movl %edi, %edi
L23:
movl $8, %eax
movl %eax, -4(%ebp)
movl $-8, %eax
movl %ebp, %ebx
addl %eax, %ebx
movl %ebx, %ebx
movl $0, %eax
pushl %eax
movl -4(%ebp), %eax
pushl %eax
call initArray
movl %eax, %eax
movl %eax, %eax
movl %eax, (%ebx)
movl $-12, %eax
movl %ebp, %ebx
addl %eax, %ebx
movl %ebx, %ebx
movl $0, %eax
pushl %eax
movl -4(%ebp), %eax
pushl %eax
call initArray
movl %eax, %eax
movl %eax, %eax
movl %eax, (%ebx)
movl $-16, %eax
movl %ebp, %ebx
addl %eax, %ebx
movl %ebx, %ebx
movl $0, %eax
pushl %eax
movl -4(%ebp), %eax
movl -4(%ebp), %ecx
movl %eax, %eax
addl %ecx, %eax
movl $1, %ecx
movl %eax, %eax
subl %ecx, %eax
pushl %eax
call initArray
movl %eax, %eax
movl %eax, %eax
movl %eax, (%ebx)
movl $-20, %eax
movl %ebp, %ebx
addl %eax, %ebx
movl %ebx, %ebx
movl $0, %eax
pushl %eax
movl -4(%ebp), %eax
movl -4(%ebp), %ecx
movl %eax, %eax
addl %ecx, %eax
movl $1, %ecx
movl %eax, %eax
subl %ecx, %eax
pushl %eax
call initArray
movl %eax, %eax
movl %eax, %eax
movl %eax, (%ebx)
movl $0, %eax
pushl %eax
pushl %ebp
call try
movl %eax, %eax
movl %eax, %eax
jmp L22
L22:
movl %edi, %edi
movl %esi, %esi
movl -24(%ebp), %ebx

movl %ebx, %ebx

leave
ret

.text
.global try
.type try, @function
try:
pushl %ebp
movl %esp,%ebp
subl $16,%esp
movl %ebx, %ebx
movl %ebx, -4(%ebp)

movl %esi, %ebx
movl %ebx, -8(%ebp)

movl %edi, %ebx
movl %ebx, -12(%ebp)

L25:
movl 12(%ebp), %ebx
movl 8(%ebp), %ecx
movl -4(%ecx), %ecx
cmp %ecx, %ebx
je ifTrueL4
ifFalseL4:
movl $0, %ebx
movl %ebx, %esi
movl 8(%ebp), %ebx
movl -4(%ebx), %ebx
movl $1, %ecx
movl %ebx, %ebx
subl %ecx, %ebx
movl %ebx, %ebx
movl %ebx, -16(%ebp)

movl -16(%ebp), %ebx

cmp %ebx, %esi
jg L11
L19:
movl 8(%ebp), %ebx
movl -8(%ebx), %ecx
movl $4, %edx
movl %esi, %ebx
imul %edx, %ebx
movl %ecx, %ecx
addl %ebx, %ecx
movl (%ecx), %ebx
movl $0, %ecx
cmp %ecx, %ebx
je ifTrueL1
ifFalseL1:
movl $0, %ebx
movl %ebx, %ebx
L12:
movl $0, %ecx
cmp %ecx, %ebx
jne ifTrueL2
ifFalseL2:
movl $0, %ecx
movl %ecx, %ecx
L15:
movl $0, %ebx
cmp %ebx, %ecx
jne ifTrueL3
ifFalseL3:
movl -16(%ebp), %ebx

cmp %ebx, %esi
je L11
L20:
movl $1, %ecx
movl %esi, %ebx
addl %ecx, %ebx
movl %ebx, %esi
jmp L19
ifTrueL4:
movl 8(%ebp), %eax
pushl %eax
call printboard
movl %eax, %ebx
movl %ebx, %ebx
L21:
movl %ebx, %eax
jmp L24
ifTrueL1:
movl $1, %ebx
movl %ebx, %ebx
movl 8(%ebp), %ecx
movl -16(%ecx), %edi
movl 12(%ebp), %edx
movl %esi, %ecx
addl %edx, %ecx
movl $4, %edx
movl %ecx, %ecx
imul %edx, %ecx
movl %edi, %edi
addl %ecx, %edi
movl (%edi), %ecx
movl $0, %edx
cmp %edx, %ecx
je L13
L14:
movl $0, %ebx
movl %ebx, %ebx
L13:
movl %ebx, %ebx
jmp L12
ifTrueL2:
movl $1, %ecx
movl %ecx, %ecx
movl 8(%ebp), %ebx
movl -20(%ebx), %ebx
movl $7, %edi
movl %esi, %edx
addl %edi, %edx
movl 12(%ebp), %edi
movl %edx, %edx
subl %edi, %edx
movl $4, %edi
movl %edx, %edx
imul %edi, %edx
movl %ebx, %ebx
addl %edx, %ebx
movl (%ebx), %ebx
movl $0, %edx
cmp %edx, %ebx
je L16
L17:
movl $0, %ecx
movl %ecx, %ecx
L16:
movl %ecx, %ecx
jmp L15
ifTrueL3:
movl $1, %ecx
movl 8(%ebp), %eax
movl -8(%eax), %ebx
movl $4, %edx
movl %esi, %eax
imul %edx, %eax
movl %ebx, %ebx
addl %eax, %ebx
movl %ecx, (%ebx)
movl $1, %ecx
movl 8(%ebp), %eax
movl -16(%eax), %ebx
movl 12(%ebp), %edx
movl %esi, %eax
addl %edx, %eax
movl $4, %edx
movl %eax, %eax
imul %edx, %eax
movl %ebx, %ebx
addl %eax, %ebx
movl %ecx, (%ebx)
movl $1, %ebx
movl 8(%ebp), %eax
movl -20(%eax), %ecx
movl $7, %edx
movl %esi, %eax
addl %edx, %eax
movl 12(%ebp), %edx
movl %eax, %eax
subl %edx, %eax
movl $4, %edx
movl %eax, %eax
imul %edx, %eax
movl %ecx, %ecx
addl %eax, %ecx
movl %ebx, (%ecx)
movl 8(%ebp), %eax
movl -12(%eax), %ebx
movl 12(%ebp), %eax
movl $4, %ecx
movl %eax, %eax
imul %ecx, %eax
movl %ebx, %ebx
addl %eax, %ebx
movl %esi, (%ebx)
movl 12(%ebp), %eax
movl $1, %ebx
movl %eax, %eax
addl %ebx, %eax
pushl %eax
movl 8(%ebp), %eax
pushl %eax
call try
movl %eax, %eax
movl $0, %edx
movl 8(%ebp), %ebx
movl -8(%ebx), %ecx
movl $4, %edi
movl %esi, %ebx
imul %edi, %ebx
movl %ecx, %ecx
addl %ebx, %ecx
movl %edx, (%ecx)
movl $0, %edx
movl 8(%ebp), %ebx
movl -16(%ebx), %edi
movl 12(%ebp), %ecx
movl %esi, %ebx
addl %ecx, %ebx
movl $4, %ecx
movl %ebx, %ebx
imul %ecx, %ebx
movl %edi, %edi
addl %ebx, %edi
movl %edx, (%edi)
movl $0, %edx
movl 8(%ebp), %ebx
movl -20(%ebx), %ecx
movl $7, %ebx
movl %esi, %edi
addl %ebx, %edi
movl 12(%ebp), %ebx
movl %edi, %edi
subl %ebx, %edi
movl $4, %ebx
movl %edi, %edi
imul %ebx, %edi
movl %ecx, %ebx
addl %edi, %ebx
movl %edx, (%ebx)
jmp ifFalseL3
L11:
movl $0, %ebx
movl %ebx, %ebx
jmp L21
L24:
movl -12(%ebp), %edi

movl %edi, %edi
movl -8(%ebp), %esi

movl %esi, %esi
movl -4(%ebp), %ebx

movl %ebx, %ebx

leave
ret

.text
.global printboard
.type printboard, @function
printboard:
pushl %ebp
movl %esp,%ebp
subl $16,%esp
movl %ebx, %ebx
movl %ebx, -4(%ebp)

movl %esi, %esi
movl %esi, -8(%ebp)

movl %edi, %edi
movl %edi, -12(%ebp)

L27:
movl $0, %eax
movl %eax, %eax
movl %eax, -16(%ebp)

movl 8(%ebp), %eax
movl -4(%eax), %esi
movl $1, %eax
movl %esi, %esi
subl %eax, %esi
movl %esi, %esi
movl -16(%ebp), %eax

cmp %esi, %eax
jg L0
L8:
movl $0, %ebx
movl %ebx, %ebx
movl 8(%ebp), %eax
movl -4(%eax), %edi
movl $1, %eax
movl %edi, %edi
subl %eax, %edi
movl %edi, %edi
cmp %edi, %ebx
jg L1
L5:
movl 8(%ebp), %eax
movl -12(%eax), %ecx
movl $4, %eax
movl -16(%ebp), %edx

movl %edx, %edx
imul %eax, %edx
movl %ecx, %ecx
addl %edx, %ecx
movl (%ecx), %eax
cmp %ebx, %eax
je ifTrueL0
ifFalseL0:
movl $L3, %eax
movl %eax, %eax
L4:
pushl %eax
call print
movl %eax, %eax
cmp %edi, %ebx
je L1
L6:
movl $1, %eax
movl %ebx, %ebx
addl %eax, %ebx
movl %ebx, %ebx
jmp L5
ifTrueL0:
movl $L2, %eax
movl %eax, %eax
jmp L4
L1:
movl $L7, %eax
pushl %eax
call print
movl %eax, %eax
movl -16(%ebp), %eax

cmp %esi, %eax
je L0
L9:
movl $1, %ebx
movl -16(%ebp), %eax

movl %eax, %eax
addl %ebx, %eax
movl %eax, %eax
movl %eax, -16(%ebp)

jmp L8
L0:
movl $L10, %eax
pushl %eax
call print
movl %eax, %eax
movl %eax, %eax
jmp L26
L26:
movl -12(%ebp), %edi

movl %edi, %edi
movl -8(%ebp), %esi

movl %esi, %esi
movl -4(%ebp), %ebx

movl %ebx, %ebx

leave
ret

.section .rodata
L10:
.int 1
.string "\n"
.section .rodata
L7:
.int 1
.string "\n"
.section .rodata
L3:
.int 2
.string " ."
.section .rodata
L2:
.int 2
.string " O"
