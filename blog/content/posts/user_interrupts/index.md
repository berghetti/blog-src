---
title: "User Interrupts"
date: 2024-12-25T18:23:00-00:00
authors: ["Mayco S. Berghetti"]
#tags: [ "C" ]
categories: [
    "programming", "computing"
]
draft: false
---

## Whats Is

User interrupts is a new processor feature that enables delivery of
interrupts directly to user space, without kernel intervention [^1]. Let’s explore how it works.

## How Works

Tasks that want use user interrupts feature need setup some structures and MSR
registers before. Here we not go see how to this feature is implemented in
details in kernel linux, with all requirements for security, but go see the
basic to this feature "works". Furthermore, currently, patch to this feature is
not in linux kernel tree [^2]. Minor details can be omitted, read Intel
Manual to more details[^3]. This feature can be divided into receiver and
sender procedures, each requiring a different setup. Let's look at this.

### Receiver

The Receive should do some setup before start receive interrupts. First, the
MSR **IA32_UINTR_PD** should contain the address of a structure named User
Posted-Interrupt Descriptor (UPID). Let's see this structure in details.

```c
/* User Posted Interrupt Descriptor (UPID) */
struct uintr_upid
{
  struct
    {
	    u8 status;      /* bit 0: ON, bit 1: SN, bit 2-7: reserved */
	    u8 reserved1;   /* Reserved */
	    u8 nv;          /* Notification vector */
	    u8 reserved2;   /* Reserved */
	    u32 ndst;       /* Notification destination */
    } nc __packed;    /* Notification control */
  u64 puir;         /* Posted user interrupt requests */
} __aligned(64);
```

The field **ndst** is the APIC ID of current CPU and the field **nv** is the
notification vector used by `SENDUIPI`. The **nv** is like a IRQ index (more bellow).
See how this values are assigned on kernel linux patch.

```c
static inline u32 cpu_to_ndst(int cpu)
{
	u32 apicid = (u32)apic->cpu_present_to_apicid(cpu);

	WARN_ON_ONCE(apicid == BAD_APICID);

	if (!x2apic_enabled())
		return (apicid << 8) & 0xFF00;

	return apicid;
}
...
upid->nc.nv = UINTR_NOTIFICATION_VECTOR;
upid->nc.ndst = cpu_to_ndst(cpu);
```

The field **nv** is used to identify the source of interrupts by CPU. Since the
CPU receive interrupts from many sources, as keyboard and network, when a
interrupt arrive, the APIC provides an interrupt vector **V** to the CPU.
With value **V**, the CPU can identify the source of interrupt and call the
appropriate interrupt handler on IDT (Interrupt Descriptor Table). In case of
uintr, **V** is equal **nv** and the CPU not call IDT entry. Instead, the CPU
recognize the interrupt as a user interrupt. The **nv** field should be copied in MSR
**IA32_UINTR_MISC[39:32]**, also called of **UINV**, to that the CPU can compare
with **V** when a interrupt arrive.

Since the **ndst** field represent the APIC ID of local CPU, that is used by
`SENDUIPI`, this value should be updated when the task is moved to other CPU.

The field **puir** is the interrupt request. Each bit on this filed represent a
distinct user vector interrupt. Each thread has a private vector space of 64
vectors ranging from 0-63. Vector number 63 has the highest priority while
vector number 0 has the lowest. If **puir** has more that one bit set, the
interrupts are delivered from highest to lowest priority order. This is useful
to implement a "IDT like" in user space task since when the interrupt is
delivered, the vector number is pushed on stack. Furthermore, when CPU identify
a user interrupt, he copy **puir** value into MSR **IA32_UINTR_RR**, also called
**UIRR**. Once CPU recognize a user interrupt, CPU-logic start to prepare the
change flow to user interrupt handler, instead normal IDT interrupt flow.

In **status** field only two bits are used. When bit 0 if is set, one or more user
interrupt is waiting, and `puir != 0`. If bit 1 is set, notifications not should be
generated when sending a user interrupt, and `SENDUIPI` not should send a
interrupt.

Second, the address of user interrupt handler (*uhandler*) should be stored in MSR
**IA32_UINTR_HANDLER**. Unlike POSIX signal handlers, *uhandlers* should preserve/restore all register used in handler because this not  is
managed by kernel. Furthermore, when the *uhandlers* is called by hardware, the
**UIRR**, value of **puir**, is pushed on stack and should be release before return of *uhandler*.
To return, the instruction `UIRET` should be used to free all uintr state
created to interrupt delivery. The pseudo-code bellow show as a *uhandler* may
look.

