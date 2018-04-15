
obj/user/softint:     file format elf32-i386


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
  80002c:	e8 09 00 00 00       	call   80003a <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	asm volatile("int $14");	// page fault
  800036:	cd 0e                	int    $0xe
}
  800038:	5d                   	pop    %ebp
  800039:	c3                   	ret    

0080003a <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80003a:	55                   	push   %ebp
  80003b:	89 e5                	mov    %esp,%ebp
  80003d:	83 ec 08             	sub    $0x8,%esp
  800040:	8b 45 08             	mov    0x8(%ebp),%eax
  800043:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800046:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  80004d:	00 00 00 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800050:	85 c0                	test   %eax,%eax
  800052:	7e 08                	jle    80005c <libmain+0x22>
		binaryname = argv[0];
  800054:	8b 0a                	mov    (%edx),%ecx
  800056:	89 0d 00 20 80 00    	mov    %ecx,0x802000

	// call user main routine
	umain(argc, argv);
  80005c:	83 ec 08             	sub    $0x8,%esp
  80005f:	52                   	push   %edx
  800060:	50                   	push   %eax
  800061:	e8 cd ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800066:	e8 05 00 00 00       	call   800070 <exit>
}
  80006b:	83 c4 10             	add    $0x10,%esp
  80006e:	c9                   	leave  
  80006f:	c3                   	ret    

00800070 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800070:	55                   	push   %ebp
  800071:	89 e5                	mov    %esp,%ebp
  800073:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800076:	6a 00                	push   $0x0
  800078:	e8 52 00 00 00       	call   8000cf <sys_env_destroy>
}
  80007d:	83 c4 10             	add    $0x10,%esp
  800080:	c9                   	leave  
  800081:	c3                   	ret    

00800082 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800082:	55                   	push   %ebp
  800083:	89 e5                	mov    %esp,%ebp
  800085:	57                   	push   %edi
  800086:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800087:	b8 00 00 00 00       	mov    $0x0,%eax
  80008c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80008f:	8b 55 08             	mov    0x8(%ebp),%edx
  800092:	89 c3                	mov    %eax,%ebx
  800094:	89 c7                	mov    %eax,%edi
  800096:	51                   	push   %ecx
  800097:	52                   	push   %edx
  800098:	53                   	push   %ebx
  800099:	54                   	push   %esp
  80009a:	55                   	push   %ebp
  80009b:	56                   	push   %esi
  80009c:	57                   	push   %edi
  80009d:	5f                   	pop    %edi
  80009e:	5e                   	pop    %esi
  80009f:	5d                   	pop    %ebp
  8000a0:	5c                   	pop    %esp
  8000a1:	5b                   	pop    %ebx
  8000a2:	5a                   	pop    %edx
  8000a3:	59                   	pop    %ecx

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000a4:	5b                   	pop    %ebx
  8000a5:	5f                   	pop    %edi
  8000a6:	5d                   	pop    %ebp
  8000a7:	c3                   	ret    

008000a8 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000a8:	55                   	push   %ebp
  8000a9:	89 e5                	mov    %esp,%ebp
  8000ab:	57                   	push   %edi
  8000ac:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8000ad:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000b2:	b8 01 00 00 00       	mov    $0x1,%eax
  8000b7:	89 ca                	mov    %ecx,%edx
  8000b9:	89 cb                	mov    %ecx,%ebx
  8000bb:	89 cf                	mov    %ecx,%edi
  8000bd:	51                   	push   %ecx
  8000be:	52                   	push   %edx
  8000bf:	53                   	push   %ebx
  8000c0:	54                   	push   %esp
  8000c1:	55                   	push   %ebp
  8000c2:	56                   	push   %esi
  8000c3:	57                   	push   %edi
  8000c4:	5f                   	pop    %edi
  8000c5:	5e                   	pop    %esi
  8000c6:	5d                   	pop    %ebp
  8000c7:	5c                   	pop    %esp
  8000c8:	5b                   	pop    %ebx
  8000c9:	5a                   	pop    %edx
  8000ca:	59                   	pop    %ecx

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000cb:	5b                   	pop    %ebx
  8000cc:	5f                   	pop    %edi
  8000cd:	5d                   	pop    %ebp
  8000ce:	c3                   	ret    

008000cf <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000cf:	55                   	push   %ebp
  8000d0:	89 e5                	mov    %esp,%ebp
  8000d2:	57                   	push   %edi
  8000d3:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8000d4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8000d9:	b8 03 00 00 00       	mov    $0x3,%eax
  8000de:	8b 55 08             	mov    0x8(%ebp),%edx
  8000e1:	89 d9                	mov    %ebx,%ecx
  8000e3:	89 df                	mov    %ebx,%edi
  8000e5:	51                   	push   %ecx
  8000e6:	52                   	push   %edx
  8000e7:	53                   	push   %ebx
  8000e8:	54                   	push   %esp
  8000e9:	55                   	push   %ebp
  8000ea:	56                   	push   %esi
  8000eb:	57                   	push   %edi
  8000ec:	5f                   	pop    %edi
  8000ed:	5e                   	pop    %esi
  8000ee:	5d                   	pop    %ebp
  8000ef:	5c                   	pop    %esp
  8000f0:	5b                   	pop    %ebx
  8000f1:	5a                   	pop    %edx
  8000f2:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  8000f3:	85 c0                	test   %eax,%eax
  8000f5:	7e 17                	jle    80010e <sys_env_destroy+0x3f>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000f7:	83 ec 0c             	sub    $0xc,%esp
  8000fa:	50                   	push   %eax
  8000fb:	6a 03                	push   $0x3
  8000fd:	68 9e 10 80 00       	push   $0x80109e
  800102:	6a 26                	push   $0x26
  800104:	68 bb 10 80 00       	push   $0x8010bb
  800109:	e8 7f 00 00 00       	call   80018d <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80010e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800111:	5b                   	pop    %ebx
  800112:	5f                   	pop    %edi
  800113:	5d                   	pop    %ebp
  800114:	c3                   	ret    

00800115 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800115:	55                   	push   %ebp
  800116:	89 e5                	mov    %esp,%ebp
  800118:	57                   	push   %edi
  800119:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80011a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80011f:	b8 02 00 00 00       	mov    $0x2,%eax
  800124:	89 ca                	mov    %ecx,%edx
  800126:	89 cb                	mov    %ecx,%ebx
  800128:	89 cf                	mov    %ecx,%edi
  80012a:	51                   	push   %ecx
  80012b:	52                   	push   %edx
  80012c:	53                   	push   %ebx
  80012d:	54                   	push   %esp
  80012e:	55                   	push   %ebp
  80012f:	56                   	push   %esi
  800130:	57                   	push   %edi
  800131:	5f                   	pop    %edi
  800132:	5e                   	pop    %esi
  800133:	5d                   	pop    %ebp
  800134:	5c                   	pop    %esp
  800135:	5b                   	pop    %ebx
  800136:	5a                   	pop    %edx
  800137:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800138:	5b                   	pop    %ebx
  800139:	5f                   	pop    %edi
  80013a:	5d                   	pop    %ebp
  80013b:	c3                   	ret    

0080013c <sys_map_kernel_page>:

int
sys_map_kernel_page(void* kpage, void* va)
{
  80013c:	55                   	push   %ebp
  80013d:	89 e5                	mov    %esp,%ebp
  80013f:	57                   	push   %edi
  800140:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800141:	bf 00 00 00 00       	mov    $0x0,%edi
  800146:	b8 04 00 00 00       	mov    $0x4,%eax
  80014b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80014e:	8b 55 08             	mov    0x8(%ebp),%edx
  800151:	89 fb                	mov    %edi,%ebx
  800153:	51                   	push   %ecx
  800154:	52                   	push   %edx
  800155:	53                   	push   %ebx
  800156:	54                   	push   %esp
  800157:	55                   	push   %ebp
  800158:	56                   	push   %esi
  800159:	57                   	push   %edi
  80015a:	5f                   	pop    %edi
  80015b:	5e                   	pop    %esi
  80015c:	5d                   	pop    %ebp
  80015d:	5c                   	pop    %esp
  80015e:	5b                   	pop    %ebx
  80015f:	5a                   	pop    %edx
  800160:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  800161:	5b                   	pop    %ebx
  800162:	5f                   	pop    %edi
  800163:	5d                   	pop    %ebp
  800164:	c3                   	ret    

00800165 <sys_sbrk>:

int
sys_sbrk(uint32_t inc)
{
  800165:	55                   	push   %ebp
  800166:	89 e5                	mov    %esp,%ebp
  800168:	57                   	push   %edi
  800169:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80016a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80016f:	b8 05 00 00 00       	mov    $0x5,%eax
  800174:	8b 55 08             	mov    0x8(%ebp),%edx
  800177:	89 cb                	mov    %ecx,%ebx
  800179:	89 cf                	mov    %ecx,%edi
  80017b:	51                   	push   %ecx
  80017c:	52                   	push   %edx
  80017d:	53                   	push   %ebx
  80017e:	54                   	push   %esp
  80017f:	55                   	push   %ebp
  800180:	56                   	push   %esi
  800181:	57                   	push   %edi
  800182:	5f                   	pop    %edi
  800183:	5e                   	pop    %esi
  800184:	5d                   	pop    %ebp
  800185:	5c                   	pop    %esp
  800186:	5b                   	pop    %ebx
  800187:	5a                   	pop    %edx
  800188:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  800189:	5b                   	pop    %ebx
  80018a:	5f                   	pop    %edi
  80018b:	5d                   	pop    %ebp
  80018c:	c3                   	ret    

0080018d <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80018d:	55                   	push   %ebp
  80018e:	89 e5                	mov    %esp,%ebp
  800190:	56                   	push   %esi
  800191:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800192:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	if (argv0)
  800195:	a1 08 20 80 00       	mov    0x802008,%eax
  80019a:	85 c0                	test   %eax,%eax
  80019c:	74 11                	je     8001af <_panic+0x22>
		cprintf("%s: ", argv0);
  80019e:	83 ec 08             	sub    $0x8,%esp
  8001a1:	50                   	push   %eax
  8001a2:	68 c9 10 80 00       	push   $0x8010c9
  8001a7:	e8 d4 00 00 00       	call   800280 <cprintf>
  8001ac:	83 c4 10             	add    $0x10,%esp
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001af:	8b 35 00 20 80 00    	mov    0x802000,%esi
  8001b5:	e8 5b ff ff ff       	call   800115 <sys_getenvid>
  8001ba:	83 ec 0c             	sub    $0xc,%esp
  8001bd:	ff 75 0c             	pushl  0xc(%ebp)
  8001c0:	ff 75 08             	pushl  0x8(%ebp)
  8001c3:	56                   	push   %esi
  8001c4:	50                   	push   %eax
  8001c5:	68 d0 10 80 00       	push   $0x8010d0
  8001ca:	e8 b1 00 00 00       	call   800280 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001cf:	83 c4 18             	add    $0x18,%esp
  8001d2:	53                   	push   %ebx
  8001d3:	ff 75 10             	pushl  0x10(%ebp)
  8001d6:	e8 54 00 00 00       	call   80022f <vcprintf>
	cprintf("\n");
  8001db:	c7 04 24 ce 10 80 00 	movl   $0x8010ce,(%esp)
  8001e2:	e8 99 00 00 00       	call   800280 <cprintf>
  8001e7:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001ea:	cc                   	int3   
  8001eb:	eb fd                	jmp    8001ea <_panic+0x5d>

008001ed <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001ed:	55                   	push   %ebp
  8001ee:	89 e5                	mov    %esp,%ebp
  8001f0:	53                   	push   %ebx
  8001f1:	83 ec 04             	sub    $0x4,%esp
  8001f4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001f7:	8b 13                	mov    (%ebx),%edx
  8001f9:	8d 42 01             	lea    0x1(%edx),%eax
  8001fc:	89 03                	mov    %eax,(%ebx)
  8001fe:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800201:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800205:	3d ff 00 00 00       	cmp    $0xff,%eax
  80020a:	75 1a                	jne    800226 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80020c:	83 ec 08             	sub    $0x8,%esp
  80020f:	68 ff 00 00 00       	push   $0xff
  800214:	8d 43 08             	lea    0x8(%ebx),%eax
  800217:	50                   	push   %eax
  800218:	e8 65 fe ff ff       	call   800082 <sys_cputs>
		b->idx = 0;
  80021d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800223:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800226:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80022a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80022d:	c9                   	leave  
  80022e:	c3                   	ret    

0080022f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80022f:	55                   	push   %ebp
  800230:	89 e5                	mov    %esp,%ebp
  800232:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800238:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80023f:	00 00 00 
	b.cnt = 0;
  800242:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800249:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80024c:	ff 75 0c             	pushl  0xc(%ebp)
  80024f:	ff 75 08             	pushl  0x8(%ebp)
  800252:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800258:	50                   	push   %eax
  800259:	68 ed 01 80 00       	push   $0x8001ed
  80025e:	e8 45 02 00 00       	call   8004a8 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800263:	83 c4 08             	add    $0x8,%esp
  800266:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80026c:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800272:	50                   	push   %eax
  800273:	e8 0a fe ff ff       	call   800082 <sys_cputs>

	return b.cnt;
}
  800278:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80027e:	c9                   	leave  
  80027f:	c3                   	ret    

00800280 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800280:	55                   	push   %ebp
  800281:	89 e5                	mov    %esp,%ebp
  800283:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800286:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800289:	50                   	push   %eax
  80028a:	ff 75 08             	pushl  0x8(%ebp)
  80028d:	e8 9d ff ff ff       	call   80022f <vcprintf>
	va_end(ap);

	return cnt;
}
  800292:	c9                   	leave  
  800293:	c3                   	ret    

