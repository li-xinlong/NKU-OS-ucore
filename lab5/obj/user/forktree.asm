
obj/__user_forktree.out:     file format elf64-littleriscv


Disassembly of section .text:

0000000000800020 <_start>:
.text
.globl _start
_start:
    # call user-program function
    call umain
  800020:	0c4000ef          	jal	ra,8000e4 <umain>
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
  80002e:	094000ef          	jal	ra,8000c2 <sys_putc>
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
  80006a:	10c000ef          	jal	ra,800176 <vprintfmt>
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

00000000008000b6 <sys_fork>:
}

int
sys_fork(void) {
    return syscall(SYS_fork);
  8000b6:	4509                	li	a0,2
  8000b8:	bf7d                	j	800076 <syscall>

00000000008000ba <sys_yield>:
    return syscall(SYS_wait, pid, store);
}

int
sys_yield(void) {
    return syscall(SYS_yield);
  8000ba:	4529                	li	a0,10
  8000bc:	bf6d                	j	800076 <syscall>

00000000008000be <sys_getpid>:
    return syscall(SYS_kill, pid);
}

int
sys_getpid(void) {
    return syscall(SYS_getpid);
  8000be:	4549                	li	a0,18
  8000c0:	bf5d                	j	800076 <syscall>

00000000008000c2 <sys_putc>:
}

