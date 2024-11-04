import sys
from antlr4 import *
from PythonGrammar import PythonGrammarLexer
from PythonGrammar import PythonGrammarParser


def main():
    if(len(sys.argv) == 1)
        #much of the following is taken from the TinyCCode example on canvas
        lexer = PythonGrammarLexer(sys.argv[0])
        stream = CommonTokenStream(lexer)
        parser = PythonGrammarParser(stream)

        if(parser.getNumberOfSyntaxErrors()>0):
            print("The python file is INVALID")
            print(f"There were {parser.getNumberOfSyntaxErrors()}")
        else:
            print("The python file is VALID")
    else:
        print("Please provide 1 argument for the file to test!")

