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
L12:
movl $8, %eax
movl %eax, -4(%ebp)
pushl %ebp
call printb
movl %eax, %eax
movl %eax, %eax
jmp L11
L11:
movl %edi, %edi
movl %esi, %esi
movl %ebx, %ebx

leave
ret

.text
.global printb
.type printb, @function
printb:
pushl %ebp
movl %esp,%ebp
subl $16,%esp
movl %ebx, %ebx
movl %ebx, -4(%ebp)

movl %esi, %esi
movl %esi, -8(%ebp)

movl %edi, %edi
movl %edi, -12(%ebp)

L14:
movl $0, %eax
movl %eax, %eax
movl %eax, -16(%ebp)

movl 8(%ebp), %eax
movl -4(%eax), %ebx
movl $1, %eax
movl %ebx, %ebx
subl %eax, %ebx
movl %ebx, %ebx
movl -16(%ebp), %eax

cmp %ebx, %eax
jg L0
L8:
movl $0, %esi
movl %esi, %esi
movl 8(%ebp), %eax
movl -4(%eax), %edi
movl $1, %eax
movl %edi, %edi
subl %eax, %edi
movl %edi, %edi
cmp %edi, %esi
jg L1
L5:
movl -16(%ebp), %eax

cmp %esi, %eax
jg ifTrueL0
ifFalseL0:
movl $L3, %eax
movl %eax, %eax
L4:
pushl %eax
call print
movl %eax, %eax
cmp %edi, %esi
je L1
L6:
movl $1, %eax
movl %esi, %esi
addl %eax, %esi
movl %esi, %esi
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

cmp %ebx, %eax
je L0
L9:
movl $1, %ecx
movl -16(%ebp), %eax

movl %eax, %eax
addl %ecx, %eax
movl %eax, %eax
movl %eax, -16(%ebp)

jmp L8
L0:
movl $L10, %eax
pushl %eax
call print
movl %eax, %eax
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
.int 1
.string "y"
.section .rodata
L2:
.int 1
.string "x"
