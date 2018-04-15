
obj/user/sbrktest:     file format elf32-i386


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
  80002c:	e8 88 00 00 00       	call   8000b9 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#define ALLOCATE_SIZE 4096
#define STRING_SIZE	  64

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 18             	sub    $0x18,%esp
	int i;
	uint32_t start, end;
	char *s;

	start = sys_sbrk(0);
  80003c:	6a 00                	push   $0x0
  80003e:	e8 be 0d 00 00       	call   800e01 <sys_sbrk>
  800043:	89 c6                	mov    %eax,%esi
  800045:	89 c3                	mov    %eax,%ebx
	end = sys_sbrk(ALLOCATE_SIZE);
  800047:	c7 04 24 00 10 00 00 	movl   $0x1000,(%esp)
  80004e:	e8 ae 0d 00 00       	call   800e01 <sys_sbrk>

	if (end - start < ALLOCATE_SIZE) {
  800053:	29 f0                	sub    %esi,%eax
  800055:	83 c4 10             	add    $0x10,%esp
  800058:	3d ff 0f 00 00       	cmp    $0xfff,%eax
  80005d:	77 10                	ja     80006f <umain+0x3c>
		cprintf("sbrk not correctly implemented\n");
  80005f:	83 ec 0c             	sub    $0xc,%esp
  800062:	68 14 11 80 00       	push   $0x801114
  800067:	e8 28 01 00 00       	call   800194 <cprintf>
  80006c:	83 c4 10             	add    $0x10,%esp
	}

	s = (char *) start;
	for ( i = 0; i < STRING_SIZE; i++) {
  80006f:	b9 00 00 00 00       	mov    $0x0,%ecx
		s[i] = 'A' + (i % 26);
  800074:	bf 4f ec c4 4e       	mov    $0x4ec4ec4f,%edi
  800079:	89 c8                	mov    %ecx,%eax
  80007b:	f7 ef                	imul   %edi
  80007d:	c1 fa 03             	sar    $0x3,%edx
  800080:	89 c8                	mov    %ecx,%eax
  800082:	c1 f8 1f             	sar    $0x1f,%eax
  800085:	29 c2                	sub    %eax,%edx
  800087:	6b d2 1a             	imul   $0x1a,%edx,%edx
  80008a:	89 c8                	mov    %ecx,%eax
  80008c:	29 d0                	sub    %edx,%eax
  80008e:	83 c0 41             	add    $0x41,%eax
  800091:	88 04 19             	mov    %al,(%ecx,%ebx,1)
	if (end - start < ALLOCATE_SIZE) {
		cprintf("sbrk not correctly implemented\n");
	}

	s = (char *) start;
	for ( i = 0; i < STRING_SIZE; i++) {
  800094:	83 c1 01             	add    $0x1,%ecx
  800097:	83 f9 40             	cmp    $0x40,%ecx
  80009a:	75 dd                	jne    800079 <umain+0x46>
		s[i] = 'A' + (i % 26);
	}
	s[STRING_SIZE] = '\0';
  80009c:	c6 46 40 00          	movb   $0x0,0x40(%esi)

	cprintf("SBRK_TEST(%s)\n", s);
  8000a0:	83 ec 08             	sub    $0x8,%esp
  8000a3:	56                   	push   %esi
  8000a4:	68 34 11 80 00       	push   $0x801134
  8000a9:	e8 e6 00 00 00       	call   800194 <cprintf>
}
  8000ae:	83 c4 10             	add    $0x10,%esp
  8000b1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000b4:	5b                   	pop    %ebx
  8000b5:	5e                   	pop    %esi
  8000b6:	5f                   	pop    %edi
  8000b7:	5d                   	pop    %ebp
  8000b8:	c3                   	ret    

008000b9 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000b9:	55                   	push   %ebp
  8000ba:	89 e5                	mov    %esp,%ebp
  8000bc:	83 ec 08             	sub    $0x8,%esp
  8000bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8000c2:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  8000c5:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  8000cc:	00 00 00 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000cf:	85 c0                	test   %eax,%eax
  8000d1:	7e 08                	jle    8000db <libmain+0x22>
		binaryname = argv[0];
  8000d3:	8b 0a                	mov    (%edx),%ecx
  8000d5:	89 0d 00 20 80 00    	mov    %ecx,0x802000

	// call user main routine
	umain(argc, argv);
  8000db:	83 ec 08             	sub    $0x8,%esp
  8000de:	52                   	push   %edx
  8000df:	50                   	push   %eax
  8000e0:	e8 4e ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000e5:	e8 05 00 00 00       	call   8000ef <exit>
}
  8000ea:	83 c4 10             	add    $0x10,%esp
  8000ed:	c9                   	leave  
  8000ee:	c3                   	ret    

008000ef <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000ef:	55                   	push   %ebp
  8000f0:	89 e5                	mov    %esp,%ebp
  8000f2:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000f5:	6a 00                	push   $0x0
  8000f7:	e8 6f 0c 00 00       	call   800d6b <sys_env_destroy>
}
  8000fc:	83 c4 10             	add    $0x10,%esp
  8000ff:	c9                   	leave  
  800100:	c3                   	ret    

00800101 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800101:	55                   	push   %ebp
  800102:	89 e5                	mov    %esp,%ebp
  800104:	53                   	push   %ebx
  800105:	83 ec 04             	sub    $0x4,%esp
  800108:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80010b:	8b 13                	mov    (%ebx),%edx
  80010d:	8d 42 01             	lea    0x1(%edx),%eax
  800110:	89 03                	mov    %eax,(%ebx)
  800112:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800115:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800119:	3d ff 00 00 00       	cmp    $0xff,%eax
  80011e:	75 1a                	jne    80013a <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800120:	83 ec 08             	sub    $0x8,%esp
  800123:	68 ff 00 00 00       	push   $0xff
  800128:	8d 43 08             	lea    0x8(%ebx),%eax
  80012b:	50                   	push   %eax
  80012c:	e8 ed 0b 00 00       	call   800d1e <sys_cputs>
		b->idx = 0;
  800131:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800137:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80013a:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80013e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800141:	c9                   	leave  
  800142:	c3                   	ret    

00800143 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800143:	55                   	push   %ebp
  800144:	89 e5                	mov    %esp,%ebp
  800146:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80014c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800153:	00 00 00 
	b.cnt = 0;
  800156:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80015d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800160:	ff 75 0c             	pushl  0xc(%ebp)
  800163:	ff 75 08             	pushl  0x8(%ebp)
  800166:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80016c:	50                   	push   %eax
  80016d:	68 01 01 80 00       	push   $0x800101
  800172:	e8 45 02 00 00       	call   8003bc <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800177:	83 c4 08             	add    $0x8,%esp
  80017a:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800180:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800186:	50                   	push   %eax
  800187:	e8 92 0b 00 00       	call   800d1e <sys_cputs>

	return b.cnt;
}
  80018c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800192:	c9                   	leave  
  800193:	c3                   	ret    

00800194 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800194:	55                   	push   %ebp
  800195:	89 e5                	mov    %esp,%ebp
  800197:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80019a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80019d:	50                   	push   %eax
  80019e:	ff 75 08             	pushl  0x8(%ebp)
  8001a1:	e8 9d ff ff ff       	call   800143 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001a6:	c9                   	leave  
  8001a7:	c3                   	ret    

