
obj/user/evilhello:     file format elf32-i386


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
  80002c:	e8 19 00 00 00       	call   80004a <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	// try to print the kernel entry point as a string!  mua ha ha!
	sys_cputs((char*)0xf010000c, 100);
  800039:	6a 64                	push   $0x64
  80003b:	68 0c 00 10 f0       	push   $0xf010000c
  800040:	e8 4d 00 00 00       	call   800092 <sys_cputs>
}
  800045:	83 c4 10             	add    $0x10,%esp
  800048:	c9                   	leave  
  800049:	c3                   	ret    

0080004a <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80004a:	55                   	push   %ebp
  80004b:	89 e5                	mov    %esp,%ebp
  80004d:	83 ec 08             	sub    $0x8,%esp
  800050:	8b 45 08             	mov    0x8(%ebp),%eax
  800053:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800056:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  80005d:	00 00 00 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800060:	85 c0                	test   %eax,%eax
  800062:	7e 08                	jle    80006c <libmain+0x22>
		binaryname = argv[0];
  800064:	8b 0a                	mov    (%edx),%ecx
  800066:	89 0d 00 20 80 00    	mov    %ecx,0x802000

	// call user main routine
	umain(argc, argv);
  80006c:	83 ec 08             	sub    $0x8,%esp
  80006f:	52                   	push   %edx
  800070:	50                   	push   %eax
  800071:	e8 bd ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800076:	e8 05 00 00 00       	call   800080 <exit>
}
  80007b:	83 c4 10             	add    $0x10,%esp
  80007e:	c9                   	leave  
  80007f:	c3                   	ret    

00800080 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800080:	55                   	push   %ebp
  800081:	89 e5                	mov    %esp,%ebp
  800083:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800086:	6a 00                	push   $0x0
  800088:	e8 52 00 00 00       	call   8000df <sys_env_destroy>
}
  80008d:	83 c4 10             	add    $0x10,%esp
  800090:	c9                   	leave  
  800091:	c3                   	ret    

00800092 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800092:	55                   	push   %ebp
  800093:	89 e5                	mov    %esp,%ebp
  800095:	57                   	push   %edi
  800096:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800097:	b8 00 00 00 00       	mov    $0x0,%eax
  80009c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80009f:	8b 55 08             	mov    0x8(%ebp),%edx
  8000a2:	89 c3                	mov    %eax,%ebx
  8000a4:	89 c7                	mov    %eax,%edi
  8000a6:	51                   	push   %ecx
  8000a7:	52                   	push   %edx
  8000a8:	53                   	push   %ebx
  8000a9:	54                   	push   %esp
  8000aa:	55                   	push   %ebp
  8000ab:	56                   	push   %esi
  8000ac:	57                   	push   %edi
  8000ad:	5f                   	pop    %edi
  8000ae:	5e                   	pop    %esi
  8000af:	5d                   	pop    %ebp
  8000b0:	5c                   	pop    %esp
  8000b1:	5b                   	pop    %ebx
  8000b2:	5a                   	pop    %edx
  8000b3:	59                   	pop    %ecx

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000b4:	5b                   	pop    %ebx
  8000b5:	5f                   	pop    %edi
  8000b6:	5d                   	pop    %ebp
  8000b7:	c3                   	ret    

008000b8 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000b8:	55                   	push   %ebp
  8000b9:	89 e5                	mov    %esp,%ebp
  8000bb:	57                   	push   %edi
  8000bc:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8000bd:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000c2:	b8 01 00 00 00       	mov    $0x1,%eax
  8000c7:	89 ca                	mov    %ecx,%edx
  8000c9:	89 cb                	mov    %ecx,%ebx
  8000cb:	89 cf                	mov    %ecx,%edi
  8000cd:	51                   	push   %ecx
  8000ce:	52                   	push   %edx
  8000cf:	53                   	push   %ebx
  8000d0:	54                   	push   %esp
  8000d1:	55                   	push   %ebp
  8000d2:	56                   	push   %esi
  8000d3:	57                   	push   %edi
  8000d4:	5f                   	pop    %edi
  8000d5:	5e                   	pop    %esi
  8000d6:	5d                   	pop    %ebp
  8000d7:	5c                   	pop    %esp
  8000d8:	5b                   	pop    %ebx
  8000d9:	5a                   	pop    %edx
  8000da:	59                   	pop    %ecx

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000db:	5b                   	pop    %ebx
  8000dc:	5f                   	pop    %edi
  8000dd:	5d                   	pop    %ebp
  8000de:	c3                   	ret    

008000df <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000df:	55                   	push   %ebp
  8000e0:	89 e5                	mov    %esp,%ebp
  8000e2:	57                   	push   %edi
  8000e3:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8000e4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8000e9:	b8 03 00 00 00       	mov    $0x3,%eax
  8000ee:	8b 55 08             	mov    0x8(%ebp),%edx
  8000f1:	89 d9                	mov    %ebx,%ecx
  8000f3:	89 df                	mov    %ebx,%edi
  8000f5:	51                   	push   %ecx
  8000f6:	52                   	push   %edx
  8000f7:	53                   	push   %ebx
  8000f8:	54                   	push   %esp
  8000f9:	55                   	push   %ebp
  8000fa:	56                   	push   %esi
  8000fb:	57                   	push   %edi
  8000fc:	5f                   	pop    %edi
  8000fd:	5e                   	pop    %esi
  8000fe:	5d                   	pop    %ebp
  8000ff:	5c                   	pop    %esp
  800100:	5b                   	pop    %ebx
  800101:	5a                   	pop    %edx
  800102:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  800103:	85 c0                	test   %eax,%eax
  800105:	7e 17                	jle    80011e <sys_env_destroy+0x3f>
		panic("syscall %d returned %d (> 0)", num, ret);
  800107:	83 ec 0c             	sub    $0xc,%esp
  80010a:	50                   	push   %eax
  80010b:	6a 03                	push   $0x3
  80010d:	68 ae 10 80 00       	push   $0x8010ae
  800112:	6a 26                	push   $0x26
  800114:	68 cb 10 80 00       	push   $0x8010cb
  800119:	e8 7f 00 00 00       	call   80019d <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80011e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800121:	5b                   	pop    %ebx
  800122:	5f                   	pop    %edi
  800123:	5d                   	pop    %ebp
  800124:	c3                   	ret    

00800125 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800125:	55                   	push   %ebp
  800126:	89 e5                	mov    %esp,%ebp
  800128:	57                   	push   %edi
  800129:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80012a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80012f:	b8 02 00 00 00       	mov    $0x2,%eax
  800134:	89 ca                	mov    %ecx,%edx
  800136:	89 cb                	mov    %ecx,%ebx
  800138:	89 cf                	mov    %ecx,%edi
  80013a:	51                   	push   %ecx
  80013b:	52                   	push   %edx
  80013c:	53                   	push   %ebx
  80013d:	54                   	push   %esp
  80013e:	55                   	push   %ebp
  80013f:	56                   	push   %esi
  800140:	57                   	push   %edi
  800141:	5f                   	pop    %edi
  800142:	5e                   	pop    %esi
  800143:	5d                   	pop    %ebp
  800144:	5c                   	pop    %esp
  800145:	5b                   	pop    %ebx
  800146:	5a                   	pop    %edx
  800147:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800148:	5b                   	pop    %ebx
  800149:	5f                   	pop    %edi
  80014a:	5d                   	pop    %ebp
  80014b:	c3                   	ret    

0080014c <sys_map_kernel_page>:

int
sys_map_kernel_page(void* kpage, void* va)
{
  80014c:	55                   	push   %ebp
  80014d:	89 e5                	mov    %esp,%ebp
  80014f:	57                   	push   %edi
  800150:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800151:	bf 00 00 00 00       	mov    $0x0,%edi
  800156:	b8 04 00 00 00       	mov    $0x4,%eax
  80015b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80015e:	8b 55 08             	mov    0x8(%ebp),%edx
  800161:	89 fb                	mov    %edi,%ebx
  800163:	51                   	push   %ecx
  800164:	52                   	push   %edx
  800165:	53                   	push   %ebx
  800166:	54                   	push   %esp
  800167:	55                   	push   %ebp
  800168:	56                   	push   %esi
  800169:	57                   	push   %edi
  80016a:	5f                   	pop    %edi
  80016b:	5e                   	pop    %esi
  80016c:	5d                   	pop    %ebp
  80016d:	5c                   	pop    %esp
  80016e:	5b                   	pop    %ebx
  80016f:	5a                   	pop    %edx
  800170:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  800171:	5b                   	pop    %ebx
  800172:	5f                   	pop    %edi
  800173:	5d                   	pop    %ebp
  800174:	c3                   	ret    

00800175 <sys_sbrk>:

int
sys_sbrk(uint32_t inc)
{
  800175:	55                   	push   %ebp
  800176:	89 e5                	mov    %esp,%ebp
  800178:	57                   	push   %edi
  800179:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80017a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80017f:	b8 05 00 00 00       	mov    $0x5,%eax
  800184:	8b 55 08             	mov    0x8(%ebp),%edx
  800187:	89 cb                	mov    %ecx,%ebx
  800189:	89 cf                	mov    %ecx,%edi
  80018b:	51                   	push   %ecx
  80018c:	52                   	push   %edx
  80018d:	53                   	push   %ebx
  80018e:	54                   	push   %esp
  80018f:	55                   	push   %ebp
  800190:	56                   	push   %esi
  800191:	57                   	push   %edi
  800192:	5f                   	pop    %edi
  800193:	5e                   	pop    %esi
  800194:	5d                   	pop    %ebp
  800195:	5c                   	pop    %esp
  800196:	5b                   	pop    %ebx
  800197:	5a                   	pop    %edx
  800198:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  800199:	5b                   	pop    %ebx
  80019a:	5f                   	pop    %edi
  80019b:	5d                   	pop    %ebp
  80019c:	c3                   	ret    

0080019d <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80019d:	55                   	push   %ebp
  80019e:	89 e5                	mov    %esp,%ebp
  8001a0:	56                   	push   %esi
  8001a1:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8001a2:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	if (argv0)
  8001a5:	a1 08 20 80 00       	mov    0x802008,%eax
  8001aa:	85 c0                	test   %eax,%eax
  8001ac:	74 11                	je     8001bf <_panic+0x22>
		cprintf("%s: ", argv0);
  8001ae:	83 ec 08             	sub    $0x8,%esp
  8001b1:	50                   	push   %eax
  8001b2:	68 d9 10 80 00       	push   $0x8010d9
  8001b7:	e8 d4 00 00 00       	call   800290 <cprintf>
  8001bc:	83 c4 10             	add    $0x10,%esp
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001bf:	8b 35 00 20 80 00    	mov    0x802000,%esi
  8001c5:	e8 5b ff ff ff       	call   800125 <sys_getenvid>
  8001ca:	83 ec 0c             	sub    $0xc,%esp
  8001cd:	ff 75 0c             	pushl  0xc(%ebp)
  8001d0:	ff 75 08             	pushl  0x8(%ebp)
  8001d3:	56                   	push   %esi
  8001d4:	50                   	push   %eax
  8001d5:	68 e0 10 80 00       	push   $0x8010e0
  8001da:	e8 b1 00 00 00       	call   800290 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001df:	83 c4 18             	add    $0x18,%esp
  8001e2:	53                   	push   %ebx
  8001e3:	ff 75 10             	pushl  0x10(%ebp)
  8001e6:	e8 54 00 00 00       	call   80023f <vcprintf>
	cprintf("\n");
  8001eb:	c7 04 24 de 10 80 00 	movl   $0x8010de,(%esp)
  8001f2:	e8 99 00 00 00       	call   800290 <cprintf>
  8001f7:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001fa:	cc                   	int3   
  8001fb:	eb fd                	jmp    8001fa <_panic+0x5d>

008001fd <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001fd:	55                   	push   %ebp
  8001fe:	89 e5                	mov    %esp,%ebp
  800200:	53                   	push   %ebx
  800201:	83 ec 04             	sub    $0x4,%esp
  800204:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800207:	8b 13                	mov    (%ebx),%edx
  800209:	8d 42 01             	lea    0x1(%edx),%eax
  80020c:	89 03                	mov    %eax,(%ebx)
  80020e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800211:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800215:	3d ff 00 00 00       	cmp    $0xff,%eax
  80021a:	75 1a                	jne    800236 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80021c:	83 ec 08             	sub    $0x8,%esp
  80021f:	68 ff 00 00 00       	push   $0xff
  800224:	8d 43 08             	lea    0x8(%ebx),%eax
  800227:	50                   	push   %eax
  800228:	e8 65 fe ff ff       	call   800092 <sys_cputs>
		b->idx = 0;
  80022d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800233:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800236:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80023a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80023d:	c9                   	leave  
  80023e:	c3                   	ret    

0080023f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80023f:	55                   	push   %ebp
  800240:	89 e5                	mov    %esp,%ebp
  800242:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800248:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80024f:	00 00 00 
	b.cnt = 0;
  800252:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800259:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80025c:	ff 75 0c             	pushl  0xc(%ebp)
  80025f:	ff 75 08             	pushl  0x8(%ebp)
  800262:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800268:	50                   	push   %eax
  800269:	68 fd 01 80 00       	push   $0x8001fd
  80026e:	e8 45 02 00 00       	call   8004b8 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800273:	83 c4 08             	add    $0x8,%esp
  800276:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80027c:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800282:	50                   	push   %eax
  800283:	e8 0a fe ff ff       	call   800092 <sys_cputs>

	return b.cnt;
}
  800288:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80028e:	c9                   	leave  
  80028f:	c3                   	ret    

00800290 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800290:	55                   	push   %ebp
  800291:	89 e5                	mov    %esp,%ebp
  800293:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800296:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800299:	50                   	push   %eax
  80029a:	ff 75 08             	pushl  0x8(%ebp)
  80029d:	e8 9d ff ff ff       	call   80023f <vcprintf>
	va_end(ap);

	return cnt;
}
  8002a2:	c9                   	leave  
  8002a3:	c3                   	ret    

