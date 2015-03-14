
/*Must have all comments and preprocessor instructions removed beforehand*/

%option noyywrap

%{
	/* Add all include headers, globals and preprocessor directives here*/

	#include "CParser.hpp"

	int linenum = 1, columnnum = 1;

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
TYPE_SPECIFIER_LENGTH					short|long
TYPE_SPECIFIER_SIGNED					signed|unsigned
UNION							unionParser::
VOLATILE_QUALIFIER					volatile
WHILE							while
XOR							\^
NUMBER_ID						0[a-zA-Z]

%%

	/*Compare for individual tokens*/
{AMPERSAND}							columnnum++;yylval.str = strdup(yytext);return ADDRESS_OR_BITWISE_AND_T;
{AMPERSAND}{AMPERSAND}						columnnum++;yylval.str = strdup(yytext);return LOGICAL_AND_T;
{AUTO}								columnnum++;yylval.str = strdup(yytext);return AUTO_T;
{BREAK}								columnnum++;yylval.str = strdup(yytext);return BREAK_T;
{CASE}								columnnum++;yylval.str = strdup(yytext);return CASE_T;
{CHAR_LITERAL}							columnnum++;yylval.str = strdup(yytext);return CHAR_T;
{CLOSE_BRACKET}							columnnum++;yylval.str = strdup(yytext);return CLOSE_BRACKET_T;
{CLOSE_CURLY_BRACKET}						columnnum++;yylval.str = strdup(yytext);return CLOSE_CURLY_BRACKET_T;
{CLOSE_SQUARE_BRACKET}						columnnum++;yylval.str = strdup(yytext);return CLOSE_SQUARE_BRACKET_T;
{COLON}								columnnum++;yylval.str = strdup(yytext);return COLON_T;
{COMMA}								columnnum++;yylval.str = strdup(yytext);return COMMA_T;
{CONST_QUALIFIER} 						columnnum++;yylval.str = strdup(yytext);return CONST_T;
{CONTINUE}							columnnum++;yylval.str = strdup(yytext);return CONTINUE_T;
{DEFAULT}							columnnum++;yylval.str = strdup(yytext);return DEFAULT_T;
{DIVIDE}|{MODULUS}|{PLUS}|{MINUS}				columnnum++;yylval.str = strdup(yytext);return ARITHMETIC_T;
{DO}								columnnum++;yylval.str = strdup(yytext);return DO_T;
{ELLIPSES}							columnnum++;yylval.str = strdup(yytext);return ELLIPSES_T;
{ELSE}								columnnum++;yylval.str = strdup(yytext);return ELSE_T;
{ENUM}								columnnum++;yylval.str = strdup(yytext);return ENUM_T;
{EQUALS}							columnnum++;yylval.str = strdup(yytext);return EQUALS_T;
{EQUALS}{EQUALS}						columnnum++;yylval.str = strdup(yytext);return LOGICAL_EQUALS_T;
{EXTERN}							columnnum++;yylval.str = strdup(yytext);return EXTERN_T;
{FOR}								columnnum++;yylval.str = strdup(yytext);return FOR_T;
{FULL_STOP}							columnnum++;yylval.str = strdup(yytext);return FULL_STOP_T;
{GOTO}								columnnum++;yylval.str = strdup(yytext);return GOTO_T;
{GREATER_THAN}							columnnum++;yylval.str = strdup(yytext);return GREATER_THAN_T;
{GREATER_THAN}{EQUALS}						columnnum++;yylval.str = strdup(yytext);return GREATER_THAN_EQUALS_T;
{GREATER_THAN}{GREATER_THAN}					columnnum++;yylval.str = strdup(yytext);return BITWISE_RIGHT_T;
{IF}								columnnum++;yylval.str = strdup(yytext);return IF_T;
{LESS_THAN}							columnnum++;yylval.str = strdup(yytext);return LESS_THAN_T;
{LESS_THAN}{EQUALS}						columnnum++;yylval.str = strdup(yytext);return LESS_THAN_EQUALS_T;
{LESS_THAN}{LESS_THAN}						columnnum++;yylval.str = strdup(yytext);return BITWISE_LEFT_T;
{MINUS}{GREATER_THAN}						columnnum++;yylval.str = strdup(yytext);return POINTER_MEMBER_T;
{MINUS}{ID}							columnnum++;yylval.str = strdup(yytext);return INVERSE_T;
{MINUS}{MINUS}							columnnum++;yylval.str = strdup(yytext);return DECREMENT_T;
{MULTIPLY}							columnnum++;yylval.str = strdup(yytext);return MULT_OR_POINTER_T;
{NOT}								columnnum++;yylval.str = strdup(yytext);return NOT_T;
{NOT}{EQUALS}							columnnum++;yylval.str = strdup(yytext);return NOT_EQUALS_T;
{OPEN_BRACKET}							columnnum++;yylval.str = strdup(yytext);return OPEN_BRACKET_T;
{OPEN_CURLY_BRACKET}						columnnum++;yylval.str = strdup(yytext);return OPEN_CURLY_BRACKET_T;
{OPEN_SQUARE_BRACKET}						columnnum++;yylval.str = strdup(yytext);return OPEN_SQUARE_BRACKET_T;
{OR}								columnnum++;yylval.str = strdup(yytext);return BITWISE_OR_T;
{OR}{OR}							columnnum++;yylval.str = strdup(yytext);return LOGICAL_OR_T;
{PLUS}{ID}							columnnum++;yylval.str = strdup(yytext);return TYPE_PROMOTION_T;
{PLUS}{PLUS}							columnnum++;yylval.str = strdup(yytext);return INCREMENT_T;
{QUESTION_MARK}							columnnum++;yylval.str = strdup(yytext);return CONDITIONAL_OPERATOR_T;
{REGISTER}							columnnum++;yylval.str = strdup(yytext);return REGISTER_T;
{RETURN}							columnnum++;yylval.str = strdup(yytext);return RETURN_T;
{SEMI_COLON}							columnnum++;yylval.str = strdup(yytext);return EOS_T;
{SIZEOF}							columnnum++;yylval.str = strdup(yytext);return SIZEOF_T;
{STATIC}							columnnum++;yylval.str = strdup(yytext);return STATIC_T;
{STRING_LITERAL}						columnnum++;yylval.str = strdup(yytext);return STRING_T;
{STRUCT}							columnnum++;yylval.str = strdup(yytext);return STRUCT_T;
{SWITCH}							columnnum++;yylval.str = strdup(yytext);return SWITCH_T;
{TILDE}								columnnum++;yylval.str = strdup(yytext);return BITWISE_INVERSE_T;
{TYPEDEF}							columnnum++;yylval.str = strdup(yytext);return TYPEDEF_T;
{TYPE_SPECIFIER_LENGTH}						columnnum++;yylval.str = strdup(yytext);return TYPE_LENGTH_T;
{TYPE_SPECIFIER_SIGNED}						columnnum++;yylval.str = strdup(yytext);return TYPE_SIGNED_T;
{TYPE}								columnnum++;yylval.str = strdup(yytext);return TYPE_T;
{UNION}								columnnum++;yylval.str = strdup(yytext);return UNION_T;
{VOLATILE_QUALIFIER}						columnnum++;yylval.str = strdup(yytext);return VOLATILE_T;
{WHILE}								columnnum++;yylval.str = strdup(yytext);return WHILE_T;
{XOR}								columnnum++;yylval.str = strdup(yytext);return BITWISE_XOR_T;

	/*The following values may match any of the above so it is best to seperate them*/
{ID}								columnnum++;yylval.str = strdup(yytext);return ID_T;
{NUMBER_ID}?{NUMBER}L?						columnnum++;yylval.str = strdup(yytext);return INT_T;
{NUMBER}{FULL_STOP}{NUMBER}L?					columnnum++;yylval.str = strdup(yytext);return FLOAT_T;
[ \t]+								/*Consumes all whitespace*/
\n								linenum++; columnnum = 1;
.                    						columnnum++;yylval.str = strdup(yytext);return UNKNOWN;

%%


