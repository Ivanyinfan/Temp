.text
.global tigermain
.type tigermain, @function
tigermain:
pushl %ebp
movl %esp,%ebp
subl $16,%esp
movl %ebx, %ebx
movl %ebx, -8(%ebp)
movl %esi, %esi
movl %esi, -12(%ebp)
movl %edi, %edi
movl %edi, -16(%ebp)
L45:
movl $-4, %ebx
movl %ebp, %eax
addl %ebx, %eax
movl %eax, %eax
call getchar
movl %eax, %eax
movl %eax, %eax
movl %eax, (%eax)
pushl %ebp
call L21
movl %eax, %ebx
movl %ebx, %ebx
movl $-4, %eax
movl %ebp, %esi
addl %eax, %esi
movl %esi, %esi
call getchar
movl %eax, %eax
movl %eax, %eax
movl %eax, (%esi)
pushl %ebp
call L21
movl %eax, %esi
movl %esi, %esi
movl $L43, %eax
pushl %eax
call print
movl %eax, %eax
movl %ebp, %edi
pushl %esi
pushl %ebx
pushl %ebp
call L22
movl %eax, %eax
movl %eax, %eax
pushl %eax
pushl %edi
call L24
movl %eax, %eax
movl %eax, %eax
jmp L44
L44:
movl -16(%ebp), %edi
movl %edi, %edi
movl -12(%ebp), %ebx
movl %ebx, %esi
movl -8(%ebp), %ebx
movl %ebx, %ebx

leave
ret

.section .rodata
L43:
.int 10
.string "tigermain\n"
.text
.global L24
.type L24, @function
L24:
pushl %ebp
movl %esp,%ebp
subl $0,%esp
movl %ebx, %ebx
movl %esi, %esi
movl %edi, %edi
L47:
movl $L39, %eax
pushl %eax
call print
movl %eax, %eax
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
call L23
movl %eax, %eax
movl $L41, %eax
pushl %eax
call print
movl %eax, %eax
movl 12(%ebp), %eax
movl 4(%eax), %eax
pushl %eax
movl 8(%ebp), %eax
pushl %eax
call L24
movl %eax, %ecx
movl %ecx, %ecx
L42:
movl %ecx, %eax
jmp L46
ifTrueL9:
movl $L40, %eax
pushl %eax
call print
movl %eax, %ecx
movl %ecx, %ecx
jmp L42
L46:
movl %edi, %edi
movl %esi, %esi
movl %ebx, %ebx

leave
ret

.section .rodata
L41:
.int 1
.string " "
.section .rodata
L40:
.int 1
.string "\n"
.section .rodata
L39:
.int 10
.string "printlist\n"
.text
.global L23
.type L23, @function
L23:
pushl %ebp
movl %esp,%ebp
subl $0,%esp
movl %ebx, %ebx
movl %esi, %esi
movl %edi, %edi
L49:
movl $L34, %eax
pushl %eax
call print
movl %eax, %eax
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
movl $L36, %eax
pushl %eax
call print
movl %eax, %ecx
movl %ecx, %ecx
L37:
movl %ecx, %eax
L38:
movl %eax, %eax
jmp L48
ifTrueL8:
movl $L35, %eax
pushl %eax
call print
movl %eax, %eax
movl $0, %eax
movl 12(%ebp), %ecx
movl %eax, %eax
subl %ecx, %eax
pushl %eax
pushl %ebp
call L31
movl %eax, %eax
movl %eax, %eax
jmp L38
ifTrueL7:
movl 12(%ebp), %eax
pushl %eax
pushl %ebp
call L31
movl %eax, %ecx
movl %ecx, %ecx
jmp L37
L48:
movl %edi, %edi
movl %esi, %esi
movl %ebx, %ebx

leave
ret

