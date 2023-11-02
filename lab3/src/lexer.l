%option noyywrap
%option nounput
%option noinput
%top{
    #include <stdarg.h>
    #include <string>
    #include "common.h" 
    #include <iostream>
    #include <ostream>
    #include <fstream>
    #include <malloc.h>
    #include <unordered_map>
    #include <cstring>

    using namespace std;
}
%{
    bool if_New; //是否为域内新建

    //链表形式组织符号表（此处符号表只记录ID）
    //链表节点
    struct node {
        char name[56];
        node* prev, * next;
    };
    //链表
    struct id_list {
        node* head, * tail;
        int count;
    };

    id_list idlist;

    // 初始化符号表链表
    void init_idlist() {
        idlist.head = (node*)malloc(sizeof(node));
        idlist.head->next = idlist.head->prev = nullptr;
        idlist.tail = idlist.head;
        idlist.count = 0;
    }

    // 链表中添加元素
    node* add(char* s) {
        node *id_elem = nullptr;
        id_elem = (node*)malloc(sizeof(node));
        strcpy(id_elem->name, s);
        idlist.tail->next = id_elem;
        id_elem->prev = idlist.tail;
        id_elem->next = nullptr;
        idlist.tail = id_elem;
        idlist.count++;
        return id_elem;
    }

    //自定义stack_element类（符号栈中元素）
    /*
    每个栈元素stack_element会持有一个指向前一元素的指针pre和一个map
    map是无序的，存储的是当前这个{}范围下所有的映射对：<标识符名，对应符号表表项的地址>
    */
    class stack_element {
    private:
        unordered_map<string, node*> map;
        stack_element* prev;
    public:
        //初始化空的符号栈的首元素
        stack_element() {
            prev = nullptr;
        }
        //往符号栈里压元素，新压入元素的pre自然就是低他一层的元素
        stack_element(stack_element* back) {
            prev = back;
        }
        void add_into_map(string name, node* id) {
            map[name] = id;
        }
        stack_element* get_prev() {
            return prev;
        }
        node* get_identifier(string name) {
            if (map.empty()) {
                return nullptr;
            }
            if (map.find(name) != map.end()) {
                return map[name];
            }
            else return nullptr;
        }
        ~stack_element() {
            prev = nullptr;
            unordered_map<string, node*>().swap(map);
            malloc_trim(0);
        }
    };

    // symble_stack 类，识别到标识符将其存入符号栈中，最后再一次性输出
    class symble_stack: public stack_element {
    private:
        // 栈的顶部
        stack_element* top;
    public:
        // 初始化，之所以要初始化一个top表项，是为了存储全局标识符，这些标识符没有{}标识
        symble_stack() {
            stack_element* t = new stack_element();
            top = t;
        }

        //栈中的每一个元素都代表一个{}范围内所有标识符相关的存储
        // 添加元素
        void push() {
            // printf("pushing\n");
            stack_element* t = new stack_element(top);
            top = t;
        }

        // 弹出元素
        void pop() {
            // printf("poping\n");
            stack_element* p;
            p = top;
            top = top->get_prev();
            p->~stack_element();
        }

        // 添加标识符
        void add_map(string name, node* id) {
            top->add_into_map(name, id);
        }

        //查找符号栈中是否曾出现过同样的标识符
        node* lookup(string name) {
        // 1. 未出现：创建一个新的idlist_entry，并添加到top指针指向的map中，然后返回idlist_entry的地址
        // 2. 已出现：返回对应的idlist_entry地址

            node* p_entry = nullptr;

            //搜索：从栈顶依次向下搜索,因为{}可能层层嵌套
            stack_element* p;
            p = top;
            do {
                p_entry = p->get_identifier(name);
                if (p_entry) {
                    //p_entry不为空，意味着已经找到了
                    return p_entry;
                }
                //p_entry为空，意味着本域没找到，继续向下搜索
                p = p->get_prev();
                if(if_New)
                {
                    //本域新建
                    p_entry = add((char*)name.c_str());
                    top->add_into_map(name, p_entry);
                    return p_entry;
                }
            } while (p);
            
            //搜索不到，于是这是一个新的标识符
            p_entry = add((char*)name.c_str());
            top->add_into_map(name, p_entry);
            return p_entry;
        }
    };

    extern FILE *yyin;
    extern FILE *yyout;

    int yycolumnno = 1;

    extern dump_type_t dump_type;

    // 单词、词素、行号、列号、属性
    inline void dump_tokens(const char* format, ...)
    {
        va_list args;
        va_start(args, format);
        int format_length = strlen(yytext);
        if (dump_type == TOKENS)
            vfprintf(yyout, format, args);
        va_end(args);
        
        // printf("%d\n", format_length);

        yycolumnno += format_length;
    }
    /* Your code here, if desired (lab3). */
    
    symble_stack m_stack;
%}

/* definitions section */

 // 数字
digit [0-9]

 // 浮点型常量
