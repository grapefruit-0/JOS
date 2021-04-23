
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
	# sufficient until we set up our real page table in mem_init
	# in lab 2.

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	movl	$(RELOC(entry_pgdir)), %eax
f0100015:	b8 00 30 11 00       	mov    $0x113000,%eax
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
f0100034:	bc 00 10 11 f0       	mov    $0xf0111000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 6c 00 00 00       	call   f01000aa <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <test_backtrace>:
#include <kern/console.h>

// Test the stack backtrace function (lab 1 only)
void
test_backtrace(int x)
{
f0100040:	f3 0f 1e fb          	endbr32 
f0100044:	55                   	push   %ebp
f0100045:	89 e5                	mov    %esp,%ebp
f0100047:	56                   	push   %esi
f0100048:	53                   	push   %ebx
f0100049:	e8 7e 01 00 00       	call   f01001cc <__x86.get_pc_thunk.bx>
f010004e:	81 c3 ba 22 01 00    	add    $0x122ba,%ebx
f0100054:	8b 75 08             	mov    0x8(%ebp),%esi
	cprintf("entering test_backtrace %d\n", x);
f0100057:	83 ec 08             	sub    $0x8,%esp
f010005a:	56                   	push   %esi
f010005b:	8d 83 38 fa fe ff    	lea    -0x105c8(%ebx),%eax
f0100061:	50                   	push   %eax
f0100062:	e8 f0 0b 00 00       	call   f0100c57 <cprintf>
	if (x > 0)
f0100067:	83 c4 10             	add    $0x10,%esp
f010006a:	85 f6                	test   %esi,%esi
f010006c:	7e 29                	jle    f0100097 <test_backtrace+0x57>
		test_backtrace(x-1);
f010006e:	83 ec 0c             	sub    $0xc,%esp
f0100071:	8d 46 ff             	lea    -0x1(%esi),%eax
f0100074:	50                   	push   %eax
f0100075:	e8 c6 ff ff ff       	call   f0100040 <test_backtrace>
f010007a:	83 c4 10             	add    $0x10,%esp
	else
		mon_backtrace(0, 0, 0);
    cprintf("leaving test_backtrace %d\n", x);
f010007d:	83 ec 08             	sub    $0x8,%esp
f0100080:	56                   	push   %esi
f0100081:	8d 83 54 fa fe ff    	lea    -0x105ac(%ebx),%eax
f0100087:	50                   	push   %eax
f0100088:	e8 ca 0b 00 00       	call   f0100c57 <cprintf>
}
f010008d:	83 c4 10             	add    $0x10,%esp
f0100090:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100093:	5b                   	pop    %ebx
f0100094:	5e                   	pop    %esi
f0100095:	5d                   	pop    %ebp
f0100096:	c3                   	ret    
		mon_backtrace(0, 0, 0);
f0100097:	83 ec 04             	sub    $0x4,%esp
f010009a:	6a 00                	push   $0x0
f010009c:	6a 00                	push   $0x0
f010009e:	6a 00                	push   $0x0
f01000a0:	e8 0c 08 00 00       	call   f01008b1 <mon_backtrace>
f01000a5:	83 c4 10             	add    $0x10,%esp
f01000a8:	eb d3                	jmp    f010007d <test_backtrace+0x3d>

f01000aa <i386_init>:

void
i386_init(void)
{
f01000aa:	f3 0f 1e fb          	endbr32 
f01000ae:	55                   	push   %ebp
f01000af:	89 e5                	mov    %esp,%ebp
f01000b1:	53                   	push   %ebx
f01000b2:	83 ec 08             	sub    $0x8,%esp
f01000b5:	e8 12 01 00 00       	call   f01001cc <__x86.get_pc_thunk.bx>
f01000ba:	81 c3 4e 22 01 00    	add    $0x1224e,%ebx
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f01000c0:	c7 c2 60 40 11 f0    	mov    $0xf0114060,%edx
f01000c6:	c7 c0 a0 46 11 f0    	mov    $0xf01146a0,%eax
f01000cc:	29 d0                	sub    %edx,%eax
f01000ce:	50                   	push   %eax
f01000cf:	6a 00                	push   $0x0
f01000d1:	52                   	push   %edx
f01000d2:	e8 e2 17 00 00       	call   f01018b9 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000d7:	e8 4b 05 00 00       	call   f0100627 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000dc:	83 c4 08             	add    $0x8,%esp
f01000df:	68 ac 1a 00 00       	push   $0x1aac
f01000e4:	8d 83 6f fa fe ff    	lea    -0x10591(%ebx),%eax
f01000ea:	50                   	push   %eax
f01000eb:	e8 67 0b 00 00       	call   f0100c57 <cprintf>

	// Test the stack backtrace function (lab 1 only)
	test_backtrace(5);
f01000f0:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
f01000f7:	e8 44 ff ff ff       	call   f0100040 <test_backtrace>
f01000fc:	83 c4 10             	add    $0x10,%esp

	// Drop into the kernel monitor.
	while (1)
		monitor(NULL);
f01000ff:	83 ec 0c             	sub    $0xc,%esp
f0100102:	6a 00                	push   $0x0
f0100104:	e8 92 08 00 00       	call   f010099b <monitor>
f0100109:	83 c4 10             	add    $0x10,%esp
f010010c:	eb f1                	jmp    f01000ff <i386_init+0x55>

f010010e <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f010010e:	f3 0f 1e fb          	endbr32 
f0100112:	55                   	push   %ebp
f0100113:	89 e5                	mov    %esp,%ebp
f0100115:	57                   	push   %edi
f0100116:	56                   	push   %esi
f0100117:	53                   	push   %ebx
f0100118:	83 ec 0c             	sub    $0xc,%esp
f010011b:	e8 ac 00 00 00       	call   f01001cc <__x86.get_pc_thunk.bx>
f0100120:	81 c3 e8 21 01 00    	add    $0x121e8,%ebx
f0100126:	8b 7d 10             	mov    0x10(%ebp),%edi
	va_list ap;

	if (panicstr)
f0100129:	c7 c0 a4 46 11 f0    	mov    $0xf01146a4,%eax
f010012f:	83 38 00             	cmpl   $0x0,(%eax)
f0100132:	74 0f                	je     f0100143 <_panic+0x35>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f0100134:	83 ec 0c             	sub    $0xc,%esp
f0100137:	6a 00                	push   $0x0
f0100139:	e8 5d 08 00 00       	call   f010099b <monitor>
f010013e:	83 c4 10             	add    $0x10,%esp
f0100141:	eb f1                	jmp    f0100134 <_panic+0x26>
	panicstr = fmt;
f0100143:	89 38                	mov    %edi,(%eax)
	asm volatile("cli; cld");
f0100145:	fa                   	cli    
f0100146:	fc                   	cld    
	va_start(ap, fmt);
f0100147:	8d 75 14             	lea    0x14(%ebp),%esi
	cprintf("kernel panic at %s:%d: ", file, line);
f010014a:	83 ec 04             	sub    $0x4,%esp
f010014d:	ff 75 0c             	pushl  0xc(%ebp)
f0100150:	ff 75 08             	pushl  0x8(%ebp)
f0100153:	8d 83 8a fa fe ff    	lea    -0x10576(%ebx),%eax
f0100159:	50                   	push   %eax
f010015a:	e8 f8 0a 00 00       	call   f0100c57 <cprintf>
	vcprintf(fmt, ap);
f010015f:	83 c4 08             	add    $0x8,%esp
f0100162:	56                   	push   %esi
f0100163:	57                   	push   %edi
f0100164:	e8 b3 0a 00 00       	call   f0100c1c <vcprintf>
	cprintf("\n");
f0100169:	8d 83 c6 fa fe ff    	lea    -0x1053a(%ebx),%eax
f010016f:	89 04 24             	mov    %eax,(%esp)
f0100172:	e8 e0 0a 00 00       	call   f0100c57 <cprintf>
f0100177:	83 c4 10             	add    $0x10,%esp
f010017a:	eb b8                	jmp    f0100134 <_panic+0x26>

f010017c <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f010017c:	f3 0f 1e fb          	endbr32 
f0100180:	55                   	push   %ebp
f0100181:	89 e5                	mov    %esp,%ebp
f0100183:	56                   	push   %esi
f0100184:	53                   	push   %ebx
f0100185:	e8 42 00 00 00       	call   f01001cc <__x86.get_pc_thunk.bx>
f010018a:	81 c3 7e 21 01 00    	add    $0x1217e,%ebx
	va_list ap;

	va_start(ap, fmt);
f0100190:	8d 75 14             	lea    0x14(%ebp),%esi
	cprintf("kernel warning at %s:%d: ", file, line);
f0100193:	83 ec 04             	sub    $0x4,%esp
f0100196:	ff 75 0c             	pushl  0xc(%ebp)
f0100199:	ff 75 08             	pushl  0x8(%ebp)
f010019c:	8d 83 a2 fa fe ff    	lea    -0x1055e(%ebx),%eax
f01001a2:	50                   	push   %eax
f01001a3:	e8 af 0a 00 00       	call   f0100c57 <cprintf>
	vcprintf(fmt, ap);
f01001a8:	83 c4 08             	add    $0x8,%esp
f01001ab:	56                   	push   %esi
f01001ac:	ff 75 10             	pushl  0x10(%ebp)
f01001af:	e8 68 0a 00 00       	call   f0100c1c <vcprintf>
	cprintf("\n");
f01001b4:	8d 83 c6 fa fe ff    	lea    -0x1053a(%ebx),%eax
f01001ba:	89 04 24             	mov    %eax,(%esp)
f01001bd:	e8 95 0a 00 00       	call   f0100c57 <cprintf>
	va_end(ap);
}
f01001c2:	83 c4 10             	add    $0x10,%esp
f01001c5:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01001c8:	5b                   	pop    %ebx
f01001c9:	5e                   	pop    %esi
f01001ca:	5d                   	pop    %ebp
f01001cb:	c3                   	ret    

f01001cc <__x86.get_pc_thunk.bx>:
f01001cc:	8b 1c 24             	mov    (%esp),%ebx
f01001cf:	c3                   	ret    

f01001d0 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f01001d0:	f3 0f 1e fb          	endbr32 

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01001d4:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01001d9:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f01001da:	a8 01                	test   $0x1,%al
f01001dc:	74 0a                	je     f01001e8 <serial_proc_data+0x18>
f01001de:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01001e3:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f01001e4:	0f b6 c0             	movzbl %al,%eax
f01001e7:	c3                   	ret    
		return -1;
f01001e8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
f01001ed:	c3                   	ret    

f01001ee <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f01001ee:	55                   	push   %ebp
f01001ef:	89 e5                	mov    %esp,%ebp
f01001f1:	57                   	push   %edi
f01001f2:	56                   	push   %esi
f01001f3:	53                   	push   %ebx
f01001f4:	83 ec 1c             	sub    $0x1c,%esp
f01001f7:	e8 88 05 00 00       	call   f0100784 <__x86.get_pc_thunk.si>
f01001fc:	81 c6 0c 21 01 00    	add    $0x1210c,%esi
f0100202:	89 c7                	mov    %eax,%edi
	int c;

	while ((c = (*proc)()) != -1) {
		if (c == 0)
			continue;
		cons.buf[cons.wpos++] = c;
f0100204:	8d 1d 78 1d 00 00    	lea    0x1d78,%ebx
f010020a:	8d 04 1e             	lea    (%esi,%ebx,1),%eax
f010020d:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100210:	89 7d e4             	mov    %edi,-0x1c(%ebp)
	while ((c = (*proc)()) != -1) {
f0100213:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100216:	ff d0                	call   *%eax
f0100218:	83 f8 ff             	cmp    $0xffffffff,%eax
f010021b:	74 2b                	je     f0100248 <cons_intr+0x5a>
		if (c == 0)
f010021d:	85 c0                	test   %eax,%eax
f010021f:	74 f2                	je     f0100213 <cons_intr+0x25>
		cons.buf[cons.wpos++] = c;
f0100221:	8b 8c 1e 04 02 00 00 	mov    0x204(%esi,%ebx,1),%ecx
f0100228:	8d 51 01             	lea    0x1(%ecx),%edx
f010022b:	8b 7d e0             	mov    -0x20(%ebp),%edi
f010022e:	88 04 0f             	mov    %al,(%edi,%ecx,1)
		if (cons.wpos == CONSBUFSIZE)
f0100231:	81 fa 00 02 00 00    	cmp    $0x200,%edx
			cons.wpos = 0;
f0100237:	b8 00 00 00 00       	mov    $0x0,%eax
f010023c:	0f 44 d0             	cmove  %eax,%edx
f010023f:	89 94 1e 04 02 00 00 	mov    %edx,0x204(%esi,%ebx,1)
f0100246:	eb cb                	jmp    f0100213 <cons_intr+0x25>
	}
}
f0100248:	83 c4 1c             	add    $0x1c,%esp
f010024b:	5b                   	pop    %ebx
f010024c:	5e                   	pop    %esi
f010024d:	5f                   	pop    %edi
f010024e:	5d                   	pop    %ebp
f010024f:	c3                   	ret    

