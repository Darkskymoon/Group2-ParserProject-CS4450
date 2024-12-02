from antlr4 import Token
from PythonGrammarLexer import PythonGrammarLexer

class PythonIndentationLexer(PythonGrammarLexer):
    def __init__(self, input_stream):
        super().__init__(input_stream)
        self.indent_stack = [0]

        self.tokens = []
        self.pending_tokens = []

    def nextToken(self):
        # Get the next token
        token = super().nextToken()
        # Check if this is a NEWLINE token
        if token.type == self.NEWLINE:
            print("Line " + str(self.line))
            # Peek at next characters to check for indentation

            indent = 0
            while self._input.LA(1) == 9:
                indent += 1
                self._input.consume()
                
            # Compare with previous indentation
            current_indent = self.indent_stack[-1] if self.indent_stack else 0
            print("  Current Indent: " + str(current_indent))
            print("  New Indent: " + str(indent))

                
            if indent > current_indent:
                # Create INDENT token
                indent_token = self._factory.create(
                    self._tokenFactorySourcePair, 
                    self.INDENT, 
                    ' ' * indent, 
                    self._channel, 
                    token.start, 
                    token.stop, 
                    token.line, 
                    token.column
                )
                self.indent_stack.append(indent)
                self.pending_tokens.append(indent_token)

                print("  Indented!")
                
            elif indent < current_indent:
                # Create DEDENT tokens
                while self.indent_stack and self.indent_stack[-1] > indent:
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

                    print("  Dedented!")

        # Return tokens with pending tokens prioritized
        return self.pending_tokens.pop(0) if self.pending_tokens else token