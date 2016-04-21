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

#if !defined (octave_FloatComplexLU_h)
#define octave_FloatComplexLU_h 1

#include "base-lu.h"
#include "dMatrix.h"
#include "fCMatrix.h"

class
OCTAVE_API
FloatComplexLU : public base_lu <FloatComplexMatrix>
{
public:

  FloatComplexLU (void)
    : base_lu <FloatComplexMatrix> () { }

  FloatComplexLU (const FloatComplexMatrix& a);

  FloatComplexLU (const FloatComplexLU& a)
    : base_lu <FloatComplexMatrix> (a) { }

  FloatComplexLU (const FloatComplexMatrix& l, const FloatComplexMatrix& u,
                  const PermMatrix& p)
    : base_lu <FloatComplexMatrix> (l, u, p) { }

  FloatComplexLU& operator = (const FloatComplexLU& a)
    {
      if (this != &a)
        base_lu <FloatComplexMatrix> :: operator = (a);

      return *this;
    }

  ~FloatComplexLU (void) { }

  void update (const FloatComplexColumnVector& u, const FloatComplexColumnVector& v);

  void update (const FloatComplexMatrix& u, const FloatComplexMatrix& v);

  void update_piv (const FloatComplexColumnVector& u, const FloatComplexColumnVector& v);

  void update_piv (const FloatComplexMatrix& u, const FloatComplexMatrix& v);
};

#endif
