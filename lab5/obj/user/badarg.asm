
obj/__user_badarg.out:     file format elf64-littleriscv


Disassembly of section .text:

0000000000800020 <_start>:
.text
.globl _start
_start:
    # call user-program function
    call umain
  800020:	12a000ef          	jal	ra,80014a <umain>
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
  80003a:	61a50513          	addi	a0,a0,1562 # 800650 <main+0xf0>
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
  800056:	00001517          	auipc	a0,0x1
  80005a:	95250513          	addi	a0,a0,-1710 # 8009a8 <error_string+0xd0>
  80005e:	044000ef          	jal	ra,8000a2 <cprintf>
    va_end(ap);
    exit(-E_PANIC);
  800062:	5559                	li	a0,-10
  800064:	0ca000ef          	jal	ra,80012e <exit>

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
  800070:	0b8000ef          	jal	ra,800128 <sys_putc>
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
  800096:	12c000ef          	jal	ra,8001c2 <vprintfmt>
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
  8000cc:	0f6000ef          	jal	ra,8001c2 <vprintfmt>
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

0000000000800128 <sys_putc>:
sys_getpid(void) {
    return syscall(SYS_getpid);
}

int
sys_putc(int64_t c) {
  800128:	85aa                	mv	a1,a0
    return syscall(SYS_putc, c);
  80012a:	4579                	li	a0,30
  80012c:	b775                	j	8000d8 <syscall>

000000000080012e <exit>:
#include <syscall.h>
#include <stdio.h>
#include <ulib.h>

void
exit(int error_code) {
  80012e:	1141                	addi	sp,sp,-16
  800130:	e406                	sd	ra,8(sp)
    sys_exit(error_code);
  800132:	fe1ff0ef          	jal	ra,800112 <sys_exit>
    cprintf("BUG: exit failed.\n");
  800136:	00000517          	auipc	a0,0x0
  80013a:	53a50513          	addi	a0,a0,1338 # 800670 <main+0x110>
  80013e:	f65ff0ef          	jal	ra,8000a2 <cprintf>
    while (1);
  800142:	a001                	j	800142 <exit+0x14>

0000000000800144 <fork>:
}

int
fork(void) {
    return sys_fork();
  800144:	bfd1                	j	800118 <sys_fork>

0000000000800146 <waitpid>:
    return sys_wait(0, NULL);
}

int
waitpid(int pid, int *store) {
    return sys_wait(pid, store);
  800146:	bfd9                	j	80011c <sys_wait>

0000000000800148 <yield>:
}

void
yield(void) {
    sys_yield();
  800148:	bff1                	j	800124 <sys_yield>

000000000080014a <umain>:
#include <ulib.h>

int main(void);

void
umain(void) {
  80014a:	1141                	addi	sp,sp,-16
  80014c:	e406                	sd	ra,8(sp)
    int ret = main();
  80014e:	412000ef          	jal	ra,800560 <main>
    exit(ret);
  800152:	fddff0ef          	jal	ra,80012e <exit>

0000000000800156 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
  800156:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  80015a:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
  80015c:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  800160:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
  800162:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
  800166:	f022                	sd	s0,32(sp)
  800168:	ec26                	sd	s1,24(sp)
  80016a:	e84a                	sd	s2,16(sp)
  80016c:	f406                	sd	ra,40(sp)
  80016e:	e44e                	sd	s3,8(sp)
  800170:	84aa                	mv	s1,a0
  800172:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  800174:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
  800178:	2a01                	sext.w	s4,s4
    if (num >= base) {
  80017a:	03067e63          	bgeu	a2,a6,8001b6 <printnum+0x60>
  80017e:	89be                	mv	s3,a5
        while (-- width > 0)
  800180:	00805763          	blez	s0,80018e <printnum+0x38>
  800184:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
  800186:	85ca                	mv	a1,s2
  800188:	854e                	mv	a0,s3
  80018a:	9482                	jalr	s1
        while (-- width > 0)
  80018c:	fc65                	bnez	s0,800184 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  80018e:	1a02                	slli	s4,s4,0x20
  800190:	00000797          	auipc	a5,0x0
  800194:	4f878793          	addi	a5,a5,1272 # 800688 <main+0x128>
  800198:	020a5a13          	srli	s4,s4,0x20
  80019c:	9a3e                	add	s4,s4,a5
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
  80019e:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
  8001a0:	000a4503          	lbu	a0,0(s4)
}
  8001a4:	70a2                	ld	ra,40(sp)
  8001a6:	69a2                	ld	s3,8(sp)
  8001a8:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
  8001aa:	85ca                	mv	a1,s2
  8001ac:	87a6                	mv	a5,s1
}
  8001ae:	6942                	ld	s2,16(sp)
  8001b0:	64e2                	ld	s1,24(sp)
  8001b2:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
  8001b4:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
  8001b6:	03065633          	divu	a2,a2,a6
  8001ba:	8722                	mv	a4,s0
  8001bc:	f9bff0ef          	jal	ra,800156 <printnum>
  8001c0:	b7f9                	j	80018e <printnum+0x38>

00000000008001c2 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  8001c2:	7119                	addi	sp,sp,-128
  8001c4:	f4a6                	sd	s1,104(sp)
  8001c6:	f0ca                	sd	s2,96(sp)
  8001c8:	ecce                	sd	s3,88(sp)
  8001ca:	e8d2                	sd	s4,80(sp)
  8001cc:	e4d6                	sd	s5,72(sp)
  8001ce:	e0da                	sd	s6,64(sp)
  8001d0:	fc5e                	sd	s7,56(sp)
  8001d2:	f06a                	sd	s10,32(sp)
  8001d4:	fc86                	sd	ra,120(sp)
  8001d6:	f8a2                	sd	s0,112(sp)
  8001d8:	f862                	sd	s8,48(sp)
  8001da:	f466                	sd	s9,40(sp)
  8001dc:	ec6e                	sd	s11,24(sp)
  8001de:	892a                	mv	s2,a0
  8001e0:	84ae                	mv	s1,a1
  8001e2:	8d32                	mv	s10,a2
  8001e4:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001e6:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
  8001ea:	5b7d                	li	s6,-1
  8001ec:	00000a97          	auipc	s5,0x0
  8001f0:	4d0a8a93          	addi	s5,s5,1232 # 8006bc <main+0x15c>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8001f4:	00000b97          	auipc	s7,0x0
  8001f8:	6e4b8b93          	addi	s7,s7,1764 # 8008d8 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001fc:	000d4503          	lbu	a0,0(s10)
  800200:	001d0413          	addi	s0,s10,1
  800204:	01350a63          	beq	a0,s3,800218 <vprintfmt+0x56>
            if (ch == '\0') {
  800208:	c121                	beqz	a0,800248 <vprintfmt+0x86>
            putch(ch, putdat);
  80020a:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  80020c:	0405                	addi	s0,s0,1
            putch(ch, putdat);
  80020e:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800210:	fff44503          	lbu	a0,-1(s0)
  800214:	ff351ae3          	bne	a0,s3,800208 <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
  800218:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
  80021c:	02000793          	li	a5,32
        lflag = altflag = 0;
  800220:	4c81                	li	s9,0
  800222:	4881                	li	a7,0
        width = precision = -1;
  800224:	5c7d                	li	s8,-1
  800226:	5dfd                	li	s11,-1
  800228:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
  80022c:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
  80022e:	fdd6059b          	addiw	a1,a2,-35
  800232:	0ff5f593          	zext.b	a1,a1
  800236:	00140d13          	addi	s10,s0,1
  80023a:	04b56263          	bltu	a0,a1,80027e <vprintfmt+0xbc>
  80023e:	058a                	slli	a1,a1,0x2
  800240:	95d6                	add	a1,a1,s5
  800242:	4194                	lw	a3,0(a1)
  800244:	96d6                	add	a3,a3,s5
  800246:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
  800248:	70e6                	ld	ra,120(sp)
  80024a:	7446                	ld	s0,112(sp)
  80024c:	74a6                	ld	s1,104(sp)
  80024e:	7906                	ld	s2,96(sp)
  800250:	69e6                	ld	s3,88(sp)
  800252:	6a46                	ld	s4,80(sp)
  800254:	6aa6                	ld	s5,72(sp)
  800256:	6b06                	ld	s6,64(sp)
  800258:	7be2                	ld	s7,56(sp)
  80025a:	7c42                	ld	s8,48(sp)
  80025c:	7ca2                	ld	s9,40(sp)
  80025e:	7d02                	ld	s10,32(sp)
  800260:	6de2                	ld	s11,24(sp)
  800262:	6109                	addi	sp,sp,128
  800264:	8082                	ret
            padc = '0';
  800266:	87b2                	mv	a5,a2
            goto reswitch;
  800268:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
  80026c:	846a                	mv	s0,s10
  80026e:	00140d13          	addi	s10,s0,1
  800272:	fdd6059b          	addiw	a1,a2,-35
  800276:	0ff5f593          	zext.b	a1,a1
  80027a:	fcb572e3          	bgeu	a0,a1,80023e <vprintfmt+0x7c>
            putch('%', putdat);
  80027e:	85a6                	mv	a1,s1
  800280:	02500513          	li	a0,37
  800284:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
  800286:	fff44783          	lbu	a5,-1(s0)
  80028a:	8d22                	mv	s10,s0
  80028c:	f73788e3          	beq	a5,s3,8001fc <vprintfmt+0x3a>
  800290:	ffed4783          	lbu	a5,-2(s10)
  800294:	1d7d                	addi	s10,s10,-1
  800296:	ff379de3          	bne	a5,s3,800290 <vprintfmt+0xce>
  80029a:	b78d                	j	8001fc <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
  80029c:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
  8002a0:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
  8002a4:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
  8002a6:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
  8002aa:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
  8002ae:	02d86463          	bltu	a6,a3,8002d6 <vprintfmt+0x114>
                ch = *fmt;
  8002b2:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
  8002b6:	002c169b          	slliw	a3,s8,0x2
  8002ba:	0186873b          	addw	a4,a3,s8
  8002be:	0017171b          	slliw	a4,a4,0x1
  8002c2:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
  8002c4:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
  8002c8:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
  8002ca:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
  8002ce:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
  8002d2:	fed870e3          	bgeu	a6,a3,8002b2 <vprintfmt+0xf0>
            if (width < 0)
  8002d6:	f40ddce3          	bgez	s11,80022e <vprintfmt+0x6c>
                width = precision, precision = -1;
  8002da:	8de2                	mv	s11,s8
  8002dc:	5c7d                	li	s8,-1
  8002de:	bf81                	j	80022e <vprintfmt+0x6c>
            if (width < 0)
  8002e0:	fffdc693          	not	a3,s11
  8002e4:	96fd                	srai	a3,a3,0x3f
  8002e6:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
  8002ea:	00144603          	lbu	a2,1(s0)
  8002ee:	2d81                	sext.w	s11,s11
  8002f0:	846a                	mv	s0,s10
            goto reswitch;
  8002f2:	bf35                	j	80022e <vprintfmt+0x6c>
            precision = va_arg(ap, int);
  8002f4:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
  8002f8:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
  8002fc:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
  8002fe:	846a                	mv	s0,s10
            goto process_precision;
  800300:	bfd9                	j	8002d6 <vprintfmt+0x114>
    if (lflag >= 2) {
  800302:	4705                	li	a4,1
            precision = va_arg(ap, int);
  800304:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  800308:	01174463          	blt	a4,a7,800310 <vprintfmt+0x14e>
    else if (lflag) {
  80030c:	1a088e63          	beqz	a7,8004c8 <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
  800310:	000a3603          	ld	a2,0(s4)
  800314:	46c1                	li	a3,16
  800316:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
  800318:	2781                	sext.w	a5,a5
  80031a:	876e                	mv	a4,s11
  80031c:	85a6                	mv	a1,s1
  80031e:	854a                	mv	a0,s2
  800320:	e37ff0ef          	jal	ra,800156 <printnum>
            break;
  800324:	bde1                	j	8001fc <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
  800326:	000a2503          	lw	a0,0(s4)
  80032a:	85a6                	mv	a1,s1
  80032c:	0a21                	addi	s4,s4,8
  80032e:	9902                	jalr	s2
            break;
  800330:	b5f1                	j	8001fc <vprintfmt+0x3a>
    if (lflag >= 2) {
  800332:	4705                	li	a4,1
            precision = va_arg(ap, int);
  800334:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  800338:	01174463          	blt	a4,a7,800340 <vprintfmt+0x17e>
    else if (lflag) {
  80033c:	18088163          	beqz	a7,8004be <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
  800340:	000a3603          	ld	a2,0(s4)
  800344:	46a9                	li	a3,10
  800346:	8a2e                	mv	s4,a1
  800348:	bfc1                	j	800318 <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
  80034a:	00144603          	lbu	a2,1(s0)
            altflag = 1;
  80034e:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
  800350:	846a                	mv	s0,s10
            goto reswitch;
  800352:	bdf1                	j	80022e <vprintfmt+0x6c>
            putch(ch, putdat);
  800354:	85a6                	mv	a1,s1
  800356:	02500513          	li	a0,37
  80035a:	9902                	jalr	s2
            break;
  80035c:	b545                	j	8001fc <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
  80035e:	00144603          	lbu	a2,1(s0)
            lflag ++;
  800362:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
  800364:	846a                	mv	s0,s10
            goto reswitch;
  800366:	b5e1                	j	80022e <vprintfmt+0x6c>
    if (lflag >= 2) {
  800368:	4705                	li	a4,1
            precision = va_arg(ap, int);
  80036a:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  80036e:	01174463          	blt	a4,a7,800376 <vprintfmt+0x1b4>
    else if (lflag) {
  800372:	14088163          	beqz	a7,8004b4 <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
  800376:	000a3603          	ld	a2,0(s4)
  80037a:	46a1                	li	a3,8
  80037c:	8a2e                	mv	s4,a1
  80037e:	bf69                	j	800318 <vprintfmt+0x156>
            putch('0', putdat);
  800380:	03000513          	li	a0,48
  800384:	85a6                	mv	a1,s1
  800386:	e03e                	sd	a5,0(sp)
  800388:	9902                	jalr	s2
            putch('x', putdat);
  80038a:	85a6                	mv	a1,s1
  80038c:	07800513          	li	a0,120
  800390:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  800392:	0a21                	addi	s4,s4,8
            goto number;
  800394:	6782                	ld	a5,0(sp)
  800396:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  800398:	ff8a3603          	ld	a2,-8(s4)
            goto number;
  80039c:	bfb5                	j	800318 <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
  80039e:	000a3403          	ld	s0,0(s4)
  8003a2:	008a0713          	addi	a4,s4,8
  8003a6:	e03a                	sd	a4,0(sp)
  8003a8:	14040263          	beqz	s0,8004ec <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
  8003ac:	0fb05763          	blez	s11,80049a <vprintfmt+0x2d8>
  8003b0:	02d00693          	li	a3,45
  8003b4:	0cd79163          	bne	a5,a3,800476 <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8003b8:	00044783          	lbu	a5,0(s0)
  8003bc:	0007851b          	sext.w	a0,a5
  8003c0:	cf85                	beqz	a5,8003f8 <vprintfmt+0x236>
  8003c2:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
  8003c6:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8003ca:	000c4563          	bltz	s8,8003d4 <vprintfmt+0x212>
  8003ce:	3c7d                	addiw	s8,s8,-1
  8003d0:	036c0263          	beq	s8,s6,8003f4 <vprintfmt+0x232>
                    putch('?', putdat);
  8003d4:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
  8003d6:	0e0c8e63          	beqz	s9,8004d2 <vprintfmt+0x310>
  8003da:	3781                	addiw	a5,a5,-32
  8003dc:	0ef47b63          	bgeu	s0,a5,8004d2 <vprintfmt+0x310>
                    putch('?', putdat);
  8003e0:	03f00513          	li	a0,63
  8003e4:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8003e6:	000a4783          	lbu	a5,0(s4)
  8003ea:	3dfd                	addiw	s11,s11,-1
  8003ec:	0a05                	addi	s4,s4,1
  8003ee:	0007851b          	sext.w	a0,a5
  8003f2:	ffe1                	bnez	a5,8003ca <vprintfmt+0x208>
            for (; width > 0; width --) {
  8003f4:	01b05963          	blez	s11,800406 <vprintfmt+0x244>
  8003f8:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
  8003fa:	85a6                	mv	a1,s1
  8003fc:	02000513          	li	a0,32
  800400:	9902                	jalr	s2
            for (; width > 0; width --) {
  800402:	fe0d9be3          	bnez	s11,8003f8 <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
  800406:	6a02                	ld	s4,0(sp)
  800408:	bbd5                	j	8001fc <vprintfmt+0x3a>
    if (lflag >= 2) {
  80040a:	4705                	li	a4,1
            precision = va_arg(ap, int);
  80040c:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
  800410:	01174463          	blt	a4,a7,800418 <vprintfmt+0x256>
    else if (lflag) {
  800414:	08088d63          	beqz	a7,8004ae <vprintfmt+0x2ec>
        return va_arg(*ap, long);
  800418:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
  80041c:	0a044d63          	bltz	s0,8004d6 <vprintfmt+0x314>
            num = getint(&ap, lflag);
  800420:	8622                	mv	a2,s0
  800422:	8a66                	mv	s4,s9
  800424:	46a9                	li	a3,10
  800426:	bdcd                	j	800318 <vprintfmt+0x156>
            err = va_arg(ap, int);
  800428:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  80042c:	4761                	li	a4,24
            err = va_arg(ap, int);
  80042e:	0a21                	addi	s4,s4,8
            if (err < 0) {
  800430:	41f7d69b          	sraiw	a3,a5,0x1f
  800434:	8fb5                	xor	a5,a5,a3
  800436:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  80043a:	02d74163          	blt	a4,a3,80045c <vprintfmt+0x29a>
  80043e:	00369793          	slli	a5,a3,0x3
  800442:	97de                	add	a5,a5,s7
  800444:	639c                	ld	a5,0(a5)
  800446:	cb99                	beqz	a5,80045c <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
  800448:	86be                	mv	a3,a5
  80044a:	00000617          	auipc	a2,0x0
  80044e:	26e60613          	addi	a2,a2,622 # 8006b8 <main+0x158>
  800452:	85a6                	mv	a1,s1
  800454:	854a                	mv	a0,s2
  800456:	0ce000ef          	jal	ra,800524 <printfmt>
  80045a:	b34d                	j	8001fc <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
  80045c:	00000617          	auipc	a2,0x0
  800460:	24c60613          	addi	a2,a2,588 # 8006a8 <main+0x148>
  800464:	85a6                	mv	a1,s1
  800466:	854a                	mv	a0,s2
  800468:	0bc000ef          	jal	ra,800524 <printfmt>
  80046c:	bb41                	j	8001fc <vprintfmt+0x3a>
                p = "(null)";
  80046e:	00000417          	auipc	s0,0x0
  800472:	23240413          	addi	s0,s0,562 # 8006a0 <main+0x140>
                for (width -= strnlen(p, precision); width > 0; width --) {
  800476:	85e2                	mv	a1,s8
  800478:	8522                	mv	a0,s0
  80047a:	e43e                	sd	a5,8(sp)
  80047c:	0c8000ef          	jal	ra,800544 <strnlen>
  800480:	40ad8dbb          	subw	s11,s11,a0
  800484:	01b05b63          	blez	s11,80049a <vprintfmt+0x2d8>
                    putch(padc, putdat);
  800488:	67a2                	ld	a5,8(sp)
  80048a:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
  80048e:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
  800490:	85a6                	mv	a1,s1
  800492:	8552                	mv	a0,s4
  800494:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
  800496:	fe0d9ce3          	bnez	s11,80048e <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80049a:	00044783          	lbu	a5,0(s0)
  80049e:	00140a13          	addi	s4,s0,1
  8004a2:	0007851b          	sext.w	a0,a5
  8004a6:	d3a5                	beqz	a5,800406 <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
  8004a8:	05e00413          	li	s0,94
  8004ac:	bf39                	j	8003ca <vprintfmt+0x208>
        return va_arg(*ap, int);
  8004ae:	000a2403          	lw	s0,0(s4)
  8004b2:	b7ad                	j	80041c <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
  8004b4:	000a6603          	lwu	a2,0(s4)
  8004b8:	46a1                	li	a3,8
  8004ba:	8a2e                	mv	s4,a1
  8004bc:	bdb1                	j	800318 <vprintfmt+0x156>
  8004be:	000a6603          	lwu	a2,0(s4)
  8004c2:	46a9                	li	a3,10
  8004c4:	8a2e                	mv	s4,a1
  8004c6:	bd89                	j	800318 <vprintfmt+0x156>
  8004c8:	000a6603          	lwu	a2,0(s4)
  8004cc:	46c1                	li	a3,16
  8004ce:	8a2e                	mv	s4,a1
  8004d0:	b5a1                	j	800318 <vprintfmt+0x156>
                    putch(ch, putdat);
  8004d2:	9902                	jalr	s2
  8004d4:	bf09                	j	8003e6 <vprintfmt+0x224>
                putch('-', putdat);
  8004d6:	85a6                	mv	a1,s1
  8004d8:	02d00513          	li	a0,45
  8004dc:	e03e                	sd	a5,0(sp)
  8004de:	9902                	jalr	s2
                num = -(long long)num;
  8004e0:	6782                	ld	a5,0(sp)
  8004e2:	8a66                	mv	s4,s9
  8004e4:	40800633          	neg	a2,s0
  8004e8:	46a9                	li	a3,10
  8004ea:	b53d                	j	800318 <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
  8004ec:	03b05163          	blez	s11,80050e <vprintfmt+0x34c>
  8004f0:	02d00693          	li	a3,45
  8004f4:	f6d79de3          	bne	a5,a3,80046e <vprintfmt+0x2ac>
                p = "(null)";
  8004f8:	00000417          	auipc	s0,0x0
  8004fc:	1a840413          	addi	s0,s0,424 # 8006a0 <main+0x140>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800500:	02800793          	li	a5,40
  800504:	02800513          	li	a0,40
  800508:	00140a13          	addi	s4,s0,1
  80050c:	bd6d                	j	8003c6 <vprintfmt+0x204>
  80050e:	00000a17          	auipc	s4,0x0
  800512:	193a0a13          	addi	s4,s4,403 # 8006a1 <main+0x141>
  800516:	02800513          	li	a0,40
  80051a:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
  80051e:	05e00413          	li	s0,94
  800522:	b565                	j	8003ca <vprintfmt+0x208>

0000000000800524 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  800524:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
  800526:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  80052a:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
  80052c:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  80052e:	ec06                	sd	ra,24(sp)
  800530:	f83a                	sd	a4,48(sp)
  800532:	fc3e                	sd	a5,56(sp)
  800534:	e0c2                	sd	a6,64(sp)
  800536:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  800538:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
  80053a:	c89ff0ef          	jal	ra,8001c2 <vprintfmt>
}
  80053e:	60e2                	ld	ra,24(sp)
  800540:	6161                	addi	sp,sp,80
  800542:	8082                	ret

0000000000800544 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
  800544:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
  800546:	e589                	bnez	a1,800550 <strnlen+0xc>
  800548:	a811                	j	80055c <strnlen+0x18>
        cnt ++;
  80054a:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
  80054c:	00f58863          	beq	a1,a5,80055c <strnlen+0x18>
  800550:	00f50733          	add	a4,a0,a5
  800554:	00074703          	lbu	a4,0(a4)
  800558:	fb6d                	bnez	a4,80054a <strnlen+0x6>
  80055a:	85be                	mv	a1,a5
    }
    return cnt;
}
  80055c:	852e                	mv	a0,a1
  80055e:	8082                	ret

0000000000800560 <main>:
#include <stdio.h>
#include <ulib.h>

int
main(void) {
  800560:	1101                	addi	sp,sp,-32
  800562:	ec06                	sd	ra,24(sp)
  800564:	e822                	sd	s0,16(sp)
    int pid, exit_code;
    if ((pid = fork()) == 0) {
  800566:	bdfff0ef          	jal	ra,800144 <fork>
  80056a:	c169                	beqz	a0,80062c <main+0xcc>
  80056c:	842a                	mv	s0,a0
        for (i = 0; i < 10; i ++) {
            yield();
        }
        exit(0xbeaf);
    }
    assert(pid > 0);
  80056e:	0aa05063          	blez	a0,80060e <main+0xae>
    assert(waitpid(-1, NULL) != 0);
  800572:	4581                	li	a1,0
  800574:	557d                	li	a0,-1
  800576:	bd1ff0ef          	jal	ra,800146 <waitpid>
  80057a:	c93d                	beqz	a0,8005f0 <main+0x90>
    assert(waitpid(pid, (void *)0xC0000000) != 0);
  80057c:	458d                	li	a1,3
  80057e:	05fa                	slli	a1,a1,0x1e
  800580:	8522                	mv	a0,s0
  800582:	bc5ff0ef          	jal	ra,800146 <waitpid>
  800586:	c531                	beqz	a0,8005d2 <main+0x72>
    assert(waitpid(pid, &exit_code) == 0 && exit_code == 0xbeaf);
  800588:	006c                	addi	a1,sp,12
  80058a:	8522                	mv	a0,s0
  80058c:	bbbff0ef          	jal	ra,800146 <waitpid>
  800590:	e115                	bnez	a0,8005b4 <main+0x54>
  800592:	4732                	lw	a4,12(sp)
  800594:	67b1                	lui	a5,0xc
  800596:	eaf78793          	addi	a5,a5,-337 # beaf <_start-0x7f4171>
  80059a:	00f71d63          	bne	a4,a5,8005b4 <main+0x54>
    cprintf("badarg pass.\n");
  80059e:	00000517          	auipc	a0,0x0
  8005a2:	4ba50513          	addi	a0,a0,1210 # 800a58 <error_string+0x180>
  8005a6:	afdff0ef          	jal	ra,8000a2 <cprintf>
    return 0;
}
  8005aa:	60e2                	ld	ra,24(sp)
  8005ac:	6442                	ld	s0,16(sp)
  8005ae:	4501                	li	a0,0
  8005b0:	6105                	addi	sp,sp,32
  8005b2:	8082                	ret
    assert(waitpid(pid, &exit_code) == 0 && exit_code == 0xbeaf);
  8005b4:	00000697          	auipc	a3,0x0
  8005b8:	46c68693          	addi	a3,a3,1132 # 800a20 <error_string+0x148>
  8005bc:	00000617          	auipc	a2,0x0
  8005c0:	3fc60613          	addi	a2,a2,1020 # 8009b8 <error_string+0xe0>
  8005c4:	45c9                	li	a1,18
  8005c6:	00000517          	auipc	a0,0x0
  8005ca:	40a50513          	addi	a0,a0,1034 # 8009d0 <error_string+0xf8>
  8005ce:	a59ff0ef          	jal	ra,800026 <__panic>
    assert(waitpid(pid, (void *)0xC0000000) != 0);
  8005d2:	00000697          	auipc	a3,0x0
  8005d6:	42668693          	addi	a3,a3,1062 # 8009f8 <error_string+0x120>
  8005da:	00000617          	auipc	a2,0x0
  8005de:	3de60613          	addi	a2,a2,990 # 8009b8 <error_string+0xe0>
  8005e2:	45c5                	li	a1,17
  8005e4:	00000517          	auipc	a0,0x0
  8005e8:	3ec50513          	addi	a0,a0,1004 # 8009d0 <error_string+0xf8>
  8005ec:	a3bff0ef          	jal	ra,800026 <__panic>
    assert(waitpid(-1, NULL) != 0);
  8005f0:	00000697          	auipc	a3,0x0
  8005f4:	3f068693          	addi	a3,a3,1008 # 8009e0 <error_string+0x108>
  8005f8:	00000617          	auipc	a2,0x0
  8005fc:	3c060613          	addi	a2,a2,960 # 8009b8 <error_string+0xe0>
  800600:	45c1                	li	a1,16
  800602:	00000517          	auipc	a0,0x0
  800606:	3ce50513          	addi	a0,a0,974 # 8009d0 <error_string+0xf8>
  80060a:	a1dff0ef          	jal	ra,800026 <__panic>
    assert(pid > 0);
  80060e:	00000697          	auipc	a3,0x0
  800612:	3a268693          	addi	a3,a3,930 # 8009b0 <error_string+0xd8>
  800616:	00000617          	auipc	a2,0x0
  80061a:	3a260613          	addi	a2,a2,930 # 8009b8 <error_string+0xe0>
  80061e:	45bd                	li	a1,15
  800620:	00000517          	auipc	a0,0x0
  800624:	3b050513          	addi	a0,a0,944 # 8009d0 <error_string+0xf8>
  800628:	9ffff0ef          	jal	ra,800026 <__panic>
        cprintf("fork ok.\n");
  80062c:	00000517          	auipc	a0,0x0
  800630:	37450513          	addi	a0,a0,884 # 8009a0 <error_string+0xc8>
  800634:	a6fff0ef          	jal	ra,8000a2 <cprintf>
  800638:	4429                	li	s0,10
        for (i = 0; i < 10; i ++) {
  80063a:	347d                	addiw	s0,s0,-1
            yield();
  80063c:	b0dff0ef          	jal	ra,800148 <yield>
        for (i = 0; i < 10; i ++) {
  800640:	fc6d                	bnez	s0,80063a <main+0xda>
        exit(0xbeaf);
  800642:	6531                	lui	a0,0xc
  800644:	eaf50513          	addi	a0,a0,-337 # beaf <_start-0x7f4171>
  800648:	ae7ff0ef          	jal	ra,80012e <exit>
