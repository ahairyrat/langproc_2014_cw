
%{
	#include <string.h>
	#include <stdio.h>
	
	#include "parse.tab.h"	//Required to find yylex function
				//parse.tab.h must be editted to include     extern "C" int yylex();
	
	int yyparse();
	int yyerror(char* str);
	int yywrap();

%}

%token ADDRESS_OR_BITWISE_AND_T ARITHMETIC_T AUTO_T BITWISE_INVERSE_T BITWISE_LEFT_T BITWISE_OR_T BITWISE_RIGHT_T BITWISE_XOR_T BREAK_T CASE_T CHAR_T CLOSE_BRACKET_T CLOSE_CURLY_BRACKET_T CLOSE_SQUARE_BRACKET_T COLON_T COMMA_T CONST_T CONTINUE_T DECREMENT_T DEFAULT_T DO_T ELLIPSES_T ELSE_T ENUM_T EQUALS_T EOS_T EXTERN_T FLOAT_T FOR_T FULL_STOP_T GOTO_T GREATER_THAN_EQUALS_T GREATER_THAN_T ID_T IF_T INCREMENT_T INT_T INVERSE_T LESS_THAN_EQUALS_T LESS_THAN_T LOGICAL_AND_T LOGICAL_EQUALS_T LOGICAL_OR_T MULT_OR_POINTER_T NOT_EQUALS_T NOT_T OPEN_BRACKET_T OPEN_CURLY_BRACKET_T OPEN_SQUARE_BRACKET_T POINTER_MEMBER_T REGISTER_T RETURN_T SIZEOF_T STATIC_T STRING_T STRUCT_T SWITCH_T TYPEDEF_T TYPE_LENGTH_T TYPE_PROMOTION_T TYPE_SIGNED_T TYPE_T UNION_T UNKNOWN VOLATILE_T WHILE_T CONDITIONAL_OPERATOR_T
			

%%

typedef		:
		TYPEDEF_T variable EOS_T			{/*Add code for adding to list of types*/}
		;

basic_type 	:
		TYPE_T
		;

qual_pointer 	:
		MULT_OR_POINTER_T qualifier
		;

pointer 	:
		qual_pointer
		| MULT_OR_POINTER_T
		;

pointer_list 	:
 		pointer pointer_list 
		| pointer
		;

qualifier 	:
		CONST_T
		| VOLATILE_T
		;

storage 	:
		EXTERN_T
		| AUTO_T
		| STATIC_T
		| REGISTER_T
		;

variable 	:
		 type dereferenced_id 
		| dereferenced_id
		;

type 		:
		 non_pointer_type pointer_list 
		| non_pointer_type
		;

non_pointer_type :
		non_pointer_basic_type
		| modified_struct
		;

non_pointer_basic_type :
		 modifier_list basic_type modifier_list 
		|  basic_type modifier_list 
		|  modifier_list basic_type 
		| modifier_list
		;

dereferenced_id :
		OPEN_BRACKET_T MULT_OR_POINTER_T id CLOSE_BRACKET_T 
		| id
		;

id		:
		ID_T			{/*Add code to change to TYPE_T if i map of types*/}
		;

length 		:
		TYPE_LENGTH_T
		;

signed 		:
		TYPE_SIGNED_T
		;

struct_def 	:
		STRUCT_T ID_T OPEN_CURLY_BRACKET_T /*....................................*/ CLOSE_CURLY_BRACKET_T
		;

struct_use 	:
		STRUCT_T ID_T
		;

struct 		:
		struct_def
		| struct_use
		;

function_def 	:
		variable OPEN_BRACKET_T parameter_list CLOSE_BRACKET_T OPEN_CURLY_BRACKET_T /*....................................*/ CLOSE_CURLY_BRACKET_T
		;

modifier 	:
		length
		| storage
		| qualifier
		| signed
		;

modifier_list 	:
		 modifier modifier_list 
		| modifier
		;

modified_struct :
		 modifier_list struct 
		| struct
		;

number 		:
		INT_T
		| FLOAT_T
		;

parameter_list 	:
		 variable COMMA_T parameter_list 
		| variable
		;

%%


int main()
{
	yyparse();
	return 0;
}

int yyerror (char* str) 		/* default action in case of error in yylex() */
{   
	printf (" error%s\n", str);  
	exit(0); 
} 

int yywrap ()
{
}