FLOAT {digit}*\.({digit}+)?(e|E[+\-]?{digit}+)?

 // 整型常量
 //十进制
DECIMIAL ([1-9][0-9]*|0)  
 //八进制
OCTAL (0[0-7]+)           
 //十六进制
HEXADECIMAL (0[xX][0-9A-Fa-f]+)            



 // 匹配ID
ID [[:alpha:]_][[:alpha:][:digit:]_]*

 //匹配不同类型的行结束符 
 //包括回车换行（\r\n）
 //换行符（\n）
 //回车符（\r）
EOL (\r\n|\n|\r)   

 //匹配空白字符，包括制表符（\t）和空格
WHITE [\t ]     

/*  Your code here (lab3). */

 //块注释
BLOCKCOMMENTBEGIN "/*"
 // 匹配块注释中的任何字符或换行符
BLOCKCOMMENTELEMENT .|\n
 // 匹配块注释的结束标志
BLOCKCOMMENTEND "*/"

/*声明blockcomment起始状态*/
%x BLOCKCOMMENT  

/*行注释*/
LINECOMMENT \/\/[^\n]*

%%
    /* rules section */
"int" {
    if_New = 1;
    dump_tokens("INT     \t%-10s\t%d\t%d\t\t\n", yytext, yylineno, yycolumnno);
}

"main" {
    dump_tokens("MAIN    \t%-10s\t%d\t%d\t\t\n", yytext, yylineno, yycolumnno);
}

"float" {
    if_New = 1;
    dump_tokens("FLOAT   \t%-10s\t%d\t%d\t\t\n", yytext, yylineno, yycolumnno);
}

"double" {
    if_New = 1;
    dump_tokens("DOUBLE  \t%-10s\t%d\t%d\t\t\n", yytext, yylineno, yycolumnno);
}

"void" {
    dump_tokens("VOID    \t%-10s\t%d\t%d\t\t\n", yytext, yylineno, yycolumnno);
}

"if" {
    dump_tokens("IF      \t%-10s\t%d\t%d\t\t\n", yytext, yylineno, yycolumnno);
}

"else" {
    dump_tokens("ELSE    \t%-10s\t%d\t%d\t\t\n", yytext, yylineno, yycolumnno);
}

"while" {
    dump_tokens("WHILE   \t%-10s\t%d\t%d\t\t\n", yytext, yylineno, yycolumnno);
}

"break" {
    dump_tokens("BREAK   \t%-10s\t%d\t%d\t\t\n", yytext, yylineno, yycolumnno);
}

"continue" {
    dump_tokens("CONTINUE\t%-10s\t%d\t%d\t\t\n", yytext, yylineno, yycolumnno);
}

"return" {
    dump_tokens("RETURN  \t%-10s\t%d\t%d\t\t\n", yytext, yylineno, yycolumnno);
}

"==" {
    dump_tokens("EQUAL   \t%-10s\t%d\t%d\t\t\n", yytext, yylineno, yycolumnno);
}

"=" {
    dump_tokens("ASSIGN  \t%-10s\t%d\t%d\t\t\n", yytext, yylineno, yycolumnno);
}

"<=" {
    dump_tokens("LESSEQUAL\t%-10s\t%d\t%d\t\t\n", yytext, yylineno, yycolumnno);
}

">=" {
    dump_tokens("GREATEREQUAL\t%-10s\t%d\t%d\t\t\n", yytext, yylineno, yycolumnno);
}

"<" {
    dump_tokens("LESS    \t%-10s\t%d\t%d\t\t\n", yytext, yylineno, yycolumnno);
}

">" {
    dump_tokens("GREATER \t%-10s\t%d\t%d\t\t\n", yytext, yylineno, yycolumnno);
}

"+" {
    dump_tokens("ADD     \t%-10s\t%d\t%d\t\t\n", yytext, yylineno, yycolumnno);
}

"-" {
    dump_tokens("SUB     \t%-10s\t%d\t%d\t\t\n", yytext, yylineno, yycolumnno);
}

"*" {
    dump_tokens("MUL     \t%-10s\t%d\t%d\t\t\n", yytext, yylineno, yycolumnno);
}

"/" {
    dump_tokens("DIV     \t%-10s\t%d\t%d\t\t\n", yytext, yylineno, yycolumnno);
}

"%" {
    dump_tokens("MOD     \t%-10s\t%d\t%d\t\t\n", yytext, yylineno, yycolumnno);
}

"!" {
    dump_tokens("NOT     \t%-10s\t%d\t%d\t\t\n", yytext, yylineno, yycolumnno);
}

"||" {
    dump_tokens("OR      \t%-10s\t%d\t%d\t\t\n", yytext, yylineno, yycolumnno);
}

"&&" {
    dump_tokens("AND     \t%-10s\t%d\t%d\t\t\n", yytext, yylineno, yycolumnno);
}

