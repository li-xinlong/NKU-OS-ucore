
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
ffffffffc020003e:	52a60613          	addi	a2,a2,1322 # ffffffffc0211564 <end>
{
ffffffffc0200042:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200044:	8e09                	sub	a2,a2,a0
ffffffffc0200046:	4581                	li	a1,0
{
ffffffffc0200048:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004a:	3f2040ef          	jal	ra,ffffffffc020443c <memset>

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc020004e:	00004597          	auipc	a1,0x4
ffffffffc0200052:	41a58593          	addi	a1,a1,1050 # ffffffffc0204468 <etext+0x2>
ffffffffc0200056:	00004517          	auipc	a0,0x4
ffffffffc020005a:	43250513          	addi	a0,a0,1074 # ffffffffc0204488 <etext+0x22>
ffffffffc020005e:	05c000ef          	jal	ra,ffffffffc02000ba <cprintf>

    print_kerninfo();
ffffffffc0200062:	0a0000ef          	jal	ra,ffffffffc0200102 <print_kerninfo>

    // grade_backtrace();

    pmm_init(); // init physical memory management
ffffffffc0200066:	251010ef          	jal	ra,ffffffffc0201ab6 <pmm_init>

    idt_init(); // init interrupt descriptor table
ffffffffc020006a:	4fa000ef          	jal	ra,ffffffffc0200564 <idt_init>

    vmm_init(); // init virtual memory management
ffffffffc020006e:	69a030ef          	jal	ra,ffffffffc0203708 <vmm_init>

    ide_init();  // init ide devices
ffffffffc0200072:	420000ef          	jal	ra,ffffffffc0200492 <ide_init>
    swap_init(); // init swap
ffffffffc0200076:	0a5020ef          	jal	ra,ffffffffc020291a <swap_init>

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
ffffffffc02000ae:	6dd030ef          	jal	ra,ffffffffc0203f8a <vprintfmt>
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
ffffffffc02000e4:	6a7030ef          	jal	ra,ffffffffc0203f8a <vprintfmt>
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
ffffffffc0200108:	38c50513          	addi	a0,a0,908 # ffffffffc0204490 <etext+0x2a>
void print_kerninfo(void) {
ffffffffc020010c:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc020010e:	fadff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc0200112:	00000597          	auipc	a1,0x0
ffffffffc0200116:	f2058593          	addi	a1,a1,-224 # ffffffffc0200032 <kern_init>
ffffffffc020011a:	00004517          	auipc	a0,0x4
ffffffffc020011e:	39650513          	addi	a0,a0,918 # ffffffffc02044b0 <etext+0x4a>
ffffffffc0200122:	f99ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc0200126:	00004597          	auipc	a1,0x4
ffffffffc020012a:	34058593          	addi	a1,a1,832 # ffffffffc0204466 <etext>
ffffffffc020012e:	00004517          	auipc	a0,0x4
ffffffffc0200132:	3a250513          	addi	a0,a0,930 # ffffffffc02044d0 <etext+0x6a>
ffffffffc0200136:	f85ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc020013a:	0000a597          	auipc	a1,0xa
ffffffffc020013e:	f0658593          	addi	a1,a1,-250 # ffffffffc020a040 <ide>
ffffffffc0200142:	00004517          	auipc	a0,0x4
ffffffffc0200146:	3ae50513          	addi	a0,a0,942 # ffffffffc02044f0 <etext+0x8a>
ffffffffc020014a:	f71ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc020014e:	00011597          	auipc	a1,0x11
ffffffffc0200152:	41658593          	addi	a1,a1,1046 # ffffffffc0211564 <end>
ffffffffc0200156:	00004517          	auipc	a0,0x4
ffffffffc020015a:	3ba50513          	addi	a0,a0,954 # ffffffffc0204510 <etext+0xaa>
ffffffffc020015e:	f5dff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc0200162:	00012597          	auipc	a1,0x12
ffffffffc0200166:	80158593          	addi	a1,a1,-2047 # ffffffffc0211963 <end+0x3ff>
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
ffffffffc0200188:	3ac50513          	addi	a0,a0,940 # ffffffffc0204530 <etext+0xca>
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
ffffffffc0200196:	3ce60613          	addi	a2,a2,974 # ffffffffc0204560 <etext+0xfa>
ffffffffc020019a:	04e00593          	li	a1,78
ffffffffc020019e:	00004517          	auipc	a0,0x4
ffffffffc02001a2:	3da50513          	addi	a0,a0,986 # ffffffffc0204578 <etext+0x112>
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
ffffffffc02001b2:	3e260613          	addi	a2,a2,994 # ffffffffc0204590 <etext+0x12a>
ffffffffc02001b6:	00004597          	auipc	a1,0x4
ffffffffc02001ba:	3fa58593          	addi	a1,a1,1018 # ffffffffc02045b0 <etext+0x14a>
ffffffffc02001be:	00004517          	auipc	a0,0x4
ffffffffc02001c2:	3fa50513          	addi	a0,a0,1018 # ffffffffc02045b8 <etext+0x152>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02001c6:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02001c8:	ef3ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc02001cc:	00004617          	auipc	a2,0x4
ffffffffc02001d0:	3fc60613          	addi	a2,a2,1020 # ffffffffc02045c8 <etext+0x162>
ffffffffc02001d4:	00004597          	auipc	a1,0x4
ffffffffc02001d8:	41c58593          	addi	a1,a1,1052 # ffffffffc02045f0 <etext+0x18a>
ffffffffc02001dc:	00004517          	auipc	a0,0x4
ffffffffc02001e0:	3dc50513          	addi	a0,a0,988 # ffffffffc02045b8 <etext+0x152>
ffffffffc02001e4:	ed7ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc02001e8:	00004617          	auipc	a2,0x4
ffffffffc02001ec:	41860613          	addi	a2,a2,1048 # ffffffffc0204600 <etext+0x19a>
ffffffffc02001f0:	00004597          	auipc	a1,0x4
ffffffffc02001f4:	43058593          	addi	a1,a1,1072 # ffffffffc0204620 <etext+0x1ba>
ffffffffc02001f8:	00004517          	auipc	a0,0x4
ffffffffc02001fc:	3c050513          	addi	a0,a0,960 # ffffffffc02045b8 <etext+0x152>
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
ffffffffc0200236:	3fe50513          	addi	a0,a0,1022 # ffffffffc0204630 <etext+0x1ca>
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
ffffffffc0200258:	40450513          	addi	a0,a0,1028 # ffffffffc0204658 <etext+0x1f2>
ffffffffc020025c:	e5fff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    if (tf != NULL) {
ffffffffc0200260:	000b8563          	beqz	s7,ffffffffc020026a <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc0200264:	855e                	mv	a0,s7
ffffffffc0200266:	4e8000ef          	jal	ra,ffffffffc020074e <print_trapframe>
ffffffffc020026a:	00004c17          	auipc	s8,0x4
ffffffffc020026e:	456c0c13          	addi	s8,s8,1110 # ffffffffc02046c0 <commands>
        if ((buf = readline("")) != NULL) {
ffffffffc0200272:	00006917          	auipc	s2,0x6
ffffffffc0200276:	88690913          	addi	s2,s2,-1914 # ffffffffc0205af8 <default_pmm_manager+0x950>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020027a:	00004497          	auipc	s1,0x4
ffffffffc020027e:	40648493          	addi	s1,s1,1030 # ffffffffc0204680 <etext+0x21a>
        if (argc == MAXARGS - 1) {
ffffffffc0200282:	49bd                	li	s3,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200284:	00004b17          	auipc	s6,0x4
ffffffffc0200288:	404b0b13          	addi	s6,s6,1028 # ffffffffc0204688 <etext+0x222>
        argv[argc ++] = buf;
ffffffffc020028c:	00004a17          	auipc	s4,0x4
ffffffffc0200290:	324a0a13          	addi	s4,s4,804 # ffffffffc02045b0 <etext+0x14a>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200294:	4a8d                	li	s5,3
        if ((buf = readline("")) != NULL) {
ffffffffc0200296:	854a                	mv	a0,s2
ffffffffc0200298:	074040ef          	jal	ra,ffffffffc020430c <readline>
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
ffffffffc02002b2:	412d0d13          	addi	s10,s10,1042 # ffffffffc02046c0 <commands>
        argv[argc ++] = buf;
ffffffffc02002b6:	8552                	mv	a0,s4
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002b8:	4401                	li	s0,0
ffffffffc02002ba:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002bc:	14c040ef          	jal	ra,ffffffffc0204408 <strcmp>
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
ffffffffc02002d0:	138040ef          	jal	ra,ffffffffc0204408 <strcmp>
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
ffffffffc020030e:	118040ef          	jal	ra,ffffffffc0204426 <strchr>
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
ffffffffc020034c:	0da040ef          	jal	ra,ffffffffc0204426 <strchr>
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
ffffffffc020036a:	34250513          	addi	a0,a0,834 # ffffffffc02046a8 <etext+0x242>
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
ffffffffc02003a6:	36650513          	addi	a0,a0,870 # ffffffffc0204708 <commands+0x48>
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
ffffffffc02003bc:	26850513          	addi	a0,a0,616 # ffffffffc0205620 <default_pmm_manager+0x478>
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
ffffffffc02003fa:	33250513          	addi	a0,a0,818 # ffffffffc0204728 <commands+0x68>
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
ffffffffc02004b8:	797030ef          	jal	ra,ffffffffc020444e <memcpy>
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
ffffffffc02004dc:	773030ef          	jal	ra,ffffffffc020444e <memcpy>
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
ffffffffc0200528:	22450513          	addi	a0,a0,548 # ffffffffc0204748 <commands+0x88>
ffffffffc020052c:	b8fff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    extern struct mm_struct *check_mm_struct;
    print_pgfault(tf);
    if (check_mm_struct != NULL) {
ffffffffc0200530:	00011517          	auipc	a0,0x11
ffffffffc0200534:	02853503          	ld	a0,40(a0) # ffffffffc0211558 <check_mm_struct>
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
ffffffffc0200548:	7980306f          	j	ffffffffc0203ce0 <do_pgfault>
    panic("unhandled page fault.\n");
ffffffffc020054c:	00004617          	auipc	a2,0x4
ffffffffc0200550:	21c60613          	addi	a2,a2,540 # ffffffffc0204768 <commands+0xa8>
ffffffffc0200554:	07800593          	li	a1,120
ffffffffc0200558:	00004517          	auipc	a0,0x4
ffffffffc020055c:	22850513          	addi	a0,a0,552 # ffffffffc0204780 <commands+0xc0>
ffffffffc0200560:	e15ff0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0200564 <idt_init>:
    write_csr(sscratch, 0);
ffffffffc0200564:	14005073          	csrwi	sscratch,0
    write_csr(stvec, &__alltraps);
ffffffffc0200568:	00000797          	auipc	a5,0x0
ffffffffc020056c:	48878793          	addi	a5,a5,1160 # ffffffffc02009f0 <__alltraps>
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
ffffffffc020058e:	20e50513          	addi	a0,a0,526 # ffffffffc0204798 <commands+0xd8>
void print_regs(struct pushregs *gpr) {
ffffffffc0200592:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200594:	b27ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc0200598:	640c                	ld	a1,8(s0)
ffffffffc020059a:	00004517          	auipc	a0,0x4
ffffffffc020059e:	21650513          	addi	a0,a0,534 # ffffffffc02047b0 <commands+0xf0>
ffffffffc02005a2:	b19ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc02005a6:	680c                	ld	a1,16(s0)
ffffffffc02005a8:	00004517          	auipc	a0,0x4
ffffffffc02005ac:	22050513          	addi	a0,a0,544 # ffffffffc02047c8 <commands+0x108>
ffffffffc02005b0:	b0bff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02005b4:	6c0c                	ld	a1,24(s0)
ffffffffc02005b6:	00004517          	auipc	a0,0x4
ffffffffc02005ba:	22a50513          	addi	a0,a0,554 # ffffffffc02047e0 <commands+0x120>
ffffffffc02005be:	afdff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02005c2:	700c                	ld	a1,32(s0)
ffffffffc02005c4:	00004517          	auipc	a0,0x4
ffffffffc02005c8:	23450513          	addi	a0,a0,564 # ffffffffc02047f8 <commands+0x138>
ffffffffc02005cc:	aefff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02005d0:	740c                	ld	a1,40(s0)
ffffffffc02005d2:	00004517          	auipc	a0,0x4
ffffffffc02005d6:	23e50513          	addi	a0,a0,574 # ffffffffc0204810 <commands+0x150>
ffffffffc02005da:	ae1ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02005de:	780c                	ld	a1,48(s0)
ffffffffc02005e0:	00004517          	auipc	a0,0x4
ffffffffc02005e4:	24850513          	addi	a0,a0,584 # ffffffffc0204828 <commands+0x168>
ffffffffc02005e8:	ad3ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02005ec:	7c0c                	ld	a1,56(s0)
ffffffffc02005ee:	00004517          	auipc	a0,0x4
ffffffffc02005f2:	25250513          	addi	a0,a0,594 # ffffffffc0204840 <commands+0x180>
ffffffffc02005f6:	ac5ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02005fa:	602c                	ld	a1,64(s0)
ffffffffc02005fc:	00004517          	auipc	a0,0x4
ffffffffc0200600:	25c50513          	addi	a0,a0,604 # ffffffffc0204858 <commands+0x198>
ffffffffc0200604:	ab7ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc0200608:	642c                	ld	a1,72(s0)
ffffffffc020060a:	00004517          	auipc	a0,0x4
ffffffffc020060e:	26650513          	addi	a0,a0,614 # ffffffffc0204870 <commands+0x1b0>
ffffffffc0200612:	aa9ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc0200616:	682c                	ld	a1,80(s0)
ffffffffc0200618:	00004517          	auipc	a0,0x4
ffffffffc020061c:	27050513          	addi	a0,a0,624 # ffffffffc0204888 <commands+0x1c8>
ffffffffc0200620:	a9bff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc0200624:	6c2c                	ld	a1,88(s0)
ffffffffc0200626:	00004517          	auipc	a0,0x4
ffffffffc020062a:	27a50513          	addi	a0,a0,634 # ffffffffc02048a0 <commands+0x1e0>
ffffffffc020062e:	a8dff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200632:	702c                	ld	a1,96(s0)
ffffffffc0200634:	00004517          	auipc	a0,0x4
ffffffffc0200638:	28450513          	addi	a0,a0,644 # ffffffffc02048b8 <commands+0x1f8>
ffffffffc020063c:	a7fff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200640:	742c                	ld	a1,104(s0)
ffffffffc0200642:	00004517          	auipc	a0,0x4
ffffffffc0200646:	28e50513          	addi	a0,a0,654 # ffffffffc02048d0 <commands+0x210>
ffffffffc020064a:	a71ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc020064e:	782c                	ld	a1,112(s0)
ffffffffc0200650:	00004517          	auipc	a0,0x4
ffffffffc0200654:	29850513          	addi	a0,a0,664 # ffffffffc02048e8 <commands+0x228>
ffffffffc0200658:	a63ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc020065c:	7c2c                	ld	a1,120(s0)
ffffffffc020065e:	00004517          	auipc	a0,0x4
ffffffffc0200662:	2a250513          	addi	a0,a0,674 # ffffffffc0204900 <commands+0x240>
ffffffffc0200666:	a55ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc020066a:	604c                	ld	a1,128(s0)
ffffffffc020066c:	00004517          	auipc	a0,0x4
ffffffffc0200670:	2ac50513          	addi	a0,a0,684 # ffffffffc0204918 <commands+0x258>
ffffffffc0200674:	a47ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200678:	644c                	ld	a1,136(s0)
ffffffffc020067a:	00004517          	auipc	a0,0x4
ffffffffc020067e:	2b650513          	addi	a0,a0,694 # ffffffffc0204930 <commands+0x270>
ffffffffc0200682:	a39ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200686:	684c                	ld	a1,144(s0)
ffffffffc0200688:	00004517          	auipc	a0,0x4
ffffffffc020068c:	2c050513          	addi	a0,a0,704 # ffffffffc0204948 <commands+0x288>
ffffffffc0200690:	a2bff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200694:	6c4c                	ld	a1,152(s0)
ffffffffc0200696:	00004517          	auipc	a0,0x4
ffffffffc020069a:	2ca50513          	addi	a0,a0,714 # ffffffffc0204960 <commands+0x2a0>
ffffffffc020069e:	a1dff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc02006a2:	704c                	ld	a1,160(s0)
ffffffffc02006a4:	00004517          	auipc	a0,0x4
ffffffffc02006a8:	2d450513          	addi	a0,a0,724 # ffffffffc0204978 <commands+0x2b8>
ffffffffc02006ac:	a0fff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02006b0:	744c                	ld	a1,168(s0)
ffffffffc02006b2:	00004517          	auipc	a0,0x4
ffffffffc02006b6:	2de50513          	addi	a0,a0,734 # ffffffffc0204990 <commands+0x2d0>
ffffffffc02006ba:	a01ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02006be:	784c                	ld	a1,176(s0)
ffffffffc02006c0:	00004517          	auipc	a0,0x4
ffffffffc02006c4:	2e850513          	addi	a0,a0,744 # ffffffffc02049a8 <commands+0x2e8>
ffffffffc02006c8:	9f3ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02006cc:	7c4c                	ld	a1,184(s0)
ffffffffc02006ce:	00004517          	auipc	a0,0x4
ffffffffc02006d2:	2f250513          	addi	a0,a0,754 # ffffffffc02049c0 <commands+0x300>
ffffffffc02006d6:	9e5ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02006da:	606c                	ld	a1,192(s0)
ffffffffc02006dc:	00004517          	auipc	a0,0x4
ffffffffc02006e0:	2fc50513          	addi	a0,a0,764 # ffffffffc02049d8 <commands+0x318>
ffffffffc02006e4:	9d7ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02006e8:	646c                	ld	a1,200(s0)
ffffffffc02006ea:	00004517          	auipc	a0,0x4
ffffffffc02006ee:	30650513          	addi	a0,a0,774 # ffffffffc02049f0 <commands+0x330>
ffffffffc02006f2:	9c9ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02006f6:	686c                	ld	a1,208(s0)
ffffffffc02006f8:	00004517          	auipc	a0,0x4
ffffffffc02006fc:	31050513          	addi	a0,a0,784 # ffffffffc0204a08 <commands+0x348>
ffffffffc0200700:	9bbff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc0200704:	6c6c                	ld	a1,216(s0)
ffffffffc0200706:	00004517          	auipc	a0,0x4
ffffffffc020070a:	31a50513          	addi	a0,a0,794 # ffffffffc0204a20 <commands+0x360>
ffffffffc020070e:	9adff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc0200712:	706c                	ld	a1,224(s0)
ffffffffc0200714:	00004517          	auipc	a0,0x4
ffffffffc0200718:	32450513          	addi	a0,a0,804 # ffffffffc0204a38 <commands+0x378>
ffffffffc020071c:	99fff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200720:	746c                	ld	a1,232(s0)
ffffffffc0200722:	00004517          	auipc	a0,0x4
ffffffffc0200726:	32e50513          	addi	a0,a0,814 # ffffffffc0204a50 <commands+0x390>
ffffffffc020072a:	991ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc020072e:	786c                	ld	a1,240(s0)
ffffffffc0200730:	00004517          	auipc	a0,0x4
ffffffffc0200734:	33850513          	addi	a0,a0,824 # ffffffffc0204a68 <commands+0x3a8>
ffffffffc0200738:	983ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020073c:	7c6c                	ld	a1,248(s0)
}
ffffffffc020073e:	6402                	ld	s0,0(sp)
ffffffffc0200740:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200742:	00004517          	auipc	a0,0x4
ffffffffc0200746:	33e50513          	addi	a0,a0,830 # ffffffffc0204a80 <commands+0x3c0>
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
ffffffffc020075a:	34250513          	addi	a0,a0,834 # ffffffffc0204a98 <commands+0x3d8>
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
ffffffffc0200772:	34250513          	addi	a0,a0,834 # ffffffffc0204ab0 <commands+0x3f0>
ffffffffc0200776:	945ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc020077a:	10843583          	ld	a1,264(s0)
ffffffffc020077e:	00004517          	auipc	a0,0x4
ffffffffc0200782:	34a50513          	addi	a0,a0,842 # ffffffffc0204ac8 <commands+0x408>
ffffffffc0200786:	935ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc020078a:	11043583          	ld	a1,272(s0)
ffffffffc020078e:	00004517          	auipc	a0,0x4
ffffffffc0200792:	35250513          	addi	a0,a0,850 # ffffffffc0204ae0 <commands+0x420>
ffffffffc0200796:	925ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020079a:	11843583          	ld	a1,280(s0)
}
ffffffffc020079e:	6402                	ld	s0,0(sp)
ffffffffc02007a0:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02007a2:	00004517          	auipc	a0,0x4
ffffffffc02007a6:	35650513          	addi	a0,a0,854 # ffffffffc0204af8 <commands+0x438>
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
ffffffffc02007ba:	06f76c63          	bltu	a4,a5,ffffffffc0200832 <interrupt_handler+0x82>
ffffffffc02007be:	00004717          	auipc	a4,0x4
ffffffffc02007c2:	40270713          	addi	a4,a4,1026 # ffffffffc0204bc0 <commands+0x500>
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
ffffffffc02007d4:	3a050513          	addi	a0,a0,928 # ffffffffc0204b70 <commands+0x4b0>
ffffffffc02007d8:	8e3ff06f          	j	ffffffffc02000ba <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02007dc:	00004517          	auipc	a0,0x4
ffffffffc02007e0:	37450513          	addi	a0,a0,884 # ffffffffc0204b50 <commands+0x490>
ffffffffc02007e4:	8d7ff06f          	j	ffffffffc02000ba <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02007e8:	00004517          	auipc	a0,0x4
ffffffffc02007ec:	32850513          	addi	a0,a0,808 # ffffffffc0204b10 <commands+0x450>
ffffffffc02007f0:	8cbff06f          	j	ffffffffc02000ba <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc02007f4:	00004517          	auipc	a0,0x4
ffffffffc02007f8:	33c50513          	addi	a0,a0,828 # ffffffffc0204b30 <commands+0x470>
ffffffffc02007fc:	8bfff06f          	j	ffffffffc02000ba <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc0200800:	1141                	addi	sp,sp,-16
ffffffffc0200802:	e406                	sd	ra,8(sp)
            // "All bits besides SSIP and USIP in the sip register are
            // read-only." -- privileged spec1.9.1, 4.1.4, p59
            // In fact, Call sbi_set_timer will clear STIP, or you can clear it
            // directly.
            // clear_csr(sip, SIP_STIP);
            clock_set_next_event();
ffffffffc0200804:	c05ff0ef          	jal	ra,ffffffffc0200408 <clock_set_next_event>
            if (++ticks % TICK_NUM == 0) {
ffffffffc0200808:	00011697          	auipc	a3,0x11
ffffffffc020080c:	cf868693          	addi	a3,a3,-776 # ffffffffc0211500 <ticks>
ffffffffc0200810:	629c                	ld	a5,0(a3)
ffffffffc0200812:	06400713          	li	a4,100
ffffffffc0200816:	0785                	addi	a5,a5,1
ffffffffc0200818:	02e7f733          	remu	a4,a5,a4
ffffffffc020081c:	e29c                	sd	a5,0(a3)
ffffffffc020081e:	cb19                	beqz	a4,ffffffffc0200834 <interrupt_handler+0x84>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200820:	60a2                	ld	ra,8(sp)
ffffffffc0200822:	0141                	addi	sp,sp,16
ffffffffc0200824:	8082                	ret
            cprintf("Supervisor external interrupt\n");
ffffffffc0200826:	00004517          	auipc	a0,0x4
ffffffffc020082a:	37a50513          	addi	a0,a0,890 # ffffffffc0204ba0 <commands+0x4e0>
ffffffffc020082e:	88dff06f          	j	ffffffffc02000ba <cprintf>
            print_trapframe(tf);
ffffffffc0200832:	bf31                	j	ffffffffc020074e <print_trapframe>
}
ffffffffc0200834:	60a2                	ld	ra,8(sp)
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200836:	06400593          	li	a1,100
ffffffffc020083a:	00004517          	auipc	a0,0x4
ffffffffc020083e:	35650513          	addi	a0,a0,854 # ffffffffc0204b90 <commands+0x4d0>
}
ffffffffc0200842:	0141                	addi	sp,sp,16
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200844:	877ff06f          	j	ffffffffc02000ba <cprintf>

ffffffffc0200848 <exception_handler>:


void exception_handler(struct trapframe *tf) {
    int ret;
    switch (tf->cause) {
ffffffffc0200848:	11853783          	ld	a5,280(a0)
void exception_handler(struct trapframe *tf) {
ffffffffc020084c:	1101                	addi	sp,sp,-32
ffffffffc020084e:	e822                	sd	s0,16(sp)
ffffffffc0200850:	ec06                	sd	ra,24(sp)
ffffffffc0200852:	e426                	sd	s1,8(sp)
ffffffffc0200854:	473d                	li	a4,15
ffffffffc0200856:	842a                	mv	s0,a0
ffffffffc0200858:	14f76a63          	bltu	a4,a5,ffffffffc02009ac <exception_handler+0x164>
ffffffffc020085c:	00004717          	auipc	a4,0x4
ffffffffc0200860:	54c70713          	addi	a4,a4,1356 # ffffffffc0204da8 <commands+0x6e8>
ffffffffc0200864:	078a                	slli	a5,a5,0x2
ffffffffc0200866:	97ba                	add	a5,a5,a4
ffffffffc0200868:	439c                	lw	a5,0(a5)
ffffffffc020086a:	97ba                	add	a5,a5,a4
ffffffffc020086c:	8782                	jr	a5
                print_trapframe(tf);
                panic("handle pgfault failed. %e\n", ret);
            }
            break;
        case CAUSE_STORE_PAGE_FAULT:
            cprintf("Store/AMO page fault\n");
ffffffffc020086e:	00004517          	auipc	a0,0x4
ffffffffc0200872:	52250513          	addi	a0,a0,1314 # ffffffffc0204d90 <commands+0x6d0>
ffffffffc0200876:	845ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc020087a:	8522                	mv	a0,s0
ffffffffc020087c:	c79ff0ef          	jal	ra,ffffffffc02004f4 <pgfault_handler>
ffffffffc0200880:	84aa                	mv	s1,a0
ffffffffc0200882:	12051b63          	bnez	a0,ffffffffc02009b8 <exception_handler+0x170>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200886:	60e2                	ld	ra,24(sp)
ffffffffc0200888:	6442                	ld	s0,16(sp)
ffffffffc020088a:	64a2                	ld	s1,8(sp)
ffffffffc020088c:	6105                	addi	sp,sp,32
ffffffffc020088e:	8082                	ret
            cprintf("Instruction address misaligned\n");
ffffffffc0200890:	00004517          	auipc	a0,0x4
ffffffffc0200894:	36050513          	addi	a0,a0,864 # ffffffffc0204bf0 <commands+0x530>
}
ffffffffc0200898:	6442                	ld	s0,16(sp)
ffffffffc020089a:	60e2                	ld	ra,24(sp)
ffffffffc020089c:	64a2                	ld	s1,8(sp)
ffffffffc020089e:	6105                	addi	sp,sp,32
            cprintf("Instruction access fault\n");
ffffffffc02008a0:	81bff06f          	j	ffffffffc02000ba <cprintf>
ffffffffc02008a4:	00004517          	auipc	a0,0x4
ffffffffc02008a8:	36c50513          	addi	a0,a0,876 # ffffffffc0204c10 <commands+0x550>
ffffffffc02008ac:	b7f5                	j	ffffffffc0200898 <exception_handler+0x50>
            cprintf("Illegal instruction\n");
ffffffffc02008ae:	00004517          	auipc	a0,0x4
ffffffffc02008b2:	38250513          	addi	a0,a0,898 # ffffffffc0204c30 <commands+0x570>
ffffffffc02008b6:	b7cd                	j	ffffffffc0200898 <exception_handler+0x50>
            cprintf("Breakpoint\n");
ffffffffc02008b8:	00004517          	auipc	a0,0x4
ffffffffc02008bc:	39050513          	addi	a0,a0,912 # ffffffffc0204c48 <commands+0x588>
ffffffffc02008c0:	bfe1                	j	ffffffffc0200898 <exception_handler+0x50>
            cprintf("Load address misaligned\n");
ffffffffc02008c2:	00004517          	auipc	a0,0x4
ffffffffc02008c6:	39650513          	addi	a0,a0,918 # ffffffffc0204c58 <commands+0x598>
ffffffffc02008ca:	b7f9                	j	ffffffffc0200898 <exception_handler+0x50>
            cprintf("Load access fault\n");
ffffffffc02008cc:	00004517          	auipc	a0,0x4
ffffffffc02008d0:	3ac50513          	addi	a0,a0,940 # ffffffffc0204c78 <commands+0x5b8>
ffffffffc02008d4:	fe6ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc02008d8:	8522                	mv	a0,s0
ffffffffc02008da:	c1bff0ef          	jal	ra,ffffffffc02004f4 <pgfault_handler>
ffffffffc02008de:	84aa                	mv	s1,a0
ffffffffc02008e0:	d15d                	beqz	a0,ffffffffc0200886 <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc02008e2:	8522                	mv	a0,s0
ffffffffc02008e4:	e6bff0ef          	jal	ra,ffffffffc020074e <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc02008e8:	86a6                	mv	a3,s1
ffffffffc02008ea:	00004617          	auipc	a2,0x4
ffffffffc02008ee:	3a660613          	addi	a2,a2,934 # ffffffffc0204c90 <commands+0x5d0>
ffffffffc02008f2:	0ca00593          	li	a1,202
ffffffffc02008f6:	00004517          	auipc	a0,0x4
ffffffffc02008fa:	e8a50513          	addi	a0,a0,-374 # ffffffffc0204780 <commands+0xc0>
ffffffffc02008fe:	a77ff0ef          	jal	ra,ffffffffc0200374 <__panic>
            cprintf("AMO address misaligned\n");
ffffffffc0200902:	00004517          	auipc	a0,0x4
ffffffffc0200906:	3ae50513          	addi	a0,a0,942 # ffffffffc0204cb0 <commands+0x5f0>
ffffffffc020090a:	b779                	j	ffffffffc0200898 <exception_handler+0x50>
            cprintf("Store/AMO access fault\n");
ffffffffc020090c:	00004517          	auipc	a0,0x4
ffffffffc0200910:	3bc50513          	addi	a0,a0,956 # ffffffffc0204cc8 <commands+0x608>
ffffffffc0200914:	fa6ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200918:	8522                	mv	a0,s0
ffffffffc020091a:	bdbff0ef          	jal	ra,ffffffffc02004f4 <pgfault_handler>
ffffffffc020091e:	84aa                	mv	s1,a0
ffffffffc0200920:	d13d                	beqz	a0,ffffffffc0200886 <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc0200922:	8522                	mv	a0,s0
ffffffffc0200924:	e2bff0ef          	jal	ra,ffffffffc020074e <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200928:	86a6                	mv	a3,s1
ffffffffc020092a:	00004617          	auipc	a2,0x4
ffffffffc020092e:	36660613          	addi	a2,a2,870 # ffffffffc0204c90 <commands+0x5d0>
ffffffffc0200932:	0d400593          	li	a1,212
ffffffffc0200936:	00004517          	auipc	a0,0x4
ffffffffc020093a:	e4a50513          	addi	a0,a0,-438 # ffffffffc0204780 <commands+0xc0>
ffffffffc020093e:	a37ff0ef          	jal	ra,ffffffffc0200374 <__panic>
            cprintf("Environment call from U-mode\n");
ffffffffc0200942:	00004517          	auipc	a0,0x4
ffffffffc0200946:	39e50513          	addi	a0,a0,926 # ffffffffc0204ce0 <commands+0x620>
ffffffffc020094a:	b7b9                	j	ffffffffc0200898 <exception_handler+0x50>
            cprintf("Environment call from S-mode\n");
ffffffffc020094c:	00004517          	auipc	a0,0x4
ffffffffc0200950:	3b450513          	addi	a0,a0,948 # ffffffffc0204d00 <commands+0x640>
ffffffffc0200954:	b791                	j	ffffffffc0200898 <exception_handler+0x50>
            cprintf("Environment call from H-mode\n");
ffffffffc0200956:	00004517          	auipc	a0,0x4
ffffffffc020095a:	3ca50513          	addi	a0,a0,970 # ffffffffc0204d20 <commands+0x660>
ffffffffc020095e:	bf2d                	j	ffffffffc0200898 <exception_handler+0x50>
            cprintf("Environment call from M-mode\n");
ffffffffc0200960:	00004517          	auipc	a0,0x4
ffffffffc0200964:	3e050513          	addi	a0,a0,992 # ffffffffc0204d40 <commands+0x680>
ffffffffc0200968:	bf05                	j	ffffffffc0200898 <exception_handler+0x50>
            cprintf("Instruction page fault\n");
ffffffffc020096a:	00004517          	auipc	a0,0x4
ffffffffc020096e:	3f650513          	addi	a0,a0,1014 # ffffffffc0204d60 <commands+0x6a0>
ffffffffc0200972:	b71d                	j	ffffffffc0200898 <exception_handler+0x50>
            cprintf("Load page fault\n");
ffffffffc0200974:	00004517          	auipc	a0,0x4
ffffffffc0200978:	40450513          	addi	a0,a0,1028 # ffffffffc0204d78 <commands+0x6b8>
ffffffffc020097c:	f3eff0ef          	jal	ra,ffffffffc02000ba <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200980:	8522                	mv	a0,s0
ffffffffc0200982:	b73ff0ef          	jal	ra,ffffffffc02004f4 <pgfault_handler>
ffffffffc0200986:	84aa                	mv	s1,a0
ffffffffc0200988:	ee050fe3          	beqz	a0,ffffffffc0200886 <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc020098c:	8522                	mv	a0,s0
ffffffffc020098e:	dc1ff0ef          	jal	ra,ffffffffc020074e <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200992:	86a6                	mv	a3,s1
ffffffffc0200994:	00004617          	auipc	a2,0x4
ffffffffc0200998:	2fc60613          	addi	a2,a2,764 # ffffffffc0204c90 <commands+0x5d0>
ffffffffc020099c:	0ea00593          	li	a1,234
ffffffffc02009a0:	00004517          	auipc	a0,0x4
ffffffffc02009a4:	de050513          	addi	a0,a0,-544 # ffffffffc0204780 <commands+0xc0>
ffffffffc02009a8:	9cdff0ef          	jal	ra,ffffffffc0200374 <__panic>
            print_trapframe(tf);
ffffffffc02009ac:	8522                	mv	a0,s0
}
ffffffffc02009ae:	6442                	ld	s0,16(sp)
ffffffffc02009b0:	60e2                	ld	ra,24(sp)
ffffffffc02009b2:	64a2                	ld	s1,8(sp)
ffffffffc02009b4:	6105                	addi	sp,sp,32
            print_trapframe(tf);
ffffffffc02009b6:	bb61                	j	ffffffffc020074e <print_trapframe>
                print_trapframe(tf);
ffffffffc02009b8:	8522                	mv	a0,s0
ffffffffc02009ba:	d95ff0ef          	jal	ra,ffffffffc020074e <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc02009be:	86a6                	mv	a3,s1
ffffffffc02009c0:	00004617          	auipc	a2,0x4
ffffffffc02009c4:	2d060613          	addi	a2,a2,720 # ffffffffc0204c90 <commands+0x5d0>
ffffffffc02009c8:	0f100593          	li	a1,241
ffffffffc02009cc:	00004517          	auipc	a0,0x4
ffffffffc02009d0:	db450513          	addi	a0,a0,-588 # ffffffffc0204780 <commands+0xc0>
ffffffffc02009d4:	9a1ff0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc02009d8 <trap>:
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf) {
    // dispatch based on what type of trap occurred
    if ((intptr_t)tf->cause < 0) {
ffffffffc02009d8:	11853783          	ld	a5,280(a0)
ffffffffc02009dc:	0007c363          	bltz	a5,ffffffffc02009e2 <trap+0xa>
        // interrupts
        interrupt_handler(tf);
    } else {
        // exceptions
        exception_handler(tf);
ffffffffc02009e0:	b5a5                	j	ffffffffc0200848 <exception_handler>
        interrupt_handler(tf);
ffffffffc02009e2:	b3f9                	j	ffffffffc02007b0 <interrupt_handler>
	...

ffffffffc02009f0 <__alltraps>:
    .endm

    .align 4
    .globl __alltraps
__alltraps:
    SAVE_ALL
ffffffffc02009f0:	14011073          	csrw	sscratch,sp
ffffffffc02009f4:	712d                	addi	sp,sp,-288
ffffffffc02009f6:	e406                	sd	ra,8(sp)
ffffffffc02009f8:	ec0e                	sd	gp,24(sp)
ffffffffc02009fa:	f012                	sd	tp,32(sp)
ffffffffc02009fc:	f416                	sd	t0,40(sp)
ffffffffc02009fe:	f81a                	sd	t1,48(sp)
ffffffffc0200a00:	fc1e                	sd	t2,56(sp)
ffffffffc0200a02:	e0a2                	sd	s0,64(sp)
ffffffffc0200a04:	e4a6                	sd	s1,72(sp)
ffffffffc0200a06:	e8aa                	sd	a0,80(sp)
ffffffffc0200a08:	ecae                	sd	a1,88(sp)
ffffffffc0200a0a:	f0b2                	sd	a2,96(sp)
ffffffffc0200a0c:	f4b6                	sd	a3,104(sp)
ffffffffc0200a0e:	f8ba                	sd	a4,112(sp)
ffffffffc0200a10:	fcbe                	sd	a5,120(sp)
ffffffffc0200a12:	e142                	sd	a6,128(sp)
ffffffffc0200a14:	e546                	sd	a7,136(sp)
ffffffffc0200a16:	e94a                	sd	s2,144(sp)
ffffffffc0200a18:	ed4e                	sd	s3,152(sp)
ffffffffc0200a1a:	f152                	sd	s4,160(sp)
ffffffffc0200a1c:	f556                	sd	s5,168(sp)
ffffffffc0200a1e:	f95a                	sd	s6,176(sp)
ffffffffc0200a20:	fd5e                	sd	s7,184(sp)
ffffffffc0200a22:	e1e2                	sd	s8,192(sp)
ffffffffc0200a24:	e5e6                	sd	s9,200(sp)
ffffffffc0200a26:	e9ea                	sd	s10,208(sp)
ffffffffc0200a28:	edee                	sd	s11,216(sp)
ffffffffc0200a2a:	f1f2                	sd	t3,224(sp)
ffffffffc0200a2c:	f5f6                	sd	t4,232(sp)
ffffffffc0200a2e:	f9fa                	sd	t5,240(sp)
ffffffffc0200a30:	fdfe                	sd	t6,248(sp)
ffffffffc0200a32:	14002473          	csrr	s0,sscratch
ffffffffc0200a36:	100024f3          	csrr	s1,sstatus
ffffffffc0200a3a:	14102973          	csrr	s2,sepc
ffffffffc0200a3e:	143029f3          	csrr	s3,stval
ffffffffc0200a42:	14202a73          	csrr	s4,scause
ffffffffc0200a46:	e822                	sd	s0,16(sp)
ffffffffc0200a48:	e226                	sd	s1,256(sp)
ffffffffc0200a4a:	e64a                	sd	s2,264(sp)
ffffffffc0200a4c:	ea4e                	sd	s3,272(sp)
ffffffffc0200a4e:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc0200a50:	850a                	mv	a0,sp
    jal trap
ffffffffc0200a52:	f87ff0ef          	jal	ra,ffffffffc02009d8 <trap>

ffffffffc0200a56 <__trapret>:
    // sp should be the same as before "jal trap"
    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc0200a56:	6492                	ld	s1,256(sp)
ffffffffc0200a58:	6932                	ld	s2,264(sp)
ffffffffc0200a5a:	10049073          	csrw	sstatus,s1
ffffffffc0200a5e:	14191073          	csrw	sepc,s2
ffffffffc0200a62:	60a2                	ld	ra,8(sp)
ffffffffc0200a64:	61e2                	ld	gp,24(sp)
ffffffffc0200a66:	7202                	ld	tp,32(sp)
ffffffffc0200a68:	72a2                	ld	t0,40(sp)
ffffffffc0200a6a:	7342                	ld	t1,48(sp)
ffffffffc0200a6c:	73e2                	ld	t2,56(sp)
ffffffffc0200a6e:	6406                	ld	s0,64(sp)
ffffffffc0200a70:	64a6                	ld	s1,72(sp)
ffffffffc0200a72:	6546                	ld	a0,80(sp)
ffffffffc0200a74:	65e6                	ld	a1,88(sp)
ffffffffc0200a76:	7606                	ld	a2,96(sp)
ffffffffc0200a78:	76a6                	ld	a3,104(sp)
ffffffffc0200a7a:	7746                	ld	a4,112(sp)
ffffffffc0200a7c:	77e6                	ld	a5,120(sp)
ffffffffc0200a7e:	680a                	ld	a6,128(sp)
ffffffffc0200a80:	68aa                	ld	a7,136(sp)
ffffffffc0200a82:	694a                	ld	s2,144(sp)
ffffffffc0200a84:	69ea                	ld	s3,152(sp)
ffffffffc0200a86:	7a0a                	ld	s4,160(sp)
ffffffffc0200a88:	7aaa                	ld	s5,168(sp)
ffffffffc0200a8a:	7b4a                	ld	s6,176(sp)
ffffffffc0200a8c:	7bea                	ld	s7,184(sp)
ffffffffc0200a8e:	6c0e                	ld	s8,192(sp)
ffffffffc0200a90:	6cae                	ld	s9,200(sp)
ffffffffc0200a92:	6d4e                	ld	s10,208(sp)
ffffffffc0200a94:	6dee                	ld	s11,216(sp)
ffffffffc0200a96:	7e0e                	ld	t3,224(sp)
ffffffffc0200a98:	7eae                	ld	t4,232(sp)
ffffffffc0200a9a:	7f4e                	ld	t5,240(sp)
ffffffffc0200a9c:	7fee                	ld	t6,248(sp)
ffffffffc0200a9e:	6142                	ld	sp,16(sp)
    // go back from supervisor call
    sret
ffffffffc0200aa0:	10200073          	sret
	...

ffffffffc0200ab0 <default_init>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200ab0:	00010797          	auipc	a5,0x10
ffffffffc0200ab4:	59078793          	addi	a5,a5,1424 # ffffffffc0211040 <free_area>
ffffffffc0200ab8:	e79c                	sd	a5,8(a5)
ffffffffc0200aba:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc0200abc:	0007a823          	sw	zero,16(a5)
}
ffffffffc0200ac0:	8082                	ret

ffffffffc0200ac2 <default_nr_free_pages>:
}

static size_t
default_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0200ac2:	00010517          	auipc	a0,0x10
ffffffffc0200ac6:	58e56503          	lwu	a0,1422(a0) # ffffffffc0211050 <free_area+0x10>
ffffffffc0200aca:	8082                	ret

ffffffffc0200acc <default_check>:
}

// LAB2: below code is used to check the first fit allocation algorithm
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
ffffffffc0200acc:	715d                	addi	sp,sp,-80
ffffffffc0200ace:	e0a2                	sd	s0,64(sp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0200ad0:	00010417          	auipc	s0,0x10
ffffffffc0200ad4:	57040413          	addi	s0,s0,1392 # ffffffffc0211040 <free_area>
ffffffffc0200ad8:	641c                	ld	a5,8(s0)
ffffffffc0200ada:	e486                	sd	ra,72(sp)
ffffffffc0200adc:	fc26                	sd	s1,56(sp)
ffffffffc0200ade:	f84a                	sd	s2,48(sp)
ffffffffc0200ae0:	f44e                	sd	s3,40(sp)
ffffffffc0200ae2:	f052                	sd	s4,32(sp)
ffffffffc0200ae4:	ec56                	sd	s5,24(sp)
ffffffffc0200ae6:	e85a                	sd	s6,16(sp)
ffffffffc0200ae8:	e45e                	sd	s7,8(sp)
ffffffffc0200aea:	e062                	sd	s8,0(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200aec:	2c878763          	beq	a5,s0,ffffffffc0200dba <default_check+0x2ee>
    int count = 0, total = 0;
ffffffffc0200af0:	4481                	li	s1,0
ffffffffc0200af2:	4901                	li	s2,0
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200af4:	fe87b703          	ld	a4,-24(a5)
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0200af8:	8b09                	andi	a4,a4,2
ffffffffc0200afa:	2c070463          	beqz	a4,ffffffffc0200dc2 <default_check+0x2f6>
        count ++, total += p->property;
ffffffffc0200afe:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200b02:	679c                	ld	a5,8(a5)
ffffffffc0200b04:	2905                	addiw	s2,s2,1
ffffffffc0200b06:	9cb9                	addw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200b08:	fe8796e3          	bne	a5,s0,ffffffffc0200af4 <default_check+0x28>
    }
    assert(total == nr_free_pages());
ffffffffc0200b0c:	89a6                	mv	s3,s1
ffffffffc0200b0e:	385000ef          	jal	ra,ffffffffc0201692 <nr_free_pages>
ffffffffc0200b12:	71351863          	bne	a0,s3,ffffffffc0201222 <default_check+0x756>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200b16:	4505                	li	a0,1
ffffffffc0200b18:	2a9000ef          	jal	ra,ffffffffc02015c0 <alloc_pages>
ffffffffc0200b1c:	8a2a                	mv	s4,a0
ffffffffc0200b1e:	44050263          	beqz	a0,ffffffffc0200f62 <default_check+0x496>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200b22:	4505                	li	a0,1
ffffffffc0200b24:	29d000ef          	jal	ra,ffffffffc02015c0 <alloc_pages>
ffffffffc0200b28:	89aa                	mv	s3,a0
ffffffffc0200b2a:	70050c63          	beqz	a0,ffffffffc0201242 <default_check+0x776>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200b2e:	4505                	li	a0,1
ffffffffc0200b30:	291000ef          	jal	ra,ffffffffc02015c0 <alloc_pages>
ffffffffc0200b34:	8aaa                	mv	s5,a0
ffffffffc0200b36:	4a050663          	beqz	a0,ffffffffc0200fe2 <default_check+0x516>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200b3a:	2b3a0463          	beq	s4,s3,ffffffffc0200de2 <default_check+0x316>
ffffffffc0200b3e:	2aaa0263          	beq	s4,a0,ffffffffc0200de2 <default_check+0x316>
ffffffffc0200b42:	2aa98063          	beq	s3,a0,ffffffffc0200de2 <default_check+0x316>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200b46:	000a2783          	lw	a5,0(s4)
ffffffffc0200b4a:	2a079c63          	bnez	a5,ffffffffc0200e02 <default_check+0x336>
ffffffffc0200b4e:	0009a783          	lw	a5,0(s3)
ffffffffc0200b52:	2a079863          	bnez	a5,ffffffffc0200e02 <default_check+0x336>
ffffffffc0200b56:	411c                	lw	a5,0(a0)
ffffffffc0200b58:	2a079563          	bnez	a5,ffffffffc0200e02 <default_check+0x336>
extern struct Page *pages;
extern size_t npage;
extern const size_t nbase;
extern uint_t va_pa_offset;

static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200b5c:	00011797          	auipc	a5,0x11
ffffffffc0200b60:	9cc7b783          	ld	a5,-1588(a5) # ffffffffc0211528 <pages>
ffffffffc0200b64:	40fa0733          	sub	a4,s4,a5
ffffffffc0200b68:	870d                	srai	a4,a4,0x3
ffffffffc0200b6a:	00006597          	auipc	a1,0x6
ffffffffc0200b6e:	8465b583          	ld	a1,-1978(a1) # ffffffffc02063b0 <error_string+0x38>
ffffffffc0200b72:	02b70733          	mul	a4,a4,a1
ffffffffc0200b76:	00006617          	auipc	a2,0x6
ffffffffc0200b7a:	84263603          	ld	a2,-1982(a2) # ffffffffc02063b8 <nbase>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200b7e:	00011697          	auipc	a3,0x11
ffffffffc0200b82:	9a26b683          	ld	a3,-1630(a3) # ffffffffc0211520 <npage>
ffffffffc0200b86:	06b2                	slli	a3,a3,0xc
ffffffffc0200b88:	9732                	add	a4,a4,a2

static inline uintptr_t page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
ffffffffc0200b8a:	0732                	slli	a4,a4,0xc
ffffffffc0200b8c:	28d77b63          	bgeu	a4,a3,ffffffffc0200e22 <default_check+0x356>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200b90:	40f98733          	sub	a4,s3,a5
ffffffffc0200b94:	870d                	srai	a4,a4,0x3
ffffffffc0200b96:	02b70733          	mul	a4,a4,a1
ffffffffc0200b9a:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200b9c:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200b9e:	4cd77263          	bgeu	a4,a3,ffffffffc0201062 <default_check+0x596>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200ba2:	40f507b3          	sub	a5,a0,a5
ffffffffc0200ba6:	878d                	srai	a5,a5,0x3
ffffffffc0200ba8:	02b787b3          	mul	a5,a5,a1
ffffffffc0200bac:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200bae:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200bb0:	30d7f963          	bgeu	a5,a3,ffffffffc0200ec2 <default_check+0x3f6>
    assert(alloc_page() == NULL);
ffffffffc0200bb4:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200bb6:	00043c03          	ld	s8,0(s0)
ffffffffc0200bba:	00843b83          	ld	s7,8(s0)
    unsigned int nr_free_store = nr_free;
ffffffffc0200bbe:	01042b03          	lw	s6,16(s0)
    elm->prev = elm->next = elm;
ffffffffc0200bc2:	e400                	sd	s0,8(s0)
ffffffffc0200bc4:	e000                	sd	s0,0(s0)
    nr_free = 0;
ffffffffc0200bc6:	00010797          	auipc	a5,0x10
ffffffffc0200bca:	4807a523          	sw	zero,1162(a5) # ffffffffc0211050 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0200bce:	1f3000ef          	jal	ra,ffffffffc02015c0 <alloc_pages>
ffffffffc0200bd2:	2c051863          	bnez	a0,ffffffffc0200ea2 <default_check+0x3d6>
    free_page(p0);
ffffffffc0200bd6:	4585                	li	a1,1
ffffffffc0200bd8:	8552                	mv	a0,s4
ffffffffc0200bda:	279000ef          	jal	ra,ffffffffc0201652 <free_pages>
    free_page(p1);
ffffffffc0200bde:	4585                	li	a1,1
ffffffffc0200be0:	854e                	mv	a0,s3
ffffffffc0200be2:	271000ef          	jal	ra,ffffffffc0201652 <free_pages>
    free_page(p2);
ffffffffc0200be6:	4585                	li	a1,1
ffffffffc0200be8:	8556                	mv	a0,s5
ffffffffc0200bea:	269000ef          	jal	ra,ffffffffc0201652 <free_pages>
    assert(nr_free == 3);
ffffffffc0200bee:	4818                	lw	a4,16(s0)
ffffffffc0200bf0:	478d                	li	a5,3
ffffffffc0200bf2:	28f71863          	bne	a4,a5,ffffffffc0200e82 <default_check+0x3b6>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200bf6:	4505                	li	a0,1
ffffffffc0200bf8:	1c9000ef          	jal	ra,ffffffffc02015c0 <alloc_pages>
ffffffffc0200bfc:	89aa                	mv	s3,a0
ffffffffc0200bfe:	26050263          	beqz	a0,ffffffffc0200e62 <default_check+0x396>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200c02:	4505                	li	a0,1
ffffffffc0200c04:	1bd000ef          	jal	ra,ffffffffc02015c0 <alloc_pages>
ffffffffc0200c08:	8aaa                	mv	s5,a0
ffffffffc0200c0a:	3a050c63          	beqz	a0,ffffffffc0200fc2 <default_check+0x4f6>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200c0e:	4505                	li	a0,1
ffffffffc0200c10:	1b1000ef          	jal	ra,ffffffffc02015c0 <alloc_pages>
ffffffffc0200c14:	8a2a                	mv	s4,a0
ffffffffc0200c16:	38050663          	beqz	a0,ffffffffc0200fa2 <default_check+0x4d6>
    assert(alloc_page() == NULL);
ffffffffc0200c1a:	4505                	li	a0,1
ffffffffc0200c1c:	1a5000ef          	jal	ra,ffffffffc02015c0 <alloc_pages>
ffffffffc0200c20:	36051163          	bnez	a0,ffffffffc0200f82 <default_check+0x4b6>
    free_page(p0);
ffffffffc0200c24:	4585                	li	a1,1
ffffffffc0200c26:	854e                	mv	a0,s3
ffffffffc0200c28:	22b000ef          	jal	ra,ffffffffc0201652 <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0200c2c:	641c                	ld	a5,8(s0)
ffffffffc0200c2e:	20878a63          	beq	a5,s0,ffffffffc0200e42 <default_check+0x376>
    assert((p = alloc_page()) == p0);
ffffffffc0200c32:	4505                	li	a0,1
ffffffffc0200c34:	18d000ef          	jal	ra,ffffffffc02015c0 <alloc_pages>
ffffffffc0200c38:	30a99563          	bne	s3,a0,ffffffffc0200f42 <default_check+0x476>
    assert(alloc_page() == NULL);
ffffffffc0200c3c:	4505                	li	a0,1
ffffffffc0200c3e:	183000ef          	jal	ra,ffffffffc02015c0 <alloc_pages>
ffffffffc0200c42:	2e051063          	bnez	a0,ffffffffc0200f22 <default_check+0x456>
    assert(nr_free == 0);
ffffffffc0200c46:	481c                	lw	a5,16(s0)
ffffffffc0200c48:	2a079d63          	bnez	a5,ffffffffc0200f02 <default_check+0x436>
    free_page(p);
ffffffffc0200c4c:	854e                	mv	a0,s3
ffffffffc0200c4e:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0200c50:	01843023          	sd	s8,0(s0)
ffffffffc0200c54:	01743423          	sd	s7,8(s0)
    nr_free = nr_free_store;
ffffffffc0200c58:	01642823          	sw	s6,16(s0)
    free_page(p);
ffffffffc0200c5c:	1f7000ef          	jal	ra,ffffffffc0201652 <free_pages>
    free_page(p1);
ffffffffc0200c60:	4585                	li	a1,1
ffffffffc0200c62:	8556                	mv	a0,s5
ffffffffc0200c64:	1ef000ef          	jal	ra,ffffffffc0201652 <free_pages>
    free_page(p2);
ffffffffc0200c68:	4585                	li	a1,1
ffffffffc0200c6a:	8552                	mv	a0,s4
ffffffffc0200c6c:	1e7000ef          	jal	ra,ffffffffc0201652 <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0200c70:	4515                	li	a0,5
ffffffffc0200c72:	14f000ef          	jal	ra,ffffffffc02015c0 <alloc_pages>
ffffffffc0200c76:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc0200c78:	26050563          	beqz	a0,ffffffffc0200ee2 <default_check+0x416>
ffffffffc0200c7c:	651c                	ld	a5,8(a0)
ffffffffc0200c7e:	8385                	srli	a5,a5,0x1
    assert(!PageProperty(p0));
ffffffffc0200c80:	8b85                	andi	a5,a5,1
ffffffffc0200c82:	54079063          	bnez	a5,ffffffffc02011c2 <default_check+0x6f6>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0200c86:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200c88:	00043b03          	ld	s6,0(s0)
ffffffffc0200c8c:	00843a83          	ld	s5,8(s0)
ffffffffc0200c90:	e000                	sd	s0,0(s0)
ffffffffc0200c92:	e400                	sd	s0,8(s0)
    assert(alloc_page() == NULL);
ffffffffc0200c94:	12d000ef          	jal	ra,ffffffffc02015c0 <alloc_pages>
ffffffffc0200c98:	50051563          	bnez	a0,ffffffffc02011a2 <default_check+0x6d6>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc0200c9c:	09098a13          	addi	s4,s3,144
ffffffffc0200ca0:	8552                	mv	a0,s4
ffffffffc0200ca2:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc0200ca4:	01042b83          	lw	s7,16(s0)
    nr_free = 0;
ffffffffc0200ca8:	00010797          	auipc	a5,0x10
ffffffffc0200cac:	3a07a423          	sw	zero,936(a5) # ffffffffc0211050 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc0200cb0:	1a3000ef          	jal	ra,ffffffffc0201652 <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0200cb4:	4511                	li	a0,4
ffffffffc0200cb6:	10b000ef          	jal	ra,ffffffffc02015c0 <alloc_pages>
ffffffffc0200cba:	4c051463          	bnez	a0,ffffffffc0201182 <default_check+0x6b6>
ffffffffc0200cbe:	0989b783          	ld	a5,152(s3)
ffffffffc0200cc2:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0200cc4:	8b85                	andi	a5,a5,1
ffffffffc0200cc6:	48078e63          	beqz	a5,ffffffffc0201162 <default_check+0x696>
ffffffffc0200cca:	0a89a703          	lw	a4,168(s3)
ffffffffc0200cce:	478d                	li	a5,3
ffffffffc0200cd0:	48f71963          	bne	a4,a5,ffffffffc0201162 <default_check+0x696>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0200cd4:	450d                	li	a0,3
ffffffffc0200cd6:	0eb000ef          	jal	ra,ffffffffc02015c0 <alloc_pages>
ffffffffc0200cda:	8c2a                	mv	s8,a0
ffffffffc0200cdc:	46050363          	beqz	a0,ffffffffc0201142 <default_check+0x676>
    assert(alloc_page() == NULL);
ffffffffc0200ce0:	4505                	li	a0,1
ffffffffc0200ce2:	0df000ef          	jal	ra,ffffffffc02015c0 <alloc_pages>
ffffffffc0200ce6:	42051e63          	bnez	a0,ffffffffc0201122 <default_check+0x656>
    assert(p0 + 2 == p1);
ffffffffc0200cea:	418a1c63          	bne	s4,s8,ffffffffc0201102 <default_check+0x636>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc0200cee:	4585                	li	a1,1
ffffffffc0200cf0:	854e                	mv	a0,s3
ffffffffc0200cf2:	161000ef          	jal	ra,ffffffffc0201652 <free_pages>
    free_pages(p1, 3);
ffffffffc0200cf6:	458d                	li	a1,3
ffffffffc0200cf8:	8552                	mv	a0,s4
ffffffffc0200cfa:	159000ef          	jal	ra,ffffffffc0201652 <free_pages>
ffffffffc0200cfe:	0089b783          	ld	a5,8(s3)
    p2 = p0 + 1;
ffffffffc0200d02:	04898c13          	addi	s8,s3,72
ffffffffc0200d06:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0200d08:	8b85                	andi	a5,a5,1
ffffffffc0200d0a:	3c078c63          	beqz	a5,ffffffffc02010e2 <default_check+0x616>
ffffffffc0200d0e:	0189a703          	lw	a4,24(s3)
ffffffffc0200d12:	4785                	li	a5,1
ffffffffc0200d14:	3cf71763          	bne	a4,a5,ffffffffc02010e2 <default_check+0x616>
ffffffffc0200d18:	008a3783          	ld	a5,8(s4)
ffffffffc0200d1c:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0200d1e:	8b85                	andi	a5,a5,1
ffffffffc0200d20:	3a078163          	beqz	a5,ffffffffc02010c2 <default_check+0x5f6>
ffffffffc0200d24:	018a2703          	lw	a4,24(s4)
ffffffffc0200d28:	478d                	li	a5,3
ffffffffc0200d2a:	38f71c63          	bne	a4,a5,ffffffffc02010c2 <default_check+0x5f6>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0200d2e:	4505                	li	a0,1
ffffffffc0200d30:	091000ef          	jal	ra,ffffffffc02015c0 <alloc_pages>
ffffffffc0200d34:	36a99763          	bne	s3,a0,ffffffffc02010a2 <default_check+0x5d6>
    free_page(p0);
ffffffffc0200d38:	4585                	li	a1,1
ffffffffc0200d3a:	119000ef          	jal	ra,ffffffffc0201652 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0200d3e:	4509                	li	a0,2
ffffffffc0200d40:	081000ef          	jal	ra,ffffffffc02015c0 <alloc_pages>
ffffffffc0200d44:	32aa1f63          	bne	s4,a0,ffffffffc0201082 <default_check+0x5b6>

    free_pages(p0, 2);
ffffffffc0200d48:	4589                	li	a1,2
ffffffffc0200d4a:	109000ef          	jal	ra,ffffffffc0201652 <free_pages>
    free_page(p2);
ffffffffc0200d4e:	4585                	li	a1,1
ffffffffc0200d50:	8562                	mv	a0,s8
ffffffffc0200d52:	101000ef          	jal	ra,ffffffffc0201652 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0200d56:	4515                	li	a0,5
ffffffffc0200d58:	069000ef          	jal	ra,ffffffffc02015c0 <alloc_pages>
ffffffffc0200d5c:	89aa                	mv	s3,a0
ffffffffc0200d5e:	48050263          	beqz	a0,ffffffffc02011e2 <default_check+0x716>
    assert(alloc_page() == NULL);
ffffffffc0200d62:	4505                	li	a0,1
ffffffffc0200d64:	05d000ef          	jal	ra,ffffffffc02015c0 <alloc_pages>
ffffffffc0200d68:	2c051d63          	bnez	a0,ffffffffc0201042 <default_check+0x576>

    assert(nr_free == 0);
ffffffffc0200d6c:	481c                	lw	a5,16(s0)
ffffffffc0200d6e:	2a079a63          	bnez	a5,ffffffffc0201022 <default_check+0x556>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc0200d72:	4595                	li	a1,5
ffffffffc0200d74:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc0200d76:	01742823          	sw	s7,16(s0)
    free_list = free_list_store;
ffffffffc0200d7a:	01643023          	sd	s6,0(s0)
ffffffffc0200d7e:	01543423          	sd	s5,8(s0)
    free_pages(p0, 5);
ffffffffc0200d82:	0d1000ef          	jal	ra,ffffffffc0201652 <free_pages>
    return listelm->next;
ffffffffc0200d86:	641c                	ld	a5,8(s0)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200d88:	00878963          	beq	a5,s0,ffffffffc0200d9a <default_check+0x2ce>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc0200d8c:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200d90:	679c                	ld	a5,8(a5)
ffffffffc0200d92:	397d                	addiw	s2,s2,-1
ffffffffc0200d94:	9c99                	subw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200d96:	fe879be3          	bne	a5,s0,ffffffffc0200d8c <default_check+0x2c0>
    }
    assert(count == 0);
ffffffffc0200d9a:	26091463          	bnez	s2,ffffffffc0201002 <default_check+0x536>
    assert(total == 0);
ffffffffc0200d9e:	46049263          	bnez	s1,ffffffffc0201202 <default_check+0x736>
}
ffffffffc0200da2:	60a6                	ld	ra,72(sp)
ffffffffc0200da4:	6406                	ld	s0,64(sp)
ffffffffc0200da6:	74e2                	ld	s1,56(sp)
ffffffffc0200da8:	7942                	ld	s2,48(sp)
ffffffffc0200daa:	79a2                	ld	s3,40(sp)
ffffffffc0200dac:	7a02                	ld	s4,32(sp)
ffffffffc0200dae:	6ae2                	ld	s5,24(sp)
ffffffffc0200db0:	6b42                	ld	s6,16(sp)
ffffffffc0200db2:	6ba2                	ld	s7,8(sp)
ffffffffc0200db4:	6c02                	ld	s8,0(sp)
ffffffffc0200db6:	6161                	addi	sp,sp,80
ffffffffc0200db8:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200dba:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc0200dbc:	4481                	li	s1,0
ffffffffc0200dbe:	4901                	li	s2,0
ffffffffc0200dc0:	b3b9                	j	ffffffffc0200b0e <default_check+0x42>
        assert(PageProperty(p));
ffffffffc0200dc2:	00004697          	auipc	a3,0x4
ffffffffc0200dc6:	02668693          	addi	a3,a3,38 # ffffffffc0204de8 <commands+0x728>
ffffffffc0200dca:	00004617          	auipc	a2,0x4
ffffffffc0200dce:	02e60613          	addi	a2,a2,46 # ffffffffc0204df8 <commands+0x738>
ffffffffc0200dd2:	0f000593          	li	a1,240
ffffffffc0200dd6:	00004517          	auipc	a0,0x4
ffffffffc0200dda:	03a50513          	addi	a0,a0,58 # ffffffffc0204e10 <commands+0x750>
ffffffffc0200dde:	d96ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200de2:	00004697          	auipc	a3,0x4
ffffffffc0200de6:	0c668693          	addi	a3,a3,198 # ffffffffc0204ea8 <commands+0x7e8>
ffffffffc0200dea:	00004617          	auipc	a2,0x4
ffffffffc0200dee:	00e60613          	addi	a2,a2,14 # ffffffffc0204df8 <commands+0x738>
ffffffffc0200df2:	0bd00593          	li	a1,189
ffffffffc0200df6:	00004517          	auipc	a0,0x4
ffffffffc0200dfa:	01a50513          	addi	a0,a0,26 # ffffffffc0204e10 <commands+0x750>
ffffffffc0200dfe:	d76ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200e02:	00004697          	auipc	a3,0x4
ffffffffc0200e06:	0ce68693          	addi	a3,a3,206 # ffffffffc0204ed0 <commands+0x810>
ffffffffc0200e0a:	00004617          	auipc	a2,0x4
ffffffffc0200e0e:	fee60613          	addi	a2,a2,-18 # ffffffffc0204df8 <commands+0x738>
ffffffffc0200e12:	0be00593          	li	a1,190
ffffffffc0200e16:	00004517          	auipc	a0,0x4
ffffffffc0200e1a:	ffa50513          	addi	a0,a0,-6 # ffffffffc0204e10 <commands+0x750>
ffffffffc0200e1e:	d56ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200e22:	00004697          	auipc	a3,0x4
ffffffffc0200e26:	0ee68693          	addi	a3,a3,238 # ffffffffc0204f10 <commands+0x850>
ffffffffc0200e2a:	00004617          	auipc	a2,0x4
ffffffffc0200e2e:	fce60613          	addi	a2,a2,-50 # ffffffffc0204df8 <commands+0x738>
ffffffffc0200e32:	0c000593          	li	a1,192
ffffffffc0200e36:	00004517          	auipc	a0,0x4
ffffffffc0200e3a:	fda50513          	addi	a0,a0,-38 # ffffffffc0204e10 <commands+0x750>
ffffffffc0200e3e:	d36ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(!list_empty(&free_list));
ffffffffc0200e42:	00004697          	auipc	a3,0x4
ffffffffc0200e46:	15668693          	addi	a3,a3,342 # ffffffffc0204f98 <commands+0x8d8>
ffffffffc0200e4a:	00004617          	auipc	a2,0x4
ffffffffc0200e4e:	fae60613          	addi	a2,a2,-82 # ffffffffc0204df8 <commands+0x738>
ffffffffc0200e52:	0d900593          	li	a1,217
ffffffffc0200e56:	00004517          	auipc	a0,0x4
ffffffffc0200e5a:	fba50513          	addi	a0,a0,-70 # ffffffffc0204e10 <commands+0x750>
ffffffffc0200e5e:	d16ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200e62:	00004697          	auipc	a3,0x4
ffffffffc0200e66:	fe668693          	addi	a3,a3,-26 # ffffffffc0204e48 <commands+0x788>
ffffffffc0200e6a:	00004617          	auipc	a2,0x4
ffffffffc0200e6e:	f8e60613          	addi	a2,a2,-114 # ffffffffc0204df8 <commands+0x738>
ffffffffc0200e72:	0d200593          	li	a1,210
ffffffffc0200e76:	00004517          	auipc	a0,0x4
ffffffffc0200e7a:	f9a50513          	addi	a0,a0,-102 # ffffffffc0204e10 <commands+0x750>
ffffffffc0200e7e:	cf6ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(nr_free == 3);
ffffffffc0200e82:	00004697          	auipc	a3,0x4
ffffffffc0200e86:	10668693          	addi	a3,a3,262 # ffffffffc0204f88 <commands+0x8c8>
ffffffffc0200e8a:	00004617          	auipc	a2,0x4
ffffffffc0200e8e:	f6e60613          	addi	a2,a2,-146 # ffffffffc0204df8 <commands+0x738>
ffffffffc0200e92:	0d000593          	li	a1,208
ffffffffc0200e96:	00004517          	auipc	a0,0x4
ffffffffc0200e9a:	f7a50513          	addi	a0,a0,-134 # ffffffffc0204e10 <commands+0x750>
ffffffffc0200e9e:	cd6ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200ea2:	00004697          	auipc	a3,0x4
ffffffffc0200ea6:	0ce68693          	addi	a3,a3,206 # ffffffffc0204f70 <commands+0x8b0>
ffffffffc0200eaa:	00004617          	auipc	a2,0x4
ffffffffc0200eae:	f4e60613          	addi	a2,a2,-178 # ffffffffc0204df8 <commands+0x738>
ffffffffc0200eb2:	0cb00593          	li	a1,203
ffffffffc0200eb6:	00004517          	auipc	a0,0x4
ffffffffc0200eba:	f5a50513          	addi	a0,a0,-166 # ffffffffc0204e10 <commands+0x750>
ffffffffc0200ebe:	cb6ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200ec2:	00004697          	auipc	a3,0x4
ffffffffc0200ec6:	08e68693          	addi	a3,a3,142 # ffffffffc0204f50 <commands+0x890>
ffffffffc0200eca:	00004617          	auipc	a2,0x4
ffffffffc0200ece:	f2e60613          	addi	a2,a2,-210 # ffffffffc0204df8 <commands+0x738>
ffffffffc0200ed2:	0c200593          	li	a1,194
ffffffffc0200ed6:	00004517          	auipc	a0,0x4
ffffffffc0200eda:	f3a50513          	addi	a0,a0,-198 # ffffffffc0204e10 <commands+0x750>
ffffffffc0200ede:	c96ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(p0 != NULL);
ffffffffc0200ee2:	00004697          	auipc	a3,0x4
ffffffffc0200ee6:	0fe68693          	addi	a3,a3,254 # ffffffffc0204fe0 <commands+0x920>
ffffffffc0200eea:	00004617          	auipc	a2,0x4
ffffffffc0200eee:	f0e60613          	addi	a2,a2,-242 # ffffffffc0204df8 <commands+0x738>
ffffffffc0200ef2:	0f800593          	li	a1,248
ffffffffc0200ef6:	00004517          	auipc	a0,0x4
ffffffffc0200efa:	f1a50513          	addi	a0,a0,-230 # ffffffffc0204e10 <commands+0x750>
ffffffffc0200efe:	c76ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(nr_free == 0);
ffffffffc0200f02:	00004697          	auipc	a3,0x4
ffffffffc0200f06:	0ce68693          	addi	a3,a3,206 # ffffffffc0204fd0 <commands+0x910>
ffffffffc0200f0a:	00004617          	auipc	a2,0x4
ffffffffc0200f0e:	eee60613          	addi	a2,a2,-274 # ffffffffc0204df8 <commands+0x738>
ffffffffc0200f12:	0df00593          	li	a1,223
ffffffffc0200f16:	00004517          	auipc	a0,0x4
ffffffffc0200f1a:	efa50513          	addi	a0,a0,-262 # ffffffffc0204e10 <commands+0x750>
ffffffffc0200f1e:	c56ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200f22:	00004697          	auipc	a3,0x4
ffffffffc0200f26:	04e68693          	addi	a3,a3,78 # ffffffffc0204f70 <commands+0x8b0>
ffffffffc0200f2a:	00004617          	auipc	a2,0x4
ffffffffc0200f2e:	ece60613          	addi	a2,a2,-306 # ffffffffc0204df8 <commands+0x738>
ffffffffc0200f32:	0dd00593          	li	a1,221
ffffffffc0200f36:	00004517          	auipc	a0,0x4
ffffffffc0200f3a:	eda50513          	addi	a0,a0,-294 # ffffffffc0204e10 <commands+0x750>
ffffffffc0200f3e:	c36ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc0200f42:	00004697          	auipc	a3,0x4
ffffffffc0200f46:	06e68693          	addi	a3,a3,110 # ffffffffc0204fb0 <commands+0x8f0>
ffffffffc0200f4a:	00004617          	auipc	a2,0x4
ffffffffc0200f4e:	eae60613          	addi	a2,a2,-338 # ffffffffc0204df8 <commands+0x738>
ffffffffc0200f52:	0dc00593          	li	a1,220
ffffffffc0200f56:	00004517          	auipc	a0,0x4
ffffffffc0200f5a:	eba50513          	addi	a0,a0,-326 # ffffffffc0204e10 <commands+0x750>
ffffffffc0200f5e:	c16ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200f62:	00004697          	auipc	a3,0x4
ffffffffc0200f66:	ee668693          	addi	a3,a3,-282 # ffffffffc0204e48 <commands+0x788>
ffffffffc0200f6a:	00004617          	auipc	a2,0x4
ffffffffc0200f6e:	e8e60613          	addi	a2,a2,-370 # ffffffffc0204df8 <commands+0x738>
ffffffffc0200f72:	0b900593          	li	a1,185
ffffffffc0200f76:	00004517          	auipc	a0,0x4
ffffffffc0200f7a:	e9a50513          	addi	a0,a0,-358 # ffffffffc0204e10 <commands+0x750>
ffffffffc0200f7e:	bf6ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200f82:	00004697          	auipc	a3,0x4
ffffffffc0200f86:	fee68693          	addi	a3,a3,-18 # ffffffffc0204f70 <commands+0x8b0>
ffffffffc0200f8a:	00004617          	auipc	a2,0x4
ffffffffc0200f8e:	e6e60613          	addi	a2,a2,-402 # ffffffffc0204df8 <commands+0x738>
ffffffffc0200f92:	0d600593          	li	a1,214
ffffffffc0200f96:	00004517          	auipc	a0,0x4
ffffffffc0200f9a:	e7a50513          	addi	a0,a0,-390 # ffffffffc0204e10 <commands+0x750>
ffffffffc0200f9e:	bd6ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200fa2:	00004697          	auipc	a3,0x4
ffffffffc0200fa6:	ee668693          	addi	a3,a3,-282 # ffffffffc0204e88 <commands+0x7c8>
ffffffffc0200faa:	00004617          	auipc	a2,0x4
ffffffffc0200fae:	e4e60613          	addi	a2,a2,-434 # ffffffffc0204df8 <commands+0x738>
ffffffffc0200fb2:	0d400593          	li	a1,212
ffffffffc0200fb6:	00004517          	auipc	a0,0x4
ffffffffc0200fba:	e5a50513          	addi	a0,a0,-422 # ffffffffc0204e10 <commands+0x750>
ffffffffc0200fbe:	bb6ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200fc2:	00004697          	auipc	a3,0x4
ffffffffc0200fc6:	ea668693          	addi	a3,a3,-346 # ffffffffc0204e68 <commands+0x7a8>
ffffffffc0200fca:	00004617          	auipc	a2,0x4
ffffffffc0200fce:	e2e60613          	addi	a2,a2,-466 # ffffffffc0204df8 <commands+0x738>
ffffffffc0200fd2:	0d300593          	li	a1,211
ffffffffc0200fd6:	00004517          	auipc	a0,0x4
ffffffffc0200fda:	e3a50513          	addi	a0,a0,-454 # ffffffffc0204e10 <commands+0x750>
ffffffffc0200fde:	b96ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200fe2:	00004697          	auipc	a3,0x4
ffffffffc0200fe6:	ea668693          	addi	a3,a3,-346 # ffffffffc0204e88 <commands+0x7c8>
ffffffffc0200fea:	00004617          	auipc	a2,0x4
ffffffffc0200fee:	e0e60613          	addi	a2,a2,-498 # ffffffffc0204df8 <commands+0x738>
ffffffffc0200ff2:	0bb00593          	li	a1,187
ffffffffc0200ff6:	00004517          	auipc	a0,0x4
ffffffffc0200ffa:	e1a50513          	addi	a0,a0,-486 # ffffffffc0204e10 <commands+0x750>
ffffffffc0200ffe:	b76ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(count == 0);
ffffffffc0201002:	00004697          	auipc	a3,0x4
ffffffffc0201006:	12e68693          	addi	a3,a3,302 # ffffffffc0205130 <commands+0xa70>
ffffffffc020100a:	00004617          	auipc	a2,0x4
ffffffffc020100e:	dee60613          	addi	a2,a2,-530 # ffffffffc0204df8 <commands+0x738>
ffffffffc0201012:	12500593          	li	a1,293
ffffffffc0201016:	00004517          	auipc	a0,0x4
ffffffffc020101a:	dfa50513          	addi	a0,a0,-518 # ffffffffc0204e10 <commands+0x750>
ffffffffc020101e:	b56ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(nr_free == 0);
ffffffffc0201022:	00004697          	auipc	a3,0x4
ffffffffc0201026:	fae68693          	addi	a3,a3,-82 # ffffffffc0204fd0 <commands+0x910>
ffffffffc020102a:	00004617          	auipc	a2,0x4
ffffffffc020102e:	dce60613          	addi	a2,a2,-562 # ffffffffc0204df8 <commands+0x738>
ffffffffc0201032:	11a00593          	li	a1,282
ffffffffc0201036:	00004517          	auipc	a0,0x4
ffffffffc020103a:	dda50513          	addi	a0,a0,-550 # ffffffffc0204e10 <commands+0x750>
ffffffffc020103e:	b36ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201042:	00004697          	auipc	a3,0x4
ffffffffc0201046:	f2e68693          	addi	a3,a3,-210 # ffffffffc0204f70 <commands+0x8b0>
ffffffffc020104a:	00004617          	auipc	a2,0x4
ffffffffc020104e:	dae60613          	addi	a2,a2,-594 # ffffffffc0204df8 <commands+0x738>
ffffffffc0201052:	11800593          	li	a1,280
ffffffffc0201056:	00004517          	auipc	a0,0x4
ffffffffc020105a:	dba50513          	addi	a0,a0,-582 # ffffffffc0204e10 <commands+0x750>
ffffffffc020105e:	b16ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0201062:	00004697          	auipc	a3,0x4
ffffffffc0201066:	ece68693          	addi	a3,a3,-306 # ffffffffc0204f30 <commands+0x870>
ffffffffc020106a:	00004617          	auipc	a2,0x4
ffffffffc020106e:	d8e60613          	addi	a2,a2,-626 # ffffffffc0204df8 <commands+0x738>
ffffffffc0201072:	0c100593          	li	a1,193
ffffffffc0201076:	00004517          	auipc	a0,0x4
ffffffffc020107a:	d9a50513          	addi	a0,a0,-614 # ffffffffc0204e10 <commands+0x750>
ffffffffc020107e:	af6ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0201082:	00004697          	auipc	a3,0x4
ffffffffc0201086:	06e68693          	addi	a3,a3,110 # ffffffffc02050f0 <commands+0xa30>
ffffffffc020108a:	00004617          	auipc	a2,0x4
ffffffffc020108e:	d6e60613          	addi	a2,a2,-658 # ffffffffc0204df8 <commands+0x738>
ffffffffc0201092:	11200593          	li	a1,274
ffffffffc0201096:	00004517          	auipc	a0,0x4
ffffffffc020109a:	d7a50513          	addi	a0,a0,-646 # ffffffffc0204e10 <commands+0x750>
ffffffffc020109e:	ad6ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc02010a2:	00004697          	auipc	a3,0x4
ffffffffc02010a6:	02e68693          	addi	a3,a3,46 # ffffffffc02050d0 <commands+0xa10>
ffffffffc02010aa:	00004617          	auipc	a2,0x4
ffffffffc02010ae:	d4e60613          	addi	a2,a2,-690 # ffffffffc0204df8 <commands+0x738>
ffffffffc02010b2:	11000593          	li	a1,272
ffffffffc02010b6:	00004517          	auipc	a0,0x4
ffffffffc02010ba:	d5a50513          	addi	a0,a0,-678 # ffffffffc0204e10 <commands+0x750>
ffffffffc02010be:	ab6ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc02010c2:	00004697          	auipc	a3,0x4
ffffffffc02010c6:	fe668693          	addi	a3,a3,-26 # ffffffffc02050a8 <commands+0x9e8>
ffffffffc02010ca:	00004617          	auipc	a2,0x4
ffffffffc02010ce:	d2e60613          	addi	a2,a2,-722 # ffffffffc0204df8 <commands+0x738>
ffffffffc02010d2:	10e00593          	li	a1,270
ffffffffc02010d6:	00004517          	auipc	a0,0x4
ffffffffc02010da:	d3a50513          	addi	a0,a0,-710 # ffffffffc0204e10 <commands+0x750>
ffffffffc02010de:	a96ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc02010e2:	00004697          	auipc	a3,0x4
ffffffffc02010e6:	f9e68693          	addi	a3,a3,-98 # ffffffffc0205080 <commands+0x9c0>
ffffffffc02010ea:	00004617          	auipc	a2,0x4
ffffffffc02010ee:	d0e60613          	addi	a2,a2,-754 # ffffffffc0204df8 <commands+0x738>
ffffffffc02010f2:	10d00593          	li	a1,269
ffffffffc02010f6:	00004517          	auipc	a0,0x4
ffffffffc02010fa:	d1a50513          	addi	a0,a0,-742 # ffffffffc0204e10 <commands+0x750>
ffffffffc02010fe:	a76ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(p0 + 2 == p1);
ffffffffc0201102:	00004697          	auipc	a3,0x4
ffffffffc0201106:	f6e68693          	addi	a3,a3,-146 # ffffffffc0205070 <commands+0x9b0>
ffffffffc020110a:	00004617          	auipc	a2,0x4
ffffffffc020110e:	cee60613          	addi	a2,a2,-786 # ffffffffc0204df8 <commands+0x738>
ffffffffc0201112:	10800593          	li	a1,264
ffffffffc0201116:	00004517          	auipc	a0,0x4
ffffffffc020111a:	cfa50513          	addi	a0,a0,-774 # ffffffffc0204e10 <commands+0x750>
ffffffffc020111e:	a56ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201122:	00004697          	auipc	a3,0x4
ffffffffc0201126:	e4e68693          	addi	a3,a3,-434 # ffffffffc0204f70 <commands+0x8b0>
ffffffffc020112a:	00004617          	auipc	a2,0x4
ffffffffc020112e:	cce60613          	addi	a2,a2,-818 # ffffffffc0204df8 <commands+0x738>
ffffffffc0201132:	10700593          	li	a1,263
ffffffffc0201136:	00004517          	auipc	a0,0x4
ffffffffc020113a:	cda50513          	addi	a0,a0,-806 # ffffffffc0204e10 <commands+0x750>
ffffffffc020113e:	a36ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0201142:	00004697          	auipc	a3,0x4
ffffffffc0201146:	f0e68693          	addi	a3,a3,-242 # ffffffffc0205050 <commands+0x990>
ffffffffc020114a:	00004617          	auipc	a2,0x4
ffffffffc020114e:	cae60613          	addi	a2,a2,-850 # ffffffffc0204df8 <commands+0x738>
ffffffffc0201152:	10600593          	li	a1,262
ffffffffc0201156:	00004517          	auipc	a0,0x4
ffffffffc020115a:	cba50513          	addi	a0,a0,-838 # ffffffffc0204e10 <commands+0x750>
ffffffffc020115e:	a16ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0201162:	00004697          	auipc	a3,0x4
ffffffffc0201166:	ebe68693          	addi	a3,a3,-322 # ffffffffc0205020 <commands+0x960>
ffffffffc020116a:	00004617          	auipc	a2,0x4
ffffffffc020116e:	c8e60613          	addi	a2,a2,-882 # ffffffffc0204df8 <commands+0x738>
ffffffffc0201172:	10500593          	li	a1,261
ffffffffc0201176:	00004517          	auipc	a0,0x4
ffffffffc020117a:	c9a50513          	addi	a0,a0,-870 # ffffffffc0204e10 <commands+0x750>
ffffffffc020117e:	9f6ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc0201182:	00004697          	auipc	a3,0x4
ffffffffc0201186:	e8668693          	addi	a3,a3,-378 # ffffffffc0205008 <commands+0x948>
ffffffffc020118a:	00004617          	auipc	a2,0x4
ffffffffc020118e:	c6e60613          	addi	a2,a2,-914 # ffffffffc0204df8 <commands+0x738>
ffffffffc0201192:	10400593          	li	a1,260
ffffffffc0201196:	00004517          	auipc	a0,0x4
ffffffffc020119a:	c7a50513          	addi	a0,a0,-902 # ffffffffc0204e10 <commands+0x750>
ffffffffc020119e:	9d6ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02011a2:	00004697          	auipc	a3,0x4
ffffffffc02011a6:	dce68693          	addi	a3,a3,-562 # ffffffffc0204f70 <commands+0x8b0>
ffffffffc02011aa:	00004617          	auipc	a2,0x4
ffffffffc02011ae:	c4e60613          	addi	a2,a2,-946 # ffffffffc0204df8 <commands+0x738>
ffffffffc02011b2:	0fe00593          	li	a1,254
ffffffffc02011b6:	00004517          	auipc	a0,0x4
ffffffffc02011ba:	c5a50513          	addi	a0,a0,-934 # ffffffffc0204e10 <commands+0x750>
ffffffffc02011be:	9b6ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(!PageProperty(p0));
ffffffffc02011c2:	00004697          	auipc	a3,0x4
ffffffffc02011c6:	e2e68693          	addi	a3,a3,-466 # ffffffffc0204ff0 <commands+0x930>
ffffffffc02011ca:	00004617          	auipc	a2,0x4
ffffffffc02011ce:	c2e60613          	addi	a2,a2,-978 # ffffffffc0204df8 <commands+0x738>
ffffffffc02011d2:	0f900593          	li	a1,249
ffffffffc02011d6:	00004517          	auipc	a0,0x4
ffffffffc02011da:	c3a50513          	addi	a0,a0,-966 # ffffffffc0204e10 <commands+0x750>
ffffffffc02011de:	996ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc02011e2:	00004697          	auipc	a3,0x4
ffffffffc02011e6:	f2e68693          	addi	a3,a3,-210 # ffffffffc0205110 <commands+0xa50>
ffffffffc02011ea:	00004617          	auipc	a2,0x4
ffffffffc02011ee:	c0e60613          	addi	a2,a2,-1010 # ffffffffc0204df8 <commands+0x738>
ffffffffc02011f2:	11700593          	li	a1,279
ffffffffc02011f6:	00004517          	auipc	a0,0x4
ffffffffc02011fa:	c1a50513          	addi	a0,a0,-998 # ffffffffc0204e10 <commands+0x750>
ffffffffc02011fe:	976ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(total == 0);
ffffffffc0201202:	00004697          	auipc	a3,0x4
ffffffffc0201206:	f3e68693          	addi	a3,a3,-194 # ffffffffc0205140 <commands+0xa80>
ffffffffc020120a:	00004617          	auipc	a2,0x4
ffffffffc020120e:	bee60613          	addi	a2,a2,-1042 # ffffffffc0204df8 <commands+0x738>
ffffffffc0201212:	12600593          	li	a1,294
ffffffffc0201216:	00004517          	auipc	a0,0x4
ffffffffc020121a:	bfa50513          	addi	a0,a0,-1030 # ffffffffc0204e10 <commands+0x750>
ffffffffc020121e:	956ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(total == nr_free_pages());
ffffffffc0201222:	00004697          	auipc	a3,0x4
ffffffffc0201226:	c0668693          	addi	a3,a3,-1018 # ffffffffc0204e28 <commands+0x768>
ffffffffc020122a:	00004617          	auipc	a2,0x4
ffffffffc020122e:	bce60613          	addi	a2,a2,-1074 # ffffffffc0204df8 <commands+0x738>
ffffffffc0201232:	0f300593          	li	a1,243
ffffffffc0201236:	00004517          	auipc	a0,0x4
ffffffffc020123a:	bda50513          	addi	a0,a0,-1062 # ffffffffc0204e10 <commands+0x750>
ffffffffc020123e:	936ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201242:	00004697          	auipc	a3,0x4
ffffffffc0201246:	c2668693          	addi	a3,a3,-986 # ffffffffc0204e68 <commands+0x7a8>
ffffffffc020124a:	00004617          	auipc	a2,0x4
ffffffffc020124e:	bae60613          	addi	a2,a2,-1106 # ffffffffc0204df8 <commands+0x738>
ffffffffc0201252:	0ba00593          	li	a1,186
ffffffffc0201256:	00004517          	auipc	a0,0x4
ffffffffc020125a:	bba50513          	addi	a0,a0,-1094 # ffffffffc0204e10 <commands+0x750>
ffffffffc020125e:	916ff0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0201262 <default_free_pages>:
default_free_pages(struct Page *base, size_t n) {
ffffffffc0201262:	1141                	addi	sp,sp,-16
ffffffffc0201264:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201266:	14058a63          	beqz	a1,ffffffffc02013ba <default_free_pages+0x158>
    for (; p != base + n; p ++) {
ffffffffc020126a:	00359693          	slli	a3,a1,0x3
ffffffffc020126e:	96ae                	add	a3,a3,a1
ffffffffc0201270:	068e                	slli	a3,a3,0x3
ffffffffc0201272:	96aa                	add	a3,a3,a0
ffffffffc0201274:	87aa                	mv	a5,a0
ffffffffc0201276:	02d50263          	beq	a0,a3,ffffffffc020129a <default_free_pages+0x38>
ffffffffc020127a:	6798                	ld	a4,8(a5)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc020127c:	8b05                	andi	a4,a4,1
ffffffffc020127e:	10071e63          	bnez	a4,ffffffffc020139a <default_free_pages+0x138>
ffffffffc0201282:	6798                	ld	a4,8(a5)
ffffffffc0201284:	8b09                	andi	a4,a4,2
ffffffffc0201286:	10071a63          	bnez	a4,ffffffffc020139a <default_free_pages+0x138>
        p->flags = 0;
ffffffffc020128a:	0007b423          	sd	zero,8(a5)
    return pa2page(PDE_ADDR(pde));
}

static inline int page_ref(struct Page *page) { return page->ref; }

static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc020128e:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0201292:	04878793          	addi	a5,a5,72
ffffffffc0201296:	fed792e3          	bne	a5,a3,ffffffffc020127a <default_free_pages+0x18>
    base->property = n;
ffffffffc020129a:	2581                	sext.w	a1,a1
ffffffffc020129c:	cd0c                	sw	a1,24(a0)
    SetPageProperty(base);
ffffffffc020129e:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02012a2:	4789                	li	a5,2
ffffffffc02012a4:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc02012a8:	00010697          	auipc	a3,0x10
ffffffffc02012ac:	d9868693          	addi	a3,a3,-616 # ffffffffc0211040 <free_area>
ffffffffc02012b0:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc02012b2:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc02012b4:	02050613          	addi	a2,a0,32
    nr_free += n;
ffffffffc02012b8:	9db9                	addw	a1,a1,a4
ffffffffc02012ba:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc02012bc:	0ad78863          	beq	a5,a3,ffffffffc020136c <default_free_pages+0x10a>
            struct Page* page = le2page(le, page_link);
ffffffffc02012c0:	fe078713          	addi	a4,a5,-32
ffffffffc02012c4:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc02012c8:	4581                	li	a1,0
            if (base < page) {
ffffffffc02012ca:	00e56a63          	bltu	a0,a4,ffffffffc02012de <default_free_pages+0x7c>
    return listelm->next;
ffffffffc02012ce:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc02012d0:	06d70263          	beq	a4,a3,ffffffffc0201334 <default_free_pages+0xd2>
    for (; p != base + n; p ++) {
ffffffffc02012d4:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc02012d6:	fe078713          	addi	a4,a5,-32
            if (base < page) {
ffffffffc02012da:	fee57ae3          	bgeu	a0,a4,ffffffffc02012ce <default_free_pages+0x6c>
ffffffffc02012de:	c199                	beqz	a1,ffffffffc02012e4 <default_free_pages+0x82>
ffffffffc02012e0:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc02012e4:	6398                	ld	a4,0(a5)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc02012e6:	e390                	sd	a2,0(a5)
ffffffffc02012e8:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc02012ea:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc02012ec:	f118                	sd	a4,32(a0)
    if (le != &free_list) {
ffffffffc02012ee:	02d70063          	beq	a4,a3,ffffffffc020130e <default_free_pages+0xac>
        if (p + p->property == base) {
ffffffffc02012f2:	ff872803          	lw	a6,-8(a4)
        p = le2page(le, page_link);
ffffffffc02012f6:	fe070593          	addi	a1,a4,-32
        if (p + p->property == base) {
ffffffffc02012fa:	02081613          	slli	a2,a6,0x20
ffffffffc02012fe:	9201                	srli	a2,a2,0x20
ffffffffc0201300:	00361793          	slli	a5,a2,0x3
ffffffffc0201304:	97b2                	add	a5,a5,a2
ffffffffc0201306:	078e                	slli	a5,a5,0x3
ffffffffc0201308:	97ae                	add	a5,a5,a1
ffffffffc020130a:	02f50f63          	beq	a0,a5,ffffffffc0201348 <default_free_pages+0xe6>
    return listelm->next;
ffffffffc020130e:	7518                	ld	a4,40(a0)
    if (le != &free_list) {
ffffffffc0201310:	00d70f63          	beq	a4,a3,ffffffffc020132e <default_free_pages+0xcc>
        if (base + base->property == p) {
ffffffffc0201314:	4d0c                	lw	a1,24(a0)
        p = le2page(le, page_link);
ffffffffc0201316:	fe070693          	addi	a3,a4,-32
        if (base + base->property == p) {
ffffffffc020131a:	02059613          	slli	a2,a1,0x20
ffffffffc020131e:	9201                	srli	a2,a2,0x20
ffffffffc0201320:	00361793          	slli	a5,a2,0x3
ffffffffc0201324:	97b2                	add	a5,a5,a2
ffffffffc0201326:	078e                	slli	a5,a5,0x3
ffffffffc0201328:	97aa                	add	a5,a5,a0
ffffffffc020132a:	04f68863          	beq	a3,a5,ffffffffc020137a <default_free_pages+0x118>
}
ffffffffc020132e:	60a2                	ld	ra,8(sp)
ffffffffc0201330:	0141                	addi	sp,sp,16
ffffffffc0201332:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0201334:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201336:	f514                	sd	a3,40(a0)
    return listelm->next;
ffffffffc0201338:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc020133a:	f11c                	sd	a5,32(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc020133c:	02d70563          	beq	a4,a3,ffffffffc0201366 <default_free_pages+0x104>
    prev->next = next->prev = elm;
ffffffffc0201340:	8832                	mv	a6,a2
ffffffffc0201342:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc0201344:	87ba                	mv	a5,a4
ffffffffc0201346:	bf41                	j	ffffffffc02012d6 <default_free_pages+0x74>
            p->property += base->property;
ffffffffc0201348:	4d1c                	lw	a5,24(a0)
ffffffffc020134a:	0107883b          	addw	a6,a5,a6
ffffffffc020134e:	ff072c23          	sw	a6,-8(a4)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0201352:	57f5                	li	a5,-3
ffffffffc0201354:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201358:	7110                	ld	a2,32(a0)
ffffffffc020135a:	751c                	ld	a5,40(a0)
            base = p;
ffffffffc020135c:	852e                	mv	a0,a1
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc020135e:	e61c                	sd	a5,8(a2)
    return listelm->next;
ffffffffc0201360:	6718                	ld	a4,8(a4)
    next->prev = prev;
ffffffffc0201362:	e390                	sd	a2,0(a5)
ffffffffc0201364:	b775                	j	ffffffffc0201310 <default_free_pages+0xae>
ffffffffc0201366:	e290                	sd	a2,0(a3)
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201368:	873e                	mv	a4,a5
ffffffffc020136a:	b761                	j	ffffffffc02012f2 <default_free_pages+0x90>
}
ffffffffc020136c:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc020136e:	e390                	sd	a2,0(a5)
ffffffffc0201370:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201372:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc0201374:	f11c                	sd	a5,32(a0)
ffffffffc0201376:	0141                	addi	sp,sp,16
ffffffffc0201378:	8082                	ret
            base->property += p->property;
ffffffffc020137a:	ff872783          	lw	a5,-8(a4)
ffffffffc020137e:	fe870693          	addi	a3,a4,-24
ffffffffc0201382:	9dbd                	addw	a1,a1,a5
ffffffffc0201384:	cd0c                	sw	a1,24(a0)
ffffffffc0201386:	57f5                	li	a5,-3
ffffffffc0201388:	60f6b02f          	amoand.d	zero,a5,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc020138c:	6314                	ld	a3,0(a4)
ffffffffc020138e:	671c                	ld	a5,8(a4)
}
ffffffffc0201390:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc0201392:	e69c                	sd	a5,8(a3)
    next->prev = prev;
ffffffffc0201394:	e394                	sd	a3,0(a5)
ffffffffc0201396:	0141                	addi	sp,sp,16
ffffffffc0201398:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc020139a:	00004697          	auipc	a3,0x4
ffffffffc020139e:	dbe68693          	addi	a3,a3,-578 # ffffffffc0205158 <commands+0xa98>
ffffffffc02013a2:	00004617          	auipc	a2,0x4
ffffffffc02013a6:	a5660613          	addi	a2,a2,-1450 # ffffffffc0204df8 <commands+0x738>
ffffffffc02013aa:	08300593          	li	a1,131
ffffffffc02013ae:	00004517          	auipc	a0,0x4
ffffffffc02013b2:	a6250513          	addi	a0,a0,-1438 # ffffffffc0204e10 <commands+0x750>
ffffffffc02013b6:	fbffe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(n > 0);
ffffffffc02013ba:	00004697          	auipc	a3,0x4
ffffffffc02013be:	d9668693          	addi	a3,a3,-618 # ffffffffc0205150 <commands+0xa90>
ffffffffc02013c2:	00004617          	auipc	a2,0x4
ffffffffc02013c6:	a3660613          	addi	a2,a2,-1482 # ffffffffc0204df8 <commands+0x738>
ffffffffc02013ca:	08000593          	li	a1,128
ffffffffc02013ce:	00004517          	auipc	a0,0x4
ffffffffc02013d2:	a4250513          	addi	a0,a0,-1470 # ffffffffc0204e10 <commands+0x750>
ffffffffc02013d6:	f9ffe0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc02013da <default_alloc_pages>:
    assert(n > 0);
ffffffffc02013da:	c959                	beqz	a0,ffffffffc0201470 <default_alloc_pages+0x96>
    if (n > nr_free) {
ffffffffc02013dc:	00010597          	auipc	a1,0x10
ffffffffc02013e0:	c6458593          	addi	a1,a1,-924 # ffffffffc0211040 <free_area>
ffffffffc02013e4:	0105a803          	lw	a6,16(a1)
ffffffffc02013e8:	862a                	mv	a2,a0
ffffffffc02013ea:	02081793          	slli	a5,a6,0x20
ffffffffc02013ee:	9381                	srli	a5,a5,0x20
ffffffffc02013f0:	00a7ee63          	bltu	a5,a0,ffffffffc020140c <default_alloc_pages+0x32>
    list_entry_t *le = &free_list;
ffffffffc02013f4:	87ae                	mv	a5,a1
ffffffffc02013f6:	a801                	j	ffffffffc0201406 <default_alloc_pages+0x2c>
        if (p->property >= n) {
ffffffffc02013f8:	ff87a703          	lw	a4,-8(a5)
ffffffffc02013fc:	02071693          	slli	a3,a4,0x20
ffffffffc0201400:	9281                	srli	a3,a3,0x20
ffffffffc0201402:	00c6f763          	bgeu	a3,a2,ffffffffc0201410 <default_alloc_pages+0x36>
    return listelm->next;
ffffffffc0201406:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201408:	feb798e3          	bne	a5,a1,ffffffffc02013f8 <default_alloc_pages+0x1e>
        return NULL;
ffffffffc020140c:	4501                	li	a0,0
}
ffffffffc020140e:	8082                	ret
    return listelm->prev;
ffffffffc0201410:	0007b883          	ld	a7,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201414:	0087b303          	ld	t1,8(a5)
        struct Page *p = le2page(le, page_link);
ffffffffc0201418:	fe078513          	addi	a0,a5,-32
            p->property = page->property - n;
ffffffffc020141c:	00060e1b          	sext.w	t3,a2
    prev->next = next;
ffffffffc0201420:	0068b423          	sd	t1,8(a7)
    next->prev = prev;
ffffffffc0201424:	01133023          	sd	a7,0(t1)
        if (page->property > n) {
ffffffffc0201428:	02d67b63          	bgeu	a2,a3,ffffffffc020145e <default_alloc_pages+0x84>
            struct Page *p = page + n;
ffffffffc020142c:	00361693          	slli	a3,a2,0x3
ffffffffc0201430:	96b2                	add	a3,a3,a2
ffffffffc0201432:	068e                	slli	a3,a3,0x3
ffffffffc0201434:	96aa                	add	a3,a3,a0
            p->property = page->property - n;
ffffffffc0201436:	41c7073b          	subw	a4,a4,t3
ffffffffc020143a:	ce98                	sw	a4,24(a3)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020143c:	00868613          	addi	a2,a3,8
ffffffffc0201440:	4709                	li	a4,2
ffffffffc0201442:	40e6302f          	amoor.d	zero,a4,(a2)
    __list_add(elm, listelm, listelm->next);
ffffffffc0201446:	0088b703          	ld	a4,8(a7)
            list_add(prev, &(p->page_link));
ffffffffc020144a:	02068613          	addi	a2,a3,32
        nr_free -= n;
ffffffffc020144e:	0105a803          	lw	a6,16(a1)
    prev->next = next->prev = elm;
ffffffffc0201452:	e310                	sd	a2,0(a4)
ffffffffc0201454:	00c8b423          	sd	a2,8(a7)
    elm->next = next;
ffffffffc0201458:	f698                	sd	a4,40(a3)
    elm->prev = prev;
ffffffffc020145a:	0316b023          	sd	a7,32(a3)
ffffffffc020145e:	41c8083b          	subw	a6,a6,t3
ffffffffc0201462:	0105a823          	sw	a6,16(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0201466:	5775                	li	a4,-3
ffffffffc0201468:	17a1                	addi	a5,a5,-24
ffffffffc020146a:	60e7b02f          	amoand.d	zero,a4,(a5)
}
ffffffffc020146e:	8082                	ret
default_alloc_pages(size_t n) {
ffffffffc0201470:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc0201472:	00004697          	auipc	a3,0x4
ffffffffc0201476:	cde68693          	addi	a3,a3,-802 # ffffffffc0205150 <commands+0xa90>
ffffffffc020147a:	00004617          	auipc	a2,0x4
ffffffffc020147e:	97e60613          	addi	a2,a2,-1666 # ffffffffc0204df8 <commands+0x738>
ffffffffc0201482:	06200593          	li	a1,98
ffffffffc0201486:	00004517          	auipc	a0,0x4
ffffffffc020148a:	98a50513          	addi	a0,a0,-1654 # ffffffffc0204e10 <commands+0x750>
default_alloc_pages(size_t n) {
ffffffffc020148e:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201490:	ee5fe0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0201494 <default_init_memmap>:
default_init_memmap(struct Page *base, size_t n) {
ffffffffc0201494:	1141                	addi	sp,sp,-16
ffffffffc0201496:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201498:	c9e1                	beqz	a1,ffffffffc0201568 <default_init_memmap+0xd4>
    for (; p != base + n; p ++) {
ffffffffc020149a:	00359693          	slli	a3,a1,0x3
ffffffffc020149e:	96ae                	add	a3,a3,a1
ffffffffc02014a0:	068e                	slli	a3,a3,0x3
ffffffffc02014a2:	96aa                	add	a3,a3,a0
ffffffffc02014a4:	87aa                	mv	a5,a0
ffffffffc02014a6:	00d50f63          	beq	a0,a3,ffffffffc02014c4 <default_init_memmap+0x30>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc02014aa:	6798                	ld	a4,8(a5)
        assert(PageReserved(p));
ffffffffc02014ac:	8b05                	andi	a4,a4,1
ffffffffc02014ae:	cf49                	beqz	a4,ffffffffc0201548 <default_init_memmap+0xb4>
        p->flags = p->property = 0;
ffffffffc02014b0:	0007ac23          	sw	zero,24(a5)
ffffffffc02014b4:	0007b423          	sd	zero,8(a5)
ffffffffc02014b8:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc02014bc:	04878793          	addi	a5,a5,72
ffffffffc02014c0:	fed795e3          	bne	a5,a3,ffffffffc02014aa <default_init_memmap+0x16>
    base->property = n;
ffffffffc02014c4:	2581                	sext.w	a1,a1
ffffffffc02014c6:	cd0c                	sw	a1,24(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02014c8:	4789                	li	a5,2
ffffffffc02014ca:	00850713          	addi	a4,a0,8
ffffffffc02014ce:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc02014d2:	00010697          	auipc	a3,0x10
ffffffffc02014d6:	b6e68693          	addi	a3,a3,-1170 # ffffffffc0211040 <free_area>
ffffffffc02014da:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc02014dc:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc02014de:	02050613          	addi	a2,a0,32
    nr_free += n;
ffffffffc02014e2:	9db9                	addw	a1,a1,a4
ffffffffc02014e4:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc02014e6:	04d78a63          	beq	a5,a3,ffffffffc020153a <default_init_memmap+0xa6>
            struct Page* page = le2page(le, page_link);
ffffffffc02014ea:	fe078713          	addi	a4,a5,-32
ffffffffc02014ee:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc02014f2:	4581                	li	a1,0
            if (base < page) {
ffffffffc02014f4:	00e56a63          	bltu	a0,a4,ffffffffc0201508 <default_init_memmap+0x74>
    return listelm->next;
ffffffffc02014f8:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc02014fa:	02d70263          	beq	a4,a3,ffffffffc020151e <default_init_memmap+0x8a>
    for (; p != base + n; p ++) {
ffffffffc02014fe:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0201500:	fe078713          	addi	a4,a5,-32
            if (base < page) {
ffffffffc0201504:	fee57ae3          	bgeu	a0,a4,ffffffffc02014f8 <default_init_memmap+0x64>
ffffffffc0201508:	c199                	beqz	a1,ffffffffc020150e <default_init_memmap+0x7a>
ffffffffc020150a:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc020150e:	6398                	ld	a4,0(a5)
}
ffffffffc0201510:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0201512:	e390                	sd	a2,0(a5)
ffffffffc0201514:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc0201516:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc0201518:	f118                	sd	a4,32(a0)
ffffffffc020151a:	0141                	addi	sp,sp,16
ffffffffc020151c:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc020151e:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201520:	f514                	sd	a3,40(a0)
    return listelm->next;
ffffffffc0201522:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0201524:	f11c                	sd	a5,32(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201526:	00d70663          	beq	a4,a3,ffffffffc0201532 <default_init_memmap+0x9e>
    prev->next = next->prev = elm;
ffffffffc020152a:	8832                	mv	a6,a2
ffffffffc020152c:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc020152e:	87ba                	mv	a5,a4
ffffffffc0201530:	bfc1                	j	ffffffffc0201500 <default_init_memmap+0x6c>
}
ffffffffc0201532:	60a2                	ld	ra,8(sp)
ffffffffc0201534:	e290                	sd	a2,0(a3)
ffffffffc0201536:	0141                	addi	sp,sp,16
ffffffffc0201538:	8082                	ret
ffffffffc020153a:	60a2                	ld	ra,8(sp)
ffffffffc020153c:	e390                	sd	a2,0(a5)
ffffffffc020153e:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201540:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc0201542:	f11c                	sd	a5,32(a0)
ffffffffc0201544:	0141                	addi	sp,sp,16
ffffffffc0201546:	8082                	ret
        assert(PageReserved(p));
ffffffffc0201548:	00004697          	auipc	a3,0x4
ffffffffc020154c:	c3868693          	addi	a3,a3,-968 # ffffffffc0205180 <commands+0xac0>
ffffffffc0201550:	00004617          	auipc	a2,0x4
ffffffffc0201554:	8a860613          	addi	a2,a2,-1880 # ffffffffc0204df8 <commands+0x738>
ffffffffc0201558:	04900593          	li	a1,73
ffffffffc020155c:	00004517          	auipc	a0,0x4
ffffffffc0201560:	8b450513          	addi	a0,a0,-1868 # ffffffffc0204e10 <commands+0x750>
ffffffffc0201564:	e11fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(n > 0);
ffffffffc0201568:	00004697          	auipc	a3,0x4
ffffffffc020156c:	be868693          	addi	a3,a3,-1048 # ffffffffc0205150 <commands+0xa90>
ffffffffc0201570:	00004617          	auipc	a2,0x4
ffffffffc0201574:	88860613          	addi	a2,a2,-1912 # ffffffffc0204df8 <commands+0x738>
ffffffffc0201578:	04600593          	li	a1,70
ffffffffc020157c:	00004517          	auipc	a0,0x4
ffffffffc0201580:	89450513          	addi	a0,a0,-1900 # ffffffffc0204e10 <commands+0x750>
ffffffffc0201584:	df1fe0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0201588 <pa2page.part.0>:
static inline struct Page *pa2page(uintptr_t pa) {
ffffffffc0201588:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc020158a:	00004617          	auipc	a2,0x4
ffffffffc020158e:	c5660613          	addi	a2,a2,-938 # ffffffffc02051e0 <default_pmm_manager+0x38>
ffffffffc0201592:	06500593          	li	a1,101
ffffffffc0201596:	00004517          	auipc	a0,0x4
ffffffffc020159a:	c6a50513          	addi	a0,a0,-918 # ffffffffc0205200 <default_pmm_manager+0x58>
static inline struct Page *pa2page(uintptr_t pa) {
ffffffffc020159e:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc02015a0:	dd5fe0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc02015a4 <pte2page.part.0>:
static inline struct Page *pte2page(pte_t pte) {
ffffffffc02015a4:	1141                	addi	sp,sp,-16
        panic("pte2page called with invalid pte");
ffffffffc02015a6:	00004617          	auipc	a2,0x4
ffffffffc02015aa:	c6a60613          	addi	a2,a2,-918 # ffffffffc0205210 <default_pmm_manager+0x68>
ffffffffc02015ae:	07000593          	li	a1,112
ffffffffc02015b2:	00004517          	auipc	a0,0x4
ffffffffc02015b6:	c4e50513          	addi	a0,a0,-946 # ffffffffc0205200 <default_pmm_manager+0x58>
static inline struct Page *pte2page(pte_t pte) {
ffffffffc02015ba:	e406                	sd	ra,8(sp)
        panic("pte2page called with invalid pte");
ffffffffc02015bc:	db9fe0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc02015c0 <alloc_pages>:
    pmm_manager->init_memmap(base, n);
}

// alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE
// memory
struct Page *alloc_pages(size_t n) {
ffffffffc02015c0:	7139                	addi	sp,sp,-64
ffffffffc02015c2:	f426                	sd	s1,40(sp)
ffffffffc02015c4:	f04a                	sd	s2,32(sp)
ffffffffc02015c6:	ec4e                	sd	s3,24(sp)
ffffffffc02015c8:	e852                	sd	s4,16(sp)
ffffffffc02015ca:	e456                	sd	s5,8(sp)
ffffffffc02015cc:	e05a                	sd	s6,0(sp)
ffffffffc02015ce:	fc06                	sd	ra,56(sp)
ffffffffc02015d0:	f822                	sd	s0,48(sp)
ffffffffc02015d2:	84aa                	mv	s1,a0
ffffffffc02015d4:	00010917          	auipc	s2,0x10
ffffffffc02015d8:	f5c90913          	addi	s2,s2,-164 # ffffffffc0211530 <pmm_manager>
    while (1) {
        local_intr_save(intr_flag);
        { page = pmm_manager->alloc_pages(n); }
        local_intr_restore(intr_flag);

        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc02015dc:	4a05                	li	s4,1
ffffffffc02015de:	00010a97          	auipc	s5,0x10
ffffffffc02015e2:	f72a8a93          	addi	s5,s5,-142 # ffffffffc0211550 <swap_init_ok>

        extern struct mm_struct *check_mm_struct;
        // cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
        swap_out(check_mm_struct, n, 0);
ffffffffc02015e6:	0005099b          	sext.w	s3,a0
ffffffffc02015ea:	00010b17          	auipc	s6,0x10
ffffffffc02015ee:	f6eb0b13          	addi	s6,s6,-146 # ffffffffc0211558 <check_mm_struct>
ffffffffc02015f2:	a01d                	j	ffffffffc0201618 <alloc_pages+0x58>
        { page = pmm_manager->alloc_pages(n); }
ffffffffc02015f4:	00093783          	ld	a5,0(s2)
ffffffffc02015f8:	6f9c                	ld	a5,24(a5)
ffffffffc02015fa:	9782                	jalr	a5
ffffffffc02015fc:	842a                	mv	s0,a0
        swap_out(check_mm_struct, n, 0);
ffffffffc02015fe:	4601                	li	a2,0
ffffffffc0201600:	85ce                	mv	a1,s3
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0201602:	ec0d                	bnez	s0,ffffffffc020163c <alloc_pages+0x7c>
ffffffffc0201604:	029a6c63          	bltu	s4,s1,ffffffffc020163c <alloc_pages+0x7c>
ffffffffc0201608:	000aa783          	lw	a5,0(s5)
ffffffffc020160c:	2781                	sext.w	a5,a5
ffffffffc020160e:	c79d                	beqz	a5,ffffffffc020163c <alloc_pages+0x7c>
        swap_out(check_mm_struct, n, 0);
ffffffffc0201610:	000b3503          	ld	a0,0(s6)
ffffffffc0201614:	189010ef          	jal	ra,ffffffffc0202f9c <swap_out>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201618:	100027f3          	csrr	a5,sstatus
ffffffffc020161c:	8b89                	andi	a5,a5,2
        { page = pmm_manager->alloc_pages(n); }
ffffffffc020161e:	8526                	mv	a0,s1
ffffffffc0201620:	dbf1                	beqz	a5,ffffffffc02015f4 <alloc_pages+0x34>
        intr_disable();
ffffffffc0201622:	ecdfe0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc0201626:	00093783          	ld	a5,0(s2)
ffffffffc020162a:	8526                	mv	a0,s1
ffffffffc020162c:	6f9c                	ld	a5,24(a5)
ffffffffc020162e:	9782                	jalr	a5
ffffffffc0201630:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0201632:	eb7fe0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
        swap_out(check_mm_struct, n, 0);
ffffffffc0201636:	4601                	li	a2,0
ffffffffc0201638:	85ce                	mv	a1,s3
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc020163a:	d469                	beqz	s0,ffffffffc0201604 <alloc_pages+0x44>
    }
    // cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
}
ffffffffc020163c:	70e2                	ld	ra,56(sp)
ffffffffc020163e:	8522                	mv	a0,s0
ffffffffc0201640:	7442                	ld	s0,48(sp)
ffffffffc0201642:	74a2                	ld	s1,40(sp)
ffffffffc0201644:	7902                	ld	s2,32(sp)
ffffffffc0201646:	69e2                	ld	s3,24(sp)
ffffffffc0201648:	6a42                	ld	s4,16(sp)
ffffffffc020164a:	6aa2                	ld	s5,8(sp)
ffffffffc020164c:	6b02                	ld	s6,0(sp)
ffffffffc020164e:	6121                	addi	sp,sp,64
ffffffffc0201650:	8082                	ret

ffffffffc0201652 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201652:	100027f3          	csrr	a5,sstatus
ffffffffc0201656:	8b89                	andi	a5,a5,2
ffffffffc0201658:	e799                	bnez	a5,ffffffffc0201666 <free_pages+0x14>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;

    local_intr_save(intr_flag);
    { pmm_manager->free_pages(base, n); }
ffffffffc020165a:	00010797          	auipc	a5,0x10
ffffffffc020165e:	ed67b783          	ld	a5,-298(a5) # ffffffffc0211530 <pmm_manager>
ffffffffc0201662:	739c                	ld	a5,32(a5)
ffffffffc0201664:	8782                	jr	a5
void free_pages(struct Page *base, size_t n) {
ffffffffc0201666:	1101                	addi	sp,sp,-32
ffffffffc0201668:	ec06                	sd	ra,24(sp)
ffffffffc020166a:	e822                	sd	s0,16(sp)
ffffffffc020166c:	e426                	sd	s1,8(sp)
ffffffffc020166e:	842a                	mv	s0,a0
ffffffffc0201670:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0201672:	e7dfe0ef          	jal	ra,ffffffffc02004ee <intr_disable>
    { pmm_manager->free_pages(base, n); }
ffffffffc0201676:	00010797          	auipc	a5,0x10
ffffffffc020167a:	eba7b783          	ld	a5,-326(a5) # ffffffffc0211530 <pmm_manager>
ffffffffc020167e:	739c                	ld	a5,32(a5)
ffffffffc0201680:	85a6                	mv	a1,s1
ffffffffc0201682:	8522                	mv	a0,s0
ffffffffc0201684:	9782                	jalr	a5
    local_intr_restore(intr_flag);
}
ffffffffc0201686:	6442                	ld	s0,16(sp)
ffffffffc0201688:	60e2                	ld	ra,24(sp)
ffffffffc020168a:	64a2                	ld	s1,8(sp)
ffffffffc020168c:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc020168e:	e5bfe06f          	j	ffffffffc02004e8 <intr_enable>

ffffffffc0201692 <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201692:	100027f3          	csrr	a5,sstatus
ffffffffc0201696:	8b89                	andi	a5,a5,2
ffffffffc0201698:	e799                	bnez	a5,ffffffffc02016a6 <nr_free_pages+0x14>
// of current free memory
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc020169a:	00010797          	auipc	a5,0x10
ffffffffc020169e:	e967b783          	ld	a5,-362(a5) # ffffffffc0211530 <pmm_manager>
ffffffffc02016a2:	779c                	ld	a5,40(a5)
ffffffffc02016a4:	8782                	jr	a5
size_t nr_free_pages(void) {
ffffffffc02016a6:	1141                	addi	sp,sp,-16
ffffffffc02016a8:	e406                	sd	ra,8(sp)
ffffffffc02016aa:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc02016ac:	e43fe0ef          	jal	ra,ffffffffc02004ee <intr_disable>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc02016b0:	00010797          	auipc	a5,0x10
ffffffffc02016b4:	e807b783          	ld	a5,-384(a5) # ffffffffc0211530 <pmm_manager>
ffffffffc02016b8:	779c                	ld	a5,40(a5)
ffffffffc02016ba:	9782                	jalr	a5
ffffffffc02016bc:	842a                	mv	s0,a0
        intr_enable();
ffffffffc02016be:	e2bfe0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc02016c2:	60a2                	ld	ra,8(sp)
ffffffffc02016c4:	8522                	mv	a0,s0
ffffffffc02016c6:	6402                	ld	s0,0(sp)
ffffffffc02016c8:	0141                	addi	sp,sp,16
ffffffffc02016ca:	8082                	ret

ffffffffc02016cc <get_pte>:
     *   PTE_W           0x002                   // page table/directory entry
     * flags bit : Writeable
     *   PTE_U           0x004                   // page table/directory entry
     * flags bit : User can access
     */
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc02016cc:	01e5d793          	srli	a5,a1,0x1e
ffffffffc02016d0:	1ff7f793          	andi	a5,a5,511
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc02016d4:	715d                	addi	sp,sp,-80
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc02016d6:	078e                	slli	a5,a5,0x3
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc02016d8:	fc26                	sd	s1,56(sp)
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc02016da:	00f504b3          	add	s1,a0,a5
    if (!(*pdep1 & PTE_V)) {
ffffffffc02016de:	6094                	ld	a3,0(s1)
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc02016e0:	f84a                	sd	s2,48(sp)
ffffffffc02016e2:	f44e                	sd	s3,40(sp)
ffffffffc02016e4:	f052                	sd	s4,32(sp)
ffffffffc02016e6:	e486                	sd	ra,72(sp)
ffffffffc02016e8:	e0a2                	sd	s0,64(sp)
ffffffffc02016ea:	ec56                	sd	s5,24(sp)
ffffffffc02016ec:	e85a                	sd	s6,16(sp)
ffffffffc02016ee:	e45e                	sd	s7,8(sp)
    if (!(*pdep1 & PTE_V)) {
ffffffffc02016f0:	0016f793          	andi	a5,a3,1
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc02016f4:	892e                	mv	s2,a1
ffffffffc02016f6:	8a32                	mv	s4,a2
ffffffffc02016f8:	00010997          	auipc	s3,0x10
ffffffffc02016fc:	e2898993          	addi	s3,s3,-472 # ffffffffc0211520 <npage>
    if (!(*pdep1 & PTE_V)) {
ffffffffc0201700:	efb5                	bnez	a5,ffffffffc020177c <get_pte+0xb0>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc0201702:	14060c63          	beqz	a2,ffffffffc020185a <get_pte+0x18e>
ffffffffc0201706:	4505                	li	a0,1
ffffffffc0201708:	eb9ff0ef          	jal	ra,ffffffffc02015c0 <alloc_pages>
ffffffffc020170c:	842a                	mv	s0,a0
ffffffffc020170e:	14050663          	beqz	a0,ffffffffc020185a <get_pte+0x18e>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201712:	00010b97          	auipc	s7,0x10
ffffffffc0201716:	e16b8b93          	addi	s7,s7,-490 # ffffffffc0211528 <pages>
ffffffffc020171a:	000bb503          	ld	a0,0(s7)
ffffffffc020171e:	00005b17          	auipc	s6,0x5
ffffffffc0201722:	c92b3b03          	ld	s6,-878(s6) # ffffffffc02063b0 <error_string+0x38>
ffffffffc0201726:	00080ab7          	lui	s5,0x80
ffffffffc020172a:	40a40533          	sub	a0,s0,a0
ffffffffc020172e:	850d                	srai	a0,a0,0x3
ffffffffc0201730:	03650533          	mul	a0,a0,s6
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201734:	00010997          	auipc	s3,0x10
ffffffffc0201738:	dec98993          	addi	s3,s3,-532 # ffffffffc0211520 <npage>
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc020173c:	4785                	li	a5,1
ffffffffc020173e:	0009b703          	ld	a4,0(s3)
ffffffffc0201742:	c01c                	sw	a5,0(s0)
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201744:	9556                	add	a0,a0,s5
ffffffffc0201746:	00c51793          	slli	a5,a0,0xc
ffffffffc020174a:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc020174c:	0532                	slli	a0,a0,0xc
ffffffffc020174e:	14e7fd63          	bgeu	a5,a4,ffffffffc02018a8 <get_pte+0x1dc>
ffffffffc0201752:	00010797          	auipc	a5,0x10
ffffffffc0201756:	de67b783          	ld	a5,-538(a5) # ffffffffc0211538 <va_pa_offset>
ffffffffc020175a:	6605                	lui	a2,0x1
ffffffffc020175c:	4581                	li	a1,0
ffffffffc020175e:	953e                	add	a0,a0,a5
ffffffffc0201760:	4dd020ef          	jal	ra,ffffffffc020443c <memset>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201764:	000bb683          	ld	a3,0(s7)
ffffffffc0201768:	40d406b3          	sub	a3,s0,a3
ffffffffc020176c:	868d                	srai	a3,a3,0x3
ffffffffc020176e:	036686b3          	mul	a3,a3,s6
ffffffffc0201772:	96d6                	add	a3,a3,s5

static inline void flush_tlb() { asm volatile("sfence.vma"); }

// construct PTE from a page and permission bits
static inline pte_t pte_create(uintptr_t ppn, int type) {
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0201774:	06aa                	slli	a3,a3,0xa
ffffffffc0201776:	0116e693          	ori	a3,a3,17
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc020177a:	e094                	sd	a3,0(s1)
    }
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc020177c:	77fd                	lui	a5,0xfffff
ffffffffc020177e:	068a                	slli	a3,a3,0x2
ffffffffc0201780:	0009b703          	ld	a4,0(s3)
ffffffffc0201784:	8efd                	and	a3,a3,a5
ffffffffc0201786:	00c6d793          	srli	a5,a3,0xc
ffffffffc020178a:	0ce7fa63          	bgeu	a5,a4,ffffffffc020185e <get_pte+0x192>
ffffffffc020178e:	00010a97          	auipc	s5,0x10
ffffffffc0201792:	daaa8a93          	addi	s5,s5,-598 # ffffffffc0211538 <va_pa_offset>
ffffffffc0201796:	000ab403          	ld	s0,0(s5)
ffffffffc020179a:	01595793          	srli	a5,s2,0x15
ffffffffc020179e:	1ff7f793          	andi	a5,a5,511
ffffffffc02017a2:	96a2                	add	a3,a3,s0
ffffffffc02017a4:	00379413          	slli	s0,a5,0x3
ffffffffc02017a8:	9436                	add	s0,s0,a3
//    pde_t *pdep0 = &((pde_t *)(PDE_ADDR(*pdep1)))[PDX0(la)];
    if (!(*pdep0 & PTE_V)) {
ffffffffc02017aa:	6014                	ld	a3,0(s0)
ffffffffc02017ac:	0016f793          	andi	a5,a3,1
ffffffffc02017b0:	ebad                	bnez	a5,ffffffffc0201822 <get_pte+0x156>
    	struct Page *page;
    	if (!create || (page = alloc_page()) == NULL) {
ffffffffc02017b2:	0a0a0463          	beqz	s4,ffffffffc020185a <get_pte+0x18e>
ffffffffc02017b6:	4505                	li	a0,1
ffffffffc02017b8:	e09ff0ef          	jal	ra,ffffffffc02015c0 <alloc_pages>
ffffffffc02017bc:	84aa                	mv	s1,a0
ffffffffc02017be:	cd51                	beqz	a0,ffffffffc020185a <get_pte+0x18e>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02017c0:	00010b97          	auipc	s7,0x10
ffffffffc02017c4:	d68b8b93          	addi	s7,s7,-664 # ffffffffc0211528 <pages>
ffffffffc02017c8:	000bb503          	ld	a0,0(s7)
ffffffffc02017cc:	00005b17          	auipc	s6,0x5
ffffffffc02017d0:	be4b3b03          	ld	s6,-1052(s6) # ffffffffc02063b0 <error_string+0x38>
ffffffffc02017d4:	00080a37          	lui	s4,0x80
ffffffffc02017d8:	40a48533          	sub	a0,s1,a0
ffffffffc02017dc:	850d                	srai	a0,a0,0x3
ffffffffc02017de:	03650533          	mul	a0,a0,s6
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc02017e2:	4785                	li	a5,1
    		return NULL;
    	}
    	set_page_ref(page, 1);
    	uintptr_t pa = page2pa(page);
    	memset(KADDR(pa), 0, PGSIZE);
ffffffffc02017e4:	0009b703          	ld	a4,0(s3)
ffffffffc02017e8:	c09c                	sw	a5,0(s1)
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02017ea:	9552                	add	a0,a0,s4
ffffffffc02017ec:	00c51793          	slli	a5,a0,0xc
ffffffffc02017f0:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc02017f2:	0532                	slli	a0,a0,0xc
ffffffffc02017f4:	08e7fd63          	bgeu	a5,a4,ffffffffc020188e <get_pte+0x1c2>
ffffffffc02017f8:	000ab783          	ld	a5,0(s5)
ffffffffc02017fc:	6605                	lui	a2,0x1
ffffffffc02017fe:	4581                	li	a1,0
ffffffffc0201800:	953e                	add	a0,a0,a5
ffffffffc0201802:	43b020ef          	jal	ra,ffffffffc020443c <memset>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201806:	000bb683          	ld	a3,0(s7)
ffffffffc020180a:	40d486b3          	sub	a3,s1,a3
ffffffffc020180e:	868d                	srai	a3,a3,0x3
ffffffffc0201810:	036686b3          	mul	a3,a3,s6
ffffffffc0201814:	96d2                	add	a3,a3,s4
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0201816:	06aa                	slli	a3,a3,0xa
ffffffffc0201818:	0116e693          	ori	a3,a3,17
 //   	memset(pa, 0, PGSIZE);
    	*pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc020181c:	e014                	sd	a3,0(s0)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc020181e:	0009b703          	ld	a4,0(s3)
ffffffffc0201822:	068a                	slli	a3,a3,0x2
ffffffffc0201824:	757d                	lui	a0,0xfffff
ffffffffc0201826:	8ee9                	and	a3,a3,a0
ffffffffc0201828:	00c6d793          	srli	a5,a3,0xc
ffffffffc020182c:	04e7f563          	bgeu	a5,a4,ffffffffc0201876 <get_pte+0x1aa>
ffffffffc0201830:	000ab503          	ld	a0,0(s5)
ffffffffc0201834:	00c95913          	srli	s2,s2,0xc
ffffffffc0201838:	1ff97913          	andi	s2,s2,511
ffffffffc020183c:	96aa                	add	a3,a3,a0
ffffffffc020183e:	00391513          	slli	a0,s2,0x3
ffffffffc0201842:	9536                	add	a0,a0,a3
}
ffffffffc0201844:	60a6                	ld	ra,72(sp)
ffffffffc0201846:	6406                	ld	s0,64(sp)
ffffffffc0201848:	74e2                	ld	s1,56(sp)
ffffffffc020184a:	7942                	ld	s2,48(sp)
ffffffffc020184c:	79a2                	ld	s3,40(sp)
ffffffffc020184e:	7a02                	ld	s4,32(sp)
ffffffffc0201850:	6ae2                	ld	s5,24(sp)
ffffffffc0201852:	6b42                	ld	s6,16(sp)
ffffffffc0201854:	6ba2                	ld	s7,8(sp)
ffffffffc0201856:	6161                	addi	sp,sp,80
ffffffffc0201858:	8082                	ret
            return NULL;
ffffffffc020185a:	4501                	li	a0,0
ffffffffc020185c:	b7e5                	j	ffffffffc0201844 <get_pte+0x178>
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc020185e:	00004617          	auipc	a2,0x4
ffffffffc0201862:	9da60613          	addi	a2,a2,-1574 # ffffffffc0205238 <default_pmm_manager+0x90>
ffffffffc0201866:	10200593          	li	a1,258
ffffffffc020186a:	00004517          	auipc	a0,0x4
ffffffffc020186e:	9f650513          	addi	a0,a0,-1546 # ffffffffc0205260 <default_pmm_manager+0xb8>
ffffffffc0201872:	b03fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0201876:	00004617          	auipc	a2,0x4
ffffffffc020187a:	9c260613          	addi	a2,a2,-1598 # ffffffffc0205238 <default_pmm_manager+0x90>
ffffffffc020187e:	10f00593          	li	a1,271
ffffffffc0201882:	00004517          	auipc	a0,0x4
ffffffffc0201886:	9de50513          	addi	a0,a0,-1570 # ffffffffc0205260 <default_pmm_manager+0xb8>
ffffffffc020188a:	aebfe0ef          	jal	ra,ffffffffc0200374 <__panic>
    	memset(KADDR(pa), 0, PGSIZE);
ffffffffc020188e:	86aa                	mv	a3,a0
ffffffffc0201890:	00004617          	auipc	a2,0x4
ffffffffc0201894:	9a860613          	addi	a2,a2,-1624 # ffffffffc0205238 <default_pmm_manager+0x90>
ffffffffc0201898:	10b00593          	li	a1,267
ffffffffc020189c:	00004517          	auipc	a0,0x4
ffffffffc02018a0:	9c450513          	addi	a0,a0,-1596 # ffffffffc0205260 <default_pmm_manager+0xb8>
ffffffffc02018a4:	ad1fe0ef          	jal	ra,ffffffffc0200374 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc02018a8:	86aa                	mv	a3,a0
ffffffffc02018aa:	00004617          	auipc	a2,0x4
ffffffffc02018ae:	98e60613          	addi	a2,a2,-1650 # ffffffffc0205238 <default_pmm_manager+0x90>
ffffffffc02018b2:	0ff00593          	li	a1,255
ffffffffc02018b6:	00004517          	auipc	a0,0x4
ffffffffc02018ba:	9aa50513          	addi	a0,a0,-1622 # ffffffffc0205260 <default_pmm_manager+0xb8>
ffffffffc02018be:	ab7fe0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc02018c2 <get_page>:

// get_page - get related Page struct for linear address la using PDT pgdir
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc02018c2:	1141                	addi	sp,sp,-16
ffffffffc02018c4:	e022                	sd	s0,0(sp)
ffffffffc02018c6:	8432                	mv	s0,a2
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc02018c8:	4601                	li	a2,0
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc02018ca:	e406                	sd	ra,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc02018cc:	e01ff0ef          	jal	ra,ffffffffc02016cc <get_pte>
    if (ptep_store != NULL) {
ffffffffc02018d0:	c011                	beqz	s0,ffffffffc02018d4 <get_page+0x12>
        *ptep_store = ptep;
ffffffffc02018d2:	e008                	sd	a0,0(s0)
    }
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc02018d4:	c511                	beqz	a0,ffffffffc02018e0 <get_page+0x1e>
ffffffffc02018d6:	611c                	ld	a5,0(a0)
        return pte2page(*ptep);
    }
    return NULL;
ffffffffc02018d8:	4501                	li	a0,0
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc02018da:	0017f713          	andi	a4,a5,1
ffffffffc02018de:	e709                	bnez	a4,ffffffffc02018e8 <get_page+0x26>
}
ffffffffc02018e0:	60a2                	ld	ra,8(sp)
ffffffffc02018e2:	6402                	ld	s0,0(sp)
ffffffffc02018e4:	0141                	addi	sp,sp,16
ffffffffc02018e6:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc02018e8:	078a                	slli	a5,a5,0x2
ffffffffc02018ea:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02018ec:	00010717          	auipc	a4,0x10
ffffffffc02018f0:	c3473703          	ld	a4,-972(a4) # ffffffffc0211520 <npage>
ffffffffc02018f4:	02e7f263          	bgeu	a5,a4,ffffffffc0201918 <get_page+0x56>
    return &pages[PPN(pa) - nbase];
ffffffffc02018f8:	fff80537          	lui	a0,0xfff80
ffffffffc02018fc:	97aa                	add	a5,a5,a0
ffffffffc02018fe:	60a2                	ld	ra,8(sp)
ffffffffc0201900:	6402                	ld	s0,0(sp)
ffffffffc0201902:	00379513          	slli	a0,a5,0x3
ffffffffc0201906:	97aa                	add	a5,a5,a0
ffffffffc0201908:	078e                	slli	a5,a5,0x3
ffffffffc020190a:	00010517          	auipc	a0,0x10
ffffffffc020190e:	c1e53503          	ld	a0,-994(a0) # ffffffffc0211528 <pages>
ffffffffc0201912:	953e                	add	a0,a0,a5
ffffffffc0201914:	0141                	addi	sp,sp,16
ffffffffc0201916:	8082                	ret
ffffffffc0201918:	c71ff0ef          	jal	ra,ffffffffc0201588 <pa2page.part.0>

ffffffffc020191c <page_remove>:
    }
}

// page_remove - free an Page which is related linear address la and has an
// validated pte
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc020191c:	1101                	addi	sp,sp,-32
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc020191e:	4601                	li	a2,0
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0201920:	ec06                	sd	ra,24(sp)
ffffffffc0201922:	e822                	sd	s0,16(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201924:	da9ff0ef          	jal	ra,ffffffffc02016cc <get_pte>
    if (ptep != NULL) {
ffffffffc0201928:	c511                	beqz	a0,ffffffffc0201934 <page_remove+0x18>
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc020192a:	611c                	ld	a5,0(a0)
ffffffffc020192c:	842a                	mv	s0,a0
ffffffffc020192e:	0017f713          	andi	a4,a5,1
ffffffffc0201932:	e709                	bnez	a4,ffffffffc020193c <page_remove+0x20>
        page_remove_pte(pgdir, la, ptep);
    }
}
ffffffffc0201934:	60e2                	ld	ra,24(sp)
ffffffffc0201936:	6442                	ld	s0,16(sp)
ffffffffc0201938:	6105                	addi	sp,sp,32
ffffffffc020193a:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc020193c:	078a                	slli	a5,a5,0x2
ffffffffc020193e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201940:	00010717          	auipc	a4,0x10
ffffffffc0201944:	be073703          	ld	a4,-1056(a4) # ffffffffc0211520 <npage>
ffffffffc0201948:	06e7f563          	bgeu	a5,a4,ffffffffc02019b2 <page_remove+0x96>
    return &pages[PPN(pa) - nbase];
ffffffffc020194c:	fff80737          	lui	a4,0xfff80
ffffffffc0201950:	97ba                	add	a5,a5,a4
ffffffffc0201952:	00379513          	slli	a0,a5,0x3
ffffffffc0201956:	97aa                	add	a5,a5,a0
ffffffffc0201958:	078e                	slli	a5,a5,0x3
ffffffffc020195a:	00010517          	auipc	a0,0x10
ffffffffc020195e:	bce53503          	ld	a0,-1074(a0) # ffffffffc0211528 <pages>
ffffffffc0201962:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc0201964:	411c                	lw	a5,0(a0)
ffffffffc0201966:	fff7871b          	addiw	a4,a5,-1
ffffffffc020196a:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc020196c:	cb09                	beqz	a4,ffffffffc020197e <page_remove+0x62>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc020196e:	00043023          	sd	zero,0(s0)
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0201972:	12000073          	sfence.vma
}
ffffffffc0201976:	60e2                	ld	ra,24(sp)
ffffffffc0201978:	6442                	ld	s0,16(sp)
ffffffffc020197a:	6105                	addi	sp,sp,32
ffffffffc020197c:	8082                	ret
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020197e:	100027f3          	csrr	a5,sstatus
ffffffffc0201982:	8b89                	andi	a5,a5,2
ffffffffc0201984:	eb89                	bnez	a5,ffffffffc0201996 <page_remove+0x7a>
    { pmm_manager->free_pages(base, n); }
ffffffffc0201986:	00010797          	auipc	a5,0x10
ffffffffc020198a:	baa7b783          	ld	a5,-1110(a5) # ffffffffc0211530 <pmm_manager>
ffffffffc020198e:	739c                	ld	a5,32(a5)
ffffffffc0201990:	4585                	li	a1,1
ffffffffc0201992:	9782                	jalr	a5
    if (flag) {
ffffffffc0201994:	bfe9                	j	ffffffffc020196e <page_remove+0x52>
        intr_disable();
ffffffffc0201996:	e42a                	sd	a0,8(sp)
ffffffffc0201998:	b57fe0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc020199c:	00010797          	auipc	a5,0x10
ffffffffc02019a0:	b947b783          	ld	a5,-1132(a5) # ffffffffc0211530 <pmm_manager>
ffffffffc02019a4:	739c                	ld	a5,32(a5)
ffffffffc02019a6:	6522                	ld	a0,8(sp)
ffffffffc02019a8:	4585                	li	a1,1
ffffffffc02019aa:	9782                	jalr	a5
        intr_enable();
ffffffffc02019ac:	b3dfe0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc02019b0:	bf7d                	j	ffffffffc020196e <page_remove+0x52>
ffffffffc02019b2:	bd7ff0ef          	jal	ra,ffffffffc0201588 <pa2page.part.0>

ffffffffc02019b6 <page_insert>:
//  page:  the Page which need to map
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
// note: PT is changed, so the TLB need to be invalidate
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc02019b6:	7179                	addi	sp,sp,-48
ffffffffc02019b8:	87b2                	mv	a5,a2
ffffffffc02019ba:	f022                	sd	s0,32(sp)
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc02019bc:	4605                	li	a2,1
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc02019be:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc02019c0:	85be                	mv	a1,a5
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc02019c2:	ec26                	sd	s1,24(sp)
ffffffffc02019c4:	f406                	sd	ra,40(sp)
ffffffffc02019c6:	e84a                	sd	s2,16(sp)
ffffffffc02019c8:	e44e                	sd	s3,8(sp)
ffffffffc02019ca:	e052                	sd	s4,0(sp)
ffffffffc02019cc:	84b6                	mv	s1,a3
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc02019ce:	cffff0ef          	jal	ra,ffffffffc02016cc <get_pte>
    if (ptep == NULL) {
ffffffffc02019d2:	cd71                	beqz	a0,ffffffffc0201aae <page_insert+0xf8>
    page->ref += 1;
ffffffffc02019d4:	4014                	lw	a3,0(s0)
        return -E_NO_MEM;
    }
    page_ref_inc(page);
    if (*ptep & PTE_V) {
ffffffffc02019d6:	611c                	ld	a5,0(a0)
ffffffffc02019d8:	89aa                	mv	s3,a0
ffffffffc02019da:	0016871b          	addiw	a4,a3,1
ffffffffc02019de:	c018                	sw	a4,0(s0)
ffffffffc02019e0:	0017f713          	andi	a4,a5,1
ffffffffc02019e4:	e331                	bnez	a4,ffffffffc0201a28 <page_insert+0x72>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02019e6:	00010797          	auipc	a5,0x10
ffffffffc02019ea:	b427b783          	ld	a5,-1214(a5) # ffffffffc0211528 <pages>
ffffffffc02019ee:	40f407b3          	sub	a5,s0,a5
ffffffffc02019f2:	878d                	srai	a5,a5,0x3
ffffffffc02019f4:	00005417          	auipc	s0,0x5
ffffffffc02019f8:	9bc43403          	ld	s0,-1604(s0) # ffffffffc02063b0 <error_string+0x38>
ffffffffc02019fc:	028787b3          	mul	a5,a5,s0
ffffffffc0201a00:	00080437          	lui	s0,0x80
ffffffffc0201a04:	97a2                	add	a5,a5,s0
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0201a06:	07aa                	slli	a5,a5,0xa
ffffffffc0201a08:	8cdd                	or	s1,s1,a5
ffffffffc0201a0a:	0014e493          	ori	s1,s1,1
            page_ref_dec(page);
        } else {
            page_remove_pte(pgdir, la, ptep);
        }
    }
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
ffffffffc0201a0e:	0099b023          	sd	s1,0(s3)
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0201a12:	12000073          	sfence.vma
    tlb_invalidate(pgdir, la);
    return 0;
ffffffffc0201a16:	4501                	li	a0,0
}
ffffffffc0201a18:	70a2                	ld	ra,40(sp)
ffffffffc0201a1a:	7402                	ld	s0,32(sp)
ffffffffc0201a1c:	64e2                	ld	s1,24(sp)
ffffffffc0201a1e:	6942                	ld	s2,16(sp)
ffffffffc0201a20:	69a2                	ld	s3,8(sp)
ffffffffc0201a22:	6a02                	ld	s4,0(sp)
ffffffffc0201a24:	6145                	addi	sp,sp,48
ffffffffc0201a26:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0201a28:	00279713          	slli	a4,a5,0x2
ffffffffc0201a2c:	8331                	srli	a4,a4,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201a2e:	00010797          	auipc	a5,0x10
ffffffffc0201a32:	af27b783          	ld	a5,-1294(a5) # ffffffffc0211520 <npage>
ffffffffc0201a36:	06f77e63          	bgeu	a4,a5,ffffffffc0201ab2 <page_insert+0xfc>
    return &pages[PPN(pa) - nbase];
ffffffffc0201a3a:	fff807b7          	lui	a5,0xfff80
ffffffffc0201a3e:	973e                	add	a4,a4,a5
ffffffffc0201a40:	00010a17          	auipc	s4,0x10
ffffffffc0201a44:	ae8a0a13          	addi	s4,s4,-1304 # ffffffffc0211528 <pages>
ffffffffc0201a48:	000a3783          	ld	a5,0(s4)
ffffffffc0201a4c:	00371913          	slli	s2,a4,0x3
ffffffffc0201a50:	993a                	add	s2,s2,a4
ffffffffc0201a52:	090e                	slli	s2,s2,0x3
ffffffffc0201a54:	993e                	add	s2,s2,a5
        if (p == page) {
ffffffffc0201a56:	03240063          	beq	s0,s2,ffffffffc0201a76 <page_insert+0xc0>
    page->ref -= 1;
ffffffffc0201a5a:	00092783          	lw	a5,0(s2)
ffffffffc0201a5e:	fff7871b          	addiw	a4,a5,-1
ffffffffc0201a62:	00e92023          	sw	a4,0(s2)
        if (page_ref(page) ==
ffffffffc0201a66:	cb11                	beqz	a4,ffffffffc0201a7a <page_insert+0xc4>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc0201a68:	0009b023          	sd	zero,0(s3)
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0201a6c:	12000073          	sfence.vma
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201a70:	000a3783          	ld	a5,0(s4)
}
ffffffffc0201a74:	bfad                	j	ffffffffc02019ee <page_insert+0x38>
    page->ref -= 1;
ffffffffc0201a76:	c014                	sw	a3,0(s0)
    return page->ref;
ffffffffc0201a78:	bf9d                	j	ffffffffc02019ee <page_insert+0x38>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201a7a:	100027f3          	csrr	a5,sstatus
ffffffffc0201a7e:	8b89                	andi	a5,a5,2
ffffffffc0201a80:	eb91                	bnez	a5,ffffffffc0201a94 <page_insert+0xde>
    { pmm_manager->free_pages(base, n); }
ffffffffc0201a82:	00010797          	auipc	a5,0x10
ffffffffc0201a86:	aae7b783          	ld	a5,-1362(a5) # ffffffffc0211530 <pmm_manager>
ffffffffc0201a8a:	739c                	ld	a5,32(a5)
ffffffffc0201a8c:	4585                	li	a1,1
ffffffffc0201a8e:	854a                	mv	a0,s2
ffffffffc0201a90:	9782                	jalr	a5
    if (flag) {
ffffffffc0201a92:	bfd9                	j	ffffffffc0201a68 <page_insert+0xb2>
        intr_disable();
ffffffffc0201a94:	a5bfe0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc0201a98:	00010797          	auipc	a5,0x10
ffffffffc0201a9c:	a987b783          	ld	a5,-1384(a5) # ffffffffc0211530 <pmm_manager>
ffffffffc0201aa0:	739c                	ld	a5,32(a5)
ffffffffc0201aa2:	4585                	li	a1,1
ffffffffc0201aa4:	854a                	mv	a0,s2
ffffffffc0201aa6:	9782                	jalr	a5
        intr_enable();
ffffffffc0201aa8:	a41fe0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc0201aac:	bf75                	j	ffffffffc0201a68 <page_insert+0xb2>
        return -E_NO_MEM;
ffffffffc0201aae:	5571                	li	a0,-4
ffffffffc0201ab0:	b7a5                	j	ffffffffc0201a18 <page_insert+0x62>
ffffffffc0201ab2:	ad7ff0ef          	jal	ra,ffffffffc0201588 <pa2page.part.0>

ffffffffc0201ab6 <pmm_init>:
    pmm_manager = &default_pmm_manager;
ffffffffc0201ab6:	00003797          	auipc	a5,0x3
ffffffffc0201aba:	6f278793          	addi	a5,a5,1778 # ffffffffc02051a8 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201abe:	638c                	ld	a1,0(a5)
void pmm_init(void) {
ffffffffc0201ac0:	7159                	addi	sp,sp,-112
ffffffffc0201ac2:	f45e                	sd	s7,40(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201ac4:	00003517          	auipc	a0,0x3
ffffffffc0201ac8:	7ac50513          	addi	a0,a0,1964 # ffffffffc0205270 <default_pmm_manager+0xc8>
    pmm_manager = &default_pmm_manager;
ffffffffc0201acc:	00010b97          	auipc	s7,0x10
ffffffffc0201ad0:	a64b8b93          	addi	s7,s7,-1436 # ffffffffc0211530 <pmm_manager>
void pmm_init(void) {
ffffffffc0201ad4:	f486                	sd	ra,104(sp)
ffffffffc0201ad6:	f0a2                	sd	s0,96(sp)
ffffffffc0201ad8:	eca6                	sd	s1,88(sp)
ffffffffc0201ada:	e8ca                	sd	s2,80(sp)
ffffffffc0201adc:	e4ce                	sd	s3,72(sp)
ffffffffc0201ade:	f85a                	sd	s6,48(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc0201ae0:	00fbb023          	sd	a5,0(s7)
void pmm_init(void) {
ffffffffc0201ae4:	e0d2                	sd	s4,64(sp)
ffffffffc0201ae6:	fc56                	sd	s5,56(sp)
ffffffffc0201ae8:	f062                	sd	s8,32(sp)
ffffffffc0201aea:	ec66                	sd	s9,24(sp)
ffffffffc0201aec:	e86a                	sd	s10,16(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201aee:	dccfe0ef          	jal	ra,ffffffffc02000ba <cprintf>
    pmm_manager->init();
ffffffffc0201af2:	000bb783          	ld	a5,0(s7)
    cprintf("membegin %llx memend %llx mem_size %llx\n",mem_begin, mem_end, mem_size);
ffffffffc0201af6:	4445                	li	s0,17
ffffffffc0201af8:	40100913          	li	s2,1025
    pmm_manager->init();
ffffffffc0201afc:	679c                	ld	a5,8(a5)
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0201afe:	00010997          	auipc	s3,0x10
ffffffffc0201b02:	a3a98993          	addi	s3,s3,-1478 # ffffffffc0211538 <va_pa_offset>
    npage = maxpa / PGSIZE;
ffffffffc0201b06:	00010497          	auipc	s1,0x10
ffffffffc0201b0a:	a1a48493          	addi	s1,s1,-1510 # ffffffffc0211520 <npage>
    pmm_manager->init();
ffffffffc0201b0e:	9782                	jalr	a5
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0201b10:	57f5                	li	a5,-3
ffffffffc0201b12:	07fa                	slli	a5,a5,0x1e
    cprintf("membegin %llx memend %llx mem_size %llx\n",mem_begin, mem_end, mem_size);
ffffffffc0201b14:	07e006b7          	lui	a3,0x7e00
ffffffffc0201b18:	01b41613          	slli	a2,s0,0x1b
ffffffffc0201b1c:	01591593          	slli	a1,s2,0x15
ffffffffc0201b20:	00003517          	auipc	a0,0x3
ffffffffc0201b24:	76850513          	addi	a0,a0,1896 # ffffffffc0205288 <default_pmm_manager+0xe0>
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0201b28:	00f9b023          	sd	a5,0(s3)
    cprintf("membegin %llx memend %llx mem_size %llx\n",mem_begin, mem_end, mem_size);
ffffffffc0201b2c:	d8efe0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("physcial memory map:\n");
ffffffffc0201b30:	00003517          	auipc	a0,0x3
ffffffffc0201b34:	78850513          	addi	a0,a0,1928 # ffffffffc02052b8 <default_pmm_manager+0x110>
ffffffffc0201b38:	d82fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
ffffffffc0201b3c:	01b41693          	slli	a3,s0,0x1b
ffffffffc0201b40:	16fd                	addi	a3,a3,-1
ffffffffc0201b42:	07e005b7          	lui	a1,0x7e00
ffffffffc0201b46:	01591613          	slli	a2,s2,0x15
ffffffffc0201b4a:	00003517          	auipc	a0,0x3
ffffffffc0201b4e:	78650513          	addi	a0,a0,1926 # ffffffffc02052d0 <default_pmm_manager+0x128>
ffffffffc0201b52:	d68fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201b56:	777d                	lui	a4,0xfffff
ffffffffc0201b58:	00011797          	auipc	a5,0x11
ffffffffc0201b5c:	a0b78793          	addi	a5,a5,-1525 # ffffffffc0212563 <end+0xfff>
ffffffffc0201b60:	8ff9                	and	a5,a5,a4
ffffffffc0201b62:	00010b17          	auipc	s6,0x10
ffffffffc0201b66:	9c6b0b13          	addi	s6,s6,-1594 # ffffffffc0211528 <pages>
    npage = maxpa / PGSIZE;
ffffffffc0201b6a:	00088737          	lui	a4,0x88
ffffffffc0201b6e:	e098                	sd	a4,0(s1)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201b70:	00fb3023          	sd	a5,0(s6)
ffffffffc0201b74:	4681                	li	a3,0
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201b76:	4701                	li	a4,0
ffffffffc0201b78:	4505                	li	a0,1
ffffffffc0201b7a:	fff805b7          	lui	a1,0xfff80
ffffffffc0201b7e:	a019                	j	ffffffffc0201b84 <pmm_init+0xce>
        SetPageReserved(pages + i);
ffffffffc0201b80:	000b3783          	ld	a5,0(s6)
ffffffffc0201b84:	97b6                	add	a5,a5,a3
ffffffffc0201b86:	07a1                	addi	a5,a5,8
ffffffffc0201b88:	40a7b02f          	amoor.d	zero,a0,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201b8c:	609c                	ld	a5,0(s1)
ffffffffc0201b8e:	0705                	addi	a4,a4,1
ffffffffc0201b90:	04868693          	addi	a3,a3,72 # 7e00048 <kern_entry-0xffffffffb83fffb8>
ffffffffc0201b94:	00b78633          	add	a2,a5,a1
ffffffffc0201b98:	fec764e3          	bltu	a4,a2,ffffffffc0201b80 <pmm_init+0xca>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201b9c:	000b3503          	ld	a0,0(s6)
ffffffffc0201ba0:	00379693          	slli	a3,a5,0x3
ffffffffc0201ba4:	96be                	add	a3,a3,a5
ffffffffc0201ba6:	fdc00737          	lui	a4,0xfdc00
ffffffffc0201baa:	972a                	add	a4,a4,a0
ffffffffc0201bac:	068e                	slli	a3,a3,0x3
ffffffffc0201bae:	96ba                	add	a3,a3,a4
ffffffffc0201bb0:	c0200737          	lui	a4,0xc0200
ffffffffc0201bb4:	64e6e463          	bltu	a3,a4,ffffffffc02021fc <pmm_init+0x746>
ffffffffc0201bb8:	0009b703          	ld	a4,0(s3)
    if (freemem < mem_end) {
ffffffffc0201bbc:	4645                	li	a2,17
ffffffffc0201bbe:	066e                	slli	a2,a2,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201bc0:	8e99                	sub	a3,a3,a4
    if (freemem < mem_end) {
ffffffffc0201bc2:	4ec6e263          	bltu	a3,a2,ffffffffc02020a6 <pmm_init+0x5f0>

    return page;
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc0201bc6:	000bb783          	ld	a5,0(s7)
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0201bca:	00010917          	auipc	s2,0x10
ffffffffc0201bce:	94e90913          	addi	s2,s2,-1714 # ffffffffc0211518 <boot_pgdir>
    pmm_manager->check();
ffffffffc0201bd2:	7b9c                	ld	a5,48(a5)
ffffffffc0201bd4:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0201bd6:	00003517          	auipc	a0,0x3
ffffffffc0201bda:	74a50513          	addi	a0,a0,1866 # ffffffffc0205320 <default_pmm_manager+0x178>
ffffffffc0201bde:	cdcfe0ef          	jal	ra,ffffffffc02000ba <cprintf>
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0201be2:	00007697          	auipc	a3,0x7
ffffffffc0201be6:	41e68693          	addi	a3,a3,1054 # ffffffffc0209000 <boot_page_table_sv39>
ffffffffc0201bea:	00d93023          	sd	a3,0(s2)
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc0201bee:	c02007b7          	lui	a5,0xc0200
ffffffffc0201bf2:	62f6e163          	bltu	a3,a5,ffffffffc0202214 <pmm_init+0x75e>
ffffffffc0201bf6:	0009b783          	ld	a5,0(s3)
ffffffffc0201bfa:	8e9d                	sub	a3,a3,a5
ffffffffc0201bfc:	00010797          	auipc	a5,0x10
ffffffffc0201c00:	90d7ba23          	sd	a3,-1772(a5) # ffffffffc0211510 <boot_cr3>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201c04:	100027f3          	csrr	a5,sstatus
ffffffffc0201c08:	8b89                	andi	a5,a5,2
ffffffffc0201c0a:	4c079763          	bnez	a5,ffffffffc02020d8 <pmm_init+0x622>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc0201c0e:	000bb783          	ld	a5,0(s7)
ffffffffc0201c12:	779c                	ld	a5,40(a5)
ffffffffc0201c14:	9782                	jalr	a5
ffffffffc0201c16:	842a                	mv	s0,a0
    size_t nr_free_store;

    nr_free_store=nr_free_pages();

    // 断言：物理内存页面数量不超过内核顶部地址除以页面大小
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0201c18:	6098                	ld	a4,0(s1)
ffffffffc0201c1a:	c80007b7          	lui	a5,0xc8000
ffffffffc0201c1e:	83b1                	srli	a5,a5,0xc
ffffffffc0201c20:	62e7e663          	bltu	a5,a4,ffffffffc020224c <pmm_init+0x796>
    // 断言：页目录指针不为空，且页目录的偏移量为 0
    assert(boot_pgdir!= NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc0201c24:	00093503          	ld	a0,0(s2)
ffffffffc0201c28:	60050263          	beqz	a0,ffffffffc020222c <pmm_init+0x776>
ffffffffc0201c2c:	03451793          	slli	a5,a0,0x34
ffffffffc0201c30:	5e079e63          	bnez	a5,ffffffffc020222c <pmm_init+0x776>
    // 断言：获取页目录中地址为 0 的页失败（应该为空）
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc0201c34:	4601                	li	a2,0
ffffffffc0201c36:	4581                	li	a1,0
ffffffffc0201c38:	c8bff0ef          	jal	ra,ffffffffc02018c2 <get_page>
ffffffffc0201c3c:	66051a63          	bnez	a0,ffffffffc02022b0 <pmm_init+0x7fa>

    struct Page *p1, *p2;
    // 分配一个页
    p1 = alloc_page();
ffffffffc0201c40:	4505                	li	a0,1
ffffffffc0201c42:	97fff0ef          	jal	ra,ffffffffc02015c0 <alloc_pages>
ffffffffc0201c46:	8a2a                	mv	s4,a0
    // 将页 p1 插入到页目录 boot_pgdir 中，地址为 0x0，权限为 0
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc0201c48:	00093503          	ld	a0,0(s2)
ffffffffc0201c4c:	4681                	li	a3,0
ffffffffc0201c4e:	4601                	li	a2,0
ffffffffc0201c50:	85d2                	mv	a1,s4
ffffffffc0201c52:	d65ff0ef          	jal	ra,ffffffffc02019b6 <page_insert>
ffffffffc0201c56:	62051d63          	bnez	a0,ffffffffc0202290 <pmm_init+0x7da>
    pte_t *ptep;
    // 获取页目录 boot_pgdir 中地址为 0x0 的页表项
    assert((ptep = get_pte(boot_pgdir, 0x0, 0))!= NULL);
ffffffffc0201c5a:	00093503          	ld	a0,0(s2)
ffffffffc0201c5e:	4601                	li	a2,0
ffffffffc0201c60:	4581                	li	a1,0
ffffffffc0201c62:	a6bff0ef          	jal	ra,ffffffffc02016cc <get_pte>
ffffffffc0201c66:	60050563          	beqz	a0,ffffffffc0202270 <pmm_init+0x7ba>
    // 断言：页表项指向的页是 p1
    assert(pte2page(*ptep) == p1);
ffffffffc0201c6a:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0201c6c:	0017f713          	andi	a4,a5,1
ffffffffc0201c70:	5e070e63          	beqz	a4,ffffffffc020226c <pmm_init+0x7b6>
    if (PPN(pa) >= npage) {
ffffffffc0201c74:	6090                	ld	a2,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201c76:	078a                	slli	a5,a5,0x2
ffffffffc0201c78:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201c7a:	56c7ff63          	bgeu	a5,a2,ffffffffc02021f8 <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc0201c7e:	fff80737          	lui	a4,0xfff80
ffffffffc0201c82:	97ba                	add	a5,a5,a4
ffffffffc0201c84:	000b3683          	ld	a3,0(s6)
ffffffffc0201c88:	00379713          	slli	a4,a5,0x3
ffffffffc0201c8c:	97ba                	add	a5,a5,a4
ffffffffc0201c8e:	078e                	slli	a5,a5,0x3
ffffffffc0201c90:	97b6                	add	a5,a5,a3
ffffffffc0201c92:	14fa18e3          	bne	s4,a5,ffffffffc02025e2 <pmm_init+0xb2c>
    // 断言：页 p1 的引用计数为 1
    assert(page_ref(p1) == 1);
ffffffffc0201c96:	000a2703          	lw	a4,0(s4)
ffffffffc0201c9a:	4785                	li	a5,1
ffffffffc0201c9c:	16f71fe3          	bne	a4,a5,ffffffffc020261a <pmm_init+0xb64>

    // 获取页目录 boot_pgdir 的第一个页表的物理地址
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc0201ca0:	00093503          	ld	a0,0(s2)
ffffffffc0201ca4:	77fd                	lui	a5,0xfffff
ffffffffc0201ca6:	6114                	ld	a3,0(a0)
ffffffffc0201ca8:	068a                	slli	a3,a3,0x2
ffffffffc0201caa:	8efd                	and	a3,a3,a5
ffffffffc0201cac:	00c6d713          	srli	a4,a3,0xc
ffffffffc0201cb0:	14c779e3          	bgeu	a4,a2,ffffffffc0202602 <pmm_init+0xb4c>
ffffffffc0201cb4:	0009bc03          	ld	s8,0(s3)
    // 获取页目录 boot_pgdir 的第一个页表的第二项的物理地址
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0201cb8:	96e2                	add	a3,a3,s8
ffffffffc0201cba:	0006ba83          	ld	s5,0(a3)
ffffffffc0201cbe:	0a8a                	slli	s5,s5,0x2
ffffffffc0201cc0:	00fafab3          	and	s5,s5,a5
ffffffffc0201cc4:	00cad793          	srli	a5,s5,0xc
ffffffffc0201cc8:	66c7f463          	bgeu	a5,a2,ffffffffc0202330 <pmm_init+0x87a>
    // 断言：获取到的页表项地址与通过 get_pte 函数获取的地址相同
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0201ccc:	4601                	li	a2,0
ffffffffc0201cce:	6585                	lui	a1,0x1
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0201cd0:	9ae2                	add	s5,s5,s8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0201cd2:	9fbff0ef          	jal	ra,ffffffffc02016cc <get_pte>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0201cd6:	0aa1                	addi	s5,s5,8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0201cd8:	63551c63          	bne	a0,s5,ffffffffc0202310 <pmm_init+0x85a>

    // 分配一个页
    p2 = alloc_page();
ffffffffc0201cdc:	4505                	li	a0,1
ffffffffc0201cde:	8e3ff0ef          	jal	ra,ffffffffc02015c0 <alloc_pages>
ffffffffc0201ce2:	8aaa                	mv	s5,a0
    // 将页 p2 插入到页目录 boot_pgdir 中，地址为 PGSIZE，权限为 PTE_U | PTE_W
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0201ce4:	00093503          	ld	a0,0(s2)
ffffffffc0201ce8:	46d1                	li	a3,20
ffffffffc0201cea:	6605                	lui	a2,0x1
ffffffffc0201cec:	85d6                	mv	a1,s5
ffffffffc0201cee:	cc9ff0ef          	jal	ra,ffffffffc02019b6 <page_insert>
ffffffffc0201cf2:	5c051f63          	bnez	a0,ffffffffc02022d0 <pmm_init+0x81a>
    // 获取页目录 boot_pgdir 中地址为 PGSIZE 的页表项
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0))!= NULL);
ffffffffc0201cf6:	00093503          	ld	a0,0(s2)
ffffffffc0201cfa:	4601                	li	a2,0
ffffffffc0201cfc:	6585                	lui	a1,0x1
ffffffffc0201cfe:	9cfff0ef          	jal	ra,ffffffffc02016cc <get_pte>
ffffffffc0201d02:	12050ce3          	beqz	a0,ffffffffc020263a <pmm_init+0xb84>
    // 断言：页表项设置了 PTE_U 和 PTE_W 标志
    assert(*ptep & PTE_U);
ffffffffc0201d06:	611c                	ld	a5,0(a0)
ffffffffc0201d08:	0107f713          	andi	a4,a5,16
ffffffffc0201d0c:	72070f63          	beqz	a4,ffffffffc020244a <pmm_init+0x994>
    assert(*ptep & PTE_W);
ffffffffc0201d10:	8b91                	andi	a5,a5,4
ffffffffc0201d12:	6e078c63          	beqz	a5,ffffffffc020240a <pmm_init+0x954>
    // 断言：页目录的第一个页表项设置了 PTE_U 标志
    assert(boot_pgdir[0] & PTE_U);
ffffffffc0201d16:	00093503          	ld	a0,0(s2)
ffffffffc0201d1a:	611c                	ld	a5,0(a0)
ffffffffc0201d1c:	8bc1                	andi	a5,a5,16
ffffffffc0201d1e:	6c078663          	beqz	a5,ffffffffc02023ea <pmm_init+0x934>
    // 断言：页 p2 的引用计数为 1
    assert(page_ref(p2) == 1);
ffffffffc0201d22:	000aa703          	lw	a4,0(s5)
ffffffffc0201d26:	4785                	li	a5,1
ffffffffc0201d28:	5cf71463          	bne	a4,a5,ffffffffc02022f0 <pmm_init+0x83a>

    // 将页 p1 再次插入到页目录 boot_pgdir 中，地址为 PGSIZE，权限为 0
    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc0201d2c:	4681                	li	a3,0
ffffffffc0201d2e:	6605                	lui	a2,0x1
ffffffffc0201d30:	85d2                	mv	a1,s4
ffffffffc0201d32:	c85ff0ef          	jal	ra,ffffffffc02019b6 <page_insert>
ffffffffc0201d36:	66051a63          	bnez	a0,ffffffffc02023aa <pmm_init+0x8f4>
    // 断言：页 p1 的引用计数为 2
    assert(page_ref(p1) == 2);
ffffffffc0201d3a:	000a2703          	lw	a4,0(s4)
ffffffffc0201d3e:	4789                	li	a5,2
ffffffffc0201d40:	64f71563          	bne	a4,a5,ffffffffc020238a <pmm_init+0x8d4>
    // 断言：页 p2 的引用计数为 0
    assert(page_ref(p2) == 0);
ffffffffc0201d44:	000aa783          	lw	a5,0(s5)
ffffffffc0201d48:	62079163          	bnez	a5,ffffffffc020236a <pmm_init+0x8b4>
    // 获取页目录 boot_pgdir 中地址为 PGSIZE 的页表项
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0))!= NULL);
ffffffffc0201d4c:	00093503          	ld	a0,0(s2)
ffffffffc0201d50:	4601                	li	a2,0
ffffffffc0201d52:	6585                	lui	a1,0x1
ffffffffc0201d54:	979ff0ef          	jal	ra,ffffffffc02016cc <get_pte>
ffffffffc0201d58:	5e050963          	beqz	a0,ffffffffc020234a <pmm_init+0x894>
    // 断言：页表项指向的页是 p1
    assert(pte2page(*ptep) == p1);
ffffffffc0201d5c:	6118                	ld	a4,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0201d5e:	00177793          	andi	a5,a4,1
ffffffffc0201d62:	50078563          	beqz	a5,ffffffffc020226c <pmm_init+0x7b6>
    if (PPN(pa) >= npage) {
ffffffffc0201d66:	6094                	ld	a3,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201d68:	00271793          	slli	a5,a4,0x2
ffffffffc0201d6c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201d6e:	48d7f563          	bgeu	a5,a3,ffffffffc02021f8 <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc0201d72:	fff806b7          	lui	a3,0xfff80
ffffffffc0201d76:	97b6                	add	a5,a5,a3
ffffffffc0201d78:	000b3603          	ld	a2,0(s6)
ffffffffc0201d7c:	00379693          	slli	a3,a5,0x3
ffffffffc0201d80:	97b6                	add	a5,a5,a3
ffffffffc0201d82:	078e                	slli	a5,a5,0x3
ffffffffc0201d84:	97b2                	add	a5,a5,a2
ffffffffc0201d86:	72fa1263          	bne	s4,a5,ffffffffc02024aa <pmm_init+0x9f4>
    // 断言：页表项没有设置 PTE_U 标志
    assert((*ptep & PTE_U) == 0);
ffffffffc0201d8a:	8b41                	andi	a4,a4,16
ffffffffc0201d8c:	6e071f63          	bnez	a4,ffffffffc020248a <pmm_init+0x9d4>

    // 从页目录 boot_pgdir 中移除地址为 0x0 的页
    page_remove(boot_pgdir, 0x0);
ffffffffc0201d90:	00093503          	ld	a0,0(s2)
ffffffffc0201d94:	4581                	li	a1,0
ffffffffc0201d96:	b87ff0ef          	jal	ra,ffffffffc020191c <page_remove>
    // 断言：页 p1 的引用计数为 1
    assert(page_ref(p1) == 1);
ffffffffc0201d9a:	000a2703          	lw	a4,0(s4)
ffffffffc0201d9e:	4785                	li	a5,1
ffffffffc0201da0:	6cf71563          	bne	a4,a5,ffffffffc020246a <pmm_init+0x9b4>
    // 断言：页 p2 的引用计数为 0
    assert(page_ref(p2) == 0);
ffffffffc0201da4:	000aa783          	lw	a5,0(s5)
ffffffffc0201da8:	78079d63          	bnez	a5,ffffffffc0202542 <pmm_init+0xa8c>

    // 从页目录 boot_pgdir 中移除地址为 PGSIZE 的页
    page_remove(boot_pgdir, PGSIZE);
ffffffffc0201dac:	00093503          	ld	a0,0(s2)
ffffffffc0201db0:	6585                	lui	a1,0x1
ffffffffc0201db2:	b6bff0ef          	jal	ra,ffffffffc020191c <page_remove>
    // 断言：页 p1 的引用计数为 0
    assert(page_ref(p1) == 0);
ffffffffc0201db6:	000a2783          	lw	a5,0(s4)
ffffffffc0201dba:	76079463          	bnez	a5,ffffffffc0202522 <pmm_init+0xa6c>
    // 断言：页 p2 的引用计数为 0
    assert(page_ref(p2) == 0);
ffffffffc0201dbe:	000aa783          	lw	a5,0(s5)
ffffffffc0201dc2:	74079063          	bnez	a5,ffffffffc0202502 <pmm_init+0xa4c>

    // 断言：页目录的第一个页表的引用计数为 1
    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc0201dc6:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0201dca:	6090                	ld	a2,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201dcc:	000a3783          	ld	a5,0(s4)
ffffffffc0201dd0:	078a                	slli	a5,a5,0x2
ffffffffc0201dd2:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201dd4:	42c7f263          	bgeu	a5,a2,ffffffffc02021f8 <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc0201dd8:	fff80737          	lui	a4,0xfff80
ffffffffc0201ddc:	973e                	add	a4,a4,a5
ffffffffc0201dde:	00371793          	slli	a5,a4,0x3
ffffffffc0201de2:	000b3503          	ld	a0,0(s6)
ffffffffc0201de6:	97ba                	add	a5,a5,a4
ffffffffc0201de8:	078e                	slli	a5,a5,0x3
static inline int page_ref(struct Page *page) { return page->ref; }
ffffffffc0201dea:	00f50733          	add	a4,a0,a5
ffffffffc0201dee:	4314                	lw	a3,0(a4)
ffffffffc0201df0:	4705                	li	a4,1
ffffffffc0201df2:	6ee69863          	bne	a3,a4,ffffffffc02024e2 <pmm_init+0xa2c>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201df6:	4037d693          	srai	a3,a5,0x3
ffffffffc0201dfa:	00004c97          	auipc	s9,0x4
ffffffffc0201dfe:	5b6cbc83          	ld	s9,1462(s9) # ffffffffc02063b0 <error_string+0x38>
ffffffffc0201e02:	039686b3          	mul	a3,a3,s9
ffffffffc0201e06:	000805b7          	lui	a1,0x80
ffffffffc0201e0a:	96ae                	add	a3,a3,a1
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201e0c:	00c69713          	slli	a4,a3,0xc
ffffffffc0201e10:	8331                	srli	a4,a4,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0201e12:	06b2                	slli	a3,a3,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201e14:	6ac77b63          	bgeu	a4,a2,ffffffffc02024ca <pmm_init+0xa14>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
    // 释放页目录的第一个页表的物理页
    free_page(pde2page(pd0[0]));
ffffffffc0201e18:	0009b703          	ld	a4,0(s3)
ffffffffc0201e1c:	96ba                	add	a3,a3,a4
    return pa2page(PDE_ADDR(pde));
ffffffffc0201e1e:	629c                	ld	a5,0(a3)
ffffffffc0201e20:	078a                	slli	a5,a5,0x2
ffffffffc0201e22:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201e24:	3cc7fa63          	bgeu	a5,a2,ffffffffc02021f8 <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc0201e28:	8f8d                	sub	a5,a5,a1
ffffffffc0201e2a:	00379713          	slli	a4,a5,0x3
ffffffffc0201e2e:	97ba                	add	a5,a5,a4
ffffffffc0201e30:	078e                	slli	a5,a5,0x3
ffffffffc0201e32:	953e                	add	a0,a0,a5
ffffffffc0201e34:	100027f3          	csrr	a5,sstatus
ffffffffc0201e38:	8b89                	andi	a5,a5,2
ffffffffc0201e3a:	2e079963          	bnez	a5,ffffffffc020212c <pmm_init+0x676>
    { pmm_manager->free_pages(base, n); }
ffffffffc0201e3e:	000bb783          	ld	a5,0(s7)
ffffffffc0201e42:	4585                	li	a1,1
ffffffffc0201e44:	739c                	ld	a5,32(a5)
ffffffffc0201e46:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0201e48:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage) {
ffffffffc0201e4c:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201e4e:	078a                	slli	a5,a5,0x2
ffffffffc0201e50:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201e52:	3ae7f363          	bgeu	a5,a4,ffffffffc02021f8 <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc0201e56:	fff80737          	lui	a4,0xfff80
ffffffffc0201e5a:	97ba                	add	a5,a5,a4
ffffffffc0201e5c:	000b3503          	ld	a0,0(s6)
ffffffffc0201e60:	00379713          	slli	a4,a5,0x3
ffffffffc0201e64:	97ba                	add	a5,a5,a4
ffffffffc0201e66:	078e                	slli	a5,a5,0x3
ffffffffc0201e68:	953e                	add	a0,a0,a5
ffffffffc0201e6a:	100027f3          	csrr	a5,sstatus
ffffffffc0201e6e:	8b89                	andi	a5,a5,2
ffffffffc0201e70:	2a079263          	bnez	a5,ffffffffc0202114 <pmm_init+0x65e>
ffffffffc0201e74:	000bb783          	ld	a5,0(s7)
ffffffffc0201e78:	4585                	li	a1,1
ffffffffc0201e7a:	739c                	ld	a5,32(a5)
ffffffffc0201e7c:	9782                	jalr	a5
    // 释放页目录的第一个页表的物理页
    free_page(pde2page(pd1[0]));
    // 将页目录的第一个页表项清零
    boot_pgdir[0] = 0;
ffffffffc0201e7e:	00093783          	ld	a5,0(s2)
ffffffffc0201e82:	0007b023          	sd	zero,0(a5) # fffffffffffff000 <end+0x3fdeda9c>
ffffffffc0201e86:	100027f3          	csrr	a5,sstatus
ffffffffc0201e8a:	8b89                	andi	a5,a5,2
ffffffffc0201e8c:	26079a63          	bnez	a5,ffffffffc0202100 <pmm_init+0x64a>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc0201e90:	000bb783          	ld	a5,0(s7)
ffffffffc0201e94:	779c                	ld	a5,40(a5)
ffffffffc0201e96:	9782                	jalr	a5
ffffffffc0201e98:	8a2a                	mv	s4,a0

    // 断言：空闲页面数量与检查前相同
    assert(nr_free_store==nr_free_pages());
ffffffffc0201e9a:	73441463          	bne	s0,s4,ffffffffc02025c2 <pmm_init+0xb0c>

    // 打印检查通过信息
    cprintf("check_pgdir() succeeded!\n");
ffffffffc0201e9e:	00003517          	auipc	a0,0x3
ffffffffc0201ea2:	76a50513          	addi	a0,a0,1898 # ffffffffc0205608 <default_pmm_manager+0x460>
ffffffffc0201ea6:	a14fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0201eaa:	100027f3          	csrr	a5,sstatus
ffffffffc0201eae:	8b89                	andi	a5,a5,2
ffffffffc0201eb0:	22079e63          	bnez	a5,ffffffffc02020ec <pmm_init+0x636>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc0201eb4:	000bb783          	ld	a5,0(s7)
ffffffffc0201eb8:	779c                	ld	a5,40(a5)
ffffffffc0201eba:	9782                	jalr	a5
ffffffffc0201ebc:	8c2a                	mv	s8,a0
    pte_t *ptep;
    int i;

    nr_free_store=nr_free_pages();

    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0201ebe:	6098                	ld	a4,0(s1)
ffffffffc0201ec0:	c0200437          	lui	s0,0xc0200
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0201ec4:	7afd                	lui	s5,0xfffff
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0201ec6:	00c71793          	slli	a5,a4,0xc
ffffffffc0201eca:	6a05                	lui	s4,0x1
ffffffffc0201ecc:	02f47c63          	bgeu	s0,a5,ffffffffc0201f04 <pmm_init+0x44e>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0201ed0:	00c45793          	srli	a5,s0,0xc
ffffffffc0201ed4:	00093503          	ld	a0,0(s2)
ffffffffc0201ed8:	30e7f363          	bgeu	a5,a4,ffffffffc02021de <pmm_init+0x728>
ffffffffc0201edc:	0009b583          	ld	a1,0(s3)
ffffffffc0201ee0:	4601                	li	a2,0
ffffffffc0201ee2:	95a2                	add	a1,a1,s0
ffffffffc0201ee4:	fe8ff0ef          	jal	ra,ffffffffc02016cc <get_pte>
ffffffffc0201ee8:	2c050b63          	beqz	a0,ffffffffc02021be <pmm_init+0x708>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0201eec:	611c                	ld	a5,0(a0)
ffffffffc0201eee:	078a                	slli	a5,a5,0x2
ffffffffc0201ef0:	0157f7b3          	and	a5,a5,s5
ffffffffc0201ef4:	2a879563          	bne	a5,s0,ffffffffc020219e <pmm_init+0x6e8>
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0201ef8:	6098                	ld	a4,0(s1)
ffffffffc0201efa:	9452                	add	s0,s0,s4
ffffffffc0201efc:	00c71793          	slli	a5,a4,0xc
ffffffffc0201f00:	fcf468e3          	bltu	s0,a5,ffffffffc0201ed0 <pmm_init+0x41a>
    }


    assert(boot_pgdir[0] == 0);
ffffffffc0201f04:	00093783          	ld	a5,0(s2)
ffffffffc0201f08:	639c                	ld	a5,0(a5)
ffffffffc0201f0a:	68079c63          	bnez	a5,ffffffffc02025a2 <pmm_init+0xaec>

    struct Page *p;
    p = alloc_page();
ffffffffc0201f0e:	4505                	li	a0,1
ffffffffc0201f10:	eb0ff0ef          	jal	ra,ffffffffc02015c0 <alloc_pages>
ffffffffc0201f14:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0201f16:	00093503          	ld	a0,0(s2)
ffffffffc0201f1a:	4699                	li	a3,6
ffffffffc0201f1c:	10000613          	li	a2,256
ffffffffc0201f20:	85d6                	mv	a1,s5
ffffffffc0201f22:	a95ff0ef          	jal	ra,ffffffffc02019b6 <page_insert>
ffffffffc0201f26:	64051e63          	bnez	a0,ffffffffc0202582 <pmm_init+0xacc>
    assert(page_ref(p) == 1);
ffffffffc0201f2a:	000aa703          	lw	a4,0(s5) # fffffffffffff000 <end+0x3fdeda9c>
ffffffffc0201f2e:	4785                	li	a5,1
ffffffffc0201f30:	62f71963          	bne	a4,a5,ffffffffc0202562 <pmm_init+0xaac>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0201f34:	00093503          	ld	a0,0(s2)
ffffffffc0201f38:	6405                	lui	s0,0x1
ffffffffc0201f3a:	4699                	li	a3,6
ffffffffc0201f3c:	10040613          	addi	a2,s0,256 # 1100 <kern_entry-0xffffffffc01fef00>
ffffffffc0201f40:	85d6                	mv	a1,s5
ffffffffc0201f42:	a75ff0ef          	jal	ra,ffffffffc02019b6 <page_insert>
ffffffffc0201f46:	48051263          	bnez	a0,ffffffffc02023ca <pmm_init+0x914>
    assert(page_ref(p) == 2);
ffffffffc0201f4a:	000aa703          	lw	a4,0(s5)
ffffffffc0201f4e:	4789                	li	a5,2
ffffffffc0201f50:	74f71563          	bne	a4,a5,ffffffffc020269a <pmm_init+0xbe4>

    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
ffffffffc0201f54:	00003597          	auipc	a1,0x3
ffffffffc0201f58:	7ec58593          	addi	a1,a1,2028 # ffffffffc0205740 <default_pmm_manager+0x598>
ffffffffc0201f5c:	10000513          	li	a0,256
ffffffffc0201f60:	496020ef          	jal	ra,ffffffffc02043f6 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0201f64:	10040593          	addi	a1,s0,256
ffffffffc0201f68:	10000513          	li	a0,256
ffffffffc0201f6c:	49c020ef          	jal	ra,ffffffffc0204408 <strcmp>
ffffffffc0201f70:	70051563          	bnez	a0,ffffffffc020267a <pmm_init+0xbc4>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201f74:	000b3683          	ld	a3,0(s6)
ffffffffc0201f78:	00080d37          	lui	s10,0x80
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201f7c:	547d                	li	s0,-1
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201f7e:	40da86b3          	sub	a3,s5,a3
ffffffffc0201f82:	868d                	srai	a3,a3,0x3
ffffffffc0201f84:	039686b3          	mul	a3,a3,s9
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201f88:	609c                	ld	a5,0(s1)
ffffffffc0201f8a:	8031                	srli	s0,s0,0xc
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201f8c:	96ea                	add	a3,a3,s10
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201f8e:	0086f733          	and	a4,a3,s0
    return page2ppn(page) << PGSHIFT;
ffffffffc0201f92:	06b2                	slli	a3,a3,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201f94:	52f77b63          	bgeu	a4,a5,ffffffffc02024ca <pmm_init+0xa14>

    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0201f98:	0009b783          	ld	a5,0(s3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc0201f9c:	10000513          	li	a0,256
    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0201fa0:	96be                	add	a3,a3,a5
ffffffffc0201fa2:	10068023          	sb	zero,256(a3) # fffffffffff80100 <end+0x3fd6eb9c>
    assert(strlen((const char *)0x100) == 0);
ffffffffc0201fa6:	41a020ef          	jal	ra,ffffffffc02043c0 <strlen>
ffffffffc0201faa:	6a051863          	bnez	a0,ffffffffc020265a <pmm_init+0xba4>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc0201fae:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0201fb2:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201fb4:	000a3783          	ld	a5,0(s4) # 1000 <kern_entry-0xffffffffc01ff000>
ffffffffc0201fb8:	078a                	slli	a5,a5,0x2
ffffffffc0201fba:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201fbc:	22e7fe63          	bgeu	a5,a4,ffffffffc02021f8 <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc0201fc0:	41a787b3          	sub	a5,a5,s10
ffffffffc0201fc4:	00379693          	slli	a3,a5,0x3
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201fc8:	96be                	add	a3,a3,a5
ffffffffc0201fca:	03968cb3          	mul	s9,a3,s9
ffffffffc0201fce:	01ac86b3          	add	a3,s9,s10
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201fd2:	8c75                	and	s0,s0,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0201fd4:	06b2                	slli	a3,a3,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201fd6:	4ee47a63          	bgeu	s0,a4,ffffffffc02024ca <pmm_init+0xa14>
ffffffffc0201fda:	0009b403          	ld	s0,0(s3)
ffffffffc0201fde:	9436                	add	s0,s0,a3
ffffffffc0201fe0:	100027f3          	csrr	a5,sstatus
ffffffffc0201fe4:	8b89                	andi	a5,a5,2
ffffffffc0201fe6:	1a079163          	bnez	a5,ffffffffc0202188 <pmm_init+0x6d2>
    { pmm_manager->free_pages(base, n); }
ffffffffc0201fea:	000bb783          	ld	a5,0(s7)
ffffffffc0201fee:	4585                	li	a1,1
ffffffffc0201ff0:	8556                	mv	a0,s5
ffffffffc0201ff2:	739c                	ld	a5,32(a5)
ffffffffc0201ff4:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0201ff6:	601c                	ld	a5,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc0201ff8:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201ffa:	078a                	slli	a5,a5,0x2
ffffffffc0201ffc:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201ffe:	1ee7fd63          	bgeu	a5,a4,ffffffffc02021f8 <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc0202002:	fff80737          	lui	a4,0xfff80
ffffffffc0202006:	97ba                	add	a5,a5,a4
ffffffffc0202008:	000b3503          	ld	a0,0(s6)
ffffffffc020200c:	00379713          	slli	a4,a5,0x3
ffffffffc0202010:	97ba                	add	a5,a5,a4
ffffffffc0202012:	078e                	slli	a5,a5,0x3
ffffffffc0202014:	953e                	add	a0,a0,a5
ffffffffc0202016:	100027f3          	csrr	a5,sstatus
ffffffffc020201a:	8b89                	andi	a5,a5,2
ffffffffc020201c:	14079a63          	bnez	a5,ffffffffc0202170 <pmm_init+0x6ba>
ffffffffc0202020:	000bb783          	ld	a5,0(s7)
ffffffffc0202024:	4585                	li	a1,1
ffffffffc0202026:	739c                	ld	a5,32(a5)
ffffffffc0202028:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc020202a:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage) {
ffffffffc020202e:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202030:	078a                	slli	a5,a5,0x2
ffffffffc0202032:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202034:	1ce7f263          	bgeu	a5,a4,ffffffffc02021f8 <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc0202038:	fff80737          	lui	a4,0xfff80
ffffffffc020203c:	97ba                	add	a5,a5,a4
ffffffffc020203e:	000b3503          	ld	a0,0(s6)
ffffffffc0202042:	00379713          	slli	a4,a5,0x3
ffffffffc0202046:	97ba                	add	a5,a5,a4
ffffffffc0202048:	078e                	slli	a5,a5,0x3
ffffffffc020204a:	953e                	add	a0,a0,a5
ffffffffc020204c:	100027f3          	csrr	a5,sstatus
ffffffffc0202050:	8b89                	andi	a5,a5,2
ffffffffc0202052:	10079363          	bnez	a5,ffffffffc0202158 <pmm_init+0x6a2>
ffffffffc0202056:	000bb783          	ld	a5,0(s7)
ffffffffc020205a:	4585                	li	a1,1
ffffffffc020205c:	739c                	ld	a5,32(a5)
ffffffffc020205e:	9782                	jalr	a5
    free_page(p);
    free_page(pde2page(pd0[0]));
    free_page(pde2page(pd1[0]));
    boot_pgdir[0] = 0;
ffffffffc0202060:	00093783          	ld	a5,0(s2)
ffffffffc0202064:	0007b023          	sd	zero,0(a5)
ffffffffc0202068:	100027f3          	csrr	a5,sstatus
ffffffffc020206c:	8b89                	andi	a5,a5,2
ffffffffc020206e:	0c079b63          	bnez	a5,ffffffffc0202144 <pmm_init+0x68e>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc0202072:	000bb783          	ld	a5,0(s7)
ffffffffc0202076:	779c                	ld	a5,40(a5)
ffffffffc0202078:	9782                	jalr	a5
ffffffffc020207a:	842a                	mv	s0,a0

    assert(nr_free_store==nr_free_pages());
ffffffffc020207c:	3a8c1763          	bne	s8,s0,ffffffffc020242a <pmm_init+0x974>
}
ffffffffc0202080:	7406                	ld	s0,96(sp)
ffffffffc0202082:	70a6                	ld	ra,104(sp)
ffffffffc0202084:	64e6                	ld	s1,88(sp)
ffffffffc0202086:	6946                	ld	s2,80(sp)
ffffffffc0202088:	69a6                	ld	s3,72(sp)
ffffffffc020208a:	6a06                	ld	s4,64(sp)
ffffffffc020208c:	7ae2                	ld	s5,56(sp)
ffffffffc020208e:	7b42                	ld	s6,48(sp)
ffffffffc0202090:	7ba2                	ld	s7,40(sp)
ffffffffc0202092:	7c02                	ld	s8,32(sp)
ffffffffc0202094:	6ce2                	ld	s9,24(sp)
ffffffffc0202096:	6d42                	ld	s10,16(sp)

    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc0202098:	00003517          	auipc	a0,0x3
ffffffffc020209c:	72050513          	addi	a0,a0,1824 # ffffffffc02057b8 <default_pmm_manager+0x610>
}
ffffffffc02020a0:	6165                	addi	sp,sp,112
    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc02020a2:	818fe06f          	j	ffffffffc02000ba <cprintf>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc02020a6:	6705                	lui	a4,0x1
ffffffffc02020a8:	177d                	addi	a4,a4,-1
ffffffffc02020aa:	96ba                	add	a3,a3,a4
ffffffffc02020ac:	777d                	lui	a4,0xfffff
ffffffffc02020ae:	8f75                	and	a4,a4,a3
    if (PPN(pa) >= npage) {
ffffffffc02020b0:	00c75693          	srli	a3,a4,0xc
ffffffffc02020b4:	14f6f263          	bgeu	a3,a5,ffffffffc02021f8 <pmm_init+0x742>
    pmm_manager->init_memmap(base, n);
ffffffffc02020b8:	000bb803          	ld	a6,0(s7)
    return &pages[PPN(pa) - nbase];
ffffffffc02020bc:	95b6                	add	a1,a1,a3
ffffffffc02020be:	00359793          	slli	a5,a1,0x3
ffffffffc02020c2:	97ae                	add	a5,a5,a1
ffffffffc02020c4:	01083683          	ld	a3,16(a6)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc02020c8:	40e60733          	sub	a4,a2,a4
ffffffffc02020cc:	078e                	slli	a5,a5,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc02020ce:	00c75593          	srli	a1,a4,0xc
ffffffffc02020d2:	953e                	add	a0,a0,a5
ffffffffc02020d4:	9682                	jalr	a3
}
ffffffffc02020d6:	bcc5                	j	ffffffffc0201bc6 <pmm_init+0x110>
        intr_disable();
ffffffffc02020d8:	c16fe0ef          	jal	ra,ffffffffc02004ee <intr_disable>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc02020dc:	000bb783          	ld	a5,0(s7)
ffffffffc02020e0:	779c                	ld	a5,40(a5)
ffffffffc02020e2:	9782                	jalr	a5
ffffffffc02020e4:	842a                	mv	s0,a0
        intr_enable();
ffffffffc02020e6:	c02fe0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc02020ea:	b63d                	j	ffffffffc0201c18 <pmm_init+0x162>
        intr_disable();
ffffffffc02020ec:	c02fe0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc02020f0:	000bb783          	ld	a5,0(s7)
ffffffffc02020f4:	779c                	ld	a5,40(a5)
ffffffffc02020f6:	9782                	jalr	a5
ffffffffc02020f8:	8c2a                	mv	s8,a0
        intr_enable();
ffffffffc02020fa:	beefe0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc02020fe:	b3c1                	j	ffffffffc0201ebe <pmm_init+0x408>
        intr_disable();
ffffffffc0202100:	beefe0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc0202104:	000bb783          	ld	a5,0(s7)
ffffffffc0202108:	779c                	ld	a5,40(a5)
ffffffffc020210a:	9782                	jalr	a5
ffffffffc020210c:	8a2a                	mv	s4,a0
        intr_enable();
ffffffffc020210e:	bdafe0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc0202112:	b361                	j	ffffffffc0201e9a <pmm_init+0x3e4>
ffffffffc0202114:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0202116:	bd8fe0ef          	jal	ra,ffffffffc02004ee <intr_disable>
    { pmm_manager->free_pages(base, n); }
ffffffffc020211a:	000bb783          	ld	a5,0(s7)
ffffffffc020211e:	6522                	ld	a0,8(sp)
ffffffffc0202120:	4585                	li	a1,1
ffffffffc0202122:	739c                	ld	a5,32(a5)
ffffffffc0202124:	9782                	jalr	a5
        intr_enable();
ffffffffc0202126:	bc2fe0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc020212a:	bb91                	j	ffffffffc0201e7e <pmm_init+0x3c8>
ffffffffc020212c:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc020212e:	bc0fe0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc0202132:	000bb783          	ld	a5,0(s7)
ffffffffc0202136:	6522                	ld	a0,8(sp)
ffffffffc0202138:	4585                	li	a1,1
ffffffffc020213a:	739c                	ld	a5,32(a5)
ffffffffc020213c:	9782                	jalr	a5
        intr_enable();
ffffffffc020213e:	baafe0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc0202142:	b319                	j	ffffffffc0201e48 <pmm_init+0x392>
        intr_disable();
ffffffffc0202144:	baafe0ef          	jal	ra,ffffffffc02004ee <intr_disable>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc0202148:	000bb783          	ld	a5,0(s7)
ffffffffc020214c:	779c                	ld	a5,40(a5)
ffffffffc020214e:	9782                	jalr	a5
ffffffffc0202150:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0202152:	b96fe0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc0202156:	b71d                	j	ffffffffc020207c <pmm_init+0x5c6>
ffffffffc0202158:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc020215a:	b94fe0ef          	jal	ra,ffffffffc02004ee <intr_disable>
    { pmm_manager->free_pages(base, n); }
ffffffffc020215e:	000bb783          	ld	a5,0(s7)
ffffffffc0202162:	6522                	ld	a0,8(sp)
ffffffffc0202164:	4585                	li	a1,1
ffffffffc0202166:	739c                	ld	a5,32(a5)
ffffffffc0202168:	9782                	jalr	a5
        intr_enable();
ffffffffc020216a:	b7efe0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc020216e:	bdcd                	j	ffffffffc0202060 <pmm_init+0x5aa>
ffffffffc0202170:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0202172:	b7cfe0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc0202176:	000bb783          	ld	a5,0(s7)
ffffffffc020217a:	6522                	ld	a0,8(sp)
ffffffffc020217c:	4585                	li	a1,1
ffffffffc020217e:	739c                	ld	a5,32(a5)
ffffffffc0202180:	9782                	jalr	a5
        intr_enable();
ffffffffc0202182:	b66fe0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc0202186:	b555                	j	ffffffffc020202a <pmm_init+0x574>
        intr_disable();
ffffffffc0202188:	b66fe0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc020218c:	000bb783          	ld	a5,0(s7)
ffffffffc0202190:	4585                	li	a1,1
ffffffffc0202192:	8556                	mv	a0,s5
ffffffffc0202194:	739c                	ld	a5,32(a5)
ffffffffc0202196:	9782                	jalr	a5
        intr_enable();
ffffffffc0202198:	b50fe0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc020219c:	bda9                	j	ffffffffc0201ff6 <pmm_init+0x540>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc020219e:	00003697          	auipc	a3,0x3
ffffffffc02021a2:	4ca68693          	addi	a3,a3,1226 # ffffffffc0205668 <default_pmm_manager+0x4c0>
ffffffffc02021a6:	00003617          	auipc	a2,0x3
ffffffffc02021aa:	c5260613          	addi	a2,a2,-942 # ffffffffc0204df8 <commands+0x738>
ffffffffc02021ae:	1f100593          	li	a1,497
ffffffffc02021b2:	00003517          	auipc	a0,0x3
ffffffffc02021b6:	0ae50513          	addi	a0,a0,174 # ffffffffc0205260 <default_pmm_manager+0xb8>
ffffffffc02021ba:	9bafe0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc02021be:	00003697          	auipc	a3,0x3
ffffffffc02021c2:	46a68693          	addi	a3,a3,1130 # ffffffffc0205628 <default_pmm_manager+0x480>
ffffffffc02021c6:	00003617          	auipc	a2,0x3
ffffffffc02021ca:	c3260613          	addi	a2,a2,-974 # ffffffffc0204df8 <commands+0x738>
ffffffffc02021ce:	1f000593          	li	a1,496
ffffffffc02021d2:	00003517          	auipc	a0,0x3
ffffffffc02021d6:	08e50513          	addi	a0,a0,142 # ffffffffc0205260 <default_pmm_manager+0xb8>
ffffffffc02021da:	99afe0ef          	jal	ra,ffffffffc0200374 <__panic>
ffffffffc02021de:	86a2                	mv	a3,s0
ffffffffc02021e0:	00003617          	auipc	a2,0x3
ffffffffc02021e4:	05860613          	addi	a2,a2,88 # ffffffffc0205238 <default_pmm_manager+0x90>
ffffffffc02021e8:	1f000593          	li	a1,496
ffffffffc02021ec:	00003517          	auipc	a0,0x3
ffffffffc02021f0:	07450513          	addi	a0,a0,116 # ffffffffc0205260 <default_pmm_manager+0xb8>
ffffffffc02021f4:	980fe0ef          	jal	ra,ffffffffc0200374 <__panic>
ffffffffc02021f8:	b90ff0ef          	jal	ra,ffffffffc0201588 <pa2page.part.0>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02021fc:	00003617          	auipc	a2,0x3
ffffffffc0202200:	0fc60613          	addi	a2,a2,252 # ffffffffc02052f8 <default_pmm_manager+0x150>
ffffffffc0202204:	07700593          	li	a1,119
ffffffffc0202208:	00003517          	auipc	a0,0x3
ffffffffc020220c:	05850513          	addi	a0,a0,88 # ffffffffc0205260 <default_pmm_manager+0xb8>
ffffffffc0202210:	964fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc0202214:	00003617          	auipc	a2,0x3
ffffffffc0202218:	0e460613          	addi	a2,a2,228 # ffffffffc02052f8 <default_pmm_manager+0x150>
ffffffffc020221c:	0bd00593          	li	a1,189
ffffffffc0202220:	00003517          	auipc	a0,0x3
ffffffffc0202224:	04050513          	addi	a0,a0,64 # ffffffffc0205260 <default_pmm_manager+0xb8>
ffffffffc0202228:	94cfe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(boot_pgdir!= NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc020222c:	00003697          	auipc	a3,0x3
ffffffffc0202230:	13468693          	addi	a3,a3,308 # ffffffffc0205360 <default_pmm_manager+0x1b8>
ffffffffc0202234:	00003617          	auipc	a2,0x3
ffffffffc0202238:	bc460613          	addi	a2,a2,-1084 # ffffffffc0204df8 <commands+0x738>
ffffffffc020223c:	19500593          	li	a1,405
ffffffffc0202240:	00003517          	auipc	a0,0x3
ffffffffc0202244:	02050513          	addi	a0,a0,32 # ffffffffc0205260 <default_pmm_manager+0xb8>
ffffffffc0202248:	92cfe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc020224c:	00003697          	auipc	a3,0x3
ffffffffc0202250:	0f468693          	addi	a3,a3,244 # ffffffffc0205340 <default_pmm_manager+0x198>
ffffffffc0202254:	00003617          	auipc	a2,0x3
ffffffffc0202258:	ba460613          	addi	a2,a2,-1116 # ffffffffc0204df8 <commands+0x738>
ffffffffc020225c:	19300593          	li	a1,403
ffffffffc0202260:	00003517          	auipc	a0,0x3
ffffffffc0202264:	00050513          	mv	a0,a0
ffffffffc0202268:	90cfe0ef          	jal	ra,ffffffffc0200374 <__panic>
ffffffffc020226c:	b38ff0ef          	jal	ra,ffffffffc02015a4 <pte2page.part.0>
    assert((ptep = get_pte(boot_pgdir, 0x0, 0))!= NULL);
ffffffffc0202270:	00003697          	auipc	a3,0x3
ffffffffc0202274:	18068693          	addi	a3,a3,384 # ffffffffc02053f0 <default_pmm_manager+0x248>
ffffffffc0202278:	00003617          	auipc	a2,0x3
ffffffffc020227c:	b8060613          	addi	a2,a2,-1152 # ffffffffc0204df8 <commands+0x738>
ffffffffc0202280:	1a000593          	li	a1,416
ffffffffc0202284:	00003517          	auipc	a0,0x3
ffffffffc0202288:	fdc50513          	addi	a0,a0,-36 # ffffffffc0205260 <default_pmm_manager+0xb8>
ffffffffc020228c:	8e8fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc0202290:	00003697          	auipc	a3,0x3
ffffffffc0202294:	13068693          	addi	a3,a3,304 # ffffffffc02053c0 <default_pmm_manager+0x218>
ffffffffc0202298:	00003617          	auipc	a2,0x3
ffffffffc020229c:	b6060613          	addi	a2,a2,-1184 # ffffffffc0204df8 <commands+0x738>
ffffffffc02022a0:	19d00593          	li	a1,413
ffffffffc02022a4:	00003517          	auipc	a0,0x3
ffffffffc02022a8:	fbc50513          	addi	a0,a0,-68 # ffffffffc0205260 <default_pmm_manager+0xb8>
ffffffffc02022ac:	8c8fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc02022b0:	00003697          	auipc	a3,0x3
ffffffffc02022b4:	0e868693          	addi	a3,a3,232 # ffffffffc0205398 <default_pmm_manager+0x1f0>
ffffffffc02022b8:	00003617          	auipc	a2,0x3
ffffffffc02022bc:	b4060613          	addi	a2,a2,-1216 # ffffffffc0204df8 <commands+0x738>
ffffffffc02022c0:	19700593          	li	a1,407
ffffffffc02022c4:	00003517          	auipc	a0,0x3
ffffffffc02022c8:	f9c50513          	addi	a0,a0,-100 # ffffffffc0205260 <default_pmm_manager+0xb8>
ffffffffc02022cc:	8a8fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc02022d0:	00003697          	auipc	a3,0x3
ffffffffc02022d4:	1a868693          	addi	a3,a3,424 # ffffffffc0205478 <default_pmm_manager+0x2d0>
ffffffffc02022d8:	00003617          	auipc	a2,0x3
ffffffffc02022dc:	b2060613          	addi	a2,a2,-1248 # ffffffffc0204df8 <commands+0x738>
ffffffffc02022e0:	1b000593          	li	a1,432
ffffffffc02022e4:	00003517          	auipc	a0,0x3
ffffffffc02022e8:	f7c50513          	addi	a0,a0,-132 # ffffffffc0205260 <default_pmm_manager+0xb8>
ffffffffc02022ec:	888fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p2) == 1);
ffffffffc02022f0:	00003697          	auipc	a3,0x3
ffffffffc02022f4:	22868693          	addi	a3,a3,552 # ffffffffc0205518 <default_pmm_manager+0x370>
ffffffffc02022f8:	00003617          	auipc	a2,0x3
ffffffffc02022fc:	b0060613          	addi	a2,a2,-1280 # ffffffffc0204df8 <commands+0x738>
ffffffffc0202300:	1b900593          	li	a1,441
ffffffffc0202304:	00003517          	auipc	a0,0x3
ffffffffc0202308:	f5c50513          	addi	a0,a0,-164 # ffffffffc0205260 <default_pmm_manager+0xb8>
ffffffffc020230c:	868fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0202310:	00003697          	auipc	a3,0x3
ffffffffc0202314:	14068693          	addi	a3,a3,320 # ffffffffc0205450 <default_pmm_manager+0x2a8>
ffffffffc0202318:	00003617          	auipc	a2,0x3
ffffffffc020231c:	ae060613          	addi	a2,a2,-1312 # ffffffffc0204df8 <commands+0x738>
ffffffffc0202320:	1ab00593          	li	a1,427
ffffffffc0202324:	00003517          	auipc	a0,0x3
ffffffffc0202328:	f3c50513          	addi	a0,a0,-196 # ffffffffc0205260 <default_pmm_manager+0xb8>
ffffffffc020232c:	848fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202330:	86d6                	mv	a3,s5
ffffffffc0202332:	00003617          	auipc	a2,0x3
ffffffffc0202336:	f0660613          	addi	a2,a2,-250 # ffffffffc0205238 <default_pmm_manager+0x90>
ffffffffc020233a:	1a900593          	li	a1,425
ffffffffc020233e:	00003517          	auipc	a0,0x3
ffffffffc0202342:	f2250513          	addi	a0,a0,-222 # ffffffffc0205260 <default_pmm_manager+0xb8>
ffffffffc0202346:	82efe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0))!= NULL);
ffffffffc020234a:	00003697          	auipc	a3,0x3
ffffffffc020234e:	16668693          	addi	a3,a3,358 # ffffffffc02054b0 <default_pmm_manager+0x308>
ffffffffc0202352:	00003617          	auipc	a2,0x3
ffffffffc0202356:	aa660613          	addi	a2,a2,-1370 # ffffffffc0204df8 <commands+0x738>
ffffffffc020235a:	1c200593          	li	a1,450
ffffffffc020235e:	00003517          	auipc	a0,0x3
ffffffffc0202362:	f0250513          	addi	a0,a0,-254 # ffffffffc0205260 <default_pmm_manager+0xb8>
ffffffffc0202366:	80efe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc020236a:	00003697          	auipc	a3,0x3
ffffffffc020236e:	20e68693          	addi	a3,a3,526 # ffffffffc0205578 <default_pmm_manager+0x3d0>
ffffffffc0202372:	00003617          	auipc	a2,0x3
ffffffffc0202376:	a8660613          	addi	a2,a2,-1402 # ffffffffc0204df8 <commands+0x738>
ffffffffc020237a:	1c000593          	li	a1,448
ffffffffc020237e:	00003517          	auipc	a0,0x3
ffffffffc0202382:	ee250513          	addi	a0,a0,-286 # ffffffffc0205260 <default_pmm_manager+0xb8>
ffffffffc0202386:	feffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p1) == 2);
ffffffffc020238a:	00003697          	auipc	a3,0x3
ffffffffc020238e:	1d668693          	addi	a3,a3,470 # ffffffffc0205560 <default_pmm_manager+0x3b8>
ffffffffc0202392:	00003617          	auipc	a2,0x3
ffffffffc0202396:	a6660613          	addi	a2,a2,-1434 # ffffffffc0204df8 <commands+0x738>
ffffffffc020239a:	1be00593          	li	a1,446
ffffffffc020239e:	00003517          	auipc	a0,0x3
ffffffffc02023a2:	ec250513          	addi	a0,a0,-318 # ffffffffc0205260 <default_pmm_manager+0xb8>
ffffffffc02023a6:	fcffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc02023aa:	00003697          	auipc	a3,0x3
ffffffffc02023ae:	18668693          	addi	a3,a3,390 # ffffffffc0205530 <default_pmm_manager+0x388>
ffffffffc02023b2:	00003617          	auipc	a2,0x3
ffffffffc02023b6:	a4660613          	addi	a2,a2,-1466 # ffffffffc0204df8 <commands+0x738>
ffffffffc02023ba:	1bc00593          	li	a1,444
ffffffffc02023be:	00003517          	auipc	a0,0x3
ffffffffc02023c2:	ea250513          	addi	a0,a0,-350 # ffffffffc0205260 <default_pmm_manager+0xb8>
ffffffffc02023c6:	faffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc02023ca:	00003697          	auipc	a3,0x3
ffffffffc02023ce:	31e68693          	addi	a3,a3,798 # ffffffffc02056e8 <default_pmm_manager+0x540>
ffffffffc02023d2:	00003617          	auipc	a2,0x3
ffffffffc02023d6:	a2660613          	addi	a2,a2,-1498 # ffffffffc0204df8 <commands+0x738>
ffffffffc02023da:	1fb00593          	li	a1,507
ffffffffc02023de:	00003517          	auipc	a0,0x3
ffffffffc02023e2:	e8250513          	addi	a0,a0,-382 # ffffffffc0205260 <default_pmm_manager+0xb8>
ffffffffc02023e6:	f8ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc02023ea:	00003697          	auipc	a3,0x3
ffffffffc02023ee:	11668693          	addi	a3,a3,278 # ffffffffc0205500 <default_pmm_manager+0x358>
ffffffffc02023f2:	00003617          	auipc	a2,0x3
ffffffffc02023f6:	a0660613          	addi	a2,a2,-1530 # ffffffffc0204df8 <commands+0x738>
ffffffffc02023fa:	1b700593          	li	a1,439
ffffffffc02023fe:	00003517          	auipc	a0,0x3
ffffffffc0202402:	e6250513          	addi	a0,a0,-414 # ffffffffc0205260 <default_pmm_manager+0xb8>
ffffffffc0202406:	f6ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(*ptep & PTE_W);
ffffffffc020240a:	00003697          	auipc	a3,0x3
ffffffffc020240e:	0e668693          	addi	a3,a3,230 # ffffffffc02054f0 <default_pmm_manager+0x348>
ffffffffc0202412:	00003617          	auipc	a2,0x3
ffffffffc0202416:	9e660613          	addi	a2,a2,-1562 # ffffffffc0204df8 <commands+0x738>
ffffffffc020241a:	1b500593          	li	a1,437
ffffffffc020241e:	00003517          	auipc	a0,0x3
ffffffffc0202422:	e4250513          	addi	a0,a0,-446 # ffffffffc0205260 <default_pmm_manager+0xb8>
ffffffffc0202426:	f4ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc020242a:	00003697          	auipc	a3,0x3
ffffffffc020242e:	1be68693          	addi	a3,a3,446 # ffffffffc02055e8 <default_pmm_manager+0x440>
ffffffffc0202432:	00003617          	auipc	a2,0x3
ffffffffc0202436:	9c660613          	addi	a2,a2,-1594 # ffffffffc0204df8 <commands+0x738>
ffffffffc020243a:	20b00593          	li	a1,523
ffffffffc020243e:	00003517          	auipc	a0,0x3
ffffffffc0202442:	e2250513          	addi	a0,a0,-478 # ffffffffc0205260 <default_pmm_manager+0xb8>
ffffffffc0202446:	f2ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(*ptep & PTE_U);
ffffffffc020244a:	00003697          	auipc	a3,0x3
ffffffffc020244e:	09668693          	addi	a3,a3,150 # ffffffffc02054e0 <default_pmm_manager+0x338>
ffffffffc0202452:	00003617          	auipc	a2,0x3
ffffffffc0202456:	9a660613          	addi	a2,a2,-1626 # ffffffffc0204df8 <commands+0x738>
ffffffffc020245a:	1b400593          	li	a1,436
ffffffffc020245e:	00003517          	auipc	a0,0x3
ffffffffc0202462:	e0250513          	addi	a0,a0,-510 # ffffffffc0205260 <default_pmm_manager+0xb8>
ffffffffc0202466:	f0ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc020246a:	00003697          	auipc	a3,0x3
ffffffffc020246e:	fce68693          	addi	a3,a3,-50 # ffffffffc0205438 <default_pmm_manager+0x290>
ffffffffc0202472:	00003617          	auipc	a2,0x3
ffffffffc0202476:	98660613          	addi	a2,a2,-1658 # ffffffffc0204df8 <commands+0x738>
ffffffffc020247a:	1cb00593          	li	a1,459
ffffffffc020247e:	00003517          	auipc	a0,0x3
ffffffffc0202482:	de250513          	addi	a0,a0,-542 # ffffffffc0205260 <default_pmm_manager+0xb8>
ffffffffc0202486:	eeffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc020248a:	00003697          	auipc	a3,0x3
ffffffffc020248e:	10668693          	addi	a3,a3,262 # ffffffffc0205590 <default_pmm_manager+0x3e8>
ffffffffc0202492:	00003617          	auipc	a2,0x3
ffffffffc0202496:	96660613          	addi	a2,a2,-1690 # ffffffffc0204df8 <commands+0x738>
ffffffffc020249a:	1c600593          	li	a1,454
ffffffffc020249e:	00003517          	auipc	a0,0x3
ffffffffc02024a2:	dc250513          	addi	a0,a0,-574 # ffffffffc0205260 <default_pmm_manager+0xb8>
ffffffffc02024a6:	ecffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc02024aa:	00003697          	auipc	a3,0x3
ffffffffc02024ae:	f7668693          	addi	a3,a3,-138 # ffffffffc0205420 <default_pmm_manager+0x278>
ffffffffc02024b2:	00003617          	auipc	a2,0x3
ffffffffc02024b6:	94660613          	addi	a2,a2,-1722 # ffffffffc0204df8 <commands+0x738>
ffffffffc02024ba:	1c400593          	li	a1,452
ffffffffc02024be:	00003517          	auipc	a0,0x3
ffffffffc02024c2:	da250513          	addi	a0,a0,-606 # ffffffffc0205260 <default_pmm_manager+0xb8>
ffffffffc02024c6:	eaffd0ef          	jal	ra,ffffffffc0200374 <__panic>
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc02024ca:	00003617          	auipc	a2,0x3
ffffffffc02024ce:	d6e60613          	addi	a2,a2,-658 # ffffffffc0205238 <default_pmm_manager+0x90>
ffffffffc02024d2:	06a00593          	li	a1,106
ffffffffc02024d6:	00003517          	auipc	a0,0x3
ffffffffc02024da:	d2a50513          	addi	a0,a0,-726 # ffffffffc0205200 <default_pmm_manager+0x58>
ffffffffc02024de:	e97fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc02024e2:	00003697          	auipc	a3,0x3
ffffffffc02024e6:	0de68693          	addi	a3,a3,222 # ffffffffc02055c0 <default_pmm_manager+0x418>
ffffffffc02024ea:	00003617          	auipc	a2,0x3
ffffffffc02024ee:	90e60613          	addi	a2,a2,-1778 # ffffffffc0204df8 <commands+0x738>
ffffffffc02024f2:	1d700593          	li	a1,471
ffffffffc02024f6:	00003517          	auipc	a0,0x3
ffffffffc02024fa:	d6a50513          	addi	a0,a0,-662 # ffffffffc0205260 <default_pmm_manager+0xb8>
ffffffffc02024fe:	e77fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0202502:	00003697          	auipc	a3,0x3
ffffffffc0202506:	07668693          	addi	a3,a3,118 # ffffffffc0205578 <default_pmm_manager+0x3d0>
ffffffffc020250a:	00003617          	auipc	a2,0x3
ffffffffc020250e:	8ee60613          	addi	a2,a2,-1810 # ffffffffc0204df8 <commands+0x738>
ffffffffc0202512:	1d400593          	li	a1,468
ffffffffc0202516:	00003517          	auipc	a0,0x3
ffffffffc020251a:	d4a50513          	addi	a0,a0,-694 # ffffffffc0205260 <default_pmm_manager+0xb8>
ffffffffc020251e:	e57fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p1) == 0);
ffffffffc0202522:	00003697          	auipc	a3,0x3
ffffffffc0202526:	08668693          	addi	a3,a3,134 # ffffffffc02055a8 <default_pmm_manager+0x400>
ffffffffc020252a:	00003617          	auipc	a2,0x3
ffffffffc020252e:	8ce60613          	addi	a2,a2,-1842 # ffffffffc0204df8 <commands+0x738>
ffffffffc0202532:	1d200593          	li	a1,466
ffffffffc0202536:	00003517          	auipc	a0,0x3
ffffffffc020253a:	d2a50513          	addi	a0,a0,-726 # ffffffffc0205260 <default_pmm_manager+0xb8>
ffffffffc020253e:	e37fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0202542:	00003697          	auipc	a3,0x3
ffffffffc0202546:	03668693          	addi	a3,a3,54 # ffffffffc0205578 <default_pmm_manager+0x3d0>
ffffffffc020254a:	00003617          	auipc	a2,0x3
ffffffffc020254e:	8ae60613          	addi	a2,a2,-1874 # ffffffffc0204df8 <commands+0x738>
ffffffffc0202552:	1cd00593          	li	a1,461
ffffffffc0202556:	00003517          	auipc	a0,0x3
ffffffffc020255a:	d0a50513          	addi	a0,a0,-758 # ffffffffc0205260 <default_pmm_manager+0xb8>
ffffffffc020255e:	e17fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p) == 1);
ffffffffc0202562:	00003697          	auipc	a3,0x3
ffffffffc0202566:	16e68693          	addi	a3,a3,366 # ffffffffc02056d0 <default_pmm_manager+0x528>
ffffffffc020256a:	00003617          	auipc	a2,0x3
ffffffffc020256e:	88e60613          	addi	a2,a2,-1906 # ffffffffc0204df8 <commands+0x738>
ffffffffc0202572:	1fa00593          	li	a1,506
ffffffffc0202576:	00003517          	auipc	a0,0x3
ffffffffc020257a:	cea50513          	addi	a0,a0,-790 # ffffffffc0205260 <default_pmm_manager+0xb8>
ffffffffc020257e:	df7fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0202582:	00003697          	auipc	a3,0x3
ffffffffc0202586:	11668693          	addi	a3,a3,278 # ffffffffc0205698 <default_pmm_manager+0x4f0>
ffffffffc020258a:	00003617          	auipc	a2,0x3
ffffffffc020258e:	86e60613          	addi	a2,a2,-1938 # ffffffffc0204df8 <commands+0x738>
ffffffffc0202592:	1f900593          	li	a1,505
ffffffffc0202596:	00003517          	auipc	a0,0x3
ffffffffc020259a:	cca50513          	addi	a0,a0,-822 # ffffffffc0205260 <default_pmm_manager+0xb8>
ffffffffc020259e:	dd7fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(boot_pgdir[0] == 0);
ffffffffc02025a2:	00003697          	auipc	a3,0x3
ffffffffc02025a6:	0de68693          	addi	a3,a3,222 # ffffffffc0205680 <default_pmm_manager+0x4d8>
ffffffffc02025aa:	00003617          	auipc	a2,0x3
ffffffffc02025ae:	84e60613          	addi	a2,a2,-1970 # ffffffffc0204df8 <commands+0x738>
ffffffffc02025b2:	1f500593          	li	a1,501
ffffffffc02025b6:	00003517          	auipc	a0,0x3
ffffffffc02025ba:	caa50513          	addi	a0,a0,-854 # ffffffffc0205260 <default_pmm_manager+0xb8>
ffffffffc02025be:	db7fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc02025c2:	00003697          	auipc	a3,0x3
ffffffffc02025c6:	02668693          	addi	a3,a3,38 # ffffffffc02055e8 <default_pmm_manager+0x440>
ffffffffc02025ca:	00003617          	auipc	a2,0x3
ffffffffc02025ce:	82e60613          	addi	a2,a2,-2002 # ffffffffc0204df8 <commands+0x738>
ffffffffc02025d2:	1e200593          	li	a1,482
ffffffffc02025d6:	00003517          	auipc	a0,0x3
ffffffffc02025da:	c8a50513          	addi	a0,a0,-886 # ffffffffc0205260 <default_pmm_manager+0xb8>
ffffffffc02025de:	d97fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc02025e2:	00003697          	auipc	a3,0x3
ffffffffc02025e6:	e3e68693          	addi	a3,a3,-450 # ffffffffc0205420 <default_pmm_manager+0x278>
ffffffffc02025ea:	00003617          	auipc	a2,0x3
ffffffffc02025ee:	80e60613          	addi	a2,a2,-2034 # ffffffffc0204df8 <commands+0x738>
ffffffffc02025f2:	1a200593          	li	a1,418
ffffffffc02025f6:	00003517          	auipc	a0,0x3
ffffffffc02025fa:	c6a50513          	addi	a0,a0,-918 # ffffffffc0205260 <default_pmm_manager+0xb8>
ffffffffc02025fe:	d77fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc0202602:	00003617          	auipc	a2,0x3
ffffffffc0202606:	c3660613          	addi	a2,a2,-970 # ffffffffc0205238 <default_pmm_manager+0x90>
ffffffffc020260a:	1a700593          	li	a1,423
ffffffffc020260e:	00003517          	auipc	a0,0x3
ffffffffc0202612:	c5250513          	addi	a0,a0,-942 # ffffffffc0205260 <default_pmm_manager+0xb8>
ffffffffc0202616:	d5ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc020261a:	00003697          	auipc	a3,0x3
ffffffffc020261e:	e1e68693          	addi	a3,a3,-482 # ffffffffc0205438 <default_pmm_manager+0x290>
ffffffffc0202622:	00002617          	auipc	a2,0x2
ffffffffc0202626:	7d660613          	addi	a2,a2,2006 # ffffffffc0204df8 <commands+0x738>
ffffffffc020262a:	1a400593          	li	a1,420
ffffffffc020262e:	00003517          	auipc	a0,0x3
ffffffffc0202632:	c3250513          	addi	a0,a0,-974 # ffffffffc0205260 <default_pmm_manager+0xb8>
ffffffffc0202636:	d3ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0))!= NULL);
ffffffffc020263a:	00003697          	auipc	a3,0x3
ffffffffc020263e:	e7668693          	addi	a3,a3,-394 # ffffffffc02054b0 <default_pmm_manager+0x308>
ffffffffc0202642:	00002617          	auipc	a2,0x2
ffffffffc0202646:	7b660613          	addi	a2,a2,1974 # ffffffffc0204df8 <commands+0x738>
ffffffffc020264a:	1b200593          	li	a1,434
ffffffffc020264e:	00003517          	auipc	a0,0x3
ffffffffc0202652:	c1250513          	addi	a0,a0,-1006 # ffffffffc0205260 <default_pmm_manager+0xb8>
ffffffffc0202656:	d1ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(strlen((const char *)0x100) == 0);
ffffffffc020265a:	00003697          	auipc	a3,0x3
ffffffffc020265e:	13668693          	addi	a3,a3,310 # ffffffffc0205790 <default_pmm_manager+0x5e8>
ffffffffc0202662:	00002617          	auipc	a2,0x2
ffffffffc0202666:	79660613          	addi	a2,a2,1942 # ffffffffc0204df8 <commands+0x738>
ffffffffc020266a:	20300593          	li	a1,515
ffffffffc020266e:	00003517          	auipc	a0,0x3
ffffffffc0202672:	bf250513          	addi	a0,a0,-1038 # ffffffffc0205260 <default_pmm_manager+0xb8>
ffffffffc0202676:	cfffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc020267a:	00003697          	auipc	a3,0x3
ffffffffc020267e:	0de68693          	addi	a3,a3,222 # ffffffffc0205758 <default_pmm_manager+0x5b0>
ffffffffc0202682:	00002617          	auipc	a2,0x2
ffffffffc0202686:	77660613          	addi	a2,a2,1910 # ffffffffc0204df8 <commands+0x738>
ffffffffc020268a:	20000593          	li	a1,512
ffffffffc020268e:	00003517          	auipc	a0,0x3
ffffffffc0202692:	bd250513          	addi	a0,a0,-1070 # ffffffffc0205260 <default_pmm_manager+0xb8>
ffffffffc0202696:	cdffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p) == 2);
ffffffffc020269a:	00003697          	auipc	a3,0x3
ffffffffc020269e:	08e68693          	addi	a3,a3,142 # ffffffffc0205728 <default_pmm_manager+0x580>
ffffffffc02026a2:	00002617          	auipc	a2,0x2
ffffffffc02026a6:	75660613          	addi	a2,a2,1878 # ffffffffc0204df8 <commands+0x738>
ffffffffc02026aa:	1fc00593          	li	a1,508
ffffffffc02026ae:	00003517          	auipc	a0,0x3
ffffffffc02026b2:	bb250513          	addi	a0,a0,-1102 # ffffffffc0205260 <default_pmm_manager+0xb8>
ffffffffc02026b6:	cbffd0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc02026ba <tlb_invalidate>:
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc02026ba:	12000073          	sfence.vma
void tlb_invalidate(pde_t *pgdir, uintptr_t la) { flush_tlb(); }
ffffffffc02026be:	8082                	ret

ffffffffc02026c0 <pgdir_alloc_page>:
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc02026c0:	7179                	addi	sp,sp,-48
ffffffffc02026c2:	e84a                	sd	s2,16(sp)
ffffffffc02026c4:	892a                	mv	s2,a0
    struct Page *page = alloc_page();
ffffffffc02026c6:	4505                	li	a0,1
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc02026c8:	f022                	sd	s0,32(sp)
ffffffffc02026ca:	ec26                	sd	s1,24(sp)
ffffffffc02026cc:	e44e                	sd	s3,8(sp)
ffffffffc02026ce:	f406                	sd	ra,40(sp)
ffffffffc02026d0:	84ae                	mv	s1,a1
ffffffffc02026d2:	89b2                	mv	s3,a2
    struct Page *page = alloc_page();
ffffffffc02026d4:	eedfe0ef          	jal	ra,ffffffffc02015c0 <alloc_pages>
ffffffffc02026d8:	842a                	mv	s0,a0
    if (page != NULL) {
ffffffffc02026da:	cd09                	beqz	a0,ffffffffc02026f4 <pgdir_alloc_page+0x34>
        if (page_insert(pgdir, page, la, perm) != 0) {
ffffffffc02026dc:	85aa                	mv	a1,a0
ffffffffc02026de:	86ce                	mv	a3,s3
ffffffffc02026e0:	8626                	mv	a2,s1
ffffffffc02026e2:	854a                	mv	a0,s2
ffffffffc02026e4:	ad2ff0ef          	jal	ra,ffffffffc02019b6 <page_insert>
ffffffffc02026e8:	ed21                	bnez	a0,ffffffffc0202740 <pgdir_alloc_page+0x80>
        if (swap_init_ok) {
ffffffffc02026ea:	0000f797          	auipc	a5,0xf
ffffffffc02026ee:	e667a783          	lw	a5,-410(a5) # ffffffffc0211550 <swap_init_ok>
ffffffffc02026f2:	eb89                	bnez	a5,ffffffffc0202704 <pgdir_alloc_page+0x44>
}
ffffffffc02026f4:	70a2                	ld	ra,40(sp)
ffffffffc02026f6:	8522                	mv	a0,s0
ffffffffc02026f8:	7402                	ld	s0,32(sp)
ffffffffc02026fa:	64e2                	ld	s1,24(sp)
ffffffffc02026fc:	6942                	ld	s2,16(sp)
ffffffffc02026fe:	69a2                	ld	s3,8(sp)
ffffffffc0202700:	6145                	addi	sp,sp,48
ffffffffc0202702:	8082                	ret
            swap_map_swappable(check_mm_struct, la, page, 0);
ffffffffc0202704:	4681                	li	a3,0
ffffffffc0202706:	8622                	mv	a2,s0
ffffffffc0202708:	85a6                	mv	a1,s1
ffffffffc020270a:	0000f517          	auipc	a0,0xf
ffffffffc020270e:	e4e53503          	ld	a0,-434(a0) # ffffffffc0211558 <check_mm_struct>
ffffffffc0202712:	07f000ef          	jal	ra,ffffffffc0202f90 <swap_map_swappable>
            assert(page_ref(page) == 1);
ffffffffc0202716:	4018                	lw	a4,0(s0)
            page->pra_vaddr = la;
ffffffffc0202718:	e024                	sd	s1,64(s0)
            assert(page_ref(page) == 1);
ffffffffc020271a:	4785                	li	a5,1
ffffffffc020271c:	fcf70ce3          	beq	a4,a5,ffffffffc02026f4 <pgdir_alloc_page+0x34>
ffffffffc0202720:	00003697          	auipc	a3,0x3
ffffffffc0202724:	0b868693          	addi	a3,a3,184 # ffffffffc02057d8 <default_pmm_manager+0x630>
ffffffffc0202728:	00002617          	auipc	a2,0x2
ffffffffc020272c:	6d060613          	addi	a2,a2,1744 # ffffffffc0204df8 <commands+0x738>
ffffffffc0202730:	17a00593          	li	a1,378
ffffffffc0202734:	00003517          	auipc	a0,0x3
ffffffffc0202738:	b2c50513          	addi	a0,a0,-1236 # ffffffffc0205260 <default_pmm_manager+0xb8>
ffffffffc020273c:	c39fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202740:	100027f3          	csrr	a5,sstatus
ffffffffc0202744:	8b89                	andi	a5,a5,2
ffffffffc0202746:	eb99                	bnez	a5,ffffffffc020275c <pgdir_alloc_page+0x9c>
    { pmm_manager->free_pages(base, n); }
ffffffffc0202748:	0000f797          	auipc	a5,0xf
ffffffffc020274c:	de87b783          	ld	a5,-536(a5) # ffffffffc0211530 <pmm_manager>
ffffffffc0202750:	739c                	ld	a5,32(a5)
ffffffffc0202752:	8522                	mv	a0,s0
ffffffffc0202754:	4585                	li	a1,1
ffffffffc0202756:	9782                	jalr	a5
            return NULL;
ffffffffc0202758:	4401                	li	s0,0
ffffffffc020275a:	bf69                	j	ffffffffc02026f4 <pgdir_alloc_page+0x34>
        intr_disable();
ffffffffc020275c:	d93fd0ef          	jal	ra,ffffffffc02004ee <intr_disable>
    { pmm_manager->free_pages(base, n); }
ffffffffc0202760:	0000f797          	auipc	a5,0xf
ffffffffc0202764:	dd07b783          	ld	a5,-560(a5) # ffffffffc0211530 <pmm_manager>
ffffffffc0202768:	739c                	ld	a5,32(a5)
ffffffffc020276a:	8522                	mv	a0,s0
ffffffffc020276c:	4585                	li	a1,1
ffffffffc020276e:	9782                	jalr	a5
            return NULL;
ffffffffc0202770:	4401                	li	s0,0
        intr_enable();
ffffffffc0202772:	d77fd0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc0202776:	bfbd                	j	ffffffffc02026f4 <pgdir_alloc_page+0x34>

ffffffffc0202778 <kmalloc>:
}

void *kmalloc(size_t n) {
ffffffffc0202778:	1141                	addi	sp,sp,-16
    void *ptr = NULL;
    struct Page *base = NULL;
    assert(n > 0 && n < 1024 * 0124);
ffffffffc020277a:	67d5                	lui	a5,0x15
void *kmalloc(size_t n) {
ffffffffc020277c:	e406                	sd	ra,8(sp)
    assert(n > 0 && n < 1024 * 0124);
ffffffffc020277e:	fff50713          	addi	a4,a0,-1
ffffffffc0202782:	17f9                	addi	a5,a5,-2
ffffffffc0202784:	04e7ea63          	bltu	a5,a4,ffffffffc02027d8 <kmalloc+0x60>
    int num_pages = (n + PGSIZE - 1) / PGSIZE;
ffffffffc0202788:	6785                	lui	a5,0x1
ffffffffc020278a:	17fd                	addi	a5,a5,-1
ffffffffc020278c:	953e                	add	a0,a0,a5
    base = alloc_pages(num_pages);
ffffffffc020278e:	8131                	srli	a0,a0,0xc
ffffffffc0202790:	e31fe0ef          	jal	ra,ffffffffc02015c0 <alloc_pages>
    assert(base != NULL);
ffffffffc0202794:	cd3d                	beqz	a0,ffffffffc0202812 <kmalloc+0x9a>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202796:	0000f797          	auipc	a5,0xf
ffffffffc020279a:	d927b783          	ld	a5,-622(a5) # ffffffffc0211528 <pages>
ffffffffc020279e:	8d1d                	sub	a0,a0,a5
ffffffffc02027a0:	00004697          	auipc	a3,0x4
ffffffffc02027a4:	c106b683          	ld	a3,-1008(a3) # ffffffffc02063b0 <error_string+0x38>
ffffffffc02027a8:	850d                	srai	a0,a0,0x3
ffffffffc02027aa:	02d50533          	mul	a0,a0,a3
ffffffffc02027ae:	000806b7          	lui	a3,0x80
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc02027b2:	0000f717          	auipc	a4,0xf
ffffffffc02027b6:	d6e73703          	ld	a4,-658(a4) # ffffffffc0211520 <npage>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02027ba:	9536                	add	a0,a0,a3
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc02027bc:	00c51793          	slli	a5,a0,0xc
ffffffffc02027c0:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc02027c2:	0532                	slli	a0,a0,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc02027c4:	02e7fa63          	bgeu	a5,a4,ffffffffc02027f8 <kmalloc+0x80>
    ptr = page2kva(base);
    return ptr;
}
ffffffffc02027c8:	60a2                	ld	ra,8(sp)
ffffffffc02027ca:	0000f797          	auipc	a5,0xf
ffffffffc02027ce:	d6e7b783          	ld	a5,-658(a5) # ffffffffc0211538 <va_pa_offset>
ffffffffc02027d2:	953e                	add	a0,a0,a5
ffffffffc02027d4:	0141                	addi	sp,sp,16
ffffffffc02027d6:	8082                	ret
    assert(n > 0 && n < 1024 * 0124);
ffffffffc02027d8:	00003697          	auipc	a3,0x3
ffffffffc02027dc:	01868693          	addi	a3,a3,24 # ffffffffc02057f0 <default_pmm_manager+0x648>
ffffffffc02027e0:	00002617          	auipc	a2,0x2
ffffffffc02027e4:	61860613          	addi	a2,a2,1560 # ffffffffc0204df8 <commands+0x738>
ffffffffc02027e8:	21300593          	li	a1,531
ffffffffc02027ec:	00003517          	auipc	a0,0x3
ffffffffc02027f0:	a7450513          	addi	a0,a0,-1420 # ffffffffc0205260 <default_pmm_manager+0xb8>
ffffffffc02027f4:	b81fd0ef          	jal	ra,ffffffffc0200374 <__panic>
ffffffffc02027f8:	86aa                	mv	a3,a0
ffffffffc02027fa:	00003617          	auipc	a2,0x3
ffffffffc02027fe:	a3e60613          	addi	a2,a2,-1474 # ffffffffc0205238 <default_pmm_manager+0x90>
ffffffffc0202802:	06a00593          	li	a1,106
ffffffffc0202806:	00003517          	auipc	a0,0x3
ffffffffc020280a:	9fa50513          	addi	a0,a0,-1542 # ffffffffc0205200 <default_pmm_manager+0x58>
ffffffffc020280e:	b67fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(base != NULL);
ffffffffc0202812:	00003697          	auipc	a3,0x3
ffffffffc0202816:	ffe68693          	addi	a3,a3,-2 # ffffffffc0205810 <default_pmm_manager+0x668>
ffffffffc020281a:	00002617          	auipc	a2,0x2
ffffffffc020281e:	5de60613          	addi	a2,a2,1502 # ffffffffc0204df8 <commands+0x738>
ffffffffc0202822:	21600593          	li	a1,534
ffffffffc0202826:	00003517          	auipc	a0,0x3
ffffffffc020282a:	a3a50513          	addi	a0,a0,-1478 # ffffffffc0205260 <default_pmm_manager+0xb8>
ffffffffc020282e:	b47fd0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0202832 <kfree>:

void kfree(void *ptr, size_t n) {
ffffffffc0202832:	1101                	addi	sp,sp,-32
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0202834:	67d5                	lui	a5,0x15
void kfree(void *ptr, size_t n) {
ffffffffc0202836:	ec06                	sd	ra,24(sp)
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0202838:	fff58713          	addi	a4,a1,-1
ffffffffc020283c:	17f9                	addi	a5,a5,-2
ffffffffc020283e:	0ae7ee63          	bltu	a5,a4,ffffffffc02028fa <kfree+0xc8>
    assert(ptr != NULL);
ffffffffc0202842:	cd41                	beqz	a0,ffffffffc02028da <kfree+0xa8>
    struct Page *base = NULL;
    int num_pages = (n + PGSIZE - 1) / PGSIZE;
ffffffffc0202844:	6785                	lui	a5,0x1
ffffffffc0202846:	17fd                	addi	a5,a5,-1
ffffffffc0202848:	95be                	add	a1,a1,a5
static inline struct Page *kva2page(void *kva) { return pa2page(PADDR(kva)); }
ffffffffc020284a:	c02007b7          	lui	a5,0xc0200
ffffffffc020284e:	81b1                	srli	a1,a1,0xc
ffffffffc0202850:	06f56863          	bltu	a0,a5,ffffffffc02028c0 <kfree+0x8e>
ffffffffc0202854:	0000f697          	auipc	a3,0xf
ffffffffc0202858:	ce46b683          	ld	a3,-796(a3) # ffffffffc0211538 <va_pa_offset>
ffffffffc020285c:	8d15                	sub	a0,a0,a3
    if (PPN(pa) >= npage) {
ffffffffc020285e:	8131                	srli	a0,a0,0xc
ffffffffc0202860:	0000f797          	auipc	a5,0xf
ffffffffc0202864:	cc07b783          	ld	a5,-832(a5) # ffffffffc0211520 <npage>
ffffffffc0202868:	04f57a63          	bgeu	a0,a5,ffffffffc02028bc <kfree+0x8a>
    return &pages[PPN(pa) - nbase];
ffffffffc020286c:	fff806b7          	lui	a3,0xfff80
ffffffffc0202870:	9536                	add	a0,a0,a3
ffffffffc0202872:	00351793          	slli	a5,a0,0x3
ffffffffc0202876:	953e                	add	a0,a0,a5
ffffffffc0202878:	050e                	slli	a0,a0,0x3
ffffffffc020287a:	0000f797          	auipc	a5,0xf
ffffffffc020287e:	cae7b783          	ld	a5,-850(a5) # ffffffffc0211528 <pages>
ffffffffc0202882:	953e                	add	a0,a0,a5
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202884:	100027f3          	csrr	a5,sstatus
ffffffffc0202888:	8b89                	andi	a5,a5,2
ffffffffc020288a:	eb89                	bnez	a5,ffffffffc020289c <kfree+0x6a>
    { pmm_manager->free_pages(base, n); }
ffffffffc020288c:	0000f797          	auipc	a5,0xf
ffffffffc0202890:	ca47b783          	ld	a5,-860(a5) # ffffffffc0211530 <pmm_manager>
    base = kva2page(ptr);
    free_pages(base, num_pages);
}
ffffffffc0202894:	60e2                	ld	ra,24(sp)
    { pmm_manager->free_pages(base, n); }
ffffffffc0202896:	739c                	ld	a5,32(a5)
}
ffffffffc0202898:	6105                	addi	sp,sp,32
    { pmm_manager->free_pages(base, n); }
ffffffffc020289a:	8782                	jr	a5
        intr_disable();
ffffffffc020289c:	e42a                	sd	a0,8(sp)
ffffffffc020289e:	e02e                	sd	a1,0(sp)
ffffffffc02028a0:	c4ffd0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc02028a4:	0000f797          	auipc	a5,0xf
ffffffffc02028a8:	c8c7b783          	ld	a5,-884(a5) # ffffffffc0211530 <pmm_manager>
ffffffffc02028ac:	6582                	ld	a1,0(sp)
ffffffffc02028ae:	6522                	ld	a0,8(sp)
ffffffffc02028b0:	739c                	ld	a5,32(a5)
ffffffffc02028b2:	9782                	jalr	a5
}
ffffffffc02028b4:	60e2                	ld	ra,24(sp)
ffffffffc02028b6:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc02028b8:	c31fd06f          	j	ffffffffc02004e8 <intr_enable>
ffffffffc02028bc:	ccdfe0ef          	jal	ra,ffffffffc0201588 <pa2page.part.0>
static inline struct Page *kva2page(void *kva) { return pa2page(PADDR(kva)); }
ffffffffc02028c0:	86aa                	mv	a3,a0
ffffffffc02028c2:	00003617          	auipc	a2,0x3
ffffffffc02028c6:	a3660613          	addi	a2,a2,-1482 # ffffffffc02052f8 <default_pmm_manager+0x150>
ffffffffc02028ca:	06c00593          	li	a1,108
ffffffffc02028ce:	00003517          	auipc	a0,0x3
ffffffffc02028d2:	93250513          	addi	a0,a0,-1742 # ffffffffc0205200 <default_pmm_manager+0x58>
ffffffffc02028d6:	a9ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(ptr != NULL);
ffffffffc02028da:	00003697          	auipc	a3,0x3
ffffffffc02028de:	f4668693          	addi	a3,a3,-186 # ffffffffc0205820 <default_pmm_manager+0x678>
ffffffffc02028e2:	00002617          	auipc	a2,0x2
ffffffffc02028e6:	51660613          	addi	a2,a2,1302 # ffffffffc0204df8 <commands+0x738>
ffffffffc02028ea:	21d00593          	li	a1,541
ffffffffc02028ee:	00003517          	auipc	a0,0x3
ffffffffc02028f2:	97250513          	addi	a0,a0,-1678 # ffffffffc0205260 <default_pmm_manager+0xb8>
ffffffffc02028f6:	a7ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(n > 0 && n < 1024 * 0124);
ffffffffc02028fa:	00003697          	auipc	a3,0x3
ffffffffc02028fe:	ef668693          	addi	a3,a3,-266 # ffffffffc02057f0 <default_pmm_manager+0x648>
ffffffffc0202902:	00002617          	auipc	a2,0x2
ffffffffc0202906:	4f660613          	addi	a2,a2,1270 # ffffffffc0204df8 <commands+0x738>
ffffffffc020290a:	21c00593          	li	a1,540
ffffffffc020290e:	00003517          	auipc	a0,0x3
ffffffffc0202912:	95250513          	addi	a0,a0,-1710 # ffffffffc0205260 <default_pmm_manager+0xb8>
ffffffffc0202916:	a5ffd0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc020291a <swap_init>:
unsigned int swap_in_seq_no[MAX_SEQ_NO], swap_out_seq_no[MAX_SEQ_NO];

static void check_swap(void);

int swap_init(void)
{
ffffffffc020291a:	7135                	addi	sp,sp,-160
ffffffffc020291c:	ed06                	sd	ra,152(sp)
ffffffffc020291e:	e922                	sd	s0,144(sp)
ffffffffc0202920:	e526                	sd	s1,136(sp)
ffffffffc0202922:	e14a                	sd	s2,128(sp)
ffffffffc0202924:	fcce                	sd	s3,120(sp)
ffffffffc0202926:	f8d2                	sd	s4,112(sp)
ffffffffc0202928:	f4d6                	sd	s5,104(sp)
ffffffffc020292a:	f0da                	sd	s6,96(sp)
ffffffffc020292c:	ecde                	sd	s7,88(sp)
ffffffffc020292e:	e8e2                	sd	s8,80(sp)
ffffffffc0202930:	e4e6                	sd	s9,72(sp)
ffffffffc0202932:	e0ea                	sd	s10,64(sp)
ffffffffc0202934:	fc6e                	sd	s11,56(sp)
     swapfs_init();
ffffffffc0202936:	478010ef          	jal	ra,ffffffffc0203dae <swapfs_init>

     // Since the IDE is faked, it can only store 7 pages at most to pass the test
     if (!(7 <= max_swap_offset &&
ffffffffc020293a:	0000f697          	auipc	a3,0xf
ffffffffc020293e:	c066b683          	ld	a3,-1018(a3) # ffffffffc0211540 <max_swap_offset>
ffffffffc0202942:	010007b7          	lui	a5,0x1000
ffffffffc0202946:	ff968713          	addi	a4,a3,-7
ffffffffc020294a:	17e1                	addi	a5,a5,-8
ffffffffc020294c:	3ee7e063          	bltu	a5,a4,ffffffffc0202d2c <swap_init+0x412>
           max_swap_offset < MAX_SWAP_OFFSET_LIMIT))
     {
          panic("bad max_swap_offset %08x.\n", max_swap_offset);
     }
     sm = &swap_manager_fifo;
ffffffffc0202950:	00007797          	auipc	a5,0x7
ffffffffc0202954:	6b078793          	addi	a5,a5,1712 # ffffffffc020a000 <swap_manager_fifo>
     //  sm = &swap_manager_clock;//use first in first out Page Replacement Algorithm
     int r = sm->init();
ffffffffc0202958:	6798                	ld	a4,8(a5)
     sm = &swap_manager_fifo;
ffffffffc020295a:	0000fb17          	auipc	s6,0xf
ffffffffc020295e:	beeb0b13          	addi	s6,s6,-1042 # ffffffffc0211548 <sm>
ffffffffc0202962:	00fb3023          	sd	a5,0(s6)
     int r = sm->init();
ffffffffc0202966:	9702                	jalr	a4
ffffffffc0202968:	89aa                	mv	s3,a0

     if (r == 0)
ffffffffc020296a:	c10d                	beqz	a0,ffffffffc020298c <swap_init+0x72>
          cprintf("SWAP: manager = %s\n", sm->name);
          check_swap();
     }

     return r;
}
ffffffffc020296c:	60ea                	ld	ra,152(sp)
ffffffffc020296e:	644a                	ld	s0,144(sp)
ffffffffc0202970:	64aa                	ld	s1,136(sp)
ffffffffc0202972:	690a                	ld	s2,128(sp)
ffffffffc0202974:	7a46                	ld	s4,112(sp)
ffffffffc0202976:	7aa6                	ld	s5,104(sp)
ffffffffc0202978:	7b06                	ld	s6,96(sp)
ffffffffc020297a:	6be6                	ld	s7,88(sp)
ffffffffc020297c:	6c46                	ld	s8,80(sp)
ffffffffc020297e:	6ca6                	ld	s9,72(sp)
ffffffffc0202980:	6d06                	ld	s10,64(sp)
ffffffffc0202982:	7de2                	ld	s11,56(sp)
ffffffffc0202984:	854e                	mv	a0,s3
ffffffffc0202986:	79e6                	ld	s3,120(sp)
ffffffffc0202988:	610d                	addi	sp,sp,160
ffffffffc020298a:	8082                	ret
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc020298c:	000b3783          	ld	a5,0(s6)
ffffffffc0202990:	00003517          	auipc	a0,0x3
ffffffffc0202994:	ed050513          	addi	a0,a0,-304 # ffffffffc0205860 <default_pmm_manager+0x6b8>
    return listelm->next;
ffffffffc0202998:	0000e497          	auipc	s1,0xe
ffffffffc020299c:	6a848493          	addi	s1,s1,1704 # ffffffffc0211040 <free_area>
ffffffffc02029a0:	638c                	ld	a1,0(a5)
          swap_init_ok = 1;
ffffffffc02029a2:	4785                	li	a5,1
ffffffffc02029a4:	0000f717          	auipc	a4,0xf
ffffffffc02029a8:	baf72623          	sw	a5,-1108(a4) # ffffffffc0211550 <swap_init_ok>
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc02029ac:	f0efd0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc02029b0:	649c                	ld	a5,8(s1)

static void
check_swap(void)
{
     // backup mem env
     int ret, count = 0, total = 0, i;
ffffffffc02029b2:	4401                	li	s0,0
ffffffffc02029b4:	4d01                	li	s10,0
     list_entry_t *le = &free_list;
     while ((le = list_next(le)) != &free_list)
ffffffffc02029b6:	2c978163          	beq	a5,s1,ffffffffc0202c78 <swap_init+0x35e>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc02029ba:	fe87b703          	ld	a4,-24(a5)
     {
          struct Page *p = le2page(le, page_link);
          assert(PageProperty(p));
ffffffffc02029be:	8b09                	andi	a4,a4,2
ffffffffc02029c0:	2a070e63          	beqz	a4,ffffffffc0202c7c <swap_init+0x362>
          count++, total += p->property;
ffffffffc02029c4:	ff87a703          	lw	a4,-8(a5)
ffffffffc02029c8:	679c                	ld	a5,8(a5)
ffffffffc02029ca:	2d05                	addiw	s10,s10,1
ffffffffc02029cc:	9c39                	addw	s0,s0,a4
     while ((le = list_next(le)) != &free_list)
ffffffffc02029ce:	fe9796e3          	bne	a5,s1,ffffffffc02029ba <swap_init+0xa0>
     }
     assert(total == nr_free_pages());
ffffffffc02029d2:	8922                	mv	s2,s0
ffffffffc02029d4:	cbffe0ef          	jal	ra,ffffffffc0201692 <nr_free_pages>
ffffffffc02029d8:	47251663          	bne	a0,s2,ffffffffc0202e44 <swap_init+0x52a>
     cprintf("BEGIN check_swap: count %d, total %d\n", count, total);
ffffffffc02029dc:	8622                	mv	a2,s0
ffffffffc02029de:	85ea                	mv	a1,s10
ffffffffc02029e0:	00003517          	auipc	a0,0x3
ffffffffc02029e4:	e9850513          	addi	a0,a0,-360 # ffffffffc0205878 <default_pmm_manager+0x6d0>
ffffffffc02029e8:	ed2fd0ef          	jal	ra,ffffffffc02000ba <cprintf>

     // now we set the phy pages env
     struct mm_struct *mm = mm_create();
ffffffffc02029ec:	361000ef          	jal	ra,ffffffffc020354c <mm_create>
ffffffffc02029f0:	8aaa                	mv	s5,a0
     assert(mm != NULL);
ffffffffc02029f2:	52050963          	beqz	a0,ffffffffc0202f24 <swap_init+0x60a>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
ffffffffc02029f6:	0000f797          	auipc	a5,0xf
ffffffffc02029fa:	b6278793          	addi	a5,a5,-1182 # ffffffffc0211558 <check_mm_struct>
ffffffffc02029fe:	6398                	ld	a4,0(a5)
ffffffffc0202a00:	54071263          	bnez	a4,ffffffffc0202f44 <swap_init+0x62a>

     check_mm_struct = mm;

     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0202a04:	0000fb97          	auipc	s7,0xf
ffffffffc0202a08:	b14bbb83          	ld	s7,-1260(s7) # ffffffffc0211518 <boot_pgdir>
     assert(pgdir[0] == 0);
ffffffffc0202a0c:	000bb703          	ld	a4,0(s7)
     check_mm_struct = mm;
ffffffffc0202a10:	e388                	sd	a0,0(a5)
     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0202a12:	01753c23          	sd	s7,24(a0)
     assert(pgdir[0] == 0);
ffffffffc0202a16:	3c071763          	bnez	a4,ffffffffc0202de4 <swap_init+0x4ca>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
ffffffffc0202a1a:	6599                	lui	a1,0x6
ffffffffc0202a1c:	460d                	li	a2,3
ffffffffc0202a1e:	6505                	lui	a0,0x1
ffffffffc0202a20:	375000ef          	jal	ra,ffffffffc0203594 <vma_create>
ffffffffc0202a24:	85aa                	mv	a1,a0
     assert(vma != NULL);
ffffffffc0202a26:	3c050f63          	beqz	a0,ffffffffc0202e04 <swap_init+0x4ea>

     insert_vma_struct(mm, vma);
ffffffffc0202a2a:	8556                	mv	a0,s5
ffffffffc0202a2c:	3d7000ef          	jal	ra,ffffffffc0203602 <insert_vma_struct>

     // setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
ffffffffc0202a30:	00003517          	auipc	a0,0x3
ffffffffc0202a34:	eb850513          	addi	a0,a0,-328 # ffffffffc02058e8 <default_pmm_manager+0x740>
ffffffffc0202a38:	e82fd0ef          	jal	ra,ffffffffc02000ba <cprintf>
     pte_t *temp_ptep = NULL;
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
ffffffffc0202a3c:	018ab503          	ld	a0,24(s5)
ffffffffc0202a40:	4605                	li	a2,1
ffffffffc0202a42:	6585                	lui	a1,0x1
ffffffffc0202a44:	c89fe0ef          	jal	ra,ffffffffc02016cc <get_pte>
     assert(temp_ptep != NULL);
ffffffffc0202a48:	3c050e63          	beqz	a0,ffffffffc0202e24 <swap_init+0x50a>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc0202a4c:	00003517          	auipc	a0,0x3
ffffffffc0202a50:	eec50513          	addi	a0,a0,-276 # ffffffffc0205938 <default_pmm_manager+0x790>
ffffffffc0202a54:	0000e917          	auipc	s2,0xe
ffffffffc0202a58:	62490913          	addi	s2,s2,1572 # ffffffffc0211078 <check_rp>
ffffffffc0202a5c:	e5efd0ef          	jal	ra,ffffffffc02000ba <cprintf>

     for (i = 0; i < CHECK_VALID_PHY_PAGE_NUM; i++)
ffffffffc0202a60:	0000ea17          	auipc	s4,0xe
ffffffffc0202a64:	638a0a13          	addi	s4,s4,1592 # ffffffffc0211098 <swap_in_seq_no>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc0202a68:	8c4a                	mv	s8,s2
     {
          check_rp[i] = alloc_page();
ffffffffc0202a6a:	4505                	li	a0,1
ffffffffc0202a6c:	b55fe0ef          	jal	ra,ffffffffc02015c0 <alloc_pages>
ffffffffc0202a70:	00ac3023          	sd	a0,0(s8)
          assert(check_rp[i] != NULL);
ffffffffc0202a74:	28050c63          	beqz	a0,ffffffffc0202d0c <swap_init+0x3f2>
ffffffffc0202a78:	651c                	ld	a5,8(a0)
          assert(!PageProperty(check_rp[i]));
ffffffffc0202a7a:	8b89                	andi	a5,a5,2
ffffffffc0202a7c:	26079863          	bnez	a5,ffffffffc0202cec <swap_init+0x3d2>
     for (i = 0; i < CHECK_VALID_PHY_PAGE_NUM; i++)
ffffffffc0202a80:	0c21                	addi	s8,s8,8
ffffffffc0202a82:	ff4c14e3          	bne	s8,s4,ffffffffc0202a6a <swap_init+0x150>
     }
     list_entry_t free_list_store = free_list;
ffffffffc0202a86:	609c                	ld	a5,0(s1)
ffffffffc0202a88:	0084bd83          	ld	s11,8(s1)
    elm->prev = elm->next = elm;
ffffffffc0202a8c:	e084                	sd	s1,0(s1)
ffffffffc0202a8e:	f03e                	sd	a5,32(sp)
     list_init(&free_list);
     assert(list_empty(&free_list));

     // assert(alloc_page() == NULL);

     unsigned int nr_free_store = nr_free;
ffffffffc0202a90:	489c                	lw	a5,16(s1)
ffffffffc0202a92:	e484                	sd	s1,8(s1)
     nr_free = 0;
ffffffffc0202a94:	0000ec17          	auipc	s8,0xe
ffffffffc0202a98:	5e4c0c13          	addi	s8,s8,1508 # ffffffffc0211078 <check_rp>
     unsigned int nr_free_store = nr_free;
ffffffffc0202a9c:	f43e                	sd	a5,40(sp)
     nr_free = 0;
ffffffffc0202a9e:	0000e797          	auipc	a5,0xe
ffffffffc0202aa2:	5a07a923          	sw	zero,1458(a5) # ffffffffc0211050 <free_area+0x10>
     for (i = 0; i < CHECK_VALID_PHY_PAGE_NUM; i++)
     {
          free_pages(check_rp[i], 1);
ffffffffc0202aa6:	000c3503          	ld	a0,0(s8)
ffffffffc0202aaa:	4585                	li	a1,1
     for (i = 0; i < CHECK_VALID_PHY_PAGE_NUM; i++)
ffffffffc0202aac:	0c21                	addi	s8,s8,8
          free_pages(check_rp[i], 1);
ffffffffc0202aae:	ba5fe0ef          	jal	ra,ffffffffc0201652 <free_pages>
     for (i = 0; i < CHECK_VALID_PHY_PAGE_NUM; i++)
ffffffffc0202ab2:	ff4c1ae3          	bne	s8,s4,ffffffffc0202aa6 <swap_init+0x18c>
     }
     assert(nr_free == CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0202ab6:	0104ac03          	lw	s8,16(s1)
ffffffffc0202aba:	4791                	li	a5,4
ffffffffc0202abc:	4afc1463          	bne	s8,a5,ffffffffc0202f64 <swap_init+0x64a>

     cprintf("set up init env for check_swap begin!\n");
ffffffffc0202ac0:	00003517          	auipc	a0,0x3
ffffffffc0202ac4:	f0050513          	addi	a0,a0,-256 # ffffffffc02059c0 <default_pmm_manager+0x818>
ffffffffc0202ac8:	df2fd0ef          	jal	ra,ffffffffc02000ba <cprintf>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0202acc:	6605                	lui	a2,0x1
     // setup initial vir_page<->phy_page environment for page relpacement algorithm

     pgfault_num = 0;
ffffffffc0202ace:	0000f797          	auipc	a5,0xf
ffffffffc0202ad2:	a807a923          	sw	zero,-1390(a5) # ffffffffc0211560 <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0202ad6:	4529                	li	a0,10
ffffffffc0202ad8:	00a60023          	sb	a0,0(a2) # 1000 <kern_entry-0xffffffffc01ff000>
     assert(pgfault_num == 1);
ffffffffc0202adc:	0000f597          	auipc	a1,0xf
ffffffffc0202ae0:	a845a583          	lw	a1,-1404(a1) # ffffffffc0211560 <pgfault_num>
ffffffffc0202ae4:	4805                	li	a6,1
ffffffffc0202ae6:	0000f797          	auipc	a5,0xf
ffffffffc0202aea:	a7a78793          	addi	a5,a5,-1414 # ffffffffc0211560 <pgfault_num>
ffffffffc0202aee:	3f059b63          	bne	a1,a6,ffffffffc0202ee4 <swap_init+0x5ca>
     *(unsigned char *)0x1010 = 0x0a;
ffffffffc0202af2:	00a60823          	sb	a0,16(a2)
     assert(pgfault_num == 1);
ffffffffc0202af6:	4390                	lw	a2,0(a5)
ffffffffc0202af8:	2601                	sext.w	a2,a2
ffffffffc0202afa:	40b61563          	bne	a2,a1,ffffffffc0202f04 <swap_init+0x5ea>
     *(unsigned char *)0x2000 = 0x0b;
ffffffffc0202afe:	6589                	lui	a1,0x2
ffffffffc0202b00:	452d                	li	a0,11
ffffffffc0202b02:	00a58023          	sb	a0,0(a1) # 2000 <kern_entry-0xffffffffc01fe000>
     assert(pgfault_num == 2);
ffffffffc0202b06:	4390                	lw	a2,0(a5)
ffffffffc0202b08:	4809                	li	a6,2
ffffffffc0202b0a:	2601                	sext.w	a2,a2
ffffffffc0202b0c:	35061c63          	bne	a2,a6,ffffffffc0202e64 <swap_init+0x54a>
     *(unsigned char *)0x2010 = 0x0b;
ffffffffc0202b10:	00a58823          	sb	a0,16(a1)
     assert(pgfault_num == 2);
ffffffffc0202b14:	438c                	lw	a1,0(a5)
ffffffffc0202b16:	2581                	sext.w	a1,a1
ffffffffc0202b18:	36c59663          	bne	a1,a2,ffffffffc0202e84 <swap_init+0x56a>
     *(unsigned char *)0x3000 = 0x0c;
ffffffffc0202b1c:	658d                	lui	a1,0x3
ffffffffc0202b1e:	4531                	li	a0,12
ffffffffc0202b20:	00a58023          	sb	a0,0(a1) # 3000 <kern_entry-0xffffffffc01fd000>
     assert(pgfault_num == 3);
ffffffffc0202b24:	4390                	lw	a2,0(a5)
ffffffffc0202b26:	480d                	li	a6,3
ffffffffc0202b28:	2601                	sext.w	a2,a2
ffffffffc0202b2a:	37061d63          	bne	a2,a6,ffffffffc0202ea4 <swap_init+0x58a>
     *(unsigned char *)0x3010 = 0x0c;
ffffffffc0202b2e:	00a58823          	sb	a0,16(a1)
     assert(pgfault_num == 3);
ffffffffc0202b32:	438c                	lw	a1,0(a5)
ffffffffc0202b34:	2581                	sext.w	a1,a1
ffffffffc0202b36:	38c59763          	bne	a1,a2,ffffffffc0202ec4 <swap_init+0x5aa>
     *(unsigned char *)0x4000 = 0x0d;
ffffffffc0202b3a:	6591                	lui	a1,0x4
ffffffffc0202b3c:	4535                	li	a0,13
ffffffffc0202b3e:	00a58023          	sb	a0,0(a1) # 4000 <kern_entry-0xffffffffc01fc000>
     assert(pgfault_num == 4);
ffffffffc0202b42:	4390                	lw	a2,0(a5)
ffffffffc0202b44:	2601                	sext.w	a2,a2
ffffffffc0202b46:	21861f63          	bne	a2,s8,ffffffffc0202d64 <swap_init+0x44a>
     *(unsigned char *)0x4010 = 0x0d;
ffffffffc0202b4a:	00a58823          	sb	a0,16(a1)
     assert(pgfault_num == 4);
ffffffffc0202b4e:	439c                	lw	a5,0(a5)
ffffffffc0202b50:	2781                	sext.w	a5,a5
ffffffffc0202b52:	22c79963          	bne	a5,a2,ffffffffc0202d84 <swap_init+0x46a>

     check_content_set();
     assert(nr_free == 0);
ffffffffc0202b56:	489c                	lw	a5,16(s1)
ffffffffc0202b58:	24079663          	bnez	a5,ffffffffc0202da4 <swap_init+0x48a>
ffffffffc0202b5c:	0000e797          	auipc	a5,0xe
ffffffffc0202b60:	53c78793          	addi	a5,a5,1340 # ffffffffc0211098 <swap_in_seq_no>
ffffffffc0202b64:	0000e617          	auipc	a2,0xe
ffffffffc0202b68:	55c60613          	addi	a2,a2,1372 # ffffffffc02110c0 <swap_out_seq_no>
ffffffffc0202b6c:	0000e517          	auipc	a0,0xe
ffffffffc0202b70:	55450513          	addi	a0,a0,1364 # ffffffffc02110c0 <swap_out_seq_no>
     for (i = 0; i < MAX_SEQ_NO; i++)
          swap_out_seq_no[i] = swap_in_seq_no[i] = -1;
ffffffffc0202b74:	55fd                	li	a1,-1
ffffffffc0202b76:	c38c                	sw	a1,0(a5)
ffffffffc0202b78:	c20c                	sw	a1,0(a2)
     for (i = 0; i < MAX_SEQ_NO; i++)
ffffffffc0202b7a:	0791                	addi	a5,a5,4
ffffffffc0202b7c:	0611                	addi	a2,a2,4
ffffffffc0202b7e:	fef51ce3          	bne	a0,a5,ffffffffc0202b76 <swap_init+0x25c>
ffffffffc0202b82:	0000e817          	auipc	a6,0xe
ffffffffc0202b86:	4d680813          	addi	a6,a6,1238 # ffffffffc0211058 <check_ptep>
ffffffffc0202b8a:	0000e897          	auipc	a7,0xe
ffffffffc0202b8e:	4ee88893          	addi	a7,a7,1262 # ffffffffc0211078 <check_rp>
ffffffffc0202b92:	6585                	lui	a1,0x1
    return &pages[PPN(pa) - nbase];
ffffffffc0202b94:	0000fc97          	auipc	s9,0xf
ffffffffc0202b98:	994c8c93          	addi	s9,s9,-1644 # ffffffffc0211528 <pages>
ffffffffc0202b9c:	00004c17          	auipc	s8,0x4
ffffffffc0202ba0:	81cc0c13          	addi	s8,s8,-2020 # ffffffffc02063b8 <nbase>

     for (i = 0; i < CHECK_VALID_PHY_PAGE_NUM; i++)
     {
          check_ptep[i] = 0;
ffffffffc0202ba4:	00083023          	sd	zero,0(a6)
          check_ptep[i] = get_pte(pgdir, (i + 1) * 0x1000, 0);
ffffffffc0202ba8:	4601                	li	a2,0
ffffffffc0202baa:	855e                	mv	a0,s7
ffffffffc0202bac:	ec46                	sd	a7,24(sp)
ffffffffc0202bae:	e82e                	sd	a1,16(sp)
          check_ptep[i] = 0;
ffffffffc0202bb0:	e442                	sd	a6,8(sp)
          check_ptep[i] = get_pte(pgdir, (i + 1) * 0x1000, 0);
ffffffffc0202bb2:	b1bfe0ef          	jal	ra,ffffffffc02016cc <get_pte>
ffffffffc0202bb6:	6822                	ld	a6,8(sp)
          // cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
          assert(check_ptep[i] != NULL);
ffffffffc0202bb8:	65c2                	ld	a1,16(sp)
ffffffffc0202bba:	68e2                	ld	a7,24(sp)
          check_ptep[i] = get_pte(pgdir, (i + 1) * 0x1000, 0);
ffffffffc0202bbc:	00a83023          	sd	a0,0(a6)
          assert(check_ptep[i] != NULL);
ffffffffc0202bc0:	0000f317          	auipc	t1,0xf
ffffffffc0202bc4:	96030313          	addi	t1,t1,-1696 # ffffffffc0211520 <npage>
ffffffffc0202bc8:	16050e63          	beqz	a0,ffffffffc0202d44 <swap_init+0x42a>
          assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0202bcc:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0202bce:	0017f613          	andi	a2,a5,1
ffffffffc0202bd2:	0e060563          	beqz	a2,ffffffffc0202cbc <swap_init+0x3a2>
    if (PPN(pa) >= npage) {
ffffffffc0202bd6:	00033603          	ld	a2,0(t1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202bda:	078a                	slli	a5,a5,0x2
ffffffffc0202bdc:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202bde:	0ec7fb63          	bgeu	a5,a2,ffffffffc0202cd4 <swap_init+0x3ba>
    return &pages[PPN(pa) - nbase];
ffffffffc0202be2:	000c3603          	ld	a2,0(s8)
ffffffffc0202be6:	000cb503          	ld	a0,0(s9)
ffffffffc0202bea:	0008bf03          	ld	t5,0(a7)
ffffffffc0202bee:	8f91                	sub	a5,a5,a2
ffffffffc0202bf0:	00379613          	slli	a2,a5,0x3
ffffffffc0202bf4:	97b2                	add	a5,a5,a2
ffffffffc0202bf6:	078e                	slli	a5,a5,0x3
ffffffffc0202bf8:	97aa                	add	a5,a5,a0
ffffffffc0202bfa:	0aff1163          	bne	t5,a5,ffffffffc0202c9c <swap_init+0x382>
     for (i = 0; i < CHECK_VALID_PHY_PAGE_NUM; i++)
ffffffffc0202bfe:	6785                	lui	a5,0x1
ffffffffc0202c00:	95be                	add	a1,a1,a5
ffffffffc0202c02:	6795                	lui	a5,0x5
ffffffffc0202c04:	0821                	addi	a6,a6,8
ffffffffc0202c06:	08a1                	addi	a7,a7,8
ffffffffc0202c08:	f8f59ee3          	bne	a1,a5,ffffffffc0202ba4 <swap_init+0x28a>
          assert((*check_ptep[i] & PTE_V));
     }
     cprintf("set up init env for check_swap over!\n");
ffffffffc0202c0c:	00003517          	auipc	a0,0x3
ffffffffc0202c10:	e7c50513          	addi	a0,a0,-388 # ffffffffc0205a88 <default_pmm_manager+0x8e0>
ffffffffc0202c14:	ca6fd0ef          	jal	ra,ffffffffc02000ba <cprintf>
     int ret = sm->check_swap();
ffffffffc0202c18:	000b3783          	ld	a5,0(s6)
ffffffffc0202c1c:	7f9c                	ld	a5,56(a5)
ffffffffc0202c1e:	9782                	jalr	a5
     // now access the virt pages to test  page relpacement algorithm
     ret = check_content_access();
     assert(ret == 0);
ffffffffc0202c20:	1a051263          	bnez	a0,ffffffffc0202dc4 <swap_init+0x4aa>

     // restore kernel mem env
     for (i = 0; i < CHECK_VALID_PHY_PAGE_NUM; i++)
     {
          free_pages(check_rp[i], 1);
ffffffffc0202c24:	00093503          	ld	a0,0(s2)
ffffffffc0202c28:	4585                	li	a1,1
     for (i = 0; i < CHECK_VALID_PHY_PAGE_NUM; i++)
ffffffffc0202c2a:	0921                	addi	s2,s2,8
          free_pages(check_rp[i], 1);
ffffffffc0202c2c:	a27fe0ef          	jal	ra,ffffffffc0201652 <free_pages>
     for (i = 0; i < CHECK_VALID_PHY_PAGE_NUM; i++)
ffffffffc0202c30:	ff491ae3          	bne	s2,s4,ffffffffc0202c24 <swap_init+0x30a>
     }

     // free_page(pte2page(*temp_ptep));

     mm_destroy(mm);
ffffffffc0202c34:	8556                	mv	a0,s5
ffffffffc0202c36:	29d000ef          	jal	ra,ffffffffc02036d2 <mm_destroy>

     nr_free = nr_free_store;
ffffffffc0202c3a:	77a2                	ld	a5,40(sp)
     free_list = free_list_store;
ffffffffc0202c3c:	01b4b423          	sd	s11,8(s1)
     nr_free = nr_free_store;
ffffffffc0202c40:	c89c                	sw	a5,16(s1)
     free_list = free_list_store;
ffffffffc0202c42:	7782                	ld	a5,32(sp)
ffffffffc0202c44:	e09c                	sd	a5,0(s1)

     le = &free_list;
     while ((le = list_next(le)) != &free_list)
ffffffffc0202c46:	009d8a63          	beq	s11,s1,ffffffffc0202c5a <swap_init+0x340>
     {
          struct Page *p = le2page(le, page_link);
          count--, total -= p->property;
ffffffffc0202c4a:	ff8da783          	lw	a5,-8(s11)
    return listelm->next;
ffffffffc0202c4e:	008dbd83          	ld	s11,8(s11)
ffffffffc0202c52:	3d7d                	addiw	s10,s10,-1
ffffffffc0202c54:	9c1d                	subw	s0,s0,a5
     while ((le = list_next(le)) != &free_list)
ffffffffc0202c56:	fe9d9ae3          	bne	s11,s1,ffffffffc0202c4a <swap_init+0x330>
     }
     cprintf("count is %d, total is %d\n", count, total);
ffffffffc0202c5a:	8622                	mv	a2,s0
ffffffffc0202c5c:	85ea                	mv	a1,s10
ffffffffc0202c5e:	00003517          	auipc	a0,0x3
ffffffffc0202c62:	e6250513          	addi	a0,a0,-414 # ffffffffc0205ac0 <default_pmm_manager+0x918>
ffffffffc0202c66:	c54fd0ef          	jal	ra,ffffffffc02000ba <cprintf>
     // assert(count == 0);

     cprintf("check_swap() succeeded!\n");
ffffffffc0202c6a:	00003517          	auipc	a0,0x3
ffffffffc0202c6e:	e7650513          	addi	a0,a0,-394 # ffffffffc0205ae0 <default_pmm_manager+0x938>
ffffffffc0202c72:	c48fd0ef          	jal	ra,ffffffffc02000ba <cprintf>
}
ffffffffc0202c76:	b9dd                	j	ffffffffc020296c <swap_init+0x52>
     while ((le = list_next(le)) != &free_list)
ffffffffc0202c78:	4901                	li	s2,0
ffffffffc0202c7a:	bba9                	j	ffffffffc02029d4 <swap_init+0xba>
          assert(PageProperty(p));
ffffffffc0202c7c:	00002697          	auipc	a3,0x2
ffffffffc0202c80:	16c68693          	addi	a3,a3,364 # ffffffffc0204de8 <commands+0x728>
ffffffffc0202c84:	00002617          	auipc	a2,0x2
ffffffffc0202c88:	17460613          	addi	a2,a2,372 # ffffffffc0204df8 <commands+0x738>
ffffffffc0202c8c:	0b600593          	li	a1,182
ffffffffc0202c90:	00003517          	auipc	a0,0x3
ffffffffc0202c94:	bc050513          	addi	a0,a0,-1088 # ffffffffc0205850 <default_pmm_manager+0x6a8>
ffffffffc0202c98:	edcfd0ef          	jal	ra,ffffffffc0200374 <__panic>
          assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0202c9c:	00003697          	auipc	a3,0x3
ffffffffc0202ca0:	dc468693          	addi	a3,a3,-572 # ffffffffc0205a60 <default_pmm_manager+0x8b8>
ffffffffc0202ca4:	00002617          	auipc	a2,0x2
ffffffffc0202ca8:	15460613          	addi	a2,a2,340 # ffffffffc0204df8 <commands+0x738>
ffffffffc0202cac:	0f800593          	li	a1,248
ffffffffc0202cb0:	00003517          	auipc	a0,0x3
ffffffffc0202cb4:	ba050513          	addi	a0,a0,-1120 # ffffffffc0205850 <default_pmm_manager+0x6a8>
ffffffffc0202cb8:	ebcfd0ef          	jal	ra,ffffffffc0200374 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0202cbc:	00002617          	auipc	a2,0x2
ffffffffc0202cc0:	55460613          	addi	a2,a2,1364 # ffffffffc0205210 <default_pmm_manager+0x68>
ffffffffc0202cc4:	07000593          	li	a1,112
ffffffffc0202cc8:	00002517          	auipc	a0,0x2
ffffffffc0202ccc:	53850513          	addi	a0,a0,1336 # ffffffffc0205200 <default_pmm_manager+0x58>
ffffffffc0202cd0:	ea4fd0ef          	jal	ra,ffffffffc0200374 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0202cd4:	00002617          	auipc	a2,0x2
ffffffffc0202cd8:	50c60613          	addi	a2,a2,1292 # ffffffffc02051e0 <default_pmm_manager+0x38>
ffffffffc0202cdc:	06500593          	li	a1,101
ffffffffc0202ce0:	00002517          	auipc	a0,0x2
ffffffffc0202ce4:	52050513          	addi	a0,a0,1312 # ffffffffc0205200 <default_pmm_manager+0x58>
ffffffffc0202ce8:	e8cfd0ef          	jal	ra,ffffffffc0200374 <__panic>
          assert(!PageProperty(check_rp[i]));
ffffffffc0202cec:	00003697          	auipc	a3,0x3
ffffffffc0202cf0:	c8c68693          	addi	a3,a3,-884 # ffffffffc0205978 <default_pmm_manager+0x7d0>
ffffffffc0202cf4:	00002617          	auipc	a2,0x2
ffffffffc0202cf8:	10460613          	addi	a2,a2,260 # ffffffffc0204df8 <commands+0x738>
ffffffffc0202cfc:	0d800593          	li	a1,216
ffffffffc0202d00:	00003517          	auipc	a0,0x3
ffffffffc0202d04:	b5050513          	addi	a0,a0,-1200 # ffffffffc0205850 <default_pmm_manager+0x6a8>
ffffffffc0202d08:	e6cfd0ef          	jal	ra,ffffffffc0200374 <__panic>
          assert(check_rp[i] != NULL);
ffffffffc0202d0c:	00003697          	auipc	a3,0x3
ffffffffc0202d10:	c5468693          	addi	a3,a3,-940 # ffffffffc0205960 <default_pmm_manager+0x7b8>
ffffffffc0202d14:	00002617          	auipc	a2,0x2
ffffffffc0202d18:	0e460613          	addi	a2,a2,228 # ffffffffc0204df8 <commands+0x738>
ffffffffc0202d1c:	0d700593          	li	a1,215
ffffffffc0202d20:	00003517          	auipc	a0,0x3
ffffffffc0202d24:	b3050513          	addi	a0,a0,-1232 # ffffffffc0205850 <default_pmm_manager+0x6a8>
ffffffffc0202d28:	e4cfd0ef          	jal	ra,ffffffffc0200374 <__panic>
          panic("bad max_swap_offset %08x.\n", max_swap_offset);
ffffffffc0202d2c:	00003617          	auipc	a2,0x3
ffffffffc0202d30:	b0460613          	addi	a2,a2,-1276 # ffffffffc0205830 <default_pmm_manager+0x688>
ffffffffc0202d34:	02700593          	li	a1,39
ffffffffc0202d38:	00003517          	auipc	a0,0x3
ffffffffc0202d3c:	b1850513          	addi	a0,a0,-1256 # ffffffffc0205850 <default_pmm_manager+0x6a8>
ffffffffc0202d40:	e34fd0ef          	jal	ra,ffffffffc0200374 <__panic>
          assert(check_ptep[i] != NULL);
ffffffffc0202d44:	00003697          	auipc	a3,0x3
ffffffffc0202d48:	d0468693          	addi	a3,a3,-764 # ffffffffc0205a48 <default_pmm_manager+0x8a0>
ffffffffc0202d4c:	00002617          	auipc	a2,0x2
ffffffffc0202d50:	0ac60613          	addi	a2,a2,172 # ffffffffc0204df8 <commands+0x738>
ffffffffc0202d54:	0f700593          	li	a1,247
ffffffffc0202d58:	00003517          	auipc	a0,0x3
ffffffffc0202d5c:	af850513          	addi	a0,a0,-1288 # ffffffffc0205850 <default_pmm_manager+0x6a8>
ffffffffc0202d60:	e14fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgfault_num == 4);
ffffffffc0202d64:	00003697          	auipc	a3,0x3
ffffffffc0202d68:	ccc68693          	addi	a3,a3,-820 # ffffffffc0205a30 <default_pmm_manager+0x888>
ffffffffc0202d6c:	00002617          	auipc	a2,0x2
ffffffffc0202d70:	08c60613          	addi	a2,a2,140 # ffffffffc0204df8 <commands+0x738>
ffffffffc0202d74:	09800593          	li	a1,152
ffffffffc0202d78:	00003517          	auipc	a0,0x3
ffffffffc0202d7c:	ad850513          	addi	a0,a0,-1320 # ffffffffc0205850 <default_pmm_manager+0x6a8>
ffffffffc0202d80:	df4fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgfault_num == 4);
ffffffffc0202d84:	00003697          	auipc	a3,0x3
ffffffffc0202d88:	cac68693          	addi	a3,a3,-852 # ffffffffc0205a30 <default_pmm_manager+0x888>
ffffffffc0202d8c:	00002617          	auipc	a2,0x2
ffffffffc0202d90:	06c60613          	addi	a2,a2,108 # ffffffffc0204df8 <commands+0x738>
ffffffffc0202d94:	09a00593          	li	a1,154
ffffffffc0202d98:	00003517          	auipc	a0,0x3
ffffffffc0202d9c:	ab850513          	addi	a0,a0,-1352 # ffffffffc0205850 <default_pmm_manager+0x6a8>
ffffffffc0202da0:	dd4fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(nr_free == 0);
ffffffffc0202da4:	00002697          	auipc	a3,0x2
ffffffffc0202da8:	22c68693          	addi	a3,a3,556 # ffffffffc0204fd0 <commands+0x910>
ffffffffc0202dac:	00002617          	auipc	a2,0x2
ffffffffc0202db0:	04c60613          	addi	a2,a2,76 # ffffffffc0204df8 <commands+0x738>
ffffffffc0202db4:	0ee00593          	li	a1,238
ffffffffc0202db8:	00003517          	auipc	a0,0x3
ffffffffc0202dbc:	a9850513          	addi	a0,a0,-1384 # ffffffffc0205850 <default_pmm_manager+0x6a8>
ffffffffc0202dc0:	db4fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(ret == 0);
ffffffffc0202dc4:	00003697          	auipc	a3,0x3
ffffffffc0202dc8:	cec68693          	addi	a3,a3,-788 # ffffffffc0205ab0 <default_pmm_manager+0x908>
ffffffffc0202dcc:	00002617          	auipc	a2,0x2
ffffffffc0202dd0:	02c60613          	addi	a2,a2,44 # ffffffffc0204df8 <commands+0x738>
ffffffffc0202dd4:	0fe00593          	li	a1,254
ffffffffc0202dd8:	00003517          	auipc	a0,0x3
ffffffffc0202ddc:	a7850513          	addi	a0,a0,-1416 # ffffffffc0205850 <default_pmm_manager+0x6a8>
ffffffffc0202de0:	d94fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgdir[0] == 0);
ffffffffc0202de4:	00003697          	auipc	a3,0x3
ffffffffc0202de8:	ae468693          	addi	a3,a3,-1308 # ffffffffc02058c8 <default_pmm_manager+0x720>
ffffffffc0202dec:	00002617          	auipc	a2,0x2
ffffffffc0202df0:	00c60613          	addi	a2,a2,12 # ffffffffc0204df8 <commands+0x738>
ffffffffc0202df4:	0c600593          	li	a1,198
ffffffffc0202df8:	00003517          	auipc	a0,0x3
ffffffffc0202dfc:	a5850513          	addi	a0,a0,-1448 # ffffffffc0205850 <default_pmm_manager+0x6a8>
ffffffffc0202e00:	d74fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(vma != NULL);
ffffffffc0202e04:	00003697          	auipc	a3,0x3
ffffffffc0202e08:	ad468693          	addi	a3,a3,-1324 # ffffffffc02058d8 <default_pmm_manager+0x730>
ffffffffc0202e0c:	00002617          	auipc	a2,0x2
ffffffffc0202e10:	fec60613          	addi	a2,a2,-20 # ffffffffc0204df8 <commands+0x738>
ffffffffc0202e14:	0c900593          	li	a1,201
ffffffffc0202e18:	00003517          	auipc	a0,0x3
ffffffffc0202e1c:	a3850513          	addi	a0,a0,-1480 # ffffffffc0205850 <default_pmm_manager+0x6a8>
ffffffffc0202e20:	d54fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(temp_ptep != NULL);
ffffffffc0202e24:	00003697          	auipc	a3,0x3
ffffffffc0202e28:	afc68693          	addi	a3,a3,-1284 # ffffffffc0205920 <default_pmm_manager+0x778>
ffffffffc0202e2c:	00002617          	auipc	a2,0x2
ffffffffc0202e30:	fcc60613          	addi	a2,a2,-52 # ffffffffc0204df8 <commands+0x738>
ffffffffc0202e34:	0d100593          	li	a1,209
ffffffffc0202e38:	00003517          	auipc	a0,0x3
ffffffffc0202e3c:	a1850513          	addi	a0,a0,-1512 # ffffffffc0205850 <default_pmm_manager+0x6a8>
ffffffffc0202e40:	d34fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(total == nr_free_pages());
ffffffffc0202e44:	00002697          	auipc	a3,0x2
ffffffffc0202e48:	fe468693          	addi	a3,a3,-28 # ffffffffc0204e28 <commands+0x768>
ffffffffc0202e4c:	00002617          	auipc	a2,0x2
ffffffffc0202e50:	fac60613          	addi	a2,a2,-84 # ffffffffc0204df8 <commands+0x738>
ffffffffc0202e54:	0b900593          	li	a1,185
ffffffffc0202e58:	00003517          	auipc	a0,0x3
ffffffffc0202e5c:	9f850513          	addi	a0,a0,-1544 # ffffffffc0205850 <default_pmm_manager+0x6a8>
ffffffffc0202e60:	d14fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgfault_num == 2);
ffffffffc0202e64:	00003697          	auipc	a3,0x3
ffffffffc0202e68:	b9c68693          	addi	a3,a3,-1124 # ffffffffc0205a00 <default_pmm_manager+0x858>
ffffffffc0202e6c:	00002617          	auipc	a2,0x2
ffffffffc0202e70:	f8c60613          	addi	a2,a2,-116 # ffffffffc0204df8 <commands+0x738>
ffffffffc0202e74:	09000593          	li	a1,144
ffffffffc0202e78:	00003517          	auipc	a0,0x3
ffffffffc0202e7c:	9d850513          	addi	a0,a0,-1576 # ffffffffc0205850 <default_pmm_manager+0x6a8>
ffffffffc0202e80:	cf4fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgfault_num == 2);
ffffffffc0202e84:	00003697          	auipc	a3,0x3
ffffffffc0202e88:	b7c68693          	addi	a3,a3,-1156 # ffffffffc0205a00 <default_pmm_manager+0x858>
ffffffffc0202e8c:	00002617          	auipc	a2,0x2
ffffffffc0202e90:	f6c60613          	addi	a2,a2,-148 # ffffffffc0204df8 <commands+0x738>
ffffffffc0202e94:	09200593          	li	a1,146
ffffffffc0202e98:	00003517          	auipc	a0,0x3
ffffffffc0202e9c:	9b850513          	addi	a0,a0,-1608 # ffffffffc0205850 <default_pmm_manager+0x6a8>
ffffffffc0202ea0:	cd4fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgfault_num == 3);
ffffffffc0202ea4:	00003697          	auipc	a3,0x3
ffffffffc0202ea8:	b7468693          	addi	a3,a3,-1164 # ffffffffc0205a18 <default_pmm_manager+0x870>
ffffffffc0202eac:	00002617          	auipc	a2,0x2
ffffffffc0202eb0:	f4c60613          	addi	a2,a2,-180 # ffffffffc0204df8 <commands+0x738>
ffffffffc0202eb4:	09400593          	li	a1,148
ffffffffc0202eb8:	00003517          	auipc	a0,0x3
ffffffffc0202ebc:	99850513          	addi	a0,a0,-1640 # ffffffffc0205850 <default_pmm_manager+0x6a8>
ffffffffc0202ec0:	cb4fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgfault_num == 3);
ffffffffc0202ec4:	00003697          	auipc	a3,0x3
ffffffffc0202ec8:	b5468693          	addi	a3,a3,-1196 # ffffffffc0205a18 <default_pmm_manager+0x870>
ffffffffc0202ecc:	00002617          	auipc	a2,0x2
ffffffffc0202ed0:	f2c60613          	addi	a2,a2,-212 # ffffffffc0204df8 <commands+0x738>
ffffffffc0202ed4:	09600593          	li	a1,150
ffffffffc0202ed8:	00003517          	auipc	a0,0x3
ffffffffc0202edc:	97850513          	addi	a0,a0,-1672 # ffffffffc0205850 <default_pmm_manager+0x6a8>
ffffffffc0202ee0:	c94fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgfault_num == 1);
ffffffffc0202ee4:	00003697          	auipc	a3,0x3
ffffffffc0202ee8:	b0468693          	addi	a3,a3,-1276 # ffffffffc02059e8 <default_pmm_manager+0x840>
ffffffffc0202eec:	00002617          	auipc	a2,0x2
ffffffffc0202ef0:	f0c60613          	addi	a2,a2,-244 # ffffffffc0204df8 <commands+0x738>
ffffffffc0202ef4:	08c00593          	li	a1,140
ffffffffc0202ef8:	00003517          	auipc	a0,0x3
ffffffffc0202efc:	95850513          	addi	a0,a0,-1704 # ffffffffc0205850 <default_pmm_manager+0x6a8>
ffffffffc0202f00:	c74fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgfault_num == 1);
ffffffffc0202f04:	00003697          	auipc	a3,0x3
ffffffffc0202f08:	ae468693          	addi	a3,a3,-1308 # ffffffffc02059e8 <default_pmm_manager+0x840>
ffffffffc0202f0c:	00002617          	auipc	a2,0x2
ffffffffc0202f10:	eec60613          	addi	a2,a2,-276 # ffffffffc0204df8 <commands+0x738>
ffffffffc0202f14:	08e00593          	li	a1,142
ffffffffc0202f18:	00003517          	auipc	a0,0x3
ffffffffc0202f1c:	93850513          	addi	a0,a0,-1736 # ffffffffc0205850 <default_pmm_manager+0x6a8>
ffffffffc0202f20:	c54fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(mm != NULL);
ffffffffc0202f24:	00003697          	auipc	a3,0x3
ffffffffc0202f28:	97c68693          	addi	a3,a3,-1668 # ffffffffc02058a0 <default_pmm_manager+0x6f8>
ffffffffc0202f2c:	00002617          	auipc	a2,0x2
ffffffffc0202f30:	ecc60613          	addi	a2,a2,-308 # ffffffffc0204df8 <commands+0x738>
ffffffffc0202f34:	0be00593          	li	a1,190
ffffffffc0202f38:	00003517          	auipc	a0,0x3
ffffffffc0202f3c:	91850513          	addi	a0,a0,-1768 # ffffffffc0205850 <default_pmm_manager+0x6a8>
ffffffffc0202f40:	c34fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(check_mm_struct == NULL);
ffffffffc0202f44:	00003697          	auipc	a3,0x3
ffffffffc0202f48:	96c68693          	addi	a3,a3,-1684 # ffffffffc02058b0 <default_pmm_manager+0x708>
ffffffffc0202f4c:	00002617          	auipc	a2,0x2
ffffffffc0202f50:	eac60613          	addi	a2,a2,-340 # ffffffffc0204df8 <commands+0x738>
ffffffffc0202f54:	0c100593          	li	a1,193
ffffffffc0202f58:	00003517          	auipc	a0,0x3
ffffffffc0202f5c:	8f850513          	addi	a0,a0,-1800 # ffffffffc0205850 <default_pmm_manager+0x6a8>
ffffffffc0202f60:	c14fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(nr_free == CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0202f64:	00003697          	auipc	a3,0x3
ffffffffc0202f68:	a3468693          	addi	a3,a3,-1484 # ffffffffc0205998 <default_pmm_manager+0x7f0>
ffffffffc0202f6c:	00002617          	auipc	a2,0x2
ffffffffc0202f70:	e8c60613          	addi	a2,a2,-372 # ffffffffc0204df8 <commands+0x738>
ffffffffc0202f74:	0e600593          	li	a1,230
ffffffffc0202f78:	00003517          	auipc	a0,0x3
ffffffffc0202f7c:	8d850513          	addi	a0,a0,-1832 # ffffffffc0205850 <default_pmm_manager+0x6a8>
ffffffffc0202f80:	bf4fd0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0202f84 <swap_init_mm>:
     return sm->init_mm(mm);
ffffffffc0202f84:	0000e797          	auipc	a5,0xe
ffffffffc0202f88:	5c47b783          	ld	a5,1476(a5) # ffffffffc0211548 <sm>
ffffffffc0202f8c:	6b9c                	ld	a5,16(a5)
ffffffffc0202f8e:	8782                	jr	a5

ffffffffc0202f90 <swap_map_swappable>:
     return sm->map_swappable(mm, addr, page, swap_in);
ffffffffc0202f90:	0000e797          	auipc	a5,0xe
ffffffffc0202f94:	5b87b783          	ld	a5,1464(a5) # ffffffffc0211548 <sm>
ffffffffc0202f98:	739c                	ld	a5,32(a5)
ffffffffc0202f9a:	8782                	jr	a5

ffffffffc0202f9c <swap_out>:
{
ffffffffc0202f9c:	711d                	addi	sp,sp,-96
ffffffffc0202f9e:	ec86                	sd	ra,88(sp)
ffffffffc0202fa0:	e8a2                	sd	s0,80(sp)
ffffffffc0202fa2:	e4a6                	sd	s1,72(sp)
ffffffffc0202fa4:	e0ca                	sd	s2,64(sp)
ffffffffc0202fa6:	fc4e                	sd	s3,56(sp)
ffffffffc0202fa8:	f852                	sd	s4,48(sp)
ffffffffc0202faa:	f456                	sd	s5,40(sp)
ffffffffc0202fac:	f05a                	sd	s6,32(sp)
ffffffffc0202fae:	ec5e                	sd	s7,24(sp)
ffffffffc0202fb0:	e862                	sd	s8,16(sp)
     for (i = 0; i != n; ++i)
ffffffffc0202fb2:	cde9                	beqz	a1,ffffffffc020308c <swap_out+0xf0>
ffffffffc0202fb4:	8a2e                	mv	s4,a1
ffffffffc0202fb6:	892a                	mv	s2,a0
ffffffffc0202fb8:	8ab2                	mv	s5,a2
ffffffffc0202fba:	4401                	li	s0,0
ffffffffc0202fbc:	0000e997          	auipc	s3,0xe
ffffffffc0202fc0:	58c98993          	addi	s3,s3,1420 # ffffffffc0211548 <sm>
               cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr / PGSIZE + 1);
ffffffffc0202fc4:	00003b17          	auipc	s6,0x3
ffffffffc0202fc8:	b9cb0b13          	addi	s6,s6,-1124 # ffffffffc0205b60 <default_pmm_manager+0x9b8>
               cprintf("SWAP: failed to save\n");
ffffffffc0202fcc:	00003b97          	auipc	s7,0x3
ffffffffc0202fd0:	b7cb8b93          	addi	s7,s7,-1156 # ffffffffc0205b48 <default_pmm_manager+0x9a0>
ffffffffc0202fd4:	a825                	j	ffffffffc020300c <swap_out+0x70>
               cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr / PGSIZE + 1);
ffffffffc0202fd6:	67a2                	ld	a5,8(sp)
ffffffffc0202fd8:	8626                	mv	a2,s1
ffffffffc0202fda:	85a2                	mv	a1,s0
ffffffffc0202fdc:	63b4                	ld	a3,64(a5)
ffffffffc0202fde:	855a                	mv	a0,s6
     for (i = 0; i != n; ++i)
ffffffffc0202fe0:	2405                	addiw	s0,s0,1
               cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr / PGSIZE + 1);
ffffffffc0202fe2:	82b1                	srli	a3,a3,0xc
ffffffffc0202fe4:	0685                	addi	a3,a3,1
ffffffffc0202fe6:	8d4fd0ef          	jal	ra,ffffffffc02000ba <cprintf>
               *ptep = (page->pra_vaddr / PGSIZE + 1) << 8;
ffffffffc0202fea:	6522                	ld	a0,8(sp)
               free_page(page);
ffffffffc0202fec:	4585                	li	a1,1
               *ptep = (page->pra_vaddr / PGSIZE + 1) << 8;
ffffffffc0202fee:	613c                	ld	a5,64(a0)
ffffffffc0202ff0:	83b1                	srli	a5,a5,0xc
ffffffffc0202ff2:	0785                	addi	a5,a5,1
ffffffffc0202ff4:	07a2                	slli	a5,a5,0x8
ffffffffc0202ff6:	00fc3023          	sd	a5,0(s8)
               free_page(page);
ffffffffc0202ffa:	e58fe0ef          	jal	ra,ffffffffc0201652 <free_pages>
          tlb_invalidate(mm->pgdir, v);
ffffffffc0202ffe:	01893503          	ld	a0,24(s2)
ffffffffc0203002:	85a6                	mv	a1,s1
ffffffffc0203004:	eb6ff0ef          	jal	ra,ffffffffc02026ba <tlb_invalidate>
     for (i = 0; i != n; ++i)
ffffffffc0203008:	048a0d63          	beq	s4,s0,ffffffffc0203062 <swap_out+0xc6>
          int r = sm->swap_out_victim(mm, &page, in_tick);
ffffffffc020300c:	0009b783          	ld	a5,0(s3)
ffffffffc0203010:	8656                	mv	a2,s5
ffffffffc0203012:	002c                	addi	a1,sp,8
ffffffffc0203014:	7b9c                	ld	a5,48(a5)
ffffffffc0203016:	854a                	mv	a0,s2
ffffffffc0203018:	9782                	jalr	a5
          if (r != 0)
ffffffffc020301a:	e12d                	bnez	a0,ffffffffc020307c <swap_out+0xe0>
          v = page->pra_vaddr;
ffffffffc020301c:	67a2                	ld	a5,8(sp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc020301e:	01893503          	ld	a0,24(s2)
ffffffffc0203022:	4601                	li	a2,0
          v = page->pra_vaddr;
ffffffffc0203024:	63a4                	ld	s1,64(a5)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0203026:	85a6                	mv	a1,s1
ffffffffc0203028:	ea4fe0ef          	jal	ra,ffffffffc02016cc <get_pte>
          assert((*ptep & PTE_V) != 0);
ffffffffc020302c:	611c                	ld	a5,0(a0)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc020302e:	8c2a                	mv	s8,a0
          assert((*ptep & PTE_V) != 0);
ffffffffc0203030:	8b85                	andi	a5,a5,1
ffffffffc0203032:	cfb9                	beqz	a5,ffffffffc0203090 <swap_out+0xf4>
          if (swapfs_write((page->pra_vaddr / PGSIZE + 1) << 8, page) != 0)
ffffffffc0203034:	65a2                	ld	a1,8(sp)
ffffffffc0203036:	61bc                	ld	a5,64(a1)
ffffffffc0203038:	83b1                	srli	a5,a5,0xc
ffffffffc020303a:	0785                	addi	a5,a5,1
ffffffffc020303c:	00879513          	slli	a0,a5,0x8
ffffffffc0203040:	643000ef          	jal	ra,ffffffffc0203e82 <swapfs_write>
ffffffffc0203044:	d949                	beqz	a0,ffffffffc0202fd6 <swap_out+0x3a>
               cprintf("SWAP: failed to save\n");
ffffffffc0203046:	855e                	mv	a0,s7
ffffffffc0203048:	872fd0ef          	jal	ra,ffffffffc02000ba <cprintf>
               sm->map_swappable(mm, v, page, 0);
ffffffffc020304c:	0009b783          	ld	a5,0(s3)
ffffffffc0203050:	6622                	ld	a2,8(sp)
ffffffffc0203052:	4681                	li	a3,0
ffffffffc0203054:	739c                	ld	a5,32(a5)
ffffffffc0203056:	85a6                	mv	a1,s1
ffffffffc0203058:	854a                	mv	a0,s2
     for (i = 0; i != n; ++i)
ffffffffc020305a:	2405                	addiw	s0,s0,1
               sm->map_swappable(mm, v, page, 0);
ffffffffc020305c:	9782                	jalr	a5
     for (i = 0; i != n; ++i)
ffffffffc020305e:	fa8a17e3          	bne	s4,s0,ffffffffc020300c <swap_out+0x70>
}
ffffffffc0203062:	60e6                	ld	ra,88(sp)
ffffffffc0203064:	8522                	mv	a0,s0
ffffffffc0203066:	6446                	ld	s0,80(sp)
ffffffffc0203068:	64a6                	ld	s1,72(sp)
ffffffffc020306a:	6906                	ld	s2,64(sp)
ffffffffc020306c:	79e2                	ld	s3,56(sp)
ffffffffc020306e:	7a42                	ld	s4,48(sp)
ffffffffc0203070:	7aa2                	ld	s5,40(sp)
ffffffffc0203072:	7b02                	ld	s6,32(sp)
ffffffffc0203074:	6be2                	ld	s7,24(sp)
ffffffffc0203076:	6c42                	ld	s8,16(sp)
ffffffffc0203078:	6125                	addi	sp,sp,96
ffffffffc020307a:	8082                	ret
               cprintf("i %d, swap_out: call swap_out_victim failed\n", i);
ffffffffc020307c:	85a2                	mv	a1,s0
ffffffffc020307e:	00003517          	auipc	a0,0x3
ffffffffc0203082:	a8250513          	addi	a0,a0,-1406 # ffffffffc0205b00 <default_pmm_manager+0x958>
ffffffffc0203086:	834fd0ef          	jal	ra,ffffffffc02000ba <cprintf>
               break;
ffffffffc020308a:	bfe1                	j	ffffffffc0203062 <swap_out+0xc6>
     for (i = 0; i != n; ++i)
ffffffffc020308c:	4401                	li	s0,0
ffffffffc020308e:	bfd1                	j	ffffffffc0203062 <swap_out+0xc6>
          assert((*ptep & PTE_V) != 0);
ffffffffc0203090:	00003697          	auipc	a3,0x3
ffffffffc0203094:	aa068693          	addi	a3,a3,-1376 # ffffffffc0205b30 <default_pmm_manager+0x988>
ffffffffc0203098:	00002617          	auipc	a2,0x2
ffffffffc020309c:	d6060613          	addi	a2,a2,-672 # ffffffffc0204df8 <commands+0x738>
ffffffffc02030a0:	06200593          	li	a1,98
ffffffffc02030a4:	00002517          	auipc	a0,0x2
ffffffffc02030a8:	7ac50513          	addi	a0,a0,1964 # ffffffffc0205850 <default_pmm_manager+0x6a8>
ffffffffc02030ac:	ac8fd0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc02030b0 <swap_in>:
{
ffffffffc02030b0:	7179                	addi	sp,sp,-48
ffffffffc02030b2:	e84a                	sd	s2,16(sp)
ffffffffc02030b4:	892a                	mv	s2,a0
     struct Page *result = alloc_page();
ffffffffc02030b6:	4505                	li	a0,1
{
ffffffffc02030b8:	ec26                	sd	s1,24(sp)
ffffffffc02030ba:	e44e                	sd	s3,8(sp)
ffffffffc02030bc:	f406                	sd	ra,40(sp)
ffffffffc02030be:	f022                	sd	s0,32(sp)
ffffffffc02030c0:	84ae                	mv	s1,a1
ffffffffc02030c2:	89b2                	mv	s3,a2
     struct Page *result = alloc_page();
ffffffffc02030c4:	cfcfe0ef          	jal	ra,ffffffffc02015c0 <alloc_pages>
     assert(result != NULL);
ffffffffc02030c8:	c129                	beqz	a0,ffffffffc020310a <swap_in+0x5a>
     pte_t *ptep = get_pte(mm->pgdir, addr, 0);
ffffffffc02030ca:	842a                	mv	s0,a0
ffffffffc02030cc:	01893503          	ld	a0,24(s2)
ffffffffc02030d0:	4601                	li	a2,0
ffffffffc02030d2:	85a6                	mv	a1,s1
ffffffffc02030d4:	df8fe0ef          	jal	ra,ffffffffc02016cc <get_pte>
ffffffffc02030d8:	892a                	mv	s2,a0
     if ((r = swapfs_read((*ptep), result)) != 0)
ffffffffc02030da:	6108                	ld	a0,0(a0)
ffffffffc02030dc:	85a2                	mv	a1,s0
ffffffffc02030de:	509000ef          	jal	ra,ffffffffc0203de6 <swapfs_read>
     cprintf("swap_in: load disk swap entry %d with swap_page in vadr 0x%x\n", (*ptep) >> 8, addr);
ffffffffc02030e2:	00093583          	ld	a1,0(s2)
ffffffffc02030e6:	8626                	mv	a2,s1
ffffffffc02030e8:	00003517          	auipc	a0,0x3
ffffffffc02030ec:	ac850513          	addi	a0,a0,-1336 # ffffffffc0205bb0 <default_pmm_manager+0xa08>
ffffffffc02030f0:	81a1                	srli	a1,a1,0x8
ffffffffc02030f2:	fc9fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
}
ffffffffc02030f6:	70a2                	ld	ra,40(sp)
     *ptr_result = result;
ffffffffc02030f8:	0089b023          	sd	s0,0(s3)
}
ffffffffc02030fc:	7402                	ld	s0,32(sp)
ffffffffc02030fe:	64e2                	ld	s1,24(sp)
ffffffffc0203100:	6942                	ld	s2,16(sp)
ffffffffc0203102:	69a2                	ld	s3,8(sp)
ffffffffc0203104:	4501                	li	a0,0
ffffffffc0203106:	6145                	addi	sp,sp,48
ffffffffc0203108:	8082                	ret
     assert(result != NULL);
ffffffffc020310a:	00003697          	auipc	a3,0x3
ffffffffc020310e:	a9668693          	addi	a3,a3,-1386 # ffffffffc0205ba0 <default_pmm_manager+0x9f8>
ffffffffc0203112:	00002617          	auipc	a2,0x2
ffffffffc0203116:	ce660613          	addi	a2,a2,-794 # ffffffffc0204df8 <commands+0x738>
ffffffffc020311a:	07900593          	li	a1,121
ffffffffc020311e:	00002517          	auipc	a0,0x2
ffffffffc0203122:	73250513          	addi	a0,a0,1842 # ffffffffc0205850 <default_pmm_manager+0x6a8>
ffffffffc0203126:	a4efd0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc020312a <_fifo_init_mm>:
    elm->prev = elm->next = elm;
ffffffffc020312a:	0000e797          	auipc	a5,0xe
ffffffffc020312e:	fbe78793          	addi	a5,a5,-66 # ffffffffc02110e8 <pra_list_head_f>
 */
static int
_fifo_init_mm(struct mm_struct *mm)
{
    list_init(&pra_list_head_f);
    mm->sm_priv = &pra_list_head_f;
ffffffffc0203132:	f51c                	sd	a5,40(a0)
ffffffffc0203134:	e79c                	sd	a5,8(a5)
ffffffffc0203136:	e39c                	sd	a5,0(a5)
    // cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
    return 0;
}
ffffffffc0203138:	4501                	li	a0,0
ffffffffc020313a:	8082                	ret

ffffffffc020313c <_fifo_init>:

static int
_fifo_init(void)
{
    return 0;
}
ffffffffc020313c:	4501                	li	a0,0
ffffffffc020313e:	8082                	ret

ffffffffc0203140 <_fifo_set_unswappable>:

static int
_fifo_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
    return 0;
}
ffffffffc0203140:	4501                	li	a0,0
ffffffffc0203142:	8082                	ret

ffffffffc0203144 <_fifo_tick_event>:

static int
_fifo_tick_event(struct mm_struct *mm)
{
    return 0;
}
ffffffffc0203144:	4501                	li	a0,0
ffffffffc0203146:	8082                	ret

ffffffffc0203148 <_fifo_check_swap>:
{
ffffffffc0203148:	711d                	addi	sp,sp,-96
ffffffffc020314a:	fc4e                	sd	s3,56(sp)
ffffffffc020314c:	f852                	sd	s4,48(sp)
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc020314e:	00003517          	auipc	a0,0x3
ffffffffc0203152:	aa250513          	addi	a0,a0,-1374 # ffffffffc0205bf0 <default_pmm_manager+0xa48>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0203156:	698d                	lui	s3,0x3
ffffffffc0203158:	4a31                	li	s4,12
{
ffffffffc020315a:	e0ca                	sd	s2,64(sp)
ffffffffc020315c:	ec86                	sd	ra,88(sp)
ffffffffc020315e:	e8a2                	sd	s0,80(sp)
ffffffffc0203160:	e4a6                	sd	s1,72(sp)
ffffffffc0203162:	f456                	sd	s5,40(sp)
ffffffffc0203164:	f05a                	sd	s6,32(sp)
ffffffffc0203166:	ec5e                	sd	s7,24(sp)
ffffffffc0203168:	e862                	sd	s8,16(sp)
ffffffffc020316a:	e466                	sd	s9,8(sp)
ffffffffc020316c:	e06a                	sd	s10,0(sp)
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc020316e:	f4dfc0ef          	jal	ra,ffffffffc02000ba <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0203172:	01498023          	sb	s4,0(s3) # 3000 <kern_entry-0xffffffffc01fd000>
    assert(pgfault_num == 4);
ffffffffc0203176:	0000e917          	auipc	s2,0xe
ffffffffc020317a:	3ea92903          	lw	s2,1002(s2) # ffffffffc0211560 <pgfault_num>
ffffffffc020317e:	4791                	li	a5,4
ffffffffc0203180:	14f91e63          	bne	s2,a5,ffffffffc02032dc <_fifo_check_swap+0x194>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0203184:	00003517          	auipc	a0,0x3
ffffffffc0203188:	aac50513          	addi	a0,a0,-1364 # ffffffffc0205c30 <default_pmm_manager+0xa88>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc020318c:	6a85                	lui	s5,0x1
ffffffffc020318e:	4b29                	li	s6,10
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0203190:	f2bfc0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0203194:	0000e417          	auipc	s0,0xe
ffffffffc0203198:	3cc40413          	addi	s0,s0,972 # ffffffffc0211560 <pgfault_num>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc020319c:	016a8023          	sb	s6,0(s5) # 1000 <kern_entry-0xffffffffc01ff000>
    assert(pgfault_num == 4);
ffffffffc02031a0:	4004                	lw	s1,0(s0)
ffffffffc02031a2:	2481                	sext.w	s1,s1
ffffffffc02031a4:	2b249c63          	bne	s1,s2,ffffffffc020345c <_fifo_check_swap+0x314>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc02031a8:	00003517          	auipc	a0,0x3
ffffffffc02031ac:	ab050513          	addi	a0,a0,-1360 # ffffffffc0205c58 <default_pmm_manager+0xab0>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc02031b0:	6b91                	lui	s7,0x4
ffffffffc02031b2:	4c35                	li	s8,13
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc02031b4:	f07fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc02031b8:	018b8023          	sb	s8,0(s7) # 4000 <kern_entry-0xffffffffc01fc000>
    assert(pgfault_num == 4);
ffffffffc02031bc:	00042903          	lw	s2,0(s0)
ffffffffc02031c0:	2901                	sext.w	s2,s2
ffffffffc02031c2:	26991d63          	bne	s2,s1,ffffffffc020343c <_fifo_check_swap+0x2f4>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc02031c6:	00003517          	auipc	a0,0x3
ffffffffc02031ca:	aba50513          	addi	a0,a0,-1350 # ffffffffc0205c80 <default_pmm_manager+0xad8>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc02031ce:	6c89                	lui	s9,0x2
ffffffffc02031d0:	4d2d                	li	s10,11
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc02031d2:	ee9fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc02031d6:	01ac8023          	sb	s10,0(s9) # 2000 <kern_entry-0xffffffffc01fe000>
    assert(pgfault_num == 4);
ffffffffc02031da:	401c                	lw	a5,0(s0)
ffffffffc02031dc:	2781                	sext.w	a5,a5
ffffffffc02031de:	23279f63          	bne	a5,s2,ffffffffc020341c <_fifo_check_swap+0x2d4>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc02031e2:	00003517          	auipc	a0,0x3
ffffffffc02031e6:	ac650513          	addi	a0,a0,-1338 # ffffffffc0205ca8 <default_pmm_manager+0xb00>
ffffffffc02031ea:	ed1fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc02031ee:	6795                	lui	a5,0x5
ffffffffc02031f0:	4739                	li	a4,14
ffffffffc02031f2:	00e78023          	sb	a4,0(a5) # 5000 <kern_entry-0xffffffffc01fb000>
    assert(pgfault_num == 5);
ffffffffc02031f6:	4004                	lw	s1,0(s0)
ffffffffc02031f8:	4795                	li	a5,5
ffffffffc02031fa:	2481                	sext.w	s1,s1
ffffffffc02031fc:	20f49063          	bne	s1,a5,ffffffffc02033fc <_fifo_check_swap+0x2b4>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0203200:	00003517          	auipc	a0,0x3
ffffffffc0203204:	a8050513          	addi	a0,a0,-1408 # ffffffffc0205c80 <default_pmm_manager+0xad8>
ffffffffc0203208:	eb3fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc020320c:	01ac8023          	sb	s10,0(s9)
    assert(pgfault_num == 5);
ffffffffc0203210:	401c                	lw	a5,0(s0)
ffffffffc0203212:	2781                	sext.w	a5,a5
ffffffffc0203214:	1c979463          	bne	a5,s1,ffffffffc02033dc <_fifo_check_swap+0x294>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0203218:	00003517          	auipc	a0,0x3
ffffffffc020321c:	a1850513          	addi	a0,a0,-1512 # ffffffffc0205c30 <default_pmm_manager+0xa88>
ffffffffc0203220:	e9bfc0ef          	jal	ra,ffffffffc02000ba <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203224:	016a8023          	sb	s6,0(s5)
    assert(pgfault_num == 6);
ffffffffc0203228:	401c                	lw	a5,0(s0)
ffffffffc020322a:	4719                	li	a4,6
ffffffffc020322c:	2781                	sext.w	a5,a5
ffffffffc020322e:	18e79763          	bne	a5,a4,ffffffffc02033bc <_fifo_check_swap+0x274>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0203232:	00003517          	auipc	a0,0x3
ffffffffc0203236:	a4e50513          	addi	a0,a0,-1458 # ffffffffc0205c80 <default_pmm_manager+0xad8>
ffffffffc020323a:	e81fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc020323e:	01ac8023          	sb	s10,0(s9)
    assert(pgfault_num == 7);
ffffffffc0203242:	401c                	lw	a5,0(s0)
ffffffffc0203244:	471d                	li	a4,7
ffffffffc0203246:	2781                	sext.w	a5,a5
ffffffffc0203248:	14e79a63          	bne	a5,a4,ffffffffc020339c <_fifo_check_swap+0x254>
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc020324c:	00003517          	auipc	a0,0x3
ffffffffc0203250:	9a450513          	addi	a0,a0,-1628 # ffffffffc0205bf0 <default_pmm_manager+0xa48>
ffffffffc0203254:	e67fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0203258:	01498023          	sb	s4,0(s3)
    assert(pgfault_num == 8);
ffffffffc020325c:	401c                	lw	a5,0(s0)
ffffffffc020325e:	4721                	li	a4,8
ffffffffc0203260:	2781                	sext.w	a5,a5
ffffffffc0203262:	10e79d63          	bne	a5,a4,ffffffffc020337c <_fifo_check_swap+0x234>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0203266:	00003517          	auipc	a0,0x3
ffffffffc020326a:	9f250513          	addi	a0,a0,-1550 # ffffffffc0205c58 <default_pmm_manager+0xab0>
ffffffffc020326e:	e4dfc0ef          	jal	ra,ffffffffc02000ba <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0203272:	018b8023          	sb	s8,0(s7)
    assert(pgfault_num == 9);
ffffffffc0203276:	401c                	lw	a5,0(s0)
ffffffffc0203278:	4725                	li	a4,9
ffffffffc020327a:	2781                	sext.w	a5,a5
ffffffffc020327c:	0ee79063          	bne	a5,a4,ffffffffc020335c <_fifo_check_swap+0x214>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc0203280:	00003517          	auipc	a0,0x3
ffffffffc0203284:	a2850513          	addi	a0,a0,-1496 # ffffffffc0205ca8 <default_pmm_manager+0xb00>
ffffffffc0203288:	e33fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc020328c:	6795                	lui	a5,0x5
ffffffffc020328e:	4739                	li	a4,14
ffffffffc0203290:	00e78023          	sb	a4,0(a5) # 5000 <kern_entry-0xffffffffc01fb000>
    assert(pgfault_num == 10);
ffffffffc0203294:	4004                	lw	s1,0(s0)
ffffffffc0203296:	47a9                	li	a5,10
ffffffffc0203298:	2481                	sext.w	s1,s1
ffffffffc020329a:	0af49163          	bne	s1,a5,ffffffffc020333c <_fifo_check_swap+0x1f4>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc020329e:	00003517          	auipc	a0,0x3
ffffffffc02032a2:	99250513          	addi	a0,a0,-1646 # ffffffffc0205c30 <default_pmm_manager+0xa88>
ffffffffc02032a6:	e15fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc02032aa:	6785                	lui	a5,0x1
ffffffffc02032ac:	0007c783          	lbu	a5,0(a5) # 1000 <kern_entry-0xffffffffc01ff000>
ffffffffc02032b0:	06979663          	bne	a5,s1,ffffffffc020331c <_fifo_check_swap+0x1d4>
    assert(pgfault_num == 11);
ffffffffc02032b4:	401c                	lw	a5,0(s0)
ffffffffc02032b6:	472d                	li	a4,11
ffffffffc02032b8:	2781                	sext.w	a5,a5
ffffffffc02032ba:	04e79163          	bne	a5,a4,ffffffffc02032fc <_fifo_check_swap+0x1b4>
}
ffffffffc02032be:	60e6                	ld	ra,88(sp)
ffffffffc02032c0:	6446                	ld	s0,80(sp)
ffffffffc02032c2:	64a6                	ld	s1,72(sp)
ffffffffc02032c4:	6906                	ld	s2,64(sp)
ffffffffc02032c6:	79e2                	ld	s3,56(sp)
ffffffffc02032c8:	7a42                	ld	s4,48(sp)
ffffffffc02032ca:	7aa2                	ld	s5,40(sp)
ffffffffc02032cc:	7b02                	ld	s6,32(sp)
ffffffffc02032ce:	6be2                	ld	s7,24(sp)
ffffffffc02032d0:	6c42                	ld	s8,16(sp)
ffffffffc02032d2:	6ca2                	ld	s9,8(sp)
ffffffffc02032d4:	6d02                	ld	s10,0(sp)
ffffffffc02032d6:	4501                	li	a0,0
ffffffffc02032d8:	6125                	addi	sp,sp,96
ffffffffc02032da:	8082                	ret
    assert(pgfault_num == 4);
ffffffffc02032dc:	00002697          	auipc	a3,0x2
ffffffffc02032e0:	75468693          	addi	a3,a3,1876 # ffffffffc0205a30 <default_pmm_manager+0x888>
ffffffffc02032e4:	00002617          	auipc	a2,0x2
ffffffffc02032e8:	b1460613          	addi	a2,a2,-1260 # ffffffffc0204df8 <commands+0x738>
ffffffffc02032ec:	05800593          	li	a1,88
ffffffffc02032f0:	00003517          	auipc	a0,0x3
ffffffffc02032f4:	92850513          	addi	a0,a0,-1752 # ffffffffc0205c18 <default_pmm_manager+0xa70>
ffffffffc02032f8:	87cfd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num == 11);
ffffffffc02032fc:	00003697          	auipc	a3,0x3
ffffffffc0203300:	a8c68693          	addi	a3,a3,-1396 # ffffffffc0205d88 <default_pmm_manager+0xbe0>
ffffffffc0203304:	00002617          	auipc	a2,0x2
ffffffffc0203308:	af460613          	addi	a2,a2,-1292 # ffffffffc0204df8 <commands+0x738>
ffffffffc020330c:	07a00593          	li	a1,122
ffffffffc0203310:	00003517          	auipc	a0,0x3
ffffffffc0203314:	90850513          	addi	a0,a0,-1784 # ffffffffc0205c18 <default_pmm_manager+0xa70>
ffffffffc0203318:	85cfd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc020331c:	00003697          	auipc	a3,0x3
ffffffffc0203320:	a4468693          	addi	a3,a3,-1468 # ffffffffc0205d60 <default_pmm_manager+0xbb8>
ffffffffc0203324:	00002617          	auipc	a2,0x2
ffffffffc0203328:	ad460613          	addi	a2,a2,-1324 # ffffffffc0204df8 <commands+0x738>
ffffffffc020332c:	07800593          	li	a1,120
ffffffffc0203330:	00003517          	auipc	a0,0x3
ffffffffc0203334:	8e850513          	addi	a0,a0,-1816 # ffffffffc0205c18 <default_pmm_manager+0xa70>
ffffffffc0203338:	83cfd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num == 10);
ffffffffc020333c:	00003697          	auipc	a3,0x3
ffffffffc0203340:	a0c68693          	addi	a3,a3,-1524 # ffffffffc0205d48 <default_pmm_manager+0xba0>
ffffffffc0203344:	00002617          	auipc	a2,0x2
ffffffffc0203348:	ab460613          	addi	a2,a2,-1356 # ffffffffc0204df8 <commands+0x738>
ffffffffc020334c:	07600593          	li	a1,118
ffffffffc0203350:	00003517          	auipc	a0,0x3
ffffffffc0203354:	8c850513          	addi	a0,a0,-1848 # ffffffffc0205c18 <default_pmm_manager+0xa70>
ffffffffc0203358:	81cfd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num == 9);
ffffffffc020335c:	00003697          	auipc	a3,0x3
ffffffffc0203360:	9d468693          	addi	a3,a3,-1580 # ffffffffc0205d30 <default_pmm_manager+0xb88>
ffffffffc0203364:	00002617          	auipc	a2,0x2
ffffffffc0203368:	a9460613          	addi	a2,a2,-1388 # ffffffffc0204df8 <commands+0x738>
ffffffffc020336c:	07300593          	li	a1,115
ffffffffc0203370:	00003517          	auipc	a0,0x3
ffffffffc0203374:	8a850513          	addi	a0,a0,-1880 # ffffffffc0205c18 <default_pmm_manager+0xa70>
ffffffffc0203378:	ffdfc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num == 8);
ffffffffc020337c:	00003697          	auipc	a3,0x3
ffffffffc0203380:	99c68693          	addi	a3,a3,-1636 # ffffffffc0205d18 <default_pmm_manager+0xb70>
ffffffffc0203384:	00002617          	auipc	a2,0x2
ffffffffc0203388:	a7460613          	addi	a2,a2,-1420 # ffffffffc0204df8 <commands+0x738>
ffffffffc020338c:	07000593          	li	a1,112
ffffffffc0203390:	00003517          	auipc	a0,0x3
ffffffffc0203394:	88850513          	addi	a0,a0,-1912 # ffffffffc0205c18 <default_pmm_manager+0xa70>
ffffffffc0203398:	fddfc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num == 7);
ffffffffc020339c:	00003697          	auipc	a3,0x3
ffffffffc02033a0:	96468693          	addi	a3,a3,-1692 # ffffffffc0205d00 <default_pmm_manager+0xb58>
ffffffffc02033a4:	00002617          	auipc	a2,0x2
ffffffffc02033a8:	a5460613          	addi	a2,a2,-1452 # ffffffffc0204df8 <commands+0x738>
ffffffffc02033ac:	06d00593          	li	a1,109
ffffffffc02033b0:	00003517          	auipc	a0,0x3
ffffffffc02033b4:	86850513          	addi	a0,a0,-1944 # ffffffffc0205c18 <default_pmm_manager+0xa70>
ffffffffc02033b8:	fbdfc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num == 6);
ffffffffc02033bc:	00003697          	auipc	a3,0x3
ffffffffc02033c0:	92c68693          	addi	a3,a3,-1748 # ffffffffc0205ce8 <default_pmm_manager+0xb40>
ffffffffc02033c4:	00002617          	auipc	a2,0x2
ffffffffc02033c8:	a3460613          	addi	a2,a2,-1484 # ffffffffc0204df8 <commands+0x738>
ffffffffc02033cc:	06a00593          	li	a1,106
ffffffffc02033d0:	00003517          	auipc	a0,0x3
ffffffffc02033d4:	84850513          	addi	a0,a0,-1976 # ffffffffc0205c18 <default_pmm_manager+0xa70>
ffffffffc02033d8:	f9dfc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num == 5);
ffffffffc02033dc:	00003697          	auipc	a3,0x3
ffffffffc02033e0:	8f468693          	addi	a3,a3,-1804 # ffffffffc0205cd0 <default_pmm_manager+0xb28>
ffffffffc02033e4:	00002617          	auipc	a2,0x2
ffffffffc02033e8:	a1460613          	addi	a2,a2,-1516 # ffffffffc0204df8 <commands+0x738>
ffffffffc02033ec:	06700593          	li	a1,103
ffffffffc02033f0:	00003517          	auipc	a0,0x3
ffffffffc02033f4:	82850513          	addi	a0,a0,-2008 # ffffffffc0205c18 <default_pmm_manager+0xa70>
ffffffffc02033f8:	f7dfc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num == 5);
ffffffffc02033fc:	00003697          	auipc	a3,0x3
ffffffffc0203400:	8d468693          	addi	a3,a3,-1836 # ffffffffc0205cd0 <default_pmm_manager+0xb28>
ffffffffc0203404:	00002617          	auipc	a2,0x2
ffffffffc0203408:	9f460613          	addi	a2,a2,-1548 # ffffffffc0204df8 <commands+0x738>
ffffffffc020340c:	06400593          	li	a1,100
ffffffffc0203410:	00003517          	auipc	a0,0x3
ffffffffc0203414:	80850513          	addi	a0,a0,-2040 # ffffffffc0205c18 <default_pmm_manager+0xa70>
ffffffffc0203418:	f5dfc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num == 4);
ffffffffc020341c:	00002697          	auipc	a3,0x2
ffffffffc0203420:	61468693          	addi	a3,a3,1556 # ffffffffc0205a30 <default_pmm_manager+0x888>
ffffffffc0203424:	00002617          	auipc	a2,0x2
ffffffffc0203428:	9d460613          	addi	a2,a2,-1580 # ffffffffc0204df8 <commands+0x738>
ffffffffc020342c:	06100593          	li	a1,97
ffffffffc0203430:	00002517          	auipc	a0,0x2
ffffffffc0203434:	7e850513          	addi	a0,a0,2024 # ffffffffc0205c18 <default_pmm_manager+0xa70>
ffffffffc0203438:	f3dfc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num == 4);
ffffffffc020343c:	00002697          	auipc	a3,0x2
ffffffffc0203440:	5f468693          	addi	a3,a3,1524 # ffffffffc0205a30 <default_pmm_manager+0x888>
ffffffffc0203444:	00002617          	auipc	a2,0x2
ffffffffc0203448:	9b460613          	addi	a2,a2,-1612 # ffffffffc0204df8 <commands+0x738>
ffffffffc020344c:	05e00593          	li	a1,94
ffffffffc0203450:	00002517          	auipc	a0,0x2
ffffffffc0203454:	7c850513          	addi	a0,a0,1992 # ffffffffc0205c18 <default_pmm_manager+0xa70>
ffffffffc0203458:	f1dfc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num == 4);
ffffffffc020345c:	00002697          	auipc	a3,0x2
ffffffffc0203460:	5d468693          	addi	a3,a3,1492 # ffffffffc0205a30 <default_pmm_manager+0x888>
ffffffffc0203464:	00002617          	auipc	a2,0x2
ffffffffc0203468:	99460613          	addi	a2,a2,-1644 # ffffffffc0204df8 <commands+0x738>
ffffffffc020346c:	05b00593          	li	a1,91
ffffffffc0203470:	00002517          	auipc	a0,0x2
ffffffffc0203474:	7a850513          	addi	a0,a0,1960 # ffffffffc0205c18 <default_pmm_manager+0xa70>
ffffffffc0203478:	efdfc0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc020347c <_fifo_swap_out_victim>:
    list_entry_t *head = (list_entry_t *)mm->sm_priv;
ffffffffc020347c:	7518                	ld	a4,40(a0)
{
ffffffffc020347e:	1141                	addi	sp,sp,-16
ffffffffc0203480:	e406                	sd	ra,8(sp)
    assert(head != NULL);
ffffffffc0203482:	c731                	beqz	a4,ffffffffc02034ce <_fifo_swap_out_victim+0x52>
    assert(in_tick == 0);
ffffffffc0203484:	e60d                	bnez	a2,ffffffffc02034ae <_fifo_swap_out_victim+0x32>
    return listelm->prev;
ffffffffc0203486:	631c                	ld	a5,0(a4)
    if (entry != head)
ffffffffc0203488:	00f70d63          	beq	a4,a5,ffffffffc02034a2 <_fifo_swap_out_victim+0x26>
    __list_del(listelm->prev, listelm->next);
ffffffffc020348c:	6394                	ld	a3,0(a5)
ffffffffc020348e:	6798                	ld	a4,8(a5)
}
ffffffffc0203490:	60a2                	ld	ra,8(sp)
        *ptr_page = le2page(entry, pra_page_link);
ffffffffc0203492:	fd078793          	addi	a5,a5,-48
    prev->next = next;
ffffffffc0203496:	e698                	sd	a4,8(a3)
    next->prev = prev;
ffffffffc0203498:	e314                	sd	a3,0(a4)
ffffffffc020349a:	e19c                	sd	a5,0(a1)
}
ffffffffc020349c:	4501                	li	a0,0
ffffffffc020349e:	0141                	addi	sp,sp,16
ffffffffc02034a0:	8082                	ret
ffffffffc02034a2:	60a2                	ld	ra,8(sp)
        *ptr_page = NULL;
ffffffffc02034a4:	0005b023          	sd	zero,0(a1) # 1000 <kern_entry-0xffffffffc01ff000>
}
ffffffffc02034a8:	4501                	li	a0,0
ffffffffc02034aa:	0141                	addi	sp,sp,16
ffffffffc02034ac:	8082                	ret
    assert(in_tick == 0);
ffffffffc02034ae:	00003697          	auipc	a3,0x3
ffffffffc02034b2:	90268693          	addi	a3,a3,-1790 # ffffffffc0205db0 <default_pmm_manager+0xc08>
ffffffffc02034b6:	00002617          	auipc	a2,0x2
ffffffffc02034ba:	94260613          	addi	a2,a2,-1726 # ffffffffc0204df8 <commands+0x738>
ffffffffc02034be:	04200593          	li	a1,66
ffffffffc02034c2:	00002517          	auipc	a0,0x2
ffffffffc02034c6:	75650513          	addi	a0,a0,1878 # ffffffffc0205c18 <default_pmm_manager+0xa70>
ffffffffc02034ca:	eabfc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(head != NULL);
ffffffffc02034ce:	00003697          	auipc	a3,0x3
ffffffffc02034d2:	8d268693          	addi	a3,a3,-1838 # ffffffffc0205da0 <default_pmm_manager+0xbf8>
ffffffffc02034d6:	00002617          	auipc	a2,0x2
ffffffffc02034da:	92260613          	addi	a2,a2,-1758 # ffffffffc0204df8 <commands+0x738>
ffffffffc02034de:	04100593          	li	a1,65
ffffffffc02034e2:	00002517          	auipc	a0,0x2
ffffffffc02034e6:	73650513          	addi	a0,a0,1846 # ffffffffc0205c18 <default_pmm_manager+0xa70>
ffffffffc02034ea:	e8bfc0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc02034ee <_fifo_map_swappable>:
    list_entry_t *head = (list_entry_t *)mm->sm_priv;
ffffffffc02034ee:	751c                	ld	a5,40(a0)
    assert(entry != NULL && head != NULL);
ffffffffc02034f0:	cb91                	beqz	a5,ffffffffc0203504 <_fifo_map_swappable+0x16>
    __list_add(elm, listelm, listelm->next);
ffffffffc02034f2:	6794                	ld	a3,8(a5)
ffffffffc02034f4:	03060713          	addi	a4,a2,48
}
ffffffffc02034f8:	4501                	li	a0,0
    prev->next = next->prev = elm;
ffffffffc02034fa:	e298                	sd	a4,0(a3)
ffffffffc02034fc:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc02034fe:	fe14                	sd	a3,56(a2)
    elm->prev = prev;
ffffffffc0203500:	fa1c                	sd	a5,48(a2)
ffffffffc0203502:	8082                	ret
{
ffffffffc0203504:	1141                	addi	sp,sp,-16
    assert(entry != NULL && head != NULL);
ffffffffc0203506:	00003697          	auipc	a3,0x3
ffffffffc020350a:	8ba68693          	addi	a3,a3,-1862 # ffffffffc0205dc0 <default_pmm_manager+0xc18>
ffffffffc020350e:	00002617          	auipc	a2,0x2
ffffffffc0203512:	8ea60613          	addi	a2,a2,-1814 # ffffffffc0204df8 <commands+0x738>
ffffffffc0203516:	03200593          	li	a1,50
ffffffffc020351a:	00002517          	auipc	a0,0x2
ffffffffc020351e:	6fe50513          	addi	a0,a0,1790 # ffffffffc0205c18 <default_pmm_manager+0xa70>
{
ffffffffc0203522:	e406                	sd	ra,8(sp)
    assert(entry != NULL && head != NULL);
ffffffffc0203524:	e51fc0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0203528 <check_vma_overlap.part.0>:
    return vma;
}

// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next)
ffffffffc0203528:	1141                	addi	sp,sp,-16
{
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);
ffffffffc020352a:	00003697          	auipc	a3,0x3
ffffffffc020352e:	8ce68693          	addi	a3,a3,-1842 # ffffffffc0205df8 <default_pmm_manager+0xc50>
ffffffffc0203532:	00002617          	auipc	a2,0x2
ffffffffc0203536:	8c660613          	addi	a2,a2,-1850 # ffffffffc0204df8 <commands+0x738>
ffffffffc020353a:	08c00593          	li	a1,140
ffffffffc020353e:	00003517          	auipc	a0,0x3
ffffffffc0203542:	8da50513          	addi	a0,a0,-1830 # ffffffffc0205e18 <default_pmm_manager+0xc70>
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next)
ffffffffc0203546:	e406                	sd	ra,8(sp)
    assert(next->vm_start < next->vm_end);
ffffffffc0203548:	e2dfc0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc020354c <mm_create>:
{
ffffffffc020354c:	1141                	addi	sp,sp,-16
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc020354e:	03000513          	li	a0,48
{
ffffffffc0203552:	e022                	sd	s0,0(sp)
ffffffffc0203554:	e406                	sd	ra,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0203556:	a22ff0ef          	jal	ra,ffffffffc0202778 <kmalloc>
ffffffffc020355a:	842a                	mv	s0,a0
    if (mm != NULL)
ffffffffc020355c:	c105                	beqz	a0,ffffffffc020357c <mm_create+0x30>
    elm->prev = elm->next = elm;
ffffffffc020355e:	e408                	sd	a0,8(s0)
ffffffffc0203560:	e008                	sd	a0,0(s0)
        mm->mmap_cache = NULL;
ffffffffc0203562:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc0203566:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc020356a:	02052023          	sw	zero,32(a0)
        if (swap_init_ok)
ffffffffc020356e:	0000e797          	auipc	a5,0xe
ffffffffc0203572:	fe27a783          	lw	a5,-30(a5) # ffffffffc0211550 <swap_init_ok>
ffffffffc0203576:	eb81                	bnez	a5,ffffffffc0203586 <mm_create+0x3a>
            mm->sm_priv = NULL;
ffffffffc0203578:	02053423          	sd	zero,40(a0)
}
ffffffffc020357c:	60a2                	ld	ra,8(sp)
ffffffffc020357e:	8522                	mv	a0,s0
ffffffffc0203580:	6402                	ld	s0,0(sp)
ffffffffc0203582:	0141                	addi	sp,sp,16
ffffffffc0203584:	8082                	ret
            swap_init_mm(mm);
ffffffffc0203586:	9ffff0ef          	jal	ra,ffffffffc0202f84 <swap_init_mm>
}
ffffffffc020358a:	60a2                	ld	ra,8(sp)
ffffffffc020358c:	8522                	mv	a0,s0
ffffffffc020358e:	6402                	ld	s0,0(sp)
ffffffffc0203590:	0141                	addi	sp,sp,16
ffffffffc0203592:	8082                	ret

ffffffffc0203594 <vma_create>:
{
ffffffffc0203594:	1101                	addi	sp,sp,-32
ffffffffc0203596:	e04a                	sd	s2,0(sp)
ffffffffc0203598:	892a                	mv	s2,a0
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc020359a:	03000513          	li	a0,48
{
ffffffffc020359e:	e822                	sd	s0,16(sp)
ffffffffc02035a0:	e426                	sd	s1,8(sp)
ffffffffc02035a2:	ec06                	sd	ra,24(sp)
ffffffffc02035a4:	84ae                	mv	s1,a1
ffffffffc02035a6:	8432                	mv	s0,a2
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02035a8:	9d0ff0ef          	jal	ra,ffffffffc0202778 <kmalloc>
    if (vma != NULL)
ffffffffc02035ac:	c509                	beqz	a0,ffffffffc02035b6 <vma_create+0x22>
        vma->vm_start = vm_start;
ffffffffc02035ae:	01253423          	sd	s2,8(a0)
        vma->vm_end = vm_end;
ffffffffc02035b2:	e904                	sd	s1,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc02035b4:	ed00                	sd	s0,24(a0)
}
ffffffffc02035b6:	60e2                	ld	ra,24(sp)
ffffffffc02035b8:	6442                	ld	s0,16(sp)
ffffffffc02035ba:	64a2                	ld	s1,8(sp)
ffffffffc02035bc:	6902                	ld	s2,0(sp)
ffffffffc02035be:	6105                	addi	sp,sp,32
ffffffffc02035c0:	8082                	ret

ffffffffc02035c2 <find_vma>:
{
ffffffffc02035c2:	86aa                	mv	a3,a0
    if (mm != NULL)
ffffffffc02035c4:	c505                	beqz	a0,ffffffffc02035ec <find_vma+0x2a>
        vma = mm->mmap_cache;
ffffffffc02035c6:	6908                	ld	a0,16(a0)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr))
ffffffffc02035c8:	c501                	beqz	a0,ffffffffc02035d0 <find_vma+0xe>
ffffffffc02035ca:	651c                	ld	a5,8(a0)
ffffffffc02035cc:	02f5f263          	bgeu	a1,a5,ffffffffc02035f0 <find_vma+0x2e>
    return listelm->next;
ffffffffc02035d0:	669c                	ld	a5,8(a3)
            while ((le = list_next(le)) != list)
ffffffffc02035d2:	00f68d63          	beq	a3,a5,ffffffffc02035ec <find_vma+0x2a>
                if (vma->vm_start <= addr && addr < vma->vm_end)
ffffffffc02035d6:	fe87b703          	ld	a4,-24(a5)
ffffffffc02035da:	00e5e663          	bltu	a1,a4,ffffffffc02035e6 <find_vma+0x24>
ffffffffc02035de:	ff07b703          	ld	a4,-16(a5)
ffffffffc02035e2:	00e5ec63          	bltu	a1,a4,ffffffffc02035fa <find_vma+0x38>
ffffffffc02035e6:	679c                	ld	a5,8(a5)
            while ((le = list_next(le)) != list)
ffffffffc02035e8:	fef697e3          	bne	a3,a5,ffffffffc02035d6 <find_vma+0x14>
    struct vma_struct *vma = NULL;
ffffffffc02035ec:	4501                	li	a0,0
}
ffffffffc02035ee:	8082                	ret
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr))
ffffffffc02035f0:	691c                	ld	a5,16(a0)
ffffffffc02035f2:	fcf5ffe3          	bgeu	a1,a5,ffffffffc02035d0 <find_vma+0xe>
            mm->mmap_cache = vma;
ffffffffc02035f6:	ea88                	sd	a0,16(a3)
ffffffffc02035f8:	8082                	ret
                vma = le2vma(le, list_link);
ffffffffc02035fa:	fe078513          	addi	a0,a5,-32
            mm->mmap_cache = vma;
ffffffffc02035fe:	ea88                	sd	a0,16(a3)
ffffffffc0203600:	8082                	ret

ffffffffc0203602 <insert_vma_struct>:
}

// insert_vma_struct -insert vma in mm's list link
void insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma)
{
    assert(vma->vm_start < vma->vm_end);
ffffffffc0203602:	6590                	ld	a2,8(a1)
ffffffffc0203604:	0105b803          	ld	a6,16(a1)
{
ffffffffc0203608:	1141                	addi	sp,sp,-16
ffffffffc020360a:	e406                	sd	ra,8(sp)
ffffffffc020360c:	87aa                	mv	a5,a0
    assert(vma->vm_start < vma->vm_end);
ffffffffc020360e:	01066763          	bltu	a2,a6,ffffffffc020361c <insert_vma_struct+0x1a>
ffffffffc0203612:	a085                	j	ffffffffc0203672 <insert_vma_struct+0x70>

    list_entry_t *le = list;
    while ((le = list_next(le)) != list)
    {
        struct vma_struct *mmap_prev = le2vma(le, list_link);
        if (mmap_prev->vm_start > vma->vm_start)
ffffffffc0203614:	fe87b703          	ld	a4,-24(a5)
ffffffffc0203618:	04e66863          	bltu	a2,a4,ffffffffc0203668 <insert_vma_struct+0x66>
ffffffffc020361c:	86be                	mv	a3,a5
ffffffffc020361e:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != list)
ffffffffc0203620:	fef51ae3          	bne	a0,a5,ffffffffc0203614 <insert_vma_struct+0x12>
    }

    le_next = list_next(le_prev);

    /* check overlap */
    if (le_prev != list)
ffffffffc0203624:	02a68463          	beq	a3,a0,ffffffffc020364c <insert_vma_struct+0x4a>
    {
        check_vma_overlap(le2vma(le_prev, list_link), vma);
ffffffffc0203628:	ff06b703          	ld	a4,-16(a3)
    assert(prev->vm_start < prev->vm_end);
ffffffffc020362c:	fe86b883          	ld	a7,-24(a3)
ffffffffc0203630:	08e8f163          	bgeu	a7,a4,ffffffffc02036b2 <insert_vma_struct+0xb0>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0203634:	04e66f63          	bltu	a2,a4,ffffffffc0203692 <insert_vma_struct+0x90>
    }
    if (le_next != list)
ffffffffc0203638:	00f50a63          	beq	a0,a5,ffffffffc020364c <insert_vma_struct+0x4a>
        if (mmap_prev->vm_start > vma->vm_start)
ffffffffc020363c:	fe87b703          	ld	a4,-24(a5)
    assert(prev->vm_end <= next->vm_start);
ffffffffc0203640:	05076963          	bltu	a4,a6,ffffffffc0203692 <insert_vma_struct+0x90>
    assert(next->vm_start < next->vm_end);
ffffffffc0203644:	ff07b603          	ld	a2,-16(a5)
ffffffffc0203648:	02c77363          	bgeu	a4,a2,ffffffffc020366e <insert_vma_struct+0x6c>
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count++;
ffffffffc020364c:	5118                	lw	a4,32(a0)
    vma->vm_mm = mm;
ffffffffc020364e:	e188                	sd	a0,0(a1)
    list_add_after(le_prev, &(vma->list_link));
ffffffffc0203650:	02058613          	addi	a2,a1,32
    prev->next = next->prev = elm;
ffffffffc0203654:	e390                	sd	a2,0(a5)
ffffffffc0203656:	e690                	sd	a2,8(a3)
}
ffffffffc0203658:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc020365a:	f59c                	sd	a5,40(a1)
    elm->prev = prev;
ffffffffc020365c:	f194                	sd	a3,32(a1)
    mm->map_count++;
ffffffffc020365e:	0017079b          	addiw	a5,a4,1
ffffffffc0203662:	d11c                	sw	a5,32(a0)
}
ffffffffc0203664:	0141                	addi	sp,sp,16
ffffffffc0203666:	8082                	ret
    if (le_prev != list)
ffffffffc0203668:	fca690e3          	bne	a3,a0,ffffffffc0203628 <insert_vma_struct+0x26>
ffffffffc020366c:	bfd1                	j	ffffffffc0203640 <insert_vma_struct+0x3e>
ffffffffc020366e:	ebbff0ef          	jal	ra,ffffffffc0203528 <check_vma_overlap.part.0>
    assert(vma->vm_start < vma->vm_end);
ffffffffc0203672:	00002697          	auipc	a3,0x2
ffffffffc0203676:	7b668693          	addi	a3,a3,1974 # ffffffffc0205e28 <default_pmm_manager+0xc80>
ffffffffc020367a:	00001617          	auipc	a2,0x1
ffffffffc020367e:	77e60613          	addi	a2,a2,1918 # ffffffffc0204df8 <commands+0x738>
ffffffffc0203682:	09200593          	li	a1,146
ffffffffc0203686:	00002517          	auipc	a0,0x2
ffffffffc020368a:	79250513          	addi	a0,a0,1938 # ffffffffc0205e18 <default_pmm_manager+0xc70>
ffffffffc020368e:	ce7fc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0203692:	00002697          	auipc	a3,0x2
ffffffffc0203696:	7d668693          	addi	a3,a3,2006 # ffffffffc0205e68 <default_pmm_manager+0xcc0>
ffffffffc020369a:	00001617          	auipc	a2,0x1
ffffffffc020369e:	75e60613          	addi	a2,a2,1886 # ffffffffc0204df8 <commands+0x738>
ffffffffc02036a2:	08b00593          	li	a1,139
ffffffffc02036a6:	00002517          	auipc	a0,0x2
ffffffffc02036aa:	77250513          	addi	a0,a0,1906 # ffffffffc0205e18 <default_pmm_manager+0xc70>
ffffffffc02036ae:	cc7fc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc02036b2:	00002697          	auipc	a3,0x2
ffffffffc02036b6:	79668693          	addi	a3,a3,1942 # ffffffffc0205e48 <default_pmm_manager+0xca0>
ffffffffc02036ba:	00001617          	auipc	a2,0x1
ffffffffc02036be:	73e60613          	addi	a2,a2,1854 # ffffffffc0204df8 <commands+0x738>
ffffffffc02036c2:	08a00593          	li	a1,138
ffffffffc02036c6:	00002517          	auipc	a0,0x2
ffffffffc02036ca:	75250513          	addi	a0,a0,1874 # ffffffffc0205e18 <default_pmm_manager+0xc70>
ffffffffc02036ce:	ca7fc0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc02036d2 <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void mm_destroy(struct mm_struct *mm)
{
ffffffffc02036d2:	1141                	addi	sp,sp,-16
ffffffffc02036d4:	e022                	sd	s0,0(sp)
ffffffffc02036d6:	842a                	mv	s0,a0
    return listelm->next;
ffffffffc02036d8:	6508                	ld	a0,8(a0)
ffffffffc02036da:	e406                	sd	ra,8(sp)

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list)
ffffffffc02036dc:	00a40e63          	beq	s0,a0,ffffffffc02036f8 <mm_destroy+0x26>
    __list_del(listelm->prev, listelm->next);
ffffffffc02036e0:	6118                	ld	a4,0(a0)
ffffffffc02036e2:	651c                	ld	a5,8(a0)
    {
        list_del(le);
        kfree(le2vma(le, list_link), sizeof(struct vma_struct)); // kfree vma
ffffffffc02036e4:	03000593          	li	a1,48
ffffffffc02036e8:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc02036ea:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc02036ec:	e398                	sd	a4,0(a5)
ffffffffc02036ee:	944ff0ef          	jal	ra,ffffffffc0202832 <kfree>
    return listelm->next;
ffffffffc02036f2:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list)
ffffffffc02036f4:	fea416e3          	bne	s0,a0,ffffffffc02036e0 <mm_destroy+0xe>
    }
    kfree(mm, sizeof(struct mm_struct)); // kfree mm
ffffffffc02036f8:	8522                	mv	a0,s0
    mm = NULL;
}
ffffffffc02036fa:	6402                	ld	s0,0(sp)
ffffffffc02036fc:	60a2                	ld	ra,8(sp)
    kfree(mm, sizeof(struct mm_struct)); // kfree mm
ffffffffc02036fe:	03000593          	li	a1,48
}
ffffffffc0203702:	0141                	addi	sp,sp,16
    kfree(mm, sizeof(struct mm_struct)); // kfree mm
ffffffffc0203704:	92eff06f          	j	ffffffffc0202832 <kfree>

ffffffffc0203708 <vmm_init>:

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void vmm_init(void)
{
ffffffffc0203708:	715d                	addi	sp,sp,-80
ffffffffc020370a:	e486                	sd	ra,72(sp)
ffffffffc020370c:	f44e                	sd	s3,40(sp)
ffffffffc020370e:	f052                	sd	s4,32(sp)
ffffffffc0203710:	e0a2                	sd	s0,64(sp)
ffffffffc0203712:	fc26                	sd	s1,56(sp)
ffffffffc0203714:	f84a                	sd	s2,48(sp)
ffffffffc0203716:	ec56                	sd	s5,24(sp)
ffffffffc0203718:	e85a                	sd	s6,16(sp)
ffffffffc020371a:	e45e                	sd	s7,8(sp)

// check_vmm - check correctness of vmm
static void
check_vmm(void)
{
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc020371c:	f77fd0ef          	jal	ra,ffffffffc0201692 <nr_free_pages>
ffffffffc0203720:	89aa                	mv	s3,a0
}

static void
check_vma_struct(void)
{
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0203722:	f71fd0ef          	jal	ra,ffffffffc0201692 <nr_free_pages>
ffffffffc0203726:	8a2a                	mv	s4,a0
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0203728:	03000513          	li	a0,48
ffffffffc020372c:	84cff0ef          	jal	ra,ffffffffc0202778 <kmalloc>
    if (mm != NULL)
ffffffffc0203730:	56050863          	beqz	a0,ffffffffc0203ca0 <vmm_init+0x598>
    elm->prev = elm->next = elm;
ffffffffc0203734:	e508                	sd	a0,8(a0)
ffffffffc0203736:	e108                	sd	a0,0(a0)
        mm->mmap_cache = NULL;
ffffffffc0203738:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc020373c:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc0203740:	02052023          	sw	zero,32(a0)
        if (swap_init_ok)
ffffffffc0203744:	0000e797          	auipc	a5,0xe
ffffffffc0203748:	e0c7a783          	lw	a5,-500(a5) # ffffffffc0211550 <swap_init_ok>
ffffffffc020374c:	84aa                	mv	s1,a0
ffffffffc020374e:	e7b9                	bnez	a5,ffffffffc020379c <vmm_init+0x94>
            mm->sm_priv = NULL;
ffffffffc0203750:	02053423          	sd	zero,40(a0)
{
ffffffffc0203754:	03200413          	li	s0,50
ffffffffc0203758:	a811                	j	ffffffffc020376c <vmm_init+0x64>
        vma->vm_start = vm_start;
ffffffffc020375a:	e500                	sd	s0,8(a0)
        vma->vm_end = vm_end;
ffffffffc020375c:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc020375e:	00053c23          	sd	zero,24(a0)
    assert(mm != NULL);

    int step1 = 10, step2 = step1 * 10;

    int i;
    for (i = step1; i >= 1; i--)
ffffffffc0203762:	146d                	addi	s0,s0,-5
    {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0203764:	8526                	mv	a0,s1
ffffffffc0203766:	e9dff0ef          	jal	ra,ffffffffc0203602 <insert_vma_struct>
    for (i = step1; i >= 1; i--)
ffffffffc020376a:	cc05                	beqz	s0,ffffffffc02037a2 <vmm_init+0x9a>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc020376c:	03000513          	li	a0,48
ffffffffc0203770:	808ff0ef          	jal	ra,ffffffffc0202778 <kmalloc>
ffffffffc0203774:	85aa                	mv	a1,a0
ffffffffc0203776:	00240793          	addi	a5,s0,2
    if (vma != NULL)
ffffffffc020377a:	f165                	bnez	a0,ffffffffc020375a <vmm_init+0x52>
        assert(vma != NULL);
ffffffffc020377c:	00002697          	auipc	a3,0x2
ffffffffc0203780:	15c68693          	addi	a3,a3,348 # ffffffffc02058d8 <default_pmm_manager+0x730>
ffffffffc0203784:	00001617          	auipc	a2,0x1
ffffffffc0203788:	67460613          	addi	a2,a2,1652 # ffffffffc0204df8 <commands+0x738>
ffffffffc020378c:	0e400593          	li	a1,228
ffffffffc0203790:	00002517          	auipc	a0,0x2
ffffffffc0203794:	68850513          	addi	a0,a0,1672 # ffffffffc0205e18 <default_pmm_manager+0xc70>
ffffffffc0203798:	bddfc0ef          	jal	ra,ffffffffc0200374 <__panic>
            swap_init_mm(mm);
ffffffffc020379c:	fe8ff0ef          	jal	ra,ffffffffc0202f84 <swap_init_mm>
ffffffffc02037a0:	bf55                	j	ffffffffc0203754 <vmm_init+0x4c>
ffffffffc02037a2:	03700413          	li	s0,55
    }

    for (i = step1 + 1; i <= step2; i++)
ffffffffc02037a6:	1f900913          	li	s2,505
ffffffffc02037aa:	a819                	j	ffffffffc02037c0 <vmm_init+0xb8>
        vma->vm_start = vm_start;
ffffffffc02037ac:	e500                	sd	s0,8(a0)
        vma->vm_end = vm_end;
ffffffffc02037ae:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc02037b0:	00053c23          	sd	zero,24(a0)
    for (i = step1 + 1; i <= step2; i++)
ffffffffc02037b4:	0415                	addi	s0,s0,5
    {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc02037b6:	8526                	mv	a0,s1
ffffffffc02037b8:	e4bff0ef          	jal	ra,ffffffffc0203602 <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i++)
ffffffffc02037bc:	03240a63          	beq	s0,s2,ffffffffc02037f0 <vmm_init+0xe8>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02037c0:	03000513          	li	a0,48
ffffffffc02037c4:	fb5fe0ef          	jal	ra,ffffffffc0202778 <kmalloc>
ffffffffc02037c8:	85aa                	mv	a1,a0
ffffffffc02037ca:	00240793          	addi	a5,s0,2
    if (vma != NULL)
ffffffffc02037ce:	fd79                	bnez	a0,ffffffffc02037ac <vmm_init+0xa4>
        assert(vma != NULL);
ffffffffc02037d0:	00002697          	auipc	a3,0x2
ffffffffc02037d4:	10868693          	addi	a3,a3,264 # ffffffffc02058d8 <default_pmm_manager+0x730>
ffffffffc02037d8:	00001617          	auipc	a2,0x1
ffffffffc02037dc:	62060613          	addi	a2,a2,1568 # ffffffffc0204df8 <commands+0x738>
ffffffffc02037e0:	0eb00593          	li	a1,235
ffffffffc02037e4:	00002517          	auipc	a0,0x2
ffffffffc02037e8:	63450513          	addi	a0,a0,1588 # ffffffffc0205e18 <default_pmm_manager+0xc70>
ffffffffc02037ec:	b89fc0ef          	jal	ra,ffffffffc0200374 <__panic>
    return listelm->next;
ffffffffc02037f0:	649c                	ld	a5,8(s1)
ffffffffc02037f2:	471d                	li	a4,7
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i++)
ffffffffc02037f4:	1fb00593          	li	a1,507
    {
        assert(le != &(mm->mmap_list));
ffffffffc02037f8:	2ef48463          	beq	s1,a5,ffffffffc0203ae0 <vmm_init+0x3d8>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc02037fc:	fe87b603          	ld	a2,-24(a5)
ffffffffc0203800:	ffe70693          	addi	a3,a4,-2
ffffffffc0203804:	26d61e63          	bne	a2,a3,ffffffffc0203a80 <vmm_init+0x378>
ffffffffc0203808:	ff07b683          	ld	a3,-16(a5)
ffffffffc020380c:	26e69a63          	bne	a3,a4,ffffffffc0203a80 <vmm_init+0x378>
    for (i = 1; i <= step2; i++)
ffffffffc0203810:	0715                	addi	a4,a4,5
ffffffffc0203812:	679c                	ld	a5,8(a5)
ffffffffc0203814:	feb712e3          	bne	a4,a1,ffffffffc02037f8 <vmm_init+0xf0>
ffffffffc0203818:	4b1d                	li	s6,7
ffffffffc020381a:	4415                	li	s0,5
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i += 5)
ffffffffc020381c:	1f900b93          	li	s7,505
    {
        struct vma_struct *vma1 = find_vma(mm, i);
ffffffffc0203820:	85a2                	mv	a1,s0
ffffffffc0203822:	8526                	mv	a0,s1
ffffffffc0203824:	d9fff0ef          	jal	ra,ffffffffc02035c2 <find_vma>
ffffffffc0203828:	892a                	mv	s2,a0
        assert(vma1 != NULL);
ffffffffc020382a:	2c050b63          	beqz	a0,ffffffffc0203b00 <vmm_init+0x3f8>
        struct vma_struct *vma2 = find_vma(mm, i + 1);
ffffffffc020382e:	00140593          	addi	a1,s0,1
ffffffffc0203832:	8526                	mv	a0,s1
ffffffffc0203834:	d8fff0ef          	jal	ra,ffffffffc02035c2 <find_vma>
ffffffffc0203838:	8aaa                	mv	s5,a0
        assert(vma2 != NULL);
ffffffffc020383a:	2e050363          	beqz	a0,ffffffffc0203b20 <vmm_init+0x418>
        struct vma_struct *vma3 = find_vma(mm, i + 2);
ffffffffc020383e:	85da                	mv	a1,s6
ffffffffc0203840:	8526                	mv	a0,s1
ffffffffc0203842:	d81ff0ef          	jal	ra,ffffffffc02035c2 <find_vma>
        assert(vma3 == NULL);
ffffffffc0203846:	2e051d63          	bnez	a0,ffffffffc0203b40 <vmm_init+0x438>
        struct vma_struct *vma4 = find_vma(mm, i + 3);
ffffffffc020384a:	00340593          	addi	a1,s0,3
ffffffffc020384e:	8526                	mv	a0,s1
ffffffffc0203850:	d73ff0ef          	jal	ra,ffffffffc02035c2 <find_vma>
        assert(vma4 == NULL);
ffffffffc0203854:	30051663          	bnez	a0,ffffffffc0203b60 <vmm_init+0x458>
        struct vma_struct *vma5 = find_vma(mm, i + 4);
ffffffffc0203858:	00440593          	addi	a1,s0,4
ffffffffc020385c:	8526                	mv	a0,s1
ffffffffc020385e:	d65ff0ef          	jal	ra,ffffffffc02035c2 <find_vma>
        assert(vma5 == NULL);
ffffffffc0203862:	30051f63          	bnez	a0,ffffffffc0203b80 <vmm_init+0x478>

        assert(vma1->vm_start == i && vma1->vm_end == i + 2);
ffffffffc0203866:	00893783          	ld	a5,8(s2)
ffffffffc020386a:	24879b63          	bne	a5,s0,ffffffffc0203ac0 <vmm_init+0x3b8>
ffffffffc020386e:	01093783          	ld	a5,16(s2)
ffffffffc0203872:	25679763          	bne	a5,s6,ffffffffc0203ac0 <vmm_init+0x3b8>
        assert(vma2->vm_start == i && vma2->vm_end == i + 2);
ffffffffc0203876:	008ab783          	ld	a5,8(s5)
ffffffffc020387a:	22879363          	bne	a5,s0,ffffffffc0203aa0 <vmm_init+0x398>
ffffffffc020387e:	010ab783          	ld	a5,16(s5)
ffffffffc0203882:	21679f63          	bne	a5,s6,ffffffffc0203aa0 <vmm_init+0x398>
    for (i = 5; i <= 5 * step2; i += 5)
ffffffffc0203886:	0415                	addi	s0,s0,5
ffffffffc0203888:	0b15                	addi	s6,s6,5
ffffffffc020388a:	f9741be3          	bne	s0,s7,ffffffffc0203820 <vmm_init+0x118>
ffffffffc020388e:	4411                	li	s0,4
    }

    for (i = 4; i >= 0; i--)
ffffffffc0203890:	597d                	li	s2,-1
    {
        struct vma_struct *vma_below_5 = find_vma(mm, i);
ffffffffc0203892:	85a2                	mv	a1,s0
ffffffffc0203894:	8526                	mv	a0,s1
ffffffffc0203896:	d2dff0ef          	jal	ra,ffffffffc02035c2 <find_vma>
ffffffffc020389a:	0004059b          	sext.w	a1,s0
        if (vma_below_5 != NULL)
ffffffffc020389e:	c90d                	beqz	a0,ffffffffc02038d0 <vmm_init+0x1c8>
        {
            cprintf("vma_below_5: i %x, start %x, end %x\n", i, vma_below_5->vm_start, vma_below_5->vm_end);
ffffffffc02038a0:	6914                	ld	a3,16(a0)
ffffffffc02038a2:	6510                	ld	a2,8(a0)
ffffffffc02038a4:	00002517          	auipc	a0,0x2
ffffffffc02038a8:	6e450513          	addi	a0,a0,1764 # ffffffffc0205f88 <default_pmm_manager+0xde0>
ffffffffc02038ac:	80ffc0ef          	jal	ra,ffffffffc02000ba <cprintf>
        }
        assert(vma_below_5 == NULL);
ffffffffc02038b0:	00002697          	auipc	a3,0x2
ffffffffc02038b4:	70068693          	addi	a3,a3,1792 # ffffffffc0205fb0 <default_pmm_manager+0xe08>
ffffffffc02038b8:	00001617          	auipc	a2,0x1
ffffffffc02038bc:	54060613          	addi	a2,a2,1344 # ffffffffc0204df8 <commands+0x738>
ffffffffc02038c0:	11100593          	li	a1,273
ffffffffc02038c4:	00002517          	auipc	a0,0x2
ffffffffc02038c8:	55450513          	addi	a0,a0,1364 # ffffffffc0205e18 <default_pmm_manager+0xc70>
ffffffffc02038cc:	aa9fc0ef          	jal	ra,ffffffffc0200374 <__panic>
    for (i = 4; i >= 0; i--)
ffffffffc02038d0:	147d                	addi	s0,s0,-1
ffffffffc02038d2:	fd2410e3          	bne	s0,s2,ffffffffc0203892 <vmm_init+0x18a>
ffffffffc02038d6:	a811                	j	ffffffffc02038ea <vmm_init+0x1e2>
    __list_del(listelm->prev, listelm->next);
ffffffffc02038d8:	6118                	ld	a4,0(a0)
ffffffffc02038da:	651c                	ld	a5,8(a0)
        kfree(le2vma(le, list_link), sizeof(struct vma_struct)); // kfree vma
ffffffffc02038dc:	03000593          	li	a1,48
ffffffffc02038e0:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc02038e2:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc02038e4:	e398                	sd	a4,0(a5)
ffffffffc02038e6:	f4dfe0ef          	jal	ra,ffffffffc0202832 <kfree>
    return listelm->next;
ffffffffc02038ea:	6488                	ld	a0,8(s1)
    while ((le = list_next(list)) != list)
ffffffffc02038ec:	fea496e3          	bne	s1,a0,ffffffffc02038d8 <vmm_init+0x1d0>
    kfree(mm, sizeof(struct mm_struct)); // kfree mm
ffffffffc02038f0:	03000593          	li	a1,48
ffffffffc02038f4:	8526                	mv	a0,s1
ffffffffc02038f6:	f3dfe0ef          	jal	ra,ffffffffc0202832 <kfree>
    }

    mm_destroy(mm);

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc02038fa:	d99fd0ef          	jal	ra,ffffffffc0201692 <nr_free_pages>
ffffffffc02038fe:	3caa1163          	bne	s4,a0,ffffffffc0203cc0 <vmm_init+0x5b8>

    cprintf("check_vma_struct() succeeded!\n");
ffffffffc0203902:	00002517          	auipc	a0,0x2
ffffffffc0203906:	6ee50513          	addi	a0,a0,1774 # ffffffffc0205ff0 <default_pmm_manager+0xe48>
ffffffffc020390a:	fb0fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void)
{
    // char *name = "check_pgfault";
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc020390e:	d85fd0ef          	jal	ra,ffffffffc0201692 <nr_free_pages>
ffffffffc0203912:	84aa                	mv	s1,a0
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0203914:	03000513          	li	a0,48
ffffffffc0203918:	e61fe0ef          	jal	ra,ffffffffc0202778 <kmalloc>
ffffffffc020391c:	842a                	mv	s0,a0
    if (mm != NULL)
ffffffffc020391e:	2a050163          	beqz	a0,ffffffffc0203bc0 <vmm_init+0x4b8>
        if (swap_init_ok)
ffffffffc0203922:	0000e797          	auipc	a5,0xe
ffffffffc0203926:	c2e7a783          	lw	a5,-978(a5) # ffffffffc0211550 <swap_init_ok>
    elm->prev = elm->next = elm;
ffffffffc020392a:	e508                	sd	a0,8(a0)
ffffffffc020392c:	e108                	sd	a0,0(a0)
        mm->mmap_cache = NULL;
ffffffffc020392e:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc0203932:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc0203936:	02052023          	sw	zero,32(a0)
        if (swap_init_ok)
ffffffffc020393a:	14079063          	bnez	a5,ffffffffc0203a7a <vmm_init+0x372>
            mm->sm_priv = NULL;
ffffffffc020393e:	02053423          	sd	zero,40(a0)

    check_mm_struct = mm_create();

    assert(check_mm_struct != NULL);
    struct mm_struct *mm = check_mm_struct;
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0203942:	0000e917          	auipc	s2,0xe
ffffffffc0203946:	bd693903          	ld	s2,-1066(s2) # ffffffffc0211518 <boot_pgdir>
    assert(pgdir[0] == 0);
ffffffffc020394a:	00093783          	ld	a5,0(s2)
    check_mm_struct = mm_create();
ffffffffc020394e:	0000e717          	auipc	a4,0xe
ffffffffc0203952:	c0873523          	sd	s0,-1014(a4) # ffffffffc0211558 <check_mm_struct>
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0203956:	01243c23          	sd	s2,24(s0)
    assert(pgdir[0] == 0);
ffffffffc020395a:	24079363          	bnez	a5,ffffffffc0203ba0 <vmm_init+0x498>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc020395e:	03000513          	li	a0,48
ffffffffc0203962:	e17fe0ef          	jal	ra,ffffffffc0202778 <kmalloc>
ffffffffc0203966:	8a2a                	mv	s4,a0
    if (vma != NULL)
ffffffffc0203968:	28050063          	beqz	a0,ffffffffc0203be8 <vmm_init+0x4e0>
        vma->vm_end = vm_end;
ffffffffc020396c:	002007b7          	lui	a5,0x200
ffffffffc0203970:	00fa3823          	sd	a5,16(s4)
        vma->vm_flags = vm_flags;
ffffffffc0203974:	4789                	li	a5,2

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);

    assert(vma != NULL);

    insert_vma_struct(mm, vma);
ffffffffc0203976:	85aa                	mv	a1,a0
        vma->vm_flags = vm_flags;
ffffffffc0203978:	00fa3c23          	sd	a5,24(s4)
    insert_vma_struct(mm, vma);
ffffffffc020397c:	8522                	mv	a0,s0
        vma->vm_start = vm_start;
ffffffffc020397e:	000a3423          	sd	zero,8(s4)
    insert_vma_struct(mm, vma);
ffffffffc0203982:	c81ff0ef          	jal	ra,ffffffffc0203602 <insert_vma_struct>

    uintptr_t addr = 0x100;
    assert(find_vma(mm, addr) == vma);
ffffffffc0203986:	10000593          	li	a1,256
ffffffffc020398a:	8522                	mv	a0,s0
ffffffffc020398c:	c37ff0ef          	jal	ra,ffffffffc02035c2 <find_vma>
ffffffffc0203990:	10000793          	li	a5,256

    int i, sum = 0;
    for (i = 0; i < 100; i++)
ffffffffc0203994:	16400713          	li	a4,356
    assert(find_vma(mm, addr) == vma);
ffffffffc0203998:	26aa1863          	bne	s4,a0,ffffffffc0203c08 <vmm_init+0x500>
    {
        *(char *)(addr + i) = i;
ffffffffc020399c:	00f78023          	sb	a5,0(a5) # 200000 <kern_entry-0xffffffffc0000000>
    for (i = 0; i < 100; i++)
ffffffffc02039a0:	0785                	addi	a5,a5,1
ffffffffc02039a2:	fee79de3          	bne	a5,a4,ffffffffc020399c <vmm_init+0x294>
        sum += i;
ffffffffc02039a6:	6705                	lui	a4,0x1
ffffffffc02039a8:	10000793          	li	a5,256
ffffffffc02039ac:	35670713          	addi	a4,a4,854 # 1356 <kern_entry-0xffffffffc01fecaa>
    }
    for (i = 0; i < 100; i++)
ffffffffc02039b0:	16400613          	li	a2,356
    {
        sum -= *(char *)(addr + i);
ffffffffc02039b4:	0007c683          	lbu	a3,0(a5)
    for (i = 0; i < 100; i++)
ffffffffc02039b8:	0785                	addi	a5,a5,1
        sum -= *(char *)(addr + i);
ffffffffc02039ba:	9f15                	subw	a4,a4,a3
    for (i = 0; i < 100; i++)
ffffffffc02039bc:	fec79ce3          	bne	a5,a2,ffffffffc02039b4 <vmm_init+0x2ac>
    }
    assert(sum == 0);
ffffffffc02039c0:	26071463          	bnez	a4,ffffffffc0203c28 <vmm_init+0x520>

    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
ffffffffc02039c4:	4581                	li	a1,0
ffffffffc02039c6:	854a                	mv	a0,s2
ffffffffc02039c8:	f55fd0ef          	jal	ra,ffffffffc020191c <page_remove>
    return pa2page(PDE_ADDR(pde));
ffffffffc02039cc:	00093783          	ld	a5,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc02039d0:	0000e717          	auipc	a4,0xe
ffffffffc02039d4:	b5073703          	ld	a4,-1200(a4) # ffffffffc0211520 <npage>
    return pa2page(PDE_ADDR(pde));
ffffffffc02039d8:	078a                	slli	a5,a5,0x2
ffffffffc02039da:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02039dc:	26e7f663          	bgeu	a5,a4,ffffffffc0203c48 <vmm_init+0x540>
    return &pages[PPN(pa) - nbase];
ffffffffc02039e0:	00003717          	auipc	a4,0x3
ffffffffc02039e4:	9d873703          	ld	a4,-1576(a4) # ffffffffc02063b8 <nbase>
ffffffffc02039e8:	8f99                	sub	a5,a5,a4
ffffffffc02039ea:	00379713          	slli	a4,a5,0x3
ffffffffc02039ee:	97ba                	add	a5,a5,a4
ffffffffc02039f0:	078e                	slli	a5,a5,0x3

    free_page(pde2page(pgdir[0]));
ffffffffc02039f2:	0000e517          	auipc	a0,0xe
ffffffffc02039f6:	b3653503          	ld	a0,-1226(a0) # ffffffffc0211528 <pages>
ffffffffc02039fa:	953e                	add	a0,a0,a5
ffffffffc02039fc:	4585                	li	a1,1
ffffffffc02039fe:	c55fd0ef          	jal	ra,ffffffffc0201652 <free_pages>
    return listelm->next;
ffffffffc0203a02:	6408                	ld	a0,8(s0)

    pgdir[0] = 0;
ffffffffc0203a04:	00093023          	sd	zero,0(s2)

    mm->pgdir = NULL;
ffffffffc0203a08:	00043c23          	sd	zero,24(s0)
    while ((le = list_next(list)) != list)
ffffffffc0203a0c:	00a40e63          	beq	s0,a0,ffffffffc0203a28 <vmm_init+0x320>
    __list_del(listelm->prev, listelm->next);
ffffffffc0203a10:	6118                	ld	a4,0(a0)
ffffffffc0203a12:	651c                	ld	a5,8(a0)
        kfree(le2vma(le, list_link), sizeof(struct vma_struct)); // kfree vma
ffffffffc0203a14:	03000593          	li	a1,48
ffffffffc0203a18:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc0203a1a:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0203a1c:	e398                	sd	a4,0(a5)
ffffffffc0203a1e:	e15fe0ef          	jal	ra,ffffffffc0202832 <kfree>
    return listelm->next;
ffffffffc0203a22:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list)
ffffffffc0203a24:	fea416e3          	bne	s0,a0,ffffffffc0203a10 <vmm_init+0x308>
    kfree(mm, sizeof(struct mm_struct)); // kfree mm
ffffffffc0203a28:	03000593          	li	a1,48
ffffffffc0203a2c:	8522                	mv	a0,s0
ffffffffc0203a2e:	e05fe0ef          	jal	ra,ffffffffc0202832 <kfree>
    mm_destroy(mm);

    check_mm_struct = NULL;
    nr_free_pages_store--; // szx : Sv39第二级页表多占了一个内存页，所以执行此操作
ffffffffc0203a32:	14fd                	addi	s1,s1,-1
    check_mm_struct = NULL;
ffffffffc0203a34:	0000e797          	auipc	a5,0xe
ffffffffc0203a38:	b207b223          	sd	zero,-1244(a5) # ffffffffc0211558 <check_mm_struct>

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203a3c:	c57fd0ef          	jal	ra,ffffffffc0201692 <nr_free_pages>
ffffffffc0203a40:	22a49063          	bne	s1,a0,ffffffffc0203c60 <vmm_init+0x558>

    cprintf("check_pgfault() succeeded!\n");
ffffffffc0203a44:	00002517          	auipc	a0,0x2
ffffffffc0203a48:	5fc50513          	addi	a0,a0,1532 # ffffffffc0206040 <default_pmm_manager+0xe98>
ffffffffc0203a4c:	e6efc0ef          	jal	ra,ffffffffc02000ba <cprintf>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203a50:	c43fd0ef          	jal	ra,ffffffffc0201692 <nr_free_pages>
    nr_free_pages_store--; // szx : Sv39三级页表多占一个内存页，所以执行此操作
ffffffffc0203a54:	19fd                	addi	s3,s3,-1
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203a56:	22a99563          	bne	s3,a0,ffffffffc0203c80 <vmm_init+0x578>
}
ffffffffc0203a5a:	6406                	ld	s0,64(sp)
ffffffffc0203a5c:	60a6                	ld	ra,72(sp)
ffffffffc0203a5e:	74e2                	ld	s1,56(sp)
ffffffffc0203a60:	7942                	ld	s2,48(sp)
ffffffffc0203a62:	79a2                	ld	s3,40(sp)
ffffffffc0203a64:	7a02                	ld	s4,32(sp)
ffffffffc0203a66:	6ae2                	ld	s5,24(sp)
ffffffffc0203a68:	6b42                	ld	s6,16(sp)
ffffffffc0203a6a:	6ba2                	ld	s7,8(sp)
    cprintf("check_vmm() succeeded.\n");
ffffffffc0203a6c:	00002517          	auipc	a0,0x2
ffffffffc0203a70:	5f450513          	addi	a0,a0,1524 # ffffffffc0206060 <default_pmm_manager+0xeb8>
}
ffffffffc0203a74:	6161                	addi	sp,sp,80
    cprintf("check_vmm() succeeded.\n");
ffffffffc0203a76:	e44fc06f          	j	ffffffffc02000ba <cprintf>
            swap_init_mm(mm);
ffffffffc0203a7a:	d0aff0ef          	jal	ra,ffffffffc0202f84 <swap_init_mm>
ffffffffc0203a7e:	b5d1                	j	ffffffffc0203942 <vmm_init+0x23a>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0203a80:	00002697          	auipc	a3,0x2
ffffffffc0203a84:	42068693          	addi	a3,a3,1056 # ffffffffc0205ea0 <default_pmm_manager+0xcf8>
ffffffffc0203a88:	00001617          	auipc	a2,0x1
ffffffffc0203a8c:	37060613          	addi	a2,a2,880 # ffffffffc0204df8 <commands+0x738>
ffffffffc0203a90:	0f500593          	li	a1,245
ffffffffc0203a94:	00002517          	auipc	a0,0x2
ffffffffc0203a98:	38450513          	addi	a0,a0,900 # ffffffffc0205e18 <default_pmm_manager+0xc70>
ffffffffc0203a9c:	8d9fc0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert(vma2->vm_start == i && vma2->vm_end == i + 2);
ffffffffc0203aa0:	00002697          	auipc	a3,0x2
ffffffffc0203aa4:	4b868693          	addi	a3,a3,1208 # ffffffffc0205f58 <default_pmm_manager+0xdb0>
ffffffffc0203aa8:	00001617          	auipc	a2,0x1
ffffffffc0203aac:	35060613          	addi	a2,a2,848 # ffffffffc0204df8 <commands+0x738>
ffffffffc0203ab0:	10700593          	li	a1,263
ffffffffc0203ab4:	00002517          	auipc	a0,0x2
ffffffffc0203ab8:	36450513          	addi	a0,a0,868 # ffffffffc0205e18 <default_pmm_manager+0xc70>
ffffffffc0203abc:	8b9fc0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert(vma1->vm_start == i && vma1->vm_end == i + 2);
ffffffffc0203ac0:	00002697          	auipc	a3,0x2
ffffffffc0203ac4:	46868693          	addi	a3,a3,1128 # ffffffffc0205f28 <default_pmm_manager+0xd80>
ffffffffc0203ac8:	00001617          	auipc	a2,0x1
ffffffffc0203acc:	33060613          	addi	a2,a2,816 # ffffffffc0204df8 <commands+0x738>
ffffffffc0203ad0:	10600593          	li	a1,262
ffffffffc0203ad4:	00002517          	auipc	a0,0x2
ffffffffc0203ad8:	34450513          	addi	a0,a0,836 # ffffffffc0205e18 <default_pmm_manager+0xc70>
ffffffffc0203adc:	899fc0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert(le != &(mm->mmap_list));
ffffffffc0203ae0:	00002697          	auipc	a3,0x2
ffffffffc0203ae4:	3a868693          	addi	a3,a3,936 # ffffffffc0205e88 <default_pmm_manager+0xce0>
ffffffffc0203ae8:	00001617          	auipc	a2,0x1
ffffffffc0203aec:	31060613          	addi	a2,a2,784 # ffffffffc0204df8 <commands+0x738>
ffffffffc0203af0:	0f300593          	li	a1,243
ffffffffc0203af4:	00002517          	auipc	a0,0x2
ffffffffc0203af8:	32450513          	addi	a0,a0,804 # ffffffffc0205e18 <default_pmm_manager+0xc70>
ffffffffc0203afc:	879fc0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert(vma1 != NULL);
ffffffffc0203b00:	00002697          	auipc	a3,0x2
ffffffffc0203b04:	3d868693          	addi	a3,a3,984 # ffffffffc0205ed8 <default_pmm_manager+0xd30>
ffffffffc0203b08:	00001617          	auipc	a2,0x1
ffffffffc0203b0c:	2f060613          	addi	a2,a2,752 # ffffffffc0204df8 <commands+0x738>
ffffffffc0203b10:	0fc00593          	li	a1,252
ffffffffc0203b14:	00002517          	auipc	a0,0x2
ffffffffc0203b18:	30450513          	addi	a0,a0,772 # ffffffffc0205e18 <default_pmm_manager+0xc70>
ffffffffc0203b1c:	859fc0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert(vma2 != NULL);
ffffffffc0203b20:	00002697          	auipc	a3,0x2
ffffffffc0203b24:	3c868693          	addi	a3,a3,968 # ffffffffc0205ee8 <default_pmm_manager+0xd40>
ffffffffc0203b28:	00001617          	auipc	a2,0x1
ffffffffc0203b2c:	2d060613          	addi	a2,a2,720 # ffffffffc0204df8 <commands+0x738>
ffffffffc0203b30:	0fe00593          	li	a1,254
ffffffffc0203b34:	00002517          	auipc	a0,0x2
ffffffffc0203b38:	2e450513          	addi	a0,a0,740 # ffffffffc0205e18 <default_pmm_manager+0xc70>
ffffffffc0203b3c:	839fc0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert(vma3 == NULL);
ffffffffc0203b40:	00002697          	auipc	a3,0x2
ffffffffc0203b44:	3b868693          	addi	a3,a3,952 # ffffffffc0205ef8 <default_pmm_manager+0xd50>
ffffffffc0203b48:	00001617          	auipc	a2,0x1
ffffffffc0203b4c:	2b060613          	addi	a2,a2,688 # ffffffffc0204df8 <commands+0x738>
ffffffffc0203b50:	10000593          	li	a1,256
ffffffffc0203b54:	00002517          	auipc	a0,0x2
ffffffffc0203b58:	2c450513          	addi	a0,a0,708 # ffffffffc0205e18 <default_pmm_manager+0xc70>
ffffffffc0203b5c:	819fc0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert(vma4 == NULL);
ffffffffc0203b60:	00002697          	auipc	a3,0x2
ffffffffc0203b64:	3a868693          	addi	a3,a3,936 # ffffffffc0205f08 <default_pmm_manager+0xd60>
ffffffffc0203b68:	00001617          	auipc	a2,0x1
ffffffffc0203b6c:	29060613          	addi	a2,a2,656 # ffffffffc0204df8 <commands+0x738>
ffffffffc0203b70:	10200593          	li	a1,258
ffffffffc0203b74:	00002517          	auipc	a0,0x2
ffffffffc0203b78:	2a450513          	addi	a0,a0,676 # ffffffffc0205e18 <default_pmm_manager+0xc70>
ffffffffc0203b7c:	ff8fc0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert(vma5 == NULL);
ffffffffc0203b80:	00002697          	auipc	a3,0x2
ffffffffc0203b84:	39868693          	addi	a3,a3,920 # ffffffffc0205f18 <default_pmm_manager+0xd70>
ffffffffc0203b88:	00001617          	auipc	a2,0x1
ffffffffc0203b8c:	27060613          	addi	a2,a2,624 # ffffffffc0204df8 <commands+0x738>
ffffffffc0203b90:	10400593          	li	a1,260
ffffffffc0203b94:	00002517          	auipc	a0,0x2
ffffffffc0203b98:	28450513          	addi	a0,a0,644 # ffffffffc0205e18 <default_pmm_manager+0xc70>
ffffffffc0203b9c:	fd8fc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgdir[0] == 0);
ffffffffc0203ba0:	00002697          	auipc	a3,0x2
ffffffffc0203ba4:	d2868693          	addi	a3,a3,-728 # ffffffffc02058c8 <default_pmm_manager+0x720>
ffffffffc0203ba8:	00001617          	auipc	a2,0x1
ffffffffc0203bac:	25060613          	addi	a2,a2,592 # ffffffffc0204df8 <commands+0x738>
ffffffffc0203bb0:	12900593          	li	a1,297
ffffffffc0203bb4:	00002517          	auipc	a0,0x2
ffffffffc0203bb8:	26450513          	addi	a0,a0,612 # ffffffffc0205e18 <default_pmm_manager+0xc70>
ffffffffc0203bbc:	fb8fc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(check_mm_struct != NULL);
ffffffffc0203bc0:	00002697          	auipc	a3,0x2
ffffffffc0203bc4:	4b868693          	addi	a3,a3,1208 # ffffffffc0206078 <default_pmm_manager+0xed0>
ffffffffc0203bc8:	00001617          	auipc	a2,0x1
ffffffffc0203bcc:	23060613          	addi	a2,a2,560 # ffffffffc0204df8 <commands+0x738>
ffffffffc0203bd0:	12600593          	li	a1,294
ffffffffc0203bd4:	00002517          	auipc	a0,0x2
ffffffffc0203bd8:	24450513          	addi	a0,a0,580 # ffffffffc0205e18 <default_pmm_manager+0xc70>
    check_mm_struct = mm_create();
ffffffffc0203bdc:	0000e797          	auipc	a5,0xe
ffffffffc0203be0:	9607be23          	sd	zero,-1668(a5) # ffffffffc0211558 <check_mm_struct>
    assert(check_mm_struct != NULL);
ffffffffc0203be4:	f90fc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(vma != NULL);
ffffffffc0203be8:	00002697          	auipc	a3,0x2
ffffffffc0203bec:	cf068693          	addi	a3,a3,-784 # ffffffffc02058d8 <default_pmm_manager+0x730>
ffffffffc0203bf0:	00001617          	auipc	a2,0x1
ffffffffc0203bf4:	20860613          	addi	a2,a2,520 # ffffffffc0204df8 <commands+0x738>
ffffffffc0203bf8:	12d00593          	li	a1,301
ffffffffc0203bfc:	00002517          	auipc	a0,0x2
ffffffffc0203c00:	21c50513          	addi	a0,a0,540 # ffffffffc0205e18 <default_pmm_manager+0xc70>
ffffffffc0203c04:	f70fc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(find_vma(mm, addr) == vma);
ffffffffc0203c08:	00002697          	auipc	a3,0x2
ffffffffc0203c0c:	40868693          	addi	a3,a3,1032 # ffffffffc0206010 <default_pmm_manager+0xe68>
ffffffffc0203c10:	00001617          	auipc	a2,0x1
ffffffffc0203c14:	1e860613          	addi	a2,a2,488 # ffffffffc0204df8 <commands+0x738>
ffffffffc0203c18:	13200593          	li	a1,306
ffffffffc0203c1c:	00002517          	auipc	a0,0x2
ffffffffc0203c20:	1fc50513          	addi	a0,a0,508 # ffffffffc0205e18 <default_pmm_manager+0xc70>
ffffffffc0203c24:	f50fc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(sum == 0);
ffffffffc0203c28:	00002697          	auipc	a3,0x2
ffffffffc0203c2c:	40868693          	addi	a3,a3,1032 # ffffffffc0206030 <default_pmm_manager+0xe88>
ffffffffc0203c30:	00001617          	auipc	a2,0x1
ffffffffc0203c34:	1c860613          	addi	a2,a2,456 # ffffffffc0204df8 <commands+0x738>
ffffffffc0203c38:	13e00593          	li	a1,318
ffffffffc0203c3c:	00002517          	auipc	a0,0x2
ffffffffc0203c40:	1dc50513          	addi	a0,a0,476 # ffffffffc0205e18 <default_pmm_manager+0xc70>
ffffffffc0203c44:	f30fc0ef          	jal	ra,ffffffffc0200374 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0203c48:	00001617          	auipc	a2,0x1
ffffffffc0203c4c:	59860613          	addi	a2,a2,1432 # ffffffffc02051e0 <default_pmm_manager+0x38>
ffffffffc0203c50:	06500593          	li	a1,101
ffffffffc0203c54:	00001517          	auipc	a0,0x1
ffffffffc0203c58:	5ac50513          	addi	a0,a0,1452 # ffffffffc0205200 <default_pmm_manager+0x58>
ffffffffc0203c5c:	f18fc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203c60:	00002697          	auipc	a3,0x2
ffffffffc0203c64:	36868693          	addi	a3,a3,872 # ffffffffc0205fc8 <default_pmm_manager+0xe20>
ffffffffc0203c68:	00001617          	auipc	a2,0x1
ffffffffc0203c6c:	19060613          	addi	a2,a2,400 # ffffffffc0204df8 <commands+0x738>
ffffffffc0203c70:	14c00593          	li	a1,332
ffffffffc0203c74:	00002517          	auipc	a0,0x2
ffffffffc0203c78:	1a450513          	addi	a0,a0,420 # ffffffffc0205e18 <default_pmm_manager+0xc70>
ffffffffc0203c7c:	ef8fc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203c80:	00002697          	auipc	a3,0x2
ffffffffc0203c84:	34868693          	addi	a3,a3,840 # ffffffffc0205fc8 <default_pmm_manager+0xe20>
ffffffffc0203c88:	00001617          	auipc	a2,0x1
ffffffffc0203c8c:	17060613          	addi	a2,a2,368 # ffffffffc0204df8 <commands+0x738>
ffffffffc0203c90:	0d100593          	li	a1,209
ffffffffc0203c94:	00002517          	auipc	a0,0x2
ffffffffc0203c98:	18450513          	addi	a0,a0,388 # ffffffffc0205e18 <default_pmm_manager+0xc70>
ffffffffc0203c9c:	ed8fc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(mm != NULL);
ffffffffc0203ca0:	00002697          	auipc	a3,0x2
ffffffffc0203ca4:	c0068693          	addi	a3,a3,-1024 # ffffffffc02058a0 <default_pmm_manager+0x6f8>
ffffffffc0203ca8:	00001617          	auipc	a2,0x1
ffffffffc0203cac:	15060613          	addi	a2,a2,336 # ffffffffc0204df8 <commands+0x738>
ffffffffc0203cb0:	0dc00593          	li	a1,220
ffffffffc0203cb4:	00002517          	auipc	a0,0x2
ffffffffc0203cb8:	16450513          	addi	a0,a0,356 # ffffffffc0205e18 <default_pmm_manager+0xc70>
ffffffffc0203cbc:	eb8fc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203cc0:	00002697          	auipc	a3,0x2
ffffffffc0203cc4:	30868693          	addi	a3,a3,776 # ffffffffc0205fc8 <default_pmm_manager+0xe20>
ffffffffc0203cc8:	00001617          	auipc	a2,0x1
ffffffffc0203ccc:	13060613          	addi	a2,a2,304 # ffffffffc0204df8 <commands+0x738>
ffffffffc0203cd0:	11600593          	li	a1,278
ffffffffc0203cd4:	00002517          	auipc	a0,0x2
ffffffffc0203cd8:	14450513          	addi	a0,a0,324 # ffffffffc0205e18 <default_pmm_manager+0xc70>
ffffffffc0203cdc:	e98fc0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0203ce0 <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr)
{
ffffffffc0203ce0:	7179                	addi	sp,sp,-48
    int ret = -E_INVAL;
    // try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc0203ce2:	85b2                	mv	a1,a2
{
ffffffffc0203ce4:	f022                	sd	s0,32(sp)
ffffffffc0203ce6:	ec26                	sd	s1,24(sp)
ffffffffc0203ce8:	f406                	sd	ra,40(sp)
ffffffffc0203cea:	e84a                	sd	s2,16(sp)
ffffffffc0203cec:	8432                	mv	s0,a2
ffffffffc0203cee:	84aa                	mv	s1,a0
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc0203cf0:	8d3ff0ef          	jal	ra,ffffffffc02035c2 <find_vma>

    pgfault_num++;
ffffffffc0203cf4:	0000e797          	auipc	a5,0xe
ffffffffc0203cf8:	86c7a783          	lw	a5,-1940(a5) # ffffffffc0211560 <pgfault_num>
ffffffffc0203cfc:	2785                	addiw	a5,a5,1
ffffffffc0203cfe:	0000e717          	auipc	a4,0xe
ffffffffc0203d02:	86f72123          	sw	a5,-1950(a4) # ffffffffc0211560 <pgfault_num>
    // If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr)
ffffffffc0203d06:	c159                	beqz	a0,ffffffffc0203d8c <do_pgfault+0xac>
ffffffffc0203d08:	651c                	ld	a5,8(a0)
ffffffffc0203d0a:	08f46163          	bltu	s0,a5,ffffffffc0203d8c <do_pgfault+0xac>
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
    if (vma->vm_flags & VM_WRITE)
ffffffffc0203d0e:	6d1c                	ld	a5,24(a0)
    uint32_t perm = PTE_U;
ffffffffc0203d10:	4941                	li	s2,16
    if (vma->vm_flags & VM_WRITE)
ffffffffc0203d12:	8b89                	andi	a5,a5,2
ffffffffc0203d14:	ebb1                	bnez	a5,ffffffffc0203d68 <do_pgfault+0x88>
    {
        perm |= (PTE_R | PTE_W);
    }
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0203d16:	75fd                	lui	a1,0xfffff
     * VARIABLES:
     *   mm->pgdir : the PDT of these vma
     *
     */

    ptep = get_pte(mm->pgdir, addr, 1); //(1) try to find a pte, if pte's
ffffffffc0203d18:	6c88                	ld	a0,24(s1)
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0203d1a:	8c6d                	and	s0,s0,a1
    ptep = get_pte(mm->pgdir, addr, 1); //(1) try to find a pte, if pte's
ffffffffc0203d1c:	85a2                	mv	a1,s0
ffffffffc0203d1e:	4605                	li	a2,1
ffffffffc0203d20:	9adfd0ef          	jal	ra,ffffffffc02016cc <get_pte>
                                        // PT(Page Table) isn't existed, then
                                        // create a PT.
    if (*ptep == 0)
ffffffffc0203d24:	610c                	ld	a1,0(a0)
ffffffffc0203d26:	c1b9                	beqz	a1,ffffffffc0203d6c <do_pgfault+0x8c>
         *    swap_in(mm, addr, &page) : 分配一个内存页，然后根据
         *    PTE中的swap条目的addr，找到磁盘页的地址，将磁盘页的内容读入这个内存页
         *    page_insert ： 建立一个Page的phy addr与线性addr la的映射
         *    swap_map_swappable ： 设置页面可交换
         */
        if (swap_init_ok)
ffffffffc0203d28:	0000e797          	auipc	a5,0xe
ffffffffc0203d2c:	8287a783          	lw	a5,-2008(a5) # ffffffffc0211550 <swap_init_ok>
ffffffffc0203d30:	c7bd                	beqz	a5,ffffffffc0203d9e <do_pgfault+0xbe>
            //(2) According to the mm,
            // addr AND page, setup the
            // map of phy addr <--->
            // logical addr
            //(3) make the page swappable.
            swap_in(mm, addr, &page);                 // 分配一个内存页并从磁盘上的交换文件加载数据到该内存页
ffffffffc0203d32:	85a2                	mv	a1,s0
ffffffffc0203d34:	0030                	addi	a2,sp,8
ffffffffc0203d36:	8526                	mv	a0,s1
            struct Page *page = NULL;
ffffffffc0203d38:	e402                	sd	zero,8(sp)
            swap_in(mm, addr, &page);                 // 分配一个内存页并从磁盘上的交换文件加载数据到该内存页
ffffffffc0203d3a:	b76ff0ef          	jal	ra,ffffffffc02030b0 <swap_in>
            page_insert(mm->pgdir, page, addr, perm); // 建立内存页 page 的物理地址和线性地址 addr 之间的映射
ffffffffc0203d3e:	65a2                	ld	a1,8(sp)
ffffffffc0203d40:	6c88                	ld	a0,24(s1)
ffffffffc0203d42:	86ca                	mv	a3,s2
ffffffffc0203d44:	8622                	mv	a2,s0
ffffffffc0203d46:	c71fd0ef          	jal	ra,ffffffffc02019b6 <page_insert>
            swap_map_swappable(mm, addr, page, 1);    // 将页面标记为可交换
ffffffffc0203d4a:	6622                	ld	a2,8(sp)
ffffffffc0203d4c:	4685                	li	a3,1
ffffffffc0203d4e:	85a2                	mv	a1,s0
ffffffffc0203d50:	8526                	mv	a0,s1
ffffffffc0203d52:	a3eff0ef          	jal	ra,ffffffffc0202f90 <swap_map_swappable>
            page->pra_vaddr = addr;                   // 跟踪页面映射的线性地址
ffffffffc0203d56:	67a2                	ld	a5,8(sp)
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
            goto failed;
        }
    }

    ret = 0;
ffffffffc0203d58:	4501                	li	a0,0
            page->pra_vaddr = addr;                   // 跟踪页面映射的线性地址
ffffffffc0203d5a:	e3a0                	sd	s0,64(a5)
failed:
    return ret;
}
ffffffffc0203d5c:	70a2                	ld	ra,40(sp)
ffffffffc0203d5e:	7402                	ld	s0,32(sp)
ffffffffc0203d60:	64e2                	ld	s1,24(sp)
ffffffffc0203d62:	6942                	ld	s2,16(sp)
ffffffffc0203d64:	6145                	addi	sp,sp,48
ffffffffc0203d66:	8082                	ret
        perm |= (PTE_R | PTE_W);
ffffffffc0203d68:	4959                	li	s2,22
ffffffffc0203d6a:	b775                	j	ffffffffc0203d16 <do_pgfault+0x36>
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL)
ffffffffc0203d6c:	6c88                	ld	a0,24(s1)
ffffffffc0203d6e:	864a                	mv	a2,s2
ffffffffc0203d70:	85a2                	mv	a1,s0
ffffffffc0203d72:	94ffe0ef          	jal	ra,ffffffffc02026c0 <pgdir_alloc_page>
ffffffffc0203d76:	87aa                	mv	a5,a0
    ret = 0;
ffffffffc0203d78:	4501                	li	a0,0
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL)
ffffffffc0203d7a:	f3ed                	bnez	a5,ffffffffc0203d5c <do_pgfault+0x7c>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
ffffffffc0203d7c:	00002517          	auipc	a0,0x2
ffffffffc0203d80:	34450513          	addi	a0,a0,836 # ffffffffc02060c0 <default_pmm_manager+0xf18>
ffffffffc0203d84:	b36fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
    ret = -E_NO_MEM;
ffffffffc0203d88:	5571                	li	a0,-4
            goto failed;
ffffffffc0203d8a:	bfc9                	j	ffffffffc0203d5c <do_pgfault+0x7c>
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
ffffffffc0203d8c:	85a2                	mv	a1,s0
ffffffffc0203d8e:	00002517          	auipc	a0,0x2
ffffffffc0203d92:	30250513          	addi	a0,a0,770 # ffffffffc0206090 <default_pmm_manager+0xee8>
ffffffffc0203d96:	b24fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
    int ret = -E_INVAL;
ffffffffc0203d9a:	5575                	li	a0,-3
        goto failed;
ffffffffc0203d9c:	b7c1                	j	ffffffffc0203d5c <do_pgfault+0x7c>
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
ffffffffc0203d9e:	00002517          	auipc	a0,0x2
ffffffffc0203da2:	34a50513          	addi	a0,a0,842 # ffffffffc02060e8 <default_pmm_manager+0xf40>
ffffffffc0203da6:	b14fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
    ret = -E_NO_MEM;
ffffffffc0203daa:	5571                	li	a0,-4
            goto failed;
ffffffffc0203dac:	bf45                	j	ffffffffc0203d5c <do_pgfault+0x7c>

ffffffffc0203dae <swapfs_init>:
 * @brief 初始化交换文件系统
 * 
 * 这个函数会检查交换设备是否有效，并计算出交换设备上最大的交换偏移量
 */
void
swapfs_init(void) {
ffffffffc0203dae:	1141                	addi	sp,sp,-16
    // 确保页面大小是扇区大小的整数倍
    static_assert((PGSIZE % SECTSIZE) == 0);
    // 如果交换设备无效，则panic
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0203db0:	4505                	li	a0,1
swapfs_init(void) {
ffffffffc0203db2:	e406                	sd	ra,8(sp)
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0203db4:	ee0fc0ef          	jal	ra,ffffffffc0200494 <ide_device_valid>
ffffffffc0203db8:	cd01                	beqz	a0,ffffffffc0203dd0 <swapfs_init+0x22>
        panic("swap fs isn't available.\n");
    }
    // 计算最大交换偏移量
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0203dba:	4505                	li	a0,1
ffffffffc0203dbc:	edefc0ef          	jal	ra,ffffffffc020049a <ide_device_size>
}
ffffffffc0203dc0:	60a2                	ld	ra,8(sp)
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0203dc2:	810d                	srli	a0,a0,0x3
ffffffffc0203dc4:	0000d797          	auipc	a5,0xd
ffffffffc0203dc8:	76a7be23          	sd	a0,1916(a5) # ffffffffc0211540 <max_swap_offset>
}
ffffffffc0203dcc:	0141                	addi	sp,sp,16
ffffffffc0203dce:	8082                	ret
        panic("swap fs isn't available.\n");
ffffffffc0203dd0:	00002617          	auipc	a2,0x2
ffffffffc0203dd4:	34060613          	addi	a2,a2,832 # ffffffffc0206110 <default_pmm_manager+0xf68>
ffffffffc0203dd8:	45d1                	li	a1,20
ffffffffc0203dda:	00002517          	auipc	a0,0x2
ffffffffc0203dde:	35650513          	addi	a0,a0,854 # ffffffffc0206130 <default_pmm_manager+0xf88>
ffffffffc0203de2:	d92fc0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0203de6 <swapfs_read>:
 * @param entry 要读取的页面的索引
 * @param page 读取到的页面将存储在这个Page结构体中
 * @return 成功返回0，失败返回负值
 */
int
swapfs_read(swap_entry_t entry, struct Page *page) {
ffffffffc0203de6:	1141                	addi	sp,sp,-16
ffffffffc0203de8:	e406                	sd	ra,8(sp)
    // 从交换设备中读取数据
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203dea:	00855793          	srli	a5,a0,0x8
ffffffffc0203dee:	c3a5                	beqz	a5,ffffffffc0203e4e <swapfs_read+0x68>
ffffffffc0203df0:	0000d717          	auipc	a4,0xd
ffffffffc0203df4:	75073703          	ld	a4,1872(a4) # ffffffffc0211540 <max_swap_offset>
ffffffffc0203df8:	04e7fb63          	bgeu	a5,a4,ffffffffc0203e4e <swapfs_read+0x68>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203dfc:	0000d617          	auipc	a2,0xd
ffffffffc0203e00:	72c63603          	ld	a2,1836(a2) # ffffffffc0211528 <pages>
ffffffffc0203e04:	8d91                	sub	a1,a1,a2
ffffffffc0203e06:	4035d613          	srai	a2,a1,0x3
ffffffffc0203e0a:	00002597          	auipc	a1,0x2
ffffffffc0203e0e:	5a65b583          	ld	a1,1446(a1) # ffffffffc02063b0 <error_string+0x38>
ffffffffc0203e12:	02b60633          	mul	a2,a2,a1
ffffffffc0203e16:	0037959b          	slliw	a1,a5,0x3
ffffffffc0203e1a:	00002797          	auipc	a5,0x2
ffffffffc0203e1e:	59e7b783          	ld	a5,1438(a5) # ffffffffc02063b8 <nbase>
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203e22:	0000d717          	auipc	a4,0xd
ffffffffc0203e26:	6fe73703          	ld	a4,1790(a4) # ffffffffc0211520 <npage>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203e2a:	963e                	add	a2,a2,a5
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203e2c:	00c61793          	slli	a5,a2,0xc
ffffffffc0203e30:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0203e32:	0632                	slli	a2,a2,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203e34:	02e7fa63          	bgeu	a5,a4,ffffffffc0203e68 <swapfs_read+0x82>
}
ffffffffc0203e38:	60a2                	ld	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203e3a:	0000d797          	auipc	a5,0xd
ffffffffc0203e3e:	6fe7b783          	ld	a5,1790(a5) # ffffffffc0211538 <va_pa_offset>
ffffffffc0203e42:	46a1                	li	a3,8
ffffffffc0203e44:	963e                	add	a2,a2,a5
ffffffffc0203e46:	4505                	li	a0,1
}
ffffffffc0203e48:	0141                	addi	sp,sp,16
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203e4a:	e56fc06f          	j	ffffffffc02004a0 <ide_read_secs>
ffffffffc0203e4e:	86aa                	mv	a3,a0
ffffffffc0203e50:	00002617          	auipc	a2,0x2
ffffffffc0203e54:	2f860613          	addi	a2,a2,760 # ffffffffc0206148 <default_pmm_manager+0xfa0>
ffffffffc0203e58:	02400593          	li	a1,36
ffffffffc0203e5c:	00002517          	auipc	a0,0x2
ffffffffc0203e60:	2d450513          	addi	a0,a0,724 # ffffffffc0206130 <default_pmm_manager+0xf88>
ffffffffc0203e64:	d10fc0ef          	jal	ra,ffffffffc0200374 <__panic>
ffffffffc0203e68:	86b2                	mv	a3,a2
ffffffffc0203e6a:	06a00593          	li	a1,106
ffffffffc0203e6e:	00001617          	auipc	a2,0x1
ffffffffc0203e72:	3ca60613          	addi	a2,a2,970 # ffffffffc0205238 <default_pmm_manager+0x90>
ffffffffc0203e76:	00001517          	auipc	a0,0x1
ffffffffc0203e7a:	38a50513          	addi	a0,a0,906 # ffffffffc0205200 <default_pmm_manager+0x58>
ffffffffc0203e7e:	cf6fc0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0203e82 <swapfs_write>:
 * @param entry 要写入的页面的索引
 * @param page 要写入的页面
 * @return 成功返回0，失败返回负值
 */
int
swapfs_write(swap_entry_t entry, struct Page *page) {
ffffffffc0203e82:	1141                	addi	sp,sp,-16
ffffffffc0203e84:	e406                	sd	ra,8(sp)
    // 将数据写入到交换设备中
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203e86:	00855793          	srli	a5,a0,0x8
ffffffffc0203e8a:	c3a5                	beqz	a5,ffffffffc0203eea <swapfs_write+0x68>
ffffffffc0203e8c:	0000d717          	auipc	a4,0xd
ffffffffc0203e90:	6b473703          	ld	a4,1716(a4) # ffffffffc0211540 <max_swap_offset>
ffffffffc0203e94:	04e7fb63          	bgeu	a5,a4,ffffffffc0203eea <swapfs_write+0x68>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203e98:	0000d617          	auipc	a2,0xd
ffffffffc0203e9c:	69063603          	ld	a2,1680(a2) # ffffffffc0211528 <pages>
ffffffffc0203ea0:	8d91                	sub	a1,a1,a2
ffffffffc0203ea2:	4035d613          	srai	a2,a1,0x3
ffffffffc0203ea6:	00002597          	auipc	a1,0x2
ffffffffc0203eaa:	50a5b583          	ld	a1,1290(a1) # ffffffffc02063b0 <error_string+0x38>
ffffffffc0203eae:	02b60633          	mul	a2,a2,a1
ffffffffc0203eb2:	0037959b          	slliw	a1,a5,0x3
ffffffffc0203eb6:	00002797          	auipc	a5,0x2
ffffffffc0203eba:	5027b783          	ld	a5,1282(a5) # ffffffffc02063b8 <nbase>
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203ebe:	0000d717          	auipc	a4,0xd
ffffffffc0203ec2:	66273703          	ld	a4,1634(a4) # ffffffffc0211520 <npage>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203ec6:	963e                	add	a2,a2,a5
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203ec8:	00c61793          	slli	a5,a2,0xc
ffffffffc0203ecc:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0203ece:	0632                	slli	a2,a2,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203ed0:	02e7fa63          	bgeu	a5,a4,ffffffffc0203f04 <swapfs_write+0x82>
}
ffffffffc0203ed4:	60a2                	ld	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203ed6:	0000d797          	auipc	a5,0xd
ffffffffc0203eda:	6627b783          	ld	a5,1634(a5) # ffffffffc0211538 <va_pa_offset>
ffffffffc0203ede:	46a1                	li	a3,8
ffffffffc0203ee0:	963e                	add	a2,a2,a5
ffffffffc0203ee2:	4505                	li	a0,1
}
ffffffffc0203ee4:	0141                	addi	sp,sp,16
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203ee6:	ddefc06f          	j	ffffffffc02004c4 <ide_write_secs>
ffffffffc0203eea:	86aa                	mv	a3,a0
ffffffffc0203eec:	00002617          	auipc	a2,0x2
ffffffffc0203ef0:	25c60613          	addi	a2,a2,604 # ffffffffc0206148 <default_pmm_manager+0xfa0>
ffffffffc0203ef4:	03100593          	li	a1,49
ffffffffc0203ef8:	00002517          	auipc	a0,0x2
ffffffffc0203efc:	23850513          	addi	a0,a0,568 # ffffffffc0206130 <default_pmm_manager+0xf88>
ffffffffc0203f00:	c74fc0ef          	jal	ra,ffffffffc0200374 <__panic>
ffffffffc0203f04:	86b2                	mv	a3,a2
ffffffffc0203f06:	06a00593          	li	a1,106
ffffffffc0203f0a:	00001617          	auipc	a2,0x1
ffffffffc0203f0e:	32e60613          	addi	a2,a2,814 # ffffffffc0205238 <default_pmm_manager+0x90>
ffffffffc0203f12:	00001517          	auipc	a0,0x1
ffffffffc0203f16:	2ee50513          	addi	a0,a0,750 # ffffffffc0205200 <default_pmm_manager+0x58>
ffffffffc0203f1a:	c5afc0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0203f1e <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0203f1e:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0203f22:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0203f24:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0203f28:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0203f2a:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0203f2e:	f022                	sd	s0,32(sp)
ffffffffc0203f30:	ec26                	sd	s1,24(sp)
ffffffffc0203f32:	e84a                	sd	s2,16(sp)
ffffffffc0203f34:	f406                	sd	ra,40(sp)
ffffffffc0203f36:	e44e                	sd	s3,8(sp)
ffffffffc0203f38:	84aa                	mv	s1,a0
ffffffffc0203f3a:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0203f3c:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0203f40:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc0203f42:	03067e63          	bgeu	a2,a6,ffffffffc0203f7e <printnum+0x60>
ffffffffc0203f46:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc0203f48:	00805763          	blez	s0,ffffffffc0203f56 <printnum+0x38>
ffffffffc0203f4c:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0203f4e:	85ca                	mv	a1,s2
ffffffffc0203f50:	854e                	mv	a0,s3
ffffffffc0203f52:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0203f54:	fc65                	bnez	s0,ffffffffc0203f4c <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203f56:	1a02                	slli	s4,s4,0x20
ffffffffc0203f58:	00002797          	auipc	a5,0x2
ffffffffc0203f5c:	21078793          	addi	a5,a5,528 # ffffffffc0206168 <default_pmm_manager+0xfc0>
ffffffffc0203f60:	020a5a13          	srli	s4,s4,0x20
ffffffffc0203f64:	9a3e                	add	s4,s4,a5
}
ffffffffc0203f66:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203f68:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0203f6c:	70a2                	ld	ra,40(sp)
ffffffffc0203f6e:	69a2                	ld	s3,8(sp)
ffffffffc0203f70:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203f72:	85ca                	mv	a1,s2
ffffffffc0203f74:	87a6                	mv	a5,s1
}
ffffffffc0203f76:	6942                	ld	s2,16(sp)
ffffffffc0203f78:	64e2                	ld	s1,24(sp)
ffffffffc0203f7a:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203f7c:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0203f7e:	03065633          	divu	a2,a2,a6
ffffffffc0203f82:	8722                	mv	a4,s0
ffffffffc0203f84:	f9bff0ef          	jal	ra,ffffffffc0203f1e <printnum>
ffffffffc0203f88:	b7f9                	j	ffffffffc0203f56 <printnum+0x38>

ffffffffc0203f8a <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0203f8a:	7119                	addi	sp,sp,-128
ffffffffc0203f8c:	f4a6                	sd	s1,104(sp)
ffffffffc0203f8e:	f0ca                	sd	s2,96(sp)
ffffffffc0203f90:	ecce                	sd	s3,88(sp)
ffffffffc0203f92:	e8d2                	sd	s4,80(sp)
ffffffffc0203f94:	e4d6                	sd	s5,72(sp)
ffffffffc0203f96:	e0da                	sd	s6,64(sp)
ffffffffc0203f98:	fc5e                	sd	s7,56(sp)
ffffffffc0203f9a:	f06a                	sd	s10,32(sp)
ffffffffc0203f9c:	fc86                	sd	ra,120(sp)
ffffffffc0203f9e:	f8a2                	sd	s0,112(sp)
ffffffffc0203fa0:	f862                	sd	s8,48(sp)
ffffffffc0203fa2:	f466                	sd	s9,40(sp)
ffffffffc0203fa4:	ec6e                	sd	s11,24(sp)
ffffffffc0203fa6:	892a                	mv	s2,a0
ffffffffc0203fa8:	84ae                	mv	s1,a1
ffffffffc0203faa:	8d32                	mv	s10,a2
ffffffffc0203fac:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0203fae:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc0203fb2:	5b7d                	li	s6,-1
ffffffffc0203fb4:	00002a97          	auipc	s5,0x2
ffffffffc0203fb8:	1e8a8a93          	addi	s5,s5,488 # ffffffffc020619c <default_pmm_manager+0xff4>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0203fbc:	00002b97          	auipc	s7,0x2
ffffffffc0203fc0:	3bcb8b93          	addi	s7,s7,956 # ffffffffc0206378 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0203fc4:	000d4503          	lbu	a0,0(s10) # 80000 <kern_entry-0xffffffffc0180000>
ffffffffc0203fc8:	001d0413          	addi	s0,s10,1
ffffffffc0203fcc:	01350a63          	beq	a0,s3,ffffffffc0203fe0 <vprintfmt+0x56>
            if (ch == '\0') {
ffffffffc0203fd0:	c121                	beqz	a0,ffffffffc0204010 <vprintfmt+0x86>
            putch(ch, putdat);
ffffffffc0203fd2:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0203fd4:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc0203fd6:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0203fd8:	fff44503          	lbu	a0,-1(s0)
ffffffffc0203fdc:	ff351ae3          	bne	a0,s3,ffffffffc0203fd0 <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203fe0:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc0203fe4:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc0203fe8:	4c81                	li	s9,0
ffffffffc0203fea:	4881                	li	a7,0
        width = precision = -1;
ffffffffc0203fec:	5c7d                	li	s8,-1
ffffffffc0203fee:	5dfd                	li	s11,-1
ffffffffc0203ff0:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
ffffffffc0203ff4:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203ff6:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0203ffa:	0ff5f593          	zext.b	a1,a1
ffffffffc0203ffe:	00140d13          	addi	s10,s0,1
ffffffffc0204002:	04b56263          	bltu	a0,a1,ffffffffc0204046 <vprintfmt+0xbc>
ffffffffc0204006:	058a                	slli	a1,a1,0x2
ffffffffc0204008:	95d6                	add	a1,a1,s5
ffffffffc020400a:	4194                	lw	a3,0(a1)
ffffffffc020400c:	96d6                	add	a3,a3,s5
ffffffffc020400e:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0204010:	70e6                	ld	ra,120(sp)
ffffffffc0204012:	7446                	ld	s0,112(sp)
ffffffffc0204014:	74a6                	ld	s1,104(sp)
ffffffffc0204016:	7906                	ld	s2,96(sp)
ffffffffc0204018:	69e6                	ld	s3,88(sp)
ffffffffc020401a:	6a46                	ld	s4,80(sp)
ffffffffc020401c:	6aa6                	ld	s5,72(sp)
ffffffffc020401e:	6b06                	ld	s6,64(sp)
ffffffffc0204020:	7be2                	ld	s7,56(sp)
ffffffffc0204022:	7c42                	ld	s8,48(sp)
ffffffffc0204024:	7ca2                	ld	s9,40(sp)
ffffffffc0204026:	7d02                	ld	s10,32(sp)
ffffffffc0204028:	6de2                	ld	s11,24(sp)
ffffffffc020402a:	6109                	addi	sp,sp,128
ffffffffc020402c:	8082                	ret
            padc = '0';
ffffffffc020402e:	87b2                	mv	a5,a2
            goto reswitch;
ffffffffc0204030:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204034:	846a                	mv	s0,s10
ffffffffc0204036:	00140d13          	addi	s10,s0,1
ffffffffc020403a:	fdd6059b          	addiw	a1,a2,-35
ffffffffc020403e:	0ff5f593          	zext.b	a1,a1
ffffffffc0204042:	fcb572e3          	bgeu	a0,a1,ffffffffc0204006 <vprintfmt+0x7c>
            putch('%', putdat);
ffffffffc0204046:	85a6                	mv	a1,s1
ffffffffc0204048:	02500513          	li	a0,37
ffffffffc020404c:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc020404e:	fff44783          	lbu	a5,-1(s0)
ffffffffc0204052:	8d22                	mv	s10,s0
ffffffffc0204054:	f73788e3          	beq	a5,s3,ffffffffc0203fc4 <vprintfmt+0x3a>
ffffffffc0204058:	ffed4783          	lbu	a5,-2(s10)
ffffffffc020405c:	1d7d                	addi	s10,s10,-1
ffffffffc020405e:	ff379de3          	bne	a5,s3,ffffffffc0204058 <vprintfmt+0xce>
ffffffffc0204062:	b78d                	j	ffffffffc0203fc4 <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
ffffffffc0204064:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
ffffffffc0204068:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020406c:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc020406e:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc0204072:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc0204076:	02d86463          	bltu	a6,a3,ffffffffc020409e <vprintfmt+0x114>
                ch = *fmt;
ffffffffc020407a:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc020407e:	002c169b          	slliw	a3,s8,0x2
ffffffffc0204082:	0186873b          	addw	a4,a3,s8
ffffffffc0204086:	0017171b          	slliw	a4,a4,0x1
ffffffffc020408a:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
ffffffffc020408c:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc0204090:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0204092:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
ffffffffc0204096:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc020409a:	fed870e3          	bgeu	a6,a3,ffffffffc020407a <vprintfmt+0xf0>
            if (width < 0)
ffffffffc020409e:	f40ddce3          	bgez	s11,ffffffffc0203ff6 <vprintfmt+0x6c>
                width = precision, precision = -1;
ffffffffc02040a2:	8de2                	mv	s11,s8
ffffffffc02040a4:	5c7d                	li	s8,-1
ffffffffc02040a6:	bf81                	j	ffffffffc0203ff6 <vprintfmt+0x6c>
            if (width < 0)
ffffffffc02040a8:	fffdc693          	not	a3,s11
ffffffffc02040ac:	96fd                	srai	a3,a3,0x3f
ffffffffc02040ae:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02040b2:	00144603          	lbu	a2,1(s0)
ffffffffc02040b6:	2d81                	sext.w	s11,s11
ffffffffc02040b8:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02040ba:	bf35                	j	ffffffffc0203ff6 <vprintfmt+0x6c>
            precision = va_arg(ap, int);
ffffffffc02040bc:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02040c0:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc02040c4:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02040c6:	846a                	mv	s0,s10
            goto process_precision;
ffffffffc02040c8:	bfd9                	j	ffffffffc020409e <vprintfmt+0x114>
    if (lflag >= 2) {
ffffffffc02040ca:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02040cc:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc02040d0:	01174463          	blt	a4,a7,ffffffffc02040d8 <vprintfmt+0x14e>
    else if (lflag) {
ffffffffc02040d4:	1a088e63          	beqz	a7,ffffffffc0204290 <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
ffffffffc02040d8:	000a3603          	ld	a2,0(s4)
ffffffffc02040dc:	46c1                	li	a3,16
ffffffffc02040de:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc02040e0:	2781                	sext.w	a5,a5
ffffffffc02040e2:	876e                	mv	a4,s11
ffffffffc02040e4:	85a6                	mv	a1,s1
ffffffffc02040e6:	854a                	mv	a0,s2
ffffffffc02040e8:	e37ff0ef          	jal	ra,ffffffffc0203f1e <printnum>
            break;
ffffffffc02040ec:	bde1                	j	ffffffffc0203fc4 <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
ffffffffc02040ee:	000a2503          	lw	a0,0(s4)
ffffffffc02040f2:	85a6                	mv	a1,s1
ffffffffc02040f4:	0a21                	addi	s4,s4,8
ffffffffc02040f6:	9902                	jalr	s2
            break;
ffffffffc02040f8:	b5f1                	j	ffffffffc0203fc4 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02040fa:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02040fc:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0204100:	01174463          	blt	a4,a7,ffffffffc0204108 <vprintfmt+0x17e>
    else if (lflag) {
ffffffffc0204104:	18088163          	beqz	a7,ffffffffc0204286 <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
ffffffffc0204108:	000a3603          	ld	a2,0(s4)
ffffffffc020410c:	46a9                	li	a3,10
ffffffffc020410e:	8a2e                	mv	s4,a1
ffffffffc0204110:	bfc1                	j	ffffffffc02040e0 <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204112:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc0204116:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204118:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc020411a:	bdf1                	j	ffffffffc0203ff6 <vprintfmt+0x6c>
            putch(ch, putdat);
ffffffffc020411c:	85a6                	mv	a1,s1
ffffffffc020411e:	02500513          	li	a0,37
ffffffffc0204122:	9902                	jalr	s2
            break;
ffffffffc0204124:	b545                	j	ffffffffc0203fc4 <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204126:	00144603          	lbu	a2,1(s0)
            lflag ++;
ffffffffc020412a:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020412c:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc020412e:	b5e1                	j	ffffffffc0203ff6 <vprintfmt+0x6c>
    if (lflag >= 2) {
ffffffffc0204130:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0204132:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0204136:	01174463          	blt	a4,a7,ffffffffc020413e <vprintfmt+0x1b4>
    else if (lflag) {
ffffffffc020413a:	14088163          	beqz	a7,ffffffffc020427c <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
ffffffffc020413e:	000a3603          	ld	a2,0(s4)
ffffffffc0204142:	46a1                	li	a3,8
ffffffffc0204144:	8a2e                	mv	s4,a1
ffffffffc0204146:	bf69                	j	ffffffffc02040e0 <vprintfmt+0x156>
            putch('0', putdat);
ffffffffc0204148:	03000513          	li	a0,48
ffffffffc020414c:	85a6                	mv	a1,s1
ffffffffc020414e:	e03e                	sd	a5,0(sp)
ffffffffc0204150:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0204152:	85a6                	mv	a1,s1
ffffffffc0204154:	07800513          	li	a0,120
ffffffffc0204158:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc020415a:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc020415c:	6782                	ld	a5,0(sp)
ffffffffc020415e:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0204160:	ff8a3603          	ld	a2,-8(s4)
            goto number;
ffffffffc0204164:	bfb5                	j	ffffffffc02040e0 <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0204166:	000a3403          	ld	s0,0(s4)
ffffffffc020416a:	008a0713          	addi	a4,s4,8
ffffffffc020416e:	e03a                	sd	a4,0(sp)
ffffffffc0204170:	14040263          	beqz	s0,ffffffffc02042b4 <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
ffffffffc0204174:	0fb05763          	blez	s11,ffffffffc0204262 <vprintfmt+0x2d8>
ffffffffc0204178:	02d00693          	li	a3,45
ffffffffc020417c:	0cd79163          	bne	a5,a3,ffffffffc020423e <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204180:	00044783          	lbu	a5,0(s0)
ffffffffc0204184:	0007851b          	sext.w	a0,a5
ffffffffc0204188:	cf85                	beqz	a5,ffffffffc02041c0 <vprintfmt+0x236>
ffffffffc020418a:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc020418e:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204192:	000c4563          	bltz	s8,ffffffffc020419c <vprintfmt+0x212>
ffffffffc0204196:	3c7d                	addiw	s8,s8,-1
ffffffffc0204198:	036c0263          	beq	s8,s6,ffffffffc02041bc <vprintfmt+0x232>
                    putch('?', putdat);
ffffffffc020419c:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc020419e:	0e0c8e63          	beqz	s9,ffffffffc020429a <vprintfmt+0x310>
ffffffffc02041a2:	3781                	addiw	a5,a5,-32
ffffffffc02041a4:	0ef47b63          	bgeu	s0,a5,ffffffffc020429a <vprintfmt+0x310>
                    putch('?', putdat);
ffffffffc02041a8:	03f00513          	li	a0,63
ffffffffc02041ac:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02041ae:	000a4783          	lbu	a5,0(s4)
ffffffffc02041b2:	3dfd                	addiw	s11,s11,-1
ffffffffc02041b4:	0a05                	addi	s4,s4,1
ffffffffc02041b6:	0007851b          	sext.w	a0,a5
ffffffffc02041ba:	ffe1                	bnez	a5,ffffffffc0204192 <vprintfmt+0x208>
            for (; width > 0; width --) {
ffffffffc02041bc:	01b05963          	blez	s11,ffffffffc02041ce <vprintfmt+0x244>
ffffffffc02041c0:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc02041c2:	85a6                	mv	a1,s1
ffffffffc02041c4:	02000513          	li	a0,32
ffffffffc02041c8:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc02041ca:	fe0d9be3          	bnez	s11,ffffffffc02041c0 <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc02041ce:	6a02                	ld	s4,0(sp)
ffffffffc02041d0:	bbd5                	j	ffffffffc0203fc4 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02041d2:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02041d4:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
ffffffffc02041d8:	01174463          	blt	a4,a7,ffffffffc02041e0 <vprintfmt+0x256>
    else if (lflag) {
ffffffffc02041dc:	08088d63          	beqz	a7,ffffffffc0204276 <vprintfmt+0x2ec>
        return va_arg(*ap, long);
ffffffffc02041e0:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc02041e4:	0a044d63          	bltz	s0,ffffffffc020429e <vprintfmt+0x314>
            num = getint(&ap, lflag);
ffffffffc02041e8:	8622                	mv	a2,s0
ffffffffc02041ea:	8a66                	mv	s4,s9
ffffffffc02041ec:	46a9                	li	a3,10
ffffffffc02041ee:	bdcd                	j	ffffffffc02040e0 <vprintfmt+0x156>
            err = va_arg(ap, int);
ffffffffc02041f0:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02041f4:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc02041f6:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc02041f8:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc02041fc:	8fb5                	xor	a5,a5,a3
ffffffffc02041fe:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0204202:	02d74163          	blt	a4,a3,ffffffffc0204224 <vprintfmt+0x29a>
ffffffffc0204206:	00369793          	slli	a5,a3,0x3
ffffffffc020420a:	97de                	add	a5,a5,s7
ffffffffc020420c:	639c                	ld	a5,0(a5)
ffffffffc020420e:	cb99                	beqz	a5,ffffffffc0204224 <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
ffffffffc0204210:	86be                	mv	a3,a5
ffffffffc0204212:	00002617          	auipc	a2,0x2
ffffffffc0204216:	f8660613          	addi	a2,a2,-122 # ffffffffc0206198 <default_pmm_manager+0xff0>
ffffffffc020421a:	85a6                	mv	a1,s1
ffffffffc020421c:	854a                	mv	a0,s2
ffffffffc020421e:	0ce000ef          	jal	ra,ffffffffc02042ec <printfmt>
ffffffffc0204222:	b34d                	j	ffffffffc0203fc4 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc0204224:	00002617          	auipc	a2,0x2
ffffffffc0204228:	f6460613          	addi	a2,a2,-156 # ffffffffc0206188 <default_pmm_manager+0xfe0>
ffffffffc020422c:	85a6                	mv	a1,s1
ffffffffc020422e:	854a                	mv	a0,s2
ffffffffc0204230:	0bc000ef          	jal	ra,ffffffffc02042ec <printfmt>
ffffffffc0204234:	bb41                	j	ffffffffc0203fc4 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc0204236:	00002417          	auipc	s0,0x2
ffffffffc020423a:	f4a40413          	addi	s0,s0,-182 # ffffffffc0206180 <default_pmm_manager+0xfd8>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020423e:	85e2                	mv	a1,s8
ffffffffc0204240:	8522                	mv	a0,s0
ffffffffc0204242:	e43e                	sd	a5,8(sp)
ffffffffc0204244:	196000ef          	jal	ra,ffffffffc02043da <strnlen>
ffffffffc0204248:	40ad8dbb          	subw	s11,s11,a0
ffffffffc020424c:	01b05b63          	blez	s11,ffffffffc0204262 <vprintfmt+0x2d8>
                    putch(padc, putdat);
ffffffffc0204250:	67a2                	ld	a5,8(sp)
ffffffffc0204252:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0204256:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc0204258:	85a6                	mv	a1,s1
ffffffffc020425a:	8552                	mv	a0,s4
ffffffffc020425c:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020425e:	fe0d9ce3          	bnez	s11,ffffffffc0204256 <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204262:	00044783          	lbu	a5,0(s0)
ffffffffc0204266:	00140a13          	addi	s4,s0,1
ffffffffc020426a:	0007851b          	sext.w	a0,a5
ffffffffc020426e:	d3a5                	beqz	a5,ffffffffc02041ce <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0204270:	05e00413          	li	s0,94
ffffffffc0204274:	bf39                	j	ffffffffc0204192 <vprintfmt+0x208>
        return va_arg(*ap, int);
ffffffffc0204276:	000a2403          	lw	s0,0(s4)
ffffffffc020427a:	b7ad                	j	ffffffffc02041e4 <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
ffffffffc020427c:	000a6603          	lwu	a2,0(s4)
ffffffffc0204280:	46a1                	li	a3,8
ffffffffc0204282:	8a2e                	mv	s4,a1
ffffffffc0204284:	bdb1                	j	ffffffffc02040e0 <vprintfmt+0x156>
ffffffffc0204286:	000a6603          	lwu	a2,0(s4)
ffffffffc020428a:	46a9                	li	a3,10
ffffffffc020428c:	8a2e                	mv	s4,a1
ffffffffc020428e:	bd89                	j	ffffffffc02040e0 <vprintfmt+0x156>
ffffffffc0204290:	000a6603          	lwu	a2,0(s4)
ffffffffc0204294:	46c1                	li	a3,16
ffffffffc0204296:	8a2e                	mv	s4,a1
ffffffffc0204298:	b5a1                	j	ffffffffc02040e0 <vprintfmt+0x156>
                    putch(ch, putdat);
ffffffffc020429a:	9902                	jalr	s2
ffffffffc020429c:	bf09                	j	ffffffffc02041ae <vprintfmt+0x224>
                putch('-', putdat);
ffffffffc020429e:	85a6                	mv	a1,s1
ffffffffc02042a0:	02d00513          	li	a0,45
ffffffffc02042a4:	e03e                	sd	a5,0(sp)
ffffffffc02042a6:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc02042a8:	6782                	ld	a5,0(sp)
ffffffffc02042aa:	8a66                	mv	s4,s9
ffffffffc02042ac:	40800633          	neg	a2,s0
ffffffffc02042b0:	46a9                	li	a3,10
ffffffffc02042b2:	b53d                	j	ffffffffc02040e0 <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
ffffffffc02042b4:	03b05163          	blez	s11,ffffffffc02042d6 <vprintfmt+0x34c>
ffffffffc02042b8:	02d00693          	li	a3,45
ffffffffc02042bc:	f6d79de3          	bne	a5,a3,ffffffffc0204236 <vprintfmt+0x2ac>
                p = "(null)";
ffffffffc02042c0:	00002417          	auipc	s0,0x2
ffffffffc02042c4:	ec040413          	addi	s0,s0,-320 # ffffffffc0206180 <default_pmm_manager+0xfd8>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02042c8:	02800793          	li	a5,40
ffffffffc02042cc:	02800513          	li	a0,40
ffffffffc02042d0:	00140a13          	addi	s4,s0,1
ffffffffc02042d4:	bd6d                	j	ffffffffc020418e <vprintfmt+0x204>
ffffffffc02042d6:	00002a17          	auipc	s4,0x2
ffffffffc02042da:	eaba0a13          	addi	s4,s4,-341 # ffffffffc0206181 <default_pmm_manager+0xfd9>
ffffffffc02042de:	02800513          	li	a0,40
ffffffffc02042e2:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02042e6:	05e00413          	li	s0,94
ffffffffc02042ea:	b565                	j	ffffffffc0204192 <vprintfmt+0x208>

ffffffffc02042ec <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02042ec:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc02042ee:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02042f2:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02042f4:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02042f6:	ec06                	sd	ra,24(sp)
ffffffffc02042f8:	f83a                	sd	a4,48(sp)
ffffffffc02042fa:	fc3e                	sd	a5,56(sp)
ffffffffc02042fc:	e0c2                	sd	a6,64(sp)
ffffffffc02042fe:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0204300:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0204302:	c89ff0ef          	jal	ra,ffffffffc0203f8a <vprintfmt>
}
ffffffffc0204306:	60e2                	ld	ra,24(sp)
ffffffffc0204308:	6161                	addi	sp,sp,80
ffffffffc020430a:	8082                	ret

ffffffffc020430c <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc020430c:	715d                	addi	sp,sp,-80
ffffffffc020430e:	e486                	sd	ra,72(sp)
ffffffffc0204310:	e0a6                	sd	s1,64(sp)
ffffffffc0204312:	fc4a                	sd	s2,56(sp)
ffffffffc0204314:	f84e                	sd	s3,48(sp)
ffffffffc0204316:	f452                	sd	s4,40(sp)
ffffffffc0204318:	f056                	sd	s5,32(sp)
ffffffffc020431a:	ec5a                	sd	s6,24(sp)
ffffffffc020431c:	e85e                	sd	s7,16(sp)
    if (prompt != NULL) {
ffffffffc020431e:	c901                	beqz	a0,ffffffffc020432e <readline+0x22>
ffffffffc0204320:	85aa                	mv	a1,a0
        cprintf("%s", prompt);
ffffffffc0204322:	00002517          	auipc	a0,0x2
ffffffffc0204326:	e7650513          	addi	a0,a0,-394 # ffffffffc0206198 <default_pmm_manager+0xff0>
ffffffffc020432a:	d91fb0ef          	jal	ra,ffffffffc02000ba <cprintf>
readline(const char *prompt) {
ffffffffc020432e:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0204330:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc0204332:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc0204334:	4aa9                	li	s5,10
ffffffffc0204336:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc0204338:	0000db97          	auipc	s7,0xd
ffffffffc020433c:	dc0b8b93          	addi	s7,s7,-576 # ffffffffc02110f8 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0204340:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc0204344:	daffb0ef          	jal	ra,ffffffffc02000f2 <getchar>
        if (c < 0) {
ffffffffc0204348:	00054a63          	bltz	a0,ffffffffc020435c <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020434c:	00a95a63          	bge	s2,a0,ffffffffc0204360 <readline+0x54>
ffffffffc0204350:	029a5263          	bge	s4,s1,ffffffffc0204374 <readline+0x68>
        c = getchar();
ffffffffc0204354:	d9ffb0ef          	jal	ra,ffffffffc02000f2 <getchar>
        if (c < 0) {
ffffffffc0204358:	fe055ae3          	bgez	a0,ffffffffc020434c <readline+0x40>
            return NULL;
ffffffffc020435c:	4501                	li	a0,0
ffffffffc020435e:	a091                	j	ffffffffc02043a2 <readline+0x96>
        else if (c == '\b' && i > 0) {
ffffffffc0204360:	03351463          	bne	a0,s3,ffffffffc0204388 <readline+0x7c>
ffffffffc0204364:	e8a9                	bnez	s1,ffffffffc02043b6 <readline+0xaa>
        c = getchar();
ffffffffc0204366:	d8dfb0ef          	jal	ra,ffffffffc02000f2 <getchar>
        if (c < 0) {
ffffffffc020436a:	fe0549e3          	bltz	a0,ffffffffc020435c <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020436e:	fea959e3          	bge	s2,a0,ffffffffc0204360 <readline+0x54>
ffffffffc0204372:	4481                	li	s1,0
            cputchar(c);
ffffffffc0204374:	e42a                	sd	a0,8(sp)
ffffffffc0204376:	d7bfb0ef          	jal	ra,ffffffffc02000f0 <cputchar>
            buf[i ++] = c;
ffffffffc020437a:	6522                	ld	a0,8(sp)
ffffffffc020437c:	009b87b3          	add	a5,s7,s1
ffffffffc0204380:	2485                	addiw	s1,s1,1
ffffffffc0204382:	00a78023          	sb	a0,0(a5)
ffffffffc0204386:	bf7d                	j	ffffffffc0204344 <readline+0x38>
        else if (c == '\n' || c == '\r') {
ffffffffc0204388:	01550463          	beq	a0,s5,ffffffffc0204390 <readline+0x84>
ffffffffc020438c:	fb651ce3          	bne	a0,s6,ffffffffc0204344 <readline+0x38>
            cputchar(c);
ffffffffc0204390:	d61fb0ef          	jal	ra,ffffffffc02000f0 <cputchar>
            buf[i] = '\0';
ffffffffc0204394:	0000d517          	auipc	a0,0xd
ffffffffc0204398:	d6450513          	addi	a0,a0,-668 # ffffffffc02110f8 <buf>
ffffffffc020439c:	94aa                	add	s1,s1,a0
ffffffffc020439e:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc02043a2:	60a6                	ld	ra,72(sp)
ffffffffc02043a4:	6486                	ld	s1,64(sp)
ffffffffc02043a6:	7962                	ld	s2,56(sp)
ffffffffc02043a8:	79c2                	ld	s3,48(sp)
ffffffffc02043aa:	7a22                	ld	s4,40(sp)
ffffffffc02043ac:	7a82                	ld	s5,32(sp)
ffffffffc02043ae:	6b62                	ld	s6,24(sp)
ffffffffc02043b0:	6bc2                	ld	s7,16(sp)
ffffffffc02043b2:	6161                	addi	sp,sp,80
ffffffffc02043b4:	8082                	ret
            cputchar(c);
ffffffffc02043b6:	4521                	li	a0,8
ffffffffc02043b8:	d39fb0ef          	jal	ra,ffffffffc02000f0 <cputchar>
            i --;
ffffffffc02043bc:	34fd                	addiw	s1,s1,-1
ffffffffc02043be:	b759                	j	ffffffffc0204344 <readline+0x38>

ffffffffc02043c0 <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc02043c0:	00054783          	lbu	a5,0(a0)
strlen(const char *s) {
ffffffffc02043c4:	872a                	mv	a4,a0
    size_t cnt = 0;
ffffffffc02043c6:	4501                	li	a0,0
    while (*s ++ != '\0') {
ffffffffc02043c8:	cb81                	beqz	a5,ffffffffc02043d8 <strlen+0x18>
        cnt ++;
ffffffffc02043ca:	0505                	addi	a0,a0,1
    while (*s ++ != '\0') {
ffffffffc02043cc:	00a707b3          	add	a5,a4,a0
ffffffffc02043d0:	0007c783          	lbu	a5,0(a5)
ffffffffc02043d4:	fbfd                	bnez	a5,ffffffffc02043ca <strlen+0xa>
ffffffffc02043d6:	8082                	ret
    }
    return cnt;
}
ffffffffc02043d8:	8082                	ret

ffffffffc02043da <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc02043da:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc02043dc:	e589                	bnez	a1,ffffffffc02043e6 <strnlen+0xc>
ffffffffc02043de:	a811                	j	ffffffffc02043f2 <strnlen+0x18>
        cnt ++;
ffffffffc02043e0:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc02043e2:	00f58863          	beq	a1,a5,ffffffffc02043f2 <strnlen+0x18>
ffffffffc02043e6:	00f50733          	add	a4,a0,a5
ffffffffc02043ea:	00074703          	lbu	a4,0(a4)
ffffffffc02043ee:	fb6d                	bnez	a4,ffffffffc02043e0 <strnlen+0x6>
ffffffffc02043f0:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc02043f2:	852e                	mv	a0,a1
ffffffffc02043f4:	8082                	ret

ffffffffc02043f6 <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc02043f6:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc02043f8:	0005c703          	lbu	a4,0(a1)
ffffffffc02043fc:	0785                	addi	a5,a5,1
ffffffffc02043fe:	0585                	addi	a1,a1,1
ffffffffc0204400:	fee78fa3          	sb	a4,-1(a5)
ffffffffc0204404:	fb75                	bnez	a4,ffffffffc02043f8 <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc0204406:	8082                	ret

ffffffffc0204408 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0204408:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc020440c:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0204410:	cb89                	beqz	a5,ffffffffc0204422 <strcmp+0x1a>
        s1 ++, s2 ++;
ffffffffc0204412:	0505                	addi	a0,a0,1
ffffffffc0204414:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0204416:	fee789e3          	beq	a5,a4,ffffffffc0204408 <strcmp>
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc020441a:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc020441e:	9d19                	subw	a0,a0,a4
ffffffffc0204420:	8082                	ret
ffffffffc0204422:	4501                	li	a0,0
ffffffffc0204424:	bfed                	j	ffffffffc020441e <strcmp+0x16>

ffffffffc0204426 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0204426:	00054783          	lbu	a5,0(a0)
ffffffffc020442a:	c799                	beqz	a5,ffffffffc0204438 <strchr+0x12>
        if (*s == c) {
ffffffffc020442c:	00f58763          	beq	a1,a5,ffffffffc020443a <strchr+0x14>
    while (*s != '\0') {
ffffffffc0204430:	00154783          	lbu	a5,1(a0)
            return (char *)s;
        }
        s ++;
ffffffffc0204434:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0204436:	fbfd                	bnez	a5,ffffffffc020442c <strchr+0x6>
    }
    return NULL;
ffffffffc0204438:	4501                	li	a0,0
}
ffffffffc020443a:	8082                	ret

ffffffffc020443c <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc020443c:	ca01                	beqz	a2,ffffffffc020444c <memset+0x10>
ffffffffc020443e:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0204440:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0204442:	0785                	addi	a5,a5,1
ffffffffc0204444:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0204448:	fec79de3          	bne	a5,a2,ffffffffc0204442 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc020444c:	8082                	ret

ffffffffc020444e <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc020444e:	ca19                	beqz	a2,ffffffffc0204464 <memcpy+0x16>
ffffffffc0204450:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc0204452:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc0204454:	0005c703          	lbu	a4,0(a1)
ffffffffc0204458:	0585                	addi	a1,a1,1
ffffffffc020445a:	0785                	addi	a5,a5,1
ffffffffc020445c:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc0204460:	fec59ae3          	bne	a1,a2,ffffffffc0204454 <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc0204464:	8082                	ret
