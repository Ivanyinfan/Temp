
obj/user/buggyhello:     file format elf32-i386


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
  80002c:	e8 16 00 00 00       	call   800047 <libmain>
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
	sys_cputs((char*)1, 1);
  800039:	6a 01                	push   $0x1
  80003b:	6a 01                	push   $0x1
  80003d:	e8 4d 00 00 00       	call   80008f <sys_cputs>
}
  800042:	83 c4 10             	add    $0x10,%esp
  800045:	c9                   	leave  
  800046:	c3                   	ret    

00800047 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800047:	55                   	push   %ebp
  800048:	89 e5                	mov    %esp,%ebp
  80004a:	83 ec 08             	sub    $0x8,%esp
  80004d:	8b 45 08             	mov    0x8(%ebp),%eax
  800050:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800053:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  80005a:	00 00 00 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80005d:	85 c0                	test   %eax,%eax
  80005f:	7e 08                	jle    800069 <libmain+0x22>
		binaryname = argv[0];
  800061:	8b 0a                	mov    (%edx),%ecx
  800063:	89 0d 00 20 80 00    	mov    %ecx,0x802000

	// call user main routine
	umain(argc, argv);
  800069:	83 ec 08             	sub    $0x8,%esp
  80006c:	52                   	push   %edx
  80006d:	50                   	push   %eax
  80006e:	e8 c0 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800073:	e8 05 00 00 00       	call   80007d <exit>
}
  800078:	83 c4 10             	add    $0x10,%esp
  80007b:	c9                   	leave  
  80007c:	c3                   	ret    

0080007d <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80007d:	55                   	push   %ebp
  80007e:	89 e5                	mov    %esp,%ebp
  800080:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800083:	6a 00                	push   $0x0
  800085:	e8 52 00 00 00       	call   8000dc <sys_env_destroy>
}
  80008a:	83 c4 10             	add    $0x10,%esp
  80008d:	c9                   	leave  
  80008e:	c3                   	ret    

0080008f <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  80008f:	55                   	push   %ebp
  800090:	89 e5                	mov    %esp,%ebp
  800092:	57                   	push   %edi
  800093:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800094:	b8 00 00 00 00       	mov    $0x0,%eax
  800099:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80009c:	8b 55 08             	mov    0x8(%ebp),%edx
  80009f:	89 c3                	mov    %eax,%ebx
  8000a1:	89 c7                	mov    %eax,%edi
  8000a3:	51                   	push   %ecx
  8000a4:	52                   	push   %edx
  8000a5:	53                   	push   %ebx
  8000a6:	54                   	push   %esp
  8000a7:	55                   	push   %ebp
  8000a8:	56                   	push   %esi
  8000a9:	57                   	push   %edi
  8000aa:	5f                   	pop    %edi
  8000ab:	5e                   	pop    %esi
  8000ac:	5d                   	pop    %ebp
  8000ad:	5c                   	pop    %esp
  8000ae:	5b                   	pop    %ebx
  8000af:	5a                   	pop    %edx
  8000b0:	59                   	pop    %ecx

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000b1:	5b                   	pop    %ebx
  8000b2:	5f                   	pop    %edi
  8000b3:	5d                   	pop    %ebp
  8000b4:	c3                   	ret    

008000b5 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000b5:	55                   	push   %ebp
  8000b6:	89 e5                	mov    %esp,%ebp
  8000b8:	57                   	push   %edi
  8000b9:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8000ba:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000bf:	b8 01 00 00 00       	mov    $0x1,%eax
  8000c4:	89 ca                	mov    %ecx,%edx
  8000c6:	89 cb                	mov    %ecx,%ebx
  8000c8:	89 cf                	mov    %ecx,%edi
  8000ca:	51                   	push   %ecx
  8000cb:	52                   	push   %edx
  8000cc:	53                   	push   %ebx
  8000cd:	54                   	push   %esp
  8000ce:	55                   	push   %ebp
  8000cf:	56                   	push   %esi
  8000d0:	57                   	push   %edi
  8000d1:	5f                   	pop    %edi
  8000d2:	5e                   	pop    %esi
  8000d3:	5d                   	pop    %ebp
  8000d4:	5c                   	pop    %esp
  8000d5:	5b                   	pop    %ebx
  8000d6:	5a                   	pop    %edx
  8000d7:	59                   	pop    %ecx

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000d8:	5b                   	pop    %ebx
  8000d9:	5f                   	pop    %edi
  8000da:	5d                   	pop    %ebp
  8000db:	c3                   	ret    

008000dc <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000dc:	55                   	push   %ebp
  8000dd:	89 e5                	mov    %esp,%ebp
  8000df:	57                   	push   %edi
  8000e0:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8000e1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8000e6:	b8 03 00 00 00       	mov    $0x3,%eax
  8000eb:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ee:	89 d9                	mov    %ebx,%ecx
  8000f0:	89 df                	mov    %ebx,%edi
  8000f2:	51                   	push   %ecx
  8000f3:	52                   	push   %edx
  8000f4:	53                   	push   %ebx
  8000f5:	54                   	push   %esp
  8000f6:	55                   	push   %ebp
  8000f7:	56                   	push   %esi
  8000f8:	57                   	push   %edi
  8000f9:	5f                   	pop    %edi
  8000fa:	5e                   	pop    %esi
  8000fb:	5d                   	pop    %ebp
  8000fc:	5c                   	pop    %esp
  8000fd:	5b                   	pop    %ebx
  8000fe:	5a                   	pop    %edx
  8000ff:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  800100:	85 c0                	test   %eax,%eax
  800102:	7e 17                	jle    80011b <sys_env_destroy+0x3f>
		panic("syscall %d returned %d (> 0)", num, ret);
  800104:	83 ec 0c             	sub    $0xc,%esp
  800107:	50                   	push   %eax
  800108:	6a 03                	push   $0x3
  80010a:	68 ae 10 80 00       	push   $0x8010ae
  80010f:	6a 26                	push   $0x26
  800111:	68 cb 10 80 00       	push   $0x8010cb
  800116:	e8 7f 00 00 00       	call   80019a <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80011b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80011e:	5b                   	pop    %ebx
  80011f:	5f                   	pop    %edi
  800120:	5d                   	pop    %ebp
  800121:	c3                   	ret    

00800122 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800122:	55                   	push   %ebp
  800123:	89 e5                	mov    %esp,%ebp
  800125:	57                   	push   %edi
  800126:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800127:	b9 00 00 00 00       	mov    $0x0,%ecx
  80012c:	b8 02 00 00 00       	mov    $0x2,%eax
  800131:	89 ca                	mov    %ecx,%edx
  800133:	89 cb                	mov    %ecx,%ebx
  800135:	89 cf                	mov    %ecx,%edi
  800137:	51                   	push   %ecx
  800138:	52                   	push   %edx
  800139:	53                   	push   %ebx
  80013a:	54                   	push   %esp
  80013b:	55                   	push   %ebp
  80013c:	56                   	push   %esi
  80013d:	57                   	push   %edi
  80013e:	5f                   	pop    %edi
  80013f:	5e                   	pop    %esi
  800140:	5d                   	pop    %ebp
  800141:	5c                   	pop    %esp
  800142:	5b                   	pop    %ebx
  800143:	5a                   	pop    %edx
  800144:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800145:	5b                   	pop    %ebx
  800146:	5f                   	pop    %edi
  800147:	5d                   	pop    %ebp
  800148:	c3                   	ret    

00800149 <sys_map_kernel_page>:

