

typedef ::= 'TYPEDEF_T' variable 'SEMI_COLON_T'  => add value into map of types

basic_type ::= 	=> defined as list of items stored as keys in type map

qual_pointer ::= 'MULT_OR_POINTER_T' qualifier

pointer ::= qual_pointer | 'MULT_OR_POINTER_T'

pointer_list ::= (pointer pointer_list) | pointer

qualifier ::= 'CONST_T' | 'VOLATILE_T'

storage ::= 'EXTERN_T' | 'AUTO_T' | 'STATIC_T' | 'REGISTER_T'

variable ::= type dereferenced_id | dereferenced_id

type ::= (non_pointer_type pointer_list) | non_pointer_type

non_pointer_type ::= non_pointer_basic_type | modified_struct

non_pointer_basic_type ::= modifier_list basic_type modifier_list |
				basic_type modifier_list |
				modifier_list basic_type |
				modifier_list

dereferenced_id ::= ('BRACKET_T' 'MULT_OR_POINTER_T' 'ID_T'' BRACKET_T') | 'ID_T'

length ::= 'TYPE_LENGTH_T'

signed ::= 'TYPE_SIGNED_T'

struct_def ::= 'STRUCT_T' 'ID_T' 'OPEN_CURLY_BRACKET_T' .................................... 'CLOSE_CURLY_BRACKET_T'

struct_use ::= 'STRUCT_T' 'ID_T'

struct ::= struct_def | struct_use

function_def ::= variable 'OPEN_BRACKETS_T' parameter_list 'CLOSE_BRACKETS_T 'OPEN_CURLY_BRACKET_T' .................................... 'CLOSE_CURLY_BRACKET_T'

modifier ::= length | storage | qualifier | signed

modifier_list ::= (modifier modifier_list) | modifier

modified_struct ::= modifier_list struct | struct

number ::= 'INT_T' | 'FLOAT_T'

parameter_list ::= (variable 'COMMA_T' parameter_list) | variable 












