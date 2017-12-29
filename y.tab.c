/* original parser id follows */
/* yysccsid[] = "@(#)yaccpar	1.9 (Berkeley) 02/21/93" */
/* (use YYMAJOR/YYMINOR for ifdefs dependent on parser version) */

#define YYBYACC 1
#define YYMAJOR 1
#define YYMINOR 9
#define YYPATCH 20140715

#define YYEMPTY        (-1)
#define yyclearin      (yychar = YYEMPTY)
#define yyerrok        (yyerrflag = 0)
#define YYRECOVERING() (yyerrflag != 0)
#define YYENOMEM       (-2)
#define YYEOF          0
#define YYPREFIX "yy"

#define YYPURE 0

#line 2 "tiger.y"
#include <stdio.h>
#include <stdlib.h>
#include "util.h"
#include "symbol.h" 
#include "errormsg.h"
#include "absyn.h"

int yylex(void); /* function prototype */

A_exp absyn_root;

void yyerror(char *s)
{
 EM_error(EM_tokPos, "%s", s);
 exit(1);
}
#line 21 "tiger.y"
#ifdef YYSTYPE
#undef  YYSTYPE_IS_DECLARED
#define YYSTYPE_IS_DECLARED 1
#endif
#ifndef YYSTYPE_IS_DECLARED
#define YYSTYPE_IS_DECLARED 1
typedef union {
	int pos;
	int ival;
	string sval;
	A_var var;
	A_exp exp;
        A_expList explist;
        A_efieldList efieldlist;
        A_decList declist;
        A_dec dec;
        A_nametyList nametylist;
        A_namety namety;
        A_ty ty;
        A_fieldList fieldlist;
        A_field field;
        A_fundec fundec;
        A_fundecList fundeclist;
	/* et cetera */
	} YYSTYPE;
#endif /* !YYSTYPE_IS_DECLARED */
#line 65 "y.tab.c"

/* compatibility with bison */
#ifdef YYPARSE_PARAM
/* compatibility with FreeBSD */
# ifdef YYPARSE_PARAM_TYPE
#  define YYPARSE_DECL() yyparse(YYPARSE_PARAM_TYPE YYPARSE_PARAM)
# else
#  define YYPARSE_DECL() yyparse(void *YYPARSE_PARAM)
# endif
#else
# define YYPARSE_DECL() yyparse(void)
#endif

/* Parameters sent to lex. */
#ifdef YYLEX_PARAM
# define YYLEX_DECL() yylex(void *YYLEX_PARAM)
# define YYLEX yylex(YYLEX_PARAM)
#else
# define YYLEX_DECL() yylex(void)
# define YYLEX yylex()
#endif

/* Parameters sent to yyerror. */
#ifndef YYERROR_DECL
#define YYERROR_DECL() yyerror(const char *s)
#endif
#ifndef YYERROR_CALL
#define YYERROR_CALL(msg) yyerror(msg)
#endif

extern int YYPARSE_DECL();

