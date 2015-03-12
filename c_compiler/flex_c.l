
/*Must have all comments and preprocessor instructions removed beforehand*/

%option noyywrap

%{
	/* Add all include headers, globals and preprocessor directives here*/
	
	#define DEBUG
	
	#include "./includes/FlexDef.h"
	#include <vector>
	#include <iostream>
	
	using namespace std;
	
	#ifdef DEBUG
	vector<flex_def> tokens;
	#endif
	
	int linenum = 0;
	int columnnum = 0;

%}

AMPERSAND						\&
AUTO							auto
BREAK							break
CASE							case
CHAR_LITERAL					\'([^\'\\]|\\.)\'
CLOSE_BRACKET					\)
CLOSE_CURLY_BRACKET				\}
CLOSE_SQUARE_BRACKET			\]
COLON							:
COMMA							,
CONST_QUALIFIER 				const
CONTINUE						continue
DEFAULT							default
DIVIDE							\/
DO								do
ELLIPSES						\.\.\.
ELSE							else
ENUM							enum
EQUALS							=
EXTERN							extern
FOR								for
FULL_STOP						\.
GOTO							goto
GREATER_THAN					>
LESS_THAN						<
MINUS							-
MODULUS							%
MULTIPLY						\*
ID								[A-Za-z_][A-Za-z0-9_]*
NOT								!
NUMBER							[0-9a-zA-Z]+
OPEN_BRACKET					\(
OPEN_CURLY_BRACKET				\{
OPEN_SQUARE_BRACKET				\[
OR								\|
PLUS							\+
QUESTION_MARK					\?
REGISTER						register
RETURN							return
SEMI_COLON						;
SIZEOF							sizeof
STATIC							static
STRING_LITERAL					\"([^\"\\]|\\.)*\"
STRUCT							struct
SWITCH							switch
TILDE							~
TYPE							int|char|double|float|void
TYPEDEF							typedef
TYPE_SPECIFIER_LENGTH			short|long
TYPE_SPECIFIER_SIGNED			signed|unsigned
UNION							union
VOLATILE_QUALIFIER				volatile
WHILE							while
XOR								\^
NUMBER_ID						0[a-zA-Z]

%%

	/*Compare for individual tokens*/
{AMPERSAND}									{flex_def def(ADDRESS_OR_BITWISE_AND_T,YYText(),linenum,columnnum);tokens.push_back(def);columnnum++;}
{AMPERSAND}{AMPERSAND}						{flex_def def(LOGICAL_AND_T,YYText(),linenum,columnnum);tokens.push_back(def);columnnum++;}
{AUTO}										{flex_def def(AUTO_T,YYText(),linenum,columnnum);tokens.push_back(def);columnnum++;}
{BREAK}										{flex_def def(BREAK_T,YYText(),linenum,columnnum);tokens.push_back(def);columnnum++;}
{CASE}										{flex_def def(CASE_T,YYText(),linenum,columnnum);tokens.push_back(def);columnnum++;}
{CHAR_LITERAL}								{flex_def def(CHAR_T,YYText(),linenum,columnnum);tokens.push_back(def);columnnum++;}
{CLOSE_BRACKET}								{flex_def def(CLOSE_BRACKET_T,YYText(),linenum,columnnum);tokens.push_back(def);columnnum++;}
{CLOSE_CURLY_BRACKET}						{flex_def def(CLOSE_CURLY_BRACKET_T,YYText(),linenum,columnnum);tokens.push_back(def);columnnum++;}
{CLOSE_SQUARE_BRACKET}						{flex_def def(CLOSE_SQUARE_BRACKET_T,YYText(),linenum,columnnum);tokens.push_back(def);columnnum++;}
{COLON}										{flex_def def(COLON_T,YYText(),linenum,columnnum);tokens.push_back(def);columnnum++;}
{COMMA}										{flex_def def(COMMA_T,YYText(),linenum,columnnum);tokens.push_back(def);columnnum++;}
{CONST_QUALIFIER} 							{flex_def def(CONST_T,YYText(),linenum,columnnum);tokens.push_back(def);columnnum++;}
{CONTINUE}									{flex_def def(CONTINUE_T,YYText(),linenum,columnnum);tokens.push_back(def);columnnum++;}
{DEFAULT}									{flex_def def(DEFAULT_T,YYText(),linenum,columnnum);tokens.push_back(def);columnnum++;}
{DIVIDE}|{MODULUS}|{PLUS}|{MINUS}			{flex_def def(ARITHMETIC_T,YYText(),linenum,columnnum);tokens.push_back(def);columnnum++;}
{DO}										{flex_def def(DO_T,YYText(),linenum,columnnum);tokens.push_back(def);columnnum++;}
{ELLIPSES}									{flex_def def(ELLIPSES_T,YYText(),linenum,columnnum);tokens.push_back(def);columnnum++;}
{ELSE}										{flex_def def(ELSE_T,YYText(),linenum,columnnum);tokens.push_back(def);columnnum++;}
{ENUM}										{flex_def def(ENUM_T,YYText(),linenum,columnnum);tokens.push_back(def);columnnum++;}
{EQUALS}									{flex_def def(EQUALS_T,YYText(),linenum,columnnum);tokens.push_back(def);columnnum++;}
{EQUALS}{EQUALS}							{flex_def def(LOGICAL_EQUALS_T,YYText(),linenum,columnnum);tokens.push_back(def);columnnum++;}
{EXTERN}									{flex_def def(EXTERN_T,YYText(),linenum,columnnum);tokens.push_back(def);columnnum++;}
{FOR}										{flex_def def(FOR_T,YYText(),linenum,columnnum);tokens.push_back(def);columnnum++;}
{FULL_STOP}									{flex_def def(FULL_STOP_T,YYText(),linenum,columnnum);tokens.push_back(def);columnnum++;}
{GOTO}										{flex_def def(GOTO_T,YYText(),linenum,columnnum);tokens.push_back(def);columnnum++;}
{GREATER_THAN}								{flex_def def(GREATER_THAN_T,YYText(),linenum,columnnum);tokens.push_back(def);columnnum++;}
{GREATER_THAN}{EQUALS}						{flex_def def(GREATER_THAN_EQUALS_T,YYText(),linenum,columnnum);tokens.push_back(def);columnnum++;}
{GREATER_THAN}{GREATER_THAN}				{flex_def def(BITWISE_RIGHT_T,YYText(),linenum,columnnum);tokens.push_back(def);columnnum++;}
{IF}										{flex_def def(IF_T,YYText(),linenum,columnnum);tokens.push_back(def);columnnum++;}
{LESS_THAN}									{flex_def def(LESS_THAN_T,YYText(),linenum,columnnum);tokens.push_back(def);columnnum++;}
{LESS_THAN}{EQUALS}							{flex_def def(LESS_THAN_EQUALS_T,YYText(),linenum,columnnum);tokens.push_back(def);columnnum++;}
{LESS_THAN}{LESS_THAN}						{flex_def def(BITWISE_LEFT_T,YYText(),linenum,columnnum);tokens.push_back(def);columnnum++;}
{MINUS}{GREATER_THAN}						{flex_def def(POINTER_MEMBER_T,YYText(),linenum,columnnum);tokens.push_back(def);columnnum++;}
{MINUS}{ID}									{flex_def def(INVERSE_T,YYText(),linenum,columnnum);tokens.push_back(def);columnnum++;}
{MINUS}{MINUS}								{flex_def def(DECREMENT_T,YYText(),linenum,columnnum);tokens.push_back(def);columnnum++;}
{MULTIPLY}									{flex_def def(MULT_OR_POINTER_T,YYText(),linenum,columnnum);tokens.push_back(def);columnnum++;}
{NOT}										{flex_def def(NOT_T,YYText(),linenum,columnnum);tokens.push_back(def);columnnum++;}
{NOT}{EQUALS}								{flex_def def(NOT_EQUALS_T,YYText(),linenum,columnnum);tokens.push_back(def);columnnum++;}
{OPEN_BRACKET}								{flex_def def(OPEN_BRACKET_T,YYText(),linenum,columnnum);tokens.push_back(def);columnnum++;}
{OPEN_CURLY_BRACKET}						{flex_def def(OPEN_CURLY_BRACKET_T,YYText(),linenum,columnnum);tokens.push_back(def);columnnum++;}
{OPEN_SQUARE_BRACKET}						{flex_def def(OPEN_SQUARE_BRACKET_T,YYText(),linenum,columnnum);tokens.push_back(def);columnnum++;}
{OR}										{flex_def def(BITWISE_OR_T,YYText(),linenum,columnnum);tokens.push_back(def);columnnum++;}
{OR}{OR}									{flex_def def(LOGICAL_OR_T,YYText(),linenum,columnnum);tokens.push_back(def);columnnum++;}
{PLUS}{ID}									{flex_def def(TYPE_PROMOTION_T,YYText(),linenum,columnnum);tokens.push_back(def);columnnum++;}
{PLUS}{PLUS}								{flex_def def(INCREMENT_T,YYText(),linenum,columnnum);tokens.push_back(def);columnnum++;}
{QUESTION_MARK}								{flex_def def(CONDITIONAL_OPERATOR,YYText(),linenum,columnnum);tokens.push_back(def);columnnum++;}
{REGISTER}									{flex_def def(REGISTER_T,YYText(),linenum,columnnum);tokens.push_back(def);columnnum++;}
{RETURN}									{flex_def def(RETURN_T,YYText(),linenum,columnnum);tokens.push_back(def);columnnum++;}
{SEMI_COLON}								{flex_def def(EOS_T,YYText(),linenum,columnnum);tokens.push_back(def);columnnum++;}
{SIZEOF}									{flex_def def(SIZEOF_T,YYText(),linenum,columnnum);tokens.push_back(def);columnnum++;}
{STATIC}									{flex_def def(STATIC_T,YYText(),linenum,columnnum);tokens.push_back(def);columnnum++;}
{STRING_LITERAL}|{CHAR_LITERAL}				{flex_def def(STRING_T,YYText(),linenum,columnnum);tokens.push_back(def);columnnum++;}
{STRUCT}									{flex_def def(STRUCT_T,YYText(),linenum,columnnum);tokens.push_back(def);columnnum++;}
{SWITCH}									{flex_def def(SWITCH_T,YYText(),linenum,columnnum);tokens.push_back(def);columnnum++;}
{TILDE}										{flex_def def(BITWISE_INVERSE_T,YYText(),linenum,columnnum);tokens.push_back(def);columnnum++;}
{TYPEDEF}									{flex_def def(TYPEDEF_T,YYText(),linenum,columnnum);tokens.push_back(def);columnnum++;}
{TYPE_SPECIFIER_LENGTH}						{flex_def def(TYPE_LENGTH_T,YYText(),linenum,columnnum);tokens.push_back(def);columnnum++;}
{TYPE_SPECIFIER_SIGNED}						{flex_def def(TYPE_SIGNED_T,YYText(),linenum,columnnum);tokens.push_back(def);columnnum++;}
{TYPE}										{flex_def def(TYPE_T,YYText(),linenum,columnnum);tokens.push_back(def);columnnum++;}
{UNION}										{flex_def def(UNION_T,YYText(),linenum,columnnum);tokens.push_back(def);columnnum++;}
{VOLATILE_QUALIFIER}						{flex_def def(VOLATILE_T,YYText(),linenum,columnnum);tokens.push_back(def);columnnum++;}
{WHILE}										{flex_def def(WHILE_T,YYText(),linenum,columnnum);tokens.push_back(def);columnnum++;}
{XOR}										{flex_def def(BITWISE_XOR_T,YYText(),linenum,columnnum);tokens.push_back(def);columnnum++;}

	/*The following values may match any of the above so it is best to seperate them*/
{ID}										{flex_def def(ID_T,YYText(),linenum,columnnum);tokens.push_back(def);columnnum++;}
{NUMBER_ID}?{NUMBER}L?						{flex_def def(INT_T,YYText(),linenum,columnnum);tokens.push_back(def);columnnum++;}
{NUMBER}{FULL_STOP}{NUMBER}L?				{flex_def def(FLOAT_T,YYText(),linenum,columnnum);tokens.push_back(def);columnnum++;}
[ \t]+										/*Consumes all whitespace*/
\n											{linenum++; columnnum = 0;};
.                    						{flex_def def(UNKNOWN,YYText(),linenum,columnnum);tokens.push_back(def);columnnum++;}

%%

#ifdef DEBUG
int main()
#else
bool lex()
#endif
{


    yyFlexLexer lexer;
	
	do{
	}while(lexer.yylex() != 0);
	
	#ifdef DEBUG
    	for(int i=0; i < tokens.size(); i++)
    		cout << hex << "0x" << tokens[i].name << " " << tokens[i].Data.toString() << endl;
    return 0;
    #else
    return true;
    #endif
}
