
#ifndef __C_COMPILER_CONFIG
#define	__C_COMPILER_CONFIG

#include <map>
#include <string>

class Config{

public:
	//Add themselves to the map of config functions
	Config();

	virtual void configure(std::string);

	//remove themselves from the map of config functions
	~Config();

private:
	std::string name;

};

typedef void(Config::*configFunctionPtr)(std::string);

//Global map of all configuration functions
//Functions can add themselves to this at runtime
std::map<std::string, configFunctionPtr> configFunctions;


//Add themselves to the map of config functions
Config::Config(){
	configFunctions[name] = &Config::configure;
}

//remove themselves from the map of config functions
Config::~Config(){
	configFunctions.erase(name);
}

void Config::configure(std::string){

}


#endif