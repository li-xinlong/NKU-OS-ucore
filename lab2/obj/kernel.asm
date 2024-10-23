
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200000:	c02052b7          	lui	t0,0xc0205
    # t1 := 0xffffffff40000000 即虚实映射偏移量
    li      t1, 0xffffffffc0000000 - 0x80000000
ffffffffc0200004:	ffd0031b          	addiw	t1,zero,-3
ffffffffc0200008:	037a                	slli	t1,t1,0x1e
    # t0 减去虚实映射偏移量 0xffffffff40000000，变为三级页表的物理地址
    sub     t0, t0, t1
ffffffffc020000a:	406282b3          	sub	t0,t0,t1
    # t0 >>= 12，变为三级页表的物理页号
    srli    t0, t0, 12
ffffffffc020000e:	00c2d293          	srli	t0,t0,0xc

    # t1 := 8 << 60，设置 satp 的 MODE 字段为 Sv39
    li      t1, 8 << 60
ffffffffc0200012:	fff0031b          	addiw	t1,zero,-1
ffffffffc0200016:	137e                	slli	t1,t1,0x3f
    # 将刚才计算出的预设三级页表物理页号附加到 satp 中
    or      t0, t0, t1
ffffffffc0200018:	0062e2b3          	or	t0,t0,t1
    # 将算出的 t0(即新的MODE|页表基址物理页号) 覆盖到 satp 中
    csrw    satp, t0
ffffffffc020001c:	18029073          	csrw	satp,t0
    # 使用 sfence.vma 指令刷新 TLB
    sfence.vma
ffffffffc0200020:	12000073          	sfence.vma
    # 从此，我们给内核搭建出了一个完美的虚拟内存空间！
    #nop # 可能映射的位置有些bug。。插入一个nop
    
    # 我们在虚拟内存空间中：随意将 sp 设置为虚拟地址！
    lui sp, %hi(bootstacktop)
ffffffffc0200024:	c0205137          	lui	sp,0xc0205

    # 我们在虚拟内存空间中：随意跳转到虚拟地址！
    # 跳转到 kern_init
    lui t0, %hi(kern_init)
ffffffffc0200028:	c02002b7          	lui	t0,0xc0200
    addi t0, t0, %lo(kern_init)
ffffffffc020002c:	03228293          	addi	t0,t0,50 # ffffffffc0200032 <kern_init>
    jr t0
ffffffffc0200030:	8282                	jr	t0

ffffffffc0200032 <kern_init>:
void grade_backtrace(void);


int kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc0200032:	00006517          	auipc	a0,0x6
ffffffffc0200036:	fde50513          	addi	a0,a0,-34 # ffffffffc0206010 <free_area_slub>
ffffffffc020003a:	00006617          	auipc	a2,0x6
ffffffffc020003e:	44e60613          	addi	a2,a2,1102 # ffffffffc0206488 <end>
int kern_init(void) {
ffffffffc0200042:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200044:	8e09                	sub	a2,a2,a0
ffffffffc0200046:	4581                	li	a1,0
int kern_init(void) {
ffffffffc0200048:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004a:	5ae010ef          	jal	ra,ffffffffc02015f8 <memset>
    cons_init();  // init the console
ffffffffc020004e:	3fc000ef          	jal	ra,ffffffffc020044a <cons_init>
    const char *message = "(THU.CST) os is loading ...\0";
    //cprintf("%s\n\n", message);
    cputs(message);
ffffffffc0200052:	00001517          	auipc	a0,0x1
ffffffffc0200056:	5be50513          	addi	a0,a0,1470 # ffffffffc0201610 <etext+0x6>
ffffffffc020005a:	090000ef          	jal	ra,ffffffffc02000ea <cputs>

    print_kerninfo();
ffffffffc020005e:	0dc000ef          	jal	ra,ffffffffc020013a <print_kerninfo>

    // grade_backtrace();
    idt_init();  // init interrupt descriptor table
ffffffffc0200062:	402000ef          	jal	ra,ffffffffc0200464 <idt_init>

    pmm_init();  // init physical memory management
ffffffffc0200066:	79c000ef          	jal	ra,ffffffffc0200802 <pmm_init>

    idt_init();  // init interrupt descriptor table
ffffffffc020006a:	3fa000ef          	jal	ra,ffffffffc0200464 <idt_init>

    clock_init();   // init clock interrupt
ffffffffc020006e:	39a000ef          	jal	ra,ffffffffc0200408 <clock_init>
    intr_enable();  // enable irq interrupt
ffffffffc0200072:	3e6000ef          	jal	ra,ffffffffc0200458 <intr_enable>
    /* do nothing */
    while (1)
ffffffffc0200076:	a001                	j	ffffffffc0200076 <kern_init+0x44>

ffffffffc0200078 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc0200078:	1141                	addi	sp,sp,-16
ffffffffc020007a:	e022                	sd	s0,0(sp)
ffffffffc020007c:	e406                	sd	ra,8(sp)
ffffffffc020007e:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc0200080:	3cc000ef          	jal	ra,ffffffffc020044c <cons_putc>
    (*cnt) ++;
ffffffffc0200084:	401c                	lw	a5,0(s0)
}
ffffffffc0200086:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc0200088:	2785                	addiw	a5,a5,1
ffffffffc020008a:	c01c                	sw	a5,0(s0)
}
ffffffffc020008c:	6402                	ld	s0,0(sp)
ffffffffc020008e:	0141                	addi	sp,sp,16
ffffffffc0200090:	8082                	ret

ffffffffc0200092 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc0200092:	1101                	addi	sp,sp,-32
ffffffffc0200094:	862a                	mv	a2,a0
ffffffffc0200096:	86ae                	mv	a3,a1
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200098:	00000517          	auipc	a0,0x0
ffffffffc020009c:	fe050513          	addi	a0,a0,-32 # ffffffffc0200078 <cputch>
ffffffffc02000a0:	006c                	addi	a1,sp,12
vcprintf(const char *fmt, va_list ap) {
ffffffffc02000a2:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc02000a4:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000a6:	07c010ef          	jal	ra,ffffffffc0201122 <vprintfmt>
    return cnt;
}
ffffffffc02000aa:	60e2                	ld	ra,24(sp)
ffffffffc02000ac:	4532                	lw	a0,12(sp)
ffffffffc02000ae:	6105                	addi	sp,sp,32
ffffffffc02000b0:	8082                	ret

ffffffffc02000b2 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc02000b2:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc02000b4:	02810313          	addi	t1,sp,40 # ffffffffc0205028 <boot_page_table_sv39+0x28>
cprintf(const char *fmt, ...) {
ffffffffc02000b8:	8e2a                	mv	t3,a0
ffffffffc02000ba:	f42e                	sd	a1,40(sp)
ffffffffc02000bc:	f832                	sd	a2,48(sp)
ffffffffc02000be:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000c0:	00000517          	auipc	a0,0x0
ffffffffc02000c4:	fb850513          	addi	a0,a0,-72 # ffffffffc0200078 <cputch>
ffffffffc02000c8:	004c                	addi	a1,sp,4
ffffffffc02000ca:	869a                	mv	a3,t1
ffffffffc02000cc:	8672                	mv	a2,t3
cprintf(const char *fmt, ...) {
ffffffffc02000ce:	ec06                	sd	ra,24(sp)
ffffffffc02000d0:	e0ba                	sd	a4,64(sp)
ffffffffc02000d2:	e4be                	sd	a5,72(sp)
ffffffffc02000d4:	e8c2                	sd	a6,80(sp)
ffffffffc02000d6:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc02000d8:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc02000da:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000dc:	046010ef          	jal	ra,ffffffffc0201122 <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02000e0:	60e2                	ld	ra,24(sp)
ffffffffc02000e2:	4512                	lw	a0,4(sp)
ffffffffc02000e4:	6125                	addi	sp,sp,96
ffffffffc02000e6:	8082                	ret

ffffffffc02000e8 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc02000e8:	a695                	j	ffffffffc020044c <cons_putc>

ffffffffc02000ea <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
ffffffffc02000ea:	1101                	addi	sp,sp,-32
ffffffffc02000ec:	e822                	sd	s0,16(sp)
ffffffffc02000ee:	ec06                	sd	ra,24(sp)
ffffffffc02000f0:	e426                	sd	s1,8(sp)
ffffffffc02000f2:	842a                	mv	s0,a0
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
ffffffffc02000f4:	00054503          	lbu	a0,0(a0)
ffffffffc02000f8:	c51d                	beqz	a0,ffffffffc0200126 <cputs+0x3c>
ffffffffc02000fa:	0405                	addi	s0,s0,1
ffffffffc02000fc:	4485                	li	s1,1
ffffffffc02000fe:	9c81                	subw	s1,s1,s0
    cons_putc(c);
ffffffffc0200100:	34c000ef          	jal	ra,ffffffffc020044c <cons_putc>
    while ((c = *str ++) != '\0') {
ffffffffc0200104:	00044503          	lbu	a0,0(s0)
ffffffffc0200108:	008487bb          	addw	a5,s1,s0
ffffffffc020010c:	0405                	addi	s0,s0,1
ffffffffc020010e:	f96d                	bnez	a0,ffffffffc0200100 <cputs+0x16>
    (*cnt) ++;
ffffffffc0200110:	0017841b          	addiw	s0,a5,1
    cons_putc(c);
ffffffffc0200114:	4529                	li	a0,10
ffffffffc0200116:	336000ef          	jal	ra,ffffffffc020044c <cons_putc>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
    return cnt;
}
ffffffffc020011a:	60e2                	ld	ra,24(sp)
ffffffffc020011c:	8522                	mv	a0,s0
ffffffffc020011e:	6442                	ld	s0,16(sp)
ffffffffc0200120:	64a2                	ld	s1,8(sp)
ffffffffc0200122:	6105                	addi	sp,sp,32
ffffffffc0200124:	8082                	ret
    while ((c = *str ++) != '\0') {
ffffffffc0200126:	4405                	li	s0,1
ffffffffc0200128:	b7f5                	j	ffffffffc0200114 <cputs+0x2a>

ffffffffc020012a <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc020012a:	1141                	addi	sp,sp,-16
ffffffffc020012c:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc020012e:	326000ef          	jal	ra,ffffffffc0200454 <cons_getc>
ffffffffc0200132:	dd75                	beqz	a0,ffffffffc020012e <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc0200134:	60a2                	ld	ra,8(sp)
ffffffffc0200136:	0141                	addi	sp,sp,16
ffffffffc0200138:	8082                	ret

ffffffffc020013a <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc020013a:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc020013c:	00001517          	auipc	a0,0x1
ffffffffc0200140:	4f450513          	addi	a0,a0,1268 # ffffffffc0201630 <etext+0x26>
void print_kerninfo(void) {
ffffffffc0200144:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc0200146:	f6dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  entry  0x%016lx (virtual)\n", kern_init);
ffffffffc020014a:	00000597          	auipc	a1,0x0
ffffffffc020014e:	ee858593          	addi	a1,a1,-280 # ffffffffc0200032 <kern_init>
ffffffffc0200152:	00001517          	auipc	a0,0x1
ffffffffc0200156:	4fe50513          	addi	a0,a0,1278 # ffffffffc0201650 <etext+0x46>
ffffffffc020015a:	f59ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  etext  0x%016lx (virtual)\n", etext);
ffffffffc020015e:	00001597          	auipc	a1,0x1
ffffffffc0200162:	4ac58593          	addi	a1,a1,1196 # ffffffffc020160a <etext>
ffffffffc0200166:	00001517          	auipc	a0,0x1
ffffffffc020016a:	50a50513          	addi	a0,a0,1290 # ffffffffc0201670 <etext+0x66>
ffffffffc020016e:	f45ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  edata  0x%016lx (virtual)\n", edata);
ffffffffc0200172:	00006597          	auipc	a1,0x6
ffffffffc0200176:	e9e58593          	addi	a1,a1,-354 # ffffffffc0206010 <free_area_slub>
ffffffffc020017a:	00001517          	auipc	a0,0x1
ffffffffc020017e:	51650513          	addi	a0,a0,1302 # ffffffffc0201690 <etext+0x86>
ffffffffc0200182:	f31ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  end    0x%016lx (virtual)\n", end);
ffffffffc0200186:	00006597          	auipc	a1,0x6
ffffffffc020018a:	30258593          	addi	a1,a1,770 # ffffffffc0206488 <end>
ffffffffc020018e:	00001517          	auipc	a0,0x1
ffffffffc0200192:	52250513          	addi	a0,a0,1314 # ffffffffc02016b0 <etext+0xa6>
ffffffffc0200196:	f1dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc020019a:	00006597          	auipc	a1,0x6
ffffffffc020019e:	6ed58593          	addi	a1,a1,1773 # ffffffffc0206887 <end+0x3ff>
ffffffffc02001a2:	00000797          	auipc	a5,0x0
ffffffffc02001a6:	e9078793          	addi	a5,a5,-368 # ffffffffc0200032 <kern_init>
ffffffffc02001aa:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001ae:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc02001b2:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001b4:	3ff5f593          	andi	a1,a1,1023
ffffffffc02001b8:	95be                	add	a1,a1,a5
ffffffffc02001ba:	85a9                	srai	a1,a1,0xa
ffffffffc02001bc:	00001517          	auipc	a0,0x1
ffffffffc02001c0:	51450513          	addi	a0,a0,1300 # ffffffffc02016d0 <etext+0xc6>
}
ffffffffc02001c4:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001c6:	b5f5                	j	ffffffffc02000b2 <cprintf>

ffffffffc02001c8 <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc02001c8:	1141                	addi	sp,sp,-16

    panic("Not Implemented!");
ffffffffc02001ca:	00001617          	auipc	a2,0x1
ffffffffc02001ce:	53660613          	addi	a2,a2,1334 # ffffffffc0201700 <etext+0xf6>
ffffffffc02001d2:	04e00593          	li	a1,78
ffffffffc02001d6:	00001517          	auipc	a0,0x1
ffffffffc02001da:	54250513          	addi	a0,a0,1346 # ffffffffc0201718 <etext+0x10e>
void print_stackframe(void) {
ffffffffc02001de:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc02001e0:	1cc000ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc02001e4 <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02001e4:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02001e6:	00001617          	auipc	a2,0x1
ffffffffc02001ea:	54a60613          	addi	a2,a2,1354 # ffffffffc0201730 <etext+0x126>
ffffffffc02001ee:	00001597          	auipc	a1,0x1
ffffffffc02001f2:	56258593          	addi	a1,a1,1378 # ffffffffc0201750 <etext+0x146>
ffffffffc02001f6:	00001517          	auipc	a0,0x1
ffffffffc02001fa:	56250513          	addi	a0,a0,1378 # ffffffffc0201758 <etext+0x14e>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02001fe:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200200:	eb3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc0200204:	00001617          	auipc	a2,0x1
ffffffffc0200208:	56460613          	addi	a2,a2,1380 # ffffffffc0201768 <etext+0x15e>
ffffffffc020020c:	00001597          	auipc	a1,0x1
ffffffffc0200210:	58458593          	addi	a1,a1,1412 # ffffffffc0201790 <etext+0x186>
ffffffffc0200214:	00001517          	auipc	a0,0x1
ffffffffc0200218:	54450513          	addi	a0,a0,1348 # ffffffffc0201758 <etext+0x14e>
ffffffffc020021c:	e97ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc0200220:	00001617          	auipc	a2,0x1
ffffffffc0200224:	58060613          	addi	a2,a2,1408 # ffffffffc02017a0 <etext+0x196>
ffffffffc0200228:	00001597          	auipc	a1,0x1
ffffffffc020022c:	59858593          	addi	a1,a1,1432 # ffffffffc02017c0 <etext+0x1b6>
ffffffffc0200230:	00001517          	auipc	a0,0x1
ffffffffc0200234:	52850513          	addi	a0,a0,1320 # ffffffffc0201758 <etext+0x14e>
ffffffffc0200238:	e7bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    }
    return 0;
}
ffffffffc020023c:	60a2                	ld	ra,8(sp)
ffffffffc020023e:	4501                	li	a0,0
ffffffffc0200240:	0141                	addi	sp,sp,16
ffffffffc0200242:	8082                	ret

ffffffffc0200244 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200244:	1141                	addi	sp,sp,-16
ffffffffc0200246:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc0200248:	ef3ff0ef          	jal	ra,ffffffffc020013a <print_kerninfo>
    return 0;
}
ffffffffc020024c:	60a2                	ld	ra,8(sp)
ffffffffc020024e:	4501                	li	a0,0
ffffffffc0200250:	0141                	addi	sp,sp,16
ffffffffc0200252:	8082                	ret

ffffffffc0200254 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200254:	1141                	addi	sp,sp,-16
ffffffffc0200256:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc0200258:	f71ff0ef          	jal	ra,ffffffffc02001c8 <print_stackframe>
    return 0;
}
ffffffffc020025c:	60a2                	ld	ra,8(sp)
ffffffffc020025e:	4501                	li	a0,0
ffffffffc0200260:	0141                	addi	sp,sp,16
ffffffffc0200262:	8082                	ret

