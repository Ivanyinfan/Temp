
obj/user/evilhello2:     file format elf32-i386


Disassembly of section .text:

00800020 <_start>:
// starts us running when we are initially loaded into a new environment.
.text
.globl _start
_start:
	// See if we were started with arguments on the stack
	cmpl $USTACKTOP, %esp
  800020:	81 fc 00 e0 bf ee    	cmp    $0xeebfe000,%esp
	jne args_exist
  800026:	75 04                	jne    80002c <args_exist>

	// If not, push dummy argc/argv arguments.
	// This happens when we are loaded by the kernel,
	// because the kernel does not know about passing arguments.
	pushl $0
  800028:	6a 00                	push   $0x0
	pushl $0
  80002a:	6a 00                	push   $0x0

0080002c <args_exist>:

args_exist:
	call libmain
  80002c:	e8 60 00 00 00       	call   800091 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <evil>:
#include <inc/x86.h>


// Call this function with ring0 privilege
void evil()
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	// Kernel memory access
	*(char*)0xf010000a = 0;
  800036:	c6 05 0a 00 10 f0 00 	movb   $0x0,0xf010000a
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
  80003d:	ba f8 03 00 00       	mov    $0x3f8,%edx
  800042:	b8 49 00 00 00       	mov    $0x49,%eax
  800047:	ee                   	out    %al,(%dx)
  800048:	b8 4e 00 00 00       	mov    $0x4e,%eax
  80004d:	ee                   	out    %al,(%dx)
  80004e:	b8 20 00 00 00       	mov    $0x20,%eax
  800053:	ee                   	out    %al,(%dx)
  800054:	b8 52 00 00 00       	mov    $0x52,%eax
  800059:	ee                   	out    %al,(%dx)
  80005a:	b8 49 00 00 00       	mov    $0x49,%eax
  80005f:	ee                   	out    %al,(%dx)
  800060:	b8 4e 00 00 00       	mov    $0x4e,%eax
  800065:	ee                   	out    %al,(%dx)
  800066:	b8 47 00 00 00       	mov    $0x47,%eax
  80006b:	ee                   	out    %al,(%dx)
  80006c:	b8 30 00 00 00       	mov    $0x30,%eax
  800071:	ee                   	out    %al,(%dx)
  800072:	b8 21 00 00 00       	mov    $0x21,%eax
  800077:	ee                   	out    %al,(%dx)
  800078:	ee                   	out    %al,(%dx)
  800079:	ee                   	out    %al,(%dx)
  80007a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80007f:	ee                   	out    %al,(%dx)
	outb(0x3f8, '0');
	outb(0x3f8, '!');
	outb(0x3f8, '!');
	outb(0x3f8, '!');
	outb(0x3f8, '\n');
}
  800080:	5d                   	pop    %ebp
  800081:	c3                   	ret    

00800082 <ring0_call>:
{
	__asm __volatile("sgdt %0" :  "=m" (*gdtd));
}

// Invoke a given function pointer with ring0 privilege, then return to ring3
void ring0_call(void (*fun_ptr)(void)) {
  800082:	55                   	push   %ebp
  800083:	89 e5                	mov    %esp,%ebp
    // Hint : use a wrapper function to call fun_ptr. Feel free
    //        to add any functions or global variables in this 
    //        file if necessary.

    // Lab3 : Your Code Here
}
  800085:	5d                   	pop    %ebp
  800086:	c3                   	ret    

00800087 <umain>:

void
umain(int argc, char **argv)
{
  800087:	55                   	push   %ebp
  800088:	89 e5                	mov    %esp,%ebp
        // call the evil function in ring0
	ring0_call(&evil);

	// call the evil function in ring3
	evil();
  80008a:	e8 a4 ff ff ff       	call   800033 <evil>
}
  80008f:	5d                   	pop    %ebp
  800090:	c3                   	ret    

00800091 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800091:	55                   	push   %ebp
  800092:	89 e5                	mov    %esp,%ebp
  800094:	83 ec 08             	sub    $0x8,%esp
  800097:	8b 45 08             	mov    0x8(%ebp),%eax
  80009a:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  80009d:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  8000a4:	00 00 00 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000a7:	85 c0                	test   %eax,%eax
  8000a9:	7e 08                	jle    8000b3 <libmain+0x22>
		binaryname = argv[0];
  8000ab:	8b 0a                	mov    (%edx),%ecx
  8000ad:	89 0d 00 20 80 00    	mov    %ecx,0x802000

	// call user main routine
	umain(argc, argv);
  8000b3:	83 ec 08             	sub    $0x8,%esp
  8000b6:	52                   	push   %edx
  8000b7:	50                   	push   %eax
  8000b8:	e8 ca ff ff ff       	call   800087 <umain>

	// exit gracefully
	exit();
  8000bd:	e8 05 00 00 00       	call   8000c7 <exit>
}
  8000c2:	83 c4 10             	add    $0x10,%esp
  8000c5:	c9                   	leave  
  8000c6:	c3                   	ret    

008000c7 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000c7:	55                   	push   %ebp
  8000c8:	89 e5                	mov    %esp,%ebp
  8000ca:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000cd:	6a 00                	push   $0x0
  8000cf:	e8 52 00 00 00       	call   800126 <sys_env_destroy>
}
  8000d4:	83 c4 10             	add    $0x10,%esp
  8000d7:	c9                   	leave  
  8000d8:	c3                   	ret    

008000d9 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000d9:	55                   	push   %ebp
  8000da:	89 e5                	mov    %esp,%ebp
  8000dc:	57                   	push   %edi
  8000dd:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8000de:	b8 00 00 00 00       	mov    $0x0,%eax
  8000e3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000e6:	8b 55 08             	mov    0x8(%ebp),%edx
  8000e9:	89 c3                	mov    %eax,%ebx
  8000eb:	89 c7                	mov    %eax,%edi
  8000ed:	51                   	push   %ecx
  8000ee:	52                   	push   %edx
  8000ef:	53                   	push   %ebx
  8000f0:	54                   	push   %esp
  8000f1:	55                   	push   %ebp
  8000f2:	56                   	push   %esi
  8000f3:	57                   	push   %edi
  8000f4:	5f                   	pop    %edi
  8000f5:	5e                   	pop    %esi
  8000f6:	5d                   	pop    %ebp
  8000f7:	5c                   	pop    %esp
  8000f8:	5b                   	pop    %ebx
  8000f9:	5a                   	pop    %edx
  8000fa:	59                   	pop    %ecx

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000fb:	5b                   	pop    %ebx
  8000fc:	5f                   	pop    %edi
  8000fd:	5d                   	pop    %ebp
  8000fe:	c3                   	ret    

008000ff <sys_cgetc>:

int
sys_cgetc(void)
{
  8000ff:	55                   	push   %ebp
  800100:	89 e5                	mov    %esp,%ebp
  800102:	57                   	push   %edi
  800103:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800104:	b9 00 00 00 00       	mov    $0x0,%ecx
  800109:	b8 01 00 00 00       	mov    $0x1,%eax
  80010e:	89 ca                	mov    %ecx,%edx
  800110:	89 cb                	mov    %ecx,%ebx
  800112:	89 cf                	mov    %ecx,%edi
  800114:	51                   	push   %ecx
  800115:	52                   	push   %edx
  800116:	53                   	push   %ebx
  800117:	54                   	push   %esp
  800118:	55                   	push   %ebp
  800119:	56                   	push   %esi
  80011a:	57                   	push   %edi
  80011b:	5f                   	pop    %edi
  80011c:	5e                   	pop    %esi
  80011d:	5d                   	pop    %ebp
  80011e:	5c                   	pop    %esp
  80011f:	5b                   	pop    %ebx
  800120:	5a                   	pop    %edx
  800121:	59                   	pop    %ecx

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800122:	5b                   	pop    %ebx
  800123:	5f                   	pop    %edi
  800124:	5d                   	pop    %ebp
  800125:	c3                   	ret    

00800126 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800126:	55                   	push   %ebp
  800127:	89 e5                	mov    %esp,%ebp
  800129:	57                   	push   %edi
  80012a:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80012b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800130:	b8 03 00 00 00       	mov    $0x3,%eax
  800135:	8b 55 08             	mov    0x8(%ebp),%edx
  800138:	89 d9                	mov    %ebx,%ecx
  80013a:	89 df                	mov    %ebx,%edi
  80013c:	51                   	push   %ecx
  80013d:	52                   	push   %edx
  80013e:	53                   	push   %ebx
  80013f:	54                   	push   %esp
  800140:	55                   	push   %ebp
  800141:	56                   	push   %esi
  800142:	57                   	push   %edi
  800143:	5f                   	pop    %edi
  800144:	5e                   	pop    %esi
  800145:	5d                   	pop    %ebp
  800146:	5c                   	pop    %esp
  800147:	5b                   	pop    %ebx
  800148:	5a                   	pop    %edx
  800149:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  80014a:	85 c0                	test   %eax,%eax
  80014c:	7e 17                	jle    800165 <sys_env_destroy+0x3f>
		panic("syscall %d returned %d (> 0)", num, ret);
  80014e:	83 ec 0c             	sub    $0xc,%esp
  800151:	50                   	push   %eax
  800152:	6a 03                	push   $0x3
  800154:	68 fe 10 80 00       	push   $0x8010fe
  800159:	6a 26                	push   $0x26
  80015b:	68 1b 11 80 00       	push   $0x80111b
  800160:	e8 7f 00 00 00       	call   8001e4 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800165:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800168:	5b                   	pop    %ebx
  800169:	5f                   	pop    %edi
  80016a:	5d                   	pop    %ebp
  80016b:	c3                   	ret    

0080016c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80016c:	55                   	push   %ebp
  80016d:	89 e5                	mov    %esp,%ebp
  80016f:	57                   	push   %edi
  800170:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800171:	b9 00 00 00 00       	mov    $0x0,%ecx
  800176:	b8 02 00 00 00       	mov    $0x2,%eax
  80017b:	89 ca                	mov    %ecx,%edx
  80017d:	89 cb                	mov    %ecx,%ebx
  80017f:	89 cf                	mov    %ecx,%edi
  800181:	51                   	push   %ecx
  800182:	52                   	push   %edx
  800183:	53                   	push   %ebx
  800184:	54                   	push   %esp
  800185:	55                   	push   %ebp
  800186:	56                   	push   %esi
  800187:	57                   	push   %edi
  800188:	5f                   	pop    %edi
  800189:	5e                   	pop    %esi
  80018a:	5d                   	pop    %ebp
  80018b:	5c                   	pop    %esp
  80018c:	5b                   	pop    %ebx
  80018d:	5a                   	pop    %edx
  80018e:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80018f:	5b                   	pop    %ebx
  800190:	5f                   	pop    %edi
  800191:	5d                   	pop    %ebp
  800192:	c3                   	ret    

00800193 <sys_map_kernel_page>:

int
sys_map_kernel_page(void* kpage, void* va)
{
  800193:	55                   	push   %ebp
  800194:	89 e5                	mov    %esp,%ebp
  800196:	57                   	push   %edi
  800197:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800198:	bf 00 00 00 00       	mov    $0x0,%edi
  80019d:	b8 04 00 00 00       	mov    $0x4,%eax
  8001a2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001a5:	8b 55 08             	mov    0x8(%ebp),%edx
  8001a8:	89 fb                	mov    %edi,%ebx
  8001aa:	51                   	push   %ecx
  8001ab:	52                   	push   %edx
  8001ac:	53                   	push   %ebx
  8001ad:	54                   	push   %esp
  8001ae:	55                   	push   %ebp
  8001af:	56                   	push   %esi
  8001b0:	57                   	push   %edi
  8001b1:	5f                   	pop    %edi
  8001b2:	5e                   	pop    %esi
  8001b3:	5d                   	pop    %ebp
  8001b4:	5c                   	pop    %esp
  8001b5:	5b                   	pop    %ebx
  8001b6:	5a                   	pop    %edx
  8001b7:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  8001b8:	5b                   	pop    %ebx
  8001b9:	5f                   	pop    %edi
  8001ba:	5d                   	pop    %ebp
  8001bb:	c3                   	ret    

008001bc <sys_sbrk>:

int
sys_sbrk(uint32_t inc)
{
  8001bc:	55                   	push   %ebp
  8001bd:	89 e5                	mov    %esp,%ebp
  8001bf:	57                   	push   %edi
  8001c0:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8001c1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001c6:	b8 05 00 00 00       	mov    $0x5,%eax
  8001cb:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ce:	89 cb                	mov    %ecx,%ebx
  8001d0:	89 cf                	mov    %ecx,%edi
  8001d2:	51                   	push   %ecx
  8001d3:	52                   	push   %edx
  8001d4:	53                   	push   %ebx
  8001d5:	54                   	push   %esp
  8001d6:	55                   	push   %ebp
  8001d7:	56                   	push   %esi
  8001d8:	57                   	push   %edi
  8001d9:	5f                   	pop    %edi
  8001da:	5e                   	pop    %esi
  8001db:	5d                   	pop    %ebp
  8001dc:	5c                   	pop    %esp
  8001dd:	5b                   	pop    %ebx
  8001de:	5a                   	pop    %edx
  8001df:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  8001e0:	5b                   	pop    %ebx
  8001e1:	5f                   	pop    %edi
  8001e2:	5d                   	pop    %ebp
  8001e3:	c3                   	ret    

008001e4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8001e4:	55                   	push   %ebp
  8001e5:	89 e5                	mov    %esp,%ebp
  8001e7:	56                   	push   %esi
  8001e8:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8001e9:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	if (argv0)
  8001ec:	a1 08 20 80 00       	mov    0x802008,%eax
  8001f1:	85 c0                	test   %eax,%eax
  8001f3:	74 11                	je     800206 <_panic+0x22>
		cprintf("%s: ", argv0);
  8001f5:	83 ec 08             	sub    $0x8,%esp
  8001f8:	50                   	push   %eax
  8001f9:	68 29 11 80 00       	push   $0x801129
  8001fe:	e8 d4 00 00 00       	call   8002d7 <cprintf>
  800203:	83 c4 10             	add    $0x10,%esp
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800206:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80020c:	e8 5b ff ff ff       	call   80016c <sys_getenvid>
  800211:	83 ec 0c             	sub    $0xc,%esp
  800214:	ff 75 0c             	pushl  0xc(%ebp)
  800217:	ff 75 08             	pushl  0x8(%ebp)
  80021a:	56                   	push   %esi
  80021b:	50                   	push   %eax
  80021c:	68 30 11 80 00       	push   $0x801130
  800221:	e8 b1 00 00 00       	call   8002d7 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800226:	83 c4 18             	add    $0x18,%esp
  800229:	53                   	push   %ebx
  80022a:	ff 75 10             	pushl  0x10(%ebp)
  80022d:	e8 54 00 00 00       	call   800286 <vcprintf>
	cprintf("\n");
  800232:	c7 04 24 2e 11 80 00 	movl   $0x80112e,(%esp)
  800239:	e8 99 00 00 00       	call   8002d7 <cprintf>
  80023e:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800241:	cc                   	int3   
  800242:	eb fd                	jmp    800241 <_panic+0x5d>

00800244 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800244:	55                   	push   %ebp
  800245:	89 e5                	mov    %esp,%ebp
  800247:	53                   	push   %ebx
  800248:	83 ec 04             	sub    $0x4,%esp
  80024b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80024e:	8b 13                	mov    (%ebx),%edx
  800250:	8d 42 01             	lea    0x1(%edx),%eax
  800253:	89 03                	mov    %eax,(%ebx)
  800255:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800258:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80025c:	3d ff 00 00 00       	cmp    $0xff,%eax
  800261:	75 1a                	jne    80027d <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800263:	83 ec 08             	sub    $0x8,%esp
  800266:	68 ff 00 00 00       	push   $0xff
  80026b:	8d 43 08             	lea    0x8(%ebx),%eax
  80026e:	50                   	push   %eax
  80026f:	e8 65 fe ff ff       	call   8000d9 <sys_cputs>
		b->idx = 0;
  800274:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80027a:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80027d:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800281:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800284:	c9                   	leave  
  800285:	c3                   	ret    

00800286 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800286:	55                   	push   %ebp
  800287:	89 e5                	mov    %esp,%ebp
  800289:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80028f:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800296:	00 00 00 
	b.cnt = 0;
  800299:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002a0:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002a3:	ff 75 0c             	pushl  0xc(%ebp)
  8002a6:	ff 75 08             	pushl  0x8(%ebp)
  8002a9:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002af:	50                   	push   %eax
  8002b0:	68 44 02 80 00       	push   $0x800244
  8002b5:	e8 45 02 00 00       	call   8004ff <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002ba:	83 c4 08             	add    $0x8,%esp
  8002bd:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8002c3:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002c9:	50                   	push   %eax
  8002ca:	e8 0a fe ff ff       	call   8000d9 <sys_cputs>

	return b.cnt;
}
  8002cf:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002d5:	c9                   	leave  
  8002d6:	c3                   	ret    

008002d7 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002d7:	55                   	push   %ebp
  8002d8:	89 e5                	mov    %esp,%ebp
  8002da:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002dd:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002e0:	50                   	push   %eax
  8002e1:	ff 75 08             	pushl  0x8(%ebp)
  8002e4:	e8 9d ff ff ff       	call   800286 <vcprintf>
	va_end(ap);

	return cnt;
}
  8002e9:	c9                   	leave  
  8002ea:	c3                   	ret    

008002eb <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002eb:	55                   	push   %ebp
  8002ec:	89 e5                	mov    %esp,%ebp
  8002ee:	57                   	push   %edi
  8002ef:	56                   	push   %esi
  8002f0:	53                   	push   %ebx
  8002f1:	83 ec 1c             	sub    $0x1c,%esp
  8002f4:	89 c7                	mov    %eax,%edi
  8002f6:	89 d6                	mov    %edx,%esi
  8002f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8002fb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002fe:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800301:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	// if cprintf'parameter includes pattern of the form "%-", padding
	// space on the right side if neccesary.
	// you can add helper function if needed.
	// your code here:
	int length,showsign=0;
	if(padc=='-'&&num>=base)
  800304:	83 7d 18 2d          	cmpl   $0x2d,0x18(%ebp)
  800308:	0f 85 8a 00 00 00    	jne    800398 <printnum+0xad>
  80030e:	8b 45 10             	mov    0x10(%ebp),%eax
  800311:	ba 00 00 00 00       	mov    $0x0,%edx
  800316:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800319:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80031c:	39 da                	cmp    %ebx,%edx
  80031e:	72 09                	jb     800329 <printnum+0x3e>
  800320:	39 4d 10             	cmp    %ecx,0x10(%ebp)
  800323:	0f 87 87 00 00 00    	ja     8003b0 <printnum+0xc5>
	{
		length=*(int *)putdat;
  800329:	8b 1e                	mov    (%esi),%ebx
		printnum(putch,putdat,num/base,base,0,padc);
  80032b:	83 ec 0c             	sub    $0xc,%esp
  80032e:	6a 2d                	push   $0x2d
  800330:	6a 00                	push   $0x0
  800332:	ff 75 10             	pushl  0x10(%ebp)
  800335:	83 ec 08             	sub    $0x8,%esp
  800338:	52                   	push   %edx
  800339:	50                   	push   %eax
  80033a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80033d:	ff 75 e0             	pushl  -0x20(%ebp)
  800340:	e8 2b 0b 00 00       	call   800e70 <__udivdi3>
  800345:	83 c4 18             	add    $0x18,%esp
  800348:	52                   	push   %edx
  800349:	50                   	push   %eax
  80034a:	89 f2                	mov    %esi,%edx
  80034c:	89 f8                	mov    %edi,%eax
  80034e:	e8 98 ff ff ff       	call   8002eb <printnum>
		while (--width > 0)
			putch(padc, putdat);
	}
	}
	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800353:	83 c4 18             	add    $0x18,%esp
  800356:	56                   	push   %esi
  800357:	8b 45 10             	mov    0x10(%ebp),%eax
  80035a:	ba 00 00 00 00       	mov    $0x0,%edx
  80035f:	83 ec 04             	sub    $0x4,%esp
  800362:	52                   	push   %edx
  800363:	50                   	push   %eax
  800364:	ff 75 e4             	pushl  -0x1c(%ebp)
  800367:	ff 75 e0             	pushl  -0x20(%ebp)
  80036a:	e8 31 0c 00 00       	call   800fa0 <__umoddi3>
  80036f:	83 c4 14             	add    $0x14,%esp
  800372:	0f be 80 53 11 80 00 	movsbl 0x801153(%eax),%eax
  800379:	50                   	push   %eax
  80037a:	ff d7                	call   *%edi
	
	if(padc=='-'&&width>0)
  80037c:	83 c4 10             	add    $0x10,%esp
  80037f:	83 7d 18 2d          	cmpl   $0x2d,0x18(%ebp)
  800383:	0f 85 fa 00 00 00    	jne    800483 <printnum+0x198>
  800389:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
  80038d:	0f 8f 9b 00 00 00    	jg     80042e <printnum+0x143>
  800393:	e9 eb 00 00 00       	jmp    800483 <printnum+0x198>
	}
	else
	{
	
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800398:	8b 45 10             	mov    0x10(%ebp),%eax
  80039b:	ba 00 00 00 00       	mov    $0x0,%edx
  8003a0:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8003a3:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8003a6:	83 fb 00             	cmp    $0x0,%ebx
  8003a9:	77 14                	ja     8003bf <printnum+0xd4>
  8003ab:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  8003ae:	73 0f                	jae    8003bf <printnum+0xd4>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b3:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8003b6:	85 db                	test   %ebx,%ebx
  8003b8:	7f 61                	jg     80041b <printnum+0x130>
  8003ba:	e9 98 00 00 00       	jmp    800457 <printnum+0x16c>
	else
	{
	
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8003bf:	83 ec 0c             	sub    $0xc,%esp
  8003c2:	ff 75 18             	pushl  0x18(%ebp)
  8003c5:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8003c8:	8d 59 ff             	lea    -0x1(%ecx),%ebx
  8003cb:	53                   	push   %ebx
  8003cc:	ff 75 10             	pushl  0x10(%ebp)
  8003cf:	83 ec 08             	sub    $0x8,%esp
  8003d2:	52                   	push   %edx
  8003d3:	50                   	push   %eax
  8003d4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003d7:	ff 75 e0             	pushl  -0x20(%ebp)
  8003da:	e8 91 0a 00 00       	call   800e70 <__udivdi3>
  8003df:	83 c4 18             	add    $0x18,%esp
  8003e2:	52                   	push   %edx
  8003e3:	50                   	push   %eax
  8003e4:	89 f2                	mov    %esi,%edx
  8003e6:	89 f8                	mov    %edi,%eax
  8003e8:	e8 fe fe ff ff       	call   8002eb <printnum>
		while (--width > 0)
			putch(padc, putdat);
	}
	}
	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003ed:	83 c4 18             	add    $0x18,%esp
  8003f0:	56                   	push   %esi
  8003f1:	8b 45 10             	mov    0x10(%ebp),%eax
  8003f4:	ba 00 00 00 00       	mov    $0x0,%edx
  8003f9:	83 ec 04             	sub    $0x4,%esp
  8003fc:	52                   	push   %edx
  8003fd:	50                   	push   %eax
  8003fe:	ff 75 e4             	pushl  -0x1c(%ebp)
  800401:	ff 75 e0             	pushl  -0x20(%ebp)
  800404:	e8 97 0b 00 00       	call   800fa0 <__umoddi3>
  800409:	83 c4 14             	add    $0x14,%esp
  80040c:	0f be 80 53 11 80 00 	movsbl 0x801153(%eax),%eax
  800413:	50                   	push   %eax
  800414:	ff d7                	call   *%edi
  800416:	83 c4 10             	add    $0x10,%esp
  800419:	eb 68                	jmp    800483 <printnum+0x198>
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80041b:	83 ec 08             	sub    $0x8,%esp
  80041e:	56                   	push   %esi
  80041f:	ff 75 18             	pushl  0x18(%ebp)
  800422:	ff d7                	call   *%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800424:	83 c4 10             	add    $0x10,%esp
  800427:	83 eb 01             	sub    $0x1,%ebx
  80042a:	75 ef                	jne    80041b <printnum+0x130>
  80042c:	eb 29                	jmp    800457 <printnum+0x16c>
	putch("0123456789abcdef"[num % base], putdat);
	
	if(padc=='-'&&width>0)
	{
		length=*(int *)putdat-length;
		for(int i=0;i<width-length;++i)
  80042e:	8b 45 14             	mov    0x14(%ebp),%eax
  800431:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800434:	2b 06                	sub    (%esi),%eax
  800436:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800439:	85 c0                	test   %eax,%eax
  80043b:	7e 46                	jle    800483 <printnum+0x198>
  80043d:	bb 00 00 00 00       	mov    $0x0,%ebx
			putch(' ',putdat);
  800442:	83 ec 08             	sub    $0x8,%esp
  800445:	56                   	push   %esi
  800446:	6a 20                	push   $0x20
  800448:	ff d7                	call   *%edi
	putch("0123456789abcdef"[num % base], putdat);
	
	if(padc=='-'&&width>0)
	{
		length=*(int *)putdat-length;
		for(int i=0;i<width-length;++i)
  80044a:	83 c3 01             	add    $0x1,%ebx
  80044d:	83 c4 10             	add    $0x10,%esp
  800450:	3b 5d e0             	cmp    -0x20(%ebp),%ebx
  800453:	75 ed                	jne    800442 <printnum+0x157>
  800455:	eb 2c                	jmp    800483 <printnum+0x198>
		while (--width > 0)
			putch(padc, putdat);
	}
	}
	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800457:	83 ec 08             	sub    $0x8,%esp
  80045a:	56                   	push   %esi
  80045b:	8b 45 10             	mov    0x10(%ebp),%eax
  80045e:	ba 00 00 00 00       	mov    $0x0,%edx
  800463:	83 ec 04             	sub    $0x4,%esp
  800466:	52                   	push   %edx
  800467:	50                   	push   %eax
  800468:	ff 75 e4             	pushl  -0x1c(%ebp)
  80046b:	ff 75 e0             	pushl  -0x20(%ebp)
  80046e:	e8 2d 0b 00 00       	call   800fa0 <__umoddi3>
  800473:	83 c4 14             	add    $0x14,%esp
  800476:	0f be 80 53 11 80 00 	movsbl 0x801153(%eax),%eax
  80047d:	50                   	push   %eax
  80047e:	ff d7                	call   *%edi
  800480:	83 c4 10             	add    $0x10,%esp
	{
		length=*(int *)putdat-length;
		for(int i=0;i<width-length;++i)
			putch(' ',putdat);
	}
}
  800483:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800486:	5b                   	pop    %ebx
  800487:	5e                   	pop    %esi
  800488:	5f                   	pop    %edi
  800489:	5d                   	pop    %ebp
  80048a:	c3                   	ret    

