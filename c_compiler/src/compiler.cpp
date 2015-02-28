
#define USECONGFIGFILE true

#include "Config.h"
#include "Lexer.h"
#include "Parser.h"
#include "Translator.h"

#include <fstream>
#include <string>

using namespace std;

int main()
{
	if (USECONGFIGFILE)
	{
		ifstream configFile;
		configFile.open("compiler.ini");
		//loadConfigurations(configFile, configFunctions);
		configFile.close();
	}
	return 0;
}