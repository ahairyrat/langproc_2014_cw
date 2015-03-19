#include "../includes/FlexDef.h"
#include "../includes/Errors.h"
#include <iostream>

abstractNode* root = NULL;

std::list<type_s> types;

std::list<type_s> pointers;

void printTree(abstractNode* node);

bool analyseTypeTree(abstractNode* node);

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
		printError("Error parsing file", true);
	else if (analyseTypeTree(root)) {
		printTree(root);
		std::cout << std::endl;
	} else
		printError("Error analysing code", true);
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

bool analyseTypeTree(abstractNode* node) {
	std::cout << "Started analysis" << std::endl;
	Node* currNode = (Node*) node;
	if (currNode->node_type == "parserNode"
			&& (currNode->id == EXPR_T || currNode->id == ASSIGN_T)) {
		std::cout << "Found expr or assign" << std::endl;
		parserNode* currNodeEx = (parserNode*) currNode;
		if (currNodeEx->LHS)
			if (!analyseTypeTree(currNodeEx->LHS))
				return false;
		std::cout << "Analysed LHS" << std::endl;
		if (currNodeEx->RHS)
			if (!analyseTypeTree(currNodeEx->RHS))
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
				parserNode* temp =
						new parserNode(CAST_T, NULL_S, NULL,
								new castNode(TYPE_T,
										((typeNode*) ((Node*) (currNodeEx->LHS)))->type),
										currNodeEx->RHS);
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
				parserNode* temp =
						new parserNode(CAST_T, NULL_S, NULL,
								new castNode(TYPE_T,
										((typeNode*) ((Node*) (currNodeEx->LHS)))->type),
										currNodeEx->RHS);
				currNodeEx->RHS = temp;
			}

			else {
				std::cout << "Trying to use "
						<< ((typeNode*) ((Node*) (currNodeEx->LHS)))->type->name
						<< " and "
						<< ((typeNode*) ((Node*) (currNodeEx->RHS)))->type->name
						<< " in the same expression" << std::endl;
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
			std::cout << "RHS is empty so type is LHS type" << std::endl;
		} else if (currNodeEx->RHS) {
			std::cout << "Unary RHS expression" << std::endl;
			if (((parserNode*) ((Node*) (currNodeEx->RHS)))->type)
				currNodeEx->type =
						((parserNode*) ((Node*) (currNodeEx->RHS)))->type;
			else
				return false;
			std::cout << "LHS is empty so type is RHS type" << std::endl;
		} else {
			std::cout << "Trying to assign or calculate items with no types"
					<< std::endl;
			return false;
		}
	} else if (currNode->node_type == "parserNode" && currNode->id == CAST_T) {
		std::cout << "Found type cast" << std::endl;
		parserNode* currNodeEx = (parserNode*) currNode;
		currNodeEx->type = ((castNode*) ((Node*) (currNodeEx->OP)))->type;

	} else if (currNode->node_type == "variableNode") {
		std::cout << "Variable expression" << std::endl;
	} else if (currNode->node_type == "functionNode") {

	} else if (currNode->node_type == "functionCallNode") {

	} else if (currNode->node_type == "condNode") {

	} else {

	}
	return true;
}
