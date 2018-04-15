
obj/user/hello:     file format elf32-i386


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
  80002c:	e8 2d 00 00 00       	call   80005e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
// hello, world
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 14             	sub    $0x14,%esp
	cprintf("hello, world\n");
  800039:	68 b4 10 80 00       	push   $0x8010b4
  80003e:	e8 f6 00 00 00       	call   800139 <cprintf>
	cprintf("i am environment %08x\n", thisenv->env_id);
  800043:	a1 04 20 80 00       	mov    0x802004,%eax
  800048:	8b 40 48             	mov    0x48(%eax),%eax
  80004b:	83 c4 08             	add    $0x8,%esp
  80004e:	50                   	push   %eax
  80004f:	68 c2 10 80 00       	push   $0x8010c2
  800054:	e8 e0 00 00 00       	call   800139 <cprintf>
}
  800059:	83 c4 10             	add    $0x10,%esp
  80005c:	c9                   	leave  
  80005d:	c3                   	ret    

0080005e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80005e:	55                   	push   %ebp
  80005f:	89 e5                	mov    %esp,%ebp
  800061:	83 ec 08             	sub    $0x8,%esp
  800064:	8b 45 08             	mov    0x8(%ebp),%eax
  800067:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  80006a:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800071:	00 00 00 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800074:	85 c0                	test   %eax,%eax
  800076:	7e 08                	jle    800080 <libmain+0x22>
		binaryname = argv[0];
  800078:	8b 0a                	mov    (%edx),%ecx
  80007a:	89 0d 00 20 80 00    	mov    %ecx,0x802000

	// call user main routine
	umain(argc, argv);
  800080:	83 ec 08             	sub    $0x8,%esp
  800083:	52                   	push   %edx
  800084:	50                   	push   %eax
  800085:	e8 a9 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80008a:	e8 05 00 00 00       	call   800094 <exit>
}
  80008f:	83 c4 10             	add    $0x10,%esp
  800092:	c9                   	leave  
  800093:	c3                   	ret    

00800094 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800094:	55                   	push   %ebp
  800095:	89 e5                	mov    %esp,%ebp
  800097:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80009a:	6a 00                	push   $0x0
  80009c:	e8 6f 0c 00 00       	call   800d10 <sys_env_destroy>
}
  8000a1:	83 c4 10             	add    $0x10,%esp
  8000a4:	c9                   	leave  
  8000a5:	c3                   	ret    

008000a6 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000a6:	55                   	push   %ebp
  8000a7:	89 e5                	mov    %esp,%ebp
  8000a9:	53                   	push   %ebx
  8000aa:	83 ec 04             	sub    $0x4,%esp
  8000ad:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000b0:	8b 13                	mov    (%ebx),%edx
  8000b2:	8d 42 01             	lea    0x1(%edx),%eax
  8000b5:	89 03                	mov    %eax,(%ebx)
  8000b7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000ba:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000be:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000c3:	75 1a                	jne    8000df <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8000c5:	83 ec 08             	sub    $0x8,%esp
  8000c8:	68 ff 00 00 00       	push   $0xff
  8000cd:	8d 43 08             	lea    0x8(%ebx),%eax
  8000d0:	50                   	push   %eax
  8000d1:	e8 ed 0b 00 00       	call   800cc3 <sys_cputs>
		b->idx = 0;
  8000d6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8000dc:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8000df:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000e3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000e6:	c9                   	leave  
  8000e7:	c3                   	ret    

008000e8 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8000e8:	55                   	push   %ebp
  8000e9:	89 e5                	mov    %esp,%ebp
  8000eb:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8000f1:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8000f8:	00 00 00 
	b.cnt = 0;
  8000fb:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800102:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800105:	ff 75 0c             	pushl  0xc(%ebp)
  800108:	ff 75 08             	pushl  0x8(%ebp)
  80010b:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800111:	50                   	push   %eax
  800112:	68 a6 00 80 00       	push   $0x8000a6
  800117:	e8 45 02 00 00       	call   800361 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80011c:	83 c4 08             	add    $0x8,%esp
  80011f:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800125:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80012b:	50                   	push   %eax
  80012c:	e8 92 0b 00 00       	call   800cc3 <sys_cputs>

	return b.cnt;
}
  800131:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800137:	c9                   	leave  
  800138:	c3                   	ret    

00800139 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800139:	55                   	push   %ebp
  80013a:	89 e5                	mov    %esp,%ebp
  80013c:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80013f:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800142:	50                   	push   %eax
  800143:	ff 75 08             	pushl  0x8(%ebp)
  800146:	e8 9d ff ff ff       	call   8000e8 <vcprintf>
	va_end(ap);

	return cnt;
}
  80014b:	c9                   	leave  
  80014c:	c3                   	ret    

0080014d <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80014d:	55                   	push   %ebp
  80014e:	89 e5                	mov    %esp,%ebp
  800150:	57                   	push   %edi
  800151:	56                   	push   %esi
  800152:	53                   	push   %ebx
  800153:	83 ec 1c             	sub    $0x1c,%esp
  800156:	89 c7                	mov    %eax,%edi
  800158:	89 d6                	mov    %edx,%esi
  80015a:	8b 45 08             	mov    0x8(%ebp),%eax
  80015d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800160:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800163:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	// if cprintf'parameter includes pattern of the form "%-", padding
	// space on the right side if neccesary.
	// you can add helper function if needed.
	// your code here:
	int length,showsign=0;
	if(padc=='-'&&num>=base)
  800166:	83 7d 18 2d          	cmpl   $0x2d,0x18(%ebp)
  80016a:	0f 85 8a 00 00 00    	jne    8001fa <printnum+0xad>
  800170:	8b 45 10             	mov    0x10(%ebp),%eax
  800173:	ba 00 00 00 00       	mov    $0x0,%edx
  800178:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80017b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80017e:	39 da                	cmp    %ebx,%edx
  800180:	72 09                	jb     80018b <printnum+0x3e>
  800182:	39 4d 10             	cmp    %ecx,0x10(%ebp)
  800185:	0f 87 87 00 00 00    	ja     800212 <printnum+0xc5>
	{
		length=*(int *)putdat;
  80018b:	8b 1e                	mov    (%esi),%ebx
		printnum(putch,putdat,num/base,base,0,padc);
  80018d:	83 ec 0c             	sub    $0xc,%esp
  800190:	6a 2d                	push   $0x2d
  800192:	6a 00                	push   $0x0
  800194:	ff 75 10             	pushl  0x10(%ebp)
  800197:	83 ec 08             	sub    $0x8,%esp
  80019a:	52                   	push   %edx
  80019b:	50                   	push   %eax
  80019c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80019f:	ff 75 e0             	pushl  -0x20(%ebp)
  8001a2:	e8 89 0c 00 00       	call   800e30 <__udivdi3>
  8001a7:	83 c4 18             	add    $0x18,%esp
  8001aa:	52                   	push   %edx
  8001ab:	50                   	push   %eax
  8001ac:	89 f2                	mov    %esi,%edx
  8001ae:	89 f8                	mov    %edi,%eax
  8001b0:	e8 98 ff ff ff       	call   80014d <printnum>
		while (--width > 0)
			putch(padc, putdat);
	}
	}
	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001b5:	83 c4 18             	add    $0x18,%esp
  8001b8:	56                   	push   %esi
  8001b9:	8b 45 10             	mov    0x10(%ebp),%eax
  8001bc:	ba 00 00 00 00       	mov    $0x0,%edx
  8001c1:	83 ec 04             	sub    $0x4,%esp
  8001c4:	52                   	push   %edx
  8001c5:	50                   	push   %eax
  8001c6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001c9:	ff 75 e0             	pushl  -0x20(%ebp)
  8001cc:	e8 8f 0d 00 00       	call   800f60 <__umoddi3>
  8001d1:	83 c4 14             	add    $0x14,%esp
  8001d4:	0f be 80 e3 10 80 00 	movsbl 0x8010e3(%eax),%eax
  8001db:	50                   	push   %eax
  8001dc:	ff d7                	call   *%edi
	
	if(padc=='-'&&width>0)
  8001de:	83 c4 10             	add    $0x10,%esp
  8001e1:	83 7d 18 2d          	cmpl   $0x2d,0x18(%ebp)
  8001e5:	0f 85 fa 00 00 00    	jne    8002e5 <printnum+0x198>
  8001eb:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
  8001ef:	0f 8f 9b 00 00 00    	jg     800290 <printnum+0x143>
  8001f5:	e9 eb 00 00 00       	jmp    8002e5 <printnum+0x198>
	}
	else
	{
	
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001fa:	8b 45 10             	mov    0x10(%ebp),%eax
  8001fd:	ba 00 00 00 00       	mov    $0x0,%edx
  800202:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800205:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800208:	83 fb 00             	cmp    $0x0,%ebx
  80020b:	77 14                	ja     800221 <printnum+0xd4>
  80020d:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800210:	73 0f                	jae    800221 <printnum+0xd4>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800212:	8b 45 14             	mov    0x14(%ebp),%eax
  800215:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800218:	85 db                	test   %ebx,%ebx
  80021a:	7f 61                	jg     80027d <printnum+0x130>
  80021c:	e9 98 00 00 00       	jmp    8002b9 <printnum+0x16c>
	else
	{
	
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800221:	83 ec 0c             	sub    $0xc,%esp
  800224:	ff 75 18             	pushl  0x18(%ebp)
  800227:	8b 4d 14             	mov    0x14(%ebp),%ecx
  80022a:	8d 59 ff             	lea    -0x1(%ecx),%ebx
  80022d:	53                   	push   %ebx
  80022e:	ff 75 10             	pushl  0x10(%ebp)
  800231:	83 ec 08             	sub    $0x8,%esp
  800234:	52                   	push   %edx
  800235:	50                   	push   %eax
  800236:	ff 75 e4             	pushl  -0x1c(%ebp)
  800239:	ff 75 e0             	pushl  -0x20(%ebp)
  80023c:	e8 ef 0b 00 00       	call   800e30 <__udivdi3>
  800241:	83 c4 18             	add    $0x18,%esp
  800244:	52                   	push   %edx
  800245:	50                   	push   %eax
  800246:	89 f2                	mov    %esi,%edx
  800248:	89 f8                	mov    %edi,%eax
  80024a:	e8 fe fe ff ff       	call   80014d <printnum>
		while (--width > 0)
			putch(padc, putdat);
	}
	}
	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80024f:	83 c4 18             	add    $0x18,%esp
  800252:	56                   	push   %esi
  800253:	8b 45 10             	mov    0x10(%ebp),%eax
  800256:	ba 00 00 00 00       	mov    $0x0,%edx
  80025b:	83 ec 04             	sub    $0x4,%esp
  80025e:	52                   	push   %edx
  80025f:	50                   	push   %eax
  800260:	ff 75 e4             	pushl  -0x1c(%ebp)
  800263:	ff 75 e0             	pushl  -0x20(%ebp)
  800266:	e8 f5 0c 00 00       	call   800f60 <__umoddi3>
  80026b:	83 c4 14             	add    $0x14,%esp
  80026e:	0f be 80 e3 10 80 00 	movsbl 0x8010e3(%eax),%eax
  800275:	50                   	push   %eax
  800276:	ff d7                	call   *%edi
  800278:	83 c4 10             	add    $0x10,%esp
  80027b:	eb 68                	jmp    8002e5 <printnum+0x198>
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80027d:	83 ec 08             	sub    $0x8,%esp
  800280:	56                   	push   %esi
  800281:	ff 75 18             	pushl  0x18(%ebp)
  800284:	ff d7                	call   *%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800286:	83 c4 10             	add    $0x10,%esp
  800289:	83 eb 01             	sub    $0x1,%ebx
  80028c:	75 ef                	jne    80027d <printnum+0x130>
  80028e:	eb 29                	jmp    8002b9 <printnum+0x16c>
	putch("0123456789abcdef"[num % base], putdat);
	
	if(padc=='-'&&width>0)
	{
		length=*(int *)putdat-length;
		for(int i=0;i<width-length;++i)
  800290:	8b 45 14             	mov    0x14(%ebp),%eax
  800293:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800296:	2b 06                	sub    (%esi),%eax
  800298:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80029b:	85 c0                	test   %eax,%eax
  80029d:	7e 46                	jle    8002e5 <printnum+0x198>
  80029f:	bb 00 00 00 00       	mov    $0x0,%ebx
			putch(' ',putdat);
  8002a4:	83 ec 08             	sub    $0x8,%esp
  8002a7:	56                   	push   %esi
  8002a8:	6a 20                	push   $0x20
  8002aa:	ff d7                	call   *%edi
	putch("0123456789abcdef"[num % base], putdat);
	
	if(padc=='-'&&width>0)
	{
		length=*(int *)putdat-length;
		for(int i=0;i<width-length;++i)
  8002ac:	83 c3 01             	add    $0x1,%ebx
  8002af:	83 c4 10             	add    $0x10,%esp
  8002b2:	3b 5d e0             	cmp    -0x20(%ebp),%ebx
  8002b5:	75 ed                	jne    8002a4 <printnum+0x157>
  8002b7:	eb 2c                	jmp    8002e5 <printnum+0x198>
		while (--width > 0)
			putch(padc, putdat);
	}
	}
	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002b9:	83 ec 08             	sub    $0x8,%esp
  8002bc:	56                   	push   %esi
  8002bd:	8b 45 10             	mov    0x10(%ebp),%eax
  8002c0:	ba 00 00 00 00       	mov    $0x0,%edx
  8002c5:	83 ec 04             	sub    $0x4,%esp
  8002c8:	52                   	push   %edx
  8002c9:	50                   	push   %eax
  8002ca:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002cd:	ff 75 e0             	pushl  -0x20(%ebp)
  8002d0:	e8 8b 0c 00 00       	call   800f60 <__umoddi3>
  8002d5:	83 c4 14             	add    $0x14,%esp
  8002d8:	0f be 80 e3 10 80 00 	movsbl 0x8010e3(%eax),%eax
  8002df:	50                   	push   %eax
  8002e0:	ff d7                	call   *%edi
  8002e2:	83 c4 10             	add    $0x10,%esp
	{
		length=*(int *)putdat-length;
		for(int i=0;i<width-length;++i)
			putch(' ',putdat);
	}
}
  8002e5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002e8:	5b                   	pop    %ebx
  8002e9:	5e                   	pop    %esi
  8002ea:	5f                   	pop    %edi
  8002eb:	5d                   	pop    %ebp
  8002ec:	c3                   	ret    

