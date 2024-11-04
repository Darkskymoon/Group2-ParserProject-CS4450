grammar PythonGrammar;

program: Assignment EOF;
Expression: ('+'|'-'|'*'|'/'|'%') ValidParam;

ValidParam: ([0-9]+|VarName);
Expression2: ValidParam Expression;

Assignment: VarName ('='|'+''='|'-''='|'*''='|'/''=') Expression2 '\n';


 
VarName: ([a-z]|[A-Z]|'_')+([a-z]|[A-Z]|[1-9]|'_')*;