008001a8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001a8:	55                   	push   %ebp
  8001a9:	89 e5                	mov    %esp,%ebp
  8001ab:	57                   	push   %edi
  8001ac:	56                   	push   %esi
  8001ad:	53                   	push   %ebx
  8001ae:	83 ec 1c             	sub    $0x1c,%esp
  8001b1:	89 c7                	mov    %eax,%edi
  8001b3:	89 d6                	mov    %edx,%esi
  8001b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8001b8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001bb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001be:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	// if cprintf'parameter includes pattern of the form "%-", padding
	// space on the right side if neccesary.
	// you can add helper function if needed.
	// your code here:
	int length,showsign=0;
	if(padc=='-'&&num>=base)
  8001c1:	83 7d 18 2d          	cmpl   $0x2d,0x18(%ebp)
  8001c5:	0f 85 8a 00 00 00    	jne    800255 <printnum+0xad>
  8001cb:	8b 45 10             	mov    0x10(%ebp),%eax
  8001ce:	ba 00 00 00 00       	mov    $0x0,%edx
  8001d3:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8001d6:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8001d9:	39 da                	cmp    %ebx,%edx
  8001db:	72 09                	jb     8001e6 <printnum+0x3e>
  8001dd:	39 4d 10             	cmp    %ecx,0x10(%ebp)
  8001e0:	0f 87 87 00 00 00    	ja     80026d <printnum+0xc5>
	{
		length=*(int *)putdat;
  8001e6:	8b 1e                	mov    (%esi),%ebx
		printnum(putch,putdat,num/base,base,0,padc);
  8001e8:	83 ec 0c             	sub    $0xc,%esp
  8001eb:	6a 2d                	push   $0x2d
  8001ed:	6a 00                	push   $0x0
  8001ef:	ff 75 10             	pushl  0x10(%ebp)
  8001f2:	83 ec 08             	sub    $0x8,%esp
  8001f5:	52                   	push   %edx
  8001f6:	50                   	push   %eax
  8001f7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001fa:	ff 75 e0             	pushl  -0x20(%ebp)
  8001fd:	e8 8e 0c 00 00       	call   800e90 <__udivdi3>
  800202:	83 c4 18             	add    $0x18,%esp
  800205:	52                   	push   %edx
  800206:	50                   	push   %eax
  800207:	89 f2                	mov    %esi,%edx
  800209:	89 f8                	mov    %edi,%eax
  80020b:	e8 98 ff ff ff       	call   8001a8 <printnum>
		while (--width > 0)
			putch(padc, putdat);
	}
	}
	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800210:	83 c4 18             	add    $0x18,%esp
  800213:	56                   	push   %esi
  800214:	8b 45 10             	mov    0x10(%ebp),%eax
  800217:	ba 00 00 00 00       	mov    $0x0,%edx
  80021c:	83 ec 04             	sub    $0x4,%esp
  80021f:	52                   	push   %edx
  800220:	50                   	push   %eax
  800221:	ff 75 e4             	pushl  -0x1c(%ebp)
  800224:	ff 75 e0             	pushl  -0x20(%ebp)
  800227:	e8 94 0d 00 00       	call   800fc0 <__umoddi3>
  80022c:	83 c4 14             	add    $0x14,%esp
  80022f:	0f be 80 4d 11 80 00 	movsbl 0x80114d(%eax),%eax
  800236:	50                   	push   %eax
  800237:	ff d7                	call   *%edi
	
	if(padc=='-'&&width>0)
  800239:	83 c4 10             	add    $0x10,%esp
  80023c:	83 7d 18 2d          	cmpl   $0x2d,0x18(%ebp)
  800240:	0f 85 fa 00 00 00    	jne    800340 <printnum+0x198>
  800246:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
  80024a:	0f 8f 9b 00 00 00    	jg     8002eb <printnum+0x143>
  800250:	e9 eb 00 00 00       	jmp    800340 <printnum+0x198>
	}
	else
	{
	
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800255:	8b 45 10             	mov    0x10(%ebp),%eax
  800258:	ba 00 00 00 00       	mov    $0x0,%edx
  80025d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800260:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800263:	83 fb 00             	cmp    $0x0,%ebx
  800266:	77 14                	ja     80027c <printnum+0xd4>
  800268:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  80026b:	73 0f                	jae    80027c <printnum+0xd4>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80026d:	8b 45 14             	mov    0x14(%ebp),%eax
  800270:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800273:	85 db                	test   %ebx,%ebx
  800275:	7f 61                	jg     8002d8 <printnum+0x130>
  800277:	e9 98 00 00 00       	jmp    800314 <printnum+0x16c>
	else
	{
	
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80027c:	83 ec 0c             	sub    $0xc,%esp
  80027f:	ff 75 18             	pushl  0x18(%ebp)
  800282:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800285:	8d 59 ff             	lea    -0x1(%ecx),%ebx
  800288:	53                   	push   %ebx
  800289:	ff 75 10             	pushl  0x10(%ebp)
  80028c:	83 ec 08             	sub    $0x8,%esp
  80028f:	52                   	push   %edx
  800290:	50                   	push   %eax
  800291:	ff 75 e4             	pushl  -0x1c(%ebp)
  800294:	ff 75 e0             	pushl  -0x20(%ebp)
  800297:	e8 f4 0b 00 00       	call   800e90 <__udivdi3>
  80029c:	83 c4 18             	add    $0x18,%esp
  80029f:	52                   	push   %edx
  8002a0:	50                   	push   %eax
  8002a1:	89 f2                	mov    %esi,%edx
  8002a3:	89 f8                	mov    %edi,%eax
  8002a5:	e8 fe fe ff ff       	call   8001a8 <printnum>
		while (--width > 0)
			putch(padc, putdat);
	}
	}
	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002aa:	83 c4 18             	add    $0x18,%esp
  8002ad:	56                   	push   %esi
  8002ae:	8b 45 10             	mov    0x10(%ebp),%eax
  8002b1:	ba 00 00 00 00       	mov    $0x0,%edx
  8002b6:	83 ec 04             	sub    $0x4,%esp
  8002b9:	52                   	push   %edx
  8002ba:	50                   	push   %eax
  8002bb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002be:	ff 75 e0             	pushl  -0x20(%ebp)
  8002c1:	e8 fa 0c 00 00       	call   800fc0 <__umoddi3>
  8002c6:	83 c4 14             	add    $0x14,%esp
  8002c9:	0f be 80 4d 11 80 00 	movsbl 0x80114d(%eax),%eax
  8002d0:	50                   	push   %eax
  8002d1:	ff d7                	call   *%edi
  8002d3:	83 c4 10             	add    $0x10,%esp
  8002d6:	eb 68                	jmp    800340 <printnum+0x198>
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002d8:	83 ec 08             	sub    $0x8,%esp
  8002db:	56                   	push   %esi
  8002dc:	ff 75 18             	pushl  0x18(%ebp)
  8002df:	ff d7                	call   *%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002e1:	83 c4 10             	add    $0x10,%esp
  8002e4:	83 eb 01             	sub    $0x1,%ebx
  8002e7:	75 ef                	jne    8002d8 <printnum+0x130>
  8002e9:	eb 29                	jmp    800314 <printnum+0x16c>
	putch("0123456789abcdef"[num % base], putdat);
	
	if(padc=='-'&&width>0)
	{
		length=*(int *)putdat-length;
		for(int i=0;i<width-length;++i)
  8002eb:	8b 45 14             	mov    0x14(%ebp),%eax
  8002ee:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  8002f1:	2b 06                	sub    (%esi),%eax
  8002f3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002f6:	85 c0                	test   %eax,%eax
  8002f8:	7e 46                	jle    800340 <printnum+0x198>
  8002fa:	bb 00 00 00 00       	mov    $0x0,%ebx
			putch(' ',putdat);
  8002ff:	83 ec 08             	sub    $0x8,%esp
  800302:	56                   	push   %esi
  800303:	6a 20                	push   $0x20
  800305:	ff d7                	call   *%edi
	putch("0123456789abcdef"[num % base], putdat);
	
	if(padc=='-'&&width>0)
	{
		length=*(int *)putdat-length;
		for(int i=0;i<width-length;++i)
  800307:	83 c3 01             	add    $0x1,%ebx
  80030a:	83 c4 10             	add    $0x10,%esp
  80030d:	3b 5d e0             	cmp    -0x20(%ebp),%ebx
  800310:	75 ed                	jne    8002ff <printnum+0x157>
  800312:	eb 2c                	jmp    800340 <printnum+0x198>
		while (--width > 0)
			putch(padc, putdat);
	}
	}
	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800314:	83 ec 08             	sub    $0x8,%esp
  800317:	56                   	push   %esi
  800318:	8b 45 10             	mov    0x10(%ebp),%eax
  80031b:	ba 00 00 00 00       	mov    $0x0,%edx
  800320:	83 ec 04             	sub    $0x4,%esp
  800323:	52                   	push   %edx
  800324:	50                   	push   %eax
  800325:	ff 75 e4             	pushl  -0x1c(%ebp)
  800328:	ff 75 e0             	pushl  -0x20(%ebp)
  80032b:	e8 90 0c 00 00       	call   800fc0 <__umoddi3>
  800330:	83 c4 14             	add    $0x14,%esp
  800333:	0f be 80 4d 11 80 00 	movsbl 0x80114d(%eax),%eax
  80033a:	50                   	push   %eax
  80033b:	ff d7                	call   *%edi
  80033d:	83 c4 10             	add    $0x10,%esp
	{
		length=*(int *)putdat-length;
		for(int i=0;i<width-length;++i)
			putch(' ',putdat);
	}
}
  800340:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800343:	5b                   	pop    %ebx
  800344:	5e                   	pop    %esi
  800345:	5f                   	pop    %edi
  800346:	5d                   	pop    %ebp
  800347:	c3                   	ret    

00800348 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800348:	55                   	push   %ebp
  800349:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80034b:	83 fa 01             	cmp    $0x1,%edx
  80034e:	7e 0e                	jle    80035e <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800350:	8b 10                	mov    (%eax),%edx
  800352:	8d 4a 08             	lea    0x8(%edx),%ecx
  800355:	89 08                	mov    %ecx,(%eax)
  800357:	8b 02                	mov    (%edx),%eax
  800359:	8b 52 04             	mov    0x4(%edx),%edx
  80035c:	eb 22                	jmp    800380 <getuint+0x38>
	else if (lflag)
  80035e:	85 d2                	test   %edx,%edx
  800360:	74 10                	je     800372 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800362:	8b 10                	mov    (%eax),%edx
  800364:	8d 4a 04             	lea    0x4(%edx),%ecx
  800367:	89 08                	mov    %ecx,(%eax)
  800369:	8b 02                	mov    (%edx),%eax
  80036b:	ba 00 00 00 00       	mov    $0x0,%edx
  800370:	eb 0e                	jmp    800380 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800372:	8b 10                	mov    (%eax),%edx
  800374:	8d 4a 04             	lea    0x4(%edx),%ecx
  800377:	89 08                	mov    %ecx,(%eax)
  800379:	8b 02                	mov    (%edx),%eax
  80037b:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800380:	5d                   	pop    %ebp
  800381:	c3                   	ret    

00800382 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800382:	55                   	push   %ebp
  800383:	89 e5                	mov    %esp,%ebp
  800385:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800388:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80038c:	8b 10                	mov    (%eax),%edx
  80038e:	3b 50 04             	cmp    0x4(%eax),%edx
  800391:	73 0a                	jae    80039d <sprintputch+0x1b>
		*b->buf++ = ch;
  800393:	8d 4a 01             	lea    0x1(%edx),%ecx
  800396:	89 08                	mov    %ecx,(%eax)
  800398:	8b 45 08             	mov    0x8(%ebp),%eax
  80039b:	88 02                	mov    %al,(%edx)
}
  80039d:	5d                   	pop    %ebp
  80039e:	c3                   	ret    

0080039f <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80039f:	55                   	push   %ebp
  8003a0:	89 e5                	mov    %esp,%ebp
  8003a2:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8003a5:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003a8:	50                   	push   %eax
  8003a9:	ff 75 10             	pushl  0x10(%ebp)
  8003ac:	ff 75 0c             	pushl  0xc(%ebp)
  8003af:	ff 75 08             	pushl  0x8(%ebp)
  8003b2:	e8 05 00 00 00       	call   8003bc <vprintfmt>
	va_end(ap);
}
  8003b7:	83 c4 10             	add    $0x10,%esp
  8003ba:	c9                   	leave  
  8003bb:	c3                   	ret    

