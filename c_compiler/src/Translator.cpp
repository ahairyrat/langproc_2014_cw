#include "../includes/Errors.h"
#include "../includes/Translator.h"
#include <sstream>
#include <cstdlib>
#include <iostream>

union FloatingPointSinglePrecisionIEEE754 {
    struct {
        unsigned int mantissa : 23;
        unsigned int exponent : 8;
        unsigned int sign : 1;
    } raw;
    float f;
} fnumber;

Translator::Translator(abstractNode* &root, std::string outputFile) :
root(root), tempVal(0) {

	codeGenerator = new CodeGenerator(outputFile);
	registerManager = new RegisterManager(codeGenerator);
}
;

Translator::~Translator() {
	delete registerManager;
	delete codeGenerator;
}
;

void Translator::setRoot(abstractNode* root) {
	this->root = root;
}
;

bool Translator::translate() {
	std::cout << "Generating code" << std::endl;
	return translateNode (root);	
}
;

bool Translator::translateNode(abstractNode* node) {
	Node* currNode = (Node*) node;
	std::cout << currNode -> id << ' ' << currNode -> node_type << std::endl;
	if (currNode->node_type == "parserNode" && currNode->id == NULL_T) {
		std::cout << "Found branch" << std::endl;
		parserNode* currNodeEx = (parserNode*) currNode;
		if (currNodeEx->LHS)
			if (!translateNode(currNodeEx->LHS))
				return false;
		std::cout << "Translated LHS" << std::endl;
		if (currNodeEx->RHS)
			if (!translateNode(currNodeEx->RHS))
				return false;
		std::cout << "Translated RHS" << std::endl;
		return true;
	} else if (currNode->node_type == "parserNode"
			&& currNode->id == EXPR_T) {
		std::cout << "Found expression" << std::endl;
		parserNode* currNodeEx = (parserNode*) currNode;
		if (currNodeEx->LHS)
			if (!translateNode(currNodeEx->LHS))
				return false;
		std::cout << "Translated LHS" << std::endl;
		if (currNodeEx->RHS)
			if (!translateNode(currNodeEx->RHS))
				return false;
		std::cout << "Translated RHS" << std::endl;
		int rt = registerManager->allocate((((Node*) currNodeEx->LHS))->val);
		int r1 = registerManager->allocate((((Node*) currNodeEx->RHS))->val);
		switch(((Node*)(currNodeEx -> OP)) -> id)
		{
		case ASSIGN_T:
			codeGenerator->write(MOV_ASM, rt, r1, 0);
			break;
		/****************************
		case LOGICOP_T:
			
			 * 
			 * 
			 * Add code for different binary operators
			 * 
			 */
		}
		return true;
	} else if (currNode->node_type == "variableNode") {
		std::cout << "Found variable" << std::endl;
		variableNode* currNodeVar = (variableNode*) ((typeNode*) currNode);
		if (currNodeVar->id == CONST_T) {
			std::string val = generateTempName(currNode);
			int rt = registerManager->allocate(currNodeVar->val);
			if (currNodeVar->type->name == "int") {
				int num;
				if (val.size() >= 3) {
					std::string base = val.substr(0, 2);
					//if this returns false, the base used is not decimal
					if (base == "0x") {
						//The base was hexadecimal
						num = strtol(val.substr(2).c_str(), NULL,
								16);
					} else if (base == "0b") {
						//The base was binary
						num = strtol(val.substr(2).c_str(), NULL,
								2);
					} else if (base == "00") {
						//The base was octal
						num = strtol(val.substr(2).c_str(), NULL,
								8);
					} else if (!isdigit(base[2])) {
						//The base was invalid
						printError("Invalid base for integer", false,
								currNode->linenum);
						return false;
					} else {
						//The base was decimal
						num = strtol(val.substr(2).c_str(), NULL,
								10);
					}
				} else {
					num = strtol(val.c_str(), NULL, 10);
				}
				std::cout << "Completed base conversion" << std::endl;
				codeGenerator->write(MOVI_ASM, rt, num, 0);
				return true;
			} else if (currNodeVar->type->name == "float") {

				fnumber.f = atof(val.c_str());
				std::stringstream ss;
				int x = (fnumber.raw.sign << 31) + ( fnumber.raw.exponent << 23) + fnumber.raw.mantissa;
				std::cout << x << std::endl;
				codeGenerator->write(MOVI_ASM, rt, x, 0);
				return true;
			}
		}else if(currNodeVar->id == VAR_T)
		{
			//If a variable is found, making sure that it is in the register bank is enough
			registerManager->allocate(currNodeVar->val);
			return true;
		}
	}
	return false;
}
;

std::string Translator::generateTempName(abstractNode* node)
{
	Node* currNode = (Node*)node;
	std::string val = currNode -> val;
	std::stringstream ss;
	ss << "temp" << tempVal;
	tempVal++;
	currNode->val = ss.str();
	return val;
}
;
