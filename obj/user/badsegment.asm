
obj/user/badsegment:     file format elf32-i386


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
  80002c:	e8 0d 00 00 00       	call   80003e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	// Try to load the kernel's TSS selector into the DS register.
	asm volatile("movw $0x28,%ax; movw %ax,%ds");
  800036:	66 b8 28 00          	mov    $0x28,%ax
  80003a:	8e d8                	mov    %eax,%ds
}
  80003c:	5d                   	pop    %ebp
  80003d:	c3                   	ret    

0080003e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80003e:	55                   	push   %ebp
  80003f:	89 e5                	mov    %esp,%ebp
  800041:	83 ec 08             	sub    $0x8,%esp
  800044:	8b 45 08             	mov    0x8(%ebp),%eax
  800047:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  80004a:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800051:	00 00 00 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800054:	85 c0                	test   %eax,%eax
  800056:	7e 08                	jle    800060 <libmain+0x22>
		binaryname = argv[0];
  800058:	8b 0a                	mov    (%edx),%ecx
  80005a:	89 0d 00 20 80 00    	mov    %ecx,0x802000

	// call user main routine
	umain(argc, argv);
  800060:	83 ec 08             	sub    $0x8,%esp
  800063:	52                   	push   %edx
  800064:	50                   	push   %eax
  800065:	e8 c9 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80006a:	e8 05 00 00 00       	call   800074 <exit>
}
  80006f:	83 c4 10             	add    $0x10,%esp
  800072:	c9                   	leave  
  800073:	c3                   	ret    

00800074 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800074:	55                   	push   %ebp
  800075:	89 e5                	mov    %esp,%ebp
  800077:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80007a:	6a 00                	push   $0x0
  80007c:	e8 52 00 00 00       	call   8000d3 <sys_env_destroy>
}
  800081:	83 c4 10             	add    $0x10,%esp
  800084:	c9                   	leave  
  800085:	c3                   	ret    

00800086 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800086:	55                   	push   %ebp
  800087:	89 e5                	mov    %esp,%ebp
  800089:	57                   	push   %edi
  80008a:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80008b:	b8 00 00 00 00       	mov    $0x0,%eax
  800090:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800093:	8b 55 08             	mov    0x8(%ebp),%edx
  800096:	89 c3                	mov    %eax,%ebx
  800098:	89 c7                	mov    %eax,%edi
  80009a:	51                   	push   %ecx
  80009b:	52                   	push   %edx
  80009c:	53                   	push   %ebx
  80009d:	54                   	push   %esp
  80009e:	55                   	push   %ebp
  80009f:	56                   	push   %esi
  8000a0:	57                   	push   %edi
  8000a1:	5f                   	pop    %edi
  8000a2:	5e                   	pop    %esi
  8000a3:	5d                   	pop    %ebp
  8000a4:	5c                   	pop    %esp
  8000a5:	5b                   	pop    %ebx
  8000a6:	5a                   	pop    %edx
  8000a7:	59                   	pop    %ecx

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000a8:	5b                   	pop    %ebx
  8000a9:	5f                   	pop    %edi
  8000aa:	5d                   	pop    %ebp
  8000ab:	c3                   	ret    

008000ac <sys_cgetc>:

