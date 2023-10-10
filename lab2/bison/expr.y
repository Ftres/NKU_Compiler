// %{
// /*
// Yacc程序一：实现表达式的计算
// 学号：2112426
// 姓名：怀硕
// */
// #include<stdio.h>
// #include<stdlib.h>
// #include<ctype.h>
// #ifndef YYSTYPE
// #define YYSTYPE double // 这里定义了`YYSTYPE`为`double`，意味着`yacc`产生的值应该是双精度浮点数。
// #endif
// int yylex();
// extern int yyparse();
// FILE* yyin;
// void yyerror(const char* s);
// %}

// // 定义单词类别
// %token ADD MINUS MULTIPLY DIVIDE
// %token LPAREN RPAREN
// %token NUMBER

// %left ADD MINUS
// %left MULTIPLY DIVIDE
// %right UMINUS         

// %%

// lines   :       lines expr ';' { printf("%f\n", $2); }
//         |       lines ';'
//         |
//         ;

// expr    :       expr ADD expr   { $$=$1+$3; }
//         |       expr MINUS expr   { $$=$1-$3; }
//         |       expr MULTIPLY expr   { $$=$1*$3; }
//         |       expr DIVIDE expr   { $$=$1/$3; }
//         |       MINUS expr %prec UMINUS   {$$=-$2;}
//         |       NUMBER  {$$=$1;}
//         |       LPAREN expr RPAREN  { $$=$2; }
//         ;

// %%

// // 词法分析程序
// int yylex()
// {
//     int t;
//     while(1){
//         t=getchar();
//         if(t==' '||t=='\t'||t=='\n'){
//             // 忽略空白符
//         }else if(isdigit(t)){
//             // 解析多位数字返回数字类型 
//             int num = t - '0';
//             while (isdigit(t = getchar())) {
//                 num = num * 10 + (t - '0');
//             }
//             ungetc(t, stdin);
//             yylval = num; // 将数字值存储在yylval中
//             return NUMBER;
//         }else if(t=='+'){
//             return ADD;
//         }else if(t=='-'){
//             return MINUS;
//         }else if(t=='*'){
//             return MULTIPLY;
//         }else if(t=='/'){
//             return DIVIDE;
//         }else if(t=='('){
//             return LPAREN;
//         }else if(t==')'){
//             return RPAREN;
//         }else{
//             return t;
//         }
//     }
// }

// int main(void)
// {
//     yyin=stdin;
//     do{
//         yyparse();
//     }while(!feof(yyin));
//     return 0;
// }

// void yyerror(const char* s){
//     fprintf(stderr,"Parse error: %s\n",s);
//     exit(1);
// }


%{
/*********************************************
将所有的词法分析功能均放在 yylex 函数内实现，为 +、-、*、\、(、 )、标识符、赋值符号和整数分别定义一个单词类别，在 yylex 内实现代码，能
识别这些单词，并将单词类别返回给词法分析程序。
实现功能更强的词法分析程序，可识别并忽略空格、制表符、回车等
空白符，能识别多位十进制整数。
YACC 文件
**********************************************/
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>


// 符号表结构
struct symbol_entry {
    char name[256];
    double value;
};

struct symbol_table {
    struct symbol_entry entries[100];
    int count;
};

struct symbol_table symbol_table;

int yylex();
extern int yyparse();
FILE *yyin;
void yyerror(const char *s);
%}

%union
{
    char* id;
    double num;
}

// TODO: 给每个符号定义一个单词类别
%token ADD    // 加号
%token MINUS  // 减号
%token MULTIPLY  // 乘号
%token DIVIDE  // 除号
%token LPAREN  // 左括号
%token RPAREN  // 右括号
%token <num> NUMBER  // 数字
%token <id> ID  // 标识符
%token ASSIGN  // 赋值符号

%type <num> statement
%type <num> expr

//left,right明确结合性
//定义了算术运算符的优先级，越靠下优先级越高。`UMINUS`用于识别负数。
%left ADD MINUS
%left MULTIPLY DIVIDE
%right UMINUS

//语法分析段
%%

lines : lines statement ';' { printf("%f\n", $2); }
      | lines ';'
      |
      ;

// 语句可以是赋值语句或表达式
statement : ID ASSIGN expr {
    // 在符号表中查找变量，如果不存在则添加
                printf("here0\n");
                int i;
                for (i = 0; i < symbol_table.count; i++) {
                    if (strcmp($1, symbol_table.entries[i].name) == 0) {
                        symbol_table.entries[i].value = $3;
                        break;
                    }
                }
                printf("here\n");
                if (i == symbol_table.count) {
                    strcpy(symbol_table.entries[symbol_table.count].name, $1);
                    symbol_table.entries[symbol_table.count].value = $3;
                    symbol_table.count++;
                }
                $$ = $3;
            }
          | expr { $$ = $1; }
          ;

