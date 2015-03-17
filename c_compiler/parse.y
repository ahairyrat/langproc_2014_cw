

//code does not take into account mathematic precedence

%code requires{
	extern int yylex();
	extern int linenum, columnnum;
	#include "includes/FlexDef.h"
}

%{
	#include "CParser.hpp"
	#include <iostream>
	#include <string>
	#include <cstring>
	#include <sstream>
	#include <iomanip>

	void yyerror (char const *s);

	void printTree(abstractNode* node, int indent);

	int linenum = 1;
	int columnnum = 1;

	int anonymousnum = 0;

	int enum_val = 0;

%}

%union{
	char* str;
	list_t list;
	struct_list_t s_list;
	abstractNode* node;
	type_t type;
	int int_t;
}

%token<str> ADDRESS_OR_BITWISE_AND ARITHMETIC AUTO BITWISE_INVERSE BITWISE_LEFT BITWISE_OR BITWISE_RIGHT BITWISE_XOR BREAK CASE CHAR CLOSE_BRACKET CLOSE_CURLY_BRACKET CLOSE_SQUARE_BRACKET COLON COMMA CONST CONTINUE DECREMENT DEFAULT DO ELLIPSES ELSE ENUM EQUALS EOS EXTERN FLOAT FOR FULL_STOP GOTO GREATER_THAN_EQUALS GREATER_THAN ID IF INCREMENT INT INVERSE LESS_THAN_EQUALS LESS_THAN LOGICAL_AND LOGICAL_EQUALS LOGICAL_OR MULT_OR_POINTER NOT_EQUALS NOT OPEN_BRACKET OPEN_CURLY_BRACKET OPEN_SQUARE_BRACKET POINTER_MEMBER REGISTER RETURN SIZEOF STATIC STRING STRUCT SWITCH TYPEDEF TYPE_SIGNED TYPE_UNSIGNED TYPE_PROMOTION TYPE_LONG TYPE_SHORT TYPE UNION UNKNOWN VOLATILE WHILE CONDITIONAL_OPERATOR

%type<node> variable_dec_single variable_dec number unknown variable_dec_stype function_def  assign_expr expr unary_expr binary_expr switch_expr while_expr if_expr for_expr compound_assign logic_op arithmetic_op bitwise_op expr_list program_block bracketed_expr_list function_dec program def_expr rexpr lexpr cond_statement statement unary_op return type_cast for_cond while_cond if_cond

%type<str> qualifier storage length signed modifier address id address_id array id_or_array pointer

%type<list> address_list id_list modifier_list qualifier_list

%type<type> basic_type type non_pointer_type non_pointer_basic_type union_def modified_union  union union_use enum enum_def enum_use modified_enum struct_use struct_def struct modified_struct data_structure

%type<s_list> struct_def_param_list enum_def_param_list parameter_list

%type<int_t> pointer_list

%right EQUALS 

%left ARITHMETIC ADDRESS_OR_BITWISE_AND BITWISE MULT_OR_POINTER BITWISE_INVERSE  BITWISE_LEFT BITWISE_OR BITWISE_RIGHT BITWISE_XOR NOT

%start	start

%%

start		:
		program						{root = $1};
		;

typedef		:
		TYPEDEF variable_dec_single			{//Does not need to input into AST
									if($2 != NULL)
									{
										variableNode* node = (variableNode*)$2;
										addType(node -> namespacev, node -> val, node -> type, *(new std::vector<struct_member>()));
										delete node;
									}
								}
		;

basic_type 	:						//int, char, void etc.
		TYPE						{$$ = getType($1, "type");
									if($$ == NULL)
									{
										std::cout << $1 << " is not a basic type" << std::endl;
									}
								}
		;

pointer 	:					
		MULT_OR_POINTER qualifier_list			{/*Link through qualified pointer*/}//*const
		| MULT_OR_POINTER				{/*Link through pointer*/}//*
		;