008002ed <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002ed:	55                   	push   %ebp
  8002ee:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002f0:	83 fa 01             	cmp    $0x1,%edx
  8002f3:	7e 0e                	jle    800303 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002f5:	8b 10                	mov    (%eax),%edx
  8002f7:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002fa:	89 08                	mov    %ecx,(%eax)
  8002fc:	8b 02                	mov    (%edx),%eax
  8002fe:	8b 52 04             	mov    0x4(%edx),%edx
  800301:	eb 22                	jmp    800325 <getuint+0x38>
	else if (lflag)
  800303:	85 d2                	test   %edx,%edx
  800305:	74 10                	je     800317 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800307:	8b 10                	mov    (%eax),%edx
  800309:	8d 4a 04             	lea    0x4(%edx),%ecx
  80030c:	89 08                	mov    %ecx,(%eax)
  80030e:	8b 02                	mov    (%edx),%eax
  800310:	ba 00 00 00 00       	mov    $0x0,%edx
  800315:	eb 0e                	jmp    800325 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800317:	8b 10                	mov    (%eax),%edx
  800319:	8d 4a 04             	lea    0x4(%edx),%ecx
  80031c:	89 08                	mov    %ecx,(%eax)
  80031e:	8b 02                	mov    (%edx),%eax
  800320:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800325:	5d                   	pop    %ebp
  800326:	c3                   	ret    

00800327 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800327:	55                   	push   %ebp
  800328:	89 e5                	mov    %esp,%ebp
  80032a:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80032d:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800331:	8b 10                	mov    (%eax),%edx
  800333:	3b 50 04             	cmp    0x4(%eax),%edx
  800336:	73 0a                	jae    800342 <sprintputch+0x1b>
		*b->buf++ = ch;
  800338:	8d 4a 01             	lea    0x1(%edx),%ecx
  80033b:	89 08                	mov    %ecx,(%eax)
  80033d:	8b 45 08             	mov    0x8(%ebp),%eax
  800340:	88 02                	mov    %al,(%edx)
}
  800342:	5d                   	pop    %ebp
  800343:	c3                   	ret    

00800344 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800344:	55                   	push   %ebp
  800345:	89 e5                	mov    %esp,%ebp
  800347:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80034a:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80034d:	50                   	push   %eax
  80034e:	ff 75 10             	pushl  0x10(%ebp)
  800351:	ff 75 0c             	pushl  0xc(%ebp)
  800354:	ff 75 08             	pushl  0x8(%ebp)
  800357:	e8 05 00 00 00       	call   800361 <vprintfmt>
	va_end(ap);
}
  80035c:	83 c4 10             	add    $0x10,%esp
  80035f:	c9                   	leave  
  800360:	c3                   	ret    

