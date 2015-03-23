#include "Errors.h"
#include "Translator.h"
#include <sstream>
#include <cstdlib>
#include <iostream>

union FloatingPointSinglePrecisionIEEE754 {
	struct {
		unsigned int mantissa :23;
		unsigned int exponent :8;
		unsigned int sign :1;
	} raw;
	float f;
} fnumber;

Translator::Translator(abstractNode* &root, std::string outputFile) :
		root(root), tempVal(0), labelVal(0) {

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
	//Initialise base for memory addresses to 0 in register 12
	codeGenerator->write(MOVI_ASM, 12, 0, 0);
	codeGenerator->writeLabel("");
	return translateNode(root);
}
;

bool Translator::translateNode(abstractNode* node) {
	Node* currNode = (Node*) node;
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
	} else if (currNode->node_type == "parserNode" && currNode->id == EXPR_T) {
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
		generateTempName(currNodeEx);
		int rt = registerManager->allocate(currNodeEx->val);
		int r1 = registerManager->allocate((((Node*) currNodeEx->LHS))->val);
		int r2 = registerManager->allocate((((Node*) currNodeEx->RHS))->val);
		switch (((Node*) (currNodeEx->OP))->id) {
		case ASSIGN_T:
			codeGenerator->write(MOV_ASM, r1, r2, 0);
			break;
		case LOGICOP_T:
			if (((Node*) (currNodeEx->OP))->val == ">") {
				codeGenerator->write(CMP_ASM, r1, r2, 0);
				codeGenerator->write(MOVILE_ASM, rt, 0, 0);
				codeGenerator->write(MOVIGT_ASM, rt, 1, 0);
			} else if (((Node*) (currNodeEx->OP))->val == "<") {
				codeGenerator->write(CMP_ASM, r1, r2, 0);
				codeGenerator->write(MOVIGE_ASM, rt, 0, 0);
				codeGenerator->write(MOVILT_ASM, rt, 1, 0);
			} else if (((Node*) (currNodeEx->OP))->val == "==") {
				codeGenerator->write(CMP_ASM, r1, r2, 0);
				codeGenerator->write(MOVINE_ASM, rt, 0, 0);
				codeGenerator->write(MOVIEQ_ASM, rt, 1, 0);
			} else if (((Node*) (currNodeEx->OP))->val == "<=") {
				codeGenerator->write(CMP_ASM, r1, r2, 0);
				codeGenerator->write(MOVIGT_ASM, rt, 0, 0);
				codeGenerator->write(MOVILE_ASM, rt, 1, 0);
			} else if (((Node*) (currNodeEx->OP))->val == ">=") {
				codeGenerator->write(CMP_ASM, r1, r2, 0);
				codeGenerator->write(MOVILT_ASM, rt, 0, 0);
				codeGenerator->write(MOVIGE_ASM, rt, 1, 0);
			} else if (((Node*) (currNodeEx->OP))->val == "!=") {
				codeGenerator->write(CMP_ASM, r1, r2, 0);
				codeGenerator->write(MOVIEQ_ASM, rt, 0, 0);
				codeGenerator->write(MOVINE_ASM, rt, 1, 0);
			} else if (((Node*) (currNodeEx->OP))->val == "!") {
				codeGenerator->write(CMPI_ASM, r2, 0, 0);
				codeGenerator->write(MOVINE_ASM, rt, 0, 0);
				codeGenerator->write(MOVIEQ_ASM, rt, 1, 0);
			} else if (((Node*) (currNodeEx->OP))->val == "&&") {
				std::string label1 = generateLabel();
				std::string label2 = generateLabel();
				codeGenerator->write(CMPI_ASM, r1, 0, 0);
				codeGenerator->writeBranch(BEQ_ASM, label1);
				codeGenerator->write(CMPI_ASM, r2, 0, 0);
				codeGenerator->writeBranch(BEQ_ASM, label1);
				codeGenerator->write(MOVI_ASM, rt, 1, 0);
				codeGenerator->writeBranch(B_ASM, label2);
				codeGenerator->writeLabel(label1);
				codeGenerator->write(MOVI_ASM, rt, 0, 0);
				codeGenerator->writeLabel(label2);
			} else if (((Node*) (currNodeEx->OP))->val == "||") {
				std::string label1 = generateLabel();
				std::string label2 = generateLabel();
				codeGenerator->write(CMPI_ASM, r1, 1, 0);
				codeGenerator->writeBranch(BEQ_ASM, label1);
				codeGenerator->write(CMPI_ASM, r2, 1, 0);
				codeGenerator->writeBranch(BEQ_ASM, label1);
				codeGenerator->write(MOVI_ASM, rt, 0, 0);
				codeGenerator->writeBranch(B_ASM, label2);
				codeGenerator->writeLabel(label1);
				codeGenerator->write(MOVI_ASM, rt, 1, 0);
				codeGenerator->writeLabel(label2);

			}
			break;
		case ARROP_T:
			if (((Node*) (currNodeEx->OP))->val == "+") {
				codeGenerator->write(ADD_ASM, rt, r1, r2);
			} else if (((Node*) (currNodeEx->OP))->val == "-") {
				codeGenerator->write(SUB_ASM, rt, r1, r2);
			} else if (((Node*) (currNodeEx->OP))->val == "*") {
				codeGenerator->write(MULT_ASM, rt, r1, r2);
			} else if (((Node*) (currNodeEx->OP))->val == "/") {
				codeGenerator->write(DIV_ASM, rt, r1, r2);
			} else if (((Node*) (currNodeEx->OP))->val == "%") {
				codeGenerator->write(MOD_ASM, rt, r1, r2);
			}
			break;
		case BITOP_T:
			if (((Node*) (currNodeEx->OP))->val == "&") {
				codeGenerator->write(AND_ASM, rt, r1, r2);
			} else if (((Node*) (currNodeEx->OP))->val == "|") {
				codeGenerator->write(OR_ASM, rt, r1, r2);
			} else if (((Node*) (currNodeEx->OP))->val == "^") {
				codeGenerator->write(XOR_ASM, rt, r1, r2);
			} else if (((Node*) (currNodeEx->OP))->val == "<<") {
				codeGenerator->write(MOVLSL_ASM, rt, r1, r2);
			} else if (((Node*) (currNodeEx->OP))->val == ">>") {
				codeGenerator->write(MOVLSR_ASM, rt, r1, r2);
			} else if (((Node*) (currNodeEx->OP))->val == "~") {
				codeGenerator->write(MVN_ASM, rt, r1, r2);
			}
			break;
		}
		//Temporary values do not need to use up memory and register space as they are only used once
		if (((((Node*) currNodeEx->RHS))->val).find("temp") == 0)
			registerManager->deallocate((((Node*) currNodeEx->RHS))->val);
		if (((((Node*) currNodeEx->LHS))->val).find("temp") == 0)
			registerManager->deallocate((((Node*) currNodeEx->LHS))->val);
		return true;
	} else if (currNode->node_type == "variableNode") {
		std::cout << "Found variable" << std::endl;
		variableNode* currNodeVar = (variableNode*) ((typeNode*) currNode);
		if (currNodeVar->id == CONST_T) {
			std::string val = generateTempName(currNode);
			int rt = registerManager->allocate(currNodeVar->val);
			if (currNodeVar->type->name == "int") {
				unsigned num;
				if (val.size() >= 3) {
					std::string base = val.substr(0, 2);
					//if this returns false, the base used is not decimal
					if (base == "0x") {
						//The base was hexadecimal
						num = strtol(val.substr(2).c_str(), NULL, 16);
					} else if (base == "0b") {
						//The base was binary
						num = strtol(val.substr(2).c_str(), NULL, 2);
					} else if (base == "00") {
						//The base was octal
						num = strtol(val.substr(2).c_str(), NULL, 8);
					} else if (!isdigit(base[2])) {
						//The base was invalid
						printError("Invalid base for integer", false,
								currNode->linenum);
						return false;
					} else {
						//The base was decimal
						num = strtol(val.substr(2).c_str(), NULL, 10);
					}
				} else {
					num = strtol(val.c_str(), NULL, 10);
				}
				codeGenerator->write(MOVI_ASM, rt, num, 0);
				return true;
			} else if (currNodeVar->type->name == "float") {
				//Convert floating point to IEEE 754 format
				fnumber.f = atof(val.c_str());
				std::stringstream ss;
				int x = (fnumber.raw.sign << 31) + (fnumber.raw.exponent << 23)
						+ fnumber.raw.mantissa;
				std::cout << x << std::endl;
				codeGenerator->write(MOVI_ASM, rt, x, 0);
				return true;
			} else if (currNodeVar->type->name == "char") {
				//if it is only one character long, it does not contain an escape character
				int num;
				if (val.size() >= 2) {
					printError("Escape characters not supported", false,
							currNode->linenum);
					return false;
				} else
					num = val[0];
				codeGenerator->write(MOVI_ASM, rt, num, 0);
				return true;
			}
		} else if (currNodeVar->id == VAR_T) {
			//If a variable is found, making sure that it is in the register bank is enough
			if (currNodeVar->type->namespacev == "type")
				registerManager->allocate(currNodeVar->val);
			else if (currNodeVar->type->namespacev == "struct") {
				//Loads entire struct into the registers
				for (int i = 0; i < currNodeVar->type->members.size(); i++) {
					std::stringstream ss;
					ss << currNodeVar->type->name << i;
					registerManager->allocate(ss.str());
				}
			}
			return true;
		}
	} else if (currNode->node_type == "functionCallNode") {
		std::cout << "Found function call" << std::endl;
		functionCallNode* currNodeFunc = (functionCallNode*) currNode;
		std::vector < std::string > parameterNames;
		//Reverse the iterators to get parameters in correct order
		for (int i = (currNodeFunc->parameters->size()) - 1; i >= 0; i--) {
			if (!translateNode(currNodeFunc->parameters->at(i)))
				return false;
			parameterNames.push_back(
					((Node*) (currNodeFunc->parameters->at(i)))->val);
		}
		registerManager->allocateSubroutine(parameterNames);
		std::stringstream ss;
		ss << '_' << currNodeFunc->val;
		registerManager->allocate(currNode->val, 0);
		codeGenerator->writeBranch(BL_ASM, ss.str());
		registerManager->deallocateSubroutine();
		return true;
	} else if (currNode->node_type == "functionDecNode") {
		//Function declerations do not need to be translated to assembly
		return true;
	} else if (currNode->node_type == "functionNode") {
		functionNode* currNodeFunc = (functionNode*) ((typeNode*) currNode);
		functionDecNode* currNodeDec =
				(functionDecNode*) ((typeNode*) ((Node*) (currNodeFunc->def)));
		std::stringstream ss;
		ss << '\t' << ".global " << '_' << ((Node*) (currNodeFunc->def))->val;
		codeGenerator->writeLabel(ss.str());
		codeGenerator->writeLabel("\t");
		std::stringstream ss2;
		ss2 << '_' << ((Node*) (currNodeFunc->def))->val << ':';
		codeGenerator->writeLabel(ss2.str());
		//Initialise base for memory addresses to 0 in register 12
		codeGenerator->write(MOVI_ASM, 12, 0, 0);
		codeGenerator->writeLabel("");

		std::vector < std::string > parameterNames;
		int i;
		for (i = 0; i < 4; i++) {
			if (i < currNodeDec->parameters.size())
				//Builds array of first four parameter names for aliasing
				parameterNames.push_back(
						currNodeDec->parameters.at(
								currNodeDec->parameters.size() - 1 - i).id);
			else
				parameterNames.push_back("NULL");
		}
		registerManager->aliasRegisters(parameterNames);
		//For all remaining parameters, load them from the stack
		for (i; i < currNodeDec->parameters.size(); i++) {
			registerManager->loadStack(i,
					currNodeDec->parameters.at(
							currNodeDec->parameters.size() - 1 - i).id);
		}
		if (currNodeFunc->code)
			if (!translateNode(currNodeFunc->code))
				return false;
		registerManager->restoreAliasRegisters();
		registerManager->invalidateLocalRegisters();
		codeGenerator->write(MOV_ASM, 15, 14, 0);
		return true;
	} else if (currNode->node_type == "parserNode"
			&& currNode->id == RETURN_T) {
		parserNode* currNodeRet = (parserNode*) ((typeNode*) (currNode));
		if (currNodeRet->RHS)
			if (!translateNode(currNodeRet->RHS))
				return false;
		int reg = registerManager->allocate(((Node*) (currNodeRet->RHS))->val);
		codeGenerator->write(MOV_ASM, 0, reg, 0);
		codeGenerator->write(MOV_ASM, 15, 14, 0);
		return true;
	} else if (currNode->node_type == "parserNode" && currNode->id == LOOP_T) {
		parserNode* currNodeLoop = (parserNode*) ((typeNode*) (currNode));
		//It is either a while or a for loop
		if (((Node*) (currNodeLoop->LHS))->node_type == "condNode") {
			//It is a while loop
			std::string beginning = generateLabel();//Method may not work for large loops as data may be lost in memory
			codeGenerator->writeLabel(beginning);
			if (currNodeLoop->RHS)
				if (!translateNode(currNodeLoop->RHS))
					return false;
			condNode* currNodeCond = (condNode*) ((Node*) (currNodeLoop->LHS));
			if (currNodeCond->condition)
				if (!translateNode(currNodeCond->condition))
					return false;
			int reg = registerManager->allocate(
					((Node*) (currNodeCond->condition))->val);
			codeGenerator->write(CMPI_ASM, reg, 0, 0);
			codeGenerator->writeBranch(BNE_ASM, beginning);
			return true;

		} else if (((Node*) (currNodeLoop->LHS))->node_type == "forNode") {
			//It is a for loop
			forNode* currNodeFor = (forNode*) ((Node*) (currNodeLoop->LHS));
			if (currNodeFor->initial)
				if (!translateNode(currNodeFor->initial))
					return false;
			std::string loopBeginning = generateLabel();//Method may not work for large loops as data may be lost in memory
			std::string loopCond = generateLabel();
			codeGenerator->writeBranch(B_ASM, loopCond);

			//Wtite the loop body
			codeGenerator->writeLabel(loopBeginning);
			if (currNodeFor->repeat)
				if (!translateNode(currNodeFor->repeat))
					return false;
			if (currNodeLoop->RHS)
				if (!translateNode(currNodeLoop->RHS))
					return false;

			codeGenerator->writeLabel(loopCond);
			if (currNodeFor->condition)
				if (!translateNode(currNodeFor->condition))
					return false;
			int reg = registerManager->allocate(
					((Node*) (currNodeFor->condition))->val);
			codeGenerator->write(CMPI_ASM, reg, 0, 0);
			codeGenerator->writeBranch(BNE_ASM, loopBeginning);

			return true;
		}
	}
	return false;
}
;

std::string Translator::generateTempName(abstractNode * node) {
	Node* currNode = (Node*) node;
	std::string val = currNode->val;
	std::stringstream ss;
	ss << "temp" << tempVal;
	tempVal++;
	currNode->val = ss.str();
	return val;
}
;

std::string Translator::generateLabel() {
	std::stringstream ss;
	ss << ".label" << labelVal << ':';
	labelVal++;
	return ss.str();
}
;
