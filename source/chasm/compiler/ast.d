module chasm.compiler.ast;

import chasm.compiler.lexer.token;
import core.sys.posix.sys.socket;
import std.file;

abstract class Node {
public:
    SourcePosition position;

    this(SourcePosition position) {
        this.position = position;
    }
}

class Module : Node {
public:
    Import[] imports;
    Declaration[] declarations;

    this(Import[] imports, Declaration[] declarations, SourcePosition position) {
        super(position);
        this.imports = imports;
        this.declarations = declarations;
    }
}

class Type : Node {
public:
    Token name;
    Type generic;

    this(Token name, Type generic, SourcePosition position) {
        super(position);
        this.name = name;
        this.generic = generic;
    }
}

class Attribute : Node {
public:
    enum Type {
        public_,
        protected_,
        private_,
        static_,
        abstract_,
        final_,
        async,
    }

    Type type;
    Expression[] arguments;

    this(Type type, Expression[] arguments, SourcePosition position) {
        super(position);
        this.type = type;
        this.arguments = arguments;
    }
}

class Import : Node {
public:
    Token path;

    this(Token path, SourcePosition position) {
        super(position);
        this.path = path;
    }
}

abstract class Expression : Node {
public:
    interface Visitor(R) {
        R visit(Literal expression);
        R visit(Symbol expression);
        R visit(Unary expression);
        R visit(Binary expression);
        R visit(Ternary expression);
        R visit(Call expression);
        R visit(Super expression);
        R visit(This expression);
    }

    static class Literal : Expression {
    public:
        Token token;

        this(Token token, SourcePosition position) {
            super(position);
            this.token = token;
        }
    }

    static class Symbol : Expression {
    public:
        Token token;

        this(Token token, SourcePosition position) {
            super(position);
            this.token = token;
        }
    }

    static class Unary : Expression {
    public:
        Token.Type operator;
        Expression operand;

        this(Token.Type operator, Expression operand, SourcePosition position) {
            super(position);
            this.operator = operator;
            this.operand = operand;
        }
    }

    static class Binary : Expression {
    public:
        Token.Type operator;
        Expression left;
        Expression right;

        this(Token.Type operator, Expression left, Expression right, SourcePosition position) {
            super(position);
            this.operator = operator;
            this.left = left;
            this.right = right;
        }
    }

    static class Ternary : Expression {
    public:
        Expression condition;
        Expression trueResult;
        Expression falseResult;

        this(Expression condition, Expression trueResult, Expression falseResult, SourcePosition position) {
            super(position);
            this.condition = condition;
            this.trueResult = trueResult;
            this.falseResult = falseResult;
        }
    }

    static class Call : Expression {
    public:
        Expression callee;
        Expression[] arguments;

        this(Expression callee, Expression[] arguments, SourcePosition position) {
            super(position);
            this.callee = callee;
            this.arguments = arguments;
        }
    }

    static class Super : Expression {
    public:
        Token keyword;

        this(Token keyword, SourcePosition position) {
            super(position);
            this.keyword = keyword;
        }
    }

    static class This : Expression {
    public:
        Token keyword;

        this(Token keyword, SourcePosition position) {
            super(position);
            this.keyword = keyword;
        }
    }

    static class New : Expression {
    public:
        Type type;
        Call call;

        this(Type type, Call call, SourcePosition position) {
            super(position);
            this.type = type;
            this.call = call;
        }
    }

    this(SourcePosition position) {
        super(position);
    }
}

class Statement : Node {
public:
    static class Block : Statement {
    public:
        Statement[] statements;

        this(Statement[] statements, SourcePosition position) {
            super(position);
            this.statements = statements;
        }
    }

    static class While : Statement {
    public:
        Expression condition;
        Statement body_;

        this(Expression condition, Statement body_, SourcePosition position) {
            super(position);
            this.condition = condition;
            this.body_ = body_;
        }
    }

    static class Return : Statement {
    public:
        Expression value;

        this(Expression value, SourcePosition position) {
            super(position);
            this.value = value;
        }
    }

    static class If : Statement {
    public:
        Expression condition;
        Statement trueBranch;
        Statement falseBranch;

        this(Expression condition, Statement trueBranch, Statement falseBranch, SourcePosition position) {
            super(position);
            this.condition = condition;
            this.trueBranch = trueBranch;
            this.falseBranch = falseBranch;
        }
    }

    static class Goto : Statement {
    public:
        Token label;

        this(Token label, SourcePosition position) {
            super(position);
            this.label = label;
        }
    }

    this(SourcePosition position) {
        super(position);
    }
}

class Declaration : Node {
public:
    static class Parameter : Declaration {
    public:
        Token name;
        Type type;

        this(Token name, Type type, SourcePosition position) {
            super(position);
            this.name = name;
            this.type = type;
        }
    }

    static class Variable : Declaration {
    public:
        Token name;
        Type type;
        Expression initializer;
        bool isConst;
        Attribute[] attributes;

        this(Token name, Type type, Expression initializer, bool isConst, Attribute[] attributes, SourcePosition position) {
            super(position);
            this.name = name;
            this.type = type;
            this.initializer = initializer;
            this.isConst = isConst;
            this.attributes = attributes;
        }
    }

    static class Function : Declaration {
    public:
        Token name;
        Type returnType;
        Parameter[] parameters;
        Statement body_;
        Attribute[] attributes;

        this(Token name, Type returnType, Parameter[] parameters, Statement body_, Attribute[] attributes, SourcePosition position) {
            super(position);
            this.name = name;
            this.returnType = returnType;
            this.parameters = parameters;
            this.body_ = body_;
            this.attributes = attributes;
        }
    }

    static class Class : Declaration {
    public:
        Token name;
        Token superClass;
        Declaration[] members;
        Attribute[] attributes;

        this(Token name, Token superClass, Declaration[] members, Attribute[] attributes, SourcePosition position) {
            super(position);
            this.name = name;
            this.superClass = superClass;
            this.members = members;
            this.attributes = attributes;
        }
    }

    this(SourcePosition position) {
        super(position);
    }
}