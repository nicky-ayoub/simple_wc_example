#ifndef __MCDRIVER_HPP__
#define __MCDRIVER_HPP__ 1

#include <string>
#include <cstddef>
#include <istream>
#include <charconv>

#include "mc_scanner.hpp"
#include "mc_parser.tab.hh"

namespace MC{

class MC_Driver{
public:
   MC_Driver() = default;

   virtual ~MC_Driver();
   
   /** 
    * parse - parse from a file
    * @param filename - valid string with input file
    */
   void parse( const char * const filename );
   /** 
    * parse - parse from a c++ input stream
    * @param is - std::istream&, valid input stream
    */
   void parse( std::istream &iss );

   void add_title( const std::string &first );
   void add_command( const std::string &command );
   void add_device( const std::string &device );
   void add_value( const std::string &value );
   void add_value( const std::string &value, const std::string &factor );
   void add_value( const std::string &value, const std::string &factor, const std::string &unit );
   void add_word( const std::string &word );
   void add_assign();
   void add_comment();
   void add_newline();

   std::ostream& print(std::ostream &stream);
private:

   void parse_helper( std::istream &stream );

   std::size_t  words      = 0;
   std::size_t  commands   = 0;
   std::size_t  devices    = 0;
   std::size_t  values     = 0;
   std::size_t  lines      = 0;
   std::size_t  comments   = 0;
   std::size_t  assigns    = 0;
   std::string  title      = "";
   MC::MC_Parser  *parser  = nullptr;
   MC::MC_Scanner *scanner = nullptr;
   
   const std::string red   = "\033[1;31m";
   const std::string blue  = "\033[1;36m";
   const std::string yellow  = "\033[1;33m";
   const std::string norm  = "\033[0m";
};

} /* end namespace MC */
#endif /* END __MCDRIVER_HPP__ */
