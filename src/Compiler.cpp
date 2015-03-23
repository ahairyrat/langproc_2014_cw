#include "FlexDef.h"
#include "Errors.h"
#include "Translator.h"
#include <iostream>
#include <list>
#include <map>
#include <cctype>
#include <sstream>

////////////////////////////////////////////////////////////////////////////////////////////
//Functions
//
//Prints out the code stored in the tree by recursively printing every node 
void printTree(abstractNode* &node);
//
//The main function to analyse the tree
//It trims analyses types and analyses variable/function definition rules
//It will throw an error message and return false if C89 rules are not followed									
bool analyseTree();
//
//The function to trim the tree
//It trims nodes that are empty and shifts the nodes around if they are useless
void trimTree(abstractNode* &node);
//
//The function to analyse variable declarations in the tree and assign types to used variables
//It will throw an error and return false should C89 variable rules not be followed
bool analyseVariables(abstractNode* node,
		std::list<std::map<std::string, type_t> >&scopeList);
//
//The function to analyse type equality in the tree and perform implicit and explicit type casts
//It will throw an error and return false should C89 variable rules not be followed
bool analyseTypes(abstractNode* node, bool inFunction, type_t functionType);
type_t getScopeVariable(std::string name,
		std::list<std::map<std::string, type_t> > &scopeList);
//
//The function to compare the types of two parameter vectors.
//It will return true if they are equal, false otherwise
bool compareParameters(std::vector<struct_member>& paramList1,
		std::vector<struct_member> &paramList2);
//
//The function to check and evaluate names to see if the parser has added 
//any modifiers eg arrays , or pointers to it
//It will throw an error and return false should C89 variable rules not 
//be followed (pointer to struct member, multiple addressing)
bool evaluateName(abstractNode* node,
		std::list<std::map<std::string, type_t> > &scopeList);
//
//The function to check and evaluate a single variable to determine whether it has been declared in the scope
//If it is a variable declaration that is being evaluated, it will be added to the current scope
//It will throw an error and return false should C89 variable rules not be followed
bool checkVariable(abstractNode* node,
		std::list<std::map<std::string, type_t> > &scopeList);
//
//The function to retrieve a pointer to the declaration of a function to determine whether the 
//function has been redeclared or used incorrectly
abstractNode* getFunctionDec(std::string name,
		std::map<std::string, abstractNode*> scope);
//
//A function to set-up the global type lists to account for thee basic types	
//Should not be called multiple times as multiple copies of said types will appear and 
//type checks will not result ion the correct value
void setupTypes();
//
//A function to print argument help on the command line
void printHelp();
///////////////////////////////////////////////////////////////////////////////////////////////		

////////////////////////////////////////////////////////////////////////////////////////////////
//Global variables for interfacing with the Parser and allow global scoping to occur
//
//Root of the AST, will be passed to all of the components of the compiler to be evaluated
abstractNode* root = NULL;
//
//List of all currently known types.
//These can be basic types or custom types
std::list<type_s> types;
//
//List of all currently known pointer types.
//These can be basic types or custom type pointers of varying indirection
std::list<type_s> pointers;
//
//Map of all function names to decleration node
std::map<std::string, abstractNode*> functions;
//
//Map of all enumerated types names to decleration node
std::map<std::string, abstractNode*> enums;
//
//Map of all union types names to decleration node
std::map<std::string, abstractNode*> unions;
//
//Map of all struct types names to decleration node
std::map<std::string, abstractNode*> structs;
//
//Type of file that should be output
std::string outputType;
////////////////////////////////////////////////////////////////////////////////////////////////