int
sys_map_kernel_page(void* kpage, void* va)
{
  800149:	55                   	push   %ebp
  80014a:	89 e5                	mov    %esp,%ebp
  80014c:	57                   	push   %edi
  80014d:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80014e:	bf 00 00 00 00       	mov    $0x0,%edi
  800153:	b8 04 00 00 00       	mov    $0x4,%eax
  800158:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80015b:	8b 55 08             	mov    0x8(%ebp),%edx
  80015e:	89 fb                	mov    %edi,%ebx
  800160:	51                   	push   %ecx
  800161:	52                   	push   %edx
  800162:	53                   	push   %ebx
  800163:	54                   	push   %esp
  800164:	55                   	push   %ebp
  800165:	56                   	push   %esi
  800166:	57                   	push   %edi
  800167:	5f                   	pop    %edi
  800168:	5e                   	pop    %esi
  800169:	5d                   	pop    %ebp
  80016a:	5c                   	pop    %esp
  80016b:	5b                   	pop    %ebx
  80016c:	5a                   	pop    %edx
  80016d:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  80016e:	5b                   	pop    %ebx
  80016f:	5f                   	pop    %edi
  800170:	5d                   	pop    %ebp
  800171:	c3                   	ret    

00800172 <sys_sbrk>:

int
sys_sbrk(uint32_t inc)
{
  800172:	55                   	push   %ebp
  800173:	89 e5                	mov    %esp,%ebp
  800175:	57                   	push   %edi
  800176:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800177:	b9 00 00 00 00       	mov    $0x0,%ecx
  80017c:	b8 05 00 00 00       	mov    $0x5,%eax
  800181:	8b 55 08             	mov    0x8(%ebp),%edx
  800184:	89 cb                	mov    %ecx,%ebx
  800186:	89 cf                	mov    %ecx,%edi
  800188:	51                   	push   %ecx
  800189:	52                   	push   %edx
  80018a:	53                   	push   %ebx
  80018b:	54                   	push   %esp
  80018c:	55                   	push   %ebp
  80018d:	56                   	push   %esi
  80018e:	57                   	push   %edi
  80018f:	5f                   	pop    %edi
  800190:	5e                   	pop    %esi
  800191:	5d                   	pop    %ebp
  800192:	5c                   	pop    %esp
  800193:	5b                   	pop    %ebx
  800194:	5a                   	pop    %edx
  800195:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  800196:	5b                   	pop    %ebx
  800197:	5f                   	pop    %edi
  800198:	5d                   	pop    %ebp
  800199:	c3                   	ret    

0080019a <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80019a:	55                   	push   %ebp
  80019b:	89 e5                	mov    %esp,%ebp
  80019d:	56                   	push   %esi
  80019e:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80019f:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	if (argv0)
  8001a2:	a1 08 20 80 00       	mov    0x802008,%eax
  8001a7:	85 c0                	test   %eax,%eax
  8001a9:	74 11                	je     8001bc <_panic+0x22>
		cprintf("%s: ", argv0);
  8001ab:	83 ec 08             	sub    $0x8,%esp
  8001ae:	50                   	push   %eax
  8001af:	68 d9 10 80 00       	push   $0x8010d9
  8001b4:	e8 d4 00 00 00       	call   80028d <cprintf>
  8001b9:	83 c4 10             	add    $0x10,%esp
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001bc:	8b 35 00 20 80 00    	mov    0x802000,%esi
  8001c2:	e8 5b ff ff ff       	call   800122 <sys_getenvid>
  8001c7:	83 ec 0c             	sub    $0xc,%esp
  8001ca:	ff 75 0c             	pushl  0xc(%ebp)
  8001cd:	ff 75 08             	pushl  0x8(%ebp)
  8001d0:	56                   	push   %esi
  8001d1:	50                   	push   %eax
  8001d2:	68 e0 10 80 00       	push   $0x8010e0
  8001d7:	e8 b1 00 00 00       	call   80028d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001dc:	83 c4 18             	add    $0x18,%esp
  8001df:	53                   	push   %ebx
  8001e0:	ff 75 10             	pushl  0x10(%ebp)
  8001e3:	e8 54 00 00 00       	call   80023c <vcprintf>
	cprintf("\n");
  8001e8:	c7 04 24 de 10 80 00 	movl   $0x8010de,(%esp)
  8001ef:	e8 99 00 00 00       	call   80028d <cprintf>
  8001f4:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001f7:	cc                   	int3   
  8001f8:	eb fd                	jmp    8001f7 <_panic+0x5d>

008001fa <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001fa:	55                   	push   %ebp
  8001fb:	89 e5                	mov    %esp,%ebp
  8001fd:	53                   	push   %ebx
  8001fe:	83 ec 04             	sub    $0x4,%esp
  800201:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800204:	8b 13                	mov    (%ebx),%edx
  800206:	8d 42 01             	lea    0x1(%edx),%eax
  800209:	89 03                	mov    %eax,(%ebx)
  80020b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80020e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800212:	3d ff 00 00 00       	cmp    $0xff,%eax
  800217:	75 1a                	jne    800233 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800219:	83 ec 08             	sub    $0x8,%esp
  80021c:	68 ff 00 00 00       	push   $0xff
  800221:	8d 43 08             	lea    0x8(%ebx),%eax
  800224:	50                   	push   %eax
  800225:	e8 65 fe ff ff       	call   80008f <sys_cputs>
		b->idx = 0;
  80022a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800230:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800233:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800237:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80023a:	c9                   	leave  
  80023b:	c3                   	ret    

0080023c <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80023c:	55                   	push   %ebp
  80023d:	89 e5                	mov    %esp,%ebp
  80023f:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800245:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80024c:	00 00 00 
	b.cnt = 0;
  80024f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800256:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800259:	ff 75 0c             	pushl  0xc(%ebp)
  80025c:	ff 75 08             	pushl  0x8(%ebp)
  80025f:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800265:	50                   	push   %eax
  800266:	68 fa 01 80 00       	push   $0x8001fa
  80026b:	e8 45 02 00 00       	call   8004b5 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800270:	83 c4 08             	add    $0x8,%esp
  800273:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800279:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80027f:	50                   	push   %eax
  800280:	e8 0a fe ff ff       	call   80008f <sys_cputs>

	return b.cnt;
}
  800285:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80028b:	c9                   	leave  
  80028c:	c3                   	ret    

0080028d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80028d:	55                   	push   %ebp
  80028e:	89 e5                	mov    %esp,%ebp
  800290:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800293:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800296:	50                   	push   %eax
  800297:	ff 75 08             	pushl  0x8(%ebp)
  80029a:	e8 9d ff ff ff       	call   80023c <vcprintf>
	va_end(ap);

	return cnt;
}
  80029f:	c9                   	leave  
  8002a0:	c3                   	ret    

008002a1 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002a1:	55                   	push   %ebp
  8002a2:	89 e5                	mov    %esp,%ebp
  8002a4:	57                   	push   %edi
  8002a5:	56                   	push   %esi
  8002a6:	53                   	push   %ebx
  8002a7:	83 ec 1c             	sub    $0x1c,%esp
  8002aa:	89 c7                	mov    %eax,%edi
  8002ac:	89 d6                	mov    %edx,%esi
  8002ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002b4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002b7:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	// if cprintf'parameter includes pattern of the form "%-", padding
	// space on the right side if neccesary.
	// you can add helper function if needed.
	// your code here:
	int length,showsign=0;
	if(padc=='-'&&num>=base)
  8002ba:	83 7d 18 2d          	cmpl   $0x2d,0x18(%ebp)
  8002be:	0f 85 8a 00 00 00    	jne    80034e <printnum+0xad>
  8002c4:	8b 45 10             	mov    0x10(%ebp),%eax
  8002c7:	ba 00 00 00 00       	mov    $0x0,%edx
  8002cc:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8002cf:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8002d2:	39 da                	cmp    %ebx,%edx
  8002d4:	72 09                	jb     8002df <printnum+0x3e>
  8002d6:	39 4d 10             	cmp    %ecx,0x10(%ebp)
  8002d9:	0f 87 87 00 00 00    	ja     800366 <printnum+0xc5>
	{
		length=*(int *)putdat;
  8002df:	8b 1e                	mov    (%esi),%ebx
		printnum(putch,putdat,num/base,base,0,padc);
  8002e1:	83 ec 0c             	sub    $0xc,%esp
  8002e4:	6a 2d                	push   $0x2d
  8002e6:	6a 00                	push   $0x0
  8002e8:	ff 75 10             	pushl  0x10(%ebp)
  8002eb:	83 ec 08             	sub    $0x8,%esp
  8002ee:	52                   	push   %edx
  8002ef:	50                   	push   %eax
  8002f0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002f3:	ff 75 e0             	pushl  -0x20(%ebp)
  8002f6:	e8 25 0b 00 00       	call   800e20 <__udivdi3>
  8002fb:	83 c4 18             	add    $0x18,%esp
  8002fe:	52                   	push   %edx
  8002ff:	50                   	push   %eax
  800300:	89 f2                	mov    %esi,%edx
  800302:	89 f8                	mov    %edi,%eax
  800304:	e8 98 ff ff ff       	call   8002a1 <printnum>
		while (--width > 0)
			putch(padc, putdat);
	}
	}
	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800309:	83 c4 18             	add    $0x18,%esp
  80030c:	56                   	push   %esi
  80030d:	8b 45 10             	mov    0x10(%ebp),%eax
  800310:	ba 00 00 00 00       	mov    $0x0,%edx
  800315:	83 ec 04             	sub    $0x4,%esp
  800318:	52                   	push   %edx
  800319:	50                   	push   %eax
  80031a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80031d:	ff 75 e0             	pushl  -0x20(%ebp)
  800320:	e8 2b 0c 00 00       	call   800f50 <__umoddi3>
  800325:	83 c4 14             	add    $0x14,%esp
  800328:	0f be 80 03 11 80 00 	movsbl 0x801103(%eax),%eax
  80032f:	50                   	push   %eax
  800330:	ff d7                	call   *%edi
	
	if(padc=='-'&&width>0)
  800332:	83 c4 10             	add    $0x10,%esp
  800335:	83 7d 18 2d          	cmpl   $0x2d,0x18(%ebp)
  800339:	0f 85 fa 00 00 00    	jne    800439 <printnum+0x198>
  80033f:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
  800343:	0f 8f 9b 00 00 00    	jg     8003e4 <printnum+0x143>
  800349:	e9 eb 00 00 00       	jmp    800439 <printnum+0x198>
	}
	else
	{
	
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80034e:	8b 45 10             	mov    0x10(%ebp),%eax
  800351:	ba 00 00 00 00       	mov    $0x0,%edx
  800356:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800359:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80035c:	83 fb 00             	cmp    $0x0,%ebx
  80035f:	77 14                	ja     800375 <printnum+0xd4>
  800361:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800364:	73 0f                	jae    800375 <printnum+0xd4>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800366:	8b 45 14             	mov    0x14(%ebp),%eax
  800369:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80036c:	85 db                	test   %ebx,%ebx
  80036e:	7f 61                	jg     8003d1 <printnum+0x130>
  800370:	e9 98 00 00 00       	jmp    80040d <printnum+0x16c>
	else
	{
	
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800375:	83 ec 0c             	sub    $0xc,%esp
  800378:	ff 75 18             	pushl  0x18(%ebp)
  80037b:	8b 4d 14             	mov    0x14(%ebp),%ecx
  80037e:	8d 59 ff             	lea    -0x1(%ecx),%ebx
  800381:	53                   	push   %ebx
  800382:	ff 75 10             	pushl  0x10(%ebp)
  800385:	83 ec 08             	sub    $0x8,%esp
  800388:	52                   	push   %edx
  800389:	50                   	push   %eax
  80038a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80038d:	ff 75 e0             	pushl  -0x20(%ebp)
  800390:	e8 8b 0a 00 00       	call   800e20 <__udivdi3>
  800395:	83 c4 18             	add    $0x18,%esp
  800398:	52                   	push   %edx
  800399:	50                   	push   %eax
  80039a:	89 f2                	mov    %esi,%edx
  80039c:	89 f8                	mov    %edi,%eax
  80039e:	e8 fe fe ff ff       	call   8002a1 <printnum>
		while (--width > 0)
			putch(padc, putdat);
	}
	}
	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003a3:	83 c4 18             	add    $0x18,%esp
  8003a6:	56                   	push   %esi
  8003a7:	8b 45 10             	mov    0x10(%ebp),%eax
  8003aa:	ba 00 00 00 00       	mov    $0x0,%edx
  8003af:	83 ec 04             	sub    $0x4,%esp
  8003b2:	52                   	push   %edx
  8003b3:	50                   	push   %eax
  8003b4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003b7:	ff 75 e0             	pushl  -0x20(%ebp)
  8003ba:	e8 91 0b 00 00       	call   800f50 <__umoddi3>
  8003bf:	83 c4 14             	add    $0x14,%esp
  8003c2:	0f be 80 03 11 80 00 	movsbl 0x801103(%eax),%eax
  8003c9:	50                   	push   %eax
  8003ca:	ff d7                	call   *%edi
  8003cc:	83 c4 10             	add    $0x10,%esp
  8003cf:	eb 68                	jmp    800439 <printnum+0x198>
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8003d1:	83 ec 08             	sub    $0x8,%esp
  8003d4:	56                   	push   %esi
  8003d5:	ff 75 18             	pushl  0x18(%ebp)
  8003d8:	ff d7                	call   *%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003da:	83 c4 10             	add    $0x10,%esp
  8003dd:	83 eb 01             	sub    $0x1,%ebx
  8003e0:	75 ef                	jne    8003d1 <printnum+0x130>
  8003e2:	eb 29                	jmp    80040d <printnum+0x16c>
	putch("0123456789abcdef"[num % base], putdat);
	
	if(padc=='-'&&width>0)
	{
		length=*(int *)putdat-length;
		for(int i=0;i<width-length;++i)
  8003e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e7:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  8003ea:	2b 06                	sub    (%esi),%eax
  8003ec:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003ef:	85 c0                	test   %eax,%eax
  8003f1:	7e 46                	jle    800439 <printnum+0x198>
  8003f3:	bb 00 00 00 00       	mov    $0x0,%ebx
			putch(' ',putdat);
  8003f8:	83 ec 08             	sub    $0x8,%esp
  8003fb:	56                   	push   %esi
  8003fc:	6a 20                	push   $0x20
  8003fe:	ff d7                	call   *%edi
	putch("0123456789abcdef"[num % base], putdat);
	
	if(padc=='-'&&width>0)
	{
		length=*(int *)putdat-length;
		for(int i=0;i<width-length;++i)
  800400:	83 c3 01             	add    $0x1,%ebx
  800403:	83 c4 10             	add    $0x10,%esp
  800406:	3b 5d e0             	cmp    -0x20(%ebp),%ebx
  800409:	75 ed                	jne    8003f8 <printnum+0x157>
  80040b:	eb 2c                	jmp    800439 <printnum+0x198>
		while (--width > 0)
			putch(padc, putdat);
	}
	}
	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80040d:	83 ec 08             	sub    $0x8,%esp
  800410:	56                   	push   %esi
  800411:	8b 45 10             	mov    0x10(%ebp),%eax
  800414:	ba 00 00 00 00       	mov    $0x0,%edx
  800419:	83 ec 04             	sub    $0x4,%esp
  80041c:	52                   	push   %edx
  80041d:	50                   	push   %eax
  80041e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800421:	ff 75 e0             	pushl  -0x20(%ebp)
  800424:	e8 27 0b 00 00       	call   800f50 <__umoddi3>
  800429:	83 c4 14             	add    $0x14,%esp
  80042c:	0f be 80 03 11 80 00 	movsbl 0x801103(%eax),%eax
  800433:	50                   	push   %eax
  800434:	ff d7                	call   *%edi
  800436:	83 c4 10             	add    $0x10,%esp
	{
		length=*(int *)putdat-length;
		for(int i=0;i<width-length;++i)
			putch(' ',putdat);
	}
}
  800439:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80043c:	5b                   	pop    %ebx
  80043d:	5e                   	pop    %esi
  80043e:	5f                   	pop    %edi
  80043f:	5d                   	pop    %ebp
  800440:	c3                   	ret    

