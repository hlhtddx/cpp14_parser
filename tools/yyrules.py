import json
import sys
from enum import IntEnum


class Rules:
    def __init__(self):
        self.down_links = {}
        self.up_links = {}
        self.references = set()

    def load(self, pathname):
        file = open(pathname, 'r')
        grammar = json.load(file)
        for rule in grammar['grammar']:
            name = rule[0]
            content = tuple(rule[1:])
            if name not in self.down_links:
                self.down_links[name] = []
            self.down_links[name].append(content)
            self.set_up_link(name, content)

    def set_up_link(self, name, content):
        for element in content:
            if element not in self.up_links:
                self.up_links[element] = []
            self.up_links[element].append(name)
            self.references.add((name, element))


class Commands:
    def __init__(self):
        self._commands = {}
        self.rules = Rules()

    def add_commands(self, name, func):
        self._commands[name] = func

    def run_command(self, name, args):
        if name in self._commands:
            func = self._commands[name]
            return func(self, args)
        return False


def cmd_exit(rules, params):
    exit(0)


def cmd_load(commands, params):
    json_name = params[0]
    print('Load JSON file with rules', json_name)
    commands.rules.load(json_name)


def cmd_get_rule(commands, params):
    rules = commands.rules
    rule_name = params[0]
    print('Get rule for name', rule_name)
    if rule_name in rules.down_links:
        for rule in rules.down_links[rule_name]:
            for element in rule:
                sys.stdout.write(element + ' ')
            print()
    return True


def cmd_tree_from_rule(commands, params):
    print(params)
    return True


class GenerateDotDirection(IntEnum):
    up = 0
    down = 1


def _traverse_for_children_internal(rules: Rules, start: str, rule_defs, ref_table):
    rule_defs.add(start)
    if start not in rules.down_links:
        return
    nodes = rules.down_links[start]
    for node in nodes:
        for element in node:
            ref_table.add((start, element))
            if element not in rule_defs:
                _traverse_for_children_internal(rules, element, rule_defs, ref_table)
    return rule_defs, ref_table


def _traverse_for_children(rules: Rules, start: str):
    if start not in rules.down_links:
        print(start, "is not a valid node")
        return [], []
    rule_defs = set()
    ref_table = set()
    _traverse_for_children_internal(rules, start, rule_defs, ref_table)
    return rule_defs, ref_table


def _traverse_for_parent_internal(rules: Rules, start: str, rule_defs, ref_table):
    rule_defs.add(start)
    if start not in rules.down_links:
        return
    if start not in rules.up_links:
        print(start, "is not a valid node")
        return [], []
    nodes = rules.up_links[start]
    for node in nodes:
        for element in node:
            ref_table.add((element, start))
            if element not in rule_defs:
                _traverse_for_parent_internal(rules, element, rule_defs, ref_table)
    return rule_defs, ref_table


def _traverse_for_parent(rules: Rules, start: str):
    if start not in rules.down_links:
        print(start, "is not a valid node")
        return None, None
    rule_defs = set()
    ref_table = set()
    _traverse_for_children_internal(rules, start, rule_defs, ref_table)
    return rule_defs, ref_table


def _generate_dot(rules: Rules, params):
    filename = params[0]
    start = params[1] if len(params) > 1 else None
    direction = GenerateDotDirection.up if (len(params) > 2 and params[2] == 'up') else GenerateDotDirection.down

    if start is None:
        rule_def, references = rules.down_links.keys(), rules.references
    elif direction == GenerateDotDirection.down:
        rule_def, references = _traverse_for_children(rules, start)
    else:
        rule_def, references = _traverse_for_parent(rules, start)

    dot_file = open(filename, 'w')
    dot_file.write('digraph {\n')
    dot_file.write('\tnode [fontname = courier, shape = box, colorscheme = paired6]\n')
    dot_file.write('\tedge [fontname = courier]\n')

    for rule in rule_def:
        dot_file.write(f'\t\"{rule}\" [label=\"{rule}\"]\n')

    for reference in references:
        dot_file.write(f'\t\"{reference[0]}\" -> \"{reference[1]}\" [style=solid]\n')

    dot_file.write('}\n')
    dot_file.close()


def cmd_dot(commands, params):
    _generate_dot(commands.rules, params)
    return True


def parse_commands(argv):
    commands = Commands()
    commands.add_commands('load', cmd_load)
    commands.add_commands('exit', cmd_exit)
    commands.add_commands('rule', cmd_get_rule)
    commands.add_commands('tree', cmd_tree_from_rule)
    commands.add_commands('dot', cmd_dot)
    if len(argv) > 0:
        commands.run_command('load', argv)

    for line in sys.stdin:
        args = line.split()
        if len(args) < 1:
            print('Empty command. skip it.')
        else:
            commands.run_command(args[0], args[1:])


if __name__ == '__main__':
    if len(sys.argv) < 2:
        raise Exception("target json file is not specified!")

    parse_commands(sys.argv[1:])
