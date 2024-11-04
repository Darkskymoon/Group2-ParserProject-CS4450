grammar PythonGrammar;


expression: expression ('+'|'-'|'*'|'/'|'%') expression
    | ([0-9]+|variableName) ;

assignment: variableName ('='|'+''='|'-''='|'*''='|'/''=') expression '\n';

variableName: ([a-zA-Z]|_)+([a-zA-Z]|[1-9]|_)*;