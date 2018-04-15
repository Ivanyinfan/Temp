
obj/user/testbss:     file format elf32-i386


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
  80002c:	e8 cb 00 00 00       	call   8000fc <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

uint32_t bigarray[ARRAYSIZE];

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 14             	sub    $0x14,%esp
	int i;

	cprintf("Making sure bss works right...\n");
  800039:	68 54 11 80 00       	push   $0x801154
  80003e:	e8 f4 01 00 00       	call   800237 <cprintf>
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != 0)
  800043:	83 c4 10             	add    $0x10,%esp
  800046:	83 3d 20 20 80 00 00 	cmpl   $0x0,0x802020
  80004d:	75 11                	jne    800060 <umain+0x2d>
  80004f:	b8 01 00 00 00       	mov    $0x1,%eax
  800054:	83 3c 85 20 20 80 00 	cmpl   $0x0,0x802020(,%eax,4)
  80005b:	00 
  80005c:	74 19                	je     800077 <umain+0x44>
  80005e:	eb 05                	jmp    800065 <umain+0x32>
umain(int argc, char **argv)
{
	int i;

	cprintf("Making sure bss works right...\n");
	for (i = 0; i < ARRAYSIZE; i++)
  800060:	b8 00 00 00 00       	mov    $0x0,%eax
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
  800065:	50                   	push   %eax
  800066:	68 cf 11 80 00       	push   $0x8011cf
  80006b:	6a 11                	push   $0x11
  80006d:	68 ec 11 80 00       	push   $0x8011ec
  800072:	e8 cd 00 00 00       	call   800144 <_panic>
umain(int argc, char **argv)
{
	int i;

	cprintf("Making sure bss works right...\n");
	for (i = 0; i < ARRAYSIZE; i++)
  800077:	83 c0 01             	add    $0x1,%eax
  80007a:	3d 00 00 10 00       	cmp    $0x100000,%eax
  80007f:	75 d3                	jne    800054 <umain+0x21>
  800081:	b8 00 00 00 00       	mov    $0x0,%eax
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
		bigarray[i] = i;
  800086:	89 04 85 20 20 80 00 	mov    %eax,0x802020(,%eax,4)

	cprintf("Making sure bss works right...\n");
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
  80008d:	83 c0 01             	add    $0x1,%eax
  800090:	3d 00 00 10 00       	cmp    $0x100000,%eax
  800095:	75 ef                	jne    800086 <umain+0x53>
		bigarray[i] = i;
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != i)
  800097:	83 3d 20 20 80 00 00 	cmpl   $0x0,0x802020
  80009e:	75 10                	jne    8000b0 <umain+0x7d>
  8000a0:	b8 01 00 00 00       	mov    $0x1,%eax
  8000a5:	3b 04 85 20 20 80 00 	cmp    0x802020(,%eax,4),%eax
  8000ac:	74 19                	je     8000c7 <umain+0x94>
  8000ae:	eb 05                	jmp    8000b5 <umain+0x82>
  8000b0:	b8 00 00 00 00       	mov    $0x0,%eax
			panic("bigarray[%d] didn't hold its value!\n", i);
  8000b5:	50                   	push   %eax
  8000b6:	68 74 11 80 00       	push   $0x801174
  8000bb:	6a 16                	push   $0x16
  8000bd:	68 ec 11 80 00       	push   $0x8011ec
  8000c2:	e8 7d 00 00 00       	call   800144 <_panic>
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
		bigarray[i] = i;
	for (i = 0; i < ARRAYSIZE; i++)
  8000c7:	83 c0 01             	add    $0x1,%eax
  8000ca:	3d 00 00 10 00       	cmp    $0x100000,%eax
  8000cf:	75 d4                	jne    8000a5 <umain+0x72>
		if (bigarray[i] != i)
			panic("bigarray[%d] didn't hold its value!\n", i);

	cprintf("Yes, good.  Now doing a wild write off the end...\n");
  8000d1:	83 ec 0c             	sub    $0xc,%esp
  8000d4:	68 9c 11 80 00       	push   $0x80119c
  8000d9:	e8 59 01 00 00       	call   800237 <cprintf>
	bigarray[ARRAYSIZE+1024] = 0;
  8000de:	c7 05 20 30 c0 00 00 	movl   $0x0,0xc03020
  8000e5:	00 00 00 
	panic("SHOULD HAVE TRAPPED!!!");
  8000e8:	83 c4 0c             	add    $0xc,%esp
  8000eb:	68 fb 11 80 00       	push   $0x8011fb
  8000f0:	6a 1a                	push   $0x1a
  8000f2:	68 ec 11 80 00       	push   $0x8011ec
  8000f7:	e8 48 00 00 00       	call   800144 <_panic>

008000fc <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000fc:	55                   	push   %ebp
  8000fd:	89 e5                	mov    %esp,%ebp
  8000ff:	83 ec 08             	sub    $0x8,%esp
  800102:	8b 45 08             	mov    0x8(%ebp),%eax
  800105:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800108:	c7 05 20 20 c0 00 00 	movl   $0x0,0xc02020
  80010f:	00 00 00 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800112:	85 c0                	test   %eax,%eax
  800114:	7e 08                	jle    80011e <libmain+0x22>
		binaryname = argv[0];
  800116:	8b 0a                	mov    (%edx),%ecx
  800118:	89 0d 00 20 80 00    	mov    %ecx,0x802000

	// call user main routine
	umain(argc, argv);
  80011e:	83 ec 08             	sub    $0x8,%esp
  800121:	52                   	push   %edx
  800122:	50                   	push   %eax
  800123:	e8 0b ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800128:	e8 05 00 00 00       	call   800132 <exit>
}
  80012d:	83 c4 10             	add    $0x10,%esp
  800130:	c9                   	leave  
  800131:	c3                   	ret    

00800132 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800132:	55                   	push   %ebp
  800133:	89 e5                	mov    %esp,%ebp
  800135:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800138:	6a 00                	push   $0x0
  80013a:	e8 cf 0c 00 00       	call   800e0e <sys_env_destroy>
}
  80013f:	83 c4 10             	add    $0x10,%esp
  800142:	c9                   	leave  
  800143:	c3                   	ret    

00800144 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800144:	55                   	push   %ebp
  800145:	89 e5                	mov    %esp,%ebp
  800147:	56                   	push   %esi
  800148:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800149:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	if (argv0)
  80014c:	a1 24 20 c0 00       	mov    0xc02024,%eax
  800151:	85 c0                	test   %eax,%eax
  800153:	74 11                	je     800166 <_panic+0x22>
		cprintf("%s: ", argv0);
  800155:	83 ec 08             	sub    $0x8,%esp
  800158:	50                   	push   %eax
  800159:	68 1c 12 80 00       	push   $0x80121c
  80015e:	e8 d4 00 00 00       	call   800237 <cprintf>
  800163:	83 c4 10             	add    $0x10,%esp
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800166:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80016c:	e8 e3 0c 00 00       	call   800e54 <sys_getenvid>
  800171:	83 ec 0c             	sub    $0xc,%esp
  800174:	ff 75 0c             	pushl  0xc(%ebp)
  800177:	ff 75 08             	pushl  0x8(%ebp)
  80017a:	56                   	push   %esi
  80017b:	50                   	push   %eax
  80017c:	68 24 12 80 00       	push   $0x801224
  800181:	e8 b1 00 00 00       	call   800237 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800186:	83 c4 18             	add    $0x18,%esp
  800189:	53                   	push   %ebx
  80018a:	ff 75 10             	pushl  0x10(%ebp)
  80018d:	e8 54 00 00 00       	call   8001e6 <vcprintf>
	cprintf("\n");
  800192:	c7 04 24 ea 11 80 00 	movl   $0x8011ea,(%esp)
  800199:	e8 99 00 00 00       	call   800237 <cprintf>
  80019e:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001a1:	cc                   	int3   
  8001a2:	eb fd                	jmp    8001a1 <_panic+0x5d>

008001a4 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001a4:	55                   	push   %ebp
  8001a5:	89 e5                	mov    %esp,%ebp
  8001a7:	53                   	push   %ebx
  8001a8:	83 ec 04             	sub    $0x4,%esp
  8001ab:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001ae:	8b 13                	mov    (%ebx),%edx
  8001b0:	8d 42 01             	lea    0x1(%edx),%eax
  8001b3:	89 03                	mov    %eax,(%ebx)
  8001b5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001b8:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001bc:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001c1:	75 1a                	jne    8001dd <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8001c3:	83 ec 08             	sub    $0x8,%esp
  8001c6:	68 ff 00 00 00       	push   $0xff
  8001cb:	8d 43 08             	lea    0x8(%ebx),%eax
  8001ce:	50                   	push   %eax
  8001cf:	e8 ed 0b 00 00       	call   800dc1 <sys_cputs>
		b->idx = 0;
  8001d4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001da:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001dd:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001e1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001e4:	c9                   	leave  
  8001e5:	c3                   	ret    

008001e6 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001e6:	55                   	push   %ebp
  8001e7:	89 e5                	mov    %esp,%ebp
  8001e9:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001ef:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001f6:	00 00 00 
	b.cnt = 0;
  8001f9:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800200:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800203:	ff 75 0c             	pushl  0xc(%ebp)
  800206:	ff 75 08             	pushl  0x8(%ebp)
  800209:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80020f:	50                   	push   %eax
  800210:	68 a4 01 80 00       	push   $0x8001a4
  800215:	e8 45 02 00 00       	call   80045f <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80021a:	83 c4 08             	add    $0x8,%esp
  80021d:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800223:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800229:	50                   	push   %eax
  80022a:	e8 92 0b 00 00       	call   800dc1 <sys_cputs>

	return b.cnt;
}
  80022f:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800235:	c9                   	leave  
  800236:	c3                   	ret    

00800237 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800237:	55                   	push   %ebp
  800238:	89 e5                	mov    %esp,%ebp
  80023a:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80023d:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800240:	50                   	push   %eax
  800241:	ff 75 08             	pushl  0x8(%ebp)
  800244:	e8 9d ff ff ff       	call   8001e6 <vcprintf>
	va_end(ap);

	return cnt;
}
  800249:	c9                   	leave  
  80024a:	c3                   	ret    

