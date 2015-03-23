
/*Must have all comments and preprocessor instructions removed beforehand*/

%option noyywrap

%{
	/* Add all include headers, globals and preprocessor directives here*/
	#include "includes/FlexDef.h"
	#include "CParser.hpp"

	int isType(char* string);
%}

AMPERSAND						\&
AUTO							auto
BREAK							break
CASE							case
CHAR_LITERAL						\'([^\'\\]|\\.)?\'
CLOSE_BRACKET						\)
CLOSE_CURLY_BRACKET					\}
CLOSE_SQUARE_BRACKET					\]
COLON							:
COMMA							,
CONST_QUALIFIER 					const
CONTINUE						continue
DEFAULT							default
DIVIDE							\/
DO							do
ELLIPSES						\.\.\.
ELSE							else
ENUM							enum
EQUALS							=
EXTERN							extern
FOR							for
FULL_STOP						\.
GOTO							goto
GREATER_THAN						>
LESS_THAN						<
MINUS							-
MODULUS							%
MULTIPLY						\*
ID							[A-Za-z_][A-Za-z0-9_]*
IF							if
NOT							!
NUMBER							[0-9a-zA-Z]+
OPEN_BRACKET						\(
OPEN_CURLY_BRACKET					\{
OPEN_SQUARE_BRACKET					\[
OR							\|
PLUS							\+
QUESTION_MARK						\?
REGISTER						register
RETURN							return
SEMI_COLON						;
SIZEOF							sizeof
STATIC							static
STRING_LITERAL						\"([^\"\\]|\\.)*\"
STRUCT							struct
SWITCH							switch
TILDE							~
TYPE							int|char|double|float|void
TYPEDEF							typedef
TYPE_SPECIFIER_LONG					long
TYPE_SPECIFIER_SHORT					short
TYPE_SPECIFIER_SIGNED					signed
TYPE_SPECIFIER_UNSIGNED					unsigned
UNION							union
VOLATILE_QUALIFIER					volatile
WHILE							while
XOR							\^
NUMBER_ID						0[a-zA-Z]

%%

	/*Compare for individual tokens*/
{AMPERSAND}							yylval.str = strdup(yytext);return ADDRESS_OR_BITWISE_AND;
{AMPERSAND}{AMPERSAND}						yylval.str = strdup(yytext);return LOGICAL_AND;
{AUTO}								yylval.str = strdup(yytext);return AUTO;
{BREAK}								yylval.str = strdup(yytext);return BREAK;
{CASE}								yylval.str = strdup(yytext);return CASE;
{CHAR_LITERAL}							yylval.str = strdup(yytext);return CHAR;
{CLOSE_BRACKET}							yylval.str = strdup(yytext);return CLOSE_BRACKET;
{CLOSE_CURLY_BRACKET}						yylval.str = strdup(yytext);return CLOSE_CURLY_BRACKET;
{CLOSE_SQUARE_BRACKET}						yylval.str = strdup(yytext);return CLOSE_SQUARE_BRACKET;
{COLON}								yylval.str = strdup(yytext);return COLON;
{COMMA}								yylval.str = strdup(yytext);return COMMA;
{CONST_QUALIFIER} 						yylval.str = strdup(yytext);return CONST;
{CONTINUE}							yylval.str = strdup(yytext);return CONTINUE;
{DEFAULT}							yylval.str = strdup(yytext);return DEFAULT;
{DIVIDE}|{MODULUS}|{PLUS}					yylval.str = strdup(yytext);return ARITHMETIC;
{DO}								yylval.str = strdup(yytext);return DO;
{ELLIPSES}							yylval.str = strdup(yytext);return ELLIPSES;
{ELSE}								yylval.str = strdup(yytext);return ELSE;
{ENUM}								yylval.str = strdup(yytext);return ENUM;
{EQUALS}							yylval.str = strdup(yytext);return EQUALS;
{EQUALS}{EQUALS}						yylval.str = strdup(yytext);return LOGICAL_EQUALS;
{EXTERN}							yylval.str = strdup(yytext);return EXTERN;
{FOR}								yylval.str = strdup(yytext);return FOR;
{FULL_STOP}							yylval.str = strdup(yytext);return FULL_STOP;
{GOTO}								yylval.str = strdup(yytext);return GOTO;
{GREATER_THAN}							yylval.str = strdup(yytext);return GREATER_THAN;
{GREATER_THAN}{EQUALS}						yylval.str = strdup(yytext);return GREATER_THAN_EQUALS;
{GREATER_THAN}{GREATER_THAN}					yylval.str = strdup(yytext);return BITWISE_RIGHT;
{IF}								yylval.str = strdup(yytext);return IF;
{LESS_THAN}							yylval.str = strdup(yytext);return LESS_THAN;
{LESS_THAN}{EQUALS}						yylval.str = strdup(yytext);return LESS_THAN_EQUALS;
{LESS_THAN}{LESS_THAN}						yylval.str = strdup(yytext);return BITWISE_LEFT;
{MINUS}{GREATER_THAN}						yylval.str = strdup(yytext);return POINTER_MEMBER;
{MINUS}{MINUS}							yylval.str = strdup(yytext);return DECREMENT;
{MINUS}								yylval.str = strdup(yytext);return INVERSE;
{MULTIPLY}							yylval.str = strdup(yytext);return MULT_OR_POINTER;
{NOT}								yylval.str = strdup(yytext);return NOT;
{NOT}{EQUALS}							yylval.str = strdup(yytext);return NOT_EQUALS;
{OPEN_BRACKET}							yylval.str = strdup(yytext);return OPEN_BRACKET;
{OPEN_CURLY_BRACKET}						yylval.str = strdup(yytext);return OPEN_CURLY_BRACKET;
{OPEN_SQUARE_BRACKET}						yylval.str = strdup(yytext);return OPEN_SQUARE_BRACKET;
{OR}								yylval.str = strdup(yytext);return BITWISE_OR;
{OR}{OR}							yylval.str = strdup(yytext);return LOGICAL_OR;
{PLUS}{PLUS}							yylval.str = strdup(yytext);return INCREMENT;
{QUESTION_MARK}							yylval.str = strdup(yytext);return CONDITIONAL_OPERATOR;
{REGISTER}							yylval.str = strdup(yytext);return REGISTER;
{RETURN}							yylval.str = strdup(yytext);return RETURN;
{SEMI_COLON}							yylval.str = strdup(yytext);return EOS;
{SIZEOF}							yylval.str = strdup(yytext);return SIZEOF;
{STATIC}							yylval.str = strdup(yytext);return STATIC;
{STRING_LITERAL}						yylval.str = strdup(yytext);return STRING;
{STRUCT}							yylval.str = strdup(yytext);return STRUCT;
{SWITCH}							yylval.str = strdup(yytext);return SWITCH;
{TILDE}								yylval.str = strdup(yytext);return BITWISE_INVERSE;
{TYPEDEF}							yylval.str = strdup(yytext);return TYPEDEF;
{TYPE_SPECIFIER_LONG}						yylval.str = strdup(yytext);return TYPE_LONG;
{TYPE_SPECIFIER_SHORT}						yylval.str = strdup(yytext);return TYPE_SHORT;
{TYPE_SPECIFIER_SIGNED}						yylval.str = strdup(yytext);return TYPE_SIGNED;
{TYPE_SPECIFIER_UNSIGNED}					yylval.str = strdup(yytext);return TYPE_UNSIGNED;
{TYPE}								yylval.str = strdup(yytext);return TYPE;
{UNION}								yylval.str = strdup(yytext);return UNION;
{VOLATILE_QUALIFIER}						yylval.str = strdup(yytext);return VOLATILE;
{WHILE}								yylval.str = strdup(yytext);return WHILE;
{XOR}								yylval.str = strdup(yytext);return BITWISE_XOR;

	/*The following values may match any of the above so it is best to seperate them*/
{ID}								yylval.str = strdup(yytext);return isType(yytext);
{NUMBER_ID}?{NUMBER}						yylval.str = strdup(yytext);return INT;
[0-9]+{FULL_STOP}[0-9]+						yylval.str = strdup(yytext);return FLOAT;
[ \t]+								/*Consumes all whitespace*/
^#.*$								/*consumes preprocessor instructions */
\/\/.*$								/*Consumes in line comments*/
\n								linenum++;
.                    						yylval.str = strdup(yytext);return UNKNOWN;

%%

int isType(char* string)
{
	if(getType(string, "type"))
		return TYPE;
	else if(getType(string, "struct"))
		return STRUCT_TYPE;
 	else if(getType(string, "enum"))
		return ENUM_TYPE;
	else if(getType(string, "union"))
		return UNION_TYPE;
	else
		return ID;
		
}
