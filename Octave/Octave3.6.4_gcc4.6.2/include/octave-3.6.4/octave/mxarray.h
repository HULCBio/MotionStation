/*

Copyright (C) 2001-2012 Paul Kienzle

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

/*

Part of this code was originally distributed as part of Octave Forge under
the following terms:

Author: Paul Kienzle
I grant this code to the public domain.
2001-03-22

THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
SUCH DAMAGE.

*/

#if ! defined (MXARRAY_H)
#define MXARRAY_H

typedef enum
  {
    mxREAL = 0,
    mxCOMPLEX = 1
  }
  mxComplexity;

typedef enum
  {
    mxUNKNOWN_CLASS = 0,
    mxCELL_CLASS,
    mxSTRUCT_CLASS,
    mxLOGICAL_CLASS,
    mxCHAR_CLASS,
    mxUNUSED_CLASS,
    mxDOUBLE_CLASS,
    mxSINGLE_CLASS,
    mxINT8_CLASS,
    mxUINT8_CLASS,
    mxINT16_CLASS,
    mxUINT16_CLASS,
    mxINT32_CLASS,
    mxUINT32_CLASS,
    mxINT64_CLASS,
    mxUINT64_CLASS,
    mxFUNCTION_CLASS
  }
  mxClassID;

typedef unsigned char mxLogical;

/* typedef Uint16 mxChar; */
typedef char mxChar;

/*
 * FIXME? Mathworks says these should be size_t on 64-bit system and when
 * mex is used with the -largearraydims flag, but why do that? Its better
 * to conform to the same indexing as the rest of Octave
 */
typedef int mwSize;
typedef int mwIndex;

#if ! defined (MXARRAY_TYPEDEFS_ONLY)

#include <cstring>

class octave_value;

#define DO_MUTABLE_METHOD(RET_T, METHOD_CALL) \
  RET_T retval = rep->METHOD_CALL; \
 \
  if (rep->mutation_needed ()) \
    { \
      maybe_mutate (); \
      retval = rep->METHOD_CALL; \
    } \
 \
  return retval

#define DO_VOID_MUTABLE_METHOD(METHOD_CALL) \
  rep->METHOD_CALL; \
 \
  if (rep->mutation_needed ()) \
    { \
      maybe_mutate (); \
      rep->METHOD_CALL; \
    }

// This just provides a way to avoid infinite recursion when building
// mxArray objects.

struct
xmxArray
{
  xmxArray (void) { }
};

// The main interface class.  The representation can be based on an
// octave_value object or a separate object that tries to reproduce
// the semantics of mxArray objects in Matlab more directly.

class mxArray
{
public:

  mxArray (const octave_value& ov);

  mxArray (mxClassID id, mwSize ndims, const mwSize *dims,
           mxComplexity flag = mxREAL);

  mxArray (mxClassID id, const dim_vector& dv, mxComplexity flag = mxREAL);

  mxArray (mxClassID id, mwSize m, mwSize n, mxComplexity flag = mxREAL);

  mxArray (mxClassID id, double val);

  mxArray (mxClassID id, mxLogical val);

  mxArray (const char *str);

  mxArray (mwSize m, const char **str);

  mxArray (mxClassID id, mwSize m, mwSize n, mwSize nzmax,
           mxComplexity flag = mxREAL);

  mxArray (mwSize ndims, const mwSize *dims, int num_keys, const char **keys);

  mxArray (const dim_vector& dv, int num_keys, const char **keys);

  mxArray (mwSize m, mwSize n, int num_keys, const char **keys);

  mxArray (mwSize ndims, const mwSize *dims);

  mxArray (const dim_vector& dv);

  mxArray (mwSize m, mwSize n);

  virtual mxArray *dup (void) const
  {
    mxArray *new_rep = rep->dup ();

    return new mxArray (new_rep, name);
  }

  virtual ~mxArray (void);

  virtual bool is_octave_value (void) const { return rep->is_octave_value (); }

  virtual int is_cell (void) const { return rep->is_cell (); }

  virtual int is_char (void) const { return rep->is_char (); }

  virtual int is_class (const char *name_arg) const { return rep->is_class (name_arg); }

  virtual int is_complex (void) const { return rep->is_complex (); }

  virtual int is_double (void) const { return rep->is_double (); }

  virtual int is_function_handle (void) const { return rep->is_function_handle (); }

  virtual int is_int16 (void) const { return rep->is_int16 (); }

  virtual int is_int32 (void) const { return rep->is_int32 (); }

  virtual int is_int64 (void) const { return rep->is_int64 (); }

  virtual int is_int8 (void) const { return rep->is_int8 (); }

  virtual int is_logical (void) const { return rep->is_logical (); }

  virtual int is_numeric (void) const { return rep->is_numeric (); }

  virtual int is_single (void) const { return rep->is_single (); }

  virtual int is_sparse (void) const { return rep->is_sparse (); }

  virtual int is_struct (void) const { return rep->is_struct (); }

  virtual int is_uint16 (void) const { return rep->is_uint16 (); }

  virtual int is_uint32 (void) const { return rep->is_uint32 (); }

  virtual int is_uint64 (void) const { return rep->is_uint64 (); }

  virtual int is_uint8 (void) const { return rep->is_uint8 (); }

  virtual int is_logical_scalar (void) const { return rep->is_logical_scalar (); }

