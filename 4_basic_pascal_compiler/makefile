CC = g++
OBJDIR = obj

all: comp

comp : $(OBJDIR)/main.o $(OBJDIR)/emitter.o $(OBJDIR)/init.o $(OBJDIR)/operations.o $(OBJDIR)/lexer.o $(OBJDIR)/parser.o $(OBJDIR)/symtable.o
	$(CC) -o comp $(OBJDIR)/main.o $(OBJDIR)/emitter.o $(OBJDIR)/init.o $(OBJDIR)/operations.o $(OBJDIR)/lexer.o $(OBJDIR)/parser.o $(OBJDIR)/symtable.o

$(OBJDIR)/main.o : main.cpp global.hpp parser.h | $(OBJDIR)
	$(CC) -c main.cpp -o $(OBJDIR)/main.o

$(OBJDIR)/emitter.o : emitter.cpp global.hpp parser.h | $(OBJDIR)
	$(CC) -c emitter.cpp -o $(OBJDIR)/emitter.o

$(OBJDIR)/init.o : init.cpp | $(OBJDIR)
	$(CC) -c init.cpp -o $(OBJDIR)/init.o
	
$(OBJDIR)/operations.o : operations.cpp | $(OBJDIR)
	$(CC) -c operations.cpp -o $(OBJDIR)/operations.o

$(OBJDIR)/symtable.o : symtable.cpp global.hpp | $(OBJDIR)
	$(CC) -c symtable.cpp -o $(OBJDIR)/symtable.o

$(OBJDIR)/lexer.o : lexer.c global.hpp parser.h | $(OBJDIR)
	$(CC) -c lexer.c -o $(OBJDIR)/lexer.o

$(OBJDIR)/parser.o : parser.c global.hpp parser.h | $(OBJDIR)
	$(CC) -c parser.c -o $(OBJDIR)/parser.o

lexer.c : lexer.lex
	flex -o lexer.c lexer.lex

parser.c parser.h : parser.y
	bison -d -v -t -o parser.c parser.y

$(OBJDIR):
	mkdir -p $(OBJDIR)

.PHONY: clean
clean :
	rm -rf comp $(OBJDIR)
	rm -f lexer.c
	rm -f parser.c
	rm -f parser.h
	rm -f parser.output
