#include "../includes/FlexDef.h"
#include "../includes/Errors.h"
#include <iostream>
#include <list>
#include <map>
#include <cctype>
#include <sstream>

abstractNode* root = NULL;

std::list<type_s> types;

std::list<type_s> pointers;

void printTree(abstractNode* &node);

bool analyseTree();

bool trimTree(abstractNode* &node);

bool analyseVariables(abstractNode* node,
		std::list<std::map<std::string, type_t> >&scopeList);

bool analyseTypes(abstractNode* node, bool inFunction, type_t functionType);

type_t getScopeVariable(std::string name,
		std::list<std::map<std::string, type_t> > &scopeList);

std::map<std::string, abstractNode*> functions;

std::map<std::string, abstractNode*> enums;

std::map<std::string, abstractNode*> unions;

std::map<std::string, abstractNode*> structs;

abstractNode* getDec(std::string name,
		std::map<std::string, abstractNode*> scope);

bool compareParameters(std::vector<struct_member>& paramList1,
		std::vector<struct_member> &paramList2);

bool checkName(abstractNode* node,
		std::list<std::map<std::string, type_t> > &scopeList);

bool checkVariable(abstractNode* node,
		std::list<std::map<std::string, type_t> > &scopeList);

int main() {
	std::string filename;
	/* add basic types into vector*/
	addType("type", "int", NULL, *(new std::vector<struct_member>()));
	addType("type", "char", NULL, *(new std::vector<struct_member>()));
	addType("type", "void", NULL, *(new std::vector<struct_member>()));
	addType("type", "float", NULL, *(new std::vector<struct_member>()));
	addType("type", "double", NULL, *(new std::vector<struct_member>()));
	addPointer("char*", getType("char", "type"));
	std::cout << "Please enter filename to be compiled" << std::endl;
	std::cin >> filename;
	if (!parse(filename))
		printError("Error parsing file", true, 0);
	else if (analyseTree()) {
		printTree(root);
		std::cout << std::endl;
	} else
		printError("Error analysing code", true, 0);
	return 0;
}

void printTree(abstractNode* &node) {
	Node* currNode = (Node*) node;
	if (currNode != NULL) {
		if (currNode->node_type == "parserNode") {
			if (((parserNode*) currNode)->LHS)
				printTree(((parserNode*) currNode)->LHS);
			if (((parserNode*) currNode)->OP)
				printTree(((parserNode*) currNode)->OP);
			if (((parserNode*) currNode)->RHS)
				printTree(((parserNode*) currNode)->RHS);
			std::cout << currNode->val << ' ';
		} else if (currNode->node_type == "condNode") {
			std::cout << currNode->val << ' ';
			if (((condNode*) currNode)->condition) {
				std::cout << "if ";
				printTree(((condNode*) currNode)->condition);
			}
			if (((condNode*) currNode)->cond_true) {
				std::cout << "{ ";
				printTree(((condNode*) currNode)->cond_true);
				std::cout << "} ";
			}
			if (((condNode*) currNode)->cond_false) {
				std::cout << "else { ";
				printTree(((condNode*) currNode)->cond_false);
				std::cout << "} ";
			}
		} else if (currNode->node_type == "castNode")
			std::cout << '(' << ((castNode*) currNode)->type->name << ") ";
		else if (currNode->node_type == "variableNode") {
			if (((typeNode*) currNode)->type)
				std::cout << ((typeNode*) currNode)->actualType->name << ' ';

			std::cout << currNode->val << ' ';
		} else if (currNode->node_type == "functionNode") {
			std::cout << currNode->val << ' ';
			if (((functionNode*) currNode)->def) {
				std::cout << "function ";
				printTree(((functionNode*) currNode)->def);
			}
			if (((functionNode*) currNode)->code) {
				std::cout << "{ ";
				printTree(((functionNode*) currNode)->code);
				std::cout << "} ";
			}
		} else if (currNode->node_type == "functionCallNode") {
			std::cout << currNode->val << "( ";
			if (((functionCallNode*) currNode)->parameters) {
				for (int i = 0;
						i < ((functionCallNode*) currNode)->parameters->size();
						i++)
					printTree(
							((functionCallNode*) currNode)->parameters->at(i));
			}
			std::cout << " )";
		} else
			std::cout << currNode->val << ' ';
	}
}