int
sys_cgetc(void)
{
  8000ac:	55                   	push   %ebp
  8000ad:	89 e5                	mov    %esp,%ebp
  8000af:	57                   	push   %edi
  8000b0:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8000b1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000b6:	b8 01 00 00 00       	mov    $0x1,%eax
  8000bb:	89 ca                	mov    %ecx,%edx
  8000bd:	89 cb                	mov    %ecx,%ebx
  8000bf:	89 cf                	mov    %ecx,%edi
  8000c1:	51                   	push   %ecx
  8000c2:	52                   	push   %edx
  8000c3:	53                   	push   %ebx
  8000c4:	54                   	push   %esp
  8000c5:	55                   	push   %ebp
  8000c6:	56                   	push   %esi
  8000c7:	57                   	push   %edi
  8000c8:	5f                   	pop    %edi
  8000c9:	5e                   	pop    %esi
  8000ca:	5d                   	pop    %ebp
  8000cb:	5c                   	pop    %esp
  8000cc:	5b                   	pop    %ebx
  8000cd:	5a                   	pop    %edx
  8000ce:	59                   	pop    %ecx

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000cf:	5b                   	pop    %ebx
  8000d0:	5f                   	pop    %edi
  8000d1:	5d                   	pop    %ebp
  8000d2:	c3                   	ret    

008000d3 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000d3:	55                   	push   %ebp
  8000d4:	89 e5                	mov    %esp,%ebp
  8000d6:	57                   	push   %edi
  8000d7:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8000d8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8000dd:	b8 03 00 00 00       	mov    $0x3,%eax
  8000e2:	8b 55 08             	mov    0x8(%ebp),%edx
  8000e5:	89 d9                	mov    %ebx,%ecx
  8000e7:	89 df                	mov    %ebx,%edi
  8000e9:	51                   	push   %ecx
  8000ea:	52                   	push   %edx
  8000eb:	53                   	push   %ebx
  8000ec:	54                   	push   %esp
  8000ed:	55                   	push   %ebp
  8000ee:	56                   	push   %esi
  8000ef:	57                   	push   %edi
  8000f0:	5f                   	pop    %edi
  8000f1:	5e                   	pop    %esi
  8000f2:	5d                   	pop    %ebp
  8000f3:	5c                   	pop    %esp
  8000f4:	5b                   	pop    %ebx
  8000f5:	5a                   	pop    %edx
  8000f6:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  8000f7:	85 c0                	test   %eax,%eax
  8000f9:	7e 17                	jle    800112 <sys_env_destroy+0x3f>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000fb:	83 ec 0c             	sub    $0xc,%esp
  8000fe:	50                   	push   %eax
  8000ff:	6a 03                	push   $0x3
  800101:	68 9e 10 80 00       	push   $0x80109e
  800106:	6a 26                	push   $0x26
  800108:	68 bb 10 80 00       	push   $0x8010bb
  80010d:	e8 7f 00 00 00       	call   800191 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800112:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800115:	5b                   	pop    %ebx
  800116:	5f                   	pop    %edi
  800117:	5d                   	pop    %ebp
  800118:	c3                   	ret    

00800119 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800119:	55                   	push   %ebp
  80011a:	89 e5                	mov    %esp,%ebp
  80011c:	57                   	push   %edi
  80011d:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80011e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800123:	b8 02 00 00 00       	mov    $0x2,%eax
  800128:	89 ca                	mov    %ecx,%edx
  80012a:	89 cb                	mov    %ecx,%ebx
  80012c:	89 cf                	mov    %ecx,%edi
  80012e:	51                   	push   %ecx
  80012f:	52                   	push   %edx
  800130:	53                   	push   %ebx
  800131:	54                   	push   %esp
  800132:	55                   	push   %ebp
  800133:	56                   	push   %esi
  800134:	57                   	push   %edi
  800135:	5f                   	pop    %edi
  800136:	5e                   	pop    %esi
  800137:	5d                   	pop    %ebp
  800138:	5c                   	pop    %esp
  800139:	5b                   	pop    %ebx
  80013a:	5a                   	pop    %edx
  80013b:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80013c:	5b                   	pop    %ebx
  80013d:	5f                   	pop    %edi
  80013e:	5d                   	pop    %ebp
  80013f:	c3                   	ret    

00800140 <sys_map_kernel_page>:

int
sys_map_kernel_page(void* kpage, void* va)
{
  800140:	55                   	push   %ebp
  800141:	89 e5                	mov    %esp,%ebp
  800143:	57                   	push   %edi
  800144:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800145:	bf 00 00 00 00       	mov    $0x0,%edi
  80014a:	b8 04 00 00 00       	mov    $0x4,%eax
  80014f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800152:	8b 55 08             	mov    0x8(%ebp),%edx
  800155:	89 fb                	mov    %edi,%ebx
  800157:	51                   	push   %ecx
  800158:	52                   	push   %edx
  800159:	53                   	push   %ebx
  80015a:	54                   	push   %esp
  80015b:	55                   	push   %ebp
  80015c:	56                   	push   %esi
  80015d:	57                   	push   %edi
  80015e:	5f                   	pop    %edi
  80015f:	5e                   	pop    %esi
  800160:	5d                   	pop    %ebp
  800161:	5c                   	pop    %esp
  800162:	5b                   	pop    %ebx
  800163:	5a                   	pop    %edx
  800164:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  800165:	5b                   	pop    %ebx
  800166:	5f                   	pop    %edi
  800167:	5d                   	pop    %ebp
  800168:	c3                   	ret    

00800169 <sys_sbrk>:

int
sys_sbrk(uint32_t inc)
{
  800169:	55                   	push   %ebp
  80016a:	89 e5                	mov    %esp,%ebp
  80016c:	57                   	push   %edi
  80016d:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  80016e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800173:	b8 05 00 00 00       	mov    $0x5,%eax
  800178:	8b 55 08             	mov    0x8(%ebp),%edx
  80017b:	89 cb                	mov    %ecx,%ebx
  80017d:	89 cf                	mov    %ecx,%edi
  80017f:	51                   	push   %ecx
  800180:	52                   	push   %edx
  800181:	53                   	push   %ebx
  800182:	54                   	push   %esp
  800183:	55                   	push   %ebp
  800184:	56                   	push   %esi
  800185:	57                   	push   %edi
  800186:	5f                   	pop    %edi
  800187:	5e                   	pop    %esi
  800188:	5d                   	pop    %ebp
  800189:	5c                   	pop    %esp
  80018a:	5b                   	pop    %ebx
  80018b:	5a                   	pop    %edx
  80018c:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  80018d:	5b                   	pop    %ebx
  80018e:	5f                   	pop    %edi
  80018f:	5d                   	pop    %ebp
  800190:	c3                   	ret    

00800191 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800191:	55                   	push   %ebp
  800192:	89 e5                	mov    %esp,%ebp
  800194:	56                   	push   %esi
  800195:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800196:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	if (argv0)
  800199:	a1 08 20 80 00       	mov    0x802008,%eax
  80019e:	85 c0                	test   %eax,%eax
  8001a0:	74 11                	je     8001b3 <_panic+0x22>
		cprintf("%s: ", argv0);
  8001a2:	83 ec 08             	sub    $0x8,%esp
  8001a5:	50                   	push   %eax
  8001a6:	68 c9 10 80 00       	push   $0x8010c9
  8001ab:	e8 d4 00 00 00       	call   800284 <cprintf>
  8001b0:	83 c4 10             	add    $0x10,%esp
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001b3:	8b 35 00 20 80 00    	mov    0x802000,%esi
  8001b9:	e8 5b ff ff ff       	call   800119 <sys_getenvid>
  8001be:	83 ec 0c             	sub    $0xc,%esp
  8001c1:	ff 75 0c             	pushl  0xc(%ebp)
  8001c4:	ff 75 08             	pushl  0x8(%ebp)
  8001c7:	56                   	push   %esi
  8001c8:	50                   	push   %eax
  8001c9:	68 d0 10 80 00       	push   $0x8010d0
  8001ce:	e8 b1 00 00 00       	call   800284 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001d3:	83 c4 18             	add    $0x18,%esp
  8001d6:	53                   	push   %ebx
  8001d7:	ff 75 10             	pushl  0x10(%ebp)
  8001da:	e8 54 00 00 00       	call   800233 <vcprintf>
	cprintf("\n");
  8001df:	c7 04 24 ce 10 80 00 	movl   $0x8010ce,(%esp)
  8001e6:	e8 99 00 00 00       	call   800284 <cprintf>
  8001eb:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001ee:	cc                   	int3   
  8001ef:	eb fd                	jmp    8001ee <_panic+0x5d>

008001f1 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001f1:	55                   	push   %ebp
  8001f2:	89 e5                	mov    %esp,%ebp
  8001f4:	53                   	push   %ebx
  8001f5:	83 ec 04             	sub    $0x4,%esp
  8001f8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001fb:	8b 13                	mov    (%ebx),%edx
  8001fd:	8d 42 01             	lea    0x1(%edx),%eax
  800200:	89 03                	mov    %eax,(%ebx)
  800202:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800205:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800209:	3d ff 00 00 00       	cmp    $0xff,%eax
  80020e:	75 1a                	jne    80022a <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800210:	83 ec 08             	sub    $0x8,%esp
  800213:	68 ff 00 00 00       	push   $0xff
  800218:	8d 43 08             	lea    0x8(%ebx),%eax
  80021b:	50                   	push   %eax
  80021c:	e8 65 fe ff ff       	call   800086 <sys_cputs>
		b->idx = 0;
  800221:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800227:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80022a:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80022e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800231:	c9                   	leave  
  800232:	c3                   	ret    

00800233 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800233:	55                   	push   %ebp
  800234:	89 e5                	mov    %esp,%ebp
  800236:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80023c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800243:	00 00 00 
	b.cnt = 0;
  800246:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80024d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800250:	ff 75 0c             	pushl  0xc(%ebp)
  800253:	ff 75 08             	pushl  0x8(%ebp)
  800256:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80025c:	50                   	push   %eax
  80025d:	68 f1 01 80 00       	push   $0x8001f1
  800262:	e8 45 02 00 00       	call   8004ac <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800267:	83 c4 08             	add    $0x8,%esp
  80026a:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800270:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800276:	50                   	push   %eax
  800277:	e8 0a fe ff ff       	call   800086 <sys_cputs>

	return b.cnt;
}
  80027c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800282:	c9                   	leave  
  800283:	c3                   	ret    

00800284 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800284:	55                   	push   %ebp
  800285:	89 e5                	mov    %esp,%ebp
  800287:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80028a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80028d:	50                   	push   %eax
  80028e:	ff 75 08             	pushl  0x8(%ebp)
  800291:	e8 9d ff ff ff       	call   800233 <vcprintf>
	va_end(ap);

	return cnt;
}
  800296:	c9                   	leave  
  800297:	c3                   	ret    

00800298 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800298:	55                   	push   %ebp
  800299:	89 e5                	mov    %esp,%ebp
  80029b:	57                   	push   %edi
  80029c:	56                   	push   %esi
  80029d:	53                   	push   %ebx
  80029e:	83 ec 1c             	sub    $0x1c,%esp
  8002a1:	89 c7                	mov    %eax,%edi
  8002a3:	89 d6                	mov    %edx,%esi
  8002a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8002a8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002ab:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002ae:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	// if cprintf'parameter includes pattern of the form "%-", padding
	// space on the right side if neccesary.
	// you can add helper function if needed.
	// your code here:
	int length,showsign=0;
	if(padc=='-'&&num>=base)
  8002b1:	83 7d 18 2d          	cmpl   $0x2d,0x18(%ebp)
  8002b5:	0f 85 8a 00 00 00    	jne    800345 <printnum+0xad>
  8002bb:	8b 45 10             	mov    0x10(%ebp),%eax
  8002be:	ba 00 00 00 00       	mov    $0x0,%edx
  8002c3:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8002c6:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8002c9:	39 da                	cmp    %ebx,%edx
  8002cb:	72 09                	jb     8002d6 <printnum+0x3e>
  8002cd:	39 4d 10             	cmp    %ecx,0x10(%ebp)
  8002d0:	0f 87 87 00 00 00    	ja     80035d <printnum+0xc5>
	{
		length=*(int *)putdat;
  8002d6:	8b 1e                	mov    (%esi),%ebx
		printnum(putch,putdat,num/base,base,0,padc);
  8002d8:	83 ec 0c             	sub    $0xc,%esp
  8002db:	6a 2d                	push   $0x2d
  8002dd:	6a 00                	push   $0x0
  8002df:	ff 75 10             	pushl  0x10(%ebp)
  8002e2:	83 ec 08             	sub    $0x8,%esp
  8002e5:	52                   	push   %edx
  8002e6:	50                   	push   %eax
  8002e7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002ea:	ff 75 e0             	pushl  -0x20(%ebp)
  8002ed:	e8 1e 0b 00 00       	call   800e10 <__udivdi3>
  8002f2:	83 c4 18             	add    $0x18,%esp
  8002f5:	52                   	push   %edx
  8002f6:	50                   	push   %eax
  8002f7:	89 f2                	mov    %esi,%edx
  8002f9:	89 f8                	mov    %edi,%eax
  8002fb:	e8 98 ff ff ff       	call   800298 <printnum>
		while (--width > 0)
			putch(padc, putdat);
	}
	}
	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800300:	83 c4 18             	add    $0x18,%esp
  800303:	56                   	push   %esi
  800304:	8b 45 10             	mov    0x10(%ebp),%eax
  800307:	ba 00 00 00 00       	mov    $0x0,%edx
  80030c:	83 ec 04             	sub    $0x4,%esp
  80030f:	52                   	push   %edx
  800310:	50                   	push   %eax
  800311:	ff 75 e4             	pushl  -0x1c(%ebp)
  800314:	ff 75 e0             	pushl  -0x20(%ebp)
  800317:	e8 24 0c 00 00       	call   800f40 <__umoddi3>
  80031c:	83 c4 14             	add    $0x14,%esp
  80031f:	0f be 80 f3 10 80 00 	movsbl 0x8010f3(%eax),%eax
  800326:	50                   	push   %eax
  800327:	ff d7                	call   *%edi
	
	if(padc=='-'&&width>0)
  800329:	83 c4 10             	add    $0x10,%esp
  80032c:	83 7d 18 2d          	cmpl   $0x2d,0x18(%ebp)
  800330:	0f 85 fa 00 00 00    	jne    800430 <printnum+0x198>
  800336:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
  80033a:	0f 8f 9b 00 00 00    	jg     8003db <printnum+0x143>
  800340:	e9 eb 00 00 00       	jmp    800430 <printnum+0x198>
	}
	else
	{
	
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800345:	8b 45 10             	mov    0x10(%ebp),%eax
  800348:	ba 00 00 00 00       	mov    $0x0,%edx
  80034d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800350:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800353:	83 fb 00             	cmp    $0x0,%ebx
  800356:	77 14                	ja     80036c <printnum+0xd4>
  800358:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  80035b:	73 0f                	jae    80036c <printnum+0xd4>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80035d:	8b 45 14             	mov    0x14(%ebp),%eax
  800360:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800363:	85 db                	test   %ebx,%ebx
  800365:	7f 61                	jg     8003c8 <printnum+0x130>
  800367:	e9 98 00 00 00       	jmp    800404 <printnum+0x16c>
	else
	{
	
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80036c:	83 ec 0c             	sub    $0xc,%esp
  80036f:	ff 75 18             	pushl  0x18(%ebp)
  800372:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800375:	8d 59 ff             	lea    -0x1(%ecx),%ebx
  800378:	53                   	push   %ebx
  800379:	ff 75 10             	pushl  0x10(%ebp)
  80037c:	83 ec 08             	sub    $0x8,%esp
  80037f:	52                   	push   %edx
  800380:	50                   	push   %eax
  800381:	ff 75 e4             	pushl  -0x1c(%ebp)
  800384:	ff 75 e0             	pushl  -0x20(%ebp)
  800387:	e8 84 0a 00 00       	call   800e10 <__udivdi3>
  80038c:	83 c4 18             	add    $0x18,%esp
  80038f:	52                   	push   %edx
  800390:	50                   	push   %eax
  800391:	89 f2                	mov    %esi,%edx
  800393:	89 f8                	mov    %edi,%eax
  800395:	e8 fe fe ff ff       	call   800298 <printnum>
		while (--width > 0)
			putch(padc, putdat);
	}
	}
	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80039a:	83 c4 18             	add    $0x18,%esp
  80039d:	56                   	push   %esi
  80039e:	8b 45 10             	mov    0x10(%ebp),%eax
  8003a1:	ba 00 00 00 00       	mov    $0x0,%edx
  8003a6:	83 ec 04             	sub    $0x4,%esp
  8003a9:	52                   	push   %edx
  8003aa:	50                   	push   %eax
  8003ab:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003ae:	ff 75 e0             	pushl  -0x20(%ebp)
  8003b1:	e8 8a 0b 00 00       	call   800f40 <__umoddi3>
  8003b6:	83 c4 14             	add    $0x14,%esp
  8003b9:	0f be 80 f3 10 80 00 	movsbl 0x8010f3(%eax),%eax
  8003c0:	50                   	push   %eax
  8003c1:	ff d7                	call   *%edi
  8003c3:	83 c4 10             	add    $0x10,%esp
  8003c6:	eb 68                	jmp    800430 <printnum+0x198>
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8003c8:	83 ec 08             	sub    $0x8,%esp
  8003cb:	56                   	push   %esi
  8003cc:	ff 75 18             	pushl  0x18(%ebp)
  8003cf:	ff d7                	call   *%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003d1:	83 c4 10             	add    $0x10,%esp
  8003d4:	83 eb 01             	sub    $0x1,%ebx
  8003d7:	75 ef                	jne    8003c8 <printnum+0x130>
  8003d9:	eb 29                	jmp    800404 <printnum+0x16c>
	putch("0123456789abcdef"[num % base], putdat);
	
	if(padc=='-'&&width>0)
	{
		length=*(int *)putdat-length;
		for(int i=0;i<width-length;++i)
  8003db:	8b 45 14             	mov    0x14(%ebp),%eax
  8003de:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  8003e1:	2b 06                	sub    (%esi),%eax
  8003e3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003e6:	85 c0                	test   %eax,%eax
  8003e8:	7e 46                	jle    800430 <printnum+0x198>
  8003ea:	bb 00 00 00 00       	mov    $0x0,%ebx
			putch(' ',putdat);
  8003ef:	83 ec 08             	sub    $0x8,%esp
  8003f2:	56                   	push   %esi
  8003f3:	6a 20                	push   $0x20
  8003f5:	ff d7                	call   *%edi
	putch("0123456789abcdef"[num % base], putdat);
	
	if(padc=='-'&&width>0)
	{
		length=*(int *)putdat-length;
		for(int i=0;i<width-length;++i)
  8003f7:	83 c3 01             	add    $0x1,%ebx
  8003fa:	83 c4 10             	add    $0x10,%esp
  8003fd:	3b 5d e0             	cmp    -0x20(%ebp),%ebx
  800400:	75 ed                	jne    8003ef <printnum+0x157>
  800402:	eb 2c                	jmp    800430 <printnum+0x198>
		while (--width > 0)
			putch(padc, putdat);
	}
	}
	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800404:	83 ec 08             	sub    $0x8,%esp
  800407:	56                   	push   %esi
  800408:	8b 45 10             	mov    0x10(%ebp),%eax
  80040b:	ba 00 00 00 00       	mov    $0x0,%edx
  800410:	83 ec 04             	sub    $0x4,%esp
  800413:	52                   	push   %edx
  800414:	50                   	push   %eax
  800415:	ff 75 e4             	pushl  -0x1c(%ebp)
  800418:	ff 75 e0             	pushl  -0x20(%ebp)
  80041b:	e8 20 0b 00 00       	call   800f40 <__umoddi3>
  800420:	83 c4 14             	add    $0x14,%esp
  800423:	0f be 80 f3 10 80 00 	movsbl 0x8010f3(%eax),%eax
  80042a:	50                   	push   %eax
  80042b:	ff d7                	call   *%edi
  80042d:	83 c4 10             	add    $0x10,%esp
	{
		length=*(int *)putdat-length;
		for(int i=0;i<width-length;++i)
			putch(' ',putdat);
	}
}
  800430:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800433:	5b                   	pop    %ebx
  800434:	5e                   	pop    %esi
  800435:	5f                   	pop    %edi
  800436:	5d                   	pop    %ebp
  800437:	c3                   	ret    