.section .rodata
L36:
.int 1
.string "0"
.section .rodata
L35:
.int 1
.string "-"
.section .rodata
L34:
.int 9
.string "printint\n"
.text
.global L31
.type L31, @function
L31:
pushl %ebp
movl %esp,%ebp
subl $4,%esp
movl %ebx, %ebx
movl %ebx, -4(%ebp)
movl %esi, %esi
movl %edi, %edi
L51:
movl 12(%ebp), %eax
movl $0, %ebx
cmp %ebx, %eax
jg ifTrueL6
ifFalseL6:
movl $0, %eax
movl %eax, %eax
jmp L50
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
call L31
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
movl $L32, %eax
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
L50:
movl %edi, %edi
movl %esi, %esi
movl -4(%ebp), %ebx
movl %ebx, %ebx

leave
ret

.section .rodata
L32:
.int 1
.string "0"
.text
.global L22
.type L22, @function
L22:
pushl %ebp
movl %esp,%ebp
subl $8,%esp
movl %ebx, %ebx
movl %ebx, -4(%ebp)
movl %esi, %esi
movl %esi, -8(%ebp)
movl %edi, %edi
L53:
movl $L27, %eax
pushl %eax
call print
movl %eax, %eax
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
call L22
movl %eax, %eax
movl %eax, %eax
movl %eax, (%esi)
movl 16(%ebp), %eax
movl 0(%eax), %eax
movl %eax, 0(%ebx)
movl %ebx, %ebx
L28:
movl %ebx, %ebx
L29:
movl %ebx, %ebx
L30:
movl %ebx, %eax
jmp L52
ifTrueL5:
movl 16(%ebp), %ebx
jmp L30
ifTrueL4:
movl 12(%ebp), %ebx
jmp L29
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
call L22
movl %eax, %ecx
movl %ecx, %ecx
movl %ecx, (%esi)
movl 12(%ebp), %ecx
movl 0(%ecx), %ecx
movl %ecx, 0(%ebx)
movl %ebx, %ebx
jmp L28
L52:
movl %edi, %edi
movl -8(%ebp), %esi
movl %esi, %esi
movl -4(%ebp), %ebx
movl %ebx, %ebx

leave
ret

.section .rodata
L27:
.int 6
.string "merge\n"
.text
.global L21
.type L21, @function
L21:
pushl %ebp
movl %esp,%ebp
subl $12,%esp
movl %ebx, %ebx
movl %ebx, -4(%ebp)
movl %esi, %esi
movl %esi, -8(%ebp)
movl %edi, %edi
movl %edi, -12(%ebp)
L55:
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
call L0
movl %eax, %esi
movl %esi, %esi
movl $L25, %eax
pushl %eax
call print
movl %eax, %eax
movl 0(%ebx), %eax
movl $0, %ebx
cmp %ebx, %eax
jne ifTrueL2
ifFalseL2:
movl $0, %ebx
movl %ebx, %ebx
L26:
movl %ebx, %eax
jmp L54
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
call L21
movl %eax, %ecx
movl %ecx, %ecx
movl %ecx, (%edi)
movl %esi, 0(%ebx)
movl %ebx, %ebx
jmp L26
L54:
movl -12(%ebp), %edi
movl %edi, %edi
movl -8(%ebp), %esi
movl %esi, %esi
movl -4(%ebp), %ebx
movl %ebx, %ebx

leave
ret

.section .rodata
L25:
.int 9
.string "readlist\n"
.text
.global L0
.type L0, @function
L0:
pushl %ebp
movl %esp,%ebp
subl $8,%esp
movl %ebx, %ebx
movl %ebx, -4(%ebp)
movl %esi, %esi
movl %esi, -8(%ebp)
movl %edi, %edi
L57:
movl $0, %ebx
movl %ebx, %ebx
movl $L18, %eax
pushl %eax
call print
movl %eax, %eax
pushl %ebp
call L2
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
call L1
movl %eax, %eax
movl %eax, %eax
movl %eax, (%esi)
L20:
movl 8(%ebp), %eax
movl -4(%eax), %eax
pushl %eax
pushl %ebp
call L1
movl %eax, %eax
movl %eax, %eax
movl $0, %ecx
cmp %ecx, %eax
jne wLoopL1
wDoneL1:
movl %ebx, %eax
jmp L56
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
movl $L19, %eax
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
jmp L20
L56:
movl %edi, %edi
movl -8(%ebp), %esi
movl %esi, %esi
movl -4(%ebp), %ebx
movl %ebx, %ebx