00800294 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800294:	55                   	push   %ebp
  800295:	89 e5                	mov    %esp,%ebp
  800297:	57                   	push   %edi
  800298:	56                   	push   %esi
  800299:	53                   	push   %ebx
  80029a:	83 ec 1c             	sub    $0x1c,%esp
  80029d:	89 c7                	mov    %eax,%edi
  80029f:	89 d6                	mov    %edx,%esi
  8002a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8002a4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002a7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002aa:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	// if cprintf'parameter includes pattern of the form "%-", padding
	// space on the right side if neccesary.
	// you can add helper function if needed.
	// your code here:
	int length,showsign=0;
	if(padc=='-'&&num>=base)
  8002ad:	83 7d 18 2d          	cmpl   $0x2d,0x18(%ebp)
  8002b1:	0f 85 8a 00 00 00    	jne    800341 <printnum+0xad>
  8002b7:	8b 45 10             	mov    0x10(%ebp),%eax
  8002ba:	ba 00 00 00 00       	mov    $0x0,%edx
  8002bf:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8002c2:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8002c5:	39 da                	cmp    %ebx,%edx
  8002c7:	72 09                	jb     8002d2 <printnum+0x3e>
  8002c9:	39 4d 10             	cmp    %ecx,0x10(%ebp)
  8002cc:	0f 87 87 00 00 00    	ja     800359 <printnum+0xc5>
	{
		length=*(int *)putdat;
  8002d2:	8b 1e                	mov    (%esi),%ebx
		printnum(putch,putdat,num/base,base,0,padc);
  8002d4:	83 ec 0c             	sub    $0xc,%esp
  8002d7:	6a 2d                	push   $0x2d
  8002d9:	6a 00                	push   $0x0
  8002db:	ff 75 10             	pushl  0x10(%ebp)
  8002de:	83 ec 08             	sub    $0x8,%esp
  8002e1:	52                   	push   %edx
  8002e2:	50                   	push   %eax
  8002e3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002e6:	ff 75 e0             	pushl  -0x20(%ebp)
  8002e9:	e8 22 0b 00 00       	call   800e10 <__udivdi3>
  8002ee:	83 c4 18             	add    $0x18,%esp
  8002f1:	52                   	push   %edx
  8002f2:	50                   	push   %eax
  8002f3:	89 f2                	mov    %esi,%edx
  8002f5:	89 f8                	mov    %edi,%eax
  8002f7:	e8 98 ff ff ff       	call   800294 <printnum>
		while (--width > 0)
			putch(padc, putdat);
	}
	}
	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002fc:	83 c4 18             	add    $0x18,%esp
  8002ff:	56                   	push   %esi
  800300:	8b 45 10             	mov    0x10(%ebp),%eax
  800303:	ba 00 00 00 00       	mov    $0x0,%edx
  800308:	83 ec 04             	sub    $0x4,%esp
  80030b:	52                   	push   %edx
  80030c:	50                   	push   %eax
  80030d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800310:	ff 75 e0             	pushl  -0x20(%ebp)
  800313:	e8 28 0c 00 00       	call   800f40 <__umoddi3>
  800318:	83 c4 14             	add    $0x14,%esp
  80031b:	0f be 80 f3 10 80 00 	movsbl 0x8010f3(%eax),%eax
  800322:	50                   	push   %eax
  800323:	ff d7                	call   *%edi
	
	if(padc=='-'&&width>0)
  800325:	83 c4 10             	add    $0x10,%esp
  800328:	83 7d 18 2d          	cmpl   $0x2d,0x18(%ebp)
  80032c:	0f 85 fa 00 00 00    	jne    80042c <printnum+0x198>
  800332:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
  800336:	0f 8f 9b 00 00 00    	jg     8003d7 <printnum+0x143>
  80033c:	e9 eb 00 00 00       	jmp    80042c <printnum+0x198>
	}
	else
	{
	
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800341:	8b 45 10             	mov    0x10(%ebp),%eax
  800344:	ba 00 00 00 00       	mov    $0x0,%edx
  800349:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80034c:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80034f:	83 fb 00             	cmp    $0x0,%ebx
  800352:	77 14                	ja     800368 <printnum+0xd4>
  800354:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800357:	73 0f                	jae    800368 <printnum+0xd4>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800359:	8b 45 14             	mov    0x14(%ebp),%eax
  80035c:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80035f:	85 db                	test   %ebx,%ebx
  800361:	7f 61                	jg     8003c4 <printnum+0x130>
  800363:	e9 98 00 00 00       	jmp    800400 <printnum+0x16c>
	else
	{
	
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800368:	83 ec 0c             	sub    $0xc,%esp
  80036b:	ff 75 18             	pushl  0x18(%ebp)
  80036e:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800371:	8d 59 ff             	lea    -0x1(%ecx),%ebx
  800374:	53                   	push   %ebx
  800375:	ff 75 10             	pushl  0x10(%ebp)
  800378:	83 ec 08             	sub    $0x8,%esp
  80037b:	52                   	push   %edx
  80037c:	50                   	push   %eax
  80037d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800380:	ff 75 e0             	pushl  -0x20(%ebp)
  800383:	e8 88 0a 00 00       	call   800e10 <__udivdi3>
  800388:	83 c4 18             	add    $0x18,%esp
  80038b:	52                   	push   %edx
  80038c:	50                   	push   %eax
  80038d:	89 f2                	mov    %esi,%edx
  80038f:	89 f8                	mov    %edi,%eax
  800391:	e8 fe fe ff ff       	call   800294 <printnum>
		while (--width > 0)
			putch(padc, putdat);
	}
	}
	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800396:	83 c4 18             	add    $0x18,%esp
  800399:	56                   	push   %esi
  80039a:	8b 45 10             	mov    0x10(%ebp),%eax
  80039d:	ba 00 00 00 00       	mov    $0x0,%edx
  8003a2:	83 ec 04             	sub    $0x4,%esp
  8003a5:	52                   	push   %edx
  8003a6:	50                   	push   %eax
  8003a7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003aa:	ff 75 e0             	pushl  -0x20(%ebp)
  8003ad:	e8 8e 0b 00 00       	call   800f40 <__umoddi3>
  8003b2:	83 c4 14             	add    $0x14,%esp
  8003b5:	0f be 80 f3 10 80 00 	movsbl 0x8010f3(%eax),%eax
  8003bc:	50                   	push   %eax
  8003bd:	ff d7                	call   *%edi
  8003bf:	83 c4 10             	add    $0x10,%esp
  8003c2:	eb 68                	jmp    80042c <printnum+0x198>
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8003c4:	83 ec 08             	sub    $0x8,%esp
  8003c7:	56                   	push   %esi
  8003c8:	ff 75 18             	pushl  0x18(%ebp)
  8003cb:	ff d7                	call   *%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003cd:	83 c4 10             	add    $0x10,%esp
  8003d0:	83 eb 01             	sub    $0x1,%ebx
  8003d3:	75 ef                	jne    8003c4 <printnum+0x130>
  8003d5:	eb 29                	jmp    800400 <printnum+0x16c>
	putch("0123456789abcdef"[num % base], putdat);
	
	if(padc=='-'&&width>0)
	{
		length=*(int *)putdat-length;
		for(int i=0;i<width-length;++i)
  8003d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8003da:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  8003dd:	2b 06                	sub    (%esi),%eax
  8003df:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003e2:	85 c0                	test   %eax,%eax
  8003e4:	7e 46                	jle    80042c <printnum+0x198>
  8003e6:	bb 00 00 00 00       	mov    $0x0,%ebx
			putch(' ',putdat);
  8003eb:	83 ec 08             	sub    $0x8,%esp
  8003ee:	56                   	push   %esi
  8003ef:	6a 20                	push   $0x20
  8003f1:	ff d7                	call   *%edi
	putch("0123456789abcdef"[num % base], putdat);
	
	if(padc=='-'&&width>0)
	{
		length=*(int *)putdat-length;
		for(int i=0;i<width-length;++i)
  8003f3:	83 c3 01             	add    $0x1,%ebx
  8003f6:	83 c4 10             	add    $0x10,%esp
  8003f9:	3b 5d e0             	cmp    -0x20(%ebp),%ebx
  8003fc:	75 ed                	jne    8003eb <printnum+0x157>
  8003fe:	eb 2c                	jmp    80042c <printnum+0x198>
		while (--width > 0)
			putch(padc, putdat);
	}
	}
	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800400:	83 ec 08             	sub    $0x8,%esp
  800403:	56                   	push   %esi
  800404:	8b 45 10             	mov    0x10(%ebp),%eax
  800407:	ba 00 00 00 00       	mov    $0x0,%edx
  80040c:	83 ec 04             	sub    $0x4,%esp
  80040f:	52                   	push   %edx
  800410:	50                   	push   %eax
  800411:	ff 75 e4             	pushl  -0x1c(%ebp)
  800414:	ff 75 e0             	pushl  -0x20(%ebp)
  800417:	e8 24 0b 00 00       	call   800f40 <__umoddi3>
  80041c:	83 c4 14             	add    $0x14,%esp
  80041f:	0f be 80 f3 10 80 00 	movsbl 0x8010f3(%eax),%eax
  800426:	50                   	push   %eax
  800427:	ff d7                	call   *%edi
  800429:	83 c4 10             	add    $0x10,%esp
	{
		length=*(int *)putdat-length;
		for(int i=0;i<width-length;++i)
			putch(' ',putdat);
	}
}
  80042c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80042f:	5b                   	pop    %ebx
  800430:	5e                   	pop    %esi
  800431:	5f                   	pop    %edi
  800432:	5d                   	pop    %ebp
  800433:	c3                   	ret    

