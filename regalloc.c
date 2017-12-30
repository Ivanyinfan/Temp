#include <stdio.h>
#include "util.h"
#include "symbol.h"
#include "temp.h"
#include "tree.h"
#include "absyn.h"
#include "assem.h"
#include "frame.h"
#include "graph.h"
#include "liveness.h"
#include "color.h"
#include "regalloc.h"
#include "table.h"
#include "flowgraph.h"

#define K 6
#define MAXLINE 40

/* 使用预定义功能 G_nodeList G_NodeList(G_node head, G_nodeList tail) */

static char *reg_names[7] = {"undef", "%eax", "%ebx", "%ecx", "%edx", "%esi", "%edi"};

static bool *adjSet;
static G_graph graph;
static G_table degree;
static G_table color;
static G_table alias;
static G_table rank;
static G_nodeList spillWorklist;
static G_nodeList simplifyWorklist;
static G_nodeList spillNodes;
static G_nodeList coalescedNodes;
static G_nodeList freezeWorklist;
static G_nodeList selectStack;//从图中删除的临时变量的栈

static Live_moveList coalescedMoves;  //已经合并的传送指令集合
static Live_moveList constrainedMoves;//源操作数和目标操作数冲突的传送指令
static Live_moveList frozenMoves;     //不再考虑合并的传送指令集合
static Live_moveList worklistMoves;   //有可能合并的传送指令集合
static Live_moveList activeMoves;     //还未做好合并准备的传送指令集合

static int times;
struct RA_result RA_regAlloc(F_frame f, AS_instrList il) {
	//your code here
	fprintf(stdout,"[regalloc][RA_regAllocp] begin\n");fflush(stdout);
	struct RA_result ret;
	struct Live_graph live_graph;
    bool done = FALSE;
    for(times=1;!done;++times)
    {
    	fprintf(stdout,"[regalloc][RA_regAllocp] allocing\n");fflush(stdout);
        G_graph flow_graph = FG_AssemFlowGraph(il, f);
        live_graph = Live_liveness(flow_graph,times);
        Build(live_graph);
        MakeWorklist();
        while (simplifyWorklist || spillWorklist || worklistMoves || freezeWorklist)
		{
            if (simplifyWorklist)
				Simplify();
            else if (worklistMoves)
                Coalesce();
            else if (freezeWorklist)
                Freeze();
            else if (spillWorklist)
                SelectSpill();
        }
        AssignColors();
        if (spillNodes)
            RewriteProgram(f, &il);
        else
            done = TRUE;
    }

    ret.il = il;
	ret.coloring = generate_map();
	fprintf(stdout,"[regalloc][RA_regAllocp] complete\n");fflush(stdout);
	return ret;
}

static void Build(struct Live_graph g)
{
	fprintf(stdout,"[regalloc][Build] begin\n");fflush(stdout);
    degree = G_empty();
    color = G_empty();
    alias = G_empty();
    for (G_nodeList p = G_nodes(g.graph); p; p = p->tail)
	{//对于每个节点
        int * t = checked_malloc(sizeof(int));
        *t = 0;
		//算度数，即后继的数量
        for (G_nodeList cur = G_succ(p->head); cur; cur = cur->tail)
		{
            ++(*t);
        }
        G_enter(degree, p->head, t);

		//预着色节点着色，其他节点颜色为0
        int * c = checked_malloc(sizeof(int));
        Temp_temp temp = Live_gtemp(p->head);
        if (temp == F_eax()) {
            *c = 1;
        } else if (temp == F_ebx()) {
            *c = 2;
        } else if (temp == F_ecx()) {
            *c = 3;
        } else if (temp == F_edx()) {
            *c = 4;
        } else if (temp == F_esi()) {
            *c = 5;
        } else if (temp == F_edi()) {
            *c = 6;
        } else {
            *c = 0;
        }
        G_enter(color, p->head, c);

		//每个点和自己合并 ？
        G_node * a = checked_malloc(sizeof(G_node));
        *a = p->head;
        G_enter(alias, p->head, a);
    }
	
	//初始化
    graph = g.graph;
    adjSet = g.adj;
    rank = g.rank;
    spillWorklist = NULL;
    simplifyWorklist = NULL;
    freezeWorklist = NULL;
    worklistMoves = g.moves;
    activeMoves = NULL;
    frozenMoves = NULL;
    constrainedMoves = NULL;
    coalescedMoves = NULL;
    selectStack = NULL;
    coalescedNodes = NULL;
}

