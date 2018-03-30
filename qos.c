#include "rte_common.h"
#include "rte_mbuf.h"
#include "rte_meter.h"
#include "rte_red.h"

#include "qos.h"

struct rte_meter_srtcm rte_meter_srtcms[APP_FLOWS_MAX];
struct rte_red_config rte_red_configs[APP_FLOWS_MAX][3];
struct rte_red rte_reds[APP_FLOWS_MAX];
static int q[APP_FLOWS_MAX]={0};

/**
 * srTCM
 */
int
qos_meter_init(void)
{
    /* to do */
	struct rte_meter_srtcm_params srtcm_params[APP_FLOWS_MAX]={ {(uint64_t)640*8*1000*1000/4,384,640},{(uint64_t)640*8*1000*1000/4,384,900},{(uint64_t)640*8*1000*1000/4,384,640},{(uint64_t)640*8*1000*1000/4,384,640} };
	for(int i=0;i<APP_FLOWS_MAX;++i)
	{
		int result=rte_meter_srtcm_config(&rte_meter_srtcms[i],&srtcm_params[i]);
		if(result)
			return result;
	}
    return 0;
}

enum qos_color
qos_meter_run(uint32_t flow_id, uint32_t pkt_len, uint64_t time)
{
    /* to do */
	return rte_meter_srtcm_color_blind_check(&rte_meter_srtcms[flow_id],time,pkt_len);
}


/**
 * WRED
 */

int
qos_dropper_init(void)
{
    /* to do */
	struct rte_red_params rte_red_params[APP_FLOWS_MAX][3]=
	{
		{ {1000,1023,1,12},{1000,1023,1,12},{1000,1023,1,12} },
		{ {512,1000,1,10},{512,1000,1,9},{512,1000,1,9} },
		{ {200,800,1,5},{200,700,1,1},{200,600,1,1} },
		{ {0,600,1,1},{0,600,1,1},{0,300,1,1} }
	};
	for(int i=0;i<APP_FLOWS_MAX;++i)
	{
		for(int j=0;j<3;++j)
		{
			int result=rte_red_config_init(&rte_red_configs[i][j],rte_red_params[i][j].wq_log2,rte_red_params[i][j].min_th,rte_red_params[i][j].max_th,rte_red_params[i][j].maxp_inv);
			if(result)
			{
				printf("i=%d,j=%d,result=%d,min_th=%d,max_th=%d\n",i,j,result,rte_red_params[i][j].min_th,rte_red_params[i][j].max_th);
				return result;
			}
			//printf("[qos_dropper_init]rte_red_configs[%d][%d]min_th=%d,max_th=%d,maxp_inv=%d,wq_log2=%d\n",i,j,rte_red_configs[i][j].min_th,rte_red_configs[i][j].max_th,rte_red_configs[i][j].maxp_inv,rte_red_configs[i][j].wq_log2);
		}
	}
	return 0;
}

int
qos_dropper_run(uint32_t flow_id, enum qos_color color, uint64_t time)
{
    /* to do */
	static unsigned int i=0;
	int result=rte_red_enqueue(&rte_red_configs[flow_id][color],&rte_reds[flow_id],q[flow_id],time);
	if(!result)
		q[flow_id]++;
	if(time%1000000>i)
	{
		for(int j=0;j<APP_FLOWS_MAX;++j)
			q[j]=0;
		i++;
	}
	return result;
}