008002a4 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002a4:	55                   	push   %ebp
  8002a5:	89 e5                	mov    %esp,%ebp
  8002a7:	57                   	push   %edi
  8002a8:	56                   	push   %esi
  8002a9:	53                   	push   %ebx
  8002aa:	83 ec 1c             	sub    $0x1c,%esp
  8002ad:	89 c7                	mov    %eax,%edi
  8002af:	89 d6                	mov    %edx,%esi
  8002b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002b7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002ba:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	// if cprintf'parameter includes pattern of the form "%-", padding
	// space on the right side if neccesary.
	// you can add helper function if needed.
	// your code here:
	int length,showsign=0;
	if(padc=='-'&&num>=base)
  8002bd:	83 7d 18 2d          	cmpl   $0x2d,0x18(%ebp)
  8002c1:	0f 85 8a 00 00 00    	jne    800351 <printnum+0xad>
  8002c7:	8b 45 10             	mov    0x10(%ebp),%eax
  8002ca:	ba 00 00 00 00       	mov    $0x0,%edx
  8002cf:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8002d2:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8002d5:	39 da                	cmp    %ebx,%edx
  8002d7:	72 09                	jb     8002e2 <printnum+0x3e>
  8002d9:	39 4d 10             	cmp    %ecx,0x10(%ebp)
  8002dc:	0f 87 87 00 00 00    	ja     800369 <printnum+0xc5>
	{
		length=*(int *)putdat;
  8002e2:	8b 1e                	mov    (%esi),%ebx
		printnum(putch,putdat,num/base,base,0,padc);
  8002e4:	83 ec 0c             	sub    $0xc,%esp
  8002e7:	6a 2d                	push   $0x2d
  8002e9:	6a 00                	push   $0x0
  8002eb:	ff 75 10             	pushl  0x10(%ebp)
  8002ee:	83 ec 08             	sub    $0x8,%esp
  8002f1:	52                   	push   %edx
  8002f2:	50                   	push   %eax
  8002f3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002f6:	ff 75 e0             	pushl  -0x20(%ebp)
  8002f9:	e8 22 0b 00 00       	call   800e20 <__udivdi3>
  8002fe:	83 c4 18             	add    $0x18,%esp
  800301:	52                   	push   %edx
  800302:	50                   	push   %eax
  800303:	89 f2                	mov    %esi,%edx
  800305:	89 f8                	mov    %edi,%eax
  800307:	e8 98 ff ff ff       	call   8002a4 <printnum>
		while (--width > 0)
			putch(padc, putdat);
	}
	}
	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80030c:	83 c4 18             	add    $0x18,%esp
  80030f:	56                   	push   %esi
  800310:	8b 45 10             	mov    0x10(%ebp),%eax
  800313:	ba 00 00 00 00       	mov    $0x0,%edx
  800318:	83 ec 04             	sub    $0x4,%esp
  80031b:	52                   	push   %edx
  80031c:	50                   	push   %eax
  80031d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800320:	ff 75 e0             	pushl  -0x20(%ebp)
  800323:	e8 28 0c 00 00       	call   800f50 <__umoddi3>
  800328:	83 c4 14             	add    $0x14,%esp
  80032b:	0f be 80 03 11 80 00 	movsbl 0x801103(%eax),%eax
  800332:	50                   	push   %eax
  800333:	ff d7                	call   *%edi
	
	if(padc=='-'&&width>0)
  800335:	83 c4 10             	add    $0x10,%esp
  800338:	83 7d 18 2d          	cmpl   $0x2d,0x18(%ebp)
  80033c:	0f 85 fa 00 00 00    	jne    80043c <printnum+0x198>
  800342:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
  800346:	0f 8f 9b 00 00 00    	jg     8003e7 <printnum+0x143>
  80034c:	e9 eb 00 00 00       	jmp    80043c <printnum+0x198>
	}
	else
	{
	
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800351:	8b 45 10             	mov    0x10(%ebp),%eax
  800354:	ba 00 00 00 00       	mov    $0x0,%edx
  800359:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80035c:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80035f:	83 fb 00             	cmp    $0x0,%ebx
  800362:	77 14                	ja     800378 <printnum+0xd4>
  800364:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800367:	73 0f                	jae    800378 <printnum+0xd4>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800369:	8b 45 14             	mov    0x14(%ebp),%eax
  80036c:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80036f:	85 db                	test   %ebx,%ebx
  800371:	7f 61                	jg     8003d4 <printnum+0x130>
  800373:	e9 98 00 00 00       	jmp    800410 <printnum+0x16c>
	else
	{
	
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800378:	83 ec 0c             	sub    $0xc,%esp
  80037b:	ff 75 18             	pushl  0x18(%ebp)
  80037e:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800381:	8d 59 ff             	lea    -0x1(%ecx),%ebx
  800384:	53                   	push   %ebx
  800385:	ff 75 10             	pushl  0x10(%ebp)
  800388:	83 ec 08             	sub    $0x8,%esp
  80038b:	52                   	push   %edx
  80038c:	50                   	push   %eax
  80038d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800390:	ff 75 e0             	pushl  -0x20(%ebp)
  800393:	e8 88 0a 00 00       	call   800e20 <__udivdi3>
  800398:	83 c4 18             	add    $0x18,%esp
  80039b:	52                   	push   %edx
  80039c:	50                   	push   %eax
  80039d:	89 f2                	mov    %esi,%edx
  80039f:	89 f8                	mov    %edi,%eax
  8003a1:	e8 fe fe ff ff       	call   8002a4 <printnum>
		while (--width > 0)
			putch(padc, putdat);
	}
	}
	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003a6:	83 c4 18             	add    $0x18,%esp
  8003a9:	56                   	push   %esi
  8003aa:	8b 45 10             	mov    0x10(%ebp),%eax
  8003ad:	ba 00 00 00 00       	mov    $0x0,%edx
  8003b2:	83 ec 04             	sub    $0x4,%esp
  8003b5:	52                   	push   %edx
  8003b6:	50                   	push   %eax
  8003b7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003ba:	ff 75 e0             	pushl  -0x20(%ebp)
  8003bd:	e8 8e 0b 00 00       	call   800f50 <__umoddi3>
  8003c2:	83 c4 14             	add    $0x14,%esp
  8003c5:	0f be 80 03 11 80 00 	movsbl 0x801103(%eax),%eax
  8003cc:	50                   	push   %eax
  8003cd:	ff d7                	call   *%edi
  8003cf:	83 c4 10             	add    $0x10,%esp
  8003d2:	eb 68                	jmp    80043c <printnum+0x198>
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8003d4:	83 ec 08             	sub    $0x8,%esp
  8003d7:	56                   	push   %esi
  8003d8:	ff 75 18             	pushl  0x18(%ebp)
  8003db:	ff d7                	call   *%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003dd:	83 c4 10             	add    $0x10,%esp
  8003e0:	83 eb 01             	sub    $0x1,%ebx
  8003e3:	75 ef                	jne    8003d4 <printnum+0x130>
  8003e5:	eb 29                	jmp    800410 <printnum+0x16c>
	putch("0123456789abcdef"[num % base], putdat);
	
	if(padc=='-'&&width>0)
	{
		length=*(int *)putdat-length;
		for(int i=0;i<width-length;++i)
  8003e7:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ea:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  8003ed:	2b 06                	sub    (%esi),%eax
  8003ef:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003f2:	85 c0                	test   %eax,%eax
  8003f4:	7e 46                	jle    80043c <printnum+0x198>
  8003f6:	bb 00 00 00 00       	mov    $0x0,%ebx
			putch(' ',putdat);
  8003fb:	83 ec 08             	sub    $0x8,%esp
  8003fe:	56                   	push   %esi
  8003ff:	6a 20                	push   $0x20
  800401:	ff d7                	call   *%edi
	putch("0123456789abcdef"[num % base], putdat);
	
	if(padc=='-'&&width>0)
	{
		length=*(int *)putdat-length;
		for(int i=0;i<width-length;++i)
  800403:	83 c3 01             	add    $0x1,%ebx
  800406:	83 c4 10             	add    $0x10,%esp
  800409:	3b 5d e0             	cmp    -0x20(%ebp),%ebx
  80040c:	75 ed                	jne    8003fb <printnum+0x157>
  80040e:	eb 2c                	jmp    80043c <printnum+0x198>
		while (--width > 0)
			putch(padc, putdat);
	}
	}
	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800410:	83 ec 08             	sub    $0x8,%esp
  800413:	56                   	push   %esi
  800414:	8b 45 10             	mov    0x10(%ebp),%eax
  800417:	ba 00 00 00 00       	mov    $0x0,%edx
  80041c:	83 ec 04             	sub    $0x4,%esp
  80041f:	52                   	push   %edx
  800420:	50                   	push   %eax
  800421:	ff 75 e4             	pushl  -0x1c(%ebp)
  800424:	ff 75 e0             	pushl  -0x20(%ebp)
  800427:	e8 24 0b 00 00       	call   800f50 <__umoddi3>
  80042c:	83 c4 14             	add    $0x14,%esp
  80042f:	0f be 80 03 11 80 00 	movsbl 0x801103(%eax),%eax
  800436:	50                   	push   %eax
  800437:	ff d7                	call   *%edi
  800439:	83 c4 10             	add    $0x10,%esp
	{
		length=*(int *)putdat-length;
		for(int i=0;i<width-length;++i)
			putch(' ',putdat);
	}
}
  80043c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80043f:	5b                   	pop    %ebx
  800440:	5e                   	pop    %esi
  800441:	5f                   	pop    %edi
  800442:	5d                   	pop    %ebp
  800443:	c3                   	ret    

