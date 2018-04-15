
obj/user/faultwritekernel:     file format elf32-i386


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
  80002c:	e8 11 00 00 00       	call   800042 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	*(unsigned*)0xf0100000 = 0;
  800036:	c7 05 00 00 10 f0 00 	movl   $0x0,0xf0100000
  80003d:	00 00 00 
}
  800040:	5d                   	pop    %ebp
  800041:	c3                   	ret    

00800042 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800042:	55                   	push   %ebp
  800043:	89 e5                	mov    %esp,%ebp
  800045:	83 ec 08             	sub    $0x8,%esp
  800048:	8b 45 08             	mov    0x8(%ebp),%eax
  80004b:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  80004e:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800055:	00 00 00 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800058:	85 c0                	test   %eax,%eax
  80005a:	7e 08                	jle    800064 <libmain+0x22>
		binaryname = argv[0];
  80005c:	8b 0a                	mov    (%edx),%ecx
  80005e:	89 0d 00 20 80 00    	mov    %ecx,0x802000

	// call user main routine
	umain(argc, argv);
  800064:	83 ec 08             	sub    $0x8,%esp
  800067:	52                   	push   %edx
  800068:	50                   	push   %eax
  800069:	e8 c5 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80006e:	e8 05 00 00 00       	call   800078 <exit>
}
  800073:	83 c4 10             	add    $0x10,%esp
  800076:	c9                   	leave  
  800077:	c3                   	ret    

00800078 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800078:	55                   	push   %ebp
  800079:	89 e5                	mov    %esp,%ebp
  80007b:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80007e:	6a 00                	push   $0x0
  800080:	e8 52 00 00 00       	call   8000d7 <sys_env_destroy>
}
  800085:	83 c4 10             	add    $0x10,%esp
  800088:	c9                   	leave  
  800089:	c3                   	ret    

0080008a <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  80008a:	55                   	push   %ebp
  80008b:	89 e5                	mov    %esp,%ebp
  80008d:	57                   	push   %edi
  80008e:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80008f:	b8 00 00 00 00       	mov    $0x0,%eax
  800094:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800097:	8b 55 08             	mov    0x8(%ebp),%edx
  80009a:	89 c3                	mov    %eax,%ebx
  80009c:	89 c7                	mov    %eax,%edi
  80009e:	51                   	push   %ecx
  80009f:	52                   	push   %edx
  8000a0:	53                   	push   %ebx
  8000a1:	54                   	push   %esp
  8000a2:	55                   	push   %ebp
  8000a3:	56                   	push   %esi
  8000a4:	57                   	push   %edi
  8000a5:	5f                   	pop    %edi
  8000a6:	5e                   	pop    %esi
  8000a7:	5d                   	pop    %ebp
  8000a8:	5c                   	pop    %esp
  8000a9:	5b                   	pop    %ebx
  8000aa:	5a                   	pop    %edx
  8000ab:	59                   	pop    %ecx

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000ac:	5b                   	pop    %ebx
  8000ad:	5f                   	pop    %edi
  8000ae:	5d                   	pop    %ebp
  8000af:	c3                   	ret    

008000b0 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000b0:	55                   	push   %ebp
  8000b1:	89 e5                	mov    %esp,%ebp
  8000b3:	57                   	push   %edi
  8000b4:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8000b5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000ba:	b8 01 00 00 00       	mov    $0x1,%eax
  8000bf:	89 ca                	mov    %ecx,%edx
  8000c1:	89 cb                	mov    %ecx,%ebx
  8000c3:	89 cf                	mov    %ecx,%edi
  8000c5:	51                   	push   %ecx
  8000c6:	52                   	push   %edx
  8000c7:	53                   	push   %ebx
  8000c8:	54                   	push   %esp
  8000c9:	55                   	push   %ebp
  8000ca:	56                   	push   %esi
  8000cb:	57                   	push   %edi
  8000cc:	5f                   	pop    %edi
  8000cd:	5e                   	pop    %esi
  8000ce:	5d                   	pop    %ebp
  8000cf:	5c                   	pop    %esp
  8000d0:	5b                   	pop    %ebx
  8000d1:	5a                   	pop    %edx
  8000d2:	59                   	pop    %ecx

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000d3:	5b                   	pop    %ebx
  8000d4:	5f                   	pop    %edi
  8000d5:	5d                   	pop    %ebp
  8000d6:	c3                   	ret    

008000d7 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000d7:	55                   	push   %ebp
  8000d8:	89 e5                	mov    %esp,%ebp
  8000da:	57                   	push   %edi
  8000db:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8000dc:	bb 00 00 00 00       	mov    $0x0,%ebx
  8000e1:	b8 03 00 00 00       	mov    $0x3,%eax
  8000e6:	8b 55 08             	mov    0x8(%ebp),%edx
  8000e9:	89 d9                	mov    %ebx,%ecx
  8000eb:	89 df                	mov    %ebx,%edi
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
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  8000fb:	85 c0                	test   %eax,%eax
  8000fd:	7e 17                	jle    800116 <sys_env_destroy+0x3f>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000ff:	83 ec 0c             	sub    $0xc,%esp
  800102:	50                   	push   %eax
  800103:	6a 03                	push   $0x3
  800105:	68 ae 10 80 00       	push   $0x8010ae
  80010a:	6a 26                	push   $0x26
  80010c:	68 cb 10 80 00       	push   $0x8010cb
  800111:	e8 7f 00 00 00       	call   800195 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800116:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800119:	5b                   	pop    %ebx
  80011a:	5f                   	pop    %edi
  80011b:	5d                   	pop    %ebp
  80011c:	c3                   	ret    

0080011d <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80011d:	55                   	push   %ebp
  80011e:	89 e5                	mov    %esp,%ebp
  800120:	57                   	push   %edi
  800121:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800122:	b9 00 00 00 00       	mov    $0x0,%ecx
  800127:	b8 02 00 00 00       	mov    $0x2,%eax
  80012c:	89 ca                	mov    %ecx,%edx
  80012e:	89 cb                	mov    %ecx,%ebx
  800130:	89 cf                	mov    %ecx,%edi
  800132:	51                   	push   %ecx
  800133:	52                   	push   %edx
  800134:	53                   	push   %ebx
  800135:	54                   	push   %esp
  800136:	55                   	push   %ebp
  800137:	56                   	push   %esi
  800138:	57                   	push   %edi
  800139:	5f                   	pop    %edi
  80013a:	5e                   	pop    %esi
  80013b:	5d                   	pop    %ebp
  80013c:	5c                   	pop    %esp
  80013d:	5b                   	pop    %ebx
  80013e:	5a                   	pop    %edx
  80013f:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800140:	5b                   	pop    %ebx
  800141:	5f                   	pop    %edi
  800142:	5d                   	pop    %ebp
  800143:	c3                   	ret    

00800144 <sys_map_kernel_page>:

