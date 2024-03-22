module chasm.compiler.parsing.expression;

import std.string : format;

import chasm.compiler.ast;
import chasm.compiler.compiler;
import chasm.compiler.lexing.lexer;
import chasm.compiler.lexing.token;

Expression parseExpression(Lexer lexer) {
    return parseBinary(lexer, parsePrimary(lexer), 0);
}

Expression parsePrimary(Lexer lexer) {
    with (Token.Type)
    switch (lexer.peek().type) {
    case openParen:
        return parseGrouping(lexer);
    
    case string:
    case integer:
    case floating:
    case boolean:
    case kwNull:
        return parseLiteral(lexer);

    case identifier:
        return parseSymbol(lexer);

    case minus:
    case plus:
    case logicNot:
    case bitwiseNot:
        return parseUnary(lexer);

    default:
        immutable token = lexer.next();
        lexer.compiler.writeMessage(token.position, MessageType.error, format!"Unexpected token: %s"(token.type));
        return null;
    }
}

private:

Expression parseBinary(Lexer lexer, Expression left, int minPrecedence) {
    static int[Token.Type] precedence = [
        Token.Type.logicOr: 10,
        Token.Type.logicAnd: 20,
        Token.Type.bitwiseOr: 30,
        Token.Type.bitwiseXor: 40,
        Token.Type.bitwiseAnd: 50,
        Token.Type.equal: 60,
        Token.Type.notEqual: 60,
        Token.Type.less: 70,
        Token.Type.lessEqual: 70,
        Token.Type.greater: 70,
        Token.Type.greaterEqual: 70,
        Token.Type.shiftLeft: 80,
        Token.Type.shiftRight: 80,
        Token.Type.plus: 90,
        Token.Type.minus: 90,
        Token.Type.asterisk: 100,
        Token.Type.slash: 100,
        Token.Type.modulo: 100,
    ];

    auto lookAhead = lexer.peek();

    while (precedence.get(lookAhead.type, -1) >= minPrecedence) {
        auto operator = lexer.next();
        auto right = parsePrimary(lexer);
        if (!right) {
            return null;
        }

        lookAhead = lexer.peek();
        while (precedence.get(lookAhead.type, -1) > precedence[operator.type]) {
            right = parseBinary(lexer, right, precedence[lookAhead.type]);
            lookAhead = lexer.peek();
        }

        left = new Expression.Binary(operator, left, right, left.position);
    }

    return left;
}

Expression parseLiteral(Lexer lexer) {
    immutable Token token = lexer.next();
    return new Expression.Literal(token, token.position);
}

Expression parseCall(Lexer lexer, Expression callee) {
    return new Expression.Call(callee, parseArguments(lexer), callee.position);
}

Expression[] parseArguments(Lexer lexer) {
    Expression[] result;

    lexer.enforce(Token.Type.openParen);

    while (!lexer.match(Token.Type.closeParen)) {
        result ~= parseExpression(lexer);

        if (!lexer.match(Token.Type.closeParen)) {
            lexer.enforce(Token.Type.comma);
        }
    }

    lexer.enforce(Token.Type.closeParen);
    return result;
}

Expression parseGrouping(Lexer lexer) {
    lexer.enforce(Token.Type.openParen);
    auto expression = parseExpression(lexer);
    lexer.enforce(Token.Type.closeParen);

    return expression;
}

Expression parseSymbol(Lexer lexer) {
    immutable Token token = lexer.next();
    return new Expression.Symbol(token, token.position);
}

Expression parseUnary(Lexer lexer) {
    immutable Token token = lexer.next();
    auto operand = parsePrimary(lexer);

    return new Expression.Unary(token, operand, token.position);
}