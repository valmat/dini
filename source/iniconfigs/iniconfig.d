// 
// 
// 

module iniconfigs.iniconfig;

/*
import std.range      : empty, popFront, front;
import std.traits     : isIterable;
import std.typecons   : Tuple, tuple, isTuple;
import std.meta       : staticMap;
*/
import std.algorithm.iteration: splitter;
import std.algorithm.iteration: joiner;
import std.range : enumerate;
//import std.array: array;
import std.string: indexOf, strip;

import std.functional : forward;

import std.stdio : writeln, File;

import std.conv : to;

import iniconfigs.inivalue;



class IniConfigsException : Exception
{
    
    this(size_t iniLine, string file = __FILE__, size_t line = __LINE__) {
        super("IniConfigs: syntax error in line: " ~ iniLine.to!string, file, line);
    }
}

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
        
        //return cast(T) IniValue!string(*cfg);
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
        
        //return cast(T) IniValue!string(*cfg);
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



// cd source 
// rdmd -unittest -main  iniconfigs/iniconfig
nothrow unittest {}