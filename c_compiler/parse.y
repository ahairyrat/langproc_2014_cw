
%header{
	#include <iostream>
	#include <fstream>
	#include <cstdlib>
	using namespace std;
%}

%{
	#include <FlexLexer.h>
%}

%name C_Parser
%define MEMBERS           	\
    virtual ~C_Parser()   {} 	\
    private:                   	\
       yyFlexLexer lexer;
%define LEX_BODY {return lexer.yylex();}
%define ERROR_BODY {cerr << "error encountered at line: "<<lexer.lineno()<<" last word parsed:"<<lexer.YYText()<<"\n";}

%union{
  	char* str;
	int   intval;
}


%token<str> ADDRESS_OR_BITWISE_AND_T ARITHMETIC_T AUTO_T BITWISE_INVERSE_T BITWISE_LEFT_T BITWISE_OR_T BITWISE_RIGHT_T BITWISE_XOR_T BREAK_T CASE_T CHAR_T CLOSE_BRACKET_T CLOSE_CURLY_BRACKET_T CLOSE_SQUARE_BRACKET_T COLON_T COMMA_T CONST_T CONTINUE_T DECREMENT_T DEFAULT_T DO_T ELLIPSES_T ELSE_T ENUM_T EQUALS_T EOS_T EXTERN_T FLOAT_T FOR_T FULL_STOP_T GOTO_T GREATER_THAN_EQUALS_T GREATER_THAN_T ID_T IF_T INCREMENT_T INT_T INVERSE_T LESS_THAN_EQUALS_T LESS_THAN_T LOGICAL_AND_T LOGICAL_EQUALS_T LOGICAL_OR_T MULT_OR_POINTER_T NOT_EQUALS_T NOT_T OPEN_BRACKET_T OPEN_CURLY_BRACKET_T OPEN_SQUARE_BRACKET_T POINTER_MEMBER_T REGISTER_T RETURN_T SIZEOF_T STATIC_T STRING_T STRUCT_T SWITCH_T TYPEDEF_T TYPE_LENGTH_T TYPE_PROMOTION_T TYPE_SIGNED_T TYPE_T UNION_T UNKNOWN VOLATILE_T WHILE_T CONDITIONAL_OPERATOR_T
			
%start	test

%%

typedef		:
		TYPEDEF_T variable_dec_single EOS_T			{cout << "Found " << $1 << " " << $2 <<" " << $3 << endl;
										/*Add code for adding to list of types*/}
		;

basic_type 	:							//int, char, void etc.
		TYPE_T							{}
		;

qual_pointer 	:						//The qualifier for a pointer comes after the respective pointer
		MULT_OR_POINTER_T qualifier_list		{}
		;

pointer 	:					
		qual_pointer					{}//*const
		| MULT_OR_POINTER_T				{}//*
		;

pointer_list 	:						//Unbounded list of pointers
 		pointer_list pointer 				{}
		| pointer					{}
		;

qualifier 	:
		CONST_T						{}//const
		| VOLATILE_T					{}//volatile
		;

storage 	:		
		EXTERN_T					{}//extern
		| AUTO_T					{}//auto
		| STATIC_T					{}//static
		| REGISTER_T					{}//register
		;

variable_dec_single:
		 type ID_T					{}//int x, int***const* x
		;

variable_dec_stype:
		type id_list					{}//int x, y, z
		;

variable_dec	:
		variable_dec_single				{}//int x
		| variable_dec_stype				{}//int x, y, z
		;

id_list		:							//unbounded list of comma seperate identifiers
		id_list COMMA_T id				{}
		| id						{}
		;

type 		:
		 non_pointer_type pointer_list 			{}	//int x***
		| non_pointer_type				{}	//int x
		;

non_pointer_type :							//all of the following can be used as a type or the basis for a pointer
		non_pointer_basic_type				{}
		| modified_struct				{}
		| modified_enum					{}
		| modified_union				{}
		;

non_pointer_basic_type :
		 modifier_list basic_type modifier_list 	{}	//const unsigned int volatile etc.
		| basic_type modifier_list 			{}	//int unsigned
		| modifier_list basic_type 			{}	//unsigned int
		| modifier_list					{}	//unsigned
		;

id		:
		ID_T						{cout << "Found ID " << $1. << endl;
								/*Add code to change to TYPE_T if i map of types*/}
		;

address_id	:
		address_list id					{}
		;

address		:
		MULT_OR_POINTER_T				{}
		| ADDRESS_OR_BITWISE_AND_T			{}
		;

address_list	:
		address_list address				{}
		| address					{}
		;

length 		:							//long, short
		TYPE_LENGTH_T					{}
		;

signed 		:							//signed, unsigned
		TYPE_SIGNED_T					{}
		;

struct_def 	:					//struct s{...}
		STRUCT_T id OPEN_CURLY_BRACKET_T struct_def_param_list CLOSE_CURLY_BRACKET_T	
								{}
		| STRUCT_T OPEN_CURLY_BRACKET_T struct_def_param_list CLOSE_CURLY_BRACKET_T
								{}
		;

struct_use 	:							//struct s
		STRUCT_T id					{}
		;

struct 		:
		struct_def					{}	//struct s{...}
		| struct_use					{}	//struct s
		;

function_def 	:
		variable_dec_single OPEN_BRACKET_T parameter_list CLOSE_BRACKET_T OPEN_CURLY_BRACKET_T parameter_list CLOSE_CURLY_BRACKET_T
								{}
		;