00800444 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800444:	55                   	push   %ebp
  800445:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800447:	83 fa 01             	cmp    $0x1,%edx
  80044a:	7e 0e                	jle    80045a <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80044c:	8b 10                	mov    (%eax),%edx
  80044e:	8d 4a 08             	lea    0x8(%edx),%ecx
  800451:	89 08                	mov    %ecx,(%eax)
  800453:	8b 02                	mov    (%edx),%eax
  800455:	8b 52 04             	mov    0x4(%edx),%edx
  800458:	eb 22                	jmp    80047c <getuint+0x38>
	else if (lflag)
  80045a:	85 d2                	test   %edx,%edx
  80045c:	74 10                	je     80046e <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80045e:	8b 10                	mov    (%eax),%edx
  800460:	8d 4a 04             	lea    0x4(%edx),%ecx
  800463:	89 08                	mov    %ecx,(%eax)
  800465:	8b 02                	mov    (%edx),%eax
  800467:	ba 00 00 00 00       	mov    $0x0,%edx
  80046c:	eb 0e                	jmp    80047c <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80046e:	8b 10                	mov    (%eax),%edx
  800470:	8d 4a 04             	lea    0x4(%edx),%ecx
  800473:	89 08                	mov    %ecx,(%eax)
  800475:	8b 02                	mov    (%edx),%eax
  800477:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80047c:	5d                   	pop    %ebp
  80047d:	c3                   	ret    

0080047e <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80047e:	55                   	push   %ebp
  80047f:	89 e5                	mov    %esp,%ebp
  800481:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800484:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800488:	8b 10                	mov    (%eax),%edx
  80048a:	3b 50 04             	cmp    0x4(%eax),%edx
  80048d:	73 0a                	jae    800499 <sprintputch+0x1b>
		*b->buf++ = ch;
  80048f:	8d 4a 01             	lea    0x1(%edx),%ecx
  800492:	89 08                	mov    %ecx,(%eax)
  800494:	8b 45 08             	mov    0x8(%ebp),%eax
  800497:	88 02                	mov    %al,(%edx)
}
  800499:	5d                   	pop    %ebp
  80049a:	c3                   	ret    

0080049b <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80049b:	55                   	push   %ebp
  80049c:	89 e5                	mov    %esp,%ebp
  80049e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8004a1:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004a4:	50                   	push   %eax
  8004a5:	ff 75 10             	pushl  0x10(%ebp)
  8004a8:	ff 75 0c             	pushl  0xc(%ebp)
  8004ab:	ff 75 08             	pushl  0x8(%ebp)
  8004ae:	e8 05 00 00 00       	call   8004b8 <vprintfmt>
	va_end(ap);
}
  8004b3:	83 c4 10             	add    $0x10,%esp
  8004b6:	c9                   	leave  
  8004b7:	c3                   	ret    

