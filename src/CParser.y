

//code does not take into account mathematic precedence

%code requires{

	#include <stdio.h>
	#include "../includes/FlexDef.h"
	#include "../includes/Errors.h"
	
	int yylex();
		
	extern FILE* yyin;
	extern int linenum;
}

%{
	#include "CParser.hpp"
	#include <sstream>
	#include <cstring>

	void yyerror (char const *s);

	int anonymousnum = 0;

	int enum_val = 0;
	
	bool error = true;

	int linenum = 1;

%}

%union{
	char* str;
	list_t list;
	struct_list_t s_list;
	abstractNode* node;
	type_t type;
	int int_t;
	node_list_t node_list;
}

%token<str> ADDRESS_OR_BITWISE_AND ARITHMETIC AUTO BITWISE_INVERSE BITWISE_LEFT BITWISE_OR BITWISE_RIGHT BITWISE_XOR BREAK CASE CHAR CLOSE_BRACKET CLOSE_CURLY_BRACKET CLOSE_SQUARE_BRACKET COLON COMMA CONST CONTINUE DECREMENT DEFAULT DO ELLIPSES ELSE ENUM EQUALS EOS EXTERN FLOAT FOR FULL_STOP GOTO GREATER_THAN_EQUALS GREATER_THAN ID IF INCREMENT INT INVERSE LESS_THAN_EQUALS LESS_THAN LOGICAL_AND LOGICAL_EQUALS LOGICAL_OR MULT_OR_POINTER NOT_EQUALS NOT OPEN_BRACKET OPEN_CURLY_BRACKET OPEN_SQUARE_BRACKET POINTER_MEMBER REGISTER RETURN SIZEOF STATIC STRING STRUCT SWITCH TYPEDEF TYPE_SIGNED TYPE_UNSIGNED TYPE_PROMOTION TYPE_LONG TYPE_SHORT TYPE UNION UNKNOWN VOLATILE WHILE CONDITIONAL_OPERATOR STRUCT_TYPE ENUM_TYPE UNION_TYPE

%type<node> variable_dec_single variable_dec number unknown variable_dec_stype function_def  assign_expr expr unary_expr binary_expr switch_statement while_statement if_statement for_statement compound_assign logic_op arithmetic_op bitwise_op statement_list program_block bracketed_statement_list function_dec program def_expr rexpr lexpr cond_statement statement return type_cast for_cond while_cond if_cond const_expr if_main else function_call

%type<str> qualifier storage length signed modifier id address_id array id_or_array struct_member

%type<list> id_list modifier_list qualifier_list

%type<type> basic_type type non_pointer_type non_pointer_basic_type union_def modified_union  union union_use enum enum_def enum_use modified_enum struct_use struct_def struct modified_struct data_structure

%type<s_list> struct_def_param_list enum_def_param_list parameter_list

%type<int_t> pointer_list pointer address address_list

%type<node_list> parameter_send_list

%right EQUALS INVERSE CLOSE_BRACKET CLOSE_CURLY_BRACKET CLOSE_SQUARE_BRACKET

%left ARITHMETIC ADDRESS_OR_BITWISE_AND BITWISE MULT_OR_POINTER BITWISE_INVERSE  BITWISE_LEFT BITWISE_OR BITWISE_RIGHT BITWISE_XOR NOT INCREMENT DECREMENT OPEN_BRACKET OPEN_CURLY_BRACKET OPEN_SQUARE_BRACKET COMMA ELSE IF

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
									yyerror("Is not a basic type");
								}
		;

pointer 	:					
		MULT_OR_POINTER						{/*Link through pointer*/}//*
		//| MULT_OR_POINTER qualifier_list			{/*Link through qualified pointer*/}//*const
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
		non_pointer_type id_or_array				{ 
								  $$ = NULL;
								  if($1 != NULL)	
									$$ = new variableNode(VAR_T, $2, $1, $1 -> namespacev, linenum);
								  else
									yyerror("Is not a type");
								}//int x
		;

