import sys
import re
import io
from enum import Enum


class RuleReader:
    def __init__(self, buffer: str):
        self.buffer = buffer
        self.current = 0
        self.capacity = len(buffer)

    def has_next(self):
        return self.current < self.capacity - 1

    def get_next(self):
        n = self.buffer[self.current]
        self.current += 1
        return n

    def untake(self):
        if self.current > 0:
            self.current -= 1


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

    def parse_labeled_token(self, stream):
        token, name = self.parse_name(stream)
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
        if stream.has_next():
            c = stream.get_next()
            if c == '{':
                all_char = []
                while c:
                    if c == '}':
                        break
                    elif c == '':
                        raise Exception('cannot extract } from label')
                    else:
                        all_char.append(c)
                    c = stream.get_next()
                value = ''.join(all_char)
            else:
                stream.untake()
        return token_type, value

    def parse_name(self, stream):
        c = stream.get_next()
        if not ((c >= 'a' and c <= 'z') or (c >= 'A' and c <= 'Z') or c == '-' or c == '_'):
            raise Exception(f'Invalid character {c} for name')
        all_char = [c]
        while stream.has_next():
            c = stream.get_next()
            if not ((c >= 'a' and c <= 'z') or (c >= 'A' and c <= 'Z') or c == '-' or c == '_'):
                break;
            all_char.append(c)
        return Token.TextNormal, ''.join(all_char)

    def parse_token(self, stream):
        c = stream.get_next()
        if c == '\\':
            return self.parse_labeled_token(stream)
        elif (c >= 'a' and c <= 'z') or (c >= 'A' and c <= 'Z') or c == '-' or c == '_':
            stream.untake()
            return self.parse_name(stream)
        elif c.isspace():
            return Token.Space, ''
        elif c == '\n':
            return Token.EndOfLine, ''
        else:
            raise Exception(f'Unrecognized character \'{c}\'')

    def parse_rule(self, out_file, match):
        stream = RuleReader(match)
        while stream.has_next():
            token, value = self.parse_token(stream)
            print(token, value, file=sys.stderr)

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
