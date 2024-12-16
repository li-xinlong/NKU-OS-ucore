
obj/__user_exit.out:     file format elf64-littleriscv


Disassembly of section .text:

0000000000800020 <_start>:
.text
.globl _start
_start:
    # call user-program function
    call umain
  800020:	130000ef          	jal	ra,800150 <umain>
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
  80003a:	64250513          	addi	a0,a0,1602 # 800678 <main+0x112>
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
  80005a:	9d250513          	addi	a0,a0,-1582 # 800a28 <error_string+0x128>
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
  800096:	132000ef          	jal	ra,8001c8 <vprintfmt>
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
  8000cc:	0fc000ef          	jal	ra,8001c8 <vprintfmt>
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
  80013a:	56250513          	addi	a0,a0,1378 # 800698 <main+0x132>
  80013e:	f65ff0ef          	jal	ra,8000a2 <cprintf>
    while (1);
  800142:	a001                	j	800142 <exit+0x14>

0000000000800144 <fork>:
}

int
fork(void) {
    return sys_fork();
  800144:	bfd1                	j	800118 <sys_fork>

0000000000800146 <wait>:
}

int
wait(void) {
    return sys_wait(0, NULL);
  800146:	4581                	li	a1,0
  800148:	4501                	li	a0,0
  80014a:	bfc9                	j	80011c <sys_wait>

000000000080014c <waitpid>:
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

0000000000800150 <umain>:
#include <ulib.h>

int main(void);

void
umain(void) {
  800150:	1141                	addi	sp,sp,-16
  800152:	e406                	sd	ra,8(sp)
    int ret = main();
  800154:	412000ef          	jal	ra,800566 <main>
    exit(ret);
  800158:	fd7ff0ef          	jal	ra,80012e <exit>

000000000080015c <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
  80015c:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  800160:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
  800162:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  800166:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
  800168:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
  80016c:	f022                	sd	s0,32(sp)
  80016e:	ec26                	sd	s1,24(sp)
  800170:	e84a                	sd	s2,16(sp)
  800172:	f406                	sd	ra,40(sp)
  800174:	e44e                	sd	s3,8(sp)
  800176:	84aa                	mv	s1,a0
  800178:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  80017a:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
  80017e:	2a01                	sext.w	s4,s4
    if (num >= base) {
  800180:	03067e63          	bgeu	a2,a6,8001bc <printnum+0x60>
  800184:	89be                	mv	s3,a5
        while (-- width > 0)
  800186:	00805763          	blez	s0,800194 <printnum+0x38>
  80018a:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
  80018c:	85ca                	mv	a1,s2
  80018e:	854e                	mv	a0,s3
  800190:	9482                	jalr	s1
        while (-- width > 0)
  800192:	fc65                	bnez	s0,80018a <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  800194:	1a02                	slli	s4,s4,0x20
  800196:	00000797          	auipc	a5,0x0
  80019a:	51a78793          	addi	a5,a5,1306 # 8006b0 <main+0x14a>
  80019e:	020a5a13          	srli	s4,s4,0x20
  8001a2:	9a3e                	add	s4,s4,a5
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
  8001a4:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
  8001a6:	000a4503          	lbu	a0,0(s4)
}
  8001aa:	70a2                	ld	ra,40(sp)
  8001ac:	69a2                	ld	s3,8(sp)
  8001ae:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
  8001b0:	85ca                	mv	a1,s2
  8001b2:	87a6                	mv	a5,s1
}
  8001b4:	6942                	ld	s2,16(sp)
  8001b6:	64e2                	ld	s1,24(sp)
  8001b8:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
  8001ba:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
  8001bc:	03065633          	divu	a2,a2,a6
  8001c0:	8722                	mv	a4,s0
  8001c2:	f9bff0ef          	jal	ra,80015c <printnum>
  8001c6:	b7f9                	j	800194 <printnum+0x38>

00000000008001c8 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  8001c8:	7119                	addi	sp,sp,-128
  8001ca:	f4a6                	sd	s1,104(sp)
  8001cc:	f0ca                	sd	s2,96(sp)
  8001ce:	ecce                	sd	s3,88(sp)
  8001d0:	e8d2                	sd	s4,80(sp)
  8001d2:	e4d6                	sd	s5,72(sp)
  8001d4:	e0da                	sd	s6,64(sp)
  8001d6:	fc5e                	sd	s7,56(sp)
  8001d8:	f06a                	sd	s10,32(sp)
  8001da:	fc86                	sd	ra,120(sp)
  8001dc:	f8a2                	sd	s0,112(sp)
  8001de:	f862                	sd	s8,48(sp)
  8001e0:	f466                	sd	s9,40(sp)
  8001e2:	ec6e                	sd	s11,24(sp)
  8001e4:	892a                	mv	s2,a0
  8001e6:	84ae                	mv	s1,a1
  8001e8:	8d32                	mv	s10,a2
  8001ea:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001ec:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
  8001f0:	5b7d                	li	s6,-1
  8001f2:	00000a97          	auipc	s5,0x0
  8001f6:	4f2a8a93          	addi	s5,s5,1266 # 8006e4 <main+0x17e>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8001fa:	00000b97          	auipc	s7,0x0
  8001fe:	706b8b93          	addi	s7,s7,1798 # 800900 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800202:	000d4503          	lbu	a0,0(s10)
  800206:	001d0413          	addi	s0,s10,1
  80020a:	01350a63          	beq	a0,s3,80021e <vprintfmt+0x56>
            if (ch == '\0') {
  80020e:	c121                	beqz	a0,80024e <vprintfmt+0x86>
            putch(ch, putdat);
  800210:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800212:	0405                	addi	s0,s0,1
            putch(ch, putdat);
  800214:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800216:	fff44503          	lbu	a0,-1(s0)
  80021a:	ff351ae3          	bne	a0,s3,80020e <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
  80021e:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
  800222:	02000793          	li	a5,32
        lflag = altflag = 0;
  800226:	4c81                	li	s9,0
  800228:	4881                	li	a7,0
        width = precision = -1;
  80022a:	5c7d                	li	s8,-1
  80022c:	5dfd                	li	s11,-1
  80022e:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
  800232:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
  800234:	fdd6059b          	addiw	a1,a2,-35
  800238:	0ff5f593          	zext.b	a1,a1
  80023c:	00140d13          	addi	s10,s0,1
  800240:	04b56263          	bltu	a0,a1,800284 <vprintfmt+0xbc>
  800244:	058a                	slli	a1,a1,0x2
  800246:	95d6                	add	a1,a1,s5
  800248:	4194                	lw	a3,0(a1)
  80024a:	96d6                	add	a3,a3,s5
  80024c:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
  80024e:	70e6                	ld	ra,120(sp)
  800250:	7446                	ld	s0,112(sp)
  800252:	74a6                	ld	s1,104(sp)
  800254:	7906                	ld	s2,96(sp)
  800256:	69e6                	ld	s3,88(sp)
  800258:	6a46                	ld	s4,80(sp)
  80025a:	6aa6                	ld	s5,72(sp)
  80025c:	6b06                	ld	s6,64(sp)
  80025e:	7be2                	ld	s7,56(sp)
  800260:	7c42                	ld	s8,48(sp)
  800262:	7ca2                	ld	s9,40(sp)
  800264:	7d02                	ld	s10,32(sp)
  800266:	6de2                	ld	s11,24(sp)
  800268:	6109                	addi	sp,sp,128
  80026a:	8082                	ret
            padc = '0';
  80026c:	87b2                	mv	a5,a2
            goto reswitch;
  80026e:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
  800272:	846a                	mv	s0,s10
  800274:	00140d13          	addi	s10,s0,1
  800278:	fdd6059b          	addiw	a1,a2,-35
  80027c:	0ff5f593          	zext.b	a1,a1
  800280:	fcb572e3          	bgeu	a0,a1,800244 <vprintfmt+0x7c>
            putch('%', putdat);
  800284:	85a6                	mv	a1,s1
  800286:	02500513          	li	a0,37
  80028a:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
  80028c:	fff44783          	lbu	a5,-1(s0)
  800290:	8d22                	mv	s10,s0
  800292:	f73788e3          	beq	a5,s3,800202 <vprintfmt+0x3a>
  800296:	ffed4783          	lbu	a5,-2(s10)
  80029a:	1d7d                	addi	s10,s10,-1
  80029c:	ff379de3          	bne	a5,s3,800296 <vprintfmt+0xce>
  8002a0:	b78d                	j	800202 <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
  8002a2:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
  8002a6:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
  8002aa:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
  8002ac:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
  8002b0:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
  8002b4:	02d86463          	bltu	a6,a3,8002dc <vprintfmt+0x114>
                ch = *fmt;
  8002b8:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
  8002bc:	002c169b          	slliw	a3,s8,0x2
  8002c0:	0186873b          	addw	a4,a3,s8
  8002c4:	0017171b          	slliw	a4,a4,0x1
  8002c8:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
  8002ca:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
  8002ce:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
  8002d0:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
  8002d4:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
  8002d8:	fed870e3          	bgeu	a6,a3,8002b8 <vprintfmt+0xf0>
            if (width < 0)
  8002dc:	f40ddce3          	bgez	s11,800234 <vprintfmt+0x6c>
                width = precision, precision = -1;
  8002e0:	8de2                	mv	s11,s8
  8002e2:	5c7d                	li	s8,-1
  8002e4:	bf81                	j	800234 <vprintfmt+0x6c>
            if (width < 0)
  8002e6:	fffdc693          	not	a3,s11
  8002ea:	96fd                	srai	a3,a3,0x3f
  8002ec:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
  8002f0:	00144603          	lbu	a2,1(s0)
  8002f4:	2d81                	sext.w	s11,s11
  8002f6:	846a                	mv	s0,s10
            goto reswitch;
  8002f8:	bf35                	j	800234 <vprintfmt+0x6c>
            precision = va_arg(ap, int);
  8002fa:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
  8002fe:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
  800302:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
  800304:	846a                	mv	s0,s10
            goto process_precision;
  800306:	bfd9                	j	8002dc <vprintfmt+0x114>
    if (lflag >= 2) {
  800308:	4705                	li	a4,1
            precision = va_arg(ap, int);
  80030a:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  80030e:	01174463          	blt	a4,a7,800316 <vprintfmt+0x14e>
    else if (lflag) {
  800312:	1a088e63          	beqz	a7,8004ce <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
  800316:	000a3603          	ld	a2,0(s4)
  80031a:	46c1                	li	a3,16
  80031c:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
  80031e:	2781                	sext.w	a5,a5
  800320:	876e                	mv	a4,s11
  800322:	85a6                	mv	a1,s1
  800324:	854a                	mv	a0,s2
  800326:	e37ff0ef          	jal	ra,80015c <printnum>
            break;
  80032a:	bde1                	j	800202 <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
  80032c:	000a2503          	lw	a0,0(s4)
  800330:	85a6                	mv	a1,s1
  800332:	0a21                	addi	s4,s4,8
  800334:	9902                	jalr	s2
            break;
  800336:	b5f1                	j	800202 <vprintfmt+0x3a>
    if (lflag >= 2) {
  800338:	4705                	li	a4,1
            precision = va_arg(ap, int);
  80033a:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  80033e:	01174463          	blt	a4,a7,800346 <vprintfmt+0x17e>
    else if (lflag) {
  800342:	18088163          	beqz	a7,8004c4 <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
  800346:	000a3603          	ld	a2,0(s4)
  80034a:	46a9                	li	a3,10
  80034c:	8a2e                	mv	s4,a1
  80034e:	bfc1                	j	80031e <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
  800350:	00144603          	lbu	a2,1(s0)
            altflag = 1;
  800354:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
  800356:	846a                	mv	s0,s10
            goto reswitch;
  800358:	bdf1                	j	800234 <vprintfmt+0x6c>
            putch(ch, putdat);
  80035a:	85a6                	mv	a1,s1
  80035c:	02500513          	li	a0,37
  800360:	9902                	jalr	s2
            break;
  800362:	b545                	j	800202 <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
  800364:	00144603          	lbu	a2,1(s0)
            lflag ++;
  800368:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
  80036a:	846a                	mv	s0,s10
            goto reswitch;
  80036c:	b5e1                	j	800234 <vprintfmt+0x6c>
    if (lflag >= 2) {
  80036e:	4705                	li	a4,1
            precision = va_arg(ap, int);
  800370:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  800374:	01174463          	blt	a4,a7,80037c <vprintfmt+0x1b4>
    else if (lflag) {
  800378:	14088163          	beqz	a7,8004ba <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
  80037c:	000a3603          	ld	a2,0(s4)
  800380:	46a1                	li	a3,8
  800382:	8a2e                	mv	s4,a1
  800384:	bf69                	j	80031e <vprintfmt+0x156>
            putch('0', putdat);
  800386:	03000513          	li	a0,48
  80038a:	85a6                	mv	a1,s1
  80038c:	e03e                	sd	a5,0(sp)
  80038e:	9902                	jalr	s2
            putch('x', putdat);
  800390:	85a6                	mv	a1,s1
  800392:	07800513          	li	a0,120
  800396:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  800398:	0a21                	addi	s4,s4,8
            goto number;
  80039a:	6782                	ld	a5,0(sp)
  80039c:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  80039e:	ff8a3603          	ld	a2,-8(s4)
            goto number;
  8003a2:	bfb5                	j	80031e <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
  8003a4:	000a3403          	ld	s0,0(s4)
  8003a8:	008a0713          	addi	a4,s4,8
  8003ac:	e03a                	sd	a4,0(sp)
  8003ae:	14040263          	beqz	s0,8004f2 <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
  8003b2:	0fb05763          	blez	s11,8004a0 <vprintfmt+0x2d8>
  8003b6:	02d00693          	li	a3,45
  8003ba:	0cd79163          	bne	a5,a3,80047c <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8003be:	00044783          	lbu	a5,0(s0)
  8003c2:	0007851b          	sext.w	a0,a5
  8003c6:	cf85                	beqz	a5,8003fe <vprintfmt+0x236>
  8003c8:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
  8003cc:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8003d0:	000c4563          	bltz	s8,8003da <vprintfmt+0x212>
  8003d4:	3c7d                	addiw	s8,s8,-1
  8003d6:	036c0263          	beq	s8,s6,8003fa <vprintfmt+0x232>
                    putch('?', putdat);
  8003da:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
  8003dc:	0e0c8e63          	beqz	s9,8004d8 <vprintfmt+0x310>
  8003e0:	3781                	addiw	a5,a5,-32
  8003e2:	0ef47b63          	bgeu	s0,a5,8004d8 <vprintfmt+0x310>
                    putch('?', putdat);
  8003e6:	03f00513          	li	a0,63
  8003ea:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8003ec:	000a4783          	lbu	a5,0(s4)
  8003f0:	3dfd                	addiw	s11,s11,-1
  8003f2:	0a05                	addi	s4,s4,1
  8003f4:	0007851b          	sext.w	a0,a5
  8003f8:	ffe1                	bnez	a5,8003d0 <vprintfmt+0x208>
            for (; width > 0; width --) {
  8003fa:	01b05963          	blez	s11,80040c <vprintfmt+0x244>
  8003fe:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
  800400:	85a6                	mv	a1,s1
  800402:	02000513          	li	a0,32
  800406:	9902                	jalr	s2
            for (; width > 0; width --) {
  800408:	fe0d9be3          	bnez	s11,8003fe <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
  80040c:	6a02                	ld	s4,0(sp)
  80040e:	bbd5                	j	800202 <vprintfmt+0x3a>
    if (lflag >= 2) {
  800410:	4705                	li	a4,1
            precision = va_arg(ap, int);
  800412:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
  800416:	01174463          	blt	a4,a7,80041e <vprintfmt+0x256>
    else if (lflag) {
  80041a:	08088d63          	beqz	a7,8004b4 <vprintfmt+0x2ec>
        return va_arg(*ap, long);
  80041e:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
  800422:	0a044d63          	bltz	s0,8004dc <vprintfmt+0x314>
            num = getint(&ap, lflag);
  800426:	8622                	mv	a2,s0
  800428:	8a66                	mv	s4,s9
  80042a:	46a9                	li	a3,10
  80042c:	bdcd                	j	80031e <vprintfmt+0x156>
            err = va_arg(ap, int);
  80042e:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  800432:	4761                	li	a4,24
            err = va_arg(ap, int);
  800434:	0a21                	addi	s4,s4,8
            if (err < 0) {
  800436:	41f7d69b          	sraiw	a3,a5,0x1f
  80043a:	8fb5                	xor	a5,a5,a3
  80043c:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  800440:	02d74163          	blt	a4,a3,800462 <vprintfmt+0x29a>
  800444:	00369793          	slli	a5,a3,0x3
  800448:	97de                	add	a5,a5,s7
  80044a:	639c                	ld	a5,0(a5)
  80044c:	cb99                	beqz	a5,800462 <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
  80044e:	86be                	mv	a3,a5
  800450:	00000617          	auipc	a2,0x0
  800454:	29060613          	addi	a2,a2,656 # 8006e0 <main+0x17a>
  800458:	85a6                	mv	a1,s1
  80045a:	854a                	mv	a0,s2
  80045c:	0ce000ef          	jal	ra,80052a <printfmt>
  800460:	b34d                	j	800202 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
  800462:	00000617          	auipc	a2,0x0
  800466:	26e60613          	addi	a2,a2,622 # 8006d0 <main+0x16a>
  80046a:	85a6                	mv	a1,s1
  80046c:	854a                	mv	a0,s2
  80046e:	0bc000ef          	jal	ra,80052a <printfmt>
  800472:	bb41                	j	800202 <vprintfmt+0x3a>
                p = "(null)";
  800474:	00000417          	auipc	s0,0x0
  800478:	25440413          	addi	s0,s0,596 # 8006c8 <main+0x162>
                for (width -= strnlen(p, precision); width > 0; width --) {
  80047c:	85e2                	mv	a1,s8
  80047e:	8522                	mv	a0,s0
  800480:	e43e                	sd	a5,8(sp)
  800482:	0c8000ef          	jal	ra,80054a <strnlen>
  800486:	40ad8dbb          	subw	s11,s11,a0
  80048a:	01b05b63          	blez	s11,8004a0 <vprintfmt+0x2d8>
                    putch(padc, putdat);
  80048e:	67a2                	ld	a5,8(sp)
  800490:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
  800494:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
  800496:	85a6                	mv	a1,s1
  800498:	8552                	mv	a0,s4
  80049a:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
  80049c:	fe0d9ce3          	bnez	s11,800494 <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8004a0:	00044783          	lbu	a5,0(s0)
  8004a4:	00140a13          	addi	s4,s0,1
  8004a8:	0007851b          	sext.w	a0,a5
  8004ac:	d3a5                	beqz	a5,80040c <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
  8004ae:	05e00413          	li	s0,94
  8004b2:	bf39                	j	8003d0 <vprintfmt+0x208>
        return va_arg(*ap, int);
  8004b4:	000a2403          	lw	s0,0(s4)
  8004b8:	b7ad                	j	800422 <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
  8004ba:	000a6603          	lwu	a2,0(s4)
  8004be:	46a1                	li	a3,8
  8004c0:	8a2e                	mv	s4,a1
  8004c2:	bdb1                	j	80031e <vprintfmt+0x156>
  8004c4:	000a6603          	lwu	a2,0(s4)
  8004c8:	46a9                	li	a3,10
  8004ca:	8a2e                	mv	s4,a1
  8004cc:	bd89                	j	80031e <vprintfmt+0x156>
  8004ce:	000a6603          	lwu	a2,0(s4)
  8004d2:	46c1                	li	a3,16
  8004d4:	8a2e                	mv	s4,a1
  8004d6:	b5a1                	j	80031e <vprintfmt+0x156>
                    putch(ch, putdat);
  8004d8:	9902                	jalr	s2
  8004da:	bf09                	j	8003ec <vprintfmt+0x224>
                putch('-', putdat);
  8004dc:	85a6                	mv	a1,s1
  8004de:	02d00513          	li	a0,45
  8004e2:	e03e                	sd	a5,0(sp)
  8004e4:	9902                	jalr	s2
                num = -(long long)num;
  8004e6:	6782                	ld	a5,0(sp)
  8004e8:	8a66                	mv	s4,s9
  8004ea:	40800633          	neg	a2,s0
  8004ee:	46a9                	li	a3,10
  8004f0:	b53d                	j	80031e <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
  8004f2:	03b05163          	blez	s11,800514 <vprintfmt+0x34c>
  8004f6:	02d00693          	li	a3,45
  8004fa:	f6d79de3          	bne	a5,a3,800474 <vprintfmt+0x2ac>
                p = "(null)";
  8004fe:	00000417          	auipc	s0,0x0
  800502:	1ca40413          	addi	s0,s0,458 # 8006c8 <main+0x162>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800506:	02800793          	li	a5,40
  80050a:	02800513          	li	a0,40
  80050e:	00140a13          	addi	s4,s0,1
  800512:	bd6d                	j	8003cc <vprintfmt+0x204>
  800514:	00000a17          	auipc	s4,0x0
  800518:	1b5a0a13          	addi	s4,s4,437 # 8006c9 <main+0x163>
  80051c:	02800513          	li	a0,40
  800520:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
  800524:	05e00413          	li	s0,94
  800528:	b565                	j	8003d0 <vprintfmt+0x208>

000000000080052a <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  80052a:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
  80052c:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  800530:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
  800532:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  800534:	ec06                	sd	ra,24(sp)
  800536:	f83a                	sd	a4,48(sp)
  800538:	fc3e                	sd	a5,56(sp)
  80053a:	e0c2                	sd	a6,64(sp)
  80053c:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  80053e:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
  800540:	c89ff0ef          	jal	ra,8001c8 <vprintfmt>
}
  800544:	60e2                	ld	ra,24(sp)
  800546:	6161                	addi	sp,sp,80
  800548:	8082                	ret

000000000080054a <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
  80054a:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
  80054c:	e589                	bnez	a1,800556 <strnlen+0xc>
  80054e:	a811                	j	800562 <strnlen+0x18>
        cnt ++;
  800550:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
  800552:	00f58863          	beq	a1,a5,800562 <strnlen+0x18>
  800556:	00f50733          	add	a4,a0,a5
  80055a:	00074703          	lbu	a4,0(a4)
  80055e:	fb6d                	bnez	a4,800550 <strnlen+0x6>
  800560:	85be                	mv	a1,a5
    }
    return cnt;
}
  800562:	852e                	mv	a0,a1
  800564:	8082                	ret

0000000000800566 <main>:
#include <ulib.h>

int magic = -0x10384;

int
main(void) {
  800566:	1101                	addi	sp,sp,-32
    int pid, code;
    cprintf("I am the parent. Forking the child...\n");
  800568:	00000517          	auipc	a0,0x0
  80056c:	46050513          	addi	a0,a0,1120 # 8009c8 <error_string+0xc8>
main(void) {
  800570:	ec06                	sd	ra,24(sp)
  800572:	e822                	sd	s0,16(sp)
    cprintf("I am the parent. Forking the child...\n");
  800574:	b2fff0ef          	jal	ra,8000a2 <cprintf>
    if ((pid = fork()) == 0) {
  800578:	bcdff0ef          	jal	ra,800144 <fork>
  80057c:	c561                	beqz	a0,800644 <main+0xde>
  80057e:	842a                	mv	s0,a0
        yield();
        yield();
        exit(magic);
    }
    else {
        cprintf("I am parent, fork a child pid %d\n",pid);
  800580:	85aa                	mv	a1,a0
  800582:	00000517          	auipc	a0,0x0
  800586:	48650513          	addi	a0,a0,1158 # 800a08 <error_string+0x108>
  80058a:	b19ff0ef          	jal	ra,8000a2 <cprintf>
    }
    assert(pid > 0);
  80058e:	08805c63          	blez	s0,800626 <main+0xc0>
    cprintf("I am the parent, waiting now..\n");
  800592:	00000517          	auipc	a0,0x0
  800596:	4ce50513          	addi	a0,a0,1230 # 800a60 <error_string+0x160>
  80059a:	b09ff0ef          	jal	ra,8000a2 <cprintf>

    assert(waitpid(pid, &code) == 0 && code == magic);
  80059e:	006c                	addi	a1,sp,12
  8005a0:	8522                	mv	a0,s0
  8005a2:	babff0ef          	jal	ra,80014c <waitpid>
  8005a6:	e131                	bnez	a0,8005ea <main+0x84>
  8005a8:	4732                	lw	a4,12(sp)
  8005aa:	00001797          	auipc	a5,0x1
  8005ae:	a567a783          	lw	a5,-1450(a5) # 801000 <magic>
  8005b2:	02f71c63          	bne	a4,a5,8005ea <main+0x84>
    assert(waitpid(pid, &code) != 0 && wait() != 0);
  8005b6:	006c                	addi	a1,sp,12
  8005b8:	8522                	mv	a0,s0
  8005ba:	b93ff0ef          	jal	ra,80014c <waitpid>
  8005be:	c529                	beqz	a0,800608 <main+0xa2>
  8005c0:	b87ff0ef          	jal	ra,800146 <wait>
  8005c4:	c131                	beqz	a0,800608 <main+0xa2>
    cprintf("waitpid %d ok.\n", pid);
  8005c6:	85a2                	mv	a1,s0
  8005c8:	00000517          	auipc	a0,0x0
  8005cc:	51050513          	addi	a0,a0,1296 # 800ad8 <error_string+0x1d8>
  8005d0:	ad3ff0ef          	jal	ra,8000a2 <cprintf>

    cprintf("exit pass.\n");
  8005d4:	00000517          	auipc	a0,0x0
  8005d8:	51450513          	addi	a0,a0,1300 # 800ae8 <error_string+0x1e8>
  8005dc:	ac7ff0ef          	jal	ra,8000a2 <cprintf>
    return 0;
}
  8005e0:	60e2                	ld	ra,24(sp)
  8005e2:	6442                	ld	s0,16(sp)
  8005e4:	4501                	li	a0,0
  8005e6:	6105                	addi	sp,sp,32
  8005e8:	8082                	ret
    assert(waitpid(pid, &code) == 0 && code == magic);
  8005ea:	00000697          	auipc	a3,0x0
  8005ee:	49668693          	addi	a3,a3,1174 # 800a80 <error_string+0x180>
  8005f2:	00000617          	auipc	a2,0x0
  8005f6:	44660613          	addi	a2,a2,1094 # 800a38 <error_string+0x138>
  8005fa:	45ed                	li	a1,27
  8005fc:	00000517          	auipc	a0,0x0
  800600:	45450513          	addi	a0,a0,1108 # 800a50 <error_string+0x150>
  800604:	a23ff0ef          	jal	ra,800026 <__panic>
    assert(waitpid(pid, &code) != 0 && wait() != 0);
  800608:	00000697          	auipc	a3,0x0
  80060c:	4a868693          	addi	a3,a3,1192 # 800ab0 <error_string+0x1b0>
  800610:	00000617          	auipc	a2,0x0
  800614:	42860613          	addi	a2,a2,1064 # 800a38 <error_string+0x138>
  800618:	45f1                	li	a1,28
  80061a:	00000517          	auipc	a0,0x0
  80061e:	43650513          	addi	a0,a0,1078 # 800a50 <error_string+0x150>
  800622:	a05ff0ef          	jal	ra,800026 <__panic>
    assert(pid > 0);
  800626:	00000697          	auipc	a3,0x0
  80062a:	40a68693          	addi	a3,a3,1034 # 800a30 <error_string+0x130>
  80062e:	00000617          	auipc	a2,0x0
  800632:	40a60613          	addi	a2,a2,1034 # 800a38 <error_string+0x138>
  800636:	45e1                	li	a1,24
  800638:	00000517          	auipc	a0,0x0
  80063c:	41850513          	addi	a0,a0,1048 # 800a50 <error_string+0x150>
  800640:	9e7ff0ef          	jal	ra,800026 <__panic>
        cprintf("I am the child.\n");
  800644:	00000517          	auipc	a0,0x0
  800648:	3ac50513          	addi	a0,a0,940 # 8009f0 <error_string+0xf0>
  80064c:	a57ff0ef          	jal	ra,8000a2 <cprintf>
        yield();
  800650:	affff0ef          	jal	ra,80014e <yield>
        yield();
  800654:	afbff0ef          	jal	ra,80014e <yield>
        yield();
  800658:	af7ff0ef          	jal	ra,80014e <yield>
        yield();
  80065c:	af3ff0ef          	jal	ra,80014e <yield>
        yield();
  800660:	aefff0ef          	jal	ra,80014e <yield>
        yield();
  800664:	aebff0ef          	jal	ra,80014e <yield>
        yield();
  800668:	ae7ff0ef          	jal	ra,80014e <yield>
        exit(magic);
  80066c:	00001517          	auipc	a0,0x1
  800670:	99452503          	lw	a0,-1644(a0) # 801000 <magic>
  800674:	abbff0ef          	jal	ra,80012e <exit>
