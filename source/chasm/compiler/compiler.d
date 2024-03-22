module chasm.compiler.compiler;

import chasm.compiler.lexer.token;
import chasm.compiler.lexer.lexer;

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

    this() {
        mLexer = new Lexer(this);
    }

    ~this() {
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
}