
obj/__user_spin.out:     file format elf64-littleriscv


Disassembly of section .text:

0000000000800020 <_start>:
.text
.globl _start
_start:
    # call user-program function
    call umain
  800020:	132000ef          	jal	ra,800152 <umain>
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
  80003a:	60250513          	addi	a0,a0,1538 # 800638 <main+0xd0>
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
  80005a:	60250513          	addi	a0,a0,1538 # 800658 <main+0xf0>
  80005e:	044000ef          	jal	ra,8000a2 <cprintf>
    va_end(ap);
    exit(-E_PANIC);
  800062:	5559                	li	a0,-10
  800064:	0d0000ef          	jal	ra,800134 <exit>

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
  800070:	0be000ef          	jal	ra,80012e <sys_putc>
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
  800096:	134000ef          	jal	ra,8001ca <vprintfmt>
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
  8000cc:	0fe000ef          	jal	ra,8001ca <vprintfmt>
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

0000000000800124 <sys_yield>:
}

int
sys_yield(void) {
    return syscall(SYS_yield);
  800124:	4529                	li	a0,10
  800126:	bf4d                	j	8000d8 <syscall>

0000000000800128 <sys_kill>:
}

int
sys_kill(int64_t pid) {
  800128:	85aa                	mv	a1,a0
    return syscall(SYS_kill, pid);
  80012a:	4531                	li	a0,12
  80012c:	b775                	j	8000d8 <syscall>

000000000080012e <sys_putc>:
sys_getpid(void) {
    return syscall(SYS_getpid);
}

int
sys_putc(int64_t c) {
  80012e:	85aa                	mv	a1,a0
    return syscall(SYS_putc, c);
  800130:	4579                	li	a0,30
  800132:	b75d                	j	8000d8 <syscall>

0000000000800134 <exit>:
#include <syscall.h>
#include <stdio.h>
#include <ulib.h>

void
exit(int error_code) {
  800134:	1141                	addi	sp,sp,-16
  800136:	e406                	sd	ra,8(sp)
    sys_exit(error_code);
  800138:	fdbff0ef          	jal	ra,800112 <sys_exit>
    cprintf("BUG: exit failed.\n");
  80013c:	00000517          	auipc	a0,0x0
  800140:	52450513          	addi	a0,a0,1316 # 800660 <main+0xf8>
  800144:	f5fff0ef          	jal	ra,8000a2 <cprintf>
    while (1);
  800148:	a001                	j	800148 <exit+0x14>

000000000080014a <fork>:
}

int
fork(void) {
    return sys_fork();
  80014a:	b7f9                	j	800118 <sys_fork>

000000000080014c <waitpid>:
    return sys_wait(0, NULL);
}

int
waitpid(int pid, int *store) {
    return sys_wait(pid, store);
  80014c:	bfc1                	j	80011c <sys_wait>

000000000080014e <yield>:
}

void
yield(void) {
    sys_yield();
  80014e:	bfd9                	j	800124 <sys_yield>

0000000000800150 <kill>:
}

int
kill(int pid) {
    return sys_kill(pid);
  800150:	bfe1                	j	800128 <sys_kill>

0000000000800152 <umain>:
#include <ulib.h>

int main(void);

void
umain(void) {
  800152:	1141                	addi	sp,sp,-16
  800154:	e406                	sd	ra,8(sp)
    int ret = main();
  800156:	412000ef          	jal	ra,800568 <main>
    exit(ret);
  80015a:	fdbff0ef          	jal	ra,800134 <exit>

000000000080015e <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
  80015e:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  800162:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
  800164:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  800168:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
  80016a:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
  80016e:	f022                	sd	s0,32(sp)
  800170:	ec26                	sd	s1,24(sp)
  800172:	e84a                	sd	s2,16(sp)
  800174:	f406                	sd	ra,40(sp)
  800176:	e44e                	sd	s3,8(sp)
  800178:	84aa                	mv	s1,a0
  80017a:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  80017c:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
  800180:	2a01                	sext.w	s4,s4
    if (num >= base) {
  800182:	03067e63          	bgeu	a2,a6,8001be <printnum+0x60>
  800186:	89be                	mv	s3,a5
        while (-- width > 0)
  800188:	00805763          	blez	s0,800196 <printnum+0x38>
  80018c:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
  80018e:	85ca                	mv	a1,s2
  800190:	854e                	mv	a0,s3
  800192:	9482                	jalr	s1
        while (-- width > 0)
  800194:	fc65                	bnez	s0,80018c <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  800196:	1a02                	slli	s4,s4,0x20
  800198:	00000797          	auipc	a5,0x0
  80019c:	4e078793          	addi	a5,a5,1248 # 800678 <main+0x110>
  8001a0:	020a5a13          	srli	s4,s4,0x20
  8001a4:	9a3e                	add	s4,s4,a5
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
  8001a6:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
  8001a8:	000a4503          	lbu	a0,0(s4)
}
  8001ac:	70a2                	ld	ra,40(sp)
  8001ae:	69a2                	ld	s3,8(sp)
  8001b0:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
  8001b2:	85ca                	mv	a1,s2
  8001b4:	87a6                	mv	a5,s1
}
  8001b6:	6942                	ld	s2,16(sp)
  8001b8:	64e2                	ld	s1,24(sp)
  8001ba:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
  8001bc:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
  8001be:	03065633          	divu	a2,a2,a6
  8001c2:	8722                	mv	a4,s0
  8001c4:	f9bff0ef          	jal	ra,80015e <printnum>
  8001c8:	b7f9                	j	800196 <printnum+0x38>

00000000008001ca <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  8001ca:	7119                	addi	sp,sp,-128
  8001cc:	f4a6                	sd	s1,104(sp)
  8001ce:	f0ca                	sd	s2,96(sp)
  8001d0:	ecce                	sd	s3,88(sp)
  8001d2:	e8d2                	sd	s4,80(sp)
  8001d4:	e4d6                	sd	s5,72(sp)
  8001d6:	e0da                	sd	s6,64(sp)
  8001d8:	fc5e                	sd	s7,56(sp)
  8001da:	f06a                	sd	s10,32(sp)
  8001dc:	fc86                	sd	ra,120(sp)
  8001de:	f8a2                	sd	s0,112(sp)
  8001e0:	f862                	sd	s8,48(sp)
  8001e2:	f466                	sd	s9,40(sp)
  8001e4:	ec6e                	sd	s11,24(sp)
  8001e6:	892a                	mv	s2,a0
  8001e8:	84ae                	mv	s1,a1
  8001ea:	8d32                	mv	s10,a2
  8001ec:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001ee:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
  8001f2:	5b7d                	li	s6,-1
  8001f4:	00000a97          	auipc	s5,0x0
  8001f8:	4b8a8a93          	addi	s5,s5,1208 # 8006ac <main+0x144>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8001fc:	00000b97          	auipc	s7,0x0
  800200:	6ccb8b93          	addi	s7,s7,1740 # 8008c8 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800204:	000d4503          	lbu	a0,0(s10)
  800208:	001d0413          	addi	s0,s10,1
  80020c:	01350a63          	beq	a0,s3,800220 <vprintfmt+0x56>
            if (ch == '\0') {
  800210:	c121                	beqz	a0,800250 <vprintfmt+0x86>
            putch(ch, putdat);
  800212:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800214:	0405                	addi	s0,s0,1
            putch(ch, putdat);
  800216:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800218:	fff44503          	lbu	a0,-1(s0)
  80021c:	ff351ae3          	bne	a0,s3,800210 <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
  800220:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
  800224:	02000793          	li	a5,32
        lflag = altflag = 0;
  800228:	4c81                	li	s9,0
  80022a:	4881                	li	a7,0
        width = precision = -1;
  80022c:	5c7d                	li	s8,-1
  80022e:	5dfd                	li	s11,-1
  800230:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
  800234:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
  800236:	fdd6059b          	addiw	a1,a2,-35
  80023a:	0ff5f593          	zext.b	a1,a1
  80023e:	00140d13          	addi	s10,s0,1
  800242:	04b56263          	bltu	a0,a1,800286 <vprintfmt+0xbc>
  800246:	058a                	slli	a1,a1,0x2
  800248:	95d6                	add	a1,a1,s5
  80024a:	4194                	lw	a3,0(a1)
  80024c:	96d6                	add	a3,a3,s5
  80024e:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
  800250:	70e6                	ld	ra,120(sp)
  800252:	7446                	ld	s0,112(sp)
  800254:	74a6                	ld	s1,104(sp)
  800256:	7906                	ld	s2,96(sp)
  800258:	69e6                	ld	s3,88(sp)
  80025a:	6a46                	ld	s4,80(sp)
  80025c:	6aa6                	ld	s5,72(sp)
  80025e:	6b06                	ld	s6,64(sp)
  800260:	7be2                	ld	s7,56(sp)
  800262:	7c42                	ld	s8,48(sp)
  800264:	7ca2                	ld	s9,40(sp)
  800266:	7d02                	ld	s10,32(sp)
  800268:	6de2                	ld	s11,24(sp)
  80026a:	6109                	addi	sp,sp,128
  80026c:	8082                	ret
            padc = '0';
  80026e:	87b2                	mv	a5,a2
            goto reswitch;
  800270:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
  800274:	846a                	mv	s0,s10
  800276:	00140d13          	addi	s10,s0,1
  80027a:	fdd6059b          	addiw	a1,a2,-35
  80027e:	0ff5f593          	zext.b	a1,a1
  800282:	fcb572e3          	bgeu	a0,a1,800246 <vprintfmt+0x7c>
            putch('%', putdat);
  800286:	85a6                	mv	a1,s1
  800288:	02500513          	li	a0,37
  80028c:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
  80028e:	fff44783          	lbu	a5,-1(s0)
  800292:	8d22                	mv	s10,s0
  800294:	f73788e3          	beq	a5,s3,800204 <vprintfmt+0x3a>
  800298:	ffed4783          	lbu	a5,-2(s10)
  80029c:	1d7d                	addi	s10,s10,-1
  80029e:	ff379de3          	bne	a5,s3,800298 <vprintfmt+0xce>
  8002a2:	b78d                	j	800204 <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
  8002a4:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
  8002a8:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
  8002ac:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
  8002ae:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
  8002b2:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
  8002b6:	02d86463          	bltu	a6,a3,8002de <vprintfmt+0x114>
                ch = *fmt;
  8002ba:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
  8002be:	002c169b          	slliw	a3,s8,0x2
  8002c2:	0186873b          	addw	a4,a3,s8
  8002c6:	0017171b          	slliw	a4,a4,0x1
  8002ca:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
  8002cc:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
  8002d0:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
  8002d2:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
  8002d6:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
  8002da:	fed870e3          	bgeu	a6,a3,8002ba <vprintfmt+0xf0>
            if (width < 0)
  8002de:	f40ddce3          	bgez	s11,800236 <vprintfmt+0x6c>
                width = precision, precision = -1;
  8002e2:	8de2                	mv	s11,s8
  8002e4:	5c7d                	li	s8,-1
  8002e6:	bf81                	j	800236 <vprintfmt+0x6c>
            if (width < 0)
  8002e8:	fffdc693          	not	a3,s11
  8002ec:	96fd                	srai	a3,a3,0x3f
  8002ee:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
  8002f2:	00144603          	lbu	a2,1(s0)
  8002f6:	2d81                	sext.w	s11,s11
  8002f8:	846a                	mv	s0,s10
            goto reswitch;
  8002fa:	bf35                	j	800236 <vprintfmt+0x6c>
            precision = va_arg(ap, int);
  8002fc:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
  800300:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
  800304:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
  800306:	846a                	mv	s0,s10
            goto process_precision;
  800308:	bfd9                	j	8002de <vprintfmt+0x114>
    if (lflag >= 2) {
  80030a:	4705                	li	a4,1
            precision = va_arg(ap, int);
  80030c:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  800310:	01174463          	blt	a4,a7,800318 <vprintfmt+0x14e>
    else if (lflag) {
  800314:	1a088e63          	beqz	a7,8004d0 <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
  800318:	000a3603          	ld	a2,0(s4)
  80031c:	46c1                	li	a3,16
  80031e:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
  800320:	2781                	sext.w	a5,a5
  800322:	876e                	mv	a4,s11
  800324:	85a6                	mv	a1,s1
  800326:	854a                	mv	a0,s2
  800328:	e37ff0ef          	jal	ra,80015e <printnum>
            break;
  80032c:	bde1                	j	800204 <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
  80032e:	000a2503          	lw	a0,0(s4)
  800332:	85a6                	mv	a1,s1
  800334:	0a21                	addi	s4,s4,8
  800336:	9902                	jalr	s2
            break;
  800338:	b5f1                	j	800204 <vprintfmt+0x3a>
    if (lflag >= 2) {
  80033a:	4705                	li	a4,1
            precision = va_arg(ap, int);
  80033c:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  800340:	01174463          	blt	a4,a7,800348 <vprintfmt+0x17e>
    else if (lflag) {
  800344:	18088163          	beqz	a7,8004c6 <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
  800348:	000a3603          	ld	a2,0(s4)
  80034c:	46a9                	li	a3,10
  80034e:	8a2e                	mv	s4,a1
  800350:	bfc1                	j	800320 <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
  800352:	00144603          	lbu	a2,1(s0)
            altflag = 1;
  800356:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
  800358:	846a                	mv	s0,s10
            goto reswitch;
  80035a:	bdf1                	j	800236 <vprintfmt+0x6c>
            putch(ch, putdat);
  80035c:	85a6                	mv	a1,s1
  80035e:	02500513          	li	a0,37
  800362:	9902                	jalr	s2
            break;
  800364:	b545                	j	800204 <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
  800366:	00144603          	lbu	a2,1(s0)
            lflag ++;
  80036a:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
  80036c:	846a                	mv	s0,s10
            goto reswitch;
  80036e:	b5e1                	j	800236 <vprintfmt+0x6c>
    if (lflag >= 2) {
  800370:	4705                	li	a4,1
            precision = va_arg(ap, int);
  800372:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  800376:	01174463          	blt	a4,a7,80037e <vprintfmt+0x1b4>
    else if (lflag) {
  80037a:	14088163          	beqz	a7,8004bc <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
  80037e:	000a3603          	ld	a2,0(s4)
  800382:	46a1                	li	a3,8
  800384:	8a2e                	mv	s4,a1
  800386:	bf69                	j	800320 <vprintfmt+0x156>
            putch('0', putdat);
  800388:	03000513          	li	a0,48
  80038c:	85a6                	mv	a1,s1
  80038e:	e03e                	sd	a5,0(sp)
  800390:	9902                	jalr	s2
            putch('x', putdat);
  800392:	85a6                	mv	a1,s1
  800394:	07800513          	li	a0,120
  800398:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  80039a:	0a21                	addi	s4,s4,8
            goto number;
  80039c:	6782                	ld	a5,0(sp)
  80039e:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  8003a0:	ff8a3603          	ld	a2,-8(s4)
            goto number;
  8003a4:	bfb5                	j	800320 <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
  8003a6:	000a3403          	ld	s0,0(s4)
  8003aa:	008a0713          	addi	a4,s4,8
  8003ae:	e03a                	sd	a4,0(sp)
  8003b0:	14040263          	beqz	s0,8004f4 <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
  8003b4:	0fb05763          	blez	s11,8004a2 <vprintfmt+0x2d8>
  8003b8:	02d00693          	li	a3,45
  8003bc:	0cd79163          	bne	a5,a3,80047e <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8003c0:	00044783          	lbu	a5,0(s0)
  8003c4:	0007851b          	sext.w	a0,a5
  8003c8:	cf85                	beqz	a5,800400 <vprintfmt+0x236>
  8003ca:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
  8003ce:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8003d2:	000c4563          	bltz	s8,8003dc <vprintfmt+0x212>
  8003d6:	3c7d                	addiw	s8,s8,-1
  8003d8:	036c0263          	beq	s8,s6,8003fc <vprintfmt+0x232>
                    putch('?', putdat);
  8003dc:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
  8003de:	0e0c8e63          	beqz	s9,8004da <vprintfmt+0x310>
  8003e2:	3781                	addiw	a5,a5,-32
  8003e4:	0ef47b63          	bgeu	s0,a5,8004da <vprintfmt+0x310>
                    putch('?', putdat);
  8003e8:	03f00513          	li	a0,63
  8003ec:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8003ee:	000a4783          	lbu	a5,0(s4)
  8003f2:	3dfd                	addiw	s11,s11,-1
  8003f4:	0a05                	addi	s4,s4,1
  8003f6:	0007851b          	sext.w	a0,a5
  8003fa:	ffe1                	bnez	a5,8003d2 <vprintfmt+0x208>
            for (; width > 0; width --) {
  8003fc:	01b05963          	blez	s11,80040e <vprintfmt+0x244>
  800400:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
  800402:	85a6                	mv	a1,s1
  800404:	02000513          	li	a0,32
  800408:	9902                	jalr	s2
            for (; width > 0; width --) {
  80040a:	fe0d9be3          	bnez	s11,800400 <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
  80040e:	6a02                	ld	s4,0(sp)
  800410:	bbd5                	j	800204 <vprintfmt+0x3a>
    if (lflag >= 2) {
  800412:	4705                	li	a4,1
            precision = va_arg(ap, int);
  800414:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
  800418:	01174463          	blt	a4,a7,800420 <vprintfmt+0x256>
    else if (lflag) {
  80041c:	08088d63          	beqz	a7,8004b6 <vprintfmt+0x2ec>
        return va_arg(*ap, long);
  800420:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
  800424:	0a044d63          	bltz	s0,8004de <vprintfmt+0x314>
            num = getint(&ap, lflag);
  800428:	8622                	mv	a2,s0
  80042a:	8a66                	mv	s4,s9
  80042c:	46a9                	li	a3,10
  80042e:	bdcd                	j	800320 <vprintfmt+0x156>
            err = va_arg(ap, int);
  800430:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  800434:	4761                	li	a4,24
            err = va_arg(ap, int);
  800436:	0a21                	addi	s4,s4,8
            if (err < 0) {
  800438:	41f7d69b          	sraiw	a3,a5,0x1f
  80043c:	8fb5                	xor	a5,a5,a3
  80043e:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  800442:	02d74163          	blt	a4,a3,800464 <vprintfmt+0x29a>
  800446:	00369793          	slli	a5,a3,0x3
  80044a:	97de                	add	a5,a5,s7
  80044c:	639c                	ld	a5,0(a5)
  80044e:	cb99                	beqz	a5,800464 <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
  800450:	86be                	mv	a3,a5
  800452:	00000617          	auipc	a2,0x0
  800456:	25660613          	addi	a2,a2,598 # 8006a8 <main+0x140>
  80045a:	85a6                	mv	a1,s1
  80045c:	854a                	mv	a0,s2
  80045e:	0ce000ef          	jal	ra,80052c <printfmt>
  800462:	b34d                	j	800204 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
  800464:	00000617          	auipc	a2,0x0
  800468:	23460613          	addi	a2,a2,564 # 800698 <main+0x130>
  80046c:	85a6                	mv	a1,s1
  80046e:	854a                	mv	a0,s2
  800470:	0bc000ef          	jal	ra,80052c <printfmt>
  800474:	bb41                	j	800204 <vprintfmt+0x3a>
                p = "(null)";
  800476:	00000417          	auipc	s0,0x0
  80047a:	21a40413          	addi	s0,s0,538 # 800690 <main+0x128>
                for (width -= strnlen(p, precision); width > 0; width --) {
  80047e:	85e2                	mv	a1,s8
  800480:	8522                	mv	a0,s0
  800482:	e43e                	sd	a5,8(sp)
  800484:	0c8000ef          	jal	ra,80054c <strnlen>
  800488:	40ad8dbb          	subw	s11,s11,a0
  80048c:	01b05b63          	blez	s11,8004a2 <vprintfmt+0x2d8>
                    putch(padc, putdat);
  800490:	67a2                	ld	a5,8(sp)
  800492:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
  800496:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
  800498:	85a6                	mv	a1,s1
  80049a:	8552                	mv	a0,s4
  80049c:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
  80049e:	fe0d9ce3          	bnez	s11,800496 <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8004a2:	00044783          	lbu	a5,0(s0)
  8004a6:	00140a13          	addi	s4,s0,1
  8004aa:	0007851b          	sext.w	a0,a5
  8004ae:	d3a5                	beqz	a5,80040e <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
  8004b0:	05e00413          	li	s0,94
  8004b4:	bf39                	j	8003d2 <vprintfmt+0x208>
        return va_arg(*ap, int);
  8004b6:	000a2403          	lw	s0,0(s4)
  8004ba:	b7ad                	j	800424 <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
  8004bc:	000a6603          	lwu	a2,0(s4)
  8004c0:	46a1                	li	a3,8
  8004c2:	8a2e                	mv	s4,a1
  8004c4:	bdb1                	j	800320 <vprintfmt+0x156>
  8004c6:	000a6603          	lwu	a2,0(s4)
  8004ca:	46a9                	li	a3,10
  8004cc:	8a2e                	mv	s4,a1
  8004ce:	bd89                	j	800320 <vprintfmt+0x156>
  8004d0:	000a6603          	lwu	a2,0(s4)
  8004d4:	46c1                	li	a3,16
  8004d6:	8a2e                	mv	s4,a1
  8004d8:	b5a1                	j	800320 <vprintfmt+0x156>
                    putch(ch, putdat);
  8004da:	9902                	jalr	s2
  8004dc:	bf09                	j	8003ee <vprintfmt+0x224>
                putch('-', putdat);
  8004de:	85a6                	mv	a1,s1
  8004e0:	02d00513          	li	a0,45
  8004e4:	e03e                	sd	a5,0(sp)
  8004e6:	9902                	jalr	s2
                num = -(long long)num;
  8004e8:	6782                	ld	a5,0(sp)
  8004ea:	8a66                	mv	s4,s9
  8004ec:	40800633          	neg	a2,s0
  8004f0:	46a9                	li	a3,10
  8004f2:	b53d                	j	800320 <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
  8004f4:	03b05163          	blez	s11,800516 <vprintfmt+0x34c>
  8004f8:	02d00693          	li	a3,45
  8004fc:	f6d79de3          	bne	a5,a3,800476 <vprintfmt+0x2ac>
                p = "(null)";
  800500:	00000417          	auipc	s0,0x0
  800504:	19040413          	addi	s0,s0,400 # 800690 <main+0x128>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800508:	02800793          	li	a5,40
  80050c:	02800513          	li	a0,40
  800510:	00140a13          	addi	s4,s0,1
  800514:	bd6d                	j	8003ce <vprintfmt+0x204>
  800516:	00000a17          	auipc	s4,0x0
  80051a:	17ba0a13          	addi	s4,s4,379 # 800691 <main+0x129>
  80051e:	02800513          	li	a0,40
  800522:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
  800526:	05e00413          	li	s0,94
  80052a:	b565                	j	8003d2 <vprintfmt+0x208>

000000000080052c <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  80052c:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
  80052e:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  800532:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
  800534:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  800536:	ec06                	sd	ra,24(sp)
  800538:	f83a                	sd	a4,48(sp)
  80053a:	fc3e                	sd	a5,56(sp)
  80053c:	e0c2                	sd	a6,64(sp)
  80053e:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  800540:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
  800542:	c89ff0ef          	jal	ra,8001ca <vprintfmt>
}
  800546:	60e2                	ld	ra,24(sp)
  800548:	6161                	addi	sp,sp,80
  80054a:	8082                	ret

000000000080054c <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
  80054c:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
  80054e:	e589                	bnez	a1,800558 <strnlen+0xc>
  800550:	a811                	j	800564 <strnlen+0x18>
        cnt ++;
  800552:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
  800554:	00f58863          	beq	a1,a5,800564 <strnlen+0x18>
  800558:	00f50733          	add	a4,a0,a5
  80055c:	00074703          	lbu	a4,0(a4)
  800560:	fb6d                	bnez	a4,800552 <strnlen+0x6>
  800562:	85be                	mv	a1,a5
    }
    return cnt;
}
  800564:	852e                	mv	a0,a1
  800566:	8082                	ret

0000000000800568 <main>:
#include <stdio.h>
#include <ulib.h>

int
main(void) {
  800568:	1141                	addi	sp,sp,-16
    int pid, ret;
    cprintf("I am the parent. Forking the child...\n");
  80056a:	00000517          	auipc	a0,0x0
  80056e:	42650513          	addi	a0,a0,1062 # 800990 <error_string+0xc8>
main(void) {
  800572:	e406                	sd	ra,8(sp)
  800574:	e022                	sd	s0,0(sp)
    cprintf("I am the parent. Forking the child...\n");
  800576:	b2dff0ef          	jal	ra,8000a2 <cprintf>
    if ((pid = fork()) == 0) {
  80057a:	bd1ff0ef          	jal	ra,80014a <fork>
  80057e:	e901                	bnez	a0,80058e <main+0x26>
        cprintf("I am the child. spinning ...\n");
  800580:	00000517          	auipc	a0,0x0
  800584:	43850513          	addi	a0,a0,1080 # 8009b8 <error_string+0xf0>
  800588:	b1bff0ef          	jal	ra,8000a2 <cprintf>
        while (1);
  80058c:	a001                	j	80058c <main+0x24>
    }
    cprintf("I am the parent. Running the child...\n");
  80058e:	842a                	mv	s0,a0
  800590:	00000517          	auipc	a0,0x0
  800594:	44850513          	addi	a0,a0,1096 # 8009d8 <error_string+0x110>
  800598:	b0bff0ef          	jal	ra,8000a2 <cprintf>

    yield();
  80059c:	bb3ff0ef          	jal	ra,80014e <yield>
    yield();
  8005a0:	bafff0ef          	jal	ra,80014e <yield>
    yield();
  8005a4:	babff0ef          	jal	ra,80014e <yield>

    cprintf("I am the parent.  Killing the child...\n");
  8005a8:	00000517          	auipc	a0,0x0
  8005ac:	45850513          	addi	a0,a0,1112 # 800a00 <error_string+0x138>
  8005b0:	af3ff0ef          	jal	ra,8000a2 <cprintf>

    assert((ret = kill(pid)) == 0);
  8005b4:	8522                	mv	a0,s0
  8005b6:	b9bff0ef          	jal	ra,800150 <kill>
  8005ba:	ed31                	bnez	a0,800616 <main+0xae>
    cprintf("kill returns %d\n", ret);
  8005bc:	4581                	li	a1,0
  8005be:	00000517          	auipc	a0,0x0
  8005c2:	4aa50513          	addi	a0,a0,1194 # 800a68 <error_string+0x1a0>
  8005c6:	addff0ef          	jal	ra,8000a2 <cprintf>

    assert((ret = waitpid(pid, NULL)) == 0);
  8005ca:	4581                	li	a1,0
  8005cc:	8522                	mv	a0,s0
  8005ce:	b7fff0ef          	jal	ra,80014c <waitpid>
  8005d2:	e11d                	bnez	a0,8005f8 <main+0x90>
    cprintf("wait returns %d\n", ret);
  8005d4:	4581                	li	a1,0
  8005d6:	00000517          	auipc	a0,0x0
  8005da:	4ca50513          	addi	a0,a0,1226 # 800aa0 <error_string+0x1d8>
  8005de:	ac5ff0ef          	jal	ra,8000a2 <cprintf>

    cprintf("spin may pass.\n");
  8005e2:	00000517          	auipc	a0,0x0
  8005e6:	4d650513          	addi	a0,a0,1238 # 800ab8 <error_string+0x1f0>
  8005ea:	ab9ff0ef          	jal	ra,8000a2 <cprintf>
    return 0;
}
  8005ee:	60a2                	ld	ra,8(sp)
  8005f0:	6402                	ld	s0,0(sp)
  8005f2:	4501                	li	a0,0
  8005f4:	0141                	addi	sp,sp,16
  8005f6:	8082                	ret
    assert((ret = waitpid(pid, NULL)) == 0);
  8005f8:	00000697          	auipc	a3,0x0
  8005fc:	48868693          	addi	a3,a3,1160 # 800a80 <error_string+0x1b8>
  800600:	00000617          	auipc	a2,0x0
  800604:	44060613          	addi	a2,a2,1088 # 800a40 <error_string+0x178>
  800608:	45dd                	li	a1,23
  80060a:	00000517          	auipc	a0,0x0
  80060e:	44e50513          	addi	a0,a0,1102 # 800a58 <error_string+0x190>
  800612:	a15ff0ef          	jal	ra,800026 <__panic>
    assert((ret = kill(pid)) == 0);
  800616:	00000697          	auipc	a3,0x0
  80061a:	41268693          	addi	a3,a3,1042 # 800a28 <error_string+0x160>
  80061e:	00000617          	auipc	a2,0x0
  800622:	42260613          	addi	a2,a2,1058 # 800a40 <error_string+0x178>
  800626:	45d1                	li	a1,20
  800628:	00000517          	auipc	a0,0x0
  80062c:	43050513          	addi	a0,a0,1072 # 800a58 <error_string+0x190>
  800630:	9f7ff0ef          	jal	ra,800026 <__panic>
