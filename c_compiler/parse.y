
%code requires{
	extern "C" int yylex();
}

%{
	#include <iostream>
	
	#include "parse.tab.h"	//Required to find yylex function
				//parse.tab.h must be editted to include "extern "C" int yylex();"
	extern int yyerror(char* str);
	extern int yywrap();

%}

%token ADDRESS_OR_BITWISE_AND_T ARITHMETIC_T AUTO_T BITWISE_INVERSE_T BITWISE_LEFT_T BITWISE_OR_T BITWISE_RIGHT_T BITWISE_XOR_T BREAK_T CASE_T CHAR_T CLOSE_BRACKET_T CLOSE_CURLY_BRACKET_T CLOSE_SQUARE_BRACKET_T COLON_T COMMA_T CONST_T CONTINUE_T DECREMENT_T DEFAULT_T DO_T ELLIPSES_T ELSE_T ENUM_T EQUALS_T EOS_T EXTERN_T FLOAT_T FOR_T FULL_STOP_T GOTO_T GREATER_THAN_EQUALS_T GREATER_THAN_T ID_T IF_T INCREMENT_T INT_T INVERSE_T LESS_THAN_EQUALS_T LESS_THAN_T LOGICAL_AND_T LOGICAL_EQUALS_T LOGICAL_OR_T MULT_OR_POINTER_T NOT_EQUALS_T NOT_T OPEN_BRACKET_T OPEN_CURLY_BRACKET_T OPEN_SQUARE_BRACKET_T POINTER_MEMBER_T REGISTER_T RETURN_T SIZEOF_T STATIC_T STRING_T STRUCT_T SWITCH_T TYPEDEF_T TYPE_LENGTH_T TYPE_PROMOTION_T TYPE_SIGNED_T TYPE_T UNION_T UNKNOWN VOLATILE_T WHILE_T CONDITIONAL_OPERATOR_T
			
%start	program

%%

typedef		:
		TYPEDEF_T variable_dec EOS_T			{/*Add code for adding to list of types*/}
		;

basic_type 	:
		TYPE_T						//int, char, void etc.
		;

qual_pointer 	:						//The qualifier for a pointer comes after the respective pointer
		MULT_OR_POINTER_T qualifier_list		//*const
		;

pointer 	:				
		qual_pointer					//*const
		| MULT_OR_POINTER_T				//*
		;

pointer_list 	:						//Unbounded list of pointers
 		pointer pointer_list 
		| pointer
		;

qualifier 	:
		CONST_T						//const
		| VOLATILE_T					//volatile
		;

storage 	:		
		EXTERN_T					//extern
		| AUTO_T					//auto
		| STATIC_T					//static
		| REGISTER_T					//register
		;

variable_dec 	:
		 type ID_T					//int x, int***const* x
		;

type 		:
		 non_pointer_type pointer_list 				//int x***
		| non_pointer_type					//int x
		;

non_pointer_type :							//all of the following can be used as a type or the basis for a pointer
		non_pointer_basic_type
		| modified_struct
		| modified_enum
		| modified_union
		;

non_pointer_basic_type :
		 modifier_list basic_type modifier_list 		//const unsigned int volatile etc.
		| basic_type modifier_list 				//int unsigned
		| modifier_list basic_type 				//unsigned int
		| modifier_list						//unsigned
		;

id		:
		ID_T						{/*Add code to change to TYPE_T if i map of types*/}
		| MULT_OR_POINTER_T+ ID_T		//dereferenced id
		| ADDRESS_OR_BITWISE_AND_T+ id		//address of id
		| MULT_OR_POINTER_T+ ADDRESS_OR_BITWISE_AND_T+ id		//dereferences of addresses of id
		| ADDRESS_OR_BITWISE_AND_T+ MULT_OR_POINTER_T+ id		//address of dereferences of id
		;

length 		:
		TYPE_LENGTH_T				//long, short
		;

signed 		:
		TYPE_SIGNED_T				//signed, unsigned
		;

struct_def 	:					//struct s{...}
		STRUCT_T id OPEN_CURLY_BRACKET_T /*....................................*/ CLOSE_CURLY_BRACKET_T
		;

struct_use 	:
		STRUCT_T id				//struct s
		;

struct 		:
		struct_def				//struct s{...}
		| struct_use				//struct s
		;

function_def 	:
		variable_dec OPEN_BRACKET_T parameter_list CLOSE_BRACKET_T OPEN_CURLY_BRACKET_T /*....................................*/ CLOSE_CURLY_BRACKET_T
		;

modifier 	:
		length				//short, long
		| storage			//extern, static, auto, register
		| qualifier			//const, volatile
		| signed			//signed, unsigned
		;

