// 
// 
// 

module dini.traits;

import std.file       : FileException;
import std.stdio      : File;
import dini.iniconfig : IniConfigs, IniConfigsException;

private
mixin template setField(string fname)
{
    // retrieves configuration field from file or assigns it by default
    mixin( `auto ` ~ fname ~ `() const {return _ini.get("` ~ fname ~ `", dflt.` ~ fname ~ `);}` );
}


struct ConfigsTrait(ConfigsDefault)
{
private:
    alias dflt = ConfigsDefault;
    IniConfigs _ini;

public:

    void init(string ini_filename) 
    {   
        try {
            _ini.add(File(ini_filename));
        } catch (FileException e) {
            throw new IniConfigsException(e.msg);
        }
    }
    void init(File ini_file) 
    {   
        _ini.add(ini_file);
    }


    // Automatically generates getters by fields of structure ConfigsDefault
    static foreach(enum string mmbr_name; __traits(allMembers, ConfigsDefault)) {
        //pragma(msg, mmbr_name);
        mixin setField!mmbr_name;
    }
}