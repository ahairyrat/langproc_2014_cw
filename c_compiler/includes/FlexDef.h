
#ifndef	_FLEXDEF_H
#define	_FLEXDEF_H

enum  flex_type{
	ADDRESS_OR_BITWISE_AND_T	=	0x400,
	ARITHMETIC_T				=	0x401,
	AUTO_T						=	0x402,
	BITWISE_INVERSE_T			=	0x403,
	BITWISE_LEFT_T				=	0x404,
	BITWISE_OR_T				=	0x405,
	BITWISE_RIGHT_T				=	0x406,
	BITWISE_XOR_T				=	0x407,
	BREAK_T						=	0x408,
	CASE_T						=	0x409,
	CHAR_T						=	0x410,
	CLOSE_BRACKET_T				=	0x411,
	CLOSE_CURLY_BRACKET_T		=	0x412,
	CLOSE_SQUARE_BRACKET_T		=	0x413,
	COLON_T						=	0x414,
	COMMA_T						=	0x415,
	CONDITIONAL_OPERATOR		=	0x416,
	CONST_T						=	0x417,
	CONTINUE_T					=	0x418,
	DECREMENT_T					=	0x419,
	DEFAULT_T					=	0x420,
	DO_T						=	0x421,
	ELLIPSES_T					=	0x465,
	ELSE_T						=	0x422,
	ENUM_T						=	0x423,
	EQUALS_T					= 	0x466,
	EOS_T						=	0x424,
	EXTERN_T					=	0x425,
	FLOAT_T						=	0x426,
	FOR_T						=	0x427,
	FULL_STOP_T					=	0x428,
	GOTO_T						=	0x429,
	GREATER_THAN_EQUALS_T		=	0x430,
	GREATER_THAN_T				=	0x431,
	ID_T						=	0x443,
	IF_T						=	0x432,
	INCREMENT_T					=	0x434,
	INT_T						=	0x435,
	INVERSE_T					=	0x436,
	LESS_THAN_EQUALS_T			=	0x437,
	LESS_THAN_T					=	0x438,
	LOGICAL_AND_T				=	0x439,
	LOGICAL_EQUALS_T			=	0x440,
	LOGICAL_OR_T				=	0x441,
	MULT_OR_POINTER_T			=	0x442,
	NOT_EQUALS_T				=	0x444,
	NOT_T						=	0x445,
	OPEN_BRACKET_T				=	0x446,
	OPEN_CURLY_BRACKET_T		=	0x447,
	OPEN_SQUARE_BRACKET_T		=	0x448,
	POINTER_MEMBER_T			=	0x449,
	REGISTER_T					=	0x450,
	RETURN_T					=	0x451,
	SIZEOF_T					=	0x452,
	STATIC_T					=	0x453,
	STRING_T					=	0x454,
	STRUCT_T					=	0x455,
	SWITCH_T					=	0x456,
	TYPEDEF_T					=	0x457,
	TYPE_LENGTH_T				=	0x458,
	TYPE_PROMOTION_T			=	0x459,
	TYPE_SIGNED_T				=	0x460,
	TYPE_T						=	0x461,
	UNION_T						=	0x462,
	UNKNOWN						=	0x800,
	VOLATILE_T					=	0x463,
	WHILE_T						=	0x464,
};


class tokn_t
{
public:
	virtual std::string toString(){
		return Data;
	}

	virtual void setData(std::string input){
		Data = input;
	}
private:
	std::string Data; 
};

struct flex_def{
public:
	flex_def(flex_type name, const char* Data_in, int linenum, int columnnum)
	:name(name), linenum(linenum),columnnum(columnnum){
		Data.setData(Data_in);
	}

	flex_type	name;
	tokn_t	Data;
	int linenum;
	int columnnum;
};
	
#endif
