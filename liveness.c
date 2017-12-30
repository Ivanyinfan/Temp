#include <stdio.h>
#include "util.h"
#include "symbol.h"
#include "temp.h"
#include "tree.h"
#include "absyn.h"
#include "assem.h"
#include "frame.h"
#include "graph.h"
#include "flowgraph.h"
#include "liveness.h"
#include "table.h"

Live_moveList Live_MoveList(G_node src, G_node dst, Live_moveList tail) {
	Live_moveList lm = (Live_moveList) checked_malloc(sizeof(*lm));
	lm->src = src;
	lm->dst = dst;
	lm->tail = tail;
	return lm;
}

Temp_temp Live_gtemp(G_node n) {
	//your code here.
	return G_nodeInfo(n);
}

static Temp_tempList machine_regs = NULL;
Temp_tempList MachineRegs()
{
    if (!machine_regs) {
        machine_regs = Temp_TempList(F_eax(),
                       Temp_TempList(F_ebx(),
                       Temp_TempList(F_ecx(),
                       Temp_TempList(F_edx(),
                       Temp_TempList(F_esi(),
                       Temp_TempList(F_edi(), NULL))))));
    }
    return machine_regs;
}

G_node get_node(G_graph g, Temp_temp temp, TAB_table temp2node)
{
    G_node res = TAB_look(temp2node, temp);
    if (!res) {
        res = G_Node(g, temp);
        TAB_enter(temp2node, temp, res);
    }
    return res;
}

bool * G_adjSet(bool * set, int cnt, int i, int j)
{
    return set + (j + cnt * i);
}

void link(struct Live_graph *g, Temp_temp temp_a, Temp_temp temp_b, TAB_table temp2node, G_table rank)
{
	//////fprintf(stdout,"[liveness][link] a=%d,b=%d\n",Temp_int(temp_a),Temp_int(temp_b));fflush(stdout);
    if (temp_a == temp_b || temp_a == F_FP() || temp_b == F_FP()) return; /* exclude ebp */

    G_node a = get_node(g->graph, temp_a, temp2node);
    G_node b = get_node(g->graph, temp_b, temp2node);
    if (!Temp_inTempList(temp_a, MachineRegs()))
    {
        int *r = G_look(rank, a);
        ++(*r);
    }
    if (!Temp_inTempList(temp_b, MachineRegs()))
    {
        int *r = G_look(rank, b);
        ++(*r);
    }
	//////fprintf(stdout,"[liveness][link] rank change complete\n");fflush(stdout);
	
    bool * cell = G_adjSet(g->adj, G_getNodecount(g->graph), G_getMykey(a), G_getMykey(b));
    if (!*cell) {
        /* printf("link %d-%d\n", temp_a->num, temp_b->num); */

        *cell = TRUE;
        cell = G_adjSet(g->adj, G_getNodecount(g->graph), G_getMykey(b), G_getMykey(a));
        *cell = TRUE;
        if (!Temp_inTempList(temp_a, MachineRegs()))
            G_addEdge(a, b);
        if (!Temp_inTempList(temp_b, MachineRegs()))
            G_addEdge(b, a);
    }
    //////fprintf(stdout,"[liveness][link] complete\n");fflush(stdout);
}

struct Live_graph Live_liveness(G_graph flow) {
	//your code here.
	//fprintf(stdout,"[liveness][Live_liveness] begin\n");fflush(stdout);
	struct Live_graph lg;
    G_table in = G_empty();//节点n和in[n]的对应
    G_table out = G_empty();//节点n和out[n]的对应
    TAB_table temp2node = TAB_empty();
    G_nodeList p;
    //为每个节点in和out分配空间
    for (p = G_nodes(flow); p; p = p->tail) {
        G_enter(in, p->head, checked_malloc(sizeof(Temp_tempList*)));
        G_enter(out, p->head, checked_malloc(sizeof(Temp_tempList*)));
    }
    bool change = TRUE;
    while (change)
    {
        change = FALSE;
        p = G_nodes(flow);
		//repeat for each n
        for (; p; p = p->tail)
		{
			AS_instr inst=G_nodeInfo(p->head);
			//保存原来的in和out
            Temp_tempList inp0 = *(Temp_tempList*)G_look(in, p->head);
            Temp_tempList outp0 = *(Temp_tempList*)G_look(out, p->head);
            //////fprintf(stdout,"[liveness][Live_liveness] %d %s",inst->key,AssemInst(inst));
            //////fprintf(stdout,"[liveness][Live_liveness] inp0=");printTempList(stdout,inp0);
        	//////fprintf(stdout,"[liveness][Live_liveness] outp0=");printTempList(stdout,outp0);
            Temp_tempList inp, outp;
            G_nodeList succ = G_succ(p->head);
            outp = NULL;
			//out[n]<-in[n后继]并集
            for (; succ ; succ = succ->tail)
			{
				AS_instr succInst=G_nodeInfo(succ->head);
				//////fprintf(stdout,"[liveness][Live_liveness] %d %s",succInst->key,AssemInst(succInst));
                Temp_tempList ins = *(Temp_tempList*)G_look(in, succ->head);
                outp = Temp_UnionTempList(outp, ins);
                //////fprintf(stdout,"[liveness][Live_liveness] inp0=");printTempList(stdout,inp0);
        		//////fprintf(stdout,"[liveness][Live_liveness] outp0=");printTempList(stdout,outp0);
            }
			//in[n]<-use[n]U(out[n]-def[n])
            inp = Temp_UnionTempList(FG_use(p->head), Temp_SubTempList(outp, FG_def(p->head)));
			//检查是否改变
            if (!Temp_TempListEqual(inp, inp0))
            {
                change = TRUE;
                *(Temp_tempList*)G_look(in, p->head) = inp;
            }
            if (!Temp_TempListEqual(outp, outp0))
            {
                change = TRUE;
                *(Temp_tempList*)G_look(out, p->head) = outp;
            }
        }
    }
    ////fprintf(stdout,"[liveness][Live_liveness] in out complete\n");fflush(stdout);
    lg.moves = NULL;
    lg.graph = G_Graph();
    lg.rank = G_empty();

