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
    void initSrc(string src) pure
    {   
        _ini.add(src);
    }


    // Automatically generates getters by fields of structure ConfigsDefault
    static foreach(enum string mmbr_name; __traits(allMembers, ConfigsDefault)) {
        mixin setField!mmbr_name;
    }
}


///////////////////////////////////////////////////////
// cd source 
// rdmd -unittest -main  dini/traits
unittest {
    string ini = `
        value1 = Some text           
        value2 = 9856428642
    `;

    static struct AppConfigsDefault
    {
        enum string value1 = "Ultimate Question of Life, the Universe, and Everything";
        enum size_t value2 = 42;
    }
    alias AppConfigs = ConfigsTrait!AppConfigsDefault;


    AppConfigs cfg;
    assert(cfg.value1 == AppConfigsDefault.value1);
    assert(cfg.value2 == AppConfigsDefault.value2);


    try {
        cfg.initSrc (ini);
    } catch (IniConfigsException e) {
        assert(0);
    }

    assert(cfg.value1 == "Some text");
    assert(cfg.value2 == 9856428642);
}