0080048b <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80048b:	55                   	push   %ebp
  80048c:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80048e:	83 fa 01             	cmp    $0x1,%edx
  800491:	7e 0e                	jle    8004a1 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800493:	8b 10                	mov    (%eax),%edx
  800495:	8d 4a 08             	lea    0x8(%edx),%ecx
  800498:	89 08                	mov    %ecx,(%eax)
  80049a:	8b 02                	mov    (%edx),%eax
  80049c:	8b 52 04             	mov    0x4(%edx),%edx
  80049f:	eb 22                	jmp    8004c3 <getuint+0x38>
	else if (lflag)
  8004a1:	85 d2                	test   %edx,%edx
  8004a3:	74 10                	je     8004b5 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8004a5:	8b 10                	mov    (%eax),%edx
  8004a7:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004aa:	89 08                	mov    %ecx,(%eax)
  8004ac:	8b 02                	mov    (%edx),%eax
  8004ae:	ba 00 00 00 00       	mov    $0x0,%edx
  8004b3:	eb 0e                	jmp    8004c3 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8004b5:	8b 10                	mov    (%eax),%edx
  8004b7:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004ba:	89 08                	mov    %ecx,(%eax)
  8004bc:	8b 02                	mov    (%edx),%eax
  8004be:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8004c3:	5d                   	pop    %ebp
  8004c4:	c3                   	ret    

008004c5 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004c5:	55                   	push   %ebp
  8004c6:	89 e5                	mov    %esp,%ebp
  8004c8:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004cb:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004cf:	8b 10                	mov    (%eax),%edx
  8004d1:	3b 50 04             	cmp    0x4(%eax),%edx
  8004d4:	73 0a                	jae    8004e0 <sprintputch+0x1b>
		*b->buf++ = ch;
  8004d6:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004d9:	89 08                	mov    %ecx,(%eax)
  8004db:	8b 45 08             	mov    0x8(%ebp),%eax
  8004de:	88 02                	mov    %al,(%edx)
}
  8004e0:	5d                   	pop    %ebp
  8004e1:	c3                   	ret    

008004e2 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8004e2:	55                   	push   %ebp
  8004e3:	89 e5                	mov    %esp,%ebp
  8004e5:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8004e8:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004eb:	50                   	push   %eax
  8004ec:	ff 75 10             	pushl  0x10(%ebp)
  8004ef:	ff 75 0c             	pushl  0xc(%ebp)
  8004f2:	ff 75 08             	pushl  0x8(%ebp)
  8004f5:	e8 05 00 00 00       	call   8004ff <vprintfmt>
	va_end(ap);
}
  8004fa:	83 c4 10             	add    $0x10,%esp
  8004fd:	c9                   	leave  
  8004fe:	c3                   	ret    