ffffffffc0200264 <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc0200264:	7115                	addi	sp,sp,-224
ffffffffc0200266:	ed5e                	sd	s7,152(sp)
ffffffffc0200268:	8baa                	mv	s7,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc020026a:	00001517          	auipc	a0,0x1
ffffffffc020026e:	56650513          	addi	a0,a0,1382 # ffffffffc02017d0 <etext+0x1c6>
kmonitor(struct trapframe *tf) {
ffffffffc0200272:	ed86                	sd	ra,216(sp)
ffffffffc0200274:	e9a2                	sd	s0,208(sp)
ffffffffc0200276:	e5a6                	sd	s1,200(sp)
ffffffffc0200278:	e1ca                	sd	s2,192(sp)
ffffffffc020027a:	fd4e                	sd	s3,184(sp)
ffffffffc020027c:	f952                	sd	s4,176(sp)
ffffffffc020027e:	f556                	sd	s5,168(sp)
ffffffffc0200280:	f15a                	sd	s6,160(sp)
ffffffffc0200282:	e962                	sd	s8,144(sp)
ffffffffc0200284:	e566                	sd	s9,136(sp)
ffffffffc0200286:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200288:	e2bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc020028c:	00001517          	auipc	a0,0x1
ffffffffc0200290:	56c50513          	addi	a0,a0,1388 # ffffffffc02017f8 <etext+0x1ee>
ffffffffc0200294:	e1fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    if (tf != NULL) {
ffffffffc0200298:	000b8563          	beqz	s7,ffffffffc02002a2 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc020029c:	855e                	mv	a0,s7
ffffffffc020029e:	3a4000ef          	jal	ra,ffffffffc0200642 <print_trapframe>
ffffffffc02002a2:	00001c17          	auipc	s8,0x1
ffffffffc02002a6:	5c6c0c13          	addi	s8,s8,1478 # ffffffffc0201868 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002aa:	00001917          	auipc	s2,0x1
ffffffffc02002ae:	57690913          	addi	s2,s2,1398 # ffffffffc0201820 <etext+0x216>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002b2:	00001497          	auipc	s1,0x1
ffffffffc02002b6:	57648493          	addi	s1,s1,1398 # ffffffffc0201828 <etext+0x21e>
        if (argc == MAXARGS - 1) {
ffffffffc02002ba:	49bd                	li	s3,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02002bc:	00001b17          	auipc	s6,0x1
ffffffffc02002c0:	574b0b13          	addi	s6,s6,1396 # ffffffffc0201830 <etext+0x226>
        argv[argc ++] = buf;
ffffffffc02002c4:	00001a17          	auipc	s4,0x1
ffffffffc02002c8:	48ca0a13          	addi	s4,s4,1164 # ffffffffc0201750 <etext+0x146>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002cc:	4a8d                	li	s5,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002ce:	854a                	mv	a0,s2
ffffffffc02002d0:	1d4010ef          	jal	ra,ffffffffc02014a4 <readline>
ffffffffc02002d4:	842a                	mv	s0,a0
ffffffffc02002d6:	dd65                	beqz	a0,ffffffffc02002ce <kmonitor+0x6a>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002d8:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc02002dc:	4c81                	li	s9,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002de:	e1bd                	bnez	a1,ffffffffc0200344 <kmonitor+0xe0>
    if (argc == 0) {
ffffffffc02002e0:	fe0c87e3          	beqz	s9,ffffffffc02002ce <kmonitor+0x6a>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002e4:	6582                	ld	a1,0(sp)
ffffffffc02002e6:	00001d17          	auipc	s10,0x1
ffffffffc02002ea:	582d0d13          	addi	s10,s10,1410 # ffffffffc0201868 <commands>
        argv[argc ++] = buf;
ffffffffc02002ee:	8552                	mv	a0,s4
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002f0:	4401                	li	s0,0
ffffffffc02002f2:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002f4:	2d0010ef          	jal	ra,ffffffffc02015c4 <strcmp>
ffffffffc02002f8:	c919                	beqz	a0,ffffffffc020030e <kmonitor+0xaa>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002fa:	2405                	addiw	s0,s0,1
ffffffffc02002fc:	0b540063          	beq	s0,s5,ffffffffc020039c <kmonitor+0x138>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200300:	000d3503          	ld	a0,0(s10)
ffffffffc0200304:	6582                	ld	a1,0(sp)
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200306:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200308:	2bc010ef          	jal	ra,ffffffffc02015c4 <strcmp>
ffffffffc020030c:	f57d                	bnez	a0,ffffffffc02002fa <kmonitor+0x96>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc020030e:	00141793          	slli	a5,s0,0x1
ffffffffc0200312:	97a2                	add	a5,a5,s0
ffffffffc0200314:	078e                	slli	a5,a5,0x3
ffffffffc0200316:	97e2                	add	a5,a5,s8
ffffffffc0200318:	6b9c                	ld	a5,16(a5)
ffffffffc020031a:	865e                	mv	a2,s7
ffffffffc020031c:	002c                	addi	a1,sp,8
ffffffffc020031e:	fffc851b          	addiw	a0,s9,-1
ffffffffc0200322:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc0200324:	fa0555e3          	bgez	a0,ffffffffc02002ce <kmonitor+0x6a>
}
ffffffffc0200328:	60ee                	ld	ra,216(sp)
ffffffffc020032a:	644e                	ld	s0,208(sp)
ffffffffc020032c:	64ae                	ld	s1,200(sp)
ffffffffc020032e:	690e                	ld	s2,192(sp)
ffffffffc0200330:	79ea                	ld	s3,184(sp)
ffffffffc0200332:	7a4a                	ld	s4,176(sp)
ffffffffc0200334:	7aaa                	ld	s5,168(sp)
ffffffffc0200336:	7b0a                	ld	s6,160(sp)
ffffffffc0200338:	6bea                	ld	s7,152(sp)
ffffffffc020033a:	6c4a                	ld	s8,144(sp)
ffffffffc020033c:	6caa                	ld	s9,136(sp)
ffffffffc020033e:	6d0a                	ld	s10,128(sp)
ffffffffc0200340:	612d                	addi	sp,sp,224
ffffffffc0200342:	8082                	ret
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200344:	8526                	mv	a0,s1
ffffffffc0200346:	29c010ef          	jal	ra,ffffffffc02015e2 <strchr>
ffffffffc020034a:	c901                	beqz	a0,ffffffffc020035a <kmonitor+0xf6>
ffffffffc020034c:	00144583          	lbu	a1,1(s0)
            *buf ++ = '\0';
ffffffffc0200350:	00040023          	sb	zero,0(s0)
ffffffffc0200354:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200356:	d5c9                	beqz	a1,ffffffffc02002e0 <kmonitor+0x7c>
ffffffffc0200358:	b7f5                	j	ffffffffc0200344 <kmonitor+0xe0>
        if (*buf == '\0') {
ffffffffc020035a:	00044783          	lbu	a5,0(s0)
ffffffffc020035e:	d3c9                	beqz	a5,ffffffffc02002e0 <kmonitor+0x7c>
        if (argc == MAXARGS - 1) {
ffffffffc0200360:	033c8963          	beq	s9,s3,ffffffffc0200392 <kmonitor+0x12e>
        argv[argc ++] = buf;
ffffffffc0200364:	003c9793          	slli	a5,s9,0x3
ffffffffc0200368:	0118                	addi	a4,sp,128
ffffffffc020036a:	97ba                	add	a5,a5,a4
ffffffffc020036c:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200370:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc0200374:	2c85                	addiw	s9,s9,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200376:	e591                	bnez	a1,ffffffffc0200382 <kmonitor+0x11e>
ffffffffc0200378:	b7b5                	j	ffffffffc02002e4 <kmonitor+0x80>
ffffffffc020037a:	00144583          	lbu	a1,1(s0)
            buf ++;
ffffffffc020037e:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200380:	d1a5                	beqz	a1,ffffffffc02002e0 <kmonitor+0x7c>
ffffffffc0200382:	8526                	mv	a0,s1
ffffffffc0200384:	25e010ef          	jal	ra,ffffffffc02015e2 <strchr>
ffffffffc0200388:	d96d                	beqz	a0,ffffffffc020037a <kmonitor+0x116>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020038a:	00044583          	lbu	a1,0(s0)
ffffffffc020038e:	d9a9                	beqz	a1,ffffffffc02002e0 <kmonitor+0x7c>
ffffffffc0200390:	bf55                	j	ffffffffc0200344 <kmonitor+0xe0>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200392:	45c1                	li	a1,16
ffffffffc0200394:	855a                	mv	a0,s6
ffffffffc0200396:	d1dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc020039a:	b7e9                	j	ffffffffc0200364 <kmonitor+0x100>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc020039c:	6582                	ld	a1,0(sp)
ffffffffc020039e:	00001517          	auipc	a0,0x1
ffffffffc02003a2:	4b250513          	addi	a0,a0,1202 # ffffffffc0201850 <etext+0x246>
ffffffffc02003a6:	d0dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    return 0;
ffffffffc02003aa:	b715                	j	ffffffffc02002ce <kmonitor+0x6a>

ffffffffc02003ac <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc02003ac:	00006317          	auipc	t1,0x6
ffffffffc02003b0:	09430313          	addi	t1,t1,148 # ffffffffc0206440 <is_panic>
ffffffffc02003b4:	00032e03          	lw	t3,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc02003b8:	715d                	addi	sp,sp,-80
ffffffffc02003ba:	ec06                	sd	ra,24(sp)
ffffffffc02003bc:	e822                	sd	s0,16(sp)
ffffffffc02003be:	f436                	sd	a3,40(sp)
ffffffffc02003c0:	f83a                	sd	a4,48(sp)
ffffffffc02003c2:	fc3e                	sd	a5,56(sp)
ffffffffc02003c4:	e0c2                	sd	a6,64(sp)
ffffffffc02003c6:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc02003c8:	020e1a63          	bnez	t3,ffffffffc02003fc <__panic+0x50>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc02003cc:	4785                	li	a5,1
ffffffffc02003ce:	00f32023          	sw	a5,0(t1)

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
ffffffffc02003d2:	8432                	mv	s0,a2
ffffffffc02003d4:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003d6:	862e                	mv	a2,a1
ffffffffc02003d8:	85aa                	mv	a1,a0
ffffffffc02003da:	00001517          	auipc	a0,0x1
ffffffffc02003de:	4d650513          	addi	a0,a0,1238 # ffffffffc02018b0 <commands+0x48>
    va_start(ap, fmt);
ffffffffc02003e2:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003e4:	ccfff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    vcprintf(fmt, ap);
ffffffffc02003e8:	65a2                	ld	a1,8(sp)
ffffffffc02003ea:	8522                	mv	a0,s0
ffffffffc02003ec:	ca7ff0ef          	jal	ra,ffffffffc0200092 <vcprintf>
    cprintf("\n");
ffffffffc02003f0:	00001517          	auipc	a0,0x1
ffffffffc02003f4:	30850513          	addi	a0,a0,776 # ffffffffc02016f8 <etext+0xee>
ffffffffc02003f8:	cbbff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    va_end(ap);

panic_dead:
    intr_disable();
ffffffffc02003fc:	062000ef          	jal	ra,ffffffffc020045e <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc0200400:	4501                	li	a0,0
ffffffffc0200402:	e63ff0ef          	jal	ra,ffffffffc0200264 <kmonitor>
    while (1) {
ffffffffc0200406:	bfed                	j	ffffffffc0200400 <__panic+0x54>

ffffffffc0200408 <clock_init>:

/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
ffffffffc0200408:	1141                	addi	sp,sp,-16
ffffffffc020040a:	e406                	sd	ra,8(sp)
    // enable timer interrupt in sie
    set_csr(sie, MIP_STIP);
ffffffffc020040c:	02000793          	li	a5,32
ffffffffc0200410:	1047a7f3          	csrrs	a5,sie,a5
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200414:	c0102573          	rdtime	a0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200418:	67e1                	lui	a5,0x18
ffffffffc020041a:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0xffffffffc01e7960>
ffffffffc020041e:	953e                	add	a0,a0,a5
ffffffffc0200420:	152010ef          	jal	ra,ffffffffc0201572 <sbi_set_timer>
}
ffffffffc0200424:	60a2                	ld	ra,8(sp)
    ticks = 0;
ffffffffc0200426:	00006797          	auipc	a5,0x6
ffffffffc020042a:	0207b123          	sd	zero,34(a5) # ffffffffc0206448 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc020042e:	00001517          	auipc	a0,0x1
ffffffffc0200432:	4a250513          	addi	a0,a0,1186 # ffffffffc02018d0 <commands+0x68>
}
ffffffffc0200436:	0141                	addi	sp,sp,16
    cprintf("++ setup timer interrupts\n");
ffffffffc0200438:	b9ad                	j	ffffffffc02000b2 <cprintf>

ffffffffc020043a <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc020043a:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc020043e:	67e1                	lui	a5,0x18
ffffffffc0200440:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0xffffffffc01e7960>
ffffffffc0200444:	953e                	add	a0,a0,a5
ffffffffc0200446:	12c0106f          	j	ffffffffc0201572 <sbi_set_timer>

ffffffffc020044a <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc020044a:	8082                	ret

ffffffffc020044c <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) { sbi_console_putchar((unsigned char)c); }
ffffffffc020044c:	0ff57513          	zext.b	a0,a0
ffffffffc0200450:	1080106f          	j	ffffffffc0201558 <sbi_console_putchar>

ffffffffc0200454 <cons_getc>:
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int cons_getc(void) {
    int c = 0;
    c = sbi_console_getchar();
ffffffffc0200454:	1380106f          	j	ffffffffc020158c <sbi_console_getchar>

ffffffffc0200458 <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc0200458:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc020045c:	8082                	ret

ffffffffc020045e <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc020045e:	100177f3          	csrrci	a5,sstatus,2
ffffffffc0200462:	8082                	ret

ffffffffc0200464 <idt_init>:
     */

    extern void __alltraps(void);
    /* Set sup0 scratch register to 0, indicating to exception vector
       that we are presently executing in the kernel */
    write_csr(sscratch, 0);
ffffffffc0200464:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
ffffffffc0200468:	00000797          	auipc	a5,0x0
ffffffffc020046c:	2e478793          	addi	a5,a5,740 # ffffffffc020074c <__alltraps>
ffffffffc0200470:	10579073          	csrw	stvec,a5
}
ffffffffc0200474:	8082                	ret

ffffffffc0200476 <print_regs>:
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs *gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200476:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
ffffffffc0200478:	1141                	addi	sp,sp,-16
ffffffffc020047a:	e022                	sd	s0,0(sp)
ffffffffc020047c:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020047e:	00001517          	auipc	a0,0x1
ffffffffc0200482:	47250513          	addi	a0,a0,1138 # ffffffffc02018f0 <commands+0x88>
void print_regs(struct pushregs *gpr) {
ffffffffc0200486:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200488:	c2bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc020048c:	640c                	ld	a1,8(s0)
ffffffffc020048e:	00001517          	auipc	a0,0x1
ffffffffc0200492:	47a50513          	addi	a0,a0,1146 # ffffffffc0201908 <commands+0xa0>
ffffffffc0200496:	c1dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc020049a:	680c                	ld	a1,16(s0)
ffffffffc020049c:	00001517          	auipc	a0,0x1
ffffffffc02004a0:	48450513          	addi	a0,a0,1156 # ffffffffc0201920 <commands+0xb8>
ffffffffc02004a4:	c0fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02004a8:	6c0c                	ld	a1,24(s0)
ffffffffc02004aa:	00001517          	auipc	a0,0x1
ffffffffc02004ae:	48e50513          	addi	a0,a0,1166 # ffffffffc0201938 <commands+0xd0>
ffffffffc02004b2:	c01ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02004b6:	700c                	ld	a1,32(s0)
ffffffffc02004b8:	00001517          	auipc	a0,0x1
ffffffffc02004bc:	49850513          	addi	a0,a0,1176 # ffffffffc0201950 <commands+0xe8>
ffffffffc02004c0:	bf3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02004c4:	740c                	ld	a1,40(s0)
ffffffffc02004c6:	00001517          	auipc	a0,0x1
ffffffffc02004ca:	4a250513          	addi	a0,a0,1186 # ffffffffc0201968 <commands+0x100>
ffffffffc02004ce:	be5ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02004d2:	780c                	ld	a1,48(s0)
ffffffffc02004d4:	00001517          	auipc	a0,0x1
ffffffffc02004d8:	4ac50513          	addi	a0,a0,1196 # ffffffffc0201980 <commands+0x118>
ffffffffc02004dc:	bd7ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02004e0:	7c0c                	ld	a1,56(s0)
ffffffffc02004e2:	00001517          	auipc	a0,0x1
ffffffffc02004e6:	4b650513          	addi	a0,a0,1206 # ffffffffc0201998 <commands+0x130>
ffffffffc02004ea:	bc9ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02004ee:	602c                	ld	a1,64(s0)
ffffffffc02004f0:	00001517          	auipc	a0,0x1
ffffffffc02004f4:	4c050513          	addi	a0,a0,1216 # ffffffffc02019b0 <commands+0x148>
ffffffffc02004f8:	bbbff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc02004fc:	642c                	ld	a1,72(s0)
ffffffffc02004fe:	00001517          	auipc	a0,0x1
ffffffffc0200502:	4ca50513          	addi	a0,a0,1226 # ffffffffc02019c8 <commands+0x160>
ffffffffc0200506:	badff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc020050a:	682c                	ld	a1,80(s0)
ffffffffc020050c:	00001517          	auipc	a0,0x1
ffffffffc0200510:	4d450513          	addi	a0,a0,1236 # ffffffffc02019e0 <commands+0x178>
ffffffffc0200514:	b9fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc0200518:	6c2c                	ld	a1,88(s0)
ffffffffc020051a:	00001517          	auipc	a0,0x1
ffffffffc020051e:	4de50513          	addi	a0,a0,1246 # ffffffffc02019f8 <commands+0x190>
ffffffffc0200522:	b91ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200526:	702c                	ld	a1,96(s0)
ffffffffc0200528:	00001517          	auipc	a0,0x1
ffffffffc020052c:	4e850513          	addi	a0,a0,1256 # ffffffffc0201a10 <commands+0x1a8>
ffffffffc0200530:	b83ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200534:	742c                	ld	a1,104(s0)
ffffffffc0200536:	00001517          	auipc	a0,0x1
ffffffffc020053a:	4f250513          	addi	a0,a0,1266 # ffffffffc0201a28 <commands+0x1c0>
ffffffffc020053e:	b75ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200542:	782c                	ld	a1,112(s0)
ffffffffc0200544:	00001517          	auipc	a0,0x1
ffffffffc0200548:	4fc50513          	addi	a0,a0,1276 # ffffffffc0201a40 <commands+0x1d8>
ffffffffc020054c:	b67ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200550:	7c2c                	ld	a1,120(s0)
ffffffffc0200552:	00001517          	auipc	a0,0x1
ffffffffc0200556:	50650513          	addi	a0,a0,1286 # ffffffffc0201a58 <commands+0x1f0>
ffffffffc020055a:	b59ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc020055e:	604c                	ld	a1,128(s0)
ffffffffc0200560:	00001517          	auipc	a0,0x1
ffffffffc0200564:	51050513          	addi	a0,a0,1296 # ffffffffc0201a70 <commands+0x208>
ffffffffc0200568:	b4bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc020056c:	644c                	ld	a1,136(s0)
ffffffffc020056e:	00001517          	auipc	a0,0x1
ffffffffc0200572:	51a50513          	addi	a0,a0,1306 # ffffffffc0201a88 <commands+0x220>
ffffffffc0200576:	b3dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc020057a:	684c                	ld	a1,144(s0)
ffffffffc020057c:	00001517          	auipc	a0,0x1
ffffffffc0200580:	52450513          	addi	a0,a0,1316 # ffffffffc0201aa0 <commands+0x238>
ffffffffc0200584:	b2fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200588:	6c4c                	ld	a1,152(s0)
ffffffffc020058a:	00001517          	auipc	a0,0x1
ffffffffc020058e:	52e50513          	addi	a0,a0,1326 # ffffffffc0201ab8 <commands+0x250>
ffffffffc0200592:	b21ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200596:	704c                	ld	a1,160(s0)
ffffffffc0200598:	00001517          	auipc	a0,0x1
ffffffffc020059c:	53850513          	addi	a0,a0,1336 # ffffffffc0201ad0 <commands+0x268>
ffffffffc02005a0:	b13ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02005a4:	744c                	ld	a1,168(s0)
ffffffffc02005a6:	00001517          	auipc	a0,0x1
ffffffffc02005aa:	54250513          	addi	a0,a0,1346 # ffffffffc0201ae8 <commands+0x280>
ffffffffc02005ae:	b05ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02005b2:	784c                	ld	a1,176(s0)
ffffffffc02005b4:	00001517          	auipc	a0,0x1
ffffffffc02005b8:	54c50513          	addi	a0,a0,1356 # ffffffffc0201b00 <commands+0x298>
ffffffffc02005bc:	af7ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02005c0:	7c4c                	ld	a1,184(s0)
ffffffffc02005c2:	00001517          	auipc	a0,0x1
ffffffffc02005c6:	55650513          	addi	a0,a0,1366 # ffffffffc0201b18 <commands+0x2b0>
ffffffffc02005ca:	ae9ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02005ce:	606c                	ld	a1,192(s0)
ffffffffc02005d0:	00001517          	auipc	a0,0x1
ffffffffc02005d4:	56050513          	addi	a0,a0,1376 # ffffffffc0201b30 <commands+0x2c8>
ffffffffc02005d8:	adbff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02005dc:	646c                	ld	a1,200(s0)
ffffffffc02005de:	00001517          	auipc	a0,0x1
ffffffffc02005e2:	56a50513          	addi	a0,a0,1386 # ffffffffc0201b48 <commands+0x2e0>
ffffffffc02005e6:	acdff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02005ea:	686c                	ld	a1,208(s0)
ffffffffc02005ec:	00001517          	auipc	a0,0x1
ffffffffc02005f0:	57450513          	addi	a0,a0,1396 # ffffffffc0201b60 <commands+0x2f8>
ffffffffc02005f4:	abfff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02005f8:	6c6c                	ld	a1,216(s0)
ffffffffc02005fa:	00001517          	auipc	a0,0x1
ffffffffc02005fe:	57e50513          	addi	a0,a0,1406 # ffffffffc0201b78 <commands+0x310>
ffffffffc0200602:	ab1ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc0200606:	706c                	ld	a1,224(s0)
ffffffffc0200608:	00001517          	auipc	a0,0x1
ffffffffc020060c:	58850513          	addi	a0,a0,1416 # ffffffffc0201b90 <commands+0x328>
ffffffffc0200610:	aa3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200614:	746c                	ld	a1,232(s0)
ffffffffc0200616:	00001517          	auipc	a0,0x1
ffffffffc020061a:	59250513          	addi	a0,a0,1426 # ffffffffc0201ba8 <commands+0x340>
ffffffffc020061e:	a95ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200622:	786c                	ld	a1,240(s0)
ffffffffc0200624:	00001517          	auipc	a0,0x1
ffffffffc0200628:	59c50513          	addi	a0,a0,1436 # ffffffffc0201bc0 <commands+0x358>
ffffffffc020062c:	a87ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200630:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200632:	6402                	ld	s0,0(sp)
ffffffffc0200634:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200636:	00001517          	auipc	a0,0x1
ffffffffc020063a:	5a250513          	addi	a0,a0,1442 # ffffffffc0201bd8 <commands+0x370>
}
ffffffffc020063e:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200640:	bc8d                	j	ffffffffc02000b2 <cprintf>

ffffffffc0200642 <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
ffffffffc0200642:	1141                	addi	sp,sp,-16
ffffffffc0200644:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200646:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
ffffffffc0200648:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc020064a:	00001517          	auipc	a0,0x1
ffffffffc020064e:	5a650513          	addi	a0,a0,1446 # ffffffffc0201bf0 <commands+0x388>
void print_trapframe(struct trapframe *tf) {
ffffffffc0200652:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200654:	a5fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200658:	8522                	mv	a0,s0
ffffffffc020065a:	e1dff0ef          	jal	ra,ffffffffc0200476 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc020065e:	10043583          	ld	a1,256(s0)
ffffffffc0200662:	00001517          	auipc	a0,0x1
ffffffffc0200666:	5a650513          	addi	a0,a0,1446 # ffffffffc0201c08 <commands+0x3a0>
ffffffffc020066a:	a49ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc020066e:	10843583          	ld	a1,264(s0)
ffffffffc0200672:	00001517          	auipc	a0,0x1
ffffffffc0200676:	5ae50513          	addi	a0,a0,1454 # ffffffffc0201c20 <commands+0x3b8>
ffffffffc020067a:	a39ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc020067e:	11043583          	ld	a1,272(s0)
ffffffffc0200682:	00001517          	auipc	a0,0x1
ffffffffc0200686:	5b650513          	addi	a0,a0,1462 # ffffffffc0201c38 <commands+0x3d0>
ffffffffc020068a:	a29ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020068e:	11843583          	ld	a1,280(s0)
}
ffffffffc0200692:	6402                	ld	s0,0(sp)
ffffffffc0200694:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200696:	00001517          	auipc	a0,0x1
ffffffffc020069a:	5ba50513          	addi	a0,a0,1466 # ffffffffc0201c50 <commands+0x3e8>
}
ffffffffc020069e:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02006a0:	bc09                	j	ffffffffc02000b2 <cprintf>

ffffffffc02006a2 <interrupt_handler>:

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc02006a2:	11853783          	ld	a5,280(a0)
ffffffffc02006a6:	472d                	li	a4,11
ffffffffc02006a8:	0786                	slli	a5,a5,0x1
ffffffffc02006aa:	8385                	srli	a5,a5,0x1
ffffffffc02006ac:	06f76c63          	bltu	a4,a5,ffffffffc0200724 <interrupt_handler+0x82>
ffffffffc02006b0:	00001717          	auipc	a4,0x1
ffffffffc02006b4:	68070713          	addi	a4,a4,1664 # ffffffffc0201d30 <commands+0x4c8>
ffffffffc02006b8:	078a                	slli	a5,a5,0x2
ffffffffc02006ba:	97ba                	add	a5,a5,a4
ffffffffc02006bc:	439c                	lw	a5,0(a5)
ffffffffc02006be:	97ba                	add	a5,a5,a4
ffffffffc02006c0:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02006c2:	00001517          	auipc	a0,0x1
ffffffffc02006c6:	60650513          	addi	a0,a0,1542 # ffffffffc0201cc8 <commands+0x460>
ffffffffc02006ca:	b2e5                	j	ffffffffc02000b2 <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02006cc:	00001517          	auipc	a0,0x1
ffffffffc02006d0:	5dc50513          	addi	a0,a0,1500 # ffffffffc0201ca8 <commands+0x440>
ffffffffc02006d4:	baf9                	j	ffffffffc02000b2 <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02006d6:	00001517          	auipc	a0,0x1
ffffffffc02006da:	59250513          	addi	a0,a0,1426 # ffffffffc0201c68 <commands+0x400>
ffffffffc02006de:	bad1                	j	ffffffffc02000b2 <cprintf>
            break;
        case IRQ_U_TIMER:
            cprintf("User Timer interrupt\n");
ffffffffc02006e0:	00001517          	auipc	a0,0x1
ffffffffc02006e4:	60850513          	addi	a0,a0,1544 # ffffffffc0201ce8 <commands+0x480>
ffffffffc02006e8:	b2e9                	j	ffffffffc02000b2 <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc02006ea:	1141                	addi	sp,sp,-16
ffffffffc02006ec:	e406                	sd	ra,8(sp)
            // read-only." -- privileged spec1.9.1, 4.1.4, p59
            // In fact, Call sbi_set_timer will clear STIP, or you can clear it
            // directly.
            // cprintf("Supervisor timer interrupt\n");
            // clear_csr(sip, SIP_STIP);
            clock_set_next_event();
ffffffffc02006ee:	d4dff0ef          	jal	ra,ffffffffc020043a <clock_set_next_event>
            if (++ticks % TICK_NUM == 0) {
ffffffffc02006f2:	00006697          	auipc	a3,0x6
ffffffffc02006f6:	d5668693          	addi	a3,a3,-682 # ffffffffc0206448 <ticks>
ffffffffc02006fa:	629c                	ld	a5,0(a3)
ffffffffc02006fc:	06400713          	li	a4,100
ffffffffc0200700:	0785                	addi	a5,a5,1
ffffffffc0200702:	02e7f733          	remu	a4,a5,a4
ffffffffc0200706:	e29c                	sd	a5,0(a3)
ffffffffc0200708:	cf19                	beqz	a4,ffffffffc0200726 <interrupt_handler+0x84>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc020070a:	60a2                	ld	ra,8(sp)
ffffffffc020070c:	0141                	addi	sp,sp,16
ffffffffc020070e:	8082                	ret
            cprintf("Supervisor external interrupt\n");
ffffffffc0200710:	00001517          	auipc	a0,0x1
ffffffffc0200714:	60050513          	addi	a0,a0,1536 # ffffffffc0201d10 <commands+0x4a8>
ffffffffc0200718:	ba69                	j	ffffffffc02000b2 <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc020071a:	00001517          	auipc	a0,0x1
ffffffffc020071e:	56e50513          	addi	a0,a0,1390 # ffffffffc0201c88 <commands+0x420>
ffffffffc0200722:	ba41                	j	ffffffffc02000b2 <cprintf>
            print_trapframe(tf);
ffffffffc0200724:	bf39                	j	ffffffffc0200642 <print_trapframe>
}
ffffffffc0200726:	60a2                	ld	ra,8(sp)
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200728:	06400593          	li	a1,100
ffffffffc020072c:	00001517          	auipc	a0,0x1
ffffffffc0200730:	5d450513          	addi	a0,a0,1492 # ffffffffc0201d00 <commands+0x498>
}
ffffffffc0200734:	0141                	addi	sp,sp,16
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200736:	bab5                	j	ffffffffc02000b2 <cprintf>

ffffffffc0200738 <trap>:
            break;
    }
}

