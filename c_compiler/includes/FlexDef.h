
#ifndef	_FLEXDEF_H
#define	_FLEXDEF_H

#include <string>
#include <list>
#include <vector>

#define NULL_S ""

struct type_s;

struct struct_member{std::string id; type_s* type; int value;};

struct type_s{
	std::string namespacev;
	std::string name;
	type_s* base;
	std::vector<struct_member> members;
};

typedef type_s* type_t;
typedef std::list<std::string>* list_t;
typedef std::list<struct_member>* struct_list_t;

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
	ARROP_T,
	UNOP_T
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
	std::string namespacev;
	storType storage;
	signType sign;
	lenType length;
	
	type_t type;

	variableNode(tokType id, std::string val, type_t type, std::string namespacev);
	void evaluateModifiers(const list_t modifiers);
};

extern type_t getType(const char* name, std::string namespacev);


extern abstractNode* root;

extern std::list<type_s> types;

type_t addType(std::string namespacev, std::string name, type_s* base, std::vector<struct_member> members);

std::vector<struct_member> build_struct_members(const struct_list_t memberList); 
	
#endif
