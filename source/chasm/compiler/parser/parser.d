module chasm.compiler.parser.parser;

import chasm.compiler.compiler;
import chasm.compiler.lexer.lexer;

class Parser {
protected:
    Compiler mCompiler;
    Lexer mLexer;

public:
    this(Compiler compiler) {
        mCompiler = compiler;
    }

    void start(Lexer lexer) {
        mLexer = lexer;
    }
}