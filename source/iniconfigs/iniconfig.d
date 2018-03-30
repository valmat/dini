// 
// 
// 

module iniconfigs.iniconfig;

import std.algorithm  : splitter, joiner;
import std.range      : enumerate;
import std.string     : indexOf, strip;
import std.functional : forward;
import std.stdio      : File;
import std.conv       : to;

import iniconfigs.inivalue;

struct IniConfigs
{
public:
    /// Constructors
    this(string content)
    {
        this.add(content);
    }
    this(File file)
    {
        this.add(file);
    }

    /// assignment
    void opAssign(string content)
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
    void add(string content)
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
        const string* cfg = (forward!key in _map);

        // if key not exists
        if(cfg is null) {
            return forward!dfltValue;
        }

        // check if config value string is empty
        if(noEmpty && null == *cfg) {
            return forward!dfltValue;
        }

        return cast(T) IniValue(*cfg);
    }

    /// Get ini entry
    T get(T)(auto ref string key) const
    {
        const string* cfg = forward!key in _map;
        // if key not exists or config value string is empty return default
        if(!cfg || null == *cfg) {
            return T.init;
        }

        import std.stdio;
        //writeln("**************");
        //writeln("\t",[typeof(*cfg).stringof]);
        //writeln("\t",[*cfg]);
        //writeln("**************");

        
        return cast(T) IniValue(*cfg);
    }

    /// Check if ini entry exists
    bool has()(auto ref string key) const
    {
        return (key in _map) !is null;
    }

    /// Check if ini configs has not entries
    bool empty() const
    {
        return !_map.length;
    }

    /// Returns counts of ini entries
    size_t size() const
    {
        return _map.length;
    }
    size_t length() const
    {
        return _map.length;
    }

private:
    string[string] _map;
};


class IniConfigsException : Exception
{
    this(size_t iniLine, string file = __FILE__, size_t line = __LINE__) {
        super("IniConfigs: syntax error in line: " ~ iniLine.to!string, file, line);
    }
}


// cd source 
// rdmd -unittest -main  iniconfigs/iniconfig
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