008004b8 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8004b8:	55                   	push   %ebp
  8004b9:	89 e5                	mov    %esp,%ebp
  8004bb:	57                   	push   %edi
  8004bc:	56                   	push   %esi
  8004bd:	53                   	push   %ebx
  8004be:	83 ec 2c             	sub    $0x2c,%esp
  8004c1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8004c4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004c7:	eb 03                	jmp    8004cc <vprintfmt+0x14>
			break;
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
			for (fmt--; fmt[-1] != '%'; fmt--)
  8004c9:	89 75 10             	mov    %esi,0x10(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8004cc:	8b 45 10             	mov    0x10(%ebp),%eax
  8004cf:	8d 70 01             	lea    0x1(%eax),%esi
  8004d2:	0f b6 00             	movzbl (%eax),%eax
  8004d5:	83 f8 25             	cmp    $0x25,%eax
  8004d8:	74 27                	je     800501 <vprintfmt+0x49>
			if (ch == '\0')
  8004da:	85 c0                	test   %eax,%eax
  8004dc:	75 0d                	jne    8004eb <vprintfmt+0x33>
  8004de:	e9 8b 04 00 00       	jmp    80096e <vprintfmt+0x4b6>
  8004e3:	85 c0                	test   %eax,%eax
  8004e5:	0f 84 83 04 00 00    	je     80096e <vprintfmt+0x4b6>
				return;
			putch(ch, putdat);
  8004eb:	83 ec 08             	sub    $0x8,%esp
  8004ee:	53                   	push   %ebx
  8004ef:	50                   	push   %eax
  8004f0:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8004f2:	83 c6 01             	add    $0x1,%esi
  8004f5:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  8004f9:	83 c4 10             	add    $0x10,%esp
  8004fc:	83 f8 25             	cmp    $0x25,%eax
  8004ff:	75 e2                	jne    8004e3 <vprintfmt+0x2b>
			padc = '-';
			goto reswitch;
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800501:	c6 45 e3 20          	movb   $0x20,-0x1d(%ebp)
  800505:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80050c:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800513:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80051a:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  800521:	b9 00 00 00 00       	mov    $0x0,%ecx
  800526:	eb 07                	jmp    80052f <vprintfmt+0x77>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800528:	8b 75 10             	mov    0x10(%ebp),%esi

		// flag to show the sign
		case '+':
			padc='+';
  80052b:	c6 45 e3 2b          	movb   $0x2b,-0x1d(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80052f:	8d 46 01             	lea    0x1(%esi),%eax
  800532:	89 45 10             	mov    %eax,0x10(%ebp)
  800535:	0f b6 06             	movzbl (%esi),%eax
  800538:	0f b6 d0             	movzbl %al,%edx
  80053b:	83 e8 23             	sub    $0x23,%eax
  80053e:	3c 55                	cmp    $0x55,%al
  800540:	0f 87 e9 03 00 00    	ja     80092f <vprintfmt+0x477>
  800546:	0f b6 c0             	movzbl %al,%eax
  800549:	ff 24 85 0c 12 80 00 	jmp    *0x80120c(,%eax,4)
  800550:	8b 75 10             	mov    0x10(%ebp),%esi
			padc='+';
			goto reswitch;
		
		// flag to pad on the right
		case '-':
			padc = '-';
  800553:	c6 45 e3 2d          	movb   $0x2d,-0x1d(%ebp)
  800557:	eb d6                	jmp    80052f <vprintfmt+0x77>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800559:	8d 42 d0             	lea    -0x30(%edx),%eax
  80055c:	89 45 d0             	mov    %eax,-0x30(%ebp)
				ch = *fmt;
  80055f:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  800563:	8d 50 d0             	lea    -0x30(%eax),%edx
  800566:	83 fa 09             	cmp    $0x9,%edx
  800569:	77 66                	ja     8005d1 <vprintfmt+0x119>
  80056b:	8b 75 10             	mov    0x10(%ebp),%esi
  80056e:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800571:	89 7d 08             	mov    %edi,0x8(%ebp)
  800574:	eb 09                	jmp    80057f <vprintfmt+0xc7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800576:	8b 75 10             	mov    0x10(%ebp),%esi
			padc = '-';
			goto reswitch;
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800579:	c6 45 e3 30          	movb   $0x30,-0x1d(%ebp)
			goto reswitch;
  80057d:	eb b0                	jmp    80052f <vprintfmt+0x77>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80057f:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  800582:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800585:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  800589:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80058c:	8d 78 d0             	lea    -0x30(%eax),%edi
  80058f:	83 ff 09             	cmp    $0x9,%edi
  800592:	76 eb                	jbe    80057f <vprintfmt+0xc7>
  800594:	89 55 d0             	mov    %edx,-0x30(%ebp)
  800597:	8b 7d 08             	mov    0x8(%ebp),%edi
  80059a:	eb 38                	jmp    8005d4 <vprintfmt+0x11c>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80059c:	8b 45 14             	mov    0x14(%ebp),%eax
  80059f:	8d 50 04             	lea    0x4(%eax),%edx
  8005a2:	89 55 14             	mov    %edx,0x14(%ebp)
  8005a5:	8b 00                	mov    (%eax),%eax
  8005a7:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005aa:	8b 75 10             	mov    0x10(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005ad:	eb 25                	jmp    8005d4 <vprintfmt+0x11c>
  8005af:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005b2:	85 c0                	test   %eax,%eax
  8005b4:	0f 48 c1             	cmovs  %ecx,%eax
  8005b7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ba:	8b 75 10             	mov    0x10(%ebp),%esi
  8005bd:	e9 6d ff ff ff       	jmp    80052f <vprintfmt+0x77>
  8005c2:	8b 75 10             	mov    0x10(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8005c5:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8005cc:	e9 5e ff ff ff       	jmp    80052f <vprintfmt+0x77>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005d1:	8b 75 10             	mov    0x10(%ebp),%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8005d4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005d8:	0f 89 51 ff ff ff    	jns    80052f <vprintfmt+0x77>
				width = precision, precision = -1;
  8005de:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8005e1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8005e4:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8005eb:	e9 3f ff ff ff       	jmp    80052f <vprintfmt+0x77>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8005f0:	83 45 cc 01          	addl   $0x1,-0x34(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005f4:	8b 75 10             	mov    0x10(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8005f7:	e9 33 ff ff ff       	jmp    80052f <vprintfmt+0x77>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8005fc:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ff:	8d 50 04             	lea    0x4(%eax),%edx
  800602:	89 55 14             	mov    %edx,0x14(%ebp)
  800605:	83 ec 08             	sub    $0x8,%esp
  800608:	53                   	push   %ebx
  800609:	ff 30                	pushl  (%eax)
  80060b:	ff d7                	call   *%edi
			break;
  80060d:	83 c4 10             	add    $0x10,%esp
  800610:	e9 b7 fe ff ff       	jmp    8004cc <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800615:	8b 45 14             	mov    0x14(%ebp),%eax
  800618:	8d 50 04             	lea    0x4(%eax),%edx
  80061b:	89 55 14             	mov    %edx,0x14(%ebp)
  80061e:	8b 00                	mov    (%eax),%eax
  800620:	99                   	cltd   
  800621:	31 d0                	xor    %edx,%eax
  800623:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800625:	83 f8 06             	cmp    $0x6,%eax
  800628:	7f 0b                	jg     800635 <vprintfmt+0x17d>
  80062a:	8b 14 85 64 13 80 00 	mov    0x801364(,%eax,4),%edx
  800631:	85 d2                	test   %edx,%edx
  800633:	75 15                	jne    80064a <vprintfmt+0x192>
				printfmt(putch, putdat, "error %d", err);
  800635:	50                   	push   %eax
  800636:	68 1b 11 80 00       	push   $0x80111b
  80063b:	53                   	push   %ebx
  80063c:	57                   	push   %edi
  80063d:	e8 59 fe ff ff       	call   80049b <printfmt>
  800642:	83 c4 10             	add    $0x10,%esp
  800645:	e9 82 fe ff ff       	jmp    8004cc <vprintfmt+0x14>
			else
				printfmt(putch, putdat, "%s", p);
  80064a:	52                   	push   %edx
  80064b:	68 24 11 80 00       	push   $0x801124
  800650:	53                   	push   %ebx
  800651:	57                   	push   %edi
  800652:	e8 44 fe ff ff       	call   80049b <printfmt>
  800657:	83 c4 10             	add    $0x10,%esp
  80065a:	e9 6d fe ff ff       	jmp    8004cc <vprintfmt+0x14>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80065f:	8b 45 14             	mov    0x14(%ebp),%eax
  800662:	8d 50 04             	lea    0x4(%eax),%edx
  800665:	89 55 14             	mov    %edx,0x14(%ebp)
  800668:	8b 00                	mov    (%eax),%eax
				p = "(null)";
  80066a:	85 c0                	test   %eax,%eax
  80066c:	b9 14 11 80 00       	mov    $0x801114,%ecx
  800671:	0f 45 c8             	cmovne %eax,%ecx
  800674:	89 4d cc             	mov    %ecx,-0x34(%ebp)
			if (width > 0 && padc != '-')
  800677:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80067b:	7e 06                	jle    800683 <vprintfmt+0x1cb>
  80067d:	80 7d e3 2d          	cmpb   $0x2d,-0x1d(%ebp)
  800681:	75 19                	jne    80069c <vprintfmt+0x1e4>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800683:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800686:	8d 70 01             	lea    0x1(%eax),%esi
  800689:	0f b6 00             	movzbl (%eax),%eax
  80068c:	0f be d0             	movsbl %al,%edx
  80068f:	85 d2                	test   %edx,%edx
  800691:	0f 85 9f 00 00 00    	jne    800736 <vprintfmt+0x27e>
  800697:	e9 8c 00 00 00       	jmp    800728 <vprintfmt+0x270>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80069c:	83 ec 08             	sub    $0x8,%esp
  80069f:	ff 75 d0             	pushl  -0x30(%ebp)
  8006a2:	ff 75 cc             	pushl  -0x34(%ebp)
  8006a5:	e8 56 03 00 00       	call   800a00 <strnlen>
  8006aa:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  8006ad:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8006b0:	83 c4 10             	add    $0x10,%esp
  8006b3:	85 c9                	test   %ecx,%ecx
  8006b5:	0f 8e 9a 02 00 00    	jle    800955 <vprintfmt+0x49d>
					putch(padc, putdat);
  8006bb:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  8006bf:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006c2:	89 cb                	mov    %ecx,%ebx
  8006c4:	83 ec 08             	sub    $0x8,%esp
  8006c7:	ff 75 0c             	pushl  0xc(%ebp)
  8006ca:	56                   	push   %esi
  8006cb:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006cd:	83 c4 10             	add    $0x10,%esp
  8006d0:	83 eb 01             	sub    $0x1,%ebx
  8006d3:	75 ef                	jne    8006c4 <vprintfmt+0x20c>
  8006d5:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8006d8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006db:	e9 75 02 00 00       	jmp    800955 <vprintfmt+0x49d>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8006e0:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8006e4:	74 1b                	je     800701 <vprintfmt+0x249>
  8006e6:	0f be c0             	movsbl %al,%eax
  8006e9:	83 e8 20             	sub    $0x20,%eax
  8006ec:	83 f8 5e             	cmp    $0x5e,%eax
  8006ef:	76 10                	jbe    800701 <vprintfmt+0x249>
					putch('?', putdat);
  8006f1:	83 ec 08             	sub    $0x8,%esp
  8006f4:	ff 75 0c             	pushl  0xc(%ebp)
  8006f7:	6a 3f                	push   $0x3f
  8006f9:	ff 55 08             	call   *0x8(%ebp)
  8006fc:	83 c4 10             	add    $0x10,%esp
  8006ff:	eb 0d                	jmp    80070e <vprintfmt+0x256>
				else
					putch(ch, putdat);
  800701:	83 ec 08             	sub    $0x8,%esp
  800704:	ff 75 0c             	pushl  0xc(%ebp)
  800707:	52                   	push   %edx
  800708:	ff 55 08             	call   *0x8(%ebp)
  80070b:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80070e:	83 ef 01             	sub    $0x1,%edi
  800711:	83 c6 01             	add    $0x1,%esi
  800714:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  800718:	0f be d0             	movsbl %al,%edx
  80071b:	85 d2                	test   %edx,%edx
  80071d:	75 31                	jne    800750 <vprintfmt+0x298>
  80071f:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800722:	8b 7d 08             	mov    0x8(%ebp),%edi
  800725:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800728:	8b 75 e4             	mov    -0x1c(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80072b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80072f:	7f 33                	jg     800764 <vprintfmt+0x2ac>
  800731:	e9 96 fd ff ff       	jmp    8004cc <vprintfmt+0x14>
  800736:	89 7d 08             	mov    %edi,0x8(%ebp)
  800739:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80073c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80073f:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800742:	eb 0c                	jmp    800750 <vprintfmt+0x298>
  800744:	89 7d 08             	mov    %edi,0x8(%ebp)
  800747:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80074a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80074d:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800750:	85 db                	test   %ebx,%ebx
  800752:	78 8c                	js     8006e0 <vprintfmt+0x228>
  800754:	83 eb 01             	sub    $0x1,%ebx
  800757:	79 87                	jns    8006e0 <vprintfmt+0x228>
  800759:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  80075c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80075f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800762:	eb c4                	jmp    800728 <vprintfmt+0x270>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800764:	83 ec 08             	sub    $0x8,%esp
  800767:	53                   	push   %ebx
  800768:	6a 20                	push   $0x20
  80076a:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80076c:	83 c4 10             	add    $0x10,%esp
  80076f:	83 ee 01             	sub    $0x1,%esi
  800772:	75 f0                	jne    800764 <vprintfmt+0x2ac>
  800774:	e9 53 fd ff ff       	jmp    8004cc <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800779:	83 7d cc 01          	cmpl   $0x1,-0x34(%ebp)
  80077d:	7e 16                	jle    800795 <vprintfmt+0x2dd>
		return va_arg(*ap, long long);
  80077f:	8b 45 14             	mov    0x14(%ebp),%eax
  800782:	8d 50 08             	lea    0x8(%eax),%edx
  800785:	89 55 14             	mov    %edx,0x14(%ebp)
  800788:	8b 50 04             	mov    0x4(%eax),%edx
  80078b:	8b 00                	mov    (%eax),%eax
  80078d:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800790:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800793:	eb 34                	jmp    8007c9 <vprintfmt+0x311>
	else if (lflag)
  800795:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800799:	74 18                	je     8007b3 <vprintfmt+0x2fb>
		return va_arg(*ap, long);
  80079b:	8b 45 14             	mov    0x14(%ebp),%eax
  80079e:	8d 50 04             	lea    0x4(%eax),%edx
  8007a1:	89 55 14             	mov    %edx,0x14(%ebp)
  8007a4:	8b 30                	mov    (%eax),%esi
  8007a6:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8007a9:	89 f0                	mov    %esi,%eax
  8007ab:	c1 f8 1f             	sar    $0x1f,%eax
  8007ae:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8007b1:	eb 16                	jmp    8007c9 <vprintfmt+0x311>
	else
		return va_arg(*ap, int);
  8007b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b6:	8d 50 04             	lea    0x4(%eax),%edx
  8007b9:	89 55 14             	mov    %edx,0x14(%ebp)
  8007bc:	8b 30                	mov    (%eax),%esi
  8007be:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8007c1:	89 f0                	mov    %esi,%eax
  8007c3:	c1 f8 1f             	sar    $0x1f,%eax
  8007c6:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8007c9:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8007cc:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8007cf:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007d2:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  8007d5:	85 d2                	test   %edx,%edx
  8007d7:	79 28                	jns    800801 <vprintfmt+0x349>
				putch('-', putdat);
  8007d9:	83 ec 08             	sub    $0x8,%esp
  8007dc:	53                   	push   %ebx
  8007dd:	6a 2d                	push   $0x2d
  8007df:	ff d7                	call   *%edi
				num = -(long long) num;
  8007e1:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8007e4:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8007e7:	f7 d8                	neg    %eax
  8007e9:	83 d2 00             	adc    $0x0,%edx
  8007ec:	f7 da                	neg    %edx
  8007ee:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007f1:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007f4:	83 c4 10             	add    $0x10,%esp
			else
			{
				if(padc=='+')
					putch('+', putdat);
			}
			base = 10;
  8007f7:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007fc:	e9 a5 00 00 00       	jmp    8008a6 <vprintfmt+0x3ee>
  800801:	b8 0a 00 00 00       	mov    $0xa,%eax
				putch('-', putdat);
				num = -(long long) num;
			}
			else
			{
				if(padc=='+')
  800806:	80 7d e3 2b          	cmpb   $0x2b,-0x1d(%ebp)
  80080a:	0f 85 96 00 00 00    	jne    8008a6 <vprintfmt+0x3ee>
					putch('+', putdat);
  800810:	83 ec 08             	sub    $0x8,%esp
  800813:	53                   	push   %ebx
  800814:	6a 2b                	push   $0x2b
  800816:	ff d7                	call   *%edi
  800818:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80081b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800820:	e9 81 00 00 00       	jmp    8008a6 <vprintfmt+0x3ee>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800825:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800828:	8d 45 14             	lea    0x14(%ebp),%eax
  80082b:	e8 14 fc ff ff       	call   800444 <getuint>
  800830:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800833:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  800836:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80083b:	eb 69                	jmp    8008a6 <vprintfmt+0x3ee>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			putch('0', putdat);
  80083d:	83 ec 08             	sub    $0x8,%esp
  800840:	53                   	push   %ebx
  800841:	6a 30                	push   $0x30
  800843:	ff d7                	call   *%edi
			num = getuint(&ap, lflag);
  800845:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800848:	8d 45 14             	lea    0x14(%ebp),%eax
  80084b:	e8 f4 fb ff ff       	call   800444 <getuint>
  800850:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800853:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
			goto number;
  800856:	83 c4 10             	add    $0x10,%esp
		case 'o':
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
  800859:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  80085e:	eb 46                	jmp    8008a6 <vprintfmt+0x3ee>

		// pointer
		case 'p':
			putch('0', putdat);
  800860:	83 ec 08             	sub    $0x8,%esp
  800863:	53                   	push   %ebx
  800864:	6a 30                	push   $0x30
  800866:	ff d7                	call   *%edi
			putch('x', putdat);
  800868:	83 c4 08             	add    $0x8,%esp
  80086b:	53                   	push   %ebx
  80086c:	6a 78                	push   $0x78
  80086e:	ff d7                	call   *%edi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800870:	8b 45 14             	mov    0x14(%ebp),%eax
  800873:	8d 50 04             	lea    0x4(%eax),%edx
  800876:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800879:	8b 00                	mov    (%eax),%eax
  80087b:	ba 00 00 00 00       	mov    $0x0,%edx
  800880:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800883:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800886:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800889:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80088e:	eb 16                	jmp    8008a6 <vprintfmt+0x3ee>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800890:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800893:	8d 45 14             	lea    0x14(%ebp),%eax
  800896:	e8 a9 fb ff ff       	call   800444 <getuint>
  80089b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80089e:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  8008a1:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8008a6:	83 ec 0c             	sub    $0xc,%esp
  8008a9:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  8008ad:	56                   	push   %esi
  8008ae:	ff 75 e4             	pushl  -0x1c(%ebp)
  8008b1:	50                   	push   %eax
  8008b2:	ff 75 dc             	pushl  -0x24(%ebp)
  8008b5:	ff 75 d8             	pushl  -0x28(%ebp)
  8008b8:	89 da                	mov    %ebx,%edx
  8008ba:	89 f8                	mov    %edi,%eax
  8008bc:	e8 e3 f9 ff ff       	call   8002a4 <printnum>
			break;
  8008c1:	83 c4 20             	add    $0x20,%esp
  8008c4:	e9 03 fc ff ff       	jmp    8004cc <vprintfmt+0x14>

            const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
            const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

            // Your code here
			num=(unsigned long long)(uintptr_t)va_arg(ap, void *);
  8008c9:	8b 45 14             	mov    0x14(%ebp),%eax
  8008cc:	8d 50 04             	lea    0x4(%eax),%edx
  8008cf:	89 55 14             	mov    %edx,0x14(%ebp)
  8008d2:	8b 00                	mov    (%eax),%eax
			if(!num)
  8008d4:	85 c0                	test   %eax,%eax
  8008d6:	75 1c                	jne    8008f4 <vprintfmt+0x43c>
				*(int *)putdat+=cprintf("%s",null_error);
  8008d8:	83 ec 08             	sub    $0x8,%esp
  8008db:	68 90 11 80 00       	push   $0x801190
  8008e0:	68 24 11 80 00       	push   $0x801124
  8008e5:	e8 a6 f9 ff ff       	call   800290 <cprintf>
  8008ea:	01 03                	add    %eax,(%ebx)
  8008ec:	83 c4 10             	add    $0x10,%esp
  8008ef:	e9 d8 fb ff ff       	jmp    8004cc <vprintfmt+0x14>
			else
			{
				*(char *)(int)num=*(int *)putdat;
  8008f4:	8b 13                	mov    (%ebx),%edx
  8008f6:	88 10                	mov    %dl,(%eax)
				if((*(int *)putdat)>128)
  8008f8:	81 3b 80 00 00 00    	cmpl   $0x80,(%ebx)
  8008fe:	0f 8e c8 fb ff ff    	jle    8004cc <vprintfmt+0x14>
					*(int *)putdat+=cprintf("%s",overflow_error);
  800904:	83 ec 08             	sub    $0x8,%esp
  800907:	68 c8 11 80 00       	push   $0x8011c8
  80090c:	68 24 11 80 00       	push   $0x801124
  800911:	e8 7a f9 ff ff       	call   800290 <cprintf>
  800916:	01 03                	add    %eax,(%ebx)
  800918:	83 c4 10             	add    $0x10,%esp
  80091b:	e9 ac fb ff ff       	jmp    8004cc <vprintfmt+0x14>
            break;
        }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800920:	83 ec 08             	sub    $0x8,%esp
  800923:	53                   	push   %ebx
  800924:	52                   	push   %edx
  800925:	ff d7                	call   *%edi
			break;
  800927:	83 c4 10             	add    $0x10,%esp
  80092a:	e9 9d fb ff ff       	jmp    8004cc <vprintfmt+0x14>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80092f:	83 ec 08             	sub    $0x8,%esp
  800932:	53                   	push   %ebx
  800933:	6a 25                	push   $0x25
  800935:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800937:	83 c4 10             	add    $0x10,%esp
  80093a:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80093e:	0f 84 85 fb ff ff    	je     8004c9 <vprintfmt+0x11>
  800944:	83 ee 01             	sub    $0x1,%esi
  800947:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80094b:	75 f7                	jne    800944 <vprintfmt+0x48c>
  80094d:	89 75 10             	mov    %esi,0x10(%ebp)
  800950:	e9 77 fb ff ff       	jmp    8004cc <vprintfmt+0x14>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800955:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800958:	8d 70 01             	lea    0x1(%eax),%esi
  80095b:	0f b6 00             	movzbl (%eax),%eax
  80095e:	0f be d0             	movsbl %al,%edx
  800961:	85 d2                	test   %edx,%edx
  800963:	0f 85 db fd ff ff    	jne    800744 <vprintfmt+0x28c>
  800969:	e9 5e fb ff ff       	jmp    8004cc <vprintfmt+0x14>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  80096e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800971:	5b                   	pop    %ebx
  800972:	5e                   	pop    %esi
  800973:	5f                   	pop    %edi
  800974:	5d                   	pop    %ebp
  800975:	c3                   	ret    

00800976 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800976:	55                   	push   %ebp
  800977:	89 e5                	mov    %esp,%ebp
  800979:	83 ec 18             	sub    $0x18,%esp
  80097c:	8b 45 08             	mov    0x8(%ebp),%eax
  80097f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800982:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800985:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800989:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80098c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800993:	85 c0                	test   %eax,%eax
  800995:	74 26                	je     8009bd <vsnprintf+0x47>
  800997:	85 d2                	test   %edx,%edx
  800999:	7e 22                	jle    8009bd <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80099b:	ff 75 14             	pushl  0x14(%ebp)
  80099e:	ff 75 10             	pushl  0x10(%ebp)
  8009a1:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8009a4:	50                   	push   %eax
  8009a5:	68 7e 04 80 00       	push   $0x80047e
  8009aa:	e8 09 fb ff ff       	call   8004b8 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8009af:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8009b2:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8009b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009b8:	83 c4 10             	add    $0x10,%esp
  8009bb:	eb 05                	jmp    8009c2 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8009bd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8009c2:	c9                   	leave  
  8009c3:	c3                   	ret    

008009c4 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8009c4:	55                   	push   %ebp
  8009c5:	89 e5                	mov    %esp,%ebp
  8009c7:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8009ca:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8009cd:	50                   	push   %eax
  8009ce:	ff 75 10             	pushl  0x10(%ebp)
  8009d1:	ff 75 0c             	pushl  0xc(%ebp)
  8009d4:	ff 75 08             	pushl  0x8(%ebp)
  8009d7:	e8 9a ff ff ff       	call   800976 <vsnprintf>
	va_end(ap);

	return rc;
}
  8009dc:	c9                   	leave  
  8009dd:	c3                   	ret    

008009de <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8009de:	55                   	push   %ebp
  8009df:	89 e5                	mov    %esp,%ebp
  8009e1:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8009e4:	80 3a 00             	cmpb   $0x0,(%edx)
  8009e7:	74 10                	je     8009f9 <strlen+0x1b>
  8009e9:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8009ee:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8009f1:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8009f5:	75 f7                	jne    8009ee <strlen+0x10>
  8009f7:	eb 05                	jmp    8009fe <strlen+0x20>
  8009f9:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8009fe:	5d                   	pop    %ebp
  8009ff:	c3                   	ret    

00800a00 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a00:	55                   	push   %ebp
  800a01:	89 e5                	mov    %esp,%ebp
  800a03:	53                   	push   %ebx
  800a04:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800a07:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a0a:	85 c9                	test   %ecx,%ecx
  800a0c:	74 1c                	je     800a2a <strnlen+0x2a>
  800a0e:	80 3b 00             	cmpb   $0x0,(%ebx)
  800a11:	74 1e                	je     800a31 <strnlen+0x31>
  800a13:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  800a18:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a1a:	39 ca                	cmp    %ecx,%edx
  800a1c:	74 18                	je     800a36 <strnlen+0x36>
  800a1e:	83 c2 01             	add    $0x1,%edx
  800a21:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800a26:	75 f0                	jne    800a18 <strnlen+0x18>
  800a28:	eb 0c                	jmp    800a36 <strnlen+0x36>
  800a2a:	b8 00 00 00 00       	mov    $0x0,%eax
  800a2f:	eb 05                	jmp    800a36 <strnlen+0x36>
  800a31:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800a36:	5b                   	pop    %ebx
  800a37:	5d                   	pop    %ebp
  800a38:	c3                   	ret    

00800a39 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a39:	55                   	push   %ebp
  800a3a:	89 e5                	mov    %esp,%ebp
  800a3c:	53                   	push   %ebx
  800a3d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a40:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a43:	89 c2                	mov    %eax,%edx
  800a45:	83 c2 01             	add    $0x1,%edx
  800a48:	83 c1 01             	add    $0x1,%ecx
  800a4b:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800a4f:	88 5a ff             	mov    %bl,-0x1(%edx)
  800a52:	84 db                	test   %bl,%bl
  800a54:	75 ef                	jne    800a45 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800a56:	5b                   	pop    %ebx
  800a57:	5d                   	pop    %ebp
  800a58:	c3                   	ret    

00800a59 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a59:	55                   	push   %ebp
  800a5a:	89 e5                	mov    %esp,%ebp
  800a5c:	53                   	push   %ebx
  800a5d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a60:	53                   	push   %ebx
  800a61:	e8 78 ff ff ff       	call   8009de <strlen>
  800a66:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800a69:	ff 75 0c             	pushl  0xc(%ebp)
  800a6c:	01 d8                	add    %ebx,%eax
  800a6e:	50                   	push   %eax
  800a6f:	e8 c5 ff ff ff       	call   800a39 <strcpy>
	return dst;
}
  800a74:	89 d8                	mov    %ebx,%eax
  800a76:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a79:	c9                   	leave  
  800a7a:	c3                   	ret    

00800a7b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a7b:	55                   	push   %ebp
  800a7c:	89 e5                	mov    %esp,%ebp
  800a7e:	56                   	push   %esi
  800a7f:	53                   	push   %ebx
  800a80:	8b 75 08             	mov    0x8(%ebp),%esi
  800a83:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a86:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a89:	85 db                	test   %ebx,%ebx
  800a8b:	74 17                	je     800aa4 <strncpy+0x29>
  800a8d:	01 f3                	add    %esi,%ebx
  800a8f:	89 f1                	mov    %esi,%ecx
		*dst++ = *src;
  800a91:	83 c1 01             	add    $0x1,%ecx
  800a94:	0f b6 02             	movzbl (%edx),%eax
  800a97:	88 41 ff             	mov    %al,-0x1(%ecx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a9a:	80 3a 01             	cmpb   $0x1,(%edx)
  800a9d:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800aa0:	39 cb                	cmp    %ecx,%ebx
  800aa2:	75 ed                	jne    800a91 <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800aa4:	89 f0                	mov    %esi,%eax
  800aa6:	5b                   	pop    %ebx
  800aa7:	5e                   	pop    %esi
  800aa8:	5d                   	pop    %ebp
  800aa9:	c3                   	ret    

00800aaa <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800aaa:	55                   	push   %ebp
  800aab:	89 e5                	mov    %esp,%ebp
  800aad:	56                   	push   %esi
  800aae:	53                   	push   %ebx
  800aaf:	8b 75 08             	mov    0x8(%ebp),%esi
  800ab2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ab5:	8b 55 10             	mov    0x10(%ebp),%edx
  800ab8:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800aba:	85 d2                	test   %edx,%edx
  800abc:	74 35                	je     800af3 <strlcpy+0x49>
		while (--size > 0 && *src != '\0')
  800abe:	89 d0                	mov    %edx,%eax
  800ac0:	83 e8 01             	sub    $0x1,%eax
  800ac3:	74 25                	je     800aea <strlcpy+0x40>
  800ac5:	0f b6 0b             	movzbl (%ebx),%ecx
  800ac8:	84 c9                	test   %cl,%cl
  800aca:	74 22                	je     800aee <strlcpy+0x44>
  800acc:	8d 53 01             	lea    0x1(%ebx),%edx
  800acf:	01 c3                	add    %eax,%ebx
  800ad1:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
  800ad3:	83 c0 01             	add    $0x1,%eax
  800ad6:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800ad9:	39 da                	cmp    %ebx,%edx
  800adb:	74 13                	je     800af0 <strlcpy+0x46>
  800add:	83 c2 01             	add    $0x1,%edx
  800ae0:	0f b6 4a ff          	movzbl -0x1(%edx),%ecx
  800ae4:	84 c9                	test   %cl,%cl
  800ae6:	75 eb                	jne    800ad3 <strlcpy+0x29>
  800ae8:	eb 06                	jmp    800af0 <strlcpy+0x46>
  800aea:	89 f0                	mov    %esi,%eax
  800aec:	eb 02                	jmp    800af0 <strlcpy+0x46>
  800aee:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800af0:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800af3:	29 f0                	sub    %esi,%eax
}
  800af5:	5b                   	pop    %ebx
  800af6:	5e                   	pop    %esi
  800af7:	5d                   	pop    %ebp
  800af8:	c3                   	ret    

00800af9 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800af9:	55                   	push   %ebp
  800afa:	89 e5                	mov    %esp,%ebp
  800afc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800aff:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800b02:	0f b6 01             	movzbl (%ecx),%eax
  800b05:	84 c0                	test   %al,%al
  800b07:	74 15                	je     800b1e <strcmp+0x25>
  800b09:	3a 02                	cmp    (%edx),%al
  800b0b:	75 11                	jne    800b1e <strcmp+0x25>
		p++, q++;
  800b0d:	83 c1 01             	add    $0x1,%ecx
  800b10:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800b13:	0f b6 01             	movzbl (%ecx),%eax
  800b16:	84 c0                	test   %al,%al
  800b18:	74 04                	je     800b1e <strcmp+0x25>
  800b1a:	3a 02                	cmp    (%edx),%al
  800b1c:	74 ef                	je     800b0d <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800b1e:	0f b6 c0             	movzbl %al,%eax
  800b21:	0f b6 12             	movzbl (%edx),%edx
  800b24:	29 d0                	sub    %edx,%eax
}
  800b26:	5d                   	pop    %ebp
  800b27:	c3                   	ret    

00800b28 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b28:	55                   	push   %ebp
  800b29:	89 e5                	mov    %esp,%ebp
  800b2b:	56                   	push   %esi
  800b2c:	53                   	push   %ebx
  800b2d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800b30:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b33:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  800b36:	85 f6                	test   %esi,%esi
  800b38:	74 29                	je     800b63 <strncmp+0x3b>
  800b3a:	0f b6 03             	movzbl (%ebx),%eax
  800b3d:	84 c0                	test   %al,%al
  800b3f:	74 30                	je     800b71 <strncmp+0x49>
  800b41:	3a 02                	cmp    (%edx),%al
  800b43:	75 2c                	jne    800b71 <strncmp+0x49>
  800b45:	8d 43 01             	lea    0x1(%ebx),%eax
  800b48:	01 de                	add    %ebx,%esi
		n--, p++, q++;
  800b4a:	89 c3                	mov    %eax,%ebx
  800b4c:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800b4f:	39 c6                	cmp    %eax,%esi
  800b51:	74 17                	je     800b6a <strncmp+0x42>
  800b53:	0f b6 08             	movzbl (%eax),%ecx
  800b56:	84 c9                	test   %cl,%cl
  800b58:	74 17                	je     800b71 <strncmp+0x49>
  800b5a:	83 c0 01             	add    $0x1,%eax
  800b5d:	3a 0a                	cmp    (%edx),%cl
  800b5f:	74 e9                	je     800b4a <strncmp+0x22>
  800b61:	eb 0e                	jmp    800b71 <strncmp+0x49>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800b63:	b8 00 00 00 00       	mov    $0x0,%eax
  800b68:	eb 0f                	jmp    800b79 <strncmp+0x51>
  800b6a:	b8 00 00 00 00       	mov    $0x0,%eax
  800b6f:	eb 08                	jmp    800b79 <strncmp+0x51>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b71:	0f b6 03             	movzbl (%ebx),%eax
  800b74:	0f b6 12             	movzbl (%edx),%edx
  800b77:	29 d0                	sub    %edx,%eax
}
  800b79:	5b                   	pop    %ebx
  800b7a:	5e                   	pop    %esi
  800b7b:	5d                   	pop    %ebp
  800b7c:	c3                   	ret    

00800b7d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b7d:	55                   	push   %ebp
  800b7e:	89 e5                	mov    %esp,%ebp
  800b80:	53                   	push   %ebx
  800b81:	8b 45 08             	mov    0x8(%ebp),%eax
  800b84:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
  800b87:	0f b6 10             	movzbl (%eax),%edx
  800b8a:	84 d2                	test   %dl,%dl
  800b8c:	74 1d                	je     800bab <strchr+0x2e>
  800b8e:	89 d9                	mov    %ebx,%ecx
		if (*s == c)
  800b90:	38 d3                	cmp    %dl,%bl
  800b92:	75 06                	jne    800b9a <strchr+0x1d>
  800b94:	eb 1a                	jmp    800bb0 <strchr+0x33>
  800b96:	38 ca                	cmp    %cl,%dl
  800b98:	74 16                	je     800bb0 <strchr+0x33>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b9a:	83 c0 01             	add    $0x1,%eax
  800b9d:	0f b6 10             	movzbl (%eax),%edx
  800ba0:	84 d2                	test   %dl,%dl
  800ba2:	75 f2                	jne    800b96 <strchr+0x19>
		if (*s == c)
			return (char *) s;
	return 0;
  800ba4:	b8 00 00 00 00       	mov    $0x0,%eax
  800ba9:	eb 05                	jmp    800bb0 <strchr+0x33>
  800bab:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bb0:	5b                   	pop    %ebx
  800bb1:	5d                   	pop    %ebp
  800bb2:	c3                   	ret    

00800bb3 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800bb3:	55                   	push   %ebp
  800bb4:	89 e5                	mov    %esp,%ebp
  800bb6:	53                   	push   %ebx
  800bb7:	8b 45 08             	mov    0x8(%ebp),%eax
  800bba:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  800bbd:	0f b6 18             	movzbl (%eax),%ebx
		if (*s == c)
  800bc0:	38 d3                	cmp    %dl,%bl
  800bc2:	74 14                	je     800bd8 <strfind+0x25>
  800bc4:	89 d1                	mov    %edx,%ecx
  800bc6:	84 db                	test   %bl,%bl
  800bc8:	74 0e                	je     800bd8 <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800bca:	83 c0 01             	add    $0x1,%eax
  800bcd:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800bd0:	38 ca                	cmp    %cl,%dl
  800bd2:	74 04                	je     800bd8 <strfind+0x25>
  800bd4:	84 d2                	test   %dl,%dl
  800bd6:	75 f2                	jne    800bca <strfind+0x17>
			break;
	return (char *) s;
}
  800bd8:	5b                   	pop    %ebx
  800bd9:	5d                   	pop    %ebp
  800bda:	c3                   	ret    

00800bdb <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800bdb:	55                   	push   %ebp
  800bdc:	89 e5                	mov    %esp,%ebp
  800bde:	57                   	push   %edi
  800bdf:	56                   	push   %esi
  800be0:	53                   	push   %ebx
  800be1:	8b 7d 08             	mov    0x8(%ebp),%edi
  800be4:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800be7:	85 c9                	test   %ecx,%ecx
  800be9:	74 36                	je     800c21 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800beb:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800bf1:	75 28                	jne    800c1b <memset+0x40>
  800bf3:	f6 c1 03             	test   $0x3,%cl
  800bf6:	75 23                	jne    800c1b <memset+0x40>
		c &= 0xFF;
  800bf8:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800bfc:	89 d3                	mov    %edx,%ebx
  800bfe:	c1 e3 08             	shl    $0x8,%ebx
  800c01:	89 d6                	mov    %edx,%esi
  800c03:	c1 e6 18             	shl    $0x18,%esi
  800c06:	89 d0                	mov    %edx,%eax
  800c08:	c1 e0 10             	shl    $0x10,%eax
  800c0b:	09 f0                	or     %esi,%eax
  800c0d:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800c0f:	89 d8                	mov    %ebx,%eax
  800c11:	09 d0                	or     %edx,%eax
  800c13:	c1 e9 02             	shr    $0x2,%ecx
  800c16:	fc                   	cld    
  800c17:	f3 ab                	rep stos %eax,%es:(%edi)
  800c19:	eb 06                	jmp    800c21 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800c1b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c1e:	fc                   	cld    
  800c1f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800c21:	89 f8                	mov    %edi,%eax
  800c23:	5b                   	pop    %ebx
  800c24:	5e                   	pop    %esi
  800c25:	5f                   	pop    %edi
  800c26:	5d                   	pop    %ebp
  800c27:	c3                   	ret    

00800c28 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800c28:	55                   	push   %ebp
  800c29:	89 e5                	mov    %esp,%ebp
  800c2b:	57                   	push   %edi
  800c2c:	56                   	push   %esi
  800c2d:	8b 45 08             	mov    0x8(%ebp),%eax
  800c30:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c33:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800c36:	39 c6                	cmp    %eax,%esi
  800c38:	73 35                	jae    800c6f <memmove+0x47>
  800c3a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c3d:	39 d0                	cmp    %edx,%eax
  800c3f:	73 2e                	jae    800c6f <memmove+0x47>
		s += n;
		d += n;
  800c41:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c44:	89 d6                	mov    %edx,%esi
  800c46:	09 fe                	or     %edi,%esi
  800c48:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c4e:	75 13                	jne    800c63 <memmove+0x3b>
  800c50:	f6 c1 03             	test   $0x3,%cl
  800c53:	75 0e                	jne    800c63 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800c55:	83 ef 04             	sub    $0x4,%edi
  800c58:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c5b:	c1 e9 02             	shr    $0x2,%ecx
  800c5e:	fd                   	std    
  800c5f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c61:	eb 09                	jmp    800c6c <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800c63:	83 ef 01             	sub    $0x1,%edi
  800c66:	8d 72 ff             	lea    -0x1(%edx),%esi
  800c69:	fd                   	std    
  800c6a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c6c:	fc                   	cld    
  800c6d:	eb 1d                	jmp    800c8c <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c6f:	89 f2                	mov    %esi,%edx
  800c71:	09 c2                	or     %eax,%edx
  800c73:	f6 c2 03             	test   $0x3,%dl
  800c76:	75 0f                	jne    800c87 <memmove+0x5f>
  800c78:	f6 c1 03             	test   $0x3,%cl
  800c7b:	75 0a                	jne    800c87 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800c7d:	c1 e9 02             	shr    $0x2,%ecx
  800c80:	89 c7                	mov    %eax,%edi
  800c82:	fc                   	cld    
  800c83:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c85:	eb 05                	jmp    800c8c <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c87:	89 c7                	mov    %eax,%edi
  800c89:	fc                   	cld    
  800c8a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c8c:	5e                   	pop    %esi
  800c8d:	5f                   	pop    %edi
  800c8e:	5d                   	pop    %ebp
  800c8f:	c3                   	ret    

00800c90 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800c90:	55                   	push   %ebp
  800c91:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800c93:	ff 75 10             	pushl  0x10(%ebp)
  800c96:	ff 75 0c             	pushl  0xc(%ebp)
  800c99:	ff 75 08             	pushl  0x8(%ebp)
  800c9c:	e8 87 ff ff ff       	call   800c28 <memmove>
}
  800ca1:	c9                   	leave  
  800ca2:	c3                   	ret    

00800ca3 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ca3:	55                   	push   %ebp
  800ca4:	89 e5                	mov    %esp,%ebp
  800ca6:	57                   	push   %edi
  800ca7:	56                   	push   %esi
  800ca8:	53                   	push   %ebx
  800ca9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800cac:	8b 75 0c             	mov    0xc(%ebp),%esi
  800caf:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800cb2:	85 c0                	test   %eax,%eax
  800cb4:	74 39                	je     800cef <memcmp+0x4c>
  800cb6:	8d 78 ff             	lea    -0x1(%eax),%edi
		if (*s1 != *s2)
  800cb9:	0f b6 13             	movzbl (%ebx),%edx
  800cbc:	0f b6 0e             	movzbl (%esi),%ecx
  800cbf:	38 ca                	cmp    %cl,%dl
  800cc1:	75 17                	jne    800cda <memcmp+0x37>
  800cc3:	b8 00 00 00 00       	mov    $0x0,%eax
  800cc8:	eb 1a                	jmp    800ce4 <memcmp+0x41>
  800cca:	0f b6 54 03 01       	movzbl 0x1(%ebx,%eax,1),%edx
  800ccf:	83 c0 01             	add    $0x1,%eax
  800cd2:	0f b6 0c 06          	movzbl (%esi,%eax,1),%ecx
  800cd6:	38 ca                	cmp    %cl,%dl
  800cd8:	74 0a                	je     800ce4 <memcmp+0x41>
			return (int) *s1 - (int) *s2;
  800cda:	0f b6 c2             	movzbl %dl,%eax
  800cdd:	0f b6 c9             	movzbl %cl,%ecx
  800ce0:	29 c8                	sub    %ecx,%eax
  800ce2:	eb 10                	jmp    800cf4 <memcmp+0x51>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ce4:	39 f8                	cmp    %edi,%eax
  800ce6:	75 e2                	jne    800cca <memcmp+0x27>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800ce8:	b8 00 00 00 00       	mov    $0x0,%eax
  800ced:	eb 05                	jmp    800cf4 <memcmp+0x51>
  800cef:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800cf4:	5b                   	pop    %ebx
  800cf5:	5e                   	pop    %esi
  800cf6:	5f                   	pop    %edi
  800cf7:	5d                   	pop    %ebp
  800cf8:	c3                   	ret    

00800cf9 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800cf9:	55                   	push   %ebp
  800cfa:	89 e5                	mov    %esp,%ebp
  800cfc:	53                   	push   %ebx
  800cfd:	8b 55 08             	mov    0x8(%ebp),%edx
	const void *ends = (const char *) s + n;
  800d00:	89 d0                	mov    %edx,%eax
  800d02:	03 45 10             	add    0x10(%ebp),%eax
	for (; s < ends; s++)
  800d05:	39 c2                	cmp    %eax,%edx
  800d07:	73 1d                	jae    800d26 <memfind+0x2d>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d09:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
  800d0d:	0f b6 0a             	movzbl (%edx),%ecx
  800d10:	39 d9                	cmp    %ebx,%ecx
  800d12:	75 09                	jne    800d1d <memfind+0x24>
  800d14:	eb 14                	jmp    800d2a <memfind+0x31>
  800d16:	0f b6 0a             	movzbl (%edx),%ecx
  800d19:	39 d9                	cmp    %ebx,%ecx
  800d1b:	74 11                	je     800d2e <memfind+0x35>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800d1d:	83 c2 01             	add    $0x1,%edx
  800d20:	39 d0                	cmp    %edx,%eax
  800d22:	75 f2                	jne    800d16 <memfind+0x1d>
  800d24:	eb 0a                	jmp    800d30 <memfind+0x37>
  800d26:	89 d0                	mov    %edx,%eax
  800d28:	eb 06                	jmp    800d30 <memfind+0x37>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d2a:	89 d0                	mov    %edx,%eax
  800d2c:	eb 02                	jmp    800d30 <memfind+0x37>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800d2e:	89 d0                	mov    %edx,%eax
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800d30:	5b                   	pop    %ebx
  800d31:	5d                   	pop    %ebp
  800d32:	c3                   	ret    

00800d33 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d33:	55                   	push   %ebp
  800d34:	89 e5                	mov    %esp,%ebp
  800d36:	57                   	push   %edi
  800d37:	56                   	push   %esi
  800d38:	53                   	push   %ebx
  800d39:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d3c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d3f:	0f b6 01             	movzbl (%ecx),%eax
  800d42:	3c 20                	cmp    $0x20,%al
  800d44:	74 04                	je     800d4a <strtol+0x17>
  800d46:	3c 09                	cmp    $0x9,%al
  800d48:	75 0e                	jne    800d58 <strtol+0x25>
		s++;
  800d4a:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d4d:	0f b6 01             	movzbl (%ecx),%eax
  800d50:	3c 20                	cmp    $0x20,%al
  800d52:	74 f6                	je     800d4a <strtol+0x17>
  800d54:	3c 09                	cmp    $0x9,%al
  800d56:	74 f2                	je     800d4a <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  800d58:	3c 2b                	cmp    $0x2b,%al
  800d5a:	75 0a                	jne    800d66 <strtol+0x33>
		s++;
  800d5c:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800d5f:	bf 00 00 00 00       	mov    $0x0,%edi
  800d64:	eb 11                	jmp    800d77 <strtol+0x44>
  800d66:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800d6b:	3c 2d                	cmp    $0x2d,%al
  800d6d:	75 08                	jne    800d77 <strtol+0x44>
		s++, neg = 1;
  800d6f:	83 c1 01             	add    $0x1,%ecx
  800d72:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d77:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800d7d:	75 15                	jne    800d94 <strtol+0x61>
  800d7f:	80 39 30             	cmpb   $0x30,(%ecx)
  800d82:	75 10                	jne    800d94 <strtol+0x61>
  800d84:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800d88:	75 7c                	jne    800e06 <strtol+0xd3>
		s += 2, base = 16;
  800d8a:	83 c1 02             	add    $0x2,%ecx
  800d8d:	bb 10 00 00 00       	mov    $0x10,%ebx
  800d92:	eb 16                	jmp    800daa <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  800d94:	85 db                	test   %ebx,%ebx
  800d96:	75 12                	jne    800daa <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800d98:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800d9d:	80 39 30             	cmpb   $0x30,(%ecx)
  800da0:	75 08                	jne    800daa <strtol+0x77>
		s++, base = 8;
  800da2:	83 c1 01             	add    $0x1,%ecx
  800da5:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800daa:	b8 00 00 00 00       	mov    $0x0,%eax
  800daf:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800db2:	0f b6 11             	movzbl (%ecx),%edx
  800db5:	8d 72 d0             	lea    -0x30(%edx),%esi
  800db8:	89 f3                	mov    %esi,%ebx
  800dba:	80 fb 09             	cmp    $0x9,%bl
  800dbd:	77 08                	ja     800dc7 <strtol+0x94>
			dig = *s - '0';
  800dbf:	0f be d2             	movsbl %dl,%edx
  800dc2:	83 ea 30             	sub    $0x30,%edx
  800dc5:	eb 22                	jmp    800de9 <strtol+0xb6>
		else if (*s >= 'a' && *s <= 'z')
  800dc7:	8d 72 9f             	lea    -0x61(%edx),%esi
  800dca:	89 f3                	mov    %esi,%ebx
  800dcc:	80 fb 19             	cmp    $0x19,%bl
  800dcf:	77 08                	ja     800dd9 <strtol+0xa6>
			dig = *s - 'a' + 10;
  800dd1:	0f be d2             	movsbl %dl,%edx
  800dd4:	83 ea 57             	sub    $0x57,%edx
  800dd7:	eb 10                	jmp    800de9 <strtol+0xb6>
		else if (*s >= 'A' && *s <= 'Z')
  800dd9:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ddc:	89 f3                	mov    %esi,%ebx
  800dde:	80 fb 19             	cmp    $0x19,%bl
  800de1:	77 16                	ja     800df9 <strtol+0xc6>
			dig = *s - 'A' + 10;
  800de3:	0f be d2             	movsbl %dl,%edx
  800de6:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800de9:	3b 55 10             	cmp    0x10(%ebp),%edx
  800dec:	7d 0b                	jge    800df9 <strtol+0xc6>
			break;
		s++, val = (val * base) + dig;
  800dee:	83 c1 01             	add    $0x1,%ecx
  800df1:	0f af 45 10          	imul   0x10(%ebp),%eax
  800df5:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800df7:	eb b9                	jmp    800db2 <strtol+0x7f>

	if (endptr)
  800df9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800dfd:	74 0d                	je     800e0c <strtol+0xd9>
		*endptr = (char *) s;
  800dff:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e02:	89 0e                	mov    %ecx,(%esi)
  800e04:	eb 06                	jmp    800e0c <strtol+0xd9>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800e06:	85 db                	test   %ebx,%ebx
  800e08:	74 98                	je     800da2 <strtol+0x6f>
  800e0a:	eb 9e                	jmp    800daa <strtol+0x77>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800e0c:	89 c2                	mov    %eax,%edx
  800e0e:	f7 da                	neg    %edx
  800e10:	85 ff                	test   %edi,%edi
  800e12:	0f 45 c2             	cmovne %edx,%eax
}
  800e15:	5b                   	pop    %ebx
  800e16:	5e                   	pop    %esi
  800e17:	5f                   	pop    %edi
  800e18:	5d                   	pop    %ebp
  800e19:	c3                   	ret    
  800e1a:	66 90                	xchg   %ax,%ax
  800e1c:	66 90                	xchg   %ax,%ax
  800e1e:	66 90                	xchg   %ax,%ax

