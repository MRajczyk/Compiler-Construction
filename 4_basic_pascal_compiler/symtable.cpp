#include "global.hpp"

std::vector<symbol_t> symtable;
int temp_count = 0;
int curr_address = 0;

void init_symtable() {
  symbol_t read;
  read.name = "read";
  read.token = PROCEDURE;
  read.type = NONE;

  symbol_t write;
  write.name = "write";
  write.token = PROCEDURE;
  write.type = NONE;

  symbol_t program;
  program.name = "program";
  program.token = LABEL;
  program.type = NONE;

  symtable.push_back(read);
  symtable.push_back(write);
  symtable.push_back(program);
}

int find_id(const std::string name) {
  for (int p = symtable.size() - 1; p > 0; p--) {
    if (symtable[p].name == name) {
      return p;
    }
  }

  return -1;
}

int get_symbol_size(symbol_t symbol) {
  if (symbol.token == VAR) {
    if (symbol.type == REAL) {
      return 8;
    }
    else if (symbol.type == INTEGER) {
      return 4;
    }
  }

  return 0;
}

int get_address(std::string name) {
  int address = 0;
  for (auto sym : symtable) {
    if (sym.name != name) {
      address += get_symbol_size(sym);
    }
  }

  return address;
}

int insert_symbol(symbol_t sym) {
  symtable.push_back(sym);
  return symtable.size() - 1;
}

int insert(std::string name, int token, int type) {
  int look = find_id(name);
  if (look >= 0) {
    return look;
  }
  symbol_t sym;
  sym.name = name;
  sym.token = token;
  sym.type = type;
  sym.address = curr_address;
  curr_address += get_symbol_size(sym);

  return insert_symbol(sym);
}

int new_temp(int type) {
  symbol_t t;
  t.name = "$t" + std::to_string(temp_count);
  t.type = type;
  t.token = VAR;
  t.address = 0;
  int index = insert_symbol(t);
  symtable[index].address = get_address(t.name);
  ++temp_count;
  return index;
}

int new_num(std::string name, int type) {
  return insert(name, NUM, type);
}