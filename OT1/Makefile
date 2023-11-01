.PHONY: test, cp, clean
test:
	g++ Reg2NFA.cpp -o Reg2NFA.out
	./Reg2NFA.out
	./Reg2NFA.out > output.txt
cp:
	g++ Reg2NFA_cp.cpp -o Reg2NFA_cp.out
	./Reg2NFA_cp.out > output_cp.txt
new:
	g++ Reg2NFA_new.cpp -o Reg2NFA_new.out
	./Reg2NFA_new.out > output_new.txt
clean:
	rm -fr *.out *.txt