f0100250 <kbd_proc_data>:
{
f0100250:	f3 0f 1e fb          	endbr32 
f0100254:	55                   	push   %ebp
f0100255:	89 e5                	mov    %esp,%ebp
f0100257:	56                   	push   %esi
f0100258:	53                   	push   %ebx
f0100259:	e8 6e ff ff ff       	call   f01001cc <__x86.get_pc_thunk.bx>
f010025e:	81 c3 aa 20 01 00    	add    $0x120aa,%ebx
f0100264:	ba 64 00 00 00       	mov    $0x64,%edx
f0100269:	ec                   	in     (%dx),%al
	if ((stat & KBS_DIB) == 0)
f010026a:	a8 01                	test   $0x1,%al
f010026c:	0f 84 fb 00 00 00    	je     f010036d <kbd_proc_data+0x11d>
	if (stat & KBS_TERR)
f0100272:	a8 20                	test   $0x20,%al
f0100274:	0f 85 fa 00 00 00    	jne    f0100374 <kbd_proc_data+0x124>
f010027a:	ba 60 00 00 00       	mov    $0x60,%edx
f010027f:	ec                   	in     (%dx),%al
f0100280:	89 c2                	mov    %eax,%edx
	if (data == 0xE0) {
f0100282:	3c e0                	cmp    $0xe0,%al
f0100284:	74 64                	je     f01002ea <kbd_proc_data+0x9a>
	} else if (data & 0x80) {
f0100286:	84 c0                	test   %al,%al
f0100288:	78 75                	js     f01002ff <kbd_proc_data+0xaf>
	} else if (shift & E0ESC) {
f010028a:	8b 8b 58 1d 00 00    	mov    0x1d58(%ebx),%ecx
f0100290:	f6 c1 40             	test   $0x40,%cl
f0100293:	74 0e                	je     f01002a3 <kbd_proc_data+0x53>
		data |= 0x80;
f0100295:	83 c8 80             	or     $0xffffff80,%eax
f0100298:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f010029a:	83 e1 bf             	and    $0xffffffbf,%ecx
f010029d:	89 8b 58 1d 00 00    	mov    %ecx,0x1d58(%ebx)
	shift |= shiftcode[data];
f01002a3:	0f b6 d2             	movzbl %dl,%edx
f01002a6:	0f b6 84 13 f8 fb fe 	movzbl -0x10408(%ebx,%edx,1),%eax
f01002ad:	ff 
f01002ae:	0b 83 58 1d 00 00    	or     0x1d58(%ebx),%eax
	shift ^= togglecode[data];
f01002b4:	0f b6 8c 13 f8 fa fe 	movzbl -0x10508(%ebx,%edx,1),%ecx
f01002bb:	ff 
f01002bc:	31 c8                	xor    %ecx,%eax
f01002be:	89 83 58 1d 00 00    	mov    %eax,0x1d58(%ebx)
	c = charcode[shift & (CTL | SHIFT)][data];
f01002c4:	89 c1                	mov    %eax,%ecx
f01002c6:	83 e1 03             	and    $0x3,%ecx
f01002c9:	8b 8c 8b f8 1c 00 00 	mov    0x1cf8(%ebx,%ecx,4),%ecx
f01002d0:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f01002d4:	0f b6 f2             	movzbl %dl,%esi
	if (shift & CAPSLOCK) {
f01002d7:	a8 08                	test   $0x8,%al
f01002d9:	74 65                	je     f0100340 <kbd_proc_data+0xf0>
		if ('a' <= c && c <= 'z')
f01002db:	89 f2                	mov    %esi,%edx
f01002dd:	8d 4e 9f             	lea    -0x61(%esi),%ecx
f01002e0:	83 f9 19             	cmp    $0x19,%ecx
f01002e3:	77 4f                	ja     f0100334 <kbd_proc_data+0xe4>
			c += 'A' - 'a';
f01002e5:	83 ee 20             	sub    $0x20,%esi
f01002e8:	eb 0c                	jmp    f01002f6 <kbd_proc_data+0xa6>
		shift |= E0ESC;
f01002ea:	83 8b 58 1d 00 00 40 	orl    $0x40,0x1d58(%ebx)
		return 0;
f01002f1:	be 00 00 00 00       	mov    $0x0,%esi
}
f01002f6:	89 f0                	mov    %esi,%eax
f01002f8:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01002fb:	5b                   	pop    %ebx
f01002fc:	5e                   	pop    %esi
f01002fd:	5d                   	pop    %ebp
f01002fe:	c3                   	ret    
		data = (shift & E0ESC ? data : data & 0x7F);
f01002ff:	8b 8b 58 1d 00 00    	mov    0x1d58(%ebx),%ecx
f0100305:	89 ce                	mov    %ecx,%esi
f0100307:	83 e6 40             	and    $0x40,%esi
f010030a:	83 e0 7f             	and    $0x7f,%eax
f010030d:	85 f6                	test   %esi,%esi
f010030f:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f0100312:	0f b6 d2             	movzbl %dl,%edx
f0100315:	0f b6 84 13 f8 fb fe 	movzbl -0x10408(%ebx,%edx,1),%eax
f010031c:	ff 
f010031d:	83 c8 40             	or     $0x40,%eax
f0100320:	0f b6 c0             	movzbl %al,%eax
f0100323:	f7 d0                	not    %eax
f0100325:	21 c8                	and    %ecx,%eax
f0100327:	89 83 58 1d 00 00    	mov    %eax,0x1d58(%ebx)
		return 0;
f010032d:	be 00 00 00 00       	mov    $0x0,%esi
f0100332:	eb c2                	jmp    f01002f6 <kbd_proc_data+0xa6>
		else if ('A' <= c && c <= 'Z')
f0100334:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f0100337:	8d 4e 20             	lea    0x20(%esi),%ecx
f010033a:	83 fa 1a             	cmp    $0x1a,%edx
f010033d:	0f 42 f1             	cmovb  %ecx,%esi
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f0100340:	f7 d0                	not    %eax
f0100342:	a8 06                	test   $0x6,%al
f0100344:	75 b0                	jne    f01002f6 <kbd_proc_data+0xa6>
f0100346:	81 fe e9 00 00 00    	cmp    $0xe9,%esi
f010034c:	75 a8                	jne    f01002f6 <kbd_proc_data+0xa6>
		cprintf("Rebooting!\n");
f010034e:	83 ec 0c             	sub    $0xc,%esp
f0100351:	8d 83 bc fa fe ff    	lea    -0x10544(%ebx),%eax
f0100357:	50                   	push   %eax
f0100358:	e8 fa 08 00 00       	call   f0100c57 <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010035d:	b8 03 00 00 00       	mov    $0x3,%eax
f0100362:	ba 92 00 00 00       	mov    $0x92,%edx
f0100367:	ee                   	out    %al,(%dx)
}
f0100368:	83 c4 10             	add    $0x10,%esp
f010036b:	eb 89                	jmp    f01002f6 <kbd_proc_data+0xa6>
		return -1;
f010036d:	be ff ff ff ff       	mov    $0xffffffff,%esi
f0100372:	eb 82                	jmp    f01002f6 <kbd_proc_data+0xa6>
		return -1;
f0100374:	be ff ff ff ff       	mov    $0xffffffff,%esi
f0100379:	e9 78 ff ff ff       	jmp    f01002f6 <kbd_proc_data+0xa6>

f010037e <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f010037e:	55                   	push   %ebp
f010037f:	89 e5                	mov    %esp,%ebp
f0100381:	57                   	push   %edi
f0100382:	56                   	push   %esi
f0100383:	53                   	push   %ebx
f0100384:	83 ec 1c             	sub    $0x1c,%esp
f0100387:	e8 40 fe ff ff       	call   f01001cc <__x86.get_pc_thunk.bx>
f010038c:	81 c3 7c 1f 01 00    	add    $0x11f7c,%ebx
f0100392:	89 c7                	mov    %eax,%edi
	for (i = 0;
f0100394:	be 00 00 00 00       	mov    $0x0,%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100399:	b9 84 00 00 00       	mov    $0x84,%ecx
f010039e:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01003a3:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f01003a4:	a8 20                	test   $0x20,%al
f01003a6:	75 13                	jne    f01003bb <cons_putc+0x3d>
f01003a8:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
f01003ae:	7f 0b                	jg     f01003bb <cons_putc+0x3d>
f01003b0:	89 ca                	mov    %ecx,%edx
f01003b2:	ec                   	in     (%dx),%al
f01003b3:	ec                   	in     (%dx),%al
f01003b4:	ec                   	in     (%dx),%al
f01003b5:	ec                   	in     (%dx),%al
	     i++)
f01003b6:	83 c6 01             	add    $0x1,%esi
f01003b9:	eb e3                	jmp    f010039e <cons_putc+0x20>
	outb(COM1 + COM_TX, c);
f01003bb:	89 f8                	mov    %edi,%eax
f01003bd:	88 45 e7             	mov    %al,-0x19(%ebp)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003c0:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01003c5:	ee                   	out    %al,(%dx)
	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f01003c6:	be 00 00 00 00       	mov    $0x0,%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01003cb:	b9 84 00 00 00       	mov    $0x84,%ecx
f01003d0:	ba 79 03 00 00       	mov    $0x379,%edx
f01003d5:	ec                   	in     (%dx),%al
f01003d6:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
f01003dc:	7f 0f                	jg     f01003ed <cons_putc+0x6f>
f01003de:	84 c0                	test   %al,%al
f01003e0:	78 0b                	js     f01003ed <cons_putc+0x6f>
f01003e2:	89 ca                	mov    %ecx,%edx
f01003e4:	ec                   	in     (%dx),%al
f01003e5:	ec                   	in     (%dx),%al
f01003e6:	ec                   	in     (%dx),%al
f01003e7:	ec                   	in     (%dx),%al
f01003e8:	83 c6 01             	add    $0x1,%esi
f01003eb:	eb e3                	jmp    f01003d0 <cons_putc+0x52>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003ed:	ba 78 03 00 00       	mov    $0x378,%edx
f01003f2:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f01003f6:	ee                   	out    %al,(%dx)
f01003f7:	ba 7a 03 00 00       	mov    $0x37a,%edx
f01003fc:	b8 0d 00 00 00       	mov    $0xd,%eax
f0100401:	ee                   	out    %al,(%dx)
f0100402:	b8 08 00 00 00       	mov    $0x8,%eax
f0100407:	ee                   	out    %al,(%dx)
		c |= 0x0700;
f0100408:	89 f8                	mov    %edi,%eax
f010040a:	80 cc 07             	or     $0x7,%ah
f010040d:	f7 c7 00 ff ff ff    	test   $0xffffff00,%edi
f0100413:	0f 44 f8             	cmove  %eax,%edi
	switch (c & 0xff) {
f0100416:	89 f8                	mov    %edi,%eax
f0100418:	0f b6 c0             	movzbl %al,%eax
f010041b:	89 f9                	mov    %edi,%ecx
f010041d:	80 f9 0a             	cmp    $0xa,%cl
f0100420:	0f 84 e2 00 00 00    	je     f0100508 <cons_putc+0x18a>
f0100426:	83 f8 0a             	cmp    $0xa,%eax
f0100429:	7f 46                	jg     f0100471 <cons_putc+0xf3>
f010042b:	83 f8 08             	cmp    $0x8,%eax
f010042e:	0f 84 a8 00 00 00    	je     f01004dc <cons_putc+0x15e>
f0100434:	83 f8 09             	cmp    $0x9,%eax
f0100437:	0f 85 d8 00 00 00    	jne    f0100515 <cons_putc+0x197>
		cons_putc(' ');
f010043d:	b8 20 00 00 00       	mov    $0x20,%eax
f0100442:	e8 37 ff ff ff       	call   f010037e <cons_putc>
		cons_putc(' ');
f0100447:	b8 20 00 00 00       	mov    $0x20,%eax
f010044c:	e8 2d ff ff ff       	call   f010037e <cons_putc>
		cons_putc(' ');
f0100451:	b8 20 00 00 00       	mov    $0x20,%eax
f0100456:	e8 23 ff ff ff       	call   f010037e <cons_putc>
		cons_putc(' ');
f010045b:	b8 20 00 00 00       	mov    $0x20,%eax
f0100460:	e8 19 ff ff ff       	call   f010037e <cons_putc>
		cons_putc(' ');
f0100465:	b8 20 00 00 00       	mov    $0x20,%eax
f010046a:	e8 0f ff ff ff       	call   f010037e <cons_putc>
		break;
f010046f:	eb 26                	jmp    f0100497 <cons_putc+0x119>
	switch (c & 0xff) {
f0100471:	83 f8 0d             	cmp    $0xd,%eax
f0100474:	0f 85 9b 00 00 00    	jne    f0100515 <cons_putc+0x197>
		crt_pos -= (crt_pos % CRT_COLS);
f010047a:	0f b7 83 80 1f 00 00 	movzwl 0x1f80(%ebx),%eax
f0100481:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f0100487:	c1 e8 16             	shr    $0x16,%eax
f010048a:	8d 04 80             	lea    (%eax,%eax,4),%eax
f010048d:	c1 e0 04             	shl    $0x4,%eax
f0100490:	66 89 83 80 1f 00 00 	mov    %ax,0x1f80(%ebx)
	if (crt_pos >= CRT_SIZE) {
f0100497:	66 81 bb 80 1f 00 00 	cmpw   $0x7cf,0x1f80(%ebx)
f010049e:	cf 07 
f01004a0:	0f 87 92 00 00 00    	ja     f0100538 <cons_putc+0x1ba>
	outb(addr_6845, 14);
f01004a6:	8b 8b 88 1f 00 00    	mov    0x1f88(%ebx),%ecx
f01004ac:	b8 0e 00 00 00       	mov    $0xe,%eax
f01004b1:	89 ca                	mov    %ecx,%edx
f01004b3:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01004b4:	0f b7 9b 80 1f 00 00 	movzwl 0x1f80(%ebx),%ebx
f01004bb:	8d 71 01             	lea    0x1(%ecx),%esi
f01004be:	89 d8                	mov    %ebx,%eax
f01004c0:	66 c1 e8 08          	shr    $0x8,%ax
f01004c4:	89 f2                	mov    %esi,%edx
f01004c6:	ee                   	out    %al,(%dx)
f01004c7:	b8 0f 00 00 00       	mov    $0xf,%eax
f01004cc:	89 ca                	mov    %ecx,%edx
f01004ce:	ee                   	out    %al,(%dx)
f01004cf:	89 d8                	mov    %ebx,%eax
f01004d1:	89 f2                	mov    %esi,%edx
f01004d3:	ee                   	out    %al,(%dx)
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f01004d4:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01004d7:	5b                   	pop    %ebx
f01004d8:	5e                   	pop    %esi
f01004d9:	5f                   	pop    %edi
f01004da:	5d                   	pop    %ebp
f01004db:	c3                   	ret    
		if (crt_pos > 0) {
f01004dc:	0f b7 83 80 1f 00 00 	movzwl 0x1f80(%ebx),%eax
f01004e3:	66 85 c0             	test   %ax,%ax
f01004e6:	74 be                	je     f01004a6 <cons_putc+0x128>
			crt_pos--;
f01004e8:	83 e8 01             	sub    $0x1,%eax
f01004eb:	66 89 83 80 1f 00 00 	mov    %ax,0x1f80(%ebx)
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01004f2:	0f b7 c0             	movzwl %ax,%eax
f01004f5:	89 fa                	mov    %edi,%edx
f01004f7:	b2 00                	mov    $0x0,%dl
f01004f9:	83 ca 20             	or     $0x20,%edx
f01004fc:	8b 8b 84 1f 00 00    	mov    0x1f84(%ebx),%ecx
f0100502:	66 89 14 41          	mov    %dx,(%ecx,%eax,2)
f0100506:	eb 8f                	jmp    f0100497 <cons_putc+0x119>
		crt_pos += CRT_COLS;
f0100508:	66 83 83 80 1f 00 00 	addw   $0x50,0x1f80(%ebx)
f010050f:	50 
f0100510:	e9 65 ff ff ff       	jmp    f010047a <cons_putc+0xfc>
		crt_buf[crt_pos++] = c;		/* write the character */
f0100515:	0f b7 83 80 1f 00 00 	movzwl 0x1f80(%ebx),%eax
f010051c:	8d 50 01             	lea    0x1(%eax),%edx
f010051f:	66 89 93 80 1f 00 00 	mov    %dx,0x1f80(%ebx)
f0100526:	0f b7 c0             	movzwl %ax,%eax
f0100529:	8b 93 84 1f 00 00    	mov    0x1f84(%ebx),%edx
f010052f:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
f0100533:	e9 5f ff ff ff       	jmp    f0100497 <cons_putc+0x119>
		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100538:	8b 83 84 1f 00 00    	mov    0x1f84(%ebx),%eax
f010053e:	83 ec 04             	sub    $0x4,%esp
f0100541:	68 00 0f 00 00       	push   $0xf00
f0100546:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f010054c:	52                   	push   %edx
f010054d:	50                   	push   %eax
f010054e:	e8 b2 13 00 00       	call   f0101905 <memmove>
			crt_buf[i] = 0x0700 | ' ';
f0100553:	8b 93 84 1f 00 00    	mov    0x1f84(%ebx),%edx
f0100559:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f010055f:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f0100565:	83 c4 10             	add    $0x10,%esp
f0100568:	66 c7 00 20 07       	movw   $0x720,(%eax)
f010056d:	83 c0 02             	add    $0x2,%eax
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100570:	39 d0                	cmp    %edx,%eax
f0100572:	75 f4                	jne    f0100568 <cons_putc+0x1ea>
		crt_pos -= CRT_COLS;
f0100574:	66 83 ab 80 1f 00 00 	subw   $0x50,0x1f80(%ebx)
f010057b:	50 
f010057c:	e9 25 ff ff ff       	jmp    f01004a6 <cons_putc+0x128>

f0100581 <serial_intr>:
{
f0100581:	f3 0f 1e fb          	endbr32 
f0100585:	e8 f6 01 00 00       	call   f0100780 <__x86.get_pc_thunk.ax>
f010058a:	05 7e 1d 01 00       	add    $0x11d7e,%eax
	if (serial_exists)
f010058f:	80 b8 8c 1f 00 00 00 	cmpb   $0x0,0x1f8c(%eax)
f0100596:	75 01                	jne    f0100599 <serial_intr+0x18>
f0100598:	c3                   	ret    
{
f0100599:	55                   	push   %ebp
f010059a:	89 e5                	mov    %esp,%ebp
f010059c:	83 ec 08             	sub    $0x8,%esp
		cons_intr(serial_proc_data);
f010059f:	8d 80 c8 de fe ff    	lea    -0x12138(%eax),%eax
f01005a5:	e8 44 fc ff ff       	call   f01001ee <cons_intr>
}
f01005aa:	c9                   	leave  
f01005ab:	c3                   	ret    

f01005ac <kbd_intr>:
{
f01005ac:	f3 0f 1e fb          	endbr32 
f01005b0:	55                   	push   %ebp
f01005b1:	89 e5                	mov    %esp,%ebp
f01005b3:	83 ec 08             	sub    $0x8,%esp
f01005b6:	e8 c5 01 00 00       	call   f0100780 <__x86.get_pc_thunk.ax>
f01005bb:	05 4d 1d 01 00       	add    $0x11d4d,%eax
	cons_intr(kbd_proc_data);
f01005c0:	8d 80 48 df fe ff    	lea    -0x120b8(%eax),%eax
f01005c6:	e8 23 fc ff ff       	call   f01001ee <cons_intr>
}
f01005cb:	c9                   	leave  
f01005cc:	c3                   	ret    

f01005cd <cons_getc>:
{
f01005cd:	f3 0f 1e fb          	endbr32 
f01005d1:	55                   	push   %ebp
f01005d2:	89 e5                	mov    %esp,%ebp
f01005d4:	53                   	push   %ebx
f01005d5:	83 ec 04             	sub    $0x4,%esp
f01005d8:	e8 ef fb ff ff       	call   f01001cc <__x86.get_pc_thunk.bx>
f01005dd:	81 c3 2b 1d 01 00    	add    $0x11d2b,%ebx
	serial_intr();
f01005e3:	e8 99 ff ff ff       	call   f0100581 <serial_intr>
	kbd_intr();
f01005e8:	e8 bf ff ff ff       	call   f01005ac <kbd_intr>
	if (cons.rpos != cons.wpos) {
f01005ed:	8b 83 78 1f 00 00    	mov    0x1f78(%ebx),%eax
	return 0;
f01005f3:	ba 00 00 00 00       	mov    $0x0,%edx
	if (cons.rpos != cons.wpos) {
f01005f8:	3b 83 7c 1f 00 00    	cmp    0x1f7c(%ebx),%eax
f01005fe:	74 1f                	je     f010061f <cons_getc+0x52>
		c = cons.buf[cons.rpos++];
f0100600:	8d 48 01             	lea    0x1(%eax),%ecx
f0100603:	0f b6 94 03 78 1d 00 	movzbl 0x1d78(%ebx,%eax,1),%edx
f010060a:	00 
			cons.rpos = 0;
f010060b:	81 f9 00 02 00 00    	cmp    $0x200,%ecx
f0100611:	b8 00 00 00 00       	mov    $0x0,%eax
f0100616:	0f 44 c8             	cmove  %eax,%ecx
f0100619:	89 8b 78 1f 00 00    	mov    %ecx,0x1f78(%ebx)
}
f010061f:	89 d0                	mov    %edx,%eax
f0100621:	83 c4 04             	add    $0x4,%esp
f0100624:	5b                   	pop    %ebx
f0100625:	5d                   	pop    %ebp
f0100626:	c3                   	ret    

f0100627 <cons_init>:

// initialize the console devices
void
cons_init(void)
{
f0100627:	f3 0f 1e fb          	endbr32 
f010062b:	55                   	push   %ebp
f010062c:	89 e5                	mov    %esp,%ebp
f010062e:	57                   	push   %edi
f010062f:	56                   	push   %esi
f0100630:	53                   	push   %ebx
f0100631:	83 ec 1c             	sub    $0x1c,%esp
f0100634:	e8 93 fb ff ff       	call   f01001cc <__x86.get_pc_thunk.bx>
f0100639:	81 c3 cf 1c 01 00    	add    $0x11ccf,%ebx
	was = *cp;
f010063f:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f0100646:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f010064d:	5a a5 
	if (*cp != 0xA55A) {
f010064f:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f0100656:	66 3d 5a a5          	cmp    $0xa55a,%ax
f010065a:	0f 84 bc 00 00 00    	je     f010071c <cons_init+0xf5>
		addr_6845 = MONO_BASE;
f0100660:	c7 83 88 1f 00 00 b4 	movl   $0x3b4,0x1f88(%ebx)
f0100667:	03 00 00 
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f010066a:	c7 45 e4 00 00 0b f0 	movl   $0xf00b0000,-0x1c(%ebp)
	outb(addr_6845, 14);
f0100671:	8b bb 88 1f 00 00    	mov    0x1f88(%ebx),%edi
f0100677:	b8 0e 00 00 00       	mov    $0xe,%eax
f010067c:	89 fa                	mov    %edi,%edx
f010067e:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f010067f:	8d 4f 01             	lea    0x1(%edi),%ecx
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100682:	89 ca                	mov    %ecx,%edx
f0100684:	ec                   	in     (%dx),%al
f0100685:	0f b6 f0             	movzbl %al,%esi
f0100688:	c1 e6 08             	shl    $0x8,%esi
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010068b:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100690:	89 fa                	mov    %edi,%edx
f0100692:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100693:	89 ca                	mov    %ecx,%edx
f0100695:	ec                   	in     (%dx),%al
	crt_buf = (uint16_t*) cp;
f0100696:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100699:	89 bb 84 1f 00 00    	mov    %edi,0x1f84(%ebx)
	pos |= inb(addr_6845 + 1);
f010069f:	0f b6 c0             	movzbl %al,%eax
f01006a2:	09 c6                	or     %eax,%esi
	crt_pos = pos;
f01006a4:	66 89 b3 80 1f 00 00 	mov    %si,0x1f80(%ebx)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01006ab:	b9 00 00 00 00       	mov    $0x0,%ecx
f01006b0:	89 c8                	mov    %ecx,%eax
f01006b2:	ba fa 03 00 00       	mov    $0x3fa,%edx
f01006b7:	ee                   	out    %al,(%dx)
f01006b8:	bf fb 03 00 00       	mov    $0x3fb,%edi
f01006bd:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f01006c2:	89 fa                	mov    %edi,%edx
f01006c4:	ee                   	out    %al,(%dx)
f01006c5:	b8 0c 00 00 00       	mov    $0xc,%eax
f01006ca:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01006cf:	ee                   	out    %al,(%dx)
f01006d0:	be f9 03 00 00       	mov    $0x3f9,%esi
f01006d5:	89 c8                	mov    %ecx,%eax
f01006d7:	89 f2                	mov    %esi,%edx
f01006d9:	ee                   	out    %al,(%dx)
f01006da:	b8 03 00 00 00       	mov    $0x3,%eax
f01006df:	89 fa                	mov    %edi,%edx
f01006e1:	ee                   	out    %al,(%dx)
f01006e2:	ba fc 03 00 00       	mov    $0x3fc,%edx
f01006e7:	89 c8                	mov    %ecx,%eax
f01006e9:	ee                   	out    %al,(%dx)
f01006ea:	b8 01 00 00 00       	mov    $0x1,%eax
f01006ef:	89 f2                	mov    %esi,%edx
f01006f1:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006f2:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01006f7:	ec                   	in     (%dx),%al
f01006f8:	89 c1                	mov    %eax,%ecx
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f01006fa:	3c ff                	cmp    $0xff,%al
f01006fc:	0f 95 83 8c 1f 00 00 	setne  0x1f8c(%ebx)
f0100703:	ba fa 03 00 00       	mov    $0x3fa,%edx
f0100708:	ec                   	in     (%dx),%al
f0100709:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010070e:	ec                   	in     (%dx),%al
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f010070f:	80 f9 ff             	cmp    $0xff,%cl
f0100712:	74 25                	je     f0100739 <cons_init+0x112>
		cprintf("Serial port does not exist!\n");
}
f0100714:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100717:	5b                   	pop    %ebx
f0100718:	5e                   	pop    %esi
f0100719:	5f                   	pop    %edi
f010071a:	5d                   	pop    %ebp
f010071b:	c3                   	ret    
		*cp = was;
f010071c:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f0100723:	c7 83 88 1f 00 00 d4 	movl   $0x3d4,0x1f88(%ebx)
f010072a:	03 00 00 
	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f010072d:	c7 45 e4 00 80 0b f0 	movl   $0xf00b8000,-0x1c(%ebp)
f0100734:	e9 38 ff ff ff       	jmp    f0100671 <cons_init+0x4a>
		cprintf("Serial port does not exist!\n");
f0100739:	83 ec 0c             	sub    $0xc,%esp
f010073c:	8d 83 c8 fa fe ff    	lea    -0x10538(%ebx),%eax
f0100742:	50                   	push   %eax
f0100743:	e8 0f 05 00 00       	call   f0100c57 <cprintf>
f0100748:	83 c4 10             	add    $0x10,%esp
}
f010074b:	eb c7                	jmp    f0100714 <cons_init+0xed>

f010074d <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f010074d:	f3 0f 1e fb          	endbr32 
f0100751:	55                   	push   %ebp
f0100752:	89 e5                	mov    %esp,%ebp
f0100754:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f0100757:	8b 45 08             	mov    0x8(%ebp),%eax
f010075a:	e8 1f fc ff ff       	call   f010037e <cons_putc>
}
f010075f:	c9                   	leave  
f0100760:	c3                   	ret    

f0100761 <getchar>:

int
getchar(void)
{
f0100761:	f3 0f 1e fb          	endbr32 
f0100765:	55                   	push   %ebp
f0100766:	89 e5                	mov    %esp,%ebp
f0100768:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f010076b:	e8 5d fe ff ff       	call   f01005cd <cons_getc>
f0100770:	85 c0                	test   %eax,%eax
f0100772:	74 f7                	je     f010076b <getchar+0xa>
		/* do nothing */;
	return c;
}
f0100774:	c9                   	leave  
f0100775:	c3                   	ret    

f0100776 <iscons>:

int
iscons(int fdnum)
{
f0100776:	f3 0f 1e fb          	endbr32 
	// used by readline
	return 1;
}
f010077a:	b8 01 00 00 00       	mov    $0x1,%eax
f010077f:	c3                   	ret    

f0100780 <__x86.get_pc_thunk.ax>:
f0100780:	8b 04 24             	mov    (%esp),%eax
f0100783:	c3                   	ret    

f0100784 <__x86.get_pc_thunk.si>:
f0100784:	8b 34 24             	mov    (%esp),%esi
f0100787:	c3                   	ret    

f0100788 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100788:	f3 0f 1e fb          	endbr32 
f010078c:	55                   	push   %ebp
f010078d:	89 e5                	mov    %esp,%ebp
f010078f:	56                   	push   %esi
f0100790:	53                   	push   %ebx
f0100791:	e8 36 fa ff ff       	call   f01001cc <__x86.get_pc_thunk.bx>
f0100796:	81 c3 72 1b 01 00    	add    $0x11b72,%ebx
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f010079c:	83 ec 04             	sub    $0x4,%esp
f010079f:	8d 83 f8 fc fe ff    	lea    -0x10308(%ebx),%eax
f01007a5:	50                   	push   %eax
f01007a6:	8d 83 16 fd fe ff    	lea    -0x102ea(%ebx),%eax
f01007ac:	50                   	push   %eax
f01007ad:	8d b3 1b fd fe ff    	lea    -0x102e5(%ebx),%esi
f01007b3:	56                   	push   %esi
f01007b4:	e8 9e 04 00 00       	call   f0100c57 <cprintf>
f01007b9:	83 c4 0c             	add    $0xc,%esp
f01007bc:	8d 83 c8 fd fe ff    	lea    -0x10238(%ebx),%eax
f01007c2:	50                   	push   %eax
f01007c3:	8d 83 24 fd fe ff    	lea    -0x102dc(%ebx),%eax
f01007c9:	50                   	push   %eax
f01007ca:	56                   	push   %esi
f01007cb:	e8 87 04 00 00       	call   f0100c57 <cprintf>
	return 0;
}
f01007d0:	b8 00 00 00 00       	mov    $0x0,%eax
f01007d5:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01007d8:	5b                   	pop    %ebx
f01007d9:	5e                   	pop    %esi
f01007da:	5d                   	pop    %ebp
f01007db:	c3                   	ret    

f01007dc <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01007dc:	f3 0f 1e fb          	endbr32 
f01007e0:	55                   	push   %ebp
f01007e1:	89 e5                	mov    %esp,%ebp
f01007e3:	57                   	push   %edi
f01007e4:	56                   	push   %esi
f01007e5:	53                   	push   %ebx
f01007e6:	83 ec 18             	sub    $0x18,%esp
f01007e9:	e8 de f9 ff ff       	call   f01001cc <__x86.get_pc_thunk.bx>
f01007ee:	81 c3 1a 1b 01 00    	add    $0x11b1a,%ebx
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01007f4:	8d 83 2d fd fe ff    	lea    -0x102d3(%ebx),%eax
f01007fa:	50                   	push   %eax
f01007fb:	e8 57 04 00 00       	call   f0100c57 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100800:	83 c4 08             	add    $0x8,%esp
f0100803:	ff b3 f8 ff ff ff    	pushl  -0x8(%ebx)
f0100809:	8d 83 f0 fd fe ff    	lea    -0x10210(%ebx),%eax
f010080f:	50                   	push   %eax
f0100810:	e8 42 04 00 00       	call   f0100c57 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100815:	83 c4 0c             	add    $0xc,%esp
f0100818:	c7 c7 0c 00 10 f0    	mov    $0xf010000c,%edi
f010081e:	8d 87 00 00 00 10    	lea    0x10000000(%edi),%eax
f0100824:	50                   	push   %eax
f0100825:	57                   	push   %edi
f0100826:	8d 83 18 fe fe ff    	lea    -0x101e8(%ebx),%eax
f010082c:	50                   	push   %eax
f010082d:	e8 25 04 00 00       	call   f0100c57 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100832:	83 c4 0c             	add    $0xc,%esp
f0100835:	c7 c0 2d 1d 10 f0    	mov    $0xf0101d2d,%eax
f010083b:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0100841:	52                   	push   %edx
f0100842:	50                   	push   %eax
f0100843:	8d 83 3c fe fe ff    	lea    -0x101c4(%ebx),%eax
f0100849:	50                   	push   %eax
f010084a:	e8 08 04 00 00       	call   f0100c57 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f010084f:	83 c4 0c             	add    $0xc,%esp
f0100852:	c7 c0 60 40 11 f0    	mov    $0xf0114060,%eax
f0100858:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f010085e:	52                   	push   %edx
f010085f:	50                   	push   %eax
f0100860:	8d 83 60 fe fe ff    	lea    -0x101a0(%ebx),%eax
f0100866:	50                   	push   %eax
f0100867:	e8 eb 03 00 00       	call   f0100c57 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f010086c:	83 c4 0c             	add    $0xc,%esp
f010086f:	c7 c6 a0 46 11 f0    	mov    $0xf01146a0,%esi
f0100875:	8d 86 00 00 00 10    	lea    0x10000000(%esi),%eax
f010087b:	50                   	push   %eax
f010087c:	56                   	push   %esi
f010087d:	8d 83 84 fe fe ff    	lea    -0x1017c(%ebx),%eax
f0100883:	50                   	push   %eax
f0100884:	e8 ce 03 00 00       	call   f0100c57 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100889:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f010088c:	29 fe                	sub    %edi,%esi
f010088e:	81 c6 ff 03 00 00    	add    $0x3ff,%esi
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100894:	c1 fe 0a             	sar    $0xa,%esi
f0100897:	56                   	push   %esi
f0100898:	8d 83 a8 fe fe ff    	lea    -0x10158(%ebx),%eax
f010089e:	50                   	push   %eax
f010089f:	e8 b3 03 00 00       	call   f0100c57 <cprintf>
	return 0;
}
f01008a4:	b8 00 00 00 00       	mov    $0x0,%eax
f01008a9:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01008ac:	5b                   	pop    %ebx
f01008ad:	5e                   	pop    %esi
f01008ae:	5f                   	pop    %edi
f01008af:	5d                   	pop    %ebp
f01008b0:	c3                   	ret    

f01008b1 <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f01008b1:	f3 0f 1e fb          	endbr32 
f01008b5:	55                   	push   %ebp
f01008b6:	89 e5                	mov    %esp,%ebp
f01008b8:	57                   	push   %edi
f01008b9:	56                   	push   %esi
f01008ba:	53                   	push   %ebx
f01008bb:	83 ec 48             	sub    $0x48,%esp
f01008be:	e8 09 f9 ff ff       	call   f01001cc <__x86.get_pc_thunk.bx>
f01008c3:	81 c3 45 1a 01 00    	add    $0x11a45,%ebx

static inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f01008c9:	89 e8                	mov    %ebp,%eax
	// Your code here.	
    uint32_t *ebp;
    uint32_t eip;

    ebp = (uint32_t *) read_ebp();
f01008cb:	89 c6                	mov    %eax,%esi
    eip = *(ebp + 1);
f01008cd:	8b 40 04             	mov    0x4(%eax),%eax
f01008d0:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    cprintf("Stack backtrace:\n");
f01008d3:	8d 83 46 fd fe ff    	lea    -0x102ba(%ebx),%eax
f01008d9:	50                   	push   %eax
f01008da:	e8 78 03 00 00       	call   f0100c57 <cprintf>
f01008df:	83 c4 10             	add    $0x10,%esp
     * +----------------------+
     * |       %ebp.old       |  <- %ebp.new
     * +----------------------+
     */
    while (ebp) {
        cprintf("  ebp %08x  eip %08x  args", ebp, eip); 
f01008e2:	8d 83 58 fd fe ff    	lea    -0x102a8(%ebx),%eax
f01008e8:	89 45 c0             	mov    %eax,-0x40(%ebp)
        cprintf(" %08x", *(ebp + 2));
f01008eb:	8d bb 73 fd fe ff    	lea    -0x1028d(%ebx),%edi
        cprintf("  ebp %08x  eip %08x  args", ebp, eip); 
f01008f1:	83 ec 04             	sub    $0x4,%esp
f01008f4:	ff 75 c4             	pushl  -0x3c(%ebp)
f01008f7:	56                   	push   %esi
f01008f8:	ff 75 c0             	pushl  -0x40(%ebp)
f01008fb:	e8 57 03 00 00       	call   f0100c57 <cprintf>
        cprintf(" %08x", *(ebp + 2));
f0100900:	83 c4 08             	add    $0x8,%esp
f0100903:	ff 76 08             	pushl  0x8(%esi)
f0100906:	57                   	push   %edi
f0100907:	e8 4b 03 00 00       	call   f0100c57 <cprintf>
        cprintf(" %08x", *(ebp + 3));
f010090c:	83 c4 08             	add    $0x8,%esp
f010090f:	ff 76 0c             	pushl  0xc(%esi)
f0100912:	57                   	push   %edi
f0100913:	e8 3f 03 00 00       	call   f0100c57 <cprintf>
        cprintf(" %08x", *(ebp + 4));
f0100918:	83 c4 08             	add    $0x8,%esp
f010091b:	ff 76 10             	pushl  0x10(%esi)
f010091e:	57                   	push   %edi
f010091f:	e8 33 03 00 00       	call   f0100c57 <cprintf>
        cprintf(" %08x", *(ebp + 5));
f0100924:	83 c4 08             	add    $0x8,%esp
f0100927:	ff 76 14             	pushl  0x14(%esi)
f010092a:	57                   	push   %edi
f010092b:	e8 27 03 00 00       	call   f0100c57 <cprintf>
        cprintf(" %08x", *(ebp + 6));
f0100930:	83 c4 08             	add    $0x8,%esp
f0100933:	ff 76 18             	pushl  0x18(%esi)
f0100936:	57                   	push   %edi
f0100937:	e8 1b 03 00 00       	call   f0100c57 <cprintf>
        cprintf("\n");
f010093c:	8d 83 c6 fa fe ff    	lea    -0x1053a(%ebx),%eax
f0100942:	89 04 24             	mov    %eax,(%esp)
f0100945:	e8 0d 03 00 00       	call   f0100c57 <cprintf>

        struct Eipdebuginfo info;
        debuginfo_eip(eip, &info);
f010094a:	83 c4 08             	add    $0x8,%esp
f010094d:	8d 45 d0             	lea    -0x30(%ebp),%eax
f0100950:	50                   	push   %eax
f0100951:	ff 75 c4             	pushl  -0x3c(%ebp)
f0100954:	e8 0b 04 00 00       	call   f0100d64 <debuginfo_eip>
        cprintf("\t%s:%d:  %.*s+%d\n",
f0100959:	83 c4 08             	add    $0x8,%esp
f010095c:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f010095f:	2b 45 e0             	sub    -0x20(%ebp),%eax
f0100962:	50                   	push   %eax
f0100963:	ff 75 d8             	pushl  -0x28(%ebp)
f0100966:	ff 75 dc             	pushl  -0x24(%ebp)
f0100969:	ff 75 d4             	pushl  -0x2c(%ebp)
f010096c:	ff 75 d0             	pushl  -0x30(%ebp)
f010096f:	8d 83 79 fd fe ff    	lea    -0x10287(%ebx),%eax
f0100975:	50                   	push   %eax
f0100976:	e8 dc 02 00 00       	call   f0100c57 <cprintf>
                info.eip_file, info.eip_line,
                info.eip_fn_namelen, info.eip_fn_name,
                eip - info.eip_fn_addr);

        ebp = (uint32_t *) *ebp;
f010097b:	8b 36                	mov    (%esi),%esi
        eip = *(ebp + 1);
f010097d:	8b 46 04             	mov    0x4(%esi),%eax
f0100980:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    while (ebp) {
f0100983:	83 c4 20             	add    $0x20,%esp
f0100986:	85 f6                	test   %esi,%esi
f0100988:	0f 85 63 ff ff ff    	jne    f01008f1 <mon_backtrace+0x40>
    }

    return 0;
}
f010098e:	b8 00 00 00 00       	mov    $0x0,%eax
f0100993:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100996:	5b                   	pop    %ebx
f0100997:	5e                   	pop    %esi
f0100998:	5f                   	pop    %edi
f0100999:	5d                   	pop    %ebp
f010099a:	c3                   	ret    

f010099b <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f010099b:	f3 0f 1e fb          	endbr32 
f010099f:	55                   	push   %ebp
f01009a0:	89 e5                	mov    %esp,%ebp
f01009a2:	57                   	push   %edi
f01009a3:	56                   	push   %esi
f01009a4:	53                   	push   %ebx
f01009a5:	83 ec 68             	sub    $0x68,%esp
f01009a8:	e8 1f f8 ff ff       	call   f01001cc <__x86.get_pc_thunk.bx>
f01009ad:	81 c3 5b 19 01 00    	add    $0x1195b,%ebx
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f01009b3:	8d 83 d4 fe fe ff    	lea    -0x1012c(%ebx),%eax
f01009b9:	50                   	push   %eax
f01009ba:	e8 98 02 00 00       	call   f0100c57 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f01009bf:	8d 83 f8 fe fe ff    	lea    -0x10108(%ebx),%eax
f01009c5:	89 04 24             	mov    %eax,(%esp)
f01009c8:	e8 8a 02 00 00       	call   f0100c57 <cprintf>
f01009cd:	83 c4 10             	add    $0x10,%esp
		while (*buf && strchr(WHITESPACE, *buf))
f01009d0:	8d 83 8f fd fe ff    	lea    -0x10271(%ebx),%eax
f01009d6:	89 45 a0             	mov    %eax,-0x60(%ebp)
f01009d9:	e9 dc 00 00 00       	jmp    f0100aba <monitor+0x11f>
f01009de:	83 ec 08             	sub    $0x8,%esp
f01009e1:	0f be c0             	movsbl %al,%eax
f01009e4:	50                   	push   %eax
f01009e5:	ff 75 a0             	pushl  -0x60(%ebp)
f01009e8:	e8 87 0e 00 00       	call   f0101874 <strchr>
f01009ed:	83 c4 10             	add    $0x10,%esp
f01009f0:	85 c0                	test   %eax,%eax
f01009f2:	74 74                	je     f0100a68 <monitor+0xcd>
			*buf++ = 0;
f01009f4:	c6 06 00             	movb   $0x0,(%esi)
f01009f7:	89 7d a4             	mov    %edi,-0x5c(%ebp)
f01009fa:	8d 76 01             	lea    0x1(%esi),%esi
f01009fd:	8b 7d a4             	mov    -0x5c(%ebp),%edi
		while (*buf && strchr(WHITESPACE, *buf))
f0100a00:	0f b6 06             	movzbl (%esi),%eax
f0100a03:	84 c0                	test   %al,%al
f0100a05:	75 d7                	jne    f01009de <monitor+0x43>
	argv[argc] = 0;
f0100a07:	c7 44 bd a8 00 00 00 	movl   $0x0,-0x58(%ebp,%edi,4)
f0100a0e:	00 
	if (argc == 0)
f0100a0f:	85 ff                	test   %edi,%edi
f0100a11:	0f 84 a3 00 00 00    	je     f0100aba <monitor+0x11f>
		if (strcmp(argv[0], commands[i].name) == 0)
f0100a17:	83 ec 08             	sub    $0x8,%esp
f0100a1a:	8d 83 16 fd fe ff    	lea    -0x102ea(%ebx),%eax
f0100a20:	50                   	push   %eax
f0100a21:	ff 75 a8             	pushl  -0x58(%ebp)
f0100a24:	e8 e5 0d 00 00       	call   f010180e <strcmp>
f0100a29:	83 c4 10             	add    $0x10,%esp
f0100a2c:	85 c0                	test   %eax,%eax
f0100a2e:	0f 84 b4 00 00 00    	je     f0100ae8 <monitor+0x14d>
f0100a34:	83 ec 08             	sub    $0x8,%esp
f0100a37:	8d 83 24 fd fe ff    	lea    -0x102dc(%ebx),%eax
f0100a3d:	50                   	push   %eax
f0100a3e:	ff 75 a8             	pushl  -0x58(%ebp)
f0100a41:	e8 c8 0d 00 00       	call   f010180e <strcmp>
f0100a46:	83 c4 10             	add    $0x10,%esp
f0100a49:	85 c0                	test   %eax,%eax
f0100a4b:	0f 84 92 00 00 00    	je     f0100ae3 <monitor+0x148>
	cprintf("Unknown command '%s'\n", argv[0]);
f0100a51:	83 ec 08             	sub    $0x8,%esp
f0100a54:	ff 75 a8             	pushl  -0x58(%ebp)
f0100a57:	8d 83 b1 fd fe ff    	lea    -0x1024f(%ebx),%eax
f0100a5d:	50                   	push   %eax
f0100a5e:	e8 f4 01 00 00       	call   f0100c57 <cprintf>
	return 0;
f0100a63:	83 c4 10             	add    $0x10,%esp
f0100a66:	eb 52                	jmp    f0100aba <monitor+0x11f>
		if (*buf == 0)
f0100a68:	80 3e 00             	cmpb   $0x0,(%esi)
f0100a6b:	74 9a                	je     f0100a07 <monitor+0x6c>
		if (argc == MAXARGS-1) {
f0100a6d:	83 ff 0f             	cmp    $0xf,%edi
f0100a70:	74 34                	je     f0100aa6 <monitor+0x10b>
		argv[argc++] = buf;
f0100a72:	8d 47 01             	lea    0x1(%edi),%eax
f0100a75:	89 45 a4             	mov    %eax,-0x5c(%ebp)
f0100a78:	89 74 bd a8          	mov    %esi,-0x58(%ebp,%edi,4)
		while (*buf && !strchr(WHITESPACE, *buf))
f0100a7c:	0f b6 06             	movzbl (%esi),%eax
f0100a7f:	84 c0                	test   %al,%al
f0100a81:	0f 84 76 ff ff ff    	je     f01009fd <monitor+0x62>
f0100a87:	83 ec 08             	sub    $0x8,%esp
f0100a8a:	0f be c0             	movsbl %al,%eax
f0100a8d:	50                   	push   %eax
f0100a8e:	ff 75 a0             	pushl  -0x60(%ebp)
f0100a91:	e8 de 0d 00 00       	call   f0101874 <strchr>
f0100a96:	83 c4 10             	add    $0x10,%esp
f0100a99:	85 c0                	test   %eax,%eax
f0100a9b:	0f 85 5c ff ff ff    	jne    f01009fd <monitor+0x62>
			buf++;
f0100aa1:	83 c6 01             	add    $0x1,%esi
f0100aa4:	eb d6                	jmp    f0100a7c <monitor+0xe1>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100aa6:	83 ec 08             	sub    $0x8,%esp
f0100aa9:	6a 10                	push   $0x10
f0100aab:	8d 83 94 fd fe ff    	lea    -0x1026c(%ebx),%eax
f0100ab1:	50                   	push   %eax
f0100ab2:	e8 a0 01 00 00       	call   f0100c57 <cprintf>
			return 0;
f0100ab7:	83 c4 10             	add    $0x10,%esp
    // cprintf("H%x Wo%s", 57616, &i);
    
    // cprintf("x=%d y=%d", 3);

    while (1) {
		buf = readline("K> ");
f0100aba:	8d bb 8b fd fe ff    	lea    -0x10275(%ebx),%edi
f0100ac0:	83 ec 0c             	sub    $0xc,%esp
f0100ac3:	57                   	push   %edi
f0100ac4:	e8 3a 0b 00 00       	call   f0101603 <readline>
f0100ac9:	89 c6                	mov    %eax,%esi
		if (buf != NULL)
f0100acb:	83 c4 10             	add    $0x10,%esp
f0100ace:	85 c0                	test   %eax,%eax
f0100ad0:	74 ee                	je     f0100ac0 <monitor+0x125>
	argv[argc] = 0;
f0100ad2:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	argc = 0;
f0100ad9:	bf 00 00 00 00       	mov    $0x0,%edi
f0100ade:	e9 1d ff ff ff       	jmp    f0100a00 <monitor+0x65>
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100ae3:	b8 01 00 00 00       	mov    $0x1,%eax
			return commands[i].func(argc, argv, tf);
f0100ae8:	83 ec 04             	sub    $0x4,%esp
f0100aeb:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0100aee:	ff 75 08             	pushl  0x8(%ebp)
f0100af1:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100af4:	52                   	push   %edx
f0100af5:	57                   	push   %edi
f0100af6:	ff 94 83 10 1d 00 00 	call   *0x1d10(%ebx,%eax,4)
			if (runcmd(buf, tf) < 0)
f0100afd:	83 c4 10             	add    $0x10,%esp
f0100b00:	85 c0                	test   %eax,%eax
f0100b02:	79 b6                	jns    f0100aba <monitor+0x11f>
				break;
	}
}
f0100b04:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100b07:	5b                   	pop    %ebx
f0100b08:	5e                   	pop    %esi
f0100b09:	5f                   	pop    %edi
f0100b0a:	5d                   	pop    %ebp
f0100b0b:	c3                   	ret    

f0100b0c <backtrace>:

int
backtrace(int argc, char **argv, struct Trapframe *tf)
{
f0100b0c:	f3 0f 1e fb          	endbr32 
f0100b10:	55                   	push   %ebp
f0100b11:	89 e5                	mov    %esp,%ebp
f0100b13:	57                   	push   %edi
f0100b14:	56                   	push   %esi
f0100b15:	53                   	push   %ebx
f0100b16:	83 ec 48             	sub    $0x48,%esp
f0100b19:	e8 ae f6 ff ff       	call   f01001cc <__x86.get_pc_thunk.bx>
f0100b1e:	81 c3 ea 17 01 00    	add    $0x117ea,%ebx
f0100b24:	89 e8                	mov    %ebp,%eax
    uint32_t *ebp;
    uint32_t eip;

    ebp = (uint32_t *) read_ebp();
f0100b26:	89 c6                	mov    %eax,%esi
    eip = *(ebp + 1);
f0100b28:	8b 40 04             	mov    0x4(%eax),%eax
f0100b2b:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    cprintf("Stack backtrace:\n");
f0100b2e:	8d 83 46 fd fe ff    	lea    -0x102ba(%ebx),%eax
f0100b34:	50                   	push   %eax
f0100b35:	e8 1d 01 00 00       	call   f0100c57 <cprintf>
f0100b3a:	83 c4 10             	add    $0x10,%esp
    while (ebp) {
        cprintf("  ebp %08x  eip %08x  args", ebp, eip); 
f0100b3d:	8d 83 58 fd fe ff    	lea    -0x102a8(%ebx),%eax
f0100b43:	89 45 c0             	mov    %eax,-0x40(%ebp)
        cprintf(" %08x", *(ebp + 2));
f0100b46:	8d bb 73 fd fe ff    	lea    -0x1028d(%ebx),%edi
        cprintf("  ebp %08x  eip %08x  args", ebp, eip); 
f0100b4c:	83 ec 04             	sub    $0x4,%esp
f0100b4f:	ff 75 c4             	pushl  -0x3c(%ebp)
f0100b52:	56                   	push   %esi
f0100b53:	ff 75 c0             	pushl  -0x40(%ebp)
f0100b56:	e8 fc 00 00 00       	call   f0100c57 <cprintf>
        cprintf(" %08x", *(ebp + 2));
f0100b5b:	83 c4 08             	add    $0x8,%esp
f0100b5e:	ff 76 08             	pushl  0x8(%esi)
f0100b61:	57                   	push   %edi
f0100b62:	e8 f0 00 00 00       	call   f0100c57 <cprintf>
        cprintf(" %08x", *(ebp + 3));
f0100b67:	83 c4 08             	add    $0x8,%esp
f0100b6a:	ff 76 0c             	pushl  0xc(%esi)
f0100b6d:	57                   	push   %edi
f0100b6e:	e8 e4 00 00 00       	call   f0100c57 <cprintf>
        cprintf(" %08x", *(ebp + 4));
f0100b73:	83 c4 08             	add    $0x8,%esp
f0100b76:	ff 76 10             	pushl  0x10(%esi)
f0100b79:	57                   	push   %edi
f0100b7a:	e8 d8 00 00 00       	call   f0100c57 <cprintf>
        cprintf(" %08x", *(ebp + 5));
f0100b7f:	83 c4 08             	add    $0x8,%esp
f0100b82:	ff 76 14             	pushl  0x14(%esi)
f0100b85:	57                   	push   %edi
f0100b86:	e8 cc 00 00 00       	call   f0100c57 <cprintf>
        cprintf(" %08x", *(ebp + 6));
f0100b8b:	83 c4 08             	add    $0x8,%esp
f0100b8e:	ff 76 18             	pushl  0x18(%esi)
f0100b91:	57                   	push   %edi
f0100b92:	e8 c0 00 00 00       	call   f0100c57 <cprintf>
        cprintf("\n");
f0100b97:	8d 83 c6 fa fe ff    	lea    -0x1053a(%ebx),%eax
f0100b9d:	89 04 24             	mov    %eax,(%esp)
f0100ba0:	e8 b2 00 00 00       	call   f0100c57 <cprintf>

        struct Eipdebuginfo info;
        debuginfo_eip(eip, &info);
f0100ba5:	83 c4 08             	add    $0x8,%esp
f0100ba8:	8d 45 d0             	lea    -0x30(%ebp),%eax
f0100bab:	50                   	push   %eax
f0100bac:	ff 75 c4             	pushl  -0x3c(%ebp)
f0100baf:	e8 b0 01 00 00       	call   f0100d64 <debuginfo_eip>
        cprintf("\t%s:%d:  %.*s+%d\n",
f0100bb4:	83 c4 08             	add    $0x8,%esp
f0100bb7:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0100bba:	2b 45 e0             	sub    -0x20(%ebp),%eax
f0100bbd:	50                   	push   %eax
f0100bbe:	ff 75 d8             	pushl  -0x28(%ebp)
f0100bc1:	ff 75 dc             	pushl  -0x24(%ebp)
f0100bc4:	ff 75 d4             	pushl  -0x2c(%ebp)
f0100bc7:	ff 75 d0             	pushl  -0x30(%ebp)
f0100bca:	8d 83 79 fd fe ff    	lea    -0x10287(%ebx),%eax
f0100bd0:	50                   	push   %eax
f0100bd1:	e8 81 00 00 00       	call   f0100c57 <cprintf>
                info.eip_file, info.eip_line,
                info.eip_fn_namelen, info.eip_fn_name,
                eip - info.eip_fn_addr);

        ebp = (uint32_t *) *ebp;
f0100bd6:	8b 36                	mov    (%esi),%esi
        eip = *(ebp + 1);
f0100bd8:	8b 46 04             	mov    0x4(%esi),%eax
f0100bdb:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    while (ebp) {
f0100bde:	83 c4 20             	add    $0x20,%esp
f0100be1:	85 f6                	test   %esi,%esi
f0100be3:	0f 85 63 ff ff ff    	jne    f0100b4c <backtrace+0x40>
    }

    return 0;
}
f0100be9:	b8 00 00 00 00       	mov    $0x0,%eax
f0100bee:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100bf1:	5b                   	pop    %ebx
f0100bf2:	5e                   	pop    %esi
f0100bf3:	5f                   	pop    %edi
f0100bf4:	5d                   	pop    %ebp
f0100bf5:	c3                   	ret    

f0100bf6 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0100bf6:	f3 0f 1e fb          	endbr32 
f0100bfa:	55                   	push   %ebp
f0100bfb:	89 e5                	mov    %esp,%ebp
f0100bfd:	53                   	push   %ebx
f0100bfe:	83 ec 10             	sub    $0x10,%esp
f0100c01:	e8 c6 f5 ff ff       	call   f01001cc <__x86.get_pc_thunk.bx>
f0100c06:	81 c3 02 17 01 00    	add    $0x11702,%ebx
	cputchar(ch);
f0100c0c:	ff 75 08             	pushl  0x8(%ebp)
f0100c0f:	e8 39 fb ff ff       	call   f010074d <cputchar>
	*cnt++;
}
f0100c14:	83 c4 10             	add    $0x10,%esp
f0100c17:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100c1a:	c9                   	leave  
f0100c1b:	c3                   	ret    

f0100c1c <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0100c1c:	f3 0f 1e fb          	endbr32 
f0100c20:	55                   	push   %ebp
f0100c21:	89 e5                	mov    %esp,%ebp
f0100c23:	53                   	push   %ebx
f0100c24:	83 ec 14             	sub    $0x14,%esp
f0100c27:	e8 a0 f5 ff ff       	call   f01001cc <__x86.get_pc_thunk.bx>
f0100c2c:	81 c3 dc 16 01 00    	add    $0x116dc,%ebx
	int cnt = 0;
f0100c32:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0100c39:	ff 75 0c             	pushl  0xc(%ebp)
f0100c3c:	ff 75 08             	pushl  0x8(%ebp)
f0100c3f:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0100c42:	50                   	push   %eax
f0100c43:	8d 83 ee e8 fe ff    	lea    -0x11712(%ebx),%eax
f0100c49:	50                   	push   %eax
f0100c4a:	e8 7a 04 00 00       	call   f01010c9 <vprintfmt>
	return cnt;
}
f0100c4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100c52:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100c55:	c9                   	leave  
f0100c56:	c3                   	ret    

f0100c57 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0100c57:	f3 0f 1e fb          	endbr32 
f0100c5b:	55                   	push   %ebp
f0100c5c:	89 e5                	mov    %esp,%ebp
f0100c5e:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0100c61:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0100c64:	50                   	push   %eax
f0100c65:	ff 75 08             	pushl  0x8(%ebp)
f0100c68:	e8 af ff ff ff       	call   f0100c1c <vcprintf>
	va_end(ap);

	return cnt;
}
f0100c6d:	c9                   	leave  
f0100c6e:	c3                   	ret    

f0100c6f <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0100c6f:	55                   	push   %ebp
f0100c70:	89 e5                	mov    %esp,%ebp
f0100c72:	57                   	push   %edi
f0100c73:	56                   	push   %esi
f0100c74:	53                   	push   %ebx
f0100c75:	83 ec 14             	sub    $0x14,%esp
f0100c78:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0100c7b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0100c7e:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0100c81:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0100c84:	8b 1a                	mov    (%edx),%ebx
f0100c86:	8b 01                	mov    (%ecx),%eax
f0100c88:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100c8b:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0100c92:	eb 23                	jmp    f0100cb7 <stab_binsearch+0x48>

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0100c94:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f0100c97:	eb 1e                	jmp    f0100cb7 <stab_binsearch+0x48>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0100c99:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100c9c:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0100c9f:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0100ca3:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0100ca6:	73 46                	jae    f0100cee <stab_binsearch+0x7f>
			*region_left = m;
f0100ca8:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0100cab:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f0100cad:	8d 5f 01             	lea    0x1(%edi),%ebx
		any_matches = 1;
f0100cb0:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
	while (l <= r) {
f0100cb7:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0100cba:	7f 5f                	jg     f0100d1b <stab_binsearch+0xac>
		int true_m = (l + r) / 2, m = true_m;
f0100cbc:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0100cbf:	8d 14 03             	lea    (%ebx,%eax,1),%edx
f0100cc2:	89 d0                	mov    %edx,%eax
f0100cc4:	c1 e8 1f             	shr    $0x1f,%eax
f0100cc7:	01 d0                	add    %edx,%eax
f0100cc9:	89 c7                	mov    %eax,%edi
f0100ccb:	d1 ff                	sar    %edi
f0100ccd:	83 e0 fe             	and    $0xfffffffe,%eax
f0100cd0:	01 f8                	add    %edi,%eax
f0100cd2:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0100cd5:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
f0100cd9:	89 f8                	mov    %edi,%eax
		while (m >= l && stabs[m].n_type != type)
f0100cdb:	39 c3                	cmp    %eax,%ebx
f0100cdd:	7f b5                	jg     f0100c94 <stab_binsearch+0x25>
f0100cdf:	0f b6 0a             	movzbl (%edx),%ecx
f0100ce2:	83 ea 0c             	sub    $0xc,%edx
f0100ce5:	39 f1                	cmp    %esi,%ecx
f0100ce7:	74 b0                	je     f0100c99 <stab_binsearch+0x2a>
			m--;
f0100ce9:	83 e8 01             	sub    $0x1,%eax
f0100cec:	eb ed                	jmp    f0100cdb <stab_binsearch+0x6c>
		} else if (stabs[m].n_value > addr) {
f0100cee:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0100cf1:	76 14                	jbe    f0100d07 <stab_binsearch+0x98>
			*region_right = m - 1;
f0100cf3:	83 e8 01             	sub    $0x1,%eax
f0100cf6:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100cf9:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0100cfc:	89 07                	mov    %eax,(%edi)
		any_matches = 1;
f0100cfe:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0100d05:	eb b0                	jmp    f0100cb7 <stab_binsearch+0x48>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0100d07:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100d0a:	89 07                	mov    %eax,(%edi)
			l = m;
			addr++;
f0100d0c:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0100d10:	89 c3                	mov    %eax,%ebx
		any_matches = 1;
f0100d12:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0100d19:	eb 9c                	jmp    f0100cb7 <stab_binsearch+0x48>
		}
	}

	if (!any_matches)
f0100d1b:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0100d1f:	75 15                	jne    f0100d36 <stab_binsearch+0xc7>
		*region_right = *region_left - 1;
f0100d21:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100d24:	8b 00                	mov    (%eax),%eax
f0100d26:	83 e8 01             	sub    $0x1,%eax
f0100d29:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0100d2c:	89 07                	mov    %eax,(%edi)
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f0100d2e:	83 c4 14             	add    $0x14,%esp
f0100d31:	5b                   	pop    %ebx
f0100d32:	5e                   	pop    %esi
f0100d33:	5f                   	pop    %edi
f0100d34:	5d                   	pop    %ebp
f0100d35:	c3                   	ret    
		for (l = *region_right;
f0100d36:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100d39:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0100d3b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100d3e:	8b 0f                	mov    (%edi),%ecx
f0100d40:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100d43:	8b 7d ec             	mov    -0x14(%ebp),%edi
f0100d46:	8d 54 97 04          	lea    0x4(%edi,%edx,4),%edx
		for (l = *region_right;
f0100d4a:	eb 03                	jmp    f0100d4f <stab_binsearch+0xe0>
		     l--)
f0100d4c:	83 e8 01             	sub    $0x1,%eax
		for (l = *region_right;
f0100d4f:	39 c1                	cmp    %eax,%ecx
f0100d51:	7d 0a                	jge    f0100d5d <stab_binsearch+0xee>
		     l > *region_left && stabs[l].n_type != type;
f0100d53:	0f b6 1a             	movzbl (%edx),%ebx
f0100d56:	83 ea 0c             	sub    $0xc,%edx
f0100d59:	39 f3                	cmp    %esi,%ebx
f0100d5b:	75 ef                	jne    f0100d4c <stab_binsearch+0xdd>
		*region_left = l;
f0100d5d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100d60:	89 07                	mov    %eax,(%edi)
}
f0100d62:	eb ca                	jmp    f0100d2e <stab_binsearch+0xbf>

f0100d64 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0100d64:	f3 0f 1e fb          	endbr32 
f0100d68:	55                   	push   %ebp
f0100d69:	89 e5                	mov    %esp,%ebp
f0100d6b:	57                   	push   %edi
f0100d6c:	56                   	push   %esi
f0100d6d:	53                   	push   %ebx
f0100d6e:	83 ec 3c             	sub    $0x3c,%esp
f0100d71:	e8 56 f4 ff ff       	call   f01001cc <__x86.get_pc_thunk.bx>
f0100d76:	81 c3 92 15 01 00    	add    $0x11592,%ebx
f0100d7c:	89 5d c4             	mov    %ebx,-0x3c(%ebp)
f0100d7f:	8b 7d 08             	mov    0x8(%ebp),%edi
f0100d82:	8b 75 0c             	mov    0xc(%ebp),%esi
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0100d85:	8d 83 1d ff fe ff    	lea    -0x100e3(%ebx),%eax
f0100d8b:	89 06                	mov    %eax,(%esi)
	info->eip_line = 0;
f0100d8d:	c7 46 04 00 00 00 00 	movl   $0x0,0x4(%esi)
	info->eip_fn_name = "<unknown>";
f0100d94:	89 46 08             	mov    %eax,0x8(%esi)
	info->eip_fn_namelen = 9;
f0100d97:	c7 46 0c 09 00 00 00 	movl   $0x9,0xc(%esi)
	info->eip_fn_addr = addr;
f0100d9e:	89 7e 10             	mov    %edi,0x10(%esi)
	info->eip_fn_narg = 0;
f0100da1:	c7 46 14 00 00 00 00 	movl   $0x0,0x14(%esi)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0100da8:	81 ff ff ff 7f ef    	cmp    $0xef7fffff,%edi
f0100dae:	0f 86 38 01 00 00    	jbe    f0100eec <debuginfo_eip+0x188>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100db4:	c7 c0 61 6a 10 f0    	mov    $0xf0106a61,%eax
f0100dba:	39 83 fc ff ff ff    	cmp    %eax,-0x4(%ebx)
f0100dc0:	0f 86 da 01 00 00    	jbe    f0100fa0 <debuginfo_eip+0x23c>
f0100dc6:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100dc9:	c7 c0 32 84 10 f0    	mov    $0xf0108432,%eax
f0100dcf:	80 78 ff 00          	cmpb   $0x0,-0x1(%eax)
f0100dd3:	0f 85 ce 01 00 00    	jne    f0100fa7 <debuginfo_eip+0x243>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0100dd9:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0100de0:	c7 c0 40 24 10 f0    	mov    $0xf0102440,%eax
f0100de6:	c7 c2 60 6a 10 f0    	mov    $0xf0106a60,%edx
f0100dec:	29 c2                	sub    %eax,%edx
f0100dee:	c1 fa 02             	sar    $0x2,%edx
f0100df1:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f0100df7:	83 ea 01             	sub    $0x1,%edx
f0100dfa:	89 55 e0             	mov    %edx,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0100dfd:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0100e00:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0100e03:	83 ec 08             	sub    $0x8,%esp
f0100e06:	57                   	push   %edi
f0100e07:	6a 64                	push   $0x64
f0100e09:	e8 61 fe ff ff       	call   f0100c6f <stab_binsearch>
	if (lfile == 0)
f0100e0e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100e11:	83 c4 10             	add    $0x10,%esp
f0100e14:	85 c0                	test   %eax,%eax
f0100e16:	0f 84 92 01 00 00    	je     f0100fae <debuginfo_eip+0x24a>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0100e1c:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0100e1f:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100e22:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0100e25:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0100e28:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100e2b:	83 ec 08             	sub    $0x8,%esp
f0100e2e:	57                   	push   %edi
f0100e2f:	6a 24                	push   $0x24
f0100e31:	c7 c0 40 24 10 f0    	mov    $0xf0102440,%eax
f0100e37:	e8 33 fe ff ff       	call   f0100c6f <stab_binsearch>

	if (lfun <= rfun) {
f0100e3c:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100e3f:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f0100e42:	89 4d c0             	mov    %ecx,-0x40(%ebp)
f0100e45:	83 c4 10             	add    $0x10,%esp
f0100e48:	39 c8                	cmp    %ecx,%eax
f0100e4a:	0f 8f b7 00 00 00    	jg     f0100f07 <debuginfo_eip+0x1a3>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0100e50:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100e53:	c7 c1 40 24 10 f0    	mov    $0xf0102440,%ecx
f0100e59:	8d 0c 91             	lea    (%ecx,%edx,4),%ecx
f0100e5c:	8b 11                	mov    (%ecx),%edx
f0100e5e:	89 55 bc             	mov    %edx,-0x44(%ebp)
f0100e61:	c7 c2 32 84 10 f0    	mov    $0xf0108432,%edx
f0100e67:	89 5d c4             	mov    %ebx,-0x3c(%ebp)
f0100e6a:	81 ea 61 6a 10 f0    	sub    $0xf0106a61,%edx
f0100e70:	8b 5d bc             	mov    -0x44(%ebp),%ebx
f0100e73:	39 d3                	cmp    %edx,%ebx
f0100e75:	73 0c                	jae    f0100e83 <debuginfo_eip+0x11f>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0100e77:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f0100e7a:	81 c3 61 6a 10 f0    	add    $0xf0106a61,%ebx
f0100e80:	89 5e 08             	mov    %ebx,0x8(%esi)
		info->eip_fn_addr = stabs[lfun].n_value;
f0100e83:	8b 51 08             	mov    0x8(%ecx),%edx
f0100e86:	89 56 10             	mov    %edx,0x10(%esi)
		addr -= info->eip_fn_addr;
f0100e89:	29 d7                	sub    %edx,%edi
		// Search within the function definition for the line number.
		lline = lfun;
f0100e8b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0100e8e:	8b 45 c0             	mov    -0x40(%ebp),%eax
f0100e91:	89 45 d0             	mov    %eax,-0x30(%ebp)
		info->eip_fn_addr = addr;
		lline = lfile;
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0100e94:	83 ec 08             	sub    $0x8,%esp
f0100e97:	6a 3a                	push   $0x3a
f0100e99:	ff 76 08             	pushl  0x8(%esi)
f0100e9c:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100e9f:	e8 f5 09 00 00       	call   f0101899 <strfind>
f0100ea4:	2b 46 08             	sub    0x8(%esi),%eax
f0100ea7:	89 46 0c             	mov    %eax,0xc(%esi)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0100eaa:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0100ead:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0100eb0:	83 c4 08             	add    $0x8,%esp
f0100eb3:	57                   	push   %edi
f0100eb4:	6a 44                	push   $0x44
f0100eb6:	c7 c0 40 24 10 f0    	mov    $0xf0102440,%eax
f0100ebc:	e8 ae fd ff ff       	call   f0100c6f <stab_binsearch>
    if (lline <= rline) {
f0100ec1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100ec4:	83 c4 10             	add    $0x10,%esp
f0100ec7:	3b 45 d0             	cmp    -0x30(%ebp),%eax
f0100eca:	0f 8f e5 00 00 00    	jg     f0100fb5 <debuginfo_eip+0x251>
	    info->eip_line = stabs[lline].n_desc;
f0100ed0:	89 c2                	mov    %eax,%edx
f0100ed2:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f0100ed5:	c7 c0 40 24 10 f0    	mov    $0xf0102440,%eax
f0100edb:	0f b7 5c 88 06       	movzwl 0x6(%eax,%ecx,4),%ebx
f0100ee0:	89 5e 04             	mov    %ebx,0x4(%esi)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0100ee3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100ee6:	8d 44 88 04          	lea    0x4(%eax,%ecx,4),%eax
f0100eea:	eb 35                	jmp    f0100f21 <debuginfo_eip+0x1bd>
  	        panic("User address");
f0100eec:	83 ec 04             	sub    $0x4,%esp
f0100eef:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100ef2:	8d 83 27 ff fe ff    	lea    -0x100d9(%ebx),%eax
f0100ef8:	50                   	push   %eax
f0100ef9:	6a 7f                	push   $0x7f
f0100efb:	8d 83 34 ff fe ff    	lea    -0x100cc(%ebx),%eax
f0100f01:	50                   	push   %eax
f0100f02:	e8 07 f2 ff ff       	call   f010010e <_panic>
		info->eip_fn_addr = addr;
f0100f07:	89 7e 10             	mov    %edi,0x10(%esi)
		lline = lfile;
f0100f0a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100f0d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0100f10:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100f13:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0100f16:	e9 79 ff ff ff       	jmp    f0100e94 <debuginfo_eip+0x130>
f0100f1b:	83 ea 01             	sub    $0x1,%edx
f0100f1e:	83 e8 0c             	sub    $0xc,%eax
	while (lline >= lfile
f0100f21:	39 d7                	cmp    %edx,%edi
f0100f23:	7f 3a                	jg     f0100f5f <debuginfo_eip+0x1fb>
	       && stabs[lline].n_type != N_SOL
f0100f25:	0f b6 08             	movzbl (%eax),%ecx
f0100f28:	80 f9 84             	cmp    $0x84,%cl
f0100f2b:	74 0b                	je     f0100f38 <debuginfo_eip+0x1d4>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0100f2d:	80 f9 64             	cmp    $0x64,%cl
f0100f30:	75 e9                	jne    f0100f1b <debuginfo_eip+0x1b7>
f0100f32:	83 78 04 00          	cmpl   $0x0,0x4(%eax)
f0100f36:	74 e3                	je     f0100f1b <debuginfo_eip+0x1b7>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0100f38:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0100f3b:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0100f3e:	c7 c0 40 24 10 f0    	mov    $0xf0102440,%eax
f0100f44:	8b 14 90             	mov    (%eax,%edx,4),%edx
f0100f47:	c7 c0 32 84 10 f0    	mov    $0xf0108432,%eax
f0100f4d:	81 e8 61 6a 10 f0    	sub    $0xf0106a61,%eax
f0100f53:	39 c2                	cmp    %eax,%edx
f0100f55:	73 08                	jae    f0100f5f <debuginfo_eip+0x1fb>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0100f57:	81 c2 61 6a 10 f0    	add    $0xf0106a61,%edx
f0100f5d:	89 16                	mov    %edx,(%esi)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0100f5f:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100f62:	8b 5d d8             	mov    -0x28(%ebp),%ebx
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100f65:	b8 00 00 00 00       	mov    $0x0,%eax
	if (lfun < rfun)
f0100f6a:	39 da                	cmp    %ebx,%edx
f0100f6c:	7d 53                	jge    f0100fc1 <debuginfo_eip+0x25d>
		for (lline = lfun + 1;
f0100f6e:	8d 42 01             	lea    0x1(%edx),%eax
f0100f71:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f0100f74:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0100f77:	c7 c2 40 24 10 f0    	mov    $0xf0102440,%edx
f0100f7d:	8d 54 8a 04          	lea    0x4(%edx,%ecx,4),%edx
f0100f81:	eb 04                	jmp    f0100f87 <debuginfo_eip+0x223>
			info->eip_fn_narg++;
f0100f83:	83 46 14 01          	addl   $0x1,0x14(%esi)
		for (lline = lfun + 1;
f0100f87:	39 c3                	cmp    %eax,%ebx
f0100f89:	7e 31                	jle    f0100fbc <debuginfo_eip+0x258>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0100f8b:	0f b6 0a             	movzbl (%edx),%ecx
f0100f8e:	83 c0 01             	add    $0x1,%eax
f0100f91:	83 c2 0c             	add    $0xc,%edx
f0100f94:	80 f9 a0             	cmp    $0xa0,%cl
f0100f97:	74 ea                	je     f0100f83 <debuginfo_eip+0x21f>
	return 0;
f0100f99:	b8 00 00 00 00       	mov    $0x0,%eax
f0100f9e:	eb 21                	jmp    f0100fc1 <debuginfo_eip+0x25d>
		return -1;
f0100fa0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100fa5:	eb 1a                	jmp    f0100fc1 <debuginfo_eip+0x25d>
f0100fa7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100fac:	eb 13                	jmp    f0100fc1 <debuginfo_eip+0x25d>
		return -1;
f0100fae:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100fb3:	eb 0c                	jmp    f0100fc1 <debuginfo_eip+0x25d>
        return -1;
f0100fb5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100fba:	eb 05                	jmp    f0100fc1 <debuginfo_eip+0x25d>
	return 0;
f0100fbc:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100fc1:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100fc4:	5b                   	pop    %ebx
f0100fc5:	5e                   	pop    %esi
f0100fc6:	5f                   	pop    %edi
f0100fc7:	5d                   	pop    %ebp
f0100fc8:	c3                   	ret    

f0100fc9 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0100fc9:	55                   	push   %ebp
f0100fca:	89 e5                	mov    %esp,%ebp
f0100fcc:	57                   	push   %edi
f0100fcd:	56                   	push   %esi
f0100fce:	53                   	push   %ebx
f0100fcf:	83 ec 2c             	sub    $0x2c,%esp
f0100fd2:	e8 28 06 00 00       	call   f01015ff <__x86.get_pc_thunk.cx>
f0100fd7:	81 c1 31 13 01 00    	add    $0x11331,%ecx
f0100fdd:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0100fe0:	89 c7                	mov    %eax,%edi
f0100fe2:	89 d6                	mov    %edx,%esi
f0100fe4:	8b 45 08             	mov    0x8(%ebp),%eax
f0100fe7:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100fea:	89 d1                	mov    %edx,%ecx
f0100fec:	89 c2                	mov    %eax,%edx
f0100fee:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0100ff1:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f0100ff4:	8b 45 10             	mov    0x10(%ebp),%eax
f0100ff7:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0100ffa:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100ffd:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f0101004:	39 c2                	cmp    %eax,%edx
f0101006:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
f0101009:	72 41                	jb     f010104c <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f010100b:	83 ec 0c             	sub    $0xc,%esp
f010100e:	ff 75 18             	pushl  0x18(%ebp)
f0101011:	83 eb 01             	sub    $0x1,%ebx
f0101014:	53                   	push   %ebx
f0101015:	50                   	push   %eax
f0101016:	83 ec 08             	sub    $0x8,%esp
f0101019:	ff 75 e4             	pushl  -0x1c(%ebp)
f010101c:	ff 75 e0             	pushl  -0x20(%ebp)
f010101f:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101022:	ff 75 d0             	pushl  -0x30(%ebp)
f0101025:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0101028:	e8 a3 0a 00 00       	call   f0101ad0 <__udivdi3>
f010102d:	83 c4 18             	add    $0x18,%esp
f0101030:	52                   	push   %edx
f0101031:	50                   	push   %eax
f0101032:	89 f2                	mov    %esi,%edx
f0101034:	89 f8                	mov    %edi,%eax
f0101036:	e8 8e ff ff ff       	call   f0100fc9 <printnum>
f010103b:	83 c4 20             	add    $0x20,%esp
f010103e:	eb 13                	jmp    f0101053 <printnum+0x8a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0101040:	83 ec 08             	sub    $0x8,%esp
f0101043:	56                   	push   %esi
f0101044:	ff 75 18             	pushl  0x18(%ebp)
f0101047:	ff d7                	call   *%edi
f0101049:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
f010104c:	83 eb 01             	sub    $0x1,%ebx
f010104f:	85 db                	test   %ebx,%ebx
f0101051:	7f ed                	jg     f0101040 <printnum+0x77>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0101053:	83 ec 08             	sub    $0x8,%esp
f0101056:	56                   	push   %esi
f0101057:	83 ec 04             	sub    $0x4,%esp
f010105a:	ff 75 e4             	pushl  -0x1c(%ebp)
f010105d:	ff 75 e0             	pushl  -0x20(%ebp)
f0101060:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101063:	ff 75 d0             	pushl  -0x30(%ebp)
f0101066:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0101069:	e8 72 0b 00 00       	call   f0101be0 <__umoddi3>
f010106e:	83 c4 14             	add    $0x14,%esp
f0101071:	0f be 84 03 42 ff fe 	movsbl -0x100be(%ebx,%eax,1),%eax
f0101078:	ff 
f0101079:	50                   	push   %eax
f010107a:	ff d7                	call   *%edi
}
f010107c:	83 c4 10             	add    $0x10,%esp
f010107f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101082:	5b                   	pop    %ebx
f0101083:	5e                   	pop    %esi
f0101084:	5f                   	pop    %edi
f0101085:	5d                   	pop    %ebp
f0101086:	c3                   	ret    

f0101087 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0101087:	f3 0f 1e fb          	endbr32 
f010108b:	55                   	push   %ebp
f010108c:	89 e5                	mov    %esp,%ebp
f010108e:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0101091:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0101095:	8b 10                	mov    (%eax),%edx
f0101097:	3b 50 04             	cmp    0x4(%eax),%edx
f010109a:	73 0a                	jae    f01010a6 <sprintputch+0x1f>
		*b->buf++ = ch;
f010109c:	8d 4a 01             	lea    0x1(%edx),%ecx
f010109f:	89 08                	mov    %ecx,(%eax)
f01010a1:	8b 45 08             	mov    0x8(%ebp),%eax
f01010a4:	88 02                	mov    %al,(%edx)
}
f01010a6:	5d                   	pop    %ebp
f01010a7:	c3                   	ret    

f01010a8 <printfmt>:
{
f01010a8:	f3 0f 1e fb          	endbr32 
f01010ac:	55                   	push   %ebp
f01010ad:	89 e5                	mov    %esp,%ebp
f01010af:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
f01010b2:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f01010b5:	50                   	push   %eax
f01010b6:	ff 75 10             	pushl  0x10(%ebp)
f01010b9:	ff 75 0c             	pushl  0xc(%ebp)
f01010bc:	ff 75 08             	pushl  0x8(%ebp)
f01010bf:	e8 05 00 00 00       	call   f01010c9 <vprintfmt>
}
f01010c4:	83 c4 10             	add    $0x10,%esp
f01010c7:	c9                   	leave  
f01010c8:	c3                   	ret    

f01010c9 <vprintfmt>:
{
f01010c9:	f3 0f 1e fb          	endbr32 
f01010cd:	55                   	push   %ebp
f01010ce:	89 e5                	mov    %esp,%ebp
f01010d0:	57                   	push   %edi
f01010d1:	56                   	push   %esi
f01010d2:	53                   	push   %ebx
f01010d3:	83 ec 3c             	sub    $0x3c,%esp
f01010d6:	e8 a5 f6 ff ff       	call   f0100780 <__x86.get_pc_thunk.ax>
f01010db:	05 2d 12 01 00       	add    $0x1122d,%eax
f01010e0:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01010e3:	8b 75 08             	mov    0x8(%ebp),%esi
f01010e6:	8b 7d 0c             	mov    0xc(%ebp),%edi
f01010e9:	8b 5d 10             	mov    0x10(%ebp),%ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f01010ec:	8d 80 20 1d 00 00    	lea    0x1d20(%eax),%eax
f01010f2:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f01010f5:	e9 cd 03 00 00       	jmp    f01014c7 <.L25+0x48>
		padc = ' ';
f01010fa:	c6 45 cf 20          	movb   $0x20,-0x31(%ebp)
		altflag = 0;
f01010fe:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
		precision = -1;
f0101105:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
f010110c:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		lflag = 0;
f0101113:	b9 00 00 00 00       	mov    $0x0,%ecx
f0101118:	89 4d c8             	mov    %ecx,-0x38(%ebp)
f010111b:	89 75 08             	mov    %esi,0x8(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f010111e:	8d 43 01             	lea    0x1(%ebx),%eax
f0101121:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0101124:	0f b6 13             	movzbl (%ebx),%edx
f0101127:	8d 42 dd             	lea    -0x23(%edx),%eax
f010112a:	3c 55                	cmp    $0x55,%al
f010112c:	0f 87 21 04 00 00    	ja     f0101553 <.L20>
f0101132:	0f b6 c0             	movzbl %al,%eax
f0101135:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0101138:	89 ce                	mov    %ecx,%esi
f010113a:	03 b4 81 d0 ff fe ff 	add    -0x10030(%ecx,%eax,4),%esi
f0101141:	3e ff e6             	notrack jmp *%esi

f0101144 <.L68>:
f0101144:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			padc = '-';
f0101147:	c6 45 cf 2d          	movb   $0x2d,-0x31(%ebp)
f010114b:	eb d1                	jmp    f010111e <vprintfmt+0x55>

f010114d <.L32>:
		switch (ch = *(unsigned char *) fmt++) {
f010114d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0101150:	c6 45 cf 30          	movb   $0x30,-0x31(%ebp)
f0101154:	eb c8                	jmp    f010111e <vprintfmt+0x55>

f0101156 <.L31>:
f0101156:	0f b6 d2             	movzbl %dl,%edx
f0101159:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			for (precision = 0; ; ++fmt) {
f010115c:	b8 00 00 00 00       	mov    $0x0,%eax
f0101161:	8b 75 08             	mov    0x8(%ebp),%esi
				precision = precision * 10 + ch - '0';
f0101164:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0101167:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
f010116b:	0f be 13             	movsbl (%ebx),%edx
				if (ch < '0' || ch > '9')
f010116e:	8d 4a d0             	lea    -0x30(%edx),%ecx
f0101171:	83 f9 09             	cmp    $0x9,%ecx
f0101174:	77 58                	ja     f01011ce <.L36+0xf>
			for (precision = 0; ; ++fmt) {
f0101176:	83 c3 01             	add    $0x1,%ebx
				precision = precision * 10 + ch - '0';
f0101179:	eb e9                	jmp    f0101164 <.L31+0xe>

f010117b <.L34>:
			precision = va_arg(ap, int);
f010117b:	8b 45 14             	mov    0x14(%ebp),%eax
f010117e:	8b 00                	mov    (%eax),%eax
f0101180:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0101183:	8b 45 14             	mov    0x14(%ebp),%eax
f0101186:	8d 40 04             	lea    0x4(%eax),%eax
f0101189:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f010118c:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			if (width < 0)
f010118f:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f0101193:	79 89                	jns    f010111e <vprintfmt+0x55>
				width = precision, precision = -1;
f0101195:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0101198:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010119b:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
f01011a2:	e9 77 ff ff ff       	jmp    f010111e <vprintfmt+0x55>

f01011a7 <.L33>:
f01011a7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01011aa:	85 c0                	test   %eax,%eax
f01011ac:	ba 00 00 00 00       	mov    $0x0,%edx
f01011b1:	0f 49 d0             	cmovns %eax,%edx
f01011b4:	89 55 d4             	mov    %edx,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f01011b7:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
f01011ba:	e9 5f ff ff ff       	jmp    f010111e <vprintfmt+0x55>

f01011bf <.L36>:
		switch (ch = *(unsigned char *) fmt++) {
f01011bf:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			altflag = 1;
f01011c2:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
			goto reswitch;
f01011c9:	e9 50 ff ff ff       	jmp    f010111e <vprintfmt+0x55>
f01011ce:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01011d1:	89 75 08             	mov    %esi,0x8(%ebp)
f01011d4:	eb b9                	jmp    f010118f <.L34+0x14>

f01011d6 <.L27>:
			lflag++;
f01011d6:	83 45 c8 01          	addl   $0x1,-0x38(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f01011da:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
f01011dd:	e9 3c ff ff ff       	jmp    f010111e <vprintfmt+0x55>

f01011e2 <.L30>:
f01011e2:	8b 75 08             	mov    0x8(%ebp),%esi
			putch(va_arg(ap, int), putdat);
f01011e5:	8b 45 14             	mov    0x14(%ebp),%eax
f01011e8:	8d 58 04             	lea    0x4(%eax),%ebx
f01011eb:	83 ec 08             	sub    $0x8,%esp
f01011ee:	57                   	push   %edi
f01011ef:	ff 30                	pushl  (%eax)
f01011f1:	ff d6                	call   *%esi
			break;
f01011f3:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
f01011f6:	89 5d 14             	mov    %ebx,0x14(%ebp)
			break;
f01011f9:	e9 c6 02 00 00       	jmp    f01014c4 <.L25+0x45>

f01011fe <.L28>:
f01011fe:	8b 75 08             	mov    0x8(%ebp),%esi
			err = va_arg(ap, int);
f0101201:	8b 45 14             	mov    0x14(%ebp),%eax
f0101204:	8d 58 04             	lea    0x4(%eax),%ebx
f0101207:	8b 00                	mov    (%eax),%eax
f0101209:	99                   	cltd   
f010120a:	31 d0                	xor    %edx,%eax
f010120c:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f010120e:	83 f8 06             	cmp    $0x6,%eax
f0101211:	7f 27                	jg     f010123a <.L28+0x3c>
f0101213:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f0101216:	8b 14 82             	mov    (%edx,%eax,4),%edx
f0101219:	85 d2                	test   %edx,%edx
f010121b:	74 1d                	je     f010123a <.L28+0x3c>
				printfmt(putch, putdat, "%s", p);
f010121d:	52                   	push   %edx
f010121e:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101221:	8d 80 63 ff fe ff    	lea    -0x1009d(%eax),%eax
f0101227:	50                   	push   %eax
f0101228:	57                   	push   %edi
f0101229:	56                   	push   %esi
f010122a:	e8 79 fe ff ff       	call   f01010a8 <printfmt>
f010122f:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0101232:	89 5d 14             	mov    %ebx,0x14(%ebp)
f0101235:	e9 8a 02 00 00       	jmp    f01014c4 <.L25+0x45>
				printfmt(putch, putdat, "error %d", err);
f010123a:	50                   	push   %eax
f010123b:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010123e:	8d 80 5a ff fe ff    	lea    -0x100a6(%eax),%eax
f0101244:	50                   	push   %eax
f0101245:	57                   	push   %edi
f0101246:	56                   	push   %esi
f0101247:	e8 5c fe ff ff       	call   f01010a8 <printfmt>
f010124c:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f010124f:	89 5d 14             	mov    %ebx,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
f0101252:	e9 6d 02 00 00       	jmp    f01014c4 <.L25+0x45>

f0101257 <.L24>:
f0101257:	8b 75 08             	mov    0x8(%ebp),%esi
			if ((p = va_arg(ap, char *)) == NULL)
f010125a:	8b 45 14             	mov    0x14(%ebp),%eax
f010125d:	83 c0 04             	add    $0x4,%eax
f0101260:	89 45 c0             	mov    %eax,-0x40(%ebp)
f0101263:	8b 45 14             	mov    0x14(%ebp),%eax
f0101266:	8b 10                	mov    (%eax),%edx
				p = "(null)";
f0101268:	85 d2                	test   %edx,%edx
f010126a:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010126d:	8d 80 53 ff fe ff    	lea    -0x100ad(%eax),%eax
f0101273:	0f 45 c2             	cmovne %edx,%eax
f0101276:	89 45 c8             	mov    %eax,-0x38(%ebp)
			if (width > 0 && padc != '-')
f0101279:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f010127d:	7e 06                	jle    f0101285 <.L24+0x2e>
f010127f:	80 7d cf 2d          	cmpb   $0x2d,-0x31(%ebp)
f0101283:	75 0d                	jne    f0101292 <.L24+0x3b>
				for (width -= strnlen(p, precision); width > 0; width--)
f0101285:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0101288:	89 c3                	mov    %eax,%ebx
f010128a:	03 45 d4             	add    -0x2c(%ebp),%eax
f010128d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101290:	eb 58                	jmp    f01012ea <.L24+0x93>
f0101292:	83 ec 08             	sub    $0x8,%esp
f0101295:	ff 75 d8             	pushl  -0x28(%ebp)
f0101298:	ff 75 c8             	pushl  -0x38(%ebp)
f010129b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f010129e:	e8 85 04 00 00       	call   f0101728 <strnlen>
f01012a3:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f01012a6:	29 c2                	sub    %eax,%edx
f01012a8:	89 55 bc             	mov    %edx,-0x44(%ebp)
f01012ab:	83 c4 10             	add    $0x10,%esp
f01012ae:	89 d3                	mov    %edx,%ebx
					putch(padc, putdat);
f01012b0:	0f be 45 cf          	movsbl -0x31(%ebp),%eax
f01012b4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
f01012b7:	85 db                	test   %ebx,%ebx
f01012b9:	7e 11                	jle    f01012cc <.L24+0x75>
					putch(padc, putdat);
f01012bb:	83 ec 08             	sub    $0x8,%esp
f01012be:	57                   	push   %edi
f01012bf:	ff 75 d4             	pushl  -0x2c(%ebp)
f01012c2:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
f01012c4:	83 eb 01             	sub    $0x1,%ebx
f01012c7:	83 c4 10             	add    $0x10,%esp
f01012ca:	eb eb                	jmp    f01012b7 <.L24+0x60>
f01012cc:	8b 55 bc             	mov    -0x44(%ebp),%edx
f01012cf:	85 d2                	test   %edx,%edx
f01012d1:	b8 00 00 00 00       	mov    $0x0,%eax
f01012d6:	0f 49 c2             	cmovns %edx,%eax
f01012d9:	29 c2                	sub    %eax,%edx
f01012db:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f01012de:	eb a5                	jmp    f0101285 <.L24+0x2e>
					putch(ch, putdat);
f01012e0:	83 ec 08             	sub    $0x8,%esp
f01012e3:	57                   	push   %edi
f01012e4:	52                   	push   %edx
f01012e5:	ff d6                	call   *%esi
f01012e7:	83 c4 10             	add    $0x10,%esp
f01012ea:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f01012ed:	29 d9                	sub    %ebx,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01012ef:	83 c3 01             	add    $0x1,%ebx
f01012f2:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
f01012f6:	0f be d0             	movsbl %al,%edx
f01012f9:	85 d2                	test   %edx,%edx
f01012fb:	74 4b                	je     f0101348 <.L24+0xf1>
f01012fd:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0101301:	78 06                	js     f0101309 <.L24+0xb2>
f0101303:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
f0101307:	78 1e                	js     f0101327 <.L24+0xd0>
				if (altflag && (ch < ' ' || ch > '~'))
f0101309:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
f010130d:	74 d1                	je     f01012e0 <.L24+0x89>
f010130f:	0f be c0             	movsbl %al,%eax
f0101312:	83 e8 20             	sub    $0x20,%eax
f0101315:	83 f8 5e             	cmp    $0x5e,%eax
f0101318:	76 c6                	jbe    f01012e0 <.L24+0x89>
					putch('?', putdat);
f010131a:	83 ec 08             	sub    $0x8,%esp
f010131d:	57                   	push   %edi
f010131e:	6a 3f                	push   $0x3f
f0101320:	ff d6                	call   *%esi
f0101322:	83 c4 10             	add    $0x10,%esp
f0101325:	eb c3                	jmp    f01012ea <.L24+0x93>
f0101327:	89 cb                	mov    %ecx,%ebx
f0101329:	eb 0e                	jmp    f0101339 <.L24+0xe2>
				putch(' ', putdat);
f010132b:	83 ec 08             	sub    $0x8,%esp
f010132e:	57                   	push   %edi
f010132f:	6a 20                	push   $0x20
f0101331:	ff d6                	call   *%esi
			for (; width > 0; width--)
f0101333:	83 eb 01             	sub    $0x1,%ebx
f0101336:	83 c4 10             	add    $0x10,%esp
f0101339:	85 db                	test   %ebx,%ebx
f010133b:	7f ee                	jg     f010132b <.L24+0xd4>
			if ((p = va_arg(ap, char *)) == NULL)
f010133d:	8b 45 c0             	mov    -0x40(%ebp),%eax
f0101340:	89 45 14             	mov    %eax,0x14(%ebp)
f0101343:	e9 7c 01 00 00       	jmp    f01014c4 <.L25+0x45>
f0101348:	89 cb                	mov    %ecx,%ebx
f010134a:	eb ed                	jmp    f0101339 <.L24+0xe2>

f010134c <.L29>:
f010134c:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f010134f:	8b 75 08             	mov    0x8(%ebp),%esi
	if (lflag >= 2)
f0101352:	83 f9 01             	cmp    $0x1,%ecx
f0101355:	7f 1b                	jg     f0101372 <.L29+0x26>
	else if (lflag)
f0101357:	85 c9                	test   %ecx,%ecx
f0101359:	74 63                	je     f01013be <.L29+0x72>
		return va_arg(*ap, long);
f010135b:	8b 45 14             	mov    0x14(%ebp),%eax
f010135e:	8b 00                	mov    (%eax),%eax
f0101360:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0101363:	99                   	cltd   
f0101364:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0101367:	8b 45 14             	mov    0x14(%ebp),%eax
f010136a:	8d 40 04             	lea    0x4(%eax),%eax
f010136d:	89 45 14             	mov    %eax,0x14(%ebp)
f0101370:	eb 17                	jmp    f0101389 <.L29+0x3d>
		return va_arg(*ap, long long);
f0101372:	8b 45 14             	mov    0x14(%ebp),%eax
f0101375:	8b 50 04             	mov    0x4(%eax),%edx
f0101378:	8b 00                	mov    (%eax),%eax
f010137a:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010137d:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0101380:	8b 45 14             	mov    0x14(%ebp),%eax
f0101383:	8d 40 08             	lea    0x8(%eax),%eax
f0101386:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
f0101389:	8b 55 d8             	mov    -0x28(%ebp),%edx
f010138c:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
f010138f:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
f0101394:	85 c9                	test   %ecx,%ecx
f0101396:	0f 89 0e 01 00 00    	jns    f01014aa <.L25+0x2b>
				putch('-', putdat);
f010139c:	83 ec 08             	sub    $0x8,%esp
f010139f:	57                   	push   %edi
f01013a0:	6a 2d                	push   $0x2d
f01013a2:	ff d6                	call   *%esi
				num = -(long long) num;
f01013a4:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01013a7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f01013aa:	f7 da                	neg    %edx
f01013ac:	83 d1 00             	adc    $0x0,%ecx
f01013af:	f7 d9                	neg    %ecx
f01013b1:	83 c4 10             	add    $0x10,%esp
			base = 10;
f01013b4:	b8 0a 00 00 00       	mov    $0xa,%eax
f01013b9:	e9 ec 00 00 00       	jmp    f01014aa <.L25+0x2b>
		return va_arg(*ap, int);
f01013be:	8b 45 14             	mov    0x14(%ebp),%eax
f01013c1:	8b 00                	mov    (%eax),%eax
f01013c3:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01013c6:	99                   	cltd   
f01013c7:	89 55 dc             	mov    %edx,-0x24(%ebp)
f01013ca:	8b 45 14             	mov    0x14(%ebp),%eax
f01013cd:	8d 40 04             	lea    0x4(%eax),%eax
f01013d0:	89 45 14             	mov    %eax,0x14(%ebp)
f01013d3:	eb b4                	jmp    f0101389 <.L29+0x3d>

f01013d5 <.L23>:
f01013d5:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f01013d8:	8b 75 08             	mov    0x8(%ebp),%esi
	if (lflag >= 2)
f01013db:	83 f9 01             	cmp    $0x1,%ecx
f01013de:	7f 1e                	jg     f01013fe <.L23+0x29>
	else if (lflag)
f01013e0:	85 c9                	test   %ecx,%ecx
f01013e2:	74 32                	je     f0101416 <.L23+0x41>
		return va_arg(*ap, unsigned long);
f01013e4:	8b 45 14             	mov    0x14(%ebp),%eax
f01013e7:	8b 10                	mov    (%eax),%edx
f01013e9:	b9 00 00 00 00       	mov    $0x0,%ecx
f01013ee:	8d 40 04             	lea    0x4(%eax),%eax
f01013f1:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f01013f4:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
f01013f9:	e9 ac 00 00 00       	jmp    f01014aa <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
f01013fe:	8b 45 14             	mov    0x14(%ebp),%eax
f0101401:	8b 10                	mov    (%eax),%edx
f0101403:	8b 48 04             	mov    0x4(%eax),%ecx
f0101406:	8d 40 08             	lea    0x8(%eax),%eax
f0101409:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f010140c:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
f0101411:	e9 94 00 00 00       	jmp    f01014aa <.L25+0x2b>
		return va_arg(*ap, unsigned int);
f0101416:	8b 45 14             	mov    0x14(%ebp),%eax
f0101419:	8b 10                	mov    (%eax),%edx
f010141b:	b9 00 00 00 00       	mov    $0x0,%ecx
f0101420:	8d 40 04             	lea    0x4(%eax),%eax
f0101423:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0101426:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
f010142b:	eb 7d                	jmp    f01014aa <.L25+0x2b>

f010142d <.L26>:
f010142d:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0101430:	8b 75 08             	mov    0x8(%ebp),%esi
	if (lflag >= 2)
f0101433:	83 f9 01             	cmp    $0x1,%ecx
f0101436:	7f 1b                	jg     f0101453 <.L26+0x26>
	else if (lflag)
f0101438:	85 c9                	test   %ecx,%ecx
f010143a:	74 2c                	je     f0101468 <.L26+0x3b>
		return va_arg(*ap, unsigned long);
f010143c:	8b 45 14             	mov    0x14(%ebp),%eax
f010143f:	8b 10                	mov    (%eax),%edx
f0101441:	b9 00 00 00 00       	mov    $0x0,%ecx
f0101446:	8d 40 04             	lea    0x4(%eax),%eax
f0101449:	89 45 14             	mov    %eax,0x14(%ebp)
            base = 8;
f010144c:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long);
f0101451:	eb 57                	jmp    f01014aa <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
f0101453:	8b 45 14             	mov    0x14(%ebp),%eax
f0101456:	8b 10                	mov    (%eax),%edx
f0101458:	8b 48 04             	mov    0x4(%eax),%ecx
f010145b:	8d 40 08             	lea    0x8(%eax),%eax
f010145e:	89 45 14             	mov    %eax,0x14(%ebp)
            base = 8;
f0101461:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long long);
f0101466:	eb 42                	jmp    f01014aa <.L25+0x2b>
		return va_arg(*ap, unsigned int);
f0101468:	8b 45 14             	mov    0x14(%ebp),%eax
f010146b:	8b 10                	mov    (%eax),%edx
f010146d:	b9 00 00 00 00       	mov    $0x0,%ecx
f0101472:	8d 40 04             	lea    0x4(%eax),%eax
f0101475:	89 45 14             	mov    %eax,0x14(%ebp)
            base = 8;
f0101478:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned int);
f010147d:	eb 2b                	jmp    f01014aa <.L25+0x2b>

f010147f <.L25>:
f010147f:	8b 75 08             	mov    0x8(%ebp),%esi
			putch('0', putdat);
f0101482:	83 ec 08             	sub    $0x8,%esp
f0101485:	57                   	push   %edi
f0101486:	6a 30                	push   $0x30
f0101488:	ff d6                	call   *%esi
			putch('x', putdat);
f010148a:	83 c4 08             	add    $0x8,%esp
f010148d:	57                   	push   %edi
f010148e:	6a 78                	push   $0x78
f0101490:	ff d6                	call   *%esi
			num = (unsigned long long)
f0101492:	8b 45 14             	mov    0x14(%ebp),%eax
f0101495:	8b 10                	mov    (%eax),%edx
f0101497:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
f010149c:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
f010149f:	8d 40 04             	lea    0x4(%eax),%eax
f01014a2:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01014a5:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
f01014aa:	83 ec 0c             	sub    $0xc,%esp
f01014ad:	0f be 5d cf          	movsbl -0x31(%ebp),%ebx
f01014b1:	53                   	push   %ebx
f01014b2:	ff 75 d4             	pushl  -0x2c(%ebp)
f01014b5:	50                   	push   %eax
f01014b6:	51                   	push   %ecx
f01014b7:	52                   	push   %edx
f01014b8:	89 fa                	mov    %edi,%edx
f01014ba:	89 f0                	mov    %esi,%eax
f01014bc:	e8 08 fb ff ff       	call   f0100fc9 <printnum>
			break;
f01014c1:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
f01014c4:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		while ((ch = *(unsigned char *) fmt++) != '%') {
f01014c7:	83 c3 01             	add    $0x1,%ebx
f01014ca:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
f01014ce:	83 f8 25             	cmp    $0x25,%eax
f01014d1:	0f 84 23 fc ff ff    	je     f01010fa <vprintfmt+0x31>
			if (ch == '\0')
f01014d7:	85 c0                	test   %eax,%eax
f01014d9:	0f 84 97 00 00 00    	je     f0101576 <.L20+0x23>
			putch(ch, putdat);
f01014df:	83 ec 08             	sub    $0x8,%esp
f01014e2:	57                   	push   %edi
f01014e3:	50                   	push   %eax
f01014e4:	ff d6                	call   *%esi
f01014e6:	83 c4 10             	add    $0x10,%esp
f01014e9:	eb dc                	jmp    f01014c7 <.L25+0x48>

f01014eb <.L21>:
f01014eb:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f01014ee:	8b 75 08             	mov    0x8(%ebp),%esi
	if (lflag >= 2)
f01014f1:	83 f9 01             	cmp    $0x1,%ecx
f01014f4:	7f 1b                	jg     f0101511 <.L21+0x26>
	else if (lflag)
f01014f6:	85 c9                	test   %ecx,%ecx
f01014f8:	74 2c                	je     f0101526 <.L21+0x3b>
		return va_arg(*ap, unsigned long);
f01014fa:	8b 45 14             	mov    0x14(%ebp),%eax
f01014fd:	8b 10                	mov    (%eax),%edx
f01014ff:	b9 00 00 00 00       	mov    $0x0,%ecx
f0101504:	8d 40 04             	lea    0x4(%eax),%eax
f0101507:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f010150a:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
f010150f:	eb 99                	jmp    f01014aa <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
f0101511:	8b 45 14             	mov    0x14(%ebp),%eax
f0101514:	8b 10                	mov    (%eax),%edx
f0101516:	8b 48 04             	mov    0x4(%eax),%ecx
f0101519:	8d 40 08             	lea    0x8(%eax),%eax
f010151c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f010151f:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
f0101524:	eb 84                	jmp    f01014aa <.L25+0x2b>
		return va_arg(*ap, unsigned int);
f0101526:	8b 45 14             	mov    0x14(%ebp),%eax
f0101529:	8b 10                	mov    (%eax),%edx
f010152b:	b9 00 00 00 00       	mov    $0x0,%ecx
f0101530:	8d 40 04             	lea    0x4(%eax),%eax
f0101533:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0101536:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
f010153b:	e9 6a ff ff ff       	jmp    f01014aa <.L25+0x2b>

f0101540 <.L35>:
f0101540:	8b 75 08             	mov    0x8(%ebp),%esi
			putch(ch, putdat);
f0101543:	83 ec 08             	sub    $0x8,%esp
f0101546:	57                   	push   %edi
f0101547:	6a 25                	push   $0x25
f0101549:	ff d6                	call   *%esi
			break;
f010154b:	83 c4 10             	add    $0x10,%esp
f010154e:	e9 71 ff ff ff       	jmp    f01014c4 <.L25+0x45>

f0101553 <.L20>:
f0101553:	8b 75 08             	mov    0x8(%ebp),%esi
			putch('%', putdat);
f0101556:	83 ec 08             	sub    $0x8,%esp
f0101559:	57                   	push   %edi
f010155a:	6a 25                	push   $0x25
f010155c:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f010155e:	83 c4 10             	add    $0x10,%esp
f0101561:	89 d8                	mov    %ebx,%eax
f0101563:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
f0101567:	74 05                	je     f010156e <.L20+0x1b>
f0101569:	83 e8 01             	sub    $0x1,%eax
f010156c:	eb f5                	jmp    f0101563 <.L20+0x10>
f010156e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0101571:	e9 4e ff ff ff       	jmp    f01014c4 <.L25+0x45>
}
f0101576:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101579:	5b                   	pop    %ebx
f010157a:	5e                   	pop    %esi
f010157b:	5f                   	pop    %edi
f010157c:	5d                   	pop    %ebp
f010157d:	c3                   	ret    

f010157e <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f010157e:	f3 0f 1e fb          	endbr32 
f0101582:	55                   	push   %ebp
f0101583:	89 e5                	mov    %esp,%ebp
f0101585:	53                   	push   %ebx
f0101586:	83 ec 14             	sub    $0x14,%esp
f0101589:	e8 3e ec ff ff       	call   f01001cc <__x86.get_pc_thunk.bx>
f010158e:	81 c3 7a 0d 01 00    	add    $0x10d7a,%ebx
f0101594:	8b 45 08             	mov    0x8(%ebp),%eax
f0101597:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f010159a:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010159d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f01015a1:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f01015a4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f01015ab:	85 c0                	test   %eax,%eax
f01015ad:	74 2b                	je     f01015da <vsnprintf+0x5c>
f01015af:	85 d2                	test   %edx,%edx
f01015b1:	7e 27                	jle    f01015da <vsnprintf+0x5c>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f01015b3:	ff 75 14             	pushl  0x14(%ebp)
f01015b6:	ff 75 10             	pushl  0x10(%ebp)
f01015b9:	8d 45 ec             	lea    -0x14(%ebp),%eax
f01015bc:	50                   	push   %eax
f01015bd:	8d 83 7f ed fe ff    	lea    -0x11281(%ebx),%eax
f01015c3:	50                   	push   %eax
f01015c4:	e8 00 fb ff ff       	call   f01010c9 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f01015c9:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01015cc:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f01015cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01015d2:	83 c4 10             	add    $0x10,%esp
}
f01015d5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01015d8:	c9                   	leave  
f01015d9:	c3                   	ret    
		return -E_INVAL;
f01015da:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01015df:	eb f4                	jmp    f01015d5 <vsnprintf+0x57>

f01015e1 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f01015e1:	f3 0f 1e fb          	endbr32 
f01015e5:	55                   	push   %ebp
f01015e6:	89 e5                	mov    %esp,%ebp
f01015e8:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f01015eb:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f01015ee:	50                   	push   %eax
f01015ef:	ff 75 10             	pushl  0x10(%ebp)
f01015f2:	ff 75 0c             	pushl  0xc(%ebp)
f01015f5:	ff 75 08             	pushl  0x8(%ebp)
f01015f8:	e8 81 ff ff ff       	call   f010157e <vsnprintf>
	va_end(ap);

	return rc;
}
f01015fd:	c9                   	leave  
f01015fe:	c3                   	ret    

f01015ff <__x86.get_pc_thunk.cx>:
f01015ff:	8b 0c 24             	mov    (%esp),%ecx
f0101602:	c3                   	ret    

f0101603 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0101603:	f3 0f 1e fb          	endbr32 
f0101607:	55                   	push   %ebp
f0101608:	89 e5                	mov    %esp,%ebp
f010160a:	57                   	push   %edi
f010160b:	56                   	push   %esi
f010160c:	53                   	push   %ebx
f010160d:	83 ec 1c             	sub    $0x1c,%esp
f0101610:	e8 b7 eb ff ff       	call   f01001cc <__x86.get_pc_thunk.bx>
f0101615:	81 c3 f3 0c 01 00    	add    $0x10cf3,%ebx
f010161b:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f010161e:	85 c0                	test   %eax,%eax
f0101620:	74 13                	je     f0101635 <readline+0x32>
		cprintf("%s", prompt);
f0101622:	83 ec 08             	sub    $0x8,%esp
f0101625:	50                   	push   %eax
f0101626:	8d 83 63 ff fe ff    	lea    -0x1009d(%ebx),%eax
f010162c:	50                   	push   %eax
f010162d:	e8 25 f6 ff ff       	call   f0100c57 <cprintf>
f0101632:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f0101635:	83 ec 0c             	sub    $0xc,%esp
f0101638:	6a 00                	push   $0x0
f010163a:	e8 37 f1 ff ff       	call   f0100776 <iscons>
f010163f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0101642:	83 c4 10             	add    $0x10,%esp
	i = 0;
f0101645:	bf 00 00 00 00       	mov    $0x0,%edi
				cputchar('\b');
			i--;
		} else if (c >= ' ' && i < BUFLEN-1) {
			if (echoing)
				cputchar(c);
			buf[i++] = c;
f010164a:	8d 83 98 1f 00 00    	lea    0x1f98(%ebx),%eax
f0101650:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0101653:	eb 51                	jmp    f01016a6 <readline+0xa3>
			cprintf("read error: %e\n", c);
f0101655:	83 ec 08             	sub    $0x8,%esp
f0101658:	50                   	push   %eax
f0101659:	8d 83 28 01 ff ff    	lea    -0xfed8(%ebx),%eax
f010165f:	50                   	push   %eax
f0101660:	e8 f2 f5 ff ff       	call   f0100c57 <cprintf>
			return NULL;
f0101665:	83 c4 10             	add    $0x10,%esp
f0101668:	b8 00 00 00 00       	mov    $0x0,%eax
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
f010166d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101670:	5b                   	pop    %ebx
f0101671:	5e                   	pop    %esi
f0101672:	5f                   	pop    %edi
f0101673:	5d                   	pop    %ebp
f0101674:	c3                   	ret    
			if (echoing)
f0101675:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0101679:	75 05                	jne    f0101680 <readline+0x7d>
			i--;
f010167b:	83 ef 01             	sub    $0x1,%edi
f010167e:	eb 26                	jmp    f01016a6 <readline+0xa3>
				cputchar('\b');
f0101680:	83 ec 0c             	sub    $0xc,%esp
f0101683:	6a 08                	push   $0x8
f0101685:	e8 c3 f0 ff ff       	call   f010074d <cputchar>
f010168a:	83 c4 10             	add    $0x10,%esp
f010168d:	eb ec                	jmp    f010167b <readline+0x78>
				cputchar(c);
f010168f:	83 ec 0c             	sub    $0xc,%esp
f0101692:	56                   	push   %esi
f0101693:	e8 b5 f0 ff ff       	call   f010074d <cputchar>
f0101698:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f010169b:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f010169e:	89 f0                	mov    %esi,%eax
f01016a0:	88 04 39             	mov    %al,(%ecx,%edi,1)
f01016a3:	8d 7f 01             	lea    0x1(%edi),%edi
		c = getchar();
f01016a6:	e8 b6 f0 ff ff       	call   f0100761 <getchar>
f01016ab:	89 c6                	mov    %eax,%esi
		if (c < 0) {
f01016ad:	85 c0                	test   %eax,%eax
f01016af:	78 a4                	js     f0101655 <readline+0x52>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f01016b1:	83 f8 08             	cmp    $0x8,%eax
f01016b4:	0f 94 c2             	sete   %dl
f01016b7:	83 f8 7f             	cmp    $0x7f,%eax
f01016ba:	0f 94 c0             	sete   %al
f01016bd:	08 c2                	or     %al,%dl
f01016bf:	74 04                	je     f01016c5 <readline+0xc2>
f01016c1:	85 ff                	test   %edi,%edi
f01016c3:	7f b0                	jg     f0101675 <readline+0x72>
		} else if (c >= ' ' && i < BUFLEN-1) {
f01016c5:	83 fe 1f             	cmp    $0x1f,%esi
f01016c8:	7e 10                	jle    f01016da <readline+0xd7>
f01016ca:	81 ff fe 03 00 00    	cmp    $0x3fe,%edi
f01016d0:	7f 08                	jg     f01016da <readline+0xd7>
			if (echoing)
f01016d2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01016d6:	74 c3                	je     f010169b <readline+0x98>
f01016d8:	eb b5                	jmp    f010168f <readline+0x8c>
		} else if (c == '\n' || c == '\r') {
f01016da:	83 fe 0a             	cmp    $0xa,%esi
f01016dd:	74 05                	je     f01016e4 <readline+0xe1>
f01016df:	83 fe 0d             	cmp    $0xd,%esi
f01016e2:	75 c2                	jne    f01016a6 <readline+0xa3>
			if (echoing)
f01016e4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01016e8:	75 13                	jne    f01016fd <readline+0xfa>
			buf[i] = 0;
f01016ea:	c6 84 3b 98 1f 00 00 	movb   $0x0,0x1f98(%ebx,%edi,1)
f01016f1:	00 
			return buf;
f01016f2:	8d 83 98 1f 00 00    	lea    0x1f98(%ebx),%eax
f01016f8:	e9 70 ff ff ff       	jmp    f010166d <readline+0x6a>
				cputchar('\n');
f01016fd:	83 ec 0c             	sub    $0xc,%esp
f0101700:	6a 0a                	push   $0xa
f0101702:	e8 46 f0 ff ff       	call   f010074d <cputchar>
f0101707:	83 c4 10             	add    $0x10,%esp
f010170a:	eb de                	jmp    f01016ea <readline+0xe7>

f010170c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f010170c:	f3 0f 1e fb          	endbr32 
f0101710:	55                   	push   %ebp
f0101711:	89 e5                	mov    %esp,%ebp
f0101713:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0101716:	b8 00 00 00 00       	mov    $0x0,%eax
f010171b:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f010171f:	74 05                	je     f0101726 <strlen+0x1a>
		n++;
f0101721:	83 c0 01             	add    $0x1,%eax
f0101724:	eb f5                	jmp    f010171b <strlen+0xf>
	return n;
}
f0101726:	5d                   	pop    %ebp
f0101727:	c3                   	ret    

f0101728 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0101728:	f3 0f 1e fb          	endbr32 
f010172c:	55                   	push   %ebp
f010172d:	89 e5                	mov    %esp,%ebp
f010172f:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0101732:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0101735:	b8 00 00 00 00       	mov    $0x0,%eax
f010173a:	39 d0                	cmp    %edx,%eax
f010173c:	74 0d                	je     f010174b <strnlen+0x23>
f010173e:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f0101742:	74 05                	je     f0101749 <strnlen+0x21>
		n++;
f0101744:	83 c0 01             	add    $0x1,%eax
f0101747:	eb f1                	jmp    f010173a <strnlen+0x12>
f0101749:	89 c2                	mov    %eax,%edx
	return n;
}
f010174b:	89 d0                	mov    %edx,%eax
f010174d:	5d                   	pop    %ebp
f010174e:	c3                   	ret    

f010174f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f010174f:	f3 0f 1e fb          	endbr32 
f0101753:	55                   	push   %ebp
f0101754:	89 e5                	mov    %esp,%ebp
f0101756:	53                   	push   %ebx
f0101757:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010175a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f010175d:	b8 00 00 00 00       	mov    $0x0,%eax
f0101762:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
f0101766:	88 14 01             	mov    %dl,(%ecx,%eax,1)
f0101769:	83 c0 01             	add    $0x1,%eax
f010176c:	84 d2                	test   %dl,%dl
f010176e:	75 f2                	jne    f0101762 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
f0101770:	89 c8                	mov    %ecx,%eax
f0101772:	5b                   	pop    %ebx
f0101773:	5d                   	pop    %ebp
f0101774:	c3                   	ret    

f0101775 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0101775:	f3 0f 1e fb          	endbr32 
f0101779:	55                   	push   %ebp
f010177a:	89 e5                	mov    %esp,%ebp
f010177c:	53                   	push   %ebx
f010177d:	83 ec 10             	sub    $0x10,%esp
f0101780:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0101783:	53                   	push   %ebx
f0101784:	e8 83 ff ff ff       	call   f010170c <strlen>
f0101789:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
f010178c:	ff 75 0c             	pushl  0xc(%ebp)
f010178f:	01 d8                	add    %ebx,%eax
f0101791:	50                   	push   %eax
f0101792:	e8 b8 ff ff ff       	call   f010174f <strcpy>
	return dst;
}
f0101797:	89 d8                	mov    %ebx,%eax
f0101799:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010179c:	c9                   	leave  
f010179d:	c3                   	ret    

f010179e <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f010179e:	f3 0f 1e fb          	endbr32 
f01017a2:	55                   	push   %ebp
f01017a3:	89 e5                	mov    %esp,%ebp
f01017a5:	56                   	push   %esi
f01017a6:	53                   	push   %ebx
f01017a7:	8b 75 08             	mov    0x8(%ebp),%esi
f01017aa:	8b 55 0c             	mov    0xc(%ebp),%edx
f01017ad:	89 f3                	mov    %esi,%ebx
f01017af:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01017b2:	89 f0                	mov    %esi,%eax
f01017b4:	39 d8                	cmp    %ebx,%eax
f01017b6:	74 11                	je     f01017c9 <strncpy+0x2b>
		*dst++ = *src;
f01017b8:	83 c0 01             	add    $0x1,%eax
f01017bb:	0f b6 0a             	movzbl (%edx),%ecx
f01017be:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f01017c1:	80 f9 01             	cmp    $0x1,%cl
f01017c4:	83 da ff             	sbb    $0xffffffff,%edx
f01017c7:	eb eb                	jmp    f01017b4 <strncpy+0x16>
	}
	return ret;
}
f01017c9:	89 f0                	mov    %esi,%eax
f01017cb:	5b                   	pop    %ebx
f01017cc:	5e                   	pop    %esi
f01017cd:	5d                   	pop    %ebp
f01017ce:	c3                   	ret    

f01017cf <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f01017cf:	f3 0f 1e fb          	endbr32 
f01017d3:	55                   	push   %ebp
f01017d4:	89 e5                	mov    %esp,%ebp
f01017d6:	56                   	push   %esi
f01017d7:	53                   	push   %ebx
f01017d8:	8b 75 08             	mov    0x8(%ebp),%esi
f01017db:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01017de:	8b 55 10             	mov    0x10(%ebp),%edx
f01017e1:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f01017e3:	85 d2                	test   %edx,%edx
f01017e5:	74 21                	je     f0101808 <strlcpy+0x39>
f01017e7:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f01017eb:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
f01017ed:	39 c2                	cmp    %eax,%edx
f01017ef:	74 14                	je     f0101805 <strlcpy+0x36>
f01017f1:	0f b6 19             	movzbl (%ecx),%ebx
f01017f4:	84 db                	test   %bl,%bl
f01017f6:	74 0b                	je     f0101803 <strlcpy+0x34>
			*dst++ = *src++;
f01017f8:	83 c1 01             	add    $0x1,%ecx
f01017fb:	83 c2 01             	add    $0x1,%edx
f01017fe:	88 5a ff             	mov    %bl,-0x1(%edx)
f0101801:	eb ea                	jmp    f01017ed <strlcpy+0x1e>
f0101803:	89 d0                	mov    %edx,%eax
		*dst = '\0';
f0101805:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0101808:	29 f0                	sub    %esi,%eax
}
f010180a:	5b                   	pop    %ebx
f010180b:	5e                   	pop    %esi
f010180c:	5d                   	pop    %ebp
f010180d:	c3                   	ret    

f010180e <strcmp>:

int
strcmp(const char *p, const char *q)
{
f010180e:	f3 0f 1e fb          	endbr32 
f0101812:	55                   	push   %ebp
f0101813:	89 e5                	mov    %esp,%ebp
f0101815:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0101818:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f010181b:	0f b6 01             	movzbl (%ecx),%eax
f010181e:	84 c0                	test   %al,%al
f0101820:	74 0c                	je     f010182e <strcmp+0x20>
f0101822:	3a 02                	cmp    (%edx),%al
f0101824:	75 08                	jne    f010182e <strcmp+0x20>
		p++, q++;
f0101826:	83 c1 01             	add    $0x1,%ecx
f0101829:	83 c2 01             	add    $0x1,%edx
f010182c:	eb ed                	jmp    f010181b <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
f010182e:	0f b6 c0             	movzbl %al,%eax
f0101831:	0f b6 12             	movzbl (%edx),%edx
f0101834:	29 d0                	sub    %edx,%eax
}
f0101836:	5d                   	pop    %ebp
f0101837:	c3                   	ret    

f0101838 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0101838:	f3 0f 1e fb          	endbr32 
f010183c:	55                   	push   %ebp
f010183d:	89 e5                	mov    %esp,%ebp
f010183f:	53                   	push   %ebx
f0101840:	8b 45 08             	mov    0x8(%ebp),%eax
f0101843:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101846:	89 c3                	mov    %eax,%ebx
f0101848:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f010184b:	eb 06                	jmp    f0101853 <strncmp+0x1b>
		n--, p++, q++;
f010184d:	83 c0 01             	add    $0x1,%eax
f0101850:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
f0101853:	39 d8                	cmp    %ebx,%eax
f0101855:	74 16                	je     f010186d <strncmp+0x35>
f0101857:	0f b6 08             	movzbl (%eax),%ecx
f010185a:	84 c9                	test   %cl,%cl
f010185c:	74 04                	je     f0101862 <strncmp+0x2a>
f010185e:	3a 0a                	cmp    (%edx),%cl
f0101860:	74 eb                	je     f010184d <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0101862:	0f b6 00             	movzbl (%eax),%eax
f0101865:	0f b6 12             	movzbl (%edx),%edx
f0101868:	29 d0                	sub    %edx,%eax
}
f010186a:	5b                   	pop    %ebx
f010186b:	5d                   	pop    %ebp
f010186c:	c3                   	ret    
		return 0;
f010186d:	b8 00 00 00 00       	mov    $0x0,%eax
f0101872:	eb f6                	jmp    f010186a <strncmp+0x32>

f0101874 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0101874:	f3 0f 1e fb          	endbr32 
f0101878:	55                   	push   %ebp
f0101879:	89 e5                	mov    %esp,%ebp
f010187b:	8b 45 08             	mov    0x8(%ebp),%eax
f010187e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0101882:	0f b6 10             	movzbl (%eax),%edx
f0101885:	84 d2                	test   %dl,%dl
f0101887:	74 09                	je     f0101892 <strchr+0x1e>
		if (*s == c)
f0101889:	38 ca                	cmp    %cl,%dl
f010188b:	74 0a                	je     f0101897 <strchr+0x23>
	for (; *s; s++)
f010188d:	83 c0 01             	add    $0x1,%eax
f0101890:	eb f0                	jmp    f0101882 <strchr+0xe>
			return (char *) s;
	return 0;
f0101892:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101897:	5d                   	pop    %ebp
f0101898:	c3                   	ret    

f0101899 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0101899:	f3 0f 1e fb          	endbr32 
f010189d:	55                   	push   %ebp
f010189e:	89 e5                	mov    %esp,%ebp
f01018a0:	8b 45 08             	mov    0x8(%ebp),%eax
f01018a3:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01018a7:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f01018aa:	38 ca                	cmp    %cl,%dl
f01018ac:	74 09                	je     f01018b7 <strfind+0x1e>
f01018ae:	84 d2                	test   %dl,%dl
f01018b0:	74 05                	je     f01018b7 <strfind+0x1e>
	for (; *s; s++)
f01018b2:	83 c0 01             	add    $0x1,%eax
f01018b5:	eb f0                	jmp    f01018a7 <strfind+0xe>
			break;
	return (char *) s;
}
f01018b7:	5d                   	pop    %ebp
f01018b8:	c3                   	ret    

f01018b9 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f01018b9:	f3 0f 1e fb          	endbr32 
f01018bd:	55                   	push   %ebp
f01018be:	89 e5                	mov    %esp,%ebp
f01018c0:	57                   	push   %edi
f01018c1:	56                   	push   %esi
f01018c2:	53                   	push   %ebx
f01018c3:	8b 7d 08             	mov    0x8(%ebp),%edi
f01018c6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f01018c9:	85 c9                	test   %ecx,%ecx
f01018cb:	74 31                	je     f01018fe <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f01018cd:	89 f8                	mov    %edi,%eax
f01018cf:	09 c8                	or     %ecx,%eax
f01018d1:	a8 03                	test   $0x3,%al
f01018d3:	75 23                	jne    f01018f8 <memset+0x3f>
		c &= 0xFF;
f01018d5:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f01018d9:	89 d3                	mov    %edx,%ebx
f01018db:	c1 e3 08             	shl    $0x8,%ebx
f01018de:	89 d0                	mov    %edx,%eax
f01018e0:	c1 e0 18             	shl    $0x18,%eax
f01018e3:	89 d6                	mov    %edx,%esi
f01018e5:	c1 e6 10             	shl    $0x10,%esi
f01018e8:	09 f0                	or     %esi,%eax
f01018ea:	09 c2                	or     %eax,%edx
f01018ec:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f01018ee:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
f01018f1:	89 d0                	mov    %edx,%eax
f01018f3:	fc                   	cld    
f01018f4:	f3 ab                	rep stos %eax,%es:(%edi)
f01018f6:	eb 06                	jmp    f01018fe <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f01018f8:	8b 45 0c             	mov    0xc(%ebp),%eax
f01018fb:	fc                   	cld    
f01018fc:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f01018fe:	89 f8                	mov    %edi,%eax
f0101900:	5b                   	pop    %ebx
f0101901:	5e                   	pop    %esi
f0101902:	5f                   	pop    %edi
f0101903:	5d                   	pop    %ebp
f0101904:	c3                   	ret    

f0101905 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0101905:	f3 0f 1e fb          	endbr32 
f0101909:	55                   	push   %ebp
f010190a:	89 e5                	mov    %esp,%ebp
f010190c:	57                   	push   %edi
f010190d:	56                   	push   %esi
f010190e:	8b 45 08             	mov    0x8(%ebp),%eax
f0101911:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101914:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0101917:	39 c6                	cmp    %eax,%esi
f0101919:	73 32                	jae    f010194d <memmove+0x48>
f010191b:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f010191e:	39 c2                	cmp    %eax,%edx
f0101920:	76 2b                	jbe    f010194d <memmove+0x48>
		s += n;
		d += n;
f0101922:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0101925:	89 fe                	mov    %edi,%esi
f0101927:	09 ce                	or     %ecx,%esi
f0101929:	09 d6                	or     %edx,%esi
f010192b:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0101931:	75 0e                	jne    f0101941 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0101933:	83 ef 04             	sub    $0x4,%edi
f0101936:	8d 72 fc             	lea    -0x4(%edx),%esi
f0101939:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
f010193c:	fd                   	std    
f010193d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010193f:	eb 09                	jmp    f010194a <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f0101941:	83 ef 01             	sub    $0x1,%edi
f0101944:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
f0101947:	fd                   	std    
f0101948:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f010194a:	fc                   	cld    
f010194b:	eb 1a                	jmp    f0101967 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010194d:	89 c2                	mov    %eax,%edx
f010194f:	09 ca                	or     %ecx,%edx
f0101951:	09 f2                	or     %esi,%edx
f0101953:	f6 c2 03             	test   $0x3,%dl
f0101956:	75 0a                	jne    f0101962 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f0101958:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
f010195b:	89 c7                	mov    %eax,%edi
f010195d:	fc                   	cld    
f010195e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0101960:	eb 05                	jmp    f0101967 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
f0101962:	89 c7                	mov    %eax,%edi
f0101964:	fc                   	cld    
f0101965:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0101967:	5e                   	pop    %esi
f0101968:	5f                   	pop    %edi
f0101969:	5d                   	pop    %ebp
f010196a:	c3                   	ret    

f010196b <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f010196b:	f3 0f 1e fb          	endbr32 
f010196f:	55                   	push   %ebp
f0101970:	89 e5                	mov    %esp,%ebp
f0101972:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f0101975:	ff 75 10             	pushl  0x10(%ebp)
f0101978:	ff 75 0c             	pushl  0xc(%ebp)
f010197b:	ff 75 08             	pushl  0x8(%ebp)
f010197e:	e8 82 ff ff ff       	call   f0101905 <memmove>
}
f0101983:	c9                   	leave  
f0101984:	c3                   	ret    

