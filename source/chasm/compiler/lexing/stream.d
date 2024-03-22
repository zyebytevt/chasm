module chasm.compiler.lexing.stream;

import chasm.compiler.lexing.token;

package:

struct TextStream {
private:
    string mText;
    size_t mCurrent;
    SourcePosition mPosition;

public:
    this(string text, string fileName) @safe pure nothrow {
        mText = text;
        mCurrent = 0;
        mPosition = SourcePosition(fileName, 1, 1);
    }

    char get() @safe pure nothrow {
        if (mCurrent >= mText.length) {
            return '\0';
        }

        immutable char c = mText[mCurrent++];
        
        if (c == '\n') {
            mPosition.line++;
            mPosition.column = 1;
        } else {
            mPosition.column++;
        }

        return c;
    }

    char peek(ptrdiff_t offset = 0) @safe pure const nothrow {
        immutable size_t index = mCurrent + offset;

        return index >= mText.length ? '\0' : mText[index];
    }

    bool isEof() @safe pure const nothrow => mCurrent >= mText.length;

    SourcePosition position() @safe pure const nothrow => mPosition;

    string text() @safe pure const nothrow => mText;
    size_t current() @safe pure const nothrow => mCurrent;
}