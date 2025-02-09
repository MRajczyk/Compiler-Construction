#include "global.hpp"
#include <iostream>

std::vector<symbol_t> symtable;
int temp_count = 0;
int label_count = 1;
int curr_address = 0;

void init_symtable() {
  symbol_t read;
  read.name = "read";
  read.token = PROCEDURE;
  read.type = NONE;
  read.address = 0;

  symbol_t write;
  write.name = "write";
  write.token = PROCEDURE;
  write.type = NONE;
  write.address = 0;

  symbol_t program;
  program.name = "lab0";
  program.token = LABEL;
  program.type = NONE;
  program.address = 0;

  symbol_t input;
  input.name = "input";
  input.token = ID;
  input.type = NONE;
  input.address = 0;

  symbol_t output;
  output.name = "output";
  output.token = ID;
  output.type = NONE;
  output.address = 0;

  symtable.push_back(read);
  symtable.push_back(write);
  symtable.push_back(program);
  symtable.push_back(input);
  symtable.push_back(output);
}

int find_num(int num) {
  for (int p = symtable.size() - 1; p > 0; p--) {
    if (symtable[p].name == std::to_string(num)) {
      return p;
    }
  }

  return -1;
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
  else if(symbol.token == ARRAY) {
    int element_size = symbol.type == REAL ? 4 : 8;
    return element_size * (symbol.array_info.end_idx - symbol.array_info.start_idx + 1);
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

int get_symbol_type(int v1, varmode varmode1) {
  if(varmode1 == ADDRESS) {
    return INTEGER;
  }

	return symtable[v1].type;
}

int get_result_type(int v1, int  v2) {
  if (symtable[v1].type == REAL || symtable[v1].type == REAL) {
		return REAL;
	} 
  else {
		return INTEGER;
	}
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
  int index = insert_symbol(t);
  symtable[index].address = get_address(t.name);
  ++temp_count;
  return index;
}

int new_num(std::string name, int type) {
  return insert(name, NUM, type);
}

int new_label() {
  return insert(std::string("lab") + std::to_string(label_count++), LABEL, NONE);
}

void print_symtable() {
  std::string idx_head = std::string("idx");
  std::string name_head = std::string("name");
  std::string token_head = std::string("token");
  std::string type_head = std::string("type");
  std::string address_head = std::string("address");

  size_t longest_idx_len = idx_head.length() > std::to_string(symtable.size()).length() ? idx_head.length() : std::to_string(symtable.size()).length();
  size_t longest_name_len = name_head.length();
  size_t longest_token_len = token_head.length();
  size_t longest_type_len = type_head.length();
  size_t longest_address_len = address_head.length();

  for (auto symbol : symtable) {
    if (symbol.name.length() > longest_name_len) {
      longest_name_len = symbol.name.length();
    }
    std::string token = std::string(token_name(symbol.token));
    if (token.length() > longest_token_len) {
      longest_token_len = token.length();
    }
    std::string type = std::string(token_name(symbol.type));
    if (type.length() > longest_type_len) {
      longest_type_len = type.length();
    }
    std::string address = std::string(std::to_string(symbol.address));
    if (address.length() > longest_address_len) {
      longest_address_len = address.length();
    }
  }

  std::string separator = std::string(" | ");

  std::cout << std::string(longest_idx_len - idx_head.length(), ' ').append(idx_head).append(separator)
    .append(std::string(longest_name_len - name_head.length(), ' ')).append(name_head).append(separator)
    .append(std::string(longest_token_len - token_head.length(), ' ')).append(token_head).append(separator)
    .append(std::string(longest_address_len - address_head.length(), ' ')).append(address_head).append(separator)
    .append(std::string(longest_type_len - type_head.length(), ' ')).append(type_head).append("\n")
    .append(std::string(longest_idx_len + longest_name_len + longest_token_len + longest_type_len + longest_address_len + separator.length() * 4, '-')).append("\n");

  int i = 0;
  for (auto symbol : symtable) {
    if(symbol.token == ARRAY) {
      std::cout << std::string(longest_idx_len - std::to_string(i).length(), ' ').append(std::to_string(i)).append(separator)
      .append(std::string(longest_name_len - symbol.name.length(), ' ')).append(symbol.name).append(separator)
      .append(std::string(longest_token_len - std::string(token_name(symbol.token)).length(), ' ')).append(token_name(symbol.token)).append(separator)
      .append(std::string(longest_address_len - std::to_string(symbol.address).length(), ' ')).append(std::to_string(symbol.address)).append(separator)
      .append(std::string(longest_type_len - std::string(token_name(symbol.type)).length(), ' ')).append(token_name(symbol.type))
      .append(" ").append(std::to_string(symbol.array_info.start_idx)).append("..").append(std::to_string(symbol.array_info.end_idx)).append(" ").append("of").append(" ").append(token_name(symbol.type)).append("\n");
      ++i;
    }
    else {
      std::cout << std::string(longest_idx_len - std::to_string(i).length(), ' ').append(std::to_string(i)).append(separator)
      .append(std::string(longest_name_len - symbol.name.length(), ' ')).append(symbol.name).append(separator)
      .append(std::string(longest_token_len - std::string(token_name(symbol.token)).length(), ' ')).append(token_name(symbol.token)).append(separator)
      .append(std::string(longest_address_len - std::to_string(symbol.address).length(), ' ')).append(std::to_string(symbol.address)).append(separator)
      .append(std::string(longest_type_len - std::string(token_name(symbol.type)).length(), ' ')).append(token_name(symbol.type)).append("\n");
      ++i;
    }
  }
}
