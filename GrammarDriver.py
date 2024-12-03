import sys
from antlr4 import *
from PythonIndentationLexer import PythonIndentationLexer
from PythonGrammarParser import PythonGrammarParser
from graphviz import Digraph

def create_parse_tree_graph(tree, parser, output_file='parse_tree'):
    """
    Create a graphical representation of the parse tree
    
    Args:
    - tree: The parse tree node
    - parser: The parser used to create the tree
    - output_file: Base name for output files
    """
    dot = Digraph(comment='Parse Tree', 
                  node_attr={'shape': 'box', 'style': 'filled', 'fillcolor': 'lightblue'})

    def get_token_name(symbol_type):
        """
        Get a meaningful name for a token type
        """
        # Try literal names first
        if 0 <= symbol_type < len(parser.literalNames):
            literal = parser.literalNames[symbol_type]
            if literal and literal != '<INVALID>':
                return literal.strip("'")
        
        # Then try symbolic names
        if 0 <= symbol_type < len(parser.symbolicNames):
            symbolic = parser.symbolicNames[symbol_type]
            if symbolic and symbolic != '<INVALID>':
                return symbolic
        
        # Fallback
        return f'Token_{symbol_type}'

    def format_node_label(node):
        """
        Generate a formatted label for the node
        """
        from antlr4.tree.Tree import TerminalNode
        
        if isinstance(node, TerminalNode):
            symbol = node.getSymbol()
            token_type = symbol.type
            token_text = symbol.text
            
            # Special handling for EOF
            if token_type == parser.EOF:
                return 'EOF'
            
            # Get token name
            token_name = get_token_name(token_type)
            
            # Clean up and format the label
            clean_text = repr(token_text).strip("'\"")
            return f"{token_name}: {clean_text}"
        
        # For non-terminal nodes, use rule name
        return parser.ruleNames[node.getRuleIndex()]

    def add_nodes(node, parent=None):
        if node is None:
            return

        # Generate node label and ID
        node_label = format_node_label(node)
        node_id = str(id(node))

        # Styling for terminal vs non-terminal nodes
        from antlr4.tree.Tree import TerminalNode
        if isinstance(node, TerminalNode):
            dot.node(node_id, node_label, shape='ellipse', fillcolor='lightyellow')
        else:
            dot.node(node_id, node_label)

        # Connect to parent if exists
        if parent:
            dot.edge(str(id(parent)), node_id)

        # Recursively process children
        for i in range(node.getChildCount()):
            add_nodes(node.getChild(i), node)

    # Start the graph generation
    add_nodes(tree)

    # Render to file (SVG and PDF)
    dot.render(output_file, format='svg', cleanup=True)
    dot.render(output_file, format='pdf', cleanup=True)
    print(f"Parse tree visualizations created: {output_file}.svg and {output_file}.pdf")

def main():
    if(len(sys.argv) == 2):
        # much of the following is taken from the TinyCCode example on canvas
        lexer = PythonIndentationLexer(FileStream(sys.argv[1]))
        stream = CommonTokenStream(lexer)
        parser = PythonGrammarParser(stream)
        tree = parser.program()

        # Generate parse tree visualization
        create_parse_tree_graph(tree, parser)

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