bool analyseTree() {
	trimTree(root);
	if (!root) {
		printError("Code has been optimised away", true, 0);
		return false;
	}
	std::list < std::map<std::string, type_t> > scopeList;
	//Insert global scope
	scopeList.insert(scopeList.begin(), *(new std::map<std::string, type_t>));
	if (analyseVariables(root, scopeList))	//Analyses
		if (analyseTypes(root, false, NULL))
			return true;
	//Delete global scope
	scopeList.erase(scopeList.begin());
	return false;

}

bool trimTree(abstractNode* &node) {
	std::cout << "Started trimming" << std::endl;
	Node* currNode = (Node*) node;
	if (currNode->node_type == "parserNode") {
		//Trim LHS
		if (((parserNode*) currNode)->LHS)
			if (trimTree(((parserNode*) currNode)->LHS))
				((parserNode*) currNode)->LHS = NULL;
		std::cout << "Trimmed LHS" << std::endl;
		//Trim RHS
		if (((parserNode*) currNode)->RHS)
			if (trimTree(((parserNode*) currNode)->RHS))
				((parserNode*) currNode)->RHS = NULL;
		std::cout << "Trimmed RHS" << std::endl;
		//If node is empty, delete it
		if (!((parserNode*) currNode)->LHS && !((parserNode*) currNode)->RHS
				&& ((Node*) ((parserNode*) currNode)->OP)->id != RETURNOP_T) {
			delete ((parserNode*) currNode);
			std::cout << "Deleting branch" << std::endl;
			node = NULL;
		} else if (!((parserNode*) currNode)->LHS
				&& ((parserNode*) currNode)->RHS
				&& !((parserNode*) currNode)->OP) {
			//If only one node exists, swap current node to new node as long as it is not a unary operator
			abstractNode* temp = ((parserNode*) currNode)->RHS;	//Shift node up and remove it from previous parent to prevent chain deletion
			((parserNode*) currNode)->RHS = NULL;
			delete ((parserNode*) currNode);
			std::cout << "Shifting to RHS" << std::endl;
			node = (abstractNode*) ((Node*) temp);
		} else if (((parserNode*) currNode)->LHS
				&& !((parserNode*) currNode)->RHS
				&& !((parserNode*) currNode)->OP) {
			//If only one node exists, swap current node to new node as long as it is not a unary operator
			abstractNode* temp = ((parserNode*) currNode)->LHS;	//Shift node up and remove it from previous parent to prevent chain deletion
			((parserNode*) currNode)->LHS = NULL;
			delete ((parserNode*) currNode);
			std::cout << "Shifting to LHS" << std::endl;
			node = (abstractNode*) ((Node*) temp);
		}
	}
	return false;
}

