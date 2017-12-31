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
#include "assem.h" /* for debug purpose */

static int ltimes;

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

G_node allocNode(G_graph g, Temp_temp temp, TAB_table temp2node)
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

void addEdge(struct Live_graph *g, Temp_temp temp_a, Temp_temp temp_b, TAB_table temp2node, G_table spillCost)
{
	//fprintf(stdout,"[liveness][addEdge] %d a=%d,b=%d\n",ltimes,Temp_int(temp_a),Temp_int(temp_b));fflush(stdout);
    if (temp_a == temp_b || temp_a == F_FP() || temp_b == F_FP()) return; /* exclude ebp */

    G_node a = allocNode(g->graph, temp_a, temp2node);
    G_node b = allocNode(g->graph, temp_b, temp2node);
    if (!Temp_inTempList(temp_a, F_registers()))
    {
        int *r = G_look(spillCost, a);
        ++(*r);
    }
    if (!Temp_inTempList(temp_b, F_registers()))
    {
        int *r = G_look(spillCost, b);
        ++(*r);
    }
	//fprintf(stdout,"[liveness][addEdge] spillCost change complete\n");fflush(stdout);
	
    bool * cell = G_adjSet(g->adj, G_getNodecount(g->graph), G_getMykey(a), G_getMykey(b));
    //fprintf(stdout,"[liveness][addEdge] %d cell=%d\n",ltimes,*cell);fflush(stdout);
    if (!*cell) {
        /* printf("addEdge %d-%d\n", temp_a->num, temp_b->num); */

        *cell = TRUE;
        cell = G_adjSet(g->adj, G_getNodecount(g->graph), G_getMykey(b), G_getMykey(a));
        *cell = TRUE;
        G_addEdge(a, b);
        G_addEdge(b, a);
    }
    //fprintf(stdout,"[liveness][addEdge] complete\n");fflush(stdout);
}

struct Live_graph Live_liveness(G_graph flow,int times) {
	//your code here.
	//fprintf(stdout,"[liveness][Live_liveness] begin\n");fflush(stdout);
	ltimes=times;
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
            //fprintf(stdout,"[liveness][Live_liveness] %d %s",inst->key,AssemInst(inst));
            //fprintf(stdout,"[liveness][Live_liveness] inp0=");printTempList(stdout,inp0);
        	//fprintf(stdout,"[liveness][Live_liveness] outp0=");printTempList(stdout,outp0);
            Temp_tempList inp, outp;
            G_nodeList succ = G_succ(p->head);
            outp = NULL;
			//out[n]<-in[n后继]并集
            for (; succ ; succ = succ->tail)
			{
				AS_instr succInst=G_nodeInfo(succ->head);
				//fprintf(stdout,"[liveness][Live_liveness] %d %s",succInst->key,AssemInst(succInst));
                Temp_tempList ins = *(Temp_tempList*)G_look(in, succ->head);
                outp = Temp_UnionTempList(outp, ins);
                //fprintf(stdout,"[liveness][Live_liveness] inp0=");printTempList(stdout,inp0);
        		//fprintf(stdout,"[liveness][Live_liveness] outp0=");printTempList(stdout,outp0);
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
    fprintf(stdout,"[liveness][Live_liveness] in out result:\n");fflush(stdout);
    for(G_nodeList n=G_nodes(flow);n;n=n->tail)
    {
    	AS_instr inst=G_nodeInfo(n->head);
    	Temp_tempList inn = *(Temp_tempList*)G_look(in, n->head);
        Temp_tempList outn = *(Temp_tempList*)G_look(out, n->head);
        fprintf(stdout,"[liveness][Live_liveness] instr %d:\n",inst->key);fflush(stdout);
        fprintf(stdout,"[liveness][Live_liveness] in:");printTempList(stdout,inn);fflush(stdout);
        fprintf(stdout,"[liveness][Live_liveness] out:");printTempList(stdout,outn);fflush(stdout);
    }
    
    lg.moves = NULL;
    lg.graph = G_Graph();
    lg.spillCost = G_empty();

    /* 为每个临时变量创建节点 */
    for (Temp_tempList m = F_registers(); m; m = m->tail)
    {
        allocNode(lg.graph, m->head, temp2node);
    }
    
    /* 为每个节点设置spillCost值 */
    for (p = G_nodes(flow); p; p = p->tail)
	{//对于每个节点
        for (Temp_tempList def = FG_def(p->head); def; def = def->tail)
		{//对于每个节点中定值的变量
            if (def->head != F_FP())
			{//如果不是frame pointer
                int * r = checked_malloc(sizeof(int));
                *r = 0;
                G_enter(lg.spillCost, allocNode(lg.graph, def->head, temp2node), r);
            }
        }
    }
    //fprintf(stdout,"[liveness][Live_liveness] alloc spillCost complete\n");fflush(stdout);
    
    /* 预着色节点之间相互连接 */
    lg.adj = checked_malloc(G_getNodecount(lg.graph) * G_getNodecount(lg.graph) * sizeof(bool));
    //for(bool *i=lg.adj;i<G_getNodecount(lg.graph)*G_getNodecount(lg.graph);++i)
    //*i=FALSE;	
    for (Temp_tempList m1 = F_registers(); m1; m1 = m1->tail)
	{
        for (Temp_tempList m2 = F_registers(); m2; m2 = m2->tail)
		{
            if (m1->head != m2->head)
			{
                addEdge(&lg, m1->head, m2->head, temp2node, lg.spillCost);
            }
        }
    }
    //fprintf(stdout,"[liveness][Live_liveness] precolor addEdge complete\n");fflush(stdout);

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
                    lg.moves = Live_MoveList(allocNode(lg.graph, use->head, temp2node),
                            allocNode(lg.graph, def->head, temp2node),
                            lg.moves);//moveList中加入(m,n)
                }
            }
        }
        //fprintf(stdout,"[liveness][Live_liveness] build1 complete\n");fflush(stdout);
        
        //fprintf(stdout,"[liveness][Live_liveness] %d %s",inst->key,AssemInst(inst));
		//fprintf(stdout,"[liveness][Live_liveness] outp=");printTempList(stdout,outp);

        for (Temp_tempList def = FG_def(p->head); def; def = def->tail)
		{//for all d in def[n]
            for (op = outp; op; op = op->tail)
			{//for all l in live
				//addEdge(l,d)
                addEdge(&lg, def->head, op->head, temp2node, lg.spillCost);
            }
        }
        //fprintf(stdout,"[liveness][Live_liveness] build2 complete\n");fflush(stdout);
    }
    //fprintf(stdout,"[liveness][Live_liveness] complete\n");fflush(stdout);
	return lg;
}
