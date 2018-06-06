#ifndef JOS_INC_SYSCALL_H
#define JOS_INC_SYSCALL_H

/* system call numbers */
enum {
	SYS_cputs = 0,
	SYS_cgetc,
	SYS_getenvid,
	SYS_env_destroy,

	SYS_map_kernel_page,

	SYS_page_alloc,
	SYS_page_map,
	SYS_page_unmap,
	SYS_exofork,
	SYS_env_set_status,
	SYS_env_set_trapframe,
	SYS_env_set_pgfault_upcall,
	SYS_env_set_priority,
	SYS_yield,
	SYS_ipc_try_send,
	SYS_ipc_recv,

	SYS_sbrk,
	SYS_time_msec,
	
	SYS_net_try_send,
	SYS_net_recv,
	SYS_load_mac,
	NSYSCALLS
};

#endif /* !JOS_INC_SYSCALL_H */