int
sys_map_kernel_page(void* kpage, void* va)
{
  800144:	55                   	push   %ebp
  800145:	89 e5                	mov    %esp,%ebp
  800147:	57                   	push   %edi
  800148:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800149:	bf 00 00 00 00       	mov    $0x0,%edi
  80014e:	b8 04 00 00 00       	mov    $0x4,%eax
  800153:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800156:	8b 55 08             	mov    0x8(%ebp),%edx
  800159:	89 fb                	mov    %edi,%ebx
  80015b:	51                   	push   %ecx
  80015c:	52                   	push   %edx
  80015d:	53                   	push   %ebx
  80015e:	54                   	push   %esp
  80015f:	55                   	push   %ebp
  800160:	56                   	push   %esi
  800161:	57                   	push   %edi
  800162:	5f                   	pop    %edi
  800163:	5e                   	pop    %esi
  800164:	5d                   	pop    %ebp
  800165:	5c                   	pop    %esp
  800166:	5b                   	pop    %ebx
  800167:	5a                   	pop    %edx
  800168:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  800169:	5b                   	pop    %ebx
  80016a:	5f                   	pop    %edi
  80016b:	5d                   	pop    %ebp
  80016c:	c3                   	ret    

0080016d <sys_sbrk>:

int
sys_sbrk(uint32_t inc)
{
  80016d:	55                   	push   %ebp
  80016e:	89 e5                	mov    %esp,%ebp
  800170:	57                   	push   %edi
  800171:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800172:	b9 00 00 00 00       	mov    $0x0,%ecx
  800177:	b8 05 00 00 00       	mov    $0x5,%eax
  80017c:	8b 55 08             	mov    0x8(%ebp),%edx
  80017f:	89 cb                	mov    %ecx,%ebx
  800181:	89 cf                	mov    %ecx,%edi
  800183:	51                   	push   %ecx
  800184:	52                   	push   %edx
  800185:	53                   	push   %ebx
  800186:	54                   	push   %esp
  800187:	55                   	push   %ebp
  800188:	56                   	push   %esi
  800189:	57                   	push   %edi
  80018a:	5f                   	pop    %edi
  80018b:	5e                   	pop    %esi
  80018c:	5d                   	pop    %ebp
  80018d:	5c                   	pop    %esp
  80018e:	5b                   	pop    %ebx
  80018f:	5a                   	pop    %edx
  800190:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  800191:	5b                   	pop    %ebx
  800192:	5f                   	pop    %edi
  800193:	5d                   	pop    %ebp
  800194:	c3                   	ret    

00800195 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800195:	55                   	push   %ebp
  800196:	89 e5                	mov    %esp,%ebp
  800198:	56                   	push   %esi
  800199:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80019a:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	if (argv0)
  80019d:	a1 08 20 80 00       	mov    0x802008,%eax
  8001a2:	85 c0                	test   %eax,%eax
  8001a4:	74 11                	je     8001b7 <_panic+0x22>
		cprintf("%s: ", argv0);
  8001a6:	83 ec 08             	sub    $0x8,%esp
  8001a9:	50                   	push   %eax
  8001aa:	68 d9 10 80 00       	push   $0x8010d9
  8001af:	e8 d4 00 00 00       	call   800288 <cprintf>
  8001b4:	83 c4 10             	add    $0x10,%esp
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001b7:	8b 35 00 20 80 00    	mov    0x802000,%esi
  8001bd:	e8 5b ff ff ff       	call   80011d <sys_getenvid>
  8001c2:	83 ec 0c             	sub    $0xc,%esp
  8001c5:	ff 75 0c             	pushl  0xc(%ebp)
  8001c8:	ff 75 08             	pushl  0x8(%ebp)
  8001cb:	56                   	push   %esi
  8001cc:	50                   	push   %eax
  8001cd:	68 e0 10 80 00       	push   $0x8010e0
  8001d2:	e8 b1 00 00 00       	call   800288 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001d7:	83 c4 18             	add    $0x18,%esp
  8001da:	53                   	push   %ebx
  8001db:	ff 75 10             	pushl  0x10(%ebp)
  8001de:	e8 54 00 00 00       	call   800237 <vcprintf>
	cprintf("\n");
  8001e3:	c7 04 24 de 10 80 00 	movl   $0x8010de,(%esp)
  8001ea:	e8 99 00 00 00       	call   800288 <cprintf>
  8001ef:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001f2:	cc                   	int3   
  8001f3:	eb fd                	jmp    8001f2 <_panic+0x5d>

008001f5 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001f5:	55                   	push   %ebp
  8001f6:	89 e5                	mov    %esp,%ebp
  8001f8:	53                   	push   %ebx
  8001f9:	83 ec 04             	sub    $0x4,%esp
  8001fc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001ff:	8b 13                	mov    (%ebx),%edx
  800201:	8d 42 01             	lea    0x1(%edx),%eax
  800204:	89 03                	mov    %eax,(%ebx)
  800206:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800209:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80020d:	3d ff 00 00 00       	cmp    $0xff,%eax
  800212:	75 1a                	jne    80022e <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800214:	83 ec 08             	sub    $0x8,%esp
  800217:	68 ff 00 00 00       	push   $0xff
  80021c:	8d 43 08             	lea    0x8(%ebx),%eax
  80021f:	50                   	push   %eax
  800220:	e8 65 fe ff ff       	call   80008a <sys_cputs>
		b->idx = 0;
  800225:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80022b:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80022e:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800232:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800235:	c9                   	leave  
  800236:	c3                   	ret    

00800237 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800237:	55                   	push   %ebp
  800238:	89 e5                	mov    %esp,%ebp
  80023a:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800240:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800247:	00 00 00 
	b.cnt = 0;
  80024a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800251:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800254:	ff 75 0c             	pushl  0xc(%ebp)
  800257:	ff 75 08             	pushl  0x8(%ebp)
  80025a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800260:	50                   	push   %eax
  800261:	68 f5 01 80 00       	push   $0x8001f5
  800266:	e8 45 02 00 00       	call   8004b0 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80026b:	83 c4 08             	add    $0x8,%esp
  80026e:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800274:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80027a:	50                   	push   %eax
  80027b:	e8 0a fe ff ff       	call   80008a <sys_cputs>

	return b.cnt;
}
  800280:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800286:	c9                   	leave  
  800287:	c3                   	ret    

00800288 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800288:	55                   	push   %ebp
  800289:	89 e5                	mov    %esp,%ebp
  80028b:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80028e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800291:	50                   	push   %eax
  800292:	ff 75 08             	pushl  0x8(%ebp)
  800295:	e8 9d ff ff ff       	call   800237 <vcprintf>
	va_end(ap);

	return cnt;
}
  80029a:	c9                   	leave  
  80029b:	c3                   	ret    

0080029c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80029c:	55                   	push   %ebp
  80029d:	89 e5                	mov    %esp,%ebp
  80029f:	57                   	push   %edi
  8002a0:	56                   	push   %esi
  8002a1:	53                   	push   %ebx
  8002a2:	83 ec 1c             	sub    $0x1c,%esp
  8002a5:	89 c7                	mov    %eax,%edi
  8002a7:	89 d6                	mov    %edx,%esi
  8002a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8002ac:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002af:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002b2:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	// if cprintf'parameter includes pattern of the form "%-", padding
	// space on the right side if neccesary.
	// you can add helper function if needed.
	// your code here:
	int length,showsign=0;
	if(padc=='-'&&num>=base)
  8002b5:	83 7d 18 2d          	cmpl   $0x2d,0x18(%ebp)
  8002b9:	0f 85 8a 00 00 00    	jne    800349 <printnum+0xad>
  8002bf:	8b 45 10             	mov    0x10(%ebp),%eax
  8002c2:	ba 00 00 00 00       	mov    $0x0,%edx
  8002c7:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8002ca:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8002cd:	39 da                	cmp    %ebx,%edx
  8002cf:	72 09                	jb     8002da <printnum+0x3e>
  8002d1:	39 4d 10             	cmp    %ecx,0x10(%ebp)
  8002d4:	0f 87 87 00 00 00    	ja     800361 <printnum+0xc5>
	{
		length=*(int *)putdat;
  8002da:	8b 1e                	mov    (%esi),%ebx
		printnum(putch,putdat,num/base,base,0,padc);
  8002dc:	83 ec 0c             	sub    $0xc,%esp
  8002df:	6a 2d                	push   $0x2d
  8002e1:	6a 00                	push   $0x0
  8002e3:	ff 75 10             	pushl  0x10(%ebp)
  8002e6:	83 ec 08             	sub    $0x8,%esp
  8002e9:	52                   	push   %edx
  8002ea:	50                   	push   %eax
  8002eb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002ee:	ff 75 e0             	pushl  -0x20(%ebp)
  8002f1:	e8 2a 0b 00 00       	call   800e20 <__udivdi3>
  8002f6:	83 c4 18             	add    $0x18,%esp
  8002f9:	52                   	push   %edx
  8002fa:	50                   	push   %eax
  8002fb:	89 f2                	mov    %esi,%edx
  8002fd:	89 f8                	mov    %edi,%eax
  8002ff:	e8 98 ff ff ff       	call   80029c <printnum>
		while (--width > 0)
			putch(padc, putdat);
	}
	}
	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800304:	83 c4 18             	add    $0x18,%esp
  800307:	56                   	push   %esi
  800308:	8b 45 10             	mov    0x10(%ebp),%eax
  80030b:	ba 00 00 00 00       	mov    $0x0,%edx
  800310:	83 ec 04             	sub    $0x4,%esp
  800313:	52                   	push   %edx
  800314:	50                   	push   %eax
  800315:	ff 75 e4             	pushl  -0x1c(%ebp)
  800318:	ff 75 e0             	pushl  -0x20(%ebp)
  80031b:	e8 30 0c 00 00       	call   800f50 <__umoddi3>
  800320:	83 c4 14             	add    $0x14,%esp
  800323:	0f be 80 03 11 80 00 	movsbl 0x801103(%eax),%eax
  80032a:	50                   	push   %eax
  80032b:	ff d7                	call   *%edi
	
	if(padc=='-'&&width>0)
  80032d:	83 c4 10             	add    $0x10,%esp
  800330:	83 7d 18 2d          	cmpl   $0x2d,0x18(%ebp)
  800334:	0f 85 fa 00 00 00    	jne    800434 <printnum+0x198>
  80033a:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
  80033e:	0f 8f 9b 00 00 00    	jg     8003df <printnum+0x143>
  800344:	e9 eb 00 00 00       	jmp    800434 <printnum+0x198>
	}
	else
	{
	
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800349:	8b 45 10             	mov    0x10(%ebp),%eax
  80034c:	ba 00 00 00 00       	mov    $0x0,%edx
  800351:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800354:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800357:	83 fb 00             	cmp    $0x0,%ebx
  80035a:	77 14                	ja     800370 <printnum+0xd4>
  80035c:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  80035f:	73 0f                	jae    800370 <printnum+0xd4>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800361:	8b 45 14             	mov    0x14(%ebp),%eax
  800364:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800367:	85 db                	test   %ebx,%ebx
  800369:	7f 61                	jg     8003cc <printnum+0x130>
  80036b:	e9 98 00 00 00       	jmp    800408 <printnum+0x16c>
	else
	{
	
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800370:	83 ec 0c             	sub    $0xc,%esp
  800373:	ff 75 18             	pushl  0x18(%ebp)
  800376:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800379:	8d 59 ff             	lea    -0x1(%ecx),%ebx
  80037c:	53                   	push   %ebx
  80037d:	ff 75 10             	pushl  0x10(%ebp)
  800380:	83 ec 08             	sub    $0x8,%esp
  800383:	52                   	push   %edx
  800384:	50                   	push   %eax
  800385:	ff 75 e4             	pushl  -0x1c(%ebp)
  800388:	ff 75 e0             	pushl  -0x20(%ebp)
  80038b:	e8 90 0a 00 00       	call   800e20 <__udivdi3>
  800390:	83 c4 18             	add    $0x18,%esp
  800393:	52                   	push   %edx
  800394:	50                   	push   %eax
  800395:	89 f2                	mov    %esi,%edx
  800397:	89 f8                	mov    %edi,%eax
  800399:	e8 fe fe ff ff       	call   80029c <printnum>
		while (--width > 0)
			putch(padc, putdat);
	}
	}
	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80039e:	83 c4 18             	add    $0x18,%esp
  8003a1:	56                   	push   %esi
  8003a2:	8b 45 10             	mov    0x10(%ebp),%eax
  8003a5:	ba 00 00 00 00       	mov    $0x0,%edx
  8003aa:	83 ec 04             	sub    $0x4,%esp
  8003ad:	52                   	push   %edx
  8003ae:	50                   	push   %eax
  8003af:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003b2:	ff 75 e0             	pushl  -0x20(%ebp)
  8003b5:	e8 96 0b 00 00       	call   800f50 <__umoddi3>
  8003ba:	83 c4 14             	add    $0x14,%esp
  8003bd:	0f be 80 03 11 80 00 	movsbl 0x801103(%eax),%eax
  8003c4:	50                   	push   %eax
  8003c5:	ff d7                	call   *%edi
  8003c7:	83 c4 10             	add    $0x10,%esp
  8003ca:	eb 68                	jmp    800434 <printnum+0x198>
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8003cc:	83 ec 08             	sub    $0x8,%esp
  8003cf:	56                   	push   %esi
  8003d0:	ff 75 18             	pushl  0x18(%ebp)
  8003d3:	ff d7                	call   *%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003d5:	83 c4 10             	add    $0x10,%esp
  8003d8:	83 eb 01             	sub    $0x1,%ebx
  8003db:	75 ef                	jne    8003cc <printnum+0x130>
  8003dd:	eb 29                	jmp    800408 <printnum+0x16c>
	putch("0123456789abcdef"[num % base], putdat);
	
	if(padc=='-'&&width>0)
	{
		length=*(int *)putdat-length;
		for(int i=0;i<width-length;++i)
  8003df:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e2:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  8003e5:	2b 06                	sub    (%esi),%eax
  8003e7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003ea:	85 c0                	test   %eax,%eax
  8003ec:	7e 46                	jle    800434 <printnum+0x198>
  8003ee:	bb 00 00 00 00       	mov    $0x0,%ebx
			putch(' ',putdat);
  8003f3:	83 ec 08             	sub    $0x8,%esp
  8003f6:	56                   	push   %esi
  8003f7:	6a 20                	push   $0x20
  8003f9:	ff d7                	call   *%edi
	putch("0123456789abcdef"[num % base], putdat);
	
	if(padc=='-'&&width>0)
	{
		length=*(int *)putdat-length;
		for(int i=0;i<width-length;++i)
  8003fb:	83 c3 01             	add    $0x1,%ebx
  8003fe:	83 c4 10             	add    $0x10,%esp
  800401:	3b 5d e0             	cmp    -0x20(%ebp),%ebx
  800404:	75 ed                	jne    8003f3 <printnum+0x157>
  800406:	eb 2c                	jmp    800434 <printnum+0x198>
		while (--width > 0)
			putch(padc, putdat);
	}
	}
	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800408:	83 ec 08             	sub    $0x8,%esp
  80040b:	56                   	push   %esi
  80040c:	8b 45 10             	mov    0x10(%ebp),%eax
  80040f:	ba 00 00 00 00       	mov    $0x0,%edx
  800414:	83 ec 04             	sub    $0x4,%esp
  800417:	52                   	push   %edx
  800418:	50                   	push   %eax
  800419:	ff 75 e4             	pushl  -0x1c(%ebp)
  80041c:	ff 75 e0             	pushl  -0x20(%ebp)
  80041f:	e8 2c 0b 00 00       	call   800f50 <__umoddi3>
  800424:	83 c4 14             	add    $0x14,%esp
  800427:	0f be 80 03 11 80 00 	movsbl 0x801103(%eax),%eax
  80042e:	50                   	push   %eax
  80042f:	ff d7                	call   *%edi
  800431:	83 c4 10             	add    $0x10,%esp
	{
		length=*(int *)putdat-length;
		for(int i=0;i<width-length;++i)
			putch(' ',putdat);
	}
}
  800434:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800437:	5b                   	pop    %ebx
  800438:	5e                   	pop    %esi
  800439:	5f                   	pop    %edi
  80043a:	5d                   	pop    %ebp
  80043b:	c3                   	ret    