static inline void trap_dispatch(struct trapframe *tf) {
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200738:	11853783          	ld	a5,280(a0)
ffffffffc020073c:	0007c763          	bltz	a5,ffffffffc020074a <trap+0x12>
    switch (tf->cause) {
ffffffffc0200740:	472d                	li	a4,11
ffffffffc0200742:	00f76363          	bltu	a4,a5,ffffffffc0200748 <trap+0x10>
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf) {
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
}
ffffffffc0200746:	8082                	ret
            print_trapframe(tf);
ffffffffc0200748:	bded                	j	ffffffffc0200642 <print_trapframe>
        interrupt_handler(tf);
ffffffffc020074a:	bfa1                	j	ffffffffc02006a2 <interrupt_handler>

ffffffffc020074c <__alltraps>:
    .endm

    .globl __alltraps
    .align(2)
__alltraps:
    SAVE_ALL
ffffffffc020074c:	14011073          	csrw	sscratch,sp
ffffffffc0200750:	712d                	addi	sp,sp,-288
ffffffffc0200752:	e002                	sd	zero,0(sp)
ffffffffc0200754:	e406                	sd	ra,8(sp)
ffffffffc0200756:	ec0e                	sd	gp,24(sp)
ffffffffc0200758:	f012                	sd	tp,32(sp)
ffffffffc020075a:	f416                	sd	t0,40(sp)
ffffffffc020075c:	f81a                	sd	t1,48(sp)
ffffffffc020075e:	fc1e                	sd	t2,56(sp)
ffffffffc0200760:	e0a2                	sd	s0,64(sp)
ffffffffc0200762:	e4a6                	sd	s1,72(sp)
ffffffffc0200764:	e8aa                	sd	a0,80(sp)
ffffffffc0200766:	ecae                	sd	a1,88(sp)
ffffffffc0200768:	f0b2                	sd	a2,96(sp)
ffffffffc020076a:	f4b6                	sd	a3,104(sp)
ffffffffc020076c:	f8ba                	sd	a4,112(sp)
ffffffffc020076e:	fcbe                	sd	a5,120(sp)
ffffffffc0200770:	e142                	sd	a6,128(sp)
ffffffffc0200772:	e546                	sd	a7,136(sp)
ffffffffc0200774:	e94a                	sd	s2,144(sp)
ffffffffc0200776:	ed4e                	sd	s3,152(sp)
ffffffffc0200778:	f152                	sd	s4,160(sp)
ffffffffc020077a:	f556                	sd	s5,168(sp)
ffffffffc020077c:	f95a                	sd	s6,176(sp)
ffffffffc020077e:	fd5e                	sd	s7,184(sp)
ffffffffc0200780:	e1e2                	sd	s8,192(sp)
ffffffffc0200782:	e5e6                	sd	s9,200(sp)
ffffffffc0200784:	e9ea                	sd	s10,208(sp)
ffffffffc0200786:	edee                	sd	s11,216(sp)
ffffffffc0200788:	f1f2                	sd	t3,224(sp)
ffffffffc020078a:	f5f6                	sd	t4,232(sp)
ffffffffc020078c:	f9fa                	sd	t5,240(sp)
ffffffffc020078e:	fdfe                	sd	t6,248(sp)
ffffffffc0200790:	14001473          	csrrw	s0,sscratch,zero
ffffffffc0200794:	100024f3          	csrr	s1,sstatus
ffffffffc0200798:	14102973          	csrr	s2,sepc
ffffffffc020079c:	143029f3          	csrr	s3,stval
ffffffffc02007a0:	14202a73          	csrr	s4,scause
ffffffffc02007a4:	e822                	sd	s0,16(sp)
ffffffffc02007a6:	e226                	sd	s1,256(sp)
ffffffffc02007a8:	e64a                	sd	s2,264(sp)
ffffffffc02007aa:	ea4e                	sd	s3,272(sp)
ffffffffc02007ac:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc02007ae:	850a                	mv	a0,sp
    jal trap
ffffffffc02007b0:	f89ff0ef          	jal	ra,ffffffffc0200738 <trap>

ffffffffc02007b4 <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc02007b4:	6492                	ld	s1,256(sp)
ffffffffc02007b6:	6932                	ld	s2,264(sp)
ffffffffc02007b8:	10049073          	csrw	sstatus,s1
ffffffffc02007bc:	14191073          	csrw	sepc,s2
ffffffffc02007c0:	60a2                	ld	ra,8(sp)
ffffffffc02007c2:	61e2                	ld	gp,24(sp)
ffffffffc02007c4:	7202                	ld	tp,32(sp)
ffffffffc02007c6:	72a2                	ld	t0,40(sp)
ffffffffc02007c8:	7342                	ld	t1,48(sp)
ffffffffc02007ca:	73e2                	ld	t2,56(sp)
ffffffffc02007cc:	6406                	ld	s0,64(sp)
ffffffffc02007ce:	64a6                	ld	s1,72(sp)
ffffffffc02007d0:	6546                	ld	a0,80(sp)
ffffffffc02007d2:	65e6                	ld	a1,88(sp)
ffffffffc02007d4:	7606                	ld	a2,96(sp)
ffffffffc02007d6:	76a6                	ld	a3,104(sp)
ffffffffc02007d8:	7746                	ld	a4,112(sp)
ffffffffc02007da:	77e6                	ld	a5,120(sp)
ffffffffc02007dc:	680a                	ld	a6,128(sp)
ffffffffc02007de:	68aa                	ld	a7,136(sp)
ffffffffc02007e0:	694a                	ld	s2,144(sp)
ffffffffc02007e2:	69ea                	ld	s3,152(sp)
ffffffffc02007e4:	7a0a                	ld	s4,160(sp)
ffffffffc02007e6:	7aaa                	ld	s5,168(sp)
ffffffffc02007e8:	7b4a                	ld	s6,176(sp)
ffffffffc02007ea:	7bea                	ld	s7,184(sp)
ffffffffc02007ec:	6c0e                	ld	s8,192(sp)
ffffffffc02007ee:	6cae                	ld	s9,200(sp)
ffffffffc02007f0:	6d4e                	ld	s10,208(sp)
ffffffffc02007f2:	6dee                	ld	s11,216(sp)
ffffffffc02007f4:	7e0e                	ld	t3,224(sp)
ffffffffc02007f6:	7eae                	ld	t4,232(sp)
ffffffffc02007f8:	7f4e                	ld	t5,240(sp)
ffffffffc02007fa:	7fee                	ld	t6,248(sp)
ffffffffc02007fc:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
ffffffffc02007fe:	10200073          	sret

ffffffffc0200802 <pmm_init>:
// init_pmm_manager - initialize a pmm_manager instance
static void init_pmm_manager(void)
{
    // pmm_manager = &best_fit_pmm_manager;
    // pmm_manager = &default_pmm_manager;
    pmm_manager = &slub_pmm_manager;
ffffffffc0200802:	00002797          	auipc	a5,0x2
ffffffffc0200806:	92678793          	addi	a5,a5,-1754 # ffffffffc0202128 <slub_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc020080a:	638c                	ld	a1,0(a5)
    }
}

