
obj/kern/kernel:     file format elf32-i386


Disassembly of section .text:

f0100000 <_start+0xeffffff4>:
.globl		_start
_start = RELOC(entry)

.globl entry
entry:
	movw	$0x1234,0x472			# warm boot
f0100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
f0100006:	00 00                	add    %al,(%eax)
f0100008:	fe 4f 52             	decb   0x52(%edi)
f010000b:	e4                   	.byte 0xe4

f010000c <entry>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 
	# physical addresses [0, 4MB).  This 4MB region will be suffice
	# until we set up our real page table in mem_init in lab 2.

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	movl	$(RELOC(entry_pgdir)), %eax
f0100015:	b8 00 90 11 00       	mov    $0x119000,%eax
	movl	%eax, %cr3
f010001a:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl	%cr0, %eax
f010001d:	0f 20 c0             	mov    %cr0,%eax
	orl	$(CR0_PE|CR0_PG|CR0_WP), %eax
f0100020:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl	%eax, %cr0
f0100025:	0f 22 c0             	mov    %eax,%cr0

	# Now paging is enabled, but we're still running at a low EIP
	# (why is this okay?).  Jump up above KERNBASE before entering
	# C code.
	mov	$relocated, %eax
f0100028:	b8 2f 00 10 f0       	mov    $0xf010002f,%eax
	jmp	*%eax
f010002d:	ff e0                	jmp    *%eax

f010002f <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
f010002f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Set the stack pointer
	movl	$(bootstacktop),%esp
f0100034:	bc 00 90 11 f0       	mov    $0xf0119000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 02 00 00 00       	call   f0100040 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <i386_init>:
#include <kern/trap.h>


void
i386_init(void)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	83 ec 0c             	sub    $0xc,%esp
	char ntest[256] = {};

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f0100046:	b8 70 01 19 f0       	mov    $0xf0190170,%eax
f010004b:	2d 52 f2 18 f0       	sub    $0xf018f252,%eax
f0100050:	50                   	push   %eax
f0100051:	6a 00                	push   $0x0
f0100053:	68 52 f2 18 f0       	push   $0xf018f252
f0100058:	e8 27 41 00 00       	call   f0104184 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f010005d:	e8 d8 04 00 00       	call   f010053a <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f0100062:	83 c4 08             	add    $0x8,%esp
f0100065:	68 ac 1a 00 00       	push   $0x1aac
f010006a:	68 60 46 10 f0       	push   $0xf0104660
f010006f:	e8 b6 2f 00 00       	call   f010302a <cprintf>
	cprintf("pading space in the right to number 22: %-8d.\n", 22);
f0100074:	83 c4 08             	add    $0x8,%esp
f0100077:	6a 16                	push   $0x16
f0100079:	68 cc 46 10 f0       	push   $0xf01046cc
f010007e:	e8 a7 2f 00 00       	call   f010302a <cprintf>
	cprintf("show me the sign: %+d, %+d\n", 1024, -1024);
f0100083:	83 c4 0c             	add    $0xc,%esp
f0100086:	68 00 fc ff ff       	push   $0xfffffc00
f010008b:	68 00 04 00 00       	push   $0x400
f0100090:	68 7b 46 10 f0       	push   $0xf010467b
f0100095:	e8 90 2f 00 00       	call   f010302a <cprintf>


	// Lab 2 memory management initialization functions
	mem_init();
f010009a:	e8 45 14 00 00       	call   f01014e4 <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f010009f:	e8 c6 2b 00 00       	call   f0102c6a <env_init>
	trap_init();
f01000a4:	e8 f2 2f 00 00       	call   f010309b <trap_init>
#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
#else
	// Touch all you want.
	ENV_CREATE(user_hello, ENV_TYPE_USER);
f01000a9:	83 c4 0c             	add    $0xc,%esp
f01000ac:	6a 00                	push   $0x0
f01000ae:	68 6c 78 00 00       	push   $0x786c
f01000b3:	68 56 b3 11 f0       	push   $0xf011b356
f01000b8:	e8 d1 2c 00 00       	call   f0102d8e <env_create>
#endif // TEST*

	// We only have one user environment for now, so just run it.
	env_run(&envs[0]);
f01000bd:	83 c4 04             	add    $0x4,%esp
f01000c0:	ff 35 a8 f4 18 f0    	pushl  0xf018f4a8
f01000c6:	e8 d4 2e 00 00       	call   f0102f9f <env_run>

f01000cb <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f01000cb:	55                   	push   %ebp
f01000cc:	89 e5                	mov    %esp,%ebp
f01000ce:	56                   	push   %esi
f01000cf:	53                   	push   %ebx
f01000d0:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f01000d3:	83 3d 60 01 19 f0 00 	cmpl   $0x0,0xf0190160
f01000da:	75 37                	jne    f0100113 <_panic+0x48>
		goto dead;
	panicstr = fmt;
f01000dc:	89 35 60 01 19 f0    	mov    %esi,0xf0190160

	// Be extra sure that the machine is in as reasonable state
	__asm __volatile("cli; cld");
f01000e2:	fa                   	cli    
f01000e3:	fc                   	cld    

	va_start(ap, fmt);
f01000e4:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic at %s:%d: ", file, line);
f01000e7:	83 ec 04             	sub    $0x4,%esp
f01000ea:	ff 75 0c             	pushl  0xc(%ebp)
f01000ed:	ff 75 08             	pushl  0x8(%ebp)
f01000f0:	68 97 46 10 f0       	push   $0xf0104697
f01000f5:	e8 30 2f 00 00       	call   f010302a <cprintf>
	vcprintf(fmt, ap);
f01000fa:	83 c4 08             	add    $0x8,%esp
f01000fd:	53                   	push   %ebx
f01000fe:	56                   	push   %esi
f01000ff:	e8 00 2f 00 00       	call   f0103004 <vcprintf>
	cprintf("\n");
f0100104:	c7 04 24 59 56 10 f0 	movl   $0xf0105659,(%esp)
f010010b:	e8 1a 2f 00 00       	call   f010302a <cprintf>
	va_end(ap);
f0100110:	83 c4 10             	add    $0x10,%esp

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f0100113:	83 ec 0c             	sub    $0xc,%esp
f0100116:	6a 00                	push   $0x0
f0100118:	e8 93 0a 00 00       	call   f0100bb0 <monitor>
f010011d:	83 c4 10             	add    $0x10,%esp
f0100120:	eb f1                	jmp    f0100113 <_panic+0x48>

f0100122 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f0100122:	55                   	push   %ebp
f0100123:	89 e5                	mov    %esp,%ebp
f0100125:	53                   	push   %ebx
f0100126:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0100129:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f010012c:	ff 75 0c             	pushl  0xc(%ebp)
f010012f:	ff 75 08             	pushl  0x8(%ebp)
f0100132:	68 af 46 10 f0       	push   $0xf01046af
f0100137:	e8 ee 2e 00 00       	call   f010302a <cprintf>
	vcprintf(fmt, ap);
f010013c:	83 c4 08             	add    $0x8,%esp
f010013f:	53                   	push   %ebx
f0100140:	ff 75 10             	pushl  0x10(%ebp)
f0100143:	e8 bc 2e 00 00       	call   f0103004 <vcprintf>
	cprintf("\n");
f0100148:	c7 04 24 59 56 10 f0 	movl   $0xf0105659,(%esp)
f010014f:	e8 d6 2e 00 00       	call   f010302a <cprintf>
	va_end(ap);
}
f0100154:	83 c4 10             	add    $0x10,%esp
f0100157:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010015a:	c9                   	leave  
f010015b:	c3                   	ret    

f010015c <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f010015c:	55                   	push   %ebp
f010015d:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010015f:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100164:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f0100165:	a8 01                	test   $0x1,%al
f0100167:	74 0b                	je     f0100174 <serial_proc_data+0x18>
f0100169:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010016e:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f010016f:	0f b6 c0             	movzbl %al,%eax
f0100172:	eb 05                	jmp    f0100179 <serial_proc_data+0x1d>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f0100174:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f0100179:	5d                   	pop    %ebp
f010017a:	c3                   	ret    

f010017b <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f010017b:	55                   	push   %ebp
f010017c:	89 e5                	mov    %esp,%ebp
f010017e:	53                   	push   %ebx
f010017f:	83 ec 04             	sub    $0x4,%esp
f0100182:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f0100184:	eb 2b                	jmp    f01001b1 <cons_intr+0x36>
		if (c == 0)
f0100186:	85 c0                	test   %eax,%eax
f0100188:	74 27                	je     f01001b1 <cons_intr+0x36>
			continue;
		cons.buf[cons.wpos++] = c;
f010018a:	8b 0d 84 f4 18 f0    	mov    0xf018f484,%ecx
f0100190:	8d 51 01             	lea    0x1(%ecx),%edx
f0100193:	89 15 84 f4 18 f0    	mov    %edx,0xf018f484
f0100199:	88 81 80 f2 18 f0    	mov    %al,-0xfe70d80(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f010019f:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01001a5:	75 0a                	jne    f01001b1 <cons_intr+0x36>
			cons.wpos = 0;
f01001a7:	c7 05 84 f4 18 f0 00 	movl   $0x0,0xf018f484
f01001ae:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f01001b1:	ff d3                	call   *%ebx
f01001b3:	83 f8 ff             	cmp    $0xffffffff,%eax
f01001b6:	75 ce                	jne    f0100186 <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f01001b8:	83 c4 04             	add    $0x4,%esp
f01001bb:	5b                   	pop    %ebx
f01001bc:	5d                   	pop    %ebp
f01001bd:	c3                   	ret    

f01001be <kbd_proc_data>:
f01001be:	ba 64 00 00 00       	mov    $0x64,%edx
f01001c3:	ec                   	in     (%dx),%al
{
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f01001c4:	a8 01                	test   $0x1,%al
f01001c6:	0f 84 f0 00 00 00    	je     f01002bc <kbd_proc_data+0xfe>
f01001cc:	ba 60 00 00 00       	mov    $0x60,%edx
f01001d1:	ec                   	in     (%dx),%al
f01001d2:	89 c2                	mov    %eax,%edx
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f01001d4:	3c e0                	cmp    $0xe0,%al
f01001d6:	75 0d                	jne    f01001e5 <kbd_proc_data+0x27>
		// E0 escape character
		shift |= E0ESC;
f01001d8:	83 0d 60 f2 18 f0 40 	orl    $0x40,0xf018f260
		return 0;
f01001df:	b8 00 00 00 00       	mov    $0x0,%eax
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f01001e4:	c3                   	ret    
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f01001e5:	55                   	push   %ebp
f01001e6:	89 e5                	mov    %esp,%ebp
f01001e8:	53                   	push   %ebx
f01001e9:	83 ec 04             	sub    $0x4,%esp

	if (data == 0xE0) {
		// E0 escape character
		shift |= E0ESC;
		return 0;
	} else if (data & 0x80) {
f01001ec:	84 c0                	test   %al,%al
f01001ee:	79 36                	jns    f0100226 <kbd_proc_data+0x68>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f01001f0:	8b 0d 60 f2 18 f0    	mov    0xf018f260,%ecx
f01001f6:	89 cb                	mov    %ecx,%ebx
f01001f8:	83 e3 40             	and    $0x40,%ebx
f01001fb:	83 e0 7f             	and    $0x7f,%eax
f01001fe:	85 db                	test   %ebx,%ebx
f0100200:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f0100203:	0f b6 d2             	movzbl %dl,%edx
f0100206:	0f b6 82 60 48 10 f0 	movzbl -0xfefb7a0(%edx),%eax
f010020d:	83 c8 40             	or     $0x40,%eax
f0100210:	0f b6 c0             	movzbl %al,%eax
f0100213:	f7 d0                	not    %eax
f0100215:	21 c8                	and    %ecx,%eax
f0100217:	a3 60 f2 18 f0       	mov    %eax,0xf018f260
		return 0;
f010021c:	b8 00 00 00 00       	mov    $0x0,%eax
f0100221:	e9 9e 00 00 00       	jmp    f01002c4 <kbd_proc_data+0x106>
	} else if (shift & E0ESC) {
f0100226:	8b 0d 60 f2 18 f0    	mov    0xf018f260,%ecx
f010022c:	f6 c1 40             	test   $0x40,%cl
f010022f:	74 0e                	je     f010023f <kbd_proc_data+0x81>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f0100231:	83 c8 80             	or     $0xffffff80,%eax
f0100234:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f0100236:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100239:	89 0d 60 f2 18 f0    	mov    %ecx,0xf018f260
	}

	shift |= shiftcode[data];
f010023f:	0f b6 d2             	movzbl %dl,%edx
	shift ^= togglecode[data];
f0100242:	0f b6 82 60 48 10 f0 	movzbl -0xfefb7a0(%edx),%eax
f0100249:	0b 05 60 f2 18 f0    	or     0xf018f260,%eax
f010024f:	0f b6 8a 60 47 10 f0 	movzbl -0xfefb8a0(%edx),%ecx
f0100256:	31 c8                	xor    %ecx,%eax
f0100258:	a3 60 f2 18 f0       	mov    %eax,0xf018f260

	c = charcode[shift & (CTL | SHIFT)][data];
f010025d:	89 c1                	mov    %eax,%ecx
f010025f:	83 e1 03             	and    $0x3,%ecx
f0100262:	8b 0c 8d 40 47 10 f0 	mov    -0xfefb8c0(,%ecx,4),%ecx
f0100269:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f010026d:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f0100270:	a8 08                	test   $0x8,%al
f0100272:	74 1b                	je     f010028f <kbd_proc_data+0xd1>
		if ('a' <= c && c <= 'z')
f0100274:	89 da                	mov    %ebx,%edx
f0100276:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f0100279:	83 f9 19             	cmp    $0x19,%ecx
f010027c:	77 05                	ja     f0100283 <kbd_proc_data+0xc5>
			c += 'A' - 'a';
f010027e:	83 eb 20             	sub    $0x20,%ebx
f0100281:	eb 0c                	jmp    f010028f <kbd_proc_data+0xd1>
		else if ('A' <= c && c <= 'Z')
f0100283:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f0100286:	8d 4b 20             	lea    0x20(%ebx),%ecx
f0100289:	83 fa 19             	cmp    $0x19,%edx
f010028c:	0f 46 d9             	cmovbe %ecx,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f010028f:	f7 d0                	not    %eax
f0100291:	a8 06                	test   $0x6,%al
f0100293:	75 2d                	jne    f01002c2 <kbd_proc_data+0x104>
f0100295:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f010029b:	75 25                	jne    f01002c2 <kbd_proc_data+0x104>
		cprintf("Rebooting!\n");
f010029d:	83 ec 0c             	sub    $0xc,%esp
f01002a0:	68 fb 46 10 f0       	push   $0xf01046fb
f01002a5:	e8 80 2d 00 00       	call   f010302a <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01002aa:	ba 92 00 00 00       	mov    $0x92,%edx
f01002af:	b8 03 00 00 00       	mov    $0x3,%eax
f01002b4:	ee                   	out    %al,(%dx)
f01002b5:	83 c4 10             	add    $0x10,%esp
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01002b8:	89 d8                	mov    %ebx,%eax
f01002ba:	eb 08                	jmp    f01002c4 <kbd_proc_data+0x106>
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
		return -1;
f01002bc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01002c1:	c3                   	ret    
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01002c2:	89 d8                	mov    %ebx,%eax
}
f01002c4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01002c7:	c9                   	leave  
f01002c8:	c3                   	ret    

f01002c9 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f01002c9:	55                   	push   %ebp
f01002ca:	89 e5                	mov    %esp,%ebp
f01002cc:	57                   	push   %edi
f01002cd:	56                   	push   %esi
f01002ce:	53                   	push   %ebx
f01002cf:	83 ec 1c             	sub    $0x1c,%esp
f01002d2:	89 c7                	mov    %eax,%edi

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002d4:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01002d9:	ec                   	in     (%dx),%al
serial_putc(int c)
{
	int i;
	
	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f01002da:	a8 20                	test   $0x20,%al
f01002dc:	75 27                	jne    f0100305 <cons_putc+0x3c>
f01002de:	bb 00 00 00 00       	mov    $0x0,%ebx
f01002e3:	b9 84 00 00 00       	mov    $0x84,%ecx
f01002e8:	be fd 03 00 00       	mov    $0x3fd,%esi
f01002ed:	89 ca                	mov    %ecx,%edx
f01002ef:	ec                   	in     (%dx),%al
f01002f0:	ec                   	in     (%dx),%al
f01002f1:	ec                   	in     (%dx),%al
f01002f2:	ec                   	in     (%dx),%al
	     i++)
f01002f3:	83 c3 01             	add    $0x1,%ebx
f01002f6:	89 f2                	mov    %esi,%edx
f01002f8:	ec                   	in     (%dx),%al
serial_putc(int c)
{
	int i;
	
	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f01002f9:	a8 20                	test   $0x20,%al
f01002fb:	75 08                	jne    f0100305 <cons_putc+0x3c>
f01002fd:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f0100303:	7e e8                	jle    f01002ed <cons_putc+0x24>
f0100305:	89 f8                	mov    %edi,%eax
f0100307:	88 45 e7             	mov    %al,-0x19(%ebp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010030a:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010030f:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100310:	ba 79 03 00 00       	mov    $0x379,%edx
f0100315:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f0100316:	84 c0                	test   %al,%al
f0100318:	78 27                	js     f0100341 <cons_putc+0x78>
f010031a:	bb 00 00 00 00       	mov    $0x0,%ebx
f010031f:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100324:	be 79 03 00 00       	mov    $0x379,%esi
f0100329:	89 ca                	mov    %ecx,%edx
f010032b:	ec                   	in     (%dx),%al
f010032c:	ec                   	in     (%dx),%al
f010032d:	ec                   	in     (%dx),%al
f010032e:	ec                   	in     (%dx),%al
f010032f:	83 c3 01             	add    $0x1,%ebx
f0100332:	89 f2                	mov    %esi,%edx
f0100334:	ec                   	in     (%dx),%al
f0100335:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f010033b:	7f 04                	jg     f0100341 <cons_putc+0x78>
f010033d:	84 c0                	test   %al,%al
f010033f:	79 e8                	jns    f0100329 <cons_putc+0x60>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100341:	ba 78 03 00 00       	mov    $0x378,%edx
f0100346:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f010034a:	ee                   	out    %al,(%dx)
f010034b:	ba 7a 03 00 00       	mov    $0x37a,%edx
f0100350:	b8 0d 00 00 00       	mov    $0xd,%eax
f0100355:	ee                   	out    %al,(%dx)
f0100356:	b8 08 00 00 00       	mov    $0x8,%eax
f010035b:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f010035c:	89 fa                	mov    %edi,%edx
f010035e:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f0100364:	89 f8                	mov    %edi,%eax
f0100366:	80 cc 07             	or     $0x7,%ah
f0100369:	85 d2                	test   %edx,%edx
f010036b:	0f 44 f8             	cmove  %eax,%edi

	switch (c & 0xff) {
f010036e:	89 f8                	mov    %edi,%eax
f0100370:	0f b6 c0             	movzbl %al,%eax
f0100373:	83 f8 09             	cmp    $0x9,%eax
f0100376:	74 74                	je     f01003ec <cons_putc+0x123>
f0100378:	83 f8 09             	cmp    $0x9,%eax
f010037b:	7f 0a                	jg     f0100387 <cons_putc+0xbe>
f010037d:	83 f8 08             	cmp    $0x8,%eax
f0100380:	74 14                	je     f0100396 <cons_putc+0xcd>
f0100382:	e9 99 00 00 00       	jmp    f0100420 <cons_putc+0x157>
f0100387:	83 f8 0a             	cmp    $0xa,%eax
f010038a:	74 3a                	je     f01003c6 <cons_putc+0xfd>
f010038c:	83 f8 0d             	cmp    $0xd,%eax
f010038f:	74 3d                	je     f01003ce <cons_putc+0x105>
f0100391:	e9 8a 00 00 00       	jmp    f0100420 <cons_putc+0x157>
	case '\b':
		if (crt_pos > 0) {
f0100396:	0f b7 05 88 f4 18 f0 	movzwl 0xf018f488,%eax
f010039d:	66 85 c0             	test   %ax,%ax
f01003a0:	0f 84 e6 00 00 00    	je     f010048c <cons_putc+0x1c3>
			crt_pos--;
f01003a6:	83 e8 01             	sub    $0x1,%eax
f01003a9:	66 a3 88 f4 18 f0    	mov    %ax,0xf018f488
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01003af:	0f b7 c0             	movzwl %ax,%eax
f01003b2:	66 81 e7 00 ff       	and    $0xff00,%di
f01003b7:	83 cf 20             	or     $0x20,%edi
f01003ba:	8b 15 8c f4 18 f0    	mov    0xf018f48c,%edx
f01003c0:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f01003c4:	eb 78                	jmp    f010043e <cons_putc+0x175>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f01003c6:	66 83 05 88 f4 18 f0 	addw   $0x50,0xf018f488
f01003cd:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f01003ce:	0f b7 05 88 f4 18 f0 	movzwl 0xf018f488,%eax
f01003d5:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01003db:	c1 e8 16             	shr    $0x16,%eax
f01003de:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01003e1:	c1 e0 04             	shl    $0x4,%eax
f01003e4:	66 a3 88 f4 18 f0    	mov    %ax,0xf018f488
f01003ea:	eb 52                	jmp    f010043e <cons_putc+0x175>
		break;
	case '\t':
		cons_putc(' ');
f01003ec:	b8 20 00 00 00       	mov    $0x20,%eax
f01003f1:	e8 d3 fe ff ff       	call   f01002c9 <cons_putc>
		cons_putc(' ');
f01003f6:	b8 20 00 00 00       	mov    $0x20,%eax
f01003fb:	e8 c9 fe ff ff       	call   f01002c9 <cons_putc>
		cons_putc(' ');
f0100400:	b8 20 00 00 00       	mov    $0x20,%eax
f0100405:	e8 bf fe ff ff       	call   f01002c9 <cons_putc>
		cons_putc(' ');
f010040a:	b8 20 00 00 00       	mov    $0x20,%eax
f010040f:	e8 b5 fe ff ff       	call   f01002c9 <cons_putc>
		cons_putc(' ');
f0100414:	b8 20 00 00 00       	mov    $0x20,%eax
f0100419:	e8 ab fe ff ff       	call   f01002c9 <cons_putc>
f010041e:	eb 1e                	jmp    f010043e <cons_putc+0x175>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f0100420:	0f b7 05 88 f4 18 f0 	movzwl 0xf018f488,%eax
f0100427:	8d 50 01             	lea    0x1(%eax),%edx
f010042a:	66 89 15 88 f4 18 f0 	mov    %dx,0xf018f488
f0100431:	0f b7 c0             	movzwl %ax,%eax
f0100434:	8b 15 8c f4 18 f0    	mov    0xf018f48c,%edx
f010043a:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f010043e:	66 81 3d 88 f4 18 f0 	cmpw   $0x7cf,0xf018f488
f0100445:	cf 07 
f0100447:	76 43                	jbe    f010048c <cons_putc+0x1c3>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100449:	a1 8c f4 18 f0       	mov    0xf018f48c,%eax
f010044e:	83 ec 04             	sub    $0x4,%esp
f0100451:	68 00 0f 00 00       	push   $0xf00
f0100456:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f010045c:	52                   	push   %edx
f010045d:	50                   	push   %eax
f010045e:	e8 6e 3d 00 00       	call   f01041d1 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f0100463:	8b 15 8c f4 18 f0    	mov    0xf018f48c,%edx
f0100469:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f010046f:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f0100475:	83 c4 10             	add    $0x10,%esp
f0100478:	66 c7 00 20 07       	movw   $0x720,(%eax)
f010047d:	83 c0 02             	add    $0x2,%eax
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100480:	39 c2                	cmp    %eax,%edx
f0100482:	75 f4                	jne    f0100478 <cons_putc+0x1af>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f0100484:	66 83 2d 88 f4 18 f0 	subw   $0x50,0xf018f488
f010048b:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f010048c:	8b 0d 90 f4 18 f0    	mov    0xf018f490,%ecx
f0100492:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100497:	89 ca                	mov    %ecx,%edx
f0100499:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f010049a:	0f b7 1d 88 f4 18 f0 	movzwl 0xf018f488,%ebx
f01004a1:	8d 71 01             	lea    0x1(%ecx),%esi
f01004a4:	89 d8                	mov    %ebx,%eax
f01004a6:	66 c1 e8 08          	shr    $0x8,%ax
f01004aa:	89 f2                	mov    %esi,%edx
f01004ac:	ee                   	out    %al,(%dx)
f01004ad:	b8 0f 00 00 00       	mov    $0xf,%eax
f01004b2:	89 ca                	mov    %ecx,%edx
f01004b4:	ee                   	out    %al,(%dx)
f01004b5:	89 d8                	mov    %ebx,%eax
f01004b7:	89 f2                	mov    %esi,%edx
f01004b9:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f01004ba:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01004bd:	5b                   	pop    %ebx
f01004be:	5e                   	pop    %esi
f01004bf:	5f                   	pop    %edi
f01004c0:	5d                   	pop    %ebp
f01004c1:	c3                   	ret    

f01004c2 <serial_intr>:
}

void
serial_intr(void)
{
	if (serial_exists)
f01004c2:	83 3d 94 f4 18 f0 00 	cmpl   $0x0,0xf018f494
f01004c9:	74 11                	je     f01004dc <serial_intr+0x1a>
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f01004cb:	55                   	push   %ebp
f01004cc:	89 e5                	mov    %esp,%ebp
f01004ce:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
		cons_intr(serial_proc_data);
f01004d1:	b8 5c 01 10 f0       	mov    $0xf010015c,%eax
f01004d6:	e8 a0 fc ff ff       	call   f010017b <cons_intr>
}
f01004db:	c9                   	leave  
f01004dc:	f3 c3                	repz ret 

f01004de <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f01004de:	55                   	push   %ebp
f01004df:	89 e5                	mov    %esp,%ebp
f01004e1:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f01004e4:	b8 be 01 10 f0       	mov    $0xf01001be,%eax
f01004e9:	e8 8d fc ff ff       	call   f010017b <cons_intr>
}
f01004ee:	c9                   	leave  
f01004ef:	c3                   	ret    

f01004f0 <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f01004f0:	55                   	push   %ebp
f01004f1:	89 e5                	mov    %esp,%ebp
f01004f3:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f01004f6:	e8 c7 ff ff ff       	call   f01004c2 <serial_intr>
	kbd_intr();
f01004fb:	e8 de ff ff ff       	call   f01004de <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f0100500:	a1 80 f4 18 f0       	mov    0xf018f480,%eax
f0100505:	3b 05 84 f4 18 f0    	cmp    0xf018f484,%eax
f010050b:	74 26                	je     f0100533 <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f010050d:	8d 50 01             	lea    0x1(%eax),%edx
f0100510:	89 15 80 f4 18 f0    	mov    %edx,0xf018f480
f0100516:	0f b6 88 80 f2 18 f0 	movzbl -0xfe70d80(%eax),%ecx
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
f010051d:	89 c8                	mov    %ecx,%eax
	kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
f010051f:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f0100525:	75 11                	jne    f0100538 <cons_getc+0x48>
			cons.rpos = 0;
f0100527:	c7 05 80 f4 18 f0 00 	movl   $0x0,0xf018f480
f010052e:	00 00 00 
f0100531:	eb 05                	jmp    f0100538 <cons_getc+0x48>
		return c;
	}
	return 0;
f0100533:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100538:	c9                   	leave  
f0100539:	c3                   	ret    

f010053a <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f010053a:	55                   	push   %ebp
f010053b:	89 e5                	mov    %esp,%ebp
f010053d:	57                   	push   %edi
f010053e:	56                   	push   %esi
f010053f:	53                   	push   %ebx
f0100540:	83 ec 0c             	sub    $0xc,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f0100543:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f010054a:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100551:	5a a5 
	if (*cp != 0xA55A) {
f0100553:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f010055a:	66 3d 5a a5          	cmp    $0xa55a,%ax
f010055e:	74 11                	je     f0100571 <cons_init+0x37>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f0100560:	c7 05 90 f4 18 f0 b4 	movl   $0x3b4,0xf018f490
f0100567:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f010056a:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f010056f:	eb 16                	jmp    f0100587 <cons_init+0x4d>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f0100571:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f0100578:	c7 05 90 f4 18 f0 d4 	movl   $0x3d4,0xf018f490
f010057f:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f0100582:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}
	
	/* Extract cursor location */
	outb(addr_6845, 14);
f0100587:	8b 3d 90 f4 18 f0    	mov    0xf018f490,%edi
f010058d:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100592:	89 fa                	mov    %edi,%edx
f0100594:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f0100595:	8d 5f 01             	lea    0x1(%edi),%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100598:	89 da                	mov    %ebx,%edx
f010059a:	ec                   	in     (%dx),%al
f010059b:	0f b6 c8             	movzbl %al,%ecx
f010059e:	c1 e1 08             	shl    $0x8,%ecx
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01005a1:	b8 0f 00 00 00       	mov    $0xf,%eax
f01005a6:	89 fa                	mov    %edi,%edx
f01005a8:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005a9:	89 da                	mov    %ebx,%edx
f01005ab:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f01005ac:	89 35 8c f4 18 f0    	mov    %esi,0xf018f48c
	crt_pos = pos;
f01005b2:	0f b6 c0             	movzbl %al,%eax
f01005b5:	09 c8                	or     %ecx,%eax
f01005b7:	66 a3 88 f4 18 f0    	mov    %ax,0xf018f488
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01005bd:	be fa 03 00 00       	mov    $0x3fa,%esi
f01005c2:	b8 00 00 00 00       	mov    $0x0,%eax
f01005c7:	89 f2                	mov    %esi,%edx
f01005c9:	ee                   	out    %al,(%dx)
f01005ca:	ba fb 03 00 00       	mov    $0x3fb,%edx
f01005cf:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f01005d4:	ee                   	out    %al,(%dx)
f01005d5:	bb f8 03 00 00       	mov    $0x3f8,%ebx
f01005da:	b8 0c 00 00 00       	mov    $0xc,%eax
f01005df:	89 da                	mov    %ebx,%edx
f01005e1:	ee                   	out    %al,(%dx)
f01005e2:	ba f9 03 00 00       	mov    $0x3f9,%edx
f01005e7:	b8 00 00 00 00       	mov    $0x0,%eax
f01005ec:	ee                   	out    %al,(%dx)
f01005ed:	ba fb 03 00 00       	mov    $0x3fb,%edx
f01005f2:	b8 03 00 00 00       	mov    $0x3,%eax
f01005f7:	ee                   	out    %al,(%dx)
f01005f8:	ba fc 03 00 00       	mov    $0x3fc,%edx
f01005fd:	b8 00 00 00 00       	mov    $0x0,%eax
f0100602:	ee                   	out    %al,(%dx)
f0100603:	ba f9 03 00 00       	mov    $0x3f9,%edx
f0100608:	b8 01 00 00 00       	mov    $0x1,%eax
f010060d:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010060e:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100613:	ec                   	in     (%dx),%al
f0100614:	89 c1                	mov    %eax,%ecx
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f0100616:	3c ff                	cmp    $0xff,%al
f0100618:	0f 95 c0             	setne  %al
f010061b:	0f b6 c0             	movzbl %al,%eax
f010061e:	a3 94 f4 18 f0       	mov    %eax,0xf018f494
f0100623:	89 f2                	mov    %esi,%edx
f0100625:	ec                   	in     (%dx),%al
f0100626:	89 da                	mov    %ebx,%edx
f0100628:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f0100629:	80 f9 ff             	cmp    $0xff,%cl
f010062c:	75 10                	jne    f010063e <cons_init+0x104>
		cprintf("Serial port does not exist!\n");
f010062e:	83 ec 0c             	sub    $0xc,%esp
f0100631:	68 07 47 10 f0       	push   $0xf0104707
f0100636:	e8 ef 29 00 00       	call   f010302a <cprintf>
f010063b:	83 c4 10             	add    $0x10,%esp
}
f010063e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100641:	5b                   	pop    %ebx
f0100642:	5e                   	pop    %esi
f0100643:	5f                   	pop    %edi
f0100644:	5d                   	pop    %ebp
f0100645:	c3                   	ret    

f0100646 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f0100646:	55                   	push   %ebp
f0100647:	89 e5                	mov    %esp,%ebp
f0100649:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f010064c:	8b 45 08             	mov    0x8(%ebp),%eax
f010064f:	e8 75 fc ff ff       	call   f01002c9 <cons_putc>
}
f0100654:	c9                   	leave  
f0100655:	c3                   	ret    

f0100656 <getchar>:

int
getchar(void)
{
f0100656:	55                   	push   %ebp
f0100657:	89 e5                	mov    %esp,%ebp
f0100659:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f010065c:	e8 8f fe ff ff       	call   f01004f0 <cons_getc>
f0100661:	85 c0                	test   %eax,%eax
f0100663:	74 f7                	je     f010065c <getchar+0x6>
		/* do nothing */;
	return c;
}
f0100665:	c9                   	leave  
f0100666:	c3                   	ret    

f0100667 <iscons>:

int
iscons(int fdnum)
{
f0100667:	55                   	push   %ebp
f0100668:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f010066a:	b8 01 00 00 00       	mov    $0x1,%eax
f010066f:	5d                   	pop    %ebp
f0100670:	c3                   	ret    

f0100671 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100671:	55                   	push   %ebp
f0100672:	89 e5                	mov    %esp,%ebp
f0100674:	56                   	push   %esi
f0100675:	53                   	push   %ebx
f0100676:	bb 64 4c 10 f0       	mov    $0xf0104c64,%ebx
f010067b:	be ac 4c 10 f0       	mov    $0xf0104cac,%esi
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100680:	83 ec 04             	sub    $0x4,%esp
f0100683:	ff 33                	pushl  (%ebx)
f0100685:	ff 73 fc             	pushl  -0x4(%ebx)
f0100688:	68 60 49 10 f0       	push   $0xf0104960
f010068d:	e8 98 29 00 00       	call   f010302a <cprintf>
f0100692:	83 c3 0c             	add    $0xc,%ebx
int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
	int i;

	for (i = 0; i < NCOMMANDS; i++)
f0100695:	83 c4 10             	add    $0x10,%esp
f0100698:	39 f3                	cmp    %esi,%ebx
f010069a:	75 e4                	jne    f0100680 <mon_help+0xf>
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
	return 0;
}
f010069c:	b8 00 00 00 00       	mov    $0x0,%eax
f01006a1:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01006a4:	5b                   	pop    %ebx
f01006a5:	5e                   	pop    %esi
f01006a6:	5d                   	pop    %ebp
f01006a7:	c3                   	ret    

f01006a8 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01006a8:	55                   	push   %ebp
f01006a9:	89 e5                	mov    %esp,%ebp
f01006ab:	83 ec 14             	sub    $0x14,%esp
	extern char entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01006ae:	68 69 49 10 f0       	push   $0xf0104969
f01006b3:	e8 72 29 00 00       	call   f010302a <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01006b8:	83 c4 0c             	add    $0xc,%esp
f01006bb:	68 0c 00 10 00       	push   $0x10000c
f01006c0:	68 0c 00 10 f0       	push   $0xf010000c
f01006c5:	68 b4 4a 10 f0       	push   $0xf0104ab4
f01006ca:	e8 5b 29 00 00       	call   f010302a <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01006cf:	83 c4 0c             	add    $0xc,%esp
f01006d2:	68 51 46 10 00       	push   $0x104651
f01006d7:	68 51 46 10 f0       	push   $0xf0104651
f01006dc:	68 d8 4a 10 f0       	push   $0xf0104ad8
f01006e1:	e8 44 29 00 00       	call   f010302a <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f01006e6:	83 c4 0c             	add    $0xc,%esp
f01006e9:	68 52 f2 18 00       	push   $0x18f252
f01006ee:	68 52 f2 18 f0       	push   $0xf018f252
f01006f3:	68 fc 4a 10 f0       	push   $0xf0104afc
f01006f8:	e8 2d 29 00 00       	call   f010302a <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f01006fd:	83 c4 0c             	add    $0xc,%esp
f0100700:	68 70 01 19 00       	push   $0x190170
f0100705:	68 70 01 19 f0       	push   $0xf0190170
f010070a:	68 20 4b 10 f0       	push   $0xf0104b20
f010070f:	e8 16 29 00 00       	call   f010302a <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100714:	83 c4 08             	add    $0x8,%esp
f0100717:	b8 6f 05 19 f0       	mov    $0xf019056f,%eax
f010071c:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
f0100721:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f0100727:	85 c0                	test   %eax,%eax
f0100729:	0f 48 c2             	cmovs  %edx,%eax
f010072c:	c1 f8 0a             	sar    $0xa,%eax
f010072f:	50                   	push   %eax
f0100730:	68 44 4b 10 f0       	push   $0xf0104b44
f0100735:	e8 f0 28 00 00       	call   f010302a <cprintf>
		(end-entry+1023)/1024);
	return 0;
}
f010073a:	b8 00 00 00 00       	mov    $0x0,%eax
f010073f:	c9                   	leave  
f0100740:	c3                   	ret    

f0100741 <mon_time>:
    cprintf("Backtrace success\n");
	return 0;
}

int mon_time(int argc,char **argv,struct Trapframe *tf)
{
f0100741:	55                   	push   %ebp
f0100742:	89 e5                	mov    %esp,%ebp
f0100744:	57                   	push   %edi
f0100745:	56                   	push   %esi
f0100746:	53                   	push   %ebx
f0100747:	83 ec 1c             	sub    $0x1c,%esp
f010074a:	8b 75 0c             	mov    0xc(%ebp),%esi
	if(argc==1)
f010074d:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
f0100751:	74 74                	je     f01007c7 <mon_time+0x86>
f0100753:	bf 60 4c 10 f0       	mov    $0xf0104c60,%edi
f0100758:	bb 00 00 00 00       	mov    $0x0,%ebx
		return 0;
	uint64_t cycles;
	int flag=0;
	for(int i = 0;i<NCOMMANDS;++i)
	{
		if(strcmp(argv[1],commands[i].name)==0)
f010075d:	83 ec 08             	sub    $0x8,%esp
f0100760:	ff 37                	pushl  (%edi)
f0100762:	ff 76 04             	pushl  0x4(%esi)
f0100765:	e8 38 39 00 00       	call   f01040a2 <strcmp>
f010076a:	83 c4 10             	add    $0x10,%esp
f010076d:	85 c0                	test   %eax,%eax
f010076f:	75 38                	jne    f01007a9 <mon_time+0x68>

static __inline uint64_t
read_tsc(void)
{
        uint64_t tsc;
        __asm __volatile("rdtsc" : "=A" (tsc));
f0100771:	0f 31                	rdtsc  
f0100773:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100776:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		{
			flag=1;
			cycles=read_tsc();
			commands[i].func(argc, argv, tf);
f0100779:	83 ec 04             	sub    $0x4,%esp
f010077c:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f010077f:	ff 75 10             	pushl  0x10(%ebp)
f0100782:	56                   	push   %esi
f0100783:	ff 75 08             	pushl  0x8(%ebp)
f0100786:	ff 14 85 68 4c 10 f0 	call   *-0xfefb398(,%eax,4)
f010078d:	0f 31                	rdtsc  
		}
	}
	if(!flag)
		cprintf("Unknown command '%s'\n", argv[1]);
	else
		cprintf("%s cycles: %d\n",argv[1],cycles);
f010078f:	2b 45 e0             	sub    -0x20(%ebp),%eax
f0100792:	1b 55 e4             	sbb    -0x1c(%ebp),%edx
f0100795:	52                   	push   %edx
f0100796:	50                   	push   %eax
f0100797:	ff 76 04             	pushl  0x4(%esi)
f010079a:	68 82 49 10 f0       	push   $0xf0104982
f010079f:	e8 86 28 00 00       	call   f010302a <cprintf>
f01007a4:	83 c4 20             	add    $0x20,%esp
f01007a7:	eb 1e                	jmp    f01007c7 <mon_time+0x86>
{
	if(argc==1)
		return 0;
	uint64_t cycles;
	int flag=0;
	for(int i = 0;i<NCOMMANDS;++i)
f01007a9:	83 c3 01             	add    $0x1,%ebx
f01007ac:	83 c7 0c             	add    $0xc,%edi
f01007af:	83 fb 06             	cmp    $0x6,%ebx
f01007b2:	75 a9                	jne    f010075d <mon_time+0x1c>
			cycles=read_tsc()-cycles;
			break;
		}
	}
	if(!flag)
		cprintf("Unknown command '%s'\n", argv[1]);
f01007b4:	83 ec 08             	sub    $0x8,%esp
f01007b7:	ff 76 04             	pushl  0x4(%esi)
f01007ba:	68 91 49 10 f0       	push   $0xf0104991
f01007bf:	e8 66 28 00 00       	call   f010302a <cprintf>
f01007c4:	83 c4 10             	add    $0x10,%esp
	else
		cprintf("%s cycles: %d\n",argv[1],cycles);
	return 0;
}
f01007c7:	b8 00 00 00 00       	mov    $0x0,%eax
f01007cc:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01007cf:	5b                   	pop    %ebx
f01007d0:	5e                   	pop    %esi
f01007d1:	5f                   	pop    %edi
f01007d2:	5d                   	pop    %ebp
f01007d3:	c3                   	ret    

f01007d4 <mon_showmappings>:

int mon_showmappings(int argc,char **argv,struct Trapframe* tf)
{
f01007d4:	55                   	push   %ebp
f01007d5:	89 e5                	mov    %esp,%ebp
f01007d7:	56                   	push   %esi
f01007d8:	53                   	push   %ebx
f01007d9:	8b 75 0c             	mov    0xc(%ebp),%esi
	if(argc!=3)
f01007dc:	83 7d 08 03          	cmpl   $0x3,0x8(%ebp)
f01007e0:	0f 85 f0 00 00 00    	jne    f01008d6 <mon_showmappings+0x102>
		return -1;
	pte_t *pte;
	uintptr_t start_va=strtol(argv[1],NULL,16);
f01007e6:	83 ec 04             	sub    $0x4,%esp
f01007e9:	6a 10                	push   $0x10
f01007eb:	6a 00                	push   $0x0
f01007ed:	ff 76 04             	pushl  0x4(%esi)
f01007f0:	e8 e7 3a 00 00       	call   f01042dc <strtol>
f01007f5:	89 c3                	mov    %eax,%ebx
	uintptr_t end_va=strtol(argv[2],NULL,16);
f01007f7:	83 c4 0c             	add    $0xc,%esp
f01007fa:	6a 10                	push   $0x10
f01007fc:	6a 00                	push   $0x0
f01007fe:	ff 76 08             	pushl  0x8(%esi)
f0100801:	e8 d6 3a 00 00       	call   f01042dc <strtol>
	for(uintptr_t i=PTE_ADDR(start_va);i<=PTE_ADDR(end_va);i+=PGSIZE)
f0100806:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f010080c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100811:	89 c6                	mov    %eax,%esi
f0100813:	83 c4 10             	add    $0x10,%esp
f0100816:	39 c3                	cmp    %eax,%ebx
f0100818:	0f 87 bf 00 00 00    	ja     f01008dd <mon_showmappings+0x109>
	{
		cprintf("virtual address=%p,",i);
f010081e:	83 ec 08             	sub    $0x8,%esp
f0100821:	53                   	push   %ebx
f0100822:	68 a7 49 10 f0       	push   $0xf01049a7
f0100827:	e8 fe 27 00 00       	call   f010302a <cprintf>

static __inline uint32_t
rcr3(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr3,%0" : "=r" (val));
f010082c:	0f 20 da             	mov    %cr3,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010082f:	89 d0                	mov    %edx,%eax
f0100831:	c1 e8 0c             	shr    $0xc,%eax
f0100834:	83 c4 10             	add    $0x10,%esp
f0100837:	3b 05 64 01 19 f0    	cmp    0xf0190164,%eax
f010083d:	72 15                	jb     f0100854 <mon_showmappings+0x80>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010083f:	52                   	push   %edx
f0100840:	68 70 4b 10 f0       	push   $0xf0104b70
f0100845:	68 8a 00 00 00       	push   $0x8a
f010084a:	68 bb 49 10 f0       	push   $0xf01049bb
f010084f:	e8 77 f8 ff ff       	call   f01000cb <_panic>
		pte_t *pte=pgdir_walk(KADDR(rcr3()),(void *)i,0);
f0100854:	83 ec 04             	sub    $0x4,%esp
f0100857:	6a 00                	push   $0x0
f0100859:	53                   	push   %ebx
f010085a:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0100860:	52                   	push   %edx
f0100861:	e8 9e 09 00 00       	call   f0101204 <pgdir_walk>
		if(pte==NULL||!(*pte&PTE_P))
f0100866:	83 c4 10             	add    $0x10,%esp
f0100869:	85 c0                	test   %eax,%eax
f010086b:	74 06                	je     f0100873 <mon_showmappings+0x9f>
f010086d:	8b 00                	mov    (%eax),%eax
f010086f:	a8 01                	test   $0x1,%al
f0100871:	75 12                	jne    f0100885 <mon_showmappings+0xb1>
			cprintf("physical address=NULL\n");
f0100873:	83 ec 0c             	sub    $0xc,%esp
f0100876:	68 ca 49 10 f0       	push   $0xf01049ca
f010087b:	e8 aa 27 00 00       	call   f010302a <cprintf>
f0100880:	83 c4 10             	add    $0x10,%esp
f0100883:	eb 3c                	jmp    f01008c1 <mon_showmappings+0xed>
		else if(*pte&PTE_PS)
f0100885:	a8 80                	test   $0x80,%al
f0100887:	74 22                	je     f01008ab <mon_showmappings+0xd7>
			cprintf("physical address=%p\n",PTE_ADDR(*pte)|(PTX(i)<<PTXSHIFT));
f0100889:	83 ec 08             	sub    $0x8,%esp
f010088c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100891:	89 da                	mov    %ebx,%edx
f0100893:	81 e2 00 f0 3f 00    	and    $0x3ff000,%edx
f0100899:	09 d0                	or     %edx,%eax
f010089b:	50                   	push   %eax
f010089c:	68 e1 49 10 f0       	push   $0xf01049e1
f01008a1:	e8 84 27 00 00       	call   f010302a <cprintf>
f01008a6:	83 c4 10             	add    $0x10,%esp
f01008a9:	eb 16                	jmp    f01008c1 <mon_showmappings+0xed>
		else
			cprintf("physical address=%p\n",PTE_ADDR(*pte));
f01008ab:	83 ec 08             	sub    $0x8,%esp
f01008ae:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01008b3:	50                   	push   %eax
f01008b4:	68 e1 49 10 f0       	push   $0xf01049e1
f01008b9:	e8 6c 27 00 00       	call   f010302a <cprintf>
f01008be:	83 c4 10             	add    $0x10,%esp
	if(argc!=3)
		return -1;
	pte_t *pte;
	uintptr_t start_va=strtol(argv[1],NULL,16);
	uintptr_t end_va=strtol(argv[2],NULL,16);
	for(uintptr_t i=PTE_ADDR(start_va);i<=PTE_ADDR(end_va);i+=PGSIZE)
f01008c1:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01008c7:	39 f3                	cmp    %esi,%ebx
f01008c9:	0f 86 4f ff ff ff    	jbe    f010081e <mon_showmappings+0x4a>
		else if(*pte&PTE_PS)
			cprintf("physical address=%p\n",PTE_ADDR(*pte)|(PTX(i)<<PTXSHIFT));
		else
			cprintf("physical address=%p\n",PTE_ADDR(*pte));
	}
	return 0;
f01008cf:	b8 00 00 00 00       	mov    $0x0,%eax
f01008d4:	eb 0c                	jmp    f01008e2 <mon_showmappings+0x10e>
}

int mon_showmappings(int argc,char **argv,struct Trapframe* tf)
{
	if(argc!=3)
		return -1;
f01008d6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01008db:	eb 05                	jmp    f01008e2 <mon_showmappings+0x10e>
		else if(*pte&PTE_PS)
			cprintf("physical address=%p\n",PTE_ADDR(*pte)|(PTX(i)<<PTXSHIFT));
		else
			cprintf("physical address=%p\n",PTE_ADDR(*pte));
	}
	return 0;
f01008dd:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01008e2:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01008e5:	5b                   	pop    %ebx
f01008e6:	5e                   	pop    %esi
f01008e7:	5d                   	pop    %ebp
f01008e8:	c3                   	ret    

f01008e9 <mon_changepermissions>:

int mon_changepermissions(int argc,char **argv,struct Trapframe* tf)
{
f01008e9:	55                   	push   %ebp
f01008ea:	89 e5                	mov    %esp,%ebp
f01008ec:	56                   	push   %esi
f01008ed:	53                   	push   %ebx
f01008ee:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	if(argc!=3)
f01008f1:	83 7d 08 03          	cmpl   $0x3,0x8(%ebp)
f01008f5:	0f 85 ae 00 00 00    	jne    f01009a9 <mon_changepermissions+0xc0>
		return -1;
	uintptr_t va=strtol(argv[1],NULL,16);
f01008fb:	83 ec 04             	sub    $0x4,%esp
f01008fe:	6a 10                	push   $0x10
f0100900:	6a 00                	push   $0x0
f0100902:	ff 73 04             	pushl  0x4(%ebx)
f0100905:	e8 d2 39 00 00       	call   f01042dc <strtol>
f010090a:	89 c6                	mov    %eax,%esi
	uintptr_t permission=strtol(argv[2],NULL,16);
f010090c:	83 c4 0c             	add    $0xc,%esp
f010090f:	6a 10                	push   $0x10
f0100911:	6a 00                	push   $0x0
f0100913:	ff 73 08             	pushl  0x8(%ebx)
f0100916:	e8 c1 39 00 00       	call   f01042dc <strtol>
f010091b:	89 c3                	mov    %eax,%ebx
f010091d:	0f 20 d8             	mov    %cr3,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100920:	89 c2                	mov    %eax,%edx
f0100922:	c1 ea 0c             	shr    $0xc,%edx
f0100925:	83 c4 10             	add    $0x10,%esp
f0100928:	3b 15 64 01 19 f0    	cmp    0xf0190164,%edx
f010092e:	72 15                	jb     f0100945 <mon_changepermissions+0x5c>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100930:	50                   	push   %eax
f0100931:	68 70 4b 10 f0       	push   $0xf0104b70
f0100936:	68 9b 00 00 00       	push   $0x9b
f010093b:	68 bb 49 10 f0       	push   $0xf01049bb
f0100940:	e8 86 f7 ff ff       	call   f01000cb <_panic>
	pte_t *pte=pgdir_walk(KADDR(rcr3()),(void *)va,0);
f0100945:	83 ec 04             	sub    $0x4,%esp
f0100948:	6a 00                	push   $0x0
f010094a:	56                   	push   %esi
f010094b:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100950:	50                   	push   %eax
f0100951:	e8 ae 08 00 00       	call   f0101204 <pgdir_walk>
	if(pte==NULL||!(*pte&PTE_P))
f0100956:	83 c4 10             	add    $0x10,%esp
f0100959:	85 c0                	test   %eax,%eax
f010095b:	74 07                	je     f0100964 <mon_changepermissions+0x7b>
f010095d:	8b 10                	mov    (%eax),%edx
f010095f:	f6 c2 01             	test   $0x1,%dl
f0100962:	75 18                	jne    f010097c <mon_changepermissions+0x93>
		cprintf("virtual address %p not mapped\n",va);
f0100964:	83 ec 08             	sub    $0x8,%esp
f0100967:	56                   	push   %esi
f0100968:	68 94 4b 10 f0       	push   $0xf0104b94
f010096d:	e8 b8 26 00 00       	call   f010302a <cprintf>
f0100972:	83 c4 10             	add    $0x10,%esp
	else if(*pte&PTE_PS)
		*pte=PTE_ADDR(*pte)|permission|PTE_PS|PTE_P;
	else
		*pte=PTE_ADDR(*pte)|permission|PTE_P;
	return 0;
f0100975:	b8 00 00 00 00       	mov    $0x0,%eax
		return -1;
	uintptr_t va=strtol(argv[1],NULL,16);
	uintptr_t permission=strtol(argv[2],NULL,16);
	pte_t *pte=pgdir_walk(KADDR(rcr3()),(void *)va,0);
	if(pte==NULL||!(*pte&PTE_P))
		cprintf("virtual address %p not mapped\n",va);
f010097a:	eb 32                	jmp    f01009ae <mon_changepermissions+0xc5>
	else if(*pte&PTE_PS)
f010097c:	f6 c2 80             	test   $0x80,%dl
f010097f:	74 14                	je     f0100995 <mon_changepermissions+0xac>
		*pte=PTE_ADDR(*pte)|permission|PTE_PS|PTE_P;
f0100981:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100987:	80 cb 81             	or     $0x81,%bl
f010098a:	09 da                	or     %ebx,%edx
f010098c:	89 10                	mov    %edx,(%eax)
	else
		*pte=PTE_ADDR(*pte)|permission|PTE_P;
	return 0;
f010098e:	b8 00 00 00 00       	mov    $0x0,%eax
f0100993:	eb 19                	jmp    f01009ae <mon_changepermissions+0xc5>
	if(pte==NULL||!(*pte&PTE_P))
		cprintf("virtual address %p not mapped\n",va);
	else if(*pte&PTE_PS)
		*pte=PTE_ADDR(*pte)|permission|PTE_PS|PTE_P;
	else
		*pte=PTE_ADDR(*pte)|permission|PTE_P;
f0100995:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f010099b:	83 cb 01             	or     $0x1,%ebx
f010099e:	09 da                	or     %ebx,%edx
f01009a0:	89 10                	mov    %edx,(%eax)
	return 0;
f01009a2:	b8 00 00 00 00       	mov    $0x0,%eax
f01009a7:	eb 05                	jmp    f01009ae <mon_changepermissions+0xc5>
}

int mon_changepermissions(int argc,char **argv,struct Trapframe* tf)
{
	if(argc!=3)
		return -1;
f01009a9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	else if(*pte&PTE_PS)
		*pte=PTE_ADDR(*pte)|permission|PTE_PS|PTE_P;
	else
		*pte=PTE_ADDR(*pte)|permission|PTE_P;
	return 0;
}
f01009ae:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01009b1:	5b                   	pop    %ebx
f01009b2:	5e                   	pop    %esi
f01009b3:	5d                   	pop    %ebp
f01009b4:	c3                   	ret    

f01009b5 <mon_dump>:

int mon_dump(int argc,char **argv,struct Trapframe* tf)
{
f01009b5:	55                   	push   %ebp
f01009b6:	89 e5                	mov    %esp,%ebp
f01009b8:	57                   	push   %edi
f01009b9:	56                   	push   %esi
f01009ba:	53                   	push   %ebx
f01009bb:	83 ec 0c             	sub    $0xc,%esp
f01009be:	8b 75 0c             	mov    0xc(%ebp),%esi
	if(argc!=4)
f01009c1:	83 7d 08 04          	cmpl   $0x4,0x8(%ebp)
f01009c5:	0f 85 e7 00 00 00    	jne    f0100ab2 <mon_dump+0xfd>
		return -1;
	if(strcmp(argv[1],"va")==0)
f01009cb:	83 ec 08             	sub    $0x8,%esp
f01009ce:	68 f6 49 10 f0       	push   $0xf01049f6
f01009d3:	ff 76 04             	pushl  0x4(%esi)
f01009d6:	e8 c7 36 00 00       	call   f01040a2 <strcmp>
f01009db:	89 c7                	mov    %eax,%edi
f01009dd:	83 c4 10             	add    $0x10,%esp
f01009e0:	85 c0                	test   %eax,%eax
f01009e2:	0f 85 b3 00 00 00    	jne    f0100a9b <mon_dump+0xe6>
	{
		uintptr_t *start_va=(uintptr_t *)strtol(argv[2],NULL,16);
f01009e8:	83 ec 04             	sub    $0x4,%esp
f01009eb:	6a 10                	push   $0x10
f01009ed:	6a 00                	push   $0x0
f01009ef:	ff 76 08             	pushl  0x8(%esi)
f01009f2:	e8 e5 38 00 00       	call   f01042dc <strtol>
f01009f7:	89 c3                	mov    %eax,%ebx
		uintptr_t *end_va=(uintptr_t *)strtol(argv[3],NULL,16);
f01009f9:	83 c4 0c             	add    $0xc,%esp
f01009fc:	6a 10                	push   $0x10
f01009fe:	6a 00                	push   $0x0
f0100a00:	ff 76 0c             	pushl  0xc(%esi)
f0100a03:	e8 d4 38 00 00       	call   f01042dc <strtol>
f0100a08:	89 c6                	mov    %eax,%esi
		for(char *i=(char *)start_va;i<=(char *)end_va;i++)
f0100a0a:	83 c4 10             	add    $0x10,%esp
f0100a0d:	39 c3                	cmp    %eax,%ebx
f0100a0f:	0f 87 a2 00 00 00    	ja     f0100ab7 <mon_dump+0x102>
f0100a15:	0f 20 d8             	mov    %cr3,%eax
f0100a18:	89 c2                	mov    %eax,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100a1a:	c1 e8 0c             	shr    $0xc,%eax
f0100a1d:	3b 05 64 01 19 f0    	cmp    0xf0190164,%eax
f0100a23:	72 27                	jb     f0100a4c <mon_dump+0x97>
f0100a25:	eb 10                	jmp    f0100a37 <mon_dump+0x82>
f0100a27:	0f 20 d8             	mov    %cr3,%eax
f0100a2a:	89 c2                	mov    %eax,%edx
f0100a2c:	c1 e8 0c             	shr    $0xc,%eax
f0100a2f:	3b 05 64 01 19 f0    	cmp    0xf0190164,%eax
f0100a35:	72 15                	jb     f0100a4c <mon_dump+0x97>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100a37:	52                   	push   %edx
f0100a38:	68 70 4b 10 f0       	push   $0xf0104b70
f0100a3d:	68 af 00 00 00       	push   $0xaf
f0100a42:	68 bb 49 10 f0       	push   $0xf01049bb
f0100a47:	e8 7f f6 ff ff       	call   f01000cb <_panic>
		{
			pte_t *pte=pgdir_walk(KADDR(rcr3()),(void *)i,0);
f0100a4c:	83 ec 04             	sub    $0x4,%esp
f0100a4f:	6a 00                	push   $0x0
f0100a51:	53                   	push   %ebx
f0100a52:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0100a58:	52                   	push   %edx
f0100a59:	e8 a6 07 00 00       	call   f0101204 <pgdir_walk>
			if(pte==NULL||!(*pte&PTE_P))
f0100a5e:	83 c4 10             	add    $0x10,%esp
f0100a61:	85 c0                	test   %eax,%eax
f0100a63:	74 05                	je     f0100a6a <mon_dump+0xb5>
f0100a65:	f6 00 01             	testb  $0x1,(%eax)
f0100a68:	75 13                	jne    f0100a7d <mon_dump+0xc8>
				cprintf("%p: NULL\n",i);
f0100a6a:	83 ec 08             	sub    $0x8,%esp
f0100a6d:	53                   	push   %ebx
f0100a6e:	68 f9 49 10 f0       	push   $0xf01049f9
f0100a73:	e8 b2 25 00 00       	call   f010302a <cprintf>
f0100a78:	83 c4 10             	add    $0x10,%esp
f0100a7b:	eb 15                	jmp    f0100a92 <mon_dump+0xdd>
			else
				cprintf("%p: 0x%x\n",i,*i);
f0100a7d:	83 ec 04             	sub    $0x4,%esp
f0100a80:	0f be 03             	movsbl (%ebx),%eax
f0100a83:	50                   	push   %eax
f0100a84:	53                   	push   %ebx
f0100a85:	68 03 4a 10 f0       	push   $0xf0104a03
f0100a8a:	e8 9b 25 00 00       	call   f010302a <cprintf>
f0100a8f:	83 c4 10             	add    $0x10,%esp
		return -1;
	if(strcmp(argv[1],"va")==0)
	{
		uintptr_t *start_va=(uintptr_t *)strtol(argv[2],NULL,16);
		uintptr_t *end_va=(uintptr_t *)strtol(argv[3],NULL,16);
		for(char *i=(char *)start_va;i<=(char *)end_va;i++)
f0100a92:	83 c3 01             	add    $0x1,%ebx
f0100a95:	39 de                	cmp    %ebx,%esi
f0100a97:	73 8e                	jae    f0100a27 <mon_dump+0x72>
f0100a99:	eb 1c                	jmp    f0100ab7 <mon_dump+0x102>
			else
				cprintf("%p: 0x%x\n",i,*i);
		}
	}
	else
		cprintf("dump not supported\n");
f0100a9b:	83 ec 0c             	sub    $0xc,%esp
f0100a9e:	68 0d 4a 10 f0       	push   $0xf0104a0d
f0100aa3:	e8 82 25 00 00       	call   f010302a <cprintf>
f0100aa8:	83 c4 10             	add    $0x10,%esp
	return 0;
f0100aab:	bf 00 00 00 00       	mov    $0x0,%edi
f0100ab0:	eb 05                	jmp    f0100ab7 <mon_dump+0x102>
}

int mon_dump(int argc,char **argv,struct Trapframe* tf)
{
	if(argc!=4)
		return -1;
f0100ab2:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		}
	}
	else
		cprintf("dump not supported\n");
	return 0;
}
f0100ab7:	89 f8                	mov    %edi,%eax
f0100ab9:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100abc:	5b                   	pop    %ebx
f0100abd:	5e                   	pop    %esi
f0100abe:	5f                   	pop    %edi
f0100abf:	5d                   	pop    %ebp
f0100ac0:	c3                   	ret    

f0100ac1 <mon_backtrace>:
    return pretaddr;
}

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f0100ac1:	55                   	push   %ebp
f0100ac2:	89 e5                	mov    %esp,%ebp
f0100ac4:	57                   	push   %edi
f0100ac5:	56                   	push   %esi
f0100ac6:	53                   	push   %ebx
f0100ac7:	83 ec 4c             	sub    $0x4c,%esp

static __inline uint32_t
read_ebp(void)
{
        uint32_t ebp;
        __asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f0100aca:	89 e8                	mov    %ebp,%eax
f0100acc:	89 c1                	mov    %eax,%ecx
	uint32_t next_ebp,pretaddr;
	uint32_t args[5];
	uint32_t ebp=read_ebp();
	struct Eipdebuginfo info;
	int result;
	while(ebp!=0)
f0100ace:	85 c0                	test   %eax,%eax
f0100ad0:	0f 84 bd 00 00 00    	je     f0100b93 <mon_backtrace+0xd2>
	{
		next_ebp=*(uint32_t *)ebp;
f0100ad6:	8b 31                	mov    (%ecx),%esi
		pretaddr=*(uint32_t *)(ebp+4);
f0100ad8:	8b 59 04             	mov    0x4(%ecx),%ebx
		for(int i=0;i<5;++i)
f0100adb:	b8 00 00 00 00       	mov    $0x0,%eax
			args[i]=*(uint32_t *)(ebp+8+4*i);
f0100ae0:	8b 54 81 08          	mov    0x8(%ecx,%eax,4),%edx
f0100ae4:	89 54 85 d4          	mov    %edx,-0x2c(%ebp,%eax,4)
	int result;
	while(ebp!=0)
	{
		next_ebp=*(uint32_t *)ebp;
		pretaddr=*(uint32_t *)(ebp+4);
		for(int i=0;i<5;++i)
f0100ae8:	83 c0 01             	add    $0x1,%eax
f0100aeb:	83 f8 05             	cmp    $0x5,%eax
f0100aee:	75 f0                	jne    f0100ae0 <mon_backtrace+0x1f>
			args[i]=*(uint32_t *)(ebp+8+4*i);
		cprintf("eip %x ebp %x args %08x %08x %08x %08x %08x\n",pretaddr,ebp,args[0],args[1],args[2],args[3],args[4]);
f0100af0:	ff 75 e4             	pushl  -0x1c(%ebp)
f0100af3:	ff 75 e0             	pushl  -0x20(%ebp)
f0100af6:	ff 75 dc             	pushl  -0x24(%ebp)
f0100af9:	ff 75 d8             	pushl  -0x28(%ebp)
f0100afc:	ff 75 d4             	pushl  -0x2c(%ebp)
f0100aff:	51                   	push   %ecx
f0100b00:	53                   	push   %ebx
f0100b01:	68 b4 4b 10 f0       	push   $0xf0104bb4
f0100b06:	e8 1f 25 00 00       	call   f010302a <cprintf>
		result=debuginfo_eip(pretaddr,&info);
f0100b0b:	83 c4 18             	add    $0x18,%esp
f0100b0e:	8d 45 bc             	lea    -0x44(%ebp),%eax
f0100b11:	50                   	push   %eax
f0100b12:	53                   	push   %ebx
f0100b13:	e8 fd 29 00 00       	call   f0103515 <debuginfo_eip>
		if(result)
f0100b18:	83 c4 10             	add    $0x10,%esp
f0100b1b:	85 c0                	test   %eax,%eax
f0100b1d:	0f 85 85 00 00 00    	jne    f0100ba8 <mon_backtrace+0xe7>
			return result;
		cprintf("%s:%d: ",info.eip_file,info.eip_line);
f0100b23:	83 ec 04             	sub    $0x4,%esp
f0100b26:	ff 75 c0             	pushl  -0x40(%ebp)
f0100b29:	ff 75 bc             	pushl  -0x44(%ebp)
f0100b2c:	68 a7 46 10 f0       	push   $0xf01046a7
f0100b31:	e8 f4 24 00 00       	call   f010302a <cprintf>
		char buffer[info.eip_fn_namelen+1];
f0100b36:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0100b39:	8d 48 01             	lea    0x1(%eax),%ecx
f0100b3c:	83 c4 10             	add    $0x10,%esp
f0100b3f:	89 65 b4             	mov    %esp,-0x4c(%ebp)
f0100b42:	83 c0 10             	add    $0x10,%eax
f0100b45:	bf 10 00 00 00       	mov    $0x10,%edi
f0100b4a:	ba 00 00 00 00       	mov    $0x0,%edx
f0100b4f:	f7 f7                	div    %edi
f0100b51:	c1 e0 04             	shl    $0x4,%eax
f0100b54:	29 c4                	sub    %eax,%esp
f0100b56:	89 e7                	mov    %esp,%edi
		snprintf(buffer,info.eip_fn_namelen+1,"%s",info.eip_fn_name);
f0100b58:	ff 75 c4             	pushl  -0x3c(%ebp)
f0100b5b:	68 01 54 10 f0       	push   $0xf0105401
f0100b60:	51                   	push   %ecx
f0100b61:	57                   	push   %edi
f0100b62:	e8 2d 33 00 00       	call   f0103e94 <snprintf>
		cprintf("%s",buffer);
f0100b67:	83 c4 08             	add    $0x8,%esp
f0100b6a:	57                   	push   %edi
f0100b6b:	68 01 54 10 f0       	push   $0xf0105401
f0100b70:	e8 b5 24 00 00       	call   f010302a <cprintf>
		cprintf("+%d\n",pretaddr-info.eip_fn_addr);
f0100b75:	83 c4 08             	add    $0x8,%esp
f0100b78:	2b 5d cc             	sub    -0x34(%ebp),%ebx
f0100b7b:	53                   	push   %ebx
f0100b7c:	68 21 4a 10 f0       	push   $0xf0104a21
f0100b81:	e8 a4 24 00 00       	call   f010302a <cprintf>
f0100b86:	8b 65 b4             	mov    -0x4c(%ebp),%esp
		ebp=next_ebp;
f0100b89:	89 f1                	mov    %esi,%ecx
	uint32_t next_ebp,pretaddr;
	uint32_t args[5];
	uint32_t ebp=read_ebp();
	struct Eipdebuginfo info;
	int result;
	while(ebp!=0)
f0100b8b:	85 f6                	test   %esi,%esi
f0100b8d:	0f 85 43 ff ff ff    	jne    f0100ad6 <mon_backtrace+0x15>
		snprintf(buffer,info.eip_fn_namelen+1,"%s",info.eip_fn_name);
		cprintf("%s",buffer);
		cprintf("+%d\n",pretaddr-info.eip_fn_addr);
		ebp=next_ebp;
	}
    cprintf("Backtrace success\n");
f0100b93:	83 ec 0c             	sub    $0xc,%esp
f0100b96:	68 26 4a 10 f0       	push   $0xf0104a26
f0100b9b:	e8 8a 24 00 00       	call   f010302a <cprintf>
	return 0;
f0100ba0:	83 c4 10             	add    $0x10,%esp
f0100ba3:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100ba8:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100bab:	5b                   	pop    %ebx
f0100bac:	5e                   	pop    %esi
f0100bad:	5f                   	pop    %edi
f0100bae:	5d                   	pop    %ebp
f0100baf:	c3                   	ret    

f0100bb0 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100bb0:	55                   	push   %ebp
f0100bb1:	89 e5                	mov    %esp,%ebp
f0100bb3:	57                   	push   %edi
f0100bb4:	56                   	push   %esi
f0100bb5:	53                   	push   %ebx
f0100bb6:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100bb9:	68 e4 4b 10 f0       	push   $0xf0104be4
f0100bbe:	e8 67 24 00 00       	call   f010302a <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100bc3:	c7 04 24 08 4c 10 f0 	movl   $0xf0104c08,(%esp)
f0100bca:	e8 5b 24 00 00       	call   f010302a <cprintf>

	if (tf != NULL)
f0100bcf:	83 c4 10             	add    $0x10,%esp
f0100bd2:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0100bd6:	74 0e                	je     f0100be6 <monitor+0x36>
		print_trapframe(tf);
f0100bd8:	83 ec 0c             	sub    $0xc,%esp
f0100bdb:	ff 75 08             	pushl  0x8(%ebp)
f0100bde:	e8 50 25 00 00       	call   f0103133 <print_trapframe>
f0100be3:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f0100be6:	83 ec 0c             	sub    $0xc,%esp
f0100be9:	68 39 4a 10 f0       	push   $0xf0104a39
f0100bee:	e8 bb 32 00 00       	call   f0103eae <readline>
f0100bf3:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100bf5:	83 c4 10             	add    $0x10,%esp
f0100bf8:	85 c0                	test   %eax,%eax
f0100bfa:	74 ea                	je     f0100be6 <monitor+0x36>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f0100bfc:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f0100c03:	be 00 00 00 00       	mov    $0x0,%esi
f0100c08:	eb 0a                	jmp    f0100c14 <monitor+0x64>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f0100c0a:	c6 03 00             	movb   $0x0,(%ebx)
f0100c0d:	89 f7                	mov    %esi,%edi
f0100c0f:	8d 5b 01             	lea    0x1(%ebx),%ebx
f0100c12:	89 fe                	mov    %edi,%esi
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f0100c14:	0f b6 03             	movzbl (%ebx),%eax
f0100c17:	84 c0                	test   %al,%al
f0100c19:	74 6a                	je     f0100c85 <monitor+0xd5>
f0100c1b:	83 ec 08             	sub    $0x8,%esp
f0100c1e:	0f be c0             	movsbl %al,%eax
f0100c21:	50                   	push   %eax
f0100c22:	68 3d 4a 10 f0       	push   $0xf0104a3d
f0100c27:	e8 fa 34 00 00       	call   f0104126 <strchr>
f0100c2c:	83 c4 10             	add    $0x10,%esp
f0100c2f:	85 c0                	test   %eax,%eax
f0100c31:	75 d7                	jne    f0100c0a <monitor+0x5a>
			*buf++ = 0;
		if (*buf == 0)
f0100c33:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100c36:	74 4d                	je     f0100c85 <monitor+0xd5>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f0100c38:	83 fe 0f             	cmp    $0xf,%esi
f0100c3b:	75 14                	jne    f0100c51 <monitor+0xa1>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100c3d:	83 ec 08             	sub    $0x8,%esp
f0100c40:	6a 10                	push   $0x10
f0100c42:	68 42 4a 10 f0       	push   $0xf0104a42
f0100c47:	e8 de 23 00 00       	call   f010302a <cprintf>
f0100c4c:	83 c4 10             	add    $0x10,%esp
f0100c4f:	eb 95                	jmp    f0100be6 <monitor+0x36>
			return 0;
		}
		argv[argc++] = buf;
f0100c51:	8d 7e 01             	lea    0x1(%esi),%edi
f0100c54:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
		while (*buf && !strchr(WHITESPACE, *buf))
f0100c58:	0f b6 03             	movzbl (%ebx),%eax
f0100c5b:	84 c0                	test   %al,%al
f0100c5d:	75 0c                	jne    f0100c6b <monitor+0xbb>
f0100c5f:	eb b1                	jmp    f0100c12 <monitor+0x62>
			buf++;
f0100c61:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f0100c64:	0f b6 03             	movzbl (%ebx),%eax
f0100c67:	84 c0                	test   %al,%al
f0100c69:	74 a7                	je     f0100c12 <monitor+0x62>
f0100c6b:	83 ec 08             	sub    $0x8,%esp
f0100c6e:	0f be c0             	movsbl %al,%eax
f0100c71:	50                   	push   %eax
f0100c72:	68 3d 4a 10 f0       	push   $0xf0104a3d
f0100c77:	e8 aa 34 00 00       	call   f0104126 <strchr>
f0100c7c:	83 c4 10             	add    $0x10,%esp
f0100c7f:	85 c0                	test   %eax,%eax
f0100c81:	74 de                	je     f0100c61 <monitor+0xb1>
f0100c83:	eb 8d                	jmp    f0100c12 <monitor+0x62>
			buf++;
	}
	argv[argc] = 0;
f0100c85:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100c8c:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0100c8d:	85 f6                	test   %esi,%esi
f0100c8f:	0f 84 51 ff ff ff    	je     f0100be6 <monitor+0x36>
f0100c95:	bb 00 00 00 00       	mov    $0x0,%ebx
		return 0;
	
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0100c9a:	83 ec 08             	sub    $0x8,%esp
f0100c9d:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100ca0:	ff 34 85 60 4c 10 f0 	pushl  -0xfefb3a0(,%eax,4)
f0100ca7:	ff 75 a8             	pushl  -0x58(%ebp)
f0100caa:	e8 f3 33 00 00       	call   f01040a2 <strcmp>
f0100caf:	83 c4 10             	add    $0x10,%esp
f0100cb2:	85 c0                	test   %eax,%eax
f0100cb4:	75 21                	jne    f0100cd7 <monitor+0x127>
			return commands[i].func(argc, argv, tf);
f0100cb6:	83 ec 04             	sub    $0x4,%esp
f0100cb9:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100cbc:	ff 75 08             	pushl  0x8(%ebp)
f0100cbf:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100cc2:	52                   	push   %edx
f0100cc3:	56                   	push   %esi
f0100cc4:	ff 14 85 68 4c 10 f0 	call   *-0xfefb398(,%eax,4)
		print_trapframe(tf);

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0100ccb:	83 c4 10             	add    $0x10,%esp
f0100cce:	85 c0                	test   %eax,%eax
f0100cd0:	78 25                	js     f0100cf7 <monitor+0x147>
f0100cd2:	e9 0f ff ff ff       	jmp    f0100be6 <monitor+0x36>

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	
	for (i = 0; i < NCOMMANDS; i++) {
f0100cd7:	83 c3 01             	add    $0x1,%ebx
f0100cda:	83 fb 06             	cmp    $0x6,%ebx
f0100cdd:	75 bb                	jne    f0100c9a <monitor+0xea>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100cdf:	83 ec 08             	sub    $0x8,%esp
f0100ce2:	ff 75 a8             	pushl  -0x58(%ebp)
f0100ce5:	68 91 49 10 f0       	push   $0xf0104991
f0100cea:	e8 3b 23 00 00       	call   f010302a <cprintf>
f0100cef:	83 c4 10             	add    $0x10,%esp
f0100cf2:	e9 ef fe ff ff       	jmp    f0100be6 <monitor+0x36>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f0100cf7:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100cfa:	5b                   	pop    %ebx
f0100cfb:	5e                   	pop    %esi
f0100cfc:	5f                   	pop    %edi
f0100cfd:	5d                   	pop    %ebp
f0100cfe:	c3                   	ret    

f0100cff <read_eip>:
// return EIP of caller.
// does not work if inlined.
// putting at the end of the file seems to prevent inlining.
unsigned
read_eip()
{
f0100cff:	55                   	push   %ebp
f0100d00:	89 e5                	mov    %esp,%ebp
	uint32_t callerpc;
	__asm __volatile("movl 4(%%ebp), %0" : "=r" (callerpc));
f0100d02:	8b 45 04             	mov    0x4(%ebp),%eax
	return callerpc;
}
f0100d05:	5d                   	pop    %ebp
f0100d06:	c3                   	ret    

f0100d07 <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100d07:	55                   	push   %ebp
f0100d08:	89 e5                	mov    %esp,%ebp
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100d0a:	83 3d 98 f4 18 f0 00 	cmpl   $0x0,0xf018f498
f0100d11:	75 11                	jne    f0100d24 <boot_alloc+0x1d>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100d13:	ba 6f 11 19 f0       	mov    $0xf019116f,%edx
f0100d18:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100d1e:	89 15 98 f4 18 f0    	mov    %edx,0xf018f498
	// Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	char *ret=nextfree;
f0100d24:	8b 0d 98 f4 18 f0    	mov    0xf018f498,%ecx
	nextfree+=n;
	nextfree=ROUNDUP(nextfree,PGSIZE);
f0100d2a:	8d 94 01 ff 0f 00 00 	lea    0xfff(%ecx,%eax,1),%edx
f0100d31:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100d37:	89 15 98 f4 18 f0    	mov    %edx,0xf018f498
	return ret;
}
f0100d3d:	89 c8                	mov    %ecx,%eax
f0100d3f:	5d                   	pop    %ebp
f0100d40:	c3                   	ret    

f0100d41 <check_va2pa>:
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
f0100d41:	89 d1                	mov    %edx,%ecx
f0100d43:	c1 e9 16             	shr    $0x16,%ecx
f0100d46:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0100d49:	a8 01                	test   $0x1,%al
f0100d4b:	74 52                	je     f0100d9f <check_va2pa+0x5e>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100d4d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100d52:	89 c1                	mov    %eax,%ecx
f0100d54:	c1 e9 0c             	shr    $0xc,%ecx
f0100d57:	3b 0d 64 01 19 f0    	cmp    0xf0190164,%ecx
f0100d5d:	72 1b                	jb     f0100d7a <check_va2pa+0x39>
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100d5f:	55                   	push   %ebp
f0100d60:	89 e5                	mov    %esp,%ebp
f0100d62:	83 ec 08             	sub    $0x8,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100d65:	50                   	push   %eax
f0100d66:	68 70 4b 10 f0       	push   $0xf0104b70
f0100d6b:	68 3c 03 00 00       	push   $0x33c
f0100d70:	68 c9 53 10 f0       	push   $0xf01053c9
f0100d75:	e8 51 f3 ff ff       	call   f01000cb <_panic>

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
f0100d7a:	c1 ea 0c             	shr    $0xc,%edx
f0100d7d:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100d83:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0100d8a:	89 c2                	mov    %eax,%edx
f0100d8c:	83 e2 01             	and    $0x1,%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100d8f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100d94:	85 d2                	test   %edx,%edx
f0100d96:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100d9b:	0f 44 c2             	cmove  %edx,%eax
f0100d9e:	c3                   	ret    
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
f0100d9f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
}
f0100da4:	c3                   	ret    

f0100da5 <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f0100da5:	55                   	push   %ebp
f0100da6:	89 e5                	mov    %esp,%ebp
f0100da8:	57                   	push   %edi
f0100da9:	56                   	push   %esi
f0100daa:	53                   	push   %ebx
f0100dab:	83 ec 2c             	sub    $0x2c,%esp
	struct Page *pp;
	int pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100dae:	85 c0                	test   %eax,%eax
f0100db0:	0f 85 b1 02 00 00    	jne    f0101067 <check_page_free_list+0x2c2>
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0100db6:	8b 1d 9c f4 18 f0    	mov    0xf018f49c,%ebx
f0100dbc:	85 db                	test   %ebx,%ebx
f0100dbe:	75 6c                	jne    f0100e2c <check_page_free_list+0x87>
		panic("'page_free_list' is a null pointer!");
f0100dc0:	83 ec 04             	sub    $0x4,%esp
f0100dc3:	68 a8 4c 10 f0       	push   $0xf0104ca8
f0100dc8:	68 70 02 00 00       	push   $0x270
f0100dcd:	68 c9 53 10 f0       	push   $0xf01053c9
f0100dd2:	e8 f4 f2 ff ff       	call   f01000cb <_panic>

	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct Page *pp1, *pp2;
		struct Page **tp[2] = { &pp1, &pp2 };
f0100dd7:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100dda:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100ddd:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100de0:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100de3:	89 c2                	mov    %eax,%edx
f0100de5:	2b 15 6c 01 19 f0    	sub    0xf019016c,%edx
f0100deb:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100df1:	0f 95 c2             	setne  %dl
f0100df4:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0100df7:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100dfb:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100dfd:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct Page *pp1, *pp2;
		struct Page **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100e01:	8b 00                	mov    (%eax),%eax
f0100e03:	85 c0                	test   %eax,%eax
f0100e05:	75 dc                	jne    f0100de3 <check_page_free_list+0x3e>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f0100e07:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100e0a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100e10:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100e13:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100e16:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100e18:	8b 5d d8             	mov    -0x28(%ebp),%ebx
f0100e1b:	89 1d 9c f4 18 f0    	mov    %ebx,0xf018f49c
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link){
f0100e21:	85 db                	test   %ebx,%ebx
f0100e23:	74 63                	je     f0100e88 <check_page_free_list+0xe3>
f0100e25:	be 01 00 00 00       	mov    $0x1,%esi
f0100e2a:	eb 05                	jmp    f0100e31 <check_page_free_list+0x8c>
//
static void
check_page_free_list(bool only_low_memory)
{
	struct Page *pp;
	int pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100e2c:	be 00 04 00 00       	mov    $0x400,%esi
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0100e31:	89 d8                	mov    %ebx,%eax
f0100e33:	2b 05 6c 01 19 f0    	sub    0xf019016c,%eax
f0100e39:	c1 f8 03             	sar    $0x3,%eax
f0100e3c:	c1 e0 0c             	shl    $0xc,%eax
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link){
		if (PDX(page2pa(pp)) < pdx_limit)
f0100e3f:	89 c2                	mov    %eax,%edx
f0100e41:	c1 ea 16             	shr    $0x16,%edx
f0100e44:	39 f2                	cmp    %esi,%edx
f0100e46:	73 3a                	jae    f0100e82 <check_page_free_list+0xdd>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100e48:	89 c2                	mov    %eax,%edx
f0100e4a:	c1 ea 0c             	shr    $0xc,%edx
f0100e4d:	3b 15 64 01 19 f0    	cmp    0xf0190164,%edx
f0100e53:	72 12                	jb     f0100e67 <check_page_free_list+0xc2>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100e55:	50                   	push   %eax
f0100e56:	68 70 4b 10 f0       	push   $0xf0104b70
f0100e5b:	6a 56                	push   $0x56
f0100e5d:	68 d5 53 10 f0       	push   $0xf01053d5
f0100e62:	e8 64 f2 ff ff       	call   f01000cb <_panic>
			memset(page2kva(pp), 0x97, 128);
f0100e67:	83 ec 04             	sub    $0x4,%esp
f0100e6a:	68 80 00 00 00       	push   $0x80
f0100e6f:	68 97 00 00 00       	push   $0x97
f0100e74:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100e79:	50                   	push   %eax
f0100e7a:	e8 05 33 00 00       	call   f0104184 <memset>
f0100e7f:	83 c4 10             	add    $0x10,%esp
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link){
f0100e82:	8b 1b                	mov    (%ebx),%ebx
f0100e84:	85 db                	test   %ebx,%ebx
f0100e86:	75 a9                	jne    f0100e31 <check_page_free_list+0x8c>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);
	}

	first_free_page = (char *) boot_alloc(0);
f0100e88:	b8 00 00 00 00       	mov    $0x0,%eax
f0100e8d:	e8 75 fe ff ff       	call   f0100d07 <boot_alloc>
f0100e92:	89 45 cc             	mov    %eax,-0x34(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100e95:	8b 15 9c f4 18 f0    	mov    0xf018f49c,%edx
f0100e9b:	85 d2                	test   %edx,%edx
f0100e9d:	0f 84 8e 01 00 00    	je     f0101031 <check_page_free_list+0x28c>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100ea3:	8b 0d 6c 01 19 f0    	mov    0xf019016c,%ecx
f0100ea9:	39 ca                	cmp    %ecx,%edx
f0100eab:	72 49                	jb     f0100ef6 <check_page_free_list+0x151>
		assert(pp < pages + npages);
f0100ead:	a1 64 01 19 f0       	mov    0xf0190164,%eax
f0100eb2:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0100eb5:	8d 3c c1             	lea    (%ecx,%eax,8),%edi
f0100eb8:	39 fa                	cmp    %edi,%edx
f0100eba:	73 57                	jae    f0100f13 <check_page_free_list+0x16e>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100ebc:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f0100ebf:	89 d0                	mov    %edx,%eax
f0100ec1:	29 c8                	sub    %ecx,%eax
f0100ec3:	a8 07                	test   $0x7,%al
f0100ec5:	75 6e                	jne    f0100f35 <check_page_free_list+0x190>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0100ec7:	c1 f8 03             	sar    $0x3,%eax
f0100eca:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0100ecd:	85 c0                	test   %eax,%eax
f0100ecf:	0f 84 83 00 00 00    	je     f0100f58 <check_page_free_list+0x1b3>
		assert(page2pa(pp) != IOPHYSMEM);
f0100ed5:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100eda:	0f 84 98 00 00 00    	je     f0100f78 <check_page_free_list+0x1d3>
f0100ee0:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100ee5:	be 00 00 00 00       	mov    $0x0,%esi
f0100eea:	89 5d d0             	mov    %ebx,-0x30(%ebp)
f0100eed:	e9 9f 00 00 00       	jmp    f0100f91 <check_page_free_list+0x1ec>
	}

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100ef2:	39 ca                	cmp    %ecx,%edx
f0100ef4:	73 19                	jae    f0100f0f <check_page_free_list+0x16a>
f0100ef6:	68 e3 53 10 f0       	push   $0xf01053e3
f0100efb:	68 ef 53 10 f0       	push   $0xf01053ef
f0100f00:	68 8b 02 00 00       	push   $0x28b
f0100f05:	68 c9 53 10 f0       	push   $0xf01053c9
f0100f0a:	e8 bc f1 ff ff       	call   f01000cb <_panic>
		assert(pp < pages + npages);
f0100f0f:	39 fa                	cmp    %edi,%edx
f0100f11:	72 19                	jb     f0100f2c <check_page_free_list+0x187>
f0100f13:	68 04 54 10 f0       	push   $0xf0105404
f0100f18:	68 ef 53 10 f0       	push   $0xf01053ef
f0100f1d:	68 8c 02 00 00       	push   $0x28c
f0100f22:	68 c9 53 10 f0       	push   $0xf01053c9
f0100f27:	e8 9f f1 ff ff       	call   f01000cb <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100f2c:	89 d0                	mov    %edx,%eax
f0100f2e:	2b 45 d4             	sub    -0x2c(%ebp),%eax
f0100f31:	a8 07                	test   $0x7,%al
f0100f33:	74 19                	je     f0100f4e <check_page_free_list+0x1a9>
f0100f35:	68 cc 4c 10 f0       	push   $0xf0104ccc
f0100f3a:	68 ef 53 10 f0       	push   $0xf01053ef
f0100f3f:	68 8d 02 00 00       	push   $0x28d
f0100f44:	68 c9 53 10 f0       	push   $0xf01053c9
f0100f49:	e8 7d f1 ff ff       	call   f01000cb <_panic>
f0100f4e:	c1 f8 03             	sar    $0x3,%eax
f0100f51:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0100f54:	85 c0                	test   %eax,%eax
f0100f56:	75 19                	jne    f0100f71 <check_page_free_list+0x1cc>
f0100f58:	68 18 54 10 f0       	push   $0xf0105418
f0100f5d:	68 ef 53 10 f0       	push   $0xf01053ef
f0100f62:	68 90 02 00 00       	push   $0x290
f0100f67:	68 c9 53 10 f0       	push   $0xf01053c9
f0100f6c:	e8 5a f1 ff ff       	call   f01000cb <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100f71:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100f76:	75 19                	jne    f0100f91 <check_page_free_list+0x1ec>
f0100f78:	68 29 54 10 f0       	push   $0xf0105429
f0100f7d:	68 ef 53 10 f0       	push   $0xf01053ef
f0100f82:	68 91 02 00 00       	push   $0x291
f0100f87:	68 c9 53 10 f0       	push   $0xf01053c9
f0100f8c:	e8 3a f1 ff ff       	call   f01000cb <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100f91:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100f96:	75 19                	jne    f0100fb1 <check_page_free_list+0x20c>
f0100f98:	68 00 4d 10 f0       	push   $0xf0104d00
f0100f9d:	68 ef 53 10 f0       	push   $0xf01053ef
f0100fa2:	68 92 02 00 00       	push   $0x292
f0100fa7:	68 c9 53 10 f0       	push   $0xf01053c9
f0100fac:	e8 1a f1 ff ff       	call   f01000cb <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100fb1:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100fb6:	75 19                	jne    f0100fd1 <check_page_free_list+0x22c>
f0100fb8:	68 42 54 10 f0       	push   $0xf0105442
f0100fbd:	68 ef 53 10 f0       	push   $0xf01053ef
f0100fc2:	68 93 02 00 00       	push   $0x293
f0100fc7:	68 c9 53 10 f0       	push   $0xf01053c9
f0100fcc:	e8 fa f0 ff ff       	call   f01000cb <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100fd1:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100fd6:	76 3f                	jbe    f0101017 <check_page_free_list+0x272>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100fd8:	89 c3                	mov    %eax,%ebx
f0100fda:	c1 eb 0c             	shr    $0xc,%ebx
f0100fdd:	39 5d c8             	cmp    %ebx,-0x38(%ebp)
f0100fe0:	77 12                	ja     f0100ff4 <check_page_free_list+0x24f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100fe2:	50                   	push   %eax
f0100fe3:	68 70 4b 10 f0       	push   $0xf0104b70
f0100fe8:	6a 56                	push   $0x56
f0100fea:	68 d5 53 10 f0       	push   $0xf01053d5
f0100fef:	e8 d7 f0 ff ff       	call   f01000cb <_panic>
f0100ff4:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100ff9:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0100ffc:	76 1e                	jbe    f010101c <check_page_free_list+0x277>
f0100ffe:	68 24 4d 10 f0       	push   $0xf0104d24
f0101003:	68 ef 53 10 f0       	push   $0xf01053ef
f0101008:	68 94 02 00 00       	push   $0x294
f010100d:	68 c9 53 10 f0       	push   $0xf01053c9
f0101012:	e8 b4 f0 ff ff       	call   f01000cb <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
			++nfree_basemem;
f0101017:	83 c6 01             	add    $0x1,%esi
f010101a:	eb 04                	jmp    f0101020 <check_page_free_list+0x27b>
		else
			++nfree_extmem;
f010101c:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);
	}

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0101020:	8b 12                	mov    (%edx),%edx
f0101022:	85 d2                	test   %edx,%edx
f0101024:	0f 85 c8 fe ff ff    	jne    f0100ef2 <check_page_free_list+0x14d>
f010102a:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f010102d:	85 f6                	test   %esi,%esi
f010102f:	7f 19                	jg     f010104a <check_page_free_list+0x2a5>
f0101031:	68 5c 54 10 f0       	push   $0xf010545c
f0101036:	68 ef 53 10 f0       	push   $0xf01053ef
f010103b:	68 9c 02 00 00       	push   $0x29c
f0101040:	68 c9 53 10 f0       	push   $0xf01053c9
f0101045:	e8 81 f0 ff ff       	call   f01000cb <_panic>
	assert(nfree_extmem > 0);
f010104a:	85 db                	test   %ebx,%ebx
f010104c:	7f 2b                	jg     f0101079 <check_page_free_list+0x2d4>
f010104e:	68 6e 54 10 f0       	push   $0xf010546e
f0101053:	68 ef 53 10 f0       	push   $0xf01053ef
f0101058:	68 9d 02 00 00       	push   $0x29d
f010105d:	68 c9 53 10 f0       	push   $0xf01053c9
f0101062:	e8 64 f0 ff ff       	call   f01000cb <_panic>
	struct Page *pp;
	int pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0101067:	a1 9c f4 18 f0       	mov    0xf018f49c,%eax
f010106c:	85 c0                	test   %eax,%eax
f010106e:	0f 85 63 fd ff ff    	jne    f0100dd7 <check_page_free_list+0x32>
f0101074:	e9 47 fd ff ff       	jmp    f0100dc0 <check_page_free_list+0x1b>
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
	assert(nfree_extmem > 0);
}
f0101079:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010107c:	5b                   	pop    %ebx
f010107d:	5e                   	pop    %esi
f010107e:	5f                   	pop    %edi
f010107f:	5d                   	pop    %ebp
f0101080:	c3                   	ret    

f0101081 <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0101081:	55                   	push   %ebp
f0101082:	89 e5                	mov    %esp,%ebp
f0101084:	57                   	push   %edi
f0101085:	56                   	push   %esi
f0101086:	53                   	push   %ebx
f0101087:	83 ec 1c             	sub    $0x1c,%esp
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	char *first_free_page=(char *)boot_alloc(0);
f010108a:	b8 00 00 00 00       	mov    $0x0,%eax
f010108f:	e8 73 fc ff ff       	call   f0100d07 <boot_alloc>
f0101094:	89 45 dc             	mov    %eax,-0x24(%ebp)
	for (i = 0; i < npages; i++) {
f0101097:	8b 1d 64 01 19 f0    	mov    0xf0190164,%ebx
f010109d:	85 db                	test   %ebx,%ebx
f010109f:	0f 84 a6 00 00 00    	je     f010114b <page_init+0xca>
f01010a5:	a1 9c f4 18 f0       	mov    0xf018f49c,%eax
f01010aa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01010ad:	c6 45 e3 00          	movb   $0x0,-0x1d(%ebp)
f01010b1:	b8 00 00 00 00       	mov    $0x0,%eax
f01010b6:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
		if((page2pa(pages+i)>=PGSIZE&&page2pa(pages+i)<IOPHYSMEM)||(page2pa(pages+i)>=EXTPHYSMEM&&(char *)page2kva(pages+i)>=first_free_page))
f01010bd:	89 cf                	mov    %ecx,%edi
f01010bf:	03 3d 6c 01 19 f0    	add    0xf019016c,%edi
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f01010c5:	89 ca                	mov    %ecx,%edx
f01010c7:	c1 e2 09             	shl    $0x9,%edx
f01010ca:	8d b2 00 f0 ff ff    	lea    -0x1000(%edx),%esi
f01010d0:	81 fe ff ef 09 00    	cmp    $0x9efff,%esi
f01010d6:	76 3c                	jbe    f0101114 <page_init+0x93>
f01010d8:	81 fa ff ff 0f 00    	cmp    $0xfffff,%edx
f01010de:	76 4c                	jbe    f010112c <page_init+0xab>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01010e0:	89 d6                	mov    %edx,%esi
f01010e2:	c1 ee 0c             	shr    $0xc,%esi
f01010e5:	39 de                	cmp    %ebx,%esi
f01010e7:	72 20                	jb     f0101109 <page_init+0x88>
f01010e9:	80 7d e3 00          	cmpb   $0x0,-0x1d(%ebp)
f01010ed:	74 08                	je     f01010f7 <page_init+0x76>
f01010ef:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01010f2:	a3 9c f4 18 f0       	mov    %eax,0xf018f49c
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01010f7:	52                   	push   %edx
f01010f8:	68 70 4b 10 f0       	push   $0xf0104b70
f01010fd:	6a 56                	push   $0x56
f01010ff:	68 d5 53 10 f0       	push   $0xf01053d5
f0101104:	e8 c2 ef ff ff       	call   f01000cb <_panic>
f0101109:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f010110f:	39 55 dc             	cmp    %edx,-0x24(%ebp)
f0101112:	77 18                	ja     f010112c <page_init+0xab>
		{
			pages[i].pp_ref = 0;
f0101114:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)
			pages[i].pp_link = page_free_list;
f010111a:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f010111d:	89 37                	mov    %esi,(%edi)
			page_free_list = &pages[i];
f010111f:	03 0d 6c 01 19 f0    	add    0xf019016c,%ecx
f0101125:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f0101128:	c6 45 e3 01          	movb   $0x1,-0x1d(%ebp)
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	char *first_free_page=(char *)boot_alloc(0);
	for (i = 0; i < npages; i++) {
f010112c:	83 c0 01             	add    $0x1,%eax
f010112f:	8b 1d 64 01 19 f0    	mov    0xf0190164,%ebx
f0101135:	39 c3                	cmp    %eax,%ebx
f0101137:	0f 87 79 ff ff ff    	ja     f01010b6 <page_init+0x35>
f010113d:	80 7d e3 00          	cmpb   $0x0,-0x1d(%ebp)
f0101141:	74 08                	je     f010114b <page_init+0xca>
f0101143:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101146:	a3 9c f4 18 f0       	mov    %eax,0xf018f49c
			pages[i].pp_link = page_free_list;
			page_free_list = &pages[i];
		}
	}
	chunk_list = NULL;
}
f010114b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010114e:	5b                   	pop    %ebx
f010114f:	5e                   	pop    %esi
f0101150:	5f                   	pop    %edi
f0101151:	5d                   	pop    %ebp
f0101152:	c3                   	ret    

f0101153 <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct Page *
page_alloc(int alloc_flags)
{
f0101153:	55                   	push   %ebp
f0101154:	89 e5                	mov    %esp,%ebp
f0101156:	53                   	push   %ebx
f0101157:	83 ec 04             	sub    $0x4,%esp
	// Fill this function in
	if(!page_free_list)
f010115a:	8b 1d 9c f4 18 f0    	mov    0xf018f49c,%ebx
f0101160:	85 db                	test   %ebx,%ebx
f0101162:	74 52                	je     f01011b6 <page_alloc+0x63>
		return NULL;
	struct Page *ret=page_free_list;
	page_free_list=page_free_list->pp_link;
f0101164:	8b 03                	mov    (%ebx),%eax
f0101166:	a3 9c f4 18 f0       	mov    %eax,0xf018f49c
	if(alloc_flags&ALLOC_ZERO)
f010116b:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f010116f:	74 45                	je     f01011b6 <page_alloc+0x63>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0101171:	89 d8                	mov    %ebx,%eax
f0101173:	2b 05 6c 01 19 f0    	sub    0xf019016c,%eax
f0101179:	c1 f8 03             	sar    $0x3,%eax
f010117c:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010117f:	89 c2                	mov    %eax,%edx
f0101181:	c1 ea 0c             	shr    $0xc,%edx
f0101184:	3b 15 64 01 19 f0    	cmp    0xf0190164,%edx
f010118a:	72 12                	jb     f010119e <page_alloc+0x4b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010118c:	50                   	push   %eax
f010118d:	68 70 4b 10 f0       	push   $0xf0104b70
f0101192:	6a 56                	push   $0x56
f0101194:	68 d5 53 10 f0       	push   $0xf01053d5
f0101199:	e8 2d ef ff ff       	call   f01000cb <_panic>
		memset(page2kva(ret),'\0',PGSIZE);
f010119e:	83 ec 04             	sub    $0x4,%esp
f01011a1:	68 00 10 00 00       	push   $0x1000
f01011a6:	6a 00                	push   $0x0
f01011a8:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01011ad:	50                   	push   %eax
f01011ae:	e8 d1 2f 00 00       	call   f0104184 <memset>
f01011b3:	83 c4 10             	add    $0x10,%esp
	return ret;
}
f01011b6:	89 d8                	mov    %ebx,%eax
f01011b8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01011bb:	c9                   	leave  
f01011bc:	c3                   	ret    

f01011bd <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct Page *pp)
{
f01011bd:	55                   	push   %ebp
f01011be:	89 e5                	mov    %esp,%ebp
f01011c0:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function in
	if(pp->pp_ref!=0)
f01011c3:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f01011c8:	75 0d                	jne    f01011d7 <page_free+0x1a>
		return;
	pp->pp_link=page_free_list;
f01011ca:	8b 15 9c f4 18 f0    	mov    0xf018f49c,%edx
f01011d0:	89 10                	mov    %edx,(%eax)
	page_free_list=pp;
f01011d2:	a3 9c f4 18 f0       	mov    %eax,0xf018f49c
}
f01011d7:	5d                   	pop    %ebp
f01011d8:	c3                   	ret    

f01011d9 <page_realloc_npages>:
// You can man realloc for better understanding.
// (Try to reuse the allocated pages as many as possible.)
//
struct Page *
page_realloc_npages(struct Page *pp, int old_n, int new_n)
{
f01011d9:	55                   	push   %ebp
f01011da:	89 e5                	mov    %esp,%ebp
	// Fill this function
	return NULL;
}
f01011dc:	b8 00 00 00 00       	mov    $0x0,%eax
f01011e1:	5d                   	pop    %ebp
f01011e2:	c3                   	ret    

f01011e3 <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct Page* pp)
{
f01011e3:	55                   	push   %ebp
f01011e4:	89 e5                	mov    %esp,%ebp
f01011e6:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f01011e9:	0f b7 42 04          	movzwl 0x4(%edx),%eax
f01011ed:	83 e8 01             	sub    $0x1,%eax
f01011f0:	66 89 42 04          	mov    %ax,0x4(%edx)
f01011f4:	66 85 c0             	test   %ax,%ax
f01011f7:	75 09                	jne    f0101202 <page_decref+0x1f>
		page_free(pp);
f01011f9:	52                   	push   %edx
f01011fa:	e8 be ff ff ff       	call   f01011bd <page_free>
f01011ff:	83 c4 04             	add    $0x4,%esp
}
f0101202:	c9                   	leave  
f0101203:	c3                   	ret    

f0101204 <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that mainipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f0101204:	55                   	push   %ebp
f0101205:	89 e5                	mov    %esp,%ebp
f0101207:	56                   	push   %esi
f0101208:	53                   	push   %ebx
f0101209:	8b 75 0c             	mov    0xc(%ebp),%esi
	// Fill this function in
	//cprintf("kern/pmap.c [pgdir_walk] pgdir=%p,va=%p,create=%d\n",pgdir,va,create);
	pte_t *pte=(pte_t *)pgdir[PDX(va)];
f010120c:	89 f3                	mov    %esi,%ebx
f010120e:	c1 eb 16             	shr    $0x16,%ebx
f0101211:	c1 e3 02             	shl    $0x2,%ebx
f0101214:	03 5d 08             	add    0x8(%ebp),%ebx
f0101217:	8b 03                	mov    (%ebx),%eax
	if(((physaddr_t)pte&PTE_P)==0)
f0101219:	a8 01                	test   $0x1,%al
f010121b:	75 33                	jne    f0101250 <pgdir_walk+0x4c>
	{
		if(!create)
f010121d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0101221:	74 6a                	je     f010128d <pgdir_walk+0x89>
			return NULL;
		struct Page *result=page_alloc(1);
f0101223:	83 ec 0c             	sub    $0xc,%esp
f0101226:	6a 01                	push   $0x1
f0101228:	e8 26 ff ff ff       	call   f0101153 <page_alloc>
		if(result==NULL)
f010122d:	83 c4 10             	add    $0x10,%esp
f0101230:	85 c0                	test   %eax,%eax
f0101232:	74 60                	je     f0101294 <pgdir_walk+0x90>
			return NULL;
		result->pp_ref++;
f0101234:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0101239:	2b 05 6c 01 19 f0    	sub    0xf019016c,%eax
f010123f:	89 c2                	mov    %eax,%edx
f0101241:	c1 fa 03             	sar    $0x3,%edx
f0101244:	c1 e2 0c             	shl    $0xc,%edx
		pte=(pte_t *)page2pa(result);
f0101247:	89 d0                	mov    %edx,%eax
		pgdir[PDX(va)]=(physaddr_t)pte|create;
f0101249:	0b 55 10             	or     0x10(%ebp),%edx
f010124c:	89 13                	mov    %edx,(%ebx)
f010124e:	eb 04                	jmp    f0101254 <pgdir_walk+0x50>
	}
	else if((physaddr_t)pte&PTE_PS)
f0101250:	a8 80                	test   $0x80,%al
f0101252:	75 45                	jne    f0101299 <pgdir_walk+0x95>
		return &pgdir[PDX(va)];
	return &((pte_t *)KADDR(PTE_ADDR(pte)))[PTX(va)];
f0101254:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101259:	89 c2                	mov    %eax,%edx
f010125b:	c1 ea 0c             	shr    $0xc,%edx
f010125e:	3b 15 64 01 19 f0    	cmp    0xf0190164,%edx
f0101264:	72 15                	jb     f010127b <pgdir_walk+0x77>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101266:	50                   	push   %eax
f0101267:	68 70 4b 10 f0       	push   $0xf0104b70
f010126c:	68 84 01 00 00       	push   $0x184
f0101271:	68 c9 53 10 f0       	push   $0xf01053c9
f0101276:	e8 50 ee ff ff       	call   f01000cb <_panic>
f010127b:	c1 ee 0a             	shr    $0xa,%esi
f010127e:	81 e6 fc 0f 00 00    	and    $0xffc,%esi
f0101284:	8d 9c 30 00 00 00 f0 	lea    -0x10000000(%eax,%esi,1),%ebx
f010128b:	eb 0c                	jmp    f0101299 <pgdir_walk+0x95>
	//cprintf("kern/pmap.c [pgdir_walk] pgdir=%p,va=%p,create=%d\n",pgdir,va,create);
	pte_t *pte=(pte_t *)pgdir[PDX(va)];
	if(((physaddr_t)pte&PTE_P)==0)
	{
		if(!create)
			return NULL;
f010128d:	bb 00 00 00 00       	mov    $0x0,%ebx
f0101292:	eb 05                	jmp    f0101299 <pgdir_walk+0x95>
		struct Page *result=page_alloc(1);
		if(result==NULL)
			return NULL;
f0101294:	bb 00 00 00 00       	mov    $0x0,%ebx
		pgdir[PDX(va)]=(physaddr_t)pte|create;
	}
	else if((physaddr_t)pte&PTE_PS)
		return &pgdir[PDX(va)];
	return &((pte_t *)KADDR(PTE_ADDR(pte)))[PTX(va)];
}
f0101299:	89 d8                	mov    %ebx,%eax
f010129b:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010129e:	5b                   	pop    %ebx
f010129f:	5e                   	pop    %esi
f01012a0:	5d                   	pop    %ebp
f01012a1:	c3                   	ret    

f01012a2 <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f01012a2:	55                   	push   %ebp
f01012a3:	89 e5                	mov    %esp,%ebp
f01012a5:	57                   	push   %edi
f01012a6:	56                   	push   %esi
f01012a7:	53                   	push   %ebx
f01012a8:	83 ec 1c             	sub    $0x1c,%esp
	// Fill this function in
	//cprintf("kern/pmap.c [boot_map_region] va=%p,size=%p,pa=%p\n",va,size,pa);
	for(uint32_t end=va+size;va<end;va+=PGSIZE,pa+=PGSIZE)
f01012ab:	01 d1                	add    %edx,%ecx
f01012ad:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f01012b0:	39 ca                	cmp    %ecx,%edx
f01012b2:	73 5d                	jae    f0101311 <boot_map_region+0x6f>
	{
		if(va==0&&end==0xFFFFFFFF)
f01012b4:	83 f9 ff             	cmp    $0xffffffff,%ecx
f01012b7:	0f 94 45 db          	sete   -0x25(%ebp)
f01012bb:	0f b6 4d db          	movzbl -0x25(%ebp),%ecx
f01012bf:	85 d2                	test   %edx,%edx
f01012c1:	75 04                	jne    f01012c7 <boot_map_region+0x25>
f01012c3:	84 c9                	test   %cl,%cl
f01012c5:	75 4a                	jne    f0101311 <boot_map_region+0x6f>
f01012c7:	89 45 dc             	mov    %eax,-0x24(%ebp)
f01012ca:	89 d3                	mov    %edx,%ebx
f01012cc:	8b 45 08             	mov    0x8(%ebp),%eax
f01012cf:	29 d0                	sub    %edx,%eax
f01012d1:	89 45 e0             	mov    %eax,-0x20(%ebp)
			return;
		pte_t *pte=pgdir_walk(pgdir,(void *)va,perm|PTE_P);
f01012d4:	8b 7d 0c             	mov    0xc(%ebp),%edi
f01012d7:	83 cf 01             	or     $0x1,%edi
f01012da:	eb 0a                	jmp    f01012e6 <boot_map_region+0x44>
{
	// Fill this function in
	//cprintf("kern/pmap.c [boot_map_region] va=%p,size=%p,pa=%p\n",va,size,pa);
	for(uint32_t end=va+size;va<end;va+=PGSIZE,pa+=PGSIZE)
	{
		if(va==0&&end==0xFFFFFFFF)
f01012dc:	85 db                	test   %ebx,%ebx
f01012de:	75 06                	jne    f01012e6 <boot_map_region+0x44>
f01012e0:	80 7d db 00          	cmpb   $0x0,-0x25(%ebp)
f01012e4:	75 2b                	jne    f0101311 <boot_map_region+0x6f>
f01012e6:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01012e9:	8d 34 18             	lea    (%eax,%ebx,1),%esi
			return;
		pte_t *pte=pgdir_walk(pgdir,(void *)va,perm|PTE_P);
f01012ec:	83 ec 04             	sub    $0x4,%esp
f01012ef:	57                   	push   %edi
f01012f0:	53                   	push   %ebx
f01012f1:	ff 75 dc             	pushl  -0x24(%ebp)
f01012f4:	e8 0b ff ff ff       	call   f0101204 <pgdir_walk>
		*pte=PTE_ADDR(pa)|perm|PTE_P;
f01012f9:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
f01012ff:	09 fe                	or     %edi,%esi
f0101301:	89 30                	mov    %esi,(%eax)
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	// Fill this function in
	//cprintf("kern/pmap.c [boot_map_region] va=%p,size=%p,pa=%p\n",va,size,pa);
	for(uint32_t end=va+size;va<end;va+=PGSIZE,pa+=PGSIZE)
f0101303:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0101309:	83 c4 10             	add    $0x10,%esp
f010130c:	39 5d e4             	cmp    %ebx,-0x1c(%ebp)
f010130f:	77 cb                	ja     f01012dc <boot_map_region+0x3a>
		if(va==0&&end==0xFFFFFFFF)
			return;
		pte_t *pte=pgdir_walk(pgdir,(void *)va,perm|PTE_P);
		*pte=PTE_ADDR(pa)|perm|PTE_P;
	}
}
f0101311:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101314:	5b                   	pop    %ebx
f0101315:	5e                   	pop    %esi
f0101316:	5f                   	pop    %edi
f0101317:	5d                   	pop    %ebp
f0101318:	c3                   	ret    

f0101319 <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct Page *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f0101319:	55                   	push   %ebp
f010131a:	89 e5                	mov    %esp,%ebp
f010131c:	53                   	push   %ebx
f010131d:	83 ec 08             	sub    $0x8,%esp
f0101320:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// Fill this function in
	pte_t *pte=pgdir_walk(pgdir,va,0);
f0101323:	6a 00                	push   $0x0
f0101325:	ff 75 0c             	pushl  0xc(%ebp)
f0101328:	ff 75 08             	pushl  0x8(%ebp)
f010132b:	e8 d4 fe ff ff       	call   f0101204 <pgdir_walk>
	if(pte==NULL)
f0101330:	83 c4 10             	add    $0x10,%esp
f0101333:	85 c0                	test   %eax,%eax
f0101335:	74 32                	je     f0101369 <page_lookup+0x50>
		return NULL;
	if(pte_store)
f0101337:	85 db                	test   %ebx,%ebx
f0101339:	74 02                	je     f010133d <page_lookup+0x24>
		*pte_store=pte;
f010133b:	89 03                	mov    %eax,(%ebx)
}

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010133d:	8b 00                	mov    (%eax),%eax
f010133f:	c1 e8 0c             	shr    $0xc,%eax
f0101342:	3b 05 64 01 19 f0    	cmp    0xf0190164,%eax
f0101348:	72 14                	jb     f010135e <page_lookup+0x45>
		panic("pa2page called with invalid pa");
f010134a:	83 ec 04             	sub    $0x4,%esp
f010134d:	68 6c 4d 10 f0       	push   $0xf0104d6c
f0101352:	6a 4f                	push   $0x4f
f0101354:	68 d5 53 10 f0       	push   $0xf01053d5
f0101359:	e8 6d ed ff ff       	call   f01000cb <_panic>
	return &pages[PGNUM(pa)];
f010135e:	8b 15 6c 01 19 f0    	mov    0xf019016c,%edx
f0101364:	8d 04 c2             	lea    (%edx,%eax,8),%eax
	return pa2page(PTE_ADDR(*pte));
f0101367:	eb 05                	jmp    f010136e <page_lookup+0x55>
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
	// Fill this function in
	pte_t *pte=pgdir_walk(pgdir,va,0);
	if(pte==NULL)
		return NULL;
f0101369:	b8 00 00 00 00       	mov    $0x0,%eax
	if(pte_store)
		*pte_store=pte;
	return pa2page(PTE_ADDR(*pte));
}
f010136e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101371:	c9                   	leave  
f0101372:	c3                   	ret    

f0101373 <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f0101373:	55                   	push   %ebp
f0101374:	89 e5                	mov    %esp,%ebp
f0101376:	53                   	push   %ebx
f0101377:	83 ec 18             	sub    $0x18,%esp
f010137a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Fill this function in
	pte_t *pte;
	struct Page *page=page_lookup(pgdir,va,&pte);
f010137d:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0101380:	50                   	push   %eax
f0101381:	53                   	push   %ebx
f0101382:	ff 75 08             	pushl  0x8(%ebp)
f0101385:	e8 8f ff ff ff       	call   f0101319 <page_lookup>
	if(page==NULL)
f010138a:	83 c4 10             	add    $0x10,%esp
f010138d:	85 c0                	test   %eax,%eax
f010138f:	74 15                	je     f01013a6 <page_remove+0x33>
}

static __inline void 
invlpg(void *addr)
{ 
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0101391:	0f 01 3b             	invlpg (%ebx)
		return;
	tlb_invalidate(pgdir,va);
	*pte=*pte&~PTE_P;
f0101394:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0101397:	83 22 fe             	andl   $0xfffffffe,(%edx)
	page_decref(page);
f010139a:	83 ec 0c             	sub    $0xc,%esp
f010139d:	50                   	push   %eax
f010139e:	e8 40 fe ff ff       	call   f01011e3 <page_decref>
f01013a3:	83 c4 10             	add    $0x10,%esp
}
f01013a6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01013a9:	c9                   	leave  
f01013aa:	c3                   	ret    

f01013ab <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct Page *pp, void *va, int perm)
{
f01013ab:	55                   	push   %ebp
f01013ac:	89 e5                	mov    %esp,%ebp
f01013ae:	57                   	push   %edi
f01013af:	56                   	push   %esi
f01013b0:	53                   	push   %ebx
f01013b1:	83 ec 20             	sub    $0x20,%esp
f01013b4:	8b 7d 0c             	mov    0xc(%ebp),%edi
	// Fill this function in
	//cprintf("kern/pmap.c [page_insert] pgdir=%p,va=%p\n",pgdir,va);
	pte_t *pte=pgdir_walk(pgdir,va,0);
f01013b7:	6a 00                	push   $0x0
f01013b9:	ff 75 10             	pushl  0x10(%ebp)
f01013bc:	ff 75 08             	pushl  0x8(%ebp)
f01013bf:	e8 40 fe ff ff       	call   f0101204 <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f01013c4:	89 fb                	mov    %edi,%ebx
f01013c6:	2b 1d 6c 01 19 f0    	sub    0xf019016c,%ebx
f01013cc:	c1 fb 03             	sar    $0x3,%ebx
f01013cf:	c1 e3 0c             	shl    $0xc,%ebx
	physaddr_t pp_pa=page2pa(pp);
	if(pte==NULL)
f01013d2:	83 c4 10             	add    $0x10,%esp
f01013d5:	85 c0                	test   %eax,%eax
f01013d7:	75 79                	jne    f0101452 <page_insert+0xa7>
	{
		struct Page *page=page_alloc(1);
f01013d9:	83 ec 0c             	sub    $0xc,%esp
f01013dc:	6a 01                	push   $0x1
f01013de:	e8 70 fd ff ff       	call   f0101153 <page_alloc>
		if(page==NULL)
f01013e3:	83 c4 10             	add    $0x10,%esp
f01013e6:	85 c0                	test   %eax,%eax
f01013e8:	0f 84 e2 00 00 00    	je     f01014d0 <page_insert+0x125>
			return -E_NO_MEM;
		page->pp_ref++;
f01013ee:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
f01013f3:	2b 05 6c 01 19 f0    	sub    0xf019016c,%eax
f01013f9:	c1 f8 03             	sar    $0x3,%eax
f01013fc:	c1 e0 0c             	shl    $0xc,%eax
f01013ff:	8b 75 14             	mov    0x14(%ebp),%esi
f0101402:	83 ce 01             	or     $0x1,%esi
f0101405:	89 75 e4             	mov    %esi,-0x1c(%ebp)
		physaddr_t pa=page2pa(page);
		pgdir[PDX(va)]=pa|perm|PTE_P;
f0101408:	8b 55 10             	mov    0x10(%ebp),%edx
f010140b:	c1 ea 16             	shr    $0x16,%edx
f010140e:	89 f1                	mov    %esi,%ecx
f0101410:	09 c1                	or     %eax,%ecx
f0101412:	8b 75 08             	mov    0x8(%ebp),%esi
f0101415:	89 0c 96             	mov    %ecx,(%esi,%edx,4)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101418:	89 c2                	mov    %eax,%edx
f010141a:	c1 ea 0c             	shr    $0xc,%edx
f010141d:	3b 15 64 01 19 f0    	cmp    0xf0190164,%edx
f0101423:	72 15                	jb     f010143a <page_insert+0x8f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101425:	50                   	push   %eax
f0101426:	68 70 4b 10 f0       	push   $0xf0104b70
f010142b:	68 dc 01 00 00       	push   $0x1dc
f0101430:	68 c9 53 10 f0       	push   $0xf01053c9
f0101435:	e8 91 ec ff ff       	call   f01000cb <_panic>
		((pte_t *)KADDR(pa))[PTX(va)]=PTE_ADDR(pp_pa)|perm|PTE_P;
f010143a:	8b 55 10             	mov    0x10(%ebp),%edx
f010143d:	c1 ea 0c             	shr    $0xc,%edx
f0101440:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0101446:	0b 5d e4             	or     -0x1c(%ebp),%ebx
f0101449:	89 9c 90 00 00 00 f0 	mov    %ebx,-0x10000000(%eax,%edx,4)
f0101450:	eb 72                	jmp    f01014c4 <page_insert+0x119>
f0101452:	89 c6                	mov    %eax,%esi
	}
	else
	{
		if(*pte!=0)
f0101454:	8b 00                	mov    (%eax),%eax
f0101456:	85 c0                	test   %eax,%eax
f0101458:	74 48                	je     f01014a2 <page_insert+0xf7>
f010145a:	8b 55 14             	mov    0x14(%ebp),%edx
f010145d:	83 ca 01             	or     $0x1,%edx
		{
			if(*pte==(PTE_ADDR(pp_pa)|perm|PTE_P))
f0101460:	89 d9                	mov    %ebx,%ecx
f0101462:	09 d1                	or     %edx,%ecx
f0101464:	39 c8                	cmp    %ecx,%eax
f0101466:	74 6f                	je     f01014d7 <page_insert+0x12c>
				return 0;
			if(PTE_ADDR(*pte)==PTE_ADDR(pp_pa))
f0101468:	31 d8                	xor    %ebx,%eax
f010146a:	a9 00 f0 ff ff       	test   $0xfffff000,%eax
f010146f:	75 20                	jne    f0101491 <page_insert+0xe6>
			{
				*pte=PTE_ADDR(pp_pa)|perm|PTE_P;
f0101471:	89 0e                	mov    %ecx,(%esi)
				pgdir[PDX(va)]=PTE_ADDR(pgdir[PDX(va)])|perm|PTE_P;
f0101473:	8b 45 10             	mov    0x10(%ebp),%eax
f0101476:	c1 e8 16             	shr    $0x16,%eax
f0101479:	8b 7d 08             	mov    0x8(%ebp),%edi
f010147c:	8d 0c 87             	lea    (%edi,%eax,4),%ecx
f010147f:	8b 01                	mov    (%ecx),%eax
f0101481:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0101486:	09 c2                	or     %eax,%edx
f0101488:	89 11                	mov    %edx,(%ecx)
				return 0;
f010148a:	b8 00 00 00 00       	mov    $0x0,%eax
f010148f:	eb 4b                	jmp    f01014dc <page_insert+0x131>
			}
			page_remove(pgdir,va);
f0101491:	83 ec 08             	sub    $0x8,%esp
f0101494:	ff 75 10             	pushl  0x10(%ebp)
f0101497:	ff 75 08             	pushl  0x8(%ebp)
f010149a:	e8 d4 fe ff ff       	call   f0101373 <page_remove>
f010149f:	83 c4 10             	add    $0x10,%esp
f01014a2:	8b 45 14             	mov    0x14(%ebp),%eax
f01014a5:	83 c8 01             	or     $0x1,%eax
		}
		*pte=PTE_ADDR(pp_pa)|perm|PTE_P;
f01014a8:	09 c3                	or     %eax,%ebx
f01014aa:	89 1e                	mov    %ebx,(%esi)
		pgdir[PDX(va)]=PTE_ADDR(pgdir[PDX(va)])|perm|PTE_P;
f01014ac:	8b 55 10             	mov    0x10(%ebp),%edx
f01014af:	c1 ea 16             	shr    $0x16,%edx
f01014b2:	8b 75 08             	mov    0x8(%ebp),%esi
f01014b5:	8d 0c 96             	lea    (%esi,%edx,4),%ecx
f01014b8:	8b 11                	mov    (%ecx),%edx
f01014ba:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01014c0:	09 d0                	or     %edx,%eax
f01014c2:	89 01                	mov    %eax,(%ecx)
	}
	pp->pp_ref++;
f01014c4:	66 83 47 04 01       	addw   $0x1,0x4(%edi)
	return 0;
f01014c9:	b8 00 00 00 00       	mov    $0x0,%eax
f01014ce:	eb 0c                	jmp    f01014dc <page_insert+0x131>
	physaddr_t pp_pa=page2pa(pp);
	if(pte==NULL)
	{
		struct Page *page=page_alloc(1);
		if(page==NULL)
			return -E_NO_MEM;
f01014d0:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f01014d5:	eb 05                	jmp    f01014dc <page_insert+0x131>
	else
	{
		if(*pte!=0)
		{
			if(*pte==(PTE_ADDR(pp_pa)|perm|PTE_P))
				return 0;
f01014d7:	b8 00 00 00 00       	mov    $0x0,%eax
		*pte=PTE_ADDR(pp_pa)|perm|PTE_P;
		pgdir[PDX(va)]=PTE_ADDR(pgdir[PDX(va)])|perm|PTE_P;
	}
	pp->pp_ref++;
	return 0;
}
f01014dc:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01014df:	5b                   	pop    %ebx
f01014e0:	5e                   	pop    %esi
f01014e1:	5f                   	pop    %edi
f01014e2:	5d                   	pop    %ebp
f01014e3:	c3                   	ret    

f01014e4 <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f01014e4:	55                   	push   %ebp
f01014e5:	89 e5                	mov    %esp,%ebp
f01014e7:	57                   	push   %edi
f01014e8:	56                   	push   %esi
f01014e9:	53                   	push   %ebx
f01014ea:	83 ec 48             	sub    $0x48,%esp
// --------------------------------------------------------------

static int
nvram_read(int r)
{
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f01014ed:	6a 15                	push   $0x15
f01014ef:	e8 c5 1a 00 00       	call   f0102fb9 <mc146818_read>
f01014f4:	89 c3                	mov    %eax,%ebx
f01014f6:	c7 04 24 16 00 00 00 	movl   $0x16,(%esp)
f01014fd:	e8 b7 1a 00 00       	call   f0102fb9 <mc146818_read>
{
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f0101502:	c1 e0 08             	shl    $0x8,%eax
f0101505:	09 d8                	or     %ebx,%eax
f0101507:	c1 e0 0a             	shl    $0xa,%eax
f010150a:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f0101510:	85 c0                	test   %eax,%eax
f0101512:	0f 48 c2             	cmovs  %edx,%eax
f0101515:	c1 f8 0c             	sar    $0xc,%eax
f0101518:	a3 a0 f4 18 f0       	mov    %eax,0xf018f4a0
// --------------------------------------------------------------

static int
nvram_read(int r)
{
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f010151d:	c7 04 24 17 00 00 00 	movl   $0x17,(%esp)
f0101524:	e8 90 1a 00 00       	call   f0102fb9 <mc146818_read>
f0101529:	89 c3                	mov    %eax,%ebx
f010152b:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
f0101532:	e8 82 1a 00 00       	call   f0102fb9 <mc146818_read>
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f0101537:	c1 e0 08             	shl    $0x8,%eax
f010153a:	09 d8                	or     %ebx,%eax
f010153c:	c1 e0 0a             	shl    $0xa,%eax
f010153f:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f0101545:	83 c4 10             	add    $0x10,%esp
f0101548:	85 c0                	test   %eax,%eax
f010154a:	0f 48 c2             	cmovs  %edx,%eax
f010154d:	c1 f8 0c             	sar    $0xc,%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (npages_extmem)
f0101550:	85 c0                	test   %eax,%eax
f0101552:	74 0e                	je     f0101562 <mem_init+0x7e>
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f0101554:	8d 90 00 01 00 00    	lea    0x100(%eax),%edx
f010155a:	89 15 64 01 19 f0    	mov    %edx,0xf0190164
f0101560:	eb 0c                	jmp    f010156e <mem_init+0x8a>
	else
		npages = npages_basemem;
f0101562:	8b 15 a0 f4 18 f0    	mov    0xf018f4a0,%edx
f0101568:	89 15 64 01 19 f0    	mov    %edx,0xf0190164

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f010156e:	c1 e0 0c             	shl    $0xc,%eax
f0101571:	c1 e8 0a             	shr    $0xa,%eax
f0101574:	50                   	push   %eax
f0101575:	a1 a0 f4 18 f0       	mov    0xf018f4a0,%eax
f010157a:	c1 e0 0c             	shl    $0xc,%eax
f010157d:	c1 e8 0a             	shr    $0xa,%eax
f0101580:	50                   	push   %eax
f0101581:	a1 64 01 19 f0       	mov    0xf0190164,%eax
f0101586:	c1 e0 0c             	shl    $0xc,%eax
f0101589:	c1 e8 0a             	shr    $0xa,%eax
f010158c:	50                   	push   %eax
f010158d:	68 8c 4d 10 f0       	push   $0xf0104d8c
f0101592:	e8 93 1a 00 00       	call   f010302a <cprintf>
	// Remove this line when you're ready to test this function.
	// panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f0101597:	b8 00 10 00 00       	mov    $0x1000,%eax
f010159c:	e8 66 f7 ff ff       	call   f0100d07 <boot_alloc>
f01015a1:	a3 68 01 19 f0       	mov    %eax,0xf0190168
	memset(kern_pgdir, 0, PGSIZE);
f01015a6:	83 c4 0c             	add    $0xc,%esp
f01015a9:	68 00 10 00 00       	push   $0x1000
f01015ae:	6a 00                	push   $0x0
f01015b0:	50                   	push   %eax
f01015b1:	e8 ce 2b 00 00       	call   f0104184 <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following two lines.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f01015b6:	a1 68 01 19 f0       	mov    0xf0190168,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01015bb:	83 c4 10             	add    $0x10,%esp
f01015be:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01015c3:	77 15                	ja     f01015da <mem_init+0xf6>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01015c5:	50                   	push   %eax
f01015c6:	68 c8 4d 10 f0       	push   $0xf0104dc8
f01015cb:	68 93 00 00 00       	push   $0x93
f01015d0:	68 c9 53 10 f0       	push   $0xf01053c9
f01015d5:	e8 f1 ea ff ff       	call   f01000cb <_panic>
f01015da:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01015e0:	83 ca 05             	or     $0x5,%edx
f01015e3:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate an array of npages 'struct Page's and store it in 'pages'.
	// The kernel uses this array to keep track of physical pages: for
	// each physical page, there is a corresponding struct Page in this
	// array.  'npages' is the number of physical pages in memory.
	// Your code goes here:
	pages=boot_alloc(npages*(sizeof(struct Page)));
f01015e9:	a1 64 01 19 f0       	mov    0xf0190164,%eax
f01015ee:	c1 e0 03             	shl    $0x3,%eax
f01015f1:	e8 11 f7 ff ff       	call   f0100d07 <boot_alloc>
f01015f6:	a3 6c 01 19 f0       	mov    %eax,0xf019016c
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f01015fb:	e8 81 fa ff ff       	call   f0101081 <page_init>

	check_page_free_list(1);
f0101600:	b8 01 00 00 00       	mov    $0x1,%eax
f0101605:	e8 9b f7 ff ff       	call   f0100da5 <check_page_free_list>
	int nfree;
	struct Page *fl;
	char *c;
	int i;

	if (!pages)
f010160a:	83 3d 6c 01 19 f0 00 	cmpl   $0x0,0xf019016c
f0101611:	75 17                	jne    f010162a <mem_init+0x146>
		panic("'pages' is a null pointer!");
f0101613:	83 ec 04             	sub    $0x4,%esp
f0101616:	68 7f 54 10 f0       	push   $0xf010547f
f010161b:	68 ae 02 00 00       	push   $0x2ae
f0101620:	68 c9 53 10 f0       	push   $0xf01053c9
f0101625:	e8 a1 ea ff ff       	call   f01000cb <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f010162a:	a1 9c f4 18 f0       	mov    0xf018f49c,%eax
f010162f:	85 c0                	test   %eax,%eax
f0101631:	74 10                	je     f0101643 <mem_init+0x15f>
f0101633:	bb 00 00 00 00       	mov    $0x0,%ebx
		++nfree;
f0101638:	83 c3 01             	add    $0x1,%ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f010163b:	8b 00                	mov    (%eax),%eax
f010163d:	85 c0                	test   %eax,%eax
f010163f:	75 f7                	jne    f0101638 <mem_init+0x154>
f0101641:	eb 05                	jmp    f0101648 <mem_init+0x164>
f0101643:	bb 00 00 00 00       	mov    $0x0,%ebx
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101648:	83 ec 0c             	sub    $0xc,%esp
f010164b:	6a 00                	push   $0x0
f010164d:	e8 01 fb ff ff       	call   f0101153 <page_alloc>
f0101652:	89 c7                	mov    %eax,%edi
f0101654:	83 c4 10             	add    $0x10,%esp
f0101657:	85 c0                	test   %eax,%eax
f0101659:	75 19                	jne    f0101674 <mem_init+0x190>
f010165b:	68 9a 54 10 f0       	push   $0xf010549a
f0101660:	68 ef 53 10 f0       	push   $0xf01053ef
f0101665:	68 b6 02 00 00       	push   $0x2b6
f010166a:	68 c9 53 10 f0       	push   $0xf01053c9
f010166f:	e8 57 ea ff ff       	call   f01000cb <_panic>
	assert((pp1 = page_alloc(0)));
f0101674:	83 ec 0c             	sub    $0xc,%esp
f0101677:	6a 00                	push   $0x0
f0101679:	e8 d5 fa ff ff       	call   f0101153 <page_alloc>
f010167e:	89 c6                	mov    %eax,%esi
f0101680:	83 c4 10             	add    $0x10,%esp
f0101683:	85 c0                	test   %eax,%eax
f0101685:	75 19                	jne    f01016a0 <mem_init+0x1bc>
f0101687:	68 b0 54 10 f0       	push   $0xf01054b0
f010168c:	68 ef 53 10 f0       	push   $0xf01053ef
f0101691:	68 b7 02 00 00       	push   $0x2b7
f0101696:	68 c9 53 10 f0       	push   $0xf01053c9
f010169b:	e8 2b ea ff ff       	call   f01000cb <_panic>
	assert((pp2 = page_alloc(0)));
f01016a0:	83 ec 0c             	sub    $0xc,%esp
f01016a3:	6a 00                	push   $0x0
f01016a5:	e8 a9 fa ff ff       	call   f0101153 <page_alloc>
f01016aa:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01016ad:	83 c4 10             	add    $0x10,%esp
f01016b0:	85 c0                	test   %eax,%eax
f01016b2:	75 19                	jne    f01016cd <mem_init+0x1e9>
f01016b4:	68 c6 54 10 f0       	push   $0xf01054c6
f01016b9:	68 ef 53 10 f0       	push   $0xf01053ef
f01016be:	68 b8 02 00 00       	push   $0x2b8
f01016c3:	68 c9 53 10 f0       	push   $0xf01053c9
f01016c8:	e8 fe e9 ff ff       	call   f01000cb <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01016cd:	39 f7                	cmp    %esi,%edi
f01016cf:	75 19                	jne    f01016ea <mem_init+0x206>
f01016d1:	68 dc 54 10 f0       	push   $0xf01054dc
f01016d6:	68 ef 53 10 f0       	push   $0xf01053ef
f01016db:	68 bb 02 00 00       	push   $0x2bb
f01016e0:	68 c9 53 10 f0       	push   $0xf01053c9
f01016e5:	e8 e1 e9 ff ff       	call   f01000cb <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01016ea:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01016ed:	39 c6                	cmp    %eax,%esi
f01016ef:	74 04                	je     f01016f5 <mem_init+0x211>
f01016f1:	39 c7                	cmp    %eax,%edi
f01016f3:	75 19                	jne    f010170e <mem_init+0x22a>
f01016f5:	68 ec 4d 10 f0       	push   $0xf0104dec
f01016fa:	68 ef 53 10 f0       	push   $0xf01053ef
f01016ff:	68 bc 02 00 00       	push   $0x2bc
f0101704:	68 c9 53 10 f0       	push   $0xf01053c9
f0101709:	e8 bd e9 ff ff       	call   f01000cb <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f010170e:	8b 0d 6c 01 19 f0    	mov    0xf019016c,%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f0101714:	8b 15 64 01 19 f0    	mov    0xf0190164,%edx
f010171a:	c1 e2 0c             	shl    $0xc,%edx
f010171d:	89 f8                	mov    %edi,%eax
f010171f:	29 c8                	sub    %ecx,%eax
f0101721:	c1 f8 03             	sar    $0x3,%eax
f0101724:	c1 e0 0c             	shl    $0xc,%eax
f0101727:	39 d0                	cmp    %edx,%eax
f0101729:	72 19                	jb     f0101744 <mem_init+0x260>
f010172b:	68 ee 54 10 f0       	push   $0xf01054ee
f0101730:	68 ef 53 10 f0       	push   $0xf01053ef
f0101735:	68 bd 02 00 00       	push   $0x2bd
f010173a:	68 c9 53 10 f0       	push   $0xf01053c9
f010173f:	e8 87 e9 ff ff       	call   f01000cb <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f0101744:	89 f0                	mov    %esi,%eax
f0101746:	29 c8                	sub    %ecx,%eax
f0101748:	c1 f8 03             	sar    $0x3,%eax
f010174b:	c1 e0 0c             	shl    $0xc,%eax
f010174e:	39 c2                	cmp    %eax,%edx
f0101750:	77 19                	ja     f010176b <mem_init+0x287>
f0101752:	68 0b 55 10 f0       	push   $0xf010550b
f0101757:	68 ef 53 10 f0       	push   $0xf01053ef
f010175c:	68 be 02 00 00       	push   $0x2be
f0101761:	68 c9 53 10 f0       	push   $0xf01053c9
f0101766:	e8 60 e9 ff ff       	call   f01000cb <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f010176b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010176e:	29 c8                	sub    %ecx,%eax
f0101770:	c1 f8 03             	sar    $0x3,%eax
f0101773:	c1 e0 0c             	shl    $0xc,%eax
f0101776:	39 c2                	cmp    %eax,%edx
f0101778:	77 19                	ja     f0101793 <mem_init+0x2af>
f010177a:	68 28 55 10 f0       	push   $0xf0105528
f010177f:	68 ef 53 10 f0       	push   $0xf01053ef
f0101784:	68 bf 02 00 00       	push   $0x2bf
f0101789:	68 c9 53 10 f0       	push   $0xf01053c9
f010178e:	e8 38 e9 ff ff       	call   f01000cb <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101793:	a1 9c f4 18 f0       	mov    0xf018f49c,%eax
f0101798:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f010179b:	c7 05 9c f4 18 f0 00 	movl   $0x0,0xf018f49c
f01017a2:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f01017a5:	83 ec 0c             	sub    $0xc,%esp
f01017a8:	6a 00                	push   $0x0
f01017aa:	e8 a4 f9 ff ff       	call   f0101153 <page_alloc>
f01017af:	83 c4 10             	add    $0x10,%esp
f01017b2:	85 c0                	test   %eax,%eax
f01017b4:	74 19                	je     f01017cf <mem_init+0x2eb>
f01017b6:	68 45 55 10 f0       	push   $0xf0105545
f01017bb:	68 ef 53 10 f0       	push   $0xf01053ef
f01017c0:	68 c6 02 00 00       	push   $0x2c6
f01017c5:	68 c9 53 10 f0       	push   $0xf01053c9
f01017ca:	e8 fc e8 ff ff       	call   f01000cb <_panic>

	// free and re-allocate?
	page_free(pp0);
f01017cf:	83 ec 0c             	sub    $0xc,%esp
f01017d2:	57                   	push   %edi
f01017d3:	e8 e5 f9 ff ff       	call   f01011bd <page_free>
	page_free(pp1);
f01017d8:	89 34 24             	mov    %esi,(%esp)
f01017db:	e8 dd f9 ff ff       	call   f01011bd <page_free>
	page_free(pp2);
f01017e0:	83 c4 04             	add    $0x4,%esp
f01017e3:	ff 75 d4             	pushl  -0x2c(%ebp)
f01017e6:	e8 d2 f9 ff ff       	call   f01011bd <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01017eb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01017f2:	e8 5c f9 ff ff       	call   f0101153 <page_alloc>
f01017f7:	89 c6                	mov    %eax,%esi
f01017f9:	83 c4 10             	add    $0x10,%esp
f01017fc:	85 c0                	test   %eax,%eax
f01017fe:	75 19                	jne    f0101819 <mem_init+0x335>
f0101800:	68 9a 54 10 f0       	push   $0xf010549a
f0101805:	68 ef 53 10 f0       	push   $0xf01053ef
f010180a:	68 cd 02 00 00       	push   $0x2cd
f010180f:	68 c9 53 10 f0       	push   $0xf01053c9
f0101814:	e8 b2 e8 ff ff       	call   f01000cb <_panic>
	assert((pp1 = page_alloc(0)));
f0101819:	83 ec 0c             	sub    $0xc,%esp
f010181c:	6a 00                	push   $0x0
f010181e:	e8 30 f9 ff ff       	call   f0101153 <page_alloc>
f0101823:	89 c7                	mov    %eax,%edi
f0101825:	83 c4 10             	add    $0x10,%esp
f0101828:	85 c0                	test   %eax,%eax
f010182a:	75 19                	jne    f0101845 <mem_init+0x361>
f010182c:	68 b0 54 10 f0       	push   $0xf01054b0
f0101831:	68 ef 53 10 f0       	push   $0xf01053ef
f0101836:	68 ce 02 00 00       	push   $0x2ce
f010183b:	68 c9 53 10 f0       	push   $0xf01053c9
f0101840:	e8 86 e8 ff ff       	call   f01000cb <_panic>
	assert((pp2 = page_alloc(0)));
f0101845:	83 ec 0c             	sub    $0xc,%esp
f0101848:	6a 00                	push   $0x0
f010184a:	e8 04 f9 ff ff       	call   f0101153 <page_alloc>
f010184f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101852:	83 c4 10             	add    $0x10,%esp
f0101855:	85 c0                	test   %eax,%eax
f0101857:	75 19                	jne    f0101872 <mem_init+0x38e>
f0101859:	68 c6 54 10 f0       	push   $0xf01054c6
f010185e:	68 ef 53 10 f0       	push   $0xf01053ef
f0101863:	68 cf 02 00 00       	push   $0x2cf
f0101868:	68 c9 53 10 f0       	push   $0xf01053c9
f010186d:	e8 59 e8 ff ff       	call   f01000cb <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101872:	39 fe                	cmp    %edi,%esi
f0101874:	75 19                	jne    f010188f <mem_init+0x3ab>
f0101876:	68 dc 54 10 f0       	push   $0xf01054dc
f010187b:	68 ef 53 10 f0       	push   $0xf01053ef
f0101880:	68 d1 02 00 00       	push   $0x2d1
f0101885:	68 c9 53 10 f0       	push   $0xf01053c9
f010188a:	e8 3c e8 ff ff       	call   f01000cb <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010188f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101892:	39 c7                	cmp    %eax,%edi
f0101894:	74 04                	je     f010189a <mem_init+0x3b6>
f0101896:	39 c6                	cmp    %eax,%esi
f0101898:	75 19                	jne    f01018b3 <mem_init+0x3cf>
f010189a:	68 ec 4d 10 f0       	push   $0xf0104dec
f010189f:	68 ef 53 10 f0       	push   $0xf01053ef
f01018a4:	68 d2 02 00 00       	push   $0x2d2
f01018a9:	68 c9 53 10 f0       	push   $0xf01053c9
f01018ae:	e8 18 e8 ff ff       	call   f01000cb <_panic>
	assert(!page_alloc(0));
f01018b3:	83 ec 0c             	sub    $0xc,%esp
f01018b6:	6a 00                	push   $0x0
f01018b8:	e8 96 f8 ff ff       	call   f0101153 <page_alloc>
f01018bd:	83 c4 10             	add    $0x10,%esp
f01018c0:	85 c0                	test   %eax,%eax
f01018c2:	74 19                	je     f01018dd <mem_init+0x3f9>
f01018c4:	68 45 55 10 f0       	push   $0xf0105545
f01018c9:	68 ef 53 10 f0       	push   $0xf01053ef
f01018ce:	68 d3 02 00 00       	push   $0x2d3
f01018d3:	68 c9 53 10 f0       	push   $0xf01053c9
f01018d8:	e8 ee e7 ff ff       	call   f01000cb <_panic>
f01018dd:	89 f0                	mov    %esi,%eax
f01018df:	2b 05 6c 01 19 f0    	sub    0xf019016c,%eax
f01018e5:	c1 f8 03             	sar    $0x3,%eax
f01018e8:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01018eb:	89 c2                	mov    %eax,%edx
f01018ed:	c1 ea 0c             	shr    $0xc,%edx
f01018f0:	3b 15 64 01 19 f0    	cmp    0xf0190164,%edx
f01018f6:	72 12                	jb     f010190a <mem_init+0x426>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01018f8:	50                   	push   %eax
f01018f9:	68 70 4b 10 f0       	push   $0xf0104b70
f01018fe:	6a 56                	push   $0x56
f0101900:	68 d5 53 10 f0       	push   $0xf01053d5
f0101905:	e8 c1 e7 ff ff       	call   f01000cb <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f010190a:	83 ec 04             	sub    $0x4,%esp
f010190d:	68 00 10 00 00       	push   $0x1000
f0101912:	6a 01                	push   $0x1
f0101914:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101919:	50                   	push   %eax
f010191a:	e8 65 28 00 00       	call   f0104184 <memset>
	page_free(pp0);
f010191f:	89 34 24             	mov    %esi,(%esp)
f0101922:	e8 96 f8 ff ff       	call   f01011bd <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101927:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f010192e:	e8 20 f8 ff ff       	call   f0101153 <page_alloc>
f0101933:	83 c4 10             	add    $0x10,%esp
f0101936:	85 c0                	test   %eax,%eax
f0101938:	75 19                	jne    f0101953 <mem_init+0x46f>
f010193a:	68 54 55 10 f0       	push   $0xf0105554
f010193f:	68 ef 53 10 f0       	push   $0xf01053ef
f0101944:	68 d8 02 00 00       	push   $0x2d8
f0101949:	68 c9 53 10 f0       	push   $0xf01053c9
f010194e:	e8 78 e7 ff ff       	call   f01000cb <_panic>
	assert(pp && pp0 == pp);
f0101953:	39 c6                	cmp    %eax,%esi
f0101955:	74 19                	je     f0101970 <mem_init+0x48c>
f0101957:	68 72 55 10 f0       	push   $0xf0105572
f010195c:	68 ef 53 10 f0       	push   $0xf01053ef
f0101961:	68 d9 02 00 00       	push   $0x2d9
f0101966:	68 c9 53 10 f0       	push   $0xf01053c9
f010196b:	e8 5b e7 ff ff       	call   f01000cb <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0101970:	89 f2                	mov    %esi,%edx
f0101972:	2b 15 6c 01 19 f0    	sub    0xf019016c,%edx
f0101978:	c1 fa 03             	sar    $0x3,%edx
f010197b:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010197e:	89 d0                	mov    %edx,%eax
f0101980:	c1 e8 0c             	shr    $0xc,%eax
f0101983:	3b 05 64 01 19 f0    	cmp    0xf0190164,%eax
f0101989:	72 12                	jb     f010199d <mem_init+0x4b9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010198b:	52                   	push   %edx
f010198c:	68 70 4b 10 f0       	push   $0xf0104b70
f0101991:	6a 56                	push   $0x56
f0101993:	68 d5 53 10 f0       	push   $0xf01053d5
f0101998:	e8 2e e7 ff ff       	call   f01000cb <_panic>
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f010199d:	80 ba 00 00 00 f0 00 	cmpb   $0x0,-0x10000000(%edx)
f01019a4:	75 11                	jne    f01019b7 <mem_init+0x4d3>
f01019a6:	8d 82 01 00 00 f0    	lea    -0xfffffff(%edx),%eax
f01019ac:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
f01019b2:	80 38 00             	cmpb   $0x0,(%eax)
f01019b5:	74 19                	je     f01019d0 <mem_init+0x4ec>
f01019b7:	68 82 55 10 f0       	push   $0xf0105582
f01019bc:	68 ef 53 10 f0       	push   $0xf01053ef
f01019c1:	68 dc 02 00 00       	push   $0x2dc
f01019c6:	68 c9 53 10 f0       	push   $0xf01053c9
f01019cb:	e8 fb e6 ff ff       	call   f01000cb <_panic>
f01019d0:	83 c0 01             	add    $0x1,%eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f01019d3:	39 d0                	cmp    %edx,%eax
f01019d5:	75 db                	jne    f01019b2 <mem_init+0x4ce>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f01019d7:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01019da:	a3 9c f4 18 f0       	mov    %eax,0xf018f49c

	// free the pages we took
	page_free(pp0);
f01019df:	83 ec 0c             	sub    $0xc,%esp
f01019e2:	56                   	push   %esi
f01019e3:	e8 d5 f7 ff ff       	call   f01011bd <page_free>
	page_free(pp1);
f01019e8:	89 3c 24             	mov    %edi,(%esp)
f01019eb:	e8 cd f7 ff ff       	call   f01011bd <page_free>
	page_free(pp2);
f01019f0:	83 c4 04             	add    $0x4,%esp
f01019f3:	ff 75 d4             	pushl  -0x2c(%ebp)
f01019f6:	e8 c2 f7 ff ff       	call   f01011bd <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01019fb:	a1 9c f4 18 f0       	mov    0xf018f49c,%eax
f0101a00:	83 c4 10             	add    $0x10,%esp
f0101a03:	85 c0                	test   %eax,%eax
f0101a05:	74 09                	je     f0101a10 <mem_init+0x52c>
		--nfree;
f0101a07:	83 eb 01             	sub    $0x1,%ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101a0a:	8b 00                	mov    (%eax),%eax
f0101a0c:	85 c0                	test   %eax,%eax
f0101a0e:	75 f7                	jne    f0101a07 <mem_init+0x523>
		--nfree;
	assert(nfree == 0);
f0101a10:	85 db                	test   %ebx,%ebx
f0101a12:	74 19                	je     f0101a2d <mem_init+0x549>
f0101a14:	68 8c 55 10 f0       	push   $0xf010558c
f0101a19:	68 ef 53 10 f0       	push   $0xf01053ef
f0101a1e:	68 e9 02 00 00       	push   $0x2e9
f0101a23:	68 c9 53 10 f0       	push   $0xf01053c9
f0101a28:	e8 9e e6 ff ff       	call   f01000cb <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f0101a2d:	83 ec 0c             	sub    $0xc,%esp
f0101a30:	68 0c 4e 10 f0       	push   $0xf0104e0c
f0101a35:	e8 f0 15 00 00       	call   f010302a <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101a3a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101a41:	e8 0d f7 ff ff       	call   f0101153 <page_alloc>
f0101a46:	89 c3                	mov    %eax,%ebx
f0101a48:	83 c4 10             	add    $0x10,%esp
f0101a4b:	85 c0                	test   %eax,%eax
f0101a4d:	75 19                	jne    f0101a68 <mem_init+0x584>
f0101a4f:	68 9a 54 10 f0       	push   $0xf010549a
f0101a54:	68 ef 53 10 f0       	push   $0xf01053ef
f0101a59:	68 59 03 00 00       	push   $0x359
f0101a5e:	68 c9 53 10 f0       	push   $0xf01053c9
f0101a63:	e8 63 e6 ff ff       	call   f01000cb <_panic>
	assert((pp1 = page_alloc(0)));
f0101a68:	83 ec 0c             	sub    $0xc,%esp
f0101a6b:	6a 00                	push   $0x0
f0101a6d:	e8 e1 f6 ff ff       	call   f0101153 <page_alloc>
f0101a72:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101a75:	83 c4 10             	add    $0x10,%esp
f0101a78:	85 c0                	test   %eax,%eax
f0101a7a:	75 19                	jne    f0101a95 <mem_init+0x5b1>
f0101a7c:	68 b0 54 10 f0       	push   $0xf01054b0
f0101a81:	68 ef 53 10 f0       	push   $0xf01053ef
f0101a86:	68 5a 03 00 00       	push   $0x35a
f0101a8b:	68 c9 53 10 f0       	push   $0xf01053c9
f0101a90:	e8 36 e6 ff ff       	call   f01000cb <_panic>
	assert((pp2 = page_alloc(0)));
f0101a95:	83 ec 0c             	sub    $0xc,%esp
f0101a98:	6a 00                	push   $0x0
f0101a9a:	e8 b4 f6 ff ff       	call   f0101153 <page_alloc>
f0101a9f:	89 c6                	mov    %eax,%esi
f0101aa1:	83 c4 10             	add    $0x10,%esp
f0101aa4:	85 c0                	test   %eax,%eax
f0101aa6:	75 19                	jne    f0101ac1 <mem_init+0x5dd>
f0101aa8:	68 c6 54 10 f0       	push   $0xf01054c6
f0101aad:	68 ef 53 10 f0       	push   $0xf01053ef
f0101ab2:	68 5b 03 00 00       	push   $0x35b
f0101ab7:	68 c9 53 10 f0       	push   $0xf01053c9
f0101abc:	e8 0a e6 ff ff       	call   f01000cb <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101ac1:	3b 5d d4             	cmp    -0x2c(%ebp),%ebx
f0101ac4:	75 19                	jne    f0101adf <mem_init+0x5fb>
f0101ac6:	68 dc 54 10 f0       	push   $0xf01054dc
f0101acb:	68 ef 53 10 f0       	push   $0xf01053ef
f0101ad0:	68 5e 03 00 00       	push   $0x35e
f0101ad5:	68 c9 53 10 f0       	push   $0xf01053c9
f0101ada:	e8 ec e5 ff ff       	call   f01000cb <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101adf:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f0101ae2:	74 04                	je     f0101ae8 <mem_init+0x604>
f0101ae4:	39 c3                	cmp    %eax,%ebx
f0101ae6:	75 19                	jne    f0101b01 <mem_init+0x61d>
f0101ae8:	68 ec 4d 10 f0       	push   $0xf0104dec
f0101aed:	68 ef 53 10 f0       	push   $0xf01053ef
f0101af2:	68 5f 03 00 00       	push   $0x35f
f0101af7:	68 c9 53 10 f0       	push   $0xf01053c9
f0101afc:	e8 ca e5 ff ff       	call   f01000cb <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101b01:	a1 9c f4 18 f0       	mov    0xf018f49c,%eax
f0101b06:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101b09:	c7 05 9c f4 18 f0 00 	movl   $0x0,0xf018f49c
f0101b10:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101b13:	83 ec 0c             	sub    $0xc,%esp
f0101b16:	6a 00                	push   $0x0
f0101b18:	e8 36 f6 ff ff       	call   f0101153 <page_alloc>
f0101b1d:	83 c4 10             	add    $0x10,%esp
f0101b20:	85 c0                	test   %eax,%eax
f0101b22:	74 19                	je     f0101b3d <mem_init+0x659>
f0101b24:	68 45 55 10 f0       	push   $0xf0105545
f0101b29:	68 ef 53 10 f0       	push   $0xf01053ef
f0101b2e:	68 66 03 00 00       	push   $0x366
f0101b33:	68 c9 53 10 f0       	push   $0xf01053c9
f0101b38:	e8 8e e5 ff ff       	call   f01000cb <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101b3d:	83 ec 04             	sub    $0x4,%esp
f0101b40:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101b43:	50                   	push   %eax
f0101b44:	6a 00                	push   $0x0
f0101b46:	ff 35 68 01 19 f0    	pushl  0xf0190168
f0101b4c:	e8 c8 f7 ff ff       	call   f0101319 <page_lookup>
f0101b51:	83 c4 10             	add    $0x10,%esp
f0101b54:	85 c0                	test   %eax,%eax
f0101b56:	74 19                	je     f0101b71 <mem_init+0x68d>
f0101b58:	68 2c 4e 10 f0       	push   $0xf0104e2c
f0101b5d:	68 ef 53 10 f0       	push   $0xf01053ef
f0101b62:	68 69 03 00 00       	push   $0x369
f0101b67:	68 c9 53 10 f0       	push   $0xf01053c9
f0101b6c:	e8 5a e5 ff ff       	call   f01000cb <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101b71:	6a 02                	push   $0x2
f0101b73:	6a 00                	push   $0x0
f0101b75:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101b78:	ff 35 68 01 19 f0    	pushl  0xf0190168
f0101b7e:	e8 28 f8 ff ff       	call   f01013ab <page_insert>
f0101b83:	83 c4 10             	add    $0x10,%esp
f0101b86:	85 c0                	test   %eax,%eax
f0101b88:	78 19                	js     f0101ba3 <mem_init+0x6bf>
f0101b8a:	68 64 4e 10 f0       	push   $0xf0104e64
f0101b8f:	68 ef 53 10 f0       	push   $0xf01053ef
f0101b94:	68 6c 03 00 00       	push   $0x36c
f0101b99:	68 c9 53 10 f0       	push   $0xf01053c9
f0101b9e:	e8 28 e5 ff ff       	call   f01000cb <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101ba3:	83 ec 0c             	sub    $0xc,%esp
f0101ba6:	53                   	push   %ebx
f0101ba7:	e8 11 f6 ff ff       	call   f01011bd <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101bac:	6a 02                	push   $0x2
f0101bae:	6a 00                	push   $0x0
f0101bb0:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101bb3:	ff 35 68 01 19 f0    	pushl  0xf0190168
f0101bb9:	e8 ed f7 ff ff       	call   f01013ab <page_insert>
f0101bbe:	83 c4 20             	add    $0x20,%esp
f0101bc1:	85 c0                	test   %eax,%eax
f0101bc3:	74 19                	je     f0101bde <mem_init+0x6fa>
f0101bc5:	68 94 4e 10 f0       	push   $0xf0104e94
f0101bca:	68 ef 53 10 f0       	push   $0xf01053ef
f0101bcf:	68 70 03 00 00       	push   $0x370
f0101bd4:	68 c9 53 10 f0       	push   $0xf01053c9
f0101bd9:	e8 ed e4 ff ff       	call   f01000cb <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101bde:	8b 3d 68 01 19 f0    	mov    0xf0190168,%edi
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0101be4:	a1 6c 01 19 f0       	mov    0xf019016c,%eax
f0101be9:	89 c1                	mov    %eax,%ecx
f0101beb:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101bee:	8b 17                	mov    (%edi),%edx
f0101bf0:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101bf6:	89 d8                	mov    %ebx,%eax
f0101bf8:	29 c8                	sub    %ecx,%eax
f0101bfa:	c1 f8 03             	sar    $0x3,%eax
f0101bfd:	c1 e0 0c             	shl    $0xc,%eax
f0101c00:	39 c2                	cmp    %eax,%edx
f0101c02:	74 19                	je     f0101c1d <mem_init+0x739>
f0101c04:	68 c4 4e 10 f0       	push   $0xf0104ec4
f0101c09:	68 ef 53 10 f0       	push   $0xf01053ef
f0101c0e:	68 71 03 00 00       	push   $0x371
f0101c13:	68 c9 53 10 f0       	push   $0xf01053c9
f0101c18:	e8 ae e4 ff ff       	call   f01000cb <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101c1d:	ba 00 00 00 00       	mov    $0x0,%edx
f0101c22:	89 f8                	mov    %edi,%eax
f0101c24:	e8 18 f1 ff ff       	call   f0100d41 <check_va2pa>
f0101c29:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0101c2c:	2b 55 cc             	sub    -0x34(%ebp),%edx
f0101c2f:	c1 fa 03             	sar    $0x3,%edx
f0101c32:	c1 e2 0c             	shl    $0xc,%edx
f0101c35:	39 d0                	cmp    %edx,%eax
f0101c37:	74 19                	je     f0101c52 <mem_init+0x76e>
f0101c39:	68 ec 4e 10 f0       	push   $0xf0104eec
f0101c3e:	68 ef 53 10 f0       	push   $0xf01053ef
f0101c43:	68 72 03 00 00       	push   $0x372
f0101c48:	68 c9 53 10 f0       	push   $0xf01053c9
f0101c4d:	e8 79 e4 ff ff       	call   f01000cb <_panic>
	assert(pp1->pp_ref == 1);
f0101c52:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101c55:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101c5a:	74 19                	je     f0101c75 <mem_init+0x791>
f0101c5c:	68 97 55 10 f0       	push   $0xf0105597
f0101c61:	68 ef 53 10 f0       	push   $0xf01053ef
f0101c66:	68 73 03 00 00       	push   $0x373
f0101c6b:	68 c9 53 10 f0       	push   $0xf01053c9
f0101c70:	e8 56 e4 ff ff       	call   f01000cb <_panic>
	assert(pp0->pp_ref == 1);
f0101c75:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101c7a:	74 19                	je     f0101c95 <mem_init+0x7b1>
f0101c7c:	68 a8 55 10 f0       	push   $0xf01055a8
f0101c81:	68 ef 53 10 f0       	push   $0xf01053ef
f0101c86:	68 74 03 00 00       	push   $0x374
f0101c8b:	68 c9 53 10 f0       	push   $0xf01053c9
f0101c90:	e8 36 e4 ff ff       	call   f01000cb <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101c95:	6a 02                	push   $0x2
f0101c97:	68 00 10 00 00       	push   $0x1000
f0101c9c:	56                   	push   %esi
f0101c9d:	57                   	push   %edi
f0101c9e:	e8 08 f7 ff ff       	call   f01013ab <page_insert>
f0101ca3:	83 c4 10             	add    $0x10,%esp
f0101ca6:	85 c0                	test   %eax,%eax
f0101ca8:	74 19                	je     f0101cc3 <mem_init+0x7df>
f0101caa:	68 1c 4f 10 f0       	push   $0xf0104f1c
f0101caf:	68 ef 53 10 f0       	push   $0xf01053ef
f0101cb4:	68 77 03 00 00       	push   $0x377
f0101cb9:	68 c9 53 10 f0       	push   $0xf01053c9
f0101cbe:	e8 08 e4 ff ff       	call   f01000cb <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101cc3:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101cc8:	a1 68 01 19 f0       	mov    0xf0190168,%eax
f0101ccd:	e8 6f f0 ff ff       	call   f0100d41 <check_va2pa>
f0101cd2:	89 f2                	mov    %esi,%edx
f0101cd4:	2b 15 6c 01 19 f0    	sub    0xf019016c,%edx
f0101cda:	c1 fa 03             	sar    $0x3,%edx
f0101cdd:	c1 e2 0c             	shl    $0xc,%edx
f0101ce0:	39 d0                	cmp    %edx,%eax
f0101ce2:	74 19                	je     f0101cfd <mem_init+0x819>
f0101ce4:	68 58 4f 10 f0       	push   $0xf0104f58
f0101ce9:	68 ef 53 10 f0       	push   $0xf01053ef
f0101cee:	68 78 03 00 00       	push   $0x378
f0101cf3:	68 c9 53 10 f0       	push   $0xf01053c9
f0101cf8:	e8 ce e3 ff ff       	call   f01000cb <_panic>
	assert(pp2->pp_ref == 1);
f0101cfd:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101d02:	74 19                	je     f0101d1d <mem_init+0x839>
f0101d04:	68 b9 55 10 f0       	push   $0xf01055b9
f0101d09:	68 ef 53 10 f0       	push   $0xf01053ef
f0101d0e:	68 79 03 00 00       	push   $0x379
f0101d13:	68 c9 53 10 f0       	push   $0xf01053c9
f0101d18:	e8 ae e3 ff ff       	call   f01000cb <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101d1d:	83 ec 0c             	sub    $0xc,%esp
f0101d20:	6a 00                	push   $0x0
f0101d22:	e8 2c f4 ff ff       	call   f0101153 <page_alloc>
f0101d27:	83 c4 10             	add    $0x10,%esp
f0101d2a:	85 c0                	test   %eax,%eax
f0101d2c:	74 19                	je     f0101d47 <mem_init+0x863>
f0101d2e:	68 45 55 10 f0       	push   $0xf0105545
f0101d33:	68 ef 53 10 f0       	push   $0xf01053ef
f0101d38:	68 7c 03 00 00       	push   $0x37c
f0101d3d:	68 c9 53 10 f0       	push   $0xf01053c9
f0101d42:	e8 84 e3 ff ff       	call   f01000cb <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101d47:	6a 02                	push   $0x2
f0101d49:	68 00 10 00 00       	push   $0x1000
f0101d4e:	56                   	push   %esi
f0101d4f:	ff 35 68 01 19 f0    	pushl  0xf0190168
f0101d55:	e8 51 f6 ff ff       	call   f01013ab <page_insert>
f0101d5a:	83 c4 10             	add    $0x10,%esp
f0101d5d:	85 c0                	test   %eax,%eax
f0101d5f:	74 19                	je     f0101d7a <mem_init+0x896>
f0101d61:	68 1c 4f 10 f0       	push   $0xf0104f1c
f0101d66:	68 ef 53 10 f0       	push   $0xf01053ef
f0101d6b:	68 7f 03 00 00       	push   $0x37f
f0101d70:	68 c9 53 10 f0       	push   $0xf01053c9
f0101d75:	e8 51 e3 ff ff       	call   f01000cb <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101d7a:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101d7f:	a1 68 01 19 f0       	mov    0xf0190168,%eax
f0101d84:	e8 b8 ef ff ff       	call   f0100d41 <check_va2pa>
f0101d89:	89 f2                	mov    %esi,%edx
f0101d8b:	2b 15 6c 01 19 f0    	sub    0xf019016c,%edx
f0101d91:	c1 fa 03             	sar    $0x3,%edx
f0101d94:	c1 e2 0c             	shl    $0xc,%edx
f0101d97:	39 d0                	cmp    %edx,%eax
f0101d99:	74 19                	je     f0101db4 <mem_init+0x8d0>
f0101d9b:	68 58 4f 10 f0       	push   $0xf0104f58
f0101da0:	68 ef 53 10 f0       	push   $0xf01053ef
f0101da5:	68 80 03 00 00       	push   $0x380
f0101daa:	68 c9 53 10 f0       	push   $0xf01053c9
f0101daf:	e8 17 e3 ff ff       	call   f01000cb <_panic>
	assert(pp2->pp_ref == 1);
f0101db4:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101db9:	74 19                	je     f0101dd4 <mem_init+0x8f0>
f0101dbb:	68 b9 55 10 f0       	push   $0xf01055b9
f0101dc0:	68 ef 53 10 f0       	push   $0xf01053ef
f0101dc5:	68 81 03 00 00       	push   $0x381
f0101dca:	68 c9 53 10 f0       	push   $0xf01053c9
f0101dcf:	e8 f7 e2 ff ff       	call   f01000cb <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101dd4:	83 ec 0c             	sub    $0xc,%esp
f0101dd7:	6a 00                	push   $0x0
f0101dd9:	e8 75 f3 ff ff       	call   f0101153 <page_alloc>
f0101dde:	83 c4 10             	add    $0x10,%esp
f0101de1:	85 c0                	test   %eax,%eax
f0101de3:	74 19                	je     f0101dfe <mem_init+0x91a>
f0101de5:	68 45 55 10 f0       	push   $0xf0105545
f0101dea:	68 ef 53 10 f0       	push   $0xf01053ef
f0101def:	68 85 03 00 00       	push   $0x385
f0101df4:	68 c9 53 10 f0       	push   $0xf01053c9
f0101df9:	e8 cd e2 ff ff       	call   f01000cb <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101dfe:	8b 15 68 01 19 f0    	mov    0xf0190168,%edx
f0101e04:	8b 02                	mov    (%edx),%eax
f0101e06:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101e0b:	89 c1                	mov    %eax,%ecx
f0101e0d:	c1 e9 0c             	shr    $0xc,%ecx
f0101e10:	3b 0d 64 01 19 f0    	cmp    0xf0190164,%ecx
f0101e16:	72 15                	jb     f0101e2d <mem_init+0x949>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101e18:	50                   	push   %eax
f0101e19:	68 70 4b 10 f0       	push   $0xf0104b70
f0101e1e:	68 88 03 00 00       	push   $0x388
f0101e23:	68 c9 53 10 f0       	push   $0xf01053c9
f0101e28:	e8 9e e2 ff ff       	call   f01000cb <_panic>
f0101e2d:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101e32:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101e35:	83 ec 04             	sub    $0x4,%esp
f0101e38:	6a 00                	push   $0x0
f0101e3a:	68 00 10 00 00       	push   $0x1000
f0101e3f:	52                   	push   %edx
f0101e40:	e8 bf f3 ff ff       	call   f0101204 <pgdir_walk>
f0101e45:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0101e48:	8d 57 04             	lea    0x4(%edi),%edx
f0101e4b:	83 c4 10             	add    $0x10,%esp
f0101e4e:	39 d0                	cmp    %edx,%eax
f0101e50:	74 19                	je     f0101e6b <mem_init+0x987>
f0101e52:	68 88 4f 10 f0       	push   $0xf0104f88
f0101e57:	68 ef 53 10 f0       	push   $0xf01053ef
f0101e5c:	68 89 03 00 00       	push   $0x389
f0101e61:	68 c9 53 10 f0       	push   $0xf01053c9
f0101e66:	e8 60 e2 ff ff       	call   f01000cb <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101e6b:	6a 06                	push   $0x6
f0101e6d:	68 00 10 00 00       	push   $0x1000
f0101e72:	56                   	push   %esi
f0101e73:	ff 35 68 01 19 f0    	pushl  0xf0190168
f0101e79:	e8 2d f5 ff ff       	call   f01013ab <page_insert>
f0101e7e:	83 c4 10             	add    $0x10,%esp
f0101e81:	85 c0                	test   %eax,%eax
f0101e83:	74 19                	je     f0101e9e <mem_init+0x9ba>
f0101e85:	68 c8 4f 10 f0       	push   $0xf0104fc8
f0101e8a:	68 ef 53 10 f0       	push   $0xf01053ef
f0101e8f:	68 8c 03 00 00       	push   $0x38c
f0101e94:	68 c9 53 10 f0       	push   $0xf01053c9
f0101e99:	e8 2d e2 ff ff       	call   f01000cb <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101e9e:	8b 3d 68 01 19 f0    	mov    0xf0190168,%edi
f0101ea4:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101ea9:	89 f8                	mov    %edi,%eax
f0101eab:	e8 91 ee ff ff       	call   f0100d41 <check_va2pa>
f0101eb0:	89 f2                	mov    %esi,%edx
f0101eb2:	2b 15 6c 01 19 f0    	sub    0xf019016c,%edx
f0101eb8:	c1 fa 03             	sar    $0x3,%edx
f0101ebb:	c1 e2 0c             	shl    $0xc,%edx
f0101ebe:	39 d0                	cmp    %edx,%eax
f0101ec0:	74 19                	je     f0101edb <mem_init+0x9f7>
f0101ec2:	68 58 4f 10 f0       	push   $0xf0104f58
f0101ec7:	68 ef 53 10 f0       	push   $0xf01053ef
f0101ecc:	68 8d 03 00 00       	push   $0x38d
f0101ed1:	68 c9 53 10 f0       	push   $0xf01053c9
f0101ed6:	e8 f0 e1 ff ff       	call   f01000cb <_panic>
	assert(pp2->pp_ref == 1);
f0101edb:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101ee0:	74 19                	je     f0101efb <mem_init+0xa17>
f0101ee2:	68 b9 55 10 f0       	push   $0xf01055b9
f0101ee7:	68 ef 53 10 f0       	push   $0xf01053ef
f0101eec:	68 8e 03 00 00       	push   $0x38e
f0101ef1:	68 c9 53 10 f0       	push   $0xf01053c9
f0101ef6:	e8 d0 e1 ff ff       	call   f01000cb <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101efb:	83 ec 04             	sub    $0x4,%esp
f0101efe:	6a 00                	push   $0x0
f0101f00:	68 00 10 00 00       	push   $0x1000
f0101f05:	57                   	push   %edi
f0101f06:	e8 f9 f2 ff ff       	call   f0101204 <pgdir_walk>
f0101f0b:	83 c4 10             	add    $0x10,%esp
f0101f0e:	f6 00 04             	testb  $0x4,(%eax)
f0101f11:	75 19                	jne    f0101f2c <mem_init+0xa48>
f0101f13:	68 08 50 10 f0       	push   $0xf0105008
f0101f18:	68 ef 53 10 f0       	push   $0xf01053ef
f0101f1d:	68 8f 03 00 00       	push   $0x38f
f0101f22:	68 c9 53 10 f0       	push   $0xf01053c9
f0101f27:	e8 9f e1 ff ff       	call   f01000cb <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0101f2c:	a1 68 01 19 f0       	mov    0xf0190168,%eax
f0101f31:	f6 00 04             	testb  $0x4,(%eax)
f0101f34:	75 19                	jne    f0101f4f <mem_init+0xa6b>
f0101f36:	68 ca 55 10 f0       	push   $0xf01055ca
f0101f3b:	68 ef 53 10 f0       	push   $0xf01053ef
f0101f40:	68 90 03 00 00       	push   $0x390
f0101f45:	68 c9 53 10 f0       	push   $0xf01053c9
f0101f4a:	e8 7c e1 ff ff       	call   f01000cb <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101f4f:	6a 02                	push   $0x2
f0101f51:	68 00 00 40 00       	push   $0x400000
f0101f56:	53                   	push   %ebx
f0101f57:	50                   	push   %eax
f0101f58:	e8 4e f4 ff ff       	call   f01013ab <page_insert>
f0101f5d:	83 c4 10             	add    $0x10,%esp
f0101f60:	85 c0                	test   %eax,%eax
f0101f62:	78 19                	js     f0101f7d <mem_init+0xa99>
f0101f64:	68 3c 50 10 f0       	push   $0xf010503c
f0101f69:	68 ef 53 10 f0       	push   $0xf01053ef
f0101f6e:	68 93 03 00 00       	push   $0x393
f0101f73:	68 c9 53 10 f0       	push   $0xf01053c9
f0101f78:	e8 4e e1 ff ff       	call   f01000cb <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101f7d:	6a 02                	push   $0x2
f0101f7f:	68 00 10 00 00       	push   $0x1000
f0101f84:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101f87:	ff 35 68 01 19 f0    	pushl  0xf0190168
f0101f8d:	e8 19 f4 ff ff       	call   f01013ab <page_insert>
f0101f92:	83 c4 10             	add    $0x10,%esp
f0101f95:	85 c0                	test   %eax,%eax
f0101f97:	74 19                	je     f0101fb2 <mem_init+0xace>
f0101f99:	68 74 50 10 f0       	push   $0xf0105074
f0101f9e:	68 ef 53 10 f0       	push   $0xf01053ef
f0101fa3:	68 96 03 00 00       	push   $0x396
f0101fa8:	68 c9 53 10 f0       	push   $0xf01053c9
f0101fad:	e8 19 e1 ff ff       	call   f01000cb <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101fb2:	83 ec 04             	sub    $0x4,%esp
f0101fb5:	6a 00                	push   $0x0
f0101fb7:	68 00 10 00 00       	push   $0x1000
f0101fbc:	ff 35 68 01 19 f0    	pushl  0xf0190168
f0101fc2:	e8 3d f2 ff ff       	call   f0101204 <pgdir_walk>
f0101fc7:	83 c4 10             	add    $0x10,%esp
f0101fca:	f6 00 04             	testb  $0x4,(%eax)
f0101fcd:	74 19                	je     f0101fe8 <mem_init+0xb04>
f0101fcf:	68 b0 50 10 f0       	push   $0xf01050b0
f0101fd4:	68 ef 53 10 f0       	push   $0xf01053ef
f0101fd9:	68 97 03 00 00       	push   $0x397
f0101fde:	68 c9 53 10 f0       	push   $0xf01053c9
f0101fe3:	e8 e3 e0 ff ff       	call   f01000cb <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101fe8:	8b 3d 68 01 19 f0    	mov    0xf0190168,%edi
f0101fee:	ba 00 00 00 00       	mov    $0x0,%edx
f0101ff3:	89 f8                	mov    %edi,%eax
f0101ff5:	e8 47 ed ff ff       	call   f0100d41 <check_va2pa>
f0101ffa:	89 c1                	mov    %eax,%ecx
f0101ffc:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101fff:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102002:	2b 05 6c 01 19 f0    	sub    0xf019016c,%eax
f0102008:	c1 f8 03             	sar    $0x3,%eax
f010200b:	c1 e0 0c             	shl    $0xc,%eax
f010200e:	39 c1                	cmp    %eax,%ecx
f0102010:	74 19                	je     f010202b <mem_init+0xb47>
f0102012:	68 e8 50 10 f0       	push   $0xf01050e8
f0102017:	68 ef 53 10 f0       	push   $0xf01053ef
f010201c:	68 9a 03 00 00       	push   $0x39a
f0102021:	68 c9 53 10 f0       	push   $0xf01053c9
f0102026:	e8 a0 e0 ff ff       	call   f01000cb <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f010202b:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102030:	89 f8                	mov    %edi,%eax
f0102032:	e8 0a ed ff ff       	call   f0100d41 <check_va2pa>
f0102037:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f010203a:	74 19                	je     f0102055 <mem_init+0xb71>
f010203c:	68 14 51 10 f0       	push   $0xf0105114
f0102041:	68 ef 53 10 f0       	push   $0xf01053ef
f0102046:	68 9b 03 00 00       	push   $0x39b
f010204b:	68 c9 53 10 f0       	push   $0xf01053c9
f0102050:	e8 76 e0 ff ff       	call   f01000cb <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0102055:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102058:	66 83 78 04 02       	cmpw   $0x2,0x4(%eax)
f010205d:	74 19                	je     f0102078 <mem_init+0xb94>
f010205f:	68 e0 55 10 f0       	push   $0xf01055e0
f0102064:	68 ef 53 10 f0       	push   $0xf01053ef
f0102069:	68 9d 03 00 00       	push   $0x39d
f010206e:	68 c9 53 10 f0       	push   $0xf01053c9
f0102073:	e8 53 e0 ff ff       	call   f01000cb <_panic>
	assert(pp2->pp_ref == 0);
f0102078:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f010207d:	74 19                	je     f0102098 <mem_init+0xbb4>
f010207f:	68 f1 55 10 f0       	push   $0xf01055f1
f0102084:	68 ef 53 10 f0       	push   $0xf01053ef
f0102089:	68 9e 03 00 00       	push   $0x39e
f010208e:	68 c9 53 10 f0       	push   $0xf01053c9
f0102093:	e8 33 e0 ff ff       	call   f01000cb <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0102098:	83 ec 0c             	sub    $0xc,%esp
f010209b:	6a 00                	push   $0x0
f010209d:	e8 b1 f0 ff ff       	call   f0101153 <page_alloc>
f01020a2:	83 c4 10             	add    $0x10,%esp
f01020a5:	85 c0                	test   %eax,%eax
f01020a7:	74 04                	je     f01020ad <mem_init+0xbc9>
f01020a9:	39 c6                	cmp    %eax,%esi
f01020ab:	74 19                	je     f01020c6 <mem_init+0xbe2>
f01020ad:	68 44 51 10 f0       	push   $0xf0105144
f01020b2:	68 ef 53 10 f0       	push   $0xf01053ef
f01020b7:	68 a1 03 00 00       	push   $0x3a1
f01020bc:	68 c9 53 10 f0       	push   $0xf01053c9
f01020c1:	e8 05 e0 ff ff       	call   f01000cb <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f01020c6:	83 ec 08             	sub    $0x8,%esp
f01020c9:	6a 00                	push   $0x0
f01020cb:	ff 35 68 01 19 f0    	pushl  0xf0190168
f01020d1:	e8 9d f2 ff ff       	call   f0101373 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01020d6:	8b 3d 68 01 19 f0    	mov    0xf0190168,%edi
f01020dc:	ba 00 00 00 00       	mov    $0x0,%edx
f01020e1:	89 f8                	mov    %edi,%eax
f01020e3:	e8 59 ec ff ff       	call   f0100d41 <check_va2pa>
f01020e8:	83 c4 10             	add    $0x10,%esp
f01020eb:	83 f8 ff             	cmp    $0xffffffff,%eax
f01020ee:	74 19                	je     f0102109 <mem_init+0xc25>
f01020f0:	68 68 51 10 f0       	push   $0xf0105168
f01020f5:	68 ef 53 10 f0       	push   $0xf01053ef
f01020fa:	68 a5 03 00 00       	push   $0x3a5
f01020ff:	68 c9 53 10 f0       	push   $0xf01053c9
f0102104:	e8 c2 df ff ff       	call   f01000cb <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102109:	ba 00 10 00 00       	mov    $0x1000,%edx
f010210e:	89 f8                	mov    %edi,%eax
f0102110:	e8 2c ec ff ff       	call   f0100d41 <check_va2pa>
f0102115:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0102118:	2b 15 6c 01 19 f0    	sub    0xf019016c,%edx
f010211e:	c1 fa 03             	sar    $0x3,%edx
f0102121:	c1 e2 0c             	shl    $0xc,%edx
f0102124:	39 d0                	cmp    %edx,%eax
f0102126:	74 19                	je     f0102141 <mem_init+0xc5d>
f0102128:	68 14 51 10 f0       	push   $0xf0105114
f010212d:	68 ef 53 10 f0       	push   $0xf01053ef
f0102132:	68 a6 03 00 00       	push   $0x3a6
f0102137:	68 c9 53 10 f0       	push   $0xf01053c9
f010213c:	e8 8a df ff ff       	call   f01000cb <_panic>
	assert(pp1->pp_ref == 1);
f0102141:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102144:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0102149:	74 19                	je     f0102164 <mem_init+0xc80>
f010214b:	68 97 55 10 f0       	push   $0xf0105597
f0102150:	68 ef 53 10 f0       	push   $0xf01053ef
f0102155:	68 a7 03 00 00       	push   $0x3a7
f010215a:	68 c9 53 10 f0       	push   $0xf01053c9
f010215f:	e8 67 df ff ff       	call   f01000cb <_panic>
	assert(pp2->pp_ref == 0);
f0102164:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102169:	74 19                	je     f0102184 <mem_init+0xca0>
f010216b:	68 f1 55 10 f0       	push   $0xf01055f1
f0102170:	68 ef 53 10 f0       	push   $0xf01053ef
f0102175:	68 a8 03 00 00       	push   $0x3a8
f010217a:	68 c9 53 10 f0       	push   $0xf01053c9
f010217f:	e8 47 df ff ff       	call   f01000cb <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102184:	83 ec 08             	sub    $0x8,%esp
f0102187:	68 00 10 00 00       	push   $0x1000
f010218c:	57                   	push   %edi
f010218d:	e8 e1 f1 ff ff       	call   f0101373 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102192:	8b 3d 68 01 19 f0    	mov    0xf0190168,%edi
f0102198:	ba 00 00 00 00       	mov    $0x0,%edx
f010219d:	89 f8                	mov    %edi,%eax
f010219f:	e8 9d eb ff ff       	call   f0100d41 <check_va2pa>
f01021a4:	83 c4 10             	add    $0x10,%esp
f01021a7:	83 f8 ff             	cmp    $0xffffffff,%eax
f01021aa:	74 19                	je     f01021c5 <mem_init+0xce1>
f01021ac:	68 68 51 10 f0       	push   $0xf0105168
f01021b1:	68 ef 53 10 f0       	push   $0xf01053ef
f01021b6:	68 ac 03 00 00       	push   $0x3ac
f01021bb:	68 c9 53 10 f0       	push   $0xf01053c9
f01021c0:	e8 06 df ff ff       	call   f01000cb <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f01021c5:	ba 00 10 00 00       	mov    $0x1000,%edx
f01021ca:	89 f8                	mov    %edi,%eax
f01021cc:	e8 70 eb ff ff       	call   f0100d41 <check_va2pa>
f01021d1:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f01021d4:	83 f8 ff             	cmp    $0xffffffff,%eax
f01021d7:	74 19                	je     f01021f2 <mem_init+0xd0e>
f01021d9:	68 8c 51 10 f0       	push   $0xf010518c
f01021de:	68 ef 53 10 f0       	push   $0xf01053ef
f01021e3:	68 ad 03 00 00       	push   $0x3ad
f01021e8:	68 c9 53 10 f0       	push   $0xf01053c9
f01021ed:	e8 d9 de ff ff       	call   f01000cb <_panic>
	assert(pp1->pp_ref == 0);
f01021f2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01021f5:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f01021fa:	74 19                	je     f0102215 <mem_init+0xd31>
f01021fc:	68 02 56 10 f0       	push   $0xf0105602
f0102201:	68 ef 53 10 f0       	push   $0xf01053ef
f0102206:	68 ae 03 00 00       	push   $0x3ae
f010220b:	68 c9 53 10 f0       	push   $0xf01053c9
f0102210:	e8 b6 de ff ff       	call   f01000cb <_panic>
	assert(pp2->pp_ref == 0);
f0102215:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f010221a:	74 19                	je     f0102235 <mem_init+0xd51>
f010221c:	68 f1 55 10 f0       	push   $0xf01055f1
f0102221:	68 ef 53 10 f0       	push   $0xf01053ef
f0102226:	68 af 03 00 00       	push   $0x3af
f010222b:	68 c9 53 10 f0       	push   $0xf01053c9
f0102230:	e8 96 de ff ff       	call   f01000cb <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0102235:	83 ec 0c             	sub    $0xc,%esp
f0102238:	6a 00                	push   $0x0
f010223a:	e8 14 ef ff ff       	call   f0101153 <page_alloc>
f010223f:	83 c4 10             	add    $0x10,%esp
f0102242:	85 c0                	test   %eax,%eax
f0102244:	74 05                	je     f010224b <mem_init+0xd67>
f0102246:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f0102249:	74 19                	je     f0102264 <mem_init+0xd80>
f010224b:	68 b4 51 10 f0       	push   $0xf01051b4
f0102250:	68 ef 53 10 f0       	push   $0xf01053ef
f0102255:	68 b2 03 00 00       	push   $0x3b2
f010225a:	68 c9 53 10 f0       	push   $0xf01053c9
f010225f:	e8 67 de ff ff       	call   f01000cb <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0102264:	83 ec 0c             	sub    $0xc,%esp
f0102267:	6a 00                	push   $0x0
f0102269:	e8 e5 ee ff ff       	call   f0101153 <page_alloc>
f010226e:	83 c4 10             	add    $0x10,%esp
f0102271:	85 c0                	test   %eax,%eax
f0102273:	74 19                	je     f010228e <mem_init+0xdaa>
f0102275:	68 45 55 10 f0       	push   $0xf0105545
f010227a:	68 ef 53 10 f0       	push   $0xf01053ef
f010227f:	68 b5 03 00 00       	push   $0x3b5
f0102284:	68 c9 53 10 f0       	push   $0xf01053c9
f0102289:	e8 3d de ff ff       	call   f01000cb <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f010228e:	8b 0d 68 01 19 f0    	mov    0xf0190168,%ecx
f0102294:	8b 11                	mov    (%ecx),%edx
f0102296:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f010229c:	89 d8                	mov    %ebx,%eax
f010229e:	2b 05 6c 01 19 f0    	sub    0xf019016c,%eax
f01022a4:	c1 f8 03             	sar    $0x3,%eax
f01022a7:	c1 e0 0c             	shl    $0xc,%eax
f01022aa:	39 c2                	cmp    %eax,%edx
f01022ac:	74 19                	je     f01022c7 <mem_init+0xde3>
f01022ae:	68 c4 4e 10 f0       	push   $0xf0104ec4
f01022b3:	68 ef 53 10 f0       	push   $0xf01053ef
f01022b8:	68 b8 03 00 00       	push   $0x3b8
f01022bd:	68 c9 53 10 f0       	push   $0xf01053c9
f01022c2:	e8 04 de ff ff       	call   f01000cb <_panic>
	kern_pgdir[0] = 0;
f01022c7:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f01022cd:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01022d2:	74 19                	je     f01022ed <mem_init+0xe09>
f01022d4:	68 a8 55 10 f0       	push   $0xf01055a8
f01022d9:	68 ef 53 10 f0       	push   $0xf01053ef
f01022de:	68 ba 03 00 00       	push   $0x3ba
f01022e3:	68 c9 53 10 f0       	push   $0xf01053c9
f01022e8:	e8 de dd ff ff       	call   f01000cb <_panic>
	pp0->pp_ref = 0;
f01022ed:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f01022f3:	83 ec 0c             	sub    $0xc,%esp
f01022f6:	53                   	push   %ebx
f01022f7:	e8 c1 ee ff ff       	call   f01011bd <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f01022fc:	83 c4 0c             	add    $0xc,%esp
f01022ff:	6a 01                	push   $0x1
f0102301:	68 00 10 40 00       	push   $0x401000
f0102306:	ff 35 68 01 19 f0    	pushl  0xf0190168
f010230c:	e8 f3 ee ff ff       	call   f0101204 <pgdir_walk>
f0102311:	89 c7                	mov    %eax,%edi
f0102313:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0102316:	a1 68 01 19 f0       	mov    0xf0190168,%eax
f010231b:	89 45 cc             	mov    %eax,-0x34(%ebp)
f010231e:	8b 40 04             	mov    0x4(%eax),%eax
f0102321:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102326:	8b 0d 64 01 19 f0    	mov    0xf0190164,%ecx
f010232c:	89 c2                	mov    %eax,%edx
f010232e:	c1 ea 0c             	shr    $0xc,%edx
f0102331:	83 c4 10             	add    $0x10,%esp
f0102334:	39 ca                	cmp    %ecx,%edx
f0102336:	72 15                	jb     f010234d <mem_init+0xe69>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102338:	50                   	push   %eax
f0102339:	68 70 4b 10 f0       	push   $0xf0104b70
f010233e:	68 c1 03 00 00       	push   $0x3c1
f0102343:	68 c9 53 10 f0       	push   $0xf01053c9
f0102348:	e8 7e dd ff ff       	call   f01000cb <_panic>
	assert(ptep == ptep1 + PTX(va));
f010234d:	2d fc ff ff 0f       	sub    $0xffffffc,%eax
f0102352:	39 c7                	cmp    %eax,%edi
f0102354:	74 19                	je     f010236f <mem_init+0xe8b>
f0102356:	68 13 56 10 f0       	push   $0xf0105613
f010235b:	68 ef 53 10 f0       	push   $0xf01053ef
f0102360:	68 c2 03 00 00       	push   $0x3c2
f0102365:	68 c9 53 10 f0       	push   $0xf01053c9
f010236a:	e8 5c dd ff ff       	call   f01000cb <_panic>
	kern_pgdir[PDX(va)] = 0;
f010236f:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0102372:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	pp0->pp_ref = 0;
f0102379:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f010237f:	89 d8                	mov    %ebx,%eax
f0102381:	2b 05 6c 01 19 f0    	sub    0xf019016c,%eax
f0102387:	c1 f8 03             	sar    $0x3,%eax
f010238a:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010238d:	89 c2                	mov    %eax,%edx
f010238f:	c1 ea 0c             	shr    $0xc,%edx
f0102392:	39 d1                	cmp    %edx,%ecx
f0102394:	77 12                	ja     f01023a8 <mem_init+0xec4>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102396:	50                   	push   %eax
f0102397:	68 70 4b 10 f0       	push   $0xf0104b70
f010239c:	6a 56                	push   $0x56
f010239e:	68 d5 53 10 f0       	push   $0xf01053d5
f01023a3:	e8 23 dd ff ff       	call   f01000cb <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f01023a8:	83 ec 04             	sub    $0x4,%esp
f01023ab:	68 00 10 00 00       	push   $0x1000
f01023b0:	68 ff 00 00 00       	push   $0xff
f01023b5:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01023ba:	50                   	push   %eax
f01023bb:	e8 c4 1d 00 00       	call   f0104184 <memset>
	page_free(pp0);
f01023c0:	89 1c 24             	mov    %ebx,(%esp)
f01023c3:	e8 f5 ed ff ff       	call   f01011bd <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f01023c8:	83 c4 0c             	add    $0xc,%esp
f01023cb:	6a 01                	push   $0x1
f01023cd:	6a 00                	push   $0x0
f01023cf:	ff 35 68 01 19 f0    	pushl  0xf0190168
f01023d5:	e8 2a ee ff ff       	call   f0101204 <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f01023da:	89 da                	mov    %ebx,%edx
f01023dc:	2b 15 6c 01 19 f0    	sub    0xf019016c,%edx
f01023e2:	c1 fa 03             	sar    $0x3,%edx
f01023e5:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01023e8:	89 d0                	mov    %edx,%eax
f01023ea:	c1 e8 0c             	shr    $0xc,%eax
f01023ed:	83 c4 10             	add    $0x10,%esp
f01023f0:	3b 05 64 01 19 f0    	cmp    0xf0190164,%eax
f01023f6:	72 12                	jb     f010240a <mem_init+0xf26>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01023f8:	52                   	push   %edx
f01023f9:	68 70 4b 10 f0       	push   $0xf0104b70
f01023fe:	6a 56                	push   $0x56
f0102400:	68 d5 53 10 f0       	push   $0xf01053d5
f0102405:	e8 c1 dc ff ff       	call   f01000cb <_panic>
	return (void *)(pa + KERNBASE);
f010240a:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f0102410:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0102413:	f6 82 00 00 00 f0 01 	testb  $0x1,-0x10000000(%edx)
f010241a:	75 11                	jne    f010242d <mem_init+0xf49>
f010241c:	8d 82 04 00 00 f0    	lea    -0xffffffc(%edx),%eax
f0102422:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
f0102428:	f6 00 01             	testb  $0x1,(%eax)
f010242b:	74 19                	je     f0102446 <mem_init+0xf62>
f010242d:	68 2b 56 10 f0       	push   $0xf010562b
f0102432:	68 ef 53 10 f0       	push   $0xf01053ef
f0102437:	68 cc 03 00 00       	push   $0x3cc
f010243c:	68 c9 53 10 f0       	push   $0xf01053c9
f0102441:	e8 85 dc ff ff       	call   f01000cb <_panic>
f0102446:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f0102449:	39 c2                	cmp    %eax,%edx
f010244b:	75 db                	jne    f0102428 <mem_init+0xf44>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f010244d:	a1 68 01 19 f0       	mov    0xf0190168,%eax
f0102452:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0102458:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// give free list back
	page_free_list = fl;
f010245e:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102461:	a3 9c f4 18 f0       	mov    %eax,0xf018f49c

	// free the pages we took
	page_free(pp0);
f0102466:	83 ec 0c             	sub    $0xc,%esp
f0102469:	53                   	push   %ebx
f010246a:	e8 4e ed ff ff       	call   f01011bd <page_free>
	page_free(pp1);
f010246f:	83 c4 04             	add    $0x4,%esp
f0102472:	ff 75 d4             	pushl  -0x2c(%ebp)
f0102475:	e8 43 ed ff ff       	call   f01011bd <page_free>
	page_free(pp2);
f010247a:	89 34 24             	mov    %esi,(%esp)
f010247d:	e8 3b ed ff ff       	call   f01011bd <page_free>

	cprintf("check_page() succeeded!\n");
f0102482:	c7 04 24 42 56 10 f0 	movl   $0xf0105642,(%esp)
f0102489:	e8 9c 0b 00 00       	call   f010302a <cprintf>
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir,UPAGES,ROUNDUP(npages*sizeof(struct Page),PGSIZE),PADDR(pages),PTE_W);
f010248e:	a1 6c 01 19 f0       	mov    0xf019016c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102493:	83 c4 10             	add    $0x10,%esp
f0102496:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010249b:	77 15                	ja     f01024b2 <mem_init+0xfce>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010249d:	50                   	push   %eax
f010249e:	68 c8 4d 10 f0       	push   $0xf0104dc8
f01024a3:	68 b7 00 00 00       	push   $0xb7
f01024a8:	68 c9 53 10 f0       	push   $0xf01053c9
f01024ad:	e8 19 dc ff ff       	call   f01000cb <_panic>
f01024b2:	8b 15 64 01 19 f0    	mov    0xf0190164,%edx
f01024b8:	8d 0c d5 ff 0f 00 00 	lea    0xfff(,%edx,8),%ecx
f01024bf:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f01024c5:	83 ec 08             	sub    $0x8,%esp
f01024c8:	6a 02                	push   $0x2
f01024ca:	05 00 00 00 10       	add    $0x10000000,%eax
f01024cf:	50                   	push   %eax
f01024d0:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f01024d5:	a1 68 01 19 f0       	mov    0xf0190168,%eax
f01024da:	e8 c3 ed ff ff       	call   f01012a2 <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01024df:	83 c4 10             	add    $0x10,%esp
f01024e2:	b8 00 10 11 f0       	mov    $0xf0111000,%eax
f01024e7:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01024ec:	77 15                	ja     f0102503 <mem_init+0x101f>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01024ee:	50                   	push   %eax
f01024ef:	68 c8 4d 10 f0       	push   $0xf0104dc8
f01024f4:	68 cc 00 00 00       	push   $0xcc
f01024f9:	68 c9 53 10 f0       	push   $0xf01053c9
f01024fe:	e8 c8 db ff ff       	call   f01000cb <_panic>
	return (physaddr_t)kva - KERNBASE;
f0102503:	c7 45 c8 00 10 11 00 	movl   $0x111000,-0x38(%ebp)
	//     * [KSTACKTOP-PTSIZE, KSTACKTOP-KSTKSIZE) -- not backed; so if
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir,KSTACKTOP-KSTKSIZE,KSTKSIZE,PADDR(bootstack),PTE_W);
f010250a:	83 ec 08             	sub    $0x8,%esp
f010250d:	6a 02                	push   $0x2
f010250f:	68 00 10 11 00       	push   $0x111000
f0102514:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102519:	ba 00 80 bf ef       	mov    $0xefbf8000,%edx
f010251e:	a1 68 01 19 f0       	mov    0xf0190168,%eax
f0102523:	e8 7a ed ff ff       	call   f01012a2 <boot_map_region>
	//      the PA range [0, 2^32 - KERNBASE)
	// We might not have 2^32 - KERNBASE bytes of physical memory, but
	// we just set up the mapping anyway.
	// Permissions: kernel RW, user NONE
	// Your code goes here:
	boot_map_region_large(kern_pgdir,KERNBASE,(uint32_t)0xFFFFFFFF-KERNBASE,0,PTE_W);
f0102528:	8b 1d 68 01 19 f0    	mov    0xf0190168,%ebx
f010252e:	83 c4 10             	add    $0x10,%esp
f0102531:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
	// Fill this function in
	for(uint32_t end=va+size;va<end;va+=PTSIZE,pa+=PTSIZE)
	{
		if(va==0&&end==0xFFFFFFFF)
			return;
		pgdir[PDX(va)]=PTE_ADDR(pa)|perm|PTE_P|PTE_PS;
f0102536:	89 d1                	mov    %edx,%ecx
f0102538:	c1 e9 16             	shr    $0x16,%ecx
f010253b:	8d 82 00 00 00 10    	lea    0x10000000(%edx),%eax
f0102541:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102546:	0c 83                	or     $0x83,%al
f0102548:	89 04 8b             	mov    %eax,(%ebx,%ecx,4)
boot_map_region_large(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	// Fill this function in
	for(uint32_t end=va+size;va<end;va+=PTSIZE,pa+=PTSIZE)
	{
		if(va==0&&end==0xFFFFFFFF)
f010254b:	81 c2 00 00 40 00    	add    $0x400000,%edx
f0102551:	75 e3                	jne    f0102536 <mem_init+0x1052>

static __inline uint32_t
rcr4(void)
{
	uint32_t cr4;
	__asm __volatile("movl %%cr4,%0" : "=r" (cr4));
f0102553:	0f 20 e0             	mov    %cr4,%eax
}

static __inline void
lcr4(uint32_t val)
{
	__asm __volatile("movl %0,%%cr4" : : "r" (val));
f0102556:	83 c8 10             	or     $0x10,%eax
f0102559:	0f 22 e0             	mov    %eax,%cr4
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f010255c:	8b 1d 68 01 19 f0    	mov    0xf0190168,%ebx

	// check pages array
	n = ROUNDUP(npages*sizeof(struct Page), PGSIZE);
f0102562:	a1 64 01 19 f0       	mov    0xf0190164,%eax
f0102567:	89 45 cc             	mov    %eax,-0x34(%ebp)
f010256a:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102571:	8b 3d 6c 01 19 f0    	mov    0xf019016c,%edi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102577:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f010257a:	be 00 00 00 00       	mov    $0x0,%esi

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct Page), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f010257f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102584:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0102587:	75 10                	jne    f0102599 <mem_init+0x10b5>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102589:	8b 3d a8 f4 18 f0    	mov    0xf018f4a8,%edi
f010258f:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0102592:	be 00 00 c0 ee       	mov    $0xeec00000,%esi
f0102597:	eb 5c                	jmp    f01025f5 <mem_init+0x1111>
	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct Page), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102599:	8d 96 00 00 00 ef    	lea    -0x11000000(%esi),%edx
f010259f:	89 d8                	mov    %ebx,%eax
f01025a1:	e8 9b e7 ff ff       	call   f0100d41 <check_va2pa>
f01025a6:	81 7d d4 ff ff ff ef 	cmpl   $0xefffffff,-0x2c(%ebp)
f01025ad:	77 15                	ja     f01025c4 <mem_init+0x10e0>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01025af:	57                   	push   %edi
f01025b0:	68 c8 4d 10 f0       	push   $0xf0104dc8
f01025b5:	68 01 03 00 00       	push   $0x301
f01025ba:	68 c9 53 10 f0       	push   $0xf01053c9
f01025bf:	e8 07 db ff ff       	call   f01000cb <_panic>
f01025c4:	8d 94 37 00 00 00 10 	lea    0x10000000(%edi,%esi,1),%edx
f01025cb:	39 c2                	cmp    %eax,%edx
f01025cd:	74 19                	je     f01025e8 <mem_init+0x1104>
f01025cf:	68 d8 51 10 f0       	push   $0xf01051d8
f01025d4:	68 ef 53 10 f0       	push   $0xf01053ef
f01025d9:	68 01 03 00 00       	push   $0x301
f01025de:	68 c9 53 10 f0       	push   $0xf01053c9
f01025e3:	e8 e3 da ff ff       	call   f01000cb <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct Page), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f01025e8:	81 c6 00 10 00 00    	add    $0x1000,%esi
f01025ee:	39 75 d0             	cmp    %esi,-0x30(%ebp)
f01025f1:	77 a6                	ja     f0102599 <mem_init+0x10b5>
f01025f3:	eb 94                	jmp    f0102589 <mem_init+0x10a5>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f01025f5:	89 f2                	mov    %esi,%edx
f01025f7:	89 d8                	mov    %ebx,%eax
f01025f9:	e8 43 e7 ff ff       	call   f0100d41 <check_va2pa>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01025fe:	81 7d d4 ff ff ff ef 	cmpl   $0xefffffff,-0x2c(%ebp)
f0102605:	77 15                	ja     f010261c <mem_init+0x1138>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102607:	57                   	push   %edi
f0102608:	68 c8 4d 10 f0       	push   $0xf0104dc8
f010260d:	68 06 03 00 00       	push   $0x306
f0102612:	68 c9 53 10 f0       	push   $0xf01053c9
f0102617:	e8 af da ff ff       	call   f01000cb <_panic>
f010261c:	8d 94 37 00 00 40 21 	lea    0x21400000(%edi,%esi,1),%edx
f0102623:	39 c2                	cmp    %eax,%edx
f0102625:	74 19                	je     f0102640 <mem_init+0x115c>
f0102627:	68 0c 52 10 f0       	push   $0xf010520c
f010262c:	68 ef 53 10 f0       	push   $0xf01053ef
f0102631:	68 06 03 00 00       	push   $0x306
f0102636:	68 c9 53 10 f0       	push   $0xf01053c9
f010263b:	e8 8b da ff ff       	call   f01000cb <_panic>
f0102640:	81 c6 00 10 00 00    	add    $0x1000,%esi
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102646:	81 fe 00 80 c1 ee    	cmp    $0xeec18000,%esi
f010264c:	75 a7                	jne    f01025f5 <mem_init+0x1111>

static physaddr_t
check_va2pa_large(pde_t *pgdir, uintptr_t va)
{
	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P) | !(*pgdir & PTE_PS))
f010264e:	8b 83 00 0f 00 00    	mov    0xf00(%ebx),%eax
f0102654:	89 c2                	mov    %eax,%edx
f0102656:	81 e2 81 00 00 00    	and    $0x81,%edx
f010265c:	81 fa 81 00 00 00    	cmp    $0x81,%edx
f0102662:	75 07                	jne    f010266b <mem_init+0x1187>
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	if (check_va2pa_large(pgdir, KERNBASE) == 0) {
f0102664:	a9 00 f0 ff ff       	test   $0xfffff000,%eax
f0102669:	74 15                	je     f0102680 <mem_init+0x119c>
		for (i = 0; i < npages * PGSIZE; i += PTSIZE)
			assert(check_va2pa_large(pgdir, KERNBASE + i) == i);

		cprintf("large page installed!\n");
	} else {
	    for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f010266b:	8b 7d cc             	mov    -0x34(%ebp),%edi
f010266e:	c1 e7 0c             	shl    $0xc,%edi
f0102671:	be 00 00 00 00       	mov    $0x0,%esi
f0102676:	85 ff                	test   %edi,%edi
f0102678:	0f 85 91 00 00 00    	jne    f010270f <mem_init+0x122b>
f010267e:	eb 6b                	jmp    f01026eb <mem_init+0x1207>
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	if (check_va2pa_large(pgdir, KERNBASE) == 0) {
		for (i = 0; i < npages * PGSIZE; i += PTSIZE)
f0102680:	8b 7d cc             	mov    -0x34(%ebp),%edi
f0102683:	c1 e7 0c             	shl    $0xc,%edi
f0102686:	85 ff                	test   %edi,%edi
f0102688:	74 51                	je     f01026db <mem_init+0x11f7>
f010268a:	ba 00 00 00 00       	mov    $0x0,%edx
f010268f:	8b 4d c4             	mov    -0x3c(%ebp),%ecx

static physaddr_t
check_va2pa_large(pde_t *pgdir, uintptr_t va)
{
	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P) | !(*pgdir & PTE_PS))
f0102692:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
f0102698:	c1 e8 16             	shr    $0x16,%eax
f010269b:	8b 04 83             	mov    (%ebx,%eax,4),%eax
f010269e:	89 c6                	mov    %eax,%esi
f01026a0:	81 e6 81 00 00 00    	and    $0x81,%esi
		return ~0;
	return PTE_ADDR(*pgdir);
f01026a6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01026ab:	81 fe 81 00 00 00    	cmp    $0x81,%esi
f01026b1:	0f 45 c1             	cmovne %ecx,%eax
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	if (check_va2pa_large(pgdir, KERNBASE) == 0) {
		for (i = 0; i < npages * PGSIZE; i += PTSIZE)
			assert(check_va2pa_large(pgdir, KERNBASE + i) == i);
f01026b4:	39 d0                	cmp    %edx,%eax
f01026b6:	74 19                	je     f01026d1 <mem_init+0x11ed>
f01026b8:	68 40 52 10 f0       	push   $0xf0105240
f01026bd:	68 ef 53 10 f0       	push   $0xf01053ef
f01026c2:	68 0b 03 00 00       	push   $0x30b
f01026c7:	68 c9 53 10 f0       	push   $0xf01053c9
f01026cc:	e8 fa d9 ff ff       	call   f01000cb <_panic>
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	if (check_va2pa_large(pgdir, KERNBASE) == 0) {
		for (i = 0; i < npages * PGSIZE; i += PTSIZE)
f01026d1:	81 c2 00 00 40 00    	add    $0x400000,%edx
f01026d7:	39 fa                	cmp    %edi,%edx
f01026d9:	72 b7                	jb     f0102692 <mem_init+0x11ae>
			assert(check_va2pa_large(pgdir, KERNBASE + i) == i);

		cprintf("large page installed!\n");
f01026db:	83 ec 0c             	sub    $0xc,%esp
f01026de:	68 5b 56 10 f0       	push   $0xf010565b
f01026e3:	e8 42 09 00 00       	call   f010302a <cprintf>
f01026e8:	83 c4 10             	add    $0x10,%esp



	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f01026eb:	ba 00 80 bf ef       	mov    $0xefbf8000,%edx
f01026f0:	89 d8                	mov    %ebx,%eax
f01026f2:	e8 4a e6 ff ff       	call   f0100d41 <check_va2pa>
f01026f7:	bf 00 90 11 00       	mov    $0x119000,%edi
f01026fc:	be 00 80 bf df       	mov    $0xdfbf8000,%esi
f0102701:	81 ee 00 10 11 f0    	sub    $0xf0111000,%esi
f0102707:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
f010270a:	8b 5d c8             	mov    -0x38(%ebp),%ebx
f010270d:	eb 36                	jmp    f0102745 <mem_init+0x1261>
			assert(check_va2pa_large(pgdir, KERNBASE + i) == i);

		cprintf("large page installed!\n");
	} else {
	    for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		    assert(check_va2pa(pgdir, KERNBASE + i) == i);
f010270f:	8d 96 00 00 00 f0    	lea    -0x10000000(%esi),%edx
f0102715:	89 d8                	mov    %ebx,%eax
f0102717:	e8 25 e6 ff ff       	call   f0100d41 <check_va2pa>
f010271c:	39 f0                	cmp    %esi,%eax
f010271e:	74 19                	je     f0102739 <mem_init+0x1255>
f0102720:	68 6c 52 10 f0       	push   $0xf010526c
f0102725:	68 ef 53 10 f0       	push   $0xf01053ef
f010272a:	68 10 03 00 00       	push   $0x310
f010272f:	68 c9 53 10 f0       	push   $0xf01053c9
f0102734:	e8 92 d9 ff ff       	call   f01000cb <_panic>
		for (i = 0; i < npages * PGSIZE; i += PTSIZE)
			assert(check_va2pa_large(pgdir, KERNBASE + i) == i);

		cprintf("large page installed!\n");
	} else {
	    for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102739:	81 c6 00 10 00 00    	add    $0x1000,%esi
f010273f:	39 fe                	cmp    %edi,%esi
f0102741:	72 cc                	jb     f010270f <mem_init+0x122b>
f0102743:	eb a6                	jmp    f01026eb <mem_init+0x1207>



	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0102745:	39 c3                	cmp    %eax,%ebx
f0102747:	74 19                	je     f0102762 <mem_init+0x127e>
f0102749:	68 94 52 10 f0       	push   $0xf0105294
f010274e:	68 ef 53 10 f0       	push   $0xf01053ef
f0102753:	68 17 03 00 00       	push   $0x317
f0102758:	68 c9 53 10 f0       	push   $0xf01053c9
f010275d:	e8 69 d9 ff ff       	call   f01000cb <_panic>
f0102762:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	}



	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102768:	39 df                	cmp    %ebx,%edi
f010276a:	0f 85 1b 04 00 00    	jne    f0102b8b <mem_init+0x16a7>
f0102770:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f0102773:	ba 00 00 80 ef       	mov    $0xef800000,%edx
f0102778:	89 d8                	mov    %ebx,%eax
f010277a:	e8 c2 e5 ff ff       	call   f0100d41 <check_va2pa>
f010277f:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102782:	74 19                	je     f010279d <mem_init+0x12b9>
f0102784:	68 dc 52 10 f0       	push   $0xf01052dc
f0102789:	68 ef 53 10 f0       	push   $0xf01053ef
f010278e:	68 18 03 00 00       	push   $0x318
f0102793:	68 c9 53 10 f0       	push   $0xf01053c9
f0102798:	e8 2e d9 ff ff       	call   f01000cb <_panic>
f010279d:	b8 00 00 00 00       	mov    $0x0,%eax

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f01027a2:	8d 90 45 fc ff ff    	lea    -0x3bb(%eax),%edx
f01027a8:	83 fa 03             	cmp    $0x3,%edx
f01027ab:	77 1f                	ja     f01027cc <mem_init+0x12e8>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
		case PDX(UENVS):
			assert(pgdir[i] & PTE_P);
f01027ad:	f6 04 83 01          	testb  $0x1,(%ebx,%eax,4)
f01027b1:	75 7e                	jne    f0102831 <mem_init+0x134d>
f01027b3:	68 72 56 10 f0       	push   $0xf0105672
f01027b8:	68 ef 53 10 f0       	push   $0xf01053ef
f01027bd:	68 21 03 00 00       	push   $0x321
f01027c2:	68 c9 53 10 f0       	push   $0xf01053c9
f01027c7:	e8 ff d8 ff ff       	call   f01000cb <_panic>
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f01027cc:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f01027d1:	76 3f                	jbe    f0102812 <mem_init+0x132e>
				assert(pgdir[i] & PTE_P);
f01027d3:	8b 14 83             	mov    (%ebx,%eax,4),%edx
f01027d6:	f6 c2 01             	test   $0x1,%dl
f01027d9:	75 19                	jne    f01027f4 <mem_init+0x1310>
f01027db:	68 72 56 10 f0       	push   $0xf0105672
f01027e0:	68 ef 53 10 f0       	push   $0xf01053ef
f01027e5:	68 25 03 00 00       	push   $0x325
f01027ea:	68 c9 53 10 f0       	push   $0xf01053c9
f01027ef:	e8 d7 d8 ff ff       	call   f01000cb <_panic>
				assert(pgdir[i] & PTE_W);
f01027f4:	f6 c2 02             	test   $0x2,%dl
f01027f7:	75 38                	jne    f0102831 <mem_init+0x134d>
f01027f9:	68 83 56 10 f0       	push   $0xf0105683
f01027fe:	68 ef 53 10 f0       	push   $0xf01053ef
f0102803:	68 26 03 00 00       	push   $0x326
f0102808:	68 c9 53 10 f0       	push   $0xf01053c9
f010280d:	e8 b9 d8 ff ff       	call   f01000cb <_panic>
			} else
				assert(pgdir[i] == 0);
f0102812:	83 3c 83 00          	cmpl   $0x0,(%ebx,%eax,4)
f0102816:	74 19                	je     f0102831 <mem_init+0x134d>
f0102818:	68 94 56 10 f0       	push   $0xf0105694
f010281d:	68 ef 53 10 f0       	push   $0xf01053ef
f0102822:	68 28 03 00 00       	push   $0x328
f0102827:	68 c9 53 10 f0       	push   $0xf01053c9
f010282c:	e8 9a d8 ff ff       	call   f01000cb <_panic>
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f0102831:	83 c0 01             	add    $0x1,%eax
f0102834:	3d 00 04 00 00       	cmp    $0x400,%eax
f0102839:	0f 85 63 ff ff ff    	jne    f01027a2 <mem_init+0x12be>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f010283f:	83 ec 0c             	sub    $0xc,%esp
f0102842:	68 0c 53 10 f0       	push   $0xf010530c
f0102847:	e8 de 07 00 00       	call   f010302a <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f010284c:	a1 68 01 19 f0       	mov    0xf0190168,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102851:	83 c4 10             	add    $0x10,%esp
f0102854:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102859:	77 15                	ja     f0102870 <mem_init+0x138c>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010285b:	50                   	push   %eax
f010285c:	68 c8 4d 10 f0       	push   $0xf0104dc8
f0102861:	68 e3 00 00 00       	push   $0xe3
f0102866:	68 c9 53 10 f0       	push   $0xf01053c9
f010286b:	e8 5b d8 ff ff       	call   f01000cb <_panic>
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0102870:	05 00 00 00 10       	add    $0x10000000,%eax
f0102875:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f0102878:	b8 00 00 00 00       	mov    $0x0,%eax
f010287d:	e8 23 e5 ff ff       	call   f0100da5 <check_page_free_list>

static __inline uint32_t
rcr0(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr0,%0" : "=r" (val));
f0102882:	0f 20 c0             	mov    %cr0,%eax
f0102885:	83 e0 f3             	and    $0xfffffff3,%eax
}

static __inline void
lcr0(uint32_t val)
{
	__asm __volatile("movl %0,%%cr0" : : "r" (val));
f0102888:	0d 23 00 05 80       	or     $0x80050023,%eax
f010288d:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102890:	83 ec 0c             	sub    $0xc,%esp
f0102893:	6a 00                	push   $0x0
f0102895:	e8 b9 e8 ff ff       	call   f0101153 <page_alloc>
f010289a:	89 c3                	mov    %eax,%ebx
f010289c:	83 c4 10             	add    $0x10,%esp
f010289f:	85 c0                	test   %eax,%eax
f01028a1:	75 19                	jne    f01028bc <mem_init+0x13d8>
f01028a3:	68 9a 54 10 f0       	push   $0xf010549a
f01028a8:	68 ef 53 10 f0       	push   $0xf01053ef
f01028ad:	68 fb 03 00 00       	push   $0x3fb
f01028b2:	68 c9 53 10 f0       	push   $0xf01053c9
f01028b7:	e8 0f d8 ff ff       	call   f01000cb <_panic>
	assert((pp1 = page_alloc(0)));
f01028bc:	83 ec 0c             	sub    $0xc,%esp
f01028bf:	6a 00                	push   $0x0
f01028c1:	e8 8d e8 ff ff       	call   f0101153 <page_alloc>
f01028c6:	89 c7                	mov    %eax,%edi
f01028c8:	83 c4 10             	add    $0x10,%esp
f01028cb:	85 c0                	test   %eax,%eax
f01028cd:	75 19                	jne    f01028e8 <mem_init+0x1404>
f01028cf:	68 b0 54 10 f0       	push   $0xf01054b0
f01028d4:	68 ef 53 10 f0       	push   $0xf01053ef
f01028d9:	68 fc 03 00 00       	push   $0x3fc
f01028de:	68 c9 53 10 f0       	push   $0xf01053c9
f01028e3:	e8 e3 d7 ff ff       	call   f01000cb <_panic>
	assert((pp2 = page_alloc(0)));
f01028e8:	83 ec 0c             	sub    $0xc,%esp
f01028eb:	6a 00                	push   $0x0
f01028ed:	e8 61 e8 ff ff       	call   f0101153 <page_alloc>
f01028f2:	89 c6                	mov    %eax,%esi
f01028f4:	83 c4 10             	add    $0x10,%esp
f01028f7:	85 c0                	test   %eax,%eax
f01028f9:	75 19                	jne    f0102914 <mem_init+0x1430>
f01028fb:	68 c6 54 10 f0       	push   $0xf01054c6
f0102900:	68 ef 53 10 f0       	push   $0xf01053ef
f0102905:	68 fd 03 00 00       	push   $0x3fd
f010290a:	68 c9 53 10 f0       	push   $0xf01053c9
f010290f:	e8 b7 d7 ff ff       	call   f01000cb <_panic>
	page_free(pp0);
f0102914:	83 ec 0c             	sub    $0xc,%esp
f0102917:	53                   	push   %ebx
f0102918:	e8 a0 e8 ff ff       	call   f01011bd <page_free>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f010291d:	89 f8                	mov    %edi,%eax
f010291f:	2b 05 6c 01 19 f0    	sub    0xf019016c,%eax
f0102925:	c1 f8 03             	sar    $0x3,%eax
f0102928:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010292b:	89 c2                	mov    %eax,%edx
f010292d:	c1 ea 0c             	shr    $0xc,%edx
f0102930:	83 c4 10             	add    $0x10,%esp
f0102933:	3b 15 64 01 19 f0    	cmp    0xf0190164,%edx
f0102939:	72 12                	jb     f010294d <mem_init+0x1469>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010293b:	50                   	push   %eax
f010293c:	68 70 4b 10 f0       	push   $0xf0104b70
f0102941:	6a 56                	push   $0x56
f0102943:	68 d5 53 10 f0       	push   $0xf01053d5
f0102948:	e8 7e d7 ff ff       	call   f01000cb <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f010294d:	83 ec 04             	sub    $0x4,%esp
f0102950:	68 00 10 00 00       	push   $0x1000
f0102955:	6a 01                	push   $0x1
f0102957:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010295c:	50                   	push   %eax
f010295d:	e8 22 18 00 00       	call   f0104184 <memset>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0102962:	89 f0                	mov    %esi,%eax
f0102964:	2b 05 6c 01 19 f0    	sub    0xf019016c,%eax
f010296a:	c1 f8 03             	sar    $0x3,%eax
f010296d:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102970:	89 c2                	mov    %eax,%edx
f0102972:	c1 ea 0c             	shr    $0xc,%edx
f0102975:	83 c4 10             	add    $0x10,%esp
f0102978:	3b 15 64 01 19 f0    	cmp    0xf0190164,%edx
f010297e:	72 12                	jb     f0102992 <mem_init+0x14ae>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102980:	50                   	push   %eax
f0102981:	68 70 4b 10 f0       	push   $0xf0104b70
f0102986:	6a 56                	push   $0x56
f0102988:	68 d5 53 10 f0       	push   $0xf01053d5
f010298d:	e8 39 d7 ff ff       	call   f01000cb <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f0102992:	83 ec 04             	sub    $0x4,%esp
f0102995:	68 00 10 00 00       	push   $0x1000
f010299a:	6a 02                	push   $0x2
f010299c:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01029a1:	50                   	push   %eax
f01029a2:	e8 dd 17 00 00       	call   f0104184 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f01029a7:	6a 02                	push   $0x2
f01029a9:	68 00 10 00 00       	push   $0x1000
f01029ae:	57                   	push   %edi
f01029af:	ff 35 68 01 19 f0    	pushl  0xf0190168
f01029b5:	e8 f1 e9 ff ff       	call   f01013ab <page_insert>
	assert(pp1->pp_ref == 1);
f01029ba:	83 c4 20             	add    $0x20,%esp
f01029bd:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f01029c2:	74 19                	je     f01029dd <mem_init+0x14f9>
f01029c4:	68 97 55 10 f0       	push   $0xf0105597
f01029c9:	68 ef 53 10 f0       	push   $0xf01053ef
f01029ce:	68 02 04 00 00       	push   $0x402
f01029d3:	68 c9 53 10 f0       	push   $0xf01053c9
f01029d8:	e8 ee d6 ff ff       	call   f01000cb <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f01029dd:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f01029e4:	01 01 01 
f01029e7:	74 19                	je     f0102a02 <mem_init+0x151e>
f01029e9:	68 2c 53 10 f0       	push   $0xf010532c
f01029ee:	68 ef 53 10 f0       	push   $0xf01053ef
f01029f3:	68 03 04 00 00       	push   $0x403
f01029f8:	68 c9 53 10 f0       	push   $0xf01053c9
f01029fd:	e8 c9 d6 ff ff       	call   f01000cb <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102a02:	6a 02                	push   $0x2
f0102a04:	68 00 10 00 00       	push   $0x1000
f0102a09:	56                   	push   %esi
f0102a0a:	ff 35 68 01 19 f0    	pushl  0xf0190168
f0102a10:	e8 96 e9 ff ff       	call   f01013ab <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102a15:	83 c4 10             	add    $0x10,%esp
f0102a18:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102a1f:	02 02 02 
f0102a22:	74 19                	je     f0102a3d <mem_init+0x1559>
f0102a24:	68 50 53 10 f0       	push   $0xf0105350
f0102a29:	68 ef 53 10 f0       	push   $0xf01053ef
f0102a2e:	68 05 04 00 00       	push   $0x405
f0102a33:	68 c9 53 10 f0       	push   $0xf01053c9
f0102a38:	e8 8e d6 ff ff       	call   f01000cb <_panic>
	assert(pp2->pp_ref == 1);
f0102a3d:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102a42:	74 19                	je     f0102a5d <mem_init+0x1579>
f0102a44:	68 b9 55 10 f0       	push   $0xf01055b9
f0102a49:	68 ef 53 10 f0       	push   $0xf01053ef
f0102a4e:	68 06 04 00 00       	push   $0x406
f0102a53:	68 c9 53 10 f0       	push   $0xf01053c9
f0102a58:	e8 6e d6 ff ff       	call   f01000cb <_panic>
	assert(pp1->pp_ref == 0);
f0102a5d:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102a62:	74 19                	je     f0102a7d <mem_init+0x1599>
f0102a64:	68 02 56 10 f0       	push   $0xf0105602
f0102a69:	68 ef 53 10 f0       	push   $0xf01053ef
f0102a6e:	68 07 04 00 00       	push   $0x407
f0102a73:	68 c9 53 10 f0       	push   $0xf01053c9
f0102a78:	e8 4e d6 ff ff       	call   f01000cb <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102a7d:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102a84:	03 03 03 
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0102a87:	89 f0                	mov    %esi,%eax
f0102a89:	2b 05 6c 01 19 f0    	sub    0xf019016c,%eax
f0102a8f:	c1 f8 03             	sar    $0x3,%eax
f0102a92:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102a95:	89 c2                	mov    %eax,%edx
f0102a97:	c1 ea 0c             	shr    $0xc,%edx
f0102a9a:	3b 15 64 01 19 f0    	cmp    0xf0190164,%edx
f0102aa0:	72 12                	jb     f0102ab4 <mem_init+0x15d0>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102aa2:	50                   	push   %eax
f0102aa3:	68 70 4b 10 f0       	push   $0xf0104b70
f0102aa8:	6a 56                	push   $0x56
f0102aaa:	68 d5 53 10 f0       	push   $0xf01053d5
f0102aaf:	e8 17 d6 ff ff       	call   f01000cb <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102ab4:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0102abb:	03 03 03 
f0102abe:	74 19                	je     f0102ad9 <mem_init+0x15f5>
f0102ac0:	68 74 53 10 f0       	push   $0xf0105374
f0102ac5:	68 ef 53 10 f0       	push   $0xf01053ef
f0102aca:	68 09 04 00 00       	push   $0x409
f0102acf:	68 c9 53 10 f0       	push   $0xf01053c9
f0102ad4:	e8 f2 d5 ff ff       	call   f01000cb <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102ad9:	83 ec 08             	sub    $0x8,%esp
f0102adc:	68 00 10 00 00       	push   $0x1000
f0102ae1:	ff 35 68 01 19 f0    	pushl  0xf0190168
f0102ae7:	e8 87 e8 ff ff       	call   f0101373 <page_remove>
	assert(pp2->pp_ref == 0);
f0102aec:	83 c4 10             	add    $0x10,%esp
f0102aef:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102af4:	74 19                	je     f0102b0f <mem_init+0x162b>
f0102af6:	68 f1 55 10 f0       	push   $0xf01055f1
f0102afb:	68 ef 53 10 f0       	push   $0xf01053ef
f0102b00:	68 0b 04 00 00       	push   $0x40b
f0102b05:	68 c9 53 10 f0       	push   $0xf01053c9
f0102b0a:	e8 bc d5 ff ff       	call   f01000cb <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102b0f:	8b 0d 68 01 19 f0    	mov    0xf0190168,%ecx
f0102b15:	8b 11                	mov    (%ecx),%edx
f0102b17:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102b1d:	89 d8                	mov    %ebx,%eax
f0102b1f:	2b 05 6c 01 19 f0    	sub    0xf019016c,%eax
f0102b25:	c1 f8 03             	sar    $0x3,%eax
f0102b28:	c1 e0 0c             	shl    $0xc,%eax
f0102b2b:	39 c2                	cmp    %eax,%edx
f0102b2d:	74 19                	je     f0102b48 <mem_init+0x1664>
f0102b2f:	68 c4 4e 10 f0       	push   $0xf0104ec4
f0102b34:	68 ef 53 10 f0       	push   $0xf01053ef
f0102b39:	68 0e 04 00 00       	push   $0x40e
f0102b3e:	68 c9 53 10 f0       	push   $0xf01053c9
f0102b43:	e8 83 d5 ff ff       	call   f01000cb <_panic>
	kern_pgdir[0] = 0;
f0102b48:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102b4e:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102b53:	74 19                	je     f0102b6e <mem_init+0x168a>
f0102b55:	68 a8 55 10 f0       	push   $0xf01055a8
f0102b5a:	68 ef 53 10 f0       	push   $0xf01053ef
f0102b5f:	68 10 04 00 00       	push   $0x410
f0102b64:	68 c9 53 10 f0       	push   $0xf01053c9
f0102b69:	e8 5d d5 ff ff       	call   f01000cb <_panic>
	pp0->pp_ref = 0;
f0102b6e:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f0102b74:	83 ec 0c             	sub    $0xc,%esp
f0102b77:	53                   	push   %ebx
f0102b78:	e8 40 e6 ff ff       	call   f01011bd <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102b7d:	c7 04 24 a0 53 10 f0 	movl   $0xf01053a0,(%esp)
f0102b84:	e8 a1 04 00 00       	call   f010302a <cprintf>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f0102b89:	eb 10                	jmp    f0102b9b <mem_init+0x16b7>



	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0102b8b:	8d 14 1e             	lea    (%esi,%ebx,1),%edx
f0102b8e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102b91:	e8 ab e1 ff ff       	call   f0100d41 <check_va2pa>
f0102b96:	e9 aa fb ff ff       	jmp    f0102745 <mem_init+0x1261>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f0102b9b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102b9e:	5b                   	pop    %ebx
f0102b9f:	5e                   	pop    %esi
f0102ba0:	5f                   	pop    %edi
f0102ba1:	5d                   	pop    %ebp
f0102ba2:	c3                   	ret    

f0102ba3 <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f0102ba3:	55                   	push   %ebp
f0102ba4:	89 e5                	mov    %esp,%ebp
}

static __inline void 
invlpg(void *addr)
{ 
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0102ba6:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102ba9:	0f 01 38             	invlpg (%eax)
	// Flush the entry only if we're modifying the current address space.
	// For now, there is only one address space, so always invalidate.
	invlpg(va);
}
f0102bac:	5d                   	pop    %ebp
f0102bad:	c3                   	ret    

f0102bae <user_mem_check>:
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f0102bae:	55                   	push   %ebp
f0102baf:	89 e5                	mov    %esp,%ebp
	// LAB 3: Your code here.

	return 0;
}
f0102bb1:	b8 00 00 00 00       	mov    $0x0,%eax
f0102bb6:	5d                   	pop    %ebp
f0102bb7:	c3                   	ret    

f0102bb8 <user_mem_assert>:
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f0102bb8:	55                   	push   %ebp
f0102bb9:	89 e5                	mov    %esp,%ebp
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
		cprintf("[%08x] user_mem_check assertion failure for "
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
	}
}
f0102bbb:	5d                   	pop    %ebp
f0102bbc:	c3                   	ret    

f0102bbd <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f0102bbd:	55                   	push   %ebp
f0102bbe:	89 e5                	mov    %esp,%ebp
f0102bc0:	8b 55 08             	mov    0x8(%ebp),%edx
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f0102bc3:	85 d2                	test   %edx,%edx
f0102bc5:	75 11                	jne    f0102bd8 <envid2env+0x1b>
		*env_store = curenv;
f0102bc7:	a1 a4 f4 18 f0       	mov    0xf018f4a4,%eax
f0102bcc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0102bcf:	89 01                	mov    %eax,(%ecx)
		return 0;
f0102bd1:	b8 00 00 00 00       	mov    $0x0,%eax
f0102bd6:	eb 60                	jmp    f0102c38 <envid2env+0x7b>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f0102bd8:	89 d0                	mov    %edx,%eax
f0102bda:	25 ff 03 00 00       	and    $0x3ff,%eax
f0102bdf:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0102be2:	c1 e0 05             	shl    $0x5,%eax
f0102be5:	03 05 a8 f4 18 f0    	add    0xf018f4a8,%eax
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f0102beb:	83 78 54 00          	cmpl   $0x0,0x54(%eax)
f0102bef:	74 05                	je     f0102bf6 <envid2env+0x39>
f0102bf1:	3b 50 48             	cmp    0x48(%eax),%edx
f0102bf4:	74 10                	je     f0102c06 <envid2env+0x49>
		*env_store = 0;
f0102bf6:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102bf9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0102bff:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0102c04:	eb 32                	jmp    f0102c38 <envid2env+0x7b>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0102c06:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0102c0a:	74 22                	je     f0102c2e <envid2env+0x71>
f0102c0c:	8b 15 a4 f4 18 f0    	mov    0xf018f4a4,%edx
f0102c12:	39 d0                	cmp    %edx,%eax
f0102c14:	74 18                	je     f0102c2e <envid2env+0x71>
f0102c16:	8b 4a 48             	mov    0x48(%edx),%ecx
f0102c19:	39 48 4c             	cmp    %ecx,0x4c(%eax)
f0102c1c:	74 10                	je     f0102c2e <envid2env+0x71>
		*env_store = 0;
f0102c1e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102c21:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0102c27:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0102c2c:	eb 0a                	jmp    f0102c38 <envid2env+0x7b>
	}

	*env_store = e;
f0102c2e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0102c31:	89 01                	mov    %eax,(%ecx)
	return 0;
f0102c33:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102c38:	5d                   	pop    %ebp
f0102c39:	c3                   	ret    

f0102c3a <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f0102c3a:	55                   	push   %ebp
f0102c3b:	89 e5                	mov    %esp,%ebp
}

static __inline void
lgdt(void *p)
{
	__asm __volatile("lgdt (%0)" : : "r" (p));
f0102c3d:	b8 00 b3 11 f0       	mov    $0xf011b300,%eax
f0102c42:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" :: "a" (GD_UD|3));
f0102c45:	b8 23 00 00 00       	mov    $0x23,%eax
f0102c4a:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" :: "a" (GD_UD|3));
f0102c4c:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" :: "a" (GD_KD));
f0102c4e:	b8 10 00 00 00       	mov    $0x10,%eax
f0102c53:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" :: "a" (GD_KD));
f0102c55:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" :: "a" (GD_KD));
f0102c57:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" :: "i" (GD_KT));
f0102c59:	ea 60 2c 10 f0 08 00 	ljmp   $0x8,$0xf0102c60
}

static __inline void
lldt(uint16_t sel)
{
	__asm __volatile("lldt %0" : : "r" (sel));
f0102c60:	b8 00 00 00 00       	mov    $0x0,%eax
f0102c65:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f0102c68:	5d                   	pop    %ebp
f0102c69:	c3                   	ret    

f0102c6a <env_init>:
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
{
f0102c6a:	55                   	push   %ebp
f0102c6b:	89 e5                	mov    %esp,%ebp
	// Set up envs array
	// LAB 3: Your code here.

	// Per-CPU part of the initialization
	env_init_percpu();
f0102c6d:	e8 c8 ff ff ff       	call   f0102c3a <env_init_percpu>
}
f0102c72:	5d                   	pop    %ebp
f0102c73:	c3                   	ret    

f0102c74 <env_alloc>:
//	-E_NO_FREE_ENV if all NENVS environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f0102c74:	55                   	push   %ebp
f0102c75:	89 e5                	mov    %esp,%ebp
f0102c77:	53                   	push   %ebx
f0102c78:	83 ec 04             	sub    $0x4,%esp
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f0102c7b:	8b 1d ac f4 18 f0    	mov    0xf018f4ac,%ebx
f0102c81:	85 db                	test   %ebx,%ebx
f0102c83:	0f 84 f4 00 00 00    	je     f0102d7d <env_alloc+0x109>
{
	int i;
	struct Page *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f0102c89:	83 ec 0c             	sub    $0xc,%esp
f0102c8c:	6a 01                	push   $0x1
f0102c8e:	e8 c0 e4 ff ff       	call   f0101153 <page_alloc>
f0102c93:	83 c4 10             	add    $0x10,%esp
f0102c96:	85 c0                	test   %eax,%eax
f0102c98:	0f 84 e6 00 00 00    	je     f0102d84 <env_alloc+0x110>

	// LAB 3: Your code here.

	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f0102c9e:	8b 43 5c             	mov    0x5c(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102ca1:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102ca6:	77 15                	ja     f0102cbd <env_alloc+0x49>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102ca8:	50                   	push   %eax
f0102ca9:	68 c8 4d 10 f0       	push   $0xf0104dc8
f0102cae:	68 b9 00 00 00       	push   $0xb9
f0102cb3:	68 da 56 10 f0       	push   $0xf01056da
f0102cb8:	e8 0e d4 ff ff       	call   f01000cb <_panic>
f0102cbd:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0102cc3:	83 ca 05             	or     $0x5,%edx
f0102cc6:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f0102ccc:	8b 43 48             	mov    0x48(%ebx),%eax
f0102ccf:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f0102cd4:	25 00 fc ff ff       	and    $0xfffffc00,%eax
		generation = 1 << ENVGENSHIFT;
f0102cd9:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102cde:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f0102ce1:	89 da                	mov    %ebx,%edx
f0102ce3:	2b 15 a8 f4 18 f0    	sub    0xf018f4a8,%edx
f0102ce9:	c1 fa 05             	sar    $0x5,%edx
f0102cec:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f0102cf2:	09 d0                	or     %edx,%eax
f0102cf4:	89 43 48             	mov    %eax,0x48(%ebx)

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f0102cf7:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102cfa:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f0102cfd:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f0102d04:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
	e->env_runs = 0;
f0102d0b:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f0102d12:	83 ec 04             	sub    $0x4,%esp
f0102d15:	6a 44                	push   $0x44
f0102d17:	6a 00                	push   $0x0
f0102d19:	53                   	push   %ebx
f0102d1a:	e8 65 14 00 00       	call   f0104184 <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f0102d1f:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f0102d25:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f0102d2b:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f0102d31:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f0102d38:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	// You will set e->env_tf.tf_eip later.

	// commit the allocation
	env_free_list = e->env_link;
f0102d3e:	8b 43 44             	mov    0x44(%ebx),%eax
f0102d41:	a3 ac f4 18 f0       	mov    %eax,0xf018f4ac
	*newenv_store = e;
f0102d46:	8b 45 08             	mov    0x8(%ebp),%eax
f0102d49:	89 18                	mov    %ebx,(%eax)

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0102d4b:	8b 53 48             	mov    0x48(%ebx),%edx
f0102d4e:	a1 a4 f4 18 f0       	mov    0xf018f4a4,%eax
f0102d53:	83 c4 10             	add    $0x10,%esp
f0102d56:	85 c0                	test   %eax,%eax
f0102d58:	74 05                	je     f0102d5f <env_alloc+0xeb>
f0102d5a:	8b 40 48             	mov    0x48(%eax),%eax
f0102d5d:	eb 05                	jmp    f0102d64 <env_alloc+0xf0>
f0102d5f:	b8 00 00 00 00       	mov    $0x0,%eax
f0102d64:	83 ec 04             	sub    $0x4,%esp
f0102d67:	52                   	push   %edx
f0102d68:	50                   	push   %eax
f0102d69:	68 e5 56 10 f0       	push   $0xf01056e5
f0102d6e:	e8 b7 02 00 00       	call   f010302a <cprintf>
	return 0;
f0102d73:	83 c4 10             	add    $0x10,%esp
f0102d76:	b8 00 00 00 00       	mov    $0x0,%eax
f0102d7b:	eb 0c                	jmp    f0102d89 <env_alloc+0x115>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
		return -E_NO_FREE_ENV;
f0102d7d:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f0102d82:	eb 05                	jmp    f0102d89 <env_alloc+0x115>
	int i;
	struct Page *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
		return -E_NO_MEM;
f0102d84:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	env_free_list = e->env_link;
	*newenv_store = e;

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}
f0102d89:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0102d8c:	c9                   	leave  
f0102d8d:	c3                   	ret    

f0102d8e <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, size_t size, enum EnvType type)
{
f0102d8e:	55                   	push   %ebp
f0102d8f:	89 e5                	mov    %esp,%ebp
	// LAB 3: Your code here.
}
f0102d91:	5d                   	pop    %ebp
f0102d92:	c3                   	ret    

f0102d93 <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f0102d93:	55                   	push   %ebp
f0102d94:	89 e5                	mov    %esp,%ebp
f0102d96:	57                   	push   %edi
f0102d97:	56                   	push   %esi
f0102d98:	53                   	push   %ebx
f0102d99:	83 ec 1c             	sub    $0x1c,%esp
f0102d9c:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f0102d9f:	8b 15 a4 f4 18 f0    	mov    0xf018f4a4,%edx
f0102da5:	39 fa                	cmp    %edi,%edx
f0102da7:	75 29                	jne    f0102dd2 <env_free+0x3f>
		lcr3(PADDR(kern_pgdir));
f0102da9:	a1 68 01 19 f0       	mov    0xf0190168,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102dae:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102db3:	77 15                	ja     f0102dca <env_free+0x37>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102db5:	50                   	push   %eax
f0102db6:	68 c8 4d 10 f0       	push   $0xf0104dc8
f0102dbb:	68 68 01 00 00       	push   $0x168
f0102dc0:	68 da 56 10 f0       	push   $0xf01056da
f0102dc5:	e8 01 d3 ff ff       	call   f01000cb <_panic>
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0102dca:	05 00 00 00 10       	add    $0x10000000,%eax
f0102dcf:	0f 22 d8             	mov    %eax,%cr3

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0102dd2:	8b 4f 48             	mov    0x48(%edi),%ecx
f0102dd5:	85 d2                	test   %edx,%edx
f0102dd7:	74 05                	je     f0102dde <env_free+0x4b>
f0102dd9:	8b 42 48             	mov    0x48(%edx),%eax
f0102ddc:	eb 05                	jmp    f0102de3 <env_free+0x50>
f0102dde:	b8 00 00 00 00       	mov    $0x0,%eax
f0102de3:	83 ec 04             	sub    $0x4,%esp
f0102de6:	51                   	push   %ecx
f0102de7:	50                   	push   %eax
f0102de8:	68 fa 56 10 f0       	push   $0xf01056fa
f0102ded:	e8 38 02 00 00       	call   f010302a <cprintf>
f0102df2:	83 c4 10             	add    $0x10,%esp

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0102df5:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0102dfc:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0102dff:	89 d0                	mov    %edx,%eax
f0102e01:	c1 e0 02             	shl    $0x2,%eax
f0102e04:	89 45 dc             	mov    %eax,-0x24(%ebp)

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f0102e07:	8b 47 5c             	mov    0x5c(%edi),%eax
f0102e0a:	8b 34 90             	mov    (%eax,%edx,4),%esi
f0102e0d:	f7 c6 01 00 00 00    	test   $0x1,%esi
f0102e13:	0f 84 a8 00 00 00    	je     f0102ec1 <env_free+0x12e>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0102e19:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102e1f:	89 f0                	mov    %esi,%eax
f0102e21:	c1 e8 0c             	shr    $0xc,%eax
f0102e24:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0102e27:	39 05 64 01 19 f0    	cmp    %eax,0xf0190164
f0102e2d:	77 15                	ja     f0102e44 <env_free+0xb1>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102e2f:	56                   	push   %esi
f0102e30:	68 70 4b 10 f0       	push   $0xf0104b70
f0102e35:	68 77 01 00 00       	push   $0x177
f0102e3a:	68 da 56 10 f0       	push   $0xf01056da
f0102e3f:	e8 87 d2 ff ff       	call   f01000cb <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0102e44:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102e47:	c1 e0 16             	shl    $0x16,%eax
f0102e4a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0102e4d:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f0102e52:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f0102e59:	01 
f0102e5a:	74 17                	je     f0102e73 <env_free+0xe0>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0102e5c:	83 ec 08             	sub    $0x8,%esp
f0102e5f:	89 d8                	mov    %ebx,%eax
f0102e61:	c1 e0 0c             	shl    $0xc,%eax
f0102e64:	0b 45 e4             	or     -0x1c(%ebp),%eax
f0102e67:	50                   	push   %eax
f0102e68:	ff 77 5c             	pushl  0x5c(%edi)
f0102e6b:	e8 03 e5 ff ff       	call   f0101373 <page_remove>
f0102e70:	83 c4 10             	add    $0x10,%esp
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0102e73:	83 c3 01             	add    $0x1,%ebx
f0102e76:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f0102e7c:	75 d4                	jne    f0102e52 <env_free+0xbf>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f0102e7e:	8b 47 5c             	mov    0x5c(%edi),%eax
f0102e81:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0102e84:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102e8b:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0102e8e:	3b 05 64 01 19 f0    	cmp    0xf0190164,%eax
f0102e94:	72 14                	jb     f0102eaa <env_free+0x117>
		panic("pa2page called with invalid pa");
f0102e96:	83 ec 04             	sub    $0x4,%esp
f0102e99:	68 6c 4d 10 f0       	push   $0xf0104d6c
f0102e9e:	6a 4f                	push   $0x4f
f0102ea0:	68 d5 53 10 f0       	push   $0xf01053d5
f0102ea5:	e8 21 d2 ff ff       	call   f01000cb <_panic>
		page_decref(pa2page(pa));
f0102eaa:	83 ec 0c             	sub    $0xc,%esp
f0102ead:	a1 6c 01 19 f0       	mov    0xf019016c,%eax
f0102eb2:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0102eb5:	8d 04 d0             	lea    (%eax,%edx,8),%eax
f0102eb8:	50                   	push   %eax
f0102eb9:	e8 25 e3 ff ff       	call   f01011e3 <page_decref>
f0102ebe:	83 c4 10             	add    $0x10,%esp
	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0102ec1:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
f0102ec5:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102ec8:	3d bb 03 00 00       	cmp    $0x3bb,%eax
f0102ecd:	0f 85 29 ff ff ff    	jne    f0102dfc <env_free+0x69>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f0102ed3:	8b 47 5c             	mov    0x5c(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102ed6:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102edb:	77 15                	ja     f0102ef2 <env_free+0x15f>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102edd:	50                   	push   %eax
f0102ede:	68 c8 4d 10 f0       	push   $0xf0104dc8
f0102ee3:	68 85 01 00 00       	push   $0x185
f0102ee8:	68 da 56 10 f0       	push   $0xf01056da
f0102eed:	e8 d9 d1 ff ff       	call   f01000cb <_panic>
	e->env_pgdir = 0;
f0102ef2:	c7 47 5c 00 00 00 00 	movl   $0x0,0x5c(%edi)
}

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102ef9:	05 00 00 00 10       	add    $0x10000000,%eax
f0102efe:	c1 e8 0c             	shr    $0xc,%eax
f0102f01:	3b 05 64 01 19 f0    	cmp    0xf0190164,%eax
f0102f07:	72 14                	jb     f0102f1d <env_free+0x18a>
		panic("pa2page called with invalid pa");
f0102f09:	83 ec 04             	sub    $0x4,%esp
f0102f0c:	68 6c 4d 10 f0       	push   $0xf0104d6c
f0102f11:	6a 4f                	push   $0x4f
f0102f13:	68 d5 53 10 f0       	push   $0xf01053d5
f0102f18:	e8 ae d1 ff ff       	call   f01000cb <_panic>
	page_decref(pa2page(pa));
f0102f1d:	83 ec 0c             	sub    $0xc,%esp
f0102f20:	8b 15 6c 01 19 f0    	mov    0xf019016c,%edx
f0102f26:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f0102f29:	50                   	push   %eax
f0102f2a:	e8 b4 e2 ff ff       	call   f01011e3 <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f0102f2f:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f0102f36:	a1 ac f4 18 f0       	mov    0xf018f4ac,%eax
f0102f3b:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f0102f3e:	89 3d ac f4 18 f0    	mov    %edi,0xf018f4ac
}
f0102f44:	83 c4 10             	add    $0x10,%esp
f0102f47:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102f4a:	5b                   	pop    %ebx
f0102f4b:	5e                   	pop    %esi
f0102f4c:	5f                   	pop    %edi
f0102f4d:	5d                   	pop    %ebp
f0102f4e:	c3                   	ret    

f0102f4f <env_destroy>:
//
// Frees environment e.
//
void
env_destroy(struct Env *e)
{
f0102f4f:	55                   	push   %ebp
f0102f50:	89 e5                	mov    %esp,%ebp
f0102f52:	83 ec 14             	sub    $0x14,%esp
	env_free(e);
f0102f55:	ff 75 08             	pushl  0x8(%ebp)
f0102f58:	e8 36 fe ff ff       	call   f0102d93 <env_free>

	cprintf("Destroyed the only environment - nothing more to do!\n");
f0102f5d:	c7 04 24 a4 56 10 f0 	movl   $0xf01056a4,(%esp)
f0102f64:	e8 c1 00 00 00       	call   f010302a <cprintf>
f0102f69:	83 c4 10             	add    $0x10,%esp
	while (1)
		monitor(NULL);
f0102f6c:	83 ec 0c             	sub    $0xc,%esp
f0102f6f:	6a 00                	push   $0x0
f0102f71:	e8 3a dc ff ff       	call   f0100bb0 <monitor>
f0102f76:	83 c4 10             	add    $0x10,%esp
f0102f79:	eb f1                	jmp    f0102f6c <env_destroy+0x1d>

f0102f7b <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f0102f7b:	55                   	push   %ebp
f0102f7c:	89 e5                	mov    %esp,%ebp
f0102f7e:	83 ec 0c             	sub    $0xc,%esp
	__asm __volatile("movl %0,%%esp\n"
f0102f81:	8b 65 08             	mov    0x8(%ebp),%esp
f0102f84:	61                   	popa   
f0102f85:	07                   	pop    %es
f0102f86:	1f                   	pop    %ds
f0102f87:	83 c4 08             	add    $0x8,%esp
f0102f8a:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f0102f8b:	68 10 57 10 f0       	push   $0xf0105710
f0102f90:	68 ad 01 00 00       	push   $0x1ad
f0102f95:	68 da 56 10 f0       	push   $0xf01056da
f0102f9a:	e8 2c d1 ff ff       	call   f01000cb <_panic>

f0102f9f <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f0102f9f:	55                   	push   %ebp
f0102fa0:	89 e5                	mov    %esp,%ebp
f0102fa2:	83 ec 0c             	sub    $0xc,%esp
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.

	panic("env_run not yet implemented");
f0102fa5:	68 1c 57 10 f0       	push   $0xf010571c
f0102faa:	68 cc 01 00 00       	push   $0x1cc
f0102faf:	68 da 56 10 f0       	push   $0xf01056da
f0102fb4:	e8 12 d1 ff ff       	call   f01000cb <_panic>

f0102fb9 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0102fb9:	55                   	push   %ebp
f0102fba:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0102fbc:	ba 70 00 00 00       	mov    $0x70,%edx
f0102fc1:	8b 45 08             	mov    0x8(%ebp),%eax
f0102fc4:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0102fc5:	ba 71 00 00 00       	mov    $0x71,%edx
f0102fca:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0102fcb:	0f b6 c0             	movzbl %al,%eax
}
f0102fce:	5d                   	pop    %ebp
f0102fcf:	c3                   	ret    

f0102fd0 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0102fd0:	55                   	push   %ebp
f0102fd1:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0102fd3:	ba 70 00 00 00       	mov    $0x70,%edx
f0102fd8:	8b 45 08             	mov    0x8(%ebp),%eax
f0102fdb:	ee                   	out    %al,(%dx)
f0102fdc:	ba 71 00 00 00       	mov    $0x71,%edx
f0102fe1:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102fe4:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0102fe5:	5d                   	pop    %ebp
f0102fe6:	c3                   	ret    

f0102fe7 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0102fe7:	55                   	push   %ebp
f0102fe8:	89 e5                	mov    %esp,%ebp
f0102fea:	53                   	push   %ebx
f0102feb:	83 ec 10             	sub    $0x10,%esp
f0102fee:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	cputchar(ch);
f0102ff1:	ff 75 08             	pushl  0x8(%ebp)
f0102ff4:	e8 4d d6 ff ff       	call   f0100646 <cputchar>
    (*cnt)++;
f0102ff9:	83 03 01             	addl   $0x1,(%ebx)
}
f0102ffc:	83 c4 10             	add    $0x10,%esp
f0102fff:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103002:	c9                   	leave  
f0103003:	c3                   	ret    

f0103004 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0103004:	55                   	push   %ebp
f0103005:	89 e5                	mov    %esp,%ebp
f0103007:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f010300a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0103011:	ff 75 0c             	pushl  0xc(%ebp)
f0103014:	ff 75 08             	pushl  0x8(%ebp)
f0103017:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010301a:	50                   	push   %eax
f010301b:	68 e7 2f 10 f0       	push   $0xf0102fe7
f0103020:	e8 63 09 00 00       	call   f0103988 <vprintfmt>
	return cnt;
}
f0103025:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103028:	c9                   	leave  
f0103029:	c3                   	ret    

f010302a <cprintf>:

int
cprintf(const char *fmt, ...)
{
f010302a:	55                   	push   %ebp
f010302b:	89 e5                	mov    %esp,%ebp
f010302d:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0103030:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0103033:	50                   	push   %eax
f0103034:	ff 75 08             	pushl  0x8(%ebp)
f0103037:	e8 c8 ff ff ff       	call   f0103004 <vcprintf>
	va_end(ap);

	return cnt;
}
f010303c:	c9                   	leave  
f010303d:	c3                   	ret    

f010303e <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f010303e:	55                   	push   %ebp
f010303f:	89 e5                	mov    %esp,%ebp
	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	ts.ts_esp0 = KSTACKTOP;
f0103041:	b8 e0 fc 18 f0       	mov    $0xf018fce0,%eax
f0103046:	c7 05 e4 fc 18 f0 00 	movl   $0xefc00000,0xf018fce4
f010304d:	00 c0 ef 
	ts.ts_ss0 = GD_KD;
f0103050:	66 c7 05 e8 fc 18 f0 	movw   $0x10,0xf018fce8
f0103057:	10 00 

	// Initialize the TSS slot of the gdt.
	gdt[GD_TSS0 >> 3] = SEG16(STS_T32A, (uint32_t) (&ts),
f0103059:	66 c7 05 48 b3 11 f0 	movw   $0x68,0xf011b348
f0103060:	68 00 
f0103062:	66 a3 4a b3 11 f0    	mov    %ax,0xf011b34a
f0103068:	89 c2                	mov    %eax,%edx
f010306a:	c1 ea 10             	shr    $0x10,%edx
f010306d:	88 15 4c b3 11 f0    	mov    %dl,0xf011b34c
f0103073:	c6 05 4e b3 11 f0 40 	movb   $0x40,0xf011b34e
f010307a:	c1 e8 18             	shr    $0x18,%eax
f010307d:	a2 4f b3 11 f0       	mov    %al,0xf011b34f
					sizeof(struct Taskstate), 0);
	gdt[GD_TSS0 >> 3].sd_s = 0;
f0103082:	c6 05 4d b3 11 f0 89 	movb   $0x89,0xf011b34d
}

static __inline void
ltr(uint16_t sel)
{
	__asm __volatile("ltr %0" : : "r" (sel));
f0103089:	b8 28 00 00 00       	mov    $0x28,%eax
f010308e:	0f 00 d8             	ltr    %ax
}  

static __inline void
lidt(void *p)
{
	__asm __volatile("lidt (%0)" : : "r" (p));
f0103091:	b8 50 b3 11 f0       	mov    $0xf011b350,%eax
f0103096:	0f 01 18             	lidtl  (%eax)
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0);

	// Load the IDT
	lidt(&idt_pd);
}
f0103099:	5d                   	pop    %ebp
f010309a:	c3                   	ret    

f010309b <trap_init>:
}


void
trap_init(void)
{
f010309b:	55                   	push   %ebp
f010309c:	89 e5                	mov    %esp,%ebp
	extern struct Segdesc gdt[];

	// LAB 3: Your code here.

	// Per-CPU setup 
	trap_init_percpu();
f010309e:	e8 9b ff ff ff       	call   f010303e <trap_init_percpu>
}
f01030a3:	5d                   	pop    %ebp
f01030a4:	c3                   	ret    

f01030a5 <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f01030a5:	55                   	push   %ebp
f01030a6:	89 e5                	mov    %esp,%ebp
f01030a8:	53                   	push   %ebx
f01030a9:	83 ec 0c             	sub    $0xc,%esp
f01030ac:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f01030af:	ff 33                	pushl  (%ebx)
f01030b1:	68 38 57 10 f0       	push   $0xf0105738
f01030b6:	e8 6f ff ff ff       	call   f010302a <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f01030bb:	83 c4 08             	add    $0x8,%esp
f01030be:	ff 73 04             	pushl  0x4(%ebx)
f01030c1:	68 47 57 10 f0       	push   $0xf0105747
f01030c6:	e8 5f ff ff ff       	call   f010302a <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f01030cb:	83 c4 08             	add    $0x8,%esp
f01030ce:	ff 73 08             	pushl  0x8(%ebx)
f01030d1:	68 56 57 10 f0       	push   $0xf0105756
f01030d6:	e8 4f ff ff ff       	call   f010302a <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f01030db:	83 c4 08             	add    $0x8,%esp
f01030de:	ff 73 0c             	pushl  0xc(%ebx)
f01030e1:	68 65 57 10 f0       	push   $0xf0105765
f01030e6:	e8 3f ff ff ff       	call   f010302a <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f01030eb:	83 c4 08             	add    $0x8,%esp
f01030ee:	ff 73 10             	pushl  0x10(%ebx)
f01030f1:	68 74 57 10 f0       	push   $0xf0105774
f01030f6:	e8 2f ff ff ff       	call   f010302a <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f01030fb:	83 c4 08             	add    $0x8,%esp
f01030fe:	ff 73 14             	pushl  0x14(%ebx)
f0103101:	68 83 57 10 f0       	push   $0xf0105783
f0103106:	e8 1f ff ff ff       	call   f010302a <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f010310b:	83 c4 08             	add    $0x8,%esp
f010310e:	ff 73 18             	pushl  0x18(%ebx)
f0103111:	68 92 57 10 f0       	push   $0xf0105792
f0103116:	e8 0f ff ff ff       	call   f010302a <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f010311b:	83 c4 08             	add    $0x8,%esp
f010311e:	ff 73 1c             	pushl  0x1c(%ebx)
f0103121:	68 a1 57 10 f0       	push   $0xf01057a1
f0103126:	e8 ff fe ff ff       	call   f010302a <cprintf>
}
f010312b:	83 c4 10             	add    $0x10,%esp
f010312e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103131:	c9                   	leave  
f0103132:	c3                   	ret    

f0103133 <print_trapframe>:
	lidt(&idt_pd);
}

void
print_trapframe(struct Trapframe *tf)
{
f0103133:	55                   	push   %ebp
f0103134:	89 e5                	mov    %esp,%ebp
f0103136:	56                   	push   %esi
f0103137:	53                   	push   %ebx
f0103138:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p\n", tf);
f010313b:	83 ec 08             	sub    $0x8,%esp
f010313e:	53                   	push   %ebx
f010313f:	68 d7 58 10 f0       	push   $0xf01058d7
f0103144:	e8 e1 fe ff ff       	call   f010302a <cprintf>
	print_regs(&tf->tf_regs);
f0103149:	89 1c 24             	mov    %ebx,(%esp)
f010314c:	e8 54 ff ff ff       	call   f01030a5 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0103151:	83 c4 08             	add    $0x8,%esp
f0103154:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f0103158:	50                   	push   %eax
f0103159:	68 f2 57 10 f0       	push   $0xf01057f2
f010315e:	e8 c7 fe ff ff       	call   f010302a <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f0103163:	83 c4 08             	add    $0x8,%esp
f0103166:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f010316a:	50                   	push   %eax
f010316b:	68 05 58 10 f0       	push   $0xf0105805
f0103170:	e8 b5 fe ff ff       	call   f010302a <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103175:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
f0103178:	83 c4 10             	add    $0x10,%esp
f010317b:	83 f8 13             	cmp    $0x13,%eax
f010317e:	77 09                	ja     f0103189 <print_trapframe+0x56>
		return excnames[trapno];
f0103180:	8b 14 85 a0 5a 10 f0 	mov    -0xfefa560(,%eax,4),%edx
f0103187:	eb 10                	jmp    f0103199 <print_trapframe+0x66>
	if (trapno == T_SYSCALL)
		return "System call";
	return "(unknown trap)";
f0103189:	83 f8 30             	cmp    $0x30,%eax
f010318c:	b9 bc 57 10 f0       	mov    $0xf01057bc,%ecx
f0103191:	ba b0 57 10 f0       	mov    $0xf01057b0,%edx
f0103196:	0f 45 d1             	cmovne %ecx,%edx
{
	cprintf("TRAP frame at %p\n", tf);
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103199:	83 ec 04             	sub    $0x4,%esp
f010319c:	52                   	push   %edx
f010319d:	50                   	push   %eax
f010319e:	68 18 58 10 f0       	push   $0xf0105818
f01031a3:	e8 82 fe ff ff       	call   f010302a <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f01031a8:	83 c4 10             	add    $0x10,%esp
f01031ab:	3b 1d c0 fc 18 f0    	cmp    0xf018fcc0,%ebx
f01031b1:	75 1a                	jne    f01031cd <print_trapframe+0x9a>
f01031b3:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f01031b7:	75 14                	jne    f01031cd <print_trapframe+0x9a>

static __inline uint32_t
rcr2(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
f01031b9:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f01031bc:	83 ec 08             	sub    $0x8,%esp
f01031bf:	50                   	push   %eax
f01031c0:	68 2a 58 10 f0       	push   $0xf010582a
f01031c5:	e8 60 fe ff ff       	call   f010302a <cprintf>
f01031ca:	83 c4 10             	add    $0x10,%esp
	cprintf("  err  0x%08x", tf->tf_err);
f01031cd:	83 ec 08             	sub    $0x8,%esp
f01031d0:	ff 73 2c             	pushl  0x2c(%ebx)
f01031d3:	68 39 58 10 f0       	push   $0xf0105839
f01031d8:	e8 4d fe ff ff       	call   f010302a <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f01031dd:	83 c4 10             	add    $0x10,%esp
f01031e0:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f01031e4:	75 49                	jne    f010322f <print_trapframe+0xfc>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f01031e6:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f01031e9:	89 c2                	mov    %eax,%edx
f01031eb:	83 e2 01             	and    $0x1,%edx
f01031ee:	ba d6 57 10 f0       	mov    $0xf01057d6,%edx
f01031f3:	b9 cb 57 10 f0       	mov    $0xf01057cb,%ecx
f01031f8:	0f 44 ca             	cmove  %edx,%ecx
f01031fb:	89 c2                	mov    %eax,%edx
f01031fd:	83 e2 02             	and    $0x2,%edx
f0103200:	ba e8 57 10 f0       	mov    $0xf01057e8,%edx
f0103205:	be e2 57 10 f0       	mov    $0xf01057e2,%esi
f010320a:	0f 45 d6             	cmovne %esi,%edx
f010320d:	83 e0 04             	and    $0x4,%eax
f0103210:	be 02 59 10 f0       	mov    $0xf0105902,%esi
f0103215:	b8 ed 57 10 f0       	mov    $0xf01057ed,%eax
f010321a:	0f 44 c6             	cmove  %esi,%eax
f010321d:	51                   	push   %ecx
f010321e:	52                   	push   %edx
f010321f:	50                   	push   %eax
f0103220:	68 47 58 10 f0       	push   $0xf0105847
f0103225:	e8 00 fe ff ff       	call   f010302a <cprintf>
f010322a:	83 c4 10             	add    $0x10,%esp
f010322d:	eb 10                	jmp    f010323f <print_trapframe+0x10c>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f010322f:	83 ec 0c             	sub    $0xc,%esp
f0103232:	68 59 56 10 f0       	push   $0xf0105659
f0103237:	e8 ee fd ff ff       	call   f010302a <cprintf>
f010323c:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f010323f:	83 ec 08             	sub    $0x8,%esp
f0103242:	ff 73 30             	pushl  0x30(%ebx)
f0103245:	68 56 58 10 f0       	push   $0xf0105856
f010324a:	e8 db fd ff ff       	call   f010302a <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f010324f:	83 c4 08             	add    $0x8,%esp
f0103252:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f0103256:	50                   	push   %eax
f0103257:	68 65 58 10 f0       	push   $0xf0105865
f010325c:	e8 c9 fd ff ff       	call   f010302a <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f0103261:	83 c4 08             	add    $0x8,%esp
f0103264:	ff 73 38             	pushl  0x38(%ebx)
f0103267:	68 78 58 10 f0       	push   $0xf0105878
f010326c:	e8 b9 fd ff ff       	call   f010302a <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f0103271:	83 c4 10             	add    $0x10,%esp
f0103274:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0103278:	74 25                	je     f010329f <print_trapframe+0x16c>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f010327a:	83 ec 08             	sub    $0x8,%esp
f010327d:	ff 73 3c             	pushl  0x3c(%ebx)
f0103280:	68 87 58 10 f0       	push   $0xf0105887
f0103285:	e8 a0 fd ff ff       	call   f010302a <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f010328a:	83 c4 08             	add    $0x8,%esp
f010328d:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f0103291:	50                   	push   %eax
f0103292:	68 96 58 10 f0       	push   $0xf0105896
f0103297:	e8 8e fd ff ff       	call   f010302a <cprintf>
f010329c:	83 c4 10             	add    $0x10,%esp
	}
}
f010329f:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01032a2:	5b                   	pop    %ebx
f01032a3:	5e                   	pop    %esi
f01032a4:	5d                   	pop    %ebp
f01032a5:	c3                   	ret    

f01032a6 <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f01032a6:	55                   	push   %ebp
f01032a7:	89 e5                	mov    %esp,%ebp
f01032a9:	57                   	push   %edi
f01032aa:	56                   	push   %esi
f01032ab:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f01032ae:	fc                   	cld    

static __inline uint32_t
read_eflags(void)
{
        uint32_t eflags;
        __asm __volatile("pushfl; popl %0" : "=r" (eflags));
f01032af:	9c                   	pushf  
f01032b0:	58                   	pop    %eax

	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f01032b1:	f6 c4 02             	test   $0x2,%ah
f01032b4:	74 19                	je     f01032cf <trap+0x29>
f01032b6:	68 a9 58 10 f0       	push   $0xf01058a9
f01032bb:	68 ef 53 10 f0       	push   $0xf01053ef
f01032c0:	68 a7 00 00 00       	push   $0xa7
f01032c5:	68 c2 58 10 f0       	push   $0xf01058c2
f01032ca:	e8 fc cd ff ff       	call   f01000cb <_panic>

	cprintf("Incoming TRAP frame at %p\n", tf);
f01032cf:	83 ec 08             	sub    $0x8,%esp
f01032d2:	56                   	push   %esi
f01032d3:	68 ce 58 10 f0       	push   $0xf01058ce
f01032d8:	e8 4d fd ff ff       	call   f010302a <cprintf>

	if ((tf->tf_cs & 3) == 3) {
f01032dd:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f01032e1:	83 e0 03             	and    $0x3,%eax
f01032e4:	83 c4 10             	add    $0x10,%esp
f01032e7:	66 83 f8 03          	cmp    $0x3,%ax
f01032eb:	75 31                	jne    f010331e <trap+0x78>
		// Trapped from user mode.
		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		assert(curenv);
f01032ed:	a1 a4 f4 18 f0       	mov    0xf018f4a4,%eax
f01032f2:	85 c0                	test   %eax,%eax
f01032f4:	75 19                	jne    f010330f <trap+0x69>
f01032f6:	68 e9 58 10 f0       	push   $0xf01058e9
f01032fb:	68 ef 53 10 f0       	push   $0xf01053ef
f0103300:	68 b0 00 00 00       	push   $0xb0
f0103305:	68 c2 58 10 f0       	push   $0xf01058c2
f010330a:	e8 bc cd ff ff       	call   f01000cb <_panic>
		curenv->env_tf = *tf;
f010330f:	b9 11 00 00 00       	mov    $0x11,%ecx
f0103314:	89 c7                	mov    %eax,%edi
f0103316:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f0103318:	8b 35 a4 f4 18 f0    	mov    0xf018f4a4,%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f010331e:	89 35 c0 fc 18 f0    	mov    %esi,0xf018fcc0
{
	// Handle processor exceptions.
	// LAB 3: Your code here.

	// Unexpected trap: The user process or the kernel has a bug.
	print_trapframe(tf);
f0103324:	83 ec 0c             	sub    $0xc,%esp
f0103327:	56                   	push   %esi
f0103328:	e8 06 fe ff ff       	call   f0103133 <print_trapframe>
	if (tf->tf_cs == GD_KT)
f010332d:	83 c4 10             	add    $0x10,%esp
f0103330:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f0103335:	75 17                	jne    f010334e <trap+0xa8>
		panic("unhandled trap in kernel");
f0103337:	83 ec 04             	sub    $0x4,%esp
f010333a:	68 f0 58 10 f0       	push   $0xf01058f0
f010333f:	68 96 00 00 00       	push   $0x96
f0103344:	68 c2 58 10 f0       	push   $0xf01058c2
f0103349:	e8 7d cd ff ff       	call   f01000cb <_panic>
	else {
		env_destroy(curenv);
f010334e:	83 ec 0c             	sub    $0xc,%esp
f0103351:	ff 35 a4 f4 18 f0    	pushl  0xf018f4a4
f0103357:	e8 f3 fb ff ff       	call   f0102f4f <env_destroy>

	// Dispatch based on what type of trap occurred
	trap_dispatch(tf);

	// Return to the current environment, which should be running.
	assert(curenv && curenv->env_status == ENV_RUNNING);
f010335c:	a1 a4 f4 18 f0       	mov    0xf018f4a4,%eax
f0103361:	83 c4 10             	add    $0x10,%esp
f0103364:	85 c0                	test   %eax,%eax
f0103366:	74 06                	je     f010336e <trap+0xc8>
f0103368:	83 78 54 02          	cmpl   $0x2,0x54(%eax)
f010336c:	74 19                	je     f0103387 <trap+0xe1>
f010336e:	68 4c 5a 10 f0       	push   $0xf0105a4c
f0103373:	68 ef 53 10 f0       	push   $0xf01053ef
f0103378:	68 be 00 00 00       	push   $0xbe
f010337d:	68 c2 58 10 f0       	push   $0xf01058c2
f0103382:	e8 44 cd ff ff       	call   f01000cb <_panic>
	env_run(curenv);
f0103387:	83 ec 0c             	sub    $0xc,%esp
f010338a:	50                   	push   %eax
f010338b:	e8 0f fc ff ff       	call   f0102f9f <env_run>

f0103390 <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f0103390:	55                   	push   %ebp
f0103391:	89 e5                	mov    %esp,%ebp
f0103393:	53                   	push   %ebx
f0103394:	83 ec 04             	sub    $0x4,%esp
f0103397:	8b 5d 08             	mov    0x8(%ebp),%ebx

static __inline uint32_t
rcr2(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
f010339a:	0f 20 d0             	mov    %cr2,%eax

	// We've already handled kernel-mode exceptions, so if we get here,
	// the page fault happened in user mode.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f010339d:	ff 73 30             	pushl  0x30(%ebx)
f01033a0:	50                   	push   %eax
f01033a1:	a1 a4 f4 18 f0       	mov    0xf018f4a4,%eax
f01033a6:	ff 70 48             	pushl  0x48(%eax)
f01033a9:	68 78 5a 10 f0       	push   $0xf0105a78
f01033ae:	e8 77 fc ff ff       	call   f010302a <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f01033b3:	89 1c 24             	mov    %ebx,(%esp)
f01033b6:	e8 78 fd ff ff       	call   f0103133 <print_trapframe>
	env_destroy(curenv);
f01033bb:	83 c4 04             	add    $0x4,%esp
f01033be:	ff 35 a4 f4 18 f0    	pushl  0xf018f4a4
f01033c4:	e8 86 fb ff ff       	call   f0102f4f <env_destroy>
}
f01033c9:	83 c4 10             	add    $0x10,%esp
f01033cc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01033cf:	c9                   	leave  
f01033d0:	c3                   	ret    
f01033d1:	90                   	nop

f01033d2 <syscall>:
f01033d2:	55                   	push   %ebp
f01033d3:	89 e5                	mov    %esp,%ebp
f01033d5:	83 ec 0c             	sub    $0xc,%esp
f01033d8:	68 f0 5a 10 f0       	push   $0xf0105af0
f01033dd:	6a 5b                	push   $0x5b
f01033df:	68 08 5b 10 f0       	push   $0xf0105b08
f01033e4:	e8 e2 cc ff ff       	call   f01000cb <_panic>

f01033e9 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f01033e9:	55                   	push   %ebp
f01033ea:	89 e5                	mov    %esp,%ebp
f01033ec:	57                   	push   %edi
f01033ed:	56                   	push   %esi
f01033ee:	53                   	push   %ebx
f01033ef:	83 ec 14             	sub    $0x14,%esp
f01033f2:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01033f5:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f01033f8:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f01033fb:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f01033fe:	8b 1a                	mov    (%edx),%ebx
f0103400:	8b 01                	mov    (%ecx),%eax
f0103402:	89 45 f0             	mov    %eax,-0x10(%ebp)
	
	while (l <= r) {
f0103405:	39 c3                	cmp    %eax,%ebx
f0103407:	0f 8f 9a 00 00 00    	jg     f01034a7 <stab_binsearch+0xbe>
f010340d:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
		int true_m = (l + r) / 2, m = true_m;
f0103414:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0103417:	01 d8                	add    %ebx,%eax
f0103419:	89 c6                	mov    %eax,%esi
f010341b:	c1 ee 1f             	shr    $0x1f,%esi
f010341e:	01 c6                	add    %eax,%esi
f0103420:	d1 fe                	sar    %esi
		
		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0103422:	39 de                	cmp    %ebx,%esi
f0103424:	0f 8c c4 00 00 00    	jl     f01034ee <stab_binsearch+0x105>
f010342a:	8d 04 76             	lea    (%esi,%esi,2),%eax
f010342d:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0103430:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f0103433:	0f b6 42 04          	movzbl 0x4(%edx),%eax
f0103437:	39 c7                	cmp    %eax,%edi
f0103439:	0f 84 b4 00 00 00    	je     f01034f3 <stab_binsearch+0x10a>
f010343f:	89 f0                	mov    %esi,%eax
			m--;
f0103441:	83 e8 01             	sub    $0x1,%eax
	
	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
		
		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0103444:	39 d8                	cmp    %ebx,%eax
f0103446:	0f 8c a2 00 00 00    	jl     f01034ee <stab_binsearch+0x105>
f010344c:	0f b6 4a f8          	movzbl -0x8(%edx),%ecx
f0103450:	83 ea 0c             	sub    $0xc,%edx
f0103453:	39 f9                	cmp    %edi,%ecx
f0103455:	75 ea                	jne    f0103441 <stab_binsearch+0x58>
f0103457:	e9 99 00 00 00       	jmp    f01034f5 <stab_binsearch+0x10c>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f010345c:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f010345f:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f0103461:	8d 5e 01             	lea    0x1(%esi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0103464:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f010346b:	eb 2b                	jmp    f0103498 <stab_binsearch+0xaf>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f010346d:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0103470:	76 14                	jbe    f0103486 <stab_binsearch+0x9d>
			*region_right = m - 1;
f0103472:	83 e8 01             	sub    $0x1,%eax
f0103475:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0103478:	8b 75 e0             	mov    -0x20(%ebp),%esi
f010347b:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f010347d:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0103484:	eb 12                	jmp    f0103498 <stab_binsearch+0xaf>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0103486:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0103489:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f010348b:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f010348f:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0103491:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;
	
	while (l <= r) {
f0103498:	39 5d f0             	cmp    %ebx,-0x10(%ebp)
f010349b:	0f 8d 73 ff ff ff    	jge    f0103414 <stab_binsearch+0x2b>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f01034a1:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f01034a5:	75 0f                	jne    f01034b6 <stab_binsearch+0xcd>
		*region_right = *region_left - 1;
f01034a7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01034aa:	8b 00                	mov    (%eax),%eax
f01034ac:	83 e8 01             	sub    $0x1,%eax
f01034af:	8b 7d e0             	mov    -0x20(%ebp),%edi
f01034b2:	89 07                	mov    %eax,(%edi)
f01034b4:	eb 57                	jmp    f010350d <stab_binsearch+0x124>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01034b6:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01034b9:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f01034bb:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01034be:	8b 0e                	mov    (%esi),%ecx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01034c0:	39 c8                	cmp    %ecx,%eax
f01034c2:	7e 23                	jle    f01034e7 <stab_binsearch+0xfe>
		     l > *region_left && stabs[l].n_type != type;
f01034c4:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01034c7:	8b 75 ec             	mov    -0x14(%ebp),%esi
f01034ca:	8d 14 96             	lea    (%esi,%edx,4),%edx
f01034cd:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f01034d1:	39 df                	cmp    %ebx,%edi
f01034d3:	74 12                	je     f01034e7 <stab_binsearch+0xfe>
		     l--)
f01034d5:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01034d8:	39 c8                	cmp    %ecx,%eax
f01034da:	7e 0b                	jle    f01034e7 <stab_binsearch+0xfe>
		     l > *region_left && stabs[l].n_type != type;
f01034dc:	0f b6 5a f8          	movzbl -0x8(%edx),%ebx
f01034e0:	83 ea 0c             	sub    $0xc,%edx
f01034e3:	39 df                	cmp    %ebx,%edi
f01034e5:	75 ee                	jne    f01034d5 <stab_binsearch+0xec>
		     l--)
			/* do nothing */;
		*region_left = l;
f01034e7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01034ea:	89 07                	mov    %eax,(%edi)
	}
}
f01034ec:	eb 1f                	jmp    f010350d <stab_binsearch+0x124>
		
		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f01034ee:	8d 5e 01             	lea    0x1(%esi),%ebx
			continue;
f01034f1:	eb a5                	jmp    f0103498 <stab_binsearch+0xaf>
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;
	
	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f01034f3:	89 f0                	mov    %esi,%eax
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f01034f5:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01034f8:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f01034fb:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f01034ff:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0103502:	0f 82 54 ff ff ff    	jb     f010345c <stab_binsearch+0x73>
f0103508:	e9 60 ff ff ff       	jmp    f010346d <stab_binsearch+0x84>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f010350d:	83 c4 14             	add    $0x14,%esp
f0103510:	5b                   	pop    %ebx
f0103511:	5e                   	pop    %esi
f0103512:	5f                   	pop    %edi
f0103513:	5d                   	pop    %ebp
f0103514:	c3                   	ret    

f0103515 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0103515:	55                   	push   %ebp
f0103516:	89 e5                	mov    %esp,%ebp
f0103518:	57                   	push   %edi
f0103519:	56                   	push   %esi
f010351a:	53                   	push   %ebx
f010351b:	83 ec 3c             	sub    $0x3c,%esp
f010351e:	8b 75 08             	mov    0x8(%ebp),%esi
f0103521:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0103524:	c7 03 17 5b 10 f0    	movl   $0xf0105b17,(%ebx)
	info->eip_line = 0;
f010352a:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0103531:	c7 43 08 17 5b 10 f0 	movl   $0xf0105b17,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0103538:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f010353f:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0103542:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0103549:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f010354f:	77 21                	ja     f0103572 <debuginfo_eip+0x5d>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.

		stabs = usd->stabs;
f0103551:	a1 00 00 20 00       	mov    0x200000,%eax
f0103556:	89 45 bc             	mov    %eax,-0x44(%ebp)
		stab_end = usd->stab_end;
f0103559:	a1 04 00 20 00       	mov    0x200004,%eax
		stabstr = usd->stabstr;
f010355e:	8b 3d 08 00 20 00    	mov    0x200008,%edi
f0103564:	89 7d b8             	mov    %edi,-0x48(%ebp)
		stabstr_end = usd->stabstr_end;
f0103567:	8b 3d 0c 00 20 00    	mov    0x20000c,%edi
f010356d:	89 7d c0             	mov    %edi,-0x40(%ebp)
f0103570:	eb 1a                	jmp    f010358c <debuginfo_eip+0x77>
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f0103572:	c7 45 c0 f9 00 11 f0 	movl   $0xf01100f9,-0x40(%ebp)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
f0103579:	c7 45 b8 d9 d6 10 f0 	movl   $0xf010d6d9,-0x48(%ebp)
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
f0103580:	b8 d8 d6 10 f0       	mov    $0xf010d6d8,%eax
	info->eip_fn_addr = addr;
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
f0103585:	c7 45 bc ac 5d 10 f0 	movl   $0xf0105dac,-0x44(%ebp)
		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f010358c:	8b 7d c0             	mov    -0x40(%ebp),%edi
f010358f:	39 7d b8             	cmp    %edi,-0x48(%ebp)
f0103592:	0f 83 a5 01 00 00    	jae    f010373d <debuginfo_eip+0x228>
f0103598:	80 7f ff 00          	cmpb   $0x0,-0x1(%edi)
f010359c:	0f 85 a2 01 00 00    	jne    f0103744 <debuginfo_eip+0x22f>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.
	
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f01035a2:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f01035a9:	8b 7d bc             	mov    -0x44(%ebp),%edi
f01035ac:	29 f8                	sub    %edi,%eax
f01035ae:	c1 f8 02             	sar    $0x2,%eax
f01035b1:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f01035b7:	83 e8 01             	sub    $0x1,%eax
f01035ba:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f01035bd:	56                   	push   %esi
f01035be:	6a 64                	push   $0x64
f01035c0:	8d 45 e0             	lea    -0x20(%ebp),%eax
f01035c3:	89 c1                	mov    %eax,%ecx
f01035c5:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f01035c8:	89 f8                	mov    %edi,%eax
f01035ca:	e8 1a fe ff ff       	call   f01033e9 <stab_binsearch>
	if (lfile == 0)
f01035cf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01035d2:	83 c4 08             	add    $0x8,%esp
f01035d5:	85 c0                	test   %eax,%eax
f01035d7:	0f 84 6e 01 00 00    	je     f010374b <debuginfo_eip+0x236>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f01035dd:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f01035e0:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01035e3:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f01035e6:	56                   	push   %esi
f01035e7:	6a 24                	push   $0x24
f01035e9:	8d 45 d8             	lea    -0x28(%ebp),%eax
f01035ec:	89 c1                	mov    %eax,%ecx
f01035ee:	8d 55 dc             	lea    -0x24(%ebp),%edx
f01035f1:	89 f8                	mov    %edi,%eax
f01035f3:	e8 f1 fd ff ff       	call   f01033e9 <stab_binsearch>

	if (lfun <= rfun) {
f01035f8:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01035fb:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01035fe:	89 55 c4             	mov    %edx,-0x3c(%ebp)
f0103601:	83 c4 08             	add    $0x8,%esp
f0103604:	39 d0                	cmp    %edx,%eax
f0103606:	7f 2b                	jg     f0103633 <debuginfo_eip+0x11e>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0103608:	8d 14 40             	lea    (%eax,%eax,2),%edx
f010360b:	8d 0c 97             	lea    (%edi,%edx,4),%ecx
f010360e:	8b 11                	mov    (%ecx),%edx
f0103610:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0103613:	2b 7d b8             	sub    -0x48(%ebp),%edi
f0103616:	39 fa                	cmp    %edi,%edx
f0103618:	73 06                	jae    f0103620 <debuginfo_eip+0x10b>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f010361a:	03 55 b8             	add    -0x48(%ebp),%edx
f010361d:	89 53 08             	mov    %edx,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0103620:	8b 51 08             	mov    0x8(%ecx),%edx
f0103623:	89 53 10             	mov    %edx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0103626:	29 d6                	sub    %edx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f0103628:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f010362b:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f010362e:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0103631:	eb 0f                	jmp    f0103642 <debuginfo_eip+0x12d>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0103633:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0103636:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103639:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f010363c:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010363f:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0103642:	83 ec 08             	sub    $0x8,%esp
f0103645:	6a 3a                	push   $0x3a
f0103647:	ff 73 08             	pushl  0x8(%ebx)
f010364a:	e8 0d 0b 00 00       	call   f010415c <strfind>
f010364f:	2b 43 08             	sub    0x8(%ebx),%eax
f0103652:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs,&lline,&rline,N_SLINE,addr);
f0103655:	83 c4 08             	add    $0x8,%esp
f0103658:	56                   	push   %esi
f0103659:	6a 44                	push   $0x44
f010365b:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f010365e:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0103661:	8b 75 bc             	mov    -0x44(%ebp),%esi
f0103664:	89 f0                	mov    %esi,%eax
f0103666:	e8 7e fd ff ff       	call   f01033e9 <stab_binsearch>
	if(lline>rline)
f010366b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010366e:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0103671:	83 c4 10             	add    $0x10,%esp
f0103674:	39 d0                	cmp    %edx,%eax
f0103676:	0f 8f d6 00 00 00    	jg     f0103752 <debuginfo_eip+0x23d>
		return -1;
	info->eip_line=rline;
f010367c:	89 53 04             	mov    %edx,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f010367f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103682:	39 f8                	cmp    %edi,%eax
f0103684:	7c 69                	jl     f01036ef <debuginfo_eip+0x1da>
	       && stabs[lline].n_type != N_SOL
f0103686:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0103689:	8d 34 96             	lea    (%esi,%edx,4),%esi
f010368c:	0f b6 56 04          	movzbl 0x4(%esi),%edx
f0103690:	80 fa 84             	cmp    $0x84,%dl
f0103693:	74 41                	je     f01036d6 <debuginfo_eip+0x1c1>
f0103695:	89 f1                	mov    %esi,%ecx
f0103697:	83 c6 08             	add    $0x8,%esi
f010369a:	c6 45 c4 00          	movb   $0x0,-0x3c(%ebp)
f010369e:	eb 1f                	jmp    f01036bf <debuginfo_eip+0x1aa>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f01036a0:	83 e8 01             	sub    $0x1,%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f01036a3:	39 f8                	cmp    %edi,%eax
f01036a5:	7c 48                	jl     f01036ef <debuginfo_eip+0x1da>
	       && stabs[lline].n_type != N_SOL
f01036a7:	0f b6 51 f8          	movzbl -0x8(%ecx),%edx
f01036ab:	83 e9 0c             	sub    $0xc,%ecx
f01036ae:	83 ee 0c             	sub    $0xc,%esi
f01036b1:	c6 45 c4 01          	movb   $0x1,-0x3c(%ebp)
f01036b5:	80 fa 84             	cmp    $0x84,%dl
f01036b8:	75 05                	jne    f01036bf <debuginfo_eip+0x1aa>
f01036ba:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01036bd:	eb 17                	jmp    f01036d6 <debuginfo_eip+0x1c1>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f01036bf:	80 fa 64             	cmp    $0x64,%dl
f01036c2:	75 dc                	jne    f01036a0 <debuginfo_eip+0x18b>
f01036c4:	83 3e 00             	cmpl   $0x0,(%esi)
f01036c7:	74 d7                	je     f01036a0 <debuginfo_eip+0x18b>
f01036c9:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f01036cd:	74 03                	je     f01036d2 <debuginfo_eip+0x1bd>
f01036cf:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f01036d2:	39 c7                	cmp    %eax,%edi
f01036d4:	7f 19                	jg     f01036ef <debuginfo_eip+0x1da>
f01036d6:	8d 04 40             	lea    (%eax,%eax,2),%eax
f01036d9:	8b 7d bc             	mov    -0x44(%ebp),%edi
f01036dc:	8b 14 87             	mov    (%edi,%eax,4),%edx
f01036df:	8b 45 c0             	mov    -0x40(%ebp),%eax
f01036e2:	8b 7d b8             	mov    -0x48(%ebp),%edi
f01036e5:	29 f8                	sub    %edi,%eax
f01036e7:	39 c2                	cmp    %eax,%edx
f01036e9:	73 04                	jae    f01036ef <debuginfo_eip+0x1da>
		info->eip_file = stabstr + stabs[lline].n_strx;
f01036eb:	01 fa                	add    %edi,%edx
f01036ed:	89 13                	mov    %edx,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f01036ef:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01036f2:	8b 75 d8             	mov    -0x28(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
	
	return 0;
f01036f5:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f01036fa:	39 f2                	cmp    %esi,%edx
f01036fc:	7d 6e                	jge    f010376c <debuginfo_eip+0x257>
		for (lline = lfun + 1;
f01036fe:	8d 42 01             	lea    0x1(%edx),%eax
f0103701:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0103704:	39 c6                	cmp    %eax,%esi
f0103706:	7e 51                	jle    f0103759 <debuginfo_eip+0x244>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0103708:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f010370b:	c1 e1 02             	shl    $0x2,%ecx
f010370e:	8b 7d bc             	mov    -0x44(%ebp),%edi
f0103711:	80 7c 0f 04 a0       	cmpb   $0xa0,0x4(%edi,%ecx,1)
f0103716:	75 48                	jne    f0103760 <debuginfo_eip+0x24b>
f0103718:	8d 42 02             	lea    0x2(%edx),%eax
f010371b:	8d 54 0f f4          	lea    -0xc(%edi,%ecx,1),%edx
		     lline++)
			info->eip_fn_narg++;
f010371f:	83 43 14 01          	addl   $0x1,0x14(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0103723:	39 c6                	cmp    %eax,%esi
f0103725:	74 40                	je     f0103767 <debuginfo_eip+0x252>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0103727:	0f b6 4a 1c          	movzbl 0x1c(%edx),%ecx
f010372b:	83 c0 01             	add    $0x1,%eax
f010372e:	83 c2 0c             	add    $0xc,%edx
f0103731:	80 f9 a0             	cmp    $0xa0,%cl
f0103734:	74 e9                	je     f010371f <debuginfo_eip+0x20a>
		     lline++)
			info->eip_fn_narg++;
	
	return 0;
f0103736:	b8 00 00 00 00       	mov    $0x0,%eax
f010373b:	eb 2f                	jmp    f010376c <debuginfo_eip+0x257>
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f010373d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103742:	eb 28                	jmp    f010376c <debuginfo_eip+0x257>
f0103744:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103749:	eb 21                	jmp    f010376c <debuginfo_eip+0x257>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f010374b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103750:	eb 1a                	jmp    f010376c <debuginfo_eip+0x257>
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs,&lline,&rline,N_SLINE,addr);
	if(lline>rline)
		return -1;
f0103752:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103757:	eb 13                	jmp    f010376c <debuginfo_eip+0x257>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
	
	return 0;
f0103759:	b8 00 00 00 00       	mov    $0x0,%eax
f010375e:	eb 0c                	jmp    f010376c <debuginfo_eip+0x257>
f0103760:	b8 00 00 00 00       	mov    $0x0,%eax
f0103765:	eb 05                	jmp    f010376c <debuginfo_eip+0x257>
f0103767:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010376c:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010376f:	5b                   	pop    %ebx
f0103770:	5e                   	pop    %esi
f0103771:	5f                   	pop    %edi
f0103772:	5d                   	pop    %ebp
f0103773:	c3                   	ret    

f0103774 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0103774:	55                   	push   %ebp
f0103775:	89 e5                	mov    %esp,%ebp
f0103777:	57                   	push   %edi
f0103778:	56                   	push   %esi
f0103779:	53                   	push   %ebx
f010377a:	83 ec 1c             	sub    $0x1c,%esp
f010377d:	89 c7                	mov    %eax,%edi
f010377f:	89 d6                	mov    %edx,%esi
f0103781:	8b 45 08             	mov    0x8(%ebp),%eax
f0103784:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103787:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010378a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	// if cprintf'parameter includes pattern of the form "%-", padding
	// space on the right side if neccesary.
	// you can add helper function if needed.
	// your code here:
	int length,showsign=0;
	if(padc=='-'&&num>=base)
f010378d:	83 7d 18 2d          	cmpl   $0x2d,0x18(%ebp)
f0103791:	0f 85 8a 00 00 00    	jne    f0103821 <printnum+0xad>
f0103797:	8b 45 10             	mov    0x10(%ebp),%eax
f010379a:	ba 00 00 00 00       	mov    $0x0,%edx
f010379f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f01037a2:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f01037a5:	39 da                	cmp    %ebx,%edx
f01037a7:	72 09                	jb     f01037b2 <printnum+0x3e>
f01037a9:	39 4d 10             	cmp    %ecx,0x10(%ebp)
f01037ac:	0f 87 87 00 00 00    	ja     f0103839 <printnum+0xc5>
	{
		length=*(int *)putdat;
f01037b2:	8b 1e                	mov    (%esi),%ebx
		printnum(putch,putdat,num/base,base,0,padc);
f01037b4:	83 ec 0c             	sub    $0xc,%esp
f01037b7:	6a 2d                	push   $0x2d
f01037b9:	6a 00                	push   $0x0
f01037bb:	ff 75 10             	pushl  0x10(%ebp)
f01037be:	83 ec 08             	sub    $0x8,%esp
f01037c1:	52                   	push   %edx
f01037c2:	50                   	push   %eax
f01037c3:	ff 75 e4             	pushl  -0x1c(%ebp)
f01037c6:	ff 75 e0             	pushl  -0x20(%ebp)
f01037c9:	e8 02 0c 00 00       	call   f01043d0 <__udivdi3>
f01037ce:	83 c4 18             	add    $0x18,%esp
f01037d1:	52                   	push   %edx
f01037d2:	50                   	push   %eax
f01037d3:	89 f2                	mov    %esi,%edx
f01037d5:	89 f8                	mov    %edi,%eax
f01037d7:	e8 98 ff ff ff       	call   f0103774 <printnum>
		while (--width > 0)
			putch(padc, putdat);
	}
	}
	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f01037dc:	83 c4 18             	add    $0x18,%esp
f01037df:	56                   	push   %esi
f01037e0:	8b 45 10             	mov    0x10(%ebp),%eax
f01037e3:	ba 00 00 00 00       	mov    $0x0,%edx
f01037e8:	83 ec 04             	sub    $0x4,%esp
f01037eb:	52                   	push   %edx
f01037ec:	50                   	push   %eax
f01037ed:	ff 75 e4             	pushl  -0x1c(%ebp)
f01037f0:	ff 75 e0             	pushl  -0x20(%ebp)
f01037f3:	e8 08 0d 00 00       	call   f0104500 <__umoddi3>
f01037f8:	83 c4 14             	add    $0x14,%esp
f01037fb:	0f be 80 21 5b 10 f0 	movsbl -0xfefa4df(%eax),%eax
f0103802:	50                   	push   %eax
f0103803:	ff d7                	call   *%edi
	
	if(padc=='-'&&width>0)
f0103805:	83 c4 10             	add    $0x10,%esp
f0103808:	83 7d 18 2d          	cmpl   $0x2d,0x18(%ebp)
f010380c:	0f 85 fa 00 00 00    	jne    f010390c <printnum+0x198>
f0103812:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
f0103816:	0f 8f 9b 00 00 00    	jg     f01038b7 <printnum+0x143>
f010381c:	e9 eb 00 00 00       	jmp    f010390c <printnum+0x198>
	}
	else
	{
	
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0103821:	8b 45 10             	mov    0x10(%ebp),%eax
f0103824:	ba 00 00 00 00       	mov    $0x0,%edx
f0103829:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f010382c:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f010382f:	83 fb 00             	cmp    $0x0,%ebx
f0103832:	77 14                	ja     f0103848 <printnum+0xd4>
f0103834:	3b 4d 10             	cmp    0x10(%ebp),%ecx
f0103837:	73 0f                	jae    f0103848 <printnum+0xd4>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0103839:	8b 45 14             	mov    0x14(%ebp),%eax
f010383c:	8d 58 ff             	lea    -0x1(%eax),%ebx
f010383f:	85 db                	test   %ebx,%ebx
f0103841:	7f 61                	jg     f01038a4 <printnum+0x130>
f0103843:	e9 98 00 00 00       	jmp    f01038e0 <printnum+0x16c>
	else
	{
	
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0103848:	83 ec 0c             	sub    $0xc,%esp
f010384b:	ff 75 18             	pushl  0x18(%ebp)
f010384e:	8b 4d 14             	mov    0x14(%ebp),%ecx
f0103851:	8d 59 ff             	lea    -0x1(%ecx),%ebx
f0103854:	53                   	push   %ebx
f0103855:	ff 75 10             	pushl  0x10(%ebp)
f0103858:	83 ec 08             	sub    $0x8,%esp
f010385b:	52                   	push   %edx
f010385c:	50                   	push   %eax
f010385d:	ff 75 e4             	pushl  -0x1c(%ebp)
f0103860:	ff 75 e0             	pushl  -0x20(%ebp)
f0103863:	e8 68 0b 00 00       	call   f01043d0 <__udivdi3>
f0103868:	83 c4 18             	add    $0x18,%esp
f010386b:	52                   	push   %edx
f010386c:	50                   	push   %eax
f010386d:	89 f2                	mov    %esi,%edx
f010386f:	89 f8                	mov    %edi,%eax
f0103871:	e8 fe fe ff ff       	call   f0103774 <printnum>
		while (--width > 0)
			putch(padc, putdat);
	}
	}
	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0103876:	83 c4 18             	add    $0x18,%esp
f0103879:	56                   	push   %esi
f010387a:	8b 45 10             	mov    0x10(%ebp),%eax
f010387d:	ba 00 00 00 00       	mov    $0x0,%edx
f0103882:	83 ec 04             	sub    $0x4,%esp
f0103885:	52                   	push   %edx
f0103886:	50                   	push   %eax
f0103887:	ff 75 e4             	pushl  -0x1c(%ebp)
f010388a:	ff 75 e0             	pushl  -0x20(%ebp)
f010388d:	e8 6e 0c 00 00       	call   f0104500 <__umoddi3>
f0103892:	83 c4 14             	add    $0x14,%esp
f0103895:	0f be 80 21 5b 10 f0 	movsbl -0xfefa4df(%eax),%eax
f010389c:	50                   	push   %eax
f010389d:	ff d7                	call   *%edi
f010389f:	83 c4 10             	add    $0x10,%esp
f01038a2:	eb 68                	jmp    f010390c <printnum+0x198>
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f01038a4:	83 ec 08             	sub    $0x8,%esp
f01038a7:	56                   	push   %esi
f01038a8:	ff 75 18             	pushl  0x18(%ebp)
f01038ab:	ff d7                	call   *%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f01038ad:	83 c4 10             	add    $0x10,%esp
f01038b0:	83 eb 01             	sub    $0x1,%ebx
f01038b3:	75 ef                	jne    f01038a4 <printnum+0x130>
f01038b5:	eb 29                	jmp    f01038e0 <printnum+0x16c>
	putch("0123456789abcdef"[num % base], putdat);
	
	if(padc=='-'&&width>0)
	{
		length=*(int *)putdat-length;
		for(int i=0;i<width-length;++i)
f01038b7:	8b 45 14             	mov    0x14(%ebp),%eax
f01038ba:	8d 04 03             	lea    (%ebx,%eax,1),%eax
f01038bd:	2b 06                	sub    (%esi),%eax
f01038bf:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01038c2:	85 c0                	test   %eax,%eax
f01038c4:	7e 46                	jle    f010390c <printnum+0x198>
f01038c6:	bb 00 00 00 00       	mov    $0x0,%ebx
			putch(' ',putdat);
f01038cb:	83 ec 08             	sub    $0x8,%esp
f01038ce:	56                   	push   %esi
f01038cf:	6a 20                	push   $0x20
f01038d1:	ff d7                	call   *%edi
	putch("0123456789abcdef"[num % base], putdat);
	
	if(padc=='-'&&width>0)
	{
		length=*(int *)putdat-length;
		for(int i=0;i<width-length;++i)
f01038d3:	83 c3 01             	add    $0x1,%ebx
f01038d6:	83 c4 10             	add    $0x10,%esp
f01038d9:	3b 5d e0             	cmp    -0x20(%ebp),%ebx
f01038dc:	75 ed                	jne    f01038cb <printnum+0x157>
f01038de:	eb 2c                	jmp    f010390c <printnum+0x198>
		while (--width > 0)
			putch(padc, putdat);
	}
	}
	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f01038e0:	83 ec 08             	sub    $0x8,%esp
f01038e3:	56                   	push   %esi
f01038e4:	8b 45 10             	mov    0x10(%ebp),%eax
f01038e7:	ba 00 00 00 00       	mov    $0x0,%edx
f01038ec:	83 ec 04             	sub    $0x4,%esp
f01038ef:	52                   	push   %edx
f01038f0:	50                   	push   %eax
f01038f1:	ff 75 e4             	pushl  -0x1c(%ebp)
f01038f4:	ff 75 e0             	pushl  -0x20(%ebp)
f01038f7:	e8 04 0c 00 00       	call   f0104500 <__umoddi3>
f01038fc:	83 c4 14             	add    $0x14,%esp
f01038ff:	0f be 80 21 5b 10 f0 	movsbl -0xfefa4df(%eax),%eax
f0103906:	50                   	push   %eax
f0103907:	ff d7                	call   *%edi
f0103909:	83 c4 10             	add    $0x10,%esp
	{
		length=*(int *)putdat-length;
		for(int i=0;i<width-length;++i)
			putch(' ',putdat);
	}
}
f010390c:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010390f:	5b                   	pop    %ebx
f0103910:	5e                   	pop    %esi
f0103911:	5f                   	pop    %edi
f0103912:	5d                   	pop    %ebp
f0103913:	c3                   	ret    

f0103914 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0103914:	55                   	push   %ebp
f0103915:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0103917:	83 fa 01             	cmp    $0x1,%edx
f010391a:	7e 0e                	jle    f010392a <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f010391c:	8b 10                	mov    (%eax),%edx
f010391e:	8d 4a 08             	lea    0x8(%edx),%ecx
f0103921:	89 08                	mov    %ecx,(%eax)
f0103923:	8b 02                	mov    (%edx),%eax
f0103925:	8b 52 04             	mov    0x4(%edx),%edx
f0103928:	eb 22                	jmp    f010394c <getuint+0x38>
	else if (lflag)
f010392a:	85 d2                	test   %edx,%edx
f010392c:	74 10                	je     f010393e <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f010392e:	8b 10                	mov    (%eax),%edx
f0103930:	8d 4a 04             	lea    0x4(%edx),%ecx
f0103933:	89 08                	mov    %ecx,(%eax)
f0103935:	8b 02                	mov    (%edx),%eax
f0103937:	ba 00 00 00 00       	mov    $0x0,%edx
f010393c:	eb 0e                	jmp    f010394c <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f010393e:	8b 10                	mov    (%eax),%edx
f0103940:	8d 4a 04             	lea    0x4(%edx),%ecx
f0103943:	89 08                	mov    %ecx,(%eax)
f0103945:	8b 02                	mov    (%edx),%eax
f0103947:	ba 00 00 00 00       	mov    $0x0,%edx
}
f010394c:	5d                   	pop    %ebp
f010394d:	c3                   	ret    

f010394e <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f010394e:	55                   	push   %ebp
f010394f:	89 e5                	mov    %esp,%ebp
f0103951:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0103954:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0103958:	8b 10                	mov    (%eax),%edx
f010395a:	3b 50 04             	cmp    0x4(%eax),%edx
f010395d:	73 0a                	jae    f0103969 <sprintputch+0x1b>
		*b->buf++ = ch;
f010395f:	8d 4a 01             	lea    0x1(%edx),%ecx
f0103962:	89 08                	mov    %ecx,(%eax)
f0103964:	8b 45 08             	mov    0x8(%ebp),%eax
f0103967:	88 02                	mov    %al,(%edx)
}
f0103969:	5d                   	pop    %ebp
f010396a:	c3                   	ret    

f010396b <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f010396b:	55                   	push   %ebp
f010396c:	89 e5                	mov    %esp,%ebp
f010396e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0103971:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0103974:	50                   	push   %eax
f0103975:	ff 75 10             	pushl  0x10(%ebp)
f0103978:	ff 75 0c             	pushl  0xc(%ebp)
f010397b:	ff 75 08             	pushl  0x8(%ebp)
f010397e:	e8 05 00 00 00       	call   f0103988 <vprintfmt>
	va_end(ap);
}
f0103983:	83 c4 10             	add    $0x10,%esp
f0103986:	c9                   	leave  
f0103987:	c3                   	ret    

f0103988 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0103988:	55                   	push   %ebp
f0103989:	89 e5                	mov    %esp,%ebp
f010398b:	57                   	push   %edi
f010398c:	56                   	push   %esi
f010398d:	53                   	push   %ebx
f010398e:	83 ec 2c             	sub    $0x2c,%esp
f0103991:	8b 7d 08             	mov    0x8(%ebp),%edi
f0103994:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103997:	eb 03                	jmp    f010399c <vprintfmt+0x14>
			break;
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
			for (fmt--; fmt[-1] != '%'; fmt--)
f0103999:	89 75 10             	mov    %esi,0x10(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f010399c:	8b 45 10             	mov    0x10(%ebp),%eax
f010399f:	8d 70 01             	lea    0x1(%eax),%esi
f01039a2:	0f b6 00             	movzbl (%eax),%eax
f01039a5:	83 f8 25             	cmp    $0x25,%eax
f01039a8:	74 27                	je     f01039d1 <vprintfmt+0x49>
			if (ch == '\0')
f01039aa:	85 c0                	test   %eax,%eax
f01039ac:	75 0d                	jne    f01039bb <vprintfmt+0x33>
f01039ae:	e9 8b 04 00 00       	jmp    f0103e3e <vprintfmt+0x4b6>
f01039b3:	85 c0                	test   %eax,%eax
f01039b5:	0f 84 83 04 00 00    	je     f0103e3e <vprintfmt+0x4b6>
				return;
			putch(ch, putdat);
f01039bb:	83 ec 08             	sub    $0x8,%esp
f01039be:	53                   	push   %ebx
f01039bf:	50                   	push   %eax
f01039c0:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f01039c2:	83 c6 01             	add    $0x1,%esi
f01039c5:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
f01039c9:	83 c4 10             	add    $0x10,%esp
f01039cc:	83 f8 25             	cmp    $0x25,%eax
f01039cf:	75 e2                	jne    f01039b3 <vprintfmt+0x2b>
			padc = '-';
			goto reswitch;
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f01039d1:	c6 45 e3 20          	movb   $0x20,-0x1d(%ebp)
f01039d5:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f01039dc:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f01039e3:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
f01039ea:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
f01039f1:	b9 00 00 00 00       	mov    $0x0,%ecx
f01039f6:	eb 07                	jmp    f01039ff <vprintfmt+0x77>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01039f8:	8b 75 10             	mov    0x10(%ebp),%esi

		// flag to show the sign
		case '+':
			padc='+';
f01039fb:	c6 45 e3 2b          	movb   $0x2b,-0x1d(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01039ff:	8d 46 01             	lea    0x1(%esi),%eax
f0103a02:	89 45 10             	mov    %eax,0x10(%ebp)
f0103a05:	0f b6 06             	movzbl (%esi),%eax
f0103a08:	0f b6 d0             	movzbl %al,%edx
f0103a0b:	83 e8 23             	sub    $0x23,%eax
f0103a0e:	3c 55                	cmp    $0x55,%al
f0103a10:	0f 87 e9 03 00 00    	ja     f0103dff <vprintfmt+0x477>
f0103a16:	0f b6 c0             	movzbl %al,%eax
f0103a19:	ff 24 85 28 5c 10 f0 	jmp    *-0xfefa3d8(,%eax,4)
f0103a20:	8b 75 10             	mov    0x10(%ebp),%esi
			padc='+';
			goto reswitch;
		
		// flag to pad on the right
		case '-':
			padc = '-';
f0103a23:	c6 45 e3 2d          	movb   $0x2d,-0x1d(%ebp)
f0103a27:	eb d6                	jmp    f01039ff <vprintfmt+0x77>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0103a29:	8d 42 d0             	lea    -0x30(%edx),%eax
f0103a2c:	89 45 d0             	mov    %eax,-0x30(%ebp)
				ch = *fmt;
f0103a2f:	0f be 46 01          	movsbl 0x1(%esi),%eax
				if (ch < '0' || ch > '9')
f0103a33:	8d 50 d0             	lea    -0x30(%eax),%edx
f0103a36:	83 fa 09             	cmp    $0x9,%edx
f0103a39:	77 66                	ja     f0103aa1 <vprintfmt+0x119>
f0103a3b:	8b 75 10             	mov    0x10(%ebp),%esi
f0103a3e:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0103a41:	89 7d 08             	mov    %edi,0x8(%ebp)
f0103a44:	eb 09                	jmp    f0103a4f <vprintfmt+0xc7>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103a46:	8b 75 10             	mov    0x10(%ebp),%esi
			padc = '-';
			goto reswitch;
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0103a49:	c6 45 e3 30          	movb   $0x30,-0x1d(%ebp)
			goto reswitch;
f0103a4d:	eb b0                	jmp    f01039ff <vprintfmt+0x77>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0103a4f:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
f0103a52:	8d 14 92             	lea    (%edx,%edx,4),%edx
f0103a55:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
f0103a59:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
f0103a5c:	8d 78 d0             	lea    -0x30(%eax),%edi
f0103a5f:	83 ff 09             	cmp    $0x9,%edi
f0103a62:	76 eb                	jbe    f0103a4f <vprintfmt+0xc7>
f0103a64:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0103a67:	8b 7d 08             	mov    0x8(%ebp),%edi
f0103a6a:	eb 38                	jmp    f0103aa4 <vprintfmt+0x11c>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0103a6c:	8b 45 14             	mov    0x14(%ebp),%eax
f0103a6f:	8d 50 04             	lea    0x4(%eax),%edx
f0103a72:	89 55 14             	mov    %edx,0x14(%ebp)
f0103a75:	8b 00                	mov    (%eax),%eax
f0103a77:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103a7a:	8b 75 10             	mov    0x10(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0103a7d:	eb 25                	jmp    f0103aa4 <vprintfmt+0x11c>
f0103a7f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103a82:	85 c0                	test   %eax,%eax
f0103a84:	0f 48 c1             	cmovs  %ecx,%eax
f0103a87:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103a8a:	8b 75 10             	mov    0x10(%ebp),%esi
f0103a8d:	e9 6d ff ff ff       	jmp    f01039ff <vprintfmt+0x77>
f0103a92:	8b 75 10             	mov    0x10(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0103a95:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f0103a9c:	e9 5e ff ff ff       	jmp    f01039ff <vprintfmt+0x77>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103aa1:	8b 75 10             	mov    0x10(%ebp),%esi
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
f0103aa4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0103aa8:	0f 89 51 ff ff ff    	jns    f01039ff <vprintfmt+0x77>
				width = precision, precision = -1;
f0103aae:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0103ab1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0103ab4:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0103abb:	e9 3f ff ff ff       	jmp    f01039ff <vprintfmt+0x77>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0103ac0:	83 45 cc 01          	addl   $0x1,-0x34(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103ac4:	8b 75 10             	mov    0x10(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0103ac7:	e9 33 ff ff ff       	jmp    f01039ff <vprintfmt+0x77>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0103acc:	8b 45 14             	mov    0x14(%ebp),%eax
f0103acf:	8d 50 04             	lea    0x4(%eax),%edx
f0103ad2:	89 55 14             	mov    %edx,0x14(%ebp)
f0103ad5:	83 ec 08             	sub    $0x8,%esp
f0103ad8:	53                   	push   %ebx
f0103ad9:	ff 30                	pushl  (%eax)
f0103adb:	ff d7                	call   *%edi
			break;
f0103add:	83 c4 10             	add    $0x10,%esp
f0103ae0:	e9 b7 fe ff ff       	jmp    f010399c <vprintfmt+0x14>

		// error message
		case 'e':
			err = va_arg(ap, int);
f0103ae5:	8b 45 14             	mov    0x14(%ebp),%eax
f0103ae8:	8d 50 04             	lea    0x4(%eax),%edx
f0103aeb:	89 55 14             	mov    %edx,0x14(%ebp)
f0103aee:	8b 00                	mov    (%eax),%eax
f0103af0:	99                   	cltd   
f0103af1:	31 d0                	xor    %edx,%eax
f0103af3:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0103af5:	83 f8 06             	cmp    $0x6,%eax
f0103af8:	7f 0b                	jg     f0103b05 <vprintfmt+0x17d>
f0103afa:	8b 14 85 80 5d 10 f0 	mov    -0xfefa280(,%eax,4),%edx
f0103b01:	85 d2                	test   %edx,%edx
f0103b03:	75 15                	jne    f0103b1a <vprintfmt+0x192>
				printfmt(putch, putdat, "error %d", err);
f0103b05:	50                   	push   %eax
f0103b06:	68 39 5b 10 f0       	push   $0xf0105b39
f0103b0b:	53                   	push   %ebx
f0103b0c:	57                   	push   %edi
f0103b0d:	e8 59 fe ff ff       	call   f010396b <printfmt>
f0103b12:	83 c4 10             	add    $0x10,%esp
f0103b15:	e9 82 fe ff ff       	jmp    f010399c <vprintfmt+0x14>
			else
				printfmt(putch, putdat, "%s", p);
f0103b1a:	52                   	push   %edx
f0103b1b:	68 01 54 10 f0       	push   $0xf0105401
f0103b20:	53                   	push   %ebx
f0103b21:	57                   	push   %edi
f0103b22:	e8 44 fe ff ff       	call   f010396b <printfmt>
f0103b27:	83 c4 10             	add    $0x10,%esp
f0103b2a:	e9 6d fe ff ff       	jmp    f010399c <vprintfmt+0x14>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0103b2f:	8b 45 14             	mov    0x14(%ebp),%eax
f0103b32:	8d 50 04             	lea    0x4(%eax),%edx
f0103b35:	89 55 14             	mov    %edx,0x14(%ebp)
f0103b38:	8b 00                	mov    (%eax),%eax
				p = "(null)";
f0103b3a:	85 c0                	test   %eax,%eax
f0103b3c:	b9 32 5b 10 f0       	mov    $0xf0105b32,%ecx
f0103b41:	0f 45 c8             	cmovne %eax,%ecx
f0103b44:	89 4d cc             	mov    %ecx,-0x34(%ebp)
			if (width > 0 && padc != '-')
f0103b47:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0103b4b:	7e 06                	jle    f0103b53 <vprintfmt+0x1cb>
f0103b4d:	80 7d e3 2d          	cmpb   $0x2d,-0x1d(%ebp)
f0103b51:	75 19                	jne    f0103b6c <vprintfmt+0x1e4>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0103b53:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0103b56:	8d 70 01             	lea    0x1(%eax),%esi
f0103b59:	0f b6 00             	movzbl (%eax),%eax
f0103b5c:	0f be d0             	movsbl %al,%edx
f0103b5f:	85 d2                	test   %edx,%edx
f0103b61:	0f 85 9f 00 00 00    	jne    f0103c06 <vprintfmt+0x27e>
f0103b67:	e9 8c 00 00 00       	jmp    f0103bf8 <vprintfmt+0x270>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0103b6c:	83 ec 08             	sub    $0x8,%esp
f0103b6f:	ff 75 d0             	pushl  -0x30(%ebp)
f0103b72:	ff 75 cc             	pushl  -0x34(%ebp)
f0103b75:	e8 2f 04 00 00       	call   f0103fa9 <strnlen>
f0103b7a:	29 45 e4             	sub    %eax,-0x1c(%ebp)
f0103b7d:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0103b80:	83 c4 10             	add    $0x10,%esp
f0103b83:	85 c9                	test   %ecx,%ecx
f0103b85:	0f 8e 9a 02 00 00    	jle    f0103e25 <vprintfmt+0x49d>
					putch(padc, putdat);
f0103b8b:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
f0103b8f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0103b92:	89 cb                	mov    %ecx,%ebx
f0103b94:	83 ec 08             	sub    $0x8,%esp
f0103b97:	ff 75 0c             	pushl  0xc(%ebp)
f0103b9a:	56                   	push   %esi
f0103b9b:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0103b9d:	83 c4 10             	add    $0x10,%esp
f0103ba0:	83 eb 01             	sub    $0x1,%ebx
f0103ba3:	75 ef                	jne    f0103b94 <vprintfmt+0x20c>
f0103ba5:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0103ba8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103bab:	e9 75 02 00 00       	jmp    f0103e25 <vprintfmt+0x49d>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0103bb0:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0103bb4:	74 1b                	je     f0103bd1 <vprintfmt+0x249>
f0103bb6:	0f be c0             	movsbl %al,%eax
f0103bb9:	83 e8 20             	sub    $0x20,%eax
f0103bbc:	83 f8 5e             	cmp    $0x5e,%eax
f0103bbf:	76 10                	jbe    f0103bd1 <vprintfmt+0x249>
					putch('?', putdat);
f0103bc1:	83 ec 08             	sub    $0x8,%esp
f0103bc4:	ff 75 0c             	pushl  0xc(%ebp)
f0103bc7:	6a 3f                	push   $0x3f
f0103bc9:	ff 55 08             	call   *0x8(%ebp)
f0103bcc:	83 c4 10             	add    $0x10,%esp
f0103bcf:	eb 0d                	jmp    f0103bde <vprintfmt+0x256>
				else
					putch(ch, putdat);
f0103bd1:	83 ec 08             	sub    $0x8,%esp
f0103bd4:	ff 75 0c             	pushl  0xc(%ebp)
f0103bd7:	52                   	push   %edx
f0103bd8:	ff 55 08             	call   *0x8(%ebp)
f0103bdb:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0103bde:	83 ef 01             	sub    $0x1,%edi
f0103be1:	83 c6 01             	add    $0x1,%esi
f0103be4:	0f b6 46 ff          	movzbl -0x1(%esi),%eax
f0103be8:	0f be d0             	movsbl %al,%edx
f0103beb:	85 d2                	test   %edx,%edx
f0103bed:	75 31                	jne    f0103c20 <vprintfmt+0x298>
f0103bef:	89 7d e4             	mov    %edi,-0x1c(%ebp)
f0103bf2:	8b 7d 08             	mov    0x8(%ebp),%edi
f0103bf5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103bf8:	8b 75 e4             	mov    -0x1c(%ebp),%esi
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0103bfb:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0103bff:	7f 33                	jg     f0103c34 <vprintfmt+0x2ac>
f0103c01:	e9 96 fd ff ff       	jmp    f010399c <vprintfmt+0x14>
f0103c06:	89 7d 08             	mov    %edi,0x8(%ebp)
f0103c09:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103c0c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0103c0f:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0103c12:	eb 0c                	jmp    f0103c20 <vprintfmt+0x298>
f0103c14:	89 7d 08             	mov    %edi,0x8(%ebp)
f0103c17:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103c1a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0103c1d:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0103c20:	85 db                	test   %ebx,%ebx
f0103c22:	78 8c                	js     f0103bb0 <vprintfmt+0x228>
f0103c24:	83 eb 01             	sub    $0x1,%ebx
f0103c27:	79 87                	jns    f0103bb0 <vprintfmt+0x228>
f0103c29:	89 7d e4             	mov    %edi,-0x1c(%ebp)
f0103c2c:	8b 7d 08             	mov    0x8(%ebp),%edi
f0103c2f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103c32:	eb c4                	jmp    f0103bf8 <vprintfmt+0x270>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0103c34:	83 ec 08             	sub    $0x8,%esp
f0103c37:	53                   	push   %ebx
f0103c38:	6a 20                	push   $0x20
f0103c3a:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0103c3c:	83 c4 10             	add    $0x10,%esp
f0103c3f:	83 ee 01             	sub    $0x1,%esi
f0103c42:	75 f0                	jne    f0103c34 <vprintfmt+0x2ac>
f0103c44:	e9 53 fd ff ff       	jmp    f010399c <vprintfmt+0x14>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0103c49:	83 7d cc 01          	cmpl   $0x1,-0x34(%ebp)
f0103c4d:	7e 16                	jle    f0103c65 <vprintfmt+0x2dd>
		return va_arg(*ap, long long);
f0103c4f:	8b 45 14             	mov    0x14(%ebp),%eax
f0103c52:	8d 50 08             	lea    0x8(%eax),%edx
f0103c55:	89 55 14             	mov    %edx,0x14(%ebp)
f0103c58:	8b 50 04             	mov    0x4(%eax),%edx
f0103c5b:	8b 00                	mov    (%eax),%eax
f0103c5d:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0103c60:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0103c63:	eb 34                	jmp    f0103c99 <vprintfmt+0x311>
	else if (lflag)
f0103c65:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
f0103c69:	74 18                	je     f0103c83 <vprintfmt+0x2fb>
		return va_arg(*ap, long);
f0103c6b:	8b 45 14             	mov    0x14(%ebp),%eax
f0103c6e:	8d 50 04             	lea    0x4(%eax),%edx
f0103c71:	89 55 14             	mov    %edx,0x14(%ebp)
f0103c74:	8b 30                	mov    (%eax),%esi
f0103c76:	89 75 d0             	mov    %esi,-0x30(%ebp)
f0103c79:	89 f0                	mov    %esi,%eax
f0103c7b:	c1 f8 1f             	sar    $0x1f,%eax
f0103c7e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0103c81:	eb 16                	jmp    f0103c99 <vprintfmt+0x311>
	else
		return va_arg(*ap, int);
f0103c83:	8b 45 14             	mov    0x14(%ebp),%eax
f0103c86:	8d 50 04             	lea    0x4(%eax),%edx
f0103c89:	89 55 14             	mov    %edx,0x14(%ebp)
f0103c8c:	8b 30                	mov    (%eax),%esi
f0103c8e:	89 75 d0             	mov    %esi,-0x30(%ebp)
f0103c91:	89 f0                	mov    %esi,%eax
f0103c93:	c1 f8 1f             	sar    $0x1f,%eax
f0103c96:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0103c99:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0103c9c:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0103c9f:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103ca2:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
f0103ca5:	85 d2                	test   %edx,%edx
f0103ca7:	79 28                	jns    f0103cd1 <vprintfmt+0x349>
				putch('-', putdat);
f0103ca9:	83 ec 08             	sub    $0x8,%esp
f0103cac:	53                   	push   %ebx
f0103cad:	6a 2d                	push   $0x2d
f0103caf:	ff d7                	call   *%edi
				num = -(long long) num;
f0103cb1:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0103cb4:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0103cb7:	f7 d8                	neg    %eax
f0103cb9:	83 d2 00             	adc    $0x0,%edx
f0103cbc:	f7 da                	neg    %edx
f0103cbe:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103cc1:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0103cc4:	83 c4 10             	add    $0x10,%esp
			else
			{
				if(padc=='+')
					putch('+', putdat);
			}
			base = 10;
f0103cc7:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103ccc:	e9 a5 00 00 00       	jmp    f0103d76 <vprintfmt+0x3ee>
f0103cd1:	b8 0a 00 00 00       	mov    $0xa,%eax
				putch('-', putdat);
				num = -(long long) num;
			}
			else
			{
				if(padc=='+')
f0103cd6:	80 7d e3 2b          	cmpb   $0x2b,-0x1d(%ebp)
f0103cda:	0f 85 96 00 00 00    	jne    f0103d76 <vprintfmt+0x3ee>
					putch('+', putdat);
f0103ce0:	83 ec 08             	sub    $0x8,%esp
f0103ce3:	53                   	push   %ebx
f0103ce4:	6a 2b                	push   $0x2b
f0103ce6:	ff d7                	call   *%edi
f0103ce8:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
f0103ceb:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103cf0:	e9 81 00 00 00       	jmp    f0103d76 <vprintfmt+0x3ee>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0103cf5:	8b 55 cc             	mov    -0x34(%ebp),%edx
f0103cf8:	8d 45 14             	lea    0x14(%ebp),%eax
f0103cfb:	e8 14 fc ff ff       	call   f0103914 <getuint>
f0103d00:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103d03:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
f0103d06:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
f0103d0b:	eb 69                	jmp    f0103d76 <vprintfmt+0x3ee>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			putch('0', putdat);
f0103d0d:	83 ec 08             	sub    $0x8,%esp
f0103d10:	53                   	push   %ebx
f0103d11:	6a 30                	push   $0x30
f0103d13:	ff d7                	call   *%edi
			num = getuint(&ap, lflag);
f0103d15:	8b 55 cc             	mov    -0x34(%ebp),%edx
f0103d18:	8d 45 14             	lea    0x14(%ebp),%eax
f0103d1b:	e8 f4 fb ff ff       	call   f0103914 <getuint>
f0103d20:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103d23:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
			goto number;
f0103d26:	83 c4 10             	add    $0x10,%esp
		case 'o':
			// Replace this with your code.
			// display a number in octal form and the form should begin with '0'
			putch('0', putdat);
			num = getuint(&ap, lflag);
			base = 8;
f0103d29:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
f0103d2e:	eb 46                	jmp    f0103d76 <vprintfmt+0x3ee>

		// pointer
		case 'p':
			putch('0', putdat);
f0103d30:	83 ec 08             	sub    $0x8,%esp
f0103d33:	53                   	push   %ebx
f0103d34:	6a 30                	push   $0x30
f0103d36:	ff d7                	call   *%edi
			putch('x', putdat);
f0103d38:	83 c4 08             	add    $0x8,%esp
f0103d3b:	53                   	push   %ebx
f0103d3c:	6a 78                	push   $0x78
f0103d3e:	ff d7                	call   *%edi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0103d40:	8b 45 14             	mov    0x14(%ebp),%eax
f0103d43:	8d 50 04             	lea    0x4(%eax),%edx
f0103d46:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f0103d49:	8b 00                	mov    (%eax),%eax
f0103d4b:	ba 00 00 00 00       	mov    $0x0,%edx
f0103d50:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103d53:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f0103d56:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f0103d59:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
f0103d5e:	eb 16                	jmp    f0103d76 <vprintfmt+0x3ee>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0103d60:	8b 55 cc             	mov    -0x34(%ebp),%edx
f0103d63:	8d 45 14             	lea    0x14(%ebp),%eax
f0103d66:	e8 a9 fb ff ff       	call   f0103914 <getuint>
f0103d6b:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103d6e:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
f0103d71:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
f0103d76:	83 ec 0c             	sub    $0xc,%esp
f0103d79:	0f be 75 e3          	movsbl -0x1d(%ebp),%esi
f0103d7d:	56                   	push   %esi
f0103d7e:	ff 75 e4             	pushl  -0x1c(%ebp)
f0103d81:	50                   	push   %eax
f0103d82:	ff 75 dc             	pushl  -0x24(%ebp)
f0103d85:	ff 75 d8             	pushl  -0x28(%ebp)
f0103d88:	89 da                	mov    %ebx,%edx
f0103d8a:	89 f8                	mov    %edi,%eax
f0103d8c:	e8 e3 f9 ff ff       	call   f0103774 <printnum>
			break;
f0103d91:	83 c4 20             	add    $0x20,%esp
f0103d94:	e9 03 fc ff ff       	jmp    f010399c <vprintfmt+0x14>

            const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
            const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

            // Your code here
			num=(unsigned long long)(uintptr_t)va_arg(ap, void *);
f0103d99:	8b 45 14             	mov    0x14(%ebp),%eax
f0103d9c:	8d 50 04             	lea    0x4(%eax),%edx
f0103d9f:	89 55 14             	mov    %edx,0x14(%ebp)
f0103da2:	8b 00                	mov    (%eax),%eax
			if(!num)
f0103da4:	85 c0                	test   %eax,%eax
f0103da6:	75 1c                	jne    f0103dc4 <vprintfmt+0x43c>
				*(int *)putdat+=cprintf("%s",null_error);
f0103da8:	83 ec 08             	sub    $0x8,%esp
f0103dab:	68 ac 5b 10 f0       	push   $0xf0105bac
f0103db0:	68 01 54 10 f0       	push   $0xf0105401
f0103db5:	e8 70 f2 ff ff       	call   f010302a <cprintf>
f0103dba:	01 03                	add    %eax,(%ebx)
f0103dbc:	83 c4 10             	add    $0x10,%esp
f0103dbf:	e9 d8 fb ff ff       	jmp    f010399c <vprintfmt+0x14>
			else
			{
				*(char *)(int)num=*(int *)putdat;
f0103dc4:	8b 13                	mov    (%ebx),%edx
f0103dc6:	88 10                	mov    %dl,(%eax)
				if((*(int *)putdat)>128)
f0103dc8:	81 3b 80 00 00 00    	cmpl   $0x80,(%ebx)
f0103dce:	0f 8e c8 fb ff ff    	jle    f010399c <vprintfmt+0x14>
					*(int *)putdat+=cprintf("%s",overflow_error);
f0103dd4:	83 ec 08             	sub    $0x8,%esp
f0103dd7:	68 e4 5b 10 f0       	push   $0xf0105be4
f0103ddc:	68 01 54 10 f0       	push   $0xf0105401
f0103de1:	e8 44 f2 ff ff       	call   f010302a <cprintf>
f0103de6:	01 03                	add    %eax,(%ebx)
f0103de8:	83 c4 10             	add    $0x10,%esp
f0103deb:	e9 ac fb ff ff       	jmp    f010399c <vprintfmt+0x14>
            break;
        }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0103df0:	83 ec 08             	sub    $0x8,%esp
f0103df3:	53                   	push   %ebx
f0103df4:	52                   	push   %edx
f0103df5:	ff d7                	call   *%edi
			break;
f0103df7:	83 c4 10             	add    $0x10,%esp
f0103dfa:	e9 9d fb ff ff       	jmp    f010399c <vprintfmt+0x14>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0103dff:	83 ec 08             	sub    $0x8,%esp
f0103e02:	53                   	push   %ebx
f0103e03:	6a 25                	push   $0x25
f0103e05:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0103e07:	83 c4 10             	add    $0x10,%esp
f0103e0a:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
f0103e0e:	0f 84 85 fb ff ff    	je     f0103999 <vprintfmt+0x11>
f0103e14:	83 ee 01             	sub    $0x1,%esi
f0103e17:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
f0103e1b:	75 f7                	jne    f0103e14 <vprintfmt+0x48c>
f0103e1d:	89 75 10             	mov    %esi,0x10(%ebp)
f0103e20:	e9 77 fb ff ff       	jmp    f010399c <vprintfmt+0x14>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0103e25:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0103e28:	8d 70 01             	lea    0x1(%eax),%esi
f0103e2b:	0f b6 00             	movzbl (%eax),%eax
f0103e2e:	0f be d0             	movsbl %al,%edx
f0103e31:	85 d2                	test   %edx,%edx
f0103e33:	0f 85 db fd ff ff    	jne    f0103c14 <vprintfmt+0x28c>
f0103e39:	e9 5e fb ff ff       	jmp    f010399c <vprintfmt+0x14>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
f0103e3e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103e41:	5b                   	pop    %ebx
f0103e42:	5e                   	pop    %esi
f0103e43:	5f                   	pop    %edi
f0103e44:	5d                   	pop    %ebp
f0103e45:	c3                   	ret    

f0103e46 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0103e46:	55                   	push   %ebp
f0103e47:	89 e5                	mov    %esp,%ebp
f0103e49:	83 ec 18             	sub    $0x18,%esp
f0103e4c:	8b 45 08             	mov    0x8(%ebp),%eax
f0103e4f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0103e52:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0103e55:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0103e59:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0103e5c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0103e63:	85 c0                	test   %eax,%eax
f0103e65:	74 26                	je     f0103e8d <vsnprintf+0x47>
f0103e67:	85 d2                	test   %edx,%edx
f0103e69:	7e 22                	jle    f0103e8d <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0103e6b:	ff 75 14             	pushl  0x14(%ebp)
f0103e6e:	ff 75 10             	pushl  0x10(%ebp)
f0103e71:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0103e74:	50                   	push   %eax
f0103e75:	68 4e 39 10 f0       	push   $0xf010394e
f0103e7a:	e8 09 fb ff ff       	call   f0103988 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0103e7f:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0103e82:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0103e85:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103e88:	83 c4 10             	add    $0x10,%esp
f0103e8b:	eb 05                	jmp    f0103e92 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f0103e8d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f0103e92:	c9                   	leave  
f0103e93:	c3                   	ret    

f0103e94 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0103e94:	55                   	push   %ebp
f0103e95:	89 e5                	mov    %esp,%ebp
f0103e97:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0103e9a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0103e9d:	50                   	push   %eax
f0103e9e:	ff 75 10             	pushl  0x10(%ebp)
f0103ea1:	ff 75 0c             	pushl  0xc(%ebp)
f0103ea4:	ff 75 08             	pushl  0x8(%ebp)
f0103ea7:	e8 9a ff ff ff       	call   f0103e46 <vsnprintf>
	va_end(ap);

	return rc;
}
f0103eac:	c9                   	leave  
f0103ead:	c3                   	ret    

f0103eae <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0103eae:	55                   	push   %ebp
f0103eaf:	89 e5                	mov    %esp,%ebp
f0103eb1:	57                   	push   %edi
f0103eb2:	56                   	push   %esi
f0103eb3:	53                   	push   %ebx
f0103eb4:	83 ec 0c             	sub    $0xc,%esp
f0103eb7:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0103eba:	85 c0                	test   %eax,%eax
f0103ebc:	74 11                	je     f0103ecf <readline+0x21>
		cprintf("%s", prompt);
f0103ebe:	83 ec 08             	sub    $0x8,%esp
f0103ec1:	50                   	push   %eax
f0103ec2:	68 01 54 10 f0       	push   $0xf0105401
f0103ec7:	e8 5e f1 ff ff       	call   f010302a <cprintf>
f0103ecc:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f0103ecf:	83 ec 0c             	sub    $0xc,%esp
f0103ed2:	6a 00                	push   $0x0
f0103ed4:	e8 8e c7 ff ff       	call   f0100667 <iscons>
f0103ed9:	89 c7                	mov    %eax,%edi
f0103edb:	83 c4 10             	add    $0x10,%esp
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f0103ede:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0103ee3:	e8 6e c7 ff ff       	call   f0100656 <getchar>
f0103ee8:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0103eea:	85 c0                	test   %eax,%eax
f0103eec:	79 18                	jns    f0103f06 <readline+0x58>
			cprintf("read error: %e\n", c);
f0103eee:	83 ec 08             	sub    $0x8,%esp
f0103ef1:	50                   	push   %eax
f0103ef2:	68 9c 5d 10 f0       	push   $0xf0105d9c
f0103ef7:	e8 2e f1 ff ff       	call   f010302a <cprintf>
			return NULL;
f0103efc:	83 c4 10             	add    $0x10,%esp
f0103eff:	b8 00 00 00 00       	mov    $0x0,%eax
f0103f04:	eb 79                	jmp    f0103f7f <readline+0xd1>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0103f06:	83 f8 08             	cmp    $0x8,%eax
f0103f09:	0f 94 c2             	sete   %dl
f0103f0c:	83 f8 7f             	cmp    $0x7f,%eax
f0103f0f:	0f 94 c0             	sete   %al
f0103f12:	08 c2                	or     %al,%dl
f0103f14:	74 1a                	je     f0103f30 <readline+0x82>
f0103f16:	85 f6                	test   %esi,%esi
f0103f18:	7e 16                	jle    f0103f30 <readline+0x82>
			if (echoing)
f0103f1a:	85 ff                	test   %edi,%edi
f0103f1c:	74 0d                	je     f0103f2b <readline+0x7d>
				cputchar('\b');
f0103f1e:	83 ec 0c             	sub    $0xc,%esp
f0103f21:	6a 08                	push   $0x8
f0103f23:	e8 1e c7 ff ff       	call   f0100646 <cputchar>
f0103f28:	83 c4 10             	add    $0x10,%esp
			i--;
f0103f2b:	83 ee 01             	sub    $0x1,%esi
f0103f2e:	eb b3                	jmp    f0103ee3 <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0103f30:	83 fb 1f             	cmp    $0x1f,%ebx
f0103f33:	7e 23                	jle    f0103f58 <readline+0xaa>
f0103f35:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0103f3b:	7f 1b                	jg     f0103f58 <readline+0xaa>
			if (echoing)
f0103f3d:	85 ff                	test   %edi,%edi
f0103f3f:	74 0c                	je     f0103f4d <readline+0x9f>
				cputchar(c);
f0103f41:	83 ec 0c             	sub    $0xc,%esp
f0103f44:	53                   	push   %ebx
f0103f45:	e8 fc c6 ff ff       	call   f0100646 <cputchar>
f0103f4a:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f0103f4d:	88 9e 60 fd 18 f0    	mov    %bl,-0xfe702a0(%esi)
f0103f53:	8d 76 01             	lea    0x1(%esi),%esi
f0103f56:	eb 8b                	jmp    f0103ee3 <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f0103f58:	83 fb 0a             	cmp    $0xa,%ebx
f0103f5b:	74 05                	je     f0103f62 <readline+0xb4>
f0103f5d:	83 fb 0d             	cmp    $0xd,%ebx
f0103f60:	75 81                	jne    f0103ee3 <readline+0x35>
			if (echoing)
f0103f62:	85 ff                	test   %edi,%edi
f0103f64:	74 0d                	je     f0103f73 <readline+0xc5>
				cputchar('\n');
f0103f66:	83 ec 0c             	sub    $0xc,%esp
f0103f69:	6a 0a                	push   $0xa
f0103f6b:	e8 d6 c6 ff ff       	call   f0100646 <cputchar>
f0103f70:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f0103f73:	c6 86 60 fd 18 f0 00 	movb   $0x0,-0xfe702a0(%esi)
			return buf;
f0103f7a:	b8 60 fd 18 f0       	mov    $0xf018fd60,%eax
		}
	}
}
f0103f7f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103f82:	5b                   	pop    %ebx
f0103f83:	5e                   	pop    %esi
f0103f84:	5f                   	pop    %edi
f0103f85:	5d                   	pop    %ebp
f0103f86:	c3                   	ret    

f0103f87 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0103f87:	55                   	push   %ebp
f0103f88:	89 e5                	mov    %esp,%ebp
f0103f8a:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0103f8d:	80 3a 00             	cmpb   $0x0,(%edx)
f0103f90:	74 10                	je     f0103fa2 <strlen+0x1b>
f0103f92:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
f0103f97:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0103f9a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0103f9e:	75 f7                	jne    f0103f97 <strlen+0x10>
f0103fa0:	eb 05                	jmp    f0103fa7 <strlen+0x20>
f0103fa2:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
f0103fa7:	5d                   	pop    %ebp
f0103fa8:	c3                   	ret    

f0103fa9 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0103fa9:	55                   	push   %ebp
f0103faa:	89 e5                	mov    %esp,%ebp
f0103fac:	53                   	push   %ebx
f0103fad:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0103fb0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0103fb3:	85 c9                	test   %ecx,%ecx
f0103fb5:	74 1c                	je     f0103fd3 <strnlen+0x2a>
f0103fb7:	80 3b 00             	cmpb   $0x0,(%ebx)
f0103fba:	74 1e                	je     f0103fda <strnlen+0x31>
f0103fbc:	ba 01 00 00 00       	mov    $0x1,%edx
		n++;
f0103fc1:	89 d0                	mov    %edx,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0103fc3:	39 ca                	cmp    %ecx,%edx
f0103fc5:	74 18                	je     f0103fdf <strnlen+0x36>
f0103fc7:	83 c2 01             	add    $0x1,%edx
f0103fca:	80 7c 13 ff 00       	cmpb   $0x0,-0x1(%ebx,%edx,1)
f0103fcf:	75 f0                	jne    f0103fc1 <strnlen+0x18>
f0103fd1:	eb 0c                	jmp    f0103fdf <strnlen+0x36>
f0103fd3:	b8 00 00 00 00       	mov    $0x0,%eax
f0103fd8:	eb 05                	jmp    f0103fdf <strnlen+0x36>
f0103fda:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
f0103fdf:	5b                   	pop    %ebx
f0103fe0:	5d                   	pop    %ebp
f0103fe1:	c3                   	ret    

f0103fe2 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0103fe2:	55                   	push   %ebp
f0103fe3:	89 e5                	mov    %esp,%ebp
f0103fe5:	53                   	push   %ebx
f0103fe6:	8b 45 08             	mov    0x8(%ebp),%eax
f0103fe9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0103fec:	89 c2                	mov    %eax,%edx
f0103fee:	83 c2 01             	add    $0x1,%edx
f0103ff1:	83 c1 01             	add    $0x1,%ecx
f0103ff4:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f0103ff8:	88 5a ff             	mov    %bl,-0x1(%edx)
f0103ffb:	84 db                	test   %bl,%bl
f0103ffd:	75 ef                	jne    f0103fee <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f0103fff:	5b                   	pop    %ebx
f0104000:	5d                   	pop    %ebp
f0104001:	c3                   	ret    

f0104002 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0104002:	55                   	push   %ebp
f0104003:	89 e5                	mov    %esp,%ebp
f0104005:	53                   	push   %ebx
f0104006:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0104009:	53                   	push   %ebx
f010400a:	e8 78 ff ff ff       	call   f0103f87 <strlen>
f010400f:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f0104012:	ff 75 0c             	pushl  0xc(%ebp)
f0104015:	01 d8                	add    %ebx,%eax
f0104017:	50                   	push   %eax
f0104018:	e8 c5 ff ff ff       	call   f0103fe2 <strcpy>
	return dst;
}
f010401d:	89 d8                	mov    %ebx,%eax
f010401f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0104022:	c9                   	leave  
f0104023:	c3                   	ret    

f0104024 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0104024:	55                   	push   %ebp
f0104025:	89 e5                	mov    %esp,%ebp
f0104027:	56                   	push   %esi
f0104028:	53                   	push   %ebx
f0104029:	8b 75 08             	mov    0x8(%ebp),%esi
f010402c:	8b 55 0c             	mov    0xc(%ebp),%edx
f010402f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0104032:	85 db                	test   %ebx,%ebx
f0104034:	74 17                	je     f010404d <strncpy+0x29>
f0104036:	01 f3                	add    %esi,%ebx
f0104038:	89 f1                	mov    %esi,%ecx
		*dst++ = *src;
f010403a:	83 c1 01             	add    $0x1,%ecx
f010403d:	0f b6 02             	movzbl (%edx),%eax
f0104040:	88 41 ff             	mov    %al,-0x1(%ecx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0104043:	80 3a 01             	cmpb   $0x1,(%edx)
f0104046:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0104049:	39 cb                	cmp    %ecx,%ebx
f010404b:	75 ed                	jne    f010403a <strncpy+0x16>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f010404d:	89 f0                	mov    %esi,%eax
f010404f:	5b                   	pop    %ebx
f0104050:	5e                   	pop    %esi
f0104051:	5d                   	pop    %ebp
f0104052:	c3                   	ret    

f0104053 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0104053:	55                   	push   %ebp
f0104054:	89 e5                	mov    %esp,%ebp
f0104056:	56                   	push   %esi
f0104057:	53                   	push   %ebx
f0104058:	8b 75 08             	mov    0x8(%ebp),%esi
f010405b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010405e:	8b 55 10             	mov    0x10(%ebp),%edx
f0104061:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0104063:	85 d2                	test   %edx,%edx
f0104065:	74 35                	je     f010409c <strlcpy+0x49>
		while (--size > 0 && *src != '\0')
f0104067:	89 d0                	mov    %edx,%eax
f0104069:	83 e8 01             	sub    $0x1,%eax
f010406c:	74 25                	je     f0104093 <strlcpy+0x40>
f010406e:	0f b6 0b             	movzbl (%ebx),%ecx
f0104071:	84 c9                	test   %cl,%cl
f0104073:	74 22                	je     f0104097 <strlcpy+0x44>
f0104075:	8d 53 01             	lea    0x1(%ebx),%edx
f0104078:	01 c3                	add    %eax,%ebx
f010407a:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
f010407c:	83 c0 01             	add    $0x1,%eax
f010407f:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0104082:	39 da                	cmp    %ebx,%edx
f0104084:	74 13                	je     f0104099 <strlcpy+0x46>
f0104086:	83 c2 01             	add    $0x1,%edx
f0104089:	0f b6 4a ff          	movzbl -0x1(%edx),%ecx
f010408d:	84 c9                	test   %cl,%cl
f010408f:	75 eb                	jne    f010407c <strlcpy+0x29>
f0104091:	eb 06                	jmp    f0104099 <strlcpy+0x46>
f0104093:	89 f0                	mov    %esi,%eax
f0104095:	eb 02                	jmp    f0104099 <strlcpy+0x46>
f0104097:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
f0104099:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f010409c:	29 f0                	sub    %esi,%eax
}
f010409e:	5b                   	pop    %ebx
f010409f:	5e                   	pop    %esi
f01040a0:	5d                   	pop    %ebp
f01040a1:	c3                   	ret    

f01040a2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f01040a2:	55                   	push   %ebp
f01040a3:	89 e5                	mov    %esp,%ebp
f01040a5:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01040a8:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f01040ab:	0f b6 01             	movzbl (%ecx),%eax
f01040ae:	84 c0                	test   %al,%al
f01040b0:	74 15                	je     f01040c7 <strcmp+0x25>
f01040b2:	3a 02                	cmp    (%edx),%al
f01040b4:	75 11                	jne    f01040c7 <strcmp+0x25>
		p++, q++;
f01040b6:	83 c1 01             	add    $0x1,%ecx
f01040b9:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f01040bc:	0f b6 01             	movzbl (%ecx),%eax
f01040bf:	84 c0                	test   %al,%al
f01040c1:	74 04                	je     f01040c7 <strcmp+0x25>
f01040c3:	3a 02                	cmp    (%edx),%al
f01040c5:	74 ef                	je     f01040b6 <strcmp+0x14>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f01040c7:	0f b6 c0             	movzbl %al,%eax
f01040ca:	0f b6 12             	movzbl (%edx),%edx
f01040cd:	29 d0                	sub    %edx,%eax
}
f01040cf:	5d                   	pop    %ebp
f01040d0:	c3                   	ret    

f01040d1 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f01040d1:	55                   	push   %ebp
f01040d2:	89 e5                	mov    %esp,%ebp
f01040d4:	56                   	push   %esi
f01040d5:	53                   	push   %ebx
f01040d6:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01040d9:	8b 55 0c             	mov    0xc(%ebp),%edx
f01040dc:	8b 75 10             	mov    0x10(%ebp),%esi
	while (n > 0 && *p && *p == *q)
f01040df:	85 f6                	test   %esi,%esi
f01040e1:	74 29                	je     f010410c <strncmp+0x3b>
f01040e3:	0f b6 03             	movzbl (%ebx),%eax
f01040e6:	84 c0                	test   %al,%al
f01040e8:	74 30                	je     f010411a <strncmp+0x49>
f01040ea:	3a 02                	cmp    (%edx),%al
f01040ec:	75 2c                	jne    f010411a <strncmp+0x49>
f01040ee:	8d 43 01             	lea    0x1(%ebx),%eax
f01040f1:	01 de                	add    %ebx,%esi
		n--, p++, q++;
f01040f3:	89 c3                	mov    %eax,%ebx
f01040f5:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f01040f8:	39 c6                	cmp    %eax,%esi
f01040fa:	74 17                	je     f0104113 <strncmp+0x42>
f01040fc:	0f b6 08             	movzbl (%eax),%ecx
f01040ff:	84 c9                	test   %cl,%cl
f0104101:	74 17                	je     f010411a <strncmp+0x49>
f0104103:	83 c0 01             	add    $0x1,%eax
f0104106:	3a 0a                	cmp    (%edx),%cl
f0104108:	74 e9                	je     f01040f3 <strncmp+0x22>
f010410a:	eb 0e                	jmp    f010411a <strncmp+0x49>
		n--, p++, q++;
	if (n == 0)
		return 0;
f010410c:	b8 00 00 00 00       	mov    $0x0,%eax
f0104111:	eb 0f                	jmp    f0104122 <strncmp+0x51>
f0104113:	b8 00 00 00 00       	mov    $0x0,%eax
f0104118:	eb 08                	jmp    f0104122 <strncmp+0x51>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f010411a:	0f b6 03             	movzbl (%ebx),%eax
f010411d:	0f b6 12             	movzbl (%edx),%edx
f0104120:	29 d0                	sub    %edx,%eax
}
f0104122:	5b                   	pop    %ebx
f0104123:	5e                   	pop    %esi
f0104124:	5d                   	pop    %ebp
f0104125:	c3                   	ret    

f0104126 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0104126:	55                   	push   %ebp
f0104127:	89 e5                	mov    %esp,%ebp
f0104129:	53                   	push   %ebx
f010412a:	8b 45 08             	mov    0x8(%ebp),%eax
f010412d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	for (; *s; s++)
f0104130:	0f b6 10             	movzbl (%eax),%edx
f0104133:	84 d2                	test   %dl,%dl
f0104135:	74 1d                	je     f0104154 <strchr+0x2e>
f0104137:	89 d9                	mov    %ebx,%ecx
		if (*s == c)
f0104139:	38 d3                	cmp    %dl,%bl
f010413b:	75 06                	jne    f0104143 <strchr+0x1d>
f010413d:	eb 1a                	jmp    f0104159 <strchr+0x33>
f010413f:	38 ca                	cmp    %cl,%dl
f0104141:	74 16                	je     f0104159 <strchr+0x33>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0104143:	83 c0 01             	add    $0x1,%eax
f0104146:	0f b6 10             	movzbl (%eax),%edx
f0104149:	84 d2                	test   %dl,%dl
f010414b:	75 f2                	jne    f010413f <strchr+0x19>
		if (*s == c)
			return (char *) s;
	return 0;
f010414d:	b8 00 00 00 00       	mov    $0x0,%eax
f0104152:	eb 05                	jmp    f0104159 <strchr+0x33>
f0104154:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104159:	5b                   	pop    %ebx
f010415a:	5d                   	pop    %ebp
f010415b:	c3                   	ret    

f010415c <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f010415c:	55                   	push   %ebp
f010415d:	89 e5                	mov    %esp,%ebp
f010415f:	53                   	push   %ebx
f0104160:	8b 45 08             	mov    0x8(%ebp),%eax
f0104163:	8b 55 0c             	mov    0xc(%ebp),%edx
	for (; *s; s++)
f0104166:	0f b6 18             	movzbl (%eax),%ebx
		if (*s == c)
f0104169:	38 d3                	cmp    %dl,%bl
f010416b:	74 14                	je     f0104181 <strfind+0x25>
f010416d:	89 d1                	mov    %edx,%ecx
f010416f:	84 db                	test   %bl,%bl
f0104171:	74 0e                	je     f0104181 <strfind+0x25>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f0104173:	83 c0 01             	add    $0x1,%eax
f0104176:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f0104179:	38 ca                	cmp    %cl,%dl
f010417b:	74 04                	je     f0104181 <strfind+0x25>
f010417d:	84 d2                	test   %dl,%dl
f010417f:	75 f2                	jne    f0104173 <strfind+0x17>
			break;
	return (char *) s;
}
f0104181:	5b                   	pop    %ebx
f0104182:	5d                   	pop    %ebp
f0104183:	c3                   	ret    

f0104184 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0104184:	55                   	push   %ebp
f0104185:	89 e5                	mov    %esp,%ebp
f0104187:	57                   	push   %edi
f0104188:	56                   	push   %esi
f0104189:	53                   	push   %ebx
f010418a:	8b 7d 08             	mov    0x8(%ebp),%edi
f010418d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0104190:	85 c9                	test   %ecx,%ecx
f0104192:	74 36                	je     f01041ca <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0104194:	f7 c7 03 00 00 00    	test   $0x3,%edi
f010419a:	75 28                	jne    f01041c4 <memset+0x40>
f010419c:	f6 c1 03             	test   $0x3,%cl
f010419f:	75 23                	jne    f01041c4 <memset+0x40>
		c &= 0xFF;
f01041a1:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f01041a5:	89 d3                	mov    %edx,%ebx
f01041a7:	c1 e3 08             	shl    $0x8,%ebx
f01041aa:	89 d6                	mov    %edx,%esi
f01041ac:	c1 e6 18             	shl    $0x18,%esi
f01041af:	89 d0                	mov    %edx,%eax
f01041b1:	c1 e0 10             	shl    $0x10,%eax
f01041b4:	09 f0                	or     %esi,%eax
f01041b6:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
f01041b8:	89 d8                	mov    %ebx,%eax
f01041ba:	09 d0                	or     %edx,%eax
f01041bc:	c1 e9 02             	shr    $0x2,%ecx
f01041bf:	fc                   	cld    
f01041c0:	f3 ab                	rep stos %eax,%es:(%edi)
f01041c2:	eb 06                	jmp    f01041ca <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f01041c4:	8b 45 0c             	mov    0xc(%ebp),%eax
f01041c7:	fc                   	cld    
f01041c8:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f01041ca:	89 f8                	mov    %edi,%eax
f01041cc:	5b                   	pop    %ebx
f01041cd:	5e                   	pop    %esi
f01041ce:	5f                   	pop    %edi
f01041cf:	5d                   	pop    %ebp
f01041d0:	c3                   	ret    

f01041d1 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f01041d1:	55                   	push   %ebp
f01041d2:	89 e5                	mov    %esp,%ebp
f01041d4:	57                   	push   %edi
f01041d5:	56                   	push   %esi
f01041d6:	8b 45 08             	mov    0x8(%ebp),%eax
f01041d9:	8b 75 0c             	mov    0xc(%ebp),%esi
f01041dc:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
f01041df:	39 c6                	cmp    %eax,%esi
f01041e1:	73 35                	jae    f0104218 <memmove+0x47>
f01041e3:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f01041e6:	39 d0                	cmp    %edx,%eax
f01041e8:	73 2e                	jae    f0104218 <memmove+0x47>
		s += n;
		d += n;
f01041ea:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01041ed:	89 d6                	mov    %edx,%esi
f01041ef:	09 fe                	or     %edi,%esi
f01041f1:	f7 c6 03 00 00 00    	test   $0x3,%esi
f01041f7:	75 13                	jne    f010420c <memmove+0x3b>
f01041f9:	f6 c1 03             	test   $0x3,%cl
f01041fc:	75 0e                	jne    f010420c <memmove+0x3b>
			asm volatile("std; rep movsl\n"
f01041fe:	83 ef 04             	sub    $0x4,%edi
f0104201:	8d 72 fc             	lea    -0x4(%edx),%esi
f0104204:	c1 e9 02             	shr    $0x2,%ecx
f0104207:	fd                   	std    
f0104208:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010420a:	eb 09                	jmp    f0104215 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f010420c:	83 ef 01             	sub    $0x1,%edi
f010420f:	8d 72 ff             	lea    -0x1(%edx),%esi
f0104212:	fd                   	std    
f0104213:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0104215:	fc                   	cld    
f0104216:	eb 1d                	jmp    f0104235 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0104218:	89 f2                	mov    %esi,%edx
f010421a:	09 c2                	or     %eax,%edx
f010421c:	f6 c2 03             	test   $0x3,%dl
f010421f:	75 0f                	jne    f0104230 <memmove+0x5f>
f0104221:	f6 c1 03             	test   $0x3,%cl
f0104224:	75 0a                	jne    f0104230 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
f0104226:	c1 e9 02             	shr    $0x2,%ecx
f0104229:	89 c7                	mov    %eax,%edi
f010422b:	fc                   	cld    
f010422c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010422e:	eb 05                	jmp    f0104235 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0104230:	89 c7                	mov    %eax,%edi
f0104232:	fc                   	cld    
f0104233:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0104235:	5e                   	pop    %esi
f0104236:	5f                   	pop    %edi
f0104237:	5d                   	pop    %ebp
f0104238:	c3                   	ret    

f0104239 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
f0104239:	55                   	push   %ebp
f010423a:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f010423c:	ff 75 10             	pushl  0x10(%ebp)
f010423f:	ff 75 0c             	pushl  0xc(%ebp)
f0104242:	ff 75 08             	pushl  0x8(%ebp)
f0104245:	e8 87 ff ff ff       	call   f01041d1 <memmove>
}
f010424a:	c9                   	leave  
f010424b:	c3                   	ret    

f010424c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f010424c:	55                   	push   %ebp
f010424d:	89 e5                	mov    %esp,%ebp
f010424f:	57                   	push   %edi
f0104250:	56                   	push   %esi
f0104251:	53                   	push   %ebx
f0104252:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0104255:	8b 75 0c             	mov    0xc(%ebp),%esi
f0104258:	8b 45 10             	mov    0x10(%ebp),%eax
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010425b:	85 c0                	test   %eax,%eax
f010425d:	74 39                	je     f0104298 <memcmp+0x4c>
f010425f:	8d 78 ff             	lea    -0x1(%eax),%edi
		if (*s1 != *s2)
f0104262:	0f b6 13             	movzbl (%ebx),%edx
f0104265:	0f b6 0e             	movzbl (%esi),%ecx
f0104268:	38 ca                	cmp    %cl,%dl
f010426a:	75 17                	jne    f0104283 <memcmp+0x37>
f010426c:	b8 00 00 00 00       	mov    $0x0,%eax
f0104271:	eb 1a                	jmp    f010428d <memcmp+0x41>
f0104273:	0f b6 54 03 01       	movzbl 0x1(%ebx,%eax,1),%edx
f0104278:	83 c0 01             	add    $0x1,%eax
f010427b:	0f b6 0c 06          	movzbl (%esi,%eax,1),%ecx
f010427f:	38 ca                	cmp    %cl,%dl
f0104281:	74 0a                	je     f010428d <memcmp+0x41>
			return (int) *s1 - (int) *s2;
f0104283:	0f b6 c2             	movzbl %dl,%eax
f0104286:	0f b6 c9             	movzbl %cl,%ecx
f0104289:	29 c8                	sub    %ecx,%eax
f010428b:	eb 10                	jmp    f010429d <memcmp+0x51>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010428d:	39 f8                	cmp    %edi,%eax
f010428f:	75 e2                	jne    f0104273 <memcmp+0x27>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0104291:	b8 00 00 00 00       	mov    $0x0,%eax
f0104296:	eb 05                	jmp    f010429d <memcmp+0x51>
f0104298:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010429d:	5b                   	pop    %ebx
f010429e:	5e                   	pop    %esi
f010429f:	5f                   	pop    %edi
f01042a0:	5d                   	pop    %ebp
f01042a1:	c3                   	ret    

f01042a2 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f01042a2:	55                   	push   %ebp
f01042a3:	89 e5                	mov    %esp,%ebp
f01042a5:	53                   	push   %ebx
f01042a6:	8b 55 08             	mov    0x8(%ebp),%edx
	const void *ends = (const char *) s + n;
f01042a9:	89 d0                	mov    %edx,%eax
f01042ab:	03 45 10             	add    0x10(%ebp),%eax
	for (; s < ends; s++)
f01042ae:	39 c2                	cmp    %eax,%edx
f01042b0:	73 1d                	jae    f01042cf <memfind+0x2d>
		if (*(const unsigned char *) s == (unsigned char) c)
f01042b2:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
f01042b6:	0f b6 0a             	movzbl (%edx),%ecx
f01042b9:	39 d9                	cmp    %ebx,%ecx
f01042bb:	75 09                	jne    f01042c6 <memfind+0x24>
f01042bd:	eb 14                	jmp    f01042d3 <memfind+0x31>
f01042bf:	0f b6 0a             	movzbl (%edx),%ecx
f01042c2:	39 d9                	cmp    %ebx,%ecx
f01042c4:	74 11                	je     f01042d7 <memfind+0x35>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f01042c6:	83 c2 01             	add    $0x1,%edx
f01042c9:	39 d0                	cmp    %edx,%eax
f01042cb:	75 f2                	jne    f01042bf <memfind+0x1d>
f01042cd:	eb 0a                	jmp    f01042d9 <memfind+0x37>
f01042cf:	89 d0                	mov    %edx,%eax
f01042d1:	eb 06                	jmp    f01042d9 <memfind+0x37>
		if (*(const unsigned char *) s == (unsigned char) c)
f01042d3:	89 d0                	mov    %edx,%eax
f01042d5:	eb 02                	jmp    f01042d9 <memfind+0x37>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f01042d7:	89 d0                	mov    %edx,%eax
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f01042d9:	5b                   	pop    %ebx
f01042da:	5d                   	pop    %ebp
f01042db:	c3                   	ret    

f01042dc <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f01042dc:	55                   	push   %ebp
f01042dd:	89 e5                	mov    %esp,%ebp
f01042df:	57                   	push   %edi
f01042e0:	56                   	push   %esi
f01042e1:	53                   	push   %ebx
f01042e2:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01042e5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01042e8:	0f b6 01             	movzbl (%ecx),%eax
f01042eb:	3c 20                	cmp    $0x20,%al
f01042ed:	74 04                	je     f01042f3 <strtol+0x17>
f01042ef:	3c 09                	cmp    $0x9,%al
f01042f1:	75 0e                	jne    f0104301 <strtol+0x25>
		s++;
f01042f3:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01042f6:	0f b6 01             	movzbl (%ecx),%eax
f01042f9:	3c 20                	cmp    $0x20,%al
f01042fb:	74 f6                	je     f01042f3 <strtol+0x17>
f01042fd:	3c 09                	cmp    $0x9,%al
f01042ff:	74 f2                	je     f01042f3 <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
f0104301:	3c 2b                	cmp    $0x2b,%al
f0104303:	75 0a                	jne    f010430f <strtol+0x33>
		s++;
f0104305:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0104308:	bf 00 00 00 00       	mov    $0x0,%edi
f010430d:	eb 11                	jmp    f0104320 <strtol+0x44>
f010430f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f0104314:	3c 2d                	cmp    $0x2d,%al
f0104316:	75 08                	jne    f0104320 <strtol+0x44>
		s++, neg = 1;
f0104318:	83 c1 01             	add    $0x1,%ecx
f010431b:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0104320:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f0104326:	75 15                	jne    f010433d <strtol+0x61>
f0104328:	80 39 30             	cmpb   $0x30,(%ecx)
f010432b:	75 10                	jne    f010433d <strtol+0x61>
f010432d:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f0104331:	75 7c                	jne    f01043af <strtol+0xd3>
		s += 2, base = 16;
f0104333:	83 c1 02             	add    $0x2,%ecx
f0104336:	bb 10 00 00 00       	mov    $0x10,%ebx
f010433b:	eb 16                	jmp    f0104353 <strtol+0x77>
	else if (base == 0 && s[0] == '0')
f010433d:	85 db                	test   %ebx,%ebx
f010433f:	75 12                	jne    f0104353 <strtol+0x77>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0104341:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0104346:	80 39 30             	cmpb   $0x30,(%ecx)
f0104349:	75 08                	jne    f0104353 <strtol+0x77>
		s++, base = 8;
f010434b:	83 c1 01             	add    $0x1,%ecx
f010434e:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
f0104353:	b8 00 00 00 00       	mov    $0x0,%eax
f0104358:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f010435b:	0f b6 11             	movzbl (%ecx),%edx
f010435e:	8d 72 d0             	lea    -0x30(%edx),%esi
f0104361:	89 f3                	mov    %esi,%ebx
f0104363:	80 fb 09             	cmp    $0x9,%bl
f0104366:	77 08                	ja     f0104370 <strtol+0x94>
			dig = *s - '0';
f0104368:	0f be d2             	movsbl %dl,%edx
f010436b:	83 ea 30             	sub    $0x30,%edx
f010436e:	eb 22                	jmp    f0104392 <strtol+0xb6>
		else if (*s >= 'a' && *s <= 'z')
f0104370:	8d 72 9f             	lea    -0x61(%edx),%esi
f0104373:	89 f3                	mov    %esi,%ebx
f0104375:	80 fb 19             	cmp    $0x19,%bl
f0104378:	77 08                	ja     f0104382 <strtol+0xa6>
			dig = *s - 'a' + 10;
f010437a:	0f be d2             	movsbl %dl,%edx
f010437d:	83 ea 57             	sub    $0x57,%edx
f0104380:	eb 10                	jmp    f0104392 <strtol+0xb6>
		else if (*s >= 'A' && *s <= 'Z')
f0104382:	8d 72 bf             	lea    -0x41(%edx),%esi
f0104385:	89 f3                	mov    %esi,%ebx
f0104387:	80 fb 19             	cmp    $0x19,%bl
f010438a:	77 16                	ja     f01043a2 <strtol+0xc6>
			dig = *s - 'A' + 10;
f010438c:	0f be d2             	movsbl %dl,%edx
f010438f:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
f0104392:	3b 55 10             	cmp    0x10(%ebp),%edx
f0104395:	7d 0b                	jge    f01043a2 <strtol+0xc6>
			break;
		s++, val = (val * base) + dig;
f0104397:	83 c1 01             	add    $0x1,%ecx
f010439a:	0f af 45 10          	imul   0x10(%ebp),%eax
f010439e:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
f01043a0:	eb b9                	jmp    f010435b <strtol+0x7f>

	if (endptr)
f01043a2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f01043a6:	74 0d                	je     f01043b5 <strtol+0xd9>
		*endptr = (char *) s;
f01043a8:	8b 75 0c             	mov    0xc(%ebp),%esi
f01043ab:	89 0e                	mov    %ecx,(%esi)
f01043ad:	eb 06                	jmp    f01043b5 <strtol+0xd9>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f01043af:	85 db                	test   %ebx,%ebx
f01043b1:	74 98                	je     f010434b <strtol+0x6f>
f01043b3:	eb 9e                	jmp    f0104353 <strtol+0x77>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
f01043b5:	89 c2                	mov    %eax,%edx
f01043b7:	f7 da                	neg    %edx
f01043b9:	85 ff                	test   %edi,%edi
f01043bb:	0f 45 c2             	cmovne %edx,%eax
}
f01043be:	5b                   	pop    %ebx
f01043bf:	5e                   	pop    %esi
f01043c0:	5f                   	pop    %edi
f01043c1:	5d                   	pop    %ebp
f01043c2:	c3                   	ret    
f01043c3:	66 90                	xchg   %ax,%ax
f01043c5:	66 90                	xchg   %ax,%ax
f01043c7:	66 90                	xchg   %ax,%ax
f01043c9:	66 90                	xchg   %ax,%ax
f01043cb:	66 90                	xchg   %ax,%ax
f01043cd:	66 90                	xchg   %ax,%ax
f01043cf:	90                   	nop

f01043d0 <__udivdi3>:
f01043d0:	55                   	push   %ebp
f01043d1:	57                   	push   %edi
f01043d2:	56                   	push   %esi
f01043d3:	53                   	push   %ebx
f01043d4:	83 ec 1c             	sub    $0x1c,%esp
f01043d7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
f01043db:	8b 5c 24 30          	mov    0x30(%esp),%ebx
f01043df:	8b 4c 24 34          	mov    0x34(%esp),%ecx
f01043e3:	8b 7c 24 38          	mov    0x38(%esp),%edi
f01043e7:	85 f6                	test   %esi,%esi
f01043e9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01043ed:	89 ca                	mov    %ecx,%edx
f01043ef:	89 f8                	mov    %edi,%eax
f01043f1:	75 3d                	jne    f0104430 <__udivdi3+0x60>
f01043f3:	39 cf                	cmp    %ecx,%edi
f01043f5:	0f 87 c5 00 00 00    	ja     f01044c0 <__udivdi3+0xf0>
f01043fb:	85 ff                	test   %edi,%edi
f01043fd:	89 fd                	mov    %edi,%ebp
f01043ff:	75 0b                	jne    f010440c <__udivdi3+0x3c>
f0104401:	b8 01 00 00 00       	mov    $0x1,%eax
f0104406:	31 d2                	xor    %edx,%edx
f0104408:	f7 f7                	div    %edi
f010440a:	89 c5                	mov    %eax,%ebp
f010440c:	89 c8                	mov    %ecx,%eax
f010440e:	31 d2                	xor    %edx,%edx
f0104410:	f7 f5                	div    %ebp
f0104412:	89 c1                	mov    %eax,%ecx
f0104414:	89 d8                	mov    %ebx,%eax
f0104416:	89 cf                	mov    %ecx,%edi
f0104418:	f7 f5                	div    %ebp
f010441a:	89 c3                	mov    %eax,%ebx
f010441c:	89 d8                	mov    %ebx,%eax
f010441e:	89 fa                	mov    %edi,%edx
f0104420:	83 c4 1c             	add    $0x1c,%esp
f0104423:	5b                   	pop    %ebx
f0104424:	5e                   	pop    %esi
f0104425:	5f                   	pop    %edi
f0104426:	5d                   	pop    %ebp
f0104427:	c3                   	ret    
f0104428:	90                   	nop
f0104429:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0104430:	39 ce                	cmp    %ecx,%esi
f0104432:	77 74                	ja     f01044a8 <__udivdi3+0xd8>
f0104434:	0f bd fe             	bsr    %esi,%edi
f0104437:	83 f7 1f             	xor    $0x1f,%edi
f010443a:	0f 84 98 00 00 00    	je     f01044d8 <__udivdi3+0x108>
f0104440:	bb 20 00 00 00       	mov    $0x20,%ebx
f0104445:	89 f9                	mov    %edi,%ecx
f0104447:	89 c5                	mov    %eax,%ebp
f0104449:	29 fb                	sub    %edi,%ebx
f010444b:	d3 e6                	shl    %cl,%esi
f010444d:	89 d9                	mov    %ebx,%ecx
f010444f:	d3 ed                	shr    %cl,%ebp
f0104451:	89 f9                	mov    %edi,%ecx
f0104453:	d3 e0                	shl    %cl,%eax
f0104455:	09 ee                	or     %ebp,%esi
f0104457:	89 d9                	mov    %ebx,%ecx
f0104459:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010445d:	89 d5                	mov    %edx,%ebp
f010445f:	8b 44 24 08          	mov    0x8(%esp),%eax
f0104463:	d3 ed                	shr    %cl,%ebp
f0104465:	89 f9                	mov    %edi,%ecx
f0104467:	d3 e2                	shl    %cl,%edx
f0104469:	89 d9                	mov    %ebx,%ecx
f010446b:	d3 e8                	shr    %cl,%eax
f010446d:	09 c2                	or     %eax,%edx
f010446f:	89 d0                	mov    %edx,%eax
f0104471:	89 ea                	mov    %ebp,%edx
f0104473:	f7 f6                	div    %esi
f0104475:	89 d5                	mov    %edx,%ebp
f0104477:	89 c3                	mov    %eax,%ebx
f0104479:	f7 64 24 0c          	mull   0xc(%esp)
f010447d:	39 d5                	cmp    %edx,%ebp
f010447f:	72 10                	jb     f0104491 <__udivdi3+0xc1>
f0104481:	8b 74 24 08          	mov    0x8(%esp),%esi
f0104485:	89 f9                	mov    %edi,%ecx
f0104487:	d3 e6                	shl    %cl,%esi
f0104489:	39 c6                	cmp    %eax,%esi
f010448b:	73 07                	jae    f0104494 <__udivdi3+0xc4>
f010448d:	39 d5                	cmp    %edx,%ebp
f010448f:	75 03                	jne    f0104494 <__udivdi3+0xc4>
f0104491:	83 eb 01             	sub    $0x1,%ebx
f0104494:	31 ff                	xor    %edi,%edi
f0104496:	89 d8                	mov    %ebx,%eax
f0104498:	89 fa                	mov    %edi,%edx
f010449a:	83 c4 1c             	add    $0x1c,%esp
f010449d:	5b                   	pop    %ebx
f010449e:	5e                   	pop    %esi
f010449f:	5f                   	pop    %edi
f01044a0:	5d                   	pop    %ebp
f01044a1:	c3                   	ret    
f01044a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01044a8:	31 ff                	xor    %edi,%edi
f01044aa:	31 db                	xor    %ebx,%ebx
f01044ac:	89 d8                	mov    %ebx,%eax
f01044ae:	89 fa                	mov    %edi,%edx
f01044b0:	83 c4 1c             	add    $0x1c,%esp
f01044b3:	5b                   	pop    %ebx
f01044b4:	5e                   	pop    %esi
f01044b5:	5f                   	pop    %edi
f01044b6:	5d                   	pop    %ebp
f01044b7:	c3                   	ret    
f01044b8:	90                   	nop
f01044b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01044c0:	89 d8                	mov    %ebx,%eax
f01044c2:	f7 f7                	div    %edi
f01044c4:	31 ff                	xor    %edi,%edi
f01044c6:	89 c3                	mov    %eax,%ebx
f01044c8:	89 d8                	mov    %ebx,%eax
f01044ca:	89 fa                	mov    %edi,%edx
f01044cc:	83 c4 1c             	add    $0x1c,%esp
f01044cf:	5b                   	pop    %ebx
f01044d0:	5e                   	pop    %esi
f01044d1:	5f                   	pop    %edi
f01044d2:	5d                   	pop    %ebp
f01044d3:	c3                   	ret    
f01044d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01044d8:	39 ce                	cmp    %ecx,%esi
f01044da:	72 0c                	jb     f01044e8 <__udivdi3+0x118>
f01044dc:	31 db                	xor    %ebx,%ebx
f01044de:	3b 44 24 08          	cmp    0x8(%esp),%eax
f01044e2:	0f 87 34 ff ff ff    	ja     f010441c <__udivdi3+0x4c>
f01044e8:	bb 01 00 00 00       	mov    $0x1,%ebx
f01044ed:	e9 2a ff ff ff       	jmp    f010441c <__udivdi3+0x4c>
f01044f2:	66 90                	xchg   %ax,%ax
f01044f4:	66 90                	xchg   %ax,%ax
f01044f6:	66 90                	xchg   %ax,%ax
f01044f8:	66 90                	xchg   %ax,%ax
f01044fa:	66 90                	xchg   %ax,%ax
f01044fc:	66 90                	xchg   %ax,%ax
f01044fe:	66 90                	xchg   %ax,%ax

f0104500 <__umoddi3>:
f0104500:	55                   	push   %ebp
f0104501:	57                   	push   %edi
f0104502:	56                   	push   %esi
f0104503:	53                   	push   %ebx
f0104504:	83 ec 1c             	sub    $0x1c,%esp
f0104507:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f010450b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
f010450f:	8b 74 24 34          	mov    0x34(%esp),%esi
f0104513:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0104517:	85 d2                	test   %edx,%edx
f0104519:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f010451d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0104521:	89 f3                	mov    %esi,%ebx
f0104523:	89 3c 24             	mov    %edi,(%esp)
f0104526:	89 74 24 04          	mov    %esi,0x4(%esp)
f010452a:	75 1c                	jne    f0104548 <__umoddi3+0x48>
f010452c:	39 f7                	cmp    %esi,%edi
f010452e:	76 50                	jbe    f0104580 <__umoddi3+0x80>
f0104530:	89 c8                	mov    %ecx,%eax
f0104532:	89 f2                	mov    %esi,%edx
f0104534:	f7 f7                	div    %edi
f0104536:	89 d0                	mov    %edx,%eax
f0104538:	31 d2                	xor    %edx,%edx
f010453a:	83 c4 1c             	add    $0x1c,%esp
f010453d:	5b                   	pop    %ebx
f010453e:	5e                   	pop    %esi
f010453f:	5f                   	pop    %edi
f0104540:	5d                   	pop    %ebp
f0104541:	c3                   	ret    
f0104542:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0104548:	39 f2                	cmp    %esi,%edx
f010454a:	89 d0                	mov    %edx,%eax
f010454c:	77 52                	ja     f01045a0 <__umoddi3+0xa0>
f010454e:	0f bd ea             	bsr    %edx,%ebp
f0104551:	83 f5 1f             	xor    $0x1f,%ebp
f0104554:	75 5a                	jne    f01045b0 <__umoddi3+0xb0>
f0104556:	3b 54 24 04          	cmp    0x4(%esp),%edx
f010455a:	0f 82 e0 00 00 00    	jb     f0104640 <__umoddi3+0x140>
f0104560:	39 0c 24             	cmp    %ecx,(%esp)
f0104563:	0f 86 d7 00 00 00    	jbe    f0104640 <__umoddi3+0x140>
f0104569:	8b 44 24 08          	mov    0x8(%esp),%eax
f010456d:	8b 54 24 04          	mov    0x4(%esp),%edx
f0104571:	83 c4 1c             	add    $0x1c,%esp
f0104574:	5b                   	pop    %ebx
f0104575:	5e                   	pop    %esi
f0104576:	5f                   	pop    %edi
f0104577:	5d                   	pop    %ebp
f0104578:	c3                   	ret    
f0104579:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0104580:	85 ff                	test   %edi,%edi
f0104582:	89 fd                	mov    %edi,%ebp
f0104584:	75 0b                	jne    f0104591 <__umoddi3+0x91>
f0104586:	b8 01 00 00 00       	mov    $0x1,%eax
f010458b:	31 d2                	xor    %edx,%edx
f010458d:	f7 f7                	div    %edi
f010458f:	89 c5                	mov    %eax,%ebp
f0104591:	89 f0                	mov    %esi,%eax
f0104593:	31 d2                	xor    %edx,%edx
f0104595:	f7 f5                	div    %ebp
f0104597:	89 c8                	mov    %ecx,%eax
f0104599:	f7 f5                	div    %ebp
f010459b:	89 d0                	mov    %edx,%eax
f010459d:	eb 99                	jmp    f0104538 <__umoddi3+0x38>
f010459f:	90                   	nop
f01045a0:	89 c8                	mov    %ecx,%eax
f01045a2:	89 f2                	mov    %esi,%edx
f01045a4:	83 c4 1c             	add    $0x1c,%esp
f01045a7:	5b                   	pop    %ebx
f01045a8:	5e                   	pop    %esi
f01045a9:	5f                   	pop    %edi
f01045aa:	5d                   	pop    %ebp
f01045ab:	c3                   	ret    
f01045ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01045b0:	8b 34 24             	mov    (%esp),%esi
f01045b3:	bf 20 00 00 00       	mov    $0x20,%edi
f01045b8:	89 e9                	mov    %ebp,%ecx
f01045ba:	29 ef                	sub    %ebp,%edi
f01045bc:	d3 e0                	shl    %cl,%eax
f01045be:	89 f9                	mov    %edi,%ecx
f01045c0:	89 f2                	mov    %esi,%edx
f01045c2:	d3 ea                	shr    %cl,%edx
f01045c4:	89 e9                	mov    %ebp,%ecx
f01045c6:	09 c2                	or     %eax,%edx
f01045c8:	89 d8                	mov    %ebx,%eax
f01045ca:	89 14 24             	mov    %edx,(%esp)
f01045cd:	89 f2                	mov    %esi,%edx
f01045cf:	d3 e2                	shl    %cl,%edx
f01045d1:	89 f9                	mov    %edi,%ecx
f01045d3:	89 54 24 04          	mov    %edx,0x4(%esp)
f01045d7:	8b 54 24 0c          	mov    0xc(%esp),%edx
f01045db:	d3 e8                	shr    %cl,%eax
f01045dd:	89 e9                	mov    %ebp,%ecx
f01045df:	89 c6                	mov    %eax,%esi
f01045e1:	d3 e3                	shl    %cl,%ebx
f01045e3:	89 f9                	mov    %edi,%ecx
f01045e5:	89 d0                	mov    %edx,%eax
f01045e7:	d3 e8                	shr    %cl,%eax
f01045e9:	89 e9                	mov    %ebp,%ecx
f01045eb:	09 d8                	or     %ebx,%eax
f01045ed:	89 d3                	mov    %edx,%ebx
f01045ef:	89 f2                	mov    %esi,%edx
f01045f1:	f7 34 24             	divl   (%esp)
f01045f4:	89 d6                	mov    %edx,%esi
f01045f6:	d3 e3                	shl    %cl,%ebx
f01045f8:	f7 64 24 04          	mull   0x4(%esp)
f01045fc:	39 d6                	cmp    %edx,%esi
f01045fe:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0104602:	89 d1                	mov    %edx,%ecx
f0104604:	89 c3                	mov    %eax,%ebx
f0104606:	72 08                	jb     f0104610 <__umoddi3+0x110>
f0104608:	75 11                	jne    f010461b <__umoddi3+0x11b>
f010460a:	39 44 24 08          	cmp    %eax,0x8(%esp)
f010460e:	73 0b                	jae    f010461b <__umoddi3+0x11b>
f0104610:	2b 44 24 04          	sub    0x4(%esp),%eax
f0104614:	1b 14 24             	sbb    (%esp),%edx
f0104617:	89 d1                	mov    %edx,%ecx
f0104619:	89 c3                	mov    %eax,%ebx
f010461b:	8b 54 24 08          	mov    0x8(%esp),%edx
f010461f:	29 da                	sub    %ebx,%edx
f0104621:	19 ce                	sbb    %ecx,%esi
f0104623:	89 f9                	mov    %edi,%ecx
f0104625:	89 f0                	mov    %esi,%eax
f0104627:	d3 e0                	shl    %cl,%eax
f0104629:	89 e9                	mov    %ebp,%ecx
f010462b:	d3 ea                	shr    %cl,%edx
f010462d:	89 e9                	mov    %ebp,%ecx
f010462f:	d3 ee                	shr    %cl,%esi
f0104631:	09 d0                	or     %edx,%eax
f0104633:	89 f2                	mov    %esi,%edx
f0104635:	83 c4 1c             	add    $0x1c,%esp
f0104638:	5b                   	pop    %ebx
f0104639:	5e                   	pop    %esi
f010463a:	5f                   	pop    %edi
f010463b:	5d                   	pop    %ebp
f010463c:	c3                   	ret    
f010463d:	8d 76 00             	lea    0x0(%esi),%esi
f0104640:	29 f9                	sub    %edi,%ecx
f0104642:	19 d6                	sbb    %edx,%esi
f0104644:	89 74 24 04          	mov    %esi,0x4(%esp)
f0104648:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f010464c:	e9 18 ff ff ff       	jmp    f0104569 <__umoddi3+0x69>