008004ff <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8004ff:	55                   	push   %ebp
  800500:	89 e5                	mov    %esp,%ebp
  800502:	57                   	push   %edi
  800503:	56                   	push   %esi
  800504:	53                   	push   %ebx
  800505:	83 ec 2c             	sub    $0x2c,%esp
  800508:	8b 7d 08             	mov    0x8(%ebp),%edi
  80050b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80050e:	eb 03                	jmp    800513 <vprintfmt+0x14>
			break;
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
			for (fmt--; fmt[-1] != '%'; fmt--)
  800510:	89 75 10             	mov    %esi,0x10(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800513:	8b 45 10             	mov    0x10(%ebp),%eax
  800516:	8d 70 01             	lea    0x1(%eax),%esi
  800519:	0f b6 00             	movzbl (%eax),%eax
  80051c:	83 f8 25             	cmp    $0x25,%eax
  80051f:	74 27                	je     800548 <vprintfmt+0x49>
			if (ch == '\0')
  800521:	85 c0                	test   %eax,%eax
  800523:	75 0d                	jne    800532 <vprintfmt+0x33>
  800525:	e9 8b 04 00 00       	jmp    8009b5 <vprintfmt+0x4b6>
  80052a:	85 c0                	test   %eax,%eax
  80052c:	0f 84 83 04 00 00    	je     8009b5 <vprintfmt+0x4b6>
				return;
			putch(ch, putdat);
  800532:	83 ec 08             	sub    $0x8,%esp
  800535:	53                   	push   %ebx
  800536:	50                   	push   %eax
  800537:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800539:	83 c6 01             	add    $0x1,%esi
  80053c:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  800540:	83 c4 10             	add    $0x10,%esp
  800543:	83 f8 25             	cmp    $0x25,%eax
  800546:	75 e2                	jne    80052a <vprintfmt+0x2b>
			padc = '-';
			goto reswitch;
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800548:	c6 45 e3 20          	movb   $0x20,-0x1d(%ebp)
  80054c:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800553:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80055a:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800561:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  800568:	b9 00 00 00 00       	mov    $0x0,%ecx
  80056d:	eb 07                	jmp    800576 <vprintfmt+0x77>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80056f:	8b 75 10             	mov    0x10(%ebp),%esi

		// flag to show the sign
		case '+':
			padc='+';
  800572:	c6 45 e3 2b          	movb   $0x2b,-0x1d(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800576:	8d 46 01             	lea    0x1(%esi),%eax
  800579:	89 45 10             	mov    %eax,0x10(%ebp)
  80057c:	0f b6 06             	movzbl (%esi),%eax
  80057f:	0f b6 d0             	movzbl %al,%edx
  800582:	83 e8 23             	sub    $0x23,%eax
  800585:	3c 55                	cmp    $0x55,%al
  800587:	0f 87 e9 03 00 00    	ja     800976 <vprintfmt+0x477>
  80058d:	0f b6 c0             	movzbl %al,%eax
  800590:	ff 24 85 5c 12 80 00 	jmp    *0x80125c(,%eax,4)
  800597:	8b 75 10             	mov    0x10(%ebp),%esi
			padc='+';
			goto reswitch;
		
		// flag to pad on the right
		case '-':
			padc = '-';
  80059a:	c6 45 e3 2d          	movb   $0x2d,-0x1d(%ebp)
  80059e:	eb d6                	jmp    800576 <vprintfmt+0x77>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8005a0:	8d 42 d0             	lea    -0x30(%edx),%eax
  8005a3:	89 45 d0             	mov    %eax,-0x30(%ebp)
				ch = *fmt;
  8005a6:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  8005aa:	8d 50 d0             	lea    -0x30(%eax),%edx
  8005ad:	83 fa 09             	cmp    $0x9,%edx
  8005b0:	77 66                	ja     800618 <vprintfmt+0x119>
  8005b2:	8b 75 10             	mov    0x10(%ebp),%esi
  8005b5:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8005b8:	89 7d 08             	mov    %edi,0x8(%ebp)
  8005bb:	eb 09                	jmp    8005c6 <vprintfmt+0xc7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005bd:	8b 75 10             	mov    0x10(%ebp),%esi
			padc = '-';
			goto reswitch;
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8005c0:	c6 45 e3 30          	movb   $0x30,-0x1d(%ebp)
			goto reswitch;
  8005c4:	eb b0                	jmp    800576 <vprintfmt+0x77>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005c6:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  8005c9:	8d 14 92             	lea    (%edx,%edx,4),%edx
  8005cc:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  8005d0:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8005d3:	8d 78 d0             	lea    -0x30(%eax),%edi
  8005d6:	83 ff 09             	cmp    $0x9,%edi
  8005d9:	76 eb                	jbe    8005c6 <vprintfmt+0xc7>
  8005db:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8005de:	8b 7d 08             	mov    0x8(%ebp),%edi
  8005e1:	eb 38                	jmp    80061b <vprintfmt+0x11c>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e6:	8d 50 04             	lea    0x4(%eax),%edx
  8005e9:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ec:	8b 00                	mov    (%eax),%eax
  8005ee:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005f1:	8b 75 10             	mov    0x10(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005f4:	eb 25                	jmp    80061b <vprintfmt+0x11c>
  8005f6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005f9:	85 c0                	test   %eax,%eax
  8005fb:	0f 48 c1             	cmovs  %ecx,%eax
  8005fe:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800601:	8b 75 10             	mov    0x10(%ebp),%esi
  800604:	e9 6d ff ff ff       	jmp    800576 <vprintfmt+0x77>
  800609:	8b 75 10             	mov    0x10(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80060c:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800613:	e9 5e ff ff ff       	jmp    800576 <vprintfmt+0x77>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800618:	8b 75 10             	mov    0x10(%ebp),%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80061b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80061f:	0f 89 51 ff ff ff    	jns    800576 <vprintfmt+0x77>
				width = precision, precision = -1;
  800625:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800628:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80062b:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800632:	e9 3f ff ff ff       	jmp    800576 <vprintfmt+0x77>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800637:	83 45 cc 01          	addl   $0x1,-0x34(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80063b:	8b 75 10             	mov    0x10(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80063e:	e9 33 ff ff ff       	jmp    800576 <vprintfmt+0x77>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800643:	8b 45 14             	mov    0x14(%ebp),%eax
  800646:	8d 50 04             	lea    0x4(%eax),%edx
  800649:	89 55 14             	mov    %edx,0x14(%ebp)
  80064c:	83 ec 08             	sub    $0x8,%esp
  80064f:	53                   	push   %ebx
  800650:	ff 30                	pushl  (%eax)
  800652:	ff d7                	call   *%edi
			break;
  800654:	83 c4 10             	add    $0x10,%esp
  800657:	e9 b7 fe ff ff       	jmp    800513 <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80065c:	8b 45 14             	mov    0x14(%ebp),%eax
  80065f:	8d 50 04             	lea    0x4(%eax),%edx
  800662:	89 55 14             	mov    %edx,0x14(%ebp)
  800665:	8b 00                	mov    (%eax),%eax
  800667:	99                   	cltd   
  800668:	31 d0                	xor    %edx,%eax
  80066a:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80066c:	83 f8 06             	cmp    $0x6,%eax
  80066f:	7f 0b                	jg     80067c <vprintfmt+0x17d>
  800671:	8b 14 85 b4 13 80 00 	mov    0x8013b4(,%eax,4),%edx
  800678:	85 d2                	test   %edx,%edx
  80067a:	75 15                	jne    800691 <vprintfmt+0x192>
				printfmt(putch, putdat, "error %d", err);
  80067c:	50                   	push   %eax
  80067d:	68 6b 11 80 00       	push   $0x80116b
  800682:	53                   	push   %ebx
  800683:	57                   	push   %edi
  800684:	e8 59 fe ff ff       	call   8004e2 <printfmt>
  800689:	83 c4 10             	add    $0x10,%esp
  80068c:	e9 82 fe ff ff       	jmp    800513 <vprintfmt+0x14>
			else
				printfmt(putch, putdat, "%s", p);
  800691:	52                   	push   %edx
  800692:	68 74 11 80 00       	push   $0x801174
  800697:	53                   	push   %ebx
  800698:	57                   	push   %edi
  800699:	e8 44 fe ff ff       	call   8004e2 <printfmt>
  80069e:	83 c4 10             	add    $0x10,%esp
  8006a1:	e9 6d fe ff ff       	jmp    800513 <vprintfmt+0x14>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8006a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a9:	8d 50 04             	lea    0x4(%eax),%edx
  8006ac:	89 55 14             	mov    %edx,0x14(%ebp)
  8006af:	8b 00                	mov    (%eax),%eax
				p = "(null)";
  8006b1:	85 c0                	test   %eax,%eax
  8006b3:	b9 64 11 80 00       	mov    $0x801164,%ecx
  8006b8:	0f 45 c8             	cmovne %eax,%ecx
  8006bb:	89 4d cc             	mov    %ecx,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8006be:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8006c2:	7e 06                	jle    8006ca <vprintfmt+0x1cb>
  8006c4:	80 7d e3 2d          	cmpb   $0x2d,-0x1d(%ebp)
  8006c8:	75 19                	jne    8006e3 <vprintfmt+0x1e4>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006ca:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8006cd:	8d 70 01             	lea    0x1(%eax),%esi
  8006d0:	0f b6 00             	movzbl (%eax),%eax
  8006d3:	0f be d0             	movsbl %al,%edx
  8006d6:	85 d2                	test   %edx,%edx
  8006d8:	0f 85 9f 00 00 00    	jne    80077d <vprintfmt+0x27e>
  8006de:	e9 8c 00 00 00       	jmp    80076f <vprintfmt+0x270>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006e3:	83 ec 08             	sub    $0x8,%esp
  8006e6:	ff 75 d0             	pushl  -0x30(%ebp)
  8006e9:	ff 75 cc             	pushl  -0x34(%ebp)
  8006ec:	e8 56 03 00 00       	call   800a47 <strnlen>
  8006f1:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  8006f4:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8006f7:	83 c4 10             	add    $0x10,%esp
  8006fa:	85 c9                	test   %ecx,%ecx
  8006fc:	0f 8e 9a 02 00 00    	jle    80099c <vprintfmt+0x49d>
					putch(padc, putdat);
  800702:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  800706:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800709:	89 cb                	mov    %ecx,%ebx
  80070b:	83 ec 08             	sub    $0x8,%esp
  80070e:	ff 75 0c             	pushl  0xc(%ebp)
  800711:	56                   	push   %esi
  800712:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800714:	83 c4 10             	add    $0x10,%esp
  800717:	83 eb 01             	sub    $0x1,%ebx
  80071a:	75 ef                	jne    80070b <vprintfmt+0x20c>
  80071c:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80071f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800722:	e9 75 02 00 00       	jmp    80099c <vprintfmt+0x49d>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800727:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80072b:	74 1b                	je     800748 <vprintfmt+0x249>
  80072d:	0f be c0             	movsbl %al,%eax
  800730:	83 e8 20             	sub    $0x20,%eax
  800733:	83 f8 5e             	cmp    $0x5e,%eax
  800736:	76 10                	jbe    800748 <vprintfmt+0x249>
					putch('?', putdat);
  800738:	83 ec 08             	sub    $0x8,%esp
  80073b:	ff 75 0c             	pushl  0xc(%ebp)
  80073e:	6a 3f                	push   $0x3f
  800740:	ff 55 08             	call   *0x8(%ebp)
  800743:	83 c4 10             	add    $0x10,%esp
  800746:	eb 0d                	jmp    800755 <vprintfmt+0x256>
				else
					putch(ch, putdat);
  800748:	83 ec 08             	sub    $0x8,%esp
  80074b:	ff 75 0c             	pushl  0xc(%ebp)
  80074e:	52                   	push   %edx
  80074f:	ff 55 08             	call   *0x8(%ebp)
  800752:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800755:	83 ef 01             	sub    $0x1,%edi
  800758:	83 c6 01             	add    $0x1,%esi
  80075b:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  80075f:	0f be d0             	movsbl %al,%edx
  800762:	85 d2                	test   %edx,%edx
  800764:	75 31                	jne    800797 <vprintfmt+0x298>
  800766:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800769:	8b 7d 08             	mov    0x8(%ebp),%edi
  80076c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80076f:	8b 75 e4             	mov    -0x1c(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800772:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800776:	7f 33                	jg     8007ab <vprintfmt+0x2ac>
  800778:	e9 96 fd ff ff       	jmp    800513 <vprintfmt+0x14>
  80077d:	89 7d 08             	mov    %edi,0x8(%ebp)
  800780:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800783:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800786:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800789:	eb 0c                	jmp    800797 <vprintfmt+0x298>
  80078b:	89 7d 08             	mov    %edi,0x8(%ebp)
  80078e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800791:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800794:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800797:	85 db                	test   %ebx,%ebx
  800799:	78 8c                	js     800727 <vprintfmt+0x228>
  80079b:	83 eb 01             	sub    $0x1,%ebx
  80079e:	79 87                	jns    800727 <vprintfmt+0x228>
  8007a0:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8007a3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8007a6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007a9:	eb c4                	jmp    80076f <vprintfmt+0x270>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8007ab:	83 ec 08             	sub    $0x8,%esp
  8007ae:	53                   	push   %ebx
  8007af:	6a 20                	push   $0x20
  8007b1:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8007b3:	83 c4 10             	add    $0x10,%esp
  8007b6:	83 ee 01             	sub    $0x1,%esi
  8007b9:	75 f0                	jne    8007ab <vprintfmt+0x2ac>
  8007bb:	e9 53 fd ff ff       	jmp    800513 <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007c0:	83 7d cc 01          	cmpl   $0x1,-0x34(%ebp)
  8007c4:	7e 16                	jle    8007dc <vprintfmt+0x2dd>
		return va_arg(*ap, long long);
  8007c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c9:	8d 50 08             	lea    0x8(%eax),%edx
  8007cc:	89 55 14             	mov    %edx,0x14(%ebp)
  8007cf:	8b 50 04             	mov    0x4(%eax),%edx
  8007d2:	8b 00                	mov    (%eax),%eax
  8007d4:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8007d7:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8007da:	eb 34                	jmp    800810 <vprintfmt+0x311>
	else if (lflag)
  8007dc:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8007e0:	74 18                	je     8007fa <vprintfmt+0x2fb>
		return va_arg(*ap, long);
  8007e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e5:	8d 50 04             	lea    0x4(%eax),%edx
  8007e8:	89 55 14             	mov    %edx,0x14(%ebp)
  8007eb:	8b 30                	mov    (%eax),%esi
  8007ed:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8007f0:	89 f0                	mov    %esi,%eax
  8007f2:	c1 f8 1f             	sar    $0x1f,%eax
  8007f5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8007f8:	eb 16                	jmp    800810 <vprintfmt+0x311>
	else
		return va_arg(*ap, int);
  8007fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8007fd:	8d 50 04             	lea    0x4(%eax),%edx
  800800:	89 55 14             	mov    %edx,0x14(%ebp)
  800803:	8b 30                	mov    (%eax),%esi
  800805:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800808:	89 f0                	mov    %esi,%eax
  80080a:	c1 f8 1f             	sar    $0x1f,%eax
  80080d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800810:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800813:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800816:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800819:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  80081c:	85 d2                	test   %edx,%edx
  80081e:	79 28                	jns    800848 <vprintfmt+0x349>
				putch('-', putdat);
  800820:	83 ec 08             	sub    $0x8,%esp
  800823:	53                   	push   %ebx
  800824:	6a 2d                	push   $0x2d
  800826:	ff d7                	call   *%edi
				num = -(long long) num;
  800828:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80082b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80082e:	f7 d8                	neg    %eax
  800830:	83 d2 00             	adc    $0x0,%edx
  800833:	f7 da                	neg    %edx
  800835:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800838:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80083b:	83 c4 10             	add    $0x10,%esp
			else
			{
				if(padc=='+')
					putch('+', putdat);
			}
			base = 10;
  80083e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800843:	e9 a5 00 00 00       	jmp    8008ed <vprintfmt+0x3ee>
  800848:	b8 0a 00 00 00       	mov    $0xa,%eax
				putch('-', putdat);
				num = -(long long) num;
			}
			else
			{
				if(padc=='+')
  80084d:	80 7d e3 2b          	cmpb   $0x2b,-0x1d(%ebp)
  800851:	0f 85 96 00 00 00    	jne    8008ed <vprintfmt+0x3ee>
					putch('+', putdat);
  800857:	83 ec 08             	sub    $0x8,%esp
  80085a:	53                   	push   %ebx
  80085b:	6a 2b                	push   $0x2b
  80085d:	ff d7                	call   *%edi
  80085f:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800862:	b8 0a 00 00 00       	mov    $0xa,%eax
  800867:	e9 81 00 00 00       	jmp    8008ed <vprintfmt+0x3ee>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80086c:	8b 55 cc             	mov    -0x34(%ebp),%edx
  80086f:	8d 45 14             	lea    0x14(%ebp),%eax
  800872:	e8 14 fc ff ff       	call   80048b <getuint>
  800877:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80087a:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  80087d:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800882:	eb 69                	jmp    8008ed <vprintfmt+0x3ee>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			putch('0', putdat);
  800884:	83 ec 08             	sub    $0x8,%esp
  800887:	53                   	push   %ebx
  800888:	6a 30                	push   $0x30
  80088a:	ff d7                	call   *%edi
			num = getuint(&ap, lflag);
  80088c:	8b 55 cc             	mov    -0x34(%ebp),%edx
  80088f:	8d 45 14             	lea    0x14(%ebp),%eax
  800892:	e8 f4 fb ff ff       	call   80048b <getuint>
  800897:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80089a:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
			goto number;
  80089d:	83 c4 10             	add    $0x10,%esp
		case 'o':
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
  8008a0:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  8008a5:	eb 46                	jmp    8008ed <vprintfmt+0x3ee>

		// pointer
		case 'p':
			putch('0', putdat);
  8008a7:	83 ec 08             	sub    $0x8,%esp
  8008aa:	53                   	push   %ebx
  8008ab:	6a 30                	push   $0x30
  8008ad:	ff d7                	call   *%edi
			putch('x', putdat);
  8008af:	83 c4 08             	add    $0x8,%esp
  8008b2:	53                   	push   %ebx
  8008b3:	6a 78                	push   $0x78
  8008b5:	ff d7                	call   *%edi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8008b7:	8b 45 14             	mov    0x14(%ebp),%eax
  8008ba:	8d 50 04             	lea    0x4(%eax),%edx
  8008bd:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8008c0:	8b 00                	mov    (%eax),%eax
  8008c2:	ba 00 00 00 00       	mov    $0x0,%edx
  8008c7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8008ca:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8008cd:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8008d0:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8008d5:	eb 16                	jmp    8008ed <vprintfmt+0x3ee>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8008d7:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8008da:	8d 45 14             	lea    0x14(%ebp),%eax
  8008dd:	e8 a9 fb ff ff       	call   80048b <getuint>
  8008e2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8008e5:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  8008e8:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8008ed:	83 ec 0c             	sub    $0xc,%esp
  8008f0:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  8008f4:	56                   	push   %esi
  8008f5:	ff 75 e4             	pushl  -0x1c(%ebp)
  8008f8:	50                   	push   %eax
  8008f9:	ff 75 dc             	pushl  -0x24(%ebp)
  8008fc:	ff 75 d8             	pushl  -0x28(%ebp)
  8008ff:	89 da                	mov    %ebx,%edx
  800901:	89 f8                	mov    %edi,%eax
  800903:	e8 e3 f9 ff ff       	call   8002eb <printnum>
			break;
  800908:	83 c4 20             	add    $0x20,%esp
  80090b:	e9 03 fc ff ff       	jmp    800513 <vprintfmt+0x14>

            const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
            const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

            // Your code here
			num=(unsigned long long)(uintptr_t)va_arg(ap, void *);
  800910:	8b 45 14             	mov    0x14(%ebp),%eax
  800913:	8d 50 04             	lea    0x4(%eax),%edx
  800916:	89 55 14             	mov    %edx,0x14(%ebp)
  800919:	8b 00                	mov    (%eax),%eax
			if(!num)
  80091b:	85 c0                	test   %eax,%eax
  80091d:	75 1c                	jne    80093b <vprintfmt+0x43c>
				*(int *)putdat+=cprintf("%s",null_error);
  80091f:	83 ec 08             	sub    $0x8,%esp
  800922:	68 e0 11 80 00       	push   $0x8011e0
  800927:	68 74 11 80 00       	push   $0x801174
  80092c:	e8 a6 f9 ff ff       	call   8002d7 <cprintf>
  800931:	01 03                	add    %eax,(%ebx)
  800933:	83 c4 10             	add    $0x10,%esp
  800936:	e9 d8 fb ff ff       	jmp    800513 <vprintfmt+0x14>
			else
			{
				*(char *)(int)num=*(int *)putdat;
  80093b:	8b 13                	mov    (%ebx),%edx
  80093d:	88 10                	mov    %dl,(%eax)
				if((*(int *)putdat)>128)
  80093f:	81 3b 80 00 00 00    	cmpl   $0x80,(%ebx)
  800945:	0f 8e c8 fb ff ff    	jle    800513 <vprintfmt+0x14>
					*(int *)putdat+=cprintf("%s",overflow_error);
  80094b:	83 ec 08             	sub    $0x8,%esp
  80094e:	68 18 12 80 00       	push   $0x801218
  800953:	68 74 11 80 00       	push   $0x801174
  800958:	e8 7a f9 ff ff       	call   8002d7 <cprintf>
  80095d:	01 03                	add    %eax,(%ebx)
  80095f:	83 c4 10             	add    $0x10,%esp
  800962:	e9 ac fb ff ff       	jmp    800513 <vprintfmt+0x14>
            break;
        }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800967:	83 ec 08             	sub    $0x8,%esp
  80096a:	53                   	push   %ebx
  80096b:	52                   	push   %edx
  80096c:	ff d7                	call   *%edi
			break;
  80096e:	83 c4 10             	add    $0x10,%esp
  800971:	e9 9d fb ff ff       	jmp    800513 <vprintfmt+0x14>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800976:	83 ec 08             	sub    $0x8,%esp
  800979:	53                   	push   %ebx
  80097a:	6a 25                	push   $0x25
  80097c:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80097e:	83 c4 10             	add    $0x10,%esp
  800981:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800985:	0f 84 85 fb ff ff    	je     800510 <vprintfmt+0x11>
  80098b:	83 ee 01             	sub    $0x1,%esi
  80098e:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800992:	75 f7                	jne    80098b <vprintfmt+0x48c>
  800994:	89 75 10             	mov    %esi,0x10(%ebp)
  800997:	e9 77 fb ff ff       	jmp    800513 <vprintfmt+0x14>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80099c:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80099f:	8d 70 01             	lea    0x1(%eax),%esi
  8009a2:	0f b6 00             	movzbl (%eax),%eax
  8009a5:	0f be d0             	movsbl %al,%edx
  8009a8:	85 d2                	test   %edx,%edx
  8009aa:	0f 85 db fd ff ff    	jne    80078b <vprintfmt+0x28c>
  8009b0:	e9 5e fb ff ff       	jmp    800513 <vprintfmt+0x14>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  8009b5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8009b8:	5b                   	pop    %ebx
  8009b9:	5e                   	pop    %esi
  8009ba:	5f                   	pop    %edi
  8009bb:	5d                   	pop    %ebp
  8009bc:	c3                   	ret    

008009bd <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8009bd:	55                   	push   %ebp
  8009be:	89 e5                	mov    %esp,%ebp
  8009c0:	83 ec 18             	sub    $0x18,%esp
  8009c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c6:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8009c9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8009cc:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8009d0:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8009d3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8009da:	85 c0                	test   %eax,%eax
  8009dc:	74 26                	je     800a04 <vsnprintf+0x47>
  8009de:	85 d2                	test   %edx,%edx
  8009e0:	7e 22                	jle    800a04 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8009e2:	ff 75 14             	pushl  0x14(%ebp)
  8009e5:	ff 75 10             	pushl  0x10(%ebp)
  8009e8:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8009eb:	50                   	push   %eax
  8009ec:	68 c5 04 80 00       	push   $0x8004c5
  8009f1:	e8 09 fb ff ff       	call   8004ff <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8009f6:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8009f9:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8009fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009ff:	83 c4 10             	add    $0x10,%esp
  800a02:	eb 05                	jmp    800a09 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800a04:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800a09:	c9                   	leave  
  800a0a:	c3                   	ret    

00800a0b <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800a0b:	55                   	push   %ebp
  800a0c:	89 e5                	mov    %esp,%ebp
  800a0e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800a11:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800a14:	50                   	push   %eax
  800a15:	ff 75 10             	pushl  0x10(%ebp)
  800a18:	ff 75 0c             	pushl  0xc(%ebp)
  800a1b:	ff 75 08             	pushl  0x8(%ebp)
  800a1e:	e8 9a ff ff ff       	call   8009bd <vsnprintf>
	va_end(ap);

	return rc;
}
  800a23:	c9                   	leave  
  800a24:	c3                   	ret    

00800a25 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a25:	55                   	push   %ebp
  800a26:	89 e5                	mov    %esp,%ebp
  800a28:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a2b:	80 3a 00             	cmpb   $0x0,(%edx)
  800a2e:	74 10                	je     800a40 <strlen+0x1b>
  800a30:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800a35:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800a38:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a3c:	75 f7                	jne    800a35 <strlen+0x10>
  800a3e:	eb 05                	jmp    800a45 <strlen+0x20>
  800a40:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800a45:	5d                   	pop    %ebp
  800a46:	c3                   	ret    

00800a47 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a47:	55                   	push   %ebp
  800a48:	89 e5                	mov    %esp,%ebp
  800a4a:	53                   	push   %ebx
  800a4b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800a4e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a51:	85 c9                	test   %ecx,%ecx
  800a53:	74 1c                	je     800a71 <strnlen+0x2a>
  800a55:	80 3b 00             	cmpb   $0x0,(%ebx)
  800a58:	74 1e                	je     800a78 <strnlen+0x31>
  800a5a:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  800a5f:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a61:	39 ca                	cmp    %ecx,%edx
  800a63:	74 18                	je     800a7d <strnlen+0x36>
  800a65:	83 c2 01             	add    $0x1,%edx
  800a68:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800a6d:	75 f0                	jne    800a5f <strnlen+0x18>
  800a6f:	eb 0c                	jmp    800a7d <strnlen+0x36>
  800a71:	b8 00 00 00 00       	mov    $0x0,%eax
  800a76:	eb 05                	jmp    800a7d <strnlen+0x36>
  800a78:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800a7d:	5b                   	pop    %ebx
  800a7e:	5d                   	pop    %ebp
  800a7f:	c3                   	ret    

00800a80 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a80:	55                   	push   %ebp
  800a81:	89 e5                	mov    %esp,%ebp
  800a83:	53                   	push   %ebx
  800a84:	8b 45 08             	mov    0x8(%ebp),%eax
  800a87:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a8a:	89 c2                	mov    %eax,%edx
  800a8c:	83 c2 01             	add    $0x1,%edx
  800a8f:	83 c1 01             	add    $0x1,%ecx
  800a92:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800a96:	88 5a ff             	mov    %bl,-0x1(%edx)
  800a99:	84 db                	test   %bl,%bl
  800a9b:	75 ef                	jne    800a8c <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800a9d:	5b                   	pop    %ebx
  800a9e:	5d                   	pop    %ebp
  800a9f:	c3                   	ret    

00800aa0 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800aa0:	55                   	push   %ebp
  800aa1:	89 e5                	mov    %esp,%ebp
  800aa3:	53                   	push   %ebx
  800aa4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800aa7:	53                   	push   %ebx
  800aa8:	e8 78 ff ff ff       	call   800a25 <strlen>
  800aad:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800ab0:	ff 75 0c             	pushl  0xc(%ebp)
  800ab3:	01 d8                	add    %ebx,%eax
  800ab5:	50                   	push   %eax
  800ab6:	e8 c5 ff ff ff       	call   800a80 <strcpy>
	return dst;
}
  800abb:	89 d8                	mov    %ebx,%eax
  800abd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ac0:	c9                   	leave  
  800ac1:	c3                   	ret    

00800ac2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800ac2:	55                   	push   %ebp
  800ac3:	89 e5                	mov    %esp,%ebp
  800ac5:	56                   	push   %esi
  800ac6:	53                   	push   %ebx
  800ac7:	8b 75 08             	mov    0x8(%ebp),%esi
  800aca:	8b 55 0c             	mov    0xc(%ebp),%edx
  800acd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ad0:	85 db                	test   %ebx,%ebx
  800ad2:	74 17                	je     800aeb <strncpy+0x29>
  800ad4:	01 f3                	add    %esi,%ebx
  800ad6:	89 f1                	mov    %esi,%ecx
		*dst++ = *src;
  800ad8:	83 c1 01             	add    $0x1,%ecx
  800adb:	0f b6 02             	movzbl (%edx),%eax
  800ade:	88 41 ff             	mov    %al,-0x1(%ecx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800ae1:	80 3a 01             	cmpb   $0x1,(%edx)
  800ae4:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ae7:	39 cb                	cmp    %ecx,%ebx
  800ae9:	75 ed                	jne    800ad8 <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800aeb:	89 f0                	mov    %esi,%eax
  800aed:	5b                   	pop    %ebx
  800aee:	5e                   	pop    %esi
  800aef:	5d                   	pop    %ebp
  800af0:	c3                   	ret    

00800af1 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800af1:	55                   	push   %ebp
  800af2:	89 e5                	mov    %esp,%ebp
  800af4:	56                   	push   %esi
  800af5:	53                   	push   %ebx
  800af6:	8b 75 08             	mov    0x8(%ebp),%esi
  800af9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800afc:	8b 55 10             	mov    0x10(%ebp),%edx
  800aff:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b01:	85 d2                	test   %edx,%edx
  800b03:	74 35                	je     800b3a <strlcpy+0x49>
		while (--size > 0 && *src != '\0')
  800b05:	89 d0                	mov    %edx,%eax
  800b07:	83 e8 01             	sub    $0x1,%eax
  800b0a:	74 25                	je     800b31 <strlcpy+0x40>
  800b0c:	0f b6 0b             	movzbl (%ebx),%ecx
  800b0f:	84 c9                	test   %cl,%cl
  800b11:	74 22                	je     800b35 <strlcpy+0x44>
  800b13:	8d 53 01             	lea    0x1(%ebx),%edx
  800b16:	01 c3                	add    %eax,%ebx
  800b18:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
  800b1a:	83 c0 01             	add    $0x1,%eax
  800b1d:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800b20:	39 da                	cmp    %ebx,%edx
  800b22:	74 13                	je     800b37 <strlcpy+0x46>
  800b24:	83 c2 01             	add    $0x1,%edx
  800b27:	0f b6 4a ff          	movzbl -0x1(%edx),%ecx
  800b2b:	84 c9                	test   %cl,%cl
  800b2d:	75 eb                	jne    800b1a <strlcpy+0x29>
  800b2f:	eb 06                	jmp    800b37 <strlcpy+0x46>
  800b31:	89 f0                	mov    %esi,%eax
  800b33:	eb 02                	jmp    800b37 <strlcpy+0x46>
  800b35:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800b37:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800b3a:	29 f0                	sub    %esi,%eax
}
  800b3c:	5b                   	pop    %ebx
  800b3d:	5e                   	pop    %esi
  800b3e:	5d                   	pop    %ebp
  800b3f:	c3                   	ret    

00800b40 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800b40:	55                   	push   %ebp
  800b41:	89 e5                	mov    %esp,%ebp
  800b43:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b46:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800b49:	0f b6 01             	movzbl (%ecx),%eax
  800b4c:	84 c0                	test   %al,%al
  800b4e:	74 15                	je     800b65 <strcmp+0x25>
  800b50:	3a 02                	cmp    (%edx),%al
  800b52:	75 11                	jne    800b65 <strcmp+0x25>
		p++, q++;
  800b54:	83 c1 01             	add    $0x1,%ecx
  800b57:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800b5a:	0f b6 01             	movzbl (%ecx),%eax
  800b5d:	84 c0                	test   %al,%al
  800b5f:	74 04                	je     800b65 <strcmp+0x25>
  800b61:	3a 02                	cmp    (%edx),%al
  800b63:	74 ef                	je     800b54 <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800b65:	0f b6 c0             	movzbl %al,%eax
  800b68:	0f b6 12             	movzbl (%edx),%edx
  800b6b:	29 d0                	sub    %edx,%eax
}
  800b6d:	5d                   	pop    %ebp
  800b6e:	c3                   	ret    

00800b6f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b6f:	55                   	push   %ebp
  800b70:	89 e5                	mov    %esp,%ebp
  800b72:	56                   	push   %esi
  800b73:	53                   	push   %ebx
  800b74:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800b77:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b7a:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  800b7d:	85 f6                	test   %esi,%esi
  800b7f:	74 29                	je     800baa <strncmp+0x3b>
  800b81:	0f b6 03             	movzbl (%ebx),%eax
  800b84:	84 c0                	test   %al,%al
  800b86:	74 30                	je     800bb8 <strncmp+0x49>
  800b88:	3a 02                	cmp    (%edx),%al
  800b8a:	75 2c                	jne    800bb8 <strncmp+0x49>
  800b8c:	8d 43 01             	lea    0x1(%ebx),%eax
  800b8f:	01 de                	add    %ebx,%esi
		n--, p++, q++;
  800b91:	89 c3                	mov    %eax,%ebx
  800b93:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800b96:	39 c6                	cmp    %eax,%esi
  800b98:	74 17                	je     800bb1 <strncmp+0x42>
  800b9a:	0f b6 08             	movzbl (%eax),%ecx
  800b9d:	84 c9                	test   %cl,%cl
  800b9f:	74 17                	je     800bb8 <strncmp+0x49>
  800ba1:	83 c0 01             	add    $0x1,%eax
  800ba4:	3a 0a                	cmp    (%edx),%cl
  800ba6:	74 e9                	je     800b91 <strncmp+0x22>
  800ba8:	eb 0e                	jmp    800bb8 <strncmp+0x49>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800baa:	b8 00 00 00 00       	mov    $0x0,%eax
  800baf:	eb 0f                	jmp    800bc0 <strncmp+0x51>
  800bb1:	b8 00 00 00 00       	mov    $0x0,%eax
  800bb6:	eb 08                	jmp    800bc0 <strncmp+0x51>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800bb8:	0f b6 03             	movzbl (%ebx),%eax
  800bbb:	0f b6 12             	movzbl (%edx),%edx
  800bbe:	29 d0                	sub    %edx,%eax
}
  800bc0:	5b                   	pop    %ebx
  800bc1:	5e                   	pop    %esi
  800bc2:	5d                   	pop    %ebp
  800bc3:	c3                   	ret    

00800bc4 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800bc4:	55                   	push   %ebp
  800bc5:	89 e5                	mov    %esp,%ebp
  800bc7:	53                   	push   %ebx
  800bc8:	8b 45 08             	mov    0x8(%ebp),%eax
  800bcb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
  800bce:	0f b6 10             	movzbl (%eax),%edx
  800bd1:	84 d2                	test   %dl,%dl
  800bd3:	74 1d                	je     800bf2 <strchr+0x2e>
  800bd5:	89 d9                	mov    %ebx,%ecx
		if (*s == c)
  800bd7:	38 d3                	cmp    %dl,%bl
  800bd9:	75 06                	jne    800be1 <strchr+0x1d>
  800bdb:	eb 1a                	jmp    800bf7 <strchr+0x33>
  800bdd:	38 ca                	cmp    %cl,%dl
  800bdf:	74 16                	je     800bf7 <strchr+0x33>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800be1:	83 c0 01             	add    $0x1,%eax
  800be4:	0f b6 10             	movzbl (%eax),%edx
  800be7:	84 d2                	test   %dl,%dl
  800be9:	75 f2                	jne    800bdd <strchr+0x19>
		if (*s == c)
			return (char *) s;
	return 0;
  800beb:	b8 00 00 00 00       	mov    $0x0,%eax
  800bf0:	eb 05                	jmp    800bf7 <strchr+0x33>
  800bf2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bf7:	5b                   	pop    %ebx
  800bf8:	5d                   	pop    %ebp
  800bf9:	c3                   	ret    

00800bfa <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800bfa:	55                   	push   %ebp
  800bfb:	89 e5                	mov    %esp,%ebp
  800bfd:	53                   	push   %ebx
  800bfe:	8b 45 08             	mov    0x8(%ebp),%eax
  800c01:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  800c04:	0f b6 18             	movzbl (%eax),%ebx
		if (*s == c)
  800c07:	38 d3                	cmp    %dl,%bl
  800c09:	74 14                	je     800c1f <strfind+0x25>
  800c0b:	89 d1                	mov    %edx,%ecx
  800c0d:	84 db                	test   %bl,%bl
  800c0f:	74 0e                	je     800c1f <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800c11:	83 c0 01             	add    $0x1,%eax
  800c14:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800c17:	38 ca                	cmp    %cl,%dl
  800c19:	74 04                	je     800c1f <strfind+0x25>
  800c1b:	84 d2                	test   %dl,%dl
  800c1d:	75 f2                	jne    800c11 <strfind+0x17>
			break;
	return (char *) s;
}
  800c1f:	5b                   	pop    %ebx
  800c20:	5d                   	pop    %ebp
  800c21:	c3                   	ret    

00800c22 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800c22:	55                   	push   %ebp
  800c23:	89 e5                	mov    %esp,%ebp
  800c25:	57                   	push   %edi
  800c26:	56                   	push   %esi
  800c27:	53                   	push   %ebx
  800c28:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c2b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800c2e:	85 c9                	test   %ecx,%ecx
  800c30:	74 36                	je     800c68 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800c32:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c38:	75 28                	jne    800c62 <memset+0x40>
  800c3a:	f6 c1 03             	test   $0x3,%cl
  800c3d:	75 23                	jne    800c62 <memset+0x40>
		c &= 0xFF;
  800c3f:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800c43:	89 d3                	mov    %edx,%ebx
  800c45:	c1 e3 08             	shl    $0x8,%ebx
  800c48:	89 d6                	mov    %edx,%esi
  800c4a:	c1 e6 18             	shl    $0x18,%esi
  800c4d:	89 d0                	mov    %edx,%eax
  800c4f:	c1 e0 10             	shl    $0x10,%eax
  800c52:	09 f0                	or     %esi,%eax
  800c54:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800c56:	89 d8                	mov    %ebx,%eax
  800c58:	09 d0                	or     %edx,%eax
  800c5a:	c1 e9 02             	shr    $0x2,%ecx
  800c5d:	fc                   	cld    
  800c5e:	f3 ab                	rep stos %eax,%es:(%edi)
  800c60:	eb 06                	jmp    800c68 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800c62:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c65:	fc                   	cld    
  800c66:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800c68:	89 f8                	mov    %edi,%eax
  800c6a:	5b                   	pop    %ebx
  800c6b:	5e                   	pop    %esi
  800c6c:	5f                   	pop    %edi
  800c6d:	5d                   	pop    %ebp
  800c6e:	c3                   	ret    

00800c6f <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800c6f:	55                   	push   %ebp
  800c70:	89 e5                	mov    %esp,%ebp
  800c72:	57                   	push   %edi
  800c73:	56                   	push   %esi
  800c74:	8b 45 08             	mov    0x8(%ebp),%eax
  800c77:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c7a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800c7d:	39 c6                	cmp    %eax,%esi
  800c7f:	73 35                	jae    800cb6 <memmove+0x47>
  800c81:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c84:	39 d0                	cmp    %edx,%eax
  800c86:	73 2e                	jae    800cb6 <memmove+0x47>
		s += n;
		d += n;
  800c88:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c8b:	89 d6                	mov    %edx,%esi
  800c8d:	09 fe                	or     %edi,%esi
  800c8f:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c95:	75 13                	jne    800caa <memmove+0x3b>
  800c97:	f6 c1 03             	test   $0x3,%cl
  800c9a:	75 0e                	jne    800caa <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800c9c:	83 ef 04             	sub    $0x4,%edi
  800c9f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ca2:	c1 e9 02             	shr    $0x2,%ecx
  800ca5:	fd                   	std    
  800ca6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ca8:	eb 09                	jmp    800cb3 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800caa:	83 ef 01             	sub    $0x1,%edi
  800cad:	8d 72 ff             	lea    -0x1(%edx),%esi
  800cb0:	fd                   	std    
  800cb1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800cb3:	fc                   	cld    
  800cb4:	eb 1d                	jmp    800cd3 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800cb6:	89 f2                	mov    %esi,%edx
  800cb8:	09 c2                	or     %eax,%edx
  800cba:	f6 c2 03             	test   $0x3,%dl
  800cbd:	75 0f                	jne    800cce <memmove+0x5f>
  800cbf:	f6 c1 03             	test   $0x3,%cl
  800cc2:	75 0a                	jne    800cce <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800cc4:	c1 e9 02             	shr    $0x2,%ecx
  800cc7:	89 c7                	mov    %eax,%edi
  800cc9:	fc                   	cld    
  800cca:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ccc:	eb 05                	jmp    800cd3 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800cce:	89 c7                	mov    %eax,%edi
  800cd0:	fc                   	cld    
  800cd1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800cd3:	5e                   	pop    %esi
  800cd4:	5f                   	pop    %edi
  800cd5:	5d                   	pop    %ebp
  800cd6:	c3                   	ret    

00800cd7 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800cd7:	55                   	push   %ebp
  800cd8:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800cda:	ff 75 10             	pushl  0x10(%ebp)
  800cdd:	ff 75 0c             	pushl  0xc(%ebp)
  800ce0:	ff 75 08             	pushl  0x8(%ebp)
  800ce3:	e8 87 ff ff ff       	call   800c6f <memmove>
}
  800ce8:	c9                   	leave  
  800ce9:	c3                   	ret    

00800cea <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800cea:	55                   	push   %ebp
  800ceb:	89 e5                	mov    %esp,%ebp
  800ced:	57                   	push   %edi
  800cee:	56                   	push   %esi
  800cef:	53                   	push   %ebx
  800cf0:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800cf3:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cf6:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800cf9:	85 c0                	test   %eax,%eax
  800cfb:	74 39                	je     800d36 <memcmp+0x4c>
  800cfd:	8d 78 ff             	lea    -0x1(%eax),%edi
		if (*s1 != *s2)
  800d00:	0f b6 13             	movzbl (%ebx),%edx
  800d03:	0f b6 0e             	movzbl (%esi),%ecx
  800d06:	38 ca                	cmp    %cl,%dl
  800d08:	75 17                	jne    800d21 <memcmp+0x37>
  800d0a:	b8 00 00 00 00       	mov    $0x0,%eax
  800d0f:	eb 1a                	jmp    800d2b <memcmp+0x41>
  800d11:	0f b6 54 03 01       	movzbl 0x1(%ebx,%eax,1),%edx
  800d16:	83 c0 01             	add    $0x1,%eax
  800d19:	0f b6 0c 06          	movzbl (%esi,%eax,1),%ecx
  800d1d:	38 ca                	cmp    %cl,%dl
  800d1f:	74 0a                	je     800d2b <memcmp+0x41>
			return (int) *s1 - (int) *s2;
  800d21:	0f b6 c2             	movzbl %dl,%eax
  800d24:	0f b6 c9             	movzbl %cl,%ecx
  800d27:	29 c8                	sub    %ecx,%eax
  800d29:	eb 10                	jmp    800d3b <memcmp+0x51>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d2b:	39 f8                	cmp    %edi,%eax
  800d2d:	75 e2                	jne    800d11 <memcmp+0x27>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800d2f:	b8 00 00 00 00       	mov    $0x0,%eax
  800d34:	eb 05                	jmp    800d3b <memcmp+0x51>
  800d36:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d3b:	5b                   	pop    %ebx
  800d3c:	5e                   	pop    %esi
  800d3d:	5f                   	pop    %edi
  800d3e:	5d                   	pop    %ebp
  800d3f:	c3                   	ret    

00800d40 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800d40:	55                   	push   %ebp
  800d41:	89 e5                	mov    %esp,%ebp
  800d43:	53                   	push   %ebx
  800d44:	8b 55 08             	mov    0x8(%ebp),%edx
	const void *ends = (const char *) s + n;
  800d47:	89 d0                	mov    %edx,%eax
  800d49:	03 45 10             	add    0x10(%ebp),%eax
	for (; s < ends; s++)
  800d4c:	39 c2                	cmp    %eax,%edx
  800d4e:	73 1d                	jae    800d6d <memfind+0x2d>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d50:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
  800d54:	0f b6 0a             	movzbl (%edx),%ecx
  800d57:	39 d9                	cmp    %ebx,%ecx
  800d59:	75 09                	jne    800d64 <memfind+0x24>
  800d5b:	eb 14                	jmp    800d71 <memfind+0x31>
  800d5d:	0f b6 0a             	movzbl (%edx),%ecx
  800d60:	39 d9                	cmp    %ebx,%ecx
  800d62:	74 11                	je     800d75 <memfind+0x35>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800d64:	83 c2 01             	add    $0x1,%edx
  800d67:	39 d0                	cmp    %edx,%eax
  800d69:	75 f2                	jne    800d5d <memfind+0x1d>
  800d6b:	eb 0a                	jmp    800d77 <memfind+0x37>
  800d6d:	89 d0                	mov    %edx,%eax
  800d6f:	eb 06                	jmp    800d77 <memfind+0x37>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d71:	89 d0                	mov    %edx,%eax
  800d73:	eb 02                	jmp    800d77 <memfind+0x37>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800d75:	89 d0                	mov    %edx,%eax
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800d77:	5b                   	pop    %ebx
  800d78:	5d                   	pop    %ebp
  800d79:	c3                   	ret    

00800d7a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d7a:	55                   	push   %ebp
  800d7b:	89 e5                	mov    %esp,%ebp
  800d7d:	57                   	push   %edi
  800d7e:	56                   	push   %esi
  800d7f:	53                   	push   %ebx
  800d80:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d83:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d86:	0f b6 01             	movzbl (%ecx),%eax
  800d89:	3c 20                	cmp    $0x20,%al
  800d8b:	74 04                	je     800d91 <strtol+0x17>
  800d8d:	3c 09                	cmp    $0x9,%al
  800d8f:	75 0e                	jne    800d9f <strtol+0x25>
		s++;
  800d91:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d94:	0f b6 01             	movzbl (%ecx),%eax
  800d97:	3c 20                	cmp    $0x20,%al
  800d99:	74 f6                	je     800d91 <strtol+0x17>
  800d9b:	3c 09                	cmp    $0x9,%al
  800d9d:	74 f2                	je     800d91 <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  800d9f:	3c 2b                	cmp    $0x2b,%al
  800da1:	75 0a                	jne    800dad <strtol+0x33>
		s++;
  800da3:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800da6:	bf 00 00 00 00       	mov    $0x0,%edi
  800dab:	eb 11                	jmp    800dbe <strtol+0x44>
  800dad:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800db2:	3c 2d                	cmp    $0x2d,%al
  800db4:	75 08                	jne    800dbe <strtol+0x44>
		s++, neg = 1;
  800db6:	83 c1 01             	add    $0x1,%ecx
  800db9:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800dbe:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800dc4:	75 15                	jne    800ddb <strtol+0x61>
  800dc6:	80 39 30             	cmpb   $0x30,(%ecx)
  800dc9:	75 10                	jne    800ddb <strtol+0x61>
  800dcb:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800dcf:	75 7c                	jne    800e4d <strtol+0xd3>
		s += 2, base = 16;
  800dd1:	83 c1 02             	add    $0x2,%ecx
  800dd4:	bb 10 00 00 00       	mov    $0x10,%ebx
  800dd9:	eb 16                	jmp    800df1 <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  800ddb:	85 db                	test   %ebx,%ebx
  800ddd:	75 12                	jne    800df1 <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ddf:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800de4:	80 39 30             	cmpb   $0x30,(%ecx)
  800de7:	75 08                	jne    800df1 <strtol+0x77>
		s++, base = 8;
  800de9:	83 c1 01             	add    $0x1,%ecx
  800dec:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800df1:	b8 00 00 00 00       	mov    $0x0,%eax
  800df6:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800df9:	0f b6 11             	movzbl (%ecx),%edx
  800dfc:	8d 72 d0             	lea    -0x30(%edx),%esi
  800dff:	89 f3                	mov    %esi,%ebx
  800e01:	80 fb 09             	cmp    $0x9,%bl
  800e04:	77 08                	ja     800e0e <strtol+0x94>
			dig = *s - '0';
  800e06:	0f be d2             	movsbl %dl,%edx
  800e09:	83 ea 30             	sub    $0x30,%edx
  800e0c:	eb 22                	jmp    800e30 <strtol+0xb6>
		else if (*s >= 'a' && *s <= 'z')
  800e0e:	8d 72 9f             	lea    -0x61(%edx),%esi
  800e11:	89 f3                	mov    %esi,%ebx
  800e13:	80 fb 19             	cmp    $0x19,%bl
  800e16:	77 08                	ja     800e20 <strtol+0xa6>
			dig = *s - 'a' + 10;
  800e18:	0f be d2             	movsbl %dl,%edx
  800e1b:	83 ea 57             	sub    $0x57,%edx
  800e1e:	eb 10                	jmp    800e30 <strtol+0xb6>
		else if (*s >= 'A' && *s <= 'Z')
  800e20:	8d 72 bf             	lea    -0x41(%edx),%esi
  800e23:	89 f3                	mov    %esi,%ebx
  800e25:	80 fb 19             	cmp    $0x19,%bl
  800e28:	77 16                	ja     800e40 <strtol+0xc6>
			dig = *s - 'A' + 10;
  800e2a:	0f be d2             	movsbl %dl,%edx
  800e2d:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800e30:	3b 55 10             	cmp    0x10(%ebp),%edx
  800e33:	7d 0b                	jge    800e40 <strtol+0xc6>
			break;
		s++, val = (val * base) + dig;
  800e35:	83 c1 01             	add    $0x1,%ecx
  800e38:	0f af 45 10          	imul   0x10(%ebp),%eax
  800e3c:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800e3e:	eb b9                	jmp    800df9 <strtol+0x7f>

	if (endptr)
  800e40:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800e44:	74 0d                	je     800e53 <strtol+0xd9>
		*endptr = (char *) s;
  800e46:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e49:	89 0e                	mov    %ecx,(%esi)
  800e4b:	eb 06                	jmp    800e53 <strtol+0xd9>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800e4d:	85 db                	test   %ebx,%ebx
  800e4f:	74 98                	je     800de9 <strtol+0x6f>
  800e51:	eb 9e                	jmp    800df1 <strtol+0x77>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800e53:	89 c2                	mov    %eax,%edx
  800e55:	f7 da                	neg    %edx
  800e57:	85 ff                	test   %edi,%edi
  800e59:	0f 45 c2             	cmovne %edx,%eax
}
  800e5c:	5b                   	pop    %ebx
  800e5d:	5e                   	pop    %esi
  800e5e:	5f                   	pop    %edi
  800e5f:	5d                   	pop    %ebp
  800e60:	c3                   	ret    
  800e61:	66 90                	xchg   %ax,%ax
  800e63:	66 90                	xchg   %ax,%ax
  800e65:	66 90                	xchg   %ax,%ax
  800e67:	66 90                	xchg   %ax,%ax
  800e69:	66 90                	xchg   %ax,%ax
  800e6b:	66 90                	xchg   %ax,%ax
  800e6d:	66 90                	xchg   %ax,%ax
  800e6f:	90                   	nop