int main(int argc, char* argv[]) {
	std::string inFilename;
	std::string outFileName("");
	if (argc < 2) {
		//Only the compiler was run with no command line arguments
		printError("No input file given", true, 0);
		return 1;
	}
	for (int i = 1; i < argc - 1; i++) {
		std::string arg(argv[i]);
		if (arg == "-S")
			outputType = "Assembly";
		else if (arg == "-o") {
			outFileName = argv[i + 1];
			i++;
		} else if (arg == "-h") {
			printHelp();
		} else
			printError("Unknown argument", true, 0);
	}
	//Default the output file name
	if (outFfileName == "")
		outfileName = "a.s";

	inFileName = argv[argc - 1];

	Translator translator(root, outFileName);

	//Try to parse the input file
	if (!parse(filename)) {
		printError("Error parsing file", true, 0);
		return 1;
	}
	//Try to analyse the tree
	else if (analyseTree()) {
		//If the tree was correct, start the translation into assembly
		translator.setRoot(root);
		if (!translator.translate()) {
			printError("Error compiling code", true, 0);
			return 1;
		}
	} else {
		printError("Error analysing code", true, 0);
		return 1;
	}
	return 0;
}

//Function to print the tree, prints the stored character rather than id to determine what to print
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
				std::cout << ((typeNode*) currNode)->type->name << ' ';
			if (((typeNode*) currNode)->actualType)
				std::cout << '/' << ((typeNode*) currNode)->actualType->name
						<< ' ';

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
	//
	trimTree(root);
	//In very rare cases the code may be built in such a way that the whole tree disappears
	if (!root) {
		printError("Code has been optimised away", true, 0);
		return false;
	}
	std::list < std::map<std::string, type_t> > scopeList;
	//Insert global scope
	scopeList.insert(scopeList.begin(), *(new std::map<std::string, type_t>));
	//Try to analyse the whole set of variables
	if (analyseVariables(root, scopeList)) {
		if (analyseTypes(root, false, NULL)) {
			//Delete global scope
			scopeList.erase(scopeList.begin());
			return true;
		}
	}
	//Delete global scope
	scopeList.erase(scopeList.begin());
	return false;

}

void trimTree(abstractNode* &node) {
	Node* currNode = (Node*) node;
	if (currNode->node_type == "parserNode") {
		//Trim LHS
		if (((parserNode*) currNode)->LHS)
			if (trimTree(((parserNode*) currNode)->LHS))
				((parserNode*) currNode)->LHS = NULL;

		//Trim RHS
		if (((parserNode*) currNode)->RHS)
			if (trimTree(((parserNode*) currNode)->RHS))
				((parserNode*) currNode)->RHS = NULL;

		//If node is empty, delete it
		if (!((parserNode*) currNode)->LHS && !((parserNode*) currNode)->RHS
				&& ((Node*) ((parserNode*) currNode)->OP)->id != RETURNOP_T) {
			delete ((parserNode*) currNode);

			node = NULL;
		} else if (!((parserNode*) currNode)->LHS
				&& ((parserNode*) currNode)->RHS
				&& !((parserNode*) currNode)->OP) {
			//If only one node exists, swap current node to new node as long as it is not a unary operator
			abstractNode* temp = ((parserNode*) currNode)->RHS;	//Shift node up and remove it from previous parent to prevent chain deletion
			((parserNode*) currNode)->RHS = NULL;
			delete ((parserNode*) currNode);

			node = (abstractNode*) ((Node*) temp);
		} else if (((parserNode*) currNode)->LHS
				&& !((parserNode*) currNode)->RHS
				&& !((parserNode*) currNode)->OP) {
			//If only one node exists, swap current node to new node as long as it is not a unary operator
			//Shift node up and remove it from previous parent to prevent chain deletion
			abstractNode* temp = ((parserNode*) currNode)->LHS;
			((parserNode*) currNode)->LHS = NULL;
			delete ((parserNode*) currNode);

			node = (abstractNode*) ((Node*) temp);
		}
	}
}