00800361 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800361:	55                   	push   %ebp
  800362:	89 e5                	mov    %esp,%ebp
  800364:	57                   	push   %edi
  800365:	56                   	push   %esi
  800366:	53                   	push   %ebx
  800367:	83 ec 2c             	sub    $0x2c,%esp
  80036a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80036d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800370:	eb 03                	jmp    800375 <vprintfmt+0x14>
			break;
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
			for (fmt--; fmt[-1] != '%'; fmt--)
  800372:	89 75 10             	mov    %esi,0x10(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800375:	8b 45 10             	mov    0x10(%ebp),%eax
  800378:	8d 70 01             	lea    0x1(%eax),%esi
  80037b:	0f b6 00             	movzbl (%eax),%eax
  80037e:	83 f8 25             	cmp    $0x25,%eax
  800381:	74 27                	je     8003aa <vprintfmt+0x49>
			if (ch == '\0')
  800383:	85 c0                	test   %eax,%eax
  800385:	75 0d                	jne    800394 <vprintfmt+0x33>
  800387:	e9 8b 04 00 00       	jmp    800817 <vprintfmt+0x4b6>
  80038c:	85 c0                	test   %eax,%eax
  80038e:	0f 84 83 04 00 00    	je     800817 <vprintfmt+0x4b6>
				return;
			putch(ch, putdat);
  800394:	83 ec 08             	sub    $0x8,%esp
  800397:	53                   	push   %ebx
  800398:	50                   	push   %eax
  800399:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80039b:	83 c6 01             	add    $0x1,%esi
  80039e:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  8003a2:	83 c4 10             	add    $0x10,%esp
  8003a5:	83 f8 25             	cmp    $0x25,%eax
  8003a8:	75 e2                	jne    80038c <vprintfmt+0x2b>
			padc = '-';
			goto reswitch;
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003aa:	c6 45 e3 20          	movb   $0x20,-0x1d(%ebp)
  8003ae:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8003b5:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003bc:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8003c3:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  8003ca:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003cf:	eb 07                	jmp    8003d8 <vprintfmt+0x77>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d1:	8b 75 10             	mov    0x10(%ebp),%esi

		// flag to show the sign
		case '+':
			padc='+';
  8003d4:	c6 45 e3 2b          	movb   $0x2b,-0x1d(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d8:	8d 46 01             	lea    0x1(%esi),%eax
  8003db:	89 45 10             	mov    %eax,0x10(%ebp)
  8003de:	0f b6 06             	movzbl (%esi),%eax
  8003e1:	0f b6 d0             	movzbl %al,%edx
  8003e4:	83 e8 23             	sub    $0x23,%eax
  8003e7:	3c 55                	cmp    $0x55,%al
  8003e9:	0f 87 e9 03 00 00    	ja     8007d8 <vprintfmt+0x477>
  8003ef:	0f b6 c0             	movzbl %al,%eax
  8003f2:	ff 24 85 ec 11 80 00 	jmp    *0x8011ec(,%eax,4)
  8003f9:	8b 75 10             	mov    0x10(%ebp),%esi
			padc='+';
			goto reswitch;
		
		// flag to pad on the right
		case '-':
			padc = '-';
  8003fc:	c6 45 e3 2d          	movb   $0x2d,-0x1d(%ebp)
  800400:	eb d6                	jmp    8003d8 <vprintfmt+0x77>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800402:	8d 42 d0             	lea    -0x30(%edx),%eax
  800405:	89 45 d0             	mov    %eax,-0x30(%ebp)
				ch = *fmt;
  800408:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  80040c:	8d 50 d0             	lea    -0x30(%eax),%edx
  80040f:	83 fa 09             	cmp    $0x9,%edx
  800412:	77 66                	ja     80047a <vprintfmt+0x119>
  800414:	8b 75 10             	mov    0x10(%ebp),%esi
  800417:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80041a:	89 7d 08             	mov    %edi,0x8(%ebp)
  80041d:	eb 09                	jmp    800428 <vprintfmt+0xc7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041f:	8b 75 10             	mov    0x10(%ebp),%esi
			padc = '-';
			goto reswitch;
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800422:	c6 45 e3 30          	movb   $0x30,-0x1d(%ebp)
			goto reswitch;
  800426:	eb b0                	jmp    8003d8 <vprintfmt+0x77>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800428:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  80042b:	8d 14 92             	lea    (%edx,%edx,4),%edx
  80042e:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  800432:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800435:	8d 78 d0             	lea    -0x30(%eax),%edi
  800438:	83 ff 09             	cmp    $0x9,%edi
  80043b:	76 eb                	jbe    800428 <vprintfmt+0xc7>
  80043d:	89 55 d0             	mov    %edx,-0x30(%ebp)
  800440:	8b 7d 08             	mov    0x8(%ebp),%edi
  800443:	eb 38                	jmp    80047d <vprintfmt+0x11c>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800445:	8b 45 14             	mov    0x14(%ebp),%eax
  800448:	8d 50 04             	lea    0x4(%eax),%edx
  80044b:	89 55 14             	mov    %edx,0x14(%ebp)
  80044e:	8b 00                	mov    (%eax),%eax
  800450:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800453:	8b 75 10             	mov    0x10(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800456:	eb 25                	jmp    80047d <vprintfmt+0x11c>
  800458:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80045b:	85 c0                	test   %eax,%eax
  80045d:	0f 48 c1             	cmovs  %ecx,%eax
  800460:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800463:	8b 75 10             	mov    0x10(%ebp),%esi
  800466:	e9 6d ff ff ff       	jmp    8003d8 <vprintfmt+0x77>
  80046b:	8b 75 10             	mov    0x10(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80046e:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800475:	e9 5e ff ff ff       	jmp    8003d8 <vprintfmt+0x77>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80047a:	8b 75 10             	mov    0x10(%ebp),%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80047d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800481:	0f 89 51 ff ff ff    	jns    8003d8 <vprintfmt+0x77>
				width = precision, precision = -1;
  800487:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80048a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80048d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800494:	e9 3f ff ff ff       	jmp    8003d8 <vprintfmt+0x77>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800499:	83 45 cc 01          	addl   $0x1,-0x34(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049d:	8b 75 10             	mov    0x10(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004a0:	e9 33 ff ff ff       	jmp    8003d8 <vprintfmt+0x77>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a8:	8d 50 04             	lea    0x4(%eax),%edx
  8004ab:	89 55 14             	mov    %edx,0x14(%ebp)
  8004ae:	83 ec 08             	sub    $0x8,%esp
  8004b1:	53                   	push   %ebx
  8004b2:	ff 30                	pushl  (%eax)
  8004b4:	ff d7                	call   *%edi
			break;
  8004b6:	83 c4 10             	add    $0x10,%esp
  8004b9:	e9 b7 fe ff ff       	jmp    800375 <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004be:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c1:	8d 50 04             	lea    0x4(%eax),%edx
  8004c4:	89 55 14             	mov    %edx,0x14(%ebp)
  8004c7:	8b 00                	mov    (%eax),%eax
  8004c9:	99                   	cltd   
  8004ca:	31 d0                	xor    %edx,%eax
  8004cc:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004ce:	83 f8 06             	cmp    $0x6,%eax
  8004d1:	7f 0b                	jg     8004de <vprintfmt+0x17d>
  8004d3:	8b 14 85 44 13 80 00 	mov    0x801344(,%eax,4),%edx
  8004da:	85 d2                	test   %edx,%edx
  8004dc:	75 15                	jne    8004f3 <vprintfmt+0x192>
				printfmt(putch, putdat, "error %d", err);
  8004de:	50                   	push   %eax
  8004df:	68 fb 10 80 00       	push   $0x8010fb
  8004e4:	53                   	push   %ebx
  8004e5:	57                   	push   %edi
  8004e6:	e8 59 fe ff ff       	call   800344 <printfmt>
  8004eb:	83 c4 10             	add    $0x10,%esp
  8004ee:	e9 82 fe ff ff       	jmp    800375 <vprintfmt+0x14>
			else
				printfmt(putch, putdat, "%s", p);
  8004f3:	52                   	push   %edx
  8004f4:	68 04 11 80 00       	push   $0x801104
  8004f9:	53                   	push   %ebx
  8004fa:	57                   	push   %edi
  8004fb:	e8 44 fe ff ff       	call   800344 <printfmt>
  800500:	83 c4 10             	add    $0x10,%esp
  800503:	e9 6d fe ff ff       	jmp    800375 <vprintfmt+0x14>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800508:	8b 45 14             	mov    0x14(%ebp),%eax
  80050b:	8d 50 04             	lea    0x4(%eax),%edx
  80050e:	89 55 14             	mov    %edx,0x14(%ebp)
  800511:	8b 00                	mov    (%eax),%eax
				p = "(null)";
  800513:	85 c0                	test   %eax,%eax
  800515:	b9 f4 10 80 00       	mov    $0x8010f4,%ecx
  80051a:	0f 45 c8             	cmovne %eax,%ecx
  80051d:	89 4d cc             	mov    %ecx,-0x34(%ebp)
			if (width > 0 && padc != '-')
  800520:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800524:	7e 06                	jle    80052c <vprintfmt+0x1cb>
  800526:	80 7d e3 2d          	cmpb   $0x2d,-0x1d(%ebp)
  80052a:	75 19                	jne    800545 <vprintfmt+0x1e4>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80052c:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80052f:	8d 70 01             	lea    0x1(%eax),%esi
  800532:	0f b6 00             	movzbl (%eax),%eax
  800535:	0f be d0             	movsbl %al,%edx
  800538:	85 d2                	test   %edx,%edx
  80053a:	0f 85 9f 00 00 00    	jne    8005df <vprintfmt+0x27e>
  800540:	e9 8c 00 00 00       	jmp    8005d1 <vprintfmt+0x270>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800545:	83 ec 08             	sub    $0x8,%esp
  800548:	ff 75 d0             	pushl  -0x30(%ebp)
  80054b:	ff 75 cc             	pushl  -0x34(%ebp)
  80054e:	e8 56 03 00 00       	call   8008a9 <strnlen>
  800553:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  800556:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800559:	83 c4 10             	add    $0x10,%esp
  80055c:	85 c9                	test   %ecx,%ecx
  80055e:	0f 8e 9a 02 00 00    	jle    8007fe <vprintfmt+0x49d>
					putch(padc, putdat);
  800564:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  800568:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80056b:	89 cb                	mov    %ecx,%ebx
  80056d:	83 ec 08             	sub    $0x8,%esp
  800570:	ff 75 0c             	pushl  0xc(%ebp)
  800573:	56                   	push   %esi
  800574:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800576:	83 c4 10             	add    $0x10,%esp
  800579:	83 eb 01             	sub    $0x1,%ebx
  80057c:	75 ef                	jne    80056d <vprintfmt+0x20c>
  80057e:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800581:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800584:	e9 75 02 00 00       	jmp    8007fe <vprintfmt+0x49d>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800589:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80058d:	74 1b                	je     8005aa <vprintfmt+0x249>
  80058f:	0f be c0             	movsbl %al,%eax
  800592:	83 e8 20             	sub    $0x20,%eax
  800595:	83 f8 5e             	cmp    $0x5e,%eax
  800598:	76 10                	jbe    8005aa <vprintfmt+0x249>
					putch('?', putdat);
  80059a:	83 ec 08             	sub    $0x8,%esp
  80059d:	ff 75 0c             	pushl  0xc(%ebp)
  8005a0:	6a 3f                	push   $0x3f
  8005a2:	ff 55 08             	call   *0x8(%ebp)
  8005a5:	83 c4 10             	add    $0x10,%esp
  8005a8:	eb 0d                	jmp    8005b7 <vprintfmt+0x256>
				else
					putch(ch, putdat);
  8005aa:	83 ec 08             	sub    $0x8,%esp
  8005ad:	ff 75 0c             	pushl  0xc(%ebp)
  8005b0:	52                   	push   %edx
  8005b1:	ff 55 08             	call   *0x8(%ebp)
  8005b4:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005b7:	83 ef 01             	sub    $0x1,%edi
  8005ba:	83 c6 01             	add    $0x1,%esi
  8005bd:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  8005c1:	0f be d0             	movsbl %al,%edx
  8005c4:	85 d2                	test   %edx,%edx
  8005c6:	75 31                	jne    8005f9 <vprintfmt+0x298>
  8005c8:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8005cb:	8b 7d 08             	mov    0x8(%ebp),%edi
  8005ce:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005d1:	8b 75 e4             	mov    -0x1c(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005d4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005d8:	7f 33                	jg     80060d <vprintfmt+0x2ac>
  8005da:	e9 96 fd ff ff       	jmp    800375 <vprintfmt+0x14>
  8005df:	89 7d 08             	mov    %edi,0x8(%ebp)
  8005e2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005e5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005e8:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8005eb:	eb 0c                	jmp    8005f9 <vprintfmt+0x298>
  8005ed:	89 7d 08             	mov    %edi,0x8(%ebp)
  8005f0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005f3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005f6:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005f9:	85 db                	test   %ebx,%ebx
  8005fb:	78 8c                	js     800589 <vprintfmt+0x228>
  8005fd:	83 eb 01             	sub    $0x1,%ebx
  800600:	79 87                	jns    800589 <vprintfmt+0x228>
  800602:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800605:	8b 7d 08             	mov    0x8(%ebp),%edi
  800608:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80060b:	eb c4                	jmp    8005d1 <vprintfmt+0x270>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80060d:	83 ec 08             	sub    $0x8,%esp
  800610:	53                   	push   %ebx
  800611:	6a 20                	push   $0x20
  800613:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800615:	83 c4 10             	add    $0x10,%esp
  800618:	83 ee 01             	sub    $0x1,%esi
  80061b:	75 f0                	jne    80060d <vprintfmt+0x2ac>
  80061d:	e9 53 fd ff ff       	jmp    800375 <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800622:	83 7d cc 01          	cmpl   $0x1,-0x34(%ebp)
  800626:	7e 16                	jle    80063e <vprintfmt+0x2dd>
		return va_arg(*ap, long long);
  800628:	8b 45 14             	mov    0x14(%ebp),%eax
  80062b:	8d 50 08             	lea    0x8(%eax),%edx
  80062e:	89 55 14             	mov    %edx,0x14(%ebp)
  800631:	8b 50 04             	mov    0x4(%eax),%edx
  800634:	8b 00                	mov    (%eax),%eax
  800636:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800639:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80063c:	eb 34                	jmp    800672 <vprintfmt+0x311>
	else if (lflag)
  80063e:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800642:	74 18                	je     80065c <vprintfmt+0x2fb>
		return va_arg(*ap, long);
  800644:	8b 45 14             	mov    0x14(%ebp),%eax
  800647:	8d 50 04             	lea    0x4(%eax),%edx
  80064a:	89 55 14             	mov    %edx,0x14(%ebp)
  80064d:	8b 30                	mov    (%eax),%esi
  80064f:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800652:	89 f0                	mov    %esi,%eax
  800654:	c1 f8 1f             	sar    $0x1f,%eax
  800657:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80065a:	eb 16                	jmp    800672 <vprintfmt+0x311>
	else
		return va_arg(*ap, int);
  80065c:	8b 45 14             	mov    0x14(%ebp),%eax
  80065f:	8d 50 04             	lea    0x4(%eax),%edx
  800662:	89 55 14             	mov    %edx,0x14(%ebp)
  800665:	8b 30                	mov    (%eax),%esi
  800667:	89 75 d0             	mov    %esi,-0x30(%ebp)
  80066a:	89 f0                	mov    %esi,%eax
  80066c:	c1 f8 1f             	sar    $0x1f,%eax
  80066f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800672:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800675:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800678:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80067b:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  80067e:	85 d2                	test   %edx,%edx
  800680:	79 28                	jns    8006aa <vprintfmt+0x349>
				putch('-', putdat);
  800682:	83 ec 08             	sub    $0x8,%esp
  800685:	53                   	push   %ebx
  800686:	6a 2d                	push   $0x2d
  800688:	ff d7                	call   *%edi
				num = -(long long) num;
  80068a:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80068d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800690:	f7 d8                	neg    %eax
  800692:	83 d2 00             	adc    $0x0,%edx
  800695:	f7 da                	neg    %edx
  800697:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80069a:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80069d:	83 c4 10             	add    $0x10,%esp
			else
			{
				if(padc=='+')
					putch('+', putdat);
			}
			base = 10;
  8006a0:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006a5:	e9 a5 00 00 00       	jmp    80074f <vprintfmt+0x3ee>
  8006aa:	b8 0a 00 00 00       	mov    $0xa,%eax
				putch('-', putdat);
				num = -(long long) num;
			}
			else
			{
				if(padc=='+')
  8006af:	80 7d e3 2b          	cmpb   $0x2b,-0x1d(%ebp)
  8006b3:	0f 85 96 00 00 00    	jne    80074f <vprintfmt+0x3ee>
					putch('+', putdat);
  8006b9:	83 ec 08             	sub    $0x8,%esp
  8006bc:	53                   	push   %ebx
  8006bd:	6a 2b                	push   $0x2b
  8006bf:	ff d7                	call   *%edi
  8006c1:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8006c4:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006c9:	e9 81 00 00 00       	jmp    80074f <vprintfmt+0x3ee>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006ce:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8006d1:	8d 45 14             	lea    0x14(%ebp),%eax
  8006d4:	e8 14 fc ff ff       	call   8002ed <getuint>
  8006d9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006dc:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  8006df:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8006e4:	eb 69                	jmp    80074f <vprintfmt+0x3ee>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			putch('0', putdat);
  8006e6:	83 ec 08             	sub    $0x8,%esp
  8006e9:	53                   	push   %ebx
  8006ea:	6a 30                	push   $0x30
  8006ec:	ff d7                	call   *%edi
			num = getuint(&ap, lflag);
  8006ee:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8006f1:	8d 45 14             	lea    0x14(%ebp),%eax
  8006f4:	e8 f4 fb ff ff       	call   8002ed <getuint>
  8006f9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006fc:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
			goto number;
  8006ff:	83 c4 10             	add    $0x10,%esp
		case 'o':
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
  800702:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800707:	eb 46                	jmp    80074f <vprintfmt+0x3ee>

		// pointer
		case 'p':
			putch('0', putdat);
  800709:	83 ec 08             	sub    $0x8,%esp
  80070c:	53                   	push   %ebx
  80070d:	6a 30                	push   $0x30
  80070f:	ff d7                	call   *%edi
			putch('x', putdat);
  800711:	83 c4 08             	add    $0x8,%esp
  800714:	53                   	push   %ebx
  800715:	6a 78                	push   $0x78
  800717:	ff d7                	call   *%edi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800719:	8b 45 14             	mov    0x14(%ebp),%eax
  80071c:	8d 50 04             	lea    0x4(%eax),%edx
  80071f:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800722:	8b 00                	mov    (%eax),%eax
  800724:	ba 00 00 00 00       	mov    $0x0,%edx
  800729:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80072c:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80072f:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800732:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800737:	eb 16                	jmp    80074f <vprintfmt+0x3ee>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800739:	8b 55 cc             	mov    -0x34(%ebp),%edx
  80073c:	8d 45 14             	lea    0x14(%ebp),%eax
  80073f:	e8 a9 fb ff ff       	call   8002ed <getuint>
  800744:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800747:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  80074a:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  80074f:	83 ec 0c             	sub    $0xc,%esp
  800752:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  800756:	56                   	push   %esi
  800757:	ff 75 e4             	pushl  -0x1c(%ebp)
  80075a:	50                   	push   %eax
  80075b:	ff 75 dc             	pushl  -0x24(%ebp)
  80075e:	ff 75 d8             	pushl  -0x28(%ebp)
  800761:	89 da                	mov    %ebx,%edx
  800763:	89 f8                	mov    %edi,%eax
  800765:	e8 e3 f9 ff ff       	call   80014d <printnum>
			break;
  80076a:	83 c4 20             	add    $0x20,%esp
  80076d:	e9 03 fc ff ff       	jmp    800375 <vprintfmt+0x14>

            const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
            const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

            // Your code here
			num=(unsigned long long)(uintptr_t)va_arg(ap, void *);
  800772:	8b 45 14             	mov    0x14(%ebp),%eax
  800775:	8d 50 04             	lea    0x4(%eax),%edx
  800778:	89 55 14             	mov    %edx,0x14(%ebp)
  80077b:	8b 00                	mov    (%eax),%eax
			if(!num)
  80077d:	85 c0                	test   %eax,%eax
  80077f:	75 1c                	jne    80079d <vprintfmt+0x43c>
				*(int *)putdat+=cprintf("%s",null_error);
  800781:	83 ec 08             	sub    $0x8,%esp
  800784:	68 70 11 80 00       	push   $0x801170
  800789:	68 04 11 80 00       	push   $0x801104
  80078e:	e8 a6 f9 ff ff       	call   800139 <cprintf>
  800793:	01 03                	add    %eax,(%ebx)
  800795:	83 c4 10             	add    $0x10,%esp
  800798:	e9 d8 fb ff ff       	jmp    800375 <vprintfmt+0x14>
			else
			{
				*(char *)(int)num=*(int *)putdat;
  80079d:	8b 13                	mov    (%ebx),%edx
  80079f:	88 10                	mov    %dl,(%eax)
				if((*(int *)putdat)>128)
  8007a1:	81 3b 80 00 00 00    	cmpl   $0x80,(%ebx)
  8007a7:	0f 8e c8 fb ff ff    	jle    800375 <vprintfmt+0x14>
					*(int *)putdat+=cprintf("%s",overflow_error);
  8007ad:	83 ec 08             	sub    $0x8,%esp
  8007b0:	68 a8 11 80 00       	push   $0x8011a8
  8007b5:	68 04 11 80 00       	push   $0x801104
  8007ba:	e8 7a f9 ff ff       	call   800139 <cprintf>
  8007bf:	01 03                	add    %eax,(%ebx)
  8007c1:	83 c4 10             	add    $0x10,%esp
  8007c4:	e9 ac fb ff ff       	jmp    800375 <vprintfmt+0x14>
            break;
        }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007c9:	83 ec 08             	sub    $0x8,%esp
  8007cc:	53                   	push   %ebx
  8007cd:	52                   	push   %edx
  8007ce:	ff d7                	call   *%edi
			break;
  8007d0:	83 c4 10             	add    $0x10,%esp
  8007d3:	e9 9d fb ff ff       	jmp    800375 <vprintfmt+0x14>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007d8:	83 ec 08             	sub    $0x8,%esp
  8007db:	53                   	push   %ebx
  8007dc:	6a 25                	push   $0x25
  8007de:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007e0:	83 c4 10             	add    $0x10,%esp
  8007e3:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8007e7:	0f 84 85 fb ff ff    	je     800372 <vprintfmt+0x11>
  8007ed:	83 ee 01             	sub    $0x1,%esi
  8007f0:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8007f4:	75 f7                	jne    8007ed <vprintfmt+0x48c>
  8007f6:	89 75 10             	mov    %esi,0x10(%ebp)
  8007f9:	e9 77 fb ff ff       	jmp    800375 <vprintfmt+0x14>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8007fe:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800801:	8d 70 01             	lea    0x1(%eax),%esi
  800804:	0f b6 00             	movzbl (%eax),%eax
  800807:	0f be d0             	movsbl %al,%edx
  80080a:	85 d2                	test   %edx,%edx
  80080c:	0f 85 db fd ff ff    	jne    8005ed <vprintfmt+0x28c>
  800812:	e9 5e fb ff ff       	jmp    800375 <vprintfmt+0x14>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800817:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80081a:	5b                   	pop    %ebx
  80081b:	5e                   	pop    %esi
  80081c:	5f                   	pop    %edi
  80081d:	5d                   	pop    %ebp
  80081e:	c3                   	ret    

0080081f <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80081f:	55                   	push   %ebp
  800820:	89 e5                	mov    %esp,%ebp
  800822:	83 ec 18             	sub    $0x18,%esp
  800825:	8b 45 08             	mov    0x8(%ebp),%eax
  800828:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80082b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80082e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800832:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800835:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80083c:	85 c0                	test   %eax,%eax
  80083e:	74 26                	je     800866 <vsnprintf+0x47>
  800840:	85 d2                	test   %edx,%edx
  800842:	7e 22                	jle    800866 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800844:	ff 75 14             	pushl  0x14(%ebp)
  800847:	ff 75 10             	pushl  0x10(%ebp)
  80084a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80084d:	50                   	push   %eax
  80084e:	68 27 03 80 00       	push   $0x800327
  800853:	e8 09 fb ff ff       	call   800361 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800858:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80085b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80085e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800861:	83 c4 10             	add    $0x10,%esp
  800864:	eb 05                	jmp    80086b <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800866:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80086b:	c9                   	leave  
  80086c:	c3                   	ret    

0080086d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80086d:	55                   	push   %ebp
  80086e:	89 e5                	mov    %esp,%ebp
  800870:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800873:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800876:	50                   	push   %eax
  800877:	ff 75 10             	pushl  0x10(%ebp)
  80087a:	ff 75 0c             	pushl  0xc(%ebp)
  80087d:	ff 75 08             	pushl  0x8(%ebp)
  800880:	e8 9a ff ff ff       	call   80081f <vsnprintf>
	va_end(ap);

	return rc;
}
  800885:	c9                   	leave  
  800886:	c3                   	ret    

00800887 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800887:	55                   	push   %ebp
  800888:	89 e5                	mov    %esp,%ebp
  80088a:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80088d:	80 3a 00             	cmpb   $0x0,(%edx)
  800890:	74 10                	je     8008a2 <strlen+0x1b>
  800892:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800897:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80089a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80089e:	75 f7                	jne    800897 <strlen+0x10>
  8008a0:	eb 05                	jmp    8008a7 <strlen+0x20>
  8008a2:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8008a7:	5d                   	pop    %ebp
  8008a8:	c3                   	ret    

008008a9 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008a9:	55                   	push   %ebp
  8008aa:	89 e5                	mov    %esp,%ebp
  8008ac:	53                   	push   %ebx
  8008ad:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8008b0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008b3:	85 c9                	test   %ecx,%ecx
  8008b5:	74 1c                	je     8008d3 <strnlen+0x2a>
  8008b7:	80 3b 00             	cmpb   $0x0,(%ebx)
  8008ba:	74 1e                	je     8008da <strnlen+0x31>
  8008bc:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  8008c1:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008c3:	39 ca                	cmp    %ecx,%edx
  8008c5:	74 18                	je     8008df <strnlen+0x36>
  8008c7:	83 c2 01             	add    $0x1,%edx
  8008ca:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  8008cf:	75 f0                	jne    8008c1 <strnlen+0x18>
  8008d1:	eb 0c                	jmp    8008df <strnlen+0x36>
  8008d3:	b8 00 00 00 00       	mov    $0x0,%eax
  8008d8:	eb 05                	jmp    8008df <strnlen+0x36>
  8008da:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8008df:	5b                   	pop    %ebx
  8008e0:	5d                   	pop    %ebp
  8008e1:	c3                   	ret    

008008e2 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008e2:	55                   	push   %ebp
  8008e3:	89 e5                	mov    %esp,%ebp
  8008e5:	53                   	push   %ebx
  8008e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008ec:	89 c2                	mov    %eax,%edx
  8008ee:	83 c2 01             	add    $0x1,%edx
  8008f1:	83 c1 01             	add    $0x1,%ecx
  8008f4:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8008f8:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008fb:	84 db                	test   %bl,%bl
  8008fd:	75 ef                	jne    8008ee <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8008ff:	5b                   	pop    %ebx
  800900:	5d                   	pop    %ebp
  800901:	c3                   	ret    

00800902 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800902:	55                   	push   %ebp
  800903:	89 e5                	mov    %esp,%ebp
  800905:	53                   	push   %ebx
  800906:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800909:	53                   	push   %ebx
  80090a:	e8 78 ff ff ff       	call   800887 <strlen>
  80090f:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800912:	ff 75 0c             	pushl  0xc(%ebp)
  800915:	01 d8                	add    %ebx,%eax
  800917:	50                   	push   %eax
  800918:	e8 c5 ff ff ff       	call   8008e2 <strcpy>
	return dst;
}
  80091d:	89 d8                	mov    %ebx,%eax
  80091f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800922:	c9                   	leave  
  800923:	c3                   	ret    

00800924 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800924:	55                   	push   %ebp
  800925:	89 e5                	mov    %esp,%ebp
  800927:	56                   	push   %esi
  800928:	53                   	push   %ebx
  800929:	8b 75 08             	mov    0x8(%ebp),%esi
  80092c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80092f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800932:	85 db                	test   %ebx,%ebx
  800934:	74 17                	je     80094d <strncpy+0x29>
  800936:	01 f3                	add    %esi,%ebx
  800938:	89 f1                	mov    %esi,%ecx
		*dst++ = *src;
  80093a:	83 c1 01             	add    $0x1,%ecx
  80093d:	0f b6 02             	movzbl (%edx),%eax
  800940:	88 41 ff             	mov    %al,-0x1(%ecx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800943:	80 3a 01             	cmpb   $0x1,(%edx)
  800946:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800949:	39 cb                	cmp    %ecx,%ebx
  80094b:	75 ed                	jne    80093a <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80094d:	89 f0                	mov    %esi,%eax
  80094f:	5b                   	pop    %ebx
  800950:	5e                   	pop    %esi
  800951:	5d                   	pop    %ebp
  800952:	c3                   	ret    

00800953 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800953:	55                   	push   %ebp
  800954:	89 e5                	mov    %esp,%ebp
  800956:	56                   	push   %esi
  800957:	53                   	push   %ebx
  800958:	8b 75 08             	mov    0x8(%ebp),%esi
  80095b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80095e:	8b 55 10             	mov    0x10(%ebp),%edx
  800961:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800963:	85 d2                	test   %edx,%edx
  800965:	74 35                	je     80099c <strlcpy+0x49>
		while (--size > 0 && *src != '\0')
  800967:	89 d0                	mov    %edx,%eax
  800969:	83 e8 01             	sub    $0x1,%eax
  80096c:	74 25                	je     800993 <strlcpy+0x40>
  80096e:	0f b6 0b             	movzbl (%ebx),%ecx
  800971:	84 c9                	test   %cl,%cl
  800973:	74 22                	je     800997 <strlcpy+0x44>
  800975:	8d 53 01             	lea    0x1(%ebx),%edx
  800978:	01 c3                	add    %eax,%ebx
  80097a:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
  80097c:	83 c0 01             	add    $0x1,%eax
  80097f:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800982:	39 da                	cmp    %ebx,%edx
  800984:	74 13                	je     800999 <strlcpy+0x46>
  800986:	83 c2 01             	add    $0x1,%edx
  800989:	0f b6 4a ff          	movzbl -0x1(%edx),%ecx
  80098d:	84 c9                	test   %cl,%cl
  80098f:	75 eb                	jne    80097c <strlcpy+0x29>
  800991:	eb 06                	jmp    800999 <strlcpy+0x46>
  800993:	89 f0                	mov    %esi,%eax
  800995:	eb 02                	jmp    800999 <strlcpy+0x46>
  800997:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800999:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80099c:	29 f0                	sub    %esi,%eax
}
  80099e:	5b                   	pop    %ebx
  80099f:	5e                   	pop    %esi
  8009a0:	5d                   	pop    %ebp
  8009a1:	c3                   	ret    

008009a2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009a2:	55                   	push   %ebp
  8009a3:	89 e5                	mov    %esp,%ebp
  8009a5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009a8:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009ab:	0f b6 01             	movzbl (%ecx),%eax
  8009ae:	84 c0                	test   %al,%al
  8009b0:	74 15                	je     8009c7 <strcmp+0x25>
  8009b2:	3a 02                	cmp    (%edx),%al
  8009b4:	75 11                	jne    8009c7 <strcmp+0x25>
		p++, q++;
  8009b6:	83 c1 01             	add    $0x1,%ecx
  8009b9:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8009bc:	0f b6 01             	movzbl (%ecx),%eax
  8009bf:	84 c0                	test   %al,%al
  8009c1:	74 04                	je     8009c7 <strcmp+0x25>
  8009c3:	3a 02                	cmp    (%edx),%al
  8009c5:	74 ef                	je     8009b6 <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009c7:	0f b6 c0             	movzbl %al,%eax
  8009ca:	0f b6 12             	movzbl (%edx),%edx
  8009cd:	29 d0                	sub    %edx,%eax
}
  8009cf:	5d                   	pop    %ebp
  8009d0:	c3                   	ret    

008009d1 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009d1:	55                   	push   %ebp
  8009d2:	89 e5                	mov    %esp,%ebp
  8009d4:	56                   	push   %esi
  8009d5:	53                   	push   %ebx
  8009d6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8009d9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009dc:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  8009df:	85 f6                	test   %esi,%esi
  8009e1:	74 29                	je     800a0c <strncmp+0x3b>
  8009e3:	0f b6 03             	movzbl (%ebx),%eax
  8009e6:	84 c0                	test   %al,%al
  8009e8:	74 30                	je     800a1a <strncmp+0x49>
  8009ea:	3a 02                	cmp    (%edx),%al
  8009ec:	75 2c                	jne    800a1a <strncmp+0x49>
  8009ee:	8d 43 01             	lea    0x1(%ebx),%eax
  8009f1:	01 de                	add    %ebx,%esi
		n--, p++, q++;
  8009f3:	89 c3                	mov    %eax,%ebx
  8009f5:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009f8:	39 c6                	cmp    %eax,%esi
  8009fa:	74 17                	je     800a13 <strncmp+0x42>
  8009fc:	0f b6 08             	movzbl (%eax),%ecx
  8009ff:	84 c9                	test   %cl,%cl
  800a01:	74 17                	je     800a1a <strncmp+0x49>
  800a03:	83 c0 01             	add    $0x1,%eax
  800a06:	3a 0a                	cmp    (%edx),%cl
  800a08:	74 e9                	je     8009f3 <strncmp+0x22>
  800a0a:	eb 0e                	jmp    800a1a <strncmp+0x49>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a0c:	b8 00 00 00 00       	mov    $0x0,%eax
  800a11:	eb 0f                	jmp    800a22 <strncmp+0x51>
  800a13:	b8 00 00 00 00       	mov    $0x0,%eax
  800a18:	eb 08                	jmp    800a22 <strncmp+0x51>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a1a:	0f b6 03             	movzbl (%ebx),%eax
  800a1d:	0f b6 12             	movzbl (%edx),%edx
  800a20:	29 d0                	sub    %edx,%eax
}
  800a22:	5b                   	pop    %ebx
  800a23:	5e                   	pop    %esi
  800a24:	5d                   	pop    %ebp
  800a25:	c3                   	ret    

00800a26 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a26:	55                   	push   %ebp
  800a27:	89 e5                	mov    %esp,%ebp
  800a29:	53                   	push   %ebx
  800a2a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a2d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
  800a30:	0f b6 10             	movzbl (%eax),%edx
  800a33:	84 d2                	test   %dl,%dl
  800a35:	74 1d                	je     800a54 <strchr+0x2e>
  800a37:	89 d9                	mov    %ebx,%ecx
		if (*s == c)
  800a39:	38 d3                	cmp    %dl,%bl
  800a3b:	75 06                	jne    800a43 <strchr+0x1d>
  800a3d:	eb 1a                	jmp    800a59 <strchr+0x33>
  800a3f:	38 ca                	cmp    %cl,%dl
  800a41:	74 16                	je     800a59 <strchr+0x33>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a43:	83 c0 01             	add    $0x1,%eax
  800a46:	0f b6 10             	movzbl (%eax),%edx
  800a49:	84 d2                	test   %dl,%dl
  800a4b:	75 f2                	jne    800a3f <strchr+0x19>
		if (*s == c)
			return (char *) s;
	return 0;
  800a4d:	b8 00 00 00 00       	mov    $0x0,%eax
  800a52:	eb 05                	jmp    800a59 <strchr+0x33>
  800a54:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a59:	5b                   	pop    %ebx
  800a5a:	5d                   	pop    %ebp
  800a5b:	c3                   	ret    

00800a5c <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a5c:	55                   	push   %ebp
  800a5d:	89 e5                	mov    %esp,%ebp
  800a5f:	53                   	push   %ebx
  800a60:	8b 45 08             	mov    0x8(%ebp),%eax
  800a63:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  800a66:	0f b6 18             	movzbl (%eax),%ebx
		if (*s == c)
  800a69:	38 d3                	cmp    %dl,%bl
  800a6b:	74 14                	je     800a81 <strfind+0x25>
  800a6d:	89 d1                	mov    %edx,%ecx
  800a6f:	84 db                	test   %bl,%bl
  800a71:	74 0e                	je     800a81 <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a73:	83 c0 01             	add    $0x1,%eax
  800a76:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a79:	38 ca                	cmp    %cl,%dl
  800a7b:	74 04                	je     800a81 <strfind+0x25>
  800a7d:	84 d2                	test   %dl,%dl
  800a7f:	75 f2                	jne    800a73 <strfind+0x17>
			break;
	return (char *) s;
}
  800a81:	5b                   	pop    %ebx
  800a82:	5d                   	pop    %ebp
  800a83:	c3                   	ret    

00800a84 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a84:	55                   	push   %ebp
  800a85:	89 e5                	mov    %esp,%ebp
  800a87:	57                   	push   %edi
  800a88:	56                   	push   %esi
  800a89:	53                   	push   %ebx
  800a8a:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a8d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a90:	85 c9                	test   %ecx,%ecx
  800a92:	74 36                	je     800aca <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a94:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a9a:	75 28                	jne    800ac4 <memset+0x40>
  800a9c:	f6 c1 03             	test   $0x3,%cl
  800a9f:	75 23                	jne    800ac4 <memset+0x40>
		c &= 0xFF;
  800aa1:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800aa5:	89 d3                	mov    %edx,%ebx
  800aa7:	c1 e3 08             	shl    $0x8,%ebx
  800aaa:	89 d6                	mov    %edx,%esi
  800aac:	c1 e6 18             	shl    $0x18,%esi
  800aaf:	89 d0                	mov    %edx,%eax
  800ab1:	c1 e0 10             	shl    $0x10,%eax
  800ab4:	09 f0                	or     %esi,%eax
  800ab6:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800ab8:	89 d8                	mov    %ebx,%eax
  800aba:	09 d0                	or     %edx,%eax
  800abc:	c1 e9 02             	shr    $0x2,%ecx
  800abf:	fc                   	cld    
  800ac0:	f3 ab                	rep stos %eax,%es:(%edi)
  800ac2:	eb 06                	jmp    800aca <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800ac4:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ac7:	fc                   	cld    
  800ac8:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800aca:	89 f8                	mov    %edi,%eax
  800acc:	5b                   	pop    %ebx
  800acd:	5e                   	pop    %esi
  800ace:	5f                   	pop    %edi
  800acf:	5d                   	pop    %ebp
  800ad0:	c3                   	ret    

00800ad1 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ad1:	55                   	push   %ebp
  800ad2:	89 e5                	mov    %esp,%ebp
  800ad4:	57                   	push   %edi
  800ad5:	56                   	push   %esi
  800ad6:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad9:	8b 75 0c             	mov    0xc(%ebp),%esi
  800adc:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800adf:	39 c6                	cmp    %eax,%esi
  800ae1:	73 35                	jae    800b18 <memmove+0x47>
  800ae3:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ae6:	39 d0                	cmp    %edx,%eax
  800ae8:	73 2e                	jae    800b18 <memmove+0x47>
		s += n;
		d += n;
  800aea:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800aed:	89 d6                	mov    %edx,%esi
  800aef:	09 fe                	or     %edi,%esi
  800af1:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800af7:	75 13                	jne    800b0c <memmove+0x3b>
  800af9:	f6 c1 03             	test   $0x3,%cl
  800afc:	75 0e                	jne    800b0c <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800afe:	83 ef 04             	sub    $0x4,%edi
  800b01:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b04:	c1 e9 02             	shr    $0x2,%ecx
  800b07:	fd                   	std    
  800b08:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b0a:	eb 09                	jmp    800b15 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b0c:	83 ef 01             	sub    $0x1,%edi
  800b0f:	8d 72 ff             	lea    -0x1(%edx),%esi
  800b12:	fd                   	std    
  800b13:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b15:	fc                   	cld    
  800b16:	eb 1d                	jmp    800b35 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b18:	89 f2                	mov    %esi,%edx
  800b1a:	09 c2                	or     %eax,%edx
  800b1c:	f6 c2 03             	test   $0x3,%dl
  800b1f:	75 0f                	jne    800b30 <memmove+0x5f>
  800b21:	f6 c1 03             	test   $0x3,%cl
  800b24:	75 0a                	jne    800b30 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800b26:	c1 e9 02             	shr    $0x2,%ecx
  800b29:	89 c7                	mov    %eax,%edi
  800b2b:	fc                   	cld    
  800b2c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b2e:	eb 05                	jmp    800b35 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b30:	89 c7                	mov    %eax,%edi
  800b32:	fc                   	cld    
  800b33:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b35:	5e                   	pop    %esi
  800b36:	5f                   	pop    %edi
  800b37:	5d                   	pop    %ebp
  800b38:	c3                   	ret    

00800b39 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800b39:	55                   	push   %ebp
  800b3a:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b3c:	ff 75 10             	pushl  0x10(%ebp)
  800b3f:	ff 75 0c             	pushl  0xc(%ebp)
  800b42:	ff 75 08             	pushl  0x8(%ebp)
  800b45:	e8 87 ff ff ff       	call   800ad1 <memmove>
}
  800b4a:	c9                   	leave  
  800b4b:	c3                   	ret    

00800b4c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b4c:	55                   	push   %ebp
  800b4d:	89 e5                	mov    %esp,%ebp
  800b4f:	57                   	push   %edi
  800b50:	56                   	push   %esi
  800b51:	53                   	push   %ebx
  800b52:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800b55:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b58:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b5b:	85 c0                	test   %eax,%eax
  800b5d:	74 39                	je     800b98 <memcmp+0x4c>
  800b5f:	8d 78 ff             	lea    -0x1(%eax),%edi
		if (*s1 != *s2)
  800b62:	0f b6 13             	movzbl (%ebx),%edx
  800b65:	0f b6 0e             	movzbl (%esi),%ecx
  800b68:	38 ca                	cmp    %cl,%dl
  800b6a:	75 17                	jne    800b83 <memcmp+0x37>
  800b6c:	b8 00 00 00 00       	mov    $0x0,%eax
  800b71:	eb 1a                	jmp    800b8d <memcmp+0x41>
  800b73:	0f b6 54 03 01       	movzbl 0x1(%ebx,%eax,1),%edx
  800b78:	83 c0 01             	add    $0x1,%eax
  800b7b:	0f b6 0c 06          	movzbl (%esi,%eax,1),%ecx
  800b7f:	38 ca                	cmp    %cl,%dl
  800b81:	74 0a                	je     800b8d <memcmp+0x41>
			return (int) *s1 - (int) *s2;
  800b83:	0f b6 c2             	movzbl %dl,%eax
  800b86:	0f b6 c9             	movzbl %cl,%ecx
  800b89:	29 c8                	sub    %ecx,%eax
  800b8b:	eb 10                	jmp    800b9d <memcmp+0x51>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b8d:	39 f8                	cmp    %edi,%eax
  800b8f:	75 e2                	jne    800b73 <memcmp+0x27>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b91:	b8 00 00 00 00       	mov    $0x0,%eax
  800b96:	eb 05                	jmp    800b9d <memcmp+0x51>
  800b98:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b9d:	5b                   	pop    %ebx
  800b9e:	5e                   	pop    %esi
  800b9f:	5f                   	pop    %edi
  800ba0:	5d                   	pop    %ebp
  800ba1:	c3                   	ret    

00800ba2 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ba2:	55                   	push   %ebp
  800ba3:	89 e5                	mov    %esp,%ebp
  800ba5:	53                   	push   %ebx
  800ba6:	8b 55 08             	mov    0x8(%ebp),%edx
	const void *ends = (const char *) s + n;
  800ba9:	89 d0                	mov    %edx,%eax
  800bab:	03 45 10             	add    0x10(%ebp),%eax
	for (; s < ends; s++)
  800bae:	39 c2                	cmp    %eax,%edx
  800bb0:	73 1d                	jae    800bcf <memfind+0x2d>
		if (*(const unsigned char *) s == (unsigned char) c)
  800bb2:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
  800bb6:	0f b6 0a             	movzbl (%edx),%ecx
  800bb9:	39 d9                	cmp    %ebx,%ecx
  800bbb:	75 09                	jne    800bc6 <memfind+0x24>
  800bbd:	eb 14                	jmp    800bd3 <memfind+0x31>
  800bbf:	0f b6 0a             	movzbl (%edx),%ecx
  800bc2:	39 d9                	cmp    %ebx,%ecx
  800bc4:	74 11                	je     800bd7 <memfind+0x35>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800bc6:	83 c2 01             	add    $0x1,%edx
  800bc9:	39 d0                	cmp    %edx,%eax
  800bcb:	75 f2                	jne    800bbf <memfind+0x1d>
  800bcd:	eb 0a                	jmp    800bd9 <memfind+0x37>
  800bcf:	89 d0                	mov    %edx,%eax
  800bd1:	eb 06                	jmp    800bd9 <memfind+0x37>
		if (*(const unsigned char *) s == (unsigned char) c)
  800bd3:	89 d0                	mov    %edx,%eax
  800bd5:	eb 02                	jmp    800bd9 <memfind+0x37>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800bd7:	89 d0                	mov    %edx,%eax
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800bd9:	5b                   	pop    %ebx
  800bda:	5d                   	pop    %ebp
  800bdb:	c3                   	ret    

00800bdc <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800bdc:	55                   	push   %ebp
  800bdd:	89 e5                	mov    %esp,%ebp
  800bdf:	57                   	push   %edi
  800be0:	56                   	push   %esi
  800be1:	53                   	push   %ebx
  800be2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800be5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800be8:	0f b6 01             	movzbl (%ecx),%eax
  800beb:	3c 20                	cmp    $0x20,%al
  800bed:	74 04                	je     800bf3 <strtol+0x17>
  800bef:	3c 09                	cmp    $0x9,%al
  800bf1:	75 0e                	jne    800c01 <strtol+0x25>
		s++;
  800bf3:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bf6:	0f b6 01             	movzbl (%ecx),%eax
  800bf9:	3c 20                	cmp    $0x20,%al
  800bfb:	74 f6                	je     800bf3 <strtol+0x17>
  800bfd:	3c 09                	cmp    $0x9,%al
  800bff:	74 f2                	je     800bf3 <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c01:	3c 2b                	cmp    $0x2b,%al
  800c03:	75 0a                	jne    800c0f <strtol+0x33>
		s++;
  800c05:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c08:	bf 00 00 00 00       	mov    $0x0,%edi
  800c0d:	eb 11                	jmp    800c20 <strtol+0x44>
  800c0f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c14:	3c 2d                	cmp    $0x2d,%al
  800c16:	75 08                	jne    800c20 <strtol+0x44>
		s++, neg = 1;
  800c18:	83 c1 01             	add    $0x1,%ecx
  800c1b:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c20:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c26:	75 15                	jne    800c3d <strtol+0x61>
  800c28:	80 39 30             	cmpb   $0x30,(%ecx)
  800c2b:	75 10                	jne    800c3d <strtol+0x61>
  800c2d:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c31:	75 7c                	jne    800caf <strtol+0xd3>
		s += 2, base = 16;
  800c33:	83 c1 02             	add    $0x2,%ecx
  800c36:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c3b:	eb 16                	jmp    800c53 <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  800c3d:	85 db                	test   %ebx,%ebx
  800c3f:	75 12                	jne    800c53 <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c41:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c46:	80 39 30             	cmpb   $0x30,(%ecx)
  800c49:	75 08                	jne    800c53 <strtol+0x77>
		s++, base = 8;
  800c4b:	83 c1 01             	add    $0x1,%ecx
  800c4e:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800c53:	b8 00 00 00 00       	mov    $0x0,%eax
  800c58:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c5b:	0f b6 11             	movzbl (%ecx),%edx
  800c5e:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c61:	89 f3                	mov    %esi,%ebx
  800c63:	80 fb 09             	cmp    $0x9,%bl
  800c66:	77 08                	ja     800c70 <strtol+0x94>
			dig = *s - '0';
  800c68:	0f be d2             	movsbl %dl,%edx
  800c6b:	83 ea 30             	sub    $0x30,%edx
  800c6e:	eb 22                	jmp    800c92 <strtol+0xb6>
		else if (*s >= 'a' && *s <= 'z')
  800c70:	8d 72 9f             	lea    -0x61(%edx),%esi
  800c73:	89 f3                	mov    %esi,%ebx
  800c75:	80 fb 19             	cmp    $0x19,%bl
  800c78:	77 08                	ja     800c82 <strtol+0xa6>
			dig = *s - 'a' + 10;
  800c7a:	0f be d2             	movsbl %dl,%edx
  800c7d:	83 ea 57             	sub    $0x57,%edx
  800c80:	eb 10                	jmp    800c92 <strtol+0xb6>
		else if (*s >= 'A' && *s <= 'Z')
  800c82:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c85:	89 f3                	mov    %esi,%ebx
  800c87:	80 fb 19             	cmp    $0x19,%bl
  800c8a:	77 16                	ja     800ca2 <strtol+0xc6>
			dig = *s - 'A' + 10;
  800c8c:	0f be d2             	movsbl %dl,%edx
  800c8f:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800c92:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c95:	7d 0b                	jge    800ca2 <strtol+0xc6>
			break;
		s++, val = (val * base) + dig;
  800c97:	83 c1 01             	add    $0x1,%ecx
  800c9a:	0f af 45 10          	imul   0x10(%ebp),%eax
  800c9e:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800ca0:	eb b9                	jmp    800c5b <strtol+0x7f>

	if (endptr)
  800ca2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ca6:	74 0d                	je     800cb5 <strtol+0xd9>
		*endptr = (char *) s;
  800ca8:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cab:	89 0e                	mov    %ecx,(%esi)
  800cad:	eb 06                	jmp    800cb5 <strtol+0xd9>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800caf:	85 db                	test   %ebx,%ebx
  800cb1:	74 98                	je     800c4b <strtol+0x6f>
  800cb3:	eb 9e                	jmp    800c53 <strtol+0x77>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800cb5:	89 c2                	mov    %eax,%edx
  800cb7:	f7 da                	neg    %edx
  800cb9:	85 ff                	test   %edi,%edi
  800cbb:	0f 45 c2             	cmovne %edx,%eax
}
  800cbe:	5b                   	pop    %ebx
  800cbf:	5e                   	pop    %esi
  800cc0:	5f                   	pop    %edi
  800cc1:	5d                   	pop    %ebp
  800cc2:	c3                   	ret    