008003bc <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003bc:	55                   	push   %ebp
  8003bd:	89 e5                	mov    %esp,%ebp
  8003bf:	57                   	push   %edi
  8003c0:	56                   	push   %esi
  8003c1:	53                   	push   %ebx
  8003c2:	83 ec 2c             	sub    $0x2c,%esp
  8003c5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8003c8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003cb:	eb 03                	jmp    8003d0 <vprintfmt+0x14>
			break;
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
			for (fmt--; fmt[-1] != '%'; fmt--)
  8003cd:	89 75 10             	mov    %esi,0x10(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003d0:	8b 45 10             	mov    0x10(%ebp),%eax
  8003d3:	8d 70 01             	lea    0x1(%eax),%esi
  8003d6:	0f b6 00             	movzbl (%eax),%eax
  8003d9:	83 f8 25             	cmp    $0x25,%eax
  8003dc:	74 27                	je     800405 <vprintfmt+0x49>
			if (ch == '\0')
  8003de:	85 c0                	test   %eax,%eax
  8003e0:	75 0d                	jne    8003ef <vprintfmt+0x33>
  8003e2:	e9 8b 04 00 00       	jmp    800872 <vprintfmt+0x4b6>
  8003e7:	85 c0                	test   %eax,%eax
  8003e9:	0f 84 83 04 00 00    	je     800872 <vprintfmt+0x4b6>
				return;
			putch(ch, putdat);
  8003ef:	83 ec 08             	sub    $0x8,%esp
  8003f2:	53                   	push   %ebx
  8003f3:	50                   	push   %eax
  8003f4:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003f6:	83 c6 01             	add    $0x1,%esi
  8003f9:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  8003fd:	83 c4 10             	add    $0x10,%esp
  800400:	83 f8 25             	cmp    $0x25,%eax
  800403:	75 e2                	jne    8003e7 <vprintfmt+0x2b>
			padc = '-';
			goto reswitch;
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800405:	c6 45 e3 20          	movb   $0x20,-0x1d(%ebp)
  800409:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800410:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800417:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80041e:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  800425:	b9 00 00 00 00       	mov    $0x0,%ecx
  80042a:	eb 07                	jmp    800433 <vprintfmt+0x77>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80042c:	8b 75 10             	mov    0x10(%ebp),%esi

		// flag to show the sign
		case '+':
			padc='+';
  80042f:	c6 45 e3 2b          	movb   $0x2b,-0x1d(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800433:	8d 46 01             	lea    0x1(%esi),%eax
  800436:	89 45 10             	mov    %eax,0x10(%ebp)
  800439:	0f b6 06             	movzbl (%esi),%eax
  80043c:	0f b6 d0             	movzbl %al,%edx
  80043f:	83 e8 23             	sub    $0x23,%eax
  800442:	3c 55                	cmp    $0x55,%al
  800444:	0f 87 e9 03 00 00    	ja     800833 <vprintfmt+0x477>
  80044a:	0f b6 c0             	movzbl %al,%eax
  80044d:	ff 24 85 58 12 80 00 	jmp    *0x801258(,%eax,4)
  800454:	8b 75 10             	mov    0x10(%ebp),%esi
			padc='+';
			goto reswitch;
		
		// flag to pad on the right
		case '-':
			padc = '-';
  800457:	c6 45 e3 2d          	movb   $0x2d,-0x1d(%ebp)
  80045b:	eb d6                	jmp    800433 <vprintfmt+0x77>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80045d:	8d 42 d0             	lea    -0x30(%edx),%eax
  800460:	89 45 d0             	mov    %eax,-0x30(%ebp)
				ch = *fmt;
  800463:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
  800467:	8d 50 d0             	lea    -0x30(%eax),%edx
  80046a:	83 fa 09             	cmp    $0x9,%edx
  80046d:	77 66                	ja     8004d5 <vprintfmt+0x119>
  80046f:	8b 75 10             	mov    0x10(%ebp),%esi
  800472:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800475:	89 7d 08             	mov    %edi,0x8(%ebp)
  800478:	eb 09                	jmp    800483 <vprintfmt+0xc7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80047a:	8b 75 10             	mov    0x10(%ebp),%esi
			padc = '-';
			goto reswitch;
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80047d:	c6 45 e3 30          	movb   $0x30,-0x1d(%ebp)
			goto reswitch;
  800481:	eb b0                	jmp    800433 <vprintfmt+0x77>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800483:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  800486:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800489:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  80048d:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800490:	8d 78 d0             	lea    -0x30(%eax),%edi
  800493:	83 ff 09             	cmp    $0x9,%edi
  800496:	76 eb                	jbe    800483 <vprintfmt+0xc7>
  800498:	89 55 d0             	mov    %edx,-0x30(%ebp)
  80049b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80049e:	eb 38                	jmp    8004d8 <vprintfmt+0x11c>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004a0:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a3:	8d 50 04             	lea    0x4(%eax),%edx
  8004a6:	89 55 14             	mov    %edx,0x14(%ebp)
  8004a9:	8b 00                	mov    (%eax),%eax
  8004ab:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ae:	8b 75 10             	mov    0x10(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004b1:	eb 25                	jmp    8004d8 <vprintfmt+0x11c>
  8004b3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8004b6:	85 c0                	test   %eax,%eax
  8004b8:	0f 48 c1             	cmovs  %ecx,%eax
  8004bb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004be:	8b 75 10             	mov    0x10(%ebp),%esi
  8004c1:	e9 6d ff ff ff       	jmp    800433 <vprintfmt+0x77>
  8004c6:	8b 75 10             	mov    0x10(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004c9:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8004d0:	e9 5e ff ff ff       	jmp    800433 <vprintfmt+0x77>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d5:	8b 75 10             	mov    0x10(%ebp),%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8004d8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004dc:	0f 89 51 ff ff ff    	jns    800433 <vprintfmt+0x77>
				width = precision, precision = -1;
  8004e2:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8004e5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004e8:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8004ef:	e9 3f ff ff ff       	jmp    800433 <vprintfmt+0x77>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004f4:	83 45 cc 01          	addl   $0x1,-0x34(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f8:	8b 75 10             	mov    0x10(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004fb:	e9 33 ff ff ff       	jmp    800433 <vprintfmt+0x77>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800500:	8b 45 14             	mov    0x14(%ebp),%eax
  800503:	8d 50 04             	lea    0x4(%eax),%edx
  800506:	89 55 14             	mov    %edx,0x14(%ebp)
  800509:	83 ec 08             	sub    $0x8,%esp
  80050c:	53                   	push   %ebx
  80050d:	ff 30                	pushl  (%eax)
  80050f:	ff d7                	call   *%edi
			break;
  800511:	83 c4 10             	add    $0x10,%esp
  800514:	e9 b7 fe ff ff       	jmp    8003d0 <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800519:	8b 45 14             	mov    0x14(%ebp),%eax
  80051c:	8d 50 04             	lea    0x4(%eax),%edx
  80051f:	89 55 14             	mov    %edx,0x14(%ebp)
  800522:	8b 00                	mov    (%eax),%eax
  800524:	99                   	cltd   
  800525:	31 d0                	xor    %edx,%eax
  800527:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800529:	83 f8 06             	cmp    $0x6,%eax
  80052c:	7f 0b                	jg     800539 <vprintfmt+0x17d>
  80052e:	8b 14 85 b0 13 80 00 	mov    0x8013b0(,%eax,4),%edx
  800535:	85 d2                	test   %edx,%edx
  800537:	75 15                	jne    80054e <vprintfmt+0x192>
				printfmt(putch, putdat, "error %d", err);
  800539:	50                   	push   %eax
  80053a:	68 65 11 80 00       	push   $0x801165
  80053f:	53                   	push   %ebx
  800540:	57                   	push   %edi
  800541:	e8 59 fe ff ff       	call   80039f <printfmt>
  800546:	83 c4 10             	add    $0x10,%esp
  800549:	e9 82 fe ff ff       	jmp    8003d0 <vprintfmt+0x14>
			else
				printfmt(putch, putdat, "%s", p);
  80054e:	52                   	push   %edx
  80054f:	68 6e 11 80 00       	push   $0x80116e
  800554:	53                   	push   %ebx
  800555:	57                   	push   %edi
  800556:	e8 44 fe ff ff       	call   80039f <printfmt>
  80055b:	83 c4 10             	add    $0x10,%esp
  80055e:	e9 6d fe ff ff       	jmp    8003d0 <vprintfmt+0x14>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800563:	8b 45 14             	mov    0x14(%ebp),%eax
  800566:	8d 50 04             	lea    0x4(%eax),%edx
  800569:	89 55 14             	mov    %edx,0x14(%ebp)
  80056c:	8b 00                	mov    (%eax),%eax
				p = "(null)";
  80056e:	85 c0                	test   %eax,%eax
  800570:	b9 5e 11 80 00       	mov    $0x80115e,%ecx
  800575:	0f 45 c8             	cmovne %eax,%ecx
  800578:	89 4d cc             	mov    %ecx,-0x34(%ebp)
			if (width > 0 && padc != '-')
  80057b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80057f:	7e 06                	jle    800587 <vprintfmt+0x1cb>
  800581:	80 7d e3 2d          	cmpb   $0x2d,-0x1d(%ebp)
  800585:	75 19                	jne    8005a0 <vprintfmt+0x1e4>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800587:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80058a:	8d 70 01             	lea    0x1(%eax),%esi
  80058d:	0f b6 00             	movzbl (%eax),%eax
  800590:	0f be d0             	movsbl %al,%edx
  800593:	85 d2                	test   %edx,%edx
  800595:	0f 85 9f 00 00 00    	jne    80063a <vprintfmt+0x27e>
  80059b:	e9 8c 00 00 00       	jmp    80062c <vprintfmt+0x270>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005a0:	83 ec 08             	sub    $0x8,%esp
  8005a3:	ff 75 d0             	pushl  -0x30(%ebp)
  8005a6:	ff 75 cc             	pushl  -0x34(%ebp)
  8005a9:	e8 56 03 00 00       	call   800904 <strnlen>
  8005ae:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  8005b1:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8005b4:	83 c4 10             	add    $0x10,%esp
  8005b7:	85 c9                	test   %ecx,%ecx
  8005b9:	0f 8e 9a 02 00 00    	jle    800859 <vprintfmt+0x49d>
					putch(padc, putdat);
  8005bf:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  8005c3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005c6:	89 cb                	mov    %ecx,%ebx
  8005c8:	83 ec 08             	sub    $0x8,%esp
  8005cb:	ff 75 0c             	pushl  0xc(%ebp)
  8005ce:	56                   	push   %esi
  8005cf:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005d1:	83 c4 10             	add    $0x10,%esp
  8005d4:	83 eb 01             	sub    $0x1,%ebx
  8005d7:	75 ef                	jne    8005c8 <vprintfmt+0x20c>
  8005d9:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8005dc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005df:	e9 75 02 00 00       	jmp    800859 <vprintfmt+0x49d>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005e4:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005e8:	74 1b                	je     800605 <vprintfmt+0x249>
  8005ea:	0f be c0             	movsbl %al,%eax
  8005ed:	83 e8 20             	sub    $0x20,%eax
  8005f0:	83 f8 5e             	cmp    $0x5e,%eax
  8005f3:	76 10                	jbe    800605 <vprintfmt+0x249>
					putch('?', putdat);
  8005f5:	83 ec 08             	sub    $0x8,%esp
  8005f8:	ff 75 0c             	pushl  0xc(%ebp)
  8005fb:	6a 3f                	push   $0x3f
  8005fd:	ff 55 08             	call   *0x8(%ebp)
  800600:	83 c4 10             	add    $0x10,%esp
  800603:	eb 0d                	jmp    800612 <vprintfmt+0x256>
				else
					putch(ch, putdat);
  800605:	83 ec 08             	sub    $0x8,%esp
  800608:	ff 75 0c             	pushl  0xc(%ebp)
  80060b:	52                   	push   %edx
  80060c:	ff 55 08             	call   *0x8(%ebp)
  80060f:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800612:	83 ef 01             	sub    $0x1,%edi
  800615:	83 c6 01             	add    $0x1,%esi
  800618:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
  80061c:	0f be d0             	movsbl %al,%edx
  80061f:	85 d2                	test   %edx,%edx
  800621:	75 31                	jne    800654 <vprintfmt+0x298>
  800623:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800626:	8b 7d 08             	mov    0x8(%ebp),%edi
  800629:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80062c:	8b 75 e4             	mov    -0x1c(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80062f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800633:	7f 33                	jg     800668 <vprintfmt+0x2ac>
  800635:	e9 96 fd ff ff       	jmp    8003d0 <vprintfmt+0x14>
  80063a:	89 7d 08             	mov    %edi,0x8(%ebp)
  80063d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800640:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800643:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800646:	eb 0c                	jmp    800654 <vprintfmt+0x298>
  800648:	89 7d 08             	mov    %edi,0x8(%ebp)
  80064b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80064e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800651:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800654:	85 db                	test   %ebx,%ebx
  800656:	78 8c                	js     8005e4 <vprintfmt+0x228>
  800658:	83 eb 01             	sub    $0x1,%ebx
  80065b:	79 87                	jns    8005e4 <vprintfmt+0x228>
  80065d:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800660:	8b 7d 08             	mov    0x8(%ebp),%edi
  800663:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800666:	eb c4                	jmp    80062c <vprintfmt+0x270>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800668:	83 ec 08             	sub    $0x8,%esp
  80066b:	53                   	push   %ebx
  80066c:	6a 20                	push   $0x20
  80066e:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800670:	83 c4 10             	add    $0x10,%esp
  800673:	83 ee 01             	sub    $0x1,%esi
  800676:	75 f0                	jne    800668 <vprintfmt+0x2ac>
  800678:	e9 53 fd ff ff       	jmp    8003d0 <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80067d:	83 7d cc 01          	cmpl   $0x1,-0x34(%ebp)
  800681:	7e 16                	jle    800699 <vprintfmt+0x2dd>
		return va_arg(*ap, long long);
  800683:	8b 45 14             	mov    0x14(%ebp),%eax
  800686:	8d 50 08             	lea    0x8(%eax),%edx
  800689:	89 55 14             	mov    %edx,0x14(%ebp)
  80068c:	8b 50 04             	mov    0x4(%eax),%edx
  80068f:	8b 00                	mov    (%eax),%eax
  800691:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800694:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800697:	eb 34                	jmp    8006cd <vprintfmt+0x311>
	else if (lflag)
  800699:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  80069d:	74 18                	je     8006b7 <vprintfmt+0x2fb>
		return va_arg(*ap, long);
  80069f:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a2:	8d 50 04             	lea    0x4(%eax),%edx
  8006a5:	89 55 14             	mov    %edx,0x14(%ebp)
  8006a8:	8b 30                	mov    (%eax),%esi
  8006aa:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8006ad:	89 f0                	mov    %esi,%eax
  8006af:	c1 f8 1f             	sar    $0x1f,%eax
  8006b2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8006b5:	eb 16                	jmp    8006cd <vprintfmt+0x311>
	else
		return va_arg(*ap, int);
  8006b7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ba:	8d 50 04             	lea    0x4(%eax),%edx
  8006bd:	89 55 14             	mov    %edx,0x14(%ebp)
  8006c0:	8b 30                	mov    (%eax),%esi
  8006c2:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8006c5:	89 f0                	mov    %esi,%eax
  8006c7:	c1 f8 1f             	sar    $0x1f,%eax
  8006ca:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006cd:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8006d0:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8006d3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006d6:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  8006d9:	85 d2                	test   %edx,%edx
  8006db:	79 28                	jns    800705 <vprintfmt+0x349>
				putch('-', putdat);
  8006dd:	83 ec 08             	sub    $0x8,%esp
  8006e0:	53                   	push   %ebx
  8006e1:	6a 2d                	push   $0x2d
  8006e3:	ff d7                	call   *%edi
				num = -(long long) num;
  8006e5:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8006e8:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8006eb:	f7 d8                	neg    %eax
  8006ed:	83 d2 00             	adc    $0x0,%edx
  8006f0:	f7 da                	neg    %edx
  8006f2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006f5:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006f8:	83 c4 10             	add    $0x10,%esp
			else
			{
				if(padc=='+')
					putch('+', putdat);
			}
			base = 10;
  8006fb:	b8 0a 00 00 00       	mov    $0xa,%eax
  800700:	e9 a5 00 00 00       	jmp    8007aa <vprintfmt+0x3ee>
  800705:	b8 0a 00 00 00       	mov    $0xa,%eax
				putch('-', putdat);
				num = -(long long) num;
			}
			else
			{
				if(padc=='+')
  80070a:	80 7d e3 2b          	cmpb   $0x2b,-0x1d(%ebp)
  80070e:	0f 85 96 00 00 00    	jne    8007aa <vprintfmt+0x3ee>
					putch('+', putdat);
  800714:	83 ec 08             	sub    $0x8,%esp
  800717:	53                   	push   %ebx
  800718:	6a 2b                	push   $0x2b
  80071a:	ff d7                	call   *%edi
  80071c:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80071f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800724:	e9 81 00 00 00       	jmp    8007aa <vprintfmt+0x3ee>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800729:	8b 55 cc             	mov    -0x34(%ebp),%edx
  80072c:	8d 45 14             	lea    0x14(%ebp),%eax
  80072f:	e8 14 fc ff ff       	call   800348 <getuint>
  800734:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800737:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  80073a:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80073f:	eb 69                	jmp    8007aa <vprintfmt+0x3ee>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			putch('0', putdat);
  800741:	83 ec 08             	sub    $0x8,%esp
  800744:	53                   	push   %ebx
  800745:	6a 30                	push   $0x30
  800747:	ff d7                	call   *%edi
			num = getuint(&ap, lflag);
  800749:	8b 55 cc             	mov    -0x34(%ebp),%edx
  80074c:	8d 45 14             	lea    0x14(%ebp),%eax
  80074f:	e8 f4 fb ff ff       	call   800348 <getuint>
  800754:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800757:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
			goto number;
  80075a:	83 c4 10             	add    $0x10,%esp
		case 'o':
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
  80075d:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800762:	eb 46                	jmp    8007aa <vprintfmt+0x3ee>

		// pointer
		case 'p':
			putch('0', putdat);
  800764:	83 ec 08             	sub    $0x8,%esp
  800767:	53                   	push   %ebx
  800768:	6a 30                	push   $0x30
  80076a:	ff d7                	call   *%edi
			putch('x', putdat);
  80076c:	83 c4 08             	add    $0x8,%esp
  80076f:	53                   	push   %ebx
  800770:	6a 78                	push   $0x78
  800772:	ff d7                	call   *%edi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800774:	8b 45 14             	mov    0x14(%ebp),%eax
  800777:	8d 50 04             	lea    0x4(%eax),%edx
  80077a:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80077d:	8b 00                	mov    (%eax),%eax
  80077f:	ba 00 00 00 00       	mov    $0x0,%edx
  800784:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800787:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80078a:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80078d:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800792:	eb 16                	jmp    8007aa <vprintfmt+0x3ee>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800794:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800797:	8d 45 14             	lea    0x14(%ebp),%eax
  80079a:	e8 a9 fb ff ff       	call   800348 <getuint>
  80079f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007a2:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  8007a5:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007aa:	83 ec 0c             	sub    $0xc,%esp
  8007ad:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
  8007b1:	56                   	push   %esi
  8007b2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8007b5:	50                   	push   %eax
  8007b6:	ff 75 dc             	pushl  -0x24(%ebp)
  8007b9:	ff 75 d8             	pushl  -0x28(%ebp)
  8007bc:	89 da                	mov    %ebx,%edx
  8007be:	89 f8                	mov    %edi,%eax
  8007c0:	e8 e3 f9 ff ff       	call   8001a8 <printnum>
			break;
  8007c5:	83 c4 20             	add    $0x20,%esp
  8007c8:	e9 03 fc ff ff       	jmp    8003d0 <vprintfmt+0x14>

            const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
            const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

            // Your code here
			num=(unsigned long long)(uintptr_t)va_arg(ap, void *);
  8007cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d0:	8d 50 04             	lea    0x4(%eax),%edx
  8007d3:	89 55 14             	mov    %edx,0x14(%ebp)
  8007d6:	8b 00                	mov    (%eax),%eax
			if(!num)
  8007d8:	85 c0                	test   %eax,%eax
  8007da:	75 1c                	jne    8007f8 <vprintfmt+0x43c>
				*(int *)putdat+=cprintf("%s",null_error);
  8007dc:	83 ec 08             	sub    $0x8,%esp
  8007df:	68 dc 11 80 00       	push   $0x8011dc
  8007e4:	68 6e 11 80 00       	push   $0x80116e
  8007e9:	e8 a6 f9 ff ff       	call   800194 <cprintf>
  8007ee:	01 03                	add    %eax,(%ebx)
  8007f0:	83 c4 10             	add    $0x10,%esp
  8007f3:	e9 d8 fb ff ff       	jmp    8003d0 <vprintfmt+0x14>
			else
			{
				*(char *)(int)num=*(int *)putdat;
  8007f8:	8b 13                	mov    (%ebx),%edx
  8007fa:	88 10                	mov    %dl,(%eax)
				if((*(int *)putdat)>128)
  8007fc:	81 3b 80 00 00 00    	cmpl   $0x80,(%ebx)
  800802:	0f 8e c8 fb ff ff    	jle    8003d0 <vprintfmt+0x14>
					*(int *)putdat+=cprintf("%s",overflow_error);
  800808:	83 ec 08             	sub    $0x8,%esp
  80080b:	68 14 12 80 00       	push   $0x801214
  800810:	68 6e 11 80 00       	push   $0x80116e
  800815:	e8 7a f9 ff ff       	call   800194 <cprintf>
  80081a:	01 03                	add    %eax,(%ebx)
  80081c:	83 c4 10             	add    $0x10,%esp
  80081f:	e9 ac fb ff ff       	jmp    8003d0 <vprintfmt+0x14>
            break;
        }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800824:	83 ec 08             	sub    $0x8,%esp
  800827:	53                   	push   %ebx
  800828:	52                   	push   %edx
  800829:	ff d7                	call   *%edi
			break;
  80082b:	83 c4 10             	add    $0x10,%esp
  80082e:	e9 9d fb ff ff       	jmp    8003d0 <vprintfmt+0x14>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800833:	83 ec 08             	sub    $0x8,%esp
  800836:	53                   	push   %ebx
  800837:	6a 25                	push   $0x25
  800839:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80083b:	83 c4 10             	add    $0x10,%esp
  80083e:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800842:	0f 84 85 fb ff ff    	je     8003cd <vprintfmt+0x11>
  800848:	83 ee 01             	sub    $0x1,%esi
  80084b:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80084f:	75 f7                	jne    800848 <vprintfmt+0x48c>
  800851:	89 75 10             	mov    %esi,0x10(%ebp)
  800854:	e9 77 fb ff ff       	jmp    8003d0 <vprintfmt+0x14>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800859:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80085c:	8d 70 01             	lea    0x1(%eax),%esi
  80085f:	0f b6 00             	movzbl (%eax),%eax
  800862:	0f be d0             	movsbl %al,%edx
  800865:	85 d2                	test   %edx,%edx
  800867:	0f 85 db fd ff ff    	jne    800648 <vprintfmt+0x28c>
  80086d:	e9 5e fb ff ff       	jmp    8003d0 <vprintfmt+0x14>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800872:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800875:	5b                   	pop    %ebx
  800876:	5e                   	pop    %esi
  800877:	5f                   	pop    %edi
  800878:	5d                   	pop    %ebp
  800879:	c3                   	ret    

0080087a <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80087a:	55                   	push   %ebp
  80087b:	89 e5                	mov    %esp,%ebp
  80087d:	83 ec 18             	sub    $0x18,%esp
  800880:	8b 45 08             	mov    0x8(%ebp),%eax
  800883:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800886:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800889:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80088d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800890:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800897:	85 c0                	test   %eax,%eax
  800899:	74 26                	je     8008c1 <vsnprintf+0x47>
  80089b:	85 d2                	test   %edx,%edx
  80089d:	7e 22                	jle    8008c1 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80089f:	ff 75 14             	pushl  0x14(%ebp)
  8008a2:	ff 75 10             	pushl  0x10(%ebp)
  8008a5:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008a8:	50                   	push   %eax
  8008a9:	68 82 03 80 00       	push   $0x800382
  8008ae:	e8 09 fb ff ff       	call   8003bc <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008b3:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008b6:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008bc:	83 c4 10             	add    $0x10,%esp
  8008bf:	eb 05                	jmp    8008c6 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8008c1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8008c6:	c9                   	leave  
  8008c7:	c3                   	ret    

008008c8 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008c8:	55                   	push   %ebp
  8008c9:	89 e5                	mov    %esp,%ebp
  8008cb:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008ce:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008d1:	50                   	push   %eax
  8008d2:	ff 75 10             	pushl  0x10(%ebp)
  8008d5:	ff 75 0c             	pushl  0xc(%ebp)
  8008d8:	ff 75 08             	pushl  0x8(%ebp)
  8008db:	e8 9a ff ff ff       	call   80087a <vsnprintf>
	va_end(ap);

	return rc;
}
  8008e0:	c9                   	leave  
  8008e1:	c3                   	ret    

008008e2 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008e2:	55                   	push   %ebp
  8008e3:	89 e5                	mov    %esp,%ebp
  8008e5:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008e8:	80 3a 00             	cmpb   $0x0,(%edx)
  8008eb:	74 10                	je     8008fd <strlen+0x1b>
  8008ed:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8008f2:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8008f5:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008f9:	75 f7                	jne    8008f2 <strlen+0x10>
  8008fb:	eb 05                	jmp    800902 <strlen+0x20>
  8008fd:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800902:	5d                   	pop    %ebp
  800903:	c3                   	ret    

00800904 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800904:	55                   	push   %ebp
  800905:	89 e5                	mov    %esp,%ebp
  800907:	53                   	push   %ebx
  800908:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80090b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80090e:	85 c9                	test   %ecx,%ecx
  800910:	74 1c                	je     80092e <strnlen+0x2a>
  800912:	80 3b 00             	cmpb   $0x0,(%ebx)
  800915:	74 1e                	je     800935 <strnlen+0x31>
  800917:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
  80091c:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80091e:	39 ca                	cmp    %ecx,%edx
  800920:	74 18                	je     80093a <strnlen+0x36>
  800922:	83 c2 01             	add    $0x1,%edx
  800925:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
  80092a:	75 f0                	jne    80091c <strnlen+0x18>
  80092c:	eb 0c                	jmp    80093a <strnlen+0x36>
  80092e:	b8 00 00 00 00       	mov    $0x0,%eax
  800933:	eb 05                	jmp    80093a <strnlen+0x36>
  800935:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  80093a:	5b                   	pop    %ebx
  80093b:	5d                   	pop    %ebp
  80093c:	c3                   	ret    

0080093d <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80093d:	55                   	push   %ebp
  80093e:	89 e5                	mov    %esp,%ebp
  800940:	53                   	push   %ebx
  800941:	8b 45 08             	mov    0x8(%ebp),%eax
  800944:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800947:	89 c2                	mov    %eax,%edx
  800949:	83 c2 01             	add    $0x1,%edx
  80094c:	83 c1 01             	add    $0x1,%ecx
  80094f:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800953:	88 5a ff             	mov    %bl,-0x1(%edx)
  800956:	84 db                	test   %bl,%bl
  800958:	75 ef                	jne    800949 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80095a:	5b                   	pop    %ebx
  80095b:	5d                   	pop    %ebp
  80095c:	c3                   	ret    

0080095d <strcat>:

char *
strcat(char *dst, const char *src)
{
  80095d:	55                   	push   %ebp
  80095e:	89 e5                	mov    %esp,%ebp
  800960:	53                   	push   %ebx
  800961:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800964:	53                   	push   %ebx
  800965:	e8 78 ff ff ff       	call   8008e2 <strlen>
  80096a:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80096d:	ff 75 0c             	pushl  0xc(%ebp)
  800970:	01 d8                	add    %ebx,%eax
  800972:	50                   	push   %eax
  800973:	e8 c5 ff ff ff       	call   80093d <strcpy>
	return dst;
}
  800978:	89 d8                	mov    %ebx,%eax
  80097a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80097d:	c9                   	leave  
  80097e:	c3                   	ret    

0080097f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80097f:	55                   	push   %ebp
  800980:	89 e5                	mov    %esp,%ebp
  800982:	56                   	push   %esi
  800983:	53                   	push   %ebx
  800984:	8b 75 08             	mov    0x8(%ebp),%esi
  800987:	8b 55 0c             	mov    0xc(%ebp),%edx
  80098a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80098d:	85 db                	test   %ebx,%ebx
  80098f:	74 17                	je     8009a8 <strncpy+0x29>
  800991:	01 f3                	add    %esi,%ebx
  800993:	89 f1                	mov    %esi,%ecx
		*dst++ = *src;
  800995:	83 c1 01             	add    $0x1,%ecx
  800998:	0f b6 02             	movzbl (%edx),%eax
  80099b:	88 41 ff             	mov    %al,-0x1(%ecx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80099e:	80 3a 01             	cmpb   $0x1,(%edx)
  8009a1:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009a4:	39 cb                	cmp    %ecx,%ebx
  8009a6:	75 ed                	jne    800995 <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8009a8:	89 f0                	mov    %esi,%eax
  8009aa:	5b                   	pop    %ebx
  8009ab:	5e                   	pop    %esi
  8009ac:	5d                   	pop    %ebp
  8009ad:	c3                   	ret    

008009ae <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009ae:	55                   	push   %ebp
  8009af:	89 e5                	mov    %esp,%ebp
  8009b1:	56                   	push   %esi
  8009b2:	53                   	push   %ebx
  8009b3:	8b 75 08             	mov    0x8(%ebp),%esi
  8009b6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8009b9:	8b 55 10             	mov    0x10(%ebp),%edx
  8009bc:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009be:	85 d2                	test   %edx,%edx
  8009c0:	74 35                	je     8009f7 <strlcpy+0x49>
		while (--size > 0 && *src != '\0')
  8009c2:	89 d0                	mov    %edx,%eax
  8009c4:	83 e8 01             	sub    $0x1,%eax
  8009c7:	74 25                	je     8009ee <strlcpy+0x40>
  8009c9:	0f b6 0b             	movzbl (%ebx),%ecx
  8009cc:	84 c9                	test   %cl,%cl
  8009ce:	74 22                	je     8009f2 <strlcpy+0x44>
  8009d0:	8d 53 01             	lea    0x1(%ebx),%edx
  8009d3:	01 c3                	add    %eax,%ebx
  8009d5:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
  8009d7:	83 c0 01             	add    $0x1,%eax
  8009da:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8009dd:	39 da                	cmp    %ebx,%edx
  8009df:	74 13                	je     8009f4 <strlcpy+0x46>
  8009e1:	83 c2 01             	add    $0x1,%edx
  8009e4:	0f b6 4a ff          	movzbl -0x1(%edx),%ecx
  8009e8:	84 c9                	test   %cl,%cl
  8009ea:	75 eb                	jne    8009d7 <strlcpy+0x29>
  8009ec:	eb 06                	jmp    8009f4 <strlcpy+0x46>
  8009ee:	89 f0                	mov    %esi,%eax
  8009f0:	eb 02                	jmp    8009f4 <strlcpy+0x46>
  8009f2:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  8009f4:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8009f7:	29 f0                	sub    %esi,%eax
}
  8009f9:	5b                   	pop    %ebx
  8009fa:	5e                   	pop    %esi
  8009fb:	5d                   	pop    %ebp
  8009fc:	c3                   	ret    

008009fd <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009fd:	55                   	push   %ebp
  8009fe:	89 e5                	mov    %esp,%ebp
  800a00:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a03:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a06:	0f b6 01             	movzbl (%ecx),%eax
  800a09:	84 c0                	test   %al,%al
  800a0b:	74 15                	je     800a22 <strcmp+0x25>
  800a0d:	3a 02                	cmp    (%edx),%al
  800a0f:	75 11                	jne    800a22 <strcmp+0x25>
		p++, q++;
  800a11:	83 c1 01             	add    $0x1,%ecx
  800a14:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a17:	0f b6 01             	movzbl (%ecx),%eax
  800a1a:	84 c0                	test   %al,%al
  800a1c:	74 04                	je     800a22 <strcmp+0x25>
  800a1e:	3a 02                	cmp    (%edx),%al
  800a20:	74 ef                	je     800a11 <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a22:	0f b6 c0             	movzbl %al,%eax
  800a25:	0f b6 12             	movzbl (%edx),%edx
  800a28:	29 d0                	sub    %edx,%eax
}
  800a2a:	5d                   	pop    %ebp
  800a2b:	c3                   	ret    

00800a2c <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a2c:	55                   	push   %ebp
  800a2d:	89 e5                	mov    %esp,%ebp
  800a2f:	56                   	push   %esi
  800a30:	53                   	push   %ebx
  800a31:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800a34:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a37:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
  800a3a:	85 f6                	test   %esi,%esi
  800a3c:	74 29                	je     800a67 <strncmp+0x3b>
  800a3e:	0f b6 03             	movzbl (%ebx),%eax
  800a41:	84 c0                	test   %al,%al
  800a43:	74 30                	je     800a75 <strncmp+0x49>
  800a45:	3a 02                	cmp    (%edx),%al
  800a47:	75 2c                	jne    800a75 <strncmp+0x49>
  800a49:	8d 43 01             	lea    0x1(%ebx),%eax
  800a4c:	01 de                	add    %ebx,%esi
		n--, p++, q++;
  800a4e:	89 c3                	mov    %eax,%ebx
  800a50:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a53:	39 c6                	cmp    %eax,%esi
  800a55:	74 17                	je     800a6e <strncmp+0x42>
  800a57:	0f b6 08             	movzbl (%eax),%ecx
  800a5a:	84 c9                	test   %cl,%cl
  800a5c:	74 17                	je     800a75 <strncmp+0x49>
  800a5e:	83 c0 01             	add    $0x1,%eax
  800a61:	3a 0a                	cmp    (%edx),%cl
  800a63:	74 e9                	je     800a4e <strncmp+0x22>
  800a65:	eb 0e                	jmp    800a75 <strncmp+0x49>
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a67:	b8 00 00 00 00       	mov    $0x0,%eax
  800a6c:	eb 0f                	jmp    800a7d <strncmp+0x51>
  800a6e:	b8 00 00 00 00       	mov    $0x0,%eax
  800a73:	eb 08                	jmp    800a7d <strncmp+0x51>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a75:	0f b6 03             	movzbl (%ebx),%eax
  800a78:	0f b6 12             	movzbl (%edx),%edx
  800a7b:	29 d0                	sub    %edx,%eax
}
  800a7d:	5b                   	pop    %ebx
  800a7e:	5e                   	pop    %esi
  800a7f:	5d                   	pop    %ebp
  800a80:	c3                   	ret    

00800a81 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a81:	55                   	push   %ebp
  800a82:	89 e5                	mov    %esp,%ebp
  800a84:	53                   	push   %ebx
  800a85:	8b 45 08             	mov    0x8(%ebp),%eax
  800a88:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
  800a8b:	0f b6 10             	movzbl (%eax),%edx
  800a8e:	84 d2                	test   %dl,%dl
  800a90:	74 1d                	je     800aaf <strchr+0x2e>
  800a92:	89 d9                	mov    %ebx,%ecx
		if (*s == c)
  800a94:	38 d3                	cmp    %dl,%bl
  800a96:	75 06                	jne    800a9e <strchr+0x1d>
  800a98:	eb 1a                	jmp    800ab4 <strchr+0x33>
  800a9a:	38 ca                	cmp    %cl,%dl
  800a9c:	74 16                	je     800ab4 <strchr+0x33>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a9e:	83 c0 01             	add    $0x1,%eax
  800aa1:	0f b6 10             	movzbl (%eax),%edx
  800aa4:	84 d2                	test   %dl,%dl
  800aa6:	75 f2                	jne    800a9a <strchr+0x19>
		if (*s == c)
			return (char *) s;
	return 0;
  800aa8:	b8 00 00 00 00       	mov    $0x0,%eax
  800aad:	eb 05                	jmp    800ab4 <strchr+0x33>
  800aaf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ab4:	5b                   	pop    %ebx
  800ab5:	5d                   	pop    %ebp
  800ab6:	c3                   	ret    

00800ab7 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800ab7:	55                   	push   %ebp
  800ab8:	89 e5                	mov    %esp,%ebp
  800aba:	53                   	push   %ebx
  800abb:	8b 45 08             	mov    0x8(%ebp),%eax
  800abe:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
  800ac1:	0f b6 18             	movzbl (%eax),%ebx
		if (*s == c)
  800ac4:	38 d3                	cmp    %dl,%bl
  800ac6:	74 14                	je     800adc <strfind+0x25>
  800ac8:	89 d1                	mov    %edx,%ecx
  800aca:	84 db                	test   %bl,%bl
  800acc:	74 0e                	je     800adc <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800ace:	83 c0 01             	add    $0x1,%eax
  800ad1:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800ad4:	38 ca                	cmp    %cl,%dl
  800ad6:	74 04                	je     800adc <strfind+0x25>
  800ad8:	84 d2                	test   %dl,%dl
  800ada:	75 f2                	jne    800ace <strfind+0x17>
			break;
	return (char *) s;
}
  800adc:	5b                   	pop    %ebx
  800add:	5d                   	pop    %ebp
  800ade:	c3                   	ret    

00800adf <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800adf:	55                   	push   %ebp
  800ae0:	89 e5                	mov    %esp,%ebp
  800ae2:	57                   	push   %edi
  800ae3:	56                   	push   %esi
  800ae4:	53                   	push   %ebx
  800ae5:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ae8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800aeb:	85 c9                	test   %ecx,%ecx
  800aed:	74 36                	je     800b25 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800aef:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800af5:	75 28                	jne    800b1f <memset+0x40>
  800af7:	f6 c1 03             	test   $0x3,%cl
  800afa:	75 23                	jne    800b1f <memset+0x40>
		c &= 0xFF;
  800afc:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b00:	89 d3                	mov    %edx,%ebx
  800b02:	c1 e3 08             	shl    $0x8,%ebx
  800b05:	89 d6                	mov    %edx,%esi
  800b07:	c1 e6 18             	shl    $0x18,%esi
  800b0a:	89 d0                	mov    %edx,%eax
  800b0c:	c1 e0 10             	shl    $0x10,%eax
  800b0f:	09 f0                	or     %esi,%eax
  800b11:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800b13:	89 d8                	mov    %ebx,%eax
  800b15:	09 d0                	or     %edx,%eax
  800b17:	c1 e9 02             	shr    $0x2,%ecx
  800b1a:	fc                   	cld    
  800b1b:	f3 ab                	rep stos %eax,%es:(%edi)
  800b1d:	eb 06                	jmp    800b25 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b1f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b22:	fc                   	cld    
  800b23:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b25:	89 f8                	mov    %edi,%eax
  800b27:	5b                   	pop    %ebx
  800b28:	5e                   	pop    %esi
  800b29:	5f                   	pop    %edi
  800b2a:	5d                   	pop    %ebp
  800b2b:	c3                   	ret    

00800b2c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b2c:	55                   	push   %ebp
  800b2d:	89 e5                	mov    %esp,%ebp
  800b2f:	57                   	push   %edi
  800b30:	56                   	push   %esi
  800b31:	8b 45 08             	mov    0x8(%ebp),%eax
  800b34:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b37:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b3a:	39 c6                	cmp    %eax,%esi
  800b3c:	73 35                	jae    800b73 <memmove+0x47>
  800b3e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b41:	39 d0                	cmp    %edx,%eax
  800b43:	73 2e                	jae    800b73 <memmove+0x47>
		s += n;
		d += n;
  800b45:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b48:	89 d6                	mov    %edx,%esi
  800b4a:	09 fe                	or     %edi,%esi
  800b4c:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b52:	75 13                	jne    800b67 <memmove+0x3b>
  800b54:	f6 c1 03             	test   $0x3,%cl
  800b57:	75 0e                	jne    800b67 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800b59:	83 ef 04             	sub    $0x4,%edi
  800b5c:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b5f:	c1 e9 02             	shr    $0x2,%ecx
  800b62:	fd                   	std    
  800b63:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b65:	eb 09                	jmp    800b70 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b67:	83 ef 01             	sub    $0x1,%edi
  800b6a:	8d 72 ff             	lea    -0x1(%edx),%esi
  800b6d:	fd                   	std    
  800b6e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b70:	fc                   	cld    
  800b71:	eb 1d                	jmp    800b90 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b73:	89 f2                	mov    %esi,%edx
  800b75:	09 c2                	or     %eax,%edx
  800b77:	f6 c2 03             	test   $0x3,%dl
  800b7a:	75 0f                	jne    800b8b <memmove+0x5f>
  800b7c:	f6 c1 03             	test   $0x3,%cl
  800b7f:	75 0a                	jne    800b8b <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800b81:	c1 e9 02             	shr    $0x2,%ecx
  800b84:	89 c7                	mov    %eax,%edi
  800b86:	fc                   	cld    
  800b87:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b89:	eb 05                	jmp    800b90 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b8b:	89 c7                	mov    %eax,%edi
  800b8d:	fc                   	cld    
  800b8e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b90:	5e                   	pop    %esi
  800b91:	5f                   	pop    %edi
  800b92:	5d                   	pop    %ebp
  800b93:	c3                   	ret    

00800b94 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800b94:	55                   	push   %ebp
  800b95:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b97:	ff 75 10             	pushl  0x10(%ebp)
  800b9a:	ff 75 0c             	pushl  0xc(%ebp)
  800b9d:	ff 75 08             	pushl  0x8(%ebp)
  800ba0:	e8 87 ff ff ff       	call   800b2c <memmove>
}
  800ba5:	c9                   	leave  
  800ba6:	c3                   	ret    

00800ba7 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ba7:	55                   	push   %ebp
  800ba8:	89 e5                	mov    %esp,%ebp
  800baa:	57                   	push   %edi
  800bab:	56                   	push   %esi
  800bac:	53                   	push   %ebx
  800bad:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800bb0:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bb3:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bb6:	85 c0                	test   %eax,%eax
  800bb8:	74 39                	je     800bf3 <memcmp+0x4c>
  800bba:	8d 78 ff             	lea    -0x1(%eax),%edi
		if (*s1 != *s2)
  800bbd:	0f b6 13             	movzbl (%ebx),%edx
  800bc0:	0f b6 0e             	movzbl (%esi),%ecx
  800bc3:	38 ca                	cmp    %cl,%dl
  800bc5:	75 17                	jne    800bde <memcmp+0x37>
  800bc7:	b8 00 00 00 00       	mov    $0x0,%eax
  800bcc:	eb 1a                	jmp    800be8 <memcmp+0x41>
  800bce:	0f b6 54 03 01       	movzbl 0x1(%ebx,%eax,1),%edx
  800bd3:	83 c0 01             	add    $0x1,%eax
  800bd6:	0f b6 0c 06          	movzbl (%esi,%eax,1),%ecx
  800bda:	38 ca                	cmp    %cl,%dl
  800bdc:	74 0a                	je     800be8 <memcmp+0x41>
			return (int) *s1 - (int) *s2;
  800bde:	0f b6 c2             	movzbl %dl,%eax
  800be1:	0f b6 c9             	movzbl %cl,%ecx
  800be4:	29 c8                	sub    %ecx,%eax
  800be6:	eb 10                	jmp    800bf8 <memcmp+0x51>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800be8:	39 f8                	cmp    %edi,%eax
  800bea:	75 e2                	jne    800bce <memcmp+0x27>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800bec:	b8 00 00 00 00       	mov    $0x0,%eax
  800bf1:	eb 05                	jmp    800bf8 <memcmp+0x51>
  800bf3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bf8:	5b                   	pop    %ebx
  800bf9:	5e                   	pop    %esi
  800bfa:	5f                   	pop    %edi
  800bfb:	5d                   	pop    %ebp
  800bfc:	c3                   	ret    

00800bfd <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800bfd:	55                   	push   %ebp
  800bfe:	89 e5                	mov    %esp,%ebp
  800c00:	53                   	push   %ebx
  800c01:	8b 55 08             	mov    0x8(%ebp),%edx
	const void *ends = (const char *) s + n;
  800c04:	89 d0                	mov    %edx,%eax
  800c06:	03 45 10             	add    0x10(%ebp),%eax
	for (; s < ends; s++)
  800c09:	39 c2                	cmp    %eax,%edx
  800c0b:	73 1d                	jae    800c2a <memfind+0x2d>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c0d:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
  800c11:	0f b6 0a             	movzbl (%edx),%ecx
  800c14:	39 d9                	cmp    %ebx,%ecx
  800c16:	75 09                	jne    800c21 <memfind+0x24>
  800c18:	eb 14                	jmp    800c2e <memfind+0x31>
  800c1a:	0f b6 0a             	movzbl (%edx),%ecx
  800c1d:	39 d9                	cmp    %ebx,%ecx
  800c1f:	74 11                	je     800c32 <memfind+0x35>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c21:	83 c2 01             	add    $0x1,%edx
  800c24:	39 d0                	cmp    %edx,%eax
  800c26:	75 f2                	jne    800c1a <memfind+0x1d>
  800c28:	eb 0a                	jmp    800c34 <memfind+0x37>
  800c2a:	89 d0                	mov    %edx,%eax
  800c2c:	eb 06                	jmp    800c34 <memfind+0x37>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c2e:	89 d0                	mov    %edx,%eax
  800c30:	eb 02                	jmp    800c34 <memfind+0x37>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c32:	89 d0                	mov    %edx,%eax
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c34:	5b                   	pop    %ebx
  800c35:	5d                   	pop    %ebp
  800c36:	c3                   	ret    

00800c37 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c37:	55                   	push   %ebp
  800c38:	89 e5                	mov    %esp,%ebp
  800c3a:	57                   	push   %edi
  800c3b:	56                   	push   %esi
  800c3c:	53                   	push   %ebx
  800c3d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c40:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c43:	0f b6 01             	movzbl (%ecx),%eax
  800c46:	3c 20                	cmp    $0x20,%al
  800c48:	74 04                	je     800c4e <strtol+0x17>
  800c4a:	3c 09                	cmp    $0x9,%al
  800c4c:	75 0e                	jne    800c5c <strtol+0x25>
		s++;
  800c4e:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c51:	0f b6 01             	movzbl (%ecx),%eax
  800c54:	3c 20                	cmp    $0x20,%al
  800c56:	74 f6                	je     800c4e <strtol+0x17>
  800c58:	3c 09                	cmp    $0x9,%al
  800c5a:	74 f2                	je     800c4e <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c5c:	3c 2b                	cmp    $0x2b,%al
  800c5e:	75 0a                	jne    800c6a <strtol+0x33>
		s++;
  800c60:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c63:	bf 00 00 00 00       	mov    $0x0,%edi
  800c68:	eb 11                	jmp    800c7b <strtol+0x44>
  800c6a:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c6f:	3c 2d                	cmp    $0x2d,%al
  800c71:	75 08                	jne    800c7b <strtol+0x44>
		s++, neg = 1;
  800c73:	83 c1 01             	add    $0x1,%ecx
  800c76:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c7b:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c81:	75 15                	jne    800c98 <strtol+0x61>
  800c83:	80 39 30             	cmpb   $0x30,(%ecx)
  800c86:	75 10                	jne    800c98 <strtol+0x61>
  800c88:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c8c:	75 7c                	jne    800d0a <strtol+0xd3>
		s += 2, base = 16;
  800c8e:	83 c1 02             	add    $0x2,%ecx
  800c91:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c96:	eb 16                	jmp    800cae <strtol+0x77>
	else if (base == 0 && s[0] == '0')
  800c98:	85 db                	test   %ebx,%ebx
  800c9a:	75 12                	jne    800cae <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c9c:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ca1:	80 39 30             	cmpb   $0x30,(%ecx)
  800ca4:	75 08                	jne    800cae <strtol+0x77>
		s++, base = 8;
  800ca6:	83 c1 01             	add    $0x1,%ecx
  800ca9:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800cae:	b8 00 00 00 00       	mov    $0x0,%eax
  800cb3:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800cb6:	0f b6 11             	movzbl (%ecx),%edx
  800cb9:	8d 72 d0             	lea    -0x30(%edx),%esi
  800cbc:	89 f3                	mov    %esi,%ebx
  800cbe:	80 fb 09             	cmp    $0x9,%bl
  800cc1:	77 08                	ja     800ccb <strtol+0x94>
			dig = *s - '0';
  800cc3:	0f be d2             	movsbl %dl,%edx
  800cc6:	83 ea 30             	sub    $0x30,%edx
  800cc9:	eb 22                	jmp    800ced <strtol+0xb6>
		else if (*s >= 'a' && *s <= 'z')
  800ccb:	8d 72 9f             	lea    -0x61(%edx),%esi
  800cce:	89 f3                	mov    %esi,%ebx
  800cd0:	80 fb 19             	cmp    $0x19,%bl
  800cd3:	77 08                	ja     800cdd <strtol+0xa6>
			dig = *s - 'a' + 10;
  800cd5:	0f be d2             	movsbl %dl,%edx
  800cd8:	83 ea 57             	sub    $0x57,%edx
  800cdb:	eb 10                	jmp    800ced <strtol+0xb6>
		else if (*s >= 'A' && *s <= 'Z')
  800cdd:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ce0:	89 f3                	mov    %esi,%ebx
  800ce2:	80 fb 19             	cmp    $0x19,%bl
  800ce5:	77 16                	ja     800cfd <strtol+0xc6>
			dig = *s - 'A' + 10;
  800ce7:	0f be d2             	movsbl %dl,%edx
  800cea:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800ced:	3b 55 10             	cmp    0x10(%ebp),%edx
  800cf0:	7d 0b                	jge    800cfd <strtol+0xc6>
			break;
		s++, val = (val * base) + dig;
  800cf2:	83 c1 01             	add    $0x1,%ecx
  800cf5:	0f af 45 10          	imul   0x10(%ebp),%eax
  800cf9:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800cfb:	eb b9                	jmp    800cb6 <strtol+0x7f>

	if (endptr)
  800cfd:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d01:	74 0d                	je     800d10 <strtol+0xd9>
		*endptr = (char *) s;
  800d03:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d06:	89 0e                	mov    %ecx,(%esi)
  800d08:	eb 06                	jmp    800d10 <strtol+0xd9>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800d0a:	85 db                	test   %ebx,%ebx
  800d0c:	74 98                	je     800ca6 <strtol+0x6f>
  800d0e:	eb 9e                	jmp    800cae <strtol+0x77>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800d10:	89 c2                	mov    %eax,%edx
  800d12:	f7 da                	neg    %edx
  800d14:	85 ff                	test   %edi,%edi
  800d16:	0f 45 c2             	cmovne %edx,%eax
}
  800d19:	5b                   	pop    %ebx
  800d1a:	5e                   	pop    %esi
  800d1b:	5f                   	pop    %edi
  800d1c:	5d                   	pop    %ebp
  800d1d:	c3                   	ret    

00800d1e <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800d1e:	55                   	push   %ebp
  800d1f:	89 e5                	mov    %esp,%ebp
  800d21:	57                   	push   %edi
  800d22:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800d23:	b8 00 00 00 00       	mov    $0x0,%eax
  800d28:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d2b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d2e:	89 c3                	mov    %eax,%ebx
  800d30:	89 c7                	mov    %eax,%edi
  800d32:	51                   	push   %ecx
  800d33:	52                   	push   %edx
  800d34:	53                   	push   %ebx
  800d35:	54                   	push   %esp
  800d36:	55                   	push   %ebp
  800d37:	56                   	push   %esi
  800d38:	57                   	push   %edi
  800d39:	5f                   	pop    %edi
  800d3a:	5e                   	pop    %esi
  800d3b:	5d                   	pop    %ebp
  800d3c:	5c                   	pop    %esp
  800d3d:	5b                   	pop    %ebx
  800d3e:	5a                   	pop    %edx
  800d3f:	59                   	pop    %ecx

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800d40:	5b                   	pop    %ebx
  800d41:	5f                   	pop    %edi
  800d42:	5d                   	pop    %ebp
  800d43:	c3                   	ret    

00800d44 <sys_cgetc>:

int
sys_cgetc(void)
{
  800d44:	55                   	push   %ebp
  800d45:	89 e5                	mov    %esp,%ebp
  800d47:	57                   	push   %edi
  800d48:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800d49:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d4e:	b8 01 00 00 00       	mov    $0x1,%eax
  800d53:	89 ca                	mov    %ecx,%edx
  800d55:	89 cb                	mov    %ecx,%ebx
  800d57:	89 cf                	mov    %ecx,%edi
  800d59:	51                   	push   %ecx
  800d5a:	52                   	push   %edx
  800d5b:	53                   	push   %ebx
  800d5c:	54                   	push   %esp
  800d5d:	55                   	push   %ebp
  800d5e:	56                   	push   %esi
  800d5f:	57                   	push   %edi
  800d60:	5f                   	pop    %edi
  800d61:	5e                   	pop    %esi
  800d62:	5d                   	pop    %ebp
  800d63:	5c                   	pop    %esp
  800d64:	5b                   	pop    %ebx
  800d65:	5a                   	pop    %edx
  800d66:	59                   	pop    %ecx

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800d67:	5b                   	pop    %ebx
  800d68:	5f                   	pop    %edi
  800d69:	5d                   	pop    %ebp
  800d6a:	c3                   	ret    

00800d6b <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800d6b:	55                   	push   %ebp
  800d6c:	89 e5                	mov    %esp,%ebp
  800d6e:	57                   	push   %edi
  800d6f:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800d70:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d75:	b8 03 00 00 00       	mov    $0x3,%eax
  800d7a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d7d:	89 d9                	mov    %ebx,%ecx
  800d7f:	89 df                	mov    %ebx,%edi
  800d81:	51                   	push   %ecx
  800d82:	52                   	push   %edx
  800d83:	53                   	push   %ebx
  800d84:	54                   	push   %esp
  800d85:	55                   	push   %ebp
  800d86:	56                   	push   %esi
  800d87:	57                   	push   %edi
  800d88:	5f                   	pop    %edi
  800d89:	5e                   	pop    %esi
  800d8a:	5d                   	pop    %ebp
  800d8b:	5c                   	pop    %esp
  800d8c:	5b                   	pop    %ebx
  800d8d:	5a                   	pop    %edx
  800d8e:	59                   	pop    %ecx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  800d8f:	85 c0                	test   %eax,%eax
  800d91:	7e 17                	jle    800daa <sys_env_destroy+0x3f>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d93:	83 ec 0c             	sub    $0xc,%esp
  800d96:	50                   	push   %eax
  800d97:	6a 03                	push   $0x3
  800d99:	68 cc 13 80 00       	push   $0x8013cc
  800d9e:	6a 26                	push   $0x26
  800da0:	68 e9 13 80 00       	push   $0x8013e9
  800da5:	e8 7f 00 00 00       	call   800e29 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800daa:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800dad:	5b                   	pop    %ebx
  800dae:	5f                   	pop    %edi
  800daf:	5d                   	pop    %ebp
  800db0:	c3                   	ret    

00800db1 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800db1:	55                   	push   %ebp
  800db2:	89 e5                	mov    %esp,%ebp
  800db4:	57                   	push   %edi
  800db5:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800db6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dbb:	b8 02 00 00 00       	mov    $0x2,%eax
  800dc0:	89 ca                	mov    %ecx,%edx
  800dc2:	89 cb                	mov    %ecx,%ebx
  800dc4:	89 cf                	mov    %ecx,%edi
  800dc6:	51                   	push   %ecx
  800dc7:	52                   	push   %edx
  800dc8:	53                   	push   %ebx
  800dc9:	54                   	push   %esp
  800dca:	55                   	push   %ebp
  800dcb:	56                   	push   %esi
  800dcc:	57                   	push   %edi
  800dcd:	5f                   	pop    %edi
  800dce:	5e                   	pop    %esi
  800dcf:	5d                   	pop    %ebp
  800dd0:	5c                   	pop    %esp
  800dd1:	5b                   	pop    %ebx
  800dd2:	5a                   	pop    %edx
  800dd3:	59                   	pop    %ecx

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800dd4:	5b                   	pop    %ebx
  800dd5:	5f                   	pop    %edi
  800dd6:	5d                   	pop    %ebp
  800dd7:	c3                   	ret    

00800dd8 <sys_map_kernel_page>:

int
sys_map_kernel_page(void* kpage, void* va)
{
  800dd8:	55                   	push   %ebp
  800dd9:	89 e5                	mov    %esp,%ebp
  800ddb:	57                   	push   %edi
  800ddc:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800ddd:	bf 00 00 00 00       	mov    $0x0,%edi
  800de2:	b8 04 00 00 00       	mov    $0x4,%eax
  800de7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dea:	8b 55 08             	mov    0x8(%ebp),%edx
  800ded:	89 fb                	mov    %edi,%ebx
  800def:	51                   	push   %ecx
  800df0:	52                   	push   %edx
  800df1:	53                   	push   %ebx
  800df2:	54                   	push   %esp
  800df3:	55                   	push   %ebp
  800df4:	56                   	push   %esi
  800df5:	57                   	push   %edi
  800df6:	5f                   	pop    %edi
  800df7:	5e                   	pop    %esi
  800df8:	5d                   	pop    %ebp
  800df9:	5c                   	pop    %esp
  800dfa:	5b                   	pop    %ebx
  800dfb:	5a                   	pop    %edx
  800dfc:	59                   	pop    %ecx

int
sys_map_kernel_page(void* kpage, void* va)
{
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  800dfd:	5b                   	pop    %ebx
  800dfe:	5f                   	pop    %edi
  800dff:	5d                   	pop    %ebp
  800e00:	c3                   	ret    

00800e01 <sys_sbrk>:

int
sys_sbrk(uint32_t inc)
{
  800e01:	55                   	push   %ebp
  800e02:	89 e5                	mov    %esp,%ebp
  800e04:	57                   	push   %edi
  800e05:	53                   	push   %ebx

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800e06:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e0b:	b8 05 00 00 00       	mov    $0x5,%eax
  800e10:	8b 55 08             	mov    0x8(%ebp),%edx
  800e13:	89 cb                	mov    %ecx,%ebx
  800e15:	89 cf                	mov    %ecx,%edi
  800e17:	51                   	push   %ecx
  800e18:	52                   	push   %edx
  800e19:	53                   	push   %ebx
  800e1a:	54                   	push   %esp
  800e1b:	55                   	push   %ebp
  800e1c:	56                   	push   %esi
  800e1d:	57                   	push   %edi
  800e1e:	5f                   	pop    %edi
  800e1f:	5e                   	pop    %esi
  800e20:	5d                   	pop    %ebp
  800e21:	5c                   	pop    %esp
  800e22:	5b                   	pop    %ebx
  800e23:	5a                   	pop    %edx
  800e24:	59                   	pop    %ecx

int
sys_sbrk(uint32_t inc)
{
	 return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  800e25:	5b                   	pop    %ebx
  800e26:	5f                   	pop    %edi
  800e27:	5d                   	pop    %ebp
  800e28:	c3                   	ret    

00800e29 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800e29:	55                   	push   %ebp
  800e2a:	89 e5                	mov    %esp,%ebp
  800e2c:	56                   	push   %esi
  800e2d:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800e2e:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	if (argv0)
  800e31:	a1 08 20 80 00       	mov    0x802008,%eax
  800e36:	85 c0                	test   %eax,%eax
  800e38:	74 11                	je     800e4b <_panic+0x22>
		cprintf("%s: ", argv0);
  800e3a:	83 ec 08             	sub    $0x8,%esp
  800e3d:	50                   	push   %eax
  800e3e:	68 f7 13 80 00       	push   $0x8013f7
  800e43:	e8 4c f3 ff ff       	call   800194 <cprintf>
  800e48:	83 c4 10             	add    $0x10,%esp
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800e4b:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800e51:	e8 5b ff ff ff       	call   800db1 <sys_getenvid>
  800e56:	83 ec 0c             	sub    $0xc,%esp
  800e59:	ff 75 0c             	pushl  0xc(%ebp)
  800e5c:	ff 75 08             	pushl  0x8(%ebp)
  800e5f:	56                   	push   %esi
  800e60:	50                   	push   %eax
  800e61:	68 fc 13 80 00       	push   $0x8013fc
  800e66:	e8 29 f3 ff ff       	call   800194 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800e6b:	83 c4 18             	add    $0x18,%esp
  800e6e:	53                   	push   %ebx
  800e6f:	ff 75 10             	pushl  0x10(%ebp)
  800e72:	e8 cc f2 ff ff       	call   800143 <vcprintf>
	cprintf("\n");
  800e77:	c7 04 24 41 11 80 00 	movl   $0x801141,(%esp)
  800e7e:	e8 11 f3 ff ff       	call   800194 <cprintf>
  800e83:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800e86:	cc                   	int3   
  800e87:	eb fd                	jmp    800e86 <_panic+0x5d>
  800e89:	66 90                	xchg   %ax,%ax
  800e8b:	66 90                	xchg   %ax,%ax
  800e8d:	66 90                	xchg   %ax,%ax
  800e8f:	90                   	nop

00800e90 <__udivdi3>:
  800e90:	55                   	push   %ebp
  800e91:	57                   	push   %edi
  800e92:	56                   	push   %esi
  800e93:	53                   	push   %ebx
  800e94:	83 ec 1c             	sub    $0x1c,%esp
  800e97:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  800e9b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  800e9f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  800ea3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800ea7:	85 f6                	test   %esi,%esi
  800ea9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800ead:	89 ca                	mov    %ecx,%edx
  800eaf:	89 f8                	mov    %edi,%eax
  800eb1:	75 3d                	jne    800ef0 <__udivdi3+0x60>
  800eb3:	39 cf                	cmp    %ecx,%edi
  800eb5:	0f 87 c5 00 00 00    	ja     800f80 <__udivdi3+0xf0>
  800ebb:	85 ff                	test   %edi,%edi
  800ebd:	89 fd                	mov    %edi,%ebp
  800ebf:	75 0b                	jne    800ecc <__udivdi3+0x3c>
  800ec1:	b8 01 00 00 00       	mov    $0x1,%eax
  800ec6:	31 d2                	xor    %edx,%edx
  800ec8:	f7 f7                	div    %edi
  800eca:	89 c5                	mov    %eax,%ebp
  800ecc:	89 c8                	mov    %ecx,%eax
  800ece:	31 d2                	xor    %edx,%edx
  800ed0:	f7 f5                	div    %ebp
  800ed2:	89 c1                	mov    %eax,%ecx
  800ed4:	89 d8                	mov    %ebx,%eax
  800ed6:	89 cf                	mov    %ecx,%edi
  800ed8:	f7 f5                	div    %ebp
  800eda:	89 c3                	mov    %eax,%ebx
  800edc:	89 d8                	mov    %ebx,%eax
  800ede:	89 fa                	mov    %edi,%edx
  800ee0:	83 c4 1c             	add    $0x1c,%esp
  800ee3:	5b                   	pop    %ebx
  800ee4:	5e                   	pop    %esi
  800ee5:	5f                   	pop    %edi
  800ee6:	5d                   	pop    %ebp
  800ee7:	c3                   	ret    
  800ee8:	90                   	nop
  800ee9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800ef0:	39 ce                	cmp    %ecx,%esi
  800ef2:	77 74                	ja     800f68 <__udivdi3+0xd8>
  800ef4:	0f bd fe             	bsr    %esi,%edi
  800ef7:	83 f7 1f             	xor    $0x1f,%edi
  800efa:	0f 84 98 00 00 00    	je     800f98 <__udivdi3+0x108>
  800f00:	bb 20 00 00 00       	mov    $0x20,%ebx
  800f05:	89 f9                	mov    %edi,%ecx
  800f07:	89 c5                	mov    %eax,%ebp
  800f09:	29 fb                	sub    %edi,%ebx
  800f0b:	d3 e6                	shl    %cl,%esi
  800f0d:	89 d9                	mov    %ebx,%ecx
  800f0f:	d3 ed                	shr    %cl,%ebp
  800f11:	89 f9                	mov    %edi,%ecx
  800f13:	d3 e0                	shl    %cl,%eax
  800f15:	09 ee                	or     %ebp,%esi
  800f17:	89 d9                	mov    %ebx,%ecx
  800f19:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f1d:	89 d5                	mov    %edx,%ebp
  800f1f:	8b 44 24 08          	mov    0x8(%esp),%eax
  800f23:	d3 ed                	shr    %cl,%ebp
  800f25:	89 f9                	mov    %edi,%ecx
  800f27:	d3 e2                	shl    %cl,%edx
  800f29:	89 d9                	mov    %ebx,%ecx
  800f2b:	d3 e8                	shr    %cl,%eax
  800f2d:	09 c2                	or     %eax,%edx
  800f2f:	89 d0                	mov    %edx,%eax
  800f31:	89 ea                	mov    %ebp,%edx
  800f33:	f7 f6                	div    %esi
  800f35:	89 d5                	mov    %edx,%ebp
  800f37:	89 c3                	mov    %eax,%ebx
  800f39:	f7 64 24 0c          	mull   0xc(%esp)
  800f3d:	39 d5                	cmp    %edx,%ebp
  800f3f:	72 10                	jb     800f51 <__udivdi3+0xc1>
  800f41:	8b 74 24 08          	mov    0x8(%esp),%esi
  800f45:	89 f9                	mov    %edi,%ecx
  800f47:	d3 e6                	shl    %cl,%esi
  800f49:	39 c6                	cmp    %eax,%esi
  800f4b:	73 07                	jae    800f54 <__udivdi3+0xc4>
  800f4d:	39 d5                	cmp    %edx,%ebp
  800f4f:	75 03                	jne    800f54 <__udivdi3+0xc4>
  800f51:	83 eb 01             	sub    $0x1,%ebx
  800f54:	31 ff                	xor    %edi,%edi
  800f56:	89 d8                	mov    %ebx,%eax
  800f58:	89 fa                	mov    %edi,%edx
  800f5a:	83 c4 1c             	add    $0x1c,%esp
  800f5d:	5b                   	pop    %ebx
  800f5e:	5e                   	pop    %esi
  800f5f:	5f                   	pop    %edi
  800f60:	5d                   	pop    %ebp
  800f61:	c3                   	ret    
  800f62:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800f68:	31 ff                	xor    %edi,%edi
  800f6a:	31 db                	xor    %ebx,%ebx
  800f6c:	89 d8                	mov    %ebx,%eax
  800f6e:	89 fa                	mov    %edi,%edx
  800f70:	83 c4 1c             	add    $0x1c,%esp
  800f73:	5b                   	pop    %ebx
  800f74:	5e                   	pop    %esi
  800f75:	5f                   	pop    %edi
  800f76:	5d                   	pop    %ebp
  800f77:	c3                   	ret    
  800f78:	90                   	nop
  800f79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f80:	89 d8                	mov    %ebx,%eax
  800f82:	f7 f7                	div    %edi
  800f84:	31 ff                	xor    %edi,%edi
  800f86:	89 c3                	mov    %eax,%ebx
  800f88:	89 d8                	mov    %ebx,%eax
  800f8a:	89 fa                	mov    %edi,%edx
  800f8c:	83 c4 1c             	add    $0x1c,%esp
  800f8f:	5b                   	pop    %ebx
  800f90:	5e                   	pop    %esi
  800f91:	5f                   	pop    %edi
  800f92:	5d                   	pop    %ebp
  800f93:	c3                   	ret    
  800f94:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f98:	39 ce                	cmp    %ecx,%esi
  800f9a:	72 0c                	jb     800fa8 <__udivdi3+0x118>
  800f9c:	31 db                	xor    %ebx,%ebx
  800f9e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  800fa2:	0f 87 34 ff ff ff    	ja     800edc <__udivdi3+0x4c>
  800fa8:	bb 01 00 00 00       	mov    $0x1,%ebx
  800fad:	e9 2a ff ff ff       	jmp    800edc <__udivdi3+0x4c>
  800fb2:	66 90                	xchg   %ax,%ax
  800fb4:	66 90                	xchg   %ax,%ax
  800fb6:	66 90                	xchg   %ax,%ax
  800fb8:	66 90                	xchg   %ax,%ax
  800fba:	66 90                	xchg   %ax,%ax
  800fbc:	66 90                	xchg   %ax,%ax
  800fbe:	66 90                	xchg   %ax,%ax

00800fc0 <__umoddi3>:
  800fc0:	55                   	push   %ebp
  800fc1:	57                   	push   %edi
  800fc2:	56                   	push   %esi
  800fc3:	53                   	push   %ebx
  800fc4:	83 ec 1c             	sub    $0x1c,%esp
  800fc7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800fcb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  800fcf:	8b 74 24 34          	mov    0x34(%esp),%esi
  800fd3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800fd7:	85 d2                	test   %edx,%edx
  800fd9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800fdd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800fe1:	89 f3                	mov    %esi,%ebx
  800fe3:	89 3c 24             	mov    %edi,(%esp)
  800fe6:	89 74 24 04          	mov    %esi,0x4(%esp)
  800fea:	75 1c                	jne    801008 <__umoddi3+0x48>
  800fec:	39 f7                	cmp    %esi,%edi
  800fee:	76 50                	jbe    801040 <__umoddi3+0x80>
  800ff0:	89 c8                	mov    %ecx,%eax
  800ff2:	89 f2                	mov    %esi,%edx
  800ff4:	f7 f7                	div    %edi
  800ff6:	89 d0                	mov    %edx,%eax
  800ff8:	31 d2                	xor    %edx,%edx
  800ffa:	83 c4 1c             	add    $0x1c,%esp
  800ffd:	5b                   	pop    %ebx
  800ffe:	5e                   	pop    %esi
  800fff:	5f                   	pop    %edi
  801000:	5d                   	pop    %ebp
  801001:	c3                   	ret    
  801002:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801008:	39 f2                	cmp    %esi,%edx
  80100a:	89 d0                	mov    %edx,%eax
  80100c:	77 52                	ja     801060 <__umoddi3+0xa0>
  80100e:	0f bd ea             	bsr    %edx,%ebp
  801011:	83 f5 1f             	xor    $0x1f,%ebp
  801014:	75 5a                	jne    801070 <__umoddi3+0xb0>
  801016:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80101a:	0f 82 e0 00 00 00    	jb     801100 <__umoddi3+0x140>
  801020:	39 0c 24             	cmp    %ecx,(%esp)
  801023:	0f 86 d7 00 00 00    	jbe    801100 <__umoddi3+0x140>
  801029:	8b 44 24 08          	mov    0x8(%esp),%eax
  80102d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801031:	83 c4 1c             	add    $0x1c,%esp
  801034:	5b                   	pop    %ebx
  801035:	5e                   	pop    %esi
  801036:	5f                   	pop    %edi
  801037:	5d                   	pop    %ebp
  801038:	c3                   	ret    
  801039:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801040:	85 ff                	test   %edi,%edi
  801042:	89 fd                	mov    %edi,%ebp
  801044:	75 0b                	jne    801051 <__umoddi3+0x91>
  801046:	b8 01 00 00 00       	mov    $0x1,%eax
  80104b:	31 d2                	xor    %edx,%edx
  80104d:	f7 f7                	div    %edi
  80104f:	89 c5                	mov    %eax,%ebp
  801051:	89 f0                	mov    %esi,%eax
  801053:	31 d2                	xor    %edx,%edx
  801055:	f7 f5                	div    %ebp
  801057:	89 c8                	mov    %ecx,%eax
  801059:	f7 f5                	div    %ebp
  80105b:	89 d0                	mov    %edx,%eax
  80105d:	eb 99                	jmp    800ff8 <__umoddi3+0x38>
  80105f:	90                   	nop
  801060:	89 c8                	mov    %ecx,%eax
  801062:	89 f2                	mov    %esi,%edx
  801064:	83 c4 1c             	add    $0x1c,%esp
  801067:	5b                   	pop    %ebx
  801068:	5e                   	pop    %esi
  801069:	5f                   	pop    %edi
  80106a:	5d                   	pop    %ebp
  80106b:	c3                   	ret    
  80106c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801070:	8b 34 24             	mov    (%esp),%esi
  801073:	bf 20 00 00 00       	mov    $0x20,%edi
  801078:	89 e9                	mov    %ebp,%ecx
  80107a:	29 ef                	sub    %ebp,%edi
  80107c:	d3 e0                	shl    %cl,%eax
  80107e:	89 f9                	mov    %edi,%ecx
  801080:	89 f2                	mov    %esi,%edx
  801082:	d3 ea                	shr    %cl,%edx
  801084:	89 e9                	mov    %ebp,%ecx
  801086:	09 c2                	or     %eax,%edx
  801088:	89 d8                	mov    %ebx,%eax
  80108a:	89 14 24             	mov    %edx,(%esp)
  80108d:	89 f2                	mov    %esi,%edx
  80108f:	d3 e2                	shl    %cl,%edx
  801091:	89 f9                	mov    %edi,%ecx
  801093:	89 54 24 04          	mov    %edx,0x4(%esp)
  801097:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80109b:	d3 e8                	shr    %cl,%eax
  80109d:	89 e9                	mov    %ebp,%ecx
  80109f:	89 c6                	mov    %eax,%esi
  8010a1:	d3 e3                	shl    %cl,%ebx
  8010a3:	89 f9                	mov    %edi,%ecx
  8010a5:	89 d0                	mov    %edx,%eax
  8010a7:	d3 e8                	shr    %cl,%eax
  8010a9:	89 e9                	mov    %ebp,%ecx
  8010ab:	09 d8                	or     %ebx,%eax
  8010ad:	89 d3                	mov    %edx,%ebx
  8010af:	89 f2                	mov    %esi,%edx
  8010b1:	f7 34 24             	divl   (%esp)
  8010b4:	89 d6                	mov    %edx,%esi
  8010b6:	d3 e3                	shl    %cl,%ebx
  8010b8:	f7 64 24 04          	mull   0x4(%esp)
  8010bc:	39 d6                	cmp    %edx,%esi
  8010be:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8010c2:	89 d1                	mov    %edx,%ecx
  8010c4:	89 c3                	mov    %eax,%ebx
  8010c6:	72 08                	jb     8010d0 <__umoddi3+0x110>
  8010c8:	75 11                	jne    8010db <__umoddi3+0x11b>
  8010ca:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8010ce:	73 0b                	jae    8010db <__umoddi3+0x11b>
  8010d0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8010d4:	1b 14 24             	sbb    (%esp),%edx
  8010d7:	89 d1                	mov    %edx,%ecx
  8010d9:	89 c3                	mov    %eax,%ebx
  8010db:	8b 54 24 08          	mov    0x8(%esp),%edx
  8010df:	29 da                	sub    %ebx,%edx
  8010e1:	19 ce                	sbb    %ecx,%esi
  8010e3:	89 f9                	mov    %edi,%ecx
  8010e5:	89 f0                	mov    %esi,%eax
  8010e7:	d3 e0                	shl    %cl,%eax
  8010e9:	89 e9                	mov    %ebp,%ecx
  8010eb:	d3 ea                	shr    %cl,%edx
  8010ed:	89 e9                	mov    %ebp,%ecx
  8010ef:	d3 ee                	shr    %cl,%esi
  8010f1:	09 d0                	or     %edx,%eax
  8010f3:	89 f2                	mov    %esi,%edx
  8010f5:	83 c4 1c             	add    $0x1c,%esp
  8010f8:	5b                   	pop    %ebx
  8010f9:	5e                   	pop    %esi
  8010fa:	5f                   	pop    %edi
  8010fb:	5d                   	pop    %ebp
  8010fc:	c3                   	ret    
  8010fd:	8d 76 00             	lea    0x0(%esi),%esi
  801100:	29 f9                	sub    %edi,%ecx
  801102:	19 d6                	sbb    %edx,%esi
  801104:	89 74 24 04          	mov    %esi,0x4(%esp)
  801108:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80110c:	e9 18 ff ff ff       	jmp    801029 <__umoddi3+0x69>