variable_dec_stype:
		non_pointer_type id_list					{
								std::list<std::string>::iterator i;
								 if($1 != NULL){
									$$ = new variableNode(VAR_T, *($2->begin()), $1, $1 -> namespacev, linenum);
									i = $2->begin();
									i++;						//Get iterator to secoond value
									for( i; i != $2->end(); i++)
									{
										if(((Node*)$$)->node_type == "parserNode" && ((Node*)$$) -> id == NULL_T)
										{
											parserNode* temp = (parserNode*)((typeNode*)((Node*)($$)));
											parserNode* temp2;
								  			while(((Node*)temp)->node_type == "parserNode" && ((Node*)temp) -> id == NULL_T)
											{
												temp2 = temp;
												temp = (parserNode*)((typeNode*)((Node*)(temp -> RHS)));
											}
		
								  			temp =  new parserNode(NULL_T, NULL_S, temp, NULL, new variableNode(VAR_T, *i, $1, $1 -> namespacev,linenum), linenum);
											temp2 -> RHS = temp;
										}
										else{
 											$$ =  new parserNode(NULL_T, NULL_S, $$, NULL, new variableNode(VAR_T, *i, $1, $1 -> namespacev, linenum), linenum);
										}
									}
								}
									  
								 else
								{
									$$ = NULL;
									yyerror("Is not a type");
								}
								}//int x, y, z
		;

variable_dec	:
		variable_dec_single				{$$ = $1}//int x
		| variable_dec_stype				{$$ = $1}//int x, y, z
		;

id_list		:						 //unbounded list of comma seperate identifiers
		id_list COMMA id_or_array			{$$ = $1; $$ -> insert($$ -> end(), *(new std::string($3)));}
		| id_or_array COMMA id_or_array			{$$ = new std::list<std::string>;
									$$ -> insert($$ -> end(), *(new std::string($1)));
									$$ -> insert($$ -> end(), *(new std::string($3)));
								}
		;

id_or_array	:
		id array					{std::stringstream ss;
								 ss << $2 << $1;
								 $$ = strdup(ss.str().c_str());
									 				//VariableNames that start with a [x] are considered arrays of that size x (x can be a number or variable)
								}
		| id						{$$ = $1;}
		| struct_member					{$$ = $1;}				//VariableNames that start with .x. are struct members, -x- are pointer members
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
										yyerror("Is not a type");
											
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
/*		| modifier_list basic_type modifier_list 	{$$ = $2;
									$1 -> splice($1 -> end(), *$3);
									yyerror("Not implemented yet");
									//evaluate modifiers
								}	//const unsigned int volatile etc.
		| basic_type modifier_list 			{$$ = $1;
									yyerror("Not implemented yet");
									//Evaluate modifiers
								}	//int unsigned
		| modifier_list basic_type 			{$$ = $2;
									yyerror("Not implemented yet");
									//Evaluate modifiers
								}	//unsigned int
		| modifier_list					{$$ = getType("int", "type");
									yyerror("Not implemented yet");
									//Evaluate modifiers
								}	//unsigned*/
		;

id		:
		ID						{$$ = $1;}
		;

address_id	:
		address_list id					{std::stringstream ss;
								ss << '*';
								ss << $1;
								ss  << '*';
								ss << $2;
								$$ = strdup(ss.str().c_str());
								}
		;

address		:
		pointer						{$$ = 1}
		| ADDRESS_OR_BITWISE_AND			{$$ = -1}
		;

address_list	:
		address address_list				{$$ = $2; $$+=$1}
		| address					{$$ = $1}
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
									yyerror("Struct has been previously defined");
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
		STRUCT STRUCT_TYPE				{$$ = getType($2, "struct");
								   if($$ == NULL)
									yyerror("Struct has not been defined");
								}
		;

struct 		:
		struct_def					{$$ = $1}	//struct s{...}
		| struct_use					{$$ = $1}	//struct s
		;

function_def 	:
		function_dec bracketed_statement_list		{$$ = new functionNode(FUNC_T, NULL_S, $1, $2, linenum);}
		;

function_dec	:
		variable_dec_single OPEN_BRACKET parameter_list CLOSE_BRACKET	{$$ = new functionDecNode(FUNC_DEF_T, (variableNode*)((Node*)$1), build_struct_members($3), linenum);
										 delete $1;}
		| variable_dec_single OPEN_BRACKET CLOSE_BRACKET		{$$ = new functionDecNode(FUNC_DEF_T, (variableNode*)((Node*)$1), *(new std::vector<struct_member>()), linenum);
										 delete $1;}
		;

