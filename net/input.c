#include "ns.h"

extern union Nsipc nsipcbuf;

void
input(envid_t ns_envid)
{
	binaryname = "ns_input";

	// LAB 6: Your code here:
	// 	- read a packet from the device driver
	//	- send it to the network server
	// Hint: When you IPC a page to the network server, it will be
	// reading from it for a while, so don't immediately receive
	// another packet in to the same physical page.
	int r;
	while(1)
	{
		r=sys_page_alloc(0,&nsipcbuf,PTE_P|PTE_U|PTE_W);
		if(r)
			panic("input: %e",r);
		do
		{
			r=sys_net_recv(nsipcbuf.pkt.jp_data);
		}while(r<0);
		nsipcbuf.pkt.jp_len=r;
		do
		{
			r=sys_ipc_try_send(ns_envid, NSREQ_INPUT, &nsipcbuf, PTE_P|PTE_U|PTE_W);
		}while(r<0);
		
	}
}