
obj/user/breakpoint:     file format elf32-i386


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
  80002c:	e8 48 00 00 00       	call   800079 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 20             	sub    $0x20,%esp
	int a;
	a=10;
  800039:	c7 45 f4 0a 00 00 00 	movl   $0xa,-0xc(%ebp)
	cprintf("At first , a equals %d\n",a);
  800040:	6a 0a                	push   $0xa
  800042:	68 d4 10 80 00       	push   $0x8010d4
  800047:	e8 08 01 00 00       	call   800154 <cprintf>
	cprintf("&a equals 0x%x\n",&a);
  80004c:	83 c4 08             	add    $0x8,%esp
  80004f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800052:	50                   	push   %eax
  800053:	68 ec 10 80 00       	push   $0x8010ec
  800058:	e8 f7 00 00 00       	call   800154 <cprintf>
	asm volatile("int $3");
  80005d:	cc                   	int3   
	// Try single-step here
	a=20;
  80005e:	c7 45 f4 14 00 00 00 	movl   $0x14,-0xc(%ebp)
	cprintf("Finally , a equals %d\n",a);
  800065:	83 c4 08             	add    $0x8,%esp
  800068:	6a 14                	push   $0x14
  80006a:	68 fc 10 80 00       	push   $0x8010fc
  80006f:	e8 e0 00 00 00       	call   800154 <cprintf>
}
  800074:	83 c4 10             	add    $0x10,%esp
  800077:	c9                   	leave  
  800078:	c3                   	ret    

00800079 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800079:	55                   	push   %ebp
  80007a:	89 e5                	mov    %esp,%ebp
  80007c:	83 ec 08             	sub    $0x8,%esp
  80007f:	8b 45 08             	mov    0x8(%ebp),%eax
  800082:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800085:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  80008c:	00 00 00 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80008f:	85 c0                	test   %eax,%eax
  800091:	7e 08                	jle    80009b <libmain+0x22>
		binaryname = argv[0];
  800093:	8b 0a                	mov    (%edx),%ecx
  800095:	89 0d 00 20 80 00    	mov    %ecx,0x802000

	// call user main routine
	umain(argc, argv);
  80009b:	83 ec 08             	sub    $0x8,%esp
  80009e:	52                   	push   %edx
  80009f:	50                   	push   %eax
  8000a0:	e8 8e ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000a5:	e8 05 00 00 00       	call   8000af <exit>
}
  8000aa:	83 c4 10             	add    $0x10,%esp
  8000ad:	c9                   	leave  
  8000ae:	c3                   	ret    

008000af <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000af:	55                   	push   %ebp
  8000b0:	89 e5                	mov    %esp,%ebp
  8000b2:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000b5:	6a 00                	push   $0x0
  8000b7:	e8 6f 0c 00 00       	call   800d2b <sys_env_destroy>
}
  8000bc:	83 c4 10             	add    $0x10,%esp
  8000bf:	c9                   	leave  
  8000c0:	c3                   	ret    

008000c1 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000c1:	55                   	push   %ebp
  8000c2:	89 e5                	mov    %esp,%ebp
  8000c4:	53                   	push   %ebx
  8000c5:	83 ec 04             	sub    $0x4,%esp
  8000c8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000cb:	8b 13                	mov    (%ebx),%edx
  8000cd:	8d 42 01             	lea    0x1(%edx),%eax
  8000d0:	89 03                	mov    %eax,(%ebx)
  8000d2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000d5:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000d9:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000de:	75 1a                	jne    8000fa <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8000e0:	83 ec 08             	sub    $0x8,%esp
  8000e3:	68 ff 00 00 00       	push   $0xff
  8000e8:	8d 43 08             	lea    0x8(%ebx),%eax
  8000eb:	50                   	push   %eax
  8000ec:	e8 ed 0b 00 00       	call   800cde <sys_cputs>
		b->idx = 0;
  8000f1:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8000f7:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8000fa:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000fe:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800101:	c9                   	leave  
  800102:	c3                   	ret    

00800103 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800103:	55                   	push   %ebp
  800104:	89 e5                	mov    %esp,%ebp
  800106:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80010c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800113:	00 00 00 
	b.cnt = 0;
  800116:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80011d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800120:	ff 75 0c             	pushl  0xc(%ebp)
  800123:	ff 75 08             	pushl  0x8(%ebp)
  800126:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80012c:	50                   	push   %eax
  80012d:	68 c1 00 80 00       	push   $0x8000c1
  800132:	e8 45 02 00 00       	call   80037c <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800137:	83 c4 08             	add    $0x8,%esp
  80013a:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800140:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800146:	50                   	push   %eax
  800147:	e8 92 0b 00 00       	call   800cde <sys_cputs>

	return b.cnt;
}
  80014c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800152:	c9                   	leave  
  800153:	c3                   	ret    

00800154 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800154:	55                   	push   %ebp
  800155:	89 e5                	mov    %esp,%ebp
  800157:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80015a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80015d:	50                   	push   %eax
  80015e:	ff 75 08             	pushl  0x8(%ebp)
  800161:	e8 9d ff ff ff       	call   800103 <vcprintf>
	va_end(ap);

	return cnt;
}
  800166:	c9                   	leave  
  800167:	c3                   	ret    

00800168 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800168:	55                   	push   %ebp
  800169:	89 e5                	mov    %esp,%ebp
  80016b:	57                   	push   %edi
  80016c:	56                   	push   %esi
  80016d:	53                   	push   %ebx
  80016e:	83 ec 1c             	sub    $0x1c,%esp
  800171:	89 c7                	mov    %eax,%edi
  800173:	89 d6                	mov    %edx,%esi
  800175:	8b 45 08             	mov    0x8(%ebp),%eax
  800178:	8b 55 0c             	mov    0xc(%ebp),%edx
  80017b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80017e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	// if cprintf'parameter includes pattern of the form "%-", padding
	// space on the right side if neccesary.
	// you can add helper function if needed.
	// your code here:
	int length,showsign=0;
	if(padc=='-'&&num>=base)
  800181:	83 7d 18 2d          	cmpl   $0x2d,0x18(%ebp)
  800185:	0f 85 8a 00 00 00    	jne    800215 <printnum+0xad>
  80018b:	8b 45 10             	mov    0x10(%ebp),%eax
  80018e:	ba 00 00 00 00       	mov    $0x0,%edx
  800193:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800196:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800199:	39 da                	cmp    %ebx,%edx
  80019b:	72 09                	jb     8001a6 <printnum+0x3e>
  80019d:	39 4d 10             	cmp    %ecx,0x10(%ebp)
  8001a0:	0f 87 87 00 00 00    	ja     80022d <printnum+0xc5>
	{
		length=*(int *)putdat;
  8001a6:	8b 1e                	mov    (%esi),%ebx
		printnum(putch,putdat,num/base,base,0,padc);
  8001a8:	83 ec 0c             	sub    $0xc,%esp
  8001ab:	6a 2d                	push   $0x2d
  8001ad:	6a 00                	push   $0x0
  8001af:	ff 75 10             	pushl  0x10(%ebp)
  8001b2:	83 ec 08             	sub    $0x8,%esp
  8001b5:	52                   	push   %edx
  8001b6:	50                   	push   %eax
  8001b7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001ba:	ff 75 e0             	pushl  -0x20(%ebp)
  8001bd:	e8 8e 0c 00 00       	call   800e50 <__udivdi3>
  8001c2:	83 c4 18             	add    $0x18,%esp
  8001c5:	52                   	push   %edx
  8001c6:	50                   	push   %eax
  8001c7:	89 f2                	mov    %esi,%edx
  8001c9:	89 f8                	mov    %edi,%eax
  8001cb:	e8 98 ff ff ff       	call   800168 <printnum>
		while (--width > 0)
			putch(padc, putdat);
	}
	}
	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001d0:	83 c4 18             	add    $0x18,%esp
  8001d3:	56                   	push   %esi
  8001d4:	8b 45 10             	mov    0x10(%ebp),%eax
  8001d7:	ba 00 00 00 00       	mov    $0x0,%edx
  8001dc:	83 ec 04             	sub    $0x4,%esp
  8001df:	52                   	push   %edx
  8001e0:	50                   	push   %eax
  8001e1:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001e4:	ff 75 e0             	pushl  -0x20(%ebp)
  8001e7:	e8 94 0d 00 00       	call   800f80 <__umoddi3>
  8001ec:	83 c4 14             	add    $0x14,%esp
  8001ef:	0f be 80 1d 11 80 00 	movsbl 0x80111d(%eax),%eax
  8001f6:	50                   	push   %eax
  8001f7:	ff d7                	call   *%edi
	
	if(padc=='-'&&width>0)
  8001f9:	83 c4 10             	add    $0x10,%esp
  8001fc:	83 7d 18 2d          	cmpl   $0x2d,0x18(%ebp)
  800200:	0f 85 fa 00 00 00    	jne    800300 <printnum+0x198>
  800206:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
  80020a:	0f 8f 9b 00 00 00    	jg     8002ab <printnum+0x143>
  800210:	e9 eb 00 00 00       	jmp    800300 <printnum+0x198>
	}
	else
	{
	
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800215:	8b 45 10             	mov    0x10(%ebp),%eax
  800218:	ba 00 00 00 00       	mov    $0x0,%edx
  80021d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800220:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800223:	83 fb 00             	cmp    $0x0,%ebx
  800226:	77 14                	ja     80023c <printnum+0xd4>
  800228:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  80022b:	73 0f                	jae    80023c <printnum+0xd4>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80022d:	8b 45 14             	mov    0x14(%ebp),%eax
  800230:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800233:	85 db                	test   %ebx,%ebx
  800235:	7f 61                	jg     800298 <printnum+0x130>
  800237:	e9 98 00 00 00       	jmp    8002d4 <printnum+0x16c>
	else
	{
	
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80023c:	83 ec 0c             	sub    $0xc,%esp
  80023f:	ff 75 18             	pushl  0x18(%ebp)
  800242:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800245:	8d 59 ff             	lea    -0x1(%ecx),%ebx
  800248:	53                   	push   %ebx
  800249:	ff 75 10             	pushl  0x10(%ebp)
  80024c:	83 ec 08             	sub    $0x8,%esp
  80024f:	52                   	push   %edx
  800250:	50                   	push   %eax
  800251:	ff 75 e4             	pushl  -0x1c(%ebp)
  800254:	ff 75 e0             	pushl  -0x20(%ebp)
  800257:	e8 f4 0b 00 00       	call   800e50 <__udivdi3>
  80025c:	83 c4 18             	add    $0x18,%esp
  80025f:	52                   	push   %edx
  800260:	50                   	push   %eax
  800261:	89 f2                	mov    %esi,%edx
  800263:	89 f8                	mov    %edi,%eax
  800265:	e8 fe fe ff ff       	call   800168 <printnum>
		while (--width > 0)
			putch(padc, putdat);
	}
	}
	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80026a:	83 c4 18             	add    $0x18,%esp
  80026d:	56                   	push   %esi
  80026e:	8b 45 10             	mov    0x10(%ebp),%eax
  800271:	ba 00 00 00 00       	mov    $0x0,%edx
  800276:	83 ec 04             	sub    $0x4,%esp
  800279:	52                   	push   %edx
  80027a:	50                   	push   %eax
  80027b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80027e:	ff 75 e0             	pushl  -0x20(%ebp)
  800281:	e8 fa 0c 00 00       	call   800f80 <__umoddi3>
  800286:	83 c4 14             	add    $0x14,%esp
  800289:	0f be 80 1d 11 80 00 	movsbl 0x80111d(%eax),%eax
  800290:	50                   	push   %eax
  800291:	ff d7                	call   *%edi
  800293:	83 c4 10             	add    $0x10,%esp
  800296:	eb 68                	jmp    800300 <printnum+0x198>
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800298:	83 ec 08             	sub    $0x8,%esp
  80029b:	56                   	push   %esi
  80029c:	ff 75 18             	pushl  0x18(%ebp)
  80029f:	ff d7                	call   *%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002a1:	83 c4 10             	add    $0x10,%esp
  8002a4:	83 eb 01             	sub    $0x1,%ebx
  8002a7:	75 ef                	jne    800298 <printnum+0x130>
  8002a9:	eb 29                	jmp    8002d4 <printnum+0x16c>
	putch("0123456789abcdef"[num % base], putdat);
	
	if(padc=='-'&&width>0)
	{
		length=*(int *)putdat-length;
		for(int i=0;i<width-length;++i)
  8002ab:	8b 45 14             	mov    0x14(%ebp),%eax
  8002ae:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  8002b1:	2b 06                	sub    (%esi),%eax
  8002b3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002b6:	85 c0                	test   %eax,%eax
  8002b8:	7e 46                	jle    800300 <printnum+0x198>
  8002ba:	bb 00 00 00 00       	mov    $0x0,%ebx
			putch(' ',putdat);
  8002bf:	83 ec 08             	sub    $0x8,%esp
  8002c2:	56                   	push   %esi
  8002c3:	6a 20                	push   $0x20
  8002c5:	ff d7                	call   *%edi
	putch("0123456789abcdef"[num % base], putdat);
	
	if(padc=='-'&&width>0)
	{
		length=*(int *)putdat-length;
		for(int i=0;i<width-length;++i)
  8002c7:	83 c3 01             	add    $0x1,%ebx
  8002ca:	83 c4 10             	add    $0x10,%esp
  8002cd:	3b 5d e0             	cmp    -0x20(%ebp),%ebx
  8002d0:	75 ed                	jne    8002bf <printnum+0x157>
  8002d2:	eb 2c                	jmp    800300 <printnum+0x198>
		while (--width > 0)
			putch(padc, putdat);
	}
	}
	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002d4:	83 ec 08             	sub    $0x8,%esp
  8002d7:	56                   	push   %esi
  8002d8:	8b 45 10             	mov    0x10(%ebp),%eax
  8002db:	ba 00 00 00 00       	mov    $0x0,%edx
  8002e0:	83 ec 04             	sub    $0x4,%esp
  8002e3:	52                   	push   %edx
  8002e4:	50                   	push   %eax
  8002e5:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002e8:	ff 75 e0             	pushl  -0x20(%ebp)
  8002eb:	e8 90 0c 00 00       	call   800f80 <__umoddi3>
  8002f0:	83 c4 14             	add    $0x14,%esp
  8002f3:	0f be 80 1d 11 80 00 	movsbl 0x80111d(%eax),%eax
  8002fa:	50                   	push   %eax
  8002fb:	ff d7                	call   *%edi
  8002fd:	83 c4 10             	add    $0x10,%esp
	{
		length=*(int *)putdat-length;
		for(int i=0;i<width-length;++i)
			putch(' ',putdat);
	}
}
  800300:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800303:	5b                   	pop    %ebx
  800304:	5e                   	pop    %esi
  800305:	5f                   	pop    %edi
  800306:	5d                   	pop    %ebp
  800307:	c3                   	ret    

