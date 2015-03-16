
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

	void yyerror (char const *s);

	int linenum = 1;
	int columnnum = 1;

	int anonymousnum = 0;

%}

%union{
	char* str;
	list_t list;
	struct_list_t s_list;
	abstractNode* node;
	type_t type;
}

%token<str> ADDRESS_OR_BITWISE_AND ARITHMETIC AUTO BITWISE_INVERSE BITWISE_LEFT BITWISE_OR BITWISE_RIGHT BITWISE_XOR BREAK CASE CHAR CLOSE_BRACKET CLOSE_CURLY_BRACKET CLOSE_SQUARE_BRACKET COLON COMMA CONST CONTINUE DECREMENT DEFAULT DO ELLIPSES ELSE ENUM EQUALS EOS EXTERN FLOAT FOR FULL_STOP GOTO GREATER_THAN_EQUALS GREATER_THAN ID IF INCREMENT INT INVERSE LESS_THAN_EQUALS LESS_THAN LOGICAL_AND LOGICAL_EQUALS LOGICAL_OR MULT_OR_POINTER NOT_EQUALS NOT OPEN_BRACKET OPEN_CURLY_BRACKET OPEN_SQUARE_BRACKET POINTER_MEMBER REGISTER RETURN SIZEOF STATIC STRING STRUCT SWITCH TYPEDEF TYPE_SIGNED TYPE_UNSIGNED TYPE_PROMOTION TYPE_LONG TYPE_SHORT TYPE UNION UNKNOWN VOLATILE WHILE CONDITIONAL_OPERATOR

%type<node> variable_dec_single pointer_list variable_dec number parameter_list  unknown variable_dec_stype function_def  assign_expr expr unary_expr binary_expr switch_expr while_expr if_expr for_expr compound_assign logic_op arithmetic_op bitwise_op expr_list program_block bracketed_expr_list function_dec program def_expr

%type<str> qualifier storage length signed modifier address id address_id

%type<list> address_list id_list modifier_list qualifier_list

%type<type> basic_type pointer type non_pointer_type non_pointer_basic_type union_def modified_union  union union_use enum enum_def enum_use modified_enum struct_use struct_def struct modified_struct  

%type<s_list> struct_def_param_list

%start	test

%%

test		:						//For debugging purposes
		program					{	root = $1;
								std::cout << "Test successful" << std::endl;
								std::list<type_s>::iterator i;
								for( i = types.begin(); i != types.end(); i++)
								{
								std::cout << i -> name;
								if(i -> base != NULL)
								{
									type_s* base_type = &(*i);
									while(base_type -> base != NULL)
										base_type = base_type -> base;
									std::cout << "->" << base_type -> name;
								}
								else std::cout << "-> No base class";
									
								std::cout << std::endl;				
								}
							}
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
		| id						{$$ = getType($1, "type");
									if($$ == NULL)
										std::cout << $1 << " is not a defined type" << std::endl;
								}
		;

pointer 	:					
		MULT_OR_POINTER qualifier_list			{/*Link through qualified pointer*/}//*const
		| MULT_OR_POINTER				{/*Link through pointer*/}//*
		;

pointer_list 	:						//Unbounded list of pointers
 		pointer_list pointer 				{}
		| pointer					{}
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
		type id						{ if($1 != NULL)
									$$ = new variableNode(VAR_T, $2, $1, "type");
								  else
									$$ = NULL;
								}//int x
		;

variable_dec_stype:
		type id_list					{/* link ids to type */
									}//int x, y, z
		;

variable_dec	:
		variable_dec_single				{$$ = $1}//int x
		| variable_dec_stype				{$$ = $1}//int x, y, z
		;

id_list		:						 //unbounded list of comma seperate identifiers
		id_list COMMA id				{$$ = $1; $$ -> insert($$ -> end(), *(new std::string($3)));}
		| id						{$$ = new std::list<std::string>; $$ -> insert($$ -> end(), *(new std::string($1)));}
		;

type 		:
		 non_pointer_type pointer_list 			{}	//int x***
		| non_pointer_type				{$$ = $1;}	//int x
		;