// TODO: 完善表达式的规则
// $$代表产生式左部的属性值，$n 为产生式右部第n个token的属性值
expr : expr ADD expr { $$ = $1 + $3; }
     | expr MINUS expr { $$ = $1 - $3; }
     | expr MULTIPLY expr { $$ = $1 * $3; }
     | expr DIVIDE expr { $$ = $1 / $3; }
     | MINUS expr %prec UMINUS { $$ = -$2; }   //%prec UMINUS声明表示一元减号的优先级高于其他运算符，因此在表达式中会首先计算一元减号
     | NUMBER { $$ = $1; }
     | LPAREN expr RPAREN { $$ = $2; }
     | ID {
         // 查找变量在符号表中的值，如果不存在则默认为0
         int i;
         for (i = 0; i < symbol_table.count; i++) {
             if (strcmp($1, symbol_table.entries[i].name) == 0) {
                 $$ = symbol_table.entries[i].value;
                 break;
             }
         }
         if (i == symbol_table.count) {
             $$ = 0;
         }
     }
     ;

%%

// 程序部分
//词法分析段

int yylex()
{
    int t; //储存字符
    while (1)
    {
        t = getchar(); // 从输入流中获取下一个字符
        if (t == ' ' || t == '\t' || t == '\n')
        {
            // 忽略空白字符、制表符和换行符
        }
        else if (isdigit(t))
        {
            printf("digit\n");
            // TODO: 解析多位数字返回数字类型
            // 如果当前字符是数字
            ungetc(t, stdin); // 将第一个数字字符放回输入流
            int value = 0;
            while (isdigit(t = getchar()))
            {
                printf("%d\n", t);
                value = value * 10 + (t - '0'); // 解析多位整数
            }
            ungetc(t, stdin); // 将非数字字符放回输入流
            yylval.num = value;   // 存储解析的整数值
            printf("%d\n, value");
            return NUMBER;    // 返回标记值为NUMBER的标记
        }
        else if (isalpha(t))
        {
            printf("alpha\n");
            // TODO: 解析标识符
            ungetc(t, stdin); // 将第一个字符放回输入流
            char id[256];
            int i = 0;
            while (isalnum(t = getchar()) || t == '_')
            {
                if (i < 255)
                {
                    id[i++] = t;
                }
            }
            id[i] = '\0';
            yylval.id=id; // 存储解析的标识符
            printf("%s\n", id);
            return ID;         // 返回标记值为IDENTIFIER的标记
        }
        else if (t == '+')
        {
            printf("equal\n");
            return ADD; // 返回标记值为ADD的标记
        }
        else if (t == '-')
        {
            printf("equal\n");
            return MINUS; // 返回标记值为MINUS的标记
        }
        else if (t == '*')
        {
            printf("equal\n");
            return MULTIPLY; // 返回标记值为MULTIPLY的标记
        }
        else if (t == '/')
        {
            printf("equal\n");
            return DIVIDE; // 返回标记值为DIVIDE的标记
        }
        else if (t == '(')
        {
            printf("equal\n");
            return LPAREN; // 返回标记值为LPAREN的标记
        }
        else if (t == ')')
        {
            printf("equal\n");
            return RPAREN; // 返回标记值为RPAREN的标记
        }
        else if (t == '=')
        {
            printf("equal\n");
            return ASSIGN; // 返回标记值为ASSIGN的标记
        }
        else
        {
            printf("equal\n");
            return t; // 返回未知字符的标记（将字符本身作为标记）
        }
    }
}

/*
yylex函数笔记：
yylex使用一个无限循环来连续读取字符，直到识别到一个有效的词法单元（token）为止。
首先，它使用 getchar 从输入流中获取下一个字符，并存储在变量 t 中。
如果字符是空格、制表符或换行符，则忽略它们，不返回任何标记。
如果字符是数字（isdigit(t) 返回 true），则进入一个循环，解析多位整数，并将整数值存储在 yylval 变量中。然后，返回一个标记为 NUMBER 的标记，表示识别到一个整数。
如果字符是字母或下划线（isalpha(t) 返回 true），则进入一个循环，解析标识符，并将标识符存储在 yylval 变量中。然后，返回一个标记为 IDENTIFIER 的标记，表示识别到一个标识符。
如果字符是加号、减号、乘号、除号、左括号、右括号或赋值符号，则分别返回相应的标记（ADD、MINUS、MULTIPLY、DIVIDE、LPAREN、RPAREN、ASSIGN）。
如果字符不属于上述任何一种情况，则将字符本身作为标记值返回，表示未知字符。
在每次循环迭代中，yylex 函数从输入流中读取字符，直到识别到一个有效的标记为止，然后返回该标记。
*/
int main(void)
{
    yyin = stdin;
    symbol_table.count = 0; // 初始化符号表计数器
    do
    {
        yyparse();
    } while (!feof(yyin));
    return 0;
}

void yyerror(const char *s)
{
    fprintf(stderr, "解析错误: %s\n", s);
    exit(1);
}
