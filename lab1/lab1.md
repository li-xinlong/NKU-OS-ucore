# Lab0.5&Lab1实验报告

2212599 李欣龙   2212294赵思洋   2212045闫耀方

#### 【Lab 0.5】**练习1: 使用GDB验证启动流程**

> 为了熟悉使用qemu和gdb进行调试工作,使用gdb调试QEMU模拟的RISC-V计算机加电开始运行到执行应用程序的第一条指令（即跳转到0x80200000）这个阶段的执行过程，说明RISC-V硬件加电后的几条指令在哪里？完成了哪些功能？要求在报告中简要写出练习过程和回答。

  1. 在RISC-V上电后，PC的复位地址是`0x1000`，即从`0x1000`处开始执行。然后，在顺序执行`0x101c`处，会执行“`ld t0,24(t0)`”。执行该指令前，`t0`寄存器为`0x1000`，执行后，t0寄存器的值为成`0x1018`处的数据，即`0x80000000`，然后执行指令“`jr t0`”，跳转至`0x80000000`处。之后执行OpenSBI中的指令，将内核文件`OS.bin`加载至内存。最后，跳转至`0x80200000`。在用QEMU模拟的RISCV中，这些指令存储在一个名为OpenSBI的固态存储器中（称之为`bootloader`）。上电后，pc处的10条指令如下：

     ```
     (gdb) x/10i $pc
      => 0x1000:  auipc   t0,0x0
         0x1004:  addi    a1,t0,32
         0x1008:  csrr    a0,mhartid
         0x100c:  ld  t0,24(t0)
         0x1010:  jr  t0
         0x1014:  unimp
         0x1016:  unimp
         0x1018:  unimp
         0x101a:  0x8000
         0x101c:  unimp
     ```

     

  2. 完成的功能如下：OpenSBI是一个能够存储数据，但又掉电不丢失数据的设备，它存储的是CPU可读取的硬盘驱动程序，从而能够使CPU把硬盘上存储的操作系统程序读取到RAM中（即内存），接着RAM接替OpenSBI，使CPU正常运行读取的操作系统。简单来说，就是把操作系统加载到内存，然后把CPU的控制权交给操作系统。

#### **【Lab 1】练习1：理解内核启动中的程序入口操作**

> 阅读` kern/init/entry.S`内容代码，结合操作系统内核启动流程，说明指令` la sp, bootstacktop `完成了什么操作，目的是什么？ `tail kern_init `完成了什么操作，目的是什么？

1. ### ` la sp, bootstacktop`

   作用：将`bootstacktop`的地址加载到`sp`寄存器中，将栈指针指向`bootstacktop`, 即设置了内核栈的起始地址。

   目的：为了初始化内核栈，让内核能够使用`bootstack`作为其栈空间。

   

2. ### `tail kern_init`

   作用：该指令是一个尾调用指令，它将当前函数的栈帧清除，然后跳转到`kern_init`函数。

   目的：为了节省栈空间，避免不必要的栈帧堆叠，有效避免了栈溢出的问题。

#### **【Lab 1】练习2：完善中断处理 （需要编程）**

> 请编程完善trap.c中的中断处理函数trap，在对时钟中断进行处理的部分填写kern/trap/trap.c函数中处理时钟中断的部分，使操作系统每遇到100次时钟中断后，调用print_ticks子程序，向屏幕上打印一行文字”100 ticks”，在打印完10行后调用sbi.h中的shut_down()函数关机。
>
> 要求完成问题1提出的相关函数实现，提交改进后的源代码包（可以编译执行），并在实验报告中简要说明实现过程和定时器中断中断处理的流程。实现要求的部分代码后，运行整个系统，大约每1秒会输出一次”100 ticks”，输出10行。

**定时器中断中断处理的流程**：在内核加载的时候即`kern/init/init.c`中将会初始化中断向量表以及时钟中断，同时会调用`clock_set_next_event()`函数设置下一个时钟中断的时间点，当经过大约10ms时触发了`IRQ_S_TIMER`时钟中断，调用`kern/trap/trapentry.S`保存上下文，然后调用`kern/trap/trap.c`中的trap()函数处理中断，在`trap_dispatch()`函数进入`interrupt_handler()`函数分支处理。

`IRQ_S_TIMER`时钟中断处理如下：

```c
case IRQ_S_TIMER:
            // "All bits besides SSIP and USIP in the sip register are
            // read-only." -- privileged spec1.9.1, 4.1.4, p59
            // In fact, Call sbi_set_timer will clear STIP, or you can clear it
            // directly.
            // cprintf("Supervisor timer interrupt\n");
             /* LAB1 EXERCISE2   2212599 2212294 2212045 :  */
            /*(1)设置下次时钟中断- clock_set_next_event()
             *(2)计数器（ticks）加一
             *(3)当计数器加到100的时候，我们会输出一个`100ticks`表示我们触发了100次时钟中断，同时打印次数（num）加一
            * (4)判断打印次数，当打印次数为10时，调用<sbi.h>中的关机函数关机
            */
            clock_set_next_event();
            ticks+=1;
            if(ticks%TICK_NUM==0){
                num+=1;
                print_ticks();
                if(num==10){
                    sbi_shutdown();
                }
            }
            break;
```