pointer_list 	:						//Unbounded list of pointers
 		pointer pointer_list 				{$$ = $2 + 1;}
		| pointer					{$$ = 1}
		;

qualifier 	:
		CONST						{$$ = $1}//const
		| VOLATILE					{$$ = $1}//volatile
		;

storage 	:		
		EXTERN						{$$ = $1}//extern
		| AUTO						{$$ = $1}//auto
		| STATIC					{$$ = $1}//static
		| REGISTER					{$$ = $1}//register
		;

variable_dec_single:
		type id_or_array				{ if($1 != NULL)	
									$$ = new variableNode(VAR_T, $2, $1, "type");
								  else
								  {
									std::cout << $1 << "is not a type" << std::endl;
									$$ = NULL;
								  }
								}//int x
		;

variable_dec_stype:
		type id_list					{
								std::list<std::string>::iterator i;
								 if($1 != NULL)
									for( i = $2->begin(); i != $2->end(); i++)
									    	$$ = new parserNode(EXPR_T,NULL_S,$$,NULL,new variableNode(VAR_T, *i, $1, "type"));		
								 else
								 {
									std::cout << $1 << "is not a type" << std::endl;
									$$ = NULL;
								 }
								}//int x, y, z
		;

variable_dec	:
		variable_dec_single				{$$ = $1}//int x
		| variable_dec_stype				{$$ = $1}//int x, y, z
		;

id_list		:						 //unbounded list of comma seperate identifiers
		id_or_array COMMA id_list			{$$ = $3; $$ -> insert($$ -> begin(), *(new std::string($1)));}
		| id_or_array COMMA id_or_array					{$$ = new std::list<std::string>;
									$$ -> insert($$ -> end(), *(new std::string($1)));
									$$ -> insert($$ -> end(), *(new std::string($3))); 
								}
		;

id_or_array	:
		id array					{$$ = (char*)malloc(strlen($1)+strlen($2)+1);
									$$ = '\0';
    									strcat($$,$1);
   								 	strcat($$,$2);
								}
		| id						{$$ = $1;}
		;

type 		:
		 non_pointer_type pointer_list 			{
									std::stringstream ss;
									$$ = getType(($1 -> name).c_str(), $1 -> namespacev);	//check if basetype exists
									if($$ != NULL)
									{
										ss << $1 -> name;
										for(int i = 0; i < $2; i++)
										{
											ss << '*';
											if(($$ = getPointer(ss.str().c_str())) == NULL)
												$$ = addPointer(ss.str(), $$);			//Adds all missing pointers in the chain to the current pointer
										}
									}
									else
										std::cout << "The type " << $1 -> name << " does not exist" << std::endl;
											
								}	//int x***
		| non_pointer_type				{$$ = $1;}	//int x
		;

non_pointer_type :							//all of the following can be used as a type or the basis for a pointer
		non_pointer_basic_type				{$$ = $1;}
		| data_structure				{$$ = $1;}
		;

data_structure	:
		modified_struct					{$$ = $1;}
		| modified_enum					{$$ = $1;}
		| modified_union				{$$ = $1;}
		;

non_pointer_basic_type :
		basic_type					{$$ = $1}	//int
		| modifier_list basic_type modifier_list 	{$$ = $2;
									$1 -> splice($1 -> end(), *$3);
									//evaluate modifiers
								}	//const unsigned int volatile etc.
		| basic_type modifier_list 			{$$ = $1;
									//Evaluate modifiers
								}	//int unsigned
		| modifier_list basic_type 			{$$ = $2;
									//Evaluate modifiers
								}	//unsigned int
		| modifier_list					{$$ = getType("int", "type");
									if($$ == NULL)
										addType("type","int", NULL,*(new std::vector<struct_member>()));
									//Evaluate modifiers
								}	//unsigned
		;

id		:
		ID						{$$ = $1;}
		;

address_id	:
		address_list id					{$$ = $2;}
		;