    /* 为每个临时变量创建节点 */
    for (Temp_tempList m = MachineRegs(); m; m = m->tail)
    {
        get_node(lg.graph, m->head, temp2node);
    }
    
    /* 为每个节点设置rank值 */
    for (p = G_nodes(flow); p; p = p->tail)
	{//对于每个节点
        for (Temp_tempList def = FG_def(p->head); def; def = def->tail)
		{//对于每个节点中定值的变量
            if (def->head != F_FP())
			{//如果不是frame pointer
                int * r = checked_malloc(sizeof(int));
                *r = 0;
                G_enter(lg.rank, get_node(lg.graph, def->head, temp2node), r);
            }
        }
    }
    ////fprintf(stdout,"[liveness][Live_liveness] alloc rank complete\n");fflush(stdout);
    
    /* 预着色节点之间相互连接 */
    lg.adj = checked_malloc(G_getNodecount(lg.graph) * G_getNodecount(lg.graph) * sizeof(bool));
    for (Temp_tempList m1 = MachineRegs(); m1; m1 = m1->tail)
	{
        for (Temp_tempList m2 = MachineRegs(); m2; m2 = m2->tail)
		{
            if (m1->head != m2->head)
			{
                link(&lg, m1->head, m2->head, temp2node, lg.rank);
            }
        }
    }
    ////fprintf(stdout,"[liveness][Live_liveness] precolor link complete\n");fflush(stdout);

	//procedure Build()
    for (p = G_nodes(flow); p; p = p->tail)
	{//对于图中每个点 for each instruction
        Temp_tempList outp = *(Temp_tempList*)G_look(out, p->head), op;
        AS_instr inst = G_nodeInfo(p->head);
        if (inst->kind == I_MOVE)
		{//如果是MOVE指令
			//live<-live\use(I)
            outp = Temp_SubTempList(outp, FG_use(p->head));
            for (Temp_tempList def = FG_def(p->head); def; def = def->tail)
			{//for all n in def[n]
                for (Temp_tempList use = FG_use(p->head); use; use = use->tail)
				{//for all m in use[n]
                    /* printf("move: %d-%d\n", def->head->num, use->head->num); */
                    lg.moves = Live_MoveList(get_node(lg.graph, use->head, temp2node),
                            get_node(lg.graph, def->head, temp2node),
                            lg.moves);//moveList中加入(m,n)
                }
            }
        }
        ////fprintf(stdout,"[liveness][Live_liveness] build1 complete\n");fflush(stdout);
        
        ////fprintf(stdout,"[liveness][Live_liveness] %d %s",inst->key,AssemInst(inst));
		////fprintf(stdout,"[liveness][Live_liveness] outp=");printTempList(stdout,outp);

        for (Temp_tempList def = FG_def(p->head); def; def = def->tail)
		{//for all d in def[n]
            for (op = outp; op; op = op->tail)
			{//for all l in live
				//addEdge(l,d)
                link(&lg, def->head, op->head, temp2node, lg.rank);
            }
        }
        ////fprintf(stdout,"[liveness][Live_liveness] build2 complete\n");fflush(stdout);
    }
    //fprintf(stdout,"[liveness][Live_liveness] complete\n");fflush(stdout);
	return lg;
}
