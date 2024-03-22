module chasm.compiler.parser.expression;

import chasm.compiler.ast;
import chasm.compiler.compiler;
import chasm.compiler.lexer.lexer;
import chasm.compiler.lexer.token;

version(none)
Expression parseExpression(Compiler compiler, Lexer lexer) {
    with (Token.Type)
    static int[Token.Type] binaryPrecedence = [
        logicOr: 10,
        logicAnd: 20,
        bitwiseOr: 30,
        bitwiseXor: 40,
        bitwiseAnd: 50,
        equal: 60,
        notEqual: 60,
        less: 70,
        lessEqual: 70,
        greater: 70,
        greaterEqual: 70,
        shiftLeft: 80,
        shiftRight: 80,
        plus: 90,
        minus: 90,
        asterisk: 100,
        slash: 100,
        modulo: 100,
    ];
}