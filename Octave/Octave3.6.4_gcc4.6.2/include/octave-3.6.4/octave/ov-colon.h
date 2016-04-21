/*

Copyright (C) 1996-2012 John W. Eaton

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

#if !defined (octave_magic_colon_h)
#define octave_magic_colon_h 1

#include <cstdlib>

#include <iosfwd>
#include <string>

#include "mx-base.h"
#include "str-vec.h"

#include "error.h"
#include "ov-base.h"
#include "ov-typeinfo.h"

class octave_value_list;

class tree_walker;

// A type to represent ':' as used for indexing.

class
octave_magic_colon : public octave_base_value
{
public:

  octave_magic_colon (void)
    : octave_base_value () { }

  octave_magic_colon (const octave_magic_colon&)
    : octave_base_value () { }

  ~octave_magic_colon (void) { }

  octave_base_value *clone (void) const { return new octave_magic_colon (*this); }
  octave_base_value *empty_clone (void) const { return new octave_magic_colon (); }

  idx_vector index_vector (void) const { return idx_vector (':'); }

  bool is_defined (void) const { return true; }

  bool is_constant (void) const { return true; }

  bool is_magic_colon (void) const { return true; }

  void print (std::ostream& os, bool pr_as_read_syntax = false) const;

  void print_raw (std::ostream& os, bool pr_as_read_syntax = false) const;

private:

  DECLARE_OV_TYPEID_FUNCTIONS_AND_DATA
};

#endif