0080024b <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80024b:	55                   	push   %ebp
  80024c:	89 e5                	mov    %esp,%ebp
  80024e:	57                   	push   %edi
  80024f:	56                   	push   %esi
  800250:	53                   	push   %ebx
  800251:	83 ec 1c             	sub    $0x1c,%esp
  800254:	89 c7                	mov    %eax,%edi
  800256:	89 d6                	mov    %edx,%esi
  800258:	8b 45 08             	mov    0x8(%ebp),%eax
  80025b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80025e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800261:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	// if cprintf'parameter includes pattern of the form "%-", padding
	// space on the right side if neccesary.
	// you can add helper function if needed.
	// your code here:
	int length,showsign=0;
	if(padc=='-'&&num>=base)
  800264:	83 7d 18 2d          	cmpl   $0x2d,0x18(%ebp)
  800268:	0f 85 8a 00 00 00    	jne    8002f8 <printnum+0xad>
  80026e:	8b 45 10             	mov    0x10(%ebp),%eax
  800271:	ba 00 00 00 00       	mov    $0x0,%edx
  800276:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800279:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80027c:	39 da                	cmp    %ebx,%edx
  80027e:	72 09                	jb     800289 <printnum+0x3e>
  800280:	39 4d 10             	cmp    %ecx,0x10(%ebp)
  800283:	0f 87 87 00 00 00    	ja     800310 <printnum+0xc5>
	{
		length=*(int *)putdat;
  800289:	8b 1e                	mov    (%esi),%ebx
		printnum(putch,putdat,num/base,base,0,padc);
  80028b:	83 ec 0c             	sub    $0xc,%esp
  80028e:	6a 2d                	push   $0x2d
  800290:	6a 00                	push   $0x0
  800292:	ff 75 10             	pushl  0x10(%ebp)
  800295:	83 ec 08             	sub    $0x8,%esp
  800298:	52                   	push   %edx
  800299:	50                   	push   %eax
  80029a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80029d:	ff 75 e0             	pushl  -0x20(%ebp)
  8002a0:	e8 2b 0c 00 00       	call   800ed0 <__udivdi3>
  8002a5:	83 c4 18             	add    $0x18,%esp
  8002a8:	52                   	push   %edx
  8002a9:	50                   	push   %eax
  8002aa:	89 f2                	mov    %esi,%edx
  8002ac:	89 f8                	mov    %edi,%eax
  8002ae:	e8 98 ff ff ff       	call   80024b <printnum>
		while (--width > 0)
			putch(padc, putdat);
	}
	}
	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002b3:	83 c4 18             	add    $0x18,%esp
  8002b6:	56                   	push   %esi
  8002b7:	8b 45 10             	mov    0x10(%ebp),%eax
  8002ba:	ba 00 00 00 00       	mov    $0x0,%edx
  8002bf:	83 ec 04             	sub    $0x4,%esp
  8002c2:	52                   	push   %edx
  8002c3:	50                   	push   %eax
  8002c4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002c7:	ff 75 e0             	pushl  -0x20(%ebp)
  8002ca:	e8 31 0d 00 00       	call   801000 <__umoddi3>
  8002cf:	83 c4 14             	add    $0x14,%esp
  8002d2:	0f be 80 47 12 80 00 	movsbl 0x801247(%eax),%eax
  8002d9:	50                   	push   %eax
  8002da:	ff d7                	call   *%edi
	
	if(padc=='-'&&width>0)
  8002dc:	83 c4 10             	add    $0x10,%esp
  8002df:	83 7d 18 2d          	cmpl   $0x2d,0x18(%ebp)
  8002e3:	0f 85 fa 00 00 00    	jne    8003e3 <printnum+0x198>
  8002e9:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
  8002ed:	0f 8f 9b 00 00 00    	jg     80038e <printnum+0x143>
  8002f3:	e9 eb 00 00 00       	jmp    8003e3 <printnum+0x198>
	}
	else
	{
	
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002f8:	8b 45 10             	mov    0x10(%ebp),%eax
  8002fb:	ba 00 00 00 00       	mov    $0x0,%edx
  800300:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800303:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800306:	83 fb 00             	cmp    $0x0,%ebx
  800309:	77 14                	ja     80031f <printnum+0xd4>
  80030b:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  80030e:	73 0f                	jae    80031f <printnum+0xd4>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800310:	8b 45 14             	mov    0x14(%ebp),%eax
  800313:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800316:	85 db                	test   %ebx,%ebx
  800318:	7f 61                	jg     80037b <printnum+0x130>
  80031a:	e9 98 00 00 00       	jmp    8003b7 <printnum+0x16c>
	else
	{
	
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80031f:	83 ec 0c             	sub    $0xc,%esp
  800322:	ff 75 18             	pushl  0x18(%ebp)
  800325:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800328:	8d 59 ff             	lea    -0x1(%ecx),%ebx
  80032b:	53                   	push   %ebx
  80032c:	ff 75 10             	pushl  0x10(%ebp)
  80032f:	83 ec 08             	sub    $0x8,%esp
  800332:	52                   	push   %edx
  800333:	50                   	push   %eax
  800334:	ff 75 e4             	pushl  -0x1c(%ebp)
  800337:	ff 75 e0             	pushl  -0x20(%ebp)
  80033a:	e8 91 0b 00 00       	call   800ed0 <__udivdi3>
  80033f:	83 c4 18             	add    $0x18,%esp
  800342:	52                   	push   %edx
  800343:	50                   	push   %eax
  800344:	89 f2                	mov    %esi,%edx
  800346:	89 f8                	mov    %edi,%eax
  800348:	e8 fe fe ff ff       	call   80024b <printnum>
		while (--width > 0)
			putch(padc, putdat);
	}
	}
	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80034d:	83 c4 18             	add    $0x18,%esp
  800350:	56                   	push   %esi
  800351:	8b 45 10             	mov    0x10(%ebp),%eax
  800354:	ba 00 00 00 00       	mov    $0x0,%edx
  800359:	83 ec 04             	sub    $0x4,%esp
  80035c:	52                   	push   %edx
  80035d:	50                   	push   %eax
  80035e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800361:	ff 75 e0             	pushl  -0x20(%ebp)
  800364:	e8 97 0c 00 00       	call   801000 <__umoddi3>
  800369:	83 c4 14             	add    $0x14,%esp
  80036c:	0f be 80 47 12 80 00 	movsbl 0x801247(%eax),%eax
  800373:	50                   	push   %eax
  800374:	ff d7                	call   *%edi
  800376:	83 c4 10             	add    $0x10,%esp
  800379:	eb 68                	jmp    8003e3 <printnum+0x198>
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80037b:	83 ec 08             	sub    $0x8,%esp
  80037e:	56                   	push   %esi
  80037f:	ff 75 18             	pushl  0x18(%ebp)
  800382:	ff d7                	call   *%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800384:	83 c4 10             	add    $0x10,%esp
  800387:	83 eb 01             	sub    $0x1,%ebx
  80038a:	75 ef                	jne    80037b <printnum+0x130>
  80038c:	eb 29                	jmp    8003b7 <printnum+0x16c>
	putch("0123456789abcdef"[num % base], putdat);
	
	if(padc=='-'&&width>0)
	{
		length=*(int *)putdat-length;
		for(int i=0;i<width-length;++i)
  80038e:	8b 45 14             	mov    0x14(%ebp),%eax
  800391:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800394:	2b 06                	sub    (%esi),%eax
  800396:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800399:	85 c0                	test   %eax,%eax
  80039b:	7e 46                	jle    8003e3 <printnum+0x198>
  80039d:	bb 00 00 00 00       	mov    $0x0,%ebx
			putch(' ',putdat);
  8003a2:	83 ec 08             	sub    $0x8,%esp
  8003a5:	56                   	push   %esi
  8003a6:	6a 20                	push   $0x20
  8003a8:	ff d7                	call   *%edi
	putch("0123456789abcdef"[num % base], putdat);
	
	if(padc=='-'&&width>0)
	{
		length=*(int *)putdat-length;
		for(int i=0;i<width-length;++i)
  8003aa:	83 c3 01             	add    $0x1,%ebx
  8003ad:	83 c4 10             	add    $0x10,%esp
  8003b0:	3b 5d e0             	cmp    -0x20(%ebp),%ebx
  8003b3:	75 ed                	jne    8003a2 <printnum+0x157>
  8003b5:	eb 2c                	jmp    8003e3 <printnum+0x198>
		while (--width > 0)
			putch(padc, putdat);
	}
	}
	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003b7:	83 ec 08             	sub    $0x8,%esp
  8003ba:	56                   	push   %esi
  8003bb:	8b 45 10             	mov    0x10(%ebp),%eax
  8003be:	ba 00 00 00 00       	mov    $0x0,%edx
  8003c3:	83 ec 04             	sub    $0x4,%esp
  8003c6:	52                   	push   %edx
  8003c7:	50                   	push   %eax
  8003c8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003cb:	ff 75 e0             	pushl  -0x20(%ebp)
  8003ce:	e8 2d 0c 00 00       	call   801000 <__umoddi3>
  8003d3:	83 c4 14             	add    $0x14,%esp
  8003d6:	0f be 80 47 12 80 00 	movsbl 0x801247(%eax),%eax
  8003dd:	50                   	push   %eax
  8003de:	ff d7                	call   *%edi
  8003e0:	83 c4 10             	add    $0x10,%esp
	{
		length=*(int *)putdat-length;
		for(int i=0;i<width-length;++i)
			putch(' ',putdat);
	}
}
  8003e3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003e6:	5b                   	pop    %ebx
  8003e7:	5e                   	pop    %esi
  8003e8:	5f                   	pop    %edi
  8003e9:	5d                   	pop    %ebp
  8003ea:	c3                   	ret    

008003eb <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003eb:	55                   	push   %ebp
  8003ec:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003ee:	83 fa 01             	cmp    $0x1,%edx
  8003f1:	7e 0e                	jle    800401 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003f3:	8b 10                	mov    (%eax),%edx
  8003f5:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003f8:	89 08                	mov    %ecx,(%eax)
  8003fa:	8b 02                	mov    (%edx),%eax
  8003fc:	8b 52 04             	mov    0x4(%edx),%edx
  8003ff:	eb 22                	jmp    800423 <getuint+0x38>
	else if (lflag)
  800401:	85 d2                	test   %edx,%edx
  800403:	74 10                	je     800415 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800405:	8b 10                	mov    (%eax),%edx
  800407:	8d 4a 04             	lea    0x4(%edx),%ecx
  80040a:	89 08                	mov    %ecx,(%eax)
  80040c:	8b 02                	mov    (%edx),%eax
  80040e:	ba 00 00 00 00       	mov    $0x0,%edx
  800413:	eb 0e                	jmp    800423 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800415:	8b 10                	mov    (%eax),%edx
  800417:	8d 4a 04             	lea    0x4(%edx),%ecx
  80041a:	89 08                	mov    %ecx,(%eax)
  80041c:	8b 02                	mov    (%edx),%eax
  80041e:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800423:	5d                   	pop    %ebp
  800424:	c3                   	ret    

00800425 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800425:	55                   	push   %ebp
  800426:	89 e5                	mov    %esp,%ebp
  800428:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80042b:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80042f:	8b 10                	mov    (%eax),%edx
  800431:	3b 50 04             	cmp    0x4(%eax),%edx
  800434:	73 0a                	jae    800440 <sprintputch+0x1b>
		*b->buf++ = ch;
  800436:	8d 4a 01             	lea    0x1(%edx),%ecx
  800439:	89 08                	mov    %ecx,(%eax)
  80043b:	8b 45 08             	mov    0x8(%ebp),%eax
  80043e:	88 02                	mov    %al,(%edx)
}
  800440:	5d                   	pop    %ebp
  800441:	c3                   	ret    

00800442 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800442:	55                   	push   %ebp
  800443:	89 e5                	mov    %esp,%ebp
  800445:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800448:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80044b:	50                   	push   %eax
  80044c:	ff 75 10             	pushl  0x10(%ebp)
  80044f:	ff 75 0c             	pushl  0xc(%ebp)
  800452:	ff 75 08             	pushl  0x8(%ebp)
  800455:	e8 05 00 00 00       	call   80045f <vprintfmt>
	va_end(ap);
}
  80045a:	83 c4 10             	add    $0x10,%esp
  80045d:	c9                   	leave  
  80045e:	c3                   	ret    