/* P178 procedure MakeWorklist */
static void MakeWorklist()
{
	fprintf(stdout,"[regalloc][MakeWorklist] begin\n");fflush(stdout);
    G_nodeList nodes = G_nodes(graph);
    for (; nodes; nodes = nodes->tail)
	{
        int *deg = G_look(degree, nodes->head);
        int *c = G_look(color, nodes->head);
        if (*c == 0)
		{//如果不是预着色的节点
            if (*deg >= K)
                spillWorklist = G_NodeList(nodes->head, spillWorklist);
            else if (MoveRelated(nodes->head))
                freezeWorklist = G_NodeList(nodes->head, freezeWorklist);
            else
                simplifyWorklist = G_NodeList(nodes->head, simplifyWorklist);
        }
    }
}

//从图中去掉一个节点并减少相邻节点的度数
static void Simplify()
{
	fprintf(stdout,"[regalloc][Simplify] begin\n");fflush(stdout);
    G_node cur = simplifyWorklist->head;
    simplifyWorklist = simplifyWorklist->tail;
    /*
    assert(!precolored(cur));
    printf("pushed: %d\n", Live_gtemp(cur)->num);
    */
    selectStack = G_NodeList(cur, selectStack);
    fprintf(stdout,"[regalloc][Simplify] simplify %d\n",Temp_int(G_nodeInfo(cur)));fflush(stdout);
    for (G_nodeList p = Adjacent(cur); p; p = p->tail)
        DecrementDegree(p->head);
}

static G_nodeList Adjacent(G_node n)
{
    return G_SubNodeList(G_SubNodeList(G_succ(n), selectStack), coalescedNodes);
}

//将一个节点的度数减一，它可能变成可合并的
static void DecrementDegree(G_node m)
{
    int *d1 = G_look(degree, m);
    int *c = G_look(color, m);
    int d2 = *d1;
    *d1 = d2 - 1;
	//为什么要G_inNodeList(m, spillWorklist)？
    if (d2 == K && *c == 0 && G_inNodeList(m, spillWorklist))
	{
        EnableMoves(G_NodeList(m, Adjacent(m)));
        spillWorklist = G_SubNodeList(spillWorklist, G_NodeList(m, NULL));
        if (MoveRelated(m))
            freezeWorklist = G_NodeList(m, freezeWorklist);
        else
            simplifyWorklist = G_NodeList(m, simplifyWorklist);
    }
}

static void EnableMoves(G_nodeList nodes)
{
    for (G_nodeList i = nodes; i; i = i->tail)
	{
        for (Live_moveList m = NodeMoves(i->head); m; m = m->tail)
		{
            if (Live_inMoveList(m->src, m->dst, activeMoves))
			{
                activeMoves = Live_SubMoveList(activeMoves, Live_MoveList(m->src, m->dst, NULL));
                worklistMoves = Live_UnionMoveList(worklistMoves, Live_MoveList(m->src, m->dst, NULL));
            }
        }
    }
}

static Live_moveList NodeMoves(G_node n)
{
    Live_moveList p = Live_UnionMoveList(activeMoves, worklistMoves);
    Live_moveList res = NULL;
    G_node m = GetAlias(n);
    for (Live_moveList cur = p; cur; cur = cur->tail) {
        if (GetAlias(cur->src) == m || GetAlias(cur->dst) == m) {
            res = Live_MoveList(cur->src, cur->dst, res);
        }
    }
    return res;
}

static bool MoveRelated(G_node n)
{
    return NodeMoves(n) != NULL;
}

