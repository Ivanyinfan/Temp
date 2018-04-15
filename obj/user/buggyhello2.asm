
obj/user/buggyhello2:     file format elf32-i386


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
  80002c:	e8 1d 00 00 00       	call   80004e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

const char *hello = "hello, world\n";

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	sys_cputs(hello, 1024*1024);
  800039:	68 00 00 10 00       	push   $0x100000
  80003e:	ff 35 00 20 80 00    	pushl  0x802000
  800044:	e8 4d 00 00 00       	call   800096 <sys_cputs>
}
  800049:	83 c4 10             	add    $0x10,%esp
  80004c:	c9                   	leave  
  80004d:	c3                   	ret    

0080004e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80004e:	55                   	push   %ebp
  80004f:	89 e5                	mov    %esp,%ebp
  800051:	83 ec 08             	sub    $0x8,%esp
  800054:	8b 45 08             	mov    0x8(%ebp),%eax
  800057:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  80005a:	c7 05 08 20 80 00 00 	movl   $0x0,0x802008
  800061:	00 00 00 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800064:	85 c0                	test   %eax,%eax
  800066:	7e 08                	jle    800070 <libmain+0x22>
		binaryname = argv[0];
  800068:	8b 0a                	mov    (%edx),%ecx
  80006a:	89 0d 04 20 80 00    	mov    %ecx,0x802004

	// call user main routine
	umain(argc, argv);
  800070:	83 ec 08             	sub    $0x8,%esp
  800073:	52                   	push   %edx
  800074:	50                   	push   %eax
  800075:	e8 b9 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80007a:	e8 05 00 00 00       	call   800084 <exit>
}
  80007f:	83 c4 10             	add    $0x10,%esp
  800082:	c9                   	leave  
  800083:	c3                   	ret    

00800084 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800084:	55                   	push   %ebp
  800085:	89 e5                	mov    %esp,%ebp
  800087:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80008a:	6a 00                	push   $0x0
  80008c:	e8 52 00 00 00       	call   8000e3 <sys_env_destroy>
}
  800091:	83 c4 10             	add    $0x10,%esp
  800094:	c9                   	leave  
  800095:	c3                   	ret    

00800096 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800096:	55                   	push   %ebp
  800097:	89 e5                	mov    %esp,%ebp
  800099:	57                   	push   %edi
  80009a:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80009b:	b8 00 00 00 00       	mov    $0x0,%eax
  8000a0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000a3:	8b 55 08             	mov    0x8(%ebp),%edx
  8000a6:	89 c3                	mov    %eax,%ebx
  8000a8:	89 c7                	mov    %eax,%edi
  8000aa:	51                   	push   %ecx
  8000ab:	52                   	push   %edx
  8000ac:	53                   	push   %ebx
  8000ad:	54                   	push   %esp
  8000ae:	55                   	push   %ebp
  8000af:	56                   	push   %esi
  8000b0:	57                   	push   %edi
  8000b1:	5f                   	pop    %edi
  8000b2:	5e                   	pop    %esi
  8000b3:	5d                   	pop    %ebp
  8000b4:	5c                   	pop    %esp
  8000b5:	5b                   	pop    %ebx
  8000b6:	5a                   	pop    %edx
  8000b7:	59                   	pop    %ecx

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000b8:	5b                   	pop    %ebx
  8000b9:	5f                   	pop    %edi
  8000ba:	5d                   	pop    %ebp
  8000bb:	c3                   	ret    

008000bc <sys_cgetc>:

