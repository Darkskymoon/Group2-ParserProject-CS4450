grammar PythonGrammar;

program: (statement Newline*)* EOF;

Newline
    : '\r'?'\n';

statement
    : assignment 
    | expression
    | conditional
    | if;

assignment
    : VarName assignmentOperator expression;

operator
    : PLUS | MINUS | MULT | DIV | MOD;

expression
    : validParam (operator expression)?;

String
    : '"' [a-zA-Z0-9_ ]* '"'   
    | '\'' [a-zA-Z0-9_ ]* '\'';   

Number
    : [0-9]+ ('.'[0-9]*)?;

Bool
    : 'True'
    | 'False';

validParam
    : Number
    | VarName
    | String 
    | Bool
    | '[' validParam (',' validParam)* ']';

assignmentOperator: ASSIGN | PLUS_ASSIGN | MINUS_ASSIGN | MULT_ASSIGN | DIV_ASSIGN;

conditionalOperator: LESS_THAN | GREATER_THAN | EQUAL_TO | NOT_EQUAL_TO | LESS_THAN_OR_EQUAL_TO | GREATER_THAN_OR_EQUAL_TO | AND | OR;
 
VarName
    : [a-zA-Z_] [a-zA-Z0-9_]*;

WS
    :	[ \t]+ -> skip;

PLUS          : '+';
MINUS         : '-';
MULT          : '*';
DIV           : '/';
MOD           : '%';

ASSIGN        : '=';
PLUS_ASSIGN   : '+=';
MINUS_ASSIGN  : '-=';
MULT_ASSIGN   : '*=';
DIV_ASSIGN    : '/=';

LESS_THAN     : '<';
GREATER_THAN  : '>';
EQUAL_TO      : '==';
NOT_EQUAL_TO  : '!=';
LESS_THAN_OR_EQUAL_TO  : '<=';
GREATER_THAN_OR_EQUAL_TO  : '>=';
AND           : 'and';
OR            : 'or';

conditional
    : (validParam) conditionalOperator (validParam | conditional);
if
    : 'if' conditional ':' (Newline* '\t' statement)*;
