
obj/__user_hello.out:     file format elf64-littleriscv


Disassembly of section .text:

0000000000800020 <_start>:
.text
.globl _start
_start:
    # call user-program function
    call umain
  800020:	0b8000ef          	jal	ra,8000d8 <umain>
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
  80002e:	08c000ef          	jal	ra,8000ba <sys_putc>
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
  80006a:	0e6000ef          	jal	ra,800150 <vprintfmt>
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

00000000008000b6 <sys_getpid>:
    return syscall(SYS_kill, pid);
}

int
sys_getpid(void) {
    return syscall(SYS_getpid);
  8000b6:	4549                	li	a0,18
  8000b8:	bf7d                	j	800076 <syscall>

00000000008000ba <sys_putc>:
}

int
sys_putc(int64_t c) {
  8000ba:	85aa                	mv	a1,a0
    return syscall(SYS_putc, c);
  8000bc:	4579                	li	a0,30
  8000be:	bf65                	j	800076 <syscall>

00000000008000c0 <exit>:
#include <syscall.h>
#include <stdio.h>
#include <ulib.h>

void
exit(int error_code) {
  8000c0:	1141                	addi	sp,sp,-16
  8000c2:	e406                	sd	ra,8(sp)
    sys_exit(error_code);
  8000c4:	fedff0ef          	jal	ra,8000b0 <sys_exit>
    cprintf("BUG: exit failed.\n");
  8000c8:	00000517          	auipc	a0,0x0
  8000cc:	46050513          	addi	a0,a0,1120 # 800528 <main+0x3a>
  8000d0:	f71ff0ef          	jal	ra,800040 <cprintf>
    while (1);
  8000d4:	a001                	j	8000d4 <exit+0x14>

00000000008000d6 <getpid>:
    return sys_kill(pid);
}

int
getpid(void) {
    return sys_getpid();
  8000d6:	b7c5                	j	8000b6 <sys_getpid>

00000000008000d8 <umain>:
#include <ulib.h>

int main(void);

void
umain(void) {
  8000d8:	1141                	addi	sp,sp,-16
  8000da:	e406                	sd	ra,8(sp)
    int ret = main();
  8000dc:	412000ef          	jal	ra,8004ee <main>
    exit(ret);
  8000e0:	fe1ff0ef          	jal	ra,8000c0 <exit>

00000000008000e4 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
  8000e4:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  8000e8:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
  8000ea:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  8000ee:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
  8000f0:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
  8000f4:	f022                	sd	s0,32(sp)
  8000f6:	ec26                	sd	s1,24(sp)
  8000f8:	e84a                	sd	s2,16(sp)
  8000fa:	f406                	sd	ra,40(sp)
  8000fc:	e44e                	sd	s3,8(sp)
  8000fe:	84aa                	mv	s1,a0
  800100:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  800102:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
  800106:	2a01                	sext.w	s4,s4
    if (num >= base) {
  800108:	03067e63          	bgeu	a2,a6,800144 <printnum+0x60>
  80010c:	89be                	mv	s3,a5
        while (-- width > 0)
  80010e:	00805763          	blez	s0,80011c <printnum+0x38>
  800112:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
  800114:	85ca                	mv	a1,s2
  800116:	854e                	mv	a0,s3
  800118:	9482                	jalr	s1
        while (-- width > 0)
  80011a:	fc65                	bnez	s0,800112 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  80011c:	1a02                	slli	s4,s4,0x20
  80011e:	00000797          	auipc	a5,0x0
  800122:	42278793          	addi	a5,a5,1058 # 800540 <main+0x52>
  800126:	020a5a13          	srli	s4,s4,0x20
  80012a:	9a3e                	add	s4,s4,a5
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
  80012c:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
  80012e:	000a4503          	lbu	a0,0(s4)
}
  800132:	70a2                	ld	ra,40(sp)
  800134:	69a2                	ld	s3,8(sp)
  800136:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
  800138:	85ca                	mv	a1,s2
  80013a:	87a6                	mv	a5,s1
}
  80013c:	6942                	ld	s2,16(sp)
  80013e:	64e2                	ld	s1,24(sp)
  800140:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
  800142:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
  800144:	03065633          	divu	a2,a2,a6
  800148:	8722                	mv	a4,s0
  80014a:	f9bff0ef          	jal	ra,8000e4 <printnum>
  80014e:	b7f9                	j	80011c <printnum+0x38>

0000000000800150 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  800150:	7119                	addi	sp,sp,-128
  800152:	f4a6                	sd	s1,104(sp)
  800154:	f0ca                	sd	s2,96(sp)
  800156:	ecce                	sd	s3,88(sp)
  800158:	e8d2                	sd	s4,80(sp)
  80015a:	e4d6                	sd	s5,72(sp)
  80015c:	e0da                	sd	s6,64(sp)
  80015e:	fc5e                	sd	s7,56(sp)
  800160:	f06a                	sd	s10,32(sp)
  800162:	fc86                	sd	ra,120(sp)
  800164:	f8a2                	sd	s0,112(sp)
  800166:	f862                	sd	s8,48(sp)
  800168:	f466                	sd	s9,40(sp)
  80016a:	ec6e                	sd	s11,24(sp)
  80016c:	892a                	mv	s2,a0
  80016e:	84ae                	mv	s1,a1
  800170:	8d32                	mv	s10,a2
  800172:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800174:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
  800178:	5b7d                	li	s6,-1
  80017a:	00000a97          	auipc	s5,0x0
  80017e:	3faa8a93          	addi	s5,s5,1018 # 800574 <main+0x86>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  800182:	00000b97          	auipc	s7,0x0
  800186:	60eb8b93          	addi	s7,s7,1550 # 800790 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  80018a:	000d4503          	lbu	a0,0(s10)
  80018e:	001d0413          	addi	s0,s10,1
  800192:	01350a63          	beq	a0,s3,8001a6 <vprintfmt+0x56>
            if (ch == '\0') {
  800196:	c121                	beqz	a0,8001d6 <vprintfmt+0x86>
            putch(ch, putdat);
  800198:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  80019a:	0405                	addi	s0,s0,1
            putch(ch, putdat);
  80019c:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  80019e:	fff44503          	lbu	a0,-1(s0)
  8001a2:	ff351ae3          	bne	a0,s3,800196 <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
  8001a6:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
  8001aa:	02000793          	li	a5,32
        lflag = altflag = 0;
  8001ae:	4c81                	li	s9,0
  8001b0:	4881                	li	a7,0
        width = precision = -1;
  8001b2:	5c7d                	li	s8,-1
  8001b4:	5dfd                	li	s11,-1
  8001b6:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
  8001ba:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
  8001bc:	fdd6059b          	addiw	a1,a2,-35
  8001c0:	0ff5f593          	zext.b	a1,a1
  8001c4:	00140d13          	addi	s10,s0,1
  8001c8:	04b56263          	bltu	a0,a1,80020c <vprintfmt+0xbc>
  8001cc:	058a                	slli	a1,a1,0x2
  8001ce:	95d6                	add	a1,a1,s5
  8001d0:	4194                	lw	a3,0(a1)
  8001d2:	96d6                	add	a3,a3,s5
  8001d4:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
  8001d6:	70e6                	ld	ra,120(sp)
  8001d8:	7446                	ld	s0,112(sp)
  8001da:	74a6                	ld	s1,104(sp)
  8001dc:	7906                	ld	s2,96(sp)
  8001de:	69e6                	ld	s3,88(sp)
  8001e0:	6a46                	ld	s4,80(sp)
  8001e2:	6aa6                	ld	s5,72(sp)
  8001e4:	6b06                	ld	s6,64(sp)
  8001e6:	7be2                	ld	s7,56(sp)
  8001e8:	7c42                	ld	s8,48(sp)
  8001ea:	7ca2                	ld	s9,40(sp)
  8001ec:	7d02                	ld	s10,32(sp)
  8001ee:	6de2                	ld	s11,24(sp)
  8001f0:	6109                	addi	sp,sp,128
  8001f2:	8082                	ret
            padc = '0';
  8001f4:	87b2                	mv	a5,a2
            goto reswitch;
  8001f6:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
  8001fa:	846a                	mv	s0,s10
  8001fc:	00140d13          	addi	s10,s0,1
  800200:	fdd6059b          	addiw	a1,a2,-35
  800204:	0ff5f593          	zext.b	a1,a1
  800208:	fcb572e3          	bgeu	a0,a1,8001cc <vprintfmt+0x7c>
            putch('%', putdat);
  80020c:	85a6                	mv	a1,s1
  80020e:	02500513          	li	a0,37
  800212:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
  800214:	fff44783          	lbu	a5,-1(s0)
  800218:	8d22                	mv	s10,s0
  80021a:	f73788e3          	beq	a5,s3,80018a <vprintfmt+0x3a>
  80021e:	ffed4783          	lbu	a5,-2(s10)
  800222:	1d7d                	addi	s10,s10,-1
  800224:	ff379de3          	bne	a5,s3,80021e <vprintfmt+0xce>
  800228:	b78d                	j	80018a <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
  80022a:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
  80022e:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
  800232:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
  800234:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
  800238:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
  80023c:	02d86463          	bltu	a6,a3,800264 <vprintfmt+0x114>
                ch = *fmt;
  800240:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
  800244:	002c169b          	slliw	a3,s8,0x2
  800248:	0186873b          	addw	a4,a3,s8
  80024c:	0017171b          	slliw	a4,a4,0x1
  800250:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
  800252:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
  800256:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
  800258:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
  80025c:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
  800260:	fed870e3          	bgeu	a6,a3,800240 <vprintfmt+0xf0>
            if (width < 0)
  800264:	f40ddce3          	bgez	s11,8001bc <vprintfmt+0x6c>
                width = precision, precision = -1;
  800268:	8de2                	mv	s11,s8
  80026a:	5c7d                	li	s8,-1
  80026c:	bf81                	j	8001bc <vprintfmt+0x6c>
            if (width < 0)
  80026e:	fffdc693          	not	a3,s11
  800272:	96fd                	srai	a3,a3,0x3f
  800274:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
  800278:	00144603          	lbu	a2,1(s0)
  80027c:	2d81                	sext.w	s11,s11
  80027e:	846a                	mv	s0,s10
            goto reswitch;
  800280:	bf35                	j	8001bc <vprintfmt+0x6c>
            precision = va_arg(ap, int);
  800282:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
  800286:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
  80028a:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
  80028c:	846a                	mv	s0,s10
            goto process_precision;
  80028e:	bfd9                	j	800264 <vprintfmt+0x114>
    if (lflag >= 2) {
  800290:	4705                	li	a4,1
            precision = va_arg(ap, int);
  800292:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  800296:	01174463          	blt	a4,a7,80029e <vprintfmt+0x14e>
    else if (lflag) {
  80029a:	1a088e63          	beqz	a7,800456 <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
  80029e:	000a3603          	ld	a2,0(s4)
  8002a2:	46c1                	li	a3,16
  8002a4:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
  8002a6:	2781                	sext.w	a5,a5
  8002a8:	876e                	mv	a4,s11
  8002aa:	85a6                	mv	a1,s1
  8002ac:	854a                	mv	a0,s2
  8002ae:	e37ff0ef          	jal	ra,8000e4 <printnum>
            break;
  8002b2:	bde1                	j	80018a <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
  8002b4:	000a2503          	lw	a0,0(s4)
  8002b8:	85a6                	mv	a1,s1
  8002ba:	0a21                	addi	s4,s4,8
  8002bc:	9902                	jalr	s2
            break;
  8002be:	b5f1                	j	80018a <vprintfmt+0x3a>
    if (lflag >= 2) {
  8002c0:	4705                	li	a4,1
            precision = va_arg(ap, int);
  8002c2:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  8002c6:	01174463          	blt	a4,a7,8002ce <vprintfmt+0x17e>
    else if (lflag) {
  8002ca:	18088163          	beqz	a7,80044c <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
  8002ce:	000a3603          	ld	a2,0(s4)
  8002d2:	46a9                	li	a3,10
  8002d4:	8a2e                	mv	s4,a1
  8002d6:	bfc1                	j	8002a6 <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
  8002d8:	00144603          	lbu	a2,1(s0)
            altflag = 1;
  8002dc:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
  8002de:	846a                	mv	s0,s10
            goto reswitch;
  8002e0:	bdf1                	j	8001bc <vprintfmt+0x6c>
            putch(ch, putdat);
  8002e2:	85a6                	mv	a1,s1
  8002e4:	02500513          	li	a0,37
  8002e8:	9902                	jalr	s2
            break;
  8002ea:	b545                	j	80018a <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
  8002ec:	00144603          	lbu	a2,1(s0)
            lflag ++;
  8002f0:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
  8002f2:	846a                	mv	s0,s10
            goto reswitch;
  8002f4:	b5e1                	j	8001bc <vprintfmt+0x6c>
    if (lflag >= 2) {
  8002f6:	4705                	li	a4,1
            precision = va_arg(ap, int);
  8002f8:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  8002fc:	01174463          	blt	a4,a7,800304 <vprintfmt+0x1b4>
    else if (lflag) {
  800300:	14088163          	beqz	a7,800442 <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
  800304:	000a3603          	ld	a2,0(s4)
  800308:	46a1                	li	a3,8
  80030a:	8a2e                	mv	s4,a1
  80030c:	bf69                	j	8002a6 <vprintfmt+0x156>
            putch('0', putdat);
  80030e:	03000513          	li	a0,48
  800312:	85a6                	mv	a1,s1
  800314:	e03e                	sd	a5,0(sp)
  800316:	9902                	jalr	s2
            putch('x', putdat);
  800318:	85a6                	mv	a1,s1
  80031a:	07800513          	li	a0,120
  80031e:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  800320:	0a21                	addi	s4,s4,8
            goto number;
  800322:	6782                	ld	a5,0(sp)
  800324:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  800326:	ff8a3603          	ld	a2,-8(s4)
            goto number;
  80032a:	bfb5                	j	8002a6 <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
  80032c:	000a3403          	ld	s0,0(s4)
  800330:	008a0713          	addi	a4,s4,8
  800334:	e03a                	sd	a4,0(sp)
  800336:	14040263          	beqz	s0,80047a <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
  80033a:	0fb05763          	blez	s11,800428 <vprintfmt+0x2d8>
  80033e:	02d00693          	li	a3,45
  800342:	0cd79163          	bne	a5,a3,800404 <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800346:	00044783          	lbu	a5,0(s0)
  80034a:	0007851b          	sext.w	a0,a5
  80034e:	cf85                	beqz	a5,800386 <vprintfmt+0x236>
  800350:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
  800354:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800358:	000c4563          	bltz	s8,800362 <vprintfmt+0x212>
  80035c:	3c7d                	addiw	s8,s8,-1
  80035e:	036c0263          	beq	s8,s6,800382 <vprintfmt+0x232>
                    putch('?', putdat);
  800362:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
  800364:	0e0c8e63          	beqz	s9,800460 <vprintfmt+0x310>
  800368:	3781                	addiw	a5,a5,-32
  80036a:	0ef47b63          	bgeu	s0,a5,800460 <vprintfmt+0x310>
                    putch('?', putdat);
  80036e:	03f00513          	li	a0,63
  800372:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800374:	000a4783          	lbu	a5,0(s4)
  800378:	3dfd                	addiw	s11,s11,-1
  80037a:	0a05                	addi	s4,s4,1
  80037c:	0007851b          	sext.w	a0,a5
  800380:	ffe1                	bnez	a5,800358 <vprintfmt+0x208>
            for (; width > 0; width --) {
  800382:	01b05963          	blez	s11,800394 <vprintfmt+0x244>
  800386:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
  800388:	85a6                	mv	a1,s1
  80038a:	02000513          	li	a0,32
  80038e:	9902                	jalr	s2
            for (; width > 0; width --) {
  800390:	fe0d9be3          	bnez	s11,800386 <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
  800394:	6a02                	ld	s4,0(sp)
  800396:	bbd5                	j	80018a <vprintfmt+0x3a>
    if (lflag >= 2) {
  800398:	4705                	li	a4,1
            precision = va_arg(ap, int);
  80039a:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
  80039e:	01174463          	blt	a4,a7,8003a6 <vprintfmt+0x256>
    else if (lflag) {
  8003a2:	08088d63          	beqz	a7,80043c <vprintfmt+0x2ec>
        return va_arg(*ap, long);
  8003a6:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
  8003aa:	0a044d63          	bltz	s0,800464 <vprintfmt+0x314>
            num = getint(&ap, lflag);
  8003ae:	8622                	mv	a2,s0
  8003b0:	8a66                	mv	s4,s9
  8003b2:	46a9                	li	a3,10
  8003b4:	bdcd                	j	8002a6 <vprintfmt+0x156>
            err = va_arg(ap, int);
  8003b6:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8003ba:	4761                	li	a4,24
            err = va_arg(ap, int);
  8003bc:	0a21                	addi	s4,s4,8
            if (err < 0) {
  8003be:	41f7d69b          	sraiw	a3,a5,0x1f
  8003c2:	8fb5                	xor	a5,a5,a3
  8003c4:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8003c8:	02d74163          	blt	a4,a3,8003ea <vprintfmt+0x29a>
  8003cc:	00369793          	slli	a5,a3,0x3
  8003d0:	97de                	add	a5,a5,s7
  8003d2:	639c                	ld	a5,0(a5)
  8003d4:	cb99                	beqz	a5,8003ea <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
  8003d6:	86be                	mv	a3,a5
  8003d8:	00000617          	auipc	a2,0x0
  8003dc:	19860613          	addi	a2,a2,408 # 800570 <main+0x82>
  8003e0:	85a6                	mv	a1,s1
  8003e2:	854a                	mv	a0,s2
  8003e4:	0ce000ef          	jal	ra,8004b2 <printfmt>
  8003e8:	b34d                	j	80018a <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
  8003ea:	00000617          	auipc	a2,0x0
  8003ee:	17660613          	addi	a2,a2,374 # 800560 <main+0x72>
  8003f2:	85a6                	mv	a1,s1
  8003f4:	854a                	mv	a0,s2
  8003f6:	0bc000ef          	jal	ra,8004b2 <printfmt>
  8003fa:	bb41                	j	80018a <vprintfmt+0x3a>
                p = "(null)";
  8003fc:	00000417          	auipc	s0,0x0
  800400:	15c40413          	addi	s0,s0,348 # 800558 <main+0x6a>
                for (width -= strnlen(p, precision); width > 0; width --) {
  800404:	85e2                	mv	a1,s8
  800406:	8522                	mv	a0,s0
  800408:	e43e                	sd	a5,8(sp)
  80040a:	0c8000ef          	jal	ra,8004d2 <strnlen>
  80040e:	40ad8dbb          	subw	s11,s11,a0
  800412:	01b05b63          	blez	s11,800428 <vprintfmt+0x2d8>
                    putch(padc, putdat);
  800416:	67a2                	ld	a5,8(sp)
  800418:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
  80041c:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
  80041e:	85a6                	mv	a1,s1
  800420:	8552                	mv	a0,s4
  800422:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
  800424:	fe0d9ce3          	bnez	s11,80041c <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800428:	00044783          	lbu	a5,0(s0)
  80042c:	00140a13          	addi	s4,s0,1
  800430:	0007851b          	sext.w	a0,a5
  800434:	d3a5                	beqz	a5,800394 <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
  800436:	05e00413          	li	s0,94
  80043a:	bf39                	j	800358 <vprintfmt+0x208>
        return va_arg(*ap, int);
  80043c:	000a2403          	lw	s0,0(s4)
  800440:	b7ad                	j	8003aa <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
  800442:	000a6603          	lwu	a2,0(s4)
  800446:	46a1                	li	a3,8
  800448:	8a2e                	mv	s4,a1
  80044a:	bdb1                	j	8002a6 <vprintfmt+0x156>
  80044c:	000a6603          	lwu	a2,0(s4)
  800450:	46a9                	li	a3,10
  800452:	8a2e                	mv	s4,a1
  800454:	bd89                	j	8002a6 <vprintfmt+0x156>
  800456:	000a6603          	lwu	a2,0(s4)
  80045a:	46c1                	li	a3,16
  80045c:	8a2e                	mv	s4,a1
  80045e:	b5a1                	j	8002a6 <vprintfmt+0x156>
                    putch(ch, putdat);
  800460:	9902                	jalr	s2
  800462:	bf09                	j	800374 <vprintfmt+0x224>
                putch('-', putdat);
  800464:	85a6                	mv	a1,s1
  800466:	02d00513          	li	a0,45
  80046a:	e03e                	sd	a5,0(sp)
  80046c:	9902                	jalr	s2
                num = -(long long)num;
  80046e:	6782                	ld	a5,0(sp)
  800470:	8a66                	mv	s4,s9
  800472:	40800633          	neg	a2,s0
  800476:	46a9                	li	a3,10
  800478:	b53d                	j	8002a6 <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
  80047a:	03b05163          	blez	s11,80049c <vprintfmt+0x34c>
  80047e:	02d00693          	li	a3,45
  800482:	f6d79de3          	bne	a5,a3,8003fc <vprintfmt+0x2ac>
                p = "(null)";
  800486:	00000417          	auipc	s0,0x0
  80048a:	0d240413          	addi	s0,s0,210 # 800558 <main+0x6a>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80048e:	02800793          	li	a5,40
  800492:	02800513          	li	a0,40
  800496:	00140a13          	addi	s4,s0,1
  80049a:	bd6d                	j	800354 <vprintfmt+0x204>
  80049c:	00000a17          	auipc	s4,0x0
  8004a0:	0bda0a13          	addi	s4,s4,189 # 800559 <main+0x6b>
  8004a4:	02800513          	li	a0,40
  8004a8:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
  8004ac:	05e00413          	li	s0,94
  8004b0:	b565                	j	800358 <vprintfmt+0x208>

00000000008004b2 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8004b2:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
  8004b4:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8004b8:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
  8004ba:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8004bc:	ec06                	sd	ra,24(sp)
  8004be:	f83a                	sd	a4,48(sp)
  8004c0:	fc3e                	sd	a5,56(sp)
  8004c2:	e0c2                	sd	a6,64(sp)
  8004c4:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  8004c6:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
  8004c8:	c89ff0ef          	jal	ra,800150 <vprintfmt>
}
  8004cc:	60e2                	ld	ra,24(sp)
  8004ce:	6161                	addi	sp,sp,80
  8004d0:	8082                	ret

00000000008004d2 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
  8004d2:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
  8004d4:	e589                	bnez	a1,8004de <strnlen+0xc>
  8004d6:	a811                	j	8004ea <strnlen+0x18>
        cnt ++;
  8004d8:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
  8004da:	00f58863          	beq	a1,a5,8004ea <strnlen+0x18>
  8004de:	00f50733          	add	a4,a0,a5
  8004e2:	00074703          	lbu	a4,0(a4)
  8004e6:	fb6d                	bnez	a4,8004d8 <strnlen+0x6>
  8004e8:	85be                	mv	a1,a5
    }
    return cnt;
}
  8004ea:	852e                	mv	a0,a1
  8004ec:	8082                	ret

00000000008004ee <main>:
#include <stdio.h>
#include <ulib.h>

int
main(void) {
  8004ee:	1141                	addi	sp,sp,-16
    cprintf("Hello world!!.\n");
  8004f0:	00000517          	auipc	a0,0x0
  8004f4:	36850513          	addi	a0,a0,872 # 800858 <error_string+0xc8>
main(void) {
  8004f8:	e406                	sd	ra,8(sp)
    cprintf("Hello world!!.\n");
  8004fa:	b47ff0ef          	jal	ra,800040 <cprintf>
    cprintf("I am process %d.\n", getpid());
  8004fe:	bd9ff0ef          	jal	ra,8000d6 <getpid>
  800502:	85aa                	mv	a1,a0
  800504:	00000517          	auipc	a0,0x0
  800508:	36450513          	addi	a0,a0,868 # 800868 <error_string+0xd8>
  80050c:	b35ff0ef          	jal	ra,800040 <cprintf>
    cprintf("hello pass.\n");
  800510:	00000517          	auipc	a0,0x0
  800514:	37050513          	addi	a0,a0,880 # 800880 <error_string+0xf0>
  800518:	b29ff0ef          	jal	ra,800040 <cprintf>
    return 0;
}
  80051c:	60a2                	ld	ra,8(sp)
  80051e:	4501                	li	a0,0
  800520:	0141                	addi	sp,sp,16
  800522:	8082                	ret