00800434 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800434:	55                   	push   %ebp
  800435:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800437:	83 fa 01             	cmp    $0x1,%edx
  80043a:	7e 0e                	jle    80044a <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80043c:	8b 10                	mov    (%eax),%edx
  80043e:	8d 4a 08             	lea    0x8(%edx),%ecx
  800441:	89 08                	mov    %ecx,(%eax)
  800443:	8b 02                	mov    (%edx),%eax
  800445:	8b 52 04             	mov    0x4(%edx),%edx
  800448:	eb 22                	jmp    80046c <getuint+0x38>
	else if (lflag)
  80044a:	85 d2                	test   %edx,%edx
  80044c:	74 10                	je     80045e <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80044e:	8b 10                	mov    (%eax),%edx
  800450:	8d 4a 04             	lea    0x4(%edx),%ecx
  800453:	89 08                	mov    %ecx,(%eax)
  800455:	8b 02                	mov    (%edx),%eax
  800457:	ba 00 00 00 00       	mov    $0x0,%edx
  80045c:	eb 0e                	jmp    80046c <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80045e:	8b 10                	mov    (%eax),%edx
  800460:	8d 4a 04             	lea    0x4(%edx),%ecx
  800463:	89 08                	mov    %ecx,(%eax)
  800465:	8b 02                	mov    (%edx),%eax
  800467:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80046c:	5d                   	pop    %ebp
  80046d:	c3                   	ret    

0080046e <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80046e:	55                   	push   %ebp
  80046f:	89 e5                	mov    %esp,%ebp
  800471:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800474:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800478:	8b 10                	mov    (%eax),%edx
  80047a:	3b 50 04             	cmp    0x4(%eax),%edx
  80047d:	73 0a                	jae    800489 <sprintputch+0x1b>
		*b->buf++ = ch;
  80047f:	8d 4a 01             	lea    0x1(%edx),%ecx
  800482:	89 08                	mov    %ecx,(%eax)
  800484:	8b 45 08             	mov    0x8(%ebp),%eax
  800487:	88 02                	mov    %al,(%edx)
}
  800489:	5d                   	pop    %ebp
  80048a:	c3                   	ret    

0080048b <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80048b:	55                   	push   %ebp
  80048c:	89 e5                	mov    %esp,%ebp
  80048e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800491:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800494:	50                   	push   %eax
  800495:	ff 75 10             	pushl  0x10(%ebp)
  800498:	ff 75 0c             	pushl  0xc(%ebp)
  80049b:	ff 75 08             	pushl  0x8(%ebp)
  80049e:	e8 05 00 00 00       	call   8004a8 <vprintfmt>
	va_end(ap);
}
  8004a3:	83 c4 10             	add    $0x10,%esp
  8004a6:	c9                   	leave  
  8004a7:	c3                   	ret    

