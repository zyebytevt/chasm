module chasm.compiler.debugging;

import std.stdio;

import chasm.compiler.ast;

class ExpressionPrintVisitor : Expression.Visitor {
    void visit(Expression expression) {
        expression.accept(this);
    }

    void visit(Expression.Literal expression) {
        write(expression.token.value);
    }

    void visit(Expression.Symbol expression) {
        write(expression.token.value);
    }

    void visit(Expression.Unary expression) {
        write('(');
        write(expression.operator.type);
        expression.operand.accept(this);
        write(')');
    }

    void visit(Expression.Binary expression) {
        write('(');
        expression.left.accept(this);
        write(' ');
        write(expression.operator.type);
        write(' ');
        expression.right.accept(this);
        write(')');
    }

    void visit(Expression.Ternary expression) {
        write('(');
        expression.condition.accept(this);
        write(" ? ");
        expression.trueResult.accept(this);
        write(" : ");
        expression.falseResult.accept(this);
        write(')');
    }

    void visit(Expression.Call expression) {
        expression.callee.accept(this);
        write('(');
        foreach (arg; expression.arguments) {
            arg.accept(this);
            if (arg !is expression.arguments[$-1]) {
                write(", ");
            }
        }
        write(')');
    }

    void visit(Expression.Super expression) {
        write("super.");
    }

    void visit(Expression.This expression) {
        write("this");
    }

    void visit(Expression.New expression) {
        write("new ");
    }
}