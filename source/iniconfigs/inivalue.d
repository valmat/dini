// 
// 
// 

module iniconfigs.inivalue;

import std.string : toLower;
import std.conv   : to;
import std.traits : isNumeric, isUnsigned;

import std.stdio;

struct IniValue
{
public:
    /// Constructor
    this(string value) 
    {
        this._value = value;
    }

    /// Cast to a string
    string opCast(R : string)() const
    {
        //writeln("~~~~~~~~~~~~");
        //writeln("\t",[_value]);
        //writeln("~~~~~~~~~~~~");

        return _value;
    }

    /// Casting to integer and float types
    auto opCast(R)() const
        if(isNumeric!R || isUnsigned!R)
    {
        
        //writeln("------------");
        //writeln("\t",[typeof(_value).stringof]);
        //writeln("\t",[_value]);
        //writeln("\t",R.stringof);
        //writeln("------------");
        return _value.to!R;
    }

    /// Cast to a bool
    auto opCast(R : bool) () const
    {
        //writeln("++++++++++++");
        //writeln("\t",[_value]);
        //writeln("++++++++++++");
        string v = _value.toLower();
        return ("true" == v || "1" == v || "on" == v);
    }
    
private:
    string _value;
};

// cd source 
// rdmd -unittest -main  iniconfigs/inivalue
nothrow unittest {}