008004a8 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8004a8:	55                   	push   %ebp
  8004a9:	89 e5                	mov    %esp,%ebp
  8004ab:	57                   	push   %edi
  8004ac:	56                   	push   %esi
  8004ad:	53                   	push   %ebx
  8004ae:	83 ec 2c             	sub    $0x2c,%esp
  8004b1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8004b4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004b7:	eb 03                	jmp    8004bc <vprintfmt+0x14>
			break;
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
			for (fmt--; fmt[-1] != '%'; fmt--)
  8004b9:	89 75 10             	mov    %esi,0x10(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8004bc:	8b 45 10             	mov    0x10(%ebp),%eax
  8004bf:	8d 70 01             	lea    0x1(%eax),%esi
  8004c2:	0f b6 00             	movzbl (%eax),%eax
  8004c5:	83 f8 25             	cmp    $0x25,%eax
  8004c8:	74 27                	je     8004f1 <vprintfmt+0x49>
			if (ch == '\0')
  8004ca:	85 c0                	test   %eax,%eax
  8004cc:	75 0d                	jne    8004db <vprintfmt+0x33>
  8004ce:	e9 8b 04 00 00       	jmp    80095e <vprintfmt+0x4b6>
  8004d3:	85 c0                	test   %eax,%eax
  8004d5:	0f 84 83 04 00 00    	je     80095e <vprintfmt+0x4b6>
				return;
			putch(ch, putdat);
  8004db:	83 ec 08             	sub    $0x8,%esp
  8004de:	53                   	push   %ebx
  8004df:	50                   	push   %eax
  8004e0:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8004e2:	83 c6 01             	add    $0x1,%esi
  8004e5:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  8004e9:	83 c4 10             	add    $0x10,%esp
  8004ec:	83 f8 25             	cmp    $0x25,%eax
  8004ef:	75 e2                	jne    8004d3 <vprintfmt+0x2b>
			padc = '-';
			goto reswitch;
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004f1:	c6 45 e3 20          	movb   $0x20,-0x1d(%ebp)
  8004f5:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8004fc:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800503:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80050a:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  800511:	b9 00 00 00 00       	mov    $0x0,%ecx
  800516:	eb 07                	jmp    80051f <vprintfmt+0x77>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800518:	8b 75 10             	mov    0x10(%ebp),%esi

		// flag to show the sign
		case '+':
			padc='+';
  80051b:	c6 45 e3 2b          	movb   $0x2b,-0x1d(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80051f:	8d 46 01             	lea    0x1(%esi),%eax
  800522:	89 45 10             	mov    %eax,0x10(%ebp)
  800525:	0f b6 06             	movzbl (%esi),%eax
  800528:	0f b6 d0             	movzbl %al,%edx
  80052b:	83 e8 23             	sub    $0x23,%eax
  80052e:	3c 55                	cmp    $0x55,%al
  800530:	0f 87 e9 03 00 00    	ja     80091f <vprintfmt+0x477>
  800536:	0f b6 c0             	movzbl %al,%eax
  800539:	ff 24 85 fc 11 80 00 	jmp    *0x8011fc(,%eax,4)
  800540:	8b 75 10             	mov    0x10(%ebp),%esi
			padc='+';
			goto reswitch;
		
		// flag to pad on the right
		case '-':
			padc = '-';
  800543:	c6 45 e3 2d          	movb   $0x2d,-0x1d(%ebp)
  800547:	eb d6                	jmp    80051f <vprintfmt+0x77>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800549:	8d 42 d0             	lea    -0x30(%edx),%eax
  80054c:	89 45 d0             	mov    %eax,-0x30(%ebp)
				ch = *fmt;
  80054f:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  800553:	8d 50 d0             	lea    -0x30(%eax),%edx
  800556:	83 fa 09             	cmp    $0x9,%edx
  800559:	77 66                	ja     8005c1 <vprintfmt+0x119>
  80055b:	8b 75 10             	mov    0x10(%ebp),%esi
  80055e:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800561:	89 7d 08             	mov    %edi,0x8(%ebp)
  800564:	eb 09                	jmp    80056f <vprintfmt+0xc7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800566:	8b 75 10             	mov    0x10(%ebp),%esi
			padc = '-';
			goto reswitch;
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800569:	c6 45 e3 30          	movb   $0x30,-0x1d(%ebp)
			goto reswitch;
  80056d:	eb b0                	jmp    80051f <vprintfmt+0x77>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80056f:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  800572:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800575:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  800579:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80057c:	8d 78 d0             	lea    -0x30(%eax),%edi
  80057f:	83 ff 09             	cmp    $0x9,%edi
  800582:	76 eb                	jbe    80056f <vprintfmt+0xc7>
  800584:	89 55 d0             	mov    %edx,-0x30(%ebp)
  800587:	8b 7d 08             	mov    0x8(%ebp),%edi
  80058a:	eb 38                	jmp    8005c4 <vprintfmt+0x11c>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80058c:	8b 45 14             	mov    0x14(%ebp),%eax
  80058f:	8d 50 04             	lea    0x4(%eax),%edx
  800592:	89 55 14             	mov    %edx,0x14(%ebp)
  800595:	8b 00                	mov    (%eax),%eax
  800597:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80059a:	8b 75 10             	mov    0x10(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80059d:	eb 25                	jmp    8005c4 <vprintfmt+0x11c>
  80059f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005a2:	85 c0                	test   %eax,%eax
  8005a4:	0f 48 c1             	cmovs  %ecx,%eax
  8005a7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005aa:	8b 75 10             	mov    0x10(%ebp),%esi
  8005ad:	e9 6d ff ff ff       	jmp    80051f <vprintfmt+0x77>
  8005b2:	8b 75 10             	mov    0x10(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8005b5:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8005bc:	e9 5e ff ff ff       	jmp    80051f <vprintfmt+0x77>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005c1:	8b 75 10             	mov    0x10(%ebp),%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8005c4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005c8:	0f 89 51 ff ff ff    	jns    80051f <vprintfmt+0x77>
				width = precision, precision = -1;
  8005ce:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8005d1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8005d4:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8005db:	e9 3f ff ff ff       	jmp    80051f <vprintfmt+0x77>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8005e0:	83 45 cc 01          	addl   $0x1,-0x34(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005e4:	8b 75 10             	mov    0x10(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8005e7:	e9 33 ff ff ff       	jmp    80051f <vprintfmt+0x77>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8005ec:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ef:	8d 50 04             	lea    0x4(%eax),%edx
  8005f2:	89 55 14             	mov    %edx,0x14(%ebp)
  8005f5:	83 ec 08             	sub    $0x8,%esp
  8005f8:	53                   	push   %ebx
  8005f9:	ff 30                	pushl  (%eax)
  8005fb:	ff d7                	call   *%edi
			break;
  8005fd:	83 c4 10             	add    $0x10,%esp
  800600:	e9 b7 fe ff ff       	jmp    8004bc <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800605:	8b 45 14             	mov    0x14(%ebp),%eax
  800608:	8d 50 04             	lea    0x4(%eax),%edx
  80060b:	89 55 14             	mov    %edx,0x14(%ebp)
  80060e:	8b 00                	mov    (%eax),%eax
  800610:	99                   	cltd   
  800611:	31 d0                	xor    %edx,%eax
  800613:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800615:	83 f8 06             	cmp    $0x6,%eax
  800618:	7f 0b                	jg     800625 <vprintfmt+0x17d>
  80061a:	8b 14 85 54 13 80 00 	mov    0x801354(,%eax,4),%edx
  800621:	85 d2                	test   %edx,%edx
  800623:	75 15                	jne    80063a <vprintfmt+0x192>
				printfmt(putch, putdat, "error %d", err);
  800625:	50                   	push   %eax
  800626:	68 0b 11 80 00       	push   $0x80110b
  80062b:	53                   	push   %ebx
  80062c:	57                   	push   %edi
  80062d:	e8 59 fe ff ff       	call   80048b <printfmt>
  800632:	83 c4 10             	add    $0x10,%esp
  800635:	e9 82 fe ff ff       	jmp    8004bc <vprintfmt+0x14>
			else
				printfmt(putch, putdat, "%s", p);
  80063a:	52                   	push   %edx
  80063b:	68 14 11 80 00       	push   $0x801114
  800640:	53                   	push   %ebx
  800641:	57                   	push   %edi
  800642:	e8 44 fe ff ff       	call   80048b <printfmt>
  800647:	83 c4 10             	add    $0x10,%esp
  80064a:	e9 6d fe ff ff       	jmp    8004bc <vprintfmt+0x14>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80064f:	8b 45 14             	mov    0x14(%ebp),%eax
  800652:	8d 50 04             	lea    0x4(%eax),%edx
  800655:	89 55 14             	mov    %edx,0x14(%ebp)
  800658:	8b 00                	mov    (%eax),%eax
				p = "(null)";
  80065a:	85 c0                	test   %eax,%eax
  80065c:	b9 04 11 80 00       	mov    $0x801104,%ecx
  800661:	0f 45 c8             	cmovne %eax,%ecx
  800664:	89 4d cc             	mov    %ecx,-0x34(%ebp)
			if (width > 0 && padc != '-')
  800667:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80066b:	7e 06                	jle    800673 <vprintfmt+0x1cb>
  80066d:	80 7d e3 2d          	cmpb   $0x2d,-0x1d(%ebp)
  800671:	75 19                	jne    80068c <vprintfmt+0x1e4>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800673:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800676:	8d 70 01             	lea    0x1(%eax),%esi
  800679:	0f b6 00             	movzbl (%eax),%eax
  80067c:	0f be d0             	movsbl %al,%edx
  80067f:	85 d2                	test   %edx,%edx
  800681:	0f 85 9f 00 00 00    	jne    800726 <vprintfmt+0x27e>
  800687:	e9 8c 00 00 00       	jmp    800718 <vprintfmt+0x270>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80068c:	83 ec 08             	sub    $0x8,%esp
  80068f:	ff 75 d0             	pushl  -0x30(%ebp)
  800692:	ff 75 cc             	pushl  -0x34(%ebp)
  800695:	e8 56 03 00 00       	call   8009f0 <strnlen>
  80069a:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  80069d:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8006a0:	83 c4 10             	add    $0x10,%esp
  8006a3:	85 c9                	test   %ecx,%ecx
  8006a5:	0f 8e 9a 02 00 00    	jle    800945 <vprintfmt+0x49d>
					putch(padc, putdat);
  8006ab:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  8006af:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006b2:	89 cb                	mov    %ecx,%ebx
  8006b4:	83 ec 08             	sub    $0x8,%esp
  8006b7:	ff 75 0c             	pushl  0xc(%ebp)
  8006ba:	56                   	push   %esi
  8006bb:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006bd:	83 c4 10             	add    $0x10,%esp
  8006c0:	83 eb 01             	sub    $0x1,%ebx
  8006c3:	75 ef                	jne    8006b4 <vprintfmt+0x20c>
  8006c5:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8006c8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006cb:	e9 75 02 00 00       	jmp    800945 <vprintfmt+0x49d>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8006d0:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8006d4:	74 1b                	je     8006f1 <vprintfmt+0x249>
  8006d6:	0f be c0             	movsbl %al,%eax
  8006d9:	83 e8 20             	sub    $0x20,%eax
  8006dc:	83 f8 5e             	cmp    $0x5e,%eax
  8006df:	76 10                	jbe    8006f1 <vprintfmt+0x249>
					putch('?', putdat);
  8006e1:	83 ec 08             	sub    $0x8,%esp
  8006e4:	ff 75 0c             	pushl  0xc(%ebp)
  8006e7:	6a 3f                	push   $0x3f
  8006e9:	ff 55 08             	call   *0x8(%ebp)
  8006ec:	83 c4 10             	add    $0x10,%esp
  8006ef:	eb 0d                	jmp    8006fe <vprintfmt+0x256>
				else
					putch(ch, putdat);
  8006f1:	83 ec 08             	sub    $0x8,%esp
  8006f4:	ff 75 0c             	pushl  0xc(%ebp)
  8006f7:	52                   	push   %edx
  8006f8:	ff 55 08             	call   *0x8(%ebp)
  8006fb:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006fe:	83 ef 01             	sub    $0x1,%edi
  800701:	83 c6 01             	add    $0x1,%esi
  800704:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  800708:	0f be d0             	movsbl %al,%edx
  80070b:	85 d2                	test   %edx,%edx
  80070d:	75 31                	jne    800740 <vprintfmt+0x298>
  80070f:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800712:	8b 7d 08             	mov    0x8(%ebp),%edi
  800715:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800718:	8b 75 e4             	mov    -0x1c(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80071b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80071f:	7f 33                	jg     800754 <vprintfmt+0x2ac>
  800721:	e9 96 fd ff ff       	jmp    8004bc <vprintfmt+0x14>
  800726:	89 7d 08             	mov    %edi,0x8(%ebp)
  800729:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80072c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80072f:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800732:	eb 0c                	jmp    800740 <vprintfmt+0x298>
  800734:	89 7d 08             	mov    %edi,0x8(%ebp)
  800737:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80073a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80073d:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800740:	85 db                	test   %ebx,%ebx
  800742:	78 8c                	js     8006d0 <vprintfmt+0x228>
  800744:	83 eb 01             	sub    $0x1,%ebx
  800747:	79 87                	jns    8006d0 <vprintfmt+0x228>
  800749:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  80074c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80074f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800752:	eb c4                	jmp    800718 <vprintfmt+0x270>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800754:	83 ec 08             	sub    $0x8,%esp
  800757:	53                   	push   %ebx
  800758:	6a 20                	push   $0x20
  80075a:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80075c:	83 c4 10             	add    $0x10,%esp
  80075f:	83 ee 01             	sub    $0x1,%esi
  800762:	75 f0                	jne    800754 <vprintfmt+0x2ac>
  800764:	e9 53 fd ff ff       	jmp    8004bc <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800769:	83 7d cc 01          	cmpl   $0x1,-0x34(%ebp)
  80076d:	7e 16                	jle    800785 <vprintfmt+0x2dd>
		return va_arg(*ap, long long);
  80076f:	8b 45 14             	mov    0x14(%ebp),%eax
  800772:	8d 50 08             	lea    0x8(%eax),%edx
  800775:	89 55 14             	mov    %edx,0x14(%ebp)
  800778:	8b 50 04             	mov    0x4(%eax),%edx
  80077b:	8b 00                	mov    (%eax),%eax
  80077d:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800780:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800783:	eb 34                	jmp    8007b9 <vprintfmt+0x311>
	else if (lflag)
  800785:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800789:	74 18                	je     8007a3 <vprintfmt+0x2fb>
		return va_arg(*ap, long);
  80078b:	8b 45 14             	mov    0x14(%ebp),%eax
  80078e:	8d 50 04             	lea    0x4(%eax),%edx
  800791:	89 55 14             	mov    %edx,0x14(%ebp)
  800794:	8b 30                	mov    (%eax),%esi
  800796:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800799:	89 f0                	mov    %esi,%eax
  80079b:	c1 f8 1f             	sar    $0x1f,%eax
  80079e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8007a1:	eb 16                	jmp    8007b9 <vprintfmt+0x311>
	else
		return va_arg(*ap, int);
  8007a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a6:	8d 50 04             	lea    0x4(%eax),%edx
  8007a9:	89 55 14             	mov    %edx,0x14(%ebp)
  8007ac:	8b 30                	mov    (%eax),%esi
  8007ae:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8007b1:	89 f0                	mov    %esi,%eax
  8007b3:	c1 f8 1f             	sar    $0x1f,%eax
  8007b6:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8007b9:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8007bc:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8007bf:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007c2:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  8007c5:	85 d2                	test   %edx,%edx
  8007c7:	79 28                	jns    8007f1 <vprintfmt+0x349>
				putch('-', putdat);
  8007c9:	83 ec 08             	sub    $0x8,%esp
  8007cc:	53                   	push   %ebx
  8007cd:	6a 2d                	push   $0x2d
  8007cf:	ff d7                	call   *%edi
				num = -(long long) num;
  8007d1:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8007d4:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8007d7:	f7 d8                	neg    %eax
  8007d9:	83 d2 00             	adc    $0x0,%edx
  8007dc:	f7 da                	neg    %edx
  8007de:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007e1:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007e4:	83 c4 10             	add    $0x10,%esp
			else
			{
				if(padc=='+')
					putch('+', putdat);
			}
			base = 10;
  8007e7:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007ec:	e9 a5 00 00 00       	jmp    800896 <vprintfmt+0x3ee>
  8007f1:	b8 0a 00 00 00       	mov    $0xa,%eax
				putch('-', putdat);
				num = -(long long) num;
			}
			else
			{
				if(padc=='+')
  8007f6:	80 7d e3 2b          	cmpb   $0x2b,-0x1d(%ebp)
  8007fa:	0f 85 96 00 00 00    	jne    800896 <vprintfmt+0x3ee>
					putch('+', putdat);
  800800:	83 ec 08             	sub    $0x8,%esp
  800803:	53                   	push   %ebx
  800804:	6a 2b                	push   $0x2b
  800806:	ff d7                	call   *%edi
  800808:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80080b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800810:	e9 81 00 00 00       	jmp    800896 <vprintfmt+0x3ee>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800815:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800818:	8d 45 14             	lea    0x14(%ebp),%eax
  80081b:	e8 14 fc ff ff       	call   800434 <getuint>
  800820:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800823:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  800826:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80082b:	eb 69                	jmp    800896 <vprintfmt+0x3ee>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			putch('0', putdat);
  80082d:	83 ec 08             	sub    $0x8,%esp
  800830:	53                   	push   %ebx
  800831:	6a 30                	push   $0x30
  800833:	ff d7                	call   *%edi
			num = getuint(&ap, lflag);
  800835:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800838:	8d 45 14             	lea    0x14(%ebp),%eax
  80083b:	e8 f4 fb ff ff       	call   800434 <getuint>
  800840:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800843:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
			goto number;
  800846:	83 c4 10             	add    $0x10,%esp
		case 'o':
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
  800849:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  80084e:	eb 46                	jmp    800896 <vprintfmt+0x3ee>

		// pointer
		case 'p':
			putch('0', putdat);
  800850:	83 ec 08             	sub    $0x8,%esp
  800853:	53                   	push   %ebx
  800854:	6a 30                	push   $0x30
  800856:	ff d7                	call   *%edi
			putch('x', putdat);
  800858:	83 c4 08             	add    $0x8,%esp
  80085b:	53                   	push   %ebx
  80085c:	6a 78                	push   $0x78
  80085e:	ff d7                	call   *%edi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800860:	8b 45 14             	mov    0x14(%ebp),%eax
  800863:	8d 50 04             	lea    0x4(%eax),%edx
  800866:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800869:	8b 00                	mov    (%eax),%eax
  80086b:	ba 00 00 00 00       	mov    $0x0,%edx
  800870:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800873:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800876:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800879:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80087e:	eb 16                	jmp    800896 <vprintfmt+0x3ee>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800880:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800883:	8d 45 14             	lea    0x14(%ebp),%eax
  800886:	e8 a9 fb ff ff       	call   800434 <getuint>
  80088b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80088e:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  800891:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800896:	83 ec 0c             	sub    $0xc,%esp
  800899:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  80089d:	56                   	push   %esi
  80089e:	ff 75 e4             	pushl  -0x1c(%ebp)
  8008a1:	50                   	push   %eax
  8008a2:	ff 75 dc             	pushl  -0x24(%ebp)
  8008a5:	ff 75 d8             	pushl  -0x28(%ebp)
  8008a8:	89 da                	mov    %ebx,%edx
  8008aa:	89 f8                	mov    %edi,%eax
  8008ac:	e8 e3 f9 ff ff       	call   800294 <printnum>
			break;
  8008b1:	83 c4 20             	add    $0x20,%esp
  8008b4:	e9 03 fc ff ff       	jmp    8004bc <vprintfmt+0x14>

            const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
            const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

            // Your code here
			num=(unsigned long long)(uintptr_t)va_arg(ap, void *);
  8008b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8008bc:	8d 50 04             	lea    0x4(%eax),%edx
  8008bf:	89 55 14             	mov    %edx,0x14(%ebp)
  8008c2:	8b 00                	mov    (%eax),%eax
			if(!num)
  8008c4:	85 c0                	test   %eax,%eax
  8008c6:	75 1c                	jne    8008e4 <vprintfmt+0x43c>
				*(int *)putdat+=cprintf("%s",null_error);
  8008c8:	83 ec 08             	sub    $0x8,%esp
  8008cb:	68 80 11 80 00       	push   $0x801180
  8008d0:	68 14 11 80 00       	push   $0x801114
  8008d5:	e8 a6 f9 ff ff       	call   800280 <cprintf>
  8008da:	01 03                	add    %eax,(%ebx)
  8008dc:	83 c4 10             	add    $0x10,%esp
  8008df:	e9 d8 fb ff ff       	jmp    8004bc <vprintfmt+0x14>
			else
			{
				*(char *)(int)num=*(int *)putdat;
  8008e4:	8b 13                	mov    (%ebx),%edx
  8008e6:	88 10                	mov    %dl,(%eax)
				if((*(int *)putdat)>128)
  8008e8:	81 3b 80 00 00 00    	cmpl   $0x80,(%ebx)
  8008ee:	0f 8e c8 fb ff ff    	jle    8004bc <vprintfmt+0x14>
					*(int *)putdat+=cprintf("%s",overflow_error);
  8008f4:	83 ec 08             	sub    $0x8,%esp
  8008f7:	68 b8 11 80 00       	push   $0x8011b8
  8008fc:	68 14 11 80 00       	push   $0x801114
  800901:	e8 7a f9 ff ff       	call   800280 <cprintf>
  800906:	01 03                	add    %eax,(%ebx)
  800908:	83 c4 10             	add    $0x10,%esp
  80090b:	e9 ac fb ff ff       	jmp    8004bc <vprintfmt+0x14>
            break;
        }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800910:	83 ec 08             	sub    $0x8,%esp
  800913:	53                   	push   %ebx
  800914:	52                   	push   %edx
  800915:	ff d7                	call   *%edi
			break;
  800917:	83 c4 10             	add    $0x10,%esp
  80091a:	e9 9d fb ff ff       	jmp    8004bc <vprintfmt+0x14>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80091f:	83 ec 08             	sub    $0x8,%esp
  800922:	53                   	push   %ebx
  800923:	6a 25                	push   $0x25
  800925:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800927:	83 c4 10             	add    $0x10,%esp
  80092a:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80092e:	0f 84 85 fb ff ff    	je     8004b9 <vprintfmt+0x11>
  800934:	83 ee 01             	sub    $0x1,%esi
  800937:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80093b:	75 f7                	jne    800934 <vprintfmt+0x48c>
  80093d:	89 75 10             	mov    %esi,0x10(%ebp)
  800940:	e9 77 fb ff ff       	jmp    8004bc <vprintfmt+0x14>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800945:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800948:	8d 70 01             	lea    0x1(%eax),%esi
  80094b:	0f b6 00             	movzbl (%eax),%eax
  80094e:	0f be d0             	movsbl %al,%edx
  800951:	85 d2                	test   %edx,%edx
  800953:	0f 85 db fd ff ff    	jne    800734 <vprintfmt+0x28c>
  800959:	e9 5e fb ff ff       	jmp    8004bc <vprintfmt+0x14>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  80095e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800961:	5b                   	pop    %ebx
  800962:	5e                   	pop    %esi
  800963:	5f                   	pop    %edi
  800964:	5d                   	pop    %ebp
  800965:	c3                   	ret    

00800966 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800966:	55                   	push   %ebp
  800967:	89 e5                	mov    %esp,%ebp
  800969:	83 ec 18             	sub    $0x18,%esp
  80096c:	8b 45 08             	mov    0x8(%ebp),%eax
  80096f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800972:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800975:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800979:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80097c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800983:	85 c0                	test   %eax,%eax
  800985:	74 26                	je     8009ad <vsnprintf+0x47>
  800987:	85 d2                	test   %edx,%edx
  800989:	7e 22                	jle    8009ad <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80098b:	ff 75 14             	pushl  0x14(%ebp)
  80098e:	ff 75 10             	pushl  0x10(%ebp)
  800991:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800994:	50                   	push   %eax
  800995:	68 6e 04 80 00       	push   $0x80046e
  80099a:	e8 09 fb ff ff       	call   8004a8 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80099f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8009a2:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8009a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009a8:	83 c4 10             	add    $0x10,%esp
  8009ab:	eb 05                	jmp    8009b2 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8009ad:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8009b2:	c9                   	leave  
  8009b3:	c3                   	ret    

008009b4 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8009b4:	55                   	push   %ebp
  8009b5:	89 e5                	mov    %esp,%ebp
  8009b7:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8009ba:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8009bd:	50                   	push   %eax
  8009be:	ff 75 10             	pushl  0x10(%ebp)
  8009c1:	ff 75 0c             	pushl  0xc(%ebp)
  8009c4:	ff 75 08             	pushl  0x8(%ebp)
  8009c7:	e8 9a ff ff ff       	call   800966 <vsnprintf>
	va_end(ap);

	return rc;
}
  8009cc:	c9                   	leave  
  8009cd:	c3                   	ret    

008009ce <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8009ce:	55                   	push   %ebp
  8009cf:	89 e5                	mov    %esp,%ebp
  8009d1:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8009d4:	80 3a 00             	cmpb   $0x0,(%edx)
  8009d7:	74 10                	je     8009e9 <strlen+0x1b>
  8009d9:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8009de:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8009e1:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8009e5:	75 f7                	jne    8009de <strlen+0x10>
  8009e7:	eb 05                	jmp    8009ee <strlen+0x20>
  8009e9:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8009ee:	5d                   	pop    %ebp
  8009ef:	c3                   	ret    

008009f0 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8009f0:	55                   	push   %ebp
  8009f1:	89 e5                	mov    %esp,%ebp
  8009f3:	53                   	push   %ebx
  8009f4:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8009f7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009fa:	85 c9                	test   %ecx,%ecx
  8009fc:	74 1c                	je     800a1a <strnlen+0x2a>
  8009fe:	80 3b 00             	cmpb   $0x0,(%ebx)
  800a01:	74 1e                	je     800a21 <strnlen+0x31>
  800a03:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  800a08:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a0a:	39 ca                	cmp    %ecx,%edx
  800a0c:	74 18                	je     800a26 <strnlen+0x36>
  800a0e:	83 c2 01             	add    $0x1,%edx
  800a11:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800a16:	75 f0                	jne    800a08 <strnlen+0x18>
  800a18:	eb 0c                	jmp    800a26 <strnlen+0x36>
  800a1a:	b8 00 00 00 00       	mov    $0x0,%eax
  800a1f:	eb 05                	jmp    800a26 <strnlen+0x36>
  800a21:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800a26:	5b                   	pop    %ebx
  800a27:	5d                   	pop    %ebp
  800a28:	c3                   	ret    

00800a29 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a29:	55                   	push   %ebp
  800a2a:	89 e5                	mov    %esp,%ebp
  800a2c:	53                   	push   %ebx
  800a2d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a30:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a33:	89 c2                	mov    %eax,%edx
  800a35:	83 c2 01             	add    $0x1,%edx
  800a38:	83 c1 01             	add    $0x1,%ecx
  800a3b:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800a3f:	88 5a ff             	mov    %bl,-0x1(%edx)
  800a42:	84 db                	test   %bl,%bl
  800a44:	75 ef                	jne    800a35 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800a46:	5b                   	pop    %ebx
  800a47:	5d                   	pop    %ebp
  800a48:	c3                   	ret    

00800a49 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a49:	55                   	push   %ebp
  800a4a:	89 e5                	mov    %esp,%ebp
  800a4c:	53                   	push   %ebx
  800a4d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a50:	53                   	push   %ebx
  800a51:	e8 78 ff ff ff       	call   8009ce <strlen>
  800a56:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800a59:	ff 75 0c             	pushl  0xc(%ebp)
  800a5c:	01 d8                	add    %ebx,%eax
  800a5e:	50                   	push   %eax
  800a5f:	e8 c5 ff ff ff       	call   800a29 <strcpy>
	return dst;
}
  800a64:	89 d8                	mov    %ebx,%eax
  800a66:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a69:	c9                   	leave  
  800a6a:	c3                   	ret    

00800a6b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a6b:	55                   	push   %ebp
  800a6c:	89 e5                	mov    %esp,%ebp
  800a6e:	56                   	push   %esi
  800a6f:	53                   	push   %ebx
  800a70:	8b 75 08             	mov    0x8(%ebp),%esi
  800a73:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a76:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a79:	85 db                	test   %ebx,%ebx
  800a7b:	74 17                	je     800a94 <strncpy+0x29>
  800a7d:	01 f3                	add    %esi,%ebx
  800a7f:	89 f1                	mov    %esi,%ecx
		*dst++ = *src;
  800a81:	83 c1 01             	add    $0x1,%ecx
  800a84:	0f b6 02             	movzbl (%edx),%eax
  800a87:	88 41 ff             	mov    %al,-0x1(%ecx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a8a:	80 3a 01             	cmpb   $0x1,(%edx)
  800a8d:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a90:	39 cb                	cmp    %ecx,%ebx
  800a92:	75 ed                	jne    800a81 <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a94:	89 f0                	mov    %esi,%eax
  800a96:	5b                   	pop    %ebx
  800a97:	5e                   	pop    %esi
  800a98:	5d                   	pop    %ebp
  800a99:	c3                   	ret    

00800a9a <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a9a:	55                   	push   %ebp
  800a9b:	89 e5                	mov    %esp,%ebp
  800a9d:	56                   	push   %esi
  800a9e:	53                   	push   %ebx
  800a9f:	8b 75 08             	mov    0x8(%ebp),%esi
  800aa2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800aa5:	8b 55 10             	mov    0x10(%ebp),%edx
  800aa8:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800aaa:	85 d2                	test   %edx,%edx
  800aac:	74 35                	je     800ae3 <strlcpy+0x49>
		while (--size > 0 && *src != '\0')
  800aae:	89 d0                	mov    %edx,%eax
  800ab0:	83 e8 01             	sub    $0x1,%eax
  800ab3:	74 25                	je     800ada <strlcpy+0x40>
  800ab5:	0f b6 0b             	movzbl (%ebx),%ecx
  800ab8:	84 c9                	test   %cl,%cl
  800aba:	74 22                	je     800ade <strlcpy+0x44>
  800abc:	8d 53 01             	lea    0x1(%ebx),%edx
  800abf:	01 c3                	add    %eax,%ebx
  800ac1:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
  800ac3:	83 c0 01             	add    $0x1,%eax
  800ac6:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800ac9:	39 da                	cmp    %ebx,%edx
  800acb:	74 13                	je     800ae0 <strlcpy+0x46>
  800acd:	83 c2 01             	add    $0x1,%edx
  800ad0:	0f b6 4a ff          	movzbl -0x1(%edx),%ecx
  800ad4:	84 c9                	test   %cl,%cl
  800ad6:	75 eb                	jne    800ac3 <strlcpy+0x29>
  800ad8:	eb 06                	jmp    800ae0 <strlcpy+0x46>
  800ada:	89 f0                	mov    %esi,%eax
  800adc:	eb 02                	jmp    800ae0 <strlcpy+0x46>
  800ade:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800ae0:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800ae3:	29 f0                	sub    %esi,%eax
}
  800ae5:	5b                   	pop    %ebx
  800ae6:	5e                   	pop    %esi
  800ae7:	5d                   	pop    %ebp
  800ae8:	c3                   	ret    

00800ae9 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800ae9:	55                   	push   %ebp
  800aea:	89 e5                	mov    %esp,%ebp
  800aec:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800aef:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800af2:	0f b6 01             	movzbl (%ecx),%eax
  800af5:	84 c0                	test   %al,%al
  800af7:	74 15                	je     800b0e <strcmp+0x25>
  800af9:	3a 02                	cmp    (%edx),%al
  800afb:	75 11                	jne    800b0e <strcmp+0x25>
		p++, q++;
  800afd:	83 c1 01             	add    $0x1,%ecx
  800b00:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800b03:	0f b6 01             	movzbl (%ecx),%eax
  800b06:	84 c0                	test   %al,%al
  800b08:	74 04                	je     800b0e <strcmp+0x25>
  800b0a:	3a 02                	cmp    (%edx),%al
  800b0c:	74 ef                	je     800afd <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800b0e:	0f b6 c0             	movzbl %al,%eax
  800b11:	0f b6 12             	movzbl (%edx),%edx
  800b14:	29 d0                	sub    %edx,%eax
}
  800b16:	5d                   	pop    %ebp
  800b17:	c3                   	ret    

00800b18 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b18:	55                   	push   %ebp
  800b19:	89 e5                	mov    %esp,%ebp
  800b1b:	56                   	push   %esi
  800b1c:	53                   	push   %ebx
  800b1d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800b20:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b23:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  800b26:	85 f6                	test   %esi,%esi
  800b28:	74 29                	je     800b53 <strncmp+0x3b>
  800b2a:	0f b6 03             	movzbl (%ebx),%eax
  800b2d:	84 c0                	test   %al,%al
  800b2f:	74 30                	je     800b61 <strncmp+0x49>
  800b31:	3a 02                	cmp    (%edx),%al
  800b33:	75 2c                	jne    800b61 <strncmp+0x49>
  800b35:	8d 43 01             	lea    0x1(%ebx),%eax
  800b38:	01 de                	add    %ebx,%esi
		n--, p++, q++;
  800b3a:	89 c3                	mov    %eax,%ebx
  800b3c:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800b3f:	39 c6                	cmp    %eax,%esi
  800b41:	74 17                	je     800b5a <strncmp+0x42>
  800b43:	0f b6 08             	movzbl (%eax),%ecx
  800b46:	84 c9                	test   %cl,%cl
  800b48:	74 17                	je     800b61 <strncmp+0x49>
  800b4a:	83 c0 01             	add    $0x1,%eax
  800b4d:	3a 0a                	cmp    (%edx),%cl
  800b4f:	74 e9                	je     800b3a <strncmp+0x22>
  800b51:	eb 0e                	jmp    800b61 <strncmp+0x49>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800b53:	b8 00 00 00 00       	mov    $0x0,%eax
  800b58:	eb 0f                	jmp    800b69 <strncmp+0x51>
  800b5a:	b8 00 00 00 00       	mov    $0x0,%eax
  800b5f:	eb 08                	jmp    800b69 <strncmp+0x51>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b61:	0f b6 03             	movzbl (%ebx),%eax
  800b64:	0f b6 12             	movzbl (%edx),%edx
  800b67:	29 d0                	sub    %edx,%eax
}
  800b69:	5b                   	pop    %ebx
  800b6a:	5e                   	pop    %esi
  800b6b:	5d                   	pop    %ebp
  800b6c:	c3                   	ret    

00800b6d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b6d:	55                   	push   %ebp
  800b6e:	89 e5                	mov    %esp,%ebp
  800b70:	53                   	push   %ebx
  800b71:	8b 45 08             	mov    0x8(%ebp),%eax
  800b74:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
  800b77:	0f b6 10             	movzbl (%eax),%edx
  800b7a:	84 d2                	test   %dl,%dl
  800b7c:	74 1d                	je     800b9b <strchr+0x2e>
  800b7e:	89 d9                	mov    %ebx,%ecx
		if (*s == c)
  800b80:	38 d3                	cmp    %dl,%bl
  800b82:	75 06                	jne    800b8a <strchr+0x1d>
  800b84:	eb 1a                	jmp    800ba0 <strchr+0x33>
  800b86:	38 ca                	cmp    %cl,%dl
  800b88:	74 16                	je     800ba0 <strchr+0x33>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b8a:	83 c0 01             	add    $0x1,%eax
  800b8d:	0f b6 10             	movzbl (%eax),%edx
  800b90:	84 d2                	test   %dl,%dl
  800b92:	75 f2                	jne    800b86 <strchr+0x19>
		if (*s == c)
			return (char *) s;
	return 0;
  800b94:	b8 00 00 00 00       	mov    $0x0,%eax
  800b99:	eb 05                	jmp    800ba0 <strchr+0x33>
  800b9b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ba0:	5b                   	pop    %ebx
  800ba1:	5d                   	pop    %ebp
  800ba2:	c3                   	ret    

00800ba3 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800ba3:	55                   	push   %ebp
  800ba4:	89 e5                	mov    %esp,%ebp
  800ba6:	53                   	push   %ebx
  800ba7:	8b 45 08             	mov    0x8(%ebp),%eax
  800baa:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  800bad:	0f b6 18             	movzbl (%eax),%ebx
		if (*s == c)
  800bb0:	38 d3                	cmp    %dl,%bl
  800bb2:	74 14                	je     800bc8 <strfind+0x25>
  800bb4:	89 d1                	mov    %edx,%ecx
  800bb6:	84 db                	test   %bl,%bl
  800bb8:	74 0e                	je     800bc8 <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800bba:	83 c0 01             	add    $0x1,%eax
  800bbd:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800bc0:	38 ca                	cmp    %cl,%dl
  800bc2:	74 04                	je     800bc8 <strfind+0x25>
  800bc4:	84 d2                	test   %dl,%dl
  800bc6:	75 f2                	jne    800bba <strfind+0x17>
			break;
	return (char *) s;
}
  800bc8:	5b                   	pop    %ebx
  800bc9:	5d                   	pop    %ebp
  800bca:	c3                   	ret    

00800bcb <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800bcb:	55                   	push   %ebp
  800bcc:	89 e5                	mov    %esp,%ebp
  800bce:	57                   	push   %edi
  800bcf:	56                   	push   %esi
  800bd0:	53                   	push   %ebx
  800bd1:	8b 7d 08             	mov    0x8(%ebp),%edi
  800bd4:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800bd7:	85 c9                	test   %ecx,%ecx
  800bd9:	74 36                	je     800c11 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800bdb:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800be1:	75 28                	jne    800c0b <memset+0x40>
  800be3:	f6 c1 03             	test   $0x3,%cl
  800be6:	75 23                	jne    800c0b <memset+0x40>
		c &= 0xFF;
  800be8:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800bec:	89 d3                	mov    %edx,%ebx
  800bee:	c1 e3 08             	shl    $0x8,%ebx
  800bf1:	89 d6                	mov    %edx,%esi
  800bf3:	c1 e6 18             	shl    $0x18,%esi
  800bf6:	89 d0                	mov    %edx,%eax
  800bf8:	c1 e0 10             	shl    $0x10,%eax
  800bfb:	09 f0                	or     %esi,%eax
  800bfd:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800bff:	89 d8                	mov    %ebx,%eax
  800c01:	09 d0                	or     %edx,%eax
  800c03:	c1 e9 02             	shr    $0x2,%ecx
  800c06:	fc                   	cld    
  800c07:	f3 ab                	rep stos %eax,%es:(%edi)
  800c09:	eb 06                	jmp    800c11 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800c0b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c0e:	fc                   	cld    
  800c0f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800c11:	89 f8                	mov    %edi,%eax
  800c13:	5b                   	pop    %ebx
  800c14:	5e                   	pop    %esi
  800c15:	5f                   	pop    %edi
  800c16:	5d                   	pop    %ebp
  800c17:	c3                   	ret    

00800c18 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800c18:	55                   	push   %ebp
  800c19:	89 e5                	mov    %esp,%ebp
  800c1b:	57                   	push   %edi
  800c1c:	56                   	push   %esi
  800c1d:	8b 45 08             	mov    0x8(%ebp),%eax
  800c20:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c23:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800c26:	39 c6                	cmp    %eax,%esi
  800c28:	73 35                	jae    800c5f <memmove+0x47>
  800c2a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c2d:	39 d0                	cmp    %edx,%eax
  800c2f:	73 2e                	jae    800c5f <memmove+0x47>
		s += n;
		d += n;
  800c31:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c34:	89 d6                	mov    %edx,%esi
  800c36:	09 fe                	or     %edi,%esi
  800c38:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c3e:	75 13                	jne    800c53 <memmove+0x3b>
  800c40:	f6 c1 03             	test   $0x3,%cl
  800c43:	75 0e                	jne    800c53 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800c45:	83 ef 04             	sub    $0x4,%edi
  800c48:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c4b:	c1 e9 02             	shr    $0x2,%ecx
  800c4e:	fd                   	std    
  800c4f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c51:	eb 09                	jmp    800c5c <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800c53:	83 ef 01             	sub    $0x1,%edi
  800c56:	8d 72 ff             	lea    -0x1(%edx),%esi
  800c59:	fd                   	std    
  800c5a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c5c:	fc                   	cld    
  800c5d:	eb 1d                	jmp    800c7c <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c5f:	89 f2                	mov    %esi,%edx
  800c61:	09 c2                	or     %eax,%edx
  800c63:	f6 c2 03             	test   $0x3,%dl
  800c66:	75 0f                	jne    800c77 <memmove+0x5f>
  800c68:	f6 c1 03             	test   $0x3,%cl
  800c6b:	75 0a                	jne    800c77 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800c6d:	c1 e9 02             	shr    $0x2,%ecx
  800c70:	89 c7                	mov    %eax,%edi
  800c72:	fc                   	cld    
  800c73:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c75:	eb 05                	jmp    800c7c <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c77:	89 c7                	mov    %eax,%edi
  800c79:	fc                   	cld    
  800c7a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c7c:	5e                   	pop    %esi
  800c7d:	5f                   	pop    %edi
  800c7e:	5d                   	pop    %ebp
  800c7f:	c3                   	ret    

00800c80 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800c80:	55                   	push   %ebp
  800c81:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800c83:	ff 75 10             	pushl  0x10(%ebp)
  800c86:	ff 75 0c             	pushl  0xc(%ebp)
  800c89:	ff 75 08             	pushl  0x8(%ebp)
  800c8c:	e8 87 ff ff ff       	call   800c18 <memmove>
}
  800c91:	c9                   	leave  
  800c92:	c3                   	ret    

00800c93 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c93:	55                   	push   %ebp
  800c94:	89 e5                	mov    %esp,%ebp
  800c96:	57                   	push   %edi
  800c97:	56                   	push   %esi
  800c98:	53                   	push   %ebx
  800c99:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800c9c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c9f:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ca2:	85 c0                	test   %eax,%eax
  800ca4:	74 39                	je     800cdf <memcmp+0x4c>
  800ca6:	8d 78 ff             	lea    -0x1(%eax),%edi
		if (*s1 != *s2)
  800ca9:	0f b6 13             	movzbl (%ebx),%edx
  800cac:	0f b6 0e             	movzbl (%esi),%ecx
  800caf:	38 ca                	cmp    %cl,%dl
  800cb1:	75 17                	jne    800cca <memcmp+0x37>
  800cb3:	b8 00 00 00 00       	mov    $0x0,%eax
  800cb8:	eb 1a                	jmp    800cd4 <memcmp+0x41>
  800cba:	0f b6 54 03 01       	movzbl 0x1(%ebx,%eax,1),%edx
  800cbf:	83 c0 01             	add    $0x1,%eax
  800cc2:	0f b6 0c 06          	movzbl (%esi,%eax,1),%ecx
  800cc6:	38 ca                	cmp    %cl,%dl
  800cc8:	74 0a                	je     800cd4 <memcmp+0x41>
			return (int) *s1 - (int) *s2;
  800cca:	0f b6 c2             	movzbl %dl,%eax
  800ccd:	0f b6 c9             	movzbl %cl,%ecx
  800cd0:	29 c8                	sub    %ecx,%eax
  800cd2:	eb 10                	jmp    800ce4 <memcmp+0x51>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800cd4:	39 f8                	cmp    %edi,%eax
  800cd6:	75 e2                	jne    800cba <memcmp+0x27>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800cd8:	b8 00 00 00 00       	mov    $0x0,%eax
  800cdd:	eb 05                	jmp    800ce4 <memcmp+0x51>
  800cdf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ce4:	5b                   	pop    %ebx
  800ce5:	5e                   	pop    %esi
  800ce6:	5f                   	pop    %edi
  800ce7:	5d                   	pop    %ebp
  800ce8:	c3                   	ret    

00800ce9 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ce9:	55                   	push   %ebp
  800cea:	89 e5                	mov    %esp,%ebp
  800cec:	53                   	push   %ebx
  800ced:	8b 55 08             	mov    0x8(%ebp),%edx
	const void *ends = (const char *) s + n;
  800cf0:	89 d0                	mov    %edx,%eax
  800cf2:	03 45 10             	add    0x10(%ebp),%eax
	for (; s < ends; s++)
  800cf5:	39 c2                	cmp    %eax,%edx
  800cf7:	73 1d                	jae    800d16 <memfind+0x2d>
		if (*(const unsigned char *) s == (unsigned char) c)
  800cf9:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
  800cfd:	0f b6 0a             	movzbl (%edx),%ecx
  800d00:	39 d9                	cmp    %ebx,%ecx
  800d02:	75 09                	jne    800d0d <memfind+0x24>
  800d04:	eb 14                	jmp    800d1a <memfind+0x31>
  800d06:	0f b6 0a             	movzbl (%edx),%ecx
  800d09:	39 d9                	cmp    %ebx,%ecx
  800d0b:	74 11                	je     800d1e <memfind+0x35>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800d0d:	83 c2 01             	add    $0x1,%edx
  800d10:	39 d0                	cmp    %edx,%eax
  800d12:	75 f2                	jne    800d06 <memfind+0x1d>
  800d14:	eb 0a                	jmp    800d20 <memfind+0x37>
  800d16:	89 d0                	mov    %edx,%eax
  800d18:	eb 06                	jmp    800d20 <memfind+0x37>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d1a:	89 d0                	mov    %edx,%eax
  800d1c:	eb 02                	jmp    800d20 <memfind+0x37>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800d1e:	89 d0                	mov    %edx,%eax
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800d20:	5b                   	pop    %ebx
  800d21:	5d                   	pop    %ebp
  800d22:	c3                   	ret    

00800d23 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d23:	55                   	push   %ebp
  800d24:	89 e5                	mov    %esp,%ebp
  800d26:	57                   	push   %edi
  800d27:	56                   	push   %esi
  800d28:	53                   	push   %ebx
  800d29:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d2c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d2f:	0f b6 01             	movzbl (%ecx),%eax
  800d32:	3c 20                	cmp    $0x20,%al
  800d34:	74 04                	je     800d3a <strtol+0x17>
  800d36:	3c 09                	cmp    $0x9,%al
  800d38:	75 0e                	jne    800d48 <strtol+0x25>
		s++;
  800d3a:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d3d:	0f b6 01             	movzbl (%ecx),%eax
  800d40:	3c 20                	cmp    $0x20,%al
  800d42:	74 f6                	je     800d3a <strtol+0x17>
  800d44:	3c 09                	cmp    $0x9,%al
  800d46:	74 f2                	je     800d3a <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  800d48:	3c 2b                	cmp    $0x2b,%al
  800d4a:	75 0a                	jne    800d56 <strtol+0x33>
		s++;
  800d4c:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800d4f:	bf 00 00 00 00       	mov    $0x0,%edi
  800d54:	eb 11                	jmp    800d67 <strtol+0x44>
  800d56:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800d5b:	3c 2d                	cmp    $0x2d,%al
  800d5d:	75 08                	jne    800d67 <strtol+0x44>
		s++, neg = 1;
  800d5f:	83 c1 01             	add    $0x1,%ecx
  800d62:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d67:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800d6d:	75 15                	jne    800d84 <strtol+0x61>
  800d6f:	80 39 30             	cmpb   $0x30,(%ecx)
  800d72:	75 10                	jne    800d84 <strtol+0x61>
  800d74:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800d78:	75 7c                	jne    800df6 <strtol+0xd3>
		s += 2, base = 16;
  800d7a:	83 c1 02             	add    $0x2,%ecx
  800d7d:	bb 10 00 00 00       	mov    $0x10,%ebx
  800d82:	eb 16                	jmp    800d9a <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  800d84:	85 db                	test   %ebx,%ebx
  800d86:	75 12                	jne    800d9a <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800d88:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800d8d:	80 39 30             	cmpb   $0x30,(%ecx)
  800d90:	75 08                	jne    800d9a <strtol+0x77>
		s++, base = 8;
  800d92:	83 c1 01             	add    $0x1,%ecx
  800d95:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800d9a:	b8 00 00 00 00       	mov    $0x0,%eax
  800d9f:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800da2:	0f b6 11             	movzbl (%ecx),%edx
  800da5:	8d 72 d0             	lea    -0x30(%edx),%esi
  800da8:	89 f3                	mov    %esi,%ebx
  800daa:	80 fb 09             	cmp    $0x9,%bl
  800dad:	77 08                	ja     800db7 <strtol+0x94>
			dig = *s - '0';
  800daf:	0f be d2             	movsbl %dl,%edx
  800db2:	83 ea 30             	sub    $0x30,%edx
  800db5:	eb 22                	jmp    800dd9 <strtol+0xb6>
		else if (*s >= 'a' && *s <= 'z')
  800db7:	8d 72 9f             	lea    -0x61(%edx),%esi
  800dba:	89 f3                	mov    %esi,%ebx
  800dbc:	80 fb 19             	cmp    $0x19,%bl
  800dbf:	77 08                	ja     800dc9 <strtol+0xa6>
			dig = *s - 'a' + 10;
  800dc1:	0f be d2             	movsbl %dl,%edx
  800dc4:	83 ea 57             	sub    $0x57,%edx
  800dc7:	eb 10                	jmp    800dd9 <strtol+0xb6>
		else if (*s >= 'A' && *s <= 'Z')
  800dc9:	8d 72 bf             	lea    -0x41(%edx),%esi
  800dcc:	89 f3                	mov    %esi,%ebx
  800dce:	80 fb 19             	cmp    $0x19,%bl
  800dd1:	77 16                	ja     800de9 <strtol+0xc6>
			dig = *s - 'A' + 10;
  800dd3:	0f be d2             	movsbl %dl,%edx
  800dd6:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800dd9:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ddc:	7d 0b                	jge    800de9 <strtol+0xc6>
			break;
		s++, val = (val * base) + dig;
  800dde:	83 c1 01             	add    $0x1,%ecx
  800de1:	0f af 45 10          	imul   0x10(%ebp),%eax
  800de5:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800de7:	eb b9                	jmp    800da2 <strtol+0x7f>

	if (endptr)
  800de9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ded:	74 0d                	je     800dfc <strtol+0xd9>
		*endptr = (char *) s;
  800def:	8b 75 0c             	mov    0xc(%ebp),%esi
  800df2:	89 0e                	mov    %ecx,(%esi)
  800df4:	eb 06                	jmp    800dfc <strtol+0xd9>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800df6:	85 db                	test   %ebx,%ebx
  800df8:	74 98                	je     800d92 <strtol+0x6f>
  800dfa:	eb 9e                	jmp    800d9a <strtol+0x77>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800dfc:	89 c2                	mov    %eax,%edx
  800dfe:	f7 da                	neg    %edx
  800e00:	85 ff                	test   %edi,%edi
  800e02:	0f 45 c2             	cmovne %edx,%eax
}
  800e05:	5b                   	pop    %ebx
  800e06:	5e                   	pop    %esi
  800e07:	5f                   	pop    %edi
  800e08:	5d                   	pop    %ebp
  800e09:	c3                   	ret    
  800e0a:	66 90                	xchg   %ax,%ax
  800e0c:	66 90                	xchg   %ax,%ax
  800e0e:	66 90                	xchg   %ax,%ax