modifier_list 	:				//unbounded list of length, storage, quaifier and signed modifiers. Exact order does not matter. Validity must be checked later
		 modifier modifier_list 	
		| modifier
		;

modified_struct :
		 qualifier_list struct 		//const struct ...
		| struct			//struct ...
		;

number 		:
		INT_T				//01234, 0x134, 0b1111
		| FLOAT_T			//0213.21414
		;

parameter_list 	:				//unbounded list of variable declerations
		 variable_dec COMMA_T parameter_list 
		| variable_dec
		;

program		:
		/*..............................................................*/
		;

enum		:
		ENUM_T id OPEN_CURLY_BRACKET_T /*....................................*/ CLOSE_CURLY_BRACKET_T			//enum x{...}	-normal
		| ENUM_T OPEN_CURLY_BRACKET_T /*....................................*/ CLOSE_CURLY_BRACKET_T			//enum {...}	-anonymous
		;

modified_enum	:
		qualifier_list enum			//const enum ...
		| enum					//enum ...
		;

union		:
		UNION_T id OPEN_CURLY_BRACKET_T /*....................................*/ CLOSE_CURLY_BRACKET_T		//union x{...}	-normal
		| UNION_T OPEN_CURLY_BRACKET_T /*....................................*/ CLOSE_CURLY_BRACKET_T		//union {...}	-anonymous
		;

modified_union	:
		qualifier_list union			//const union ...
		| union					//union ...
		;

compound_assign	:
		NOT_T EQUALS_T				//!=		
		| arithmetic_op EQUALS_T		//+= -= *= /=
		| bitwise_op EQUALS_T			//^= <<= >>= etc.
		;

address		:
		
		;

logic_op	:
		NOT_T					//!
		| GREATER_THAN_T			//>
		| GREATER_THAN_EQUALS_T			//>=
		| LESS_THAN_EQUALS_T			//<=
		| LESS_THAN_T				//<
		| LOGICAL_AND_T				//&&
		| LOGICAL_EQUALS_T			//==
		| LOGICAL_OR_T				//||
		;

bitwise_op	:
		ADDRESS_OR_BITWISE_AND_T		//&
		| BITWISE_INVERSE_T			//~
		| BITWISE_LEFT_T			//<<
		| BITWISE_OR_T				//|
		| BITWISE_RIGHT_T			//>>
		| BITWISE_XOR_T				//^
		;

qualifier_list	:
		qualifier qualifier			//const volatile
		| qualifier				//const
		;

type_cast	:					//(const unsigned int**const*)
		OPEN_BRACKET_T type CLOSE_BRACKET_T
		;

unknown		:
		UNKNOWN					{std::cout << "Unknown value found " << $1 << std::endl;}
		;

arithmetic_op	:
		ARITHMETIC_T
		| MULT_OR_POINTER_T
		;

if_cond		:
		IF_T OPEN_BRACKET_T expr CLOSE_BRACKET_T
		;

while_cond	:
		WHILE_T OPEN_BRACKET_T expr CLOSE_BRACKET_T bracketed_expr_list 
		;

while_expr	:
		while_cond bracketed_expr_list					//while(true){...} 
		| DO_T bracketed_expr_list while_cond EOS_T		//do{...}while(true);
		;

bracketed_expr_list :
		OPEN_CURLY_BRACKET_T expr_list CLOSE_CURLY_BRACKET_T
		| expr								//If it is only a single expression, brackets are not needed
		;

expr_list	:
		expr_list expr
		| expr
		;

if_expr		:
		if_cond bracketed_expr_list
		;

switch_cond	:
		SWITCH_T OPEN_BRACKET_T expr CLOSE_BRACKET_T
		;

switch_expr	:
		switch_cond OPEN_CURLY_BRACKET_T case_list CLOSE_CURLY_BRACKET_T
		;

case_stat	:
		CASE_T const_expr COLON_T expr_list
		| CASE_T const_expr COLON_T bracketed_expr_list
		;

expr_list 	:
		expr expr_list
		| expr
		;

case_list 	:
		case_stat case_list
		| case_stat
		;

expr		:
		unary_expr
		| binary_expr
		| switch_expr
		| if_expr
		| while_exprpr
		| for_expr
		;

unary_expr	:
		;				

binary_expr	:
		;

assign_expr	:
		id EQUALS_T expr;
		;

const_expr	:
		;

for_cond	:
		FOR_T OPEN_BRACKET_T expr EOS_T expr EOS_T expr CLOSE_BRACKET_T
		;

for_expr	:
		for_cond bracketed_expr_list
		;

%%

int main()
{
	yyparse(); e
	return 0;
}

int yyerror (char* str) 		/* default action in case of error in yylex() */
{   
	printf (" error%s\n", str);  
	exit(0); 
} 

int yywrap ()
{
	return 1;
}


