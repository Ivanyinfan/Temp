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
L16:
pushl %ebp
call try
movl %eax, %eax
movl %eax, %eax
jmp L15
L15:
movl %edi, %edi
movl %esi, %esi
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
L18:
movl $56, %eax
pushl %eax
movl 8(%ebp), %eax
pushl %eax
call check
movl %eax, %eax
movl %eax, %eax
pushl %eax
call printi
movl %eax, %eax
movl $L4, %eax
pushl %eax
call print
movl %eax, %eax
movl $23, %eax
pushl %eax
movl 8(%ebp), %eax
pushl %eax
call check
movl %eax, %eax
movl %eax, %eax
pushl %eax
call printi
movl %eax, %eax
movl $L5, %eax
pushl %eax
call print
movl %eax, %eax
movl $71, %eax
pushl %eax
movl 8(%ebp), %eax
pushl %eax
call check
movl %eax, %eax
movl %eax, %eax
pushl %eax
call printi
movl %eax, %eax
movl $L6, %eax
pushl %eax
call print
movl %eax, %eax
movl $72, %eax
pushl %eax
movl 8(%ebp), %eax
pushl %eax
call check
movl %eax, %eax
movl %eax, %eax
pushl %eax
call printi
movl %eax, %eax
movl $L7, %eax
pushl %eax
call print
movl %eax, %eax
movl $173, %eax
pushl %eax
movl 8(%ebp), %eax
pushl %eax
call check
movl %eax, %eax
movl %eax, %eax
pushl %eax
call printi
movl %eax, %eax
movl $L8, %eax
pushl %eax
call print
movl %eax, %eax
movl $181, %eax
pushl %eax
movl 8(%ebp), %eax
pushl %eax
call check
movl %eax, %eax
movl %eax, %eax
pushl %eax
call printi
movl %eax, %eax
movl $L9, %eax
pushl %eax
call print
movl %eax, %eax
movl $281, %eax
pushl %eax
movl 8(%ebp), %eax
pushl %eax
call check
movl %eax, %eax
movl %eax, %eax
pushl %eax
call printi
movl %eax, %eax
movl $L10, %eax
pushl %eax
call print
movl %eax, %eax
movl $659, %eax
pushl %eax
movl 8(%ebp), %eax
pushl %eax
call check
movl %eax, %eax
movl %eax, %eax
pushl %eax
call printi
movl %eax, %eax
movl $L11, %eax
pushl %eax
call print
movl %eax, %eax
movl $729, %eax
pushl %eax
movl 8(%ebp), %eax
pushl %eax
call check
movl %eax, %eax
movl %eax, %eax
pushl %eax
call printi
movl %eax, %eax
movl $L12, %eax
pushl %eax
call print
movl %eax, %eax
movl $947, %eax
pushl %eax
movl 8(%ebp), %eax
pushl %eax
call check
movl %eax, %eax
movl %eax, %eax
pushl %eax
call printi
movl %eax, %eax
movl $L13, %eax
pushl %eax
call print
movl %eax, %eax
movl $945, %eax
pushl %eax
movl 8(%ebp), %eax
pushl %eax
call check
movl %eax, %eax
movl %eax, %eax
pushl %eax
call printi
movl %eax, %eax
movl $L14, %eax
pushl %eax
call print
movl %eax, %eax
movl %eax, %eax
jmp L17
L17:
movl %edi, %edi
movl %esi, %esi
movl %ebx, %ebx

leave
ret

.section .rodata
L14:
.int 1
.string "\n"
.section .rodata
L13:
.int 1
.string "\n"
.section .rodata
L12:
.int 1
.string "\n"
.section .rodata
L11:
.int 1
.string "\n"
.section .rodata
L10:
.int 1
.string "\n"
.section .rodata
L9:
.int 1
.string "\n"
.section .rodata
L8:
.int 1
.string "\n"
.section .rodata
L7:
.int 1
.string "\n"
.section .rodata
L6:
.int 1
.string "\n"
.section .rodata
L5:
.int 1
.string "\n"
.section .rodata
L4:
.int 1
.string "\n"
.text
.global check
.type check, @function
check:
pushl %ebp
movl %esp,%ebp
subl $8,%esp
movl %ebx, %ebx
movl %ebx, -4(%ebp)

movl %esi, %esi
movl %esi, -8(%ebp)

movl %edi, %edi
L20:
movl $1, %ecx
movl %ecx, %ecx
movl $2, %ebx
movl %ebx, %ebx
movl 12(%ebp), %eax
movl $2, %esi
movl %eax, %eax
cltd
idivl %esi
movl %eax, %esi
movl %esi, %esi
cmp %esi, %ebx
jg L0
L2:
movl 12(%ebp), %eax
movl %eax, %eax
cltd
idivl %ebx
movl %eax, %eax
movl %eax, %eax
imul %ebx, %eax
movl 12(%ebp), %edx
cmp %edx, %eax
je ifTrueL0
ifFalseL0:
cmp %esi, %ebx
je L0
L3:
movl $1, %eax
movl %ebx, %ebx
addl %eax, %ebx
movl %ebx, %ebx
jmp L2
ifTrueL0:
movl $0, %ecx
movl %ecx, %ecx
L0:
movl %ecx, %eax
jmp L19
L19:
movl %edi, %edi
movl -8(%ebp), %esi

movl %esi, %esi
movl -4(%ebp), %ebx

movl %ebx, %ebx

leave
ret

