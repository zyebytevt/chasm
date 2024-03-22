module chasm.compiler.compiler;

import chasm.compiler.lexing.token;
import chasm.compiler.lexing.lexer;
import chasm.compiler.ast;
import chasm.compiler.parsing.expression;

enum MessageType {
    error,
    warning,
    information
}

class Compiler {
protected:
    Lexer mLexer;
    
public:
    alias MessageCallback = void function(SourcePosition position, MessageType type, string message);
    alias GetModuleSourceCallback = string function(string moduleName);

    MessageCallback messageCallback;
    GetModuleSourceCallback getModuleSourceCallback;

    this() @trusted {
        mLexer = new Lexer(this);
    }

    ~this() @trusted {
        mLexer.destroy();
    }

    final void writeMessage(SourcePosition position, MessageType type, string message) {
        if (messageCallback) {
            messageCallback(position, type, message);
        }
    }

    final string getModuleSource(string moduleName) {
        if (getModuleSourceCallback) {
            return getModuleSourceCallback(moduleName);
        }
        
        return null;
    }

    final void compile(string source, string fileName = "<unknown>") {
        mLexer.start(source, fileName);
        Expression expression = mLexer.parseExpression();

        writeMessage(SourcePosition("", 0, 0), MessageType.information, expression.toString());

        import chasm.compiler.debugging;
        auto visitor = new ExpressionPrintVisitor();
        visitor.visit(expression);
    }
}