import sys
import re
from enum import Enum

import ply.lex as lex
import ply.yacc as yacc

tokens = (
    'WORD', 'SWORD', 'ENDL', 'SPACE',
    'LPAREN', 'RPAREN',
    'LBRACKET', 'RBRACKET',
    'LBRACE', 'RBRACE',
    'COMMA', 'PERIOD', 'SEMI', 'COLON', 'DOLLAR',
)


def t_NEWLINE(t):
    r'\n+'
    t.lexer.lineno += t.value.count("\n")


t_WORD = r'[A-Za-z_][\w_]*'
t_SWORD = r'\\[A-Za-z_][\w_]*'

# Delimeters
t_LBRACKET = r'\['
t_RBRACKET = r'\]'
t_LBRACE = r'\{'
t_RBRACE = r'\}'
t_SPECIAL= r'\_|\&|\$|\#|@'
t_OPERATOR = r'[\+\-\=]'

t_COMMA = r','
t_PERIOD = r'\.'
t_SEMI = r';'
t_DOLLAR = r'\$'
t_COLON = r':'

t_INTEGER = r'[0-9]+'
t_PUNC = r'\.|\,|\!|\?|\:|\;|\''

class RuleLexer:
    def __init__(self, buffer: str):
        self._buffer = buffer
        self._current = 0
        self._capacity = len(buffer)

    @property
    def is_not_eof(self):
        return self._current < self._capacity

    @property
    def current(self):
        return self._buffer[self._current]

    @property
    def step(self):
        n = self._buffer[self._current]
        self._current += 1
        return n

    def recall(self):
        if self._current > 0:
            self._current -= 1

    def _parse_labeled_token(self):
        if self.current != '\\':
            return None

        (token, name) = self._parse_name()
        if name is None:
            raise Exception('cannot extract name from label')
        token_type = Token.NonTerminal
        if name == 'terminal':
            token_type = Token.Terminal
        elif name == 'textnormal':
            token_type = Token.TextNormal
        elif name == 'opt':
            token_type = Token.Optional

        value = None
        if self.is_not_eof:
            c = self.step
            if c == '{':
                all_char = []
                while c:
                    if c == '}':
                        break
                    elif c == '':
                        raise Exception('cannot extract } from label')
                    else:
                        all_char.append(c)
                    c = self.step
                value = ''.join(all_char)
            else:
                self.recall()
        return token_type, value

    def _parse_name(self):
        c = self.current
        if not (('a' <= c <= 'z') or ('A' <= c <= 'Z') or c == '-' or c == '_'):
            raise Exception(f'Invalid character {c} for name')
        all_char = [c]
        while self.is_not_eof:
            c = self.step
            if not (('a' <= c <= 'z') or ('A' <= c <= 'Z') or ('0' <= c <= '9') or c == '-' or c == '_'):
                break
            all_char.append(c)
        return Token.TextNormal, ''.join(all_char)

    def _parse_token(self):
        c = self.current
        if c == '\\':
            return self._parse_labeled_token()
        elif ('a' <= c <= 'z') or ('A' <= c <= 'Z') or c == '-' or c == '_':
            return self._parse_name
        elif c.isspace():
            return self._parse_space()
        elif c == '\n':
            return Token.EndOfLine, ''
        else:
            raise Exception(f'Unrecognized character \'{c}\'')

    def get_tokens(self):
        tokens = []
        while self.is_not_eof:
            token, value = self._parse_token()
            print(token, value, file=sys.stderr)
            tokens.append((token, value))



class Token(Enum):
    Terminal = 0
    NonTerminal = 1
    TextNormal = 2
    Break = 3
    EndOfLine = 4
    Space = 5
    Optional = 6


class GrammarParser:
    re_section_str = r'\\gramSec\[([\w\.\-]+)\]\{([\w\.\-\s]+)\}\n'
    re_begin_bnf_str = r'\\begin\{(bnf(\w*))\}\n'
    re_end_bnf_str = r'\\end\{(bnf(\w*))\}\n'
    re_non_term_def_str = r'\\nontermdef\{([\w\.\-]+)\}( \\textnormal\{one of\})?\\br\n'

    def parse_section(self, out_file, match):
        print(match.group(1), ',', match.group(2), file=sys.stderr)
        section_name = match.group(1)
        section_title = match.group(2)
        print(f'/* {section_name} {section_title} */', file=out_file)
        return

    def parse_begin_bnf(self, out_file, match):
        # print('begin', match.group(1))
        return

    def parse_end_bnf(self, out_file, match):
        # print('end', match.group(1))
        return

    def parse_non_term_def(self, out_file, match):
        self.non_term_def = re.sub('-', '_', match.group(1))
        print('Definition:', self.non_term_def, file=sys.stderr)
        self.max_def_length = max(len(self.non_term_def), self.max_def_length)
        self.non_term_def_table[self.non_term_def] = []
        return

    def parse_rule(self, out_file, match):
        lexer = RuleLexer(match)
        tokens = lexer.get_tokens()

    pattern_hanlders = (
        (re.compile(re_section_str), parse_section),
        (re.compile(re_begin_bnf_str), parse_begin_bnf),
        (re.compile(re_end_bnf_str), parse_end_bnf),
        (re.compile(re_non_term_def_str), parse_non_term_def)
    )

    def __init__(self):
        self.non_term_def = None
        self.max_def_length = 0
        self.non_term_def_table = {}

    def parse_line(self, out_file, line):
        for pattern_hanlder in self.pattern_hanlders:
            pattern = pattern_hanlder[0]
            handler = pattern_hanlder[1]
            match = pattern.match(line)
            if match:
                handler(self, out_file, match)
                break
        else:
            self.parse_rule(out_file, line)

    def parse_file(self, out_file, pathname):
        file = open(pathname)
        for line in file:
            if line.startswith('\n'):
                continue
            self.parse_line(out_file, line)
        print('self.max_def_length=', self.max_def_length, file=sys.stderr)


if __name__ == '__main__':
    parser = GrammarParser()
    output = open('cpp14.y', 'w')
    parser.parse_file(out_file=output, pathname=sys.argv[1])