00800e10 <__udivdi3>:
  800e10:	55                   	push   %ebp
  800e11:	57                   	push   %edi
  800e12:	56                   	push   %esi
  800e13:	53                   	push   %ebx
  800e14:	83 ec 1c             	sub    $0x1c,%esp
  800e17:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  800e1b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  800e1f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  800e23:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800e27:	85 f6                	test   %esi,%esi
  800e29:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800e2d:	89 ca                	mov    %ecx,%edx
  800e2f:	89 f8                	mov    %edi,%eax
  800e31:	75 3d                	jne    800e70 <__udivdi3+0x60>
  800e33:	39 cf                	cmp    %ecx,%edi
  800e35:	0f 87 c5 00 00 00    	ja     800f00 <__udivdi3+0xf0>
  800e3b:	85 ff                	test   %edi,%edi
  800e3d:	89 fd                	mov    %edi,%ebp
  800e3f:	75 0b                	jne    800e4c <__udivdi3+0x3c>
  800e41:	b8 01 00 00 00       	mov    $0x1,%eax
  800e46:	31 d2                	xor    %edx,%edx
  800e48:	f7 f7                	div    %edi
  800e4a:	89 c5                	mov    %eax,%ebp
  800e4c:	89 c8                	mov    %ecx,%eax
  800e4e:	31 d2                	xor    %edx,%edx
  800e50:	f7 f5                	div    %ebp
  800e52:	89 c1                	mov    %eax,%ecx
  800e54:	89 d8                	mov    %ebx,%eax
  800e56:	89 cf                	mov    %ecx,%edi
  800e58:	f7 f5                	div    %ebp
  800e5a:	89 c3                	mov    %eax,%ebx
  800e5c:	89 d8                	mov    %ebx,%eax
  800e5e:	89 fa                	mov    %edi,%edx
  800e60:	83 c4 1c             	add    $0x1c,%esp
  800e63:	5b                   	pop    %ebx
  800e64:	5e                   	pop    %esi
  800e65:	5f                   	pop    %edi
  800e66:	5d                   	pop    %ebp
  800e67:	c3                   	ret    
  800e68:	90                   	nop
  800e69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e70:	39 ce                	cmp    %ecx,%esi
  800e72:	77 74                	ja     800ee8 <__udivdi3+0xd8>
  800e74:	0f bd fe             	bsr    %esi,%edi
  800e77:	83 f7 1f             	xor    $0x1f,%edi
  800e7a:	0f 84 98 00 00 00    	je     800f18 <__udivdi3+0x108>
  800e80:	bb 20 00 00 00       	mov    $0x20,%ebx
  800e85:	89 f9                	mov    %edi,%ecx
  800e87:	89 c5                	mov    %eax,%ebp
  800e89:	29 fb                	sub    %edi,%ebx
  800e8b:	d3 e6                	shl    %cl,%esi
  800e8d:	89 d9                	mov    %ebx,%ecx
  800e8f:	d3 ed                	shr    %cl,%ebp
  800e91:	89 f9                	mov    %edi,%ecx
  800e93:	d3 e0                	shl    %cl,%eax
  800e95:	09 ee                	or     %ebp,%esi
  800e97:	89 d9                	mov    %ebx,%ecx
  800e99:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800e9d:	89 d5                	mov    %edx,%ebp
  800e9f:	8b 44 24 08          	mov    0x8(%esp),%eax
  800ea3:	d3 ed                	shr    %cl,%ebp
  800ea5:	89 f9                	mov    %edi,%ecx
  800ea7:	d3 e2                	shl    %cl,%edx
  800ea9:	89 d9                	mov    %ebx,%ecx
  800eab:	d3 e8                	shr    %cl,%eax
  800ead:	09 c2                	or     %eax,%edx
  800eaf:	89 d0                	mov    %edx,%eax
  800eb1:	89 ea                	mov    %ebp,%edx
  800eb3:	f7 f6                	div    %esi
  800eb5:	89 d5                	mov    %edx,%ebp
  800eb7:	89 c3                	mov    %eax,%ebx
  800eb9:	f7 64 24 0c          	mull   0xc(%esp)
  800ebd:	39 d5                	cmp    %edx,%ebp
  800ebf:	72 10                	jb     800ed1 <__udivdi3+0xc1>
  800ec1:	8b 74 24 08          	mov    0x8(%esp),%esi
  800ec5:	89 f9                	mov    %edi,%ecx
  800ec7:	d3 e6                	shl    %cl,%esi
  800ec9:	39 c6                	cmp    %eax,%esi
  800ecb:	73 07                	jae    800ed4 <__udivdi3+0xc4>
  800ecd:	39 d5                	cmp    %edx,%ebp
  800ecf:	75 03                	jne    800ed4 <__udivdi3+0xc4>
  800ed1:	83 eb 01             	sub    $0x1,%ebx
  800ed4:	31 ff                	xor    %edi,%edi
  800ed6:	89 d8                	mov    %ebx,%eax
  800ed8:	89 fa                	mov    %edi,%edx
  800eda:	83 c4 1c             	add    $0x1c,%esp
  800edd:	5b                   	pop    %ebx
  800ede:	5e                   	pop    %esi
  800edf:	5f                   	pop    %edi
  800ee0:	5d                   	pop    %ebp
  800ee1:	c3                   	ret    
  800ee2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800ee8:	31 ff                	xor    %edi,%edi
  800eea:	31 db                	xor    %ebx,%ebx
  800eec:	89 d8                	mov    %ebx,%eax
  800eee:	89 fa                	mov    %edi,%edx
  800ef0:	83 c4 1c             	add    $0x1c,%esp
  800ef3:	5b                   	pop    %ebx
  800ef4:	5e                   	pop    %esi
  800ef5:	5f                   	pop    %edi
  800ef6:	5d                   	pop    %ebp
  800ef7:	c3                   	ret    
  800ef8:	90                   	nop
  800ef9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f00:	89 d8                	mov    %ebx,%eax
  800f02:	f7 f7                	div    %edi
  800f04:	31 ff                	xor    %edi,%edi
  800f06:	89 c3                	mov    %eax,%ebx
  800f08:	89 d8                	mov    %ebx,%eax
  800f0a:	89 fa                	mov    %edi,%edx
  800f0c:	83 c4 1c             	add    $0x1c,%esp
  800f0f:	5b                   	pop    %ebx
  800f10:	5e                   	pop    %esi
  800f11:	5f                   	pop    %edi
  800f12:	5d                   	pop    %ebp
  800f13:	c3                   	ret    
  800f14:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f18:	39 ce                	cmp    %ecx,%esi
  800f1a:	72 0c                	jb     800f28 <__udivdi3+0x118>
  800f1c:	31 db                	xor    %ebx,%ebx
  800f1e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  800f22:	0f 87 34 ff ff ff    	ja     800e5c <__udivdi3+0x4c>
  800f28:	bb 01 00 00 00       	mov    $0x1,%ebx
  800f2d:	e9 2a ff ff ff       	jmp    800e5c <__udivdi3+0x4c>
  800f32:	66 90                	xchg   %ax,%ax
  800f34:	66 90                	xchg   %ax,%ax
  800f36:	66 90                	xchg   %ax,%ax
  800f38:	66 90                	xchg   %ax,%ax
  800f3a:	66 90                	xchg   %ax,%ax
  800f3c:	66 90                	xchg   %ax,%ax
  800f3e:	66 90                	xchg   %ax,%ax

