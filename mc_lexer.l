%{
/* C++ string header, for string ops below */
#include <string>
#include <iostream>

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


%x Spice

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
Unit        [VvHhFf]
ScaleFact   ([fFpPnNuUmMkKgG]|"MEG"|"meg"|"MI"|"mi")
DQstring    ".*"
SQstring    '.*'
EQ          =

%%
%{          /** Code executed at the beginning of yylex **/
            yylval = lval;
%}


    /* Title line is grabbed then we go into Spice mode */
^.*\n        { 
               BEGIN Spice;    
               yylval->build< std::string >( yytext );
               loc->lines();  
               return (token::TITLE);
            }

<Spice>^\*.+$     {
               loc->lines();
               std::cout << "Comment : " << yytext << std::endl; 
               return( token::COMMENT );
            }

<Spice>{Val}{ScaleFact}?{Unit}?      {
               /**
                * Section 10.1.5.1 of the 3.0.2 Bison Manual says the 
                * following should work:
                * yylval.build( yytext );
                * but it doesn't.
                * ref: http://goo.gl/KLn0w2
                */
               yylval->build< std::string >( yytext );
               std::cout << "Value : " << yytext << std::endl;
               return( token::VALUE );
            }

<Spice>^\.{AlphaNumU}+   {
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
<Spice>^[cCrRlLxXmMjJqQiIvVtT]{AlphaNumU}+   {
               /**
                * Section 10.1.5.1 of the 3.0.2 Bison Manual says the 
                * following should work:
                * yylval.build( yytext );
                * but it doesn't.
                * ref: http://goo.gl/KLn0w2
                */
               yylval->build< std::string >( yytext );
               std::cout << "Device : " << yytext << std::endl;
               return( token::DEVICE );
            }


<Spice>{DQstring}   {
               /**
                * Section 10.1.5.1 of the 3.0.2 Bison Manual says the 
                * following should work:
                * yylval.build( yytext );
                * but it doesn't.
                * ref: http://goo.gl/KLn0w2
                */
               yylval->build< std::string >( yytext );
               std::cout << "Double quoted String : " << yytext << std::endl;
               return( token::WORD );

}

<Spice>{SQstring}   {
               /**
                * Section 10.1.5.1 of the 3.0.2 Bison Manual says the 
                * following should work:
                * yylval.build( yytext );
                * but it doesn't.
                * ref: http://goo.gl/KLn0w2
                */
               yylval->build< std::string >( yytext );
               std::cout << "Single quoted String : " << yytext << std::endl;
               return( token::WORD );

}

<Spice>{AlphaNumSym}+   {
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
<Spice>{EQ}        {
               std::cout << "Assignment : " << yytext << std::endl;
               return ( token::ASSIGN);
            }

<Spice>\n          {
               // Update line number
               loc->lines();
               std::cout << std::endl;
               return( token::NEWLINE );
            }

<Spice>[\r\t\b ]       {
            }

<Spice>.   {
               std::cout << "ERROR " << yytext <<  std::endl;
}
%%


