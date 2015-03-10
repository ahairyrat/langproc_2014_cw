
#include "Parser.h"
#include <map>

std::map<std::string, std::string>customTypes;

void CheckCustomTypes(){

	for (int i = 0; i < tokens.size(); i++)
	{
		if (tokens[i].name == TYPEDEF_T)
		{
			if (i + 2 < tokens.size() && tokens[i + 1].name == TYPE_T && tokens[i + 2].name == ID_T)		//TO-DO add checks in case pointer/derefernce type/cosnt etc.
				customTypes[tokens[i + 2].Data] = tokens[i + 1].Data;		//Define a new custom type of name in the map and assign the defined type to it
			else
				throw InvalidArgumentException
		}
		if (tokens[i].name == STRUCT_T)
		{
			if (i + 1 < tokens.size() && tokens[i + 1].name == ID_T)		//TO-DO add checks in case pointer/derefernce type
				customTypes[tokens[i + 1].Data] = tokens[i + 1].Data;		//Define a new custom type of name in the map and assign the defined type to it
			else
				throw InvalidArgumentException
		}
		if (tokens[i].name == ID_T && customTypes.find(tokens[i].Data) != customTypes.end())	//If the token is a custom type, it will ahve been picked up as am ID. Here we check if it exists in the map and change its type accordingly
			tokens[i] = def(TYPE_T, tokens[i].name);
	}


}