/* pmm_init - initialize the physical memory management */
void pmm_init(void)
{
ffffffffc020080c:	1101                	addi	sp,sp,-32
ffffffffc020080e:	e426                	sd	s1,8(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200810:	00001517          	auipc	a0,0x1
ffffffffc0200814:	55050513          	addi	a0,a0,1360 # ffffffffc0201d60 <commands+0x4f8>
    pmm_manager = &slub_pmm_manager;
ffffffffc0200818:	00006497          	auipc	s1,0x6
ffffffffc020081c:	c4848493          	addi	s1,s1,-952 # ffffffffc0206460 <pmm_manager>
{
ffffffffc0200820:	ec06                	sd	ra,24(sp)
ffffffffc0200822:	e822                	sd	s0,16(sp)
    pmm_manager = &slub_pmm_manager;
ffffffffc0200824:	e09c                	sd	a5,0(s1)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200826:	88dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    pmm_manager->init();
ffffffffc020082a:	609c                	ld	a5,0(s1)
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc020082c:	00006417          	auipc	s0,0x6
ffffffffc0200830:	c4c40413          	addi	s0,s0,-948 # ffffffffc0206478 <va_pa_offset>
    pmm_manager->init();
ffffffffc0200834:	679c                	ld	a5,8(a5)
ffffffffc0200836:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0200838:	57f5                	li	a5,-3
ffffffffc020083a:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc020083c:	00001517          	auipc	a0,0x1
ffffffffc0200840:	53c50513          	addi	a0,a0,1340 # ffffffffc0201d78 <commands+0x510>
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0200844:	e01c                	sd	a5,0(s0)
    cprintf("physcial memory map:\n");
ffffffffc0200846:	86dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size, mem_begin,
ffffffffc020084a:	46c5                	li	a3,17
ffffffffc020084c:	06ee                	slli	a3,a3,0x1b
ffffffffc020084e:	40100613          	li	a2,1025
ffffffffc0200852:	16fd                	addi	a3,a3,-1
ffffffffc0200854:	07e005b7          	lui	a1,0x7e00
ffffffffc0200858:	0656                	slli	a2,a2,0x15
ffffffffc020085a:	00001517          	auipc	a0,0x1
ffffffffc020085e:	53650513          	addi	a0,a0,1334 # ffffffffc0201d90 <commands+0x528>
ffffffffc0200862:	851ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0200866:	777d                	lui	a4,0xfffff
ffffffffc0200868:	00007797          	auipc	a5,0x7
ffffffffc020086c:	c1f78793          	addi	a5,a5,-993 # ffffffffc0207487 <end+0xfff>
ffffffffc0200870:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc0200872:	00006517          	auipc	a0,0x6
ffffffffc0200876:	bde50513          	addi	a0,a0,-1058 # ffffffffc0206450 <npage>
ffffffffc020087a:	00088737          	lui	a4,0x88
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc020087e:	00006597          	auipc	a1,0x6
ffffffffc0200882:	bda58593          	addi	a1,a1,-1062 # ffffffffc0206458 <pages>
    npage = maxpa / PGSIZE;
ffffffffc0200886:	e118                	sd	a4,0(a0)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0200888:	e19c                	sd	a5,0(a1)
ffffffffc020088a:	4681                	li	a3,0
    for (size_t i = 0; i < npage - nbase; i++)
ffffffffc020088c:	4701                	li	a4,0
 *
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void set_bit(int nr, volatile void *addr) {
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020088e:	4885                	li	a7,1
ffffffffc0200890:	fff80837          	lui	a6,0xfff80
ffffffffc0200894:	a011                	j	ffffffffc0200898 <pmm_init+0x96>
        SetPageReserved(pages + i);
ffffffffc0200896:	619c                	ld	a5,0(a1)
ffffffffc0200898:	97b6                	add	a5,a5,a3
ffffffffc020089a:	07a1                	addi	a5,a5,8
ffffffffc020089c:	4117b02f          	amoor.d	zero,a7,(a5)
    for (size_t i = 0; i < npage - nbase; i++)
ffffffffc02008a0:	611c                	ld	a5,0(a0)
ffffffffc02008a2:	0705                	addi	a4,a4,1
ffffffffc02008a4:	02868693          	addi	a3,a3,40
ffffffffc02008a8:	01078633          	add	a2,a5,a6
ffffffffc02008ac:	fec765e3          	bltu	a4,a2,ffffffffc0200896 <pmm_init+0x94>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02008b0:	6190                	ld	a2,0(a1)
ffffffffc02008b2:	00279713          	slli	a4,a5,0x2
ffffffffc02008b6:	973e                	add	a4,a4,a5
ffffffffc02008b8:	fec006b7          	lui	a3,0xfec00
ffffffffc02008bc:	070e                	slli	a4,a4,0x3
ffffffffc02008be:	96b2                	add	a3,a3,a2
ffffffffc02008c0:	96ba                	add	a3,a3,a4
ffffffffc02008c2:	c0200737          	lui	a4,0xc0200
ffffffffc02008c6:	08e6ef63          	bltu	a3,a4,ffffffffc0200964 <pmm_init+0x162>
ffffffffc02008ca:	6018                	ld	a4,0(s0)
    if (freemem < mem_end)
ffffffffc02008cc:	45c5                	li	a1,17
ffffffffc02008ce:	05ee                	slli	a1,a1,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02008d0:	8e99                	sub	a3,a3,a4
    if (freemem < mem_end)
ffffffffc02008d2:	04b6e863          	bltu	a3,a1,ffffffffc0200922 <pmm_init+0x120>
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
}

static void check_alloc_page(void)
{
    pmm_manager->check();
ffffffffc02008d6:	609c                	ld	a5,0(s1)
ffffffffc02008d8:	7b9c                	ld	a5,48(a5)
ffffffffc02008da:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc02008dc:	00001517          	auipc	a0,0x1
ffffffffc02008e0:	54c50513          	addi	a0,a0,1356 # ffffffffc0201e28 <commands+0x5c0>
ffffffffc02008e4:	fceff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    satp_virtual = (pte_t *)boot_page_table_sv39;
ffffffffc02008e8:	00004597          	auipc	a1,0x4
ffffffffc02008ec:	71858593          	addi	a1,a1,1816 # ffffffffc0205000 <boot_page_table_sv39>
ffffffffc02008f0:	00006797          	auipc	a5,0x6
ffffffffc02008f4:	b8b7b023          	sd	a1,-1152(a5) # ffffffffc0206470 <satp_virtual>
    satp_physical = PADDR(satp_virtual);
ffffffffc02008f8:	c02007b7          	lui	a5,0xc0200
ffffffffc02008fc:	08f5e063          	bltu	a1,a5,ffffffffc020097c <pmm_init+0x17a>
ffffffffc0200900:	6010                	ld	a2,0(s0)
}
ffffffffc0200902:	6442                	ld	s0,16(sp)
ffffffffc0200904:	60e2                	ld	ra,24(sp)
ffffffffc0200906:	64a2                	ld	s1,8(sp)
    satp_physical = PADDR(satp_virtual);
ffffffffc0200908:	40c58633          	sub	a2,a1,a2
ffffffffc020090c:	00006797          	auipc	a5,0x6
ffffffffc0200910:	b4c7be23          	sd	a2,-1188(a5) # ffffffffc0206468 <satp_physical>
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0200914:	00001517          	auipc	a0,0x1
ffffffffc0200918:	53450513          	addi	a0,a0,1332 # ffffffffc0201e48 <commands+0x5e0>
}
ffffffffc020091c:	6105                	addi	sp,sp,32
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc020091e:	f94ff06f          	j	ffffffffc02000b2 <cprintf>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc0200922:	6705                	lui	a4,0x1
ffffffffc0200924:	177d                	addi	a4,a4,-1
ffffffffc0200926:	96ba                	add	a3,a3,a4
ffffffffc0200928:	777d                	lui	a4,0xfffff
ffffffffc020092a:	8ef9                	and	a3,a3,a4
    page->ref -= 1;
    return page->ref;
}
// pa2page - 地址转换函数，将一个物理地址转换为对应的Page结构体指针。
static inline struct Page *pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
ffffffffc020092c:	00c6d513          	srli	a0,a3,0xc
ffffffffc0200930:	00f57e63          	bgeu	a0,a5,ffffffffc020094c <pmm_init+0x14a>
    pmm_manager->init_memmap(base, n);
ffffffffc0200934:	609c                	ld	a5,0(s1)
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
ffffffffc0200936:	982a                	add	a6,a6,a0
ffffffffc0200938:	00281513          	slli	a0,a6,0x2
ffffffffc020093c:	9542                	add	a0,a0,a6
ffffffffc020093e:	6b9c                	ld	a5,16(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0200940:	8d95                	sub	a1,a1,a3
ffffffffc0200942:	050e                	slli	a0,a0,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc0200944:	81b1                	srli	a1,a1,0xc
ffffffffc0200946:	9532                	add	a0,a0,a2
ffffffffc0200948:	9782                	jalr	a5
}
ffffffffc020094a:	b771                	j	ffffffffc02008d6 <pmm_init+0xd4>
        panic("pa2page called with invalid pa");
ffffffffc020094c:	00001617          	auipc	a2,0x1
ffffffffc0200950:	4ac60613          	addi	a2,a2,1196 # ffffffffc0201df8 <commands+0x590>
ffffffffc0200954:	07500593          	li	a1,117
ffffffffc0200958:	00001517          	auipc	a0,0x1
ffffffffc020095c:	4c050513          	addi	a0,a0,1216 # ffffffffc0201e18 <commands+0x5b0>
ffffffffc0200960:	a4dff0ef          	jal	ra,ffffffffc02003ac <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0200964:	00001617          	auipc	a2,0x1
ffffffffc0200968:	45c60613          	addi	a2,a2,1116 # ffffffffc0201dc0 <commands+0x558>
ffffffffc020096c:	07800593          	li	a1,120
ffffffffc0200970:	00001517          	auipc	a0,0x1
ffffffffc0200974:	47850513          	addi	a0,a0,1144 # ffffffffc0201de8 <commands+0x580>
ffffffffc0200978:	a35ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    satp_physical = PADDR(satp_virtual);
ffffffffc020097c:	86ae                	mv	a3,a1
ffffffffc020097e:	00001617          	auipc	a2,0x1
ffffffffc0200982:	44260613          	addi	a2,a2,1090 # ffffffffc0201dc0 <commands+0x558>
ffffffffc0200986:	09500593          	li	a1,149
ffffffffc020098a:	00001517          	auipc	a0,0x1
ffffffffc020098e:	45e50513          	addi	a0,a0,1118 # ffffffffc0201de8 <commands+0x580>
ffffffffc0200992:	a1bff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200996 <slub_init>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200996:	00005797          	auipc	a5,0x5
ffffffffc020099a:	67a78793          	addi	a5,a5,1658 # ffffffffc0206010 <free_area_slub>
    //     slub_block[i].page = NULL;
    //     slub_block[i].next = &slub_block[i];
    //     slubfree[i]=&slub_block[i];
    // }
    slub_small_block_list = NULL;
    slub_block.size = 0;
ffffffffc020099e:	00005717          	auipc	a4,0x5
ffffffffc02009a2:	68a70713          	addi	a4,a4,1674 # ffffffffc0206028 <slub_block>
ffffffffc02009a6:	e79c                	sd	a5,8(a5)
ffffffffc02009a8:	e39c                	sd	a5,0(a5)
    nr_free = 0;
ffffffffc02009aa:	0007a823          	sw	zero,16(a5)
    slub_block.size = 0;
ffffffffc02009ae:	00073023          	sd	zero,0(a4)
    slub_block.page = NULL;
ffffffffc02009b2:	00073423          	sd	zero,8(a4)
    slub_block.next = &slub_block;
ffffffffc02009b6:	eb18                	sd	a4,16(a4)
}
ffffffffc02009b8:	8082                	ret

ffffffffc02009ba <slub_nr_free_pages>:

static size_t
slub_nr_free_pages(void)
{
    return nr_free;
}
ffffffffc02009ba:	00005517          	auipc	a0,0x5
ffffffffc02009be:	66656503          	lwu	a0,1638(a0) # ffffffffc0206020 <free_area_slub+0x10>
ffffffffc02009c2:	8082                	ret

ffffffffc02009c4 <slub_alloc_pages>:
    assert(n > 0);
ffffffffc02009c4:	c14d                	beqz	a0,ffffffffc0200a66 <slub_alloc_pages+0xa2>
    if (n > nr_free)
ffffffffc02009c6:	00005617          	auipc	a2,0x5
ffffffffc02009ca:	64a60613          	addi	a2,a2,1610 # ffffffffc0206010 <free_area_slub>
ffffffffc02009ce:	01062803          	lw	a6,16(a2)
ffffffffc02009d2:	86aa                	mv	a3,a0
ffffffffc02009d4:	02081793          	slli	a5,a6,0x20
ffffffffc02009d8:	9381                	srli	a5,a5,0x20
ffffffffc02009da:	08a7e463          	bltu	a5,a0,ffffffffc0200a62 <slub_alloc_pages+0x9e>
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc02009de:	661c                	ld	a5,8(a2)
    size_t min_size = nr_free + 1;
ffffffffc02009e0:	0018059b          	addiw	a1,a6,1
ffffffffc02009e4:	1582                	slli	a1,a1,0x20
ffffffffc02009e6:	9181                	srli	a1,a1,0x20
    struct Page *page = NULL;
ffffffffc02009e8:	4501                	li	a0,0
    while ((le = list_next(le)) != &free_list)
ffffffffc02009ea:	06c78b63          	beq	a5,a2,ffffffffc0200a60 <slub_alloc_pages+0x9c>
        if (p->property >= n && p->property < min_size)
ffffffffc02009ee:	ff87e703          	lwu	a4,-8(a5)
ffffffffc02009f2:	00d76763          	bltu	a4,a3,ffffffffc0200a00 <slub_alloc_pages+0x3c>
ffffffffc02009f6:	00b77563          	bgeu	a4,a1,ffffffffc0200a00 <slub_alloc_pages+0x3c>
        struct Page *p = le2page(le, page_link);
ffffffffc02009fa:	fe878513          	addi	a0,a5,-24
ffffffffc02009fe:	85ba                	mv	a1,a4
ffffffffc0200a00:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list)
ffffffffc0200a02:	fec796e3          	bne	a5,a2,ffffffffc02009ee <slub_alloc_pages+0x2a>
    if (page != NULL)
ffffffffc0200a06:	cd29                	beqz	a0,ffffffffc0200a60 <slub_alloc_pages+0x9c>
    __list_del(listelm->prev, listelm->next);
ffffffffc0200a08:	711c                	ld	a5,32(a0)
 * list_prev - get the previous entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_prev(list_entry_t *listelm) {
    return listelm->prev;
ffffffffc0200a0a:	6d18                	ld	a4,24(a0)
        if (page->property > n)
ffffffffc0200a0c:	490c                	lw	a1,16(a0)
            p->property = page->property - n;
ffffffffc0200a0e:	0006889b          	sext.w	a7,a3
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc0200a12:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0200a14:	e398                	sd	a4,0(a5)
        if (page->property > n)
ffffffffc0200a16:	02059793          	slli	a5,a1,0x20
ffffffffc0200a1a:	9381                	srli	a5,a5,0x20
ffffffffc0200a1c:	02f6f863          	bgeu	a3,a5,ffffffffc0200a4c <slub_alloc_pages+0x88>
            struct Page *p = page + n;
ffffffffc0200a20:	00269793          	slli	a5,a3,0x2
ffffffffc0200a24:	97b6                	add	a5,a5,a3
ffffffffc0200a26:	078e                	slli	a5,a5,0x3
ffffffffc0200a28:	97aa                	add	a5,a5,a0
            p->property = page->property - n;
ffffffffc0200a2a:	411585bb          	subw	a1,a1,a7
ffffffffc0200a2e:	cb8c                	sw	a1,16(a5)
ffffffffc0200a30:	4689                	li	a3,2
ffffffffc0200a32:	00878593          	addi	a1,a5,8
ffffffffc0200a36:	40d5b02f          	amoor.d	zero,a3,(a1)
    __list_add(elm, listelm, listelm->next);
ffffffffc0200a3a:	6714                	ld	a3,8(a4)
            list_add(prev, &(p->page_link));
ffffffffc0200a3c:	01878593          	addi	a1,a5,24
        nr_free -= n;
ffffffffc0200a40:	01062803          	lw	a6,16(a2)
    prev->next = next->prev = elm;
ffffffffc0200a44:	e28c                	sd	a1,0(a3)
ffffffffc0200a46:	e70c                	sd	a1,8(a4)
    elm->next = next;
ffffffffc0200a48:	f394                	sd	a3,32(a5)
    elm->prev = prev;
ffffffffc0200a4a:	ef98                	sd	a4,24(a5)
ffffffffc0200a4c:	4118083b          	subw	a6,a6,a7
ffffffffc0200a50:	01062823          	sw	a6,16(a2)
 * clear_bit - Atomically clears a bit in memory
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void clear_bit(int nr, volatile void *addr) {
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0200a54:	57f5                	li	a5,-3
ffffffffc0200a56:	00850713          	addi	a4,a0,8
ffffffffc0200a5a:	60f7302f          	amoand.d	zero,a5,(a4)
}
ffffffffc0200a5e:	8082                	ret
}
ffffffffc0200a60:	8082                	ret
        return NULL;
ffffffffc0200a62:	4501                	li	a0,0
ffffffffc0200a64:	8082                	ret
{
ffffffffc0200a66:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc0200a68:	00001697          	auipc	a3,0x1
ffffffffc0200a6c:	42068693          	addi	a3,a3,1056 # ffffffffc0201e88 <commands+0x620>
ffffffffc0200a70:	00001617          	auipc	a2,0x1
ffffffffc0200a74:	42060613          	addi	a2,a2,1056 # ffffffffc0201e90 <commands+0x628>
ffffffffc0200a78:	05400593          	li	a1,84
ffffffffc0200a7c:	00001517          	auipc	a0,0x1
ffffffffc0200a80:	42c50513          	addi	a0,a0,1068 # ffffffffc0201ea8 <commands+0x640>
{
ffffffffc0200a84:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0200a86:	927ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200a8a <slub_free_pages.part.0>:
    for (; p != base + n; p++)
ffffffffc0200a8a:	00259793          	slli	a5,a1,0x2
ffffffffc0200a8e:	97ae                	add	a5,a5,a1
ffffffffc0200a90:	078e                	slli	a5,a5,0x3
ffffffffc0200a92:	00f506b3          	add	a3,a0,a5
ffffffffc0200a96:	87aa                	mv	a5,a0
ffffffffc0200a98:	02d50263          	beq	a0,a3,ffffffffc0200abc <slub_free_pages.part.0+0x32>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200a9c:	6798                	ld	a4,8(a5)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0200a9e:	8b05                	andi	a4,a4,1
ffffffffc0200aa0:	10071863          	bnez	a4,ffffffffc0200bb0 <slub_free_pages.part.0+0x126>
ffffffffc0200aa4:	6798                	ld	a4,8(a5)
ffffffffc0200aa6:	8b09                	andi	a4,a4,2
ffffffffc0200aa8:	10071463          	bnez	a4,ffffffffc0200bb0 <slub_free_pages.part.0+0x126>
        p->flags = 0;
ffffffffc0200aac:	0007b423          	sd	zero,8(a5)
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0200ab0:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p++)
ffffffffc0200ab4:	02878793          	addi	a5,a5,40
ffffffffc0200ab8:	fed792e3          	bne	a5,a3,ffffffffc0200a9c <slub_free_pages.part.0+0x12>
    base->property = n;
ffffffffc0200abc:	2581                	sext.w	a1,a1
ffffffffc0200abe:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);
ffffffffc0200ac0:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0200ac4:	4789                	li	a5,2
ffffffffc0200ac6:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc0200aca:	00005697          	auipc	a3,0x5
ffffffffc0200ace:	54668693          	addi	a3,a3,1350 # ffffffffc0206010 <free_area_slub>
ffffffffc0200ad2:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0200ad4:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc0200ad6:	01850613          	addi	a2,a0,24
    nr_free += n;
ffffffffc0200ada:	9db9                	addw	a1,a1,a4
ffffffffc0200adc:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list))
ffffffffc0200ade:	0cd78463          	beq	a5,a3,ffffffffc0200ba6 <slub_free_pages.part.0+0x11c>
            struct Page *page = le2page(le, page_link);
ffffffffc0200ae2:	fe878713          	addi	a4,a5,-24
ffffffffc0200ae6:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list))
ffffffffc0200aea:	4581                	li	a1,0
            if (base < page)
ffffffffc0200aec:	00e56a63          	bltu	a0,a4,ffffffffc0200b00 <slub_free_pages.part.0+0x76>
    return listelm->next;
ffffffffc0200af0:	6798                	ld	a4,8(a5)
            else if (list_next(le) == &free_list)
ffffffffc0200af2:	06d70063          	beq	a4,a3,ffffffffc0200b52 <slub_free_pages.part.0+0xc8>
    for (; p != base + n; p++)
ffffffffc0200af6:	87ba                	mv	a5,a4
            struct Page *page = le2page(le, page_link);
ffffffffc0200af8:	fe878713          	addi	a4,a5,-24
            if (base < page)
ffffffffc0200afc:	fee57ae3          	bgeu	a0,a4,ffffffffc0200af0 <slub_free_pages.part.0+0x66>
ffffffffc0200b00:	c199                	beqz	a1,ffffffffc0200b06 <slub_free_pages.part.0+0x7c>
ffffffffc0200b02:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc0200b06:	6398                	ld	a4,0(a5)
    prev->next = next->prev = elm;
ffffffffc0200b08:	e390                	sd	a2,0(a5)
ffffffffc0200b0a:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc0200b0c:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0200b0e:	ed18                	sd	a4,24(a0)
    if (le != &free_list)
ffffffffc0200b10:	02d70063          	beq	a4,a3,ffffffffc0200b30 <slub_free_pages.part.0+0xa6>
        if (p + p->property == base)
ffffffffc0200b14:	ff872803          	lw	a6,-8(a4)
        p = le2page(le, page_link);
ffffffffc0200b18:	fe870593          	addi	a1,a4,-24
        if (p + p->property == base)
ffffffffc0200b1c:	02081613          	slli	a2,a6,0x20
ffffffffc0200b20:	9201                	srli	a2,a2,0x20
ffffffffc0200b22:	00261793          	slli	a5,a2,0x2
ffffffffc0200b26:	97b2                	add	a5,a5,a2
ffffffffc0200b28:	078e                	slli	a5,a5,0x3
ffffffffc0200b2a:	97ae                	add	a5,a5,a1
ffffffffc0200b2c:	04f50b63          	beq	a0,a5,ffffffffc0200b82 <slub_free_pages.part.0+0xf8>
    return listelm->next;
ffffffffc0200b30:	7118                	ld	a4,32(a0)
    if (le != &free_list)
ffffffffc0200b32:	00d70f63          	beq	a4,a3,ffffffffc0200b50 <slub_free_pages.part.0+0xc6>
        if (base + base->property == p)
ffffffffc0200b36:	490c                	lw	a1,16(a0)
        p = le2page(le, page_link);