00800441 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800441:	55                   	push   %ebp
  800442:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800444:	83 fa 01             	cmp    $0x1,%edx
  800447:	7e 0e                	jle    800457 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800449:	8b 10                	mov    (%eax),%edx
  80044b:	8d 4a 08             	lea    0x8(%edx),%ecx
  80044e:	89 08                	mov    %ecx,(%eax)
  800450:	8b 02                	mov    (%edx),%eax
  800452:	8b 52 04             	mov    0x4(%edx),%edx
  800455:	eb 22                	jmp    800479 <getuint+0x38>
	else if (lflag)
  800457:	85 d2                	test   %edx,%edx
  800459:	74 10                	je     80046b <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80045b:	8b 10                	mov    (%eax),%edx
  80045d:	8d 4a 04             	lea    0x4(%edx),%ecx
  800460:	89 08                	mov    %ecx,(%eax)
  800462:	8b 02                	mov    (%edx),%eax
  800464:	ba 00 00 00 00       	mov    $0x0,%edx
  800469:	eb 0e                	jmp    800479 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80046b:	8b 10                	mov    (%eax),%edx
  80046d:	8d 4a 04             	lea    0x4(%edx),%ecx
  800470:	89 08                	mov    %ecx,(%eax)
  800472:	8b 02                	mov    (%edx),%eax
  800474:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800479:	5d                   	pop    %ebp
  80047a:	c3                   	ret    

0080047b <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80047b:	55                   	push   %ebp
  80047c:	89 e5                	mov    %esp,%ebp
  80047e:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800481:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800485:	8b 10                	mov    (%eax),%edx
  800487:	3b 50 04             	cmp    0x4(%eax),%edx
  80048a:	73 0a                	jae    800496 <sprintputch+0x1b>
		*b->buf++ = ch;
  80048c:	8d 4a 01             	lea    0x1(%edx),%ecx
  80048f:	89 08                	mov    %ecx,(%eax)
  800491:	8b 45 08             	mov    0x8(%ebp),%eax
  800494:	88 02                	mov    %al,(%edx)
}
  800496:	5d                   	pop    %ebp
  800497:	c3                   	ret    

00800498 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800498:	55                   	push   %ebp
  800499:	89 e5                	mov    %esp,%ebp
  80049b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80049e:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004a1:	50                   	push   %eax
  8004a2:	ff 75 10             	pushl  0x10(%ebp)
  8004a5:	ff 75 0c             	pushl  0xc(%ebp)
  8004a8:	ff 75 08             	pushl  0x8(%ebp)
  8004ab:	e8 05 00 00 00       	call   8004b5 <vprintfmt>
	va_end(ap);
}
  8004b0:	83 c4 10             	add    $0x10,%esp
  8004b3:	c9                   	leave  
  8004b4:	c3                   	ret    

