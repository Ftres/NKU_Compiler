.PHONY:test1, test2, clean
test1:
	bison -d expr.y -o expr.c
	gcc expr.c -o expr.o
	./expr.o
test2:
	bison -d expr2.y -o expr2.c
	gcc expr2.c -o expr2.o
	./expr2.o
test3:
	bison -d expr3.y -o expr3.c
	gcc expr3.c -o expr3.o
	./expr3.o
test11:
	bison -d expr.y -o expr.c
	gcc expr.c -o expr.o
	./expr.o < test.txt
test22:
	bison -d expr2.y -o expr2.c
	gcc expr2.c -o expr2.o
	./expr2.o < test.txt
test33:
	bison -d expr3.y -o expr3.c
	gcc expr3.c -o expr3.o
	./expr3.o < test2.txt
clean:
	rm -fr *.o *.c *.h

