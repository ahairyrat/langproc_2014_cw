
/*Must have all comments and preprocessor instructions removed beforehand*/

%option noyywrap
%option c++

%{
	/* Add all include headers, globals and preprocessor directives here*/

	#include "CParser.h"

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
FOR								for
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
WHILE							whileyylval.str = strdup(yytext)
XOR								\^
NUMBER_ID						0[a-zA-Z]

%%

	/*Compare for individual tokens*/
{AMPERSAND}							columnnum++;return C_Parser::ADDRESS_OR_BITWIyylval.str = strdup(yytext)SE_AND_T;
{AMPERSAND}{AMPERSAND}						columnnum++;return C_Parser::LOGICAL_AND_T;
{AUTO}								columnnum++;return C_Parser::AUTO_T;
{BREAK}								columnnum++;return C_Parser::BREAK_T;
{CASE}								columnnum++;return C_Parser::CASE_T;
{CHAR_LITERAL}							columnnum++;return C_Parser::CHAR_T;
{CLOSE_BRACKET}							columnnum++;return C_Parser::CLOSE_BRACKET_T;
{CLOSE_CURLY_BRACKET}						columnnum++;return C_Parser::CLOSE_CURLY_BRACKET_T;
{CLOSE_SQUARE_BRACKET}						columnnum++;return C_Parser::CLOSE_SQUARE_BRACKET_T;
{COLON}								columnnum++;return C_Parser::COLON_T;
{COMMA}								columnnum++;return C_Parser::COMMA_T;
{CONST_QUALIFIER} 						columnnum++;return C_Parser::CONST_T;
{CONTINUE}							columnnum++;return C_Parser::CONTINUE_T;
{DEFAULT}							columnnum++;return C_Parser::DEFAULT_T;
{DIVIDE}|{MODULUS}|{PLUS}|{MINUS}				columnnum++;return C_Parser::ARITHMETIC_T;
{DO}								columnnum++;return C_Parser::DO_T;
{ELLIPSES}							columnnum++;return C_Parser::ELLIPSES_T;
{ELSE}								columnnum++;return C_Parser::ELSE_T;
{ENUM}								columnnum++;return C_Parser::ENUM_T;
{EQUALS}							columnnum++;return C_Parser::EQUALS_T;
{EQUALS}{EQUALS}						columnnum++;return C_Parser::LOGICAL_EQUALS_T;
{EXTERN}							columnnum++;return C_Parser::EXTERN_T;
{FOR}								columnnum++;return C_Parser::FOR_T;
{FULL_STOP}							columnnum++;return C_Parser::FULL_STOP_T;
{GOTO}								columnnum++;return C_Parser::GOTO_T;
{GREATER_THAN}							columnnum++;return C_Parser::GREATER_THAN_T;
{GREATER_THAN}{EQUALS}						columnnum++;return C_Parser::GREATER_THAN_EQUALS_T;
{GREATER_THAN}{GREATER_THAN}					columnnum++;return C_Parser::BITWISE_RIGHT_T;
{IF}								columnnum++;return C_Parser::IF_T;
{LESS_THAN}							columnnum++;return C_Parser::LESS_THAN_T;
{LESS_THAN}{EQUALS}						columnnum++;return C_Parser::LESS_THAN_EQUALS_T;
{LESS_THAN}{LESS_THAN}						columnnum++;return C_Parser::BITWISE_LEFT_T;
{MINUS}{GREATER_THAN}						columnnum++;return C_Parser::POINTER_MEMBER_T;
{MINUS}{ID}							columnnum++;return C_Parser::INVERSE_T;
{MINUS}{MINUS}							columnnum++;return C_Parser::DECREMENT_T;
{MULTIPLY}							columnnum++;return C_Parser::MULT_OR_POINTER_T;
{NOT}								columnnum++;return C_Parser::NOT_T;
{NOT}{EQUALS}							columnnum++;return C_Parser::NOT_EQUALS_T;
{OPEN_BRACKET}							columnnum++;return C_Parser::OPEN_BRACKET_T;
{OPEN_CURLY_BRACKET}						columnnum++;return C_Parser::OPEN_CURLY_BRACKET_T;
{OPEN_SQUARE_BRACKET}						columnnum++;return C_Parser::OPEN_SQUARE_BRACKET_T;
{OR}								columnnum++;return C_Parser::BITWISE_OR_T;
{OR}{OR}							columnnum++;return C_Parser::LOGICAL_OR_T;
{PLUS}{ID}							columnnum++;return C_Parser::TYPE_PROMOTION_T;
{PLUS}{PLUS}							columnnum++;return C_Parser::INCREMENT_T;
{QUESTION_MARK}							columnnum++;return C_Parser::CONDITIONAL_OPERATOR_T;
{REGISTER}							columnnum++;return C_Parser::REGISTER_T;
{RETURN}					columnnum++;r		columnnum++;return C_Parser::RETURN_T;
{SEMI_COLON}							columnnum++;return C_Parser::EOS_T;
{SIZEOF}							columnnum++;return C_Parser::SIZEOF_T;
{STATIC}							columnnum++;return C_Parser::STATIC_T;
{STRING_LITERAL}						columnnum++;return C_Parser::STRING_T;
{STRUCT}							columnnum++;return C_Parser::STRUCT_T;
{SWITCH}							columnnum++;return C_Parser::SWITCH_T;
{TILDE}								columnnum++;return C_Parser::BITWISE_INVERSE_T;
{TYPEDEF}							columnnum++;return C_Parser::TYPEDEF_T;
{TYPE_SPECIFIER_LENGTH}						columnnum++;return C_Parser::TYPE_LENGTH_T;
{TYPE_SPECIFIER_SIGNED}						columnnum++;return C_Parser::TYPE_SIGNED_T;
{TYPE}								columnnum++;return C_Parser::TYPE_T;
{UNION}								columnnum++;return C_Parser::UNION_T;
{VOLATILE_QUALIFIER}						columnnum++;return C_Parser::VOLATILE_T;
{WHILE}								columnnum++;return C_Parser::WHILE_T;
{XOR}								columnnum++;return C_Parser::BITWISE_XOR_T;

	/*The following values may match any of the above so it is best to seperate them*/
{ID}								columnnum++;return C_Parser::ID_T;
{NUMBER_ID}?{NUMBER}L?						columnnum++;return C_Parser::INT_T;
{NUMBER}{FULL_STOP}{NUMBER}L?					columnnum++;return C_Parser::FLOAT_T;
[ \t]+								/*Consumes all whitespace*/
\n								linenum++; columnnum = 1;
.                    						columnnum++;return C_Parser::UNKNOWN;

%%