00800e70 <__udivdi3>:
  800e70:	55                   	push   %ebp
  800e71:	57                   	push   %edi
  800e72:	56                   	push   %esi
  800e73:	53                   	push   %ebx
  800e74:	83 ec 1c             	sub    $0x1c,%esp
  800e77:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  800e7b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  800e7f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  800e83:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800e87:	85 f6                	test   %esi,%esi
  800e89:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800e8d:	89 ca                	mov    %ecx,%edx
  800e8f:	89 f8                	mov    %edi,%eax
  800e91:	75 3d                	jne    800ed0 <__udivdi3+0x60>
  800e93:	39 cf                	cmp    %ecx,%edi
  800e95:	0f 87 c5 00 00 00    	ja     800f60 <__udivdi3+0xf0>
  800e9b:	85 ff                	test   %edi,%edi
  800e9d:	89 fd                	mov    %edi,%ebp
  800e9f:	75 0b                	jne    800eac <__udivdi3+0x3c>
  800ea1:	b8 01 00 00 00       	mov    $0x1,%eax
  800ea6:	31 d2                	xor    %edx,%edx
  800ea8:	f7 f7                	div    %edi
  800eaa:	89 c5                	mov    %eax,%ebp
  800eac:	89 c8                	mov    %ecx,%eax
  800eae:	31 d2                	xor    %edx,%edx
  800eb0:	f7 f5                	div    %ebp
  800eb2:	89 c1                	mov    %eax,%ecx
  800eb4:	89 d8                	mov    %ebx,%eax
  800eb6:	89 cf                	mov    %ecx,%edi
  800eb8:	f7 f5                	div    %ebp
  800eba:	89 c3                	mov    %eax,%ebx
  800ebc:	89 d8                	mov    %ebx,%eax
  800ebe:	89 fa                	mov    %edi,%edx
  800ec0:	83 c4 1c             	add    $0x1c,%esp
  800ec3:	5b                   	pop    %ebx
  800ec4:	5e                   	pop    %esi
  800ec5:	5f                   	pop    %edi
  800ec6:	5d                   	pop    %ebp
  800ec7:	c3                   	ret    
  800ec8:	90                   	nop
  800ec9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800ed0:	39 ce                	cmp    %ecx,%esi
  800ed2:	77 74                	ja     800f48 <__udivdi3+0xd8>
  800ed4:	0f bd fe             	bsr    %esi,%edi
  800ed7:	83 f7 1f             	xor    $0x1f,%edi
  800eda:	0f 84 98 00 00 00    	je     800f78 <__udivdi3+0x108>
  800ee0:	bb 20 00 00 00       	mov    $0x20,%ebx
  800ee5:	89 f9                	mov    %edi,%ecx
  800ee7:	89 c5                	mov    %eax,%ebp
  800ee9:	29 fb                	sub    %edi,%ebx
  800eeb:	d3 e6                	shl    %cl,%esi
  800eed:	89 d9                	mov    %ebx,%ecx
  800eef:	d3 ed                	shr    %cl,%ebp
  800ef1:	89 f9                	mov    %edi,%ecx
  800ef3:	d3 e0                	shl    %cl,%eax
  800ef5:	09 ee                	or     %ebp,%esi
  800ef7:	89 d9                	mov    %ebx,%ecx
  800ef9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800efd:	89 d5                	mov    %edx,%ebp
  800eff:	8b 44 24 08          	mov    0x8(%esp),%eax
  800f03:	d3 ed                	shr    %cl,%ebp
  800f05:	89 f9                	mov    %edi,%ecx
  800f07:	d3 e2                	shl    %cl,%edx
  800f09:	89 d9                	mov    %ebx,%ecx
  800f0b:	d3 e8                	shr    %cl,%eax
  800f0d:	09 c2                	or     %eax,%edx
  800f0f:	89 d0                	mov    %edx,%eax
  800f11:	89 ea                	mov    %ebp,%edx
  800f13:	f7 f6                	div    %esi
  800f15:	89 d5                	mov    %edx,%ebp
  800f17:	89 c3                	mov    %eax,%ebx
  800f19:	f7 64 24 0c          	mull   0xc(%esp)
  800f1d:	39 d5                	cmp    %edx,%ebp
  800f1f:	72 10                	jb     800f31 <__udivdi3+0xc1>
  800f21:	8b 74 24 08          	mov    0x8(%esp),%esi
  800f25:	89 f9                	mov    %edi,%ecx
  800f27:	d3 e6                	shl    %cl,%esi
  800f29:	39 c6                	cmp    %eax,%esi
  800f2b:	73 07                	jae    800f34 <__udivdi3+0xc4>
  800f2d:	39 d5                	cmp    %edx,%ebp
  800f2f:	75 03                	jne    800f34 <__udivdi3+0xc4>
  800f31:	83 eb 01             	sub    $0x1,%ebx
  800f34:	31 ff                	xor    %edi,%edi
  800f36:	89 d8                	mov    %ebx,%eax
  800f38:	89 fa                	mov    %edi,%edx
  800f3a:	83 c4 1c             	add    $0x1c,%esp
  800f3d:	5b                   	pop    %ebx
  800f3e:	5e                   	pop    %esi
  800f3f:	5f                   	pop    %edi
  800f40:	5d                   	pop    %ebp
  800f41:	c3                   	ret    
  800f42:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800f48:	31 ff                	xor    %edi,%edi
  800f4a:	31 db                	xor    %ebx,%ebx
  800f4c:	89 d8                	mov    %ebx,%eax
  800f4e:	89 fa                	mov    %edi,%edx
  800f50:	83 c4 1c             	add    $0x1c,%esp
  800f53:	5b                   	pop    %ebx
  800f54:	5e                   	pop    %esi
  800f55:	5f                   	pop    %edi
  800f56:	5d                   	pop    %ebp
  800f57:	c3                   	ret    
  800f58:	90                   	nop
  800f59:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f60:	89 d8                	mov    %ebx,%eax
  800f62:	f7 f7                	div    %edi
  800f64:	31 ff                	xor    %edi,%edi
  800f66:	89 c3                	mov    %eax,%ebx
  800f68:	89 d8                	mov    %ebx,%eax
  800f6a:	89 fa                	mov    %edi,%edx
  800f6c:	83 c4 1c             	add    $0x1c,%esp
  800f6f:	5b                   	pop    %ebx
  800f70:	5e                   	pop    %esi
  800f71:	5f                   	pop    %edi
  800f72:	5d                   	pop    %ebp
  800f73:	c3                   	ret    
  800f74:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f78:	39 ce                	cmp    %ecx,%esi
  800f7a:	72 0c                	jb     800f88 <__udivdi3+0x118>
  800f7c:	31 db                	xor    %ebx,%ebx
  800f7e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  800f82:	0f 87 34 ff ff ff    	ja     800ebc <__udivdi3+0x4c>
  800f88:	bb 01 00 00 00       	mov    $0x1,%ebx
  800f8d:	e9 2a ff ff ff       	jmp    800ebc <__udivdi3+0x4c>
  800f92:	66 90                	xchg   %ax,%ax
  800f94:	66 90                	xchg   %ax,%ax
  800f96:	66 90                	xchg   %ax,%ax
  800f98:	66 90                	xchg   %ax,%ax
  800f9a:	66 90                	xchg   %ax,%ax
  800f9c:	66 90                	xchg   %ax,%ax
  800f9e:	66 90                	xchg   %ax,%ax

