
/*Must have all comments and preprocessor instructions removed beforehand*/

%option noyywrap

%{
	/* Add all include headers, globals and preprocessor directives here*/
	

	
	#include "parse.tab.h"
	
	int linenum = 0;
	int columnnum = 0;

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
UNION							union
VOLATILE_QUALIFIER					volatile
WHILE							while
XOR								\^
NUMBER_ID						0[a-zA-Z]

%%

	/*Compare for individual tokens*/
{AMPERSAND}							return ADDRESS_OR_BITWISE_AND_T;columnnum++;
{AMPERSAND}{AMPERSAND}						return LOGICAL_AND_T;columnnum++;
{AUTO}								return AUTO_T;columnnum++;
{BREAK}								return BREAK_T;columnnum++;
{CASE}								return CASE_T;columnnum++;
{CHAR_LITERAL}							return CHAR_T;columnnum++;
{CLOSE_BRACKET}							return CLOSE_BRACKET_T;columnnum++;
{CLOSE_CURLY_BRACKET}						return CLOSE_CURLY_BRACKET_T;columnnum++;
{CLOSE_SQUARE_BRACKET}						return CLOSE_SQUARE_BRACKET_T;columnnum++;
{COLON}								return COLON_T;columnnum++;
{COMMA}								return COMMA_T;columnnum++;
{CONST_QUALIFIER} 						return CONST_T;columnnum++;
{CONTINUE}							return CONTINUE_T;columnnum++;
{DEFAULT}							return DEFAULT_T;columnnum++;
{DIVIDE}|{MODULUS}|{PLUS}|{MINUS}				return ARITHMETIC_T;columnnum++;
{DO}								return DO_T;columnnum++;
{ELLIPSES}							return ELLIPSES_T;columnnum++;
{ELSE}								return ELSE_T;columnnum++;
{ENUM}								return ENUM_T;columnnum++;
{EQUALS}							return EQUALS_T;columnnum++;
{EQUALS}{EQUALS}						return LOGICAL_EQUALS_T;columnnum++;
{EXTERN}							return EXTERN_T;columnnum++;
{FOR}								return FOR_T;columnnum++;
{FULL_STOP}							return FULL_STOP_T;columnnum++;
{GOTO}								return GOTO_T;columnnum++;
{GREATER_THAN}							return GREATER_THAN_T;columnnum++;
{GREATER_THAN}{EQUALS}						return GREATER_THAN_EQUALS_T;columnnum++;
{GREATER_THAN}{GREATER_THAN}					return BITWISE_RIGHT_T;columnnum++;
{IF}								return IF_T;columnnum++;
{LESS_THAN}							return LESS_THAN_T;columnnum++;
{LESS_THAN}{EQUALS}						return LESS_THAN_EQUALS_T;columnnum++;
{LESS_THAN}{LESS_THAN}						return BITWISE_LEFT_T;columnnum++;
{MINUS}{GREATER_THAN}						return POINTER_MEMBER_T;columnnum++;
{MINUS}{ID}							return INVERSE_T;columnnum++;
{MINUS}{MINUS}							return DECREMENT_T;columnnum++;
{MULTIPLY}							return MULT_OR_POINTER_T;columnnum++;
{NOT}								return NOT_T;columnnum++;
{NOT}{EQUALS}							return NOT_EQUALS_T;columnnum++;
{OPEN_BRACKET}							return OPEN_BRACKET_T;columnnum++;
{OPEN_CURLY_BRACKET}						return OPEN_CURLY_BRACKET_T;columnnum++;
{OPEN_SQUARE_BRACKET}						return OPEN_SQUARE_BRACKET_T;columnnum++;
{OR}								return BITWISE_OR_T;columnnum++;
{OR}{OR}							return LOGICAL_OR_T;columnnum++;
{PLUS}{ID}							return TYPE_PROMOTION_T;columnnum++;
{PLUS}{PLUS}							return INCREMENT_T;columnnum++;
{QUESTION_MARK}							return CONDITIONAL_OPERATOR_T;columnnum++;
{REGISTER}							return REGISTER_T;columnnum++;
{RETURN}							return RETURN_T;columnnum++;
{SEMI_COLON}							return EOS_T;columnnum++;
{SIZEOF}							return SIZEOF_T;columnnum++;
{STATIC}							return STATIC_T;columnnum++;
{STRING_LITERAL}						return STRING_T;columnnum++;
{STRUCT}							return STRUCT_T;columnnum++;
{SWITCH}							return SWITCH_T;columnnum++;
{TILDE}								return BITWISE_INVERSE_T;columnnum++;
{TYPEDEF}							return TYPEDEF_T;columnnum++;
{TYPE_SPECIFIER_LENGTH}						return TYPE_LENGTH_T;columnnum++;
{TYPE_SPECIFIER_SIGNED}						return TYPE_SIGNED_T;columnnum++;
{TYPE}								return TYPE_T;columnnum++;
{UNION}								return UNION_T;columnnum++;
{VOLATILE_QUALIFIER}						return VOLATILE_T;columnnum++;
{WHILE}								return WHILE_T;columnnum++;
{XOR}								return BITWISE_XOR_T;columnnum++;

	/*The following values may match any of the above so it is best to seperate them*/
{ID}								return ID_T;columnnum++;
{NUMBER_ID}?{NUMBER}L?						return INT_T;columnnum++;
{NUMBER}{FULL_STOP}{NUMBER}L?					return FLOAT_T;columnnum++;
[ \t]+								/*Consumes all whitespace*/
\n								{linenum++; columnnum = 0;};
.                    						return UNKNOWN;

%%


