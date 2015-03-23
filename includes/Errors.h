#ifndef __C_COMPILER_ERRORS_H
#define __C_COMPILER_ERRORS_H

extern std::string infileName;

void printError(const char* error_message, bool end, int linenum);

void printWarning(const char* error_message, bool end, int linenum);

void printFileMissing();

#endif
