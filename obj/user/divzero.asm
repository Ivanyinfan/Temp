
obj/user/divzero:     file format elf32-i386


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
  80002c:	e8 2f 00 00 00       	call   800060 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

int zero;

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	zero = 0;
  800039:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800040:	00 00 00 
	cprintf("1/0 is %08x!\n", 1/zero);
  800043:	b8 01 00 00 00       	mov    $0x1,%eax
  800048:	b9 00 00 00 00       	mov    $0x0,%ecx
  80004d:	99                   	cltd   
  80004e:	f7 f9                	idiv   %ecx
  800050:	50                   	push   %eax
  800051:	68 b4 10 80 00       	push   $0x8010b4
  800056:	e8 e0 00 00 00       	call   80013b <cprintf>
}
  80005b:	83 c4 10             	add    $0x10,%esp
  80005e:	c9                   	leave  
  80005f:	c3                   	ret    

00800060 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800060:	55                   	push   %ebp
  800061:	89 e5                	mov    %esp,%ebp
  800063:	83 ec 08             	sub    $0x8,%esp
  800066:	8b 45 08             	mov    0x8(%ebp),%eax
  800069:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  80006c:	c7 05 08 20 80 00 00 	movl   $0x0,0x802008
  800073:	00 00 00 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800076:	85 c0                	test   %eax,%eax
  800078:	7e 08                	jle    800082 <libmain+0x22>
		binaryname = argv[0];
  80007a:	8b 0a                	mov    (%edx),%ecx
  80007c:	89 0d 00 20 80 00    	mov    %ecx,0x802000

	// call user main routine
	umain(argc, argv);
  800082:	83 ec 08             	sub    $0x8,%esp
  800085:	52                   	push   %edx
  800086:	50                   	push   %eax
  800087:	e8 a7 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80008c:	e8 05 00 00 00       	call   800096 <exit>
}
  800091:	83 c4 10             	add    $0x10,%esp
  800094:	c9                   	leave  
  800095:	c3                   	ret    

00800096 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800096:	55                   	push   %ebp
  800097:	89 e5                	mov    %esp,%ebp
  800099:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80009c:	6a 00                	push   $0x0
  80009e:	e8 6f 0c 00 00       	call   800d12 <sys_env_destroy>
}
  8000a3:	83 c4 10             	add    $0x10,%esp
  8000a6:	c9                   	leave  
  8000a7:	c3                   	ret    

008000a8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000a8:	55                   	push   %ebp
  8000a9:	89 e5                	mov    %esp,%ebp
  8000ab:	53                   	push   %ebx
  8000ac:	83 ec 04             	sub    $0x4,%esp
  8000af:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000b2:	8b 13                	mov    (%ebx),%edx
  8000b4:	8d 42 01             	lea    0x1(%edx),%eax
  8000b7:	89 03                	mov    %eax,(%ebx)
  8000b9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000bc:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000c0:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000c5:	75 1a                	jne    8000e1 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8000c7:	83 ec 08             	sub    $0x8,%esp
  8000ca:	68 ff 00 00 00       	push   $0xff
  8000cf:	8d 43 08             	lea    0x8(%ebx),%eax
  8000d2:	50                   	push   %eax
  8000d3:	e8 ed 0b 00 00       	call   800cc5 <sys_cputs>
		b->idx = 0;
  8000d8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8000de:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8000e1:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000e5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000e8:	c9                   	leave  
  8000e9:	c3                   	ret    

008000ea <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8000ea:	55                   	push   %ebp
  8000eb:	89 e5                	mov    %esp,%ebp
  8000ed:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8000f3:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8000fa:	00 00 00 
	b.cnt = 0;
  8000fd:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800104:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800107:	ff 75 0c             	pushl  0xc(%ebp)
  80010a:	ff 75 08             	pushl  0x8(%ebp)
  80010d:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800113:	50                   	push   %eax
  800114:	68 a8 00 80 00       	push   $0x8000a8
  800119:	e8 45 02 00 00       	call   800363 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80011e:	83 c4 08             	add    $0x8,%esp
  800121:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800127:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80012d:	50                   	push   %eax
  80012e:	e8 92 0b 00 00       	call   800cc5 <sys_cputs>

	return b.cnt;
}
  800133:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800139:	c9                   	leave  
  80013a:	c3                   	ret    

0080013b <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80013b:	55                   	push   %ebp
  80013c:	89 e5                	mov    %esp,%ebp
  80013e:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800141:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800144:	50                   	push   %eax
  800145:	ff 75 08             	pushl  0x8(%ebp)
  800148:	e8 9d ff ff ff       	call   8000ea <vcprintf>
	va_end(ap);

	return cnt;
}
  80014d:	c9                   	leave  
  80014e:	c3                   	ret    

0080014f <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80014f:	55                   	push   %ebp
  800150:	89 e5                	mov    %esp,%ebp
  800152:	57                   	push   %edi
  800153:	56                   	push   %esi
  800154:	53                   	push   %ebx
  800155:	83 ec 1c             	sub    $0x1c,%esp
  800158:	89 c7                	mov    %eax,%edi
  80015a:	89 d6                	mov    %edx,%esi
  80015c:	8b 45 08             	mov    0x8(%ebp),%eax
  80015f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800162:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800165:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	// if cprintf'parameter includes pattern of the form "%-", padding
	// space on the right side if neccesary.
	// you can add helper function if needed.
	// your code here:
	int length,showsign=0;
	if(padc=='-'&&num>=base)
  800168:	83 7d 18 2d          	cmpl   $0x2d,0x18(%ebp)
  80016c:	0f 85 8a 00 00 00    	jne    8001fc <printnum+0xad>
  800172:	8b 45 10             	mov    0x10(%ebp),%eax
  800175:	ba 00 00 00 00       	mov    $0x0,%edx
  80017a:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80017d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800180:	39 da                	cmp    %ebx,%edx
  800182:	72 09                	jb     80018d <printnum+0x3e>
  800184:	39 4d 10             	cmp    %ecx,0x10(%ebp)
  800187:	0f 87 87 00 00 00    	ja     800214 <printnum+0xc5>
	{
		length=*(int *)putdat;
  80018d:	8b 1e                	mov    (%esi),%ebx
		printnum(putch,putdat,num/base,base,0,padc);
  80018f:	83 ec 0c             	sub    $0xc,%esp
  800192:	6a 2d                	push   $0x2d
  800194:	6a 00                	push   $0x0
  800196:	ff 75 10             	pushl  0x10(%ebp)
  800199:	83 ec 08             	sub    $0x8,%esp
  80019c:	52                   	push   %edx
  80019d:	50                   	push   %eax
  80019e:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001a1:	ff 75 e0             	pushl  -0x20(%ebp)
  8001a4:	e8 87 0c 00 00       	call   800e30 <__udivdi3>
  8001a9:	83 c4 18             	add    $0x18,%esp
  8001ac:	52                   	push   %edx
  8001ad:	50                   	push   %eax
  8001ae:	89 f2                	mov    %esi,%edx
  8001b0:	89 f8                	mov    %edi,%eax
  8001b2:	e8 98 ff ff ff       	call   80014f <printnum>
		while (--width > 0)
			putch(padc, putdat);
	}
	}
	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001b7:	83 c4 18             	add    $0x18,%esp
  8001ba:	56                   	push   %esi
  8001bb:	8b 45 10             	mov    0x10(%ebp),%eax
  8001be:	ba 00 00 00 00       	mov    $0x0,%edx
  8001c3:	83 ec 04             	sub    $0x4,%esp
  8001c6:	52                   	push   %edx
  8001c7:	50                   	push   %eax
  8001c8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001cb:	ff 75 e0             	pushl  -0x20(%ebp)
  8001ce:	e8 8d 0d 00 00       	call   800f60 <__umoddi3>
  8001d3:	83 c4 14             	add    $0x14,%esp
  8001d6:	0f be 80 cc 10 80 00 	movsbl 0x8010cc(%eax),%eax
  8001dd:	50                   	push   %eax
  8001de:	ff d7                	call   *%edi
	
	if(padc=='-'&&width>0)
  8001e0:	83 c4 10             	add    $0x10,%esp
  8001e3:	83 7d 18 2d          	cmpl   $0x2d,0x18(%ebp)
  8001e7:	0f 85 fa 00 00 00    	jne    8002e7 <printnum+0x198>
  8001ed:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
  8001f1:	0f 8f 9b 00 00 00    	jg     800292 <printnum+0x143>
  8001f7:	e9 eb 00 00 00       	jmp    8002e7 <printnum+0x198>
	}
	else
	{
	
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001fc:	8b 45 10             	mov    0x10(%ebp),%eax
  8001ff:	ba 00 00 00 00       	mov    $0x0,%edx
  800204:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800207:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80020a:	83 fb 00             	cmp    $0x0,%ebx
  80020d:	77 14                	ja     800223 <printnum+0xd4>
  80020f:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800212:	73 0f                	jae    800223 <printnum+0xd4>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800214:	8b 45 14             	mov    0x14(%ebp),%eax
  800217:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80021a:	85 db                	test   %ebx,%ebx
  80021c:	7f 61                	jg     80027f <printnum+0x130>
  80021e:	e9 98 00 00 00       	jmp    8002bb <printnum+0x16c>
	else
	{
	
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800223:	83 ec 0c             	sub    $0xc,%esp
  800226:	ff 75 18             	pushl  0x18(%ebp)
  800229:	8b 4d 14             	mov    0x14(%ebp),%ecx
  80022c:	8d 59 ff             	lea    -0x1(%ecx),%ebx
  80022f:	53                   	push   %ebx
  800230:	ff 75 10             	pushl  0x10(%ebp)
  800233:	83 ec 08             	sub    $0x8,%esp
  800236:	52                   	push   %edx
  800237:	50                   	push   %eax
  800238:	ff 75 e4             	pushl  -0x1c(%ebp)
  80023b:	ff 75 e0             	pushl  -0x20(%ebp)
  80023e:	e8 ed 0b 00 00       	call   800e30 <__udivdi3>
  800243:	83 c4 18             	add    $0x18,%esp
  800246:	52                   	push   %edx
  800247:	50                   	push   %eax
  800248:	89 f2                	mov    %esi,%edx
  80024a:	89 f8                	mov    %edi,%eax
  80024c:	e8 fe fe ff ff       	call   80014f <printnum>
		while (--width > 0)
			putch(padc, putdat);
	}
	}
	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800251:	83 c4 18             	add    $0x18,%esp
  800254:	56                   	push   %esi
  800255:	8b 45 10             	mov    0x10(%ebp),%eax
  800258:	ba 00 00 00 00       	mov    $0x0,%edx
  80025d:	83 ec 04             	sub    $0x4,%esp
  800260:	52                   	push   %edx
  800261:	50                   	push   %eax
  800262:	ff 75 e4             	pushl  -0x1c(%ebp)
  800265:	ff 75 e0             	pushl  -0x20(%ebp)
  800268:	e8 f3 0c 00 00       	call   800f60 <__umoddi3>
  80026d:	83 c4 14             	add    $0x14,%esp
  800270:	0f be 80 cc 10 80 00 	movsbl 0x8010cc(%eax),%eax
  800277:	50                   	push   %eax
  800278:	ff d7                	call   *%edi
  80027a:	83 c4 10             	add    $0x10,%esp
  80027d:	eb 68                	jmp    8002e7 <printnum+0x198>
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80027f:	83 ec 08             	sub    $0x8,%esp
  800282:	56                   	push   %esi
  800283:	ff 75 18             	pushl  0x18(%ebp)
  800286:	ff d7                	call   *%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800288:	83 c4 10             	add    $0x10,%esp
  80028b:	83 eb 01             	sub    $0x1,%ebx
  80028e:	75 ef                	jne    80027f <printnum+0x130>
  800290:	eb 29                	jmp    8002bb <printnum+0x16c>
	putch("0123456789abcdef"[num % base], putdat);
	
	if(padc=='-'&&width>0)
	{
		length=*(int *)putdat-length;
		for(int i=0;i<width-length;++i)
  800292:	8b 45 14             	mov    0x14(%ebp),%eax
  800295:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800298:	2b 06                	sub    (%esi),%eax
  80029a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80029d:	85 c0                	test   %eax,%eax
  80029f:	7e 46                	jle    8002e7 <printnum+0x198>
  8002a1:	bb 00 00 00 00       	mov    $0x0,%ebx
			putch(' ',putdat);
  8002a6:	83 ec 08             	sub    $0x8,%esp
  8002a9:	56                   	push   %esi
  8002aa:	6a 20                	push   $0x20
  8002ac:	ff d7                	call   *%edi
	putch("0123456789abcdef"[num % base], putdat);
	
	if(padc=='-'&&width>0)
	{
		length=*(int *)putdat-length;
		for(int i=0;i<width-length;++i)
  8002ae:	83 c3 01             	add    $0x1,%ebx
  8002b1:	83 c4 10             	add    $0x10,%esp
  8002b4:	3b 5d e0             	cmp    -0x20(%ebp),%ebx
  8002b7:	75 ed                	jne    8002a6 <printnum+0x157>
  8002b9:	eb 2c                	jmp    8002e7 <printnum+0x198>
		while (--width > 0)
			putch(padc, putdat);
	}
	}
	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002bb:	83 ec 08             	sub    $0x8,%esp
  8002be:	56                   	push   %esi
  8002bf:	8b 45 10             	mov    0x10(%ebp),%eax
  8002c2:	ba 00 00 00 00       	mov    $0x0,%edx
  8002c7:	83 ec 04             	sub    $0x4,%esp
  8002ca:	52                   	push   %edx
  8002cb:	50                   	push   %eax
  8002cc:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002cf:	ff 75 e0             	pushl  -0x20(%ebp)
  8002d2:	e8 89 0c 00 00       	call   800f60 <__umoddi3>
  8002d7:	83 c4 14             	add    $0x14,%esp
  8002da:	0f be 80 cc 10 80 00 	movsbl 0x8010cc(%eax),%eax
  8002e1:	50                   	push   %eax
  8002e2:	ff d7                	call   *%edi
  8002e4:	83 c4 10             	add    $0x10,%esp
	{
		length=*(int *)putdat-length;
		for(int i=0;i<width-length;++i)
			putch(' ',putdat);
	}
}
  8002e7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002ea:	5b                   	pop    %ebx
  8002eb:	5e                   	pop    %esi
  8002ec:	5f                   	pop    %edi
  8002ed:	5d                   	pop    %ebp
  8002ee:	c3                   	ret    