ffffffffc0200b38:	fe870693          	addi	a3,a4,-24
        if (base + base->property == p)
ffffffffc0200b3c:	02059613          	slli	a2,a1,0x20
ffffffffc0200b40:	9201                	srli	a2,a2,0x20
ffffffffc0200b42:	00261793          	slli	a5,a2,0x2
ffffffffc0200b46:	97b2                	add	a5,a5,a2
ffffffffc0200b48:	078e                	slli	a5,a5,0x3
ffffffffc0200b4a:	97aa                	add	a5,a5,a0
ffffffffc0200b4c:	00f68d63          	beq	a3,a5,ffffffffc0200b66 <slub_free_pages.part.0+0xdc>
ffffffffc0200b50:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0200b52:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0200b54:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc0200b56:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0200b58:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &free_list)
ffffffffc0200b5a:	04d70363          	beq	a4,a3,ffffffffc0200ba0 <slub_free_pages.part.0+0x116>
    prev->next = next->prev = elm;
ffffffffc0200b5e:	8832                	mv	a6,a2
ffffffffc0200b60:	4585                	li	a1,1
    for (; p != base + n; p++)
ffffffffc0200b62:	87ba                	mv	a5,a4
ffffffffc0200b64:	bf51                	j	ffffffffc0200af8 <slub_free_pages.part.0+0x6e>
            base->property += p->property;
ffffffffc0200b66:	ff872783          	lw	a5,-8(a4)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0200b6a:	ff070693          	addi	a3,a4,-16
ffffffffc0200b6e:	9dbd                	addw	a1,a1,a5
ffffffffc0200b70:	c90c                	sw	a1,16(a0)
ffffffffc0200b72:	57f5                	li	a5,-3
ffffffffc0200b74:	60f6b02f          	amoand.d	zero,a5,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc0200b78:	6314                	ld	a3,0(a4)
ffffffffc0200b7a:	671c                	ld	a5,8(a4)
    prev->next = next;
ffffffffc0200b7c:	e69c                	sd	a5,8(a3)
    next->prev = prev;
ffffffffc0200b7e:	e394                	sd	a3,0(a5)
ffffffffc0200b80:	8082                	ret
            p->property += base->property;
ffffffffc0200b82:	491c                	lw	a5,16(a0)
ffffffffc0200b84:	0107883b          	addw	a6,a5,a6
ffffffffc0200b88:	ff072c23          	sw	a6,-8(a4)
ffffffffc0200b8c:	57f5                	li	a5,-3
ffffffffc0200b8e:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc0200b92:	6d10                	ld	a2,24(a0)
ffffffffc0200b94:	711c                	ld	a5,32(a0)
            base = p;
ffffffffc0200b96:	852e                	mv	a0,a1
    prev->next = next;
ffffffffc0200b98:	e61c                	sd	a5,8(a2)
    return listelm->next;
ffffffffc0200b9a:	6718                	ld	a4,8(a4)
    next->prev = prev;
ffffffffc0200b9c:	e390                	sd	a2,0(a5)
ffffffffc0200b9e:	bf51                	j	ffffffffc0200b32 <slub_free_pages.part.0+0xa8>
ffffffffc0200ba0:	e290                	sd	a2,0(a3)
        while ((le = list_next(le)) != &free_list)
ffffffffc0200ba2:	873e                	mv	a4,a5
ffffffffc0200ba4:	bf85                	j	ffffffffc0200b14 <slub_free_pages.part.0+0x8a>
    prev->next = next->prev = elm;
ffffffffc0200ba6:	e390                	sd	a2,0(a5)
ffffffffc0200ba8:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0200baa:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0200bac:	ed1c                	sd	a5,24(a0)
    if (le != &free_list)
ffffffffc0200bae:	8082                	ret
slub_free_pages(struct Page *base, size_t n)
ffffffffc0200bb0:	1141                	addi	sp,sp,-16
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0200bb2:	00001697          	auipc	a3,0x1
ffffffffc0200bb6:	30e68693          	addi	a3,a3,782 # ffffffffc0201ec0 <commands+0x658>
ffffffffc0200bba:	00001617          	auipc	a2,0x1
ffffffffc0200bbe:	2d660613          	addi	a2,a2,726 # ffffffffc0201e90 <commands+0x628>
ffffffffc0200bc2:	07e00593          	li	a1,126
ffffffffc0200bc6:	00001517          	auipc	a0,0x1
ffffffffc0200bca:	2e250513          	addi	a0,a0,738 # ffffffffc0201ea8 <commands+0x640>
slub_free_pages(struct Page *base, size_t n)
ffffffffc0200bce:	e406                	sd	ra,8(sp)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0200bd0:	fdcff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200bd4 <slub_init_memmap>:
{
ffffffffc0200bd4:	1141                	addi	sp,sp,-16
ffffffffc0200bd6:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0200bd8:	c9e1                	beqz	a1,ffffffffc0200ca8 <slub_init_memmap+0xd4>
    for (; p != base + n; p++)
ffffffffc0200bda:	00259693          	slli	a3,a1,0x2
ffffffffc0200bde:	96ae                	add	a3,a3,a1
ffffffffc0200be0:	068e                	slli	a3,a3,0x3
ffffffffc0200be2:	96aa                	add	a3,a3,a0
ffffffffc0200be4:	87aa                	mv	a5,a0
ffffffffc0200be6:	00d50f63          	beq	a0,a3,ffffffffc0200c04 <slub_init_memmap+0x30>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200bea:	6798                	ld	a4,8(a5)
        assert(PageReserved(p));
ffffffffc0200bec:	8b05                	andi	a4,a4,1
ffffffffc0200bee:	cf49                	beqz	a4,ffffffffc0200c88 <slub_init_memmap+0xb4>
        p->flags = p->property = 0;
ffffffffc0200bf0:	0007a823          	sw	zero,16(a5)
ffffffffc0200bf4:	0007b423          	sd	zero,8(a5)
ffffffffc0200bf8:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p++)
ffffffffc0200bfc:	02878793          	addi	a5,a5,40
ffffffffc0200c00:	fed795e3          	bne	a5,a3,ffffffffc0200bea <slub_init_memmap+0x16>
    base->property = n;
ffffffffc0200c04:	2581                	sext.w	a1,a1
ffffffffc0200c06:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0200c08:	4789                	li	a5,2
ffffffffc0200c0a:	00850713          	addi	a4,a0,8
ffffffffc0200c0e:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc0200c12:	00005697          	auipc	a3,0x5
ffffffffc0200c16:	3fe68693          	addi	a3,a3,1022 # ffffffffc0206010 <free_area_slub>
ffffffffc0200c1a:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0200c1c:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc0200c1e:	01850613          	addi	a2,a0,24
    nr_free += n;
ffffffffc0200c22:	9db9                	addw	a1,a1,a4
ffffffffc0200c24:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list))
ffffffffc0200c26:	04d78a63          	beq	a5,a3,ffffffffc0200c7a <slub_init_memmap+0xa6>
            struct Page *page = le2page(le, page_link);
ffffffffc0200c2a:	fe878713          	addi	a4,a5,-24
ffffffffc0200c2e:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list))
ffffffffc0200c32:	4581                	li	a1,0
            if (base < page)
ffffffffc0200c34:	00e56a63          	bltu	a0,a4,ffffffffc0200c48 <slub_init_memmap+0x74>
    return listelm->next;
ffffffffc0200c38:	6798                	ld	a4,8(a5)
            else if (list_next(le) == &free_list)
ffffffffc0200c3a:	02d70263          	beq	a4,a3,ffffffffc0200c5e <slub_init_memmap+0x8a>
    for (; p != base + n; p++)
ffffffffc0200c3e:	87ba                	mv	a5,a4
            struct Page *page = le2page(le, page_link);
ffffffffc0200c40:	fe878713          	addi	a4,a5,-24
            if (base < page)
ffffffffc0200c44:	fee57ae3          	bgeu	a0,a4,ffffffffc0200c38 <slub_init_memmap+0x64>
ffffffffc0200c48:	c199                	beqz	a1,ffffffffc0200c4e <slub_init_memmap+0x7a>
ffffffffc0200c4a:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc0200c4e:	6398                	ld	a4,0(a5)
}
ffffffffc0200c50:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0200c52:	e390                	sd	a2,0(a5)
ffffffffc0200c54:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc0200c56:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0200c58:	ed18                	sd	a4,24(a0)
ffffffffc0200c5a:	0141                	addi	sp,sp,16
ffffffffc0200c5c:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0200c5e:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0200c60:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc0200c62:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0200c64:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &free_list)
ffffffffc0200c66:	00d70663          	beq	a4,a3,ffffffffc0200c72 <slub_init_memmap+0x9e>
    prev->next = next->prev = elm;
ffffffffc0200c6a:	8832                	mv	a6,a2
ffffffffc0200c6c:	4585                	li	a1,1
    for (; p != base + n; p++)
ffffffffc0200c6e:	87ba                	mv	a5,a4
ffffffffc0200c70:	bfc1                	j	ffffffffc0200c40 <slub_init_memmap+0x6c>
}
ffffffffc0200c72:	60a2                	ld	ra,8(sp)
ffffffffc0200c74:	e290                	sd	a2,0(a3)
ffffffffc0200c76:	0141                	addi	sp,sp,16
ffffffffc0200c78:	8082                	ret
ffffffffc0200c7a:	60a2                	ld	ra,8(sp)
ffffffffc0200c7c:	e390                	sd	a2,0(a5)
ffffffffc0200c7e:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0200c80:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0200c82:	ed1c                	sd	a5,24(a0)
ffffffffc0200c84:	0141                	addi	sp,sp,16
ffffffffc0200c86:	8082                	ret
        assert(PageReserved(p));
ffffffffc0200c88:	00001697          	auipc	a3,0x1
ffffffffc0200c8c:	26068693          	addi	a3,a3,608 # ffffffffc0201ee8 <commands+0x680>
ffffffffc0200c90:	00001617          	auipc	a2,0x1
ffffffffc0200c94:	20060613          	addi	a2,a2,512 # ffffffffc0201e90 <commands+0x628>
ffffffffc0200c98:	03300593          	li	a1,51
ffffffffc0200c9c:	00001517          	auipc	a0,0x1
ffffffffc0200ca0:	20c50513          	addi	a0,a0,524 # ffffffffc0201ea8 <commands+0x640>
ffffffffc0200ca4:	f08ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(n > 0);
ffffffffc0200ca8:	00001697          	auipc	a3,0x1
ffffffffc0200cac:	1e068693          	addi	a3,a3,480 # ffffffffc0201e88 <commands+0x620>
ffffffffc0200cb0:	00001617          	auipc	a2,0x1
ffffffffc0200cb4:	1e060613          	addi	a2,a2,480 # ffffffffc0201e90 <commands+0x628>
ffffffffc0200cb8:	02f00593          	li	a1,47
ffffffffc0200cbc:	00001517          	auipc	a0,0x1
ffffffffc0200cc0:	1ec50513          	addi	a0,a0,492 # ffffffffc0201ea8 <commands+0x640>
ffffffffc0200cc4:	ee8ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200cc8 <slub_free>:
    return NULL; // 分配失败
}

