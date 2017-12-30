.text
.global tigermain
.type tigermain, @function
tigermain:
pushl %ebp
movl %esp,%ebp
subl $24,%esp
movl %ebx, -24(%ebp)
L25:
movl $8, %eax
movl %eax, -4(%ebp)    N=8 ebp-4
movl $-8, %eax
movl %ebp, %ebx
addl %eax, %ebx        ebp-8
movl $0, %eax          init=0
pushl %eax     
movl -4(%ebp), %eax    N
pushl %eax
call initArray         initArray 8 0
movl %eax, (%ebx)      row ebp-8
movl $-12, %ebx
movl %ebp, %eax
addl %ebx, %eax        ebp-12 eax
movl $0, %ebx
pushl %ebx             init=0
movl -4(%ebp), %ebx    N
pushl %ebx
call initArray         initArray(N,0)
movl %eax, (%eax)
movl $-16, %ebx
movl %ebp, %eax
addl %ebx, %eax
movl $0, %ebx
pushl %ebx
movl -4(%ebp), %ebx
movl -4(%ebp), %ecx
addl %ecx, %ebx
movl $1, %ecx
subl %ecx, %ebx
pushl %ebx
call initArray
movl %eax, (%eax)
movl $-20, %ebx
movl %ebp, %eax
addl %ebx, %eax
movl $0, %ebx
pushl %ebx
movl -4(%ebp), %ebx
movl -4(%ebp), %ecx
addl %ecx, %ebx
movl $1, %ecx
subl %ecx, %ebx
pushl %ebx
call initArray
movl %eax, (%eax)
movl $0, %eax
pushl %eax
pushl %ebp
call try
jmp L24
L24:
movl -24(%ebp), %ebx
leave
ret
.text
.global try
.type try, @function
try:
pushl %ebp
movl %esp,%ebp
subl $16,%esp
movl %ebx, %eax
movl %eax, -4(%ebp)
movl %esi, %eax
movl %eax, -8(%ebp)
movl %edi, %eax
movl %eax, -12(%ebp)
L27:
movl $L12, %eax
pushl %eax
call print
call flush
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
subl %ecx, %ebx
movl %ebx, -16(%ebp)
movl -16(%ebp), %ebx
cmp %ebx, %esi
jg L13
L21:
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
L14:
movl $0, %ecx
cmp %ecx, %ebx
jne ifTrueL2
ifFalseL2:
movl $0, %ecx
movl %ecx, %ecx
L17:
movl $0, %ebx
cmp %ebx, %ecx
jne ifTrueL3
ifFalseL3:
movl -16(%ebp), %ebx
cmp %ebx, %esi
je L13
L22:
movl $1, %ecx
movl %esi, %ebx
addl %ecx, %ebx
movl %ebx, %esi
jmp L21
ifTrueL4:
movl 8(%ebp), %eax
pushl %eax
call printboard
movl %eax, %ebx
L23:
movl %ebx, %eax
jmp L26
ifTrueL1:
movl $1, %ebx
movl 8(%ebp), %ecx
movl -16(%ecx), %edi
movl 12(%ebp), %edx
movl %esi, %ecx
addl %edx, %ecx
movl $4, %edx
movl %ecx, %ecx
imul %edx, %ecx
addl %ecx, %edi
movl (%edi), %ecx
movl $0, %edx
cmp %edx, %ecx
je L15
L16:
movl $0, %ebx
L15:
jmp L14
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
addl %edx, %ebx
movl (%ebx), %ebx
movl $0, %edx
cmp %edx, %ebx
je L18
L19:
movl $0, %ecx
movl %ecx, %ecx
L18:
movl %ecx, %ecx
jmp L17
ifTrueL3:
movl $1, %ecx
movl 8(%ebp), %eax
movl -8(%eax), %ebx
movl $4, %edx
movl %esi, %eax
imul %edx, %eax
addl %eax, %ebx
movl %ecx, (%ebx)
movl $1, %ecx
movl 8(%ebp), %eax
movl -16(%eax), %ebx
movl 12(%ebp), %edx
movl %esi, %eax
addl %edx, %eax
movl $4, %edx
imul %edx, %eax
addl %eax, %ebx
movl %ecx, (%ebx)
movl $1, %ebx
movl 8(%ebp), %eax
movl -20(%eax), %ecx
movl $7, %edx
movl %esi, %eax
addl %edx, %eax
movl 12(%ebp), %edx
subl %edx, %eax
movl $4, %edx
imul %edx, %eax
movl %ecx, %ecx
addl %eax, %ecx
movl %ebx, (%ecx)
movl 8(%ebp), %eax
movl -12(%eax), %ebx
movl 12(%ebp), %eax
movl $4, %ecx
imul %ecx, %eax
addl %eax, %ebx
movl %esi, (%ebx)
movl 12(%ebp), %eax
movl $1, %ebx
addl %ebx, %eax
pushl %eax
movl 8(%ebp), %eax
pushl %eax
call try
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
imul %ecx, %ebx
addl %ebx, %edi
movl %edx, (%edi)
movl $0, %edx
movl 8(%ebp), %ebx
movl -20(%ebx), %ecx
movl $7, %ebx
movl %esi, %edi
addl %ebx, %edi
movl 12(%ebp), %ebx
subl %ebx, %edi
movl $4, %ebx
imul %ebx, %edi
movl %ecx, %ebx
addl %edi, %ebx
movl %edx, (%ebx)
jmp ifFalseL3
L13:
movl $0, %ebx
jmp L23
L26:
movl -12(%ebp), %edi
movl -8(%ebp), %esi
movl -4(%ebp), %ebx
leave
ret
.section .rodata
L12:
.int 14
.string "[queens][try]\n"
.text
.global printboard
.type printboard, @function
printboard:
pushl %ebp
movl %esp,%ebp
subl $16,%esp
movl %ebx, -4(%ebp)
movl %esi, -8(%ebp)
movl %edi, -12(%ebp)
L29:
movl $L0, %eax
pushl %eax
call print
call flush
movl $0, %eax
movl %eax, -16(%ebp)
movl 8(%ebp), %eax
movl -4(%eax), %esi
movl $1, %eax
subl %eax, %esi
movl -16(%ebp), %eax
cmp %esi, %eax
jg L1
L9:
movl $0, %ebx
movl 8(%ebp), %eax
movl -4(%eax), %edi
movl $1, %eax
subl %eax, %edi
cmp %edi, %ebx
jg L2
L6:
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
movl $L4, %eax
L5:
pushl %eax
call print
cmp %edi, %ebx
je L2
L7:
movl $1, %eax
addl %eax, %ebx
jmp L6
ifTrueL0:
movl $L3, %eax
jmp L5
L2:
movl $L8, %eax
pushl %eax
call print
movl -16(%ebp), %eax
cmp %esi, %eax
je L1
L10:
movl $1, %ebx
movl -16(%ebp), %eax
addl %ebx, %eax
movl %eax, -16(%ebp)
jmp L9
L1:
movl $L11, %eax
pushl %eax
call print
jmp L28
L28:
movl -12(%ebp), %edi
movl -8(%ebp), %esi
movl -4(%ebp), %ebx
leave
ret
.section .rodata
L11:
.int 1
.string "\n"
.section .rodata
L8:
.int 1
.string "\n"
.section .rodata
L4:
.int 2
.string " ."
.section .rodata
L3:
.int 2
.string " O"
.section .rodata
L0:
.int 14
.string "[queens][try]\n"
