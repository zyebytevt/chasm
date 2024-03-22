module chasm.compiler.lexing.token;

import std.string : format;
import std.sumtype : SumType;

struct SourcePosition {
public:
    string fileName;
    size_t line;
    size_t column;

    int opCmp(ref const SourcePosition tp) @safe pure const nothrow {
        if (line == tp.line)
        {
            if (column > tp.column)
                return 1;
            
            if (column < tp.column)
                return -1;
            
            return 0;
        }
        
        if (line > tp.line)
            return 1;
        
        return -1;
    }
    
    bool opEquals(ref const SourcePosition tp) @safe pure const nothrow => opCmp(tp) == 0;
    
    string toString() @safe const => format!"%s(%d, %d)"(fileName, line, column);
}

struct Token {
public:
    alias Value = SumType!(string, long, double, bool, typeof(null));

    enum Type {
        endOfFile, endOfStatement, identifier, string, integer, floating, boolean,
        openParen, closeParen, openBracket, closeBracket, openBrace, closeBrace,
        comma, dot, colon, question,
        plus, minus, asterisk, slash, modulo,
        logicAnd, logicOr, logicNot, bitwiseAnd, bitwiseOr, bitwiseXor, bitwiseNot,
        equal, notEqual, instanceOf, notInstanceOf, less, lessEqual, greater, greaterEqual,
        shiftLeft, shiftRight,
        assign, plusAssign, minusAssign, asteriskAssign, slashAssign, moduloAssign,
        bitwiseAndAssign, bitwiseOrAssign, bitwiseXorAssign, shiftLeftAssign, shiftRightAssign,

        kwNull, kwClass, kwExtends, kwFunc, kwVar, kwConst, kwAbstract, kwFinal, kwNative, kwPublic,
        kwProtected, kwPrivate, kwStatic, kwNew, kwIf, kwElse, kwWhile, kwReturn, kwGoto,
    }

    SourcePosition position = void;
    Type type = void;
    Value value = void;

    this(SourcePosition position, Type type) @safe pure nothrow {
        this.position = position;
        this.type = type;
    }

    this(T)(SourcePosition position, Type type, T value) @trusted pure nothrow {
        this(position, type);
        this.value = Value(value);
    }
}