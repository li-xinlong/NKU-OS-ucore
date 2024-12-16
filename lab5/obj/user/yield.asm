
obj/__user_yield.out:     file format elf64-littleriscv


Disassembly of section .text:

0000000000800020 <_start>:
.text
.globl _start
_start:
    # call user-program function
    call umain
  800020:	0be000ef          	jal	ra,8000de <umain>
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
  80002e:	090000ef          	jal	ra,8000be <sys_putc>
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
  80006a:	0ec000ef          	jal	ra,800156 <vprintfmt>
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

00000000008000b6 <sys_yield>:
    return syscall(SYS_wait, pid, store);
}

int
sys_yield(void) {
    return syscall(SYS_yield);
  8000b6:	4529                	li	a0,10
  8000b8:	bf7d                	j	800076 <syscall>

00000000008000ba <sys_getpid>:
    return syscall(SYS_kill, pid);
}

int
sys_getpid(void) {
    return syscall(SYS_getpid);
  8000ba:	4549                	li	a0,18
  8000bc:	bf6d                	j	800076 <syscall>

00000000008000be <sys_putc>:
}

int
sys_putc(int64_t c) {
  8000be:	85aa                	mv	a1,a0
    return syscall(SYS_putc, c);
  8000c0:	4579                	li	a0,30
  8000c2:	bf55                	j	800076 <syscall>

00000000008000c4 <exit>:
#include <syscall.h>
#include <stdio.h>
#include <ulib.h>

void
exit(int error_code) {
  8000c4:	1141                	addi	sp,sp,-16
  8000c6:	e406                	sd	ra,8(sp)
    sys_exit(error_code);
  8000c8:	fe9ff0ef          	jal	ra,8000b0 <sys_exit>
    cprintf("BUG: exit failed.\n");
  8000cc:	00000517          	auipc	a0,0x0
  8000d0:	49450513          	addi	a0,a0,1172 # 800560 <main+0x6c>
  8000d4:	f6dff0ef          	jal	ra,800040 <cprintf>
    while (1);
  8000d8:	a001                	j	8000d8 <exit+0x14>

00000000008000da <yield>:
    return sys_wait(pid, store);
}

void
yield(void) {
    sys_yield();
  8000da:	bff1                	j	8000b6 <sys_yield>

00000000008000dc <getpid>:
    return sys_kill(pid);
}

int
getpid(void) {
    return sys_getpid();
  8000dc:	bff9                	j	8000ba <sys_getpid>

00000000008000de <umain>:
#include <ulib.h>

int main(void);

void
umain(void) {
  8000de:	1141                	addi	sp,sp,-16
  8000e0:	e406                	sd	ra,8(sp)
    int ret = main();
  8000e2:	412000ef          	jal	ra,8004f4 <main>
    exit(ret);
  8000e6:	fdfff0ef          	jal	ra,8000c4 <exit>

00000000008000ea <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
  8000ea:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  8000ee:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
  8000f0:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  8000f4:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
  8000f6:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
  8000fa:	f022                	sd	s0,32(sp)
  8000fc:	ec26                	sd	s1,24(sp)
  8000fe:	e84a                	sd	s2,16(sp)
  800100:	f406                	sd	ra,40(sp)
  800102:	e44e                	sd	s3,8(sp)
  800104:	84aa                	mv	s1,a0
  800106:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  800108:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
  80010c:	2a01                	sext.w	s4,s4
    if (num >= base) {
  80010e:	03067e63          	bgeu	a2,a6,80014a <printnum+0x60>
  800112:	89be                	mv	s3,a5
        while (-- width > 0)
  800114:	00805763          	blez	s0,800122 <printnum+0x38>
  800118:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
  80011a:	85ca                	mv	a1,s2
  80011c:	854e                	mv	a0,s3
  80011e:	9482                	jalr	s1
        while (-- width > 0)
  800120:	fc65                	bnez	s0,800118 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  800122:	1a02                	slli	s4,s4,0x20
  800124:	00000797          	auipc	a5,0x0
  800128:	45478793          	addi	a5,a5,1108 # 800578 <main+0x84>
  80012c:	020a5a13          	srli	s4,s4,0x20
  800130:	9a3e                	add	s4,s4,a5
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
  800132:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
  800134:	000a4503          	lbu	a0,0(s4)
}
  800138:	70a2                	ld	ra,40(sp)
  80013a:	69a2                	ld	s3,8(sp)
  80013c:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
  80013e:	85ca                	mv	a1,s2
  800140:	87a6                	mv	a5,s1
}
  800142:	6942                	ld	s2,16(sp)
  800144:	64e2                	ld	s1,24(sp)
  800146:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
  800148:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
  80014a:	03065633          	divu	a2,a2,a6
  80014e:	8722                	mv	a4,s0
  800150:	f9bff0ef          	jal	ra,8000ea <printnum>
  800154:	b7f9                	j	800122 <printnum+0x38>

0000000000800156 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  800156:	7119                	addi	sp,sp,-128
  800158:	f4a6                	sd	s1,104(sp)
  80015a:	f0ca                	sd	s2,96(sp)
  80015c:	ecce                	sd	s3,88(sp)
  80015e:	e8d2                	sd	s4,80(sp)
  800160:	e4d6                	sd	s5,72(sp)
  800162:	e0da                	sd	s6,64(sp)
  800164:	fc5e                	sd	s7,56(sp)
  800166:	f06a                	sd	s10,32(sp)
  800168:	fc86                	sd	ra,120(sp)
  80016a:	f8a2                	sd	s0,112(sp)
  80016c:	f862                	sd	s8,48(sp)
  80016e:	f466                	sd	s9,40(sp)
  800170:	ec6e                	sd	s11,24(sp)
  800172:	892a                	mv	s2,a0
  800174:	84ae                	mv	s1,a1
  800176:	8d32                	mv	s10,a2
  800178:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  80017a:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
  80017e:	5b7d                	li	s6,-1
  800180:	00000a97          	auipc	s5,0x0
  800184:	42ca8a93          	addi	s5,s5,1068 # 8005ac <main+0xb8>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  800188:	00000b97          	auipc	s7,0x0
  80018c:	640b8b93          	addi	s7,s7,1600 # 8007c8 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800190:	000d4503          	lbu	a0,0(s10)
  800194:	001d0413          	addi	s0,s10,1
  800198:	01350a63          	beq	a0,s3,8001ac <vprintfmt+0x56>
            if (ch == '\0') {
  80019c:	c121                	beqz	a0,8001dc <vprintfmt+0x86>
            putch(ch, putdat);
  80019e:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001a0:	0405                	addi	s0,s0,1
            putch(ch, putdat);
  8001a2:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001a4:	fff44503          	lbu	a0,-1(s0)
  8001a8:	ff351ae3          	bne	a0,s3,80019c <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
  8001ac:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
  8001b0:	02000793          	li	a5,32
        lflag = altflag = 0;
  8001b4:	4c81                	li	s9,0
  8001b6:	4881                	li	a7,0
        width = precision = -1;
  8001b8:	5c7d                	li	s8,-1
  8001ba:	5dfd                	li	s11,-1
  8001bc:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
  8001c0:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
  8001c2:	fdd6059b          	addiw	a1,a2,-35
  8001c6:	0ff5f593          	zext.b	a1,a1
  8001ca:	00140d13          	addi	s10,s0,1
  8001ce:	04b56263          	bltu	a0,a1,800212 <vprintfmt+0xbc>
  8001d2:	058a                	slli	a1,a1,0x2
  8001d4:	95d6                	add	a1,a1,s5
  8001d6:	4194                	lw	a3,0(a1)
  8001d8:	96d6                	add	a3,a3,s5
  8001da:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
  8001dc:	70e6                	ld	ra,120(sp)
  8001de:	7446                	ld	s0,112(sp)
  8001e0:	74a6                	ld	s1,104(sp)
  8001e2:	7906                	ld	s2,96(sp)
  8001e4:	69e6                	ld	s3,88(sp)
  8001e6:	6a46                	ld	s4,80(sp)
  8001e8:	6aa6                	ld	s5,72(sp)
  8001ea:	6b06                	ld	s6,64(sp)
  8001ec:	7be2                	ld	s7,56(sp)
  8001ee:	7c42                	ld	s8,48(sp)
  8001f0:	7ca2                	ld	s9,40(sp)
  8001f2:	7d02                	ld	s10,32(sp)
  8001f4:	6de2                	ld	s11,24(sp)
  8001f6:	6109                	addi	sp,sp,128
  8001f8:	8082                	ret
            padc = '0';
  8001fa:	87b2                	mv	a5,a2
            goto reswitch;
  8001fc:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
  800200:	846a                	mv	s0,s10
  800202:	00140d13          	addi	s10,s0,1
  800206:	fdd6059b          	addiw	a1,a2,-35
  80020a:	0ff5f593          	zext.b	a1,a1
  80020e:	fcb572e3          	bgeu	a0,a1,8001d2 <vprintfmt+0x7c>
            putch('%', putdat);
  800212:	85a6                	mv	a1,s1
  800214:	02500513          	li	a0,37
  800218:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
  80021a:	fff44783          	lbu	a5,-1(s0)
  80021e:	8d22                	mv	s10,s0
  800220:	f73788e3          	beq	a5,s3,800190 <vprintfmt+0x3a>
  800224:	ffed4783          	lbu	a5,-2(s10)
  800228:	1d7d                	addi	s10,s10,-1
  80022a:	ff379de3          	bne	a5,s3,800224 <vprintfmt+0xce>
  80022e:	b78d                	j	800190 <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
  800230:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
  800234:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
  800238:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
  80023a:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
  80023e:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
  800242:	02d86463          	bltu	a6,a3,80026a <vprintfmt+0x114>
                ch = *fmt;
  800246:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
  80024a:	002c169b          	slliw	a3,s8,0x2
  80024e:	0186873b          	addw	a4,a3,s8
  800252:	0017171b          	slliw	a4,a4,0x1
  800256:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
  800258:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
  80025c:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
  80025e:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
  800262:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
  800266:	fed870e3          	bgeu	a6,a3,800246 <vprintfmt+0xf0>
            if (width < 0)
  80026a:	f40ddce3          	bgez	s11,8001c2 <vprintfmt+0x6c>
                width = precision, precision = -1;
  80026e:	8de2                	mv	s11,s8
  800270:	5c7d                	li	s8,-1
  800272:	bf81                	j	8001c2 <vprintfmt+0x6c>
            if (width < 0)
  800274:	fffdc693          	not	a3,s11
  800278:	96fd                	srai	a3,a3,0x3f
  80027a:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
  80027e:	00144603          	lbu	a2,1(s0)
  800282:	2d81                	sext.w	s11,s11
  800284:	846a                	mv	s0,s10
            goto reswitch;
  800286:	bf35                	j	8001c2 <vprintfmt+0x6c>
            precision = va_arg(ap, int);
  800288:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
  80028c:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
  800290:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
  800292:	846a                	mv	s0,s10
            goto process_precision;
  800294:	bfd9                	j	80026a <vprintfmt+0x114>
    if (lflag >= 2) {
  800296:	4705                	li	a4,1
            precision = va_arg(ap, int);
  800298:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  80029c:	01174463          	blt	a4,a7,8002a4 <vprintfmt+0x14e>
    else if (lflag) {
  8002a0:	1a088e63          	beqz	a7,80045c <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
  8002a4:	000a3603          	ld	a2,0(s4)
  8002a8:	46c1                	li	a3,16
  8002aa:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
  8002ac:	2781                	sext.w	a5,a5
  8002ae:	876e                	mv	a4,s11
  8002b0:	85a6                	mv	a1,s1
  8002b2:	854a                	mv	a0,s2
  8002b4:	e37ff0ef          	jal	ra,8000ea <printnum>
            break;
  8002b8:	bde1                	j	800190 <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
  8002ba:	000a2503          	lw	a0,0(s4)
  8002be:	85a6                	mv	a1,s1
  8002c0:	0a21                	addi	s4,s4,8
  8002c2:	9902                	jalr	s2
            break;
  8002c4:	b5f1                	j	800190 <vprintfmt+0x3a>
    if (lflag >= 2) {
  8002c6:	4705                	li	a4,1
            precision = va_arg(ap, int);
  8002c8:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  8002cc:	01174463          	blt	a4,a7,8002d4 <vprintfmt+0x17e>
    else if (lflag) {
  8002d0:	18088163          	beqz	a7,800452 <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
  8002d4:	000a3603          	ld	a2,0(s4)
  8002d8:	46a9                	li	a3,10
  8002da:	8a2e                	mv	s4,a1
  8002dc:	bfc1                	j	8002ac <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
  8002de:	00144603          	lbu	a2,1(s0)
            altflag = 1;
  8002e2:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
  8002e4:	846a                	mv	s0,s10
            goto reswitch;
  8002e6:	bdf1                	j	8001c2 <vprintfmt+0x6c>
            putch(ch, putdat);
  8002e8:	85a6                	mv	a1,s1
  8002ea:	02500513          	li	a0,37
  8002ee:	9902                	jalr	s2
            break;
  8002f0:	b545                	j	800190 <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
  8002f2:	00144603          	lbu	a2,1(s0)
            lflag ++;
  8002f6:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
  8002f8:	846a                	mv	s0,s10
            goto reswitch;
  8002fa:	b5e1                	j	8001c2 <vprintfmt+0x6c>
    if (lflag >= 2) {
  8002fc:	4705                	li	a4,1
            precision = va_arg(ap, int);
  8002fe:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  800302:	01174463          	blt	a4,a7,80030a <vprintfmt+0x1b4>
    else if (lflag) {
  800306:	14088163          	beqz	a7,800448 <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
  80030a:	000a3603          	ld	a2,0(s4)
  80030e:	46a1                	li	a3,8
  800310:	8a2e                	mv	s4,a1
  800312:	bf69                	j	8002ac <vprintfmt+0x156>
            putch('0', putdat);
  800314:	03000513          	li	a0,48
  800318:	85a6                	mv	a1,s1
  80031a:	e03e                	sd	a5,0(sp)
  80031c:	9902                	jalr	s2
            putch('x', putdat);
  80031e:	85a6                	mv	a1,s1
  800320:	07800513          	li	a0,120
  800324:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  800326:	0a21                	addi	s4,s4,8
            goto number;
  800328:	6782                	ld	a5,0(sp)
  80032a:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  80032c:	ff8a3603          	ld	a2,-8(s4)
            goto number;
  800330:	bfb5                	j	8002ac <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
  800332:	000a3403          	ld	s0,0(s4)
  800336:	008a0713          	addi	a4,s4,8
  80033a:	e03a                	sd	a4,0(sp)
  80033c:	14040263          	beqz	s0,800480 <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
  800340:	0fb05763          	blez	s11,80042e <vprintfmt+0x2d8>
  800344:	02d00693          	li	a3,45
  800348:	0cd79163          	bne	a5,a3,80040a <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80034c:	00044783          	lbu	a5,0(s0)
  800350:	0007851b          	sext.w	a0,a5
  800354:	cf85                	beqz	a5,80038c <vprintfmt+0x236>
  800356:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
  80035a:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80035e:	000c4563          	bltz	s8,800368 <vprintfmt+0x212>
  800362:	3c7d                	addiw	s8,s8,-1
  800364:	036c0263          	beq	s8,s6,800388 <vprintfmt+0x232>
                    putch('?', putdat);
  800368:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
  80036a:	0e0c8e63          	beqz	s9,800466 <vprintfmt+0x310>
  80036e:	3781                	addiw	a5,a5,-32
  800370:	0ef47b63          	bgeu	s0,a5,800466 <vprintfmt+0x310>
                    putch('?', putdat);
  800374:	03f00513          	li	a0,63
  800378:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80037a:	000a4783          	lbu	a5,0(s4)
  80037e:	3dfd                	addiw	s11,s11,-1
  800380:	0a05                	addi	s4,s4,1
  800382:	0007851b          	sext.w	a0,a5
  800386:	ffe1                	bnez	a5,80035e <vprintfmt+0x208>
            for (; width > 0; width --) {
  800388:	01b05963          	blez	s11,80039a <vprintfmt+0x244>
  80038c:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
  80038e:	85a6                	mv	a1,s1
  800390:	02000513          	li	a0,32
  800394:	9902                	jalr	s2
            for (; width > 0; width --) {
  800396:	fe0d9be3          	bnez	s11,80038c <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
  80039a:	6a02                	ld	s4,0(sp)
  80039c:	bbd5                	j	800190 <vprintfmt+0x3a>
    if (lflag >= 2) {
  80039e:	4705                	li	a4,1
            precision = va_arg(ap, int);
  8003a0:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
  8003a4:	01174463          	blt	a4,a7,8003ac <vprintfmt+0x256>
    else if (lflag) {
  8003a8:	08088d63          	beqz	a7,800442 <vprintfmt+0x2ec>
        return va_arg(*ap, long);
  8003ac:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
  8003b0:	0a044d63          	bltz	s0,80046a <vprintfmt+0x314>
            num = getint(&ap, lflag);
  8003b4:	8622                	mv	a2,s0
  8003b6:	8a66                	mv	s4,s9
  8003b8:	46a9                	li	a3,10
  8003ba:	bdcd                	j	8002ac <vprintfmt+0x156>
            err = va_arg(ap, int);
  8003bc:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8003c0:	4761                	li	a4,24
            err = va_arg(ap, int);
  8003c2:	0a21                	addi	s4,s4,8
            if (err < 0) {
  8003c4:	41f7d69b          	sraiw	a3,a5,0x1f
  8003c8:	8fb5                	xor	a5,a5,a3
  8003ca:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8003ce:	02d74163          	blt	a4,a3,8003f0 <vprintfmt+0x29a>
  8003d2:	00369793          	slli	a5,a3,0x3
  8003d6:	97de                	add	a5,a5,s7
  8003d8:	639c                	ld	a5,0(a5)
  8003da:	cb99                	beqz	a5,8003f0 <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
  8003dc:	86be                	mv	a3,a5
  8003de:	00000617          	auipc	a2,0x0
  8003e2:	1ca60613          	addi	a2,a2,458 # 8005a8 <main+0xb4>
  8003e6:	85a6                	mv	a1,s1
  8003e8:	854a                	mv	a0,s2
  8003ea:	0ce000ef          	jal	ra,8004b8 <printfmt>
  8003ee:	b34d                	j	800190 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
  8003f0:	00000617          	auipc	a2,0x0
  8003f4:	1a860613          	addi	a2,a2,424 # 800598 <main+0xa4>
  8003f8:	85a6                	mv	a1,s1
  8003fa:	854a                	mv	a0,s2
  8003fc:	0bc000ef          	jal	ra,8004b8 <printfmt>
  800400:	bb41                	j	800190 <vprintfmt+0x3a>
                p = "(null)";
  800402:	00000417          	auipc	s0,0x0
  800406:	18e40413          	addi	s0,s0,398 # 800590 <main+0x9c>
                for (width -= strnlen(p, precision); width > 0; width --) {
  80040a:	85e2                	mv	a1,s8
  80040c:	8522                	mv	a0,s0
  80040e:	e43e                	sd	a5,8(sp)
  800410:	0c8000ef          	jal	ra,8004d8 <strnlen>
  800414:	40ad8dbb          	subw	s11,s11,a0
  800418:	01b05b63          	blez	s11,80042e <vprintfmt+0x2d8>
                    putch(padc, putdat);
  80041c:	67a2                	ld	a5,8(sp)
  80041e:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
  800422:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
  800424:	85a6                	mv	a1,s1
  800426:	8552                	mv	a0,s4
  800428:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
  80042a:	fe0d9ce3          	bnez	s11,800422 <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80042e:	00044783          	lbu	a5,0(s0)
  800432:	00140a13          	addi	s4,s0,1
  800436:	0007851b          	sext.w	a0,a5
  80043a:	d3a5                	beqz	a5,80039a <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
  80043c:	05e00413          	li	s0,94
  800440:	bf39                	j	80035e <vprintfmt+0x208>
        return va_arg(*ap, int);
  800442:	000a2403          	lw	s0,0(s4)
  800446:	b7ad                	j	8003b0 <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
  800448:	000a6603          	lwu	a2,0(s4)
  80044c:	46a1                	li	a3,8
  80044e:	8a2e                	mv	s4,a1
  800450:	bdb1                	j	8002ac <vprintfmt+0x156>
  800452:	000a6603          	lwu	a2,0(s4)
  800456:	46a9                	li	a3,10
  800458:	8a2e                	mv	s4,a1
  80045a:	bd89                	j	8002ac <vprintfmt+0x156>
  80045c:	000a6603          	lwu	a2,0(s4)
  800460:	46c1                	li	a3,16
  800462:	8a2e                	mv	s4,a1
  800464:	b5a1                	j	8002ac <vprintfmt+0x156>
                    putch(ch, putdat);
  800466:	9902                	jalr	s2
  800468:	bf09                	j	80037a <vprintfmt+0x224>
                putch('-', putdat);
  80046a:	85a6                	mv	a1,s1
  80046c:	02d00513          	li	a0,45
  800470:	e03e                	sd	a5,0(sp)
  800472:	9902                	jalr	s2
                num = -(long long)num;
  800474:	6782                	ld	a5,0(sp)
  800476:	8a66                	mv	s4,s9
  800478:	40800633          	neg	a2,s0
  80047c:	46a9                	li	a3,10
  80047e:	b53d                	j	8002ac <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
  800480:	03b05163          	blez	s11,8004a2 <vprintfmt+0x34c>
  800484:	02d00693          	li	a3,45
  800488:	f6d79de3          	bne	a5,a3,800402 <vprintfmt+0x2ac>
                p = "(null)";
  80048c:	00000417          	auipc	s0,0x0
  800490:	10440413          	addi	s0,s0,260 # 800590 <main+0x9c>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800494:	02800793          	li	a5,40
  800498:	02800513          	li	a0,40
  80049c:	00140a13          	addi	s4,s0,1
  8004a0:	bd6d                	j	80035a <vprintfmt+0x204>
  8004a2:	00000a17          	auipc	s4,0x0
  8004a6:	0efa0a13          	addi	s4,s4,239 # 800591 <main+0x9d>
  8004aa:	02800513          	li	a0,40
  8004ae:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
  8004b2:	05e00413          	li	s0,94
  8004b6:	b565                	j	80035e <vprintfmt+0x208>

00000000008004b8 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8004b8:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
  8004ba:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8004be:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
  8004c0:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8004c2:	ec06                	sd	ra,24(sp)
  8004c4:	f83a                	sd	a4,48(sp)
  8004c6:	fc3e                	sd	a5,56(sp)
  8004c8:	e0c2                	sd	a6,64(sp)
  8004ca:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  8004cc:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
  8004ce:	c89ff0ef          	jal	ra,800156 <vprintfmt>
}
  8004d2:	60e2                	ld	ra,24(sp)
  8004d4:	6161                	addi	sp,sp,80
  8004d6:	8082                	ret

00000000008004d8 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
  8004d8:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
  8004da:	e589                	bnez	a1,8004e4 <strnlen+0xc>
  8004dc:	a811                	j	8004f0 <strnlen+0x18>
        cnt ++;
  8004de:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
  8004e0:	00f58863          	beq	a1,a5,8004f0 <strnlen+0x18>
  8004e4:	00f50733          	add	a4,a0,a5
  8004e8:	00074703          	lbu	a4,0(a4)
  8004ec:	fb6d                	bnez	a4,8004de <strnlen+0x6>
  8004ee:	85be                	mv	a1,a5
    }
    return cnt;
}
  8004f0:	852e                	mv	a0,a1
  8004f2:	8082                	ret

00000000008004f4 <main>:
#include <ulib.h>
#include <stdio.h>

int
main(void) {
  8004f4:	1101                	addi	sp,sp,-32
  8004f6:	ec06                	sd	ra,24(sp)
  8004f8:	e822                	sd	s0,16(sp)
  8004fa:	e426                	sd	s1,8(sp)
  8004fc:	e04a                	sd	s2,0(sp)
    int i;
    cprintf("Hello, I am process %d.\n", getpid());
  8004fe:	bdfff0ef          	jal	ra,8000dc <getpid>
  800502:	85aa                	mv	a1,a0
  800504:	00000517          	auipc	a0,0x0
  800508:	38c50513          	addi	a0,a0,908 # 800890 <error_string+0xc8>
  80050c:	b35ff0ef          	jal	ra,800040 <cprintf>
    for (i = 0; i < 5; i ++) {
  800510:	4401                	li	s0,0
        yield();
        cprintf("Back in process %d, iteration %d.\n", getpid(), i);
  800512:	00000917          	auipc	s2,0x0
  800516:	39e90913          	addi	s2,s2,926 # 8008b0 <error_string+0xe8>
    for (i = 0; i < 5; i ++) {
  80051a:	4495                	li	s1,5
        yield();
  80051c:	bbfff0ef          	jal	ra,8000da <yield>
        cprintf("Back in process %d, iteration %d.\n", getpid(), i);
  800520:	bbdff0ef          	jal	ra,8000dc <getpid>
  800524:	85aa                	mv	a1,a0
  800526:	8622                	mv	a2,s0
  800528:	854a                	mv	a0,s2
    for (i = 0; i < 5; i ++) {
  80052a:	2405                	addiw	s0,s0,1
        cprintf("Back in process %d, iteration %d.\n", getpid(), i);
  80052c:	b15ff0ef          	jal	ra,800040 <cprintf>
    for (i = 0; i < 5; i ++) {
  800530:	fe9416e3          	bne	s0,s1,80051c <main+0x28>
    }
    cprintf("All done in process %d.\n", getpid());
  800534:	ba9ff0ef          	jal	ra,8000dc <getpid>
  800538:	85aa                	mv	a1,a0
  80053a:	00000517          	auipc	a0,0x0
  80053e:	39e50513          	addi	a0,a0,926 # 8008d8 <error_string+0x110>
  800542:	affff0ef          	jal	ra,800040 <cprintf>
    cprintf("yield pass.\n");
  800546:	00000517          	auipc	a0,0x0
  80054a:	3b250513          	addi	a0,a0,946 # 8008f8 <error_string+0x130>
  80054e:	af3ff0ef          	jal	ra,800040 <cprintf>
    return 0;
}
  800552:	60e2                	ld	ra,24(sp)
  800554:	6442                	ld	s0,16(sp)
  800556:	64a2                	ld	s1,8(sp)
  800558:	6902                	ld	s2,0(sp)
  80055a:	4501                	li	a0,0
  80055c:	6105                	addi	sp,sp,32
  80055e:	8082                	ret
