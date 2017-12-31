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
L10:
pushl %ebp
call try
movl %eax, %eax
movl %eax, %eax
jmp L9
L9:
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
L12:
movl $100, %eax
pushl %eax
call printi
movl %eax, %eax
movl $L1, %eax
pushl %eax
call print
movl %eax, %eax
movl $100, %eax
pushl %eax
movl 8(%ebp), %eax
pushl %eax
call dec2bin
movl %eax, %eax
movl $L2, %eax
pushl %eax
call print
movl %eax, %eax
movl $200, %eax
pushl %eax
call printi
movl %eax, %eax
movl $L3, %eax
pushl %eax
call print
movl %eax, %eax
movl $200, %eax
pushl %eax
movl 8(%ebp), %eax
pushl %eax
call dec2bin
movl %eax, %eax
movl $L4, %eax
pushl %eax
call print
movl %eax, %eax
movl $789, %eax
pushl %eax
call printi
movl %eax, %eax
movl $L5, %eax
pushl %eax
call print
movl %eax, %eax
movl $789, %eax
pushl %eax
movl 8(%ebp), %eax
pushl %eax
call dec2bin
movl %eax, %eax
movl $L6, %eax
pushl %eax
call print
movl %eax, %eax
movl $567, %eax
pushl %eax
call printi
movl %eax, %eax
movl $L7, %eax
pushl %eax
call print
movl %eax, %eax
movl $567, %eax
pushl %eax
movl 8(%ebp), %eax
pushl %eax
call dec2bin
movl %eax, %eax
movl $L8, %eax
pushl %eax
call print
movl %eax, %eax
movl %eax, %eax
jmp L11
L11:
movl %edi, %edi
movl %esi, %esi
movl %ebx, %ebx

leave
ret

.section .rodata
L8:
.int 1
.string "\n"
.section .rodata
L7:
.int 4
.string "\t->\t"
.section .rodata
L6:
.int 1
.string "\n"
.section .rodata
L5:
.int 4
.string "\t->\t"
.section .rodata
L4:
.int 1
.string "\n"
.section .rodata
L3:
.int 4
.string "\t->\t"
.section .rodata
L2:
.int 1
.string "\n"
.section .rodata
L1:
.int 4
.string "\t->\t"
.text
.global dec2bin
.type dec2bin, @function
dec2bin:
pushl %ebp
movl %esp,%ebp
subl $4,%esp
movl %ebx, %ebx
movl %ebx, -4(%ebp)

movl %esi, %esi
movl %edi, %edi
L14:
movl 12(%ebp), %eax
movl $0, %ebx
cmp %ebx, %eax
jg ifTrueL0
ifFalseL0:
movl $0, %eax
movl %eax, %eax
jmp L13
ifTrueL0:
movl 12(%ebp), %eax
movl $2, %ebx
movl %eax, %eax
cltd
idivl %ebx
movl %eax, %eax
pushl %eax
movl 8(%ebp), %eax
pushl %eax
call dec2bin
movl %eax, %eax
movl 12(%ebp), %ecx
movl 12(%ebp), %eax
movl $2, %ebx
movl %eax, %eax
cltd
idivl %ebx
movl %eax, %eax
movl $2, %ebx
movl %eax, %eax
imul %ebx, %eax
movl %ecx, %ecx
subl %eax, %ecx
pushl %ecx
call printi
movl %eax, %eax
jmp ifFalseL0
L13:
movl %edi, %edi
movl %esi, %esi
movl -4(%ebp), %ebx

movl %ebx, %ebx

leave
ret