static void Coalesce()
{
	fprintf(stdout,"[regalloc][Coalesce] begin\n");fflush(stdout);
	//选一个点
    G_node src = worklistMoves->src;
    G_node dst = worklistMoves->dst;
	worklistMoves = worklistMoves->tail;
	G_node u,v;
    if (precolored(GetAlias(dst)))
	{
        u = GetAlias(dst);
        v = GetAlias(src);
    }
	else
	{
        u = GetAlias(src);
        v = GetAlias(dst);
    }

    /*
    Temp_temp a = G_nodeInfo(u);
    Temp_temp b = G_nodeInfo(v);
    printf("coalese: %d %d\n", a->num, b->num);
    */
    bool * cell = G_adjSet(adjSet, G_getNodecount(graph), G_getMykey(u), G_getMykey(v));
    if (u == v)
	{
        coalescedMoves = Live_MoveList(src, dst, coalescedMoves);
        AddWorklist(u);
    }
	else if (precolored(v) || *cell)
	{
        constrainedMoves = Live_MoveList(src, dst, constrainedMoves);
        AddWorklist(u);
        AddWorklist(v);
    }
	else if ((precolored(u) && OK(v, u)) || (!precolored(u) && Conservative(G_UnionNodeList(Adjacent(u), Adjacent(v)))))
	{
		fprintf(stdout,"[regalloc][Coalesce] coalesce %d %d\n",Temp_int(G_nodeInfo(u)),Temp_int(G_nodeInfo(v)));fflush(stdout);
        coalescedMoves = Live_MoveList(src, dst, coalescedMoves);
        Combine(u, v);
        AddWorklist(u);
    }
	else
	{
        activeMoves = Live_MoveList(src, dst, activeMoves);
    }
}

static G_node GetAlias(G_node n)
{
    G_node  *a = G_look(alias, n);
    if (*a != n) {
        *a = GetAlias(*a);
    }
    return *a;
}

static void AddWorklist(G_node u)
{
    int * deg = G_look(degree, u);
    if (!precolored(u) && !MoveRelated(u) && *deg < K) {
        /* assert(G_inNodeList(u, freezeWorklist)); */
        freezeWorklist = G_SubNodeList(freezeWorklist, G_NodeList(u, NULL));
        simplifyWorklist = G_NodeList(u, simplifyWorklist);
    }
}

static bool precolored(G_node n)
{
    int *c = G_look(color, n);
    return *c;
}

static bool OK(G_node v, G_node u)
{
    for (G_nodeList p = Adjacent(v); p; p = p->tail)
	{
        int * deg = G_look(degree, p->head);
        bool * cell = G_adjSet(adjSet, G_getNodecount(graph), G_getMykey(p->head), G_getMykey(u));
        if (!precolored(p->head) && *deg >= K && !(*cell))
            return FALSE;
    }
    return TRUE;
}

static bool Conservative(G_nodeList nodes)
{
    int k = 0;
    for (G_nodeList n = nodes; n; n = n->tail)
	{
        int *deg = G_look(degree, n->head);
        if (precolored(n->head) || *deg >= K)
            ++k;
    }
    return (k < K);
}

/* 用于Coalesce选定后合并两个节点 */
static void Combine(G_node u, G_node v)
{
	fprintf(stdout,"[regalloc][Combine] %d u=%d,v=%d\n",times,Temp_int(G_nodeInfo(u)),Temp_int(G_nodeInfo(v)));fflush(stdout);
    if (G_inNodeList(v, freezeWorklist))
        freezeWorklist = G_SubNodeList(freezeWorklist, G_NodeList(v, NULL));
    else
        spillWorklist = G_SubNodeList(spillWorklist, G_NodeList(v, NULL));
    coalescedNodes = G_NodeList(v, coalescedNodes);
    G_node * al = G_look(alias, v);
    fprintf(stdout,"[regalloc][Combine] %d alias[v]=%d\n",times,Temp_int(G_nodeInfo(*al)));fflush(stdout);
    *al = u;
    for (G_nodeList t = Adjacent(v); t; t = t->tail)
	{
		fprintf(stdout,"[regalloc][Combine] Adjacent(v)=%d\n",Temp_int(G_nodeInfo(t->head)));fflush(stdout);
        AddEdge(t->head, u);
        DecrementDegree(t->head);
    }
    int * deg = G_look(degree, u);
    fprintf(stdout,"[regalloc][Combine] deg=%d\n",*deg);fflush(stdout);
    if (*deg >= K && G_inNodeList(u, freezeWorklist))
	{
        freezeWorklist = G_SubNodeList(freezeWorklist, G_NodeList(u, NULL));
        spillWorklist = G_NodeList(u, spillWorklist);
    }
}

