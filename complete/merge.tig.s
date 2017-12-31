.text
.global tigermain
.type tigermain, @function
tigermain:
pushl %ebp
movl %esp,%ebp
subl $12,%esp
movl %ebx, %ebx
movl %ebx, -8(%ebp)

movl %esi, %esi
movl %esi, -12(%ebp)

movl %edi, %edi
L25:
movl $-4, %eax
movl %ebp, %ebx
addl %eax, %ebx
movl %ebx, %ebx
call getchar
movl %eax, %eax
movl %eax, %eax
movl %eax, (%ebx)
pushl %ebp
call readlist
movl %eax, %eax
movl %eax, %esi
movl $-4, %eax
movl %ebp, %ebx
addl %eax, %ebx
movl %ebx, %ebx
call getchar
movl %eax, %eax
movl %eax, %eax
movl %eax, (%ebx)
pushl %ebp
call readlist
movl %eax, %eax
movl %eax, %eax
movl %ebp, %ebx
pushl %eax
pushl %esi
pushl %ebp
call merge
movl %eax, %eax
movl %eax, %eax
pushl %eax
pushl %ebx
call printlist
movl %eax, %eax
movl %eax, %eax
jmp L24
L24:
movl %edi, %edi
movl -12(%ebp), %ebx

movl %ebx, %esi
movl -8(%ebp), %ebx

movl %ebx, %ebx

leave
ret

.text
.global printlist
.type printlist, @function
printlist:
pushl %ebp
movl %esp,%ebp
subl $0,%esp
movl %ebx, %ebx
movl %esi, %esi
movl %edi, %edi
L27:
movl 12(%ebp), %eax
movl $0, %ecx
cmp %ecx, %eax
je ifTrueL9
ifFalseL9:
movl 12(%ebp), %eax
movl 0(%eax), %eax
pushl %eax
movl 8(%ebp), %eax
pushl %eax
call printint
movl %eax, %eax
movl $L22, %eax
pushl %eax
call print
movl %eax, %eax
movl 12(%ebp), %eax
movl 4(%eax), %eax
pushl %eax
movl 8(%ebp), %eax
pushl %eax
call printlist
movl %eax, %ecx
movl %ecx, %ecx
L23:
movl %ecx, %eax
jmp L26
ifTrueL9:
movl $L21, %eax
pushl %eax
call print
movl %eax, %ecx
movl %ecx, %ecx
jmp L23
L26:
movl %edi, %edi
movl %esi, %esi
movl %ebx, %ebx

leave
ret

.section .rodata
L22:
.int 1
.string " "
.section .rodata
L21:
.int 1
.string "\n"
.text
.global printint
.type printint, @function
printint:
pushl %ebp
movl %esp,%ebp
subl $0,%esp
movl %ebx, %ebx
movl %esi, %esi
movl %edi, %edi
L29:
movl 12(%ebp), %eax
movl $0, %ecx
cmp %ecx, %eax
jl ifTrueL8
ifFalseL8:
movl 12(%ebp), %eax
movl $0, %ecx
cmp %ecx, %eax
jg ifTrueL7
ifFalseL7:
movl $L18, %eax
pushl %eax
call print
movl %eax, %ecx
movl %ecx, %ecx
L19:
movl %ecx, %eax
L20:
movl %eax, %eax
jmp L28
ifTrueL8:
movl $L17, %eax
pushl %eax
call print
movl %eax, %eax
movl $0, %eax
movl 12(%ebp), %ecx
movl %eax, %eax
subl %ecx, %eax
pushl %eax
pushl %ebp
call f
movl %eax, %eax
movl %eax, %eax
jmp L20
ifTrueL7:
movl 12(%ebp), %eax
pushl %eax
pushl %ebp
call f
movl %eax, %ecx
movl %ecx, %ecx
jmp L19
L28:
movl %edi, %edi
movl %esi, %esi
movl %ebx, %ebx

leave
ret

.section .rodata
L18:
.int 1
.string "0"
.section .rodata
L17:
.int 1
.string "-"
.text
.global f
.type f, @function
f:
pushl %ebp
movl %esp,%ebp
subl $4,%esp
movl %ebx, %ebx
movl %ebx, -4(%ebp)

movl %esi, %esi
movl %edi, %edi
L31:
movl 12(%ebp), %eax
movl $0, %ebx
cmp %ebx, %eax
jg ifTrueL6
ifFalseL6:
movl $0, %eax
movl %eax, %eax
jmp L30
ifTrueL6:
movl 12(%ebp), %eax
movl $10, %ebx
movl %eax, %eax
cltd
idivl %ebx
movl %eax, %eax
pushl %eax
movl 8(%ebp), %eax
pushl %eax
call f
movl %eax, %eax
movl 12(%ebp), %ebx
movl 12(%ebp), %eax
movl $10, %ecx
movl %eax, %eax
cltd
idivl %ecx
movl %eax, %eax
movl $10, %ecx
movl %eax, %eax
imul %ecx, %eax
movl %ebx, %ebx
subl %eax, %ebx
movl %ebx, %ebx
movl $L15, %eax
pushl %eax
call ord
movl %eax, %eax
movl %eax, %eax
movl %ebx, %ebx
addl %eax, %ebx
pushl %ebx
call chr
movl %eax, %eax
movl %eax, %eax
pushl %eax
call print
movl %eax, %eax
jmp ifFalseL6
L30:
movl %edi, %edi
movl %esi, %esi
movl -4(%ebp), %ebx