00800438 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800438:	55                   	push   %ebp
  800439:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80043b:	83 fa 01             	cmp    $0x1,%edx
  80043e:	7e 0e                	jle    80044e <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800440:	8b 10                	mov    (%eax),%edx
  800442:	8d 4a 08             	lea    0x8(%edx),%ecx
  800445:	89 08                	mov    %ecx,(%eax)
  800447:	8b 02                	mov    (%edx),%eax
  800449:	8b 52 04             	mov    0x4(%edx),%edx
  80044c:	eb 22                	jmp    800470 <getuint+0x38>
	else if (lflag)
  80044e:	85 d2                	test   %edx,%edx
  800450:	74 10                	je     800462 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800452:	8b 10                	mov    (%eax),%edx
  800454:	8d 4a 04             	lea    0x4(%edx),%ecx
  800457:	89 08                	mov    %ecx,(%eax)
  800459:	8b 02                	mov    (%edx),%eax
  80045b:	ba 00 00 00 00       	mov    $0x0,%edx
  800460:	eb 0e                	jmp    800470 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800462:	8b 10                	mov    (%eax),%edx
  800464:	8d 4a 04             	lea    0x4(%edx),%ecx
  800467:	89 08                	mov    %ecx,(%eax)
  800469:	8b 02                	mov    (%edx),%eax
  80046b:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800470:	5d                   	pop    %ebp
  800471:	c3                   	ret    

00800472 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800472:	55                   	push   %ebp
  800473:	89 e5                	mov    %esp,%ebp
  800475:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800478:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80047c:	8b 10                	mov    (%eax),%edx
  80047e:	3b 50 04             	cmp    0x4(%eax),%edx
  800481:	73 0a                	jae    80048d <sprintputch+0x1b>
		*b->buf++ = ch;
  800483:	8d 4a 01             	lea    0x1(%edx),%ecx
  800486:	89 08                	mov    %ecx,(%eax)
  800488:	8b 45 08             	mov    0x8(%ebp),%eax
  80048b:	88 02                	mov    %al,(%edx)
}
  80048d:	5d                   	pop    %ebp
  80048e:	c3                   	ret    

0080048f <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80048f:	55                   	push   %ebp
  800490:	89 e5                	mov    %esp,%ebp
  800492:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800495:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800498:	50                   	push   %eax
  800499:	ff 75 10             	pushl  0x10(%ebp)
  80049c:	ff 75 0c             	pushl  0xc(%ebp)
  80049f:	ff 75 08             	pushl  0x8(%ebp)
  8004a2:	e8 05 00 00 00       	call   8004ac <vprintfmt>
	va_end(ap);
}
  8004a7:	83 c4 10             	add    $0x10,%esp
  8004aa:	c9                   	leave  
  8004ab:	c3                   	ret    

