@ initialize:python @
@@

import os
types = set()
codebase_dir = os.getenv("CODEBASE_DIR")
if codebase_dir:
    codebase_dir = os.path.join(os.path.expanduser(codebase_dir), "")
add_comments = os.getenv("ADD_COMMENTS")


@ r0 @
type T;
position P;
@@

T@P


@ script:python r1 @
t << r0.T;
p << r0.P;
cocci_id;
@@

if t in types:
    cocci.include_match(False)
elif add_comments:
    try:
        file = p[0].file.split(codebase_dir)[1]
    except:
        file = p[0].file
    comment = "/* " + file + " " + p[0].line + " */"
    coccinelle.cocci_id = "cocci_id" + comment
    types.add(t)
else:
    coccinelle.cocci_id = "cocci_id"
    types.add(t)


@ r2 @
type r0.T;
identifier r1.cocci_id;
@@

cocci_test_suite() {
...
++ T cocci_id;
}
