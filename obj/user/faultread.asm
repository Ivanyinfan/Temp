
obj/user/faultread:     file format elf32-i386


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

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	cprintf("I read %08x from location 0!\n", *(unsigned*)0);
  800039:	ff 35 00 00 00 00    	pushl  0x0
  80003f:	68 a4 10 80 00       	push   $0x8010a4
  800044:	e8 e0 00 00 00       	call   800129 <cprintf>
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
  80005a:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800061:	00 00 00 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800064:	85 c0                	test   %eax,%eax
  800066:	7e 08                	jle    800070 <libmain+0x22>
		binaryname = argv[0];
  800068:	8b 0a                	mov    (%edx),%ecx
  80006a:	89 0d 00 20 80 00    	mov    %ecx,0x802000

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
  80008c:	e8 6f 0c 00 00       	call   800d00 <sys_env_destroy>
}
  800091:	83 c4 10             	add    $0x10,%esp
  800094:	c9                   	leave  
  800095:	c3                   	ret    

00800096 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800096:	55                   	push   %ebp
  800097:	89 e5                	mov    %esp,%ebp
  800099:	53                   	push   %ebx
  80009a:	83 ec 04             	sub    $0x4,%esp
  80009d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000a0:	8b 13                	mov    (%ebx),%edx
  8000a2:	8d 42 01             	lea    0x1(%edx),%eax
  8000a5:	89 03                	mov    %eax,(%ebx)
  8000a7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000aa:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000ae:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000b3:	75 1a                	jne    8000cf <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8000b5:	83 ec 08             	sub    $0x8,%esp
  8000b8:	68 ff 00 00 00       	push   $0xff
  8000bd:	8d 43 08             	lea    0x8(%ebx),%eax
  8000c0:	50                   	push   %eax
  8000c1:	e8 ed 0b 00 00       	call   800cb3 <sys_cputs>
		b->idx = 0;
  8000c6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8000cc:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8000cf:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000d3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000d6:	c9                   	leave  
  8000d7:	c3                   	ret    

008000d8 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8000d8:	55                   	push   %ebp
  8000d9:	89 e5                	mov    %esp,%ebp
  8000db:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8000e1:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8000e8:	00 00 00 
	b.cnt = 0;
  8000eb:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8000f2:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8000f5:	ff 75 0c             	pushl  0xc(%ebp)
  8000f8:	ff 75 08             	pushl  0x8(%ebp)
  8000fb:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800101:	50                   	push   %eax
  800102:	68 96 00 80 00       	push   $0x800096
  800107:	e8 45 02 00 00       	call   800351 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80010c:	83 c4 08             	add    $0x8,%esp
  80010f:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800115:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80011b:	50                   	push   %eax
  80011c:	e8 92 0b 00 00       	call   800cb3 <sys_cputs>

	return b.cnt;
}
  800121:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800127:	c9                   	leave  
  800128:	c3                   	ret    

00800129 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800129:	55                   	push   %ebp
  80012a:	89 e5                	mov    %esp,%ebp
  80012c:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80012f:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800132:	50                   	push   %eax
  800133:	ff 75 08             	pushl  0x8(%ebp)
  800136:	e8 9d ff ff ff       	call   8000d8 <vcprintf>
	va_end(ap);

	return cnt;
}
  80013b:	c9                   	leave  
  80013c:	c3                   	ret    

0080013d <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80013d:	55                   	push   %ebp
  80013e:	89 e5                	mov    %esp,%ebp
  800140:	57                   	push   %edi
  800141:	56                   	push   %esi
  800142:	53                   	push   %ebx
  800143:	83 ec 1c             	sub    $0x1c,%esp
  800146:	89 c7                	mov    %eax,%edi
  800148:	89 d6                	mov    %edx,%esi
  80014a:	8b 45 08             	mov    0x8(%ebp),%eax
  80014d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800150:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800153:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	// if cprintf'parameter includes pattern of the form "%-", padding
	// space on the right side if neccesary.
	// you can add helper function if needed.
	// your code here:
	int length,showsign=0;
	if(padc=='-'&&num>=base)
  800156:	83 7d 18 2d          	cmpl   $0x2d,0x18(%ebp)
  80015a:	0f 85 8a 00 00 00    	jne    8001ea <printnum+0xad>
  800160:	8b 45 10             	mov    0x10(%ebp),%eax
  800163:	ba 00 00 00 00       	mov    $0x0,%edx
  800168:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80016b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80016e:	39 da                	cmp    %ebx,%edx
  800170:	72 09                	jb     80017b <printnum+0x3e>
  800172:	39 4d 10             	cmp    %ecx,0x10(%ebp)
  800175:	0f 87 87 00 00 00    	ja     800202 <printnum+0xc5>
	{
		length=*(int *)putdat;
  80017b:	8b 1e                	mov    (%esi),%ebx
		printnum(putch,putdat,num/base,base,0,padc);
  80017d:	83 ec 0c             	sub    $0xc,%esp
  800180:	6a 2d                	push   $0x2d
  800182:	6a 00                	push   $0x0
  800184:	ff 75 10             	pushl  0x10(%ebp)
  800187:	83 ec 08             	sub    $0x8,%esp
  80018a:	52                   	push   %edx
  80018b:	50                   	push   %eax
  80018c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80018f:	ff 75 e0             	pushl  -0x20(%ebp)
  800192:	e8 89 0c 00 00       	call   800e20 <__udivdi3>
  800197:	83 c4 18             	add    $0x18,%esp
  80019a:	52                   	push   %edx
  80019b:	50                   	push   %eax
  80019c:	89 f2                	mov    %esi,%edx
  80019e:	89 f8                	mov    %edi,%eax
  8001a0:	e8 98 ff ff ff       	call   80013d <printnum>
		while (--width > 0)
			putch(padc, putdat);
	}
	}
	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001a5:	83 c4 18             	add    $0x18,%esp
  8001a8:	56                   	push   %esi
  8001a9:	8b 45 10             	mov    0x10(%ebp),%eax
  8001ac:	ba 00 00 00 00       	mov    $0x0,%edx
  8001b1:	83 ec 04             	sub    $0x4,%esp
  8001b4:	52                   	push   %edx
  8001b5:	50                   	push   %eax
  8001b6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001b9:	ff 75 e0             	pushl  -0x20(%ebp)
  8001bc:	e8 8f 0d 00 00       	call   800f50 <__umoddi3>
  8001c1:	83 c4 14             	add    $0x14,%esp
  8001c4:	0f be 80 cc 10 80 00 	movsbl 0x8010cc(%eax),%eax
  8001cb:	50                   	push   %eax
  8001cc:	ff d7                	call   *%edi
	
	if(padc=='-'&&width>0)
  8001ce:	83 c4 10             	add    $0x10,%esp
  8001d1:	83 7d 18 2d          	cmpl   $0x2d,0x18(%ebp)
  8001d5:	0f 85 fa 00 00 00    	jne    8002d5 <printnum+0x198>
  8001db:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
  8001df:	0f 8f 9b 00 00 00    	jg     800280 <printnum+0x143>
  8001e5:	e9 eb 00 00 00       	jmp    8002d5 <printnum+0x198>
	}
	else
	{
	
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001ea:	8b 45 10             	mov    0x10(%ebp),%eax
  8001ed:	ba 00 00 00 00       	mov    $0x0,%edx
  8001f2:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8001f5:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8001f8:	83 fb 00             	cmp    $0x0,%ebx
  8001fb:	77 14                	ja     800211 <printnum+0xd4>
  8001fd:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800200:	73 0f                	jae    800211 <printnum+0xd4>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800202:	8b 45 14             	mov    0x14(%ebp),%eax
  800205:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800208:	85 db                	test   %ebx,%ebx
  80020a:	7f 61                	jg     80026d <printnum+0x130>
  80020c:	e9 98 00 00 00       	jmp    8002a9 <printnum+0x16c>
	else
	{
	
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800211:	83 ec 0c             	sub    $0xc,%esp
  800214:	ff 75 18             	pushl  0x18(%ebp)
  800217:	8b 4d 14             	mov    0x14(%ebp),%ecx
  80021a:	8d 59 ff             	lea    -0x1(%ecx),%ebx
  80021d:	53                   	push   %ebx
  80021e:	ff 75 10             	pushl  0x10(%ebp)
  800221:	83 ec 08             	sub    $0x8,%esp
  800224:	52                   	push   %edx
  800225:	50                   	push   %eax
  800226:	ff 75 e4             	pushl  -0x1c(%ebp)
  800229:	ff 75 e0             	pushl  -0x20(%ebp)
  80022c:	e8 ef 0b 00 00       	call   800e20 <__udivdi3>
  800231:	83 c4 18             	add    $0x18,%esp
  800234:	52                   	push   %edx
  800235:	50                   	push   %eax
  800236:	89 f2                	mov    %esi,%edx
  800238:	89 f8                	mov    %edi,%eax
  80023a:	e8 fe fe ff ff       	call   80013d <printnum>
		while (--width > 0)
			putch(padc, putdat);
	}
	}
	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80023f:	83 c4 18             	add    $0x18,%esp
  800242:	56                   	push   %esi
  800243:	8b 45 10             	mov    0x10(%ebp),%eax
  800246:	ba 00 00 00 00       	mov    $0x0,%edx
  80024b:	83 ec 04             	sub    $0x4,%esp
  80024e:	52                   	push   %edx
  80024f:	50                   	push   %eax
  800250:	ff 75 e4             	pushl  -0x1c(%ebp)
  800253:	ff 75 e0             	pushl  -0x20(%ebp)
  800256:	e8 f5 0c 00 00       	call   800f50 <__umoddi3>
  80025b:	83 c4 14             	add    $0x14,%esp
  80025e:	0f be 80 cc 10 80 00 	movsbl 0x8010cc(%eax),%eax
  800265:	50                   	push   %eax
  800266:	ff d7                	call   *%edi
  800268:	83 c4 10             	add    $0x10,%esp
  80026b:	eb 68                	jmp    8002d5 <printnum+0x198>
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80026d:	83 ec 08             	sub    $0x8,%esp
  800270:	56                   	push   %esi
  800271:	ff 75 18             	pushl  0x18(%ebp)
  800274:	ff d7                	call   *%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800276:	83 c4 10             	add    $0x10,%esp
  800279:	83 eb 01             	sub    $0x1,%ebx
  80027c:	75 ef                	jne    80026d <printnum+0x130>
  80027e:	eb 29                	jmp    8002a9 <printnum+0x16c>
	putch("0123456789abcdef"[num % base], putdat);
	
	if(padc=='-'&&width>0)
	{
		length=*(int *)putdat-length;
		for(int i=0;i<width-length;++i)
  800280:	8b 45 14             	mov    0x14(%ebp),%eax
  800283:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800286:	2b 06                	sub    (%esi),%eax
  800288:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80028b:	85 c0                	test   %eax,%eax
  80028d:	7e 46                	jle    8002d5 <printnum+0x198>
  80028f:	bb 00 00 00 00       	mov    $0x0,%ebx
			putch(' ',putdat);
  800294:	83 ec 08             	sub    $0x8,%esp
  800297:	56                   	push   %esi
  800298:	6a 20                	push   $0x20
  80029a:	ff d7                	call   *%edi
	putch("0123456789abcdef"[num % base], putdat);
	
	if(padc=='-'&&width>0)
	{
		length=*(int *)putdat-length;
		for(int i=0;i<width-length;++i)
  80029c:	83 c3 01             	add    $0x1,%ebx
  80029f:	83 c4 10             	add    $0x10,%esp
  8002a2:	3b 5d e0             	cmp    -0x20(%ebp),%ebx
  8002a5:	75 ed                	jne    800294 <printnum+0x157>
  8002a7:	eb 2c                	jmp    8002d5 <printnum+0x198>
		while (--width > 0)
			putch(padc, putdat);
	}
	}
	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002a9:	83 ec 08             	sub    $0x8,%esp
  8002ac:	56                   	push   %esi
  8002ad:	8b 45 10             	mov    0x10(%ebp),%eax
  8002b0:	ba 00 00 00 00       	mov    $0x0,%edx
  8002b5:	83 ec 04             	sub    $0x4,%esp
  8002b8:	52                   	push   %edx
  8002b9:	50                   	push   %eax
  8002ba:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002bd:	ff 75 e0             	pushl  -0x20(%ebp)
  8002c0:	e8 8b 0c 00 00       	call   800f50 <__umoddi3>
  8002c5:	83 c4 14             	add    $0x14,%esp
  8002c8:	0f be 80 cc 10 80 00 	movsbl 0x8010cc(%eax),%eax
  8002cf:	50                   	push   %eax
  8002d0:	ff d7                	call   *%edi
  8002d2:	83 c4 10             	add    $0x10,%esp
	{
		length=*(int *)putdat-length;
		for(int i=0;i<width-length;++i)
			putch(' ',putdat);
	}
}
  8002d5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002d8:	5b                   	pop    %ebx
  8002d9:	5e                   	pop    %esi
  8002da:	5f                   	pop    %edi
  8002db:	5d                   	pop    %ebp
  8002dc:	c3                   	ret    