int
sys_cgetc(void)
{
  8000bc:	55                   	push   %ebp
  8000bd:	89 e5                	mov    %esp,%ebp
  8000bf:	57                   	push   %edi
  8000c0:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8000c1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000c6:	b8 01 00 00 00       	mov    $0x1,%eax
  8000cb:	89 ca                	mov    %ecx,%edx
  8000cd:	89 cb                	mov    %ecx,%ebx
  8000cf:	89 cf                	mov    %ecx,%edi
  8000d1:	51                   	push   %ecx
  8000d2:	52                   	push   %edx
  8000d3:	53                   	push   %ebx
  8000d4:	54                   	push   %esp
  8000d5:	55                   	push   %ebp
  8000d6:	56                   	push   %esi
  8000d7:	57                   	push   %edi
  8000d8:	5f                   	pop    %edi
  8000d9:	5e                   	pop    %esi
  8000da:	5d                   	pop    %ebp
  8000db:	5c                   	pop    %esp
  8000dc:	5b                   	pop    %ebx
  8000dd:	5a                   	pop    %edx
  8000de:	59                   	pop    %ecx

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000df:	5b                   	pop    %ebx
  8000e0:	5f                   	pop    %edi
  8000e1:	5d                   	pop    %ebp
  8000e2:	c3                   	ret    

008000e3 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000e3:	55                   	push   %ebp
  8000e4:	89 e5                	mov    %esp,%ebp
  8000e6:	57                   	push   %edi
  8000e7:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8000e8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8000ed:	b8 03 00 00 00       	mov    $0x3,%eax
  8000f2:	8b 55 08             	mov    0x8(%ebp),%edx
  8000f5:	89 d9                	mov    %ebx,%ecx
  8000f7:	89 df                	mov    %ebx,%edi
  8000f9:	51                   	push   %ecx
  8000fa:	52                   	push   %edx
  8000fb:	53                   	push   %ebx
  8000fc:	54                   	push   %esp
  8000fd:	55                   	push   %ebp
  8000fe:	56                   	push   %esi
  8000ff:	57                   	push   %edi
  800100:	5f                   	pop    %edi
  800101:	5e                   	pop    %esi
  800102:	5d                   	pop    %ebp
  800103:	5c                   	pop    %esp
  800104:	5b                   	pop    %ebx
  800105:	5a                   	pop    %edx
  800106:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  800107:	85 c0                	test   %eax,%eax
  800109:	7e 17                	jle    800122 <sys_env_destroy+0x3f>
		panic("syscall %d returned %d (> 0)", num, ret);
  80010b:	83 ec 0c             	sub    $0xc,%esp
  80010e:	50                   	push   %eax
  80010f:	6a 03                	push   $0x3
  800111:	68 bc 10 80 00       	push   $0x8010bc
  800116:	6a 26                	push   $0x26
  800118:	68 d9 10 80 00       	push   $0x8010d9
  80011d:	e8 7f 00 00 00       	call   8001a1 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800122:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800125:	5b                   	pop    %ebx
  800126:	5f                   	pop    %edi
  800127:	5d                   	pop    %ebp
  800128:	c3                   	ret    

00800129 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800129:	55                   	push   %ebp
  80012a:	89 e5                	mov    %esp,%ebp
  80012c:	57                   	push   %edi
  80012d:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80012e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800133:	b8 02 00 00 00       	mov    $0x2,%eax
  800138:	89 ca                	mov    %ecx,%edx
  80013a:	89 cb                	mov    %ecx,%ebx
  80013c:	89 cf                	mov    %ecx,%edi
  80013e:	51                   	push   %ecx
  80013f:	52                   	push   %edx
  800140:	53                   	push   %ebx
  800141:	54                   	push   %esp
  800142:	55                   	push   %ebp
  800143:	56                   	push   %esi
  800144:	57                   	push   %edi
  800145:	5f                   	pop    %edi
  800146:	5e                   	pop    %esi
  800147:	5d                   	pop    %ebp
  800148:	5c                   	pop    %esp
  800149:	5b                   	pop    %ebx
  80014a:	5a                   	pop    %edx
  80014b:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80014c:	5b                   	pop    %ebx
  80014d:	5f                   	pop    %edi
  80014e:	5d                   	pop    %ebp
  80014f:	c3                   	ret    

00800150 <sys_map_kernel_page>:

int
sys_map_kernel_page(void* kpage, void* va)
{
  800150:	55                   	push   %ebp
  800151:	89 e5                	mov    %esp,%ebp
  800153:	57                   	push   %edi
  800154:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800155:	bf 00 00 00 00       	mov    $0x0,%edi
  80015a:	b8 04 00 00 00       	mov    $0x4,%eax
  80015f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800162:	8b 55 08             	mov    0x8(%ebp),%edx
  800165:	89 fb                	mov    %edi,%ebx
  800167:	51                   	push   %ecx
  800168:	52                   	push   %edx
  800169:	53                   	push   %ebx
  80016a:	54                   	push   %esp
  80016b:	55                   	push   %ebp
  80016c:	56                   	push   %esi
  80016d:	57                   	push   %edi
  80016e:	5f                   	pop    %edi
  80016f:	5e                   	pop    %esi
  800170:	5d                   	pop    %ebp
  800171:	5c                   	pop    %esp
  800172:	5b                   	pop    %ebx
  800173:	5a                   	pop    %edx
  800174:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  800175:	5b                   	pop    %ebx
  800176:	5f                   	pop    %edi
  800177:	5d                   	pop    %ebp
  800178:	c3                   	ret    

00800179 <sys_sbrk>:

int
sys_sbrk(uint32_t inc)
{
  800179:	55                   	push   %ebp
  80017a:	89 e5                	mov    %esp,%ebp
  80017c:	57                   	push   %edi
  80017d:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80017e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800183:	b8 05 00 00 00       	mov    $0x5,%eax
  800188:	8b 55 08             	mov    0x8(%ebp),%edx
  80018b:	89 cb                	mov    %ecx,%ebx
  80018d:	89 cf                	mov    %ecx,%edi
  80018f:	51                   	push   %ecx
  800190:	52                   	push   %edx
  800191:	53                   	push   %ebx
  800192:	54                   	push   %esp
  800193:	55                   	push   %ebp
  800194:	56                   	push   %esi
  800195:	57                   	push   %edi
  800196:	5f                   	pop    %edi
  800197:	5e                   	pop    %esi
  800198:	5d                   	pop    %ebp
  800199:	5c                   	pop    %esp
  80019a:	5b                   	pop    %ebx
  80019b:	5a                   	pop    %edx
  80019c:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  80019d:	5b                   	pop    %ebx
  80019e:	5f                   	pop    %edi
  80019f:	5d                   	pop    %ebp
  8001a0:	c3                   	ret    

008001a1 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8001a1:	55                   	push   %ebp
  8001a2:	89 e5                	mov    %esp,%ebp
  8001a4:	56                   	push   %esi
  8001a5:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8001a6:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	if (argv0)
  8001a9:	a1 0c 20 80 00       	mov    0x80200c,%eax
  8001ae:	85 c0                	test   %eax,%eax
  8001b0:	74 11                	je     8001c3 <_panic+0x22>
		cprintf("%s: ", argv0);
  8001b2:	83 ec 08             	sub    $0x8,%esp
  8001b5:	50                   	push   %eax
  8001b6:	68 e7 10 80 00       	push   $0x8010e7
  8001bb:	e8 d4 00 00 00       	call   800294 <cprintf>
  8001c0:	83 c4 10             	add    $0x10,%esp
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001c3:	8b 35 04 20 80 00    	mov    0x802004,%esi
  8001c9:	e8 5b ff ff ff       	call   800129 <sys_getenvid>
  8001ce:	83 ec 0c             	sub    $0xc,%esp
  8001d1:	ff 75 0c             	pushl  0xc(%ebp)
  8001d4:	ff 75 08             	pushl  0x8(%ebp)
  8001d7:	56                   	push   %esi
  8001d8:	50                   	push   %eax
  8001d9:	68 ec 10 80 00       	push   $0x8010ec
  8001de:	e8 b1 00 00 00       	call   800294 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001e3:	83 c4 18             	add    $0x18,%esp
  8001e6:	53                   	push   %ebx
  8001e7:	ff 75 10             	pushl  0x10(%ebp)
  8001ea:	e8 54 00 00 00       	call   800243 <vcprintf>
	cprintf("\n");
  8001ef:	c7 04 24 b0 10 80 00 	movl   $0x8010b0,(%esp)
  8001f6:	e8 99 00 00 00       	call   800294 <cprintf>
  8001fb:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001fe:	cc                   	int3   
  8001ff:	eb fd                	jmp    8001fe <_panic+0x5d>

00800201 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800201:	55                   	push   %ebp
  800202:	89 e5                	mov    %esp,%ebp
  800204:	53                   	push   %ebx
  800205:	83 ec 04             	sub    $0x4,%esp
  800208:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80020b:	8b 13                	mov    (%ebx),%edx
  80020d:	8d 42 01             	lea    0x1(%edx),%eax
  800210:	89 03                	mov    %eax,(%ebx)
  800212:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800215:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800219:	3d ff 00 00 00       	cmp    $0xff,%eax
  80021e:	75 1a                	jne    80023a <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800220:	83 ec 08             	sub    $0x8,%esp
  800223:	68 ff 00 00 00       	push   $0xff
  800228:	8d 43 08             	lea    0x8(%ebx),%eax
  80022b:	50                   	push   %eax
  80022c:	e8 65 fe ff ff       	call   800096 <sys_cputs>
		b->idx = 0;
  800231:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800237:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80023a:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80023e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800241:	c9                   	leave  
  800242:	c3                   	ret    

00800243 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800243:	55                   	push   %ebp
  800244:	89 e5                	mov    %esp,%ebp
  800246:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80024c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800253:	00 00 00 
	b.cnt = 0;
  800256:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80025d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800260:	ff 75 0c             	pushl  0xc(%ebp)
  800263:	ff 75 08             	pushl  0x8(%ebp)
  800266:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80026c:	50                   	push   %eax
  80026d:	68 01 02 80 00       	push   $0x800201
  800272:	e8 45 02 00 00       	call   8004bc <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800277:	83 c4 08             	add    $0x8,%esp
  80027a:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800280:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800286:	50                   	push   %eax
  800287:	e8 0a fe ff ff       	call   800096 <sys_cputs>

	return b.cnt;
}
  80028c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800292:	c9                   	leave  
  800293:	c3                   	ret    

00800294 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800294:	55                   	push   %ebp
  800295:	89 e5                	mov    %esp,%ebp
  800297:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80029a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80029d:	50                   	push   %eax
  80029e:	ff 75 08             	pushl  0x8(%ebp)
  8002a1:	e8 9d ff ff ff       	call   800243 <vcprintf>
	va_end(ap);

	return cnt;
}
  8002a6:	c9                   	leave  
  8002a7:	c3                   	ret    

008002a8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002a8:	55                   	push   %ebp
  8002a9:	89 e5                	mov    %esp,%ebp
  8002ab:	57                   	push   %edi
  8002ac:	56                   	push   %esi
  8002ad:	53                   	push   %ebx
  8002ae:	83 ec 1c             	sub    $0x1c,%esp
  8002b1:	89 c7                	mov    %eax,%edi
  8002b3:	89 d6                	mov    %edx,%esi
  8002b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002bb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002be:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	// if cprintf'parameter includes pattern of the form "%-", padding
	// space on the right side if neccesary.
	// you can add helper function if needed.
	// your code here:
	int length,showsign=0;
	if(padc=='-'&&num>=base)
  8002c1:	83 7d 18 2d          	cmpl   $0x2d,0x18(%ebp)
  8002c5:	0f 85 8a 00 00 00    	jne    800355 <printnum+0xad>
  8002cb:	8b 45 10             	mov    0x10(%ebp),%eax
  8002ce:	ba 00 00 00 00       	mov    $0x0,%edx
  8002d3:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8002d6:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8002d9:	39 da                	cmp    %ebx,%edx
  8002db:	72 09                	jb     8002e6 <printnum+0x3e>
  8002dd:	39 4d 10             	cmp    %ecx,0x10(%ebp)
  8002e0:	0f 87 87 00 00 00    	ja     80036d <printnum+0xc5>
	{
		length=*(int *)putdat;
  8002e6:	8b 1e                	mov    (%esi),%ebx
		printnum(putch,putdat,num/base,base,0,padc);
  8002e8:	83 ec 0c             	sub    $0xc,%esp
  8002eb:	6a 2d                	push   $0x2d
  8002ed:	6a 00                	push   $0x0
  8002ef:	ff 75 10             	pushl  0x10(%ebp)
  8002f2:	83 ec 08             	sub    $0x8,%esp
  8002f5:	52                   	push   %edx
  8002f6:	50                   	push   %eax
  8002f7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002fa:	ff 75 e0             	pushl  -0x20(%ebp)
  8002fd:	e8 1e 0b 00 00       	call   800e20 <__udivdi3>
  800302:	83 c4 18             	add    $0x18,%esp
  800305:	52                   	push   %edx
  800306:	50                   	push   %eax
  800307:	89 f2                	mov    %esi,%edx
  800309:	89 f8                	mov    %edi,%eax
  80030b:	e8 98 ff ff ff       	call   8002a8 <printnum>
		while (--width > 0)
			putch(padc, putdat);
	}
	}
	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800310:	83 c4 18             	add    $0x18,%esp
  800313:	56                   	push   %esi
  800314:	8b 45 10             	mov    0x10(%ebp),%eax
  800317:	ba 00 00 00 00       	mov    $0x0,%edx
  80031c:	83 ec 04             	sub    $0x4,%esp
  80031f:	52                   	push   %edx
  800320:	50                   	push   %eax
  800321:	ff 75 e4             	pushl  -0x1c(%ebp)
  800324:	ff 75 e0             	pushl  -0x20(%ebp)
  800327:	e8 24 0c 00 00       	call   800f50 <__umoddi3>
  80032c:	83 c4 14             	add    $0x14,%esp
  80032f:	0f be 80 0f 11 80 00 	movsbl 0x80110f(%eax),%eax
  800336:	50                   	push   %eax
  800337:	ff d7                	call   *%edi
	
	if(padc=='-'&&width>0)
  800339:	83 c4 10             	add    $0x10,%esp
  80033c:	83 7d 18 2d          	cmpl   $0x2d,0x18(%ebp)
  800340:	0f 85 fa 00 00 00    	jne    800440 <printnum+0x198>
  800346:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
  80034a:	0f 8f 9b 00 00 00    	jg     8003eb <printnum+0x143>
  800350:	e9 eb 00 00 00       	jmp    800440 <printnum+0x198>
	}
	else
	{
	
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800355:	8b 45 10             	mov    0x10(%ebp),%eax
  800358:	ba 00 00 00 00       	mov    $0x0,%edx
  80035d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800360:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800363:	83 fb 00             	cmp    $0x0,%ebx
  800366:	77 14                	ja     80037c <printnum+0xd4>
  800368:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  80036b:	73 0f                	jae    80037c <printnum+0xd4>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80036d:	8b 45 14             	mov    0x14(%ebp),%eax
  800370:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800373:	85 db                	test   %ebx,%ebx
  800375:	7f 61                	jg     8003d8 <printnum+0x130>
  800377:	e9 98 00 00 00       	jmp    800414 <printnum+0x16c>
	else
	{
	
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80037c:	83 ec 0c             	sub    $0xc,%esp
  80037f:	ff 75 18             	pushl  0x18(%ebp)
  800382:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800385:	8d 59 ff             	lea    -0x1(%ecx),%ebx
  800388:	53                   	push   %ebx
  800389:	ff 75 10             	pushl  0x10(%ebp)
  80038c:	83 ec 08             	sub    $0x8,%esp
  80038f:	52                   	push   %edx
  800390:	50                   	push   %eax
  800391:	ff 75 e4             	pushl  -0x1c(%ebp)
  800394:	ff 75 e0             	pushl  -0x20(%ebp)
  800397:	e8 84 0a 00 00       	call   800e20 <__udivdi3>
  80039c:	83 c4 18             	add    $0x18,%esp
  80039f:	52                   	push   %edx
  8003a0:	50                   	push   %eax
  8003a1:	89 f2                	mov    %esi,%edx
  8003a3:	89 f8                	mov    %edi,%eax
  8003a5:	e8 fe fe ff ff       	call   8002a8 <printnum>
		while (--width > 0)
			putch(padc, putdat);
	}
	}
	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003aa:	83 c4 18             	add    $0x18,%esp
  8003ad:	56                   	push   %esi
  8003ae:	8b 45 10             	mov    0x10(%ebp),%eax
  8003b1:	ba 00 00 00 00       	mov    $0x0,%edx
  8003b6:	83 ec 04             	sub    $0x4,%esp
  8003b9:	52                   	push   %edx
  8003ba:	50                   	push   %eax
  8003bb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003be:	ff 75 e0             	pushl  -0x20(%ebp)
  8003c1:	e8 8a 0b 00 00       	call   800f50 <__umoddi3>
  8003c6:	83 c4 14             	add    $0x14,%esp
  8003c9:	0f be 80 0f 11 80 00 	movsbl 0x80110f(%eax),%eax
  8003d0:	50                   	push   %eax
  8003d1:	ff d7                	call   *%edi
  8003d3:	83 c4 10             	add    $0x10,%esp
  8003d6:	eb 68                	jmp    800440 <printnum+0x198>
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8003d8:	83 ec 08             	sub    $0x8,%esp
  8003db:	56                   	push   %esi
  8003dc:	ff 75 18             	pushl  0x18(%ebp)
  8003df:	ff d7                	call   *%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003e1:	83 c4 10             	add    $0x10,%esp
  8003e4:	83 eb 01             	sub    $0x1,%ebx
  8003e7:	75 ef                	jne    8003d8 <printnum+0x130>
  8003e9:	eb 29                	jmp    800414 <printnum+0x16c>
	putch("0123456789abcdef"[num % base], putdat);
	
	if(padc=='-'&&width>0)
	{
		length=*(int *)putdat-length;
		for(int i=0;i<width-length;++i)
  8003eb:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ee:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  8003f1:	2b 06                	sub    (%esi),%eax
  8003f3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003f6:	85 c0                	test   %eax,%eax
  8003f8:	7e 46                	jle    800440 <printnum+0x198>
  8003fa:	bb 00 00 00 00       	mov    $0x0,%ebx
			putch(' ',putdat);
  8003ff:	83 ec 08             	sub    $0x8,%esp
  800402:	56                   	push   %esi
  800403:	6a 20                	push   $0x20
  800405:	ff d7                	call   *%edi
	putch("0123456789abcdef"[num % base], putdat);
	
	if(padc=='-'&&width>0)
	{
		length=*(int *)putdat-length;
		for(int i=0;i<width-length;++i)
  800407:	83 c3 01             	add    $0x1,%ebx
  80040a:	83 c4 10             	add    $0x10,%esp
  80040d:	3b 5d e0             	cmp    -0x20(%ebp),%ebx
  800410:	75 ed                	jne    8003ff <printnum+0x157>
  800412:	eb 2c                	jmp    800440 <printnum+0x198>
		while (--width > 0)
			putch(padc, putdat);
	}
	}
	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800414:	83 ec 08             	sub    $0x8,%esp
  800417:	56                   	push   %esi
  800418:	8b 45 10             	mov    0x10(%ebp),%eax
  80041b:	ba 00 00 00 00       	mov    $0x0,%edx
  800420:	83 ec 04             	sub    $0x4,%esp
  800423:	52                   	push   %edx
  800424:	50                   	push   %eax
  800425:	ff 75 e4             	pushl  -0x1c(%ebp)
  800428:	ff 75 e0             	pushl  -0x20(%ebp)
  80042b:	e8 20 0b 00 00       	call   800f50 <__umoddi3>
  800430:	83 c4 14             	add    $0x14,%esp
  800433:	0f be 80 0f 11 80 00 	movsbl 0x80110f(%eax),%eax
  80043a:	50                   	push   %eax
  80043b:	ff d7                	call   *%edi
  80043d:	83 c4 10             	add    $0x10,%esp
	{
		length=*(int *)putdat-length;
		for(int i=0;i<width-length;++i)
			putch(' ',putdat);
	}
}
  800440:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800443:	5b                   	pop    %ebx
  800444:	5e                   	pop    %esi
  800445:	5f                   	pop    %edi
  800446:	5d                   	pop    %ebp
  800447:	c3                   	ret    