0080043c <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80043c:	55                   	push   %ebp
  80043d:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80043f:	83 fa 01             	cmp    $0x1,%edx
  800442:	7e 0e                	jle    800452 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800444:	8b 10                	mov    (%eax),%edx
  800446:	8d 4a 08             	lea    0x8(%edx),%ecx
  800449:	89 08                	mov    %ecx,(%eax)
  80044b:	8b 02                	mov    (%edx),%eax
  80044d:	8b 52 04             	mov    0x4(%edx),%edx
  800450:	eb 22                	jmp    800474 <getuint+0x38>
	else if (lflag)
  800452:	85 d2                	test   %edx,%edx
  800454:	74 10                	je     800466 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800456:	8b 10                	mov    (%eax),%edx
  800458:	8d 4a 04             	lea    0x4(%edx),%ecx
  80045b:	89 08                	mov    %ecx,(%eax)
  80045d:	8b 02                	mov    (%edx),%eax
  80045f:	ba 00 00 00 00       	mov    $0x0,%edx
  800464:	eb 0e                	jmp    800474 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800466:	8b 10                	mov    (%eax),%edx
  800468:	8d 4a 04             	lea    0x4(%edx),%ecx
  80046b:	89 08                	mov    %ecx,(%eax)
  80046d:	8b 02                	mov    (%edx),%eax
  80046f:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800474:	5d                   	pop    %ebp
  800475:	c3                   	ret    

00800476 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800476:	55                   	push   %ebp
  800477:	89 e5                	mov    %esp,%ebp
  800479:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80047c:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800480:	8b 10                	mov    (%eax),%edx
  800482:	3b 50 04             	cmp    0x4(%eax),%edx
  800485:	73 0a                	jae    800491 <sprintputch+0x1b>
		*b->buf++ = ch;
  800487:	8d 4a 01             	lea    0x1(%edx),%ecx
  80048a:	89 08                	mov    %ecx,(%eax)
  80048c:	8b 45 08             	mov    0x8(%ebp),%eax
  80048f:	88 02                	mov    %al,(%edx)
}
  800491:	5d                   	pop    %ebp
  800492:	c3                   	ret    

00800493 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800493:	55                   	push   %ebp
  800494:	89 e5                	mov    %esp,%ebp
  800496:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800499:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80049c:	50                   	push   %eax
  80049d:	ff 75 10             	pushl  0x10(%ebp)
  8004a0:	ff 75 0c             	pushl  0xc(%ebp)
  8004a3:	ff 75 08             	pushl  0x8(%ebp)
  8004a6:	e8 05 00 00 00       	call   8004b0 <vprintfmt>
	va_end(ap);
}
  8004ab:	83 c4 10             	add    $0x10,%esp
  8004ae:	c9                   	leave  
  8004af:	c3                   	ret    