movl %ebx, %ebx

leave
ret

.section .rodata
L15:
.int 1
.string "0"
.text
.global merge
.type merge, @function
merge:
pushl %ebp
movl %esp,%ebp
subl $8,%esp
movl %ebx, %ebx
movl %ebx, -4(%ebp)

movl %esi, %esi
movl %esi, -8(%ebp)

movl %edi, %edi
L33:
movl 12(%ebp), %eax
movl $0, %ebx
cmp %ebx, %eax
je ifTrueL5
ifFalseL5:
movl 16(%ebp), %eax
movl $0, %ebx
cmp %ebx, %eax
je ifTrueL4
ifFalseL4:
movl 12(%ebp), %eax
movl 0(%eax), %eax
movl 16(%ebp), %ebx
movl 0(%ebx), %ebx
cmp %ebx, %eax
jl ifTrueL3
ifFalseL3:
movl $8, %eax
pushl %eax
call allocRecord
movl %eax, %eax
movl %eax, %ebx
movl $4, %eax
movl %ebx, %esi
addl %eax, %esi
movl %esi, %esi
movl 16(%ebp), %eax
movl 4(%eax), %eax
pushl %eax
movl 12(%ebp), %eax
pushl %eax
movl 8(%ebp), %eax
pushl %eax
call merge
movl %eax, %eax
movl %eax, %eax
movl %eax, (%esi)
movl 16(%ebp), %eax
movl 0(%eax), %eax
movl %eax, 0(%ebx)
movl %ebx, %ebx
L12:
movl %ebx, %ebx
L13:
movl %ebx, %ebx
L14:
movl %ebx, %eax
jmp L32
ifTrueL5:
movl 16(%ebp), %ebx
jmp L14
ifTrueL4:
movl 12(%ebp), %ebx
jmp L13
ifTrueL3:
movl $8, %eax
pushl %eax
call allocRecord
movl %eax, %eax
movl %eax, %ebx
movl $4, %eax
movl %ebx, %esi
addl %eax, %esi
movl %esi, %esi
movl 16(%ebp), %eax
pushl %eax
movl 12(%ebp), %eax
movl 4(%eax), %eax
pushl %eax
movl 8(%ebp), %eax
pushl %eax
call merge
movl %eax, %ecx
movl %ecx, %ecx
movl %ecx, (%esi)
movl 12(%ebp), %ecx
movl 0(%ecx), %ecx
movl %ecx, 0(%ebx)
movl %ebx, %ebx
jmp L12
L32:
movl %edi, %edi
movl -8(%ebp), %esi

movl %esi, %esi
movl -4(%ebp), %ebx

movl %ebx, %ebx

leave
ret

.text
.global readlist
.type readlist, @function
readlist:
pushl %ebp
movl %esp,%ebp
subl $12,%esp
movl %ebx, %ebx
movl %ebx, -4(%ebp)

movl %esi, %esi
movl %esi, -8(%ebp)

movl %edi, %edi
movl %edi, -12(%ebp)

L35:
movl $4, %eax
pushl %eax
call allocRecord
movl %eax, %ebx
movl %ebx, %ebx
movl $0, %eax
movl %eax, 0(%ebx)
movl %ebx, %ebx
pushl %ebx
movl 8(%ebp), %eax
pushl %eax
call readint
movl %eax, %esi
movl %esi, %esi
movl 0(%ebx), %eax
movl $0, %ebx
cmp %ebx, %eax
jne ifTrueL2
ifFalseL2:
movl $0, %ebx
movl %ebx, %ebx
L11:
movl %ebx, %eax
jmp L34
ifTrueL2:
movl $8, %eax
pushl %eax
call allocRecord
movl %eax, %ebx
movl %ebx, %ebx
movl $4, %eax
movl %ebx, %edi
addl %eax, %edi
movl %edi, %edi
movl 8(%ebp), %eax
pushl %eax
call readlist
movl %eax, %ecx
movl %ecx, %ecx
movl %ecx, (%edi)
movl %esi, 0(%ebx)
movl %ebx, %ebx
jmp L11
L34:
movl -12(%ebp), %edi

movl %edi, %edi
movl -8(%ebp), %esi

movl %esi, %esi
movl -4(%ebp), %ebx

movl %ebx, %ebx

leave
ret

.text
.global readint
.type readint, @function
readint:
pushl %ebp
movl %esp,%ebp
subl $8,%esp
movl %ebx, %ebx
movl %ebx, -4(%ebp)

movl %esi, %esi
movl %esi, -8(%ebp)

