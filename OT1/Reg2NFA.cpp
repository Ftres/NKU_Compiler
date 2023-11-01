#include <iostream>
#include <stack>
#include <set>
using namespace std;

#define MaxNumOfState 100

struct NFAState
{
    int Index_State;               // NFA状态号
    char Symbol_Trans;             // 弧上的值
    int Index_TransToState;        // 转移到的状态号
    set<int> Set_TransWithEpsilon; // 通过ε转移到的状态号集合
};

struct NFA
{
    NFAState *head; // NFA的头指针
    NFAState *tail; // NFA的尾指针
};

NFAState NFA_States[MaxNumOfState]; // NFA状态数组
int nfaStateNum = 0;                // NFA状态总数

// 从状态n1到状态n2添加一条弧，弧上的值为ch
void add(NFAState *state1, NFAState *state2, char x)
{
    state1->Symbol_Trans = x;
    state1->Index_TransToState = state2->Index_State;
}

// 从状态n1到状态n2添加一条弧，弧上的值为ε
void add(NFAState *n1, NFAState *n2)
{
    n1->Set_TransWithEpsilon.insert(n2->Index_State);
}

// 新建一个NFA（即从NFA状态数组中取出两个状态）
NFA createNFA(int sum)
{
    NFA nfa;
    nfa.head = &NFA_States[sum];
    nfa.tail = &NFA_States[sum + 1];
    return nfa;
}

// 对字符串s进行预处理，在第一位是操作数、‘*’或‘)’且第二位是操作数或‘(’之间加入连接符‘&’
void RegularExpr_Add_and(string &s)
{
    int i = 0, length = s.size();
    while (i < length)
    {
        if ((s[i] >= 'a' && s[i] <= 'z') || (s[i] == '*') || (s[i] == ')'))
        {
            if ((s[i + 1] >= 'a' && s[i + 1] <= 'z') || s[i + 1] == '(')
            {
                s += ' ';
                for (int j = s.size() - 1; j > i + 1; j--)
                {
                    s[j] = s[j - 1];
                }
                s[i + 1] = '&';
                length++;
            }
        }
        i++;
    }
}

// 中缀转后缀时用到的优先级比较
int Priority_Operator(char ch)
{
    if (ch == '*')
    {
        return 3;
    }
    if (ch == '&')
    {
        return 2;
    }
    if (ch == '|')
    {
        return 1;
    }
    if (ch == '(')
    {
        return 0;
    }
}

// 中缀表达式转后缀表达式
string infix2Postfix(string Infix_Expression)
{
    RegularExpr_Add_and(Infix_Expression);

    string Postfix_Expression;
    stack<char> Stack_Operator;

    for (int i = 0; i < Infix_Expression.size(); i++)
    {
        char c = Infix_Expression[i];

        if (isalpha(c))
        {
            Postfix_Expression += c;
        }
        else if (c == '(')
        {
            Stack_Operator.push(c);
        }
        else if (c == ')')
        {
            while (!Stack_Operator.empty() && Stack_Operator.top() != '(')
            {
                Postfix_Expression += Stack_Operator.top();
                Stack_Operator.pop();
            }
            if (!Stack_Operator.empty() && Stack_Operator.top() == '(')
            {
                Stack_Operator.pop();
            }
        }
        else
        {
            while (!Stack_Operator.empty() && Priority_Operator(Stack_Operator.top()) >= Priority_Operator(c))
            {
                Postfix_Expression += Stack_Operator.top();
                Stack_Operator.pop();
            }
            Stack_Operator.push(c);
        }
    }

    while (!Stack_Operator.empty())
    {
        Postfix_Expression += Stack_Operator.top();
        Stack_Operator.pop();
    }

    return Postfix_Expression;
}

// 创建基本NFA
NFA createBasicNFA(char x)
{
    NFA n = createNFA(nfaStateNum);
    nfaStateNum += 2;
    add(n.head, n.tail, x);
    return n;
}