008004ac <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8004ac:	55                   	push   %ebp
  8004ad:	89 e5                	mov    %esp,%ebp
  8004af:	57                   	push   %edi
  8004b0:	56                   	push   %esi
  8004b1:	53                   	push   %ebx
  8004b2:	83 ec 2c             	sub    $0x2c,%esp
  8004b5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8004b8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004bb:	eb 03                	jmp    8004c0 <vprintfmt+0x14>
			break;
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
			for (fmt--; fmt[-1] != '%'; fmt--)
  8004bd:	89 75 10             	mov    %esi,0x10(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8004c0:	8b 45 10             	mov    0x10(%ebp),%eax
  8004c3:	8d 70 01             	lea    0x1(%eax),%esi
  8004c6:	0f b6 00             	movzbl (%eax),%eax
  8004c9:	83 f8 25             	cmp    $0x25,%eax
  8004cc:	74 27                	je     8004f5 <vprintfmt+0x49>
			if (ch == '\0')
  8004ce:	85 c0                	test   %eax,%eax
  8004d0:	75 0d                	jne    8004df <vprintfmt+0x33>
  8004d2:	e9 8b 04 00 00       	jmp    800962 <vprintfmt+0x4b6>
  8004d7:	85 c0                	test   %eax,%eax
  8004d9:	0f 84 83 04 00 00    	je     800962 <vprintfmt+0x4b6>
				return;
			putch(ch, putdat);
  8004df:	83 ec 08             	sub    $0x8,%esp
  8004e2:	53                   	push   %ebx
  8004e3:	50                   	push   %eax
  8004e4:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8004e6:	83 c6 01             	add    $0x1,%esi
  8004e9:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  8004ed:	83 c4 10             	add    $0x10,%esp
  8004f0:	83 f8 25             	cmp    $0x25,%eax
  8004f3:	75 e2                	jne    8004d7 <vprintfmt+0x2b>
			padc = '-';
			goto reswitch;
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004f5:	c6 45 e3 20          	movb   $0x20,-0x1d(%ebp)
  8004f9:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800500:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800507:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80050e:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  800515:	b9 00 00 00 00       	mov    $0x0,%ecx
  80051a:	eb 07                	jmp    800523 <vprintfmt+0x77>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80051c:	8b 75 10             	mov    0x10(%ebp),%esi

		// flag to show the sign
		case '+':
			padc='+';
  80051f:	c6 45 e3 2b          	movb   $0x2b,-0x1d(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800523:	8d 46 01             	lea    0x1(%esi),%eax
  800526:	89 45 10             	mov    %eax,0x10(%ebp)
  800529:	0f b6 06             	movzbl (%esi),%eax
  80052c:	0f b6 d0             	movzbl %al,%edx
  80052f:	83 e8 23             	sub    $0x23,%eax
  800532:	3c 55                	cmp    $0x55,%al
  800534:	0f 87 e9 03 00 00    	ja     800923 <vprintfmt+0x477>
  80053a:	0f b6 c0             	movzbl %al,%eax
  80053d:	ff 24 85 fc 11 80 00 	jmp    *0x8011fc(,%eax,4)
  800544:	8b 75 10             	mov    0x10(%ebp),%esi
			padc='+';
			goto reswitch;
		
		// flag to pad on the right
		case '-':
			padc = '-';
  800547:	c6 45 e3 2d          	movb   $0x2d,-0x1d(%ebp)
  80054b:	eb d6                	jmp    800523 <vprintfmt+0x77>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80054d:	8d 42 d0             	lea    -0x30(%edx),%eax
  800550:	89 45 d0             	mov    %eax,-0x30(%ebp)
				ch = *fmt;
  800553:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  800557:	8d 50 d0             	lea    -0x30(%eax),%edx
  80055a:	83 fa 09             	cmp    $0x9,%edx
  80055d:	77 66                	ja     8005c5 <vprintfmt+0x119>
  80055f:	8b 75 10             	mov    0x10(%ebp),%esi
  800562:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800565:	89 7d 08             	mov    %edi,0x8(%ebp)
  800568:	eb 09                	jmp    800573 <vprintfmt+0xc7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80056a:	8b 75 10             	mov    0x10(%ebp),%esi
			padc = '-';
			goto reswitch;
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80056d:	c6 45 e3 30          	movb   $0x30,-0x1d(%ebp)
			goto reswitch;
  800571:	eb b0                	jmp    800523 <vprintfmt+0x77>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800573:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  800576:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800579:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  80057d:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800580:	8d 78 d0             	lea    -0x30(%eax),%edi
  800583:	83 ff 09             	cmp    $0x9,%edi
  800586:	76 eb                	jbe    800573 <vprintfmt+0xc7>
  800588:	89 55 d0             	mov    %edx,-0x30(%ebp)
  80058b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80058e:	eb 38                	jmp    8005c8 <vprintfmt+0x11c>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800590:	8b 45 14             	mov    0x14(%ebp),%eax
  800593:	8d 50 04             	lea    0x4(%eax),%edx
  800596:	89 55 14             	mov    %edx,0x14(%ebp)
  800599:	8b 00                	mov    (%eax),%eax
  80059b:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80059e:	8b 75 10             	mov    0x10(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005a1:	eb 25                	jmp    8005c8 <vprintfmt+0x11c>
  8005a3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005a6:	85 c0                	test   %eax,%eax
  8005a8:	0f 48 c1             	cmovs  %ecx,%eax
  8005ab:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ae:	8b 75 10             	mov    0x10(%ebp),%esi
  8005b1:	e9 6d ff ff ff       	jmp    800523 <vprintfmt+0x77>
  8005b6:	8b 75 10             	mov    0x10(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8005b9:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8005c0:	e9 5e ff ff ff       	jmp    800523 <vprintfmt+0x77>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005c5:	8b 75 10             	mov    0x10(%ebp),%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8005c8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005cc:	0f 89 51 ff ff ff    	jns    800523 <vprintfmt+0x77>
				width = precision, precision = -1;
  8005d2:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8005d5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8005d8:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8005df:	e9 3f ff ff ff       	jmp    800523 <vprintfmt+0x77>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8005e4:	83 45 cc 01          	addl   $0x1,-0x34(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005e8:	8b 75 10             	mov    0x10(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8005eb:	e9 33 ff ff ff       	jmp    800523 <vprintfmt+0x77>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8005f0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f3:	8d 50 04             	lea    0x4(%eax),%edx
  8005f6:	89 55 14             	mov    %edx,0x14(%ebp)
  8005f9:	83 ec 08             	sub    $0x8,%esp
  8005fc:	53                   	push   %ebx
  8005fd:	ff 30                	pushl  (%eax)
  8005ff:	ff d7                	call   *%edi
			break;
  800601:	83 c4 10             	add    $0x10,%esp
  800604:	e9 b7 fe ff ff       	jmp    8004c0 <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800609:	8b 45 14             	mov    0x14(%ebp),%eax
  80060c:	8d 50 04             	lea    0x4(%eax),%edx
  80060f:	89 55 14             	mov    %edx,0x14(%ebp)
  800612:	8b 00                	mov    (%eax),%eax
  800614:	99                   	cltd   
  800615:	31 d0                	xor    %edx,%eax
  800617:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800619:	83 f8 06             	cmp    $0x6,%eax
  80061c:	7f 0b                	jg     800629 <vprintfmt+0x17d>
  80061e:	8b 14 85 54 13 80 00 	mov    0x801354(,%eax,4),%edx
  800625:	85 d2                	test   %edx,%edx
  800627:	75 15                	jne    80063e <vprintfmt+0x192>
				printfmt(putch, putdat, "error %d", err);
  800629:	50                   	push   %eax
  80062a:	68 0b 11 80 00       	push   $0x80110b
  80062f:	53                   	push   %ebx
  800630:	57                   	push   %edi
  800631:	e8 59 fe ff ff       	call   80048f <printfmt>
  800636:	83 c4 10             	add    $0x10,%esp
  800639:	e9 82 fe ff ff       	jmp    8004c0 <vprintfmt+0x14>
			else
				printfmt(putch, putdat, "%s", p);
  80063e:	52                   	push   %edx
  80063f:	68 14 11 80 00       	push   $0x801114
  800644:	53                   	push   %ebx
  800645:	57                   	push   %edi
  800646:	e8 44 fe ff ff       	call   80048f <printfmt>
  80064b:	83 c4 10             	add    $0x10,%esp
  80064e:	e9 6d fe ff ff       	jmp    8004c0 <vprintfmt+0x14>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800653:	8b 45 14             	mov    0x14(%ebp),%eax
  800656:	8d 50 04             	lea    0x4(%eax),%edx
  800659:	89 55 14             	mov    %edx,0x14(%ebp)
  80065c:	8b 00                	mov    (%eax),%eax
				p = "(null)";
  80065e:	85 c0                	test   %eax,%eax
  800660:	b9 04 11 80 00       	mov    $0x801104,%ecx
  800665:	0f 45 c8             	cmovne %eax,%ecx
  800668:	89 4d cc             	mov    %ecx,-0x34(%ebp)
			if (width > 0 && padc != '-')
  80066b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80066f:	7e 06                	jle    800677 <vprintfmt+0x1cb>
  800671:	80 7d e3 2d          	cmpb   $0x2d,-0x1d(%ebp)
  800675:	75 19                	jne    800690 <vprintfmt+0x1e4>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800677:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80067a:	8d 70 01             	lea    0x1(%eax),%esi
  80067d:	0f b6 00             	movzbl (%eax),%eax
  800680:	0f be d0             	movsbl %al,%edx
  800683:	85 d2                	test   %edx,%edx
  800685:	0f 85 9f 00 00 00    	jne    80072a <vprintfmt+0x27e>
  80068b:	e9 8c 00 00 00       	jmp    80071c <vprintfmt+0x270>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800690:	83 ec 08             	sub    $0x8,%esp
  800693:	ff 75 d0             	pushl  -0x30(%ebp)
  800696:	ff 75 cc             	pushl  -0x34(%ebp)
  800699:	e8 56 03 00 00       	call   8009f4 <strnlen>
  80069e:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  8006a1:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8006a4:	83 c4 10             	add    $0x10,%esp
  8006a7:	85 c9                	test   %ecx,%ecx
  8006a9:	0f 8e 9a 02 00 00    	jle    800949 <vprintfmt+0x49d>
					putch(padc, putdat);
  8006af:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  8006b3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006b6:	89 cb                	mov    %ecx,%ebx
  8006b8:	83 ec 08             	sub    $0x8,%esp
  8006bb:	ff 75 0c             	pushl  0xc(%ebp)
  8006be:	56                   	push   %esi
  8006bf:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006c1:	83 c4 10             	add    $0x10,%esp
  8006c4:	83 eb 01             	sub    $0x1,%ebx
  8006c7:	75 ef                	jne    8006b8 <vprintfmt+0x20c>
  8006c9:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8006cc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006cf:	e9 75 02 00 00       	jmp    800949 <vprintfmt+0x49d>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8006d4:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8006d8:	74 1b                	je     8006f5 <vprintfmt+0x249>
  8006da:	0f be c0             	movsbl %al,%eax
  8006dd:	83 e8 20             	sub    $0x20,%eax
  8006e0:	83 f8 5e             	cmp    $0x5e,%eax
  8006e3:	76 10                	jbe    8006f5 <vprintfmt+0x249>
					putch('?', putdat);
  8006e5:	83 ec 08             	sub    $0x8,%esp
  8006e8:	ff 75 0c             	pushl  0xc(%ebp)
  8006eb:	6a 3f                	push   $0x3f
  8006ed:	ff 55 08             	call   *0x8(%ebp)
  8006f0:	83 c4 10             	add    $0x10,%esp
  8006f3:	eb 0d                	jmp    800702 <vprintfmt+0x256>
				else
					putch(ch, putdat);
  8006f5:	83 ec 08             	sub    $0x8,%esp
  8006f8:	ff 75 0c             	pushl  0xc(%ebp)
  8006fb:	52                   	push   %edx
  8006fc:	ff 55 08             	call   *0x8(%ebp)
  8006ff:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800702:	83 ef 01             	sub    $0x1,%edi
  800705:	83 c6 01             	add    $0x1,%esi
  800708:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  80070c:	0f be d0             	movsbl %al,%edx
  80070f:	85 d2                	test   %edx,%edx
  800711:	75 31                	jne    800744 <vprintfmt+0x298>
  800713:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800716:	8b 7d 08             	mov    0x8(%ebp),%edi
  800719:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80071c:	8b 75 e4             	mov    -0x1c(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80071f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800723:	7f 33                	jg     800758 <vprintfmt+0x2ac>
  800725:	e9 96 fd ff ff       	jmp    8004c0 <vprintfmt+0x14>
  80072a:	89 7d 08             	mov    %edi,0x8(%ebp)
  80072d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800730:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800733:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800736:	eb 0c                	jmp    800744 <vprintfmt+0x298>
  800738:	89 7d 08             	mov    %edi,0x8(%ebp)
  80073b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80073e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800741:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800744:	85 db                	test   %ebx,%ebx
  800746:	78 8c                	js     8006d4 <vprintfmt+0x228>
  800748:	83 eb 01             	sub    $0x1,%ebx
  80074b:	79 87                	jns    8006d4 <vprintfmt+0x228>
  80074d:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800750:	8b 7d 08             	mov    0x8(%ebp),%edi
  800753:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800756:	eb c4                	jmp    80071c <vprintfmt+0x270>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800758:	83 ec 08             	sub    $0x8,%esp
  80075b:	53                   	push   %ebx
  80075c:	6a 20                	push   $0x20
  80075e:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800760:	83 c4 10             	add    $0x10,%esp
  800763:	83 ee 01             	sub    $0x1,%esi
  800766:	75 f0                	jne    800758 <vprintfmt+0x2ac>
  800768:	e9 53 fd ff ff       	jmp    8004c0 <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80076d:	83 7d cc 01          	cmpl   $0x1,-0x34(%ebp)
  800771:	7e 16                	jle    800789 <vprintfmt+0x2dd>
		return va_arg(*ap, long long);
  800773:	8b 45 14             	mov    0x14(%ebp),%eax
  800776:	8d 50 08             	lea    0x8(%eax),%edx
  800779:	89 55 14             	mov    %edx,0x14(%ebp)
  80077c:	8b 50 04             	mov    0x4(%eax),%edx
  80077f:	8b 00                	mov    (%eax),%eax
  800781:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800784:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800787:	eb 34                	jmp    8007bd <vprintfmt+0x311>
	else if (lflag)
  800789:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  80078d:	74 18                	je     8007a7 <vprintfmt+0x2fb>
		return va_arg(*ap, long);
  80078f:	8b 45 14             	mov    0x14(%ebp),%eax
  800792:	8d 50 04             	lea    0x4(%eax),%edx
  800795:	89 55 14             	mov    %edx,0x14(%ebp)
  800798:	8b 30                	mov    (%eax),%esi
  80079a:	89 75 d0             	mov    %esi,-0x30(%ebp)
  80079d:	89 f0                	mov    %esi,%eax
  80079f:	c1 f8 1f             	sar    $0x1f,%eax
  8007a2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8007a5:	eb 16                	jmp    8007bd <vprintfmt+0x311>
	else
		return va_arg(*ap, int);
  8007a7:	8b 45 14             	mov    0x14(%ebp),%eax
  8007aa:	8d 50 04             	lea    0x4(%eax),%edx
  8007ad:	89 55 14             	mov    %edx,0x14(%ebp)
  8007b0:	8b 30                	mov    (%eax),%esi
  8007b2:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8007b5:	89 f0                	mov    %esi,%eax
  8007b7:	c1 f8 1f             	sar    $0x1f,%eax
  8007ba:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8007bd:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8007c0:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8007c3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007c6:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  8007c9:	85 d2                	test   %edx,%edx
  8007cb:	79 28                	jns    8007f5 <vprintfmt+0x349>
				putch('-', putdat);
  8007cd:	83 ec 08             	sub    $0x8,%esp
  8007d0:	53                   	push   %ebx
  8007d1:	6a 2d                	push   $0x2d
  8007d3:	ff d7                	call   *%edi
				num = -(long long) num;
  8007d5:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8007d8:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8007db:	f7 d8                	neg    %eax
  8007dd:	83 d2 00             	adc    $0x0,%edx
  8007e0:	f7 da                	neg    %edx
  8007e2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007e5:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007e8:	83 c4 10             	add    $0x10,%esp
			else
			{
				if(padc=='+')
					putch('+', putdat);
			}
			base = 10;
  8007eb:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007f0:	e9 a5 00 00 00       	jmp    80089a <vprintfmt+0x3ee>
  8007f5:	b8 0a 00 00 00       	mov    $0xa,%eax
				putch('-', putdat);
				num = -(long long) num;
			}
			else
			{
				if(padc=='+')
  8007fa:	80 7d e3 2b          	cmpb   $0x2b,-0x1d(%ebp)
  8007fe:	0f 85 96 00 00 00    	jne    80089a <vprintfmt+0x3ee>
					putch('+', putdat);
  800804:	83 ec 08             	sub    $0x8,%esp
  800807:	53                   	push   %ebx
  800808:	6a 2b                	push   $0x2b
  80080a:	ff d7                	call   *%edi
  80080c:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80080f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800814:	e9 81 00 00 00       	jmp    80089a <vprintfmt+0x3ee>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800819:	8b 55 cc             	mov    -0x34(%ebp),%edx
  80081c:	8d 45 14             	lea    0x14(%ebp),%eax
  80081f:	e8 14 fc ff ff       	call   800438 <getuint>
  800824:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800827:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  80082a:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80082f:	eb 69                	jmp    80089a <vprintfmt+0x3ee>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			putch('0', putdat);
  800831:	83 ec 08             	sub    $0x8,%esp
  800834:	53                   	push   %ebx
  800835:	6a 30                	push   $0x30
  800837:	ff d7                	call   *%edi
			num = getuint(&ap, lflag);
  800839:	8b 55 cc             	mov    -0x34(%ebp),%edx
  80083c:	8d 45 14             	lea    0x14(%ebp),%eax
  80083f:	e8 f4 fb ff ff       	call   800438 <getuint>
  800844:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800847:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
			goto number;
  80084a:	83 c4 10             	add    $0x10,%esp
		case 'o':
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
  80084d:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800852:	eb 46                	jmp    80089a <vprintfmt+0x3ee>

		// pointer
		case 'p':
			putch('0', putdat);
  800854:	83 ec 08             	sub    $0x8,%esp
  800857:	53                   	push   %ebx
  800858:	6a 30                	push   $0x30
  80085a:	ff d7                	call   *%edi
			putch('x', putdat);
  80085c:	83 c4 08             	add    $0x8,%esp
  80085f:	53                   	push   %ebx
  800860:	6a 78                	push   $0x78
  800862:	ff d7                	call   *%edi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800864:	8b 45 14             	mov    0x14(%ebp),%eax
  800867:	8d 50 04             	lea    0x4(%eax),%edx
  80086a:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80086d:	8b 00                	mov    (%eax),%eax
  80086f:	ba 00 00 00 00       	mov    $0x0,%edx
  800874:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800877:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80087a:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80087d:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800882:	eb 16                	jmp    80089a <vprintfmt+0x3ee>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800884:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800887:	8d 45 14             	lea    0x14(%ebp),%eax
  80088a:	e8 a9 fb ff ff       	call   800438 <getuint>
  80088f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800892:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  800895:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  80089a:	83 ec 0c             	sub    $0xc,%esp
  80089d:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  8008a1:	56                   	push   %esi
  8008a2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8008a5:	50                   	push   %eax
  8008a6:	ff 75 dc             	pushl  -0x24(%ebp)
  8008a9:	ff 75 d8             	pushl  -0x28(%ebp)
  8008ac:	89 da                	mov    %ebx,%edx
  8008ae:	89 f8                	mov    %edi,%eax
  8008b0:	e8 e3 f9 ff ff       	call   800298 <printnum>
			break;
  8008b5:	83 c4 20             	add    $0x20,%esp
  8008b8:	e9 03 fc ff ff       	jmp    8004c0 <vprintfmt+0x14>

            const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
            const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

            // Your code here
			num=(unsigned long long)(uintptr_t)va_arg(ap, void *);
  8008bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8008c0:	8d 50 04             	lea    0x4(%eax),%edx
  8008c3:	89 55 14             	mov    %edx,0x14(%ebp)
  8008c6:	8b 00                	mov    (%eax),%eax
			if(!num)
  8008c8:	85 c0                	test   %eax,%eax
  8008ca:	75 1c                	jne    8008e8 <vprintfmt+0x43c>
				*(int *)putdat+=cprintf("%s",null_error);
  8008cc:	83 ec 08             	sub    $0x8,%esp
  8008cf:	68 80 11 80 00       	push   $0x801180
  8008d4:	68 14 11 80 00       	push   $0x801114
  8008d9:	e8 a6 f9 ff ff       	call   800284 <cprintf>
  8008de:	01 03                	add    %eax,(%ebx)
  8008e0:	83 c4 10             	add    $0x10,%esp
  8008e3:	e9 d8 fb ff ff       	jmp    8004c0 <vprintfmt+0x14>
			else
			{
				*(char *)(int)num=*(int *)putdat;
  8008e8:	8b 13                	mov    (%ebx),%edx
  8008ea:	88 10                	mov    %dl,(%eax)
				if((*(int *)putdat)>128)
  8008ec:	81 3b 80 00 00 00    	cmpl   $0x80,(%ebx)
  8008f2:	0f 8e c8 fb ff ff    	jle    8004c0 <vprintfmt+0x14>
					*(int *)putdat+=cprintf("%s",overflow_error);
  8008f8:	83 ec 08             	sub    $0x8,%esp
  8008fb:	68 b8 11 80 00       	push   $0x8011b8
  800900:	68 14 11 80 00       	push   $0x801114
  800905:	e8 7a f9 ff ff       	call   800284 <cprintf>
  80090a:	01 03                	add    %eax,(%ebx)
  80090c:	83 c4 10             	add    $0x10,%esp
  80090f:	e9 ac fb ff ff       	jmp    8004c0 <vprintfmt+0x14>
            break;
        }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800914:	83 ec 08             	sub    $0x8,%esp
  800917:	53                   	push   %ebx
  800918:	52                   	push   %edx
  800919:	ff d7                	call   *%edi
			break;
  80091b:	83 c4 10             	add    $0x10,%esp
  80091e:	e9 9d fb ff ff       	jmp    8004c0 <vprintfmt+0x14>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800923:	83 ec 08             	sub    $0x8,%esp
  800926:	53                   	push   %ebx
  800927:	6a 25                	push   $0x25
  800929:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80092b:	83 c4 10             	add    $0x10,%esp
  80092e:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800932:	0f 84 85 fb ff ff    	je     8004bd <vprintfmt+0x11>
  800938:	83 ee 01             	sub    $0x1,%esi
  80093b:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80093f:	75 f7                	jne    800938 <vprintfmt+0x48c>
  800941:	89 75 10             	mov    %esi,0x10(%ebp)
  800944:	e9 77 fb ff ff       	jmp    8004c0 <vprintfmt+0x14>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800949:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80094c:	8d 70 01             	lea    0x1(%eax),%esi
  80094f:	0f b6 00             	movzbl (%eax),%eax
  800952:	0f be d0             	movsbl %al,%edx
  800955:	85 d2                	test   %edx,%edx
  800957:	0f 85 db fd ff ff    	jne    800738 <vprintfmt+0x28c>
  80095d:	e9 5e fb ff ff       	jmp    8004c0 <vprintfmt+0x14>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800962:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800965:	5b                   	pop    %ebx
  800966:	5e                   	pop    %esi
  800967:	5f                   	pop    %edi
  800968:	5d                   	pop    %ebp
  800969:	c3                   	ret    

0080096a <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80096a:	55                   	push   %ebp
  80096b:	89 e5                	mov    %esp,%ebp
  80096d:	83 ec 18             	sub    $0x18,%esp
  800970:	8b 45 08             	mov    0x8(%ebp),%eax
  800973:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800976:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800979:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80097d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800980:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800987:	85 c0                	test   %eax,%eax
  800989:	74 26                	je     8009b1 <vsnprintf+0x47>
  80098b:	85 d2                	test   %edx,%edx
  80098d:	7e 22                	jle    8009b1 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80098f:	ff 75 14             	pushl  0x14(%ebp)
  800992:	ff 75 10             	pushl  0x10(%ebp)
  800995:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800998:	50                   	push   %eax
  800999:	68 72 04 80 00       	push   $0x800472
  80099e:	e8 09 fb ff ff       	call   8004ac <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8009a3:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8009a6:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8009a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009ac:	83 c4 10             	add    $0x10,%esp
  8009af:	eb 05                	jmp    8009b6 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8009b1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8009b6:	c9                   	leave  
  8009b7:	c3                   	ret    

008009b8 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8009b8:	55                   	push   %ebp
  8009b9:	89 e5                	mov    %esp,%ebp
  8009bb:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8009be:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8009c1:	50                   	push   %eax
  8009c2:	ff 75 10             	pushl  0x10(%ebp)
  8009c5:	ff 75 0c             	pushl  0xc(%ebp)
  8009c8:	ff 75 08             	pushl  0x8(%ebp)
  8009cb:	e8 9a ff ff ff       	call   80096a <vsnprintf>
	va_end(ap);

	return rc;
}
  8009d0:	c9                   	leave  
  8009d1:	c3                   	ret    

008009d2 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8009d2:	55                   	push   %ebp
  8009d3:	89 e5                	mov    %esp,%ebp
  8009d5:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8009d8:	80 3a 00             	cmpb   $0x0,(%edx)
  8009db:	74 10                	je     8009ed <strlen+0x1b>
  8009dd:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8009e2:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8009e5:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8009e9:	75 f7                	jne    8009e2 <strlen+0x10>
  8009eb:	eb 05                	jmp    8009f2 <strlen+0x20>
  8009ed:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8009f2:	5d                   	pop    %ebp
  8009f3:	c3                   	ret    

008009f4 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8009f4:	55                   	push   %ebp
  8009f5:	89 e5                	mov    %esp,%ebp
  8009f7:	53                   	push   %ebx
  8009f8:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8009fb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009fe:	85 c9                	test   %ecx,%ecx
  800a00:	74 1c                	je     800a1e <strnlen+0x2a>
  800a02:	80 3b 00             	cmpb   $0x0,(%ebx)
  800a05:	74 1e                	je     800a25 <strnlen+0x31>
  800a07:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  800a0c:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a0e:	39 ca                	cmp    %ecx,%edx
  800a10:	74 18                	je     800a2a <strnlen+0x36>
  800a12:	83 c2 01             	add    $0x1,%edx
  800a15:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  800a1a:	75 f0                	jne    800a0c <strnlen+0x18>
  800a1c:	eb 0c                	jmp    800a2a <strnlen+0x36>
  800a1e:	b8 00 00 00 00       	mov    $0x0,%eax
  800a23:	eb 05                	jmp    800a2a <strnlen+0x36>
  800a25:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800a2a:	5b                   	pop    %ebx
  800a2b:	5d                   	pop    %ebp
  800a2c:	c3                   	ret    

00800a2d <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a2d:	55                   	push   %ebp
  800a2e:	89 e5                	mov    %esp,%ebp
  800a30:	53                   	push   %ebx
  800a31:	8b 45 08             	mov    0x8(%ebp),%eax
  800a34:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a37:	89 c2                	mov    %eax,%edx
  800a39:	83 c2 01             	add    $0x1,%edx
  800a3c:	83 c1 01             	add    $0x1,%ecx
  800a3f:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800a43:	88 5a ff             	mov    %bl,-0x1(%edx)
  800a46:	84 db                	test   %bl,%bl
  800a48:	75 ef                	jne    800a39 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800a4a:	5b                   	pop    %ebx
  800a4b:	5d                   	pop    %ebp
  800a4c:	c3                   	ret    

00800a4d <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a4d:	55                   	push   %ebp
  800a4e:	89 e5                	mov    %esp,%ebp
  800a50:	53                   	push   %ebx
  800a51:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a54:	53                   	push   %ebx
  800a55:	e8 78 ff ff ff       	call   8009d2 <strlen>
  800a5a:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800a5d:	ff 75 0c             	pushl  0xc(%ebp)
  800a60:	01 d8                	add    %ebx,%eax
  800a62:	50                   	push   %eax
  800a63:	e8 c5 ff ff ff       	call   800a2d <strcpy>
	return dst;
}
  800a68:	89 d8                	mov    %ebx,%eax
  800a6a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a6d:	c9                   	leave  
  800a6e:	c3                   	ret    

00800a6f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a6f:	55                   	push   %ebp
  800a70:	89 e5                	mov    %esp,%ebp
  800a72:	56                   	push   %esi
  800a73:	53                   	push   %ebx
  800a74:	8b 75 08             	mov    0x8(%ebp),%esi
  800a77:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a7a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a7d:	85 db                	test   %ebx,%ebx
  800a7f:	74 17                	je     800a98 <strncpy+0x29>
  800a81:	01 f3                	add    %esi,%ebx
  800a83:	89 f1                	mov    %esi,%ecx
		*dst++ = *src;
  800a85:	83 c1 01             	add    $0x1,%ecx
  800a88:	0f b6 02             	movzbl (%edx),%eax
  800a8b:	88 41 ff             	mov    %al,-0x1(%ecx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a8e:	80 3a 01             	cmpb   $0x1,(%edx)
  800a91:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a94:	39 cb                	cmp    %ecx,%ebx
  800a96:	75 ed                	jne    800a85 <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a98:	89 f0                	mov    %esi,%eax
  800a9a:	5b                   	pop    %ebx
  800a9b:	5e                   	pop    %esi
  800a9c:	5d                   	pop    %ebp
  800a9d:	c3                   	ret    

00800a9e <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a9e:	55                   	push   %ebp
  800a9f:	89 e5                	mov    %esp,%ebp
  800aa1:	56                   	push   %esi
  800aa2:	53                   	push   %ebx
  800aa3:	8b 75 08             	mov    0x8(%ebp),%esi
  800aa6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800aa9:	8b 55 10             	mov    0x10(%ebp),%edx
  800aac:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800aae:	85 d2                	test   %edx,%edx
  800ab0:	74 35                	je     800ae7 <strlcpy+0x49>
		while (--size > 0 && *src != '\0')
  800ab2:	89 d0                	mov    %edx,%eax
  800ab4:	83 e8 01             	sub    $0x1,%eax
  800ab7:	74 25                	je     800ade <strlcpy+0x40>
  800ab9:	0f b6 0b             	movzbl (%ebx),%ecx
  800abc:	84 c9                	test   %cl,%cl
  800abe:	74 22                	je     800ae2 <strlcpy+0x44>
  800ac0:	8d 53 01             	lea    0x1(%ebx),%edx
  800ac3:	01 c3                	add    %eax,%ebx
  800ac5:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
  800ac7:	83 c0 01             	add    $0x1,%eax
  800aca:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800acd:	39 da                	cmp    %ebx,%edx
  800acf:	74 13                	je     800ae4 <strlcpy+0x46>
  800ad1:	83 c2 01             	add    $0x1,%edx
  800ad4:	0f b6 4a ff          	movzbl -0x1(%edx),%ecx
  800ad8:	84 c9                	test   %cl,%cl
  800ada:	75 eb                	jne    800ac7 <strlcpy+0x29>
  800adc:	eb 06                	jmp    800ae4 <strlcpy+0x46>
  800ade:	89 f0                	mov    %esi,%eax
  800ae0:	eb 02                	jmp    800ae4 <strlcpy+0x46>
  800ae2:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800ae4:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800ae7:	29 f0                	sub    %esi,%eax
}
  800ae9:	5b                   	pop    %ebx
  800aea:	5e                   	pop    %esi
  800aeb:	5d                   	pop    %ebp
  800aec:	c3                   	ret    

00800aed <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800aed:	55                   	push   %ebp
  800aee:	89 e5                	mov    %esp,%ebp
  800af0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800af3:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800af6:	0f b6 01             	movzbl (%ecx),%eax
  800af9:	84 c0                	test   %al,%al
  800afb:	74 15                	je     800b12 <strcmp+0x25>
  800afd:	3a 02                	cmp    (%edx),%al
  800aff:	75 11                	jne    800b12 <strcmp+0x25>
		p++, q++;
  800b01:	83 c1 01             	add    $0x1,%ecx
  800b04:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800b07:	0f b6 01             	movzbl (%ecx),%eax
  800b0a:	84 c0                	test   %al,%al
  800b0c:	74 04                	je     800b12 <strcmp+0x25>
  800b0e:	3a 02                	cmp    (%edx),%al
  800b10:	74 ef                	je     800b01 <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800b12:	0f b6 c0             	movzbl %al,%eax
  800b15:	0f b6 12             	movzbl (%edx),%edx
  800b18:	29 d0                	sub    %edx,%eax
}
  800b1a:	5d                   	pop    %ebp
  800b1b:	c3                   	ret    

00800b1c <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b1c:	55                   	push   %ebp
  800b1d:	89 e5                	mov    %esp,%ebp
  800b1f:	56                   	push   %esi
  800b20:	53                   	push   %ebx
  800b21:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800b24:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b27:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  800b2a:	85 f6                	test   %esi,%esi
  800b2c:	74 29                	je     800b57 <strncmp+0x3b>
  800b2e:	0f b6 03             	movzbl (%ebx),%eax
  800b31:	84 c0                	test   %al,%al
  800b33:	74 30                	je     800b65 <strncmp+0x49>
  800b35:	3a 02                	cmp    (%edx),%al
  800b37:	75 2c                	jne    800b65 <strncmp+0x49>
  800b39:	8d 43 01             	lea    0x1(%ebx),%eax
  800b3c:	01 de                	add    %ebx,%esi
		n--, p++, q++;
  800b3e:	89 c3                	mov    %eax,%ebx
  800b40:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800b43:	39 c6                	cmp    %eax,%esi
  800b45:	74 17                	je     800b5e <strncmp+0x42>
  800b47:	0f b6 08             	movzbl (%eax),%ecx
  800b4a:	84 c9                	test   %cl,%cl
  800b4c:	74 17                	je     800b65 <strncmp+0x49>
  800b4e:	83 c0 01             	add    $0x1,%eax
  800b51:	3a 0a                	cmp    (%edx),%cl
  800b53:	74 e9                	je     800b3e <strncmp+0x22>
  800b55:	eb 0e                	jmp    800b65 <strncmp+0x49>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800b57:	b8 00 00 00 00       	mov    $0x0,%eax
  800b5c:	eb 0f                	jmp    800b6d <strncmp+0x51>
  800b5e:	b8 00 00 00 00       	mov    $0x0,%eax
  800b63:	eb 08                	jmp    800b6d <strncmp+0x51>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b65:	0f b6 03             	movzbl (%ebx),%eax
  800b68:	0f b6 12             	movzbl (%edx),%edx
  800b6b:	29 d0                	sub    %edx,%eax
}
  800b6d:	5b                   	pop    %ebx
  800b6e:	5e                   	pop    %esi
  800b6f:	5d                   	pop    %ebp
  800b70:	c3                   	ret    

00800b71 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b71:	55                   	push   %ebp
  800b72:	89 e5                	mov    %esp,%ebp
  800b74:	53                   	push   %ebx
  800b75:	8b 45 08             	mov    0x8(%ebp),%eax
  800b78:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
  800b7b:	0f b6 10             	movzbl (%eax),%edx
  800b7e:	84 d2                	test   %dl,%dl
  800b80:	74 1d                	je     800b9f <strchr+0x2e>
  800b82:	89 d9                	mov    %ebx,%ecx
		if (*s == c)
  800b84:	38 d3                	cmp    %dl,%bl
  800b86:	75 06                	jne    800b8e <strchr+0x1d>
  800b88:	eb 1a                	jmp    800ba4 <strchr+0x33>
  800b8a:	38 ca                	cmp    %cl,%dl
  800b8c:	74 16                	je     800ba4 <strchr+0x33>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b8e:	83 c0 01             	add    $0x1,%eax
  800b91:	0f b6 10             	movzbl (%eax),%edx
  800b94:	84 d2                	test   %dl,%dl
  800b96:	75 f2                	jne    800b8a <strchr+0x19>
		if (*s == c)
			return (char *) s;
	return 0;
  800b98:	b8 00 00 00 00       	mov    $0x0,%eax
  800b9d:	eb 05                	jmp    800ba4 <strchr+0x33>
  800b9f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ba4:	5b                   	pop    %ebx
  800ba5:	5d                   	pop    %ebp
  800ba6:	c3                   	ret    

00800ba7 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800ba7:	55                   	push   %ebp
  800ba8:	89 e5                	mov    %esp,%ebp
  800baa:	53                   	push   %ebx
  800bab:	8b 45 08             	mov    0x8(%ebp),%eax
  800bae:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  800bb1:	0f b6 18             	movzbl (%eax),%ebx
		if (*s == c)
  800bb4:	38 d3                	cmp    %dl,%bl
  800bb6:	74 14                	je     800bcc <strfind+0x25>
  800bb8:	89 d1                	mov    %edx,%ecx
  800bba:	84 db                	test   %bl,%bl
  800bbc:	74 0e                	je     800bcc <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800bbe:	83 c0 01             	add    $0x1,%eax
  800bc1:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800bc4:	38 ca                	cmp    %cl,%dl
  800bc6:	74 04                	je     800bcc <strfind+0x25>
  800bc8:	84 d2                	test   %dl,%dl
  800bca:	75 f2                	jne    800bbe <strfind+0x17>
			break;
	return (char *) s;
}
  800bcc:	5b                   	pop    %ebx
  800bcd:	5d                   	pop    %ebp
  800bce:	c3                   	ret    

00800bcf <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800bcf:	55                   	push   %ebp
  800bd0:	89 e5                	mov    %esp,%ebp
  800bd2:	57                   	push   %edi
  800bd3:	56                   	push   %esi
  800bd4:	53                   	push   %ebx
  800bd5:	8b 7d 08             	mov    0x8(%ebp),%edi
  800bd8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800bdb:	85 c9                	test   %ecx,%ecx
  800bdd:	74 36                	je     800c15 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800bdf:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800be5:	75 28                	jne    800c0f <memset+0x40>
  800be7:	f6 c1 03             	test   $0x3,%cl
  800bea:	75 23                	jne    800c0f <memset+0x40>
		c &= 0xFF;
  800bec:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800bf0:	89 d3                	mov    %edx,%ebx
  800bf2:	c1 e3 08             	shl    $0x8,%ebx
  800bf5:	89 d6                	mov    %edx,%esi
  800bf7:	c1 e6 18             	shl    $0x18,%esi
  800bfa:	89 d0                	mov    %edx,%eax
  800bfc:	c1 e0 10             	shl    $0x10,%eax
  800bff:	09 f0                	or     %esi,%eax
  800c01:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800c03:	89 d8                	mov    %ebx,%eax
  800c05:	09 d0                	or     %edx,%eax
  800c07:	c1 e9 02             	shr    $0x2,%ecx
  800c0a:	fc                   	cld    
  800c0b:	f3 ab                	rep stos %eax,%es:(%edi)
  800c0d:	eb 06                	jmp    800c15 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800c0f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c12:	fc                   	cld    
  800c13:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800c15:	89 f8                	mov    %edi,%eax
  800c17:	5b                   	pop    %ebx
  800c18:	5e                   	pop    %esi
  800c19:	5f                   	pop    %edi
  800c1a:	5d                   	pop    %ebp
  800c1b:	c3                   	ret    

00800c1c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800c1c:	55                   	push   %ebp
  800c1d:	89 e5                	mov    %esp,%ebp
  800c1f:	57                   	push   %edi
  800c20:	56                   	push   %esi
  800c21:	8b 45 08             	mov    0x8(%ebp),%eax
  800c24:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c27:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800c2a:	39 c6                	cmp    %eax,%esi
  800c2c:	73 35                	jae    800c63 <memmove+0x47>
  800c2e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c31:	39 d0                	cmp    %edx,%eax
  800c33:	73 2e                	jae    800c63 <memmove+0x47>
		s += n;
		d += n;
  800c35:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c38:	89 d6                	mov    %edx,%esi
  800c3a:	09 fe                	or     %edi,%esi
  800c3c:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c42:	75 13                	jne    800c57 <memmove+0x3b>
  800c44:	f6 c1 03             	test   $0x3,%cl
  800c47:	75 0e                	jne    800c57 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800c49:	83 ef 04             	sub    $0x4,%edi
  800c4c:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c4f:	c1 e9 02             	shr    $0x2,%ecx
  800c52:	fd                   	std    
  800c53:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c55:	eb 09                	jmp    800c60 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800c57:	83 ef 01             	sub    $0x1,%edi
  800c5a:	8d 72 ff             	lea    -0x1(%edx),%esi
  800c5d:	fd                   	std    
  800c5e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c60:	fc                   	cld    
  800c61:	eb 1d                	jmp    800c80 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c63:	89 f2                	mov    %esi,%edx
  800c65:	09 c2                	or     %eax,%edx
  800c67:	f6 c2 03             	test   $0x3,%dl
  800c6a:	75 0f                	jne    800c7b <memmove+0x5f>
  800c6c:	f6 c1 03             	test   $0x3,%cl
  800c6f:	75 0a                	jne    800c7b <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800c71:	c1 e9 02             	shr    $0x2,%ecx
  800c74:	89 c7                	mov    %eax,%edi
  800c76:	fc                   	cld    
  800c77:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c79:	eb 05                	jmp    800c80 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c7b:	89 c7                	mov    %eax,%edi
  800c7d:	fc                   	cld    
  800c7e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c80:	5e                   	pop    %esi
  800c81:	5f                   	pop    %edi
  800c82:	5d                   	pop    %ebp
  800c83:	c3                   	ret    

00800c84 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800c84:	55                   	push   %ebp
  800c85:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800c87:	ff 75 10             	pushl  0x10(%ebp)
  800c8a:	ff 75 0c             	pushl  0xc(%ebp)
  800c8d:	ff 75 08             	pushl  0x8(%ebp)
  800c90:	e8 87 ff ff ff       	call   800c1c <memmove>
}
  800c95:	c9                   	leave  
  800c96:	c3                   	ret    

00800c97 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c97:	55                   	push   %ebp
  800c98:	89 e5                	mov    %esp,%ebp
  800c9a:	57                   	push   %edi
  800c9b:	56                   	push   %esi
  800c9c:	53                   	push   %ebx
  800c9d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800ca0:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ca3:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ca6:	85 c0                	test   %eax,%eax
  800ca8:	74 39                	je     800ce3 <memcmp+0x4c>
  800caa:	8d 78 ff             	lea    -0x1(%eax),%edi
		if (*s1 != *s2)
  800cad:	0f b6 13             	movzbl (%ebx),%edx
  800cb0:	0f b6 0e             	movzbl (%esi),%ecx
  800cb3:	38 ca                	cmp    %cl,%dl
  800cb5:	75 17                	jne    800cce <memcmp+0x37>
  800cb7:	b8 00 00 00 00       	mov    $0x0,%eax
  800cbc:	eb 1a                	jmp    800cd8 <memcmp+0x41>
  800cbe:	0f b6 54 03 01       	movzbl 0x1(%ebx,%eax,1),%edx
  800cc3:	83 c0 01             	add    $0x1,%eax
  800cc6:	0f b6 0c 06          	movzbl (%esi,%eax,1),%ecx
  800cca:	38 ca                	cmp    %cl,%dl
  800ccc:	74 0a                	je     800cd8 <memcmp+0x41>
			return (int) *s1 - (int) *s2;
  800cce:	0f b6 c2             	movzbl %dl,%eax
  800cd1:	0f b6 c9             	movzbl %cl,%ecx
  800cd4:	29 c8                	sub    %ecx,%eax
  800cd6:	eb 10                	jmp    800ce8 <memcmp+0x51>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800cd8:	39 f8                	cmp    %edi,%eax
  800cda:	75 e2                	jne    800cbe <memcmp+0x27>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800cdc:	b8 00 00 00 00       	mov    $0x0,%eax
  800ce1:	eb 05                	jmp    800ce8 <memcmp+0x51>
  800ce3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ce8:	5b                   	pop    %ebx
  800ce9:	5e                   	pop    %esi
  800cea:	5f                   	pop    %edi
  800ceb:	5d                   	pop    %ebp
  800cec:	c3                   	ret    

00800ced <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ced:	55                   	push   %ebp
  800cee:	89 e5                	mov    %esp,%ebp
  800cf0:	53                   	push   %ebx
  800cf1:	8b 55 08             	mov    0x8(%ebp),%edx
	const void *ends = (const char *) s + n;
  800cf4:	89 d0                	mov    %edx,%eax
  800cf6:	03 45 10             	add    0x10(%ebp),%eax
	for (; s < ends; s++)
  800cf9:	39 c2                	cmp    %eax,%edx
  800cfb:	73 1d                	jae    800d1a <memfind+0x2d>
		if (*(const unsigned char *) s == (unsigned char) c)
  800cfd:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
  800d01:	0f b6 0a             	movzbl (%edx),%ecx
  800d04:	39 d9                	cmp    %ebx,%ecx
  800d06:	75 09                	jne    800d11 <memfind+0x24>
  800d08:	eb 14                	jmp    800d1e <memfind+0x31>
  800d0a:	0f b6 0a             	movzbl (%edx),%ecx
  800d0d:	39 d9                	cmp    %ebx,%ecx
  800d0f:	74 11                	je     800d22 <memfind+0x35>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800d11:	83 c2 01             	add    $0x1,%edx
  800d14:	39 d0                	cmp    %edx,%eax
  800d16:	75 f2                	jne    800d0a <memfind+0x1d>
  800d18:	eb 0a                	jmp    800d24 <memfind+0x37>
  800d1a:	89 d0                	mov    %edx,%eax
  800d1c:	eb 06                	jmp    800d24 <memfind+0x37>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d1e:	89 d0                	mov    %edx,%eax
  800d20:	eb 02                	jmp    800d24 <memfind+0x37>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800d22:	89 d0                	mov    %edx,%eax
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800d24:	5b                   	pop    %ebx
  800d25:	5d                   	pop    %ebp
  800d26:	c3                   	ret    

00800d27 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d27:	55                   	push   %ebp
  800d28:	89 e5                	mov    %esp,%ebp
  800d2a:	57                   	push   %edi
  800d2b:	56                   	push   %esi
  800d2c:	53                   	push   %ebx
  800d2d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d30:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d33:	0f b6 01             	movzbl (%ecx),%eax
  800d36:	3c 20                	cmp    $0x20,%al
  800d38:	74 04                	je     800d3e <strtol+0x17>
  800d3a:	3c 09                	cmp    $0x9,%al
  800d3c:	75 0e                	jne    800d4c <strtol+0x25>
		s++;
  800d3e:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d41:	0f b6 01             	movzbl (%ecx),%eax
  800d44:	3c 20                	cmp    $0x20,%al
  800d46:	74 f6                	je     800d3e <strtol+0x17>
  800d48:	3c 09                	cmp    $0x9,%al
  800d4a:	74 f2                	je     800d3e <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  800d4c:	3c 2b                	cmp    $0x2b,%al
  800d4e:	75 0a                	jne    800d5a <strtol+0x33>
		s++;
  800d50:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800d53:	bf 00 00 00 00       	mov    $0x0,%edi
  800d58:	eb 11                	jmp    800d6b <strtol+0x44>
  800d5a:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800d5f:	3c 2d                	cmp    $0x2d,%al
  800d61:	75 08                	jne    800d6b <strtol+0x44>
		s++, neg = 1;
  800d63:	83 c1 01             	add    $0x1,%ecx
  800d66:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d6b:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800d71:	75 15                	jne    800d88 <strtol+0x61>
  800d73:	80 39 30             	cmpb   $0x30,(%ecx)
  800d76:	75 10                	jne    800d88 <strtol+0x61>
  800d78:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800d7c:	75 7c                	jne    800dfa <strtol+0xd3>
		s += 2, base = 16;
  800d7e:	83 c1 02             	add    $0x2,%ecx
  800d81:	bb 10 00 00 00       	mov    $0x10,%ebx
  800d86:	eb 16                	jmp    800d9e <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  800d88:	85 db                	test   %ebx,%ebx
  800d8a:	75 12                	jne    800d9e <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800d8c:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800d91:	80 39 30             	cmpb   $0x30,(%ecx)
  800d94:	75 08                	jne    800d9e <strtol+0x77>
		s++, base = 8;
  800d96:	83 c1 01             	add    $0x1,%ecx
  800d99:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800d9e:	b8 00 00 00 00       	mov    $0x0,%eax
  800da3:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800da6:	0f b6 11             	movzbl (%ecx),%edx
  800da9:	8d 72 d0             	lea    -0x30(%edx),%esi
  800dac:	89 f3                	mov    %esi,%ebx
  800dae:	80 fb 09             	cmp    $0x9,%bl
  800db1:	77 08                	ja     800dbb <strtol+0x94>
			dig = *s - '0';
  800db3:	0f be d2             	movsbl %dl,%edx
  800db6:	83 ea 30             	sub    $0x30,%edx
  800db9:	eb 22                	jmp    800ddd <strtol+0xb6>
		else if (*s >= 'a' && *s <= 'z')
  800dbb:	8d 72 9f             	lea    -0x61(%edx),%esi
  800dbe:	89 f3                	mov    %esi,%ebx
  800dc0:	80 fb 19             	cmp    $0x19,%bl
  800dc3:	77 08                	ja     800dcd <strtol+0xa6>
			dig = *s - 'a' + 10;
  800dc5:	0f be d2             	movsbl %dl,%edx
  800dc8:	83 ea 57             	sub    $0x57,%edx
  800dcb:	eb 10                	jmp    800ddd <strtol+0xb6>
		else if (*s >= 'A' && *s <= 'Z')
  800dcd:	8d 72 bf             	lea    -0x41(%edx),%esi
  800dd0:	89 f3                	mov    %esi,%ebx
  800dd2:	80 fb 19             	cmp    $0x19,%bl
  800dd5:	77 16                	ja     800ded <strtol+0xc6>
			dig = *s - 'A' + 10;
  800dd7:	0f be d2             	movsbl %dl,%edx
  800dda:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800ddd:	3b 55 10             	cmp    0x10(%ebp),%edx
  800de0:	7d 0b                	jge    800ded <strtol+0xc6>
			break;
		s++, val = (val * base) + dig;
  800de2:	83 c1 01             	add    $0x1,%ecx
  800de5:	0f af 45 10          	imul   0x10(%ebp),%eax
  800de9:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800deb:	eb b9                	jmp    800da6 <strtol+0x7f>

	if (endptr)
  800ded:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800df1:	74 0d                	je     800e00 <strtol+0xd9>
		*endptr = (char *) s;
  800df3:	8b 75 0c             	mov    0xc(%ebp),%esi
  800df6:	89 0e                	mov    %ecx,(%esi)
  800df8:	eb 06                	jmp    800e00 <strtol+0xd9>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800dfa:	85 db                	test   %ebx,%ebx
  800dfc:	74 98                	je     800d96 <strtol+0x6f>
  800dfe:	eb 9e                	jmp    800d9e <strtol+0x77>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800e00:	89 c2                	mov    %eax,%edx
  800e02:	f7 da                	neg    %edx
  800e04:	85 ff                	test   %edi,%edi
  800e06:	0f 45 c2             	cmovne %edx,%eax
}
  800e09:	5b                   	pop    %ebx
  800e0a:	5e                   	pop    %esi
  800e0b:	5f                   	pop    %edi
  800e0c:	5d                   	pop    %ebp
  800e0d:	c3                   	ret    
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
