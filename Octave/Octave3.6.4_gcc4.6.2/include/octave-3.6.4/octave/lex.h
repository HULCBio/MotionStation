/*

Copyright (C) 1993-2012 John W. Eaton

This file is part of Octave.

Octave is free software; you can redistribute it and/or modify it
under the terms of the GNU General Public License as published by the
Free Software Foundation; either version 3 of the License, or (at your
option) any later version.

Octave is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
for more details.

You should have received a copy of the GNU General Public License
along with Octave; see the file COPYING.  If not, see
<http://www.gnu.org/licenses/>.

*/

#if !defined (octave_lex_h)
#define octave_lex_h 1

#include <list>
#include <stack>

// FIXME -- these input buffer things should be members of a
// parser input stream class.

typedef struct yy_buffer_state *YY_BUFFER_STATE;

// Associate a buffer with a new file to read.
extern OCTINTERP_API YY_BUFFER_STATE create_buffer (FILE *f);

// Report the current buffer.
extern OCTINTERP_API YY_BUFFER_STATE current_buffer (void);

// Connect to new buffer buffer.
extern OCTINTERP_API void switch_to_buffer (YY_BUFFER_STATE buf);

// Delete a buffer.
extern OCTINTERP_API void delete_buffer (YY_BUFFER_STATE buf);

extern OCTINTERP_API void clear_all_buffers (void);

extern OCTINTERP_API void cleanup_parser (void);

// Is the given string a keyword?
extern bool is_keyword (const std::string& s);

extern void prep_lexer_for_script_file (void);
extern void prep_lexer_for_function_file (void);

// For communication between the lexer and parser.

class
lexical_feedback
{
public:

  lexical_feedback (void)

    : bracketflag (0), braceflag (0), looping (0),
      convert_spaces_to_comma (true), at_beginning_of_statement (true),
      defining_func (0), looking_at_function_handle (0),
      looking_at_anon_fcn_args (true),
      looking_at_return_list (false), looking_at_parameter_list (false),
      looking_at_decl_list (false), looking_at_initializer_expression (false),
      looking_at_matrix_or_assign_lhs (false), looking_at_object_index (),
      looking_for_object_index (false), do_comma_insert (false),
      looking_at_indirect_ref (false), parsed_function_name (),
      parsing_class_method (false), maybe_classdef_get_set_method (false),
      parsing_classdef (false), quote_is_transpose (false),
      pending_local_variables ()

    {
      init ();
    }

  ~lexical_feedback (void) { }

  void init (void);

  // Square bracket level count.
  int bracketflag;

  // Curly brace level count.
  int braceflag;

  // TRUE means we're in the middle of defining a loop.
  int looping;

  // TRUE means that we should convert spaces to a comma inside a
  // matrix definition.
  bool convert_spaces_to_comma;

  // TRUE means we are at the beginning of a statement, where a
  // command name is possible.
  bool at_beginning_of_statement;

  // Nonzero means we're in the middle of defining a function.
  int defining_func;

  // Nonzero means we are parsing a function handle.
  int looking_at_function_handle;

  // TRUE means we are parsing an anonymous function argument list.
  bool looking_at_anon_fcn_args;

  // TRUE means we're parsing the return list for a function.
  bool looking_at_return_list;

  // TRUE means we're parsing the parameter list for a function.
  bool looking_at_parameter_list;

  // TRUE means we're parsing a declaration list (global or
  // persistent).
  bool looking_at_decl_list;

  // TRUE means we are looking at the initializer expression for a
  // parameter list element.
  bool looking_at_initializer_expression;

  // TRUE means we're parsing a matrix or the left hand side of
  // multi-value assignment statement.
  bool looking_at_matrix_or_assign_lhs;

  // If the front of the list is TRUE, the closest paren, brace, or
  // bracket nesting is an index for an object.
  std::list<bool> looking_at_object_index;

  // Object index not possible until we've seen something.
  bool looking_for_object_index;

  // GAG.  Stupid kludge so that [[1,2][3,4]] will work.
  bool do_comma_insert;

  // TRUE means we're looking at an indirect reference to a
  // structure element.
  bool looking_at_indirect_ref;

  // If the top of the stack is TRUE, then we've already seen the name
  // of the current function.  Should only matter if
  // current_function_level > 0
  std::stack<bool> parsed_function_name;

  // TRUE means we are parsing a class method in function or classdef file.
  bool parsing_class_method;

  // TRUE means we are parsing a class method declaration line in a
  // classdef file and can accept a property get or set method name.
  // For example, "get.PropertyName" is recognized as a function name.
  bool maybe_classdef_get_set_method;

  // TRUE means we are parsing a classdef file
  bool parsing_classdef;

  // Return transpose or start a string?
  bool quote_is_transpose;

  // Set of identifiers that might be local variable names.
  std::set<std::string> pending_local_variables;

private:

  lexical_feedback (const lexical_feedback&);

  lexical_feedback& operator = (const lexical_feedback&);
};

class
stream_reader
{
public:
  virtual int getc (void) = 0;
  virtual int ungetc (int c) = 0;

protected:
  stream_reader (void) { }
  ~stream_reader (void) { }

private:

  // No copying!
  stream_reader (const stream_reader&);
  stream_reader& operator = (const stream_reader&);
};

extern std::string
grab_comment_block (stream_reader& reader, bool at_bol, bool& eof);

// TRUE means that we have encountered EOF on the input stream.
extern bool parser_end_of_input;

// Flags that need to be shared between the lexer and parser.
extern lexical_feedback lexer_flags;

#endif
