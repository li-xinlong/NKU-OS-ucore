
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200000:	c02092b7          	lui	t0,0xc0209
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
ffffffffc0200024:	c0209137          	lui	sp,0xc0209

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

int kern_init(void)
{
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc0200032:	0000a517          	auipc	a0,0xa
ffffffffc0200036:	00e50513          	addi	a0,a0,14 # ffffffffc020a040 <ide>
ffffffffc020003a:	00011617          	auipc	a2,0x11
ffffffffc020003e:	53260613          	addi	a2,a2,1330 # ffffffffc021156c <end>
{
ffffffffc0200042:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200044:	8e09                	sub	a2,a2,a0
ffffffffc0200046:	4581                	li	a1,0
{
ffffffffc0200048:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004a:	432040ef          	jal	ra,ffffffffc020447c <memset>

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc020004e:	00004597          	auipc	a1,0x4
ffffffffc0200052:	45a58593          	addi	a1,a1,1114 # ffffffffc02044a8 <etext+0x2>
ffffffffc0200056:	00004517          	auipc	a0,0x4
ffffffffc020005a:	47250513          	addi	a0,a0,1138 # ffffffffc02044c8 <etext+0x22>
ffffffffc020005e:	05c000ef          	jal	ra,ffffffffc02000ba <cprintf>

    print_kerninfo();
ffffffffc0200062:	0a0000ef          	jal	ra,ffffffffc0200102 <print_kerninfo>

    // grade_backtrace();

    pmm_init(); // init physical memory management
ffffffffc0200066:	291010ef          	jal	ra,ffffffffc0201af6 <pmm_init>

    idt_init(); // init interrupt descriptor table
ffffffffc020006a:	4fa000ef          	jal	ra,ffffffffc0200564 <idt_init>

    vmm_init(); // init virtual memory management
ffffffffc020006e:	6da030ef          	jal	ra,ffffffffc0203748 <vmm_init>

    ide_init();  // init ide devices
ffffffffc0200072:	420000ef          	jal	ra,ffffffffc0200492 <ide_init>
    swap_init(); // init swap
ffffffffc0200076:	0e5020ef          	jal	ra,ffffffffc020295a <swap_init>

    clock_init(); // init clock interrupt
ffffffffc020007a:	356000ef          	jal	ra,ffffffffc02003d0 <clock_init>
    // intr_enable();              // enable irq interrupt

    /* do nothing */
    while (1)
ffffffffc020007e:	a001                	j	ffffffffc020007e <kern_init+0x4c>

ffffffffc0200080 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc0200080:	1141                	addi	sp,sp,-16
ffffffffc0200082:	e022                	sd	s0,0(sp)
ffffffffc0200084:	e406                	sd	ra,8(sp)
ffffffffc0200086:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc0200088:	39a000ef          	jal	ra,ffffffffc0200422 <cons_putc>
    (*cnt) ++;
ffffffffc020008c:	401c                	lw	a5,0(s0)
}
ffffffffc020008e:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc0200090:	2785                	addiw	a5,a5,1
ffffffffc0200092:	c01c                	sw	a5,0(s0)
}
ffffffffc0200094:	6402                	ld	s0,0(sp)
ffffffffc0200096:	0141                	addi	sp,sp,16
ffffffffc0200098:	8082                	ret

ffffffffc020009a <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc020009a:	1101                	addi	sp,sp,-32
ffffffffc020009c:	862a                	mv	a2,a0
ffffffffc020009e:	86ae                	mv	a3,a1
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000a0:	00000517          	auipc	a0,0x0
ffffffffc02000a4:	fe050513          	addi	a0,a0,-32 # ffffffffc0200080 <cputch>
ffffffffc02000a8:	006c                	addi	a1,sp,12
vcprintf(const char *fmt, va_list ap) {
ffffffffc02000aa:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc02000ac:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000ae:	71d030ef          	jal	ra,ffffffffc0203fca <vprintfmt>
    return cnt;
}
ffffffffc02000b2:	60e2                	ld	ra,24(sp)
ffffffffc02000b4:	4532                	lw	a0,12(sp)
ffffffffc02000b6:	6105                	addi	sp,sp,32
ffffffffc02000b8:	8082                	ret

ffffffffc02000ba <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc02000ba:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc02000bc:	02810313          	addi	t1,sp,40 # ffffffffc0209028 <boot_page_table_sv39+0x28>
cprintf(const char *fmt, ...) {
ffffffffc02000c0:	8e2a                	mv	t3,a0
ffffffffc02000c2:	f42e                	sd	a1,40(sp)
ffffffffc02000c4:	f832                	sd	a2,48(sp)
ffffffffc02000c6:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000c8:	00000517          	auipc	a0,0x0
ffffffffc02000cc:	fb850513          	addi	a0,a0,-72 # ffffffffc0200080 <cputch>
ffffffffc02000d0:	004c                	addi	a1,sp,4
ffffffffc02000d2:	869a                	mv	a3,t1
ffffffffc02000d4:	8672                	mv	a2,t3
cprintf(const char *fmt, ...) {
ffffffffc02000d6:	ec06                	sd	ra,24(sp)
ffffffffc02000d8:	e0ba                	sd	a4,64(sp)
ffffffffc02000da:	e4be                	sd	a5,72(sp)
ffffffffc02000dc:	e8c2                	sd	a6,80(sp)
ffffffffc02000de:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc02000e0:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc02000e2:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000e4:	6e7030ef          	jal	ra,ffffffffc0203fca <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02000e8:	60e2                	ld	ra,24(sp)
ffffffffc02000ea:	4512                	lw	a0,4(sp)
ffffffffc02000ec:	6125                	addi	sp,sp,96
ffffffffc02000ee:	8082                	ret

ffffffffc02000f0 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc02000f0:	ae0d                	j	ffffffffc0200422 <cons_putc>

ffffffffc02000f2 <getchar>:
    return cnt;
}

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc02000f2:	1141                	addi	sp,sp,-16
ffffffffc02000f4:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc02000f6:	360000ef          	jal	ra,ffffffffc0200456 <cons_getc>
ffffffffc02000fa:	dd75                	beqz	a0,ffffffffc02000f6 <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc02000fc:	60a2                	ld	ra,8(sp)
ffffffffc02000fe:	0141                	addi	sp,sp,16
ffffffffc0200100:	8082                	ret

ffffffffc0200102 <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc0200102:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc0200104:	00004517          	auipc	a0,0x4
ffffffffc0200108:	3cc50513          	addi	a0,a0,972 # ffffffffc02044d0 <etext+0x2a>
void print_kerninfo(void) {
ffffffffc020010c:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc020010e:	fadff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc0200112:	00000597          	auipc	a1,0x0
ffffffffc0200116:	f2058593          	addi	a1,a1,-224 # ffffffffc0200032 <kern_init>
ffffffffc020011a:	00004517          	auipc	a0,0x4
ffffffffc020011e:	3d650513          	addi	a0,a0,982 # ffffffffc02044f0 <etext+0x4a>
ffffffffc0200122:	f99ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc0200126:	00004597          	auipc	a1,0x4
ffffffffc020012a:	38058593          	addi	a1,a1,896 # ffffffffc02044a6 <etext>
ffffffffc020012e:	00004517          	auipc	a0,0x4
ffffffffc0200132:	3e250513          	addi	a0,a0,994 # ffffffffc0204510 <etext+0x6a>
ffffffffc0200136:	f85ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc020013a:	0000a597          	auipc	a1,0xa
ffffffffc020013e:	f0658593          	addi	a1,a1,-250 # ffffffffc020a040 <ide>
ffffffffc0200142:	00004517          	auipc	a0,0x4
ffffffffc0200146:	3ee50513          	addi	a0,a0,1006 # ffffffffc0204530 <etext+0x8a>
ffffffffc020014a:	f71ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc020014e:	00011597          	auipc	a1,0x11
ffffffffc0200152:	41e58593          	addi	a1,a1,1054 # ffffffffc021156c <end>
ffffffffc0200156:	00004517          	auipc	a0,0x4
ffffffffc020015a:	3fa50513          	addi	a0,a0,1018 # ffffffffc0204550 <etext+0xaa>
ffffffffc020015e:	f5dff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc0200162:	00012597          	auipc	a1,0x12
ffffffffc0200166:	80958593          	addi	a1,a1,-2039 # ffffffffc021196b <end+0x3ff>
ffffffffc020016a:	00000797          	auipc	a5,0x0
ffffffffc020016e:	ec878793          	addi	a5,a5,-312 # ffffffffc0200032 <kern_init>
ffffffffc0200172:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200176:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc020017a:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc020017c:	3ff5f593          	andi	a1,a1,1023
ffffffffc0200180:	95be                	add	a1,a1,a5
ffffffffc0200182:	85a9                	srai	a1,a1,0xa
ffffffffc0200184:	00004517          	auipc	a0,0x4
ffffffffc0200188:	3ec50513          	addi	a0,a0,1004 # ffffffffc0204570 <etext+0xca>
}
ffffffffc020018c:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc020018e:	b735                	j	ffffffffc02000ba <cprintf>

ffffffffc0200190 <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc0200190:	1141                	addi	sp,sp,-16

    panic("Not Implemented!");
ffffffffc0200192:	00004617          	auipc	a2,0x4
ffffffffc0200196:	40e60613          	addi	a2,a2,1038 # ffffffffc02045a0 <etext+0xfa>
ffffffffc020019a:	04e00593          	li	a1,78
ffffffffc020019e:	00004517          	auipc	a0,0x4
ffffffffc02001a2:	41a50513          	addi	a0,a0,1050 # ffffffffc02045b8 <etext+0x112>
void print_stackframe(void) {
ffffffffc02001a6:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc02001a8:	1cc000ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc02001ac <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02001ac:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02001ae:	00004617          	auipc	a2,0x4
ffffffffc02001b2:	42260613          	addi	a2,a2,1058 # ffffffffc02045d0 <etext+0x12a>
ffffffffc02001b6:	00004597          	auipc	a1,0x4
ffffffffc02001ba:	43a58593          	addi	a1,a1,1082 # ffffffffc02045f0 <etext+0x14a>
ffffffffc02001be:	00004517          	auipc	a0,0x4
ffffffffc02001c2:	43a50513          	addi	a0,a0,1082 # ffffffffc02045f8 <etext+0x152>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02001c6:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02001c8:	ef3ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc02001cc:	00004617          	auipc	a2,0x4
ffffffffc02001d0:	43c60613          	addi	a2,a2,1084 # ffffffffc0204608 <etext+0x162>
ffffffffc02001d4:	00004597          	auipc	a1,0x4
ffffffffc02001d8:	45c58593          	addi	a1,a1,1116 # ffffffffc0204630 <etext+0x18a>
ffffffffc02001dc:	00004517          	auipc	a0,0x4
ffffffffc02001e0:	41c50513          	addi	a0,a0,1052 # ffffffffc02045f8 <etext+0x152>
ffffffffc02001e4:	ed7ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc02001e8:	00004617          	auipc	a2,0x4
ffffffffc02001ec:	45860613          	addi	a2,a2,1112 # ffffffffc0204640 <etext+0x19a>
ffffffffc02001f0:	00004597          	auipc	a1,0x4
ffffffffc02001f4:	47058593          	addi	a1,a1,1136 # ffffffffc0204660 <etext+0x1ba>
ffffffffc02001f8:	00004517          	auipc	a0,0x4
ffffffffc02001fc:	40050513          	addi	a0,a0,1024 # ffffffffc02045f8 <etext+0x152>
ffffffffc0200200:	ebbff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    }
    return 0;
}
ffffffffc0200204:	60a2                	ld	ra,8(sp)
ffffffffc0200206:	4501                	li	a0,0
ffffffffc0200208:	0141                	addi	sp,sp,16
ffffffffc020020a:	8082                	ret

ffffffffc020020c <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc020020c:	1141                	addi	sp,sp,-16
ffffffffc020020e:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc0200210:	ef3ff0ef          	jal	ra,ffffffffc0200102 <print_kerninfo>
    return 0;
}
ffffffffc0200214:	60a2                	ld	ra,8(sp)
ffffffffc0200216:	4501                	li	a0,0
ffffffffc0200218:	0141                	addi	sp,sp,16
ffffffffc020021a:	8082                	ret

ffffffffc020021c <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc020021c:	1141                	addi	sp,sp,-16
ffffffffc020021e:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc0200220:	f71ff0ef          	jal	ra,ffffffffc0200190 <print_stackframe>
    return 0;
}
ffffffffc0200224:	60a2                	ld	ra,8(sp)
ffffffffc0200226:	4501                	li	a0,0
ffffffffc0200228:	0141                	addi	sp,sp,16
ffffffffc020022a:	8082                	ret

ffffffffc020022c <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc020022c:	7115                	addi	sp,sp,-224
ffffffffc020022e:	ed5e                	sd	s7,152(sp)
ffffffffc0200230:	8baa                	mv	s7,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200232:	00004517          	auipc	a0,0x4
ffffffffc0200236:	43e50513          	addi	a0,a0,1086 # ffffffffc0204670 <etext+0x1ca>
kmonitor(struct trapframe *tf) {
ffffffffc020023a:	ed86                	sd	ra,216(sp)
ffffffffc020023c:	e9a2                	sd	s0,208(sp)
ffffffffc020023e:	e5a6                	sd	s1,200(sp)
ffffffffc0200240:	e1ca                	sd	s2,192(sp)
ffffffffc0200242:	fd4e                	sd	s3,184(sp)
ffffffffc0200244:	f952                	sd	s4,176(sp)
ffffffffc0200246:	f556                	sd	s5,168(sp)
ffffffffc0200248:	f15a                	sd	s6,160(sp)
ffffffffc020024a:	e962                	sd	s8,144(sp)
ffffffffc020024c:	e566                	sd	s9,136(sp)
ffffffffc020024e:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200250:	e6bff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc0200254:	00004517          	auipc	a0,0x4
ffffffffc0200258:	44450513          	addi	a0,a0,1092 # ffffffffc0204698 <etext+0x1f2>
ffffffffc020025c:	e5fff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    if (tf != NULL) {
ffffffffc0200260:	000b8563          	beqz	s7,ffffffffc020026a <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc0200264:	855e                	mv	a0,s7
ffffffffc0200266:	4e8000ef          	jal	ra,ffffffffc020074e <print_trapframe>
ffffffffc020026a:	00004c17          	auipc	s8,0x4
ffffffffc020026e:	496c0c13          	addi	s8,s8,1174 # ffffffffc0204700 <commands>
        if ((buf = readline("")) != NULL) {
ffffffffc0200272:	00006917          	auipc	s2,0x6
ffffffffc0200276:	8ee90913          	addi	s2,s2,-1810 # ffffffffc0205b60 <default_pmm_manager+0x950>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020027a:	00004497          	auipc	s1,0x4
ffffffffc020027e:	44648493          	addi	s1,s1,1094 # ffffffffc02046c0 <etext+0x21a>
        if (argc == MAXARGS - 1) {
ffffffffc0200282:	49bd                	li	s3,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200284:	00004b17          	auipc	s6,0x4
ffffffffc0200288:	444b0b13          	addi	s6,s6,1092 # ffffffffc02046c8 <etext+0x222>
        argv[argc ++] = buf;
ffffffffc020028c:	00004a17          	auipc	s4,0x4
ffffffffc0200290:	364a0a13          	addi	s4,s4,868 # ffffffffc02045f0 <etext+0x14a>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200294:	4a8d                	li	s5,3
        if ((buf = readline("")) != NULL) {
ffffffffc0200296:	854a                	mv	a0,s2
ffffffffc0200298:	0b4040ef          	jal	ra,ffffffffc020434c <readline>
ffffffffc020029c:	842a                	mv	s0,a0
ffffffffc020029e:	dd65                	beqz	a0,ffffffffc0200296 <kmonitor+0x6a>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002a0:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc02002a4:	4c81                	li	s9,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002a6:	e1bd                	bnez	a1,ffffffffc020030c <kmonitor+0xe0>
    if (argc == 0) {
ffffffffc02002a8:	fe0c87e3          	beqz	s9,ffffffffc0200296 <kmonitor+0x6a>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002ac:	6582                	ld	a1,0(sp)
ffffffffc02002ae:	00004d17          	auipc	s10,0x4
ffffffffc02002b2:	452d0d13          	addi	s10,s10,1106 # ffffffffc0204700 <commands>
        argv[argc ++] = buf;
ffffffffc02002b6:	8552                	mv	a0,s4
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002b8:	4401                	li	s0,0
ffffffffc02002ba:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002bc:	18c040ef          	jal	ra,ffffffffc0204448 <strcmp>
ffffffffc02002c0:	c919                	beqz	a0,ffffffffc02002d6 <kmonitor+0xaa>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002c2:	2405                	addiw	s0,s0,1
ffffffffc02002c4:	0b540063          	beq	s0,s5,ffffffffc0200364 <kmonitor+0x138>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002c8:	000d3503          	ld	a0,0(s10)
ffffffffc02002cc:	6582                	ld	a1,0(sp)
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002ce:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002d0:	178040ef          	jal	ra,ffffffffc0204448 <strcmp>
ffffffffc02002d4:	f57d                	bnez	a0,ffffffffc02002c2 <kmonitor+0x96>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc02002d6:	00141793          	slli	a5,s0,0x1
ffffffffc02002da:	97a2                	add	a5,a5,s0
ffffffffc02002dc:	078e                	slli	a5,a5,0x3
ffffffffc02002de:	97e2                	add	a5,a5,s8
ffffffffc02002e0:	6b9c                	ld	a5,16(a5)
ffffffffc02002e2:	865e                	mv	a2,s7
ffffffffc02002e4:	002c                	addi	a1,sp,8
ffffffffc02002e6:	fffc851b          	addiw	a0,s9,-1
ffffffffc02002ea:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc02002ec:	fa0555e3          	bgez	a0,ffffffffc0200296 <kmonitor+0x6a>
}
ffffffffc02002f0:	60ee                	ld	ra,216(sp)
ffffffffc02002f2:	644e                	ld	s0,208(sp)
ffffffffc02002f4:	64ae                	ld	s1,200(sp)
ffffffffc02002f6:	690e                	ld	s2,192(sp)
ffffffffc02002f8:	79ea                	ld	s3,184(sp)
ffffffffc02002fa:	7a4a                	ld	s4,176(sp)
ffffffffc02002fc:	7aaa                	ld	s5,168(sp)
ffffffffc02002fe:	7b0a                	ld	s6,160(sp)
ffffffffc0200300:	6bea                	ld	s7,152(sp)
ffffffffc0200302:	6c4a                	ld	s8,144(sp)
ffffffffc0200304:	6caa                	ld	s9,136(sp)
ffffffffc0200306:	6d0a                	ld	s10,128(sp)
ffffffffc0200308:	612d                	addi	sp,sp,224
ffffffffc020030a:	8082                	ret
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020030c:	8526                	mv	a0,s1
ffffffffc020030e:	158040ef          	jal	ra,ffffffffc0204466 <strchr>
ffffffffc0200312:	c901                	beqz	a0,ffffffffc0200322 <kmonitor+0xf6>
ffffffffc0200314:	00144583          	lbu	a1,1(s0)
            *buf ++ = '\0';
ffffffffc0200318:	00040023          	sb	zero,0(s0)
ffffffffc020031c:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020031e:	d5c9                	beqz	a1,ffffffffc02002a8 <kmonitor+0x7c>
ffffffffc0200320:	b7f5                	j	ffffffffc020030c <kmonitor+0xe0>
        if (*buf == '\0') {
ffffffffc0200322:	00044783          	lbu	a5,0(s0)
ffffffffc0200326:	d3c9                	beqz	a5,ffffffffc02002a8 <kmonitor+0x7c>
        if (argc == MAXARGS - 1) {
ffffffffc0200328:	033c8963          	beq	s9,s3,ffffffffc020035a <kmonitor+0x12e>
        argv[argc ++] = buf;
ffffffffc020032c:	003c9793          	slli	a5,s9,0x3
ffffffffc0200330:	0118                	addi	a4,sp,128
ffffffffc0200332:	97ba                	add	a5,a5,a4
ffffffffc0200334:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200338:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc020033c:	2c85                	addiw	s9,s9,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc020033e:	e591                	bnez	a1,ffffffffc020034a <kmonitor+0x11e>
ffffffffc0200340:	b7b5                	j	ffffffffc02002ac <kmonitor+0x80>
ffffffffc0200342:	00144583          	lbu	a1,1(s0)
            buf ++;
ffffffffc0200346:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200348:	d1a5                	beqz	a1,ffffffffc02002a8 <kmonitor+0x7c>
ffffffffc020034a:	8526                	mv	a0,s1
ffffffffc020034c:	11a040ef          	jal	ra,ffffffffc0204466 <strchr>
ffffffffc0200350:	d96d                	beqz	a0,ffffffffc0200342 <kmonitor+0x116>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200352:	00044583          	lbu	a1,0(s0)
ffffffffc0200356:	d9a9                	beqz	a1,ffffffffc02002a8 <kmonitor+0x7c>
ffffffffc0200358:	bf55                	j	ffffffffc020030c <kmonitor+0xe0>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc020035a:	45c1                	li	a1,16
ffffffffc020035c:	855a                	mv	a0,s6
ffffffffc020035e:	d5dff0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0200362:	b7e9                	j	ffffffffc020032c <kmonitor+0x100>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc0200364:	6582                	ld	a1,0(sp)
ffffffffc0200366:	00004517          	auipc	a0,0x4
ffffffffc020036a:	38250513          	addi	a0,a0,898 # ffffffffc02046e8 <etext+0x242>
ffffffffc020036e:	d4dff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    return 0;
ffffffffc0200372:	b715                	j	ffffffffc0200296 <kmonitor+0x6a>

ffffffffc0200374 <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc0200374:	00011317          	auipc	t1,0x11
ffffffffc0200378:	18430313          	addi	t1,t1,388 # ffffffffc02114f8 <is_panic>
ffffffffc020037c:	00032e03          	lw	t3,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc0200380:	715d                	addi	sp,sp,-80
ffffffffc0200382:	ec06                	sd	ra,24(sp)
ffffffffc0200384:	e822                	sd	s0,16(sp)
ffffffffc0200386:	f436                	sd	a3,40(sp)
ffffffffc0200388:	f83a                	sd	a4,48(sp)
ffffffffc020038a:	fc3e                	sd	a5,56(sp)
ffffffffc020038c:	e0c2                	sd	a6,64(sp)
ffffffffc020038e:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc0200390:	020e1a63          	bnez	t3,ffffffffc02003c4 <__panic+0x50>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc0200394:	4785                	li	a5,1
ffffffffc0200396:	00f32023          	sw	a5,0(t1)

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
ffffffffc020039a:	8432                	mv	s0,a2
ffffffffc020039c:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc020039e:	862e                	mv	a2,a1
ffffffffc02003a0:	85aa                	mv	a1,a0
ffffffffc02003a2:	00004517          	auipc	a0,0x4
ffffffffc02003a6:	3a650513          	addi	a0,a0,934 # ffffffffc0204748 <commands+0x48>
    va_start(ap, fmt);
ffffffffc02003aa:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003ac:	d0fff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    vcprintf(fmt, ap);
ffffffffc02003b0:	65a2                	ld	a1,8(sp)
ffffffffc02003b2:	8522                	mv	a0,s0
ffffffffc02003b4:	ce7ff0ef          	jal	ra,ffffffffc020009a <vcprintf>
    cprintf("\n");
ffffffffc02003b8:	00005517          	auipc	a0,0x5
ffffffffc02003bc:	2d050513          	addi	a0,a0,720 # ffffffffc0205688 <default_pmm_manager+0x478>
ffffffffc02003c0:	cfbff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    va_end(ap);

panic_dead:
    intr_disable();
ffffffffc02003c4:	12a000ef          	jal	ra,ffffffffc02004ee <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc02003c8:	4501                	li	a0,0
ffffffffc02003ca:	e63ff0ef          	jal	ra,ffffffffc020022c <kmonitor>
    while (1) {
ffffffffc02003ce:	bfed                	j	ffffffffc02003c8 <__panic+0x54>

ffffffffc02003d0 <clock_init>:
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    // divided by 500 when using Spike(2MHz)
    // divided by 100 when using QEMU(10MHz)
    timebase = 1e7 / 100;
ffffffffc02003d0:	67e1                	lui	a5,0x18
ffffffffc02003d2:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0xffffffffc01e7960>
ffffffffc02003d6:	00011717          	auipc	a4,0x11
ffffffffc02003da:	12f73923          	sd	a5,306(a4) # ffffffffc0211508 <timebase>
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc02003de:	c0102573          	rdtime	a0
static inline void sbi_set_timer(uint64_t stime_value)
{
#if __riscv_xlen == 32
	SBI_CALL_2(SBI_SET_TIMER, stime_value, stime_value >> 32);
#else
	SBI_CALL_1(SBI_SET_TIMER, stime_value);
ffffffffc02003e2:	4581                	li	a1,0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc02003e4:	953e                	add	a0,a0,a5
ffffffffc02003e6:	4601                	li	a2,0
ffffffffc02003e8:	4881                	li	a7,0
ffffffffc02003ea:	00000073          	ecall
    set_csr(sie, MIP_STIP);
ffffffffc02003ee:	02000793          	li	a5,32
ffffffffc02003f2:	1047a7f3          	csrrs	a5,sie,a5
    cprintf("++ setup timer interrupts\n");
ffffffffc02003f6:	00004517          	auipc	a0,0x4
ffffffffc02003fa:	37250513          	addi	a0,a0,882 # ffffffffc0204768 <commands+0x68>
    ticks = 0;
ffffffffc02003fe:	00011797          	auipc	a5,0x11
ffffffffc0200402:	1007b123          	sd	zero,258(a5) # ffffffffc0211500 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc0200406:	b955                	j	ffffffffc02000ba <cprintf>

ffffffffc0200408 <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200408:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc020040c:	00011797          	auipc	a5,0x11
ffffffffc0200410:	0fc7b783          	ld	a5,252(a5) # ffffffffc0211508 <timebase>
ffffffffc0200414:	953e                	add	a0,a0,a5
ffffffffc0200416:	4581                	li	a1,0
ffffffffc0200418:	4601                	li	a2,0
ffffffffc020041a:	4881                	li	a7,0
ffffffffc020041c:	00000073          	ecall
ffffffffc0200420:	8082                	ret

ffffffffc0200422 <cons_putc>:
#include <intr.h>
#include <mmu.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200422:	100027f3          	csrr	a5,sstatus
ffffffffc0200426:	8b89                	andi	a5,a5,2
	SBI_CALL_1(SBI_CONSOLE_PUTCHAR, ch);
ffffffffc0200428:	0ff57513          	zext.b	a0,a0
ffffffffc020042c:	e799                	bnez	a5,ffffffffc020043a <cons_putc+0x18>
ffffffffc020042e:	4581                	li	a1,0
ffffffffc0200430:	4601                	li	a2,0
ffffffffc0200432:	4885                	li	a7,1
ffffffffc0200434:	00000073          	ecall
    }
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
ffffffffc0200438:	8082                	ret

/* cons_init - initializes the console devices */
void cons_init(void) {}

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) {
ffffffffc020043a:	1101                	addi	sp,sp,-32
ffffffffc020043c:	ec06                	sd	ra,24(sp)
ffffffffc020043e:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0200440:	0ae000ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc0200444:	6522                	ld	a0,8(sp)
ffffffffc0200446:	4581                	li	a1,0
ffffffffc0200448:	4601                	li	a2,0
ffffffffc020044a:	4885                	li	a7,1
ffffffffc020044c:	00000073          	ecall
    local_intr_save(intr_flag);
    {
        sbi_console_putchar((unsigned char)c);
    }
    local_intr_restore(intr_flag);
}
ffffffffc0200450:	60e2                	ld	ra,24(sp)
ffffffffc0200452:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0200454:	a851                	j	ffffffffc02004e8 <intr_enable>

ffffffffc0200456 <cons_getc>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200456:	100027f3          	csrr	a5,sstatus
ffffffffc020045a:	8b89                	andi	a5,a5,2
ffffffffc020045c:	eb89                	bnez	a5,ffffffffc020046e <cons_getc+0x18>
	return SBI_CALL_0(SBI_CONSOLE_GETCHAR);
ffffffffc020045e:	4501                	li	a0,0
ffffffffc0200460:	4581                	li	a1,0
ffffffffc0200462:	4601                	li	a2,0
ffffffffc0200464:	4889                	li	a7,2
ffffffffc0200466:	00000073          	ecall
ffffffffc020046a:	2501                	sext.w	a0,a0
    {
        c = sbi_console_getchar();
    }
    local_intr_restore(intr_flag);
    return c;
}
ffffffffc020046c:	8082                	ret
int cons_getc(void) {
ffffffffc020046e:	1101                	addi	sp,sp,-32
ffffffffc0200470:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc0200472:	07c000ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc0200476:	4501                	li	a0,0
ffffffffc0200478:	4581                	li	a1,0
ffffffffc020047a:	4601                	li	a2,0
ffffffffc020047c:	4889                	li	a7,2
ffffffffc020047e:	00000073          	ecall
ffffffffc0200482:	2501                	sext.w	a0,a0
ffffffffc0200484:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0200486:	062000ef          	jal	ra,ffffffffc02004e8 <intr_enable>
}
ffffffffc020048a:	60e2                	ld	ra,24(sp)
ffffffffc020048c:	6522                	ld	a0,8(sp)
ffffffffc020048e:	6105                	addi	sp,sp,32
ffffffffc0200490:	8082                	ret

ffffffffc0200492 <ide_init>:
#include <string.h>
#include <trap.h>
#include <riscv.h>

// 初始化 IDE 设备
void ide_init(void) {}
ffffffffc0200492:	8082                	ret

ffffffffc0200494 <ide_device_valid>:
#define MAX_DISK_NSECS 56
// 静态字符数组，用于模拟磁盘存储空间
static char ide[MAX_DISK_NSECS * SECTSIZE];

// 检查给定的 IDE 设备编号是否有效
bool ide_device_valid(unsigned short ideno) { return ideno < MAX_IDE; }
ffffffffc0200494:	00253513          	sltiu	a0,a0,2
ffffffffc0200498:	8082                	ret

ffffffffc020049a <ide_device_size>:

// 返回给定 IDE 设备的大小（扇区数量）
size_t ide_device_size(unsigned short ideno) { return MAX_DISK_NSECS; }
ffffffffc020049a:	03800513          	li	a0,56
ffffffffc020049e:	8082                	ret

ffffffffc02004a0 <ide_read_secs>:
int ide_read_secs(unsigned short ideno, uint32_t secno, void *dst,
                  size_t nsecs) {
    // 计算读取数据的起始偏移量
    int iobase = secno * SECTSIZE;
    // 从模拟的磁盘存储空间中拷贝数据到目标缓冲区
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc02004a0:	0000a797          	auipc	a5,0xa
ffffffffc02004a4:	ba078793          	addi	a5,a5,-1120 # ffffffffc020a040 <ide>
    int iobase = secno * SECTSIZE;
ffffffffc02004a8:	0095959b          	slliw	a1,a1,0x9
                  size_t nsecs) {
ffffffffc02004ac:	1141                	addi	sp,sp,-16
ffffffffc02004ae:	8532                	mv	a0,a2
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc02004b0:	95be                	add	a1,a1,a5
ffffffffc02004b2:	00969613          	slli	a2,a3,0x9
                  size_t nsecs) {
ffffffffc02004b6:	e406                	sd	ra,8(sp)
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc02004b8:	7d7030ef          	jal	ra,ffffffffc020448e <memcpy>
    return 0;
}
ffffffffc02004bc:	60a2                	ld	ra,8(sp)
ffffffffc02004be:	4501                	li	a0,0
ffffffffc02004c0:	0141                	addi	sp,sp,16
ffffffffc02004c2:	8082                	ret

ffffffffc02004c4 <ide_write_secs>:

// 将数据从指定的缓冲区写入到指定的 IDE 设备扇区
int ide_write_secs(unsigned short ideno, uint32_t secno, const void *src,
                   size_t nsecs) {
    // 计算写入数据的起始偏移量
    int iobase = secno * SECTSIZE;
ffffffffc02004c4:	0095979b          	slliw	a5,a1,0x9
    // 将数据从源缓冲区拷贝到模拟的磁盘存储空间
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc02004c8:	0000a517          	auipc	a0,0xa
ffffffffc02004cc:	b7850513          	addi	a0,a0,-1160 # ffffffffc020a040 <ide>
                   size_t nsecs) {
ffffffffc02004d0:	1141                	addi	sp,sp,-16
ffffffffc02004d2:	85b2                	mv	a1,a2
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc02004d4:	953e                	add	a0,a0,a5
ffffffffc02004d6:	00969613          	slli	a2,a3,0x9
                   size_t nsecs) {
ffffffffc02004da:	e406                	sd	ra,8(sp)
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc02004dc:	7b3030ef          	jal	ra,ffffffffc020448e <memcpy>
    return 0;
}
ffffffffc02004e0:	60a2                	ld	ra,8(sp)
ffffffffc02004e2:	4501                	li	a0,0
ffffffffc02004e4:	0141                	addi	sp,sp,16
ffffffffc02004e6:	8082                	ret

ffffffffc02004e8 <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc02004e8:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc02004ec:	8082                	ret

ffffffffc02004ee <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc02004ee:	100177f3          	csrrci	a5,sstatus,2
ffffffffc02004f2:	8082                	ret

ffffffffc02004f4 <pgfault_handler>:
    set_csr(sstatus, SSTATUS_SUM);
}

/* trap_in_kernel - test if trap happened in kernel */
bool trap_in_kernel(struct trapframe *tf) {
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02004f4:	10053783          	ld	a5,256(a0)
    cprintf("page fault at 0x%08x: %c/%c\n", tf->badvaddr,
            trap_in_kernel(tf) ? 'K' : 'U',
            tf->cause == CAUSE_STORE_PAGE_FAULT ? 'W' : 'R');
}

static int pgfault_handler(struct trapframe *tf) {
ffffffffc02004f8:	1141                	addi	sp,sp,-16
ffffffffc02004fa:	e022                	sd	s0,0(sp)
ffffffffc02004fc:	e406                	sd	ra,8(sp)
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02004fe:	1007f793          	andi	a5,a5,256
    cprintf("page fault at 0x%08x: %c/%c\n", tf->badvaddr,
ffffffffc0200502:	11053583          	ld	a1,272(a0)
static int pgfault_handler(struct trapframe *tf) {
ffffffffc0200506:	842a                	mv	s0,a0
    cprintf("page fault at 0x%08x: %c/%c\n", tf->badvaddr,
ffffffffc0200508:	05500613          	li	a2,85
ffffffffc020050c:	c399                	beqz	a5,ffffffffc0200512 <pgfault_handler+0x1e>
ffffffffc020050e:	04b00613          	li	a2,75
ffffffffc0200512:	11843703          	ld	a4,280(s0)
ffffffffc0200516:	47bd                	li	a5,15
ffffffffc0200518:	05700693          	li	a3,87
ffffffffc020051c:	00f70463          	beq	a4,a5,ffffffffc0200524 <pgfault_handler+0x30>
ffffffffc0200520:	05200693          	li	a3,82
ffffffffc0200524:	00004517          	auipc	a0,0x4
ffffffffc0200528:	26450513          	addi	a0,a0,612 # ffffffffc0204788 <commands+0x88>
ffffffffc020052c:	b8fff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    extern struct mm_struct *check_mm_struct;
    print_pgfault(tf);
    if (check_mm_struct != NULL) {
ffffffffc0200530:	00011517          	auipc	a0,0x11
ffffffffc0200534:	03053503          	ld	a0,48(a0) # ffffffffc0211560 <check_mm_struct>
ffffffffc0200538:	c911                	beqz	a0,ffffffffc020054c <pgfault_handler+0x58>
        return do_pgfault(check_mm_struct, tf->cause, tf->badvaddr);
ffffffffc020053a:	11043603          	ld	a2,272(s0)
ffffffffc020053e:	11843583          	ld	a1,280(s0)
    }
    panic("unhandled page fault.\n");
}
ffffffffc0200542:	6402                	ld	s0,0(sp)
ffffffffc0200544:	60a2                	ld	ra,8(sp)
ffffffffc0200546:	0141                	addi	sp,sp,16
        return do_pgfault(check_mm_struct, tf->cause, tf->badvaddr);
ffffffffc0200548:	7d80306f          	j	ffffffffc0203d20 <do_pgfault>
    panic("unhandled page fault.\n");
ffffffffc020054c:	00004617          	auipc	a2,0x4
ffffffffc0200550:	25c60613          	addi	a2,a2,604 # ffffffffc02047a8 <commands+0xa8>
ffffffffc0200554:	07900593          	li	a1,121
ffffffffc0200558:	00004517          	auipc	a0,0x4
ffffffffc020055c:	26850513          	addi	a0,a0,616 # ffffffffc02047c0 <commands+0xc0>
ffffffffc0200560:	e15ff0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0200564 <idt_init>:
    write_csr(sscratch, 0);
ffffffffc0200564:	14005073          	csrwi	sscratch,0
    write_csr(stvec, &__alltraps);
ffffffffc0200568:	00000797          	auipc	a5,0x0
ffffffffc020056c:	4c878793          	addi	a5,a5,1224 # ffffffffc0200a30 <__alltraps>
ffffffffc0200570:	10579073          	csrw	stvec,a5
    set_csr(sstatus, SSTATUS_SIE);
ffffffffc0200574:	100167f3          	csrrsi	a5,sstatus,2
    set_csr(sstatus, SSTATUS_SUM);
ffffffffc0200578:	000407b7          	lui	a5,0x40
ffffffffc020057c:	1007a7f3          	csrrs	a5,sstatus,a5
}
ffffffffc0200580:	8082                	ret

ffffffffc0200582 <print_regs>:
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200582:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
ffffffffc0200584:	1141                	addi	sp,sp,-16
ffffffffc0200586:	e022                	sd	s0,0(sp)
ffffffffc0200588:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020058a:	00004517          	auipc	a0,0x4
ffffffffc020058e:	24e50513          	addi	a0,a0,590 # ffffffffc02047d8 <commands+0xd8>
void print_regs(struct pushregs *gpr) {
ffffffffc0200592:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200594:	b27ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc0200598:	640c                	ld	a1,8(s0)
ffffffffc020059a:	00004517          	auipc	a0,0x4
ffffffffc020059e:	25650513          	addi	a0,a0,598 # ffffffffc02047f0 <commands+0xf0>
ffffffffc02005a2:	b19ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc02005a6:	680c                	ld	a1,16(s0)
ffffffffc02005a8:	00004517          	auipc	a0,0x4
ffffffffc02005ac:	26050513          	addi	a0,a0,608 # ffffffffc0204808 <commands+0x108>
ffffffffc02005b0:	b0bff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02005b4:	6c0c                	ld	a1,24(s0)
ffffffffc02005b6:	00004517          	auipc	a0,0x4
ffffffffc02005ba:	26a50513          	addi	a0,a0,618 # ffffffffc0204820 <commands+0x120>
ffffffffc02005be:	afdff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02005c2:	700c                	ld	a1,32(s0)
ffffffffc02005c4:	00004517          	auipc	a0,0x4
ffffffffc02005c8:	27450513          	addi	a0,a0,628 # ffffffffc0204838 <commands+0x138>
ffffffffc02005cc:	aefff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02005d0:	740c                	ld	a1,40(s0)
ffffffffc02005d2:	00004517          	auipc	a0,0x4
ffffffffc02005d6:	27e50513          	addi	a0,a0,638 # ffffffffc0204850 <commands+0x150>
ffffffffc02005da:	ae1ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02005de:	780c                	ld	a1,48(s0)
ffffffffc02005e0:	00004517          	auipc	a0,0x4
ffffffffc02005e4:	28850513          	addi	a0,a0,648 # ffffffffc0204868 <commands+0x168>
ffffffffc02005e8:	ad3ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02005ec:	7c0c                	ld	a1,56(s0)
ffffffffc02005ee:	00004517          	auipc	a0,0x4
ffffffffc02005f2:	29250513          	addi	a0,a0,658 # ffffffffc0204880 <commands+0x180>
ffffffffc02005f6:	ac5ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02005fa:	602c                	ld	a1,64(s0)
ffffffffc02005fc:	00004517          	auipc	a0,0x4
ffffffffc0200600:	29c50513          	addi	a0,a0,668 # ffffffffc0204898 <commands+0x198>
ffffffffc0200604:	ab7ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc0200608:	642c                	ld	a1,72(s0)
ffffffffc020060a:	00004517          	auipc	a0,0x4
ffffffffc020060e:	2a650513          	addi	a0,a0,678 # ffffffffc02048b0 <commands+0x1b0>
ffffffffc0200612:	aa9ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc0200616:	682c                	ld	a1,80(s0)
ffffffffc0200618:	00004517          	auipc	a0,0x4
ffffffffc020061c:	2b050513          	addi	a0,a0,688 # ffffffffc02048c8 <commands+0x1c8>
ffffffffc0200620:	a9bff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc0200624:	6c2c                	ld	a1,88(s0)
ffffffffc0200626:	00004517          	auipc	a0,0x4
ffffffffc020062a:	2ba50513          	addi	a0,a0,698 # ffffffffc02048e0 <commands+0x1e0>
ffffffffc020062e:	a8dff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200632:	702c                	ld	a1,96(s0)
ffffffffc0200634:	00004517          	auipc	a0,0x4
ffffffffc0200638:	2c450513          	addi	a0,a0,708 # ffffffffc02048f8 <commands+0x1f8>
ffffffffc020063c:	a7fff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200640:	742c                	ld	a1,104(s0)
ffffffffc0200642:	00004517          	auipc	a0,0x4
ffffffffc0200646:	2ce50513          	addi	a0,a0,718 # ffffffffc0204910 <commands+0x210>
ffffffffc020064a:	a71ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc020064e:	782c                	ld	a1,112(s0)
ffffffffc0200650:	00004517          	auipc	a0,0x4
ffffffffc0200654:	2d850513          	addi	a0,a0,728 # ffffffffc0204928 <commands+0x228>
ffffffffc0200658:	a63ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc020065c:	7c2c                	ld	a1,120(s0)
ffffffffc020065e:	00004517          	auipc	a0,0x4
ffffffffc0200662:	2e250513          	addi	a0,a0,738 # ffffffffc0204940 <commands+0x240>
ffffffffc0200666:	a55ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc020066a:	604c                	ld	a1,128(s0)
ffffffffc020066c:	00004517          	auipc	a0,0x4
ffffffffc0200670:	2ec50513          	addi	a0,a0,748 # ffffffffc0204958 <commands+0x258>
ffffffffc0200674:	a47ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200678:	644c                	ld	a1,136(s0)
ffffffffc020067a:	00004517          	auipc	a0,0x4
ffffffffc020067e:	2f650513          	addi	a0,a0,758 # ffffffffc0204970 <commands+0x270>
ffffffffc0200682:	a39ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200686:	684c                	ld	a1,144(s0)
ffffffffc0200688:	00004517          	auipc	a0,0x4
ffffffffc020068c:	30050513          	addi	a0,a0,768 # ffffffffc0204988 <commands+0x288>
ffffffffc0200690:	a2bff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200694:	6c4c                	ld	a1,152(s0)
ffffffffc0200696:	00004517          	auipc	a0,0x4
ffffffffc020069a:	30a50513          	addi	a0,a0,778 # ffffffffc02049a0 <commands+0x2a0>
ffffffffc020069e:	a1dff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc02006a2:	704c                	ld	a1,160(s0)
ffffffffc02006a4:	00004517          	auipc	a0,0x4
ffffffffc02006a8:	31450513          	addi	a0,a0,788 # ffffffffc02049b8 <commands+0x2b8>
ffffffffc02006ac:	a0fff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02006b0:	744c                	ld	a1,168(s0)
ffffffffc02006b2:	00004517          	auipc	a0,0x4
ffffffffc02006b6:	31e50513          	addi	a0,a0,798 # ffffffffc02049d0 <commands+0x2d0>
ffffffffc02006ba:	a01ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02006be:	784c                	ld	a1,176(s0)
ffffffffc02006c0:	00004517          	auipc	a0,0x4
ffffffffc02006c4:	32850513          	addi	a0,a0,808 # ffffffffc02049e8 <commands+0x2e8>
ffffffffc02006c8:	9f3ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02006cc:	7c4c                	ld	a1,184(s0)
ffffffffc02006ce:	00004517          	auipc	a0,0x4
ffffffffc02006d2:	33250513          	addi	a0,a0,818 # ffffffffc0204a00 <commands+0x300>
ffffffffc02006d6:	9e5ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02006da:	606c                	ld	a1,192(s0)
ffffffffc02006dc:	00004517          	auipc	a0,0x4
ffffffffc02006e0:	33c50513          	addi	a0,a0,828 # ffffffffc0204a18 <commands+0x318>
ffffffffc02006e4:	9d7ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02006e8:	646c                	ld	a1,200(s0)
ffffffffc02006ea:	00004517          	auipc	a0,0x4
ffffffffc02006ee:	34650513          	addi	a0,a0,838 # ffffffffc0204a30 <commands+0x330>
ffffffffc02006f2:	9c9ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02006f6:	686c                	ld	a1,208(s0)
ffffffffc02006f8:	00004517          	auipc	a0,0x4
ffffffffc02006fc:	35050513          	addi	a0,a0,848 # ffffffffc0204a48 <commands+0x348>
ffffffffc0200700:	9bbff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc0200704:	6c6c                	ld	a1,216(s0)
ffffffffc0200706:	00004517          	auipc	a0,0x4
ffffffffc020070a:	35a50513          	addi	a0,a0,858 # ffffffffc0204a60 <commands+0x360>
ffffffffc020070e:	9adff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc0200712:	706c                	ld	a1,224(s0)
ffffffffc0200714:	00004517          	auipc	a0,0x4
ffffffffc0200718:	36450513          	addi	a0,a0,868 # ffffffffc0204a78 <commands+0x378>
ffffffffc020071c:	99fff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200720:	746c                	ld	a1,232(s0)
ffffffffc0200722:	00004517          	auipc	a0,0x4
ffffffffc0200726:	36e50513          	addi	a0,a0,878 # ffffffffc0204a90 <commands+0x390>
ffffffffc020072a:	991ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc020072e:	786c                	ld	a1,240(s0)
ffffffffc0200730:	00004517          	auipc	a0,0x4
ffffffffc0200734:	37850513          	addi	a0,a0,888 # ffffffffc0204aa8 <commands+0x3a8>
ffffffffc0200738:	983ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020073c:	7c6c                	ld	a1,248(s0)
}
ffffffffc020073e:	6402                	ld	s0,0(sp)
ffffffffc0200740:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200742:	00004517          	auipc	a0,0x4
ffffffffc0200746:	37e50513          	addi	a0,a0,894 # ffffffffc0204ac0 <commands+0x3c0>
}
ffffffffc020074a:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020074c:	b2bd                	j	ffffffffc02000ba <cprintf>

ffffffffc020074e <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
ffffffffc020074e:	1141                	addi	sp,sp,-16
ffffffffc0200750:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200752:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
ffffffffc0200754:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc0200756:	00004517          	auipc	a0,0x4
ffffffffc020075a:	38250513          	addi	a0,a0,898 # ffffffffc0204ad8 <commands+0x3d8>
void print_trapframe(struct trapframe *tf) {
ffffffffc020075e:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200760:	95bff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200764:	8522                	mv	a0,s0
ffffffffc0200766:	e1dff0ef          	jal	ra,ffffffffc0200582 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc020076a:	10043583          	ld	a1,256(s0)
ffffffffc020076e:	00004517          	auipc	a0,0x4
ffffffffc0200772:	38250513          	addi	a0,a0,898 # ffffffffc0204af0 <commands+0x3f0>
ffffffffc0200776:	945ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc020077a:	10843583          	ld	a1,264(s0)
ffffffffc020077e:	00004517          	auipc	a0,0x4
ffffffffc0200782:	38a50513          	addi	a0,a0,906 # ffffffffc0204b08 <commands+0x408>
ffffffffc0200786:	935ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc020078a:	11043583          	ld	a1,272(s0)
ffffffffc020078e:	00004517          	auipc	a0,0x4
ffffffffc0200792:	39250513          	addi	a0,a0,914 # ffffffffc0204b20 <commands+0x420>
ffffffffc0200796:	925ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020079a:	11843583          	ld	a1,280(s0)
}
ffffffffc020079e:	6402                	ld	s0,0(sp)
ffffffffc02007a0:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02007a2:	00004517          	auipc	a0,0x4
ffffffffc02007a6:	39650513          	addi	a0,a0,918 # ffffffffc0204b38 <commands+0x438>
}
ffffffffc02007aa:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02007ac:	90fff06f          	j	ffffffffc02000ba <cprintf>

ffffffffc02007b0 <interrupt_handler>:

static volatile int in_swap_tick_event = 0;
extern struct mm_struct *check_mm_struct;

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc02007b0:	11853783          	ld	a5,280(a0)
ffffffffc02007b4:	472d                	li	a4,11
ffffffffc02007b6:	0786                	slli	a5,a5,0x1
ffffffffc02007b8:	8385                	srli	a5,a5,0x1
ffffffffc02007ba:	06f76f63          	bltu	a4,a5,ffffffffc0200838 <interrupt_handler+0x88>
ffffffffc02007be:	00004717          	auipc	a4,0x4
ffffffffc02007c2:	44270713          	addi	a4,a4,1090 # ffffffffc0204c00 <commands+0x500>
ffffffffc02007c6:	078a                	slli	a5,a5,0x2
ffffffffc02007c8:	97ba                	add	a5,a5,a4
ffffffffc02007ca:	439c                	lw	a5,0(a5)
ffffffffc02007cc:	97ba                	add	a5,a5,a4
ffffffffc02007ce:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02007d0:	00004517          	auipc	a0,0x4
ffffffffc02007d4:	3e050513          	addi	a0,a0,992 # ffffffffc0204bb0 <commands+0x4b0>
ffffffffc02007d8:	8e3ff06f          	j	ffffffffc02000ba <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02007dc:	00004517          	auipc	a0,0x4
ffffffffc02007e0:	3b450513          	addi	a0,a0,948 # ffffffffc0204b90 <commands+0x490>
ffffffffc02007e4:	8d7ff06f          	j	ffffffffc02000ba <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02007e8:	00004517          	auipc	a0,0x4
ffffffffc02007ec:	36850513          	addi	a0,a0,872 # ffffffffc0204b50 <commands+0x450>
ffffffffc02007f0:	8cbff06f          	j	ffffffffc02000ba <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc02007f4:	00004517          	auipc	a0,0x4
ffffffffc02007f8:	37c50513          	addi	a0,a0,892 # ffffffffc0204b70 <commands+0x470>
ffffffffc02007fc:	8bfff06f          	j	ffffffffc02000ba <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc0200800:	1141                	addi	sp,sp,-16
ffffffffc0200802:	e406                	sd	ra,8(sp)
ffffffffc0200804:	e022                	sd	s0,0(sp)
            /*(1)设置下次时钟中断- clock_set_next_event()
             *(2)计数器（ticks）加一
             *(3)当计数器加到100的时候，我们会输出一个`100ticks`表示我们触发了100次时钟中断，同时打印次数（num）加一
            * (4)判断打印次数，当打印次数为10时，调用<sbi.h>中的关机函数关机
            */
            clock_set_next_event();
ffffffffc0200806:	c03ff0ef          	jal	ra,ffffffffc0200408 <clock_set_next_event>
            ticks+=1;
ffffffffc020080a:	00011797          	auipc	a5,0x11
ffffffffc020080e:	cf678793          	addi	a5,a5,-778 # ffffffffc0211500 <ticks>
ffffffffc0200812:	6398                	ld	a4,0(a5)
ffffffffc0200814:	0705                	addi	a4,a4,1
ffffffffc0200816:	e398                	sd	a4,0(a5)
            if(ticks%TICK_NUM==0){
ffffffffc0200818:	639c                	ld	a5,0(a5)
ffffffffc020081a:	06400713          	li	a4,100
ffffffffc020081e:	02e7f7b3          	remu	a5,a5,a4
ffffffffc0200822:	cf81                	beqz	a5,ffffffffc020083a <interrupt_handler+0x8a>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200824:	60a2                	ld	ra,8(sp)
ffffffffc0200826:	6402                	ld	s0,0(sp)
ffffffffc0200828:	0141                	addi	sp,sp,16
ffffffffc020082a:	8082                	ret
            cprintf("Supervisor external interrupt\n");
ffffffffc020082c:	00004517          	auipc	a0,0x4
ffffffffc0200830:	3b450513          	addi	a0,a0,948 # ffffffffc0204be0 <commands+0x4e0>
ffffffffc0200834:	887ff06f          	j	ffffffffc02000ba <cprintf>
            print_trapframe(tf);
ffffffffc0200838:	bf19                	j	ffffffffc020074e <print_trapframe>
                num+=1;
ffffffffc020083a:	00011417          	auipc	s0,0x11
ffffffffc020083e:	cd640413          	addi	s0,s0,-810 # ffffffffc0211510 <num>
ffffffffc0200842:	601c                	ld	a5,0(s0)
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200844:	06400593          	li	a1,100
ffffffffc0200848:	00004517          	auipc	a0,0x4
ffffffffc020084c:	38850513          	addi	a0,a0,904 # ffffffffc0204bd0 <commands+0x4d0>
                num+=1;
ffffffffc0200850:	0785                	addi	a5,a5,1
ffffffffc0200852:	e01c                	sd	a5,0(s0)
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200854:	867ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
                if(num==10){
ffffffffc0200858:	6018                	ld	a4,0(s0)
ffffffffc020085a:	47a9                	li	a5,10
ffffffffc020085c:	fcf714e3          	bne	a4,a5,ffffffffc0200824 <interrupt_handler+0x74>
#endif
}

static inline void sbi_shutdown(void)
{
	SBI_CALL_0(SBI_SHUTDOWN);
ffffffffc0200860:	4501                	li	a0,0
ffffffffc0200862:	4581                	li	a1,0
ffffffffc0200864:	4601                	li	a2,0
ffffffffc0200866:	48a1                	li	a7,8
ffffffffc0200868:	00000073          	ecall
}
ffffffffc020086c:	bf65                	j	ffffffffc0200824 <interrupt_handler+0x74>

ffffffffc020086e <exception_handler>:


void exception_handler(struct trapframe *tf) {
    int ret;
    switch (tf->cause) {
ffffffffc020086e:	11853783          	ld	a5,280(a0)
void exception_handler(struct trapframe *tf) {
ffffffffc0200872:	1101                	addi	sp,sp,-32
ffffffffc0200874:	e822                	sd	s0,16(sp)
ffffffffc0200876:	ec06                	sd	ra,24(sp)
ffffffffc0200878:	e426                	sd	s1,8(sp)
ffffffffc020087a:	473d                	li	a4,15
ffffffffc020087c:	842a                	mv	s0,a0
ffffffffc020087e:	16f76963          	bltu	a4,a5,ffffffffc02009f0 <exception_handler+0x182>
ffffffffc0200882:	00004717          	auipc	a4,0x4
ffffffffc0200886:	58e70713          	addi	a4,a4,1422 # ffffffffc0204e10 <commands+0x710>
ffffffffc020088a:	078a                	slli	a5,a5,0x2
ffffffffc020088c:	97ba                	add	a5,a5,a4
ffffffffc020088e:	439c                	lw	a5,0(a5)
ffffffffc0200890:	97ba                	add	a5,a5,a4
ffffffffc0200892:	8782                	jr	a5
                print_trapframe(tf);
                panic("handle pgfault failed. %e\n", ret);
            }
            break;
        case CAUSE_STORE_PAGE_FAULT:
            cprintf("Store/AMO page fault\n");
ffffffffc0200894:	00004517          	auipc	a0,0x4
ffffffffc0200898:	56450513          	addi	a0,a0,1380 # ffffffffc0204df8 <commands+0x6f8>
ffffffffc020089c:	81fff0ef          	jal	ra,ffffffffc02000ba <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc02008a0:	8522                	mv	a0,s0
ffffffffc02008a2:	c53ff0ef          	jal	ra,ffffffffc02004f4 <pgfault_handler>
ffffffffc02008a6:	84aa                	mv	s1,a0
ffffffffc02008a8:	14051a63          	bnez	a0,ffffffffc02009fc <exception_handler+0x18e>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc02008ac:	60e2                	ld	ra,24(sp)
ffffffffc02008ae:	6442                	ld	s0,16(sp)
ffffffffc02008b0:	64a2                	ld	s1,8(sp)
ffffffffc02008b2:	6105                	addi	sp,sp,32
ffffffffc02008b4:	8082                	ret
            cprintf("Instruction address misaligned\n");
ffffffffc02008b6:	00004517          	auipc	a0,0x4
ffffffffc02008ba:	37a50513          	addi	a0,a0,890 # ffffffffc0204c30 <commands+0x530>
}
ffffffffc02008be:	6442                	ld	s0,16(sp)
ffffffffc02008c0:	60e2                	ld	ra,24(sp)
ffffffffc02008c2:	64a2                	ld	s1,8(sp)
ffffffffc02008c4:	6105                	addi	sp,sp,32
            cprintf("Instruction access fault\n");
ffffffffc02008c6:	ff4ff06f          	j	ffffffffc02000ba <cprintf>
ffffffffc02008ca:	00004517          	auipc	a0,0x4
ffffffffc02008ce:	38650513          	addi	a0,a0,902 # ffffffffc0204c50 <commands+0x550>
ffffffffc02008d2:	b7f5                	j	ffffffffc02008be <exception_handler+0x50>
            cprintf("Illegal instruction\n");
ffffffffc02008d4:	00004517          	auipc	a0,0x4
ffffffffc02008d8:	39c50513          	addi	a0,a0,924 # ffffffffc0204c70 <commands+0x570>
ffffffffc02008dc:	b7cd                	j	ffffffffc02008be <exception_handler+0x50>
            cprintf("Exception type:breakpoint\n");
ffffffffc02008de:	00004517          	auipc	a0,0x4
ffffffffc02008e2:	3aa50513          	addi	a0,a0,938 # ffffffffc0204c88 <commands+0x588>
ffffffffc02008e6:	fd4ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
            cprintf("指令地址: 0x%08x\n", tf->epc);
ffffffffc02008ea:	10843583          	ld	a1,264(s0)
ffffffffc02008ee:	00004517          	auipc	a0,0x4
ffffffffc02008f2:	3ba50513          	addi	a0,a0,954 # ffffffffc0204ca8 <commands+0x5a8>
ffffffffc02008f6:	fc4ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
            tf->epc += 2;
ffffffffc02008fa:	10843783          	ld	a5,264(s0)
ffffffffc02008fe:	0789                	addi	a5,a5,2
ffffffffc0200900:	10f43423          	sd	a5,264(s0)
            break;
ffffffffc0200904:	b765                	j	ffffffffc02008ac <exception_handler+0x3e>
            cprintf("Load address misaligned\n");
ffffffffc0200906:	00004517          	auipc	a0,0x4
ffffffffc020090a:	3ba50513          	addi	a0,a0,954 # ffffffffc0204cc0 <commands+0x5c0>
ffffffffc020090e:	bf45                	j	ffffffffc02008be <exception_handler+0x50>
            cprintf("Load access fault\n");
ffffffffc0200910:	00004517          	auipc	a0,0x4
ffffffffc0200914:	3d050513          	addi	a0,a0,976 # ffffffffc0204ce0 <commands+0x5e0>
ffffffffc0200918:	fa2ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc020091c:	8522                	mv	a0,s0
ffffffffc020091e:	bd7ff0ef          	jal	ra,ffffffffc02004f4 <pgfault_handler>
ffffffffc0200922:	84aa                	mv	s1,a0
ffffffffc0200924:	d541                	beqz	a0,ffffffffc02008ac <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc0200926:	8522                	mv	a0,s0
ffffffffc0200928:	e27ff0ef          	jal	ra,ffffffffc020074e <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc020092c:	86a6                	mv	a3,s1
ffffffffc020092e:	00004617          	auipc	a2,0x4
ffffffffc0200932:	3ca60613          	addi	a2,a2,970 # ffffffffc0204cf8 <commands+0x5f8>
ffffffffc0200936:	0de00593          	li	a1,222
ffffffffc020093a:	00004517          	auipc	a0,0x4
ffffffffc020093e:	e8650513          	addi	a0,a0,-378 # ffffffffc02047c0 <commands+0xc0>
ffffffffc0200942:	a33ff0ef          	jal	ra,ffffffffc0200374 <__panic>
            cprintf("AMO address misaligned\n");
ffffffffc0200946:	00004517          	auipc	a0,0x4
ffffffffc020094a:	3d250513          	addi	a0,a0,978 # ffffffffc0204d18 <commands+0x618>
ffffffffc020094e:	bf85                	j	ffffffffc02008be <exception_handler+0x50>
            cprintf("Store/AMO access fault\n");
ffffffffc0200950:	00004517          	auipc	a0,0x4
ffffffffc0200954:	3e050513          	addi	a0,a0,992 # ffffffffc0204d30 <commands+0x630>
ffffffffc0200958:	f62ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc020095c:	8522                	mv	a0,s0
ffffffffc020095e:	b97ff0ef          	jal	ra,ffffffffc02004f4 <pgfault_handler>
ffffffffc0200962:	84aa                	mv	s1,a0
ffffffffc0200964:	d521                	beqz	a0,ffffffffc02008ac <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc0200966:	8522                	mv	a0,s0
ffffffffc0200968:	de7ff0ef          	jal	ra,ffffffffc020074e <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc020096c:	86a6                	mv	a3,s1
ffffffffc020096e:	00004617          	auipc	a2,0x4
ffffffffc0200972:	38a60613          	addi	a2,a2,906 # ffffffffc0204cf8 <commands+0x5f8>
ffffffffc0200976:	0e800593          	li	a1,232
ffffffffc020097a:	00004517          	auipc	a0,0x4
ffffffffc020097e:	e4650513          	addi	a0,a0,-442 # ffffffffc02047c0 <commands+0xc0>
ffffffffc0200982:	9f3ff0ef          	jal	ra,ffffffffc0200374 <__panic>
            cprintf("Environment call from U-mode\n");
ffffffffc0200986:	00004517          	auipc	a0,0x4
ffffffffc020098a:	3c250513          	addi	a0,a0,962 # ffffffffc0204d48 <commands+0x648>
ffffffffc020098e:	bf05                	j	ffffffffc02008be <exception_handler+0x50>
            cprintf("Environment call from S-mode\n");
ffffffffc0200990:	00004517          	auipc	a0,0x4
ffffffffc0200994:	3d850513          	addi	a0,a0,984 # ffffffffc0204d68 <commands+0x668>
ffffffffc0200998:	b71d                	j	ffffffffc02008be <exception_handler+0x50>
            cprintf("Environment call from H-mode\n");
ffffffffc020099a:	00004517          	auipc	a0,0x4
ffffffffc020099e:	3ee50513          	addi	a0,a0,1006 # ffffffffc0204d88 <commands+0x688>
ffffffffc02009a2:	bf31                	j	ffffffffc02008be <exception_handler+0x50>
            cprintf("Environment call from M-mode\n");
ffffffffc02009a4:	00004517          	auipc	a0,0x4
ffffffffc02009a8:	40450513          	addi	a0,a0,1028 # ffffffffc0204da8 <commands+0x6a8>
ffffffffc02009ac:	bf09                	j	ffffffffc02008be <exception_handler+0x50>
            cprintf("Instruction page fault\n");
ffffffffc02009ae:	00004517          	auipc	a0,0x4
ffffffffc02009b2:	41a50513          	addi	a0,a0,1050 # ffffffffc0204dc8 <commands+0x6c8>
ffffffffc02009b6:	b721                	j	ffffffffc02008be <exception_handler+0x50>
            cprintf("Load page fault\n");
ffffffffc02009b8:	00004517          	auipc	a0,0x4
ffffffffc02009bc:	42850513          	addi	a0,a0,1064 # ffffffffc0204de0 <commands+0x6e0>
ffffffffc02009c0:	efaff0ef          	jal	ra,ffffffffc02000ba <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc02009c4:	8522                	mv	a0,s0
ffffffffc02009c6:	b2fff0ef          	jal	ra,ffffffffc02004f4 <pgfault_handler>
ffffffffc02009ca:	84aa                	mv	s1,a0
ffffffffc02009cc:	ee0500e3          	beqz	a0,ffffffffc02008ac <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc02009d0:	8522                	mv	a0,s0
ffffffffc02009d2:	d7dff0ef          	jal	ra,ffffffffc020074e <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc02009d6:	86a6                	mv	a3,s1
ffffffffc02009d8:	00004617          	auipc	a2,0x4
ffffffffc02009dc:	32060613          	addi	a2,a2,800 # ffffffffc0204cf8 <commands+0x5f8>
ffffffffc02009e0:	0fe00593          	li	a1,254
ffffffffc02009e4:	00004517          	auipc	a0,0x4
ffffffffc02009e8:	ddc50513          	addi	a0,a0,-548 # ffffffffc02047c0 <commands+0xc0>
ffffffffc02009ec:	989ff0ef          	jal	ra,ffffffffc0200374 <__panic>
            print_trapframe(tf);
ffffffffc02009f0:	8522                	mv	a0,s0
}
ffffffffc02009f2:	6442                	ld	s0,16(sp)
ffffffffc02009f4:	60e2                	ld	ra,24(sp)
ffffffffc02009f6:	64a2                	ld	s1,8(sp)
ffffffffc02009f8:	6105                	addi	sp,sp,32
            print_trapframe(tf);
ffffffffc02009fa:	bb91                	j	ffffffffc020074e <print_trapframe>
                print_trapframe(tf);
ffffffffc02009fc:	8522                	mv	a0,s0
ffffffffc02009fe:	d51ff0ef          	jal	ra,ffffffffc020074e <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200a02:	86a6                	mv	a3,s1
ffffffffc0200a04:	00004617          	auipc	a2,0x4
ffffffffc0200a08:	2f460613          	addi	a2,a2,756 # ffffffffc0204cf8 <commands+0x5f8>
ffffffffc0200a0c:	10500593          	li	a1,261
ffffffffc0200a10:	00004517          	auipc	a0,0x4
ffffffffc0200a14:	db050513          	addi	a0,a0,-592 # ffffffffc02047c0 <commands+0xc0>
ffffffffc0200a18:	95dff0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0200a1c <trap>:
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf) {
    // dispatch based on what type of trap occurred
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200a1c:	11853783          	ld	a5,280(a0)
ffffffffc0200a20:	0007c363          	bltz	a5,ffffffffc0200a26 <trap+0xa>
        // interrupts
        interrupt_handler(tf);
    } else {
        // exceptions
        exception_handler(tf);
ffffffffc0200a24:	b5a9                	j	ffffffffc020086e <exception_handler>
        interrupt_handler(tf);
ffffffffc0200a26:	b369                	j	ffffffffc02007b0 <interrupt_handler>
	...

ffffffffc0200a30 <__alltraps>:
    .endm

    .align 4
    .globl __alltraps
__alltraps:
    SAVE_ALL
ffffffffc0200a30:	14011073          	csrw	sscratch,sp
ffffffffc0200a34:	712d                	addi	sp,sp,-288
ffffffffc0200a36:	e406                	sd	ra,8(sp)
ffffffffc0200a38:	ec0e                	sd	gp,24(sp)
ffffffffc0200a3a:	f012                	sd	tp,32(sp)
ffffffffc0200a3c:	f416                	sd	t0,40(sp)
ffffffffc0200a3e:	f81a                	sd	t1,48(sp)
ffffffffc0200a40:	fc1e                	sd	t2,56(sp)
ffffffffc0200a42:	e0a2                	sd	s0,64(sp)
ffffffffc0200a44:	e4a6                	sd	s1,72(sp)
ffffffffc0200a46:	e8aa                	sd	a0,80(sp)
ffffffffc0200a48:	ecae                	sd	a1,88(sp)
ffffffffc0200a4a:	f0b2                	sd	a2,96(sp)
ffffffffc0200a4c:	f4b6                	sd	a3,104(sp)
ffffffffc0200a4e:	f8ba                	sd	a4,112(sp)
ffffffffc0200a50:	fcbe                	sd	a5,120(sp)
ffffffffc0200a52:	e142                	sd	a6,128(sp)
ffffffffc0200a54:	e546                	sd	a7,136(sp)
ffffffffc0200a56:	e94a                	sd	s2,144(sp)
ffffffffc0200a58:	ed4e                	sd	s3,152(sp)
ffffffffc0200a5a:	f152                	sd	s4,160(sp)
ffffffffc0200a5c:	f556                	sd	s5,168(sp)
ffffffffc0200a5e:	f95a                	sd	s6,176(sp)
ffffffffc0200a60:	fd5e                	sd	s7,184(sp)
ffffffffc0200a62:	e1e2                	sd	s8,192(sp)
ffffffffc0200a64:	e5e6                	sd	s9,200(sp)
ffffffffc0200a66:	e9ea                	sd	s10,208(sp)
ffffffffc0200a68:	edee                	sd	s11,216(sp)
ffffffffc0200a6a:	f1f2                	sd	t3,224(sp)
ffffffffc0200a6c:	f5f6                	sd	t4,232(sp)
ffffffffc0200a6e:	f9fa                	sd	t5,240(sp)
ffffffffc0200a70:	fdfe                	sd	t6,248(sp)
ffffffffc0200a72:	14002473          	csrr	s0,sscratch
ffffffffc0200a76:	100024f3          	csrr	s1,sstatus
ffffffffc0200a7a:	14102973          	csrr	s2,sepc
ffffffffc0200a7e:	143029f3          	csrr	s3,stval
ffffffffc0200a82:	14202a73          	csrr	s4,scause
ffffffffc0200a86:	e822                	sd	s0,16(sp)
ffffffffc0200a88:	e226                	sd	s1,256(sp)
ffffffffc0200a8a:	e64a                	sd	s2,264(sp)
ffffffffc0200a8c:	ea4e                	sd	s3,272(sp)
ffffffffc0200a8e:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc0200a90:	850a                	mv	a0,sp
    jal trap
ffffffffc0200a92:	f8bff0ef          	jal	ra,ffffffffc0200a1c <trap>

ffffffffc0200a96 <__trapret>:
    // sp should be the same as before "jal trap"
    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc0200a96:	6492                	ld	s1,256(sp)
ffffffffc0200a98:	6932                	ld	s2,264(sp)
ffffffffc0200a9a:	10049073          	csrw	sstatus,s1
ffffffffc0200a9e:	14191073          	csrw	sepc,s2
ffffffffc0200aa2:	60a2                	ld	ra,8(sp)
ffffffffc0200aa4:	61e2                	ld	gp,24(sp)
ffffffffc0200aa6:	7202                	ld	tp,32(sp)
ffffffffc0200aa8:	72a2                	ld	t0,40(sp)
ffffffffc0200aaa:	7342                	ld	t1,48(sp)
ffffffffc0200aac:	73e2                	ld	t2,56(sp)
ffffffffc0200aae:	6406                	ld	s0,64(sp)
ffffffffc0200ab0:	64a6                	ld	s1,72(sp)
ffffffffc0200ab2:	6546                	ld	a0,80(sp)
ffffffffc0200ab4:	65e6                	ld	a1,88(sp)
ffffffffc0200ab6:	7606                	ld	a2,96(sp)
ffffffffc0200ab8:	76a6                	ld	a3,104(sp)
ffffffffc0200aba:	7746                	ld	a4,112(sp)
ffffffffc0200abc:	77e6                	ld	a5,120(sp)
ffffffffc0200abe:	680a                	ld	a6,128(sp)
ffffffffc0200ac0:	68aa                	ld	a7,136(sp)
ffffffffc0200ac2:	694a                	ld	s2,144(sp)
ffffffffc0200ac4:	69ea                	ld	s3,152(sp)
ffffffffc0200ac6:	7a0a                	ld	s4,160(sp)
ffffffffc0200ac8:	7aaa                	ld	s5,168(sp)
ffffffffc0200aca:	7b4a                	ld	s6,176(sp)
ffffffffc0200acc:	7bea                	ld	s7,184(sp)
ffffffffc0200ace:	6c0e                	ld	s8,192(sp)
ffffffffc0200ad0:	6cae                	ld	s9,200(sp)
ffffffffc0200ad2:	6d4e                	ld	s10,208(sp)
ffffffffc0200ad4:	6dee                	ld	s11,216(sp)
ffffffffc0200ad6:	7e0e                	ld	t3,224(sp)
ffffffffc0200ad8:	7eae                	ld	t4,232(sp)
ffffffffc0200ada:	7f4e                	ld	t5,240(sp)
ffffffffc0200adc:	7fee                	ld	t6,248(sp)
ffffffffc0200ade:	6142                	ld	sp,16(sp)
    // go back from supervisor call
    sret
ffffffffc0200ae0:	10200073          	sret
	...

ffffffffc0200af0 <default_init>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200af0:	00010797          	auipc	a5,0x10
ffffffffc0200af4:	55078793          	addi	a5,a5,1360 # ffffffffc0211040 <free_area>
ffffffffc0200af8:	e79c                	sd	a5,8(a5)
ffffffffc0200afa:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc0200afc:	0007a823          	sw	zero,16(a5)
}
ffffffffc0200b00:	8082                	ret

ffffffffc0200b02 <default_nr_free_pages>:
}

static size_t
default_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0200b02:	00010517          	auipc	a0,0x10
ffffffffc0200b06:	54e56503          	lwu	a0,1358(a0) # ffffffffc0211050 <free_area+0x10>
ffffffffc0200b0a:	8082                	ret

ffffffffc0200b0c <default_check>:
}

// LAB2: below code is used to check the first fit allocation algorithm
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
ffffffffc0200b0c:	715d                	addi	sp,sp,-80
ffffffffc0200b0e:	e0a2                	sd	s0,64(sp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0200b10:	00010417          	auipc	s0,0x10
ffffffffc0200b14:	53040413          	addi	s0,s0,1328 # ffffffffc0211040 <free_area>
ffffffffc0200b18:	641c                	ld	a5,8(s0)
ffffffffc0200b1a:	e486                	sd	ra,72(sp)
ffffffffc0200b1c:	fc26                	sd	s1,56(sp)
ffffffffc0200b1e:	f84a                	sd	s2,48(sp)
ffffffffc0200b20:	f44e                	sd	s3,40(sp)
ffffffffc0200b22:	f052                	sd	s4,32(sp)
ffffffffc0200b24:	ec56                	sd	s5,24(sp)
ffffffffc0200b26:	e85a                	sd	s6,16(sp)
ffffffffc0200b28:	e45e                	sd	s7,8(sp)
ffffffffc0200b2a:	e062                	sd	s8,0(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200b2c:	2c878763          	beq	a5,s0,ffffffffc0200dfa <default_check+0x2ee>
    int count = 0, total = 0;
ffffffffc0200b30:	4481                	li	s1,0
ffffffffc0200b32:	4901                	li	s2,0
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200b34:	fe87b703          	ld	a4,-24(a5)
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0200b38:	8b09                	andi	a4,a4,2
ffffffffc0200b3a:	2c070463          	beqz	a4,ffffffffc0200e02 <default_check+0x2f6>
        count ++, total += p->property;
ffffffffc0200b3e:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200b42:	679c                	ld	a5,8(a5)
ffffffffc0200b44:	2905                	addiw	s2,s2,1
ffffffffc0200b46:	9cb9                	addw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200b48:	fe8796e3          	bne	a5,s0,ffffffffc0200b34 <default_check+0x28>
    }
    assert(total == nr_free_pages());
ffffffffc0200b4c:	89a6                	mv	s3,s1
ffffffffc0200b4e:	385000ef          	jal	ra,ffffffffc02016d2 <nr_free_pages>
ffffffffc0200b52:	71351863          	bne	a0,s3,ffffffffc0201262 <default_check+0x756>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200b56:	4505                	li	a0,1
ffffffffc0200b58:	2a9000ef          	jal	ra,ffffffffc0201600 <alloc_pages>
ffffffffc0200b5c:	8a2a                	mv	s4,a0
ffffffffc0200b5e:	44050263          	beqz	a0,ffffffffc0200fa2 <default_check+0x496>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200b62:	4505                	li	a0,1
ffffffffc0200b64:	29d000ef          	jal	ra,ffffffffc0201600 <alloc_pages>
ffffffffc0200b68:	89aa                	mv	s3,a0
ffffffffc0200b6a:	70050c63          	beqz	a0,ffffffffc0201282 <default_check+0x776>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200b6e:	4505                	li	a0,1
ffffffffc0200b70:	291000ef          	jal	ra,ffffffffc0201600 <alloc_pages>
ffffffffc0200b74:	8aaa                	mv	s5,a0
ffffffffc0200b76:	4a050663          	beqz	a0,ffffffffc0201022 <default_check+0x516>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200b7a:	2b3a0463          	beq	s4,s3,ffffffffc0200e22 <default_check+0x316>
ffffffffc0200b7e:	2aaa0263          	beq	s4,a0,ffffffffc0200e22 <default_check+0x316>
ffffffffc0200b82:	2aa98063          	beq	s3,a0,ffffffffc0200e22 <default_check+0x316>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200b86:	000a2783          	lw	a5,0(s4)
ffffffffc0200b8a:	2a079c63          	bnez	a5,ffffffffc0200e42 <default_check+0x336>
ffffffffc0200b8e:	0009a783          	lw	a5,0(s3)
ffffffffc0200b92:	2a079863          	bnez	a5,ffffffffc0200e42 <default_check+0x336>
ffffffffc0200b96:	411c                	lw	a5,0(a0)
ffffffffc0200b98:	2a079563          	bnez	a5,ffffffffc0200e42 <default_check+0x336>
extern struct Page *pages;
extern size_t npage;
extern const size_t nbase;
extern uint_t va_pa_offset;

static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200b9c:	00011797          	auipc	a5,0x11
ffffffffc0200ba0:	9947b783          	ld	a5,-1644(a5) # ffffffffc0211530 <pages>
ffffffffc0200ba4:	40fa0733          	sub	a4,s4,a5
ffffffffc0200ba8:	870d                	srai	a4,a4,0x3
ffffffffc0200baa:	00006597          	auipc	a1,0x6
ffffffffc0200bae:	86e5b583          	ld	a1,-1938(a1) # ffffffffc0206418 <error_string+0x38>
ffffffffc0200bb2:	02b70733          	mul	a4,a4,a1
ffffffffc0200bb6:	00006617          	auipc	a2,0x6
ffffffffc0200bba:	86a63603          	ld	a2,-1942(a2) # ffffffffc0206420 <nbase>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200bbe:	00011697          	auipc	a3,0x11
ffffffffc0200bc2:	96a6b683          	ld	a3,-1686(a3) # ffffffffc0211528 <npage>
ffffffffc0200bc6:	06b2                	slli	a3,a3,0xc
ffffffffc0200bc8:	9732                	add	a4,a4,a2

static inline uintptr_t page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
ffffffffc0200bca:	0732                	slli	a4,a4,0xc
ffffffffc0200bcc:	28d77b63          	bgeu	a4,a3,ffffffffc0200e62 <default_check+0x356>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200bd0:	40f98733          	sub	a4,s3,a5
ffffffffc0200bd4:	870d                	srai	a4,a4,0x3
ffffffffc0200bd6:	02b70733          	mul	a4,a4,a1
ffffffffc0200bda:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200bdc:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200bde:	4cd77263          	bgeu	a4,a3,ffffffffc02010a2 <default_check+0x596>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200be2:	40f507b3          	sub	a5,a0,a5
ffffffffc0200be6:	878d                	srai	a5,a5,0x3
ffffffffc0200be8:	02b787b3          	mul	a5,a5,a1
ffffffffc0200bec:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200bee:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200bf0:	30d7f963          	bgeu	a5,a3,ffffffffc0200f02 <default_check+0x3f6>
    assert(alloc_page() == NULL);
ffffffffc0200bf4:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200bf6:	00043c03          	ld	s8,0(s0)
ffffffffc0200bfa:	00843b83          	ld	s7,8(s0)
    unsigned int nr_free_store = nr_free;
ffffffffc0200bfe:	01042b03          	lw	s6,16(s0)
    elm->prev = elm->next = elm;
ffffffffc0200c02:	e400                	sd	s0,8(s0)
ffffffffc0200c04:	e000                	sd	s0,0(s0)
    nr_free = 0;
ffffffffc0200c06:	00010797          	auipc	a5,0x10
ffffffffc0200c0a:	4407a523          	sw	zero,1098(a5) # ffffffffc0211050 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0200c0e:	1f3000ef          	jal	ra,ffffffffc0201600 <alloc_pages>
ffffffffc0200c12:	2c051863          	bnez	a0,ffffffffc0200ee2 <default_check+0x3d6>
    free_page(p0);
ffffffffc0200c16:	4585                	li	a1,1
ffffffffc0200c18:	8552                	mv	a0,s4
ffffffffc0200c1a:	279000ef          	jal	ra,ffffffffc0201692 <free_pages>
    free_page(p1);
ffffffffc0200c1e:	4585                	li	a1,1
ffffffffc0200c20:	854e                	mv	a0,s3
ffffffffc0200c22:	271000ef          	jal	ra,ffffffffc0201692 <free_pages>
    free_page(p2);
ffffffffc0200c26:	4585                	li	a1,1
ffffffffc0200c28:	8556                	mv	a0,s5
ffffffffc0200c2a:	269000ef          	jal	ra,ffffffffc0201692 <free_pages>
    assert(nr_free == 3);
ffffffffc0200c2e:	4818                	lw	a4,16(s0)
ffffffffc0200c30:	478d                	li	a5,3
ffffffffc0200c32:	28f71863          	bne	a4,a5,ffffffffc0200ec2 <default_check+0x3b6>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200c36:	4505                	li	a0,1
ffffffffc0200c38:	1c9000ef          	jal	ra,ffffffffc0201600 <alloc_pages>
ffffffffc0200c3c:	89aa                	mv	s3,a0
ffffffffc0200c3e:	26050263          	beqz	a0,ffffffffc0200ea2 <default_check+0x396>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200c42:	4505                	li	a0,1
ffffffffc0200c44:	1bd000ef          	jal	ra,ffffffffc0201600 <alloc_pages>
ffffffffc0200c48:	8aaa                	mv	s5,a0
ffffffffc0200c4a:	3a050c63          	beqz	a0,ffffffffc0201002 <default_check+0x4f6>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200c4e:	4505                	li	a0,1
ffffffffc0200c50:	1b1000ef          	jal	ra,ffffffffc0201600 <alloc_pages>
ffffffffc0200c54:	8a2a                	mv	s4,a0
ffffffffc0200c56:	38050663          	beqz	a0,ffffffffc0200fe2 <default_check+0x4d6>
    assert(alloc_page() == NULL);
ffffffffc0200c5a:	4505                	li	a0,1
ffffffffc0200c5c:	1a5000ef          	jal	ra,ffffffffc0201600 <alloc_pages>
ffffffffc0200c60:	36051163          	bnez	a0,ffffffffc0200fc2 <default_check+0x4b6>
    free_page(p0);
ffffffffc0200c64:	4585                	li	a1,1
ffffffffc0200c66:	854e                	mv	a0,s3
ffffffffc0200c68:	22b000ef          	jal	ra,ffffffffc0201692 <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0200c6c:	641c                	ld	a5,8(s0)
ffffffffc0200c6e:	20878a63          	beq	a5,s0,ffffffffc0200e82 <default_check+0x376>
    assert((p = alloc_page()) == p0);
ffffffffc0200c72:	4505                	li	a0,1
ffffffffc0200c74:	18d000ef          	jal	ra,ffffffffc0201600 <alloc_pages>
ffffffffc0200c78:	30a99563          	bne	s3,a0,ffffffffc0200f82 <default_check+0x476>
    assert(alloc_page() == NULL);
ffffffffc0200c7c:	4505                	li	a0,1
ffffffffc0200c7e:	183000ef          	jal	ra,ffffffffc0201600 <alloc_pages>
ffffffffc0200c82:	2e051063          	bnez	a0,ffffffffc0200f62 <default_check+0x456>
    assert(nr_free == 0);
ffffffffc0200c86:	481c                	lw	a5,16(s0)
ffffffffc0200c88:	2a079d63          	bnez	a5,ffffffffc0200f42 <default_check+0x436>
    free_page(p);
ffffffffc0200c8c:	854e                	mv	a0,s3
ffffffffc0200c8e:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0200c90:	01843023          	sd	s8,0(s0)
ffffffffc0200c94:	01743423          	sd	s7,8(s0)
    nr_free = nr_free_store;
ffffffffc0200c98:	01642823          	sw	s6,16(s0)
    free_page(p);
ffffffffc0200c9c:	1f7000ef          	jal	ra,ffffffffc0201692 <free_pages>
    free_page(p1);
ffffffffc0200ca0:	4585                	li	a1,1
ffffffffc0200ca2:	8556                	mv	a0,s5
ffffffffc0200ca4:	1ef000ef          	jal	ra,ffffffffc0201692 <free_pages>
    free_page(p2);
ffffffffc0200ca8:	4585                	li	a1,1
ffffffffc0200caa:	8552                	mv	a0,s4
ffffffffc0200cac:	1e7000ef          	jal	ra,ffffffffc0201692 <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0200cb0:	4515                	li	a0,5
ffffffffc0200cb2:	14f000ef          	jal	ra,ffffffffc0201600 <alloc_pages>
ffffffffc0200cb6:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc0200cb8:	26050563          	beqz	a0,ffffffffc0200f22 <default_check+0x416>
ffffffffc0200cbc:	651c                	ld	a5,8(a0)
ffffffffc0200cbe:	8385                	srli	a5,a5,0x1
    assert(!PageProperty(p0));
ffffffffc0200cc0:	8b85                	andi	a5,a5,1
ffffffffc0200cc2:	54079063          	bnez	a5,ffffffffc0201202 <default_check+0x6f6>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0200cc6:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200cc8:	00043b03          	ld	s6,0(s0)
ffffffffc0200ccc:	00843a83          	ld	s5,8(s0)
ffffffffc0200cd0:	e000                	sd	s0,0(s0)
ffffffffc0200cd2:	e400                	sd	s0,8(s0)
    assert(alloc_page() == NULL);
ffffffffc0200cd4:	12d000ef          	jal	ra,ffffffffc0201600 <alloc_pages>
ffffffffc0200cd8:	50051563          	bnez	a0,ffffffffc02011e2 <default_check+0x6d6>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc0200cdc:	09098a13          	addi	s4,s3,144
ffffffffc0200ce0:	8552                	mv	a0,s4
ffffffffc0200ce2:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc0200ce4:	01042b83          	lw	s7,16(s0)
    nr_free = 0;
ffffffffc0200ce8:	00010797          	auipc	a5,0x10
ffffffffc0200cec:	3607a423          	sw	zero,872(a5) # ffffffffc0211050 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc0200cf0:	1a3000ef          	jal	ra,ffffffffc0201692 <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0200cf4:	4511                	li	a0,4
ffffffffc0200cf6:	10b000ef          	jal	ra,ffffffffc0201600 <alloc_pages>
ffffffffc0200cfa:	4c051463          	bnez	a0,ffffffffc02011c2 <default_check+0x6b6>
ffffffffc0200cfe:	0989b783          	ld	a5,152(s3)
ffffffffc0200d02:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0200d04:	8b85                	andi	a5,a5,1
ffffffffc0200d06:	48078e63          	beqz	a5,ffffffffc02011a2 <default_check+0x696>
ffffffffc0200d0a:	0a89a703          	lw	a4,168(s3)
ffffffffc0200d0e:	478d                	li	a5,3
ffffffffc0200d10:	48f71963          	bne	a4,a5,ffffffffc02011a2 <default_check+0x696>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0200d14:	450d                	li	a0,3
ffffffffc0200d16:	0eb000ef          	jal	ra,ffffffffc0201600 <alloc_pages>
ffffffffc0200d1a:	8c2a                	mv	s8,a0
ffffffffc0200d1c:	46050363          	beqz	a0,ffffffffc0201182 <default_check+0x676>
    assert(alloc_page() == NULL);
ffffffffc0200d20:	4505                	li	a0,1
ffffffffc0200d22:	0df000ef          	jal	ra,ffffffffc0201600 <alloc_pages>
ffffffffc0200d26:	42051e63          	bnez	a0,ffffffffc0201162 <default_check+0x656>
    assert(p0 + 2 == p1);
ffffffffc0200d2a:	418a1c63          	bne	s4,s8,ffffffffc0201142 <default_check+0x636>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc0200d2e:	4585                	li	a1,1
ffffffffc0200d30:	854e                	mv	a0,s3
ffffffffc0200d32:	161000ef          	jal	ra,ffffffffc0201692 <free_pages>
    free_pages(p1, 3);
ffffffffc0200d36:	458d                	li	a1,3
ffffffffc0200d38:	8552                	mv	a0,s4
ffffffffc0200d3a:	159000ef          	jal	ra,ffffffffc0201692 <free_pages>
ffffffffc0200d3e:	0089b783          	ld	a5,8(s3)
    p2 = p0 + 1;
ffffffffc0200d42:	04898c13          	addi	s8,s3,72
ffffffffc0200d46:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0200d48:	8b85                	andi	a5,a5,1
ffffffffc0200d4a:	3c078c63          	beqz	a5,ffffffffc0201122 <default_check+0x616>
ffffffffc0200d4e:	0189a703          	lw	a4,24(s3)
ffffffffc0200d52:	4785                	li	a5,1
ffffffffc0200d54:	3cf71763          	bne	a4,a5,ffffffffc0201122 <default_check+0x616>
ffffffffc0200d58:	008a3783          	ld	a5,8(s4)
ffffffffc0200d5c:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0200d5e:	8b85                	andi	a5,a5,1
ffffffffc0200d60:	3a078163          	beqz	a5,ffffffffc0201102 <default_check+0x5f6>
ffffffffc0200d64:	018a2703          	lw	a4,24(s4)
ffffffffc0200d68:	478d                	li	a5,3
ffffffffc0200d6a:	38f71c63          	bne	a4,a5,ffffffffc0201102 <default_check+0x5f6>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0200d6e:	4505                	li	a0,1
ffffffffc0200d70:	091000ef          	jal	ra,ffffffffc0201600 <alloc_pages>
ffffffffc0200d74:	36a99763          	bne	s3,a0,ffffffffc02010e2 <default_check+0x5d6>
    free_page(p0);
ffffffffc0200d78:	4585                	li	a1,1
ffffffffc0200d7a:	119000ef          	jal	ra,ffffffffc0201692 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0200d7e:	4509                	li	a0,2
ffffffffc0200d80:	081000ef          	jal	ra,ffffffffc0201600 <alloc_pages>
ffffffffc0200d84:	32aa1f63          	bne	s4,a0,ffffffffc02010c2 <default_check+0x5b6>

    free_pages(p0, 2);
ffffffffc0200d88:	4589                	li	a1,2
ffffffffc0200d8a:	109000ef          	jal	ra,ffffffffc0201692 <free_pages>
    free_page(p2);
ffffffffc0200d8e:	4585                	li	a1,1
ffffffffc0200d90:	8562                	mv	a0,s8
ffffffffc0200d92:	101000ef          	jal	ra,ffffffffc0201692 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0200d96:	4515                	li	a0,5
ffffffffc0200d98:	069000ef          	jal	ra,ffffffffc0201600 <alloc_pages>
ffffffffc0200d9c:	89aa                	mv	s3,a0
ffffffffc0200d9e:	48050263          	beqz	a0,ffffffffc0201222 <default_check+0x716>
    assert(alloc_page() == NULL);
ffffffffc0200da2:	4505                	li	a0,1
ffffffffc0200da4:	05d000ef          	jal	ra,ffffffffc0201600 <alloc_pages>
ffffffffc0200da8:	2c051d63          	bnez	a0,ffffffffc0201082 <default_check+0x576>

    assert(nr_free == 0);
ffffffffc0200dac:	481c                	lw	a5,16(s0)
ffffffffc0200dae:	2a079a63          	bnez	a5,ffffffffc0201062 <default_check+0x556>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc0200db2:	4595                	li	a1,5
ffffffffc0200db4:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc0200db6:	01742823          	sw	s7,16(s0)
    free_list = free_list_store;
ffffffffc0200dba:	01643023          	sd	s6,0(s0)
ffffffffc0200dbe:	01543423          	sd	s5,8(s0)
    free_pages(p0, 5);
ffffffffc0200dc2:	0d1000ef          	jal	ra,ffffffffc0201692 <free_pages>
    return listelm->next;
ffffffffc0200dc6:	641c                	ld	a5,8(s0)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200dc8:	00878963          	beq	a5,s0,ffffffffc0200dda <default_check+0x2ce>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc0200dcc:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200dd0:	679c                	ld	a5,8(a5)
ffffffffc0200dd2:	397d                	addiw	s2,s2,-1
ffffffffc0200dd4:	9c99                	subw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200dd6:	fe879be3          	bne	a5,s0,ffffffffc0200dcc <default_check+0x2c0>
    }
    assert(count == 0);
ffffffffc0200dda:	26091463          	bnez	s2,ffffffffc0201042 <default_check+0x536>
    assert(total == 0);
ffffffffc0200dde:	46049263          	bnez	s1,ffffffffc0201242 <default_check+0x736>
}
ffffffffc0200de2:	60a6                	ld	ra,72(sp)
ffffffffc0200de4:	6406                	ld	s0,64(sp)
ffffffffc0200de6:	74e2                	ld	s1,56(sp)
ffffffffc0200de8:	7942                	ld	s2,48(sp)
ffffffffc0200dea:	79a2                	ld	s3,40(sp)
ffffffffc0200dec:	7a02                	ld	s4,32(sp)
ffffffffc0200dee:	6ae2                	ld	s5,24(sp)
ffffffffc0200df0:	6b42                	ld	s6,16(sp)
ffffffffc0200df2:	6ba2                	ld	s7,8(sp)
ffffffffc0200df4:	6c02                	ld	s8,0(sp)
ffffffffc0200df6:	6161                	addi	sp,sp,80
ffffffffc0200df8:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200dfa:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc0200dfc:	4481                	li	s1,0
ffffffffc0200dfe:	4901                	li	s2,0
ffffffffc0200e00:	b3b9                	j	ffffffffc0200b4e <default_check+0x42>
        assert(PageProperty(p));
ffffffffc0200e02:	00004697          	auipc	a3,0x4
ffffffffc0200e06:	04e68693          	addi	a3,a3,78 # ffffffffc0204e50 <commands+0x750>
ffffffffc0200e0a:	00004617          	auipc	a2,0x4
ffffffffc0200e0e:	05660613          	addi	a2,a2,86 # ffffffffc0204e60 <commands+0x760>
ffffffffc0200e12:	0f000593          	li	a1,240
ffffffffc0200e16:	00004517          	auipc	a0,0x4
ffffffffc0200e1a:	06250513          	addi	a0,a0,98 # ffffffffc0204e78 <commands+0x778>
ffffffffc0200e1e:	d56ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200e22:	00004697          	auipc	a3,0x4
ffffffffc0200e26:	0ee68693          	addi	a3,a3,238 # ffffffffc0204f10 <commands+0x810>
ffffffffc0200e2a:	00004617          	auipc	a2,0x4
ffffffffc0200e2e:	03660613          	addi	a2,a2,54 # ffffffffc0204e60 <commands+0x760>
ffffffffc0200e32:	0bd00593          	li	a1,189
ffffffffc0200e36:	00004517          	auipc	a0,0x4
ffffffffc0200e3a:	04250513          	addi	a0,a0,66 # ffffffffc0204e78 <commands+0x778>
ffffffffc0200e3e:	d36ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200e42:	00004697          	auipc	a3,0x4
ffffffffc0200e46:	0f668693          	addi	a3,a3,246 # ffffffffc0204f38 <commands+0x838>
ffffffffc0200e4a:	00004617          	auipc	a2,0x4
ffffffffc0200e4e:	01660613          	addi	a2,a2,22 # ffffffffc0204e60 <commands+0x760>
ffffffffc0200e52:	0be00593          	li	a1,190
ffffffffc0200e56:	00004517          	auipc	a0,0x4
ffffffffc0200e5a:	02250513          	addi	a0,a0,34 # ffffffffc0204e78 <commands+0x778>
ffffffffc0200e5e:	d16ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200e62:	00004697          	auipc	a3,0x4
ffffffffc0200e66:	11668693          	addi	a3,a3,278 # ffffffffc0204f78 <commands+0x878>
ffffffffc0200e6a:	00004617          	auipc	a2,0x4
ffffffffc0200e6e:	ff660613          	addi	a2,a2,-10 # ffffffffc0204e60 <commands+0x760>
ffffffffc0200e72:	0c000593          	li	a1,192
ffffffffc0200e76:	00004517          	auipc	a0,0x4
ffffffffc0200e7a:	00250513          	addi	a0,a0,2 # ffffffffc0204e78 <commands+0x778>
ffffffffc0200e7e:	cf6ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(!list_empty(&free_list));
ffffffffc0200e82:	00004697          	auipc	a3,0x4
ffffffffc0200e86:	17e68693          	addi	a3,a3,382 # ffffffffc0205000 <commands+0x900>
ffffffffc0200e8a:	00004617          	auipc	a2,0x4
ffffffffc0200e8e:	fd660613          	addi	a2,a2,-42 # ffffffffc0204e60 <commands+0x760>
ffffffffc0200e92:	0d900593          	li	a1,217
ffffffffc0200e96:	00004517          	auipc	a0,0x4
ffffffffc0200e9a:	fe250513          	addi	a0,a0,-30 # ffffffffc0204e78 <commands+0x778>
ffffffffc0200e9e:	cd6ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200ea2:	00004697          	auipc	a3,0x4
ffffffffc0200ea6:	00e68693          	addi	a3,a3,14 # ffffffffc0204eb0 <commands+0x7b0>
ffffffffc0200eaa:	00004617          	auipc	a2,0x4
ffffffffc0200eae:	fb660613          	addi	a2,a2,-74 # ffffffffc0204e60 <commands+0x760>
ffffffffc0200eb2:	0d200593          	li	a1,210
ffffffffc0200eb6:	00004517          	auipc	a0,0x4
ffffffffc0200eba:	fc250513          	addi	a0,a0,-62 # ffffffffc0204e78 <commands+0x778>
ffffffffc0200ebe:	cb6ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(nr_free == 3);
ffffffffc0200ec2:	00004697          	auipc	a3,0x4
ffffffffc0200ec6:	12e68693          	addi	a3,a3,302 # ffffffffc0204ff0 <commands+0x8f0>
ffffffffc0200eca:	00004617          	auipc	a2,0x4
ffffffffc0200ece:	f9660613          	addi	a2,a2,-106 # ffffffffc0204e60 <commands+0x760>
ffffffffc0200ed2:	0d000593          	li	a1,208
ffffffffc0200ed6:	00004517          	auipc	a0,0x4
ffffffffc0200eda:	fa250513          	addi	a0,a0,-94 # ffffffffc0204e78 <commands+0x778>
ffffffffc0200ede:	c96ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200ee2:	00004697          	auipc	a3,0x4
ffffffffc0200ee6:	0f668693          	addi	a3,a3,246 # ffffffffc0204fd8 <commands+0x8d8>
ffffffffc0200eea:	00004617          	auipc	a2,0x4
ffffffffc0200eee:	f7660613          	addi	a2,a2,-138 # ffffffffc0204e60 <commands+0x760>
ffffffffc0200ef2:	0cb00593          	li	a1,203
ffffffffc0200ef6:	00004517          	auipc	a0,0x4
ffffffffc0200efa:	f8250513          	addi	a0,a0,-126 # ffffffffc0204e78 <commands+0x778>
ffffffffc0200efe:	c76ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200f02:	00004697          	auipc	a3,0x4
ffffffffc0200f06:	0b668693          	addi	a3,a3,182 # ffffffffc0204fb8 <commands+0x8b8>
ffffffffc0200f0a:	00004617          	auipc	a2,0x4
ffffffffc0200f0e:	f5660613          	addi	a2,a2,-170 # ffffffffc0204e60 <commands+0x760>
ffffffffc0200f12:	0c200593          	li	a1,194
ffffffffc0200f16:	00004517          	auipc	a0,0x4
ffffffffc0200f1a:	f6250513          	addi	a0,a0,-158 # ffffffffc0204e78 <commands+0x778>
ffffffffc0200f1e:	c56ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(p0 != NULL);
ffffffffc0200f22:	00004697          	auipc	a3,0x4
ffffffffc0200f26:	12668693          	addi	a3,a3,294 # ffffffffc0205048 <commands+0x948>
ffffffffc0200f2a:	00004617          	auipc	a2,0x4
ffffffffc0200f2e:	f3660613          	addi	a2,a2,-202 # ffffffffc0204e60 <commands+0x760>
ffffffffc0200f32:	0f800593          	li	a1,248
ffffffffc0200f36:	00004517          	auipc	a0,0x4
ffffffffc0200f3a:	f4250513          	addi	a0,a0,-190 # ffffffffc0204e78 <commands+0x778>
ffffffffc0200f3e:	c36ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(nr_free == 0);
ffffffffc0200f42:	00004697          	auipc	a3,0x4
ffffffffc0200f46:	0f668693          	addi	a3,a3,246 # ffffffffc0205038 <commands+0x938>
ffffffffc0200f4a:	00004617          	auipc	a2,0x4
ffffffffc0200f4e:	f1660613          	addi	a2,a2,-234 # ffffffffc0204e60 <commands+0x760>
ffffffffc0200f52:	0df00593          	li	a1,223
ffffffffc0200f56:	00004517          	auipc	a0,0x4
ffffffffc0200f5a:	f2250513          	addi	a0,a0,-222 # ffffffffc0204e78 <commands+0x778>
ffffffffc0200f5e:	c16ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200f62:	00004697          	auipc	a3,0x4
ffffffffc0200f66:	07668693          	addi	a3,a3,118 # ffffffffc0204fd8 <commands+0x8d8>
ffffffffc0200f6a:	00004617          	auipc	a2,0x4
ffffffffc0200f6e:	ef660613          	addi	a2,a2,-266 # ffffffffc0204e60 <commands+0x760>
ffffffffc0200f72:	0dd00593          	li	a1,221
ffffffffc0200f76:	00004517          	auipc	a0,0x4
ffffffffc0200f7a:	f0250513          	addi	a0,a0,-254 # ffffffffc0204e78 <commands+0x778>
ffffffffc0200f7e:	bf6ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc0200f82:	00004697          	auipc	a3,0x4
ffffffffc0200f86:	09668693          	addi	a3,a3,150 # ffffffffc0205018 <commands+0x918>
ffffffffc0200f8a:	00004617          	auipc	a2,0x4
ffffffffc0200f8e:	ed660613          	addi	a2,a2,-298 # ffffffffc0204e60 <commands+0x760>
ffffffffc0200f92:	0dc00593          	li	a1,220
ffffffffc0200f96:	00004517          	auipc	a0,0x4
ffffffffc0200f9a:	ee250513          	addi	a0,a0,-286 # ffffffffc0204e78 <commands+0x778>
ffffffffc0200f9e:	bd6ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200fa2:	00004697          	auipc	a3,0x4
ffffffffc0200fa6:	f0e68693          	addi	a3,a3,-242 # ffffffffc0204eb0 <commands+0x7b0>
ffffffffc0200faa:	00004617          	auipc	a2,0x4
ffffffffc0200fae:	eb660613          	addi	a2,a2,-330 # ffffffffc0204e60 <commands+0x760>
ffffffffc0200fb2:	0b900593          	li	a1,185
ffffffffc0200fb6:	00004517          	auipc	a0,0x4
ffffffffc0200fba:	ec250513          	addi	a0,a0,-318 # ffffffffc0204e78 <commands+0x778>
ffffffffc0200fbe:	bb6ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200fc2:	00004697          	auipc	a3,0x4
ffffffffc0200fc6:	01668693          	addi	a3,a3,22 # ffffffffc0204fd8 <commands+0x8d8>
ffffffffc0200fca:	00004617          	auipc	a2,0x4
ffffffffc0200fce:	e9660613          	addi	a2,a2,-362 # ffffffffc0204e60 <commands+0x760>
ffffffffc0200fd2:	0d600593          	li	a1,214
ffffffffc0200fd6:	00004517          	auipc	a0,0x4
ffffffffc0200fda:	ea250513          	addi	a0,a0,-350 # ffffffffc0204e78 <commands+0x778>
ffffffffc0200fde:	b96ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200fe2:	00004697          	auipc	a3,0x4
ffffffffc0200fe6:	f0e68693          	addi	a3,a3,-242 # ffffffffc0204ef0 <commands+0x7f0>
ffffffffc0200fea:	00004617          	auipc	a2,0x4
ffffffffc0200fee:	e7660613          	addi	a2,a2,-394 # ffffffffc0204e60 <commands+0x760>
ffffffffc0200ff2:	0d400593          	li	a1,212
ffffffffc0200ff6:	00004517          	auipc	a0,0x4
ffffffffc0200ffa:	e8250513          	addi	a0,a0,-382 # ffffffffc0204e78 <commands+0x778>
ffffffffc0200ffe:	b76ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201002:	00004697          	auipc	a3,0x4
ffffffffc0201006:	ece68693          	addi	a3,a3,-306 # ffffffffc0204ed0 <commands+0x7d0>
ffffffffc020100a:	00004617          	auipc	a2,0x4
ffffffffc020100e:	e5660613          	addi	a2,a2,-426 # ffffffffc0204e60 <commands+0x760>
ffffffffc0201012:	0d300593          	li	a1,211
ffffffffc0201016:	00004517          	auipc	a0,0x4
ffffffffc020101a:	e6250513          	addi	a0,a0,-414 # ffffffffc0204e78 <commands+0x778>
ffffffffc020101e:	b56ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0201022:	00004697          	auipc	a3,0x4
ffffffffc0201026:	ece68693          	addi	a3,a3,-306 # ffffffffc0204ef0 <commands+0x7f0>
ffffffffc020102a:	00004617          	auipc	a2,0x4
ffffffffc020102e:	e3660613          	addi	a2,a2,-458 # ffffffffc0204e60 <commands+0x760>
ffffffffc0201032:	0bb00593          	li	a1,187
ffffffffc0201036:	00004517          	auipc	a0,0x4
ffffffffc020103a:	e4250513          	addi	a0,a0,-446 # ffffffffc0204e78 <commands+0x778>
ffffffffc020103e:	b36ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(count == 0);
ffffffffc0201042:	00004697          	auipc	a3,0x4
ffffffffc0201046:	15668693          	addi	a3,a3,342 # ffffffffc0205198 <commands+0xa98>
ffffffffc020104a:	00004617          	auipc	a2,0x4
ffffffffc020104e:	e1660613          	addi	a2,a2,-490 # ffffffffc0204e60 <commands+0x760>
ffffffffc0201052:	12500593          	li	a1,293
ffffffffc0201056:	00004517          	auipc	a0,0x4
ffffffffc020105a:	e2250513          	addi	a0,a0,-478 # ffffffffc0204e78 <commands+0x778>
ffffffffc020105e:	b16ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(nr_free == 0);
ffffffffc0201062:	00004697          	auipc	a3,0x4
ffffffffc0201066:	fd668693          	addi	a3,a3,-42 # ffffffffc0205038 <commands+0x938>
ffffffffc020106a:	00004617          	auipc	a2,0x4
ffffffffc020106e:	df660613          	addi	a2,a2,-522 # ffffffffc0204e60 <commands+0x760>
ffffffffc0201072:	11a00593          	li	a1,282
ffffffffc0201076:	00004517          	auipc	a0,0x4
ffffffffc020107a:	e0250513          	addi	a0,a0,-510 # ffffffffc0204e78 <commands+0x778>
ffffffffc020107e:	af6ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201082:	00004697          	auipc	a3,0x4
ffffffffc0201086:	f5668693          	addi	a3,a3,-170 # ffffffffc0204fd8 <commands+0x8d8>
ffffffffc020108a:	00004617          	auipc	a2,0x4
ffffffffc020108e:	dd660613          	addi	a2,a2,-554 # ffffffffc0204e60 <commands+0x760>
ffffffffc0201092:	11800593          	li	a1,280
ffffffffc0201096:	00004517          	auipc	a0,0x4
ffffffffc020109a:	de250513          	addi	a0,a0,-542 # ffffffffc0204e78 <commands+0x778>
ffffffffc020109e:	ad6ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc02010a2:	00004697          	auipc	a3,0x4
ffffffffc02010a6:	ef668693          	addi	a3,a3,-266 # ffffffffc0204f98 <commands+0x898>
ffffffffc02010aa:	00004617          	auipc	a2,0x4
ffffffffc02010ae:	db660613          	addi	a2,a2,-586 # ffffffffc0204e60 <commands+0x760>
ffffffffc02010b2:	0c100593          	li	a1,193
ffffffffc02010b6:	00004517          	auipc	a0,0x4
ffffffffc02010ba:	dc250513          	addi	a0,a0,-574 # ffffffffc0204e78 <commands+0x778>
ffffffffc02010be:	ab6ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc02010c2:	00004697          	auipc	a3,0x4
ffffffffc02010c6:	09668693          	addi	a3,a3,150 # ffffffffc0205158 <commands+0xa58>
ffffffffc02010ca:	00004617          	auipc	a2,0x4
ffffffffc02010ce:	d9660613          	addi	a2,a2,-618 # ffffffffc0204e60 <commands+0x760>
ffffffffc02010d2:	11200593          	li	a1,274
ffffffffc02010d6:	00004517          	auipc	a0,0x4
ffffffffc02010da:	da250513          	addi	a0,a0,-606 # ffffffffc0204e78 <commands+0x778>
ffffffffc02010de:	a96ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc02010e2:	00004697          	auipc	a3,0x4
ffffffffc02010e6:	05668693          	addi	a3,a3,86 # ffffffffc0205138 <commands+0xa38>
ffffffffc02010ea:	00004617          	auipc	a2,0x4
ffffffffc02010ee:	d7660613          	addi	a2,a2,-650 # ffffffffc0204e60 <commands+0x760>
ffffffffc02010f2:	11000593          	li	a1,272
ffffffffc02010f6:	00004517          	auipc	a0,0x4
ffffffffc02010fa:	d8250513          	addi	a0,a0,-638 # ffffffffc0204e78 <commands+0x778>
ffffffffc02010fe:	a76ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0201102:	00004697          	auipc	a3,0x4
ffffffffc0201106:	00e68693          	addi	a3,a3,14 # ffffffffc0205110 <commands+0xa10>
ffffffffc020110a:	00004617          	auipc	a2,0x4
ffffffffc020110e:	d5660613          	addi	a2,a2,-682 # ffffffffc0204e60 <commands+0x760>
ffffffffc0201112:	10e00593          	li	a1,270
ffffffffc0201116:	00004517          	auipc	a0,0x4
ffffffffc020111a:	d6250513          	addi	a0,a0,-670 # ffffffffc0204e78 <commands+0x778>
ffffffffc020111e:	a56ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0201122:	00004697          	auipc	a3,0x4
ffffffffc0201126:	fc668693          	addi	a3,a3,-58 # ffffffffc02050e8 <commands+0x9e8>
ffffffffc020112a:	00004617          	auipc	a2,0x4
ffffffffc020112e:	d3660613          	addi	a2,a2,-714 # ffffffffc0204e60 <commands+0x760>
ffffffffc0201132:	10d00593          	li	a1,269
ffffffffc0201136:	00004517          	auipc	a0,0x4
ffffffffc020113a:	d4250513          	addi	a0,a0,-702 # ffffffffc0204e78 <commands+0x778>
ffffffffc020113e:	a36ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(p0 + 2 == p1);
ffffffffc0201142:	00004697          	auipc	a3,0x4
ffffffffc0201146:	f9668693          	addi	a3,a3,-106 # ffffffffc02050d8 <commands+0x9d8>
ffffffffc020114a:	00004617          	auipc	a2,0x4
ffffffffc020114e:	d1660613          	addi	a2,a2,-746 # ffffffffc0204e60 <commands+0x760>
ffffffffc0201152:	10800593          	li	a1,264
ffffffffc0201156:	00004517          	auipc	a0,0x4
ffffffffc020115a:	d2250513          	addi	a0,a0,-734 # ffffffffc0204e78 <commands+0x778>
ffffffffc020115e:	a16ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201162:	00004697          	auipc	a3,0x4
ffffffffc0201166:	e7668693          	addi	a3,a3,-394 # ffffffffc0204fd8 <commands+0x8d8>
ffffffffc020116a:	00004617          	auipc	a2,0x4
ffffffffc020116e:	cf660613          	addi	a2,a2,-778 # ffffffffc0204e60 <commands+0x760>
ffffffffc0201172:	10700593          	li	a1,263
ffffffffc0201176:	00004517          	auipc	a0,0x4
ffffffffc020117a:	d0250513          	addi	a0,a0,-766 # ffffffffc0204e78 <commands+0x778>
ffffffffc020117e:	9f6ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0201182:	00004697          	auipc	a3,0x4
ffffffffc0201186:	f3668693          	addi	a3,a3,-202 # ffffffffc02050b8 <commands+0x9b8>
ffffffffc020118a:	00004617          	auipc	a2,0x4
ffffffffc020118e:	cd660613          	addi	a2,a2,-810 # ffffffffc0204e60 <commands+0x760>
ffffffffc0201192:	10600593          	li	a1,262
ffffffffc0201196:	00004517          	auipc	a0,0x4
ffffffffc020119a:	ce250513          	addi	a0,a0,-798 # ffffffffc0204e78 <commands+0x778>
ffffffffc020119e:	9d6ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc02011a2:	00004697          	auipc	a3,0x4
ffffffffc02011a6:	ee668693          	addi	a3,a3,-282 # ffffffffc0205088 <commands+0x988>
ffffffffc02011aa:	00004617          	auipc	a2,0x4
ffffffffc02011ae:	cb660613          	addi	a2,a2,-842 # ffffffffc0204e60 <commands+0x760>
ffffffffc02011b2:	10500593          	li	a1,261
ffffffffc02011b6:	00004517          	auipc	a0,0x4
ffffffffc02011ba:	cc250513          	addi	a0,a0,-830 # ffffffffc0204e78 <commands+0x778>
ffffffffc02011be:	9b6ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc02011c2:	00004697          	auipc	a3,0x4
ffffffffc02011c6:	eae68693          	addi	a3,a3,-338 # ffffffffc0205070 <commands+0x970>
ffffffffc02011ca:	00004617          	auipc	a2,0x4
ffffffffc02011ce:	c9660613          	addi	a2,a2,-874 # ffffffffc0204e60 <commands+0x760>
ffffffffc02011d2:	10400593          	li	a1,260
ffffffffc02011d6:	00004517          	auipc	a0,0x4
ffffffffc02011da:	ca250513          	addi	a0,a0,-862 # ffffffffc0204e78 <commands+0x778>
ffffffffc02011de:	996ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02011e2:	00004697          	auipc	a3,0x4
ffffffffc02011e6:	df668693          	addi	a3,a3,-522 # ffffffffc0204fd8 <commands+0x8d8>
ffffffffc02011ea:	00004617          	auipc	a2,0x4
ffffffffc02011ee:	c7660613          	addi	a2,a2,-906 # ffffffffc0204e60 <commands+0x760>
ffffffffc02011f2:	0fe00593          	li	a1,254
ffffffffc02011f6:	00004517          	auipc	a0,0x4
ffffffffc02011fa:	c8250513          	addi	a0,a0,-894 # ffffffffc0204e78 <commands+0x778>
ffffffffc02011fe:	976ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(!PageProperty(p0));
ffffffffc0201202:	00004697          	auipc	a3,0x4
ffffffffc0201206:	e5668693          	addi	a3,a3,-426 # ffffffffc0205058 <commands+0x958>
ffffffffc020120a:	00004617          	auipc	a2,0x4
ffffffffc020120e:	c5660613          	addi	a2,a2,-938 # ffffffffc0204e60 <commands+0x760>
ffffffffc0201212:	0f900593          	li	a1,249
ffffffffc0201216:	00004517          	auipc	a0,0x4
ffffffffc020121a:	c6250513          	addi	a0,a0,-926 # ffffffffc0204e78 <commands+0x778>
ffffffffc020121e:	956ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0201222:	00004697          	auipc	a3,0x4
ffffffffc0201226:	f5668693          	addi	a3,a3,-170 # ffffffffc0205178 <commands+0xa78>
ffffffffc020122a:	00004617          	auipc	a2,0x4
ffffffffc020122e:	c3660613          	addi	a2,a2,-970 # ffffffffc0204e60 <commands+0x760>
ffffffffc0201232:	11700593          	li	a1,279
ffffffffc0201236:	00004517          	auipc	a0,0x4
ffffffffc020123a:	c4250513          	addi	a0,a0,-958 # ffffffffc0204e78 <commands+0x778>
ffffffffc020123e:	936ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(total == 0);
ffffffffc0201242:	00004697          	auipc	a3,0x4
ffffffffc0201246:	f6668693          	addi	a3,a3,-154 # ffffffffc02051a8 <commands+0xaa8>
ffffffffc020124a:	00004617          	auipc	a2,0x4
ffffffffc020124e:	c1660613          	addi	a2,a2,-1002 # ffffffffc0204e60 <commands+0x760>
ffffffffc0201252:	12600593          	li	a1,294
ffffffffc0201256:	00004517          	auipc	a0,0x4
ffffffffc020125a:	c2250513          	addi	a0,a0,-990 # ffffffffc0204e78 <commands+0x778>
ffffffffc020125e:	916ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(total == nr_free_pages());
ffffffffc0201262:	00004697          	auipc	a3,0x4
ffffffffc0201266:	c2e68693          	addi	a3,a3,-978 # ffffffffc0204e90 <commands+0x790>
ffffffffc020126a:	00004617          	auipc	a2,0x4
ffffffffc020126e:	bf660613          	addi	a2,a2,-1034 # ffffffffc0204e60 <commands+0x760>
ffffffffc0201272:	0f300593          	li	a1,243
ffffffffc0201276:	00004517          	auipc	a0,0x4
ffffffffc020127a:	c0250513          	addi	a0,a0,-1022 # ffffffffc0204e78 <commands+0x778>
ffffffffc020127e:	8f6ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201282:	00004697          	auipc	a3,0x4
ffffffffc0201286:	c4e68693          	addi	a3,a3,-946 # ffffffffc0204ed0 <commands+0x7d0>
ffffffffc020128a:	00004617          	auipc	a2,0x4
ffffffffc020128e:	bd660613          	addi	a2,a2,-1066 # ffffffffc0204e60 <commands+0x760>
ffffffffc0201292:	0ba00593          	li	a1,186
ffffffffc0201296:	00004517          	auipc	a0,0x4
ffffffffc020129a:	be250513          	addi	a0,a0,-1054 # ffffffffc0204e78 <commands+0x778>
ffffffffc020129e:	8d6ff0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc02012a2 <default_free_pages>:
default_free_pages(struct Page *base, size_t n) {
ffffffffc02012a2:	1141                	addi	sp,sp,-16
ffffffffc02012a4:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02012a6:	14058a63          	beqz	a1,ffffffffc02013fa <default_free_pages+0x158>
    for (; p != base + n; p ++) {
ffffffffc02012aa:	00359693          	slli	a3,a1,0x3
ffffffffc02012ae:	96ae                	add	a3,a3,a1
ffffffffc02012b0:	068e                	slli	a3,a3,0x3
ffffffffc02012b2:	96aa                	add	a3,a3,a0
ffffffffc02012b4:	87aa                	mv	a5,a0
ffffffffc02012b6:	02d50263          	beq	a0,a3,ffffffffc02012da <default_free_pages+0x38>
ffffffffc02012ba:	6798                	ld	a4,8(a5)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc02012bc:	8b05                	andi	a4,a4,1
ffffffffc02012be:	10071e63          	bnez	a4,ffffffffc02013da <default_free_pages+0x138>
ffffffffc02012c2:	6798                	ld	a4,8(a5)
ffffffffc02012c4:	8b09                	andi	a4,a4,2
ffffffffc02012c6:	10071a63          	bnez	a4,ffffffffc02013da <default_free_pages+0x138>
        p->flags = 0;
ffffffffc02012ca:	0007b423          	sd	zero,8(a5)
    return pa2page(PDE_ADDR(pde));
}

static inline int page_ref(struct Page *page) { return page->ref; }

static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc02012ce:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc02012d2:	04878793          	addi	a5,a5,72
ffffffffc02012d6:	fed792e3          	bne	a5,a3,ffffffffc02012ba <default_free_pages+0x18>
    base->property = n;
ffffffffc02012da:	2581                	sext.w	a1,a1
ffffffffc02012dc:	cd0c                	sw	a1,24(a0)
    SetPageProperty(base);
ffffffffc02012de:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02012e2:	4789                	li	a5,2
ffffffffc02012e4:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc02012e8:	00010697          	auipc	a3,0x10
ffffffffc02012ec:	d5868693          	addi	a3,a3,-680 # ffffffffc0211040 <free_area>
ffffffffc02012f0:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc02012f2:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc02012f4:	02050613          	addi	a2,a0,32
    nr_free += n;
ffffffffc02012f8:	9db9                	addw	a1,a1,a4
ffffffffc02012fa:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc02012fc:	0ad78863          	beq	a5,a3,ffffffffc02013ac <default_free_pages+0x10a>
            struct Page* page = le2page(le, page_link);
ffffffffc0201300:	fe078713          	addi	a4,a5,-32
ffffffffc0201304:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc0201308:	4581                	li	a1,0
            if (base < page) {
ffffffffc020130a:	00e56a63          	bltu	a0,a4,ffffffffc020131e <default_free_pages+0x7c>
    return listelm->next;
ffffffffc020130e:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0201310:	06d70263          	beq	a4,a3,ffffffffc0201374 <default_free_pages+0xd2>
    for (; p != base + n; p ++) {
ffffffffc0201314:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0201316:	fe078713          	addi	a4,a5,-32
            if (base < page) {
ffffffffc020131a:	fee57ae3          	bgeu	a0,a4,ffffffffc020130e <default_free_pages+0x6c>
ffffffffc020131e:	c199                	beqz	a1,ffffffffc0201324 <default_free_pages+0x82>
ffffffffc0201320:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc0201324:	6398                	ld	a4,0(a5)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc0201326:	e390                	sd	a2,0(a5)
ffffffffc0201328:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc020132a:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc020132c:	f118                	sd	a4,32(a0)
    if (le != &free_list) {
ffffffffc020132e:	02d70063          	beq	a4,a3,ffffffffc020134e <default_free_pages+0xac>
        if (p + p->property == base) {
ffffffffc0201332:	ff872803          	lw	a6,-8(a4)
        p = le2page(le, page_link);
ffffffffc0201336:	fe070593          	addi	a1,a4,-32
        if (p + p->property == base) {
ffffffffc020133a:	02081613          	slli	a2,a6,0x20
ffffffffc020133e:	9201                	srli	a2,a2,0x20
ffffffffc0201340:	00361793          	slli	a5,a2,0x3
ffffffffc0201344:	97b2                	add	a5,a5,a2
ffffffffc0201346:	078e                	slli	a5,a5,0x3
ffffffffc0201348:	97ae                	add	a5,a5,a1
ffffffffc020134a:	02f50f63          	beq	a0,a5,ffffffffc0201388 <default_free_pages+0xe6>
    return listelm->next;
ffffffffc020134e:	7518                	ld	a4,40(a0)
    if (le != &free_list) {
ffffffffc0201350:	00d70f63          	beq	a4,a3,ffffffffc020136e <default_free_pages+0xcc>
        if (base + base->property == p) {
ffffffffc0201354:	4d0c                	lw	a1,24(a0)
        p = le2page(le, page_link);
ffffffffc0201356:	fe070693          	addi	a3,a4,-32
        if (base + base->property == p) {
ffffffffc020135a:	02059613          	slli	a2,a1,0x20
ffffffffc020135e:	9201                	srli	a2,a2,0x20
ffffffffc0201360:	00361793          	slli	a5,a2,0x3
ffffffffc0201364:	97b2                	add	a5,a5,a2
ffffffffc0201366:	078e                	slli	a5,a5,0x3
ffffffffc0201368:	97aa                	add	a5,a5,a0
ffffffffc020136a:	04f68863          	beq	a3,a5,ffffffffc02013ba <default_free_pages+0x118>
}
ffffffffc020136e:	60a2                	ld	ra,8(sp)
ffffffffc0201370:	0141                	addi	sp,sp,16
ffffffffc0201372:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0201374:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201376:	f514                	sd	a3,40(a0)
    return listelm->next;
ffffffffc0201378:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc020137a:	f11c                	sd	a5,32(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc020137c:	02d70563          	beq	a4,a3,ffffffffc02013a6 <default_free_pages+0x104>
    prev->next = next->prev = elm;
ffffffffc0201380:	8832                	mv	a6,a2
ffffffffc0201382:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc0201384:	87ba                	mv	a5,a4
ffffffffc0201386:	bf41                	j	ffffffffc0201316 <default_free_pages+0x74>
            p->property += base->property;
ffffffffc0201388:	4d1c                	lw	a5,24(a0)
ffffffffc020138a:	0107883b          	addw	a6,a5,a6
ffffffffc020138e:	ff072c23          	sw	a6,-8(a4)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0201392:	57f5                	li	a5,-3
ffffffffc0201394:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201398:	7110                	ld	a2,32(a0)
ffffffffc020139a:	751c                	ld	a5,40(a0)
            base = p;
ffffffffc020139c:	852e                	mv	a0,a1
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc020139e:	e61c                	sd	a5,8(a2)
    return listelm->next;
ffffffffc02013a0:	6718                	ld	a4,8(a4)
    next->prev = prev;
ffffffffc02013a2:	e390                	sd	a2,0(a5)
ffffffffc02013a4:	b775                	j	ffffffffc0201350 <default_free_pages+0xae>
ffffffffc02013a6:	e290                	sd	a2,0(a3)
        while ((le = list_next(le)) != &free_list) {
ffffffffc02013a8:	873e                	mv	a4,a5
ffffffffc02013aa:	b761                	j	ffffffffc0201332 <default_free_pages+0x90>
}
ffffffffc02013ac:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc02013ae:	e390                	sd	a2,0(a5)
ffffffffc02013b0:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02013b2:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc02013b4:	f11c                	sd	a5,32(a0)
ffffffffc02013b6:	0141                	addi	sp,sp,16
ffffffffc02013b8:	8082                	ret
            base->property += p->property;
ffffffffc02013ba:	ff872783          	lw	a5,-8(a4)
ffffffffc02013be:	fe870693          	addi	a3,a4,-24
ffffffffc02013c2:	9dbd                	addw	a1,a1,a5
ffffffffc02013c4:	cd0c                	sw	a1,24(a0)
ffffffffc02013c6:	57f5                	li	a5,-3
ffffffffc02013c8:	60f6b02f          	amoand.d	zero,a5,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc02013cc:	6314                	ld	a3,0(a4)
ffffffffc02013ce:	671c                	ld	a5,8(a4)
}
ffffffffc02013d0:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc02013d2:	e69c                	sd	a5,8(a3)
    next->prev = prev;
ffffffffc02013d4:	e394                	sd	a3,0(a5)
ffffffffc02013d6:	0141                	addi	sp,sp,16
ffffffffc02013d8:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc02013da:	00004697          	auipc	a3,0x4
ffffffffc02013de:	de668693          	addi	a3,a3,-538 # ffffffffc02051c0 <commands+0xac0>
ffffffffc02013e2:	00004617          	auipc	a2,0x4
ffffffffc02013e6:	a7e60613          	addi	a2,a2,-1410 # ffffffffc0204e60 <commands+0x760>
ffffffffc02013ea:	08300593          	li	a1,131
ffffffffc02013ee:	00004517          	auipc	a0,0x4
ffffffffc02013f2:	a8a50513          	addi	a0,a0,-1398 # ffffffffc0204e78 <commands+0x778>
ffffffffc02013f6:	f7ffe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(n > 0);
ffffffffc02013fa:	00004697          	auipc	a3,0x4
ffffffffc02013fe:	dbe68693          	addi	a3,a3,-578 # ffffffffc02051b8 <commands+0xab8>
ffffffffc0201402:	00004617          	auipc	a2,0x4
ffffffffc0201406:	a5e60613          	addi	a2,a2,-1442 # ffffffffc0204e60 <commands+0x760>
ffffffffc020140a:	08000593          	li	a1,128
ffffffffc020140e:	00004517          	auipc	a0,0x4
ffffffffc0201412:	a6a50513          	addi	a0,a0,-1430 # ffffffffc0204e78 <commands+0x778>
ffffffffc0201416:	f5ffe0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc020141a <default_alloc_pages>:
    assert(n > 0);
ffffffffc020141a:	c959                	beqz	a0,ffffffffc02014b0 <default_alloc_pages+0x96>
    if (n > nr_free) {
ffffffffc020141c:	00010597          	auipc	a1,0x10
ffffffffc0201420:	c2458593          	addi	a1,a1,-988 # ffffffffc0211040 <free_area>
ffffffffc0201424:	0105a803          	lw	a6,16(a1)
ffffffffc0201428:	862a                	mv	a2,a0
ffffffffc020142a:	02081793          	slli	a5,a6,0x20
ffffffffc020142e:	9381                	srli	a5,a5,0x20
ffffffffc0201430:	00a7ee63          	bltu	a5,a0,ffffffffc020144c <default_alloc_pages+0x32>
    list_entry_t *le = &free_list;
ffffffffc0201434:	87ae                	mv	a5,a1
ffffffffc0201436:	a801                	j	ffffffffc0201446 <default_alloc_pages+0x2c>
        if (p->property >= n) {
ffffffffc0201438:	ff87a703          	lw	a4,-8(a5)
ffffffffc020143c:	02071693          	slli	a3,a4,0x20
ffffffffc0201440:	9281                	srli	a3,a3,0x20
ffffffffc0201442:	00c6f763          	bgeu	a3,a2,ffffffffc0201450 <default_alloc_pages+0x36>
    return listelm->next;
ffffffffc0201446:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201448:	feb798e3          	bne	a5,a1,ffffffffc0201438 <default_alloc_pages+0x1e>
        return NULL;
ffffffffc020144c:	4501                	li	a0,0
}
ffffffffc020144e:	8082                	ret
    return listelm->prev;
ffffffffc0201450:	0007b883          	ld	a7,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201454:	0087b303          	ld	t1,8(a5)
        struct Page *p = le2page(le, page_link);
ffffffffc0201458:	fe078513          	addi	a0,a5,-32
            p->property = page->property - n;
ffffffffc020145c:	00060e1b          	sext.w	t3,a2
    prev->next = next;
ffffffffc0201460:	0068b423          	sd	t1,8(a7)
    next->prev = prev;
ffffffffc0201464:	01133023          	sd	a7,0(t1)
        if (page->property > n) {
ffffffffc0201468:	02d67b63          	bgeu	a2,a3,ffffffffc020149e <default_alloc_pages+0x84>
            struct Page *p = page + n;
ffffffffc020146c:	00361693          	slli	a3,a2,0x3
ffffffffc0201470:	96b2                	add	a3,a3,a2
ffffffffc0201472:	068e                	slli	a3,a3,0x3
ffffffffc0201474:	96aa                	add	a3,a3,a0
            p->property = page->property - n;
ffffffffc0201476:	41c7073b          	subw	a4,a4,t3
ffffffffc020147a:	ce98                	sw	a4,24(a3)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020147c:	00868613          	addi	a2,a3,8
ffffffffc0201480:	4709                	li	a4,2
ffffffffc0201482:	40e6302f          	amoor.d	zero,a4,(a2)
    __list_add(elm, listelm, listelm->next);
ffffffffc0201486:	0088b703          	ld	a4,8(a7)
            list_add(prev, &(p->page_link));
ffffffffc020148a:	02068613          	addi	a2,a3,32
        nr_free -= n;
ffffffffc020148e:	0105a803          	lw	a6,16(a1)
    prev->next = next->prev = elm;
ffffffffc0201492:	e310                	sd	a2,0(a4)
ffffffffc0201494:	00c8b423          	sd	a2,8(a7)
    elm->next = next;
ffffffffc0201498:	f698                	sd	a4,40(a3)
    elm->prev = prev;
ffffffffc020149a:	0316b023          	sd	a7,32(a3)
ffffffffc020149e:	41c8083b          	subw	a6,a6,t3
ffffffffc02014a2:	0105a823          	sw	a6,16(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02014a6:	5775                	li	a4,-3
ffffffffc02014a8:	17a1                	addi	a5,a5,-24
ffffffffc02014aa:	60e7b02f          	amoand.d	zero,a4,(a5)
}
ffffffffc02014ae:	8082                	ret
default_alloc_pages(size_t n) {
ffffffffc02014b0:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc02014b2:	00004697          	auipc	a3,0x4
ffffffffc02014b6:	d0668693          	addi	a3,a3,-762 # ffffffffc02051b8 <commands+0xab8>
ffffffffc02014ba:	00004617          	auipc	a2,0x4
ffffffffc02014be:	9a660613          	addi	a2,a2,-1626 # ffffffffc0204e60 <commands+0x760>
ffffffffc02014c2:	06200593          	li	a1,98
ffffffffc02014c6:	00004517          	auipc	a0,0x4
ffffffffc02014ca:	9b250513          	addi	a0,a0,-1614 # ffffffffc0204e78 <commands+0x778>
default_alloc_pages(size_t n) {
ffffffffc02014ce:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02014d0:	ea5fe0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc02014d4 <default_init_memmap>:
default_init_memmap(struct Page *base, size_t n) {
ffffffffc02014d4:	1141                	addi	sp,sp,-16
ffffffffc02014d6:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02014d8:	c9e1                	beqz	a1,ffffffffc02015a8 <default_init_memmap+0xd4>
    for (; p != base + n; p ++) {
ffffffffc02014da:	00359693          	slli	a3,a1,0x3
ffffffffc02014de:	96ae                	add	a3,a3,a1
ffffffffc02014e0:	068e                	slli	a3,a3,0x3
ffffffffc02014e2:	96aa                	add	a3,a3,a0
ffffffffc02014e4:	87aa                	mv	a5,a0
ffffffffc02014e6:	00d50f63          	beq	a0,a3,ffffffffc0201504 <default_init_memmap+0x30>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc02014ea:	6798                	ld	a4,8(a5)
        assert(PageReserved(p));
ffffffffc02014ec:	8b05                	andi	a4,a4,1
ffffffffc02014ee:	cf49                	beqz	a4,ffffffffc0201588 <default_init_memmap+0xb4>
        p->flags = p->property = 0;
ffffffffc02014f0:	0007ac23          	sw	zero,24(a5)
ffffffffc02014f4:	0007b423          	sd	zero,8(a5)
ffffffffc02014f8:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc02014fc:	04878793          	addi	a5,a5,72
ffffffffc0201500:	fed795e3          	bne	a5,a3,ffffffffc02014ea <default_init_memmap+0x16>
    base->property = n;
ffffffffc0201504:	2581                	sext.w	a1,a1
ffffffffc0201506:	cd0c                	sw	a1,24(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201508:	4789                	li	a5,2
ffffffffc020150a:	00850713          	addi	a4,a0,8
ffffffffc020150e:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc0201512:	00010697          	auipc	a3,0x10
ffffffffc0201516:	b2e68693          	addi	a3,a3,-1234 # ffffffffc0211040 <free_area>
ffffffffc020151a:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc020151c:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc020151e:	02050613          	addi	a2,a0,32
    nr_free += n;
ffffffffc0201522:	9db9                	addw	a1,a1,a4
ffffffffc0201524:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc0201526:	04d78a63          	beq	a5,a3,ffffffffc020157a <default_init_memmap+0xa6>
            struct Page* page = le2page(le, page_link);
ffffffffc020152a:	fe078713          	addi	a4,a5,-32
ffffffffc020152e:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc0201532:	4581                	li	a1,0
            if (base < page) {
ffffffffc0201534:	00e56a63          	bltu	a0,a4,ffffffffc0201548 <default_init_memmap+0x74>
    return listelm->next;
ffffffffc0201538:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc020153a:	02d70263          	beq	a4,a3,ffffffffc020155e <default_init_memmap+0x8a>
    for (; p != base + n; p ++) {
ffffffffc020153e:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0201540:	fe078713          	addi	a4,a5,-32
            if (base < page) {
ffffffffc0201544:	fee57ae3          	bgeu	a0,a4,ffffffffc0201538 <default_init_memmap+0x64>
ffffffffc0201548:	c199                	beqz	a1,ffffffffc020154e <default_init_memmap+0x7a>
ffffffffc020154a:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc020154e:	6398                	ld	a4,0(a5)
}
ffffffffc0201550:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0201552:	e390                	sd	a2,0(a5)
ffffffffc0201554:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc0201556:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc0201558:	f118                	sd	a4,32(a0)
ffffffffc020155a:	0141                	addi	sp,sp,16
ffffffffc020155c:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc020155e:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201560:	f514                	sd	a3,40(a0)
    return listelm->next;
ffffffffc0201562:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0201564:	f11c                	sd	a5,32(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201566:	00d70663          	beq	a4,a3,ffffffffc0201572 <default_init_memmap+0x9e>
    prev->next = next->prev = elm;
ffffffffc020156a:	8832                	mv	a6,a2
ffffffffc020156c:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc020156e:	87ba                	mv	a5,a4
ffffffffc0201570:	bfc1                	j	ffffffffc0201540 <default_init_memmap+0x6c>
}
ffffffffc0201572:	60a2                	ld	ra,8(sp)
ffffffffc0201574:	e290                	sd	a2,0(a3)
ffffffffc0201576:	0141                	addi	sp,sp,16
ffffffffc0201578:	8082                	ret
ffffffffc020157a:	60a2                	ld	ra,8(sp)
ffffffffc020157c:	e390                	sd	a2,0(a5)
ffffffffc020157e:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201580:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc0201582:	f11c                	sd	a5,32(a0)
ffffffffc0201584:	0141                	addi	sp,sp,16
ffffffffc0201586:	8082                	ret
        assert(PageReserved(p));
ffffffffc0201588:	00004697          	auipc	a3,0x4
ffffffffc020158c:	c6068693          	addi	a3,a3,-928 # ffffffffc02051e8 <commands+0xae8>
ffffffffc0201590:	00004617          	auipc	a2,0x4
ffffffffc0201594:	8d060613          	addi	a2,a2,-1840 # ffffffffc0204e60 <commands+0x760>
ffffffffc0201598:	04900593          	li	a1,73
ffffffffc020159c:	00004517          	auipc	a0,0x4
ffffffffc02015a0:	8dc50513          	addi	a0,a0,-1828 # ffffffffc0204e78 <commands+0x778>
ffffffffc02015a4:	dd1fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(n > 0);
ffffffffc02015a8:	00004697          	auipc	a3,0x4
ffffffffc02015ac:	c1068693          	addi	a3,a3,-1008 # ffffffffc02051b8 <commands+0xab8>
ffffffffc02015b0:	00004617          	auipc	a2,0x4
ffffffffc02015b4:	8b060613          	addi	a2,a2,-1872 # ffffffffc0204e60 <commands+0x760>
ffffffffc02015b8:	04600593          	li	a1,70
ffffffffc02015bc:	00004517          	auipc	a0,0x4
ffffffffc02015c0:	8bc50513          	addi	a0,a0,-1860 # ffffffffc0204e78 <commands+0x778>
ffffffffc02015c4:	db1fe0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc02015c8 <pa2page.part.0>:
static inline struct Page *pa2page(uintptr_t pa) {
ffffffffc02015c8:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc02015ca:	00004617          	auipc	a2,0x4
ffffffffc02015ce:	c7e60613          	addi	a2,a2,-898 # ffffffffc0205248 <default_pmm_manager+0x38>
ffffffffc02015d2:	06500593          	li	a1,101
ffffffffc02015d6:	00004517          	auipc	a0,0x4
ffffffffc02015da:	c9250513          	addi	a0,a0,-878 # ffffffffc0205268 <default_pmm_manager+0x58>
static inline struct Page *pa2page(uintptr_t pa) {
ffffffffc02015de:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc02015e0:	d95fe0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc02015e4 <pte2page.part.0>:
static inline struct Page *pte2page(pte_t pte) {
ffffffffc02015e4:	1141                	addi	sp,sp,-16
        panic("pte2page called with invalid pte");
ffffffffc02015e6:	00004617          	auipc	a2,0x4
ffffffffc02015ea:	c9260613          	addi	a2,a2,-878 # ffffffffc0205278 <default_pmm_manager+0x68>
ffffffffc02015ee:	07000593          	li	a1,112
ffffffffc02015f2:	00004517          	auipc	a0,0x4
ffffffffc02015f6:	c7650513          	addi	a0,a0,-906 # ffffffffc0205268 <default_pmm_manager+0x58>
static inline struct Page *pte2page(pte_t pte) {
ffffffffc02015fa:	e406                	sd	ra,8(sp)
        panic("pte2page called with invalid pte");
ffffffffc02015fc:	d79fe0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0201600 <alloc_pages>:
    pmm_manager->init_memmap(base, n);
}

// alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE
// memory
struct Page *alloc_pages(size_t n) {
ffffffffc0201600:	7139                	addi	sp,sp,-64
ffffffffc0201602:	f426                	sd	s1,40(sp)
ffffffffc0201604:	f04a                	sd	s2,32(sp)
ffffffffc0201606:	ec4e                	sd	s3,24(sp)
ffffffffc0201608:	e852                	sd	s4,16(sp)
ffffffffc020160a:	e456                	sd	s5,8(sp)
ffffffffc020160c:	e05a                	sd	s6,0(sp)
ffffffffc020160e:	fc06                	sd	ra,56(sp)
ffffffffc0201610:	f822                	sd	s0,48(sp)
ffffffffc0201612:	84aa                	mv	s1,a0
ffffffffc0201614:	00010917          	auipc	s2,0x10
ffffffffc0201618:	f2490913          	addi	s2,s2,-220 # ffffffffc0211538 <pmm_manager>
    while (1) {
        local_intr_save(intr_flag);
        { page = pmm_manager->alloc_pages(n); }
        local_intr_restore(intr_flag);

        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc020161c:	4a05                	li	s4,1
ffffffffc020161e:	00010a97          	auipc	s5,0x10
ffffffffc0201622:	f3aa8a93          	addi	s5,s5,-198 # ffffffffc0211558 <swap_init_ok>

        extern struct mm_struct *check_mm_struct;
        // cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
        swap_out(check_mm_struct, n, 0);
ffffffffc0201626:	0005099b          	sext.w	s3,a0
ffffffffc020162a:	00010b17          	auipc	s6,0x10
ffffffffc020162e:	f36b0b13          	addi	s6,s6,-202 # ffffffffc0211560 <check_mm_struct>
ffffffffc0201632:	a01d                	j	ffffffffc0201658 <alloc_pages+0x58>
        { page = pmm_manager->alloc_pages(n); }
ffffffffc0201634:	00093783          	ld	a5,0(s2)
ffffffffc0201638:	6f9c                	ld	a5,24(a5)
ffffffffc020163a:	9782                	jalr	a5
ffffffffc020163c:	842a                	mv	s0,a0
        swap_out(check_mm_struct, n, 0);
ffffffffc020163e:	4601                	li	a2,0
ffffffffc0201640:	85ce                	mv	a1,s3
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0201642:	ec0d                	bnez	s0,ffffffffc020167c <alloc_pages+0x7c>
ffffffffc0201644:	029a6c63          	bltu	s4,s1,ffffffffc020167c <alloc_pages+0x7c>
ffffffffc0201648:	000aa783          	lw	a5,0(s5)
ffffffffc020164c:	2781                	sext.w	a5,a5
ffffffffc020164e:	c79d                	beqz	a5,ffffffffc020167c <alloc_pages+0x7c>
        swap_out(check_mm_struct, n, 0);
ffffffffc0201650:	000b3503          	ld	a0,0(s6)
ffffffffc0201654:	189010ef          	jal	ra,ffffffffc0202fdc <swap_out>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201658:	100027f3          	csrr	a5,sstatus
ffffffffc020165c:	8b89                	andi	a5,a5,2
        { page = pmm_manager->alloc_pages(n); }
ffffffffc020165e:	8526                	mv	a0,s1
ffffffffc0201660:	dbf1                	beqz	a5,ffffffffc0201634 <alloc_pages+0x34>
        intr_disable();
ffffffffc0201662:	e8dfe0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc0201666:	00093783          	ld	a5,0(s2)
ffffffffc020166a:	8526                	mv	a0,s1
ffffffffc020166c:	6f9c                	ld	a5,24(a5)
ffffffffc020166e:	9782                	jalr	a5
ffffffffc0201670:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0201672:	e77fe0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
        swap_out(check_mm_struct, n, 0);
ffffffffc0201676:	4601                	li	a2,0
ffffffffc0201678:	85ce                	mv	a1,s3
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc020167a:	d469                	beqz	s0,ffffffffc0201644 <alloc_pages+0x44>
    }
    // cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
}
ffffffffc020167c:	70e2                	ld	ra,56(sp)
ffffffffc020167e:	8522                	mv	a0,s0
ffffffffc0201680:	7442                	ld	s0,48(sp)
ffffffffc0201682:	74a2                	ld	s1,40(sp)
ffffffffc0201684:	7902                	ld	s2,32(sp)
ffffffffc0201686:	69e2                	ld	s3,24(sp)
ffffffffc0201688:	6a42                	ld	s4,16(sp)
ffffffffc020168a:	6aa2                	ld	s5,8(sp)
ffffffffc020168c:	6b02                	ld	s6,0(sp)
ffffffffc020168e:	6121                	addi	sp,sp,64
ffffffffc0201690:	8082                	ret

ffffffffc0201692 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201692:	100027f3          	csrr	a5,sstatus
ffffffffc0201696:	8b89                	andi	a5,a5,2
ffffffffc0201698:	e799                	bnez	a5,ffffffffc02016a6 <free_pages+0x14>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;

    local_intr_save(intr_flag);
    { pmm_manager->free_pages(base, n); }
ffffffffc020169a:	00010797          	auipc	a5,0x10
ffffffffc020169e:	e9e7b783          	ld	a5,-354(a5) # ffffffffc0211538 <pmm_manager>
ffffffffc02016a2:	739c                	ld	a5,32(a5)
ffffffffc02016a4:	8782                	jr	a5
void free_pages(struct Page *base, size_t n) {
ffffffffc02016a6:	1101                	addi	sp,sp,-32
ffffffffc02016a8:	ec06                	sd	ra,24(sp)
ffffffffc02016aa:	e822                	sd	s0,16(sp)
ffffffffc02016ac:	e426                	sd	s1,8(sp)
ffffffffc02016ae:	842a                	mv	s0,a0
ffffffffc02016b0:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc02016b2:	e3dfe0ef          	jal	ra,ffffffffc02004ee <intr_disable>
    { pmm_manager->free_pages(base, n); }
ffffffffc02016b6:	00010797          	auipc	a5,0x10
ffffffffc02016ba:	e827b783          	ld	a5,-382(a5) # ffffffffc0211538 <pmm_manager>
ffffffffc02016be:	739c                	ld	a5,32(a5)
ffffffffc02016c0:	85a6                	mv	a1,s1
ffffffffc02016c2:	8522                	mv	a0,s0
ffffffffc02016c4:	9782                	jalr	a5
    local_intr_restore(intr_flag);
}
ffffffffc02016c6:	6442                	ld	s0,16(sp)
ffffffffc02016c8:	60e2                	ld	ra,24(sp)
ffffffffc02016ca:	64a2                	ld	s1,8(sp)
ffffffffc02016cc:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc02016ce:	e1bfe06f          	j	ffffffffc02004e8 <intr_enable>

ffffffffc02016d2 <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02016d2:	100027f3          	csrr	a5,sstatus
ffffffffc02016d6:	8b89                	andi	a5,a5,2
ffffffffc02016d8:	e799                	bnez	a5,ffffffffc02016e6 <nr_free_pages+0x14>
// of current free memory
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc02016da:	00010797          	auipc	a5,0x10
ffffffffc02016de:	e5e7b783          	ld	a5,-418(a5) # ffffffffc0211538 <pmm_manager>
ffffffffc02016e2:	779c                	ld	a5,40(a5)
ffffffffc02016e4:	8782                	jr	a5
size_t nr_free_pages(void) {
ffffffffc02016e6:	1141                	addi	sp,sp,-16
ffffffffc02016e8:	e406                	sd	ra,8(sp)
ffffffffc02016ea:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc02016ec:	e03fe0ef          	jal	ra,ffffffffc02004ee <intr_disable>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc02016f0:	00010797          	auipc	a5,0x10
ffffffffc02016f4:	e487b783          	ld	a5,-440(a5) # ffffffffc0211538 <pmm_manager>
ffffffffc02016f8:	779c                	ld	a5,40(a5)
ffffffffc02016fa:	9782                	jalr	a5
ffffffffc02016fc:	842a                	mv	s0,a0
        intr_enable();
ffffffffc02016fe:	debfe0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc0201702:	60a2                	ld	ra,8(sp)
ffffffffc0201704:	8522                	mv	a0,s0
ffffffffc0201706:	6402                	ld	s0,0(sp)
ffffffffc0201708:	0141                	addi	sp,sp,16
ffffffffc020170a:	8082                	ret

ffffffffc020170c <get_pte>:
     *   PTE_W           0x002                   // page table/directory entry
     * flags bit : Writeable
     *   PTE_U           0x004                   // page table/directory entry
     * flags bit : User can access
     */
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc020170c:	01e5d793          	srli	a5,a1,0x1e
ffffffffc0201710:	1ff7f793          	andi	a5,a5,511
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0201714:	715d                	addi	sp,sp,-80
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0201716:	078e                	slli	a5,a5,0x3
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0201718:	fc26                	sd	s1,56(sp)
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc020171a:	00f504b3          	add	s1,a0,a5
    if (!(*pdep1 & PTE_V)) {
ffffffffc020171e:	6094                	ld	a3,0(s1)
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0201720:	f84a                	sd	s2,48(sp)
ffffffffc0201722:	f44e                	sd	s3,40(sp)
ffffffffc0201724:	f052                	sd	s4,32(sp)
ffffffffc0201726:	e486                	sd	ra,72(sp)
ffffffffc0201728:	e0a2                	sd	s0,64(sp)
ffffffffc020172a:	ec56                	sd	s5,24(sp)
ffffffffc020172c:	e85a                	sd	s6,16(sp)
ffffffffc020172e:	e45e                	sd	s7,8(sp)
    if (!(*pdep1 & PTE_V)) {
ffffffffc0201730:	0016f793          	andi	a5,a3,1
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0201734:	892e                	mv	s2,a1
ffffffffc0201736:	8a32                	mv	s4,a2
ffffffffc0201738:	00010997          	auipc	s3,0x10
ffffffffc020173c:	df098993          	addi	s3,s3,-528 # ffffffffc0211528 <npage>
    if (!(*pdep1 & PTE_V)) {
ffffffffc0201740:	efb5                	bnez	a5,ffffffffc02017bc <get_pte+0xb0>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc0201742:	14060c63          	beqz	a2,ffffffffc020189a <get_pte+0x18e>
ffffffffc0201746:	4505                	li	a0,1
ffffffffc0201748:	eb9ff0ef          	jal	ra,ffffffffc0201600 <alloc_pages>
ffffffffc020174c:	842a                	mv	s0,a0
ffffffffc020174e:	14050663          	beqz	a0,ffffffffc020189a <get_pte+0x18e>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201752:	00010b97          	auipc	s7,0x10
ffffffffc0201756:	ddeb8b93          	addi	s7,s7,-546 # ffffffffc0211530 <pages>
ffffffffc020175a:	000bb503          	ld	a0,0(s7)
ffffffffc020175e:	00005b17          	auipc	s6,0x5
ffffffffc0201762:	cbab3b03          	ld	s6,-838(s6) # ffffffffc0206418 <error_string+0x38>
ffffffffc0201766:	00080ab7          	lui	s5,0x80
ffffffffc020176a:	40a40533          	sub	a0,s0,a0
ffffffffc020176e:	850d                	srai	a0,a0,0x3
ffffffffc0201770:	03650533          	mul	a0,a0,s6
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201774:	00010997          	auipc	s3,0x10
ffffffffc0201778:	db498993          	addi	s3,s3,-588 # ffffffffc0211528 <npage>
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc020177c:	4785                	li	a5,1
ffffffffc020177e:	0009b703          	ld	a4,0(s3)
ffffffffc0201782:	c01c                	sw	a5,0(s0)
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201784:	9556                	add	a0,a0,s5
ffffffffc0201786:	00c51793          	slli	a5,a0,0xc
ffffffffc020178a:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc020178c:	0532                	slli	a0,a0,0xc
ffffffffc020178e:	14e7fd63          	bgeu	a5,a4,ffffffffc02018e8 <get_pte+0x1dc>
ffffffffc0201792:	00010797          	auipc	a5,0x10
ffffffffc0201796:	dae7b783          	ld	a5,-594(a5) # ffffffffc0211540 <va_pa_offset>
ffffffffc020179a:	6605                	lui	a2,0x1
ffffffffc020179c:	4581                	li	a1,0
ffffffffc020179e:	953e                	add	a0,a0,a5
ffffffffc02017a0:	4dd020ef          	jal	ra,ffffffffc020447c <memset>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02017a4:	000bb683          	ld	a3,0(s7)
ffffffffc02017a8:	40d406b3          	sub	a3,s0,a3
ffffffffc02017ac:	868d                	srai	a3,a3,0x3
ffffffffc02017ae:	036686b3          	mul	a3,a3,s6
ffffffffc02017b2:	96d6                	add	a3,a3,s5

static inline void flush_tlb() { asm volatile("sfence.vma"); }

// construct PTE from a page and permission bits
static inline pte_t pte_create(uintptr_t ppn, int type) {
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc02017b4:	06aa                	slli	a3,a3,0xa
ffffffffc02017b6:	0116e693          	ori	a3,a3,17
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc02017ba:	e094                	sd	a3,0(s1)
    }
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc02017bc:	77fd                	lui	a5,0xfffff
ffffffffc02017be:	068a                	slli	a3,a3,0x2
ffffffffc02017c0:	0009b703          	ld	a4,0(s3)
ffffffffc02017c4:	8efd                	and	a3,a3,a5
ffffffffc02017c6:	00c6d793          	srli	a5,a3,0xc
ffffffffc02017ca:	0ce7fa63          	bgeu	a5,a4,ffffffffc020189e <get_pte+0x192>
ffffffffc02017ce:	00010a97          	auipc	s5,0x10
ffffffffc02017d2:	d72a8a93          	addi	s5,s5,-654 # ffffffffc0211540 <va_pa_offset>
ffffffffc02017d6:	000ab403          	ld	s0,0(s5)
ffffffffc02017da:	01595793          	srli	a5,s2,0x15
ffffffffc02017de:	1ff7f793          	andi	a5,a5,511
ffffffffc02017e2:	96a2                	add	a3,a3,s0
ffffffffc02017e4:	00379413          	slli	s0,a5,0x3
ffffffffc02017e8:	9436                	add	s0,s0,a3
//    pde_t *pdep0 = &((pde_t *)(PDE_ADDR(*pdep1)))[PDX0(la)];
    if (!(*pdep0 & PTE_V)) {
ffffffffc02017ea:	6014                	ld	a3,0(s0)
ffffffffc02017ec:	0016f793          	andi	a5,a3,1
ffffffffc02017f0:	ebad                	bnez	a5,ffffffffc0201862 <get_pte+0x156>
    	struct Page *page;
    	if (!create || (page = alloc_page()) == NULL) {
ffffffffc02017f2:	0a0a0463          	beqz	s4,ffffffffc020189a <get_pte+0x18e>
ffffffffc02017f6:	4505                	li	a0,1
ffffffffc02017f8:	e09ff0ef          	jal	ra,ffffffffc0201600 <alloc_pages>
ffffffffc02017fc:	84aa                	mv	s1,a0
ffffffffc02017fe:	cd51                	beqz	a0,ffffffffc020189a <get_pte+0x18e>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201800:	00010b97          	auipc	s7,0x10
ffffffffc0201804:	d30b8b93          	addi	s7,s7,-720 # ffffffffc0211530 <pages>
ffffffffc0201808:	000bb503          	ld	a0,0(s7)
ffffffffc020180c:	00005b17          	auipc	s6,0x5
ffffffffc0201810:	c0cb3b03          	ld	s6,-1012(s6) # ffffffffc0206418 <error_string+0x38>
ffffffffc0201814:	00080a37          	lui	s4,0x80
ffffffffc0201818:	40a48533          	sub	a0,s1,a0
ffffffffc020181c:	850d                	srai	a0,a0,0x3
ffffffffc020181e:	03650533          	mul	a0,a0,s6
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0201822:	4785                	li	a5,1
    		return NULL;
    	}
    	set_page_ref(page, 1);
    	uintptr_t pa = page2pa(page);
    	memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201824:	0009b703          	ld	a4,0(s3)
ffffffffc0201828:	c09c                	sw	a5,0(s1)
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc020182a:	9552                	add	a0,a0,s4
ffffffffc020182c:	00c51793          	slli	a5,a0,0xc
ffffffffc0201830:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0201832:	0532                	slli	a0,a0,0xc
ffffffffc0201834:	08e7fd63          	bgeu	a5,a4,ffffffffc02018ce <get_pte+0x1c2>
ffffffffc0201838:	000ab783          	ld	a5,0(s5)
ffffffffc020183c:	6605                	lui	a2,0x1
ffffffffc020183e:	4581                	li	a1,0
ffffffffc0201840:	953e                	add	a0,a0,a5
ffffffffc0201842:	43b020ef          	jal	ra,ffffffffc020447c <memset>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201846:	000bb683          	ld	a3,0(s7)
ffffffffc020184a:	40d486b3          	sub	a3,s1,a3
ffffffffc020184e:	868d                	srai	a3,a3,0x3
ffffffffc0201850:	036686b3          	mul	a3,a3,s6
ffffffffc0201854:	96d2                	add	a3,a3,s4
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0201856:	06aa                	slli	a3,a3,0xa
ffffffffc0201858:	0116e693          	ori	a3,a3,17
 //   	memset(pa, 0, PGSIZE);
    	*pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc020185c:	e014                	sd	a3,0(s0)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc020185e:	0009b703          	ld	a4,0(s3)
ffffffffc0201862:	068a                	slli	a3,a3,0x2
ffffffffc0201864:	757d                	lui	a0,0xfffff
ffffffffc0201866:	8ee9                	and	a3,a3,a0
ffffffffc0201868:	00c6d793          	srli	a5,a3,0xc
ffffffffc020186c:	04e7f563          	bgeu	a5,a4,ffffffffc02018b6 <get_pte+0x1aa>
ffffffffc0201870:	000ab503          	ld	a0,0(s5)
ffffffffc0201874:	00c95913          	srli	s2,s2,0xc
ffffffffc0201878:	1ff97913          	andi	s2,s2,511
ffffffffc020187c:	96aa                	add	a3,a3,a0
ffffffffc020187e:	00391513          	slli	a0,s2,0x3
ffffffffc0201882:	9536                	add	a0,a0,a3
}
ffffffffc0201884:	60a6                	ld	ra,72(sp)
ffffffffc0201886:	6406                	ld	s0,64(sp)
ffffffffc0201888:	74e2                	ld	s1,56(sp)
ffffffffc020188a:	7942                	ld	s2,48(sp)
ffffffffc020188c:	79a2                	ld	s3,40(sp)
ffffffffc020188e:	7a02                	ld	s4,32(sp)
ffffffffc0201890:	6ae2                	ld	s5,24(sp)
ffffffffc0201892:	6b42                	ld	s6,16(sp)
ffffffffc0201894:	6ba2                	ld	s7,8(sp)
ffffffffc0201896:	6161                	addi	sp,sp,80
ffffffffc0201898:	8082                	ret
            return NULL;
ffffffffc020189a:	4501                	li	a0,0
ffffffffc020189c:	b7e5                	j	ffffffffc0201884 <get_pte+0x178>
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc020189e:	00004617          	auipc	a2,0x4
ffffffffc02018a2:	a0260613          	addi	a2,a2,-1534 # ffffffffc02052a0 <default_pmm_manager+0x90>
ffffffffc02018a6:	10200593          	li	a1,258
ffffffffc02018aa:	00004517          	auipc	a0,0x4
ffffffffc02018ae:	a1e50513          	addi	a0,a0,-1506 # ffffffffc02052c8 <default_pmm_manager+0xb8>
ffffffffc02018b2:	ac3fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc02018b6:	00004617          	auipc	a2,0x4
ffffffffc02018ba:	9ea60613          	addi	a2,a2,-1558 # ffffffffc02052a0 <default_pmm_manager+0x90>
ffffffffc02018be:	10f00593          	li	a1,271
ffffffffc02018c2:	00004517          	auipc	a0,0x4
ffffffffc02018c6:	a0650513          	addi	a0,a0,-1530 # ffffffffc02052c8 <default_pmm_manager+0xb8>
ffffffffc02018ca:	aabfe0ef          	jal	ra,ffffffffc0200374 <__panic>
    	memset(KADDR(pa), 0, PGSIZE);
ffffffffc02018ce:	86aa                	mv	a3,a0
ffffffffc02018d0:	00004617          	auipc	a2,0x4
ffffffffc02018d4:	9d060613          	addi	a2,a2,-1584 # ffffffffc02052a0 <default_pmm_manager+0x90>
ffffffffc02018d8:	10b00593          	li	a1,267
ffffffffc02018dc:	00004517          	auipc	a0,0x4
ffffffffc02018e0:	9ec50513          	addi	a0,a0,-1556 # ffffffffc02052c8 <default_pmm_manager+0xb8>
ffffffffc02018e4:	a91fe0ef          	jal	ra,ffffffffc0200374 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc02018e8:	86aa                	mv	a3,a0
ffffffffc02018ea:	00004617          	auipc	a2,0x4
ffffffffc02018ee:	9b660613          	addi	a2,a2,-1610 # ffffffffc02052a0 <default_pmm_manager+0x90>
ffffffffc02018f2:	0ff00593          	li	a1,255
ffffffffc02018f6:	00004517          	auipc	a0,0x4
ffffffffc02018fa:	9d250513          	addi	a0,a0,-1582 # ffffffffc02052c8 <default_pmm_manager+0xb8>
ffffffffc02018fe:	a77fe0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0201902 <get_page>:

// get_page - get related Page struct for linear address la using PDT pgdir
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc0201902:	1141                	addi	sp,sp,-16
ffffffffc0201904:	e022                	sd	s0,0(sp)
ffffffffc0201906:	8432                	mv	s0,a2
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201908:	4601                	li	a2,0
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc020190a:	e406                	sd	ra,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc020190c:	e01ff0ef          	jal	ra,ffffffffc020170c <get_pte>
    if (ptep_store != NULL) {
ffffffffc0201910:	c011                	beqz	s0,ffffffffc0201914 <get_page+0x12>
        *ptep_store = ptep;
ffffffffc0201912:	e008                	sd	a0,0(s0)
    }
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc0201914:	c511                	beqz	a0,ffffffffc0201920 <get_page+0x1e>
ffffffffc0201916:	611c                	ld	a5,0(a0)
        return pte2page(*ptep);
    }
    return NULL;
ffffffffc0201918:	4501                	li	a0,0
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc020191a:	0017f713          	andi	a4,a5,1
ffffffffc020191e:	e709                	bnez	a4,ffffffffc0201928 <get_page+0x26>
}
ffffffffc0201920:	60a2                	ld	ra,8(sp)
ffffffffc0201922:	6402                	ld	s0,0(sp)
ffffffffc0201924:	0141                	addi	sp,sp,16
ffffffffc0201926:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0201928:	078a                	slli	a5,a5,0x2
ffffffffc020192a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020192c:	00010717          	auipc	a4,0x10
ffffffffc0201930:	bfc73703          	ld	a4,-1028(a4) # ffffffffc0211528 <npage>
ffffffffc0201934:	02e7f263          	bgeu	a5,a4,ffffffffc0201958 <get_page+0x56>
    return &pages[PPN(pa) - nbase];
ffffffffc0201938:	fff80537          	lui	a0,0xfff80
ffffffffc020193c:	97aa                	add	a5,a5,a0
ffffffffc020193e:	60a2                	ld	ra,8(sp)
ffffffffc0201940:	6402                	ld	s0,0(sp)
ffffffffc0201942:	00379513          	slli	a0,a5,0x3
ffffffffc0201946:	97aa                	add	a5,a5,a0
ffffffffc0201948:	078e                	slli	a5,a5,0x3
ffffffffc020194a:	00010517          	auipc	a0,0x10
ffffffffc020194e:	be653503          	ld	a0,-1050(a0) # ffffffffc0211530 <pages>
ffffffffc0201952:	953e                	add	a0,a0,a5
ffffffffc0201954:	0141                	addi	sp,sp,16
ffffffffc0201956:	8082                	ret
ffffffffc0201958:	c71ff0ef          	jal	ra,ffffffffc02015c8 <pa2page.part.0>

ffffffffc020195c <page_remove>:
    }
}

// page_remove - free an Page which is related linear address la and has an
// validated pte
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc020195c:	1101                	addi	sp,sp,-32
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc020195e:	4601                	li	a2,0
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0201960:	ec06                	sd	ra,24(sp)
ffffffffc0201962:	e822                	sd	s0,16(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201964:	da9ff0ef          	jal	ra,ffffffffc020170c <get_pte>
    if (ptep != NULL) {
ffffffffc0201968:	c511                	beqz	a0,ffffffffc0201974 <page_remove+0x18>
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc020196a:	611c                	ld	a5,0(a0)
ffffffffc020196c:	842a                	mv	s0,a0
ffffffffc020196e:	0017f713          	andi	a4,a5,1
ffffffffc0201972:	e709                	bnez	a4,ffffffffc020197c <page_remove+0x20>
        page_remove_pte(pgdir, la, ptep);
    }
}
ffffffffc0201974:	60e2                	ld	ra,24(sp)
ffffffffc0201976:	6442                	ld	s0,16(sp)
ffffffffc0201978:	6105                	addi	sp,sp,32
ffffffffc020197a:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc020197c:	078a                	slli	a5,a5,0x2
ffffffffc020197e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201980:	00010717          	auipc	a4,0x10
ffffffffc0201984:	ba873703          	ld	a4,-1112(a4) # ffffffffc0211528 <npage>
ffffffffc0201988:	06e7f563          	bgeu	a5,a4,ffffffffc02019f2 <page_remove+0x96>
    return &pages[PPN(pa) - nbase];
ffffffffc020198c:	fff80737          	lui	a4,0xfff80
ffffffffc0201990:	97ba                	add	a5,a5,a4
ffffffffc0201992:	00379513          	slli	a0,a5,0x3
ffffffffc0201996:	97aa                	add	a5,a5,a0
ffffffffc0201998:	078e                	slli	a5,a5,0x3
ffffffffc020199a:	00010517          	auipc	a0,0x10
ffffffffc020199e:	b9653503          	ld	a0,-1130(a0) # ffffffffc0211530 <pages>
ffffffffc02019a2:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc02019a4:	411c                	lw	a5,0(a0)
ffffffffc02019a6:	fff7871b          	addiw	a4,a5,-1
ffffffffc02019aa:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc02019ac:	cb09                	beqz	a4,ffffffffc02019be <page_remove+0x62>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc02019ae:	00043023          	sd	zero,0(s0)
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc02019b2:	12000073          	sfence.vma
}
ffffffffc02019b6:	60e2                	ld	ra,24(sp)
ffffffffc02019b8:	6442                	ld	s0,16(sp)
ffffffffc02019ba:	6105                	addi	sp,sp,32
ffffffffc02019bc:	8082                	ret
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02019be:	100027f3          	csrr	a5,sstatus
ffffffffc02019c2:	8b89                	andi	a5,a5,2
ffffffffc02019c4:	eb89                	bnez	a5,ffffffffc02019d6 <page_remove+0x7a>
    { pmm_manager->free_pages(base, n); }
ffffffffc02019c6:	00010797          	auipc	a5,0x10
ffffffffc02019ca:	b727b783          	ld	a5,-1166(a5) # ffffffffc0211538 <pmm_manager>
ffffffffc02019ce:	739c                	ld	a5,32(a5)
ffffffffc02019d0:	4585                	li	a1,1
ffffffffc02019d2:	9782                	jalr	a5
    if (flag) {
ffffffffc02019d4:	bfe9                	j	ffffffffc02019ae <page_remove+0x52>
        intr_disable();
ffffffffc02019d6:	e42a                	sd	a0,8(sp)
ffffffffc02019d8:	b17fe0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc02019dc:	00010797          	auipc	a5,0x10
ffffffffc02019e0:	b5c7b783          	ld	a5,-1188(a5) # ffffffffc0211538 <pmm_manager>
ffffffffc02019e4:	739c                	ld	a5,32(a5)
ffffffffc02019e6:	6522                	ld	a0,8(sp)
ffffffffc02019e8:	4585                	li	a1,1
ffffffffc02019ea:	9782                	jalr	a5
        intr_enable();
ffffffffc02019ec:	afdfe0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc02019f0:	bf7d                	j	ffffffffc02019ae <page_remove+0x52>
ffffffffc02019f2:	bd7ff0ef          	jal	ra,ffffffffc02015c8 <pa2page.part.0>

ffffffffc02019f6 <page_insert>:
//  page:  the Page which need to map
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
// note: PT is changed, so the TLB need to be invalidate
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc02019f6:	7179                	addi	sp,sp,-48
ffffffffc02019f8:	87b2                	mv	a5,a2
ffffffffc02019fa:	f022                	sd	s0,32(sp)
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc02019fc:	4605                	li	a2,1
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc02019fe:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0201a00:	85be                	mv	a1,a5
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0201a02:	ec26                	sd	s1,24(sp)
ffffffffc0201a04:	f406                	sd	ra,40(sp)
ffffffffc0201a06:	e84a                	sd	s2,16(sp)
ffffffffc0201a08:	e44e                	sd	s3,8(sp)
ffffffffc0201a0a:	e052                	sd	s4,0(sp)
ffffffffc0201a0c:	84b6                	mv	s1,a3
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0201a0e:	cffff0ef          	jal	ra,ffffffffc020170c <get_pte>
    if (ptep == NULL) {
ffffffffc0201a12:	cd71                	beqz	a0,ffffffffc0201aee <page_insert+0xf8>
    page->ref += 1;
ffffffffc0201a14:	4014                	lw	a3,0(s0)
        return -E_NO_MEM;
    }
    page_ref_inc(page);
    if (*ptep & PTE_V) {
ffffffffc0201a16:	611c                	ld	a5,0(a0)
ffffffffc0201a18:	89aa                	mv	s3,a0
ffffffffc0201a1a:	0016871b          	addiw	a4,a3,1
ffffffffc0201a1e:	c018                	sw	a4,0(s0)
ffffffffc0201a20:	0017f713          	andi	a4,a5,1
ffffffffc0201a24:	e331                	bnez	a4,ffffffffc0201a68 <page_insert+0x72>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201a26:	00010797          	auipc	a5,0x10
ffffffffc0201a2a:	b0a7b783          	ld	a5,-1270(a5) # ffffffffc0211530 <pages>
ffffffffc0201a2e:	40f407b3          	sub	a5,s0,a5
ffffffffc0201a32:	878d                	srai	a5,a5,0x3
ffffffffc0201a34:	00005417          	auipc	s0,0x5
ffffffffc0201a38:	9e443403          	ld	s0,-1564(s0) # ffffffffc0206418 <error_string+0x38>
ffffffffc0201a3c:	028787b3          	mul	a5,a5,s0
ffffffffc0201a40:	00080437          	lui	s0,0x80
ffffffffc0201a44:	97a2                	add	a5,a5,s0
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0201a46:	07aa                	slli	a5,a5,0xa
ffffffffc0201a48:	8cdd                	or	s1,s1,a5
ffffffffc0201a4a:	0014e493          	ori	s1,s1,1
            page_ref_dec(page);
        } else {
            page_remove_pte(pgdir, la, ptep);
        }
    }
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
ffffffffc0201a4e:	0099b023          	sd	s1,0(s3)
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0201a52:	12000073          	sfence.vma
    tlb_invalidate(pgdir, la);
    return 0;
ffffffffc0201a56:	4501                	li	a0,0
}
ffffffffc0201a58:	70a2                	ld	ra,40(sp)
ffffffffc0201a5a:	7402                	ld	s0,32(sp)
ffffffffc0201a5c:	64e2                	ld	s1,24(sp)
ffffffffc0201a5e:	6942                	ld	s2,16(sp)
ffffffffc0201a60:	69a2                	ld	s3,8(sp)
ffffffffc0201a62:	6a02                	ld	s4,0(sp)
ffffffffc0201a64:	6145                	addi	sp,sp,48
ffffffffc0201a66:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0201a68:	00279713          	slli	a4,a5,0x2
ffffffffc0201a6c:	8331                	srli	a4,a4,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201a6e:	00010797          	auipc	a5,0x10
ffffffffc0201a72:	aba7b783          	ld	a5,-1350(a5) # ffffffffc0211528 <npage>
ffffffffc0201a76:	06f77e63          	bgeu	a4,a5,ffffffffc0201af2 <page_insert+0xfc>
    return &pages[PPN(pa) - nbase];
ffffffffc0201a7a:	fff807b7          	lui	a5,0xfff80
ffffffffc0201a7e:	973e                	add	a4,a4,a5
ffffffffc0201a80:	00010a17          	auipc	s4,0x10
ffffffffc0201a84:	ab0a0a13          	addi	s4,s4,-1360 # ffffffffc0211530 <pages>
ffffffffc0201a88:	000a3783          	ld	a5,0(s4)
ffffffffc0201a8c:	00371913          	slli	s2,a4,0x3
ffffffffc0201a90:	993a                	add	s2,s2,a4
ffffffffc0201a92:	090e                	slli	s2,s2,0x3
ffffffffc0201a94:	993e                	add	s2,s2,a5
        if (p == page) {
ffffffffc0201a96:	03240063          	beq	s0,s2,ffffffffc0201ab6 <page_insert+0xc0>
    page->ref -= 1;
ffffffffc0201a9a:	00092783          	lw	a5,0(s2)
ffffffffc0201a9e:	fff7871b          	addiw	a4,a5,-1
ffffffffc0201aa2:	00e92023          	sw	a4,0(s2)
        if (page_ref(page) ==
ffffffffc0201aa6:	cb11                	beqz	a4,ffffffffc0201aba <page_insert+0xc4>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc0201aa8:	0009b023          	sd	zero,0(s3)
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0201aac:	12000073          	sfence.vma
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201ab0:	000a3783          	ld	a5,0(s4)
}
ffffffffc0201ab4:	bfad                	j	ffffffffc0201a2e <page_insert+0x38>
    page->ref -= 1;
ffffffffc0201ab6:	c014                	sw	a3,0(s0)
    return page->ref;
ffffffffc0201ab8:	bf9d                	j	ffffffffc0201a2e <page_insert+0x38>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201aba:	100027f3          	csrr	a5,sstatus
ffffffffc0201abe:	8b89                	andi	a5,a5,2
ffffffffc0201ac0:	eb91                	bnez	a5,ffffffffc0201ad4 <page_insert+0xde>
    { pmm_manager->free_pages(base, n); }
ffffffffc0201ac2:	00010797          	auipc	a5,0x10
ffffffffc0201ac6:	a767b783          	ld	a5,-1418(a5) # ffffffffc0211538 <pmm_manager>
ffffffffc0201aca:	739c                	ld	a5,32(a5)
ffffffffc0201acc:	4585                	li	a1,1
ffffffffc0201ace:	854a                	mv	a0,s2
ffffffffc0201ad0:	9782                	jalr	a5
    if (flag) {
ffffffffc0201ad2:	bfd9                	j	ffffffffc0201aa8 <page_insert+0xb2>
        intr_disable();
ffffffffc0201ad4:	a1bfe0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc0201ad8:	00010797          	auipc	a5,0x10
ffffffffc0201adc:	a607b783          	ld	a5,-1440(a5) # ffffffffc0211538 <pmm_manager>
ffffffffc0201ae0:	739c                	ld	a5,32(a5)
ffffffffc0201ae2:	4585                	li	a1,1
ffffffffc0201ae4:	854a                	mv	a0,s2
ffffffffc0201ae6:	9782                	jalr	a5
        intr_enable();
ffffffffc0201ae8:	a01fe0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc0201aec:	bf75                	j	ffffffffc0201aa8 <page_insert+0xb2>
        return -E_NO_MEM;
ffffffffc0201aee:	5571                	li	a0,-4
ffffffffc0201af0:	b7a5                	j	ffffffffc0201a58 <page_insert+0x62>
ffffffffc0201af2:	ad7ff0ef          	jal	ra,ffffffffc02015c8 <pa2page.part.0>

ffffffffc0201af6 <pmm_init>:
    pmm_manager = &default_pmm_manager;
ffffffffc0201af6:	00003797          	auipc	a5,0x3
ffffffffc0201afa:	71a78793          	addi	a5,a5,1818 # ffffffffc0205210 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201afe:	638c                	ld	a1,0(a5)
void pmm_init(void) {
ffffffffc0201b00:	7159                	addi	sp,sp,-112
ffffffffc0201b02:	f45e                	sd	s7,40(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201b04:	00003517          	auipc	a0,0x3
ffffffffc0201b08:	7d450513          	addi	a0,a0,2004 # ffffffffc02052d8 <default_pmm_manager+0xc8>
    pmm_manager = &default_pmm_manager;
ffffffffc0201b0c:	00010b97          	auipc	s7,0x10
ffffffffc0201b10:	a2cb8b93          	addi	s7,s7,-1492 # ffffffffc0211538 <pmm_manager>
void pmm_init(void) {
ffffffffc0201b14:	f486                	sd	ra,104(sp)
ffffffffc0201b16:	f0a2                	sd	s0,96(sp)
ffffffffc0201b18:	eca6                	sd	s1,88(sp)
ffffffffc0201b1a:	e8ca                	sd	s2,80(sp)
ffffffffc0201b1c:	e4ce                	sd	s3,72(sp)
ffffffffc0201b1e:	f85a                	sd	s6,48(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc0201b20:	00fbb023          	sd	a5,0(s7)
void pmm_init(void) {
ffffffffc0201b24:	e0d2                	sd	s4,64(sp)
ffffffffc0201b26:	fc56                	sd	s5,56(sp)
ffffffffc0201b28:	f062                	sd	s8,32(sp)
ffffffffc0201b2a:	ec66                	sd	s9,24(sp)
ffffffffc0201b2c:	e86a                	sd	s10,16(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201b2e:	d8cfe0ef          	jal	ra,ffffffffc02000ba <cprintf>
    pmm_manager->init();
ffffffffc0201b32:	000bb783          	ld	a5,0(s7)
    cprintf("membegin %llx memend %llx mem_size %llx\n",mem_begin, mem_end, mem_size);
ffffffffc0201b36:	4445                	li	s0,17
ffffffffc0201b38:	40100913          	li	s2,1025
    pmm_manager->init();
ffffffffc0201b3c:	679c                	ld	a5,8(a5)
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0201b3e:	00010997          	auipc	s3,0x10
ffffffffc0201b42:	a0298993          	addi	s3,s3,-1534 # ffffffffc0211540 <va_pa_offset>
    npage = maxpa / PGSIZE;
ffffffffc0201b46:	00010497          	auipc	s1,0x10
ffffffffc0201b4a:	9e248493          	addi	s1,s1,-1566 # ffffffffc0211528 <npage>
    pmm_manager->init();
ffffffffc0201b4e:	9782                	jalr	a5
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0201b50:	57f5                	li	a5,-3
ffffffffc0201b52:	07fa                	slli	a5,a5,0x1e
    cprintf("membegin %llx memend %llx mem_size %llx\n",mem_begin, mem_end, mem_size);
ffffffffc0201b54:	07e006b7          	lui	a3,0x7e00
ffffffffc0201b58:	01b41613          	slli	a2,s0,0x1b
ffffffffc0201b5c:	01591593          	slli	a1,s2,0x15
ffffffffc0201b60:	00003517          	auipc	a0,0x3
ffffffffc0201b64:	79050513          	addi	a0,a0,1936 # ffffffffc02052f0 <default_pmm_manager+0xe0>
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0201b68:	00f9b023          	sd	a5,0(s3)
    cprintf("membegin %llx memend %llx mem_size %llx\n",mem_begin, mem_end, mem_size);
ffffffffc0201b6c:	d4efe0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("physcial memory map:\n");
ffffffffc0201b70:	00003517          	auipc	a0,0x3
ffffffffc0201b74:	7b050513          	addi	a0,a0,1968 # ffffffffc0205320 <default_pmm_manager+0x110>
ffffffffc0201b78:	d42fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
ffffffffc0201b7c:	01b41693          	slli	a3,s0,0x1b
ffffffffc0201b80:	16fd                	addi	a3,a3,-1
ffffffffc0201b82:	07e005b7          	lui	a1,0x7e00
ffffffffc0201b86:	01591613          	slli	a2,s2,0x15
ffffffffc0201b8a:	00003517          	auipc	a0,0x3
ffffffffc0201b8e:	7ae50513          	addi	a0,a0,1966 # ffffffffc0205338 <default_pmm_manager+0x128>
ffffffffc0201b92:	d28fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201b96:	777d                	lui	a4,0xfffff
ffffffffc0201b98:	00011797          	auipc	a5,0x11
ffffffffc0201b9c:	9d378793          	addi	a5,a5,-1581 # ffffffffc021256b <end+0xfff>
ffffffffc0201ba0:	8ff9                	and	a5,a5,a4
ffffffffc0201ba2:	00010b17          	auipc	s6,0x10
ffffffffc0201ba6:	98eb0b13          	addi	s6,s6,-1650 # ffffffffc0211530 <pages>
    npage = maxpa / PGSIZE;
ffffffffc0201baa:	00088737          	lui	a4,0x88
ffffffffc0201bae:	e098                	sd	a4,0(s1)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201bb0:	00fb3023          	sd	a5,0(s6)
ffffffffc0201bb4:	4681                	li	a3,0
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201bb6:	4701                	li	a4,0
ffffffffc0201bb8:	4505                	li	a0,1
ffffffffc0201bba:	fff805b7          	lui	a1,0xfff80
ffffffffc0201bbe:	a019                	j	ffffffffc0201bc4 <pmm_init+0xce>
        SetPageReserved(pages + i);
ffffffffc0201bc0:	000b3783          	ld	a5,0(s6)
ffffffffc0201bc4:	97b6                	add	a5,a5,a3
ffffffffc0201bc6:	07a1                	addi	a5,a5,8
ffffffffc0201bc8:	40a7b02f          	amoor.d	zero,a0,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201bcc:	609c                	ld	a5,0(s1)
ffffffffc0201bce:	0705                	addi	a4,a4,1
ffffffffc0201bd0:	04868693          	addi	a3,a3,72 # 7e00048 <kern_entry-0xffffffffb83fffb8>
ffffffffc0201bd4:	00b78633          	add	a2,a5,a1
ffffffffc0201bd8:	fec764e3          	bltu	a4,a2,ffffffffc0201bc0 <pmm_init+0xca>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201bdc:	000b3503          	ld	a0,0(s6)
ffffffffc0201be0:	00379693          	slli	a3,a5,0x3
ffffffffc0201be4:	96be                	add	a3,a3,a5
ffffffffc0201be6:	fdc00737          	lui	a4,0xfdc00
ffffffffc0201bea:	972a                	add	a4,a4,a0
ffffffffc0201bec:	068e                	slli	a3,a3,0x3
ffffffffc0201bee:	96ba                	add	a3,a3,a4
ffffffffc0201bf0:	c0200737          	lui	a4,0xc0200
ffffffffc0201bf4:	64e6e463          	bltu	a3,a4,ffffffffc020223c <pmm_init+0x746>
ffffffffc0201bf8:	0009b703          	ld	a4,0(s3)
    if (freemem < mem_end) {
ffffffffc0201bfc:	4645                	li	a2,17
ffffffffc0201bfe:	066e                	slli	a2,a2,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201c00:	8e99                	sub	a3,a3,a4
    if (freemem < mem_end) {
ffffffffc0201c02:	4ec6e263          	bltu	a3,a2,ffffffffc02020e6 <pmm_init+0x5f0>

    return page;
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc0201c06:	000bb783          	ld	a5,0(s7)
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0201c0a:	00010917          	auipc	s2,0x10
ffffffffc0201c0e:	91690913          	addi	s2,s2,-1770 # ffffffffc0211520 <boot_pgdir>
    pmm_manager->check();
ffffffffc0201c12:	7b9c                	ld	a5,48(a5)
ffffffffc0201c14:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0201c16:	00003517          	auipc	a0,0x3
ffffffffc0201c1a:	77250513          	addi	a0,a0,1906 # ffffffffc0205388 <default_pmm_manager+0x178>
ffffffffc0201c1e:	c9cfe0ef          	jal	ra,ffffffffc02000ba <cprintf>
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0201c22:	00007697          	auipc	a3,0x7
ffffffffc0201c26:	3de68693          	addi	a3,a3,990 # ffffffffc0209000 <boot_page_table_sv39>
ffffffffc0201c2a:	00d93023          	sd	a3,0(s2)
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc0201c2e:	c02007b7          	lui	a5,0xc0200
ffffffffc0201c32:	62f6e163          	bltu	a3,a5,ffffffffc0202254 <pmm_init+0x75e>
ffffffffc0201c36:	0009b783          	ld	a5,0(s3)
ffffffffc0201c3a:	8e9d                	sub	a3,a3,a5
ffffffffc0201c3c:	00010797          	auipc	a5,0x10
ffffffffc0201c40:	8cd7be23          	sd	a3,-1828(a5) # ffffffffc0211518 <boot_cr3>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201c44:	100027f3          	csrr	a5,sstatus
ffffffffc0201c48:	8b89                	andi	a5,a5,2
ffffffffc0201c4a:	4c079763          	bnez	a5,ffffffffc0202118 <pmm_init+0x622>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc0201c4e:	000bb783          	ld	a5,0(s7)
ffffffffc0201c52:	779c                	ld	a5,40(a5)
ffffffffc0201c54:	9782                	jalr	a5
ffffffffc0201c56:	842a                	mv	s0,a0
    size_t nr_free_store;

    nr_free_store=nr_free_pages();

    // 断言：物理内存页面数量不超过内核顶部地址除以页面大小
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0201c58:	6098                	ld	a4,0(s1)
ffffffffc0201c5a:	c80007b7          	lui	a5,0xc8000
ffffffffc0201c5e:	83b1                	srli	a5,a5,0xc
ffffffffc0201c60:	62e7e663          	bltu	a5,a4,ffffffffc020228c <pmm_init+0x796>
    // 断言：页目录指针不为空，且页目录的偏移量为 0
    assert(boot_pgdir!= NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc0201c64:	00093503          	ld	a0,0(s2)
ffffffffc0201c68:	60050263          	beqz	a0,ffffffffc020226c <pmm_init+0x776>
ffffffffc0201c6c:	03451793          	slli	a5,a0,0x34
ffffffffc0201c70:	5e079e63          	bnez	a5,ffffffffc020226c <pmm_init+0x776>
    // 断言：获取页目录中地址为 0 的页失败（应该为空）
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc0201c74:	4601                	li	a2,0
ffffffffc0201c76:	4581                	li	a1,0
ffffffffc0201c78:	c8bff0ef          	jal	ra,ffffffffc0201902 <get_page>
ffffffffc0201c7c:	66051a63          	bnez	a0,ffffffffc02022f0 <pmm_init+0x7fa>

    struct Page *p1, *p2;
    // 分配一个页
    p1 = alloc_page();
ffffffffc0201c80:	4505                	li	a0,1
ffffffffc0201c82:	97fff0ef          	jal	ra,ffffffffc0201600 <alloc_pages>
ffffffffc0201c86:	8a2a                	mv	s4,a0
    // 将页 p1 插入到页目录 boot_pgdir 中，地址为 0x0，权限为 0
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc0201c88:	00093503          	ld	a0,0(s2)
ffffffffc0201c8c:	4681                	li	a3,0
ffffffffc0201c8e:	4601                	li	a2,0
ffffffffc0201c90:	85d2                	mv	a1,s4
ffffffffc0201c92:	d65ff0ef          	jal	ra,ffffffffc02019f6 <page_insert>
ffffffffc0201c96:	62051d63          	bnez	a0,ffffffffc02022d0 <pmm_init+0x7da>
    pte_t *ptep;
    // 获取页目录 boot_pgdir 中地址为 0x0 的页表项
    assert((ptep = get_pte(boot_pgdir, 0x0, 0))!= NULL);
ffffffffc0201c9a:	00093503          	ld	a0,0(s2)
ffffffffc0201c9e:	4601                	li	a2,0
ffffffffc0201ca0:	4581                	li	a1,0
ffffffffc0201ca2:	a6bff0ef          	jal	ra,ffffffffc020170c <get_pte>
ffffffffc0201ca6:	60050563          	beqz	a0,ffffffffc02022b0 <pmm_init+0x7ba>
    // 断言：页表项指向的页是 p1
    assert(pte2page(*ptep) == p1);
ffffffffc0201caa:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0201cac:	0017f713          	andi	a4,a5,1
ffffffffc0201cb0:	5e070e63          	beqz	a4,ffffffffc02022ac <pmm_init+0x7b6>
    if (PPN(pa) >= npage) {
ffffffffc0201cb4:	6090                	ld	a2,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201cb6:	078a                	slli	a5,a5,0x2
ffffffffc0201cb8:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201cba:	56c7ff63          	bgeu	a5,a2,ffffffffc0202238 <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc0201cbe:	fff80737          	lui	a4,0xfff80
ffffffffc0201cc2:	97ba                	add	a5,a5,a4
ffffffffc0201cc4:	000b3683          	ld	a3,0(s6)
ffffffffc0201cc8:	00379713          	slli	a4,a5,0x3
ffffffffc0201ccc:	97ba                	add	a5,a5,a4
ffffffffc0201cce:	078e                	slli	a5,a5,0x3
ffffffffc0201cd0:	97b6                	add	a5,a5,a3
ffffffffc0201cd2:	14fa18e3          	bne	s4,a5,ffffffffc0202622 <pmm_init+0xb2c>
    // 断言：页 p1 的引用计数为 1
    assert(page_ref(p1) == 1);
ffffffffc0201cd6:	000a2703          	lw	a4,0(s4)
ffffffffc0201cda:	4785                	li	a5,1
ffffffffc0201cdc:	16f71fe3          	bne	a4,a5,ffffffffc020265a <pmm_init+0xb64>

    // 获取页目录 boot_pgdir 的第一个页表的物理地址
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc0201ce0:	00093503          	ld	a0,0(s2)
ffffffffc0201ce4:	77fd                	lui	a5,0xfffff
ffffffffc0201ce6:	6114                	ld	a3,0(a0)
ffffffffc0201ce8:	068a                	slli	a3,a3,0x2
ffffffffc0201cea:	8efd                	and	a3,a3,a5
ffffffffc0201cec:	00c6d713          	srli	a4,a3,0xc
ffffffffc0201cf0:	14c779e3          	bgeu	a4,a2,ffffffffc0202642 <pmm_init+0xb4c>
ffffffffc0201cf4:	0009bc03          	ld	s8,0(s3)
    // 获取页目录 boot_pgdir 的第一个页表的第二项的物理地址
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0201cf8:	96e2                	add	a3,a3,s8
ffffffffc0201cfa:	0006ba83          	ld	s5,0(a3)
ffffffffc0201cfe:	0a8a                	slli	s5,s5,0x2
ffffffffc0201d00:	00fafab3          	and	s5,s5,a5
ffffffffc0201d04:	00cad793          	srli	a5,s5,0xc
ffffffffc0201d08:	66c7f463          	bgeu	a5,a2,ffffffffc0202370 <pmm_init+0x87a>
    // 断言：获取到的页表项地址与通过 get_pte 函数获取的地址相同
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0201d0c:	4601                	li	a2,0
ffffffffc0201d0e:	6585                	lui	a1,0x1
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0201d10:	9ae2                	add	s5,s5,s8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0201d12:	9fbff0ef          	jal	ra,ffffffffc020170c <get_pte>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0201d16:	0aa1                	addi	s5,s5,8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0201d18:	63551c63          	bne	a0,s5,ffffffffc0202350 <pmm_init+0x85a>

    // 分配一个页
    p2 = alloc_page();
ffffffffc0201d1c:	4505                	li	a0,1
ffffffffc0201d1e:	8e3ff0ef          	jal	ra,ffffffffc0201600 <alloc_pages>
ffffffffc0201d22:	8aaa                	mv	s5,a0
    // 将页 p2 插入到页目录 boot_pgdir 中，地址为 PGSIZE，权限为 PTE_U | PTE_W
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0201d24:	00093503          	ld	a0,0(s2)
ffffffffc0201d28:	46d1                	li	a3,20
ffffffffc0201d2a:	6605                	lui	a2,0x1
ffffffffc0201d2c:	85d6                	mv	a1,s5
ffffffffc0201d2e:	cc9ff0ef          	jal	ra,ffffffffc02019f6 <page_insert>
ffffffffc0201d32:	5c051f63          	bnez	a0,ffffffffc0202310 <pmm_init+0x81a>
    // 获取页目录 boot_pgdir 中地址为 PGSIZE 的页表项
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0))!= NULL);
ffffffffc0201d36:	00093503          	ld	a0,0(s2)
ffffffffc0201d3a:	4601                	li	a2,0
ffffffffc0201d3c:	6585                	lui	a1,0x1
ffffffffc0201d3e:	9cfff0ef          	jal	ra,ffffffffc020170c <get_pte>
ffffffffc0201d42:	12050ce3          	beqz	a0,ffffffffc020267a <pmm_init+0xb84>
    // 断言：页表项设置了 PTE_U 和 PTE_W 标志
    assert(*ptep & PTE_U);
ffffffffc0201d46:	611c                	ld	a5,0(a0)
ffffffffc0201d48:	0107f713          	andi	a4,a5,16
ffffffffc0201d4c:	72070f63          	beqz	a4,ffffffffc020248a <pmm_init+0x994>
    assert(*ptep & PTE_W);
ffffffffc0201d50:	8b91                	andi	a5,a5,4
ffffffffc0201d52:	6e078c63          	beqz	a5,ffffffffc020244a <pmm_init+0x954>
    // 断言：页目录的第一个页表项设置了 PTE_U 标志
    assert(boot_pgdir[0] & PTE_U);
ffffffffc0201d56:	00093503          	ld	a0,0(s2)
ffffffffc0201d5a:	611c                	ld	a5,0(a0)
ffffffffc0201d5c:	8bc1                	andi	a5,a5,16
ffffffffc0201d5e:	6c078663          	beqz	a5,ffffffffc020242a <pmm_init+0x934>
    // 断言：页 p2 的引用计数为 1
    assert(page_ref(p2) == 1);
ffffffffc0201d62:	000aa703          	lw	a4,0(s5)
ffffffffc0201d66:	4785                	li	a5,1
ffffffffc0201d68:	5cf71463          	bne	a4,a5,ffffffffc0202330 <pmm_init+0x83a>

    // 将页 p1 再次插入到页目录 boot_pgdir 中，地址为 PGSIZE，权限为 0
    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc0201d6c:	4681                	li	a3,0
ffffffffc0201d6e:	6605                	lui	a2,0x1
ffffffffc0201d70:	85d2                	mv	a1,s4
ffffffffc0201d72:	c85ff0ef          	jal	ra,ffffffffc02019f6 <page_insert>
ffffffffc0201d76:	66051a63          	bnez	a0,ffffffffc02023ea <pmm_init+0x8f4>
    // 断言：页 p1 的引用计数为 2
    assert(page_ref(p1) == 2);
ffffffffc0201d7a:	000a2703          	lw	a4,0(s4)
ffffffffc0201d7e:	4789                	li	a5,2
ffffffffc0201d80:	64f71563          	bne	a4,a5,ffffffffc02023ca <pmm_init+0x8d4>
    // 断言：页 p2 的引用计数为 0
    assert(page_ref(p2) == 0);
ffffffffc0201d84:	000aa783          	lw	a5,0(s5)
ffffffffc0201d88:	62079163          	bnez	a5,ffffffffc02023aa <pmm_init+0x8b4>
    // 获取页目录 boot_pgdir 中地址为 PGSIZE 的页表项
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0))!= NULL);
ffffffffc0201d8c:	00093503          	ld	a0,0(s2)
ffffffffc0201d90:	4601                	li	a2,0
ffffffffc0201d92:	6585                	lui	a1,0x1
ffffffffc0201d94:	979ff0ef          	jal	ra,ffffffffc020170c <get_pte>
ffffffffc0201d98:	5e050963          	beqz	a0,ffffffffc020238a <pmm_init+0x894>
    // 断言：页表项指向的页是 p1
    assert(pte2page(*ptep) == p1);
ffffffffc0201d9c:	6118                	ld	a4,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0201d9e:	00177793          	andi	a5,a4,1
ffffffffc0201da2:	50078563          	beqz	a5,ffffffffc02022ac <pmm_init+0x7b6>
    if (PPN(pa) >= npage) {
ffffffffc0201da6:	6094                	ld	a3,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201da8:	00271793          	slli	a5,a4,0x2
ffffffffc0201dac:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201dae:	48d7f563          	bgeu	a5,a3,ffffffffc0202238 <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc0201db2:	fff806b7          	lui	a3,0xfff80
ffffffffc0201db6:	97b6                	add	a5,a5,a3
ffffffffc0201db8:	000b3603          	ld	a2,0(s6)
ffffffffc0201dbc:	00379693          	slli	a3,a5,0x3
ffffffffc0201dc0:	97b6                	add	a5,a5,a3
ffffffffc0201dc2:	078e                	slli	a5,a5,0x3
ffffffffc0201dc4:	97b2                	add	a5,a5,a2
ffffffffc0201dc6:	72fa1263          	bne	s4,a5,ffffffffc02024ea <pmm_init+0x9f4>
    // 断言：页表项没有设置 PTE_U 标志
    assert((*ptep & PTE_U) == 0);
ffffffffc0201dca:	8b41                	andi	a4,a4,16
ffffffffc0201dcc:	6e071f63          	bnez	a4,ffffffffc02024ca <pmm_init+0x9d4>

    // 从页目录 boot_pgdir 中移除地址为 0x0 的页
    page_remove(boot_pgdir, 0x0);
ffffffffc0201dd0:	00093503          	ld	a0,0(s2)
ffffffffc0201dd4:	4581                	li	a1,0
ffffffffc0201dd6:	b87ff0ef          	jal	ra,ffffffffc020195c <page_remove>
    // 断言：页 p1 的引用计数为 1
    assert(page_ref(p1) == 1);
ffffffffc0201dda:	000a2703          	lw	a4,0(s4)
ffffffffc0201dde:	4785                	li	a5,1
ffffffffc0201de0:	6cf71563          	bne	a4,a5,ffffffffc02024aa <pmm_init+0x9b4>
    // 断言：页 p2 的引用计数为 0
    assert(page_ref(p2) == 0);
ffffffffc0201de4:	000aa783          	lw	a5,0(s5)
ffffffffc0201de8:	78079d63          	bnez	a5,ffffffffc0202582 <pmm_init+0xa8c>

    // 从页目录 boot_pgdir 中移除地址为 PGSIZE 的页
    page_remove(boot_pgdir, PGSIZE);
ffffffffc0201dec:	00093503          	ld	a0,0(s2)
ffffffffc0201df0:	6585                	lui	a1,0x1
ffffffffc0201df2:	b6bff0ef          	jal	ra,ffffffffc020195c <page_remove>
    // 断言：页 p1 的引用计数为 0
    assert(page_ref(p1) == 0);
ffffffffc0201df6:	000a2783          	lw	a5,0(s4)
ffffffffc0201dfa:	76079463          	bnez	a5,ffffffffc0202562 <pmm_init+0xa6c>
    // 断言：页 p2 的引用计数为 0
    assert(page_ref(p2) == 0);
ffffffffc0201dfe:	000aa783          	lw	a5,0(s5)
ffffffffc0201e02:	74079063          	bnez	a5,ffffffffc0202542 <pmm_init+0xa4c>

    // 断言：页目录的第一个页表的引用计数为 1
    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc0201e06:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0201e0a:	6090                	ld	a2,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201e0c:	000a3783          	ld	a5,0(s4)
ffffffffc0201e10:	078a                	slli	a5,a5,0x2
ffffffffc0201e12:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201e14:	42c7f263          	bgeu	a5,a2,ffffffffc0202238 <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc0201e18:	fff80737          	lui	a4,0xfff80
ffffffffc0201e1c:	973e                	add	a4,a4,a5
ffffffffc0201e1e:	00371793          	slli	a5,a4,0x3
ffffffffc0201e22:	000b3503          	ld	a0,0(s6)
ffffffffc0201e26:	97ba                	add	a5,a5,a4
ffffffffc0201e28:	078e                	slli	a5,a5,0x3
static inline int page_ref(struct Page *page) { return page->ref; }
ffffffffc0201e2a:	00f50733          	add	a4,a0,a5
ffffffffc0201e2e:	4314                	lw	a3,0(a4)
ffffffffc0201e30:	4705                	li	a4,1
ffffffffc0201e32:	6ee69863          	bne	a3,a4,ffffffffc0202522 <pmm_init+0xa2c>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201e36:	4037d693          	srai	a3,a5,0x3
ffffffffc0201e3a:	00004c97          	auipc	s9,0x4
ffffffffc0201e3e:	5decbc83          	ld	s9,1502(s9) # ffffffffc0206418 <error_string+0x38>
ffffffffc0201e42:	039686b3          	mul	a3,a3,s9
ffffffffc0201e46:	000805b7          	lui	a1,0x80
ffffffffc0201e4a:	96ae                	add	a3,a3,a1
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201e4c:	00c69713          	slli	a4,a3,0xc
ffffffffc0201e50:	8331                	srli	a4,a4,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0201e52:	06b2                	slli	a3,a3,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201e54:	6ac77b63          	bgeu	a4,a2,ffffffffc020250a <pmm_init+0xa14>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
    // 释放页目录的第一个页表的物理页
    free_page(pde2page(pd0[0]));
ffffffffc0201e58:	0009b703          	ld	a4,0(s3)
ffffffffc0201e5c:	96ba                	add	a3,a3,a4
    return pa2page(PDE_ADDR(pde));
ffffffffc0201e5e:	629c                	ld	a5,0(a3)
ffffffffc0201e60:	078a                	slli	a5,a5,0x2
ffffffffc0201e62:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201e64:	3cc7fa63          	bgeu	a5,a2,ffffffffc0202238 <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc0201e68:	8f8d                	sub	a5,a5,a1
ffffffffc0201e6a:	00379713          	slli	a4,a5,0x3
ffffffffc0201e6e:	97ba                	add	a5,a5,a4
ffffffffc0201e70:	078e                	slli	a5,a5,0x3
ffffffffc0201e72:	953e                	add	a0,a0,a5
ffffffffc0201e74:	100027f3          	csrr	a5,sstatus
ffffffffc0201e78:	8b89                	andi	a5,a5,2
ffffffffc0201e7a:	2e079963          	bnez	a5,ffffffffc020216c <pmm_init+0x676>
    { pmm_manager->free_pages(base, n); }
ffffffffc0201e7e:	000bb783          	ld	a5,0(s7)
ffffffffc0201e82:	4585                	li	a1,1
ffffffffc0201e84:	739c                	ld	a5,32(a5)
ffffffffc0201e86:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0201e88:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage) {
ffffffffc0201e8c:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201e8e:	078a                	slli	a5,a5,0x2
ffffffffc0201e90:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201e92:	3ae7f363          	bgeu	a5,a4,ffffffffc0202238 <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc0201e96:	fff80737          	lui	a4,0xfff80
ffffffffc0201e9a:	97ba                	add	a5,a5,a4
ffffffffc0201e9c:	000b3503          	ld	a0,0(s6)
ffffffffc0201ea0:	00379713          	slli	a4,a5,0x3
ffffffffc0201ea4:	97ba                	add	a5,a5,a4
ffffffffc0201ea6:	078e                	slli	a5,a5,0x3
ffffffffc0201ea8:	953e                	add	a0,a0,a5
ffffffffc0201eaa:	100027f3          	csrr	a5,sstatus
ffffffffc0201eae:	8b89                	andi	a5,a5,2
ffffffffc0201eb0:	2a079263          	bnez	a5,ffffffffc0202154 <pmm_init+0x65e>
ffffffffc0201eb4:	000bb783          	ld	a5,0(s7)
ffffffffc0201eb8:	4585                	li	a1,1
ffffffffc0201eba:	739c                	ld	a5,32(a5)
ffffffffc0201ebc:	9782                	jalr	a5
    // 释放页目录的第一个页表的物理页
    free_page(pde2page(pd1[0]));
    // 将页目录的第一个页表项清零
    boot_pgdir[0] = 0;
ffffffffc0201ebe:	00093783          	ld	a5,0(s2)
ffffffffc0201ec2:	0007b023          	sd	zero,0(a5) # fffffffffffff000 <end+0x3fdeda94>
ffffffffc0201ec6:	100027f3          	csrr	a5,sstatus
ffffffffc0201eca:	8b89                	andi	a5,a5,2
ffffffffc0201ecc:	26079a63          	bnez	a5,ffffffffc0202140 <pmm_init+0x64a>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc0201ed0:	000bb783          	ld	a5,0(s7)
ffffffffc0201ed4:	779c                	ld	a5,40(a5)
ffffffffc0201ed6:	9782                	jalr	a5
ffffffffc0201ed8:	8a2a                	mv	s4,a0

    // 断言：空闲页面数量与检查前相同
    assert(nr_free_store==nr_free_pages());
ffffffffc0201eda:	73441463          	bne	s0,s4,ffffffffc0202602 <pmm_init+0xb0c>

    // 打印检查通过信息
    cprintf("check_pgdir() succeeded!\n");
ffffffffc0201ede:	00003517          	auipc	a0,0x3
ffffffffc0201ee2:	79250513          	addi	a0,a0,1938 # ffffffffc0205670 <default_pmm_manager+0x460>
ffffffffc0201ee6:	9d4fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0201eea:	100027f3          	csrr	a5,sstatus
ffffffffc0201eee:	8b89                	andi	a5,a5,2
ffffffffc0201ef0:	22079e63          	bnez	a5,ffffffffc020212c <pmm_init+0x636>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc0201ef4:	000bb783          	ld	a5,0(s7)
ffffffffc0201ef8:	779c                	ld	a5,40(a5)
ffffffffc0201efa:	9782                	jalr	a5
ffffffffc0201efc:	8c2a                	mv	s8,a0
    pte_t *ptep;
    int i;

    nr_free_store=nr_free_pages();

    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0201efe:	6098                	ld	a4,0(s1)
ffffffffc0201f00:	c0200437          	lui	s0,0xc0200
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0201f04:	7afd                	lui	s5,0xfffff
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0201f06:	00c71793          	slli	a5,a4,0xc
ffffffffc0201f0a:	6a05                	lui	s4,0x1
ffffffffc0201f0c:	02f47c63          	bgeu	s0,a5,ffffffffc0201f44 <pmm_init+0x44e>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0201f10:	00c45793          	srli	a5,s0,0xc
ffffffffc0201f14:	00093503          	ld	a0,0(s2)
ffffffffc0201f18:	30e7f363          	bgeu	a5,a4,ffffffffc020221e <pmm_init+0x728>
ffffffffc0201f1c:	0009b583          	ld	a1,0(s3)
ffffffffc0201f20:	4601                	li	a2,0
ffffffffc0201f22:	95a2                	add	a1,a1,s0
ffffffffc0201f24:	fe8ff0ef          	jal	ra,ffffffffc020170c <get_pte>
ffffffffc0201f28:	2c050b63          	beqz	a0,ffffffffc02021fe <pmm_init+0x708>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0201f2c:	611c                	ld	a5,0(a0)
ffffffffc0201f2e:	078a                	slli	a5,a5,0x2
ffffffffc0201f30:	0157f7b3          	and	a5,a5,s5
ffffffffc0201f34:	2a879563          	bne	a5,s0,ffffffffc02021de <pmm_init+0x6e8>
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0201f38:	6098                	ld	a4,0(s1)
ffffffffc0201f3a:	9452                	add	s0,s0,s4
ffffffffc0201f3c:	00c71793          	slli	a5,a4,0xc
ffffffffc0201f40:	fcf468e3          	bltu	s0,a5,ffffffffc0201f10 <pmm_init+0x41a>
    }


    assert(boot_pgdir[0] == 0);
ffffffffc0201f44:	00093783          	ld	a5,0(s2)
ffffffffc0201f48:	639c                	ld	a5,0(a5)
ffffffffc0201f4a:	68079c63          	bnez	a5,ffffffffc02025e2 <pmm_init+0xaec>

    struct Page *p;
    p = alloc_page();
ffffffffc0201f4e:	4505                	li	a0,1
ffffffffc0201f50:	eb0ff0ef          	jal	ra,ffffffffc0201600 <alloc_pages>
ffffffffc0201f54:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0201f56:	00093503          	ld	a0,0(s2)
ffffffffc0201f5a:	4699                	li	a3,6
ffffffffc0201f5c:	10000613          	li	a2,256
ffffffffc0201f60:	85d6                	mv	a1,s5
ffffffffc0201f62:	a95ff0ef          	jal	ra,ffffffffc02019f6 <page_insert>
ffffffffc0201f66:	64051e63          	bnez	a0,ffffffffc02025c2 <pmm_init+0xacc>
    assert(page_ref(p) == 1);
ffffffffc0201f6a:	000aa703          	lw	a4,0(s5) # fffffffffffff000 <end+0x3fdeda94>
ffffffffc0201f6e:	4785                	li	a5,1
ffffffffc0201f70:	62f71963          	bne	a4,a5,ffffffffc02025a2 <pmm_init+0xaac>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0201f74:	00093503          	ld	a0,0(s2)
ffffffffc0201f78:	6405                	lui	s0,0x1
ffffffffc0201f7a:	4699                	li	a3,6
ffffffffc0201f7c:	10040613          	addi	a2,s0,256 # 1100 <kern_entry-0xffffffffc01fef00>
ffffffffc0201f80:	85d6                	mv	a1,s5
ffffffffc0201f82:	a75ff0ef          	jal	ra,ffffffffc02019f6 <page_insert>
ffffffffc0201f86:	48051263          	bnez	a0,ffffffffc020240a <pmm_init+0x914>
    assert(page_ref(p) == 2);
ffffffffc0201f8a:	000aa703          	lw	a4,0(s5)
ffffffffc0201f8e:	4789                	li	a5,2
ffffffffc0201f90:	74f71563          	bne	a4,a5,ffffffffc02026da <pmm_init+0xbe4>

    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
ffffffffc0201f94:	00004597          	auipc	a1,0x4
ffffffffc0201f98:	81458593          	addi	a1,a1,-2028 # ffffffffc02057a8 <default_pmm_manager+0x598>
ffffffffc0201f9c:	10000513          	li	a0,256
ffffffffc0201fa0:	496020ef          	jal	ra,ffffffffc0204436 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0201fa4:	10040593          	addi	a1,s0,256
ffffffffc0201fa8:	10000513          	li	a0,256
ffffffffc0201fac:	49c020ef          	jal	ra,ffffffffc0204448 <strcmp>
ffffffffc0201fb0:	70051563          	bnez	a0,ffffffffc02026ba <pmm_init+0xbc4>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201fb4:	000b3683          	ld	a3,0(s6)
ffffffffc0201fb8:	00080d37          	lui	s10,0x80
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201fbc:	547d                	li	s0,-1
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201fbe:	40da86b3          	sub	a3,s5,a3
ffffffffc0201fc2:	868d                	srai	a3,a3,0x3
ffffffffc0201fc4:	039686b3          	mul	a3,a3,s9
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201fc8:	609c                	ld	a5,0(s1)
ffffffffc0201fca:	8031                	srli	s0,s0,0xc
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201fcc:	96ea                	add	a3,a3,s10
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201fce:	0086f733          	and	a4,a3,s0
    return page2ppn(page) << PGSHIFT;
ffffffffc0201fd2:	06b2                	slli	a3,a3,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201fd4:	52f77b63          	bgeu	a4,a5,ffffffffc020250a <pmm_init+0xa14>

    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0201fd8:	0009b783          	ld	a5,0(s3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc0201fdc:	10000513          	li	a0,256
    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0201fe0:	96be                	add	a3,a3,a5
ffffffffc0201fe2:	10068023          	sb	zero,256(a3) # fffffffffff80100 <end+0x3fd6eb94>
    assert(strlen((const char *)0x100) == 0);
ffffffffc0201fe6:	41a020ef          	jal	ra,ffffffffc0204400 <strlen>
ffffffffc0201fea:	6a051863          	bnez	a0,ffffffffc020269a <pmm_init+0xba4>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc0201fee:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0201ff2:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201ff4:	000a3783          	ld	a5,0(s4) # 1000 <kern_entry-0xffffffffc01ff000>
ffffffffc0201ff8:	078a                	slli	a5,a5,0x2
ffffffffc0201ffa:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201ffc:	22e7fe63          	bgeu	a5,a4,ffffffffc0202238 <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc0202000:	41a787b3          	sub	a5,a5,s10
ffffffffc0202004:	00379693          	slli	a3,a5,0x3
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202008:	96be                	add	a3,a3,a5
ffffffffc020200a:	03968cb3          	mul	s9,a3,s9
ffffffffc020200e:	01ac86b3          	add	a3,s9,s10
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0202012:	8c75                	and	s0,s0,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0202014:	06b2                	slli	a3,a3,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0202016:	4ee47a63          	bgeu	s0,a4,ffffffffc020250a <pmm_init+0xa14>
ffffffffc020201a:	0009b403          	ld	s0,0(s3)
ffffffffc020201e:	9436                	add	s0,s0,a3
ffffffffc0202020:	100027f3          	csrr	a5,sstatus
ffffffffc0202024:	8b89                	andi	a5,a5,2
ffffffffc0202026:	1a079163          	bnez	a5,ffffffffc02021c8 <pmm_init+0x6d2>
    { pmm_manager->free_pages(base, n); }
ffffffffc020202a:	000bb783          	ld	a5,0(s7)
ffffffffc020202e:	4585                	li	a1,1
ffffffffc0202030:	8556                	mv	a0,s5
ffffffffc0202032:	739c                	ld	a5,32(a5)
ffffffffc0202034:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0202036:	601c                	ld	a5,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc0202038:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc020203a:	078a                	slli	a5,a5,0x2
ffffffffc020203c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020203e:	1ee7fd63          	bgeu	a5,a4,ffffffffc0202238 <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc0202042:	fff80737          	lui	a4,0xfff80
ffffffffc0202046:	97ba                	add	a5,a5,a4
ffffffffc0202048:	000b3503          	ld	a0,0(s6)
ffffffffc020204c:	00379713          	slli	a4,a5,0x3
ffffffffc0202050:	97ba                	add	a5,a5,a4
ffffffffc0202052:	078e                	slli	a5,a5,0x3
ffffffffc0202054:	953e                	add	a0,a0,a5
ffffffffc0202056:	100027f3          	csrr	a5,sstatus
ffffffffc020205a:	8b89                	andi	a5,a5,2
ffffffffc020205c:	14079a63          	bnez	a5,ffffffffc02021b0 <pmm_init+0x6ba>
ffffffffc0202060:	000bb783          	ld	a5,0(s7)
ffffffffc0202064:	4585                	li	a1,1
ffffffffc0202066:	739c                	ld	a5,32(a5)
ffffffffc0202068:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc020206a:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage) {
ffffffffc020206e:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202070:	078a                	slli	a5,a5,0x2
ffffffffc0202072:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202074:	1ce7f263          	bgeu	a5,a4,ffffffffc0202238 <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc0202078:	fff80737          	lui	a4,0xfff80
ffffffffc020207c:	97ba                	add	a5,a5,a4
ffffffffc020207e:	000b3503          	ld	a0,0(s6)
ffffffffc0202082:	00379713          	slli	a4,a5,0x3
ffffffffc0202086:	97ba                	add	a5,a5,a4
ffffffffc0202088:	078e                	slli	a5,a5,0x3
ffffffffc020208a:	953e                	add	a0,a0,a5
ffffffffc020208c:	100027f3          	csrr	a5,sstatus
ffffffffc0202090:	8b89                	andi	a5,a5,2
ffffffffc0202092:	10079363          	bnez	a5,ffffffffc0202198 <pmm_init+0x6a2>
ffffffffc0202096:	000bb783          	ld	a5,0(s7)
ffffffffc020209a:	4585                	li	a1,1
ffffffffc020209c:	739c                	ld	a5,32(a5)
ffffffffc020209e:	9782                	jalr	a5
    free_page(p);
    free_page(pde2page(pd0[0]));
    free_page(pde2page(pd1[0]));
    boot_pgdir[0] = 0;
ffffffffc02020a0:	00093783          	ld	a5,0(s2)
ffffffffc02020a4:	0007b023          	sd	zero,0(a5)
ffffffffc02020a8:	100027f3          	csrr	a5,sstatus
ffffffffc02020ac:	8b89                	andi	a5,a5,2
ffffffffc02020ae:	0c079b63          	bnez	a5,ffffffffc0202184 <pmm_init+0x68e>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc02020b2:	000bb783          	ld	a5,0(s7)
ffffffffc02020b6:	779c                	ld	a5,40(a5)
ffffffffc02020b8:	9782                	jalr	a5
ffffffffc02020ba:	842a                	mv	s0,a0

    assert(nr_free_store==nr_free_pages());
ffffffffc02020bc:	3a8c1763          	bne	s8,s0,ffffffffc020246a <pmm_init+0x974>
}
ffffffffc02020c0:	7406                	ld	s0,96(sp)
ffffffffc02020c2:	70a6                	ld	ra,104(sp)
ffffffffc02020c4:	64e6                	ld	s1,88(sp)
ffffffffc02020c6:	6946                	ld	s2,80(sp)
ffffffffc02020c8:	69a6                	ld	s3,72(sp)
ffffffffc02020ca:	6a06                	ld	s4,64(sp)
ffffffffc02020cc:	7ae2                	ld	s5,56(sp)
ffffffffc02020ce:	7b42                	ld	s6,48(sp)
ffffffffc02020d0:	7ba2                	ld	s7,40(sp)
ffffffffc02020d2:	7c02                	ld	s8,32(sp)
ffffffffc02020d4:	6ce2                	ld	s9,24(sp)
ffffffffc02020d6:	6d42                	ld	s10,16(sp)

    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc02020d8:	00003517          	auipc	a0,0x3
ffffffffc02020dc:	74850513          	addi	a0,a0,1864 # ffffffffc0205820 <default_pmm_manager+0x610>
}
ffffffffc02020e0:	6165                	addi	sp,sp,112
    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc02020e2:	fd9fd06f          	j	ffffffffc02000ba <cprintf>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc02020e6:	6705                	lui	a4,0x1
ffffffffc02020e8:	177d                	addi	a4,a4,-1
ffffffffc02020ea:	96ba                	add	a3,a3,a4
ffffffffc02020ec:	777d                	lui	a4,0xfffff
ffffffffc02020ee:	8f75                	and	a4,a4,a3
    if (PPN(pa) >= npage) {
ffffffffc02020f0:	00c75693          	srli	a3,a4,0xc
ffffffffc02020f4:	14f6f263          	bgeu	a3,a5,ffffffffc0202238 <pmm_init+0x742>
    pmm_manager->init_memmap(base, n);
ffffffffc02020f8:	000bb803          	ld	a6,0(s7)
    return &pages[PPN(pa) - nbase];
ffffffffc02020fc:	95b6                	add	a1,a1,a3
ffffffffc02020fe:	00359793          	slli	a5,a1,0x3
ffffffffc0202102:	97ae                	add	a5,a5,a1
ffffffffc0202104:	01083683          	ld	a3,16(a6)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0202108:	40e60733          	sub	a4,a2,a4
ffffffffc020210c:	078e                	slli	a5,a5,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc020210e:	00c75593          	srli	a1,a4,0xc
ffffffffc0202112:	953e                	add	a0,a0,a5
ffffffffc0202114:	9682                	jalr	a3
}
ffffffffc0202116:	bcc5                	j	ffffffffc0201c06 <pmm_init+0x110>
        intr_disable();
ffffffffc0202118:	bd6fe0ef          	jal	ra,ffffffffc02004ee <intr_disable>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc020211c:	000bb783          	ld	a5,0(s7)
ffffffffc0202120:	779c                	ld	a5,40(a5)
ffffffffc0202122:	9782                	jalr	a5
ffffffffc0202124:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0202126:	bc2fe0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc020212a:	b63d                	j	ffffffffc0201c58 <pmm_init+0x162>
        intr_disable();
ffffffffc020212c:	bc2fe0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc0202130:	000bb783          	ld	a5,0(s7)
ffffffffc0202134:	779c                	ld	a5,40(a5)
ffffffffc0202136:	9782                	jalr	a5
ffffffffc0202138:	8c2a                	mv	s8,a0
        intr_enable();
ffffffffc020213a:	baefe0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc020213e:	b3c1                	j	ffffffffc0201efe <pmm_init+0x408>
        intr_disable();
ffffffffc0202140:	baefe0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc0202144:	000bb783          	ld	a5,0(s7)
ffffffffc0202148:	779c                	ld	a5,40(a5)
ffffffffc020214a:	9782                	jalr	a5
ffffffffc020214c:	8a2a                	mv	s4,a0
        intr_enable();
ffffffffc020214e:	b9afe0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc0202152:	b361                	j	ffffffffc0201eda <pmm_init+0x3e4>
ffffffffc0202154:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0202156:	b98fe0ef          	jal	ra,ffffffffc02004ee <intr_disable>
    { pmm_manager->free_pages(base, n); }
ffffffffc020215a:	000bb783          	ld	a5,0(s7)
ffffffffc020215e:	6522                	ld	a0,8(sp)
ffffffffc0202160:	4585                	li	a1,1
ffffffffc0202162:	739c                	ld	a5,32(a5)
ffffffffc0202164:	9782                	jalr	a5
        intr_enable();
ffffffffc0202166:	b82fe0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc020216a:	bb91                	j	ffffffffc0201ebe <pmm_init+0x3c8>
ffffffffc020216c:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc020216e:	b80fe0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc0202172:	000bb783          	ld	a5,0(s7)
ffffffffc0202176:	6522                	ld	a0,8(sp)
ffffffffc0202178:	4585                	li	a1,1
ffffffffc020217a:	739c                	ld	a5,32(a5)
ffffffffc020217c:	9782                	jalr	a5
        intr_enable();
ffffffffc020217e:	b6afe0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc0202182:	b319                	j	ffffffffc0201e88 <pmm_init+0x392>
        intr_disable();
ffffffffc0202184:	b6afe0ef          	jal	ra,ffffffffc02004ee <intr_disable>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc0202188:	000bb783          	ld	a5,0(s7)
ffffffffc020218c:	779c                	ld	a5,40(a5)
ffffffffc020218e:	9782                	jalr	a5
ffffffffc0202190:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0202192:	b56fe0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc0202196:	b71d                	j	ffffffffc02020bc <pmm_init+0x5c6>
ffffffffc0202198:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc020219a:	b54fe0ef          	jal	ra,ffffffffc02004ee <intr_disable>
    { pmm_manager->free_pages(base, n); }
ffffffffc020219e:	000bb783          	ld	a5,0(s7)
ffffffffc02021a2:	6522                	ld	a0,8(sp)
ffffffffc02021a4:	4585                	li	a1,1
ffffffffc02021a6:	739c                	ld	a5,32(a5)
ffffffffc02021a8:	9782                	jalr	a5
        intr_enable();
ffffffffc02021aa:	b3efe0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc02021ae:	bdcd                	j	ffffffffc02020a0 <pmm_init+0x5aa>
ffffffffc02021b0:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc02021b2:	b3cfe0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc02021b6:	000bb783          	ld	a5,0(s7)
ffffffffc02021ba:	6522                	ld	a0,8(sp)
ffffffffc02021bc:	4585                	li	a1,1
ffffffffc02021be:	739c                	ld	a5,32(a5)
ffffffffc02021c0:	9782                	jalr	a5
        intr_enable();
ffffffffc02021c2:	b26fe0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc02021c6:	b555                	j	ffffffffc020206a <pmm_init+0x574>
        intr_disable();
ffffffffc02021c8:	b26fe0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc02021cc:	000bb783          	ld	a5,0(s7)
ffffffffc02021d0:	4585                	li	a1,1
ffffffffc02021d2:	8556                	mv	a0,s5
ffffffffc02021d4:	739c                	ld	a5,32(a5)
ffffffffc02021d6:	9782                	jalr	a5
        intr_enable();
ffffffffc02021d8:	b10fe0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc02021dc:	bda9                	j	ffffffffc0202036 <pmm_init+0x540>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc02021de:	00003697          	auipc	a3,0x3
ffffffffc02021e2:	4f268693          	addi	a3,a3,1266 # ffffffffc02056d0 <default_pmm_manager+0x4c0>
ffffffffc02021e6:	00003617          	auipc	a2,0x3
ffffffffc02021ea:	c7a60613          	addi	a2,a2,-902 # ffffffffc0204e60 <commands+0x760>
ffffffffc02021ee:	1f100593          	li	a1,497
ffffffffc02021f2:	00003517          	auipc	a0,0x3
ffffffffc02021f6:	0d650513          	addi	a0,a0,214 # ffffffffc02052c8 <default_pmm_manager+0xb8>
ffffffffc02021fa:	97afe0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc02021fe:	00003697          	auipc	a3,0x3
ffffffffc0202202:	49268693          	addi	a3,a3,1170 # ffffffffc0205690 <default_pmm_manager+0x480>
ffffffffc0202206:	00003617          	auipc	a2,0x3
ffffffffc020220a:	c5a60613          	addi	a2,a2,-934 # ffffffffc0204e60 <commands+0x760>
ffffffffc020220e:	1f000593          	li	a1,496
ffffffffc0202212:	00003517          	auipc	a0,0x3
ffffffffc0202216:	0b650513          	addi	a0,a0,182 # ffffffffc02052c8 <default_pmm_manager+0xb8>
ffffffffc020221a:	95afe0ef          	jal	ra,ffffffffc0200374 <__panic>
ffffffffc020221e:	86a2                	mv	a3,s0
ffffffffc0202220:	00003617          	auipc	a2,0x3
ffffffffc0202224:	08060613          	addi	a2,a2,128 # ffffffffc02052a0 <default_pmm_manager+0x90>
ffffffffc0202228:	1f000593          	li	a1,496
ffffffffc020222c:	00003517          	auipc	a0,0x3
ffffffffc0202230:	09c50513          	addi	a0,a0,156 # ffffffffc02052c8 <default_pmm_manager+0xb8>
ffffffffc0202234:	940fe0ef          	jal	ra,ffffffffc0200374 <__panic>
ffffffffc0202238:	b90ff0ef          	jal	ra,ffffffffc02015c8 <pa2page.part.0>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc020223c:	00003617          	auipc	a2,0x3
ffffffffc0202240:	12460613          	addi	a2,a2,292 # ffffffffc0205360 <default_pmm_manager+0x150>
ffffffffc0202244:	07700593          	li	a1,119
ffffffffc0202248:	00003517          	auipc	a0,0x3
ffffffffc020224c:	08050513          	addi	a0,a0,128 # ffffffffc02052c8 <default_pmm_manager+0xb8>
ffffffffc0202250:	924fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc0202254:	00003617          	auipc	a2,0x3
ffffffffc0202258:	10c60613          	addi	a2,a2,268 # ffffffffc0205360 <default_pmm_manager+0x150>
ffffffffc020225c:	0bd00593          	li	a1,189
ffffffffc0202260:	00003517          	auipc	a0,0x3
ffffffffc0202264:	06850513          	addi	a0,a0,104 # ffffffffc02052c8 <default_pmm_manager+0xb8>
ffffffffc0202268:	90cfe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(boot_pgdir!= NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc020226c:	00003697          	auipc	a3,0x3
ffffffffc0202270:	15c68693          	addi	a3,a3,348 # ffffffffc02053c8 <default_pmm_manager+0x1b8>
ffffffffc0202274:	00003617          	auipc	a2,0x3
ffffffffc0202278:	bec60613          	addi	a2,a2,-1044 # ffffffffc0204e60 <commands+0x760>
ffffffffc020227c:	19500593          	li	a1,405
ffffffffc0202280:	00003517          	auipc	a0,0x3
ffffffffc0202284:	04850513          	addi	a0,a0,72 # ffffffffc02052c8 <default_pmm_manager+0xb8>
ffffffffc0202288:	8ecfe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc020228c:	00003697          	auipc	a3,0x3
ffffffffc0202290:	11c68693          	addi	a3,a3,284 # ffffffffc02053a8 <default_pmm_manager+0x198>
ffffffffc0202294:	00003617          	auipc	a2,0x3
ffffffffc0202298:	bcc60613          	addi	a2,a2,-1076 # ffffffffc0204e60 <commands+0x760>
ffffffffc020229c:	19300593          	li	a1,403
ffffffffc02022a0:	00003517          	auipc	a0,0x3
ffffffffc02022a4:	02850513          	addi	a0,a0,40 # ffffffffc02052c8 <default_pmm_manager+0xb8>
ffffffffc02022a8:	8ccfe0ef          	jal	ra,ffffffffc0200374 <__panic>
ffffffffc02022ac:	b38ff0ef          	jal	ra,ffffffffc02015e4 <pte2page.part.0>
    assert((ptep = get_pte(boot_pgdir, 0x0, 0))!= NULL);
ffffffffc02022b0:	00003697          	auipc	a3,0x3
ffffffffc02022b4:	1a868693          	addi	a3,a3,424 # ffffffffc0205458 <default_pmm_manager+0x248>
ffffffffc02022b8:	00003617          	auipc	a2,0x3
ffffffffc02022bc:	ba860613          	addi	a2,a2,-1112 # ffffffffc0204e60 <commands+0x760>
ffffffffc02022c0:	1a000593          	li	a1,416
ffffffffc02022c4:	00003517          	auipc	a0,0x3
ffffffffc02022c8:	00450513          	addi	a0,a0,4 # ffffffffc02052c8 <default_pmm_manager+0xb8>
ffffffffc02022cc:	8a8fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc02022d0:	00003697          	auipc	a3,0x3
ffffffffc02022d4:	15868693          	addi	a3,a3,344 # ffffffffc0205428 <default_pmm_manager+0x218>
ffffffffc02022d8:	00003617          	auipc	a2,0x3
ffffffffc02022dc:	b8860613          	addi	a2,a2,-1144 # ffffffffc0204e60 <commands+0x760>
ffffffffc02022e0:	19d00593          	li	a1,413
ffffffffc02022e4:	00003517          	auipc	a0,0x3
ffffffffc02022e8:	fe450513          	addi	a0,a0,-28 # ffffffffc02052c8 <default_pmm_manager+0xb8>
ffffffffc02022ec:	888fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc02022f0:	00003697          	auipc	a3,0x3
ffffffffc02022f4:	11068693          	addi	a3,a3,272 # ffffffffc0205400 <default_pmm_manager+0x1f0>
ffffffffc02022f8:	00003617          	auipc	a2,0x3
ffffffffc02022fc:	b6860613          	addi	a2,a2,-1176 # ffffffffc0204e60 <commands+0x760>
ffffffffc0202300:	19700593          	li	a1,407
ffffffffc0202304:	00003517          	auipc	a0,0x3
ffffffffc0202308:	fc450513          	addi	a0,a0,-60 # ffffffffc02052c8 <default_pmm_manager+0xb8>
ffffffffc020230c:	868fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0202310:	00003697          	auipc	a3,0x3
ffffffffc0202314:	1d068693          	addi	a3,a3,464 # ffffffffc02054e0 <default_pmm_manager+0x2d0>
ffffffffc0202318:	00003617          	auipc	a2,0x3
ffffffffc020231c:	b4860613          	addi	a2,a2,-1208 # ffffffffc0204e60 <commands+0x760>
ffffffffc0202320:	1b000593          	li	a1,432
ffffffffc0202324:	00003517          	auipc	a0,0x3
ffffffffc0202328:	fa450513          	addi	a0,a0,-92 # ffffffffc02052c8 <default_pmm_manager+0xb8>
ffffffffc020232c:	848fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p2) == 1);
ffffffffc0202330:	00003697          	auipc	a3,0x3
ffffffffc0202334:	25068693          	addi	a3,a3,592 # ffffffffc0205580 <default_pmm_manager+0x370>
ffffffffc0202338:	00003617          	auipc	a2,0x3
ffffffffc020233c:	b2860613          	addi	a2,a2,-1240 # ffffffffc0204e60 <commands+0x760>
ffffffffc0202340:	1b900593          	li	a1,441
ffffffffc0202344:	00003517          	auipc	a0,0x3
ffffffffc0202348:	f8450513          	addi	a0,a0,-124 # ffffffffc02052c8 <default_pmm_manager+0xb8>
ffffffffc020234c:	828fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0202350:	00003697          	auipc	a3,0x3
ffffffffc0202354:	16868693          	addi	a3,a3,360 # ffffffffc02054b8 <default_pmm_manager+0x2a8>
ffffffffc0202358:	00003617          	auipc	a2,0x3
ffffffffc020235c:	b0860613          	addi	a2,a2,-1272 # ffffffffc0204e60 <commands+0x760>
ffffffffc0202360:	1ab00593          	li	a1,427
ffffffffc0202364:	00003517          	auipc	a0,0x3
ffffffffc0202368:	f6450513          	addi	a0,a0,-156 # ffffffffc02052c8 <default_pmm_manager+0xb8>
ffffffffc020236c:	808fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202370:	86d6                	mv	a3,s5
ffffffffc0202372:	00003617          	auipc	a2,0x3
ffffffffc0202376:	f2e60613          	addi	a2,a2,-210 # ffffffffc02052a0 <default_pmm_manager+0x90>
ffffffffc020237a:	1a900593          	li	a1,425
ffffffffc020237e:	00003517          	auipc	a0,0x3
ffffffffc0202382:	f4a50513          	addi	a0,a0,-182 # ffffffffc02052c8 <default_pmm_manager+0xb8>
ffffffffc0202386:	feffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0))!= NULL);
ffffffffc020238a:	00003697          	auipc	a3,0x3
ffffffffc020238e:	18e68693          	addi	a3,a3,398 # ffffffffc0205518 <default_pmm_manager+0x308>
ffffffffc0202392:	00003617          	auipc	a2,0x3
ffffffffc0202396:	ace60613          	addi	a2,a2,-1330 # ffffffffc0204e60 <commands+0x760>
ffffffffc020239a:	1c200593          	li	a1,450
ffffffffc020239e:	00003517          	auipc	a0,0x3
ffffffffc02023a2:	f2a50513          	addi	a0,a0,-214 # ffffffffc02052c8 <default_pmm_manager+0xb8>
ffffffffc02023a6:	fcffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc02023aa:	00003697          	auipc	a3,0x3
ffffffffc02023ae:	23668693          	addi	a3,a3,566 # ffffffffc02055e0 <default_pmm_manager+0x3d0>
ffffffffc02023b2:	00003617          	auipc	a2,0x3
ffffffffc02023b6:	aae60613          	addi	a2,a2,-1362 # ffffffffc0204e60 <commands+0x760>
ffffffffc02023ba:	1c000593          	li	a1,448
ffffffffc02023be:	00003517          	auipc	a0,0x3
ffffffffc02023c2:	f0a50513          	addi	a0,a0,-246 # ffffffffc02052c8 <default_pmm_manager+0xb8>
ffffffffc02023c6:	faffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p1) == 2);
ffffffffc02023ca:	00003697          	auipc	a3,0x3
ffffffffc02023ce:	1fe68693          	addi	a3,a3,510 # ffffffffc02055c8 <default_pmm_manager+0x3b8>
ffffffffc02023d2:	00003617          	auipc	a2,0x3
ffffffffc02023d6:	a8e60613          	addi	a2,a2,-1394 # ffffffffc0204e60 <commands+0x760>
ffffffffc02023da:	1be00593          	li	a1,446
ffffffffc02023de:	00003517          	auipc	a0,0x3
ffffffffc02023e2:	eea50513          	addi	a0,a0,-278 # ffffffffc02052c8 <default_pmm_manager+0xb8>
ffffffffc02023e6:	f8ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc02023ea:	00003697          	auipc	a3,0x3
ffffffffc02023ee:	1ae68693          	addi	a3,a3,430 # ffffffffc0205598 <default_pmm_manager+0x388>
ffffffffc02023f2:	00003617          	auipc	a2,0x3
ffffffffc02023f6:	a6e60613          	addi	a2,a2,-1426 # ffffffffc0204e60 <commands+0x760>
ffffffffc02023fa:	1bc00593          	li	a1,444
ffffffffc02023fe:	00003517          	auipc	a0,0x3
ffffffffc0202402:	eca50513          	addi	a0,a0,-310 # ffffffffc02052c8 <default_pmm_manager+0xb8>
ffffffffc0202406:	f6ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc020240a:	00003697          	auipc	a3,0x3
ffffffffc020240e:	34668693          	addi	a3,a3,838 # ffffffffc0205750 <default_pmm_manager+0x540>
ffffffffc0202412:	00003617          	auipc	a2,0x3
ffffffffc0202416:	a4e60613          	addi	a2,a2,-1458 # ffffffffc0204e60 <commands+0x760>
ffffffffc020241a:	1fb00593          	li	a1,507
ffffffffc020241e:	00003517          	auipc	a0,0x3
ffffffffc0202422:	eaa50513          	addi	a0,a0,-342 # ffffffffc02052c8 <default_pmm_manager+0xb8>
ffffffffc0202426:	f4ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc020242a:	00003697          	auipc	a3,0x3
ffffffffc020242e:	13e68693          	addi	a3,a3,318 # ffffffffc0205568 <default_pmm_manager+0x358>
ffffffffc0202432:	00003617          	auipc	a2,0x3
ffffffffc0202436:	a2e60613          	addi	a2,a2,-1490 # ffffffffc0204e60 <commands+0x760>
ffffffffc020243a:	1b700593          	li	a1,439
ffffffffc020243e:	00003517          	auipc	a0,0x3
ffffffffc0202442:	e8a50513          	addi	a0,a0,-374 # ffffffffc02052c8 <default_pmm_manager+0xb8>
ffffffffc0202446:	f2ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(*ptep & PTE_W);
ffffffffc020244a:	00003697          	auipc	a3,0x3
ffffffffc020244e:	10e68693          	addi	a3,a3,270 # ffffffffc0205558 <default_pmm_manager+0x348>
ffffffffc0202452:	00003617          	auipc	a2,0x3
ffffffffc0202456:	a0e60613          	addi	a2,a2,-1522 # ffffffffc0204e60 <commands+0x760>
ffffffffc020245a:	1b500593          	li	a1,437
ffffffffc020245e:	00003517          	auipc	a0,0x3
ffffffffc0202462:	e6a50513          	addi	a0,a0,-406 # ffffffffc02052c8 <default_pmm_manager+0xb8>
ffffffffc0202466:	f0ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc020246a:	00003697          	auipc	a3,0x3
ffffffffc020246e:	1e668693          	addi	a3,a3,486 # ffffffffc0205650 <default_pmm_manager+0x440>
ffffffffc0202472:	00003617          	auipc	a2,0x3
ffffffffc0202476:	9ee60613          	addi	a2,a2,-1554 # ffffffffc0204e60 <commands+0x760>
ffffffffc020247a:	20b00593          	li	a1,523
ffffffffc020247e:	00003517          	auipc	a0,0x3
ffffffffc0202482:	e4a50513          	addi	a0,a0,-438 # ffffffffc02052c8 <default_pmm_manager+0xb8>
ffffffffc0202486:	eeffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(*ptep & PTE_U);
ffffffffc020248a:	00003697          	auipc	a3,0x3
ffffffffc020248e:	0be68693          	addi	a3,a3,190 # ffffffffc0205548 <default_pmm_manager+0x338>
ffffffffc0202492:	00003617          	auipc	a2,0x3
ffffffffc0202496:	9ce60613          	addi	a2,a2,-1586 # ffffffffc0204e60 <commands+0x760>
ffffffffc020249a:	1b400593          	li	a1,436
ffffffffc020249e:	00003517          	auipc	a0,0x3
ffffffffc02024a2:	e2a50513          	addi	a0,a0,-470 # ffffffffc02052c8 <default_pmm_manager+0xb8>
ffffffffc02024a6:	ecffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc02024aa:	00003697          	auipc	a3,0x3
ffffffffc02024ae:	ff668693          	addi	a3,a3,-10 # ffffffffc02054a0 <default_pmm_manager+0x290>
ffffffffc02024b2:	00003617          	auipc	a2,0x3
ffffffffc02024b6:	9ae60613          	addi	a2,a2,-1618 # ffffffffc0204e60 <commands+0x760>
ffffffffc02024ba:	1cb00593          	li	a1,459
ffffffffc02024be:	00003517          	auipc	a0,0x3
ffffffffc02024c2:	e0a50513          	addi	a0,a0,-502 # ffffffffc02052c8 <default_pmm_manager+0xb8>
ffffffffc02024c6:	eaffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc02024ca:	00003697          	auipc	a3,0x3
ffffffffc02024ce:	12e68693          	addi	a3,a3,302 # ffffffffc02055f8 <default_pmm_manager+0x3e8>
ffffffffc02024d2:	00003617          	auipc	a2,0x3
ffffffffc02024d6:	98e60613          	addi	a2,a2,-1650 # ffffffffc0204e60 <commands+0x760>
ffffffffc02024da:	1c600593          	li	a1,454
ffffffffc02024de:	00003517          	auipc	a0,0x3
ffffffffc02024e2:	dea50513          	addi	a0,a0,-534 # ffffffffc02052c8 <default_pmm_manager+0xb8>
ffffffffc02024e6:	e8ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc02024ea:	00003697          	auipc	a3,0x3
ffffffffc02024ee:	f9e68693          	addi	a3,a3,-98 # ffffffffc0205488 <default_pmm_manager+0x278>
ffffffffc02024f2:	00003617          	auipc	a2,0x3
ffffffffc02024f6:	96e60613          	addi	a2,a2,-1682 # ffffffffc0204e60 <commands+0x760>
ffffffffc02024fa:	1c400593          	li	a1,452
ffffffffc02024fe:	00003517          	auipc	a0,0x3
ffffffffc0202502:	dca50513          	addi	a0,a0,-566 # ffffffffc02052c8 <default_pmm_manager+0xb8>
ffffffffc0202506:	e6ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc020250a:	00003617          	auipc	a2,0x3
ffffffffc020250e:	d9660613          	addi	a2,a2,-618 # ffffffffc02052a0 <default_pmm_manager+0x90>
ffffffffc0202512:	06a00593          	li	a1,106
ffffffffc0202516:	00003517          	auipc	a0,0x3
ffffffffc020251a:	d5250513          	addi	a0,a0,-686 # ffffffffc0205268 <default_pmm_manager+0x58>
ffffffffc020251e:	e57fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc0202522:	00003697          	auipc	a3,0x3
ffffffffc0202526:	10668693          	addi	a3,a3,262 # ffffffffc0205628 <default_pmm_manager+0x418>
ffffffffc020252a:	00003617          	auipc	a2,0x3
ffffffffc020252e:	93660613          	addi	a2,a2,-1738 # ffffffffc0204e60 <commands+0x760>
ffffffffc0202532:	1d700593          	li	a1,471
ffffffffc0202536:	00003517          	auipc	a0,0x3
ffffffffc020253a:	d9250513          	addi	a0,a0,-622 # ffffffffc02052c8 <default_pmm_manager+0xb8>
ffffffffc020253e:	e37fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0202542:	00003697          	auipc	a3,0x3
ffffffffc0202546:	09e68693          	addi	a3,a3,158 # ffffffffc02055e0 <default_pmm_manager+0x3d0>
ffffffffc020254a:	00003617          	auipc	a2,0x3
ffffffffc020254e:	91660613          	addi	a2,a2,-1770 # ffffffffc0204e60 <commands+0x760>
ffffffffc0202552:	1d400593          	li	a1,468
ffffffffc0202556:	00003517          	auipc	a0,0x3
ffffffffc020255a:	d7250513          	addi	a0,a0,-654 # ffffffffc02052c8 <default_pmm_manager+0xb8>
ffffffffc020255e:	e17fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p1) == 0);
ffffffffc0202562:	00003697          	auipc	a3,0x3
ffffffffc0202566:	0ae68693          	addi	a3,a3,174 # ffffffffc0205610 <default_pmm_manager+0x400>
ffffffffc020256a:	00003617          	auipc	a2,0x3
ffffffffc020256e:	8f660613          	addi	a2,a2,-1802 # ffffffffc0204e60 <commands+0x760>
ffffffffc0202572:	1d200593          	li	a1,466
ffffffffc0202576:	00003517          	auipc	a0,0x3
ffffffffc020257a:	d5250513          	addi	a0,a0,-686 # ffffffffc02052c8 <default_pmm_manager+0xb8>
ffffffffc020257e:	df7fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0202582:	00003697          	auipc	a3,0x3
ffffffffc0202586:	05e68693          	addi	a3,a3,94 # ffffffffc02055e0 <default_pmm_manager+0x3d0>
ffffffffc020258a:	00003617          	auipc	a2,0x3
ffffffffc020258e:	8d660613          	addi	a2,a2,-1834 # ffffffffc0204e60 <commands+0x760>
ffffffffc0202592:	1cd00593          	li	a1,461
ffffffffc0202596:	00003517          	auipc	a0,0x3
ffffffffc020259a:	d3250513          	addi	a0,a0,-718 # ffffffffc02052c8 <default_pmm_manager+0xb8>
ffffffffc020259e:	dd7fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p) == 1);
ffffffffc02025a2:	00003697          	auipc	a3,0x3
ffffffffc02025a6:	19668693          	addi	a3,a3,406 # ffffffffc0205738 <default_pmm_manager+0x528>
ffffffffc02025aa:	00003617          	auipc	a2,0x3
ffffffffc02025ae:	8b660613          	addi	a2,a2,-1866 # ffffffffc0204e60 <commands+0x760>
ffffffffc02025b2:	1fa00593          	li	a1,506
ffffffffc02025b6:	00003517          	auipc	a0,0x3
ffffffffc02025ba:	d1250513          	addi	a0,a0,-750 # ffffffffc02052c8 <default_pmm_manager+0xb8>
ffffffffc02025be:	db7fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc02025c2:	00003697          	auipc	a3,0x3
ffffffffc02025c6:	13e68693          	addi	a3,a3,318 # ffffffffc0205700 <default_pmm_manager+0x4f0>
ffffffffc02025ca:	00003617          	auipc	a2,0x3
ffffffffc02025ce:	89660613          	addi	a2,a2,-1898 # ffffffffc0204e60 <commands+0x760>
ffffffffc02025d2:	1f900593          	li	a1,505
ffffffffc02025d6:	00003517          	auipc	a0,0x3
ffffffffc02025da:	cf250513          	addi	a0,a0,-782 # ffffffffc02052c8 <default_pmm_manager+0xb8>
ffffffffc02025de:	d97fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(boot_pgdir[0] == 0);
ffffffffc02025e2:	00003697          	auipc	a3,0x3
ffffffffc02025e6:	10668693          	addi	a3,a3,262 # ffffffffc02056e8 <default_pmm_manager+0x4d8>
ffffffffc02025ea:	00003617          	auipc	a2,0x3
ffffffffc02025ee:	87660613          	addi	a2,a2,-1930 # ffffffffc0204e60 <commands+0x760>
ffffffffc02025f2:	1f500593          	li	a1,501
ffffffffc02025f6:	00003517          	auipc	a0,0x3
ffffffffc02025fa:	cd250513          	addi	a0,a0,-814 # ffffffffc02052c8 <default_pmm_manager+0xb8>
ffffffffc02025fe:	d77fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc0202602:	00003697          	auipc	a3,0x3
ffffffffc0202606:	04e68693          	addi	a3,a3,78 # ffffffffc0205650 <default_pmm_manager+0x440>
ffffffffc020260a:	00003617          	auipc	a2,0x3
ffffffffc020260e:	85660613          	addi	a2,a2,-1962 # ffffffffc0204e60 <commands+0x760>
ffffffffc0202612:	1e200593          	li	a1,482
ffffffffc0202616:	00003517          	auipc	a0,0x3
ffffffffc020261a:	cb250513          	addi	a0,a0,-846 # ffffffffc02052c8 <default_pmm_manager+0xb8>
ffffffffc020261e:	d57fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0202622:	00003697          	auipc	a3,0x3
ffffffffc0202626:	e6668693          	addi	a3,a3,-410 # ffffffffc0205488 <default_pmm_manager+0x278>
ffffffffc020262a:	00003617          	auipc	a2,0x3
ffffffffc020262e:	83660613          	addi	a2,a2,-1994 # ffffffffc0204e60 <commands+0x760>
ffffffffc0202632:	1a200593          	li	a1,418
ffffffffc0202636:	00003517          	auipc	a0,0x3
ffffffffc020263a:	c9250513          	addi	a0,a0,-878 # ffffffffc02052c8 <default_pmm_manager+0xb8>
ffffffffc020263e:	d37fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc0202642:	00003617          	auipc	a2,0x3
ffffffffc0202646:	c5e60613          	addi	a2,a2,-930 # ffffffffc02052a0 <default_pmm_manager+0x90>
ffffffffc020264a:	1a700593          	li	a1,423
ffffffffc020264e:	00003517          	auipc	a0,0x3
ffffffffc0202652:	c7a50513          	addi	a0,a0,-902 # ffffffffc02052c8 <default_pmm_manager+0xb8>
ffffffffc0202656:	d1ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc020265a:	00003697          	auipc	a3,0x3
ffffffffc020265e:	e4668693          	addi	a3,a3,-442 # ffffffffc02054a0 <default_pmm_manager+0x290>
ffffffffc0202662:	00002617          	auipc	a2,0x2
ffffffffc0202666:	7fe60613          	addi	a2,a2,2046 # ffffffffc0204e60 <commands+0x760>
ffffffffc020266a:	1a400593          	li	a1,420
ffffffffc020266e:	00003517          	auipc	a0,0x3
ffffffffc0202672:	c5a50513          	addi	a0,a0,-934 # ffffffffc02052c8 <default_pmm_manager+0xb8>
ffffffffc0202676:	cfffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0))!= NULL);
ffffffffc020267a:	00003697          	auipc	a3,0x3
ffffffffc020267e:	e9e68693          	addi	a3,a3,-354 # ffffffffc0205518 <default_pmm_manager+0x308>
ffffffffc0202682:	00002617          	auipc	a2,0x2
ffffffffc0202686:	7de60613          	addi	a2,a2,2014 # ffffffffc0204e60 <commands+0x760>
ffffffffc020268a:	1b200593          	li	a1,434
ffffffffc020268e:	00003517          	auipc	a0,0x3
ffffffffc0202692:	c3a50513          	addi	a0,a0,-966 # ffffffffc02052c8 <default_pmm_manager+0xb8>
ffffffffc0202696:	cdffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(strlen((const char *)0x100) == 0);
ffffffffc020269a:	00003697          	auipc	a3,0x3
ffffffffc020269e:	15e68693          	addi	a3,a3,350 # ffffffffc02057f8 <default_pmm_manager+0x5e8>
ffffffffc02026a2:	00002617          	auipc	a2,0x2
ffffffffc02026a6:	7be60613          	addi	a2,a2,1982 # ffffffffc0204e60 <commands+0x760>
ffffffffc02026aa:	20300593          	li	a1,515
ffffffffc02026ae:	00003517          	auipc	a0,0x3
ffffffffc02026b2:	c1a50513          	addi	a0,a0,-998 # ffffffffc02052c8 <default_pmm_manager+0xb8>
ffffffffc02026b6:	cbffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc02026ba:	00003697          	auipc	a3,0x3
ffffffffc02026be:	10668693          	addi	a3,a3,262 # ffffffffc02057c0 <default_pmm_manager+0x5b0>
ffffffffc02026c2:	00002617          	auipc	a2,0x2
ffffffffc02026c6:	79e60613          	addi	a2,a2,1950 # ffffffffc0204e60 <commands+0x760>
ffffffffc02026ca:	20000593          	li	a1,512
ffffffffc02026ce:	00003517          	auipc	a0,0x3
ffffffffc02026d2:	bfa50513          	addi	a0,a0,-1030 # ffffffffc02052c8 <default_pmm_manager+0xb8>
ffffffffc02026d6:	c9ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p) == 2);
ffffffffc02026da:	00003697          	auipc	a3,0x3
ffffffffc02026de:	0b668693          	addi	a3,a3,182 # ffffffffc0205790 <default_pmm_manager+0x580>
ffffffffc02026e2:	00002617          	auipc	a2,0x2
ffffffffc02026e6:	77e60613          	addi	a2,a2,1918 # ffffffffc0204e60 <commands+0x760>
ffffffffc02026ea:	1fc00593          	li	a1,508
ffffffffc02026ee:	00003517          	auipc	a0,0x3
ffffffffc02026f2:	bda50513          	addi	a0,a0,-1062 # ffffffffc02052c8 <default_pmm_manager+0xb8>
ffffffffc02026f6:	c7ffd0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc02026fa <tlb_invalidate>:
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc02026fa:	12000073          	sfence.vma
void tlb_invalidate(pde_t *pgdir, uintptr_t la) { flush_tlb(); }
ffffffffc02026fe:	8082                	ret

ffffffffc0202700 <pgdir_alloc_page>:
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0202700:	7179                	addi	sp,sp,-48
ffffffffc0202702:	e84a                	sd	s2,16(sp)
ffffffffc0202704:	892a                	mv	s2,a0
    struct Page *page = alloc_page();
ffffffffc0202706:	4505                	li	a0,1
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0202708:	f022                	sd	s0,32(sp)
ffffffffc020270a:	ec26                	sd	s1,24(sp)
ffffffffc020270c:	e44e                	sd	s3,8(sp)
ffffffffc020270e:	f406                	sd	ra,40(sp)
ffffffffc0202710:	84ae                	mv	s1,a1
ffffffffc0202712:	89b2                	mv	s3,a2
    struct Page *page = alloc_page();
ffffffffc0202714:	eedfe0ef          	jal	ra,ffffffffc0201600 <alloc_pages>
ffffffffc0202718:	842a                	mv	s0,a0
    if (page != NULL) {
ffffffffc020271a:	cd09                	beqz	a0,ffffffffc0202734 <pgdir_alloc_page+0x34>
        if (page_insert(pgdir, page, la, perm) != 0) {
ffffffffc020271c:	85aa                	mv	a1,a0
ffffffffc020271e:	86ce                	mv	a3,s3
ffffffffc0202720:	8626                	mv	a2,s1
ffffffffc0202722:	854a                	mv	a0,s2
ffffffffc0202724:	ad2ff0ef          	jal	ra,ffffffffc02019f6 <page_insert>
ffffffffc0202728:	ed21                	bnez	a0,ffffffffc0202780 <pgdir_alloc_page+0x80>
        if (swap_init_ok) {
ffffffffc020272a:	0000f797          	auipc	a5,0xf
ffffffffc020272e:	e2e7a783          	lw	a5,-466(a5) # ffffffffc0211558 <swap_init_ok>
ffffffffc0202732:	eb89                	bnez	a5,ffffffffc0202744 <pgdir_alloc_page+0x44>
}
ffffffffc0202734:	70a2                	ld	ra,40(sp)
ffffffffc0202736:	8522                	mv	a0,s0
ffffffffc0202738:	7402                	ld	s0,32(sp)
ffffffffc020273a:	64e2                	ld	s1,24(sp)
ffffffffc020273c:	6942                	ld	s2,16(sp)
ffffffffc020273e:	69a2                	ld	s3,8(sp)
ffffffffc0202740:	6145                	addi	sp,sp,48
ffffffffc0202742:	8082                	ret
            swap_map_swappable(check_mm_struct, la, page, 0);
ffffffffc0202744:	4681                	li	a3,0
ffffffffc0202746:	8622                	mv	a2,s0
ffffffffc0202748:	85a6                	mv	a1,s1
ffffffffc020274a:	0000f517          	auipc	a0,0xf
ffffffffc020274e:	e1653503          	ld	a0,-490(a0) # ffffffffc0211560 <check_mm_struct>
ffffffffc0202752:	07f000ef          	jal	ra,ffffffffc0202fd0 <swap_map_swappable>
            assert(page_ref(page) == 1);
ffffffffc0202756:	4018                	lw	a4,0(s0)
            page->pra_vaddr = la;
ffffffffc0202758:	e024                	sd	s1,64(s0)
            assert(page_ref(page) == 1);
ffffffffc020275a:	4785                	li	a5,1
ffffffffc020275c:	fcf70ce3          	beq	a4,a5,ffffffffc0202734 <pgdir_alloc_page+0x34>
ffffffffc0202760:	00003697          	auipc	a3,0x3
ffffffffc0202764:	0e068693          	addi	a3,a3,224 # ffffffffc0205840 <default_pmm_manager+0x630>
ffffffffc0202768:	00002617          	auipc	a2,0x2
ffffffffc020276c:	6f860613          	addi	a2,a2,1784 # ffffffffc0204e60 <commands+0x760>
ffffffffc0202770:	17a00593          	li	a1,378
ffffffffc0202774:	00003517          	auipc	a0,0x3
ffffffffc0202778:	b5450513          	addi	a0,a0,-1196 # ffffffffc02052c8 <default_pmm_manager+0xb8>
ffffffffc020277c:	bf9fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202780:	100027f3          	csrr	a5,sstatus
ffffffffc0202784:	8b89                	andi	a5,a5,2
ffffffffc0202786:	eb99                	bnez	a5,ffffffffc020279c <pgdir_alloc_page+0x9c>
    { pmm_manager->free_pages(base, n); }
ffffffffc0202788:	0000f797          	auipc	a5,0xf
ffffffffc020278c:	db07b783          	ld	a5,-592(a5) # ffffffffc0211538 <pmm_manager>
ffffffffc0202790:	739c                	ld	a5,32(a5)
ffffffffc0202792:	8522                	mv	a0,s0
ffffffffc0202794:	4585                	li	a1,1
ffffffffc0202796:	9782                	jalr	a5
            return NULL;
ffffffffc0202798:	4401                	li	s0,0
ffffffffc020279a:	bf69                	j	ffffffffc0202734 <pgdir_alloc_page+0x34>
        intr_disable();
ffffffffc020279c:	d53fd0ef          	jal	ra,ffffffffc02004ee <intr_disable>
    { pmm_manager->free_pages(base, n); }
ffffffffc02027a0:	0000f797          	auipc	a5,0xf
ffffffffc02027a4:	d987b783          	ld	a5,-616(a5) # ffffffffc0211538 <pmm_manager>
ffffffffc02027a8:	739c                	ld	a5,32(a5)
ffffffffc02027aa:	8522                	mv	a0,s0
ffffffffc02027ac:	4585                	li	a1,1
ffffffffc02027ae:	9782                	jalr	a5
            return NULL;
ffffffffc02027b0:	4401                	li	s0,0
        intr_enable();
ffffffffc02027b2:	d37fd0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc02027b6:	bfbd                	j	ffffffffc0202734 <pgdir_alloc_page+0x34>

ffffffffc02027b8 <kmalloc>:
}

void *kmalloc(size_t n) {
ffffffffc02027b8:	1141                	addi	sp,sp,-16
    void *ptr = NULL;
    struct Page *base = NULL;
    assert(n > 0 && n < 1024 * 0124);
ffffffffc02027ba:	67d5                	lui	a5,0x15
void *kmalloc(size_t n) {
ffffffffc02027bc:	e406                	sd	ra,8(sp)
    assert(n > 0 && n < 1024 * 0124);
ffffffffc02027be:	fff50713          	addi	a4,a0,-1
ffffffffc02027c2:	17f9                	addi	a5,a5,-2
ffffffffc02027c4:	04e7ea63          	bltu	a5,a4,ffffffffc0202818 <kmalloc+0x60>
    int num_pages = (n + PGSIZE - 1) / PGSIZE;
ffffffffc02027c8:	6785                	lui	a5,0x1
ffffffffc02027ca:	17fd                	addi	a5,a5,-1
ffffffffc02027cc:	953e                	add	a0,a0,a5
    base = alloc_pages(num_pages);
ffffffffc02027ce:	8131                	srli	a0,a0,0xc
ffffffffc02027d0:	e31fe0ef          	jal	ra,ffffffffc0201600 <alloc_pages>
    assert(base != NULL);
ffffffffc02027d4:	cd3d                	beqz	a0,ffffffffc0202852 <kmalloc+0x9a>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02027d6:	0000f797          	auipc	a5,0xf
ffffffffc02027da:	d5a7b783          	ld	a5,-678(a5) # ffffffffc0211530 <pages>
ffffffffc02027de:	8d1d                	sub	a0,a0,a5
ffffffffc02027e0:	00004697          	auipc	a3,0x4
ffffffffc02027e4:	c386b683          	ld	a3,-968(a3) # ffffffffc0206418 <error_string+0x38>
ffffffffc02027e8:	850d                	srai	a0,a0,0x3
ffffffffc02027ea:	02d50533          	mul	a0,a0,a3
ffffffffc02027ee:	000806b7          	lui	a3,0x80
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc02027f2:	0000f717          	auipc	a4,0xf
ffffffffc02027f6:	d3673703          	ld	a4,-714(a4) # ffffffffc0211528 <npage>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02027fa:	9536                	add	a0,a0,a3
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc02027fc:	00c51793          	slli	a5,a0,0xc
ffffffffc0202800:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0202802:	0532                	slli	a0,a0,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0202804:	02e7fa63          	bgeu	a5,a4,ffffffffc0202838 <kmalloc+0x80>
    ptr = page2kva(base);
    return ptr;
}
ffffffffc0202808:	60a2                	ld	ra,8(sp)
ffffffffc020280a:	0000f797          	auipc	a5,0xf
ffffffffc020280e:	d367b783          	ld	a5,-714(a5) # ffffffffc0211540 <va_pa_offset>
ffffffffc0202812:	953e                	add	a0,a0,a5
ffffffffc0202814:	0141                	addi	sp,sp,16
ffffffffc0202816:	8082                	ret
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0202818:	00003697          	auipc	a3,0x3
ffffffffc020281c:	04068693          	addi	a3,a3,64 # ffffffffc0205858 <default_pmm_manager+0x648>
ffffffffc0202820:	00002617          	auipc	a2,0x2
ffffffffc0202824:	64060613          	addi	a2,a2,1600 # ffffffffc0204e60 <commands+0x760>
ffffffffc0202828:	21300593          	li	a1,531
ffffffffc020282c:	00003517          	auipc	a0,0x3
ffffffffc0202830:	a9c50513          	addi	a0,a0,-1380 # ffffffffc02052c8 <default_pmm_manager+0xb8>
ffffffffc0202834:	b41fd0ef          	jal	ra,ffffffffc0200374 <__panic>
ffffffffc0202838:	86aa                	mv	a3,a0
ffffffffc020283a:	00003617          	auipc	a2,0x3
ffffffffc020283e:	a6660613          	addi	a2,a2,-1434 # ffffffffc02052a0 <default_pmm_manager+0x90>
ffffffffc0202842:	06a00593          	li	a1,106
ffffffffc0202846:	00003517          	auipc	a0,0x3
ffffffffc020284a:	a2250513          	addi	a0,a0,-1502 # ffffffffc0205268 <default_pmm_manager+0x58>
ffffffffc020284e:	b27fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(base != NULL);
ffffffffc0202852:	00003697          	auipc	a3,0x3
ffffffffc0202856:	02668693          	addi	a3,a3,38 # ffffffffc0205878 <default_pmm_manager+0x668>
ffffffffc020285a:	00002617          	auipc	a2,0x2
ffffffffc020285e:	60660613          	addi	a2,a2,1542 # ffffffffc0204e60 <commands+0x760>
ffffffffc0202862:	21600593          	li	a1,534
ffffffffc0202866:	00003517          	auipc	a0,0x3
ffffffffc020286a:	a6250513          	addi	a0,a0,-1438 # ffffffffc02052c8 <default_pmm_manager+0xb8>
ffffffffc020286e:	b07fd0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0202872 <kfree>:

void kfree(void *ptr, size_t n) {
ffffffffc0202872:	1101                	addi	sp,sp,-32
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0202874:	67d5                	lui	a5,0x15
void kfree(void *ptr, size_t n) {
ffffffffc0202876:	ec06                	sd	ra,24(sp)
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0202878:	fff58713          	addi	a4,a1,-1
ffffffffc020287c:	17f9                	addi	a5,a5,-2
ffffffffc020287e:	0ae7ee63          	bltu	a5,a4,ffffffffc020293a <kfree+0xc8>
    assert(ptr != NULL);
ffffffffc0202882:	cd41                	beqz	a0,ffffffffc020291a <kfree+0xa8>
    struct Page *base = NULL;
    int num_pages = (n + PGSIZE - 1) / PGSIZE;
ffffffffc0202884:	6785                	lui	a5,0x1
ffffffffc0202886:	17fd                	addi	a5,a5,-1
ffffffffc0202888:	95be                	add	a1,a1,a5
static inline struct Page *kva2page(void *kva) { return pa2page(PADDR(kva)); }
ffffffffc020288a:	c02007b7          	lui	a5,0xc0200
ffffffffc020288e:	81b1                	srli	a1,a1,0xc
ffffffffc0202890:	06f56863          	bltu	a0,a5,ffffffffc0202900 <kfree+0x8e>
ffffffffc0202894:	0000f697          	auipc	a3,0xf
ffffffffc0202898:	cac6b683          	ld	a3,-852(a3) # ffffffffc0211540 <va_pa_offset>
ffffffffc020289c:	8d15                	sub	a0,a0,a3
    if (PPN(pa) >= npage) {
ffffffffc020289e:	8131                	srli	a0,a0,0xc
ffffffffc02028a0:	0000f797          	auipc	a5,0xf
ffffffffc02028a4:	c887b783          	ld	a5,-888(a5) # ffffffffc0211528 <npage>
ffffffffc02028a8:	04f57a63          	bgeu	a0,a5,ffffffffc02028fc <kfree+0x8a>
    return &pages[PPN(pa) - nbase];
ffffffffc02028ac:	fff806b7          	lui	a3,0xfff80
ffffffffc02028b0:	9536                	add	a0,a0,a3
ffffffffc02028b2:	00351793          	slli	a5,a0,0x3
ffffffffc02028b6:	953e                	add	a0,a0,a5
ffffffffc02028b8:	050e                	slli	a0,a0,0x3
ffffffffc02028ba:	0000f797          	auipc	a5,0xf
ffffffffc02028be:	c767b783          	ld	a5,-906(a5) # ffffffffc0211530 <pages>
ffffffffc02028c2:	953e                	add	a0,a0,a5
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02028c4:	100027f3          	csrr	a5,sstatus
ffffffffc02028c8:	8b89                	andi	a5,a5,2
ffffffffc02028ca:	eb89                	bnez	a5,ffffffffc02028dc <kfree+0x6a>
    { pmm_manager->free_pages(base, n); }
ffffffffc02028cc:	0000f797          	auipc	a5,0xf
ffffffffc02028d0:	c6c7b783          	ld	a5,-916(a5) # ffffffffc0211538 <pmm_manager>
    base = kva2page(ptr);
    free_pages(base, num_pages);
}
ffffffffc02028d4:	60e2                	ld	ra,24(sp)
    { pmm_manager->free_pages(base, n); }
ffffffffc02028d6:	739c                	ld	a5,32(a5)
}
ffffffffc02028d8:	6105                	addi	sp,sp,32
    { pmm_manager->free_pages(base, n); }
ffffffffc02028da:	8782                	jr	a5
        intr_disable();
ffffffffc02028dc:	e42a                	sd	a0,8(sp)
ffffffffc02028de:	e02e                	sd	a1,0(sp)
ffffffffc02028e0:	c0ffd0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc02028e4:	0000f797          	auipc	a5,0xf
ffffffffc02028e8:	c547b783          	ld	a5,-940(a5) # ffffffffc0211538 <pmm_manager>
ffffffffc02028ec:	6582                	ld	a1,0(sp)
ffffffffc02028ee:	6522                	ld	a0,8(sp)
ffffffffc02028f0:	739c                	ld	a5,32(a5)
ffffffffc02028f2:	9782                	jalr	a5
}
ffffffffc02028f4:	60e2                	ld	ra,24(sp)
ffffffffc02028f6:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc02028f8:	bf1fd06f          	j	ffffffffc02004e8 <intr_enable>
ffffffffc02028fc:	ccdfe0ef          	jal	ra,ffffffffc02015c8 <pa2page.part.0>
static inline struct Page *kva2page(void *kva) { return pa2page(PADDR(kva)); }
ffffffffc0202900:	86aa                	mv	a3,a0
ffffffffc0202902:	00003617          	auipc	a2,0x3
ffffffffc0202906:	a5e60613          	addi	a2,a2,-1442 # ffffffffc0205360 <default_pmm_manager+0x150>
ffffffffc020290a:	06c00593          	li	a1,108
ffffffffc020290e:	00003517          	auipc	a0,0x3
ffffffffc0202912:	95a50513          	addi	a0,a0,-1702 # ffffffffc0205268 <default_pmm_manager+0x58>
ffffffffc0202916:	a5ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(ptr != NULL);
ffffffffc020291a:	00003697          	auipc	a3,0x3
ffffffffc020291e:	f6e68693          	addi	a3,a3,-146 # ffffffffc0205888 <default_pmm_manager+0x678>
ffffffffc0202922:	00002617          	auipc	a2,0x2
ffffffffc0202926:	53e60613          	addi	a2,a2,1342 # ffffffffc0204e60 <commands+0x760>
ffffffffc020292a:	21d00593          	li	a1,541
ffffffffc020292e:	00003517          	auipc	a0,0x3
ffffffffc0202932:	99a50513          	addi	a0,a0,-1638 # ffffffffc02052c8 <default_pmm_manager+0xb8>
ffffffffc0202936:	a3ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(n > 0 && n < 1024 * 0124);
ffffffffc020293a:	00003697          	auipc	a3,0x3
ffffffffc020293e:	f1e68693          	addi	a3,a3,-226 # ffffffffc0205858 <default_pmm_manager+0x648>
ffffffffc0202942:	00002617          	auipc	a2,0x2
ffffffffc0202946:	51e60613          	addi	a2,a2,1310 # ffffffffc0204e60 <commands+0x760>
ffffffffc020294a:	21c00593          	li	a1,540
ffffffffc020294e:	00003517          	auipc	a0,0x3
ffffffffc0202952:	97a50513          	addi	a0,a0,-1670 # ffffffffc02052c8 <default_pmm_manager+0xb8>
ffffffffc0202956:	a1ffd0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc020295a <swap_init>:
unsigned int swap_in_seq_no[MAX_SEQ_NO], swap_out_seq_no[MAX_SEQ_NO];

static void check_swap(void);

int swap_init(void)
{
ffffffffc020295a:	7135                	addi	sp,sp,-160
ffffffffc020295c:	ed06                	sd	ra,152(sp)
ffffffffc020295e:	e922                	sd	s0,144(sp)
ffffffffc0202960:	e526                	sd	s1,136(sp)
ffffffffc0202962:	e14a                	sd	s2,128(sp)
ffffffffc0202964:	fcce                	sd	s3,120(sp)
ffffffffc0202966:	f8d2                	sd	s4,112(sp)
ffffffffc0202968:	f4d6                	sd	s5,104(sp)
ffffffffc020296a:	f0da                	sd	s6,96(sp)
ffffffffc020296c:	ecde                	sd	s7,88(sp)
ffffffffc020296e:	e8e2                	sd	s8,80(sp)
ffffffffc0202970:	e4e6                	sd	s9,72(sp)
ffffffffc0202972:	e0ea                	sd	s10,64(sp)
ffffffffc0202974:	fc6e                	sd	s11,56(sp)
     swapfs_init();
ffffffffc0202976:	478010ef          	jal	ra,ffffffffc0203dee <swapfs_init>

     // Since the IDE is faked, it can only store 7 pages at most to pass the test
     if (!(7 <= max_swap_offset &&
ffffffffc020297a:	0000f697          	auipc	a3,0xf
ffffffffc020297e:	bce6b683          	ld	a3,-1074(a3) # ffffffffc0211548 <max_swap_offset>
ffffffffc0202982:	010007b7          	lui	a5,0x1000
ffffffffc0202986:	ff968713          	addi	a4,a3,-7
ffffffffc020298a:	17e1                	addi	a5,a5,-8
ffffffffc020298c:	3ee7e063          	bltu	a5,a4,ffffffffc0202d6c <swap_init+0x412>
           max_swap_offset < MAX_SWAP_OFFSET_LIMIT))
     {
          panic("bad max_swap_offset %08x.\n", max_swap_offset);
     }
     sm = &swap_manager_fifo;
ffffffffc0202990:	00007797          	auipc	a5,0x7
ffffffffc0202994:	67078793          	addi	a5,a5,1648 # ffffffffc020a000 <swap_manager_fifo>
     //  sm = &swap_manager_clock;//use first in first out Page Replacement Algorithm
     int r = sm->init();
ffffffffc0202998:	6798                	ld	a4,8(a5)
     sm = &swap_manager_fifo;
ffffffffc020299a:	0000fb17          	auipc	s6,0xf
ffffffffc020299e:	bb6b0b13          	addi	s6,s6,-1098 # ffffffffc0211550 <sm>
ffffffffc02029a2:	00fb3023          	sd	a5,0(s6)
     int r = sm->init();
ffffffffc02029a6:	9702                	jalr	a4
ffffffffc02029a8:	89aa                	mv	s3,a0

     if (r == 0)
ffffffffc02029aa:	c10d                	beqz	a0,ffffffffc02029cc <swap_init+0x72>
          cprintf("SWAP: manager = %s\n", sm->name);
          check_swap();
     }

     return r;
}
ffffffffc02029ac:	60ea                	ld	ra,152(sp)
ffffffffc02029ae:	644a                	ld	s0,144(sp)
ffffffffc02029b0:	64aa                	ld	s1,136(sp)
ffffffffc02029b2:	690a                	ld	s2,128(sp)
ffffffffc02029b4:	7a46                	ld	s4,112(sp)
ffffffffc02029b6:	7aa6                	ld	s5,104(sp)
ffffffffc02029b8:	7b06                	ld	s6,96(sp)
ffffffffc02029ba:	6be6                	ld	s7,88(sp)
ffffffffc02029bc:	6c46                	ld	s8,80(sp)
ffffffffc02029be:	6ca6                	ld	s9,72(sp)
ffffffffc02029c0:	6d06                	ld	s10,64(sp)
ffffffffc02029c2:	7de2                	ld	s11,56(sp)
ffffffffc02029c4:	854e                	mv	a0,s3
ffffffffc02029c6:	79e6                	ld	s3,120(sp)
ffffffffc02029c8:	610d                	addi	sp,sp,160
ffffffffc02029ca:	8082                	ret
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc02029cc:	000b3783          	ld	a5,0(s6)
ffffffffc02029d0:	00003517          	auipc	a0,0x3
ffffffffc02029d4:	ef850513          	addi	a0,a0,-264 # ffffffffc02058c8 <default_pmm_manager+0x6b8>
    return listelm->next;
ffffffffc02029d8:	0000e497          	auipc	s1,0xe
ffffffffc02029dc:	66848493          	addi	s1,s1,1640 # ffffffffc0211040 <free_area>
ffffffffc02029e0:	638c                	ld	a1,0(a5)
          swap_init_ok = 1;
ffffffffc02029e2:	4785                	li	a5,1
ffffffffc02029e4:	0000f717          	auipc	a4,0xf
ffffffffc02029e8:	b6f72a23          	sw	a5,-1164(a4) # ffffffffc0211558 <swap_init_ok>
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc02029ec:	ecefd0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc02029f0:	649c                	ld	a5,8(s1)

static void
check_swap(void)
{
     // backup mem env
     int ret, count = 0, total = 0, i;
ffffffffc02029f2:	4401                	li	s0,0
ffffffffc02029f4:	4d01                	li	s10,0
     list_entry_t *le = &free_list;
     while ((le = list_next(le)) != &free_list)
ffffffffc02029f6:	2c978163          	beq	a5,s1,ffffffffc0202cb8 <swap_init+0x35e>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc02029fa:	fe87b703          	ld	a4,-24(a5)
     {
          struct Page *p = le2page(le, page_link);
          assert(PageProperty(p));
ffffffffc02029fe:	8b09                	andi	a4,a4,2
ffffffffc0202a00:	2a070e63          	beqz	a4,ffffffffc0202cbc <swap_init+0x362>
          count++, total += p->property;
ffffffffc0202a04:	ff87a703          	lw	a4,-8(a5)
ffffffffc0202a08:	679c                	ld	a5,8(a5)
ffffffffc0202a0a:	2d05                	addiw	s10,s10,1
ffffffffc0202a0c:	9c39                	addw	s0,s0,a4
     while ((le = list_next(le)) != &free_list)
ffffffffc0202a0e:	fe9796e3          	bne	a5,s1,ffffffffc02029fa <swap_init+0xa0>
     }
     assert(total == nr_free_pages());
ffffffffc0202a12:	8922                	mv	s2,s0
ffffffffc0202a14:	cbffe0ef          	jal	ra,ffffffffc02016d2 <nr_free_pages>
ffffffffc0202a18:	47251663          	bne	a0,s2,ffffffffc0202e84 <swap_init+0x52a>
     cprintf("BEGIN check_swap: count %d, total %d\n", count, total);
ffffffffc0202a1c:	8622                	mv	a2,s0
ffffffffc0202a1e:	85ea                	mv	a1,s10
ffffffffc0202a20:	00003517          	auipc	a0,0x3
ffffffffc0202a24:	ec050513          	addi	a0,a0,-320 # ffffffffc02058e0 <default_pmm_manager+0x6d0>
ffffffffc0202a28:	e92fd0ef          	jal	ra,ffffffffc02000ba <cprintf>

     // now we set the phy pages env
     struct mm_struct *mm = mm_create();
ffffffffc0202a2c:	361000ef          	jal	ra,ffffffffc020358c <mm_create>
ffffffffc0202a30:	8aaa                	mv	s5,a0
     assert(mm != NULL);
ffffffffc0202a32:	52050963          	beqz	a0,ffffffffc0202f64 <swap_init+0x60a>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
ffffffffc0202a36:	0000f797          	auipc	a5,0xf
ffffffffc0202a3a:	b2a78793          	addi	a5,a5,-1238 # ffffffffc0211560 <check_mm_struct>
ffffffffc0202a3e:	6398                	ld	a4,0(a5)
ffffffffc0202a40:	54071263          	bnez	a4,ffffffffc0202f84 <swap_init+0x62a>

     check_mm_struct = mm;

     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0202a44:	0000fb97          	auipc	s7,0xf
ffffffffc0202a48:	adcbbb83          	ld	s7,-1316(s7) # ffffffffc0211520 <boot_pgdir>
     assert(pgdir[0] == 0);
ffffffffc0202a4c:	000bb703          	ld	a4,0(s7)
     check_mm_struct = mm;
ffffffffc0202a50:	e388                	sd	a0,0(a5)
     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0202a52:	01753c23          	sd	s7,24(a0)
     assert(pgdir[0] == 0);
ffffffffc0202a56:	3c071763          	bnez	a4,ffffffffc0202e24 <swap_init+0x4ca>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
ffffffffc0202a5a:	6599                	lui	a1,0x6
ffffffffc0202a5c:	460d                	li	a2,3
ffffffffc0202a5e:	6505                	lui	a0,0x1
ffffffffc0202a60:	375000ef          	jal	ra,ffffffffc02035d4 <vma_create>
ffffffffc0202a64:	85aa                	mv	a1,a0
     assert(vma != NULL);
ffffffffc0202a66:	3c050f63          	beqz	a0,ffffffffc0202e44 <swap_init+0x4ea>

     insert_vma_struct(mm, vma);
ffffffffc0202a6a:	8556                	mv	a0,s5
ffffffffc0202a6c:	3d7000ef          	jal	ra,ffffffffc0203642 <insert_vma_struct>

     // setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
ffffffffc0202a70:	00003517          	auipc	a0,0x3
ffffffffc0202a74:	ee050513          	addi	a0,a0,-288 # ffffffffc0205950 <default_pmm_manager+0x740>
ffffffffc0202a78:	e42fd0ef          	jal	ra,ffffffffc02000ba <cprintf>
     pte_t *temp_ptep = NULL;
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
ffffffffc0202a7c:	018ab503          	ld	a0,24(s5)
ffffffffc0202a80:	4605                	li	a2,1
ffffffffc0202a82:	6585                	lui	a1,0x1
ffffffffc0202a84:	c89fe0ef          	jal	ra,ffffffffc020170c <get_pte>
     assert(temp_ptep != NULL);
ffffffffc0202a88:	3c050e63          	beqz	a0,ffffffffc0202e64 <swap_init+0x50a>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc0202a8c:	00003517          	auipc	a0,0x3
ffffffffc0202a90:	f1450513          	addi	a0,a0,-236 # ffffffffc02059a0 <default_pmm_manager+0x790>
ffffffffc0202a94:	0000e917          	auipc	s2,0xe
ffffffffc0202a98:	5e490913          	addi	s2,s2,1508 # ffffffffc0211078 <check_rp>
ffffffffc0202a9c:	e1efd0ef          	jal	ra,ffffffffc02000ba <cprintf>

     for (i = 0; i < CHECK_VALID_PHY_PAGE_NUM; i++)
ffffffffc0202aa0:	0000ea17          	auipc	s4,0xe
ffffffffc0202aa4:	5f8a0a13          	addi	s4,s4,1528 # ffffffffc0211098 <swap_in_seq_no>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc0202aa8:	8c4a                	mv	s8,s2
     {
          check_rp[i] = alloc_page();
ffffffffc0202aaa:	4505                	li	a0,1
ffffffffc0202aac:	b55fe0ef          	jal	ra,ffffffffc0201600 <alloc_pages>
ffffffffc0202ab0:	00ac3023          	sd	a0,0(s8)
          assert(check_rp[i] != NULL);
ffffffffc0202ab4:	28050c63          	beqz	a0,ffffffffc0202d4c <swap_init+0x3f2>
ffffffffc0202ab8:	651c                	ld	a5,8(a0)
          assert(!PageProperty(check_rp[i]));
ffffffffc0202aba:	8b89                	andi	a5,a5,2
ffffffffc0202abc:	26079863          	bnez	a5,ffffffffc0202d2c <swap_init+0x3d2>
     for (i = 0; i < CHECK_VALID_PHY_PAGE_NUM; i++)
ffffffffc0202ac0:	0c21                	addi	s8,s8,8
ffffffffc0202ac2:	ff4c14e3          	bne	s8,s4,ffffffffc0202aaa <swap_init+0x150>
     }
     list_entry_t free_list_store = free_list;
ffffffffc0202ac6:	609c                	ld	a5,0(s1)
ffffffffc0202ac8:	0084bd83          	ld	s11,8(s1)
    elm->prev = elm->next = elm;
ffffffffc0202acc:	e084                	sd	s1,0(s1)
ffffffffc0202ace:	f03e                	sd	a5,32(sp)
     list_init(&free_list);
     assert(list_empty(&free_list));

     // assert(alloc_page() == NULL);

     unsigned int nr_free_store = nr_free;
ffffffffc0202ad0:	489c                	lw	a5,16(s1)
ffffffffc0202ad2:	e484                	sd	s1,8(s1)
     nr_free = 0;
ffffffffc0202ad4:	0000ec17          	auipc	s8,0xe
ffffffffc0202ad8:	5a4c0c13          	addi	s8,s8,1444 # ffffffffc0211078 <check_rp>
     unsigned int nr_free_store = nr_free;
ffffffffc0202adc:	f43e                	sd	a5,40(sp)
     nr_free = 0;
ffffffffc0202ade:	0000e797          	auipc	a5,0xe
ffffffffc0202ae2:	5607a923          	sw	zero,1394(a5) # ffffffffc0211050 <free_area+0x10>
     for (i = 0; i < CHECK_VALID_PHY_PAGE_NUM; i++)
     {
          free_pages(check_rp[i], 1);
ffffffffc0202ae6:	000c3503          	ld	a0,0(s8)
ffffffffc0202aea:	4585                	li	a1,1
     for (i = 0; i < CHECK_VALID_PHY_PAGE_NUM; i++)
ffffffffc0202aec:	0c21                	addi	s8,s8,8
          free_pages(check_rp[i], 1);
ffffffffc0202aee:	ba5fe0ef          	jal	ra,ffffffffc0201692 <free_pages>
     for (i = 0; i < CHECK_VALID_PHY_PAGE_NUM; i++)
ffffffffc0202af2:	ff4c1ae3          	bne	s8,s4,ffffffffc0202ae6 <swap_init+0x18c>
     }
     assert(nr_free == CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0202af6:	0104ac03          	lw	s8,16(s1)
ffffffffc0202afa:	4791                	li	a5,4
ffffffffc0202afc:	4afc1463          	bne	s8,a5,ffffffffc0202fa4 <swap_init+0x64a>

     cprintf("set up init env for check_swap begin!\n");
ffffffffc0202b00:	00003517          	auipc	a0,0x3
ffffffffc0202b04:	f2850513          	addi	a0,a0,-216 # ffffffffc0205a28 <default_pmm_manager+0x818>
ffffffffc0202b08:	db2fd0ef          	jal	ra,ffffffffc02000ba <cprintf>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0202b0c:	6605                	lui	a2,0x1
     // setup initial vir_page<->phy_page environment for page relpacement algorithm

     pgfault_num = 0;
ffffffffc0202b0e:	0000f797          	auipc	a5,0xf
ffffffffc0202b12:	a407ad23          	sw	zero,-1446(a5) # ffffffffc0211568 <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0202b16:	4529                	li	a0,10
ffffffffc0202b18:	00a60023          	sb	a0,0(a2) # 1000 <kern_entry-0xffffffffc01ff000>
     assert(pgfault_num == 1);
ffffffffc0202b1c:	0000f597          	auipc	a1,0xf
ffffffffc0202b20:	a4c5a583          	lw	a1,-1460(a1) # ffffffffc0211568 <pgfault_num>
ffffffffc0202b24:	4805                	li	a6,1
ffffffffc0202b26:	0000f797          	auipc	a5,0xf
ffffffffc0202b2a:	a4278793          	addi	a5,a5,-1470 # ffffffffc0211568 <pgfault_num>
ffffffffc0202b2e:	3f059b63          	bne	a1,a6,ffffffffc0202f24 <swap_init+0x5ca>
     *(unsigned char *)0x1010 = 0x0a;
ffffffffc0202b32:	00a60823          	sb	a0,16(a2)
     assert(pgfault_num == 1);
ffffffffc0202b36:	4390                	lw	a2,0(a5)
ffffffffc0202b38:	2601                	sext.w	a2,a2
ffffffffc0202b3a:	40b61563          	bne	a2,a1,ffffffffc0202f44 <swap_init+0x5ea>
     *(unsigned char *)0x2000 = 0x0b;
ffffffffc0202b3e:	6589                	lui	a1,0x2
ffffffffc0202b40:	452d                	li	a0,11
ffffffffc0202b42:	00a58023          	sb	a0,0(a1) # 2000 <kern_entry-0xffffffffc01fe000>
     assert(pgfault_num == 2);
ffffffffc0202b46:	4390                	lw	a2,0(a5)
ffffffffc0202b48:	4809                	li	a6,2
ffffffffc0202b4a:	2601                	sext.w	a2,a2
ffffffffc0202b4c:	35061c63          	bne	a2,a6,ffffffffc0202ea4 <swap_init+0x54a>
     *(unsigned char *)0x2010 = 0x0b;
ffffffffc0202b50:	00a58823          	sb	a0,16(a1)
     assert(pgfault_num == 2);
ffffffffc0202b54:	438c                	lw	a1,0(a5)
ffffffffc0202b56:	2581                	sext.w	a1,a1
ffffffffc0202b58:	36c59663          	bne	a1,a2,ffffffffc0202ec4 <swap_init+0x56a>
     *(unsigned char *)0x3000 = 0x0c;
ffffffffc0202b5c:	658d                	lui	a1,0x3
ffffffffc0202b5e:	4531                	li	a0,12
ffffffffc0202b60:	00a58023          	sb	a0,0(a1) # 3000 <kern_entry-0xffffffffc01fd000>
     assert(pgfault_num == 3);
ffffffffc0202b64:	4390                	lw	a2,0(a5)
ffffffffc0202b66:	480d                	li	a6,3
ffffffffc0202b68:	2601                	sext.w	a2,a2
ffffffffc0202b6a:	37061d63          	bne	a2,a6,ffffffffc0202ee4 <swap_init+0x58a>
     *(unsigned char *)0x3010 = 0x0c;
ffffffffc0202b6e:	00a58823          	sb	a0,16(a1)
     assert(pgfault_num == 3);
ffffffffc0202b72:	438c                	lw	a1,0(a5)
ffffffffc0202b74:	2581                	sext.w	a1,a1
ffffffffc0202b76:	38c59763          	bne	a1,a2,ffffffffc0202f04 <swap_init+0x5aa>
     *(unsigned char *)0x4000 = 0x0d;
ffffffffc0202b7a:	6591                	lui	a1,0x4
ffffffffc0202b7c:	4535                	li	a0,13
ffffffffc0202b7e:	00a58023          	sb	a0,0(a1) # 4000 <kern_entry-0xffffffffc01fc000>
     assert(pgfault_num == 4);
ffffffffc0202b82:	4390                	lw	a2,0(a5)
ffffffffc0202b84:	2601                	sext.w	a2,a2
ffffffffc0202b86:	21861f63          	bne	a2,s8,ffffffffc0202da4 <swap_init+0x44a>
     *(unsigned char *)0x4010 = 0x0d;
ffffffffc0202b8a:	00a58823          	sb	a0,16(a1)
     assert(pgfault_num == 4);
ffffffffc0202b8e:	439c                	lw	a5,0(a5)
ffffffffc0202b90:	2781                	sext.w	a5,a5
ffffffffc0202b92:	22c79963          	bne	a5,a2,ffffffffc0202dc4 <swap_init+0x46a>

     check_content_set();
     assert(nr_free == 0);
ffffffffc0202b96:	489c                	lw	a5,16(s1)
ffffffffc0202b98:	24079663          	bnez	a5,ffffffffc0202de4 <swap_init+0x48a>
ffffffffc0202b9c:	0000e797          	auipc	a5,0xe
ffffffffc0202ba0:	4fc78793          	addi	a5,a5,1276 # ffffffffc0211098 <swap_in_seq_no>
ffffffffc0202ba4:	0000e617          	auipc	a2,0xe
ffffffffc0202ba8:	51c60613          	addi	a2,a2,1308 # ffffffffc02110c0 <swap_out_seq_no>
ffffffffc0202bac:	0000e517          	auipc	a0,0xe
ffffffffc0202bb0:	51450513          	addi	a0,a0,1300 # ffffffffc02110c0 <swap_out_seq_no>
     for (i = 0; i < MAX_SEQ_NO; i++)
          swap_out_seq_no[i] = swap_in_seq_no[i] = -1;
ffffffffc0202bb4:	55fd                	li	a1,-1
ffffffffc0202bb6:	c38c                	sw	a1,0(a5)
ffffffffc0202bb8:	c20c                	sw	a1,0(a2)
     for (i = 0; i < MAX_SEQ_NO; i++)
ffffffffc0202bba:	0791                	addi	a5,a5,4
ffffffffc0202bbc:	0611                	addi	a2,a2,4
ffffffffc0202bbe:	fef51ce3          	bne	a0,a5,ffffffffc0202bb6 <swap_init+0x25c>
ffffffffc0202bc2:	0000e817          	auipc	a6,0xe
ffffffffc0202bc6:	49680813          	addi	a6,a6,1174 # ffffffffc0211058 <check_ptep>
ffffffffc0202bca:	0000e897          	auipc	a7,0xe
ffffffffc0202bce:	4ae88893          	addi	a7,a7,1198 # ffffffffc0211078 <check_rp>
ffffffffc0202bd2:	6585                	lui	a1,0x1
    return &pages[PPN(pa) - nbase];
ffffffffc0202bd4:	0000fc97          	auipc	s9,0xf
ffffffffc0202bd8:	95cc8c93          	addi	s9,s9,-1700 # ffffffffc0211530 <pages>
ffffffffc0202bdc:	00004c17          	auipc	s8,0x4
ffffffffc0202be0:	844c0c13          	addi	s8,s8,-1980 # ffffffffc0206420 <nbase>

     for (i = 0; i < CHECK_VALID_PHY_PAGE_NUM; i++)
     {
          check_ptep[i] = 0;
ffffffffc0202be4:	00083023          	sd	zero,0(a6)
          check_ptep[i] = get_pte(pgdir, (i + 1) * 0x1000, 0);
ffffffffc0202be8:	4601                	li	a2,0
ffffffffc0202bea:	855e                	mv	a0,s7
ffffffffc0202bec:	ec46                	sd	a7,24(sp)
ffffffffc0202bee:	e82e                	sd	a1,16(sp)
          check_ptep[i] = 0;
ffffffffc0202bf0:	e442                	sd	a6,8(sp)
          check_ptep[i] = get_pte(pgdir, (i + 1) * 0x1000, 0);
ffffffffc0202bf2:	b1bfe0ef          	jal	ra,ffffffffc020170c <get_pte>
ffffffffc0202bf6:	6822                	ld	a6,8(sp)
          // cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
          assert(check_ptep[i] != NULL);
ffffffffc0202bf8:	65c2                	ld	a1,16(sp)
ffffffffc0202bfa:	68e2                	ld	a7,24(sp)
          check_ptep[i] = get_pte(pgdir, (i + 1) * 0x1000, 0);
ffffffffc0202bfc:	00a83023          	sd	a0,0(a6)
          assert(check_ptep[i] != NULL);
ffffffffc0202c00:	0000f317          	auipc	t1,0xf
ffffffffc0202c04:	92830313          	addi	t1,t1,-1752 # ffffffffc0211528 <npage>
ffffffffc0202c08:	16050e63          	beqz	a0,ffffffffc0202d84 <swap_init+0x42a>
          assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0202c0c:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0202c0e:	0017f613          	andi	a2,a5,1
ffffffffc0202c12:	0e060563          	beqz	a2,ffffffffc0202cfc <swap_init+0x3a2>
    if (PPN(pa) >= npage) {
ffffffffc0202c16:	00033603          	ld	a2,0(t1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202c1a:	078a                	slli	a5,a5,0x2
ffffffffc0202c1c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202c1e:	0ec7fb63          	bgeu	a5,a2,ffffffffc0202d14 <swap_init+0x3ba>
    return &pages[PPN(pa) - nbase];
ffffffffc0202c22:	000c3603          	ld	a2,0(s8)
ffffffffc0202c26:	000cb503          	ld	a0,0(s9)
ffffffffc0202c2a:	0008bf03          	ld	t5,0(a7)
ffffffffc0202c2e:	8f91                	sub	a5,a5,a2
ffffffffc0202c30:	00379613          	slli	a2,a5,0x3
ffffffffc0202c34:	97b2                	add	a5,a5,a2
ffffffffc0202c36:	078e                	slli	a5,a5,0x3
ffffffffc0202c38:	97aa                	add	a5,a5,a0
ffffffffc0202c3a:	0aff1163          	bne	t5,a5,ffffffffc0202cdc <swap_init+0x382>
     for (i = 0; i < CHECK_VALID_PHY_PAGE_NUM; i++)
ffffffffc0202c3e:	6785                	lui	a5,0x1
ffffffffc0202c40:	95be                	add	a1,a1,a5
ffffffffc0202c42:	6795                	lui	a5,0x5
ffffffffc0202c44:	0821                	addi	a6,a6,8
ffffffffc0202c46:	08a1                	addi	a7,a7,8
ffffffffc0202c48:	f8f59ee3          	bne	a1,a5,ffffffffc0202be4 <swap_init+0x28a>
          assert((*check_ptep[i] & PTE_V));
     }
     cprintf("set up init env for check_swap over!\n");
ffffffffc0202c4c:	00003517          	auipc	a0,0x3
ffffffffc0202c50:	ea450513          	addi	a0,a0,-348 # ffffffffc0205af0 <default_pmm_manager+0x8e0>
ffffffffc0202c54:	c66fd0ef          	jal	ra,ffffffffc02000ba <cprintf>
     int ret = sm->check_swap();
ffffffffc0202c58:	000b3783          	ld	a5,0(s6)
ffffffffc0202c5c:	7f9c                	ld	a5,56(a5)
ffffffffc0202c5e:	9782                	jalr	a5
     // now access the virt pages to test  page relpacement algorithm
     ret = check_content_access();
     assert(ret == 0);
ffffffffc0202c60:	1a051263          	bnez	a0,ffffffffc0202e04 <swap_init+0x4aa>

     // restore kernel mem env
     for (i = 0; i < CHECK_VALID_PHY_PAGE_NUM; i++)
     {
          free_pages(check_rp[i], 1);
ffffffffc0202c64:	00093503          	ld	a0,0(s2)
ffffffffc0202c68:	4585                	li	a1,1
     for (i = 0; i < CHECK_VALID_PHY_PAGE_NUM; i++)
ffffffffc0202c6a:	0921                	addi	s2,s2,8
          free_pages(check_rp[i], 1);
ffffffffc0202c6c:	a27fe0ef          	jal	ra,ffffffffc0201692 <free_pages>
     for (i = 0; i < CHECK_VALID_PHY_PAGE_NUM; i++)
ffffffffc0202c70:	ff491ae3          	bne	s2,s4,ffffffffc0202c64 <swap_init+0x30a>
     }

     // free_page(pte2page(*temp_ptep));

     mm_destroy(mm);
ffffffffc0202c74:	8556                	mv	a0,s5
ffffffffc0202c76:	29d000ef          	jal	ra,ffffffffc0203712 <mm_destroy>

     nr_free = nr_free_store;
ffffffffc0202c7a:	77a2                	ld	a5,40(sp)
     free_list = free_list_store;
ffffffffc0202c7c:	01b4b423          	sd	s11,8(s1)
     nr_free = nr_free_store;
ffffffffc0202c80:	c89c                	sw	a5,16(s1)
     free_list = free_list_store;
ffffffffc0202c82:	7782                	ld	a5,32(sp)
ffffffffc0202c84:	e09c                	sd	a5,0(s1)

     le = &free_list;
     while ((le = list_next(le)) != &free_list)
ffffffffc0202c86:	009d8a63          	beq	s11,s1,ffffffffc0202c9a <swap_init+0x340>
     {
          struct Page *p = le2page(le, page_link);
          count--, total -= p->property;
ffffffffc0202c8a:	ff8da783          	lw	a5,-8(s11)
    return listelm->next;
ffffffffc0202c8e:	008dbd83          	ld	s11,8(s11)
ffffffffc0202c92:	3d7d                	addiw	s10,s10,-1
ffffffffc0202c94:	9c1d                	subw	s0,s0,a5
     while ((le = list_next(le)) != &free_list)
ffffffffc0202c96:	fe9d9ae3          	bne	s11,s1,ffffffffc0202c8a <swap_init+0x330>
     }
     cprintf("count is %d, total is %d\n", count, total);
ffffffffc0202c9a:	8622                	mv	a2,s0
ffffffffc0202c9c:	85ea                	mv	a1,s10
ffffffffc0202c9e:	00003517          	auipc	a0,0x3
ffffffffc0202ca2:	e8a50513          	addi	a0,a0,-374 # ffffffffc0205b28 <default_pmm_manager+0x918>
ffffffffc0202ca6:	c14fd0ef          	jal	ra,ffffffffc02000ba <cprintf>
     // assert(count == 0);

     cprintf("check_swap() succeeded!\n");
ffffffffc0202caa:	00003517          	auipc	a0,0x3
ffffffffc0202cae:	e9e50513          	addi	a0,a0,-354 # ffffffffc0205b48 <default_pmm_manager+0x938>
ffffffffc0202cb2:	c08fd0ef          	jal	ra,ffffffffc02000ba <cprintf>
}
ffffffffc0202cb6:	b9dd                	j	ffffffffc02029ac <swap_init+0x52>
     while ((le = list_next(le)) != &free_list)
ffffffffc0202cb8:	4901                	li	s2,0
ffffffffc0202cba:	bba9                	j	ffffffffc0202a14 <swap_init+0xba>
          assert(PageProperty(p));
ffffffffc0202cbc:	00002697          	auipc	a3,0x2
ffffffffc0202cc0:	19468693          	addi	a3,a3,404 # ffffffffc0204e50 <commands+0x750>
ffffffffc0202cc4:	00002617          	auipc	a2,0x2
ffffffffc0202cc8:	19c60613          	addi	a2,a2,412 # ffffffffc0204e60 <commands+0x760>
ffffffffc0202ccc:	0b600593          	li	a1,182
ffffffffc0202cd0:	00003517          	auipc	a0,0x3
ffffffffc0202cd4:	be850513          	addi	a0,a0,-1048 # ffffffffc02058b8 <default_pmm_manager+0x6a8>
ffffffffc0202cd8:	e9cfd0ef          	jal	ra,ffffffffc0200374 <__panic>
          assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0202cdc:	00003697          	auipc	a3,0x3
ffffffffc0202ce0:	dec68693          	addi	a3,a3,-532 # ffffffffc0205ac8 <default_pmm_manager+0x8b8>
ffffffffc0202ce4:	00002617          	auipc	a2,0x2
ffffffffc0202ce8:	17c60613          	addi	a2,a2,380 # ffffffffc0204e60 <commands+0x760>
ffffffffc0202cec:	0f800593          	li	a1,248
ffffffffc0202cf0:	00003517          	auipc	a0,0x3
ffffffffc0202cf4:	bc850513          	addi	a0,a0,-1080 # ffffffffc02058b8 <default_pmm_manager+0x6a8>
ffffffffc0202cf8:	e7cfd0ef          	jal	ra,ffffffffc0200374 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0202cfc:	00002617          	auipc	a2,0x2
ffffffffc0202d00:	57c60613          	addi	a2,a2,1404 # ffffffffc0205278 <default_pmm_manager+0x68>
ffffffffc0202d04:	07000593          	li	a1,112
ffffffffc0202d08:	00002517          	auipc	a0,0x2
ffffffffc0202d0c:	56050513          	addi	a0,a0,1376 # ffffffffc0205268 <default_pmm_manager+0x58>
ffffffffc0202d10:	e64fd0ef          	jal	ra,ffffffffc0200374 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0202d14:	00002617          	auipc	a2,0x2
ffffffffc0202d18:	53460613          	addi	a2,a2,1332 # ffffffffc0205248 <default_pmm_manager+0x38>
ffffffffc0202d1c:	06500593          	li	a1,101
ffffffffc0202d20:	00002517          	auipc	a0,0x2
ffffffffc0202d24:	54850513          	addi	a0,a0,1352 # ffffffffc0205268 <default_pmm_manager+0x58>
ffffffffc0202d28:	e4cfd0ef          	jal	ra,ffffffffc0200374 <__panic>
          assert(!PageProperty(check_rp[i]));
ffffffffc0202d2c:	00003697          	auipc	a3,0x3
ffffffffc0202d30:	cb468693          	addi	a3,a3,-844 # ffffffffc02059e0 <default_pmm_manager+0x7d0>
ffffffffc0202d34:	00002617          	auipc	a2,0x2
ffffffffc0202d38:	12c60613          	addi	a2,a2,300 # ffffffffc0204e60 <commands+0x760>
ffffffffc0202d3c:	0d800593          	li	a1,216
ffffffffc0202d40:	00003517          	auipc	a0,0x3
ffffffffc0202d44:	b7850513          	addi	a0,a0,-1160 # ffffffffc02058b8 <default_pmm_manager+0x6a8>
ffffffffc0202d48:	e2cfd0ef          	jal	ra,ffffffffc0200374 <__panic>
          assert(check_rp[i] != NULL);
ffffffffc0202d4c:	00003697          	auipc	a3,0x3
ffffffffc0202d50:	c7c68693          	addi	a3,a3,-900 # ffffffffc02059c8 <default_pmm_manager+0x7b8>
ffffffffc0202d54:	00002617          	auipc	a2,0x2
ffffffffc0202d58:	10c60613          	addi	a2,a2,268 # ffffffffc0204e60 <commands+0x760>
ffffffffc0202d5c:	0d700593          	li	a1,215
ffffffffc0202d60:	00003517          	auipc	a0,0x3
ffffffffc0202d64:	b5850513          	addi	a0,a0,-1192 # ffffffffc02058b8 <default_pmm_manager+0x6a8>
ffffffffc0202d68:	e0cfd0ef          	jal	ra,ffffffffc0200374 <__panic>
          panic("bad max_swap_offset %08x.\n", max_swap_offset);
ffffffffc0202d6c:	00003617          	auipc	a2,0x3
ffffffffc0202d70:	b2c60613          	addi	a2,a2,-1236 # ffffffffc0205898 <default_pmm_manager+0x688>
ffffffffc0202d74:	02700593          	li	a1,39
ffffffffc0202d78:	00003517          	auipc	a0,0x3
ffffffffc0202d7c:	b4050513          	addi	a0,a0,-1216 # ffffffffc02058b8 <default_pmm_manager+0x6a8>
ffffffffc0202d80:	df4fd0ef          	jal	ra,ffffffffc0200374 <__panic>
          assert(check_ptep[i] != NULL);
ffffffffc0202d84:	00003697          	auipc	a3,0x3
ffffffffc0202d88:	d2c68693          	addi	a3,a3,-724 # ffffffffc0205ab0 <default_pmm_manager+0x8a0>
ffffffffc0202d8c:	00002617          	auipc	a2,0x2
ffffffffc0202d90:	0d460613          	addi	a2,a2,212 # ffffffffc0204e60 <commands+0x760>
ffffffffc0202d94:	0f700593          	li	a1,247
ffffffffc0202d98:	00003517          	auipc	a0,0x3
ffffffffc0202d9c:	b2050513          	addi	a0,a0,-1248 # ffffffffc02058b8 <default_pmm_manager+0x6a8>
ffffffffc0202da0:	dd4fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgfault_num == 4);
ffffffffc0202da4:	00003697          	auipc	a3,0x3
ffffffffc0202da8:	cf468693          	addi	a3,a3,-780 # ffffffffc0205a98 <default_pmm_manager+0x888>
ffffffffc0202dac:	00002617          	auipc	a2,0x2
ffffffffc0202db0:	0b460613          	addi	a2,a2,180 # ffffffffc0204e60 <commands+0x760>
ffffffffc0202db4:	09800593          	li	a1,152
ffffffffc0202db8:	00003517          	auipc	a0,0x3
ffffffffc0202dbc:	b0050513          	addi	a0,a0,-1280 # ffffffffc02058b8 <default_pmm_manager+0x6a8>
ffffffffc0202dc0:	db4fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgfault_num == 4);
ffffffffc0202dc4:	00003697          	auipc	a3,0x3
ffffffffc0202dc8:	cd468693          	addi	a3,a3,-812 # ffffffffc0205a98 <default_pmm_manager+0x888>
ffffffffc0202dcc:	00002617          	auipc	a2,0x2
ffffffffc0202dd0:	09460613          	addi	a2,a2,148 # ffffffffc0204e60 <commands+0x760>
ffffffffc0202dd4:	09a00593          	li	a1,154
ffffffffc0202dd8:	00003517          	auipc	a0,0x3
ffffffffc0202ddc:	ae050513          	addi	a0,a0,-1312 # ffffffffc02058b8 <default_pmm_manager+0x6a8>
ffffffffc0202de0:	d94fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(nr_free == 0);
ffffffffc0202de4:	00002697          	auipc	a3,0x2
ffffffffc0202de8:	25468693          	addi	a3,a3,596 # ffffffffc0205038 <commands+0x938>
ffffffffc0202dec:	00002617          	auipc	a2,0x2
ffffffffc0202df0:	07460613          	addi	a2,a2,116 # ffffffffc0204e60 <commands+0x760>
ffffffffc0202df4:	0ee00593          	li	a1,238
ffffffffc0202df8:	00003517          	auipc	a0,0x3
ffffffffc0202dfc:	ac050513          	addi	a0,a0,-1344 # ffffffffc02058b8 <default_pmm_manager+0x6a8>
ffffffffc0202e00:	d74fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(ret == 0);
ffffffffc0202e04:	00003697          	auipc	a3,0x3
ffffffffc0202e08:	d1468693          	addi	a3,a3,-748 # ffffffffc0205b18 <default_pmm_manager+0x908>
ffffffffc0202e0c:	00002617          	auipc	a2,0x2
ffffffffc0202e10:	05460613          	addi	a2,a2,84 # ffffffffc0204e60 <commands+0x760>
ffffffffc0202e14:	0fe00593          	li	a1,254
ffffffffc0202e18:	00003517          	auipc	a0,0x3
ffffffffc0202e1c:	aa050513          	addi	a0,a0,-1376 # ffffffffc02058b8 <default_pmm_manager+0x6a8>
ffffffffc0202e20:	d54fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgdir[0] == 0);
ffffffffc0202e24:	00003697          	auipc	a3,0x3
ffffffffc0202e28:	b0c68693          	addi	a3,a3,-1268 # ffffffffc0205930 <default_pmm_manager+0x720>
ffffffffc0202e2c:	00002617          	auipc	a2,0x2
ffffffffc0202e30:	03460613          	addi	a2,a2,52 # ffffffffc0204e60 <commands+0x760>
ffffffffc0202e34:	0c600593          	li	a1,198
ffffffffc0202e38:	00003517          	auipc	a0,0x3
ffffffffc0202e3c:	a8050513          	addi	a0,a0,-1408 # ffffffffc02058b8 <default_pmm_manager+0x6a8>
ffffffffc0202e40:	d34fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(vma != NULL);
ffffffffc0202e44:	00003697          	auipc	a3,0x3
ffffffffc0202e48:	afc68693          	addi	a3,a3,-1284 # ffffffffc0205940 <default_pmm_manager+0x730>
ffffffffc0202e4c:	00002617          	auipc	a2,0x2
ffffffffc0202e50:	01460613          	addi	a2,a2,20 # ffffffffc0204e60 <commands+0x760>
ffffffffc0202e54:	0c900593          	li	a1,201
ffffffffc0202e58:	00003517          	auipc	a0,0x3
ffffffffc0202e5c:	a6050513          	addi	a0,a0,-1440 # ffffffffc02058b8 <default_pmm_manager+0x6a8>
ffffffffc0202e60:	d14fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(temp_ptep != NULL);
ffffffffc0202e64:	00003697          	auipc	a3,0x3
ffffffffc0202e68:	b2468693          	addi	a3,a3,-1244 # ffffffffc0205988 <default_pmm_manager+0x778>
ffffffffc0202e6c:	00002617          	auipc	a2,0x2
ffffffffc0202e70:	ff460613          	addi	a2,a2,-12 # ffffffffc0204e60 <commands+0x760>
ffffffffc0202e74:	0d100593          	li	a1,209
ffffffffc0202e78:	00003517          	auipc	a0,0x3
ffffffffc0202e7c:	a4050513          	addi	a0,a0,-1472 # ffffffffc02058b8 <default_pmm_manager+0x6a8>
ffffffffc0202e80:	cf4fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(total == nr_free_pages());
ffffffffc0202e84:	00002697          	auipc	a3,0x2
ffffffffc0202e88:	00c68693          	addi	a3,a3,12 # ffffffffc0204e90 <commands+0x790>
ffffffffc0202e8c:	00002617          	auipc	a2,0x2
ffffffffc0202e90:	fd460613          	addi	a2,a2,-44 # ffffffffc0204e60 <commands+0x760>
ffffffffc0202e94:	0b900593          	li	a1,185
ffffffffc0202e98:	00003517          	auipc	a0,0x3
ffffffffc0202e9c:	a2050513          	addi	a0,a0,-1504 # ffffffffc02058b8 <default_pmm_manager+0x6a8>
ffffffffc0202ea0:	cd4fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgfault_num == 2);
ffffffffc0202ea4:	00003697          	auipc	a3,0x3
ffffffffc0202ea8:	bc468693          	addi	a3,a3,-1084 # ffffffffc0205a68 <default_pmm_manager+0x858>
ffffffffc0202eac:	00002617          	auipc	a2,0x2
ffffffffc0202eb0:	fb460613          	addi	a2,a2,-76 # ffffffffc0204e60 <commands+0x760>
ffffffffc0202eb4:	09000593          	li	a1,144
ffffffffc0202eb8:	00003517          	auipc	a0,0x3
ffffffffc0202ebc:	a0050513          	addi	a0,a0,-1536 # ffffffffc02058b8 <default_pmm_manager+0x6a8>
ffffffffc0202ec0:	cb4fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgfault_num == 2);
ffffffffc0202ec4:	00003697          	auipc	a3,0x3
ffffffffc0202ec8:	ba468693          	addi	a3,a3,-1116 # ffffffffc0205a68 <default_pmm_manager+0x858>
ffffffffc0202ecc:	00002617          	auipc	a2,0x2
ffffffffc0202ed0:	f9460613          	addi	a2,a2,-108 # ffffffffc0204e60 <commands+0x760>
ffffffffc0202ed4:	09200593          	li	a1,146
ffffffffc0202ed8:	00003517          	auipc	a0,0x3
ffffffffc0202edc:	9e050513          	addi	a0,a0,-1568 # ffffffffc02058b8 <default_pmm_manager+0x6a8>
ffffffffc0202ee0:	c94fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgfault_num == 3);
ffffffffc0202ee4:	00003697          	auipc	a3,0x3
ffffffffc0202ee8:	b9c68693          	addi	a3,a3,-1124 # ffffffffc0205a80 <default_pmm_manager+0x870>
ffffffffc0202eec:	00002617          	auipc	a2,0x2
ffffffffc0202ef0:	f7460613          	addi	a2,a2,-140 # ffffffffc0204e60 <commands+0x760>
ffffffffc0202ef4:	09400593          	li	a1,148
ffffffffc0202ef8:	00003517          	auipc	a0,0x3
ffffffffc0202efc:	9c050513          	addi	a0,a0,-1600 # ffffffffc02058b8 <default_pmm_manager+0x6a8>
ffffffffc0202f00:	c74fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgfault_num == 3);
ffffffffc0202f04:	00003697          	auipc	a3,0x3
ffffffffc0202f08:	b7c68693          	addi	a3,a3,-1156 # ffffffffc0205a80 <default_pmm_manager+0x870>
ffffffffc0202f0c:	00002617          	auipc	a2,0x2
ffffffffc0202f10:	f5460613          	addi	a2,a2,-172 # ffffffffc0204e60 <commands+0x760>
ffffffffc0202f14:	09600593          	li	a1,150
ffffffffc0202f18:	00003517          	auipc	a0,0x3
ffffffffc0202f1c:	9a050513          	addi	a0,a0,-1632 # ffffffffc02058b8 <default_pmm_manager+0x6a8>
ffffffffc0202f20:	c54fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgfault_num == 1);
ffffffffc0202f24:	00003697          	auipc	a3,0x3
ffffffffc0202f28:	b2c68693          	addi	a3,a3,-1236 # ffffffffc0205a50 <default_pmm_manager+0x840>
ffffffffc0202f2c:	00002617          	auipc	a2,0x2
ffffffffc0202f30:	f3460613          	addi	a2,a2,-204 # ffffffffc0204e60 <commands+0x760>
ffffffffc0202f34:	08c00593          	li	a1,140
ffffffffc0202f38:	00003517          	auipc	a0,0x3
ffffffffc0202f3c:	98050513          	addi	a0,a0,-1664 # ffffffffc02058b8 <default_pmm_manager+0x6a8>
ffffffffc0202f40:	c34fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgfault_num == 1);
ffffffffc0202f44:	00003697          	auipc	a3,0x3
ffffffffc0202f48:	b0c68693          	addi	a3,a3,-1268 # ffffffffc0205a50 <default_pmm_manager+0x840>
ffffffffc0202f4c:	00002617          	auipc	a2,0x2
ffffffffc0202f50:	f1460613          	addi	a2,a2,-236 # ffffffffc0204e60 <commands+0x760>
ffffffffc0202f54:	08e00593          	li	a1,142
ffffffffc0202f58:	00003517          	auipc	a0,0x3
ffffffffc0202f5c:	96050513          	addi	a0,a0,-1696 # ffffffffc02058b8 <default_pmm_manager+0x6a8>
ffffffffc0202f60:	c14fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(mm != NULL);
ffffffffc0202f64:	00003697          	auipc	a3,0x3
ffffffffc0202f68:	9a468693          	addi	a3,a3,-1628 # ffffffffc0205908 <default_pmm_manager+0x6f8>
ffffffffc0202f6c:	00002617          	auipc	a2,0x2
ffffffffc0202f70:	ef460613          	addi	a2,a2,-268 # ffffffffc0204e60 <commands+0x760>
ffffffffc0202f74:	0be00593          	li	a1,190
ffffffffc0202f78:	00003517          	auipc	a0,0x3
ffffffffc0202f7c:	94050513          	addi	a0,a0,-1728 # ffffffffc02058b8 <default_pmm_manager+0x6a8>
ffffffffc0202f80:	bf4fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(check_mm_struct == NULL);
ffffffffc0202f84:	00003697          	auipc	a3,0x3
ffffffffc0202f88:	99468693          	addi	a3,a3,-1644 # ffffffffc0205918 <default_pmm_manager+0x708>
ffffffffc0202f8c:	00002617          	auipc	a2,0x2
ffffffffc0202f90:	ed460613          	addi	a2,a2,-300 # ffffffffc0204e60 <commands+0x760>
ffffffffc0202f94:	0c100593          	li	a1,193
ffffffffc0202f98:	00003517          	auipc	a0,0x3
ffffffffc0202f9c:	92050513          	addi	a0,a0,-1760 # ffffffffc02058b8 <default_pmm_manager+0x6a8>
ffffffffc0202fa0:	bd4fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(nr_free == CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0202fa4:	00003697          	auipc	a3,0x3
ffffffffc0202fa8:	a5c68693          	addi	a3,a3,-1444 # ffffffffc0205a00 <default_pmm_manager+0x7f0>
ffffffffc0202fac:	00002617          	auipc	a2,0x2
ffffffffc0202fb0:	eb460613          	addi	a2,a2,-332 # ffffffffc0204e60 <commands+0x760>
ffffffffc0202fb4:	0e600593          	li	a1,230
ffffffffc0202fb8:	00003517          	auipc	a0,0x3
ffffffffc0202fbc:	90050513          	addi	a0,a0,-1792 # ffffffffc02058b8 <default_pmm_manager+0x6a8>
ffffffffc0202fc0:	bb4fd0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0202fc4 <swap_init_mm>:
     return sm->init_mm(mm);
ffffffffc0202fc4:	0000e797          	auipc	a5,0xe
ffffffffc0202fc8:	58c7b783          	ld	a5,1420(a5) # ffffffffc0211550 <sm>
ffffffffc0202fcc:	6b9c                	ld	a5,16(a5)
ffffffffc0202fce:	8782                	jr	a5

ffffffffc0202fd0 <swap_map_swappable>:
     return sm->map_swappable(mm, addr, page, swap_in);
ffffffffc0202fd0:	0000e797          	auipc	a5,0xe
ffffffffc0202fd4:	5807b783          	ld	a5,1408(a5) # ffffffffc0211550 <sm>
ffffffffc0202fd8:	739c                	ld	a5,32(a5)
ffffffffc0202fda:	8782                	jr	a5

ffffffffc0202fdc <swap_out>:
{
ffffffffc0202fdc:	711d                	addi	sp,sp,-96
ffffffffc0202fde:	ec86                	sd	ra,88(sp)
ffffffffc0202fe0:	e8a2                	sd	s0,80(sp)
ffffffffc0202fe2:	e4a6                	sd	s1,72(sp)
ffffffffc0202fe4:	e0ca                	sd	s2,64(sp)
ffffffffc0202fe6:	fc4e                	sd	s3,56(sp)
ffffffffc0202fe8:	f852                	sd	s4,48(sp)
ffffffffc0202fea:	f456                	sd	s5,40(sp)
ffffffffc0202fec:	f05a                	sd	s6,32(sp)
ffffffffc0202fee:	ec5e                	sd	s7,24(sp)
ffffffffc0202ff0:	e862                	sd	s8,16(sp)
     for (i = 0; i != n; ++i)
ffffffffc0202ff2:	cde9                	beqz	a1,ffffffffc02030cc <swap_out+0xf0>
ffffffffc0202ff4:	8a2e                	mv	s4,a1
ffffffffc0202ff6:	892a                	mv	s2,a0
ffffffffc0202ff8:	8ab2                	mv	s5,a2
ffffffffc0202ffa:	4401                	li	s0,0
ffffffffc0202ffc:	0000e997          	auipc	s3,0xe
ffffffffc0203000:	55498993          	addi	s3,s3,1364 # ffffffffc0211550 <sm>
               cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr / PGSIZE + 1);
ffffffffc0203004:	00003b17          	auipc	s6,0x3
ffffffffc0203008:	bc4b0b13          	addi	s6,s6,-1084 # ffffffffc0205bc8 <default_pmm_manager+0x9b8>
               cprintf("SWAP: failed to save\n");
ffffffffc020300c:	00003b97          	auipc	s7,0x3
ffffffffc0203010:	ba4b8b93          	addi	s7,s7,-1116 # ffffffffc0205bb0 <default_pmm_manager+0x9a0>
ffffffffc0203014:	a825                	j	ffffffffc020304c <swap_out+0x70>
               cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr / PGSIZE + 1);
ffffffffc0203016:	67a2                	ld	a5,8(sp)
ffffffffc0203018:	8626                	mv	a2,s1
ffffffffc020301a:	85a2                	mv	a1,s0
ffffffffc020301c:	63b4                	ld	a3,64(a5)
ffffffffc020301e:	855a                	mv	a0,s6
     for (i = 0; i != n; ++i)
ffffffffc0203020:	2405                	addiw	s0,s0,1
               cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr / PGSIZE + 1);
ffffffffc0203022:	82b1                	srli	a3,a3,0xc
ffffffffc0203024:	0685                	addi	a3,a3,1
ffffffffc0203026:	894fd0ef          	jal	ra,ffffffffc02000ba <cprintf>
               *ptep = (page->pra_vaddr / PGSIZE + 1) << 8;
ffffffffc020302a:	6522                	ld	a0,8(sp)
               free_page(page);
ffffffffc020302c:	4585                	li	a1,1
               *ptep = (page->pra_vaddr / PGSIZE + 1) << 8;
ffffffffc020302e:	613c                	ld	a5,64(a0)
ffffffffc0203030:	83b1                	srli	a5,a5,0xc
ffffffffc0203032:	0785                	addi	a5,a5,1
ffffffffc0203034:	07a2                	slli	a5,a5,0x8
ffffffffc0203036:	00fc3023          	sd	a5,0(s8)
               free_page(page);
ffffffffc020303a:	e58fe0ef          	jal	ra,ffffffffc0201692 <free_pages>
          tlb_invalidate(mm->pgdir, v);
ffffffffc020303e:	01893503          	ld	a0,24(s2)
ffffffffc0203042:	85a6                	mv	a1,s1
ffffffffc0203044:	eb6ff0ef          	jal	ra,ffffffffc02026fa <tlb_invalidate>
     for (i = 0; i != n; ++i)
ffffffffc0203048:	048a0d63          	beq	s4,s0,ffffffffc02030a2 <swap_out+0xc6>
          int r = sm->swap_out_victim(mm, &page, in_tick);
ffffffffc020304c:	0009b783          	ld	a5,0(s3)
ffffffffc0203050:	8656                	mv	a2,s5
ffffffffc0203052:	002c                	addi	a1,sp,8
ffffffffc0203054:	7b9c                	ld	a5,48(a5)
ffffffffc0203056:	854a                	mv	a0,s2
ffffffffc0203058:	9782                	jalr	a5
          if (r != 0)
ffffffffc020305a:	e12d                	bnez	a0,ffffffffc02030bc <swap_out+0xe0>
          v = page->pra_vaddr;
ffffffffc020305c:	67a2                	ld	a5,8(sp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc020305e:	01893503          	ld	a0,24(s2)
ffffffffc0203062:	4601                	li	a2,0
          v = page->pra_vaddr;
ffffffffc0203064:	63a4                	ld	s1,64(a5)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0203066:	85a6                	mv	a1,s1
ffffffffc0203068:	ea4fe0ef          	jal	ra,ffffffffc020170c <get_pte>
          assert((*ptep & PTE_V) != 0);
ffffffffc020306c:	611c                	ld	a5,0(a0)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc020306e:	8c2a                	mv	s8,a0
          assert((*ptep & PTE_V) != 0);
ffffffffc0203070:	8b85                	andi	a5,a5,1
ffffffffc0203072:	cfb9                	beqz	a5,ffffffffc02030d0 <swap_out+0xf4>
          if (swapfs_write((page->pra_vaddr / PGSIZE + 1) << 8, page) != 0)
ffffffffc0203074:	65a2                	ld	a1,8(sp)
ffffffffc0203076:	61bc                	ld	a5,64(a1)
ffffffffc0203078:	83b1                	srli	a5,a5,0xc
ffffffffc020307a:	0785                	addi	a5,a5,1
ffffffffc020307c:	00879513          	slli	a0,a5,0x8
ffffffffc0203080:	643000ef          	jal	ra,ffffffffc0203ec2 <swapfs_write>
ffffffffc0203084:	d949                	beqz	a0,ffffffffc0203016 <swap_out+0x3a>
               cprintf("SWAP: failed to save\n");
ffffffffc0203086:	855e                	mv	a0,s7
ffffffffc0203088:	832fd0ef          	jal	ra,ffffffffc02000ba <cprintf>
               sm->map_swappable(mm, v, page, 0);
ffffffffc020308c:	0009b783          	ld	a5,0(s3)
ffffffffc0203090:	6622                	ld	a2,8(sp)
ffffffffc0203092:	4681                	li	a3,0
ffffffffc0203094:	739c                	ld	a5,32(a5)
ffffffffc0203096:	85a6                	mv	a1,s1
ffffffffc0203098:	854a                	mv	a0,s2
     for (i = 0; i != n; ++i)
ffffffffc020309a:	2405                	addiw	s0,s0,1
               sm->map_swappable(mm, v, page, 0);
ffffffffc020309c:	9782                	jalr	a5
     for (i = 0; i != n; ++i)
ffffffffc020309e:	fa8a17e3          	bne	s4,s0,ffffffffc020304c <swap_out+0x70>
}
ffffffffc02030a2:	60e6                	ld	ra,88(sp)
ffffffffc02030a4:	8522                	mv	a0,s0
ffffffffc02030a6:	6446                	ld	s0,80(sp)
ffffffffc02030a8:	64a6                	ld	s1,72(sp)
ffffffffc02030aa:	6906                	ld	s2,64(sp)
ffffffffc02030ac:	79e2                	ld	s3,56(sp)
ffffffffc02030ae:	7a42                	ld	s4,48(sp)
ffffffffc02030b0:	7aa2                	ld	s5,40(sp)
ffffffffc02030b2:	7b02                	ld	s6,32(sp)
ffffffffc02030b4:	6be2                	ld	s7,24(sp)
ffffffffc02030b6:	6c42                	ld	s8,16(sp)
ffffffffc02030b8:	6125                	addi	sp,sp,96
ffffffffc02030ba:	8082                	ret
               cprintf("i %d, swap_out: call swap_out_victim failed\n", i);
ffffffffc02030bc:	85a2                	mv	a1,s0
ffffffffc02030be:	00003517          	auipc	a0,0x3
ffffffffc02030c2:	aaa50513          	addi	a0,a0,-1366 # ffffffffc0205b68 <default_pmm_manager+0x958>
ffffffffc02030c6:	ff5fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
               break;
ffffffffc02030ca:	bfe1                	j	ffffffffc02030a2 <swap_out+0xc6>
     for (i = 0; i != n; ++i)
ffffffffc02030cc:	4401                	li	s0,0
ffffffffc02030ce:	bfd1                	j	ffffffffc02030a2 <swap_out+0xc6>
          assert((*ptep & PTE_V) != 0);
ffffffffc02030d0:	00003697          	auipc	a3,0x3
ffffffffc02030d4:	ac868693          	addi	a3,a3,-1336 # ffffffffc0205b98 <default_pmm_manager+0x988>
ffffffffc02030d8:	00002617          	auipc	a2,0x2
ffffffffc02030dc:	d8860613          	addi	a2,a2,-632 # ffffffffc0204e60 <commands+0x760>
ffffffffc02030e0:	06200593          	li	a1,98
ffffffffc02030e4:	00002517          	auipc	a0,0x2
ffffffffc02030e8:	7d450513          	addi	a0,a0,2004 # ffffffffc02058b8 <default_pmm_manager+0x6a8>
ffffffffc02030ec:	a88fd0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc02030f0 <swap_in>:
{
ffffffffc02030f0:	7179                	addi	sp,sp,-48
ffffffffc02030f2:	e84a                	sd	s2,16(sp)
ffffffffc02030f4:	892a                	mv	s2,a0
     struct Page *result = alloc_page();
ffffffffc02030f6:	4505                	li	a0,1
{
ffffffffc02030f8:	ec26                	sd	s1,24(sp)
ffffffffc02030fa:	e44e                	sd	s3,8(sp)
ffffffffc02030fc:	f406                	sd	ra,40(sp)
ffffffffc02030fe:	f022                	sd	s0,32(sp)
ffffffffc0203100:	84ae                	mv	s1,a1
ffffffffc0203102:	89b2                	mv	s3,a2
     struct Page *result = alloc_page();
ffffffffc0203104:	cfcfe0ef          	jal	ra,ffffffffc0201600 <alloc_pages>
     assert(result != NULL);
ffffffffc0203108:	c129                	beqz	a0,ffffffffc020314a <swap_in+0x5a>
     pte_t *ptep = get_pte(mm->pgdir, addr, 0);
ffffffffc020310a:	842a                	mv	s0,a0
ffffffffc020310c:	01893503          	ld	a0,24(s2)
ffffffffc0203110:	4601                	li	a2,0
ffffffffc0203112:	85a6                	mv	a1,s1
ffffffffc0203114:	df8fe0ef          	jal	ra,ffffffffc020170c <get_pte>
ffffffffc0203118:	892a                	mv	s2,a0
     if ((r = swapfs_read((*ptep), result)) != 0)
ffffffffc020311a:	6108                	ld	a0,0(a0)
ffffffffc020311c:	85a2                	mv	a1,s0
ffffffffc020311e:	509000ef          	jal	ra,ffffffffc0203e26 <swapfs_read>
     cprintf("swap_in: load disk swap entry %d with swap_page in vadr 0x%x\n", (*ptep) >> 8, addr);
ffffffffc0203122:	00093583          	ld	a1,0(s2)
ffffffffc0203126:	8626                	mv	a2,s1
ffffffffc0203128:	00003517          	auipc	a0,0x3
ffffffffc020312c:	af050513          	addi	a0,a0,-1296 # ffffffffc0205c18 <default_pmm_manager+0xa08>
ffffffffc0203130:	81a1                	srli	a1,a1,0x8
ffffffffc0203132:	f89fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
}
ffffffffc0203136:	70a2                	ld	ra,40(sp)
     *ptr_result = result;
ffffffffc0203138:	0089b023          	sd	s0,0(s3)
}
ffffffffc020313c:	7402                	ld	s0,32(sp)
ffffffffc020313e:	64e2                	ld	s1,24(sp)
ffffffffc0203140:	6942                	ld	s2,16(sp)
ffffffffc0203142:	69a2                	ld	s3,8(sp)
ffffffffc0203144:	4501                	li	a0,0
ffffffffc0203146:	6145                	addi	sp,sp,48
ffffffffc0203148:	8082                	ret
     assert(result != NULL);
ffffffffc020314a:	00003697          	auipc	a3,0x3
ffffffffc020314e:	abe68693          	addi	a3,a3,-1346 # ffffffffc0205c08 <default_pmm_manager+0x9f8>
ffffffffc0203152:	00002617          	auipc	a2,0x2
ffffffffc0203156:	d0e60613          	addi	a2,a2,-754 # ffffffffc0204e60 <commands+0x760>
ffffffffc020315a:	07900593          	li	a1,121
ffffffffc020315e:	00002517          	auipc	a0,0x2
ffffffffc0203162:	75a50513          	addi	a0,a0,1882 # ffffffffc02058b8 <default_pmm_manager+0x6a8>
ffffffffc0203166:	a0efd0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc020316a <_fifo_init_mm>:
    elm->prev = elm->next = elm;
ffffffffc020316a:	0000e797          	auipc	a5,0xe
ffffffffc020316e:	f7e78793          	addi	a5,a5,-130 # ffffffffc02110e8 <pra_list_head_f>
 */
static int
_fifo_init_mm(struct mm_struct *mm)
{
    list_init(&pra_list_head_f);
    mm->sm_priv = &pra_list_head_f;
ffffffffc0203172:	f51c                	sd	a5,40(a0)
ffffffffc0203174:	e79c                	sd	a5,8(a5)
ffffffffc0203176:	e39c                	sd	a5,0(a5)
    // cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
    return 0;
}
ffffffffc0203178:	4501                	li	a0,0
ffffffffc020317a:	8082                	ret

ffffffffc020317c <_fifo_init>:

static int
_fifo_init(void)
{
    return 0;
}
ffffffffc020317c:	4501                	li	a0,0
ffffffffc020317e:	8082                	ret

ffffffffc0203180 <_fifo_set_unswappable>:

static int
_fifo_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
    return 0;
}
ffffffffc0203180:	4501                	li	a0,0
ffffffffc0203182:	8082                	ret

ffffffffc0203184 <_fifo_tick_event>:

static int
_fifo_tick_event(struct mm_struct *mm)
{
    return 0;
}
ffffffffc0203184:	4501                	li	a0,0
ffffffffc0203186:	8082                	ret

ffffffffc0203188 <_fifo_check_swap>:
{
ffffffffc0203188:	711d                	addi	sp,sp,-96
ffffffffc020318a:	fc4e                	sd	s3,56(sp)
ffffffffc020318c:	f852                	sd	s4,48(sp)
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc020318e:	00003517          	auipc	a0,0x3
ffffffffc0203192:	aca50513          	addi	a0,a0,-1334 # ffffffffc0205c58 <default_pmm_manager+0xa48>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0203196:	698d                	lui	s3,0x3
ffffffffc0203198:	4a31                	li	s4,12
{
ffffffffc020319a:	e0ca                	sd	s2,64(sp)
ffffffffc020319c:	ec86                	sd	ra,88(sp)
ffffffffc020319e:	e8a2                	sd	s0,80(sp)
ffffffffc02031a0:	e4a6                	sd	s1,72(sp)
ffffffffc02031a2:	f456                	sd	s5,40(sp)
ffffffffc02031a4:	f05a                	sd	s6,32(sp)
ffffffffc02031a6:	ec5e                	sd	s7,24(sp)
ffffffffc02031a8:	e862                	sd	s8,16(sp)
ffffffffc02031aa:	e466                	sd	s9,8(sp)
ffffffffc02031ac:	e06a                	sd	s10,0(sp)
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc02031ae:	f0dfc0ef          	jal	ra,ffffffffc02000ba <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc02031b2:	01498023          	sb	s4,0(s3) # 3000 <kern_entry-0xffffffffc01fd000>
    assert(pgfault_num == 4);
ffffffffc02031b6:	0000e917          	auipc	s2,0xe
ffffffffc02031ba:	3b292903          	lw	s2,946(s2) # ffffffffc0211568 <pgfault_num>
ffffffffc02031be:	4791                	li	a5,4
ffffffffc02031c0:	14f91e63          	bne	s2,a5,ffffffffc020331c <_fifo_check_swap+0x194>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc02031c4:	00003517          	auipc	a0,0x3
ffffffffc02031c8:	ad450513          	addi	a0,a0,-1324 # ffffffffc0205c98 <default_pmm_manager+0xa88>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc02031cc:	6a85                	lui	s5,0x1
ffffffffc02031ce:	4b29                	li	s6,10
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc02031d0:	eebfc0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc02031d4:	0000e417          	auipc	s0,0xe
ffffffffc02031d8:	39440413          	addi	s0,s0,916 # ffffffffc0211568 <pgfault_num>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc02031dc:	016a8023          	sb	s6,0(s5) # 1000 <kern_entry-0xffffffffc01ff000>
    assert(pgfault_num == 4);
ffffffffc02031e0:	4004                	lw	s1,0(s0)
ffffffffc02031e2:	2481                	sext.w	s1,s1
ffffffffc02031e4:	2b249c63          	bne	s1,s2,ffffffffc020349c <_fifo_check_swap+0x314>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc02031e8:	00003517          	auipc	a0,0x3
ffffffffc02031ec:	ad850513          	addi	a0,a0,-1320 # ffffffffc0205cc0 <default_pmm_manager+0xab0>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc02031f0:	6b91                	lui	s7,0x4
ffffffffc02031f2:	4c35                	li	s8,13
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc02031f4:	ec7fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc02031f8:	018b8023          	sb	s8,0(s7) # 4000 <kern_entry-0xffffffffc01fc000>
    assert(pgfault_num == 4);
ffffffffc02031fc:	00042903          	lw	s2,0(s0)
ffffffffc0203200:	2901                	sext.w	s2,s2
ffffffffc0203202:	26991d63          	bne	s2,s1,ffffffffc020347c <_fifo_check_swap+0x2f4>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0203206:	00003517          	auipc	a0,0x3
ffffffffc020320a:	ae250513          	addi	a0,a0,-1310 # ffffffffc0205ce8 <default_pmm_manager+0xad8>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc020320e:	6c89                	lui	s9,0x2
ffffffffc0203210:	4d2d                	li	s10,11
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0203212:	ea9fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203216:	01ac8023          	sb	s10,0(s9) # 2000 <kern_entry-0xffffffffc01fe000>
    assert(pgfault_num == 4);
ffffffffc020321a:	401c                	lw	a5,0(s0)
ffffffffc020321c:	2781                	sext.w	a5,a5
ffffffffc020321e:	23279f63          	bne	a5,s2,ffffffffc020345c <_fifo_check_swap+0x2d4>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc0203222:	00003517          	auipc	a0,0x3
ffffffffc0203226:	aee50513          	addi	a0,a0,-1298 # ffffffffc0205d10 <default_pmm_manager+0xb00>
ffffffffc020322a:	e91fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc020322e:	6795                	lui	a5,0x5
ffffffffc0203230:	4739                	li	a4,14
ffffffffc0203232:	00e78023          	sb	a4,0(a5) # 5000 <kern_entry-0xffffffffc01fb000>
    assert(pgfault_num == 5);
ffffffffc0203236:	4004                	lw	s1,0(s0)
ffffffffc0203238:	4795                	li	a5,5
ffffffffc020323a:	2481                	sext.w	s1,s1
ffffffffc020323c:	20f49063          	bne	s1,a5,ffffffffc020343c <_fifo_check_swap+0x2b4>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0203240:	00003517          	auipc	a0,0x3
ffffffffc0203244:	aa850513          	addi	a0,a0,-1368 # ffffffffc0205ce8 <default_pmm_manager+0xad8>
ffffffffc0203248:	e73fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc020324c:	01ac8023          	sb	s10,0(s9)
    assert(pgfault_num == 5);
ffffffffc0203250:	401c                	lw	a5,0(s0)
ffffffffc0203252:	2781                	sext.w	a5,a5
ffffffffc0203254:	1c979463          	bne	a5,s1,ffffffffc020341c <_fifo_check_swap+0x294>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0203258:	00003517          	auipc	a0,0x3
ffffffffc020325c:	a4050513          	addi	a0,a0,-1472 # ffffffffc0205c98 <default_pmm_manager+0xa88>
ffffffffc0203260:	e5bfc0ef          	jal	ra,ffffffffc02000ba <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203264:	016a8023          	sb	s6,0(s5)
    assert(pgfault_num == 6);
ffffffffc0203268:	401c                	lw	a5,0(s0)
ffffffffc020326a:	4719                	li	a4,6
ffffffffc020326c:	2781                	sext.w	a5,a5
ffffffffc020326e:	18e79763          	bne	a5,a4,ffffffffc02033fc <_fifo_check_swap+0x274>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0203272:	00003517          	auipc	a0,0x3
ffffffffc0203276:	a7650513          	addi	a0,a0,-1418 # ffffffffc0205ce8 <default_pmm_manager+0xad8>
ffffffffc020327a:	e41fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc020327e:	01ac8023          	sb	s10,0(s9)
    assert(pgfault_num == 7);
ffffffffc0203282:	401c                	lw	a5,0(s0)
ffffffffc0203284:	471d                	li	a4,7
ffffffffc0203286:	2781                	sext.w	a5,a5
ffffffffc0203288:	14e79a63          	bne	a5,a4,ffffffffc02033dc <_fifo_check_swap+0x254>
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc020328c:	00003517          	auipc	a0,0x3
ffffffffc0203290:	9cc50513          	addi	a0,a0,-1588 # ffffffffc0205c58 <default_pmm_manager+0xa48>
ffffffffc0203294:	e27fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0203298:	01498023          	sb	s4,0(s3)
    assert(pgfault_num == 8);
ffffffffc020329c:	401c                	lw	a5,0(s0)
ffffffffc020329e:	4721                	li	a4,8
ffffffffc02032a0:	2781                	sext.w	a5,a5
ffffffffc02032a2:	10e79d63          	bne	a5,a4,ffffffffc02033bc <_fifo_check_swap+0x234>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc02032a6:	00003517          	auipc	a0,0x3
ffffffffc02032aa:	a1a50513          	addi	a0,a0,-1510 # ffffffffc0205cc0 <default_pmm_manager+0xab0>
ffffffffc02032ae:	e0dfc0ef          	jal	ra,ffffffffc02000ba <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc02032b2:	018b8023          	sb	s8,0(s7)
    assert(pgfault_num == 9);
ffffffffc02032b6:	401c                	lw	a5,0(s0)
ffffffffc02032b8:	4725                	li	a4,9
ffffffffc02032ba:	2781                	sext.w	a5,a5
ffffffffc02032bc:	0ee79063          	bne	a5,a4,ffffffffc020339c <_fifo_check_swap+0x214>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc02032c0:	00003517          	auipc	a0,0x3
ffffffffc02032c4:	a5050513          	addi	a0,a0,-1456 # ffffffffc0205d10 <default_pmm_manager+0xb00>
ffffffffc02032c8:	df3fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc02032cc:	6795                	lui	a5,0x5
ffffffffc02032ce:	4739                	li	a4,14
ffffffffc02032d0:	00e78023          	sb	a4,0(a5) # 5000 <kern_entry-0xffffffffc01fb000>
    assert(pgfault_num == 10);
ffffffffc02032d4:	4004                	lw	s1,0(s0)
ffffffffc02032d6:	47a9                	li	a5,10
ffffffffc02032d8:	2481                	sext.w	s1,s1
ffffffffc02032da:	0af49163          	bne	s1,a5,ffffffffc020337c <_fifo_check_swap+0x1f4>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc02032de:	00003517          	auipc	a0,0x3
ffffffffc02032e2:	9ba50513          	addi	a0,a0,-1606 # ffffffffc0205c98 <default_pmm_manager+0xa88>
ffffffffc02032e6:	dd5fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc02032ea:	6785                	lui	a5,0x1
ffffffffc02032ec:	0007c783          	lbu	a5,0(a5) # 1000 <kern_entry-0xffffffffc01ff000>
ffffffffc02032f0:	06979663          	bne	a5,s1,ffffffffc020335c <_fifo_check_swap+0x1d4>
    assert(pgfault_num == 11);
ffffffffc02032f4:	401c                	lw	a5,0(s0)
ffffffffc02032f6:	472d                	li	a4,11
ffffffffc02032f8:	2781                	sext.w	a5,a5
ffffffffc02032fa:	04e79163          	bne	a5,a4,ffffffffc020333c <_fifo_check_swap+0x1b4>
}
ffffffffc02032fe:	60e6                	ld	ra,88(sp)
ffffffffc0203300:	6446                	ld	s0,80(sp)
ffffffffc0203302:	64a6                	ld	s1,72(sp)
ffffffffc0203304:	6906                	ld	s2,64(sp)
ffffffffc0203306:	79e2                	ld	s3,56(sp)
ffffffffc0203308:	7a42                	ld	s4,48(sp)
ffffffffc020330a:	7aa2                	ld	s5,40(sp)
ffffffffc020330c:	7b02                	ld	s6,32(sp)
ffffffffc020330e:	6be2                	ld	s7,24(sp)
ffffffffc0203310:	6c42                	ld	s8,16(sp)
ffffffffc0203312:	6ca2                	ld	s9,8(sp)
ffffffffc0203314:	6d02                	ld	s10,0(sp)
ffffffffc0203316:	4501                	li	a0,0
ffffffffc0203318:	6125                	addi	sp,sp,96
ffffffffc020331a:	8082                	ret
    assert(pgfault_num == 4);
ffffffffc020331c:	00002697          	auipc	a3,0x2
ffffffffc0203320:	77c68693          	addi	a3,a3,1916 # ffffffffc0205a98 <default_pmm_manager+0x888>
ffffffffc0203324:	00002617          	auipc	a2,0x2
ffffffffc0203328:	b3c60613          	addi	a2,a2,-1220 # ffffffffc0204e60 <commands+0x760>
ffffffffc020332c:	05800593          	li	a1,88
ffffffffc0203330:	00003517          	auipc	a0,0x3
ffffffffc0203334:	95050513          	addi	a0,a0,-1712 # ffffffffc0205c80 <default_pmm_manager+0xa70>
ffffffffc0203338:	83cfd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num == 11);
ffffffffc020333c:	00003697          	auipc	a3,0x3
ffffffffc0203340:	ab468693          	addi	a3,a3,-1356 # ffffffffc0205df0 <default_pmm_manager+0xbe0>
ffffffffc0203344:	00002617          	auipc	a2,0x2
ffffffffc0203348:	b1c60613          	addi	a2,a2,-1252 # ffffffffc0204e60 <commands+0x760>
ffffffffc020334c:	07a00593          	li	a1,122
ffffffffc0203350:	00003517          	auipc	a0,0x3
ffffffffc0203354:	93050513          	addi	a0,a0,-1744 # ffffffffc0205c80 <default_pmm_manager+0xa70>
ffffffffc0203358:	81cfd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc020335c:	00003697          	auipc	a3,0x3
ffffffffc0203360:	a6c68693          	addi	a3,a3,-1428 # ffffffffc0205dc8 <default_pmm_manager+0xbb8>
ffffffffc0203364:	00002617          	auipc	a2,0x2
ffffffffc0203368:	afc60613          	addi	a2,a2,-1284 # ffffffffc0204e60 <commands+0x760>
ffffffffc020336c:	07800593          	li	a1,120
ffffffffc0203370:	00003517          	auipc	a0,0x3
ffffffffc0203374:	91050513          	addi	a0,a0,-1776 # ffffffffc0205c80 <default_pmm_manager+0xa70>
ffffffffc0203378:	ffdfc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num == 10);
ffffffffc020337c:	00003697          	auipc	a3,0x3
ffffffffc0203380:	a3468693          	addi	a3,a3,-1484 # ffffffffc0205db0 <default_pmm_manager+0xba0>
ffffffffc0203384:	00002617          	auipc	a2,0x2
ffffffffc0203388:	adc60613          	addi	a2,a2,-1316 # ffffffffc0204e60 <commands+0x760>
ffffffffc020338c:	07600593          	li	a1,118
ffffffffc0203390:	00003517          	auipc	a0,0x3
ffffffffc0203394:	8f050513          	addi	a0,a0,-1808 # ffffffffc0205c80 <default_pmm_manager+0xa70>
ffffffffc0203398:	fddfc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num == 9);
ffffffffc020339c:	00003697          	auipc	a3,0x3
ffffffffc02033a0:	9fc68693          	addi	a3,a3,-1540 # ffffffffc0205d98 <default_pmm_manager+0xb88>
ffffffffc02033a4:	00002617          	auipc	a2,0x2
ffffffffc02033a8:	abc60613          	addi	a2,a2,-1348 # ffffffffc0204e60 <commands+0x760>
ffffffffc02033ac:	07300593          	li	a1,115
ffffffffc02033b0:	00003517          	auipc	a0,0x3
ffffffffc02033b4:	8d050513          	addi	a0,a0,-1840 # ffffffffc0205c80 <default_pmm_manager+0xa70>
ffffffffc02033b8:	fbdfc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num == 8);
ffffffffc02033bc:	00003697          	auipc	a3,0x3
ffffffffc02033c0:	9c468693          	addi	a3,a3,-1596 # ffffffffc0205d80 <default_pmm_manager+0xb70>
ffffffffc02033c4:	00002617          	auipc	a2,0x2
ffffffffc02033c8:	a9c60613          	addi	a2,a2,-1380 # ffffffffc0204e60 <commands+0x760>
ffffffffc02033cc:	07000593          	li	a1,112
ffffffffc02033d0:	00003517          	auipc	a0,0x3
ffffffffc02033d4:	8b050513          	addi	a0,a0,-1872 # ffffffffc0205c80 <default_pmm_manager+0xa70>
ffffffffc02033d8:	f9dfc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num == 7);
ffffffffc02033dc:	00003697          	auipc	a3,0x3
ffffffffc02033e0:	98c68693          	addi	a3,a3,-1652 # ffffffffc0205d68 <default_pmm_manager+0xb58>
ffffffffc02033e4:	00002617          	auipc	a2,0x2
ffffffffc02033e8:	a7c60613          	addi	a2,a2,-1412 # ffffffffc0204e60 <commands+0x760>
ffffffffc02033ec:	06d00593          	li	a1,109
ffffffffc02033f0:	00003517          	auipc	a0,0x3
ffffffffc02033f4:	89050513          	addi	a0,a0,-1904 # ffffffffc0205c80 <default_pmm_manager+0xa70>
ffffffffc02033f8:	f7dfc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num == 6);
ffffffffc02033fc:	00003697          	auipc	a3,0x3
ffffffffc0203400:	95468693          	addi	a3,a3,-1708 # ffffffffc0205d50 <default_pmm_manager+0xb40>
ffffffffc0203404:	00002617          	auipc	a2,0x2
ffffffffc0203408:	a5c60613          	addi	a2,a2,-1444 # ffffffffc0204e60 <commands+0x760>
ffffffffc020340c:	06a00593          	li	a1,106
ffffffffc0203410:	00003517          	auipc	a0,0x3
ffffffffc0203414:	87050513          	addi	a0,a0,-1936 # ffffffffc0205c80 <default_pmm_manager+0xa70>
ffffffffc0203418:	f5dfc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num == 5);
ffffffffc020341c:	00003697          	auipc	a3,0x3
ffffffffc0203420:	91c68693          	addi	a3,a3,-1764 # ffffffffc0205d38 <default_pmm_manager+0xb28>
ffffffffc0203424:	00002617          	auipc	a2,0x2
ffffffffc0203428:	a3c60613          	addi	a2,a2,-1476 # ffffffffc0204e60 <commands+0x760>
ffffffffc020342c:	06700593          	li	a1,103
ffffffffc0203430:	00003517          	auipc	a0,0x3
ffffffffc0203434:	85050513          	addi	a0,a0,-1968 # ffffffffc0205c80 <default_pmm_manager+0xa70>
ffffffffc0203438:	f3dfc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num == 5);
ffffffffc020343c:	00003697          	auipc	a3,0x3
ffffffffc0203440:	8fc68693          	addi	a3,a3,-1796 # ffffffffc0205d38 <default_pmm_manager+0xb28>
ffffffffc0203444:	00002617          	auipc	a2,0x2
ffffffffc0203448:	a1c60613          	addi	a2,a2,-1508 # ffffffffc0204e60 <commands+0x760>
ffffffffc020344c:	06400593          	li	a1,100
ffffffffc0203450:	00003517          	auipc	a0,0x3
ffffffffc0203454:	83050513          	addi	a0,a0,-2000 # ffffffffc0205c80 <default_pmm_manager+0xa70>
ffffffffc0203458:	f1dfc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num == 4);
ffffffffc020345c:	00002697          	auipc	a3,0x2
ffffffffc0203460:	63c68693          	addi	a3,a3,1596 # ffffffffc0205a98 <default_pmm_manager+0x888>
ffffffffc0203464:	00002617          	auipc	a2,0x2
ffffffffc0203468:	9fc60613          	addi	a2,a2,-1540 # ffffffffc0204e60 <commands+0x760>
ffffffffc020346c:	06100593          	li	a1,97
ffffffffc0203470:	00003517          	auipc	a0,0x3
ffffffffc0203474:	81050513          	addi	a0,a0,-2032 # ffffffffc0205c80 <default_pmm_manager+0xa70>
ffffffffc0203478:	efdfc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num == 4);
ffffffffc020347c:	00002697          	auipc	a3,0x2
ffffffffc0203480:	61c68693          	addi	a3,a3,1564 # ffffffffc0205a98 <default_pmm_manager+0x888>
ffffffffc0203484:	00002617          	auipc	a2,0x2
ffffffffc0203488:	9dc60613          	addi	a2,a2,-1572 # ffffffffc0204e60 <commands+0x760>
ffffffffc020348c:	05e00593          	li	a1,94
ffffffffc0203490:	00002517          	auipc	a0,0x2
ffffffffc0203494:	7f050513          	addi	a0,a0,2032 # ffffffffc0205c80 <default_pmm_manager+0xa70>
ffffffffc0203498:	eddfc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num == 4);
ffffffffc020349c:	00002697          	auipc	a3,0x2
ffffffffc02034a0:	5fc68693          	addi	a3,a3,1532 # ffffffffc0205a98 <default_pmm_manager+0x888>
ffffffffc02034a4:	00002617          	auipc	a2,0x2
ffffffffc02034a8:	9bc60613          	addi	a2,a2,-1604 # ffffffffc0204e60 <commands+0x760>
ffffffffc02034ac:	05b00593          	li	a1,91
ffffffffc02034b0:	00002517          	auipc	a0,0x2
ffffffffc02034b4:	7d050513          	addi	a0,a0,2000 # ffffffffc0205c80 <default_pmm_manager+0xa70>
ffffffffc02034b8:	ebdfc0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc02034bc <_fifo_swap_out_victim>:
    list_entry_t *head = (list_entry_t *)mm->sm_priv;
ffffffffc02034bc:	7518                	ld	a4,40(a0)
{
ffffffffc02034be:	1141                	addi	sp,sp,-16
ffffffffc02034c0:	e406                	sd	ra,8(sp)
    assert(head != NULL);
ffffffffc02034c2:	c731                	beqz	a4,ffffffffc020350e <_fifo_swap_out_victim+0x52>
    assert(in_tick == 0);
ffffffffc02034c4:	e60d                	bnez	a2,ffffffffc02034ee <_fifo_swap_out_victim+0x32>
    return listelm->prev;
ffffffffc02034c6:	631c                	ld	a5,0(a4)
    if (entry != head)
ffffffffc02034c8:	00f70d63          	beq	a4,a5,ffffffffc02034e2 <_fifo_swap_out_victim+0x26>
    __list_del(listelm->prev, listelm->next);
ffffffffc02034cc:	6394                	ld	a3,0(a5)
ffffffffc02034ce:	6798                	ld	a4,8(a5)
}
ffffffffc02034d0:	60a2                	ld	ra,8(sp)
        *ptr_page = le2page(entry, pra_page_link);
ffffffffc02034d2:	fd078793          	addi	a5,a5,-48
    prev->next = next;
ffffffffc02034d6:	e698                	sd	a4,8(a3)
    next->prev = prev;
ffffffffc02034d8:	e314                	sd	a3,0(a4)
ffffffffc02034da:	e19c                	sd	a5,0(a1)
}
ffffffffc02034dc:	4501                	li	a0,0
ffffffffc02034de:	0141                	addi	sp,sp,16
ffffffffc02034e0:	8082                	ret
ffffffffc02034e2:	60a2                	ld	ra,8(sp)
        *ptr_page = NULL;
ffffffffc02034e4:	0005b023          	sd	zero,0(a1) # 1000 <kern_entry-0xffffffffc01ff000>
}
ffffffffc02034e8:	4501                	li	a0,0
ffffffffc02034ea:	0141                	addi	sp,sp,16
ffffffffc02034ec:	8082                	ret
    assert(in_tick == 0);
ffffffffc02034ee:	00003697          	auipc	a3,0x3
ffffffffc02034f2:	92a68693          	addi	a3,a3,-1750 # ffffffffc0205e18 <default_pmm_manager+0xc08>
ffffffffc02034f6:	00002617          	auipc	a2,0x2
ffffffffc02034fa:	96a60613          	addi	a2,a2,-1686 # ffffffffc0204e60 <commands+0x760>
ffffffffc02034fe:	04200593          	li	a1,66
ffffffffc0203502:	00002517          	auipc	a0,0x2
ffffffffc0203506:	77e50513          	addi	a0,a0,1918 # ffffffffc0205c80 <default_pmm_manager+0xa70>
ffffffffc020350a:	e6bfc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(head != NULL);
ffffffffc020350e:	00003697          	auipc	a3,0x3
ffffffffc0203512:	8fa68693          	addi	a3,a3,-1798 # ffffffffc0205e08 <default_pmm_manager+0xbf8>
ffffffffc0203516:	00002617          	auipc	a2,0x2
ffffffffc020351a:	94a60613          	addi	a2,a2,-1718 # ffffffffc0204e60 <commands+0x760>
ffffffffc020351e:	04100593          	li	a1,65
ffffffffc0203522:	00002517          	auipc	a0,0x2
ffffffffc0203526:	75e50513          	addi	a0,a0,1886 # ffffffffc0205c80 <default_pmm_manager+0xa70>
ffffffffc020352a:	e4bfc0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc020352e <_fifo_map_swappable>:
    list_entry_t *head = (list_entry_t *)mm->sm_priv;
ffffffffc020352e:	751c                	ld	a5,40(a0)
    assert(entry != NULL && head != NULL);
ffffffffc0203530:	cb91                	beqz	a5,ffffffffc0203544 <_fifo_map_swappable+0x16>
    __list_add(elm, listelm, listelm->next);
ffffffffc0203532:	6794                	ld	a3,8(a5)
ffffffffc0203534:	03060713          	addi	a4,a2,48
}
ffffffffc0203538:	4501                	li	a0,0
    prev->next = next->prev = elm;
ffffffffc020353a:	e298                	sd	a4,0(a3)
ffffffffc020353c:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc020353e:	fe14                	sd	a3,56(a2)
    elm->prev = prev;
ffffffffc0203540:	fa1c                	sd	a5,48(a2)
ffffffffc0203542:	8082                	ret
{
ffffffffc0203544:	1141                	addi	sp,sp,-16
    assert(entry != NULL && head != NULL);
ffffffffc0203546:	00003697          	auipc	a3,0x3
ffffffffc020354a:	8e268693          	addi	a3,a3,-1822 # ffffffffc0205e28 <default_pmm_manager+0xc18>
ffffffffc020354e:	00002617          	auipc	a2,0x2
ffffffffc0203552:	91260613          	addi	a2,a2,-1774 # ffffffffc0204e60 <commands+0x760>
ffffffffc0203556:	03200593          	li	a1,50
ffffffffc020355a:	00002517          	auipc	a0,0x2
ffffffffc020355e:	72650513          	addi	a0,a0,1830 # ffffffffc0205c80 <default_pmm_manager+0xa70>
{
ffffffffc0203562:	e406                	sd	ra,8(sp)
    assert(entry != NULL && head != NULL);
ffffffffc0203564:	e11fc0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0203568 <check_vma_overlap.part.0>:
    return vma;
}

// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next)
ffffffffc0203568:	1141                	addi	sp,sp,-16
{
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);
ffffffffc020356a:	00003697          	auipc	a3,0x3
ffffffffc020356e:	8f668693          	addi	a3,a3,-1802 # ffffffffc0205e60 <default_pmm_manager+0xc50>
ffffffffc0203572:	00002617          	auipc	a2,0x2
ffffffffc0203576:	8ee60613          	addi	a2,a2,-1810 # ffffffffc0204e60 <commands+0x760>
ffffffffc020357a:	08c00593          	li	a1,140
ffffffffc020357e:	00003517          	auipc	a0,0x3
ffffffffc0203582:	90250513          	addi	a0,a0,-1790 # ffffffffc0205e80 <default_pmm_manager+0xc70>
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next)
ffffffffc0203586:	e406                	sd	ra,8(sp)
    assert(next->vm_start < next->vm_end);
ffffffffc0203588:	dedfc0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc020358c <mm_create>:
{
ffffffffc020358c:	1141                	addi	sp,sp,-16
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc020358e:	03000513          	li	a0,48
{
ffffffffc0203592:	e022                	sd	s0,0(sp)
ffffffffc0203594:	e406                	sd	ra,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0203596:	a22ff0ef          	jal	ra,ffffffffc02027b8 <kmalloc>
ffffffffc020359a:	842a                	mv	s0,a0
    if (mm != NULL)
ffffffffc020359c:	c105                	beqz	a0,ffffffffc02035bc <mm_create+0x30>
    elm->prev = elm->next = elm;
ffffffffc020359e:	e408                	sd	a0,8(s0)
ffffffffc02035a0:	e008                	sd	a0,0(s0)
        mm->mmap_cache = NULL;
ffffffffc02035a2:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc02035a6:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc02035aa:	02052023          	sw	zero,32(a0)
        if (swap_init_ok)
ffffffffc02035ae:	0000e797          	auipc	a5,0xe
ffffffffc02035b2:	faa7a783          	lw	a5,-86(a5) # ffffffffc0211558 <swap_init_ok>
ffffffffc02035b6:	eb81                	bnez	a5,ffffffffc02035c6 <mm_create+0x3a>
            mm->sm_priv = NULL;
ffffffffc02035b8:	02053423          	sd	zero,40(a0)
}
ffffffffc02035bc:	60a2                	ld	ra,8(sp)
ffffffffc02035be:	8522                	mv	a0,s0
ffffffffc02035c0:	6402                	ld	s0,0(sp)
ffffffffc02035c2:	0141                	addi	sp,sp,16
ffffffffc02035c4:	8082                	ret
            swap_init_mm(mm);
ffffffffc02035c6:	9ffff0ef          	jal	ra,ffffffffc0202fc4 <swap_init_mm>
}
ffffffffc02035ca:	60a2                	ld	ra,8(sp)
ffffffffc02035cc:	8522                	mv	a0,s0
ffffffffc02035ce:	6402                	ld	s0,0(sp)
ffffffffc02035d0:	0141                	addi	sp,sp,16
ffffffffc02035d2:	8082                	ret

ffffffffc02035d4 <vma_create>:
{
ffffffffc02035d4:	1101                	addi	sp,sp,-32
ffffffffc02035d6:	e04a                	sd	s2,0(sp)
ffffffffc02035d8:	892a                	mv	s2,a0
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02035da:	03000513          	li	a0,48
{
ffffffffc02035de:	e822                	sd	s0,16(sp)
ffffffffc02035e0:	e426                	sd	s1,8(sp)
ffffffffc02035e2:	ec06                	sd	ra,24(sp)
ffffffffc02035e4:	84ae                	mv	s1,a1
ffffffffc02035e6:	8432                	mv	s0,a2
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02035e8:	9d0ff0ef          	jal	ra,ffffffffc02027b8 <kmalloc>
    if (vma != NULL)
ffffffffc02035ec:	c509                	beqz	a0,ffffffffc02035f6 <vma_create+0x22>
        vma->vm_start = vm_start;
ffffffffc02035ee:	01253423          	sd	s2,8(a0)
        vma->vm_end = vm_end;
ffffffffc02035f2:	e904                	sd	s1,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc02035f4:	ed00                	sd	s0,24(a0)
}
ffffffffc02035f6:	60e2                	ld	ra,24(sp)
ffffffffc02035f8:	6442                	ld	s0,16(sp)
ffffffffc02035fa:	64a2                	ld	s1,8(sp)
ffffffffc02035fc:	6902                	ld	s2,0(sp)
ffffffffc02035fe:	6105                	addi	sp,sp,32
ffffffffc0203600:	8082                	ret

ffffffffc0203602 <find_vma>:
{
ffffffffc0203602:	86aa                	mv	a3,a0
    if (mm != NULL)
ffffffffc0203604:	c505                	beqz	a0,ffffffffc020362c <find_vma+0x2a>
        vma = mm->mmap_cache;
ffffffffc0203606:	6908                	ld	a0,16(a0)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr))
ffffffffc0203608:	c501                	beqz	a0,ffffffffc0203610 <find_vma+0xe>
ffffffffc020360a:	651c                	ld	a5,8(a0)
ffffffffc020360c:	02f5f263          	bgeu	a1,a5,ffffffffc0203630 <find_vma+0x2e>
    return listelm->next;
ffffffffc0203610:	669c                	ld	a5,8(a3)
            while ((le = list_next(le)) != list)
ffffffffc0203612:	00f68d63          	beq	a3,a5,ffffffffc020362c <find_vma+0x2a>
                if (vma->vm_start <= addr && addr < vma->vm_end)
ffffffffc0203616:	fe87b703          	ld	a4,-24(a5)
ffffffffc020361a:	00e5e663          	bltu	a1,a4,ffffffffc0203626 <find_vma+0x24>
ffffffffc020361e:	ff07b703          	ld	a4,-16(a5)
ffffffffc0203622:	00e5ec63          	bltu	a1,a4,ffffffffc020363a <find_vma+0x38>
ffffffffc0203626:	679c                	ld	a5,8(a5)
            while ((le = list_next(le)) != list)
ffffffffc0203628:	fef697e3          	bne	a3,a5,ffffffffc0203616 <find_vma+0x14>
    struct vma_struct *vma = NULL;
ffffffffc020362c:	4501                	li	a0,0
}
ffffffffc020362e:	8082                	ret
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr))
ffffffffc0203630:	691c                	ld	a5,16(a0)
ffffffffc0203632:	fcf5ffe3          	bgeu	a1,a5,ffffffffc0203610 <find_vma+0xe>
            mm->mmap_cache = vma;
ffffffffc0203636:	ea88                	sd	a0,16(a3)
ffffffffc0203638:	8082                	ret
                vma = le2vma(le, list_link);
ffffffffc020363a:	fe078513          	addi	a0,a5,-32
            mm->mmap_cache = vma;
ffffffffc020363e:	ea88                	sd	a0,16(a3)
ffffffffc0203640:	8082                	ret

ffffffffc0203642 <insert_vma_struct>:
}

// insert_vma_struct -insert vma in mm's list link
void insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma)
{
    assert(vma->vm_start < vma->vm_end);
ffffffffc0203642:	6590                	ld	a2,8(a1)
ffffffffc0203644:	0105b803          	ld	a6,16(a1)
{
ffffffffc0203648:	1141                	addi	sp,sp,-16
ffffffffc020364a:	e406                	sd	ra,8(sp)
ffffffffc020364c:	87aa                	mv	a5,a0
    assert(vma->vm_start < vma->vm_end);
ffffffffc020364e:	01066763          	bltu	a2,a6,ffffffffc020365c <insert_vma_struct+0x1a>
ffffffffc0203652:	a085                	j	ffffffffc02036b2 <insert_vma_struct+0x70>

    list_entry_t *le = list;
    while ((le = list_next(le)) != list)
    {
        struct vma_struct *mmap_prev = le2vma(le, list_link);
        if (mmap_prev->vm_start > vma->vm_start)
ffffffffc0203654:	fe87b703          	ld	a4,-24(a5)
ffffffffc0203658:	04e66863          	bltu	a2,a4,ffffffffc02036a8 <insert_vma_struct+0x66>
ffffffffc020365c:	86be                	mv	a3,a5
ffffffffc020365e:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != list)
ffffffffc0203660:	fef51ae3          	bne	a0,a5,ffffffffc0203654 <insert_vma_struct+0x12>
    }

    le_next = list_next(le_prev);

    /* check overlap */
    if (le_prev != list)
ffffffffc0203664:	02a68463          	beq	a3,a0,ffffffffc020368c <insert_vma_struct+0x4a>
    {
        check_vma_overlap(le2vma(le_prev, list_link), vma);
ffffffffc0203668:	ff06b703          	ld	a4,-16(a3)
    assert(prev->vm_start < prev->vm_end);
ffffffffc020366c:	fe86b883          	ld	a7,-24(a3)
ffffffffc0203670:	08e8f163          	bgeu	a7,a4,ffffffffc02036f2 <insert_vma_struct+0xb0>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0203674:	04e66f63          	bltu	a2,a4,ffffffffc02036d2 <insert_vma_struct+0x90>
    }
    if (le_next != list)
ffffffffc0203678:	00f50a63          	beq	a0,a5,ffffffffc020368c <insert_vma_struct+0x4a>
        if (mmap_prev->vm_start > vma->vm_start)
ffffffffc020367c:	fe87b703          	ld	a4,-24(a5)
    assert(prev->vm_end <= next->vm_start);
ffffffffc0203680:	05076963          	bltu	a4,a6,ffffffffc02036d2 <insert_vma_struct+0x90>
    assert(next->vm_start < next->vm_end);
ffffffffc0203684:	ff07b603          	ld	a2,-16(a5)
ffffffffc0203688:	02c77363          	bgeu	a4,a2,ffffffffc02036ae <insert_vma_struct+0x6c>
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count++;
ffffffffc020368c:	5118                	lw	a4,32(a0)
    vma->vm_mm = mm;
ffffffffc020368e:	e188                	sd	a0,0(a1)
    list_add_after(le_prev, &(vma->list_link));
ffffffffc0203690:	02058613          	addi	a2,a1,32
    prev->next = next->prev = elm;
ffffffffc0203694:	e390                	sd	a2,0(a5)
ffffffffc0203696:	e690                	sd	a2,8(a3)
}
ffffffffc0203698:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc020369a:	f59c                	sd	a5,40(a1)
    elm->prev = prev;
ffffffffc020369c:	f194                	sd	a3,32(a1)
    mm->map_count++;
ffffffffc020369e:	0017079b          	addiw	a5,a4,1
ffffffffc02036a2:	d11c                	sw	a5,32(a0)
}
ffffffffc02036a4:	0141                	addi	sp,sp,16
ffffffffc02036a6:	8082                	ret
    if (le_prev != list)
ffffffffc02036a8:	fca690e3          	bne	a3,a0,ffffffffc0203668 <insert_vma_struct+0x26>
ffffffffc02036ac:	bfd1                	j	ffffffffc0203680 <insert_vma_struct+0x3e>
ffffffffc02036ae:	ebbff0ef          	jal	ra,ffffffffc0203568 <check_vma_overlap.part.0>
    assert(vma->vm_start < vma->vm_end);
ffffffffc02036b2:	00002697          	auipc	a3,0x2
ffffffffc02036b6:	7de68693          	addi	a3,a3,2014 # ffffffffc0205e90 <default_pmm_manager+0xc80>
ffffffffc02036ba:	00001617          	auipc	a2,0x1
ffffffffc02036be:	7a660613          	addi	a2,a2,1958 # ffffffffc0204e60 <commands+0x760>
ffffffffc02036c2:	09200593          	li	a1,146
ffffffffc02036c6:	00002517          	auipc	a0,0x2
ffffffffc02036ca:	7ba50513          	addi	a0,a0,1978 # ffffffffc0205e80 <default_pmm_manager+0xc70>
ffffffffc02036ce:	ca7fc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc02036d2:	00002697          	auipc	a3,0x2
ffffffffc02036d6:	7fe68693          	addi	a3,a3,2046 # ffffffffc0205ed0 <default_pmm_manager+0xcc0>
ffffffffc02036da:	00001617          	auipc	a2,0x1
ffffffffc02036de:	78660613          	addi	a2,a2,1926 # ffffffffc0204e60 <commands+0x760>
ffffffffc02036e2:	08b00593          	li	a1,139
ffffffffc02036e6:	00002517          	auipc	a0,0x2
ffffffffc02036ea:	79a50513          	addi	a0,a0,1946 # ffffffffc0205e80 <default_pmm_manager+0xc70>
ffffffffc02036ee:	c87fc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc02036f2:	00002697          	auipc	a3,0x2
ffffffffc02036f6:	7be68693          	addi	a3,a3,1982 # ffffffffc0205eb0 <default_pmm_manager+0xca0>
ffffffffc02036fa:	00001617          	auipc	a2,0x1
ffffffffc02036fe:	76660613          	addi	a2,a2,1894 # ffffffffc0204e60 <commands+0x760>
ffffffffc0203702:	08a00593          	li	a1,138
ffffffffc0203706:	00002517          	auipc	a0,0x2
ffffffffc020370a:	77a50513          	addi	a0,a0,1914 # ffffffffc0205e80 <default_pmm_manager+0xc70>
ffffffffc020370e:	c67fc0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0203712 <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void mm_destroy(struct mm_struct *mm)
{
ffffffffc0203712:	1141                	addi	sp,sp,-16
ffffffffc0203714:	e022                	sd	s0,0(sp)
ffffffffc0203716:	842a                	mv	s0,a0
    return listelm->next;
ffffffffc0203718:	6508                	ld	a0,8(a0)
ffffffffc020371a:	e406                	sd	ra,8(sp)

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list)
ffffffffc020371c:	00a40e63          	beq	s0,a0,ffffffffc0203738 <mm_destroy+0x26>
    __list_del(listelm->prev, listelm->next);
ffffffffc0203720:	6118                	ld	a4,0(a0)
ffffffffc0203722:	651c                	ld	a5,8(a0)
    {
        list_del(le);
        kfree(le2vma(le, list_link), sizeof(struct vma_struct)); // kfree vma
ffffffffc0203724:	03000593          	li	a1,48
ffffffffc0203728:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc020372a:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc020372c:	e398                	sd	a4,0(a5)
ffffffffc020372e:	944ff0ef          	jal	ra,ffffffffc0202872 <kfree>
    return listelm->next;
ffffffffc0203732:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list)
ffffffffc0203734:	fea416e3          	bne	s0,a0,ffffffffc0203720 <mm_destroy+0xe>
    }
    kfree(mm, sizeof(struct mm_struct)); // kfree mm
ffffffffc0203738:	8522                	mv	a0,s0
    mm = NULL;
}
ffffffffc020373a:	6402                	ld	s0,0(sp)
ffffffffc020373c:	60a2                	ld	ra,8(sp)
    kfree(mm, sizeof(struct mm_struct)); // kfree mm
ffffffffc020373e:	03000593          	li	a1,48
}
ffffffffc0203742:	0141                	addi	sp,sp,16
    kfree(mm, sizeof(struct mm_struct)); // kfree mm
ffffffffc0203744:	92eff06f          	j	ffffffffc0202872 <kfree>

ffffffffc0203748 <vmm_init>:

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void vmm_init(void)
{
ffffffffc0203748:	715d                	addi	sp,sp,-80
ffffffffc020374a:	e486                	sd	ra,72(sp)
ffffffffc020374c:	f44e                	sd	s3,40(sp)
ffffffffc020374e:	f052                	sd	s4,32(sp)
ffffffffc0203750:	e0a2                	sd	s0,64(sp)
ffffffffc0203752:	fc26                	sd	s1,56(sp)
ffffffffc0203754:	f84a                	sd	s2,48(sp)
ffffffffc0203756:	ec56                	sd	s5,24(sp)
ffffffffc0203758:	e85a                	sd	s6,16(sp)
ffffffffc020375a:	e45e                	sd	s7,8(sp)

// check_vmm - check correctness of vmm
static void
check_vmm(void)
{
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc020375c:	f77fd0ef          	jal	ra,ffffffffc02016d2 <nr_free_pages>
ffffffffc0203760:	89aa                	mv	s3,a0
}

static void
check_vma_struct(void)
{
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0203762:	f71fd0ef          	jal	ra,ffffffffc02016d2 <nr_free_pages>
ffffffffc0203766:	8a2a                	mv	s4,a0
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0203768:	03000513          	li	a0,48
ffffffffc020376c:	84cff0ef          	jal	ra,ffffffffc02027b8 <kmalloc>
    if (mm != NULL)
ffffffffc0203770:	56050863          	beqz	a0,ffffffffc0203ce0 <vmm_init+0x598>
    elm->prev = elm->next = elm;
ffffffffc0203774:	e508                	sd	a0,8(a0)
ffffffffc0203776:	e108                	sd	a0,0(a0)
        mm->mmap_cache = NULL;
ffffffffc0203778:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc020377c:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc0203780:	02052023          	sw	zero,32(a0)
        if (swap_init_ok)
ffffffffc0203784:	0000e797          	auipc	a5,0xe
ffffffffc0203788:	dd47a783          	lw	a5,-556(a5) # ffffffffc0211558 <swap_init_ok>
ffffffffc020378c:	84aa                	mv	s1,a0
ffffffffc020378e:	e7b9                	bnez	a5,ffffffffc02037dc <vmm_init+0x94>
            mm->sm_priv = NULL;
ffffffffc0203790:	02053423          	sd	zero,40(a0)
{
ffffffffc0203794:	03200413          	li	s0,50
ffffffffc0203798:	a811                	j	ffffffffc02037ac <vmm_init+0x64>
        vma->vm_start = vm_start;
ffffffffc020379a:	e500                	sd	s0,8(a0)
        vma->vm_end = vm_end;
ffffffffc020379c:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc020379e:	00053c23          	sd	zero,24(a0)
    assert(mm != NULL);

    int step1 = 10, step2 = step1 * 10;

    int i;
    for (i = step1; i >= 1; i--)
ffffffffc02037a2:	146d                	addi	s0,s0,-5
    {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc02037a4:	8526                	mv	a0,s1
ffffffffc02037a6:	e9dff0ef          	jal	ra,ffffffffc0203642 <insert_vma_struct>
    for (i = step1; i >= 1; i--)
ffffffffc02037aa:	cc05                	beqz	s0,ffffffffc02037e2 <vmm_init+0x9a>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02037ac:	03000513          	li	a0,48
ffffffffc02037b0:	808ff0ef          	jal	ra,ffffffffc02027b8 <kmalloc>
ffffffffc02037b4:	85aa                	mv	a1,a0
ffffffffc02037b6:	00240793          	addi	a5,s0,2
    if (vma != NULL)
ffffffffc02037ba:	f165                	bnez	a0,ffffffffc020379a <vmm_init+0x52>
        assert(vma != NULL);
ffffffffc02037bc:	00002697          	auipc	a3,0x2
ffffffffc02037c0:	18468693          	addi	a3,a3,388 # ffffffffc0205940 <default_pmm_manager+0x730>
ffffffffc02037c4:	00001617          	auipc	a2,0x1
ffffffffc02037c8:	69c60613          	addi	a2,a2,1692 # ffffffffc0204e60 <commands+0x760>
ffffffffc02037cc:	0e400593          	li	a1,228
ffffffffc02037d0:	00002517          	auipc	a0,0x2
ffffffffc02037d4:	6b050513          	addi	a0,a0,1712 # ffffffffc0205e80 <default_pmm_manager+0xc70>
ffffffffc02037d8:	b9dfc0ef          	jal	ra,ffffffffc0200374 <__panic>
            swap_init_mm(mm);
ffffffffc02037dc:	fe8ff0ef          	jal	ra,ffffffffc0202fc4 <swap_init_mm>
ffffffffc02037e0:	bf55                	j	ffffffffc0203794 <vmm_init+0x4c>
ffffffffc02037e2:	03700413          	li	s0,55
    }

    for (i = step1 + 1; i <= step2; i++)
ffffffffc02037e6:	1f900913          	li	s2,505
ffffffffc02037ea:	a819                	j	ffffffffc0203800 <vmm_init+0xb8>
        vma->vm_start = vm_start;
ffffffffc02037ec:	e500                	sd	s0,8(a0)
        vma->vm_end = vm_end;
ffffffffc02037ee:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc02037f0:	00053c23          	sd	zero,24(a0)
    for (i = step1 + 1; i <= step2; i++)
ffffffffc02037f4:	0415                	addi	s0,s0,5
    {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc02037f6:	8526                	mv	a0,s1
ffffffffc02037f8:	e4bff0ef          	jal	ra,ffffffffc0203642 <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i++)
ffffffffc02037fc:	03240a63          	beq	s0,s2,ffffffffc0203830 <vmm_init+0xe8>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0203800:	03000513          	li	a0,48
ffffffffc0203804:	fb5fe0ef          	jal	ra,ffffffffc02027b8 <kmalloc>
ffffffffc0203808:	85aa                	mv	a1,a0
ffffffffc020380a:	00240793          	addi	a5,s0,2
    if (vma != NULL)
ffffffffc020380e:	fd79                	bnez	a0,ffffffffc02037ec <vmm_init+0xa4>
        assert(vma != NULL);
ffffffffc0203810:	00002697          	auipc	a3,0x2
ffffffffc0203814:	13068693          	addi	a3,a3,304 # ffffffffc0205940 <default_pmm_manager+0x730>
ffffffffc0203818:	00001617          	auipc	a2,0x1
ffffffffc020381c:	64860613          	addi	a2,a2,1608 # ffffffffc0204e60 <commands+0x760>
ffffffffc0203820:	0eb00593          	li	a1,235
ffffffffc0203824:	00002517          	auipc	a0,0x2
ffffffffc0203828:	65c50513          	addi	a0,a0,1628 # ffffffffc0205e80 <default_pmm_manager+0xc70>
ffffffffc020382c:	b49fc0ef          	jal	ra,ffffffffc0200374 <__panic>
    return listelm->next;
ffffffffc0203830:	649c                	ld	a5,8(s1)
ffffffffc0203832:	471d                	li	a4,7
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i++)
ffffffffc0203834:	1fb00593          	li	a1,507
    {
        assert(le != &(mm->mmap_list));
ffffffffc0203838:	2ef48463          	beq	s1,a5,ffffffffc0203b20 <vmm_init+0x3d8>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc020383c:	fe87b603          	ld	a2,-24(a5)
ffffffffc0203840:	ffe70693          	addi	a3,a4,-2
ffffffffc0203844:	26d61e63          	bne	a2,a3,ffffffffc0203ac0 <vmm_init+0x378>
ffffffffc0203848:	ff07b683          	ld	a3,-16(a5)
ffffffffc020384c:	26e69a63          	bne	a3,a4,ffffffffc0203ac0 <vmm_init+0x378>
    for (i = 1; i <= step2; i++)
ffffffffc0203850:	0715                	addi	a4,a4,5
ffffffffc0203852:	679c                	ld	a5,8(a5)
ffffffffc0203854:	feb712e3          	bne	a4,a1,ffffffffc0203838 <vmm_init+0xf0>
ffffffffc0203858:	4b1d                	li	s6,7
ffffffffc020385a:	4415                	li	s0,5
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i += 5)
ffffffffc020385c:	1f900b93          	li	s7,505
    {
        struct vma_struct *vma1 = find_vma(mm, i);
ffffffffc0203860:	85a2                	mv	a1,s0
ffffffffc0203862:	8526                	mv	a0,s1
ffffffffc0203864:	d9fff0ef          	jal	ra,ffffffffc0203602 <find_vma>
ffffffffc0203868:	892a                	mv	s2,a0
        assert(vma1 != NULL);
ffffffffc020386a:	2c050b63          	beqz	a0,ffffffffc0203b40 <vmm_init+0x3f8>
        struct vma_struct *vma2 = find_vma(mm, i + 1);
ffffffffc020386e:	00140593          	addi	a1,s0,1
ffffffffc0203872:	8526                	mv	a0,s1
ffffffffc0203874:	d8fff0ef          	jal	ra,ffffffffc0203602 <find_vma>
ffffffffc0203878:	8aaa                	mv	s5,a0
        assert(vma2 != NULL);
ffffffffc020387a:	2e050363          	beqz	a0,ffffffffc0203b60 <vmm_init+0x418>
        struct vma_struct *vma3 = find_vma(mm, i + 2);
ffffffffc020387e:	85da                	mv	a1,s6
ffffffffc0203880:	8526                	mv	a0,s1
ffffffffc0203882:	d81ff0ef          	jal	ra,ffffffffc0203602 <find_vma>
        assert(vma3 == NULL);
ffffffffc0203886:	2e051d63          	bnez	a0,ffffffffc0203b80 <vmm_init+0x438>
        struct vma_struct *vma4 = find_vma(mm, i + 3);
ffffffffc020388a:	00340593          	addi	a1,s0,3
ffffffffc020388e:	8526                	mv	a0,s1
ffffffffc0203890:	d73ff0ef          	jal	ra,ffffffffc0203602 <find_vma>
        assert(vma4 == NULL);
ffffffffc0203894:	30051663          	bnez	a0,ffffffffc0203ba0 <vmm_init+0x458>
        struct vma_struct *vma5 = find_vma(mm, i + 4);
ffffffffc0203898:	00440593          	addi	a1,s0,4
ffffffffc020389c:	8526                	mv	a0,s1
ffffffffc020389e:	d65ff0ef          	jal	ra,ffffffffc0203602 <find_vma>
        assert(vma5 == NULL);
ffffffffc02038a2:	30051f63          	bnez	a0,ffffffffc0203bc0 <vmm_init+0x478>

        assert(vma1->vm_start == i && vma1->vm_end == i + 2);
ffffffffc02038a6:	00893783          	ld	a5,8(s2)
ffffffffc02038aa:	24879b63          	bne	a5,s0,ffffffffc0203b00 <vmm_init+0x3b8>
ffffffffc02038ae:	01093783          	ld	a5,16(s2)
ffffffffc02038b2:	25679763          	bne	a5,s6,ffffffffc0203b00 <vmm_init+0x3b8>
        assert(vma2->vm_start == i && vma2->vm_end == i + 2);
ffffffffc02038b6:	008ab783          	ld	a5,8(s5)
ffffffffc02038ba:	22879363          	bne	a5,s0,ffffffffc0203ae0 <vmm_init+0x398>
ffffffffc02038be:	010ab783          	ld	a5,16(s5)
ffffffffc02038c2:	21679f63          	bne	a5,s6,ffffffffc0203ae0 <vmm_init+0x398>
    for (i = 5; i <= 5 * step2; i += 5)
ffffffffc02038c6:	0415                	addi	s0,s0,5
ffffffffc02038c8:	0b15                	addi	s6,s6,5
ffffffffc02038ca:	f9741be3          	bne	s0,s7,ffffffffc0203860 <vmm_init+0x118>
ffffffffc02038ce:	4411                	li	s0,4
    }

    for (i = 4; i >= 0; i--)
ffffffffc02038d0:	597d                	li	s2,-1
    {
        struct vma_struct *vma_below_5 = find_vma(mm, i);
ffffffffc02038d2:	85a2                	mv	a1,s0
ffffffffc02038d4:	8526                	mv	a0,s1
ffffffffc02038d6:	d2dff0ef          	jal	ra,ffffffffc0203602 <find_vma>
ffffffffc02038da:	0004059b          	sext.w	a1,s0
        if (vma_below_5 != NULL)
ffffffffc02038de:	c90d                	beqz	a0,ffffffffc0203910 <vmm_init+0x1c8>
        {
            cprintf("vma_below_5: i %x, start %x, end %x\n", i, vma_below_5->vm_start, vma_below_5->vm_end);
ffffffffc02038e0:	6914                	ld	a3,16(a0)
ffffffffc02038e2:	6510                	ld	a2,8(a0)
ffffffffc02038e4:	00002517          	auipc	a0,0x2
ffffffffc02038e8:	70c50513          	addi	a0,a0,1804 # ffffffffc0205ff0 <default_pmm_manager+0xde0>
ffffffffc02038ec:	fcefc0ef          	jal	ra,ffffffffc02000ba <cprintf>
        }
        assert(vma_below_5 == NULL);
ffffffffc02038f0:	00002697          	auipc	a3,0x2
ffffffffc02038f4:	72868693          	addi	a3,a3,1832 # ffffffffc0206018 <default_pmm_manager+0xe08>
ffffffffc02038f8:	00001617          	auipc	a2,0x1
ffffffffc02038fc:	56860613          	addi	a2,a2,1384 # ffffffffc0204e60 <commands+0x760>
ffffffffc0203900:	11100593          	li	a1,273
ffffffffc0203904:	00002517          	auipc	a0,0x2
ffffffffc0203908:	57c50513          	addi	a0,a0,1404 # ffffffffc0205e80 <default_pmm_manager+0xc70>
ffffffffc020390c:	a69fc0ef          	jal	ra,ffffffffc0200374 <__panic>
    for (i = 4; i >= 0; i--)
ffffffffc0203910:	147d                	addi	s0,s0,-1
ffffffffc0203912:	fd2410e3          	bne	s0,s2,ffffffffc02038d2 <vmm_init+0x18a>
ffffffffc0203916:	a811                	j	ffffffffc020392a <vmm_init+0x1e2>
    __list_del(listelm->prev, listelm->next);
ffffffffc0203918:	6118                	ld	a4,0(a0)
ffffffffc020391a:	651c                	ld	a5,8(a0)
        kfree(le2vma(le, list_link), sizeof(struct vma_struct)); // kfree vma
ffffffffc020391c:	03000593          	li	a1,48
ffffffffc0203920:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc0203922:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0203924:	e398                	sd	a4,0(a5)
ffffffffc0203926:	f4dfe0ef          	jal	ra,ffffffffc0202872 <kfree>
    return listelm->next;
ffffffffc020392a:	6488                	ld	a0,8(s1)
    while ((le = list_next(list)) != list)
ffffffffc020392c:	fea496e3          	bne	s1,a0,ffffffffc0203918 <vmm_init+0x1d0>
    kfree(mm, sizeof(struct mm_struct)); // kfree mm
ffffffffc0203930:	03000593          	li	a1,48
ffffffffc0203934:	8526                	mv	a0,s1
ffffffffc0203936:	f3dfe0ef          	jal	ra,ffffffffc0202872 <kfree>
    }

    mm_destroy(mm);

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc020393a:	d99fd0ef          	jal	ra,ffffffffc02016d2 <nr_free_pages>
ffffffffc020393e:	3caa1163          	bne	s4,a0,ffffffffc0203d00 <vmm_init+0x5b8>

    cprintf("check_vma_struct() succeeded!\n");
ffffffffc0203942:	00002517          	auipc	a0,0x2
ffffffffc0203946:	71650513          	addi	a0,a0,1814 # ffffffffc0206058 <default_pmm_manager+0xe48>
ffffffffc020394a:	f70fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void)
{
    // char *name = "check_pgfault";
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc020394e:	d85fd0ef          	jal	ra,ffffffffc02016d2 <nr_free_pages>
ffffffffc0203952:	84aa                	mv	s1,a0
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0203954:	03000513          	li	a0,48
ffffffffc0203958:	e61fe0ef          	jal	ra,ffffffffc02027b8 <kmalloc>
ffffffffc020395c:	842a                	mv	s0,a0
    if (mm != NULL)
ffffffffc020395e:	2a050163          	beqz	a0,ffffffffc0203c00 <vmm_init+0x4b8>
        if (swap_init_ok)
ffffffffc0203962:	0000e797          	auipc	a5,0xe
ffffffffc0203966:	bf67a783          	lw	a5,-1034(a5) # ffffffffc0211558 <swap_init_ok>
    elm->prev = elm->next = elm;
ffffffffc020396a:	e508                	sd	a0,8(a0)
ffffffffc020396c:	e108                	sd	a0,0(a0)
        mm->mmap_cache = NULL;
ffffffffc020396e:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc0203972:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc0203976:	02052023          	sw	zero,32(a0)
        if (swap_init_ok)
ffffffffc020397a:	14079063          	bnez	a5,ffffffffc0203aba <vmm_init+0x372>
            mm->sm_priv = NULL;
ffffffffc020397e:	02053423          	sd	zero,40(a0)

    check_mm_struct = mm_create();

    assert(check_mm_struct != NULL);
    struct mm_struct *mm = check_mm_struct;
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0203982:	0000e917          	auipc	s2,0xe
ffffffffc0203986:	b9e93903          	ld	s2,-1122(s2) # ffffffffc0211520 <boot_pgdir>
    assert(pgdir[0] == 0);
ffffffffc020398a:	00093783          	ld	a5,0(s2)
    check_mm_struct = mm_create();
ffffffffc020398e:	0000e717          	auipc	a4,0xe
ffffffffc0203992:	bc873923          	sd	s0,-1070(a4) # ffffffffc0211560 <check_mm_struct>
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0203996:	01243c23          	sd	s2,24(s0)
    assert(pgdir[0] == 0);
ffffffffc020399a:	24079363          	bnez	a5,ffffffffc0203be0 <vmm_init+0x498>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc020399e:	03000513          	li	a0,48
ffffffffc02039a2:	e17fe0ef          	jal	ra,ffffffffc02027b8 <kmalloc>
ffffffffc02039a6:	8a2a                	mv	s4,a0
    if (vma != NULL)
ffffffffc02039a8:	28050063          	beqz	a0,ffffffffc0203c28 <vmm_init+0x4e0>
        vma->vm_end = vm_end;
ffffffffc02039ac:	002007b7          	lui	a5,0x200
ffffffffc02039b0:	00fa3823          	sd	a5,16(s4)
        vma->vm_flags = vm_flags;
ffffffffc02039b4:	4789                	li	a5,2

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);

    assert(vma != NULL);

    insert_vma_struct(mm, vma);
ffffffffc02039b6:	85aa                	mv	a1,a0
        vma->vm_flags = vm_flags;
ffffffffc02039b8:	00fa3c23          	sd	a5,24(s4)
    insert_vma_struct(mm, vma);
ffffffffc02039bc:	8522                	mv	a0,s0
        vma->vm_start = vm_start;
ffffffffc02039be:	000a3423          	sd	zero,8(s4)
    insert_vma_struct(mm, vma);
ffffffffc02039c2:	c81ff0ef          	jal	ra,ffffffffc0203642 <insert_vma_struct>

    uintptr_t addr = 0x100;
    assert(find_vma(mm, addr) == vma);
ffffffffc02039c6:	10000593          	li	a1,256
ffffffffc02039ca:	8522                	mv	a0,s0
ffffffffc02039cc:	c37ff0ef          	jal	ra,ffffffffc0203602 <find_vma>
ffffffffc02039d0:	10000793          	li	a5,256

    int i, sum = 0;
    for (i = 0; i < 100; i++)
ffffffffc02039d4:	16400713          	li	a4,356
    assert(find_vma(mm, addr) == vma);
ffffffffc02039d8:	26aa1863          	bne	s4,a0,ffffffffc0203c48 <vmm_init+0x500>
    {
        *(char *)(addr + i) = i;
ffffffffc02039dc:	00f78023          	sb	a5,0(a5) # 200000 <kern_entry-0xffffffffc0000000>
    for (i = 0; i < 100; i++)
ffffffffc02039e0:	0785                	addi	a5,a5,1
ffffffffc02039e2:	fee79de3          	bne	a5,a4,ffffffffc02039dc <vmm_init+0x294>
        sum += i;
ffffffffc02039e6:	6705                	lui	a4,0x1
ffffffffc02039e8:	10000793          	li	a5,256
ffffffffc02039ec:	35670713          	addi	a4,a4,854 # 1356 <kern_entry-0xffffffffc01fecaa>
    }
    for (i = 0; i < 100; i++)
ffffffffc02039f0:	16400613          	li	a2,356
    {
        sum -= *(char *)(addr + i);
ffffffffc02039f4:	0007c683          	lbu	a3,0(a5)
    for (i = 0; i < 100; i++)
ffffffffc02039f8:	0785                	addi	a5,a5,1
        sum -= *(char *)(addr + i);
ffffffffc02039fa:	9f15                	subw	a4,a4,a3
    for (i = 0; i < 100; i++)
ffffffffc02039fc:	fec79ce3          	bne	a5,a2,ffffffffc02039f4 <vmm_init+0x2ac>
    }
    assert(sum == 0);
ffffffffc0203a00:	26071463          	bnez	a4,ffffffffc0203c68 <vmm_init+0x520>

    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
ffffffffc0203a04:	4581                	li	a1,0
ffffffffc0203a06:	854a                	mv	a0,s2
ffffffffc0203a08:	f55fd0ef          	jal	ra,ffffffffc020195c <page_remove>
    return pa2page(PDE_ADDR(pde));
ffffffffc0203a0c:	00093783          	ld	a5,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0203a10:	0000e717          	auipc	a4,0xe
ffffffffc0203a14:	b1873703          	ld	a4,-1256(a4) # ffffffffc0211528 <npage>
    return pa2page(PDE_ADDR(pde));
ffffffffc0203a18:	078a                	slli	a5,a5,0x2
ffffffffc0203a1a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203a1c:	26e7f663          	bgeu	a5,a4,ffffffffc0203c88 <vmm_init+0x540>
    return &pages[PPN(pa) - nbase];
ffffffffc0203a20:	00003717          	auipc	a4,0x3
ffffffffc0203a24:	a0073703          	ld	a4,-1536(a4) # ffffffffc0206420 <nbase>
ffffffffc0203a28:	8f99                	sub	a5,a5,a4
ffffffffc0203a2a:	00379713          	slli	a4,a5,0x3
ffffffffc0203a2e:	97ba                	add	a5,a5,a4
ffffffffc0203a30:	078e                	slli	a5,a5,0x3

    free_page(pde2page(pgdir[0]));
ffffffffc0203a32:	0000e517          	auipc	a0,0xe
ffffffffc0203a36:	afe53503          	ld	a0,-1282(a0) # ffffffffc0211530 <pages>
ffffffffc0203a3a:	953e                	add	a0,a0,a5
ffffffffc0203a3c:	4585                	li	a1,1
ffffffffc0203a3e:	c55fd0ef          	jal	ra,ffffffffc0201692 <free_pages>
    return listelm->next;
ffffffffc0203a42:	6408                	ld	a0,8(s0)

    pgdir[0] = 0;
ffffffffc0203a44:	00093023          	sd	zero,0(s2)

    mm->pgdir = NULL;
ffffffffc0203a48:	00043c23          	sd	zero,24(s0)
    while ((le = list_next(list)) != list)
ffffffffc0203a4c:	00a40e63          	beq	s0,a0,ffffffffc0203a68 <vmm_init+0x320>
    __list_del(listelm->prev, listelm->next);
ffffffffc0203a50:	6118                	ld	a4,0(a0)
ffffffffc0203a52:	651c                	ld	a5,8(a0)
        kfree(le2vma(le, list_link), sizeof(struct vma_struct)); // kfree vma
ffffffffc0203a54:	03000593          	li	a1,48
ffffffffc0203a58:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc0203a5a:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0203a5c:	e398                	sd	a4,0(a5)
ffffffffc0203a5e:	e15fe0ef          	jal	ra,ffffffffc0202872 <kfree>
    return listelm->next;
ffffffffc0203a62:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list)
ffffffffc0203a64:	fea416e3          	bne	s0,a0,ffffffffc0203a50 <vmm_init+0x308>
    kfree(mm, sizeof(struct mm_struct)); // kfree mm
ffffffffc0203a68:	03000593          	li	a1,48
ffffffffc0203a6c:	8522                	mv	a0,s0
ffffffffc0203a6e:	e05fe0ef          	jal	ra,ffffffffc0202872 <kfree>
    mm_destroy(mm);

    check_mm_struct = NULL;
    nr_free_pages_store--; // szx : Sv39第二级页表多占了一个内存页，所以执行此操作
ffffffffc0203a72:	14fd                	addi	s1,s1,-1
    check_mm_struct = NULL;
ffffffffc0203a74:	0000e797          	auipc	a5,0xe
ffffffffc0203a78:	ae07b623          	sd	zero,-1300(a5) # ffffffffc0211560 <check_mm_struct>

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203a7c:	c57fd0ef          	jal	ra,ffffffffc02016d2 <nr_free_pages>
ffffffffc0203a80:	22a49063          	bne	s1,a0,ffffffffc0203ca0 <vmm_init+0x558>

    cprintf("check_pgfault() succeeded!\n");
ffffffffc0203a84:	00002517          	auipc	a0,0x2
ffffffffc0203a88:	62450513          	addi	a0,a0,1572 # ffffffffc02060a8 <default_pmm_manager+0xe98>
ffffffffc0203a8c:	e2efc0ef          	jal	ra,ffffffffc02000ba <cprintf>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203a90:	c43fd0ef          	jal	ra,ffffffffc02016d2 <nr_free_pages>
    nr_free_pages_store--; // szx : Sv39三级页表多占一个内存页，所以执行此操作
ffffffffc0203a94:	19fd                	addi	s3,s3,-1
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203a96:	22a99563          	bne	s3,a0,ffffffffc0203cc0 <vmm_init+0x578>
}
ffffffffc0203a9a:	6406                	ld	s0,64(sp)
ffffffffc0203a9c:	60a6                	ld	ra,72(sp)
ffffffffc0203a9e:	74e2                	ld	s1,56(sp)
ffffffffc0203aa0:	7942                	ld	s2,48(sp)
ffffffffc0203aa2:	79a2                	ld	s3,40(sp)
ffffffffc0203aa4:	7a02                	ld	s4,32(sp)
ffffffffc0203aa6:	6ae2                	ld	s5,24(sp)
ffffffffc0203aa8:	6b42                	ld	s6,16(sp)
ffffffffc0203aaa:	6ba2                	ld	s7,8(sp)
    cprintf("check_vmm() succeeded.\n");
ffffffffc0203aac:	00002517          	auipc	a0,0x2
ffffffffc0203ab0:	61c50513          	addi	a0,a0,1564 # ffffffffc02060c8 <default_pmm_manager+0xeb8>
}
ffffffffc0203ab4:	6161                	addi	sp,sp,80
    cprintf("check_vmm() succeeded.\n");
ffffffffc0203ab6:	e04fc06f          	j	ffffffffc02000ba <cprintf>
            swap_init_mm(mm);
ffffffffc0203aba:	d0aff0ef          	jal	ra,ffffffffc0202fc4 <swap_init_mm>
ffffffffc0203abe:	b5d1                	j	ffffffffc0203982 <vmm_init+0x23a>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0203ac0:	00002697          	auipc	a3,0x2
ffffffffc0203ac4:	44868693          	addi	a3,a3,1096 # ffffffffc0205f08 <default_pmm_manager+0xcf8>
ffffffffc0203ac8:	00001617          	auipc	a2,0x1
ffffffffc0203acc:	39860613          	addi	a2,a2,920 # ffffffffc0204e60 <commands+0x760>
ffffffffc0203ad0:	0f500593          	li	a1,245
ffffffffc0203ad4:	00002517          	auipc	a0,0x2
ffffffffc0203ad8:	3ac50513          	addi	a0,a0,940 # ffffffffc0205e80 <default_pmm_manager+0xc70>
ffffffffc0203adc:	899fc0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert(vma2->vm_start == i && vma2->vm_end == i + 2);
ffffffffc0203ae0:	00002697          	auipc	a3,0x2
ffffffffc0203ae4:	4e068693          	addi	a3,a3,1248 # ffffffffc0205fc0 <default_pmm_manager+0xdb0>
ffffffffc0203ae8:	00001617          	auipc	a2,0x1
ffffffffc0203aec:	37860613          	addi	a2,a2,888 # ffffffffc0204e60 <commands+0x760>
ffffffffc0203af0:	10700593          	li	a1,263
ffffffffc0203af4:	00002517          	auipc	a0,0x2
ffffffffc0203af8:	38c50513          	addi	a0,a0,908 # ffffffffc0205e80 <default_pmm_manager+0xc70>
ffffffffc0203afc:	879fc0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert(vma1->vm_start == i && vma1->vm_end == i + 2);
ffffffffc0203b00:	00002697          	auipc	a3,0x2
ffffffffc0203b04:	49068693          	addi	a3,a3,1168 # ffffffffc0205f90 <default_pmm_manager+0xd80>
ffffffffc0203b08:	00001617          	auipc	a2,0x1
ffffffffc0203b0c:	35860613          	addi	a2,a2,856 # ffffffffc0204e60 <commands+0x760>
ffffffffc0203b10:	10600593          	li	a1,262
ffffffffc0203b14:	00002517          	auipc	a0,0x2
ffffffffc0203b18:	36c50513          	addi	a0,a0,876 # ffffffffc0205e80 <default_pmm_manager+0xc70>
ffffffffc0203b1c:	859fc0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert(le != &(mm->mmap_list));
ffffffffc0203b20:	00002697          	auipc	a3,0x2
ffffffffc0203b24:	3d068693          	addi	a3,a3,976 # ffffffffc0205ef0 <default_pmm_manager+0xce0>
ffffffffc0203b28:	00001617          	auipc	a2,0x1
ffffffffc0203b2c:	33860613          	addi	a2,a2,824 # ffffffffc0204e60 <commands+0x760>
ffffffffc0203b30:	0f300593          	li	a1,243
ffffffffc0203b34:	00002517          	auipc	a0,0x2
ffffffffc0203b38:	34c50513          	addi	a0,a0,844 # ffffffffc0205e80 <default_pmm_manager+0xc70>
ffffffffc0203b3c:	839fc0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert(vma1 != NULL);
ffffffffc0203b40:	00002697          	auipc	a3,0x2
ffffffffc0203b44:	40068693          	addi	a3,a3,1024 # ffffffffc0205f40 <default_pmm_manager+0xd30>
ffffffffc0203b48:	00001617          	auipc	a2,0x1
ffffffffc0203b4c:	31860613          	addi	a2,a2,792 # ffffffffc0204e60 <commands+0x760>
ffffffffc0203b50:	0fc00593          	li	a1,252
ffffffffc0203b54:	00002517          	auipc	a0,0x2
ffffffffc0203b58:	32c50513          	addi	a0,a0,812 # ffffffffc0205e80 <default_pmm_manager+0xc70>
ffffffffc0203b5c:	819fc0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert(vma2 != NULL);
ffffffffc0203b60:	00002697          	auipc	a3,0x2
ffffffffc0203b64:	3f068693          	addi	a3,a3,1008 # ffffffffc0205f50 <default_pmm_manager+0xd40>
ffffffffc0203b68:	00001617          	auipc	a2,0x1
ffffffffc0203b6c:	2f860613          	addi	a2,a2,760 # ffffffffc0204e60 <commands+0x760>
ffffffffc0203b70:	0fe00593          	li	a1,254
ffffffffc0203b74:	00002517          	auipc	a0,0x2
ffffffffc0203b78:	30c50513          	addi	a0,a0,780 # ffffffffc0205e80 <default_pmm_manager+0xc70>
ffffffffc0203b7c:	ff8fc0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert(vma3 == NULL);
ffffffffc0203b80:	00002697          	auipc	a3,0x2
ffffffffc0203b84:	3e068693          	addi	a3,a3,992 # ffffffffc0205f60 <default_pmm_manager+0xd50>
ffffffffc0203b88:	00001617          	auipc	a2,0x1
ffffffffc0203b8c:	2d860613          	addi	a2,a2,728 # ffffffffc0204e60 <commands+0x760>
ffffffffc0203b90:	10000593          	li	a1,256
ffffffffc0203b94:	00002517          	auipc	a0,0x2
ffffffffc0203b98:	2ec50513          	addi	a0,a0,748 # ffffffffc0205e80 <default_pmm_manager+0xc70>
ffffffffc0203b9c:	fd8fc0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert(vma4 == NULL);
ffffffffc0203ba0:	00002697          	auipc	a3,0x2
ffffffffc0203ba4:	3d068693          	addi	a3,a3,976 # ffffffffc0205f70 <default_pmm_manager+0xd60>
ffffffffc0203ba8:	00001617          	auipc	a2,0x1
ffffffffc0203bac:	2b860613          	addi	a2,a2,696 # ffffffffc0204e60 <commands+0x760>
ffffffffc0203bb0:	10200593          	li	a1,258
ffffffffc0203bb4:	00002517          	auipc	a0,0x2
ffffffffc0203bb8:	2cc50513          	addi	a0,a0,716 # ffffffffc0205e80 <default_pmm_manager+0xc70>
ffffffffc0203bbc:	fb8fc0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert(vma5 == NULL);
ffffffffc0203bc0:	00002697          	auipc	a3,0x2
ffffffffc0203bc4:	3c068693          	addi	a3,a3,960 # ffffffffc0205f80 <default_pmm_manager+0xd70>
ffffffffc0203bc8:	00001617          	auipc	a2,0x1
ffffffffc0203bcc:	29860613          	addi	a2,a2,664 # ffffffffc0204e60 <commands+0x760>
ffffffffc0203bd0:	10400593          	li	a1,260
ffffffffc0203bd4:	00002517          	auipc	a0,0x2
ffffffffc0203bd8:	2ac50513          	addi	a0,a0,684 # ffffffffc0205e80 <default_pmm_manager+0xc70>
ffffffffc0203bdc:	f98fc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgdir[0] == 0);
ffffffffc0203be0:	00002697          	auipc	a3,0x2
ffffffffc0203be4:	d5068693          	addi	a3,a3,-688 # ffffffffc0205930 <default_pmm_manager+0x720>
ffffffffc0203be8:	00001617          	auipc	a2,0x1
ffffffffc0203bec:	27860613          	addi	a2,a2,632 # ffffffffc0204e60 <commands+0x760>
ffffffffc0203bf0:	12900593          	li	a1,297
ffffffffc0203bf4:	00002517          	auipc	a0,0x2
ffffffffc0203bf8:	28c50513          	addi	a0,a0,652 # ffffffffc0205e80 <default_pmm_manager+0xc70>
ffffffffc0203bfc:	f78fc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(check_mm_struct != NULL);
ffffffffc0203c00:	00002697          	auipc	a3,0x2
ffffffffc0203c04:	4e068693          	addi	a3,a3,1248 # ffffffffc02060e0 <default_pmm_manager+0xed0>
ffffffffc0203c08:	00001617          	auipc	a2,0x1
ffffffffc0203c0c:	25860613          	addi	a2,a2,600 # ffffffffc0204e60 <commands+0x760>
ffffffffc0203c10:	12600593          	li	a1,294
ffffffffc0203c14:	00002517          	auipc	a0,0x2
ffffffffc0203c18:	26c50513          	addi	a0,a0,620 # ffffffffc0205e80 <default_pmm_manager+0xc70>
    check_mm_struct = mm_create();
ffffffffc0203c1c:	0000e797          	auipc	a5,0xe
ffffffffc0203c20:	9407b223          	sd	zero,-1724(a5) # ffffffffc0211560 <check_mm_struct>
    assert(check_mm_struct != NULL);
ffffffffc0203c24:	f50fc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(vma != NULL);
ffffffffc0203c28:	00002697          	auipc	a3,0x2
ffffffffc0203c2c:	d1868693          	addi	a3,a3,-744 # ffffffffc0205940 <default_pmm_manager+0x730>
ffffffffc0203c30:	00001617          	auipc	a2,0x1
ffffffffc0203c34:	23060613          	addi	a2,a2,560 # ffffffffc0204e60 <commands+0x760>
ffffffffc0203c38:	12d00593          	li	a1,301
ffffffffc0203c3c:	00002517          	auipc	a0,0x2
ffffffffc0203c40:	24450513          	addi	a0,a0,580 # ffffffffc0205e80 <default_pmm_manager+0xc70>
ffffffffc0203c44:	f30fc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(find_vma(mm, addr) == vma);
ffffffffc0203c48:	00002697          	auipc	a3,0x2
ffffffffc0203c4c:	43068693          	addi	a3,a3,1072 # ffffffffc0206078 <default_pmm_manager+0xe68>
ffffffffc0203c50:	00001617          	auipc	a2,0x1
ffffffffc0203c54:	21060613          	addi	a2,a2,528 # ffffffffc0204e60 <commands+0x760>
ffffffffc0203c58:	13200593          	li	a1,306
ffffffffc0203c5c:	00002517          	auipc	a0,0x2
ffffffffc0203c60:	22450513          	addi	a0,a0,548 # ffffffffc0205e80 <default_pmm_manager+0xc70>
ffffffffc0203c64:	f10fc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(sum == 0);
ffffffffc0203c68:	00002697          	auipc	a3,0x2
ffffffffc0203c6c:	43068693          	addi	a3,a3,1072 # ffffffffc0206098 <default_pmm_manager+0xe88>
ffffffffc0203c70:	00001617          	auipc	a2,0x1
ffffffffc0203c74:	1f060613          	addi	a2,a2,496 # ffffffffc0204e60 <commands+0x760>
ffffffffc0203c78:	13e00593          	li	a1,318
ffffffffc0203c7c:	00002517          	auipc	a0,0x2
ffffffffc0203c80:	20450513          	addi	a0,a0,516 # ffffffffc0205e80 <default_pmm_manager+0xc70>
ffffffffc0203c84:	ef0fc0ef          	jal	ra,ffffffffc0200374 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0203c88:	00001617          	auipc	a2,0x1
ffffffffc0203c8c:	5c060613          	addi	a2,a2,1472 # ffffffffc0205248 <default_pmm_manager+0x38>
ffffffffc0203c90:	06500593          	li	a1,101
ffffffffc0203c94:	00001517          	auipc	a0,0x1
ffffffffc0203c98:	5d450513          	addi	a0,a0,1492 # ffffffffc0205268 <default_pmm_manager+0x58>
ffffffffc0203c9c:	ed8fc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203ca0:	00002697          	auipc	a3,0x2
ffffffffc0203ca4:	39068693          	addi	a3,a3,912 # ffffffffc0206030 <default_pmm_manager+0xe20>
ffffffffc0203ca8:	00001617          	auipc	a2,0x1
ffffffffc0203cac:	1b860613          	addi	a2,a2,440 # ffffffffc0204e60 <commands+0x760>
ffffffffc0203cb0:	14c00593          	li	a1,332
ffffffffc0203cb4:	00002517          	auipc	a0,0x2
ffffffffc0203cb8:	1cc50513          	addi	a0,a0,460 # ffffffffc0205e80 <default_pmm_manager+0xc70>
ffffffffc0203cbc:	eb8fc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203cc0:	00002697          	auipc	a3,0x2
ffffffffc0203cc4:	37068693          	addi	a3,a3,880 # ffffffffc0206030 <default_pmm_manager+0xe20>
ffffffffc0203cc8:	00001617          	auipc	a2,0x1
ffffffffc0203ccc:	19860613          	addi	a2,a2,408 # ffffffffc0204e60 <commands+0x760>
ffffffffc0203cd0:	0d100593          	li	a1,209
ffffffffc0203cd4:	00002517          	auipc	a0,0x2
ffffffffc0203cd8:	1ac50513          	addi	a0,a0,428 # ffffffffc0205e80 <default_pmm_manager+0xc70>
ffffffffc0203cdc:	e98fc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(mm != NULL);
ffffffffc0203ce0:	00002697          	auipc	a3,0x2
ffffffffc0203ce4:	c2868693          	addi	a3,a3,-984 # ffffffffc0205908 <default_pmm_manager+0x6f8>
ffffffffc0203ce8:	00001617          	auipc	a2,0x1
ffffffffc0203cec:	17860613          	addi	a2,a2,376 # ffffffffc0204e60 <commands+0x760>
ffffffffc0203cf0:	0dc00593          	li	a1,220
ffffffffc0203cf4:	00002517          	auipc	a0,0x2
ffffffffc0203cf8:	18c50513          	addi	a0,a0,396 # ffffffffc0205e80 <default_pmm_manager+0xc70>
ffffffffc0203cfc:	e78fc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203d00:	00002697          	auipc	a3,0x2
ffffffffc0203d04:	33068693          	addi	a3,a3,816 # ffffffffc0206030 <default_pmm_manager+0xe20>
ffffffffc0203d08:	00001617          	auipc	a2,0x1
ffffffffc0203d0c:	15860613          	addi	a2,a2,344 # ffffffffc0204e60 <commands+0x760>
ffffffffc0203d10:	11600593          	li	a1,278
ffffffffc0203d14:	00002517          	auipc	a0,0x2
ffffffffc0203d18:	16c50513          	addi	a0,a0,364 # ffffffffc0205e80 <default_pmm_manager+0xc70>
ffffffffc0203d1c:	e58fc0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0203d20 <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr)
{
ffffffffc0203d20:	7179                	addi	sp,sp,-48
    int ret = -E_INVAL;
    // try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc0203d22:	85b2                	mv	a1,a2
{
ffffffffc0203d24:	f022                	sd	s0,32(sp)
ffffffffc0203d26:	ec26                	sd	s1,24(sp)
ffffffffc0203d28:	f406                	sd	ra,40(sp)
ffffffffc0203d2a:	e84a                	sd	s2,16(sp)
ffffffffc0203d2c:	8432                	mv	s0,a2
ffffffffc0203d2e:	84aa                	mv	s1,a0
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc0203d30:	8d3ff0ef          	jal	ra,ffffffffc0203602 <find_vma>

    pgfault_num++;
ffffffffc0203d34:	0000e797          	auipc	a5,0xe
ffffffffc0203d38:	8347a783          	lw	a5,-1996(a5) # ffffffffc0211568 <pgfault_num>
ffffffffc0203d3c:	2785                	addiw	a5,a5,1
ffffffffc0203d3e:	0000e717          	auipc	a4,0xe
ffffffffc0203d42:	82f72523          	sw	a5,-2006(a4) # ffffffffc0211568 <pgfault_num>
    // If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr)
ffffffffc0203d46:	c159                	beqz	a0,ffffffffc0203dcc <do_pgfault+0xac>
ffffffffc0203d48:	651c                	ld	a5,8(a0)
ffffffffc0203d4a:	08f46163          	bltu	s0,a5,ffffffffc0203dcc <do_pgfault+0xac>
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
    if (vma->vm_flags & VM_WRITE)
ffffffffc0203d4e:	6d1c                	ld	a5,24(a0)
    uint32_t perm = PTE_U;
ffffffffc0203d50:	4941                	li	s2,16
    if (vma->vm_flags & VM_WRITE)
ffffffffc0203d52:	8b89                	andi	a5,a5,2
ffffffffc0203d54:	ebb1                	bnez	a5,ffffffffc0203da8 <do_pgfault+0x88>
    {
        perm |= (PTE_R | PTE_W);
    }
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0203d56:	75fd                	lui	a1,0xfffff
     * VARIABLES:
     *   mm->pgdir : the PDT of these vma
     *
     */

    ptep = get_pte(mm->pgdir, addr, 1); //(1) try to find a pte, if pte's
ffffffffc0203d58:	6c88                	ld	a0,24(s1)
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0203d5a:	8c6d                	and	s0,s0,a1
    ptep = get_pte(mm->pgdir, addr, 1); //(1) try to find a pte, if pte's
ffffffffc0203d5c:	85a2                	mv	a1,s0
ffffffffc0203d5e:	4605                	li	a2,1
ffffffffc0203d60:	9adfd0ef          	jal	ra,ffffffffc020170c <get_pte>
                                        // PT(Page Table) isn't existed, then
                                        // create a PT.
    if (*ptep == 0)
ffffffffc0203d64:	610c                	ld	a1,0(a0)
ffffffffc0203d66:	c1b9                	beqz	a1,ffffffffc0203dac <do_pgfault+0x8c>
         *    swap_in(mm, addr, &page) : 分配一个内存页，然后根据
         *    PTE中的swap条目的addr，找到磁盘页的地址，将磁盘页的内容读入这个内存页
         *    page_insert ： 建立一个Page的phy addr与线性addr la的映射
         *    swap_map_swappable ： 设置页面可交换
         */
        if (swap_init_ok)
ffffffffc0203d68:	0000d797          	auipc	a5,0xd
ffffffffc0203d6c:	7f07a783          	lw	a5,2032(a5) # ffffffffc0211558 <swap_init_ok>
ffffffffc0203d70:	c7bd                	beqz	a5,ffffffffc0203dde <do_pgfault+0xbe>
            //(2) According to the mm,
            // addr AND page, setup the
            // map of phy addr <--->
            // logical addr
            //(3) make the page swappable.
            swap_in(mm, addr, &page);                 // 分配一个内存页并从磁盘上的交换文件加载数据到该内存页
ffffffffc0203d72:	85a2                	mv	a1,s0
ffffffffc0203d74:	0030                	addi	a2,sp,8
ffffffffc0203d76:	8526                	mv	a0,s1
            struct Page *page = NULL;
ffffffffc0203d78:	e402                	sd	zero,8(sp)
            swap_in(mm, addr, &page);                 // 分配一个内存页并从磁盘上的交换文件加载数据到该内存页
ffffffffc0203d7a:	b76ff0ef          	jal	ra,ffffffffc02030f0 <swap_in>
            page_insert(mm->pgdir, page, addr, perm); // 建立内存页 page 的物理地址和线性地址 addr 之间的映射
ffffffffc0203d7e:	65a2                	ld	a1,8(sp)
ffffffffc0203d80:	6c88                	ld	a0,24(s1)
ffffffffc0203d82:	86ca                	mv	a3,s2
ffffffffc0203d84:	8622                	mv	a2,s0
ffffffffc0203d86:	c71fd0ef          	jal	ra,ffffffffc02019f6 <page_insert>
            swap_map_swappable(mm, addr, page, 1);    // 将页面标记为可交换
ffffffffc0203d8a:	6622                	ld	a2,8(sp)
ffffffffc0203d8c:	4685                	li	a3,1
ffffffffc0203d8e:	85a2                	mv	a1,s0
ffffffffc0203d90:	8526                	mv	a0,s1
ffffffffc0203d92:	a3eff0ef          	jal	ra,ffffffffc0202fd0 <swap_map_swappable>
            page->pra_vaddr = addr;                   // 跟踪页面映射的线性地址
ffffffffc0203d96:	67a2                	ld	a5,8(sp)
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
            goto failed;
        }
    }

    ret = 0;
ffffffffc0203d98:	4501                	li	a0,0
            page->pra_vaddr = addr;                   // 跟踪页面映射的线性地址
ffffffffc0203d9a:	e3a0                	sd	s0,64(a5)
failed:
    return ret;
}
ffffffffc0203d9c:	70a2                	ld	ra,40(sp)
ffffffffc0203d9e:	7402                	ld	s0,32(sp)
ffffffffc0203da0:	64e2                	ld	s1,24(sp)
ffffffffc0203da2:	6942                	ld	s2,16(sp)
ffffffffc0203da4:	6145                	addi	sp,sp,48
ffffffffc0203da6:	8082                	ret
        perm |= (PTE_R | PTE_W);
ffffffffc0203da8:	4959                	li	s2,22
ffffffffc0203daa:	b775                	j	ffffffffc0203d56 <do_pgfault+0x36>
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL)
ffffffffc0203dac:	6c88                	ld	a0,24(s1)
ffffffffc0203dae:	864a                	mv	a2,s2
ffffffffc0203db0:	85a2                	mv	a1,s0
ffffffffc0203db2:	94ffe0ef          	jal	ra,ffffffffc0202700 <pgdir_alloc_page>
ffffffffc0203db6:	87aa                	mv	a5,a0
    ret = 0;
ffffffffc0203db8:	4501                	li	a0,0
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL)
ffffffffc0203dba:	f3ed                	bnez	a5,ffffffffc0203d9c <do_pgfault+0x7c>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
ffffffffc0203dbc:	00002517          	auipc	a0,0x2
ffffffffc0203dc0:	36c50513          	addi	a0,a0,876 # ffffffffc0206128 <default_pmm_manager+0xf18>
ffffffffc0203dc4:	af6fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
    ret = -E_NO_MEM;
ffffffffc0203dc8:	5571                	li	a0,-4
            goto failed;
ffffffffc0203dca:	bfc9                	j	ffffffffc0203d9c <do_pgfault+0x7c>
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
ffffffffc0203dcc:	85a2                	mv	a1,s0
ffffffffc0203dce:	00002517          	auipc	a0,0x2
ffffffffc0203dd2:	32a50513          	addi	a0,a0,810 # ffffffffc02060f8 <default_pmm_manager+0xee8>
ffffffffc0203dd6:	ae4fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
    int ret = -E_INVAL;
ffffffffc0203dda:	5575                	li	a0,-3
        goto failed;
ffffffffc0203ddc:	b7c1                	j	ffffffffc0203d9c <do_pgfault+0x7c>
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
ffffffffc0203dde:	00002517          	auipc	a0,0x2
ffffffffc0203de2:	37250513          	addi	a0,a0,882 # ffffffffc0206150 <default_pmm_manager+0xf40>
ffffffffc0203de6:	ad4fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
    ret = -E_NO_MEM;
ffffffffc0203dea:	5571                	li	a0,-4
            goto failed;
ffffffffc0203dec:	bf45                	j	ffffffffc0203d9c <do_pgfault+0x7c>

ffffffffc0203dee <swapfs_init>:
 * @brief 初始化交换文件系统
 * 
 * 这个函数会检查交换设备是否有效，并计算出交换设备上最大的交换偏移量
 */
void
swapfs_init(void) {
ffffffffc0203dee:	1141                	addi	sp,sp,-16
    // 确保页面大小是扇区大小的整数倍
    static_assert((PGSIZE % SECTSIZE) == 0);
    // 如果交换设备无效，则panic
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0203df0:	4505                	li	a0,1
swapfs_init(void) {
ffffffffc0203df2:	e406                	sd	ra,8(sp)
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0203df4:	ea0fc0ef          	jal	ra,ffffffffc0200494 <ide_device_valid>
ffffffffc0203df8:	cd01                	beqz	a0,ffffffffc0203e10 <swapfs_init+0x22>
        panic("swap fs isn't available.\n");
    }
    // 计算最大交换偏移量
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0203dfa:	4505                	li	a0,1
ffffffffc0203dfc:	e9efc0ef          	jal	ra,ffffffffc020049a <ide_device_size>
}
ffffffffc0203e00:	60a2                	ld	ra,8(sp)
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0203e02:	810d                	srli	a0,a0,0x3
ffffffffc0203e04:	0000d797          	auipc	a5,0xd
ffffffffc0203e08:	74a7b223          	sd	a0,1860(a5) # ffffffffc0211548 <max_swap_offset>
}
ffffffffc0203e0c:	0141                	addi	sp,sp,16
ffffffffc0203e0e:	8082                	ret
        panic("swap fs isn't available.\n");
ffffffffc0203e10:	00002617          	auipc	a2,0x2
ffffffffc0203e14:	36860613          	addi	a2,a2,872 # ffffffffc0206178 <default_pmm_manager+0xf68>
ffffffffc0203e18:	45d1                	li	a1,20
ffffffffc0203e1a:	00002517          	auipc	a0,0x2
ffffffffc0203e1e:	37e50513          	addi	a0,a0,894 # ffffffffc0206198 <default_pmm_manager+0xf88>
ffffffffc0203e22:	d52fc0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0203e26 <swapfs_read>:
 * @param entry 要读取的页面的索引
 * @param page 读取到的页面将存储在这个Page结构体中
 * @return 成功返回0，失败返回负值
 */
int
swapfs_read(swap_entry_t entry, struct Page *page) {
ffffffffc0203e26:	1141                	addi	sp,sp,-16
ffffffffc0203e28:	e406                	sd	ra,8(sp)
    // 从交换设备中读取数据
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203e2a:	00855793          	srli	a5,a0,0x8
ffffffffc0203e2e:	c3a5                	beqz	a5,ffffffffc0203e8e <swapfs_read+0x68>
ffffffffc0203e30:	0000d717          	auipc	a4,0xd
ffffffffc0203e34:	71873703          	ld	a4,1816(a4) # ffffffffc0211548 <max_swap_offset>
ffffffffc0203e38:	04e7fb63          	bgeu	a5,a4,ffffffffc0203e8e <swapfs_read+0x68>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203e3c:	0000d617          	auipc	a2,0xd
ffffffffc0203e40:	6f463603          	ld	a2,1780(a2) # ffffffffc0211530 <pages>
ffffffffc0203e44:	8d91                	sub	a1,a1,a2
ffffffffc0203e46:	4035d613          	srai	a2,a1,0x3
ffffffffc0203e4a:	00002597          	auipc	a1,0x2
ffffffffc0203e4e:	5ce5b583          	ld	a1,1486(a1) # ffffffffc0206418 <error_string+0x38>
ffffffffc0203e52:	02b60633          	mul	a2,a2,a1
ffffffffc0203e56:	0037959b          	slliw	a1,a5,0x3
ffffffffc0203e5a:	00002797          	auipc	a5,0x2
ffffffffc0203e5e:	5c67b783          	ld	a5,1478(a5) # ffffffffc0206420 <nbase>
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203e62:	0000d717          	auipc	a4,0xd
ffffffffc0203e66:	6c673703          	ld	a4,1734(a4) # ffffffffc0211528 <npage>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203e6a:	963e                	add	a2,a2,a5
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203e6c:	00c61793          	slli	a5,a2,0xc
ffffffffc0203e70:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0203e72:	0632                	slli	a2,a2,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203e74:	02e7fa63          	bgeu	a5,a4,ffffffffc0203ea8 <swapfs_read+0x82>
}
ffffffffc0203e78:	60a2                	ld	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203e7a:	0000d797          	auipc	a5,0xd
ffffffffc0203e7e:	6c67b783          	ld	a5,1734(a5) # ffffffffc0211540 <va_pa_offset>
ffffffffc0203e82:	46a1                	li	a3,8
ffffffffc0203e84:	963e                	add	a2,a2,a5
ffffffffc0203e86:	4505                	li	a0,1
}
ffffffffc0203e88:	0141                	addi	sp,sp,16
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203e8a:	e16fc06f          	j	ffffffffc02004a0 <ide_read_secs>
ffffffffc0203e8e:	86aa                	mv	a3,a0
ffffffffc0203e90:	00002617          	auipc	a2,0x2
ffffffffc0203e94:	32060613          	addi	a2,a2,800 # ffffffffc02061b0 <default_pmm_manager+0xfa0>
ffffffffc0203e98:	02400593          	li	a1,36
ffffffffc0203e9c:	00002517          	auipc	a0,0x2
ffffffffc0203ea0:	2fc50513          	addi	a0,a0,764 # ffffffffc0206198 <default_pmm_manager+0xf88>
ffffffffc0203ea4:	cd0fc0ef          	jal	ra,ffffffffc0200374 <__panic>
ffffffffc0203ea8:	86b2                	mv	a3,a2
ffffffffc0203eaa:	06a00593          	li	a1,106
ffffffffc0203eae:	00001617          	auipc	a2,0x1
ffffffffc0203eb2:	3f260613          	addi	a2,a2,1010 # ffffffffc02052a0 <default_pmm_manager+0x90>
ffffffffc0203eb6:	00001517          	auipc	a0,0x1
ffffffffc0203eba:	3b250513          	addi	a0,a0,946 # ffffffffc0205268 <default_pmm_manager+0x58>
ffffffffc0203ebe:	cb6fc0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0203ec2 <swapfs_write>:
 * @param entry 要写入的页面的索引
 * @param page 要写入的页面
 * @return 成功返回0，失败返回负值
 */
int
swapfs_write(swap_entry_t entry, struct Page *page) {
ffffffffc0203ec2:	1141                	addi	sp,sp,-16
ffffffffc0203ec4:	e406                	sd	ra,8(sp)
    // 将数据写入到交换设备中
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203ec6:	00855793          	srli	a5,a0,0x8
ffffffffc0203eca:	c3a5                	beqz	a5,ffffffffc0203f2a <swapfs_write+0x68>
ffffffffc0203ecc:	0000d717          	auipc	a4,0xd
ffffffffc0203ed0:	67c73703          	ld	a4,1660(a4) # ffffffffc0211548 <max_swap_offset>
ffffffffc0203ed4:	04e7fb63          	bgeu	a5,a4,ffffffffc0203f2a <swapfs_write+0x68>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203ed8:	0000d617          	auipc	a2,0xd
ffffffffc0203edc:	65863603          	ld	a2,1624(a2) # ffffffffc0211530 <pages>
ffffffffc0203ee0:	8d91                	sub	a1,a1,a2
ffffffffc0203ee2:	4035d613          	srai	a2,a1,0x3
ffffffffc0203ee6:	00002597          	auipc	a1,0x2
ffffffffc0203eea:	5325b583          	ld	a1,1330(a1) # ffffffffc0206418 <error_string+0x38>
ffffffffc0203eee:	02b60633          	mul	a2,a2,a1
ffffffffc0203ef2:	0037959b          	slliw	a1,a5,0x3
ffffffffc0203ef6:	00002797          	auipc	a5,0x2
ffffffffc0203efa:	52a7b783          	ld	a5,1322(a5) # ffffffffc0206420 <nbase>
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203efe:	0000d717          	auipc	a4,0xd
ffffffffc0203f02:	62a73703          	ld	a4,1578(a4) # ffffffffc0211528 <npage>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203f06:	963e                	add	a2,a2,a5
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203f08:	00c61793          	slli	a5,a2,0xc
ffffffffc0203f0c:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0203f0e:	0632                	slli	a2,a2,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203f10:	02e7fa63          	bgeu	a5,a4,ffffffffc0203f44 <swapfs_write+0x82>
}
ffffffffc0203f14:	60a2                	ld	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203f16:	0000d797          	auipc	a5,0xd
ffffffffc0203f1a:	62a7b783          	ld	a5,1578(a5) # ffffffffc0211540 <va_pa_offset>
ffffffffc0203f1e:	46a1                	li	a3,8
ffffffffc0203f20:	963e                	add	a2,a2,a5
ffffffffc0203f22:	4505                	li	a0,1
}
ffffffffc0203f24:	0141                	addi	sp,sp,16
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203f26:	d9efc06f          	j	ffffffffc02004c4 <ide_write_secs>
ffffffffc0203f2a:	86aa                	mv	a3,a0
ffffffffc0203f2c:	00002617          	auipc	a2,0x2
ffffffffc0203f30:	28460613          	addi	a2,a2,644 # ffffffffc02061b0 <default_pmm_manager+0xfa0>
ffffffffc0203f34:	03100593          	li	a1,49
ffffffffc0203f38:	00002517          	auipc	a0,0x2
ffffffffc0203f3c:	26050513          	addi	a0,a0,608 # ffffffffc0206198 <default_pmm_manager+0xf88>
ffffffffc0203f40:	c34fc0ef          	jal	ra,ffffffffc0200374 <__panic>
ffffffffc0203f44:	86b2                	mv	a3,a2
ffffffffc0203f46:	06a00593          	li	a1,106
ffffffffc0203f4a:	00001617          	auipc	a2,0x1
ffffffffc0203f4e:	35660613          	addi	a2,a2,854 # ffffffffc02052a0 <default_pmm_manager+0x90>
ffffffffc0203f52:	00001517          	auipc	a0,0x1
ffffffffc0203f56:	31650513          	addi	a0,a0,790 # ffffffffc0205268 <default_pmm_manager+0x58>
ffffffffc0203f5a:	c1afc0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0203f5e <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0203f5e:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0203f62:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0203f64:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0203f68:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0203f6a:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0203f6e:	f022                	sd	s0,32(sp)
ffffffffc0203f70:	ec26                	sd	s1,24(sp)
ffffffffc0203f72:	e84a                	sd	s2,16(sp)
ffffffffc0203f74:	f406                	sd	ra,40(sp)
ffffffffc0203f76:	e44e                	sd	s3,8(sp)
ffffffffc0203f78:	84aa                	mv	s1,a0
ffffffffc0203f7a:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0203f7c:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0203f80:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc0203f82:	03067e63          	bgeu	a2,a6,ffffffffc0203fbe <printnum+0x60>
ffffffffc0203f86:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc0203f88:	00805763          	blez	s0,ffffffffc0203f96 <printnum+0x38>
ffffffffc0203f8c:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0203f8e:	85ca                	mv	a1,s2
ffffffffc0203f90:	854e                	mv	a0,s3
ffffffffc0203f92:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0203f94:	fc65                	bnez	s0,ffffffffc0203f8c <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203f96:	1a02                	slli	s4,s4,0x20
ffffffffc0203f98:	00002797          	auipc	a5,0x2
ffffffffc0203f9c:	23878793          	addi	a5,a5,568 # ffffffffc02061d0 <default_pmm_manager+0xfc0>
ffffffffc0203fa0:	020a5a13          	srli	s4,s4,0x20
ffffffffc0203fa4:	9a3e                	add	s4,s4,a5
}
ffffffffc0203fa6:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203fa8:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0203fac:	70a2                	ld	ra,40(sp)
ffffffffc0203fae:	69a2                	ld	s3,8(sp)
ffffffffc0203fb0:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203fb2:	85ca                	mv	a1,s2
ffffffffc0203fb4:	87a6                	mv	a5,s1
}
ffffffffc0203fb6:	6942                	ld	s2,16(sp)
ffffffffc0203fb8:	64e2                	ld	s1,24(sp)
ffffffffc0203fba:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203fbc:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0203fbe:	03065633          	divu	a2,a2,a6
ffffffffc0203fc2:	8722                	mv	a4,s0
ffffffffc0203fc4:	f9bff0ef          	jal	ra,ffffffffc0203f5e <printnum>
ffffffffc0203fc8:	b7f9                	j	ffffffffc0203f96 <printnum+0x38>

ffffffffc0203fca <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0203fca:	7119                	addi	sp,sp,-128
ffffffffc0203fcc:	f4a6                	sd	s1,104(sp)
ffffffffc0203fce:	f0ca                	sd	s2,96(sp)
ffffffffc0203fd0:	ecce                	sd	s3,88(sp)
ffffffffc0203fd2:	e8d2                	sd	s4,80(sp)
ffffffffc0203fd4:	e4d6                	sd	s5,72(sp)
ffffffffc0203fd6:	e0da                	sd	s6,64(sp)
ffffffffc0203fd8:	fc5e                	sd	s7,56(sp)
ffffffffc0203fda:	f06a                	sd	s10,32(sp)
ffffffffc0203fdc:	fc86                	sd	ra,120(sp)
ffffffffc0203fde:	f8a2                	sd	s0,112(sp)
ffffffffc0203fe0:	f862                	sd	s8,48(sp)
ffffffffc0203fe2:	f466                	sd	s9,40(sp)
ffffffffc0203fe4:	ec6e                	sd	s11,24(sp)
ffffffffc0203fe6:	892a                	mv	s2,a0
ffffffffc0203fe8:	84ae                	mv	s1,a1
ffffffffc0203fea:	8d32                	mv	s10,a2
ffffffffc0203fec:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0203fee:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc0203ff2:	5b7d                	li	s6,-1
ffffffffc0203ff4:	00002a97          	auipc	s5,0x2
ffffffffc0203ff8:	210a8a93          	addi	s5,s5,528 # ffffffffc0206204 <default_pmm_manager+0xff4>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0203ffc:	00002b97          	auipc	s7,0x2
ffffffffc0204000:	3e4b8b93          	addi	s7,s7,996 # ffffffffc02063e0 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0204004:	000d4503          	lbu	a0,0(s10) # 80000 <kern_entry-0xffffffffc0180000>
ffffffffc0204008:	001d0413          	addi	s0,s10,1
ffffffffc020400c:	01350a63          	beq	a0,s3,ffffffffc0204020 <vprintfmt+0x56>
            if (ch == '\0') {
ffffffffc0204010:	c121                	beqz	a0,ffffffffc0204050 <vprintfmt+0x86>
            putch(ch, putdat);
ffffffffc0204012:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0204014:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc0204016:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0204018:	fff44503          	lbu	a0,-1(s0)
ffffffffc020401c:	ff351ae3          	bne	a0,s3,ffffffffc0204010 <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204020:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc0204024:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc0204028:	4c81                	li	s9,0
ffffffffc020402a:	4881                	li	a7,0
        width = precision = -1;
ffffffffc020402c:	5c7d                	li	s8,-1
ffffffffc020402e:	5dfd                	li	s11,-1
ffffffffc0204030:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
ffffffffc0204034:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204036:	fdd6059b          	addiw	a1,a2,-35
ffffffffc020403a:	0ff5f593          	zext.b	a1,a1
ffffffffc020403e:	00140d13          	addi	s10,s0,1
ffffffffc0204042:	04b56263          	bltu	a0,a1,ffffffffc0204086 <vprintfmt+0xbc>
ffffffffc0204046:	058a                	slli	a1,a1,0x2
ffffffffc0204048:	95d6                	add	a1,a1,s5
ffffffffc020404a:	4194                	lw	a3,0(a1)
ffffffffc020404c:	96d6                	add	a3,a3,s5
ffffffffc020404e:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0204050:	70e6                	ld	ra,120(sp)
ffffffffc0204052:	7446                	ld	s0,112(sp)
ffffffffc0204054:	74a6                	ld	s1,104(sp)
ffffffffc0204056:	7906                	ld	s2,96(sp)
ffffffffc0204058:	69e6                	ld	s3,88(sp)
ffffffffc020405a:	6a46                	ld	s4,80(sp)
ffffffffc020405c:	6aa6                	ld	s5,72(sp)
ffffffffc020405e:	6b06                	ld	s6,64(sp)
ffffffffc0204060:	7be2                	ld	s7,56(sp)
ffffffffc0204062:	7c42                	ld	s8,48(sp)
ffffffffc0204064:	7ca2                	ld	s9,40(sp)
ffffffffc0204066:	7d02                	ld	s10,32(sp)
ffffffffc0204068:	6de2                	ld	s11,24(sp)
ffffffffc020406a:	6109                	addi	sp,sp,128
ffffffffc020406c:	8082                	ret
            padc = '0';
ffffffffc020406e:	87b2                	mv	a5,a2
            goto reswitch;
ffffffffc0204070:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204074:	846a                	mv	s0,s10
ffffffffc0204076:	00140d13          	addi	s10,s0,1
ffffffffc020407a:	fdd6059b          	addiw	a1,a2,-35
ffffffffc020407e:	0ff5f593          	zext.b	a1,a1
ffffffffc0204082:	fcb572e3          	bgeu	a0,a1,ffffffffc0204046 <vprintfmt+0x7c>
            putch('%', putdat);
ffffffffc0204086:	85a6                	mv	a1,s1
ffffffffc0204088:	02500513          	li	a0,37
ffffffffc020408c:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc020408e:	fff44783          	lbu	a5,-1(s0)
ffffffffc0204092:	8d22                	mv	s10,s0
ffffffffc0204094:	f73788e3          	beq	a5,s3,ffffffffc0204004 <vprintfmt+0x3a>
ffffffffc0204098:	ffed4783          	lbu	a5,-2(s10)
ffffffffc020409c:	1d7d                	addi	s10,s10,-1
ffffffffc020409e:	ff379de3          	bne	a5,s3,ffffffffc0204098 <vprintfmt+0xce>
ffffffffc02040a2:	b78d                	j	ffffffffc0204004 <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
ffffffffc02040a4:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
ffffffffc02040a8:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02040ac:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc02040ae:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc02040b2:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc02040b6:	02d86463          	bltu	a6,a3,ffffffffc02040de <vprintfmt+0x114>
                ch = *fmt;
ffffffffc02040ba:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc02040be:	002c169b          	slliw	a3,s8,0x2
ffffffffc02040c2:	0186873b          	addw	a4,a3,s8
ffffffffc02040c6:	0017171b          	slliw	a4,a4,0x1
ffffffffc02040ca:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
ffffffffc02040cc:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc02040d0:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc02040d2:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
ffffffffc02040d6:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc02040da:	fed870e3          	bgeu	a6,a3,ffffffffc02040ba <vprintfmt+0xf0>
            if (width < 0)
ffffffffc02040de:	f40ddce3          	bgez	s11,ffffffffc0204036 <vprintfmt+0x6c>
                width = precision, precision = -1;
ffffffffc02040e2:	8de2                	mv	s11,s8
ffffffffc02040e4:	5c7d                	li	s8,-1
ffffffffc02040e6:	bf81                	j	ffffffffc0204036 <vprintfmt+0x6c>
            if (width < 0)
ffffffffc02040e8:	fffdc693          	not	a3,s11
ffffffffc02040ec:	96fd                	srai	a3,a3,0x3f
ffffffffc02040ee:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02040f2:	00144603          	lbu	a2,1(s0)
ffffffffc02040f6:	2d81                	sext.w	s11,s11
ffffffffc02040f8:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02040fa:	bf35                	j	ffffffffc0204036 <vprintfmt+0x6c>
            precision = va_arg(ap, int);
ffffffffc02040fc:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204100:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc0204104:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204106:	846a                	mv	s0,s10
            goto process_precision;
ffffffffc0204108:	bfd9                	j	ffffffffc02040de <vprintfmt+0x114>
    if (lflag >= 2) {
ffffffffc020410a:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc020410c:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0204110:	01174463          	blt	a4,a7,ffffffffc0204118 <vprintfmt+0x14e>
    else if (lflag) {
ffffffffc0204114:	1a088e63          	beqz	a7,ffffffffc02042d0 <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
ffffffffc0204118:	000a3603          	ld	a2,0(s4)
ffffffffc020411c:	46c1                	li	a3,16
ffffffffc020411e:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0204120:	2781                	sext.w	a5,a5
ffffffffc0204122:	876e                	mv	a4,s11
ffffffffc0204124:	85a6                	mv	a1,s1
ffffffffc0204126:	854a                	mv	a0,s2
ffffffffc0204128:	e37ff0ef          	jal	ra,ffffffffc0203f5e <printnum>
            break;
ffffffffc020412c:	bde1                	j	ffffffffc0204004 <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
ffffffffc020412e:	000a2503          	lw	a0,0(s4)
ffffffffc0204132:	85a6                	mv	a1,s1
ffffffffc0204134:	0a21                	addi	s4,s4,8
ffffffffc0204136:	9902                	jalr	s2
            break;
ffffffffc0204138:	b5f1                	j	ffffffffc0204004 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc020413a:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc020413c:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0204140:	01174463          	blt	a4,a7,ffffffffc0204148 <vprintfmt+0x17e>
    else if (lflag) {
ffffffffc0204144:	18088163          	beqz	a7,ffffffffc02042c6 <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
ffffffffc0204148:	000a3603          	ld	a2,0(s4)
ffffffffc020414c:	46a9                	li	a3,10
ffffffffc020414e:	8a2e                	mv	s4,a1
ffffffffc0204150:	bfc1                	j	ffffffffc0204120 <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204152:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc0204156:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204158:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc020415a:	bdf1                	j	ffffffffc0204036 <vprintfmt+0x6c>
            putch(ch, putdat);
ffffffffc020415c:	85a6                	mv	a1,s1
ffffffffc020415e:	02500513          	li	a0,37
ffffffffc0204162:	9902                	jalr	s2
            break;
ffffffffc0204164:	b545                	j	ffffffffc0204004 <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204166:	00144603          	lbu	a2,1(s0)
            lflag ++;
ffffffffc020416a:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020416c:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc020416e:	b5e1                	j	ffffffffc0204036 <vprintfmt+0x6c>
    if (lflag >= 2) {
ffffffffc0204170:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0204172:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0204176:	01174463          	blt	a4,a7,ffffffffc020417e <vprintfmt+0x1b4>
    else if (lflag) {
ffffffffc020417a:	14088163          	beqz	a7,ffffffffc02042bc <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
ffffffffc020417e:	000a3603          	ld	a2,0(s4)
ffffffffc0204182:	46a1                	li	a3,8
ffffffffc0204184:	8a2e                	mv	s4,a1
ffffffffc0204186:	bf69                	j	ffffffffc0204120 <vprintfmt+0x156>
            putch('0', putdat);
ffffffffc0204188:	03000513          	li	a0,48
ffffffffc020418c:	85a6                	mv	a1,s1
ffffffffc020418e:	e03e                	sd	a5,0(sp)
ffffffffc0204190:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0204192:	85a6                	mv	a1,s1
ffffffffc0204194:	07800513          	li	a0,120
ffffffffc0204198:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc020419a:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc020419c:	6782                	ld	a5,0(sp)
ffffffffc020419e:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc02041a0:	ff8a3603          	ld	a2,-8(s4)
            goto number;
ffffffffc02041a4:	bfb5                	j	ffffffffc0204120 <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc02041a6:	000a3403          	ld	s0,0(s4)
ffffffffc02041aa:	008a0713          	addi	a4,s4,8
ffffffffc02041ae:	e03a                	sd	a4,0(sp)
ffffffffc02041b0:	14040263          	beqz	s0,ffffffffc02042f4 <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
ffffffffc02041b4:	0fb05763          	blez	s11,ffffffffc02042a2 <vprintfmt+0x2d8>
ffffffffc02041b8:	02d00693          	li	a3,45
ffffffffc02041bc:	0cd79163          	bne	a5,a3,ffffffffc020427e <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02041c0:	00044783          	lbu	a5,0(s0)
ffffffffc02041c4:	0007851b          	sext.w	a0,a5
ffffffffc02041c8:	cf85                	beqz	a5,ffffffffc0204200 <vprintfmt+0x236>
ffffffffc02041ca:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02041ce:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02041d2:	000c4563          	bltz	s8,ffffffffc02041dc <vprintfmt+0x212>
ffffffffc02041d6:	3c7d                	addiw	s8,s8,-1
ffffffffc02041d8:	036c0263          	beq	s8,s6,ffffffffc02041fc <vprintfmt+0x232>
                    putch('?', putdat);
ffffffffc02041dc:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02041de:	0e0c8e63          	beqz	s9,ffffffffc02042da <vprintfmt+0x310>
ffffffffc02041e2:	3781                	addiw	a5,a5,-32
ffffffffc02041e4:	0ef47b63          	bgeu	s0,a5,ffffffffc02042da <vprintfmt+0x310>
                    putch('?', putdat);
ffffffffc02041e8:	03f00513          	li	a0,63
ffffffffc02041ec:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02041ee:	000a4783          	lbu	a5,0(s4)
ffffffffc02041f2:	3dfd                	addiw	s11,s11,-1
ffffffffc02041f4:	0a05                	addi	s4,s4,1
ffffffffc02041f6:	0007851b          	sext.w	a0,a5
ffffffffc02041fa:	ffe1                	bnez	a5,ffffffffc02041d2 <vprintfmt+0x208>
            for (; width > 0; width --) {
ffffffffc02041fc:	01b05963          	blez	s11,ffffffffc020420e <vprintfmt+0x244>
ffffffffc0204200:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0204202:	85a6                	mv	a1,s1
ffffffffc0204204:	02000513          	li	a0,32
ffffffffc0204208:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc020420a:	fe0d9be3          	bnez	s11,ffffffffc0204200 <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc020420e:	6a02                	ld	s4,0(sp)
ffffffffc0204210:	bbd5                	j	ffffffffc0204004 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0204212:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0204214:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
ffffffffc0204218:	01174463          	blt	a4,a7,ffffffffc0204220 <vprintfmt+0x256>
    else if (lflag) {
ffffffffc020421c:	08088d63          	beqz	a7,ffffffffc02042b6 <vprintfmt+0x2ec>
        return va_arg(*ap, long);
ffffffffc0204220:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc0204224:	0a044d63          	bltz	s0,ffffffffc02042de <vprintfmt+0x314>
            num = getint(&ap, lflag);
ffffffffc0204228:	8622                	mv	a2,s0
ffffffffc020422a:	8a66                	mv	s4,s9
ffffffffc020422c:	46a9                	li	a3,10
ffffffffc020422e:	bdcd                	j	ffffffffc0204120 <vprintfmt+0x156>
            err = va_arg(ap, int);
ffffffffc0204230:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0204234:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc0204236:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc0204238:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc020423c:	8fb5                	xor	a5,a5,a3
ffffffffc020423e:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0204242:	02d74163          	blt	a4,a3,ffffffffc0204264 <vprintfmt+0x29a>
ffffffffc0204246:	00369793          	slli	a5,a3,0x3
ffffffffc020424a:	97de                	add	a5,a5,s7
ffffffffc020424c:	639c                	ld	a5,0(a5)
ffffffffc020424e:	cb99                	beqz	a5,ffffffffc0204264 <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
ffffffffc0204250:	86be                	mv	a3,a5
ffffffffc0204252:	00002617          	auipc	a2,0x2
ffffffffc0204256:	fae60613          	addi	a2,a2,-82 # ffffffffc0206200 <default_pmm_manager+0xff0>
ffffffffc020425a:	85a6                	mv	a1,s1
ffffffffc020425c:	854a                	mv	a0,s2
ffffffffc020425e:	0ce000ef          	jal	ra,ffffffffc020432c <printfmt>
ffffffffc0204262:	b34d                	j	ffffffffc0204004 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc0204264:	00002617          	auipc	a2,0x2
ffffffffc0204268:	f8c60613          	addi	a2,a2,-116 # ffffffffc02061f0 <default_pmm_manager+0xfe0>
ffffffffc020426c:	85a6                	mv	a1,s1
ffffffffc020426e:	854a                	mv	a0,s2
ffffffffc0204270:	0bc000ef          	jal	ra,ffffffffc020432c <printfmt>
ffffffffc0204274:	bb41                	j	ffffffffc0204004 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc0204276:	00002417          	auipc	s0,0x2
ffffffffc020427a:	f7240413          	addi	s0,s0,-142 # ffffffffc02061e8 <default_pmm_manager+0xfd8>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020427e:	85e2                	mv	a1,s8
ffffffffc0204280:	8522                	mv	a0,s0
ffffffffc0204282:	e43e                	sd	a5,8(sp)
ffffffffc0204284:	196000ef          	jal	ra,ffffffffc020441a <strnlen>
ffffffffc0204288:	40ad8dbb          	subw	s11,s11,a0
ffffffffc020428c:	01b05b63          	blez	s11,ffffffffc02042a2 <vprintfmt+0x2d8>
                    putch(padc, putdat);
ffffffffc0204290:	67a2                	ld	a5,8(sp)
ffffffffc0204292:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0204296:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc0204298:	85a6                	mv	a1,s1
ffffffffc020429a:	8552                	mv	a0,s4
ffffffffc020429c:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020429e:	fe0d9ce3          	bnez	s11,ffffffffc0204296 <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02042a2:	00044783          	lbu	a5,0(s0)
ffffffffc02042a6:	00140a13          	addi	s4,s0,1
ffffffffc02042aa:	0007851b          	sext.w	a0,a5
ffffffffc02042ae:	d3a5                	beqz	a5,ffffffffc020420e <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02042b0:	05e00413          	li	s0,94
ffffffffc02042b4:	bf39                	j	ffffffffc02041d2 <vprintfmt+0x208>
        return va_arg(*ap, int);
ffffffffc02042b6:	000a2403          	lw	s0,0(s4)
ffffffffc02042ba:	b7ad                	j	ffffffffc0204224 <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
ffffffffc02042bc:	000a6603          	lwu	a2,0(s4)
ffffffffc02042c0:	46a1                	li	a3,8
ffffffffc02042c2:	8a2e                	mv	s4,a1
ffffffffc02042c4:	bdb1                	j	ffffffffc0204120 <vprintfmt+0x156>
ffffffffc02042c6:	000a6603          	lwu	a2,0(s4)
ffffffffc02042ca:	46a9                	li	a3,10
ffffffffc02042cc:	8a2e                	mv	s4,a1
ffffffffc02042ce:	bd89                	j	ffffffffc0204120 <vprintfmt+0x156>
ffffffffc02042d0:	000a6603          	lwu	a2,0(s4)
ffffffffc02042d4:	46c1                	li	a3,16
ffffffffc02042d6:	8a2e                	mv	s4,a1
ffffffffc02042d8:	b5a1                	j	ffffffffc0204120 <vprintfmt+0x156>
                    putch(ch, putdat);
ffffffffc02042da:	9902                	jalr	s2
ffffffffc02042dc:	bf09                	j	ffffffffc02041ee <vprintfmt+0x224>
                putch('-', putdat);
ffffffffc02042de:	85a6                	mv	a1,s1
ffffffffc02042e0:	02d00513          	li	a0,45
ffffffffc02042e4:	e03e                	sd	a5,0(sp)
ffffffffc02042e6:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc02042e8:	6782                	ld	a5,0(sp)
ffffffffc02042ea:	8a66                	mv	s4,s9
ffffffffc02042ec:	40800633          	neg	a2,s0
ffffffffc02042f0:	46a9                	li	a3,10
ffffffffc02042f2:	b53d                	j	ffffffffc0204120 <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
ffffffffc02042f4:	03b05163          	blez	s11,ffffffffc0204316 <vprintfmt+0x34c>
ffffffffc02042f8:	02d00693          	li	a3,45
ffffffffc02042fc:	f6d79de3          	bne	a5,a3,ffffffffc0204276 <vprintfmt+0x2ac>
                p = "(null)";
ffffffffc0204300:	00002417          	auipc	s0,0x2
ffffffffc0204304:	ee840413          	addi	s0,s0,-280 # ffffffffc02061e8 <default_pmm_manager+0xfd8>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204308:	02800793          	li	a5,40
ffffffffc020430c:	02800513          	li	a0,40
ffffffffc0204310:	00140a13          	addi	s4,s0,1
ffffffffc0204314:	bd6d                	j	ffffffffc02041ce <vprintfmt+0x204>
ffffffffc0204316:	00002a17          	auipc	s4,0x2
ffffffffc020431a:	ed3a0a13          	addi	s4,s4,-301 # ffffffffc02061e9 <default_pmm_manager+0xfd9>
ffffffffc020431e:	02800513          	li	a0,40
ffffffffc0204322:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0204326:	05e00413          	li	s0,94
ffffffffc020432a:	b565                	j	ffffffffc02041d2 <vprintfmt+0x208>

ffffffffc020432c <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc020432c:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc020432e:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0204332:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0204334:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0204336:	ec06                	sd	ra,24(sp)
ffffffffc0204338:	f83a                	sd	a4,48(sp)
ffffffffc020433a:	fc3e                	sd	a5,56(sp)
ffffffffc020433c:	e0c2                	sd	a6,64(sp)
ffffffffc020433e:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0204340:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0204342:	c89ff0ef          	jal	ra,ffffffffc0203fca <vprintfmt>
}
ffffffffc0204346:	60e2                	ld	ra,24(sp)
ffffffffc0204348:	6161                	addi	sp,sp,80
ffffffffc020434a:	8082                	ret

ffffffffc020434c <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc020434c:	715d                	addi	sp,sp,-80
ffffffffc020434e:	e486                	sd	ra,72(sp)
ffffffffc0204350:	e0a6                	sd	s1,64(sp)
ffffffffc0204352:	fc4a                	sd	s2,56(sp)
ffffffffc0204354:	f84e                	sd	s3,48(sp)
ffffffffc0204356:	f452                	sd	s4,40(sp)
ffffffffc0204358:	f056                	sd	s5,32(sp)
ffffffffc020435a:	ec5a                	sd	s6,24(sp)
ffffffffc020435c:	e85e                	sd	s7,16(sp)
    if (prompt != NULL) {
ffffffffc020435e:	c901                	beqz	a0,ffffffffc020436e <readline+0x22>
ffffffffc0204360:	85aa                	mv	a1,a0
        cprintf("%s", prompt);
ffffffffc0204362:	00002517          	auipc	a0,0x2
ffffffffc0204366:	e9e50513          	addi	a0,a0,-354 # ffffffffc0206200 <default_pmm_manager+0xff0>
ffffffffc020436a:	d51fb0ef          	jal	ra,ffffffffc02000ba <cprintf>
readline(const char *prompt) {
ffffffffc020436e:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0204370:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc0204372:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc0204374:	4aa9                	li	s5,10
ffffffffc0204376:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc0204378:	0000db97          	auipc	s7,0xd
ffffffffc020437c:	d80b8b93          	addi	s7,s7,-640 # ffffffffc02110f8 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0204380:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc0204384:	d6ffb0ef          	jal	ra,ffffffffc02000f2 <getchar>
        if (c < 0) {
ffffffffc0204388:	00054a63          	bltz	a0,ffffffffc020439c <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020438c:	00a95a63          	bge	s2,a0,ffffffffc02043a0 <readline+0x54>
ffffffffc0204390:	029a5263          	bge	s4,s1,ffffffffc02043b4 <readline+0x68>
        c = getchar();
ffffffffc0204394:	d5ffb0ef          	jal	ra,ffffffffc02000f2 <getchar>
        if (c < 0) {
ffffffffc0204398:	fe055ae3          	bgez	a0,ffffffffc020438c <readline+0x40>
            return NULL;
ffffffffc020439c:	4501                	li	a0,0
ffffffffc020439e:	a091                	j	ffffffffc02043e2 <readline+0x96>
        else if (c == '\b' && i > 0) {
ffffffffc02043a0:	03351463          	bne	a0,s3,ffffffffc02043c8 <readline+0x7c>
ffffffffc02043a4:	e8a9                	bnez	s1,ffffffffc02043f6 <readline+0xaa>
        c = getchar();
ffffffffc02043a6:	d4dfb0ef          	jal	ra,ffffffffc02000f2 <getchar>
        if (c < 0) {
ffffffffc02043aa:	fe0549e3          	bltz	a0,ffffffffc020439c <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02043ae:	fea959e3          	bge	s2,a0,ffffffffc02043a0 <readline+0x54>
ffffffffc02043b2:	4481                	li	s1,0
            cputchar(c);
ffffffffc02043b4:	e42a                	sd	a0,8(sp)
ffffffffc02043b6:	d3bfb0ef          	jal	ra,ffffffffc02000f0 <cputchar>
            buf[i ++] = c;
ffffffffc02043ba:	6522                	ld	a0,8(sp)
ffffffffc02043bc:	009b87b3          	add	a5,s7,s1
ffffffffc02043c0:	2485                	addiw	s1,s1,1
ffffffffc02043c2:	00a78023          	sb	a0,0(a5)
ffffffffc02043c6:	bf7d                	j	ffffffffc0204384 <readline+0x38>
        else if (c == '\n' || c == '\r') {
ffffffffc02043c8:	01550463          	beq	a0,s5,ffffffffc02043d0 <readline+0x84>
ffffffffc02043cc:	fb651ce3          	bne	a0,s6,ffffffffc0204384 <readline+0x38>
            cputchar(c);
ffffffffc02043d0:	d21fb0ef          	jal	ra,ffffffffc02000f0 <cputchar>
            buf[i] = '\0';
ffffffffc02043d4:	0000d517          	auipc	a0,0xd
ffffffffc02043d8:	d2450513          	addi	a0,a0,-732 # ffffffffc02110f8 <buf>
ffffffffc02043dc:	94aa                	add	s1,s1,a0
ffffffffc02043de:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc02043e2:	60a6                	ld	ra,72(sp)
ffffffffc02043e4:	6486                	ld	s1,64(sp)
ffffffffc02043e6:	7962                	ld	s2,56(sp)
ffffffffc02043e8:	79c2                	ld	s3,48(sp)
ffffffffc02043ea:	7a22                	ld	s4,40(sp)
ffffffffc02043ec:	7a82                	ld	s5,32(sp)
ffffffffc02043ee:	6b62                	ld	s6,24(sp)
ffffffffc02043f0:	6bc2                	ld	s7,16(sp)
ffffffffc02043f2:	6161                	addi	sp,sp,80
ffffffffc02043f4:	8082                	ret
            cputchar(c);
ffffffffc02043f6:	4521                	li	a0,8
ffffffffc02043f8:	cf9fb0ef          	jal	ra,ffffffffc02000f0 <cputchar>
            i --;
ffffffffc02043fc:	34fd                	addiw	s1,s1,-1
ffffffffc02043fe:	b759                	j	ffffffffc0204384 <readline+0x38>

ffffffffc0204400 <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc0204400:	00054783          	lbu	a5,0(a0)
strlen(const char *s) {
ffffffffc0204404:	872a                	mv	a4,a0
    size_t cnt = 0;
ffffffffc0204406:	4501                	li	a0,0
    while (*s ++ != '\0') {
ffffffffc0204408:	cb81                	beqz	a5,ffffffffc0204418 <strlen+0x18>
        cnt ++;
ffffffffc020440a:	0505                	addi	a0,a0,1
    while (*s ++ != '\0') {
ffffffffc020440c:	00a707b3          	add	a5,a4,a0
ffffffffc0204410:	0007c783          	lbu	a5,0(a5)
ffffffffc0204414:	fbfd                	bnez	a5,ffffffffc020440a <strlen+0xa>
ffffffffc0204416:	8082                	ret
    }
    return cnt;
}
ffffffffc0204418:	8082                	ret

ffffffffc020441a <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc020441a:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc020441c:	e589                	bnez	a1,ffffffffc0204426 <strnlen+0xc>
ffffffffc020441e:	a811                	j	ffffffffc0204432 <strnlen+0x18>
        cnt ++;
ffffffffc0204420:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0204422:	00f58863          	beq	a1,a5,ffffffffc0204432 <strnlen+0x18>
ffffffffc0204426:	00f50733          	add	a4,a0,a5
ffffffffc020442a:	00074703          	lbu	a4,0(a4)
ffffffffc020442e:	fb6d                	bnez	a4,ffffffffc0204420 <strnlen+0x6>
ffffffffc0204430:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc0204432:	852e                	mv	a0,a1
ffffffffc0204434:	8082                	ret

ffffffffc0204436 <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc0204436:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc0204438:	0005c703          	lbu	a4,0(a1)
ffffffffc020443c:	0785                	addi	a5,a5,1
ffffffffc020443e:	0585                	addi	a1,a1,1
ffffffffc0204440:	fee78fa3          	sb	a4,-1(a5)
ffffffffc0204444:	fb75                	bnez	a4,ffffffffc0204438 <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc0204446:	8082                	ret

ffffffffc0204448 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0204448:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc020444c:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0204450:	cb89                	beqz	a5,ffffffffc0204462 <strcmp+0x1a>
        s1 ++, s2 ++;
ffffffffc0204452:	0505                	addi	a0,a0,1
ffffffffc0204454:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0204456:	fee789e3          	beq	a5,a4,ffffffffc0204448 <strcmp>
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc020445a:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc020445e:	9d19                	subw	a0,a0,a4
ffffffffc0204460:	8082                	ret
ffffffffc0204462:	4501                	li	a0,0
ffffffffc0204464:	bfed                	j	ffffffffc020445e <strcmp+0x16>

ffffffffc0204466 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0204466:	00054783          	lbu	a5,0(a0)
ffffffffc020446a:	c799                	beqz	a5,ffffffffc0204478 <strchr+0x12>
        if (*s == c) {
ffffffffc020446c:	00f58763          	beq	a1,a5,ffffffffc020447a <strchr+0x14>
    while (*s != '\0') {
ffffffffc0204470:	00154783          	lbu	a5,1(a0)
            return (char *)s;
        }
        s ++;
ffffffffc0204474:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0204476:	fbfd                	bnez	a5,ffffffffc020446c <strchr+0x6>
    }
    return NULL;
ffffffffc0204478:	4501                	li	a0,0
}
ffffffffc020447a:	8082                	ret

ffffffffc020447c <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc020447c:	ca01                	beqz	a2,ffffffffc020448c <memset+0x10>
ffffffffc020447e:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0204480:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0204482:	0785                	addi	a5,a5,1
ffffffffc0204484:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0204488:	fec79de3          	bne	a5,a2,ffffffffc0204482 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc020448c:	8082                	ret

ffffffffc020448e <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc020448e:	ca19                	beqz	a2,ffffffffc02044a4 <memcpy+0x16>
ffffffffc0204490:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc0204492:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc0204494:	0005c703          	lbu	a4,0(a1)
ffffffffc0204498:	0585                	addi	a1,a1,1
ffffffffc020449a:	0785                	addi	a5,a5,1
ffffffffc020449c:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc02044a0:	fec59ae3          	bne	a1,a2,ffffffffc0204494 <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc02044a4:	8082                	ret