0080045f <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80045f:	55                   	push   %ebp
  800460:	89 e5                	mov    %esp,%ebp
  800462:	57                   	push   %edi
  800463:	56                   	push   %esi
  800464:	53                   	push   %ebx
  800465:	83 ec 2c             	sub    $0x2c,%esp
  800468:	8b 7d 08             	mov    0x8(%ebp),%edi
  80046b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80046e:	eb 03                	jmp    800473 <vprintfmt+0x14>
			break;
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
			for (fmt--; fmt[-1] != '%'; fmt--)
  800470:	89 75 10             	mov    %esi,0x10(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800473:	8b 45 10             	mov    0x10(%ebp),%eax
  800476:	8d 70 01             	lea    0x1(%eax),%esi
  800479:	0f b6 00             	movzbl (%eax),%eax
  80047c:	83 f8 25             	cmp    $0x25,%eax
  80047f:	74 27                	je     8004a8 <vprintfmt+0x49>
			if (ch == '\0')
  800481:	85 c0                	test   %eax,%eax
  800483:	75 0d                	jne    800492 <vprintfmt+0x33>
  800485:	e9 8b 04 00 00       	jmp    800915 <vprintfmt+0x4b6>
  80048a:	85 c0                	test   %eax,%eax
  80048c:	0f 84 83 04 00 00    	je     800915 <vprintfmt+0x4b6>
				return;
			putch(ch, putdat);
  800492:	83 ec 08             	sub    $0x8,%esp
  800495:	53                   	push   %ebx
  800496:	50                   	push   %eax
  800497:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800499:	83 c6 01             	add    $0x1,%esi
  80049c:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  8004a0:	83 c4 10             	add    $0x10,%esp
  8004a3:	83 f8 25             	cmp    $0x25,%eax
  8004a6:	75 e2                	jne    80048a <vprintfmt+0x2b>
			padc = '-';
			goto reswitch;
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004a8:	c6 45 e3 20          	movb   $0x20,-0x1d(%ebp)
  8004ac:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8004b3:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8004ba:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8004c1:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  8004c8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004cd:	eb 07                	jmp    8004d6 <vprintfmt+0x77>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004cf:	8b 75 10             	mov    0x10(%ebp),%esi

		// flag to show the sign
		case '+':
			padc='+';
  8004d2:	c6 45 e3 2b          	movb   $0x2b,-0x1d(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d6:	8d 46 01             	lea    0x1(%esi),%eax
  8004d9:	89 45 10             	mov    %eax,0x10(%ebp)
  8004dc:	0f b6 06             	movzbl (%esi),%eax
  8004df:	0f b6 d0             	movzbl %al,%edx
  8004e2:	83 e8 23             	sub    $0x23,%eax
  8004e5:	3c 55                	cmp    $0x55,%al
  8004e7:	0f 87 e9 03 00 00    	ja     8008d6 <vprintfmt+0x477>
  8004ed:	0f b6 c0             	movzbl %al,%eax
  8004f0:	ff 24 85 50 13 80 00 	jmp    *0x801350(,%eax,4)
  8004f7:	8b 75 10             	mov    0x10(%ebp),%esi
			padc='+';
			goto reswitch;
		
		// flag to pad on the right
		case '-':
			padc = '-';
  8004fa:	c6 45 e3 2d          	movb   $0x2d,-0x1d(%ebp)
  8004fe:	eb d6                	jmp    8004d6 <vprintfmt+0x77>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800500:	8d 42 d0             	lea    -0x30(%edx),%eax
  800503:	89 45 d0             	mov    %eax,-0x30(%ebp)
				ch = *fmt;
  800506:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  80050a:	8d 50 d0             	lea    -0x30(%eax),%edx
  80050d:	83 fa 09             	cmp    $0x9,%edx
  800510:	77 66                	ja     800578 <vprintfmt+0x119>
  800512:	8b 75 10             	mov    0x10(%ebp),%esi
  800515:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800518:	89 7d 08             	mov    %edi,0x8(%ebp)
  80051b:	eb 09                	jmp    800526 <vprintfmt+0xc7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80051d:	8b 75 10             	mov    0x10(%ebp),%esi
			padc = '-';
			goto reswitch;
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800520:	c6 45 e3 30          	movb   $0x30,-0x1d(%ebp)
			goto reswitch;
  800524:	eb b0                	jmp    8004d6 <vprintfmt+0x77>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800526:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  800529:	8d 14 92             	lea    (%edx,%edx,4),%edx
  80052c:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  800530:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800533:	8d 78 d0             	lea    -0x30(%eax),%edi
  800536:	83 ff 09             	cmp    $0x9,%edi
  800539:	76 eb                	jbe    800526 <vprintfmt+0xc7>
  80053b:	89 55 d0             	mov    %edx,-0x30(%ebp)
  80053e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800541:	eb 38                	jmp    80057b <vprintfmt+0x11c>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800543:	8b 45 14             	mov    0x14(%ebp),%eax
  800546:	8d 50 04             	lea    0x4(%eax),%edx
  800549:	89 55 14             	mov    %edx,0x14(%ebp)
  80054c:	8b 00                	mov    (%eax),%eax
  80054e:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800551:	8b 75 10             	mov    0x10(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800554:	eb 25                	jmp    80057b <vprintfmt+0x11c>
  800556:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800559:	85 c0                	test   %eax,%eax
  80055b:	0f 48 c1             	cmovs  %ecx,%eax
  80055e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800561:	8b 75 10             	mov    0x10(%ebp),%esi
  800564:	e9 6d ff ff ff       	jmp    8004d6 <vprintfmt+0x77>
  800569:	8b 75 10             	mov    0x10(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80056c:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800573:	e9 5e ff ff ff       	jmp    8004d6 <vprintfmt+0x77>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800578:	8b 75 10             	mov    0x10(%ebp),%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80057b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80057f:	0f 89 51 ff ff ff    	jns    8004d6 <vprintfmt+0x77>
				width = precision, precision = -1;
  800585:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800588:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80058b:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800592:	e9 3f ff ff ff       	jmp    8004d6 <vprintfmt+0x77>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800597:	83 45 cc 01          	addl   $0x1,-0x34(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80059b:	8b 75 10             	mov    0x10(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80059e:	e9 33 ff ff ff       	jmp    8004d6 <vprintfmt+0x77>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8005a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a6:	8d 50 04             	lea    0x4(%eax),%edx
  8005a9:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ac:	83 ec 08             	sub    $0x8,%esp
  8005af:	53                   	push   %ebx
  8005b0:	ff 30                	pushl  (%eax)
  8005b2:	ff d7                	call   *%edi
			break;
  8005b4:	83 c4 10             	add    $0x10,%esp
  8005b7:	e9 b7 fe ff ff       	jmp    800473 <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8005bc:	8b 45 14             	mov    0x14(%ebp),%eax
  8005bf:	8d 50 04             	lea    0x4(%eax),%edx
  8005c2:	89 55 14             	mov    %edx,0x14(%ebp)
  8005c5:	8b 00                	mov    (%eax),%eax
  8005c7:	99                   	cltd   
  8005c8:	31 d0                	xor    %edx,%eax
  8005ca:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005cc:	83 f8 06             	cmp    $0x6,%eax
  8005cf:	7f 0b                	jg     8005dc <vprintfmt+0x17d>
  8005d1:	8b 14 85 a8 14 80 00 	mov    0x8014a8(,%eax,4),%edx
  8005d8:	85 d2                	test   %edx,%edx
  8005da:	75 15                	jne    8005f1 <vprintfmt+0x192>
				printfmt(putch, putdat, "error %d", err);
  8005dc:	50                   	push   %eax
  8005dd:	68 5f 12 80 00       	push   $0x80125f
  8005e2:	53                   	push   %ebx
  8005e3:	57                   	push   %edi
  8005e4:	e8 59 fe ff ff       	call   800442 <printfmt>
  8005e9:	83 c4 10             	add    $0x10,%esp
  8005ec:	e9 82 fe ff ff       	jmp    800473 <vprintfmt+0x14>
			else
				printfmt(putch, putdat, "%s", p);
  8005f1:	52                   	push   %edx
  8005f2:	68 68 12 80 00       	push   $0x801268
  8005f7:	53                   	push   %ebx
  8005f8:	57                   	push   %edi
  8005f9:	e8 44 fe ff ff       	call   800442 <printfmt>
  8005fe:	83 c4 10             	add    $0x10,%esp
  800601:	e9 6d fe ff ff       	jmp    800473 <vprintfmt+0x14>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800606:	8b 45 14             	mov    0x14(%ebp),%eax
  800609:	8d 50 04             	lea    0x4(%eax),%edx
  80060c:	89 55 14             	mov    %edx,0x14(%ebp)
  80060f:	8b 00                	mov    (%eax),%eax
				p = "(null)";
  800611:	85 c0                	test   %eax,%eax
  800613:	b9 58 12 80 00       	mov    $0x801258,%ecx
  800618:	0f 45 c8             	cmovne %eax,%ecx
  80061b:	89 4d cc             	mov    %ecx,-0x34(%ebp)
			if (width > 0 && padc != '-')
  80061e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800622:	7e 06                	jle    80062a <vprintfmt+0x1cb>
  800624:	80 7d e3 2d          	cmpb   $0x2d,-0x1d(%ebp)
  800628:	75 19                	jne    800643 <vprintfmt+0x1e4>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80062a:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80062d:	8d 70 01             	lea    0x1(%eax),%esi
  800630:	0f b6 00             	movzbl (%eax),%eax
  800633:	0f be d0             	movsbl %al,%edx
  800636:	85 d2                	test   %edx,%edx
  800638:	0f 85 9f 00 00 00    	jne    8006dd <vprintfmt+0x27e>
  80063e:	e9 8c 00 00 00       	jmp    8006cf <vprintfmt+0x270>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800643:	83 ec 08             	sub    $0x8,%esp
  800646:	ff 75 d0             	pushl  -0x30(%ebp)
  800649:	ff 75 cc             	pushl  -0x34(%ebp)
  80064c:	e8 56 03 00 00       	call   8009a7 <strnlen>
  800651:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  800654:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800657:	83 c4 10             	add    $0x10,%esp
  80065a:	85 c9                	test   %ecx,%ecx
  80065c:	0f 8e 9a 02 00 00    	jle    8008fc <vprintfmt+0x49d>
					putch(padc, putdat);
  800662:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  800666:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800669:	89 cb                	mov    %ecx,%ebx
  80066b:	83 ec 08             	sub    $0x8,%esp
  80066e:	ff 75 0c             	pushl  0xc(%ebp)
  800671:	56                   	push   %esi
  800672:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800674:	83 c4 10             	add    $0x10,%esp
  800677:	83 eb 01             	sub    $0x1,%ebx
  80067a:	75 ef                	jne    80066b <vprintfmt+0x20c>
  80067c:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80067f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800682:	e9 75 02 00 00       	jmp    8008fc <vprintfmt+0x49d>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800687:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80068b:	74 1b                	je     8006a8 <vprintfmt+0x249>
  80068d:	0f be c0             	movsbl %al,%eax
  800690:	83 e8 20             	sub    $0x20,%eax
  800693:	83 f8 5e             	cmp    $0x5e,%eax
  800696:	76 10                	jbe    8006a8 <vprintfmt+0x249>
					putch('?', putdat);
  800698:	83 ec 08             	sub    $0x8,%esp
  80069b:	ff 75 0c             	pushl  0xc(%ebp)
  80069e:	6a 3f                	push   $0x3f
  8006a0:	ff 55 08             	call   *0x8(%ebp)
  8006a3:	83 c4 10             	add    $0x10,%esp
  8006a6:	eb 0d                	jmp    8006b5 <vprintfmt+0x256>
				else
					putch(ch, putdat);
  8006a8:	83 ec 08             	sub    $0x8,%esp
  8006ab:	ff 75 0c             	pushl  0xc(%ebp)
  8006ae:	52                   	push   %edx
  8006af:	ff 55 08             	call   *0x8(%ebp)
  8006b2:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006b5:	83 ef 01             	sub    $0x1,%edi
  8006b8:	83 c6 01             	add    $0x1,%esi
  8006bb:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  8006bf:	0f be d0             	movsbl %al,%edx
  8006c2:	85 d2                	test   %edx,%edx
  8006c4:	75 31                	jne    8006f7 <vprintfmt+0x298>
  8006c6:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8006c9:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006cc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006cf:	8b 75 e4             	mov    -0x1c(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006d2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8006d6:	7f 33                	jg     80070b <vprintfmt+0x2ac>
  8006d8:	e9 96 fd ff ff       	jmp    800473 <vprintfmt+0x14>
  8006dd:	89 7d 08             	mov    %edi,0x8(%ebp)
  8006e0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006e3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006e6:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8006e9:	eb 0c                	jmp    8006f7 <vprintfmt+0x298>
  8006eb:	89 7d 08             	mov    %edi,0x8(%ebp)
  8006ee:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006f1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006f4:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006f7:	85 db                	test   %ebx,%ebx
  8006f9:	78 8c                	js     800687 <vprintfmt+0x228>
  8006fb:	83 eb 01             	sub    $0x1,%ebx
  8006fe:	79 87                	jns    800687 <vprintfmt+0x228>
  800700:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800703:	8b 7d 08             	mov    0x8(%ebp),%edi
  800706:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800709:	eb c4                	jmp    8006cf <vprintfmt+0x270>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80070b:	83 ec 08             	sub    $0x8,%esp
  80070e:	53                   	push   %ebx
  80070f:	6a 20                	push   $0x20
  800711:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800713:	83 c4 10             	add    $0x10,%esp
  800716:	83 ee 01             	sub    $0x1,%esi
  800719:	75 f0                	jne    80070b <vprintfmt+0x2ac>
  80071b:	e9 53 fd ff ff       	jmp    800473 <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800720:	83 7d cc 01          	cmpl   $0x1,-0x34(%ebp)
  800724:	7e 16                	jle    80073c <vprintfmt+0x2dd>
		return va_arg(*ap, long long);
  800726:	8b 45 14             	mov    0x14(%ebp),%eax
  800729:	8d 50 08             	lea    0x8(%eax),%edx
  80072c:	89 55 14             	mov    %edx,0x14(%ebp)
  80072f:	8b 50 04             	mov    0x4(%eax),%edx
  800732:	8b 00                	mov    (%eax),%eax
  800734:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800737:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80073a:	eb 34                	jmp    800770 <vprintfmt+0x311>
	else if (lflag)
  80073c:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800740:	74 18                	je     80075a <vprintfmt+0x2fb>
		return va_arg(*ap, long);
  800742:	8b 45 14             	mov    0x14(%ebp),%eax
  800745:	8d 50 04             	lea    0x4(%eax),%edx
  800748:	89 55 14             	mov    %edx,0x14(%ebp)
  80074b:	8b 30                	mov    (%eax),%esi
  80074d:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800750:	89 f0                	mov    %esi,%eax
  800752:	c1 f8 1f             	sar    $0x1f,%eax
  800755:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800758:	eb 16                	jmp    800770 <vprintfmt+0x311>
	else
		return va_arg(*ap, int);
  80075a:	8b 45 14             	mov    0x14(%ebp),%eax
  80075d:	8d 50 04             	lea    0x4(%eax),%edx
  800760:	89 55 14             	mov    %edx,0x14(%ebp)
  800763:	8b 30                	mov    (%eax),%esi
  800765:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800768:	89 f0                	mov    %esi,%eax
  80076a:	c1 f8 1f             	sar    $0x1f,%eax
  80076d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800770:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800773:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800776:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800779:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  80077c:	85 d2                	test   %edx,%edx
  80077e:	79 28                	jns    8007a8 <vprintfmt+0x349>
				putch('-', putdat);
  800780:	83 ec 08             	sub    $0x8,%esp
  800783:	53                   	push   %ebx
  800784:	6a 2d                	push   $0x2d
  800786:	ff d7                	call   *%edi
				num = -(long long) num;
  800788:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80078b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80078e:	f7 d8                	neg    %eax
  800790:	83 d2 00             	adc    $0x0,%edx
  800793:	f7 da                	neg    %edx
  800795:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800798:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80079b:	83 c4 10             	add    $0x10,%esp
			else
			{
				if(padc=='+')
					putch('+', putdat);
			}
			base = 10;
  80079e:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007a3:	e9 a5 00 00 00       	jmp    80084d <vprintfmt+0x3ee>
  8007a8:	b8 0a 00 00 00       	mov    $0xa,%eax
				putch('-', putdat);
				num = -(long long) num;
			}
			else
			{
				if(padc=='+')
  8007ad:	80 7d e3 2b          	cmpb   $0x2b,-0x1d(%ebp)
  8007b1:	0f 85 96 00 00 00    	jne    80084d <vprintfmt+0x3ee>
					putch('+', putdat);
  8007b7:	83 ec 08             	sub    $0x8,%esp
  8007ba:	53                   	push   %ebx
  8007bb:	6a 2b                	push   $0x2b
  8007bd:	ff d7                	call   *%edi
  8007bf:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8007c2:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007c7:	e9 81 00 00 00       	jmp    80084d <vprintfmt+0x3ee>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8007cc:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8007cf:	8d 45 14             	lea    0x14(%ebp),%eax
  8007d2:	e8 14 fc ff ff       	call   8003eb <getuint>
  8007d7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007da:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  8007dd:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8007e2:	eb 69                	jmp    80084d <vprintfmt+0x3ee>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			putch('0', putdat);
  8007e4:	83 ec 08             	sub    $0x8,%esp
  8007e7:	53                   	push   %ebx
  8007e8:	6a 30                	push   $0x30
  8007ea:	ff d7                	call   *%edi
			num = getuint(&ap, lflag);
  8007ec:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8007ef:	8d 45 14             	lea    0x14(%ebp),%eax
  8007f2:	e8 f4 fb ff ff       	call   8003eb <getuint>
  8007f7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007fa:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
			goto number;
  8007fd:	83 c4 10             	add    $0x10,%esp
		case 'o':
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
  800800:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800805:	eb 46                	jmp    80084d <vprintfmt+0x3ee>

		// pointer
		case 'p':
			putch('0', putdat);
  800807:	83 ec 08             	sub    $0x8,%esp
  80080a:	53                   	push   %ebx
  80080b:	6a 30                	push   $0x30
  80080d:	ff d7                	call   *%edi
			putch('x', putdat);
  80080f:	83 c4 08             	add    $0x8,%esp
  800812:	53                   	push   %ebx
  800813:	6a 78                	push   $0x78
  800815:	ff d7                	call   *%edi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800817:	8b 45 14             	mov    0x14(%ebp),%eax
  80081a:	8d 50 04             	lea    0x4(%eax),%edx
  80081d:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800820:	8b 00                	mov    (%eax),%eax
  800822:	ba 00 00 00 00       	mov    $0x0,%edx
  800827:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80082a:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80082d:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800830:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800835:	eb 16                	jmp    80084d <vprintfmt+0x3ee>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800837:	8b 55 cc             	mov    -0x34(%ebp),%edx
  80083a:	8d 45 14             	lea    0x14(%ebp),%eax
  80083d:	e8 a9 fb ff ff       	call   8003eb <getuint>
  800842:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800845:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  800848:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  80084d:	83 ec 0c             	sub    $0xc,%esp
  800850:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  800854:	56                   	push   %esi
  800855:	ff 75 e4             	pushl  -0x1c(%ebp)
  800858:	50                   	push   %eax
  800859:	ff 75 dc             	pushl  -0x24(%ebp)
  80085c:	ff 75 d8             	pushl  -0x28(%ebp)
  80085f:	89 da                	mov    %ebx,%edx
  800861:	89 f8                	mov    %edi,%eax
  800863:	e8 e3 f9 ff ff       	call   80024b <printnum>
			break;
  800868:	83 c4 20             	add    $0x20,%esp
  80086b:	e9 03 fc ff ff       	jmp    800473 <vprintfmt+0x14>

            const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
            const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

            // Your code here
			num=(unsigned long long)(uintptr_t)va_arg(ap, void *);
  800870:	8b 45 14             	mov    0x14(%ebp),%eax
  800873:	8d 50 04             	lea    0x4(%eax),%edx
  800876:	89 55 14             	mov    %edx,0x14(%ebp)
  800879:	8b 00                	mov    (%eax),%eax
			if(!num)
  80087b:	85 c0                	test   %eax,%eax
  80087d:	75 1c                	jne    80089b <vprintfmt+0x43c>
				*(int *)putdat+=cprintf("%s",null_error);
  80087f:	83 ec 08             	sub    $0x8,%esp
  800882:	68 d4 12 80 00       	push   $0x8012d4
  800887:	68 68 12 80 00       	push   $0x801268
  80088c:	e8 a6 f9 ff ff       	call   800237 <cprintf>
  800891:	01 03                	add    %eax,(%ebx)
  800893:	83 c4 10             	add    $0x10,%esp
  800896:	e9 d8 fb ff ff       	jmp    800473 <vprintfmt+0x14>
			else
			{
				*(char *)(int)num=*(int *)putdat;
  80089b:	8b 13                	mov    (%ebx),%edx
  80089d:	88 10                	mov    %dl,(%eax)
				if((*(int *)putdat)>128)
  80089f:	81 3b 80 00 00 00    	cmpl   $0x80,(%ebx)
  8008a5:	0f 8e c8 fb ff ff    	jle    800473 <vprintfmt+0x14>
					*(int *)putdat+=cprintf("%s",overflow_error);
  8008ab:	83 ec 08             	sub    $0x8,%esp
  8008ae:	68 0c 13 80 00       	push   $0x80130c
  8008b3:	68 68 12 80 00       	push   $0x801268
  8008b8:	e8 7a f9 ff ff       	call   800237 <cprintf>
  8008bd:	01 03                	add    %eax,(%ebx)
  8008bf:	83 c4 10             	add    $0x10,%esp
  8008c2:	e9 ac fb ff ff       	jmp    800473 <vprintfmt+0x14>
            break;
        }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8008c7:	83 ec 08             	sub    $0x8,%esp
  8008ca:	53                   	push   %ebx
  8008cb:	52                   	push   %edx
  8008cc:	ff d7                	call   *%edi
			break;
  8008ce:	83 c4 10             	add    $0x10,%esp
  8008d1:	e9 9d fb ff ff       	jmp    800473 <vprintfmt+0x14>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8008d6:	83 ec 08             	sub    $0x8,%esp
  8008d9:	53                   	push   %ebx
  8008da:	6a 25                	push   $0x25
  8008dc:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008de:	83 c4 10             	add    $0x10,%esp
  8008e1:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8008e5:	0f 84 85 fb ff ff    	je     800470 <vprintfmt+0x11>
  8008eb:	83 ee 01             	sub    $0x1,%esi
  8008ee:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8008f2:	75 f7                	jne    8008eb <vprintfmt+0x48c>
  8008f4:	89 75 10             	mov    %esi,0x10(%ebp)
  8008f7:	e9 77 fb ff ff       	jmp    800473 <vprintfmt+0x14>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8008fc:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8008ff:	8d 70 01             	lea    0x1(%eax),%esi
  800902:	0f b6 00             	movzbl (%eax),%eax
  800905:	0f be d0             	movsbl %al,%edx
  800908:	85 d2                	test   %edx,%edx
  80090a:	0f 85 db fd ff ff    	jne    8006eb <vprintfmt+0x28c>
  800910:	e9 5e fb ff ff       	jmp    800473 <vprintfmt+0x14>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800915:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800918:	5b                   	pop    %ebx
  800919:	5e                   	pop    %esi
  80091a:	5f                   	pop    %edi
  80091b:	5d                   	pop    %ebp
  80091c:	c3                   	ret    

0080091d <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80091d:	55                   	push   %ebp
  80091e:	89 e5                	mov    %esp,%ebp
  800920:	83 ec 18             	sub    $0x18,%esp
  800923:	8b 45 08             	mov    0x8(%ebp),%eax
  800926:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800929:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80092c:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800930:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800933:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80093a:	85 c0                	test   %eax,%eax
  80093c:	74 26                	je     800964 <vsnprintf+0x47>
  80093e:	85 d2                	test   %edx,%edx
  800940:	7e 22                	jle    800964 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800942:	ff 75 14             	pushl  0x14(%ebp)
  800945:	ff 75 10             	pushl  0x10(%ebp)
  800948:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80094b:	50                   	push   %eax
  80094c:	68 25 04 80 00       	push   $0x800425
  800951:	e8 09 fb ff ff       	call   80045f <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800956:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800959:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80095c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80095f:	83 c4 10             	add    $0x10,%esp
  800962:	eb 05                	jmp    800969 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800964:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800969:	c9                   	leave  
  80096a:	c3                   	ret    

0080096b <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80096b:	55                   	push   %ebp
  80096c:	89 e5                	mov    %esp,%ebp
  80096e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800971:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800974:	50                   	push   %eax
  800975:	ff 75 10             	pushl  0x10(%ebp)
  800978:	ff 75 0c             	pushl  0xc(%ebp)
  80097b:	ff 75 08             	pushl  0x8(%ebp)
  80097e:	e8 9a ff ff ff       	call   80091d <vsnprintf>
	va_end(ap);

	return rc;
}
  800983:	c9                   	leave  
  800984:	c3                   	ret    

00800985 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800985:	55                   	push   %ebp
  800986:	89 e5                	mov    %esp,%ebp
  800988:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80098b:	80 3a 00             	cmpb   $0x0,(%edx)
  80098e:	74 10                	je     8009a0 <strlen+0x1b>
  800990:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800995:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800998:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80099c:	75 f7                	jne    800995 <strlen+0x10>
  80099e:	eb 05                	jmp    8009a5 <strlen+0x20>
  8009a0:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8009a5:	5d                   	pop    %ebp
  8009a6:	c3                   	ret    

008009a7 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8009a7:	55                   	push   %ebp
  8009a8:	89 e5                	mov    %esp,%ebp
  8009aa:	53                   	push   %ebx
  8009ab:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8009ae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009b1:	85 c9                	test   %ecx,%ecx
  8009b3:	74 1c                	je     8009d1 <strnlen+0x2a>
  8009b5:	80 3b 00             	cmpb   $0x0,(%ebx)
  8009b8:	74 1e                	je     8009d8 <strnlen+0x31>
  8009ba:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  8009bf:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009c1:	39 ca                	cmp    %ecx,%edx
  8009c3:	74 18                	je     8009dd <strnlen+0x36>
  8009c5:	83 c2 01             	add    $0x1,%edx
  8009c8:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  8009cd:	75 f0                	jne    8009bf <strnlen+0x18>
  8009cf:	eb 0c                	jmp    8009dd <strnlen+0x36>
  8009d1:	b8 00 00 00 00       	mov    $0x0,%eax
  8009d6:	eb 05                	jmp    8009dd <strnlen+0x36>
  8009d8:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8009dd:	5b                   	pop    %ebx
  8009de:	5d                   	pop    %ebp
  8009df:	c3                   	ret    

008009e0 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8009e0:	55                   	push   %ebp
  8009e1:	89 e5                	mov    %esp,%ebp
  8009e3:	53                   	push   %ebx
  8009e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8009ea:	89 c2                	mov    %eax,%edx
  8009ec:	83 c2 01             	add    $0x1,%edx
  8009ef:	83 c1 01             	add    $0x1,%ecx
  8009f2:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8009f6:	88 5a ff             	mov    %bl,-0x1(%edx)
  8009f9:	84 db                	test   %bl,%bl
  8009fb:	75 ef                	jne    8009ec <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8009fd:	5b                   	pop    %ebx
  8009fe:	5d                   	pop    %ebp
  8009ff:	c3                   	ret    

00800a00 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a00:	55                   	push   %ebp
  800a01:	89 e5                	mov    %esp,%ebp
  800a03:	53                   	push   %ebx
  800a04:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a07:	53                   	push   %ebx
  800a08:	e8 78 ff ff ff       	call   800985 <strlen>
  800a0d:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800a10:	ff 75 0c             	pushl  0xc(%ebp)
  800a13:	01 d8                	add    %ebx,%eax
  800a15:	50                   	push   %eax
  800a16:	e8 c5 ff ff ff       	call   8009e0 <strcpy>
	return dst;
}
  800a1b:	89 d8                	mov    %ebx,%eax
  800a1d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a20:	c9                   	leave  
  800a21:	c3                   	ret    

00800a22 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a22:	55                   	push   %ebp
  800a23:	89 e5                	mov    %esp,%ebp
  800a25:	56                   	push   %esi
  800a26:	53                   	push   %ebx
  800a27:	8b 75 08             	mov    0x8(%ebp),%esi
  800a2a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a2d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a30:	85 db                	test   %ebx,%ebx
  800a32:	74 17                	je     800a4b <strncpy+0x29>
  800a34:	01 f3                	add    %esi,%ebx
  800a36:	89 f1                	mov    %esi,%ecx
		*dst++ = *src;
  800a38:	83 c1 01             	add    $0x1,%ecx
  800a3b:	0f b6 02             	movzbl (%edx),%eax
  800a3e:	88 41 ff             	mov    %al,-0x1(%ecx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a41:	80 3a 01             	cmpb   $0x1,(%edx)
  800a44:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a47:	39 cb                	cmp    %ecx,%ebx
  800a49:	75 ed                	jne    800a38 <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a4b:	89 f0                	mov    %esi,%eax
  800a4d:	5b                   	pop    %ebx
  800a4e:	5e                   	pop    %esi
  800a4f:	5d                   	pop    %ebp
  800a50:	c3                   	ret    

00800a51 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a51:	55                   	push   %ebp
  800a52:	89 e5                	mov    %esp,%ebp
  800a54:	56                   	push   %esi
  800a55:	53                   	push   %ebx
  800a56:	8b 75 08             	mov    0x8(%ebp),%esi
  800a59:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a5c:	8b 55 10             	mov    0x10(%ebp),%edx
  800a5f:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a61:	85 d2                	test   %edx,%edx
  800a63:	74 35                	je     800a9a <strlcpy+0x49>
		while (--size > 0 && *src != '\0')
  800a65:	89 d0                	mov    %edx,%eax
  800a67:	83 e8 01             	sub    $0x1,%eax
  800a6a:	74 25                	je     800a91 <strlcpy+0x40>
  800a6c:	0f b6 0b             	movzbl (%ebx),%ecx
  800a6f:	84 c9                	test   %cl,%cl
  800a71:	74 22                	je     800a95 <strlcpy+0x44>
  800a73:	8d 53 01             	lea    0x1(%ebx),%edx
  800a76:	01 c3                	add    %eax,%ebx
  800a78:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
  800a7a:	83 c0 01             	add    $0x1,%eax
  800a7d:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a80:	39 da                	cmp    %ebx,%edx
  800a82:	74 13                	je     800a97 <strlcpy+0x46>
  800a84:	83 c2 01             	add    $0x1,%edx
  800a87:	0f b6 4a ff          	movzbl -0x1(%edx),%ecx
  800a8b:	84 c9                	test   %cl,%cl
  800a8d:	75 eb                	jne    800a7a <strlcpy+0x29>
  800a8f:	eb 06                	jmp    800a97 <strlcpy+0x46>
  800a91:	89 f0                	mov    %esi,%eax
  800a93:	eb 02                	jmp    800a97 <strlcpy+0x46>
  800a95:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800a97:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a9a:	29 f0                	sub    %esi,%eax
}
  800a9c:	5b                   	pop    %ebx
  800a9d:	5e                   	pop    %esi
  800a9e:	5d                   	pop    %ebp
  800a9f:	c3                   	ret    

00800aa0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800aa0:	55                   	push   %ebp
  800aa1:	89 e5                	mov    %esp,%ebp
  800aa3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800aa6:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800aa9:	0f b6 01             	movzbl (%ecx),%eax
  800aac:	84 c0                	test   %al,%al
  800aae:	74 15                	je     800ac5 <strcmp+0x25>
  800ab0:	3a 02                	cmp    (%edx),%al
  800ab2:	75 11                	jne    800ac5 <strcmp+0x25>
		p++, q++;
  800ab4:	83 c1 01             	add    $0x1,%ecx
  800ab7:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800aba:	0f b6 01             	movzbl (%ecx),%eax
  800abd:	84 c0                	test   %al,%al
  800abf:	74 04                	je     800ac5 <strcmp+0x25>
  800ac1:	3a 02                	cmp    (%edx),%al
  800ac3:	74 ef                	je     800ab4 <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800ac5:	0f b6 c0             	movzbl %al,%eax
  800ac8:	0f b6 12             	movzbl (%edx),%edx
  800acb:	29 d0                	sub    %edx,%eax
}
  800acd:	5d                   	pop    %ebp
  800ace:	c3                   	ret    

00800acf <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800acf:	55                   	push   %ebp
  800ad0:	89 e5                	mov    %esp,%ebp
  800ad2:	56                   	push   %esi
  800ad3:	53                   	push   %ebx
  800ad4:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800ad7:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ada:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  800add:	85 f6                	test   %esi,%esi
  800adf:	74 29                	je     800b0a <strncmp+0x3b>
  800ae1:	0f b6 03             	movzbl (%ebx),%eax
  800ae4:	84 c0                	test   %al,%al
  800ae6:	74 30                	je     800b18 <strncmp+0x49>
  800ae8:	3a 02                	cmp    (%edx),%al
  800aea:	75 2c                	jne    800b18 <strncmp+0x49>
  800aec:	8d 43 01             	lea    0x1(%ebx),%eax
  800aef:	01 de                	add    %ebx,%esi
		n--, p++, q++;
  800af1:	89 c3                	mov    %eax,%ebx
  800af3:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800af6:	39 c6                	cmp    %eax,%esi
  800af8:	74 17                	je     800b11 <strncmp+0x42>
  800afa:	0f b6 08             	movzbl (%eax),%ecx
  800afd:	84 c9                	test   %cl,%cl
  800aff:	74 17                	je     800b18 <strncmp+0x49>
  800b01:	83 c0 01             	add    $0x1,%eax
  800b04:	3a 0a                	cmp    (%edx),%cl
  800b06:	74 e9                	je     800af1 <strncmp+0x22>
  800b08:	eb 0e                	jmp    800b18 <strncmp+0x49>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800b0a:	b8 00 00 00 00       	mov    $0x0,%eax
  800b0f:	eb 0f                	jmp    800b20 <strncmp+0x51>
  800b11:	b8 00 00 00 00       	mov    $0x0,%eax
  800b16:	eb 08                	jmp    800b20 <strncmp+0x51>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b18:	0f b6 03             	movzbl (%ebx),%eax
  800b1b:	0f b6 12             	movzbl (%edx),%edx
  800b1e:	29 d0                	sub    %edx,%eax
}
  800b20:	5b                   	pop    %ebx
  800b21:	5e                   	pop    %esi
  800b22:	5d                   	pop    %ebp
  800b23:	c3                   	ret    

00800b24 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b24:	55                   	push   %ebp
  800b25:	89 e5                	mov    %esp,%ebp
  800b27:	53                   	push   %ebx
  800b28:	8b 45 08             	mov    0x8(%ebp),%eax
  800b2b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
  800b2e:	0f b6 10             	movzbl (%eax),%edx
  800b31:	84 d2                	test   %dl,%dl
  800b33:	74 1d                	je     800b52 <strchr+0x2e>
  800b35:	89 d9                	mov    %ebx,%ecx
		if (*s == c)
  800b37:	38 d3                	cmp    %dl,%bl
  800b39:	75 06                	jne    800b41 <strchr+0x1d>
  800b3b:	eb 1a                	jmp    800b57 <strchr+0x33>
  800b3d:	38 ca                	cmp    %cl,%dl
  800b3f:	74 16                	je     800b57 <strchr+0x33>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b41:	83 c0 01             	add    $0x1,%eax
  800b44:	0f b6 10             	movzbl (%eax),%edx
  800b47:	84 d2                	test   %dl,%dl
  800b49:	75 f2                	jne    800b3d <strchr+0x19>
		if (*s == c)
			return (char *) s;
	return 0;
  800b4b:	b8 00 00 00 00       	mov    $0x0,%eax
  800b50:	eb 05                	jmp    800b57 <strchr+0x33>
  800b52:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b57:	5b                   	pop    %ebx
  800b58:	5d                   	pop    %ebp
  800b59:	c3                   	ret    

00800b5a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b5a:	55                   	push   %ebp
  800b5b:	89 e5                	mov    %esp,%ebp
  800b5d:	53                   	push   %ebx
  800b5e:	8b 45 08             	mov    0x8(%ebp),%eax
  800b61:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  800b64:	0f b6 18             	movzbl (%eax),%ebx
		if (*s == c)
  800b67:	38 d3                	cmp    %dl,%bl
  800b69:	74 14                	je     800b7f <strfind+0x25>
  800b6b:	89 d1                	mov    %edx,%ecx
  800b6d:	84 db                	test   %bl,%bl
  800b6f:	74 0e                	je     800b7f <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800b71:	83 c0 01             	add    $0x1,%eax
  800b74:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800b77:	38 ca                	cmp    %cl,%dl
  800b79:	74 04                	je     800b7f <strfind+0x25>
  800b7b:	84 d2                	test   %dl,%dl
  800b7d:	75 f2                	jne    800b71 <strfind+0x17>
			break;
	return (char *) s;
}
  800b7f:	5b                   	pop    %ebx
  800b80:	5d                   	pop    %ebp
  800b81:	c3                   	ret    

00800b82 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b82:	55                   	push   %ebp
  800b83:	89 e5                	mov    %esp,%ebp
  800b85:	57                   	push   %edi
  800b86:	56                   	push   %esi
  800b87:	53                   	push   %ebx
  800b88:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b8b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b8e:	85 c9                	test   %ecx,%ecx
  800b90:	74 36                	je     800bc8 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b92:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b98:	75 28                	jne    800bc2 <memset+0x40>
  800b9a:	f6 c1 03             	test   $0x3,%cl
  800b9d:	75 23                	jne    800bc2 <memset+0x40>
		c &= 0xFF;
  800b9f:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ba3:	89 d3                	mov    %edx,%ebx
  800ba5:	c1 e3 08             	shl    $0x8,%ebx
  800ba8:	89 d6                	mov    %edx,%esi
  800baa:	c1 e6 18             	shl    $0x18,%esi
  800bad:	89 d0                	mov    %edx,%eax
  800baf:	c1 e0 10             	shl    $0x10,%eax
  800bb2:	09 f0                	or     %esi,%eax
  800bb4:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800bb6:	89 d8                	mov    %ebx,%eax
  800bb8:	09 d0                	or     %edx,%eax
  800bba:	c1 e9 02             	shr    $0x2,%ecx
  800bbd:	fc                   	cld    
  800bbe:	f3 ab                	rep stos %eax,%es:(%edi)
  800bc0:	eb 06                	jmp    800bc8 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800bc2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bc5:	fc                   	cld    
  800bc6:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800bc8:	89 f8                	mov    %edi,%eax
  800bca:	5b                   	pop    %ebx
  800bcb:	5e                   	pop    %esi
  800bcc:	5f                   	pop    %edi
  800bcd:	5d                   	pop    %ebp
  800bce:	c3                   	ret    

00800bcf <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800bcf:	55                   	push   %ebp
  800bd0:	89 e5                	mov    %esp,%ebp
  800bd2:	57                   	push   %edi
  800bd3:	56                   	push   %esi
  800bd4:	8b 45 08             	mov    0x8(%ebp),%eax
  800bd7:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bda:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800bdd:	39 c6                	cmp    %eax,%esi
  800bdf:	73 35                	jae    800c16 <memmove+0x47>
  800be1:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800be4:	39 d0                	cmp    %edx,%eax
  800be6:	73 2e                	jae    800c16 <memmove+0x47>
		s += n;
		d += n;
  800be8:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800beb:	89 d6                	mov    %edx,%esi
  800bed:	09 fe                	or     %edi,%esi
  800bef:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800bf5:	75 13                	jne    800c0a <memmove+0x3b>
  800bf7:	f6 c1 03             	test   $0x3,%cl
  800bfa:	75 0e                	jne    800c0a <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800bfc:	83 ef 04             	sub    $0x4,%edi
  800bff:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c02:	c1 e9 02             	shr    $0x2,%ecx
  800c05:	fd                   	std    
  800c06:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c08:	eb 09                	jmp    800c13 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800c0a:	83 ef 01             	sub    $0x1,%edi
  800c0d:	8d 72 ff             	lea    -0x1(%edx),%esi
  800c10:	fd                   	std    
  800c11:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c13:	fc                   	cld    
  800c14:	eb 1d                	jmp    800c33 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c16:	89 f2                	mov    %esi,%edx
  800c18:	09 c2                	or     %eax,%edx
  800c1a:	f6 c2 03             	test   $0x3,%dl
  800c1d:	75 0f                	jne    800c2e <memmove+0x5f>
  800c1f:	f6 c1 03             	test   $0x3,%cl
  800c22:	75 0a                	jne    800c2e <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800c24:	c1 e9 02             	shr    $0x2,%ecx
  800c27:	89 c7                	mov    %eax,%edi
  800c29:	fc                   	cld    
  800c2a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c2c:	eb 05                	jmp    800c33 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c2e:	89 c7                	mov    %eax,%edi
  800c30:	fc                   	cld    
  800c31:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c33:	5e                   	pop    %esi
  800c34:	5f                   	pop    %edi
  800c35:	5d                   	pop    %ebp
  800c36:	c3                   	ret    

00800c37 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800c37:	55                   	push   %ebp
  800c38:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800c3a:	ff 75 10             	pushl  0x10(%ebp)
  800c3d:	ff 75 0c             	pushl  0xc(%ebp)
  800c40:	ff 75 08             	pushl  0x8(%ebp)
  800c43:	e8 87 ff ff ff       	call   800bcf <memmove>
}
  800c48:	c9                   	leave  
  800c49:	c3                   	ret    

00800c4a <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c4a:	55                   	push   %ebp
  800c4b:	89 e5                	mov    %esp,%ebp
  800c4d:	57                   	push   %edi
  800c4e:	56                   	push   %esi
  800c4f:	53                   	push   %ebx
  800c50:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800c53:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c56:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c59:	85 c0                	test   %eax,%eax
  800c5b:	74 39                	je     800c96 <memcmp+0x4c>
  800c5d:	8d 78 ff             	lea    -0x1(%eax),%edi
		if (*s1 != *s2)
  800c60:	0f b6 13             	movzbl (%ebx),%edx
  800c63:	0f b6 0e             	movzbl (%esi),%ecx
  800c66:	38 ca                	cmp    %cl,%dl
  800c68:	75 17                	jne    800c81 <memcmp+0x37>
  800c6a:	b8 00 00 00 00       	mov    $0x0,%eax
  800c6f:	eb 1a                	jmp    800c8b <memcmp+0x41>
  800c71:	0f b6 54 03 01       	movzbl 0x1(%ebx,%eax,1),%edx
  800c76:	83 c0 01             	add    $0x1,%eax
  800c79:	0f b6 0c 06          	movzbl (%esi,%eax,1),%ecx
  800c7d:	38 ca                	cmp    %cl,%dl
  800c7f:	74 0a                	je     800c8b <memcmp+0x41>
			return (int) *s1 - (int) *s2;
  800c81:	0f b6 c2             	movzbl %dl,%eax
  800c84:	0f b6 c9             	movzbl %cl,%ecx
  800c87:	29 c8                	sub    %ecx,%eax
  800c89:	eb 10                	jmp    800c9b <memcmp+0x51>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c8b:	39 f8                	cmp    %edi,%eax
  800c8d:	75 e2                	jne    800c71 <memcmp+0x27>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c8f:	b8 00 00 00 00       	mov    $0x0,%eax
  800c94:	eb 05                	jmp    800c9b <memcmp+0x51>
  800c96:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c9b:	5b                   	pop    %ebx
  800c9c:	5e                   	pop    %esi
  800c9d:	5f                   	pop    %edi
  800c9e:	5d                   	pop    %ebp
  800c9f:	c3                   	ret    

00800ca0 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ca0:	55                   	push   %ebp
  800ca1:	89 e5                	mov    %esp,%ebp
  800ca3:	53                   	push   %ebx
  800ca4:	8b 55 08             	mov    0x8(%ebp),%edx
	const void *ends = (const char *) s + n;
  800ca7:	89 d0                	mov    %edx,%eax
  800ca9:	03 45 10             	add    0x10(%ebp),%eax
	for (; s < ends; s++)
  800cac:	39 c2                	cmp    %eax,%edx
  800cae:	73 1d                	jae    800ccd <memfind+0x2d>
		if (*(const unsigned char *) s == (unsigned char) c)
  800cb0:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
  800cb4:	0f b6 0a             	movzbl (%edx),%ecx
  800cb7:	39 d9                	cmp    %ebx,%ecx
  800cb9:	75 09                	jne    800cc4 <memfind+0x24>
  800cbb:	eb 14                	jmp    800cd1 <memfind+0x31>
  800cbd:	0f b6 0a             	movzbl (%edx),%ecx
  800cc0:	39 d9                	cmp    %ebx,%ecx
  800cc2:	74 11                	je     800cd5 <memfind+0x35>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800cc4:	83 c2 01             	add    $0x1,%edx
  800cc7:	39 d0                	cmp    %edx,%eax
  800cc9:	75 f2                	jne    800cbd <memfind+0x1d>
  800ccb:	eb 0a                	jmp    800cd7 <memfind+0x37>
  800ccd:	89 d0                	mov    %edx,%eax
  800ccf:	eb 06                	jmp    800cd7 <memfind+0x37>
		if (*(const unsigned char *) s == (unsigned char) c)
  800cd1:	89 d0                	mov    %edx,%eax
  800cd3:	eb 02                	jmp    800cd7 <memfind+0x37>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800cd5:	89 d0                	mov    %edx,%eax
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800cd7:	5b                   	pop    %ebx
  800cd8:	5d                   	pop    %ebp
  800cd9:	c3                   	ret    

00800cda <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800cda:	55                   	push   %ebp
  800cdb:	89 e5                	mov    %esp,%ebp
  800cdd:	57                   	push   %edi
  800cde:	56                   	push   %esi
  800cdf:	53                   	push   %ebx
  800ce0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ce3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ce6:	0f b6 01             	movzbl (%ecx),%eax
  800ce9:	3c 20                	cmp    $0x20,%al
  800ceb:	74 04                	je     800cf1 <strtol+0x17>
  800ced:	3c 09                	cmp    $0x9,%al
  800cef:	75 0e                	jne    800cff <strtol+0x25>
		s++;
  800cf1:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800cf4:	0f b6 01             	movzbl (%ecx),%eax
  800cf7:	3c 20                	cmp    $0x20,%al
  800cf9:	74 f6                	je     800cf1 <strtol+0x17>
  800cfb:	3c 09                	cmp    $0x9,%al
  800cfd:	74 f2                	je     800cf1 <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  800cff:	3c 2b                	cmp    $0x2b,%al
  800d01:	75 0a                	jne    800d0d <strtol+0x33>
		s++;
  800d03:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800d06:	bf 00 00 00 00       	mov    $0x0,%edi
  800d0b:	eb 11                	jmp    800d1e <strtol+0x44>
  800d0d:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800d12:	3c 2d                	cmp    $0x2d,%al
  800d14:	75 08                	jne    800d1e <strtol+0x44>
		s++, neg = 1;
  800d16:	83 c1 01             	add    $0x1,%ecx
  800d19:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d1e:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800d24:	75 15                	jne    800d3b <strtol+0x61>
  800d26:	80 39 30             	cmpb   $0x30,(%ecx)
  800d29:	75 10                	jne    800d3b <strtol+0x61>
  800d2b:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800d2f:	75 7c                	jne    800dad <strtol+0xd3>
		s += 2, base = 16;
  800d31:	83 c1 02             	add    $0x2,%ecx
  800d34:	bb 10 00 00 00       	mov    $0x10,%ebx
  800d39:	eb 16                	jmp    800d51 <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  800d3b:	85 db                	test   %ebx,%ebx
  800d3d:	75 12                	jne    800d51 <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800d3f:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800d44:	80 39 30             	cmpb   $0x30,(%ecx)
  800d47:	75 08                	jne    800d51 <strtol+0x77>
		s++, base = 8;
  800d49:	83 c1 01             	add    $0x1,%ecx
  800d4c:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800d51:	b8 00 00 00 00       	mov    $0x0,%eax
  800d56:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d59:	0f b6 11             	movzbl (%ecx),%edx
  800d5c:	8d 72 d0             	lea    -0x30(%edx),%esi
  800d5f:	89 f3                	mov    %esi,%ebx
  800d61:	80 fb 09             	cmp    $0x9,%bl
  800d64:	77 08                	ja     800d6e <strtol+0x94>
			dig = *s - '0';
  800d66:	0f be d2             	movsbl %dl,%edx
  800d69:	83 ea 30             	sub    $0x30,%edx
  800d6c:	eb 22                	jmp    800d90 <strtol+0xb6>
		else if (*s >= 'a' && *s <= 'z')
  800d6e:	8d 72 9f             	lea    -0x61(%edx),%esi
  800d71:	89 f3                	mov    %esi,%ebx
  800d73:	80 fb 19             	cmp    $0x19,%bl
  800d76:	77 08                	ja     800d80 <strtol+0xa6>
			dig = *s - 'a' + 10;
  800d78:	0f be d2             	movsbl %dl,%edx
  800d7b:	83 ea 57             	sub    $0x57,%edx
  800d7e:	eb 10                	jmp    800d90 <strtol+0xb6>
		else if (*s >= 'A' && *s <= 'Z')
  800d80:	8d 72 bf             	lea    -0x41(%edx),%esi
  800d83:	89 f3                	mov    %esi,%ebx
  800d85:	80 fb 19             	cmp    $0x19,%bl
  800d88:	77 16                	ja     800da0 <strtol+0xc6>
			dig = *s - 'A' + 10;
  800d8a:	0f be d2             	movsbl %dl,%edx
  800d8d:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800d90:	3b 55 10             	cmp    0x10(%ebp),%edx
  800d93:	7d 0b                	jge    800da0 <strtol+0xc6>
			break;
		s++, val = (val * base) + dig;
  800d95:	83 c1 01             	add    $0x1,%ecx
  800d98:	0f af 45 10          	imul   0x10(%ebp),%eax
  800d9c:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800d9e:	eb b9                	jmp    800d59 <strtol+0x7f>

	if (endptr)
  800da0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800da4:	74 0d                	je     800db3 <strtol+0xd9>
		*endptr = (char *) s;
  800da6:	8b 75 0c             	mov    0xc(%ebp),%esi
  800da9:	89 0e                	mov    %ecx,(%esi)
  800dab:	eb 06                	jmp    800db3 <strtol+0xd9>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800dad:	85 db                	test   %ebx,%ebx
  800daf:	74 98                	je     800d49 <strtol+0x6f>
  800db1:	eb 9e                	jmp    800d51 <strtol+0x77>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800db3:	89 c2                	mov    %eax,%edx
  800db5:	f7 da                	neg    %edx
  800db7:	85 ff                	test   %edi,%edi
  800db9:	0f 45 c2             	cmovne %edx,%eax
}
  800dbc:	5b                   	pop    %ebx
  800dbd:	5e                   	pop    %esi
  800dbe:	5f                   	pop    %edi
  800dbf:	5d                   	pop    %ebp
  800dc0:	c3                   	ret    