movl %edi, %edi
L37:
movl $0, %ebx
movl %ebx, %ebx
pushl %ebp
call skipto
movl %eax, %eax
movl 12(%ebp), %esi
movl $0, %eax
movl %esi, %esi
addl %eax, %esi
movl %esi, %esi
movl 8(%ebp), %eax
movl -4(%eax), %eax
pushl %eax
pushl %ebp
call isdigit
movl %eax, %eax
movl %eax, %eax
movl %eax, (%esi)
wTestL1:
movl 8(%ebp), %eax
movl -4(%eax), %eax
pushl %eax
pushl %ebp
call isdigit
movl %eax, %eax
movl %eax, %eax
movl $0, %ecx
cmp %ecx, %eax
jne wLoopL1
wDoneL1:
movl %ebx, %eax
jmp L36
wLoopL1:
movl $10, %eax
movl %ebx, %ebx
imul %eax, %ebx
movl %ebx, %ebx
movl 8(%ebp), %eax
movl -4(%eax), %eax
pushl %eax
call ord
movl %eax, %eax
movl %eax, %eax
movl %ebx, %ebx
addl %eax, %ebx
movl %ebx, %ebx
movl $L10, %eax
pushl %eax
call ord
movl %eax, %eax
movl %eax, %eax
movl %ebx, %ebx
subl %eax, %ebx
movl %ebx, %ebx
movl 8(%ebp), %esi
movl $-4, %eax
movl %esi, %esi
addl %eax, %esi
movl %esi, %esi
call getchar
movl %eax, %ecx
movl %ecx, %ecx
movl %ecx, (%esi)
jmp wTestL1
L36:
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
.string "0"
.text
.global skipto
.type skipto, @function
skipto:
pushl %ebp
movl %esp,%ebp
subl $4,%esp
movl %ebx, %ebx
movl %ebx, -4(%ebp)

movl %esi, %esi
movl %edi, %edi
wTestL0:
movl $L5, %eax
pushl %eax
movl 8(%ebp), %eax
movl 8(%eax), %eax
movl -4(%eax), %eax
pushl %eax
call stringEqual
movl %eax, %eax
movl %eax, %eax
movl $1, %ebx
cmp %ebx, %eax
je ifTrueL1
ifFalseL1:
movl $1, %ebx
movl %ebx, %ebx
movl $L6, %eax
pushl %eax
movl 8(%ebp), %eax
movl 8(%eax), %eax
movl -4(%eax), %eax
pushl %eax
call stringEqual
movl %eax, %eax
movl %eax, %eax
movl $1, %ecx
cmp %ecx, %eax
je L8
L9:
movl $0, %ebx
movl %ebx, %ebx
L8:
movl %ebx, %ebx
L7:
movl $0, %eax
cmp %eax, %ebx
jne wLoopL0
wDoneL0:
movl $0, %eax
movl %eax, %eax
jmp L38
ifTrueL1:
movl $1, %ebx
movl %ebx, %ebx
jmp L7
wLoopL0:
movl 8(%ebp), %eax
movl 8(%eax), %ebx
movl $-4, %eax
movl %ebx, %ebx
addl %eax, %ebx
movl %ebx, %ebx
call getchar
movl %eax, %ecx
movl %ecx, %ecx
movl %ecx, (%ebx)
jmp wTestL0
L38:
movl %edi, %edi
movl %esi, %esi
movl -4(%ebp), %ebx

movl %ebx, %ebx

leave
ret

.section .rodata
L6:
.int 1
.string "\n"
.section .rodata
L5:
.int 1
.string " "
.text
.global isdigit
.type isdigit, @function
isdigit:
pushl %ebp
movl %esp,%ebp
subl $8,%esp
movl %ebx, %ebx
movl %ebx, -4(%ebp)

movl %esi, %esi
movl %esi, -8(%ebp)

movl %edi, %edi
L40:
movl 8(%ebp), %eax
movl 8(%eax), %eax
movl -4(%eax), %eax
pushl %eax
call ord
movl %eax, %eax
movl %eax, %eax
movl %eax, %ebx
movl $L0, %eax
pushl %eax
call ord
movl %eax, %eax
movl %eax, %eax
cmp %eax, %ebx
jge ifTrueL0
ifFalseL0:
movl $0, %esi
movl %esi, %esi
L2:
movl %esi, %eax
jmp L39
ifTrueL0:
movl $1, %esi
movl %esi, %esi
movl 8(%ebp), %eax
movl 8(%eax), %eax
movl -4(%eax), %eax
pushl %eax
call ord
movl %eax, %ebx
movl %ebx, %ebx
movl %ebx, %ebx
movl $L1, %eax
pushl %eax
call ord
movl %eax, %ecx
movl %ecx, %ecx
cmp %ecx, %ebx
jle L3
L4:
movl $0, %esi
movl %esi, %esi
L3:
movl %esi, %esi
jmp L2
L39:
movl %edi, %edi
movl -8(%ebp), %esi

movl %esi, %esi
movl -4(%ebp), %ebx

movl %ebx, %ebx

leave
ret

.section .rodata
L1:
.int 1
.string "9"
.section .rodata
L0:
.int 1
.string "0"
