CC = gcc
OBJDIR = obj

comp : $(OBJDIR)/main.o $(OBJDIR)/error.o $(OBJDIR)/emitter.o $(OBJDIR)/init.o $(OBJDIR)/lexer.o $(OBJDIR)/parser.o $(OBJDIR)/symbol.o
	$(CC) -o comp $(OBJDIR)/main.o $(OBJDIR)/error.o $(OBJDIR)/emitter.o $(OBJDIR)/init.o $(OBJDIR)/lexer.o $(OBJDIR)/parser.o $(OBJDIR)/symbol.o

$(OBJDIR)/main.o : main.c global.h | $(OBJDIR)
	$(CC) -c main.c -o $(OBJDIR)/main.o

$(OBJDIR)/emitter.o : emitter.c global.h | $(OBJDIR)
	$(CC) -c emitter.c -o $(OBJDIR)/emitter.o

$(OBJDIR)/error.o : error.c global.h | $(OBJDIR)
	$(CC) -c error.c -o $(OBJDIR)/error.o

$(OBJDIR)/init.o : init.c global.h | $(OBJDIR)
	$(CC) -c init.c -o $(OBJDIR)/init.o

$(OBJDIR)/lexer.o : lexer.c global.h | $(OBJDIR)
	$(CC) -c lexer.c -o $(OBJDIR)/lexer.o

$(OBJDIR)/parser.o : parser.c global.h | $(OBJDIR)
	$(CC) -c parser.c -o $(OBJDIR)/parser.o

$(OBJDIR)/symbol.o : symbol.c global.h | $(OBJDIR)
	$(CC) -c symbol.c -o $(OBJDIR)/symbol.o

$(OBJDIR):
	mkdir -p $(OBJDIR)

.PHONY: clean
clean :
	rm -rf comp $(OBJDIR)