  virtual int is_logical_scalar_true (void) const { return rep->is_logical_scalar_true (); }

  virtual mwSize get_m (void) const { return rep->get_m (); }

  virtual mwSize get_n (void) const { return rep->get_n (); }

  virtual mwSize *get_dimensions (void) const { return rep->get_dimensions (); }

  virtual mwSize get_number_of_dimensions (void) const { return rep->get_number_of_dimensions (); }

  virtual void set_m (mwSize m) { DO_VOID_MUTABLE_METHOD (set_m (m)); }

  virtual void set_n (mwSize n) { DO_VOID_MUTABLE_METHOD (set_n (n)); }

  virtual void set_dimensions (mwSize *dims_arg, mwSize ndims_arg) { DO_VOID_MUTABLE_METHOD (set_dimensions (dims_arg, ndims_arg)); }

  virtual mwSize get_number_of_elements (void) const { return rep->get_number_of_elements (); }

  virtual int is_empty (void) const { return get_number_of_elements () == 0; }

  const char *get_name (void) const { return name; }

  void set_name (const char *name_arg);

  virtual mxClassID get_class_id (void) const { return rep->get_class_id (); }

  virtual const char *get_class_name (void) const { return rep->get_class_name (); }

  virtual void set_class_name (const char *name_arg) { DO_VOID_MUTABLE_METHOD (set_class_name (name_arg)); }

  virtual mxArray *get_cell (mwIndex idx) const { DO_MUTABLE_METHOD (mxArray *, get_cell (idx)); }

  virtual void set_cell (mwIndex idx, mxArray *val) { DO_VOID_MUTABLE_METHOD (set_cell (idx, val)); }

  virtual double get_scalar (void) const { return rep->get_scalar (); }

  virtual void *get_data (void) const { DO_MUTABLE_METHOD (void *, get_data ()); }

  virtual void *get_imag_data (void) const { DO_MUTABLE_METHOD (void *, get_imag_data ()); }

  virtual void set_data (void *pr) { DO_VOID_MUTABLE_METHOD (set_data (pr)); }

  virtual void set_imag_data (void *pi) { DO_VOID_MUTABLE_METHOD (set_imag_data (pi)); }

  virtual mwIndex *get_ir (void) const { DO_MUTABLE_METHOD (mwIndex *, get_ir ()); }

  virtual mwIndex *get_jc (void) const { DO_MUTABLE_METHOD (mwIndex *, get_jc ()); }

  virtual mwSize get_nzmax (void) const { return rep->get_nzmax (); }

  virtual void set_ir (mwIndex *ir) { DO_VOID_MUTABLE_METHOD (set_ir (ir)); }

  virtual void set_jc (mwIndex *jc) { DO_VOID_MUTABLE_METHOD (set_jc (jc)); }

  virtual void set_nzmax (mwSize nzmax) { DO_VOID_MUTABLE_METHOD (set_nzmax (nzmax)); }

  virtual int add_field (const char *key) { DO_MUTABLE_METHOD (int, add_field (key)); }

  virtual void remove_field (int key_num) { DO_VOID_MUTABLE_METHOD (remove_field (key_num)); }

  virtual mxArray *get_field_by_number (mwIndex index, int key_num) const { DO_MUTABLE_METHOD (mxArray *, get_field_by_number (index, key_num)); }

  virtual void set_field_by_number (mwIndex index, int key_num, mxArray *val) { DO_VOID_MUTABLE_METHOD (set_field_by_number (index, key_num, val)); }

  virtual int get_number_of_fields (void) const { return rep->get_number_of_fields (); }

  virtual const char *get_field_name_by_number (int key_num) const { DO_MUTABLE_METHOD (const char*, get_field_name_by_number (key_num)); }

  virtual int get_field_number (const char *key) const { DO_MUTABLE_METHOD (int, get_field_number (key)); }

  virtual int get_string (char *buf, mwSize buflen) const { return rep->get_string (buf, buflen); }

  virtual char *array_to_string (void) const { return rep->array_to_string (); }

  virtual mwIndex calc_single_subscript (mwSize nsubs, mwIndex *subs) const { return rep->calc_single_subscript (nsubs, subs); }

  virtual size_t get_element_size (void) const { return rep->get_element_size (); }

  virtual bool mutation_needed (void) const { return rep->mutation_needed (); }

  virtual mxArray *mutate (void) const { return rep->mutate (); }

  static void *malloc (size_t n);

  static void *calloc (size_t n, size_t t);

  static char *strsave (const char *str)
  {
    char *retval = 0;

    if (str)
      {
        mwSize sz =  sizeof (mxChar) * (strlen (str) + 1);
        retval = static_cast<char *> (mxArray::malloc (sz));
        strcpy (retval, str);
      }

    return retval;
  }

  static octave_value as_octave_value (mxArray *ptr);

protected:

  virtual octave_value as_octave_value (void) const;

  mxArray (const xmxArray&) : rep (0), name (0) { }

private:

  mutable mxArray *rep;

  char *name;

  mxArray (mxArray *r, const char *n)
    : rep (r), name (strsave (n)) { }

  void maybe_mutate (void) const;

  // No copying!

  mxArray (const mxArray&);

  mxArray& operator = (const mxArray&);
};

#undef DO_MUTABLE_METHOD
#undef DO_VOID_MUTABLE_METHOD

#endif
#endif
