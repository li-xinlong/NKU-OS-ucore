
obj/__user_softint.out:     file format elf64-littleriscv


Disassembly of section .text:

0000000000800020 <_start>:
.text
.globl _start
_start:
    # call user-program function
    call umain
  800020:	0b2000ef          	jal	ra,8000d2 <umain>
1:  j 1b
  800024:	a001                	j	800024 <_start+0x4>

0000000000800026 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
  800026:	1141                	addi	sp,sp,-16
  800028:	e022                	sd	s0,0(sp)
  80002a:	e406                	sd	ra,8(sp)
  80002c:	842e                	mv	s0,a1
    sys_putc(c);
  80002e:	088000ef          	jal	ra,8000b6 <sys_putc>
    (*cnt) ++;
  800032:	401c                	lw	a5,0(s0)
}
  800034:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
  800036:	2785                	addiw	a5,a5,1
  800038:	c01c                	sw	a5,0(s0)
}
  80003a:	6402                	ld	s0,0(sp)
  80003c:	0141                	addi	sp,sp,16
  80003e:	8082                	ret

0000000000800040 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
  800040:	711d                	addi	sp,sp,-96
    va_list ap;

    va_start(ap, fmt);
  800042:	02810313          	addi	t1,sp,40
cprintf(const char *fmt, ...) {
  800046:	8e2a                	mv	t3,a0
  800048:	f42e                	sd	a1,40(sp)
  80004a:	f832                	sd	a2,48(sp)
  80004c:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  80004e:	00000517          	auipc	a0,0x0
  800052:	fd850513          	addi	a0,a0,-40 # 800026 <cputch>
  800056:	004c                	addi	a1,sp,4
  800058:	869a                	mv	a3,t1
  80005a:	8672                	mv	a2,t3
cprintf(const char *fmt, ...) {
  80005c:	ec06                	sd	ra,24(sp)
  80005e:	e0ba                	sd	a4,64(sp)
  800060:	e4be                	sd	a5,72(sp)
  800062:	e8c2                	sd	a6,80(sp)
  800064:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
  800066:	e41a                	sd	t1,8(sp)
    int cnt = 0;
  800068:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  80006a:	0e0000ef          	jal	ra,80014a <vprintfmt>
    int cnt = vcprintf(fmt, ap);
    va_end(ap);

    return cnt;
}
  80006e:	60e2                	ld	ra,24(sp)
  800070:	4512                	lw	a0,4(sp)
  800072:	6125                	addi	sp,sp,96
  800074:	8082                	ret

0000000000800076 <syscall>:
#include <syscall.h>

#define MAX_ARGS            5

static inline int
syscall(int64_t num, ...) {
  800076:	7175                	addi	sp,sp,-144
  800078:	f8ba                	sd	a4,112(sp)
    va_list ap;
    va_start(ap, num);
    uint64_t a[MAX_ARGS];
    int i, ret;
    for (i = 0; i < MAX_ARGS; i ++) {
        a[i] = va_arg(ap, uint64_t);
  80007a:	e0ba                	sd	a4,64(sp)
  80007c:	0118                	addi	a4,sp,128
syscall(int64_t num, ...) {
  80007e:	e42a                	sd	a0,8(sp)
  800080:	ecae                	sd	a1,88(sp)
  800082:	f0b2                	sd	a2,96(sp)
  800084:	f4b6                	sd	a3,104(sp)
  800086:	fcbe                	sd	a5,120(sp)
  800088:	e142                	sd	a6,128(sp)
  80008a:	e546                	sd	a7,136(sp)
        a[i] = va_arg(ap, uint64_t);
  80008c:	f42e                	sd	a1,40(sp)
  80008e:	f832                	sd	a2,48(sp)
  800090:	fc36                	sd	a3,56(sp)
  800092:	f03a                	sd	a4,32(sp)
  800094:	e4be                	sd	a5,72(sp)
    }
    va_end(ap);

    asm volatile (
  800096:	6522                	ld	a0,8(sp)
  800098:	75a2                	ld	a1,40(sp)
  80009a:	7642                	ld	a2,48(sp)
  80009c:	76e2                	ld	a3,56(sp)
  80009e:	6706                	ld	a4,64(sp)
  8000a0:	67a6                	ld	a5,72(sp)
  8000a2:	00000073          	ecall
  8000a6:	00a13e23          	sd	a0,28(sp)
        "sd a0, %0"
        : "=m" (ret)
        : "m"(num), "m"(a[0]), "m"(a[1]), "m"(a[2]), "m"(a[3]), "m"(a[4])
        :"memory");
    return ret;
}
  8000aa:	4572                	lw	a0,28(sp)
  8000ac:	6149                	addi	sp,sp,144
  8000ae:	8082                	ret

00000000008000b0 <sys_exit>:

int
sys_exit(int64_t error_code) {
  8000b0:	85aa                	mv	a1,a0
    return syscall(SYS_exit, error_code);
  8000b2:	4505                	li	a0,1
  8000b4:	b7c9                	j	800076 <syscall>

00000000008000b6 <sys_putc>:
sys_getpid(void) {
    return syscall(SYS_getpid);
}

int
sys_putc(int64_t c) {
  8000b6:	85aa                	mv	a1,a0
    return syscall(SYS_putc, c);
  8000b8:	4579                	li	a0,30
  8000ba:	bf75                	j	800076 <syscall>

00000000008000bc <exit>:
#include <syscall.h>
#include <stdio.h>
#include <ulib.h>

void
exit(int error_code) {
  8000bc:	1141                	addi	sp,sp,-16
  8000be:	e406                	sd	ra,8(sp)
    sys_exit(error_code);
  8000c0:	ff1ff0ef          	jal	ra,8000b0 <sys_exit>
    cprintf("BUG: exit failed.\n");
  8000c4:	00000517          	auipc	a0,0x0
  8000c8:	43450513          	addi	a0,a0,1076 # 8004f8 <main+0x10>
  8000cc:	f75ff0ef          	jal	ra,800040 <cprintf>
    while (1);
  8000d0:	a001                	j	8000d0 <exit+0x14>

00000000008000d2 <umain>:
#include <ulib.h>

int main(void);

void
umain(void) {
  8000d2:	1141                	addi	sp,sp,-16
  8000d4:	e406                	sd	ra,8(sp)
    int ret = main();
  8000d6:	412000ef          	jal	ra,8004e8 <main>
    exit(ret);
  8000da:	fe3ff0ef          	jal	ra,8000bc <exit>

00000000008000de <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
  8000de:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  8000e2:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
  8000e4:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  8000e8:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
  8000ea:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
  8000ee:	f022                	sd	s0,32(sp)
  8000f0:	ec26                	sd	s1,24(sp)
  8000f2:	e84a                	sd	s2,16(sp)
  8000f4:	f406                	sd	ra,40(sp)
  8000f6:	e44e                	sd	s3,8(sp)
  8000f8:	84aa                	mv	s1,a0
  8000fa:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  8000fc:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
  800100:	2a01                	sext.w	s4,s4
    if (num >= base) {
  800102:	03067e63          	bgeu	a2,a6,80013e <printnum+0x60>
  800106:	89be                	mv	s3,a5
        while (-- width > 0)
  800108:	00805763          	blez	s0,800116 <printnum+0x38>
  80010c:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
  80010e:	85ca                	mv	a1,s2
  800110:	854e                	mv	a0,s3
  800112:	9482                	jalr	s1
        while (-- width > 0)
  800114:	fc65                	bnez	s0,80010c <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  800116:	1a02                	slli	s4,s4,0x20
  800118:	00000797          	auipc	a5,0x0
  80011c:	3f878793          	addi	a5,a5,1016 # 800510 <main+0x28>
  800120:	020a5a13          	srli	s4,s4,0x20
  800124:	9a3e                	add	s4,s4,a5
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
  800126:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
  800128:	000a4503          	lbu	a0,0(s4)
}
  80012c:	70a2                	ld	ra,40(sp)
  80012e:	69a2                	ld	s3,8(sp)
  800130:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
  800132:	85ca                	mv	a1,s2
  800134:	87a6                	mv	a5,s1
}
  800136:	6942                	ld	s2,16(sp)
  800138:	64e2                	ld	s1,24(sp)
  80013a:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
  80013c:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
  80013e:	03065633          	divu	a2,a2,a6
  800142:	8722                	mv	a4,s0
  800144:	f9bff0ef          	jal	ra,8000de <printnum>
  800148:	b7f9                	j	800116 <printnum+0x38>

000000000080014a <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  80014a:	7119                	addi	sp,sp,-128
  80014c:	f4a6                	sd	s1,104(sp)
  80014e:	f0ca                	sd	s2,96(sp)
  800150:	ecce                	sd	s3,88(sp)
  800152:	e8d2                	sd	s4,80(sp)
  800154:	e4d6                	sd	s5,72(sp)
  800156:	e0da                	sd	s6,64(sp)
  800158:	fc5e                	sd	s7,56(sp)
  80015a:	f06a                	sd	s10,32(sp)
  80015c:	fc86                	sd	ra,120(sp)
  80015e:	f8a2                	sd	s0,112(sp)
  800160:	f862                	sd	s8,48(sp)
  800162:	f466                	sd	s9,40(sp)
  800164:	ec6e                	sd	s11,24(sp)
  800166:	892a                	mv	s2,a0
  800168:	84ae                	mv	s1,a1
  80016a:	8d32                	mv	s10,a2
  80016c:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  80016e:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
  800172:	5b7d                	li	s6,-1
  800174:	00000a97          	auipc	s5,0x0
  800178:	3d0a8a93          	addi	s5,s5,976 # 800544 <main+0x5c>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  80017c:	00000b97          	auipc	s7,0x0
  800180:	5e4b8b93          	addi	s7,s7,1508 # 800760 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800184:	000d4503          	lbu	a0,0(s10)
  800188:	001d0413          	addi	s0,s10,1
  80018c:	01350a63          	beq	a0,s3,8001a0 <vprintfmt+0x56>
            if (ch == '\0') {
  800190:	c121                	beqz	a0,8001d0 <vprintfmt+0x86>
            putch(ch, putdat);
  800192:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800194:	0405                	addi	s0,s0,1
            putch(ch, putdat);
  800196:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800198:	fff44503          	lbu	a0,-1(s0)
  80019c:	ff351ae3          	bne	a0,s3,800190 <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
  8001a0:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
  8001a4:	02000793          	li	a5,32
        lflag = altflag = 0;
  8001a8:	4c81                	li	s9,0
  8001aa:	4881                	li	a7,0
        width = precision = -1;
  8001ac:	5c7d                	li	s8,-1
  8001ae:	5dfd                	li	s11,-1
  8001b0:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
  8001b4:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
  8001b6:	fdd6059b          	addiw	a1,a2,-35
  8001ba:	0ff5f593          	zext.b	a1,a1
  8001be:	00140d13          	addi	s10,s0,1
  8001c2:	04b56263          	bltu	a0,a1,800206 <vprintfmt+0xbc>
  8001c6:	058a                	slli	a1,a1,0x2
  8001c8:	95d6                	add	a1,a1,s5
  8001ca:	4194                	lw	a3,0(a1)
  8001cc:	96d6                	add	a3,a3,s5
  8001ce:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
  8001d0:	70e6                	ld	ra,120(sp)
  8001d2:	7446                	ld	s0,112(sp)
  8001d4:	74a6                	ld	s1,104(sp)
  8001d6:	7906                	ld	s2,96(sp)
  8001d8:	69e6                	ld	s3,88(sp)
  8001da:	6a46                	ld	s4,80(sp)
  8001dc:	6aa6                	ld	s5,72(sp)
  8001de:	6b06                	ld	s6,64(sp)
  8001e0:	7be2                	ld	s7,56(sp)
  8001e2:	7c42                	ld	s8,48(sp)
  8001e4:	7ca2                	ld	s9,40(sp)
  8001e6:	7d02                	ld	s10,32(sp)
  8001e8:	6de2                	ld	s11,24(sp)
  8001ea:	6109                	addi	sp,sp,128
  8001ec:	8082                	ret
            padc = '0';
  8001ee:	87b2                	mv	a5,a2
            goto reswitch;
  8001f0:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
  8001f4:	846a                	mv	s0,s10
  8001f6:	00140d13          	addi	s10,s0,1
  8001fa:	fdd6059b          	addiw	a1,a2,-35
  8001fe:	0ff5f593          	zext.b	a1,a1
  800202:	fcb572e3          	bgeu	a0,a1,8001c6 <vprintfmt+0x7c>
            putch('%', putdat);
  800206:	85a6                	mv	a1,s1
  800208:	02500513          	li	a0,37
  80020c:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
  80020e:	fff44783          	lbu	a5,-1(s0)
  800212:	8d22                	mv	s10,s0
  800214:	f73788e3          	beq	a5,s3,800184 <vprintfmt+0x3a>
  800218:	ffed4783          	lbu	a5,-2(s10)
  80021c:	1d7d                	addi	s10,s10,-1
  80021e:	ff379de3          	bne	a5,s3,800218 <vprintfmt+0xce>
  800222:	b78d                	j	800184 <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
  800224:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
  800228:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
  80022c:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
  80022e:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
  800232:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
  800236:	02d86463          	bltu	a6,a3,80025e <vprintfmt+0x114>
                ch = *fmt;
  80023a:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
  80023e:	002c169b          	slliw	a3,s8,0x2
  800242:	0186873b          	addw	a4,a3,s8
  800246:	0017171b          	slliw	a4,a4,0x1
  80024a:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
  80024c:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
  800250:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
  800252:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
  800256:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
  80025a:	fed870e3          	bgeu	a6,a3,80023a <vprintfmt+0xf0>
            if (width < 0)
  80025e:	f40ddce3          	bgez	s11,8001b6 <vprintfmt+0x6c>
                width = precision, precision = -1;
  800262:	8de2                	mv	s11,s8
  800264:	5c7d                	li	s8,-1
  800266:	bf81                	j	8001b6 <vprintfmt+0x6c>
            if (width < 0)
  800268:	fffdc693          	not	a3,s11
  80026c:	96fd                	srai	a3,a3,0x3f
  80026e:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
  800272:	00144603          	lbu	a2,1(s0)
  800276:	2d81                	sext.w	s11,s11
  800278:	846a                	mv	s0,s10
            goto reswitch;
  80027a:	bf35                	j	8001b6 <vprintfmt+0x6c>
            precision = va_arg(ap, int);
  80027c:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
  800280:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
  800284:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
  800286:	846a                	mv	s0,s10
            goto process_precision;
  800288:	bfd9                	j	80025e <vprintfmt+0x114>
    if (lflag >= 2) {
  80028a:	4705                	li	a4,1
            precision = va_arg(ap, int);
  80028c:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  800290:	01174463          	blt	a4,a7,800298 <vprintfmt+0x14e>
    else if (lflag) {
  800294:	1a088e63          	beqz	a7,800450 <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
  800298:	000a3603          	ld	a2,0(s4)
  80029c:	46c1                	li	a3,16
  80029e:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
  8002a0:	2781                	sext.w	a5,a5
  8002a2:	876e                	mv	a4,s11
  8002a4:	85a6                	mv	a1,s1
  8002a6:	854a                	mv	a0,s2
  8002a8:	e37ff0ef          	jal	ra,8000de <printnum>
            break;
  8002ac:	bde1                	j	800184 <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
  8002ae:	000a2503          	lw	a0,0(s4)
  8002b2:	85a6                	mv	a1,s1
  8002b4:	0a21                	addi	s4,s4,8
  8002b6:	9902                	jalr	s2
            break;
  8002b8:	b5f1                	j	800184 <vprintfmt+0x3a>
    if (lflag >= 2) {
  8002ba:	4705                	li	a4,1
            precision = va_arg(ap, int);
  8002bc:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  8002c0:	01174463          	blt	a4,a7,8002c8 <vprintfmt+0x17e>
    else if (lflag) {
  8002c4:	18088163          	beqz	a7,800446 <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
  8002c8:	000a3603          	ld	a2,0(s4)
  8002cc:	46a9                	li	a3,10
  8002ce:	8a2e                	mv	s4,a1
  8002d0:	bfc1                	j	8002a0 <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
  8002d2:	00144603          	lbu	a2,1(s0)
            altflag = 1;
  8002d6:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
  8002d8:	846a                	mv	s0,s10
            goto reswitch;
  8002da:	bdf1                	j	8001b6 <vprintfmt+0x6c>
            putch(ch, putdat);
  8002dc:	85a6                	mv	a1,s1
  8002de:	02500513          	li	a0,37
  8002e2:	9902                	jalr	s2
            break;
  8002e4:	b545                	j	800184 <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
  8002e6:	00144603          	lbu	a2,1(s0)
            lflag ++;
  8002ea:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
  8002ec:	846a                	mv	s0,s10
            goto reswitch;
  8002ee:	b5e1                	j	8001b6 <vprintfmt+0x6c>
    if (lflag >= 2) {
  8002f0:	4705                	li	a4,1
            precision = va_arg(ap, int);
  8002f2:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  8002f6:	01174463          	blt	a4,a7,8002fe <vprintfmt+0x1b4>
    else if (lflag) {
  8002fa:	14088163          	beqz	a7,80043c <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
  8002fe:	000a3603          	ld	a2,0(s4)
  800302:	46a1                	li	a3,8
  800304:	8a2e                	mv	s4,a1
  800306:	bf69                	j	8002a0 <vprintfmt+0x156>
            putch('0', putdat);
  800308:	03000513          	li	a0,48
  80030c:	85a6                	mv	a1,s1
  80030e:	e03e                	sd	a5,0(sp)
  800310:	9902                	jalr	s2
            putch('x', putdat);
  800312:	85a6                	mv	a1,s1
  800314:	07800513          	li	a0,120
  800318:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  80031a:	0a21                	addi	s4,s4,8
            goto number;
  80031c:	6782                	ld	a5,0(sp)
  80031e:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  800320:	ff8a3603          	ld	a2,-8(s4)
            goto number;
  800324:	bfb5                	j	8002a0 <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
  800326:	000a3403          	ld	s0,0(s4)
  80032a:	008a0713          	addi	a4,s4,8
  80032e:	e03a                	sd	a4,0(sp)
  800330:	14040263          	beqz	s0,800474 <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
  800334:	0fb05763          	blez	s11,800422 <vprintfmt+0x2d8>
  800338:	02d00693          	li	a3,45
  80033c:	0cd79163          	bne	a5,a3,8003fe <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800340:	00044783          	lbu	a5,0(s0)
  800344:	0007851b          	sext.w	a0,a5
  800348:	cf85                	beqz	a5,800380 <vprintfmt+0x236>
  80034a:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
  80034e:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800352:	000c4563          	bltz	s8,80035c <vprintfmt+0x212>
  800356:	3c7d                	addiw	s8,s8,-1
  800358:	036c0263          	beq	s8,s6,80037c <vprintfmt+0x232>
                    putch('?', putdat);
  80035c:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
  80035e:	0e0c8e63          	beqz	s9,80045a <vprintfmt+0x310>
  800362:	3781                	addiw	a5,a5,-32
  800364:	0ef47b63          	bgeu	s0,a5,80045a <vprintfmt+0x310>
                    putch('?', putdat);
  800368:	03f00513          	li	a0,63
  80036c:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80036e:	000a4783          	lbu	a5,0(s4)
  800372:	3dfd                	addiw	s11,s11,-1
  800374:	0a05                	addi	s4,s4,1
  800376:	0007851b          	sext.w	a0,a5
  80037a:	ffe1                	bnez	a5,800352 <vprintfmt+0x208>
            for (; width > 0; width --) {
  80037c:	01b05963          	blez	s11,80038e <vprintfmt+0x244>
  800380:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
  800382:	85a6                	mv	a1,s1
  800384:	02000513          	li	a0,32
  800388:	9902                	jalr	s2
            for (; width > 0; width --) {
  80038a:	fe0d9be3          	bnez	s11,800380 <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
  80038e:	6a02                	ld	s4,0(sp)
  800390:	bbd5                	j	800184 <vprintfmt+0x3a>
    if (lflag >= 2) {
  800392:	4705                	li	a4,1
            precision = va_arg(ap, int);
  800394:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
  800398:	01174463          	blt	a4,a7,8003a0 <vprintfmt+0x256>
    else if (lflag) {
  80039c:	08088d63          	beqz	a7,800436 <vprintfmt+0x2ec>
        return va_arg(*ap, long);
  8003a0:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
  8003a4:	0a044d63          	bltz	s0,80045e <vprintfmt+0x314>
            num = getint(&ap, lflag);
  8003a8:	8622                	mv	a2,s0
  8003aa:	8a66                	mv	s4,s9
  8003ac:	46a9                	li	a3,10
  8003ae:	bdcd                	j	8002a0 <vprintfmt+0x156>
            err = va_arg(ap, int);
  8003b0:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8003b4:	4761                	li	a4,24
            err = va_arg(ap, int);
  8003b6:	0a21                	addi	s4,s4,8
            if (err < 0) {
  8003b8:	41f7d69b          	sraiw	a3,a5,0x1f
  8003bc:	8fb5                	xor	a5,a5,a3
  8003be:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8003c2:	02d74163          	blt	a4,a3,8003e4 <vprintfmt+0x29a>
  8003c6:	00369793          	slli	a5,a3,0x3
  8003ca:	97de                	add	a5,a5,s7
  8003cc:	639c                	ld	a5,0(a5)
  8003ce:	cb99                	beqz	a5,8003e4 <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
  8003d0:	86be                	mv	a3,a5
  8003d2:	00000617          	auipc	a2,0x0
  8003d6:	16e60613          	addi	a2,a2,366 # 800540 <main+0x58>
  8003da:	85a6                	mv	a1,s1
  8003dc:	854a                	mv	a0,s2
  8003de:	0ce000ef          	jal	ra,8004ac <printfmt>
  8003e2:	b34d                	j	800184 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
  8003e4:	00000617          	auipc	a2,0x0
  8003e8:	14c60613          	addi	a2,a2,332 # 800530 <main+0x48>
  8003ec:	85a6                	mv	a1,s1
  8003ee:	854a                	mv	a0,s2
  8003f0:	0bc000ef          	jal	ra,8004ac <printfmt>
  8003f4:	bb41                	j	800184 <vprintfmt+0x3a>
                p = "(null)";
  8003f6:	00000417          	auipc	s0,0x0
  8003fa:	13240413          	addi	s0,s0,306 # 800528 <main+0x40>
                for (width -= strnlen(p, precision); width > 0; width --) {
  8003fe:	85e2                	mv	a1,s8
  800400:	8522                	mv	a0,s0
  800402:	e43e                	sd	a5,8(sp)
  800404:	0c8000ef          	jal	ra,8004cc <strnlen>
  800408:	40ad8dbb          	subw	s11,s11,a0
  80040c:	01b05b63          	blez	s11,800422 <vprintfmt+0x2d8>
                    putch(padc, putdat);
  800410:	67a2                	ld	a5,8(sp)
  800412:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
  800416:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
  800418:	85a6                	mv	a1,s1
  80041a:	8552                	mv	a0,s4
  80041c:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
  80041e:	fe0d9ce3          	bnez	s11,800416 <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800422:	00044783          	lbu	a5,0(s0)
  800426:	00140a13          	addi	s4,s0,1
  80042a:	0007851b          	sext.w	a0,a5
  80042e:	d3a5                	beqz	a5,80038e <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
  800430:	05e00413          	li	s0,94
  800434:	bf39                	j	800352 <vprintfmt+0x208>
        return va_arg(*ap, int);
  800436:	000a2403          	lw	s0,0(s4)
  80043a:	b7ad                	j	8003a4 <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
  80043c:	000a6603          	lwu	a2,0(s4)
  800440:	46a1                	li	a3,8
  800442:	8a2e                	mv	s4,a1
  800444:	bdb1                	j	8002a0 <vprintfmt+0x156>
  800446:	000a6603          	lwu	a2,0(s4)
  80044a:	46a9                	li	a3,10
  80044c:	8a2e                	mv	s4,a1
  80044e:	bd89                	j	8002a0 <vprintfmt+0x156>
  800450:	000a6603          	lwu	a2,0(s4)
  800454:	46c1                	li	a3,16
  800456:	8a2e                	mv	s4,a1
  800458:	b5a1                	j	8002a0 <vprintfmt+0x156>
                    putch(ch, putdat);
  80045a:	9902                	jalr	s2
  80045c:	bf09                	j	80036e <vprintfmt+0x224>
                putch('-', putdat);
  80045e:	85a6                	mv	a1,s1
  800460:	02d00513          	li	a0,45
  800464:	e03e                	sd	a5,0(sp)
  800466:	9902                	jalr	s2
                num = -(long long)num;
  800468:	6782                	ld	a5,0(sp)
  80046a:	8a66                	mv	s4,s9
  80046c:	40800633          	neg	a2,s0
  800470:	46a9                	li	a3,10
  800472:	b53d                	j	8002a0 <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
  800474:	03b05163          	blez	s11,800496 <vprintfmt+0x34c>
  800478:	02d00693          	li	a3,45
  80047c:	f6d79de3          	bne	a5,a3,8003f6 <vprintfmt+0x2ac>
                p = "(null)";
  800480:	00000417          	auipc	s0,0x0
  800484:	0a840413          	addi	s0,s0,168 # 800528 <main+0x40>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800488:	02800793          	li	a5,40
  80048c:	02800513          	li	a0,40
  800490:	00140a13          	addi	s4,s0,1
  800494:	bd6d                	j	80034e <vprintfmt+0x204>
  800496:	00000a17          	auipc	s4,0x0
  80049a:	093a0a13          	addi	s4,s4,147 # 800529 <main+0x41>
  80049e:	02800513          	li	a0,40
  8004a2:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
  8004a6:	05e00413          	li	s0,94
  8004aa:	b565                	j	800352 <vprintfmt+0x208>

00000000008004ac <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8004ac:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
  8004ae:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8004b2:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
  8004b4:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8004b6:	ec06                	sd	ra,24(sp)
  8004b8:	f83a                	sd	a4,48(sp)
  8004ba:	fc3e                	sd	a5,56(sp)
  8004bc:	e0c2                	sd	a6,64(sp)
  8004be:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  8004c0:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
  8004c2:	c89ff0ef          	jal	ra,80014a <vprintfmt>
}
  8004c6:	60e2                	ld	ra,24(sp)
  8004c8:	6161                	addi	sp,sp,80
  8004ca:	8082                	ret

00000000008004cc <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
  8004cc:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
  8004ce:	e589                	bnez	a1,8004d8 <strnlen+0xc>
  8004d0:	a811                	j	8004e4 <strnlen+0x18>
        cnt ++;
  8004d2:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
  8004d4:	00f58863          	beq	a1,a5,8004e4 <strnlen+0x18>
  8004d8:	00f50733          	add	a4,a0,a5
  8004dc:	00074703          	lbu	a4,0(a4)
  8004e0:	fb6d                	bnez	a4,8004d2 <strnlen+0x6>
  8004e2:	85be                	mv	a1,a5
    }
    return cnt;
}
  8004e4:	852e                	mv	a0,a1
  8004e6:	8082                	ret

00000000008004e8 <main>:
#include <stdio.h>
#include <ulib.h>

int
main(void) {
  8004e8:	1141                	addi	sp,sp,-16
	// Never mind
    // asm volatile("int $14");
    exit(0);
  8004ea:	4501                	li	a0,0
main(void) {
  8004ec:	e406                	sd	ra,8(sp)
    exit(0);
  8004ee:	bcfff0ef          	jal	ra,8000bc <exit>
