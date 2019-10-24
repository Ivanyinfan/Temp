#include <list>
#include <queue>
#include <chrono>
#include <vector>
#include <fstream>
#include <iostream>
#include <math.h>

#define POSINFINITY +999999999
#define NEGINFINITY -999999999
#define CALIBRATEBASE 100000
#define PRUNEFACTOR 2
#define GAMECALIBRATE (5.5 / 0.07)
#define FPOS 0
#define MPOS 1
#define BPOS 2

float calibrate = 1.1;
char POSITIONTYPE[20][20] = {
    {'B','B','B','B','B','B','B','B','B','B','B','B','B','B','B','B','B','B','B','B'},
    {'B','B','B','B','B','B','B','B','B','B','B','B','B','B','B','B','B','B','B','B'},
    {'B','B','B','B','B','B','B','.','.','.','.','.','.','.','.','.','.','.','B','B'},
    {'B','B','B','B','B','B','B','.','.','.','.','.','.','.','.','.','.','.','B','B'},
    {'B','B','B','B','B','B','.','.','.','.','.','.','.','.','.','.','.','.','B','B'},
    {'B','B','B','B','B','.','.','.','.','.','.','.','.','.','.','.','.','.','B','B'},
    {'B','B','B','B','.','.','.','.','.','.','.','.','.','.','.','.','.','.','B','B'},
    {'B','B','.','.','.','.','.','.','.','.','.','.','.','.','.','.','.','.','B','B'},
    {'B','B','.','.','.','.','.','.','.','.','.','.','.','.','.','.','.','.','B','B'},
    {'B','B','.','.','.','.','.','.','.','.','.','.','.','.','.','.','.','.','B','B'},
    {'B','B','.','.','.','.','.','.','.','.','.','.','.','.','.','.','.','.','B','B'},
    {'B','B','.','.','.','.','.','.','.','.','.','.','.','.','.','.','.','.','B','B'},
    {'B','B','.','.','.','.','.','.','.','.','.','.','.','.','.','.','.','.','B','B'},
    {'B','B','.','.','.','.','.','.','.','.','.','.','.','.','.','.','W','W','B','B'},
    {'B','B','.','.','.','.','.','.','.','.','.','.','.','.','.','W','W','W','B','B'},
    {'B','B','.','.','.','.','.','.','.','.','.','.','.','.','W','W','W','W','B','B'},
    {'B','B','.','.','.','.','.','.','.','.','.','.','.','W','W','W','W','W','B','B'},
    {'B','B','.','.','.','.','.','.','.','.','.','.','.','W','W','W','W','W','B','B'},
    {'B','B','B','B','B','B','B','B','B','B','B','B','B','B','B','B','B','B','B','B'},
    {'B','B','B','B','B','B','B','B','B','B','B','B','B','B','B','B','B','B','B','B'}
};
char TYPE[7];
char ME;
char OPPONENT;
float TIME;
int LAYMAX;
int LAYERS = 0;
bool INCAMP[2] = {false};
int ARGC;
char *ARGV;
std::fstream logg;
int evaluated = 0;
int pruned = 0;
int evalFinal = 0;
int total = 0;

class Point
{
public:
    int x;
    int y;
    Point() {}
    Point(int a, int b)
    {
        x = a;
        y = b;
    }
    bool operator==(const Point &p) { return p.x == x && p.y == y; }
};

struct Point2
{
    int x;
    int y;
    Point2 *father;
    Point2(int x,int y,Point2 *f)
    {
        this->x = x;
        this->y = y;
        this->father = f;
    }
};

struct Board
{
    char board[20][20];
    std::vector<Point> invalid;
    // std::vector<Board *> *children;
    std::list<Board *> *children;
    int roughV;
    int value;
    int ox;
    int oy;
    int nx;
    int ny;
    Board() { children = nullptr; }
    Board(const Board &b)
    {
        std::memcpy((void *)board, (void *)b.board, 20 * 20);
        invalid = b.invalid;
        children = nullptr;
    }
    Board(const char *b)
    {
        std::memcpy((void *)board, (void *)b, 20 * 20);
        children = nullptr;
        ox = oy = nx = ny = 0;
    }
    bool inInvalid(const Point &p) { return find(invalid.begin(), invalid.end(), p) != invalid.end(); }
};

class Position
{
public:
    Point p;
    int distance;
    Position() {}
    Position(int x, int y, int d)
    {
        p = Point(x, y);
        distance = d;
    }
    bool operator<(const Position &pos) { return this->distance < pos.distance; }
};

Board BOARD;

void getNextJump(Board &b, int x, int y, std::vector<Board *> *result);
void getNextMove(Board &b, int x, int y, std::list<Board *> *result);
int Min_Value(Board &b, int alpha, int beta, Board **minBoard);

bool operator<(const Position &p1, const Position &p2) { return p1.distance < p2.distance; }

void getinput()
{
    char color[6];
    std::fstream fin("input.txt", std::ios::in);
    fin >> TYPE >> color >> TIME;
    for (int i = 2; i < 18; i++)
        fin >> (BOARD.board[i] + 2);
    fin.close();
    ME = color[0];
    OPPONENT = ME == 'B' ? 'W' : 'B';
    for (int y = 0; y < 20; y++)
    {
        if (y == 0 || y == 1 || y == 18 || y == 19)
        {
            for (int x = 0; x < 20; x++)
                BOARD.board[y][x] = 'B';
        }
        else
        {
            BOARD.board[y][0] = 'B';
            BOARD.board[y][1] = 'B';
            BOARD.board[y][18] = 'B';
            BOARD.board[y][19] = 'B';
        }
    }
    logg.open("log.txt", std::ios::out | std::ios::app);
}