static void AddEdge(G_node u, G_node v)
{
	fprintf(stdout,"[regalloc][AddEdge] %d u=%d,v=%d\n",times,Temp_int(Live_gtemp(u)),Temp_int(Live_gtemp(v)));fflush(stdout);
    bool * cell = G_adjSet(adjSet, G_getNodecount(graph), G_getMykey(u), G_getMykey(v));
    fprintf(stdout,"[regalloc][AddEdge] %d cell=%d\n",times,*cell);fflush(stdout);
    if (u != v && !*cell) {
        /*
        Temp_temp a = G_nodeInfo(u);
        Temp_temp b = G_nodeInfo(v);
        printf("link %d-%d\n", a->num, b->num);
        */
        *cell = TRUE;
        cell = G_adjSet(adjSet, G_getNodecount(graph), G_getMykey(v), G_getMykey(u));
        *cell = TRUE;
        if (!precolored(u)) {
            int * deg = G_look(degree, u);
            ++(*deg);
            G_addEdge(u, v);
        }
        if (!precolored(v)) {
            int * deg = G_look(degree, v);
            ++(*deg);
            G_addEdge(v, u);
        }
    }
}

static void Freeze()
{
	////fprintf(stdout,"[regalloc][Freeze] begin\n");fflush(stdout);
    G_node u = freezeWorklist->head;
    freezeWorklist = freezeWorklist->tail;
    simplifyWorklist = G_NodeList(u, simplifyWorklist);
    FreezeMoves(u);
}

static void FreezeMoves(G_node u)
{
    G_node v;
    for (Live_moveList m = NodeMoves(u); m; m = m->tail)
	{
        if (GetAlias(m->dst) == GetAlias(u))
            v = GetAlias(m->src);
		else
            v = GetAlias(m->dst);
        activeMoves = Live_SubMoveList(activeMoves, Live_MoveList(m->src, m->dst, NULL));
        frozenMoves = Live_UnionMoveList(frozenMoves, Live_MoveList(m->src, m->dst, NULL));
        int *deg = G_look(degree, v);
        if (!MoveRelated(v) && !precolored(v) && *deg < K) {
            /* assert(G_inNodeList(v, freezeWorklist)); */
            freezeWorklist = G_SubNodeList(freezeWorklist, G_NodeList(v, NULL));
            simplifyWorklist = G_NodeList(v, simplifyWorklist);
        }
    }
}

static void SelectSpill()
{
	fprintf(stdout,"[regalloc][SelectSpill] begin\n");fflush(stdout);
    G_node m = spillWorklist->head;
    int max = *(int *)G_look(rank, m);
	/* 根据rank的值来选择溢出的点 */
    for (G_nodeList p = spillWorklist->tail; p; p = p->tail)
	{
        int t = *(int *)G_look(rank, p->head);
        if (Live_gtemp(p->head)->spilled)
		{
            t = 0; /* spilled register has a lower priority to be spilled again */
        }
        if (t > max) {
            max = t;
            m = p->head;
        }
    }
    /*
    Temp_temp a = G_nodeInfo(m);
    int *d = G_look(degree, m);
    printf("spill: %d %x %d\n", a->num, adjacent(m), *d);
    */
    fprintf(stdout,"[regalloc][SelectSpill] spill %d\n",Temp_int(G_nodeInfo(m)));fflush(stdout);
    spillWorklist = G_SubNodeList(spillWorklist, G_NodeList(m, NULL));
    simplifyWorklist = G_NodeList(m, simplifyWorklist);
    FreezeMoves(m);
}