00800cc3 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800cc3:	55                   	push   %ebp
  800cc4:	89 e5                	mov    %esp,%ebp
  800cc6:	57                   	push   %edi
  800cc7:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800cc8:	b8 00 00 00 00       	mov    $0x0,%eax
  800ccd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd0:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd3:	89 c3                	mov    %eax,%ebx
  800cd5:	89 c7                	mov    %eax,%edi
  800cd7:	51                   	push   %ecx
  800cd8:	52                   	push   %edx
  800cd9:	53                   	push   %ebx
  800cda:	54                   	push   %esp
  800cdb:	55                   	push   %ebp
  800cdc:	56                   	push   %esi
  800cdd:	57                   	push   %edi
  800cde:	5f                   	pop    %edi
  800cdf:	5e                   	pop    %esi
  800ce0:	5d                   	pop    %ebp
  800ce1:	5c                   	pop    %esp
  800ce2:	5b                   	pop    %ebx
  800ce3:	5a                   	pop    %edx
  800ce4:	59                   	pop    %ecx

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ce5:	5b                   	pop    %ebx
  800ce6:	5f                   	pop    %edi
  800ce7:	5d                   	pop    %ebp
  800ce8:	c3                   	ret    

00800ce9 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ce9:	55                   	push   %ebp
  800cea:	89 e5                	mov    %esp,%ebp
  800cec:	57                   	push   %edi
  800ced:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800cee:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cf3:	b8 01 00 00 00       	mov    $0x1,%eax
  800cf8:	89 ca                	mov    %ecx,%edx
  800cfa:	89 cb                	mov    %ecx,%ebx
  800cfc:	89 cf                	mov    %ecx,%edi
  800cfe:	51                   	push   %ecx
  800cff:	52                   	push   %edx
  800d00:	53                   	push   %ebx
  800d01:	54                   	push   %esp
  800d02:	55                   	push   %ebp
  800d03:	56                   	push   %esi
  800d04:	57                   	push   %edi
  800d05:	5f                   	pop    %edi
  800d06:	5e                   	pop    %esi
  800d07:	5d                   	pop    %ebp
  800d08:	5c                   	pop    %esp
  800d09:	5b                   	pop    %ebx
  800d0a:	5a                   	pop    %edx
  800d0b:	59                   	pop    %ecx

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800d0c:	5b                   	pop    %ebx
  800d0d:	5f                   	pop    %edi
  800d0e:	5d                   	pop    %ebp
  800d0f:	c3                   	ret    

