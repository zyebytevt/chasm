module chasm.compiler.lexing.lexer;

import std.string : format;
import std.conv : to;
import std.algorithm : canFind;

import chasm.compiler.lexing.stream;
import chasm.compiler.lexing.token;
import chasm.compiler.compiler;

class Lexer {
protected:
    Compiler mCompiler;
    TextStream mStream;
    Token mCurrentToken;

    Token scanOperator() {
        auto start = mStream.position;

        switch (mStream.get()) with (Token.Type) {
        case '{': return Token(start, openBrace);
        case '}': return Token(start, closeBrace);
        case '(': return Token(start, openParen);
        case ')': return Token(start, closeParen);
        case '[': return Token(start, openBracket);
        case ']': return Token(start, closeBracket);
        case '?': return Token(start, question);
        case ':': return Token(start, colon);
        case '.': return Token(start, dot);
        case '<':
            if (mStream.peek() == '<') {
                mStream.get();
                return Token(start, shiftLeft);
            } else if (mStream.peek() == '=') {
                mStream.get();
                return Token(start, lessEqual);
            }
            return Token(start, less);
        case '>':
            if (mStream.peek() == '>' && lexShiftRight) {
                mStream.get();
                return Token(start, shiftRight);
            } else if (mStream.peek() == '=') {
                mStream.get();
                return Token(start, greaterEqual);
            }
            return Token(start, greater);
        case '=':
            if (mStream.peek() == '=') {
                mStream.get();
                return Token(start, equal);
            }
            return Token(start, assign);
        case '!':
            if (mStream.peek() == '=') {
                mStream.get();
                return Token(start, notEqual);
            }
            return Token(start, logicNot);
        case '+':
            if (mStream.peek() == '=') {
                mStream.get();
                return Token(start, plusAssign);
            }
            return Token(start, plus);
        case '-':
            if (mStream.peek() == '=') {
                mStream.get();
                return Token(start, minusAssign);
            }
            return Token(start, minus);
        case '*':
            if (mStream.peek() == '=') {
                mStream.get();
                return Token(start, asteriskAssign);
            }
            return Token(start, asterisk);
        case '/':
            if (mStream.peek() == '=') {
                mStream.get();
                return Token(start, slashAssign);
            }
            return Token(start, slash);
        case '%':
            if (mStream.peek() == '=') {
                mStream.get();
                return Token(start, moduloAssign);
            }
            return Token(start, modulo);
        case '&':
            if (mStream.peek() == '&') {
                mStream.get();
                return Token(start, logicAnd);
            }
            if (mStream.peek() == '=') {
                mStream.get();
                return Token(start, bitwiseAndAssign);
            }
            return Token(start, bitwiseAnd);
        case '|':
            if (mStream.peek() == '|') {
                mStream.get();
                return Token(start, logicOr);
            }
            if (mStream.peek() == '=') {
                mStream.get();
                return Token(start, bitwiseOrAssign);
            }
            return Token(start, bitwiseOr);
        case '^':
            if (mStream.peek() == '=') {
                mStream.get();
                return Token(start, bitwiseXorAssign);
            }
            return Token(start, bitwiseXor);
        case '~': return Token(start, bitwiseNot);
        case ',': return Token(start, comma);
        default:
            mCompiler.writeMessage(start, MessageType.error, format!"Unknown operator: %s"(mStream.peek(-1)));
            return Token(start, endOfStatement);
        }
    }