008002dd <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002dd:	55                   	push   %ebp
  8002de:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002e0:	83 fa 01             	cmp    $0x1,%edx
  8002e3:	7e 0e                	jle    8002f3 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002e5:	8b 10                	mov    (%eax),%edx
  8002e7:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002ea:	89 08                	mov    %ecx,(%eax)
  8002ec:	8b 02                	mov    (%edx),%eax
  8002ee:	8b 52 04             	mov    0x4(%edx),%edx
  8002f1:	eb 22                	jmp    800315 <getuint+0x38>
	else if (lflag)
  8002f3:	85 d2                	test   %edx,%edx
  8002f5:	74 10                	je     800307 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002f7:	8b 10                	mov    (%eax),%edx
  8002f9:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002fc:	89 08                	mov    %ecx,(%eax)
  8002fe:	8b 02                	mov    (%edx),%eax
  800300:	ba 00 00 00 00       	mov    $0x0,%edx
  800305:	eb 0e                	jmp    800315 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800307:	8b 10                	mov    (%eax),%edx
  800309:	8d 4a 04             	lea    0x4(%edx),%ecx
  80030c:	89 08                	mov    %ecx,(%eax)
  80030e:	8b 02                	mov    (%edx),%eax
  800310:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800315:	5d                   	pop    %ebp
  800316:	c3                   	ret    

00800317 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800317:	55                   	push   %ebp
  800318:	89 e5                	mov    %esp,%ebp
  80031a:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80031d:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800321:	8b 10                	mov    (%eax),%edx
  800323:	3b 50 04             	cmp    0x4(%eax),%edx
  800326:	73 0a                	jae    800332 <sprintputch+0x1b>
		*b->buf++ = ch;
  800328:	8d 4a 01             	lea    0x1(%edx),%ecx
  80032b:	89 08                	mov    %ecx,(%eax)
  80032d:	8b 45 08             	mov    0x8(%ebp),%eax
  800330:	88 02                	mov    %al,(%edx)
}
  800332:	5d                   	pop    %ebp
  800333:	c3                   	ret    

00800334 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800334:	55                   	push   %ebp
  800335:	89 e5                	mov    %esp,%ebp
  800337:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80033a:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80033d:	50                   	push   %eax
  80033e:	ff 75 10             	pushl  0x10(%ebp)
  800341:	ff 75 0c             	pushl  0xc(%ebp)
  800344:	ff 75 08             	pushl  0x8(%ebp)
  800347:	e8 05 00 00 00       	call   800351 <vprintfmt>
	va_end(ap);
}
  80034c:	83 c4 10             	add    $0x10,%esp
  80034f:	c9                   	leave  
  800350:	c3                   	ret    