int
sys_putc(int64_t c) {
  8000c2:	85aa                	mv	a1,a0
    return syscall(SYS_putc, c);
  8000c4:	4579                	li	a0,30
  8000c6:	bf45                	j	800076 <syscall>

00000000008000c8 <exit>:
#include <syscall.h>
#include <stdio.h>
#include <ulib.h>

void
exit(int error_code) {
  8000c8:	1141                	addi	sp,sp,-16
  8000ca:	e406                	sd	ra,8(sp)
    sys_exit(error_code);
  8000cc:	fe5ff0ef          	jal	ra,8000b0 <sys_exit>
    cprintf("BUG: exit failed.\n");
  8000d0:	00000517          	auipc	a0,0x0
  8000d4:	57050513          	addi	a0,a0,1392 # 800640 <main+0x1c>
  8000d8:	f69ff0ef          	jal	ra,800040 <cprintf>
    while (1);
  8000dc:	a001                	j	8000dc <exit+0x14>

00000000008000de <fork>:
}

int
fork(void) {
    return sys_fork();
  8000de:	bfe1                	j	8000b6 <sys_fork>

00000000008000e0 <yield>:
    return sys_wait(pid, store);
}

void
yield(void) {
    sys_yield();
  8000e0:	bfe9                	j	8000ba <sys_yield>

00000000008000e2 <getpid>:
    return sys_kill(pid);
}

int
getpid(void) {
    return sys_getpid();
  8000e2:	bff1                	j	8000be <sys_getpid>

00000000008000e4 <umain>:
#include <ulib.h>

int main(void);

void
umain(void) {
  8000e4:	1141                	addi	sp,sp,-16
  8000e6:	e406                	sd	ra,8(sp)
    int ret = main();
  8000e8:	53c000ef          	jal	ra,800624 <main>
    exit(ret);
  8000ec:	fddff0ef          	jal	ra,8000c8 <exit>

00000000008000f0 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
  8000f0:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  8000f4:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
  8000f6:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  8000fa:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
  8000fc:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
  800100:	f022                	sd	s0,32(sp)
  800102:	ec26                	sd	s1,24(sp)
  800104:	e84a                	sd	s2,16(sp)
  800106:	f406                	sd	ra,40(sp)
  800108:	e44e                	sd	s3,8(sp)
  80010a:	84aa                	mv	s1,a0
  80010c:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  80010e:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
  800112:	2a01                	sext.w	s4,s4
    if (num >= base) {
  800114:	03067e63          	bgeu	a2,a6,800150 <printnum+0x60>
  800118:	89be                	mv	s3,a5
        while (-- width > 0)
  80011a:	00805763          	blez	s0,800128 <printnum+0x38>
  80011e:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
  800120:	85ca                	mv	a1,s2
  800122:	854e                	mv	a0,s3
  800124:	9482                	jalr	s1
        while (-- width > 0)
  800126:	fc65                	bnez	s0,80011e <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  800128:	1a02                	slli	s4,s4,0x20
  80012a:	00000797          	auipc	a5,0x0
  80012e:	52e78793          	addi	a5,a5,1326 # 800658 <main+0x34>
  800132:	020a5a13          	srli	s4,s4,0x20
  800136:	9a3e                	add	s4,s4,a5
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
  800138:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
  80013a:	000a4503          	lbu	a0,0(s4)
}
  80013e:	70a2                	ld	ra,40(sp)
  800140:	69a2                	ld	s3,8(sp)
  800142:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
  800144:	85ca                	mv	a1,s2
  800146:	87a6                	mv	a5,s1
}
  800148:	6942                	ld	s2,16(sp)
  80014a:	64e2                	ld	s1,24(sp)
  80014c:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
  80014e:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
  800150:	03065633          	divu	a2,a2,a6
  800154:	8722                	mv	a4,s0
  800156:	f9bff0ef          	jal	ra,8000f0 <printnum>
  80015a:	b7f9                	j	800128 <printnum+0x38>

000000000080015c <sprintputch>:
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
    b->cnt ++;
  80015c:	499c                	lw	a5,16(a1)
    if (b->buf < b->ebuf) {
  80015e:	6198                	ld	a4,0(a1)
  800160:	6594                	ld	a3,8(a1)
    b->cnt ++;
  800162:	2785                	addiw	a5,a5,1
  800164:	c99c                	sw	a5,16(a1)
    if (b->buf < b->ebuf) {
  800166:	00d77763          	bgeu	a4,a3,800174 <sprintputch+0x18>
        *b->buf ++ = ch;
  80016a:	00170793          	addi	a5,a4,1
  80016e:	e19c                	sd	a5,0(a1)
  800170:	00a70023          	sb	a0,0(a4)
    }
}
  800174:	8082                	ret

0000000000800176 <vprintfmt>:
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  800176:	7119                	addi	sp,sp,-128
  800178:	f4a6                	sd	s1,104(sp)
  80017a:	f0ca                	sd	s2,96(sp)
  80017c:	ecce                	sd	s3,88(sp)
  80017e:	e8d2                	sd	s4,80(sp)
  800180:	e4d6                	sd	s5,72(sp)
  800182:	e0da                	sd	s6,64(sp)
  800184:	fc5e                	sd	s7,56(sp)
  800186:	f06a                	sd	s10,32(sp)
  800188:	fc86                	sd	ra,120(sp)
  80018a:	f8a2                	sd	s0,112(sp)
  80018c:	f862                	sd	s8,48(sp)
  80018e:	f466                	sd	s9,40(sp)
  800190:	ec6e                	sd	s11,24(sp)
  800192:	892a                	mv	s2,a0
  800194:	84ae                	mv	s1,a1
  800196:	8d32                	mv	s10,a2
  800198:	8a36                	mv	s4,a3
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  80019a:	02500993          	li	s3,37
        width = precision = -1;
  80019e:	5b7d                	li	s6,-1
  8001a0:	00000a97          	auipc	s5,0x0
  8001a4:	4eca8a93          	addi	s5,s5,1260 # 80068c <main+0x68>
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8001a8:	00000b97          	auipc	s7,0x0
  8001ac:	700b8b93          	addi	s7,s7,1792 # 8008a8 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001b0:	000d4503          	lbu	a0,0(s10)
  8001b4:	001d0413          	addi	s0,s10,1
  8001b8:	01350a63          	beq	a0,s3,8001cc <vprintfmt+0x56>
            if (ch == '\0') {
  8001bc:	c121                	beqz	a0,8001fc <vprintfmt+0x86>
            putch(ch, putdat);
  8001be:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001c0:	0405                	addi	s0,s0,1
            putch(ch, putdat);
  8001c2:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001c4:	fff44503          	lbu	a0,-1(s0)
  8001c8:	ff351ae3          	bne	a0,s3,8001bc <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
  8001cc:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
  8001d0:	02000793          	li	a5,32
        lflag = altflag = 0;
  8001d4:	4c81                	li	s9,0
  8001d6:	4881                	li	a7,0
        width = precision = -1;
  8001d8:	5c7d                	li	s8,-1
  8001da:	5dfd                	li	s11,-1
  8001dc:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
  8001e0:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
  8001e2:	fdd6059b          	addiw	a1,a2,-35
  8001e6:	0ff5f593          	zext.b	a1,a1
  8001ea:	00140d13          	addi	s10,s0,1
  8001ee:	04b56263          	bltu	a0,a1,800232 <vprintfmt+0xbc>
  8001f2:	058a                	slli	a1,a1,0x2
  8001f4:	95d6                	add	a1,a1,s5
  8001f6:	4194                	lw	a3,0(a1)
  8001f8:	96d6                	add	a3,a3,s5
  8001fa:	8682                	jr	a3
}
  8001fc:	70e6                	ld	ra,120(sp)
  8001fe:	7446                	ld	s0,112(sp)
  800200:	74a6                	ld	s1,104(sp)
  800202:	7906                	ld	s2,96(sp)
  800204:	69e6                	ld	s3,88(sp)
  800206:	6a46                	ld	s4,80(sp)
  800208:	6aa6                	ld	s5,72(sp)
  80020a:	6b06                	ld	s6,64(sp)
  80020c:	7be2                	ld	s7,56(sp)
  80020e:	7c42                	ld	s8,48(sp)
  800210:	7ca2                	ld	s9,40(sp)
  800212:	7d02                	ld	s10,32(sp)
  800214:	6de2                	ld	s11,24(sp)
  800216:	6109                	addi	sp,sp,128
  800218:	8082                	ret
            padc = '0';
  80021a:	87b2                	mv	a5,a2
            goto reswitch;
  80021c:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
  800220:	846a                	mv	s0,s10
  800222:	00140d13          	addi	s10,s0,1
  800226:	fdd6059b          	addiw	a1,a2,-35
  80022a:	0ff5f593          	zext.b	a1,a1
  80022e:	fcb572e3          	bgeu	a0,a1,8001f2 <vprintfmt+0x7c>
            putch('%', putdat);
  800232:	85a6                	mv	a1,s1
  800234:	02500513          	li	a0,37
  800238:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
  80023a:	fff44783          	lbu	a5,-1(s0)
  80023e:	8d22                	mv	s10,s0
  800240:	f73788e3          	beq	a5,s3,8001b0 <vprintfmt+0x3a>
  800244:	ffed4783          	lbu	a5,-2(s10)
  800248:	1d7d                	addi	s10,s10,-1
  80024a:	ff379de3          	bne	a5,s3,800244 <vprintfmt+0xce>
  80024e:	b78d                	j	8001b0 <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
  800250:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
  800254:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
  800258:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
  80025a:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
  80025e:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
  800262:	02d86463          	bltu	a6,a3,80028a <vprintfmt+0x114>
                ch = *fmt;
  800266:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
  80026a:	002c169b          	slliw	a3,s8,0x2
  80026e:	0186873b          	addw	a4,a3,s8
  800272:	0017171b          	slliw	a4,a4,0x1
  800276:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
  800278:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
  80027c:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
  80027e:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
  800282:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
  800286:	fed870e3          	bgeu	a6,a3,800266 <vprintfmt+0xf0>
            if (width < 0)
  80028a:	f40ddce3          	bgez	s11,8001e2 <vprintfmt+0x6c>
                width = precision, precision = -1;
  80028e:	8de2                	mv	s11,s8
  800290:	5c7d                	li	s8,-1
  800292:	bf81                	j	8001e2 <vprintfmt+0x6c>
            if (width < 0)
  800294:	fffdc693          	not	a3,s11
  800298:	96fd                	srai	a3,a3,0x3f
  80029a:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
  80029e:	00144603          	lbu	a2,1(s0)
  8002a2:	2d81                	sext.w	s11,s11
  8002a4:	846a                	mv	s0,s10
            goto reswitch;
  8002a6:	bf35                	j	8001e2 <vprintfmt+0x6c>
            precision = va_arg(ap, int);
  8002a8:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
  8002ac:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
  8002b0:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
  8002b2:	846a                	mv	s0,s10
            goto process_precision;
  8002b4:	bfd9                	j	80028a <vprintfmt+0x114>
    if (lflag >= 2) {
  8002b6:	4705                	li	a4,1
            precision = va_arg(ap, int);
  8002b8:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  8002bc:	01174463          	blt	a4,a7,8002c4 <vprintfmt+0x14e>
    else if (lflag) {
  8002c0:	1a088e63          	beqz	a7,80047c <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
  8002c4:	000a3603          	ld	a2,0(s4)
  8002c8:	46c1                	li	a3,16
  8002ca:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
  8002cc:	2781                	sext.w	a5,a5
  8002ce:	876e                	mv	a4,s11
  8002d0:	85a6                	mv	a1,s1
  8002d2:	854a                	mv	a0,s2
  8002d4:	e1dff0ef          	jal	ra,8000f0 <printnum>
            break;
  8002d8:	bde1                	j	8001b0 <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
  8002da:	000a2503          	lw	a0,0(s4)
  8002de:	85a6                	mv	a1,s1
  8002e0:	0a21                	addi	s4,s4,8
  8002e2:	9902                	jalr	s2
            break;
  8002e4:	b5f1                	j	8001b0 <vprintfmt+0x3a>
    if (lflag >= 2) {
  8002e6:	4705                	li	a4,1
            precision = va_arg(ap, int);
  8002e8:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  8002ec:	01174463          	blt	a4,a7,8002f4 <vprintfmt+0x17e>
    else if (lflag) {
  8002f0:	18088163          	beqz	a7,800472 <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
  8002f4:	000a3603          	ld	a2,0(s4)
  8002f8:	46a9                	li	a3,10
  8002fa:	8a2e                	mv	s4,a1
  8002fc:	bfc1                	j	8002cc <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
  8002fe:	00144603          	lbu	a2,1(s0)
            altflag = 1;
  800302:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
  800304:	846a                	mv	s0,s10
            goto reswitch;
  800306:	bdf1                	j	8001e2 <vprintfmt+0x6c>
            putch(ch, putdat);
  800308:	85a6                	mv	a1,s1
  80030a:	02500513          	li	a0,37
  80030e:	9902                	jalr	s2
            break;
  800310:	b545                	j	8001b0 <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
  800312:	00144603          	lbu	a2,1(s0)
            lflag ++;
  800316:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
  800318:	846a                	mv	s0,s10
            goto reswitch;
  80031a:	b5e1                	j	8001e2 <vprintfmt+0x6c>
    if (lflag >= 2) {
  80031c:	4705                	li	a4,1
            precision = va_arg(ap, int);
  80031e:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  800322:	01174463          	blt	a4,a7,80032a <vprintfmt+0x1b4>
    else if (lflag) {
  800326:	14088163          	beqz	a7,800468 <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
  80032a:	000a3603          	ld	a2,0(s4)
  80032e:	46a1                	li	a3,8
  800330:	8a2e                	mv	s4,a1
  800332:	bf69                	j	8002cc <vprintfmt+0x156>
            putch('0', putdat);
  800334:	03000513          	li	a0,48
  800338:	85a6                	mv	a1,s1
  80033a:	e03e                	sd	a5,0(sp)
  80033c:	9902                	jalr	s2
            putch('x', putdat);
  80033e:	85a6                	mv	a1,s1
  800340:	07800513          	li	a0,120
  800344:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  800346:	0a21                	addi	s4,s4,8
            goto number;
  800348:	6782                	ld	a5,0(sp)
  80034a:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  80034c:	ff8a3603          	ld	a2,-8(s4)
            goto number;
  800350:	bfb5                	j	8002cc <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
  800352:	000a3403          	ld	s0,0(s4)
  800356:	008a0713          	addi	a4,s4,8
  80035a:	e03a                	sd	a4,0(sp)
  80035c:	14040263          	beqz	s0,8004a0 <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
  800360:	0fb05763          	blez	s11,80044e <vprintfmt+0x2d8>
  800364:	02d00693          	li	a3,45
  800368:	0cd79163          	bne	a5,a3,80042a <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80036c:	00044783          	lbu	a5,0(s0)
  800370:	0007851b          	sext.w	a0,a5
  800374:	cf85                	beqz	a5,8003ac <vprintfmt+0x236>
  800376:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
  80037a:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80037e:	000c4563          	bltz	s8,800388 <vprintfmt+0x212>
  800382:	3c7d                	addiw	s8,s8,-1
  800384:	036c0263          	beq	s8,s6,8003a8 <vprintfmt+0x232>
                    putch('?', putdat);
  800388:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
  80038a:	0e0c8e63          	beqz	s9,800486 <vprintfmt+0x310>
  80038e:	3781                	addiw	a5,a5,-32
  800390:	0ef47b63          	bgeu	s0,a5,800486 <vprintfmt+0x310>
                    putch('?', putdat);
  800394:	03f00513          	li	a0,63
  800398:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80039a:	000a4783          	lbu	a5,0(s4)
  80039e:	3dfd                	addiw	s11,s11,-1
  8003a0:	0a05                	addi	s4,s4,1
  8003a2:	0007851b          	sext.w	a0,a5
  8003a6:	ffe1                	bnez	a5,80037e <vprintfmt+0x208>
            for (; width > 0; width --) {
  8003a8:	01b05963          	blez	s11,8003ba <vprintfmt+0x244>
  8003ac:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
  8003ae:	85a6                	mv	a1,s1
  8003b0:	02000513          	li	a0,32
  8003b4:	9902                	jalr	s2
            for (; width > 0; width --) {
  8003b6:	fe0d9be3          	bnez	s11,8003ac <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
  8003ba:	6a02                	ld	s4,0(sp)
  8003bc:	bbd5                	j	8001b0 <vprintfmt+0x3a>
    if (lflag >= 2) {
  8003be:	4705                	li	a4,1
            precision = va_arg(ap, int);
  8003c0:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
  8003c4:	01174463          	blt	a4,a7,8003cc <vprintfmt+0x256>
    else if (lflag) {
  8003c8:	08088d63          	beqz	a7,800462 <vprintfmt+0x2ec>
        return va_arg(*ap, long);
  8003cc:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
  8003d0:	0a044d63          	bltz	s0,80048a <vprintfmt+0x314>
            num = getint(&ap, lflag);
  8003d4:	8622                	mv	a2,s0
  8003d6:	8a66                	mv	s4,s9
  8003d8:	46a9                	li	a3,10
  8003da:	bdcd                	j	8002cc <vprintfmt+0x156>
            err = va_arg(ap, int);
  8003dc:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8003e0:	4761                	li	a4,24
            err = va_arg(ap, int);
  8003e2:	0a21                	addi	s4,s4,8
            if (err < 0) {
  8003e4:	41f7d69b          	sraiw	a3,a5,0x1f
  8003e8:	8fb5                	xor	a5,a5,a3
  8003ea:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8003ee:	02d74163          	blt	a4,a3,800410 <vprintfmt+0x29a>
  8003f2:	00369793          	slli	a5,a3,0x3
  8003f6:	97de                	add	a5,a5,s7
  8003f8:	639c                	ld	a5,0(a5)
  8003fa:	cb99                	beqz	a5,800410 <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
  8003fc:	86be                	mv	a3,a5
  8003fe:	00000617          	auipc	a2,0x0
  800402:	28a60613          	addi	a2,a2,650 # 800688 <main+0x64>
  800406:	85a6                	mv	a1,s1
  800408:	854a                	mv	a0,s2
  80040a:	0ce000ef          	jal	ra,8004d8 <printfmt>
  80040e:	b34d                	j	8001b0 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
  800410:	00000617          	auipc	a2,0x0
  800414:	26860613          	addi	a2,a2,616 # 800678 <main+0x54>
  800418:	85a6                	mv	a1,s1
  80041a:	854a                	mv	a0,s2
  80041c:	0bc000ef          	jal	ra,8004d8 <printfmt>
  800420:	bb41                	j	8001b0 <vprintfmt+0x3a>
                p = "(null)";
  800422:	00000417          	auipc	s0,0x0
  800426:	24e40413          	addi	s0,s0,590 # 800670 <main+0x4c>
                for (width -= strnlen(p, precision); width > 0; width --) {
  80042a:	85e2                	mv	a1,s8
  80042c:	8522                	mv	a0,s0
  80042e:	e43e                	sd	a5,8(sp)
  800430:	128000ef          	jal	ra,800558 <strnlen>
  800434:	40ad8dbb          	subw	s11,s11,a0
  800438:	01b05b63          	blez	s11,80044e <vprintfmt+0x2d8>
                    putch(padc, putdat);
  80043c:	67a2                	ld	a5,8(sp)
  80043e:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
  800442:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
  800444:	85a6                	mv	a1,s1
  800446:	8552                	mv	a0,s4
  800448:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
  80044a:	fe0d9ce3          	bnez	s11,800442 <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80044e:	00044783          	lbu	a5,0(s0)
  800452:	00140a13          	addi	s4,s0,1
  800456:	0007851b          	sext.w	a0,a5
  80045a:	d3a5                	beqz	a5,8003ba <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
  80045c:	05e00413          	li	s0,94
  800460:	bf39                	j	80037e <vprintfmt+0x208>
        return va_arg(*ap, int);
  800462:	000a2403          	lw	s0,0(s4)
  800466:	b7ad                	j	8003d0 <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
  800468:	000a6603          	lwu	a2,0(s4)
  80046c:	46a1                	li	a3,8
  80046e:	8a2e                	mv	s4,a1
  800470:	bdb1                	j	8002cc <vprintfmt+0x156>
  800472:	000a6603          	lwu	a2,0(s4)
  800476:	46a9                	li	a3,10
  800478:	8a2e                	mv	s4,a1
  80047a:	bd89                	j	8002cc <vprintfmt+0x156>
  80047c:	000a6603          	lwu	a2,0(s4)
  800480:	46c1                	li	a3,16
  800482:	8a2e                	mv	s4,a1
  800484:	b5a1                	j	8002cc <vprintfmt+0x156>
                    putch(ch, putdat);
  800486:	9902                	jalr	s2
  800488:	bf09                	j	80039a <vprintfmt+0x224>
                putch('-', putdat);
  80048a:	85a6                	mv	a1,s1
  80048c:	02d00513          	li	a0,45
  800490:	e03e                	sd	a5,0(sp)
  800492:	9902                	jalr	s2
                num = -(long long)num;
  800494:	6782                	ld	a5,0(sp)
  800496:	8a66                	mv	s4,s9
  800498:	40800633          	neg	a2,s0
  80049c:	46a9                	li	a3,10
  80049e:	b53d                	j	8002cc <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
  8004a0:	03b05163          	blez	s11,8004c2 <vprintfmt+0x34c>
  8004a4:	02d00693          	li	a3,45
  8004a8:	f6d79de3          	bne	a5,a3,800422 <vprintfmt+0x2ac>
                p = "(null)";
  8004ac:	00000417          	auipc	s0,0x0
  8004b0:	1c440413          	addi	s0,s0,452 # 800670 <main+0x4c>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8004b4:	02800793          	li	a5,40
  8004b8:	02800513          	li	a0,40
  8004bc:	00140a13          	addi	s4,s0,1
  8004c0:	bd6d                	j	80037a <vprintfmt+0x204>
  8004c2:	00000a17          	auipc	s4,0x0
  8004c6:	1afa0a13          	addi	s4,s4,431 # 800671 <main+0x4d>
  8004ca:	02800513          	li	a0,40
  8004ce:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
  8004d2:	05e00413          	li	s0,94
  8004d6:	b565                	j	80037e <vprintfmt+0x208>

00000000008004d8 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8004d8:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
  8004da:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8004de:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
  8004e0:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8004e2:	ec06                	sd	ra,24(sp)
  8004e4:	f83a                	sd	a4,48(sp)
  8004e6:	fc3e                	sd	a5,56(sp)
  8004e8:	e0c2                	sd	a6,64(sp)
  8004ea:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  8004ec:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
  8004ee:	c89ff0ef          	jal	ra,800176 <vprintfmt>
}
  8004f2:	60e2                	ld	ra,24(sp)
  8004f4:	6161                	addi	sp,sp,80
  8004f6:	8082                	ret

00000000008004f8 <snprintf>:
 * @str:        the buffer to place the result into
 * @size:       the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
  8004f8:	711d                	addi	sp,sp,-96
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
    struct sprintbuf b = {str, str + size - 1, 0};
  8004fa:	15fd                	addi	a1,a1,-1
    va_start(ap, fmt);
  8004fc:	03810313          	addi	t1,sp,56
    struct sprintbuf b = {str, str + size - 1, 0};
  800500:	95aa                	add	a1,a1,a0
snprintf(char *str, size_t size, const char *fmt, ...) {
  800502:	f406                	sd	ra,40(sp)
  800504:	fc36                	sd	a3,56(sp)
  800506:	e0ba                	sd	a4,64(sp)
  800508:	e4be                	sd	a5,72(sp)
  80050a:	e8c2                	sd	a6,80(sp)
  80050c:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
  80050e:	e01a                	sd	t1,0(sp)
    struct sprintbuf b = {str, str + size - 1, 0};
  800510:	e42a                	sd	a0,8(sp)
  800512:	e82e                	sd	a1,16(sp)
  800514:	cc02                	sw	zero,24(sp)
    if (str == NULL || b.buf > b.ebuf) {
  800516:	c115                	beqz	a0,80053a <snprintf+0x42>
  800518:	02a5e163          	bltu	a1,a0,80053a <snprintf+0x42>
        return -E_INVAL;
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
  80051c:	00000517          	auipc	a0,0x0
  800520:	c4050513          	addi	a0,a0,-960 # 80015c <sprintputch>
  800524:	869a                	mv	a3,t1
  800526:	002c                	addi	a1,sp,8
  800528:	c4fff0ef          	jal	ra,800176 <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
  80052c:	67a2                	ld	a5,8(sp)
  80052e:	00078023          	sb	zero,0(a5)
    return b.cnt;
  800532:	4562                	lw	a0,24(sp)
}
  800534:	70a2                	ld	ra,40(sp)
  800536:	6125                	addi	sp,sp,96
  800538:	8082                	ret
        return -E_INVAL;
  80053a:	5575                	li	a0,-3
  80053c:	bfe5                	j	800534 <snprintf+0x3c>

000000000080053e <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
  80053e:	00054783          	lbu	a5,0(a0)
strlen(const char *s) {
  800542:	872a                	mv	a4,a0
    size_t cnt = 0;
  800544:	4501                	li	a0,0
    while (*s ++ != '\0') {
  800546:	cb81                	beqz	a5,800556 <strlen+0x18>
        cnt ++;
  800548:	0505                	addi	a0,a0,1
    while (*s ++ != '\0') {
  80054a:	00a707b3          	add	a5,a4,a0
  80054e:	0007c783          	lbu	a5,0(a5)
  800552:	fbfd                	bnez	a5,800548 <strlen+0xa>
  800554:	8082                	ret
    }
    return cnt;
}
  800556:	8082                	ret

0000000000800558 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
  800558:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
  80055a:	e589                	bnez	a1,800564 <strnlen+0xc>
  80055c:	a811                	j	800570 <strnlen+0x18>
        cnt ++;
  80055e:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
  800560:	00f58863          	beq	a1,a5,800570 <strnlen+0x18>
  800564:	00f50733          	add	a4,a0,a5
  800568:	00074703          	lbu	a4,0(a4)
  80056c:	fb6d                	bnez	a4,80055e <strnlen+0x6>
  80056e:	85be                	mv	a1,a5
    }
    return cnt;
}
  800570:	852e                	mv	a0,a1
  800572:	8082                	ret

0000000000800574 <forktree>:
        exit(0);
    }
}

void
forktree(const char *cur) {
  800574:	1101                	addi	sp,sp,-32
  800576:	ec06                	sd	ra,24(sp)
  800578:	e822                	sd	s0,16(sp)
  80057a:	842a                	mv	s0,a0
    cprintf("%04x: I am '%s'\n", getpid(), cur);
  80057c:	b67ff0ef          	jal	ra,8000e2 <getpid>
  800580:	85aa                	mv	a1,a0
  800582:	8622                	mv	a2,s0
  800584:	00000517          	auipc	a0,0x0
  800588:	3ec50513          	addi	a0,a0,1004 # 800970 <error_string+0xc8>
  80058c:	ab5ff0ef          	jal	ra,800040 <cprintf>

    forkchild(cur, '0');
  800590:	03000593          	li	a1,48
  800594:	8522                	mv	a0,s0
  800596:	044000ef          	jal	ra,8005da <forkchild>
    if (strlen(cur) >= DEPTH)
  80059a:	8522                	mv	a0,s0
  80059c:	fa3ff0ef          	jal	ra,80053e <strlen>
  8005a0:	478d                	li	a5,3
  8005a2:	00a7f663          	bgeu	a5,a0,8005ae <forktree+0x3a>
    forkchild(cur, '1');
}
  8005a6:	60e2                	ld	ra,24(sp)
  8005a8:	6442                	ld	s0,16(sp)
  8005aa:	6105                	addi	sp,sp,32
  8005ac:	8082                	ret
    snprintf(nxt, DEPTH + 1, "%s%c", cur, branch);
  8005ae:	03100713          	li	a4,49
  8005b2:	86a2                	mv	a3,s0
  8005b4:	00000617          	auipc	a2,0x0
  8005b8:	3d460613          	addi	a2,a2,980 # 800988 <error_string+0xe0>
  8005bc:	4595                	li	a1,5
  8005be:	0028                	addi	a0,sp,8
  8005c0:	f39ff0ef          	jal	ra,8004f8 <snprintf>
    if (fork() == 0) {
  8005c4:	b1bff0ef          	jal	ra,8000de <fork>
  8005c8:	fd79                	bnez	a0,8005a6 <forktree+0x32>
        forktree(nxt);
  8005ca:	0028                	addi	a0,sp,8
  8005cc:	fa9ff0ef          	jal	ra,800574 <forktree>
        yield();
  8005d0:	b11ff0ef          	jal	ra,8000e0 <yield>
        exit(0);
  8005d4:	4501                	li	a0,0
  8005d6:	af3ff0ef          	jal	ra,8000c8 <exit>

00000000008005da <forkchild>:
forkchild(const char *cur, char branch) {
  8005da:	7179                	addi	sp,sp,-48
  8005dc:	f022                	sd	s0,32(sp)
  8005de:	ec26                	sd	s1,24(sp)
  8005e0:	f406                	sd	ra,40(sp)
  8005e2:	842a                	mv	s0,a0
  8005e4:	84ae                	mv	s1,a1
    if (strlen(cur) >= DEPTH)
  8005e6:	f59ff0ef          	jal	ra,80053e <strlen>
  8005ea:	478d                	li	a5,3
  8005ec:	00a7f763          	bgeu	a5,a0,8005fa <forkchild+0x20>
}
  8005f0:	70a2                	ld	ra,40(sp)
  8005f2:	7402                	ld	s0,32(sp)
  8005f4:	64e2                	ld	s1,24(sp)
  8005f6:	6145                	addi	sp,sp,48
  8005f8:	8082                	ret
    snprintf(nxt, DEPTH + 1, "%s%c", cur, branch);
  8005fa:	8726                	mv	a4,s1
  8005fc:	86a2                	mv	a3,s0
  8005fe:	00000617          	auipc	a2,0x0
  800602:	38a60613          	addi	a2,a2,906 # 800988 <error_string+0xe0>
  800606:	4595                	li	a1,5
  800608:	0028                	addi	a0,sp,8
  80060a:	eefff0ef          	jal	ra,8004f8 <snprintf>
    if (fork() == 0) {
  80060e:	ad1ff0ef          	jal	ra,8000de <fork>
  800612:	fd79                	bnez	a0,8005f0 <forkchild+0x16>
        forktree(nxt);
  800614:	0028                	addi	a0,sp,8
  800616:	f5fff0ef          	jal	ra,800574 <forktree>
        yield();
  80061a:	ac7ff0ef          	jal	ra,8000e0 <yield>
        exit(0);
  80061e:	4501                	li	a0,0
  800620:	aa9ff0ef          	jal	ra,8000c8 <exit>

0000000000800624 <main>:

int
main(void) {
  800624:	1141                	addi	sp,sp,-16
    forktree("");
  800626:	00000517          	auipc	a0,0x0
  80062a:	35a50513          	addi	a0,a0,858 # 800980 <error_string+0xd8>
main(void) {
  80062e:	e406                	sd	ra,8(sp)
    forktree("");
  800630:	f45ff0ef          	jal	ra,800574 <forktree>
    return 0;
}
  800634:	60a2                	ld	ra,8(sp)
  800636:	4501                	li	a0,0
  800638:	0141                	addi	sp,sp,16
  80063a:	8082                	ret
