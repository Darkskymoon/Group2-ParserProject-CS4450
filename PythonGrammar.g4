grammar PythonGrammar;

INDENT  : '\t';  // Tab for indentation
DEDENT  : '<DEDENT>'; // Dedentation placeholder

program: (statement NEWLINE*)* EOF;

NEWLINE
    : '\r'?'\n';

statement
    : assignment 
    | expression
    | conditional
    | NEWLINE
    | if
    | loop
    | comment;

assignment
    : VarName assignmentOperator expression;

operator
    : PLUS | MINUS | MULT | DIV | MOD;

expression
    : validParam (operator expression)?;

String
    : '"' ([a-zA-Z0-9_ ]|'!'|[#-/])* '"'   
    | '\'' ([a-zA-Z0-9_ ]|[!-&]|[*-/])* '\'';   

Number
    : ('-')?[0-9]+ ('.'[0-9]*)?;

Bool
    : 'True'
    | 'False';

validParam
    : Number
    | VarName
    | String 
    | Bool
    | '[' validParam (',' validParam)* ']';

comment
    : SingleLineComment
    | MultiLineComment;

SingleLineComment
    : '#' [a-zA-Z0-9_ ]*;

//Uses code from: https://stackoverflow.com/questions/12898052/antlr-how-to-skip-multiline-comments
MultiLineComment 
    : '\'\'\'' .*? '\'\'\'' ;
    //: '\'\'\'' ((NEWLINE|[a-zA-Z0-9_ ]|[!-/]))*? '\'\'\'' ;


assignmentOperator: ASSIGN | PLUS_ASSIGN | MINUS_ASSIGN | MULT_ASSIGN | DIV_ASSIGN;

conditionalOperator: LESS_THAN | GREATER_THAN | EQUAL_TO | NOT_EQUAL_TO | LESS_THAN_OR_EQUAL_TO | GREATER_THAN_OR_EQUAL_TO;
 
VarName
    : [a-zA-Z_] [a-zA-Z0-9_]*;

WS
    :	[ ]+ -> skip;

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

AND           : ' and ';
OR            : ' or ';
NOT           : 'not ';

comparable
    : validParam
    | Bool
    | NOT comparable;

comparison
    : comparable conditionalOperator comparable
    | NOT? '(' comparison ')'
    | comparable; 

conditional
    : comparison ((AND | OR) comparison)*;

indented_block
    : INDENT statement+ DEDENT;

if
    : 'if' conditional ':' indented_block (elif)* (else)?;

elif
    : 'elif' conditional ':' indented_block;

else
    : 'else:' indented_block;

loop
    : for
    | while;

for: 'for ' VarName 'in' (VarName | 'range' '(' Number ',' Number ')')  ':' indented_block;

while
    : 'while' conditional ':' indented_block;