00800351 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800351:	55                   	push   %ebp
  800352:	89 e5                	mov    %esp,%ebp
  800354:	57                   	push   %edi
  800355:	56                   	push   %esi
  800356:	53                   	push   %ebx
  800357:	83 ec 2c             	sub    $0x2c,%esp
  80035a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80035d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800360:	eb 03                	jmp    800365 <vprintfmt+0x14>
			break;
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
			for (fmt--; fmt[-1] != '%'; fmt--)
  800362:	89 75 10             	mov    %esi,0x10(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800365:	8b 45 10             	mov    0x10(%ebp),%eax
  800368:	8d 70 01             	lea    0x1(%eax),%esi
  80036b:	0f b6 00             	movzbl (%eax),%eax
  80036e:	83 f8 25             	cmp    $0x25,%eax
  800371:	74 27                	je     80039a <vprintfmt+0x49>
			if (ch == '\0')
  800373:	85 c0                	test   %eax,%eax
  800375:	75 0d                	jne    800384 <vprintfmt+0x33>
  800377:	e9 8b 04 00 00       	jmp    800807 <vprintfmt+0x4b6>
  80037c:	85 c0                	test   %eax,%eax
  80037e:	0f 84 83 04 00 00    	je     800807 <vprintfmt+0x4b6>
				return;
			putch(ch, putdat);
  800384:	83 ec 08             	sub    $0x8,%esp
  800387:	53                   	push   %ebx
  800388:	50                   	push   %eax
  800389:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80038b:	83 c6 01             	add    $0x1,%esi
  80038e:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  800392:	83 c4 10             	add    $0x10,%esp
  800395:	83 f8 25             	cmp    $0x25,%eax
  800398:	75 e2                	jne    80037c <vprintfmt+0x2b>
			padc = '-';
			goto reswitch;
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80039a:	c6 45 e3 20          	movb   $0x20,-0x1d(%ebp)
  80039e:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8003a5:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003ac:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8003b3:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  8003ba:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003bf:	eb 07                	jmp    8003c8 <vprintfmt+0x77>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c1:	8b 75 10             	mov    0x10(%ebp),%esi

		// flag to show the sign
		case '+':
			padc='+';
  8003c4:	c6 45 e3 2b          	movb   $0x2b,-0x1d(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c8:	8d 46 01             	lea    0x1(%esi),%eax
  8003cb:	89 45 10             	mov    %eax,0x10(%ebp)
  8003ce:	0f b6 06             	movzbl (%esi),%eax
  8003d1:	0f b6 d0             	movzbl %al,%edx
  8003d4:	83 e8 23             	sub    $0x23,%eax
  8003d7:	3c 55                	cmp    $0x55,%al
  8003d9:	0f 87 e9 03 00 00    	ja     8007c8 <vprintfmt+0x477>
  8003df:	0f b6 c0             	movzbl %al,%eax
  8003e2:	ff 24 85 d8 11 80 00 	jmp    *0x8011d8(,%eax,4)
  8003e9:	8b 75 10             	mov    0x10(%ebp),%esi
			padc='+';
			goto reswitch;
		
		// flag to pad on the right
		case '-':
			padc = '-';
  8003ec:	c6 45 e3 2d          	movb   $0x2d,-0x1d(%ebp)
  8003f0:	eb d6                	jmp    8003c8 <vprintfmt+0x77>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003f2:	8d 42 d0             	lea    -0x30(%edx),%eax
  8003f5:	89 45 d0             	mov    %eax,-0x30(%ebp)
				ch = *fmt;
  8003f8:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  8003fc:	8d 50 d0             	lea    -0x30(%eax),%edx
  8003ff:	83 fa 09             	cmp    $0x9,%edx
  800402:	77 66                	ja     80046a <vprintfmt+0x119>
  800404:	8b 75 10             	mov    0x10(%ebp),%esi
  800407:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80040a:	89 7d 08             	mov    %edi,0x8(%ebp)
  80040d:	eb 09                	jmp    800418 <vprintfmt+0xc7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80040f:	8b 75 10             	mov    0x10(%ebp),%esi
			padc = '-';
			goto reswitch;
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800412:	c6 45 e3 30          	movb   $0x30,-0x1d(%ebp)
			goto reswitch;
  800416:	eb b0                	jmp    8003c8 <vprintfmt+0x77>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800418:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  80041b:	8d 14 92             	lea    (%edx,%edx,4),%edx
  80041e:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  800422:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800425:	8d 78 d0             	lea    -0x30(%eax),%edi
  800428:	83 ff 09             	cmp    $0x9,%edi
  80042b:	76 eb                	jbe    800418 <vprintfmt+0xc7>
  80042d:	89 55 d0             	mov    %edx,-0x30(%ebp)
  800430:	8b 7d 08             	mov    0x8(%ebp),%edi
  800433:	eb 38                	jmp    80046d <vprintfmt+0x11c>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800435:	8b 45 14             	mov    0x14(%ebp),%eax
  800438:	8d 50 04             	lea    0x4(%eax),%edx
  80043b:	89 55 14             	mov    %edx,0x14(%ebp)
  80043e:	8b 00                	mov    (%eax),%eax
  800440:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800443:	8b 75 10             	mov    0x10(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800446:	eb 25                	jmp    80046d <vprintfmt+0x11c>
  800448:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80044b:	85 c0                	test   %eax,%eax
  80044d:	0f 48 c1             	cmovs  %ecx,%eax
  800450:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800453:	8b 75 10             	mov    0x10(%ebp),%esi
  800456:	e9 6d ff ff ff       	jmp    8003c8 <vprintfmt+0x77>
  80045b:	8b 75 10             	mov    0x10(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80045e:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800465:	e9 5e ff ff ff       	jmp    8003c8 <vprintfmt+0x77>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046a:	8b 75 10             	mov    0x10(%ebp),%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80046d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800471:	0f 89 51 ff ff ff    	jns    8003c8 <vprintfmt+0x77>
				width = precision, precision = -1;
  800477:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80047a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80047d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800484:	e9 3f ff ff ff       	jmp    8003c8 <vprintfmt+0x77>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800489:	83 45 cc 01          	addl   $0x1,-0x34(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80048d:	8b 75 10             	mov    0x10(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800490:	e9 33 ff ff ff       	jmp    8003c8 <vprintfmt+0x77>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800495:	8b 45 14             	mov    0x14(%ebp),%eax
  800498:	8d 50 04             	lea    0x4(%eax),%edx
  80049b:	89 55 14             	mov    %edx,0x14(%ebp)
  80049e:	83 ec 08             	sub    $0x8,%esp
  8004a1:	53                   	push   %ebx
  8004a2:	ff 30                	pushl  (%eax)
  8004a4:	ff d7                	call   *%edi
			break;
  8004a6:	83 c4 10             	add    $0x10,%esp
  8004a9:	e9 b7 fe ff ff       	jmp    800365 <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b1:	8d 50 04             	lea    0x4(%eax),%edx
  8004b4:	89 55 14             	mov    %edx,0x14(%ebp)
  8004b7:	8b 00                	mov    (%eax),%eax
  8004b9:	99                   	cltd   
  8004ba:	31 d0                	xor    %edx,%eax
  8004bc:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004be:	83 f8 06             	cmp    $0x6,%eax
  8004c1:	7f 0b                	jg     8004ce <vprintfmt+0x17d>
  8004c3:	8b 14 85 30 13 80 00 	mov    0x801330(,%eax,4),%edx
  8004ca:	85 d2                	test   %edx,%edx
  8004cc:	75 15                	jne    8004e3 <vprintfmt+0x192>
				printfmt(putch, putdat, "error %d", err);
  8004ce:	50                   	push   %eax
  8004cf:	68 e4 10 80 00       	push   $0x8010e4
  8004d4:	53                   	push   %ebx
  8004d5:	57                   	push   %edi
  8004d6:	e8 59 fe ff ff       	call   800334 <printfmt>
  8004db:	83 c4 10             	add    $0x10,%esp
  8004de:	e9 82 fe ff ff       	jmp    800365 <vprintfmt+0x14>
			else
				printfmt(putch, putdat, "%s", p);
  8004e3:	52                   	push   %edx
  8004e4:	68 ed 10 80 00       	push   $0x8010ed
  8004e9:	53                   	push   %ebx
  8004ea:	57                   	push   %edi
  8004eb:	e8 44 fe ff ff       	call   800334 <printfmt>
  8004f0:	83 c4 10             	add    $0x10,%esp
  8004f3:	e9 6d fe ff ff       	jmp    800365 <vprintfmt+0x14>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8004fb:	8d 50 04             	lea    0x4(%eax),%edx
  8004fe:	89 55 14             	mov    %edx,0x14(%ebp)
  800501:	8b 00                	mov    (%eax),%eax
				p = "(null)";
  800503:	85 c0                	test   %eax,%eax
  800505:	b9 dd 10 80 00       	mov    $0x8010dd,%ecx
  80050a:	0f 45 c8             	cmovne %eax,%ecx
  80050d:	89 4d cc             	mov    %ecx,-0x34(%ebp)
			if (width > 0 && padc != '-')
  800510:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800514:	7e 06                	jle    80051c <vprintfmt+0x1cb>
  800516:	80 7d e3 2d          	cmpb   $0x2d,-0x1d(%ebp)
  80051a:	75 19                	jne    800535 <vprintfmt+0x1e4>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80051c:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80051f:	8d 70 01             	lea    0x1(%eax),%esi
  800522:	0f b6 00             	movzbl (%eax),%eax
  800525:	0f be d0             	movsbl %al,%edx
  800528:	85 d2                	test   %edx,%edx
  80052a:	0f 85 9f 00 00 00    	jne    8005cf <vprintfmt+0x27e>
  800530:	e9 8c 00 00 00       	jmp    8005c1 <vprintfmt+0x270>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800535:	83 ec 08             	sub    $0x8,%esp
  800538:	ff 75 d0             	pushl  -0x30(%ebp)
  80053b:	ff 75 cc             	pushl  -0x34(%ebp)
  80053e:	e8 56 03 00 00       	call   800899 <strnlen>
  800543:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  800546:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800549:	83 c4 10             	add    $0x10,%esp
  80054c:	85 c9                	test   %ecx,%ecx
  80054e:	0f 8e 9a 02 00 00    	jle    8007ee <vprintfmt+0x49d>
					putch(padc, putdat);
  800554:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  800558:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80055b:	89 cb                	mov    %ecx,%ebx
  80055d:	83 ec 08             	sub    $0x8,%esp
  800560:	ff 75 0c             	pushl  0xc(%ebp)
  800563:	56                   	push   %esi
  800564:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800566:	83 c4 10             	add    $0x10,%esp
  800569:	83 eb 01             	sub    $0x1,%ebx
  80056c:	75 ef                	jne    80055d <vprintfmt+0x20c>
  80056e:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800571:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800574:	e9 75 02 00 00       	jmp    8007ee <vprintfmt+0x49d>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800579:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80057d:	74 1b                	je     80059a <vprintfmt+0x249>
  80057f:	0f be c0             	movsbl %al,%eax
  800582:	83 e8 20             	sub    $0x20,%eax
  800585:	83 f8 5e             	cmp    $0x5e,%eax
  800588:	76 10                	jbe    80059a <vprintfmt+0x249>
					putch('?', putdat);
  80058a:	83 ec 08             	sub    $0x8,%esp
  80058d:	ff 75 0c             	pushl  0xc(%ebp)
  800590:	6a 3f                	push   $0x3f
  800592:	ff 55 08             	call   *0x8(%ebp)
  800595:	83 c4 10             	add    $0x10,%esp
  800598:	eb 0d                	jmp    8005a7 <vprintfmt+0x256>
				else
					putch(ch, putdat);
  80059a:	83 ec 08             	sub    $0x8,%esp
  80059d:	ff 75 0c             	pushl  0xc(%ebp)
  8005a0:	52                   	push   %edx
  8005a1:	ff 55 08             	call   *0x8(%ebp)
  8005a4:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005a7:	83 ef 01             	sub    $0x1,%edi
  8005aa:	83 c6 01             	add    $0x1,%esi
  8005ad:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  8005b1:	0f be d0             	movsbl %al,%edx
  8005b4:	85 d2                	test   %edx,%edx
  8005b6:	75 31                	jne    8005e9 <vprintfmt+0x298>
  8005b8:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8005bb:	8b 7d 08             	mov    0x8(%ebp),%edi
  8005be:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005c1:	8b 75 e4             	mov    -0x1c(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005c4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005c8:	7f 33                	jg     8005fd <vprintfmt+0x2ac>
  8005ca:	e9 96 fd ff ff       	jmp    800365 <vprintfmt+0x14>
  8005cf:	89 7d 08             	mov    %edi,0x8(%ebp)
  8005d2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005d5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005d8:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8005db:	eb 0c                	jmp    8005e9 <vprintfmt+0x298>
  8005dd:	89 7d 08             	mov    %edi,0x8(%ebp)
  8005e0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005e3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005e6:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005e9:	85 db                	test   %ebx,%ebx
  8005eb:	78 8c                	js     800579 <vprintfmt+0x228>
  8005ed:	83 eb 01             	sub    $0x1,%ebx
  8005f0:	79 87                	jns    800579 <vprintfmt+0x228>
  8005f2:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8005f5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8005f8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005fb:	eb c4                	jmp    8005c1 <vprintfmt+0x270>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005fd:	83 ec 08             	sub    $0x8,%esp
  800600:	53                   	push   %ebx
  800601:	6a 20                	push   $0x20
  800603:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800605:	83 c4 10             	add    $0x10,%esp
  800608:	83 ee 01             	sub    $0x1,%esi
  80060b:	75 f0                	jne    8005fd <vprintfmt+0x2ac>
  80060d:	e9 53 fd ff ff       	jmp    800365 <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800612:	83 7d cc 01          	cmpl   $0x1,-0x34(%ebp)
  800616:	7e 16                	jle    80062e <vprintfmt+0x2dd>
		return va_arg(*ap, long long);
  800618:	8b 45 14             	mov    0x14(%ebp),%eax
  80061b:	8d 50 08             	lea    0x8(%eax),%edx
  80061e:	89 55 14             	mov    %edx,0x14(%ebp)
  800621:	8b 50 04             	mov    0x4(%eax),%edx
  800624:	8b 00                	mov    (%eax),%eax
  800626:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800629:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80062c:	eb 34                	jmp    800662 <vprintfmt+0x311>
	else if (lflag)
  80062e:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800632:	74 18                	je     80064c <vprintfmt+0x2fb>
		return va_arg(*ap, long);
  800634:	8b 45 14             	mov    0x14(%ebp),%eax
  800637:	8d 50 04             	lea    0x4(%eax),%edx
  80063a:	89 55 14             	mov    %edx,0x14(%ebp)
  80063d:	8b 30                	mov    (%eax),%esi
  80063f:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800642:	89 f0                	mov    %esi,%eax
  800644:	c1 f8 1f             	sar    $0x1f,%eax
  800647:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80064a:	eb 16                	jmp    800662 <vprintfmt+0x311>
	else
		return va_arg(*ap, int);
  80064c:	8b 45 14             	mov    0x14(%ebp),%eax
  80064f:	8d 50 04             	lea    0x4(%eax),%edx
  800652:	89 55 14             	mov    %edx,0x14(%ebp)
  800655:	8b 30                	mov    (%eax),%esi
  800657:	89 75 d0             	mov    %esi,-0x30(%ebp)
  80065a:	89 f0                	mov    %esi,%eax
  80065c:	c1 f8 1f             	sar    $0x1f,%eax
  80065f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800662:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800665:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800668:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80066b:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  80066e:	85 d2                	test   %edx,%edx
  800670:	79 28                	jns    80069a <vprintfmt+0x349>
				putch('-', putdat);
  800672:	83 ec 08             	sub    $0x8,%esp
  800675:	53                   	push   %ebx
  800676:	6a 2d                	push   $0x2d
  800678:	ff d7                	call   *%edi
				num = -(long long) num;
  80067a:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80067d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800680:	f7 d8                	neg    %eax
  800682:	83 d2 00             	adc    $0x0,%edx
  800685:	f7 da                	neg    %edx
  800687:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80068a:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80068d:	83 c4 10             	add    $0x10,%esp
			else
			{
				if(padc=='+')
					putch('+', putdat);
			}
			base = 10;
  800690:	b8 0a 00 00 00       	mov    $0xa,%eax
  800695:	e9 a5 00 00 00       	jmp    80073f <vprintfmt+0x3ee>
  80069a:	b8 0a 00 00 00       	mov    $0xa,%eax
				putch('-', putdat);
				num = -(long long) num;
			}
			else
			{
				if(padc=='+')
  80069f:	80 7d e3 2b          	cmpb   $0x2b,-0x1d(%ebp)
  8006a3:	0f 85 96 00 00 00    	jne    80073f <vprintfmt+0x3ee>
					putch('+', putdat);
  8006a9:	83 ec 08             	sub    $0x8,%esp
  8006ac:	53                   	push   %ebx
  8006ad:	6a 2b                	push   $0x2b
  8006af:	ff d7                	call   *%edi
  8006b1:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8006b4:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006b9:	e9 81 00 00 00       	jmp    80073f <vprintfmt+0x3ee>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006be:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8006c1:	8d 45 14             	lea    0x14(%ebp),%eax
  8006c4:	e8 14 fc ff ff       	call   8002dd <getuint>
  8006c9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006cc:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  8006cf:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8006d4:	eb 69                	jmp    80073f <vprintfmt+0x3ee>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			putch('0', putdat);
  8006d6:	83 ec 08             	sub    $0x8,%esp
  8006d9:	53                   	push   %ebx
  8006da:	6a 30                	push   $0x30
  8006dc:	ff d7                	call   *%edi
			num = getuint(&ap, lflag);
  8006de:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8006e1:	8d 45 14             	lea    0x14(%ebp),%eax
  8006e4:	e8 f4 fb ff ff       	call   8002dd <getuint>
  8006e9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006ec:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
			goto number;
  8006ef:	83 c4 10             	add    $0x10,%esp
		case 'o':
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
  8006f2:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  8006f7:	eb 46                	jmp    80073f <vprintfmt+0x3ee>

		// pointer
		case 'p':
			putch('0', putdat);
  8006f9:	83 ec 08             	sub    $0x8,%esp
  8006fc:	53                   	push   %ebx
  8006fd:	6a 30                	push   $0x30
  8006ff:	ff d7                	call   *%edi
			putch('x', putdat);
  800701:	83 c4 08             	add    $0x8,%esp
  800704:	53                   	push   %ebx
  800705:	6a 78                	push   $0x78
  800707:	ff d7                	call   *%edi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800709:	8b 45 14             	mov    0x14(%ebp),%eax
  80070c:	8d 50 04             	lea    0x4(%eax),%edx
  80070f:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800712:	8b 00                	mov    (%eax),%eax
  800714:	ba 00 00 00 00       	mov    $0x0,%edx
  800719:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80071c:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80071f:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800722:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800727:	eb 16                	jmp    80073f <vprintfmt+0x3ee>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800729:	8b 55 cc             	mov    -0x34(%ebp),%edx
  80072c:	8d 45 14             	lea    0x14(%ebp),%eax
  80072f:	e8 a9 fb ff ff       	call   8002dd <getuint>
  800734:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800737:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  80073a:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  80073f:	83 ec 0c             	sub    $0xc,%esp
  800742:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  800746:	56                   	push   %esi
  800747:	ff 75 e4             	pushl  -0x1c(%ebp)
  80074a:	50                   	push   %eax
  80074b:	ff 75 dc             	pushl  -0x24(%ebp)
  80074e:	ff 75 d8             	pushl  -0x28(%ebp)
  800751:	89 da                	mov    %ebx,%edx
  800753:	89 f8                	mov    %edi,%eax
  800755:	e8 e3 f9 ff ff       	call   80013d <printnum>
			break;
  80075a:	83 c4 20             	add    $0x20,%esp
  80075d:	e9 03 fc ff ff       	jmp    800365 <vprintfmt+0x14>

            const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
            const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

            // Your code here
			num=(unsigned long long)(uintptr_t)va_arg(ap, void *);
  800762:	8b 45 14             	mov    0x14(%ebp),%eax
  800765:	8d 50 04             	lea    0x4(%eax),%edx
  800768:	89 55 14             	mov    %edx,0x14(%ebp)
  80076b:	8b 00                	mov    (%eax),%eax
			if(!num)
  80076d:	85 c0                	test   %eax,%eax
  80076f:	75 1c                	jne    80078d <vprintfmt+0x43c>
				*(int *)putdat+=cprintf("%s",null_error);
  800771:	83 ec 08             	sub    $0x8,%esp
  800774:	68 5c 11 80 00       	push   $0x80115c
  800779:	68 ed 10 80 00       	push   $0x8010ed
  80077e:	e8 a6 f9 ff ff       	call   800129 <cprintf>
  800783:	01 03                	add    %eax,(%ebx)
  800785:	83 c4 10             	add    $0x10,%esp
  800788:	e9 d8 fb ff ff       	jmp    800365 <vprintfmt+0x14>
			else
			{
				*(char *)(int)num=*(int *)putdat;
  80078d:	8b 13                	mov    (%ebx),%edx
  80078f:	88 10                	mov    %dl,(%eax)
				if((*(int *)putdat)>128)
  800791:	81 3b 80 00 00 00    	cmpl   $0x80,(%ebx)
  800797:	0f 8e c8 fb ff ff    	jle    800365 <vprintfmt+0x14>
					*(int *)putdat+=cprintf("%s",overflow_error);
  80079d:	83 ec 08             	sub    $0x8,%esp
  8007a0:	68 94 11 80 00       	push   $0x801194
  8007a5:	68 ed 10 80 00       	push   $0x8010ed
  8007aa:	e8 7a f9 ff ff       	call   800129 <cprintf>
  8007af:	01 03                	add    %eax,(%ebx)
  8007b1:	83 c4 10             	add    $0x10,%esp
  8007b4:	e9 ac fb ff ff       	jmp    800365 <vprintfmt+0x14>
            break;
        }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007b9:	83 ec 08             	sub    $0x8,%esp
  8007bc:	53                   	push   %ebx
  8007bd:	52                   	push   %edx
  8007be:	ff d7                	call   *%edi
			break;
  8007c0:	83 c4 10             	add    $0x10,%esp
  8007c3:	e9 9d fb ff ff       	jmp    800365 <vprintfmt+0x14>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007c8:	83 ec 08             	sub    $0x8,%esp
  8007cb:	53                   	push   %ebx
  8007cc:	6a 25                	push   $0x25
  8007ce:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007d0:	83 c4 10             	add    $0x10,%esp
  8007d3:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8007d7:	0f 84 85 fb ff ff    	je     800362 <vprintfmt+0x11>
  8007dd:	83 ee 01             	sub    $0x1,%esi
  8007e0:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8007e4:	75 f7                	jne    8007dd <vprintfmt+0x48c>
  8007e6:	89 75 10             	mov    %esi,0x10(%ebp)
  8007e9:	e9 77 fb ff ff       	jmp    800365 <vprintfmt+0x14>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8007ee:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8007f1:	8d 70 01             	lea    0x1(%eax),%esi
  8007f4:	0f b6 00             	movzbl (%eax),%eax
  8007f7:	0f be d0             	movsbl %al,%edx
  8007fa:	85 d2                	test   %edx,%edx
  8007fc:	0f 85 db fd ff ff    	jne    8005dd <vprintfmt+0x28c>
  800802:	e9 5e fb ff ff       	jmp    800365 <vprintfmt+0x14>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800807:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80080a:	5b                   	pop    %ebx
  80080b:	5e                   	pop    %esi
  80080c:	5f                   	pop    %edi
  80080d:	5d                   	pop    %ebp
  80080e:	c3                   	ret    

0080080f <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80080f:	55                   	push   %ebp
  800810:	89 e5                	mov    %esp,%ebp
  800812:	83 ec 18             	sub    $0x18,%esp
  800815:	8b 45 08             	mov    0x8(%ebp),%eax
  800818:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80081b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80081e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800822:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800825:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80082c:	85 c0                	test   %eax,%eax
  80082e:	74 26                	je     800856 <vsnprintf+0x47>
  800830:	85 d2                	test   %edx,%edx
  800832:	7e 22                	jle    800856 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800834:	ff 75 14             	pushl  0x14(%ebp)
  800837:	ff 75 10             	pushl  0x10(%ebp)
  80083a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80083d:	50                   	push   %eax
  80083e:	68 17 03 80 00       	push   $0x800317
  800843:	e8 09 fb ff ff       	call   800351 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800848:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80084b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80084e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800851:	83 c4 10             	add    $0x10,%esp
  800854:	eb 05                	jmp    80085b <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800856:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80085b:	c9                   	leave  
  80085c:	c3                   	ret    

0080085d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80085d:	55                   	push   %ebp
  80085e:	89 e5                	mov    %esp,%ebp
  800860:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800863:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800866:	50                   	push   %eax
  800867:	ff 75 10             	pushl  0x10(%ebp)
  80086a:	ff 75 0c             	pushl  0xc(%ebp)
  80086d:	ff 75 08             	pushl  0x8(%ebp)
  800870:	e8 9a ff ff ff       	call   80080f <vsnprintf>
	va_end(ap);

	return rc;
}
  800875:	c9                   	leave  
  800876:	c3                   	ret    

00800877 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800877:	55                   	push   %ebp
  800878:	89 e5                	mov    %esp,%ebp
  80087a:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80087d:	80 3a 00             	cmpb   $0x0,(%edx)
  800880:	74 10                	je     800892 <strlen+0x1b>
  800882:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800887:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80088a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80088e:	75 f7                	jne    800887 <strlen+0x10>
  800890:	eb 05                	jmp    800897 <strlen+0x20>
  800892:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800897:	5d                   	pop    %ebp
  800898:	c3                   	ret    

00800899 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800899:	55                   	push   %ebp
  80089a:	89 e5                	mov    %esp,%ebp
  80089c:	53                   	push   %ebx
  80089d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8008a0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008a3:	85 c9                	test   %ecx,%ecx
  8008a5:	74 1c                	je     8008c3 <strnlen+0x2a>
  8008a7:	80 3b 00             	cmpb   $0x0,(%ebx)
  8008aa:	74 1e                	je     8008ca <strnlen+0x31>
  8008ac:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  8008b1:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008b3:	39 ca                	cmp    %ecx,%edx
  8008b5:	74 18                	je     8008cf <strnlen+0x36>
  8008b7:	83 c2 01             	add    $0x1,%edx
  8008ba:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  8008bf:	75 f0                	jne    8008b1 <strnlen+0x18>
  8008c1:	eb 0c                	jmp    8008cf <strnlen+0x36>
  8008c3:	b8 00 00 00 00       	mov    $0x0,%eax
  8008c8:	eb 05                	jmp    8008cf <strnlen+0x36>
  8008ca:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8008cf:	5b                   	pop    %ebx
  8008d0:	5d                   	pop    %ebp
  8008d1:	c3                   	ret    

008008d2 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008d2:	55                   	push   %ebp
  8008d3:	89 e5                	mov    %esp,%ebp
  8008d5:	53                   	push   %ebx
  8008d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008dc:	89 c2                	mov    %eax,%edx
  8008de:	83 c2 01             	add    $0x1,%edx
  8008e1:	83 c1 01             	add    $0x1,%ecx
  8008e4:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8008e8:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008eb:	84 db                	test   %bl,%bl
  8008ed:	75 ef                	jne    8008de <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8008ef:	5b                   	pop    %ebx
  8008f0:	5d                   	pop    %ebp
  8008f1:	c3                   	ret    

008008f2 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008f2:	55                   	push   %ebp
  8008f3:	89 e5                	mov    %esp,%ebp
  8008f5:	53                   	push   %ebx
  8008f6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008f9:	53                   	push   %ebx
  8008fa:	e8 78 ff ff ff       	call   800877 <strlen>
  8008ff:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800902:	ff 75 0c             	pushl  0xc(%ebp)
  800905:	01 d8                	add    %ebx,%eax
  800907:	50                   	push   %eax
  800908:	e8 c5 ff ff ff       	call   8008d2 <strcpy>
	return dst;
}
  80090d:	89 d8                	mov    %ebx,%eax
  80090f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800912:	c9                   	leave  
  800913:	c3                   	ret    

00800914 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800914:	55                   	push   %ebp
  800915:	89 e5                	mov    %esp,%ebp
  800917:	56                   	push   %esi
  800918:	53                   	push   %ebx
  800919:	8b 75 08             	mov    0x8(%ebp),%esi
  80091c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80091f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800922:	85 db                	test   %ebx,%ebx
  800924:	74 17                	je     80093d <strncpy+0x29>
  800926:	01 f3                	add    %esi,%ebx
  800928:	89 f1                	mov    %esi,%ecx
		*dst++ = *src;
  80092a:	83 c1 01             	add    $0x1,%ecx
  80092d:	0f b6 02             	movzbl (%edx),%eax
  800930:	88 41 ff             	mov    %al,-0x1(%ecx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800933:	80 3a 01             	cmpb   $0x1,(%edx)
  800936:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800939:	39 cb                	cmp    %ecx,%ebx
  80093b:	75 ed                	jne    80092a <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80093d:	89 f0                	mov    %esi,%eax
  80093f:	5b                   	pop    %ebx
  800940:	5e                   	pop    %esi
  800941:	5d                   	pop    %ebp
  800942:	c3                   	ret    

00800943 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800943:	55                   	push   %ebp
  800944:	89 e5                	mov    %esp,%ebp
  800946:	56                   	push   %esi
  800947:	53                   	push   %ebx
  800948:	8b 75 08             	mov    0x8(%ebp),%esi
  80094b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80094e:	8b 55 10             	mov    0x10(%ebp),%edx
  800951:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800953:	85 d2                	test   %edx,%edx
  800955:	74 35                	je     80098c <strlcpy+0x49>
		while (--size > 0 && *src != '\0')
  800957:	89 d0                	mov    %edx,%eax
  800959:	83 e8 01             	sub    $0x1,%eax
  80095c:	74 25                	je     800983 <strlcpy+0x40>
  80095e:	0f b6 0b             	movzbl (%ebx),%ecx
  800961:	84 c9                	test   %cl,%cl
  800963:	74 22                	je     800987 <strlcpy+0x44>
  800965:	8d 53 01             	lea    0x1(%ebx),%edx
  800968:	01 c3                	add    %eax,%ebx
  80096a:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
  80096c:	83 c0 01             	add    $0x1,%eax
  80096f:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800972:	39 da                	cmp    %ebx,%edx
  800974:	74 13                	je     800989 <strlcpy+0x46>
  800976:	83 c2 01             	add    $0x1,%edx
  800979:	0f b6 4a ff          	movzbl -0x1(%edx),%ecx
  80097d:	84 c9                	test   %cl,%cl
  80097f:	75 eb                	jne    80096c <strlcpy+0x29>
  800981:	eb 06                	jmp    800989 <strlcpy+0x46>
  800983:	89 f0                	mov    %esi,%eax
  800985:	eb 02                	jmp    800989 <strlcpy+0x46>
  800987:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800989:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80098c:	29 f0                	sub    %esi,%eax
}
  80098e:	5b                   	pop    %ebx
  80098f:	5e                   	pop    %esi
  800990:	5d                   	pop    %ebp
  800991:	c3                   	ret    

00800992 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800992:	55                   	push   %ebp
  800993:	89 e5                	mov    %esp,%ebp
  800995:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800998:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80099b:	0f b6 01             	movzbl (%ecx),%eax
  80099e:	84 c0                	test   %al,%al
  8009a0:	74 15                	je     8009b7 <strcmp+0x25>
  8009a2:	3a 02                	cmp    (%edx),%al
  8009a4:	75 11                	jne    8009b7 <strcmp+0x25>
		p++, q++;
  8009a6:	83 c1 01             	add    $0x1,%ecx
  8009a9:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8009ac:	0f b6 01             	movzbl (%ecx),%eax
  8009af:	84 c0                	test   %al,%al
  8009b1:	74 04                	je     8009b7 <strcmp+0x25>
  8009b3:	3a 02                	cmp    (%edx),%al
  8009b5:	74 ef                	je     8009a6 <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009b7:	0f b6 c0             	movzbl %al,%eax
  8009ba:	0f b6 12             	movzbl (%edx),%edx
  8009bd:	29 d0                	sub    %edx,%eax
}
  8009bf:	5d                   	pop    %ebp
  8009c0:	c3                   	ret    

008009c1 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009c1:	55                   	push   %ebp
  8009c2:	89 e5                	mov    %esp,%ebp
  8009c4:	56                   	push   %esi
  8009c5:	53                   	push   %ebx
  8009c6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8009c9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009cc:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  8009cf:	85 f6                	test   %esi,%esi
  8009d1:	74 29                	je     8009fc <strncmp+0x3b>
  8009d3:	0f b6 03             	movzbl (%ebx),%eax
  8009d6:	84 c0                	test   %al,%al
  8009d8:	74 30                	je     800a0a <strncmp+0x49>
  8009da:	3a 02                	cmp    (%edx),%al
  8009dc:	75 2c                	jne    800a0a <strncmp+0x49>
  8009de:	8d 43 01             	lea    0x1(%ebx),%eax
  8009e1:	01 de                	add    %ebx,%esi
		n--, p++, q++;
  8009e3:	89 c3                	mov    %eax,%ebx
  8009e5:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009e8:	39 c6                	cmp    %eax,%esi
  8009ea:	74 17                	je     800a03 <strncmp+0x42>
  8009ec:	0f b6 08             	movzbl (%eax),%ecx
  8009ef:	84 c9                	test   %cl,%cl
  8009f1:	74 17                	je     800a0a <strncmp+0x49>
  8009f3:	83 c0 01             	add    $0x1,%eax
  8009f6:	3a 0a                	cmp    (%edx),%cl
  8009f8:	74 e9                	je     8009e3 <strncmp+0x22>
  8009fa:	eb 0e                	jmp    800a0a <strncmp+0x49>
		n--, p++, q++;
	if (n == 0)
		return 0;
  8009fc:	b8 00 00 00 00       	mov    $0x0,%eax
  800a01:	eb 0f                	jmp    800a12 <strncmp+0x51>
  800a03:	b8 00 00 00 00       	mov    $0x0,%eax
  800a08:	eb 08                	jmp    800a12 <strncmp+0x51>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a0a:	0f b6 03             	movzbl (%ebx),%eax
  800a0d:	0f b6 12             	movzbl (%edx),%edx
  800a10:	29 d0                	sub    %edx,%eax
}
  800a12:	5b                   	pop    %ebx
  800a13:	5e                   	pop    %esi
  800a14:	5d                   	pop    %ebp
  800a15:	c3                   	ret    

00800a16 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a16:	55                   	push   %ebp
  800a17:	89 e5                	mov    %esp,%ebp
  800a19:	53                   	push   %ebx
  800a1a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a1d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
  800a20:	0f b6 10             	movzbl (%eax),%edx
  800a23:	84 d2                	test   %dl,%dl
  800a25:	74 1d                	je     800a44 <strchr+0x2e>
  800a27:	89 d9                	mov    %ebx,%ecx
		if (*s == c)
  800a29:	38 d3                	cmp    %dl,%bl
  800a2b:	75 06                	jne    800a33 <strchr+0x1d>
  800a2d:	eb 1a                	jmp    800a49 <strchr+0x33>
  800a2f:	38 ca                	cmp    %cl,%dl
  800a31:	74 16                	je     800a49 <strchr+0x33>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a33:	83 c0 01             	add    $0x1,%eax
  800a36:	0f b6 10             	movzbl (%eax),%edx
  800a39:	84 d2                	test   %dl,%dl
  800a3b:	75 f2                	jne    800a2f <strchr+0x19>
		if (*s == c)
			return (char *) s;
	return 0;
  800a3d:	b8 00 00 00 00       	mov    $0x0,%eax
  800a42:	eb 05                	jmp    800a49 <strchr+0x33>
  800a44:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a49:	5b                   	pop    %ebx
  800a4a:	5d                   	pop    %ebp
  800a4b:	c3                   	ret    

00800a4c <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a4c:	55                   	push   %ebp
  800a4d:	89 e5                	mov    %esp,%ebp
  800a4f:	53                   	push   %ebx
  800a50:	8b 45 08             	mov    0x8(%ebp),%eax
  800a53:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  800a56:	0f b6 18             	movzbl (%eax),%ebx
		if (*s == c)
  800a59:	38 d3                	cmp    %dl,%bl
  800a5b:	74 14                	je     800a71 <strfind+0x25>
  800a5d:	89 d1                	mov    %edx,%ecx
  800a5f:	84 db                	test   %bl,%bl
  800a61:	74 0e                	je     800a71 <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a63:	83 c0 01             	add    $0x1,%eax
  800a66:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a69:	38 ca                	cmp    %cl,%dl
  800a6b:	74 04                	je     800a71 <strfind+0x25>
  800a6d:	84 d2                	test   %dl,%dl
  800a6f:	75 f2                	jne    800a63 <strfind+0x17>
			break;
	return (char *) s;
}
  800a71:	5b                   	pop    %ebx
  800a72:	5d                   	pop    %ebp
  800a73:	c3                   	ret    

00800a74 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a74:	55                   	push   %ebp
  800a75:	89 e5                	mov    %esp,%ebp
  800a77:	57                   	push   %edi
  800a78:	56                   	push   %esi
  800a79:	53                   	push   %ebx
  800a7a:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a7d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a80:	85 c9                	test   %ecx,%ecx
  800a82:	74 36                	je     800aba <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a84:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a8a:	75 28                	jne    800ab4 <memset+0x40>
  800a8c:	f6 c1 03             	test   $0x3,%cl
  800a8f:	75 23                	jne    800ab4 <memset+0x40>
		c &= 0xFF;
  800a91:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a95:	89 d3                	mov    %edx,%ebx
  800a97:	c1 e3 08             	shl    $0x8,%ebx
  800a9a:	89 d6                	mov    %edx,%esi
  800a9c:	c1 e6 18             	shl    $0x18,%esi
  800a9f:	89 d0                	mov    %edx,%eax
  800aa1:	c1 e0 10             	shl    $0x10,%eax
  800aa4:	09 f0                	or     %esi,%eax
  800aa6:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800aa8:	89 d8                	mov    %ebx,%eax
  800aaa:	09 d0                	or     %edx,%eax
  800aac:	c1 e9 02             	shr    $0x2,%ecx
  800aaf:	fc                   	cld    
  800ab0:	f3 ab                	rep stos %eax,%es:(%edi)
  800ab2:	eb 06                	jmp    800aba <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800ab4:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ab7:	fc                   	cld    
  800ab8:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800aba:	89 f8                	mov    %edi,%eax
  800abc:	5b                   	pop    %ebx
  800abd:	5e                   	pop    %esi
  800abe:	5f                   	pop    %edi
  800abf:	5d                   	pop    %ebp
  800ac0:	c3                   	ret    

00800ac1 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ac1:	55                   	push   %ebp
  800ac2:	89 e5                	mov    %esp,%ebp
  800ac4:	57                   	push   %edi
  800ac5:	56                   	push   %esi
  800ac6:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac9:	8b 75 0c             	mov    0xc(%ebp),%esi
  800acc:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800acf:	39 c6                	cmp    %eax,%esi
  800ad1:	73 35                	jae    800b08 <memmove+0x47>
  800ad3:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ad6:	39 d0                	cmp    %edx,%eax
  800ad8:	73 2e                	jae    800b08 <memmove+0x47>
		s += n;
		d += n;
  800ada:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800add:	89 d6                	mov    %edx,%esi
  800adf:	09 fe                	or     %edi,%esi
  800ae1:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800ae7:	75 13                	jne    800afc <memmove+0x3b>
  800ae9:	f6 c1 03             	test   $0x3,%cl
  800aec:	75 0e                	jne    800afc <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800aee:	83 ef 04             	sub    $0x4,%edi
  800af1:	8d 72 fc             	lea    -0x4(%edx),%esi
  800af4:	c1 e9 02             	shr    $0x2,%ecx
  800af7:	fd                   	std    
  800af8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800afa:	eb 09                	jmp    800b05 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800afc:	83 ef 01             	sub    $0x1,%edi
  800aff:	8d 72 ff             	lea    -0x1(%edx),%esi
  800b02:	fd                   	std    
  800b03:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b05:	fc                   	cld    
  800b06:	eb 1d                	jmp    800b25 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b08:	89 f2                	mov    %esi,%edx
  800b0a:	09 c2                	or     %eax,%edx
  800b0c:	f6 c2 03             	test   $0x3,%dl
  800b0f:	75 0f                	jne    800b20 <memmove+0x5f>
  800b11:	f6 c1 03             	test   $0x3,%cl
  800b14:	75 0a                	jne    800b20 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800b16:	c1 e9 02             	shr    $0x2,%ecx
  800b19:	89 c7                	mov    %eax,%edi
  800b1b:	fc                   	cld    
  800b1c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b1e:	eb 05                	jmp    800b25 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b20:	89 c7                	mov    %eax,%edi
  800b22:	fc                   	cld    
  800b23:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b25:	5e                   	pop    %esi
  800b26:	5f                   	pop    %edi
  800b27:	5d                   	pop    %ebp
  800b28:	c3                   	ret    

00800b29 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800b29:	55                   	push   %ebp
  800b2a:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b2c:	ff 75 10             	pushl  0x10(%ebp)
  800b2f:	ff 75 0c             	pushl  0xc(%ebp)
  800b32:	ff 75 08             	pushl  0x8(%ebp)
  800b35:	e8 87 ff ff ff       	call   800ac1 <memmove>
}
  800b3a:	c9                   	leave  
  800b3b:	c3                   	ret    

00800b3c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b3c:	55                   	push   %ebp
  800b3d:	89 e5                	mov    %esp,%ebp
  800b3f:	57                   	push   %edi
  800b40:	56                   	push   %esi
  800b41:	53                   	push   %ebx
  800b42:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800b45:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b48:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b4b:	85 c0                	test   %eax,%eax
  800b4d:	74 39                	je     800b88 <memcmp+0x4c>
  800b4f:	8d 78 ff             	lea    -0x1(%eax),%edi
		if (*s1 != *s2)
  800b52:	0f b6 13             	movzbl (%ebx),%edx
  800b55:	0f b6 0e             	movzbl (%esi),%ecx
  800b58:	38 ca                	cmp    %cl,%dl
  800b5a:	75 17                	jne    800b73 <memcmp+0x37>
  800b5c:	b8 00 00 00 00       	mov    $0x0,%eax
  800b61:	eb 1a                	jmp    800b7d <memcmp+0x41>
  800b63:	0f b6 54 03 01       	movzbl 0x1(%ebx,%eax,1),%edx
  800b68:	83 c0 01             	add    $0x1,%eax
  800b6b:	0f b6 0c 06          	movzbl (%esi,%eax,1),%ecx
  800b6f:	38 ca                	cmp    %cl,%dl
  800b71:	74 0a                	je     800b7d <memcmp+0x41>
			return (int) *s1 - (int) *s2;
  800b73:	0f b6 c2             	movzbl %dl,%eax
  800b76:	0f b6 c9             	movzbl %cl,%ecx
  800b79:	29 c8                	sub    %ecx,%eax
  800b7b:	eb 10                	jmp    800b8d <memcmp+0x51>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b7d:	39 f8                	cmp    %edi,%eax
  800b7f:	75 e2                	jne    800b63 <memcmp+0x27>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b81:	b8 00 00 00 00       	mov    $0x0,%eax
  800b86:	eb 05                	jmp    800b8d <memcmp+0x51>
  800b88:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b8d:	5b                   	pop    %ebx
  800b8e:	5e                   	pop    %esi
  800b8f:	5f                   	pop    %edi
  800b90:	5d                   	pop    %ebp
  800b91:	c3                   	ret    

00800b92 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b92:	55                   	push   %ebp
  800b93:	89 e5                	mov    %esp,%ebp
  800b95:	53                   	push   %ebx
  800b96:	8b 55 08             	mov    0x8(%ebp),%edx
	const void *ends = (const char *) s + n;
  800b99:	89 d0                	mov    %edx,%eax
  800b9b:	03 45 10             	add    0x10(%ebp),%eax
	for (; s < ends; s++)
  800b9e:	39 c2                	cmp    %eax,%edx
  800ba0:	73 1d                	jae    800bbf <memfind+0x2d>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ba2:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
  800ba6:	0f b6 0a             	movzbl (%edx),%ecx
  800ba9:	39 d9                	cmp    %ebx,%ecx
  800bab:	75 09                	jne    800bb6 <memfind+0x24>
  800bad:	eb 14                	jmp    800bc3 <memfind+0x31>
  800baf:	0f b6 0a             	movzbl (%edx),%ecx
  800bb2:	39 d9                	cmp    %ebx,%ecx
  800bb4:	74 11                	je     800bc7 <memfind+0x35>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800bb6:	83 c2 01             	add    $0x1,%edx
  800bb9:	39 d0                	cmp    %edx,%eax
  800bbb:	75 f2                	jne    800baf <memfind+0x1d>
  800bbd:	eb 0a                	jmp    800bc9 <memfind+0x37>
  800bbf:	89 d0                	mov    %edx,%eax
  800bc1:	eb 06                	jmp    800bc9 <memfind+0x37>
		if (*(const unsigned char *) s == (unsigned char) c)
  800bc3:	89 d0                	mov    %edx,%eax
  800bc5:	eb 02                	jmp    800bc9 <memfind+0x37>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800bc7:	89 d0                	mov    %edx,%eax
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800bc9:	5b                   	pop    %ebx
  800bca:	5d                   	pop    %ebp
  800bcb:	c3                   	ret    

00800bcc <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800bcc:	55                   	push   %ebp
  800bcd:	89 e5                	mov    %esp,%ebp
  800bcf:	57                   	push   %edi
  800bd0:	56                   	push   %esi
  800bd1:	53                   	push   %ebx
  800bd2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bd5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bd8:	0f b6 01             	movzbl (%ecx),%eax
  800bdb:	3c 20                	cmp    $0x20,%al
  800bdd:	74 04                	je     800be3 <strtol+0x17>
  800bdf:	3c 09                	cmp    $0x9,%al
  800be1:	75 0e                	jne    800bf1 <strtol+0x25>
		s++;
  800be3:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800be6:	0f b6 01             	movzbl (%ecx),%eax
  800be9:	3c 20                	cmp    $0x20,%al
  800beb:	74 f6                	je     800be3 <strtol+0x17>
  800bed:	3c 09                	cmp    $0x9,%al
  800bef:	74 f2                	je     800be3 <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  800bf1:	3c 2b                	cmp    $0x2b,%al
  800bf3:	75 0a                	jne    800bff <strtol+0x33>
		s++;
  800bf5:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800bf8:	bf 00 00 00 00       	mov    $0x0,%edi
  800bfd:	eb 11                	jmp    800c10 <strtol+0x44>
  800bff:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c04:	3c 2d                	cmp    $0x2d,%al
  800c06:	75 08                	jne    800c10 <strtol+0x44>
		s++, neg = 1;
  800c08:	83 c1 01             	add    $0x1,%ecx
  800c0b:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c10:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c16:	75 15                	jne    800c2d <strtol+0x61>
  800c18:	80 39 30             	cmpb   $0x30,(%ecx)
  800c1b:	75 10                	jne    800c2d <strtol+0x61>
  800c1d:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c21:	75 7c                	jne    800c9f <strtol+0xd3>
		s += 2, base = 16;
  800c23:	83 c1 02             	add    $0x2,%ecx
  800c26:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c2b:	eb 16                	jmp    800c43 <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  800c2d:	85 db                	test   %ebx,%ebx
  800c2f:	75 12                	jne    800c43 <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c31:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c36:	80 39 30             	cmpb   $0x30,(%ecx)
  800c39:	75 08                	jne    800c43 <strtol+0x77>
		s++, base = 8;
  800c3b:	83 c1 01             	add    $0x1,%ecx
  800c3e:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800c43:	b8 00 00 00 00       	mov    $0x0,%eax
  800c48:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c4b:	0f b6 11             	movzbl (%ecx),%edx
  800c4e:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c51:	89 f3                	mov    %esi,%ebx
  800c53:	80 fb 09             	cmp    $0x9,%bl
  800c56:	77 08                	ja     800c60 <strtol+0x94>
			dig = *s - '0';
  800c58:	0f be d2             	movsbl %dl,%edx
  800c5b:	83 ea 30             	sub    $0x30,%edx
  800c5e:	eb 22                	jmp    800c82 <strtol+0xb6>
		else if (*s >= 'a' && *s <= 'z')
  800c60:	8d 72 9f             	lea    -0x61(%edx),%esi
  800c63:	89 f3                	mov    %esi,%ebx
  800c65:	80 fb 19             	cmp    $0x19,%bl
  800c68:	77 08                	ja     800c72 <strtol+0xa6>
			dig = *s - 'a' + 10;
  800c6a:	0f be d2             	movsbl %dl,%edx
  800c6d:	83 ea 57             	sub    $0x57,%edx
  800c70:	eb 10                	jmp    800c82 <strtol+0xb6>
		else if (*s >= 'A' && *s <= 'Z')
  800c72:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c75:	89 f3                	mov    %esi,%ebx
  800c77:	80 fb 19             	cmp    $0x19,%bl
  800c7a:	77 16                	ja     800c92 <strtol+0xc6>
			dig = *s - 'A' + 10;
  800c7c:	0f be d2             	movsbl %dl,%edx
  800c7f:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800c82:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c85:	7d 0b                	jge    800c92 <strtol+0xc6>
			break;
		s++, val = (val * base) + dig;
  800c87:	83 c1 01             	add    $0x1,%ecx
  800c8a:	0f af 45 10          	imul   0x10(%ebp),%eax
  800c8e:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800c90:	eb b9                	jmp    800c4b <strtol+0x7f>

	if (endptr)
  800c92:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c96:	74 0d                	je     800ca5 <strtol+0xd9>
		*endptr = (char *) s;
  800c98:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c9b:	89 0e                	mov    %ecx,(%esi)
  800c9d:	eb 06                	jmp    800ca5 <strtol+0xd9>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c9f:	85 db                	test   %ebx,%ebx
  800ca1:	74 98                	je     800c3b <strtol+0x6f>
  800ca3:	eb 9e                	jmp    800c43 <strtol+0x77>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800ca5:	89 c2                	mov    %eax,%edx
  800ca7:	f7 da                	neg    %edx
  800ca9:	85 ff                	test   %edi,%edi
  800cab:	0f 45 c2             	cmovne %edx,%eax
}
  800cae:	5b                   	pop    %ebx
  800caf:	5e                   	pop    %esi
  800cb0:	5f                   	pop    %edi
  800cb1:	5d                   	pop    %ebp
  800cb2:	c3                   	ret    

