

#include <iostream>
#include <string>
#include <cstring>
#include <sstream>
#include <fstream>

extern std::string infileName;

void printError(const char* error_message, bool end);

void printWarning(const char* error_message, bool end);

void printFileMissing();
