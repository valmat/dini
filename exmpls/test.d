#!/usr/bin/rdmd --shebang=-I../source -I.

import std.stdio : writeln;

import iniconfigs.iniconfig;
//import iniconfigs.inivalue;


/*
string[string] add(string content)
{
    import std.algorithm.iteration: splitter;
    import std.range : enumerate;
    //import std.array: array;
    import std.string: indexOf, strip;

    string[string] _map;

    
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


    return _map;
}
*/

void main()
{
    string ini = `
        value1 = 1 ;value1 comment  
        value2 =     hello world        ;value2 comment

            value3 =     1.1

        value3 = 3.1415 5.1;value3 comment

        ;value4 comment
        value4 = 3.14159263358979361680130282241663053355296142399311

        ;dfgg

            ; this is a comment      
        value5=value5
            value6  =   value6
        ;   dfgdfgdgd   sdfs    s       
                    value7= Some text with spaces           

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

    //add(ini).writeln;
    



}