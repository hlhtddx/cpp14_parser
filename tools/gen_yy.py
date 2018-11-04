import sys
import re

file = open(sys.argv[1])

re_section = r'\\gramSec\[([\w\.\-]+)\]\{([\w\.\-\s]+)\}'
re_begin_bnf = r'\\begin\{bnf\}'
re_end_bnf = r'\\end\{bnf\}'
re_non_term_def = r'\\nontermdef\{([\w\.\-]+)\}\\br'


for line in file:
    if line.startswith('\n'):
        continue
    if line.startswith('\gramSec'):
        parse_title(line)
    sys.stderr.write(line)