//Extremely inefficient as a pasrerNode can only declare a single variable
bool analyseVariables(abstractNode* node,
		std::list<std::map<std::string, type_t> > &scopeList) {
	//A variable is in scope in its current branch starting from itself and the node left of it 
	//				root
	//			/		\
	//		int a		+			a is in scope, b is not
	//				/		\
	//				a		b

	//Each declared variable -> add to map for scope
	//If found change type
	//delete map once scope left
	std::cout << "Started variable analysis" << std::endl;
	Node* currNode = (Node*) node;
	if (currNode->node_type == "parserNode") {
		std::cout << "Found branching node" << std::endl;
		parserNode* currNodeEx = (parserNode*) currNode;
		//Push current scope onto the top of the stack
		scopeList.insert(scopeList.begin(),
				*(new std::map<std::string, type_t>));
		if (currNodeEx->LHS)
			if (!analyseVariables(currNodeEx->LHS, scopeList))
				return false;
		std::cout << "Analysed LHS" << std::endl;
		if (currNodeEx->RHS)
			if (!analyseVariables(currNodeEx->RHS, scopeList))
				return false;
		std::cout << "Analysed RHS" << std::endl;
		//Delete current scope from the stack
		scopeList.erase(scopeList.begin());
		return true;
	} else if (currNode->node_type == "variableNode") {
		if (!checkName(currNode, scopeList))
			return false;

		if (((variableNode*) ((typeNode*) currNode))->size)	//If it is an array with a size parameter, check that the parameter is valid
		{
			abstractNode* size =
					(((variableNode*) ((typeNode*) currNode))->size);
			if (!analyseVariables(size, scopeList))
				return false;
			if ((((typeNode*) (Node*) size))->type != getType("int", "type"))
				return false;
		}
		return checkVariable(currNode, scopeList);
	} else if (currNode->node_type == "functionNode") {
		std::cout << "Found defined function" << std::endl;
		functionNode* currNodeFunc = (functionNode*) currNode;
		std::string name =
				((functionDecNode*) ((typeNode*) ((Node*) (currNodeFunc->def))))->val;
		functionDecNode* functionDec =
				(functionDecNode*) ((typeNode*) ((Node*) getDec(name, functions)));
		if (functionDec != NULL) {
			if (!compareParameters(
					((functionDecNode*) (currNodeFunc->def))->parameters,
					functionDec->parameters)) {
				printError("Invalid redecleration", false,
						currNodeFunc->linenum);
				return false;
			}
			std::cout << "Function has previously been declared" << std::endl;
			return true;
		} else {
			std::cout << "Undeclared function" << std::endl;
			functions[currNodeFunc->val] = currNodeFunc->def;
			std::cout << "Function declared" << std::endl;
			return true;
		}
	} else if (currNode->node_type == "functionDecNode") {
		std::cout << "Found declared function" << std::endl;
		functionDecNode* currNodeFunc = (functionDecNode*) currNode;
		functionDecNode* functionDec = (functionDecNode*) ((Node*) getDec(
				currNodeFunc->val, functions));
		if (functionDec != NULL) {
			if (!compareParameters(currNodeFunc->parameters,
					functionDec->parameters)) {
				printError("Invalid redecleration", false,
						currNodeFunc->linenum);
				return false;
			}
			std::cout << "Function has previously been declared" << std::endl;
			return true;
		} else {
			functions[currNodeFunc->val] = currNodeFunc;
			std::cout << "Function declared" << std::endl;
			return true;
		}
	} else {
		printError("Trying to call undefined function", false,
				currNode->linenum);
		return false;
	}
}