f0101985 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0101985:	f3 0f 1e fb          	endbr32 
f0101989:	55                   	push   %ebp
f010198a:	89 e5                	mov    %esp,%ebp
f010198c:	56                   	push   %esi
f010198d:	53                   	push   %ebx
f010198e:	8b 45 08             	mov    0x8(%ebp),%eax
f0101991:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101994:	89 c6                	mov    %eax,%esi
f0101996:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0101999:	39 f0                	cmp    %esi,%eax
f010199b:	74 1c                	je     f01019b9 <memcmp+0x34>
		if (*s1 != *s2)
f010199d:	0f b6 08             	movzbl (%eax),%ecx
f01019a0:	0f b6 1a             	movzbl (%edx),%ebx
f01019a3:	38 d9                	cmp    %bl,%cl
f01019a5:	75 08                	jne    f01019af <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
f01019a7:	83 c0 01             	add    $0x1,%eax
f01019aa:	83 c2 01             	add    $0x1,%edx
f01019ad:	eb ea                	jmp    f0101999 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
f01019af:	0f b6 c1             	movzbl %cl,%eax
f01019b2:	0f b6 db             	movzbl %bl,%ebx
f01019b5:	29 d8                	sub    %ebx,%eax
f01019b7:	eb 05                	jmp    f01019be <memcmp+0x39>
	}

	return 0;
