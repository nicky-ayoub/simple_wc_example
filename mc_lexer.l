%{
/* C++ string header, for string ops below */
#include <string>
#include <iostream>
#include <charconv>

/* Implementation of yyFlexScanner */ 
#include "mc_scanner.hpp"
#undef  YY_DECL
#define YY_DECL int MC::MC_Scanner::yylex( MC::MC_Parser::semantic_type * const lval, MC::MC_Parser::location_type *loc )

/* typedef to make the returns for the tokens shorter */
using token = MC::MC_Parser::token;

/* define yyterminate as this instead of NULL */
#define yyterminate() return( token::END )

/* msvc2010 requires that we exclude this header file. */
#define YY_NO_UNISTD_H

/* update location on matching */
#define YY_USER_ACTION loc->step(); loc->columns(yyleng);

%}

%option debug
%option nodefault
%option yyclass="MC::MC_Scanner"
%option noyywrap
%option c++

Alpha       [a-zA-Z]
AlphaU      [a-zA-Z_]
AlphaNum    [a-zA-Z0-9]
AlphaNumU   [a-zA-Z0-9_]
AlphaNumUD  [a-zA-Z0-9_.]
AlphaNumSym [a-zA-Z0-9_.!@#%^&*+~:;?\]\[]
Digit       [0-9]
DigitU      [0-9_]
Number      ({Digit}+)
Integer     ([+-]?{Number})
Decimal     ([+-]?{Digit}*"."{Number})
Float       (({Integer}|{Decimal})[eE][+-]?{Number})
Val         ({Integer}|{Decimal}|{Float})
EQ          =

%%
%{          /** Code executed at the beginning of yylex **/
            yylval = lval;
%}

^\*.+\n     {
               loc->lines();
               std::cout << "Comment : " << yytext; // newline is captured
               return( token::COMMENT );
            }

{Val}       {
               /**
                * Section 10.1.5.1 of the 3.0.2 Bison Manual says the 
                * following should work:
                * yylval.build( yytext );
                * but it doesn't.
                * ref: http://goo.gl/KLn0w2
                */
               yylval->build< std::string >( yytext );

               // Let's see if we can use c++17 to convert string to double:
               const std::string str = yytext;
               double value = 0.0;
               auto [p, ec] = std::from_chars(str.data(), str.data() + str.size(), value);
                if (ec != std::errc()) {
                        std::cout << "Couldn't convert value for " << str;
               }
               
               std::cout << "Value : " << yytext << '(' << value << ')' << std::endl;
               return( token::VALUE );
            }

^\.{AlphaNumU}+   {
               /**
                * Section 10.1.5.1 of the 3.0.2 Bison Manual says the 
                * following should work:
                * yylval.build( yytext );
                * but it doesn't.
                * ref: http://goo.gl/KLn0w2
                */
               yylval->build< std::string >( yytext );
               std::cout << "Command : " << yytext << std::endl;
               return( token::COMMAND );
            }

{AlphaNumSym}+   {
               /**
                * Section 10.1.5.1 of the 3.0.2 Bison Manual says the 
                * following should work:
                * yylval.build( yytext );
                * but it doesn't.
                * ref: http://goo.gl/KLn0w2
                */
               yylval->build< std::string >( yytext );
               std::cout << "Word : " << yytext << std::endl;
               return( token::WORD );
            }
{EQ}        {
               std::cout << "Assignment : " << yytext << std::endl;
               return ( token::ASSIGN);
            }

\n          {
               // Update line number
               loc->lines();
               return( token::NEWLINE );
            }

.           {
               return( token::CHAR );
            }
%%


