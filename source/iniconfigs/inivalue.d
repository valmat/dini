// 
// 
// 

module iniconfigs.inivalue;

import core.stdc.stdint : uint64_t, uint32_t, uint16_t, uint8_t, int64_t, int32_t, int16_t, int8_t;
import std.string : toLower;
import std.functional : forward;

import std.conv : to;

import std.traits;


struct IniValue
{
public:
    /// Constructor
    this(string value) 
    {
        this._value = value;
    }

    /*
    /// Cast to a string
    string opCast(R : string)    () const { return _value;             }

    /// Casting to integer types
    //auto opCast(R : int)    () const { return _value.to!int; }
    auto opCast(R : uint64_t)    () const { return _value.to!uint64_t; }
    auto opCast(R : uint32_t)    () const { return _value.to!uint32_t; }
    auto opCast(R : uint16_t)    () const { return _value.to!uint16_t; }
    auto opCast(R : uint8_t)     () const { return _value.to!uint8_t;  }

    auto opCast(R : int64_t)     () const { return _value.to!int64_t;  }
    auto opCast(R : int32_t)     () const { return _value.to!int32_t;  }
    auto opCast(R : int16_t)     () const { return _value.to!int16_t;  }
    auto opCast(R : int8_t)      () const { return _value.to!int8_t;   }
    */


    string opCast(R : string)() const
    {
        return _value;
    }


    /*
    auto opCast(R)() const
        if(is(R : double))
    {
        return _value.to!R;
    }
    */

    auto opCast(R)() const
        if(isNumeric!R || isUnsigned!R)
    {
        return _value.to!R;
    }

    

    /// Casting to float types
    //auto opCast(R : float)       () const { return _value.to!float;    }
    //auto opCast(R : double)      () const { return _value.to!double;   }
    //auto opCast(R : real)        () const { return _value.to!(real);   }


    /*
    auto opCast(R : uint64_t)    () const { return _value.to!uint64_t; }
    auto opCast(R : uint32_t)    () const { return _value.to!uint32_t; }
    auto opCast(R : uint16_t)    () const { return _value.to!uint16_t; }
    auto opCast(R : uint8_t)     () const { return _value.to!uint8_t;  }

    auto opCast(R : int64_t)     () const { return _value.to!int64_t;  }
    auto opCast(R : int32_t)     () const { return _value.to!int32_t;  }
    auto opCast(R : int16_t)     () const { return _value.to!int16_t;  }
    auto opCast(R : int8_t)      () const { return _value.to!int8_t;   }
    */

    /// Casting to float types
    //auto opCast(R : float)       () const { return _value.to!float;    }
    //auto opCast(R : double)      () const { return _value.to!double;   }
    //auto opCast(R : real)        () const { return _value.to!(real);   }


    /// Cast to a bool
    auto opCast(R : bool) () const
    {
        string v = _value.toLower();
        return ("true" == v || "1" == v || "on" == v);
    }
    
private:
    string _value;
};

// cd source 
// rdmd -unittest -main  iniconfigs/inivalue
nothrow unittest {}