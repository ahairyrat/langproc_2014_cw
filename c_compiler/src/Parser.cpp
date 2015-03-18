
#include "../includes/FlexDef.h"
#include <iomanip>
#include <iostream>

abstractNode* root = NULL;

std::list<type_s> types;

std::list<type_s> pointers;

void printTree(abstractNode* node);

bool analyseTree();

int main()
{
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
	if(parse(filename))
	{
		printTree(root);
		std::cout << std::endl;
	}
	return 0;
}

void printTree(abstractNode* node)
{
	Node* currNode = (Node*)node;
    	if(currNode != NULL)
	{
		if (currNode -> node_type == "parserNode") {
        		if(((parserNode*)currNode)->LHS) printTree(((parserNode*)currNode)->LHS);
			if(((parserNode*)currNode)->OP) printTree(((parserNode*)currNode)->OP);
        		if(((parserNode*)currNode)->RHS) printTree(((parserNode*)currNode)->RHS);
			std::cout<< currNode->val << ' ';
		}
		else if (currNode -> node_type == "condNode") {
			std::cout << currNode -> val << ' ';
			if(((condNode*)currNode)->condition) {std::cout << "if ";printTree(((condNode*)currNode)->condition);}
			if(((condNode*)currNode)->cond_true) {std::cout << "{ ";printTree(((condNode*)currNode)->cond_true);std::cout << "} ";}
        		if(((condNode*)currNode)->cond_false){std::cout << "else { ";printTree(((condNode*)currNode)->cond_false);std::cout << "} ";}
		}
		else if (currNode -> node_type == "castNode")
			std::cout << '(' <<  ((castNode*)currNode) -> castType -> name << ") ";
		else if (currNode -> node_type == "variableNode")
			std::cout <<  ((variableNode*)currNode) -> type -> name << ' ' << currNode -> val << ' ';
		else if (currNode -> node_type == "functionNode") {
			std::cout << currNode -> val << ' ';
			if(((functionNode*)currNode)->def) {std::cout << "function ";printTree(((functionNode*)currNode)->def);}
			if(((functionNode*)currNode)->code) {std::cout << "{ ";printTree(((functionNode*)currNode)->code);std::cout << "} ";}
		}
		else if (currNode -> node_type == "functionCallNode") {
			std::cout << currNode -> val << "( ";
			if(((functionCallNode*)currNode)->parameters) {printTree(((functionCallNode*)currNode)->parameters);}
			 std::cout << " )";
		}
		else
			std::cout << currNode -> val << ' ';
	}
}

bool analyseTree()
{

}
