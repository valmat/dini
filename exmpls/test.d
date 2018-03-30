#!/usr/bin/rdmd --shebang=-I../source -I.

import std.stdio : writeln, writefln, File;
import std.math  : approxEqual;

import iniconfigs.iniconfig : IniConfigs, IniConfigsException;


void main()
{
    string ini = `
        value1 = 1 ;value1 comment  
        value2 =     hello world        ;value2 comment

            value3 =     1.1

        value3 = 3.1415 ; value3 comment

        ;value4 comment
        value4 = 3.14159263358979361680130282241663053355296142399311

        ;dfgg

            ; this is a comment      
        value5=value5
            value6  =   value6
        ;   dfgdfgdgd   sdfs    s       
                    value7= Some text with spaces           

                    value7+  = " Some text with spaces      "     

        value8_ = 985642
        value8=9856428642



        boolval1 = on
        boolval2 = 1
        boolval3 = true

        boolval4 = off
        boolval5 = 0
        boolval6 = false
        boolval7 = any else
    `;


    IniConfigs cfg;

    writeln("Is ini configs empty? ", cfg.empty());
    assert(cfg.empty());
    writeln("Ini entries number:  ",  cfg.size());
    assert(!cfg.size());

    try {
        cfg = ini;
    } catch (IniConfigsException e) {
        writeln(e.msg);
        return;
    }


    writeln("Is ini configs empty? ", cfg.empty());
    assert(!cfg.empty());
    writeln("Ini entries number:  ",  cfg.size());
    assert(17 == cfg.size());

    cfg.add(`
        value9 = 15
        value10 =  -15        
    `);

    writeln("Ini entries number:  ",  cfg.size());
    assert(19 == cfg.size());


    cfg.add(File("test1.ini"));

    writeln("Ini entries number:  ",  cfg.size());
    assert(21 == cfg.size());


    writeln( " 15 (ubyte)  == ", cfg.get!ubyte  ("value9") );
    assert(15 == cfg.get!ubyte  ("value9"));
    writeln( " 15 (ushort) == ", cfg.get!ushort ("value9") );
    assert(15 == cfg.get!ushort ("value9"));
    writeln( " 15 (uint)   == ", cfg.get!uint   ("value9") );
    assert(15 == cfg.get!uint   ("value9"));
    writeln( " 15 (ulong)  == ", cfg.get!ulong  ("value9") );
    assert(15 == cfg.get!ulong  ("value9"));
    //writeln( " 15 (ucent)  == ", cfg.get!ucent  ("value9") );


    writeln( " -15 (byte)   == ", cfg.get!byte   ("value10") );
    assert(-15 == cfg.get!byte   ("value10"));
    writeln( " -15 (int)    == ", cfg.get!int    ("value10") );
    assert(-15 == cfg.get!int    ("value10"));
    writeln( " -15 (short)  == ", cfg.get!short  ("value10") );
    assert(-15 == cfg.get!short  ("value10"));
    writeln( " -15 (long)   == ", cfg.get!long   ("value10") );
    assert(-15 == cfg.get!long   ("value10"));
    //writeln( " -15 (cent)   == ", cfg.get!cent   ("value10") );
    

    writefln("value3 : %.5f", cfg.get!float  ("value3") );
    assert( approxEqual(3.1415, cfg.get!float  ("value3")) );
    writefln("value3 : %.5f", cfg.get!double ("value3") );
    assert( approxEqual(3.1415, cfg.get!double ("value3")) );
    writefln("value3 : %.5f", cfg.get!real   ("value3") );
    assert( approxEqual(3.1415, cfg.get!real   ("value3")) );

    writefln("value4 : %.61f", cfg.get!float  ("value4") );
    assert( approxEqual(3.14159263358979361680130282241663053355296142399311, cfg.get!float  ("value4"), 1e-20) );
    writefln("value4 : %.61f", cfg.get!double ("value4") );
    assert( approxEqual(3.14159263358979361680130282241663053355296142399311, cfg.get!double ("value4"), 1e-40) );
    writefln("value4 : %.61f", cfg.get!real   ("value4") );
    assert( approxEqual(3.14159263358979361680130282241663053355296142399311, cfg.get!real   ("value4"), 1e-60) );

    
    const string name1  = "value1";
    const string name1_ = "value1_";
    int val1  = cfg.get(name1,  5);
    int val1_ = cfg.get(name1_, 5);

    writeln("[", name1, " ]: [", val1 , ']');
    assert(1 == val1);
    writeln("[", name1_, "]: [", val1_, ']');
    assert(5 == val1_);

    writeln("[value2  ]: [", cfg.get!string("value2",  "default value") , ']');
    assert("hello world"   == cfg.get!string("value2",  "default value") );
    writeln("[value2+ ]: [", cfg.get!string("value2+", "default value") , ']');
    assert("default value" == cfg.get!string("value2+", "default value") );

    
    writeln("[value3  ]: [", cfg.get!string("value3") ,  ']');
    assert("3.1415" == cfg.get!string("value3"));
    writeln("[value3+ ]: [", cfg.get!string("value3+") , ']');
    assert(""       == cfg.get!string("value3+"));
    
    writeln( "[value3  ] :[ ", cfg.get("value3",  2.718281828459), ']');
    assert(approxEqual(3.1415, cfg.get("value3",  2.718281828459)));
    writeln( "[value3+ ] :[ ", cfg.get("value3+", 2.718281828459), ']');
    assert(approxEqual(2.71828,cfg.get("value3+", 2.718281828459)));
    writeln( "[value4  ] :[ ", cfg.get("value4",  2.718281828459), ']');
    assert(approxEqual(3.14159,cfg.get("value4",  2.718281828459)));


    writeln("Has `value3`?  ", cfg.has("value3")  );
    assert(cfg.has("value3"));
    writeln("Has `value3+`? ", cfg.has("value3+") );
    assert(!cfg.has("value3+"));

    writeln("value4 :", cfg.get!float  ("value4",  2.718281828459) );
    writeln("value4 :", cfg.get!double ("value4",  2.718281828459) );

    auto value5 =  cfg.get!string("value5", "value5");
    auto value6 =  cfg.get!string("value6", "value6");
    writeln("value5 : [", value5, ']');
    writeln("value6 : [", value6, ']');


    writeln("value7 : [", cast(string) cfg.get!string("value7", "value7"), ']');
    writeln("value7 : [", cfg.get!string("value7", "value7"), ']');
    assert("Some text with spaces" == cfg.get!string("value7", "value7"));

    writeln("value7+ : [", cfg.get!string("value7+"), ']');
    assert(" Some text with spaces      " == cfg.get!string("value7+"));


    writeln("value8 : [", cfg.get("value8_", 0), ']');
    assert(985642     == cfg.get("value8_", 0) );
    writeln("value8 : [", cfg.get("value8", size_t(0)), ']');
    assert(9856428642 == cfg.get("value8", size_t(0)) );
    writeln("value8 : [", cfg.get!size_t("value8", 0), ']');
    assert(9856428642 == cfg.get!size_t("value8", 0) );


    writeln("boolval0 : [", cfg.get("boolval0", false), ']');
    assert(false == cfg.get("boolval0", false) );

    writeln("boolval1 : [", cfg.get("boolval1", false), ']');
    assert(true  == cfg.get("boolval1", false) );
    writeln("boolval2 : [", cfg.get("boolval2", false), ']');
    assert(true  == cfg.get("boolval2", false) );
    writeln("boolval3 : [", cfg.get("boolval3", false), ']');
    assert(true  == cfg.get("boolval3", false) );

    writeln("boolval4 : [", cfg.get("boolval4", true),  ']');
    assert(false == cfg.get("boolval4", true) );
    writeln("boolval5 : [", cfg.get("boolval5", true),  ']');
    assert(false == cfg.get("boolval5", true) );
    writeln("boolval6 : [", cfg.get("boolval6", true),  ']');
    assert(false == cfg.get("boolval6", true) );
    writeln("boolval7 : [", cfg.get("boolval7", true),  ']');
    assert(false == cfg.get("boolval7", true) );



    writeln("boolval2 : [", cfg.get!bool("boolval2"),  ']');
    assert(true ==  cfg.get!bool("boolval2") );

    writeln("boolval0 : [", cfg.get!bool("boolval0"), ']');
    assert(false == cfg.get!bool("boolval0") );

    // How to extend
    {
        import iniconfigs.inivalue : IniValue;
        import std.conv : to;
        static struct A1 {
            int a = 5;
            this(IniValue v)
            {
                this.a = v.toString.to!int;
            }
        }
        static struct A2 {
            int a = 7;
            void opAssign(IniValue v)
            {
                this.a = v.toString.to!int;
            }
        }

        writeln('[', cfg.get!A1("value1"), ']');
        assert( 1 == cfg.get!A1("value1").a );
        writeln('[', cfg.get!A1("value1+"), ']');
        assert( 5 == cfg.get!A1("value1+").a );
        writeln('[', cfg.get("value1", A1()), ']');
        assert( 1 == cfg.get("value1", A1()).a );
        writeln('[', cfg.get("value1+", A1()), ']');
        assert( 5 == cfg.get("value1+", A1()).a );

        writeln('[', cfg.get!A2("value1"), ']');
        assert( 1 == cfg.get!A2("value1").a );
        writeln('[', cfg.get!A2("value1+"), ']');
        assert( 7 == cfg.get!A2("value1+").a );
        writeln('[', cfg.get("value1", A2()), ']');
        assert( 1 == cfg.get("value1", A2()).a );
        writeln('[', cfg.get("value1+", A2()), ']');
        assert( 7 == cfg.get("value1+", A2()).a );

        //
        // Indirectly passing:
        //
        static struct C {
            int a = 5;
        }
        static struct D {
            int a;
            this(IniValue v)
            {
                this.a = v.toString.to!int;
            }
            this(C c)
            {
                this.a = c.a;
            }
            C castToC() const
            {
                return C(this.a);
            }
            alias castToC this;
        }
        static struct E {
            int a;
            this(IniValue v)
            {
                this.a = v.toString.to!int;
            }
            C castToC() const
            {
                return C(this.a);
            }
            alias castToC this;
        }

        C c1 = cfg.get!D("value1");
        C c2 = cfg.get!E("value1");
        C c3 = cfg.get("value1+", cast(D) C(3));

        writeln('[', c1, ']');
        assert( 1 == c1.a );
        writeln('[', c2, ']');
        assert( 1 == c2.a );
        writeln('[', c3, ']');
        assert( 3 == c3.a );


    }
}
