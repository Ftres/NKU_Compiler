%{
/*
Yacc程序二：实现表达式的后缀形式转换
学号：2112426
姓名：怀硕
*/
#include<stdio.h>
#include<stdlib.h>
#include<ctype.h>
#ifndef YYSTYPE
#define YYSTYPE char*  // 这里定义了`YYSTYPE`为`char*`，意味着`yacc`产生的值应该是字符串，即产生式中的$变量的类型为YYSTYPE。
#endif
#include<string.h>
int yylex();
int yyparse();
FILE* yyin;
void yyerror(const char* s);
char NumSave[10];
%}

// 定义单词类别
%token ADD MINUS MULTIPLY DIVIDE //加减乘除
%token LPAREN RPAREN //左右括号
%token NUMBER //数

//优先级定义：左高于右，下高于上。
%left ADD MINUS
%left MULTIPLY DIVIDE
%right UMINUS

%start lines
%%

lines   :       lines expr ';' { printf("%s\n", $2); }
        |       lines ';'
        |
        ;


expr    :       expr ADD expr   { $$ = (char*)malloc((strlen($1)+ strlen($3) + 3)*sizeof(char));strcpy($$, $1);strcat($$," ");strcat($$, $3);strcat($$, " +"); }
        |       expr MINUS expr   { $$ = (char*)malloc((strlen($1)+ strlen($3) + 3)*sizeof(char));strcpy($$, $1);strcat($$," ");strcat($$, $3);strcat($$, " -"); }
        |       expr MULTIPLY expr   { $$ = (char*)malloc((strlen($1)+ strlen($3) + 3)*sizeof(char));strcpy($$, $1);strcat($$," ");strcat($$, $3);strcat($$, " *"); }
        |       expr DIVIDE expr   { $$ = (char*)malloc((strlen($1)+ strlen($3) + 3)*sizeof(char));strcpy($$, $1);strcat($$," ");strcat($$, $3);strcat($$, " /"); }
        |       MINUS expr %prec UMINUS   { $$ = (char*)malloc((strlen($2)+ strlen(" -"))*sizeof(char));strcpy($$, $2);strcat($$," -"); }
        |       NUMBER  { $$ = (char*)malloc((strlen($1)+1)*sizeof(char));strcpy($$, $1);strcat($$, " "); }
        |       LPAREN expr RPAREN  { $$ = (char*)malloc((strlen($2)+1)*sizeof(char));strcpy($$, $2);strcat($$, " "); }
        ;

%%

// 词法分析程序
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
        else if (t>='0' && t<='9') 
        {
            // 解析多位数字返回字符串 
            int num = 0;
            NumSave[num]=t;
            t = getchar();
            while (t>='0'&& t<='9') 
            {
                num++;
                NumSave[num]=t;
                t = getchar();
            }
            NumSave[num+1]='\0';
            ungetc(t, stdin);
            yylval = NumSave; // 将字符串存储在yylval中
            // printf("%s\n", NumSave);
            return NUMBER;
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
    do 
    {
        yyparse();
    } while (!feof(yyin));
    return 0;
}

void yyerror(const char* s)
{
    fprintf(stderr, "Parse error: %s\n", s);
    exit(1);
}