modifier 	:
		length						{}	//short, long
		| storage					{}	//extern, static, auto, register
		| qualifier					{}	//const, volatile
		| signed					{}	//signed, unsigned
		;

modifier_list 	:				//unbounded list of length, storage, quaifier and signed modifiers. 
						//Exact order does not matter. Validity must be checked later
		 modifier_list modifier				{}
		| modifier					{}
		;

modified_struct :
		 qualifier_list struct 				{}	//const struct ...
		| struct					{}	//struct ...
		;

number 		:
		INT_T						{}	//01234, 0x134, 0b1111
		| FLOAT_T					{}	//0213.21414
		;

parameter_list 	:				//unbounded list of variable declerations
		 parameter_list COMMA_T variable_dec_single 	{}
		| variable_dec_single				{}
		;

program		:
		/*..............................................................*/
		;

enum_def	:
		ENUM_T id OPEN_CURLY_BRACKET_T /*....................................*/ CLOSE_CURLY_BRACKET_T	
								{}	//enum x{...}	-normal
		| ENUM_T OPEN_CURLY_BRACKET_T /*....................................*/ CLOSE_CURLY_BRACKET_T
								{}	//enum {...}	-anonymous
		;

enum_use	:
		ENUM_T id					{}
		;

enum		:
		enum_def					{}
		| enum_use					{}
		;

modified_enum	:
		qualifier_list enum				{}	//const enum ...
		| enum						{}	//enum ...
		;

union_def	:
		UNION_T id OPEN_CURLY_BRACKET_T struct_def_param_list CLOSE_CURLY_BRACKET_T
								{}	//union x{...}	-normal
		| UNION_T OPEN_CURLY_BRACKET_T struct_def_param_list CLOSE_CURLY_BRACKET_T
								{}	//union {...}	-anonymous
		;

union_use	:
		UNION_T id					{}
		;

union		:
		union_def					{}
		| union_use					{}
		;

modified_union	:
		qualifier_list union				{}	//const union ...
		| union						{}	//union ...
		;

compound_assign	:
		NOT_T EQUALS_T					{}	//!=		
		| arithmetic_op EQUALS_T			{}	//+= -= *= /=
		| bitwise_op EQUALS_T				{}	//^= <<= >>= etc.
		;

logic_op	:
		NOT_T						{}	//!
		| GREATER_THAN_T				{}	//>
		| GREATER_THAN_EQUALS_T				{}	//>=
		| LESS_THAN_EQUALS_T				{}	//<=
		| LESS_THAN_T					{}	//<
		| LOGICAL_AND_T					{}	//&&
		| LOGICAL_EQUALS_T				{}	//==
		| LOGICAL_OR_T					{}	//||
		;

bitwise_op	:
		ADDRESS_OR_BITWISE_AND_T			{}	//&
		| BITWISE_INVERSE_T				{}	//~
		| BITWISE_LEFT_T				{}	//<<
		| BITWISE_OR_T					{}	//|
		| BITWISE_RIGHT_T				{}	//>>
		| BITWISE_XOR_T					{}	//^
		;

qualifier_list	:
		qualifier qualifier				{}	//const volatile
		| qualifier					{}	//const
		;

type_cast	:					//(const unsigned int**const*)
		OPEN_BRACKET_T type CLOSE_BRACKET_T		{}
		;

unknown		:
		UNKNOWN					{std::cout << "Unknown value found " << $1 << std::endl;}
		;

arithmetic_op	:
		ARITHMETIC_T					{}
		| MULT_OR_POINTER_T				{}
		;

if_cond		:
		IF_T OPEN_BRACKET_T expr CLOSE_BRACKET_T	{}
		;

while_cond	:
		WHILE_T OPEN_BRACKET_T expr CLOSE_BRACKET_T bracketed_expr_list 
								{}
		;

while_expr	:
		while_cond bracketed_expr_list			{}			//while(true){...} 
		| DO_T bracketed_expr_list while_cond EOS_T	{}			//do{...}while(true);
		;

bracketed_expr_list :
		OPEN_CURLY_BRACKET_T expr_list CLOSE_CURLY_BRACKET_T
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
		SWITCH_T OPEN_BRACKET_T expr CLOSE_BRACKET_T	{}
		;

switch_expr	:
		switch_cond OPEN_CURLY_BRACKET_T case_list CLOSE_CURLY_BRACKET_T
								{}
		;

case_stat	:
		CASE_T const_expr COLON_T expr_list		{}
		| CASE_T const_expr COLON_T bracketed_expr_list	{}
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
		unary_expr					{}
		| binary_expr					{}
		| switch_expr					{}
		| if_expr					{}
		| while_expr					{}
		| for_expr					{}
		;

unary_expr	:
		;				

binary_expr	:
		;

assign_expr	:
		id EQUALS_T expr				{}
		;

const_expr	:
		;

for_cond	:
		FOR_T OPEN_BRACKET_T expr EOS_T expr EOS_T expr CLOSE_BRACKET_T
								{}
		;

for_expr	:
		for_cond bracketed_expr_list			{}
		;

struct_def_param_list:
		struct_def_param_list EOS_T variable_dec	{}		//int x; int y; char z ...
		| variable_dec					{}
		;

test		:								//For debugging purposes
		id						{}
		;

%%

int main()
{
	C_Parser parser;
	parser.yyparse();
	return 0;
}