function_call 	:
		id OPEN_BRACKET parameter_send_list CLOSE_BRACKET 	{
									$$ = new functionCallNode(FUNC_CALL_T, $1, $3, linenum);
									}
		| id OPEN_BRACKET CLOSE_BRACKET				{$$ = new functionCallNode(FUNC_CALL_T, $1, NULL, linenum);}
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
		INT						{$$ = new variableNode(CONST_T, $1, getType("int", "type"), "const", linenum)}	//01234, 0x134, 0b1111
		| FLOAT						{$$ = new variableNode(CONST_T, $1, getType("float", "type"), "const",linenum)}	//0213.21414
		;

parameter_list 	:				//unbounded list of variable declerations
		 variable_dec_single COMMA parameter_list  	{$$ = $3;
								 variableNode* variable = (variableNode*)((Node*)$1);
								 struct_member newMember;
								 newMember.id = variable -> val;
								 newMember.type = variable -> type;
 								 newMember.size = variable -> size;
								 $$ -> insert($$ -> end(), newMember);
								 delete variable;}
		| variable_dec_single			        {$$ = new std::list<struct_member>();
								 variableNode* variable = (variableNode*)((Node*)$1);
								 struct_member newMember;
								 newMember.id = variable -> val;
								 newMember.type = variable -> type;
								 newMember.size = variable -> size;
								 $$ -> insert($$ -> end(), newMember);
								 delete variable;}
		;

program_block	:
		variable_dec EOS				{$$ = $1;}
		| def_expr					{$$ = NULL}
		| variable_dec EQUALS rexpr EOS			{$$ = new parserNode(EXPR_T, NULL_S, $1, new Node(ASSIGN_T, $2, linenum), $3, linenum);}
		| bracketed_statement_list			{$$ = $1}
		| typedef EOS					{$$ = NULL}
		| function_def					{$$ = $1}
		| function_dec EOS				{$$ = $1}
		| unknown					{$$ = NULL;}
		;

program		:
		program_block program				{$$ = new parserNode(NULL_T, NULL_S, $1, NULL, $2, linenum);}
		| program_block					{$$ = $1}
		;