00800f40 <__umoddi3>:
  800f40:	55                   	push   %ebp
  800f41:	57                   	push   %edi
  800f42:	56                   	push   %esi
  800f43:	53                   	push   %ebx
  800f44:	83 ec 1c             	sub    $0x1c,%esp
  800f47:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800f4b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  800f4f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800f53:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800f57:	85 d2                	test   %edx,%edx
  800f59:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800f5d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800f61:	89 f3                	mov    %esi,%ebx
  800f63:	89 3c 24             	mov    %edi,(%esp)
  800f66:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f6a:	75 1c                	jne    800f88 <__umoddi3+0x48>
  800f6c:	39 f7                	cmp    %esi,%edi
  800f6e:	76 50                	jbe    800fc0 <__umoddi3+0x80>
  800f70:	89 c8                	mov    %ecx,%eax
  800f72:	89 f2                	mov    %esi,%edx
  800f74:	f7 f7                	div    %edi
  800f76:	89 d0                	mov    %edx,%eax
  800f78:	31 d2                	xor    %edx,%edx
  800f7a:	83 c4 1c             	add    $0x1c,%esp
  800f7d:	5b                   	pop    %ebx
  800f7e:	5e                   	pop    %esi
  800f7f:	5f                   	pop    %edi
  800f80:	5d                   	pop    %ebp
  800f81:	c3                   	ret    
  800f82:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800f88:	39 f2                	cmp    %esi,%edx
  800f8a:	89 d0                	mov    %edx,%eax
  800f8c:	77 52                	ja     800fe0 <__umoddi3+0xa0>
  800f8e:	0f bd ea             	bsr    %edx,%ebp
  800f91:	83 f5 1f             	xor    $0x1f,%ebp
  800f94:	75 5a                	jne    800ff0 <__umoddi3+0xb0>
  800f96:	3b 54 24 04          	cmp    0x4(%esp),%edx
  800f9a:	0f 82 e0 00 00 00    	jb     801080 <__umoddi3+0x140>
  800fa0:	39 0c 24             	cmp    %ecx,(%esp)
  800fa3:	0f 86 d7 00 00 00    	jbe    801080 <__umoddi3+0x140>
  800fa9:	8b 44 24 08          	mov    0x8(%esp),%eax
  800fad:	8b 54 24 04          	mov    0x4(%esp),%edx
  800fb1:	83 c4 1c             	add    $0x1c,%esp
  800fb4:	5b                   	pop    %ebx
  800fb5:	5e                   	pop    %esi
  800fb6:	5f                   	pop    %edi
  800fb7:	5d                   	pop    %ebp
  800fb8:	c3                   	ret    
  800fb9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800fc0:	85 ff                	test   %edi,%edi
  800fc2:	89 fd                	mov    %edi,%ebp
  800fc4:	75 0b                	jne    800fd1 <__umoddi3+0x91>
  800fc6:	b8 01 00 00 00       	mov    $0x1,%eax
  800fcb:	31 d2                	xor    %edx,%edx
  800fcd:	f7 f7                	div    %edi
  800fcf:	89 c5                	mov    %eax,%ebp
  800fd1:	89 f0                	mov    %esi,%eax
  800fd3:	31 d2                	xor    %edx,%edx
  800fd5:	f7 f5                	div    %ebp
  800fd7:	89 c8                	mov    %ecx,%eax
  800fd9:	f7 f5                	div    %ebp
  800fdb:	89 d0                	mov    %edx,%eax
  800fdd:	eb 99                	jmp    800f78 <__umoddi3+0x38>
  800fdf:	90                   	nop
  800fe0:	89 c8                	mov    %ecx,%eax
  800fe2:	89 f2                	mov    %esi,%edx
  800fe4:	83 c4 1c             	add    $0x1c,%esp
  800fe7:	5b                   	pop    %ebx
  800fe8:	5e                   	pop    %esi
  800fe9:	5f                   	pop    %edi
  800fea:	5d                   	pop    %ebp
  800feb:	c3                   	ret    
  800fec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800ff0:	8b 34 24             	mov    (%esp),%esi
  800ff3:	bf 20 00 00 00       	mov    $0x20,%edi
  800ff8:	89 e9                	mov    %ebp,%ecx
  800ffa:	29 ef                	sub    %ebp,%edi
  800ffc:	d3 e0                	shl    %cl,%eax
  800ffe:	89 f9                	mov    %edi,%ecx
  801000:	89 f2                	mov    %esi,%edx
  801002:	d3 ea                	shr    %cl,%edx
  801004:	89 e9                	mov    %ebp,%ecx
  801006:	09 c2                	or     %eax,%edx
  801008:	89 d8                	mov    %ebx,%eax
  80100a:	89 14 24             	mov    %edx,(%esp)
  80100d:	89 f2                	mov    %esi,%edx
  80100f:	d3 e2                	shl    %cl,%edx
  801011:	89 f9                	mov    %edi,%ecx
  801013:	89 54 24 04          	mov    %edx,0x4(%esp)
  801017:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80101b:	d3 e8                	shr    %cl,%eax
  80101d:	89 e9                	mov    %ebp,%ecx
  80101f:	89 c6                	mov    %eax,%esi
  801021:	d3 e3                	shl    %cl,%ebx
  801023:	89 f9                	mov    %edi,%ecx
  801025:	89 d0                	mov    %edx,%eax
  801027:	d3 e8                	shr    %cl,%eax
  801029:	89 e9                	mov    %ebp,%ecx
  80102b:	09 d8                	or     %ebx,%eax
  80102d:	89 d3                	mov    %edx,%ebx
  80102f:	89 f2                	mov    %esi,%edx
  801031:	f7 34 24             	divl   (%esp)
  801034:	89 d6                	mov    %edx,%esi
  801036:	d3 e3                	shl    %cl,%ebx
  801038:	f7 64 24 04          	mull   0x4(%esp)
  80103c:	39 d6                	cmp    %edx,%esi
  80103e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801042:	89 d1                	mov    %edx,%ecx
  801044:	89 c3                	mov    %eax,%ebx
  801046:	72 08                	jb     801050 <__umoddi3+0x110>
  801048:	75 11                	jne    80105b <__umoddi3+0x11b>
  80104a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80104e:	73 0b                	jae    80105b <__umoddi3+0x11b>
  801050:	2b 44 24 04          	sub    0x4(%esp),%eax
  801054:	1b 14 24             	sbb    (%esp),%edx
  801057:	89 d1                	mov    %edx,%ecx
  801059:	89 c3                	mov    %eax,%ebx
  80105b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80105f:	29 da                	sub    %ebx,%edx
  801061:	19 ce                	sbb    %ecx,%esi
  801063:	89 f9                	mov    %edi,%ecx
  801065:	89 f0                	mov    %esi,%eax
  801067:	d3 e0                	shl    %cl,%eax
  801069:	89 e9                	mov    %ebp,%ecx
  80106b:	d3 ea                	shr    %cl,%edx
  80106d:	89 e9                	mov    %ebp,%ecx
  80106f:	d3 ee                	shr    %cl,%esi
  801071:	09 d0                	or     %edx,%eax
  801073:	89 f2                	mov    %esi,%edx
  801075:	83 c4 1c             	add    $0x1c,%esp
  801078:	5b                   	pop    %ebx
  801079:	5e                   	pop    %esi
  80107a:	5f                   	pop    %edi
  80107b:	5d                   	pop    %ebp
  80107c:	c3                   	ret    
  80107d:	8d 76 00             	lea    0x0(%esi),%esi
  801080:	29 f9                	sub    %edi,%ecx
  801082:	19 d6                	sbb    %edx,%esi
  801084:	89 74 24 04          	mov    %esi,0x4(%esp)
  801088:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80108c:	e9 18 ff ff ff       	jmp    800fa9 <__umoddi3+0x69>