```asm
/* not use pushad/popad, this only a example and this instructions not works on x86_64 */
pushad        /* save all general purpose registers */
call uhandler /* call high level handler (ensure that uhandler not use float point registers)*/
popad         /* restore registers */
add $8, $rsp  /* release UIRR of stack */
uiret         /* clear uintr state create by hardware interrupt delivery and
                 return to point before interrupt */
```

Finally, to start receive user interrupts, the receiver need enable the **UIF** (User
Interrupt Flag) using the instruction `stui`. The **UIF** can be disabled using
the instruction `clui`. This instructions not are privileged. Furthermore, when a user interrupt is delivered this
flag is disabled by hardware, avoiding receive other user interrupt while in
*uhandler*, and enable again by `UIRET` instruction.

### Sender

Before send a user interrupt, using `SENDUIPI` instruction, the sender need
setup the User-Interrupt Target Table (**UITT**). The **UITT** structure address should
be store on MSR **IA32_UINTR_TT**, in addition, bit 0 this register enables use of
`SENDUIPI`. The `SENDUIPI` instruction taken a index to **UITT**. Each entry on
**UITT** has structure shown below.

```c
/* User Interrupt Target Table Entry (UITTE) */
struct uintr_uitt_entry
{
	u8	valid;              /* bit 0: valid, bit 1-7: reserved */
	u8	user_vec;           /* in range of 0-63 */
	u8	reserved[6];
	u64	target_upid_addr;   /* UPID struct address of target of interrupt */
} __packed __aligned(16);
```

The field **valid** only accept values **0** or **1** if the entry if invalid or
valid espectively. The field **user_vec** is the value that will be placed on
**puir** on target **UPID** structure. Latly, **target_upid_addr** is the
address of **UPID** structure of target.

After the **UITT** is configured, a user space task can use the `SENDUIPI`
instruction the send a user interrupt.

## Performance

I wrote a test to compare the performance of user level interrupts and POSIX
signals. The test is done using two threads. The first
thread (sender) send interrupts to second thread (receiver). When the sender
send a interrupt, he wait the receiver receive the interrupt and return from
interrupt handler before send other interrupt.

The test, done using a *Intel(R) Xeon(R) Gold 6438Y+* processor, send 500.000
interrupts and measure, in nanoseconds, different points. The test show
different percentiles, but to brevity here is shown only the minimum, median and
maximum.


### Send
This results show the time wast to send a interrupt by sender thread. This only
show the overhead of sender thread to send a interrupt and not takes into
account if the interruption has already been delivered or not.

| Metric  | UINTR (ns) | Signal (ns) | Comparison (Signal/UINTR) |
|---------|-----------------|-------------------|---------------------------|
| Min     | 163             | 968               | 5.9                       |
| Median  | 259             | 1075              | 4.2                       |
| Max     | 3774            | 12991             | 3.4                       |

### Delivery
This results show the time wast to a complete interrupt delivery. The time start
when sender thread send the interrupt and finish when the receiver thread enters
on interrupt handler. This take into account three overhead sources: sender,
propagation on system and receiver.

| Metric  | UINTR (ns) | Signal (ns) | Comparison (Signal/UINTR) |
|---------|-----------------|-------------------|---------------------------|
| Min     | 612             | 2568              | 4.2                       |
| Median  | 1015            | 2672              | 2.6                       |
| Max     | 12929           | 109133            | 8.4                       |

### Receive
This results show the time wast to receiver thread exit the normal execution
flow and enter on handler interrupt.

| Metric  | UINTR (ns) | Signal (ns) | Comparison (Signal/UINTR) |
|---------|-----------------|-------------------|---------------------------|
| Min     | 402             | 1551              | 3.9                       |
| Median  | 629             | 1647              | 2.6                       |
| Max     | 13269           | 107851            | 8.1                       |

### Return
This results show the time wast to receiver thread exit from handler interrupt
and return to normal execution flow. The sum of table **receive** with this table give us the total
overhead of receiver (not shown).

| Metric  | UINTR (ns) | Signal (ns) | Comparison (Signal/UINTR) |
|---------|-----------------|-------------------|---------------------------|
| Min     | 41              | 712               | 17.4                      |
| Median  | 46              | 799               | 17.4                      |
| Max     | 356             | 4416              | 12.4                      |


## Conclusion

User level interrupts is a great new hardware feature that improve IPIs to user
level tasks. This feature can be used in many cases that need high performance
but can't spend CPU cycles doing polling, software dispatchers, user level
schedulers that implement preemptable user level threads to fast context switch.

[^1]: https://lwn.net/Articles/869140/
[^2]: https://github.com/intel/uintr-linux-kernel
[^3]:
	https://www.intel.com/content/www/us/en/developer/articles/technical/intel-sdm.html (Vol. 3A, Chapter 7)