Board *getNewBoard(Board &b, int x, int y, int nx, int ny, std::vector<Board *> *result)
{
    Board *r = new Board(b);
    char color = r->board[y][x];
    r->board[y][x] = '.';
    r->board[ny][nx] = color;
    r->ox = x;
    r->oy = y;
    r->nx = nx;
    r->ny = ny;
    result->push_back(r);
    return r;
}

Board *getNewBoard(Board &b, int x, int y, int nx, int ny, std::list<Board *> *result)
{
    Board *r = new Board(b);
    char color = r->board[y][x];
    r->board[y][x] = '.';
    r->board[ny][nx] = color;
    r->ox = x;
    r->oy = y;
    r->nx = nx;
    r->ny = ny;
    result->push_back(r);
    return r;
}

void getJumpBoard(Board &b, int x, int y, int nx, int ny, std::vector<Board *> *result)
{
    Point p(nx, ny);
    if (b.inInvalid(p))
        return;
    Board *r = getNewBoard(b, x, y, nx, ny, result);
    r->invalid.push_back(Point(x, y));
    getNextJump(*r, nx, ny, result);
}

void getNextJump(Board &b, int x, int y, std::vector<Board *> *result)
{
    if (b.board[y][x - 1] != '.' && b.board[y][x - 2] == '.')
        getJumpBoard(b, x, y, x - 2, y, result);
    if (b.board[y][x + 1] != '.' && b.board[y][x + 2] == '.')
        getJumpBoard(b, x, y, x + 2, y, result);
    if (b.board[y - 1][x - 1] != '.' && b.board[y - 2][x - 2] == '.')
        getJumpBoard(b, x, y, x - 2, y - 2, result);
    if (b.board[y - 1][x] != '.' && b.board[y - 2][x] == '.')
        getJumpBoard(b, x, y, x, y - 2, result);
    if (b.board[y - 1][x + 1] != '.' && b.board[y - 2][x + 2] == '.')
        getJumpBoard(b, x, y, x + 2, y - 2, result);
    if (b.board[y + 1][x - 1] != '.' && b.board[y + 2][x - 2] == '.')
        getJumpBoard(b, x, y, x - 2, y + 2, result);
    if (b.board[y + 1][x] != '.' && b.board[y + 2][x] == '.')
        getJumpBoard(b, x, y, x, y + 2, result);
    if (b.board[y + 1][x + 1] != '.' && b.board[y + 2][x + 2] == '.')
        getJumpBoard(b, x, y, x + 2, y + 2, result);
}

void getNextMove(Board &bb, char color)
{
    if (bb.children)
        return;
    std::vector<Board *> *result = new std::vector<Board *>();
    Board b = Board((char *)bb.board);
    for (int y = 2; y < 18; y++)
    {
        for (int x = 2; x < 18; x++)
        {
            if (b.board[y][x] == color)
            {
                char c = b.board[y][x - 1];
                if (c == '.')
                {
                    getNewBoard(b, x, y, x - 1, y, result);
                }
                else if (b.board[y][x - 2] == '.')
                {
                    getJumpBoard(b, x, y, x - 2, y, result);
                }
                c = b.board[y][x + 1];
                if (c == '.')
                {
                    getNewBoard(b, x, y, x + 1, y, result);
                }
                else if (b.board[y][x + 2] == '.')
                {
                    getJumpBoard(b, x, y, x + 2, y, result);
                }
                c = b.board[y - 1][x - 1];
                if (c == '.')
                {
                    getNewBoard(b, x, y, x - 1, y - 1, result);
                }
                else if (b.board[y - 2][x - 2] == '.')
                {
                    getJumpBoard(b, x, y, x - 2, y - 2, result);
                }
                c = b.board[y - 1][x];
                if (c == '.')
                {
                    getNewBoard(b, x, y, x, y - 1, result);
                }
                else if (b.board[y - 2][x] == '.')
                {
                    getJumpBoard(b, x, y, x, y - 2, result);
                }
                c = b.board[y - 1][x + 1];
                if (c == '.')
                {
                    getNewBoard(b, x, y, x + 1, y - 1, result);
                }
                else if (b.board[y - 2][x + 2] == '.')
                {
                    getJumpBoard(b, x, y, x + 2, y - 2, result);
                }
                c = b.board[y + 1][x - 1];
                if (c == '.')
                {
                    getNewBoard(b, x, y, x - 1, y + 1, result);
                }
                else if (b.board[y + 2][x - 2] == '.')
                {
                    getJumpBoard(b, x, y, x - 2, y + 2, result);
                }
                c = b.board[y + 1][x];
                if (c == '.')
                {
                    getNewBoard(b, x, y, x, y + 1, result);
                }
                else if (b.board[y + 2][x] == '.')
                {
                    getJumpBoard(b, x, y, x, y + 2, result);
                }
                c = b.board[y + 1][x + 1];
                if (c == '.')
                {
                    getNewBoard(b, x, y, x + 1, y + 1, result);
                }
                else if (b.board[y + 2][x + 2] == '.')
                {
                    getJumpBoard(b, x, y, x + 2, y + 2, result);
                }
            }
        }
    }
    // bb.children = result;
}