#define ID 257
#define STRING 258
#define INT 259
#define COMMA 260
#define COLON 261
#define SEMICOLON 262
#define LPAREN 263
#define RPAREN 264
#define LBRACK 265
#define RBRACK 266
#define LBRACE 267
#define RBRACE 268
#define DOT 269
#define PLUS 270
#define MINUS 271
#define TIMES 272
#define DIVIDE 273
#define EQ 274
#define NEQ 275
#define LT 276
#define LE 277
#define GT 278
#define GE 279
#define UMINUS 280
#define AND 281
#define OR 282
#define ASSIGN 283
#define ARRAY 284
#define IF 285
#define THEN 286
#define ELSE 287
#define WHILE 288
#define FOR 289
#define TO 290
#define DO 291
#define LET 292
#define IN 293
#define END 294
#define OF 295
#define BREAK 296
#define NIL 297
#define FUNCTION 298
#define VAR 299
#define TYPE 300
#define YYERRCODE 256
typedef short YYINT;
static const YYINT yylhs[] = {                           -1,
    0,    1,    1,    1,    1,    1,    1,    1,    1,    1,
    1,    1,    1,    1,    1,    1,    1,    1,    1,    1,
    1,    1,    1,    1,    1,    1,    1,    1,    1,    7,
    7,    8,    8,    3,    3,    3,    4,    4,    5,    5,
    6,    6,   13,   13,    9,    9,    9,   10,   10,   14,
   15,   15,   15,   16,   16,   17,   17,   12,   12,   11,
   11,   18,   18,    2,    2,    2,    2,
};
static const YYINT yylen[] = {                            2,
    1,    1,    1,    1,    1,    1,    2,    3,    6,    4,
    4,    8,    5,    6,    4,    4,    3,    3,    3,    3,
    3,    3,    3,    3,    3,    3,    3,    3,    3,    0,
    1,    3,    5,    3,    0,    1,    1,    3,    0,    1,
    1,    3,    0,    2,    1,    1,    1,    1,    2,    4,
    1,    3,    3,    0,    1,    3,    5,    4,    6,    1,
    2,    7,    9,    1,    3,    4,    4,
};
static const YYINT yydefred[] = {                         0,
    0,    5,    4,    0,    0,    0,    0,    0,    0,    6,
    3,    0,    0,    0,    0,    0,    0,    0,    0,    7,
    0,    0,    0,    0,    0,    0,    0,   45,   47,   46,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
   40,    0,    0,    0,   31,    0,    8,    0,    0,    0,
    0,    0,    0,   44,    0,   49,   61,    0,    0,   19,
   20,    0,    0,    0,    0,    0,    0,    0,    0,    0,
   65,    0,    0,   16,    0,    0,   15,    0,   34,    0,
    0,    0,    0,    0,    0,    0,    0,   66,   42,    0,
    0,    0,    0,    0,    0,    0,   55,    0,    0,   51,
    0,    0,   50,   13,    0,    0,   38,    0,    0,    0,
    0,    0,    0,    0,   33,    0,    0,    0,    0,    0,
   52,   53,    0,    0,    0,    0,   57,    0,    0,
};
static const YYINT yydgoto[] = {                         12,
   18,   14,   19,   89,   50,   51,   54,   55,   27,   28,
   29,   30,   31,   32,  113,  106,  107,   33,
};
static const YYINT yysindex[] = {                      -199,
 -164,    0,    0, -199, -199, -199, -199, -254, -170,    0,
    0,    0,  721, -247, -199, -199, -249, -156, -251,    0,
  -22, -104, -263, -234, -228, -220, -170,    0,    0,    0,
 -252, -213, -232, -199, -199, -199, -199, -199, -199, -199,
 -199, -199, -199, -199, -199, -199, -169, -199, -197, -173,
    0,  694, -180, -172,    0, -199,    0, -199, -199, -199,
 -163, -257, -167,    0, -199,    0,    0, -202, -202,    0,
    0,  -91,  -91,  -91,  -91,  -91,  -91,  246,  205,  708,
    0,  721, -199,    0, -193, -199,    0,  -60,    0,  496,
  721,  -47, -152, -149, -199, -250, -184,    0,    0, -199,
 -121, -199, -199, -199, -124, -120,    0, -143,  721,    0,
 -152, -150,    0,    0,  721, -249,    0,  721,  -82, -111,
 -255, -199, -109,  -95,    0, -199, -112,  -94, -199,  721,
    0,    0,  721, -152, -110,  721,    0, -199,  721,
};
static const YYINT yyrindex[] = {                         0,
   42,    0,    0,  -88,    0,    0,    0,    0, -108,    0,
    0,    0,  183,   83,  -80,    0,  -70, -264,    0,    0,
    0,    0,    0,    0,    0,    0, -108,    0,    0,    0,
    0, -237, -272,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,  -78,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,  -93,    0,    0,  124,  165,    0,
    0,  206,  247,  289,  330,  371,  412,  453,  494,    0,
    0,  535,    0,    0,    1,    0,    0, -262,    0,  663,
  550,    0,  -61,    0,    0,    0,    0,    0,    0,    0,
  -64,    0,    0,    0,    0,    0,    0,    0, -288,    0,
  -63,    0,    0,    0,  591,    0,    0,  606,    0,    0,
    0,    0,    0,    0,    0,    0, -233,    0,    0, -260,
    0,    0,  647,    0,    0, -166,    0,    0, -157,
};
static const YYINT yygindex[] = {                         0,
    9,    0,  142,  106,    0,  137,    0,  117,    0,  204,
  207,    0,  210,    0,    0,  127,  105,    0,
};
#define YYTABLESIZE 1003
static const YYINT yytable[] = {                         36,
   67,   37,   23,   94,   58,  128,  110,   53,   13,   58,
   58,   58,   57,   20,   21,   22,  111,   46,  129,   60,
   60,   47,   61,   49,   52,   95,   60,   60,   62,   36,
   56,   37,   59,  112,   56,   48,   63,   59,   59,   59,
   65,   64,   68,   69,   70,   71,   72,   73,   74,   75,
   76,   77,   78,   79,   80,   48,   82,    1,    2,    3,
   48,   48,   83,    4,   88,   24,   90,   91,   92,   36,
   37,    5,   34,   35,   36,   37,   38,   39,   40,   41,
   42,   43,    2,   44,   45,    6,   26,   81,    7,    8,
   84,   49,    9,   86,  101,   87,   10,   11,   15,   93,
   16,  100,   17,  109,  105,   56,   96,  108,  115,  114,
   88,  118,  119,   34,   35,   36,   37,   38,   39,   40,
   41,   42,   43,   17,   44,   45,   62,   24,   25,   26,
  130,   62,   62,   62,  133,   63,  120,  136,  116,  122,
   63,   63,   63,  121,  124,  127,  139,  134,   34,   35,
   36,   37,   38,   39,   40,   41,   42,   43,  131,   44,
   45,  132,  135,  138,   18,   34,   35,   36,   37,   38,
   39,   40,   41,   42,   43,   35,   44,   45,   34,   35,
   36,   37,    1,   39,   43,   41,   59,   34,   35,   36,
   37,   38,   39,   40,   41,   42,   43,   30,   44,   45,
   35,  102,   54,   32,   54,   21,   97,  117,  126,   34,
   35,   36,   37,   38,   39,   40,   41,   42,   43,   99,
   44,   45,   34,   35,   36,   37,   38,   39,   40,   41,
   42,   43,  125,   44,   45,   66,   64,  123,  137,   67,
    0,    0,  104,    0,    0,    0,   22,   34,   35,   36,
   37,   38,   39,   40,   41,   42,   43,    0,   44,   45,
   67,    0,   67,   58,   67,   67,   67,    0,   67,   67,
   67,   67,   67,   67,   67,   67,   67,   67,   67,   67,
    0,   67,   67,   67,    0,    0,   67,   67,   23,    0,
   67,   67,    0,   67,   67,    0,    0,    0,   67,   67,
   67,   64,    0,   64,    0,   64,    0,   64,    0,   64,
   64,   64,   64,   64,   64,   64,   64,   64,   64,   64,
   64,    0,   64,   64,   64,    0,    0,   64,   64,   24,
    0,   64,   64,    0,   64,   64,    0,    0,    0,   64,
   64,   64,    2,    0,    2,    0,    2,    0,    2,    0,
    2,    0,    2,    2,    2,    2,    2,    2,    2,    2,
    2,    2,    0,    2,    2,    0,    0,    0,    2,    2,
   25,    0,    2,    2,    0,    2,    2,    0,    0,    0,
    2,    2,    2,   17,    0,   17,    0,   17,    0,   17,
    0,   17,    0,   17,   17,    0,    0,   17,   17,   17,
   17,   17,   17,    0,   17,   17,    0,    0,    0,   17,
   17,   26,    0,   17,   17,    0,   17,   17,    0,    0,
    0,   17,   17,   17,   18,    0,   18,    0,   18,    0,
   18,    0,   18,    0,   18,   18,    0,    0,   18,   18,
   18,   18,   18,   18,    0,   18,   18,    0,    0,    0,
   18,   18,   27,    0,   18,   18,    0,   18,   18,    0,
    0,    0,   18,   18,   18,   21,    0,   21,    0,   21,
    0,   21,    0,   21,   34,   35,   36,   37,   38,   39,
   40,   41,   42,   43,    0,   44,   21,   21,    0,    0,
    0,   21,   21,   28,    0,   21,   21,    0,   21,   21,
    0,    0,    0,   21,   21,   21,   22,    0,   22,    0,
   22,    0,   22,    0,   22,   34,   35,   36,   37,   38,
   39,   40,   41,   42,   43,    0,    0,   22,   22,    0,
    0,    0,   22,   22,   29,    0,   22,   22,    0,   22,
   22,    0,    0,    0,   22,   22,   22,    0,   23,   11,
   23,    0,   23,    0,   23,    0,   23,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,   23,
   23,    0,    0,    0,   23,   23,    0,    0,   23,   23,
    0,   23,   23,    0,    0,    0,   23,   23,   23,   24,
   14,   24,    0,   24,    0,   24,    0,   24,    0,    0,
    0,    0,    0,    0,    0,    9,    0,    0,    0,    0,
   24,   24,    0,    0,    0,   24,   24,    0,    0,   24,
   24,    0,   24,   24,    0,    0,    0,   24,   24,   24,
   25,    0,   25,    0,   25,    0,   25,    0,   25,    0,
    0,    0,    0,    0,    0,    0,   12,    0,    0,    0,
    0,   25,   25,    0,    0,    0,   25,   25,    0,    0,
   25,   25,   10,   25,   25,    0,    0,    0,   25,   25,
   25,   26,    0,   26,    0,   26,    0,   26,    0,   26,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,   26,   26,    0,    0,    0,   26,   26,    0,
    0,   26,   26,    0,   26,   26,    0,    0,    0,   26,
   26,   26,   27,    0,   27,    0,   27,    0,   27,    0,
   27,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,   27,   27,    0,    0,    0,   27,   27,
    0,    0,   27,   27,    0,   27,   27,    0,    0,    0,
   27,   27,   27,   28,    0,   28,    0,   28,    0,   28,
    0,   28,    0,    0,    0,   34,   35,   36,   37,   38,
   39,   40,   41,   42,   43,   28,   44,   45,    0,   28,
   28,    0,  103,   28,   28,    0,   28,   28,    0,    0,
    0,   28,   28,   28,   29,    0,   29,    0,   29,    0,
   29,    0,   29,    0,    0,    0,    0,    0,    0,   11,
    0,   11,    0,   11,    0,   11,    0,   11,    0,    0,
   29,   29,    0,    0,   29,   29,    0,   29,   29,    0,
    0,    0,   29,   29,   29,   11,   11,    0,    0,   11,
   11,    0,   11,   11,    0,    0,    0,   11,   11,   11,
   14,    0,   14,    0,   14,    0,   14,    0,   14,    0,
    0,    0,    0,    0,    0,    9,    0,    9,    0,    9,
    0,    9,    0,    9,    0,    0,   14,   14,    0,    0,
   14,   14,    0,   14,   14,    0,    0,    0,   14,   14,
   14,    9,    9,    0,    0,    9,    9,    0,    9,    9,
    0,    0,    0,    9,    9,    9,   12,    0,   12,    0,
   12,    0,   12,    0,   12,    0,    0,    0,    0,    0,
    0,    0,   10,    0,   10,    0,   10,    0,   10,    0,
   10,    0,   12,   12,    0,    0,   12,   12,    0,   12,
   12,    0,    0,    0,   12,   12,   12,    0,   10,    0,
    0,    0,   10,   10,    0,   10,   10,    0,    0,   85,
   10,   10,   10,   34,   35,   36,   37,   38,   39,   40,
   41,   42,   43,   98,   44,   45,    0,   34,   35,   36,
   37,   38,   39,   40,   41,   42,   43,    0,   44,   45,
   34,   35,   36,   37,   38,   39,   40,   41,   42,   43,
    0,   44,   45,
};
static const YYINT yycheck[] = {                        264,
    0,  264,  257,  261,  293,  261,  257,  257,    0,  298,
  299,  300,  264,    5,    6,    7,  267,  265,  274,  283,
  293,  269,  257,   15,   16,  283,  299,  300,  257,  294,
  264,  294,  293,  284,  268,  283,  257,  298,  299,  300,
  293,    0,   34,   35,   36,   37,   38,   39,   40,   41,
   42,   43,   44,   45,   46,  293,   48,  257,  258,  259,
  298,  299,  260,  263,   56,  298,   58,   59,   60,  272,
  273,  271,  270,  271,  272,  273,  274,  275,  276,  277,
  278,  279,    0,  281,  282,  285,  300,  257,  288,  289,
  264,   83,  292,  274,   86,  268,  296,  297,  263,  263,
  265,  295,  267,   95,  257,  262,  274,  257,  100,  294,
  102,  103,  104,  270,  271,  272,  273,  274,  275,  276,
  277,  278,  279,    0,  281,  282,  293,  298,  299,  300,
  122,  298,  299,  300,  126,  293,  261,  129,  260,  283,
  298,  299,  300,  264,  295,  257,  138,  260,  270,  271,
  272,  273,  274,  275,  276,  277,  278,  279,  268,  281,
  282,  257,  257,  274,    0,  270,  271,  272,  273,  274,
  275,  276,  277,  278,  279,  264,  281,  282,  270,  271,
  272,  273,    0,  264,  293,  264,  291,  270,  271,  272,
  273,  274,  275,  276,  277,  278,  279,  268,  281,  282,
  294,  262,  264,  268,  268,    0,   65,  102,  291,  270,
  271,  272,  273,  274,  275,  276,  277,  278,  279,   83,
  281,  282,  270,  271,  272,  273,  274,  275,  276,  277,
  278,  279,  116,  281,  282,   32,   27,  111,  134,   33,
   -1,   -1,  290,   -1,   -1,   -1,    0,  270,  271,  272,
  273,  274,  275,  276,  277,  278,  279,   -1,  281,  282,
  260,   -1,  262,  286,  264,  265,  266,   -1,  268,  269,
  270,  271,  272,  273,  274,  275,  276,  277,  278,  279,
   -1,  281,  282,  283,   -1,   -1,  286,  287,    0,   -1,
  290,  291,   -1,  293,  294,   -1,   -1,   -1,  298,  299,
  300,  260,   -1,  262,   -1,  264,   -1,  266,   -1,  268,
  269,  270,  271,  272,  273,  274,  275,  276,  277,  278,
  279,   -1,  281,  282,  283,   -1,   -1,  286,  287,    0,
   -1,  290,  291,   -1,  293,  294,   -1,   -1,   -1,  298,
  299,  300,  260,   -1,  262,   -1,  264,   -1,  266,   -1,
  268,   -1,  270,  271,  272,  273,  274,  275,  276,  277,
  278,  279,   -1,  281,  282,   -1,   -1,   -1,  286,  287,
    0,   -1,  290,  291,   -1,  293,  294,   -1,   -1,   -1,
  298,  299,  300,  260,   -1,  262,   -1,  264,   -1,  266,
   -1,  268,   -1,  270,  271,   -1,   -1,  274,  275,  276,
  277,  278,  279,   -1,  281,  282,   -1,   -1,   -1,  286,
  287,    0,   -1,  290,  291,   -1,  293,  294,   -1,   -1,
   -1,  298,  299,  300,  260,   -1,  262,   -1,  264,   -1,
  266,   -1,  268,   -1,  270,  271,   -1,   -1,  274,  275,
  276,  277,  278,  279,   -1,  281,  282,   -1,   -1,   -1,
  286,  287,    0,   -1,  290,  291,   -1,  293,  294,   -1,
   -1,   -1,  298,  299,  300,  260,   -1,  262,   -1,  264,
   -1,  266,   -1,  268,  270,  271,  272,  273,  274,  275,
  276,  277,  278,  279,   -1,  281,  281,  282,   -1,   -1,
   -1,  286,  287,    0,   -1,  290,  291,   -1,  293,  294,
   -1,   -1,   -1,  298,  299,  300,  260,   -1,  262,   -1,
  264,   -1,  266,   -1,  268,  270,  271,  272,  273,  274,
  275,  276,  277,  278,  279,   -1,   -1,  281,  282,   -1,
   -1,   -1,  286,  287,    0,   -1,  290,  291,   -1,  293,
  294,   -1,   -1,   -1,  298,  299,  300,   -1,  260,    0,
  262,   -1,  264,   -1,  266,   -1,  268,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,  281,
  282,   -1,   -1,   -1,  286,  287,   -1,   -1,  290,  291,
   -1,  293,  294,   -1,   -1,   -1,  298,  299,  300,  260,
    0,  262,   -1,  264,   -1,  266,   -1,  268,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,    0,   -1,   -1,   -1,   -1,
  281,  282,   -1,   -1,   -1,  286,  287,   -1,   -1,  290,
  291,   -1,  293,  294,   -1,   -1,   -1,  298,  299,  300,
  260,   -1,  262,   -1,  264,   -1,  266,   -1,  268,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,    0,   -1,   -1,   -1,
   -1,  281,  282,   -1,   -1,   -1,  286,  287,   -1,   -1,
  290,  291,    0,  293,  294,   -1,   -1,   -1,  298,  299,
  300,  260,   -1,  262,   -1,  264,   -1,  266,   -1,  268,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,  281,  282,   -1,   -1,   -1,  286,  287,   -1,
   -1,  290,  291,   -1,  293,  294,   -1,   -1,   -1,  298,
  299,  300,  260,   -1,  262,   -1,  264,   -1,  266,   -1,
  268,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,  281,  282,   -1,   -1,   -1,  286,  287,
   -1,   -1,  290,  291,   -1,  293,  294,   -1,   -1,   -1,
  298,  299,  300,  260,   -1,  262,   -1,  264,   -1,  266,
   -1,  268,   -1,   -1,   -1,  270,  271,  272,  273,  274,
  275,  276,  277,  278,  279,  282,  281,  282,   -1,  286,
  287,   -1,  287,  290,  291,   -1,  293,  294,   -1,   -1,
   -1,  298,  299,  300,  260,   -1,  262,   -1,  264,   -1,
  266,   -1,  268,   -1,   -1,   -1,   -1,   -1,   -1,  260,
   -1,  262,   -1,  264,   -1,  266,   -1,  268,   -1,   -1,
  286,  287,   -1,   -1,  290,  291,   -1,  293,  294,   -1,
   -1,   -1,  298,  299,  300,  286,  287,   -1,   -1,  290,
  291,   -1,  293,  294,   -1,   -1,   -1,  298,  299,  300,
  260,   -1,  262,   -1,  264,   -1,  266,   -1,  268,   -1,
   -1,   -1,   -1,   -1,   -1,  260,   -1,  262,   -1,  264,
   -1,  266,   -1,  268,   -1,   -1,  286,  287,   -1,   -1,
  290,  291,   -1,  293,  294,   -1,   -1,   -1,  298,  299,
  300,  286,  287,   -1,   -1,  290,  291,   -1,  293,  294,
   -1,   -1,   -1,  298,  299,  300,  260,   -1,  262,   -1,
  264,   -1,  266,   -1,  268,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,  260,   -1,  262,   -1,  264,   -1,  266,   -1,
  268,   -1,  286,  287,   -1,   -1,  290,  291,   -1,  293,
  294,   -1,   -1,   -1,  298,  299,  300,   -1,  286,   -1,
   -1,   -1,  290,  291,   -1,  293,  294,   -1,   -1,  266,
  298,  299,  300,  270,  271,  272,  273,  274,  275,  276,
  277,  278,  279,  266,  281,  282,   -1,  270,  271,  272,
  273,  274,  275,  276,  277,  278,  279,   -1,  281,  282,
  270,  271,  272,  273,  274,  275,  276,  277,  278,  279,
   -1,  281,  282,
};
#define YYFINAL 12
#ifndef YYDEBUG
#define YYDEBUG 0
#endif
#define YYMAXTOKEN 300
#define YYUNDFTOKEN 321
#define YYTRANSLATE(a) ((a) > YYMAXTOKEN ? YYUNDFTOKEN : (a))
#if YYDEBUG
static const char *const yyname[] = {

"end-of-file",0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,"ID","STRING","INT","COMMA",
"COLON","SEMICOLON","LPAREN","RPAREN","LBRACK","RBRACK","LBRACE","RBRACE","DOT",
"PLUS","MINUS","TIMES","DIVIDE","EQ","NEQ","LT","LE","GT","GE","UMINUS","AND",
"OR","ASSIGN","ARRAY","IF","THEN","ELSE","WHILE","FOR","TO","DO","LET","IN",
"END","OF","BREAK","NIL","FUNCTION","VAR","TYPE",0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,"illegal-symbol",
};
static const char *const yyrule[] = {
"$accept : program",
"program : exp",
"exp : lvalue",
"exp : NIL",
"exp : INT",
"exp : STRING",
"exp : BREAK",
"exp : MINUS exp",
"exp : LPAREN expseq RPAREN",
"exp : IF exp THEN exp ELSE exp",
"exp : IF exp THEN exp",
"exp : WHILE exp DO exp",
"exp : FOR ID ASSIGN exp TO exp DO exp",
"exp : LET decs IN expseq END",
"exp : ID LBRACK exp RBRACK OF exp",
"exp : ID LBRACE rec RBRACE",
"exp : ID LPAREN params RPAREN",
"exp : exp PLUS exp",
"exp : exp MINUS exp",
"exp : exp TIMES exp",
"exp : exp DIVIDE exp",
"exp : exp EQ exp",
"exp : exp NEQ exp",
"exp : exp LT exp",
"exp : exp LE exp",
"exp : exp GT exp",
"exp : exp GE exp",
"exp : exp AND exp",
"exp : exp OR exp",
"exp : lvalue ASSIGN exp",
"rec :",
"rec : recs",
"recs : ID EQ exp",
"recs : ID EQ exp COMMA recs",
"expseq : exp SEMICOLON exps",
"expseq :",
"expseq : exp",
"exps : exp",
"exps : exp SEMICOLON exps",
"params :",
"params : param",
"param : exp",
"param : exp COMMA param",
"decs :",
"decs : dec decs",
"dec : tydecs",
"dec : vardec",
"dec : fundecs",
"tydecs : tydec",
"tydecs : tydec tydecs",
"tydec : TYPE ID EQ ty",
"ty : ID",
"ty : LBRACE tyfields RBRACE",
"ty : ARRAY OF ID",
"tyfields :",
"tyfields : tyfield",
"tyfield : ID COLON ID",
"tyfield : ID COLON ID COMMA tyfield",
"vardec : VAR ID ASSIGN exp",
"vardec : VAR ID COLON ID ASSIGN exp",
"fundecs : fundec",
"fundecs : fundec fundecs",
"fundec : FUNCTION ID LPAREN tyfields RPAREN EQ exp",
"fundec : FUNCTION ID LPAREN tyfields RPAREN COLON ID EQ exp",
"lvalue : ID",
"lvalue : lvalue DOT ID",
"lvalue : lvalue LBRACK exp RBRACK",
"lvalue : ID LBRACK exp RBRACK",

};
#endif

