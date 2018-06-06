#include <kern/e1000.h>

// LAB 6: Your driver code here
struct tx_desc tx_queue[E1000_NTXDESCS] __attribute__((aligned(16)));
char tx_pkt_buffer[E1000_NTXDESCS][E1000_TX_PKT_SIZE]={0};
struct rx_desc rx_queue[E1000_NRXDESCS] __attribute__((aligned(16)));
char rx_pkt_buffer[E1000_NRXDESCS][E1000_RX_PKT_SIZE]={0};

int e1000_attach(struct pci_func *pcif)
{
	pci_func_enable(pcif);
	boot_map_region(kern_pgdir, KSTACKTOP, pcif->reg_size[0], pcif->reg_base[0], PTE_W | PTE_PCD | PTE_PWT);
	e1000=(char *)KSTACKTOP;
	for(int i=0;i<E1000_NTXDESCS;i++)
	{
		tx_queue[i].addr=PADDR(tx_pkt_buffer[i]);
		tx_queue[i].status=E1000_TDESC_STAT_DD;
		tx_queue[i].length=tx_queue[i].special=0;
		tx_queue[i].cso=tx_queue[i].cmd=tx_queue[i].css=0;
	}
	*(uint32_t *)(e1000+E1000_TDBAL)=PADDR(tx_queue);
	*(uint32_t *)(e1000+E1000_TDBAH)=0;
	*(uint32_t *)(e1000+E1000_TDLEN)=sizeof(tx_queue);
	*(uint32_t *)(e1000+E1000_TDH)=0;
	*(uint32_t *)(e1000+E1000_TDT)=0;
	*(uint32_t *)(e1000+E1000_TCTL)=0;
	*(uint32_t *)(e1000+E1000_TCTL)|=E1000_TCTL_EN;
	*(uint32_t *)(e1000+E1000_TCTL)|=E1000_TCTL_PSP;
	*(uint32_t *)(e1000+E1000_TCTL)|=E1000_TCTL_CT;
	*(uint32_t *)(e1000+E1000_TCTL)|=E1000_TCTL_COLD;
	*(uint32_t *)(e1000+E1000_TIPG)=0;
	*(uint32_t *)(e1000+E1000_TIPG)|=E1000_TIPG_IPGT;
	*(uint32_t *)(e1000+E1000_TIPG)|=E1000_TIPG_IPGR1;
	*(uint32_t *)(e1000+E1000_TIPG)|=E1000_TIPG_IPGR2;
	for(int i=0;i<E1000_NRXDESCS;++i)
	{
		rx_queue[i].addr=PADDR(rx_pkt_buffer[i]);
		rx_queue[i].length=rx_queue[i].checksum=rx_queue[i].special=0;
		rx_queue[i].status=rx_queue[i].errors=0;
	}
	*(uint32_t *)(e1000+E1000_RAL)=0x12005452;
	*(uint32_t *)(e1000+E1000_RAH)=0x00005634;
	*(uint32_t *)(e1000+E1000_RAH)|=E1000_RAH_VALID;
	*(uint32_t *)(e1000+E1000_RDBAL)=PADDR(rx_queue);
	*(uint32_t *)(e1000+E1000_RDBAH)=0;
	*(uint32_t *)(e1000+E1000_RDLEN)=sizeof(rx_queue);
	*(uint32_t *)(e1000+E1000_RDH)=1;
	*(uint32_t *)(e1000+E1000_RDT)=0;
	*(uint32_t *)(e1000+E1000_RCTL)=0;
	*(uint32_t *)(e1000+E1000_RCTL)|=E1000_RCTL_EN;
	*(uint32_t *)(e1000+E1000_RCTL)|=E1000_RCTL_SECRC;
	return 0;
}

int e1000_transmit(char *data,uint32_t len)
{
	//cprintf("kern/e1000.c [e1000_transmit] data=%s,len=%d\n",data,len);
	uint32_t *tdt=(uint32_t *)(e1000+E1000_TDT);
	if((tx_queue[*tdt].status&E1000_TDESC_STAT_DD)==0)
		return -E_TX_FULL;
	memmove(tx_pkt_buffer[*tdt],data,len);
	tx_queue[*tdt].length=len;
	tx_queue[*tdt].status&=~E1000_TDESC_STAT_DD;
	tx_queue[*tdt].cmd|=E1000_TXDESC_CMD_RS;
	tx_queue[*tdt].cmd|=E1000_TXDESC_CMD_EOP;
	*tdt=(*tdt+1)%E1000_NTXDESCS;
	return 0;
}

int e1000_receive(char *data)
{
	//cprintf("kern/e1000.c [e1000_receive] data=%s\n",data);
	uint32_t rdt=(*(uint32_t *)(e1000+E1000_RDT)+1)%E1000_NRXDESCS;
	if((rx_queue[rdt].status&E1000_RDESC_STAT_DD)==0)
		return -E_RX_EMPTY;
	uint32_t len=rx_queue[rdt].length;
	memmove(data,rx_pkt_buffer[rdt],len);
	rx_queue[rdt].status &= ~E1000_RDESC_STAT_DD;
	*(uint32_t *)(e1000+E1000_RDT)=rdt;
	return len;
}

uint8_t e1000_mac[6];
void e1000_mac_eeprom()
{
	uint32_t *eerd=(uint32_t *)(e1000+E1000_EERD);
	for(int i=0;i<3;++i)
	{
		*eerd=(i<<8)|0x1;
		while((*eerd&0x10)==0);
		e1000_mac[2*i]=*eerd&0xff;
		e1000_mac[2*i+1]=(*eerd>>24)&0xff;
	}
}
		