00800448 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800448:	55                   	push   %ebp
  800449:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80044b:	83 fa 01             	cmp    $0x1,%edx
  80044e:	7e 0e                	jle    80045e <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800450:	8b 10                	mov    (%eax),%edx
  800452:	8d 4a 08             	lea    0x8(%edx),%ecx
  800455:	89 08                	mov    %ecx,(%eax)
  800457:	8b 02                	mov    (%edx),%eax
  800459:	8b 52 04             	mov    0x4(%edx),%edx
  80045c:	eb 22                	jmp    800480 <getuint+0x38>
	else if (lflag)
  80045e:	85 d2                	test   %edx,%edx
  800460:	74 10                	je     800472 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800462:	8b 10                	mov    (%eax),%edx
  800464:	8d 4a 04             	lea    0x4(%edx),%ecx
  800467:	89 08                	mov    %ecx,(%eax)
  800469:	8b 02                	mov    (%edx),%eax
  80046b:	ba 00 00 00 00       	mov    $0x0,%edx
  800470:	eb 0e                	jmp    800480 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800472:	8b 10                	mov    (%eax),%edx
  800474:	8d 4a 04             	lea    0x4(%edx),%ecx
  800477:	89 08                	mov    %ecx,(%eax)
  800479:	8b 02                	mov    (%edx),%eax
  80047b:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800480:	5d                   	pop    %ebp
  800481:	c3                   	ret    

00800482 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800482:	55                   	push   %ebp
  800483:	89 e5                	mov    %esp,%ebp
  800485:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800488:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80048c:	8b 10                	mov    (%eax),%edx
  80048e:	3b 50 04             	cmp    0x4(%eax),%edx
  800491:	73 0a                	jae    80049d <sprintputch+0x1b>
		*b->buf++ = ch;
  800493:	8d 4a 01             	lea    0x1(%edx),%ecx
  800496:	89 08                	mov    %ecx,(%eax)
  800498:	8b 45 08             	mov    0x8(%ebp),%eax
  80049b:	88 02                	mov    %al,(%edx)
}
  80049d:	5d                   	pop    %ebp
  80049e:	c3                   	ret    

0080049f <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80049f:	55                   	push   %ebp
  8004a0:	89 e5                	mov    %esp,%ebp
  8004a2:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8004a5:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004a8:	50                   	push   %eax
  8004a9:	ff 75 10             	pushl  0x10(%ebp)
  8004ac:	ff 75 0c             	pushl  0xc(%ebp)
  8004af:	ff 75 08             	pushl  0x8(%ebp)
  8004b2:	e8 05 00 00 00       	call   8004bc <vprintfmt>
	va_end(ap);
}
  8004b7:	83 c4 10             	add    $0x10,%esp
  8004ba:	c9                   	leave  
  8004bb:	c3                   	ret    