void getNextMove(Board *bb, char color)
{
    getNextMove(*bb,color);
}

void getNewBoard(Board &b, int x, int y, int nx, int ny, std::list<Board *> *result[])
{
    Board *r = new Board(b);
    char color = r->board[y][x];
    r->board[y][x] = '.';
    r->board[ny][nx] = color;
    r->ox = x;
    r->oy = y;
    r->nx = nx;
    r->ny = ny;
    int xdiff;
    int ydiff;
    if(color == 'B')
    {
        xdiff = nx - x;
        ydiff = ny - y;
    }
    else
    {
        xdiff = x - nx;
        ydiff = y - ny;
    }
    if(xdiff>0)
    {
        if(ydiff>0)
            result[FPOS]->push_back(r);
        else
            result[MPOS]->push_back(r);
    }
    else
    {
        if(ydiff>0)
            result[MPOS]->push_back(r);
        else
            result[BPOS]->push_back(r);
    }
}

int inCampNumber(Board &b, char color, int pos[])
{
    int i = 0;
    if(color=='B')
    {
        if(b.board[2][2]==color){pos[2*i]=2;pos[2*i+1]=2;i++;}
        if(b.board[2][3]==color){pos[2*i]=3;pos[2*i+1]=2;i++;}
        if(b.board[2][4]==color){pos[2*i]=4;pos[2*i+1]=2;i++;}
        if(b.board[2][5]==color){pos[2*i]=5;pos[2*i+1]=2;i++;}
        if(b.board[2][6]==color){pos[2*i]=6;pos[2*i+1]=2;i++;}
        if(b.board[3][2]==color){pos[2*i]=2;pos[2*i+1]=3;i++;}
        if(b.board[3][3]==color){pos[2*i]=3;pos[2*i+1]=3;i++;}
        if(b.board[3][4]==color){pos[2*i]=4;pos[2*i+1]=3;i++;}
        if(b.board[3][5]==color){pos[2*i]=5;pos[2*i+1]=3;i++;}
        if(b.board[3][6]==color){pos[2*i]=6;pos[2*i+1]=3;i++;}
        if(b.board[4][2]==color){pos[2*i]=2;pos[2*i+1]=4;i++;}
        if(b.board[4][3]==color){pos[2*i]=3;pos[2*i+1]=4;i++;}
        if(b.board[4][4]==color){pos[2*i]=4;pos[2*i+1]=4;i++;}
        if(b.board[4][5]==color){pos[2*i]=5;pos[2*i+1]=4;i++;}
        if(b.board[5][2]==color){pos[2*i]=2;pos[2*i+1]=5;i++;}
        if(b.board[5][3]==color){pos[2*i]=3;pos[2*i+1]=5;i++;}
        if(b.board[5][4]==color){pos[2*i]=4;pos[2*i+1]=5;i++;}
        if(b.board[6][2]==color){pos[2*i]=2;pos[2*i+1]=6;i++;}
        if(b.board[6][3]==color){pos[2*i]=3;pos[2*i+1]=6;i++;}
    }
    else
    {
        for(int y = 13;y<18;++y)
        {
            for(int x = 13;x<18;++x)
            {
                if(POSITIONTYPE[y][x]==color&&b.board[y][x]==color)
                {
                    pos[2*i]=x;
                    pos[2*i+1]=y;
                    i++;
                }
            }
        }
    }
    return i;
}

void inCamp()
{
    for(int y = 2;y<7;++y)
    {
        for(int x=2;x<7;++x)
        {
            if(POSITIONTYPE[y][x]=='B'&&BOARD.board[y][x]=='B')
            {
                INCAMP[0] = true;
                break;
            }
        }
        if(INCAMP[0])
            break;
    }
    for(int y = 13;y<18;++y)
    {
        for(int x = 13;x<18;++x)
        {
            if(POSITIONTYPE[y][x]=='W'&&BOARD.board[y][x]=='W')
            {
                INCAMP[1] = true;
                break;
            }
        }
        if(INCAMP[1])
            break;
    }
}

bool inCamp(Board &b, char color, std::list<Board *> *result[])
{
    int pos[38];
    int number = inCampNumber(b, color, pos);
    if (number==0)
        return false;
    std::list<Board *> tmp = std::list<Board *>();
    std::list<Board *> outCamp = std::list<Board *>();
    std::list<Board *> furtherCamp = std::list<Board *>();
    std::list<Board *> m = std::list<Board *>();
    std::list<Board *> back = std::list<Board *>();
    for(int i=0;i<number;++i)
    {
        int x = pos[2*i];
        int y = pos[2*i+1];
        getNextMove(b,x,y,&tmp);
        std::list<Board *>::iterator end = tmp.end();
        for(std::list<Board *>::iterator it=tmp.begin();it!=end;++it)
        {
            Board *b = *it;
            int nx = b->nx;
            int ny = b->ny;
            if(POSITIONTYPE[ny][nx]=='.')
            {
                outCamp.push_back(b);
            }
            else
            {
                if(outCamp.empty())
                {
                    int xdiff;
                    int ydiff;
                    if(color == 'B')
                    {
                        xdiff = nx - x;
                        ydiff = ny - y;
                    }
                    else
                    {
                        xdiff = x - nx;
                        ydiff = y - ny;
                    }
                    if(xdiff>0)
                    {
                        if(ydiff>0)
                            furtherCamp.push_back(b);
                        else
                        {
                            if(furtherCamp.empty())
                                m.push_back(b);
                        }
                    }
                    else
                    {
                        if(furtherCamp.empty())
                        {
                            if(ydiff>0)
                                m.push_back(b);
                            else
                                back.push_back(b);
                        }
                    }
                }
            }
        }
        tmp.clear();
    }
    if(!outCamp.empty())
    {
        result[FPOS]->splice(result[FPOS]->begin(),outCamp);
        return true;
    }
    if(!furtherCamp.empty())
    {
        result[FPOS]->splice(result[FPOS]->begin(),furtherCamp);
        return true;
    }
    result[MPOS]->splice(result[MPOS]->begin(), m);
    result[BPOS]->splice(result[BPOS]->begin(), back);
    return false;
}

