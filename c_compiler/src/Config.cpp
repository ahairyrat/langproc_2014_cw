

#include "Config.h"

#include <iostream>

///////////////////////////////////////////////////
//Definition of all global config vraiables
bool DISPLAYAST = false;

///////////////////////////////////////////////////

std::map<std::string, configFunctionPtr> configFunctions;

bool stob(std::string input);

//Decleration of all config functions
void configAST(std::string input);


//Function to add all config functions to map
void initialiseConfigs()
{
	configFunctions["AST"] = &configAST;
}

//
void configAST(std::string input){
	DISPLAYAST = stob(input);
	std::cout << "Set DISPLAYAST to: " << DISPLAYAST << std::endl;
}

bool stob(std::string input)
{
	if (input.compare("true"))
		return true;
	return false;
}