static void AssignColors()
{
	fprintf(stdout,"[regalloc][AssignColors] %d begin\n",times);fflush(stdout);
    bool used[K+1];
    int i;
    spillNodes = NULL;
    while (selectStack)
    {
        G_node cur = selectStack->head;
        selectStack = selectStack->tail;
        fprintf(stdout,"[regalloc][AssignColors] %d cur=%d\n",times,Temp_int(Live_gtemp(cur)));fflush(stdout);
        /*
        printf("coloring %d\n", Live_gtemp(cur)->num);
        assert(GetAlias(cur) == cur);
        assert(!precolored(cur));
        */
        for (i = 1; i <= K; ++i) {
            used[i] = FALSE;
        }
        for (G_nodeList p = G_succ(cur); p; p = p->tail)
        {
            int *t = G_look(color, GetAlias(p->head));
            fprintf(stdout,"[regalloc][AssignColors] %d curSucc=%d,color=%d\n",times,Temp_int(Live_gtemp(p->head)),*t);fflush(stdout);
            used[*t] = TRUE;
        }
        fprintf(stdout,"[regalloc][AssignColors] %d get succ complete\n",times);fflush(stdout);
        for (i = 1; i <= K; ++i) {
            if (!used[i]) {
                break;
            }
        }
        if (i > K) {
            spillNodes = G_NodeList(cur, spillNodes);
        } else {
            int *c = G_look(color, cur);
            *c = i;
			fprintf(stdout,"[regalloc][AssignColors] %d %d=%s\n",times,Temp_int(Live_gtemp(cur)),reg_names[i]);fflush(stdout);
        }
    }
    for (G_nodeList p = G_nodes(graph); p != NULL; p = p->tail)
    {
    	fprintf(stdout,"[regalloc][AssignColors] %d GetAlias(p->head)=%d\n",times,Temp_int(Live_gtemp(GetAlias(p->head))));fflush(stdout);
    	fprintf(stdout,"[regalloc][AssignColors] %d p->head=%d\n",times,Temp_int(Live_gtemp(p->head)));fflush(stdout);
        int *c0 = G_look(color, GetAlias(p->head));
        int *c = G_look(color, p->head);
        *c = *c0;
        fprintf(stdout,"[regalloc][AssignColors] %d %d=%d=%s\n",times,Temp_int(Live_gtemp(p->head)),Temp_int(Live_gtemp(GetAlias(p->head))),reg_names[*c]);fflush(stdout);
    }
    ////fprintf(stdout,"[regalloc][AssignColors] complete\n");fflush(stdout);
}

static void RewriteProgram(F_frame f, AS_instrList *pil)
{
	////fprintf(stdout,"[regalloc][RewriteProgram] begin\n");fflush(stdout);
    AS_instrList il = *pil, l, last, next, new_instr;
    int off;
    while(spillNodes)
	{
        G_node cur = spillNodes->head;
        spillNodes = spillNodes->tail;
        /* assert(!precolored(cur)); */
        Temp_temp c = Live_gtemp(cur);
		fprintf(stdout,"[regalloc][RewriteProgram] spill %d\n",Temp_int(c));fflush(stdout);
        off = F_spill(f);

        l = il;
        last = NULL;
        while(l)
		{
            Temp_temp t = NULL;
            next = l->tail;
            Temp_tempList *def = Inst_def(l->head);
            Temp_tempList *use = Inst_use(l->head);
            if (use && Temp_inTempList(c, *use))
			{
                if (t == NULL)
				{
                    t = Temp_newtemp();
                    //fprintf(stdout,"[regalloc][RewriteProgram] newTemp=%d\n",Temp_int(t));fflush(stdout);
                    t->spilled = TRUE;
                }
                *use = Temp_replaceTempList(*use, c, t);
				/* 创建一条新指令并接在后面 */
                char *a = checked_malloc(MAXLINE * sizeof(char));
                sprintf(a, "movl %d(%%ebp), `d0\n", off);
                new_instr = AS_InstrList(AS_Oper(a, Temp_TempList(t, NULL), NULL, AS_Targets(NULL)), l);
				/* 分为后面有没有指令两种情况 */
                if (last) {
                    last->tail = new_instr;
                } else {
                    il = new_instr;
                }
            }
            last = l;
            if (def && Temp_inTempList(c, *def))
			{
				/* 为使用创建新的临时变量 */
                if (t == NULL)
				{
                    t = Temp_newtemp();
                    t->spilled = TRUE;
                }
                *def = Temp_replaceTempList(*def, c, t);
                char *a = checked_malloc(MAXLINE * sizeof(char));
                sprintf(a, "movl `s0, %d(%%ebp)\n", off);
                l->tail = AS_InstrList(AS_Oper(a, NULL, Temp_TempList(t, NULL), AS_Targets(NULL)), next);
                last = l->tail;
            }
            l = next;
        }
    }
    *pil = il;
}