//Extremely inefficient as a pasrerNode can only declare a single variable but createxs a new scope
bool analyseVariables(abstractNode* node,
		std::list<std::map<std::string, type_t> > &scopeList) {
	//A variable is in scope in its current branch starting from itself and the node left of it 
	//				root
	//			/		\
	//		int a		+			a is in the scope, b is not
	//				/		\
	//				a		b

	//Each declared variable -> add to map for scope
	//If found change type
	//delete map once scope left

	//Also a scope can only be created at a null node 
	//as they represent individual lists of statements

	Node* currNode = (Node*) node;
	if (currNode->node_type == "parserNode") {

		parserNode* currNodeEx = (parserNode*) currNode;
		//Only create a new scope if the operation is null, (list of statements)
		if (currNodeEx->OP == NULL) {
			//Push current scope onto the top of the stack
			scopeList.insert(scopeList.begin(),
					*(new std::map<std::string, type_t>));
		}
		//Analyse LHS
		if (currNodeEx->LHS)
			if (!analyseVariables(currNodeEx->LHS, scopeList))
				return false;
		//Analyse RHS
		if (currNodeEx->RHS)
			if (!analyseVariables(currNodeEx->RHS, scopeList))
				return false;
		//Delete the current scope to prevent interference with other scopes
		if (currNodeEx->OP == NULL) {
			//Delete current scope from the stack
			scopeList.erase(scopeList.begin());
		}
		return true;

	} else if (currNode->node_type == "variableNode") {
		if (currNode->id != CONST_T) {
			//Try to evaluate name modifiers for the variable
			if (!evaluateName(currNode, scopeList))
				return false;
			//If it is an array with a size parameter, check that the parameter is valid
			if (((variableNode*) ((typeNode*) currNode))->size) {
				abstractNode* size =
						(((variableNode*) ((typeNode*) currNode))->size);
				if (!analyseVariables(size, scopeList))
					return false;
				//Make sure that the parameter of the array is of type int
				if ((((typeNode*) (Node*) size))->type
						!= getType("int", "type"))
					return false;
			}
		}
		//Check the variable
		return checkVariable(currNode, scopeList);
	} else if (currNode->node_type == "functionNode") {
		//If this is a function definition
		functionNode* currNodeFunc = (functionNode*) currNode;
		//Get the declaration node of the function
		std::string name =
				((functionDecNode*) ((typeNode*) ((Node*) (currNodeFunc->def))))->val;
		functionDecNode* functionDec =
				(functionDecNode*) ((typeNode*) ((Node*) getFunctionDec(name,
						functions)));
		//If the function has been declared before
		if (functionDec != NULL) {
			//Check that the parameters types of the two function declaration are the same
			if (!compareParameters(
					((functionDecNode*) (currNodeFunc->def))->parameters,
					functionDec->parameters)) {
				printError("Invalid redeclaration", false,
						currNodeFunc->linenum);
				return false;
			}

		} else {
			//If it hasn't been declared before, add it to the lists of declarations
			functions[currNodeFunc->val] = currNodeFunc->def;

		}
		//add all defined parameters to the current scope for the function
		for (int i = 0;
				i
						< (((functionDecNode*) (currNodeFunc->def))->parameters).size();
				i++)
			(*scopeList.begin()).insert(
					std::pair<std::string, type_t>(
							(((functionDecNode*) (currNodeFunc->def))->parameters)[i].id,
							(((functionDecNode*) (currNodeFunc->def))->parameters)[i].type));
		//Analyse the variables inside the functions code
		if (currNodeFunc->code)
			if (!analyseVariables(currNodeFunc->code, scopeList))
				return false;
		return true;
	} else if (currNode->node_type == "functionDecNode") {
		//If it is a function declaration
		functionDecNode* currNodeFunc = (functionDecNode*) currNode;
		//Get the declaration node of the function
		functionDecNode* functionDec =
				(functionDecNode*) ((Node*) getFunctionDec(currNodeFunc->val,
						functions));
		//If the function has been declared before
		if (functionDec != NULL) {
			//Check that the parameters types of the two function declaration are the same
			if (!compareParameters(currNodeFunc->parameters,
					functionDec->parameters)) {
				printError("Invalid redeclaration", false,
						currNodeFunc->linenum);
				return false;
			}
			return true;
		} else {
			//If it hasn't been declared before, add it to the lists of declarations
			functions[currNodeFunc->val] = currNodeFunc;
			return true;
		}
	} else if (currNode->node_type == "condNode") {
		//If it is a conditional node
		//Check the condition expression, the sub tree for true evaluation and false evaluation
		condNode* currNodeIf = (condNode*) currNode;
		if (currNodeIf->condition)
			if (!analyseVariables(currNodeIf->condition, scopeList))
				return false;

		if (currNodeIf->cond_true)
			if (!analyseVariables(currNodeIf->cond_true, scopeList))
				return false;

		if (currNodeIf->cond_false)
			if (!analyseVariables(currNodeIf->cond_false, scopeList))
				return false;

		return true;
	} else if (currNode->node_type == "forNode") {
		//if it is a for loop, check the initial, condition and 
		//repeat code as well as the actual loop body
		forNode* currNodeIf = (forNode*) currNode;
		if (currNodeIf->initial)
			if (!analyseVariables(currNodeIf->initial, scopeList))
				return false;

		if (currNodeIf->condition)
			if (!analyseVariables(currNodeIf->condition, scopeList))
				return false;

		if (currNodeIf->repeat)
			if (!analyseVariables(currNodeIf->repeat, scopeList))
				return false;

		return true;
	} else if (currNode->node_type == "functionCallNode") {
#
		//If it is a function call node, check if it has been declared
		//Other checks are done later on
		functionDecNode* functionDec = (functionDecNode*) ((Node*) getFunctionDec(
						currNode->val, functions));
		if (!functionDec) {
			printError("undeclared function", false, currNode->linenum);
			return false;
		}

		((typeNode*) currNode)->type = functionDec->type;
		return true;
		//Base case to block unknown and not implemented nodes
	} else {
		printError("Unknown error", false, currNode->linenum);
		return false;
	}
}