address		:
		MULT_OR_POINTER					{$$ = $1}
		| ADDRESS_OR_BITWISE_AND			{$$ = $1}
		;

address_list	:
		address address_list				{$$ = $2; $$ -> insert($$ -> begin(), *(new std::string($1)));}
		| address					{$$ = new std::list<std::string>(); $$ -> insert($$ -> end(), *(new std::string($1)));}
		;

length 		:						//long, short
		TYPE_LONG					{$$ = $1}
		| TYPE_SHORT					{$$ = $1}
		;

signed 		:						//signed, unsigned
		TYPE_SIGNED					{$$ = $1}
		| TYPE_UNSIGNED					{$$ = $1}
		;

struct_def 	:					//struct s{...}
		STRUCT id OPEN_CURLY_BRACKET struct_def_param_list CLOSE_CURLY_BRACKET
								{
								   $$ = getType($2, "struct");
								   if($$ == NULL)
									$$ = addType("struct",$2, NULL,build_struct_members($4));
								   else
									std::cout << $1 << " " << $2 << " already defined" << std::endl;
								}
		| STRUCT OPEN_CURLY_BRACKET struct_def_param_list CLOSE_CURLY_BRACKET
								{
									std::stringstream ss;
									ss << anonymousnum << "struct";
		
									$$ = addType("struct",ss.str(), NULL,build_struct_members($3));
									anonymousnum++;
								}
		;

struct_use 	:							//struct s
		STRUCT id					{$$ = getType($2, "struct");
								   if($$ == NULL)
									std::cout << $1 << " " << $2 << " has not been defined" << std::endl;}
		;

struct 		:
		struct_def					{$$ = $1}	//struct s{...}
		| struct_use					{$$ = $1}	//struct s
		;

function_def 	:
		function_dec bracketed_expr_list
								{$$ = new functionNode(FUNC_T, NULL_S, $1, $2);}
		;

function_dec	:
		variable_dec_single OPEN_BRACKET parameter_list CLOSE_BRACKET	{$$ = new functionDefNode(FUNC_DEF_T, (variableNode*)((Node*)$1), build_struct_members($3));
										 delete $1;}
		;

modifier 	:
		length						{$$ = $1}	//short, long
		| storage					{$$ = $1}	//extern, static, auto, register
		| qualifier					{$$ = $1}	//const, volatile
		| signed					{$$ = $1}	//signed, unsigned
		;

modifier_list 	:							//unbounded list of length, storage, quaifier and signed modifiers. 
									//Exact order does not matter. Validity must be checked later
		 modifier modifier_list				{}
		| modifier					{}
		;

modified_struct :
		 qualifier_list struct 				{$$ = $2; /* evaluate modifiers */}	//const volatile struct ...
		|qualifier struct 				{$$ = $2; /* evaluate modifiers */}	//const struct ...
		| struct					{$$ = $1;}	//struct ...
		;

number 		:
		INT						{$$ = new Node(CONST_VAL_T, $1);}	//01234, 0x134, 0b1111
		| FLOAT						{$$ = new Node(CONST_VAL_T, $1);}	//0213.21414
		;

parameter_list 	:				//unbounded list of variable declerations
		 variable_dec_single COMMA parameter_list  	{$$ = $3;
								 variableNode* variable = (variableNode*)((Node*)$1);
								 struct_member newMember;
								 newMember.id = variable -> val;
								 newMember.type = variable -> type;
								 $$ -> insert($$ -> end(), newMember);
								 delete variable;}
		| variable_dec_single			        {$$ = new std::list<struct_member>();
								 variableNode* variable = (variableNode*)((Node*)$1);
								 struct_member newMember;
								 newMember.id = variable -> val;
								 newMember.type = variable -> type;
								 $$ -> insert($$ -> end(), newMember);
								 delete variable;}
		;