f01019b9:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01019be:	5b                   	pop    %ebx
f01019bf:	5e                   	pop    %esi
f01019c0:	5d                   	pop    %ebp
f01019c1:	c3                   	ret    

f01019c2 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f01019c2:	f3 0f 1e fb          	endbr32 
f01019c6:	55                   	push   %ebp
f01019c7:	89 e5                	mov    %esp,%ebp
f01019c9:	8b 45 08             	mov    0x8(%ebp),%eax
f01019cc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f01019cf:	89 c2                	mov    %eax,%edx
f01019d1:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f01019d4:	39 d0                	cmp    %edx,%eax
f01019d6:	73 09                	jae    f01019e1 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
f01019d8:	38 08                	cmp    %cl,(%eax)
f01019da:	74 05                	je     f01019e1 <memfind+0x1f>
	for (; s < ends; s++)
f01019dc:	83 c0 01             	add    $0x1,%eax
f01019df:	eb f3                	jmp    f01019d4 <memfind+0x12>
			break;
	return (void *) s;
}
f01019e1:	5d                   	pop    %ebp
f01019e2:	c3                   	ret    

f01019e3 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f01019e3:	f3 0f 1e fb          	endbr32 
f01019e7:	55                   	push   %ebp
f01019e8:	89 e5                	mov    %esp,%ebp
f01019ea:	57                   	push   %edi
f01019eb:	56                   	push   %esi
f01019ec:	53                   	push   %ebx
f01019ed:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01019f0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01019f3:	eb 03                	jmp    f01019f8 <strtol+0x15>
		s++;