enum_def	:
		ENUM id OPEN_CURLY_BRACKET enum_def_param_list CLOSE_CURLY_BRACKET
								{
							 	   $$ = getType($2, "enum");
								   if($$ == NULL)
									$$ = addType("enum",$2, NULL,build_struct_members($4));
								   else
									yyerror("Enumerated has been previously defined");
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
		ENUM ENUM_TYPE					{
							 	   $$ = getType($2, "enum");
								   if($$ == NULL)
									yyerror("Enumerated has not been defined");
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
									yyerror("Union has been previously defined");
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
		UNION UNION_TYPE				{
								   $$ = getType($2, "union");
								   if($$ == NULL)
									yyerror("Union has not been defined");
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
		arithmetic_op EQUALS				{$$ = $1}	//+= -= *= /=
		| bitwise_op EQUALS				{$$ = $1}	//^= <<= >>= etc.
		;

logic_op	:
		NOT_EQUALS					{$$ = new Node(LOGICOP_T, $1, linenum)}	//!=
		| NOT						{$$ = new Node(LOGICOP_T, $1, linenum)}	//!
		| GREATER_THAN					{$$ = new Node(LOGICOP_T, $1, linenum)}	//>
		| GREATER_THAN_EQUALS				{$$ = new Node(LOGICOP_T, $1, linenum)}	//>=
		| LESS_THAN_EQUALS				{$$ = new Node(LOGICOP_T, $1, linenum)}	//<=
		| LESS_THAN					{$$ = new Node(LOGICOP_T, $1, linenum)}	//<
		| LOGICAL_AND					{$$ = new Node(LOGICOP_T, $1, linenum)}	//&&
		| LOGICAL_EQUALS				{$$ = new Node(LOGICOP_T, $1, linenum)}	//==
		| LOGICAL_OR					{$$ = new Node(LOGICOP_T, $1, linenum)}	//||
		;

bitwise_op	:
		ADDRESS_OR_BITWISE_AND				{$$ = new Node(BITOP_T, $1, linenum)}	//&
		| BITWISE_INVERSE				{$$ = new Node(BITOP_T, $1, linenum)}	//~
		| BITWISE_LEFT					{$$ = new Node(BITOP_T, $1, linenum)}	//<<
		| BITWISE_OR					{$$ = new Node(BITOP_T, $1, linenum)}	//|
		| BITWISE_RIGHT					{$$ = new Node(BITOP_T, $1, linenum)}	//>>
		| BITWISE_XOR					{$$ = new Node(BITOP_T, $1, linenum)}	//^
		;

qualifier_list	:
		qualifier qualifier				{yyerror("Not implemented yet"); exit(1);}	//const volatile
		;

type_cast	:						//(const unsigned int**const*)
		OPEN_BRACKET type CLOSE_BRACKET			{$$ = new castNode(TYPE_T, $2, linenum);}
		;

unknown		:
		UNKNOWN						{yyerror("Unknown value found"); exit(1);}
		| CONDITIONAL_OPERATOR				{yyerror("Not implemented yet"); exit(1);}
		| SIZEOF					{yyerror("Not implemented yet"); exit(1);}
		| ELLIPSES					{yyerror("Not implemented yet"); exit(1);}
		| CONTINUE					{yyerror("Not implemented yet"); exit(1);}
		| DEFAULT					{yyerror("Not implemented yet"); exit(1);}
		| BREAK						{yyerror("Not implemented yet"); exit(1);}
		| GOTO						{yyerror("Not implemented yet"); exit(1);}
		| COLON						{yyerror("Not implemented yet"); exit(1);}
		;

arithmetic_op	:
		ARITHMETIC					{$$ = new Node(ARROP_T, $1, linenum)}
		| INVERSE					{$$ = new Node(ARROP_T, $1, linenum)}
		| MULT_OR_POINTER				{$$ = new Node(ARROP_T, $1, linenum)}
		;

if_cond		:
		IF OPEN_BRACKET expr CLOSE_BRACKET		{$$ = new parserNode(IF_COND_T, NULL_S, $3, NULL, NULL, linenum);}
		;

while_cond	:
		WHILE OPEN_BRACKET expr CLOSE_BRACKET		{$$ = new condNode(WHILE_COND_T, NULL_S, $3, NULL, NULL, linenum);}
		;

while_statement	:
		while_cond bracketed_statement_list		{$$ = new parserNode(LOOP_T, NULL_S, $1, NULL, $2, linenum);}			//while(true){...} 
		| while_cond statement				{$$ = new parserNode(LOOP_T, NULL_S, $1, NULL, $2, linenum);}			//while(true)...
		| DO bracketed_statement_list while_cond EOS	{$$ = new parserNode(NULL_T, NULL_S, $2, NULL, new parserNode(LOOP_T, NULL_S, $3, NULL, $2, linenum), linenum);}			//do{...}while(true);
		| DO statement while_cond EOS			{$$ = new parserNode(NULL_T, NULL_S, $2, NULL, new parserNode(LOOP_T, NULL_S, $3, NULL, $2, linenum), linenum);}			//do...while(true)
		;

bracketed_statement_list :
		OPEN_CURLY_BRACKET statement_list CLOSE_CURLY_BRACKET
								{$$ = $2;}
		|OPEN_CURLY_BRACKET CLOSE_CURLY_BRACKET
								{$$ = NULL;}
		;

statement_list	:
		statement_list statement			{$$ = $1;
								if(((Node*)$$)->node_type == "parserNode" && ((Node*)$$) -> id == NULL_T)
								{
									parserNode* temp = (parserNode*)((typeNode*)((Node*)($$)));
									parserNode* temp2;
								  	while(((Node*)temp)->node_type == "parserNode" && ((Node*)temp) -> id == NULL_T)
									{
										temp2 = temp;
										temp = (parserNode*)((typeNode*)((Node*)(temp -> RHS)));
									}
		
								  	temp =  new parserNode(NULL_T, NULL_S, temp, NULL, $2, linenum);
									temp2 -> RHS = temp;
								}
								else{
 									$$ =  new parserNode(NULL_T, NULL_S, $1, NULL, $2, linenum);
								}
								}
		| statement					{$$ = $1}
		;

if_main		:
		if_cond bracketed_statement_list		{$$ = new condNode(COND_T, NULL_S, $1, $2, NULL, linenum);}
		| if_cond statement				{$$ = new condNode(COND_T, NULL_S, $1, $2, NULL, linenum);}
		;

if_statement		:
		if_main else					{$$ = $1; ((condNode*)((Node*)$$)) -> cond_false = $2;}
		| if_main					{$$ = $1;}
		;

else		:
		ELSE bracketed_statement_list			{$$ = $2;}
		| ELSE statement				{$$ = $2;}
		;

switch_cond	:
		SWITCH OPEN_BRACKET expr CLOSE_BRACKET		{yyerror("Not implemented yet"); exit(1);}
		;

switch_statement	:
		switch_cond OPEN_CURLY_BRACKET case_list CLOSE_CURLY_BRACKET
								{yyerror("Not implemented yet"); exit(1);}
		;

case_stat	:
		CASE unary_expr COLON statement_list		{yyerror("Not implemented yet"); exit(1);}
		| CASE unary_expr COLON bracketed_statement_list{yyerror("Not implemented yet"); exit(1);}
		;

case_list 	:
		case_stat case_list				{yyerror("Not implemented yet"); exit(1);}
		| case_stat					{yyerror("Not implemented yet"); exit(1);}
		;

statement	:
		expr EOS					{$$ = $1;}
		| cond_statement				{$$ = $1;}
		| return EOS					{$$ = $1;}
		;

cond_statement	:
		switch_statement				{$$ = $1;}
		| if_statement					{$$ = $1;}
		| while_statement				{$$ = $1;}
		| for_statement					{$$ = $1;}
		;
		
expr		:
		rexpr						{$$ = $1;}
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

const_expr	:
		number						{$$ = $1;}
		| id_or_array					{$$ = new variableNode(VAR_T, $1, NULL, "unknown", linenum);}
		| address_id					{$$ = new variableNode(VAR_T, $1, NULL, "unknown", linenum);}
		| CHAR						{std::string tmp = $1; tmp.erase(0,1);tmp.erase(tmp.size()-1);	$$ = new variableNode(CONST_T, tmp, getType("char", "type"), "const", linenum);}
		| STRING					{std::string tmp = $1; tmp.erase(0,1);tmp.erase(tmp.size()-1);  $$ = new variableNode(CONST_T, tmp, getPointer("char*"), "const", linenum);}
		;

unary_expr	:
		const_expr					{$$ = $1;}
		| INCREMENT unary_expr				{$$ = new parserNode(EXPR_T, NULL_S, $2, new Node(ASSIGN_T,"=", linenum), new parserNode(EXPR_T,NULL_S, $2, new Node(ARROP_T, "+", linenum), new variableNode(CONST_T, "1", getType("int", "type"), "const", linenum), linenum), linenum);}
		| DECREMENT unary_expr				{$$ = new parserNode(EXPR_T, NULL_S, $2, new Node(ASSIGN_T,"=", linenum), new parserNode(EXPR_T,NULL_S, $2, new Node(ARROP_T, "-", linenum), new variableNode(CONST_T, "1", getType("int", "type"), "const", linenum), linenum), linenum);}
		| INVERSE unary_expr				{$$ = new parserNode(EXPR_T, NULL_S, new variableNode(CONST_T, "0", getType("int", "type"), "const", linenum), new Node(ARROP_T, "-", linenum), $2, linenum);}
		| unary_expr INCREMENT				{$$ = new parserNode(EXPR_T, NULL_S, $1, new Node(ASSIGN_T,"=", linenum), new parserNode(EXPR_T,NULL_S, $1, new Node(ARROP_T, "+", linenum), new variableNode(CONST_T, "1", getType("int", "type"), "const", linenum), linenum), linenum);}
		| unary_expr DECREMENT				{$$ = new parserNode(EXPR_T, NULL_S, $1, new Node(ASSIGN_T,"=", linenum), new parserNode(EXPR_T,NULL_S, $1, new Node(ARROP_T, "-", linenum), new variableNode(CONST_T, "1", getType("int", "type"), "const", linenum), linenum), linenum);}
		| type_cast unary_expr				{$$ = new parserNode(CAST_T, NULL_S, NULL, $1, $2, linenum);}
		| OPEN_BRACKET expr CLOSE_BRACKET		{$$ = $2}
		| function_call					{$$ = $1;}
		;				

binary_expr	:
		lexpr arithmetic_op rexpr			{$$ = new parserNode(EXPR_T, NULL_S, $1, $2, $3, linenum);}
		| rexpr arithmetic_op rexpr			{$$ = new parserNode(EXPR_T, NULL_S, $1, $2, $3, linenum);}
		| lexpr logic_op rexpr				{$$ = new parserNode(EXPR_T, NULL_S, $1, $2, $3, linenum);}
		| lexpr bitwise_op rexpr			{$$ = new parserNode(EXPR_T, NULL_S, $1, $2, $3, linenum);}
		;

assign_expr	:
		lexpr EQUALS rexpr				{$$ = new parserNode(EXPR_T, NULL_S, $1, new Node(ASSIGN_T,$2, linenum), $3, linenum);}
		| lexpr compound_assign rexpr			{$$ = new parserNode(EXPR_T, NULL_S, $1, new Node(ASSIGN_T,"=", linenum), new parserNode(EXPR_T,NULL_S, $1, $2, $3, linenum), linenum);}
		;

for_cond	:
		FOR OPEN_BRACKET expr EOS expr EOS expr CLOSE_BRACKET
								{$$ = new forNode(FOR_COND_T, $1, $3, $5, $7, linenum);}
		;

for_statement	:
		for_cond bracketed_statement_list		{$$ = new parserNode(LOOP_T, NULL_S, $1, NULL, $2, linenum);}
		| for_cond statement				{$$ = new parserNode(LOOP_T, NULL_S, $1, NULL, $2, linenum);}
		;

struct_def_param_list:
		variable_dec EOS struct_def_param_list
								{
								$$ = $3;
								 variableNode* variable = (variableNode*)((Node*)$1);
								 struct_member newMember;
								 newMember.id = variable -> val;
								 newMember.type = variable -> type;
 								 newMember.size = variable -> size;
								 $$ -> insert($$ -> end(), newMember);
								 delete variable;
								}		//int x; int y; char z ...
		| variable_dec EOS				{
								$$ = new std::list<struct_member>();
								 variableNode* variable = (variableNode*)((Node*)$1);
								 struct_member newMember;
								 newMember.id = variable -> val;
								 newMember.type = variable -> type;
								 newMember.size = variable -> size;
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

return		:
		RETURN rexpr					{$$ = new parserNode(RETURN_T, NULL_S, NULL, new Node(RETURNOP_T, $1, linenum), $2, linenum)}
		| RETURN					{$$ = new parserNode(RETURN_T, NULL_S, NULL, new Node(RETURNOP_T, $1, linenum), NULL, linenum)}
		;

array		:
		OPEN_SQUARE_BRACKET number CLOSE_SQUARE_BRACKET	{std::stringstream ss;
								ss << '[';
								ss << ((Node*)$2) -> val;
								ss  << ']';
								delete $2;
								$$ = strdup(ss.str().c_str());
								}
		| OPEN_SQUARE_BRACKET id CLOSE_SQUARE_BRACKET	{std::stringstream ss;
								ss << '[';
								ss << $2;
								ss  << ']';
								$$ = strdup(ss.str().c_str());}
		;

parameter_send_list:
		rexpr COMMA parameter_send_list			{$$ = $3; $$ -> push_back($1);}
		| rexpr						{$$ = new std::vector<abstractNode*>; $$ -> push_back($1);}
		;

struct_member 	:	
		id FULL_STOP id					{std::stringstream ss;
								ss << '.';
								ss << $3;
								ss << '.';
								ss << $1;
								$$ = strdup(ss.str().c_str());}
		| id POINTER_MEMBER id				{std::stringstream ss;
								ss << '-';
								ss << $3;
								ss << '-';
								ss << $1;
								$$ = strdup(ss.str().c_str());}
		;
		


%%

void yyerror (char const *s)
{	
	printError(s, false, linenum);
	error = false;
}

bool parse(std::string fileName)
{
	infileName = fileName;
	if(fileName != "NULL")
	{
		FILE* infile = fopen(fileName.c_str(), "r");
		if(infile == NULL)
		{
			printFileMissing();
			return false;
		}
		else
			yyin = infile;
	}
	yyparse();
	fclose(yyin);
	return error;
}