program_block	:
		variable_dec EOS				{$$ = $1;}
		| def_expr					{$$ = NULL}
		| variable_dec EQUALS rexpr EOS			{$$ = new parserNode(EXPR_T, NULL_S, $1, new Node(ASSIGN_T,NULL_S), $3);}
		| bracketed_expr_list				{$$ = $1}
		| typedef EOS					{$$ = NULL}
		| function_def					{$$ = $1}
		| function_dec EOS				{$$ = $1}
		| unknown
		;

program		:
		program program_block				{$$ = new parserNode(NULL_T, NULL_S, $1, NULL, $2);}
		| program_block					{$$ = $1}
		;

enum_def	:
		ENUM id OPEN_CURLY_BRACKET enum_def_param_list CLOSE_CURLY_BRACKET
								{
							 	   $$ = getType($2, "enum");
								   if($$ == NULL)
									$$ = addType("enum",$2, NULL,build_struct_members($4));
								   else
									std::cout << $1 << " " << $2 << " already defined" << std::endl;
								enum_val = 0;
								}
		| ENUM OPEN_CURLY_BRACKET enum_def_param_list CLOSE_CURLY_BRACKET	
								{
									std::stringstream ss;
									ss << anonymousnum << "enum";
		
									$$ = addType("enum",ss.str(), NULL,build_struct_members($3));
									anonymousnum++;
									enum_val = 0;
								}
		;

enum_use	:
		ENUM id						{
							 	   $$ = getType($2, "enum");
								   if($$ == NULL)
									std::cout << $1 << " " << $2 << " has not been defined" << std::endl;
								}
		;

enum		:
		enum_def					{$$ = $1}
		| enum_use					{$$ = $1}
		;

modified_enum	:
		qualifier_list enum				{$$ = $2; /*evaluate modifiers */}	//const volatile enum ...
		| qualifier enum				{$$ = $2; /*evaluate modifiers */}	//const enum ...
		| enum						{$$ = $1}	//enum ...
		;

union_def	:
		UNION id OPEN_CURLY_BRACKET struct_def_param_list CLOSE_CURLY_BRACKET	
								{ 
								   $$ = getType($2, "union");
								   if($$ == NULL)
									$$ = addType("union",$2, NULL,build_struct_members($4));
								   else
									std::cout << $1 << " " << $2 << " already defined" << std::endl;
								}
		| UNION OPEN_CURLY_BRACKET struct_def_param_list CLOSE_CURLY_BRACKET	
								{
									std::stringstream ss;
									ss << anonymousnum << "union";
		
									$$ = addType("union",ss.str(), NULL,build_struct_members($3));
									anonymousnum++;
									}
		;

union_use	:
		UNION id					{
								   $$ = getType($2, "union");
								   if($$ == NULL)
									std::cout << $1 << " " << $2 << " has not been defined" << std::endl;
								}
		;

union		:
		union_def					{$$ = $1}
		| union_use					{$$ = $1}
		;

modified_union	:
		qualifier_list union				{$$ = $2; /*evaluate modifiers */}	//const voaltile union ...#
		| qualifier union				{$$ = $2; /*evaluate modifiers */}	//const union ...
		| union						{$$ = $1;}	//union ...
		;

compound_assign	:
		NOT EQUALS					{$$ = new Node(LOGICOP_T, $1)}	//!=		
		| arithmetic_op EQUALS				{$$ = $1}	//+= -= *= /=
		| bitwise_op EQUALS				{$$ = $1}	//^= <<= >>= etc.
		;

logic_op	:
		NOT						{$$ = new Node(LOGICOP_T, $1)}	//!
		| GREATER_THAN					{$$ = new Node(LOGICOP_T, $1)}	//>
		| GREATER_THAN_EQUALS				{$$ = new Node(LOGICOP_T, $1)}	//>=
		| LESS_THAN_EQUALS				{$$ = new Node(LOGICOP_T, $1)}	//<=
		| LESS_THAN					{$$ = new Node(LOGICOP_T, $1)}	//<
		| LOGICAL_AND					{$$ = new Node(LOGICOP_T, $1)}	//&&
		| LOGICAL_EQUALS				{$$ = new Node(LOGICOP_T, $1)}	//==
		| LOGICAL_OR					{$$ = new Node(LOGICOP_T, $1)}	//||
		;

