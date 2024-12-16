
obj/__user_waitkill.out:     file format elf64-littleriscv


Disassembly of section .text:

0000000000800020 <_start>:
.text
.globl _start
_start:
    # call user-program function
    call umain
  800020:	138000ef          	jal	ra,800158 <umain>
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
  80003a:	67250513          	addi	a0,a0,1650 # 8006a8 <main+0xb2>
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
  80005a:	9aa50513          	addi	a0,a0,-1622 # 800a00 <error_string+0xd0>
  80005e:	044000ef          	jal	ra,8000a2 <cprintf>
    va_end(ap);
    exit(-E_PANIC);
  800062:	5559                	li	a0,-10
  800064:	0d4000ef          	jal	ra,800138 <exit>

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
  800070:	0c2000ef          	jal	ra,800132 <sys_putc>
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
  800096:	13a000ef          	jal	ra,8001d0 <vprintfmt>
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
  8000cc:	104000ef          	jal	ra,8001d0 <vprintfmt>
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

000000000080012e <sys_getpid>:
}

int
sys_getpid(void) {
    return syscall(SYS_getpid);
  80012e:	4549                	li	a0,18
  800130:	b765                	j	8000d8 <syscall>

0000000000800132 <sys_putc>:
}

int
sys_putc(int64_t c) {
  800132:	85aa                	mv	a1,a0
    return syscall(SYS_putc, c);
  800134:	4579                	li	a0,30
  800136:	b74d                	j	8000d8 <syscall>

0000000000800138 <exit>:
#include <syscall.h>
#include <stdio.h>
#include <ulib.h>

void
exit(int error_code) {
  800138:	1141                	addi	sp,sp,-16
  80013a:	e406                	sd	ra,8(sp)
    sys_exit(error_code);
  80013c:	fd7ff0ef          	jal	ra,800112 <sys_exit>
    cprintf("BUG: exit failed.\n");
  800140:	00000517          	auipc	a0,0x0
  800144:	58850513          	addi	a0,a0,1416 # 8006c8 <main+0xd2>
  800148:	f5bff0ef          	jal	ra,8000a2 <cprintf>
    while (1);
  80014c:	a001                	j	80014c <exit+0x14>

000000000080014e <fork>:
}

int
fork(void) {
    return sys_fork();
  80014e:	b7e9                	j	800118 <sys_fork>

0000000000800150 <waitpid>:
    return sys_wait(0, NULL);
}

int
waitpid(int pid, int *store) {
    return sys_wait(pid, store);
  800150:	b7f1                	j	80011c <sys_wait>

0000000000800152 <yield>:
}

void
yield(void) {
    sys_yield();
  800152:	bfc9                	j	800124 <sys_yield>

0000000000800154 <kill>:
}

int
kill(int pid) {
    return sys_kill(pid);
  800154:	bfd1                	j	800128 <sys_kill>

0000000000800156 <getpid>:
}

int
getpid(void) {
    return sys_getpid();
  800156:	bfe1                	j	80012e <sys_getpid>

0000000000800158 <umain>:
#include <ulib.h>

int main(void);

void
umain(void) {
  800158:	1141                	addi	sp,sp,-16
  80015a:	e406                	sd	ra,8(sp)
    int ret = main();
  80015c:	49a000ef          	jal	ra,8005f6 <main>
    exit(ret);
  800160:	fd9ff0ef          	jal	ra,800138 <exit>

0000000000800164 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
  800164:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  800168:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
  80016a:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  80016e:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
  800170:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
  800174:	f022                	sd	s0,32(sp)
  800176:	ec26                	sd	s1,24(sp)
  800178:	e84a                	sd	s2,16(sp)
  80017a:	f406                	sd	ra,40(sp)
  80017c:	e44e                	sd	s3,8(sp)
  80017e:	84aa                	mv	s1,a0
  800180:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  800182:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
  800186:	2a01                	sext.w	s4,s4
    if (num >= base) {
  800188:	03067e63          	bgeu	a2,a6,8001c4 <printnum+0x60>
  80018c:	89be                	mv	s3,a5
        while (-- width > 0)
  80018e:	00805763          	blez	s0,80019c <printnum+0x38>
  800192:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
  800194:	85ca                	mv	a1,s2
  800196:	854e                	mv	a0,s3
  800198:	9482                	jalr	s1
        while (-- width > 0)
  80019a:	fc65                	bnez	s0,800192 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  80019c:	1a02                	slli	s4,s4,0x20
  80019e:	00000797          	auipc	a5,0x0
  8001a2:	54278793          	addi	a5,a5,1346 # 8006e0 <main+0xea>
  8001a6:	020a5a13          	srli	s4,s4,0x20
  8001aa:	9a3e                	add	s4,s4,a5
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
  8001ac:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
  8001ae:	000a4503          	lbu	a0,0(s4)
}
  8001b2:	70a2                	ld	ra,40(sp)
  8001b4:	69a2                	ld	s3,8(sp)
  8001b6:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
  8001b8:	85ca                	mv	a1,s2
  8001ba:	87a6                	mv	a5,s1
}
  8001bc:	6942                	ld	s2,16(sp)
  8001be:	64e2                	ld	s1,24(sp)
  8001c0:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
  8001c2:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
  8001c4:	03065633          	divu	a2,a2,a6
  8001c8:	8722                	mv	a4,s0
  8001ca:	f9bff0ef          	jal	ra,800164 <printnum>
  8001ce:	b7f9                	j	80019c <printnum+0x38>

00000000008001d0 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  8001d0:	7119                	addi	sp,sp,-128
  8001d2:	f4a6                	sd	s1,104(sp)
  8001d4:	f0ca                	sd	s2,96(sp)
  8001d6:	ecce                	sd	s3,88(sp)
  8001d8:	e8d2                	sd	s4,80(sp)
  8001da:	e4d6                	sd	s5,72(sp)
  8001dc:	e0da                	sd	s6,64(sp)
  8001de:	fc5e                	sd	s7,56(sp)
  8001e0:	f06a                	sd	s10,32(sp)
  8001e2:	fc86                	sd	ra,120(sp)
  8001e4:	f8a2                	sd	s0,112(sp)
  8001e6:	f862                	sd	s8,48(sp)
  8001e8:	f466                	sd	s9,40(sp)
  8001ea:	ec6e                	sd	s11,24(sp)
  8001ec:	892a                	mv	s2,a0
  8001ee:	84ae                	mv	s1,a1
  8001f0:	8d32                	mv	s10,a2
  8001f2:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001f4:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
  8001f8:	5b7d                	li	s6,-1
  8001fa:	00000a97          	auipc	s5,0x0
  8001fe:	51aa8a93          	addi	s5,s5,1306 # 800714 <main+0x11e>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  800202:	00000b97          	auipc	s7,0x0
  800206:	72eb8b93          	addi	s7,s7,1838 # 800930 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  80020a:	000d4503          	lbu	a0,0(s10)
  80020e:	001d0413          	addi	s0,s10,1
  800212:	01350a63          	beq	a0,s3,800226 <vprintfmt+0x56>
            if (ch == '\0') {
  800216:	c121                	beqz	a0,800256 <vprintfmt+0x86>
            putch(ch, putdat);
  800218:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  80021a:	0405                	addi	s0,s0,1
            putch(ch, putdat);
  80021c:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  80021e:	fff44503          	lbu	a0,-1(s0)
  800222:	ff351ae3          	bne	a0,s3,800216 <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
  800226:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
  80022a:	02000793          	li	a5,32
        lflag = altflag = 0;
  80022e:	4c81                	li	s9,0
  800230:	4881                	li	a7,0
        width = precision = -1;
  800232:	5c7d                	li	s8,-1
  800234:	5dfd                	li	s11,-1
  800236:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
  80023a:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
  80023c:	fdd6059b          	addiw	a1,a2,-35
  800240:	0ff5f593          	zext.b	a1,a1
  800244:	00140d13          	addi	s10,s0,1
  800248:	04b56263          	bltu	a0,a1,80028c <vprintfmt+0xbc>
  80024c:	058a                	slli	a1,a1,0x2
  80024e:	95d6                	add	a1,a1,s5
  800250:	4194                	lw	a3,0(a1)
  800252:	96d6                	add	a3,a3,s5
  800254:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
  800256:	70e6                	ld	ra,120(sp)
  800258:	7446                	ld	s0,112(sp)
  80025a:	74a6                	ld	s1,104(sp)
  80025c:	7906                	ld	s2,96(sp)
  80025e:	69e6                	ld	s3,88(sp)
  800260:	6a46                	ld	s4,80(sp)
  800262:	6aa6                	ld	s5,72(sp)
  800264:	6b06                	ld	s6,64(sp)
  800266:	7be2                	ld	s7,56(sp)
  800268:	7c42                	ld	s8,48(sp)
  80026a:	7ca2                	ld	s9,40(sp)
  80026c:	7d02                	ld	s10,32(sp)
  80026e:	6de2                	ld	s11,24(sp)
  800270:	6109                	addi	sp,sp,128
  800272:	8082                	ret
            padc = '0';
  800274:	87b2                	mv	a5,a2
            goto reswitch;
  800276:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
  80027a:	846a                	mv	s0,s10
  80027c:	00140d13          	addi	s10,s0,1
  800280:	fdd6059b          	addiw	a1,a2,-35
  800284:	0ff5f593          	zext.b	a1,a1
  800288:	fcb572e3          	bgeu	a0,a1,80024c <vprintfmt+0x7c>
            putch('%', putdat);
  80028c:	85a6                	mv	a1,s1
  80028e:	02500513          	li	a0,37
  800292:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
  800294:	fff44783          	lbu	a5,-1(s0)
  800298:	8d22                	mv	s10,s0
  80029a:	f73788e3          	beq	a5,s3,80020a <vprintfmt+0x3a>
  80029e:	ffed4783          	lbu	a5,-2(s10)
  8002a2:	1d7d                	addi	s10,s10,-1
  8002a4:	ff379de3          	bne	a5,s3,80029e <vprintfmt+0xce>
  8002a8:	b78d                	j	80020a <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
  8002aa:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
  8002ae:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
  8002b2:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
  8002b4:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
  8002b8:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
  8002bc:	02d86463          	bltu	a6,a3,8002e4 <vprintfmt+0x114>
                ch = *fmt;
  8002c0:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
  8002c4:	002c169b          	slliw	a3,s8,0x2
  8002c8:	0186873b          	addw	a4,a3,s8
  8002cc:	0017171b          	slliw	a4,a4,0x1
  8002d0:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
  8002d2:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
  8002d6:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
  8002d8:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
  8002dc:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
  8002e0:	fed870e3          	bgeu	a6,a3,8002c0 <vprintfmt+0xf0>
            if (width < 0)
  8002e4:	f40ddce3          	bgez	s11,80023c <vprintfmt+0x6c>
                width = precision, precision = -1;
  8002e8:	8de2                	mv	s11,s8
  8002ea:	5c7d                	li	s8,-1
  8002ec:	bf81                	j	80023c <vprintfmt+0x6c>
            if (width < 0)
  8002ee:	fffdc693          	not	a3,s11
  8002f2:	96fd                	srai	a3,a3,0x3f
  8002f4:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
  8002f8:	00144603          	lbu	a2,1(s0)
  8002fc:	2d81                	sext.w	s11,s11
  8002fe:	846a                	mv	s0,s10
            goto reswitch;
  800300:	bf35                	j	80023c <vprintfmt+0x6c>
            precision = va_arg(ap, int);
  800302:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
  800306:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
  80030a:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
  80030c:	846a                	mv	s0,s10
            goto process_precision;
  80030e:	bfd9                	j	8002e4 <vprintfmt+0x114>
    if (lflag >= 2) {
  800310:	4705                	li	a4,1
            precision = va_arg(ap, int);
  800312:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  800316:	01174463          	blt	a4,a7,80031e <vprintfmt+0x14e>
    else if (lflag) {
  80031a:	1a088e63          	beqz	a7,8004d6 <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
  80031e:	000a3603          	ld	a2,0(s4)
  800322:	46c1                	li	a3,16
  800324:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
  800326:	2781                	sext.w	a5,a5
  800328:	876e                	mv	a4,s11
  80032a:	85a6                	mv	a1,s1
  80032c:	854a                	mv	a0,s2
  80032e:	e37ff0ef          	jal	ra,800164 <printnum>
            break;
  800332:	bde1                	j	80020a <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
  800334:	000a2503          	lw	a0,0(s4)
  800338:	85a6                	mv	a1,s1
  80033a:	0a21                	addi	s4,s4,8
  80033c:	9902                	jalr	s2
            break;
  80033e:	b5f1                	j	80020a <vprintfmt+0x3a>
    if (lflag >= 2) {
  800340:	4705                	li	a4,1
            precision = va_arg(ap, int);
  800342:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  800346:	01174463          	blt	a4,a7,80034e <vprintfmt+0x17e>
    else if (lflag) {
  80034a:	18088163          	beqz	a7,8004cc <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
  80034e:	000a3603          	ld	a2,0(s4)
  800352:	46a9                	li	a3,10
  800354:	8a2e                	mv	s4,a1
  800356:	bfc1                	j	800326 <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
  800358:	00144603          	lbu	a2,1(s0)
            altflag = 1;
  80035c:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
  80035e:	846a                	mv	s0,s10
            goto reswitch;
  800360:	bdf1                	j	80023c <vprintfmt+0x6c>
            putch(ch, putdat);
  800362:	85a6                	mv	a1,s1
  800364:	02500513          	li	a0,37
  800368:	9902                	jalr	s2
            break;
  80036a:	b545                	j	80020a <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
  80036c:	00144603          	lbu	a2,1(s0)
            lflag ++;
  800370:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
  800372:	846a                	mv	s0,s10
            goto reswitch;
  800374:	b5e1                	j	80023c <vprintfmt+0x6c>
    if (lflag >= 2) {
  800376:	4705                	li	a4,1
            precision = va_arg(ap, int);
  800378:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  80037c:	01174463          	blt	a4,a7,800384 <vprintfmt+0x1b4>
    else if (lflag) {
  800380:	14088163          	beqz	a7,8004c2 <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
  800384:	000a3603          	ld	a2,0(s4)
  800388:	46a1                	li	a3,8
  80038a:	8a2e                	mv	s4,a1
  80038c:	bf69                	j	800326 <vprintfmt+0x156>
            putch('0', putdat);
  80038e:	03000513          	li	a0,48
  800392:	85a6                	mv	a1,s1
  800394:	e03e                	sd	a5,0(sp)
  800396:	9902                	jalr	s2
            putch('x', putdat);
  800398:	85a6                	mv	a1,s1
  80039a:	07800513          	li	a0,120
  80039e:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  8003a0:	0a21                	addi	s4,s4,8
            goto number;
  8003a2:	6782                	ld	a5,0(sp)
  8003a4:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  8003a6:	ff8a3603          	ld	a2,-8(s4)
            goto number;
  8003aa:	bfb5                	j	800326 <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
  8003ac:	000a3403          	ld	s0,0(s4)
  8003b0:	008a0713          	addi	a4,s4,8
  8003b4:	e03a                	sd	a4,0(sp)
  8003b6:	14040263          	beqz	s0,8004fa <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
  8003ba:	0fb05763          	blez	s11,8004a8 <vprintfmt+0x2d8>
  8003be:	02d00693          	li	a3,45
  8003c2:	0cd79163          	bne	a5,a3,800484 <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8003c6:	00044783          	lbu	a5,0(s0)
  8003ca:	0007851b          	sext.w	a0,a5
  8003ce:	cf85                	beqz	a5,800406 <vprintfmt+0x236>
  8003d0:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
  8003d4:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8003d8:	000c4563          	bltz	s8,8003e2 <vprintfmt+0x212>
  8003dc:	3c7d                	addiw	s8,s8,-1
  8003de:	036c0263          	beq	s8,s6,800402 <vprintfmt+0x232>
                    putch('?', putdat);
  8003e2:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
  8003e4:	0e0c8e63          	beqz	s9,8004e0 <vprintfmt+0x310>
  8003e8:	3781                	addiw	a5,a5,-32
  8003ea:	0ef47b63          	bgeu	s0,a5,8004e0 <vprintfmt+0x310>
                    putch('?', putdat);
  8003ee:	03f00513          	li	a0,63
  8003f2:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8003f4:	000a4783          	lbu	a5,0(s4)
  8003f8:	3dfd                	addiw	s11,s11,-1
  8003fa:	0a05                	addi	s4,s4,1
  8003fc:	0007851b          	sext.w	a0,a5
  800400:	ffe1                	bnez	a5,8003d8 <vprintfmt+0x208>
            for (; width > 0; width --) {
  800402:	01b05963          	blez	s11,800414 <vprintfmt+0x244>
  800406:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
  800408:	85a6                	mv	a1,s1
  80040a:	02000513          	li	a0,32
  80040e:	9902                	jalr	s2
            for (; width > 0; width --) {
  800410:	fe0d9be3          	bnez	s11,800406 <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
  800414:	6a02                	ld	s4,0(sp)
  800416:	bbd5                	j	80020a <vprintfmt+0x3a>
    if (lflag >= 2) {
  800418:	4705                	li	a4,1
            precision = va_arg(ap, int);
  80041a:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
  80041e:	01174463          	blt	a4,a7,800426 <vprintfmt+0x256>
    else if (lflag) {
  800422:	08088d63          	beqz	a7,8004bc <vprintfmt+0x2ec>
        return va_arg(*ap, long);
  800426:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
  80042a:	0a044d63          	bltz	s0,8004e4 <vprintfmt+0x314>
            num = getint(&ap, lflag);
  80042e:	8622                	mv	a2,s0
  800430:	8a66                	mv	s4,s9
  800432:	46a9                	li	a3,10
  800434:	bdcd                	j	800326 <vprintfmt+0x156>
            err = va_arg(ap, int);
  800436:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  80043a:	4761                	li	a4,24
            err = va_arg(ap, int);
  80043c:	0a21                	addi	s4,s4,8
            if (err < 0) {
  80043e:	41f7d69b          	sraiw	a3,a5,0x1f
  800442:	8fb5                	xor	a5,a5,a3
  800444:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  800448:	02d74163          	blt	a4,a3,80046a <vprintfmt+0x29a>
  80044c:	00369793          	slli	a5,a3,0x3
  800450:	97de                	add	a5,a5,s7
  800452:	639c                	ld	a5,0(a5)
  800454:	cb99                	beqz	a5,80046a <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
  800456:	86be                	mv	a3,a5
  800458:	00000617          	auipc	a2,0x0
  80045c:	2b860613          	addi	a2,a2,696 # 800710 <main+0x11a>
  800460:	85a6                	mv	a1,s1
  800462:	854a                	mv	a0,s2
  800464:	0ce000ef          	jal	ra,800532 <printfmt>
  800468:	b34d                	j	80020a <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
  80046a:	00000617          	auipc	a2,0x0
  80046e:	29660613          	addi	a2,a2,662 # 800700 <main+0x10a>
  800472:	85a6                	mv	a1,s1
  800474:	854a                	mv	a0,s2
  800476:	0bc000ef          	jal	ra,800532 <printfmt>
  80047a:	bb41                	j	80020a <vprintfmt+0x3a>
                p = "(null)";
  80047c:	00000417          	auipc	s0,0x0
  800480:	27c40413          	addi	s0,s0,636 # 8006f8 <main+0x102>
                for (width -= strnlen(p, precision); width > 0; width --) {
  800484:	85e2                	mv	a1,s8
  800486:	8522                	mv	a0,s0
  800488:	e43e                	sd	a5,8(sp)
  80048a:	0c8000ef          	jal	ra,800552 <strnlen>
  80048e:	40ad8dbb          	subw	s11,s11,a0
  800492:	01b05b63          	blez	s11,8004a8 <vprintfmt+0x2d8>
                    putch(padc, putdat);
  800496:	67a2                	ld	a5,8(sp)
  800498:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
  80049c:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
  80049e:	85a6                	mv	a1,s1
  8004a0:	8552                	mv	a0,s4
  8004a2:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004a4:	fe0d9ce3          	bnez	s11,80049c <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8004a8:	00044783          	lbu	a5,0(s0)
  8004ac:	00140a13          	addi	s4,s0,1
  8004b0:	0007851b          	sext.w	a0,a5
  8004b4:	d3a5                	beqz	a5,800414 <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
  8004b6:	05e00413          	li	s0,94
  8004ba:	bf39                	j	8003d8 <vprintfmt+0x208>
        return va_arg(*ap, int);
  8004bc:	000a2403          	lw	s0,0(s4)
  8004c0:	b7ad                	j	80042a <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
  8004c2:	000a6603          	lwu	a2,0(s4)
  8004c6:	46a1                	li	a3,8
  8004c8:	8a2e                	mv	s4,a1
  8004ca:	bdb1                	j	800326 <vprintfmt+0x156>
  8004cc:	000a6603          	lwu	a2,0(s4)
  8004d0:	46a9                	li	a3,10
  8004d2:	8a2e                	mv	s4,a1
  8004d4:	bd89                	j	800326 <vprintfmt+0x156>
  8004d6:	000a6603          	lwu	a2,0(s4)
  8004da:	46c1                	li	a3,16
  8004dc:	8a2e                	mv	s4,a1
  8004de:	b5a1                	j	800326 <vprintfmt+0x156>
                    putch(ch, putdat);
  8004e0:	9902                	jalr	s2
  8004e2:	bf09                	j	8003f4 <vprintfmt+0x224>
                putch('-', putdat);
  8004e4:	85a6                	mv	a1,s1
  8004e6:	02d00513          	li	a0,45
  8004ea:	e03e                	sd	a5,0(sp)
  8004ec:	9902                	jalr	s2
                num = -(long long)num;
  8004ee:	6782                	ld	a5,0(sp)
  8004f0:	8a66                	mv	s4,s9
  8004f2:	40800633          	neg	a2,s0
  8004f6:	46a9                	li	a3,10
  8004f8:	b53d                	j	800326 <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
  8004fa:	03b05163          	blez	s11,80051c <vprintfmt+0x34c>
  8004fe:	02d00693          	li	a3,45
  800502:	f6d79de3          	bne	a5,a3,80047c <vprintfmt+0x2ac>
                p = "(null)";
  800506:	00000417          	auipc	s0,0x0
  80050a:	1f240413          	addi	s0,s0,498 # 8006f8 <main+0x102>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80050e:	02800793          	li	a5,40
  800512:	02800513          	li	a0,40
  800516:	00140a13          	addi	s4,s0,1
  80051a:	bd6d                	j	8003d4 <vprintfmt+0x204>
  80051c:	00000a17          	auipc	s4,0x0
  800520:	1dda0a13          	addi	s4,s4,477 # 8006f9 <main+0x103>
  800524:	02800513          	li	a0,40
  800528:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
  80052c:	05e00413          	li	s0,94
  800530:	b565                	j	8003d8 <vprintfmt+0x208>

0000000000800532 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  800532:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
  800534:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  800538:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
  80053a:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  80053c:	ec06                	sd	ra,24(sp)
  80053e:	f83a                	sd	a4,48(sp)
  800540:	fc3e                	sd	a5,56(sp)
  800542:	e0c2                	sd	a6,64(sp)
  800544:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  800546:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
  800548:	c89ff0ef          	jal	ra,8001d0 <vprintfmt>
}
  80054c:	60e2                	ld	ra,24(sp)
  80054e:	6161                	addi	sp,sp,80
  800550:	8082                	ret

0000000000800552 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
  800552:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
  800554:	e589                	bnez	a1,80055e <strnlen+0xc>
  800556:	a811                	j	80056a <strnlen+0x18>
        cnt ++;
  800558:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
  80055a:	00f58863          	beq	a1,a5,80056a <strnlen+0x18>
  80055e:	00f50733          	add	a4,a0,a5
  800562:	00074703          	lbu	a4,0(a4)
  800566:	fb6d                	bnez	a4,800558 <strnlen+0x6>
  800568:	85be                	mv	a1,a5
    }
    return cnt;
}
  80056a:	852e                	mv	a0,a1
  80056c:	8082                	ret

000000000080056e <do_yield>:
#include <ulib.h>
#include <stdio.h>

void
do_yield(void) {
  80056e:	1141                	addi	sp,sp,-16
  800570:	e406                	sd	ra,8(sp)
    yield();
  800572:	be1ff0ef          	jal	ra,800152 <yield>
    yield();
  800576:	bddff0ef          	jal	ra,800152 <yield>
    yield();
  80057a:	bd9ff0ef          	jal	ra,800152 <yield>
    yield();
  80057e:	bd5ff0ef          	jal	ra,800152 <yield>
    yield();
  800582:	bd1ff0ef          	jal	ra,800152 <yield>
    yield();
}
  800586:	60a2                	ld	ra,8(sp)
  800588:	0141                	addi	sp,sp,16
    yield();
  80058a:	b6e1                	j	800152 <yield>

000000000080058c <loop>:

int parent, pid1, pid2;

void
loop(void) {
  80058c:	1141                	addi	sp,sp,-16
    cprintf("child 1.\n");
  80058e:	00000517          	auipc	a0,0x0
  800592:	46a50513          	addi	a0,a0,1130 # 8009f8 <error_string+0xc8>
loop(void) {
  800596:	e406                	sd	ra,8(sp)
    cprintf("child 1.\n");
  800598:	b0bff0ef          	jal	ra,8000a2 <cprintf>
    while (1);
  80059c:	a001                	j	80059c <loop+0x10>

000000000080059e <work>:
}

void
work(void) {
  80059e:	1141                	addi	sp,sp,-16
    cprintf("child 2.\n");
  8005a0:	00000517          	auipc	a0,0x0
  8005a4:	46850513          	addi	a0,a0,1128 # 800a08 <error_string+0xd8>
work(void) {
  8005a8:	e406                	sd	ra,8(sp)
    cprintf("child 2.\n");
  8005aa:	af9ff0ef          	jal	ra,8000a2 <cprintf>
    do_yield();
  8005ae:	fc1ff0ef          	jal	ra,80056e <do_yield>
    if (kill(parent) == 0) {
  8005b2:	00001517          	auipc	a0,0x1
  8005b6:	a4e52503          	lw	a0,-1458(a0) # 801000 <parent>
  8005ba:	b9bff0ef          	jal	ra,800154 <kill>
  8005be:	e105                	bnez	a0,8005de <work+0x40>
        cprintf("kill parent ok.\n");
  8005c0:	00000517          	auipc	a0,0x0
  8005c4:	45850513          	addi	a0,a0,1112 # 800a18 <error_string+0xe8>
  8005c8:	adbff0ef          	jal	ra,8000a2 <cprintf>
        do_yield();
  8005cc:	fa3ff0ef          	jal	ra,80056e <do_yield>
        if (kill(pid1) == 0) {
  8005d0:	00001517          	auipc	a0,0x1
  8005d4:	a3452503          	lw	a0,-1484(a0) # 801004 <pid1>
  8005d8:	b7dff0ef          	jal	ra,800154 <kill>
  8005dc:	c501                	beqz	a0,8005e4 <work+0x46>
            cprintf("kill child1 ok.\n");
            exit(0);
        }
    }
    exit(-1);
  8005de:	557d                	li	a0,-1
  8005e0:	b59ff0ef          	jal	ra,800138 <exit>
            cprintf("kill child1 ok.\n");
  8005e4:	00000517          	auipc	a0,0x0
  8005e8:	44c50513          	addi	a0,a0,1100 # 800a30 <error_string+0x100>
  8005ec:	ab7ff0ef          	jal	ra,8000a2 <cprintf>
            exit(0);
  8005f0:	4501                	li	a0,0
  8005f2:	b47ff0ef          	jal	ra,800138 <exit>

00000000008005f6 <main>:
}

int
main(void) {
  8005f6:	1141                	addi	sp,sp,-16
  8005f8:	e406                	sd	ra,8(sp)
  8005fa:	e022                	sd	s0,0(sp)
    parent = getpid();
  8005fc:	b5bff0ef          	jal	ra,800156 <getpid>
  800600:	00001797          	auipc	a5,0x1
  800604:	a0a7a023          	sw	a0,-1536(a5) # 801000 <parent>
    if ((pid1 = fork()) == 0) {
  800608:	00001417          	auipc	s0,0x1
  80060c:	9fc40413          	addi	s0,s0,-1540 # 801004 <pid1>
  800610:	b3fff0ef          	jal	ra,80014e <fork>
  800614:	c008                	sw	a0,0(s0)
  800616:	c13d                	beqz	a0,80067c <main+0x86>
        loop();
    }

    assert(pid1 > 0);
  800618:	04a05263          	blez	a0,80065c <main+0x66>

    if ((pid2 = fork()) == 0) {
  80061c:	b33ff0ef          	jal	ra,80014e <fork>
  800620:	00001797          	auipc	a5,0x1
  800624:	9ea7a423          	sw	a0,-1560(a5) # 801008 <pid2>
  800628:	c93d                	beqz	a0,80069e <main+0xa8>
        work();
    }
    if (pid2 > 0) {
  80062a:	04a05b63          	blez	a0,800680 <main+0x8a>
        cprintf("wait child 1.\n");
  80062e:	00000517          	auipc	a0,0x0
  800632:	45250513          	addi	a0,a0,1106 # 800a80 <error_string+0x150>
  800636:	a6dff0ef          	jal	ra,8000a2 <cprintf>
        waitpid(pid1, NULL);
  80063a:	4008                	lw	a0,0(s0)
  80063c:	4581                	li	a1,0
  80063e:	b13ff0ef          	jal	ra,800150 <waitpid>
        panic("waitpid %d returns\n", pid1);
  800642:	4014                	lw	a3,0(s0)
  800644:	00000617          	auipc	a2,0x0
  800648:	44c60613          	addi	a2,a2,1100 # 800a90 <error_string+0x160>
  80064c:	03400593          	li	a1,52
  800650:	00000517          	auipc	a0,0x0
  800654:	42050513          	addi	a0,a0,1056 # 800a70 <error_string+0x140>
  800658:	9cfff0ef          	jal	ra,800026 <__panic>
    assert(pid1 > 0);
  80065c:	00000697          	auipc	a3,0x0
  800660:	3ec68693          	addi	a3,a3,1004 # 800a48 <error_string+0x118>
  800664:	00000617          	auipc	a2,0x0
  800668:	3f460613          	addi	a2,a2,1012 # 800a58 <error_string+0x128>
  80066c:	02c00593          	li	a1,44
  800670:	00000517          	auipc	a0,0x0
  800674:	40050513          	addi	a0,a0,1024 # 800a70 <error_string+0x140>
  800678:	9afff0ef          	jal	ra,800026 <__panic>
        loop();
  80067c:	f11ff0ef          	jal	ra,80058c <loop>
    }
    else {
        kill(pid1);
  800680:	4008                	lw	a0,0(s0)
  800682:	ad3ff0ef          	jal	ra,800154 <kill>
    }
    panic("FAIL: T.T\n");
  800686:	00000617          	auipc	a2,0x0
  80068a:	42260613          	addi	a2,a2,1058 # 800aa8 <error_string+0x178>
  80068e:	03900593          	li	a1,57
  800692:	00000517          	auipc	a0,0x0
  800696:	3de50513          	addi	a0,a0,990 # 800a70 <error_string+0x140>
  80069a:	98dff0ef          	jal	ra,800026 <__panic>
        work();
  80069e:	f01ff0ef          	jal	ra,80059e <work>
