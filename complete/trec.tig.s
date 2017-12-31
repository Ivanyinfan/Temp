.text
.global tigermain
.type tigermain, @function
tigermain:
pushl %ebp
movl %esp,%ebp
subl $4,%esp
movl %ebx, %ebx
movl %ebx, -4(%ebp)

movl %esi, %esi
movl %edi, %edi
L1:
movl $8, %eax
pushl %eax
call allocRecord
movl %eax, %ebx
movl %ebx, %ebx
movl $4, %eax
movl %eax, 4(%ebx)
movl $3, %eax
movl %eax, 0(%ebx)
movl %ebx, %ebx
movl 0(%ebx), %eax
pushl %eax
call printi
movl %eax, %eax
movl 4(%ebx), %eax
pushl %eax
call printi
movl %eax, %eax
movl %eax, %eax
jmp L0
L0:
movl %edi, %edi
movl %esi, %esi
movl -4(%ebp), %ebx

movl %ebx, %ebx

leave
ret