int      yydebug;
int      yynerrs;

int      yyerrflag;
int      yychar;
YYSTYPE  yyval;
YYSTYPE  yylval;

/* define the initial stack-sizes */
#ifdef YYSTACKSIZE
#undef YYMAXDEPTH
#define YYMAXDEPTH  YYSTACKSIZE
#else
#ifdef YYMAXDEPTH
#define YYSTACKSIZE YYMAXDEPTH
#else
#define YYSTACKSIZE 10000
#define YYMAXDEPTH  10000
#endif
#endif

#define YYINITSTACKSIZE 200

typedef struct {
    unsigned stacksize;
    YYINT    *s_base;
    YYINT    *s_mark;
    YYINT    *s_last;
    YYSTYPE  *l_base;
    YYSTYPE  *l_mark;
} YYSTACKDATA;
/* variables for the parser stack */
static YYSTACKDATA yystack;

#if YYDEBUG
#include <stdio.h>		/* needed for printf */
#endif

#include <stdlib.h>	/* needed for malloc, etc */
#include <string.h>	/* needed for memset */

/* allocate initial stack or double stack size, up to YYMAXDEPTH */
static int yygrowstack(YYSTACKDATA *data)
{
    int i;
    unsigned newsize;
    YYINT *newss;
    YYSTYPE *newvs;

    if ((newsize = data->stacksize) == 0)
        newsize = YYINITSTACKSIZE;
    else if (newsize >= YYMAXDEPTH)
        return YYENOMEM;
    else if ((newsize *= 2) > YYMAXDEPTH)
        newsize = YYMAXDEPTH;

    i = (int) (data->s_mark - data->s_base);
    newss = (YYINT *)realloc(data->s_base, newsize * sizeof(*newss));
    if (newss == 0)
        return YYENOMEM;

    data->s_base = newss;
    data->s_mark = newss + i;

    newvs = (YYSTYPE *)realloc(data->l_base, newsize * sizeof(*newvs));
    if (newvs == 0)
        return YYENOMEM;

    data->l_base = newvs;
    data->l_mark = newvs + i;

    data->stacksize = newsize;
    data->s_last = data->s_base + newsize - 1;
    return 0;
}