    Token scanWord() {
        auto start = mStream.position;
        size_t startIndex = mStream.current;

        char c = mStream.peek();
        while (c == '_' || (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || (c >= '0' && c <= '9')) {
            mStream.get();
            c = mStream.peek();
        }

        string word = mStream.text[startIndex..mStream.current];

        switch (word) with (Token.Type) {
        case "true": return Token(start, boolean, true);
        case "false": return Token(start, boolean, false);
        case "null": return Token(start, kwNull);
        case "if": return Token(start, kwIf);
        case "else": return Token(start, kwElse);
        case "while": return Token(start, kwWhile);
        case "class": return Token(start, kwClass);
        case "extends": return Token(start, kwExtends);
        case "func": return Token(start, kwFunc);
        case "return": return Token(start, kwReturn);
        case "new": return Token(start, kwNew);
        case "var": return Token(start, kwVar);
        case "const": return Token(start, kwConst);
        case "abstract": return Token(start, kwAbstract);
        case "final": return Token(start, kwFinal);
        case "native": return Token(start, kwNative);
        case "public": return Token(start, kwPublic);
        case "protected": return Token(start, kwProtected);
        case "private": return Token(start, kwPrivate);
        case "static": return Token(start, kwStatic);
        case "goto": return Token(start, kwGoto);

        case "and": return Token(start, logicAnd);
        case "or": return Token(start, logicOr);
        case "not": return Token(start, logicNot);
        case "bitand": return Token(start, bitwiseAnd);
        case "bitor": return Token(start, bitwiseOr);
        case "bitxor": return Token(start, bitwiseXor);
        case "bitnot": return Token(start, bitwiseNot);
        default: return Token(start, identifier, word);
        }
    }

    Token scanString() {
        auto start = mStream.position;
        size_t startIndex = mStream.current;

        immutable char quoteType = mStream.get();

        while (mStream.peek() != quoteType) {
            mStream.get();
        }

        string str = mStream.text[startIndex+1..mStream.current];
        mStream.get(); // Skip the closing quote.

        return Token(start, Token.Type.string, str);
    }

    Token scanNumber() {
        auto start = mStream.position;
        size_t startIndex = mStream.current;
        bool isFloating = false;
        int base = 10;
        char c = mStream.peek();

        while ((c >= '0' && c <= '9') || (c >= 'a' && c <= 'f') || (c >= 'A' && c <= 'F') || c == 'x' || c == '.') {
            mStream.get();

            if (c == '.') {
                if (isFloating) {
                    break;
                }

                isFloating = true;
            }

            if (!mStream.isEof) {
                c = mStream.peek();
            } else {
                break;
            }
        }

        string numString = mStream.text[startIndex..mStream.current];

        if (numString.length > 2 && numString[0] == '0') {
            if (isFloating) {
                mCompiler.writeMessage(start, MessageType.error, "Floating point numbers cannot have a base.");
            }

            switch (numString[1]) {
            case 'b': base = 2; break;
            case 'o': base = 8; break;
            case 'x': base = 16; break;
            default:
                mCompiler.writeMessage(start, MessageType.error, "Invalid number base.");
            }

            numString = numString[2..$];
        }

        if (isFloating) {
            return Token(start, Token.Type.floating, numString.to!double);
        } else {
            return Token(start, Token.Type.integer, numString.to!long(base));
        }
    }

    Token scanToken() {
    start:
        if (isEof) {
            return Token(mStream.position, Token.Type.endOfFile);
        }

        switch (mStream.peek()) {
        case ' ', '\t', '\r', '\\':
            mStream.get();
            goto start;

        case '/':
            if (mStream.peek(1) == '/') {
                mStream.get();
                mStream.get();

                while (mStream.peek() != '\n' && !isEof) {
                    mStream.get();
                }

                goto start;
            } else if (mStream.peek(1) == '*') {
                mStream.get();
                mStream.get();

                while (mStream.peek() != '*' && mStream.peek(1) != '/' && !isEof) {
                    mStream.get();
                }

                mStream.get();
                mStream.get();

                goto start;
            }
            goto case '*';

        case '\n':
            mStream.get();

            switch (mCurrentToken.type) {
            case Token.Type.openBrace:
            case Token.Type.openBracket:
            case Token.Type.openParen:
            case Token.Type.comma:
            case Token.Type.colon:
            case Token.Type.endOfStatement:
            case Token.Type.endOfFile:
                goto start;
            
            default:
                return Token(mStream.position, Token.Type.endOfStatement);
            }

        case '{':
        case '}':
        case '(':
        case ')':
        case '[':
        case ']':
        case '<':
        case '>':
        case '=':
        case '!':
        case '+':
        case '-':
        case '*':
        case '%':
        case '&':
        case '|':
        case '^':
        case '~':
        case ':':
        case '.':
        case '?':
        case ',':
            return scanOperator();

        case '"':
        case '\'':
            return scanString();

        case '0': .. case '9':
            return scanNumber();

        case 'a': .. case 'z':
        case 'A': .. case 'Z':
        case '_':
            return scanWord();

        default:
            mCompiler.writeMessage(mStream.position, MessageType.error, format!"Unknown character: %s"(mStream.get()));
            goto start;
        }
    }

public:
    /// If false, >> will be treated as two tokens, otherwise it will be treated as a single token.
    bool lexShiftRight;

    this(Compiler compiler) {
        mCompiler = compiler;
    }

    void start(string source, string fileName) {
        mStream = TextStream(source, fileName);
        lexShiftRight = true;
        mCurrentToken = scanToken();
    }

    Token next() {
        immutable result = mCurrentToken;
        mCurrentToken = scanToken();
        return result;
    }

    Token peek() {
        return mCurrentToken;
    }

    bool consume(Token.Type type) {
        if (mCurrentToken.type == type) {
            next();
            return true;
        }

        return false;
    }

    bool match(Token.Type type) {
        return mCurrentToken.type == type;
    }

    void enforce(Token.Type[] types...) {
        if (!types.canFind(mCurrentToken.type)) {
            compiler.writeMessage(mCurrentToken.position, MessageType.error,
                format!"Got '%s', expected %('%s' or %)."(mCurrentToken.type, types));
        }

        next();
    }

    bool isEof() @safe pure nothrow => mStream.isEof();

    Compiler compiler() pure nothrow => mCompiler;
}