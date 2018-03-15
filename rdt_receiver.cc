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
#include <list>

#include "rdt_struct.h"
#include "rdt_receiver.h"

#define WIN_SIZE 10
#define SEQ_MAX 30
#define header_size 2
/* 2-byte tail indicating the checksum */
#define checksum_size 2

using namespace std;

static int expected_seq;
static list<packet> buffer;
static short addChecksum(packet *pkt);
static bool checkPacket(packet *pkt);
static bool isLater(int a,int b);
static bool inBuffer(int seq);

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

	if(checkPacket(pkt))
	{
		std::cout<<"[rdt_receiver][Receiver_FromLowerLayer]pkt->size="<<(int)pkt->data[0]<<std::endl;
		std::cout<<"[rdt_receiver][Receiver_FromLowerLayer]pkt->seq="<<(int)pkt->data[1]<<std::endl;
		std::cout<<"[rdt_receiver][Receiver_FromLowerLayer]expected_seq="<<expected_seq<<std::endl;
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

			packet packett;
			packett.data[0]=expected_seq;
			expected_seq=(expected_seq+1)%30;
			short checksum=addChecksum(&packett);
			////cout<<"[rdt_sender][Sender_FromUpperLayer]checksum1="<<hex<<(int)(checksum>>8)<<endl;
			////cout<<"[rdt_sender][Sender_FromUpperLayer]checksum2="<<hex<<(int)checksum<<endl;
			packett.data[RDT_PKTSIZE-2]=checksum>>8;
			packett.data[RDT_PKTSIZE-1]=checksum;
			Receiver_ToLowerLayer(&packett);
			if (msg->data!=NULL) free(msg->data);
			
			bool flag=!buffer.empty();
			while(flag)
			{
				flag=false;
				for(list<packet>::iterator it=buffer.begin();it!=buffer.end();++it)
				{
					std::cout<<"[rdt_receiver][Receiver_FromLowerLayer](it)->data[1]="<<(int)((it)->data[1])<<std::endl;
					std::cout<<"[rdt_receiver][Receiver_FromLowerLayer]expected_seq="<<expected_seq<<std::endl;
					if((it)->data[1]==expected_seq)
					{
						flag=true;
						msg->size=(it)->data[0];
						msg->data = (char*) malloc(msg->size);
						memcpy(msg->data, (it)->data+header_size, msg->size);
						Receiver_ToUpperLayer(msg);
						packett.data[0]=expected_seq;
						expected_seq=(expected_seq+1)%30;
						Receiver_ToLowerLayer(&packett);
						if (msg->data!=NULL) free(msg->data);
						buffer.erase(it);
						break;
					}
				}
			}
			
			/* don't forget to free the space */
			//if (msg->data!=NULL) free(msg->data);
			if (msg!=NULL) free(msg);
		}
		else if(isLater(expected_seq,pkt->data[1])&&!inBuffer(pkt->data[1]))
		{
			buffer.push_back(*pkt);
			std::cout<<"[rdt_receiver][Receiver_FromLowerLayer]buffer packet seq="<<(int)pkt->data[1]<<std::endl;
		}
		else
		{
			packet packett;
			packett.data[0]=pkt->data[1];
			short checksum=addChecksum(&packett);
			////cout<<"[rdt_sender][Sender_FromUpperLayer]checksum1="<<hex<<(int)(checksum>>8)<<endl;
			////cout<<"[rdt_sender][Sender_FromUpperLayer]checksum2="<<hex<<(int)checksum<<endl;
			packett.data[RDT_PKTSIZE-2]=checksum>>8;
			packett.data[RDT_PKTSIZE-1]=checksum;
			Receiver_ToLowerLayer(&packett);
		}
	}
	else
		std::cout<<"[rdt_receiver][Receiver_FromLowerLayer]checkPacket failed"<<std::endl;
	//std::cout<<"[rdt_receiver][Receiver_FromLowerLayer]end"<<std::endl;
}

static short addChecksum(packet *pkt)
{
	//cout<<"[rdt_sender][addChecksum]seq="<<dec<<(int)pkt->data[1]<<endl;
	unsigned long sum=0;
	for(int i=0;i<RDT_PKTSIZE-checksum_size;i+=2)
	{
		//cout<<"[rdt_sender][addChecksum]data["<<dec<<i<<"]=";
		//cout<<hex<<(int)(unsigned char)pkt->data[i]<<endl;
		//cout<<"[rdt_sender][addChecksum]data["<<dec<<i+1<<"]=";
		//cout<<hex<<(int)(unsigned char)pkt->data[i+1]<<endl;
		unsigned short tmp=(((unsigned short)pkt->data[i])<<8)|(pkt->data[i+1]&0x00ff);
		//cout<<"[rdt_sender][addChecksum]tmp="<<tmp<<endl;
		sum+=tmp;
		//cout<<"[rdt_sender][addChecksum]sum="<<sum<<endl;
	}
	//cout<<"[rdt_sender][addChecksum]add complete"<<endl;
	while(sum>>16)
	{
		////cout<<"[rdt_sender][addChecksum]sum="<<sum<<endl;
		////cout<<"[rdt_sender][addChecksum]sum>>16="<<(sum>>16)<<endl;
		////cout<<"[rdt_sender][addChecksum]sum&0xffff="<<(sum&0xffff)<<endl;
		sum=(sum>>16)+(sum&0xffff);
		//cout<<"[rdt_sender][addChecksum]sum="<<sum<<endl;
	}
	return ~sum;
}

static bool checkPacket(packet *pkt)
{
	cout<<"[rdt_receiver][checkPacket]seq="<<dec<<(int)pkt->data[1]<<endl;
	unsigned long sum=0;
	for(int i=0;i<RDT_PKTSIZE;i+=2)
	{
		//cout<<"[rdt_receiver][checkPacket]data["<<dec<<i<<"]=";
		//cout<<hex<<(int)(unsigned char)pkt->data[i]<<endl;
		//cout<<"[rdt_receiver][checkPacket]data["<<dec<<i+1<<"]=";
		//cout<<hex<<(int)(unsigned char)pkt->data[i+1]<<endl;
		unsigned short tmp1=(pkt->data[i]<<8);
		//cout<<"[rdt_receiver][checkPacket]tmp1="<<tmp1<<endl;
		unsigned short tmp=tmp1|(pkt->data[i+1]&0x00ff);
		//cout<<"[rdt_receiver][checkPacket]tmp="<<tmp<<endl;
		sum+=tmp;
		//cout<<"[rdt_receiver][checkPacket]sum="<<sum<<endl;
	}
	while(sum>>16)
	{
		sum=(sum>>16)+(sum&0xffff);
		//cout<<"[rdt_receiver][checkPacket]sum="<<sum<<endl;
	}
	//cout<<"[rdt_receiver][checkPacket]sum="<<sum<<endl;
	return sum==0xffff;
}

static bool isLater(int a,int b)
{
	if(a>SEQ_MAX-WIN_SIZE)
		return b>a||b<(a+WIN_SIZE)%SEQ_MAX;
	return b>a&&b<a+WIN_SIZE;
}

static bool inBuffer(int seq)
{
	for(list<packet>::iterator it=buffer.begin();it!=buffer.end();++it)
	{
		if(it->data[1]==seq)
			return true;
	}
	return false;
}