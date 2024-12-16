
obj/__user_forktest.out:     file format elf64-littleriscv


Disassembly of section .text:

0000000000800020 <_start>:
.text
.globl _start
_start:
    # call user-program function
    call umain
  800020:	128000ef          	jal	ra,800148 <umain>
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
  80003a:	5d250513          	addi	a0,a0,1490 # 800608 <main+0xaa>
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
  80005a:	5d250513          	addi	a0,a0,1490 # 800628 <main+0xca>
  80005e:	044000ef          	jal	ra,8000a2 <cprintf>
    va_end(ap);
    exit(-E_PANIC);
  800062:	5559                	li	a0,-10
  800064:	0c6000ef          	jal	ra,80012a <exit>

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
  800070:	0b4000ef          	jal	ra,800124 <sys_putc>
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
  800096:	12a000ef          	jal	ra,8001c0 <vprintfmt>
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
  8000cc:	0f4000ef          	jal	ra,8001c0 <vprintfmt>
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

0000000000800118 <sys_fork>:
}

int
sys_fork(void) {
    return syscall(SYS_fork);
  800118:	4509                	li	a0,2
  80011a:	bf7d                	j	8000d8 <syscall>

000000000080011c <sys_wait>:
}

int
sys_wait(int64_t pid, int *store) {
  80011c:	862e                	mv	a2,a1
    return syscall(SYS_wait, pid, store);
  80011e:	85aa                	mv	a1,a0
  800120:	450d                	li	a0,3
  800122:	bf5d                	j	8000d8 <syscall>

0000000000800124 <sys_putc>:
sys_getpid(void) {
    return syscall(SYS_getpid);
}

int
sys_putc(int64_t c) {
  800124:	85aa                	mv	a1,a0
    return syscall(SYS_putc, c);
  800126:	4579                	li	a0,30
  800128:	bf45                	j	8000d8 <syscall>

000000000080012a <exit>:
#include <syscall.h>
#include <stdio.h>
#include <ulib.h>

void
exit(int error_code) {
  80012a:	1141                	addi	sp,sp,-16
  80012c:	e406                	sd	ra,8(sp)
    sys_exit(error_code);
  80012e:	fe5ff0ef          	jal	ra,800112 <sys_exit>
    cprintf("BUG: exit failed.\n");
  800132:	00000517          	auipc	a0,0x0
  800136:	4fe50513          	addi	a0,a0,1278 # 800630 <main+0xd2>
  80013a:	f69ff0ef          	jal	ra,8000a2 <cprintf>
    while (1);
  80013e:	a001                	j	80013e <exit+0x14>

0000000000800140 <fork>:
}

int
fork(void) {
    return sys_fork();
  800140:	bfe1                	j	800118 <sys_fork>

0000000000800142 <wait>:
}

int
wait(void) {
    return sys_wait(0, NULL);
  800142:	4581                	li	a1,0
  800144:	4501                	li	a0,0
  800146:	bfd9                	j	80011c <sys_wait>

0000000000800148 <umain>:
#include <ulib.h>

int main(void);

void
umain(void) {
  800148:	1141                	addi	sp,sp,-16
  80014a:	e406                	sd	ra,8(sp)
    int ret = main();
  80014c:	412000ef          	jal	ra,80055e <main>
    exit(ret);
  800150:	fdbff0ef          	jal	ra,80012a <exit>

0000000000800154 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
  800154:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  800158:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
  80015a:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  80015e:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
  800160:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
  800164:	f022                	sd	s0,32(sp)
  800166:	ec26                	sd	s1,24(sp)
  800168:	e84a                	sd	s2,16(sp)
  80016a:	f406                	sd	ra,40(sp)
  80016c:	e44e                	sd	s3,8(sp)
  80016e:	84aa                	mv	s1,a0
  800170:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  800172:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
  800176:	2a01                	sext.w	s4,s4
    if (num >= base) {
  800178:	03067e63          	bgeu	a2,a6,8001b4 <printnum+0x60>
  80017c:	89be                	mv	s3,a5
        while (-- width > 0)
  80017e:	00805763          	blez	s0,80018c <printnum+0x38>
  800182:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
  800184:	85ca                	mv	a1,s2
  800186:	854e                	mv	a0,s3
  800188:	9482                	jalr	s1
        while (-- width > 0)
  80018a:	fc65                	bnez	s0,800182 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  80018c:	1a02                	slli	s4,s4,0x20
  80018e:	00000797          	auipc	a5,0x0
  800192:	4ba78793          	addi	a5,a5,1210 # 800648 <main+0xea>
  800196:	020a5a13          	srli	s4,s4,0x20
  80019a:	9a3e                	add	s4,s4,a5
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
  80019c:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
  80019e:	000a4503          	lbu	a0,0(s4)
}
  8001a2:	70a2                	ld	ra,40(sp)
  8001a4:	69a2                	ld	s3,8(sp)
  8001a6:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
  8001a8:	85ca                	mv	a1,s2
  8001aa:	87a6                	mv	a5,s1
}
  8001ac:	6942                	ld	s2,16(sp)
  8001ae:	64e2                	ld	s1,24(sp)
  8001b0:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
  8001b2:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
  8001b4:	03065633          	divu	a2,a2,a6
  8001b8:	8722                	mv	a4,s0
  8001ba:	f9bff0ef          	jal	ra,800154 <printnum>
  8001be:	b7f9                	j	80018c <printnum+0x38>

00000000008001c0 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  8001c0:	7119                	addi	sp,sp,-128
  8001c2:	f4a6                	sd	s1,104(sp)
  8001c4:	f0ca                	sd	s2,96(sp)
  8001c6:	ecce                	sd	s3,88(sp)
  8001c8:	e8d2                	sd	s4,80(sp)
  8001ca:	e4d6                	sd	s5,72(sp)
  8001cc:	e0da                	sd	s6,64(sp)
  8001ce:	fc5e                	sd	s7,56(sp)
  8001d0:	f06a                	sd	s10,32(sp)
  8001d2:	fc86                	sd	ra,120(sp)
  8001d4:	f8a2                	sd	s0,112(sp)
  8001d6:	f862                	sd	s8,48(sp)
  8001d8:	f466                	sd	s9,40(sp)
  8001da:	ec6e                	sd	s11,24(sp)
  8001dc:	892a                	mv	s2,a0
  8001de:	84ae                	mv	s1,a1
  8001e0:	8d32                	mv	s10,a2
  8001e2:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001e4:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
  8001e8:	5b7d                	li	s6,-1
  8001ea:	00000a97          	auipc	s5,0x0
  8001ee:	492a8a93          	addi	s5,s5,1170 # 80067c <main+0x11e>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8001f2:	00000b97          	auipc	s7,0x0
  8001f6:	6a6b8b93          	addi	s7,s7,1702 # 800898 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001fa:	000d4503          	lbu	a0,0(s10)
  8001fe:	001d0413          	addi	s0,s10,1
  800202:	01350a63          	beq	a0,s3,800216 <vprintfmt+0x56>
            if (ch == '\0') {
  800206:	c121                	beqz	a0,800246 <vprintfmt+0x86>
            putch(ch, putdat);
  800208:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  80020a:	0405                	addi	s0,s0,1
            putch(ch, putdat);
  80020c:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  80020e:	fff44503          	lbu	a0,-1(s0)
  800212:	ff351ae3          	bne	a0,s3,800206 <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
  800216:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
  80021a:	02000793          	li	a5,32
        lflag = altflag = 0;
  80021e:	4c81                	li	s9,0
  800220:	4881                	li	a7,0
        width = precision = -1;
  800222:	5c7d                	li	s8,-1
  800224:	5dfd                	li	s11,-1
  800226:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
  80022a:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
  80022c:	fdd6059b          	addiw	a1,a2,-35
  800230:	0ff5f593          	zext.b	a1,a1
  800234:	00140d13          	addi	s10,s0,1
  800238:	04b56263          	bltu	a0,a1,80027c <vprintfmt+0xbc>
  80023c:	058a                	slli	a1,a1,0x2
  80023e:	95d6                	add	a1,a1,s5
  800240:	4194                	lw	a3,0(a1)
  800242:	96d6                	add	a3,a3,s5
  800244:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
  800246:	70e6                	ld	ra,120(sp)
  800248:	7446                	ld	s0,112(sp)
  80024a:	74a6                	ld	s1,104(sp)
  80024c:	7906                	ld	s2,96(sp)
  80024e:	69e6                	ld	s3,88(sp)
  800250:	6a46                	ld	s4,80(sp)
  800252:	6aa6                	ld	s5,72(sp)
  800254:	6b06                	ld	s6,64(sp)
  800256:	7be2                	ld	s7,56(sp)
  800258:	7c42                	ld	s8,48(sp)
  80025a:	7ca2                	ld	s9,40(sp)
  80025c:	7d02                	ld	s10,32(sp)
  80025e:	6de2                	ld	s11,24(sp)
  800260:	6109                	addi	sp,sp,128
  800262:	8082                	ret
            padc = '0';
  800264:	87b2                	mv	a5,a2
            goto reswitch;
  800266:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
  80026a:	846a                	mv	s0,s10
  80026c:	00140d13          	addi	s10,s0,1
  800270:	fdd6059b          	addiw	a1,a2,-35
  800274:	0ff5f593          	zext.b	a1,a1
  800278:	fcb572e3          	bgeu	a0,a1,80023c <vprintfmt+0x7c>
            putch('%', putdat);
  80027c:	85a6                	mv	a1,s1
  80027e:	02500513          	li	a0,37
  800282:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
  800284:	fff44783          	lbu	a5,-1(s0)
  800288:	8d22                	mv	s10,s0
  80028a:	f73788e3          	beq	a5,s3,8001fa <vprintfmt+0x3a>
  80028e:	ffed4783          	lbu	a5,-2(s10)
  800292:	1d7d                	addi	s10,s10,-1
  800294:	ff379de3          	bne	a5,s3,80028e <vprintfmt+0xce>
  800298:	b78d                	j	8001fa <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
  80029a:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
  80029e:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
  8002a2:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
  8002a4:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
  8002a8:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
  8002ac:	02d86463          	bltu	a6,a3,8002d4 <vprintfmt+0x114>
                ch = *fmt;
  8002b0:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
  8002b4:	002c169b          	slliw	a3,s8,0x2
  8002b8:	0186873b          	addw	a4,a3,s8
  8002bc:	0017171b          	slliw	a4,a4,0x1
  8002c0:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
  8002c2:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
  8002c6:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
  8002c8:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
  8002cc:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
  8002d0:	fed870e3          	bgeu	a6,a3,8002b0 <vprintfmt+0xf0>
            if (width < 0)
  8002d4:	f40ddce3          	bgez	s11,80022c <vprintfmt+0x6c>
                width = precision, precision = -1;
  8002d8:	8de2                	mv	s11,s8
  8002da:	5c7d                	li	s8,-1
  8002dc:	bf81                	j	80022c <vprintfmt+0x6c>
            if (width < 0)
  8002de:	fffdc693          	not	a3,s11
  8002e2:	96fd                	srai	a3,a3,0x3f
  8002e4:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
  8002e8:	00144603          	lbu	a2,1(s0)
  8002ec:	2d81                	sext.w	s11,s11
  8002ee:	846a                	mv	s0,s10
            goto reswitch;
  8002f0:	bf35                	j	80022c <vprintfmt+0x6c>
            precision = va_arg(ap, int);
  8002f2:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
  8002f6:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
  8002fa:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
  8002fc:	846a                	mv	s0,s10
            goto process_precision;
  8002fe:	bfd9                	j	8002d4 <vprintfmt+0x114>
    if (lflag >= 2) {
  800300:	4705                	li	a4,1
            precision = va_arg(ap, int);
  800302:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  800306:	01174463          	blt	a4,a7,80030e <vprintfmt+0x14e>
    else if (lflag) {
  80030a:	1a088e63          	beqz	a7,8004c6 <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
  80030e:	000a3603          	ld	a2,0(s4)
  800312:	46c1                	li	a3,16
  800314:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
  800316:	2781                	sext.w	a5,a5
  800318:	876e                	mv	a4,s11
  80031a:	85a6                	mv	a1,s1
  80031c:	854a                	mv	a0,s2
  80031e:	e37ff0ef          	jal	ra,800154 <printnum>
            break;
  800322:	bde1                	j	8001fa <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
  800324:	000a2503          	lw	a0,0(s4)
  800328:	85a6                	mv	a1,s1
  80032a:	0a21                	addi	s4,s4,8
  80032c:	9902                	jalr	s2
            break;
  80032e:	b5f1                	j	8001fa <vprintfmt+0x3a>
    if (lflag >= 2) {
  800330:	4705                	li	a4,1
            precision = va_arg(ap, int);
  800332:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  800336:	01174463          	blt	a4,a7,80033e <vprintfmt+0x17e>
    else if (lflag) {
  80033a:	18088163          	beqz	a7,8004bc <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
  80033e:	000a3603          	ld	a2,0(s4)
  800342:	46a9                	li	a3,10
  800344:	8a2e                	mv	s4,a1
  800346:	bfc1                	j	800316 <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
  800348:	00144603          	lbu	a2,1(s0)
            altflag = 1;
  80034c:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
  80034e:	846a                	mv	s0,s10
            goto reswitch;
  800350:	bdf1                	j	80022c <vprintfmt+0x6c>
            putch(ch, putdat);
  800352:	85a6                	mv	a1,s1
  800354:	02500513          	li	a0,37
  800358:	9902                	jalr	s2
            break;
  80035a:	b545                	j	8001fa <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
  80035c:	00144603          	lbu	a2,1(s0)
            lflag ++;
  800360:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
  800362:	846a                	mv	s0,s10
            goto reswitch;
  800364:	b5e1                	j	80022c <vprintfmt+0x6c>
    if (lflag >= 2) {
  800366:	4705                	li	a4,1
            precision = va_arg(ap, int);
  800368:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  80036c:	01174463          	blt	a4,a7,800374 <vprintfmt+0x1b4>
    else if (lflag) {
  800370:	14088163          	beqz	a7,8004b2 <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
  800374:	000a3603          	ld	a2,0(s4)
  800378:	46a1                	li	a3,8
  80037a:	8a2e                	mv	s4,a1
  80037c:	bf69                	j	800316 <vprintfmt+0x156>
            putch('0', putdat);
  80037e:	03000513          	li	a0,48
  800382:	85a6                	mv	a1,s1
  800384:	e03e                	sd	a5,0(sp)
  800386:	9902                	jalr	s2
            putch('x', putdat);
  800388:	85a6                	mv	a1,s1
  80038a:	07800513          	li	a0,120
  80038e:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  800390:	0a21                	addi	s4,s4,8
            goto number;
  800392:	6782                	ld	a5,0(sp)
  800394:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  800396:	ff8a3603          	ld	a2,-8(s4)
            goto number;
  80039a:	bfb5                	j	800316 <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
  80039c:	000a3403          	ld	s0,0(s4)
  8003a0:	008a0713          	addi	a4,s4,8
  8003a4:	e03a                	sd	a4,0(sp)
  8003a6:	14040263          	beqz	s0,8004ea <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
  8003aa:	0fb05763          	blez	s11,800498 <vprintfmt+0x2d8>
  8003ae:	02d00693          	li	a3,45
  8003b2:	0cd79163          	bne	a5,a3,800474 <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8003b6:	00044783          	lbu	a5,0(s0)
  8003ba:	0007851b          	sext.w	a0,a5
  8003be:	cf85                	beqz	a5,8003f6 <vprintfmt+0x236>
  8003c0:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
  8003c4:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8003c8:	000c4563          	bltz	s8,8003d2 <vprintfmt+0x212>
  8003cc:	3c7d                	addiw	s8,s8,-1
  8003ce:	036c0263          	beq	s8,s6,8003f2 <vprintfmt+0x232>
                    putch('?', putdat);
  8003d2:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
  8003d4:	0e0c8e63          	beqz	s9,8004d0 <vprintfmt+0x310>
  8003d8:	3781                	addiw	a5,a5,-32
  8003da:	0ef47b63          	bgeu	s0,a5,8004d0 <vprintfmt+0x310>
                    putch('?', putdat);
  8003de:	03f00513          	li	a0,63
  8003e2:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8003e4:	000a4783          	lbu	a5,0(s4)
  8003e8:	3dfd                	addiw	s11,s11,-1
  8003ea:	0a05                	addi	s4,s4,1
  8003ec:	0007851b          	sext.w	a0,a5
  8003f0:	ffe1                	bnez	a5,8003c8 <vprintfmt+0x208>
            for (; width > 0; width --) {
  8003f2:	01b05963          	blez	s11,800404 <vprintfmt+0x244>
  8003f6:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
  8003f8:	85a6                	mv	a1,s1
  8003fa:	02000513          	li	a0,32
  8003fe:	9902                	jalr	s2
            for (; width > 0; width --) {
  800400:	fe0d9be3          	bnez	s11,8003f6 <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
  800404:	6a02                	ld	s4,0(sp)
  800406:	bbd5                	j	8001fa <vprintfmt+0x3a>
    if (lflag >= 2) {
  800408:	4705                	li	a4,1
            precision = va_arg(ap, int);
  80040a:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
  80040e:	01174463          	blt	a4,a7,800416 <vprintfmt+0x256>
    else if (lflag) {
  800412:	08088d63          	beqz	a7,8004ac <vprintfmt+0x2ec>
        return va_arg(*ap, long);
  800416:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
  80041a:	0a044d63          	bltz	s0,8004d4 <vprintfmt+0x314>
            num = getint(&ap, lflag);
  80041e:	8622                	mv	a2,s0
  800420:	8a66                	mv	s4,s9
  800422:	46a9                	li	a3,10
  800424:	bdcd                	j	800316 <vprintfmt+0x156>
            err = va_arg(ap, int);
  800426:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  80042a:	4761                	li	a4,24
            err = va_arg(ap, int);
  80042c:	0a21                	addi	s4,s4,8
            if (err < 0) {
  80042e:	41f7d69b          	sraiw	a3,a5,0x1f
  800432:	8fb5                	xor	a5,a5,a3
  800434:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  800438:	02d74163          	blt	a4,a3,80045a <vprintfmt+0x29a>
  80043c:	00369793          	slli	a5,a3,0x3
  800440:	97de                	add	a5,a5,s7
  800442:	639c                	ld	a5,0(a5)
  800444:	cb99                	beqz	a5,80045a <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
  800446:	86be                	mv	a3,a5
  800448:	00000617          	auipc	a2,0x0
  80044c:	23060613          	addi	a2,a2,560 # 800678 <main+0x11a>
  800450:	85a6                	mv	a1,s1
  800452:	854a                	mv	a0,s2
  800454:	0ce000ef          	jal	ra,800522 <printfmt>
  800458:	b34d                	j	8001fa <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
  80045a:	00000617          	auipc	a2,0x0
  80045e:	20e60613          	addi	a2,a2,526 # 800668 <main+0x10a>
  800462:	85a6                	mv	a1,s1
  800464:	854a                	mv	a0,s2
  800466:	0bc000ef          	jal	ra,800522 <printfmt>
  80046a:	bb41                	j	8001fa <vprintfmt+0x3a>
                p = "(null)";
  80046c:	00000417          	auipc	s0,0x0
  800470:	1f440413          	addi	s0,s0,500 # 800660 <main+0x102>
                for (width -= strnlen(p, precision); width > 0; width --) {
  800474:	85e2                	mv	a1,s8
  800476:	8522                	mv	a0,s0
  800478:	e43e                	sd	a5,8(sp)
  80047a:	0c8000ef          	jal	ra,800542 <strnlen>
  80047e:	40ad8dbb          	subw	s11,s11,a0
  800482:	01b05b63          	blez	s11,800498 <vprintfmt+0x2d8>
                    putch(padc, putdat);
  800486:	67a2                	ld	a5,8(sp)
  800488:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
  80048c:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
  80048e:	85a6                	mv	a1,s1
  800490:	8552                	mv	a0,s4
  800492:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
  800494:	fe0d9ce3          	bnez	s11,80048c <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800498:	00044783          	lbu	a5,0(s0)
  80049c:	00140a13          	addi	s4,s0,1
  8004a0:	0007851b          	sext.w	a0,a5
  8004a4:	d3a5                	beqz	a5,800404 <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
  8004a6:	05e00413          	li	s0,94
  8004aa:	bf39                	j	8003c8 <vprintfmt+0x208>
        return va_arg(*ap, int);
  8004ac:	000a2403          	lw	s0,0(s4)
  8004b0:	b7ad                	j	80041a <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
  8004b2:	000a6603          	lwu	a2,0(s4)
  8004b6:	46a1                	li	a3,8
  8004b8:	8a2e                	mv	s4,a1
  8004ba:	bdb1                	j	800316 <vprintfmt+0x156>
  8004bc:	000a6603          	lwu	a2,0(s4)
  8004c0:	46a9                	li	a3,10
  8004c2:	8a2e                	mv	s4,a1
  8004c4:	bd89                	j	800316 <vprintfmt+0x156>
  8004c6:	000a6603          	lwu	a2,0(s4)
  8004ca:	46c1                	li	a3,16
  8004cc:	8a2e                	mv	s4,a1
  8004ce:	b5a1                	j	800316 <vprintfmt+0x156>
                    putch(ch, putdat);
  8004d0:	9902                	jalr	s2
  8004d2:	bf09                	j	8003e4 <vprintfmt+0x224>
                putch('-', putdat);
  8004d4:	85a6                	mv	a1,s1
  8004d6:	02d00513          	li	a0,45
  8004da:	e03e                	sd	a5,0(sp)
  8004dc:	9902                	jalr	s2
                num = -(long long)num;
  8004de:	6782                	ld	a5,0(sp)
  8004e0:	8a66                	mv	s4,s9
  8004e2:	40800633          	neg	a2,s0
  8004e6:	46a9                	li	a3,10
  8004e8:	b53d                	j	800316 <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
  8004ea:	03b05163          	blez	s11,80050c <vprintfmt+0x34c>
  8004ee:	02d00693          	li	a3,45
  8004f2:	f6d79de3          	bne	a5,a3,80046c <vprintfmt+0x2ac>
                p = "(null)";
  8004f6:	00000417          	auipc	s0,0x0
  8004fa:	16a40413          	addi	s0,s0,362 # 800660 <main+0x102>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8004fe:	02800793          	li	a5,40
  800502:	02800513          	li	a0,40
  800506:	00140a13          	addi	s4,s0,1
  80050a:	bd6d                	j	8003c4 <vprintfmt+0x204>
  80050c:	00000a17          	auipc	s4,0x0
  800510:	155a0a13          	addi	s4,s4,341 # 800661 <main+0x103>
  800514:	02800513          	li	a0,40
  800518:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
  80051c:	05e00413          	li	s0,94
  800520:	b565                	j	8003c8 <vprintfmt+0x208>

0000000000800522 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  800522:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
  800524:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  800528:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
  80052a:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  80052c:	ec06                	sd	ra,24(sp)
  80052e:	f83a                	sd	a4,48(sp)
  800530:	fc3e                	sd	a5,56(sp)
  800532:	e0c2                	sd	a6,64(sp)
  800534:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  800536:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
  800538:	c89ff0ef          	jal	ra,8001c0 <vprintfmt>
}
  80053c:	60e2                	ld	ra,24(sp)
  80053e:	6161                	addi	sp,sp,80
  800540:	8082                	ret

0000000000800542 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
  800542:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
  800544:	e589                	bnez	a1,80054e <strnlen+0xc>
  800546:	a811                	j	80055a <strnlen+0x18>
        cnt ++;
  800548:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
  80054a:	00f58863          	beq	a1,a5,80055a <strnlen+0x18>
  80054e:	00f50733          	add	a4,a0,a5
  800552:	00074703          	lbu	a4,0(a4)
  800556:	fb6d                	bnez	a4,800548 <strnlen+0x6>
  800558:	85be                	mv	a1,a5
    }
    return cnt;
}
  80055a:	852e                	mv	a0,a1
  80055c:	8082                	ret

000000000080055e <main>:
#include <stdio.h>

const int max_child = 32;

int
main(void) {
  80055e:	1101                	addi	sp,sp,-32
  800560:	e822                	sd	s0,16(sp)
  800562:	e426                	sd	s1,8(sp)
  800564:	ec06                	sd	ra,24(sp)
    int n, pid;
    for (n = 0; n < max_child; n ++) {
  800566:	4401                	li	s0,0
  800568:	02000493          	li	s1,32
        if ((pid = fork()) == 0) {
  80056c:	bd5ff0ef          	jal	ra,800140 <fork>
  800570:	cd05                	beqz	a0,8005a8 <main+0x4a>
            cprintf("I am child %d\n", n);
            exit(0);
        }
        assert(pid > 0);
  800572:	06a05063          	blez	a0,8005d2 <main+0x74>
    for (n = 0; n < max_child; n ++) {
  800576:	2405                	addiw	s0,s0,1
  800578:	fe941ae3          	bne	s0,s1,80056c <main+0xe>
  80057c:	02000413          	li	s0,32
    if (n > max_child) {
        panic("fork claimed to work %d times!\n", n);
    }

    for (; n > 0; n --) {
        if (wait() != 0) {
  800580:	bc3ff0ef          	jal	ra,800142 <wait>
  800584:	ed05                	bnez	a0,8005bc <main+0x5e>
    for (; n > 0; n --) {
  800586:	347d                	addiw	s0,s0,-1
  800588:	fc65                	bnez	s0,800580 <main+0x22>
            panic("wait stopped early\n");
        }
    }

    if (wait() == 0) {
  80058a:	bb9ff0ef          	jal	ra,800142 <wait>
  80058e:	c12d                	beqz	a0,8005f0 <main+0x92>
        panic("wait got too many\n");
    }

    cprintf("forktest pass.\n");
  800590:	00000517          	auipc	a0,0x0
  800594:	44050513          	addi	a0,a0,1088 # 8009d0 <error_string+0x138>
  800598:	b0bff0ef          	jal	ra,8000a2 <cprintf>
    return 0;
}
  80059c:	60e2                	ld	ra,24(sp)
  80059e:	6442                	ld	s0,16(sp)
  8005a0:	64a2                	ld	s1,8(sp)
  8005a2:	4501                	li	a0,0
  8005a4:	6105                	addi	sp,sp,32
  8005a6:	8082                	ret
            cprintf("I am child %d\n", n);
  8005a8:	85a2                	mv	a1,s0
  8005aa:	00000517          	auipc	a0,0x0
  8005ae:	3b650513          	addi	a0,a0,950 # 800960 <error_string+0xc8>
  8005b2:	af1ff0ef          	jal	ra,8000a2 <cprintf>
            exit(0);
  8005b6:	4501                	li	a0,0
  8005b8:	b73ff0ef          	jal	ra,80012a <exit>
            panic("wait stopped early\n");
  8005bc:	00000617          	auipc	a2,0x0
  8005c0:	3e460613          	addi	a2,a2,996 # 8009a0 <error_string+0x108>
  8005c4:	45dd                	li	a1,23
  8005c6:	00000517          	auipc	a0,0x0
  8005ca:	3ca50513          	addi	a0,a0,970 # 800990 <error_string+0xf8>
  8005ce:	a59ff0ef          	jal	ra,800026 <__panic>
        assert(pid > 0);
  8005d2:	00000697          	auipc	a3,0x0
  8005d6:	39e68693          	addi	a3,a3,926 # 800970 <error_string+0xd8>
  8005da:	00000617          	auipc	a2,0x0
  8005de:	39e60613          	addi	a2,a2,926 # 800978 <error_string+0xe0>
  8005e2:	45b9                	li	a1,14
  8005e4:	00000517          	auipc	a0,0x0
  8005e8:	3ac50513          	addi	a0,a0,940 # 800990 <error_string+0xf8>
  8005ec:	a3bff0ef          	jal	ra,800026 <__panic>
        panic("wait got too many\n");
  8005f0:	00000617          	auipc	a2,0x0
  8005f4:	3c860613          	addi	a2,a2,968 # 8009b8 <error_string+0x120>
  8005f8:	45f1                	li	a1,28
  8005fa:	00000517          	auipc	a0,0x0
  8005fe:	39650513          	addi	a0,a0,918 # 800990 <error_string+0xf8>
  800602:	a25ff0ef          	jal	ra,800026 <__panic>
