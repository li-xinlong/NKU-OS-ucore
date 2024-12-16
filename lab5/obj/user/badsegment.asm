
obj/__user_badsegment.out:     file format elf64-littleriscv


Disassembly of section .text:

0000000000800020 <_start>:
.text
.globl _start
_start:
    # call user-program function
    call umain
  800020:	114000ef          	jal	ra,800134 <umain>
1:  j 1b
  800024:	a001                	j	800024 <_start+0x4>

0000000000800026 <__panic>:
#include <stdio.h>
#include <ulib.h>
#include <error.h>

void
__panic(const char *file, int line, const char *fmt, ...) {
  800026:	715d                	addi	sp,sp,-80
  800028:	8e2e                	mv	t3,a1
  80002a:	e822                	sd	s0,16(sp)
    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
    cprintf("user panic at %s:%d:\n    ", file, line);
  80002c:	85aa                	mv	a1,a0
__panic(const char *file, int line, const char *fmt, ...) {
  80002e:	8432                	mv	s0,a2
  800030:	fc3e                	sd	a5,56(sp)
    cprintf("user panic at %s:%d:\n    ", file, line);
  800032:	8672                	mv	a2,t3
    va_start(ap, fmt);
  800034:	103c                	addi	a5,sp,40
    cprintf("user panic at %s:%d:\n    ", file, line);
  800036:	00000517          	auipc	a0,0x0
  80003a:	53250513          	addi	a0,a0,1330 # 800568 <main+0x1e>
__panic(const char *file, int line, const char *fmt, ...) {
  80003e:	ec06                	sd	ra,24(sp)
  800040:	f436                	sd	a3,40(sp)
  800042:	f83a                	sd	a4,48(sp)
  800044:	e0c2                	sd	a6,64(sp)
  800046:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  800048:	e43e                	sd	a5,8(sp)
    cprintf("user panic at %s:%d:\n    ", file, line);
  80004a:	058000ef          	jal	ra,8000a2 <cprintf>
    vcprintf(fmt, ap);
  80004e:	65a2                	ld	a1,8(sp)
  800050:	8522                	mv	a0,s0
  800052:	030000ef          	jal	ra,800082 <vcprintf>
    cprintf("\n");
  800056:	00000517          	auipc	a0,0x0
  80005a:	53250513          	addi	a0,a0,1330 # 800588 <main+0x3e>
  80005e:	044000ef          	jal	ra,8000a2 <cprintf>
    va_end(ap);
    exit(-E_PANIC);
  800062:	5559                	li	a0,-10
  800064:	0ba000ef          	jal	ra,80011e <exit>

0000000000800068 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
  800068:	1141                	addi	sp,sp,-16
  80006a:	e022                	sd	s0,0(sp)
  80006c:	e406                	sd	ra,8(sp)
  80006e:	842e                	mv	s0,a1
    sys_putc(c);
  800070:	0a8000ef          	jal	ra,800118 <sys_putc>
    (*cnt) ++;
  800074:	401c                	lw	a5,0(s0)
}
  800076:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
  800078:	2785                	addiw	a5,a5,1
  80007a:	c01c                	sw	a5,0(s0)
}
  80007c:	6402                	ld	s0,0(sp)
  80007e:	0141                	addi	sp,sp,16
  800080:	8082                	ret

0000000000800082 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
  800082:	1101                	addi	sp,sp,-32
  800084:	862a                	mv	a2,a0
  800086:	86ae                	mv	a3,a1
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  800088:	00000517          	auipc	a0,0x0
  80008c:	fe050513          	addi	a0,a0,-32 # 800068 <cputch>
  800090:	006c                	addi	a1,sp,12
vcprintf(const char *fmt, va_list ap) {
  800092:	ec06                	sd	ra,24(sp)
    int cnt = 0;
  800094:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  800096:	116000ef          	jal	ra,8001ac <vprintfmt>
    return cnt;
}
  80009a:	60e2                	ld	ra,24(sp)
  80009c:	4532                	lw	a0,12(sp)
  80009e:	6105                	addi	sp,sp,32
  8000a0:	8082                	ret

00000000008000a2 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
  8000a2:	711d                	addi	sp,sp,-96
    va_list ap;

    va_start(ap, fmt);
  8000a4:	02810313          	addi	t1,sp,40
cprintf(const char *fmt, ...) {
  8000a8:	8e2a                	mv	t3,a0
  8000aa:	f42e                	sd	a1,40(sp)
  8000ac:	f832                	sd	a2,48(sp)
  8000ae:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  8000b0:	00000517          	auipc	a0,0x0
  8000b4:	fb850513          	addi	a0,a0,-72 # 800068 <cputch>
  8000b8:	004c                	addi	a1,sp,4
  8000ba:	869a                	mv	a3,t1
  8000bc:	8672                	mv	a2,t3
cprintf(const char *fmt, ...) {
  8000be:	ec06                	sd	ra,24(sp)
  8000c0:	e0ba                	sd	a4,64(sp)
  8000c2:	e4be                	sd	a5,72(sp)
  8000c4:	e8c2                	sd	a6,80(sp)
  8000c6:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
  8000c8:	e41a                	sd	t1,8(sp)
    int cnt = 0;
  8000ca:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  8000cc:	0e0000ef          	jal	ra,8001ac <vprintfmt>
    int cnt = vcprintf(fmt, ap);
    va_end(ap);

    return cnt;
}
  8000d0:	60e2                	ld	ra,24(sp)
  8000d2:	4512                	lw	a0,4(sp)
  8000d4:	6125                	addi	sp,sp,96
  8000d6:	8082                	ret

00000000008000d8 <syscall>:
#include <syscall.h>

#define MAX_ARGS            5

static inline int
syscall(int64_t num, ...) {
  8000d8:	7175                	addi	sp,sp,-144
  8000da:	f8ba                	sd	a4,112(sp)
    va_list ap;
    va_start(ap, num);
    uint64_t a[MAX_ARGS];
    int i, ret;
    for (i = 0; i < MAX_ARGS; i ++) {
        a[i] = va_arg(ap, uint64_t);
  8000dc:	e0ba                	sd	a4,64(sp)
  8000de:	0118                	addi	a4,sp,128
syscall(int64_t num, ...) {
  8000e0:	e42a                	sd	a0,8(sp)
  8000e2:	ecae                	sd	a1,88(sp)
  8000e4:	f0b2                	sd	a2,96(sp)
  8000e6:	f4b6                	sd	a3,104(sp)
  8000e8:	fcbe                	sd	a5,120(sp)
  8000ea:	e142                	sd	a6,128(sp)
  8000ec:	e546                	sd	a7,136(sp)
        a[i] = va_arg(ap, uint64_t);
  8000ee:	f42e                	sd	a1,40(sp)
  8000f0:	f832                	sd	a2,48(sp)
  8000f2:	fc36                	sd	a3,56(sp)
  8000f4:	f03a                	sd	a4,32(sp)
  8000f6:	e4be                	sd	a5,72(sp)
    }
    va_end(ap);

    asm volatile (
  8000f8:	6522                	ld	a0,8(sp)
  8000fa:	75a2                	ld	a1,40(sp)
  8000fc:	7642                	ld	a2,48(sp)
  8000fe:	76e2                	ld	a3,56(sp)
  800100:	6706                	ld	a4,64(sp)
  800102:	67a6                	ld	a5,72(sp)
  800104:	00000073          	ecall
  800108:	00a13e23          	sd	a0,28(sp)
        "sd a0, %0"
        : "=m" (ret)
        : "m"(num), "m"(a[0]), "m"(a[1]), "m"(a[2]), "m"(a[3]), "m"(a[4])
        :"memory");
    return ret;
}
  80010c:	4572                	lw	a0,28(sp)
  80010e:	6149                	addi	sp,sp,144
  800110:	8082                	ret

0000000000800112 <sys_exit>:

int
sys_exit(int64_t error_code) {
  800112:	85aa                	mv	a1,a0
    return syscall(SYS_exit, error_code);
  800114:	4505                	li	a0,1
  800116:	b7c9                	j	8000d8 <syscall>

0000000000800118 <sys_putc>:
sys_getpid(void) {
    return syscall(SYS_getpid);
}

int
sys_putc(int64_t c) {
  800118:	85aa                	mv	a1,a0
    return syscall(SYS_putc, c);
  80011a:	4579                	li	a0,30
  80011c:	bf75                	j	8000d8 <syscall>

000000000080011e <exit>:
#include <syscall.h>
#include <stdio.h>
#include <ulib.h>

void
exit(int error_code) {
  80011e:	1141                	addi	sp,sp,-16
  800120:	e406                	sd	ra,8(sp)
    sys_exit(error_code);
  800122:	ff1ff0ef          	jal	ra,800112 <sys_exit>
    cprintf("BUG: exit failed.\n");
  800126:	00000517          	auipc	a0,0x0
  80012a:	46a50513          	addi	a0,a0,1130 # 800590 <main+0x46>
  80012e:	f75ff0ef          	jal	ra,8000a2 <cprintf>
    while (1);
  800132:	a001                	j	800132 <exit+0x14>

0000000000800134 <umain>:
#include <ulib.h>

int main(void);

void
umain(void) {
  800134:	1141                	addi	sp,sp,-16
  800136:	e406                	sd	ra,8(sp)
    int ret = main();
  800138:	412000ef          	jal	ra,80054a <main>
    exit(ret);
  80013c:	fe3ff0ef          	jal	ra,80011e <exit>

0000000000800140 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
  800140:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  800144:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
  800146:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  80014a:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
  80014c:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
  800150:	f022                	sd	s0,32(sp)
  800152:	ec26                	sd	s1,24(sp)
  800154:	e84a                	sd	s2,16(sp)
  800156:	f406                	sd	ra,40(sp)
  800158:	e44e                	sd	s3,8(sp)
  80015a:	84aa                	mv	s1,a0
  80015c:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  80015e:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
  800162:	2a01                	sext.w	s4,s4
    if (num >= base) {
  800164:	03067e63          	bgeu	a2,a6,8001a0 <printnum+0x60>
  800168:	89be                	mv	s3,a5
        while (-- width > 0)
  80016a:	00805763          	blez	s0,800178 <printnum+0x38>
  80016e:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
  800170:	85ca                	mv	a1,s2
  800172:	854e                	mv	a0,s3
  800174:	9482                	jalr	s1
        while (-- width > 0)
  800176:	fc65                	bnez	s0,80016e <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  800178:	1a02                	slli	s4,s4,0x20
  80017a:	00000797          	auipc	a5,0x0
  80017e:	42e78793          	addi	a5,a5,1070 # 8005a8 <main+0x5e>
  800182:	020a5a13          	srli	s4,s4,0x20
  800186:	9a3e                	add	s4,s4,a5
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
  800188:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
  80018a:	000a4503          	lbu	a0,0(s4)
}
  80018e:	70a2                	ld	ra,40(sp)
  800190:	69a2                	ld	s3,8(sp)
  800192:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
  800194:	85ca                	mv	a1,s2
  800196:	87a6                	mv	a5,s1
}
  800198:	6942                	ld	s2,16(sp)
  80019a:	64e2                	ld	s1,24(sp)
  80019c:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
  80019e:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
  8001a0:	03065633          	divu	a2,a2,a6
  8001a4:	8722                	mv	a4,s0
  8001a6:	f9bff0ef          	jal	ra,800140 <printnum>
  8001aa:	b7f9                	j	800178 <printnum+0x38>

00000000008001ac <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  8001ac:	7119                	addi	sp,sp,-128
  8001ae:	f4a6                	sd	s1,104(sp)
  8001b0:	f0ca                	sd	s2,96(sp)
  8001b2:	ecce                	sd	s3,88(sp)
  8001b4:	e8d2                	sd	s4,80(sp)
  8001b6:	e4d6                	sd	s5,72(sp)
  8001b8:	e0da                	sd	s6,64(sp)
  8001ba:	fc5e                	sd	s7,56(sp)
  8001bc:	f06a                	sd	s10,32(sp)
  8001be:	fc86                	sd	ra,120(sp)
  8001c0:	f8a2                	sd	s0,112(sp)
  8001c2:	f862                	sd	s8,48(sp)
  8001c4:	f466                	sd	s9,40(sp)
  8001c6:	ec6e                	sd	s11,24(sp)
  8001c8:	892a                	mv	s2,a0
  8001ca:	84ae                	mv	s1,a1
  8001cc:	8d32                	mv	s10,a2
  8001ce:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001d0:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
  8001d4:	5b7d                	li	s6,-1
  8001d6:	00000a97          	auipc	s5,0x0
  8001da:	406a8a93          	addi	s5,s5,1030 # 8005dc <main+0x92>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8001de:	00000b97          	auipc	s7,0x0
  8001e2:	61ab8b93          	addi	s7,s7,1562 # 8007f8 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001e6:	000d4503          	lbu	a0,0(s10)
  8001ea:	001d0413          	addi	s0,s10,1
  8001ee:	01350a63          	beq	a0,s3,800202 <vprintfmt+0x56>
            if (ch == '\0') {
  8001f2:	c121                	beqz	a0,800232 <vprintfmt+0x86>
            putch(ch, putdat);
  8001f4:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001f6:	0405                	addi	s0,s0,1
            putch(ch, putdat);
  8001f8:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001fa:	fff44503          	lbu	a0,-1(s0)
  8001fe:	ff351ae3          	bne	a0,s3,8001f2 <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
  800202:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
  800206:	02000793          	li	a5,32
        lflag = altflag = 0;
  80020a:	4c81                	li	s9,0
  80020c:	4881                	li	a7,0
        width = precision = -1;
  80020e:	5c7d                	li	s8,-1
  800210:	5dfd                	li	s11,-1
  800212:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
  800216:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
  800218:	fdd6059b          	addiw	a1,a2,-35
  80021c:	0ff5f593          	zext.b	a1,a1
  800220:	00140d13          	addi	s10,s0,1
  800224:	04b56263          	bltu	a0,a1,800268 <vprintfmt+0xbc>
  800228:	058a                	slli	a1,a1,0x2
  80022a:	95d6                	add	a1,a1,s5
  80022c:	4194                	lw	a3,0(a1)
  80022e:	96d6                	add	a3,a3,s5
  800230:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
  800232:	70e6                	ld	ra,120(sp)
  800234:	7446                	ld	s0,112(sp)
  800236:	74a6                	ld	s1,104(sp)
  800238:	7906                	ld	s2,96(sp)
  80023a:	69e6                	ld	s3,88(sp)
  80023c:	6a46                	ld	s4,80(sp)
  80023e:	6aa6                	ld	s5,72(sp)
  800240:	6b06                	ld	s6,64(sp)
  800242:	7be2                	ld	s7,56(sp)
  800244:	7c42                	ld	s8,48(sp)
  800246:	7ca2                	ld	s9,40(sp)
  800248:	7d02                	ld	s10,32(sp)
  80024a:	6de2                	ld	s11,24(sp)
  80024c:	6109                	addi	sp,sp,128
  80024e:	8082                	ret
            padc = '0';
  800250:	87b2                	mv	a5,a2
            goto reswitch;
  800252:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
  800256:	846a                	mv	s0,s10
  800258:	00140d13          	addi	s10,s0,1
  80025c:	fdd6059b          	addiw	a1,a2,-35
  800260:	0ff5f593          	zext.b	a1,a1
  800264:	fcb572e3          	bgeu	a0,a1,800228 <vprintfmt+0x7c>
            putch('%', putdat);
  800268:	85a6                	mv	a1,s1
  80026a:	02500513          	li	a0,37
  80026e:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
  800270:	fff44783          	lbu	a5,-1(s0)
  800274:	8d22                	mv	s10,s0
  800276:	f73788e3          	beq	a5,s3,8001e6 <vprintfmt+0x3a>
  80027a:	ffed4783          	lbu	a5,-2(s10)
  80027e:	1d7d                	addi	s10,s10,-1
  800280:	ff379de3          	bne	a5,s3,80027a <vprintfmt+0xce>
  800284:	b78d                	j	8001e6 <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
  800286:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
  80028a:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
  80028e:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
  800290:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
  800294:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
  800298:	02d86463          	bltu	a6,a3,8002c0 <vprintfmt+0x114>
                ch = *fmt;
  80029c:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
  8002a0:	002c169b          	slliw	a3,s8,0x2
  8002a4:	0186873b          	addw	a4,a3,s8
  8002a8:	0017171b          	slliw	a4,a4,0x1
  8002ac:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
  8002ae:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
  8002b2:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
  8002b4:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
  8002b8:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
  8002bc:	fed870e3          	bgeu	a6,a3,80029c <vprintfmt+0xf0>
            if (width < 0)
  8002c0:	f40ddce3          	bgez	s11,800218 <vprintfmt+0x6c>
                width = precision, precision = -1;
  8002c4:	8de2                	mv	s11,s8
  8002c6:	5c7d                	li	s8,-1
  8002c8:	bf81                	j	800218 <vprintfmt+0x6c>
            if (width < 0)
  8002ca:	fffdc693          	not	a3,s11
  8002ce:	96fd                	srai	a3,a3,0x3f
  8002d0:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
  8002d4:	00144603          	lbu	a2,1(s0)
  8002d8:	2d81                	sext.w	s11,s11
  8002da:	846a                	mv	s0,s10
            goto reswitch;
  8002dc:	bf35                	j	800218 <vprintfmt+0x6c>
            precision = va_arg(ap, int);
  8002de:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
  8002e2:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
  8002e6:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
  8002e8:	846a                	mv	s0,s10
            goto process_precision;
  8002ea:	bfd9                	j	8002c0 <vprintfmt+0x114>
    if (lflag >= 2) {
  8002ec:	4705                	li	a4,1
            precision = va_arg(ap, int);
  8002ee:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  8002f2:	01174463          	blt	a4,a7,8002fa <vprintfmt+0x14e>
    else if (lflag) {
  8002f6:	1a088e63          	beqz	a7,8004b2 <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
  8002fa:	000a3603          	ld	a2,0(s4)
  8002fe:	46c1                	li	a3,16
  800300:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
  800302:	2781                	sext.w	a5,a5
  800304:	876e                	mv	a4,s11
  800306:	85a6                	mv	a1,s1
  800308:	854a                	mv	a0,s2
  80030a:	e37ff0ef          	jal	ra,800140 <printnum>
            break;
  80030e:	bde1                	j	8001e6 <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
  800310:	000a2503          	lw	a0,0(s4)
  800314:	85a6                	mv	a1,s1
  800316:	0a21                	addi	s4,s4,8
  800318:	9902                	jalr	s2
            break;
  80031a:	b5f1                	j	8001e6 <vprintfmt+0x3a>
    if (lflag >= 2) {
  80031c:	4705                	li	a4,1
            precision = va_arg(ap, int);
  80031e:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  800322:	01174463          	blt	a4,a7,80032a <vprintfmt+0x17e>
    else if (lflag) {
  800326:	18088163          	beqz	a7,8004a8 <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
  80032a:	000a3603          	ld	a2,0(s4)
  80032e:	46a9                	li	a3,10
  800330:	8a2e                	mv	s4,a1
  800332:	bfc1                	j	800302 <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
  800334:	00144603          	lbu	a2,1(s0)
            altflag = 1;
  800338:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
  80033a:	846a                	mv	s0,s10
            goto reswitch;
  80033c:	bdf1                	j	800218 <vprintfmt+0x6c>
            putch(ch, putdat);
  80033e:	85a6                	mv	a1,s1
  800340:	02500513          	li	a0,37
  800344:	9902                	jalr	s2
            break;
  800346:	b545                	j	8001e6 <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
  800348:	00144603          	lbu	a2,1(s0)
            lflag ++;
  80034c:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
  80034e:	846a                	mv	s0,s10
            goto reswitch;
  800350:	b5e1                	j	800218 <vprintfmt+0x6c>
    if (lflag >= 2) {
  800352:	4705                	li	a4,1
            precision = va_arg(ap, int);
  800354:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  800358:	01174463          	blt	a4,a7,800360 <vprintfmt+0x1b4>
    else if (lflag) {
  80035c:	14088163          	beqz	a7,80049e <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
  800360:	000a3603          	ld	a2,0(s4)
  800364:	46a1                	li	a3,8
  800366:	8a2e                	mv	s4,a1
  800368:	bf69                	j	800302 <vprintfmt+0x156>
            putch('0', putdat);
  80036a:	03000513          	li	a0,48
  80036e:	85a6                	mv	a1,s1
  800370:	e03e                	sd	a5,0(sp)
  800372:	9902                	jalr	s2
            putch('x', putdat);
  800374:	85a6                	mv	a1,s1
  800376:	07800513          	li	a0,120
  80037a:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  80037c:	0a21                	addi	s4,s4,8
            goto number;
  80037e:	6782                	ld	a5,0(sp)
  800380:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  800382:	ff8a3603          	ld	a2,-8(s4)
            goto number;
  800386:	bfb5                	j	800302 <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
  800388:	000a3403          	ld	s0,0(s4)
  80038c:	008a0713          	addi	a4,s4,8
  800390:	e03a                	sd	a4,0(sp)
  800392:	14040263          	beqz	s0,8004d6 <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
  800396:	0fb05763          	blez	s11,800484 <vprintfmt+0x2d8>
  80039a:	02d00693          	li	a3,45
  80039e:	0cd79163          	bne	a5,a3,800460 <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8003a2:	00044783          	lbu	a5,0(s0)
  8003a6:	0007851b          	sext.w	a0,a5
  8003aa:	cf85                	beqz	a5,8003e2 <vprintfmt+0x236>
  8003ac:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
  8003b0:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8003b4:	000c4563          	bltz	s8,8003be <vprintfmt+0x212>
  8003b8:	3c7d                	addiw	s8,s8,-1
  8003ba:	036c0263          	beq	s8,s6,8003de <vprintfmt+0x232>
                    putch('?', putdat);
  8003be:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
  8003c0:	0e0c8e63          	beqz	s9,8004bc <vprintfmt+0x310>
  8003c4:	3781                	addiw	a5,a5,-32
  8003c6:	0ef47b63          	bgeu	s0,a5,8004bc <vprintfmt+0x310>
                    putch('?', putdat);
  8003ca:	03f00513          	li	a0,63
  8003ce:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8003d0:	000a4783          	lbu	a5,0(s4)
  8003d4:	3dfd                	addiw	s11,s11,-1
  8003d6:	0a05                	addi	s4,s4,1
  8003d8:	0007851b          	sext.w	a0,a5
  8003dc:	ffe1                	bnez	a5,8003b4 <vprintfmt+0x208>
            for (; width > 0; width --) {
  8003de:	01b05963          	blez	s11,8003f0 <vprintfmt+0x244>
  8003e2:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
  8003e4:	85a6                	mv	a1,s1
  8003e6:	02000513          	li	a0,32
  8003ea:	9902                	jalr	s2
            for (; width > 0; width --) {
  8003ec:	fe0d9be3          	bnez	s11,8003e2 <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
  8003f0:	6a02                	ld	s4,0(sp)
  8003f2:	bbd5                	j	8001e6 <vprintfmt+0x3a>
    if (lflag >= 2) {
  8003f4:	4705                	li	a4,1
            precision = va_arg(ap, int);
  8003f6:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
  8003fa:	01174463          	blt	a4,a7,800402 <vprintfmt+0x256>
    else if (lflag) {
  8003fe:	08088d63          	beqz	a7,800498 <vprintfmt+0x2ec>
        return va_arg(*ap, long);
  800402:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
  800406:	0a044d63          	bltz	s0,8004c0 <vprintfmt+0x314>
            num = getint(&ap, lflag);
  80040a:	8622                	mv	a2,s0
  80040c:	8a66                	mv	s4,s9
  80040e:	46a9                	li	a3,10
  800410:	bdcd                	j	800302 <vprintfmt+0x156>
            err = va_arg(ap, int);
  800412:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  800416:	4761                	li	a4,24
            err = va_arg(ap, int);
  800418:	0a21                	addi	s4,s4,8
            if (err < 0) {
  80041a:	41f7d69b          	sraiw	a3,a5,0x1f
  80041e:	8fb5                	xor	a5,a5,a3
  800420:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  800424:	02d74163          	blt	a4,a3,800446 <vprintfmt+0x29a>
  800428:	00369793          	slli	a5,a3,0x3
  80042c:	97de                	add	a5,a5,s7
  80042e:	639c                	ld	a5,0(a5)
  800430:	cb99                	beqz	a5,800446 <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
  800432:	86be                	mv	a3,a5
  800434:	00000617          	auipc	a2,0x0
  800438:	1a460613          	addi	a2,a2,420 # 8005d8 <main+0x8e>
  80043c:	85a6                	mv	a1,s1
  80043e:	854a                	mv	a0,s2
  800440:	0ce000ef          	jal	ra,80050e <printfmt>
  800444:	b34d                	j	8001e6 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
  800446:	00000617          	auipc	a2,0x0
  80044a:	18260613          	addi	a2,a2,386 # 8005c8 <main+0x7e>
  80044e:	85a6                	mv	a1,s1
  800450:	854a                	mv	a0,s2
  800452:	0bc000ef          	jal	ra,80050e <printfmt>
  800456:	bb41                	j	8001e6 <vprintfmt+0x3a>
                p = "(null)";
  800458:	00000417          	auipc	s0,0x0
  80045c:	16840413          	addi	s0,s0,360 # 8005c0 <main+0x76>
                for (width -= strnlen(p, precision); width > 0; width --) {
  800460:	85e2                	mv	a1,s8
  800462:	8522                	mv	a0,s0
  800464:	e43e                	sd	a5,8(sp)
  800466:	0c8000ef          	jal	ra,80052e <strnlen>
  80046a:	40ad8dbb          	subw	s11,s11,a0
  80046e:	01b05b63          	blez	s11,800484 <vprintfmt+0x2d8>
                    putch(padc, putdat);
  800472:	67a2                	ld	a5,8(sp)
  800474:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
  800478:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
  80047a:	85a6                	mv	a1,s1
  80047c:	8552                	mv	a0,s4
  80047e:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
  800480:	fe0d9ce3          	bnez	s11,800478 <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800484:	00044783          	lbu	a5,0(s0)
  800488:	00140a13          	addi	s4,s0,1
  80048c:	0007851b          	sext.w	a0,a5
  800490:	d3a5                	beqz	a5,8003f0 <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
  800492:	05e00413          	li	s0,94
  800496:	bf39                	j	8003b4 <vprintfmt+0x208>
        return va_arg(*ap, int);
  800498:	000a2403          	lw	s0,0(s4)
  80049c:	b7ad                	j	800406 <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
  80049e:	000a6603          	lwu	a2,0(s4)
  8004a2:	46a1                	li	a3,8
  8004a4:	8a2e                	mv	s4,a1
  8004a6:	bdb1                	j	800302 <vprintfmt+0x156>
  8004a8:	000a6603          	lwu	a2,0(s4)
  8004ac:	46a9                	li	a3,10
  8004ae:	8a2e                	mv	s4,a1
  8004b0:	bd89                	j	800302 <vprintfmt+0x156>
  8004b2:	000a6603          	lwu	a2,0(s4)
  8004b6:	46c1                	li	a3,16
  8004b8:	8a2e                	mv	s4,a1
  8004ba:	b5a1                	j	800302 <vprintfmt+0x156>
                    putch(ch, putdat);
  8004bc:	9902                	jalr	s2
  8004be:	bf09                	j	8003d0 <vprintfmt+0x224>
                putch('-', putdat);
  8004c0:	85a6                	mv	a1,s1
  8004c2:	02d00513          	li	a0,45
  8004c6:	e03e                	sd	a5,0(sp)
  8004c8:	9902                	jalr	s2
                num = -(long long)num;
  8004ca:	6782                	ld	a5,0(sp)
  8004cc:	8a66                	mv	s4,s9
  8004ce:	40800633          	neg	a2,s0
  8004d2:	46a9                	li	a3,10
  8004d4:	b53d                	j	800302 <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
  8004d6:	03b05163          	blez	s11,8004f8 <vprintfmt+0x34c>
  8004da:	02d00693          	li	a3,45
  8004de:	f6d79de3          	bne	a5,a3,800458 <vprintfmt+0x2ac>
                p = "(null)";
  8004e2:	00000417          	auipc	s0,0x0
  8004e6:	0de40413          	addi	s0,s0,222 # 8005c0 <main+0x76>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8004ea:	02800793          	li	a5,40
  8004ee:	02800513          	li	a0,40
  8004f2:	00140a13          	addi	s4,s0,1
  8004f6:	bd6d                	j	8003b0 <vprintfmt+0x204>
  8004f8:	00000a17          	auipc	s4,0x0
  8004fc:	0c9a0a13          	addi	s4,s4,201 # 8005c1 <main+0x77>
  800500:	02800513          	li	a0,40
  800504:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
  800508:	05e00413          	li	s0,94
  80050c:	b565                	j	8003b4 <vprintfmt+0x208>

000000000080050e <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  80050e:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
  800510:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  800514:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
  800516:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  800518:	ec06                	sd	ra,24(sp)
  80051a:	f83a                	sd	a4,48(sp)
  80051c:	fc3e                	sd	a5,56(sp)
  80051e:	e0c2                	sd	a6,64(sp)
  800520:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  800522:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
  800524:	c89ff0ef          	jal	ra,8001ac <vprintfmt>
}
  800528:	60e2                	ld	ra,24(sp)
  80052a:	6161                	addi	sp,sp,80
  80052c:	8082                	ret

000000000080052e <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
  80052e:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
  800530:	e589                	bnez	a1,80053a <strnlen+0xc>
  800532:	a811                	j	800546 <strnlen+0x18>
        cnt ++;
  800534:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
  800536:	00f58863          	beq	a1,a5,800546 <strnlen+0x18>
  80053a:	00f50733          	add	a4,a0,a5
  80053e:	00074703          	lbu	a4,0(a4)
  800542:	fb6d                	bnez	a4,800534 <strnlen+0x6>
  800544:	85be                	mv	a1,a5
    }
    return cnt;
}
  800546:	852e                	mv	a0,a1
  800548:	8082                	ret

000000000080054a <main>:
#include <ulib.h>

/* try to load the kernel's TSS selector into the DS register */

int
main(void) {
  80054a:	1141                	addi	sp,sp,-16
	// There is no such thing as TSS in RISC-V
    // asm volatile("movw $0x28,%ax; movw %ax,%ds");
    panic("FAIL: T.T\n");
  80054c:	00000617          	auipc	a2,0x0
  800550:	37460613          	addi	a2,a2,884 # 8008c0 <error_string+0xc8>
  800554:	45a9                	li	a1,10
  800556:	00000517          	auipc	a0,0x0
  80055a:	37a50513          	addi	a0,a0,890 # 8008d0 <error_string+0xd8>
main(void) {
  80055e:	e406                	sd	ra,8(sp)
    panic("FAIL: T.T\n");
  800560:	ac7ff0ef          	jal	ra,800026 <__panic>
