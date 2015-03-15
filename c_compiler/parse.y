
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
	#include <vector>

	void yyerror (char const *s);

	int linenum = 1;
	int columnnum = 1;

	int anonymousnum = 0;

%}

%union{
	char* str;
	type_t list;
	abstractNode* node;
	type_t type;
}

%token<str> ADDRESS_OR_BITWISE_AND ARITHMETIC AUTO BITWISE_INVERSE BITWISE_LEFT BITWISE_OR BITWISE_RIGHT BITWISE_XOR BREAK CASE CHAR CLOSE_BRACKET CLOSE_CURLY_BRACKET CLOSE_SQUARE_BRACKET COLON COMMA CONST CONTINUE DECREMENT DEFAULT DO ELLIPSES ELSE ENUM EQUALS EOS EXTERN FLOAT FOR FULL_STOP GOTO GREATER_THAN_EQUALS GREATER_THAN ID IF INCREMENT INT INVERSE LESS_THAN_EQUALS LESS_THAN LOGICAL_AND LOGICAL_EQUALS LOGICAL_OR MULT_OR_POINTER NOT_EQUALS NOT OPEN_BRACKET OPEN_CURLY_BRACKET OPEN_SQUARE_BRACKET POINTER_MEMBER REGISTER RETURN SIZEOF STATIC STRING STRUCT SWITCH TYPEDEF TYPE_SIGNED TYPE_UNSIGNED TYPE_PROMOTION TYPE_LONG TYPE_SHORT TYPE UNION UNKNOWN VOLATILE WHILE CONDITIONAL_OPERATOR

%type<node> variable_dec_single typedef  pointer_list variable_dec address_id number parameter_list  unknown  variable_dec_stype function_def struct_def_param_list qualifier_list assign_expr expr unary_expr binary_expr switch_expr while_expr if_expr for_expr compound_assign logic_op arithmetic_op bitwise_op

%type<str> qualifier storage length signed modifier address id

%type<list> address_list id_list modifier_list

%type<type> basic_type pointer type non_pointer_type non_pointer_basic_type enum struct_use struct_def struct union union_use  enum_def enum_use union_def modified_struct modified_union modified_enum


%start	test

%%

test		:						//For debugging purposes
		variable_dec_single				{std::cout << "Test successful" << std::endl;
									root = $1;}
		;



typedef		:
		TYPEDEF variable_dec_single EOS			{$$ = new parserNode(TYPEDEF_T, NULL_S, $2,NULL,$3);
										//Add code to insert tpe into map/vector
								}
		;

basic_type 	:						//int, char, void etc.
		TYPE						{$$ = getType($1);}
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
		type id						{ $$ = new variableNode(VAR_T, $2, $1);}//int x
		| type assign_expr				{/* link id to type */
									}//int x = 1
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
		id_list COMMA id				{}
		| id						{}
		| id_list COMMA assign_expr			{}
		| assign_expr					{}
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

		| modifier_list basic_type modifier_list 	{$$ = $2;}	//const unsigned int volatile etc.

		| basic_type modifier_list 			{$$ = $2;
									
								}	//int unsigned

		| modifier_list basic_type 			{$$ = $2;
									
								}	//unsigned int

		| modifier_list					{$$ = getType("int");
									//Evaluate modifiers
								}	//unsigned
		;

id		:
		ID						{$$ = $1;}
		;

address_id	:
		address_list id					{/*Pop back and add for every address item*/

								}
		;

address		:
		MULT_OR_POINTER					{$$ = $1}
		| ADDRESS_OR_BITWISE_AND			{$$ = $1}
		;

address_list	:
		address_list address				{/* Add code to build list of $1 and add $2*/}
		| address					{/* Add code to build list of $1*/}
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
									/* add struct definition into storage*/}
		| STRUCT OPEN_CURLY_BRACKET struct_def_param_list CLOSE_CURLY_BRACKET
								{
									/*add struct definition into storage*/
									anonymousnum++;
									}
		;

struct_use 	:							//struct s
		STRUCT id					{}
		;

struct 		:
		struct_def					{}	//struct s{...}
		| struct_use					{}	//struct s
		;

function_def 	:
		variable_dec_single OPEN_BRACKET parameter_list CLOSE_BRACKET OPEN_CURLY_BRACKET parameter_list CLOSE_CURLY_BRACKET
								{}
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

program		:
		/*................................................			{root = new ..............*/
		;

enum_def	:
		ENUM id OPEN_CURLY_BRACKET struct_def_param_list CLOSE_CURLY_BRACKET	
								{
									/* add enum definition into storage*/}
		| ENUM OPEN_CURLY_BRACKET struct_def_param_list CLOSE_CURLY_BRACKET
								{
									/*add enum definition into storage*/
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
		UNION id OPEN_CURLY_BRACKET struct_def_param_list CLOSE_CURLY_BRACKET	
								{
									/* add union definition into storage*/}
		| UNION OPEN_CURLY_BRACKET struct_def_param_list CLOSE_CURLY_BRACKET
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
		expr_list expr					{}
		| expr						{}
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
		;

unary_expr	:
		number						{$$ = $1;}
		| id						{$$ = new Node(EXPR_T, $1);}
		| address_id					{$$ = $1;}
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
		struct_def_param_list EOS variable_dec		{}		//int x; int y; char z ...
		| variable_dec					{}
		;

%%

int main()
{
	yyparse();
	return 0;
}



void yyerror (char const *s)
{

  std::cerr << s << std::endl;
}


