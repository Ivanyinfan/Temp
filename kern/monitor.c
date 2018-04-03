// Simple command-line kernel monitor useful for
// controlling the kernel and exploring the system interactively.

#include <inc/stdio.h>
#include <inc/string.h>
#include <inc/memlayout.h>
#include <inc/assert.h>
#include <inc/x86.h>

#include <kern/console.h>
#include <kern/monitor.h>
#include <kern/kdebug.h>
#include <kern/pmap.h>

#define CMDBUF_SIZE	80	// enough for one VGA text line


struct Command {
	const char *name;
	const char *desc;
	// return -1 to force monitor to exit
	int (*func)(int argc, char** argv, struct Trapframe* tf);
};

static struct Command commands[] = {
	{ "help", "Display this list of commands", mon_help },
	{ "kerninfo", "Display information about the kernel", mon_kerninfo },
	{ "time", "", mon_time },
	{ "showmappings", "", mon_showmappings },
	{ "changepermissions", "", mon_changepermissions },
	{ "dump", "", mon_dump }
};
#define NCOMMANDS (sizeof(commands)/sizeof(commands[0]))

unsigned read_eip();

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
	return 0;
}

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
	extern char entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
		(end-entry+1023)/1024);
	return 0;
}

// Lab1 only
// read the pointer to the retaddr on the stack
static uint32_t
read_pretaddr() {
    uint32_t pretaddr;
    __asm __volatile("leal 4(%%ebp), %0" : "=r" (pretaddr)); 
    return pretaddr;
}

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
	// Your code here.
	uint32_t next_ebp,pretaddr;
	uint32_t args[5];
	uint32_t ebp=read_ebp();
	struct Eipdebuginfo info;
	int result;
	while(ebp!=0)
	{
		next_ebp=*(uint32_t *)ebp;
		pretaddr=*(uint32_t *)(ebp+4);
		for(int i=0;i<5;++i)
			args[i]=*(uint32_t *)(ebp+8+4*i);
		cprintf("eip %x ebp %x args %08x %08x %08x %08x %08x\n",pretaddr,ebp,args[0],args[1],args[2],args[3],args[4]);
		result=debuginfo_eip(pretaddr,&info);
		if(result)
			return result;
		cprintf("%s:%d: ",info.eip_file,info.eip_line);
		char buffer[info.eip_fn_namelen+1];
		snprintf(buffer,info.eip_fn_namelen+1,"%s",info.eip_fn_name);
		cprintf("%s",buffer);
		cprintf("+%d\n",pretaddr-info.eip_fn_addr);
		ebp=next_ebp;
	}
    cprintf("Backtrace success\n");
	return 0;
}

int mon_time(int argc,char **argv,struct Trapframe *tf)
{
	if(argc==1)
		return 0;
	uint64_t cycles;
	int flag=0;
	for(int i = 0;i<NCOMMANDS;++i)
	{
		if(strcmp(argv[1],commands[i].name)==0)
		{
			flag=1;
			cycles=read_tsc();
			commands[i].func(argc, argv, tf);
			cycles=read_tsc()-cycles;
			break;
		}
	}
	if(!flag)
		cprintf("Unknown command '%s'\n", argv[1]);
	else
		cprintf("%s cycles: %d\n",argv[1],cycles);
	return 0;
}

int mon_showmappings(int argc,char **argv,struct Trapframe* tf)
{
	if(argc!=3)
		return -1;
	pte_t *pte;
	uintptr_t start_va=strtol(argv[1],NULL,16);
	uintptr_t end_va=strtol(argv[2],NULL,16);
	for(uintptr_t i=PTE_ADDR(start_va);i<=PTE_ADDR(end_va);i+=PGSIZE)
	{
		cprintf("virtual address=%p,",i);
		pte_t *pte=pgdir_walk(KADDR(rcr3()),(void *)i,0);
		if(pte==NULL||!(*pte&PTE_P))
			cprintf("physical address=NULL\n");
		else if(*pte&PTE_PS)
			cprintf("physical address=%p\n",PTE_ADDR(*pte)|(PTX(i)<<PTXSHIFT));
		else
			cprintf("physical address=%p\n",PTE_ADDR(*pte));
	}
	return 0;
}

int mon_changepermissions(int argc,char **argv,struct Trapframe* tf)
{
	if(argc!=3)
		return -1;
	uintptr_t va=strtol(argv[1],NULL,16);
	uintptr_t permission=strtol(argv[2],NULL,16);
	pte_t *pte=pgdir_walk(KADDR(rcr3()),(void *)va,0);
	if(pte==NULL||!(*pte&PTE_P))
		cprintf("virtual address %p not mapped\n",va);
	else if(*pte&PTE_PS)
		*pte=PTE_ADDR(*pte)|permission|PTE_PS|PTE_P;
	else
		*pte=PTE_ADDR(*pte)|permission|PTE_P;
	return 0;
}

int mon_dump(int argc,char **argv,struct Trapframe* tf)
{
	if(argc!=3)
		return -1;
	uintptr_t *start_va=(uintptr_t *)strtol(argv[1],NULL,16);
	uintptr_t *end_va=(uintptr_t *)strtol(argv[2],NULL,16);
	for(char *i=(char *)start_va;i<=(char *)end_va;i++)
		cprintf("%p: 0x%x\n",i,*i);
	return 0;
}

/***** Kernel monitor command interpreter *****/

#define WHITESPACE "\t\r\n "
#define MAXARGS 16

static int
runcmd(char *buf, struct Trapframe *tf)
{
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
		if (*buf == 0)
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
	}
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
	return 0;
}

void
monitor(struct Trapframe *tf)
{
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
	cprintf("Type 'help' for a list of commands.\n");


	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}

// return EIP of caller.
// does not work if inlined.
// putting at the end of the file seems to prevent inlining.
unsigned
read_eip()
{
	uint32_t callerpc;
	__asm __volatile("movl 4(%%ebp), %0" : "=r" (callerpc));
	return callerpc;
}