// 创建闭包
NFA createClosureNFA(NFA nfa_2)
{
    NFA nfa_return = createNFA(nfaStateNum);
    nfaStateNum += 2;
    add(nfa_2.tail, nfa_return.head);
    add(nfa_2.tail, nfa_return.tail);
    add(nfa_return.head, nfa_2.head);
    add(nfa_return.head, nfa_return.tail);
    return nfa_return;
}
// 创建或
NFA createOrNFA(NFA nfa_1, NFA nfa_2)
{
    NFA nfa_return = createNFA(nfaStateNum);
    nfaStateNum += 2;
    add(nfa_return.head, nfa_1.head);
    add(nfa_return.head, nfa_2.head);
    add(nfa_1.tail, nfa_return.tail);
    add(nfa_2.tail, nfa_return.tail);
    return nfa_return;
}

// 创建连接
NFA createConcatenationNFA(NFA nfa_1, NFA nfa_2)
{
    NFA nfa_concatenation;
    add(nfa_1.tail, nfa_2.head);
    nfa_concatenation.head = nfa_1.head;
    nfa_concatenation.tail = nfa_2.tail;
    return nfa_concatenation;
}

// 后缀表达式转NFA
NFA Postfix2NFA(string RegularExpr_Postfix)
{
    stack<NFA> Stack_NFA;
    int nfaStateNum = 0;

    for (int i = 0; i < RegularExpr_Postfix.size(); i++)
    {
        char c = RegularExpr_Postfix[i];

        if (isalpha(c))
        {
            NFA n = createBasicNFA(c);
            Stack_NFA.push(n);
            nfaStateNum += 2;
        }
        else if (c == '*')
        {
            NFA n1 = Stack_NFA.top();
            Stack_NFA.pop();
            NFA n = createClosureNFA(n1);
            Stack_NFA.push(n);
        }
        else if (c == '|')
        {
            NFA n2 = Stack_NFA.top();
            Stack_NFA.pop();
            NFA n1 = Stack_NFA.top();
            Stack_NFA.pop();
            NFA n = createOrNFA(n1, n2);
            Stack_NFA.push(n);
        }
        else if (c == '&')
        {
            NFA n2 = Stack_NFA.top();
            Stack_NFA.pop();
            NFA n1 = Stack_NFA.top();
            Stack_NFA.pop();
            NFA n = createConcatenationNFA(n1, n2);
            Stack_NFA.push(n);
        }
    }

    return Stack_NFA.top();
}

// 输出NFA
void PrintNFA(NFA nfa)
{
    cout << "------------------------------------NFA--------------------------------------" << endl;
    cout << "Total Num Of NFA States: " << nfaStateNum << endl;
    cout << "Start State: " << nfa.head->Index_State << endl;
    cout << "End State: " << nfa.tail->Index_State << endl
         << endl;

    for (int i = 0; i < nfaStateNum; i++)
    {
        if (NFA_States[i].Symbol_Trans != '#')
        {
            cout << NFA_States[i].Index_State << "---'" << NFA_States[i].Symbol_Trans << "'--->" << NFA_States[i].Index_TransToState << '\t';
        }
        set<int>::iterator it;
        for (it = NFA_States[i].Set_TransWithEpsilon.begin(); it != NFA_States[i].Set_TransWithEpsilon.end(); it++)
        {
            cout << NFA_States[i].Index_State << "---'"
                 << " "
                 << "'--->" << *it << '\t';
        }
        cout << endl;
    }
    cout << "-----------------------------------------------------------------------------" << endl;
}

int main()
{
    // string RegularExpr_test = "(a|b)*abb";
    string RegularExpr_test;
    cin>>RegularExpr_test;
    RegularExpr_test = infix2Postfix(RegularExpr_test);

    int i, j;
    for (i = 0; i < MaxNumOfState; i++)
    {
        NFA_States[i].Index_State = i;
        NFA_States[i].Symbol_Trans = '#';
        NFA_States[i].Index_TransToState = -1;
    }

    NFA n = Postfix2NFA(RegularExpr_test);
    PrintNFA(n);

    return 0;
}