f01019f5:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
f01019f8:	0f b6 01             	movzbl (%ecx),%eax
f01019fb:	3c 20                	cmp    $0x20,%al
f01019fd:	74 f6                	je     f01019f5 <strtol+0x12>
f01019ff:	3c 09                	cmp    $0x9,%al
f0101a01:	74 f2                	je     f01019f5 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
f0101a03:	3c 2b                	cmp    $0x2b,%al
f0101a05:	74 2a                	je     f0101a31 <strtol+0x4e>
	int neg = 0;
f0101a07:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
f0101a0c:	3c 2d                	cmp    $0x2d,%al
f0101a0e:	74 2b                	je     f0101a3b <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0101a10:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f0101a16:	75 0f                	jne    f0101a27 <strtol+0x44>
f0101a18:	80 39 30             	cmpb   $0x30,(%ecx)
f0101a1b:	74 28                	je     f0101a45 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0101a1d:	85 db                	test   %ebx,%ebx
f0101a1f:	b8 0a 00 00 00       	mov    $0xa,%eax
f0101a24:	0f 44 d8             	cmove  %eax,%ebx
f0101a27:	b8 00 00 00 00       	mov    $0x0,%eax
f0101a2c:	89 5d 10             	mov    %ebx,0x10(%ebp)
f0101a2f:	eb 46                	jmp    f0101a77 <strtol+0x94>
		s++;
