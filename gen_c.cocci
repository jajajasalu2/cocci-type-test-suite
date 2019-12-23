@ initialize:python @
@@

import re
attr_pattern = re.compile(r'__')


@ r0 @
type T;
position P;
@@

T@P


@ script:python r1 @
t << r0.T;
@@

if attr_pattern.search(t) != None:
    cocci.include_match(False)


@ r2 @
type r0.T;
@@

cocci_test_suite() {
...
++ T cocci_id;
}
