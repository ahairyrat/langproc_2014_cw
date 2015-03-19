
/*Must have all comments and preprocessor instructions removed beforehand*/

%option noyywrap

%{
	/* Add all include headers, globals and preprocessor directives here*/
	#include "includes/FlexDef.h"
	#include "CParser.hpp"

	int isType(char* string);
	
	std::string prevCharNamespace = "type"; 
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
{AMPERSAND}							prevCharNamespace = "type";yylval.str = strdup(yytext);return ADDRESS_OR_BITWISE_AND;
{AMPERSAND}{AMPERSAND}						prevCharNamespace = "type";yylval.str = strdup(yytext);return LOGICAL_AND;
{AUTO}								prevCharNamespace = "type";yylval.str = strdup(yytext);return AUTO;
{BREAK}								prevCharNamespace = "type";yylval.str = strdup(yytext);return BREAK;
{CASE}								prevCharNamespace = "type";yylval.str = strdup(yytext);return CASE;
{CHAR_LITERAL}							prevCharNamespace = "type";yylval.str = strdup(yytext);return CHAR;
{CLOSE_BRACKET}							prevCharNamespace = "type";yylval.str = strdup(yytext);return CLOSE_BRACKET;
{CLOSE_CURLY_BRACKET}						prevCharNamespace = "type";yylval.str = strdup(yytext);return CLOSE_CURLY_BRACKET;
{CLOSE_SQUARE_BRACKET}						prevCharNamespace = "type";yylval.str = strdup(yytext);return CLOSE_SQUARE_BRACKET;
{COLON}								prevCharNamespace = "type";yylval.str = strdup(yytext);return COLON;
{COMMA}								prevCharNamespace = "type";yylval.str = strdup(yytext);return COMMA;
{CONST_QUALIFIER} 						prevCharNamespace = "type";yylval.str = strdup(yytext);return CONST;
{CONTINUE}							prevCharNamespace = "type";yylval.str = strdup(yytext);return CONTINUE;
{DEFAULT}							prevCharNamespace = "type";yylval.str = strdup(yytext);return DEFAULT;
{DIVIDE}|{MODULUS}|{PLUS}					prevCharNamespace = "type";yylval.str = strdup(yytext);return ARITHMETIC;
{DO}								prevCharNamespace = "type";yylval.str = strdup(yytext);return DO;
{ELLIPSES}							prevCharNamespace = "type";yylval.str = strdup(yytext);return ELLIPSES;
{ELSE}								prevCharNamespace = "type";yylval.str = strdup(yytext);return ELSE;
{ENUM}								prevCharNamespace = "enum";yylval.str = strdup(yytext);return ENUM;
{EQUALS}							prevCharNamespace = "type";yylval.str = strdup(yytext);return EQUALS;
{EQUALS}{EQUALS}						prevCharNamespace = "type";yylval.str = strdup(yytext);return LOGICAL_EQUALS;
{EXTERN}							prevCharNamespace = "type";yylval.str = strdup(yytext);return EXTERN;
{FOR}								prevCharNamespace = "type";yylval.str = strdup(yytext);return FOR;
{FULL_STOP}							prevCharNamespace = "type";yylval.str = strdup(yytext);return FULL_STOP;
{GOTO}								prevCharNamespace = "type";yylval.str = strdup(yytext);return GOTO;
{GREATER_THAN}							prevCharNamespace = "type";yylval.str = strdup(yytext);return GREATER_THAN;
{GREATER_THAN}{EQUALS}						prevCharNamespace = "type";yylval.str = strdup(yytext);return GREATER_THAN_EQUALS;
{GREATER_THAN}{GREATER_THAN}					prevCharNamespace = "type";yylval.str = strdup(yytext);return BITWISE_RIGHT;
{IF}								prevCharNamespace = "type";yylval.str = strdup(yytext);return IF;
{LESS_THAN}							prevCharNamespace = "type";yylval.str = strdup(yytext);return LESS_THAN;
{LESS_THAN}{EQUALS}						prevCharNamespace = "type";yylval.str = strdup(yytext);return LESS_THAN_EQUALS;
{LESS_THAN}{LESS_THAN}						prevCharNamespace = "type";yylval.str = strdup(yytext);return BITWISE_LEFT;
{MINUS}{GREATER_THAN}						prevCharNamespace = "type";yylval.str = strdup(yytext);return POINTER_MEMBER;
{MINUS}{MINUS}							prevCharNamespace = "type";yylval.str = strdup(yytext);return DECREMENT;
{MINUS}								prevCharNamespace = "type";yylval.str = strdup(yytext);return INVERSE;
{MULTIPLY}							prevCharNamespace = "type";yylval.str = strdup(yytext);return MULT_OR_POINTER;
{NOT}								prevCharNamespace = "type";yylval.str = strdup(yytext);return NOT;
{NOT}{EQUALS}							prevCharNamespace = "type";yylval.str = strdup(yytext);return NOT_EQUALS;
{OPEN_BRACKET}							prevCharNamespace = "type";yylval.str = strdup(yytext);return OPEN_BRACKET;
{OPEN_CURLY_BRACKET}						prevCharNamespace = "type";yylval.str = strdup(yytext);return OPEN_CURLY_BRACKET;
{OPEN_SQUARE_BRACKET}						prevCharNamespace = "type";yylval.str = strdup(yytext);return OPEN_SQUARE_BRACKET;
{OR}								prevCharNamespace = "type";yylval.str = strdup(yytext);return BITWISE_OR;
{OR}{OR}							prevCharNamespace = "type";yylval.str = strdup(yytext);return LOGICAL_OR;
{PLUS}{PLUS}							prevCharNamespace = "type";yylval.str = strdup(yytext);return INCREMENT;
{QUESTION_MARK}							prevCharNamespace = "type";yylval.str = strdup(yytext);return CONDITIONAL_OPERATOR;
{REGISTER}							prevCharNamespace = "type";yylval.str = strdup(yytext);return REGISTER;
{RETURN}							prevCharNamespace = "type";yylval.str = strdup(yytext);return RETURN;
{SEMI_COLON}							prevCharNamespace = "type";yylval.str = strdup(yytext);return EOS;
{SIZEOF}							prevCharNamespace = "type";yylval.str = strdup(yytext);return SIZEOF;
{STATIC}							prevCharNamespace = "type";yylval.str = strdup(yytext);return STATIC;
{STRING_LITERAL}						prevCharNamespace = "type";yylval.str = strdup(yytext);return STRING;
{STRUCT}							prevCharNamespace = "struct";yylval.str = strdup(yytext);return STRUCT;
{SWITCH}							prevCharNamespace = "type";yylval.str = strdup(yytext);return SWITCH;
{TILDE}								prevCharNamespace = "type";yylval.str = strdup(yytext);return BITWISE_INVERSE;
{TYPEDEF}							prevCharNamespace = "type";yylval.str = strdup(yytext);return TYPEDEF;
{TYPE_SPECIFIER_LONG}						prevCharNamespace = "type";yylval.str = strdup(yytext);return TYPE_LONG;
{TYPE_SPECIFIER_SHORT}						prevCharNamespace = "type";yylval.str = strdup(yytext);return TYPE_SHORT;
{TYPE_SPECIFIER_SIGNED}						prevCharNamespace = "type";yylval.str = strdup(yytext);return TYPE_SIGNED;
{TYPE_SPECIFIER_UNSIGNED}					prevCharNamespace = "type";yylval.str = strdup(yytext);return TYPE_UNSIGNED;
{TYPE}								prevCharNamespace = "type";yylval.str = strdup(yytext);return TYPE;
{UNION}								prevCharNamespace = "union";yylval.str = strdup(yytext);return UNION;
{VOLATILE_QUALIFIER}						prevCharNamespace = "type";yylval.str = strdup(yytext);return VOLATILE;
{WHILE}								prevCharNamespace = "type";yylval.str = strdup(yytext);return WHILE;
{XOR}								prevCharNamespace = "type";yylval.str = strdup(yytext);return BITWISE_XOR;

	/*The following values may match any of the above so it is best to seperate them*/
{ID}								prevCharNamespace = "type";yylval.str = strdup(yytext);return isType(yytext);
{NUMBER_ID}?{NUMBER}L?						prevCharNamespace = "type";yylval.str = strdup(yytext);return INT;
[0-9]+{FULL_STOP}[0-9]+L?					prevCharNamespace = "type";yylval.str = strdup(yytext);return FLOAT;
[ \t]+								/*Consumes all whitespace*/
^#.*$								/*consumes preprocessor instructions */
\/\/.*$								/*Consumes in line comments*/
\n								linenum++;prevCharNamespace = "type";
.                    						prevCharNamespace = "type";yylval.str = strdup(yytext);return UNKNOWN;

%%

int isType(char* string)
{
	if(getType(string, prevCharNamespace) == NULL)
		return ID;
	else
		return TYPE;
}
