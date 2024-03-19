module chasm.compiler.lexer.stream;

import chasm.compiler.lexer.token;

package:

struct TextStream {
private:
    string mText;
    size_t mCurrent;
    SourcePosition mPosition;

public:
    this(string text, string fileName) pure nothrow {
        mText = text;
        mCurrent = 0;
        mPosition = SourcePosition(fileName, 1, 1);
    }

    char get() pure nothrow {
        debug assert(mCurrent < mText.length, "End of file reached");

        immutable char c = mText[mCurrent++];
        
        if (c == '\n') {
            mPosition.line++;
            mPosition.column = 1;
        } else {
            mPosition.column++;
        }

        return c;
    }

    char peek(ptrdiff_t offset = 0) pure const nothrow {
        immutable size_t index = mCurrent + offset;

        return index >= mText.length ? '\0' : mText[index];
    }

    bool isEof() pure const nothrow => mCurrent >= mText.length;

    SourcePosition position() pure const nothrow => mPosition;

    string text() pure const nothrow => mText;
    size_t current() pure const nothrow => mCurrent;
}