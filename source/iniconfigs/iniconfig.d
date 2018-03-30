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
        writeln( "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~" );
        
        size_t npos = size_t(-1);
        writeln( [npos] );
        writeln( "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~" );


        foreach(lineNum, ref line; content.splitter("\n").enumerate(1)) {

            size_t pos = line.indexOf(';');
            
            writeln( [pos] );

            // remove comment
            if( npos > pos ) {
                line = line[0..pos];
            }
            // trim
            line = line.strip();

            if( null == line ) {
                continue;
            }

            writeln( [line], [lineNum] );


            // parse key and value
            pos = line.indexOf('=');
            if( npos > pos ) {
                string key   = line[  0 .. pos  ].strip();
                string value = line[ pos+1 .. $ ].strip();
                writeln( [key, value] );

                _map[key] = value;

            } else {
                throw new IniConfigsException(lineNum);
            }
        }
    }

nothrow:

    /// Get ini entry
    template get(T){
    IniValue!T get(auto ref string key, auto ref T dfltValue, bool noEmpty = true) const
    {
        auto cfg = forwrd!key in _map;
        // if key not exists
        if(!cfg) {
            return IniValue!T(forwrd!dfltValue);
        }

        // check if config value string is empty
        if(noEmpty && null == *cfg) {
            return IniValue!T(forwrd!dfltValue);
        }
        
        return IniValue!string(*cfg);
    }}

    /// Get ini entry
    template get(T){
    IniValue!T get(auto ref string key) const
    {
        auto cfg = forwrd!key in _map;
        // if key not exists or config value string is empty return default
        if(!cfg || null == *cfg) {
            return IniValue!T(T.init);
        }
        
        return IniValue!string(*cfg);
    }}

    /// Check if ini entry exists
    bool has()(auto ref string key) const
    {
        return key in _map;
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