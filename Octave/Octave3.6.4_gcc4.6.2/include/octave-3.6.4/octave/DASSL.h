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

#if !defined (octave_DASSL_h)
#define octave_DASSL_h 1

#include <cfloat>

#include "DASSL-opts.h"
#include "lo-math.h"

class
OCTAVE_API
DASSL : public DAE, public DASSL_options
{
public:

  DASSL (void)
    : DAE (), DASSL_options (), initialized (false), liw (0), lrw (0),
      info (), iwork (), rwork (), abs_tol (), rel_tol () { }

  DASSL (const ColumnVector& s, double tm, DAEFunc& f)
    : DAE (s, tm, f), DASSL_options (), initialized (false), liw (0),
      lrw (0), info (), iwork (), rwork (), abs_tol (), rel_tol () { }

  DASSL (const ColumnVector& s, const ColumnVector& deriv,
         double tm, DAEFunc& f)
    : DAE (s, deriv, tm, f), DASSL_options (), initialized (false),
      liw (0), lrw (0), info (), iwork (), rwork (), abs_tol (),
      rel_tol () { }

  ~DASSL (void) { }

  ColumnVector do_integrate (double t);

  Matrix do_integrate (const ColumnVector& tout);

  Matrix do_integrate (const ColumnVector& tout, const ColumnVector& tcrit);

  Matrix integrate (const ColumnVector& tout, Matrix& xdot_out);

  Matrix integrate (const ColumnVector& tout, Matrix& xdot_out,
                    const ColumnVector& tcrit);

  std::string error_message (void) const;

private:

  bool initialized;

  octave_idx_type liw;
  octave_idx_type lrw;

  Array<octave_idx_type> info;
  Array<octave_idx_type> iwork;

  Array<double> rwork;

  Array<double> abs_tol;
  Array<double> rel_tol;
};

#endif
