
#ifndef	_FLEXDEF_H
#define	_FLEXDEF_H

#include <string>
#include <vector>

#define NULL_S ""

typedef std::string* type_t;

enum tokType{
	TYPEDEF_T,
	TYPE_T,
	NAME_T,
	VAR_T,
	CONST_VAL_T,
	STRUCT_T,
	ENUM_T,
	UNION_T,
	EXPR_T,
	ASSIGN_T,
	LOGICOP_T,
	BITOP_T,
	ARROP_T
};

enum storType{
	AUTO_T,
	REGISTER_T,
	EXTERN_T,
	STATIC_T,
	NULLS_T
};

enum signType{
	SIGNED_T,
	UNSIGNED_T,
	NULLI_T
};

enum lenType{
	SHORT_T,
	LONG_T,
	NULLL_T
};	

class abstractNode{};

class Node : public abstractNode{
public:
	tokType id;
	std::string val;
	Node(){};
	Node(tokType id, std::string val);
	virtual ~Node();
};
	
class parserNode : public Node{
public:
	abstractNode* LHS;
	abstractNode* OP;
	abstractNode* RHS;
	parserNode(tokType id, std::string val, abstractNode* LHS, abstractNode* OP, abstractNode* RHS);
	virtual ~parserNode();
};

class variableNode : public Node{
	public:
	storType storage;
	signType sign;
	lenType length;
	
	type_t type;

	variableNode(tokType id, std::string val, type_t type);
	void evaluateModifiers(const std::vector<std::string> modifiers);
};

template <typename T>
std::vector<T> appendVector(std::vector<T> &a, std::vector<T> &b){		//Appends vector b onto a and returns a
		a.reserve(a.size() + b.size());
		a.insert(a.end(), b.begin(), b.end());
		b.clear();
		return a;
}

extern type_t getType(const char* name);

extern abstractNode* root;
	
#endif
