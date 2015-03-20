
#ifndef	_FLEXDEF_H
#define	_FLEXDEF_H

#include <list>
#include <vector>
#include <string>

#define NULL_S ""

struct type_s;

struct struct_member{std::string id; type_s* type; int value;};

struct type_s{
	std::string namespacev;
	std::string name;
	type_s* base;
	std::vector<struct_member> members;
};

class abstractNode{};

typedef type_s* type_t;
typedef std::list<std::string>* list_t;
typedef std::vector<abstractNode*>* node_list_t;
typedef std::list<struct_member>* struct_list_t;

enum tokType{
	NULL_T = 0,
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
	FOR_COND_T,
	LOOP_T,
	FUNC_T,
	WHILE_COND_T,
	IF_COND_T,
	FUNC_DEF_T,
	CONST_T,
	COND_T,
	FUNC_CALL_T,
	PARAM_T,
	CAST_T
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

class Node : public abstractNode{
public:
	std::string node_type;
	tokType id;
	std::string val;
	int linenum;
	Node(){};
	Node(tokType id, std::string val, int linenum);
	virtual ~Node();
};

class typeNode : public Node{
public:
	type_t type;
	std::string namespacev;
};
	
class parserNode : public typeNode{
public:
	abstractNode* LHS;
	abstractNode* OP;
	abstractNode* RHS;
	parserNode(tokType id, std::string val, abstractNode* LHS, abstractNode* OP, abstractNode* RHS, int linenum);
	virtual ~parserNode();
};

class variableNode : public typeNode{
public:
	storType storage;
	signType sign;
	lenType length;

	variableNode(tokType id, std::string val, type_t type, std::string namespacev, int linenum);
	void evaluateModifiers(const list_t modifiers);
};

class forNode : public Node{
public:
	abstractNode* initial;
	abstractNode* condition;
	abstractNode* repeat;
	forNode(tokType id, std::string val, abstractNode* initial, abstractNode* condition, abstractNode* repeat, int linenum);
	virtual ~forNode();
};

class condNode : public Node{
public:
	abstractNode* condition;
	abstractNode* cond_true;
	abstractNode* cond_false;
	condNode(tokType id, std::string val, abstractNode* condition, 	abstractNode* cond_true, abstractNode* cond_false, int linenum);
	virtual ~condNode();
};

class castNode : public typeNode{
public:
	castNode(tokType id, type_t castType, int linenum);
};

class functionNode : public Node{
public:
	abstractNode* code;
	abstractNode* def;
	functionNode(tokType id, std::string val, abstractNode* functionDef, abstractNode* code, int linenum);
	virtual ~functionNode();
};

class functionDecNode : public typeNode{
public:

	storType storage;
	signType sign;
	lenType length;
	std::vector<struct_member> parameters;

	functionDecNode(tokType id, variableNode* variableDef, std::vector<struct_member> parameters, int linenum);
};

class functionCallNode : public Node{
public:
	node_list_t parameters;
	functionCallNode(tokType id, std::string val, node_list_t parameters, int linenum);
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
