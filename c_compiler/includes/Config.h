
#ifndef __C_COMPILER_CONFIG
#define	__C_COMPILER_CONFIG

#include <map>
#include <string>

//////////////////////////////////////////////////
//List of all global config modifiers
extern bool DISPLAYAST;





/////////////////////////////////////////////////

typedef void(*configFunctionPtr)(std::string);

//Global map of all configuration functions
//Functions can add themselves to this at runtime
extern std::map<std::string, configFunctionPtr> configFunctions;

void initialiseConfigs();

#endif