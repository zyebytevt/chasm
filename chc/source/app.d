module chc;

import std.stdio;
import std.file : readText;
import std.datetime.stopwatch : StopWatch, AutoStart;

import chasm.compiler.compiler;

void main()
{
	immutable string source = readText("test.ch");

	auto compiler = new Compiler();

	compiler.messageCallback = (position, type, message) {
		writefln("%s %s: %s", position, type, message);
	};

	compiler.compile(source, "test.ch");
}
