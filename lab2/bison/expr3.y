%{
/*
Yacc程序三：实现带符号表的表达式计算
学号：2112426
姓名：怀硕
*/
#include <stdio.h>
#include <stdlib.h>
#include<ctype.h>
#include <string.h>

int yylex();
extern int yyparse();
FILE *yyin;
void yyerror(const char *s);

#define MAX_ID_LENGTH 100 // 变量名最大长度
#define MAX_TABLE_LENGTH 100

typedef struct {
    char id[MAX_ID_LENGTH];
    double value;
} Symbol;

Symbol symbolTable[100];  // 初始化符号表
int symbolCount = 0; // 当前变量名数量

void addToSymbolTable(char *id, double value) 
{
    printf("New Viriabel %s and value %f\n", id, value);
    //如果可以在符号表中找到，则重赋值。
    for (int i = 0; i < symbolCount; i++) 
    {
        if (strcmp(symbolTable[i].id, id) == 0) 
        {
            symbolTable[i].value = value;
        }
    }
    //如果在符号表中没找到，则添加新符号。
    Symbol symbol = {"\0", 0.0};
    strcpy(symbol.id, id);
    symbol.value = value;
    symbolTable[symbolCount++] = symbol;
}

double getFromSymbolTable(char *id) 
{
    printf("Search Viriable %s\n", id);
    for (int i = 0; i < symbolCount; i++) 
    {
        if (strcmp(symbolTable[i].id, id) == 0) 
        {
            return symbolTable[i].value;
        }
    }
    // 如果没找到变量，返回0
    printf("Viriable %s\n Not Found", id);
    return 0.0; 
}

%}



//属性值可能具有的类型
%union 
{
    double num;
    char* id;
}

%token ADD MINUS MULTIPLY DIVIDE
%token LPAREN RPAREN
%token ASSIGN
%token <num> NUMBER
%token <id> IDENTIFIER


%left ADD MINUS
%left MULTIPLY DIVIDE
%right UMINUS
%right ASSIGN

//表达式的属性值设置为数值类型
%type <num> expr
%type <num> assignStmt

%%
lines   :       lines expr ';' { printf("%f\n", $2);printf("lines -> lines expr ;\n"); }
        |       lines assignStmt ';' { printf("lines -> lines assignment ;\n"); }
        |       lines ';' {printf("lines -> lines ;\n");}
        |                 { printf("lines -> \n"); }
        ;

expr    :       expr ADD expr   { $$ = $1 + $3;printf("expr -> expr ADD expr\n");}
        |       expr MINUS expr   { $$ = $1 - $3;printf("expr -> expr MINUS expr\n"); }
        |       expr MULTIPLY expr   { $$ = $1 * $3;printf("expr -> expr MULTIPLY expr\n"); }
        |       expr DIVIDE expr   { $$ = $1 / $3;printf("expr -> expr DIVIDE expr\n"); }
        |       MINUS expr %prec UMINUS   { $$ = -$2;printf("expr -> UMINUS expr\n"); }
        |       NUMBER  { $$ = $1;printf("expr -> NUMBER\n"); }
        |       IDENTIFIER  { $$ = getFromSymbolTable($1);printf("expr -> IDENTIFIER\n"); }
        |       LPAREN expr RPAREN  { $$ = $2;printf("expr -> LPAREN expr RPAREN\n"); }
        ;

assignStmt : IDENTIFIER ASSIGN expr { addToSymbolTable($1, $3); $$ = $3;printf("assignStmt -> IDENTIFIER ASSIGN expr\n"); }
        ;


%%
int yylex()
{
    int t;
    while (1)
    {
        t = getchar();
        if (t == ' ' || t == '\t' || t == '\n')
        {
            // 忽略空白符
        }
        else if (isdigit(t))
        {
            int num = t - '0';
            while (isdigit(t = getchar()))
            {
                num = num * 10 + (t - '0');
            }
            ungetc(t, stdin);
            yylval.num = num;
            return NUMBER;
        }
        else if (isalpha(t))
        {
            int i = 0;
            char id[MAX_ID_LENGTH];
            id[i++] = t;
            while (isalnum(t = getchar()) || t == '_')
            {
                if (i < MAX_TABLE_LENGTH - 1)
                    id[i++] = t;
            }
            id[i] = '\0';
            ungetc(t, stdin);
            yylval.id = strdup(id);
            return IDENTIFIER;
        }
        else if (t == '+')
        {
            return ADD;
        }
        else if (t == '-')
        {
            return MINUS;
        }
        else if (t == '*')
        {
            return MULTIPLY;
        }
        else if (t == '/')
        {
            return DIVIDE;
        }
        else if (t == '=')
        {
            return ASSIGN;
        }
        else if (t == '(')
        {
            return LPAREN;
        }
        else if (t == ')')
        {
            return RPAREN;
        }
        else
        {
            return t;
        }
    }
}

int main(void)
{
    yyin = stdin;
    do{
        yyparse();
    } while (!feof(yyin));
    return 0;
}

void yyerror(const char *s)
{
    fprintf(stderr, "Parse error: %s\n", s);
    exit(1);
}
