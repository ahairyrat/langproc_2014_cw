
#define USECONGFIGFILE true

#include "Config.h"
#include "Lexer.h"
#include "Parser.h"
#include "Translator.h"

#include <fstream>
#include <iostream>
#include <string>

using namespace std;

void loadConfigurations(ifstream &configFile);

int main()
{
	if (USECONGFIGFILE)
	{
		initialiseConfigs();
		ifstream configFile;
		configFile.open("config.ini");
		if (!configFile.is_open())
		{
			cout << "No configuration file found\nUsing defaults" << endl;
		}
		else
			loadConfigurations(configFile);

		configFile.close();
	}

	getchar();
	return 0;
}

void loadConfigurations(ifstream &configFile)
{
	std::string line, cmd, value;
	int cmdEnd;
	while (getline(configFile, line))
	{
		cmdEnd = line.find(' ');
		if (cmdEnd < 0)
			break;
		cmd = line.substr(0, cmdEnd);
		value = line.substr(cmdEnd);
		configFunctions[cmd](value);
	}
}