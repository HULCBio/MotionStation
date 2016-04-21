/*

Copyright (C) 2010-2012 VZLU Prague

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

#if !defined (octave_binmap_h)
#define octave_binmap_h 1

#include "Array.h"
#include "Sparse.h"
#include "Array-util.h"

#include "bsxfun.h"

// This source file implements a general binary maping function for
// arrays. The syntax is binmap<type> (a, b, f, [name]). type denotes
// the expected return type of the operation. a, b, should be one of
// the 6 combinations:
//
// Array-Array
// Array-scalar
// scalar-Array
// Sparse-Sparse
// Sparse-scalar
// scalar-Sparse
//
// If both operands are nonscalar, name must be supplied. It is used
// as the base for error message when operands are nonconforming.
//
// The operation needs not be homogeneous, i.e. a, b and the result
// may be of distinct types. f can have any of the four signatures:
//
// U f (T, R)
// U f (const T&, R)
// U f (T, const R&)
// U f (const T&, const R&)
//
// Additionally, f can be an arbitrary functor object.
//
// octave_quit() is called at appropriate places, hence the operation
// is breakable.

// The following template wrappers are provided for automatic bsxfun
// calls (see the function signature for do_bsxfun_op).

template<typename R, typename X, typename Y, typename F>
class bsxfun_wrapper
{
private:
  static F f;

public:
  static void
  set_f (const F& f_in)
  {
    f = f_in;
  }

  static void
  op_mm (size_t n, R* r, const X* x , const Y* y)
  {
    for (size_t i = 0; i < n; i++)
      r[i] = f (x[i], y[i]);
  }

  static void
  op_sm (size_t n, R* r, X x, const Y* y)
  {
    for (size_t i = 0; i < n; i++)
      r[i] = f (x, y[i]);
  }

  static void
  op_ms (size_t n , R* r, const X* x, Y y)
  {
    for (size_t i = 0; i < n; i++)
      r[i] = f (x[i], y);
  }
};

// Static init
template<typename R, typename X, typename Y, typename F>
F bsxfun_wrapper<R, X, Y, F>::f;


// scalar-Array
template <class U, class T, class R, class F>
Array<U>
binmap (const T& x, const Array<R>& ya, F fcn)
{
  octave_idx_type len = ya.numel ();

  const R *y = ya.data ();

  Array<U> result (ya.dims ());
  U *p = result.fortran_vec ();

  octave_idx_type i;
  for (i = 0; i < len - 3; i += 4)
    {
      octave_quit ();

      p[i] = fcn (x, y[i]);
      p[i+1] = fcn (x, y[i+1]);
      p[i+2] = fcn (x, y[i+2]);
      p[i+3] = fcn (x, y[i+3]);
    }

  octave_quit ();

  for (; i < len; i++)
    p[i] = fcn (x, y[i]);

  return result;
}

// Array-scalar
template <class U, class T, class R, class F>
Array<U>
binmap (const Array<T>& xa, const R& y, F fcn)
{
  octave_idx_type len = xa.numel ();

  const R *x = xa.data ();

  Array<U> result (xa.dims ());
  U *p = result.fortran_vec ();

  octave_idx_type i;
  for (i = 0; i < len - 3; i += 4)
    {
      octave_quit ();

      p[i] = fcn (x[i], y);
      p[i+1] = fcn (x[i+1], y);
      p[i+2] = fcn (x[i+2], y);
      p[i+3] = fcn (x[i+3], y);
    }

  octave_quit ();

  for (; i < len; i++)
    p[i] = fcn (x[i], y);

  return result;
}

// Array-Array (treats singletons as scalars)
template <class U, class T, class R, class F>
Array<U>
binmap (const Array<T>& xa, const Array<R>& ya, F fcn, const char *name)
{
  dim_vector xad = xa.dims (), yad = ya.dims ();
  if (xa.numel () == 1)
    return binmap<U, T, R, F> (xa(0), ya, fcn);
  else if (ya.numel () == 1)
    return binmap<U, T, R, F> (xa, ya(0), fcn);
  else if (xad != yad)
    {
      if (is_valid_bsxfun (name, xad, yad))
        {
          bsxfun_wrapper<U, T, R, F>::set_f(fcn);
          return do_bsxfun_op (xa, ya,
                               bsxfun_wrapper<U, T, R, F>::op_mm,
                               bsxfun_wrapper<U, T, R, F>::op_sm,
                               bsxfun_wrapper<U, T, R, F>::op_ms);
        }
      else
        gripe_nonconformant (name, xad, yad);
    }

  octave_idx_type len = xa.numel ();

  const T *x = xa.data ();
  const T *y = ya.data ();

  Array<U> result (xa.dims ());
  U *p = result.fortran_vec ();

  octave_idx_type i;
  for (i = 0; i < len - 3; i += 4)
    {
      octave_quit ();

      p[i] = fcn (x[i], y[i]);
      p[i+1] = fcn (x[i+1], y[i+1]);
      p[i+2] = fcn (x[i+2], y[i+2]);
      p[i+3] = fcn (x[i+3], y[i+3]);
    }

  octave_quit ();

  for (; i < len; i++)
    p[i] = fcn (x[i], y[i]);

  return result;
}

// scalar-Sparse
template <class U, class T, class R, class F>
Sparse<U>
binmap (const T& x, const Sparse<R>& ys, F fcn)
{
  octave_idx_type nz = ys.nnz ();
  Sparse<U> retval (ys.rows (), ys.cols (), nz);
  for (octave_idx_type i = 0; i < nz; i++)
    {
      octave_quit ();
      retval.xdata(i) = fcn (x, ys.data(i));
    }

  octave_quit ();
  retval.maybe_compress ();
  return retval;
}

// Sparse-scalar
template <class U, class T, class R, class F>
Sparse<U>
binmap (const Sparse<T>& xs, const R& y, F fcn)
{
  octave_idx_type nz = xs.nnz ();
  Sparse<U> retval (xs.rows (), xs.cols (), nz);
  for (octave_idx_type i = 0; i < nz; i++)
    {
      octave_quit ();
      retval.xdata(i) = fcn (xs.data(i), y);
    }

  octave_quit ();
  retval.maybe_compress ();
  return retval;
}

// Sparse-Sparse (treats singletons as scalars)
template <class U, class T, class R, class F>
Sparse<U>
binmap (const Sparse<T>& xs, const Sparse<R>& ys, F fcn, const char *name)
{
  if (xs.rows () == 1 && xs.cols () == 1)
    return binmap<U, T, R, F> (xs(0,0), ys, fcn);
  else if (ys.rows () == 1 && ys.cols () == 1)
    return binmap<U, T, R, F> (xs, ys(0,0), fcn);
  else if (xs.dims () != ys.dims ())
    gripe_nonconformant (name, xs.dims (), ys.dims ());

  T xzero = T ();
  R yzero = R ();

  U fz = fcn (xzero, yzero);
  if (fz == U())
    {
      // Sparsity-preserving function. Do it efficiently.
      octave_idx_type nr = xs.rows (), nc = xs.cols ();
      Sparse<T> retval (nr, nc);

      octave_idx_type nz = 0;
      // Count nonzeros.
      for (octave_idx_type j = 0; j < nc; j++)
        {
          octave_quit ();
          octave_idx_type ix = xs.cidx(j), iy = ys.cidx(j);
          octave_idx_type ux = xs.cidx(j+1), uy = ys.cidx(j+1);
          while (ix != ux || iy != uy)
            {
              octave_idx_type rx = xs.ridx(ix), ry = ys.ridx(ix);
              ix += rx <= ry;
              iy += ry <= rx;
              nz++;
            }

          retval.xcidx(j+1) = nz;
        }

      // Allocate space.
      retval.change_capacity (retval.xcidx(nc));

      // Fill.
      nz = 0;
      for (octave_idx_type j = 0; j < nc; j++)
        {
          octave_quit ();
          octave_idx_type ix = xs.cidx(j), iy = ys.cidx(j);
          octave_idx_type ux = xs.cidx(j+1), uy = ys.cidx(j+1);
          while (ix != ux || iy != uy)
            {
              octave_idx_type rx = xs.ridx(ix), ry = ys.ridx(ix);
              if (rx == ry)
                {
                  retval.xridx(nz) = rx;
                  retval.xdata(nz) = fcn (xs.data(ix), ys.data(iy));
                  ix++;
                  iy++;
                }
              else if (rx < ry)
                {
                  retval.xridx(nz) = rx;
                  retval.xdata(nz) = fcn (xs.data(ix), yzero);
                  ix++;
                }
              else if (ry < rx)
                {
                  retval.xridx(nz) = ry;
                  retval.xdata(nz) = fcn (xzero, ys.data(iy));
                  iy++;
                }

              nz++;
            }
        }

      retval.maybe_compress ();
      return retval;
    }
  else
    return Sparse<U> (binmap<U, T, R, F> (xs.array_value (), ys.array_value (),
                                          fcn, name));
}

// Overloads for function pointers.

// Signature (T, R)

template <class U, class T, class R>
inline Array<U>
binmap (const Array<T>& xa, const Array<R>& ya, U (*fcn) (T, R), const char *name)
{ return binmap<U, T, R, U (*) (T, R)> (xa, ya, fcn, name); }

template <class U, class T, class R>
inline Array<U>
binmap (const T& x, const Array<R>& ya, U (*fcn) (T, R))
{ return binmap<U, T, R, U (*) (T, R)> (x, ya, fcn); }

template <class U, class T, class R>
inline Array<U>
binmap (const Array<T>& xa, const R& y, U (*fcn) (T, R))
{ return binmap<U, T, R, U (*) (T, R)> (xa, y, fcn); }

template <class U, class T, class R>
inline Sparse<U>
binmap (const Sparse<T>& xa, const Sparse<R>& ya, U (*fcn) (T, R), const char *name)
{ return binmap<U, T, R, U (*) (T, R)> (xa, ya, fcn, name); }

template <class U, class T, class R>
inline Sparse<U>
binmap (const T& x, const Sparse<R>& ya, U (*fcn) (T, R))
{ return binmap<U, T, R, U (*) (T, R)> (x, ya, fcn); }

template <class U, class T, class R>
inline Sparse<U>
binmap (const Sparse<T>& xa, const R& y, U (*fcn) (T, R))
{ return binmap<U, T, R, U (*) (T, R)> (xa, y, fcn); }

// Signature (const T&, const R&)

template <class U, class T, class R>
inline Array<U>
binmap (const Array<T>& xa, const Array<R>& ya, U (*fcn) (const T&, const R&), const char *name)
{ return binmap<U, T, R, U (*) (const T&, const R&)> (xa, ya, fcn, name); }

template <class U, class T, class R>
inline Array<U>
binmap (const T& x, const Array<R>& ya, U (*fcn) (const T&, const R&))
{ return binmap<U, T, R, U (*) (const T&, const R&)> (x, ya, fcn); }

template <class U, class T, class R>
inline Array<U>
binmap (const Array<T>& xa, const R& y, U (*fcn) (const T&, const R&))
{ return binmap<U, T, R, U (*) (const T&, const R&)> (xa, y, fcn); }

template <class U, class T, class R>
inline Sparse<U>
binmap (const Sparse<T>& xa, const Sparse<R>& ya, U (*fcn) (const T&, const R&), const char *name)
{ return binmap<U, T, R, U (*) (const T&, const R&)> (xa, ya, fcn, name); }

template <class U, class T, class R>
inline Sparse<U>
binmap (const T& x, const Sparse<R>& ya, U (*fcn) (const T&, const R&))
{ return binmap<U, T, R, U (*) (const T&, const R&)> (x, ya, fcn); }

template <class U, class T, class R>
inline Sparse<U>
binmap (const Sparse<T>& xa, const R& y, U (*fcn) (const T&, const R&))
{ return binmap<U, T, R, U (*) (const T&, const R&)> (xa, y, fcn); }

// Signature (const T&, R)

template <class U, class T, class R>
inline Array<U>
binmap (const Array<T>& xa, const Array<R>& ya, U (*fcn) (const T&, R), const char *name)
{ return binmap<U, T, R, U (*) (const T&, R)> (xa, ya, fcn, name); }

template <class U, class T, class R>
inline Array<U>
binmap (const T& x, const Array<R>& ya, U (*fcn) (const T&, R))
{ return binmap<U, T, R, U (*) (const T&, R)> (x, ya, fcn); }

template <class U, class T, class R>
inline Array<U>
binmap (const Array<T>& xa, const R& y, U (*fcn) (const T&, R))
{ return binmap<U, T, R, U (*) (const T&, R)> (xa, y, fcn); }

template <class U, class T, class R>
inline Sparse<U>
binmap (const Sparse<T>& xa, const Sparse<R>& ya, U (*fcn) (const T&, R), const char *name)
{ return binmap<U, T, R, U (*) (const T&, R)> (xa, ya, fcn, name); }

template <class U, class T, class R>
inline Sparse<U>
binmap (const T& x, const Sparse<R>& ya, U (*fcn) (const T&, R))
{ return binmap<U, T, R, U (*) (const T&, R)> (x, ya, fcn); }

template <class U, class T, class R>
inline Sparse<U>
binmap (const Sparse<T>& xa, const R& y, U (*fcn) (const T&, R))
{ return binmap<U, T, R, U (*) (const T&, R)> (xa, y, fcn); }

// Signature (T, const R&)

template <class U, class T, class R>
inline Array<U>
binmap (const Array<T>& xa, const Array<R>& ya, U (*fcn) (T, const R&), const char *name)
{ return binmap<U, T, R, U (*) (T, const R&)> (xa, ya, fcn, name); }

template <class U, class T, class R>
inline Array<U>
binmap (const T& x, const Array<R>& ya, U (*fcn) (T, const R&))
{ return binmap<U, T, R, U (*) (T, const R&)> (x, ya, fcn); }

template <class U, class T, class R>
inline Array<U>
binmap (const Array<T>& xa, const R& y, U (*fcn) (T, const R&))
{ return binmap<U, T, R, U (*) (T, const R&)> (xa, y, fcn); }

template <class U, class T, class R>
inline Sparse<U>
binmap (const Sparse<T>& xa, const Sparse<R>& ya, U (*fcn) (T, const R&), const char *name)
{ return binmap<U, T, R, U (*) (T, const R&)> (xa, ya, fcn, name); }

template <class U, class T, class R>
inline Sparse<U>
binmap (const T& x, const Sparse<R>& ya, U (*fcn) (T, const R&))
{ return binmap<U, T, R, U (*) (T, const R&)> (x, ya, fcn); }

template <class U, class T, class R>
inline Sparse<U>
binmap (const Sparse<T>& xa, const R& y, U (*fcn) (T, const R&))
{ return binmap<U, T, R, U (*) (T, const R&)> (xa, y, fcn); }

#endif
