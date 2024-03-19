module chc;

import std.stdio;
import std.file : readText;
import std.datetime.stopwatch : StopWatch, AutoStart;

import chasm.compiler.lexer.lexer;

void main()
{
	immutable string source = readText("test.ch");
	auto lexer = new Lexer();

	auto sw = StopWatch(AutoStart.yes);

	lexer.initialize(source);
	while (!lexer.isEof) {
		lexer.next();
	}

	writefln("Total duration: %d ms", sw.peek.total!"msecs");
}
