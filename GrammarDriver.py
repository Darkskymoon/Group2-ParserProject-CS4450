import sys
from antlr4 import *
from PythonGrammarLexer import PythonGrammarLexer
from PythonGrammarParser import PythonGrammarParser


def main():
    if(len(sys.argv) == 2):
        #much of the following is taken from the TinyCCode example on canvas
        lexer = PythonGrammarLexer(FileStream(sys.argv[1]))
        stream = CommonTokenStream(lexer)
        parser = PythonGrammarParser(stream)
        tree =parser.program()

        # print(tree.toStringTree(recog=parser))
        if(parser.getNumberOfSyntaxErrors()>0):
            print("The python file is INVALID")
            # print(f"There were {parser.getNumberOfSyntaxErrors()} errors")
        else:
            print("The python file is VALID")
            # print(f"There were {parser.getNumberOfSyntaxErrors()} errors")

    else:
        print("Invalid command try \"python3 GrammarDriver.py project_deliverable_1.py\"")


main()