f0101a31:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
f0101a34:	bf 00 00 00 00       	mov    $0x0,%edi
f0101a39:	eb d5                	jmp    f0101a10 <strtol+0x2d>
		s++, neg = 1;
f0101a3b:	83 c1 01             	add    $0x1,%ecx
f0101a3e:	bf 01 00 00 00       	mov    $0x1,%edi
f0101a43:	eb cb                	jmp    f0101a10 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0101a45:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f0101a49:	74 0e                	je     f0101a59 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
f0101a4b:	85 db                	test   %ebx,%ebx
f0101a4d:	75 d8                	jne    f0101a27 <strtol+0x44>
		s++, base = 8;
f0101a4f:	83 c1 01             	add    $0x1,%ecx
f0101a52:	bb 08 00 00 00       	mov    $0x8,%ebx
f0101a57:	eb ce                	jmp    f0101a27 <strtol+0x44>
		s += 2, base = 16;
f0101a59:	83 c1 02             	add    $0x2,%ecx
f0101a5c:	bb 10 00 00 00       	mov    $0x10,%ebx
f0101a61:	eb c4                	jmp    f0101a27 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
f0101a63:	0f be d2             	movsbl %dl,%edx
f0101a66:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f0101a69:	3b 55 10             	cmp    0x10(%ebp),%edx
f0101a6c:	7d 3a                	jge    f0101aa8 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
f0101a6e:	83 c1 01             	add    $0x1,%ecx
f0101a71:	0f af 45 10          	imul   0x10(%ebp),%eax
f0101a75:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
f0101a77:	0f b6 11             	movzbl (%ecx),%edx
f0101a7a:	8d 72 d0             	lea    -0x30(%edx),%esi
f0101a7d:	89 f3                	mov    %esi,%ebx
f0101a7f:	80 fb 09             	cmp    $0x9,%bl
f0101a82:	76 df                	jbe    f0101a63 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
f0101a84:	8d 72 9f             	lea    -0x61(%edx),%esi
f0101a87:	89 f3                	mov    %esi,%ebx
f0101a89:	80 fb 19             	cmp    $0x19,%bl
f0101a8c:	77 08                	ja     f0101a96 <strtol+0xb3>
			dig = *s - 'a' + 10;
