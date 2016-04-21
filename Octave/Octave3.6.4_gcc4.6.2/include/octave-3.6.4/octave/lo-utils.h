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

#if !defined (octave_liboctave_utils_h)
#define octave_liboctave_utils_h 1

#include <cstdio>

#include <iostream>
#include <string>

#include "lo-cutils.h"
#include "oct-cmplx.h"

extern OCTAVE_API bool xis_int_or_inf_or_nan (double x);
extern OCTAVE_API bool xis_one_or_zero (double x);
extern OCTAVE_API bool xis_zero (double x);
extern OCTAVE_API bool xtoo_large_for_float (double x);

extern OCTAVE_API bool xis_int_or_inf_or_nan (float x);
extern OCTAVE_API bool xis_one_or_zero (float x);
extern OCTAVE_API bool xis_zero (float x);
extern OCTAVE_API bool xtoo_large_for_float (float x);

extern OCTAVE_API char *strsave (const char *);

extern OCTAVE_API void
octave_putenv (const std::string&, const std::string&);

extern OCTAVE_API std::string octave_fgets (std::FILE *);
extern OCTAVE_API std::string octave_fgetl (std::FILE *);

extern OCTAVE_API std::string octave_fgets (std::FILE *, bool& eof);
extern OCTAVE_API std::string octave_fgetl (std::FILE *, bool& eof);

template <typename T>
T
octave_read_value (std::istream& is)
{
  T retval;
  is >> retval;
  return retval;
}

template <> OCTAVE_API double octave_read_value (std::istream& is);
template <> OCTAVE_API Complex octave_read_value (std::istream& is);
template <> OCTAVE_API float octave_read_value (std::istream& is);
template <> OCTAVE_API FloatComplex octave_read_value (std::istream& is);

// The next four functions are provided for backward compatibility.
inline double
octave_read_double (std::istream& is)
{
  return octave_read_value<double> (is);
}

inline Complex
octave_read_complex (std::istream& is)
{
  return octave_read_value<Complex> (is);
}

inline float
octave_read_float (std::istream& is)
{
  return octave_read_value<float> (is);
}

inline FloatComplex
octave_read_float_complex (std::istream& is)
{
  return octave_read_value<FloatComplex> (is);
}

extern OCTAVE_API void
octave_write_double (std::ostream& os, double dval);

extern OCTAVE_API void
octave_write_complex (std::ostream& os, const Complex& cval);

extern OCTAVE_API void
octave_write_float (std::ostream& os, float dval);

extern OCTAVE_API void
octave_write_float_complex (std::ostream& os, const FloatComplex& cval);

#endif
