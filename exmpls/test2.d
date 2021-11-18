#!/usr/bin/rdmd --shebang=-I../source -I.

import std.stdio : writeln, writefln, stderr, File;
//import std.math  : approxEqual;
import std.typecons  : tuple;

import dini      : IniConfigs, IniConfigsException, ConfigsTrait;


struct AppConfigsDefault
{
    enum string value11 = "Ultimate Question of Life, the Universe, and Everything";
    enum size_t value12 = 42;
}

alias AppConfigs = ConfigsTrait!AppConfigsDefault;


void main(string[] args)
{
    AppConfigs cfg;
    writeln(tuple(cfg.value11, cfg.value12));


    try {
        cfg.init (args[1]);
    } catch (IniConfigsException e) {
        stderr.writeln(e.msg);
        return;
    }

    writeln(tuple(cfg.value11, cfg.value12));
}
