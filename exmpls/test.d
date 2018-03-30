#!/usr/bin/rdmd --shebang=-I../source -I.

import std.stdio : writeln;

import core.stdc.stdint : uint64_t, uint32_t, uint16_t, uint8_t, int64_t, int32_t, int16_t, int8_t;

import iniconfigs.iniconfig;
//import iniconfigs.inivalue;

/*
struct A {
    int    i = 5;
    string s = "sdfsdf";
    float  f = 3.14;

    auto opCast(R = int)() const {return i;}
    auto opCast(R = float)() const {return f;}

    auto opCast_int() const {return i;}
    auto opCast_float() const {return f;}

    //alias opCast_int   this;
    //alias opCast_float this;
    
    //alias i this;
    //alias f this;

    //alias i, f  this;

}

struct A {
    int   i = 5;
    float f = 3.14;
    alias i this;
    alias f this;
}
*/

void main()
{
    
    /*
    A a;
    //int i = cast(size_t) a;
    int   i = a;
    float f = a;

    writeln(i);
    */


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

    ini.writeln;

    IniConfigs cfg;


    try {
        cfg = ini;
    } catch (IniConfigsException e) {
        writeln(e.msg);
        return;
    }

    cfg.writeln;


    const string name1  = "value1";
    const string name1_ = "value1_";
    int val1  = cfg.get(name1,  5);
    int val1_ = cfg.get(name1_, 5);

    writeln("[", name1, " ]: [", val1 , ']');
    writeln("[", name1_, "]: [", val1_, ']');

    writeln("[value2  ]: [", cfg.get!string("value2",  "default value") , ']');
    writeln("[value2+ ]: [", cfg.get!string("value2+", "default value") , ']');
    
    writeln("[value3  ]: [", cfg.get!string("value3") ,  ']');
    writeln("[value3+ ]: [", cfg.get!string("value3+") , ']');

    
    writeln( "[value3  ] :[ ", cfg.get("value3",  2.718281828459), ']');
    writeln( "[value3+ ] :[ ", cfg.get("value3+", 2.718281828459), ']');
    writeln( "[value4  ] :[ ", cfg.get("value4",  2.718281828459), ']');


    writeln("Has `value3`?  ", cfg.has("value3")  );
    writeln("Has `value3+`? ", cfg.has("value3+") );

    writeln("value4 :", cfg.get!float  ("value4",  2.718281828459) );
    writeln("value4 :", cfg.get!double ("value4",  2.718281828459) );

    auto value5 =  cfg.get!string("value5", "value5");
    auto value6 =  cfg.get!string("value6", "value6");
    writeln("value4 : [", value5, ']');
    writeln("value4 : [", value6, ']');


    writeln("value7 : [", cast(string) cfg.get!string("value7", "value7"), ']');
    writeln("value7 : [", cfg.get!string("value7", "value7"), ']');

    writeln("value8 : [", cfg.get("value8_", 0), ']');
    writeln("value8 : [", cfg.get("value8", size_t(0)), ']');
    writeln("value8 : [", cfg.get!size_t("value8", 0), ']');


    writeln("boolval0 : [", cfg.get("boolval0", false), ']');

    writeln("boolval1 : [", cfg.get("boolval1", false), ']');
    writeln("boolval2 : [", cfg.get("boolval2", false), ']');
    writeln("boolval3 : [", cfg.get("boolval3", false), ']');

    writeln("boolval4 : [", cfg.get("boolval4", true),  ']');
    writeln("boolval5 : [", cfg.get("boolval5", true),  ']');
    writeln("boolval6 : [", cfg.get("boolval6", true),  ']');
    writeln("boolval7 : [", cfg.get("boolval7", true),  ']');

    writeln("Is ini configs empty? ", cfg.empty());
    writeln("Ini entries number:  ", cfg.size());

    //writeln('[', cfg.get("value1",  A()).get().a, ']');
    //writeln('[', cfg.get("value1+", A()).get().a, ']');


}