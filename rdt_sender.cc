/*
 * FILE: rdt_sender.cc
 * DESCRIPTION: Reliable data transfer sender.
 * NOTE: This implementation assumes there is no packet loss, corruption, or 
 *       reordering.  You will need to enhance it to deal with all these 
 *       situations.  In this implementation, the packet format is laid out as 
 *       the following:
 *       
 *       |<-  1 byte  ->|<-             the rest            ->|
 *       | payload size |<-             payload             ->|
 *
 *       The first byte of each packet indicates the size of the payload
 *       (excluding this single-byte header)
 */


#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <iostream>
#include <iomanip>
#include <algorithm>
#include <list>

#include "rdt_struct.h"
#include "rdt_sender.h"

#define WIN_SIZE 10
#define SEQ_MAX 30
/* 2-byte header indicating the size of the payload and sequence */
#define header_size 1
/* 2-byte tail indicating the checksum */
#define checksum_size 2
/* 1-byte header indicating the sequence */
#define seq_size 1
/* maximum payload size */
#define maxpayload_size (RDT_PKTSIZE - header_size - seq_size - checksum_size)

using namespace std;

static int current_seq,received_seq;
static list<packet> window;
struct message *messagee;
static int current_cursor,last_cursor;
static int times;

struct Timers
{
	double time;
	packet *pkt;
	Timers *next;
};
static list<Timers> timers;

void fillPacket(int size,packet *packett);
static short addChecksum(packet *pkt);

/* sender initialization, called once at the very beginning */
void Sender_Init()
{
    fprintf(stdout, "At %.2fs: sender initializing ...\n", GetSimulationTime());
	current_seq=0;
	received_seq=-1;
	times=0;
}

/* sender finalization, called once at the very end.
   you may find that you don't need it, in which case you can leave it blank.
   in certain cases, you might want to take this opportunity to release some 
   memory you allocated in Sender_init(). */
void Sender_Final()
{
    fprintf(stdout, "At %.2fs: sender finalizing ...\n", GetSimulationTime());
}

/* event handler, called when a message is passed from the upper layer at the 
   sender */
void Sender_FromUpperLayer(struct message *msg)
{
	cout<<"[rdt_sender][Sender_FromUpperLayer]times="<<times++<<endl;
	cout<<"[rdt_sender][Sender_FromUpperLayer]msg->size="<<msg->size<<endl;
	//cout<<"[rdt_sender][Sender_FromUpperLayer]msg->data="<<msg->data<<endl;

    /* split the message if it is too big */

    /* reuse the same packet data structure */
    packet pkt;

    /* the cursor always points to the first unsent byte in the message */
    //int cursor = 0;

	current_cursor=last_cursor=0;
	messagee=msg;
	
    while (msg->size-last_cursor > maxpayload_size)
	{
		cout<<"[rdt_sender][Sender_FromUpperLayer]last_cursor="<<last_cursor<<endl;
		cout<<"[rdt_sender][Sender_FromUpperLayer]maxpayload_size="<<maxpayload_size<<endl;
		cout<<"[rdt_sender][Sender_FromUpperLayer]current_seq="<<current_seq<<endl;
		/* fill in the packet */
		pkt.data[0] = maxpayload_size;
		pkt.data[1]=current_seq++;
		current_seq%=SEQ_MAX;
		memcpy(pkt.data+header_size+seq_size, msg->data+last_cursor, maxpayload_size);
		short checksum=addChecksum(&pkt);
		pkt.data[RDT_PKTSIZE-2]=(char)checksum>>8;
		pkt.data[RDT_PKTSIZE-1]=(char)checksum;

		cout<<"[rdt_sender][Sender_FromUpperLayer]new pkt->size="<<(int)pkt.data[0]<<endl;
		cout<<"[rdt_sender][Sender_FromUpperLayer]new pkt->seq="<<(int)pkt.data[1]<<endl;
		/* send it out through the lower layer */
		//Sender_ToLowerLayer(&pkt);

		window.push_back(pkt);
	
		/* move the cursor */
		last_cursor += maxpayload_size;
    }

	/* send out the last packet */
	if (msg->size > last_cursor)
	{
		fillPacket(msg->size-last_cursor,&pkt);
			
		window.push_back(pkt);
    }
	
	list<packet>::iterator it;int j;
	for(j=0,it=window.begin();it!=window.end()&&j<WIN_SIZE;++it,++j)
		Sender_ToLowerLayer(&(*it));
}

/* event handler, called when a packet is passed from the lower layer at the 
   sender */
void Sender_FromLowerLayer(struct packet *pkt)
{
	received_seq=pkt->data[0];
	int expected_seq=window.front().data[1];
	cout<<"[rdt_sender][Sender_FromLowerLayer]received_seq="<<received_seq<<",expected_seq="<<expected_seq<<endl;
	if(received_seq==expected_seq)
	{
		Sender_StopTimer();
		window.pop_front();
	}
	cout<<"[rdt_sender][Sender_FromLowerLayer]end"<<endl;
}

/* event handler, called when the timer expires */
void Sender_Timeout()
{
	Sender_StartTimer(0.3);
	for(list<packet>::iterator it=window.begin();it!=window.end();++it)
		Sender_ToLowerLayer(&(*it));
}

void fillPacket(int size,packet *packett)
{
	cout<<"[rdt_sender][fillPacket]size="<<size<<",current_seq="<<current_seq<<endl;
	packett->data[0]=size;
	packett->data[1]=current_seq++;
	current_seq%=SEQ_MAX;
	memcpy(packett->data+header_size+seq_size,messagee->data+last_cursor,size);
	short checksum=addChecksum(packett);
	packett->data[RDT_PKTSIZE-2]=(char)checksum>>8;
	packett->data[RDT_PKTSIZE-1]=(char)checksum;
	last_cursor+=size;
}

static short addChecksum(packet *pkt)
{
	unsigned long sum;
	for(int i=0,sum=0;i<RDT_PKTSIZE-checksum_size;i+=2)
	{
		//cout<<"[rdt_sender][addChecksum]data["<<dec<<i<<"]=";
		//cout<<hex<<(int)(unsigned char)pkt->data[i]<<endl;
		//cout<<"[rdt_sender][addChecksum]data["<<dec<<i+1<<"]=";
		//cout<<hex<<(int)(unsigned char)pkt->data[i+1]<<endl;
		unsigned short tmp=(((unsigned short)pkt->data[i])<<8)+(unsigned)pkt->data[i+1];
		//cout<<"[rdt_sender][addChecksum]tmp="<<tmp<<endl;
		sum+=tmp;
		//cout<<"[rdt_sender][addChecksum]sum="<<sum<<endl;
	}
	while(sum>>16)
		sum=(sum>>16)+(sum&0xffff);
	return ~sum;
}