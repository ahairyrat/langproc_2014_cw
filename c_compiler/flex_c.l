
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
{AMPERSAND}							columnnum++;prevCharNamespace = "type";yylval.str = strdup(yytext);return ADDRESS_OR_BITWISE_AND;
{AMPERSAND}{AMPERSAND}						columnnum++;prevCharNamespace = "type";yylval.str = strdup(yytext);return LOGICAL_AND;
{AUTO}								columnnum++;prevCharNamespace = "type";yylval.str = strdup(yytext);return AUTO;
{BREAK}								columnnum++;prevCharNamespace = "type";yylval.str = strdup(yytext);return BREAK;
{CASE}								columnnum++;prevCharNamespace = "type";yylval.str = strdup(yytext);return CASE;
{CHAR_LITERAL}							columnnum++;prevCharNamespace = "type";yylval.str = strdup(yytext);return CHAR;
{CLOSE_BRACKET}							columnnum++;prevCharNamespace = "type";yylval.str = strdup(yytext);return CLOSE_BRACKET;
{CLOSE_CURLY_BRACKET}						columnnum++;prevCharNamespace = "type";yylval.str = strdup(yytext);return CLOSE_CURLY_BRACKET;
{CLOSE_SQUARE_BRACKET}						columnnum++;prevCharNamespace = "type";yylval.str = strdup(yytext);return CLOSE_SQUARE_BRACKET;
{COLON}								columnnum++;prevCharNamespace = "type";yylval.str = strdup(yytext);return COLON;
{COMMA}								columnnum++;prevCharNamespace = "type";yylval.str = strdup(yytext);return COMMA;
{CONST_QUALIFIER} 						columnnum++;prevCharNamespace = "type";yylval.str = strdup(yytext);return CONST;
{CONTINUE}							columnnum++;prevCharNamespace = "type";yylval.str = strdup(yytext);return CONTINUE;
{DEFAULT}							columnnum++;prevCharNamespace = "type";yylval.str = strdup(yytext);return DEFAULT;
{DIVIDE}|{MODULUS}|{PLUS}|{MINUS}				columnnum++;prevCharNamespace = "type";yylval.str = strdup(yytext);return ARITHMETIC;
{DO}								columnnum++;prevCharNamespace = "type";yylval.str = strdup(yytext);return DO;
{ELLIPSES}							columnnum++;prevCharNamespace = "type";yylval.str = strdup(yytext);return ELLIPSES;
{ELSE}								columnnum++;prevCharNamespace = "type";yylval.str = strdup(yytext);return ELSE;
{ENUM}								columnnum++;prevCharNamespace = "enum";yylval.str = strdup(yytext);return ENUM;
{EQUALS}							columnnum++;prevCharNamespace = "type";yylval.str = strdup(yytext);return EQUALS;
{EQUALS}{EQUALS}						columnnum++;prevCharNamespace = "type";yylval.str = strdup(yytext);return LOGICAL_EQUALS;
{EXTERN}							columnnum++;prevCharNamespace = "type";yylval.str = strdup(yytext);return EXTERN;
{FOR}								columnnum++;prevCharNamespace = "type";yylval.str = strdup(yytext);return FOR;
{FULL_STOP}							columnnum++;prevCharNamespace = "type";yylval.str = strdup(yytext);return FULL_STOP;
{GOTO}								columnnum++;prevCharNamespace = "type";yylval.str = strdup(yytext);return GOTO;
{GREATER_THAN}							columnnum++;prevCharNamespace = "type";yylval.str = strdup(yytext);return GREATER_THAN;
{GREATER_THAN}{EQUALS}						columnnum++;prevCharNamespace = "type";yylval.str = strdup(yytext);return GREATER_THAN_EQUALS;
{GREATER_THAN}{GREATER_THAN}					columnnum++;prevCharNamespace = "type";yylval.str = strdup(yytext);return BITWISE_RIGHT;
{IF}								columnnum++;prevCharNamespace = "type";yylval.str = strdup(yytext);return IF;
{LESS_THAN}							columnnum++;prevCharNamespace = "type";yylval.str = strdup(yytext);return LESS_THAN;
{LESS_THAN}{EQUALS}						columnnum++;prevCharNamespace = "type";yylval.str = strdup(yytext);return LESS_THAN_EQUALS;
{LESS_THAN}{LESS_THAN}						columnnum++;prevCharNamespace = "type";yylval.str = strdup(yytext);return BITWISE_LEFT;
{MINUS}{GREATER_THAN}						columnnum++;prevCharNamespace = "type";yylval.str = strdup(yytext);return POINTER_MEMBER;
{MINUS}{ID}							columnnum++;prevCharNamespace = "type";yylval.str = strdup(yytext);return INVERSE;
{MINUS}{MINUS}							columnnum++;prevCharNamespace = "type";yylval.str = strdup(yytext);return DECREMENT;
{MULTIPLY}							columnnum++;prevCharNamespace = "type";yylval.str = strdup(yytext);return MULT_OR_POINTER;
{NOT}								columnnum++;prevCharNamespace = "type";yylval.str = strdup(yytext);return NOT;
{NOT}{EQUALS}							columnnum++;prevCharNamespace = "type";yylval.str = strdup(yytext);return NOT_EQUALS;
{OPEN_BRACKET}							columnnum++;prevCharNamespace = "type";yylval.str = strdup(yytext);return OPEN_BRACKET;
{OPEN_CURLY_BRACKET}						columnnum++;prevCharNamespace = "type";yylval.str = strdup(yytext);return OPEN_CURLY_BRACKET;
{OPEN_SQUARE_BRACKET}						columnnum++;prevCharNamespace = "type";yylval.str = strdup(yytext);return OPEN_SQUARE_BRACKET;
{OR}								columnnum++;prevCharNamespace = "type";yylval.str = strdup(yytext);return BITWISE_OR;
{OR}{OR}							columnnum++;prevCharNamespace = "type";yylval.str = strdup(yytext);return LOGICAL_OR;
{PLUS}{ID}							columnnum++;prevCharNamespace = "type";yylval.str = strdup(yytext);return TYPE_PROMOTION;
{PLUS}{PLUS}							columnnum++;prevCharNamespace = "type";yylval.str = strdup(yytext);return INCREMENT;
{QUESTION_MARK}							columnnum++;prevCharNamespace = "type";yylval.str = strdup(yytext);return CONDITIONAL_OPERATOR;
{REGISTER}							columnnum++;prevCharNamespace = "type";yylval.str = strdup(yytext);return REGISTER;
{RETURN}							columnnum++;prevCharNamespace = "type";yylval.str = strdup(yytext);return RETURN;
{SEMI_COLON}							columnnum++;prevCharNamespace = "type";yylval.str = strdup(yytext);return EOS;
{SIZEOF}							columnnum++;prevCharNamespace = "type";yylval.str = strdup(yytext);return SIZEOF;
{STATIC}							columnnum++;prevCharNamespace = "type";yylval.str = strdup(yytext);return STATIC;
{STRING_LITERAL}						columnnum++;prevCharNamespace = "type";yylval.str = strdup(yytext);return STRING;
{STRUCT}							columnnum++;prevCharNamespace = "struct";yylval.str = strdup(yytext);return STRUCT;
{SWITCH}							columnnum++;prevCharNamespace = "type";yylval.str = strdup(yytext);return SWITCH;
{TILDE}								columnnum++;prevCharNamespace = "type";yylval.str = strdup(yytext);return BITWISE_INVERSE;
{TYPEDEF}							columnnum++;prevCharNamespace = "type";yylval.str = strdup(yytext);return TYPEDEF;
{TYPE_SPECIFIER_LONG}						columnnum++;prevCharNamespace = "type";yylval.str = strdup(yytext);return TYPE_LONG;
{TYPE_SPECIFIER_SHORT}						columnnum++;prevCharNamespace = "type";yylval.str = strdup(yytext);return TYPE_SHORT;
{TYPE_SPECIFIER_SIGNED}						columnnum++;prevCharNamespace = "type";yylval.str = strdup(yytext);return TYPE_SIGNED;
{TYPE_SPECIFIER_UNSIGNED}					columnnum++;prevCharNamespace = "type";yylval.str = strdup(yytext);return TYPE_UNSIGNED;
{TYPE}								columnnum++;prevCharNamespace = "type";yylval.str = strdup(yytext);return TYPE;
{UNION}								columnnum++;prevCharNamespace = "union";yylval.str = strdup(yytext);return UNION;
{VOLATILE_QUALIFIER}						columnnum++;prevCharNamespace = "type";yylval.str = strdup(yytext);return VOLATILE;
{WHILE}								columnnum++;prevCharNamespace = "type";yylval.str = strdup(yytext);return WHILE;
{XOR}								columnnum++;prevCharNamespace = "type";yylval.str = strdup(yytext);return BITWISE_XOR;

	/*The following values may match any of the above so it is best to seperate them*/
{ID}								columnnum++;prevCharNamespace = "type";yylval.str = strdup(yytext);return isType(yytext);
{NUMBER_ID}?{NUMBER}L?						columnnum++;prevCharNamespace = "type";yylval.str = strdup(yytext);return INT;
{NUMBER}{FULL_STOP}{NUMBER}L?					columnnum++;prevCharNamespace = "type";yylval.str = strdup(yytext);return FLOAT;
[ \t]+								/*Consumes all whitespace*/
^#.*$								/*consumes preprocessor instructions */
\n								linenum++;prevCharNamespace = "type"; columnnum = 1;
.                    						columnnum++;prevCharNamespace = "type";yylval.str = strdup(yytext);return UNKNOWN;

%%

int isType(char* string)
{
	if(getType(string, prevCharNamespace) == NULL)
		return ID;
	else
		return TYPE;
}
