Generate:
	@echo "generando codigo scanner"
	@flex mortal-kombat.l
	@echo "compilando codigo scanner"
	@gcc lex.yy.c -o mortal-kombat -ll

Execute:
	@echo "ejecutando codigo scanner with example.txt"
	@./mortal-kombat < example.txt

all: Generate Execute