008002ef <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002ef:	55                   	push   %ebp
  8002f0:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002f2:	83 fa 01             	cmp    $0x1,%edx
  8002f5:	7e 0e                	jle    800305 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002f7:	8b 10                	mov    (%eax),%edx
  8002f9:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002fc:	89 08                	mov    %ecx,(%eax)
  8002fe:	8b 02                	mov    (%edx),%eax
  800300:	8b 52 04             	mov    0x4(%edx),%edx
  800303:	eb 22                	jmp    800327 <getuint+0x38>
	else if (lflag)
  800305:	85 d2                	test   %edx,%edx
  800307:	74 10                	je     800319 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800309:	8b 10                	mov    (%eax),%edx
  80030b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80030e:	89 08                	mov    %ecx,(%eax)
  800310:	8b 02                	mov    (%edx),%eax
  800312:	ba 00 00 00 00       	mov    $0x0,%edx
  800317:	eb 0e                	jmp    800327 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800319:	8b 10                	mov    (%eax),%edx
  80031b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80031e:	89 08                	mov    %ecx,(%eax)
  800320:	8b 02                	mov    (%edx),%eax
  800322:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800327:	5d                   	pop    %ebp
  800328:	c3                   	ret    

00800329 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800329:	55                   	push   %ebp
  80032a:	89 e5                	mov    %esp,%ebp
  80032c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80032f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800333:	8b 10                	mov    (%eax),%edx
  800335:	3b 50 04             	cmp    0x4(%eax),%edx
  800338:	73 0a                	jae    800344 <sprintputch+0x1b>
		*b->buf++ = ch;
  80033a:	8d 4a 01             	lea    0x1(%edx),%ecx
  80033d:	89 08                	mov    %ecx,(%eax)
  80033f:	8b 45 08             	mov    0x8(%ebp),%eax
  800342:	88 02                	mov    %al,(%edx)
}
  800344:	5d                   	pop    %ebp
  800345:	c3                   	ret    

00800346 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800346:	55                   	push   %ebp
  800347:	89 e5                	mov    %esp,%ebp
  800349:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80034c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80034f:	50                   	push   %eax
  800350:	ff 75 10             	pushl  0x10(%ebp)
  800353:	ff 75 0c             	pushl  0xc(%ebp)
  800356:	ff 75 08             	pushl  0x8(%ebp)
  800359:	e8 05 00 00 00       	call   800363 <vprintfmt>
	va_end(ap);
}
  80035e:	83 c4 10             	add    $0x10,%esp
  800361:	c9                   	leave  
  800362:	c3                   	ret    

