
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
	NULL_T = 0,
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
	UNOP_T,
	RETURNOP_T,
	CAST_T,
	FOR_COND_T,
	LOOP_T,
	FUNC_T,
	WHILE_COND_T,
	IF_COND_T,
	FUNC_DEF_T,
	CONST_T,
	COND_T,
	FUNC_CALL_T,
	PARAM_T
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
	std::string node_type;
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

class forNode : public Node{
public:
	abstractNode* initial;
	abstractNode* condition;
	abstractNode* repeat;
	forNode(tokType id, std::string val, abstractNode* initial, abstractNode* condition, abstractNode* repeat);
	virtual ~forNode();
};

class condNode : public Node{
public:
	abstractNode* condition;
	abstractNode* cond_true;
	abstractNode* cond_false;
	condNode(tokType id, std::string val, abstractNode* condition, 	abstractNode* cond_true, abstractNode* cond_false);
	virtual ~condNode();
};

class castNode : public Node{
public:
	type_t castType;
	castNode(tokType id, type_t castType);
};

class functionNode : public Node{
public:
	abstractNode* code;
	abstractNode* def;
	functionNode(tokType id, std::string val, abstractNode* functionDef, abstractNode* code);
	virtual ~functionNode();
};

class functionDecNode : public Node{
public:
	std::string namespacev;
	storType storage;
	signType sign;
	lenType length;
	
	type_t type;

	std::vector<struct_member> parameters;
	functionDecNode(tokType id, variableNode* variableDef, std::vector<struct_member> parameters);
};

class functionCallNode : public Node{
public:
	abstractNode* parameters;

	functionCallNode(tokType id, std::string val, abstractNode* parameters);
	virtual ~functionCallNode();
};


type_t getType(const char* name, std::string namespacev);

type_t getPointer(const char* name);

extern abstractNode* root;

extern std::list<type_s> types;

extern std::list<type_s> pointers;

type_t addType(std::string namespacev, std::string name, type_s* base, std::vector<struct_member> members);

type_t addPointer(std::string name, type_s* deref);

std::vector<struct_member> build_struct_members(const struct_list_t memberList); 

bool parse(std::string fileName);

	
#endif
