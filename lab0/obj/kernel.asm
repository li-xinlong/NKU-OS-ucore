
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080200000 <kern_entry>:
#include <memlayout.h>

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    la sp, bootstacktop
    80200000:	00003117          	auipc	sp,0x3
    80200004:	00010113          	mv	sp,sp

    tail kern_init
    80200008:	a009                	j	8020000a <kern_init>

000000008020000a <kern_init>:
#include <sbi.h>
int kern_init(void) __attribute__((noreturn));

int kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
    8020000a:	00003517          	auipc	a0,0x3
    8020000e:	ffe50513          	addi	a0,a0,-2 # 80203008 <edata>
    80200012:	00003617          	auipc	a2,0x3
    80200016:	ff660613          	addi	a2,a2,-10 # 80203008 <edata>
int kern_init(void) {
    8020001a:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
    8020001c:	4581                	li	a1,0
    8020001e:	8e09                	sub	a2,a2,a0
int kern_init(void) {
    80200020:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
    80200022:	494000ef          	jal	ra,802004b6 <memset>

    const char *message = "(THU.CST) os is loading ...\n";
    cprintf("%s\n\n", message);
    80200026:	00000597          	auipc	a1,0x0
    8020002a:	4a258593          	addi	a1,a1,1186 # 802004c8 <memset+0x12>
    8020002e:	00000517          	auipc	a0,0x0
    80200032:	4ba50513          	addi	a0,a0,1210 # 802004e8 <memset+0x32>
    80200036:	020000ef          	jal	ra,80200056 <cprintf>
   while (1)
    8020003a:	a001                	j	8020003a <kern_init+0x30>

000000008020003c <cputch>:

/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void cputch(int c, int *cnt) {
    8020003c:	1141                	addi	sp,sp,-16
    8020003e:	e022                	sd	s0,0(sp)
    80200040:	e406                	sd	ra,8(sp)
    80200042:	842e                	mv	s0,a1
    cons_putc(c);
    80200044:	048000ef          	jal	ra,8020008c <cons_putc>
    (*cnt)++;
    80200048:	401c                	lw	a5,0(s0)
}
    8020004a:	60a2                	ld	ra,8(sp)
    (*cnt)++;
    8020004c:	2785                	addiw	a5,a5,1
    8020004e:	c01c                	sw	a5,0(s0)
}
    80200050:	6402                	ld	s0,0(sp)
    80200052:	0141                	addi	sp,sp,16
    80200054:	8082                	ret

0000000080200056 <cprintf>:
 * cprintf - formats a string and writes it to stdout
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int cprintf(const char *fmt, ...) {
    80200056:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
    80200058:	02810313          	addi	t1,sp,40 # 80203028 <edata+0x20>
int cprintf(const char *fmt, ...) {
    8020005c:	8e2a                	mv	t3,a0
    8020005e:	f42e                	sd	a1,40(sp)
    80200060:	f832                	sd	a2,48(sp)
    80200062:	fc36                	sd	a3,56(sp)
    vprintfmt((void *)cputch, &cnt, fmt, ap);
    80200064:	00000517          	auipc	a0,0x0
    80200068:	fd850513          	addi	a0,a0,-40 # 8020003c <cputch>
    8020006c:	004c                	addi	a1,sp,4
    8020006e:	869a                	mv	a3,t1
    80200070:	8672                	mv	a2,t3
int cprintf(const char *fmt, ...) {
    80200072:	ec06                	sd	ra,24(sp)
    80200074:	e0ba                	sd	a4,64(sp)
    80200076:	e4be                	sd	a5,72(sp)
    80200078:	e8c2                	sd	a6,80(sp)
    8020007a:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
    8020007c:	e41a                	sd	t1,8(sp)
    int cnt = 0;
    8020007e:	c202                	sw	zero,4(sp)
    vprintfmt((void *)cputch, &cnt, fmt, ap);
    80200080:	07e000ef          	jal	ra,802000fe <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
    80200084:	60e2                	ld	ra,24(sp)
    80200086:	4512                	lw	a0,4(sp)
    80200088:	6125                	addi	sp,sp,96
    8020008a:	8082                	ret

000000008020008c <cons_putc>:

/* cons_init - initializes the console devices */
void cons_init(void) {}

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) { sbi_console_putchar((unsigned char)c); }
    8020008c:	0ff57513          	zext.b	a0,a0
    80200090:	aec5                	j	80200480 <sbi_console_putchar>

0000000080200092 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
    80200092:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
    80200096:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
    80200098:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
    8020009c:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
    8020009e:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
    802000a2:	f022                	sd	s0,32(sp)
    802000a4:	ec26                	sd	s1,24(sp)
    802000a6:	e84a                	sd	s2,16(sp)
    802000a8:	f406                	sd	ra,40(sp)
    802000aa:	e44e                	sd	s3,8(sp)
    802000ac:	84aa                	mv	s1,a0
    802000ae:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
    802000b0:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
    802000b4:	2a01                	sext.w	s4,s4
    if (num >= base) {
    802000b6:	03067e63          	bgeu	a2,a6,802000f2 <printnum+0x60>
    802000ba:	89be                	mv	s3,a5
        while (-- width > 0)
    802000bc:	00805763          	blez	s0,802000ca <printnum+0x38>
    802000c0:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
    802000c2:	85ca                	mv	a1,s2
    802000c4:	854e                	mv	a0,s3
    802000c6:	9482                	jalr	s1
        while (-- width > 0)
    802000c8:	fc65                	bnez	s0,802000c0 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
    802000ca:	1a02                	slli	s4,s4,0x20
    802000cc:	00000797          	auipc	a5,0x0
    802000d0:	42478793          	addi	a5,a5,1060 # 802004f0 <memset+0x3a>
    802000d4:	020a5a13          	srli	s4,s4,0x20
    802000d8:	9a3e                	add	s4,s4,a5
}
    802000da:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
    802000dc:	000a4503          	lbu	a0,0(s4)
}
    802000e0:	70a2                	ld	ra,40(sp)
    802000e2:	69a2                	ld	s3,8(sp)
    802000e4:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
    802000e6:	85ca                	mv	a1,s2
    802000e8:	87a6                	mv	a5,s1
}
    802000ea:	6942                	ld	s2,16(sp)
    802000ec:	64e2                	ld	s1,24(sp)
    802000ee:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
    802000f0:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
    802000f2:	03065633          	divu	a2,a2,a6
    802000f6:	8722                	mv	a4,s0
    802000f8:	f9bff0ef          	jal	ra,80200092 <printnum>
    802000fc:	b7f9                	j	802000ca <printnum+0x38>

00000000802000fe <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
    802000fe:	7119                	addi	sp,sp,-128
    80200100:	f4a6                	sd	s1,104(sp)
    80200102:	f0ca                	sd	s2,96(sp)
    80200104:	ecce                	sd	s3,88(sp)
    80200106:	e8d2                	sd	s4,80(sp)
    80200108:	e4d6                	sd	s5,72(sp)
    8020010a:	e0da                	sd	s6,64(sp)
    8020010c:	fc5e                	sd	s7,56(sp)
    8020010e:	f06a                	sd	s10,32(sp)
    80200110:	fc86                	sd	ra,120(sp)
    80200112:	f8a2                	sd	s0,112(sp)
    80200114:	f862                	sd	s8,48(sp)
    80200116:	f466                	sd	s9,40(sp)
    80200118:	ec6e                	sd	s11,24(sp)
    8020011a:	892a                	mv	s2,a0
    8020011c:	84ae                	mv	s1,a1
    8020011e:	8d32                	mv	s10,a2
    80200120:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    80200122:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
    80200126:	5b7d                	li	s6,-1
    80200128:	00000a97          	auipc	s5,0x0
    8020012c:	3fca8a93          	addi	s5,s5,1020 # 80200524 <memset+0x6e>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
    80200130:	00000b97          	auipc	s7,0x0
    80200134:	5d0b8b93          	addi	s7,s7,1488 # 80200700 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    80200138:	000d4503          	lbu	a0,0(s10)
    8020013c:	001d0413          	addi	s0,s10,1
    80200140:	01350a63          	beq	a0,s3,80200154 <vprintfmt+0x56>
            if (ch == '\0') {
    80200144:	c121                	beqz	a0,80200184 <vprintfmt+0x86>
            putch(ch, putdat);
    80200146:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    80200148:	0405                	addi	s0,s0,1
            putch(ch, putdat);
    8020014a:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    8020014c:	fff44503          	lbu	a0,-1(s0)
    80200150:	ff351ae3          	bne	a0,s3,80200144 <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
    80200154:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
    80200158:	02000793          	li	a5,32
        lflag = altflag = 0;
    8020015c:	4c81                	li	s9,0
    8020015e:	4881                	li	a7,0
        width = precision = -1;
    80200160:	5c7d                	li	s8,-1
    80200162:	5dfd                	li	s11,-1
    80200164:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
    80200168:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
    8020016a:	fdd6059b          	addiw	a1,a2,-35
    8020016e:	0ff5f593          	zext.b	a1,a1
    80200172:	00140d13          	addi	s10,s0,1
    80200176:	04b56263          	bltu	a0,a1,802001ba <vprintfmt+0xbc>
    8020017a:	058a                	slli	a1,a1,0x2
    8020017c:	95d6                	add	a1,a1,s5
    8020017e:	4194                	lw	a3,0(a1)
    80200180:	96d6                	add	a3,a3,s5
    80200182:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
    80200184:	70e6                	ld	ra,120(sp)
    80200186:	7446                	ld	s0,112(sp)
    80200188:	74a6                	ld	s1,104(sp)
    8020018a:	7906                	ld	s2,96(sp)
    8020018c:	69e6                	ld	s3,88(sp)
    8020018e:	6a46                	ld	s4,80(sp)
    80200190:	6aa6                	ld	s5,72(sp)
    80200192:	6b06                	ld	s6,64(sp)
    80200194:	7be2                	ld	s7,56(sp)
    80200196:	7c42                	ld	s8,48(sp)
    80200198:	7ca2                	ld	s9,40(sp)
    8020019a:	7d02                	ld	s10,32(sp)
    8020019c:	6de2                	ld	s11,24(sp)
    8020019e:	6109                	addi	sp,sp,128
    802001a0:	8082                	ret
            padc = '0';
    802001a2:	87b2                	mv	a5,a2
            goto reswitch;
    802001a4:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
    802001a8:	846a                	mv	s0,s10
    802001aa:	00140d13          	addi	s10,s0,1
    802001ae:	fdd6059b          	addiw	a1,a2,-35
    802001b2:	0ff5f593          	zext.b	a1,a1
    802001b6:	fcb572e3          	bgeu	a0,a1,8020017a <vprintfmt+0x7c>
            putch('%', putdat);
    802001ba:	85a6                	mv	a1,s1
    802001bc:	02500513          	li	a0,37
    802001c0:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
    802001c2:	fff44783          	lbu	a5,-1(s0)
    802001c6:	8d22                	mv	s10,s0
    802001c8:	f73788e3          	beq	a5,s3,80200138 <vprintfmt+0x3a>
    802001cc:	ffed4783          	lbu	a5,-2(s10)
    802001d0:	1d7d                	addi	s10,s10,-1
    802001d2:	ff379de3          	bne	a5,s3,802001cc <vprintfmt+0xce>
    802001d6:	b78d                	j	80200138 <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
    802001d8:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
    802001dc:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
    802001e0:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
    802001e2:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
    802001e6:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
    802001ea:	02d86463          	bltu	a6,a3,80200212 <vprintfmt+0x114>
                ch = *fmt;
    802001ee:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
    802001f2:	002c169b          	slliw	a3,s8,0x2
    802001f6:	0186873b          	addw	a4,a3,s8
    802001fa:	0017171b          	slliw	a4,a4,0x1
    802001fe:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
    80200200:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
    80200204:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
    80200206:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
    8020020a:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
    8020020e:	fed870e3          	bgeu	a6,a3,802001ee <vprintfmt+0xf0>
            if (width < 0)
    80200212:	f40ddce3          	bgez	s11,8020016a <vprintfmt+0x6c>
                width = precision, precision = -1;
    80200216:	8de2                	mv	s11,s8
    80200218:	5c7d                	li	s8,-1
    8020021a:	bf81                	j	8020016a <vprintfmt+0x6c>
            if (width < 0)
    8020021c:	fffdc693          	not	a3,s11
    80200220:	96fd                	srai	a3,a3,0x3f
    80200222:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
    80200226:	00144603          	lbu	a2,1(s0)
    8020022a:	2d81                	sext.w	s11,s11
    8020022c:	846a                	mv	s0,s10
            goto reswitch;
    8020022e:	bf35                	j	8020016a <vprintfmt+0x6c>
            precision = va_arg(ap, int);
    80200230:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
    80200234:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
    80200238:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
    8020023a:	846a                	mv	s0,s10
            goto process_precision;
    8020023c:	bfd9                	j	80200212 <vprintfmt+0x114>
    if (lflag >= 2) {
    8020023e:	4705                	li	a4,1
            precision = va_arg(ap, int);
    80200240:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
    80200244:	01174463          	blt	a4,a7,8020024c <vprintfmt+0x14e>
    else if (lflag) {
    80200248:	1a088e63          	beqz	a7,80200404 <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
    8020024c:	000a3603          	ld	a2,0(s4)
    80200250:	46c1                	li	a3,16
    80200252:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
    80200254:	2781                	sext.w	a5,a5
    80200256:	876e                	mv	a4,s11
    80200258:	85a6                	mv	a1,s1
    8020025a:	854a                	mv	a0,s2
    8020025c:	e37ff0ef          	jal	ra,80200092 <printnum>
            break;
    80200260:	bde1                	j	80200138 <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
    80200262:	000a2503          	lw	a0,0(s4)
    80200266:	85a6                	mv	a1,s1
    80200268:	0a21                	addi	s4,s4,8
    8020026a:	9902                	jalr	s2
            break;
    8020026c:	b5f1                	j	80200138 <vprintfmt+0x3a>
    if (lflag >= 2) {
    8020026e:	4705                	li	a4,1
            precision = va_arg(ap, int);
    80200270:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
    80200274:	01174463          	blt	a4,a7,8020027c <vprintfmt+0x17e>
    else if (lflag) {
    80200278:	18088163          	beqz	a7,802003fa <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
    8020027c:	000a3603          	ld	a2,0(s4)
    80200280:	46a9                	li	a3,10
    80200282:	8a2e                	mv	s4,a1
    80200284:	bfc1                	j	80200254 <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
    80200286:	00144603          	lbu	a2,1(s0)
            altflag = 1;
    8020028a:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
    8020028c:	846a                	mv	s0,s10
            goto reswitch;
    8020028e:	bdf1                	j	8020016a <vprintfmt+0x6c>
            putch(ch, putdat);
    80200290:	85a6                	mv	a1,s1
    80200292:	02500513          	li	a0,37
    80200296:	9902                	jalr	s2
            break;
    80200298:	b545                	j	80200138 <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
    8020029a:	00144603          	lbu	a2,1(s0)
            lflag ++;
    8020029e:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
    802002a0:	846a                	mv	s0,s10
            goto reswitch;
    802002a2:	b5e1                	j	8020016a <vprintfmt+0x6c>
    if (lflag >= 2) {
    802002a4:	4705                	li	a4,1
            precision = va_arg(ap, int);
    802002a6:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
    802002aa:	01174463          	blt	a4,a7,802002b2 <vprintfmt+0x1b4>
    else if (lflag) {
    802002ae:	14088163          	beqz	a7,802003f0 <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
    802002b2:	000a3603          	ld	a2,0(s4)
    802002b6:	46a1                	li	a3,8
    802002b8:	8a2e                	mv	s4,a1
    802002ba:	bf69                	j	80200254 <vprintfmt+0x156>
            putch('0', putdat);
    802002bc:	03000513          	li	a0,48
    802002c0:	85a6                	mv	a1,s1
    802002c2:	e03e                	sd	a5,0(sp)
    802002c4:	9902                	jalr	s2
            putch('x', putdat);
    802002c6:	85a6                	mv	a1,s1
    802002c8:	07800513          	li	a0,120
    802002cc:	9902                	jalr	s2
            num = (unsigned long long)va_arg(ap, void *);
    802002ce:	0a21                	addi	s4,s4,8
            goto number;
    802002d0:	6782                	ld	a5,0(sp)
    802002d2:	46c1                	li	a3,16
            num = (unsigned long long)va_arg(ap, void *);
    802002d4:	ff8a3603          	ld	a2,-8(s4)
            goto number;
    802002d8:	bfb5                	j	80200254 <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
    802002da:	000a3403          	ld	s0,0(s4)
    802002de:	008a0713          	addi	a4,s4,8
    802002e2:	e03a                	sd	a4,0(sp)
    802002e4:	14040263          	beqz	s0,80200428 <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
    802002e8:	0fb05763          	blez	s11,802003d6 <vprintfmt+0x2d8>
    802002ec:	02d00693          	li	a3,45
    802002f0:	0cd79163          	bne	a5,a3,802003b2 <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    802002f4:	00044783          	lbu	a5,0(s0)
    802002f8:	0007851b          	sext.w	a0,a5
    802002fc:	cf85                	beqz	a5,80200334 <vprintfmt+0x236>
    802002fe:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
    80200302:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    80200306:	000c4563          	bltz	s8,80200310 <vprintfmt+0x212>
    8020030a:	3c7d                	addiw	s8,s8,-1
    8020030c:	036c0263          	beq	s8,s6,80200330 <vprintfmt+0x232>
                    putch('?', putdat);
    80200310:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
    80200312:	0e0c8e63          	beqz	s9,8020040e <vprintfmt+0x310>
    80200316:	3781                	addiw	a5,a5,-32
    80200318:	0ef47b63          	bgeu	s0,a5,8020040e <vprintfmt+0x310>
                    putch('?', putdat);
    8020031c:	03f00513          	li	a0,63
    80200320:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    80200322:	000a4783          	lbu	a5,0(s4)
    80200326:	3dfd                	addiw	s11,s11,-1
    80200328:	0a05                	addi	s4,s4,1
    8020032a:	0007851b          	sext.w	a0,a5
    8020032e:	ffe1                	bnez	a5,80200306 <vprintfmt+0x208>
            for (; width > 0; width --) {
    80200330:	01b05963          	blez	s11,80200342 <vprintfmt+0x244>
    80200334:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
    80200336:	85a6                	mv	a1,s1
    80200338:	02000513          	li	a0,32
    8020033c:	9902                	jalr	s2
            for (; width > 0; width --) {
    8020033e:	fe0d9be3          	bnez	s11,80200334 <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
    80200342:	6a02                	ld	s4,0(sp)
    80200344:	bbd5                	j	80200138 <vprintfmt+0x3a>
    if (lflag >= 2) {
    80200346:	4705                	li	a4,1
            precision = va_arg(ap, int);
    80200348:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
    8020034c:	01174463          	blt	a4,a7,80200354 <vprintfmt+0x256>
    else if (lflag) {
    80200350:	08088d63          	beqz	a7,802003ea <vprintfmt+0x2ec>
        return va_arg(*ap, long);
    80200354:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
    80200358:	0a044d63          	bltz	s0,80200412 <vprintfmt+0x314>
            num = getint(&ap, lflag);
    8020035c:	8622                	mv	a2,s0
    8020035e:	8a66                	mv	s4,s9
    80200360:	46a9                	li	a3,10
    80200362:	bdcd                	j	80200254 <vprintfmt+0x156>
            err = va_arg(ap, int);
    80200364:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
    80200368:	4719                	li	a4,6
            err = va_arg(ap, int);
    8020036a:	0a21                	addi	s4,s4,8
            if (err < 0) {
    8020036c:	41f7d69b          	sraiw	a3,a5,0x1f
    80200370:	8fb5                	xor	a5,a5,a3
    80200372:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
    80200376:	02d74163          	blt	a4,a3,80200398 <vprintfmt+0x29a>
    8020037a:	00369793          	slli	a5,a3,0x3
    8020037e:	97de                	add	a5,a5,s7
    80200380:	639c                	ld	a5,0(a5)
    80200382:	cb99                	beqz	a5,80200398 <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
    80200384:	86be                	mv	a3,a5
    80200386:	00000617          	auipc	a2,0x0
    8020038a:	19a60613          	addi	a2,a2,410 # 80200520 <memset+0x6a>
    8020038e:	85a6                	mv	a1,s1
    80200390:	854a                	mv	a0,s2
    80200392:	0ce000ef          	jal	ra,80200460 <printfmt>
    80200396:	b34d                	j	80200138 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
    80200398:	00000617          	auipc	a2,0x0
    8020039c:	17860613          	addi	a2,a2,376 # 80200510 <memset+0x5a>
    802003a0:	85a6                	mv	a1,s1
    802003a2:	854a                	mv	a0,s2
    802003a4:	0bc000ef          	jal	ra,80200460 <printfmt>
    802003a8:	bb41                	j	80200138 <vprintfmt+0x3a>
                p = "(null)";
    802003aa:	00000417          	auipc	s0,0x0
    802003ae:	15e40413          	addi	s0,s0,350 # 80200508 <memset+0x52>
                for (width -= strnlen(p, precision); width > 0; width --) {
    802003b2:	85e2                	mv	a1,s8
    802003b4:	8522                	mv	a0,s0
    802003b6:	e43e                	sd	a5,8(sp)
    802003b8:	0e2000ef          	jal	ra,8020049a <strnlen>
    802003bc:	40ad8dbb          	subw	s11,s11,a0
    802003c0:	01b05b63          	blez	s11,802003d6 <vprintfmt+0x2d8>
                    putch(padc, putdat);
    802003c4:	67a2                	ld	a5,8(sp)
    802003c6:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
    802003ca:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
    802003cc:	85a6                	mv	a1,s1
    802003ce:	8552                	mv	a0,s4
    802003d0:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
    802003d2:	fe0d9ce3          	bnez	s11,802003ca <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    802003d6:	00044783          	lbu	a5,0(s0)
    802003da:	00140a13          	addi	s4,s0,1
    802003de:	0007851b          	sext.w	a0,a5
    802003e2:	d3a5                	beqz	a5,80200342 <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
    802003e4:	05e00413          	li	s0,94
    802003e8:	bf39                	j	80200306 <vprintfmt+0x208>
        return va_arg(*ap, int);
    802003ea:	000a2403          	lw	s0,0(s4)
    802003ee:	b7ad                	j	80200358 <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
    802003f0:	000a6603          	lwu	a2,0(s4)
    802003f4:	46a1                	li	a3,8
    802003f6:	8a2e                	mv	s4,a1
    802003f8:	bdb1                	j	80200254 <vprintfmt+0x156>
    802003fa:	000a6603          	lwu	a2,0(s4)
    802003fe:	46a9                	li	a3,10
    80200400:	8a2e                	mv	s4,a1
    80200402:	bd89                	j	80200254 <vprintfmt+0x156>
    80200404:	000a6603          	lwu	a2,0(s4)
    80200408:	46c1                	li	a3,16
    8020040a:	8a2e                	mv	s4,a1
    8020040c:	b5a1                	j	80200254 <vprintfmt+0x156>
                    putch(ch, putdat);
    8020040e:	9902                	jalr	s2
    80200410:	bf09                	j	80200322 <vprintfmt+0x224>
                putch('-', putdat);
    80200412:	85a6                	mv	a1,s1
    80200414:	02d00513          	li	a0,45
    80200418:	e03e                	sd	a5,0(sp)
    8020041a:	9902                	jalr	s2
                num = -(long long)num;
    8020041c:	6782                	ld	a5,0(sp)
    8020041e:	8a66                	mv	s4,s9
    80200420:	40800633          	neg	a2,s0
    80200424:	46a9                	li	a3,10
    80200426:	b53d                	j	80200254 <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
    80200428:	03b05163          	blez	s11,8020044a <vprintfmt+0x34c>
    8020042c:	02d00693          	li	a3,45
    80200430:	f6d79de3          	bne	a5,a3,802003aa <vprintfmt+0x2ac>
                p = "(null)";
    80200434:	00000417          	auipc	s0,0x0
    80200438:	0d440413          	addi	s0,s0,212 # 80200508 <memset+0x52>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    8020043c:	02800793          	li	a5,40
    80200440:	02800513          	li	a0,40
    80200444:	00140a13          	addi	s4,s0,1
    80200448:	bd6d                	j	80200302 <vprintfmt+0x204>
    8020044a:	00000a17          	auipc	s4,0x0
    8020044e:	0bfa0a13          	addi	s4,s4,191 # 80200509 <memset+0x53>
    80200452:	02800513          	li	a0,40
    80200456:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
    8020045a:	05e00413          	li	s0,94
    8020045e:	b565                	j	80200306 <vprintfmt+0x208>

0000000080200460 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
    80200460:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
    80200462:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
    80200466:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
    80200468:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
    8020046a:	ec06                	sd	ra,24(sp)
    8020046c:	f83a                	sd	a4,48(sp)
    8020046e:	fc3e                	sd	a5,56(sp)
    80200470:	e0c2                	sd	a6,64(sp)
    80200472:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
    80200474:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
    80200476:	c89ff0ef          	jal	ra,802000fe <vprintfmt>
}
    8020047a:	60e2                	ld	ra,24(sp)
    8020047c:	6161                	addi	sp,sp,80
    8020047e:	8082                	ret

0000000080200480 <sbi_console_putchar>:
uint64_t SBI_REMOTE_SFENCE_VMA_ASID = 7;
uint64_t SBI_SHUTDOWN = 8;

uint64_t sbi_call(uint64_t sbi_type, uint64_t arg0, uint64_t arg1, uint64_t arg2) {
    uint64_t ret_val;
    __asm__ volatile (
    80200480:	4781                	li	a5,0
    80200482:	00003717          	auipc	a4,0x3
    80200486:	b7e73703          	ld	a4,-1154(a4) # 80203000 <SBI_CONSOLE_PUTCHAR>
    8020048a:	88ba                	mv	a7,a4
    8020048c:	852a                	mv	a0,a0
    8020048e:	85be                	mv	a1,a5
    80200490:	863e                	mv	a2,a5
    80200492:	00000073          	ecall
    80200496:	87aa                	mv	a5,a0
    return ret_val;
}

void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
}
    80200498:	8082                	ret

000000008020049a <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    8020049a:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
    8020049c:	e589                	bnez	a1,802004a6 <strnlen+0xc>
    8020049e:	a811                	j	802004b2 <strnlen+0x18>
        cnt ++;
    802004a0:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
    802004a2:	00f58863          	beq	a1,a5,802004b2 <strnlen+0x18>
    802004a6:	00f50733          	add	a4,a0,a5
    802004aa:	00074703          	lbu	a4,0(a4)
    802004ae:	fb6d                	bnez	a4,802004a0 <strnlen+0x6>
    802004b0:	85be                	mv	a1,a5
    }
    return cnt;
}
    802004b2:	852e                	mv	a0,a1
    802004b4:	8082                	ret

00000000802004b6 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
    802004b6:	ca01                	beqz	a2,802004c6 <memset+0x10>
    802004b8:	962a                	add	a2,a2,a0
    char *p = s;
    802004ba:	87aa                	mv	a5,a0
        *p ++ = c;
    802004bc:	0785                	addi	a5,a5,1
    802004be:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
    802004c2:	fec79de3          	bne	a5,a2,802004bc <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
    802004c6:	8082                	ret
