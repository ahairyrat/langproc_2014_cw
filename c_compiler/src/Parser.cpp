#include "../includes/FlexDef.h"
#include "../includes/Errors.h"
#include <iostream>
#include <list>
#include <map>

abstractNode* root = NULL;

std::list<type_s> types;

std::list<type_s> pointers;

void printTree(abstractNode* node);

bool analyseTree();

bool trimTree(abstractNode* &node);

bool analyseVariables(abstractNode* node,
		std::list<std::map<std::string, type_t> >&scopeList);

bool analyseTypes(abstractNode* node);

type_t getScopeVariable(std::string name,
		std::list<std::map<std::string, type_t> > &scopeList);

std::map<std::string, abstractNode*> functions;

abstractNode* getFunctionDec(std::string name);

bool compareParameters(std::vector<struct_member>& paramList1,
		std::vector<struct_member> &paramList2);

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

void printTree(abstractNode* node) {
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
				std::cout << ((typeNode*) currNode)->type->name << ' ';

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
				printTree(((functionCallNode*) currNode)->parameters);
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
		if (analyseTypes(root))
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
			} else
				printError("Variable already declared in scope", false,
						currNode->linenum);
			return false;
		}
	} else if (currNode->node_type == "functionNode") {
		std::cout << "Found defined function" << std::endl;
		functionNode* currNodeFunc = (functionNode*)currNode;
		functionDecNode* functionDec;
		if (
				(functionDec = getFunctionDec(
						((functionDec*)(
								(Node*)(currNodeFunc -> def)
								)) -> val//functionDec*
								)
						)
			!= NULL){
			if (!compareParameters(((functionDecNode*) (((functionNode*)currNodeFunc) -> def))->parameters,
					functionDec->parameters)) {
				printError("Invalid redecleration", false, currNodeFunc->linenum);
				return false;
			}
			std::cout << "Function has previously been declared" << std::endl;
			return true;
		} else {
			printError("Undeclared function", false, currNodeFunc->linenum);
			functions[currNodeFunc -> val] = currNodeFunc -> def;
		}
	} else if (currNode->node_type == "functionDecNode") {
		std::cout << "Found declared function" << std::endl;
		functionDecNode* functionDec;
		if ((functionDec = getFunctionDec(currNode->val)) != NULL) {
			if (!compareParameters(((functionDecNode*) currNode)->parameters,
					functionDec->parameters)) {
				printError("Invalid redecleration", false, currNode->linenum);
				return false;
			}
			std::cout << "Function has previously been declared" << std::endl;
			return true;
		} else {
			printError("Undeclared function", false, currNode->linenum);
			functions[currNode -> val] = currnode;
		}
	} else if (currNode->node_type == "functionCallNode") {
		std::cout << "Found called function" << std::endl;
		functionDecNode* functionDec;
		if ((functionDec = getFunctionDec(currNode->val)) != NULL) {
			std::cout << "Function has been declared" << std::endl;
			return true;
		} else {
			printError("Undeclared function", false, currNode->linenum);
			return false;
		}
	}

}

//Add return types for functions
bool analyseTypes(abstractNode* node) {
	std::cout << "Started type analysis" << std::endl;
	Node* currNode = (Node*) node;
	if (currNode->node_type == "parserNode"
			&& (currNode->id == EXPR_T || currNode->id == ASSIGN_T)) {
		std::cout << "Found expr or assign" << std::endl;
		parserNode* currNodeEx = (parserNode*) currNode;
		if (currNodeEx->LHS)
			if (!analyseTypes(currNodeEx->LHS))
				return false;
		std::cout << "Analysed LHS" << std::endl;
		if (currNodeEx->RHS)
			if (!analyseTypes(currNodeEx->RHS))
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

	} else if (currNode->node_type == "parserNode") { //Base case for parserNode is to check values below
		std::cout << "Found statement list" << std::endl;
		parserNode* currNodeEx = (parserNode*) currNode;
		if (currNodeEx->LHS)
			if (!analyseTypes(currNodeEx->LHS))
				return false;
		if (currNodeEx->RHS)
			if (!analyseTypes(currNodeEx->RHS))
				return false;
	} else if (currNode->node_type == "variableNode") {
		std::cout << "Variable expression" << std::endl;
	} else if (currNode->node_type == "functionNode") {

	} else if (currNode->node_type == "functionCallNode") {

	} else if (currNode->node_type == "condNode") {

	} else {

	}
	return true;
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

abstractNode* getFunctionDec(std::string name) {
	std::map<std::string, abstractNode*>::iterator it;
	//Search through the list of declared functions
	it = functions.find(name);
	if (it != functions.end())
		//The function has been found
		return it->second;
	return NULL;
}

bool compareParameters(std::vector<struct_member>& paramList1,
		std::vector<struct_member> &paramList2) {
	//If the number of parameters is different, they are incompatible
	if (paramList1.size() != paramList2.size())
		return false;
	for(i = 0; i < paramList1.size(); i++)
		//compare the type between the two lists
		if(paramList1[i].type != paramList2[i].type)
			return false

					return true;
}