bool analyseTypes(abstractNode* node, bool inFunction, type_t function_type) {

	Node* currNode = (Node*) node;
	//If the current node is an assignment or expression, we must check that types match
	if (currNode->node_type == "parserNode"
			&& (currNode->id == EXPR_T || currNode->id == ASSIGN_T)) {

		parserNode* currNodeEx = (parserNode*) currNode;
		//If the node has a LHS, we want to propagate its type up the sub tree
		if (currNodeEx->LHS)
			if (!analyseTypes(currNodeEx->LHS, inFunction, function_type))
				return false;
		//If the node has a RHS, we want to propagate its type up the sub tree
		if (currNodeEx->RHS)
			if (!analyseTypes(currNodeEx->RHS, inFunction, function_type))
				return false;
		//Only check that types match if both sides exist
		if (currNodeEx->LHS && currNodeEx->RHS) {
			//Check that both sides have a type and that they are equal.
			//If they are, this node has that type (int + int = int)
			if (((typeNode*) ((Node*) (currNodeEx->LHS)))->type
					&& ((typeNode*) ((Node*) (currNodeEx->RHS)))->type
					&& (((typeNode*) ((Node*) (currNodeEx->LHS)))->type
							== ((typeNode*) ((Node*) (currNodeEx->RHS)))->type))
			currNodeEx->type =
			((typeNode*) ((Node*) (currNodeEx->LHS)))->type;
			//If both nodes are of a number type (int, float, double), they can be 
			//implicitly cast amongst each other
			//The output type will be the one of the left operand
			else if (((typeNode*) ((Node*) (currNodeEx->LHS)))->type
					&& ((typeNode*) ((Node*) (currNodeEx->RHS)))->type
					&& (
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
				//If the implicit cast works, add an explicit cast
				parserNode* temp = new parserNode(CAST_T, NULL_S, NULL,
						new castNode(TYPE_T,
								((typeNode*) ((Node*) (currNodeEx->LHS)))->type,
								currNode->linenum), currNodeEx->RHS,
						currNode->linenum);
				currNodeEx->RHS = temp;
				//If the type being assigned to is an int, pointers can be assigned to it without a problem
				//Again only works if the left operand is an int (int + int* = int, int* + int  = error)
			} else if (((typeNode*) ((Node*) (currNodeEx->LHS)))->type
					&& ((typeNode*) ((Node*) (currNodeEx->RHS)))->type
					&& (
							//pointers can be cast to an int with only a warning
							(((typeNode*) ((Node*) (currNodeEx->LHS)))->type
									== getType("int", "type"))
							&& ((typeNode*) ((Node*) (currNodeEx->RHS)))->type->isPointer()) {
						//Add an explicit cast to make it easier to understand later
						parserNode* temp = new parserNode(CAST_T, NULL_S, NULL,
								new castNode(TYPE_T,
										((typeNode*) ((Node*) (currNodeEx->LHS)))->type,
										currNode->linenum), currNodeEx->RHS,
								currNode->linenum);
						currNodeEx->RHS = temp;
						return true;
					}

					else {
						printError("Invalid type conversion", false,
								currNode->linenum);
						return false;
					}

					return true;
				} else if (currNodeEx->LHS) {
					//If only the LHS exists, the current type will be the type of that node
					if (((typeNode*) ((Node*) (currNodeEx->LHS)))->type)
						currNodeEx->type =
								((typeNode*) ((Node*) (currNodeEx->LHS)))->type;
					else
						return false;
				} else if (currNodeEx->RHS) {
					//If only the RHS exists, the current type will be the type of that node
					if (((parserNode*) ((Node*) (currNodeEx->RHS)))->type)
						currNodeEx->type =
								((parserNode*) ((Node*) (currNodeEx->RHS)))->type;
					else
						return false;
				} else {
					return true;
				}
			}
			else if (currNode->node_type == "parserNode" && currNode->id == CAST_T) {
				//if the current node is node with a cast operator, the type of it will be that of the cast
				parserNode* currNodeEx = (parserNode*) currNode;
				currNodeEx->type = ((castNode*) ((Node*) (currNodeEx->OP)))->type;

			} else if (currNode->node_type == "parserNode"
					&& currNode->id == RETURN_T) {
				//If the type of the node is a return type, that type has to match the type of the function that it is in
				if (!inFunction) {
					//If we are currently not in a function, a return is out of place
					printError("Cannot have return statement outside of function",
							false, ((Node*) node)->linenum);
					return false;
				}
				parserNode* currNodeEx = (parserNode*) currNode;
				//A return n ode can only have RHS expression
				if (currNodeEx->RHS) {
					//analyse that node to get its type
					if (!analyseTypes(currNodeEx->RHS, inFunction, function_type))
					return false;
					//Check that the return type by that expression is the same as the current function
					if (!(((typeNode*) ((Node*) (currNodeEx->RHS)))->type
									== function_type)) {
						printError("Invalid return type", false,
								((Node*) node)->linenum);
						return false;
						//Otherwise a return value for a void type is wrong
					} else if (function_type == getType("void", "type")) {
						printError("Cannot return value from void function", false,
								((Node*) node)->linenum);
						return false;
					}
					//Give a warning if the return is empty but a type of the function is not void
				} else if (function_type != getType("void", "type")) {
					printWarning("Not returning value from non-void function", false,
							((Node*) node)->linenum);
					return true;
				}
				return true;
			} else if (currNode->node_type == "parserNode" && currNode->id == LOOP_T) {
				//If we are in a loop
				parserNode* currNodeLoop = (parserNode*) currNode;
				if (((Node*) (currNodeLoop->LHS))->node_type == "forNode") {

					forNode* currNodeFor = (forNode*) ((Node*) (currNodeLoop->LHS));
					//If we are in a for loop and there is no initial ,
					//condition or repeat procedure then it is wrong
					if (!currNodeFor->condition || !currNodeFor->initial
							|| !currNodeFor->repeat) {
						printError("Missing for loop initialisation", false,
								currNode->linenum);
						return false;
					}
					//Analyse the types of all of the different components of the for loop
					//No specific requirements are made for the types
					if (!analyseTypes(currNodeFor->initial, inFunction, function_type))
					return false;

					if (!analyseTypes(currNodeFor->condition, inFunction,
									function_type))
					return false;

					if (!analyseTypes(currNodeFor->repeat, inFunction, function_type))
					return false;
					//Analyse the types for the code that is being executed in the loop
					return analyseTypes(currNodeLoop->RHS, inFunction, function_type);

				} else if (((Node*) (currNodeLoop->LHS))->node_type == "condNode") {
					//If we are not in  for loop , we are in a while loop
					condNode* currNodeWhile = (condNode*) ((Node*) (currNodeLoop->LHS));
					//If no conditions exist, there is a problem
					if (!currNodeWhile->condition) {
						printError("Missing while loop condition", false,
								currNode->linenum);
						return false;
					}
					//Check the types of the condition
					if (!analyseTypes(currNodeWhile->condition, inFunction,
									function_type))
					return false;
					//check the types of the loop body
					return analyseTypes(currNodeLoop->RHS, inFunction, function_type);
				}

				return false;
			} else if (currNode->node_type == "parserNode") {
				//Base case for a branching node is to check the nodes in either sub tree
				//Mainly used for lists of statements where no operator exists
				parserNode* currNodeEx = (parserNode*) currNode;
				// Check LHS
				if (currNodeEx->LHS)
				if (!analyseTypes(currNodeEx->LHS, inFunction, function_type))
				return false;
				//Check RHS
				if (currNodeEx->RHS)
				if (!analyseTypes(currNodeEx->RHS, inFunction, function_type))
				return false;
				return true;
			} else if (currNode->node_type == "variableNode") {
				//If the node is variable, nothing needs to be done as its type should be defined already
				//These will be the base nodes from which type checking builds up from
				return true;
			} else if (currNode->node_type == "functionNode") {
				//For function definitions
				//Show that we are now in  function
				inFunction = true;
				//Set the type of this function
				function_type =
				((functionDecNode*) ((typeNode*) ((Node*) (((functionNode*) currNode)->def))))->type;
				//Check the code in the function body
				if (((functionNode*) currNode)->code)
				if (!analyseTypes(((functionNode*) currNode)->code, inFunction,
								function_type))
				{
					//Show that we have left the function
					inFunction = false;
					return false;
				}
				inFunction = false;
				return true;
			} else if (currNode->node_type == "condNode") {
				//If we have a condition node (if, ?)
				//TO-DO implement syntax checking for conditionals
				printError("Not implemented yet", false, currNode->linenum);
				return false;
			} else if (currNode->node_type == "functionCallNode") {
				//If we are calling a function
				functionDecNode* functionDec = (functionDecNode*) ((Node*) getFunctionDec(
								currNode->val, functions));
				//Check that a declaration of the function exists
				if (functionDec != NULL) {
					std::vector < struct_member > param_types;
					for (int i = 0;
							i < ((functionCallNode*) currNode)->parameters->size();
							i++) {
						//For each parameter being sent, evaluate that expression
						if (!analyseTypes(
										((functionCallNode*) currNode)->parameters->at(i),
										inFunction, function_type))
						return false;
						struct_member temp;
						//Add the type being sent to vector off types
						temp.type =
						((typeNode*) ((Node*) ((functionCallNode*) currNode)->parameters->at(
												i)))->type;
						param_types.push_back(temp);
					}
					//Compare the types to the types of the function declaration
					if (compareParameters(functionDec->parameters, param_types))
					return true;
					printError("Type mismatch in function call", false,
							currNode->linenum);
					return false;
				}
			} else if (currNode->node_type == "functionDecNode") {
				//This node is a reference of the parameters that the actual function will use
				//It doe not need to be type checked
				//Exists so base case does not catch this
				return true;
			}
			//Base case to catch all unimplemented nodes
			printError("Unknown error" , false, currNode -> linenum);
			return false;
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

		abstractNode* getFunctionDec(std::string name,
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

		bool evaluateName(abstractNode* node,
				std::list<std::map<std::string, type_t> > &scopeList) {
			std::string name = ((Node*) node)->val;
			switch (name[0]) {

			case '[': {
				//generate variable name for size - this can be a number or a variable
				std::string sizeName = name.substr(1, name.find(']') - 1);
				//If it is a name of a variable, attach a new variable node to it
				if (isalpha(name[1])) {
					((variableNode*) ((Node*) node))->size = new variableNode(
							VAR_T, sizeName, NULL, "unknown",
							((Node*) node)->linenum);
					return true;
					//If it is a number , attach a new constant node to it
				} else if (isdigit(name[1])) {
					((variableNode*) ((Node*) node))->size = new variableNode(
							CONST_T, sizeName, getType("int", "type"), "const",
							((Node*) node)->linenum);
					return true;
					//Anything else is invalid
				} else
					return false;
				break;
			}
				//Struct members have the format .x.y where x is the member name and y the struct variable
			case '.': {
				//Generate variable name from the string
				std::string memberName = name.substr(1, name.find('.', 2) - 1);
				((Node*) node)->val = name.substr(name.find('.', 2) + 1);
				//Redo the check for the struct with the new name to get a reference to its declaration
				if (!checkVariable(node, scopeList))
					return false;
				//If the type of the variable is a pointer to a struct, 
				//this is the wrong way of accessing the member
				if (getPointer(((Node*) node)->isPointer)) {
					printError(
							"Trying to access struct member using pointer method",
							false, ((Node*) node)->linenum);
					return false;
				}
				//Once the type has been determined, check if the member that 
				//is being accessed actually exists in that struct
				for (int i = 0;
						i
								< (((variableNode*) ((Node*) node))->type->members).size();
						i++)
					if ((((variableNode*) ((Node*) node))->type->members).at(i).id
							== memberName) {
						std::stringstream ss;
						//If it does, store the member index in the variable name and return
						ss << '.' << i << '.' << ((Node*) node)->val;
						((Node*) node)->val = ss.str();
						//Alias the type of the variable as the type of the member but store the actual type as well
						//This is required for type checks
						((typeNode*) ((Node*) node))->actualType =
								((typeNode*) ((Node*) node))->type;
						((typeNode*) ((Node*) node))->type =
								(((variableNode*) ((Node*) node))->type->members).at(
										i).type;
						return true;
					}
				printError("Trying to access invalid struct member", false,
						((Node*) node)->linenum);
				return false;
				break;
			}
				//Struct members  from pointers have the format -x-y where x is the member name and y the struct variable
			case '-': {
				//Generate variable name from the string
				std::string memberName = name.substr(1, name.find('-', 2) - 1);
				((Node*) node)->val = name.substr(name.find('-', 2) + 1);
				//Redo the check for the struct with the new name to get a reference to its declaration
				if (!checkVariable(node, scopeList))
					return false;
				//If the type of the variable is a struct rather than a pointer, 
				//this is the wrong way of accessing the member
				if (!getPointer(((Node*) node)->isPointer)) {
					printError(
							"Trying to access struct pointer member using non-pointer method",
							false, ((Node*) node)->linenum);
					return false;
				}
				//Once the type has been determined, check if the member that 
				//is being accessed actually exists in that struct
				for (int i = 0;
						i
								< (((variableNode*) ((Node*) node))->type->members).size();
						i++)
					if ((((variableNode*) ((Node*) node))->type->members).at(i).id
							== memberName) {
						std::stringstream ss;
						//If it does, store the member index in the variable name and return
						ss << '-' << i << '-' << ((Node*) node)->val;
						((Node*) node)->val = ss.str();
						//Alias the type of the variable as the type of the member but store the actual type as well
						//This is required for type checks
						((typeNode*) ((Node*) node))->actualType =
								((typeNode*) ((Node*) node))->type;
						((typeNode*) ((Node*) node))->type =
								(((variableNode*) ((Node*) node))->type->members).at(
										i).type;
						return true;
					}
				printError("Trying to access invalid struct member", false,
						((Node*) node)->linenum);
				return false;
				break;
			}
				//TO-DO Add additional checks for other variable modifiers
			}
			//Anything else is valid (or not yet caught)
			return true;
		}

		bool checkVariable(abstractNode* node,
				std::list<std::map<std::string, type_t> > &scopeList) {
			Node* currNode = (Node*) node;
			//If the type of the current variable is not known ...
			if (((typeNode*) currNode)->namespacev == "unknown") {
				//Check if it exists in any of the viewable scopes
				if (getScopeVariable(currNode->val, scopeList)) {
					//Get the type and namespace of the defined type
					((typeNode*) currNode)->type = getScopeVariable(
							currNode->val, scopeList);
					((typeNode*) currNode)->namespacev =
							((typeNode*) currNode)->type->namespacev
					return true;
				} else {
					printError("Undeclared variable", false, currNode->linenum);
					return false;
				}
			} else {
				//The variable has been declared in this node
				//So add it to the current scope
				//Ignore constants (1 should be able to be used multiple times)
				if (!getScopeVariable(currNode->val, scopeList)
						&& !(currNode->id == CONST_T)) {
					(*scopeList.begin()).insert(
							std::pair<std::string, type_t>(currNode->val,
									((typeNode*) currNode)->type));
					return true;
					//Ignore any structure namespaces as they will be found by the lexer automatically
					//and should not be added multiple times
				} else if (((typeNode*) currNode)->type->namespacev == "struct"
						|| ((typeNode*) currNode)->type->namespacev == "enum"
						|| ((typeNode*) currNode)->type->namespacev == "union"
						|| currNode->id == CONST_T)
					return true;
				//If the aliased type is different to the actual type
				//the type must be a structure member so it should not be declared as a varible
				else if (((typeNode*) currNode)->type
						!= ((typeNode*) currNode)->actualType)
					return true;
				else
					printError("Variable already declared in scope", false,
							currNode->linenum);
				return false;
			}
		}

		void setupTypes() {
			// add basic types into vector
			addType("type", "int", NULL, *(new std::vector<struct_member>()));
			addType("type", "char", NULL, *(new std::vector<struct_member>()));
			addType("type", "void", NULL, *(new std::vector<struct_member>()));
			addType("type", "float", NULL, *(new std::vector<struct_member>()));
			addType("type", "double", NULL,
					*(new std::vector<struct_member>()));
			//Add char* types to account for string literals
			addPointer("char*", getType("char", "type"));
		}

//Print help on command line
		void printHelp() {
			std::cout << "A compiler for C v89 to ARM assembly v9" << std::endl;
			std::cout << "Created by Patrick Engelbert (2015)" << std::endl;
			std::cout << std::endl
					<< "WARNING - Does not implement many features of C"
					<< std::endl;
			std::cout << "Use at your own risk" << std::endl;
			std::cout << std::endl;
			std::cout << "compiler [-h][-o <file-name>][-S] <input-file>"
					<< std::endl;
			std::cout << "-h\t access help for command line options"
					<< std::endl;
			std::cout << "-o\tSpecifiy name for the output file" << std::endl;
			std::cout << "-S\tOutput format is in ARM v9 assembly" << std::endl;
		}
