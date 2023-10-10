%{
/*
Yacc程序一：实现表达式的计算
学号：2112426
姓名：怀硕
*/
#include<stdio.h>
#include<stdlib.h>
#include<ctype.h>
#ifndef YYSTYPE
#define YYSTYPE double // 这里定义了`YYSTYPE`为`double`，意味着`yacc`产生的值应该是双精度浮点数。
#endif
int yylex();
extern int yyparse();
FILE* yyin;
void yyerror(const char* s);
%}

// 定义单词类别
%token ADD MINUS MULTIPLY DIVIDE
%token LPAREN RPAREN
%token NUMBER

%left ADD MINUS
%left MULTIPLY DIVIDE
%right UMINUS         

%%

lines   :       lines expr ';' { printf("%f\n", $2); }
        |       lines ';'
        |
        ;

expr    :       expr ADD expr   { $$=$1+$3; }
        |       expr MINUS expr   { $$=$1-$3; }
        |       expr MULTIPLY expr   { $$=$1*$3; }
        |       expr DIVIDE expr   { $$=$1/$3; }
        |       MINUS expr %prec UMINUS   {$$=-$2;}
        |       NUMBER  {$$=$1;}
        |       LPAREN expr RPAREN  { $$=$2; }
        ;

%%

// 词法分析程序
int yylex()
{
    int t;
    while(1){
        t=getchar();
        if(t==' '||t=='\t'||t=='\n'){
            // 忽略空白符
        }else if(isdigit(t)){
            // 解析多位数字返回数字类型 
            int num = t - '0';
            while (isdigit(t = getchar())) {
                num = num * 10 + (t - '0');
            }
            ungetc(t, stdin);
            yylval = num; // 将数字值存储在yylval中
            return NUMBER;
        }else if(t=='+'){
            return ADD;
        }else if(t=='-'){
            return MINUS;
        }else if(t=='*'){
            return MULTIPLY;
        }else if(t=='/'){
            return DIVIDE;
        }else if(t=='('){
            return LPAREN;
        }else if(t==')'){
            return RPAREN;
        }else{
            return t;
        }
    }
}

int main(void)
{
    yyin=stdin;
    do{
        yyparse();
    }while(!feof(yyin));
    return 0;
}

void yyerror(const char* s){
    fprintf(stderr,"Parse error: %s\n",s);
    exit(1);
}