f0101a8e:	0f be d2             	movsbl %dl,%edx
f0101a91:	83 ea 57             	sub    $0x57,%edx
f0101a94:	eb d3                	jmp    f0101a69 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
f0101a96:	8d 72 bf             	lea    -0x41(%edx),%esi
f0101a99:	89 f3                	mov    %esi,%ebx
f0101a9b:	80 fb 19             	cmp    $0x19,%bl
f0101a9e:	77 08                	ja     f0101aa8 <strtol+0xc5>
			dig = *s - 'A' + 10;
f0101aa0:	0f be d2             	movsbl %dl,%edx
f0101aa3:	83 ea 37             	sub    $0x37,%edx
f0101aa6:	eb c1                	jmp    f0101a69 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
f0101aa8:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0101aac:	74 05                	je     f0101ab3 <strtol+0xd0>
		*endptr = (char *) s;
f0101aae:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101ab1:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
f0101ab3:	89 c2                	mov    %eax,%edx
f0101ab5:	f7 da                	neg    %edx
f0101ab7:	85 ff                	test   %edi,%edi
f0101ab9:	0f 45 c2             	cmovne %edx,%eax
}
f0101abc:	5b                   	pop    %ebx
f0101abd:	5e                   	pop    %esi
f0101abe:	5f                   	pop    %edi
f0101abf:	5d                   	pop    %ebp
f0101ac0:	c3                   	ret    
f0101ac1:	66 90                	xchg   %ax,%ax
f0101ac3:	66 90                	xchg   %ax,%ax
f0101ac5:	66 90                	xchg   %ax,%ax
f0101ac7:	66 90                	xchg   %ax,%ax
f0101ac9:	66 90                	xchg   %ax,%ax
f0101acb:	66 90                	xchg   %ax,%ax
f0101acd:	66 90                	xchg   %ax,%ax
f0101acf:	90                   	nop

