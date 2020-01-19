@ initialize:python @
@@

from collections import defaultdict
import re
rule_count = 0
rules = []
regex = re.compile(r"\bcocci_id\b")
declarations = defaultdict(list)

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

d = regex.sub("cocci_id@p", d)
if d not in declarations:
    declarations[d] = []
declarations[d].append(p[0].line)
if p[0].line != p[0].line_end:
    declarations[d].append(p[0].line_end)


@ finalize:python @
@@

for d in declarations:
    rule_count += 1
    rules.append(rule_count)
    // Print the declaration to be matched and corresponding python binding
    print("@ r{rule_no} @".format(rule_no=str(rule_count)))
    print("symbol cocci_id;")
    print("position p;")
    print("@@")
    print("{decl}".format(decl=d))
    print("")
    print("@ script:python depends on r{rule_no} @".format(rule_no=str(rule_count)))
    print("p << r{rule_no}.p;".format(rule_no=str(rule_count)))
    print("@@")
    print("")
    print("if {rule_no} not in rule_matches:".format(rule_no=str(rule_count)))
    print("    rule_matches[%s] = {'lines': [], 'correct_lines': False, 'other_lines': []}" % str(rule_count))
    print("if p[0].line in {lines}:".format(lines=declarations[d]))
    print("    rule_matches[{rule_no}]['correct_lines'].append(p[0].line)".format(rule_no=str(rule_count)))
    print("else:")
    print("    rule_matches[{rule_no}]['other_lines'].append(p[0].line)".format(rule_no=str(rule_count)))
    print("")

print("@ finalize:python @")
print("@@")
print("rules = {rules}".format(rules=str(rules)))
print("for i in rules:")
print("    if rule_matches[i]['correct_lines']:")
print("        if rule_matches[i]['other_lines']:")
print("            print(\"PASSED %s: CORRECT MATCHES: %s INCORRECT MATCHES: %s\" % (str(i), str(rule_matches[i]['correct_lines'], str(rule_matches[i]['other_lines']))))")
print("        else:")
print("            print(\"PASSED %s: CORRECT MATCHES: %s\" % (str(i), str(rule_matches[i]['correct_lines'])))")
print("    else:")
print("        if rule_matches[i]['other_lines']:")
print("            print(\"FAILED %s: INCORRECT MATCHES: %s\" % (str(i), str(rule_matches[i]['other_lines'])))")
print("        else:")
print("            print(\"FAILED %s: NO MATCHES\" % (str(rule_matches[i]['other_lines'])))")
print("")
print("print(\"Total Number of cases: %s\" % str(len(rules)))")