00800cb3 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800cb3:	55                   	push   %ebp
  800cb4:	89 e5                	mov    %esp,%ebp
  800cb6:	57                   	push   %edi
  800cb7:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800cb8:	b8 00 00 00 00       	mov    $0x0,%eax
  800cbd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc0:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc3:	89 c3                	mov    %eax,%ebx
  800cc5:	89 c7                	mov    %eax,%edi
  800cc7:	51                   	push   %ecx
  800cc8:	52                   	push   %edx
  800cc9:	53                   	push   %ebx
  800cca:	54                   	push   %esp
  800ccb:	55                   	push   %ebp
  800ccc:	56                   	push   %esi
  800ccd:	57                   	push   %edi
  800cce:	5f                   	pop    %edi
  800ccf:	5e                   	pop    %esi
  800cd0:	5d                   	pop    %ebp
  800cd1:	5c                   	pop    %esp
  800cd2:	5b                   	pop    %ebx
  800cd3:	5a                   	pop    %edx
  800cd4:	59                   	pop    %ecx

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800cd5:	5b                   	pop    %ebx
  800cd6:	5f                   	pop    %edi
  800cd7:	5d                   	pop    %ebp
  800cd8:	c3                   	ret    

00800cd9 <sys_cgetc>:

int
sys_cgetc(void)
{
  800cd9:	55                   	push   %ebp
  800cda:	89 e5                	mov    %esp,%ebp
  800cdc:	57                   	push   %edi
  800cdd:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800cde:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ce3:	b8 01 00 00 00       	mov    $0x1,%eax
  800ce8:	89 ca                	mov    %ecx,%edx
  800cea:	89 cb                	mov    %ecx,%ebx
  800cec:	89 cf                	mov    %ecx,%edi
  800cee:	51                   	push   %ecx
  800cef:	52                   	push   %edx
  800cf0:	53                   	push   %ebx
  800cf1:	54                   	push   %esp
  800cf2:	55                   	push   %ebp
  800cf3:	56                   	push   %esi
  800cf4:	57                   	push   %edi
  800cf5:	5f                   	pop    %edi
  800cf6:	5e                   	pop    %esi
  800cf7:	5d                   	pop    %ebp
  800cf8:	5c                   	pop    %esp
  800cf9:	5b                   	pop    %ebx
  800cfa:	5a                   	pop    %edx
  800cfb:	59                   	pop    %ecx

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800cfc:	5b                   	pop    %ebx
  800cfd:	5f                   	pop    %edi
  800cfe:	5d                   	pop    %ebp
  800cff:	c3                   	ret    

00800d00 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800d00:	55                   	push   %ebp
  800d01:	89 e5                	mov    %esp,%ebp
  800d03:	57                   	push   %edi
  800d04:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800d05:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d0a:	b8 03 00 00 00       	mov    $0x3,%eax
  800d0f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d12:	89 d9                	mov    %ebx,%ecx
  800d14:	89 df                	mov    %ebx,%edi
  800d16:	51                   	push   %ecx
  800d17:	52                   	push   %edx
  800d18:	53                   	push   %ebx
  800d19:	54                   	push   %esp
  800d1a:	55                   	push   %ebp
  800d1b:	56                   	push   %esi
  800d1c:	57                   	push   %edi
  800d1d:	5f                   	pop    %edi
  800d1e:	5e                   	pop    %esi
  800d1f:	5d                   	pop    %ebp
  800d20:	5c                   	pop    %esp
  800d21:	5b                   	pop    %ebx
  800d22:	5a                   	pop    %edx
  800d23:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  800d24:	85 c0                	test   %eax,%eax
  800d26:	7e 17                	jle    800d3f <sys_env_destroy+0x3f>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d28:	83 ec 0c             	sub    $0xc,%esp
  800d2b:	50                   	push   %eax
  800d2c:	6a 03                	push   $0x3
  800d2e:	68 4c 13 80 00       	push   $0x80134c
  800d33:	6a 26                	push   $0x26
  800d35:	68 69 13 80 00       	push   $0x801369
  800d3a:	e8 7f 00 00 00       	call   800dbe <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800d3f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800d42:	5b                   	pop    %ebx
  800d43:	5f                   	pop    %edi
  800d44:	5d                   	pop    %ebp
  800d45:	c3                   	ret    

00800d46 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d46:	55                   	push   %ebp
  800d47:	89 e5                	mov    %esp,%ebp
  800d49:	57                   	push   %edi
  800d4a:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800d4b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d50:	b8 02 00 00 00       	mov    $0x2,%eax
  800d55:	89 ca                	mov    %ecx,%edx
  800d57:	89 cb                	mov    %ecx,%ebx
  800d59:	89 cf                	mov    %ecx,%edi
  800d5b:	51                   	push   %ecx
  800d5c:	52                   	push   %edx
  800d5d:	53                   	push   %ebx
  800d5e:	54                   	push   %esp
  800d5f:	55                   	push   %ebp
  800d60:	56                   	push   %esi
  800d61:	57                   	push   %edi
  800d62:	5f                   	pop    %edi
  800d63:	5e                   	pop    %esi
  800d64:	5d                   	pop    %ebp
  800d65:	5c                   	pop    %esp
  800d66:	5b                   	pop    %ebx
  800d67:	5a                   	pop    %edx
  800d68:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d69:	5b                   	pop    %ebx
  800d6a:	5f                   	pop    %edi
  800d6b:	5d                   	pop    %ebp
  800d6c:	c3                   	ret    

00800d6d <sys_map_kernel_page>:

int
sys_map_kernel_page(void* kpage, void* va)
{
  800d6d:	55                   	push   %ebp
  800d6e:	89 e5                	mov    %esp,%ebp
  800d70:	57                   	push   %edi
  800d71:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800d72:	bf 00 00 00 00       	mov    $0x0,%edi
  800d77:	b8 04 00 00 00       	mov    $0x4,%eax
  800d7c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d7f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d82:	89 fb                	mov    %edi,%ebx
  800d84:	51                   	push   %ecx
  800d85:	52                   	push   %edx
  800d86:	53                   	push   %ebx
  800d87:	54                   	push   %esp
  800d88:	55                   	push   %ebp
  800d89:	56                   	push   %esi
  800d8a:	57                   	push   %edi
  800d8b:	5f                   	pop    %edi
  800d8c:	5e                   	pop    %esi
  800d8d:	5d                   	pop    %ebp
  800d8e:	5c                   	pop    %esp
  800d8f:	5b                   	pop    %ebx
  800d90:	5a                   	pop    %edx
  800d91:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  800d92:	5b                   	pop    %ebx
  800d93:	5f                   	pop    %edi
  800d94:	5d                   	pop    %ebp
  800d95:	c3                   	ret    

00800d96 <sys_sbrk>:

int
sys_sbrk(uint32_t inc)
{
  800d96:	55                   	push   %ebp
  800d97:	89 e5                	mov    %esp,%ebp
  800d99:	57                   	push   %edi
  800d9a:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800d9b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800da0:	b8 05 00 00 00       	mov    $0x5,%eax
  800da5:	8b 55 08             	mov    0x8(%ebp),%edx
  800da8:	89 cb                	mov    %ecx,%ebx
  800daa:	89 cf                	mov    %ecx,%edi
  800dac:	51                   	push   %ecx
  800dad:	52                   	push   %edx
  800dae:	53                   	push   %ebx
  800daf:	54                   	push   %esp
  800db0:	55                   	push   %ebp
  800db1:	56                   	push   %esi
  800db2:	57                   	push   %edi
  800db3:	5f                   	pop    %edi
  800db4:	5e                   	pop    %esi
  800db5:	5d                   	pop    %ebp
  800db6:	5c                   	pop    %esp
  800db7:	5b                   	pop    %ebx
  800db8:	5a                   	pop    %edx
  800db9:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  800dba:	5b                   	pop    %ebx
  800dbb:	5f                   	pop    %edi
  800dbc:	5d                   	pop    %ebp
  800dbd:	c3                   	ret    

00800dbe <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800dbe:	55                   	push   %ebp
  800dbf:	89 e5                	mov    %esp,%ebp
  800dc1:	56                   	push   %esi
  800dc2:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800dc3:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	if (argv0)
  800dc6:	a1 08 20 80 00       	mov    0x802008,%eax
  800dcb:	85 c0                	test   %eax,%eax
  800dcd:	74 11                	je     800de0 <_panic+0x22>
		cprintf("%s: ", argv0);
  800dcf:	83 ec 08             	sub    $0x8,%esp
  800dd2:	50                   	push   %eax
  800dd3:	68 77 13 80 00       	push   $0x801377
  800dd8:	e8 4c f3 ff ff       	call   800129 <cprintf>
  800ddd:	83 c4 10             	add    $0x10,%esp
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800de0:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800de6:	e8 5b ff ff ff       	call   800d46 <sys_getenvid>
  800deb:	83 ec 0c             	sub    $0xc,%esp
  800dee:	ff 75 0c             	pushl  0xc(%ebp)
  800df1:	ff 75 08             	pushl  0x8(%ebp)
  800df4:	56                   	push   %esi
  800df5:	50                   	push   %eax
  800df6:	68 7c 13 80 00       	push   $0x80137c
  800dfb:	e8 29 f3 ff ff       	call   800129 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800e00:	83 c4 18             	add    $0x18,%esp
  800e03:	53                   	push   %ebx
  800e04:	ff 75 10             	pushl  0x10(%ebp)
  800e07:	e8 cc f2 ff ff       	call   8000d8 <vcprintf>
	cprintf("\n");
  800e0c:	c7 04 24 c0 10 80 00 	movl   $0x8010c0,(%esp)
  800e13:	e8 11 f3 ff ff       	call   800129 <cprintf>
  800e18:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800e1b:	cc                   	int3   
  800e1c:	eb fd                	jmp    800e1b <_panic+0x5d>
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
