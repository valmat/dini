// 
// 
// 

module dini.inivalue;

import std.conv   : to;
import std.traits : isNumeric, isUnsigned;

struct IniValue
{
public:
    /// Constructor
    this(string value) nothrow @nogc pure @safe
    {
        this._value = value;
    }

    string toString() const nothrow @nogc pure @safe
    {
        return _value;
    }

    T to(T)() const
        if( isConstructable!T.With!IniValue )
    {
        return T(this);
    }
    T to(T)() const
        if( !isConstructable!T.With!IniValue && isAssignable!T.With!IniValue )
    {
        T t;
        t = this;
        return t;
    }
    T to(T)() const
        if( !isConstructable!T.With!IniValue && !isAssignable!T.With!IniValue )
    {
        return cast(T) this;
    }

    /// Cast to a string
    string opCast(R : string)() const @nogc pure @safe
    {
        return _value;
    }

    /// Casting to integer and float types
    auto opCast(R)() const pure @safe
        if(isNumeric!R || isUnsigned!R)
    {
        return _value.to!R;
    }

    /// Cast to a bool
    auto opCast(R : bool) () const pure @safe
    {
        import std.string : toLower;
        string v = _value.toLower();
        return ("true" == v || "1" == v || "on" == v);
    }
    
private:
    string _value;
};


private template isConstructable(T) {
    template With(R) {
        enum bool With = __traits(compiles, typeof(T(R.init)) );
    }
}

private template isAssignable(T) {
    template With(R) {
        enum bool With = __traits(compiles, typeof(T.init.opAssign(R.init)) );
    }
}




///////////////////////////////////////////////////////
// cd source 
// rdmd -unittest -main  dini/inivalue
nothrow unittest {

    struct B1 {
        this(IniValue v) {}
    }
    struct B2 {
        void opAssign(IniValue v) {}
    }

    //pragma(msg,  "isConstructable!B1.With!IniValue");
    //pragma(msg,  isConstructable!B1.With!IniValue);
    static assert(isConstructable!B1.With!IniValue);

    //pragma(msg,  "isConstructable!B2.With!IniValue");
    //pragma(msg,  isConstructable!B2.With!IniValue);
    static assert(!isConstructable!B2.With!IniValue);

    //pragma(msg,  "isAssignable!B1.With!IniValue");
    //pragma(msg,  isAssignable!B1.With!IniValue);
    static assert(!isAssignable!B1.With!IniValue);

    //pragma(msg,  "isAssignable!B2.With!IniValue");
    //pragma(msg,  isAssignable!B2.With!IniValue);
    static assert(isAssignable!B2.With!IniValue);
}