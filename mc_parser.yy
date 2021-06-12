%skeleton "lalr1.cc"
%require  "3.0"
%debug 
%defines 
%define api.namespace {MC}
/**
 * bison 3.3.2 change
 * %define parser_class_name to this, updated
 * should work for previous bison versions as 
 * well. -jcb 24 Jan 2020
 */
%define api.parser.class {MC_Parser}

%code requires{
   namespace MC {
      class MC_Driver;
      class MC_Scanner;
   }

// The following definitions is missing when %locations isn't used
# ifndef YY_NULLPTR
#  if defined __cplusplus && 201103L <= __cplusplus
#   define YY_NULLPTR nullptr
#  else
#   define YY_NULLPTR 0
#  endif
# endif

}

%parse-param { MC_Scanner  &scanner  }
%parse-param { MC_Driver  &driver  }

%code{
   #include <iostream>
   #include <cstdlib>
   #include <fstream>
   
   /* include for all driver functions */
   #include "mc_driver.hpp"

#undef yylex
#define yylex scanner.yylex
}

%define api.value.type variant
%define parse.assert

%token               END    0     "end of file"
%token <std::string> WORD
%token               NEWLINE
%token               ASSIGN
%token               COMMENT
%token <std::string> COMMAND
%token <std::string> DEVICE
%token <std::string> TITLE
%token <std::string> VALUE
%token <std::string> FACTOR
%token <std::string> UNIT

%locations

%%

spice_deck 
: TITLE  { driver.add_title( $1 ); } END
| TITLE  { driver.add_title( $1 ); } cards END

cards
  : 
  | cards card
  ;  

card 
  : control_card
  | device_card
  ;

control_card 
   : COMMAND {driver.add_command($1); } list NEWLINE;

device_card 
   : DEVICE {driver.add_device($1); } list NEWLINE;

list
  : item 
  | list item 
  ;

item
  : WORD    { driver.add_word( $1 ); }
  | NEWLINE { driver.add_newline(); }
  | ASSIGN  { driver.add_assign(); }
  | COMMENT { driver.add_comment(); }
  | value
  ;

value 
  : VALUE             {driver.add_value($1); }
  | VALUE FACTOR      {driver.add_value($1, $2); }
  | VALUE FACTOR UNIT  {driver.add_value($1,$2, $3); }
  ;

%%


void 
MC::MC_Parser::error( const location_type &l, const std::string &err_message )
{
   std::cerr << "Error: " << err_message << " at " << l << "\n";
}