static void slub_free(struct Page *ptr, size_t size)
{
    size *= PGSIZE;
ffffffffc0200cc8:	00c59793          	slli	a5,a1,0xc
    if (size >= PGSIZE)
ffffffffc0200ccc:	6705                	lui	a4,0x1
ffffffffc0200cce:	00e7e863          	bltu	a5,a4,ffffffffc0200cde <slub_free+0x16>
    {
        slub_free_pages(ptr, (size + PGSIZE - 1) / PGSIZE); // 释放整页
ffffffffc0200cd2:	fff70593          	addi	a1,a4,-1 # fff <kern_entry-0xffffffffc01ff001>
ffffffffc0200cd6:	95be                	add	a1,a1,a5
ffffffffc0200cd8:	81b1                	srli	a1,a1,0xc
    assert(n > 0);
ffffffffc0200cda:	c5a9                	beqz	a1,ffffffffc0200d24 <slub_free+0x5c>
ffffffffc0200cdc:	b37d                	j	ffffffffc0200a8a <slub_free_pages.part.0>
ffffffffc0200cde:	88aa                	mv	a7,a0
    if (ptr == NULL)
ffffffffc0200ce0:	cd0d                	beqz	a0,ffffffffc0200d1a <slub_free+0x52>
    block->size += total_size;
ffffffffc0200ce2:	fe853683          	ld	a3,-24(a0)
    while (temp->next != &slub_block)
ffffffffc0200ce6:	00005817          	auipc	a6,0x5
ffffffffc0200cea:	34280813          	addi	a6,a6,834 # ffffffffc0206028 <slub_block>
    size_t total_size = size * PGSIZE;
ffffffffc0200cee:	05e2                	slli	a1,a1,0x18
    while (temp->next != &slub_block)
ffffffffc0200cf0:	01083783          	ld	a5,16(a6)
    block->size += total_size;
ffffffffc0200cf4:	96ae                	add	a3,a3,a1
ffffffffc0200cf6:	fed53423          	sd	a3,-24(a0)
    struct SlubBlock *block = (struct SlubBlock *)ptr - 1;
ffffffffc0200cfa:	fe850593          	addi	a1,a0,-24
    while (temp->next != &slub_block)
ffffffffc0200cfe:	01078e63          	beq	a5,a6,ffffffffc0200d1a <slub_free+0x52>
    struct SlubBlock *temp = &slub_block;
ffffffffc0200d02:	8642                	mv	a2,a6
ffffffffc0200d04:	a011                	j	ffffffffc0200d08 <slub_free+0x40>
ffffffffc0200d06:	87ba                	mv	a5,a4
        if (temp->size <= block->size)
ffffffffc0200d08:	6218                	ld	a4,0(a2)
ffffffffc0200d0a:	00e6e463          	bltu	a3,a4,ffffffffc0200d12 <slub_free+0x4a>
            if (next == &slub_block || next > block)
ffffffffc0200d0e:	00f5e763          	bltu	a1,a5,ffffffffc0200d1c <slub_free+0x54>
    while (temp->next != &slub_block)
ffffffffc0200d12:	6b98                	ld	a4,16(a5)
ffffffffc0200d14:	863e                	mv	a2,a5
ffffffffc0200d16:	ff0718e3          	bne	a4,a6,ffffffffc0200d06 <slub_free+0x3e>
ffffffffc0200d1a:	8082                	ret
                temp->next = block;
ffffffffc0200d1c:	ea0c                	sd	a1,16(a2)
                block->next = next;
ffffffffc0200d1e:	fef8bc23          	sd	a5,-8(a7)
                return;
ffffffffc0200d22:	8082                	ret
{
ffffffffc0200d24:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc0200d26:	00001697          	auipc	a3,0x1
ffffffffc0200d2a:	16268693          	addi	a3,a3,354 # ffffffffc0201e88 <commands+0x620>
ffffffffc0200d2e:	00001617          	auipc	a2,0x1
ffffffffc0200d32:	16260613          	addi	a2,a2,354 # ffffffffc0201e90 <commands+0x628>
ffffffffc0200d36:	07a00593          	li	a1,122
ffffffffc0200d3a:	00001517          	auipc	a0,0x1
ffffffffc0200d3e:	16e50513          	addi	a0,a0,366 # ffffffffc0201ea8 <commands+0x640>
{
ffffffffc0200d42:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0200d44:	e68ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200d48 <slub_alloc_small>:
    size_t total_size = size * PGSIZE; // 计算总大小
ffffffffc0200d48:	00001797          	auipc	a5,0x1
ffffffffc0200d4c:	6687a787          	flw	fa5,1640(a5) # ffffffffc02023b0 <nbase+0x8>
ffffffffc0200d50:	10f57553          	fmul.s	fa0,fa0,fa5
{
ffffffffc0200d54:	1101                	addi	sp,sp,-32
ffffffffc0200d56:	e426                	sd	s1,8(sp)
    struct SlubBlock *temp = &slub_block;
ffffffffc0200d58:	00005497          	auipc	s1,0x5
ffffffffc0200d5c:	2d048493          	addi	s1,s1,720 # ffffffffc0206028 <slub_block>
{
ffffffffc0200d60:	e822                	sd	s0,16(sp)
    size_t total_size = size * PGSIZE; // 计算总大小
ffffffffc0200d62:	c03516d3          	fcvt.lu.s	a3,fa0,rtz
{
ffffffffc0200d66:	ec06                	sd	ra,24(sp)
    struct SlubBlock *temp = &slub_block;
ffffffffc0200d68:	8426                	mv	s0,s1
    while (temp->next != &slub_block)
ffffffffc0200d6a:	a021                	j	ffffffffc0200d72 <slub_alloc_small+0x2a>
        if (temp->size >= total_size)
ffffffffc0200d6c:	6398                	ld	a4,0(a5)
ffffffffc0200d6e:	04d77263          	bgeu	a4,a3,ffffffffc0200db2 <slub_alloc_small+0x6a>
    while (temp->next != &slub_block)
ffffffffc0200d72:	87a2                	mv	a5,s0
ffffffffc0200d74:	6800                	ld	s0,16(s0)
ffffffffc0200d76:	fe941be3          	bne	s0,s1,ffffffffc0200d6c <slub_alloc_small+0x24>
    struct Page *page = slub_alloc_pages(1); // 分配一个页
ffffffffc0200d7a:	4505                	li	a0,1
ffffffffc0200d7c:	c49ff0ef          	jal	ra,ffffffffc02009c4 <slub_alloc_pages>
ffffffffc0200d80:	86aa                	mv	a3,a0
    if (page == NULL)
ffffffffc0200d82:	c129                	beqz	a0,ffffffffc0200dc4 <slub_alloc_small+0x7c>
    while (temp->next != &slub_block)
ffffffffc0200d84:	681c                	ld	a5,16(s0)
    block->size += total_size;
ffffffffc0200d86:	6705                	lui	a4,0x1
ffffffffc0200d88:	e118                	sd	a4,0(a0)
    slub_free_small((void *)(current_block + 1), 1);
ffffffffc0200d8a:	0561                	addi	a0,a0,24
    while (temp->next != &slub_block)
ffffffffc0200d8c:	00878e63          	beq	a5,s0,ffffffffc0200da8 <slub_alloc_small+0x60>
        if (temp->size <= block->size)
ffffffffc0200d90:	6605                	lui	a2,0x1
ffffffffc0200d92:	a011                	j	ffffffffc0200d96 <slub_alloc_small+0x4e>
ffffffffc0200d94:	87ba                	mv	a5,a4
ffffffffc0200d96:	6018                	ld	a4,0(s0)
ffffffffc0200d98:	00e66463          	bltu	a2,a4,ffffffffc0200da0 <slub_alloc_small+0x58>
            if (next == &slub_block || next > block)
ffffffffc0200d9c:	02f6e663          	bltu	a3,a5,ffffffffc0200dc8 <slub_alloc_small+0x80>
    while (temp->next != &slub_block)
ffffffffc0200da0:	6b98                	ld	a4,16(a5)
ffffffffc0200da2:	843e                	mv	s0,a5
ffffffffc0200da4:	fe9718e3          	bne	a4,s1,ffffffffc0200d94 <slub_alloc_small+0x4c>
}
ffffffffc0200da8:	60e2                	ld	ra,24(sp)
ffffffffc0200daa:	6442                	ld	s0,16(sp)
ffffffffc0200dac:	64a2                	ld	s1,8(sp)
ffffffffc0200dae:	6105                	addi	sp,sp,32
ffffffffc0200db0:	8082                	ret
            temp->next = block->next;
ffffffffc0200db2:	6818                	ld	a4,16(s0)
}
ffffffffc0200db4:	60e2                	ld	ra,24(sp)
            return (void *)(block + 1);
ffffffffc0200db6:	01840513          	addi	a0,s0,24
}
ffffffffc0200dba:	6442                	ld	s0,16(sp)
            temp->next = block->next;
ffffffffc0200dbc:	eb98                	sd	a4,16(a5)
}
ffffffffc0200dbe:	64a2                	ld	s1,8(sp)
ffffffffc0200dc0:	6105                	addi	sp,sp,32
ffffffffc0200dc2:	8082                	ret
        return NULL; // 分配失败
ffffffffc0200dc4:	4501                	li	a0,0
ffffffffc0200dc6:	b7cd                	j	ffffffffc0200da8 <slub_alloc_small+0x60>
                temp->next = block;
ffffffffc0200dc8:	e814                	sd	a3,16(s0)
}
ffffffffc0200dca:	60e2                	ld	ra,24(sp)
ffffffffc0200dcc:	6442                	ld	s0,16(sp)
                block->next = next;
ffffffffc0200dce:	ea9c                	sd	a5,16(a3)
}
ffffffffc0200dd0:	64a2                	ld	s1,8(sp)
ffffffffc0200dd2:	6105                	addi	sp,sp,32
ffffffffc0200dd4:	8082                	ret

ffffffffc0200dd6 <slub_alloc>:
    size = size * PGSIZE;
ffffffffc0200dd6:	0532                	slli	a0,a0,0xc
    if (size >= PGSIZE)
ffffffffc0200dd8:	6785                	lui	a5,0x1
ffffffffc0200dda:	00f57e63          	bgeu	a0,a5,ffffffffc0200df6 <slub_alloc+0x20>
    void *small_block_ptr = slub_alloc_small(size);
ffffffffc0200dde:	f0000553          	fmv.w.x	fa0,zero
{
ffffffffc0200de2:	1141                	addi	sp,sp,-16
ffffffffc0200de4:	e406                	sd	ra,8(sp)
    void *small_block_ptr = slub_alloc_small(size);
ffffffffc0200de6:	f63ff0ef          	jal	ra,ffffffffc0200d48 <slub_alloc_small>
    if (small_block_ptr)
ffffffffc0200dea:	c119                	beqz	a0,ffffffffc0200df0 <slub_alloc+0x1a>
        return block->page; // 返回关联的页面
ffffffffc0200dec:	ff053503          	ld	a0,-16(a0)
}
ffffffffc0200df0:	60a2                	ld	ra,8(sp)
ffffffffc0200df2:	0141                	addi	sp,sp,16
ffffffffc0200df4:	8082                	ret
        return slub_alloc_pages((size + PGSIZE - 1) / PGSIZE); // 大于一页时，直接分配整页
ffffffffc0200df6:	17fd                	addi	a5,a5,-1
ffffffffc0200df8:	953e                	add	a0,a0,a5
ffffffffc0200dfa:	8131                	srli	a0,a0,0xc
ffffffffc0200dfc:	b6e1                	j	ffffffffc02009c4 <slub_alloc_pages>

ffffffffc0200dfe <slub_check>:
    free_page(p1);
    free_page(p2);
}
static void
slub_check(void)
{
ffffffffc0200dfe:	7179                	addi	sp,sp,-48
    cprintf("测试开始\n");
ffffffffc0200e00:	00001517          	auipc	a0,0x1
ffffffffc0200e04:	0f850513          	addi	a0,a0,248 # ffffffffc0201ef8 <commands+0x690>
{
ffffffffc0200e08:	f406                	sd	ra,40(sp)
ffffffffc0200e0a:	f022                	sd	s0,32(sp)
ffffffffc0200e0c:	ec26                	sd	s1,24(sp)
ffffffffc0200e0e:	e84a                	sd	s2,16(sp)
ffffffffc0200e10:	e44e                	sd	s3,8(sp)
    cprintf("测试开始\n");
ffffffffc0200e12:	aa0ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    p0 = p1 = p2 = NULL;
    float size0 = 64 / PGSIZE;
    float size1 = 128 / PGSIZE;
    float size2 = 256 / PGSIZE;

    assert((p0 = slub_alloc_small(size0)) != NULL);
ffffffffc0200e16:	f0000553          	fmv.w.x	fa0,zero
ffffffffc0200e1a:	f2fff0ef          	jal	ra,ffffffffc0200d48 <slub_alloc_small>
ffffffffc0200e1e:	26050c63          	beqz	a0,ffffffffc0201096 <slub_check+0x298>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200e22:	00005797          	auipc	a5,0x5
ffffffffc0200e26:	6367b783          	ld	a5,1590(a5) # ffffffffc0206458 <pages>
ffffffffc0200e2a:	40f507b3          	sub	a5,a0,a5
ffffffffc0200e2e:	00001717          	auipc	a4,0x1
ffffffffc0200e32:	58a73703          	ld	a4,1418(a4) # ffffffffc02023b8 <nbase+0x10>
ffffffffc0200e36:	878d                	srai	a5,a5,0x3
ffffffffc0200e38:	02e787b3          	mul	a5,a5,a4
    assert(page2pa(p0) <= npage * (PGSIZE - 64));
ffffffffc0200e3c:	00005697          	auipc	a3,0x5
ffffffffc0200e40:	6146b683          	ld	a3,1556(a3) # ffffffffc0206450 <npage>
ffffffffc0200e44:	00669713          	slli	a4,a3,0x6
ffffffffc0200e48:	8f15                	sub	a4,a4,a3
ffffffffc0200e4a:	00001697          	auipc	a3,0x1
ffffffffc0200e4e:	55e6b683          	ld	a3,1374(a3) # ffffffffc02023a8 <nbase>
ffffffffc0200e52:	071a                	slli	a4,a4,0x6
ffffffffc0200e54:	89aa                	mv	s3,a0
ffffffffc0200e56:	97b6                	add	a5,a5,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0200e58:	07b2                	slli	a5,a5,0xc
ffffffffc0200e5a:	20f76e63          	bltu	a4,a5,ffffffffc0201076 <slub_check+0x278>
    cprintf("分配64字节测试通过\n");
ffffffffc0200e5e:	00001517          	auipc	a0,0x1
ffffffffc0200e62:	0fa50513          	addi	a0,a0,250 # ffffffffc0201f58 <commands+0x6f0>
ffffffffc0200e66:	a4cff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    assert((p1 = slub_alloc_small(size1)) != NULL);
ffffffffc0200e6a:	f0000553          	fmv.w.x	fa0,zero
ffffffffc0200e6e:	edbff0ef          	jal	ra,ffffffffc0200d48 <slub_alloc_small>
ffffffffc0200e72:	892a                	mv	s2,a0
ffffffffc0200e74:	1e050163          	beqz	a0,ffffffffc0201056 <slub_check+0x258>
    cprintf("分配128字节测试通过\n");
ffffffffc0200e78:	00001517          	auipc	a0,0x1
ffffffffc0200e7c:	12850513          	addi	a0,a0,296 # ffffffffc0201fa0 <commands+0x738>
ffffffffc0200e80:	a32ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    assert((p2 = slub_alloc_small(size2)) != NULL);
ffffffffc0200e84:	f0000553          	fmv.w.x	fa0,zero
ffffffffc0200e88:	ec1ff0ef          	jal	ra,ffffffffc0200d48 <slub_alloc_small>
ffffffffc0200e8c:	84aa                	mv	s1,a0
ffffffffc0200e8e:	1a050463          	beqz	a0,ffffffffc0201036 <slub_check+0x238>
    cprintf("分配256字节测试通过\n");
ffffffffc0200e92:	00001517          	auipc	a0,0x1
ffffffffc0200e96:	15650513          	addi	a0,a0,342 # ffffffffc0201fe8 <commands+0x780>
ffffffffc0200e9a:	a18ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    while (temp->next != &slub_block)
ffffffffc0200e9e:	00005417          	auipc	s0,0x5
ffffffffc0200ea2:	18a40413          	addi	s0,s0,394 # ffffffffc0206028 <slub_block>
ffffffffc0200ea6:	681c                	ld	a5,16(s0)
    block->size += total_size;
ffffffffc0200ea8:	fe89b603          	ld	a2,-24(s3)
    struct SlubBlock *block = (struct SlubBlock *)ptr - 1;
ffffffffc0200eac:	fe898593          	addi	a1,s3,-24
    while (temp->next != &slub_block)
ffffffffc0200eb0:	00878e63          	beq	a5,s0,ffffffffc0200ecc <slub_check+0xce>
    struct SlubBlock *temp = &slub_block;
ffffffffc0200eb4:	86a2                	mv	a3,s0
ffffffffc0200eb6:	a011                	j	ffffffffc0200eba <slub_check+0xbc>
ffffffffc0200eb8:	87ba                	mv	a5,a4
        if (temp->size <= block->size)
ffffffffc0200eba:	6298                	ld	a4,0(a3)
ffffffffc0200ebc:	00e66463          	bltu	a2,a4,ffffffffc0200ec4 <slub_check+0xc6>
            if (next == &slub_block || next > block)
ffffffffc0200ec0:	10f5ef63          	bltu	a1,a5,ffffffffc0200fde <slub_check+0x1e0>
    while (temp->next != &slub_block)
ffffffffc0200ec4:	6b98                	ld	a4,16(a5)
ffffffffc0200ec6:	86be                	mv	a3,a5
ffffffffc0200ec8:	fe8718e3          	bne	a4,s0,ffffffffc0200eb8 <slub_check+0xba>
    slub_free_small(p0, size0);
    cprintf("释放64字节测试通过\n");
ffffffffc0200ecc:	00001517          	auipc	a0,0x1
ffffffffc0200ed0:	13c50513          	addi	a0,a0,316 # ffffffffc0202008 <commands+0x7a0>
ffffffffc0200ed4:	9deff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    while (temp->next != &slub_block)
ffffffffc0200ed8:	681c                	ld	a5,16(s0)
    block->size += total_size;
ffffffffc0200eda:	fe893603          	ld	a2,-24(s2)
    struct SlubBlock *block = (struct SlubBlock *)ptr - 1;
ffffffffc0200ede:	fe890593          	addi	a1,s2,-24
    while (temp->next != &slub_block)
ffffffffc0200ee2:	02878163          	beq	a5,s0,ffffffffc0200f04 <slub_check+0x106>
    struct SlubBlock *temp = &slub_block;
ffffffffc0200ee6:	00005697          	auipc	a3,0x5
ffffffffc0200eea:	14268693          	addi	a3,a3,322 # ffffffffc0206028 <slub_block>
ffffffffc0200eee:	a011                	j	ffffffffc0200ef2 <slub_check+0xf4>
ffffffffc0200ef0:	87ba                	mv	a5,a4
        if (temp->size <= block->size)
ffffffffc0200ef2:	6298                	ld	a4,0(a3)
ffffffffc0200ef4:	00e66463          	bltu	a2,a4,ffffffffc0200efc <slub_check+0xfe>
            if (next == &slub_block || next > block)
ffffffffc0200ef8:	0ef5eb63          	bltu	a1,a5,ffffffffc0200fee <slub_check+0x1f0>
    while (temp->next != &slub_block)
ffffffffc0200efc:	6b98                	ld	a4,16(a5)
ffffffffc0200efe:	86be                	mv	a3,a5
ffffffffc0200f00:	fe8718e3          	bne	a4,s0,ffffffffc0200ef0 <slub_check+0xf2>
    slub_free_small(p1, size1);
    cprintf("释放128字节测试通过\n");
ffffffffc0200f04:	00001517          	auipc	a0,0x1
ffffffffc0200f08:	12450513          	addi	a0,a0,292 # ffffffffc0202028 <commands+0x7c0>
ffffffffc0200f0c:	9a6ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    while (temp->next != &slub_block)
ffffffffc0200f10:	681c                	ld	a5,16(s0)
    block->size += total_size;
ffffffffc0200f12:	fe84b603          	ld	a2,-24(s1)
    struct SlubBlock *block = (struct SlubBlock *)ptr - 1;
ffffffffc0200f16:	fe848593          	addi	a1,s1,-24
    while (temp->next != &slub_block)
ffffffffc0200f1a:	02878163          	beq	a5,s0,ffffffffc0200f3c <slub_check+0x13e>
    struct SlubBlock *temp = &slub_block;
ffffffffc0200f1e:	00005697          	auipc	a3,0x5
ffffffffc0200f22:	10a68693          	addi	a3,a3,266 # ffffffffc0206028 <slub_block>
ffffffffc0200f26:	a011                	j	ffffffffc0200f2a <slub_check+0x12c>
ffffffffc0200f28:	87ba                	mv	a5,a4
        if (temp->size <= block->size)
ffffffffc0200f2a:	6298                	ld	a4,0(a3)
ffffffffc0200f2c:	00e66463          	bltu	a2,a4,ffffffffc0200f34 <slub_check+0x136>
            if (next == &slub_block || next > block)
ffffffffc0200f30:	0af5eb63          	bltu	a1,a5,ffffffffc0200fe6 <slub_check+0x1e8>
    while (temp->next != &slub_block)
ffffffffc0200f34:	6b98                	ld	a4,16(a5)
ffffffffc0200f36:	86be                	mv	a3,a5
ffffffffc0200f38:	fe8718e3          	bne	a4,s0,ffffffffc0200f28 <slub_check+0x12a>
    slub_free_small(p2, size2);
    cprintf("释放256字节测试通过\n");
ffffffffc0200f3c:	00001517          	auipc	a0,0x1
ffffffffc0200f40:	10c50513          	addi	a0,a0,268 # ffffffffc0202048 <commands+0x7e0>
ffffffffc0200f44:	96eff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("重复64字节分配测试开始\n");
ffffffffc0200f48:	00001517          	auipc	a0,0x1
ffffffffc0200f4c:	12050513          	addi	a0,a0,288 # ffffffffc0202068 <commands+0x800>
ffffffffc0200f50:	962ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc0200f54:	3e800493          	li	s1,1000
    struct SlubBlock *temp = &slub_block;
ffffffffc0200f58:	00005917          	auipc	s2,0x5
ffffffffc0200f5c:	0d090913          	addi	s2,s2,208 # ffffffffc0206028 <slub_block>
    for (int i = 0; i < 1000; i++)
    {
        void *ptr = slub_alloc_small(64 / PGSIZE);
ffffffffc0200f60:	f0000553          	fmv.w.x	fa0,zero
ffffffffc0200f64:	de5ff0ef          	jal	ra,ffffffffc0200d48 <slub_alloc_small>
        assert(ptr != NULL);
ffffffffc0200f68:	c55d                	beqz	a0,ffffffffc0201016 <slub_check+0x218>
    while (temp->next != &slub_block)
ffffffffc0200f6a:	681c                	ld	a5,16(s0)
    block->size += total_size;
ffffffffc0200f6c:	fe853603          	ld	a2,-24(a0)
    struct SlubBlock *block = (struct SlubBlock *)ptr - 1;
ffffffffc0200f70:	fe850593          	addi	a1,a0,-24
    while (temp->next != &slub_block)
ffffffffc0200f74:	00878e63          	beq	a5,s0,ffffffffc0200f90 <slub_check+0x192>
    struct SlubBlock *temp = &slub_block;
ffffffffc0200f78:	86ca                	mv	a3,s2
ffffffffc0200f7a:	a011                	j	ffffffffc0200f7e <slub_check+0x180>
ffffffffc0200f7c:	87ba                	mv	a5,a4
        if (temp->size <= block->size)
ffffffffc0200f7e:	6298                	ld	a4,0(a3)
ffffffffc0200f80:	00e66463          	bltu	a2,a4,ffffffffc0200f88 <slub_check+0x18a>
            if (next == &slub_block || next > block)
ffffffffc0200f84:	04f5e763          	bltu	a1,a5,ffffffffc0200fd2 <slub_check+0x1d4>
    while (temp->next != &slub_block)
ffffffffc0200f88:	6b98                	ld	a4,16(a5)
ffffffffc0200f8a:	86be                	mv	a3,a5
ffffffffc0200f8c:	fe8718e3          	bne	a4,s0,ffffffffc0200f7c <slub_check+0x17e>
    for (int i = 0; i < 1000; i++)
ffffffffc0200f90:	34fd                	addiw	s1,s1,-1
ffffffffc0200f92:	f4f9                	bnez	s1,ffffffffc0200f60 <slub_check+0x162>
        slub_free_small(ptr, 64 / PGSIZE);
    }
    cprintf("重复64字节分配测试通过\n");
ffffffffc0200f94:	00001517          	auipc	a0,0x1
ffffffffc0200f98:	10c50513          	addi	a0,a0,268 # ffffffffc02020a0 <commands+0x838>
ffffffffc0200f9c:	916ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
        return slub_alloc_pages((size + PGSIZE - 1) / PGSIZE); // 大于一页时，直接分配整页
ffffffffc0200fa0:	4515                	li	a0,5
ffffffffc0200fa2:	a23ff0ef          	jal	ra,ffffffffc02009c4 <slub_alloc_pages>
    struct Page *page = slub_alloc(5); // 分配 5 页
    assert(page != NULL);
ffffffffc0200fa6:	c921                	beqz	a0,ffffffffc0200ff6 <slub_check+0x1f8>
    assert(n > 0);
ffffffffc0200fa8:	4595                	li	a1,5
ffffffffc0200faa:	ae1ff0ef          	jal	ra,ffffffffc0200a8a <slub_free_pages.part.0>
    slub_free_pages(page, 5); // 释放 5 页
    cprintf("分配和释放5页测试通过\n");
ffffffffc0200fae:	00001517          	auipc	a0,0x1
ffffffffc0200fb2:	12a50513          	addi	a0,a0,298 # ffffffffc02020d8 <commands+0x870>
ffffffffc0200fb6:	8fcff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("测试结束\n");
}
ffffffffc0200fba:	7402                	ld	s0,32(sp)
ffffffffc0200fbc:	70a2                	ld	ra,40(sp)
ffffffffc0200fbe:	64e2                	ld	s1,24(sp)
ffffffffc0200fc0:	6942                	ld	s2,16(sp)
ffffffffc0200fc2:	69a2                	ld	s3,8(sp)
    cprintf("测试结束\n");
ffffffffc0200fc4:	00001517          	auipc	a0,0x1
ffffffffc0200fc8:	13c50513          	addi	a0,a0,316 # ffffffffc0202100 <commands+0x898>
}
ffffffffc0200fcc:	6145                	addi	sp,sp,48
    cprintf("测试结束\n");
ffffffffc0200fce:	8e4ff06f          	j	ffffffffc02000b2 <cprintf>
                temp->next = block;
ffffffffc0200fd2:	ea8c                	sd	a1,16(a3)
                block->next = next;
ffffffffc0200fd4:	fef53c23          	sd	a5,-8(a0)
    for (int i = 0; i < 1000; i++)
ffffffffc0200fd8:	34fd                	addiw	s1,s1,-1
ffffffffc0200fda:	f0d9                	bnez	s1,ffffffffc0200f60 <slub_check+0x162>
ffffffffc0200fdc:	bf65                	j	ffffffffc0200f94 <slub_check+0x196>
                temp->next = block;