void getNextMove(Board &b, int x, int y, std::list<Board *> *result)
{
    std::queue<int> q;
    char visited[400] = {false};
    char c = b.board[y][x - 1];
    if (c == '.') {getNewBoard(b, x, y, x - 1, y, result);visited[y*20+x-1]=true;}
    else if (b.board[y][x - 2] == '.'){q.push(x-2);q.push(y);visited[y*20+x-2]=true;}
    c = b.board[y][x + 1];
    if (c == '.'){getNewBoard(b, x, y, x + 1, y, result);visited[y*20+x+1]=true;}
    else if (b.board[y][x + 2] == '.'){q.push(x+2);q.push(y);visited[y*20+x+2]=true;}
    c = b.board[y - 1][x - 1];
    if (c == '.'){getNewBoard(b, x, y, x - 1, y - 1, result);visited[(y-1)*20+x-1]=true;}
    else if (b.board[y - 2][x - 2] == '.'){q.push(x-2);q.push(y-2);visited[(y-2)*20+x-2]=true;}
    c = b.board[y - 1][x];
    if (c == '.'){getNewBoard(b, x, y, x, y - 1, result);visited[(y-1)*20+x]=true;}
    else if (b.board[y - 2][x] == '.'){q.push(x);q.push(y-2);visited[(y-2)*20+x]=true;}
    c = b.board[y - 1][x + 1];
    if (c == '.'){getNewBoard(b, x, y, x + 1, y - 1, result);visited[(y-1)*20+x+1]=true;}
    else if (b.board[y - 2][x + 2] == '.')
    {q.push(x+2);q.push(y-2);visited[(y-2)*20+x+2]=true;}
    c = b.board[y + 1][x - 1];
    if (c == '.'){getNewBoard(b, x, y, x - 1, y + 1, result);visited[(y+1)*20+x-1]=true;}
    else if (b.board[y + 2][x - 2] == '.'){q.push(x-2);q.push(y+2);visited[(y+2)*20+x-2]=true;}
    c = b.board[y + 1][x];
    if (c == '.'){getNewBoard(b, x, y, x, y + 1, result);visited[(y+1)*20+x]=true;}
    else if (b.board[y + 2][x] == '.'){q.push(x);q.push(y+2);visited[(y+2)*20+x]=true;}
    c = b.board[y + 1][x + 1];
    if (c == '.'){getNewBoard(b, x, y, x + 1, y + 1, result);visited[(y+1)*20+x+1]=true;}
    else if (b.board[y + 2][x + 2] == '.'){q.push(x+2);q.push(y+2);visited[(y+2)*20+x+2]=true;}
    while(!q.empty())
    {
        int nx = q.front();
        q.pop();
        int ny = q.front();
        q.pop();
        getNewBoard(b,x,y,nx,ny,result);
        if(b.board[ny][nx-1]!='.'&&b.board[ny][nx-2]=='.'&&visited[ny*20+nx-2]==false)
            {q.push(nx-2);q.push(ny);visited[ny*20+nx-2]=true;}
        if(b.board[ny][nx+1]!='.'&&b.board[ny][nx+2]=='.'&&visited[ny*20+nx+2]==false)
            {q.push(nx+2);q.push(ny);visited[ny*20+nx+2]=true;}
        if(b.board[ny-1][nx-1]!='.'&&b.board[ny-2][nx-2]=='.'&&visited[(ny-2)*20+nx-2]==false)
            {q.push(nx-2);q.push(ny-2);visited[(ny-2)*20+nx-2]=true;}
        if(b.board[ny-1][nx]!='.'&&b.board[ny-2][nx]=='.'&&visited[(ny-2)*20+nx]==false)
            {q.push(nx);q.push(ny-2);visited[(ny-2)*20+nx]=true;}
        if(b.board[ny-1][nx+1]!='.'&&b.board[ny-2][nx+2]=='.'&&visited[(ny-2)*20+nx+2]==false)
            {q.push(nx+2);q.push(ny-2);visited[(ny-2)*20+nx+2]=true;}
        if(b.board[ny+1][nx-1]!='.'&&b.board[ny+2][nx-2]=='.'&&visited[(ny+2)*20+nx-2]==false)
            {q.push(nx-2);q.push(ny+2);visited[(ny+2)*20+nx-2]=true;}
        if(b.board[ny+1][nx]!='.'&&b.board[ny+2][nx]=='.'&&visited[(ny+2)*20+nx]==false)
            {q.push(nx);q.push(ny+2);visited[(ny+2)*20+nx]=true;}
        if(b.board[ny+1][nx+1]!='.'&&b.board[ny+2][nx+2]=='.'&&visited[(ny+2)*20+nx+2]==false)
            {q.push(nx+2);q.push(ny+2);visited[(ny+2)*20+nx+2]=true;}
    }
}

