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

float calibrate = 1.1;
char TYPE[7];
char ME;
char OPPONENT;
float TIME;
int LAYMAX;
int LAYERS;
int ARGC;
char *ARGV;
std::fstream logg;
int evaluated = 0;
int pruned = 0;

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

struct Board
{
    char board[20][20];
    std::vector<Point> invalid;
    std::vector<Board *> *children;
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
    bb.children = result;
}

void getNextMove2(Board &b, char color)
{
    if (b.children)
        return;
    std::vector<Board *> *result = new std::vector<Board *>();
    std::queue<int> q;
    for (int y = 2; y < 18; y++)
    {
        for (int x = 2; x < 18; x++)
        {
            if (b.board[y][x] == color)
            {
                char visited[400] = {false};
                char c = b.board[y][x - 1];
                if (c == '.')
                {
                    getNewBoard(b, x, y, x - 1, y, result);
                    visited[y*20+x-1]=true;
                }
                else if (b.board[y][x - 2] == '.')
                {
                    q.push(x-2);
                    q.push(y);
                    visited[y*20+x-2]=true;
                }
                c = b.board[y][x + 1];
                if (c == '.')
                {
                    getNewBoard(b, x, y, x + 1, y, result);
                    visited[y*20+x+1]=true;
                }
                else if (b.board[y][x + 2] == '.')
                {
                    q.push(x+2);
                    q.push(y);
                    visited[y*20+x+2]=true;
                }
                c = b.board[y - 1][x - 1];
                if (c == '.')
                {
                    getNewBoard(b, x, y, x - 1, y - 1, result);
                    visited[(y-1)*20+x-1]=true;
                }
                else if (b.board[y - 2][x - 2] == '.')
                {
                    q.push(x-2);
                    q.push(y-2);
                    visited[(y-2)*20+x-2]=true;
                }
                c = b.board[y - 1][x];
                if (c == '.')
                {
                    getNewBoard(b, x, y, x, y - 1, result);
                    visited[(y-1)*20+x]=true;
                }
                else if (b.board[y - 2][x] == '.')
                {
                    q.push(x);
                    q.push(y-2);
                    visited[(y-2)*20+x]=true;
                }
                c = b.board[y - 1][x + 1];
                if (c == '.')
                {
                    getNewBoard(b, x, y, x + 1, y - 1, result);
                    visited[(y-1)*20+x+1]=true;
                }
                else if (b.board[y - 2][x + 2] == '.')
                {
                    q.push(x+2);
                    q.push(y-2);
                    visited[(y-2)*20+x+2]=true;
                }
                c = b.board[y + 1][x - 1];
                if (c == '.')
                {
                    getNewBoard(b, x, y, x - 1, y + 1, result);
                    visited[(y+1)*20+x-1]=true;
                }
                else if (b.board[y + 2][x - 2] == '.')
                {
                    q.push(x-2);
                    q.push(y+2);
                    visited[(y+2)*20+x-2]=true;
                }
                c = b.board[y + 1][x];
                if (c == '.')
                {
                    getNewBoard(b, x, y, x, y + 1, result);
                    visited[(y+1)*20+x]=true;
                }
                else if (b.board[y + 2][x] == '.')
                {
                    q.push(x);
                    q.push(y+2);
                    visited[(y+2)*20+x]=true;
                }
                c = b.board[y + 1][x + 1];
                if (c == '.')
                {
                    getNewBoard(b, x, y, x + 1, y + 1, result);
                    visited[(y+1)*20+x+1]=true;
                }
                else if (b.board[y + 2][x + 2] == '.')
                {
                    q.push(x+2);
                    q.push(y+2);
                    visited[(y+2)*20+x+2]=true;
                }
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
        }
    }
    b.children = result;
}

int isBlackFinal(Board &b)
{
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
    // for(int i=0;i<20;i++)
    // {
    //     std::cout<<black[i].p.x<<','<<black[i].p.y<<' '<<black[i].distance<<std::endl;
    //     std::cout<<white[i].p.x<<','<<white[i].p.y<<' '<<white[i].distance<<std::endl;
    // }
    int blackV = 0;
    int whiteV = 0;
    for (int i = 1; i <= 19; ++i)
    {
        blackV += black[i].distance * abs(black[i - 1].distance);
        whiteV += white[i].distance * abs(white[i - 1].distance);
    }
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
    std::vector<Board *> *c = b.children;
    int size = c->size();
    for (int i = 0; i < size; i++)
    {
        Board *b = (*c)[i];
        int r = isBlackFinal(*b);
        if (r)
        {
            LAYERS--;
            *maxBoard = b;
            return r;
        }
    }
    int maxValue = NEGINFINITY;
    Board *maxB = nullptr;
    Board *minB = nullptr;
    Board *child;
    int value;
    for (int i = 0; i < size; ++i)
    {
        child = (*c)[i];
        value = Min_Value(*child, alpha, beta, &minB);
        // logg<<"LAYER:"<<LAYERS<<" MAX:"<<i<<' '<<b->ox<<','<<b->oy<<" "<<b->nx<<","<<b->ny<<' '<<value<<std::endl;
        if (value >= beta)
        {
            maxValue = value;
            maxB = child;
            for (int j = i + 1; j < size; j++)
                delete (*c)[j];
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
    std::vector<Board *> *c = b.children;
    int size = c->size();
    // logg << "minSize:" << size << std::endl;
    // for(int i=0;i<size;i++)
    //     logg << "i:"<<i<<' '<<(*c)[i]->ox<<","<<(*c)[i]->oy<<' '<<(*c)[i]->nx<<','<<(*c)[i]->ny<<std::endl;
    for (int i = 0; i < size; i++)
    {
        Board *b = (*c)[i];
        int r = isWhiteFinal(*b);
        if (r)
        {
            LAYERS--;
            *minBoard = b;
            return r;
        }
    }
    int minValue = POSINFINITY;
    Board *minB = nullptr;
    Board *maxB = nullptr;
    Board *child;
    int value;
    for (int i = 0; i < size; ++i)
    {
        child = (*c)[i];
        value = Max_Value(*child, alpha, beta, &maxB);
        // log<<"LAYER:"<<LAYERS<<" MIN:"<<i<<' '<<b->ox<<','<<b->oy<<" "<<b->nx<<","<<b->ny<<' '<<value<<std::endl;
        if (value <= alpha)
        {
            minValue = value;
            minB = child;
            for (int j = i + 1; j < size; j++)
                delete (*c)[j];
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
    std::vector<Board *> *c = BOARD.children;
    int size = c->size();
    logg << "size:" << size << std::endl;
    int i;
    for (i = 1; i < POSINFINITY; i++)
    {
        float timeNeed = pow(size, i) / CALIBRATEBASE * calibrate / PRUNEFACTOR;
        if (timeNeed > TIME)
            break;
    }
    if (i == 1)
        return (*c)[0];
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
        TIME = TIME / (dis / 10) * GAMECALIBRATE;
        b = getSingleLayMax();
        if (b)
            return b;
        if (ME == 'B')
            Max_Value(BOARD, NEGINFINITY, POSINFINITY, &b);
        else
            Min_Value(BOARD, NEGINFINITY, POSINFINITY, &b);
        std::chrono::system_clock::time_point end = std::chrono::system_clock::now();
        auto duration = std::chrono::duration_cast<std::chrono::milliseconds>(end - start);
        double elapsed = double(duration.count()) / 100;
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

void outputLog()
{
    logg << "layMax:" << LAYMAX << std::endl;
    logg << "Evaluated board:" << evaluated << ", pruned board:" << pruned << std::endl;
}

int main(int argc, char *argv[])
{
    ARGC = argc;
    ARGV = argv[argc - 1];
    getinput();
    Board *b = Alpha_Beta_Search();
    output(b);
    outputLog();
    return 0;
}