#### **【Lab 1】扩展练习 Challenge1：描述与理解中断流程**

> 描述ucore中处理中断异常的流程（从异常的产生开始），其中`mov a0，sp`的目的是什么？SAVE_ALL中寄寄存器保存在栈中的位置是什么确定的？对于任何中断，`__alltraps `中都需要保存所有寄存器吗？请说明理由。


1. **异常的产生**
   异常(Exception)，指在执行一条指令的过程中发生了错误，此时我们通过中断来处理错误。最常见的异常包括：访问无效内存地址、执行非法指令(除零)、发生缺页等。他们有的可以恢复(如缺页)，有的不可恢复(如除零)，只能终止程序执行。
   陷入(Trap)，指我们主动通过一条指令停下来，并跳转到处理函数。常见的形式有通过ecall进行系统调用(syscall)，或通过ebreak进入断点(breakpoint)。
   外部中断(Interrupt)，简称中断，指的是 CPU 的执行过程被外设发来的信号打断，此时我们必须先停下来对该外设进行处理。典型的有定时器倒计时结束、串口收到数据等。

2. **中断和异常的处理流程**
    CPU响应：CPU在执行完当前指令后，会响应中断或异常，暂停当前程序的执行，并保存当前的处理器状态（如程序计数器PC、状态寄存器等）。
    跳转到异常向量：`lab1/kern/trap/trap.c`通过如下方式判断中断或异常的类型：

    ```c
    /* trap_dispatch - dispatch based on what type of trap occurred */static inline void trap_dispatch(struct trapframe *tf) {    
        if ((intptr_t)tf->cause < 0) {        
            // interrupts        
            interrupt_handler(tf);    
        } else {        
            // exceptions        
            exception_handler(tf);    
        }
    }
    ```

     中断处理初始化函数`idt_init`，将__alltraps函数的地址赋给寄存器stvec。跳转到对应的异常向量地址，使用`trapentry.S`处理。

    ```c
    void idt_init(void) {
        extern void __alltraps(void);
        /* Set sscratch register to 0, indicating to exception vector that we are
         * presently executing in the kernel */
        write_csr(sscratch, 0);
        /* Set the exception vector address */
        write_csr(stvec, &__alltraps);
    }
    ```

    保存上下文：在ucore中，__alltraps 是中断和异常的入口点。在`lab1/kern/trap/trapentry.S`，CPU会执行以下操作，调用中断处理函数`trap`。

    ```
      __alltraps:
        SAVE_ALL
    
        move  a0, sp
        jal trap
    ```

3. `mov a0, sp`：将栈指针寄存器（`sp`）的值移动到`a0`寄存器中。这是为了在后续的保存操作中将sp的值传递给 SAVE_ALL 宏，以便在栈上保存其他寄存器的值。

4. 栈指针`sp`指向栈帧（stack frame）的顶部，将栈指针`sp`的值存储在寄存器`a0`中，也就是`a0`确定的。

5. `__alltraps `并不需要保存所有寄存器，只需要保存所有的32个通用寄存器和4个控制状态寄存器（CSR）。

#### **【Lab 1】扩展练习 Challenge2：理解上下文切换机制**

> 在`trapentry.S`中汇编代码 `csrw sscratch, sp`；`csrrw s0, sscratch, x0`实现了什么操作，目的是什么？

1. ` csrw sscratch, sp`指令，为了将保存上下文前的sp寄存器的值存入上下文，需要将保存前的sp的值存入sscratch。中断前处于S态，sscratch的值原本为0

2. `csrrw s0, sscratch, x0`：这是一个特殊的指令，它将 sscratch 的值读取到s0，并将 x0（硬编码为 0 的寄存器）的值写入 sscratch。

3. 两条汇编代码借助sscratch寄存器，成功保存了发生中断或异常时sp寄存器的值。

> save all里面保存了stval scause这些csr，而在restore all里面却不还原它们？那这样store的意义何在呢？

1. `scause`记录中断产生的原因，`stval`记录中断处理所需要的辅助信息，`sbadadd`用于存储错误或异常的地址，它们都需要在中断处理函数中被使用，比如用于判断中断类型进行分发等等。这些寄存器被封装成结构体作为参数传递给trap函数，所以需要store all以便trap函数获取异常的信息。restore all中不还原是因为在异常处理完成之后，这些异常信息已经不再被需要了，不会对原来的程序状态造成影响，还能使执行的指令数减少。

