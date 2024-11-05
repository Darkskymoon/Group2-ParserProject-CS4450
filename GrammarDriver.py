import sys
from antlr4 import *
from PythonGrammarLexer import PythonGrammarLexer
from PythonGrammarParser import PythonGrammarParser


def main(argv):
    if len(sys.argv) > 1:
        inputFile = FileStream(sys.argv[1])

        #much of the following is taken from the TinyCCode example on canvas
        lexer = PythonGrammarLexer(inputFile)
        stream = CommonTokenStream(lexer)
        parser = PythonGrammarParser(stream)
        tree = parser.program()
        print(tree.toStringTree(recog=parser))

        if(parser.getNumberOfSyntaxErrors()>0):
            print("The python file is INVALID")
            print(f"There were {parser.getNumberOfSyntaxErrors()}")
        else:
            print("The python file is VALID")
    else:
        print("Please provide 1 argument for the file to test!")

if __name__ == '__main__':
    main(sys.argv)