";" {
    dump_tokens("SEMICOLON\t%-10s\t%d\t%d\t\t\n", yytext, yylineno, yycolumnno);
}

"(" {
    dump_tokens("LPAREN  \t%-10s\t%d\t%d\t\t\n", yytext, yylineno, yycolumnno);
}

")" {
    dump_tokens("RPAREN  \t%-10s\t%d\t%d\t\t\n", yytext, yylineno, yycolumnno);
}

"{" {
    m_stack.push();
    dump_tokens("LBRACE  \t%-10s\t%d\t%d\t\t\n", yytext, yylineno, yycolumnno);
}

"}" {
    m_stack.pop();
    dump_tokens("RBRACE  \t%-10s\t%d\t%d\t\t\n", yytext, yylineno, yycolumnno);
}

"[" {
    dump_tokens("LBRACKET\t%-10s\t%d\t%d\t\t\n", yytext, yylineno, yycolumnno);
}

"]" {
    dump_tokens("RBRACKET\t%-10s\t%d\t%d\t\t\n", yytext, yylineno, yycolumnno);
}

"," {
    dump_tokens("COMMA   \t%-10s\t%d\t%d\t\t\n", yytext, yylineno, yycolumnno);
}

{FLOAT} {
    //sscanf()会将参数str的字符串根据参数format字符串来转换并格式化数据,转换后的结果存于对应的参数内，与sprintf相对
    float num;
    sscanf(yytext, "%f", &num);
    dump_tokens("FLOAT   \t%-10s\t%d\t%d\t%f\t\n", yytext, yylineno, yycolumnno ,num);
}

{DECIMIAL} {
    int decimal;
    decimal = atoi(yytext);
    dump_tokens("DECIMAL \t%-10s\t%d\t%d\t%f\t\n", yytext, yylineno, yycolumnno ,decimal);
}

{OCTAL} {
    int num;
    sscanf(yytext, "%o", &num);  //将8进制转为10进制数
    dump_tokens("OCTAL   \t%-10s\t%d\t%d\t%f\t\n", yytext, yylineno, yycolumnno ,num);
}

{HEXADECIMAL} {
    int num;
    sscanf(yytext, "%x", &num);  //将16进制转为10进制数
    dump_tokens("HEXADECIMAL\t%-10s\t%d\t%d\t%f\t\n", yytext, yylineno, yycolumnno ,num);
}

{ID} {
    string str = yytext; //yytext = 词素
    node *p = m_stack.lookup(str);
    if_New = 0;
    dump_tokens("ID      \t%-10s\t%d\t%d\t%p\t\n", yytext, yylineno, yycolumnno, p);
}


{EOL} {
    yylineno++;
    yycolumnno = 0;
}

{WHITE} {
    yycolumnno+=1;
}

{LINECOMMENT} {
    dump_tokens("LINECOMMENT\t%-10s\t%d\t%d\t\t\n", yytext, yylineno, yycolumnno);
}   //处理注释，使用定义好的独占状态BLOCKCOMMENT

{BLOCKCOMMENTBEGIN} {
    BEGIN BLOCKCOMMENT;
    dump_tokens("BLOCKCOMMENTBEGIN\t%-10s\t%d\t%d\t\t\n", yytext, yylineno, yycolumnno);
}
<BLOCKCOMMENT>{BLOCKCOMMENTELEMENT} {
    yycolumnno++;
    // dump_tokens("BLOCKCOMMENTELEMENT\t%s\n", yytext);
}
<BLOCKCOMMENT>{BLOCKCOMMENTEND} {
    BEGIN INITIAL;
    dump_tokens("BLOCKCOMMENTEND\t%-10s\t%d\t%d\t\t\n", yytext, yylineno, yycolumnno);
} //使用宏BEGIN来切换状态，初始状态默认为INITIAL 

    /*  Your code here (lab3). */
%%
/* user code section */


char outfile[256] = "a.out";
dump_type_t dump_type = ASM;

int main(int argc, char *argv[])
{
    int opt;
    while ((opt = getopt(argc, argv, "to:")) != -1)
    {
        switch (opt)
        {
        case 'o':
            strcpy(outfile, optarg);
            break;
        case 't':
            dump_type = TOKENS;
            break;
        default:
            fprintf(stderr, "Usage: %s [-o outfile] infile\n", argv[0]);
            exit(EXIT_FAILURE);
            break;
        }
    }
    if (optind >= argc)
    {
        fprintf(stderr, "no input file\n");
        exit(EXIT_FAILURE);
    }
    if (!(yyin = fopen(argv[optind], "r")))
    {
        fprintf(stderr, "%s: No such file or directory\nno input file\n", argv[optind]);
        exit(EXIT_FAILURE);
    }
    if (!(yyout = fopen(outfile, "w")))
    {
        fprintf(stderr, "%s: fail to open output file\n", outfile);
        exit(EXIT_FAILURE);
    }

    // 初始化符号表（链表）
    init_idlist();

    yylex();
    return 0;
}
