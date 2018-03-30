// 
// 
// 

module iniconfigs.inivalue;

import core.stdc.stdint : uint64_t, uint32_t, uint16_t, uint8_t, int64_t, int32_t, int16_t, int8_t;
import std.string : toLower;
import std.functional : forward;


struct IniValue(T)
{
public:
    
    /// Constructors
    this(auto ref T value)
    {
        _value(forwrd!value);
    }

    /// Cast to an object of type T
    T opCast(R: T) () const {return _value; }
    
    T get () const
    {
        return _value;
    }
    
private:
    /// default value
    T _value;
};


// Template specialization for string
struct IniValue(T : string)
{
public:
    
    // Constructor
    this(string value) 
    {
        this._value = value;
    }

    // Cast to a string
    string opCast(R = string) () const {return _value;}
    string toString           () const {return _value;}

    /// Casting to integer types

    auto opCast(R = uint64_t)    () const {return _value.to!uint64_t;     }
    auto opCast(R = uint32_t)    () const {return _value.to!uint32_t;     }
    auto opCast(R = uint16_t)    () const {return _value.to!uint16_t;     }
    auto opCast(R = uint8_t)     () const {return _value.to!uint8_t;      }

    auto opCast(R = int64_t)     () const {return _value.to!int64_t;      }
    auto opCast(R = int32_t)     () const {return _value.to!int32_t;      }
    auto opCast(R = int16_t)     () const {return _value.to!int16_t;      }
    auto opCast(R = int8_t)      () const {return _value.to!int8_t;       }

    /// Casting to float types
    auto opCast(R = float)       () const {return _value.to!float;        }
    auto opCast(R = double)      () const {return _value.to!double;       }
    //auto opCast(R = long double) () const {return _value.to!(long double);}

    /// Cast to a bool
    auto opCast(R = bool)() const
    {
        string v = _value.toLower();
        return ("true" == v || "1" == v || "on" == v);
    }

    /// Cast to nullptr_t
    auto opCast(R = typeof(null))() const {return null;}
    
    /// Cast to some custom type
    //template <typename T>
    //operator IniValue<T> () const;

private:
    
    // string value
    string _value;
};

alias IniValueString = IniValue!string;



// cd source 
// rdmd -unittest -main  iniconfigs/inivalue
nothrow unittest {}