//Add return types for functions
bool analyseTypes(abstractNode* node, bool  inFunction, type_t function_type) {
	std::cout << "Started type analysis" << std::endl;
	Node* currNode = (Node*) node;
	if (currNode->node_type == "parserNode"
			&& (currNode->id == EXPR_T || currNode->id == ASSIGN_T)) {
		std::cout << "Found expr or assign" << std::endl;
		parserNode* currNodeEx = (parserNode*) currNode;
		if (currNodeEx->LHS)
			if (!analyseTypes(currNodeEx->LHS, inFunction, function_type))
				return false;
		std::cout << "Analysed LHS" << std::endl;
		if (currNodeEx->RHS)
			if (!analyseTypes(currNodeEx->RHS, inFunction, function_type))
				return false;
		std::cout << "Analysed RHS" << std::endl;
		if (currNodeEx->LHS && currNodeEx->RHS) {
			std::cout << "Binary expression" << std::endl;
			if (((typeNode*) ((Node*) (currNodeEx->LHS)))->type
					&& ((typeNode*) ((Node*) (currNodeEx->RHS)))->type
					&& (((typeNode*) ((Node*) (currNodeEx->LHS)))->type
							== ((typeNode*) ((Node*) (currNodeEx->RHS)))->type))
				currNodeEx->type =
						((typeNode*) ((Node*) (currNodeEx->LHS)))->type;
			else if (((typeNode*) ((Node*) (currNodeEx->LHS)))->type //If the type of the LHS expression is not NULL
					&& ((typeNode*) ((Node*) (currNodeEx->RHS)))->type //and if the type of the RHS expression is not NULL
					&& (
							//int, float and double can be freely cast amongst each other without an explicit cast
							(((typeNode*) ((Node*) (currNodeEx->LHS)))->type
									== getType("int", "type"))
									|| (((typeNode*) ((Node*) (currNodeEx->LHS)))->type
											== getType("float", "type"))
											|| (((typeNode*) ((Node*) (currNodeEx->LHS)))->type
													== getType("double", "type")))
													&& ((((typeNode*) ((Node*) (currNodeEx->RHS)))->type
															== getType("int", "type"))
															|| (((typeNode*) ((Node*) (currNodeEx->RHS)))->type
																	== getType("float", "type"))
																	|| (((typeNode*) ((Node*) (currNodeEx->RHS)))->type
																			== getType("double", "type")))) {
				parserNode* temp = new parserNode(CAST_T, NULL_S, NULL,
						new castNode(TYPE_T,
								((typeNode*) ((Node*) (currNodeEx->LHS)))->type,
								currNode->linenum), currNodeEx->RHS,
								currNode->linenum);
				currNodeEx->RHS = temp;
			} else if (((typeNode*) ((Node*) (currNodeEx->LHS)))->type //If the type of the LHS expression is not NULL
					&& ((typeNode*) ((Node*) (currNodeEx->RHS)))->type //and if the type of the RHS expression is not NULL
					&& (
							//pointers can be cast to an int with only a warning
							(((typeNode*) ((Node*) (currNodeEx->LHS)))->type
									== getType("int", "type"))
									//A pointer name always ends in a '*'
									&& ((((typeNode*) ((Node*) (currNodeEx->RHS)))->type)->name).at(
											((((typeNode*) ((Node*) (currNodeEx->RHS)))->type)->name).size()
											- 1) == '*')) {
				parserNode* temp = new parserNode(CAST_T, NULL_S, NULL,
						new castNode(TYPE_T,
								((typeNode*) ((Node*) (currNodeEx->LHS)))->type,
								currNode->linenum), currNodeEx->RHS,
								currNode->linenum);
				currNodeEx->RHS = temp;
			}

			else {
				printError("Invalid type conversion", false, currNode->linenum);
				return false;
			}
			std::cout << "Both types are equal" << std::endl;
		} else if (currNodeEx->LHS) {
			std::cout << "Unary LHS expression" << std::endl;
			if (((typeNode*) ((Node*) (currNodeEx->LHS)))->type)
				currNodeEx->type =
						((typeNode*) ((Node*) (currNodeEx->LHS)))->type;
			else
				return false;
		} else if (currNodeEx->RHS) {
			std::cout << "Unary RHS expression" << std::endl;
			if (((parserNode*) ((Node*) (currNodeEx->RHS)))->type)
				currNodeEx->type =
						((parserNode*) ((Node*) (currNodeEx->RHS)))->type;
			else
				return false;
		} else {
			return true;
		}
	} else if (currNode->node_type == "parserNode" && currNode->id == CAST_T) {
		std::cout << "Found type cast" << std::endl;
		parserNode* currNodeEx = (parserNode*) currNode;
		currNodeEx->type = ((castNode*) ((Node*) (currNodeEx->OP)))->type;

	} else if (currNode->node_type == "parserNode"
			&& ((Node*) (((parserNode*) currNode)->OP))->id == RETURNOP_T) {
		std::cout << "Found return statement" << std::endl;
		if (!inFunction) {
			printError("Cannot have return statement outside of function",
					false, ((Node*) node)->linenum);
			return false;
		}
		parserNode* currNodeEx = (parserNode*) currNode;
		if (currNodeEx->RHS)
			if (!analyseTypes(currNodeEx->RHS, inFunction, function_type))
				return false;
		if (((typeNode*) ((Node*) (currNodeEx->RHS)))->type == functionType) {
			printError("Invalid return type", false, ((Node*) node)->linenum);
			return false;
		}
		return true;
	} else if (currNode->node_type == "parserNode") { //Base case for parserNode is to check values below
		std::cout << "Found statement list" << std::endl;
		parserNode* currNodeEx = (parserNode*) currNode;
		if (currNodeEx->LHS)
			if (!analyseTypes(currNodeEx->LHS, inFunction, function_type))
				return false;
		if (currNodeEx->RHS)
			if (!analyseTypes(currNodeEx->RHS, inFunction, function_type))
				return false;
	} else if (currNode->node_type == "variableNode") {
		std::cout << "Variable expression" << std::endl;
	} else if (currNode->node_type == "functionNode") {
		inFunction = true;
		function_type = 
				
		//TO-DO add function checks		
				
				
	} else if (currNode->node_type == "condNode") {
		printerror("Not implemented yet", false, currNode->linenum)
		);
		return true;
	} else if (currNode->node_type == "functionCallNode") {
		std::cout << "Found called function" << std::endl;
		functionDecNode* functionDec = (functionDecNode*) ((Node*) getDec(
				currNode->val, functions));
		if (functionDec != NULL) {
			//Analyse types for all expressions being passed
			std::vector < struct_member > param_types;
			for (int i = 0; i < ((functionCallNode*) currNode)->parameters->size();
					i++) {
				if (!analyseTypes(
						((functionCallNode*) currNode)->parameters->at(i), inFunction, function_type))
					return false;
				struct_member temp;
				temp.type =
						((typeNode*) ((Node*) ((functionCallNode*) currNode)->parameters->at(
								i)))->type;
				param_types.push_back(temp);
			}
			if (compareParameters(functionDec->parameters, param_types))
				return true;
			printError("Type mismatch in function call", false, currNode->linenum);
			return false;
		}
	}
}

