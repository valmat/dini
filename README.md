# Dlang ini-configs

[![Dub version](https://img.shields.io/dub/v/dini.svg)](https://code.dlang.org/packages/dini/~master)
[![License](https://img.shields.io/dub/l/dini.svg)](https://code.dlang.org/packages/dini/)
[![Build Status](https://travis-ci.org/valmat/dini.svg?branch=master)](https://travis-ci.org/valmat/dini)
[![Tests coverage](https://codecov.io/gh/valmat/dini/branch/master/graph/badge.svg)](https://codecov.io/github/valmat/dini)

**D** ini-configs parser

May read ini-configs content from string and form file. Support multiply adding content as well.

## Example

```d
import std.stdio  : writeln, writefln, File;
import iniconfigs : IniConfigs, IniConfigsException;

void main()
{
    string ini = `
        value1 = 1 ; value1 comment  
        value2 =  hello world ; value2 comment

        value3 = 3.1415 ; value3 comment

        ;value4 comment
        value4 = 3.14159263358979361680130282241663053355296142399311

        value5 = Some text with spaces           
        value6 = " Some text with spaces      "     


        boolval1 = on
        boolval2 = 1
        boolval3 = true

        boolval4 = off
        boolval5 = 0
        boolval6 = false
        boolval7 = any else
    `;

    IniConfigs cfg;

    writeln("Is ini configs empty? ", cfg.empty()); // true
    writeln("Ini entries number:  ",  cfg.size());  // 0

    try {
        cfg = ini;
    } catch (IniConfigsException e) {
        writeln(e.msg);
        return;
    }

    writeln("Is ini configs empty? ", cfg.empty()); // false
    writeln("Ini entries number:  ",  cfg.size());  // 13

    cfg.add(`
        value7 = 15
        value8 =  -15        
    `);
    writeln("Ini entries number:  ",  cfg.size()); // 15

    // You may add file:
    // cfg.add(File("test1.ini"));


    // You can extract value as is or specify default value
    writeln( cfg.get!float("value3",) );   // 3.1415
    writeln( cfg.get!float("value3+",) );  // float.nan <- default

    writeln( cfg.get("value3",  2.71828) ); // 3.1415
    writeln( cfg.get("value3+", 2.71828) ); // 2.71828 <- default


    // Extract integers:
    writeln( " 15 (ubyte)  == ", cfg.get!ubyte  ("value7") );
    writeln( " 15 (ushort) == ", cfg.get!ushort ("value7") );
    writeln( " 15 (uint)   == ", cfg.get!uint   ("value7") );
    writeln( " 15 (ulong)  == ", cfg.get!ulong  ("value7") );

    writeln( " -15 (byte)   == ", cfg.get!byte   ("value8") );
    writeln( " -15 (int)    == ", cfg.get!int    ("value8") );
    writeln( " -15 (short)  == ", cfg.get!short  ("value8") );
    writeln( " -15 (long)   == ", cfg.get!long   ("value8") );


    // Extract Floats:
    writefln("value3 : %.5f", cfg.get!float  ("value3") );
    writefln("value3 : %.5f", cfg.get!double ("value3") );
    writefln("value3 : %.5f", cfg.get!real   ("value3") );


    // Extract string:
    // Ini: `value5 = Some text with spaces`
    writeln( cfg.get!string("value5") ); // "Some text with spaces"
    // Ini: `value6 = " Some text with spaces      "`
    writeln( cfg.get!string("value6") ); // " Some text with spaces      "


    // Ini: `boolval1 = on`
    writeln( cfg.get("boolval1", false) );   // true

    // Ini: `boolval2 = 1`
    writeln( cfg.get("boolval2", false) );   // true

    // Ini: `boolval3 = true`
    writeln( cfg.get("boolval3", false) );   // true

    // Ini: `boolval4 = off`
    writeln( cfg.get("boolval4", true) );    // false

    // Ini: `boolval5 = 0`
    writeln( cfg.get("boolval5", true) );    // false

    // Ini: `boolval6 = false`
    writeln( cfg.get("boolval6", true) );    // false

    // Ini: `boolval7 = any else`
    writeln( cfg.get("boolval7", true) );    // false
}
```
## How to extend

You can extend on your custom types

If your castom type is constructable or assignable with `IniValue`.

Or you can use wrapper type to indirectly extend.

```d
import std.stdio  : writeln, writefln, File;
import iniconfigs : IniConfigs, IniConfigsException;
import iniconfigs : IniValue;
import std.conv   : to;

void main()
{
    IniConfigs cfg = "value1 = 1";

    // Constructable with IniValue
    static struct A1 {
        int a = 5;
        this(IniValue v) {
            this.a = v.toString.to!int;
        }
    }
    // Assignable with IniValue
    static struct A2 {
        int a = 7;
        void opAssign(IniValue v) {
            this.a = v.toString.to!int;
        }
    }

    writeln('[', cfg.get!A1("value1"),       ']'); // [A1(1)]
    writeln('[', cfg.get!A1("value1+"),      ']'); // [A1(5)]  <- default
    writeln('[', cfg.get("value1", A1(55)),  ']'); // [A1(1)]
    writeln('[', cfg.get("value1+", A1(55)), ']'); // [A1(55)] <- default

    writeln('[', cfg.get!A2("value1"),       ']'); // [A2(1)]
    writeln('[', cfg.get!A2("value1+"),      ']'); // [A2(7)]  <- default
    writeln('[', cfg.get("value1", A2(33)),  ']'); // [A2(1)]
    writeln('[', cfg.get("value1+", A2(33)), ']'); // [A2(33)] <- default

    //
    // Indirectly extend:
    //

    // Suppose you can't make the structure C assignable or constructable with IniValue.
    static struct C {
        int a = 5;
    }
    // In this case, you can write a wrapper. As shown below.
    static struct D {
        int a;
        this(IniValue v) {
            this.a = v.toString.to!int;
        }
        this(C c) {
            this.a = c.a;
        }
        C castToC() const {
            return C(this.a);
        }
        alias castToC this;
    }
    static struct E {
        int a;
        this(IniValue v) {
            this.a = v.toString.to!int;
        }
        C castToC() const {
            return C(this.a);
        }
        alias castToC this;
    }

    C c1 = cfg.get!D("value1");
    C c2 = cfg.get!E("value1");
    C c3 = cfg.get("value1+", cast(D) C(3));

    writeln('[', c1, ']'); // [C(1)]
    writeln('[', c2, ']'); // [C(1)]
    writeln('[', c3, ']'); // [C(3)]
}
```

see [example](exmpls/test.d)

---
[The MIT License](LICENSE)