leave
ret

.section .rodata
L19:
.int 1
.string "0"
.section .rodata
L18:
.int 8
.string "readint\n"
.text
.global L2
.type L2, @function
L2:
pushl %ebp
movl %esp,%ebp
subl $4,%esp
movl %ebx, %ebx
movl %ebx, -4(%ebp)
movl %esi, %esi
movl %edi, %edi
L59:
movl $L9, %eax
pushl %eax
call print
movl %eax, %eax
L16:
movl $L10, %eax
pushl %eax
movl 8(%ebp), %eax
movl 8(%eax), %eax
movl -4(%eax), %eax
pushl %eax
call stringEqual
movl %eax, %eax
movl %eax, %eax
movl $0, %ebx
cmp %ebx, %eax
je ifTrueL1
ifFalseL1:
movl $1, %ebx
movl %ebx, %ebx
movl $L11, %eax
pushl %eax
movl 8(%ebp), %eax
movl 8(%eax), %eax
movl -4(%eax), %eax
pushl %eax
call stringEqual
movl %eax, %eax
movl %eax, %eax
movl $0, %ecx
cmp %ecx, %eax
je L13
L14:
movl $0, %ebx
movl %ebx, %ebx
L13:
movl %ebx, %ebx
L12:
movl $0, %eax
cmp %eax, %ebx
jne wLoopL0
wDoneL0:
movl $L17, %eax
pushl %eax
call print
movl %eax, %eax
call flush
movl %eax, %eax
movl %eax, %eax
jmp L58
ifTrueL1:
movl $1, %ebx
movl %ebx, %ebx
jmp L12

wLoopL0:
movl $L15, %eax
pushl %eax
call print
movl %eax, %eax
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
jmp L16
L58:
movl %edi, %edi
movl %esi, %esi
movl -4(%ebp), %ebx
movl %ebx, %ebx

leave
ret

.section .rodata
L17:
.int 16
.string "skiptp complete\n"
.section .rodata
L15:
.int 11
.string "ignoreone\n"
.section .rodata
L11:
.int 1
.string "\n"
.section .rodata
L10:
.int 1
.string " "
.section .rodata
L9:
.int 7
.string "skiptp\n"
.text
.global L1
.type L1, @function
L1:
pushl %ebp
movl %esp,%ebp
subl $8,%esp
movl %ebx, %ebx
movl %ebx, -4(%ebp)
movl %esi, %esi
movl %esi, -8(%ebp)
movl %edi, %edi
L61:
movl $L3, %eax
pushl %eax
call print
movl %eax, %eax
movl 8(%ebp), %eax
movl 8(%eax), %eax
movl -4(%eax), %eax
pushl %eax
call ord
movl %eax, %eax
movl %eax, %eax
movl %eax, %ebx
movl $L4, %eax
pushl %eax
call ord
movl %eax, %eax
movl %eax, %eax
cmp %eax, %ebx
jge ifTrueL0
ifFalseL0:
movl $0, %esi
movl %esi, %esi
L6:
movl %esi, %eax
jmp L60
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
movl $L5, %eax
pushl %eax
call ord
movl %eax, %ecx
movl %ecx, %ecx
cmp %ecx, %ebx
jle L7
L8:
movl $0, %esi
movl %esi, %esi
L7:
movl %esi, %esi
jmp L6
L60:
movl %edi, %edi
movl -8(%ebp), %esi
movl %esi, %esi
movl -4(%ebp), %ebx
movl %ebx, %ebx

leave
ret

.section .rodata
L5:
.int 1
.string "9"
.section .rodata
L4:
.int 1
.string "0"
.section .rodata
L3:
.int 8
.string "isdigit\n"
