//
// Created by 张航 on 2018/10/16.
//
#include <stdio.h>
#include "cpp14_parser.hpp"
#include "cpp14_lexer.hpp"

int cpp14parse ();
extern int cpp14debug;

int main(int argc, const char** argv)
{
	cpp14debug = 1;
	if (argc > 1) {
		FILE* file = fopen(argv[1], "r");
		if (file == NULL) {
			fprintf(stderr, "Cannot open file %s", argv[1]);
			return -1;
		}
		cpp14set_in(file);
	}
	return cpp14parse();
}