00800e20 <__udivdi3>:
  800e20:	55                   	push   %ebp
  800e21:	57                   	push   %edi
  800e22:	56                   	push   %esi
  800e23:	53                   	push   %ebx
  800e24:	83 ec 1c             	sub    $0x1c,%esp
  800e27:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  800e2b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  800e2f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  800e33:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800e37:	85 f6                	test   %esi,%esi
  800e39:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800e3d:	89 ca                	mov    %ecx,%edx
  800e3f:	89 f8                	mov    %edi,%eax
  800e41:	75 3d                	jne    800e80 <__udivdi3+0x60>
  800e43:	39 cf                	cmp    %ecx,%edi
  800e45:	0f 87 c5 00 00 00    	ja     800f10 <__udivdi3+0xf0>
  800e4b:	85 ff                	test   %edi,%edi
  800e4d:	89 fd                	mov    %edi,%ebp
  800e4f:	75 0b                	jne    800e5c <__udivdi3+0x3c>
  800e51:	b8 01 00 00 00       	mov    $0x1,%eax
  800e56:	31 d2                	xor    %edx,%edx
  800e58:	f7 f7                	div    %edi
  800e5a:	89 c5                	mov    %eax,%ebp
  800e5c:	89 c8                	mov    %ecx,%eax
  800e5e:	31 d2                	xor    %edx,%edx
  800e60:	f7 f5                	div    %ebp
  800e62:	89 c1                	mov    %eax,%ecx
  800e64:	89 d8                	mov    %ebx,%eax
  800e66:	89 cf                	mov    %ecx,%edi
  800e68:	f7 f5                	div    %ebp
  800e6a:	89 c3                	mov    %eax,%ebx
  800e6c:	89 d8                	mov    %ebx,%eax
  800e6e:	89 fa                	mov    %edi,%edx
  800e70:	83 c4 1c             	add    $0x1c,%esp
  800e73:	5b                   	pop    %ebx
  800e74:	5e                   	pop    %esi
  800e75:	5f                   	pop    %edi
  800e76:	5d                   	pop    %ebp
  800e77:	c3                   	ret    
  800e78:	90                   	nop
  800e79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e80:	39 ce                	cmp    %ecx,%esi
  800e82:	77 74                	ja     800ef8 <__udivdi3+0xd8>
  800e84:	0f bd fe             	bsr    %esi,%edi
  800e87:	83 f7 1f             	xor    $0x1f,%edi
  800e8a:	0f 84 98 00 00 00    	je     800f28 <__udivdi3+0x108>
  800e90:	bb 20 00 00 00       	mov    $0x20,%ebx
  800e95:	89 f9                	mov    %edi,%ecx
  800e97:	89 c5                	mov    %eax,%ebp
  800e99:	29 fb                	sub    %edi,%ebx
  800e9b:	d3 e6                	shl    %cl,%esi
  800e9d:	89 d9                	mov    %ebx,%ecx
  800e9f:	d3 ed                	shr    %cl,%ebp
  800ea1:	89 f9                	mov    %edi,%ecx
  800ea3:	d3 e0                	shl    %cl,%eax
  800ea5:	09 ee                	or     %ebp,%esi
  800ea7:	89 d9                	mov    %ebx,%ecx
  800ea9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ead:	89 d5                	mov    %edx,%ebp
  800eaf:	8b 44 24 08          	mov    0x8(%esp),%eax
  800eb3:	d3 ed                	shr    %cl,%ebp
  800eb5:	89 f9                	mov    %edi,%ecx
  800eb7:	d3 e2                	shl    %cl,%edx
  800eb9:	89 d9                	mov    %ebx,%ecx
  800ebb:	d3 e8                	shr    %cl,%eax
  800ebd:	09 c2                	or     %eax,%edx
  800ebf:	89 d0                	mov    %edx,%eax
  800ec1:	89 ea                	mov    %ebp,%edx
  800ec3:	f7 f6                	div    %esi
  800ec5:	89 d5                	mov    %edx,%ebp
  800ec7:	89 c3                	mov    %eax,%ebx
  800ec9:	f7 64 24 0c          	mull   0xc(%esp)
  800ecd:	39 d5                	cmp    %edx,%ebp
  800ecf:	72 10                	jb     800ee1 <__udivdi3+0xc1>
  800ed1:	8b 74 24 08          	mov    0x8(%esp),%esi
  800ed5:	89 f9                	mov    %edi,%ecx
  800ed7:	d3 e6                	shl    %cl,%esi
  800ed9:	39 c6                	cmp    %eax,%esi
  800edb:	73 07                	jae    800ee4 <__udivdi3+0xc4>
  800edd:	39 d5                	cmp    %edx,%ebp
  800edf:	75 03                	jne    800ee4 <__udivdi3+0xc4>
  800ee1:	83 eb 01             	sub    $0x1,%ebx
  800ee4:	31 ff                	xor    %edi,%edi
  800ee6:	89 d8                	mov    %ebx,%eax
  800ee8:	89 fa                	mov    %edi,%edx
  800eea:	83 c4 1c             	add    $0x1c,%esp
  800eed:	5b                   	pop    %ebx
  800eee:	5e                   	pop    %esi
  800eef:	5f                   	pop    %edi
  800ef0:	5d                   	pop    %ebp
  800ef1:	c3                   	ret    
  800ef2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800ef8:	31 ff                	xor    %edi,%edi
  800efa:	31 db                	xor    %ebx,%ebx
  800efc:	89 d8                	mov    %ebx,%eax
  800efe:	89 fa                	mov    %edi,%edx
  800f00:	83 c4 1c             	add    $0x1c,%esp
  800f03:	5b                   	pop    %ebx
  800f04:	5e                   	pop    %esi
  800f05:	5f                   	pop    %edi
  800f06:	5d                   	pop    %ebp
  800f07:	c3                   	ret    
  800f08:	90                   	nop
  800f09:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f10:	89 d8                	mov    %ebx,%eax
  800f12:	f7 f7                	div    %edi
  800f14:	31 ff                	xor    %edi,%edi
  800f16:	89 c3                	mov    %eax,%ebx
  800f18:	89 d8                	mov    %ebx,%eax
  800f1a:	89 fa                	mov    %edi,%edx
  800f1c:	83 c4 1c             	add    $0x1c,%esp
  800f1f:	5b                   	pop    %ebx
  800f20:	5e                   	pop    %esi
  800f21:	5f                   	pop    %edi
  800f22:	5d                   	pop    %ebp
  800f23:	c3                   	ret    
  800f24:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f28:	39 ce                	cmp    %ecx,%esi
  800f2a:	72 0c                	jb     800f38 <__udivdi3+0x118>
  800f2c:	31 db                	xor    %ebx,%ebx
  800f2e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  800f32:	0f 87 34 ff ff ff    	ja     800e6c <__udivdi3+0x4c>
  800f38:	bb 01 00 00 00       	mov    $0x1,%ebx
  800f3d:	e9 2a ff ff ff       	jmp    800e6c <__udivdi3+0x4c>
  800f42:	66 90                	xchg   %ax,%ax
  800f44:	66 90                	xchg   %ax,%ax
  800f46:	66 90                	xchg   %ax,%ax
  800f48:	66 90                	xchg   %ax,%ax
  800f4a:	66 90                	xchg   %ax,%ax
  800f4c:	66 90                	xchg   %ax,%ax
  800f4e:	66 90                	xchg   %ax,%ax