008004b5 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8004b5:	55                   	push   %ebp
  8004b6:	89 e5                	mov    %esp,%ebp
  8004b8:	57                   	push   %edi
  8004b9:	56                   	push   %esi
  8004ba:	53                   	push   %ebx
  8004bb:	83 ec 2c             	sub    $0x2c,%esp
  8004be:	8b 7d 08             	mov    0x8(%ebp),%edi
  8004c1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004c4:	eb 03                	jmp    8004c9 <vprintfmt+0x14>
			break;
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
			for (fmt--; fmt[-1] != '%'; fmt--)
  8004c6:	89 75 10             	mov    %esi,0x10(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8004c9:	8b 45 10             	mov    0x10(%ebp),%eax
  8004cc:	8d 70 01             	lea    0x1(%eax),%esi
  8004cf:	0f b6 00             	movzbl (%eax),%eax
  8004d2:	83 f8 25             	cmp    $0x25,%eax
  8004d5:	74 27                	je     8004fe <vprintfmt+0x49>
			if (ch == '\0')
  8004d7:	85 c0                	test   %eax,%eax
  8004d9:	75 0d                	jne    8004e8 <vprintfmt+0x33>
  8004db:	e9 8b 04 00 00       	jmp    80096b <vprintfmt+0x4b6>
  8004e0:	85 c0                	test   %eax,%eax
  8004e2:	0f 84 83 04 00 00    	je     80096b <vprintfmt+0x4b6>
				return;
			putch(ch, putdat);
  8004e8:	83 ec 08             	sub    $0x8,%esp
  8004eb:	53                   	push   %ebx
  8004ec:	50                   	push   %eax
  8004ed:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8004ef:	83 c6 01             	add    $0x1,%esi
  8004f2:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  8004f6:	83 c4 10             	add    $0x10,%esp
  8004f9:	83 f8 25             	cmp    $0x25,%eax
  8004fc:	75 e2                	jne    8004e0 <vprintfmt+0x2b>
			padc = '-';
			goto reswitch;
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004fe:	c6 45 e3 20          	movb   $0x20,-0x1d(%ebp)
  800502:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800509:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800510:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800517:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  80051e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800523:	eb 07                	jmp    80052c <vprintfmt+0x77>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800525:	8b 75 10             	mov    0x10(%ebp),%esi

		// flag to show the sign
		case '+':
			padc='+';
  800528:	c6 45 e3 2b          	movb   $0x2b,-0x1d(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80052c:	8d 46 01             	lea    0x1(%esi),%eax
  80052f:	89 45 10             	mov    %eax,0x10(%ebp)
  800532:	0f b6 06             	movzbl (%esi),%eax
  800535:	0f b6 d0             	movzbl %al,%edx
  800538:	83 e8 23             	sub    $0x23,%eax
  80053b:	3c 55                	cmp    $0x55,%al
  80053d:	0f 87 e9 03 00 00    	ja     80092c <vprintfmt+0x477>
  800543:	0f b6 c0             	movzbl %al,%eax
  800546:	ff 24 85 0c 12 80 00 	jmp    *0x80120c(,%eax,4)
  80054d:	8b 75 10             	mov    0x10(%ebp),%esi
			padc='+';
			goto reswitch;
		
		// flag to pad on the right
		case '-':
			padc = '-';
  800550:	c6 45 e3 2d          	movb   $0x2d,-0x1d(%ebp)
  800554:	eb d6                	jmp    80052c <vprintfmt+0x77>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800556:	8d 42 d0             	lea    -0x30(%edx),%eax
  800559:	89 45 d0             	mov    %eax,-0x30(%ebp)
				ch = *fmt;
  80055c:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  800560:	8d 50 d0             	lea    -0x30(%eax),%edx
  800563:	83 fa 09             	cmp    $0x9,%edx
  800566:	77 66                	ja     8005ce <vprintfmt+0x119>
  800568:	8b 75 10             	mov    0x10(%ebp),%esi
  80056b:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80056e:	89 7d 08             	mov    %edi,0x8(%ebp)
  800571:	eb 09                	jmp    80057c <vprintfmt+0xc7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800573:	8b 75 10             	mov    0x10(%ebp),%esi
			padc = '-';
			goto reswitch;
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800576:	c6 45 e3 30          	movb   $0x30,-0x1d(%ebp)
			goto reswitch;
  80057a:	eb b0                	jmp    80052c <vprintfmt+0x77>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80057c:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  80057f:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800582:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  800586:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800589:	8d 78 d0             	lea    -0x30(%eax),%edi
  80058c:	83 ff 09             	cmp    $0x9,%edi
  80058f:	76 eb                	jbe    80057c <vprintfmt+0xc7>
  800591:	89 55 d0             	mov    %edx,-0x30(%ebp)
  800594:	8b 7d 08             	mov    0x8(%ebp),%edi
  800597:	eb 38                	jmp    8005d1 <vprintfmt+0x11c>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800599:	8b 45 14             	mov    0x14(%ebp),%eax
  80059c:	8d 50 04             	lea    0x4(%eax),%edx
  80059f:	89 55 14             	mov    %edx,0x14(%ebp)
  8005a2:	8b 00                	mov    (%eax),%eax
  8005a4:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a7:	8b 75 10             	mov    0x10(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005aa:	eb 25                	jmp    8005d1 <vprintfmt+0x11c>
  8005ac:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005af:	85 c0                	test   %eax,%eax
  8005b1:	0f 48 c1             	cmovs  %ecx,%eax
  8005b4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005b7:	8b 75 10             	mov    0x10(%ebp),%esi
  8005ba:	e9 6d ff ff ff       	jmp    80052c <vprintfmt+0x77>
  8005bf:	8b 75 10             	mov    0x10(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8005c2:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8005c9:	e9 5e ff ff ff       	jmp    80052c <vprintfmt+0x77>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ce:	8b 75 10             	mov    0x10(%ebp),%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8005d1:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005d5:	0f 89 51 ff ff ff    	jns    80052c <vprintfmt+0x77>
				width = precision, precision = -1;
  8005db:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8005de:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8005e1:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8005e8:	e9 3f ff ff ff       	jmp    80052c <vprintfmt+0x77>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8005ed:	83 45 cc 01          	addl   $0x1,-0x34(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005f1:	8b 75 10             	mov    0x10(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8005f4:	e9 33 ff ff ff       	jmp    80052c <vprintfmt+0x77>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8005f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fc:	8d 50 04             	lea    0x4(%eax),%edx
  8005ff:	89 55 14             	mov    %edx,0x14(%ebp)
  800602:	83 ec 08             	sub    $0x8,%esp
  800605:	53                   	push   %ebx
  800606:	ff 30                	pushl  (%eax)
  800608:	ff d7                	call   *%edi
			break;
  80060a:	83 c4 10             	add    $0x10,%esp
  80060d:	e9 b7 fe ff ff       	jmp    8004c9 <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800612:	8b 45 14             	mov    0x14(%ebp),%eax
  800615:	8d 50 04             	lea    0x4(%eax),%edx
  800618:	89 55 14             	mov    %edx,0x14(%ebp)
  80061b:	8b 00                	mov    (%eax),%eax
  80061d:	99                   	cltd   
  80061e:	31 d0                	xor    %edx,%eax
  800620:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800622:	83 f8 06             	cmp    $0x6,%eax
  800625:	7f 0b                	jg     800632 <vprintfmt+0x17d>
  800627:	8b 14 85 64 13 80 00 	mov    0x801364(,%eax,4),%edx
  80062e:	85 d2                	test   %edx,%edx
  800630:	75 15                	jne    800647 <vprintfmt+0x192>
				printfmt(putch, putdat, "error %d", err);
  800632:	50                   	push   %eax
  800633:	68 1b 11 80 00       	push   $0x80111b
  800638:	53                   	push   %ebx
  800639:	57                   	push   %edi
  80063a:	e8 59 fe ff ff       	call   800498 <printfmt>
  80063f:	83 c4 10             	add    $0x10,%esp
  800642:	e9 82 fe ff ff       	jmp    8004c9 <vprintfmt+0x14>
			else
				printfmt(putch, putdat, "%s", p);
  800647:	52                   	push   %edx
  800648:	68 24 11 80 00       	push   $0x801124
  80064d:	53                   	push   %ebx
  80064e:	57                   	push   %edi
  80064f:	e8 44 fe ff ff       	call   800498 <printfmt>
  800654:	83 c4 10             	add    $0x10,%esp
  800657:	e9 6d fe ff ff       	jmp    8004c9 <vprintfmt+0x14>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80065c:	8b 45 14             	mov    0x14(%ebp),%eax
  80065f:	8d 50 04             	lea    0x4(%eax),%edx
  800662:	89 55 14             	mov    %edx,0x14(%ebp)
  800665:	8b 00                	mov    (%eax),%eax
				p = "(null)";
  800667:	85 c0                	test   %eax,%eax
  800669:	b9 14 11 80 00       	mov    $0x801114,%ecx
  80066e:	0f 45 c8             	cmovne %eax,%ecx
  800671:	89 4d cc             	mov    %ecx,-0x34(%ebp)
			if (width > 0 && padc != '-')
  800674:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800678:	7e 06                	jle    800680 <vprintfmt+0x1cb>
  80067a:	80 7d e3 2d          	cmpb   $0x2d,-0x1d(%ebp)
  80067e:	75 19                	jne    800699 <vprintfmt+0x1e4>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800680:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800683:	8d 70 01             	lea    0x1(%eax),%esi
  800686:	0f b6 00             	movzbl (%eax),%eax
  800689:	0f be d0             	movsbl %al,%edx
  80068c:	85 d2                	test   %edx,%edx
  80068e:	0f 85 9f 00 00 00    	jne    800733 <vprintfmt+0x27e>
  800694:	e9 8c 00 00 00       	jmp    800725 <vprintfmt+0x270>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800699:	83 ec 08             	sub    $0x8,%esp
  80069c:	ff 75 d0             	pushl  -0x30(%ebp)
  80069f:	ff 75 cc             	pushl  -0x34(%ebp)
  8006a2:	e8 56 03 00 00       	call   8009fd <strnlen>
  8006a7:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  8006aa:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8006ad:	83 c4 10             	add    $0x10,%esp
  8006b0:	85 c9                	test   %ecx,%ecx
  8006b2:	0f 8e 9a 02 00 00    	jle    800952 <vprintfmt+0x49d>
					putch(padc, putdat);
  8006b8:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  8006bc:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006bf:	89 cb                	mov    %ecx,%ebx
  8006c1:	83 ec 08             	sub    $0x8,%esp
  8006c4:	ff 75 0c             	pushl  0xc(%ebp)
  8006c7:	56                   	push   %esi
  8006c8:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006ca:	83 c4 10             	add    $0x10,%esp
  8006cd:	83 eb 01             	sub    $0x1,%ebx
  8006d0:	75 ef                	jne    8006c1 <vprintfmt+0x20c>
  8006d2:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8006d5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006d8:	e9 75 02 00 00       	jmp    800952 <vprintfmt+0x49d>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8006dd:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8006e1:	74 1b                	je     8006fe <vprintfmt+0x249>
  8006e3:	0f be c0             	movsbl %al,%eax
  8006e6:	83 e8 20             	sub    $0x20,%eax
  8006e9:	83 f8 5e             	cmp    $0x5e,%eax
  8006ec:	76 10                	jbe    8006fe <vprintfmt+0x249>
					putch('?', putdat);
  8006ee:	83 ec 08             	sub    $0x8,%esp
  8006f1:	ff 75 0c             	pushl  0xc(%ebp)
  8006f4:	6a 3f                	push   $0x3f
  8006f6:	ff 55 08             	call   *0x8(%ebp)
  8006f9:	83 c4 10             	add    $0x10,%esp
  8006fc:	eb 0d                	jmp    80070b <vprintfmt+0x256>
				else
					putch(ch, putdat);
  8006fe:	83 ec 08             	sub    $0x8,%esp
  800701:	ff 75 0c             	pushl  0xc(%ebp)
  800704:	52                   	push   %edx
  800705:	ff 55 08             	call   *0x8(%ebp)
  800708:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80070b:	83 ef 01             	sub    $0x1,%edi
  80070e:	83 c6 01             	add    $0x1,%esi
  800711:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  800715:	0f be d0             	movsbl %al,%edx
  800718:	85 d2                	test   %edx,%edx
  80071a:	75 31                	jne    80074d <vprintfmt+0x298>
  80071c:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  80071f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800722:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800725:	8b 75 e4             	mov    -0x1c(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800728:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80072c:	7f 33                	jg     800761 <vprintfmt+0x2ac>
  80072e:	e9 96 fd ff ff       	jmp    8004c9 <vprintfmt+0x14>
  800733:	89 7d 08             	mov    %edi,0x8(%ebp)
  800736:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800739:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80073c:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80073f:	eb 0c                	jmp    80074d <vprintfmt+0x298>
  800741:	89 7d 08             	mov    %edi,0x8(%ebp)
  800744:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800747:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80074a:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80074d:	85 db                	test   %ebx,%ebx
  80074f:	78 8c                	js     8006dd <vprintfmt+0x228>
  800751:	83 eb 01             	sub    $0x1,%ebx
  800754:	79 87                	jns    8006dd <vprintfmt+0x228>
  800756:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800759:	8b 7d 08             	mov    0x8(%ebp),%edi
  80075c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80075f:	eb c4                	jmp    800725 <vprintfmt+0x270>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800761:	83 ec 08             	sub    $0x8,%esp
  800764:	53                   	push   %ebx
  800765:	6a 20                	push   $0x20
  800767:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800769:	83 c4 10             	add    $0x10,%esp
  80076c:	83 ee 01             	sub    $0x1,%esi
  80076f:	75 f0                	jne    800761 <vprintfmt+0x2ac>
  800771:	e9 53 fd ff ff       	jmp    8004c9 <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800776:	83 7d cc 01          	cmpl   $0x1,-0x34(%ebp)
  80077a:	7e 16                	jle    800792 <vprintfmt+0x2dd>
		return va_arg(*ap, long long);
  80077c:	8b 45 14             	mov    0x14(%ebp),%eax
  80077f:	8d 50 08             	lea    0x8(%eax),%edx
  800782:	89 55 14             	mov    %edx,0x14(%ebp)
  800785:	8b 50 04             	mov    0x4(%eax),%edx
  800788:	8b 00                	mov    (%eax),%eax
  80078a:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80078d:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800790:	eb 34                	jmp    8007c6 <vprintfmt+0x311>
	else if (lflag)
  800792:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800796:	74 18                	je     8007b0 <vprintfmt+0x2fb>
		return va_arg(*ap, long);
  800798:	8b 45 14             	mov    0x14(%ebp),%eax
  80079b:	8d 50 04             	lea    0x4(%eax),%edx
  80079e:	89 55 14             	mov    %edx,0x14(%ebp)
  8007a1:	8b 30                	mov    (%eax),%esi
  8007a3:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8007a6:	89 f0                	mov    %esi,%eax
  8007a8:	c1 f8 1f             	sar    $0x1f,%eax
  8007ab:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8007ae:	eb 16                	jmp    8007c6 <vprintfmt+0x311>
	else
		return va_arg(*ap, int);
  8007b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b3:	8d 50 04             	lea    0x4(%eax),%edx
  8007b6:	89 55 14             	mov    %edx,0x14(%ebp)
  8007b9:	8b 30                	mov    (%eax),%esi
  8007bb:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8007be:	89 f0                	mov    %esi,%eax
  8007c0:	c1 f8 1f             	sar    $0x1f,%eax
  8007c3:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8007c6:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8007c9:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8007cc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007cf:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  8007d2:	85 d2                	test   %edx,%edx
  8007d4:	79 28                	jns    8007fe <vprintfmt+0x349>
				putch('-', putdat);
  8007d6:	83 ec 08             	sub    $0x8,%esp
  8007d9:	53                   	push   %ebx
  8007da:	6a 2d                	push   $0x2d
  8007dc:	ff d7                	call   *%edi
				num = -(long long) num;
  8007de:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8007e1:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8007e4:	f7 d8                	neg    %eax
  8007e6:	83 d2 00             	adc    $0x0,%edx
  8007e9:	f7 da                	neg    %edx
  8007eb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007ee:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007f1:	83 c4 10             	add    $0x10,%esp
			else
			{
				if(padc=='+')
					putch('+', putdat);
			}
			base = 10;
  8007f4:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007f9:	e9 a5 00 00 00       	jmp    8008a3 <vprintfmt+0x3ee>
  8007fe:	b8 0a 00 00 00       	mov    $0xa,%eax
				putch('-', putdat);
				num = -(long long) num;
			}
			else
			{
				if(padc=='+')
  800803:	80 7d e3 2b          	cmpb   $0x2b,-0x1d(%ebp)
  800807:	0f 85 96 00 00 00    	jne    8008a3 <vprintfmt+0x3ee>
					putch('+', putdat);
  80080d:	83 ec 08             	sub    $0x8,%esp
  800810:	53                   	push   %ebx
  800811:	6a 2b                	push   $0x2b
  800813:	ff d7                	call   *%edi
  800815:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800818:	b8 0a 00 00 00       	mov    $0xa,%eax
  80081d:	e9 81 00 00 00       	jmp    8008a3 <vprintfmt+0x3ee>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800822:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800825:	8d 45 14             	lea    0x14(%ebp),%eax
  800828:	e8 14 fc ff ff       	call   800441 <getuint>
  80082d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800830:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  800833:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800838:	eb 69                	jmp    8008a3 <vprintfmt+0x3ee>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			putch('0', putdat);
  80083a:	83 ec 08             	sub    $0x8,%esp
  80083d:	53                   	push   %ebx
  80083e:	6a 30                	push   $0x30
  800840:	ff d7                	call   *%edi
			num = getuint(&ap, lflag);
  800842:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800845:	8d 45 14             	lea    0x14(%ebp),%eax
  800848:	e8 f4 fb ff ff       	call   800441 <getuint>
  80084d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800850:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
			goto number;
  800853:	83 c4 10             	add    $0x10,%esp
		case 'o':
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
  800856:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  80085b:	eb 46                	jmp    8008a3 <vprintfmt+0x3ee>

		// pointer
		case 'p':
			putch('0', putdat);
  80085d:	83 ec 08             	sub    $0x8,%esp
  800860:	53                   	push   %ebx
  800861:	6a 30                	push   $0x30
  800863:	ff d7                	call   *%edi
			putch('x', putdat);
  800865:	83 c4 08             	add    $0x8,%esp
  800868:	53                   	push   %ebx
  800869:	6a 78                	push   $0x78
  80086b:	ff d7                	call   *%edi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80086d:	8b 45 14             	mov    0x14(%ebp),%eax
  800870:	8d 50 04             	lea    0x4(%eax),%edx
  800873:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800876:	8b 00                	mov    (%eax),%eax
  800878:	ba 00 00 00 00       	mov    $0x0,%edx
  80087d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800880:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800883:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800886:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80088b:	eb 16                	jmp    8008a3 <vprintfmt+0x3ee>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80088d:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800890:	8d 45 14             	lea    0x14(%ebp),%eax
  800893:	e8 a9 fb ff ff       	call   800441 <getuint>
  800898:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80089b:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  80089e:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8008a3:	83 ec 0c             	sub    $0xc,%esp
  8008a6:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  8008aa:	56                   	push   %esi
  8008ab:	ff 75 e4             	pushl  -0x1c(%ebp)
  8008ae:	50                   	push   %eax
  8008af:	ff 75 dc             	pushl  -0x24(%ebp)
  8008b2:	ff 75 d8             	pushl  -0x28(%ebp)
  8008b5:	89 da                	mov    %ebx,%edx
  8008b7:	89 f8                	mov    %edi,%eax
  8008b9:	e8 e3 f9 ff ff       	call   8002a1 <printnum>
			break;
  8008be:	83 c4 20             	add    $0x20,%esp
  8008c1:	e9 03 fc ff ff       	jmp    8004c9 <vprintfmt+0x14>

            const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
            const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

            // Your code here
			num=(unsigned long long)(uintptr_t)va_arg(ap, void *);
  8008c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8008c9:	8d 50 04             	lea    0x4(%eax),%edx
  8008cc:	89 55 14             	mov    %edx,0x14(%ebp)
  8008cf:	8b 00                	mov    (%eax),%eax
			if(!num)
  8008d1:	85 c0                	test   %eax,%eax
  8008d3:	75 1c                	jne    8008f1 <vprintfmt+0x43c>
				*(int *)putdat+=cprintf("%s",null_error);
  8008d5:	83 ec 08             	sub    $0x8,%esp
  8008d8:	68 90 11 80 00       	push   $0x801190
  8008dd:	68 24 11 80 00       	push   $0x801124
  8008e2:	e8 a6 f9 ff ff       	call   80028d <cprintf>
  8008e7:	01 03                	add    %eax,(%ebx)
  8008e9:	83 c4 10             	add    $0x10,%esp
  8008ec:	e9 d8 fb ff ff       	jmp    8004c9 <vprintfmt+0x14>
			else
			{
				*(char *)(int)num=*(int *)putdat;
  8008f1:	8b 13                	mov    (%ebx),%edx
  8008f3:	88 10                	mov    %dl,(%eax)
				if((*(int *)putdat)>128)
  8008f5:	81 3b 80 00 00 00    	cmpl   $0x80,(%ebx)
  8008fb:	0f 8e c8 fb ff ff    	jle    8004c9 <vprintfmt+0x14>
					*(int *)putdat+=cprintf("%s",overflow_error);
  800901:	83 ec 08             	sub    $0x8,%esp
  800904:	68 c8 11 80 00       	push   $0x8011c8
  800909:	68 24 11 80 00       	push   $0x801124
  80090e:	e8 7a f9 ff ff       	call   80028d <cprintf>
  800913:	01 03                	add    %eax,(%ebx)
  800915:	83 c4 10             	add    $0x10,%esp
  800918:	e9 ac fb ff ff       	jmp    8004c9 <vprintfmt+0x14>
            break;
        }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80091d:	83 ec 08             	sub    $0x8,%esp
  800920:	53                   	push   %ebx
  800921:	52                   	push   %edx
  800922:	ff d7                	call   *%edi
			break;
  800924:	83 c4 10             	add    $0x10,%esp
  800927:	e9 9d fb ff ff       	jmp    8004c9 <vprintfmt+0x14>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80092c:	83 ec 08             	sub    $0x8,%esp
  80092f:	53                   	push   %ebx
  800930:	6a 25                	push   $0x25
  800932:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800934:	83 c4 10             	add    $0x10,%esp
  800937:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80093b:	0f 84 85 fb ff ff    	je     8004c6 <vprintfmt+0x11>
  800941:	83 ee 01             	sub    $0x1,%esi
  800944:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800948:	75 f7                	jne    800941 <vprintfmt+0x48c>
  80094a:	89 75 10             	mov    %esi,0x10(%ebp)
  80094d:	e9 77 fb ff ff       	jmp    8004c9 <vprintfmt+0x14>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800952:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800955:	8d 70 01             	lea    0x1(%eax),%esi
  800958:	0f b6 00             	movzbl (%eax),%eax
  80095b:	0f be d0             	movsbl %al,%edx
  80095e:	85 d2                	test   %edx,%edx
  800960:	0f 85 db fd ff ff    	jne    800741 <vprintfmt+0x28c>
  800966:	e9 5e fb ff ff       	jmp    8004c9 <vprintfmt+0x14>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  80096b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80096e:	5b                   	pop    %ebx
  80096f:	5e                   	pop    %esi
  800970:	5f                   	pop    %edi
  800971:	5d                   	pop    %ebp
  800972:	c3                   	ret    

00800973 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800973:	55                   	push   %ebp
  800974:	89 e5                	mov    %esp,%ebp
  800976:	83 ec 18             	sub    $0x18,%esp
  800979:	8b 45 08             	mov    0x8(%ebp),%eax
  80097c:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80097f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800982:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800986:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800989:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800990:	85 c0                	test   %eax,%eax
  800992:	74 26                	je     8009ba <vsnprintf+0x47>
  800994:	85 d2                	test   %edx,%edx
  800996:	7e 22                	jle    8009ba <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800998:	ff 75 14             	pushl  0x14(%ebp)
  80099b:	ff 75 10             	pushl  0x10(%ebp)
  80099e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8009a1:	50                   	push   %eax
  8009a2:	68 7b 04 80 00       	push   $0x80047b
  8009a7:	e8 09 fb ff ff       	call   8004b5 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8009ac:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8009af:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8009b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009b5:	83 c4 10             	add    $0x10,%esp
  8009b8:	eb 05                	jmp    8009bf <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8009ba:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8009bf:	c9                   	leave  
  8009c0:	c3                   	ret    

008009c1 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8009c1:	55                   	push   %ebp
  8009c2:	89 e5                	mov    %esp,%ebp
  8009c4:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8009c7:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8009ca:	50                   	push   %eax
  8009cb:	ff 75 10             	pushl  0x10(%ebp)
  8009ce:	ff 75 0c             	pushl  0xc(%ebp)
  8009d1:	ff 75 08             	pushl  0x8(%ebp)
  8009d4:	e8 9a ff ff ff       	call   800973 <vsnprintf>
	va_end(ap);

	return rc;
}
  8009d9:	c9                   	leave  
  8009da:	c3                   	ret    

008009db <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8009db:	55                   	push   %ebp
  8009dc:	89 e5                	mov    %esp,%ebp
  8009de:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8009e1:	80 3a 00             	cmpb   $0x0,(%edx)
  8009e4:	74 10                	je     8009f6 <strlen+0x1b>
  8009e6:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8009eb:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8009ee:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8009f2:	75 f7                	jne    8009eb <strlen+0x10>
  8009f4:	eb 05                	jmp    8009fb <strlen+0x20>
  8009f6:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8009fb:	5d                   	pop    %ebp
  8009fc:	c3                   	ret    

008009fd <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8009fd:	55                   	push   %ebp
  8009fe:	89 e5                	mov    %esp,%ebp
  800a00:	53                   	push   %ebx
  800a01:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800a04:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a07:	85 c9                	test   %ecx,%ecx
  800a09:	74 1c                	je     800a27 <strnlen+0x2a>
  800a0b:	80 3b 00             	cmpb   $0x0,(%ebx)
  800a0e:	74 1e                	je     800a2e <strnlen+0x31>
  800a10:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  800a15:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a17:	39 ca                	cmp    %ecx,%edx
  800a19:	74 18                	je     800a33 <strnlen+0x36>
  800a1b:	83 c2 01             	add    $0x1,%edx
  800a1e:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800a23:	75 f0                	jne    800a15 <strnlen+0x18>
  800a25:	eb 0c                	jmp    800a33 <strnlen+0x36>
  800a27:	b8 00 00 00 00       	mov    $0x0,%eax
  800a2c:	eb 05                	jmp    800a33 <strnlen+0x36>
  800a2e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800a33:	5b                   	pop    %ebx
  800a34:	5d                   	pop    %ebp
  800a35:	c3                   	ret    

00800a36 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a36:	55                   	push   %ebp
  800a37:	89 e5                	mov    %esp,%ebp
  800a39:	53                   	push   %ebx
  800a3a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a3d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a40:	89 c2                	mov    %eax,%edx
  800a42:	83 c2 01             	add    $0x1,%edx
  800a45:	83 c1 01             	add    $0x1,%ecx
  800a48:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800a4c:	88 5a ff             	mov    %bl,-0x1(%edx)
  800a4f:	84 db                	test   %bl,%bl
  800a51:	75 ef                	jne    800a42 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800a53:	5b                   	pop    %ebx
  800a54:	5d                   	pop    %ebp
  800a55:	c3                   	ret    

00800a56 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a56:	55                   	push   %ebp
  800a57:	89 e5                	mov    %esp,%ebp
  800a59:	53                   	push   %ebx
  800a5a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a5d:	53                   	push   %ebx
  800a5e:	e8 78 ff ff ff       	call   8009db <strlen>
  800a63:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800a66:	ff 75 0c             	pushl  0xc(%ebp)
  800a69:	01 d8                	add    %ebx,%eax
  800a6b:	50                   	push   %eax
  800a6c:	e8 c5 ff ff ff       	call   800a36 <strcpy>
	return dst;
}
  800a71:	89 d8                	mov    %ebx,%eax
  800a73:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a76:	c9                   	leave  
  800a77:	c3                   	ret    

00800a78 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a78:	55                   	push   %ebp
  800a79:	89 e5                	mov    %esp,%ebp
  800a7b:	56                   	push   %esi
  800a7c:	53                   	push   %ebx
  800a7d:	8b 75 08             	mov    0x8(%ebp),%esi
  800a80:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a83:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a86:	85 db                	test   %ebx,%ebx
  800a88:	74 17                	je     800aa1 <strncpy+0x29>
  800a8a:	01 f3                	add    %esi,%ebx
  800a8c:	89 f1                	mov    %esi,%ecx
		*dst++ = *src;
  800a8e:	83 c1 01             	add    $0x1,%ecx
  800a91:	0f b6 02             	movzbl (%edx),%eax
  800a94:	88 41 ff             	mov    %al,-0x1(%ecx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a97:	80 3a 01             	cmpb   $0x1,(%edx)
  800a9a:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a9d:	39 cb                	cmp    %ecx,%ebx
  800a9f:	75 ed                	jne    800a8e <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800aa1:	89 f0                	mov    %esi,%eax
  800aa3:	5b                   	pop    %ebx
  800aa4:	5e                   	pop    %esi
  800aa5:	5d                   	pop    %ebp
  800aa6:	c3                   	ret    

00800aa7 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800aa7:	55                   	push   %ebp
  800aa8:	89 e5                	mov    %esp,%ebp
  800aaa:	56                   	push   %esi
  800aab:	53                   	push   %ebx
  800aac:	8b 75 08             	mov    0x8(%ebp),%esi
  800aaf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ab2:	8b 55 10             	mov    0x10(%ebp),%edx
  800ab5:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800ab7:	85 d2                	test   %edx,%edx
  800ab9:	74 35                	je     800af0 <strlcpy+0x49>
		while (--size > 0 && *src != '\0')
  800abb:	89 d0                	mov    %edx,%eax
  800abd:	83 e8 01             	sub    $0x1,%eax
  800ac0:	74 25                	je     800ae7 <strlcpy+0x40>
  800ac2:	0f b6 0b             	movzbl (%ebx),%ecx
  800ac5:	84 c9                	test   %cl,%cl
  800ac7:	74 22                	je     800aeb <strlcpy+0x44>
  800ac9:	8d 53 01             	lea    0x1(%ebx),%edx
  800acc:	01 c3                	add    %eax,%ebx
  800ace:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
  800ad0:	83 c0 01             	add    $0x1,%eax
  800ad3:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800ad6:	39 da                	cmp    %ebx,%edx
  800ad8:	74 13                	je     800aed <strlcpy+0x46>
  800ada:	83 c2 01             	add    $0x1,%edx
  800add:	0f b6 4a ff          	movzbl -0x1(%edx),%ecx
  800ae1:	84 c9                	test   %cl,%cl
  800ae3:	75 eb                	jne    800ad0 <strlcpy+0x29>
  800ae5:	eb 06                	jmp    800aed <strlcpy+0x46>
  800ae7:	89 f0                	mov    %esi,%eax
  800ae9:	eb 02                	jmp    800aed <strlcpy+0x46>
  800aeb:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800aed:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800af0:	29 f0                	sub    %esi,%eax
}
  800af2:	5b                   	pop    %ebx
  800af3:	5e                   	pop    %esi
  800af4:	5d                   	pop    %ebp
  800af5:	c3                   	ret    

00800af6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800af6:	55                   	push   %ebp
  800af7:	89 e5                	mov    %esp,%ebp
  800af9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800afc:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800aff:	0f b6 01             	movzbl (%ecx),%eax
  800b02:	84 c0                	test   %al,%al
  800b04:	74 15                	je     800b1b <strcmp+0x25>
  800b06:	3a 02                	cmp    (%edx),%al
  800b08:	75 11                	jne    800b1b <strcmp+0x25>
		p++, q++;
  800b0a:	83 c1 01             	add    $0x1,%ecx
  800b0d:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800b10:	0f b6 01             	movzbl (%ecx),%eax
  800b13:	84 c0                	test   %al,%al
  800b15:	74 04                	je     800b1b <strcmp+0x25>
  800b17:	3a 02                	cmp    (%edx),%al
  800b19:	74 ef                	je     800b0a <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800b1b:	0f b6 c0             	movzbl %al,%eax
  800b1e:	0f b6 12             	movzbl (%edx),%edx
  800b21:	29 d0                	sub    %edx,%eax
}
  800b23:	5d                   	pop    %ebp
  800b24:	c3                   	ret    

00800b25 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b25:	55                   	push   %ebp
  800b26:	89 e5                	mov    %esp,%ebp
  800b28:	56                   	push   %esi
  800b29:	53                   	push   %ebx
  800b2a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800b2d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b30:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  800b33:	85 f6                	test   %esi,%esi
  800b35:	74 29                	je     800b60 <strncmp+0x3b>
  800b37:	0f b6 03             	movzbl (%ebx),%eax
  800b3a:	84 c0                	test   %al,%al
  800b3c:	74 30                	je     800b6e <strncmp+0x49>
  800b3e:	3a 02                	cmp    (%edx),%al
  800b40:	75 2c                	jne    800b6e <strncmp+0x49>
  800b42:	8d 43 01             	lea    0x1(%ebx),%eax
  800b45:	01 de                	add    %ebx,%esi
		n--, p++, q++;
  800b47:	89 c3                	mov    %eax,%ebx
  800b49:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800b4c:	39 c6                	cmp    %eax,%esi
  800b4e:	74 17                	je     800b67 <strncmp+0x42>
  800b50:	0f b6 08             	movzbl (%eax),%ecx
  800b53:	84 c9                	test   %cl,%cl
  800b55:	74 17                	je     800b6e <strncmp+0x49>
  800b57:	83 c0 01             	add    $0x1,%eax
  800b5a:	3a 0a                	cmp    (%edx),%cl
  800b5c:	74 e9                	je     800b47 <strncmp+0x22>
  800b5e:	eb 0e                	jmp    800b6e <strncmp+0x49>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800b60:	b8 00 00 00 00       	mov    $0x0,%eax
  800b65:	eb 0f                	jmp    800b76 <strncmp+0x51>
  800b67:	b8 00 00 00 00       	mov    $0x0,%eax
  800b6c:	eb 08                	jmp    800b76 <strncmp+0x51>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b6e:	0f b6 03             	movzbl (%ebx),%eax
  800b71:	0f b6 12             	movzbl (%edx),%edx
  800b74:	29 d0                	sub    %edx,%eax
}
  800b76:	5b                   	pop    %ebx
  800b77:	5e                   	pop    %esi
  800b78:	5d                   	pop    %ebp
  800b79:	c3                   	ret    

00800b7a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b7a:	55                   	push   %ebp
  800b7b:	89 e5                	mov    %esp,%ebp
  800b7d:	53                   	push   %ebx
  800b7e:	8b 45 08             	mov    0x8(%ebp),%eax
  800b81:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
  800b84:	0f b6 10             	movzbl (%eax),%edx
  800b87:	84 d2                	test   %dl,%dl
  800b89:	74 1d                	je     800ba8 <strchr+0x2e>
  800b8b:	89 d9                	mov    %ebx,%ecx
		if (*s == c)
  800b8d:	38 d3                	cmp    %dl,%bl
  800b8f:	75 06                	jne    800b97 <strchr+0x1d>
  800b91:	eb 1a                	jmp    800bad <strchr+0x33>
  800b93:	38 ca                	cmp    %cl,%dl
  800b95:	74 16                	je     800bad <strchr+0x33>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b97:	83 c0 01             	add    $0x1,%eax
  800b9a:	0f b6 10             	movzbl (%eax),%edx
  800b9d:	84 d2                	test   %dl,%dl
  800b9f:	75 f2                	jne    800b93 <strchr+0x19>
		if (*s == c)
			return (char *) s;
	return 0;
  800ba1:	b8 00 00 00 00       	mov    $0x0,%eax
  800ba6:	eb 05                	jmp    800bad <strchr+0x33>
  800ba8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bad:	5b                   	pop    %ebx
  800bae:	5d                   	pop    %ebp
  800baf:	c3                   	ret    

00800bb0 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800bb0:	55                   	push   %ebp
  800bb1:	89 e5                	mov    %esp,%ebp
  800bb3:	53                   	push   %ebx
  800bb4:	8b 45 08             	mov    0x8(%ebp),%eax
  800bb7:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  800bba:	0f b6 18             	movzbl (%eax),%ebx
		if (*s == c)
  800bbd:	38 d3                	cmp    %dl,%bl
  800bbf:	74 14                	je     800bd5 <strfind+0x25>
  800bc1:	89 d1                	mov    %edx,%ecx
  800bc3:	84 db                	test   %bl,%bl
  800bc5:	74 0e                	je     800bd5 <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800bc7:	83 c0 01             	add    $0x1,%eax
  800bca:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800bcd:	38 ca                	cmp    %cl,%dl
  800bcf:	74 04                	je     800bd5 <strfind+0x25>
  800bd1:	84 d2                	test   %dl,%dl
  800bd3:	75 f2                	jne    800bc7 <strfind+0x17>
			break;
	return (char *) s;
}
  800bd5:	5b                   	pop    %ebx
  800bd6:	5d                   	pop    %ebp
  800bd7:	c3                   	ret    

00800bd8 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800bd8:	55                   	push   %ebp
  800bd9:	89 e5                	mov    %esp,%ebp
  800bdb:	57                   	push   %edi
  800bdc:	56                   	push   %esi
  800bdd:	53                   	push   %ebx
  800bde:	8b 7d 08             	mov    0x8(%ebp),%edi
  800be1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800be4:	85 c9                	test   %ecx,%ecx
  800be6:	74 36                	je     800c1e <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800be8:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800bee:	75 28                	jne    800c18 <memset+0x40>
  800bf0:	f6 c1 03             	test   $0x3,%cl
  800bf3:	75 23                	jne    800c18 <memset+0x40>
		c &= 0xFF;
  800bf5:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800bf9:	89 d3                	mov    %edx,%ebx
  800bfb:	c1 e3 08             	shl    $0x8,%ebx
  800bfe:	89 d6                	mov    %edx,%esi
  800c00:	c1 e6 18             	shl    $0x18,%esi
  800c03:	89 d0                	mov    %edx,%eax
  800c05:	c1 e0 10             	shl    $0x10,%eax
  800c08:	09 f0                	or     %esi,%eax
  800c0a:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800c0c:	89 d8                	mov    %ebx,%eax
  800c0e:	09 d0                	or     %edx,%eax
  800c10:	c1 e9 02             	shr    $0x2,%ecx
  800c13:	fc                   	cld    
  800c14:	f3 ab                	rep stos %eax,%es:(%edi)
  800c16:	eb 06                	jmp    800c1e <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800c18:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c1b:	fc                   	cld    
  800c1c:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800c1e:	89 f8                	mov    %edi,%eax
  800c20:	5b                   	pop    %ebx
  800c21:	5e                   	pop    %esi
  800c22:	5f                   	pop    %edi
  800c23:	5d                   	pop    %ebp
  800c24:	c3                   	ret    

00800c25 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800c25:	55                   	push   %ebp
  800c26:	89 e5                	mov    %esp,%ebp
  800c28:	57                   	push   %edi
  800c29:	56                   	push   %esi
  800c2a:	8b 45 08             	mov    0x8(%ebp),%eax
  800c2d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c30:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800c33:	39 c6                	cmp    %eax,%esi
  800c35:	73 35                	jae    800c6c <memmove+0x47>
  800c37:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c3a:	39 d0                	cmp    %edx,%eax
  800c3c:	73 2e                	jae    800c6c <memmove+0x47>
		s += n;
		d += n;
  800c3e:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c41:	89 d6                	mov    %edx,%esi
  800c43:	09 fe                	or     %edi,%esi
  800c45:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c4b:	75 13                	jne    800c60 <memmove+0x3b>
  800c4d:	f6 c1 03             	test   $0x3,%cl
  800c50:	75 0e                	jne    800c60 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800c52:	83 ef 04             	sub    $0x4,%edi
  800c55:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c58:	c1 e9 02             	shr    $0x2,%ecx
  800c5b:	fd                   	std    
  800c5c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c5e:	eb 09                	jmp    800c69 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800c60:	83 ef 01             	sub    $0x1,%edi
  800c63:	8d 72 ff             	lea    -0x1(%edx),%esi
  800c66:	fd                   	std    
  800c67:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c69:	fc                   	cld    
  800c6a:	eb 1d                	jmp    800c89 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c6c:	89 f2                	mov    %esi,%edx
  800c6e:	09 c2                	or     %eax,%edx
  800c70:	f6 c2 03             	test   $0x3,%dl
  800c73:	75 0f                	jne    800c84 <memmove+0x5f>
  800c75:	f6 c1 03             	test   $0x3,%cl
  800c78:	75 0a                	jne    800c84 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800c7a:	c1 e9 02             	shr    $0x2,%ecx
  800c7d:	89 c7                	mov    %eax,%edi
  800c7f:	fc                   	cld    
  800c80:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c82:	eb 05                	jmp    800c89 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c84:	89 c7                	mov    %eax,%edi
  800c86:	fc                   	cld    
  800c87:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c89:	5e                   	pop    %esi
  800c8a:	5f                   	pop    %edi
  800c8b:	5d                   	pop    %ebp
  800c8c:	c3                   	ret    

00800c8d <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800c8d:	55                   	push   %ebp
  800c8e:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800c90:	ff 75 10             	pushl  0x10(%ebp)
  800c93:	ff 75 0c             	pushl  0xc(%ebp)
  800c96:	ff 75 08             	pushl  0x8(%ebp)
  800c99:	e8 87 ff ff ff       	call   800c25 <memmove>
}
  800c9e:	c9                   	leave  
  800c9f:	c3                   	ret    

00800ca0 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ca0:	55                   	push   %ebp
  800ca1:	89 e5                	mov    %esp,%ebp
  800ca3:	57                   	push   %edi
  800ca4:	56                   	push   %esi
  800ca5:	53                   	push   %ebx
  800ca6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800ca9:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cac:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800caf:	85 c0                	test   %eax,%eax
  800cb1:	74 39                	je     800cec <memcmp+0x4c>
  800cb3:	8d 78 ff             	lea    -0x1(%eax),%edi
		if (*s1 != *s2)
  800cb6:	0f b6 13             	movzbl (%ebx),%edx
  800cb9:	0f b6 0e             	movzbl (%esi),%ecx
  800cbc:	38 ca                	cmp    %cl,%dl
  800cbe:	75 17                	jne    800cd7 <memcmp+0x37>
  800cc0:	b8 00 00 00 00       	mov    $0x0,%eax
  800cc5:	eb 1a                	jmp    800ce1 <memcmp+0x41>
  800cc7:	0f b6 54 03 01       	movzbl 0x1(%ebx,%eax,1),%edx
  800ccc:	83 c0 01             	add    $0x1,%eax
  800ccf:	0f b6 0c 06          	movzbl (%esi,%eax,1),%ecx
  800cd3:	38 ca                	cmp    %cl,%dl
  800cd5:	74 0a                	je     800ce1 <memcmp+0x41>
			return (int) *s1 - (int) *s2;
  800cd7:	0f b6 c2             	movzbl %dl,%eax
  800cda:	0f b6 c9             	movzbl %cl,%ecx
  800cdd:	29 c8                	sub    %ecx,%eax
  800cdf:	eb 10                	jmp    800cf1 <memcmp+0x51>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ce1:	39 f8                	cmp    %edi,%eax
  800ce3:	75 e2                	jne    800cc7 <memcmp+0x27>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800ce5:	b8 00 00 00 00       	mov    $0x0,%eax
  800cea:	eb 05                	jmp    800cf1 <memcmp+0x51>
  800cec:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800cf1:	5b                   	pop    %ebx
  800cf2:	5e                   	pop    %esi
  800cf3:	5f                   	pop    %edi
  800cf4:	5d                   	pop    %ebp
  800cf5:	c3                   	ret    

00800cf6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800cf6:	55                   	push   %ebp
  800cf7:	89 e5                	mov    %esp,%ebp
  800cf9:	53                   	push   %ebx
  800cfa:	8b 55 08             	mov    0x8(%ebp),%edx
	const void *ends = (const char *) s + n;
  800cfd:	89 d0                	mov    %edx,%eax
  800cff:	03 45 10             	add    0x10(%ebp),%eax
	for (; s < ends; s++)
  800d02:	39 c2                	cmp    %eax,%edx
  800d04:	73 1d                	jae    800d23 <memfind+0x2d>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d06:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
  800d0a:	0f b6 0a             	movzbl (%edx),%ecx
  800d0d:	39 d9                	cmp    %ebx,%ecx
  800d0f:	75 09                	jne    800d1a <memfind+0x24>
  800d11:	eb 14                	jmp    800d27 <memfind+0x31>
  800d13:	0f b6 0a             	movzbl (%edx),%ecx
  800d16:	39 d9                	cmp    %ebx,%ecx
  800d18:	74 11                	je     800d2b <memfind+0x35>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800d1a:	83 c2 01             	add    $0x1,%edx
  800d1d:	39 d0                	cmp    %edx,%eax
  800d1f:	75 f2                	jne    800d13 <memfind+0x1d>
  800d21:	eb 0a                	jmp    800d2d <memfind+0x37>
  800d23:	89 d0                	mov    %edx,%eax
  800d25:	eb 06                	jmp    800d2d <memfind+0x37>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d27:	89 d0                	mov    %edx,%eax
  800d29:	eb 02                	jmp    800d2d <memfind+0x37>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800d2b:	89 d0                	mov    %edx,%eax
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800d2d:	5b                   	pop    %ebx
  800d2e:	5d                   	pop    %ebp
  800d2f:	c3                   	ret    

00800d30 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d30:	55                   	push   %ebp
  800d31:	89 e5                	mov    %esp,%ebp
  800d33:	57                   	push   %edi
  800d34:	56                   	push   %esi
  800d35:	53                   	push   %ebx
  800d36:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d39:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d3c:	0f b6 01             	movzbl (%ecx),%eax
  800d3f:	3c 20                	cmp    $0x20,%al
  800d41:	74 04                	je     800d47 <strtol+0x17>
  800d43:	3c 09                	cmp    $0x9,%al
  800d45:	75 0e                	jne    800d55 <strtol+0x25>
		s++;
  800d47:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d4a:	0f b6 01             	movzbl (%ecx),%eax
  800d4d:	3c 20                	cmp    $0x20,%al
  800d4f:	74 f6                	je     800d47 <strtol+0x17>
  800d51:	3c 09                	cmp    $0x9,%al
  800d53:	74 f2                	je     800d47 <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  800d55:	3c 2b                	cmp    $0x2b,%al
  800d57:	75 0a                	jne    800d63 <strtol+0x33>
		s++;
  800d59:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800d5c:	bf 00 00 00 00       	mov    $0x0,%edi
  800d61:	eb 11                	jmp    800d74 <strtol+0x44>
  800d63:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800d68:	3c 2d                	cmp    $0x2d,%al
  800d6a:	75 08                	jne    800d74 <strtol+0x44>
		s++, neg = 1;
  800d6c:	83 c1 01             	add    $0x1,%ecx
  800d6f:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d74:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800d7a:	75 15                	jne    800d91 <strtol+0x61>
  800d7c:	80 39 30             	cmpb   $0x30,(%ecx)
  800d7f:	75 10                	jne    800d91 <strtol+0x61>
  800d81:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800d85:	75 7c                	jne    800e03 <strtol+0xd3>
		s += 2, base = 16;
  800d87:	83 c1 02             	add    $0x2,%ecx
  800d8a:	bb 10 00 00 00       	mov    $0x10,%ebx
  800d8f:	eb 16                	jmp    800da7 <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  800d91:	85 db                	test   %ebx,%ebx
  800d93:	75 12                	jne    800da7 <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800d95:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800d9a:	80 39 30             	cmpb   $0x30,(%ecx)
  800d9d:	75 08                	jne    800da7 <strtol+0x77>
		s++, base = 8;
  800d9f:	83 c1 01             	add    $0x1,%ecx
  800da2:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800da7:	b8 00 00 00 00       	mov    $0x0,%eax
  800dac:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800daf:	0f b6 11             	movzbl (%ecx),%edx
  800db2:	8d 72 d0             	lea    -0x30(%edx),%esi
  800db5:	89 f3                	mov    %esi,%ebx
  800db7:	80 fb 09             	cmp    $0x9,%bl
  800dba:	77 08                	ja     800dc4 <strtol+0x94>
			dig = *s - '0';
  800dbc:	0f be d2             	movsbl %dl,%edx
  800dbf:	83 ea 30             	sub    $0x30,%edx
  800dc2:	eb 22                	jmp    800de6 <strtol+0xb6>
		else if (*s >= 'a' && *s <= 'z')
  800dc4:	8d 72 9f             	lea    -0x61(%edx),%esi
  800dc7:	89 f3                	mov    %esi,%ebx
  800dc9:	80 fb 19             	cmp    $0x19,%bl
  800dcc:	77 08                	ja     800dd6 <strtol+0xa6>
			dig = *s - 'a' + 10;
  800dce:	0f be d2             	movsbl %dl,%edx
  800dd1:	83 ea 57             	sub    $0x57,%edx
  800dd4:	eb 10                	jmp    800de6 <strtol+0xb6>
		else if (*s >= 'A' && *s <= 'Z')
  800dd6:	8d 72 bf             	lea    -0x41(%edx),%esi
  800dd9:	89 f3                	mov    %esi,%ebx
  800ddb:	80 fb 19             	cmp    $0x19,%bl
  800dde:	77 16                	ja     800df6 <strtol+0xc6>
			dig = *s - 'A' + 10;
  800de0:	0f be d2             	movsbl %dl,%edx
  800de3:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800de6:	3b 55 10             	cmp    0x10(%ebp),%edx
  800de9:	7d 0b                	jge    800df6 <strtol+0xc6>
			break;
		s++, val = (val * base) + dig;
  800deb:	83 c1 01             	add    $0x1,%ecx
  800dee:	0f af 45 10          	imul   0x10(%ebp),%eax
  800df2:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800df4:	eb b9                	jmp    800daf <strtol+0x7f>

	if (endptr)
  800df6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800dfa:	74 0d                	je     800e09 <strtol+0xd9>
		*endptr = (char *) s;
  800dfc:	8b 75 0c             	mov    0xc(%ebp),%esi
  800dff:	89 0e                	mov    %ecx,(%esi)
  800e01:	eb 06                	jmp    800e09 <strtol+0xd9>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800e03:	85 db                	test   %ebx,%ebx
  800e05:	74 98                	je     800d9f <strtol+0x6f>
  800e07:	eb 9e                	jmp    800da7 <strtol+0x77>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800e09:	89 c2                	mov    %eax,%edx
  800e0b:	f7 da                	neg    %edx
  800e0d:	85 ff                	test   %edi,%edi
  800e0f:	0f 45 c2             	cmovne %edx,%eax
}
  800e12:	5b                   	pop    %ebx
  800e13:	5e                   	pop    %esi
  800e14:	5f                   	pop    %edi
  800e15:	5d                   	pop    %ebp
  800e16:	c3                   	ret    
  800e17:	66 90                	xchg   %ax,%ax
  800e19:	66 90                	xchg   %ax,%ax
  800e1b:	66 90                	xchg   %ax,%ax
  800e1d:	66 90                	xchg   %ax,%ax
  800e1f:	90                   	nop

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
