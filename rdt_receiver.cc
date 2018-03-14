/*
 * FILE: rdt_receiver.cc
 * DESCRIPTION: Reliable data transfer receiver.
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

#include "rdt_struct.h"
#include "rdt_receiver.h"

#define header_size 2

using namespace std;

static int expected_seq;
static bool checkPacket(packet *pkt);

/* receiver initialization, called once at the very beginning */
void Receiver_Init()
{
    fprintf(stdout, "At %.2fs: receiver initializing ...\n", GetSimulationTime());
	expected_seq=0;
}

/* receiver finalization, called once at the very end.
   you may find that you don't need it, in which case you can leave it blank.
   in certain cases, you might want to use this opportunity to release some 
   memory you allocated in Receiver_init(). */
void Receiver_Final()
{
    fprintf(stdout, "At %.2fs: receiver finalizing ...\n", GetSimulationTime());
}

/* event handler, called when a packet is passed from the lower layer at the 
   receiver */
void Receiver_FromLowerLayer(struct packet *pkt)
{
    /* 1-byte header indicating the size of the payload 
    int header_size = 1;*/

	std::cout<<"[rdt_receiver][Receiver_FromLowerLayer]pkt->size="<<(int)pkt->data[0]<<std::endl;
	std::cout<<"[rdt_receiver][Receiver_FromLowerLayer]pkt->seq="<<(int)pkt->data[1]<<std::endl;
	if(checkPacket(pkt)&&pkt->data[1]==expected_seq)
	{
		if(pkt->data[1]==expected_seq)
		{
			/* construct a message and deliver to the upper layer */
			struct message *msg = (struct message*) malloc(sizeof(struct message));
			ASSERT(msg!=NULL);

			msg->size = pkt->data[0];

			/* sanity check in case the packet is corrupted 
			if (msg->size<0) msg->size=0;
			if (msg->size>RDT_PKTSIZE-header_size) msg->size=RDT_PKTSIZE-header_size;*/

			msg->data = (char*) malloc(msg->size);
			ASSERT(msg->data!=NULL);
			memcpy(msg->data, pkt->data+header_size, msg->size);
			Receiver_ToUpperLayer(msg);

			/* don't forget to free the space */
			if (msg->data!=NULL) free(msg->data);
			if (msg!=NULL) free(msg);
		
			packet packett;
			packett.data[0]=expected_seq;
			expected_seq=(expected_seq+1)%30;
			Receiver_ToLowerLayer(&packett);
		}
		else
			std::cout<<"[rdt_receiver][Receiver_FromLowerLayer]pkt->data[1]!=expected_seq"<<std::endl;
	}
	else
		std::cout<<"[rdt_receiver][Receiver_FromLowerLayer]checkPacket failed"<<std::endl;
}

static bool checkPacket(packet *pkt)
{
	/*unsigned long sum;
	for(int i=0,sum=0;i<RDT_PKTSIZE;i+=2)
	{
		cout<<"[rdt_sender][checkPacket]data["<<dec<<i<<"]=";
		cout<<hex<<(int)(unsigned char)pkt->data[i]<<endl;
		cout<<"[rdt_sender][checkPacket]data["<<dec<<i+1<<"]=";
		cout<<hex<<(int)(unsigned char)pkt->data[i+1]<<endl;
		unsigned short tmp=(((unsigned short)pkt->data[i])<<8)+(unsigned)pkt->data[i+1];
		cout<<"[rdt_sender][checkPacket]tmp="<<tmp<<endl;
		sum+=tmp;
		cout<<"[rdt_sender][checkPacket]sum="<<sum<<endl;
	}
	while(sum>>16)
		sum=(sum>>16)+(sum&0xffff);
	cout<<"[rdt_sender][checkPacket]sum="<<sum<<endl;
	//return sum==0xffff;*/
	return true;
}