00800f50 <__umoddi3>:
  800f50:	55                   	push   %ebp
  800f51:	57                   	push   %edi
  800f52:	56                   	push   %esi
  800f53:	53                   	push   %ebx
  800f54:	83 ec 1c             	sub    $0x1c,%esp
  800f57:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800f5b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  800f5f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800f63:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800f67:	85 d2                	test   %edx,%edx
  800f69:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800f6d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800f71:	89 f3                	mov    %esi,%ebx
  800f73:	89 3c 24             	mov    %edi,(%esp)
  800f76:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f7a:	75 1c                	jne    800f98 <__umoddi3+0x48>
  800f7c:	39 f7                	cmp    %esi,%edi
  800f7e:	76 50                	jbe    800fd0 <__umoddi3+0x80>
  800f80:	89 c8                	mov    %ecx,%eax
  800f82:	89 f2                	mov    %esi,%edx
  800f84:	f7 f7                	div    %edi
  800f86:	89 d0                	mov    %edx,%eax
  800f88:	31 d2                	xor    %edx,%edx
  800f8a:	83 c4 1c             	add    $0x1c,%esp
  800f8d:	5b                   	pop    %ebx
  800f8e:	5e                   	pop    %esi
  800f8f:	5f                   	pop    %edi
  800f90:	5d                   	pop    %ebp
  800f91:	c3                   	ret    
  800f92:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800f98:	39 f2                	cmp    %esi,%edx
  800f9a:	89 d0                	mov    %edx,%eax
  800f9c:	77 52                	ja     800ff0 <__umoddi3+0xa0>
  800f9e:	0f bd ea             	bsr    %edx,%ebp
  800fa1:	83 f5 1f             	xor    $0x1f,%ebp
  800fa4:	75 5a                	jne    801000 <__umoddi3+0xb0>
  800fa6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  800faa:	0f 82 e0 00 00 00    	jb     801090 <__umoddi3+0x140>
  800fb0:	39 0c 24             	cmp    %ecx,(%esp)
  800fb3:	0f 86 d7 00 00 00    	jbe    801090 <__umoddi3+0x140>
  800fb9:	8b 44 24 08          	mov    0x8(%esp),%eax
  800fbd:	8b 54 24 04          	mov    0x4(%esp),%edx
  800fc1:	83 c4 1c             	add    $0x1c,%esp
  800fc4:	5b                   	pop    %ebx
  800fc5:	5e                   	pop    %esi
  800fc6:	5f                   	pop    %edi
  800fc7:	5d                   	pop    %ebp
  800fc8:	c3                   	ret    
  800fc9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800fd0:	85 ff                	test   %edi,%edi
  800fd2:	89 fd                	mov    %edi,%ebp
  800fd4:	75 0b                	jne    800fe1 <__umoddi3+0x91>
  800fd6:	b8 01 00 00 00       	mov    $0x1,%eax
  800fdb:	31 d2                	xor    %edx,%edx
  800fdd:	f7 f7                	div    %edi
  800fdf:	89 c5                	mov    %eax,%ebp
  800fe1:	89 f0                	mov    %esi,%eax
  800fe3:	31 d2                	xor    %edx,%edx
  800fe5:	f7 f5                	div    %ebp
  800fe7:	89 c8                	mov    %ecx,%eax
  800fe9:	f7 f5                	div    %ebp
  800feb:	89 d0                	mov    %edx,%eax
  800fed:	eb 99                	jmp    800f88 <__umoddi3+0x38>
  800fef:	90                   	nop
  800ff0:	89 c8                	mov    %ecx,%eax
  800ff2:	89 f2                	mov    %esi,%edx
  800ff4:	83 c4 1c             	add    $0x1c,%esp
  800ff7:	5b                   	pop    %ebx
  800ff8:	5e                   	pop    %esi
  800ff9:	5f                   	pop    %edi
  800ffa:	5d                   	pop    %ebp
  800ffb:	c3                   	ret    
  800ffc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801000:	8b 34 24             	mov    (%esp),%esi
  801003:	bf 20 00 00 00       	mov    $0x20,%edi
  801008:	89 e9                	mov    %ebp,%ecx
  80100a:	29 ef                	sub    %ebp,%edi
  80100c:	d3 e0                	shl    %cl,%eax
  80100e:	89 f9                	mov    %edi,%ecx
  801010:	89 f2                	mov    %esi,%edx
  801012:	d3 ea                	shr    %cl,%edx
  801014:	89 e9                	mov    %ebp,%ecx
  801016:	09 c2                	or     %eax,%edx
  801018:	89 d8                	mov    %ebx,%eax
  80101a:	89 14 24             	mov    %edx,(%esp)
  80101d:	89 f2                	mov    %esi,%edx
  80101f:	d3 e2                	shl    %cl,%edx
  801021:	89 f9                	mov    %edi,%ecx
  801023:	89 54 24 04          	mov    %edx,0x4(%esp)
  801027:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80102b:	d3 e8                	shr    %cl,%eax
  80102d:	89 e9                	mov    %ebp,%ecx
  80102f:	89 c6                	mov    %eax,%esi
  801031:	d3 e3                	shl    %cl,%ebx
  801033:	89 f9                	mov    %edi,%ecx
  801035:	89 d0                	mov    %edx,%eax
  801037:	d3 e8                	shr    %cl,%eax
  801039:	89 e9                	mov    %ebp,%ecx
  80103b:	09 d8                	or     %ebx,%eax
  80103d:	89 d3                	mov    %edx,%ebx
  80103f:	89 f2                	mov    %esi,%edx
  801041:	f7 34 24             	divl   (%esp)
  801044:	89 d6                	mov    %edx,%esi
  801046:	d3 e3                	shl    %cl,%ebx
  801048:	f7 64 24 04          	mull   0x4(%esp)
  80104c:	39 d6                	cmp    %edx,%esi
  80104e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801052:	89 d1                	mov    %edx,%ecx
  801054:	89 c3                	mov    %eax,%ebx
  801056:	72 08                	jb     801060 <__umoddi3+0x110>
  801058:	75 11                	jne    80106b <__umoddi3+0x11b>
  80105a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80105e:	73 0b                	jae    80106b <__umoddi3+0x11b>
  801060:	2b 44 24 04          	sub    0x4(%esp),%eax
  801064:	1b 14 24             	sbb    (%esp),%edx
  801067:	89 d1                	mov    %edx,%ecx
  801069:	89 c3                	mov    %eax,%ebx
  80106b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80106f:	29 da                	sub    %ebx,%edx
  801071:	19 ce                	sbb    %ecx,%esi
  801073:	89 f9                	mov    %edi,%ecx
  801075:	89 f0                	mov    %esi,%eax
  801077:	d3 e0                	shl    %cl,%eax
  801079:	89 e9                	mov    %ebp,%ecx
  80107b:	d3 ea                	shr    %cl,%edx
  80107d:	89 e9                	mov    %ebp,%ecx
  80107f:	d3 ee                	shr    %cl,%esi
  801081:	09 d0                	or     %edx,%eax
  801083:	89 f2                	mov    %esi,%edx
  801085:	83 c4 1c             	add    $0x1c,%esp
  801088:	5b                   	pop    %ebx
  801089:	5e                   	pop    %esi
  80108a:	5f                   	pop    %edi
  80108b:	5d                   	pop    %ebp
  80108c:	c3                   	ret    
  80108d:	8d 76 00             	lea    0x0(%esi),%esi
  801090:	29 f9                	sub    %edi,%ecx
  801092:	19 d6                	sbb    %edx,%esi
  801094:	89 74 24 04          	mov    %esi,0x4(%esp)
  801098:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80109c:	e9 18 ff ff ff       	jmp    800fb9 <__umoddi3+0x69>