008004b0 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8004b0:	55                   	push   %ebp
  8004b1:	89 e5                	mov    %esp,%ebp
  8004b3:	57                   	push   %edi
  8004b4:	56                   	push   %esi
  8004b5:	53                   	push   %ebx
  8004b6:	83 ec 2c             	sub    $0x2c,%esp
  8004b9:	8b 7d 08             	mov    0x8(%ebp),%edi
  8004bc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004bf:	eb 03                	jmp    8004c4 <vprintfmt+0x14>
			break;
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
			for (fmt--; fmt[-1] != '%'; fmt--)
  8004c1:	89 75 10             	mov    %esi,0x10(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8004c4:	8b 45 10             	mov    0x10(%ebp),%eax
  8004c7:	8d 70 01             	lea    0x1(%eax),%esi
  8004ca:	0f b6 00             	movzbl (%eax),%eax
  8004cd:	83 f8 25             	cmp    $0x25,%eax
  8004d0:	74 27                	je     8004f9 <vprintfmt+0x49>
			if (ch == '\0')
  8004d2:	85 c0                	test   %eax,%eax
  8004d4:	75 0d                	jne    8004e3 <vprintfmt+0x33>
  8004d6:	e9 8b 04 00 00       	jmp    800966 <vprintfmt+0x4b6>
  8004db:	85 c0                	test   %eax,%eax
  8004dd:	0f 84 83 04 00 00    	je     800966 <vprintfmt+0x4b6>
				return;
			putch(ch, putdat);
  8004e3:	83 ec 08             	sub    $0x8,%esp
  8004e6:	53                   	push   %ebx
  8004e7:	50                   	push   %eax
  8004e8:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8004ea:	83 c6 01             	add    $0x1,%esi
  8004ed:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  8004f1:	83 c4 10             	add    $0x10,%esp
  8004f4:	83 f8 25             	cmp    $0x25,%eax
  8004f7:	75 e2                	jne    8004db <vprintfmt+0x2b>
			padc = '-';
			goto reswitch;
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004f9:	c6 45 e3 20          	movb   $0x20,-0x1d(%ebp)
  8004fd:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800504:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80050b:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800512:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  800519:	b9 00 00 00 00       	mov    $0x0,%ecx
  80051e:	eb 07                	jmp    800527 <vprintfmt+0x77>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800520:	8b 75 10             	mov    0x10(%ebp),%esi

		// flag to show the sign
		case '+':
			padc='+';
  800523:	c6 45 e3 2b          	movb   $0x2b,-0x1d(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800527:	8d 46 01             	lea    0x1(%esi),%eax
  80052a:	89 45 10             	mov    %eax,0x10(%ebp)
  80052d:	0f b6 06             	movzbl (%esi),%eax
  800530:	0f b6 d0             	movzbl %al,%edx
  800533:	83 e8 23             	sub    $0x23,%eax
  800536:	3c 55                	cmp    $0x55,%al
  800538:	0f 87 e9 03 00 00    	ja     800927 <vprintfmt+0x477>
  80053e:	0f b6 c0             	movzbl %al,%eax
  800541:	ff 24 85 0c 12 80 00 	jmp    *0x80120c(,%eax,4)
  800548:	8b 75 10             	mov    0x10(%ebp),%esi
			padc='+';
			goto reswitch;
		
		// flag to pad on the right
		case '-':
			padc = '-';
  80054b:	c6 45 e3 2d          	movb   $0x2d,-0x1d(%ebp)
  80054f:	eb d6                	jmp    800527 <vprintfmt+0x77>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800551:	8d 42 d0             	lea    -0x30(%edx),%eax
  800554:	89 45 d0             	mov    %eax,-0x30(%ebp)
				ch = *fmt;
  800557:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  80055b:	8d 50 d0             	lea    -0x30(%eax),%edx
  80055e:	83 fa 09             	cmp    $0x9,%edx
  800561:	77 66                	ja     8005c9 <vprintfmt+0x119>
  800563:	8b 75 10             	mov    0x10(%ebp),%esi
  800566:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800569:	89 7d 08             	mov    %edi,0x8(%ebp)
  80056c:	eb 09                	jmp    800577 <vprintfmt+0xc7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80056e:	8b 75 10             	mov    0x10(%ebp),%esi
			padc = '-';
			goto reswitch;
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800571:	c6 45 e3 30          	movb   $0x30,-0x1d(%ebp)
			goto reswitch;
  800575:	eb b0                	jmp    800527 <vprintfmt+0x77>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800577:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  80057a:	8d 14 92             	lea    (%edx,%edx,4),%edx
  80057d:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  800581:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800584:	8d 78 d0             	lea    -0x30(%eax),%edi
  800587:	83 ff 09             	cmp    $0x9,%edi
  80058a:	76 eb                	jbe    800577 <vprintfmt+0xc7>
  80058c:	89 55 d0             	mov    %edx,-0x30(%ebp)
  80058f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800592:	eb 38                	jmp    8005cc <vprintfmt+0x11c>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800594:	8b 45 14             	mov    0x14(%ebp),%eax
  800597:	8d 50 04             	lea    0x4(%eax),%edx
  80059a:	89 55 14             	mov    %edx,0x14(%ebp)
  80059d:	8b 00                	mov    (%eax),%eax
  80059f:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a2:	8b 75 10             	mov    0x10(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005a5:	eb 25                	jmp    8005cc <vprintfmt+0x11c>
  8005a7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005aa:	85 c0                	test   %eax,%eax
  8005ac:	0f 48 c1             	cmovs  %ecx,%eax
  8005af:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005b2:	8b 75 10             	mov    0x10(%ebp),%esi
  8005b5:	e9 6d ff ff ff       	jmp    800527 <vprintfmt+0x77>
  8005ba:	8b 75 10             	mov    0x10(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8005bd:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8005c4:	e9 5e ff ff ff       	jmp    800527 <vprintfmt+0x77>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005c9:	8b 75 10             	mov    0x10(%ebp),%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8005cc:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005d0:	0f 89 51 ff ff ff    	jns    800527 <vprintfmt+0x77>
				width = precision, precision = -1;
  8005d6:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8005d9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8005dc:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8005e3:	e9 3f ff ff ff       	jmp    800527 <vprintfmt+0x77>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8005e8:	83 45 cc 01          	addl   $0x1,-0x34(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ec:	8b 75 10             	mov    0x10(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8005ef:	e9 33 ff ff ff       	jmp    800527 <vprintfmt+0x77>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8005f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f7:	8d 50 04             	lea    0x4(%eax),%edx
  8005fa:	89 55 14             	mov    %edx,0x14(%ebp)
  8005fd:	83 ec 08             	sub    $0x8,%esp
  800600:	53                   	push   %ebx
  800601:	ff 30                	pushl  (%eax)
  800603:	ff d7                	call   *%edi
			break;
  800605:	83 c4 10             	add    $0x10,%esp
  800608:	e9 b7 fe ff ff       	jmp    8004c4 <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80060d:	8b 45 14             	mov    0x14(%ebp),%eax
  800610:	8d 50 04             	lea    0x4(%eax),%edx
  800613:	89 55 14             	mov    %edx,0x14(%ebp)
  800616:	8b 00                	mov    (%eax),%eax
  800618:	99                   	cltd   
  800619:	31 d0                	xor    %edx,%eax
  80061b:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80061d:	83 f8 06             	cmp    $0x6,%eax
  800620:	7f 0b                	jg     80062d <vprintfmt+0x17d>
  800622:	8b 14 85 64 13 80 00 	mov    0x801364(,%eax,4),%edx
  800629:	85 d2                	test   %edx,%edx
  80062b:	75 15                	jne    800642 <vprintfmt+0x192>
				printfmt(putch, putdat, "error %d", err);
  80062d:	50                   	push   %eax
  80062e:	68 1b 11 80 00       	push   $0x80111b
  800633:	53                   	push   %ebx
  800634:	57                   	push   %edi
  800635:	e8 59 fe ff ff       	call   800493 <printfmt>
  80063a:	83 c4 10             	add    $0x10,%esp
  80063d:	e9 82 fe ff ff       	jmp    8004c4 <vprintfmt+0x14>
			else
				printfmt(putch, putdat, "%s", p);
  800642:	52                   	push   %edx
  800643:	68 24 11 80 00       	push   $0x801124
  800648:	53                   	push   %ebx
  800649:	57                   	push   %edi
  80064a:	e8 44 fe ff ff       	call   800493 <printfmt>
  80064f:	83 c4 10             	add    $0x10,%esp
  800652:	e9 6d fe ff ff       	jmp    8004c4 <vprintfmt+0x14>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800657:	8b 45 14             	mov    0x14(%ebp),%eax
  80065a:	8d 50 04             	lea    0x4(%eax),%edx
  80065d:	89 55 14             	mov    %edx,0x14(%ebp)
  800660:	8b 00                	mov    (%eax),%eax
				p = "(null)";
  800662:	85 c0                	test   %eax,%eax
  800664:	b9 14 11 80 00       	mov    $0x801114,%ecx
  800669:	0f 45 c8             	cmovne %eax,%ecx
  80066c:	89 4d cc             	mov    %ecx,-0x34(%ebp)
			if (width > 0 && padc != '-')
  80066f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800673:	7e 06                	jle    80067b <vprintfmt+0x1cb>
  800675:	80 7d e3 2d          	cmpb   $0x2d,-0x1d(%ebp)
  800679:	75 19                	jne    800694 <vprintfmt+0x1e4>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80067b:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80067e:	8d 70 01             	lea    0x1(%eax),%esi
  800681:	0f b6 00             	movzbl (%eax),%eax
  800684:	0f be d0             	movsbl %al,%edx
  800687:	85 d2                	test   %edx,%edx
  800689:	0f 85 9f 00 00 00    	jne    80072e <vprintfmt+0x27e>
  80068f:	e9 8c 00 00 00       	jmp    800720 <vprintfmt+0x270>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800694:	83 ec 08             	sub    $0x8,%esp
  800697:	ff 75 d0             	pushl  -0x30(%ebp)
  80069a:	ff 75 cc             	pushl  -0x34(%ebp)
  80069d:	e8 56 03 00 00       	call   8009f8 <strnlen>
  8006a2:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  8006a5:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8006a8:	83 c4 10             	add    $0x10,%esp
  8006ab:	85 c9                	test   %ecx,%ecx
  8006ad:	0f 8e 9a 02 00 00    	jle    80094d <vprintfmt+0x49d>
					putch(padc, putdat);
  8006b3:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  8006b7:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006ba:	89 cb                	mov    %ecx,%ebx
  8006bc:	83 ec 08             	sub    $0x8,%esp
  8006bf:	ff 75 0c             	pushl  0xc(%ebp)
  8006c2:	56                   	push   %esi
  8006c3:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006c5:	83 c4 10             	add    $0x10,%esp
  8006c8:	83 eb 01             	sub    $0x1,%ebx
  8006cb:	75 ef                	jne    8006bc <vprintfmt+0x20c>
  8006cd:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8006d0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006d3:	e9 75 02 00 00       	jmp    80094d <vprintfmt+0x49d>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8006d8:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8006dc:	74 1b                	je     8006f9 <vprintfmt+0x249>
  8006de:	0f be c0             	movsbl %al,%eax
  8006e1:	83 e8 20             	sub    $0x20,%eax
  8006e4:	83 f8 5e             	cmp    $0x5e,%eax
  8006e7:	76 10                	jbe    8006f9 <vprintfmt+0x249>
					putch('?', putdat);
  8006e9:	83 ec 08             	sub    $0x8,%esp
  8006ec:	ff 75 0c             	pushl  0xc(%ebp)
  8006ef:	6a 3f                	push   $0x3f
  8006f1:	ff 55 08             	call   *0x8(%ebp)
  8006f4:	83 c4 10             	add    $0x10,%esp
  8006f7:	eb 0d                	jmp    800706 <vprintfmt+0x256>
				else
					putch(ch, putdat);
  8006f9:	83 ec 08             	sub    $0x8,%esp
  8006fc:	ff 75 0c             	pushl  0xc(%ebp)
  8006ff:	52                   	push   %edx
  800700:	ff 55 08             	call   *0x8(%ebp)
  800703:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800706:	83 ef 01             	sub    $0x1,%edi
  800709:	83 c6 01             	add    $0x1,%esi
  80070c:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  800710:	0f be d0             	movsbl %al,%edx
  800713:	85 d2                	test   %edx,%edx
  800715:	75 31                	jne    800748 <vprintfmt+0x298>
  800717:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  80071a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80071d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800720:	8b 75 e4             	mov    -0x1c(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800723:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800727:	7f 33                	jg     80075c <vprintfmt+0x2ac>
  800729:	e9 96 fd ff ff       	jmp    8004c4 <vprintfmt+0x14>
  80072e:	89 7d 08             	mov    %edi,0x8(%ebp)
  800731:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800734:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800737:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80073a:	eb 0c                	jmp    800748 <vprintfmt+0x298>
  80073c:	89 7d 08             	mov    %edi,0x8(%ebp)
  80073f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800742:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800745:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800748:	85 db                	test   %ebx,%ebx
  80074a:	78 8c                	js     8006d8 <vprintfmt+0x228>
  80074c:	83 eb 01             	sub    $0x1,%ebx
  80074f:	79 87                	jns    8006d8 <vprintfmt+0x228>
  800751:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800754:	8b 7d 08             	mov    0x8(%ebp),%edi
  800757:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80075a:	eb c4                	jmp    800720 <vprintfmt+0x270>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80075c:	83 ec 08             	sub    $0x8,%esp
  80075f:	53                   	push   %ebx
  800760:	6a 20                	push   $0x20
  800762:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800764:	83 c4 10             	add    $0x10,%esp
  800767:	83 ee 01             	sub    $0x1,%esi
  80076a:	75 f0                	jne    80075c <vprintfmt+0x2ac>
  80076c:	e9 53 fd ff ff       	jmp    8004c4 <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800771:	83 7d cc 01          	cmpl   $0x1,-0x34(%ebp)
  800775:	7e 16                	jle    80078d <vprintfmt+0x2dd>
		return va_arg(*ap, long long);
  800777:	8b 45 14             	mov    0x14(%ebp),%eax
  80077a:	8d 50 08             	lea    0x8(%eax),%edx
  80077d:	89 55 14             	mov    %edx,0x14(%ebp)
  800780:	8b 50 04             	mov    0x4(%eax),%edx
  800783:	8b 00                	mov    (%eax),%eax
  800785:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800788:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80078b:	eb 34                	jmp    8007c1 <vprintfmt+0x311>
	else if (lflag)
  80078d:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800791:	74 18                	je     8007ab <vprintfmt+0x2fb>
		return va_arg(*ap, long);
  800793:	8b 45 14             	mov    0x14(%ebp),%eax
  800796:	8d 50 04             	lea    0x4(%eax),%edx
  800799:	89 55 14             	mov    %edx,0x14(%ebp)
  80079c:	8b 30                	mov    (%eax),%esi
  80079e:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8007a1:	89 f0                	mov    %esi,%eax
  8007a3:	c1 f8 1f             	sar    $0x1f,%eax
  8007a6:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8007a9:	eb 16                	jmp    8007c1 <vprintfmt+0x311>
	else
		return va_arg(*ap, int);
  8007ab:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ae:	8d 50 04             	lea    0x4(%eax),%edx
  8007b1:	89 55 14             	mov    %edx,0x14(%ebp)
  8007b4:	8b 30                	mov    (%eax),%esi
  8007b6:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8007b9:	89 f0                	mov    %esi,%eax
  8007bb:	c1 f8 1f             	sar    $0x1f,%eax
  8007be:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8007c1:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8007c4:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8007c7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007ca:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  8007cd:	85 d2                	test   %edx,%edx
  8007cf:	79 28                	jns    8007f9 <vprintfmt+0x349>
				putch('-', putdat);
  8007d1:	83 ec 08             	sub    $0x8,%esp
  8007d4:	53                   	push   %ebx
  8007d5:	6a 2d                	push   $0x2d
  8007d7:	ff d7                	call   *%edi
				num = -(long long) num;
  8007d9:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8007dc:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8007df:	f7 d8                	neg    %eax
  8007e1:	83 d2 00             	adc    $0x0,%edx
  8007e4:	f7 da                	neg    %edx
  8007e6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007e9:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007ec:	83 c4 10             	add    $0x10,%esp
			else
			{
				if(padc=='+')
					putch('+', putdat);
			}
			base = 10;
  8007ef:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007f4:	e9 a5 00 00 00       	jmp    80089e <vprintfmt+0x3ee>
  8007f9:	b8 0a 00 00 00       	mov    $0xa,%eax
				putch('-', putdat);
				num = -(long long) num;
			}
			else
			{
				if(padc=='+')
  8007fe:	80 7d e3 2b          	cmpb   $0x2b,-0x1d(%ebp)
  800802:	0f 85 96 00 00 00    	jne    80089e <vprintfmt+0x3ee>
					putch('+', putdat);
  800808:	83 ec 08             	sub    $0x8,%esp
  80080b:	53                   	push   %ebx
  80080c:	6a 2b                	push   $0x2b
  80080e:	ff d7                	call   *%edi
  800810:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800813:	b8 0a 00 00 00       	mov    $0xa,%eax
  800818:	e9 81 00 00 00       	jmp    80089e <vprintfmt+0x3ee>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80081d:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800820:	8d 45 14             	lea    0x14(%ebp),%eax
  800823:	e8 14 fc ff ff       	call   80043c <getuint>
  800828:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80082b:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  80082e:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800833:	eb 69                	jmp    80089e <vprintfmt+0x3ee>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			putch('0', putdat);
  800835:	83 ec 08             	sub    $0x8,%esp
  800838:	53                   	push   %ebx
  800839:	6a 30                	push   $0x30
  80083b:	ff d7                	call   *%edi
			num = getuint(&ap, lflag);
  80083d:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800840:	8d 45 14             	lea    0x14(%ebp),%eax
  800843:	e8 f4 fb ff ff       	call   80043c <getuint>
  800848:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80084b:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
			goto number;
  80084e:	83 c4 10             	add    $0x10,%esp
		case 'o':
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
  800851:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800856:	eb 46                	jmp    80089e <vprintfmt+0x3ee>

		// pointer
		case 'p':
			putch('0', putdat);
  800858:	83 ec 08             	sub    $0x8,%esp
  80085b:	53                   	push   %ebx
  80085c:	6a 30                	push   $0x30
  80085e:	ff d7                	call   *%edi
			putch('x', putdat);
  800860:	83 c4 08             	add    $0x8,%esp
  800863:	53                   	push   %ebx
  800864:	6a 78                	push   $0x78
  800866:	ff d7                	call   *%edi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800868:	8b 45 14             	mov    0x14(%ebp),%eax
  80086b:	8d 50 04             	lea    0x4(%eax),%edx
  80086e:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800871:	8b 00                	mov    (%eax),%eax
  800873:	ba 00 00 00 00       	mov    $0x0,%edx
  800878:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80087b:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80087e:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800881:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800886:	eb 16                	jmp    80089e <vprintfmt+0x3ee>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800888:	8b 55 cc             	mov    -0x34(%ebp),%edx
  80088b:	8d 45 14             	lea    0x14(%ebp),%eax
  80088e:	e8 a9 fb ff ff       	call   80043c <getuint>
  800893:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800896:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  800899:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  80089e:	83 ec 0c             	sub    $0xc,%esp
  8008a1:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  8008a5:	56                   	push   %esi
  8008a6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8008a9:	50                   	push   %eax
  8008aa:	ff 75 dc             	pushl  -0x24(%ebp)
  8008ad:	ff 75 d8             	pushl  -0x28(%ebp)
  8008b0:	89 da                	mov    %ebx,%edx
  8008b2:	89 f8                	mov    %edi,%eax
  8008b4:	e8 e3 f9 ff ff       	call   80029c <printnum>
			break;
  8008b9:	83 c4 20             	add    $0x20,%esp
  8008bc:	e9 03 fc ff ff       	jmp    8004c4 <vprintfmt+0x14>

            const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
            const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

            // Your code here
			num=(unsigned long long)(uintptr_t)va_arg(ap, void *);
  8008c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8008c4:	8d 50 04             	lea    0x4(%eax),%edx
  8008c7:	89 55 14             	mov    %edx,0x14(%ebp)
  8008ca:	8b 00                	mov    (%eax),%eax
			if(!num)
  8008cc:	85 c0                	test   %eax,%eax
  8008ce:	75 1c                	jne    8008ec <vprintfmt+0x43c>
				*(int *)putdat+=cprintf("%s",null_error);
  8008d0:	83 ec 08             	sub    $0x8,%esp
  8008d3:	68 90 11 80 00       	push   $0x801190
  8008d8:	68 24 11 80 00       	push   $0x801124
  8008dd:	e8 a6 f9 ff ff       	call   800288 <cprintf>
  8008e2:	01 03                	add    %eax,(%ebx)
  8008e4:	83 c4 10             	add    $0x10,%esp
  8008e7:	e9 d8 fb ff ff       	jmp    8004c4 <vprintfmt+0x14>
			else
			{
				*(char *)(int)num=*(int *)putdat;
  8008ec:	8b 13                	mov    (%ebx),%edx
  8008ee:	88 10                	mov    %dl,(%eax)
				if((*(int *)putdat)>128)
  8008f0:	81 3b 80 00 00 00    	cmpl   $0x80,(%ebx)
  8008f6:	0f 8e c8 fb ff ff    	jle    8004c4 <vprintfmt+0x14>
					*(int *)putdat+=cprintf("%s",overflow_error);
  8008fc:	83 ec 08             	sub    $0x8,%esp
  8008ff:	68 c8 11 80 00       	push   $0x8011c8
  800904:	68 24 11 80 00       	push   $0x801124
  800909:	e8 7a f9 ff ff       	call   800288 <cprintf>
  80090e:	01 03                	add    %eax,(%ebx)
  800910:	83 c4 10             	add    $0x10,%esp
  800913:	e9 ac fb ff ff       	jmp    8004c4 <vprintfmt+0x14>
            break;
        }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800918:	83 ec 08             	sub    $0x8,%esp
  80091b:	53                   	push   %ebx
  80091c:	52                   	push   %edx
  80091d:	ff d7                	call   *%edi
			break;
  80091f:	83 c4 10             	add    $0x10,%esp
  800922:	e9 9d fb ff ff       	jmp    8004c4 <vprintfmt+0x14>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800927:	83 ec 08             	sub    $0x8,%esp
  80092a:	53                   	push   %ebx
  80092b:	6a 25                	push   $0x25
  80092d:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80092f:	83 c4 10             	add    $0x10,%esp
  800932:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800936:	0f 84 85 fb ff ff    	je     8004c1 <vprintfmt+0x11>
  80093c:	83 ee 01             	sub    $0x1,%esi
  80093f:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800943:	75 f7                	jne    80093c <vprintfmt+0x48c>
  800945:	89 75 10             	mov    %esi,0x10(%ebp)
  800948:	e9 77 fb ff ff       	jmp    8004c4 <vprintfmt+0x14>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80094d:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800950:	8d 70 01             	lea    0x1(%eax),%esi
  800953:	0f b6 00             	movzbl (%eax),%eax
  800956:	0f be d0             	movsbl %al,%edx
  800959:	85 d2                	test   %edx,%edx
  80095b:	0f 85 db fd ff ff    	jne    80073c <vprintfmt+0x28c>
  800961:	e9 5e fb ff ff       	jmp    8004c4 <vprintfmt+0x14>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800966:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800969:	5b                   	pop    %ebx
  80096a:	5e                   	pop    %esi
  80096b:	5f                   	pop    %edi
  80096c:	5d                   	pop    %ebp
  80096d:	c3                   	ret    

0080096e <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80096e:	55                   	push   %ebp
  80096f:	89 e5                	mov    %esp,%ebp
  800971:	83 ec 18             	sub    $0x18,%esp
  800974:	8b 45 08             	mov    0x8(%ebp),%eax
  800977:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80097a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80097d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800981:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800984:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80098b:	85 c0                	test   %eax,%eax
  80098d:	74 26                	je     8009b5 <vsnprintf+0x47>
  80098f:	85 d2                	test   %edx,%edx
  800991:	7e 22                	jle    8009b5 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800993:	ff 75 14             	pushl  0x14(%ebp)
  800996:	ff 75 10             	pushl  0x10(%ebp)
  800999:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80099c:	50                   	push   %eax
  80099d:	68 76 04 80 00       	push   $0x800476
  8009a2:	e8 09 fb ff ff       	call   8004b0 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8009a7:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8009aa:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8009ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009b0:	83 c4 10             	add    $0x10,%esp
  8009b3:	eb 05                	jmp    8009ba <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8009b5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8009ba:	c9                   	leave  
  8009bb:	c3                   	ret    

008009bc <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8009bc:	55                   	push   %ebp
  8009bd:	89 e5                	mov    %esp,%ebp
  8009bf:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8009c2:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8009c5:	50                   	push   %eax
  8009c6:	ff 75 10             	pushl  0x10(%ebp)
  8009c9:	ff 75 0c             	pushl  0xc(%ebp)
  8009cc:	ff 75 08             	pushl  0x8(%ebp)
  8009cf:	e8 9a ff ff ff       	call   80096e <vsnprintf>
	va_end(ap);

	return rc;
}
  8009d4:	c9                   	leave  
  8009d5:	c3                   	ret    

008009d6 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8009d6:	55                   	push   %ebp
  8009d7:	89 e5                	mov    %esp,%ebp
  8009d9:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8009dc:	80 3a 00             	cmpb   $0x0,(%edx)
  8009df:	74 10                	je     8009f1 <strlen+0x1b>
  8009e1:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8009e6:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8009e9:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8009ed:	75 f7                	jne    8009e6 <strlen+0x10>
  8009ef:	eb 05                	jmp    8009f6 <strlen+0x20>
  8009f1:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8009f6:	5d                   	pop    %ebp
  8009f7:	c3                   	ret    

008009f8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8009f8:	55                   	push   %ebp
  8009f9:	89 e5                	mov    %esp,%ebp
  8009fb:	53                   	push   %ebx
  8009fc:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8009ff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a02:	85 c9                	test   %ecx,%ecx
  800a04:	74 1c                	je     800a22 <strnlen+0x2a>
  800a06:	80 3b 00             	cmpb   $0x0,(%ebx)
  800a09:	74 1e                	je     800a29 <strnlen+0x31>
  800a0b:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  800a10:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a12:	39 ca                	cmp    %ecx,%edx
  800a14:	74 18                	je     800a2e <strnlen+0x36>
  800a16:	83 c2 01             	add    $0x1,%edx
  800a19:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800a1e:	75 f0                	jne    800a10 <strnlen+0x18>
  800a20:	eb 0c                	jmp    800a2e <strnlen+0x36>
  800a22:	b8 00 00 00 00       	mov    $0x0,%eax
  800a27:	eb 05                	jmp    800a2e <strnlen+0x36>
  800a29:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800a2e:	5b                   	pop    %ebx
  800a2f:	5d                   	pop    %ebp
  800a30:	c3                   	ret    

00800a31 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a31:	55                   	push   %ebp
  800a32:	89 e5                	mov    %esp,%ebp
  800a34:	53                   	push   %ebx
  800a35:	8b 45 08             	mov    0x8(%ebp),%eax
  800a38:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a3b:	89 c2                	mov    %eax,%edx
  800a3d:	83 c2 01             	add    $0x1,%edx
  800a40:	83 c1 01             	add    $0x1,%ecx
  800a43:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800a47:	88 5a ff             	mov    %bl,-0x1(%edx)
  800a4a:	84 db                	test   %bl,%bl
  800a4c:	75 ef                	jne    800a3d <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800a4e:	5b                   	pop    %ebx
  800a4f:	5d                   	pop    %ebp
  800a50:	c3                   	ret    

00800a51 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a51:	55                   	push   %ebp
  800a52:	89 e5                	mov    %esp,%ebp
  800a54:	53                   	push   %ebx
  800a55:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a58:	53                   	push   %ebx
  800a59:	e8 78 ff ff ff       	call   8009d6 <strlen>
  800a5e:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800a61:	ff 75 0c             	pushl  0xc(%ebp)
  800a64:	01 d8                	add    %ebx,%eax
  800a66:	50                   	push   %eax
  800a67:	e8 c5 ff ff ff       	call   800a31 <strcpy>
	return dst;
}
  800a6c:	89 d8                	mov    %ebx,%eax
  800a6e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a71:	c9                   	leave  
  800a72:	c3                   	ret    

00800a73 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a73:	55                   	push   %ebp
  800a74:	89 e5                	mov    %esp,%ebp
  800a76:	56                   	push   %esi
  800a77:	53                   	push   %ebx
  800a78:	8b 75 08             	mov    0x8(%ebp),%esi
  800a7b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a7e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a81:	85 db                	test   %ebx,%ebx
  800a83:	74 17                	je     800a9c <strncpy+0x29>
  800a85:	01 f3                	add    %esi,%ebx
  800a87:	89 f1                	mov    %esi,%ecx
		*dst++ = *src;
  800a89:	83 c1 01             	add    $0x1,%ecx
  800a8c:	0f b6 02             	movzbl (%edx),%eax
  800a8f:	88 41 ff             	mov    %al,-0x1(%ecx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a92:	80 3a 01             	cmpb   $0x1,(%edx)
  800a95:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a98:	39 cb                	cmp    %ecx,%ebx
  800a9a:	75 ed                	jne    800a89 <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a9c:	89 f0                	mov    %esi,%eax
  800a9e:	5b                   	pop    %ebx
  800a9f:	5e                   	pop    %esi
  800aa0:	5d                   	pop    %ebp
  800aa1:	c3                   	ret    

00800aa2 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800aa2:	55                   	push   %ebp
  800aa3:	89 e5                	mov    %esp,%ebp
  800aa5:	56                   	push   %esi
  800aa6:	53                   	push   %ebx
  800aa7:	8b 75 08             	mov    0x8(%ebp),%esi
  800aaa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800aad:	8b 55 10             	mov    0x10(%ebp),%edx
  800ab0:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800ab2:	85 d2                	test   %edx,%edx
  800ab4:	74 35                	je     800aeb <strlcpy+0x49>
		while (--size > 0 && *src != '\0')
  800ab6:	89 d0                	mov    %edx,%eax
  800ab8:	83 e8 01             	sub    $0x1,%eax
  800abb:	74 25                	je     800ae2 <strlcpy+0x40>
  800abd:	0f b6 0b             	movzbl (%ebx),%ecx
  800ac0:	84 c9                	test   %cl,%cl
  800ac2:	74 22                	je     800ae6 <strlcpy+0x44>
  800ac4:	8d 53 01             	lea    0x1(%ebx),%edx
  800ac7:	01 c3                	add    %eax,%ebx
  800ac9:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
  800acb:	83 c0 01             	add    $0x1,%eax
  800ace:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800ad1:	39 da                	cmp    %ebx,%edx
  800ad3:	74 13                	je     800ae8 <strlcpy+0x46>
  800ad5:	83 c2 01             	add    $0x1,%edx
  800ad8:	0f b6 4a ff          	movzbl -0x1(%edx),%ecx
  800adc:	84 c9                	test   %cl,%cl
  800ade:	75 eb                	jne    800acb <strlcpy+0x29>
  800ae0:	eb 06                	jmp    800ae8 <strlcpy+0x46>
  800ae2:	89 f0                	mov    %esi,%eax
  800ae4:	eb 02                	jmp    800ae8 <strlcpy+0x46>
  800ae6:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800ae8:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800aeb:	29 f0                	sub    %esi,%eax
}
  800aed:	5b                   	pop    %ebx
  800aee:	5e                   	pop    %esi
  800aef:	5d                   	pop    %ebp
  800af0:	c3                   	ret    

00800af1 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800af1:	55                   	push   %ebp
  800af2:	89 e5                	mov    %esp,%ebp
  800af4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800af7:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800afa:	0f b6 01             	movzbl (%ecx),%eax
  800afd:	84 c0                	test   %al,%al
  800aff:	74 15                	je     800b16 <strcmp+0x25>
  800b01:	3a 02                	cmp    (%edx),%al
  800b03:	75 11                	jne    800b16 <strcmp+0x25>
		p++, q++;
  800b05:	83 c1 01             	add    $0x1,%ecx
  800b08:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800b0b:	0f b6 01             	movzbl (%ecx),%eax
  800b0e:	84 c0                	test   %al,%al
  800b10:	74 04                	je     800b16 <strcmp+0x25>
  800b12:	3a 02                	cmp    (%edx),%al
  800b14:	74 ef                	je     800b05 <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800b16:	0f b6 c0             	movzbl %al,%eax
  800b19:	0f b6 12             	movzbl (%edx),%edx
  800b1c:	29 d0                	sub    %edx,%eax
}
  800b1e:	5d                   	pop    %ebp
  800b1f:	c3                   	ret    

00800b20 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b20:	55                   	push   %ebp
  800b21:	89 e5                	mov    %esp,%ebp
  800b23:	56                   	push   %esi
  800b24:	53                   	push   %ebx
  800b25:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800b28:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b2b:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  800b2e:	85 f6                	test   %esi,%esi
  800b30:	74 29                	je     800b5b <strncmp+0x3b>
  800b32:	0f b6 03             	movzbl (%ebx),%eax
  800b35:	84 c0                	test   %al,%al
  800b37:	74 30                	je     800b69 <strncmp+0x49>
  800b39:	3a 02                	cmp    (%edx),%al
  800b3b:	75 2c                	jne    800b69 <strncmp+0x49>
  800b3d:	8d 43 01             	lea    0x1(%ebx),%eax
  800b40:	01 de                	add    %ebx,%esi
		n--, p++, q++;
  800b42:	89 c3                	mov    %eax,%ebx
  800b44:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800b47:	39 c6                	cmp    %eax,%esi
  800b49:	74 17                	je     800b62 <strncmp+0x42>
  800b4b:	0f b6 08             	movzbl (%eax),%ecx
  800b4e:	84 c9                	test   %cl,%cl
  800b50:	74 17                	je     800b69 <strncmp+0x49>
  800b52:	83 c0 01             	add    $0x1,%eax
  800b55:	3a 0a                	cmp    (%edx),%cl
  800b57:	74 e9                	je     800b42 <strncmp+0x22>
  800b59:	eb 0e                	jmp    800b69 <strncmp+0x49>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800b5b:	b8 00 00 00 00       	mov    $0x0,%eax
  800b60:	eb 0f                	jmp    800b71 <strncmp+0x51>
  800b62:	b8 00 00 00 00       	mov    $0x0,%eax
  800b67:	eb 08                	jmp    800b71 <strncmp+0x51>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b69:	0f b6 03             	movzbl (%ebx),%eax
  800b6c:	0f b6 12             	movzbl (%edx),%edx
  800b6f:	29 d0                	sub    %edx,%eax
}
  800b71:	5b                   	pop    %ebx
  800b72:	5e                   	pop    %esi
  800b73:	5d                   	pop    %ebp
  800b74:	c3                   	ret    

00800b75 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b75:	55                   	push   %ebp
  800b76:	89 e5                	mov    %esp,%ebp
  800b78:	53                   	push   %ebx
  800b79:	8b 45 08             	mov    0x8(%ebp),%eax
  800b7c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
  800b7f:	0f b6 10             	movzbl (%eax),%edx
  800b82:	84 d2                	test   %dl,%dl
  800b84:	74 1d                	je     800ba3 <strchr+0x2e>
  800b86:	89 d9                	mov    %ebx,%ecx
		if (*s == c)
  800b88:	38 d3                	cmp    %dl,%bl
  800b8a:	75 06                	jne    800b92 <strchr+0x1d>
  800b8c:	eb 1a                	jmp    800ba8 <strchr+0x33>
  800b8e:	38 ca                	cmp    %cl,%dl
  800b90:	74 16                	je     800ba8 <strchr+0x33>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b92:	83 c0 01             	add    $0x1,%eax
  800b95:	0f b6 10             	movzbl (%eax),%edx
  800b98:	84 d2                	test   %dl,%dl
  800b9a:	75 f2                	jne    800b8e <strchr+0x19>
		if (*s == c)
			return (char *) s;
	return 0;
  800b9c:	b8 00 00 00 00       	mov    $0x0,%eax
  800ba1:	eb 05                	jmp    800ba8 <strchr+0x33>
  800ba3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ba8:	5b                   	pop    %ebx
  800ba9:	5d                   	pop    %ebp
  800baa:	c3                   	ret    

00800bab <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800bab:	55                   	push   %ebp
  800bac:	89 e5                	mov    %esp,%ebp
  800bae:	53                   	push   %ebx
  800baf:	8b 45 08             	mov    0x8(%ebp),%eax
  800bb2:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  800bb5:	0f b6 18             	movzbl (%eax),%ebx
		if (*s == c)
  800bb8:	38 d3                	cmp    %dl,%bl
  800bba:	74 14                	je     800bd0 <strfind+0x25>
  800bbc:	89 d1                	mov    %edx,%ecx
  800bbe:	84 db                	test   %bl,%bl
  800bc0:	74 0e                	je     800bd0 <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800bc2:	83 c0 01             	add    $0x1,%eax
  800bc5:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800bc8:	38 ca                	cmp    %cl,%dl
  800bca:	74 04                	je     800bd0 <strfind+0x25>
  800bcc:	84 d2                	test   %dl,%dl
  800bce:	75 f2                	jne    800bc2 <strfind+0x17>
			break;
	return (char *) s;
}
  800bd0:	5b                   	pop    %ebx
  800bd1:	5d                   	pop    %ebp
  800bd2:	c3                   	ret    

00800bd3 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800bd3:	55                   	push   %ebp
  800bd4:	89 e5                	mov    %esp,%ebp
  800bd6:	57                   	push   %edi
  800bd7:	56                   	push   %esi
  800bd8:	53                   	push   %ebx
  800bd9:	8b 7d 08             	mov    0x8(%ebp),%edi
  800bdc:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800bdf:	85 c9                	test   %ecx,%ecx
  800be1:	74 36                	je     800c19 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800be3:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800be9:	75 28                	jne    800c13 <memset+0x40>
  800beb:	f6 c1 03             	test   $0x3,%cl
  800bee:	75 23                	jne    800c13 <memset+0x40>
		c &= 0xFF;
  800bf0:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800bf4:	89 d3                	mov    %edx,%ebx
  800bf6:	c1 e3 08             	shl    $0x8,%ebx
  800bf9:	89 d6                	mov    %edx,%esi
  800bfb:	c1 e6 18             	shl    $0x18,%esi
  800bfe:	89 d0                	mov    %edx,%eax
  800c00:	c1 e0 10             	shl    $0x10,%eax
  800c03:	09 f0                	or     %esi,%eax
  800c05:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800c07:	89 d8                	mov    %ebx,%eax
  800c09:	09 d0                	or     %edx,%eax
  800c0b:	c1 e9 02             	shr    $0x2,%ecx
  800c0e:	fc                   	cld    
  800c0f:	f3 ab                	rep stos %eax,%es:(%edi)
  800c11:	eb 06                	jmp    800c19 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800c13:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c16:	fc                   	cld    
  800c17:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800c19:	89 f8                	mov    %edi,%eax
  800c1b:	5b                   	pop    %ebx
  800c1c:	5e                   	pop    %esi
  800c1d:	5f                   	pop    %edi
  800c1e:	5d                   	pop    %ebp
  800c1f:	c3                   	ret    

00800c20 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800c20:	55                   	push   %ebp
  800c21:	89 e5                	mov    %esp,%ebp
  800c23:	57                   	push   %edi
  800c24:	56                   	push   %esi
  800c25:	8b 45 08             	mov    0x8(%ebp),%eax
  800c28:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c2b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800c2e:	39 c6                	cmp    %eax,%esi
  800c30:	73 35                	jae    800c67 <memmove+0x47>
  800c32:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c35:	39 d0                	cmp    %edx,%eax
  800c37:	73 2e                	jae    800c67 <memmove+0x47>
		s += n;
		d += n;
  800c39:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c3c:	89 d6                	mov    %edx,%esi
  800c3e:	09 fe                	or     %edi,%esi
  800c40:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c46:	75 13                	jne    800c5b <memmove+0x3b>
  800c48:	f6 c1 03             	test   $0x3,%cl
  800c4b:	75 0e                	jne    800c5b <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800c4d:	83 ef 04             	sub    $0x4,%edi
  800c50:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c53:	c1 e9 02             	shr    $0x2,%ecx
  800c56:	fd                   	std    
  800c57:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c59:	eb 09                	jmp    800c64 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800c5b:	83 ef 01             	sub    $0x1,%edi
  800c5e:	8d 72 ff             	lea    -0x1(%edx),%esi
  800c61:	fd                   	std    
  800c62:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c64:	fc                   	cld    
  800c65:	eb 1d                	jmp    800c84 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c67:	89 f2                	mov    %esi,%edx
  800c69:	09 c2                	or     %eax,%edx
  800c6b:	f6 c2 03             	test   $0x3,%dl
  800c6e:	75 0f                	jne    800c7f <memmove+0x5f>
  800c70:	f6 c1 03             	test   $0x3,%cl
  800c73:	75 0a                	jne    800c7f <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800c75:	c1 e9 02             	shr    $0x2,%ecx
  800c78:	89 c7                	mov    %eax,%edi
  800c7a:	fc                   	cld    
  800c7b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c7d:	eb 05                	jmp    800c84 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c7f:	89 c7                	mov    %eax,%edi
  800c81:	fc                   	cld    
  800c82:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c84:	5e                   	pop    %esi
  800c85:	5f                   	pop    %edi
  800c86:	5d                   	pop    %ebp
  800c87:	c3                   	ret    

00800c88 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800c88:	55                   	push   %ebp
  800c89:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800c8b:	ff 75 10             	pushl  0x10(%ebp)
  800c8e:	ff 75 0c             	pushl  0xc(%ebp)
  800c91:	ff 75 08             	pushl  0x8(%ebp)
  800c94:	e8 87 ff ff ff       	call   800c20 <memmove>
}
  800c99:	c9                   	leave  
  800c9a:	c3                   	ret    

00800c9b <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c9b:	55                   	push   %ebp
  800c9c:	89 e5                	mov    %esp,%ebp
  800c9e:	57                   	push   %edi
  800c9f:	56                   	push   %esi
  800ca0:	53                   	push   %ebx
  800ca1:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800ca4:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ca7:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800caa:	85 c0                	test   %eax,%eax
  800cac:	74 39                	je     800ce7 <memcmp+0x4c>
  800cae:	8d 78 ff             	lea    -0x1(%eax),%edi
		if (*s1 != *s2)
  800cb1:	0f b6 13             	movzbl (%ebx),%edx
  800cb4:	0f b6 0e             	movzbl (%esi),%ecx
  800cb7:	38 ca                	cmp    %cl,%dl
  800cb9:	75 17                	jne    800cd2 <memcmp+0x37>
  800cbb:	b8 00 00 00 00       	mov    $0x0,%eax
  800cc0:	eb 1a                	jmp    800cdc <memcmp+0x41>
  800cc2:	0f b6 54 03 01       	movzbl 0x1(%ebx,%eax,1),%edx
  800cc7:	83 c0 01             	add    $0x1,%eax
  800cca:	0f b6 0c 06          	movzbl (%esi,%eax,1),%ecx
  800cce:	38 ca                	cmp    %cl,%dl
  800cd0:	74 0a                	je     800cdc <memcmp+0x41>
			return (int) *s1 - (int) *s2;
  800cd2:	0f b6 c2             	movzbl %dl,%eax
  800cd5:	0f b6 c9             	movzbl %cl,%ecx
  800cd8:	29 c8                	sub    %ecx,%eax
  800cda:	eb 10                	jmp    800cec <memcmp+0x51>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800cdc:	39 f8                	cmp    %edi,%eax
  800cde:	75 e2                	jne    800cc2 <memcmp+0x27>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800ce0:	b8 00 00 00 00       	mov    $0x0,%eax
  800ce5:	eb 05                	jmp    800cec <memcmp+0x51>
  800ce7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800cec:	5b                   	pop    %ebx
  800ced:	5e                   	pop    %esi
  800cee:	5f                   	pop    %edi
  800cef:	5d                   	pop    %ebp
  800cf0:	c3                   	ret    

00800cf1 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800cf1:	55                   	push   %ebp
  800cf2:	89 e5                	mov    %esp,%ebp
  800cf4:	53                   	push   %ebx
  800cf5:	8b 55 08             	mov    0x8(%ebp),%edx
	const void *ends = (const char *) s + n;
  800cf8:	89 d0                	mov    %edx,%eax
  800cfa:	03 45 10             	add    0x10(%ebp),%eax
	for (; s < ends; s++)
  800cfd:	39 c2                	cmp    %eax,%edx
  800cff:	73 1d                	jae    800d1e <memfind+0x2d>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d01:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
  800d05:	0f b6 0a             	movzbl (%edx),%ecx
  800d08:	39 d9                	cmp    %ebx,%ecx
  800d0a:	75 09                	jne    800d15 <memfind+0x24>
  800d0c:	eb 14                	jmp    800d22 <memfind+0x31>
  800d0e:	0f b6 0a             	movzbl (%edx),%ecx
  800d11:	39 d9                	cmp    %ebx,%ecx
  800d13:	74 11                	je     800d26 <memfind+0x35>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800d15:	83 c2 01             	add    $0x1,%edx
  800d18:	39 d0                	cmp    %edx,%eax
  800d1a:	75 f2                	jne    800d0e <memfind+0x1d>
  800d1c:	eb 0a                	jmp    800d28 <memfind+0x37>
  800d1e:	89 d0                	mov    %edx,%eax
  800d20:	eb 06                	jmp    800d28 <memfind+0x37>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d22:	89 d0                	mov    %edx,%eax
  800d24:	eb 02                	jmp    800d28 <memfind+0x37>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800d26:	89 d0                	mov    %edx,%eax
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800d28:	5b                   	pop    %ebx
  800d29:	5d                   	pop    %ebp
  800d2a:	c3                   	ret    

00800d2b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d2b:	55                   	push   %ebp
  800d2c:	89 e5                	mov    %esp,%ebp
  800d2e:	57                   	push   %edi
  800d2f:	56                   	push   %esi
  800d30:	53                   	push   %ebx
  800d31:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d34:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d37:	0f b6 01             	movzbl (%ecx),%eax
  800d3a:	3c 20                	cmp    $0x20,%al
  800d3c:	74 04                	je     800d42 <strtol+0x17>
  800d3e:	3c 09                	cmp    $0x9,%al
  800d40:	75 0e                	jne    800d50 <strtol+0x25>
		s++;
  800d42:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d45:	0f b6 01             	movzbl (%ecx),%eax
  800d48:	3c 20                	cmp    $0x20,%al
  800d4a:	74 f6                	je     800d42 <strtol+0x17>
  800d4c:	3c 09                	cmp    $0x9,%al
  800d4e:	74 f2                	je     800d42 <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  800d50:	3c 2b                	cmp    $0x2b,%al
  800d52:	75 0a                	jne    800d5e <strtol+0x33>
		s++;
  800d54:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800d57:	bf 00 00 00 00       	mov    $0x0,%edi
  800d5c:	eb 11                	jmp    800d6f <strtol+0x44>
  800d5e:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800d63:	3c 2d                	cmp    $0x2d,%al
  800d65:	75 08                	jne    800d6f <strtol+0x44>
		s++, neg = 1;
  800d67:	83 c1 01             	add    $0x1,%ecx
  800d6a:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d6f:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800d75:	75 15                	jne    800d8c <strtol+0x61>
  800d77:	80 39 30             	cmpb   $0x30,(%ecx)
  800d7a:	75 10                	jne    800d8c <strtol+0x61>
  800d7c:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800d80:	75 7c                	jne    800dfe <strtol+0xd3>
		s += 2, base = 16;
  800d82:	83 c1 02             	add    $0x2,%ecx
  800d85:	bb 10 00 00 00       	mov    $0x10,%ebx
  800d8a:	eb 16                	jmp    800da2 <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  800d8c:	85 db                	test   %ebx,%ebx
  800d8e:	75 12                	jne    800da2 <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800d90:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800d95:	80 39 30             	cmpb   $0x30,(%ecx)
  800d98:	75 08                	jne    800da2 <strtol+0x77>
		s++, base = 8;
  800d9a:	83 c1 01             	add    $0x1,%ecx
  800d9d:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800da2:	b8 00 00 00 00       	mov    $0x0,%eax
  800da7:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800daa:	0f b6 11             	movzbl (%ecx),%edx
  800dad:	8d 72 d0             	lea    -0x30(%edx),%esi
  800db0:	89 f3                	mov    %esi,%ebx
  800db2:	80 fb 09             	cmp    $0x9,%bl
  800db5:	77 08                	ja     800dbf <strtol+0x94>
			dig = *s - '0';
  800db7:	0f be d2             	movsbl %dl,%edx
  800dba:	83 ea 30             	sub    $0x30,%edx
  800dbd:	eb 22                	jmp    800de1 <strtol+0xb6>
		else if (*s >= 'a' && *s <= 'z')
  800dbf:	8d 72 9f             	lea    -0x61(%edx),%esi
  800dc2:	89 f3                	mov    %esi,%ebx
  800dc4:	80 fb 19             	cmp    $0x19,%bl
  800dc7:	77 08                	ja     800dd1 <strtol+0xa6>
			dig = *s - 'a' + 10;
  800dc9:	0f be d2             	movsbl %dl,%edx
  800dcc:	83 ea 57             	sub    $0x57,%edx
  800dcf:	eb 10                	jmp    800de1 <strtol+0xb6>
		else if (*s >= 'A' && *s <= 'Z')
  800dd1:	8d 72 bf             	lea    -0x41(%edx),%esi
  800dd4:	89 f3                	mov    %esi,%ebx
  800dd6:	80 fb 19             	cmp    $0x19,%bl
  800dd9:	77 16                	ja     800df1 <strtol+0xc6>
			dig = *s - 'A' + 10;
  800ddb:	0f be d2             	movsbl %dl,%edx
  800dde:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800de1:	3b 55 10             	cmp    0x10(%ebp),%edx
  800de4:	7d 0b                	jge    800df1 <strtol+0xc6>
			break;
		s++, val = (val * base) + dig;
  800de6:	83 c1 01             	add    $0x1,%ecx
  800de9:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ded:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800def:	eb b9                	jmp    800daa <strtol+0x7f>

	if (endptr)
  800df1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800df5:	74 0d                	je     800e04 <strtol+0xd9>
		*endptr = (char *) s;
  800df7:	8b 75 0c             	mov    0xc(%ebp),%esi
  800dfa:	89 0e                	mov    %ecx,(%esi)
  800dfc:	eb 06                	jmp    800e04 <strtol+0xd9>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800dfe:	85 db                	test   %ebx,%ebx
  800e00:	74 98                	je     800d9a <strtol+0x6f>
  800e02:	eb 9e                	jmp    800da2 <strtol+0x77>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800e04:	89 c2                	mov    %eax,%edx
  800e06:	f7 da                	neg    %edx
  800e08:	85 ff                	test   %edi,%edi
  800e0a:	0f 45 c2             	cmovne %edx,%eax
}
  800e0d:	5b                   	pop    %ebx
  800e0e:	5e                   	pop    %esi
  800e0f:	5f                   	pop    %edi
  800e10:	5d                   	pop    %ebp
  800e11:	c3                   	ret    
  800e12:	66 90                	xchg   %ax,%ax
  800e14:	66 90                	xchg   %ax,%ax
  800e16:	66 90                	xchg   %ax,%ax
  800e18:	66 90                	xchg   %ax,%ax
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