00800363 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800363:	55                   	push   %ebp
  800364:	89 e5                	mov    %esp,%ebp
  800366:	57                   	push   %edi
  800367:	56                   	push   %esi
  800368:	53                   	push   %ebx
  800369:	83 ec 2c             	sub    $0x2c,%esp
  80036c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80036f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800372:	eb 03                	jmp    800377 <vprintfmt+0x14>
			break;
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
			for (fmt--; fmt[-1] != '%'; fmt--)
  800374:	89 75 10             	mov    %esi,0x10(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800377:	8b 45 10             	mov    0x10(%ebp),%eax
  80037a:	8d 70 01             	lea    0x1(%eax),%esi
  80037d:	0f b6 00             	movzbl (%eax),%eax
  800380:	83 f8 25             	cmp    $0x25,%eax
  800383:	74 27                	je     8003ac <vprintfmt+0x49>
			if (ch == '\0')
  800385:	85 c0                	test   %eax,%eax
  800387:	75 0d                	jne    800396 <vprintfmt+0x33>
  800389:	e9 8b 04 00 00       	jmp    800819 <vprintfmt+0x4b6>
  80038e:	85 c0                	test   %eax,%eax
  800390:	0f 84 83 04 00 00    	je     800819 <vprintfmt+0x4b6>
				return;
			putch(ch, putdat);
  800396:	83 ec 08             	sub    $0x8,%esp
  800399:	53                   	push   %ebx
  80039a:	50                   	push   %eax
  80039b:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80039d:	83 c6 01             	add    $0x1,%esi
  8003a0:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  8003a4:	83 c4 10             	add    $0x10,%esp
  8003a7:	83 f8 25             	cmp    $0x25,%eax
  8003aa:	75 e2                	jne    80038e <vprintfmt+0x2b>
			padc = '-';
			goto reswitch;
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003ac:	c6 45 e3 20          	movb   $0x20,-0x1d(%ebp)
  8003b0:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8003b7:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003be:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8003c5:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  8003cc:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003d1:	eb 07                	jmp    8003da <vprintfmt+0x77>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d3:	8b 75 10             	mov    0x10(%ebp),%esi

		// flag to show the sign
		case '+':
			padc='+';
  8003d6:	c6 45 e3 2b          	movb   $0x2b,-0x1d(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003da:	8d 46 01             	lea    0x1(%esi),%eax
  8003dd:	89 45 10             	mov    %eax,0x10(%ebp)
  8003e0:	0f b6 06             	movzbl (%esi),%eax
  8003e3:	0f b6 d0             	movzbl %al,%edx
  8003e6:	83 e8 23             	sub    $0x23,%eax
  8003e9:	3c 55                	cmp    $0x55,%al
  8003eb:	0f 87 e9 03 00 00    	ja     8007da <vprintfmt+0x477>
  8003f1:	0f b6 c0             	movzbl %al,%eax
  8003f4:	ff 24 85 d8 11 80 00 	jmp    *0x8011d8(,%eax,4)
  8003fb:	8b 75 10             	mov    0x10(%ebp),%esi
			padc='+';
			goto reswitch;
		
		// flag to pad on the right
		case '-':
			padc = '-';
  8003fe:	c6 45 e3 2d          	movb   $0x2d,-0x1d(%ebp)
  800402:	eb d6                	jmp    8003da <vprintfmt+0x77>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800404:	8d 42 d0             	lea    -0x30(%edx),%eax
  800407:	89 45 d0             	mov    %eax,-0x30(%ebp)
				ch = *fmt;
  80040a:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  80040e:	8d 50 d0             	lea    -0x30(%eax),%edx
  800411:	83 fa 09             	cmp    $0x9,%edx
  800414:	77 66                	ja     80047c <vprintfmt+0x119>
  800416:	8b 75 10             	mov    0x10(%ebp),%esi
  800419:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80041c:	89 7d 08             	mov    %edi,0x8(%ebp)
  80041f:	eb 09                	jmp    80042a <vprintfmt+0xc7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800421:	8b 75 10             	mov    0x10(%ebp),%esi
			padc = '-';
			goto reswitch;
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800424:	c6 45 e3 30          	movb   $0x30,-0x1d(%ebp)
			goto reswitch;
  800428:	eb b0                	jmp    8003da <vprintfmt+0x77>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80042a:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  80042d:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800430:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  800434:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800437:	8d 78 d0             	lea    -0x30(%eax),%edi
  80043a:	83 ff 09             	cmp    $0x9,%edi
  80043d:	76 eb                	jbe    80042a <vprintfmt+0xc7>
  80043f:	89 55 d0             	mov    %edx,-0x30(%ebp)
  800442:	8b 7d 08             	mov    0x8(%ebp),%edi
  800445:	eb 38                	jmp    80047f <vprintfmt+0x11c>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800447:	8b 45 14             	mov    0x14(%ebp),%eax
  80044a:	8d 50 04             	lea    0x4(%eax),%edx
  80044d:	89 55 14             	mov    %edx,0x14(%ebp)
  800450:	8b 00                	mov    (%eax),%eax
  800452:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800455:	8b 75 10             	mov    0x10(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800458:	eb 25                	jmp    80047f <vprintfmt+0x11c>
  80045a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80045d:	85 c0                	test   %eax,%eax
  80045f:	0f 48 c1             	cmovs  %ecx,%eax
  800462:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800465:	8b 75 10             	mov    0x10(%ebp),%esi
  800468:	e9 6d ff ff ff       	jmp    8003da <vprintfmt+0x77>
  80046d:	8b 75 10             	mov    0x10(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800470:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800477:	e9 5e ff ff ff       	jmp    8003da <vprintfmt+0x77>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80047c:	8b 75 10             	mov    0x10(%ebp),%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80047f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800483:	0f 89 51 ff ff ff    	jns    8003da <vprintfmt+0x77>
				width = precision, precision = -1;
  800489:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80048c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80048f:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800496:	e9 3f ff ff ff       	jmp    8003da <vprintfmt+0x77>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80049b:	83 45 cc 01          	addl   $0x1,-0x34(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049f:	8b 75 10             	mov    0x10(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004a2:	e9 33 ff ff ff       	jmp    8003da <vprintfmt+0x77>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004a7:	8b 45 14             	mov    0x14(%ebp),%eax
  8004aa:	8d 50 04             	lea    0x4(%eax),%edx
  8004ad:	89 55 14             	mov    %edx,0x14(%ebp)
  8004b0:	83 ec 08             	sub    $0x8,%esp
  8004b3:	53                   	push   %ebx
  8004b4:	ff 30                	pushl  (%eax)
  8004b6:	ff d7                	call   *%edi
			break;
  8004b8:	83 c4 10             	add    $0x10,%esp
  8004bb:	e9 b7 fe ff ff       	jmp    800377 <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004c0:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c3:	8d 50 04             	lea    0x4(%eax),%edx
  8004c6:	89 55 14             	mov    %edx,0x14(%ebp)
  8004c9:	8b 00                	mov    (%eax),%eax
  8004cb:	99                   	cltd   
  8004cc:	31 d0                	xor    %edx,%eax
  8004ce:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004d0:	83 f8 06             	cmp    $0x6,%eax
  8004d3:	7f 0b                	jg     8004e0 <vprintfmt+0x17d>
  8004d5:	8b 14 85 30 13 80 00 	mov    0x801330(,%eax,4),%edx
  8004dc:	85 d2                	test   %edx,%edx
  8004de:	75 15                	jne    8004f5 <vprintfmt+0x192>
				printfmt(putch, putdat, "error %d", err);
  8004e0:	50                   	push   %eax
  8004e1:	68 e4 10 80 00       	push   $0x8010e4
  8004e6:	53                   	push   %ebx
  8004e7:	57                   	push   %edi
  8004e8:	e8 59 fe ff ff       	call   800346 <printfmt>
  8004ed:	83 c4 10             	add    $0x10,%esp
  8004f0:	e9 82 fe ff ff       	jmp    800377 <vprintfmt+0x14>
			else
				printfmt(putch, putdat, "%s", p);
  8004f5:	52                   	push   %edx
  8004f6:	68 ed 10 80 00       	push   $0x8010ed
  8004fb:	53                   	push   %ebx
  8004fc:	57                   	push   %edi
  8004fd:	e8 44 fe ff ff       	call   800346 <printfmt>
  800502:	83 c4 10             	add    $0x10,%esp
  800505:	e9 6d fe ff ff       	jmp    800377 <vprintfmt+0x14>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80050a:	8b 45 14             	mov    0x14(%ebp),%eax
  80050d:	8d 50 04             	lea    0x4(%eax),%edx
  800510:	89 55 14             	mov    %edx,0x14(%ebp)
  800513:	8b 00                	mov    (%eax),%eax
				p = "(null)";
  800515:	85 c0                	test   %eax,%eax
  800517:	b9 dd 10 80 00       	mov    $0x8010dd,%ecx
  80051c:	0f 45 c8             	cmovne %eax,%ecx
  80051f:	89 4d cc             	mov    %ecx,-0x34(%ebp)
			if (width > 0 && padc != '-')
  800522:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800526:	7e 06                	jle    80052e <vprintfmt+0x1cb>
  800528:	80 7d e3 2d          	cmpb   $0x2d,-0x1d(%ebp)
  80052c:	75 19                	jne    800547 <vprintfmt+0x1e4>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80052e:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800531:	8d 70 01             	lea    0x1(%eax),%esi
  800534:	0f b6 00             	movzbl (%eax),%eax
  800537:	0f be d0             	movsbl %al,%edx
  80053a:	85 d2                	test   %edx,%edx
  80053c:	0f 85 9f 00 00 00    	jne    8005e1 <vprintfmt+0x27e>
  800542:	e9 8c 00 00 00       	jmp    8005d3 <vprintfmt+0x270>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800547:	83 ec 08             	sub    $0x8,%esp
  80054a:	ff 75 d0             	pushl  -0x30(%ebp)
  80054d:	ff 75 cc             	pushl  -0x34(%ebp)
  800550:	e8 56 03 00 00       	call   8008ab <strnlen>
  800555:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  800558:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80055b:	83 c4 10             	add    $0x10,%esp
  80055e:	85 c9                	test   %ecx,%ecx
  800560:	0f 8e 9a 02 00 00    	jle    800800 <vprintfmt+0x49d>
					putch(padc, putdat);
  800566:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  80056a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80056d:	89 cb                	mov    %ecx,%ebx
  80056f:	83 ec 08             	sub    $0x8,%esp
  800572:	ff 75 0c             	pushl  0xc(%ebp)
  800575:	56                   	push   %esi
  800576:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800578:	83 c4 10             	add    $0x10,%esp
  80057b:	83 eb 01             	sub    $0x1,%ebx
  80057e:	75 ef                	jne    80056f <vprintfmt+0x20c>
  800580:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800583:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800586:	e9 75 02 00 00       	jmp    800800 <vprintfmt+0x49d>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80058b:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80058f:	74 1b                	je     8005ac <vprintfmt+0x249>
  800591:	0f be c0             	movsbl %al,%eax
  800594:	83 e8 20             	sub    $0x20,%eax
  800597:	83 f8 5e             	cmp    $0x5e,%eax
  80059a:	76 10                	jbe    8005ac <vprintfmt+0x249>
					putch('?', putdat);
  80059c:	83 ec 08             	sub    $0x8,%esp
  80059f:	ff 75 0c             	pushl  0xc(%ebp)
  8005a2:	6a 3f                	push   $0x3f
  8005a4:	ff 55 08             	call   *0x8(%ebp)
  8005a7:	83 c4 10             	add    $0x10,%esp
  8005aa:	eb 0d                	jmp    8005b9 <vprintfmt+0x256>
				else
					putch(ch, putdat);
  8005ac:	83 ec 08             	sub    $0x8,%esp
  8005af:	ff 75 0c             	pushl  0xc(%ebp)
  8005b2:	52                   	push   %edx
  8005b3:	ff 55 08             	call   *0x8(%ebp)
  8005b6:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005b9:	83 ef 01             	sub    $0x1,%edi
  8005bc:	83 c6 01             	add    $0x1,%esi
  8005bf:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  8005c3:	0f be d0             	movsbl %al,%edx
  8005c6:	85 d2                	test   %edx,%edx
  8005c8:	75 31                	jne    8005fb <vprintfmt+0x298>
  8005ca:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8005cd:	8b 7d 08             	mov    0x8(%ebp),%edi
  8005d0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005d3:	8b 75 e4             	mov    -0x1c(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005d6:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005da:	7f 33                	jg     80060f <vprintfmt+0x2ac>
  8005dc:	e9 96 fd ff ff       	jmp    800377 <vprintfmt+0x14>
  8005e1:	89 7d 08             	mov    %edi,0x8(%ebp)
  8005e4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005e7:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005ea:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8005ed:	eb 0c                	jmp    8005fb <vprintfmt+0x298>
  8005ef:	89 7d 08             	mov    %edi,0x8(%ebp)
  8005f2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005f5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005f8:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005fb:	85 db                	test   %ebx,%ebx
  8005fd:	78 8c                	js     80058b <vprintfmt+0x228>
  8005ff:	83 eb 01             	sub    $0x1,%ebx
  800602:	79 87                	jns    80058b <vprintfmt+0x228>
  800604:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800607:	8b 7d 08             	mov    0x8(%ebp),%edi
  80060a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80060d:	eb c4                	jmp    8005d3 <vprintfmt+0x270>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80060f:	83 ec 08             	sub    $0x8,%esp
  800612:	53                   	push   %ebx
  800613:	6a 20                	push   $0x20
  800615:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800617:	83 c4 10             	add    $0x10,%esp
  80061a:	83 ee 01             	sub    $0x1,%esi
  80061d:	75 f0                	jne    80060f <vprintfmt+0x2ac>
  80061f:	e9 53 fd ff ff       	jmp    800377 <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800624:	83 7d cc 01          	cmpl   $0x1,-0x34(%ebp)
  800628:	7e 16                	jle    800640 <vprintfmt+0x2dd>
		return va_arg(*ap, long long);
  80062a:	8b 45 14             	mov    0x14(%ebp),%eax
  80062d:	8d 50 08             	lea    0x8(%eax),%edx
  800630:	89 55 14             	mov    %edx,0x14(%ebp)
  800633:	8b 50 04             	mov    0x4(%eax),%edx
  800636:	8b 00                	mov    (%eax),%eax
  800638:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80063b:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80063e:	eb 34                	jmp    800674 <vprintfmt+0x311>
	else if (lflag)
  800640:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800644:	74 18                	je     80065e <vprintfmt+0x2fb>
		return va_arg(*ap, long);
  800646:	8b 45 14             	mov    0x14(%ebp),%eax
  800649:	8d 50 04             	lea    0x4(%eax),%edx
  80064c:	89 55 14             	mov    %edx,0x14(%ebp)
  80064f:	8b 30                	mov    (%eax),%esi
  800651:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800654:	89 f0                	mov    %esi,%eax
  800656:	c1 f8 1f             	sar    $0x1f,%eax
  800659:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80065c:	eb 16                	jmp    800674 <vprintfmt+0x311>
	else
		return va_arg(*ap, int);
  80065e:	8b 45 14             	mov    0x14(%ebp),%eax
  800661:	8d 50 04             	lea    0x4(%eax),%edx
  800664:	89 55 14             	mov    %edx,0x14(%ebp)
  800667:	8b 30                	mov    (%eax),%esi
  800669:	89 75 d0             	mov    %esi,-0x30(%ebp)
  80066c:	89 f0                	mov    %esi,%eax
  80066e:	c1 f8 1f             	sar    $0x1f,%eax
  800671:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800674:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800677:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80067a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80067d:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  800680:	85 d2                	test   %edx,%edx
  800682:	79 28                	jns    8006ac <vprintfmt+0x349>
				putch('-', putdat);
  800684:	83 ec 08             	sub    $0x8,%esp
  800687:	53                   	push   %ebx
  800688:	6a 2d                	push   $0x2d
  80068a:	ff d7                	call   *%edi
				num = -(long long) num;
  80068c:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80068f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800692:	f7 d8                	neg    %eax
  800694:	83 d2 00             	adc    $0x0,%edx
  800697:	f7 da                	neg    %edx
  800699:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80069c:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80069f:	83 c4 10             	add    $0x10,%esp
			else
			{
				if(padc=='+')
					putch('+', putdat);
			}
			base = 10;
  8006a2:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006a7:	e9 a5 00 00 00       	jmp    800751 <vprintfmt+0x3ee>
  8006ac:	b8 0a 00 00 00       	mov    $0xa,%eax
				putch('-', putdat);
				num = -(long long) num;
			}
			else
			{
				if(padc=='+')
  8006b1:	80 7d e3 2b          	cmpb   $0x2b,-0x1d(%ebp)
  8006b5:	0f 85 96 00 00 00    	jne    800751 <vprintfmt+0x3ee>
					putch('+', putdat);
  8006bb:	83 ec 08             	sub    $0x8,%esp
  8006be:	53                   	push   %ebx
  8006bf:	6a 2b                	push   $0x2b
  8006c1:	ff d7                	call   *%edi
  8006c3:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8006c6:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006cb:	e9 81 00 00 00       	jmp    800751 <vprintfmt+0x3ee>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006d0:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8006d3:	8d 45 14             	lea    0x14(%ebp),%eax
  8006d6:	e8 14 fc ff ff       	call   8002ef <getuint>
  8006db:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006de:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  8006e1:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8006e6:	eb 69                	jmp    800751 <vprintfmt+0x3ee>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			putch('0', putdat);
  8006e8:	83 ec 08             	sub    $0x8,%esp
  8006eb:	53                   	push   %ebx
  8006ec:	6a 30                	push   $0x30
  8006ee:	ff d7                	call   *%edi
			num = getuint(&ap, lflag);
  8006f0:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8006f3:	8d 45 14             	lea    0x14(%ebp),%eax
  8006f6:	e8 f4 fb ff ff       	call   8002ef <getuint>
  8006fb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006fe:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
			goto number;
  800701:	83 c4 10             	add    $0x10,%esp
		case 'o':
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
  800704:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800709:	eb 46                	jmp    800751 <vprintfmt+0x3ee>

		// pointer
		case 'p':
			putch('0', putdat);
  80070b:	83 ec 08             	sub    $0x8,%esp
  80070e:	53                   	push   %ebx
  80070f:	6a 30                	push   $0x30
  800711:	ff d7                	call   *%edi
			putch('x', putdat);
  800713:	83 c4 08             	add    $0x8,%esp
  800716:	53                   	push   %ebx
  800717:	6a 78                	push   $0x78
  800719:	ff d7                	call   *%edi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80071b:	8b 45 14             	mov    0x14(%ebp),%eax
  80071e:	8d 50 04             	lea    0x4(%eax),%edx
  800721:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800724:	8b 00                	mov    (%eax),%eax
  800726:	ba 00 00 00 00       	mov    $0x0,%edx
  80072b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80072e:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800731:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800734:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800739:	eb 16                	jmp    800751 <vprintfmt+0x3ee>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80073b:	8b 55 cc             	mov    -0x34(%ebp),%edx
  80073e:	8d 45 14             	lea    0x14(%ebp),%eax
  800741:	e8 a9 fb ff ff       	call   8002ef <getuint>
  800746:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800749:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  80074c:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800751:	83 ec 0c             	sub    $0xc,%esp
  800754:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  800758:	56                   	push   %esi
  800759:	ff 75 e4             	pushl  -0x1c(%ebp)
  80075c:	50                   	push   %eax
  80075d:	ff 75 dc             	pushl  -0x24(%ebp)
  800760:	ff 75 d8             	pushl  -0x28(%ebp)
  800763:	89 da                	mov    %ebx,%edx
  800765:	89 f8                	mov    %edi,%eax
  800767:	e8 e3 f9 ff ff       	call   80014f <printnum>
			break;
  80076c:	83 c4 20             	add    $0x20,%esp
  80076f:	e9 03 fc ff ff       	jmp    800377 <vprintfmt+0x14>

            const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
            const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

            // Your code here
			num=(unsigned long long)(uintptr_t)va_arg(ap, void *);
  800774:	8b 45 14             	mov    0x14(%ebp),%eax
  800777:	8d 50 04             	lea    0x4(%eax),%edx
  80077a:	89 55 14             	mov    %edx,0x14(%ebp)
  80077d:	8b 00                	mov    (%eax),%eax
			if(!num)
  80077f:	85 c0                	test   %eax,%eax
  800781:	75 1c                	jne    80079f <vprintfmt+0x43c>
				*(int *)putdat+=cprintf("%s",null_error);
  800783:	83 ec 08             	sub    $0x8,%esp
  800786:	68 5c 11 80 00       	push   $0x80115c
  80078b:	68 ed 10 80 00       	push   $0x8010ed
  800790:	e8 a6 f9 ff ff       	call   80013b <cprintf>
  800795:	01 03                	add    %eax,(%ebx)
  800797:	83 c4 10             	add    $0x10,%esp
  80079a:	e9 d8 fb ff ff       	jmp    800377 <vprintfmt+0x14>
			else
			{
				*(char *)(int)num=*(int *)putdat;
  80079f:	8b 13                	mov    (%ebx),%edx
  8007a1:	88 10                	mov    %dl,(%eax)
				if((*(int *)putdat)>128)
  8007a3:	81 3b 80 00 00 00    	cmpl   $0x80,(%ebx)
  8007a9:	0f 8e c8 fb ff ff    	jle    800377 <vprintfmt+0x14>
					*(int *)putdat+=cprintf("%s",overflow_error);
  8007af:	83 ec 08             	sub    $0x8,%esp
  8007b2:	68 94 11 80 00       	push   $0x801194
  8007b7:	68 ed 10 80 00       	push   $0x8010ed
  8007bc:	e8 7a f9 ff ff       	call   80013b <cprintf>
  8007c1:	01 03                	add    %eax,(%ebx)
  8007c3:	83 c4 10             	add    $0x10,%esp
  8007c6:	e9 ac fb ff ff       	jmp    800377 <vprintfmt+0x14>
            break;
        }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007cb:	83 ec 08             	sub    $0x8,%esp
  8007ce:	53                   	push   %ebx
  8007cf:	52                   	push   %edx
  8007d0:	ff d7                	call   *%edi
			break;
  8007d2:	83 c4 10             	add    $0x10,%esp
  8007d5:	e9 9d fb ff ff       	jmp    800377 <vprintfmt+0x14>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007da:	83 ec 08             	sub    $0x8,%esp
  8007dd:	53                   	push   %ebx
  8007de:	6a 25                	push   $0x25
  8007e0:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007e2:	83 c4 10             	add    $0x10,%esp
  8007e5:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8007e9:	0f 84 85 fb ff ff    	je     800374 <vprintfmt+0x11>
  8007ef:	83 ee 01             	sub    $0x1,%esi
  8007f2:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8007f6:	75 f7                	jne    8007ef <vprintfmt+0x48c>
  8007f8:	89 75 10             	mov    %esi,0x10(%ebp)
  8007fb:	e9 77 fb ff ff       	jmp    800377 <vprintfmt+0x14>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800800:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800803:	8d 70 01             	lea    0x1(%eax),%esi
  800806:	0f b6 00             	movzbl (%eax),%eax
  800809:	0f be d0             	movsbl %al,%edx
  80080c:	85 d2                	test   %edx,%edx
  80080e:	0f 85 db fd ff ff    	jne    8005ef <vprintfmt+0x28c>
  800814:	e9 5e fb ff ff       	jmp    800377 <vprintfmt+0x14>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800819:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80081c:	5b                   	pop    %ebx
  80081d:	5e                   	pop    %esi
  80081e:	5f                   	pop    %edi
  80081f:	5d                   	pop    %ebp
  800820:	c3                   	ret    

00800821 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800821:	55                   	push   %ebp
  800822:	89 e5                	mov    %esp,%ebp
  800824:	83 ec 18             	sub    $0x18,%esp
  800827:	8b 45 08             	mov    0x8(%ebp),%eax
  80082a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80082d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800830:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800834:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800837:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80083e:	85 c0                	test   %eax,%eax
  800840:	74 26                	je     800868 <vsnprintf+0x47>
  800842:	85 d2                	test   %edx,%edx
  800844:	7e 22                	jle    800868 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800846:	ff 75 14             	pushl  0x14(%ebp)
  800849:	ff 75 10             	pushl  0x10(%ebp)
  80084c:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80084f:	50                   	push   %eax
  800850:	68 29 03 80 00       	push   $0x800329
  800855:	e8 09 fb ff ff       	call   800363 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80085a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80085d:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800860:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800863:	83 c4 10             	add    $0x10,%esp
  800866:	eb 05                	jmp    80086d <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800868:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80086d:	c9                   	leave  
  80086e:	c3                   	ret    

0080086f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80086f:	55                   	push   %ebp
  800870:	89 e5                	mov    %esp,%ebp
  800872:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800875:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800878:	50                   	push   %eax
  800879:	ff 75 10             	pushl  0x10(%ebp)
  80087c:	ff 75 0c             	pushl  0xc(%ebp)
  80087f:	ff 75 08             	pushl  0x8(%ebp)
  800882:	e8 9a ff ff ff       	call   800821 <vsnprintf>
	va_end(ap);

	return rc;
}
  800887:	c9                   	leave  
  800888:	c3                   	ret    

00800889 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800889:	55                   	push   %ebp
  80088a:	89 e5                	mov    %esp,%ebp
  80088c:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80088f:	80 3a 00             	cmpb   $0x0,(%edx)
  800892:	74 10                	je     8008a4 <strlen+0x1b>
  800894:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800899:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80089c:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008a0:	75 f7                	jne    800899 <strlen+0x10>
  8008a2:	eb 05                	jmp    8008a9 <strlen+0x20>
  8008a4:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8008a9:	5d                   	pop    %ebp
  8008aa:	c3                   	ret    

008008ab <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008ab:	55                   	push   %ebp
  8008ac:	89 e5                	mov    %esp,%ebp
  8008ae:	53                   	push   %ebx
  8008af:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8008b2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008b5:	85 c9                	test   %ecx,%ecx
  8008b7:	74 1c                	je     8008d5 <strnlen+0x2a>
  8008b9:	80 3b 00             	cmpb   $0x0,(%ebx)
  8008bc:	74 1e                	je     8008dc <strnlen+0x31>
  8008be:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  8008c3:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008c5:	39 ca                	cmp    %ecx,%edx
  8008c7:	74 18                	je     8008e1 <strnlen+0x36>
  8008c9:	83 c2 01             	add    $0x1,%edx
  8008cc:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  8008d1:	75 f0                	jne    8008c3 <strnlen+0x18>
  8008d3:	eb 0c                	jmp    8008e1 <strnlen+0x36>
  8008d5:	b8 00 00 00 00       	mov    $0x0,%eax
  8008da:	eb 05                	jmp    8008e1 <strnlen+0x36>
  8008dc:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8008e1:	5b                   	pop    %ebx
  8008e2:	5d                   	pop    %ebp
  8008e3:	c3                   	ret    

008008e4 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008e4:	55                   	push   %ebp
  8008e5:	89 e5                	mov    %esp,%ebp
  8008e7:	53                   	push   %ebx
  8008e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008eb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008ee:	89 c2                	mov    %eax,%edx
  8008f0:	83 c2 01             	add    $0x1,%edx
  8008f3:	83 c1 01             	add    $0x1,%ecx
  8008f6:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8008fa:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008fd:	84 db                	test   %bl,%bl
  8008ff:	75 ef                	jne    8008f0 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800901:	5b                   	pop    %ebx
  800902:	5d                   	pop    %ebp
  800903:	c3                   	ret    

00800904 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800904:	55                   	push   %ebp
  800905:	89 e5                	mov    %esp,%ebp
  800907:	53                   	push   %ebx
  800908:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80090b:	53                   	push   %ebx
  80090c:	e8 78 ff ff ff       	call   800889 <strlen>
  800911:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800914:	ff 75 0c             	pushl  0xc(%ebp)
  800917:	01 d8                	add    %ebx,%eax
  800919:	50                   	push   %eax
  80091a:	e8 c5 ff ff ff       	call   8008e4 <strcpy>
	return dst;
}
  80091f:	89 d8                	mov    %ebx,%eax
  800921:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800924:	c9                   	leave  
  800925:	c3                   	ret    

00800926 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800926:	55                   	push   %ebp
  800927:	89 e5                	mov    %esp,%ebp
  800929:	56                   	push   %esi
  80092a:	53                   	push   %ebx
  80092b:	8b 75 08             	mov    0x8(%ebp),%esi
  80092e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800931:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800934:	85 db                	test   %ebx,%ebx
  800936:	74 17                	je     80094f <strncpy+0x29>
  800938:	01 f3                	add    %esi,%ebx
  80093a:	89 f1                	mov    %esi,%ecx
		*dst++ = *src;
  80093c:	83 c1 01             	add    $0x1,%ecx
  80093f:	0f b6 02             	movzbl (%edx),%eax
  800942:	88 41 ff             	mov    %al,-0x1(%ecx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800945:	80 3a 01             	cmpb   $0x1,(%edx)
  800948:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80094b:	39 cb                	cmp    %ecx,%ebx
  80094d:	75 ed                	jne    80093c <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80094f:	89 f0                	mov    %esi,%eax
  800951:	5b                   	pop    %ebx
  800952:	5e                   	pop    %esi
  800953:	5d                   	pop    %ebp
  800954:	c3                   	ret    

00800955 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800955:	55                   	push   %ebp
  800956:	89 e5                	mov    %esp,%ebp
  800958:	56                   	push   %esi
  800959:	53                   	push   %ebx
  80095a:	8b 75 08             	mov    0x8(%ebp),%esi
  80095d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800960:	8b 55 10             	mov    0x10(%ebp),%edx
  800963:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800965:	85 d2                	test   %edx,%edx
  800967:	74 35                	je     80099e <strlcpy+0x49>
		while (--size > 0 && *src != '\0')
  800969:	89 d0                	mov    %edx,%eax
  80096b:	83 e8 01             	sub    $0x1,%eax
  80096e:	74 25                	je     800995 <strlcpy+0x40>
  800970:	0f b6 0b             	movzbl (%ebx),%ecx
  800973:	84 c9                	test   %cl,%cl
  800975:	74 22                	je     800999 <strlcpy+0x44>
  800977:	8d 53 01             	lea    0x1(%ebx),%edx
  80097a:	01 c3                	add    %eax,%ebx
  80097c:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
  80097e:	83 c0 01             	add    $0x1,%eax
  800981:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800984:	39 da                	cmp    %ebx,%edx
  800986:	74 13                	je     80099b <strlcpy+0x46>
  800988:	83 c2 01             	add    $0x1,%edx
  80098b:	0f b6 4a ff          	movzbl -0x1(%edx),%ecx
  80098f:	84 c9                	test   %cl,%cl
  800991:	75 eb                	jne    80097e <strlcpy+0x29>
  800993:	eb 06                	jmp    80099b <strlcpy+0x46>
  800995:	89 f0                	mov    %esi,%eax
  800997:	eb 02                	jmp    80099b <strlcpy+0x46>
  800999:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  80099b:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80099e:	29 f0                	sub    %esi,%eax
}
  8009a0:	5b                   	pop    %ebx
  8009a1:	5e                   	pop    %esi
  8009a2:	5d                   	pop    %ebp
  8009a3:	c3                   	ret    

008009a4 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009a4:	55                   	push   %ebp
  8009a5:	89 e5                	mov    %esp,%ebp
  8009a7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009aa:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009ad:	0f b6 01             	movzbl (%ecx),%eax
  8009b0:	84 c0                	test   %al,%al
  8009b2:	74 15                	je     8009c9 <strcmp+0x25>
  8009b4:	3a 02                	cmp    (%edx),%al
  8009b6:	75 11                	jne    8009c9 <strcmp+0x25>
		p++, q++;
  8009b8:	83 c1 01             	add    $0x1,%ecx
  8009bb:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8009be:	0f b6 01             	movzbl (%ecx),%eax
  8009c1:	84 c0                	test   %al,%al
  8009c3:	74 04                	je     8009c9 <strcmp+0x25>
  8009c5:	3a 02                	cmp    (%edx),%al
  8009c7:	74 ef                	je     8009b8 <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009c9:	0f b6 c0             	movzbl %al,%eax
  8009cc:	0f b6 12             	movzbl (%edx),%edx
  8009cf:	29 d0                	sub    %edx,%eax
}
  8009d1:	5d                   	pop    %ebp
  8009d2:	c3                   	ret    

008009d3 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009d3:	55                   	push   %ebp
  8009d4:	89 e5                	mov    %esp,%ebp
  8009d6:	56                   	push   %esi
  8009d7:	53                   	push   %ebx
  8009d8:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8009db:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009de:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  8009e1:	85 f6                	test   %esi,%esi
  8009e3:	74 29                	je     800a0e <strncmp+0x3b>
  8009e5:	0f b6 03             	movzbl (%ebx),%eax
  8009e8:	84 c0                	test   %al,%al
  8009ea:	74 30                	je     800a1c <strncmp+0x49>
  8009ec:	3a 02                	cmp    (%edx),%al
  8009ee:	75 2c                	jne    800a1c <strncmp+0x49>
  8009f0:	8d 43 01             	lea    0x1(%ebx),%eax
  8009f3:	01 de                	add    %ebx,%esi
		n--, p++, q++;
  8009f5:	89 c3                	mov    %eax,%ebx
  8009f7:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009fa:	39 c6                	cmp    %eax,%esi
  8009fc:	74 17                	je     800a15 <strncmp+0x42>
  8009fe:	0f b6 08             	movzbl (%eax),%ecx
  800a01:	84 c9                	test   %cl,%cl
  800a03:	74 17                	je     800a1c <strncmp+0x49>
  800a05:	83 c0 01             	add    $0x1,%eax
  800a08:	3a 0a                	cmp    (%edx),%cl
  800a0a:	74 e9                	je     8009f5 <strncmp+0x22>
  800a0c:	eb 0e                	jmp    800a1c <strncmp+0x49>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a0e:	b8 00 00 00 00       	mov    $0x0,%eax
  800a13:	eb 0f                	jmp    800a24 <strncmp+0x51>
  800a15:	b8 00 00 00 00       	mov    $0x0,%eax
  800a1a:	eb 08                	jmp    800a24 <strncmp+0x51>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a1c:	0f b6 03             	movzbl (%ebx),%eax
  800a1f:	0f b6 12             	movzbl (%edx),%edx
  800a22:	29 d0                	sub    %edx,%eax
}
  800a24:	5b                   	pop    %ebx
  800a25:	5e                   	pop    %esi
  800a26:	5d                   	pop    %ebp
  800a27:	c3                   	ret    

00800a28 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a28:	55                   	push   %ebp
  800a29:	89 e5                	mov    %esp,%ebp
  800a2b:	53                   	push   %ebx
  800a2c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a2f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
  800a32:	0f b6 10             	movzbl (%eax),%edx
  800a35:	84 d2                	test   %dl,%dl
  800a37:	74 1d                	je     800a56 <strchr+0x2e>
  800a39:	89 d9                	mov    %ebx,%ecx
		if (*s == c)
  800a3b:	38 d3                	cmp    %dl,%bl
  800a3d:	75 06                	jne    800a45 <strchr+0x1d>
  800a3f:	eb 1a                	jmp    800a5b <strchr+0x33>
  800a41:	38 ca                	cmp    %cl,%dl
  800a43:	74 16                	je     800a5b <strchr+0x33>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a45:	83 c0 01             	add    $0x1,%eax
  800a48:	0f b6 10             	movzbl (%eax),%edx
  800a4b:	84 d2                	test   %dl,%dl
  800a4d:	75 f2                	jne    800a41 <strchr+0x19>
		if (*s == c)
			return (char *) s;
	return 0;
  800a4f:	b8 00 00 00 00       	mov    $0x0,%eax
  800a54:	eb 05                	jmp    800a5b <strchr+0x33>
  800a56:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a5b:	5b                   	pop    %ebx
  800a5c:	5d                   	pop    %ebp
  800a5d:	c3                   	ret    

00800a5e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a5e:	55                   	push   %ebp
  800a5f:	89 e5                	mov    %esp,%ebp
  800a61:	53                   	push   %ebx
  800a62:	8b 45 08             	mov    0x8(%ebp),%eax
  800a65:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  800a68:	0f b6 18             	movzbl (%eax),%ebx
		if (*s == c)
  800a6b:	38 d3                	cmp    %dl,%bl
  800a6d:	74 14                	je     800a83 <strfind+0x25>
  800a6f:	89 d1                	mov    %edx,%ecx
  800a71:	84 db                	test   %bl,%bl
  800a73:	74 0e                	je     800a83 <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a75:	83 c0 01             	add    $0x1,%eax
  800a78:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a7b:	38 ca                	cmp    %cl,%dl
  800a7d:	74 04                	je     800a83 <strfind+0x25>
  800a7f:	84 d2                	test   %dl,%dl
  800a81:	75 f2                	jne    800a75 <strfind+0x17>
			break;
	return (char *) s;
}
  800a83:	5b                   	pop    %ebx
  800a84:	5d                   	pop    %ebp
  800a85:	c3                   	ret    

00800a86 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a86:	55                   	push   %ebp
  800a87:	89 e5                	mov    %esp,%ebp
  800a89:	57                   	push   %edi
  800a8a:	56                   	push   %esi
  800a8b:	53                   	push   %ebx
  800a8c:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a8f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a92:	85 c9                	test   %ecx,%ecx
  800a94:	74 36                	je     800acc <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a96:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a9c:	75 28                	jne    800ac6 <memset+0x40>
  800a9e:	f6 c1 03             	test   $0x3,%cl
  800aa1:	75 23                	jne    800ac6 <memset+0x40>
		c &= 0xFF;
  800aa3:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800aa7:	89 d3                	mov    %edx,%ebx
  800aa9:	c1 e3 08             	shl    $0x8,%ebx
  800aac:	89 d6                	mov    %edx,%esi
  800aae:	c1 e6 18             	shl    $0x18,%esi
  800ab1:	89 d0                	mov    %edx,%eax
  800ab3:	c1 e0 10             	shl    $0x10,%eax
  800ab6:	09 f0                	or     %esi,%eax
  800ab8:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800aba:	89 d8                	mov    %ebx,%eax
  800abc:	09 d0                	or     %edx,%eax
  800abe:	c1 e9 02             	shr    $0x2,%ecx
  800ac1:	fc                   	cld    
  800ac2:	f3 ab                	rep stos %eax,%es:(%edi)
  800ac4:	eb 06                	jmp    800acc <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800ac6:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ac9:	fc                   	cld    
  800aca:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800acc:	89 f8                	mov    %edi,%eax
  800ace:	5b                   	pop    %ebx
  800acf:	5e                   	pop    %esi
  800ad0:	5f                   	pop    %edi
  800ad1:	5d                   	pop    %ebp
  800ad2:	c3                   	ret    

00800ad3 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ad3:	55                   	push   %ebp
  800ad4:	89 e5                	mov    %esp,%ebp
  800ad6:	57                   	push   %edi
  800ad7:	56                   	push   %esi
  800ad8:	8b 45 08             	mov    0x8(%ebp),%eax
  800adb:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ade:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ae1:	39 c6                	cmp    %eax,%esi
  800ae3:	73 35                	jae    800b1a <memmove+0x47>
  800ae5:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ae8:	39 d0                	cmp    %edx,%eax
  800aea:	73 2e                	jae    800b1a <memmove+0x47>
		s += n;
		d += n;
  800aec:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800aef:	89 d6                	mov    %edx,%esi
  800af1:	09 fe                	or     %edi,%esi
  800af3:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800af9:	75 13                	jne    800b0e <memmove+0x3b>
  800afb:	f6 c1 03             	test   $0x3,%cl
  800afe:	75 0e                	jne    800b0e <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800b00:	83 ef 04             	sub    $0x4,%edi
  800b03:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b06:	c1 e9 02             	shr    $0x2,%ecx
  800b09:	fd                   	std    
  800b0a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b0c:	eb 09                	jmp    800b17 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b0e:	83 ef 01             	sub    $0x1,%edi
  800b11:	8d 72 ff             	lea    -0x1(%edx),%esi
  800b14:	fd                   	std    
  800b15:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b17:	fc                   	cld    
  800b18:	eb 1d                	jmp    800b37 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b1a:	89 f2                	mov    %esi,%edx
  800b1c:	09 c2                	or     %eax,%edx
  800b1e:	f6 c2 03             	test   $0x3,%dl
  800b21:	75 0f                	jne    800b32 <memmove+0x5f>
  800b23:	f6 c1 03             	test   $0x3,%cl
  800b26:	75 0a                	jne    800b32 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800b28:	c1 e9 02             	shr    $0x2,%ecx
  800b2b:	89 c7                	mov    %eax,%edi
  800b2d:	fc                   	cld    
  800b2e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b30:	eb 05                	jmp    800b37 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b32:	89 c7                	mov    %eax,%edi
  800b34:	fc                   	cld    
  800b35:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b37:	5e                   	pop    %esi
  800b38:	5f                   	pop    %edi
  800b39:	5d                   	pop    %ebp
  800b3a:	c3                   	ret    

00800b3b <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800b3b:	55                   	push   %ebp
  800b3c:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b3e:	ff 75 10             	pushl  0x10(%ebp)
  800b41:	ff 75 0c             	pushl  0xc(%ebp)
  800b44:	ff 75 08             	pushl  0x8(%ebp)
  800b47:	e8 87 ff ff ff       	call   800ad3 <memmove>
}
  800b4c:	c9                   	leave  
  800b4d:	c3                   	ret    

00800b4e <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b4e:	55                   	push   %ebp
  800b4f:	89 e5                	mov    %esp,%ebp
  800b51:	57                   	push   %edi
  800b52:	56                   	push   %esi
  800b53:	53                   	push   %ebx
  800b54:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800b57:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b5a:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b5d:	85 c0                	test   %eax,%eax
  800b5f:	74 39                	je     800b9a <memcmp+0x4c>
  800b61:	8d 78 ff             	lea    -0x1(%eax),%edi
		if (*s1 != *s2)
  800b64:	0f b6 13             	movzbl (%ebx),%edx
  800b67:	0f b6 0e             	movzbl (%esi),%ecx
  800b6a:	38 ca                	cmp    %cl,%dl
  800b6c:	75 17                	jne    800b85 <memcmp+0x37>
  800b6e:	b8 00 00 00 00       	mov    $0x0,%eax
  800b73:	eb 1a                	jmp    800b8f <memcmp+0x41>
  800b75:	0f b6 54 03 01       	movzbl 0x1(%ebx,%eax,1),%edx
  800b7a:	83 c0 01             	add    $0x1,%eax
  800b7d:	0f b6 0c 06          	movzbl (%esi,%eax,1),%ecx
  800b81:	38 ca                	cmp    %cl,%dl
  800b83:	74 0a                	je     800b8f <memcmp+0x41>
			return (int) *s1 - (int) *s2;
  800b85:	0f b6 c2             	movzbl %dl,%eax
  800b88:	0f b6 c9             	movzbl %cl,%ecx
  800b8b:	29 c8                	sub    %ecx,%eax
  800b8d:	eb 10                	jmp    800b9f <memcmp+0x51>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b8f:	39 f8                	cmp    %edi,%eax
  800b91:	75 e2                	jne    800b75 <memcmp+0x27>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b93:	b8 00 00 00 00       	mov    $0x0,%eax
  800b98:	eb 05                	jmp    800b9f <memcmp+0x51>
  800b9a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b9f:	5b                   	pop    %ebx
  800ba0:	5e                   	pop    %esi
  800ba1:	5f                   	pop    %edi
  800ba2:	5d                   	pop    %ebp
  800ba3:	c3                   	ret    

00800ba4 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ba4:	55                   	push   %ebp
  800ba5:	89 e5                	mov    %esp,%ebp
  800ba7:	53                   	push   %ebx
  800ba8:	8b 55 08             	mov    0x8(%ebp),%edx
	const void *ends = (const char *) s + n;
  800bab:	89 d0                	mov    %edx,%eax
  800bad:	03 45 10             	add    0x10(%ebp),%eax
	for (; s < ends; s++)
  800bb0:	39 c2                	cmp    %eax,%edx
  800bb2:	73 1d                	jae    800bd1 <memfind+0x2d>
		if (*(const unsigned char *) s == (unsigned char) c)
  800bb4:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
  800bb8:	0f b6 0a             	movzbl (%edx),%ecx
  800bbb:	39 d9                	cmp    %ebx,%ecx
  800bbd:	75 09                	jne    800bc8 <memfind+0x24>
  800bbf:	eb 14                	jmp    800bd5 <memfind+0x31>
  800bc1:	0f b6 0a             	movzbl (%edx),%ecx
  800bc4:	39 d9                	cmp    %ebx,%ecx
  800bc6:	74 11                	je     800bd9 <memfind+0x35>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800bc8:	83 c2 01             	add    $0x1,%edx
  800bcb:	39 d0                	cmp    %edx,%eax
  800bcd:	75 f2                	jne    800bc1 <memfind+0x1d>
  800bcf:	eb 0a                	jmp    800bdb <memfind+0x37>
  800bd1:	89 d0                	mov    %edx,%eax
  800bd3:	eb 06                	jmp    800bdb <memfind+0x37>
		if (*(const unsigned char *) s == (unsigned char) c)
  800bd5:	89 d0                	mov    %edx,%eax
  800bd7:	eb 02                	jmp    800bdb <memfind+0x37>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800bd9:	89 d0                	mov    %edx,%eax
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800bdb:	5b                   	pop    %ebx
  800bdc:	5d                   	pop    %ebp
  800bdd:	c3                   	ret    

00800bde <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800bde:	55                   	push   %ebp
  800bdf:	89 e5                	mov    %esp,%ebp
  800be1:	57                   	push   %edi
  800be2:	56                   	push   %esi
  800be3:	53                   	push   %ebx
  800be4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800be7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bea:	0f b6 01             	movzbl (%ecx),%eax
  800bed:	3c 20                	cmp    $0x20,%al
  800bef:	74 04                	je     800bf5 <strtol+0x17>
  800bf1:	3c 09                	cmp    $0x9,%al
  800bf3:	75 0e                	jne    800c03 <strtol+0x25>
		s++;
  800bf5:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bf8:	0f b6 01             	movzbl (%ecx),%eax
  800bfb:	3c 20                	cmp    $0x20,%al
  800bfd:	74 f6                	je     800bf5 <strtol+0x17>
  800bff:	3c 09                	cmp    $0x9,%al
  800c01:	74 f2                	je     800bf5 <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c03:	3c 2b                	cmp    $0x2b,%al
  800c05:	75 0a                	jne    800c11 <strtol+0x33>
		s++;
  800c07:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c0a:	bf 00 00 00 00       	mov    $0x0,%edi
  800c0f:	eb 11                	jmp    800c22 <strtol+0x44>
  800c11:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c16:	3c 2d                	cmp    $0x2d,%al
  800c18:	75 08                	jne    800c22 <strtol+0x44>
		s++, neg = 1;
  800c1a:	83 c1 01             	add    $0x1,%ecx
  800c1d:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c22:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c28:	75 15                	jne    800c3f <strtol+0x61>
  800c2a:	80 39 30             	cmpb   $0x30,(%ecx)
  800c2d:	75 10                	jne    800c3f <strtol+0x61>
  800c2f:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c33:	75 7c                	jne    800cb1 <strtol+0xd3>
		s += 2, base = 16;
  800c35:	83 c1 02             	add    $0x2,%ecx
  800c38:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c3d:	eb 16                	jmp    800c55 <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  800c3f:	85 db                	test   %ebx,%ebx
  800c41:	75 12                	jne    800c55 <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c43:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c48:	80 39 30             	cmpb   $0x30,(%ecx)
  800c4b:	75 08                	jne    800c55 <strtol+0x77>
		s++, base = 8;
  800c4d:	83 c1 01             	add    $0x1,%ecx
  800c50:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800c55:	b8 00 00 00 00       	mov    $0x0,%eax
  800c5a:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c5d:	0f b6 11             	movzbl (%ecx),%edx
  800c60:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c63:	89 f3                	mov    %esi,%ebx
  800c65:	80 fb 09             	cmp    $0x9,%bl
  800c68:	77 08                	ja     800c72 <strtol+0x94>
			dig = *s - '0';
  800c6a:	0f be d2             	movsbl %dl,%edx
  800c6d:	83 ea 30             	sub    $0x30,%edx
  800c70:	eb 22                	jmp    800c94 <strtol+0xb6>
		else if (*s >= 'a' && *s <= 'z')
  800c72:	8d 72 9f             	lea    -0x61(%edx),%esi
  800c75:	89 f3                	mov    %esi,%ebx
  800c77:	80 fb 19             	cmp    $0x19,%bl
  800c7a:	77 08                	ja     800c84 <strtol+0xa6>
			dig = *s - 'a' + 10;
  800c7c:	0f be d2             	movsbl %dl,%edx
  800c7f:	83 ea 57             	sub    $0x57,%edx
  800c82:	eb 10                	jmp    800c94 <strtol+0xb6>
		else if (*s >= 'A' && *s <= 'Z')
  800c84:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c87:	89 f3                	mov    %esi,%ebx
  800c89:	80 fb 19             	cmp    $0x19,%bl
  800c8c:	77 16                	ja     800ca4 <strtol+0xc6>
			dig = *s - 'A' + 10;
  800c8e:	0f be d2             	movsbl %dl,%edx
  800c91:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800c94:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c97:	7d 0b                	jge    800ca4 <strtol+0xc6>
			break;
		s++, val = (val * base) + dig;
  800c99:	83 c1 01             	add    $0x1,%ecx
  800c9c:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ca0:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800ca2:	eb b9                	jmp    800c5d <strtol+0x7f>

	if (endptr)
  800ca4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ca8:	74 0d                	je     800cb7 <strtol+0xd9>
		*endptr = (char *) s;
  800caa:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cad:	89 0e                	mov    %ecx,(%esi)
  800caf:	eb 06                	jmp    800cb7 <strtol+0xd9>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800cb1:	85 db                	test   %ebx,%ebx
  800cb3:	74 98                	je     800c4d <strtol+0x6f>
  800cb5:	eb 9e                	jmp    800c55 <strtol+0x77>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800cb7:	89 c2                	mov    %eax,%edx
  800cb9:	f7 da                	neg    %edx
  800cbb:	85 ff                	test   %edi,%edi
  800cbd:	0f 45 c2             	cmovne %edx,%eax
}
  800cc0:	5b                   	pop    %ebx
  800cc1:	5e                   	pop    %esi
  800cc2:	5f                   	pop    %edi
  800cc3:	5d                   	pop    %ebp
  800cc4:	c3                   	ret    

