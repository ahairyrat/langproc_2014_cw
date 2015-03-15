

#include "../includes/FlexDef.h"

Node::Node(tokType id, std::string val)
	:id(id){
		this -> val = val;
};

Node::~Node(){};
	
parserNode::parserNode(tokType id, std::string val, abstractNode* LHS, abstractNode* OP, abstractNode* RHS)
	:LHS(LHS),OP(OP),RHS(RHS){
		Node::id = id;
		Node::val = val;
};

parserNode::~parserNode(){
			delete LHS;
			delete OP;
			delete RHS;
};

variableNode::variableNode(tokType id, std::string val, type_t type)
	:storage(NULLS_T),length(NULLL_T),sign(NULLI_T),type(type)
{
		Node::id = id;
		Node::val = val;
};

void variableNode::evaluateModifiers(const std::vector<std::string> modifiers){	//throws modifiers_not_used_exception
	for(int i = 0; i < modifiers.size(); i++)
	{
		if(modifiers[i] ==  "long" && length == NULLL_T)
			length = LONG_T;
		else if(modifiers[i] == "short" && length == NULLL_T)
			length = SHORT_T;
		else if(modifiers[i] == "signed" && sign == NULLI_T)
			sign = SIGNED_T;
		else if(modifiers[i] == "unsigned" && sign == NULLI_T)
			sign = UNSIGNED_T;
		else if(modifiers[i] == "auto" && storage == NULLS_T)
			storage = AUTO_T;
		else if(modifiers[i] == "register" && storage == NULLS_T)
			storage = REGISTER_T;
		else if(modifiers[i] == "static" && storage == NULLS_T)
			storage = STATIC_T;
		else if(modifiers[i] == "extern" && storage == NULLS_T)
			storage = EXTERN_T;
		else{}
			//throw new modifiers_not_used_exception();
	}
}

type_t getType(const char* name)
{
}
abstractNode* root;