bitwise_op	:
		ADDRESS_OR_BITWISE_AND				{$$ = new Node(BITOP_T, $1)}	//&
		| BITWISE_INVERSE				{$$ = new Node(BITOP_T, $1)}	//~
		| BITWISE_LEFT					{$$ = new Node(BITOP_T, $1)}	//<<
		| BITWISE_OR					{$$ = new Node(BITOP_T, $1)}	//|
		| BITWISE_RIGHT					{$$ = new Node(BITOP_T, $1)}	//>>
		| BITWISE_XOR					{$$ = new Node(LOGICOP_T, $1)}	//^
		;

qualifier_list	:
		qualifier qualifier				{}	//const volatile
		;

type_cast	:						//(const unsigned int**const*)
		OPEN_BRACKET type CLOSE_BRACKET			{$$ = new castNode(TYPE_T, $2);}
		;

unknown		:
		UNKNOWN						{std::cout << "Unknown value found: " << $$ << std::endl;}
		| CONDITIONAL_OPERATOR				{std::cout << "? not implemented yet" <<  std::endl;}
		| SIZEOF					{std::cout << "sizeof not implemented yet" <<  std::endl;}
		;

arithmetic_op	:
		ARITHMETIC					{$$ = new Node(ARROP_T, $1)}
		| MULT_OR_POINTER				{$$ = new Node(ARROP_T, $1)}
		;

if_cond		:
		IF OPEN_BRACKET expr CLOSE_BRACKET		{}
		;

while_cond	:
		WHILE OPEN_BRACKET expr CLOSE_BRACKET		{}
		;

while_expr	:
		while_cond bracketed_expr_list			{}			//while(true){...} 
		| while_cond statement				{}			//while(true)...
		| DO bracketed_expr_list while_cond EOS		{}			//do{...}while(true);
		| DO statement while_cond EOS			{}			//do...while(true)
		;

bracketed_expr_list :
		OPEN_CURLY_BRACKET expr_list CLOSE_CURLY_BRACKET
								{$$ = $2;}
		;

expr_list	:
		expr_list statement				{$$ = new parserNode(NULL_T, NULL_S, $1, NULL,$2); }
		| statement					{$$ = $1}
		;

if_expr		:
		if_cond bracketed_expr_list			{}
		| if_cond statement				{}
		;

switch_cond	:
		SWITCH OPEN_BRACKET expr CLOSE_BRACKET		{}
		;

switch_expr	:
		switch_cond OPEN_CURLY_BRACKET case_list CLOSE_CURLY_BRACKET
								{}
		;

case_stat	:
		CASE unary_expr COLON expr_list			{}
		| CASE unary_expr COLON bracketed_expr_list	{}
		;

case_list 	:
		case_stat case_list				{}
		| case_stat					{}
		;

statement	:
		expr EOS					{$$ = $1;}
		| cond_statement				{$$ = $1;}
		| return EOS					{$$ = $1;}
		;

cond_statement	:
		switch_expr					{$$ = $1;}
		| if_expr					{$$ = $1;}
		| while_expr					{$$ = $1;}
		| for_expr					{$$ = $1;}
		;
		
expr		:
		| rexpr						{$$ = $1;}
		| variable_dec					{$$ = $1;}
		;

lexpr		:
		unary_expr					{$$ = $1;}
		| def_expr					{$$ = NULL;}
		| variable_dec					{$$ = $1;}	
		;

rexpr 		:
		binary_expr					{$$ = $1;}
		| assign_expr					{$$ = $1;}
		| unary_expr					{$$ = $1;}
		;