void getNextMove(Board &b, int x, int y, std::list<Board *> *result[])
{
    std::queue<int> q;
    char visited[400] = {false};
    char c = b.board[y][x - 1];
    if (c == '.') {getNewBoard(b, x, y, x - 1, y, result);visited[y*20+x-1]=true;}
    else if (b.board[y][x - 2] == '.'){q.push(x-2);q.push(y);visited[y*20+x-2]=true;}
    c = b.board[y][x + 1];
    if (c == '.'){getNewBoard(b, x, y, x + 1, y, result);visited[y*20+x+1]=true;}
    else if (b.board[y][x + 2] == '.'){q.push(x+2);q.push(y);visited[y*20+x+2]=true;}
    c = b.board[y - 1][x - 1];
    if (c == '.'){getNewBoard(b, x, y, x - 1, y - 1, result);visited[(y-1)*20+x-1]=true;}
    else if (b.board[y - 2][x - 2] == '.'){q.push(x-2);q.push(y-2);visited[(y-2)*20+x-2]=true;}
    c = b.board[y - 1][x];
    if (c == '.'){getNewBoard(b, x, y, x, y - 1, result);visited[(y-1)*20+x]=true;}
    else if (b.board[y - 2][x] == '.'){q.push(x);q.push(y-2);visited[(y-2)*20+x]=true;}
    c = b.board[y - 1][x + 1];
    if (c == '.'){getNewBoard(b, x, y, x + 1, y - 1, result);visited[(y-1)*20+x+1]=true;}
    else if (b.board[y - 2][x + 2] == '.')
    {q.push(x+2);q.push(y-2);visited[(y-2)*20+x+2]=true;}
    c = b.board[y + 1][x - 1];
    if (c == '.'){getNewBoard(b, x, y, x - 1, y + 1, result);visited[(y+1)*20+x-1]=true;}
    else if (b.board[y + 2][x - 2] == '.'){q.push(x-2);q.push(y+2);visited[(y+2)*20+x-2]=true;}
    c = b.board[y + 1][x];
    if (c == '.'){getNewBoard(b, x, y, x, y + 1, result);visited[(y+1)*20+x]=true;}
    else if (b.board[y + 2][x] == '.'){q.push(x);q.push(y+2);visited[(y+2)*20+x]=true;}
    c = b.board[y + 1][x + 1];
    if (c == '.'){getNewBoard(b, x, y, x + 1, y + 1, result);visited[(y+1)*20+x+1]=true;}
    else if (b.board[y + 2][x + 2] == '.'){q.push(x+2);q.push(y+2);visited[(y+2)*20+x+2]=true;}
    while(!q.empty())
    {
        int nx = q.front();
        q.pop();
        int ny = q.front();
        q.pop();
        getNewBoard(b,x,y,nx,ny,result);
        if(b.board[ny][nx-1]!='.'&&b.board[ny][nx-2]=='.'&&visited[ny*20+nx-2]==false)
            {q.push(nx-2);q.push(ny);visited[ny*20+nx-2]=true;}
        if(b.board[ny][nx+1]!='.'&&b.board[ny][nx+2]=='.'&&visited[ny*20+nx+2]==false)
            {q.push(nx+2);q.push(ny);visited[ny*20+nx+2]=true;}
        if(b.board[ny-1][nx-1]!='.'&&b.board[ny-2][nx-2]=='.'&&visited[(ny-2)*20+nx-2]==false)
            {q.push(nx-2);q.push(ny-2);visited[(ny-2)*20+nx-2]=true;}
        if(b.board[ny-1][nx]!='.'&&b.board[ny-2][nx]=='.'&&visited[(ny-2)*20+nx]==false)
            {q.push(nx);q.push(ny-2);visited[(ny-2)*20+nx]=true;}
        if(b.board[ny-1][nx+1]!='.'&&b.board[ny-2][nx+2]=='.'&&visited[(ny-2)*20+nx+2]==false)
            {q.push(nx+2);q.push(ny-2);visited[(ny-2)*20+nx+2]=true;}
        if(b.board[ny+1][nx-1]!='.'&&b.board[ny+2][nx-2]=='.'&&visited[(ny+2)*20+nx-2]==false)
            {q.push(nx-2);q.push(ny+2);visited[(ny+2)*20+nx-2]=true;}
        if(b.board[ny+1][nx]!='.'&&b.board[ny+2][nx]=='.'&&visited[(ny+2)*20+nx]==false)
            {q.push(nx);q.push(ny+2);visited[(ny+2)*20+nx]=true;}
        if(b.board[ny+1][nx+1]!='.'&&b.board[ny+2][nx+2]=='.'&&visited[(ny+2)*20+nx+2]==false)
            {q.push(nx+2);q.push(ny+2);visited[(ny+2)*20+nx+2]=true;}
    }
}