ffffffffc0200fde:	ea8c                	sd	a1,16(a3)
                block->next = next;
ffffffffc0200fe0:	fef9bc23          	sd	a5,-8(s3)
                return;
ffffffffc0200fe4:	b5e5                	j	ffffffffc0200ecc <slub_check+0xce>
                temp->next = block;
ffffffffc0200fe6:	ea8c                	sd	a1,16(a3)
                block->next = next;
ffffffffc0200fe8:	fef4bc23          	sd	a5,-8(s1)
                return;
ffffffffc0200fec:	bf81                	j	ffffffffc0200f3c <slub_check+0x13e>
                temp->next = block;
ffffffffc0200fee:	ea8c                	sd	a1,16(a3)
                block->next = next;
ffffffffc0200ff0:	fef93c23          	sd	a5,-8(s2)
                return;
ffffffffc0200ff4:	bf01                	j	ffffffffc0200f04 <slub_check+0x106>
    assert(page != NULL);
ffffffffc0200ff6:	00001697          	auipc	a3,0x1
ffffffffc0200ffa:	0d268693          	addi	a3,a3,210 # ffffffffc02020c8 <commands+0x860>
ffffffffc0200ffe:	00001617          	auipc	a2,0x1
ffffffffc0201002:	e9260613          	addi	a2,a2,-366 # ffffffffc0201e90 <commands+0x628>
ffffffffc0201006:	16b00593          	li	a1,363
ffffffffc020100a:	00001517          	auipc	a0,0x1
ffffffffc020100e:	e9e50513          	addi	a0,a0,-354 # ffffffffc0201ea8 <commands+0x640>
ffffffffc0201012:	b9aff0ef          	jal	ra,ffffffffc02003ac <__panic>
        assert(ptr != NULL);
ffffffffc0201016:	00001697          	auipc	a3,0x1
ffffffffc020101a:	07a68693          	addi	a3,a3,122 # ffffffffc0202090 <commands+0x828>
ffffffffc020101e:	00001617          	auipc	a2,0x1
ffffffffc0201022:	e7260613          	addi	a2,a2,-398 # ffffffffc0201e90 <commands+0x628>
ffffffffc0201026:	16600593          	li	a1,358
ffffffffc020102a:	00001517          	auipc	a0,0x1
ffffffffc020102e:	e7e50513          	addi	a0,a0,-386 # ffffffffc0201ea8 <commands+0x640>
ffffffffc0201032:	b7aff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p2 = slub_alloc_small(size2)) != NULL);
ffffffffc0201036:	00001697          	auipc	a3,0x1
ffffffffc020103a:	f8a68693          	addi	a3,a3,-118 # ffffffffc0201fc0 <commands+0x758>
ffffffffc020103e:	00001617          	auipc	a2,0x1
ffffffffc0201042:	e5260613          	addi	a2,a2,-430 # ffffffffc0201e90 <commands+0x628>
ffffffffc0201046:	15a00593          	li	a1,346
ffffffffc020104a:	00001517          	auipc	a0,0x1
ffffffffc020104e:	e5e50513          	addi	a0,a0,-418 # ffffffffc0201ea8 <commands+0x640>
ffffffffc0201052:	b5aff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p1 = slub_alloc_small(size1)) != NULL);
ffffffffc0201056:	00001697          	auipc	a3,0x1
ffffffffc020105a:	f2268693          	addi	a3,a3,-222 # ffffffffc0201f78 <commands+0x710>
ffffffffc020105e:	00001617          	auipc	a2,0x1
ffffffffc0201062:	e3260613          	addi	a2,a2,-462 # ffffffffc0201e90 <commands+0x628>
ffffffffc0201066:	15800593          	li	a1,344
ffffffffc020106a:	00001517          	auipc	a0,0x1
ffffffffc020106e:	e3e50513          	addi	a0,a0,-450 # ffffffffc0201ea8 <commands+0x640>
ffffffffc0201072:	b3aff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(page2pa(p0) <= npage * (PGSIZE - 64));
ffffffffc0201076:	00001697          	auipc	a3,0x1
ffffffffc020107a:	eba68693          	addi	a3,a3,-326 # ffffffffc0201f30 <commands+0x6c8>
ffffffffc020107e:	00001617          	auipc	a2,0x1
ffffffffc0201082:	e1260613          	addi	a2,a2,-494 # ffffffffc0201e90 <commands+0x628>
ffffffffc0201086:	15600593          	li	a1,342
ffffffffc020108a:	00001517          	auipc	a0,0x1
ffffffffc020108e:	e1e50513          	addi	a0,a0,-482 # ffffffffc0201ea8 <commands+0x640>
ffffffffc0201092:	b1aff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p0 = slub_alloc_small(size0)) != NULL);
ffffffffc0201096:	00001697          	auipc	a3,0x1
ffffffffc020109a:	e7268693          	addi	a3,a3,-398 # ffffffffc0201f08 <commands+0x6a0>
ffffffffc020109e:	00001617          	auipc	a2,0x1
ffffffffc02010a2:	df260613          	addi	a2,a2,-526 # ffffffffc0201e90 <commands+0x628>
ffffffffc02010a6:	15500593          	li	a1,341
ffffffffc02010aa:	00001517          	auipc	a0,0x1
ffffffffc02010ae:	dfe50513          	addi	a0,a0,-514 # ffffffffc0201ea8 <commands+0x640>
ffffffffc02010b2:	afaff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc02010b6 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc02010b6:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02010ba:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc02010bc:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02010c0:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc02010c2:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02010c6:	f022                	sd	s0,32(sp)
ffffffffc02010c8:	ec26                	sd	s1,24(sp)
ffffffffc02010ca:	e84a                	sd	s2,16(sp)
ffffffffc02010cc:	f406                	sd	ra,40(sp)
ffffffffc02010ce:	e44e                	sd	s3,8(sp)
ffffffffc02010d0:	84aa                	mv	s1,a0
ffffffffc02010d2:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc02010d4:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc02010d8:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc02010da:	03067e63          	bgeu	a2,a6,ffffffffc0201116 <printnum+0x60>
ffffffffc02010de:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc02010e0:	00805763          	blez	s0,ffffffffc02010ee <printnum+0x38>
ffffffffc02010e4:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc02010e6:	85ca                	mv	a1,s2
ffffffffc02010e8:	854e                	mv	a0,s3
ffffffffc02010ea:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc02010ec:	fc65                	bnez	s0,ffffffffc02010e4 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02010ee:	1a02                	slli	s4,s4,0x20
ffffffffc02010f0:	00001797          	auipc	a5,0x1
ffffffffc02010f4:	07078793          	addi	a5,a5,112 # ffffffffc0202160 <slub_pmm_manager+0x38>
ffffffffc02010f8:	020a5a13          	srli	s4,s4,0x20
ffffffffc02010fc:	9a3e                	add	s4,s4,a5
}
ffffffffc02010fe:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201100:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0201104:	70a2                	ld	ra,40(sp)
ffffffffc0201106:	69a2                	ld	s3,8(sp)
ffffffffc0201108:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020110a:	85ca                	mv	a1,s2
ffffffffc020110c:	87a6                	mv	a5,s1
}
ffffffffc020110e:	6942                	ld	s2,16(sp)
ffffffffc0201110:	64e2                	ld	s1,24(sp)
ffffffffc0201112:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201114:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0201116:	03065633          	divu	a2,a2,a6
ffffffffc020111a:	8722                	mv	a4,s0
ffffffffc020111c:	f9bff0ef          	jal	ra,ffffffffc02010b6 <printnum>
ffffffffc0201120:	b7f9                	j	ffffffffc02010ee <printnum+0x38>