static Temp_map generate_map()
{
	fprintf(stdout,"[regalloc][generate_map] begin\n");fflush(stdout);
    Temp_map res = Temp_empty();
    G_nodeList p = G_nodes(graph);
    for (; p; p = p->tail)
	{
        int *t = G_look(color, p->head);
        /*
        char * a = checked_malloc(sizeof(char) * MAXLINE);
        sprintf(a, "%s%d", reg_names[*t], Live_gtemp(p->head)->num);
        */
        Temp_temp temp=Live_gtemp(p->head);
        fprintf(stdout,"[regalloc][generate_map] %d=%s\n",temp->num,reg_names[*t]);fflush(stdout);
        Temp_enter(res, temp, reg_names[*t]);
    }

    /* ebp */
    Temp_enter(res, F_FP(), "%ebp");

    return res;
}

static Live_moveList Live_RemoveFromMovelist(Live_moveList l,G_node src,G_node dst)
{
	Live_moveList ret,last=NULL;
	for(Live_moveList i=l;i;last=i,i=i->tail)
	{
		if(i->src==src&&i->dst==dst)
		{
			if(last)
				last->tail=i->tail;
			else
				ret=l->tail;
			break;
		}
	}
	return ret;
}

static bool Live_inMoveList(G_node src, G_node dst, Live_moveList l)
{
    for (Live_moveList p = l; p; p = p->tail) {
        if (p->src == src && p->dst == dst) {
            return TRUE;
        }
    }
    return FALSE;
}

static Live_moveList Live_UnionMoveList(Live_moveList l, Live_moveList r)
{
    Live_moveList res = r;
    for (Live_moveList p = l; p; p = p->tail) {
        if (!Live_inMoveList(p->src, p->dst, r)) {
            res = Live_MoveList(p->src, p->dst, res);
        }
    }
    return res;
}

static Live_moveList Live_SubMoveList(Live_moveList l, Live_moveList r)
{
    Live_moveList res = NULL;
    for (Live_moveList p = l; p; p = p->tail) {
        if (!Live_inMoveList(p->src, p->dst, r)) {
            res = Live_MoveList(p->src, p->dst, res);
        }
    }
    return res;
}

G_nodeList G_UnionNodeList(G_nodeList l, G_nodeList r)
{
    G_nodeList res = r;
    G_nodeList p = l;
    for (; p != NULL; p = p->tail) {
        if (!G_inNodeList(p->head, r)) {
            res = G_NodeList(p->head, res);
        }
    }
    return res;
}

G_nodeList G_SubNodeList(G_nodeList l, G_nodeList r)
{
    G_nodeList res = NULL;
    G_nodeList p = l;
    for (; p != NULL; p = p->tail) {
        if (!G_inNodeList(p->head, r)) {
            res = G_NodeList(p->head, res);
        }
    }
    return res;
}

Temp_tempList* Inst_def(AS_instr inst) {
    switch (inst->kind) {
        case I_OPER:
            return &inst->u.OPER.dst;
        case I_LABEL:
            return NULL;
        case I_MOVE:
            return &inst->u.MOVE.dst;
        default:
            assert(0);
    }
    return NULL;
}

Temp_tempList* Inst_use(AS_instr inst) {
    switch (inst->kind) {
        case I_OPER:
            return &inst->u.OPER.src;
        case I_LABEL:
            return NULL;
        case I_MOVE:
            return &inst->u.MOVE.src;
        default:
            assert(0);
    }
    return NULL;
}
