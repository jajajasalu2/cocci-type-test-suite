@ initialize:python @
@@

import re
import logging
from collections import defaultdict

logging.basicConfig()
logger = logging.getLogger("gen_cocci")
logger.setLevel(logging.INFO)

rule_count = 0
rules = []
declarations = defaultdict(list)
typedef_regex = re.compile(r"\b[a-zA-Z0-9_]*?_t\b")
append_pos = re.compile(r"\bcocci_id\b")

filter_res = [
    re.compile(r"\]\s*__[a-zA-Z0-9_]*\s*;$"),
    re.compile(r"\}\s*__[a-zA-Z0-9_]*\s*;$"),
    re.compile(r".*__[a-zA-Z0-9_]*\s*(\*)?\s*cocci_id"),
    re.compile(r"__typeof__"),
    re.compile(r"__attribute__"),
    re.compile(r" , [a-zA-Z0-9_]*_t"),
    //re.compile(r"[a-zA-Z0-9_]*_t\s*cocci_id\s*\("),
    re.compile(r"#define"),
    re.compile(r"#ifdef")
]

known_typedefs = [
    "u_char", "u_short", "u_int", "u_long",
    "u8", "u16", "u32", "u64",
    "s8", "s16", "s32", "s64",
    "__u8", "__u16", "__u32", "__u64",
    "bool", "acpi_handle", "acpi_status", "FILE", "DIR"
]

known_typedef_regexes = dict()
for tdef in known_typedefs:
    known_typedef_regexes[tdef] = re.compile(r"\b{t}\b".format(t=tdef))

not_cocci_typedefs = [
    "size_t", "ssize_t", "ptrdiff_t"
]

logger.info("Starting semantic patch generation")
print("@ initialize:python @")
print("@@")
print("from collections import defaultdict")
print("rule_matches = defaultdict(dict)")
print("")


@ r0 @
declaration D;
position P;
@@

D@P


@ script:python r1 @
d << r0.D;
p << r0.P;
@@


filter = False
for regex in filter_res:
    if regex.search(d):
        filter = True
        logger.info("Skipped %s on line %s", d, p[0].line)
        break
if not filter:
    d = append_pos.sub("cocci_id@p", d)

    if d not in declarations:
        declarations[d] = {"lines": [], "typedefs": []}
        logger.info("Added %s on line %s", d, p[0].line)
    declarations[d]["lines"].append(p[0].line)

    if p[0].line != p[0].line_end:
        declarations[d]["lines"].append(p[0].line_end)
        logger.info("Added line_end %s for declaration %s", d, p[0].line)

    for tdef in known_typedef_regexes:
        if known_typedef_regexes[tdef].search(d):
            logger.info("FOUND TYPEDEF %s", tdef)
            declarations[d]["typedefs"].append(tdef)
    other_typedefs = set(typedef_regex.findall(d))
    for tdef in other_typedefs:
        if tdef not in not_cocci_typedefs:
            logger.info("FOUND TYPEDEF %s", tdef)
            declarations[d]["typedefs"].append(tdef)


@ finalize:python @
@@

for d in declarations:
    rule_count += 1
    rules.append(rule_count)
    // Print the declaration to be matched and corresponding python binding
    print("@ r{rule_no} @".format(rule_no=str(rule_count)))
    print("symbol cocci_id;")
    print("position p;")
    if declarations[d]["typedefs"]:
        print("typedef {tdefs};".format(tdefs=",".join(declarations[d]["typedefs"])))
    print("@@")
    print("{decl}".format(decl=d))
    print("")
    print("@ script:python depends on r{rule_no} @".format(rule_no=str(rule_count)))
    print("p << r{rule_no}.p;".format(rule_no=str(rule_count)))
    print("@@")
    print("")
    print("if {rule_no} not in rule_matches:".format(rule_no=str(rule_count)))
    print("    rule_matches[%s] = {'lines': [], 'correct_lines': [], 'other_lines': []}" % str(rule_count))
    print("if p[0].line in {lines}:".format(lines=declarations[d]["lines"]))
    print("    rule_matches[{rule_no}]['correct_lines'].append(p[0].line)".format(rule_no=str(rule_count)))
    print("else:")
    print("    rule_matches[{rule_no}]['other_lines'].append(p[0].line)".format(rule_no=str(rule_count)))
    print("")

print("@ finalize:python @")
print("@@")
print("rules = {rules}".format(rules=str(rules)))
print("for i in rules:")
print("    if i not in rule_matches:")
print("        print(\"FAILED %s: NO MATCHES\" % (str(i)))")
print("        continue")
print("    elif rule_matches[i]['correct_lines']:")
print("        if rule_matches[i]['other_lines']:")
print("            print(\"PASSED %s: CORRECT MATCHES: %s INCORRECT MATCHES: %s\" % (str(i), str(rule_matches[i]['correct_lines']), str(rule_matches[i]['other_lines'])))")
print("        else:")
print("            print(\"PASSED %s: CORRECT MATCHES: %s\" % (str(i), str(rule_matches[i]['correct_lines'])))")
print("    elif rule_matches[i]['other_lines']:")
print("        print(\"FAILED %s: INCORRECT MATCHES: %s\" % (str(i), str(rule_matches[i]['other_lines'])))")
print("    else:")
print("        print(\"UNDEFINED %s\" % str(i))")
print("")
print("print(\"Total Number of cases: %s\" % str(len(rules)))")
