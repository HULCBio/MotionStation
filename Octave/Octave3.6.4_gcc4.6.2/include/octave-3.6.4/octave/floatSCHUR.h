/*

Copyright (C) 1994-2012 John W. Eaton

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

#if !defined (octave_FloatSCHUR_h)
#define octave_FloatSCHUR_h 1

#include <iosfwd>
#include <string>

#include "fMatrix.h"

class
OCTAVE_API
FloatSCHUR
{
public:

  FloatSCHUR (void) : schur_mat (), unitary_mat (), selector (0) { }

  FloatSCHUR (const FloatMatrix& a, const std::string& ord,
              bool calc_unitary = true)
    : schur_mat (), unitary_mat (), selector (0)
    {
      init (a, ord, calc_unitary);
    }

  FloatSCHUR (const FloatMatrix& a, const std::string& ord, int& info,
              bool calc_unitary = true)
    : schur_mat (), unitary_mat (), selector (0)
    {
      info = init (a, ord, calc_unitary);
    }

  FloatSCHUR (const FloatSCHUR& a)
    : schur_mat (a.schur_mat), unitary_mat (a.unitary_mat), selector (0)
    { }

  FloatSCHUR (const FloatMatrix& s, const FloatMatrix& u);

  FloatSCHUR& operator = (const FloatSCHUR& a)
    {
      if (this != &a)
        {
          schur_mat = a.schur_mat;
          unitary_mat = a.unitary_mat;
        }
      return *this;
    }

  ~FloatSCHUR (void) { }

  FloatMatrix schur_matrix (void) const { return schur_mat; }

  FloatMatrix unitary_matrix (void) const { return unitary_mat; }

  friend std::ostream& operator << (std::ostream& os, const FloatSCHUR& a);

  typedef octave_idx_type (*select_function) (const float&, const float&);

private:

  FloatMatrix schur_mat;
  FloatMatrix unitary_mat;

  select_function selector;

  octave_idx_type init (const FloatMatrix& a, const std::string& ord, bool calc_unitary);
};

#endif