008004bc <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8004bc:	55                   	push   %ebp
  8004bd:	89 e5                	mov    %esp,%ebp
  8004bf:	57                   	push   %edi
  8004c0:	56                   	push   %esi
  8004c1:	53                   	push   %ebx
  8004c2:	83 ec 2c             	sub    $0x2c,%esp
  8004c5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8004c8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004cb:	eb 03                	jmp    8004d0 <vprintfmt+0x14>
			break;
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
			for (fmt--; fmt[-1] != '%'; fmt--)
  8004cd:	89 75 10             	mov    %esi,0x10(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8004d0:	8b 45 10             	mov    0x10(%ebp),%eax
  8004d3:	8d 70 01             	lea    0x1(%eax),%esi
  8004d6:	0f b6 00             	movzbl (%eax),%eax
  8004d9:	83 f8 25             	cmp    $0x25,%eax
  8004dc:	74 27                	je     800505 <vprintfmt+0x49>
			if (ch == '\0')
  8004de:	85 c0                	test   %eax,%eax
  8004e0:	75 0d                	jne    8004ef <vprintfmt+0x33>
  8004e2:	e9 8b 04 00 00       	jmp    800972 <vprintfmt+0x4b6>
  8004e7:	85 c0                	test   %eax,%eax
  8004e9:	0f 84 83 04 00 00    	je     800972 <vprintfmt+0x4b6>
				return;
			putch(ch, putdat);
  8004ef:	83 ec 08             	sub    $0x8,%esp
  8004f2:	53                   	push   %ebx
  8004f3:	50                   	push   %eax
  8004f4:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8004f6:	83 c6 01             	add    $0x1,%esi
  8004f9:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  8004fd:	83 c4 10             	add    $0x10,%esp
  800500:	83 f8 25             	cmp    $0x25,%eax
  800503:	75 e2                	jne    8004e7 <vprintfmt+0x2b>
			padc = '-';
			goto reswitch;
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800505:	c6 45 e3 20          	movb   $0x20,-0x1d(%ebp)
  800509:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800510:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800517:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80051e:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  800525:	b9 00 00 00 00       	mov    $0x0,%ecx
  80052a:	eb 07                	jmp    800533 <vprintfmt+0x77>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80052c:	8b 75 10             	mov    0x10(%ebp),%esi

		// flag to show the sign
		case '+':
			padc='+';
  80052f:	c6 45 e3 2b          	movb   $0x2b,-0x1d(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800533:	8d 46 01             	lea    0x1(%esi),%eax
  800536:	89 45 10             	mov    %eax,0x10(%ebp)
  800539:	0f b6 06             	movzbl (%esi),%eax
  80053c:	0f b6 d0             	movzbl %al,%edx
  80053f:	83 e8 23             	sub    $0x23,%eax
  800542:	3c 55                	cmp    $0x55,%al
  800544:	0f 87 e9 03 00 00    	ja     800933 <vprintfmt+0x477>
  80054a:	0f b6 c0             	movzbl %al,%eax
  80054d:	ff 24 85 18 12 80 00 	jmp    *0x801218(,%eax,4)
  800554:	8b 75 10             	mov    0x10(%ebp),%esi
			padc='+';
			goto reswitch;
		
		// flag to pad on the right
		case '-':
			padc = '-';
  800557:	c6 45 e3 2d          	movb   $0x2d,-0x1d(%ebp)
  80055b:	eb d6                	jmp    800533 <vprintfmt+0x77>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80055d:	8d 42 d0             	lea    -0x30(%edx),%eax
  800560:	89 45 d0             	mov    %eax,-0x30(%ebp)
				ch = *fmt;
  800563:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  800567:	8d 50 d0             	lea    -0x30(%eax),%edx
  80056a:	83 fa 09             	cmp    $0x9,%edx
  80056d:	77 66                	ja     8005d5 <vprintfmt+0x119>
  80056f:	8b 75 10             	mov    0x10(%ebp),%esi
  800572:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800575:	89 7d 08             	mov    %edi,0x8(%ebp)
  800578:	eb 09                	jmp    800583 <vprintfmt+0xc7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80057a:	8b 75 10             	mov    0x10(%ebp),%esi
			padc = '-';
			goto reswitch;
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80057d:	c6 45 e3 30          	movb   $0x30,-0x1d(%ebp)
			goto reswitch;
  800581:	eb b0                	jmp    800533 <vprintfmt+0x77>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800583:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  800586:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800589:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  80058d:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800590:	8d 78 d0             	lea    -0x30(%eax),%edi
  800593:	83 ff 09             	cmp    $0x9,%edi
  800596:	76 eb                	jbe    800583 <vprintfmt+0xc7>
  800598:	89 55 d0             	mov    %edx,-0x30(%ebp)
  80059b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80059e:	eb 38                	jmp    8005d8 <vprintfmt+0x11c>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005a0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a3:	8d 50 04             	lea    0x4(%eax),%edx
  8005a6:	89 55 14             	mov    %edx,0x14(%ebp)
  8005a9:	8b 00                	mov    (%eax),%eax
  8005ab:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ae:	8b 75 10             	mov    0x10(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005b1:	eb 25                	jmp    8005d8 <vprintfmt+0x11c>
  8005b3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005b6:	85 c0                	test   %eax,%eax
  8005b8:	0f 48 c1             	cmovs  %ecx,%eax
  8005bb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005be:	8b 75 10             	mov    0x10(%ebp),%esi
  8005c1:	e9 6d ff ff ff       	jmp    800533 <vprintfmt+0x77>
  8005c6:	8b 75 10             	mov    0x10(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8005c9:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8005d0:	e9 5e ff ff ff       	jmp    800533 <vprintfmt+0x77>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005d5:	8b 75 10             	mov    0x10(%ebp),%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8005d8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005dc:	0f 89 51 ff ff ff    	jns    800533 <vprintfmt+0x77>
				width = precision, precision = -1;
  8005e2:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8005e5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8005e8:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8005ef:	e9 3f ff ff ff       	jmp    800533 <vprintfmt+0x77>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8005f4:	83 45 cc 01          	addl   $0x1,-0x34(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005f8:	8b 75 10             	mov    0x10(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8005fb:	e9 33 ff ff ff       	jmp    800533 <vprintfmt+0x77>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800600:	8b 45 14             	mov    0x14(%ebp),%eax
  800603:	8d 50 04             	lea    0x4(%eax),%edx
  800606:	89 55 14             	mov    %edx,0x14(%ebp)
  800609:	83 ec 08             	sub    $0x8,%esp
  80060c:	53                   	push   %ebx
  80060d:	ff 30                	pushl  (%eax)
  80060f:	ff d7                	call   *%edi
			break;
  800611:	83 c4 10             	add    $0x10,%esp
  800614:	e9 b7 fe ff ff       	jmp    8004d0 <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800619:	8b 45 14             	mov    0x14(%ebp),%eax
  80061c:	8d 50 04             	lea    0x4(%eax),%edx
  80061f:	89 55 14             	mov    %edx,0x14(%ebp)
  800622:	8b 00                	mov    (%eax),%eax
  800624:	99                   	cltd   
  800625:	31 d0                	xor    %edx,%eax
  800627:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800629:	83 f8 06             	cmp    $0x6,%eax
  80062c:	7f 0b                	jg     800639 <vprintfmt+0x17d>
  80062e:	8b 14 85 70 13 80 00 	mov    0x801370(,%eax,4),%edx
  800635:	85 d2                	test   %edx,%edx
  800637:	75 15                	jne    80064e <vprintfmt+0x192>
				printfmt(putch, putdat, "error %d", err);
  800639:	50                   	push   %eax
  80063a:	68 27 11 80 00       	push   $0x801127
  80063f:	53                   	push   %ebx
  800640:	57                   	push   %edi
  800641:	e8 59 fe ff ff       	call   80049f <printfmt>
  800646:	83 c4 10             	add    $0x10,%esp
  800649:	e9 82 fe ff ff       	jmp    8004d0 <vprintfmt+0x14>
			else
				printfmt(putch, putdat, "%s", p);
  80064e:	52                   	push   %edx
  80064f:	68 30 11 80 00       	push   $0x801130
  800654:	53                   	push   %ebx
  800655:	57                   	push   %edi
  800656:	e8 44 fe ff ff       	call   80049f <printfmt>
  80065b:	83 c4 10             	add    $0x10,%esp
  80065e:	e9 6d fe ff ff       	jmp    8004d0 <vprintfmt+0x14>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800663:	8b 45 14             	mov    0x14(%ebp),%eax
  800666:	8d 50 04             	lea    0x4(%eax),%edx
  800669:	89 55 14             	mov    %edx,0x14(%ebp)
  80066c:	8b 00                	mov    (%eax),%eax
				p = "(null)";
  80066e:	85 c0                	test   %eax,%eax
  800670:	b9 20 11 80 00       	mov    $0x801120,%ecx
  800675:	0f 45 c8             	cmovne %eax,%ecx
  800678:	89 4d cc             	mov    %ecx,-0x34(%ebp)
			if (width > 0 && padc != '-')
  80067b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80067f:	7e 06                	jle    800687 <vprintfmt+0x1cb>
  800681:	80 7d e3 2d          	cmpb   $0x2d,-0x1d(%ebp)
  800685:	75 19                	jne    8006a0 <vprintfmt+0x1e4>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800687:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80068a:	8d 70 01             	lea    0x1(%eax),%esi
  80068d:	0f b6 00             	movzbl (%eax),%eax
  800690:	0f be d0             	movsbl %al,%edx
  800693:	85 d2                	test   %edx,%edx
  800695:	0f 85 9f 00 00 00    	jne    80073a <vprintfmt+0x27e>
  80069b:	e9 8c 00 00 00       	jmp    80072c <vprintfmt+0x270>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006a0:	83 ec 08             	sub    $0x8,%esp
  8006a3:	ff 75 d0             	pushl  -0x30(%ebp)
  8006a6:	ff 75 cc             	pushl  -0x34(%ebp)
  8006a9:	e8 56 03 00 00       	call   800a04 <strnlen>
  8006ae:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  8006b1:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8006b4:	83 c4 10             	add    $0x10,%esp
  8006b7:	85 c9                	test   %ecx,%ecx
  8006b9:	0f 8e 9a 02 00 00    	jle    800959 <vprintfmt+0x49d>
					putch(padc, putdat);
  8006bf:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  8006c3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006c6:	89 cb                	mov    %ecx,%ebx
  8006c8:	83 ec 08             	sub    $0x8,%esp
  8006cb:	ff 75 0c             	pushl  0xc(%ebp)
  8006ce:	56                   	push   %esi
  8006cf:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006d1:	83 c4 10             	add    $0x10,%esp
  8006d4:	83 eb 01             	sub    $0x1,%ebx
  8006d7:	75 ef                	jne    8006c8 <vprintfmt+0x20c>
  8006d9:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8006dc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006df:	e9 75 02 00 00       	jmp    800959 <vprintfmt+0x49d>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8006e4:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8006e8:	74 1b                	je     800705 <vprintfmt+0x249>
  8006ea:	0f be c0             	movsbl %al,%eax
  8006ed:	83 e8 20             	sub    $0x20,%eax
  8006f0:	83 f8 5e             	cmp    $0x5e,%eax
  8006f3:	76 10                	jbe    800705 <vprintfmt+0x249>
					putch('?', putdat);
  8006f5:	83 ec 08             	sub    $0x8,%esp
  8006f8:	ff 75 0c             	pushl  0xc(%ebp)
  8006fb:	6a 3f                	push   $0x3f
  8006fd:	ff 55 08             	call   *0x8(%ebp)
  800700:	83 c4 10             	add    $0x10,%esp
  800703:	eb 0d                	jmp    800712 <vprintfmt+0x256>
				else
					putch(ch, putdat);
  800705:	83 ec 08             	sub    $0x8,%esp
  800708:	ff 75 0c             	pushl  0xc(%ebp)
  80070b:	52                   	push   %edx
  80070c:	ff 55 08             	call   *0x8(%ebp)
  80070f:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800712:	83 ef 01             	sub    $0x1,%edi
  800715:	83 c6 01             	add    $0x1,%esi
  800718:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  80071c:	0f be d0             	movsbl %al,%edx
  80071f:	85 d2                	test   %edx,%edx
  800721:	75 31                	jne    800754 <vprintfmt+0x298>
  800723:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800726:	8b 7d 08             	mov    0x8(%ebp),%edi
  800729:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80072c:	8b 75 e4             	mov    -0x1c(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80072f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800733:	7f 33                	jg     800768 <vprintfmt+0x2ac>
  800735:	e9 96 fd ff ff       	jmp    8004d0 <vprintfmt+0x14>
  80073a:	89 7d 08             	mov    %edi,0x8(%ebp)
  80073d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800740:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800743:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800746:	eb 0c                	jmp    800754 <vprintfmt+0x298>
  800748:	89 7d 08             	mov    %edi,0x8(%ebp)
  80074b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80074e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800751:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800754:	85 db                	test   %ebx,%ebx
  800756:	78 8c                	js     8006e4 <vprintfmt+0x228>
  800758:	83 eb 01             	sub    $0x1,%ebx
  80075b:	79 87                	jns    8006e4 <vprintfmt+0x228>
  80075d:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800760:	8b 7d 08             	mov    0x8(%ebp),%edi
  800763:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800766:	eb c4                	jmp    80072c <vprintfmt+0x270>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800768:	83 ec 08             	sub    $0x8,%esp
  80076b:	53                   	push   %ebx
  80076c:	6a 20                	push   $0x20
  80076e:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800770:	83 c4 10             	add    $0x10,%esp
  800773:	83 ee 01             	sub    $0x1,%esi
  800776:	75 f0                	jne    800768 <vprintfmt+0x2ac>
  800778:	e9 53 fd ff ff       	jmp    8004d0 <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80077d:	83 7d cc 01          	cmpl   $0x1,-0x34(%ebp)
  800781:	7e 16                	jle    800799 <vprintfmt+0x2dd>
		return va_arg(*ap, long long);
  800783:	8b 45 14             	mov    0x14(%ebp),%eax
  800786:	8d 50 08             	lea    0x8(%eax),%edx
  800789:	89 55 14             	mov    %edx,0x14(%ebp)
  80078c:	8b 50 04             	mov    0x4(%eax),%edx
  80078f:	8b 00                	mov    (%eax),%eax
  800791:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800794:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800797:	eb 34                	jmp    8007cd <vprintfmt+0x311>
	else if (lflag)
  800799:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  80079d:	74 18                	je     8007b7 <vprintfmt+0x2fb>
		return va_arg(*ap, long);
  80079f:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a2:	8d 50 04             	lea    0x4(%eax),%edx
  8007a5:	89 55 14             	mov    %edx,0x14(%ebp)
  8007a8:	8b 30                	mov    (%eax),%esi
  8007aa:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8007ad:	89 f0                	mov    %esi,%eax
  8007af:	c1 f8 1f             	sar    $0x1f,%eax
  8007b2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8007b5:	eb 16                	jmp    8007cd <vprintfmt+0x311>
	else
		return va_arg(*ap, int);
  8007b7:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ba:	8d 50 04             	lea    0x4(%eax),%edx
  8007bd:	89 55 14             	mov    %edx,0x14(%ebp)
  8007c0:	8b 30                	mov    (%eax),%esi
  8007c2:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8007c5:	89 f0                	mov    %esi,%eax
  8007c7:	c1 f8 1f             	sar    $0x1f,%eax
  8007ca:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8007cd:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8007d0:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8007d3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007d6:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  8007d9:	85 d2                	test   %edx,%edx
  8007db:	79 28                	jns    800805 <vprintfmt+0x349>
				putch('-', putdat);
  8007dd:	83 ec 08             	sub    $0x8,%esp
  8007e0:	53                   	push   %ebx
  8007e1:	6a 2d                	push   $0x2d
  8007e3:	ff d7                	call   *%edi
				num = -(long long) num;
  8007e5:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8007e8:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8007eb:	f7 d8                	neg    %eax
  8007ed:	83 d2 00             	adc    $0x0,%edx
  8007f0:	f7 da                	neg    %edx
  8007f2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007f5:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007f8:	83 c4 10             	add    $0x10,%esp
			else
			{
				if(padc=='+')
					putch('+', putdat);
			}
			base = 10;
  8007fb:	b8 0a 00 00 00       	mov    $0xa,%eax
  800800:	e9 a5 00 00 00       	jmp    8008aa <vprintfmt+0x3ee>
  800805:	b8 0a 00 00 00       	mov    $0xa,%eax
				putch('-', putdat);
				num = -(long long) num;
			}
			else
			{
				if(padc=='+')
  80080a:	80 7d e3 2b          	cmpb   $0x2b,-0x1d(%ebp)
  80080e:	0f 85 96 00 00 00    	jne    8008aa <vprintfmt+0x3ee>
					putch('+', putdat);
  800814:	83 ec 08             	sub    $0x8,%esp
  800817:	53                   	push   %ebx
  800818:	6a 2b                	push   $0x2b
  80081a:	ff d7                	call   *%edi
  80081c:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80081f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800824:	e9 81 00 00 00       	jmp    8008aa <vprintfmt+0x3ee>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800829:	8b 55 cc             	mov    -0x34(%ebp),%edx
  80082c:	8d 45 14             	lea    0x14(%ebp),%eax
  80082f:	e8 14 fc ff ff       	call   800448 <getuint>
  800834:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800837:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  80083a:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80083f:	eb 69                	jmp    8008aa <vprintfmt+0x3ee>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			putch('0', putdat);
  800841:	83 ec 08             	sub    $0x8,%esp
  800844:	53                   	push   %ebx
  800845:	6a 30                	push   $0x30
  800847:	ff d7                	call   *%edi
			num = getuint(&ap, lflag);
  800849:	8b 55 cc             	mov    -0x34(%ebp),%edx
  80084c:	8d 45 14             	lea    0x14(%ebp),%eax
  80084f:	e8 f4 fb ff ff       	call   800448 <getuint>
  800854:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800857:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
			goto number;
  80085a:	83 c4 10             	add    $0x10,%esp
		case 'o':
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
  80085d:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800862:	eb 46                	jmp    8008aa <vprintfmt+0x3ee>

		// pointer
		case 'p':
			putch('0', putdat);
  800864:	83 ec 08             	sub    $0x8,%esp
  800867:	53                   	push   %ebx
  800868:	6a 30                	push   $0x30
  80086a:	ff d7                	call   *%edi
			putch('x', putdat);
  80086c:	83 c4 08             	add    $0x8,%esp
  80086f:	53                   	push   %ebx
  800870:	6a 78                	push   $0x78
  800872:	ff d7                	call   *%edi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800874:	8b 45 14             	mov    0x14(%ebp),%eax
  800877:	8d 50 04             	lea    0x4(%eax),%edx
  80087a:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80087d:	8b 00                	mov    (%eax),%eax
  80087f:	ba 00 00 00 00       	mov    $0x0,%edx
  800884:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800887:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80088a:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80088d:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800892:	eb 16                	jmp    8008aa <vprintfmt+0x3ee>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800894:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800897:	8d 45 14             	lea    0x14(%ebp),%eax
  80089a:	e8 a9 fb ff ff       	call   800448 <getuint>
  80089f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8008a2:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  8008a5:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8008aa:	83 ec 0c             	sub    $0xc,%esp
  8008ad:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  8008b1:	56                   	push   %esi
  8008b2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8008b5:	50                   	push   %eax
  8008b6:	ff 75 dc             	pushl  -0x24(%ebp)
  8008b9:	ff 75 d8             	pushl  -0x28(%ebp)
  8008bc:	89 da                	mov    %ebx,%edx
  8008be:	89 f8                	mov    %edi,%eax
  8008c0:	e8 e3 f9 ff ff       	call   8002a8 <printnum>
			break;
  8008c5:	83 c4 20             	add    $0x20,%esp
  8008c8:	e9 03 fc ff ff       	jmp    8004d0 <vprintfmt+0x14>

            const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
            const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

            // Your code here
			num=(unsigned long long)(uintptr_t)va_arg(ap, void *);
  8008cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8008d0:	8d 50 04             	lea    0x4(%eax),%edx
  8008d3:	89 55 14             	mov    %edx,0x14(%ebp)
  8008d6:	8b 00                	mov    (%eax),%eax
			if(!num)
  8008d8:	85 c0                	test   %eax,%eax
  8008da:	75 1c                	jne    8008f8 <vprintfmt+0x43c>
				*(int *)putdat+=cprintf("%s",null_error);
  8008dc:	83 ec 08             	sub    $0x8,%esp
  8008df:	68 9c 11 80 00       	push   $0x80119c
  8008e4:	68 30 11 80 00       	push   $0x801130
  8008e9:	e8 a6 f9 ff ff       	call   800294 <cprintf>
  8008ee:	01 03                	add    %eax,(%ebx)
  8008f0:	83 c4 10             	add    $0x10,%esp
  8008f3:	e9 d8 fb ff ff       	jmp    8004d0 <vprintfmt+0x14>
			else
			{
				*(char *)(int)num=*(int *)putdat;
  8008f8:	8b 13                	mov    (%ebx),%edx
  8008fa:	88 10                	mov    %dl,(%eax)
				if((*(int *)putdat)>128)
  8008fc:	81 3b 80 00 00 00    	cmpl   $0x80,(%ebx)
  800902:	0f 8e c8 fb ff ff    	jle    8004d0 <vprintfmt+0x14>
					*(int *)putdat+=cprintf("%s",overflow_error);
  800908:	83 ec 08             	sub    $0x8,%esp
  80090b:	68 d4 11 80 00       	push   $0x8011d4
  800910:	68 30 11 80 00       	push   $0x801130
  800915:	e8 7a f9 ff ff       	call   800294 <cprintf>
  80091a:	01 03                	add    %eax,(%ebx)
  80091c:	83 c4 10             	add    $0x10,%esp
  80091f:	e9 ac fb ff ff       	jmp    8004d0 <vprintfmt+0x14>
            break;
        }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800924:	83 ec 08             	sub    $0x8,%esp
  800927:	53                   	push   %ebx
  800928:	52                   	push   %edx
  800929:	ff d7                	call   *%edi
			break;
  80092b:	83 c4 10             	add    $0x10,%esp
  80092e:	e9 9d fb ff ff       	jmp    8004d0 <vprintfmt+0x14>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800933:	83 ec 08             	sub    $0x8,%esp
  800936:	53                   	push   %ebx
  800937:	6a 25                	push   $0x25
  800939:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80093b:	83 c4 10             	add    $0x10,%esp
  80093e:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800942:	0f 84 85 fb ff ff    	je     8004cd <vprintfmt+0x11>
  800948:	83 ee 01             	sub    $0x1,%esi
  80094b:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80094f:	75 f7                	jne    800948 <vprintfmt+0x48c>
  800951:	89 75 10             	mov    %esi,0x10(%ebp)
  800954:	e9 77 fb ff ff       	jmp    8004d0 <vprintfmt+0x14>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800959:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80095c:	8d 70 01             	lea    0x1(%eax),%esi
  80095f:	0f b6 00             	movzbl (%eax),%eax
  800962:	0f be d0             	movsbl %al,%edx
  800965:	85 d2                	test   %edx,%edx
  800967:	0f 85 db fd ff ff    	jne    800748 <vprintfmt+0x28c>
  80096d:	e9 5e fb ff ff       	jmp    8004d0 <vprintfmt+0x14>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800972:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800975:	5b                   	pop    %ebx
  800976:	5e                   	pop    %esi
  800977:	5f                   	pop    %edi
  800978:	5d                   	pop    %ebp
  800979:	c3                   	ret    

0080097a <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80097a:	55                   	push   %ebp
  80097b:	89 e5                	mov    %esp,%ebp
  80097d:	83 ec 18             	sub    $0x18,%esp
  800980:	8b 45 08             	mov    0x8(%ebp),%eax
  800983:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800986:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800989:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80098d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800990:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800997:	85 c0                	test   %eax,%eax
  800999:	74 26                	je     8009c1 <vsnprintf+0x47>
  80099b:	85 d2                	test   %edx,%edx
  80099d:	7e 22                	jle    8009c1 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80099f:	ff 75 14             	pushl  0x14(%ebp)
  8009a2:	ff 75 10             	pushl  0x10(%ebp)
  8009a5:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8009a8:	50                   	push   %eax
  8009a9:	68 82 04 80 00       	push   $0x800482
  8009ae:	e8 09 fb ff ff       	call   8004bc <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8009b3:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8009b6:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8009b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009bc:	83 c4 10             	add    $0x10,%esp
  8009bf:	eb 05                	jmp    8009c6 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8009c1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8009c6:	c9                   	leave  
  8009c7:	c3                   	ret    

008009c8 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8009c8:	55                   	push   %ebp
  8009c9:	89 e5                	mov    %esp,%ebp
  8009cb:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8009ce:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8009d1:	50                   	push   %eax
  8009d2:	ff 75 10             	pushl  0x10(%ebp)
  8009d5:	ff 75 0c             	pushl  0xc(%ebp)
  8009d8:	ff 75 08             	pushl  0x8(%ebp)
  8009db:	e8 9a ff ff ff       	call   80097a <vsnprintf>
	va_end(ap);

	return rc;
}
  8009e0:	c9                   	leave  
  8009e1:	c3                   	ret    

008009e2 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8009e2:	55                   	push   %ebp
  8009e3:	89 e5                	mov    %esp,%ebp
  8009e5:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8009e8:	80 3a 00             	cmpb   $0x0,(%edx)
  8009eb:	74 10                	je     8009fd <strlen+0x1b>
  8009ed:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8009f2:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8009f5:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8009f9:	75 f7                	jne    8009f2 <strlen+0x10>
  8009fb:	eb 05                	jmp    800a02 <strlen+0x20>
  8009fd:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800a02:	5d                   	pop    %ebp
  800a03:	c3                   	ret    

00800a04 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a04:	55                   	push   %ebp
  800a05:	89 e5                	mov    %esp,%ebp
  800a07:	53                   	push   %ebx
  800a08:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800a0b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a0e:	85 c9                	test   %ecx,%ecx
  800a10:	74 1c                	je     800a2e <strnlen+0x2a>
  800a12:	80 3b 00             	cmpb   $0x0,(%ebx)
  800a15:	74 1e                	je     800a35 <strnlen+0x31>
  800a17:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  800a1c:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a1e:	39 ca                	cmp    %ecx,%edx
  800a20:	74 18                	je     800a3a <strnlen+0x36>
  800a22:	83 c2 01             	add    $0x1,%edx
  800a25:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800a2a:	75 f0                	jne    800a1c <strnlen+0x18>
  800a2c:	eb 0c                	jmp    800a3a <strnlen+0x36>
  800a2e:	b8 00 00 00 00       	mov    $0x0,%eax
  800a33:	eb 05                	jmp    800a3a <strnlen+0x36>
  800a35:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800a3a:	5b                   	pop    %ebx
  800a3b:	5d                   	pop    %ebp
  800a3c:	c3                   	ret    

00800a3d <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a3d:	55                   	push   %ebp
  800a3e:	89 e5                	mov    %esp,%ebp
  800a40:	53                   	push   %ebx
  800a41:	8b 45 08             	mov    0x8(%ebp),%eax
  800a44:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a47:	89 c2                	mov    %eax,%edx
  800a49:	83 c2 01             	add    $0x1,%edx
  800a4c:	83 c1 01             	add    $0x1,%ecx
  800a4f:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800a53:	88 5a ff             	mov    %bl,-0x1(%edx)
  800a56:	84 db                	test   %bl,%bl
  800a58:	75 ef                	jne    800a49 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800a5a:	5b                   	pop    %ebx
  800a5b:	5d                   	pop    %ebp
  800a5c:	c3                   	ret    

00800a5d <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a5d:	55                   	push   %ebp
  800a5e:	89 e5                	mov    %esp,%ebp
  800a60:	53                   	push   %ebx
  800a61:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a64:	53                   	push   %ebx
  800a65:	e8 78 ff ff ff       	call   8009e2 <strlen>
  800a6a:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800a6d:	ff 75 0c             	pushl  0xc(%ebp)
  800a70:	01 d8                	add    %ebx,%eax
  800a72:	50                   	push   %eax
  800a73:	e8 c5 ff ff ff       	call   800a3d <strcpy>
	return dst;
}
  800a78:	89 d8                	mov    %ebx,%eax
  800a7a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a7d:	c9                   	leave  
  800a7e:	c3                   	ret    

00800a7f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a7f:	55                   	push   %ebp
  800a80:	89 e5                	mov    %esp,%ebp
  800a82:	56                   	push   %esi
  800a83:	53                   	push   %ebx
  800a84:	8b 75 08             	mov    0x8(%ebp),%esi
  800a87:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a8a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a8d:	85 db                	test   %ebx,%ebx
  800a8f:	74 17                	je     800aa8 <strncpy+0x29>
  800a91:	01 f3                	add    %esi,%ebx
  800a93:	89 f1                	mov    %esi,%ecx
		*dst++ = *src;
  800a95:	83 c1 01             	add    $0x1,%ecx
  800a98:	0f b6 02             	movzbl (%edx),%eax
  800a9b:	88 41 ff             	mov    %al,-0x1(%ecx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a9e:	80 3a 01             	cmpb   $0x1,(%edx)
  800aa1:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800aa4:	39 cb                	cmp    %ecx,%ebx
  800aa6:	75 ed                	jne    800a95 <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800aa8:	89 f0                	mov    %esi,%eax
  800aaa:	5b                   	pop    %ebx
  800aab:	5e                   	pop    %esi
  800aac:	5d                   	pop    %ebp
  800aad:	c3                   	ret    

00800aae <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800aae:	55                   	push   %ebp
  800aaf:	89 e5                	mov    %esp,%ebp
  800ab1:	56                   	push   %esi
  800ab2:	53                   	push   %ebx
  800ab3:	8b 75 08             	mov    0x8(%ebp),%esi
  800ab6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ab9:	8b 55 10             	mov    0x10(%ebp),%edx
  800abc:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800abe:	85 d2                	test   %edx,%edx
  800ac0:	74 35                	je     800af7 <strlcpy+0x49>
		while (--size > 0 && *src != '\0')
  800ac2:	89 d0                	mov    %edx,%eax
  800ac4:	83 e8 01             	sub    $0x1,%eax
  800ac7:	74 25                	je     800aee <strlcpy+0x40>
  800ac9:	0f b6 0b             	movzbl (%ebx),%ecx
  800acc:	84 c9                	test   %cl,%cl
  800ace:	74 22                	je     800af2 <strlcpy+0x44>
  800ad0:	8d 53 01             	lea    0x1(%ebx),%edx
  800ad3:	01 c3                	add    %eax,%ebx
  800ad5:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
  800ad7:	83 c0 01             	add    $0x1,%eax
  800ada:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800add:	39 da                	cmp    %ebx,%edx
  800adf:	74 13                	je     800af4 <strlcpy+0x46>
  800ae1:	83 c2 01             	add    $0x1,%edx
  800ae4:	0f b6 4a ff          	movzbl -0x1(%edx),%ecx
  800ae8:	84 c9                	test   %cl,%cl
  800aea:	75 eb                	jne    800ad7 <strlcpy+0x29>
  800aec:	eb 06                	jmp    800af4 <strlcpy+0x46>
  800aee:	89 f0                	mov    %esi,%eax
  800af0:	eb 02                	jmp    800af4 <strlcpy+0x46>
  800af2:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800af4:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800af7:	29 f0                	sub    %esi,%eax
}
  800af9:	5b                   	pop    %ebx
  800afa:	5e                   	pop    %esi
  800afb:	5d                   	pop    %ebp
  800afc:	c3                   	ret    

00800afd <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800afd:	55                   	push   %ebp
  800afe:	89 e5                	mov    %esp,%ebp
  800b00:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b03:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800b06:	0f b6 01             	movzbl (%ecx),%eax
  800b09:	84 c0                	test   %al,%al
  800b0b:	74 15                	je     800b22 <strcmp+0x25>
  800b0d:	3a 02                	cmp    (%edx),%al
  800b0f:	75 11                	jne    800b22 <strcmp+0x25>
		p++, q++;
  800b11:	83 c1 01             	add    $0x1,%ecx
  800b14:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800b17:	0f b6 01             	movzbl (%ecx),%eax
  800b1a:	84 c0                	test   %al,%al
  800b1c:	74 04                	je     800b22 <strcmp+0x25>
  800b1e:	3a 02                	cmp    (%edx),%al
  800b20:	74 ef                	je     800b11 <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800b22:	0f b6 c0             	movzbl %al,%eax
  800b25:	0f b6 12             	movzbl (%edx),%edx
  800b28:	29 d0                	sub    %edx,%eax
}
  800b2a:	5d                   	pop    %ebp
  800b2b:	c3                   	ret    

00800b2c <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b2c:	55                   	push   %ebp
  800b2d:	89 e5                	mov    %esp,%ebp
  800b2f:	56                   	push   %esi
  800b30:	53                   	push   %ebx
  800b31:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800b34:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b37:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  800b3a:	85 f6                	test   %esi,%esi
  800b3c:	74 29                	je     800b67 <strncmp+0x3b>
  800b3e:	0f b6 03             	movzbl (%ebx),%eax
  800b41:	84 c0                	test   %al,%al
  800b43:	74 30                	je     800b75 <strncmp+0x49>
  800b45:	3a 02                	cmp    (%edx),%al
  800b47:	75 2c                	jne    800b75 <strncmp+0x49>
  800b49:	8d 43 01             	lea    0x1(%ebx),%eax
  800b4c:	01 de                	add    %ebx,%esi
		n--, p++, q++;
  800b4e:	89 c3                	mov    %eax,%ebx
  800b50:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800b53:	39 c6                	cmp    %eax,%esi
  800b55:	74 17                	je     800b6e <strncmp+0x42>
  800b57:	0f b6 08             	movzbl (%eax),%ecx
  800b5a:	84 c9                	test   %cl,%cl
  800b5c:	74 17                	je     800b75 <strncmp+0x49>
  800b5e:	83 c0 01             	add    $0x1,%eax
  800b61:	3a 0a                	cmp    (%edx),%cl
  800b63:	74 e9                	je     800b4e <strncmp+0x22>
  800b65:	eb 0e                	jmp    800b75 <strncmp+0x49>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800b67:	b8 00 00 00 00       	mov    $0x0,%eax
  800b6c:	eb 0f                	jmp    800b7d <strncmp+0x51>
  800b6e:	b8 00 00 00 00       	mov    $0x0,%eax
  800b73:	eb 08                	jmp    800b7d <strncmp+0x51>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b75:	0f b6 03             	movzbl (%ebx),%eax
  800b78:	0f b6 12             	movzbl (%edx),%edx
  800b7b:	29 d0                	sub    %edx,%eax
}
  800b7d:	5b                   	pop    %ebx
  800b7e:	5e                   	pop    %esi
  800b7f:	5d                   	pop    %ebp
  800b80:	c3                   	ret    

00800b81 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b81:	55                   	push   %ebp
  800b82:	89 e5                	mov    %esp,%ebp
  800b84:	53                   	push   %ebx
  800b85:	8b 45 08             	mov    0x8(%ebp),%eax
  800b88:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
  800b8b:	0f b6 10             	movzbl (%eax),%edx
  800b8e:	84 d2                	test   %dl,%dl
  800b90:	74 1d                	je     800baf <strchr+0x2e>
  800b92:	89 d9                	mov    %ebx,%ecx
		if (*s == c)
  800b94:	38 d3                	cmp    %dl,%bl
  800b96:	75 06                	jne    800b9e <strchr+0x1d>
  800b98:	eb 1a                	jmp    800bb4 <strchr+0x33>
  800b9a:	38 ca                	cmp    %cl,%dl
  800b9c:	74 16                	je     800bb4 <strchr+0x33>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b9e:	83 c0 01             	add    $0x1,%eax
  800ba1:	0f b6 10             	movzbl (%eax),%edx
  800ba4:	84 d2                	test   %dl,%dl
  800ba6:	75 f2                	jne    800b9a <strchr+0x19>
		if (*s == c)
			return (char *) s;
	return 0;
  800ba8:	b8 00 00 00 00       	mov    $0x0,%eax
  800bad:	eb 05                	jmp    800bb4 <strchr+0x33>
  800baf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bb4:	5b                   	pop    %ebx
  800bb5:	5d                   	pop    %ebp
  800bb6:	c3                   	ret    

00800bb7 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800bb7:	55                   	push   %ebp
  800bb8:	89 e5                	mov    %esp,%ebp
  800bba:	53                   	push   %ebx
  800bbb:	8b 45 08             	mov    0x8(%ebp),%eax
  800bbe:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  800bc1:	0f b6 18             	movzbl (%eax),%ebx
		if (*s == c)
  800bc4:	38 d3                	cmp    %dl,%bl
  800bc6:	74 14                	je     800bdc <strfind+0x25>
  800bc8:	89 d1                	mov    %edx,%ecx
  800bca:	84 db                	test   %bl,%bl
  800bcc:	74 0e                	je     800bdc <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800bce:	83 c0 01             	add    $0x1,%eax
  800bd1:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800bd4:	38 ca                	cmp    %cl,%dl
  800bd6:	74 04                	je     800bdc <strfind+0x25>
  800bd8:	84 d2                	test   %dl,%dl
  800bda:	75 f2                	jne    800bce <strfind+0x17>
			break;
	return (char *) s;
}
  800bdc:	5b                   	pop    %ebx
  800bdd:	5d                   	pop    %ebp
  800bde:	c3                   	ret    

00800bdf <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800bdf:	55                   	push   %ebp
  800be0:	89 e5                	mov    %esp,%ebp
  800be2:	57                   	push   %edi
  800be3:	56                   	push   %esi
  800be4:	53                   	push   %ebx
  800be5:	8b 7d 08             	mov    0x8(%ebp),%edi
  800be8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800beb:	85 c9                	test   %ecx,%ecx
  800bed:	74 36                	je     800c25 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800bef:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800bf5:	75 28                	jne    800c1f <memset+0x40>
  800bf7:	f6 c1 03             	test   $0x3,%cl
  800bfa:	75 23                	jne    800c1f <memset+0x40>
		c &= 0xFF;
  800bfc:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800c00:	89 d3                	mov    %edx,%ebx
  800c02:	c1 e3 08             	shl    $0x8,%ebx
  800c05:	89 d6                	mov    %edx,%esi
  800c07:	c1 e6 18             	shl    $0x18,%esi
  800c0a:	89 d0                	mov    %edx,%eax
  800c0c:	c1 e0 10             	shl    $0x10,%eax
  800c0f:	09 f0                	or     %esi,%eax
  800c11:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800c13:	89 d8                	mov    %ebx,%eax
  800c15:	09 d0                	or     %edx,%eax
  800c17:	c1 e9 02             	shr    $0x2,%ecx
  800c1a:	fc                   	cld    
  800c1b:	f3 ab                	rep stos %eax,%es:(%edi)
  800c1d:	eb 06                	jmp    800c25 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800c1f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c22:	fc                   	cld    
  800c23:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800c25:	89 f8                	mov    %edi,%eax
  800c27:	5b                   	pop    %ebx
  800c28:	5e                   	pop    %esi
  800c29:	5f                   	pop    %edi
  800c2a:	5d                   	pop    %ebp
  800c2b:	c3                   	ret    

00800c2c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800c2c:	55                   	push   %ebp
  800c2d:	89 e5                	mov    %esp,%ebp
  800c2f:	57                   	push   %edi
  800c30:	56                   	push   %esi
  800c31:	8b 45 08             	mov    0x8(%ebp),%eax
  800c34:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c37:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800c3a:	39 c6                	cmp    %eax,%esi
  800c3c:	73 35                	jae    800c73 <memmove+0x47>
  800c3e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c41:	39 d0                	cmp    %edx,%eax
  800c43:	73 2e                	jae    800c73 <memmove+0x47>
		s += n;
		d += n;
  800c45:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c48:	89 d6                	mov    %edx,%esi
  800c4a:	09 fe                	or     %edi,%esi
  800c4c:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c52:	75 13                	jne    800c67 <memmove+0x3b>
  800c54:	f6 c1 03             	test   $0x3,%cl
  800c57:	75 0e                	jne    800c67 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800c59:	83 ef 04             	sub    $0x4,%edi
  800c5c:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c5f:	c1 e9 02             	shr    $0x2,%ecx
  800c62:	fd                   	std    
  800c63:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c65:	eb 09                	jmp    800c70 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800c67:	83 ef 01             	sub    $0x1,%edi
  800c6a:	8d 72 ff             	lea    -0x1(%edx),%esi
  800c6d:	fd                   	std    
  800c6e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c70:	fc                   	cld    
  800c71:	eb 1d                	jmp    800c90 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c73:	89 f2                	mov    %esi,%edx
  800c75:	09 c2                	or     %eax,%edx
  800c77:	f6 c2 03             	test   $0x3,%dl
  800c7a:	75 0f                	jne    800c8b <memmove+0x5f>
  800c7c:	f6 c1 03             	test   $0x3,%cl
  800c7f:	75 0a                	jne    800c8b <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800c81:	c1 e9 02             	shr    $0x2,%ecx
  800c84:	89 c7                	mov    %eax,%edi
  800c86:	fc                   	cld    
  800c87:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c89:	eb 05                	jmp    800c90 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c8b:	89 c7                	mov    %eax,%edi
  800c8d:	fc                   	cld    
  800c8e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c90:	5e                   	pop    %esi
  800c91:	5f                   	pop    %edi
  800c92:	5d                   	pop    %ebp
  800c93:	c3                   	ret    

00800c94 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800c94:	55                   	push   %ebp
  800c95:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800c97:	ff 75 10             	pushl  0x10(%ebp)
  800c9a:	ff 75 0c             	pushl  0xc(%ebp)
  800c9d:	ff 75 08             	pushl  0x8(%ebp)
  800ca0:	e8 87 ff ff ff       	call   800c2c <memmove>
}
  800ca5:	c9                   	leave  
  800ca6:	c3                   	ret    

00800ca7 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ca7:	55                   	push   %ebp
  800ca8:	89 e5                	mov    %esp,%ebp
  800caa:	57                   	push   %edi
  800cab:	56                   	push   %esi
  800cac:	53                   	push   %ebx
  800cad:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800cb0:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cb3:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800cb6:	85 c0                	test   %eax,%eax
  800cb8:	74 39                	je     800cf3 <memcmp+0x4c>
  800cba:	8d 78 ff             	lea    -0x1(%eax),%edi
		if (*s1 != *s2)
  800cbd:	0f b6 13             	movzbl (%ebx),%edx
  800cc0:	0f b6 0e             	movzbl (%esi),%ecx
  800cc3:	38 ca                	cmp    %cl,%dl
  800cc5:	75 17                	jne    800cde <memcmp+0x37>
  800cc7:	b8 00 00 00 00       	mov    $0x0,%eax
  800ccc:	eb 1a                	jmp    800ce8 <memcmp+0x41>
  800cce:	0f b6 54 03 01       	movzbl 0x1(%ebx,%eax,1),%edx
  800cd3:	83 c0 01             	add    $0x1,%eax
  800cd6:	0f b6 0c 06          	movzbl (%esi,%eax,1),%ecx
  800cda:	38 ca                	cmp    %cl,%dl
  800cdc:	74 0a                	je     800ce8 <memcmp+0x41>
			return (int) *s1 - (int) *s2;
  800cde:	0f b6 c2             	movzbl %dl,%eax
  800ce1:	0f b6 c9             	movzbl %cl,%ecx
  800ce4:	29 c8                	sub    %ecx,%eax
  800ce6:	eb 10                	jmp    800cf8 <memcmp+0x51>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ce8:	39 f8                	cmp    %edi,%eax
  800cea:	75 e2                	jne    800cce <memcmp+0x27>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800cec:	b8 00 00 00 00       	mov    $0x0,%eax
  800cf1:	eb 05                	jmp    800cf8 <memcmp+0x51>
  800cf3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800cf8:	5b                   	pop    %ebx
  800cf9:	5e                   	pop    %esi
  800cfa:	5f                   	pop    %edi
  800cfb:	5d                   	pop    %ebp
  800cfc:	c3                   	ret    

00800cfd <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800cfd:	55                   	push   %ebp
  800cfe:	89 e5                	mov    %esp,%ebp
  800d00:	53                   	push   %ebx
  800d01:	8b 55 08             	mov    0x8(%ebp),%edx
	const void *ends = (const char *) s + n;
  800d04:	89 d0                	mov    %edx,%eax
  800d06:	03 45 10             	add    0x10(%ebp),%eax
	for (; s < ends; s++)
  800d09:	39 c2                	cmp    %eax,%edx
  800d0b:	73 1d                	jae    800d2a <memfind+0x2d>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d0d:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
  800d11:	0f b6 0a             	movzbl (%edx),%ecx
  800d14:	39 d9                	cmp    %ebx,%ecx
  800d16:	75 09                	jne    800d21 <memfind+0x24>
  800d18:	eb 14                	jmp    800d2e <memfind+0x31>
  800d1a:	0f b6 0a             	movzbl (%edx),%ecx
  800d1d:	39 d9                	cmp    %ebx,%ecx
  800d1f:	74 11                	je     800d32 <memfind+0x35>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800d21:	83 c2 01             	add    $0x1,%edx
  800d24:	39 d0                	cmp    %edx,%eax
  800d26:	75 f2                	jne    800d1a <memfind+0x1d>
  800d28:	eb 0a                	jmp    800d34 <memfind+0x37>
  800d2a:	89 d0                	mov    %edx,%eax
  800d2c:	eb 06                	jmp    800d34 <memfind+0x37>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d2e:	89 d0                	mov    %edx,%eax
  800d30:	eb 02                	jmp    800d34 <memfind+0x37>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800d32:	89 d0                	mov    %edx,%eax
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800d34:	5b                   	pop    %ebx
  800d35:	5d                   	pop    %ebp
  800d36:	c3                   	ret    

00800d37 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d37:	55                   	push   %ebp
  800d38:	89 e5                	mov    %esp,%ebp
  800d3a:	57                   	push   %edi
  800d3b:	56                   	push   %esi
  800d3c:	53                   	push   %ebx
  800d3d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d40:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d43:	0f b6 01             	movzbl (%ecx),%eax
  800d46:	3c 20                	cmp    $0x20,%al
  800d48:	74 04                	je     800d4e <strtol+0x17>
  800d4a:	3c 09                	cmp    $0x9,%al
  800d4c:	75 0e                	jne    800d5c <strtol+0x25>
		s++;
  800d4e:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d51:	0f b6 01             	movzbl (%ecx),%eax
  800d54:	3c 20                	cmp    $0x20,%al
  800d56:	74 f6                	je     800d4e <strtol+0x17>
  800d58:	3c 09                	cmp    $0x9,%al
  800d5a:	74 f2                	je     800d4e <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  800d5c:	3c 2b                	cmp    $0x2b,%al
  800d5e:	75 0a                	jne    800d6a <strtol+0x33>
		s++;
  800d60:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800d63:	bf 00 00 00 00       	mov    $0x0,%edi
  800d68:	eb 11                	jmp    800d7b <strtol+0x44>
  800d6a:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800d6f:	3c 2d                	cmp    $0x2d,%al
  800d71:	75 08                	jne    800d7b <strtol+0x44>
		s++, neg = 1;
  800d73:	83 c1 01             	add    $0x1,%ecx
  800d76:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d7b:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800d81:	75 15                	jne    800d98 <strtol+0x61>
  800d83:	80 39 30             	cmpb   $0x30,(%ecx)
  800d86:	75 10                	jne    800d98 <strtol+0x61>
  800d88:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800d8c:	75 7c                	jne    800e0a <strtol+0xd3>
		s += 2, base = 16;
  800d8e:	83 c1 02             	add    $0x2,%ecx
  800d91:	bb 10 00 00 00       	mov    $0x10,%ebx
  800d96:	eb 16                	jmp    800dae <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  800d98:	85 db                	test   %ebx,%ebx
  800d9a:	75 12                	jne    800dae <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800d9c:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800da1:	80 39 30             	cmpb   $0x30,(%ecx)
  800da4:	75 08                	jne    800dae <strtol+0x77>
		s++, base = 8;
  800da6:	83 c1 01             	add    $0x1,%ecx
  800da9:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800dae:	b8 00 00 00 00       	mov    $0x0,%eax
  800db3:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800db6:	0f b6 11             	movzbl (%ecx),%edx
  800db9:	8d 72 d0             	lea    -0x30(%edx),%esi
  800dbc:	89 f3                	mov    %esi,%ebx
  800dbe:	80 fb 09             	cmp    $0x9,%bl
  800dc1:	77 08                	ja     800dcb <strtol+0x94>
			dig = *s - '0';
  800dc3:	0f be d2             	movsbl %dl,%edx
  800dc6:	83 ea 30             	sub    $0x30,%edx
  800dc9:	eb 22                	jmp    800ded <strtol+0xb6>
		else if (*s >= 'a' && *s <= 'z')
  800dcb:	8d 72 9f             	lea    -0x61(%edx),%esi
  800dce:	89 f3                	mov    %esi,%ebx
  800dd0:	80 fb 19             	cmp    $0x19,%bl
  800dd3:	77 08                	ja     800ddd <strtol+0xa6>
			dig = *s - 'a' + 10;
  800dd5:	0f be d2             	movsbl %dl,%edx
  800dd8:	83 ea 57             	sub    $0x57,%edx
  800ddb:	eb 10                	jmp    800ded <strtol+0xb6>
		else if (*s >= 'A' && *s <= 'Z')
  800ddd:	8d 72 bf             	lea    -0x41(%edx),%esi
  800de0:	89 f3                	mov    %esi,%ebx
  800de2:	80 fb 19             	cmp    $0x19,%bl
  800de5:	77 16                	ja     800dfd <strtol+0xc6>
			dig = *s - 'A' + 10;
  800de7:	0f be d2             	movsbl %dl,%edx
  800dea:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800ded:	3b 55 10             	cmp    0x10(%ebp),%edx
  800df0:	7d 0b                	jge    800dfd <strtol+0xc6>
			break;
		s++, val = (val * base) + dig;
  800df2:	83 c1 01             	add    $0x1,%ecx
  800df5:	0f af 45 10          	imul   0x10(%ebp),%eax
  800df9:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800dfb:	eb b9                	jmp    800db6 <strtol+0x7f>

	if (endptr)
  800dfd:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800e01:	74 0d                	je     800e10 <strtol+0xd9>
		*endptr = (char *) s;
  800e03:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e06:	89 0e                	mov    %ecx,(%esi)
  800e08:	eb 06                	jmp    800e10 <strtol+0xd9>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800e0a:	85 db                	test   %ebx,%ebx
  800e0c:	74 98                	je     800da6 <strtol+0x6f>
  800e0e:	eb 9e                	jmp    800dae <strtol+0x77>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800e10:	89 c2                	mov    %eax,%edx
  800e12:	f7 da                	neg    %edx
  800e14:	85 ff                	test   %edi,%edi
  800e16:	0f 45 c2             	cmovne %edx,%eax
}
  800e19:	5b                   	pop    %ebx
  800e1a:	5e                   	pop    %esi
  800e1b:	5f                   	pop    %edi
  800e1c:	5d                   	pop    %ebp
  800e1d:	c3                   	ret    
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
