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
static int acwinsize;
static list<packet>::iterator next_to_send;
static list<int> ack_buffer;

struct Timers
{
	double time;
	packet *pkt;
};
static list<Timers> timers;

void fillPacket(int size,packet *packett);
static short addChecksum(packet *pkt);
static bool checkPacket(packet *pkt);
static bool isLater(int a,int b);
static void removeFormTimers(int seq);
static bool checkTimers();
static bool inAckBuffer(int seq);

/* sender initialization, called once at the very beginning */
void Sender_Init()
{
    fprintf(stdout, "At %.2fs: sender initializing ...\n", GetSimulationTime());
	current_seq=0;
	received_seq=-1;
	times=0;
	acwinsize=0;
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
	if(!checkTimers()){cout<<"[rdt_sender][Sender_FromUpperLayer]begin checkTimers failed"<<endl;exit(0);}
	//cout<<"[rdt_sender][Sender_FromUpperLayer]times="<<times++<<endl;
	//cout<<"[rdt_sender][Sender_FromUpperLayer]msg->size="<<msg->size<<endl;
	////cout<<"[rdt_sender][Sender_FromUpperLayer]msg->data="<<msg->data<<endl;

    /* split the message if it is too big */

    /* reuse the same packet data structure */
    packet pkt;

    /* the cursor always points to the first unsent byte in the message */
    //int cursor = 0;

	current_cursor=last_cursor=0;
	messagee=msg;
	
    while (msg->size-last_cursor > maxpayload_size)
	{
		////cout<<"[rdt_sender][Sender_FromUpperLayer]last_cursor="<<last_cursor<<endl;
		////cout<<"[rdt_sender][Sender_FromUpperLayer]maxpayload_size="<<maxpayload_size<<endl;
		////cout<<"[rdt_sender][Sender_FromUpperLayer]current_seq="<<current_seq<<endl;
		/* fill in the packet */
		pkt.data[0] = maxpayload_size;
		pkt.data[1]=current_seq++;
		current_seq%=SEQ_MAX;
		memcpy(pkt.data+header_size+seq_size, msg->data+last_cursor, maxpayload_size);
		short checksum=addChecksum(&pkt);
		//cout<<"[rdt_sender][Sender_FromUpperLayer]checksum1="<<(int)(char)(checksum>>8)<<endl;
		//cout<<"[rdt_sender][Sender_FromUpperLayer]checksum2="<<(int)(char)checksum<<endl;
		pkt.data[RDT_PKTSIZE-2]=checksum>>8;
		pkt.data[RDT_PKTSIZE-1]=checksum;

		////cout<<"[rdt_sender][Sender_FromUpperLayer]new pkt->size="<<(int)pkt.data[0]<<endl;
		////cout<<"[rdt_sender][Sender_FromUpperLayer]new pkt->seq="<<(int)pkt.data[1]<<endl;
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
	
	//cout<<"[rdt_sender][Sender_FromUpperLayer]acwinsize="<<acwinsize<<endl;
	if(acwinsize<WIN_SIZE)
	{
		list<packet>::iterator it;int j;
		for(j=0,it=window.begin();j<acwinsize;++j,++it){}
		for(j=acwinsize;it!=window.end()&&j<WIN_SIZE;++it,++j)
		{
			Timers timer;
			if(j==acwinsize)
				timer.time=0.3;
			else
				timer.time=0;
			timer.pkt=&(*it);
			timers.push_back(timer);
			//cout<<"[rdt_sender][Sender_FromLowerLayer]timers.push_back="<<(int)timer.pkt->data[1]<<endl;
			Sender_ToLowerLayer(&(*it));
		}
		next_to_send=it;
		acwinsize=j;
		Sender_StartTimer(0.3);
	}
	//cout<<"[rdt_sender][Sender_FromUpperLayer]acwinsize="<<acwinsize<<endl;
	if(!checkTimers()){cout<<"[rdt_sender][Sender_FromUpperLayer]end checkTimers failed"<<endl;exit(0);}
}

/* event handler, called when a packet is passed from the lower layer at the 
   sender */
void Sender_FromLowerLayer(struct packet *pkt)
{
	if(!checkTimers()){cout<<"[rdt_sender][Sender_FromLowerLayer]begin checkTimers failed"<<endl;exit(0);}
	if(!checkPacket(pkt))
		return;
	received_seq=pkt->data[0];
	int expected_seq=window.front().data[1];
	cout<<"[rdt_sender][Sender_FromLowerLayer]received_seq="<<received_seq<<",expected_seq="<<expected_seq<<endl;
	if(received_seq==expected_seq)
	{
		removeFormTimers(expected_seq);
		window.pop_front();
		expected_seq=window.front().data[1];
		--acwinsize;
		bool flag=!ack_buffer.empty();
		while(flag)
		{
			flag=false;
			for(list<int>::iterator it=ack_buffer.begin();it!=ack_buffer.end();++it)
			{
				//cout<<"[rdt_sender][Sender_FromLowerLayer]*it="<<*it<<",expected_seq="<<expected_seq<<endl;
				if(*it==expected_seq)
				{
					flag=true;
					window.pop_front();
					--acwinsize;
					ack_buffer.erase(it);
					removeFormTimers(expected_seq);
					expected_seq=window.front().data[1];
					break;
				}
			}
		}
		if(next_to_send==window.end()&&window.size()>(unsigned)acwinsize)
		{
			int i;
			for(next_to_send=window.begin(),i=0;i<acwinsize;++i,++next_to_send){}
		}
		bool first=true;
		for(;acwinsize<WIN_SIZE&&next_to_send!=window.end();++acwinsize,++next_to_send)
		{
			Sender_ToLowerLayer(&(*next_to_send));
			Timers timer;
			if(first)
			{
				timer.time=0.3;
				first=false;
			}
			else
				timer.time=0;
			timer.pkt=&(*next_to_send);
			//cout<<"[rdt_sender][Sender_FromLowerLayer]timers.push_back="<<(int)timer.pkt->data[1]<<endl;
			timers.push_back(timer);
		}
		if(timers.front().time!=0)
		{
			Sender_StopTimer();
			Sender_StartTimer(timers.front().time);
		}
	}
	else if(isLater(expected_seq,received_seq)&&!inAckBuffer(received_seq))
	{
		ack_buffer.push_back(received_seq);
		removeFormTimers(received_seq);
		//cout<<"[rdt_sender][Sender_FromLowerLayer]buffer ack="<<received_seq<<endl;
	}
	if(!checkTimers()){cout<<"[rdt_sender][Sender_FromLowerLayer]end checkTimers failed"<<endl;exit(0);}
	////cout<<"[rdt_sender][Sender_FromLowerLayer]end"<<endl;
}

/* event handler, called when the timer expires */
void Sender_Timeout()
{
	if(!checkTimers()){cout<<"[rdt_sender][Sender_Timeout]begin checkTimers failed"<<endl;exit(0);}
	Sender_StopTimer();
	if(timers.empty())
		return;
	int expected_seq=window.front().data[1];
	int expire_seq=timers.front().pkt->data[1];
	//cout<<"[rdt_sender][Sender_Timeout]expected_seq="<<expected_seq<<",expire_seq="<<expire_seq<<endl;
	if(isLater(expire_seq,expected_seq))
	{
		//cout<<"[rdt_sender][Sender_Timeout]timers.pop_front="<<(int)timers.front().pkt->data[1]<<endl;
		timers.pop_front();
		while(!timers.empty()&&timers.front().time==0&&isLater(timers.front().pkt->data[1],expected_seq))
		{
			//cout<<"[rdt_sender][Sender_Timeout]timers.pop_front="<<(int)timers.front().pkt->data[1]<<endl;
			timers.pop_front();
		}
		bool first=true;
		while(!timers.empty()&&timers.front().time==0&&!isLater(timers.front().pkt->data[1],expected_seq))
		{
			//cout<<"[rdt_sender][Sender_Timeout]resend seq="<<(int)timers.front().pkt->data[1]<<endl;
			Sender_ToLowerLayer(timers.front().pkt);
			Timers timer;
			if(first)
			{
				first=false;
				timer.time=0.3;
			}
			else
				timer.time=0;
			timer.pkt=timers.front().pkt;
			timers.push_back(timer);
			//cout<<"[rdt_sender][Sender_FromLowerLayer]timers.push_back="<<(int)timer.pkt->data[1]<<endl;
			//cout<<"[rdt_sender][Sender_Timeout]timers.pop_front="<<(int)timers.front().pkt->data[1]<<endl;
			timers.pop_front();
		}
	}
	else
	{
		//cout<<"[rdt_sender][Sender_Timeout]resend seq="<<(int)timers.front().pkt->data[1]<<endl;
		Sender_ToLowerLayer(timers.front().pkt);
		Timers timer;
		timer.time=0.3;
		timer.pkt=timers.front().pkt;
		timers.push_back(timer);
		//cout<<"[rdt_sender][Sender_FromLowerLayer]timers.push_back="<<(int)timer.pkt->data[1]<<endl;
		//cout<<"[rdt_sender][Sender_Timeout]timers.pop_front="<<(int)timers.front().pkt->data[1]<<endl;
		timers.pop_front();
		while(!timers.empty()&&timers.front().time==0)
		{
			//cout<<"[rdt_sender][Sender_Timeout]resend seq="<<(int)timers.front().pkt->data[1]<<endl;
			Sender_ToLowerLayer(timers.front().pkt);
			timer.time=0;
			timer.pkt=timers.front().pkt;
			timers.push_back(timer);
			//cout<<"[rdt_sender][Sender_FromLowerLayer]timers.push_back="<<(int)timer.pkt->data[1]<<endl;
			//cout<<"[rdt_sender][Sender_Timeout]timers.pop_front="<<(int)timers.front().pkt->data[1]<<endl;
			timers.pop_front();
		}
	}
	Sender_StartTimer(0.3);
	if(!checkTimers()){cout<<"[rdt_sender][Sender_Timeout]end checkTimers failed"<<endl;exit(0);}
}

void fillPacket(int size,packet *packett)
{
	////cout<<"[rdt_sender][fillPacket]size="<<size<<",current_seq="<<current_seq<<endl;
	packett->data[0]=size;
	packett->data[1]=current_seq++;
	current_seq%=SEQ_MAX;
	memcpy(packett->data+header_size+seq_size,messagee->data+last_cursor,size);
	short checksum=addChecksum(packett);
	////cout<<"[rdt_sender][Sender_FromUpperLayer]checksum1="<<hex<<(int)(checksum>>8)<<endl;
	////cout<<"[rdt_sender][Sender_FromUpperLayer]checksum2="<<hex<<(int)checksum<<endl;
	packett->data[RDT_PKTSIZE-2]=checksum>>8;
	packett->data[RDT_PKTSIZE-1]=checksum;
	last_cursor+=size;
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

static void removeFormTimers(int seq)
{
	if(!checkTimers()){cout<<"[rdt_sender][removeFormTimers]begin checkTimers failed"<<endl;exit(0);}
	for(list<Timers>::iterator it=timers.begin();it!=timers.end();++it)
	{
		if(it->pkt->data[1]==seq)
		{
			//cout<<"[rdt_sender][Sender_Timeout]timers.erase="<<(int)it->pkt->data[1]<<endl;
			timers.erase(it);
			break;
		}
	}
	if(!checkTimers()){cout<<"[rdt_sender][removeFormTimers]end checkTimers failed"<<endl;exit(0);}
}

static bool checkTimers()
{
	/*int j=0;
	for(list<Timers>::iterator itt=timers.begin();itt!=timers.end();++itt,++j)
	{
		//cout<<j<<" seq="<<(int)itt->pkt->data[1]<<endl;
	}
	int i=0;
	for(list<Timers>::iterator it=timers.begin();it!=timers.end();++it)
	{
		if(it->pkt->data[1]<0||it->pkt->data[1]>=SEQ_MAX)
		{
			//cout<<"checkTimers failed.i="<<i<<",seq="<<(int)it->pkt->data[1]<<endl;
			j=0;
			for(list<packet>::iterator itt=window.begin();itt!=window.end();++itt,++j)
			{
				//cout<<j<<" seq="<<(int)itt->data[1]<<endl;
			}
			return false;
		}
	}*/
	return true;
}

static bool inAckBuffer(int seq)
{
	for(list<int>::iterator it=ack_buffer.begin();it!=ack_buffer.end();++it)
	{
		if(*it==seq)
			return true;
	}
	return false;
}