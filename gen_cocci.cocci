@ initialize:python @
@@

import re
rule_count = 0
rules = []
regex = re.compile(r"\bcocci_id\b")
print("@ initialize:python @")
print("@@")
print("successful_rules = []")
print("")
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

rule_count += 1
rules.append(rule_count)
d = regex.sub("cocci_id@p", d)
print("@ r%s @" % (str(rule_count)))
print("symbol cocci_id;")
print("position p;")
print("@@")
print(d)
print("")
print("@ script:python depends on r%s @" % (str(rule_count)))
print("p << r%s.p;" % (str(rule_count)))
print("@@")
if int(p[0].line) != int(p[0].line_end):
    print("if int(p[0].line) == %s or int(p[0].line) == %s:" % (p[0].line, p[0].line_end))
else:
    print("if int(p[0].line) == %s:" % (p[0].line))
print("    successful_rules.append(%s)" % (str(rule_count)))
print("")
print("")


@ finalize:python @
@@

print("@ finalize:python @")
print("@@")
print("rules = %s" % (str(rules)))
print("print(\"SUCCESSFUL CASES:\")")
print("for i in rules:")
print("    if i in successful_rules:")
print("        print(\"%s\" % str(i))")
print("")
print("print(\"FAILED CASES:\")")
print("for i in rules:")
print("    if i not in successful_rules:")
print("        print(\"%s\" % str(i))")
