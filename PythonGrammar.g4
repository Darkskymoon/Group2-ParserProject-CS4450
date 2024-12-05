grammar PythonGrammar;


@lexer::members
{
# Indent stack starts with 0 indent level
indent_stack = [0]

# Pending INDENT and DEDENT tokens
pending_tokens = []
    
def nextToken(self):
    # Get the next token
    token = super().nextToken()

    # Check if this is a NEWLINE token
    if token.type == self.NEWLINE:
    
        # Peek at next characters to check for indentation, consuming indents
        new_indent = 0
        while self._input.LA(1) == ord('\t'):
            new_indent += 1
            self._input.consume()
            
        # Check for 4-space indentations
        space_count = 0
        while self._input.LA(1) == ord(' '):
            space_count += 1
            self._input.consume()

        new_indent += space_count // 4

        if space_count % 4 != 0:
            raise ValueError("Indentation error: spaces not multiple of 4")

        # Compare with previous indentation
        current_indent = self.indent_stack[-1] if self.indent_stack else 0
        
        # If indent is greater than current, create an indent tokens
        if new_indent > current_indent:
            # Create indent for each tab
            for i in range(0, new_indent - current_indent):
                indent_token = self._factory.create(
                    self._tokenFactorySourcePair, 
                    self.INDENT, 
                    ' ' * new_indent, 
                    self._channel, 
                    token.start, 
                    token.stop, 
                    token.line, 
                    token.column
                )
                self.indent_stack.append(new_indent)
                self.pending_tokens.append(indent_token)
        
        # If new indent is less than current, create a dedent tokens
        elif new_indent < current_indent:
            # Create dedent tokens for each previous indent that is greater than the new indent
            while self.indent_stack and self.indent_stack[-1] > new_indent:
                self.indent_stack.pop()

                dedent_token = self._factory.create(
                    self._tokenFactorySourcePair, 
                    self.DEDENT, 
                    '', 
                    self._channel, 
                    token.start, 
                    token.stop, 
                    token.line, 
                    token.column
                )
                
                self.pending_tokens.append(dedent_token)
    
    # Emit dedent tokens if EOF
    if token.type == Token.EOF:
        while self.indent_stack and self.indent_stack[-1] > 0:
            self.indent_stack.pop()
            dedent_token = self._factory.create(
                self._tokenFactorySourcePair,
                self.DEDENT,
                '',
                self._channel,
                token.start,
                token.stop,
                token.line,
                token.column
            )
            self.pending_tokens.append(dedent_token)
    
    # Append token to pending to ensure it is handled
    self.pending_tokens.append(token)

    # Return tokens with pending tokens prioritized
    return self.pending_tokens.pop(0) if self.pending_tokens else token
}

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
    : expression operator validParam 
    | validParam;

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
    : comparison (AND | OR) comparison
    | comparison;

indented_block
    : INDENT statement+ DEDENT NEWLINE*;

if
    : 'if' conditional ':' indented_block (elif)* (else)?;

elif
    : 'elif' conditional ':' indented_block;

else
    : 'else:' indented_block;

loop
    : for
    | while;

for
    :'for ' VarName ' in' VarName  ':' indented_block
    |'for ' VarName ' in range' '(' Number ',' Number')' ':' indented_block;

while
    : 'while' conditional ':' indented_block;