f0101ad0 <__udivdi3>:
f0101ad0:	f3 0f 1e fb          	endbr32 
f0101ad4:	55                   	push   %ebp
f0101ad5:	57                   	push   %edi
f0101ad6:	56                   	push   %esi
f0101ad7:	53                   	push   %ebx
f0101ad8:	83 ec 1c             	sub    $0x1c,%esp
f0101adb:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f0101adf:	8b 6c 24 30          	mov    0x30(%esp),%ebp
f0101ae3:	8b 74 24 34          	mov    0x34(%esp),%esi
f0101ae7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
f0101aeb:	85 d2                	test   %edx,%edx
f0101aed:	75 19                	jne    f0101b08 <__udivdi3+0x38>
f0101aef:	39 f3                	cmp    %esi,%ebx
f0101af1:	76 4d                	jbe    f0101b40 <__udivdi3+0x70>
f0101af3:	31 ff                	xor    %edi,%edi
f0101af5:	89 e8                	mov    %ebp,%eax
f0101af7:	89 f2                	mov    %esi,%edx
f0101af9:	f7 f3                	div    %ebx
f0101afb:	89 fa                	mov    %edi,%edx
f0101afd:	83 c4 1c             	add    $0x1c,%esp
f0101b00:	5b                   	pop    %ebx
f0101b01:	5e                   	pop    %esi
f0101b02:	5f                   	pop    %edi
f0101b03:	5d                   	pop    %ebp
f0101b04:	c3                   	ret    
f0101b05:	8d 76 00             	lea    0x0(%esi),%esi
f0101b08:	39 f2                	cmp    %esi,%edx
f0101b0a:	76 14                	jbe    f0101b20 <__udivdi3+0x50>
f0101b0c:	31 ff                	xor    %edi,%edi
f0101b0e:	31 c0                	xor    %eax,%eax
f0101b10:	89 fa                	mov    %edi,%edx
f0101b12:	83 c4 1c             	add    $0x1c,%esp
f0101b15:	5b                   	pop    %ebx
f0101b16:	5e                   	pop    %esi
f0101b17:	5f                   	pop    %edi
f0101b18:	5d                   	pop    %ebp
f0101b19:	c3                   	ret    
f0101b1a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0101b20:	0f bd fa             	bsr    %edx,%edi
f0101b23:	83 f7 1f             	xor    $0x1f,%edi
f0101b26:	75 48                	jne    f0101b70 <__udivdi3+0xa0>
f0101b28:	39 f2                	cmp    %esi,%edx
f0101b2a:	72 06                	jb     f0101b32 <__udivdi3+0x62>
f0101b2c:	31 c0                	xor    %eax,%eax
f0101b2e:	39 eb                	cmp    %ebp,%ebx
f0101b30:	77 de                	ja     f0101b10 <__udivdi3+0x40>
f0101b32:	b8 01 00 00 00       	mov    $0x1,%eax
f0101b37:	eb d7                	jmp    f0101b10 <__udivdi3+0x40>
f0101b39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101b40:	89 d9                	mov    %ebx,%ecx
f0101b42:	85 db                	test   %ebx,%ebx
f0101b44:	75 0b                	jne    f0101b51 <__udivdi3+0x81>
f0101b46:	b8 01 00 00 00       	mov    $0x1,%eax
f0101b4b:	31 d2                	xor    %edx,%edx
f0101b4d:	f7 f3                	div    %ebx
f0101b4f:	89 c1                	mov    %eax,%ecx
f0101b51:	31 d2                	xor    %edx,%edx
f0101b53:	89 f0                	mov    %esi,%eax
f0101b55:	f7 f1                	div    %ecx
f0101b57:	89 c6                	mov    %eax,%esi
f0101b59:	89 e8                	mov    %ebp,%eax
f0101b5b:	89 f7                	mov    %esi,%edi
f0101b5d:	f7 f1                	div    %ecx
f0101b5f:	89 fa                	mov    %edi,%edx
f0101b61:	83 c4 1c             	add    $0x1c,%esp
f0101b64:	5b                   	pop    %ebx
f0101b65:	5e                   	pop    %esi
f0101b66:	5f                   	pop    %edi
f0101b67:	5d                   	pop    %ebp
f0101b68:	c3                   	ret    
f0101b69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101b70:	89 f9                	mov    %edi,%ecx
f0101b72:	b8 20 00 00 00       	mov    $0x20,%eax
f0101b77:	29 f8                	sub    %edi,%eax
f0101b79:	d3 e2                	shl    %cl,%edx
f0101b7b:	89 54 24 08          	mov    %edx,0x8(%esp)
f0101b7f:	89 c1                	mov    %eax,%ecx
f0101b81:	89 da                	mov    %ebx,%edx
f0101b83:	d3 ea                	shr    %cl,%edx
f0101b85:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f0101b89:	09 d1                	or     %edx,%ecx
f0101b8b:	89 f2                	mov    %esi,%edx
f0101b8d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0101b91:	89 f9                	mov    %edi,%ecx
f0101b93:	d3 e3                	shl    %cl,%ebx
f0101b95:	89 c1                	mov    %eax,%ecx
f0101b97:	d3 ea                	shr    %cl,%edx
f0101b99:	89 f9                	mov    %edi,%ecx
f0101b9b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0101b9f:	89 eb                	mov    %ebp,%ebx
f0101ba1:	d3 e6                	shl    %cl,%esi
f0101ba3:	89 c1                	mov    %eax,%ecx
f0101ba5:	d3 eb                	shr    %cl,%ebx
f0101ba7:	09 de                	or     %ebx,%esi
f0101ba9:	89 f0                	mov    %esi,%eax
f0101bab:	f7 74 24 08          	divl   0x8(%esp)
f0101baf:	89 d6                	mov    %edx,%esi
f0101bb1:	89 c3                	mov    %eax,%ebx
f0101bb3:	f7 64 24 0c          	mull   0xc(%esp)
f0101bb7:	39 d6                	cmp    %edx,%esi
f0101bb9:	72 15                	jb     f0101bd0 <__udivdi3+0x100>
f0101bbb:	89 f9                	mov    %edi,%ecx
f0101bbd:	d3 e5                	shl    %cl,%ebp
f0101bbf:	39 c5                	cmp    %eax,%ebp
f0101bc1:	73 04                	jae    f0101bc7 <__udivdi3+0xf7>
f0101bc3:	39 d6                	cmp    %edx,%esi
f0101bc5:	74 09                	je     f0101bd0 <__udivdi3+0x100>
f0101bc7:	89 d8                	mov    %ebx,%eax
f0101bc9:	31 ff                	xor    %edi,%edi
f0101bcb:	e9 40 ff ff ff       	jmp    f0101b10 <__udivdi3+0x40>
f0101bd0:	8d 43 ff             	lea    -0x1(%ebx),%eax
f0101bd3:	31 ff                	xor    %edi,%edi
f0101bd5:	e9 36 ff ff ff       	jmp    f0101b10 <__udivdi3+0x40>
f0101bda:	66 90                	xchg   %ax,%ax
f0101bdc:	66 90                	xchg   %ax,%ax
f0101bde:	66 90                	xchg   %ax,%ax

f0101be0 <__umoddi3>:
f0101be0:	f3 0f 1e fb          	endbr32 
f0101be4:	55                   	push   %ebp
f0101be5:	57                   	push   %edi
f0101be6:	56                   	push   %esi
f0101be7:	53                   	push   %ebx
f0101be8:	83 ec 1c             	sub    $0x1c,%esp
f0101beb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
f0101bef:	8b 74 24 30          	mov    0x30(%esp),%esi
f0101bf3:	8b 5c 24 34          	mov    0x34(%esp),%ebx
f0101bf7:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0101bfb:	85 c0                	test   %eax,%eax
f0101bfd:	75 19                	jne    f0101c18 <__umoddi3+0x38>
f0101bff:	39 df                	cmp    %ebx,%edi
f0101c01:	76 5d                	jbe    f0101c60 <__umoddi3+0x80>
f0101c03:	89 f0                	mov    %esi,%eax
f0101c05:	89 da                	mov    %ebx,%edx
f0101c07:	f7 f7                	div    %edi
f0101c09:	89 d0                	mov    %edx,%eax
f0101c0b:	31 d2                	xor    %edx,%edx
f0101c0d:	83 c4 1c             	add    $0x1c,%esp
f0101c10:	5b                   	pop    %ebx
f0101c11:	5e                   	pop    %esi
f0101c12:	5f                   	pop    %edi
f0101c13:	5d                   	pop    %ebp
f0101c14:	c3                   	ret    
f0101c15:	8d 76 00             	lea    0x0(%esi),%esi
f0101c18:	89 f2                	mov    %esi,%edx
f0101c1a:	39 d8                	cmp    %ebx,%eax
f0101c1c:	76 12                	jbe    f0101c30 <__umoddi3+0x50>
f0101c1e:	89 f0                	mov    %esi,%eax
f0101c20:	89 da                	mov    %ebx,%edx
f0101c22:	83 c4 1c             	add    $0x1c,%esp
f0101c25:	5b                   	pop    %ebx
f0101c26:	5e                   	pop    %esi
f0101c27:	5f                   	pop    %edi
f0101c28:	5d                   	pop    %ebp
f0101c29:	c3                   	ret    
f0101c2a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0101c30:	0f bd e8             	bsr    %eax,%ebp
f0101c33:	83 f5 1f             	xor    $0x1f,%ebp
f0101c36:	75 50                	jne    f0101c88 <__umoddi3+0xa8>
f0101c38:	39 d8                	cmp    %ebx,%eax
f0101c3a:	0f 82 e0 00 00 00    	jb     f0101d20 <__umoddi3+0x140>
f0101c40:	89 d9                	mov    %ebx,%ecx
f0101c42:	39 f7                	cmp    %esi,%edi
f0101c44:	0f 86 d6 00 00 00    	jbe    f0101d20 <__umoddi3+0x140>
f0101c4a:	89 d0                	mov    %edx,%eax
f0101c4c:	89 ca                	mov    %ecx,%edx
f0101c4e:	83 c4 1c             	add    $0x1c,%esp
f0101c51:	5b                   	pop    %ebx
f0101c52:	5e                   	pop    %esi
f0101c53:	5f                   	pop    %edi
f0101c54:	5d                   	pop    %ebp
f0101c55:	c3                   	ret    
f0101c56:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101c5d:	8d 76 00             	lea    0x0(%esi),%esi
f0101c60:	89 fd                	mov    %edi,%ebp
f0101c62:	85 ff                	test   %edi,%edi
f0101c64:	75 0b                	jne    f0101c71 <__umoddi3+0x91>
f0101c66:	b8 01 00 00 00       	mov    $0x1,%eax
f0101c6b:	31 d2                	xor    %edx,%edx
f0101c6d:	f7 f7                	div    %edi
f0101c6f:	89 c5                	mov    %eax,%ebp
f0101c71:	89 d8                	mov    %ebx,%eax
f0101c73:	31 d2                	xor    %edx,%edx
f0101c75:	f7 f5                	div    %ebp
f0101c77:	89 f0                	mov    %esi,%eax
f0101c79:	f7 f5                	div    %ebp
f0101c7b:	89 d0                	mov    %edx,%eax
f0101c7d:	31 d2                	xor    %edx,%edx
f0101c7f:	eb 8c                	jmp    f0101c0d <__umoddi3+0x2d>
f0101c81:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101c88:	89 e9                	mov    %ebp,%ecx
f0101c8a:	ba 20 00 00 00       	mov    $0x20,%edx
f0101c8f:	29 ea                	sub    %ebp,%edx
f0101c91:	d3 e0                	shl    %cl,%eax
f0101c93:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101c97:	89 d1                	mov    %edx,%ecx
f0101c99:	89 f8                	mov    %edi,%eax
f0101c9b:	d3 e8                	shr    %cl,%eax
f0101c9d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f0101ca1:	89 54 24 04          	mov    %edx,0x4(%esp)
f0101ca5:	8b 54 24 04          	mov    0x4(%esp),%edx
f0101ca9:	09 c1                	or     %eax,%ecx
f0101cab:	89 d8                	mov    %ebx,%eax
f0101cad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0101cb1:	89 e9                	mov    %ebp,%ecx
f0101cb3:	d3 e7                	shl    %cl,%edi
f0101cb5:	89 d1                	mov    %edx,%ecx
f0101cb7:	d3 e8                	shr    %cl,%eax
f0101cb9:	89 e9                	mov    %ebp,%ecx
f0101cbb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0101cbf:	d3 e3                	shl    %cl,%ebx
f0101cc1:	89 c7                	mov    %eax,%edi
f0101cc3:	89 d1                	mov    %edx,%ecx
f0101cc5:	89 f0                	mov    %esi,%eax
f0101cc7:	d3 e8                	shr    %cl,%eax
f0101cc9:	89 e9                	mov    %ebp,%ecx
f0101ccb:	89 fa                	mov    %edi,%edx
f0101ccd:	d3 e6                	shl    %cl,%esi
f0101ccf:	09 d8                	or     %ebx,%eax
f0101cd1:	f7 74 24 08          	divl   0x8(%esp)
f0101cd5:	89 d1                	mov    %edx,%ecx
f0101cd7:	89 f3                	mov    %esi,%ebx
f0101cd9:	f7 64 24 0c          	mull   0xc(%esp)
f0101cdd:	89 c6                	mov    %eax,%esi
f0101cdf:	89 d7                	mov    %edx,%edi
f0101ce1:	39 d1                	cmp    %edx,%ecx
f0101ce3:	72 06                	jb     f0101ceb <__umoddi3+0x10b>
f0101ce5:	75 10                	jne    f0101cf7 <__umoddi3+0x117>
f0101ce7:	39 c3                	cmp    %eax,%ebx
f0101ce9:	73 0c                	jae    f0101cf7 <__umoddi3+0x117>
f0101ceb:	2b 44 24 0c          	sub    0xc(%esp),%eax
f0101cef:	1b 54 24 08          	sbb    0x8(%esp),%edx
f0101cf3:	89 d7                	mov    %edx,%edi
f0101cf5:	89 c6                	mov    %eax,%esi
f0101cf7:	89 ca                	mov    %ecx,%edx
f0101cf9:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0101cfe:	29 f3                	sub    %esi,%ebx
f0101d00:	19 fa                	sbb    %edi,%edx
f0101d02:	89 d0                	mov    %edx,%eax
f0101d04:	d3 e0                	shl    %cl,%eax
f0101d06:	89 e9                	mov    %ebp,%ecx
f0101d08:	d3 eb                	shr    %cl,%ebx
f0101d0a:	d3 ea                	shr    %cl,%edx
f0101d0c:	09 d8                	or     %ebx,%eax
f0101d0e:	83 c4 1c             	add    $0x1c,%esp
f0101d11:	5b                   	pop    %ebx
f0101d12:	5e                   	pop    %esi
f0101d13:	5f                   	pop    %edi
f0101d14:	5d                   	pop    %ebp
f0101d15:	c3                   	ret    
f0101d16:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101d1d:	8d 76 00             	lea    0x0(%esi),%esi
f0101d20:	29 fe                	sub    %edi,%esi
f0101d22:	19 c3                	sbb    %eax,%ebx
f0101d24:	89 f2                	mov    %esi,%edx
f0101d26:	89 d9                	mov    %ebx,%ecx
f0101d28:	e9 1d ff ff ff       	jmp    f0101c4a <__umoddi3+0x6a>