void getNextMove2(Board &b, char color)
{
    if (b.children)
        return;
    // std::vector<Board *> *result = new std::vector<Board *>();
    std::list<Board *> *further = new std::list<Board *>();
    std::list<Board *> *middle = new std::list<Board *>();
    std::list<Board *> *back = new std::list<Board *>();
    std::list<Board *> *moves[3] = { further, middle, back };
    bool camp;
    camp = color=='B'?INCAMP[0]:INCAMP[1];
    if(camp)
    {
        if(inCamp(b,color,moves))
        {
            b.children = further;
            return;
        }
        for (int y = 2; y < 18; y++)
        {
            for (int x = 2; x < 18; x++)
            {
                if (b.board[y][x] == color&&POSITIONTYPE[y][x]!=color)
                {
                    getNextMove(b,x,y,moves);
                }
            }
        }
    }
    else
    {
        for (int y = 2; y < 18; y++)
        {
            for (int x = 2; x < 18; x++)
            {
                if (b.board[y][x] == color)
                {
                    getNextMove(b,x,y,moves);
                }
            }
        }
    }
    further->splice(further->end(),*middle);
    further->splice(further->end(),*back);
    b.children = further;
}

int isBlackFinal(Board &b)
{
    ++evalFinal;
    bool blackFill = true;
    int blackCount = 0;
    for (int y = 13; y < 18; y++)
    {
        for (int x = 13; x < 18; x++)
        {
            int d = 285 - (x + y) * 10;
            if (d > 0)
                continue;
            char c = b.board[y][x];
            if (c == '.')
            {
                blackFill = false;
                break;
            }
            if (c == 'B')
                blackCount++;
        }
        if (blackFill == false)
            break;
    }
    if (blackFill && blackCount)
        return POSINFINITY;
    return 0;
}

int isWhiteFinal(Board &b)
{
    ++evalFinal;
    bool whiteFill = true;
    int whiteCount = 0;
    for (int y = 2; y <= 6; y++)
    {
        for (int x = 2; x <= 6; x++)
        {
            int d = (x + y) * 10 - 95;
            if (d > 0)
                continue;
            char c = b.board[y][x];
            if (c == '.')
            {
                whiteFill = false;
                break;
            }
            if (c == 'W')
                whiteCount++;
        }
        if (whiteFill == false)
            break;
    }
    if (whiteFill && whiteCount)
        return NEGINFINITY;
    return 0;
}

int evaluateBoard(Board &b)
{
    evaluated++;
    std::vector<Position> black;
    std::vector<Position> white;
    black.push_back(Position(0, 0, NEGINFINITY));
    white.push_back(Position(0, 0, NEGINFINITY));
    for (int y = 2; y < 18; y++)
    {
        for (int x = 2; x < 18; x++)
        {
            char c = b.board[y][x];
            if (c == 'B')
            {
                int d = 285 - (x + y) * 10;
                if (d == -5 && (x == 17 || y == 17))
                    d = 5;
                black.push_back(Position(x, y, d));
            }
            else if (c == 'W')
            {
                int d = (x + y) * 10 - 95;
                if (d == -5 && (x == 2 || y == 2))
                    d = 5;
                white.push_back(Position(x, y, d));
            }
        }
    }
    sort(black.begin(), black.end());
    sort(white.begin(), white.end());
    black[0].distance = black[1].distance;
    white[0].distance = white[1].distance;
    // if(evaluated==1)
    // {for(int i=0;i<20;i++)
    // {
    //     logg<<black[i].p.x<<','<<black[i].p.y<<' '<<black[i].distance<<std::endl;
    //     logg<<white[i].p.x<<','<<white[i].p.y<<' '<<white[i].distance<<std::endl;
    // }}
    int blackV = 0;
    int whiteV = 0;
    for (int i = 1; i <= 19; ++i)
    {
        blackV += black[i].distance * abs(black[i - 1].distance);
        whiteV += white[i].distance * abs(white[i - 1].distance);
    }
    // if(evaluated==1)logg<<blackV<<','<<whiteV<<std::endl;
    return whiteV - blackV;
}

int Max_Value(Board &b, int alpha, int beta, Board **maxBoard)
{
    if (LAYERS++ >= LAYMAX)
    {
        LAYERS--;
        return evaluateBoard(b);
    }
    getNextMove2(b, 'B');
    // std::vector<Board *> *c = b.children;
    std::list<Board *> *c = b.children;
    int size = c->size();
    total += size;
    std::list<Board *>::iterator end = c->end();
    // for (int i = 0; i < size; i++)
    for(std::list<Board *>::iterator it=c->begin();it!=end;++it)
    {
        // Board *b = (*c)[i];
        Board *b = *it;
        int r = isBlackFinal(*b);
        if (r)
        {
            LAYERS--;
            *maxBoard = b;
            return r;
        }
    }
    int maxValue = NEGINFINITY - 1;
    Board *maxB = nullptr;
    Board *minB = nullptr;
    Board *child;
    int value;
    int i = 0;
    // for (int i = 0; i < size; ++i)
    for(std::list<Board *>::iterator it=c->begin();it!=end;++it)
    {
        // child = (*c)[i];
        child = *it;
        // if(LAYERS==1)
        //     logg<<"LAYER:"<<LAYERS<<" MAX:"<<i<<' '<<child->ox<<','<<child->oy<<" "<<child->nx<<","<<child->ny<<std::endl;
        value = Min_Value(*child, alpha, beta, &minB);
        // if(LAYERS==1)
        //     logg<<"LAYER:"<<LAYERS<<" MAX:"<<i<<' '<<child->ox<<','<<child->oy<<" "<<child->nx<<","<<child->ny<<' '<<value<<std::endl;
        if (value >= beta)
        {
            maxValue = value;
            maxB = child;
            // for (int j = i + 1; j < size; j++)
            //     delete (*c)[j];
            for(++it;it!=end;++it)
                delete *it;
            pruned += size - i - 1;
            break;
        }
        if (value > maxValue)
        {
            delete maxB;
            maxValue = alpha = value;
            maxB = child;
        }
        else
        {
            delete child;
            delete minB;
        }
        ++i;
    }
    // logg<<"LAYER:"<<LAYERS<<" MAX:"<<maxB->ox<<','<<maxB->oy<<" "<<maxB->nx<<","<<maxB->ny<<' '<<maxValue<<std::endl;
    *maxBoard = maxB;
    LAYERS--;
    delete c;
    return maxValue;
}