unary_expr	:
		number						{$$ = $1;}
		| id						{$$ = new Node(NAME_T, $1);}
		| address_id					{$$ = new Node(NAME_T, $1);}
		| unary_op id					{$$ = new parserNode(EXPR_T, NULL_S, new Node(NAME_T, $2), new Node(ASSIGN_T,NULL_S), new parserNode(EXPR_T,NULL_S, new Node(NAME_T, $2), $1, new Node(NAME_T, $2)));}
		| id INCREMENT					{$$ = new parserNode(EXPR_T, NULL_S, new Node(NAME_T, $1), new Node(ASSIGN_T,NULL_S), new parserNode(EXPR_T,NULL_S, new Node(NAME_T, $1), new Node(UNOP_T, $2), new Node(NAME_T, $1)));}
		| id DECREMENT					{$$ = new parserNode(EXPR_T, NULL_S, new Node(NAME_T, $1), new Node(ASSIGN_T,NULL_S), new parserNode(EXPR_T,NULL_S, new Node(NAME_T, $1), new Node(UNOP_T, $2), new Node(NAME_T, $1)));}
		| type_cast id					{$$ = new parserNode(EXPR_T, NULL_S, $1, new Node(CAST_T, NULL_S), new Node(NAME_T, $2));}
		;				

binary_expr	:
		lexpr arithmetic_op rexpr			{$$ = new parserNode(EXPR_T, NULL_S, $1, $2, $3);}
		| rexpr arithmetic_op rexpr			{$$ = new parserNode(EXPR_T, NULL_S, $1, $2, $3);}
		| lexpr logic_op rexpr				{$$ = new parserNode(EXPR_T, NULL_S, $1, $2, $3);}
		| lexpr bitwise_op rexpr			{$$ = new parserNode(EXPR_T, NULL_S, $1, $2, $3);}
		;

assign_expr	:
		lexpr EQUALS rexpr				{$$ = new parserNode(EXPR_T, NULL_S, $1, new Node(ASSIGN_T,NULL_S), $3);}
		| lexpr compound_assign rexpr			{$$ = new parserNode(EXPR_T, NULL_S, $1, new Node(ASSIGN_T,NULL_S), new parserNode(EXPR_T,NULL_S, $1, $2, $3));}
		;

for_cond	:
		FOR OPEN_BRACKET expr EOS expr EOS expr CLOSE_BRACKET
								{$$ = new forNode(FOR_COND_T, NULL_S, $3, $5, $7);}
		;

for_expr	:
		for_cond bracketed_expr_list			{$$ = new parserNode(LOOP_T, NULL_S, $1, NULL, $2);}
		| for_cond statement				{$$ = new parserNode(LOOP_T, NULL_S, $1, NULL, $2);}
		;

struct_def_param_list:
		variable_dec EOS struct_def_param_list
								{
								$$ = $3;
								 variableNode* variable = (variableNode*)((Node*)$1);
								 struct_member newMember;
								 newMember.id = variable -> val;
								 newMember.type = variable -> type;
								 $$ -> insert($$ -> end(), newMember);
								 delete variable;
								}		//int x; int y; char z ...
		| variable_dec EOS				{
								$$ = new std::list<struct_member>();
								 variableNode* variable = (variableNode*)((Node*)$1);
								 struct_member newMember;
								 newMember.id = variable -> val;
								 newMember.type = variable -> type;
								 $$ -> insert($$ -> end(), newMember);
								 delete variable;
								}		//int x; int y; char z ...
		;

