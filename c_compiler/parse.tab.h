/* A Bison parser, made by GNU Bison 3.0.2.  */

/* Bison interface for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2013 Free Software Foundation, Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

#ifndef YY_YY_PARSE_TAB_H_INCLUDED
# define YY_YY_PARSE_TAB_H_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 0
#endif
#if YYDEBUG
extern int yydebug;
#endif

/* Token type.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    ADDRESS_OR_BITWISE_AND_T = 258,
    ARITHMETIC_T = 259,
    AUTO_T = 260,
    BITWISE_INVERSE_T = 261,
    BITWISE_LEFT_T = 262,
    BITWISE_OR_T = 263,
    BITWISE_RIGHT_T = 264,
    BITWISE_XOR_T = 265,
    BREAK_T = 266,
    CASE_T = 267,
    CHAR_T = 268,
    CLOSE_BRACKET_T = 269,
    CLOSE_CURLY_BRACKET_T = 270,
    CLOSE_SQUARE_BRACKET_T = 271,
    COLON_T = 272,
    COMMA_T = 273,
    CONST_T = 274,
    CONTINUE_T = 275,
    DECREMENT_T = 276,
    DEFAULT_T = 277,
    DO_T = 278,
    ELLIPSES_T = 279,
    ELSE_T = 280,
    ENUM_T = 281,
    EQUALS_T = 282,
    EOS_T = 283,
    EXTERN_T = 284,
    FLOAT_T = 285,
    FOR_T = 286,
    FULL_STOP_T = 287,
    GOTO_T = 288,
    GREATER_THAN_EQUALS_T = 289,
    GREATER_THAN_T = 290,
    ID_T = 291,
    IF_T = 292,
    INCREMENT_T = 293,
    INT_T = 294,
    INVERSE_T = 295,
    LESS_THAN_EQUALS_T = 296,
    LESS_THAN_T = 297,
    LOGICAL_AND_T = 298,
    LOGICAL_EQUALS_T = 299,
    LOGICAL_OR_T = 300,
    MULT_OR_POINTER_T = 301,
    NOT_EQUALS_T = 302,
    NOT_T = 303,
    OPEN_BRACKET_T = 304,
    OPEN_CURLY_BRACKET_T = 305,
    OPEN_SQUARE_BRACKET_T = 306,
    POINTER_MEMBER_T = 307,
    REGISTER_T = 308,
    RETURN_T = 309,
    SIZEOF_T = 310,
    STATIC_T = 311,
    STRING_T = 312,
    STRUCT_T = 313,
    SWITCH_T = 314,
    TYPEDEF_T = 315,
    TYPE_LENGTH_T = 316,
    TYPE_PROMOTION_T = 317,
    TYPE_SIGNED_T = 318,
    TYPE_T = 319,
    UNION_T = 320,
    UNKNOWN = 321,
    VOLATILE_T = 322,
    WHILE_T = 323,
    CONDITIONAL_OPERATOR_T = 324
  };
#endif

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef int YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;

int yyparse (void);

extern "C" int yylex();

#endif /* !YY_YY_PARSE_TAB_H_INCLUDED  */