int Min_Value(Board &b, int alpha, int beta, Board **minBoard)
{
    if (LAYERS++ >= LAYMAX)
    {
        LAYERS--;
        return evaluateBoard(b);
    }
    getNextMove2(b, 'W');
    // std::vector<Board *> *c = b.children;
    std::list<Board *> *c = b.children;
    int size = c->size();
    total += size;
    // logg << "minSize:" << size << std::endl;
    // for(int i=0;i<size;i++)
    //     logg << "i:"<<i<<' '<<(*c)[i]->ox<<","<<(*c)[i]->oy<<' '<<(*c)[i]->nx<<','<<(*c)[i]->ny<<std::endl;
    std::list<Board *>::iterator end = c->end();
    // for (int i = 0; i < size; i++)
    for(std::list<Board *>::iterator it=c->begin();it!=end;++it)
    {
        // Board *b = (*c)[i];
        Board *b = *it;
        int r = isWhiteFinal(*b);
        if (r)
        {
            LAYERS--;
            *minBoard = b;
            return r;
        }
    }
    int minValue = POSINFINITY + 1;
    Board *minB = nullptr;
    Board *maxB = nullptr;
    Board *child;
    int value;
    int i = 0;
    // for (int i = 0; i < size; ++i)
    for(std::list<Board *>::iterator it=c->begin();it!=end;++it)
    {
        // child = (*c)[i];
        child = *it;
        value = Max_Value(*child, alpha, beta, &maxB);
        // if(LAYERS==2)
        //     logg<<"LAYER:"<<LAYERS<<" MIN:"<<i<<' '<<child->ox<<','<<child->oy<<" "<<child->nx<<","<<child->ny<<' '<<value<<std::endl;
        if (value <= alpha)
        {
            minValue = value;
            minB = child;
            // for (int j = i + 1; j < size; j++)
            //     delete (*c)[j];
            for(++it;it!=end;++it)
                delete *it;
            pruned += size - i - 1;
            break;
        }
        if (value < minValue)
        {
            delete maxB;
            minValue = beta = value;
            minB = child;
        }
        else
        {
            delete child;
            delete maxB;
        }
        ++i;
    }
    // logg<<"LAYER:"<<LAYERS<<" MIN:"<<minB->ox<<','<<minB->oy<<" "<<minB->nx<<","<<minB->ny<<' '<<minValue<<std::endl;
    *minBoard = minB;
    LAYERS--;
    delete c;
    return minValue;
}

Board *getSingleLayMax()
{
    getNextMove2(BOARD, ME);
    // std::vector<Board *> *c = BOARD.children;
    std::list<Board *> *c = BOARD.children;
    int size = c->size();
    logg << "size:" << size << std::endl;
    if (size == 1)
        return *(c->begin());
    int i;
    for (i = 1; ; i++)
    {
        float timeNeed = pow(size, i) / CALIBRATEBASE * calibrate / PRUNEFACTOR;
        if (timeNeed > TIME)
            break;
    }
    if (i == 1)
        // return (*c)[0];
        return *(c->begin());
    LAYMAX = i - 1;
    if (ARGC == 2)
        LAYMAX = int(*ARGV) - 48;
    return nullptr;
}

int evaluateDistance()
{
    int distance = 0;
    if (ME == 'B')
    {
        for (int y = 2; y < 18; y++)
        {
            for (int x = 2; x < 18; x++)
            {
                char c = BOARD.board[y][x];
                if (c == 'B')
                {
                    int d = 285 - (x + y) * 10;
                    if (d == -5 && (x == 17 || y == 17))
                        d = 5;
                    if (d > 0)
                        distance += d;
                }
            }
        }
    }
    else
    {
        for (int y = 2; y < 18; y++)
        {
            for (int x = 2; x < 18; x++)
            {
                char c = BOARD.board[y][x];
                if (c == 'W')
                {
                    int d = (x + y) * 10 - 95;
                    if (d == -5 && (x == 2 || y == 2))
                        d = 5;
                    if (d > 0)
                        distance += d;
                }
            }
        }
    }
    return distance;
}

