// 
// 
// 

module dini.iniconfig;

import std.algorithm  : splitter, joiner;
import std.range      : enumerate;
import std.string     : indexOf, strip;
import std.functional : forward;
import std.stdio      : File;
import std.conv       : to;

import dini.inivalue;

struct IniConfigs
{
public:
    /// Constructors
    this(string content) pure
    {
        this.add(content);
    }
    this(File file)
    {
        this.add(file);
    }

    /// assignment
    void opAssign(string content) pure
    {
        this.add(content);
    }
    void opAssign(File file)
    {
        this.add(file);
    }

    /// add file
    void add(File file)
    {
        this.add(file.byLine().joiner("\n").to!string);
    }
    /// add content
    void add(string content) pure
    {
        size_t npos = size_t(-1);

        foreach(lineNum, ref line; content.splitter("\n").enumerate(1)) {
            size_t pos = line.indexOf(';');
            
            // remove comment & trim
            line = ( npos > pos ) ? line = line[0..pos].strip() : line.strip();

            if( null == line ) {
                continue;
            }

            // parse key and value
            pos = line.indexOf('=');
            if( npos > pos ) {
                string key   = line[  0 .. pos  ].strip();
                string value = line[ pos+1 .. $ ].strip();
                if(value.length > 1 && '"' == value[0] && '"' == value[$-1]) {
                    value = value[1..$-1];
                }

                _map[key] = value;
            } else {
                throw new IniConfigsException(lineNum);
            }
        }
    }

    /// Get ini entry
    T get(T)(const string key, auto ref T dfltValue, bool noEmpty = true) const
    {
        const string* cfg = (key in _map);

        // if key not exists
        if(cfg is null) {
            return dfltValue;
        }

        // check if config value string is empty
        if(noEmpty && null == *cfg) {
            return dfltValue;
        }

        //return cast(T) IniValue(*cfg);
        return IniValue(*cfg).to!T;
    }

    /// Get ini entry
    T get(T)(auto ref string key) const
    {
        const string* cfg = (key in _map);

        // if key not exists or config value string is empty return default
        if(!cfg || null == *cfg) {
            return T.init;
        }
        
        //return cast(T) IniValue(*cfg);
        return IniValue(*cfg).to!T;
    }

    /// Check if ini entry exists
    bool has()(auto ref string key) const @safe nothrow
    {
        return (key in _map) !is null;
    }

    /// Check if ini configs has not entries
    bool empty() const @nogc pure @safe nothrow
    {
        return !_map.length;
    }

    /// Returns counts of ini entries
    size_t size() const @nogc pure @safe nothrow
    {
        return _map.length;
    }
    size_t length() const @nogc pure @safe nothrow
    {
        return _map.length;
    }

    string[] keys() const pure @safe nothrow
    {
        return _map.keys();
    }

private:
    string[string] _map;
};

// Ini parse exception
class IniConfigsException : Exception
{
    this(size_t iniLine, string file = __FILE__, size_t line = __LINE__) pure @safe
    {
        super("IniConfigs: syntax error in line: " ~ iniLine.to!string, file, line);
    }
    this(string msg) pure @safe
    {
        super(msg);
    }
}



///////////////////////////////////////////////////////
// cd source 
// rdmd -unittest -main  dini/iniconfig
unittest {
    import std.math  : approxEqual;

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

    assert(cfg.empty());
    assert(!cfg.size());

    try {
        cfg = ini;
    } catch (IniConfigsException e) {
        assert(0, e.msg);
    }


    assert(!cfg.empty());
    assert(17 == cfg.size());

    cfg.add(`
        value9 = 15
        value10 =  -15        
    `);

    assert(19 == cfg.size());

    assert(15 == cfg.get!ubyte  ("value9"));
    assert(15 == cfg.get!ushort ("value9"));
    assert(15 == cfg.get!uint   ("value9"));
    assert(15 == cfg.get!ulong  ("value9"));

    assert(-15 == cfg.get!byte   ("value10"));
    assert(-15 == cfg.get!int    ("value10"));
    assert(-15 == cfg.get!short  ("value10"));
    assert(-15 == cfg.get!long   ("value10"));
    

    assert( approxEqual(3.1415, cfg.get!float  ("value3")) );
    assert( approxEqual(3.1415, cfg.get!double ("value3")) );
    assert( approxEqual(3.1415, cfg.get!real   ("value3")) );

    assert( approxEqual(3.14159263358979361680130282241663053355296142399311, cfg.get!float  ("value4"), 1e-20) );
    assert( approxEqual(3.14159263358979361680130282241663053355296142399311, cfg.get!double ("value4"), 1e-40) );
    assert( approxEqual(3.14159263358979361680130282241663053355296142399311, cfg.get!real   ("value4"), 1e-60) );

    
    const string name1  = "value1";
    const string name1_ = "value1_";
    int val1  = cfg.get(name1,  5);
    int val1_ = cfg.get(name1_, 5);

    assert(1 == val1);
    assert(5 == val1_);

    assert("hello world"   == cfg.get!string("value2",  "default value") );
    assert("default value" == cfg.get!string("value2+", "default value") );

    
    assert("3.1415" == cfg.get!string("value3"));
    assert(""       == cfg.get!string("value3+"));
    
    assert(approxEqual(3.1415, cfg.get("value3",  2.718281828459)));
    assert(approxEqual(2.71828,cfg.get("value3+", 2.718281828459)));
    assert(approxEqual(3.14159,cfg.get("value4",  2.718281828459)));

    assert(cfg.has("value3"));
    assert(!cfg.has("value3+"));

    assert("Some text with spaces" == cfg.get!string("value7", "value7"));
    assert(" Some text with spaces      " == cfg.get!string("value7+"));
    cfg.add(`empty_str = ""`);
    assert("" == cfg.get!string("empty_str") );


    assert(985642     == cfg.get("value8_", 0) );
    assert(9856428642 == cfg.get("value8", size_t(0)) );
    assert(9856428642 == cfg.get!size_t("value8", 0) );


    assert(false == cfg.get("boolval0", false) );
    assert(true  == cfg.get("boolval1", false) );
    assert(true  == cfg.get("boolval2", false) );
    assert(true  == cfg.get("boolval3", false) );

    assert(false == cfg.get("boolval4", true) );
    assert(false == cfg.get("boolval5", true) );
    assert(false == cfg.get("boolval6", true) );
    assert(false == cfg.get("boolval7", true) );

    assert(true ==  cfg.get!bool("boolval2") );
    assert(false == cfg.get!bool("boolval0") );
}


unittest {
    
    import dini.inivalue : IniValue;
    import std.conv : to;

    IniConfigs cfg = "value1 = 1";

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

    assert( 1 == cfg.get!A1("value1").a );
    assert( 5 == cfg.get!A1("value1+").a );
    assert( 1 == cfg.get("value1", A1()).a );
    assert( 5 == cfg.get("value1+", A1()).a );

    assert( 1 == cfg.get!A2("value1").a );
    assert( 7 == cfg.get!A2("value1+").a );
    assert( 1 == cfg.get("value1", A2()).a );
    assert( 7 == cfg.get("value1+", A2()).a );

    //
    // Indirectly passing:
    //
    static struct C {
        int a = 5;
    }
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

    assert( 1 == c1.a );
    assert( 1 == c2.a );
    assert( 3 == c3.a );

}