non_pointer_type :							//all of the following can be used as a type or the basis for a pointer
		non_pointer_basic_type				{$$ = $1;}
		| modified_struct				{$$ = $1;}
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
		address_list id					{/*Pop back and add for every address item*/
									$$ = $2;	
								}
		;

address		:
		MULT_OR_POINTER					{$$ = $1}
		| ADDRESS_OR_BITWISE_AND			{$$ = $1}
		;

address_list	:
		address_list address				{$$ = $1; $$ -> insert($$ -> end(), *(new std::string($2)));}
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
									ss << "struct" << anonymousnum;
		
									$$ = addType("struct",ss.str(), NULL,build_struct_members($3));
									anonymousnum++;
								}
		;

struct_use 	:							//struct s
		STRUCT id					{$$ = getType($2, "struct");}
		;

struct 		:
		struct_def					{$$ = $1}	//struct s{...}
		| struct_use					{$$ = $1}	//struct s
		;

function_def 	:
		function_dec bracketed_expr_list
								{}
		;

function_dec	:
		variable_dec_single OPEN_BRACKET parameter_list CLOSE_BRACKET	{}
		;

modifier 	:
		length						{$$ = $1}	//short, long
		| storage					{$$ = $1}	//extern, static, auto, register
		| qualifier					{$$ = $1}	//const, volatile
		| signed					{$$ = $1}	//signed, unsigned
		;

modifier_list 	:							//unbounded list of length, storage, quaifier and signed modifiers. 
									//Exact order does not matter. Validity must be checked later
		 modifier_list modifier				{}
		| modifier					{}
		;

modified_struct :
		 qualifier_list struct 				{$$ = $2; /* evaluate modifiers */}	//const struct ...
		| struct					{$$ = $1;}	//struct ...
		;

number 		:
		INT						{$$ = new Node(CONST_VAL_T, $1);}	//01234, 0x134, 0b1111
		| FLOAT						{$$ = new Node(CONST_VAL_T, $1);}	//0213.21414
		;

parameter_list 	:				//unbounded list of variable declerations
		 parameter_list COMMA variable_dec_single 	{}
		| variable_dec_single				{}
		;

program_block	:
		expr_list					{$$ = $1}
		| bracketed_expr_list				{$$ = $1}
		| bracketed_expr_list EOS			{$$ = $1}
		| typedef EOS					{$$ = NULL}
		| function_def EOS				{$$ = $1}
		| function_dec EOS				{$$ = $1}
		| unknown
		;

program		:
		program program_block				{$$ = new parserNode(EXPR_T, NULL_S, $1, NULL, $2);}
		| program_block					{$$ = new parserNode(EXPR_T,NULL_S, $1,NULL,NULL);}
		;

enum_def	:
		ENUM id OPEN_CURLY_BRACKET enum_def_param_list CLOSE_CURLY_BRACKET
								{
							 	   $$ = getType($2, "enum");
								   if($$ == NULL)
									$$ = addType("enum",$2, NULL,build_struct_members($4));
								   else
									std::cout << $1 << " " << $2 << " already defined" << std::endl;}
		| ENUM OPEN_CURLY_BRACKET enum_def_param_list CLOSE_CURLY_BRACKET	
								{
									std::stringstream ss;
									ss << "enum" << anonymousnum;
		
									$$ = addType("enum",ss.str(), NULL,build_struct_members($3));
									anonymousnum++;
									anonymousnum++;
									}
		;

enum_use	:
		ENUM id						{/*Add code to check if enum exists*/
									}
		;

enum		:
		enum_def					{$$ = $1}
		| enum_use					{$$ = $1}
		;

modified_enum	:
		qualifier_list enum				{$$ = $2; /*evaluate modifiers */}	//const enum ...
		| enum						{$$ = $1}	//enum ...
		;

union_def	:
		UNION id OPEN_CURLY_BRACKET union_def_param_list CLOSE_CURLY_BRACKET	
								{
									/* add union definition into storage*/}
		| UNION OPEN_CURLY_BRACKET union_def_param_list CLOSE_CURLY_BRACKET	
								{
									/*add union definition into storage*/
									anonymousnum++;
									}
		;