Board *Alpha_Beta_Search()
{
    Board *b;
    inCamp();
    if (TYPE[0] == 'S')
    {
        b = getSingleLayMax();
        if (b)
            return b;
        if (ME == 'B')
            Max_Value(BOARD, NEGINFINITY, POSINFINITY, &b);
        else
            Min_Value(BOARD, NEGINFINITY, POSINFINITY, &b);
    }
    else
    {
        std::chrono::system_clock::time_point start = std::chrono::system_clock::now();
        int dis = evaluateDistance();
        TIME = TIME / (dis / 10.0) * GAMECALIBRATE;
        b = getSingleLayMax();
        if (b)
            return b;
        if (ME == 'B')
            Max_Value(BOARD, NEGINFINITY, POSINFINITY, &b);
        else
            Min_Value(BOARD, NEGINFINITY, POSINFINITY, &b);
        std::chrono::system_clock::time_point end = std::chrono::system_clock::now();
        auto duration = std::chrono::duration_cast<std::chrono::milliseconds>(end - start);
        double elapsed = double(duration.count()) / 1000;
        logg << "elapsed:" << elapsed << std::endl;
    }
    return b;
}

void output(Board *b)
{
    std::fstream fout("output.txt", std::ios::out);
    int size = b->invalid.size();
    if (size == 0)
        fout << "E " << b->ox - 2 << ',' << b->oy - 2 << ' ' << b->nx - 2 << ',' << b->ny - 2;
    else
    {
        size = size - 1;
        for (int i = 0; i < size; i++)
            fout << "J " << b->invalid[i].x - 2 << ',' << b->invalid[i].y - 2 << ' ' << b->invalid[i + 1].x - 2 << ',' << b->invalid[i + 1].y - 2 << '\n';
        fout << "J " << b->invalid[size].x - 2 << ',' << b->invalid[size].y - 2 << ' ' << b->nx - 2 << ',' << b->ny - 2;
    }
    fout.close();
}

void output2(Board *bb)
{
    std::fstream fout("output.txt", std::ios::out);
    int xdiff = abs(bb->nx-bb->ox);
    int ydiff = abs(bb->ny-bb->oy);
    if(xdiff<2&&ydiff<2)
    {
        fout<<"E "<<bb->ox-2<<','<<bb->oy-2<<' '<<bb->nx-2<<','<<bb->ny-2;
    }
    else
    {
        std::list<Point2> l;
        l.push_back(Point2(bb->ox,bb->oy,nullptr));
        Board &b = BOARD;
        bool visited[400] = {false};
        std::vector<Point2 *> r;
        Point2 *p;
        for(std::list<Point2>::iterator it = l.begin();;++it)
        {
            int nx = it->x;
            int ny = it->y;
            p = &(*it);
            if(nx==bb->nx&&ny==bb->ny)
                break;
            if(b.board[ny][nx-1]!='.'&&b.board[ny][nx-2]=='.'&&visited[ny*20+nx-2]==false)
                {l.push_back(Point2(nx-2,ny,p));visited[ny*20+nx-2]=true;}
            if(b.board[ny][nx+1]!='.'&&b.board[ny][nx+2]=='.'&&visited[ny*20+nx+2]==false)
                {l.push_back(Point2(nx+2,ny,p));visited[ny*20+nx+2]=true;}
            if(b.board[ny-1][nx-1]!='.'&&b.board[ny-2][nx-2]=='.'&&visited[(ny-2)*20+nx-2]==false)
                {l.push_back(Point2(nx-2,ny-2,p));visited[(ny-2)*20+nx-2]=true;}
            if(b.board[ny-1][nx]!='.'&&b.board[ny-2][nx]=='.'&&visited[(ny-2)*20+nx]==false)
                {l.push_back(Point2(nx,ny-2,p));visited[(ny-2)*20+nx]=true;}
            if(b.board[ny-1][nx+1]!='.'&&b.board[ny-2][nx+2]=='.'&&visited[(ny-2)*20+nx+2]==false)
                {l.push_back(Point2(nx+2,ny-2,p));visited[(ny-2)*20+nx+2]=true;}
            if(b.board[ny+1][nx-1]!='.'&&b.board[ny+2][nx-2]=='.'&&visited[(ny+2)*20+nx-2]==false)
                {l.push_back(Point2(nx-2,ny+2,p));visited[(ny+2)*20+nx-2]=true;}
            if(b.board[ny+1][nx]!='.'&&b.board[ny+2][nx]=='.'&&visited[(ny+2)*20+nx]==false)
                {l.push_back(Point2(nx,ny+2,p));visited[(ny+2)*20+nx]=true;}
            if(b.board[ny+1][nx+1]!='.'&&b.board[ny+2][nx+2]=='.'&&visited[(ny+2)*20+nx+2]==false)
                {l.push_back(Point2(nx+2,ny+2,p));visited[(ny+2)*20+nx+2]=true;}
        }
        // logg<<"[output2]lSize="<<l.size()<<std::endl;
        do {
            r.push_back(p);
            p = p->father;
        }while(p);
        int size = r.size();
        int i;
        for(i=size-1;i>1;--i)
            fout<<"J "<<r[i]->x-2<<','<<r[i]->y-2<<' '<<r[i-1]->x-2<<','<<r[i-1]->y-2<<std::endl;
        fout<<"J "<<r[i]->x-2<<','<<r[i]->y-2<<' '<<r[i-1]->x-2<<','<<r[i-1]->y-2;
    }
    fout.close();
}

void outputLog()
{
    logg << "layMax:" << LAYMAX << std::endl;
    logg<<"Evaluated board:"<<evaluated<<", pruned board:"<<pruned<<", total board:"<<total<<", evalFinal:"<<evalFinal<<std::endl;
}

int main(int argc, char *argv[])
{
    ARGC = argc;
    ARGV = argv[argc - 1];
    getinput();
    Board *b = Alpha_Beta_Search();
    output2(b);
    outputLog();
    return 0;
}