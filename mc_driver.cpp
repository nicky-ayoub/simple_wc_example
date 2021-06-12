#include <cctype>
#include <fstream>
#include <cassert>
#include <algorithm>

#include "mc_driver.hpp"

MC::MC_Driver::~MC_Driver()
{
   delete(scanner);
   scanner = nullptr;
   delete(parser);
   parser = nullptr;
}

void 
MC::MC_Driver::parse( const char * const filename )
{
   assert( filename != nullptr );
   std::ifstream in_file( filename );
   if( ! in_file.good() )
   {
       exit( EXIT_FAILURE );
   }
   parse_helper( in_file );
   return;
}

void
MC::MC_Driver::parse( std::istream &stream )
{
   if( ! stream.good()  && stream.eof() )
   {
       return;
   }
   //else
   parse_helper( stream ); 
   return;
}


void 
MC::MC_Driver::parse_helper( std::istream &stream )
{
   
   delete(scanner);
   try
   {
      scanner = new MC::MC_Scanner( &stream );
   }
   catch( std::bad_alloc &ba )
   {
      std::cerr << "Failed to allocate scanner: (" <<
         ba.what() << "), exiting!!\n";
      exit( EXIT_FAILURE );
   }
   
   delete(parser); 
   try
   {
      parser = new MC::MC_Parser( (*scanner) /* scanner */, 
                                  (*this) /* driver */ );
   }
   catch( std::bad_alloc &ba )
   {
      std::cerr << "Failed to allocate parser: (" << 
         ba.what() << "), exiting!!\n";
      exit( EXIT_FAILURE );
   }
   const int accept( 0 );
   if( parser->parse() != accept )
   {
      std::cerr << "Parse failed!!\n";
   }
   return;
}

void 
MC::MC_Driver::add_assign()
{ 
   assigns++; 
}

void 
MC::MC_Driver::add_comment()
{ 
   comments++;  // Counting comment chars/words is ignored
   lines++; 
}

void 
MC::MC_Driver::add_title( const std::string &first )
{
   title = first;
   lines++; 
}

void 
MC::MC_Driver::add_word( const std::string &word )
{
   words++; 
}

void 
MC::MC_Driver::add_command( const std::string &command )
{
   commands++; 
}

void 
MC::MC_Driver::add_device( const std::string &device )
{
   devices++; 
}

bool iequals(const std::string& a, const std::string& b)
{
    return std::equal(a.begin(), a.end(),
                      b.begin(), b.end(),
                      [](char a, char b) {
                          return tolower(a) == tolower(b);
                      });
}

double factorMultiple (const std::string &factor) {
   if (iequals(factor, "meg")) return 1E6;
   if (iequals(factor, "mil")) return 2.54E-5;
   if (iequals(factor, "t")) return 1E12;
   if (iequals(factor, "g")) return 1E9;
   if (iequals(factor, "x")) return 1E6;
   if (iequals(factor, "k")) return 1E3;
   if (iequals(factor, "m")) return 1E-3;
   if (iequals(factor, "u")) return 1E-6;
   if (iequals(factor, "n")) return 1E-9;
   if (iequals(factor, "p")) return 1E-12;
   if (iequals(factor, "f")) return 1E-15;
   if (iequals(factor, "a")) return 1E-18;

   return 1;
}

double string2value (const std::string &str) {
               // Let's see if we can use c++17 to convert string to double:
               double value = 0.0;
               auto [p, ec] = std::from_chars(str.data(), str.data() + str.size(), value);
                if (ec != std::errc()) {
                        std::cout << "Couldn't convert value for " << str;
               }
               return value;
}

void 
MC::MC_Driver::add_value( const std::string &value )
{
   values++; 
   double v = string2value(value);
   std::cout << "Value converted to " << v << std::endl;
}

void 
MC::MC_Driver::add_value( const std::string &value, const std::string &factor )
{
   values++; 
   double v = string2value(value) * factorMultiple(factor);
   std::cout << "Value converted to " << v << std::endl;
}

void 
MC::MC_Driver::add_value( const std::string &value , const std::string &factor, const std::string &unit)
{
   values++;
   double v = string2value(value) * factorMultiple(factor);
   std::cout << "Value converted to " << v << " with units " << unit <<  std::endl;
}

void 
MC::MC_Driver::add_newline()
{ 
   lines++; 
}


std::ostream& 
MC::MC_Driver::print( std::ostream &stream )
{
   stream << red  << "Results: " << norm << "\n";
   stream << yellow << "Title: " << norm << title << "\n";
   stream << blue << "Lines: " << norm << lines << "\n";
   stream << blue << "Words: " << norm << words << "\n";
   stream << blue << "Commands: " << norm << commands << "\n";
   stream << blue << "Devices: " << norm << devices << "\n";
   stream << blue << "Values: " << norm << values << "\n";
   stream << blue << "Assigns: " << norm << assigns << "\n";
   return(stream);
}
