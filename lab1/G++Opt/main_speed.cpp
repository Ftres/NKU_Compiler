#include<iostream>
using namespace std;

int main()
{
	int i, n, f;
	cin>>n;
	clock_t start_time=clock();
	i = 2;
	f = 1;
	while(i<=n)
	{
		f = f*i;
		i = i+1;
	}
	cout<<f<<endl;
	clock_t end_time=clock();
	cout << "The run time is: " <<(double)(end_time - start_time) / CLOCKS_PER_SEC << "s" << endl;
}