#if YYPURE || defined(YY_NO_LEAKS)
static void yyfreestack(YYSTACKDATA *data)
{
    free(data->s_base);
    free(data->l_base);
    memset(data, 0, sizeof(*data));
}
#else
#define yyfreestack(data) /* nothing */
#endif

#define YYABORT  goto yyabort
#define YYREJECT goto yyabort
#define YYACCEPT goto yyaccept
#define YYERROR  goto yyerrlab

int
YYPARSE_DECL()
{
    int yym, yyn, yystate;
#if YYDEBUG
    const char *yys;

    if ((yys = getenv("YYDEBUG")) != 0)
    {
        yyn = *yys;
        if (yyn >= '0' && yyn <= '9')
            yydebug = yyn - '0';
    }
#endif

    yynerrs = 0;
    yyerrflag = 0;
    yychar = YYEMPTY;
    yystate = 0;

#if YYPURE
    memset(&yystack, 0, sizeof(yystack));
#endif

    if (yystack.s_base == NULL && yygrowstack(&yystack) == YYENOMEM) goto yyoverflow;
    yystack.s_mark = yystack.s_base;
    yystack.l_mark = yystack.l_base;
    yystate = 0;
    *yystack.s_mark = 0;

yyloop:
    if ((yyn = yydefred[yystate]) != 0) goto yyreduce;
    if (yychar < 0)
    {
        if ((yychar = YYLEX) < 0) yychar = YYEOF;
#if YYDEBUG
        if (yydebug)
        {
            yys = yyname[YYTRANSLATE(yychar)];
            printf("%sdebug: state %d, reading %d (%s)\n",
                    YYPREFIX, yystate, yychar, yys);
        }
#endif
    }
    if ((yyn = yysindex[yystate]) && (yyn += yychar) >= 0 &&
            yyn <= YYTABLESIZE && yycheck[yyn] == yychar)
    {
#if YYDEBUG
        if (yydebug)
            printf("%sdebug: state %d, shifting to state %d\n",
                    YYPREFIX, yystate, yytable[yyn]);
#endif
        if (yystack.s_mark >= yystack.s_last && yygrowstack(&yystack) == YYENOMEM)
        {
            goto yyoverflow;
        }
        yystate = yytable[yyn];
        *++yystack.s_mark = yytable[yyn];
        *++yystack.l_mark = yylval;
        yychar = YYEMPTY;
        if (yyerrflag > 0)  --yyerrflag;
        goto yyloop;
    }
    if ((yyn = yyrindex[yystate]) && (yyn += yychar) >= 0 &&
            yyn <= YYTABLESIZE && yycheck[yyn] == yychar)
    {
        yyn = yytable[yyn];
        goto yyreduce;
    }
    if (yyerrflag) goto yyinrecovery;

    YYERROR_CALL("syntax error");

    goto yyerrlab;

yyerrlab:
    ++yynerrs;

yyinrecovery:
    if (yyerrflag < 3)
    {
        yyerrflag = 3;
        for (;;)
        {
            if ((yyn = yysindex[*yystack.s_mark]) && (yyn += YYERRCODE) >= 0 &&
                    yyn <= YYTABLESIZE && yycheck[yyn] == YYERRCODE)
            {
#if YYDEBUG
                if (yydebug)
                    printf("%sdebug: state %d, error recovery shifting\
 to state %d\n", YYPREFIX, *yystack.s_mark, yytable[yyn]);
#endif
                if (yystack.s_mark >= yystack.s_last && yygrowstack(&yystack) == YYENOMEM)
                {
                    goto yyoverflow;
                }
                yystate = yytable[yyn];
                *++yystack.s_mark = yytable[yyn];
                *++yystack.l_mark = yylval;
                goto yyloop;
            }
            else
            {
#if YYDEBUG
                if (yydebug)
                    printf("%sdebug: error recovery discarding state %d\n",
                            YYPREFIX, *yystack.s_mark);
#endif
                if (yystack.s_mark <= yystack.s_base) goto yyabort;
                --yystack.s_mark;
                --yystack.l_mark;
            }
        }
    }
    else
    {
        if (yychar == YYEOF) goto yyabort;
#if YYDEBUG
        if (yydebug)
        {
            yys = yyname[YYTRANSLATE(yychar)];
            printf("%sdebug: state %d, error recovery discards token %d (%s)\n",
                    YYPREFIX, yystate, yychar, yys);
        }
#endif
        yychar = YYEMPTY;
        goto yyloop;
    }

yyreduce:
#if YYDEBUG
    if (yydebug)
        printf("%sdebug: state %d, reducing by rule %d (%s)\n",
                YYPREFIX, yystate, yyn, yyrule[yyn]);
#endif
    yym = yylen[yyn];
    if (yym)
        yyval = yystack.l_mark[1-yym];
    else
        memset(&yyval, 0, sizeof yyval);
    switch (yyn)
    {
case 1:
#line 106 "tiger.y"
	{absyn_root=yystack.l_mark[0].exp;}
break;
case 2:
#line 108 "tiger.y"
	{yyval.exp=A_VarExp(EM_tokPos, yystack.l_mark[0].var);}
break;
case 3:
#line 109 "tiger.y"
	{yyval.exp=A_NilExp(EM_tokPos);}
break;
case 4:
#line 110 "tiger.y"
	{yyval.exp=A_IntExp(EM_tokPos, yystack.l_mark[0].ival);}
break;
case 5:
#line 111 "tiger.y"
	{yyval.exp=A_StringExp(EM_tokPos, yystack.l_mark[0].sval);}
break;
case 6:
#line 112 "tiger.y"
	{yyval.exp=A_BreakExp(EM_tokPos);}
break;
case 7:
#line 113 "tiger.y"
	{yyval.exp=A_OpExp(EM_tokPos, A_minusOp, A_IntExp(EM_tokPos, 0), yystack.l_mark[0].exp);}
break;
case 8:
#line 114 "tiger.y"
	{yyval.exp=A_SeqExp(EM_tokPos,yystack.l_mark[-1].explist);}
break;
case 9:
#line 116 "tiger.y"
	{yyval.exp=A_IfExp(EM_tokPos, yystack.l_mark[-4].exp, yystack.l_mark[-2].exp, yystack.l_mark[0].exp);}
break;
case 10:
#line 117 "tiger.y"
	{yyval.exp=A_IfExp(EM_tokPos, yystack.l_mark[-2].exp, yystack.l_mark[0].exp, NULL);}
break;
case 11:
#line 118 "tiger.y"
	{yyval.exp=A_WhileExp(EM_tokPos, yystack.l_mark[-2].exp, yystack.l_mark[0].exp);}
break;
case 12:
#line 119 "tiger.y"
	{yyval.exp=A_ForExp(EM_tokPos, S_Symbol(yystack.l_mark[-6].sval), yystack.l_mark[-4].exp, yystack.l_mark[-2].exp, yystack.l_mark[0].exp);}
break;
case 13:
#line 120 "tiger.y"
	{yyval.exp=A_LetExp(EM_tokPos, yystack.l_mark[-3].declist, A_SeqExp(EM_tokPos, yystack.l_mark[-1].explist));}
break;
case 14:
#line 121 "tiger.y"
	{yyval.exp=A_ArrayExp(EM_tokPos, S_Symbol(yystack.l_mark[-5].sval), yystack.l_mark[-3].exp, yystack.l_mark[0].exp);}
break;
case 15:
#line 122 "tiger.y"
	{yyval.exp=A_RecordExp(EM_tokPos, S_Symbol(yystack.l_mark[-3].sval), yystack.l_mark[-1].efieldlist);}
break;
case 16:
#line 123 "tiger.y"
	{yyval.exp=A_CallExp(EM_tokPos, S_Symbol(yystack.l_mark[-3].sval), yystack.l_mark[-1].explist);}
break;
case 17:
#line 124 "tiger.y"
	{yyval.exp=A_OpExp(EM_tokPos, A_plusOp, yystack.l_mark[-2].exp, yystack.l_mark[0].exp);}
break;
case 18:
#line 125 "tiger.y"
	{yyval.exp=A_OpExp(EM_tokPos, A_minusOp, yystack.l_mark[-2].exp, yystack.l_mark[0].exp);}
break;
case 19:
#line 126 "tiger.y"
	{yyval.exp=A_OpExp(EM_tokPos, A_timesOp, yystack.l_mark[-2].exp, yystack.l_mark[0].exp);}
break;
case 20:
#line 127 "tiger.y"
	{yyval.exp=A_OpExp(EM_tokPos, A_divideOp, yystack.l_mark[-2].exp, yystack.l_mark[0].exp);}
break;
case 21:
#line 128 "tiger.y"
	{yyval.exp=A_OpExp(EM_tokPos, A_eqOp, yystack.l_mark[-2].exp, yystack.l_mark[0].exp);}
break;
case 22:
#line 129 "tiger.y"
	{yyval.exp=A_OpExp(EM_tokPos, A_neqOp, yystack.l_mark[-2].exp, yystack.l_mark[0].exp);}
break;
case 23:
#line 130 "tiger.y"
	{yyval.exp=A_OpExp(EM_tokPos, A_ltOp, yystack.l_mark[-2].exp, yystack.l_mark[0].exp);}
break;
case 24:
#line 131 "tiger.y"
	{yyval.exp=A_OpExp(EM_tokPos, A_leOp, yystack.l_mark[-2].exp, yystack.l_mark[0].exp);}
break;
case 25:
#line 132 "tiger.y"
	{yyval.exp=A_OpExp(EM_tokPos, A_gtOp, yystack.l_mark[-2].exp, yystack.l_mark[0].exp);}
break;
case 26:
#line 133 "tiger.y"
	{yyval.exp=A_OpExp(EM_tokPos, A_geOp, yystack.l_mark[-2].exp, yystack.l_mark[0].exp);}
break;
case 27:
#line 134 "tiger.y"
	{yyval.exp=A_IfExp(EM_tokPos, yystack.l_mark[-2].exp, yystack.l_mark[0].exp, A_IntExp(EM_tokPos, 0));}
break;
case 28:
#line 135 "tiger.y"
	{yyval.exp=A_IfExp(EM_tokPos, yystack.l_mark[-2].exp, A_IntExp(EM_tokPos, 1), yystack.l_mark[0].exp);}
break;
case 29:
#line 136 "tiger.y"
	{yyval.exp=A_AssignExp(EM_tokPos, yystack.l_mark[-2].var, yystack.l_mark[0].exp);}
break;
case 30:
#line 139 "tiger.y"
	{yyval.efieldlist=NULL;}
break;
case 31:
#line 140 "tiger.y"
	{yyval.efieldlist=yystack.l_mark[0].efieldlist;}
break;
case 32:
#line 143 "tiger.y"
	{yyval.efieldlist=A_EfieldList(A_Efield(S_Symbol(yystack.l_mark[-2].sval), yystack.l_mark[0].exp), NULL);}
break;
case 33:
#line 144 "tiger.y"
	{yyval.efieldlist=A_EfieldList(A_Efield(S_Symbol(yystack.l_mark[-4].sval), yystack.l_mark[-2].exp), yystack.l_mark[0].efieldlist);}
break;
case 34:
#line 147 "tiger.y"
	{yyval.explist=A_ExpList(yystack.l_mark[-2].exp, yystack.l_mark[0].explist);}
break;
case 35:
#line 148 "tiger.y"
	{yyval.explist=NULL;}
break;
case 36:
#line 149 "tiger.y"
	{yyval.explist=A_ExpList(yystack.l_mark[0].exp,NULL);}
break;
case 37:
#line 152 "tiger.y"
	{yyval.explist=A_ExpList(yystack.l_mark[0].exp, NULL);}
break;
case 38:
#line 153 "tiger.y"
	{yyval.explist=A_ExpList(yystack.l_mark[-2].exp, yystack.l_mark[0].explist);}
break;
case 39:
#line 156 "tiger.y"
	{yyval.explist=NULL;}
break;
case 40:
#line 157 "tiger.y"
	{yyval.explist=yystack.l_mark[0].explist;}
break;
case 41:
#line 160 "tiger.y"
	{yyval.explist=A_ExpList(yystack.l_mark[0].exp, NULL);}
break;
case 42:
#line 161 "tiger.y"
	{yyval.explist=A_ExpList(yystack.l_mark[-2].exp, yystack.l_mark[0].explist);}
break;
case 43:
#line 164 "tiger.y"
	{yyval.declist=NULL;}
break;
case 44:
#line 165 "tiger.y"
	{yyval.declist=A_DecList(yystack.l_mark[-1].dec, yystack.l_mark[0].declist);}
break;
case 45:
#line 168 "tiger.y"
	{yyval.dec=A_TypeDec(EM_tokPos, yystack.l_mark[0].nametylist);}
break;
case 46:
#line 169 "tiger.y"
	{yyval.dec=yystack.l_mark[0].dec;}
break;
case 47:
#line 170 "tiger.y"
	{yyval.dec=A_FunctionDec(EM_tokPos, yystack.l_mark[0].fundeclist);}
break;
case 48:
#line 173 "tiger.y"
	{yyval.nametylist=A_NametyList(yystack.l_mark[0].namety, NULL);}
break;
case 49:
#line 174 "tiger.y"
	{yyval.nametylist=A_NametyList(yystack.l_mark[-1].namety, yystack.l_mark[0].nametylist);}
break;
case 50:
#line 177 "tiger.y"
	{yyval.namety=A_Namety(S_Symbol(yystack.l_mark[-2].sval), yystack.l_mark[0].ty);}
break;
case 51:
#line 179 "tiger.y"
	{yyval.ty=A_NameTy(EM_tokPos, S_Symbol(yystack.l_mark[0].sval));}
break;
case 52:
#line 180 "tiger.y"
	{yyval.ty=A_RecordTy(EM_tokPos, yystack.l_mark[-1].fieldlist);}
break;
case 53:
#line 181 "tiger.y"
	{yyval.ty=A_ArrayTy(EM_tokPos, S_Symbol(yystack.l_mark[0].sval));}
break;
case 54:
#line 184 "tiger.y"
	{yyval.fieldlist=NULL;}
break;
case 55:
#line 185 "tiger.y"
	{yyval.fieldlist=yystack.l_mark[0].fieldlist;}
break;
case 56:
#line 188 "tiger.y"
	{yyval.fieldlist=A_FieldList(A_Field(EM_tokPos, S_Symbol(yystack.l_mark[-2].sval), S_Symbol(yystack.l_mark[0].sval)), NULL);}
break;
case 57:
#line 189 "tiger.y"
	{yyval.fieldlist=A_FieldList(A_Field(EM_tokPos, S_Symbol(yystack.l_mark[-4].sval), S_Symbol(yystack.l_mark[-2].sval)), yystack.l_mark[0].fieldlist);}
break;
case 58:
#line 192 "tiger.y"
	{yyval.dec=A_VarDec(EM_tokPos, S_Symbol(yystack.l_mark[-2].sval), S_Symbol(""), yystack.l_mark[0].exp);}
break;
case 59:
#line 193 "tiger.y"
	{yyval.dec=A_VarDec(EM_tokPos, S_Symbol(yystack.l_mark[-4].sval), S_Symbol(yystack.l_mark[-2].sval), yystack.l_mark[0].exp);}
break;
case 60:
#line 196 "tiger.y"
	{yyval.fundeclist=A_FundecList(yystack.l_mark[0].fundec, NULL);}
break;
case 61:
#line 197 "tiger.y"
	{yyval.fundeclist=A_FundecList(yystack.l_mark[-1].fundec, yystack.l_mark[0].fundeclist);}
break;
case 62:
#line 200 "tiger.y"
	{yyval.fundec=A_Fundec(EM_tokPos, S_Symbol(yystack.l_mark[-5].sval), yystack.l_mark[-3].fieldlist, S_Symbol(""), yystack.l_mark[0].exp);}
break;
case 63:
#line 201 "tiger.y"
	{yyval.fundec=A_Fundec(EM_tokPos, S_Symbol(yystack.l_mark[-7].sval), yystack.l_mark[-5].fieldlist, S_Symbol(yystack.l_mark[-2].sval), yystack.l_mark[0].exp);}
break;
case 64:
#line 204 "tiger.y"
	{yyval.var=A_SimpleVar(EM_tokPos, S_Symbol(yystack.l_mark[0].sval));}
break;
case 65:
#line 205 "tiger.y"
	{yyval.var=A_FieldVar(EM_tokPos, yystack.l_mark[-2].var, S_Symbol(yystack.l_mark[0].sval));}
break;
case 66:
#line 206 "tiger.y"
	{yyval.var=A_SubscriptVar(EM_tokPos, yystack.l_mark[-3].var, yystack.l_mark[-1].exp);}
break;
case 67:
#line 207 "tiger.y"
	{yyval.var=A_SubscriptVar(EM_tokPos, A_SimpleVar(EM_tokPos, S_Symbol(yystack.l_mark[-3].sval)), yystack.l_mark[-1].exp);}
break;
#line 1023 "y.tab.c"
    }
    yystack.s_mark -= yym;
    yystate = *yystack.s_mark;
    yystack.l_mark -= yym;
    yym = yylhs[yyn];
    if (yystate == 0 && yym == 0)
    {
#if YYDEBUG
        if (yydebug)
            printf("%sdebug: after reduction, shifting from state 0 to\
 state %d\n", YYPREFIX, YYFINAL);
#endif
        yystate = YYFINAL;
        *++yystack.s_mark = YYFINAL;
        *++yystack.l_mark = yyval;
        if (yychar < 0)
        {
            if ((yychar = YYLEX) < 0) yychar = YYEOF;
#if YYDEBUG
            if (yydebug)
            {
                yys = yyname[YYTRANSLATE(yychar)];
                printf("%sdebug: state %d, reading %d (%s)\n",
                        YYPREFIX, YYFINAL, yychar, yys);
            }
#endif
        }
        if (yychar == YYEOF) goto yyaccept;
        goto yyloop;
    }
    if ((yyn = yygindex[yym]) && (yyn += yystate) >= 0 &&
            yyn <= YYTABLESIZE && yycheck[yyn] == yystate)
        yystate = yytable[yyn];
    else
        yystate = yydgoto[yym];
#if YYDEBUG
    if (yydebug)
        printf("%sdebug: after reduction, shifting from state %d \
to state %d\n", YYPREFIX, *yystack.s_mark, yystate);
#endif
    if (yystack.s_mark >= yystack.s_last && yygrowstack(&yystack) == YYENOMEM)
    {
        goto yyoverflow;
    }
    *++yystack.s_mark = (YYINT) yystate;
    *++yystack.l_mark = yyval;
    goto yyloop;

yyoverflow:
    YYERROR_CALL("yacc stack overflow");

yyabort:
    yyfreestack(&yystack);
    return (1);

yyaccept:
    yyfreestack(&yystack);
    return (0);
}