ffffffffc0201122 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0201122:	7119                	addi	sp,sp,-128
ffffffffc0201124:	f4a6                	sd	s1,104(sp)
ffffffffc0201126:	f0ca                	sd	s2,96(sp)
ffffffffc0201128:	ecce                	sd	s3,88(sp)
ffffffffc020112a:	e8d2                	sd	s4,80(sp)
ffffffffc020112c:	e4d6                	sd	s5,72(sp)
ffffffffc020112e:	e0da                	sd	s6,64(sp)
ffffffffc0201130:	fc5e                	sd	s7,56(sp)
ffffffffc0201132:	f06a                	sd	s10,32(sp)
ffffffffc0201134:	fc86                	sd	ra,120(sp)
ffffffffc0201136:	f8a2                	sd	s0,112(sp)
ffffffffc0201138:	f862                	sd	s8,48(sp)
ffffffffc020113a:	f466                	sd	s9,40(sp)
ffffffffc020113c:	ec6e                	sd	s11,24(sp)
ffffffffc020113e:	892a                	mv	s2,a0
ffffffffc0201140:	84ae                	mv	s1,a1
ffffffffc0201142:	8d32                	mv	s10,a2
ffffffffc0201144:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201146:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc020114a:	5b7d                	li	s6,-1
ffffffffc020114c:	00001a97          	auipc	s5,0x1
ffffffffc0201150:	048a8a93          	addi	s5,s5,72 # ffffffffc0202194 <slub_pmm_manager+0x6c>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201154:	00001b97          	auipc	s7,0x1
ffffffffc0201158:	21cb8b93          	addi	s7,s7,540 # ffffffffc0202370 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020115c:	000d4503          	lbu	a0,0(s10)
ffffffffc0201160:	001d0413          	addi	s0,s10,1
ffffffffc0201164:	01350a63          	beq	a0,s3,ffffffffc0201178 <vprintfmt+0x56>
            if (ch == '\0') {
ffffffffc0201168:	c121                	beqz	a0,ffffffffc02011a8 <vprintfmt+0x86>
            putch(ch, putdat);
ffffffffc020116a:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020116c:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc020116e:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201170:	fff44503          	lbu	a0,-1(s0)
ffffffffc0201174:	ff351ae3          	bne	a0,s3,ffffffffc0201168 <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201178:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc020117c:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc0201180:	4c81                	li	s9,0
ffffffffc0201182:	4881                	li	a7,0
        width = precision = -1;
ffffffffc0201184:	5c7d                	li	s8,-1
ffffffffc0201186:	5dfd                	li	s11,-1
ffffffffc0201188:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
ffffffffc020118c:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020118e:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0201192:	0ff5f593          	zext.b	a1,a1
ffffffffc0201196:	00140d13          	addi	s10,s0,1
ffffffffc020119a:	04b56263          	bltu	a0,a1,ffffffffc02011de <vprintfmt+0xbc>
ffffffffc020119e:	058a                	slli	a1,a1,0x2
ffffffffc02011a0:	95d6                	add	a1,a1,s5
ffffffffc02011a2:	4194                	lw	a3,0(a1)
ffffffffc02011a4:	96d6                	add	a3,a3,s5
ffffffffc02011a6:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc02011a8:	70e6                	ld	ra,120(sp)
ffffffffc02011aa:	7446                	ld	s0,112(sp)
ffffffffc02011ac:	74a6                	ld	s1,104(sp)
ffffffffc02011ae:	7906                	ld	s2,96(sp)
ffffffffc02011b0:	69e6                	ld	s3,88(sp)
ffffffffc02011b2:	6a46                	ld	s4,80(sp)
ffffffffc02011b4:	6aa6                	ld	s5,72(sp)
ffffffffc02011b6:	6b06                	ld	s6,64(sp)
ffffffffc02011b8:	7be2                	ld	s7,56(sp)
ffffffffc02011ba:	7c42                	ld	s8,48(sp)
ffffffffc02011bc:	7ca2                	ld	s9,40(sp)
ffffffffc02011be:	7d02                	ld	s10,32(sp)
ffffffffc02011c0:	6de2                	ld	s11,24(sp)
ffffffffc02011c2:	6109                	addi	sp,sp,128
ffffffffc02011c4:	8082                	ret
            padc = '0';
ffffffffc02011c6:	87b2                	mv	a5,a2
            goto reswitch;
ffffffffc02011c8:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02011cc:	846a                	mv	s0,s10
ffffffffc02011ce:	00140d13          	addi	s10,s0,1
ffffffffc02011d2:	fdd6059b          	addiw	a1,a2,-35
ffffffffc02011d6:	0ff5f593          	zext.b	a1,a1
ffffffffc02011da:	fcb572e3          	bgeu	a0,a1,ffffffffc020119e <vprintfmt+0x7c>
            putch('%', putdat);
ffffffffc02011de:	85a6                	mv	a1,s1
ffffffffc02011e0:	02500513          	li	a0,37
ffffffffc02011e4:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc02011e6:	fff44783          	lbu	a5,-1(s0)
ffffffffc02011ea:	8d22                	mv	s10,s0
ffffffffc02011ec:	f73788e3          	beq	a5,s3,ffffffffc020115c <vprintfmt+0x3a>
ffffffffc02011f0:	ffed4783          	lbu	a5,-2(s10)
ffffffffc02011f4:	1d7d                	addi	s10,s10,-1
ffffffffc02011f6:	ff379de3          	bne	a5,s3,ffffffffc02011f0 <vprintfmt+0xce>
ffffffffc02011fa:	b78d                	j	ffffffffc020115c <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
ffffffffc02011fc:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
ffffffffc0201200:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201204:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc0201206:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc020120a:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc020120e:	02d86463          	bltu	a6,a3,ffffffffc0201236 <vprintfmt+0x114>
                ch = *fmt;
ffffffffc0201212:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0201216:	002c169b          	slliw	a3,s8,0x2
ffffffffc020121a:	0186873b          	addw	a4,a3,s8
ffffffffc020121e:	0017171b          	slliw	a4,a4,0x1
ffffffffc0201222:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
ffffffffc0201224:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc0201228:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc020122a:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
ffffffffc020122e:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc0201232:	fed870e3          	bgeu	a6,a3,ffffffffc0201212 <vprintfmt+0xf0>
            if (width < 0)
ffffffffc0201236:	f40ddce3          	bgez	s11,ffffffffc020118e <vprintfmt+0x6c>
                width = precision, precision = -1;
ffffffffc020123a:	8de2                	mv	s11,s8
ffffffffc020123c:	5c7d                	li	s8,-1
ffffffffc020123e:	bf81                	j	ffffffffc020118e <vprintfmt+0x6c>
            if (width < 0)
ffffffffc0201240:	fffdc693          	not	a3,s11
ffffffffc0201244:	96fd                	srai	a3,a3,0x3f
ffffffffc0201246:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020124a:	00144603          	lbu	a2,1(s0)
ffffffffc020124e:	2d81                	sext.w	s11,s11
ffffffffc0201250:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201252:	bf35                	j	ffffffffc020118e <vprintfmt+0x6c>
            precision = va_arg(ap, int);
ffffffffc0201254:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201258:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc020125c:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020125e:	846a                	mv	s0,s10
            goto process_precision;
ffffffffc0201260:	bfd9                	j	ffffffffc0201236 <vprintfmt+0x114>
    if (lflag >= 2) {
ffffffffc0201262:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201264:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0201268:	01174463          	blt	a4,a7,ffffffffc0201270 <vprintfmt+0x14e>
    else if (lflag) {
ffffffffc020126c:	1a088e63          	beqz	a7,ffffffffc0201428 <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
ffffffffc0201270:	000a3603          	ld	a2,0(s4)
ffffffffc0201274:	46c1                	li	a3,16
ffffffffc0201276:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0201278:	2781                	sext.w	a5,a5
ffffffffc020127a:	876e                	mv	a4,s11
ffffffffc020127c:	85a6                	mv	a1,s1
ffffffffc020127e:	854a                	mv	a0,s2
ffffffffc0201280:	e37ff0ef          	jal	ra,ffffffffc02010b6 <printnum>
            break;
ffffffffc0201284:	bde1                	j	ffffffffc020115c <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
ffffffffc0201286:	000a2503          	lw	a0,0(s4)
ffffffffc020128a:	85a6                	mv	a1,s1
ffffffffc020128c:	0a21                	addi	s4,s4,8
ffffffffc020128e:	9902                	jalr	s2
            break;
ffffffffc0201290:	b5f1                	j	ffffffffc020115c <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0201292:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201294:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0201298:	01174463          	blt	a4,a7,ffffffffc02012a0 <vprintfmt+0x17e>
    else if (lflag) {
ffffffffc020129c:	18088163          	beqz	a7,ffffffffc020141e <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
ffffffffc02012a0:	000a3603          	ld	a2,0(s4)
ffffffffc02012a4:	46a9                	li	a3,10
ffffffffc02012a6:	8a2e                	mv	s4,a1
ffffffffc02012a8:	bfc1                	j	ffffffffc0201278 <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02012aa:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc02012ae:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02012b0:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02012b2:	bdf1                	j	ffffffffc020118e <vprintfmt+0x6c>
            putch(ch, putdat);
ffffffffc02012b4:	85a6                	mv	a1,s1
ffffffffc02012b6:	02500513          	li	a0,37
ffffffffc02012ba:	9902                	jalr	s2
            break;
ffffffffc02012bc:	b545                	j	ffffffffc020115c <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02012be:	00144603          	lbu	a2,1(s0)
            lflag ++;
ffffffffc02012c2:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02012c4:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02012c6:	b5e1                	j	ffffffffc020118e <vprintfmt+0x6c>
    if (lflag >= 2) {
ffffffffc02012c8:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02012ca:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc02012ce:	01174463          	blt	a4,a7,ffffffffc02012d6 <vprintfmt+0x1b4>
    else if (lflag) {
ffffffffc02012d2:	14088163          	beqz	a7,ffffffffc0201414 <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
ffffffffc02012d6:	000a3603          	ld	a2,0(s4)
ffffffffc02012da:	46a1                	li	a3,8
ffffffffc02012dc:	8a2e                	mv	s4,a1
ffffffffc02012de:	bf69                	j	ffffffffc0201278 <vprintfmt+0x156>
            putch('0', putdat);
ffffffffc02012e0:	03000513          	li	a0,48
ffffffffc02012e4:	85a6                	mv	a1,s1
ffffffffc02012e6:	e03e                	sd	a5,0(sp)
ffffffffc02012e8:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc02012ea:	85a6                	mv	a1,s1
ffffffffc02012ec:	07800513          	li	a0,120
ffffffffc02012f0:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc02012f2:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc02012f4:	6782                	ld	a5,0(sp)
ffffffffc02012f6:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc02012f8:	ff8a3603          	ld	a2,-8(s4)
            goto number;
ffffffffc02012fc:	bfb5                	j	ffffffffc0201278 <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc02012fe:	000a3403          	ld	s0,0(s4)
ffffffffc0201302:	008a0713          	addi	a4,s4,8
ffffffffc0201306:	e03a                	sd	a4,0(sp)
ffffffffc0201308:	14040263          	beqz	s0,ffffffffc020144c <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
ffffffffc020130c:	0fb05763          	blez	s11,ffffffffc02013fa <vprintfmt+0x2d8>
ffffffffc0201310:	02d00693          	li	a3,45
ffffffffc0201314:	0cd79163          	bne	a5,a3,ffffffffc02013d6 <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201318:	00044783          	lbu	a5,0(s0)
ffffffffc020131c:	0007851b          	sext.w	a0,a5
ffffffffc0201320:	cf85                	beqz	a5,ffffffffc0201358 <vprintfmt+0x236>
ffffffffc0201322:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201326:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020132a:	000c4563          	bltz	s8,ffffffffc0201334 <vprintfmt+0x212>
ffffffffc020132e:	3c7d                	addiw	s8,s8,-1
ffffffffc0201330:	036c0263          	beq	s8,s6,ffffffffc0201354 <vprintfmt+0x232>
                    putch('?', putdat);
ffffffffc0201334:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201336:	0e0c8e63          	beqz	s9,ffffffffc0201432 <vprintfmt+0x310>
ffffffffc020133a:	3781                	addiw	a5,a5,-32
ffffffffc020133c:	0ef47b63          	bgeu	s0,a5,ffffffffc0201432 <vprintfmt+0x310>
                    putch('?', putdat);
ffffffffc0201340:	03f00513          	li	a0,63
ffffffffc0201344:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201346:	000a4783          	lbu	a5,0(s4)
ffffffffc020134a:	3dfd                	addiw	s11,s11,-1
ffffffffc020134c:	0a05                	addi	s4,s4,1
ffffffffc020134e:	0007851b          	sext.w	a0,a5
ffffffffc0201352:	ffe1                	bnez	a5,ffffffffc020132a <vprintfmt+0x208>
            for (; width > 0; width --) {
ffffffffc0201354:	01b05963          	blez	s11,ffffffffc0201366 <vprintfmt+0x244>
ffffffffc0201358:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc020135a:	85a6                	mv	a1,s1
ffffffffc020135c:	02000513          	li	a0,32
ffffffffc0201360:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0201362:	fe0d9be3          	bnez	s11,ffffffffc0201358 <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0201366:	6a02                	ld	s4,0(sp)
ffffffffc0201368:	bbd5                	j	ffffffffc020115c <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc020136a:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc020136c:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
ffffffffc0201370:	01174463          	blt	a4,a7,ffffffffc0201378 <vprintfmt+0x256>
    else if (lflag) {
ffffffffc0201374:	08088d63          	beqz	a7,ffffffffc020140e <vprintfmt+0x2ec>
        return va_arg(*ap, long);
ffffffffc0201378:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc020137c:	0a044d63          	bltz	s0,ffffffffc0201436 <vprintfmt+0x314>
            num = getint(&ap, lflag);
ffffffffc0201380:	8622                	mv	a2,s0
ffffffffc0201382:	8a66                	mv	s4,s9
ffffffffc0201384:	46a9                	li	a3,10
ffffffffc0201386:	bdcd                	j	ffffffffc0201278 <vprintfmt+0x156>
            err = va_arg(ap, int);
ffffffffc0201388:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc020138c:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc020138e:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc0201390:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0201394:	8fb5                	xor	a5,a5,a3
ffffffffc0201396:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc020139a:	02d74163          	blt	a4,a3,ffffffffc02013bc <vprintfmt+0x29a>
ffffffffc020139e:	00369793          	slli	a5,a3,0x3
ffffffffc02013a2:	97de                	add	a5,a5,s7
ffffffffc02013a4:	639c                	ld	a5,0(a5)
ffffffffc02013a6:	cb99                	beqz	a5,ffffffffc02013bc <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
ffffffffc02013a8:	86be                	mv	a3,a5
ffffffffc02013aa:	00001617          	auipc	a2,0x1
ffffffffc02013ae:	de660613          	addi	a2,a2,-538 # ffffffffc0202190 <slub_pmm_manager+0x68>
ffffffffc02013b2:	85a6                	mv	a1,s1
ffffffffc02013b4:	854a                	mv	a0,s2
ffffffffc02013b6:	0ce000ef          	jal	ra,ffffffffc0201484 <printfmt>
ffffffffc02013ba:	b34d                	j	ffffffffc020115c <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc02013bc:	00001617          	auipc	a2,0x1
ffffffffc02013c0:	dc460613          	addi	a2,a2,-572 # ffffffffc0202180 <slub_pmm_manager+0x58>
ffffffffc02013c4:	85a6                	mv	a1,s1
ffffffffc02013c6:	854a                	mv	a0,s2
ffffffffc02013c8:	0bc000ef          	jal	ra,ffffffffc0201484 <printfmt>
ffffffffc02013cc:	bb41                	j	ffffffffc020115c <vprintfmt+0x3a>
                p = "(null)";
ffffffffc02013ce:	00001417          	auipc	s0,0x1
ffffffffc02013d2:	daa40413          	addi	s0,s0,-598 # ffffffffc0202178 <slub_pmm_manager+0x50>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02013d6:	85e2                	mv	a1,s8
ffffffffc02013d8:	8522                	mv	a0,s0
ffffffffc02013da:	e43e                	sd	a5,8(sp)
ffffffffc02013dc:	1cc000ef          	jal	ra,ffffffffc02015a8 <strnlen>
ffffffffc02013e0:	40ad8dbb          	subw	s11,s11,a0
ffffffffc02013e4:	01b05b63          	blez	s11,ffffffffc02013fa <vprintfmt+0x2d8>
                    putch(padc, putdat);
ffffffffc02013e8:	67a2                	ld	a5,8(sp)
ffffffffc02013ea:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02013ee:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc02013f0:	85a6                	mv	a1,s1
ffffffffc02013f2:	8552                	mv	a0,s4
ffffffffc02013f4:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02013f6:	fe0d9ce3          	bnez	s11,ffffffffc02013ee <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02013fa:	00044783          	lbu	a5,0(s0)
ffffffffc02013fe:	00140a13          	addi	s4,s0,1
ffffffffc0201402:	0007851b          	sext.w	a0,a5
ffffffffc0201406:	d3a5                	beqz	a5,ffffffffc0201366 <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201408:	05e00413          	li	s0,94
ffffffffc020140c:	bf39                	j	ffffffffc020132a <vprintfmt+0x208>
        return va_arg(*ap, int);
ffffffffc020140e:	000a2403          	lw	s0,0(s4)
ffffffffc0201412:	b7ad                	j	ffffffffc020137c <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
ffffffffc0201414:	000a6603          	lwu	a2,0(s4)
ffffffffc0201418:	46a1                	li	a3,8
ffffffffc020141a:	8a2e                	mv	s4,a1
ffffffffc020141c:	bdb1                	j	ffffffffc0201278 <vprintfmt+0x156>
ffffffffc020141e:	000a6603          	lwu	a2,0(s4)
ffffffffc0201422:	46a9                	li	a3,10
ffffffffc0201424:	8a2e                	mv	s4,a1
ffffffffc0201426:	bd89                	j	ffffffffc0201278 <vprintfmt+0x156>
ffffffffc0201428:	000a6603          	lwu	a2,0(s4)
ffffffffc020142c:	46c1                	li	a3,16
ffffffffc020142e:	8a2e                	mv	s4,a1
ffffffffc0201430:	b5a1                	j	ffffffffc0201278 <vprintfmt+0x156>
                    putch(ch, putdat);
ffffffffc0201432:	9902                	jalr	s2
ffffffffc0201434:	bf09                	j	ffffffffc0201346 <vprintfmt+0x224>
                putch('-', putdat);
ffffffffc0201436:	85a6                	mv	a1,s1
ffffffffc0201438:	02d00513          	li	a0,45
ffffffffc020143c:	e03e                	sd	a5,0(sp)
ffffffffc020143e:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc0201440:	6782                	ld	a5,0(sp)
ffffffffc0201442:	8a66                	mv	s4,s9
ffffffffc0201444:	40800633          	neg	a2,s0
ffffffffc0201448:	46a9                	li	a3,10
ffffffffc020144a:	b53d                	j	ffffffffc0201278 <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
ffffffffc020144c:	03b05163          	blez	s11,ffffffffc020146e <vprintfmt+0x34c>
ffffffffc0201450:	02d00693          	li	a3,45
ffffffffc0201454:	f6d79de3          	bne	a5,a3,ffffffffc02013ce <vprintfmt+0x2ac>
                p = "(null)";
ffffffffc0201458:	00001417          	auipc	s0,0x1
ffffffffc020145c:	d2040413          	addi	s0,s0,-736 # ffffffffc0202178 <slub_pmm_manager+0x50>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201460:	02800793          	li	a5,40
ffffffffc0201464:	02800513          	li	a0,40
ffffffffc0201468:	00140a13          	addi	s4,s0,1
ffffffffc020146c:	bd6d                	j	ffffffffc0201326 <vprintfmt+0x204>
ffffffffc020146e:	00001a17          	auipc	s4,0x1
ffffffffc0201472:	d0ba0a13          	addi	s4,s4,-757 # ffffffffc0202179 <slub_pmm_manager+0x51>
ffffffffc0201476:	02800513          	li	a0,40
ffffffffc020147a:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc020147e:	05e00413          	li	s0,94
ffffffffc0201482:	b565                	j	ffffffffc020132a <vprintfmt+0x208>

ffffffffc0201484 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201484:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc0201486:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc020148a:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc020148c:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc020148e:	ec06                	sd	ra,24(sp)
ffffffffc0201490:	f83a                	sd	a4,48(sp)
ffffffffc0201492:	fc3e                	sd	a5,56(sp)
ffffffffc0201494:	e0c2                	sd	a6,64(sp)
ffffffffc0201496:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0201498:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc020149a:	c89ff0ef          	jal	ra,ffffffffc0201122 <vprintfmt>
}
ffffffffc020149e:	60e2                	ld	ra,24(sp)
ffffffffc02014a0:	6161                	addi	sp,sp,80
ffffffffc02014a2:	8082                	ret

ffffffffc02014a4 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc02014a4:	715d                	addi	sp,sp,-80
ffffffffc02014a6:	e486                	sd	ra,72(sp)
ffffffffc02014a8:	e0a6                	sd	s1,64(sp)
ffffffffc02014aa:	fc4a                	sd	s2,56(sp)
ffffffffc02014ac:	f84e                	sd	s3,48(sp)
ffffffffc02014ae:	f452                	sd	s4,40(sp)
ffffffffc02014b0:	f056                	sd	s5,32(sp)
ffffffffc02014b2:	ec5a                	sd	s6,24(sp)
ffffffffc02014b4:	e85e                	sd	s7,16(sp)
    if (prompt != NULL) {
ffffffffc02014b6:	c901                	beqz	a0,ffffffffc02014c6 <readline+0x22>
ffffffffc02014b8:	85aa                	mv	a1,a0
        cprintf("%s", prompt);
ffffffffc02014ba:	00001517          	auipc	a0,0x1
ffffffffc02014be:	cd650513          	addi	a0,a0,-810 # ffffffffc0202190 <slub_pmm_manager+0x68>
ffffffffc02014c2:	bf1fe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
readline(const char *prompt) {
ffffffffc02014c6:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02014c8:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc02014ca:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc02014cc:	4aa9                	li	s5,10
ffffffffc02014ce:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc02014d0:	00005b97          	auipc	s7,0x5
ffffffffc02014d4:	b70b8b93          	addi	s7,s7,-1168 # ffffffffc0206040 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02014d8:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc02014dc:	c4ffe0ef          	jal	ra,ffffffffc020012a <getchar>
        if (c < 0) {
ffffffffc02014e0:	00054a63          	bltz	a0,ffffffffc02014f4 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02014e4:	00a95a63          	bge	s2,a0,ffffffffc02014f8 <readline+0x54>
ffffffffc02014e8:	029a5263          	bge	s4,s1,ffffffffc020150c <readline+0x68>
        c = getchar();
ffffffffc02014ec:	c3ffe0ef          	jal	ra,ffffffffc020012a <getchar>
        if (c < 0) {
ffffffffc02014f0:	fe055ae3          	bgez	a0,ffffffffc02014e4 <readline+0x40>
            return NULL;
ffffffffc02014f4:	4501                	li	a0,0
ffffffffc02014f6:	a091                	j	ffffffffc020153a <readline+0x96>
        else if (c == '\b' && i > 0) {
ffffffffc02014f8:	03351463          	bne	a0,s3,ffffffffc0201520 <readline+0x7c>
ffffffffc02014fc:	e8a9                	bnez	s1,ffffffffc020154e <readline+0xaa>
        c = getchar();
ffffffffc02014fe:	c2dfe0ef          	jal	ra,ffffffffc020012a <getchar>
        if (c < 0) {
ffffffffc0201502:	fe0549e3          	bltz	a0,ffffffffc02014f4 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201506:	fea959e3          	bge	s2,a0,ffffffffc02014f8 <readline+0x54>
ffffffffc020150a:	4481                	li	s1,0
            cputchar(c);
ffffffffc020150c:	e42a                	sd	a0,8(sp)
ffffffffc020150e:	bdbfe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
            buf[i ++] = c;
ffffffffc0201512:	6522                	ld	a0,8(sp)
ffffffffc0201514:	009b87b3          	add	a5,s7,s1
ffffffffc0201518:	2485                	addiw	s1,s1,1
ffffffffc020151a:	00a78023          	sb	a0,0(a5)
ffffffffc020151e:	bf7d                	j	ffffffffc02014dc <readline+0x38>
        else if (c == '\n' || c == '\r') {
ffffffffc0201520:	01550463          	beq	a0,s5,ffffffffc0201528 <readline+0x84>
ffffffffc0201524:	fb651ce3          	bne	a0,s6,ffffffffc02014dc <readline+0x38>
            cputchar(c);
ffffffffc0201528:	bc1fe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
            buf[i] = '\0';
ffffffffc020152c:	00005517          	auipc	a0,0x5
ffffffffc0201530:	b1450513          	addi	a0,a0,-1260 # ffffffffc0206040 <buf>
ffffffffc0201534:	94aa                	add	s1,s1,a0
ffffffffc0201536:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc020153a:	60a6                	ld	ra,72(sp)
ffffffffc020153c:	6486                	ld	s1,64(sp)
ffffffffc020153e:	7962                	ld	s2,56(sp)
ffffffffc0201540:	79c2                	ld	s3,48(sp)
ffffffffc0201542:	7a22                	ld	s4,40(sp)
ffffffffc0201544:	7a82                	ld	s5,32(sp)
ffffffffc0201546:	6b62                	ld	s6,24(sp)
ffffffffc0201548:	6bc2                	ld	s7,16(sp)
ffffffffc020154a:	6161                	addi	sp,sp,80
ffffffffc020154c:	8082                	ret
            cputchar(c);
ffffffffc020154e:	4521                	li	a0,8
ffffffffc0201550:	b99fe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
            i --;
ffffffffc0201554:	34fd                	addiw	s1,s1,-1
ffffffffc0201556:	b759                	j	ffffffffc02014dc <readline+0x38>

ffffffffc0201558 <sbi_console_putchar>:
uint64_t SBI_REMOTE_SFENCE_VMA_ASID = 7;
uint64_t SBI_SHUTDOWN = 8;

uint64_t sbi_call(uint64_t sbi_type, uint64_t arg0, uint64_t arg1, uint64_t arg2) {
    uint64_t ret_val;
    __asm__ volatile (
ffffffffc0201558:	4781                	li	a5,0
ffffffffc020155a:	00005717          	auipc	a4,0x5
ffffffffc020155e:	aae73703          	ld	a4,-1362(a4) # ffffffffc0206008 <SBI_CONSOLE_PUTCHAR>
ffffffffc0201562:	88ba                	mv	a7,a4
ffffffffc0201564:	852a                	mv	a0,a0
ffffffffc0201566:	85be                	mv	a1,a5
ffffffffc0201568:	863e                	mv	a2,a5
ffffffffc020156a:	00000073          	ecall
ffffffffc020156e:	87aa                	mv	a5,a0
    return ret_val;
}

void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
}
ffffffffc0201570:	8082                	ret

ffffffffc0201572 <sbi_set_timer>:
    __asm__ volatile (
ffffffffc0201572:	4781                	li	a5,0
ffffffffc0201574:	00005717          	auipc	a4,0x5
ffffffffc0201578:	f0c73703          	ld	a4,-244(a4) # ffffffffc0206480 <SBI_SET_TIMER>
ffffffffc020157c:	88ba                	mv	a7,a4
ffffffffc020157e:	852a                	mv	a0,a0
ffffffffc0201580:	85be                	mv	a1,a5
ffffffffc0201582:	863e                	mv	a2,a5
ffffffffc0201584:	00000073          	ecall
ffffffffc0201588:	87aa                	mv	a5,a0

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
}
ffffffffc020158a:	8082                	ret

ffffffffc020158c <sbi_console_getchar>:
    __asm__ volatile (
ffffffffc020158c:	4501                	li	a0,0
ffffffffc020158e:	00005797          	auipc	a5,0x5
ffffffffc0201592:	a727b783          	ld	a5,-1422(a5) # ffffffffc0206000 <SBI_CONSOLE_GETCHAR>
ffffffffc0201596:	88be                	mv	a7,a5
ffffffffc0201598:	852a                	mv	a0,a0
ffffffffc020159a:	85aa                	mv	a1,a0
ffffffffc020159c:	862a                	mv	a2,a0
ffffffffc020159e:	00000073          	ecall
ffffffffc02015a2:	852a                	mv	a0,a0

int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
ffffffffc02015a4:	2501                	sext.w	a0,a0
ffffffffc02015a6:	8082                	ret

ffffffffc02015a8 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc02015a8:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc02015aa:	e589                	bnez	a1,ffffffffc02015b4 <strnlen+0xc>
ffffffffc02015ac:	a811                	j	ffffffffc02015c0 <strnlen+0x18>
        cnt ++;
ffffffffc02015ae:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc02015b0:	00f58863          	beq	a1,a5,ffffffffc02015c0 <strnlen+0x18>
ffffffffc02015b4:	00f50733          	add	a4,a0,a5
ffffffffc02015b8:	00074703          	lbu	a4,0(a4)
ffffffffc02015bc:	fb6d                	bnez	a4,ffffffffc02015ae <strnlen+0x6>
ffffffffc02015be:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc02015c0:	852e                	mv	a0,a1
ffffffffc02015c2:	8082                	ret

ffffffffc02015c4 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02015c4:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc02015c8:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02015cc:	cb89                	beqz	a5,ffffffffc02015de <strcmp+0x1a>
        s1 ++, s2 ++;
ffffffffc02015ce:	0505                	addi	a0,a0,1
ffffffffc02015d0:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02015d2:	fee789e3          	beq	a5,a4,ffffffffc02015c4 <strcmp>
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc02015d6:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc02015da:	9d19                	subw	a0,a0,a4
ffffffffc02015dc:	8082                	ret
ffffffffc02015de:	4501                	li	a0,0
ffffffffc02015e0:	bfed                	j	ffffffffc02015da <strcmp+0x16>

ffffffffc02015e2 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc02015e2:	00054783          	lbu	a5,0(a0)
ffffffffc02015e6:	c799                	beqz	a5,ffffffffc02015f4 <strchr+0x12>
        if (*s == c) {
ffffffffc02015e8:	00f58763          	beq	a1,a5,ffffffffc02015f6 <strchr+0x14>
    while (*s != '\0') {
ffffffffc02015ec:	00154783          	lbu	a5,1(a0)
            return (char *)s;
        }
        s ++;
ffffffffc02015f0:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc02015f2:	fbfd                	bnez	a5,ffffffffc02015e8 <strchr+0x6>
    }
    return NULL;
ffffffffc02015f4:	4501                	li	a0,0
}
ffffffffc02015f6:	8082                	ret

ffffffffc02015f8 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc02015f8:	ca01                	beqz	a2,ffffffffc0201608 <memset+0x10>
ffffffffc02015fa:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc02015fc:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc02015fe:	0785                	addi	a5,a5,1
ffffffffc0201600:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0201604:	fec79de3          	bne	a5,a2,ffffffffc02015fe <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0201608:	8082                	ret