00800308 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800308:	55                   	push   %ebp
  800309:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80030b:	83 fa 01             	cmp    $0x1,%edx
  80030e:	7e 0e                	jle    80031e <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800310:	8b 10                	mov    (%eax),%edx
  800312:	8d 4a 08             	lea    0x8(%edx),%ecx
  800315:	89 08                	mov    %ecx,(%eax)
  800317:	8b 02                	mov    (%edx),%eax
  800319:	8b 52 04             	mov    0x4(%edx),%edx
  80031c:	eb 22                	jmp    800340 <getuint+0x38>
	else if (lflag)
  80031e:	85 d2                	test   %edx,%edx
  800320:	74 10                	je     800332 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800322:	8b 10                	mov    (%eax),%edx
  800324:	8d 4a 04             	lea    0x4(%edx),%ecx
  800327:	89 08                	mov    %ecx,(%eax)
  800329:	8b 02                	mov    (%edx),%eax
  80032b:	ba 00 00 00 00       	mov    $0x0,%edx
  800330:	eb 0e                	jmp    800340 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800332:	8b 10                	mov    (%eax),%edx
  800334:	8d 4a 04             	lea    0x4(%edx),%ecx
  800337:	89 08                	mov    %ecx,(%eax)
  800339:	8b 02                	mov    (%edx),%eax
  80033b:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800340:	5d                   	pop    %ebp
  800341:	c3                   	ret    

00800342 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800342:	55                   	push   %ebp
  800343:	89 e5                	mov    %esp,%ebp
  800345:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800348:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80034c:	8b 10                	mov    (%eax),%edx
  80034e:	3b 50 04             	cmp    0x4(%eax),%edx
  800351:	73 0a                	jae    80035d <sprintputch+0x1b>
		*b->buf++ = ch;
  800353:	8d 4a 01             	lea    0x1(%edx),%ecx
  800356:	89 08                	mov    %ecx,(%eax)
  800358:	8b 45 08             	mov    0x8(%ebp),%eax
  80035b:	88 02                	mov    %al,(%edx)
}
  80035d:	5d                   	pop    %ebp
  80035e:	c3                   	ret    

0080035f <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80035f:	55                   	push   %ebp
  800360:	89 e5                	mov    %esp,%ebp
  800362:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800365:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800368:	50                   	push   %eax
  800369:	ff 75 10             	pushl  0x10(%ebp)
  80036c:	ff 75 0c             	pushl  0xc(%ebp)
  80036f:	ff 75 08             	pushl  0x8(%ebp)
  800372:	e8 05 00 00 00       	call   80037c <vprintfmt>
	va_end(ap);
}
  800377:	83 c4 10             	add    $0x10,%esp
  80037a:	c9                   	leave  
  80037b:	c3                   	ret    