type_t getScopeVariable(std::string name,
		std::list<std::map<std::string, type_t> > &scopeList) {
	std::list<std::map<std::string, type_t> >::iterator st;
	std::map<std::string, type_t>::iterator it;
	std::map < std::string, type_t > scope;
	//Search through current and all parent scopes
	for (st = scopeList.begin(); st != scopeList.end(); st++) {
		scope = *st;
		it = scope.find(name);
		if (it != scope.end())
			//The element has been found
			return it->second;
	}
	return NULL;
}

abstractNode* getDec(std::string name,
		std::map<std::string, abstractNode*> scope) {
	std::map<std::string, abstractNode*>::iterator it;
	//Search through the list of declared functions
	it = scope.find(name);
	if (it != scope.end())
		//The function has been found
		return it->second;
	return NULL;
}

bool compareParameters(std::vector<struct_member>& paramList1,
		std::vector<struct_member> &paramList2) {
	//If the number of parameters is different, they are incompatible
	if (paramList1.size() != paramList2.size())
		return false;
	for (int i = 0; i < paramList1.size(); i++)
		//compare the type between the two lists
		if (paramList1[i].type != paramList2[i].type)
			return false;

	return true;
}

bool checkName(abstractNode* node,
		std::list<std::map<std::string, type_t> > &scopeList) {
	std::string name = ((Node*) node)->val;
	switch (name[0]) {
	case '[': {				//It is an array of size of the second character
		std::cout << "Found array" << std::endl;
		std::string sizeName = name.substr(1, name.find(']') - 1);//generate variable name for size
		if (isalpha(name[1])) {
			((variableNode*) ((Node*) node))->size = new variableNode(VAR_T,
					sizeName, NULL, "unknown", ((Node*) node)->linenum);
			return true;
		} else if (isdigit(name[1])) {
			((variableNode*) ((Node*) node))->size = new variableNode(CONST_T,
					sizeName, getType("int", "type"), "const",
					((Node*) node)->linenum);
			return true;
		} else
			return false;
		break;
	}
	case '.': {					//It is a struct member
		std::cout << "Found struct member" << std::endl;
		std::string memberName = name.substr(1, name.find('.', 2) - 1);
		((Node*) node)->val = name.substr(name.find('.', 2) + 1);
		if (!checkVariable(node, scopeList))//Must get reference to struct decleration
			return false;
		for (int i = 0;
				i < (((variableNode*) ((Node*) node))->type->members).size(); i++)
			if ((((variableNode*) ((Node*) node))->type->members).at(i).id
					== memberName) {
				std::stringstream ss;
				ss << '.' << i << '.' << name;				//Store member index
				((Node*) node)->val = ss.str();
				((typeNode*) ((Node*) node))->actualType =
						((typeNode*) ((Node*) node))->type;
				((typeNode*) ((Node*) node))->type =
						(((variableNode*) ((Node*) node))->type->members).at(i).type;
				return true;
			}
		printError("Trying to access invalid struct member", false,
				((Node*) node)->linenum);
		return false;
		break;
	}
	case '-': {					//It is a struct member
		std::cout << "Found struct pointer member" << std::endl;
		std::string memberName = name.substr(1, name.find('-', 2) - 1);
		((Node*) node)->val = name.substr(name.find('-', 2) + 1);
		if (!checkVariable(node, scopeList))//Must get reference to struct decleration
			return false;
		if (!getPointer(((Node*) node)->val.c_str())) {
			printError("Trying to access struct member using pointer member", false,
					((Node*) node)->linenum);
			return false;
		}
		for (int i = 0;
				i < (((variableNode*) ((Node*) node))->type->members).size(); i++)
			if ((((variableNode*) ((Node*) node))->type->members).at(i).id
					== memberName) {
				std::stringstream ss;
				ss << '-' << i << '-' << name;				//Store member index
				((Node*) node)->val = ss.str();
				((typeNode*) ((Node*) node))->actualType =
						((typeNode*) ((Node*) node))->type;
				((typeNode*) ((Node*) node))->type =
						(((variableNode*) ((Node*) node))->type->members).at(i).type;
				return true;
			}
		printError("Trying to access invalid struct member", false,
				((Node*) node)->linenum);
		return false;
		break;
	}
	}
	return true;
}