00800d10 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800d10:	55                   	push   %ebp
  800d11:	89 e5                	mov    %esp,%ebp
  800d13:	57                   	push   %edi
  800d14:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800d15:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d1a:	b8 03 00 00 00       	mov    $0x3,%eax
  800d1f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d22:	89 d9                	mov    %ebx,%ecx
  800d24:	89 df                	mov    %ebx,%edi
  800d26:	51                   	push   %ecx
  800d27:	52                   	push   %edx
  800d28:	53                   	push   %ebx
  800d29:	54                   	push   %esp
  800d2a:	55                   	push   %ebp
  800d2b:	56                   	push   %esi
  800d2c:	57                   	push   %edi
  800d2d:	5f                   	pop    %edi
  800d2e:	5e                   	pop    %esi
  800d2f:	5d                   	pop    %ebp
  800d30:	5c                   	pop    %esp
  800d31:	5b                   	pop    %ebx
  800d32:	5a                   	pop    %edx
  800d33:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  800d34:	85 c0                	test   %eax,%eax
  800d36:	7e 17                	jle    800d4f <sys_env_destroy+0x3f>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d38:	83 ec 0c             	sub    $0xc,%esp
  800d3b:	50                   	push   %eax
  800d3c:	6a 03                	push   $0x3
  800d3e:	68 60 13 80 00       	push   $0x801360
  800d43:	6a 26                	push   $0x26
  800d45:	68 7d 13 80 00       	push   $0x80137d
  800d4a:	e8 7f 00 00 00       	call   800dce <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800d4f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800d52:	5b                   	pop    %ebx
  800d53:	5f                   	pop    %edi
  800d54:	5d                   	pop    %ebp
  800d55:	c3                   	ret    

