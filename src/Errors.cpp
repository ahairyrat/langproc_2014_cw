#include "Errors.h"

#include <iostream>
#include <string>
#include <cstring>
#include <sstream>
#include <fstream>

std::string infileName;

void printError(const char* error_message, bool end, int linenum) {
	if (!end) {
		std::cerr << infileName << '(' << linenum << ") " << "Error: "
				<< error_message << " at\t";
		if (infileName != "NULL") {
			std::ifstream infile;
			infile.open(infileName.c_str(), std::ifstream::in);

			std::string problemString;
			int i = linenum;
			while (!infile.eof() && i > 0) {
				i--;
				getline(infile, problemString);
			}
			std::cerr << problemString;
			infile.close();
		}
		std::cerr << std::endl;
	} else
		std::cerr << infileName << ' ' << "Error: " << error_message
				<< std::endl;
}

void printWarning(const char* error_message, bool end, int linenum) {
	if (!end) {
		std::cout << infileName << '(' << linenum << ") " << "Warning: "
				<< error_message << " at\t";
		if (infileName != "NULL") {
			std::ifstream infile;
			infile.open(infileName.c_str(), std::ifstream::in);

			std::string problemString;
			int i = linenum;
			while (!infile.eof() && i > 0) {
				i--;
				getline(infile, problemString);
			}
			std::cout << problemString;
			;
			infile.close();
		}
		std::cout << std::endl;
	} else
		std::cout << infileName << ' ' << "Warning: " << error_message
				<< std::endl;
}

void printFileMissing() {
	std::cerr << infileName << ": Does not exist" << std::endl;
}