bool checkVariable(abstractNode* node,
		std::list<std::map<std::string, type_t> > &scopeList) {
	Node* currNode = (Node*) node;
	if (((typeNode*) currNode)->namespacev == "unknown") {
		std::cout << "Found undeclared variable" << std::endl;
		if (getScopeVariable(currNode->val, scopeList)) {
			std::cout << "Variable has been declared" << std::endl;
			((typeNode*) currNode)->type = getScopeVariable(currNode->val,
					scopeList);
			((typeNode*) currNode)->namespacev =
					((typeNode*) currNode)->type->namespacev;

			return true;
		} else {
			printError("Undeclared variable", false, currNode->linenum);
			return false;
		}
	} else {
		std::cout << "Found declared variable" << std::endl;
		if (!getScopeVariable(currNode->val, scopeList)) {
			(*scopeList.begin()).insert(
					std::pair<std::string, type_t>(currNode->val,
							((typeNode*) currNode)->type));
			return true;
		} else if (((typeNode*) currNode)->type->namespacev == "struct"
				|| ((typeNode*) currNode)->type->namespacev == "enum"
						|| ((typeNode*) currNode)->type->namespacev == "union")
			return true;
		else if (((typeNode*) currNode)->type != ((typeNode*) currNode)->actualType)
			return true;
		else
			printError("Variable already declared in scope", false,
					currNode->linenum);
		return false;
	}
}