00800fa0 <__umoddi3>:
  800fa0:	55                   	push   %ebp
  800fa1:	57                   	push   %edi
  800fa2:	56                   	push   %esi
  800fa3:	53                   	push   %ebx
  800fa4:	83 ec 1c             	sub    $0x1c,%esp
  800fa7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800fab:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  800faf:	8b 74 24 34          	mov    0x34(%esp),%esi
  800fb3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800fb7:	85 d2                	test   %edx,%edx
  800fb9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800fbd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800fc1:	89 f3                	mov    %esi,%ebx
  800fc3:	89 3c 24             	mov    %edi,(%esp)
  800fc6:	89 74 24 04          	mov    %esi,0x4(%esp)
  800fca:	75 1c                	jne    800fe8 <__umoddi3+0x48>
  800fcc:	39 f7                	cmp    %esi,%edi
  800fce:	76 50                	jbe    801020 <__umoddi3+0x80>
  800fd0:	89 c8                	mov    %ecx,%eax
  800fd2:	89 f2                	mov    %esi,%edx
  800fd4:	f7 f7                	div    %edi
  800fd6:	89 d0                	mov    %edx,%eax
  800fd8:	31 d2                	xor    %edx,%edx
  800fda:	83 c4 1c             	add    $0x1c,%esp
  800fdd:	5b                   	pop    %ebx
  800fde:	5e                   	pop    %esi
  800fdf:	5f                   	pop    %edi
  800fe0:	5d                   	pop    %ebp
  800fe1:	c3                   	ret    
  800fe2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800fe8:	39 f2                	cmp    %esi,%edx
  800fea:	89 d0                	mov    %edx,%eax
  800fec:	77 52                	ja     801040 <__umoddi3+0xa0>
  800fee:	0f bd ea             	bsr    %edx,%ebp
  800ff1:	83 f5 1f             	xor    $0x1f,%ebp
  800ff4:	75 5a                	jne    801050 <__umoddi3+0xb0>
  800ff6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  800ffa:	0f 82 e0 00 00 00    	jb     8010e0 <__umoddi3+0x140>
  801000:	39 0c 24             	cmp    %ecx,(%esp)
  801003:	0f 86 d7 00 00 00    	jbe    8010e0 <__umoddi3+0x140>
  801009:	8b 44 24 08          	mov    0x8(%esp),%eax
  80100d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801011:	83 c4 1c             	add    $0x1c,%esp
  801014:	5b                   	pop    %ebx
  801015:	5e                   	pop    %esi
  801016:	5f                   	pop    %edi
  801017:	5d                   	pop    %ebp
  801018:	c3                   	ret    
  801019:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801020:	85 ff                	test   %edi,%edi
  801022:	89 fd                	mov    %edi,%ebp
  801024:	75 0b                	jne    801031 <__umoddi3+0x91>
  801026:	b8 01 00 00 00       	mov    $0x1,%eax
  80102b:	31 d2                	xor    %edx,%edx
  80102d:	f7 f7                	div    %edi
  80102f:	89 c5                	mov    %eax,%ebp
  801031:	89 f0                	mov    %esi,%eax
  801033:	31 d2                	xor    %edx,%edx
  801035:	f7 f5                	div    %ebp
  801037:	89 c8                	mov    %ecx,%eax
  801039:	f7 f5                	div    %ebp
  80103b:	89 d0                	mov    %edx,%eax
  80103d:	eb 99                	jmp    800fd8 <__umoddi3+0x38>
  80103f:	90                   	nop
  801040:	89 c8                	mov    %ecx,%eax
  801042:	89 f2                	mov    %esi,%edx
  801044:	83 c4 1c             	add    $0x1c,%esp
  801047:	5b                   	pop    %ebx
  801048:	5e                   	pop    %esi
  801049:	5f                   	pop    %edi
  80104a:	5d                   	pop    %ebp
  80104b:	c3                   	ret    
  80104c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801050:	8b 34 24             	mov    (%esp),%esi
  801053:	bf 20 00 00 00       	mov    $0x20,%edi
  801058:	89 e9                	mov    %ebp,%ecx
  80105a:	29 ef                	sub    %ebp,%edi
  80105c:	d3 e0                	shl    %cl,%eax
  80105e:	89 f9                	mov    %edi,%ecx
  801060:	89 f2                	mov    %esi,%edx
  801062:	d3 ea                	shr    %cl,%edx
  801064:	89 e9                	mov    %ebp,%ecx
  801066:	09 c2                	or     %eax,%edx
  801068:	89 d8                	mov    %ebx,%eax
  80106a:	89 14 24             	mov    %edx,(%esp)
  80106d:	89 f2                	mov    %esi,%edx
  80106f:	d3 e2                	shl    %cl,%edx
  801071:	89 f9                	mov    %edi,%ecx
  801073:	89 54 24 04          	mov    %edx,0x4(%esp)
  801077:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80107b:	d3 e8                	shr    %cl,%eax
  80107d:	89 e9                	mov    %ebp,%ecx
  80107f:	89 c6                	mov    %eax,%esi
  801081:	d3 e3                	shl    %cl,%ebx
  801083:	89 f9                	mov    %edi,%ecx
  801085:	89 d0                	mov    %edx,%eax
  801087:	d3 e8                	shr    %cl,%eax
  801089:	89 e9                	mov    %ebp,%ecx
  80108b:	09 d8                	or     %ebx,%eax
  80108d:	89 d3                	mov    %edx,%ebx
  80108f:	89 f2                	mov    %esi,%edx
  801091:	f7 34 24             	divl   (%esp)
  801094:	89 d6                	mov    %edx,%esi
  801096:	d3 e3                	shl    %cl,%ebx
  801098:	f7 64 24 04          	mull   0x4(%esp)
  80109c:	39 d6                	cmp    %edx,%esi
  80109e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8010a2:	89 d1                	mov    %edx,%ecx
  8010a4:	89 c3                	mov    %eax,%ebx
  8010a6:	72 08                	jb     8010b0 <__umoddi3+0x110>
  8010a8:	75 11                	jne    8010bb <__umoddi3+0x11b>
  8010aa:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8010ae:	73 0b                	jae    8010bb <__umoddi3+0x11b>
  8010b0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8010b4:	1b 14 24             	sbb    (%esp),%edx
  8010b7:	89 d1                	mov    %edx,%ecx
  8010b9:	89 c3                	mov    %eax,%ebx
  8010bb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8010bf:	29 da                	sub    %ebx,%edx
  8010c1:	19 ce                	sbb    %ecx,%esi
  8010c3:	89 f9                	mov    %edi,%ecx
  8010c5:	89 f0                	mov    %esi,%eax
  8010c7:	d3 e0                	shl    %cl,%eax
  8010c9:	89 e9                	mov    %ebp,%ecx
  8010cb:	d3 ea                	shr    %cl,%edx
  8010cd:	89 e9                	mov    %ebp,%ecx
  8010cf:	d3 ee                	shr    %cl,%esi
  8010d1:	09 d0                	or     %edx,%eax
  8010d3:	89 f2                	mov    %esi,%edx
  8010d5:	83 c4 1c             	add    $0x1c,%esp
  8010d8:	5b                   	pop    %ebx
  8010d9:	5e                   	pop    %esi
  8010da:	5f                   	pop    %edi
  8010db:	5d                   	pop    %ebp
  8010dc:	c3                   	ret    
  8010dd:	8d 76 00             	lea    0x0(%esi),%esi
  8010e0:	29 f9                	sub    %edi,%ecx
  8010e2:	19 d6                	sbb    %edx,%esi
  8010e4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8010e8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8010ec:	e9 18 ff ff ff       	jmp    801009 <__umoddi3+0x69>
