//
// Created by 张航 on 2018/10/16.
//
#include <stdio.h>
#include <boost/program_options/option.hpp>
#include "cpp14_parser.hpp"
#include "cpp14_lexer.hpp"

int cpp14parse ();
extern int cpp14debug;
const char* get_token_name(int token);

void do_lex() {
	for(int c = cpp14lex(); c > 0; c= cpp14lex()) {
		printf("lex next token is %s, text=\"%s\"\n", get_token_name(c), cpp14text);
	}
}

int main(int argc, const char** argv)
{
	cpp14debug = 1;
	cpp14set_debug(1);

	if (argc > 1) {
		FILE* file = fopen(argv[1], "r");
		if (file == nullptr) {
			fprintf(stderr, "Cannot open file %s", argv[1]);
			return -1;
		}
		cpp14set_in(file);
	}
	return cpp14parse();
//	do_lex();
}