00800cc5 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800cc5:	55                   	push   %ebp
  800cc6:	89 e5                	mov    %esp,%ebp
  800cc8:	57                   	push   %edi
  800cc9:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800cca:	b8 00 00 00 00       	mov    $0x0,%eax
  800ccf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd2:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd5:	89 c3                	mov    %eax,%ebx
  800cd7:	89 c7                	mov    %eax,%edi
  800cd9:	51                   	push   %ecx
  800cda:	52                   	push   %edx
  800cdb:	53                   	push   %ebx
  800cdc:	54                   	push   %esp
  800cdd:	55                   	push   %ebp
  800cde:	56                   	push   %esi
  800cdf:	57                   	push   %edi
  800ce0:	5f                   	pop    %edi
  800ce1:	5e                   	pop    %esi
  800ce2:	5d                   	pop    %ebp
  800ce3:	5c                   	pop    %esp
  800ce4:	5b                   	pop    %ebx
  800ce5:	5a                   	pop    %edx
  800ce6:	59                   	pop    %ecx

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ce7:	5b                   	pop    %ebx
  800ce8:	5f                   	pop    %edi
  800ce9:	5d                   	pop    %ebp
  800cea:	c3                   	ret    

00800ceb <sys_cgetc>:

int
sys_cgetc(void)
{
  800ceb:	55                   	push   %ebp
  800cec:	89 e5                	mov    %esp,%ebp
  800cee:	57                   	push   %edi
  800cef:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800cf0:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cf5:	b8 01 00 00 00       	mov    $0x1,%eax
  800cfa:	89 ca                	mov    %ecx,%edx
  800cfc:	89 cb                	mov    %ecx,%ebx
  800cfe:	89 cf                	mov    %ecx,%edi
  800d00:	51                   	push   %ecx
  800d01:	52                   	push   %edx
  800d02:	53                   	push   %ebx
  800d03:	54                   	push   %esp
  800d04:	55                   	push   %ebp
  800d05:	56                   	push   %esi
  800d06:	57                   	push   %edi
  800d07:	5f                   	pop    %edi
  800d08:	5e                   	pop    %esi
  800d09:	5d                   	pop    %ebp
  800d0a:	5c                   	pop    %esp
  800d0b:	5b                   	pop    %ebx
  800d0c:	5a                   	pop    %edx
  800d0d:	59                   	pop    %ecx

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800d0e:	5b                   	pop    %ebx
  800d0f:	5f                   	pop    %edi
  800d10:	5d                   	pop    %ebp
  800d11:	c3                   	ret    

00800d12 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800d12:	55                   	push   %ebp
  800d13:	89 e5                	mov    %esp,%ebp
  800d15:	57                   	push   %edi
  800d16:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800d17:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d1c:	b8 03 00 00 00       	mov    $0x3,%eax
  800d21:	8b 55 08             	mov    0x8(%ebp),%edx
  800d24:	89 d9                	mov    %ebx,%ecx
  800d26:	89 df                	mov    %ebx,%edi
  800d28:	51                   	push   %ecx
  800d29:	52                   	push   %edx
  800d2a:	53                   	push   %ebx
  800d2b:	54                   	push   %esp
  800d2c:	55                   	push   %ebp
  800d2d:	56                   	push   %esi
  800d2e:	57                   	push   %edi
  800d2f:	5f                   	pop    %edi
  800d30:	5e                   	pop    %esi
  800d31:	5d                   	pop    %ebp
  800d32:	5c                   	pop    %esp
  800d33:	5b                   	pop    %ebx
  800d34:	5a                   	pop    %edx
  800d35:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  800d36:	85 c0                	test   %eax,%eax
  800d38:	7e 17                	jle    800d51 <sys_env_destroy+0x3f>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d3a:	83 ec 0c             	sub    $0xc,%esp
  800d3d:	50                   	push   %eax
  800d3e:	6a 03                	push   $0x3
  800d40:	68 4c 13 80 00       	push   $0x80134c
  800d45:	6a 26                	push   $0x26
  800d47:	68 69 13 80 00       	push   $0x801369
  800d4c:	e8 7f 00 00 00       	call   800dd0 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800d51:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800d54:	5b                   	pop    %ebx
  800d55:	5f                   	pop    %edi
  800d56:	5d                   	pop    %ebp
  800d57:	c3                   	ret    

00800d58 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d58:	55                   	push   %ebp
  800d59:	89 e5                	mov    %esp,%ebp
  800d5b:	57                   	push   %edi
  800d5c:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800d5d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d62:	b8 02 00 00 00       	mov    $0x2,%eax
  800d67:	89 ca                	mov    %ecx,%edx
  800d69:	89 cb                	mov    %ecx,%ebx
  800d6b:	89 cf                	mov    %ecx,%edi
  800d6d:	51                   	push   %ecx
  800d6e:	52                   	push   %edx
  800d6f:	53                   	push   %ebx
  800d70:	54                   	push   %esp
  800d71:	55                   	push   %ebp
  800d72:	56                   	push   %esi
  800d73:	57                   	push   %edi
  800d74:	5f                   	pop    %edi
  800d75:	5e                   	pop    %esi
  800d76:	5d                   	pop    %ebp
  800d77:	5c                   	pop    %esp
  800d78:	5b                   	pop    %ebx
  800d79:	5a                   	pop    %edx
  800d7a:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d7b:	5b                   	pop    %ebx
  800d7c:	5f                   	pop    %edi
  800d7d:	5d                   	pop    %ebp
  800d7e:	c3                   	ret    

00800d7f <sys_map_kernel_page>:

int
sys_map_kernel_page(void* kpage, void* va)
{
  800d7f:	55                   	push   %ebp
  800d80:	89 e5                	mov    %esp,%ebp
  800d82:	57                   	push   %edi
  800d83:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800d84:	bf 00 00 00 00       	mov    $0x0,%edi
  800d89:	b8 04 00 00 00       	mov    $0x4,%eax
  800d8e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d91:	8b 55 08             	mov    0x8(%ebp),%edx
  800d94:	89 fb                	mov    %edi,%ebx
  800d96:	51                   	push   %ecx
  800d97:	52                   	push   %edx
  800d98:	53                   	push   %ebx
  800d99:	54                   	push   %esp
  800d9a:	55                   	push   %ebp
  800d9b:	56                   	push   %esi
  800d9c:	57                   	push   %edi
  800d9d:	5f                   	pop    %edi
  800d9e:	5e                   	pop    %esi
  800d9f:	5d                   	pop    %ebp
  800da0:	5c                   	pop    %esp
  800da1:	5b                   	pop    %ebx
  800da2:	5a                   	pop    %edx
  800da3:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  800da4:	5b                   	pop    %ebx
  800da5:	5f                   	pop    %edi
  800da6:	5d                   	pop    %ebp
  800da7:	c3                   	ret    

00800da8 <sys_sbrk>:

int
sys_sbrk(uint32_t inc)
{
  800da8:	55                   	push   %ebp
  800da9:	89 e5                	mov    %esp,%ebp
  800dab:	57                   	push   %edi
  800dac:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800dad:	b9 00 00 00 00       	mov    $0x0,%ecx
  800db2:	b8 05 00 00 00       	mov    $0x5,%eax
  800db7:	8b 55 08             	mov    0x8(%ebp),%edx
  800dba:	89 cb                	mov    %ecx,%ebx
  800dbc:	89 cf                	mov    %ecx,%edi
  800dbe:	51                   	push   %ecx
  800dbf:	52                   	push   %edx
  800dc0:	53                   	push   %ebx
  800dc1:	54                   	push   %esp
  800dc2:	55                   	push   %ebp
  800dc3:	56                   	push   %esi
  800dc4:	57                   	push   %edi
  800dc5:	5f                   	pop    %edi
  800dc6:	5e                   	pop    %esi
  800dc7:	5d                   	pop    %ebp
  800dc8:	5c                   	pop    %esp
  800dc9:	5b                   	pop    %ebx
  800dca:	5a                   	pop    %edx
  800dcb:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  800dcc:	5b                   	pop    %ebx
  800dcd:	5f                   	pop    %edi
  800dce:	5d                   	pop    %ebp
  800dcf:	c3                   	ret    

00800dd0 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800dd0:	55                   	push   %ebp
  800dd1:	89 e5                	mov    %esp,%ebp
  800dd3:	56                   	push   %esi
  800dd4:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800dd5:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	if (argv0)
  800dd8:	a1 0c 20 80 00       	mov    0x80200c,%eax
  800ddd:	85 c0                	test   %eax,%eax
  800ddf:	74 11                	je     800df2 <_panic+0x22>
		cprintf("%s: ", argv0);
  800de1:	83 ec 08             	sub    $0x8,%esp
  800de4:	50                   	push   %eax
  800de5:	68 77 13 80 00       	push   $0x801377
  800dea:	e8 4c f3 ff ff       	call   80013b <cprintf>
  800def:	83 c4 10             	add    $0x10,%esp
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800df2:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800df8:	e8 5b ff ff ff       	call   800d58 <sys_getenvid>
  800dfd:	83 ec 0c             	sub    $0xc,%esp
  800e00:	ff 75 0c             	pushl  0xc(%ebp)
  800e03:	ff 75 08             	pushl  0x8(%ebp)
  800e06:	56                   	push   %esi
  800e07:	50                   	push   %eax
  800e08:	68 7c 13 80 00       	push   $0x80137c
  800e0d:	e8 29 f3 ff ff       	call   80013b <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800e12:	83 c4 18             	add    $0x18,%esp
  800e15:	53                   	push   %ebx
  800e16:	ff 75 10             	pushl  0x10(%ebp)
  800e19:	e8 cc f2 ff ff       	call   8000ea <vcprintf>
	cprintf("\n");
  800e1e:	c7 04 24 c0 10 80 00 	movl   $0x8010c0,(%esp)
  800e25:	e8 11 f3 ff ff       	call   80013b <cprintf>
  800e2a:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800e2d:	cc                   	int3   
  800e2e:	eb fd                	jmp    800e2d <_panic+0x5d>

00800e30 <__udivdi3>:
  800e30:	55                   	push   %ebp
  800e31:	57                   	push   %edi
  800e32:	56                   	push   %esi
  800e33:	53                   	push   %ebx
  800e34:	83 ec 1c             	sub    $0x1c,%esp
  800e37:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  800e3b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  800e3f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  800e43:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800e47:	85 f6                	test   %esi,%esi
  800e49:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800e4d:	89 ca                	mov    %ecx,%edx
  800e4f:	89 f8                	mov    %edi,%eax
  800e51:	75 3d                	jne    800e90 <__udivdi3+0x60>
  800e53:	39 cf                	cmp    %ecx,%edi
  800e55:	0f 87 c5 00 00 00    	ja     800f20 <__udivdi3+0xf0>
  800e5b:	85 ff                	test   %edi,%edi
  800e5d:	89 fd                	mov    %edi,%ebp
  800e5f:	75 0b                	jne    800e6c <__udivdi3+0x3c>
  800e61:	b8 01 00 00 00       	mov    $0x1,%eax
  800e66:	31 d2                	xor    %edx,%edx
  800e68:	f7 f7                	div    %edi
  800e6a:	89 c5                	mov    %eax,%ebp
  800e6c:	89 c8                	mov    %ecx,%eax
  800e6e:	31 d2                	xor    %edx,%edx
  800e70:	f7 f5                	div    %ebp
  800e72:	89 c1                	mov    %eax,%ecx
  800e74:	89 d8                	mov    %ebx,%eax
  800e76:	89 cf                	mov    %ecx,%edi
  800e78:	f7 f5                	div    %ebp
  800e7a:	89 c3                	mov    %eax,%ebx
  800e7c:	89 d8                	mov    %ebx,%eax
  800e7e:	89 fa                	mov    %edi,%edx
  800e80:	83 c4 1c             	add    $0x1c,%esp
  800e83:	5b                   	pop    %ebx
  800e84:	5e                   	pop    %esi
  800e85:	5f                   	pop    %edi
  800e86:	5d                   	pop    %ebp
  800e87:	c3                   	ret    
  800e88:	90                   	nop
  800e89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e90:	39 ce                	cmp    %ecx,%esi
  800e92:	77 74                	ja     800f08 <__udivdi3+0xd8>
  800e94:	0f bd fe             	bsr    %esi,%edi
  800e97:	83 f7 1f             	xor    $0x1f,%edi
  800e9a:	0f 84 98 00 00 00    	je     800f38 <__udivdi3+0x108>
  800ea0:	bb 20 00 00 00       	mov    $0x20,%ebx
  800ea5:	89 f9                	mov    %edi,%ecx
  800ea7:	89 c5                	mov    %eax,%ebp
  800ea9:	29 fb                	sub    %edi,%ebx
  800eab:	d3 e6                	shl    %cl,%esi
  800ead:	89 d9                	mov    %ebx,%ecx
  800eaf:	d3 ed                	shr    %cl,%ebp
  800eb1:	89 f9                	mov    %edi,%ecx
  800eb3:	d3 e0                	shl    %cl,%eax
  800eb5:	09 ee                	or     %ebp,%esi
  800eb7:	89 d9                	mov    %ebx,%ecx
  800eb9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ebd:	89 d5                	mov    %edx,%ebp
  800ebf:	8b 44 24 08          	mov    0x8(%esp),%eax
  800ec3:	d3 ed                	shr    %cl,%ebp
  800ec5:	89 f9                	mov    %edi,%ecx
  800ec7:	d3 e2                	shl    %cl,%edx
  800ec9:	89 d9                	mov    %ebx,%ecx
  800ecb:	d3 e8                	shr    %cl,%eax
  800ecd:	09 c2                	or     %eax,%edx
  800ecf:	89 d0                	mov    %edx,%eax
  800ed1:	89 ea                	mov    %ebp,%edx
  800ed3:	f7 f6                	div    %esi
  800ed5:	89 d5                	mov    %edx,%ebp
  800ed7:	89 c3                	mov    %eax,%ebx
  800ed9:	f7 64 24 0c          	mull   0xc(%esp)
  800edd:	39 d5                	cmp    %edx,%ebp
  800edf:	72 10                	jb     800ef1 <__udivdi3+0xc1>
  800ee1:	8b 74 24 08          	mov    0x8(%esp),%esi
  800ee5:	89 f9                	mov    %edi,%ecx
  800ee7:	d3 e6                	shl    %cl,%esi
  800ee9:	39 c6                	cmp    %eax,%esi
  800eeb:	73 07                	jae    800ef4 <__udivdi3+0xc4>
  800eed:	39 d5                	cmp    %edx,%ebp
  800eef:	75 03                	jne    800ef4 <__udivdi3+0xc4>
  800ef1:	83 eb 01             	sub    $0x1,%ebx
  800ef4:	31 ff                	xor    %edi,%edi
  800ef6:	89 d8                	mov    %ebx,%eax
  800ef8:	89 fa                	mov    %edi,%edx
  800efa:	83 c4 1c             	add    $0x1c,%esp
  800efd:	5b                   	pop    %ebx
  800efe:	5e                   	pop    %esi
  800eff:	5f                   	pop    %edi
  800f00:	5d                   	pop    %ebp
  800f01:	c3                   	ret    
  800f02:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800f08:	31 ff                	xor    %edi,%edi
  800f0a:	31 db                	xor    %ebx,%ebx
  800f0c:	89 d8                	mov    %ebx,%eax
  800f0e:	89 fa                	mov    %edi,%edx
  800f10:	83 c4 1c             	add    $0x1c,%esp
  800f13:	5b                   	pop    %ebx
  800f14:	5e                   	pop    %esi
  800f15:	5f                   	pop    %edi
  800f16:	5d                   	pop    %ebp
  800f17:	c3                   	ret    
  800f18:	90                   	nop
  800f19:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f20:	89 d8                	mov    %ebx,%eax
  800f22:	f7 f7                	div    %edi
  800f24:	31 ff                	xor    %edi,%edi
  800f26:	89 c3                	mov    %eax,%ebx
  800f28:	89 d8                	mov    %ebx,%eax
  800f2a:	89 fa                	mov    %edi,%edx
  800f2c:	83 c4 1c             	add    $0x1c,%esp
  800f2f:	5b                   	pop    %ebx
  800f30:	5e                   	pop    %esi
  800f31:	5f                   	pop    %edi
  800f32:	5d                   	pop    %ebp
  800f33:	c3                   	ret    
  800f34:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f38:	39 ce                	cmp    %ecx,%esi
  800f3a:	72 0c                	jb     800f48 <__udivdi3+0x118>
  800f3c:	31 db                	xor    %ebx,%ebx
  800f3e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  800f42:	0f 87 34 ff ff ff    	ja     800e7c <__udivdi3+0x4c>
  800f48:	bb 01 00 00 00       	mov    $0x1,%ebx
  800f4d:	e9 2a ff ff ff       	jmp    800e7c <__udivdi3+0x4c>
  800f52:	66 90                	xchg   %ax,%ax
  800f54:	66 90                	xchg   %ax,%ax
  800f56:	66 90                	xchg   %ax,%ax
  800f58:	66 90                	xchg   %ax,%ax
  800f5a:	66 90                	xchg   %ax,%ax
  800f5c:	66 90                	xchg   %ax,%ax
  800f5e:	66 90                	xchg   %ax,%ax

00800f60 <__umoddi3>:
  800f60:	55                   	push   %ebp
  800f61:	57                   	push   %edi
  800f62:	56                   	push   %esi
  800f63:	53                   	push   %ebx
  800f64:	83 ec 1c             	sub    $0x1c,%esp
  800f67:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800f6b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  800f6f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800f73:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800f77:	85 d2                	test   %edx,%edx
  800f79:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800f7d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800f81:	89 f3                	mov    %esi,%ebx
  800f83:	89 3c 24             	mov    %edi,(%esp)
  800f86:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f8a:	75 1c                	jne    800fa8 <__umoddi3+0x48>
  800f8c:	39 f7                	cmp    %esi,%edi
  800f8e:	76 50                	jbe    800fe0 <__umoddi3+0x80>
  800f90:	89 c8                	mov    %ecx,%eax
  800f92:	89 f2                	mov    %esi,%edx
  800f94:	f7 f7                	div    %edi
  800f96:	89 d0                	mov    %edx,%eax
  800f98:	31 d2                	xor    %edx,%edx
  800f9a:	83 c4 1c             	add    $0x1c,%esp
  800f9d:	5b                   	pop    %ebx
  800f9e:	5e                   	pop    %esi
  800f9f:	5f                   	pop    %edi
  800fa0:	5d                   	pop    %ebp
  800fa1:	c3                   	ret    
  800fa2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800fa8:	39 f2                	cmp    %esi,%edx
  800faa:	89 d0                	mov    %edx,%eax
  800fac:	77 52                	ja     801000 <__umoddi3+0xa0>
  800fae:	0f bd ea             	bsr    %edx,%ebp
  800fb1:	83 f5 1f             	xor    $0x1f,%ebp
  800fb4:	75 5a                	jne    801010 <__umoddi3+0xb0>
  800fb6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  800fba:	0f 82 e0 00 00 00    	jb     8010a0 <__umoddi3+0x140>
  800fc0:	39 0c 24             	cmp    %ecx,(%esp)
  800fc3:	0f 86 d7 00 00 00    	jbe    8010a0 <__umoddi3+0x140>
  800fc9:	8b 44 24 08          	mov    0x8(%esp),%eax
  800fcd:	8b 54 24 04          	mov    0x4(%esp),%edx
  800fd1:	83 c4 1c             	add    $0x1c,%esp
  800fd4:	5b                   	pop    %ebx
  800fd5:	5e                   	pop    %esi
  800fd6:	5f                   	pop    %edi
  800fd7:	5d                   	pop    %ebp
  800fd8:	c3                   	ret    
  800fd9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800fe0:	85 ff                	test   %edi,%edi
  800fe2:	89 fd                	mov    %edi,%ebp
  800fe4:	75 0b                	jne    800ff1 <__umoddi3+0x91>
  800fe6:	b8 01 00 00 00       	mov    $0x1,%eax
  800feb:	31 d2                	xor    %edx,%edx
  800fed:	f7 f7                	div    %edi
  800fef:	89 c5                	mov    %eax,%ebp
  800ff1:	89 f0                	mov    %esi,%eax
  800ff3:	31 d2                	xor    %edx,%edx
  800ff5:	f7 f5                	div    %ebp
  800ff7:	89 c8                	mov    %ecx,%eax
  800ff9:	f7 f5                	div    %ebp
  800ffb:	89 d0                	mov    %edx,%eax
  800ffd:	eb 99                	jmp    800f98 <__umoddi3+0x38>
  800fff:	90                   	nop
  801000:	89 c8                	mov    %ecx,%eax
  801002:	89 f2                	mov    %esi,%edx
  801004:	83 c4 1c             	add    $0x1c,%esp
  801007:	5b                   	pop    %ebx
  801008:	5e                   	pop    %esi
  801009:	5f                   	pop    %edi
  80100a:	5d                   	pop    %ebp
  80100b:	c3                   	ret    
  80100c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801010:	8b 34 24             	mov    (%esp),%esi
  801013:	bf 20 00 00 00       	mov    $0x20,%edi
  801018:	89 e9                	mov    %ebp,%ecx
  80101a:	29 ef                	sub    %ebp,%edi
  80101c:	d3 e0                	shl    %cl,%eax
  80101e:	89 f9                	mov    %edi,%ecx
  801020:	89 f2                	mov    %esi,%edx
  801022:	d3 ea                	shr    %cl,%edx
  801024:	89 e9                	mov    %ebp,%ecx
  801026:	09 c2                	or     %eax,%edx
  801028:	89 d8                	mov    %ebx,%eax
  80102a:	89 14 24             	mov    %edx,(%esp)
  80102d:	89 f2                	mov    %esi,%edx
  80102f:	d3 e2                	shl    %cl,%edx
  801031:	89 f9                	mov    %edi,%ecx
  801033:	89 54 24 04          	mov    %edx,0x4(%esp)
  801037:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80103b:	d3 e8                	shr    %cl,%eax
  80103d:	89 e9                	mov    %ebp,%ecx
  80103f:	89 c6                	mov    %eax,%esi
  801041:	d3 e3                	shl    %cl,%ebx
  801043:	89 f9                	mov    %edi,%ecx
  801045:	89 d0                	mov    %edx,%eax
  801047:	d3 e8                	shr    %cl,%eax
  801049:	89 e9                	mov    %ebp,%ecx
  80104b:	09 d8                	or     %ebx,%eax
  80104d:	89 d3                	mov    %edx,%ebx
  80104f:	89 f2                	mov    %esi,%edx
  801051:	f7 34 24             	divl   (%esp)
  801054:	89 d6                	mov    %edx,%esi
  801056:	d3 e3                	shl    %cl,%ebx
  801058:	f7 64 24 04          	mull   0x4(%esp)
  80105c:	39 d6                	cmp    %edx,%esi
  80105e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801062:	89 d1                	mov    %edx,%ecx
  801064:	89 c3                	mov    %eax,%ebx
  801066:	72 08                	jb     801070 <__umoddi3+0x110>
  801068:	75 11                	jne    80107b <__umoddi3+0x11b>
  80106a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80106e:	73 0b                	jae    80107b <__umoddi3+0x11b>
  801070:	2b 44 24 04          	sub    0x4(%esp),%eax
  801074:	1b 14 24             	sbb    (%esp),%edx
  801077:	89 d1                	mov    %edx,%ecx
  801079:	89 c3                	mov    %eax,%ebx
  80107b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80107f:	29 da                	sub    %ebx,%edx
  801081:	19 ce                	sbb    %ecx,%esi
  801083:	89 f9                	mov    %edi,%ecx
  801085:	89 f0                	mov    %esi,%eax
  801087:	d3 e0                	shl    %cl,%eax
  801089:	89 e9                	mov    %ebp,%ecx
  80108b:	d3 ea                	shr    %cl,%edx
  80108d:	89 e9                	mov    %ebp,%ecx
  80108f:	d3 ee                	shr    %cl,%esi
  801091:	09 d0                	or     %edx,%eax
  801093:	89 f2                	mov    %esi,%edx
  801095:	83 c4 1c             	add    $0x1c,%esp
  801098:	5b                   	pop    %ebx
  801099:	5e                   	pop    %esi
  80109a:	5f                   	pop    %edi
  80109b:	5d                   	pop    %ebp
  80109c:	c3                   	ret    
  80109d:	8d 76 00             	lea    0x0(%esi),%esi
  8010a0:	29 f9                	sub    %edi,%ecx
  8010a2:	19 d6                	sbb    %edx,%esi
  8010a4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8010a8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8010ac:	e9 18 ff ff ff       	jmp    800fc9 <__umoddi3+0x69>