union_use	:
		UNION id					{/* Add code to check if union has been defined*/
									}
		;

union		:
		union_def					{$$ = $1}
		| union_use					{$$ = $1}
		;

modified_union	:
		qualifier_list union				{$$ = $2; /*evaluate modifiers */}	//const union ...
		| union						{$$ = $1;}	//union ...
		;

compound_assign	:
		NOT EQUALS					{}	//!=		
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
		| BITWISE_XOR					{}	//^
		;

qualifier_list	:
		qualifier qualifier				{}	//const volatile
		| qualifier					{}	//const
		;

type_cast	:						//(const unsigned int**const*)
		OPEN_BRACKET type CLOSE_BRACKET			{}
		;

unknown		:
		UNKNOWN						{std::cout << "Unknown value found: " << $$ << std::endl;}
		;

arithmetic_op	:
		ARITHMETIC					{$$ = new Node(ARROP_T, $1)}
		| MULT_OR_POINTER				{$$ = new Node(ARROP_T, $1)}
		;

if_cond		:
		IF OPEN_BRACKET expr CLOSE_BRACKET		{}
		;

while_cond	:
		WHILE OPEN_BRACKET expr CLOSE_BRACKET bracketed_expr_list 
								{}
		;

while_expr	:
		while_cond bracketed_expr_list			{}			//while(true){...} 
		| DO bracketed_expr_list while_cond EOS		{}			//do{...}while(true);
		;

bracketed_expr_list :
		OPEN_CURLY_BRACKET expr_list CLOSE_CURLY_BRACKET
								{}
		| expr						{}			//If it is only a single expression, brackets are not needed
		;

expr_list	:
		expr_list expr EOS					{$$ = new parserNode(EXPR_T, NULL_S, $1, NULL,$2); }
		| expr EOS						{$$ = $1}
		;

if_expr		:
		if_cond bracketed_expr_list			{}
		;

switch_cond	:
		SWITCH OPEN_BRACKET expr CLOSE_BRACKET		{}
		;

switch_expr	:
		switch_cond OPEN_CURLY_BRACKET case_list CLOSE_CURLY_BRACKET
								{}
		;

case_stat	:
		CASE const_expr COLON expr_list			{}
		| CASE const_expr COLON bracketed_expr_list	{}
		;

expr_list 	:
		expr expr_list					{}
		| expr						{}
		;

case_list 	:
		case_list case_stat				{}
		| case_stat					{}
		;

expr		:
		unary_expr					{$$ = $1;}
		| binary_expr					{$$ = $1;}
		| switch_expr					{$$ = $1;}
		| if_expr					{$$ = $1;}
		| while_expr					{$$ = $1;}
		| for_expr					{$$ = $1;}
		| assign_expr					{$$ = $1;}
		| def_expr					{$$ = $1;}
		;

unary_expr	:
		number						{$$ = $1;}
		| id						{$$ = new Node(EXPR_T, $1);}
		| address_id					{$$ = new Node(EXPR_T, $1);}
		| variable_dec					{$$ = $1}
		;				

binary_expr	:
		;

assign_expr	:
		expr EQUALS expr				{$$ = new parserNode(EXPR_T, NULL_S, $1, new Node(ASSIGN_T,NULL_S), $3);}
		| expr compound_assign expr			{$$ = new parserNode(EXPR_T, NULL_S, $1, new Node(ASSIGN_T,NULL_S), new parserNode(EXPR_T,NULL_S, $1, $2, $3));}
		;

const_expr	:
		;

for_cond	:
		FOR OPEN_BRACKET expr EOS expr EOS expr CLOSE_BRACKET
								{}
		;

for_expr	:
		for_cond bracketed_expr_list			{}
		;

struct_def_param_list:
		struct_def_param_list variable_dec EOS
								{
								$$ = $1;
								 variableNode* variable = (variableNode*)((Node*)$2);
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

def_expr	:
		struct						{}
		| enum						{}
		| union						{}
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
	return 0;
}



void yyerror (char const *s)
{

  std::cerr << s << " at " << yylval.str  << " " << columnnum << std::endl;
}


