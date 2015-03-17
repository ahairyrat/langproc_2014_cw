
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
CHAR_LITERAL						\'([^\'\\]|\\.)\'
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
{AMPERSAND}							columnnum++;yylval.str = strdup(yytext);return ADDRESS_OR_BITWISE_AND;
{AMPERSAND}{AMPERSAND}						columnnum++;yylval.str = strdup(yytext);return LOGICAL_AND;
{AUTO}								columnnum++;yylval.str = strdup(yytext);return AUTO;
{BREAK}								columnnum++;yylval.str = strdup(yytext);return BREAK;
{CASE}								columnnum++;yylval.str = strdup(yytext);return CASE;
{CHAR_LITERAL}							columnnum++;yylval.str = strdup(yytext);return CHAR;
{CLOSE_BRACKET}							columnnum++;yylval.str = strdup(yytext);return CLOSE_BRACKET;
{CLOSE_CURLY_BRACKET}						columnnum++;yylval.str = strdup(yytext);return CLOSE_CURLY_BRACKET;
{CLOSE_SQUARE_BRACKET}						columnnum++;yylval.str = strdup(yytext);return CLOSE_SQUARE_BRACKET;
{COLON}								columnnum++;yylval.str = strdup(yytext);return COLON;
{COMMA}								columnnum++;yylval.str = strdup(yytext);return COMMA;
{CONST_QUALIFIER} 						columnnum++;yylval.str = strdup(yytext);return CONST;
{CONTINUE}							columnnum++;yylval.str = strdup(yytext);return CONTINUE;
{DEFAULT}							columnnum++;yylval.str = strdup(yytext);return DEFAULT;
{DIVIDE}|{MODULUS}|{PLUS}|{MINUS}				columnnum++;yylval.str = strdup(yytext);return ARITHMETIC;
{DO}								columnnum++;yylval.str = strdup(yytext);return DO;
{ELLIPSES}							columnnum++;yylval.str = strdup(yytext);return ELLIPSES;
{ELSE}								columnnum++;yylval.str = strdup(yytext);return ELSE;
{ENUM}								columnnum++;yylval.str = strdup(yytext);return ENUM;
{EQUALS}							columnnum++;yylval.str = strdup(yytext);return EQUALS;
{EQUALS}{EQUALS}						columnnum++;yylval.str = strdup(yytext);return LOGICAL_EQUALS;
{EXTERN}							columnnum++;yylval.str = strdup(yytext);return EXTERN;
{FOR}								columnnum++;yylval.str = strdup(yytext);return FOR;
{FULL_STOP}							columnnum++;yylval.str = strdup(yytext);return FULL_STOP;
{GOTO}								columnnum++;yylval.str = strdup(yytext);return GOTO;
{GREATER_THAN}							columnnum++;yylval.str = strdup(yytext);return GREATER_THAN;
{GREATER_THAN}{EQUALS}						columnnum++;yylval.str = strdup(yytext);return GREATER_THAN_EQUALS;
{GREATER_THAN}{GREATER_THAN}					columnnum++;yylval.str = strdup(yytext);return BITWISE_RIGHT;
{IF}								columnnum++;yylval.str = strdup(yytext);return IF;
{LESS_THAN}							columnnum++;yylval.str = strdup(yytext);return LESS_THAN;
{LESS_THAN}{EQUALS}						columnnum++;yylval.str = strdup(yytext);return LESS_THAN_EQUALS;
{LESS_THAN}{LESS_THAN}						columnnum++;yylval.str = strdup(yytext);return BITWISE_LEFT;
{MINUS}{GREATER_THAN}						columnnum++;yylval.str = strdup(yytext);return POINTER_MEMBER;
{MINUS}{ID}							columnnum++;yylval.str = strdup(yytext);return INVERSE;
{MINUS}{MINUS}							columnnum++;yylval.str = strdup(yytext);return DECREMENT;
{MULTIPLY}							columnnum++;yylval.str = strdup(yytext);return MULT_OR_POINTER;
{NOT}								columnnum++;yylval.str = strdup(yytext);return NOT;
{NOT}{EQUALS}							columnnum++;yylval.str = strdup(yytext);return NOT_EQUALS;
{OPEN_BRACKET}							columnnum++;yylval.str = strdup(yytext);return OPEN_BRACKET;
{OPEN_CURLY_BRACKET}						columnnum++;yylval.str = strdup(yytext);return OPEN_CURLY_BRACKET;
{OPEN_SQUARE_BRACKET}						columnnum++;yylval.str = strdup(yytext);return OPEN_SQUARE_BRACKET;
{OR}								columnnum++;yylval.str = strdup(yytext);return BITWISE_OR;
{OR}{OR}							columnnum++;yylval.str = strdup(yytext);return LOGICAL_OR;
{PLUS}{ID}							columnnum++;yylval.str = strdup(yytext);return TYPE_PROMOTION;
{PLUS}{PLUS}							columnnum++;yylval.str = strdup(yytext);return INCREMENT;
{QUESTION_MARK}							columnnum++;yylval.str = strdup(yytext);return CONDITIONAL_OPERATOR;
{REGISTER}							columnnum++;yylval.str = strdup(yytext);return REGISTER;
{RETURN}							columnnum++;yylval.str = strdup(yytext);return RETURN;
{SEMI_COLON}							columnnum++;yylval.str = strdup(yytext);return EOS;
{SIZEOF}							columnnum++;yylval.str = strdup(yytext);return SIZEOF;
{STATIC}							columnnum++;yylval.str = strdup(yytext);return STATIC;
{STRING_LITERAL}						columnnum++;yylval.str = strdup(yytext);return STRING;
{STRUCT}							columnnum++;yylval.str = strdup(yytext);return STRUCT;
{SWITCH}							columnnum++;yylval.str = strdup(yytext);return SWITCH;
{TILDE}								columnnum++;yylval.str = strdup(yytext);return BITWISE_INVERSE;
{TYPEDEF}							columnnum++;yylval.str = strdup(yytext);return TYPEDEF;
{TYPE_SPECIFIER_LONG}						columnnum++;yylval.str = strdup(yytext);return TYPE_LONG;
{TYPE_SPECIFIER_SHORT}						columnnum++;yylval.str = strdup(yytext);return TYPE_SHORT;
{TYPE_SPECIFIER_SIGNED}						columnnum++;yylval.str = strdup(yytext);return TYPE_SIGNED;
{TYPE_SPECIFIER_UNSIGNED}					columnnum++;yylval.str = strdup(yytext);return TYPE_UNSIGNED;
{TYPE}								columnnum++;yylval.str = strdup(yytext);return TYPE;
{UNION}								columnnum++;yylval.str = strdup(yytext);return UNION;
{VOLATILE_QUALIFIER}						columnnum++;yylval.str = strdup(yytext);return VOLATILE;
{WHILE}								columnnum++;yylval.str = strdup(yytext);return WHILE;
{XOR}								columnnum++;yylval.str = strdup(yytext);return BITWISE_XOR;

	/*The following values may match any of the above so it is best to seperate them*/
{ID}								columnnum++;yylval.str = strdup(yytext);return isType(yytext);
{NUMBER_ID}?{NUMBER}L?						columnnum++;yylval.str = strdup(yytext);return INT;
{NUMBER}{FULL_STOP}{NUMBER}L?					columnnum++;yylval.str = strdup(yytext);return FLOAT;
[ \t]+								/*Consumes all whitespace*/
\n								linenum++; columnnum = 1;
.                    						columnnum++;yylval.str = strdup(yytext);return UNKNOWN;

%%

int isType(char* string)
{
	if(getType(string, "type") == NULL &&  getType(string, "enum") == NULL && getType(string, "struct") == NULL && getType(string, "union") == NULL)
		return ID;
	else
		return TYPE;
}
