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

    string toString() const
    {
        return _value;
    }

    
    T to(T)() const
        if( __traits(compiles, typeof(T(IniValue.init)) ) )
    {
        //T t;
        //t = this;
        //T(this)
        return T(this);
    }

    T to(T)() const
        if( !__traits(compiles, typeof(T(IniValue.init)) ) )
    {
        return cast(T) this;
    }
    


    /*
    static if( __traits(compiles, T(IniValue.init) ) ) {
        pragma(msg, __traits(compiles, T(IniValue.init) ) );
        pragma(msg, __traits(compiles, T(IniValue.init) ) );

        T to(T)() const
        {
            return T(this);
        }
    } else {
        T to(T)() const
        {
            return cast(T) this;
        }
    }
    */



    /*
    writeln(__traits(compiles));                      // false
    writeln(__traits(compiles, foo));                 // true
    writeln(__traits(compiles, foo + 1));             // true
    writeln(__traits(compiles, &foo + 1));            // false
    writeln(__traits(compiles, typeof(1)));           // true
    writeln(__traits(compiles, S.s1));                // true
    writeln(__traits(compiles, S.s3));                // false
    writeln(__traits(compiles, 1,2,3,int,long,std));  // true
    writeln(__traits(compiles, 3[1]));                // false
    writeln(__traits(compiles, 1,2,3,int,long,3[1])); // false
    */

    

    /// Cast to a string
    string opCast(R : string)() const
    {
        return _value;
    }

    /// Casting to integer and float types
    auto opCast(R)() const
        if(isNumeric!R || isUnsigned!R)
    {
        return _value.to!R;
    }

    /// Cast to a bool
    auto opCast(R : bool) () const
    {
        string v = _value.toLower();
        return ("true" == v || "1" == v || "on" == v);
    }
    
private:
    string _value;
};

/*
private {
opAssign(IniValue v)


    bool enum isConstructableWith
    opAssign(IniValue v)

        T to(T)() const
            if( !__traits(compiles, typeof(T(IniValue.init)) ) )
        {
            return cast(T) this;
        }
}
*/

// cd source 
// rdmd -unittest -main  iniconfigs/inivalue
nothrow unittest {}