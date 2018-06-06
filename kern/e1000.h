#ifndef JOS_KERN_E1000_H
#define JOS_KERN_E1000_H

#include <inc/error.h>
#include <inc/memlayout.h>
#include <inc/string.h>
#include <kern/console.h>
#include <kern/pci.h>
#include <kern/pmap.h>

#define E1000_NTXDESCS 64
#define E1000_TX_PKT_SIZE 1518
#define E1000_TDESC_STAT_DD 0x1
#define E1000_TDBAL 0x03800
#define E1000_TDBAH 0x03804
#define E1000_TDLEN 0x03808
#define E1000_TDH 0x03810
#define E1000_TDT 0x03818
#define E1000_TCTL 0x00400
#define E1000_TIPG 0x00410
#define E1000_TCTL_EN (0x1<<1)
#define E1000_TCTL_PSP (0x1<<3)
#define E1000_TCTL_CT (0x10<<4)
#define E1000_TCTL_COLD (0x40<<12)
#define E1000_TXDESC_CMD_EOP 0x1
#define E1000_TXDESC_CMD_RS (0x1<<3)
#define E1000_TIPG 0x00410
#define E1000_TIPG_IPGT 10
#define E1000_TIPG_IPGR1 (4<<10)
#define E1000_TIPG_IPGR2 (6<<20)
#define E1000_NRXDESCS 128
#define E1000_RX_PKT_SIZE 2048
#define E1000_RAL 0x05400
#define E1000_RAH 0x05404
#define E1000_RAH_VALID (0x1<<31)
#define E1000_RDBAL 0x02800
#define E1000_RDBAH 0x02804
#define E1000_RDLEN 0x2808
#define E1000_RDH 0x02810
#define E1000_RDT 0x02818
#define E1000_RCTL 0x00100
#define E1000_RCTL_EN (0x1<<1)
#define E1000_RCTL_SECRC (0x1<<26)
#define E1000_RDESC_STAT_DD 0x1
#define E1000_EERD 0x00014

struct tx_desc
{
	uint64_t addr;
	uint16_t length;
	uint8_t cso;
	uint8_t cmd;
	uint8_t status;
	uint8_t css;
	uint16_t special;
};

struct rx_desc
{
	uint64_t addr;
	uint16_t length;
	uint16_t checksum;
	uint8_t status;
	uint8_t errors;
	uint16_t special;
};

volatile char *e1000;
int e1000_attach(struct pci_func *pcif);
int e1000_transmit(char *buf,uint32_t len);
int e1000_receive(char *data);

#endif	// JOS_KERN_E1000_H
