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
L1:
call getchar
movl %eax, %eax
movl %eax, %eax
pushl %eax
call print
movl %eax, %eax
movl %eax, %eax
jmp L0
L0:
movl %edi, %edi
movl %esi, %esi
movl %ebx, %ebx

leave
ret