00800d56 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d56:	55                   	push   %ebp
  800d57:	89 e5                	mov    %esp,%ebp
  800d59:	57                   	push   %edi
  800d5a:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800d5b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d60:	b8 02 00 00 00       	mov    $0x2,%eax
  800d65:	89 ca                	mov    %ecx,%edx
  800d67:	89 cb                	mov    %ecx,%ebx
  800d69:	89 cf                	mov    %ecx,%edi
  800d6b:	51                   	push   %ecx
  800d6c:	52                   	push   %edx
  800d6d:	53                   	push   %ebx
  800d6e:	54                   	push   %esp
  800d6f:	55                   	push   %ebp
  800d70:	56                   	push   %esi
  800d71:	57                   	push   %edi
  800d72:	5f                   	pop    %edi
  800d73:	5e                   	pop    %esi
  800d74:	5d                   	pop    %ebp
  800d75:	5c                   	pop    %esp
  800d76:	5b                   	pop    %ebx
  800d77:	5a                   	pop    %edx
  800d78:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d79:	5b                   	pop    %ebx
  800d7a:	5f                   	pop    %edi
  800d7b:	5d                   	pop    %ebp
  800d7c:	c3                   	ret    

00800d7d <sys_map_kernel_page>:

int
sys_map_kernel_page(void* kpage, void* va)
{
  800d7d:	55                   	push   %ebp
  800d7e:	89 e5                	mov    %esp,%ebp
  800d80:	57                   	push   %edi
  800d81:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800d82:	bf 00 00 00 00       	mov    $0x0,%edi
  800d87:	b8 04 00 00 00       	mov    $0x4,%eax
  800d8c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d8f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d92:	89 fb                	mov    %edi,%ebx
  800d94:	51                   	push   %ecx
  800d95:	52                   	push   %edx
  800d96:	53                   	push   %ebx
  800d97:	54                   	push   %esp
  800d98:	55                   	push   %ebp
  800d99:	56                   	push   %esi
  800d9a:	57                   	push   %edi
  800d9b:	5f                   	pop    %edi
  800d9c:	5e                   	pop    %esi
  800d9d:	5d                   	pop    %ebp
  800d9e:	5c                   	pop    %esp
  800d9f:	5b                   	pop    %ebx
  800da0:	5a                   	pop    %edx
  800da1:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  800da2:	5b                   	pop    %ebx
  800da3:	5f                   	pop    %edi
  800da4:	5d                   	pop    %ebp
  800da5:	c3                   	ret    

00800da6 <sys_sbrk>:

int
sys_sbrk(uint32_t inc)
{
  800da6:	55                   	push   %ebp
  800da7:	89 e5                	mov    %esp,%ebp
  800da9:	57                   	push   %edi
  800daa:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800dab:	b9 00 00 00 00       	mov    $0x0,%ecx
  800db0:	b8 05 00 00 00       	mov    $0x5,%eax
  800db5:	8b 55 08             	mov    0x8(%ebp),%edx
  800db8:	89 cb                	mov    %ecx,%ebx
  800dba:	89 cf                	mov    %ecx,%edi
  800dbc:	51                   	push   %ecx
  800dbd:	52                   	push   %edx
  800dbe:	53                   	push   %ebx
  800dbf:	54                   	push   %esp
  800dc0:	55                   	push   %ebp
  800dc1:	56                   	push   %esi
  800dc2:	57                   	push   %edi
  800dc3:	5f                   	pop    %edi
  800dc4:	5e                   	pop    %esi
  800dc5:	5d                   	pop    %ebp
  800dc6:	5c                   	pop    %esp
  800dc7:	5b                   	pop    %ebx
  800dc8:	5a                   	pop    %edx
  800dc9:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  800dca:	5b                   	pop    %ebx
  800dcb:	5f                   	pop    %edi
  800dcc:	5d                   	pop    %ebp
  800dcd:	c3                   	ret    

00800dce <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800dce:	55                   	push   %ebp
  800dcf:	89 e5                	mov    %esp,%ebp
  800dd1:	56                   	push   %esi
  800dd2:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800dd3:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	if (argv0)
  800dd6:	a1 08 20 80 00       	mov    0x802008,%eax
  800ddb:	85 c0                	test   %eax,%eax
  800ddd:	74 11                	je     800df0 <_panic+0x22>
		cprintf("%s: ", argv0);
  800ddf:	83 ec 08             	sub    $0x8,%esp
  800de2:	50                   	push   %eax
  800de3:	68 8b 13 80 00       	push   $0x80138b
  800de8:	e8 4c f3 ff ff       	call   800139 <cprintf>
  800ded:	83 c4 10             	add    $0x10,%esp
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800df0:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800df6:	e8 5b ff ff ff       	call   800d56 <sys_getenvid>
  800dfb:	83 ec 0c             	sub    $0xc,%esp
  800dfe:	ff 75 0c             	pushl  0xc(%ebp)
  800e01:	ff 75 08             	pushl  0x8(%ebp)
  800e04:	56                   	push   %esi
  800e05:	50                   	push   %eax
  800e06:	68 90 13 80 00       	push   $0x801390
  800e0b:	e8 29 f3 ff ff       	call   800139 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800e10:	83 c4 18             	add    $0x18,%esp
  800e13:	53                   	push   %ebx
  800e14:	ff 75 10             	pushl  0x10(%ebp)
  800e17:	e8 cc f2 ff ff       	call   8000e8 <vcprintf>
	cprintf("\n");
  800e1c:	c7 04 24 c0 10 80 00 	movl   $0x8010c0,(%esp)
  800e23:	e8 11 f3 ff ff       	call   800139 <cprintf>
  800e28:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800e2b:	cc                   	int3   
  800e2c:	eb fd                	jmp    800e2b <_panic+0x5d>
  800e2e:	66 90                	xchg   %ax,%ax

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