0080037c <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80037c:	55                   	push   %ebp
  80037d:	89 e5                	mov    %esp,%ebp
  80037f:	57                   	push   %edi
  800380:	56                   	push   %esi
  800381:	53                   	push   %ebx
  800382:	83 ec 2c             	sub    $0x2c,%esp
  800385:	8b 7d 08             	mov    0x8(%ebp),%edi
  800388:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80038b:	eb 03                	jmp    800390 <vprintfmt+0x14>
			break;
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
			for (fmt--; fmt[-1] != '%'; fmt--)
  80038d:	89 75 10             	mov    %esi,0x10(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800390:	8b 45 10             	mov    0x10(%ebp),%eax
  800393:	8d 70 01             	lea    0x1(%eax),%esi
  800396:	0f b6 00             	movzbl (%eax),%eax
  800399:	83 f8 25             	cmp    $0x25,%eax
  80039c:	74 27                	je     8003c5 <vprintfmt+0x49>
			if (ch == '\0')
  80039e:	85 c0                	test   %eax,%eax
  8003a0:	75 0d                	jne    8003af <vprintfmt+0x33>
  8003a2:	e9 8b 04 00 00       	jmp    800832 <vprintfmt+0x4b6>
  8003a7:	85 c0                	test   %eax,%eax
  8003a9:	0f 84 83 04 00 00    	je     800832 <vprintfmt+0x4b6>
				return;
			putch(ch, putdat);
  8003af:	83 ec 08             	sub    $0x8,%esp
  8003b2:	53                   	push   %ebx
  8003b3:	50                   	push   %eax
  8003b4:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003b6:	83 c6 01             	add    $0x1,%esi
  8003b9:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  8003bd:	83 c4 10             	add    $0x10,%esp
  8003c0:	83 f8 25             	cmp    $0x25,%eax
  8003c3:	75 e2                	jne    8003a7 <vprintfmt+0x2b>
			padc = '-';
			goto reswitch;
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003c5:	c6 45 e3 20          	movb   $0x20,-0x1d(%ebp)
  8003c9:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8003d0:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003d7:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8003de:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  8003e5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003ea:	eb 07                	jmp    8003f3 <vprintfmt+0x77>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ec:	8b 75 10             	mov    0x10(%ebp),%esi

		// flag to show the sign
		case '+':
			padc='+';
  8003ef:	c6 45 e3 2b          	movb   $0x2b,-0x1d(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f3:	8d 46 01             	lea    0x1(%esi),%eax
  8003f6:	89 45 10             	mov    %eax,0x10(%ebp)
  8003f9:	0f b6 06             	movzbl (%esi),%eax
  8003fc:	0f b6 d0             	movzbl %al,%edx
  8003ff:	83 e8 23             	sub    $0x23,%eax
  800402:	3c 55                	cmp    $0x55,%al
  800404:	0f 87 e9 03 00 00    	ja     8007f3 <vprintfmt+0x477>
  80040a:	0f b6 c0             	movzbl %al,%eax
  80040d:	ff 24 85 28 12 80 00 	jmp    *0x801228(,%eax,4)
  800414:	8b 75 10             	mov    0x10(%ebp),%esi
			padc='+';
			goto reswitch;
		
		// flag to pad on the right
		case '-':
			padc = '-';
  800417:	c6 45 e3 2d          	movb   $0x2d,-0x1d(%ebp)
  80041b:	eb d6                	jmp    8003f3 <vprintfmt+0x77>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80041d:	8d 42 d0             	lea    -0x30(%edx),%eax
  800420:	89 45 d0             	mov    %eax,-0x30(%ebp)
				ch = *fmt;
  800423:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  800427:	8d 50 d0             	lea    -0x30(%eax),%edx
  80042a:	83 fa 09             	cmp    $0x9,%edx
  80042d:	77 66                	ja     800495 <vprintfmt+0x119>
  80042f:	8b 75 10             	mov    0x10(%ebp),%esi
  800432:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800435:	89 7d 08             	mov    %edi,0x8(%ebp)
  800438:	eb 09                	jmp    800443 <vprintfmt+0xc7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043a:	8b 75 10             	mov    0x10(%ebp),%esi
			padc = '-';
			goto reswitch;
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80043d:	c6 45 e3 30          	movb   $0x30,-0x1d(%ebp)
			goto reswitch;
  800441:	eb b0                	jmp    8003f3 <vprintfmt+0x77>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800443:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  800446:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800449:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  80044d:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800450:	8d 78 d0             	lea    -0x30(%eax),%edi
  800453:	83 ff 09             	cmp    $0x9,%edi
  800456:	76 eb                	jbe    800443 <vprintfmt+0xc7>
  800458:	89 55 d0             	mov    %edx,-0x30(%ebp)
  80045b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80045e:	eb 38                	jmp    800498 <vprintfmt+0x11c>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800460:	8b 45 14             	mov    0x14(%ebp),%eax
  800463:	8d 50 04             	lea    0x4(%eax),%edx
  800466:	89 55 14             	mov    %edx,0x14(%ebp)
  800469:	8b 00                	mov    (%eax),%eax
  80046b:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046e:	8b 75 10             	mov    0x10(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800471:	eb 25                	jmp    800498 <vprintfmt+0x11c>
  800473:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800476:	85 c0                	test   %eax,%eax
  800478:	0f 48 c1             	cmovs  %ecx,%eax
  80047b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80047e:	8b 75 10             	mov    0x10(%ebp),%esi
  800481:	e9 6d ff ff ff       	jmp    8003f3 <vprintfmt+0x77>
  800486:	8b 75 10             	mov    0x10(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800489:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800490:	e9 5e ff ff ff       	jmp    8003f3 <vprintfmt+0x77>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800495:	8b 75 10             	mov    0x10(%ebp),%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800498:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80049c:	0f 89 51 ff ff ff    	jns    8003f3 <vprintfmt+0x77>
				width = precision, precision = -1;
  8004a2:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8004a5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004a8:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8004af:	e9 3f ff ff ff       	jmp    8003f3 <vprintfmt+0x77>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004b4:	83 45 cc 01          	addl   $0x1,-0x34(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b8:	8b 75 10             	mov    0x10(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004bb:	e9 33 ff ff ff       	jmp    8003f3 <vprintfmt+0x77>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004c0:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c3:	8d 50 04             	lea    0x4(%eax),%edx
  8004c6:	89 55 14             	mov    %edx,0x14(%ebp)
  8004c9:	83 ec 08             	sub    $0x8,%esp
  8004cc:	53                   	push   %ebx
  8004cd:	ff 30                	pushl  (%eax)
  8004cf:	ff d7                	call   *%edi
			break;
  8004d1:	83 c4 10             	add    $0x10,%esp
  8004d4:	e9 b7 fe ff ff       	jmp    800390 <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004d9:	8b 45 14             	mov    0x14(%ebp),%eax
  8004dc:	8d 50 04             	lea    0x4(%eax),%edx
  8004df:	89 55 14             	mov    %edx,0x14(%ebp)
  8004e2:	8b 00                	mov    (%eax),%eax
  8004e4:	99                   	cltd   
  8004e5:	31 d0                	xor    %edx,%eax
  8004e7:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004e9:	83 f8 06             	cmp    $0x6,%eax
  8004ec:	7f 0b                	jg     8004f9 <vprintfmt+0x17d>
  8004ee:	8b 14 85 80 13 80 00 	mov    0x801380(,%eax,4),%edx
  8004f5:	85 d2                	test   %edx,%edx
  8004f7:	75 15                	jne    80050e <vprintfmt+0x192>
				printfmt(putch, putdat, "error %d", err);
  8004f9:	50                   	push   %eax
  8004fa:	68 35 11 80 00       	push   $0x801135
  8004ff:	53                   	push   %ebx
  800500:	57                   	push   %edi
  800501:	e8 59 fe ff ff       	call   80035f <printfmt>
  800506:	83 c4 10             	add    $0x10,%esp
  800509:	e9 82 fe ff ff       	jmp    800390 <vprintfmt+0x14>
			else
				printfmt(putch, putdat, "%s", p);
  80050e:	52                   	push   %edx
  80050f:	68 3e 11 80 00       	push   $0x80113e
  800514:	53                   	push   %ebx
  800515:	57                   	push   %edi
  800516:	e8 44 fe ff ff       	call   80035f <printfmt>
  80051b:	83 c4 10             	add    $0x10,%esp
  80051e:	e9 6d fe ff ff       	jmp    800390 <vprintfmt+0x14>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800523:	8b 45 14             	mov    0x14(%ebp),%eax
  800526:	8d 50 04             	lea    0x4(%eax),%edx
  800529:	89 55 14             	mov    %edx,0x14(%ebp)
  80052c:	8b 00                	mov    (%eax),%eax
				p = "(null)";
  80052e:	85 c0                	test   %eax,%eax
  800530:	b9 2e 11 80 00       	mov    $0x80112e,%ecx
  800535:	0f 45 c8             	cmovne %eax,%ecx
  800538:	89 4d cc             	mov    %ecx,-0x34(%ebp)
			if (width > 0 && padc != '-')
  80053b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80053f:	7e 06                	jle    800547 <vprintfmt+0x1cb>
  800541:	80 7d e3 2d          	cmpb   $0x2d,-0x1d(%ebp)
  800545:	75 19                	jne    800560 <vprintfmt+0x1e4>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800547:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80054a:	8d 70 01             	lea    0x1(%eax),%esi
  80054d:	0f b6 00             	movzbl (%eax),%eax
  800550:	0f be d0             	movsbl %al,%edx
  800553:	85 d2                	test   %edx,%edx
  800555:	0f 85 9f 00 00 00    	jne    8005fa <vprintfmt+0x27e>
  80055b:	e9 8c 00 00 00       	jmp    8005ec <vprintfmt+0x270>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800560:	83 ec 08             	sub    $0x8,%esp
  800563:	ff 75 d0             	pushl  -0x30(%ebp)
  800566:	ff 75 cc             	pushl  -0x34(%ebp)
  800569:	e8 56 03 00 00       	call   8008c4 <strnlen>
  80056e:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  800571:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800574:	83 c4 10             	add    $0x10,%esp
  800577:	85 c9                	test   %ecx,%ecx
  800579:	0f 8e 9a 02 00 00    	jle    800819 <vprintfmt+0x49d>
					putch(padc, putdat);
  80057f:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  800583:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800586:	89 cb                	mov    %ecx,%ebx
  800588:	83 ec 08             	sub    $0x8,%esp
  80058b:	ff 75 0c             	pushl  0xc(%ebp)
  80058e:	56                   	push   %esi
  80058f:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800591:	83 c4 10             	add    $0x10,%esp
  800594:	83 eb 01             	sub    $0x1,%ebx
  800597:	75 ef                	jne    800588 <vprintfmt+0x20c>
  800599:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80059c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80059f:	e9 75 02 00 00       	jmp    800819 <vprintfmt+0x49d>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005a4:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005a8:	74 1b                	je     8005c5 <vprintfmt+0x249>
  8005aa:	0f be c0             	movsbl %al,%eax
  8005ad:	83 e8 20             	sub    $0x20,%eax
  8005b0:	83 f8 5e             	cmp    $0x5e,%eax
  8005b3:	76 10                	jbe    8005c5 <vprintfmt+0x249>
					putch('?', putdat);
  8005b5:	83 ec 08             	sub    $0x8,%esp
  8005b8:	ff 75 0c             	pushl  0xc(%ebp)
  8005bb:	6a 3f                	push   $0x3f
  8005bd:	ff 55 08             	call   *0x8(%ebp)
  8005c0:	83 c4 10             	add    $0x10,%esp
  8005c3:	eb 0d                	jmp    8005d2 <vprintfmt+0x256>
				else
					putch(ch, putdat);
  8005c5:	83 ec 08             	sub    $0x8,%esp
  8005c8:	ff 75 0c             	pushl  0xc(%ebp)
  8005cb:	52                   	push   %edx
  8005cc:	ff 55 08             	call   *0x8(%ebp)
  8005cf:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005d2:	83 ef 01             	sub    $0x1,%edi
  8005d5:	83 c6 01             	add    $0x1,%esi
  8005d8:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  8005dc:	0f be d0             	movsbl %al,%edx
  8005df:	85 d2                	test   %edx,%edx
  8005e1:	75 31                	jne    800614 <vprintfmt+0x298>
  8005e3:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8005e6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8005e9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005ec:	8b 75 e4             	mov    -0x1c(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005ef:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005f3:	7f 33                	jg     800628 <vprintfmt+0x2ac>
  8005f5:	e9 96 fd ff ff       	jmp    800390 <vprintfmt+0x14>
  8005fa:	89 7d 08             	mov    %edi,0x8(%ebp)
  8005fd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800600:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800603:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800606:	eb 0c                	jmp    800614 <vprintfmt+0x298>
  800608:	89 7d 08             	mov    %edi,0x8(%ebp)
  80060b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80060e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800611:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800614:	85 db                	test   %ebx,%ebx
  800616:	78 8c                	js     8005a4 <vprintfmt+0x228>
  800618:	83 eb 01             	sub    $0x1,%ebx
  80061b:	79 87                	jns    8005a4 <vprintfmt+0x228>
  80061d:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800620:	8b 7d 08             	mov    0x8(%ebp),%edi
  800623:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800626:	eb c4                	jmp    8005ec <vprintfmt+0x270>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800628:	83 ec 08             	sub    $0x8,%esp
  80062b:	53                   	push   %ebx
  80062c:	6a 20                	push   $0x20
  80062e:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800630:	83 c4 10             	add    $0x10,%esp
  800633:	83 ee 01             	sub    $0x1,%esi
  800636:	75 f0                	jne    800628 <vprintfmt+0x2ac>
  800638:	e9 53 fd ff ff       	jmp    800390 <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80063d:	83 7d cc 01          	cmpl   $0x1,-0x34(%ebp)
  800641:	7e 16                	jle    800659 <vprintfmt+0x2dd>
		return va_arg(*ap, long long);
  800643:	8b 45 14             	mov    0x14(%ebp),%eax
  800646:	8d 50 08             	lea    0x8(%eax),%edx
  800649:	89 55 14             	mov    %edx,0x14(%ebp)
  80064c:	8b 50 04             	mov    0x4(%eax),%edx
  80064f:	8b 00                	mov    (%eax),%eax
  800651:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800654:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800657:	eb 34                	jmp    80068d <vprintfmt+0x311>
	else if (lflag)
  800659:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  80065d:	74 18                	je     800677 <vprintfmt+0x2fb>
		return va_arg(*ap, long);
  80065f:	8b 45 14             	mov    0x14(%ebp),%eax
  800662:	8d 50 04             	lea    0x4(%eax),%edx
  800665:	89 55 14             	mov    %edx,0x14(%ebp)
  800668:	8b 30                	mov    (%eax),%esi
  80066a:	89 75 d0             	mov    %esi,-0x30(%ebp)
  80066d:	89 f0                	mov    %esi,%eax
  80066f:	c1 f8 1f             	sar    $0x1f,%eax
  800672:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800675:	eb 16                	jmp    80068d <vprintfmt+0x311>
	else
		return va_arg(*ap, int);
  800677:	8b 45 14             	mov    0x14(%ebp),%eax
  80067a:	8d 50 04             	lea    0x4(%eax),%edx
  80067d:	89 55 14             	mov    %edx,0x14(%ebp)
  800680:	8b 30                	mov    (%eax),%esi
  800682:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800685:	89 f0                	mov    %esi,%eax
  800687:	c1 f8 1f             	sar    $0x1f,%eax
  80068a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80068d:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800690:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800693:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800696:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  800699:	85 d2                	test   %edx,%edx
  80069b:	79 28                	jns    8006c5 <vprintfmt+0x349>
				putch('-', putdat);
  80069d:	83 ec 08             	sub    $0x8,%esp
  8006a0:	53                   	push   %ebx
  8006a1:	6a 2d                	push   $0x2d
  8006a3:	ff d7                	call   *%edi
				num = -(long long) num;
  8006a5:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8006a8:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8006ab:	f7 d8                	neg    %eax
  8006ad:	83 d2 00             	adc    $0x0,%edx
  8006b0:	f7 da                	neg    %edx
  8006b2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006b5:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006b8:	83 c4 10             	add    $0x10,%esp
			else
			{
				if(padc=='+')
					putch('+', putdat);
			}
			base = 10;
  8006bb:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006c0:	e9 a5 00 00 00       	jmp    80076a <vprintfmt+0x3ee>
  8006c5:	b8 0a 00 00 00       	mov    $0xa,%eax
				putch('-', putdat);
				num = -(long long) num;
			}
			else
			{
				if(padc=='+')
  8006ca:	80 7d e3 2b          	cmpb   $0x2b,-0x1d(%ebp)
  8006ce:	0f 85 96 00 00 00    	jne    80076a <vprintfmt+0x3ee>
					putch('+', putdat);
  8006d4:	83 ec 08             	sub    $0x8,%esp
  8006d7:	53                   	push   %ebx
  8006d8:	6a 2b                	push   $0x2b
  8006da:	ff d7                	call   *%edi
  8006dc:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8006df:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006e4:	e9 81 00 00 00       	jmp    80076a <vprintfmt+0x3ee>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006e9:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8006ec:	8d 45 14             	lea    0x14(%ebp),%eax
  8006ef:	e8 14 fc ff ff       	call   800308 <getuint>
  8006f4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006f7:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  8006fa:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8006ff:	eb 69                	jmp    80076a <vprintfmt+0x3ee>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			putch('0', putdat);
  800701:	83 ec 08             	sub    $0x8,%esp
  800704:	53                   	push   %ebx
  800705:	6a 30                	push   $0x30
  800707:	ff d7                	call   *%edi
			num = getuint(&ap, lflag);
  800709:	8b 55 cc             	mov    -0x34(%ebp),%edx
  80070c:	8d 45 14             	lea    0x14(%ebp),%eax
  80070f:	e8 f4 fb ff ff       	call   800308 <getuint>
  800714:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800717:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
			goto number;
  80071a:	83 c4 10             	add    $0x10,%esp
		case 'o':
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
  80071d:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800722:	eb 46                	jmp    80076a <vprintfmt+0x3ee>

		// pointer
		case 'p':
			putch('0', putdat);
  800724:	83 ec 08             	sub    $0x8,%esp
  800727:	53                   	push   %ebx
  800728:	6a 30                	push   $0x30
  80072a:	ff d7                	call   *%edi
			putch('x', putdat);
  80072c:	83 c4 08             	add    $0x8,%esp
  80072f:	53                   	push   %ebx
  800730:	6a 78                	push   $0x78
  800732:	ff d7                	call   *%edi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800734:	8b 45 14             	mov    0x14(%ebp),%eax
  800737:	8d 50 04             	lea    0x4(%eax),%edx
  80073a:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80073d:	8b 00                	mov    (%eax),%eax
  80073f:	ba 00 00 00 00       	mov    $0x0,%edx
  800744:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800747:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80074a:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80074d:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800752:	eb 16                	jmp    80076a <vprintfmt+0x3ee>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800754:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800757:	8d 45 14             	lea    0x14(%ebp),%eax
  80075a:	e8 a9 fb ff ff       	call   800308 <getuint>
  80075f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800762:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  800765:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  80076a:	83 ec 0c             	sub    $0xc,%esp
  80076d:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  800771:	56                   	push   %esi
  800772:	ff 75 e4             	pushl  -0x1c(%ebp)
  800775:	50                   	push   %eax
  800776:	ff 75 dc             	pushl  -0x24(%ebp)
  800779:	ff 75 d8             	pushl  -0x28(%ebp)
  80077c:	89 da                	mov    %ebx,%edx
  80077e:	89 f8                	mov    %edi,%eax
  800780:	e8 e3 f9 ff ff       	call   800168 <printnum>
			break;
  800785:	83 c4 20             	add    $0x20,%esp
  800788:	e9 03 fc ff ff       	jmp    800390 <vprintfmt+0x14>

            const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
            const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

            // Your code here
			num=(unsigned long long)(uintptr_t)va_arg(ap, void *);
  80078d:	8b 45 14             	mov    0x14(%ebp),%eax
  800790:	8d 50 04             	lea    0x4(%eax),%edx
  800793:	89 55 14             	mov    %edx,0x14(%ebp)
  800796:	8b 00                	mov    (%eax),%eax
			if(!num)
  800798:	85 c0                	test   %eax,%eax
  80079a:	75 1c                	jne    8007b8 <vprintfmt+0x43c>
				*(int *)putdat+=cprintf("%s",null_error);
  80079c:	83 ec 08             	sub    $0x8,%esp
  80079f:	68 ac 11 80 00       	push   $0x8011ac
  8007a4:	68 3e 11 80 00       	push   $0x80113e
  8007a9:	e8 a6 f9 ff ff       	call   800154 <cprintf>
  8007ae:	01 03                	add    %eax,(%ebx)
  8007b0:	83 c4 10             	add    $0x10,%esp
  8007b3:	e9 d8 fb ff ff       	jmp    800390 <vprintfmt+0x14>
			else
			{
				*(char *)(int)num=*(int *)putdat;
  8007b8:	8b 13                	mov    (%ebx),%edx
  8007ba:	88 10                	mov    %dl,(%eax)
				if((*(int *)putdat)>128)
  8007bc:	81 3b 80 00 00 00    	cmpl   $0x80,(%ebx)
  8007c2:	0f 8e c8 fb ff ff    	jle    800390 <vprintfmt+0x14>
					*(int *)putdat+=cprintf("%s",overflow_error);
  8007c8:	83 ec 08             	sub    $0x8,%esp
  8007cb:	68 e4 11 80 00       	push   $0x8011e4
  8007d0:	68 3e 11 80 00       	push   $0x80113e
  8007d5:	e8 7a f9 ff ff       	call   800154 <cprintf>
  8007da:	01 03                	add    %eax,(%ebx)
  8007dc:	83 c4 10             	add    $0x10,%esp
  8007df:	e9 ac fb ff ff       	jmp    800390 <vprintfmt+0x14>
            break;
        }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007e4:	83 ec 08             	sub    $0x8,%esp
  8007e7:	53                   	push   %ebx
  8007e8:	52                   	push   %edx
  8007e9:	ff d7                	call   *%edi
			break;
  8007eb:	83 c4 10             	add    $0x10,%esp
  8007ee:	e9 9d fb ff ff       	jmp    800390 <vprintfmt+0x14>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007f3:	83 ec 08             	sub    $0x8,%esp
  8007f6:	53                   	push   %ebx
  8007f7:	6a 25                	push   $0x25
  8007f9:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007fb:	83 c4 10             	add    $0x10,%esp
  8007fe:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800802:	0f 84 85 fb ff ff    	je     80038d <vprintfmt+0x11>
  800808:	83 ee 01             	sub    $0x1,%esi
  80080b:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80080f:	75 f7                	jne    800808 <vprintfmt+0x48c>
  800811:	89 75 10             	mov    %esi,0x10(%ebp)
  800814:	e9 77 fb ff ff       	jmp    800390 <vprintfmt+0x14>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800819:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80081c:	8d 70 01             	lea    0x1(%eax),%esi
  80081f:	0f b6 00             	movzbl (%eax),%eax
  800822:	0f be d0             	movsbl %al,%edx
  800825:	85 d2                	test   %edx,%edx
  800827:	0f 85 db fd ff ff    	jne    800608 <vprintfmt+0x28c>
  80082d:	e9 5e fb ff ff       	jmp    800390 <vprintfmt+0x14>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800832:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800835:	5b                   	pop    %ebx
  800836:	5e                   	pop    %esi
  800837:	5f                   	pop    %edi
  800838:	5d                   	pop    %ebp
  800839:	c3                   	ret    

0080083a <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80083a:	55                   	push   %ebp
  80083b:	89 e5                	mov    %esp,%ebp
  80083d:	83 ec 18             	sub    $0x18,%esp
  800840:	8b 45 08             	mov    0x8(%ebp),%eax
  800843:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800846:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800849:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80084d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800850:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800857:	85 c0                	test   %eax,%eax
  800859:	74 26                	je     800881 <vsnprintf+0x47>
  80085b:	85 d2                	test   %edx,%edx
  80085d:	7e 22                	jle    800881 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80085f:	ff 75 14             	pushl  0x14(%ebp)
  800862:	ff 75 10             	pushl  0x10(%ebp)
  800865:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800868:	50                   	push   %eax
  800869:	68 42 03 80 00       	push   $0x800342
  80086e:	e8 09 fb ff ff       	call   80037c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800873:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800876:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800879:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80087c:	83 c4 10             	add    $0x10,%esp
  80087f:	eb 05                	jmp    800886 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800881:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800886:	c9                   	leave  
  800887:	c3                   	ret    

00800888 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800888:	55                   	push   %ebp
  800889:	89 e5                	mov    %esp,%ebp
  80088b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80088e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800891:	50                   	push   %eax
  800892:	ff 75 10             	pushl  0x10(%ebp)
  800895:	ff 75 0c             	pushl  0xc(%ebp)
  800898:	ff 75 08             	pushl  0x8(%ebp)
  80089b:	e8 9a ff ff ff       	call   80083a <vsnprintf>
	va_end(ap);

	return rc;
}
  8008a0:	c9                   	leave  
  8008a1:	c3                   	ret    

008008a2 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008a2:	55                   	push   %ebp
  8008a3:	89 e5                	mov    %esp,%ebp
  8008a5:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008a8:	80 3a 00             	cmpb   $0x0,(%edx)
  8008ab:	74 10                	je     8008bd <strlen+0x1b>
  8008ad:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8008b2:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8008b5:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008b9:	75 f7                	jne    8008b2 <strlen+0x10>
  8008bb:	eb 05                	jmp    8008c2 <strlen+0x20>
  8008bd:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8008c2:	5d                   	pop    %ebp
  8008c3:	c3                   	ret    

008008c4 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008c4:	55                   	push   %ebp
  8008c5:	89 e5                	mov    %esp,%ebp
  8008c7:	53                   	push   %ebx
  8008c8:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8008cb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008ce:	85 c9                	test   %ecx,%ecx
  8008d0:	74 1c                	je     8008ee <strnlen+0x2a>
  8008d2:	80 3b 00             	cmpb   $0x0,(%ebx)
  8008d5:	74 1e                	je     8008f5 <strnlen+0x31>
  8008d7:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  8008dc:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008de:	39 ca                	cmp    %ecx,%edx
  8008e0:	74 18                	je     8008fa <strnlen+0x36>
  8008e2:	83 c2 01             	add    $0x1,%edx
  8008e5:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  8008ea:	75 f0                	jne    8008dc <strnlen+0x18>
  8008ec:	eb 0c                	jmp    8008fa <strnlen+0x36>
  8008ee:	b8 00 00 00 00       	mov    $0x0,%eax
  8008f3:	eb 05                	jmp    8008fa <strnlen+0x36>
  8008f5:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8008fa:	5b                   	pop    %ebx
  8008fb:	5d                   	pop    %ebp
  8008fc:	c3                   	ret    

008008fd <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008fd:	55                   	push   %ebp
  8008fe:	89 e5                	mov    %esp,%ebp
  800900:	53                   	push   %ebx
  800901:	8b 45 08             	mov    0x8(%ebp),%eax
  800904:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800907:	89 c2                	mov    %eax,%edx
  800909:	83 c2 01             	add    $0x1,%edx
  80090c:	83 c1 01             	add    $0x1,%ecx
  80090f:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800913:	88 5a ff             	mov    %bl,-0x1(%edx)
  800916:	84 db                	test   %bl,%bl
  800918:	75 ef                	jne    800909 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80091a:	5b                   	pop    %ebx
  80091b:	5d                   	pop    %ebp
  80091c:	c3                   	ret    

0080091d <strcat>:

char *
strcat(char *dst, const char *src)
{
  80091d:	55                   	push   %ebp
  80091e:	89 e5                	mov    %esp,%ebp
  800920:	53                   	push   %ebx
  800921:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800924:	53                   	push   %ebx
  800925:	e8 78 ff ff ff       	call   8008a2 <strlen>
  80092a:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80092d:	ff 75 0c             	pushl  0xc(%ebp)
  800930:	01 d8                	add    %ebx,%eax
  800932:	50                   	push   %eax
  800933:	e8 c5 ff ff ff       	call   8008fd <strcpy>
	return dst;
}
  800938:	89 d8                	mov    %ebx,%eax
  80093a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80093d:	c9                   	leave  
  80093e:	c3                   	ret    

0080093f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80093f:	55                   	push   %ebp
  800940:	89 e5                	mov    %esp,%ebp
  800942:	56                   	push   %esi
  800943:	53                   	push   %ebx
  800944:	8b 75 08             	mov    0x8(%ebp),%esi
  800947:	8b 55 0c             	mov    0xc(%ebp),%edx
  80094a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80094d:	85 db                	test   %ebx,%ebx
  80094f:	74 17                	je     800968 <strncpy+0x29>
  800951:	01 f3                	add    %esi,%ebx
  800953:	89 f1                	mov    %esi,%ecx
		*dst++ = *src;
  800955:	83 c1 01             	add    $0x1,%ecx
  800958:	0f b6 02             	movzbl (%edx),%eax
  80095b:	88 41 ff             	mov    %al,-0x1(%ecx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80095e:	80 3a 01             	cmpb   $0x1,(%edx)
  800961:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800964:	39 cb                	cmp    %ecx,%ebx
  800966:	75 ed                	jne    800955 <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800968:	89 f0                	mov    %esi,%eax
  80096a:	5b                   	pop    %ebx
  80096b:	5e                   	pop    %esi
  80096c:	5d                   	pop    %ebp
  80096d:	c3                   	ret    

0080096e <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80096e:	55                   	push   %ebp
  80096f:	89 e5                	mov    %esp,%ebp
  800971:	56                   	push   %esi
  800972:	53                   	push   %ebx
  800973:	8b 75 08             	mov    0x8(%ebp),%esi
  800976:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800979:	8b 55 10             	mov    0x10(%ebp),%edx
  80097c:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80097e:	85 d2                	test   %edx,%edx
  800980:	74 35                	je     8009b7 <strlcpy+0x49>
		while (--size > 0 && *src != '\0')
  800982:	89 d0                	mov    %edx,%eax
  800984:	83 e8 01             	sub    $0x1,%eax
  800987:	74 25                	je     8009ae <strlcpy+0x40>
  800989:	0f b6 0b             	movzbl (%ebx),%ecx
  80098c:	84 c9                	test   %cl,%cl
  80098e:	74 22                	je     8009b2 <strlcpy+0x44>
  800990:	8d 53 01             	lea    0x1(%ebx),%edx
  800993:	01 c3                	add    %eax,%ebx
  800995:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
  800997:	83 c0 01             	add    $0x1,%eax
  80099a:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80099d:	39 da                	cmp    %ebx,%edx
  80099f:	74 13                	je     8009b4 <strlcpy+0x46>
  8009a1:	83 c2 01             	add    $0x1,%edx
  8009a4:	0f b6 4a ff          	movzbl -0x1(%edx),%ecx
  8009a8:	84 c9                	test   %cl,%cl
  8009aa:	75 eb                	jne    800997 <strlcpy+0x29>
  8009ac:	eb 06                	jmp    8009b4 <strlcpy+0x46>
  8009ae:	89 f0                	mov    %esi,%eax
  8009b0:	eb 02                	jmp    8009b4 <strlcpy+0x46>
  8009b2:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  8009b4:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8009b7:	29 f0                	sub    %esi,%eax
}
  8009b9:	5b                   	pop    %ebx
  8009ba:	5e                   	pop    %esi
  8009bb:	5d                   	pop    %ebp
  8009bc:	c3                   	ret    

008009bd <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009bd:	55                   	push   %ebp
  8009be:	89 e5                	mov    %esp,%ebp
  8009c0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009c3:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009c6:	0f b6 01             	movzbl (%ecx),%eax
  8009c9:	84 c0                	test   %al,%al
  8009cb:	74 15                	je     8009e2 <strcmp+0x25>
  8009cd:	3a 02                	cmp    (%edx),%al
  8009cf:	75 11                	jne    8009e2 <strcmp+0x25>
		p++, q++;
  8009d1:	83 c1 01             	add    $0x1,%ecx
  8009d4:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8009d7:	0f b6 01             	movzbl (%ecx),%eax
  8009da:	84 c0                	test   %al,%al
  8009dc:	74 04                	je     8009e2 <strcmp+0x25>
  8009de:	3a 02                	cmp    (%edx),%al
  8009e0:	74 ef                	je     8009d1 <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009e2:	0f b6 c0             	movzbl %al,%eax
  8009e5:	0f b6 12             	movzbl (%edx),%edx
  8009e8:	29 d0                	sub    %edx,%eax
}
  8009ea:	5d                   	pop    %ebp
  8009eb:	c3                   	ret    

008009ec <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009ec:	55                   	push   %ebp
  8009ed:	89 e5                	mov    %esp,%ebp
  8009ef:	56                   	push   %esi
  8009f0:	53                   	push   %ebx
  8009f1:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8009f4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009f7:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  8009fa:	85 f6                	test   %esi,%esi
  8009fc:	74 29                	je     800a27 <strncmp+0x3b>
  8009fe:	0f b6 03             	movzbl (%ebx),%eax
  800a01:	84 c0                	test   %al,%al
  800a03:	74 30                	je     800a35 <strncmp+0x49>
  800a05:	3a 02                	cmp    (%edx),%al
  800a07:	75 2c                	jne    800a35 <strncmp+0x49>
  800a09:	8d 43 01             	lea    0x1(%ebx),%eax
  800a0c:	01 de                	add    %ebx,%esi
		n--, p++, q++;
  800a0e:	89 c3                	mov    %eax,%ebx
  800a10:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a13:	39 c6                	cmp    %eax,%esi
  800a15:	74 17                	je     800a2e <strncmp+0x42>
  800a17:	0f b6 08             	movzbl (%eax),%ecx
  800a1a:	84 c9                	test   %cl,%cl
  800a1c:	74 17                	je     800a35 <strncmp+0x49>
  800a1e:	83 c0 01             	add    $0x1,%eax
  800a21:	3a 0a                	cmp    (%edx),%cl
  800a23:	74 e9                	je     800a0e <strncmp+0x22>
  800a25:	eb 0e                	jmp    800a35 <strncmp+0x49>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a27:	b8 00 00 00 00       	mov    $0x0,%eax
  800a2c:	eb 0f                	jmp    800a3d <strncmp+0x51>
  800a2e:	b8 00 00 00 00       	mov    $0x0,%eax
  800a33:	eb 08                	jmp    800a3d <strncmp+0x51>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a35:	0f b6 03             	movzbl (%ebx),%eax
  800a38:	0f b6 12             	movzbl (%edx),%edx
  800a3b:	29 d0                	sub    %edx,%eax
}
  800a3d:	5b                   	pop    %ebx
  800a3e:	5e                   	pop    %esi
  800a3f:	5d                   	pop    %ebp
  800a40:	c3                   	ret    

00800a41 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a41:	55                   	push   %ebp
  800a42:	89 e5                	mov    %esp,%ebp
  800a44:	53                   	push   %ebx
  800a45:	8b 45 08             	mov    0x8(%ebp),%eax
  800a48:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
  800a4b:	0f b6 10             	movzbl (%eax),%edx
  800a4e:	84 d2                	test   %dl,%dl
  800a50:	74 1d                	je     800a6f <strchr+0x2e>
  800a52:	89 d9                	mov    %ebx,%ecx
		if (*s == c)
  800a54:	38 d3                	cmp    %dl,%bl
  800a56:	75 06                	jne    800a5e <strchr+0x1d>
  800a58:	eb 1a                	jmp    800a74 <strchr+0x33>
  800a5a:	38 ca                	cmp    %cl,%dl
  800a5c:	74 16                	je     800a74 <strchr+0x33>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a5e:	83 c0 01             	add    $0x1,%eax
  800a61:	0f b6 10             	movzbl (%eax),%edx
  800a64:	84 d2                	test   %dl,%dl
  800a66:	75 f2                	jne    800a5a <strchr+0x19>
		if (*s == c)
			return (char *) s;
	return 0;
  800a68:	b8 00 00 00 00       	mov    $0x0,%eax
  800a6d:	eb 05                	jmp    800a74 <strchr+0x33>
  800a6f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a74:	5b                   	pop    %ebx
  800a75:	5d                   	pop    %ebp
  800a76:	c3                   	ret    

00800a77 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a77:	55                   	push   %ebp
  800a78:	89 e5                	mov    %esp,%ebp
  800a7a:	53                   	push   %ebx
  800a7b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a7e:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  800a81:	0f b6 18             	movzbl (%eax),%ebx
		if (*s == c)
  800a84:	38 d3                	cmp    %dl,%bl
  800a86:	74 14                	je     800a9c <strfind+0x25>
  800a88:	89 d1                	mov    %edx,%ecx
  800a8a:	84 db                	test   %bl,%bl
  800a8c:	74 0e                	je     800a9c <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a8e:	83 c0 01             	add    $0x1,%eax
  800a91:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a94:	38 ca                	cmp    %cl,%dl
  800a96:	74 04                	je     800a9c <strfind+0x25>
  800a98:	84 d2                	test   %dl,%dl
  800a9a:	75 f2                	jne    800a8e <strfind+0x17>
			break;
	return (char *) s;
}
  800a9c:	5b                   	pop    %ebx
  800a9d:	5d                   	pop    %ebp
  800a9e:	c3                   	ret    

00800a9f <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a9f:	55                   	push   %ebp
  800aa0:	89 e5                	mov    %esp,%ebp
  800aa2:	57                   	push   %edi
  800aa3:	56                   	push   %esi
  800aa4:	53                   	push   %ebx
  800aa5:	8b 7d 08             	mov    0x8(%ebp),%edi
  800aa8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800aab:	85 c9                	test   %ecx,%ecx
  800aad:	74 36                	je     800ae5 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800aaf:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800ab5:	75 28                	jne    800adf <memset+0x40>
  800ab7:	f6 c1 03             	test   $0x3,%cl
  800aba:	75 23                	jne    800adf <memset+0x40>
		c &= 0xFF;
  800abc:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ac0:	89 d3                	mov    %edx,%ebx
  800ac2:	c1 e3 08             	shl    $0x8,%ebx
  800ac5:	89 d6                	mov    %edx,%esi
  800ac7:	c1 e6 18             	shl    $0x18,%esi
  800aca:	89 d0                	mov    %edx,%eax
  800acc:	c1 e0 10             	shl    $0x10,%eax
  800acf:	09 f0                	or     %esi,%eax
  800ad1:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800ad3:	89 d8                	mov    %ebx,%eax
  800ad5:	09 d0                	or     %edx,%eax
  800ad7:	c1 e9 02             	shr    $0x2,%ecx
  800ada:	fc                   	cld    
  800adb:	f3 ab                	rep stos %eax,%es:(%edi)
  800add:	eb 06                	jmp    800ae5 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800adf:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ae2:	fc                   	cld    
  800ae3:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800ae5:	89 f8                	mov    %edi,%eax
  800ae7:	5b                   	pop    %ebx
  800ae8:	5e                   	pop    %esi
  800ae9:	5f                   	pop    %edi
  800aea:	5d                   	pop    %ebp
  800aeb:	c3                   	ret    

00800aec <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800aec:	55                   	push   %ebp
  800aed:	89 e5                	mov    %esp,%ebp
  800aef:	57                   	push   %edi
  800af0:	56                   	push   %esi
  800af1:	8b 45 08             	mov    0x8(%ebp),%eax
  800af4:	8b 75 0c             	mov    0xc(%ebp),%esi
  800af7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800afa:	39 c6                	cmp    %eax,%esi
  800afc:	73 35                	jae    800b33 <memmove+0x47>
  800afe:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b01:	39 d0                	cmp    %edx,%eax
  800b03:	73 2e                	jae    800b33 <memmove+0x47>
		s += n;
		d += n;
  800b05:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b08:	89 d6                	mov    %edx,%esi
  800b0a:	09 fe                	or     %edi,%esi
  800b0c:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b12:	75 13                	jne    800b27 <memmove+0x3b>
  800b14:	f6 c1 03             	test   $0x3,%cl
  800b17:	75 0e                	jne    800b27 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800b19:	83 ef 04             	sub    $0x4,%edi
  800b1c:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b1f:	c1 e9 02             	shr    $0x2,%ecx
  800b22:	fd                   	std    
  800b23:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b25:	eb 09                	jmp    800b30 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b27:	83 ef 01             	sub    $0x1,%edi
  800b2a:	8d 72 ff             	lea    -0x1(%edx),%esi
  800b2d:	fd                   	std    
  800b2e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b30:	fc                   	cld    
  800b31:	eb 1d                	jmp    800b50 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b33:	89 f2                	mov    %esi,%edx
  800b35:	09 c2                	or     %eax,%edx
  800b37:	f6 c2 03             	test   $0x3,%dl
  800b3a:	75 0f                	jne    800b4b <memmove+0x5f>
  800b3c:	f6 c1 03             	test   $0x3,%cl
  800b3f:	75 0a                	jne    800b4b <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800b41:	c1 e9 02             	shr    $0x2,%ecx
  800b44:	89 c7                	mov    %eax,%edi
  800b46:	fc                   	cld    
  800b47:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b49:	eb 05                	jmp    800b50 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b4b:	89 c7                	mov    %eax,%edi
  800b4d:	fc                   	cld    
  800b4e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b50:	5e                   	pop    %esi
  800b51:	5f                   	pop    %edi
  800b52:	5d                   	pop    %ebp
  800b53:	c3                   	ret    

00800b54 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800b54:	55                   	push   %ebp
  800b55:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b57:	ff 75 10             	pushl  0x10(%ebp)
  800b5a:	ff 75 0c             	pushl  0xc(%ebp)
  800b5d:	ff 75 08             	pushl  0x8(%ebp)
  800b60:	e8 87 ff ff ff       	call   800aec <memmove>
}
  800b65:	c9                   	leave  
  800b66:	c3                   	ret    

00800b67 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b67:	55                   	push   %ebp
  800b68:	89 e5                	mov    %esp,%ebp
  800b6a:	57                   	push   %edi
  800b6b:	56                   	push   %esi
  800b6c:	53                   	push   %ebx
  800b6d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800b70:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b73:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b76:	85 c0                	test   %eax,%eax
  800b78:	74 39                	je     800bb3 <memcmp+0x4c>
  800b7a:	8d 78 ff             	lea    -0x1(%eax),%edi
		if (*s1 != *s2)
  800b7d:	0f b6 13             	movzbl (%ebx),%edx
  800b80:	0f b6 0e             	movzbl (%esi),%ecx
  800b83:	38 ca                	cmp    %cl,%dl
  800b85:	75 17                	jne    800b9e <memcmp+0x37>
  800b87:	b8 00 00 00 00       	mov    $0x0,%eax
  800b8c:	eb 1a                	jmp    800ba8 <memcmp+0x41>
  800b8e:	0f b6 54 03 01       	movzbl 0x1(%ebx,%eax,1),%edx
  800b93:	83 c0 01             	add    $0x1,%eax
  800b96:	0f b6 0c 06          	movzbl (%esi,%eax,1),%ecx
  800b9a:	38 ca                	cmp    %cl,%dl
  800b9c:	74 0a                	je     800ba8 <memcmp+0x41>
			return (int) *s1 - (int) *s2;
  800b9e:	0f b6 c2             	movzbl %dl,%eax
  800ba1:	0f b6 c9             	movzbl %cl,%ecx
  800ba4:	29 c8                	sub    %ecx,%eax
  800ba6:	eb 10                	jmp    800bb8 <memcmp+0x51>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ba8:	39 f8                	cmp    %edi,%eax
  800baa:	75 e2                	jne    800b8e <memcmp+0x27>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800bac:	b8 00 00 00 00       	mov    $0x0,%eax
  800bb1:	eb 05                	jmp    800bb8 <memcmp+0x51>
  800bb3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bb8:	5b                   	pop    %ebx
  800bb9:	5e                   	pop    %esi
  800bba:	5f                   	pop    %edi
  800bbb:	5d                   	pop    %ebp
  800bbc:	c3                   	ret    

00800bbd <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800bbd:	55                   	push   %ebp
  800bbe:	89 e5                	mov    %esp,%ebp
  800bc0:	53                   	push   %ebx
  800bc1:	8b 55 08             	mov    0x8(%ebp),%edx
	const void *ends = (const char *) s + n;
  800bc4:	89 d0                	mov    %edx,%eax
  800bc6:	03 45 10             	add    0x10(%ebp),%eax
	for (; s < ends; s++)
  800bc9:	39 c2                	cmp    %eax,%edx
  800bcb:	73 1d                	jae    800bea <memfind+0x2d>
		if (*(const unsigned char *) s == (unsigned char) c)
  800bcd:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
  800bd1:	0f b6 0a             	movzbl (%edx),%ecx
  800bd4:	39 d9                	cmp    %ebx,%ecx
  800bd6:	75 09                	jne    800be1 <memfind+0x24>
  800bd8:	eb 14                	jmp    800bee <memfind+0x31>
  800bda:	0f b6 0a             	movzbl (%edx),%ecx
  800bdd:	39 d9                	cmp    %ebx,%ecx
  800bdf:	74 11                	je     800bf2 <memfind+0x35>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800be1:	83 c2 01             	add    $0x1,%edx
  800be4:	39 d0                	cmp    %edx,%eax
  800be6:	75 f2                	jne    800bda <memfind+0x1d>
  800be8:	eb 0a                	jmp    800bf4 <memfind+0x37>
  800bea:	89 d0                	mov    %edx,%eax
  800bec:	eb 06                	jmp    800bf4 <memfind+0x37>
		if (*(const unsigned char *) s == (unsigned char) c)
  800bee:	89 d0                	mov    %edx,%eax
  800bf0:	eb 02                	jmp    800bf4 <memfind+0x37>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800bf2:	89 d0                	mov    %edx,%eax
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800bf4:	5b                   	pop    %ebx
  800bf5:	5d                   	pop    %ebp
  800bf6:	c3                   	ret    

00800bf7 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800bf7:	55                   	push   %ebp
  800bf8:	89 e5                	mov    %esp,%ebp
  800bfa:	57                   	push   %edi
  800bfb:	56                   	push   %esi
  800bfc:	53                   	push   %ebx
  800bfd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c00:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c03:	0f b6 01             	movzbl (%ecx),%eax
  800c06:	3c 20                	cmp    $0x20,%al
  800c08:	74 04                	je     800c0e <strtol+0x17>
  800c0a:	3c 09                	cmp    $0x9,%al
  800c0c:	75 0e                	jne    800c1c <strtol+0x25>
		s++;
  800c0e:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c11:	0f b6 01             	movzbl (%ecx),%eax
  800c14:	3c 20                	cmp    $0x20,%al
  800c16:	74 f6                	je     800c0e <strtol+0x17>
  800c18:	3c 09                	cmp    $0x9,%al
  800c1a:	74 f2                	je     800c0e <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c1c:	3c 2b                	cmp    $0x2b,%al
  800c1e:	75 0a                	jne    800c2a <strtol+0x33>
		s++;
  800c20:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c23:	bf 00 00 00 00       	mov    $0x0,%edi
  800c28:	eb 11                	jmp    800c3b <strtol+0x44>
  800c2a:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c2f:	3c 2d                	cmp    $0x2d,%al
  800c31:	75 08                	jne    800c3b <strtol+0x44>
		s++, neg = 1;
  800c33:	83 c1 01             	add    $0x1,%ecx
  800c36:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c3b:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c41:	75 15                	jne    800c58 <strtol+0x61>
  800c43:	80 39 30             	cmpb   $0x30,(%ecx)
  800c46:	75 10                	jne    800c58 <strtol+0x61>
  800c48:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c4c:	75 7c                	jne    800cca <strtol+0xd3>
		s += 2, base = 16;
  800c4e:	83 c1 02             	add    $0x2,%ecx
  800c51:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c56:	eb 16                	jmp    800c6e <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  800c58:	85 db                	test   %ebx,%ebx
  800c5a:	75 12                	jne    800c6e <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c5c:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c61:	80 39 30             	cmpb   $0x30,(%ecx)
  800c64:	75 08                	jne    800c6e <strtol+0x77>
		s++, base = 8;
  800c66:	83 c1 01             	add    $0x1,%ecx
  800c69:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800c6e:	b8 00 00 00 00       	mov    $0x0,%eax
  800c73:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c76:	0f b6 11             	movzbl (%ecx),%edx
  800c79:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c7c:	89 f3                	mov    %esi,%ebx
  800c7e:	80 fb 09             	cmp    $0x9,%bl
  800c81:	77 08                	ja     800c8b <strtol+0x94>
			dig = *s - '0';
  800c83:	0f be d2             	movsbl %dl,%edx
  800c86:	83 ea 30             	sub    $0x30,%edx
  800c89:	eb 22                	jmp    800cad <strtol+0xb6>
		else if (*s >= 'a' && *s <= 'z')
  800c8b:	8d 72 9f             	lea    -0x61(%edx),%esi
  800c8e:	89 f3                	mov    %esi,%ebx
  800c90:	80 fb 19             	cmp    $0x19,%bl
  800c93:	77 08                	ja     800c9d <strtol+0xa6>
			dig = *s - 'a' + 10;
  800c95:	0f be d2             	movsbl %dl,%edx
  800c98:	83 ea 57             	sub    $0x57,%edx
  800c9b:	eb 10                	jmp    800cad <strtol+0xb6>
		else if (*s >= 'A' && *s <= 'Z')
  800c9d:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ca0:	89 f3                	mov    %esi,%ebx
  800ca2:	80 fb 19             	cmp    $0x19,%bl
  800ca5:	77 16                	ja     800cbd <strtol+0xc6>
			dig = *s - 'A' + 10;
  800ca7:	0f be d2             	movsbl %dl,%edx
  800caa:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800cad:	3b 55 10             	cmp    0x10(%ebp),%edx
  800cb0:	7d 0b                	jge    800cbd <strtol+0xc6>
			break;
		s++, val = (val * base) + dig;
  800cb2:	83 c1 01             	add    $0x1,%ecx
  800cb5:	0f af 45 10          	imul   0x10(%ebp),%eax
  800cb9:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800cbb:	eb b9                	jmp    800c76 <strtol+0x7f>

	if (endptr)
  800cbd:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800cc1:	74 0d                	je     800cd0 <strtol+0xd9>
		*endptr = (char *) s;
  800cc3:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cc6:	89 0e                	mov    %ecx,(%esi)
  800cc8:	eb 06                	jmp    800cd0 <strtol+0xd9>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800cca:	85 db                	test   %ebx,%ebx
  800ccc:	74 98                	je     800c66 <strtol+0x6f>
  800cce:	eb 9e                	jmp    800c6e <strtol+0x77>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800cd0:	89 c2                	mov    %eax,%edx
  800cd2:	f7 da                	neg    %edx
  800cd4:	85 ff                	test   %edi,%edi
  800cd6:	0f 45 c2             	cmovne %edx,%eax
}
  800cd9:	5b                   	pop    %ebx
  800cda:	5e                   	pop    %esi
  800cdb:	5f                   	pop    %edi
  800cdc:	5d                   	pop    %ebp
  800cdd:	c3                   	ret    

00800cde <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800cde:	55                   	push   %ebp
  800cdf:	89 e5                	mov    %esp,%ebp
  800ce1:	57                   	push   %edi
  800ce2:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800ce3:	b8 00 00 00 00       	mov    $0x0,%eax
  800ce8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ceb:	8b 55 08             	mov    0x8(%ebp),%edx
  800cee:	89 c3                	mov    %eax,%ebx
  800cf0:	89 c7                	mov    %eax,%edi
  800cf2:	51                   	push   %ecx
  800cf3:	52                   	push   %edx
  800cf4:	53                   	push   %ebx
  800cf5:	54                   	push   %esp
  800cf6:	55                   	push   %ebp
  800cf7:	56                   	push   %esi
  800cf8:	57                   	push   %edi
  800cf9:	5f                   	pop    %edi
  800cfa:	5e                   	pop    %esi
  800cfb:	5d                   	pop    %ebp
  800cfc:	5c                   	pop    %esp
  800cfd:	5b                   	pop    %ebx
  800cfe:	5a                   	pop    %edx
  800cff:	59                   	pop    %ecx

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800d00:	5b                   	pop    %ebx
  800d01:	5f                   	pop    %edi
  800d02:	5d                   	pop    %ebp
  800d03:	c3                   	ret    

00800d04 <sys_cgetc>:

int
sys_cgetc(void)
{
  800d04:	55                   	push   %ebp
  800d05:	89 e5                	mov    %esp,%ebp
  800d07:	57                   	push   %edi
  800d08:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800d09:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d0e:	b8 01 00 00 00       	mov    $0x1,%eax
  800d13:	89 ca                	mov    %ecx,%edx
  800d15:	89 cb                	mov    %ecx,%ebx
  800d17:	89 cf                	mov    %ecx,%edi
  800d19:	51                   	push   %ecx
  800d1a:	52                   	push   %edx
  800d1b:	53                   	push   %ebx
  800d1c:	54                   	push   %esp
  800d1d:	55                   	push   %ebp
  800d1e:	56                   	push   %esi
  800d1f:	57                   	push   %edi
  800d20:	5f                   	pop    %edi
  800d21:	5e                   	pop    %esi
  800d22:	5d                   	pop    %ebp
  800d23:	5c                   	pop    %esp
  800d24:	5b                   	pop    %ebx
  800d25:	5a                   	pop    %edx
  800d26:	59                   	pop    %ecx

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800d27:	5b                   	pop    %ebx
  800d28:	5f                   	pop    %edi
  800d29:	5d                   	pop    %ebp
  800d2a:	c3                   	ret    

00800d2b <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800d2b:	55                   	push   %ebp
  800d2c:	89 e5                	mov    %esp,%ebp
  800d2e:	57                   	push   %edi
  800d2f:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800d30:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d35:	b8 03 00 00 00       	mov    $0x3,%eax
  800d3a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d3d:	89 d9                	mov    %ebx,%ecx
  800d3f:	89 df                	mov    %ebx,%edi
  800d41:	51                   	push   %ecx
  800d42:	52                   	push   %edx
  800d43:	53                   	push   %ebx
  800d44:	54                   	push   %esp
  800d45:	55                   	push   %ebp
  800d46:	56                   	push   %esi
  800d47:	57                   	push   %edi
  800d48:	5f                   	pop    %edi
  800d49:	5e                   	pop    %esi
  800d4a:	5d                   	pop    %ebp
  800d4b:	5c                   	pop    %esp
  800d4c:	5b                   	pop    %ebx
  800d4d:	5a                   	pop    %edx
  800d4e:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  800d4f:	85 c0                	test   %eax,%eax
  800d51:	7e 17                	jle    800d6a <sys_env_destroy+0x3f>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d53:	83 ec 0c             	sub    $0xc,%esp
  800d56:	50                   	push   %eax
  800d57:	6a 03                	push   $0x3
  800d59:	68 9c 13 80 00       	push   $0x80139c
  800d5e:	6a 26                	push   $0x26
  800d60:	68 b9 13 80 00       	push   $0x8013b9
  800d65:	e8 7f 00 00 00       	call   800de9 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800d6a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800d6d:	5b                   	pop    %ebx
  800d6e:	5f                   	pop    %edi
  800d6f:	5d                   	pop    %ebp
  800d70:	c3                   	ret    

00800d71 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d71:	55                   	push   %ebp
  800d72:	89 e5                	mov    %esp,%ebp
  800d74:	57                   	push   %edi
  800d75:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800d76:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d7b:	b8 02 00 00 00       	mov    $0x2,%eax
  800d80:	89 ca                	mov    %ecx,%edx
  800d82:	89 cb                	mov    %ecx,%ebx
  800d84:	89 cf                	mov    %ecx,%edi
  800d86:	51                   	push   %ecx
  800d87:	52                   	push   %edx
  800d88:	53                   	push   %ebx
  800d89:	54                   	push   %esp
  800d8a:	55                   	push   %ebp
  800d8b:	56                   	push   %esi
  800d8c:	57                   	push   %edi
  800d8d:	5f                   	pop    %edi
  800d8e:	5e                   	pop    %esi
  800d8f:	5d                   	pop    %ebp
  800d90:	5c                   	pop    %esp
  800d91:	5b                   	pop    %ebx
  800d92:	5a                   	pop    %edx
  800d93:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d94:	5b                   	pop    %ebx
  800d95:	5f                   	pop    %edi
  800d96:	5d                   	pop    %ebp
  800d97:	c3                   	ret    

00800d98 <sys_map_kernel_page>:

int
sys_map_kernel_page(void* kpage, void* va)
{
  800d98:	55                   	push   %ebp
  800d99:	89 e5                	mov    %esp,%ebp
  800d9b:	57                   	push   %edi
  800d9c:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800d9d:	bf 00 00 00 00       	mov    $0x0,%edi
  800da2:	b8 04 00 00 00       	mov    $0x4,%eax
  800da7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800daa:	8b 55 08             	mov    0x8(%ebp),%edx
  800dad:	89 fb                	mov    %edi,%ebx
  800daf:	51                   	push   %ecx
  800db0:	52                   	push   %edx
  800db1:	53                   	push   %ebx
  800db2:	54                   	push   %esp
  800db3:	55                   	push   %ebp
  800db4:	56                   	push   %esi
  800db5:	57                   	push   %edi
  800db6:	5f                   	pop    %edi
  800db7:	5e                   	pop    %esi
  800db8:	5d                   	pop    %ebp
  800db9:	5c                   	pop    %esp
  800dba:	5b                   	pop    %ebx
  800dbb:	5a                   	pop    %edx
  800dbc:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  800dbd:	5b                   	pop    %ebx
  800dbe:	5f                   	pop    %edi
  800dbf:	5d                   	pop    %ebp
  800dc0:	c3                   	ret    

00800dc1 <sys_sbrk>:

int
sys_sbrk(uint32_t inc)
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
  800dc6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dcb:	b8 05 00 00 00       	mov    $0x5,%eax
  800dd0:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd3:	89 cb                	mov    %ecx,%ebx
  800dd5:	89 cf                	mov    %ecx,%edi
  800dd7:	51                   	push   %ecx
  800dd8:	52                   	push   %edx
  800dd9:	53                   	push   %ebx
  800dda:	54                   	push   %esp
  800ddb:	55                   	push   %ebp
  800ddc:	56                   	push   %esi
  800ddd:	57                   	push   %edi
  800dde:	5f                   	pop    %edi
  800ddf:	5e                   	pop    %esi
  800de0:	5d                   	pop    %ebp
  800de1:	5c                   	pop    %esp
  800de2:	5b                   	pop    %ebx
  800de3:	5a                   	pop    %edx
  800de4:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  800de5:	5b                   	pop    %ebx
  800de6:	5f                   	pop    %edi
  800de7:	5d                   	pop    %ebp
  800de8:	c3                   	ret    

00800de9 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800de9:	55                   	push   %ebp
  800dea:	89 e5                	mov    %esp,%ebp
  800dec:	56                   	push   %esi
  800ded:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800dee:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	if (argv0)
  800df1:	a1 08 20 80 00       	mov    0x802008,%eax
  800df6:	85 c0                	test   %eax,%eax
  800df8:	74 11                	je     800e0b <_panic+0x22>
		cprintf("%s: ", argv0);
  800dfa:	83 ec 08             	sub    $0x8,%esp
  800dfd:	50                   	push   %eax
  800dfe:	68 c7 13 80 00       	push   $0x8013c7
  800e03:	e8 4c f3 ff ff       	call   800154 <cprintf>
  800e08:	83 c4 10             	add    $0x10,%esp
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800e0b:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800e11:	e8 5b ff ff ff       	call   800d71 <sys_getenvid>
  800e16:	83 ec 0c             	sub    $0xc,%esp
  800e19:	ff 75 0c             	pushl  0xc(%ebp)
  800e1c:	ff 75 08             	pushl  0x8(%ebp)
  800e1f:	56                   	push   %esi
  800e20:	50                   	push   %eax
  800e21:	68 cc 13 80 00       	push   $0x8013cc
  800e26:	e8 29 f3 ff ff       	call   800154 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800e2b:	83 c4 18             	add    $0x18,%esp
  800e2e:	53                   	push   %ebx
  800e2f:	ff 75 10             	pushl  0x10(%ebp)
  800e32:	e8 cc f2 ff ff       	call   800103 <vcprintf>
	cprintf("\n");
  800e37:	c7 04 24 ea 10 80 00 	movl   $0x8010ea,(%esp)
  800e3e:	e8 11 f3 ff ff       	call   800154 <cprintf>
  800e43:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800e46:	cc                   	int3   
  800e47:	eb fd                	jmp    800e46 <_panic+0x5d>
  800e49:	66 90                	xchg   %ax,%ax
  800e4b:	66 90                	xchg   %ax,%ax
  800e4d:	66 90                	xchg   %ax,%ax
  800e4f:	90                   	nop

00800e50 <__udivdi3>:
  800e50:	55                   	push   %ebp
  800e51:	57                   	push   %edi
  800e52:	56                   	push   %esi
  800e53:	53                   	push   %ebx
  800e54:	83 ec 1c             	sub    $0x1c,%esp
  800e57:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  800e5b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  800e5f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  800e63:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800e67:	85 f6                	test   %esi,%esi
  800e69:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800e6d:	89 ca                	mov    %ecx,%edx
  800e6f:	89 f8                	mov    %edi,%eax
  800e71:	75 3d                	jne    800eb0 <__udivdi3+0x60>
  800e73:	39 cf                	cmp    %ecx,%edi
  800e75:	0f 87 c5 00 00 00    	ja     800f40 <__udivdi3+0xf0>
  800e7b:	85 ff                	test   %edi,%edi
  800e7d:	89 fd                	mov    %edi,%ebp
  800e7f:	75 0b                	jne    800e8c <__udivdi3+0x3c>
  800e81:	b8 01 00 00 00       	mov    $0x1,%eax
  800e86:	31 d2                	xor    %edx,%edx
  800e88:	f7 f7                	div    %edi
  800e8a:	89 c5                	mov    %eax,%ebp
  800e8c:	89 c8                	mov    %ecx,%eax
  800e8e:	31 d2                	xor    %edx,%edx
  800e90:	f7 f5                	div    %ebp
  800e92:	89 c1                	mov    %eax,%ecx
  800e94:	89 d8                	mov    %ebx,%eax
  800e96:	89 cf                	mov    %ecx,%edi
  800e98:	f7 f5                	div    %ebp
  800e9a:	89 c3                	mov    %eax,%ebx
  800e9c:	89 d8                	mov    %ebx,%eax
  800e9e:	89 fa                	mov    %edi,%edx
  800ea0:	83 c4 1c             	add    $0x1c,%esp
  800ea3:	5b                   	pop    %ebx
  800ea4:	5e                   	pop    %esi
  800ea5:	5f                   	pop    %edi
  800ea6:	5d                   	pop    %ebp
  800ea7:	c3                   	ret    
  800ea8:	90                   	nop
  800ea9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800eb0:	39 ce                	cmp    %ecx,%esi
  800eb2:	77 74                	ja     800f28 <__udivdi3+0xd8>
  800eb4:	0f bd fe             	bsr    %esi,%edi
  800eb7:	83 f7 1f             	xor    $0x1f,%edi
  800eba:	0f 84 98 00 00 00    	je     800f58 <__udivdi3+0x108>
  800ec0:	bb 20 00 00 00       	mov    $0x20,%ebx
  800ec5:	89 f9                	mov    %edi,%ecx
  800ec7:	89 c5                	mov    %eax,%ebp
  800ec9:	29 fb                	sub    %edi,%ebx
  800ecb:	d3 e6                	shl    %cl,%esi
  800ecd:	89 d9                	mov    %ebx,%ecx
  800ecf:	d3 ed                	shr    %cl,%ebp
  800ed1:	89 f9                	mov    %edi,%ecx
  800ed3:	d3 e0                	shl    %cl,%eax
  800ed5:	09 ee                	or     %ebp,%esi
  800ed7:	89 d9                	mov    %ebx,%ecx
  800ed9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800edd:	89 d5                	mov    %edx,%ebp
  800edf:	8b 44 24 08          	mov    0x8(%esp),%eax
  800ee3:	d3 ed                	shr    %cl,%ebp
  800ee5:	89 f9                	mov    %edi,%ecx
  800ee7:	d3 e2                	shl    %cl,%edx
  800ee9:	89 d9                	mov    %ebx,%ecx
  800eeb:	d3 e8                	shr    %cl,%eax
  800eed:	09 c2                	or     %eax,%edx
  800eef:	89 d0                	mov    %edx,%eax
  800ef1:	89 ea                	mov    %ebp,%edx
  800ef3:	f7 f6                	div    %esi
  800ef5:	89 d5                	mov    %edx,%ebp
  800ef7:	89 c3                	mov    %eax,%ebx
  800ef9:	f7 64 24 0c          	mull   0xc(%esp)
  800efd:	39 d5                	cmp    %edx,%ebp
  800eff:	72 10                	jb     800f11 <__udivdi3+0xc1>
  800f01:	8b 74 24 08          	mov    0x8(%esp),%esi
  800f05:	89 f9                	mov    %edi,%ecx
  800f07:	d3 e6                	shl    %cl,%esi
  800f09:	39 c6                	cmp    %eax,%esi
  800f0b:	73 07                	jae    800f14 <__udivdi3+0xc4>
  800f0d:	39 d5                	cmp    %edx,%ebp
  800f0f:	75 03                	jne    800f14 <__udivdi3+0xc4>
  800f11:	83 eb 01             	sub    $0x1,%ebx
  800f14:	31 ff                	xor    %edi,%edi
  800f16:	89 d8                	mov    %ebx,%eax
  800f18:	89 fa                	mov    %edi,%edx
  800f1a:	83 c4 1c             	add    $0x1c,%esp
  800f1d:	5b                   	pop    %ebx
  800f1e:	5e                   	pop    %esi
  800f1f:	5f                   	pop    %edi
  800f20:	5d                   	pop    %ebp
  800f21:	c3                   	ret    
  800f22:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800f28:	31 ff                	xor    %edi,%edi
  800f2a:	31 db                	xor    %ebx,%ebx
  800f2c:	89 d8                	mov    %ebx,%eax
  800f2e:	89 fa                	mov    %edi,%edx
  800f30:	83 c4 1c             	add    $0x1c,%esp
  800f33:	5b                   	pop    %ebx
  800f34:	5e                   	pop    %esi
  800f35:	5f                   	pop    %edi
  800f36:	5d                   	pop    %ebp
  800f37:	c3                   	ret    
  800f38:	90                   	nop
  800f39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f40:	89 d8                	mov    %ebx,%eax
  800f42:	f7 f7                	div    %edi
  800f44:	31 ff                	xor    %edi,%edi
  800f46:	89 c3                	mov    %eax,%ebx
  800f48:	89 d8                	mov    %ebx,%eax
  800f4a:	89 fa                	mov    %edi,%edx
  800f4c:	83 c4 1c             	add    $0x1c,%esp
  800f4f:	5b                   	pop    %ebx
  800f50:	5e                   	pop    %esi
  800f51:	5f                   	pop    %edi
  800f52:	5d                   	pop    %ebp
  800f53:	c3                   	ret    
  800f54:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f58:	39 ce                	cmp    %ecx,%esi
  800f5a:	72 0c                	jb     800f68 <__udivdi3+0x118>
  800f5c:	31 db                	xor    %ebx,%ebx
  800f5e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  800f62:	0f 87 34 ff ff ff    	ja     800e9c <__udivdi3+0x4c>
  800f68:	bb 01 00 00 00       	mov    $0x1,%ebx
  800f6d:	e9 2a ff ff ff       	jmp    800e9c <__udivdi3+0x4c>
  800f72:	66 90                	xchg   %ax,%ax
  800f74:	66 90                	xchg   %ax,%ax
  800f76:	66 90                	xchg   %ax,%ax
  800f78:	66 90                	xchg   %ax,%ax
  800f7a:	66 90                	xchg   %ax,%ax
  800f7c:	66 90                	xchg   %ax,%ax
  800f7e:	66 90                	xchg   %ax,%ax

00800f80 <__umoddi3>:
  800f80:	55                   	push   %ebp
  800f81:	57                   	push   %edi
  800f82:	56                   	push   %esi
  800f83:	53                   	push   %ebx
  800f84:	83 ec 1c             	sub    $0x1c,%esp
  800f87:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800f8b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  800f8f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800f93:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800f97:	85 d2                	test   %edx,%edx
  800f99:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800f9d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800fa1:	89 f3                	mov    %esi,%ebx
  800fa3:	89 3c 24             	mov    %edi,(%esp)
  800fa6:	89 74 24 04          	mov    %esi,0x4(%esp)
  800faa:	75 1c                	jne    800fc8 <__umoddi3+0x48>
  800fac:	39 f7                	cmp    %esi,%edi
  800fae:	76 50                	jbe    801000 <__umoddi3+0x80>
  800fb0:	89 c8                	mov    %ecx,%eax
  800fb2:	89 f2                	mov    %esi,%edx
  800fb4:	f7 f7                	div    %edi
  800fb6:	89 d0                	mov    %edx,%eax
  800fb8:	31 d2                	xor    %edx,%edx
  800fba:	83 c4 1c             	add    $0x1c,%esp
  800fbd:	5b                   	pop    %ebx
  800fbe:	5e                   	pop    %esi
  800fbf:	5f                   	pop    %edi
  800fc0:	5d                   	pop    %ebp
  800fc1:	c3                   	ret    
  800fc2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800fc8:	39 f2                	cmp    %esi,%edx
  800fca:	89 d0                	mov    %edx,%eax
  800fcc:	77 52                	ja     801020 <__umoddi3+0xa0>
  800fce:	0f bd ea             	bsr    %edx,%ebp
  800fd1:	83 f5 1f             	xor    $0x1f,%ebp
  800fd4:	75 5a                	jne    801030 <__umoddi3+0xb0>
  800fd6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  800fda:	0f 82 e0 00 00 00    	jb     8010c0 <__umoddi3+0x140>
  800fe0:	39 0c 24             	cmp    %ecx,(%esp)
  800fe3:	0f 86 d7 00 00 00    	jbe    8010c0 <__umoddi3+0x140>
  800fe9:	8b 44 24 08          	mov    0x8(%esp),%eax
  800fed:	8b 54 24 04          	mov    0x4(%esp),%edx
  800ff1:	83 c4 1c             	add    $0x1c,%esp
  800ff4:	5b                   	pop    %ebx
  800ff5:	5e                   	pop    %esi
  800ff6:	5f                   	pop    %edi
  800ff7:	5d                   	pop    %ebp
  800ff8:	c3                   	ret    
  800ff9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801000:	85 ff                	test   %edi,%edi
  801002:	89 fd                	mov    %edi,%ebp
  801004:	75 0b                	jne    801011 <__umoddi3+0x91>
  801006:	b8 01 00 00 00       	mov    $0x1,%eax
  80100b:	31 d2                	xor    %edx,%edx
  80100d:	f7 f7                	div    %edi
  80100f:	89 c5                	mov    %eax,%ebp
  801011:	89 f0                	mov    %esi,%eax
  801013:	31 d2                	xor    %edx,%edx
  801015:	f7 f5                	div    %ebp
  801017:	89 c8                	mov    %ecx,%eax
  801019:	f7 f5                	div    %ebp
  80101b:	89 d0                	mov    %edx,%eax
  80101d:	eb 99                	jmp    800fb8 <__umoddi3+0x38>
  80101f:	90                   	nop
  801020:	89 c8                	mov    %ecx,%eax
  801022:	89 f2                	mov    %esi,%edx
  801024:	83 c4 1c             	add    $0x1c,%esp
  801027:	5b                   	pop    %ebx
  801028:	5e                   	pop    %esi
  801029:	5f                   	pop    %edi
  80102a:	5d                   	pop    %ebp
  80102b:	c3                   	ret    
  80102c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801030:	8b 34 24             	mov    (%esp),%esi
  801033:	bf 20 00 00 00       	mov    $0x20,%edi
  801038:	89 e9                	mov    %ebp,%ecx
  80103a:	29 ef                	sub    %ebp,%edi
  80103c:	d3 e0                	shl    %cl,%eax
  80103e:	89 f9                	mov    %edi,%ecx
  801040:	89 f2                	mov    %esi,%edx
  801042:	d3 ea                	shr    %cl,%edx
  801044:	89 e9                	mov    %ebp,%ecx
  801046:	09 c2                	or     %eax,%edx
  801048:	89 d8                	mov    %ebx,%eax
  80104a:	89 14 24             	mov    %edx,(%esp)
  80104d:	89 f2                	mov    %esi,%edx
  80104f:	d3 e2                	shl    %cl,%edx
  801051:	89 f9                	mov    %edi,%ecx
  801053:	89 54 24 04          	mov    %edx,0x4(%esp)
  801057:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80105b:	d3 e8                	shr    %cl,%eax
  80105d:	89 e9                	mov    %ebp,%ecx
  80105f:	89 c6                	mov    %eax,%esi
  801061:	d3 e3                	shl    %cl,%ebx
  801063:	89 f9                	mov    %edi,%ecx
  801065:	89 d0                	mov    %edx,%eax
  801067:	d3 e8                	shr    %cl,%eax
  801069:	89 e9                	mov    %ebp,%ecx
  80106b:	09 d8                	or     %ebx,%eax
  80106d:	89 d3                	mov    %edx,%ebx
  80106f:	89 f2                	mov    %esi,%edx
  801071:	f7 34 24             	divl   (%esp)
  801074:	89 d6                	mov    %edx,%esi
  801076:	d3 e3                	shl    %cl,%ebx
  801078:	f7 64 24 04          	mull   0x4(%esp)
  80107c:	39 d6                	cmp    %edx,%esi
  80107e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801082:	89 d1                	mov    %edx,%ecx
  801084:	89 c3                	mov    %eax,%ebx
  801086:	72 08                	jb     801090 <__umoddi3+0x110>
  801088:	75 11                	jne    80109b <__umoddi3+0x11b>
  80108a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80108e:	73 0b                	jae    80109b <__umoddi3+0x11b>
  801090:	2b 44 24 04          	sub    0x4(%esp),%eax
  801094:	1b 14 24             	sbb    (%esp),%edx
  801097:	89 d1                	mov    %edx,%ecx
  801099:	89 c3                	mov    %eax,%ebx
  80109b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80109f:	29 da                	sub    %ebx,%edx
  8010a1:	19 ce                	sbb    %ecx,%esi
  8010a3:	89 f9                	mov    %edi,%ecx
  8010a5:	89 f0                	mov    %esi,%eax
  8010a7:	d3 e0                	shl    %cl,%eax
  8010a9:	89 e9                	mov    %ebp,%ecx
  8010ab:	d3 ea                	shr    %cl,%edx
  8010ad:	89 e9                	mov    %ebp,%ecx
  8010af:	d3 ee                	shr    %cl,%esi
  8010b1:	09 d0                	or     %edx,%eax
  8010b3:	89 f2                	mov    %esi,%edx
  8010b5:	83 c4 1c             	add    $0x1c,%esp
  8010b8:	5b                   	pop    %ebx
  8010b9:	5e                   	pop    %esi
  8010ba:	5f                   	pop    %edi
  8010bb:	5d                   	pop    %ebp
  8010bc:	c3                   	ret    
  8010bd:	8d 76 00             	lea    0x0(%esi),%esi
  8010c0:	29 f9                	sub    %edi,%ecx
  8010c2:	19 d6                	sbb    %edx,%esi
  8010c4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8010c8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8010cc:	e9 18 ff ff ff       	jmp    800fe9 <__umoddi3+0x69>