00800dc1 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800dc1:	55                   	push   %ebp
  800dc2:	89 e5                	mov    %esp,%ebp
  800dc4:	57                   	push   %edi
  800dc5:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800dc6:	b8 00 00 00 00       	mov    $0x0,%eax
  800dcb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dce:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd1:	89 c3                	mov    %eax,%ebx
  800dd3:	89 c7                	mov    %eax,%edi
  800dd5:	51                   	push   %ecx
  800dd6:	52                   	push   %edx
  800dd7:	53                   	push   %ebx
  800dd8:	54                   	push   %esp
  800dd9:	55                   	push   %ebp
  800dda:	56                   	push   %esi
  800ddb:	57                   	push   %edi
  800ddc:	5f                   	pop    %edi
  800ddd:	5e                   	pop    %esi
  800dde:	5d                   	pop    %ebp
  800ddf:	5c                   	pop    %esp
  800de0:	5b                   	pop    %ebx
  800de1:	5a                   	pop    %edx
  800de2:	59                   	pop    %ecx

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800de3:	5b                   	pop    %ebx
  800de4:	5f                   	pop    %edi
  800de5:	5d                   	pop    %ebp
  800de6:	c3                   	ret    

00800de7 <sys_cgetc>:

int
sys_cgetc(void)
{
  800de7:	55                   	push   %ebp
  800de8:	89 e5                	mov    %esp,%ebp
  800dea:	57                   	push   %edi
  800deb:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800dec:	b9 00 00 00 00       	mov    $0x0,%ecx
  800df1:	b8 01 00 00 00       	mov    $0x1,%eax
  800df6:	89 ca                	mov    %ecx,%edx
  800df8:	89 cb                	mov    %ecx,%ebx
  800dfa:	89 cf                	mov    %ecx,%edi
  800dfc:	51                   	push   %ecx
  800dfd:	52                   	push   %edx
  800dfe:	53                   	push   %ebx
  800dff:	54                   	push   %esp
  800e00:	55                   	push   %ebp
  800e01:	56                   	push   %esi
  800e02:	57                   	push   %edi
  800e03:	5f                   	pop    %edi
  800e04:	5e                   	pop    %esi
  800e05:	5d                   	pop    %ebp
  800e06:	5c                   	pop    %esp
  800e07:	5b                   	pop    %ebx
  800e08:	5a                   	pop    %edx
  800e09:	59                   	pop    %ecx

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800e0a:	5b                   	pop    %ebx
  800e0b:	5f                   	pop    %edi
  800e0c:	5d                   	pop    %ebp
  800e0d:	c3                   	ret    

00800e0e <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800e0e:	55                   	push   %ebp
  800e0f:	89 e5                	mov    %esp,%ebp
  800e11:	57                   	push   %edi
  800e12:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800e13:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e18:	b8 03 00 00 00       	mov    $0x3,%eax
  800e1d:	8b 55 08             	mov    0x8(%ebp),%edx
  800e20:	89 d9                	mov    %ebx,%ecx
  800e22:	89 df                	mov    %ebx,%edi
  800e24:	51                   	push   %ecx
  800e25:	52                   	push   %edx
  800e26:	53                   	push   %ebx
  800e27:	54                   	push   %esp
  800e28:	55                   	push   %ebp
  800e29:	56                   	push   %esi
  800e2a:	57                   	push   %edi
  800e2b:	5f                   	pop    %edi
  800e2c:	5e                   	pop    %esi
  800e2d:	5d                   	pop    %ebp
  800e2e:	5c                   	pop    %esp
  800e2f:	5b                   	pop    %ebx
  800e30:	5a                   	pop    %edx
  800e31:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  800e32:	85 c0                	test   %eax,%eax
  800e34:	7e 17                	jle    800e4d <sys_env_destroy+0x3f>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e36:	83 ec 0c             	sub    $0xc,%esp
  800e39:	50                   	push   %eax
  800e3a:	6a 03                	push   $0x3
  800e3c:	68 c4 14 80 00       	push   $0x8014c4
  800e41:	6a 26                	push   $0x26
  800e43:	68 e1 14 80 00       	push   $0x8014e1
  800e48:	e8 f7 f2 ff ff       	call   800144 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800e4d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e50:	5b                   	pop    %ebx
  800e51:	5f                   	pop    %edi
  800e52:	5d                   	pop    %ebp
  800e53:	c3                   	ret    

00800e54 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800e54:	55                   	push   %ebp
  800e55:	89 e5                	mov    %esp,%ebp
  800e57:	57                   	push   %edi
  800e58:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800e59:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e5e:	b8 02 00 00 00       	mov    $0x2,%eax
  800e63:	89 ca                	mov    %ecx,%edx
  800e65:	89 cb                	mov    %ecx,%ebx
  800e67:	89 cf                	mov    %ecx,%edi
  800e69:	51                   	push   %ecx
  800e6a:	52                   	push   %edx
  800e6b:	53                   	push   %ebx
  800e6c:	54                   	push   %esp
  800e6d:	55                   	push   %ebp
  800e6e:	56                   	push   %esi
  800e6f:	57                   	push   %edi
  800e70:	5f                   	pop    %edi
  800e71:	5e                   	pop    %esi
  800e72:	5d                   	pop    %ebp
  800e73:	5c                   	pop    %esp
  800e74:	5b                   	pop    %ebx
  800e75:	5a                   	pop    %edx
  800e76:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800e77:	5b                   	pop    %ebx
  800e78:	5f                   	pop    %edi
  800e79:	5d                   	pop    %ebp
  800e7a:	c3                   	ret    

00800e7b <sys_map_kernel_page>:

int
sys_map_kernel_page(void* kpage, void* va)
{
  800e7b:	55                   	push   %ebp
  800e7c:	89 e5                	mov    %esp,%ebp
  800e7e:	57                   	push   %edi
  800e7f:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800e80:	bf 00 00 00 00       	mov    $0x0,%edi
  800e85:	b8 04 00 00 00       	mov    $0x4,%eax
  800e8a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e8d:	8b 55 08             	mov    0x8(%ebp),%edx
  800e90:	89 fb                	mov    %edi,%ebx
  800e92:	51                   	push   %ecx
  800e93:	52                   	push   %edx
  800e94:	53                   	push   %ebx
  800e95:	54                   	push   %esp
  800e96:	55                   	push   %ebp
  800e97:	56                   	push   %esi
  800e98:	57                   	push   %edi
  800e99:	5f                   	pop    %edi
  800e9a:	5e                   	pop    %esi
  800e9b:	5d                   	pop    %ebp
  800e9c:	5c                   	pop    %esp
  800e9d:	5b                   	pop    %ebx
  800e9e:	5a                   	pop    %edx
  800e9f:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  800ea0:	5b                   	pop    %ebx
  800ea1:	5f                   	pop    %edi
  800ea2:	5d                   	pop    %ebp
  800ea3:	c3                   	ret    

00800ea4 <sys_sbrk>:

int
sys_sbrk(uint32_t inc)
{
  800ea4:	55                   	push   %ebp
  800ea5:	89 e5                	mov    %esp,%ebp
  800ea7:	57                   	push   %edi
  800ea8:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800ea9:	b9 00 00 00 00       	mov    $0x0,%ecx
  800eae:	b8 05 00 00 00       	mov    $0x5,%eax
  800eb3:	8b 55 08             	mov    0x8(%ebp),%edx
  800eb6:	89 cb                	mov    %ecx,%ebx
  800eb8:	89 cf                	mov    %ecx,%edi
  800eba:	51                   	push   %ecx
  800ebb:	52                   	push   %edx
  800ebc:	53                   	push   %ebx
  800ebd:	54                   	push   %esp
  800ebe:	55                   	push   %ebp
  800ebf:	56                   	push   %esi
  800ec0:	57                   	push   %edi
  800ec1:	5f                   	pop    %edi
  800ec2:	5e                   	pop    %esi
  800ec3:	5d                   	pop    %ebp
  800ec4:	5c                   	pop    %esp
  800ec5:	5b                   	pop    %ebx
  800ec6:	5a                   	pop    %edx
  800ec7:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  800ec8:	5b                   	pop    %ebx
  800ec9:	5f                   	pop    %edi
  800eca:	5d                   	pop    %ebp
  800ecb:	c3                   	ret    
  800ecc:	66 90                	xchg   %ax,%ax
  800ece:	66 90                	xchg   %ax,%ax

00800ed0 <__udivdi3>:
  800ed0:	55                   	push   %ebp
  800ed1:	57                   	push   %edi
  800ed2:	56                   	push   %esi
  800ed3:	53                   	push   %ebx
  800ed4:	83 ec 1c             	sub    $0x1c,%esp
  800ed7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  800edb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  800edf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  800ee3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800ee7:	85 f6                	test   %esi,%esi
  800ee9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800eed:	89 ca                	mov    %ecx,%edx
  800eef:	89 f8                	mov    %edi,%eax
  800ef1:	75 3d                	jne    800f30 <__udivdi3+0x60>
  800ef3:	39 cf                	cmp    %ecx,%edi
  800ef5:	0f 87 c5 00 00 00    	ja     800fc0 <__udivdi3+0xf0>
  800efb:	85 ff                	test   %edi,%edi
  800efd:	89 fd                	mov    %edi,%ebp
  800eff:	75 0b                	jne    800f0c <__udivdi3+0x3c>
  800f01:	b8 01 00 00 00       	mov    $0x1,%eax
  800f06:	31 d2                	xor    %edx,%edx
  800f08:	f7 f7                	div    %edi
  800f0a:	89 c5                	mov    %eax,%ebp
  800f0c:	89 c8                	mov    %ecx,%eax
  800f0e:	31 d2                	xor    %edx,%edx
  800f10:	f7 f5                	div    %ebp
  800f12:	89 c1                	mov    %eax,%ecx
  800f14:	89 d8                	mov    %ebx,%eax
  800f16:	89 cf                	mov    %ecx,%edi
  800f18:	f7 f5                	div    %ebp
  800f1a:	89 c3                	mov    %eax,%ebx
  800f1c:	89 d8                	mov    %ebx,%eax
  800f1e:	89 fa                	mov    %edi,%edx
  800f20:	83 c4 1c             	add    $0x1c,%esp
  800f23:	5b                   	pop    %ebx
  800f24:	5e                   	pop    %esi
  800f25:	5f                   	pop    %edi
  800f26:	5d                   	pop    %ebp
  800f27:	c3                   	ret    
  800f28:	90                   	nop
  800f29:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f30:	39 ce                	cmp    %ecx,%esi
  800f32:	77 74                	ja     800fa8 <__udivdi3+0xd8>
  800f34:	0f bd fe             	bsr    %esi,%edi
  800f37:	83 f7 1f             	xor    $0x1f,%edi
  800f3a:	0f 84 98 00 00 00    	je     800fd8 <__udivdi3+0x108>
  800f40:	bb 20 00 00 00       	mov    $0x20,%ebx
  800f45:	89 f9                	mov    %edi,%ecx
  800f47:	89 c5                	mov    %eax,%ebp
  800f49:	29 fb                	sub    %edi,%ebx
  800f4b:	d3 e6                	shl    %cl,%esi
  800f4d:	89 d9                	mov    %ebx,%ecx
  800f4f:	d3 ed                	shr    %cl,%ebp
  800f51:	89 f9                	mov    %edi,%ecx
  800f53:	d3 e0                	shl    %cl,%eax
  800f55:	09 ee                	or     %ebp,%esi
  800f57:	89 d9                	mov    %ebx,%ecx
  800f59:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f5d:	89 d5                	mov    %edx,%ebp
  800f5f:	8b 44 24 08          	mov    0x8(%esp),%eax
  800f63:	d3 ed                	shr    %cl,%ebp
  800f65:	89 f9                	mov    %edi,%ecx
  800f67:	d3 e2                	shl    %cl,%edx
  800f69:	89 d9                	mov    %ebx,%ecx
  800f6b:	d3 e8                	shr    %cl,%eax
  800f6d:	09 c2                	or     %eax,%edx
  800f6f:	89 d0                	mov    %edx,%eax
  800f71:	89 ea                	mov    %ebp,%edx
  800f73:	f7 f6                	div    %esi
  800f75:	89 d5                	mov    %edx,%ebp
  800f77:	89 c3                	mov    %eax,%ebx
  800f79:	f7 64 24 0c          	mull   0xc(%esp)
  800f7d:	39 d5                	cmp    %edx,%ebp
  800f7f:	72 10                	jb     800f91 <__udivdi3+0xc1>
  800f81:	8b 74 24 08          	mov    0x8(%esp),%esi
  800f85:	89 f9                	mov    %edi,%ecx
  800f87:	d3 e6                	shl    %cl,%esi
  800f89:	39 c6                	cmp    %eax,%esi
  800f8b:	73 07                	jae    800f94 <__udivdi3+0xc4>
  800f8d:	39 d5                	cmp    %edx,%ebp
  800f8f:	75 03                	jne    800f94 <__udivdi3+0xc4>
  800f91:	83 eb 01             	sub    $0x1,%ebx
  800f94:	31 ff                	xor    %edi,%edi
  800f96:	89 d8                	mov    %ebx,%eax
  800f98:	89 fa                	mov    %edi,%edx
  800f9a:	83 c4 1c             	add    $0x1c,%esp
  800f9d:	5b                   	pop    %ebx
  800f9e:	5e                   	pop    %esi
  800f9f:	5f                   	pop    %edi
  800fa0:	5d                   	pop    %ebp
  800fa1:	c3                   	ret    
  800fa2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800fa8:	31 ff                	xor    %edi,%edi
  800faa:	31 db                	xor    %ebx,%ebx
  800fac:	89 d8                	mov    %ebx,%eax
  800fae:	89 fa                	mov    %edi,%edx
  800fb0:	83 c4 1c             	add    $0x1c,%esp
  800fb3:	5b                   	pop    %ebx
  800fb4:	5e                   	pop    %esi
  800fb5:	5f                   	pop    %edi
  800fb6:	5d                   	pop    %ebp
  800fb7:	c3                   	ret    
  800fb8:	90                   	nop
  800fb9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800fc0:	89 d8                	mov    %ebx,%eax
  800fc2:	f7 f7                	div    %edi
  800fc4:	31 ff                	xor    %edi,%edi
  800fc6:	89 c3                	mov    %eax,%ebx
  800fc8:	89 d8                	mov    %ebx,%eax
  800fca:	89 fa                	mov    %edi,%edx
  800fcc:	83 c4 1c             	add    $0x1c,%esp
  800fcf:	5b                   	pop    %ebx
  800fd0:	5e                   	pop    %esi
  800fd1:	5f                   	pop    %edi
  800fd2:	5d                   	pop    %ebp
  800fd3:	c3                   	ret    
  800fd4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800fd8:	39 ce                	cmp    %ecx,%esi
  800fda:	72 0c                	jb     800fe8 <__udivdi3+0x118>
  800fdc:	31 db                	xor    %ebx,%ebx
  800fde:	3b 44 24 08          	cmp    0x8(%esp),%eax
  800fe2:	0f 87 34 ff ff ff    	ja     800f1c <__udivdi3+0x4c>
  800fe8:	bb 01 00 00 00       	mov    $0x1,%ebx
  800fed:	e9 2a ff ff ff       	jmp    800f1c <__udivdi3+0x4c>
  800ff2:	66 90                	xchg   %ax,%ax
  800ff4:	66 90                	xchg   %ax,%ax
  800ff6:	66 90                	xchg   %ax,%ax
  800ff8:	66 90                	xchg   %ax,%ax
  800ffa:	66 90                	xchg   %ax,%ax
  800ffc:	66 90                	xchg   %ax,%ax
  800ffe:	66 90                	xchg   %ax,%ax

00801000 <__umoddi3>:
  801000:	55                   	push   %ebp
  801001:	57                   	push   %edi
  801002:	56                   	push   %esi
  801003:	53                   	push   %ebx
  801004:	83 ec 1c             	sub    $0x1c,%esp
  801007:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80100b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80100f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801013:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801017:	85 d2                	test   %edx,%edx
  801019:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80101d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801021:	89 f3                	mov    %esi,%ebx
  801023:	89 3c 24             	mov    %edi,(%esp)
  801026:	89 74 24 04          	mov    %esi,0x4(%esp)
  80102a:	75 1c                	jne    801048 <__umoddi3+0x48>
  80102c:	39 f7                	cmp    %esi,%edi
  80102e:	76 50                	jbe    801080 <__umoddi3+0x80>
  801030:	89 c8                	mov    %ecx,%eax
  801032:	89 f2                	mov    %esi,%edx
  801034:	f7 f7                	div    %edi
  801036:	89 d0                	mov    %edx,%eax
  801038:	31 d2                	xor    %edx,%edx
  80103a:	83 c4 1c             	add    $0x1c,%esp
  80103d:	5b                   	pop    %ebx
  80103e:	5e                   	pop    %esi
  80103f:	5f                   	pop    %edi
  801040:	5d                   	pop    %ebp
  801041:	c3                   	ret    
  801042:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801048:	39 f2                	cmp    %esi,%edx
  80104a:	89 d0                	mov    %edx,%eax
  80104c:	77 52                	ja     8010a0 <__umoddi3+0xa0>
  80104e:	0f bd ea             	bsr    %edx,%ebp
  801051:	83 f5 1f             	xor    $0x1f,%ebp
  801054:	75 5a                	jne    8010b0 <__umoddi3+0xb0>
  801056:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80105a:	0f 82 e0 00 00 00    	jb     801140 <__umoddi3+0x140>
  801060:	39 0c 24             	cmp    %ecx,(%esp)
  801063:	0f 86 d7 00 00 00    	jbe    801140 <__umoddi3+0x140>
  801069:	8b 44 24 08          	mov    0x8(%esp),%eax
  80106d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801071:	83 c4 1c             	add    $0x1c,%esp
  801074:	5b                   	pop    %ebx
  801075:	5e                   	pop    %esi
  801076:	5f                   	pop    %edi
  801077:	5d                   	pop    %ebp
  801078:	c3                   	ret    
  801079:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801080:	85 ff                	test   %edi,%edi
  801082:	89 fd                	mov    %edi,%ebp
  801084:	75 0b                	jne    801091 <__umoddi3+0x91>
  801086:	b8 01 00 00 00       	mov    $0x1,%eax
  80108b:	31 d2                	xor    %edx,%edx
  80108d:	f7 f7                	div    %edi
  80108f:	89 c5                	mov    %eax,%ebp
  801091:	89 f0                	mov    %esi,%eax
  801093:	31 d2                	xor    %edx,%edx
  801095:	f7 f5                	div    %ebp
  801097:	89 c8                	mov    %ecx,%eax
  801099:	f7 f5                	div    %ebp
  80109b:	89 d0                	mov    %edx,%eax
  80109d:	eb 99                	jmp    801038 <__umoddi3+0x38>
  80109f:	90                   	nop
  8010a0:	89 c8                	mov    %ecx,%eax
  8010a2:	89 f2                	mov    %esi,%edx
  8010a4:	83 c4 1c             	add    $0x1c,%esp
  8010a7:	5b                   	pop    %ebx
  8010a8:	5e                   	pop    %esi
  8010a9:	5f                   	pop    %edi
  8010aa:	5d                   	pop    %ebp
  8010ab:	c3                   	ret    
  8010ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8010b0:	8b 34 24             	mov    (%esp),%esi
  8010b3:	bf 20 00 00 00       	mov    $0x20,%edi
  8010b8:	89 e9                	mov    %ebp,%ecx
  8010ba:	29 ef                	sub    %ebp,%edi
  8010bc:	d3 e0                	shl    %cl,%eax
  8010be:	89 f9                	mov    %edi,%ecx
  8010c0:	89 f2                	mov    %esi,%edx
  8010c2:	d3 ea                	shr    %cl,%edx
  8010c4:	89 e9                	mov    %ebp,%ecx
  8010c6:	09 c2                	or     %eax,%edx
  8010c8:	89 d8                	mov    %ebx,%eax
  8010ca:	89 14 24             	mov    %edx,(%esp)
  8010cd:	89 f2                	mov    %esi,%edx
  8010cf:	d3 e2                	shl    %cl,%edx
  8010d1:	89 f9                	mov    %edi,%ecx
  8010d3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8010d7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8010db:	d3 e8                	shr    %cl,%eax
  8010dd:	89 e9                	mov    %ebp,%ecx
  8010df:	89 c6                	mov    %eax,%esi
  8010e1:	d3 e3                	shl    %cl,%ebx
  8010e3:	89 f9                	mov    %edi,%ecx
  8010e5:	89 d0                	mov    %edx,%eax
  8010e7:	d3 e8                	shr    %cl,%eax
  8010e9:	89 e9                	mov    %ebp,%ecx
  8010eb:	09 d8                	or     %ebx,%eax
  8010ed:	89 d3                	mov    %edx,%ebx
  8010ef:	89 f2                	mov    %esi,%edx
  8010f1:	f7 34 24             	divl   (%esp)
  8010f4:	89 d6                	mov    %edx,%esi
  8010f6:	d3 e3                	shl    %cl,%ebx
  8010f8:	f7 64 24 04          	mull   0x4(%esp)
  8010fc:	39 d6                	cmp    %edx,%esi
  8010fe:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801102:	89 d1                	mov    %edx,%ecx
  801104:	89 c3                	mov    %eax,%ebx
  801106:	72 08                	jb     801110 <__umoddi3+0x110>
  801108:	75 11                	jne    80111b <__umoddi3+0x11b>
  80110a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80110e:	73 0b                	jae    80111b <__umoddi3+0x11b>
  801110:	2b 44 24 04          	sub    0x4(%esp),%eax
  801114:	1b 14 24             	sbb    (%esp),%edx
  801117:	89 d1                	mov    %edx,%ecx
  801119:	89 c3                	mov    %eax,%ebx
  80111b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80111f:	29 da                	sub    %ebx,%edx
  801121:	19 ce                	sbb    %ecx,%esi
  801123:	89 f9                	mov    %edi,%ecx
  801125:	89 f0                	mov    %esi,%eax
  801127:	d3 e0                	shl    %cl,%eax
  801129:	89 e9                	mov    %ebp,%ecx
  80112b:	d3 ea                	shr    %cl,%edx
  80112d:	89 e9                	mov    %ebp,%ecx
  80112f:	d3 ee                	shr    %cl,%esi
  801131:	09 d0                	or     %edx,%eax
  801133:	89 f2                	mov    %esi,%edx
  801135:	83 c4 1c             	add    $0x1c,%esp
  801138:	5b                   	pop    %ebx
  801139:	5e                   	pop    %esi
  80113a:	5f                   	pop    %edi
  80113b:	5d                   	pop    %ebp
  80113c:	c3                   	ret    
  80113d:	8d 76 00             	lea    0x0(%esi),%esi
  801140:	29 f9                	sub    %edi,%ecx
  801142:	19 d6                	sbb    %edx,%esi
  801144:	89 74 24 04          	mov    %esi,0x4(%esp)
  801148:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80114c:	e9 18 ff ff ff       	jmp    801069 <__umoddi3+0x69>
