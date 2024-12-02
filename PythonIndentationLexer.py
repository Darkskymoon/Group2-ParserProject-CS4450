from antlr4 import Token
from PythonGrammarLexer import PythonGrammarLexer

class PythonIndentationLexer(PythonGrammarLexer):
    def __init__(self, input_stream):
        super().__init__(input_stream)
        
        # Indent stack starts with 0 indent level
        self.indent_stack = [0]

        # Pending INDENT and DEDENT tokens
        self.pending_tokens = []

    def nextToken(self):
        # Get the next token
        token = super().nextToken()

        # Check if this is a NEWLINE token
        if token.type == self.NEWLINE:
        
            # Peek at next characters to check for indentation, consuming indents
            new_indent = 0
            while self._input.LA(1) == 9:
                new_indent += 1
                self._input.consume()
                
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

                    # Add a NEWLINE token after DEDENT
                    newline_token = self._factory.create(
                        self._tokenFactorySourcePair,
                        self.NEWLINE,
                        '\n',
                        self._channel,
                        token.start,
                        token.stop,
                        token.line,
                        token.column
                    )

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