enum_def_param_list:
		id EQUALS CHAR COMMA enum_def_param_list
								{
								$$ = $5;
								 struct_member newMember;
								 newMember.id = $1;
								 newMember.type = getType("int", "type");
								 newMember.value = (int)$3[2];
								 enum_val = newMember.value + 1;
								 $$ -> insert($$ -> begin(), newMember);
								}		//x = 'a' y = 'b'
		|id EQUALS INT COMMA enum_def_param_list
								{
								$$ = $5;
								 struct_member newMember;
								 newMember.id = $1;
								 newMember.type = getType("int", "type");
								 newMember.value = atoi($3);
								 enum_val = newMember.value + 1;
								 $$ -> insert($$ -> begin(), newMember);
								}		//x = 4, y = 5,
		| id COMMA enum_def_param_list			{
								$$ = $3;
								 struct_member newMember;
								 newMember.id = $1;
								 newMember.type = getType("int", "type");
								 newMember.value = enum_val;
								 enum_val++;
								 $$ -> insert($$ -> end(), newMember);
								}
		| id EQUALS CHAR COMMA				{
								$$ = new std::list<struct_member>();
								 struct_member newMember;
								 newMember.id = $1;
								 newMember.type = getType("int", "type");
								 newMember.value = (int)$3[2];
								 enum_val = newMember.value + 1;
								 $$ -> insert($$ -> end(), newMember);
								}		//x = 'a',
		| id EQUALS INT COMMA				{
								$$ = new std::list<struct_member>();
								 struct_member newMember;
								 newMember.id = $1;
								 newMember.type = getType("int", "type");
								 newMember.value = atoi($3);
								 enum_val = newMember.value + 1;
								 $$ -> insert($$ -> end(), newMember);
								}		//x = 5,
		| id COMMA					{
								$$ = new std::list<struct_member>();
								 struct_member newMember;
								 newMember.id = $1;
								 newMember.type = getType("int", "type");
								 newMember.value = enum_val;
								 enum_val = newMember.value + 1;
								 $$ -> insert($$ -> end(), newMember);}		//x,
		;

def_expr	:
		data_structure	EOS				{$$ = NULL}
		;

unary_op	:
		INCREMENT					{$$ = new Node(UNOP_T, $1)}
		| DECREMENT					{$$ = new Node(UNOP_T, $1)}
		| TYPE_PROMOTION				{$$ = new Node(UNOP_T, $1)}
		| INVERSE					{$$ = new Node(UNOP_T, $1)}
		;

return		:
		RETURN rexpr					{$$ = new parserNode(EXPR_T, NULL_S, NULL, new Node(RETURNOP_T, NULL_S), $2)}
		;

array		:
		OPEN_SQUARE_BRACKET number CLOSE_SQUARE_BRACKET	{}
		| OPEN_SQUARE_BRACKET id CLOSE_SQUARE_BRACKET	{}
		;

%%

int main()
{
	/* add basic types into vector*/
	addType("type", "int", NULL, *(new std::vector<struct_member>()));
	addType("type", "char", NULL, *(new std::vector<struct_member>()));
	addType("type", "void", NULL, *(new std::vector<struct_member>()));
	addType("type", "float", NULL, *(new std::vector<struct_member>()));
	addType("type", "double", NULL, *(new std::vector<struct_member>()));
	yyparse();
	printTree(root, 0);
	std::cout << std::endl;
	return 0;
}



void yyerror (char const *s)
{	
  std::cerr << s << " at " << yylval.str  << " " << columnnum << std::endl;
}

void printTree(abstractNode* node, int indent)
{
	Node* currNode = (Node*)node;
    	if(currNode != NULL)
	{
		if (currNode -> node_type == "parserNode") {
			std::cout<< currNode->id << std::endl;
        		if(((parserNode*)currNode)->LHS) printTree(((parserNode*)currNode)->LHS, indent+4);
        		if(((parserNode*)currNode)->RHS) printTree(((parserNode*)currNode)->RHS, indent+4);
		}
		else if (currNode -> node_type == "baseNode") {
			std::cout << currNode -> id << ' ' << currNode -> val;
		}
		else if (currNode -> node_type == "castNode") {
			std::cout << currNode -> id << ' ' << ((castNode*)currNode) -> castType -> name;
		}
		else if (currNode -> node_type == "variableNode") {
			std::cout << currNode -> id << ' ' << ((variableNode*)currNode) -> type -> name <<  ' ' << currNode -> val;
		}
		if (indent)
			std::cout << std::setw(indent) << ' ';
	}
      	
}

