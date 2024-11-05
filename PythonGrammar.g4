grammar PythonGrammar;

program: Assignment EOF;
Expression: ('+'|'-'|'*'|'/'|'%') ValidParam;

Expression2: ValidParam (Expression)*;

Float: [0-9]+'.'*[0-9]+;
Integer: [0-9]+;
String:'"'[\u0000-\u00ff]*'"';
Array: VarName'['[0-9]+']';
ArrayAssignmentParams: '['ValidParam']';
Bool: 'True'|'False';
ValidParam: (Integer|VarName|Float|String|Array);


Assignment: VarName ('='|'+''='|'-''='|'*''='|'/''=') Expression2 | VarName '=' Bool| VarName '=' ArrayAssignmentParams;


 
VarName: ([a-z]|[A-Z]|'_')+([a-z]|[A-Z]|[1-9]|'_')*;