2. `sstatus` 和`sepc`两寄存器的值需恢复，`sepc`需要恢复是因为当异常发生时，处理器将当前的 PC 值存储在 `sepc` 寄存器中，在异常处理结束后可以恢复执行被中断的指令；`sstatus`存储了当前处理器的特权级别和一些处理器状态标志，用于恢复中断使能状态和特权级别。

#### **【Lab 1】扩展练习Challenge3：完善异常中断**

> 编程完善在触发一条非法指令异常` mret`和`ebreak`，在 `kern/trap/trap.c`的异常处理函数中捕获，并对其进行处理，简单输出异常类型和异常指令触发地址，即“Illegal instruction caught at 0x(地址)”，“ebreak caught at 0x（地址）”与“Exception type:Illegal instruction"，“Exception type: breakpoint”。

1. 此部分代码位于`kern/trap/trap.c`中的`exception_handler()`函数中，两种异常的处理编写方式类似，分为三步：

  （1）输出指令异常类型；

  （2）输出异常指令地址（为上下文的结构体中`epc`所指的地址）；

  （3）更新` tf->epc`寄存器，使其指向下一个地址，以便在异常处理结束后程序能够正常恢复运行。

2. 非法指令异常处理

   我们在运行时发现`0x80200052`是一个正常的指令，由于指令地址一般都是4字节对齐的，所以猜测`0x80200053`就是一个非法指令，因此我们在`kern/init/init.c`中编写测试函数`test_illegal_instruction`，并在`kern_init`调用该函数以触发非法指令异常。

   ```c
   void test_illegal_instruction() {
       asm volatile(".4byte 0x80200053");
   }
   ```
   接着我们在`tarp.c`中实现对异常的处理。

   ```c
   case CAUSE_ILLEGAL_INSTRUCTION:
                // 非法指令异常处理
                /* LAB1 CHALLENGE3   2212599 2212294 2212045 :  */
               /*(1)输出指令异常类型（ Illegal instruction）
                *(2)输出异常指令地址
                *(3)更新 tf->epc寄存器
               */
               cprintf("Exception type:Illegal instruction\n");
               cprintf("指令地址: 0x%08x\n", tf->epc);
               tf->epc += 4;
               break;
   ```

   我们还了解到`mret`是RISC-V中的特权指令，用于M态中断返回S态或U态，那么在非M态下使用该指令就意味着它是非法指令了。因此我们也更新了`test_illegal_instruction`函数。

   ```c
   void test_illegal_instruction() {
       asm volatile(".4byte 0x80200053");
       asm volatile ("mret");
   }
   ```

   经测试，两者都能触发异常指令异常，但是`mret`指令触发异常后，还会在控制台打印`sbi_emulate_csr_read: hartid0: invalid csr_num=0x302`，但是在我们所写的处理非法指令异常的程序中，并没有写相关代码。 上述语句的意思是我们在代码中使用了无效的CSR编号，或者处理器不支持某个特定CSR。机器模式异常返回(Machine-mode Exception Return)将会把pc设置为CSRs[mepc]，即mepc=0x302。这说明我们在非机器模式下使用了这个属于机器模式的特权指令，因此`mret`被当做了一条非法指令。

3. 断点异常处理
   我们了解到`ebreak`会触发一个断点中断，因此我们在`kern/init/init.c`中编写测试函数`test_breakpoint`，并在`kern_init`调用该函数以触发断定异常。

   ```c
   void test_breakpoint() {
       asm volatile("ebreak"); // 这将产生一个断点异常
   }
   ```

   接着我们在`tarp.c`中实现对异常的处理。

   ```c
   case CAUSE_BREAKPOINT:
               //断点异常处理
               /* LAB1 CHALLLENGE3   2212599 2212294 2212045 :  */
               /*(1)输出指令异常类型（ breakpoint）
                *(2)输出异常指令地址
                *(3)更新 tf->epc寄存器
               */
               cprintf("Exception type:breakpoint\n");
               cprintf("指令地址: 0x%08x\n", tf->epc);
   			//tf->epc += 4;
               tf->epc += 2;
               break;
   ```

   开始时，我们和非法指令异常处理一样，将异常处理设置为跳过4字节的异常指令，即`tf->epc += 4;`，但在实际运行中，往往会在执行上述代码中`cprintf("指令地址: 0x%08x\n", tf->epc);`指令后，就停住了，这表明断点异常处理存在问题。

   经过查阅资料，我们发现RV32IC和RV64IC中有一条2字节的ebreak指令和一条4字节的ebreak指令。我们猜测在这里可能实现的是2字节的ebreak指令，并更新断点异常处理。经过测试，证明我们的猜测没有问题。

**时钟中断、断点异常还有非法指令异常的测试结果如下**：

   ![image-20240928105320151](.\res\1.png)

其中非法指令异常中，第一条输出为`asm volatile(".4byte 0x80200053");`对应输出，第二条输出为`asm volatile ("mret");`对应输出。

**时钟中断`make grade`测试结果如下：**

![image-20240928105728090](.\res\2.png)
