// DO NOT EDIT!  Generated automatically by genprops.awk.

/*

Copyright (C) 2007-2012 John W. Eaton

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

#if !defined (graphics_h)
#define graphics_h 1

#ifdef HAVE_CONFIG_H
#include <config.h>
#endif

#include <cctype>

#include <algorithm>
#include <list>
#include <map>
#include <set>
#include <sstream>
#include <string>

#include "caseless-str.h"
#include "lo-ieee.h"

#include "gripes.h"
#include "oct-map.h"
#include "oct-mutex.h"
#include "oct-refcount.h"
#include "ov.h"
#include "txt-eng-ft.h"

// FIXME -- maybe this should be a configure option?
// Matlab defaults to "Helvetica", but that causes problems for many
// gnuplot users.
#if !defined (OCTAVE_DEFAULT_FONTNAME)
#define OCTAVE_DEFAULT_FONTNAME "*"
#endif

// ---------------------------------------------------------------------

class graphics_handle
{
public:
  graphics_handle (void) : val (octave_NaN) { }

  graphics_handle (const octave_value& a);

  graphics_handle (int a) : val (a) { }

  graphics_handle (double a) : val (a) { }

  graphics_handle (const graphics_handle& a) : val (a.val) { }

  graphics_handle& operator = (const graphics_handle& a)
  {
    if (&a != this)
      val = a.val;

    return *this;
  }

  ~graphics_handle (void) { }

  double value (void) const { return val; }

  octave_value as_octave_value (void) const
  {
    return ok () ? octave_value (val) : octave_value (Matrix ());
  }

  // Prefix increment/decrement operators.
  graphics_handle& operator ++ (void)
  {
    ++val;
    return *this;
  }

  graphics_handle& operator -- (void)
  {
    --val;
    return *this;
  }

  // Postfix increment/decrement operators.
  const graphics_handle operator ++ (int)
  {
    graphics_handle old_value = *this;
    ++(*this);
    return old_value;
  }

  const graphics_handle operator -- (int)
  {
    graphics_handle old_value = *this;
    --(*this);
    return old_value;
  }

  bool ok (void) const { return ! xisnan (val); }

private:
  double val;
};

inline bool
operator == (const graphics_handle& a, const graphics_handle& b)
{
  return a.value () == b.value ();
}

inline bool
operator != (const graphics_handle& a, const graphics_handle& b)
{
  return a.value () != b.value ();
}

inline bool
operator < (const graphics_handle& a, const graphics_handle& b)
{
  return a.value () < b.value ();
}

inline bool
operator <= (const graphics_handle& a, const graphics_handle& b)
{
  return a.value () <= b.value ();
}

inline bool
operator >= (const graphics_handle& a, const graphics_handle& b)
{
  return a.value () >= b.value ();
}

inline bool
operator > (const graphics_handle& a, const graphics_handle& b)
{
  return a.value () > b.value ();
}

// ---------------------------------------------------------------------

class base_scaler
{
public:
  base_scaler (void) { }

  virtual ~base_scaler (void) { }

  virtual Matrix scale (const Matrix& m) const
    {
      error ("invalid axis scale");
      return m;
    }

  virtual NDArray scale (const NDArray& m) const
    {
      error ("invalid axis scale");
      return m;
    }

  virtual double scale (double d) const
    {
      error ("invalid axis scale");
      return d;
    }

  virtual double unscale (double d) const
    {
      error ("invalid axis scale");
      return d;
    }

  virtual base_scaler* clone () const
    { return new base_scaler (); }

  virtual bool is_linear (void) const
    { return false; }
};

class lin_scaler : public base_scaler
{
public:
  lin_scaler (void) { }

  Matrix scale (const Matrix& m) const { return m; }

  NDArray scale (const NDArray& m) const { return m; }

  double scale (double d) const { return d; }

  double unscale (double d) const { return d; }

  base_scaler* clone (void) const { return new lin_scaler (); }

  bool is_linear (void) const { return true; }
};

class log_scaler : public base_scaler
{
public:
  log_scaler (void) { }

  Matrix scale (const Matrix& m) const
    {
      Matrix retval (m.rows (), m.cols ());

      if (m.any_element_is_positive ())
        do_scale (m.data (), retval.fortran_vec (), m.numel ());
      else
        do_neg_scale (m.data (), retval.fortran_vec (), m.numel ());

      return retval;
    }

  NDArray scale (const NDArray& m) const
    {
      NDArray retval (m.dims ());

      if (m.any_element_is_positive ())
        do_scale (m.data (), retval.fortran_vec (), m.numel ());
      else
        do_neg_scale (m.data (), retval.fortran_vec (), m.numel ());

      return retval;
    }

  double scale (double d) const
    { return log10 (d); }

  double unscale (double d) const
    { return pow (10.0, d); }

  base_scaler* clone (void) const
    { return new log_scaler (); }

private:
  void do_scale (const double *src, double *dest, int n) const
    {
      for (int i = 0; i < n; i++)
        dest[i] = log10(src[i]);
    }

  void do_neg_scale (const double *src, double *dest, int n) const
    {
      for (int i = 0; i < n; i++)
        dest[i] = -log10(-src[i]);
    }
};

class scaler
{
public:
  scaler (void) : rep (new base_scaler ()) { }

  scaler (const scaler& s) : rep (s.rep->clone()) { }

  scaler (const std::string& s)
    : rep (s == "log"
           ? new log_scaler ()
           : (s == "linear" ? new lin_scaler () : new base_scaler ()))
    { }

  ~scaler (void) { delete rep; }

  Matrix scale (const Matrix& m) const
    { return rep->scale (m); }

  NDArray scale (const NDArray& m) const
    { return rep->scale (m); }

  double scale (double d) const
    { return rep->scale (d); }

  double unscale (double d) const
    { return rep->unscale (d); }

  bool is_linear (void) const
    { return rep->is_linear (); }

  scaler& operator = (const scaler& s)
    {
      if (rep)
        {
          delete rep;
          rep = 0;
        }

      rep = s.rep->clone ();

      return *this;
    }

  scaler& operator = (const std::string& s)
    {
      if (rep)
        {
          delete rep;
          rep = 0;
        }

      if (s == "log")
        rep = new log_scaler ();
      else if (s == "linear")
        rep = new lin_scaler ();
      else
        rep = new base_scaler ();

      return *this;
    }

private:
  base_scaler *rep;
};

// ---------------------------------------------------------------------

class property;

enum listener_mode { POSTSET, PERSISTENT, PREDELETE };

class base_property
{
public:
  friend class property;

public:
  base_property (void)
    : id (-1), count (1), name (), parent (), hidden (), listeners ()
    { }

  base_property (const std::string& s, const graphics_handle& h)
    : id (-1), count (1), name (s), parent (h), hidden (false), listeners ()
    { }

  base_property (const base_property& p)
    : id (-1), count (1), name (p.name), parent (p.parent),
      hidden (p.hidden), listeners ()
    { }

  virtual ~base_property (void) { }

  bool ok (void) const { return parent.ok (); }

  std::string get_name (void) const { return name; }

  void set_name (const std::string& s) { name = s; }

  graphics_handle get_parent (void) const { return parent; }

  void set_parent (const graphics_handle &h) { parent = h; }

  bool is_hidden (void) const { return hidden; }

  void set_hidden (bool flag) { hidden = flag; }

  virtual bool is_radio (void) const { return false; }

  int get_id (void) const { return id; }

  void set_id (int d) { id = d; }

  // Sets property value, notifies graphics toolkit.
  // If do_run is true, runs associated listeners.
  OCTINTERP_API bool set (const octave_value& v, bool do_run = true,
                          bool do_notify_toolkit = true);

  virtual octave_value get (void) const
    {
      error ("get: invalid property \"%s\"", name.c_str ());
      return octave_value ();
    }


  virtual std::string values_as_string (void) const
    {
      error ("values_as_string: invalid property \"%s\"", name.c_str ());
      return std::string ();
    }

  virtual Cell values_as_cell (void) const
    {
      error ("values_as_cell: invalid property \"%s\"", name.c_str ());
      return Cell ();
    }

  base_property& operator = (const octave_value& val)
    {
      set (val);
      return *this;
    }

  void add_listener (const octave_value& v, listener_mode mode = POSTSET)
    {
      octave_value_list& l = listeners[mode];
      l.resize (l.length () + 1, v);
    }

  void delete_listener (const octave_value& v = octave_value (),
                        listener_mode mode = POSTSET)
    {
      octave_value_list& l = listeners[mode];

      if (v.is_defined ())
        {
          bool found = false;
          int i;

          for (i = 0; i < l.length (); i++)
            {
              if (v.internal_rep () == l(i).internal_rep ())
                {
                  found = true;
                  break;
                }
            }
          if (found)
            {
              for (int j = i; j < l.length() - 1; j++)
                l(j) = l (j + 1);

              l.resize (l.length () - 1);
            }
        }
      else
        {
          if (mode == PERSISTENT)
            l.resize (0);
          else
            {
              octave_value_list lnew (0);
              octave_value_list& lp = listeners[PERSISTENT];
              for (int i = l.length () - 1; i >= 0 ; i--)
                {
                  for (int j = 0; j < lp.length (); j++)
                    {
                      if (l(i).internal_rep () == lp(j).internal_rep ())
                        {
                          lnew.resize (lnew.length () + 1, l(i));
                          break;
                        }
                    }
                }
              l = lnew;
            }
        }

    }

  OCTINTERP_API void run_listeners (listener_mode mode = POSTSET);

  virtual base_property* clone (void) const
    { return new base_property (*this); }

protected:
  virtual bool do_set (const octave_value&)
    {
      error ("set: invalid property \"%s\"", name.c_str ());
      return false;
    }

private:
  typedef std::map<listener_mode, octave_value_list> listener_map;
  typedef std::map<listener_mode, octave_value_list>::iterator listener_map_iterator;
  typedef std::map<listener_mode, octave_value_list>::const_iterator listener_map_const_iterator;

private:
  int id;
  octave_refcount<int> count;
  std::string name;
  graphics_handle parent;
  bool hidden;
  listener_map listeners;
};

// ---------------------------------------------------------------------

class string_property : public base_property
{
public:
  string_property (const std::string& s, const graphics_handle& h,
                   const std::string& val = "")
    : base_property (s, h), str (val) { }

  string_property (const string_property& p)
    : base_property (p), str (p.str) { }

  octave_value get (void) const
    { return octave_value (str); }

  std::string string_value (void) const { return str; }

  string_property& operator = (const octave_value& val)
    {
      set (val);
      return *this;
    }

  base_property* clone (void) const { return new string_property (*this); }

protected:
  bool do_set (const octave_value& val)
    {
      if (val.is_string ())
        {
          std::string new_str = val.string_value ();

          if (new_str != str)
            {
              str = new_str;
              return true;
            }
        }
      else
        error ("set: invalid string property value for \"%s\"",
               get_name ().c_str ());
      return false;
    }

private:
  std::string str;
};

// ---------------------------------------------------------------------

class string_array_property : public base_property
{
public:
  enum desired_enum { string_t, cell_t };

  string_array_property (const std::string& s, const graphics_handle& h,
                  const std::string& val = "", const char& sep = '|',
                  const desired_enum& typ = string_t)
    : base_property (s, h), desired_type (typ), separator (sep), str ()
    {
      size_t pos = 0;

      while (true)
        {
          size_t new_pos = val.find_first_of (separator, pos);

          if (new_pos == std::string::npos)
            {
              str.append (val.substr (pos));
              break;
            }
          else
            str.append (val.substr (pos, new_pos - pos));

          pos = new_pos + 1;
        }
    }

  string_array_property (const std::string& s, const graphics_handle& h,
                  const Cell& c, const char& sep = '|',
                  const desired_enum& typ = string_t)
    : base_property (s, h), desired_type (typ), separator (sep), str ()
    {
      if (c.is_cellstr ())
        {
          string_vector strings (c.numel ());

          for (octave_idx_type i = 0; i < c.numel (); i++)
            strings[i] = c(i).string_value ();

          str = strings;
        }
      else
        error ("set: invalid order property value for \"%s\"",
               get_name ().c_str ());
    }

  string_array_property (const string_array_property& p)
    : base_property (p), desired_type (p.desired_type),
      separator (p.separator), str (p.str) { }

  octave_value get (void) const
    {
      if (desired_type == string_t)
        return octave_value (string_value ());
      else
        return octave_value (cell_value ());
    }

  std::string string_value (void) const
    {
      std::string s;

      for (octave_idx_type i = 0; i < str.length (); i++)
        {
          s += str[i];
          if (i != str.length () - 1)
            s += separator;
        }

      return s;
    }

  Cell cell_value (void) const {return Cell (str);}

  string_vector string_vector_value (void) const { return str; }

  string_array_property& operator = (const octave_value& val)
    {
      set (val);
      return *this;
    }

  base_property* clone (void) const { return new string_array_property (*this); }

protected:
  bool do_set (const octave_value& val)
    {
      if (val.is_string ())
        {
          bool replace = false;
          std::string new_str = val.string_value ();
          string_vector strings;
          size_t pos = 0;

          while (pos != std::string::npos)
            {
              size_t new_pos = new_str.find_first_of (separator, pos);

              if (new_pos == std::string::npos)
                {
                  strings.append (new_str.substr (pos));
                  break;
                }
              else
                strings.append (new_str.substr (pos, new_pos - pos));

              pos = new_pos + 1;
            }

          if (str.numel () == strings.numel ())
            {
              for (octave_idx_type i = 0; i < str.numel (); i++)
                if (strings[i] != str[i])
                  {
                    replace = true;
                    break;
                  }
            }
          else
            replace = true;

          desired_type = string_t;

          if (replace)
            {
              str = strings;
              return true;
            }
        }
      else if (val.is_cellstr ())
        {
          bool replace = false;
          Cell new_cell = val.cell_value ();

          string_vector strings = new_cell.cellstr_value ();

          octave_idx_type nel = strings.length ();

          if (nel != str.length ())
            replace = true;
          else
            {
              for (octave_idx_type i = 0; i < nel; i++)
                {
                  if (strings[i] != str[i])
                    {
                      replace = true;
                      break;
                    }
                }
            }

          desired_type = cell_t;

          if (replace)
            {
              str = strings;
              return true;
            }
        }
      else
        error ("set: invalid string property value for \"%s\"",
               get_name ().c_str ());
      return false;
    }

private:
  desired_enum desired_type;
  char separator;
  string_vector str;
};

// ---------------------------------------------------------------------

class text_label_property : public base_property
{
public:
  enum type { char_t, cellstr_t };

  text_label_property (const std::string& s, const graphics_handle& h,
                       const std::string& val = "")
    : base_property (s, h), value (val), stored_type (char_t)
  { }

  text_label_property (const std::string& s, const graphics_handle& h,
                       const NDArray& nda)
    : base_property (s, h), stored_type (char_t)
  {
    octave_idx_type nel = nda.numel ();

    value.resize (nel);

    for (octave_idx_type i = 0; i < nel; i++)
      {
        std::ostringstream buf;
        buf << nda(i);
        value[i] = buf.str ();
      }
  }

  text_label_property (const std::string& s, const graphics_handle& h,
                       const Cell& c)
    : base_property (s, h), stored_type (cellstr_t)
  {
    octave_idx_type nel = c.numel ();

    value.resize (nel);

    for (octave_idx_type i = 0; i < nel; i++)
      {
        octave_value tmp = c(i);

        if (tmp.is_string ())
          value[i] = c(i).string_value ();
        else
          {
            double d = c(i).double_value ();

            if (! error_state)
              {
                std::ostringstream buf;
                buf << d;
                value[i] = buf.str ();
              }
            else
              break;
          }
      }
  }

  text_label_property (const text_label_property& p)
    : base_property (p), value (p.value), stored_type (p.stored_type)
  { }

  bool empty (void) const
  {
    octave_value tmp = get ();
    return tmp.is_empty ();
  }

  octave_value get (void) const
  {
    if (stored_type == char_t)
      return octave_value (char_value ());
    else
      return octave_value (cell_value ());
  }

  std::string string_value (void) const
  {
    return value.empty () ? std::string () : value[0];
  }

  string_vector string_vector_value (void) const { return value; }

  charMatrix char_value (void) const { return charMatrix (value, ' '); }

  Cell cell_value (void) const {return Cell (value); }

  text_label_property& operator = (const octave_value& val)
  {
    set (val);
    return *this;
  }

  base_property* clone (void) const { return new text_label_property (*this); }

protected:

  bool do_set (const octave_value& val)
  {
    if (val.is_string ())
      {
        value = val.all_strings ();

        stored_type = char_t;
      }
    else if (val.is_cell ())
      {
        Cell c = val.cell_value ();

        octave_idx_type nel = c.numel ();

        value.resize (nel);

        for (octave_idx_type i = 0; i < nel; i++)
          {
            octave_value tmp = c(i);

            if (tmp.is_string ())
              value[i] = c(i).string_value ();
            else
              {
                double d = c(i).double_value ();

                if (! error_state)
                  {
                    std::ostringstream buf;
                    buf << d;
                    value[i] = buf.str ();
                  }
                else
                  return false;
              }
          }

        stored_type = cellstr_t;
      }
    else
      {
        NDArray nda = val.array_value ();

        if (! error_state)
          {
            octave_idx_type nel = nda.numel ();

            value.resize (nel);

            for (octave_idx_type i = 0; i < nel; i++)
              {
                std::ostringstream buf;
                buf << nda(i);
                value[i] = buf.str ();
              }

            stored_type = char_t;
          }
        else
          {
            error ("set: invalid string property value for \"%s\"",
                   get_name ().c_str ());

            return false;
          }
      }

    return true;
  }

private:
  string_vector value;
  type stored_type;
};

// ---------------------------------------------------------------------

class radio_values
{
public:
  OCTINTERP_API radio_values (const std::string& opt_string = std::string ());

  radio_values (const radio_values& a)
    : default_val (a.default_val), possible_vals (a.possible_vals) { }

  radio_values& operator = (const radio_values& a)
  {
    if (&a != this)
      {
        default_val = a.default_val;
        possible_vals = a.possible_vals;
      }

    return *this;
  }

  std::string default_value (void) const { return default_val; }

  bool validate (const std::string& val, std::string& match)
  {
    bool retval = true;

    if (! contains (val, match))
      {
        error ("invalid value = %s", val.c_str ());
        retval = false;
      }

    return retval;
  }

  bool contains (const std::string& val, std::string& match)
  {
    size_t k = 0;

    size_t len = val.length ();

    std::string first_match;

    for (std::set<caseless_str>::const_iterator p = possible_vals.begin ();
         p != possible_vals.end (); p++)
      {
        if (p->compare (val, len))
          {
            if (len == p->length ())
              {
                // We found a full match (consider the case of val ==
                // "replace" with possible values "replace" and
                // "replacechildren").  Any other matches are
                // irrelevant, so set match and return now.

                match = *p;
                return true;
              }
            else
              {
                if (k == 0)
                  first_match = *p;

                k++;
              }
          }
      }

    if (k == 1)
      {
        match = first_match;
        return true;
      }
    else
      return false;
  }

  std::string values_as_string (void) const;

  Cell values_as_cell (void) const;

  octave_idx_type nelem (void) const { return possible_vals.size (); }

private:
  // Might also want to cache
  std::string default_val;
  std::set<caseless_str> possible_vals;
};

class radio_property : public base_property
{
public:
  radio_property (const std::string& nm, const graphics_handle& h,
                  const radio_values& v = radio_values ())
    : base_property (nm, h),
      vals (v), current_val (v.default_value ()) { }

  radio_property (const std::string& nm, const graphics_handle& h,
                  const std::string& v)
    : base_property (nm, h),
      vals (v), current_val (vals.default_value ()) { }

  radio_property (const std::string& nm, const graphics_handle& h,
                  const radio_values& v, const std::string& def)
    : base_property (nm, h),
      vals (v), current_val (def) { }

  radio_property (const radio_property& p)
    : base_property (p), vals (p.vals), current_val (p.current_val) { }

  octave_value get (void) const { return octave_value (current_val); }

  const std::string& current_value (void) const { return current_val; }

  std::string values_as_string (void) const { return vals.values_as_string (); }

  Cell values_as_cell (void) const { return vals.values_as_cell (); }

  bool is (const caseless_str& v) const
    { return v.compare (current_val); }

  bool is_radio (void) const { return true; }

  radio_property& operator = (const octave_value& val)
    {
      set (val);
      return *this;
    }

  base_property* clone (void) const { return new radio_property (*this); }

protected:
  bool do_set (const octave_value& newval)
  {
    if (newval.is_string ())
      {
        std::string s = newval.string_value ();

        std::string match;

        if (vals.validate (s, match))
          {
            if (match != current_val)
              {
                if (s.length () != match.length ())
                  warning_with_id ("Octave:abbreviated-property-match",
                                   "%s: allowing %s to match %s value %s",
                                   "set", s.c_str (), get_name ().c_str (),
                                   match.c_str ());
                current_val = match;
                return true;
              }
          }
        else
          error ("set: invalid value for radio property \"%s\" (value = %s)",
              get_name ().c_str (), s.c_str ());
      }
    else
      error ("set: invalid value for radio property \"%s\"",
          get_name ().c_str ());
    return false;
  }

private:
  radio_values vals;
  std::string current_val;
};

// ---------------------------------------------------------------------

class color_values
{
public:
  color_values (double r = 0, double g = 0, double b = 1)
    : xrgb (1, 3)
  {
    xrgb(0) = r;
    xrgb(1) = g;
    xrgb(2) = b;

    validate ();
  }

  color_values (std::string str)
    : xrgb (1, 3)
  {
    if (! str2rgb (str))
      error ("invalid color specification: %s", str.c_str ());
  }

  color_values (const color_values& c)
    : xrgb (c.xrgb)
  { }

  color_values& operator = (const color_values& c)
  {
    if (&c != this)
      xrgb = c.xrgb;

    return *this;
  }

  bool operator == (const color_values& c) const
    {
      return (xrgb(0) == c.xrgb(0)
              && xrgb(1) == c.xrgb(1)
              && xrgb(2) == c.xrgb(2));
    }

  bool operator != (const color_values& c) const
    { return ! (*this == c); }

  Matrix rgb (void) const { return xrgb; }

  operator octave_value (void) const { return xrgb; }

  void validate (void) const
  {
    for (int i = 0; i < 3; i++)
      {
        if (xrgb(i) < 0 ||  xrgb(i) > 1)
          {
            error ("invalid RGB color specification");
            break;
          }
      }
  }

private:
  Matrix xrgb;

  OCTINTERP_API bool str2rgb (std::string str);
};

class color_property : public base_property
{
public:
  color_property (const color_values& c, const radio_values& v)
    : base_property ("", graphics_handle ()),
      current_type (color_t), color_val (c), radio_val (v),
      current_val (v.default_value ())
  { }

  color_property (const std::string& nm, const graphics_handle& h,
                  const color_values& c = color_values (),
                  const radio_values& v = radio_values ())
    : base_property (nm, h),
      current_type (color_t), color_val (c), radio_val (v),
      current_val (v.default_value ())
  { }

  color_property (const std::string& nm, const graphics_handle& h,
                  const radio_values& v)
    : base_property (nm, h),
      current_type (radio_t), color_val (color_values ()), radio_val (v),
      current_val (v.default_value ())
  { }

  color_property (const std::string& nm, const graphics_handle& h,
                  const std::string& v)
    : base_property (nm, h),
      current_type (radio_t), color_val (color_values ()), radio_val (v),
      current_val (radio_val.default_value ())
  { }

  color_property (const std::string& nm, const graphics_handle& h,
                  const color_property& v)
    : base_property (nm, h),
      current_type (v.current_type), color_val (v.color_val),
      radio_val (v.radio_val), current_val (v.current_val)
  { }

  color_property (const color_property& p)
    : base_property (p), current_type (p.current_type),
      color_val (p.color_val), radio_val (p.radio_val),
      current_val (p.current_val) { }

  octave_value get (void) const
  {
    if (current_type == color_t)
      return color_val.rgb ();

    return current_val;
  }

  bool is_rgb (void) const { return (current_type == color_t); }

  bool is_radio (void) const { return (current_type == radio_t); }

  bool is (const std::string& v) const
    { return (is_radio () && current_val == v); }

  Matrix rgb (void) const
  {
    if (current_type != color_t)
      error ("color has no rgb value");

    return color_val.rgb ();
  }

  const std::string& current_value (void) const
  {
    if (current_type != radio_t)
      error ("color has no radio value");

    return current_val;
  }

  color_property& operator = (const octave_value& val)
    {
      set (val);
      return *this;
    }

  operator octave_value (void) const { return get (); }

  base_property* clone (void) const { return new color_property (*this); }

  std::string values_as_string (void) const { return radio_val.values_as_string (); }

  Cell values_as_cell (void) const { return radio_val.values_as_cell (); }

protected:
  OCTINTERP_API bool do_set (const octave_value& newval);

private:
  enum current_enum { color_t, radio_t } current_type;
  color_values color_val;
  radio_values radio_val;
  std::string current_val;
};

// ---------------------------------------------------------------------

class double_property : public base_property
{
public:
  double_property (const std::string& nm, const graphics_handle& h,
                   double d = 0)
    : base_property (nm, h),
      current_val (d) { }

  double_property (const double_property& p)
    : base_property (p), current_val (p.current_val) { }

  octave_value get (void) const { return octave_value (current_val); }

  double double_value (void) const { return current_val; }

  double_property& operator = (const octave_value& val)
    {
      set (val);
      return *this;
    }

  base_property* clone (void) const { return new double_property (*this); }

protected:
  bool do_set (const octave_value& v)
    {
      if (v.is_scalar_type () && v.is_real_type ())
        {
          double new_val = v.double_value ();

          if (new_val != current_val)
            {
              current_val = new_val;
              return true;
            }
        }
      else
        error ("set: invalid value for double property \"%s\"",
               get_name ().c_str ());
      return false;
    }

private:
  double current_val;
};

// ---------------------------------------------------------------------

class double_radio_property : public base_property
{
public:
  double_radio_property (double d, const radio_values& v)
      : base_property ("", graphics_handle ()),
        current_type (double_t), dval (d), radio_val (v),
        current_val (v.default_value ())
  { }

  double_radio_property (const std::string& nm, const graphics_handle& h,
                         const std::string& v)
      : base_property (nm, h),
        current_type (radio_t), dval (0), radio_val (v),
        current_val (radio_val.default_value ())
  { }

  double_radio_property (const std::string& nm, const graphics_handle& h,
                         const double_radio_property& v)
      : base_property (nm, h),
        current_type (v.current_type), dval (v.dval),
        radio_val (v.radio_val), current_val (v.current_val)
  { }

  double_radio_property (const double_radio_property& p)
    : base_property (p), current_type (p.current_type),
      dval (p.dval), radio_val (p.radio_val),
      current_val (p.current_val) { }

  octave_value get (void) const
  {
    if (current_type == double_t)
      return dval;

    return current_val;
  }

  bool is_double (void) const { return (current_type == double_t); }

  bool is_radio (void) const { return (current_type == radio_t); }

  bool is (const std::string& v) const
    { return (is_radio () && current_val == v); }

  double double_value (void) const
  {
    if (current_type != double_t)
      error ("%s: property has no double", get_name ().c_str ());

    return dval;
  }

  const std::string& current_value (void) const
  {
    if (current_type != radio_t)
      error ("%s: property has no radio value");

    return current_val;
  }

  double_radio_property& operator = (const octave_value& val)
    {
      set (val);
      return *this;
    }

  operator octave_value (void) const { return get (); }

  base_property* clone (void) const
    { return new double_radio_property (*this); }

protected:
  OCTINTERP_API bool do_set (const octave_value& v);

private:
  enum current_enum { double_t, radio_t } current_type;
  double dval;
  radio_values radio_val;
  std::string current_val;
};

// ---------------------------------------------------------------------

class array_property : public base_property
{
public:
  array_property (void)
    : base_property ("", graphics_handle ()), data (Matrix ()),
      xmin (), xmax (), xminp (), xmaxp (),
      type_constraints (), size_constraints ()
    {
      get_data_limits ();
    }

  array_property (const std::string& nm, const graphics_handle& h,
                  const octave_value& m)
    : base_property (nm, h), data (m),
      xmin (), xmax (), xminp (), xmaxp (),
      type_constraints (), size_constraints ()
    {
      get_data_limits ();
    }

  // This copy constructor is only intended to be used
  // internally to access min/max values; no need to
  // copy constraints.
  array_property (const array_property& p)
    : base_property (p), data (p.data),
      xmin (p.xmin), xmax (p.xmax), xminp (p.xminp), xmaxp (p.xmaxp),
      type_constraints (), size_constraints ()
    { }

  octave_value get (void) const { return data; }

  void add_constraint (const std::string& type)
    { type_constraints.push_back (type); }

  void add_constraint (const dim_vector& dims)
    { size_constraints.push_back (dims); }

  double min_val (void) const { return xmin; }
  double max_val (void) const { return xmax; }
  double min_pos (void) const { return xminp; }
  double max_neg (void) const { return xmaxp; }

  Matrix get_limits (void) const
    {
      Matrix m (1, 4);

      m(0) = min_val ();
      m(1) = max_val ();
      m(2) = min_pos ();
      m(3) = max_neg ();

      return m;
    }

  array_property& operator = (const octave_value& val)
    {
      set (val);
      return *this;
    }

  base_property* clone (void) const
    {
      array_property *p = new array_property (*this);

      p->type_constraints = type_constraints;
      p->size_constraints = size_constraints;

      return p;
    }

protected:
  bool do_set (const octave_value& v)
    {
      if (validate (v))
        {
          // FIXME -- should we check for actual data change?
          if (! is_equal (v))
            {
              data = v;

              get_data_limits ();

              return true;
            }
        }
      else
        error ("invalid value for array property \"%s\"",
               get_name ().c_str ());

      return false;
    }

private:
  OCTINTERP_API bool validate (const octave_value& v);

  OCTINTERP_API bool is_equal (const octave_value& v) const;

  OCTINTERP_API void get_data_limits (void);

protected:
  octave_value data;
  double xmin;
  double xmax;
  double xminp;
  double xmaxp;
  std::list<std::string> type_constraints;
  std::list<dim_vector> size_constraints;
};

class row_vector_property : public array_property
{
public:
  row_vector_property (const std::string& nm, const graphics_handle& h,
                       const octave_value& m)
    : array_property (nm, h, m)
  {
    add_constraint (dim_vector (-1, 1));
    add_constraint (dim_vector (1, -1));
  }

  row_vector_property (const row_vector_property& p)
    : array_property (p)
  {
    add_constraint (dim_vector (-1, 1));
    add_constraint (dim_vector (1, -1));
  }

  void add_constraint (const std::string& type)
  {
    array_property::add_constraint (type);
  }

  void add_constraint (const dim_vector& dims)
  {
    array_property::add_constraint (dims);
  }

  void add_constraint (octave_idx_type len)
  {
    size_constraints.remove (dim_vector (1, -1));
    size_constraints.remove (dim_vector (-1, 1));

    add_constraint (dim_vector (1, len));
    add_constraint (dim_vector (len, 1));
  }

  row_vector_property& operator = (const octave_value& val)
  {
    set (val);
    return *this;
  }

  base_property* clone (void) const
    {
      row_vector_property *p = new row_vector_property (*this);

      p->type_constraints = type_constraints;
      p->size_constraints = size_constraints;

      return p;
    }

protected:
  bool do_set (const octave_value& v)
  {
    bool retval = array_property::do_set (v);

    if (! error_state)
      {
        dim_vector dv = data.dims ();

        if (dv(0) > 1 && dv(1) == 1)
          {
            int tmp = dv(0);
            dv(0) = dv(1);
            dv(1) = tmp;

            data = data.reshape (dv);
          }

        return retval;
      }

    return false;
  }

private:
  OCTINTERP_API bool validate (const octave_value& v);
};

// ---------------------------------------------------------------------

class bool_property : public radio_property
{
public:
  bool_property (const std::string& nm, const graphics_handle& h,
                 bool val)
    : radio_property (nm, h, radio_values (val ? "{on}|off" : "on|{off}"))
    { }

  bool_property (const std::string& nm, const graphics_handle& h,
                 const char* val)
    : radio_property (nm, h, radio_values ("on|off"), val)
    { }

  bool_property (const bool_property& p)
    : radio_property (p) { }

  bool is_on (void) const { return is ("on"); }

  bool_property& operator = (const octave_value& val)
    {
      set (val);
      return *this;
    }

  base_property* clone (void) const { return new bool_property (*this); }

protected:
  bool do_set (const octave_value& val)
    {
      if (val.is_bool_scalar ())
        return radio_property::do_set (val.bool_value () ? "on" : "off");
      else
        return radio_property::do_set (val);
    }
};

// ---------------------------------------------------------------------

class handle_property : public base_property
{
public:
  handle_property (const std::string& nm, const graphics_handle& h,
                   const graphics_handle& val = graphics_handle ())
    : base_property (nm, h),
      current_val (val) { }

  handle_property (const handle_property& p)
    : base_property (p), current_val (p.current_val) { }

  octave_value get (void) const { return current_val.as_octave_value (); }

  graphics_handle handle_value (void) const { return current_val; }

  handle_property& operator = (const octave_value& val)
    {
      set (val);
      return *this;
    }

  handle_property& operator = (const graphics_handle& h)
    {
      set (octave_value (h.value ()));
      return *this;
    }

  base_property* clone (void) const { return new handle_property (*this); }

protected:
  OCTINTERP_API bool do_set (const octave_value& v);

private:
  graphics_handle current_val;
};

// ---------------------------------------------------------------------

class any_property : public base_property
{
public:
  any_property (const std::string& nm, const graphics_handle& h,
                  const octave_value& m = Matrix ())
    : base_property (nm, h), data (m) { }

  any_property (const any_property& p)
    : base_property (p), data (p.data) { }

  octave_value get (void) const { return data; }

  any_property& operator = (const octave_value& val)
    {
      set (val);
      return *this;
    }

  base_property* clone (void) const { return new any_property (*this); }

protected:
  bool do_set (const octave_value& v)
    {
      data = v;
      return true;
    }

private:
  octave_value data;
};

// ---------------------------------------------------------------------

class children_property : public base_property
{
public:
  children_property (void)
    : base_property ("", graphics_handle ()), children_list ()
    {
      do_init_children (Matrix ());
    }

  children_property (const std::string& nm, const graphics_handle& h,
                     const Matrix &val)
    : base_property (nm, h), children_list ()
    {
      do_init_children (val);
    }

  children_property (const children_property& p)
    : base_property (p), children_list ()
    {
      do_init_children (p.children_list);
    }

  children_property& operator = (const octave_value& val)
    {
      set (val);
      return *this;
    }

  base_property* clone (void) const { return new children_property (*this); }

  bool remove_child (const double &val)
    {
      return do_remove_child (val);
    }

  void adopt (const double &val)
    {
      do_adopt_child (val);
    }

  Matrix get_children (void) const
    {
      return do_get_children (false);
    }

  Matrix get_hidden (void) const
    {
      return do_get_children (true);
    }

  Matrix get_all (void) const
   {
     return do_get_all_children ();
   }

  octave_value get (void) const
    {
      return octave_value (get_children ());
    }

  void delete_children (bool clear = false)
    {
      do_delete_children (clear);
    }

  void renumber (graphics_handle old_gh, graphics_handle new_gh)
    {
      for (children_list_iterator p = children_list.begin ();
           p != children_list.end (); p++)
        {
          if (*p == old_gh)
            {
              *p = new_gh.value ();
              return;
            }
        }

      error ("children_list::renumber: child not found!");
    }

private:
  typedef std::list<double>::iterator children_list_iterator;
  typedef std::list<double>::const_iterator const_children_list_iterator;
  std::list<double> children_list;

protected:
  bool do_set (const octave_value& val)
    {
      const Matrix new_kids = val.matrix_value ();

      octave_idx_type nel = new_kids.numel ();

      const Matrix new_kids_column = new_kids.reshape (dim_vector (nel, 1));

      bool is_ok = true;

      if (! error_state)
        {
          const Matrix visible_kids = do_get_children (false);

          if (visible_kids.numel () == new_kids.numel ())
            {
              Matrix t1 = visible_kids.sort ();
              Matrix t2 = new_kids_column.sort ();

              if (t1 != t2)
                is_ok = false;
            }
          else
            is_ok = false;

          if (! is_ok)
            error ("set: new children must be a permutation of existing children");
        }
      else
        {
          is_ok = false;
          error ("set: expecting children to be array of graphics handles");
        }

      if (is_ok)
        {
          Matrix tmp = new_kids_column.stack (get_hidden ());

          children_list.clear ();

          // Don't use do_init_children here, as that reverses the
          // order of the list, and we don't want to do that if setting
          // the child list directly.

          for (octave_idx_type i = 0; i < tmp.numel (); i++)
            children_list.push_back (tmp.xelem (i));
        }

      return is_ok;
    }

private:
  void do_init_children (const Matrix &val)
    {
      children_list.clear ();
      for (octave_idx_type i = 0; i < val.numel (); i++)
        children_list.push_front (val.xelem (i));
    }

  void do_init_children (const std::list<double> &val)
    {
      children_list.clear ();
      for (const_children_list_iterator p = val.begin (); p != val.end (); p++)
        children_list.push_front (*p);
    }

  Matrix do_get_children (bool return_hidden) const;

  Matrix do_get_all_children (void) const
    {
      Matrix retval (children_list.size (), 1);
      octave_idx_type i  = 0;

      for (const_children_list_iterator p = children_list.begin ();
           p != children_list.end (); p++)
        retval(i++) = *p;
      return retval;
    }

  bool do_remove_child (double child)
    {
      for (children_list_iterator p = children_list.begin ();
           p != children_list.end (); p++)
        {
          if (*p == child)
            {
              children_list.erase (p);
              return true;
            }
        }
      return false;
    }

  void do_adopt_child (const double &val)
    {
      children_list.push_front (val);
    }

  void do_delete_children (bool clear);
};



// ---------------------------------------------------------------------

class callback_property : public base_property
{
public:
  callback_property (const std::string& nm, const graphics_handle& h,
                     const octave_value& m)
    : base_property (nm, h), callback (m), executing (false) { }

  callback_property (const callback_property& p)
    : base_property (p), callback (p.callback), executing (false) { }

  octave_value get (void) const { return callback; }

  OCTINTERP_API void execute (const octave_value& data = octave_value ()) const;

  bool is_defined (void) const
    {
      return (callback.is_defined () && ! callback.is_empty ());
    }

  callback_property& operator = (const octave_value& val)
    {
      set (val);
      return *this;
    }

  base_property* clone (void) const { return new callback_property (*this); }

protected:
  bool do_set (const octave_value& v)
    {
      if (validate (v))
        {
          callback = v;
          return true;
        }
      else
        error ("invalid value for callback property \"%s\"",
               get_name ().c_str ());
      return false;
    }

private:
  OCTINTERP_API bool validate (const octave_value& v) const;

private:
  octave_value callback;

  // If TRUE, we are executing this callback.
  mutable bool executing;
};

// ---------------------------------------------------------------------

class property
{
public:
  property (void) : rep (new base_property ("", graphics_handle ()))
    { }

  property (base_property *bp, bool persist = false) : rep (bp)
    { if (persist) rep->count++; }

  property (const property& p) : rep (p.rep)
    {
      rep->count++;
    }

  ~property (void)
    {
      if (--rep->count == 0)
        delete rep;
    }

  bool ok (void) const
    { return rep->ok (); }

  std::string get_name (void) const
    { return rep->get_name (); }

  void set_name (const std::string& name)
    { rep->set_name (name); }

  graphics_handle get_parent (void) const
    { return rep->get_parent (); }

  void set_parent (const graphics_handle& h)
    { rep->set_parent (h); }

  bool is_hidden (void) const
    { return rep->is_hidden (); }

  void set_hidden (bool flag)
    { rep->set_hidden (flag); }

  bool is_radio (void) const
    { return rep->is_radio (); }

  int get_id (void) const
    { return rep->get_id (); }

  void set_id (int d)
    { rep->set_id (d); }

  octave_value get (void) const
    { return rep->get (); }

  bool set (const octave_value& val, bool do_run = true,
            bool do_notify_toolkit = true)
    { return rep->set (val, do_run, do_notify_toolkit); }

  std::string values_as_string (void) const
    { return rep->values_as_string (); }

  Cell values_as_cell (void) const
    { return rep->values_as_cell (); }

  property& operator = (const octave_value& val)
    {
      *rep = val;
      return *this;
    }

  property& operator = (const property& p)
    {
      if (rep && --rep->count == 0)
        delete rep;

      rep = p.rep;
      rep->count++;

      return *this;
    }

  void add_listener (const octave_value& v, listener_mode mode = POSTSET)
    { rep->add_listener (v, mode); }

  void delete_listener (const octave_value& v = octave_value (),
                        listener_mode mode = POSTSET)
  { rep->delete_listener (v, mode); }

  void run_listeners (listener_mode mode = POSTSET)
    { rep->run_listeners (mode); }

  OCTINTERP_API static
      property create (const std::string& name, const graphics_handle& parent,
                       const caseless_str& type,
                       const octave_value_list& args);

  property clone (void) const
    { return property (rep->clone ()); }

  /*
  const string_property& as_string_property (void) const
    { return *(dynamic_cast<string_property*> (rep)); }

  const radio_property& as_radio_property (void) const
    { return *(dynamic_cast<radio_property*> (rep)); }

  const color_property& as_color_property (void) const
    { return *(dynamic_cast<color_property*> (rep)); }

  const double_property& as_double_property (void) const
    { return *(dynamic_cast<double_property*> (rep)); }

  const bool_property& as_bool_property (void) const
    { return *(dynamic_cast<bool_property*> (rep)); }

  const handle_property& as_handle_property (void) const
    { return *(dynamic_cast<handle_property*> (rep)); }
    */

private:
  base_property *rep;
};

// ---------------------------------------------------------------------

class property_list
{
public:
  typedef std::map<std::string, octave_value> pval_map_type;
  typedef std::map<std::string, pval_map_type> plist_map_type;

  typedef pval_map_type::iterator pval_map_iterator;
  typedef pval_map_type::const_iterator pval_map_const_iterator;

  typedef plist_map_type::iterator plist_map_iterator;
  typedef plist_map_type::const_iterator plist_map_const_iterator;

  property_list (const plist_map_type& m = plist_map_type ())
    : plist_map (m) { }

  ~property_list (void) { }

  void set (const caseless_str& name, const octave_value& val);

  octave_value lookup (const caseless_str& name) const;

  plist_map_iterator begin (void) { return plist_map.begin (); }
  plist_map_const_iterator begin (void) const { return plist_map.begin (); }

  plist_map_iterator end (void) { return plist_map.end (); }
  plist_map_const_iterator end (void) const { return plist_map.end (); }

  plist_map_iterator find (const std::string& go_name)
  {
    return plist_map.find (go_name);
  }

  plist_map_const_iterator find (const std::string& go_name) const
  {
    return plist_map.find (go_name);
  }

  octave_scalar_map as_struct (const std::string& prefix_arg) const;

private:
  plist_map_type plist_map;
};

// ---------------------------------------------------------------------

class graphics_toolkit;
class graphics_object;

class base_graphics_toolkit
{
public:
  friend class graphics_toolkit;

public:
  base_graphics_toolkit (const std::string& nm)
      : name (nm), count (0) { }

  virtual ~base_graphics_toolkit (void) { }

  std::string get_name (void) const { return name; }

  virtual bool is_valid (void) const { return false; }

  virtual void redraw_figure (const graphics_object&) const
    { gripe_invalid ("redraw_figure"); }

  virtual void print_figure (const graphics_object&, const std::string&,
                             const std::string&, bool,
                             const std::string& = "") const
    { gripe_invalid ("print_figure"); }

  virtual Matrix get_canvas_size (const graphics_handle&) const
    {
      gripe_invalid ("get_canvas_size");
      return Matrix (1, 2, 0.0);
    }

  virtual double get_screen_resolution (void) const
    {
      gripe_invalid ("get_screen_resolution");
      return 72.0;
    }

  virtual Matrix get_screen_size (void) const
    {
      gripe_invalid ("get_screen_size");
      return Matrix (1, 2, 0.0);
    }

  // Callback function executed when the given graphics object
  // changes.  This allows the graphics toolkit to act on property
  // changes if needed.
  virtual void update (const graphics_object&, int)
    { gripe_invalid ("base_graphics_toolkit::update"); }

  void update (const graphics_handle&, int);

  // Callback function executed when the given graphics object is
  // created.  This allows the graphics toolkit to do toolkit-specific
  // initializations for a newly created object.
  virtual bool initialize (const graphics_object&)
    { gripe_invalid ("base_graphics_toolkit::initialize"); return false; }

  bool initialize (const graphics_handle&);

  // Callback function executed just prior to deleting the given
  // graphics object.  This allows the graphics toolkit to perform
  // toolkit-specific cleanup operations before an object is deleted.
  virtual void finalize (const graphics_object&)
    { gripe_invalid ("base_graphics_toolkit::finalize"); }

  void finalize (const graphics_handle&);

  // Close the graphics toolkit.
  virtual void close (void)
  { gripe_invalid ("base_graphics_toolkit::close"); }

private:
  std::string name;
  octave_refcount<int> count;

private:
  void gripe_invalid (const std::string& fname) const
    {
      if (! is_valid ())
        error ("%s: invalid graphics toolkit", fname.c_str ());
    }
};

class graphics_toolkit
{
public:
  graphics_toolkit (void)
      : rep (new base_graphics_toolkit ("unknown"))
    {
      rep->count++;
    }

  graphics_toolkit (base_graphics_toolkit* b)
      : rep (b)
    {
      rep->count++;
    }

  graphics_toolkit (const graphics_toolkit& b)
      : rep (b.rep)
    {
      rep->count++;
    }

  ~graphics_toolkit (void)
    {
      if (--rep->count == 0)
        delete rep;
    }

  graphics_toolkit& operator = (const graphics_toolkit& b)
    {
      if (rep != b.rep)
        {
          if (--rep->count == 0)
            delete rep;

          rep = b.rep;
          rep->count++;
        }

      return *this;
    }

  operator bool (void) const { return rep->is_valid (); }

  std::string get_name (void) const { return rep->get_name (); }

  void redraw_figure (const graphics_object& go) const
    { rep->redraw_figure (go); }

  void print_figure (const graphics_object& go, const std::string& term,
                     const std::string& file, bool mono,
                     const std::string& debug_file = "") const
    { rep->print_figure (go, term, file, mono, debug_file); }

  Matrix get_canvas_size (const graphics_handle& fh) const
    { return rep->get_canvas_size (fh); }

  double get_screen_resolution (void) const
    { return rep->get_screen_resolution (); }

  Matrix get_screen_size (void) const
    { return rep->get_screen_size (); }

  // Notifies graphics toolkit that object't property has changed.
  void update (const graphics_object& go, int id)
    { rep->update (go, id); }

  void update (const graphics_handle& h, int id)
    { rep->update (h, id); }

  // Notifies graphics toolkit that new object was created.
  bool initialize (const graphics_object& go)
    { return rep->initialize (go); }

  bool initialize (const graphics_handle& h)
    { return rep->initialize (h); }

  // Notifies graphics toolkit that object was destroyed.
  // This is called only for explicitly deleted object. Children are
  // deleted implicitly and graphics toolkit isn't notified.
  void finalize (const graphics_object& go)
    { rep->finalize (go); }

  void finalize (const graphics_handle& h)
    { rep->finalize (h); }

  // Close the graphics toolkit.
  void close (void) { rep->close (); }

private:

  base_graphics_toolkit *rep;
};

class gtk_manager
{
public:

  static graphics_toolkit get_toolkit (void)
  {
    return instance_ok () ? instance->do_get_toolkit () : graphics_toolkit ();
  }

  static void register_toolkit (const std::string& name)
  {
    if (instance_ok ())
      instance->do_register_toolkit (name);
  }

  static void unregister_toolkit (const std::string& name)
  {
    if (instance_ok ())
      instance->do_unregister_toolkit (name);
  }

  static void load_toolkit (const graphics_toolkit& tk)
  {
    if (instance_ok ())
      instance->do_load_toolkit (tk);
  }

  static void unload_toolkit (const std::string& name)
  {
    if (instance_ok ())
      instance->do_unload_toolkit (name);
  }

  static graphics_toolkit find_toolkit (const std::string& name)
  {
    return instance_ok ()
      ? instance->do_find_toolkit (name) : graphics_toolkit ();
  }

  static Cell available_toolkits_list (void)
  {
    return instance_ok () ? instance->do_available_toolkits_list () : Cell ();
  }

  static Cell loaded_toolkits_list (void)
  {
    return instance_ok () ? instance->do_loaded_toolkits_list () : Cell ();
  }

  static void unload_all_toolkits (void)
  {
    if (instance_ok ())
      instance->do_unload_all_toolkits ();
  }

  static std::string default_toolkit (void)
  {
    return instance_ok () ? instance->do_default_toolkit () : std::string ();
  }

private:

  // FIXME -- default toolkit should be configurable.

  gtk_manager (void)
    : dtk ("gnuplot"), available_toolkits (), loaded_toolkits () { }

  ~gtk_manager (void) { }

  static void create_instance (void);

  static bool instance_ok (void)
  {
    bool retval = true;

    if (! instance)
      create_instance ();

    if (! instance)
      {
        ::error ("unable to create gh_manager!");

        retval = false;
      }

    return retval;
  }

  static void cleanup_instance (void) { delete instance; instance = 0; }

  static gtk_manager *instance;

  // The name of the default toolkit.
  std::string dtk;

  // The list of toolkits that we know about.
  std::set<std::string> available_toolkits;

  // The list of toolkits we have actually loaded.
  std::map<std::string, graphics_toolkit> loaded_toolkits;

  typedef std::set<std::string>::iterator available_toolkits_iterator;

  typedef std::set<std::string>::const_iterator
    const_available_toolkits_iterator;

  typedef std::map<std::string, graphics_toolkit>::iterator
    loaded_toolkits_iterator;

  typedef std::map<std::string, graphics_toolkit>::const_iterator
    const_loaded_toolkits_iterator;

  graphics_toolkit do_get_toolkit (void) const;

  void do_register_toolkit (const std::string& name)
  {
    available_toolkits.insert (name);
  }

  void do_unregister_toolkit (const std::string& name)
  {
    available_toolkits.erase (name);
  }

  void do_load_toolkit (const graphics_toolkit& tk)
  {
    loaded_toolkits[tk.get_name ()] = tk;
  }

  void do_unload_toolkit (const std::string& name)
  {
    loaded_toolkits.erase (name);
  }

  graphics_toolkit do_find_toolkit (const std::string& name) const
  {
    const_loaded_toolkits_iterator p = loaded_toolkits.find (name);

    if (p != loaded_toolkits.end ())
      return p->second;
    else
      return graphics_toolkit ();
  }

  Cell do_available_toolkits_list (void) const
  {
    Cell m (1 , available_toolkits.size ());
    
    octave_idx_type i = 0;
    for (const_available_toolkits_iterator p = available_toolkits.begin ();
         p !=  available_toolkits.end (); p++)
      m(i++) = *p;

    return m;
  }

  Cell do_loaded_toolkits_list (void) const
  {
    Cell m (1 , loaded_toolkits.size ());
    
    octave_idx_type i = 0;
    for (const_loaded_toolkits_iterator p = loaded_toolkits.begin ();
         p !=  loaded_toolkits.end (); p++)
      m(i++) = p->first;

    return m;
  }

  void do_unload_all_toolkits (void)
  {
    while (! loaded_toolkits.empty ())
      {
        loaded_toolkits_iterator p = loaded_toolkits.begin ();

        std::string name = p->first;

        p->second.close ();

        // The toolkit may have unloaded itself.  If not, we'll do
        // it here.
        if (loaded_toolkits.find (name) != loaded_toolkits.end ())
          unload_toolkit (name);
      }
  }

  std::string do_default_toolkit (void) { return dtk; }
};

// ---------------------------------------------------------------------

class base_graphics_object;
class graphics_object;

class OCTINTERP_API base_properties
{
public:
  base_properties (const std::string& ty = "unknown",
                   const graphics_handle& mh = graphics_handle (),
                   const graphics_handle& p = graphics_handle ());

  virtual ~base_properties (void) { }

  virtual std::string graphics_object_name (void) const { return "unknonwn"; }

  void mark_modified (void);

  void override_defaults (base_graphics_object& obj);

  virtual void init_integerhandle (const octave_value&)
    {
      panic_impossible ();
    }

  // Look through DEFAULTS for properties with given CLASS_NAME, and
  // apply them to the current object with set (virtual method).

  void set_from_list (base_graphics_object& obj, property_list& defaults);

  void insert_property (const std::string& name, property p)
    {
      p.set_name (name);
      p.set_parent (__myhandle__);
      all_props[name] = p;
    }

  virtual void set (const caseless_str&, const octave_value&);

  virtual octave_value get (const caseless_str& pname) const;

  virtual octave_value get (const std::string& pname) const
  {
    return get (caseless_str (pname));
  }

  virtual octave_value get (const char *pname) const
  {
    return get (caseless_str (pname));
  }

  virtual octave_value get (bool all = false) const;

  virtual property get_property (const caseless_str& pname);

  virtual bool has_property (const caseless_str&) const
  {
    panic_impossible ();
    return false;
  }

  bool is_modified (void) const { return is___modified__ (); }

  virtual void remove_child (const graphics_handle& h)
    {
      if (children.remove_child (h.value ()))
        mark_modified ();
    }

  virtual void adopt (const graphics_handle& h)
  {
    children.adopt (h.value ());
    mark_modified ();
  }

  virtual graphics_toolkit get_toolkit (void) const;

  virtual Matrix get_boundingbox (bool /*internal*/ = false,
                                  const Matrix& /*parent_pix_size*/ = Matrix ()) const
    { return Matrix (1, 4, 0.0); }

  virtual void update_boundingbox (void);

  virtual void update_autopos (const std::string& elem_type);

  virtual void add_listener (const caseless_str&, const octave_value&,
                             listener_mode = POSTSET);

  virtual void delete_listener (const caseless_str&, const octave_value&,
                                listener_mode = POSTSET);

  void set_tag (const octave_value& val) { tag = val; }

  void set_parent (const octave_value& val);

  Matrix get_children (void) const
    {
      return children.get_children ();
    }

  Matrix get_all_children (void) const
    {
      return children.get_all ();
    }

  Matrix get_hidden_children (void) const
    {
      return children.get_hidden ();
    }

  void set_modified (const octave_value& val) { set___modified__ (val); }

  void set___modified__ (const octave_value& val) { __modified__ = val; }

  void reparent (const graphics_handle& new_parent) { parent = new_parent; }

  // Update data limits for AXIS_TYPE (xdata, ydata, etc.) in the parent
  // axes object.

  virtual void update_axis_limits (const std::string& axis_type) const;

  virtual void update_axis_limits (const std::string& axis_type,
                                   const graphics_handle& h) const;

  virtual void delete_children (bool clear = false)
    {
      children.delete_children (clear);
    }

  void renumber_child (graphics_handle old_gh, graphics_handle new_gh)
    {
      children.renumber (old_gh, new_gh);
    }

  void renumber_parent (graphics_handle new_gh)
    {
      parent = new_gh;
    }

  static property_list::pval_map_type factory_defaults (void);

  // FIXME -- these functions should be generated automatically by the
  // genprops.awk script.
  //
  // EMIT_BASE_PROPERTIES_GET_FUNCTIONS

  virtual octave_value get_xlim (void) const { return octave_value (); }
  virtual octave_value get_ylim (void) const { return octave_value (); }
  virtual octave_value get_zlim (void) const { return octave_value (); }
  virtual octave_value get_clim (void) const { return octave_value (); }
  virtual octave_value get_alim (void) const { return octave_value (); }

  virtual bool is_xliminclude (void) const { return false; }
  virtual bool is_yliminclude (void) const { return false; }
  virtual bool is_zliminclude (void) const { return false; }
  virtual bool is_climinclude (void) const { return false; }
  virtual bool is_aliminclude (void) const { return false; }

  bool is_handle_visible (void) const;

  std::set<std::string> dynamic_property_names (void) const;

  bool has_dynamic_property (const std::string& pname);

protected:
  std::set<std::string> dynamic_properties;

  void set_dynamic (const caseless_str& pname, const octave_value& val);

  octave_value get_dynamic (const caseless_str& pname) const;

  octave_value get_dynamic (bool all = false) const;

  property get_property_dynamic (const caseless_str& pname);

public:


  static std::set<std::string> core_property_names (void);

  static bool has_core_property (const caseless_str& pname);

  std::set<std::string> all_property_names (void) const;

protected:

  bool_property beingdeleted;
  radio_property busyaction;
  callback_property buttondownfcn;
  children_property children;
  bool_property clipping;
  callback_property createfcn;
  callback_property deletefcn;
  radio_property handlevisibility;
  bool_property hittest;
  bool_property interruptible;
  handle_property parent;
  bool_property selected;
  bool_property selectionhighlight;
  string_property tag;
  string_property type;
  any_property userdata;
  bool_property visible;
  bool_property __modified__;
  graphics_handle __myhandle__;
  handle_property uicontextmenu;

public:

  enum
  {
    ID_BEINGDELETED = 0,
    ID_BUSYACTION = 1,
    ID_BUTTONDOWNFCN = 2,
    ID_CHILDREN = 3,
    ID_CLIPPING = 4,
    ID_CREATEFCN = 5,
    ID_DELETEFCN = 6,
    ID_HANDLEVISIBILITY = 7,
    ID_HITTEST = 8,
    ID_INTERRUPTIBLE = 9,
    ID_PARENT = 10,
    ID_SELECTED = 11,
    ID_SELECTIONHIGHLIGHT = 12,
    ID_TAG = 13,
    ID_TYPE = 14,
    ID_USERDATA = 15,
    ID_VISIBLE = 16,
    ID___MODIFIED__ = 17,
    ID___MYHANDLE__ = 18,
    ID_UICONTEXTMENU = 19
  };

  bool is_beingdeleted (void) const { return beingdeleted.is_on (); }
  std::string get_beingdeleted (void) const { return beingdeleted.current_value (); }

  bool busyaction_is (const std::string& v) const { return busyaction.is (v); }
  std::string get_busyaction (void) const { return busyaction.current_value (); }

  void execute_buttondownfcn (const octave_value& data = octave_value ()) const { buttondownfcn.execute (data); }
  octave_value get_buttondownfcn (void) const { return buttondownfcn.get (); }

  bool is_clipping (void) const { return clipping.is_on (); }
  std::string get_clipping (void) const { return clipping.current_value (); }

  void execute_createfcn (const octave_value& data = octave_value ()) const { createfcn.execute (data); }
  octave_value get_createfcn (void) const { return createfcn.get (); }

  void execute_deletefcn (const octave_value& data = octave_value ()) const { deletefcn.execute (data); }
  octave_value get_deletefcn (void) const { return deletefcn.get (); }

  bool handlevisibility_is (const std::string& v) const { return handlevisibility.is (v); }
  std::string get_handlevisibility (void) const { return handlevisibility.current_value (); }

  bool is_hittest (void) const { return hittest.is_on (); }
  std::string get_hittest (void) const { return hittest.current_value (); }

  bool is_interruptible (void) const { return interruptible.is_on (); }
  std::string get_interruptible (void) const { return interruptible.current_value (); }

  graphics_handle get_parent (void) const { return parent.handle_value (); }

  bool is_selected (void) const { return selected.is_on (); }
  std::string get_selected (void) const { return selected.current_value (); }

  bool is_selectionhighlight (void) const { return selectionhighlight.is_on (); }
  std::string get_selectionhighlight (void) const { return selectionhighlight.current_value (); }

  std::string get_tag (void) const { return tag.string_value (); }

  std::string get_type (void) const { return type.string_value (); }

  octave_value get_userdata (void) const { return userdata.get (); }

  bool is_visible (void) const { return visible.is_on (); }
  std::string get_visible (void) const { return visible.current_value (); }

  bool is___modified__ (void) const { return __modified__.is_on (); }
  std::string get___modified__ (void) const { return __modified__.current_value (); }

  graphics_handle get___myhandle__ (void) const { return __myhandle__; }

  graphics_handle get_uicontextmenu (void) const { return uicontextmenu.handle_value (); }


  void set_beingdeleted (const octave_value& val)
  {
    if (! error_state)
      {
        if (beingdeleted.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_busyaction (const octave_value& val)
  {
    if (! error_state)
      {
        if (busyaction.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_buttondownfcn (const octave_value& val)
  {
    if (! error_state)
      {
        if (buttondownfcn.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_children (const octave_value& val)
  {
    if (! error_state)
      {
        if (children.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_clipping (const octave_value& val)
  {
    if (! error_state)
      {
        if (clipping.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_createfcn (const octave_value& val)
  {
    if (! error_state)
      {
        if (createfcn.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_deletefcn (const octave_value& val)
  {
    if (! error_state)
      {
        if (deletefcn.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_handlevisibility (const octave_value& val)
  {
    if (! error_state)
      {
        if (handlevisibility.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_hittest (const octave_value& val)
  {
    if (! error_state)
      {
        if (hittest.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_interruptible (const octave_value& val)
  {
    if (! error_state)
      {
        if (interruptible.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_selected (const octave_value& val)
  {
    if (! error_state)
      {
        if (selected.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_selectionhighlight (const octave_value& val)
  {
    if (! error_state)
      {
        if (selectionhighlight.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_userdata (const octave_value& val)
  {
    if (! error_state)
      {
        if (userdata.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_visible (const octave_value& val)
  {
    if (! error_state)
      {
        if (visible.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_uicontextmenu (const octave_value& val)
  {
    if (! error_state)
      {
        if (uicontextmenu.set (val, true))
          {
            mark_modified ();
          }
      }
  }


protected:
  struct cmp_caseless_str
    {
      bool operator () (const caseless_str &a, const caseless_str &b) const
        {
          std::string a1 = a;
          std::transform (a1.begin (), a1.end (), a1.begin (), tolower);
          std::string b1 = b;
          std::transform (b1.begin (), b1.end (), b1.begin (), tolower);

          return a1 < b1;
        }
    };

  std::map<caseless_str, property, cmp_caseless_str> all_props;

protected:
  void insert_static_property (const std::string& name, base_property& p)
    { insert_property (name, property (&p, true)); }

  virtual void init (void) { }
};

class OCTINTERP_API base_graphics_object
{
public:
  friend class graphics_object;

  base_graphics_object (void) : count (1), toolkit_flag (false) { }

  virtual ~base_graphics_object (void) { }

  virtual void mark_modified (void)
  {
    if (valid_object ())
      get_properties ().mark_modified ();
    else
      error ("base_graphics_object::mark_modified: invalid graphics object");
  }

  virtual void override_defaults (base_graphics_object& obj)
  {
    if (valid_object ())
      get_properties ().override_defaults (obj);
    else
      error ("base_graphics_object::override_defaults: invalid graphics object");
  }

  virtual void set_from_list (property_list& plist)
  {
    if (valid_object ())
      get_properties ().set_from_list (*this, plist);
    else
      error ("base_graphics_object::set_from_list: invalid graphics object");
  }

  virtual void set (const caseless_str& pname, const octave_value& pval)
  {
    if (valid_object ())
      get_properties ().set (pname, pval);
    else
      error ("base_graphics_object::set: invalid graphics object");
  }

  virtual void set_defaults (const std::string&)
  {
    error ("base_graphics_object::set_defaults: invalid graphics object");
  }

  virtual octave_value get (bool all = false) const
  {
    if (valid_object ())
      return get_properties ().get (all);
    else
      {
        error ("base_graphics_object::get: invalid graphics object");
        return octave_value ();
      }
  }

  virtual octave_value get (const caseless_str& pname) const
  {
    if (valid_object ())
      return get_properties ().get (pname);
    else
      {
        error ("base_graphics_object::get: invalid graphics object");
        return octave_value ();
      }
  }

  virtual octave_value get_default (const caseless_str&) const;

  virtual octave_value get_factory_default (const caseless_str&) const;

  virtual octave_value get_defaults (void) const
  {
    error ("base_graphics_object::get_defaults: invalid graphics object");
    return octave_value ();
  }

  virtual octave_value get_factory_defaults (void) const
  {
    error ("base_graphics_object::get_factory_defaults: invalid graphics object");
    return octave_value ();
  }

  virtual std::string values_as_string (void);

  virtual octave_scalar_map values_as_struct (void);

  virtual graphics_handle get_parent (void) const
  {
    if (valid_object ())
      return get_properties ().get_parent ();
    else
      {
        error ("base_graphics_object::get_parent: invalid graphics object");
        return graphics_handle ();
      }
  }

  graphics_handle get_handle (void) const
  {
    if (valid_object ())
      return get_properties ().get___myhandle__ ();
    else
      {
        error ("base_graphics_object::get_handle: invalid graphics object");
        return graphics_handle ();
      }
  }

  virtual void remove_child (const graphics_handle& h)
  {
    if (valid_object ())
      get_properties ().remove_child (h);
    else
      error ("base_graphics_object::remove_child: invalid graphics object");
  }

  virtual void adopt (const graphics_handle& h)
  {
    if (valid_object ())
      get_properties ().adopt (h);
    else
      error ("base_graphics_object::adopt: invalid graphics object");
  }

  virtual void reparent (const graphics_handle& np)
  {
    if (valid_object ())
      get_properties ().reparent (np);
    else
      error ("base_graphics_object::reparent: invalid graphics object");
  }

  virtual void defaults (void) const
  {
    if (valid_object ())
      {
        std::string msg = (type () + "::defaults");
        gripe_not_implemented (msg.c_str ());
      }
    else
      error ("base_graphics_object::default: invalid graphics object");
  }

  virtual base_properties& get_properties (void)
  {
    static base_properties properties;
    error ("base_graphics_object::get_properties: invalid graphics object");
    return properties;
  }

  virtual const base_properties& get_properties (void) const
  {
    static base_properties properties;
    error ("base_graphics_object::get_properties: invalid graphics object");
    return properties;
  }

  virtual void update_axis_limits (const std::string& axis_type);

  virtual void update_axis_limits (const std::string& axis_type,
                                   const graphics_handle& h);

  virtual bool valid_object (void) const { return false; }

  bool valid_toolkit_object (void) const { return toolkit_flag; }

  virtual std::string type (void) const
  {
    return (valid_object () ? get_properties ().graphics_object_name ()
        : "unknown");
  }

  bool isa (const std::string& go_name) const
  {
    return type () == go_name;
  }

  virtual graphics_toolkit get_toolkit (void) const
  {
    if (valid_object ())
      return get_properties ().get_toolkit ();
    else
      {
        error ("base_graphics_object::get_toolkit: invalid graphics object");
        return graphics_toolkit ();
      }
  }

  virtual void add_property_listener (const std::string& nm,
                                      const octave_value& v,
                                      listener_mode mode = POSTSET)
    {
      if (valid_object ())
        get_properties ().add_listener (nm, v, mode);
    }

  virtual void delete_property_listener (const std::string& nm,
                                         const octave_value& v,
                                         listener_mode mode = POSTSET)
    {
      if (valid_object ())
        get_properties ().delete_listener (nm, v, mode);
    }

  virtual void remove_all_listeners (void);

  virtual void reset_default_properties (void)
    {
      if (valid_object ())
        {
          std::string msg = (type () + "::reset_default_properties");
          gripe_not_implemented (msg.c_str ());
        }
      else
        error ("base_graphics_object::default: invalid graphics object");
    }

protected:
  virtual void initialize (const graphics_object& go)
    {
      if (! toolkit_flag)
        toolkit_flag = get_toolkit ().initialize (go);
    }

  virtual void finalize (const graphics_object& go)
    {
      if (toolkit_flag)
        {
          get_toolkit ().finalize (go);
          toolkit_flag = false;
        }
    }

  virtual void update (const graphics_object& go, int id)
    {
      if (toolkit_flag)
        get_toolkit ().update (go, id);
    }

protected:
  // A reference count.
  octave_refcount<int> count;

  // A flag telling whether this object is a valid object
  // in the backend context.
  bool toolkit_flag;

  // No copying!

  base_graphics_object (const base_graphics_object&) : count (0) { }

  base_graphics_object& operator = (const base_graphics_object&)
  {
    return *this;
  }
};

class OCTINTERP_API graphics_object
{
public:
  graphics_object (void) : rep (new base_graphics_object ()) { }

  graphics_object (base_graphics_object *new_rep)
    : rep (new_rep) { }

  graphics_object (const graphics_object& obj) : rep (obj.rep)
  {
    rep->count++;
  }

  graphics_object& operator = (const graphics_object& obj)
  {
    if (rep != obj.rep)
      {
        if (--rep->count == 0)
          delete rep;

        rep = obj.rep;
        rep->count++;
      }

    return *this;
  }

  ~graphics_object (void)
  {
    if (--rep->count == 0)
      delete rep;
  }

  void mark_modified (void) { rep->mark_modified (); }

  void override_defaults (base_graphics_object& obj)
  {
    rep->override_defaults (obj);
  }

  void set_from_list (property_list& plist) { rep->set_from_list (plist); }

  void set (const caseless_str& name, const octave_value& val)
  {
    rep->set (name, val);
  }

  void set (const octave_value_list& args);

  void set (const Array<std::string>& names, const Cell& values,
            octave_idx_type row);

  void set (const octave_map& m);

  void set_value_or_default (const caseless_str& name,
                             const octave_value& val);

  void set_defaults (const std::string& mode) { rep->set_defaults (mode); }

  octave_value get (bool all = false) const { return rep->get (all); }

  octave_value get (const caseless_str& name) const
  {
    return name.compare ("default")
      ? get_defaults ()
      : (name.compare ("factory")
         ? get_factory_defaults () : rep->get (name));
  }

  octave_value get (const std::string& name) const
  {
    return get (caseless_str (name));
  }

  octave_value get (const char *name) const
  {
    return get (caseless_str (name));
  }

  octave_value get_default (const caseless_str& name) const
  {
    return rep->get_default (name);
  }

  octave_value get_factory_default (const caseless_str& name) const
  {
    return rep->get_factory_default (name);
  }

  octave_value get_defaults (void) const { return rep->get_defaults (); }

  octave_value get_factory_defaults (void) const
  {
    return rep->get_factory_defaults ();
  }

  std::string values_as_string (void) { return rep->values_as_string (); }

  octave_map values_as_struct (void) { return rep->values_as_struct (); }

  graphics_handle get_parent (void) const { return rep->get_parent (); }

  graphics_handle get_handle (void) const { return rep->get_handle (); }

  graphics_object get_ancestor (const std::string& type) const;

  void remove_child (const graphics_handle& h) { rep->remove_child (h); }

  void adopt (const graphics_handle& h) { rep->adopt (h); }

  void reparent (const graphics_handle& h) { rep->reparent (h); }

  void defaults (void) const { rep->defaults (); }

  bool isa (const std::string& go_name) const { return rep->isa (go_name); }

  base_properties& get_properties (void) { return rep->get_properties (); }

  const base_properties& get_properties (void) const
  {
    return rep->get_properties ();
  }

  void update_axis_limits (const std::string& axis_type)
  {
    rep->update_axis_limits (axis_type);
  }

  void update_axis_limits (const std::string& axis_type,
                           const graphics_handle& h)
  {
    rep->update_axis_limits (axis_type, h);
  }

  bool valid_object (void) const { return rep->valid_object (); }

  std::string type (void) const { return rep->type (); }

  operator bool (void) const { return rep->valid_object (); }

  // FIXME -- these functions should be generated automatically by the
  // genprops.awk script.
  //
  // EMIT_GRAPHICS_OBJECT_GET_FUNCTIONS

  octave_value get_xlim (void) const
  { return get_properties ().get_xlim (); }

  octave_value get_ylim (void) const
  { return get_properties ().get_ylim (); }

  octave_value get_zlim (void) const
  { return get_properties ().get_zlim (); }

  octave_value get_clim (void) const
  { return get_properties ().get_clim (); }

  octave_value get_alim (void) const
  { return get_properties ().get_alim (); }

  bool is_xliminclude (void) const
  { return get_properties ().is_xliminclude (); }

  bool is_yliminclude (void) const
  { return get_properties ().is_yliminclude (); }

  bool is_zliminclude (void) const
  { return get_properties ().is_zliminclude (); }

  bool is_climinclude (void) const
  { return get_properties ().is_climinclude (); }

  bool is_aliminclude (void) const
  { return get_properties ().is_aliminclude (); }

  bool is_handle_visible (void) const
  { return get_properties ().is_handle_visible (); }

  graphics_toolkit get_toolkit (void) const { return rep->get_toolkit (); }

  void add_property_listener (const std::string& nm, const octave_value& v,
                              listener_mode mode = POSTSET)
    { rep->add_property_listener (nm, v, mode); }

  void delete_property_listener (const std::string& nm, const octave_value& v,
                                 listener_mode mode = POSTSET)
    { rep->delete_property_listener (nm, v, mode); }

  void initialize (void) { rep->initialize (*this); }
  
  void finalize (void) { rep->finalize (*this); }

  void update (int id) { rep->update (*this, id); }

  void reset_default_properties (void)
  { rep->reset_default_properties (); }

private:
  base_graphics_object *rep;
};

// ---------------------------------------------------------------------

class OCTINTERP_API root_figure : public base_graphics_object
{
public:
  class OCTINTERP_API properties : public base_properties
  {
  public:
    void remove_child (const graphics_handle& h);

    // See the genprops.awk script for an explanation of the
    // properties declarations.

    // FIXME -- it seems strange to me that the diary, diaryfile,
    // echo, format, formatspacing, language, and recursionlimit
    // properties are here.  WTF do they have to do with graphics?
    // Also note that these properties (and the monitorpositions,
    // pointerlocation, and pointerwindow properties) are not yet used
    // by Octave, so setting them will have no effect, and changes
    // made elswhere (say, the diary or format functions) will not
    // cause these properties to be updated.

public:
  properties (const graphics_handle& mh, const graphics_handle& p);

  ~properties (void) { }

  void set (const caseless_str& pname, const octave_value& val);

  octave_value get (bool all = false) const;

  octave_value get (const caseless_str& pname) const;

  octave_value get (const std::string& pname) const
  {
    return get (caseless_str (pname));
  }

  octave_value get (const char *pname) const
  {
    return get (caseless_str (pname));
  }

  property get_property (const caseless_str& pname);

  std::string graphics_object_name (void) const { return go_name; }

  static property_list::pval_map_type factory_defaults (void);

private:
  static std::string go_name;

public:


  static std::set<std::string> core_property_names (void);

  static bool has_core_property (const caseless_str& pname);

  std::set<std::string> all_property_names (void) const;

  bool has_property (const caseless_str& pname) const;

private:

  handle_property callbackobject;
  array_property commandwindowsize;
  handle_property currentfigure;
  bool_property diary;
  string_property diaryfile;
  bool_property echo;
  radio_property format;
  radio_property formatspacing;
  string_property language;
  array_property monitorpositions;
  array_property pointerlocation;
  double_property pointerwindow;
  double_property recursionlimit;
  double_property screendepth;
  double_property screenpixelsperinch;
  array_property screensize;
  bool_property showhiddenhandles;
  radio_property units;

public:

  enum
  {
    ID_CALLBACKOBJECT = 1000,
    ID_COMMANDWINDOWSIZE = 1001,
    ID_CURRENTFIGURE = 1002,
    ID_DIARY = 1003,
    ID_DIARYFILE = 1004,
    ID_ECHO = 1005,
    ID_FORMAT = 1006,
    ID_FORMATSPACING = 1007,
    ID_LANGUAGE = 1008,
    ID_MONITORPOSITIONS = 1009,
    ID_POINTERLOCATION = 1010,
    ID_POINTERWINDOW = 1011,
    ID_RECURSIONLIMIT = 1012,
    ID_SCREENDEPTH = 1013,
    ID_SCREENPIXELSPERINCH = 1014,
    ID_SCREENSIZE = 1015,
    ID_SHOWHIDDENHANDLES = 1016,
    ID_UNITS = 1017
  };

  graphics_handle get_callbackobject (void) const { return callbackobject.handle_value (); }

  octave_value get_commandwindowsize (void) const { return commandwindowsize.get (); }

  graphics_handle get_currentfigure (void) const { return currentfigure.handle_value (); }

  bool is_diary (void) const { return diary.is_on (); }
  std::string get_diary (void) const { return diary.current_value (); }

  std::string get_diaryfile (void) const { return diaryfile.string_value (); }

  bool is_echo (void) const { return echo.is_on (); }
  std::string get_echo (void) const { return echo.current_value (); }

  bool format_is (const std::string& v) const { return format.is (v); }
  std::string get_format (void) const { return format.current_value (); }

  bool formatspacing_is (const std::string& v) const { return formatspacing.is (v); }
  std::string get_formatspacing (void) const { return formatspacing.current_value (); }

  std::string get_language (void) const { return language.string_value (); }

  octave_value get_monitorpositions (void) const { return monitorpositions.get (); }

  octave_value get_pointerlocation (void) const { return pointerlocation.get (); }

  double get_pointerwindow (void) const { return pointerwindow.double_value (); }

  double get_recursionlimit (void) const { return recursionlimit.double_value (); }

  double get_screendepth (void) const { return screendepth.double_value (); }

  double get_screenpixelsperinch (void) const { return screenpixelsperinch.double_value (); }

  octave_value get_screensize (void) const { return screensize.get (); }

  bool is_showhiddenhandles (void) const { return showhiddenhandles.is_on (); }
  std::string get_showhiddenhandles (void) const { return showhiddenhandles.current_value (); }

  bool units_is (const std::string& v) const { return units.is (v); }
  std::string get_units (void) const { return units.current_value (); }


  void set_callbackobject (const octave_value& val);

  void set_commandwindowsize (const octave_value& val)
  {
    if (! error_state)
      {
        if (commandwindowsize.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_currentfigure (const octave_value& val);

  void set_diary (const octave_value& val)
  {
    if (! error_state)
      {
        if (diary.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_diaryfile (const octave_value& val)
  {
    if (! error_state)
      {
        if (diaryfile.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_echo (const octave_value& val)
  {
    if (! error_state)
      {
        if (echo.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_format (const octave_value& val)
  {
    if (! error_state)
      {
        if (format.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_formatspacing (const octave_value& val)
  {
    if (! error_state)
      {
        if (formatspacing.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_language (const octave_value& val)
  {
    if (! error_state)
      {
        if (language.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_monitorpositions (const octave_value& val)
  {
    if (! error_state)
      {
        if (monitorpositions.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_pointerlocation (const octave_value& val)
  {
    if (! error_state)
      {
        if (pointerlocation.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_pointerwindow (const octave_value& val)
  {
    if (! error_state)
      {
        if (pointerwindow.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_recursionlimit (const octave_value& val)
  {
    if (! error_state)
      {
        if (recursionlimit.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_screendepth (const octave_value& val)
  {
    if (! error_state)
      {
        if (screendepth.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_screenpixelsperinch (const octave_value& val)
  {
    if (! error_state)
      {
        if (screenpixelsperinch.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_screensize (const octave_value& val)
  {
    if (! error_state)
      {
        if (screensize.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_showhiddenhandles (const octave_value& val)
  {
    if (! error_state)
      {
        if (showhiddenhandles.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_units (const octave_value& val)
  {
    if (! error_state)
      {
        if (units.set (val, true))
          {
            update_units ();
            mark_modified ();
          }
      }
  }

  void update_units (void);


  private:
    std::list<graphics_handle> cbo_stack;
  };

private:
  properties xproperties;

public:

  root_figure (void) : xproperties (0, graphics_handle ()), default_properties () { }

  ~root_figure (void) { }

  void mark_modified (void) { }

  void override_defaults (base_graphics_object& obj)
  {
    // Now override with our defaults.  If the default_properties
    // list includes the properties for all defaults (line,
    // surface, etc.) then we don't have to know the type of OBJ
    // here, we just call its set function and let it decide which
    // properties from the list to use.
    obj.set_from_list (default_properties);
  }

  void set (const caseless_str& name, const octave_value& value)
  {
    if (name.compare ("default", 7))
      // strip "default", pass rest to function that will
      // parse the remainder and add the element to the
      // default_properties map.
      default_properties.set (name.substr (7), value);
    else
      xproperties.set (name, value);
  }

  octave_value get (const caseless_str& name) const
  {
    octave_value retval;

    if (name.compare ("default", 7))
      return get_default (name.substr (7));
    else if (name.compare ("factory", 7))
      return get_factory_default (name.substr (7));
    else
      retval = xproperties.get (name);

    return retval;
  }

  octave_value get_default (const caseless_str& name) const
  {
    octave_value retval = default_properties.lookup (name);

    if (retval.is_undefined ())
      {
        // no default property found, use factory default
        retval = factory_properties.lookup (name);

        if (retval.is_undefined ())
          error ("get: invalid default property `%s'", name.c_str ());
      }

    return retval;
  }

  octave_value get_factory_default (const caseless_str& name) const
  {
    octave_value retval = factory_properties.lookup (name);

    if (retval.is_undefined ())
      error ("get: invalid factory default property `%s'", name.c_str ());

    return retval;
  }

  octave_value get_defaults (void) const
  {
    return default_properties.as_struct ("default");
  }

  octave_value get_factory_defaults (void) const
  {
    return factory_properties.as_struct ("factory");
  }

  base_properties& get_properties (void) { return xproperties; }

  const base_properties& get_properties (void) const { return xproperties; }

  bool valid_object (void) const { return true; }

  void reset_default_properties (void);

private:
  property_list default_properties;

  static property_list factory_properties;

  static property_list::plist_map_type init_factory_properties (void);
};

// ---------------------------------------------------------------------

class OCTINTERP_API figure : public base_graphics_object
{
public:
  class OCTINTERP_API properties : public base_properties
  {
  public:
    void init_integerhandle (const octave_value& val)
      {
        integerhandle = val;
      }

    void remove_child (const graphics_handle& h);

    void set_visible (const octave_value& val);

    graphics_toolkit get_toolkit (void) const
      {
        if (! toolkit)
          toolkit = gtk_manager::get_toolkit ();

        return toolkit;
      }

    void set_toolkit (const graphics_toolkit& b);

    void set___graphics_toolkit__ (const octave_value& val)
    {
      if (! error_state)
        {
          if (val.is_string ())
            {
              std::string nm = val.string_value ();
              graphics_toolkit b = gtk_manager::find_toolkit (nm);
              if (b.get_name () != nm)
                {
                  error ("set___graphics_toolkit__: invalid graphics toolkit");
                }
              else
                {
                  set_toolkit (b);
                  mark_modified ();
                }
            }
          else
            error ("set___graphics_toolkit__ must be a string");
        }
    }

    void set_position (const octave_value& val,
                       bool do_notify_toolkit = true);

    void set_outerposition (const octave_value& val,
                            bool do_notify_toolkit = true);

    Matrix get_boundingbox (bool internal = false,
                            const Matrix& parent_pix_size = Matrix ()) const;

    void set_boundingbox (const Matrix& bb, bool internal = false,
                          bool do_notify_toolkit = true);

    Matrix map_from_boundingbox (double x, double y) const;

    Matrix map_to_boundingbox (double x, double y) const;

    void update_units (const caseless_str& old_units);

    void update_paperunits (const caseless_str& old_paperunits);

    std::string get_title (void) const;

    // See the genprops.awk script for an explanation of the
    // properties declarations.

public:
  properties (const graphics_handle& mh, const graphics_handle& p);

  ~properties (void) { }

  void set (const caseless_str& pname, const octave_value& val);

  octave_value get (bool all = false) const;

  octave_value get (const caseless_str& pname) const;

  octave_value get (const std::string& pname) const
  {
    return get (caseless_str (pname));
  }

  octave_value get (const char *pname) const
  {
    return get (caseless_str (pname));
  }

  property get_property (const caseless_str& pname);

  std::string graphics_object_name (void) const { return go_name; }

  static property_list::pval_map_type factory_defaults (void);

private:
  static std::string go_name;

public:


  static std::set<std::string> core_property_names (void);

  static bool has_core_property (const caseless_str& pname);

  std::set<std::string> all_property_names (void) const;

  bool has_property (const caseless_str& pname) const;

private:

  any_property __plot_stream__;
  bool_property __enhanced__;
  radio_property nextplot;
  callback_property closerequestfcn;
  handle_property currentaxes;
  array_property colormap;
  radio_property paperorientation;
  color_property color;
  array_property alphamap;
  string_property currentcharacter;
  handle_property currentobject;
  array_property currentpoint;
  bool_property dockcontrols;
  bool_property doublebuffer;
  string_property filename;
  bool_property integerhandle;
  bool_property inverthardcopy;
  callback_property keypressfcn;
  callback_property keyreleasefcn;
  radio_property menubar;
  double_property mincolormap;
  string_property name;
  bool_property numbertitle;
  array_property outerposition;
  radio_property paperunits;
  array_property paperposition;
  radio_property paperpositionmode;
  array_property papersize;
  radio_property papertype;
  radio_property pointer;
  array_property pointershapecdata;
  array_property pointershapehotspot;
  array_property position;
  radio_property renderer;
  radio_property renderermode;
  bool_property resize;
  callback_property resizefcn;
  radio_property selectiontype;
  radio_property toolbar;
  radio_property units;
  callback_property windowbuttondownfcn;
  callback_property windowbuttonmotionfcn;
  callback_property windowbuttonupfcn;
  callback_property windowbuttonwheelfcn;
  radio_property windowstyle;
  string_property wvisual;
  radio_property wvisualmode;
  string_property xdisplay;
  string_property xvisual;
  radio_property xvisualmode;
  callback_property buttondownfcn;
  string_property __graphics_toolkit__;
  any_property __guidata__;

public:

  enum
  {
    ID___PLOT_STREAM__ = 2000,
    ID___ENHANCED__ = 2001,
    ID_NEXTPLOT = 2002,
    ID_CLOSEREQUESTFCN = 2003,
    ID_CURRENTAXES = 2004,
    ID_COLORMAP = 2005,
    ID_PAPERORIENTATION = 2006,
    ID_COLOR = 2007,
    ID_ALPHAMAP = 2008,
    ID_CURRENTCHARACTER = 2009,
    ID_CURRENTOBJECT = 2010,
    ID_CURRENTPOINT = 2011,
    ID_DOCKCONTROLS = 2012,
    ID_DOUBLEBUFFER = 2013,
    ID_FILENAME = 2014,
    ID_INTEGERHANDLE = 2015,
    ID_INVERTHARDCOPY = 2016,
    ID_KEYPRESSFCN = 2017,
    ID_KEYRELEASEFCN = 2018,
    ID_MENUBAR = 2019,
    ID_MINCOLORMAP = 2020,
    ID_NAME = 2021,
    ID_NUMBERTITLE = 2022,
    ID_OUTERPOSITION = 2023,
    ID_PAPERUNITS = 2024,
    ID_PAPERPOSITION = 2025,
    ID_PAPERPOSITIONMODE = 2026,
    ID_PAPERSIZE = 2027,
    ID_PAPERTYPE = 2028,
    ID_POINTER = 2029,
    ID_POINTERSHAPECDATA = 2030,
    ID_POINTERSHAPEHOTSPOT = 2031,
    ID_POSITION = 2032,
    ID_RENDERER = 2033,
    ID_RENDERERMODE = 2034,
    ID_RESIZE = 2035,
    ID_RESIZEFCN = 2036,
    ID_SELECTIONTYPE = 2037,
    ID_TOOLBAR = 2038,
    ID_UNITS = 2039,
    ID_WINDOWBUTTONDOWNFCN = 2040,
    ID_WINDOWBUTTONMOTIONFCN = 2041,
    ID_WINDOWBUTTONUPFCN = 2042,
    ID_WINDOWBUTTONWHEELFCN = 2043,
    ID_WINDOWSTYLE = 2044,
    ID_WVISUAL = 2045,
    ID_WVISUALMODE = 2046,
    ID_XDISPLAY = 2047,
    ID_XVISUAL = 2048,
    ID_XVISUALMODE = 2049,
    ID_BUTTONDOWNFCN = 2050,
    ID___GRAPHICS_TOOLKIT__ = 2051,
    ID___GUIDATA__ = 2052
  };

  octave_value get___plot_stream__ (void) const { return __plot_stream__.get (); }

  bool is___enhanced__ (void) const { return __enhanced__.is_on (); }
  std::string get___enhanced__ (void) const { return __enhanced__.current_value (); }

  bool nextplot_is (const std::string& v) const { return nextplot.is (v); }
  std::string get_nextplot (void) const { return nextplot.current_value (); }

  void execute_closerequestfcn (const octave_value& data = octave_value ()) const { closerequestfcn.execute (data); }
  octave_value get_closerequestfcn (void) const { return closerequestfcn.get (); }

  graphics_handle get_currentaxes (void) const { return currentaxes.handle_value (); }

  octave_value get_colormap (void) const { return colormap.get (); }

  bool paperorientation_is (const std::string& v) const { return paperorientation.is (v); }
  std::string get_paperorientation (void) const { return paperorientation.current_value (); }

  bool color_is_rgb (void) const { return color.is_rgb (); }
  bool color_is (const std::string& v) const { return color.is (v); }
  Matrix get_color_rgb (void) const { return (color.is_rgb () ? color.rgb () : Matrix ()); }
  octave_value get_color (void) const { return color.get (); }

  octave_value get_alphamap (void) const { return alphamap.get (); }

  std::string get_currentcharacter (void) const { return currentcharacter.string_value (); }

  graphics_handle get_currentobject (void) const { return currentobject.handle_value (); }

  octave_value get_currentpoint (void) const { return currentpoint.get (); }

  bool is_dockcontrols (void) const { return dockcontrols.is_on (); }
  std::string get_dockcontrols (void) const { return dockcontrols.current_value (); }

  bool is_doublebuffer (void) const { return doublebuffer.is_on (); }
  std::string get_doublebuffer (void) const { return doublebuffer.current_value (); }

  std::string get_filename (void) const { return filename.string_value (); }

  bool is_integerhandle (void) const { return integerhandle.is_on (); }
  std::string get_integerhandle (void) const { return integerhandle.current_value (); }

  bool is_inverthardcopy (void) const { return inverthardcopy.is_on (); }
  std::string get_inverthardcopy (void) const { return inverthardcopy.current_value (); }

  void execute_keypressfcn (const octave_value& data = octave_value ()) const { keypressfcn.execute (data); }
  octave_value get_keypressfcn (void) const { return keypressfcn.get (); }

  void execute_keyreleasefcn (const octave_value& data = octave_value ()) const { keyreleasefcn.execute (data); }
  octave_value get_keyreleasefcn (void) const { return keyreleasefcn.get (); }

  bool menubar_is (const std::string& v) const { return menubar.is (v); }
  std::string get_menubar (void) const { return menubar.current_value (); }

  double get_mincolormap (void) const { return mincolormap.double_value (); }

  std::string get_name (void) const { return name.string_value (); }

  bool is_numbertitle (void) const { return numbertitle.is_on (); }
  std::string get_numbertitle (void) const { return numbertitle.current_value (); }

  octave_value get_outerposition (void) const { return outerposition.get (); }

  bool paperunits_is (const std::string& v) const { return paperunits.is (v); }
  std::string get_paperunits (void) const { return paperunits.current_value (); }

  octave_value get_paperposition (void) const { return paperposition.get (); }

  bool paperpositionmode_is (const std::string& v) const { return paperpositionmode.is (v); }
  std::string get_paperpositionmode (void) const { return paperpositionmode.current_value (); }

  octave_value get_papersize (void) const { return papersize.get (); }

  bool papertype_is (const std::string& v) const { return papertype.is (v); }
  std::string get_papertype (void) const { return papertype.current_value (); }

  bool pointer_is (const std::string& v) const { return pointer.is (v); }
  std::string get_pointer (void) const { return pointer.current_value (); }

  octave_value get_pointershapecdata (void) const { return pointershapecdata.get (); }

  octave_value get_pointershapehotspot (void) const { return pointershapehotspot.get (); }

  octave_value get_position (void) const { return position.get (); }

  bool renderer_is (const std::string& v) const { return renderer.is (v); }
  std::string get_renderer (void) const { return renderer.current_value (); }

  bool renderermode_is (const std::string& v) const { return renderermode.is (v); }
  std::string get_renderermode (void) const { return renderermode.current_value (); }

  bool is_resize (void) const { return resize.is_on (); }
  std::string get_resize (void) const { return resize.current_value (); }

  void execute_resizefcn (const octave_value& data = octave_value ()) const { resizefcn.execute (data); }
  octave_value get_resizefcn (void) const { return resizefcn.get (); }

  bool selectiontype_is (const std::string& v) const { return selectiontype.is (v); }
  std::string get_selectiontype (void) const { return selectiontype.current_value (); }

  bool toolbar_is (const std::string& v) const { return toolbar.is (v); }
  std::string get_toolbar (void) const { return toolbar.current_value (); }

  bool units_is (const std::string& v) const { return units.is (v); }
  std::string get_units (void) const { return units.current_value (); }

  void execute_windowbuttondownfcn (const octave_value& data = octave_value ()) const { windowbuttondownfcn.execute (data); }
  octave_value get_windowbuttondownfcn (void) const { return windowbuttondownfcn.get (); }

  void execute_windowbuttonmotionfcn (const octave_value& data = octave_value ()) const { windowbuttonmotionfcn.execute (data); }
  octave_value get_windowbuttonmotionfcn (void) const { return windowbuttonmotionfcn.get (); }

  void execute_windowbuttonupfcn (const octave_value& data = octave_value ()) const { windowbuttonupfcn.execute (data); }
  octave_value get_windowbuttonupfcn (void) const { return windowbuttonupfcn.get (); }

  void execute_windowbuttonwheelfcn (const octave_value& data = octave_value ()) const { windowbuttonwheelfcn.execute (data); }
  octave_value get_windowbuttonwheelfcn (void) const { return windowbuttonwheelfcn.get (); }

  bool windowstyle_is (const std::string& v) const { return windowstyle.is (v); }
  std::string get_windowstyle (void) const { return windowstyle.current_value (); }

  std::string get_wvisual (void) const { return wvisual.string_value (); }

  bool wvisualmode_is (const std::string& v) const { return wvisualmode.is (v); }
  std::string get_wvisualmode (void) const { return wvisualmode.current_value (); }

  std::string get_xdisplay (void) const { return xdisplay.string_value (); }

  std::string get_xvisual (void) const { return xvisual.string_value (); }

  bool xvisualmode_is (const std::string& v) const { return xvisualmode.is (v); }
  std::string get_xvisualmode (void) const { return xvisualmode.current_value (); }

  void execute_buttondownfcn (const octave_value& data = octave_value ()) const { buttondownfcn.execute (data); }
  octave_value get_buttondownfcn (void) const { return buttondownfcn.get (); }

  std::string get___graphics_toolkit__ (void) const { return __graphics_toolkit__.string_value (); }

  octave_value get___guidata__ (void) const { return __guidata__.get (); }


  void set___plot_stream__ (const octave_value& val)
  {
    if (! error_state)
      {
        if (__plot_stream__.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set___enhanced__ (const octave_value& val)
  {
    if (! error_state)
      {
        if (__enhanced__.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_nextplot (const octave_value& val)
  {
    if (! error_state)
      {
        if (nextplot.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_closerequestfcn (const octave_value& val)
  {
    if (! error_state)
      {
        if (closerequestfcn.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_currentaxes (const octave_value& val);

  void set_colormap (const octave_value& val)
  {
    if (! error_state)
      {
        if (colormap.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_paperorientation (const octave_value& val)
  {
    if (! error_state)
      {
        if (paperorientation.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_color (const octave_value& val)
  {
    if (! error_state)
      {
        if (color.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_alphamap (const octave_value& val)
  {
    if (! error_state)
      {
        if (alphamap.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_currentcharacter (const octave_value& val)
  {
    if (! error_state)
      {
        if (currentcharacter.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_currentobject (const octave_value& val)
  {
    if (! error_state)
      {
        if (currentobject.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_currentpoint (const octave_value& val)
  {
    if (! error_state)
      {
        if (currentpoint.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_dockcontrols (const octave_value& val)
  {
    if (! error_state)
      {
        if (dockcontrols.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_doublebuffer (const octave_value& val)
  {
    if (! error_state)
      {
        if (doublebuffer.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_filename (const octave_value& val)
  {
    if (! error_state)
      {
        if (filename.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_integerhandle (const octave_value& val);

  void set_inverthardcopy (const octave_value& val)
  {
    if (! error_state)
      {
        if (inverthardcopy.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_keypressfcn (const octave_value& val)
  {
    if (! error_state)
      {
        if (keypressfcn.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_keyreleasefcn (const octave_value& val)
  {
    if (! error_state)
      {
        if (keyreleasefcn.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_menubar (const octave_value& val)
  {
    if (! error_state)
      {
        if (menubar.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_mincolormap (const octave_value& val)
  {
    if (! error_state)
      {
        if (mincolormap.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_name (const octave_value& val)
  {
    if (! error_state)
      {
        if (name.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_numbertitle (const octave_value& val)
  {
    if (! error_state)
      {
        if (numbertitle.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_paperunits (const octave_value& val);

  void set_paperposition (const octave_value& val)
  {
    if (! error_state)
      {
        if (paperposition.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_paperpositionmode (const octave_value& val)
  {
    if (! error_state)
      {
        if (paperpositionmode.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_papersize (const octave_value& val)
  {
    if (! error_state)
      {
        if (papersize.set (val, true))
          {
            update_papersize ();
            mark_modified ();
          }
      }
  }

  void update_papersize (void);

  void set_papertype (const octave_value& val);

  void update_papertype (void);

  void set_pointer (const octave_value& val)
  {
    if (! error_state)
      {
        if (pointer.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_pointershapecdata (const octave_value& val)
  {
    if (! error_state)
      {
        if (pointershapecdata.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_pointershapehotspot (const octave_value& val)
  {
    if (! error_state)
      {
        if (pointershapehotspot.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_renderer (const octave_value& val)
  {
    if (! error_state)
      {
        if (renderer.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_renderermode (const octave_value& val)
  {
    if (! error_state)
      {
        if (renderermode.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_resize (const octave_value& val)
  {
    if (! error_state)
      {
        if (resize.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_resizefcn (const octave_value& val)
  {
    if (! error_state)
      {
        if (resizefcn.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_selectiontype (const octave_value& val)
  {
    if (! error_state)
      {
        if (selectiontype.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_toolbar (const octave_value& val)
  {
    if (! error_state)
      {
        if (toolbar.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_units (const octave_value& val);

  void set_windowbuttondownfcn (const octave_value& val)
  {
    if (! error_state)
      {
        if (windowbuttondownfcn.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_windowbuttonmotionfcn (const octave_value& val)
  {
    if (! error_state)
      {
        if (windowbuttonmotionfcn.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_windowbuttonupfcn (const octave_value& val)
  {
    if (! error_state)
      {
        if (windowbuttonupfcn.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_windowbuttonwheelfcn (const octave_value& val)
  {
    if (! error_state)
      {
        if (windowbuttonwheelfcn.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_windowstyle (const octave_value& val)
  {
    if (! error_state)
      {
        if (windowstyle.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_wvisual (const octave_value& val)
  {
    if (! error_state)
      {
        if (wvisual.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_wvisualmode (const octave_value& val)
  {
    if (! error_state)
      {
        if (wvisualmode.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_xdisplay (const octave_value& val)
  {
    if (! error_state)
      {
        if (xdisplay.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_xvisual (const octave_value& val)
  {
    if (! error_state)
      {
        if (xvisual.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_xvisualmode (const octave_value& val)
  {
    if (! error_state)
      {
        if (xvisualmode.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_buttondownfcn (const octave_value& val)
  {
    if (! error_state)
      {
        if (buttondownfcn.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set___guidata__ (const octave_value& val)
  {
    if (! error_state)
      {
        if (__guidata__.set (val, true))
          {
            mark_modified ();
          }
      }
  }


  protected:
    void init (void)
      {
        colormap.add_constraint (dim_vector (-1, 3));
        alphamap.add_constraint (dim_vector (-1, 1));
        paperposition.add_constraint (dim_vector (1, 4));
        pointershapecdata.add_constraint (dim_vector (16, 16));
        pointershapehotspot.add_constraint (dim_vector (1, 2));
        position.add_constraint (dim_vector (1, 4));
        outerposition.add_constraint (dim_vector (1, 4));
      }

  private:
    mutable graphics_toolkit toolkit;
  };

private:
  properties xproperties;

public:
  figure (const graphics_handle& mh, const graphics_handle& p)
    : base_graphics_object (), xproperties (mh, p), default_properties ()
  {
    xproperties.override_defaults (*this);
  }

  ~figure (void) { }

  void override_defaults (base_graphics_object& obj)
  {
    // Allow parent (root figure) to override first (properties knows how
    // to find the parent object).
    xproperties.override_defaults (obj);

    // Now override with our defaults.  If the default_properties
    // list includes the properties for all defaults (line,
    // surface, etc.) then we don't have to know the type of OBJ
    // here, we just call its set function and let it decide which
    // properties from the list to use.
    obj.set_from_list (default_properties);
  }

  void set (const caseless_str& name, const octave_value& value)
  {
    if (name.compare ("default", 7))
      // strip "default", pass rest to function that will
      // parse the remainder and add the element to the
      // default_properties map.
      default_properties.set (name.substr (7), value);
    else
      xproperties.set (name, value);
  }

  octave_value get (const caseless_str& name) const
  {
    octave_value retval;

    if (name.compare ("default", 7))
      retval = get_default (name.substr (7));
    else
      retval = xproperties.get (name);

    return retval;
  }

  octave_value get_default (const caseless_str& name) const;

  octave_value get_defaults (void) const
  {
    return default_properties.as_struct ("default");
  }

  base_properties& get_properties (void) { return xproperties; }

  const base_properties& get_properties (void) const { return xproperties; }

  bool valid_object (void) const { return true; }

  void reset_default_properties (void);

private:
  property_list default_properties;
};

// ---------------------------------------------------------------------

class OCTINTERP_API graphics_xform
{
public:
  graphics_xform (void)
    : xform (xform_eye ()), xform_inv (xform_eye ()),
      sx ("linear"), sy ("linear"), sz ("linear"),  zlim (1, 2, 0.0)
    {
      zlim(1) = 1.0;
    }

  graphics_xform (const Matrix& xm, const Matrix& xim,
                  const scaler& x, const scaler& y, const scaler& z,
                  const Matrix& zl)
      : xform (xm), xform_inv (xim), sx (x), sy (y), sz (z), zlim (zl) { }

  graphics_xform (const graphics_xform& g)
      : xform (g.xform), xform_inv (g.xform_inv), sx (g.sx),
        sy (g.sy), sz (g.sz), zlim (g.zlim) { }

  ~graphics_xform (void) { }

  graphics_xform& operator = (const graphics_xform& g)
    {
      xform = g.xform;
      xform_inv = g.xform_inv;
      sx = g.sx;
      sy = g.sy;
      sz = g.sz;
      zlim = g.zlim;

      return *this;
    }

  static ColumnVector xform_vector (double x, double y, double z);

  static Matrix xform_eye (void);

  ColumnVector transform (double x, double y, double z,
                          bool use_scale = true) const;

  ColumnVector untransform (double x, double y, double z,
                            bool use_scale = true) const;

  ColumnVector untransform (double x, double y, bool use_scale = true) const
    { return untransform (x, y, (zlim(0)+zlim(1))/2, use_scale); }

  Matrix xscale (const Matrix& m) const { return sx.scale (m); }
  Matrix yscale (const Matrix& m) const { return sy.scale (m); }
  Matrix zscale (const Matrix& m) const { return sz.scale (m); }

  Matrix scale (const Matrix& m) const
    {
      bool has_z = (m.columns () > 2);

      if (sx.is_linear () && sy.is_linear ()
          && (! has_z || sz.is_linear ()))
        return m;

      Matrix retval (m.dims ());

      int r = m.rows ();

      for (int i = 0; i < r; i++)
        {
          retval(i,0) = sx.scale (m(i,0));
          retval(i,1) = sy.scale (m(i,1));
          if (has_z)
            retval(i,2) = sz.scale (m(i,2));
        }

      return retval;
    }

private:
  Matrix xform;
  Matrix xform_inv;
  scaler sx, sy, sz;
  Matrix zlim;
};

enum {
  AXE_ANY_DIR   = 0,
  AXE_DEPTH_DIR = 1,
  AXE_HORZ_DIR  = 2,
  AXE_VERT_DIR  = 3
};

class OCTINTERP_API axes : public base_graphics_object
{
public:
  class OCTINTERP_API properties : public base_properties
  {
  public:
    void set_defaults (base_graphics_object& obj, const std::string& mode);

    void remove_child (const graphics_handle& h);

    const scaler& get_x_scaler (void) const { return sx; }
    const scaler& get_y_scaler (void) const { return sy; }
    const scaler& get_z_scaler (void) const { return sz; }

    Matrix get_boundingbox (bool internal = false,
                            const Matrix& parent_pix_size = Matrix ()) const;
    Matrix get_extent (bool with_text = false, bool only_text_height=false) const;

    double get_fontsize_points (double box_pix_height = 0) const;

    void update_boundingbox (void)
      {
        if (units_is ("normalized"))
          {
            sync_positions ();
            base_properties::update_boundingbox ();
          }
      }

    void update_camera (void);
    void update_axes_layout (void);
    void update_aspectratios (void);
    void update_transform (void)
      {
        update_aspectratios ();
        update_camera ();
        update_axes_layout ();
      }

    void update_autopos (const std::string& elem_type);
    void update_xlabel_position (void);
    void update_ylabel_position (void);
    void update_zlabel_position (void);
    void update_title_position (void);

    graphics_xform get_transform (void) const
      { return graphics_xform (x_render, x_render_inv, sx, sy, sz, x_zlim); }

    Matrix get_transform_matrix (void) const { return x_render; }
    Matrix get_inverse_transform_matrix (void) const { return x_render_inv; }
    Matrix get_opengl_matrix_1 (void) const { return x_gl_mat1; }
    Matrix get_opengl_matrix_2 (void) const { return x_gl_mat2; }
    Matrix get_transform_zlim (void) const { return x_zlim; }

    int get_xstate (void) const { return xstate; }
    int get_ystate (void) const { return ystate; }
    int get_zstate (void) const { return zstate; }
    double get_xPlane (void) const { return xPlane; }
    double get_xPlaneN (void) const { return xPlaneN; }
    double get_yPlane (void) const { return yPlane; }
    double get_yPlaneN (void) const { return yPlaneN; }
    double get_zPlane (void) const { return zPlane; }
    double get_zPlaneN (void) const { return zPlaneN; }
    double get_xpTick (void) const { return xpTick; }
    double get_xpTickN (void) const { return xpTickN; }
    double get_ypTick (void) const { return ypTick; }
    double get_ypTickN (void) const { return ypTickN; }
    double get_zpTick (void) const { return zpTick; }
    double get_zpTickN (void) const { return zpTickN; }
    double get_x_min (void) const { return std::min (xPlane, xPlaneN); }
    double get_x_max (void) const { return std::max (xPlane, xPlaneN); }
    double get_y_min (void) const { return std::min (yPlane, yPlaneN); }
    double get_y_max (void) const { return std::max (yPlane, yPlaneN); }
    double get_z_min (void) const { return std::min (zPlane, zPlaneN); }
    double get_z_max (void) const { return std::max (zPlane, zPlaneN); }
    double get_fx (void) const { return fx; }
    double get_fy (void) const { return fy; }
    double get_fz (void) const { return fz; }
    double get_xticklen (void) const { return xticklen; }
    double get_yticklen (void) const { return yticklen; }
    double get_zticklen (void) const { return zticklen; }
    double get_xtickoffset (void) const { return xtickoffset; }
    double get_ytickoffset (void) const { return ytickoffset; }
    double get_ztickoffset (void) const { return ztickoffset; }
    bool get_x2Dtop (void) const { return x2Dtop; }
    bool get_y2Dright (void) const { return y2Dright; }
    bool get_layer2Dtop (void) const { return layer2Dtop; }
    bool get_xySym (void) const { return xySym; }
    bool get_xyzSym (void) const { return xyzSym; }
    bool get_zSign (void) const { return zSign; }
    bool get_nearhoriz (void) const { return nearhoriz; }

    ColumnVector pixel2coord (double px, double py) const
    { return get_transform ().untransform (px, py, (x_zlim(0)+x_zlim(1))/2); }

    ColumnVector coord2pixel (double x, double y, double z) const
    { return get_transform ().transform (x, y, z); }

    void zoom_about_point (double x, double y, double factor,
                           bool push_to_zoom_stack = true);
    void zoom (const Matrix& xl, const Matrix& yl, bool push_to_zoom_stack = true);
    void translate_view (double delta_x, double delta_y);
    void rotate_view (double delta_az, double delta_el);
    void unzoom (void);
    void clear_zoom_stack (void);

    void update_units (const caseless_str& old_units);

    void update_fontunits (const caseless_str& old_fontunits);

  private:
    scaler sx, sy, sz;
    Matrix x_render, x_render_inv;
    Matrix x_gl_mat1, x_gl_mat2;
    Matrix x_zlim;
    std::list<octave_value> zoom_stack;

    // Axes layout data
    int xstate, ystate, zstate;
    double xPlane, xPlaneN, yPlane, yPlaneN, zPlane, zPlaneN;
    double xpTick, xpTickN, ypTick, ypTickN, zpTick, zpTickN;
    double fx, fy, fz;
    double xticklen, yticklen, zticklen;
    double xtickoffset, ytickoffset, ztickoffset;
    bool x2Dtop, y2Dright, layer2Dtop;
    bool xySym, xyzSym, zSign, nearhoriz;

#if HAVE_FREETYPE
    // freetype renderer, used for calculation of text (tick labels) size
    ft_render text_renderer;
#endif

    void set_text_child (handle_property& h, const std::string& who,
                         const octave_value& v);

    void delete_text_child (handle_property& h);

    // See the genprops.awk script for an explanation of the
    // properties declarations.

    // properties which are not in matlab: interpreter

public:
  properties (const graphics_handle& mh, const graphics_handle& p);

  ~properties (void) { }

  void set (const caseless_str& pname, const octave_value& val);

  octave_value get (bool all = false) const;

  octave_value get (const caseless_str& pname) const;

  octave_value get (const std::string& pname) const
  {
    return get (caseless_str (pname));
  }

  octave_value get (const char *pname) const
  {
    return get (caseless_str (pname));
  }

  property get_property (const caseless_str& pname);

  std::string graphics_object_name (void) const { return go_name; }

  static property_list::pval_map_type factory_defaults (void);

private:
  static std::string go_name;

public:


  static std::set<std::string> core_property_names (void);

  static bool has_core_property (const caseless_str& pname);

  std::set<std::string> all_property_names (void) const;

  bool has_property (const caseless_str& pname) const;

private:

  array_property position;
  bool_property box;
  array_property colororder;
  array_property dataaspectratio;
  radio_property dataaspectratiomode;
  radio_property layer;
  row_vector_property xlim;
  row_vector_property ylim;
  row_vector_property zlim;
  row_vector_property clim;
  row_vector_property alim;
  radio_property xlimmode;
  radio_property ylimmode;
  radio_property zlimmode;
  radio_property climmode;
  radio_property alimmode;
  handle_property xlabel;
  handle_property ylabel;
  handle_property zlabel;
  handle_property title;
  bool_property xgrid;
  bool_property ygrid;
  bool_property zgrid;
  bool_property xminorgrid;
  bool_property yminorgrid;
  bool_property zminorgrid;
  row_vector_property xtick;
  row_vector_property ytick;
  row_vector_property ztick;
  radio_property xtickmode;
  radio_property ytickmode;
  radio_property ztickmode;
  bool_property xminortick;
  bool_property yminortick;
  bool_property zminortick;
  any_property xticklabel;
  any_property yticklabel;
  any_property zticklabel;
  radio_property xticklabelmode;
  radio_property yticklabelmode;
  radio_property zticklabelmode;
  radio_property interpreter;
  color_property color;
  color_property xcolor;
  color_property ycolor;
  color_property zcolor;
  radio_property xscale;
  radio_property yscale;
  radio_property zscale;
  radio_property xdir;
  radio_property ydir;
  radio_property zdir;
  radio_property yaxislocation;
  radio_property xaxislocation;
  array_property view;
  bool_property __hold_all__;
  radio_property nextplot;
  array_property outerposition;
  radio_property activepositionproperty;
  color_property ambientlightcolor;
  array_property cameraposition;
  array_property cameratarget;
  array_property cameraupvector;
  double_property cameraviewangle;
  radio_property camerapositionmode;
  radio_property cameratargetmode;
  radio_property cameraupvectormode;
  radio_property cameraviewanglemode;
  array_property currentpoint;
  radio_property drawmode;
  radio_property fontangle;
  string_property fontname;
  double_property fontsize;
  radio_property fontunits;
  radio_property fontweight;
  radio_property gridlinestyle;
  string_array_property linestyleorder;
  double_property linewidth;
  radio_property minorgridlinestyle;
  array_property plotboxaspectratio;
  radio_property plotboxaspectratiomode;
  radio_property projection;
  radio_property tickdir;
  radio_property tickdirmode;
  array_property ticklength;
  array_property tightinset;
  radio_property units;
  array_property x_viewtransform;
  array_property x_projectiontransform;
  array_property x_viewporttransform;
  array_property x_normrendertransform;
  array_property x_rendertransform;
  row_vector_property xmtick;
  row_vector_property ymtick;
  row_vector_property zmtick;
  array_property looseinset;
  radio_property autopos_tag;

public:

  enum
  {
    ID_POSITION = 3000,
    ID_BOX = 3001,
    ID_COLORORDER = 3002,
    ID_DATAASPECTRATIO = 3003,
    ID_DATAASPECTRATIOMODE = 3004,
    ID_LAYER = 3005,
    ID_XLIM = 3006,
    ID_YLIM = 3007,
    ID_ZLIM = 3008,
    ID_CLIM = 3009,
    ID_ALIM = 3010,
    ID_XLIMMODE = 3011,
    ID_YLIMMODE = 3012,
    ID_ZLIMMODE = 3013,
    ID_CLIMMODE = 3014,
    ID_ALIMMODE = 3015,
    ID_XLABEL = 3016,
    ID_YLABEL = 3017,
    ID_ZLABEL = 3018,
    ID_TITLE = 3019,
    ID_XGRID = 3020,
    ID_YGRID = 3021,
    ID_ZGRID = 3022,
    ID_XMINORGRID = 3023,
    ID_YMINORGRID = 3024,
    ID_ZMINORGRID = 3025,
    ID_XTICK = 3026,
    ID_YTICK = 3027,
    ID_ZTICK = 3028,
    ID_XTICKMODE = 3029,
    ID_YTICKMODE = 3030,
    ID_ZTICKMODE = 3031,
    ID_XMINORTICK = 3032,
    ID_YMINORTICK = 3033,
    ID_ZMINORTICK = 3034,
    ID_XTICKLABEL = 3035,
    ID_YTICKLABEL = 3036,
    ID_ZTICKLABEL = 3037,
    ID_XTICKLABELMODE = 3038,
    ID_YTICKLABELMODE = 3039,
    ID_ZTICKLABELMODE = 3040,
    ID_INTERPRETER = 3041,
    ID_COLOR = 3042,
    ID_XCOLOR = 3043,
    ID_YCOLOR = 3044,
    ID_ZCOLOR = 3045,
    ID_XSCALE = 3046,
    ID_YSCALE = 3047,
    ID_ZSCALE = 3048,
    ID_XDIR = 3049,
    ID_YDIR = 3050,
    ID_ZDIR = 3051,
    ID_YAXISLOCATION = 3052,
    ID_XAXISLOCATION = 3053,
    ID_VIEW = 3054,
    ID___HOLD_ALL__ = 3055,
    ID_NEXTPLOT = 3056,
    ID_OUTERPOSITION = 3057,
    ID_ACTIVEPOSITIONPROPERTY = 3058,
    ID_AMBIENTLIGHTCOLOR = 3059,
    ID_CAMERAPOSITION = 3060,
    ID_CAMERATARGET = 3061,
    ID_CAMERAUPVECTOR = 3062,
    ID_CAMERAVIEWANGLE = 3063,
    ID_CAMERAPOSITIONMODE = 3064,
    ID_CAMERATARGETMODE = 3065,
    ID_CAMERAUPVECTORMODE = 3066,
    ID_CAMERAVIEWANGLEMODE = 3067,
    ID_CURRENTPOINT = 3068,
    ID_DRAWMODE = 3069,
    ID_FONTANGLE = 3070,
    ID_FONTNAME = 3071,
    ID_FONTSIZE = 3072,
    ID_FONTUNITS = 3073,
    ID_FONTWEIGHT = 3074,
    ID_GRIDLINESTYLE = 3075,
    ID_LINESTYLEORDER = 3076,
    ID_LINEWIDTH = 3077,
    ID_MINORGRIDLINESTYLE = 3078,
    ID_PLOTBOXASPECTRATIO = 3079,
    ID_PLOTBOXASPECTRATIOMODE = 3080,
    ID_PROJECTION = 3081,
    ID_TICKDIR = 3082,
    ID_TICKDIRMODE = 3083,
    ID_TICKLENGTH = 3084,
    ID_TIGHTINSET = 3085,
    ID_UNITS = 3086,
    ID_X_VIEWTRANSFORM = 3087,
    ID_X_PROJECTIONTRANSFORM = 3088,
    ID_X_VIEWPORTTRANSFORM = 3089,
    ID_X_NORMRENDERTRANSFORM = 3090,
    ID_X_RENDERTRANSFORM = 3091,
    ID_XMTICK = 3092,
    ID_YMTICK = 3093,
    ID_ZMTICK = 3094,
    ID_LOOSEINSET = 3095,
    ID_AUTOPOS_TAG = 3096
  };

  octave_value get_position (void) const { return position.get (); }

  bool is_box (void) const { return box.is_on (); }
  std::string get_box (void) const { return box.current_value (); }

  octave_value get_colororder (void) const { return colororder.get (); }

  octave_value get_dataaspectratio (void) const { return dataaspectratio.get (); }

  bool dataaspectratiomode_is (const std::string& v) const { return dataaspectratiomode.is (v); }
  std::string get_dataaspectratiomode (void) const { return dataaspectratiomode.current_value (); }

  bool layer_is (const std::string& v) const { return layer.is (v); }
  std::string get_layer (void) const { return layer.current_value (); }

  octave_value get_xlim (void) const { return xlim.get (); }

  octave_value get_ylim (void) const { return ylim.get (); }

  octave_value get_zlim (void) const { return zlim.get (); }

  octave_value get_clim (void) const { return clim.get (); }

  octave_value get_alim (void) const { return alim.get (); }

  bool xlimmode_is (const std::string& v) const { return xlimmode.is (v); }
  std::string get_xlimmode (void) const { return xlimmode.current_value (); }

  bool ylimmode_is (const std::string& v) const { return ylimmode.is (v); }
  std::string get_ylimmode (void) const { return ylimmode.current_value (); }

  bool zlimmode_is (const std::string& v) const { return zlimmode.is (v); }
  std::string get_zlimmode (void) const { return zlimmode.current_value (); }

  bool climmode_is (const std::string& v) const { return climmode.is (v); }
  std::string get_climmode (void) const { return climmode.current_value (); }

  bool alimmode_is (const std::string& v) const { return alimmode.is (v); }
  std::string get_alimmode (void) const { return alimmode.current_value (); }

  graphics_handle get_xlabel (void) const { return xlabel.handle_value (); }

  graphics_handle get_ylabel (void) const { return ylabel.handle_value (); }

  graphics_handle get_zlabel (void) const { return zlabel.handle_value (); }

  graphics_handle get_title (void) const { return title.handle_value (); }

  bool is_xgrid (void) const { return xgrid.is_on (); }
  std::string get_xgrid (void) const { return xgrid.current_value (); }

  bool is_ygrid (void) const { return ygrid.is_on (); }
  std::string get_ygrid (void) const { return ygrid.current_value (); }

  bool is_zgrid (void) const { return zgrid.is_on (); }
  std::string get_zgrid (void) const { return zgrid.current_value (); }

  bool is_xminorgrid (void) const { return xminorgrid.is_on (); }
  std::string get_xminorgrid (void) const { return xminorgrid.current_value (); }

  bool is_yminorgrid (void) const { return yminorgrid.is_on (); }
  std::string get_yminorgrid (void) const { return yminorgrid.current_value (); }

  bool is_zminorgrid (void) const { return zminorgrid.is_on (); }
  std::string get_zminorgrid (void) const { return zminorgrid.current_value (); }

  octave_value get_xtick (void) const { return xtick.get (); }

  octave_value get_ytick (void) const { return ytick.get (); }

  octave_value get_ztick (void) const { return ztick.get (); }

  bool xtickmode_is (const std::string& v) const { return xtickmode.is (v); }
  std::string get_xtickmode (void) const { return xtickmode.current_value (); }

  bool ytickmode_is (const std::string& v) const { return ytickmode.is (v); }
  std::string get_ytickmode (void) const { return ytickmode.current_value (); }

  bool ztickmode_is (const std::string& v) const { return ztickmode.is (v); }
  std::string get_ztickmode (void) const { return ztickmode.current_value (); }

  bool is_xminortick (void) const { return xminortick.is_on (); }
  std::string get_xminortick (void) const { return xminortick.current_value (); }

  bool is_yminortick (void) const { return yminortick.is_on (); }
  std::string get_yminortick (void) const { return yminortick.current_value (); }

  bool is_zminortick (void) const { return zminortick.is_on (); }
  std::string get_zminortick (void) const { return zminortick.current_value (); }

  octave_value get_xticklabel (void) const { return xticklabel.get (); }

  octave_value get_yticklabel (void) const { return yticklabel.get (); }

  octave_value get_zticklabel (void) const { return zticklabel.get (); }

  bool xticklabelmode_is (const std::string& v) const { return xticklabelmode.is (v); }
  std::string get_xticklabelmode (void) const { return xticklabelmode.current_value (); }

  bool yticklabelmode_is (const std::string& v) const { return yticklabelmode.is (v); }
  std::string get_yticklabelmode (void) const { return yticklabelmode.current_value (); }

  bool zticklabelmode_is (const std::string& v) const { return zticklabelmode.is (v); }
  std::string get_zticklabelmode (void) const { return zticklabelmode.current_value (); }

  bool interpreter_is (const std::string& v) const { return interpreter.is (v); }
  std::string get_interpreter (void) const { return interpreter.current_value (); }

  bool color_is_rgb (void) const { return color.is_rgb (); }
  bool color_is (const std::string& v) const { return color.is (v); }
  Matrix get_color_rgb (void) const { return (color.is_rgb () ? color.rgb () : Matrix ()); }
  octave_value get_color (void) const { return color.get (); }

  bool xcolor_is_rgb (void) const { return xcolor.is_rgb (); }
  bool xcolor_is (const std::string& v) const { return xcolor.is (v); }
  Matrix get_xcolor_rgb (void) const { return (xcolor.is_rgb () ? xcolor.rgb () : Matrix ()); }
  octave_value get_xcolor (void) const { return xcolor.get (); }

  bool ycolor_is_rgb (void) const { return ycolor.is_rgb (); }
  bool ycolor_is (const std::string& v) const { return ycolor.is (v); }
  Matrix get_ycolor_rgb (void) const { return (ycolor.is_rgb () ? ycolor.rgb () : Matrix ()); }
  octave_value get_ycolor (void) const { return ycolor.get (); }

  bool zcolor_is_rgb (void) const { return zcolor.is_rgb (); }
  bool zcolor_is (const std::string& v) const { return zcolor.is (v); }
  Matrix get_zcolor_rgb (void) const { return (zcolor.is_rgb () ? zcolor.rgb () : Matrix ()); }
  octave_value get_zcolor (void) const { return zcolor.get (); }

  bool xscale_is (const std::string& v) const { return xscale.is (v); }
  std::string get_xscale (void) const { return xscale.current_value (); }

  bool yscale_is (const std::string& v) const { return yscale.is (v); }
  std::string get_yscale (void) const { return yscale.current_value (); }

  bool zscale_is (const std::string& v) const { return zscale.is (v); }
  std::string get_zscale (void) const { return zscale.current_value (); }

  bool xdir_is (const std::string& v) const { return xdir.is (v); }
  std::string get_xdir (void) const { return xdir.current_value (); }

  bool ydir_is (const std::string& v) const { return ydir.is (v); }
  std::string get_ydir (void) const { return ydir.current_value (); }

  bool zdir_is (const std::string& v) const { return zdir.is (v); }
  std::string get_zdir (void) const { return zdir.current_value (); }

  bool yaxislocation_is (const std::string& v) const { return yaxislocation.is (v); }
  std::string get_yaxislocation (void) const { return yaxislocation.current_value (); }

  bool xaxislocation_is (const std::string& v) const { return xaxislocation.is (v); }
  std::string get_xaxislocation (void) const { return xaxislocation.current_value (); }

  octave_value get_view (void) const { return view.get (); }

  bool is___hold_all__ (void) const { return __hold_all__.is_on (); }
  std::string get___hold_all__ (void) const { return __hold_all__.current_value (); }

  bool nextplot_is (const std::string& v) const { return nextplot.is (v); }
  std::string get_nextplot (void) const { return nextplot.current_value (); }

  octave_value get_outerposition (void) const { return outerposition.get (); }

  bool activepositionproperty_is (const std::string& v) const { return activepositionproperty.is (v); }
  std::string get_activepositionproperty (void) const { return activepositionproperty.current_value (); }

  bool ambientlightcolor_is_rgb (void) const { return ambientlightcolor.is_rgb (); }
  bool ambientlightcolor_is (const std::string& v) const { return ambientlightcolor.is (v); }
  Matrix get_ambientlightcolor_rgb (void) const { return (ambientlightcolor.is_rgb () ? ambientlightcolor.rgb () : Matrix ()); }
  octave_value get_ambientlightcolor (void) const { return ambientlightcolor.get (); }

  octave_value get_cameraposition (void) const { return cameraposition.get (); }

  octave_value get_cameratarget (void) const { return cameratarget.get (); }

  octave_value get_cameraupvector (void) const { return cameraupvector.get (); }

  double get_cameraviewangle (void) const { return cameraviewangle.double_value (); }

  bool camerapositionmode_is (const std::string& v) const { return camerapositionmode.is (v); }
  std::string get_camerapositionmode (void) const { return camerapositionmode.current_value (); }

  bool cameratargetmode_is (const std::string& v) const { return cameratargetmode.is (v); }
  std::string get_cameratargetmode (void) const { return cameratargetmode.current_value (); }

  bool cameraupvectormode_is (const std::string& v) const { return cameraupvectormode.is (v); }
  std::string get_cameraupvectormode (void) const { return cameraupvectormode.current_value (); }

  bool cameraviewanglemode_is (const std::string& v) const { return cameraviewanglemode.is (v); }
  std::string get_cameraviewanglemode (void) const { return cameraviewanglemode.current_value (); }

  octave_value get_currentpoint (void) const { return currentpoint.get (); }

  bool drawmode_is (const std::string& v) const { return drawmode.is (v); }
  std::string get_drawmode (void) const { return drawmode.current_value (); }

  bool fontangle_is (const std::string& v) const { return fontangle.is (v); }
  std::string get_fontangle (void) const { return fontangle.current_value (); }

  std::string get_fontname (void) const { return fontname.string_value (); }

  double get_fontsize (void) const { return fontsize.double_value (); }

  bool fontunits_is (const std::string& v) const { return fontunits.is (v); }
  std::string get_fontunits (void) const { return fontunits.current_value (); }

  bool fontweight_is (const std::string& v) const { return fontweight.is (v); }
  std::string get_fontweight (void) const { return fontweight.current_value (); }

  bool gridlinestyle_is (const std::string& v) const { return gridlinestyle.is (v); }
  std::string get_gridlinestyle (void) const { return gridlinestyle.current_value (); }

  std::string get_linestyleorder_string (void) const { return linestyleorder.string_value (); }
  string_vector get_linestyleorder_vector (void) const { return linestyleorder.string_vector_value (); }
  octave_value get_linestyleorder (void) const { return linestyleorder.get (); }

  double get_linewidth (void) const { return linewidth.double_value (); }

  bool minorgridlinestyle_is (const std::string& v) const { return minorgridlinestyle.is (v); }
  std::string get_minorgridlinestyle (void) const { return minorgridlinestyle.current_value (); }

  octave_value get_plotboxaspectratio (void) const { return plotboxaspectratio.get (); }

  bool plotboxaspectratiomode_is (const std::string& v) const { return plotboxaspectratiomode.is (v); }
  std::string get_plotboxaspectratiomode (void) const { return plotboxaspectratiomode.current_value (); }

  bool projection_is (const std::string& v) const { return projection.is (v); }
  std::string get_projection (void) const { return projection.current_value (); }

  bool tickdir_is (const std::string& v) const { return tickdir.is (v); }
  std::string get_tickdir (void) const { return tickdir.current_value (); }

  bool tickdirmode_is (const std::string& v) const { return tickdirmode.is (v); }
  std::string get_tickdirmode (void) const { return tickdirmode.current_value (); }

  octave_value get_ticklength (void) const { return ticklength.get (); }

  octave_value get_tightinset (void) const { return tightinset.get (); }

  bool units_is (const std::string& v) const { return units.is (v); }
  std::string get_units (void) const { return units.current_value (); }

  octave_value get_x_viewtransform (void) const { return x_viewtransform.get (); }

  octave_value get_x_projectiontransform (void) const { return x_projectiontransform.get (); }

  octave_value get_x_viewporttransform (void) const { return x_viewporttransform.get (); }

  octave_value get_x_normrendertransform (void) const { return x_normrendertransform.get (); }

  octave_value get_x_rendertransform (void) const { return x_rendertransform.get (); }

  octave_value get_xmtick (void) const { return xmtick.get (); }

  octave_value get_ymtick (void) const { return ymtick.get (); }

  octave_value get_zmtick (void) const { return zmtick.get (); }

  octave_value get_looseinset (void) const { return looseinset.get (); }

  bool autopos_tag_is (const std::string& v) const { return autopos_tag.is (v); }
  std::string get_autopos_tag (void) const { return autopos_tag.current_value (); }


  void set_position (const octave_value& val)
  {
    if (! error_state)
      {
        if (position.set (val, true))
          {
            update_position ();
            mark_modified ();
          }
      }
  }

  void set_box (const octave_value& val)
  {
    if (! error_state)
      {
        if (box.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_colororder (const octave_value& val)
  {
    if (! error_state)
      {
        if (colororder.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_dataaspectratio (const octave_value& val)
  {
    if (! error_state)
      {
        if (dataaspectratio.set (val, false))
          {
            set_dataaspectratiomode ("manual");
            update_dataaspectratio ();
            dataaspectratio.run_listeners (POSTSET);
            mark_modified ();
          }
        else
          set_dataaspectratiomode ("manual");
      }
  }

  void set_dataaspectratiomode (const octave_value& val)
  {
    if (! error_state)
      {
        if (dataaspectratiomode.set (val, true))
          {
            update_dataaspectratiomode ();
            mark_modified ();
          }
      }
  }

  void set_layer (const octave_value& val)
  {
    if (! error_state)
      {
        if (layer.set (val, true))
          {
            update_layer ();
            mark_modified ();
          }
      }
  }

  void set_xlim (const octave_value& val)
  {
    if (! error_state)
      {
        if (xlim.set (val, false))
          {
            set_xlimmode ("manual");
            update_xlim ();
            xlim.run_listeners (POSTSET);
            mark_modified ();
          }
        else
          set_xlimmode ("manual");
      }
  }

  void set_ylim (const octave_value& val)
  {
    if (! error_state)
      {
        if (ylim.set (val, false))
          {
            set_ylimmode ("manual");
            update_ylim ();
            ylim.run_listeners (POSTSET);
            mark_modified ();
          }
        else
          set_ylimmode ("manual");
      }
  }

  void set_zlim (const octave_value& val)
  {
    if (! error_state)
      {
        if (zlim.set (val, false))
          {
            set_zlimmode ("manual");
            update_zlim ();
            zlim.run_listeners (POSTSET);
            mark_modified ();
          }
        else
          set_zlimmode ("manual");
      }
  }

  void set_clim (const octave_value& val)
  {
    if (! error_state)
      {
        if (clim.set (val, false))
          {
            set_climmode ("manual");
            clim.run_listeners (POSTSET);
            mark_modified ();
          }
        else
          set_climmode ("manual");
      }
  }

  void set_alim (const octave_value& val)
  {
    if (! error_state)
      {
        if (alim.set (val, false))
          {
            set_alimmode ("manual");
            alim.run_listeners (POSTSET);
            mark_modified ();
          }
        else
          set_alimmode ("manual");
      }
  }

  void set_xlimmode (const octave_value& val)
  {
    if (! error_state)
      {
        if (xlimmode.set (val, false))
          {
            update_axis_limits ("xlimmode");
            xlimmode.run_listeners (POSTSET);
            mark_modified ();
          }
      }
  }

  void set_ylimmode (const octave_value& val)
  {
    if (! error_state)
      {
        if (ylimmode.set (val, false))
          {
            update_axis_limits ("ylimmode");
            ylimmode.run_listeners (POSTSET);
            mark_modified ();
          }
      }
  }

  void set_zlimmode (const octave_value& val)
  {
    if (! error_state)
      {
        if (zlimmode.set (val, false))
          {
            update_axis_limits ("zlimmode");
            zlimmode.run_listeners (POSTSET);
            mark_modified ();
          }
      }
  }

  void set_climmode (const octave_value& val)
  {
    if (! error_state)
      {
        if (climmode.set (val, false))
          {
            update_axis_limits ("climmode");
            climmode.run_listeners (POSTSET);
            mark_modified ();
          }
      }
  }

  void set_alimmode (const octave_value& val)
  {
    if (! error_state)
      {
        if (alimmode.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_xlabel (const octave_value& val);

  void set_ylabel (const octave_value& val);

  void set_zlabel (const octave_value& val);

  void set_title (const octave_value& val);

  void set_xgrid (const octave_value& val)
  {
    if (! error_state)
      {
        if (xgrid.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_ygrid (const octave_value& val)
  {
    if (! error_state)
      {
        if (ygrid.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_zgrid (const octave_value& val)
  {
    if (! error_state)
      {
        if (zgrid.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_xminorgrid (const octave_value& val)
  {
    if (! error_state)
      {
        if (xminorgrid.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_yminorgrid (const octave_value& val)
  {
    if (! error_state)
      {
        if (yminorgrid.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_zminorgrid (const octave_value& val)
  {
    if (! error_state)
      {
        if (zminorgrid.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_xtick (const octave_value& val)
  {
    if (! error_state)
      {
        if (xtick.set (val, false))
          {
            set_xtickmode ("manual");
            update_xtick ();
            xtick.run_listeners (POSTSET);
            mark_modified ();
          }
        else
          set_xtickmode ("manual");
      }
  }

  void set_ytick (const octave_value& val)
  {
    if (! error_state)
      {
        if (ytick.set (val, false))
          {
            set_ytickmode ("manual");
            update_ytick ();
            ytick.run_listeners (POSTSET);
            mark_modified ();
          }
        else
          set_ytickmode ("manual");
      }
  }

  void set_ztick (const octave_value& val)
  {
    if (! error_state)
      {
        if (ztick.set (val, false))
          {
            set_ztickmode ("manual");
            update_ztick ();
            ztick.run_listeners (POSTSET);
            mark_modified ();
          }
        else
          set_ztickmode ("manual");
      }
  }

  void set_xtickmode (const octave_value& val)
  {
    if (! error_state)
      {
        if (xtickmode.set (val, true))
          {
            update_xtickmode ();
            mark_modified ();
          }
      }
  }

  void set_ytickmode (const octave_value& val)
  {
    if (! error_state)
      {
        if (ytickmode.set (val, true))
          {
            update_ytickmode ();
            mark_modified ();
          }
      }
  }

  void set_ztickmode (const octave_value& val)
  {
    if (! error_state)
      {
        if (ztickmode.set (val, true))
          {
            update_ztickmode ();
            mark_modified ();
          }
      }
  }

  void set_xminortick (const octave_value& val)
  {
    if (! error_state)
      {
        if (xminortick.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_yminortick (const octave_value& val)
  {
    if (! error_state)
      {
        if (yminortick.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_zminortick (const octave_value& val)
  {
    if (! error_state)
      {
        if (zminortick.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_xticklabel (const octave_value& val)
  {
    if (! error_state)
      {
        if (xticklabel.set (val, false))
          {
            set_xticklabelmode ("manual");
            xticklabel.run_listeners (POSTSET);
            mark_modified ();
          }
        else
          set_xticklabelmode ("manual");
      }
  }

  void set_yticklabel (const octave_value& val)
  {
    if (! error_state)
      {
        if (yticklabel.set (val, false))
          {
            set_yticklabelmode ("manual");
            yticklabel.run_listeners (POSTSET);
            mark_modified ();
          }
        else
          set_yticklabelmode ("manual");
      }
  }

  void set_zticklabel (const octave_value& val)
  {
    if (! error_state)
      {
        if (zticklabel.set (val, false))
          {
            set_zticklabelmode ("manual");
            zticklabel.run_listeners (POSTSET);
            mark_modified ();
          }
        else
          set_zticklabelmode ("manual");
      }
  }

  void set_xticklabelmode (const octave_value& val)
  {
    if (! error_state)
      {
        if (xticklabelmode.set (val, true))
          {
            update_xticklabelmode ();
            mark_modified ();
          }
      }
  }

  void set_yticklabelmode (const octave_value& val)
  {
    if (! error_state)
      {
        if (yticklabelmode.set (val, true))
          {
            update_yticklabelmode ();
            mark_modified ();
          }
      }
  }

  void set_zticklabelmode (const octave_value& val)
  {
    if (! error_state)
      {
        if (zticklabelmode.set (val, true))
          {
            update_zticklabelmode ();
            mark_modified ();
          }
      }
  }

  void set_interpreter (const octave_value& val)
  {
    if (! error_state)
      {
        if (interpreter.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_color (const octave_value& val)
  {
    if (! error_state)
      {
        if (color.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_xcolor (const octave_value& val)
  {
    if (! error_state)
      {
        if (xcolor.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_ycolor (const octave_value& val)
  {
    if (! error_state)
      {
        if (ycolor.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_zcolor (const octave_value& val)
  {
    if (! error_state)
      {
        if (zcolor.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_xscale (const octave_value& val)
  {
    if (! error_state)
      {
        if (xscale.set (val, false))
          {
            update_xscale ();
            update_axis_limits ("xscale");
            xscale.run_listeners (POSTSET);
            mark_modified ();
          }
      }
  }

  void set_yscale (const octave_value& val)
  {
    if (! error_state)
      {
        if (yscale.set (val, false))
          {
            update_yscale ();
            update_axis_limits ("yscale");
            yscale.run_listeners (POSTSET);
            mark_modified ();
          }
      }
  }

  void set_zscale (const octave_value& val)
  {
    if (! error_state)
      {
        if (zscale.set (val, false))
          {
            update_zscale ();
            update_axis_limits ("zscale");
            zscale.run_listeners (POSTSET);
            mark_modified ();
          }
      }
  }

  void set_xdir (const octave_value& val)
  {
    if (! error_state)
      {
        if (xdir.set (val, true))
          {
            update_xdir ();
            mark_modified ();
          }
      }
  }

  void set_ydir (const octave_value& val)
  {
    if (! error_state)
      {
        if (ydir.set (val, true))
          {
            update_ydir ();
            mark_modified ();
          }
      }
  }

  void set_zdir (const octave_value& val)
  {
    if (! error_state)
      {
        if (zdir.set (val, true))
          {
            update_zdir ();
            mark_modified ();
          }
      }
  }

  void set_yaxislocation (const octave_value& val)
  {
    if (! error_state)
      {
        if (yaxislocation.set (val, true))
          {
            update_yaxislocation ();
            mark_modified ();
          }
      }
  }

  void set_xaxislocation (const octave_value& val)
  {
    if (! error_state)
      {
        if (xaxislocation.set (val, true))
          {
            update_xaxislocation ();
            mark_modified ();
          }
      }
  }

  void set_view (const octave_value& val)
  {
    if (! error_state)
      {
        if (view.set (val, true))
          {
            update_view ();
            mark_modified ();
          }
      }
  }

  void set___hold_all__ (const octave_value& val)
  {
    if (! error_state)
      {
        if (__hold_all__.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_nextplot (const octave_value& val)
  {
    if (! error_state)
      {
        if (nextplot.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_outerposition (const octave_value& val)
  {
    if (! error_state)
      {
        if (outerposition.set (val, true))
          {
            update_outerposition ();
            mark_modified ();
          }
      }
  }

  void set_activepositionproperty (const octave_value& val)
  {
    if (! error_state)
      {
        if (activepositionproperty.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_ambientlightcolor (const octave_value& val)
  {
    if (! error_state)
      {
        if (ambientlightcolor.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_cameraposition (const octave_value& val)
  {
    if (! error_state)
      {
        if (cameraposition.set (val, false))
          {
            set_camerapositionmode ("manual");
            cameraposition.run_listeners (POSTSET);
            mark_modified ();
          }
        else
          set_camerapositionmode ("manual");
      }
  }

  void set_cameratarget (const octave_value& val)
  {
    if (! error_state)
      {
        if (cameratarget.set (val, false))
          {
            set_cameratargetmode ("manual");
            cameratarget.run_listeners (POSTSET);
            mark_modified ();
          }
        else
          set_cameratargetmode ("manual");
      }
  }

  void set_cameraupvector (const octave_value& val)
  {
    if (! error_state)
      {
        if (cameraupvector.set (val, false))
          {
            set_cameraupvectormode ("manual");
            cameraupvector.run_listeners (POSTSET);
            mark_modified ();
          }
        else
          set_cameraupvectormode ("manual");
      }
  }

  void set_cameraviewangle (const octave_value& val)
  {
    if (! error_state)
      {
        if (cameraviewangle.set (val, false))
          {
            set_cameraviewanglemode ("manual");
            cameraviewangle.run_listeners (POSTSET);
            mark_modified ();
          }
        else
          set_cameraviewanglemode ("manual");
      }
  }

  void set_camerapositionmode (const octave_value& val)
  {
    if (! error_state)
      {
        if (camerapositionmode.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_cameratargetmode (const octave_value& val)
  {
    if (! error_state)
      {
        if (cameratargetmode.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_cameraupvectormode (const octave_value& val)
  {
    if (! error_state)
      {
        if (cameraupvectormode.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_cameraviewanglemode (const octave_value& val)
  {
    if (! error_state)
      {
        if (cameraviewanglemode.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_currentpoint (const octave_value& val)
  {
    if (! error_state)
      {
        if (currentpoint.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_drawmode (const octave_value& val)
  {
    if (! error_state)
      {
        if (drawmode.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_fontangle (const octave_value& val)
  {
    if (! error_state)
      {
        if (fontangle.set (val, true))
          {
            update_fontangle ();
            mark_modified ();
          }
      }
  }

  void set_fontname (const octave_value& val)
  {
    if (! error_state)
      {
        if (fontname.set (val, true))
          {
            update_fontname ();
            mark_modified ();
          }
      }
  }

  void set_fontsize (const octave_value& val)
  {
    if (! error_state)
      {
        if (fontsize.set (val, true))
          {
            update_fontsize ();
            mark_modified ();
          }
      }
  }

  void set_fontunits (const octave_value& val);

  void update_fontunits (void);

  void set_fontweight (const octave_value& val)
  {
    if (! error_state)
      {
        if (fontweight.set (val, true))
          {
            update_fontweight ();
            mark_modified ();
          }
      }
  }

  void set_gridlinestyle (const octave_value& val)
  {
    if (! error_state)
      {
        if (gridlinestyle.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_linestyleorder (const octave_value& val)
  {
    if (! error_state)
      {
        if (linestyleorder.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_linewidth (const octave_value& val)
  {
    if (! error_state)
      {
        if (linewidth.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_minorgridlinestyle (const octave_value& val)
  {
    if (! error_state)
      {
        if (minorgridlinestyle.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_plotboxaspectratio (const octave_value& val)
  {
    if (! error_state)
      {
        if (plotboxaspectratio.set (val, false))
          {
            set_plotboxaspectratiomode ("manual");
            update_plotboxaspectratio ();
            plotboxaspectratio.run_listeners (POSTSET);
            mark_modified ();
          }
        else
          set_plotboxaspectratiomode ("manual");
      }
  }

  void set_plotboxaspectratiomode (const octave_value& val)
  {
    if (! error_state)
      {
        if (plotboxaspectratiomode.set (val, true))
          {
            update_plotboxaspectratiomode ();
            mark_modified ();
          }
      }
  }

  void set_projection (const octave_value& val)
  {
    if (! error_state)
      {
        if (projection.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_tickdir (const octave_value& val)
  {
    if (! error_state)
      {
        if (tickdir.set (val, false))
          {
            set_tickdirmode ("manual");
            update_tickdir ();
            tickdir.run_listeners (POSTSET);
            mark_modified ();
          }
        else
          set_tickdirmode ("manual");
      }
  }

  void set_tickdirmode (const octave_value& val)
  {
    if (! error_state)
      {
        if (tickdirmode.set (val, true))
          {
            update_tickdirmode ();
            mark_modified ();
          }
      }
  }

  void set_ticklength (const octave_value& val)
  {
    if (! error_state)
      {
        if (ticklength.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_tightinset (const octave_value& val)
  {
    if (! error_state)
      {
        if (tightinset.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_units (const octave_value& val);

  void update_units (void);

  void set_x_viewtransform (const octave_value& val)
  {
    if (! error_state)
      {
        if (x_viewtransform.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_x_projectiontransform (const octave_value& val)
  {
    if (! error_state)
      {
        if (x_projectiontransform.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_x_viewporttransform (const octave_value& val)
  {
    if (! error_state)
      {
        if (x_viewporttransform.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_x_normrendertransform (const octave_value& val)
  {
    if (! error_state)
      {
        if (x_normrendertransform.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_x_rendertransform (const octave_value& val)
  {
    if (! error_state)
      {
        if (x_rendertransform.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_xmtick (const octave_value& val)
  {
    if (! error_state)
      {
        if (xmtick.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_ymtick (const octave_value& val)
  {
    if (! error_state)
      {
        if (ymtick.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_zmtick (const octave_value& val)
  {
    if (! error_state)
      {
        if (zmtick.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_looseinset (const octave_value& val)
  {
    if (! error_state)
      {
        if (looseinset.set (val, true))
          {
            update_looseinset ();
            mark_modified ();
          }
      }
  }

  void set_autopos_tag (const octave_value& val)
  {
    if (! error_state)
      {
        if (autopos_tag.set (val, true))
          {
            mark_modified ();
          }
      }
  }


  protected:
    void init (void);

  private:
    void update_xscale (void) { sx = get_xscale (); }
    void update_yscale (void) { sy = get_yscale (); }
    void update_zscale (void) { sz = get_zscale (); }

    void update_view (void) { sync_positions (); }
    void update_dataaspectratio (void) { sync_positions (); }
    void update_dataaspectratiomode (void) { sync_positions (); }
    void update_plotboxaspectratio (void) { sync_positions (); }
    void update_plotboxaspectratiomode (void) { sync_positions (); }

    void update_layer (void) { update_axes_layout (); }
    void update_yaxislocation (void)
      {
        update_axes_layout ();
        update_ylabel_position ();
      }
    void update_xaxislocation (void)
      {
        update_axes_layout ();
        update_xlabel_position ();
      }

    void update_xdir (void) { update_camera (); update_axes_layout (); }
    void update_ydir (void) { update_camera (); update_axes_layout (); }
    void update_zdir (void) { update_camera (); update_axes_layout (); }

    void update_ticklengths (void);
    void update_tickdir (void) { update_ticklengths (); }
    void update_tickdirmode (void) { update_ticklengths (); }

    void update_xtick (void)
      {
        if (xticklabelmode.is ("auto"))
          calc_ticklabels (xtick, xticklabel, xscale.is ("log"));
      }
    void update_ytick (void)
      {
        if (yticklabelmode.is ("auto"))
          calc_ticklabels (ytick, yticklabel, yscale.is ("log"));
      }
    void update_ztick (void)
      {
        if (zticklabelmode.is ("auto"))
          calc_ticklabels (ztick, zticklabel, zscale.is ("log"));
      }

    void update_xtickmode (void)
      {
      if (xtickmode.is ("auto"))
        {
          calc_ticks_and_lims (xlim, xtick, xmtick, xlimmode.is ("auto"), xscale.is ("log"));
          update_xtick ();
        }
      }
    void update_ytickmode (void)
      {
      if (ytickmode.is ("auto"))
        {
          calc_ticks_and_lims (ylim, ytick, ymtick, ylimmode.is ("auto"), yscale.is ("log"));
          update_ytick ();
        }
      }
    void update_ztickmode (void)
      {
      if (ztickmode.is ("auto"))
        {
          calc_ticks_and_lims (zlim, ztick, zmtick, zlimmode.is ("auto"), zscale.is ("log"));
          update_ztick ();
        }
      }

    void update_xticklabelmode (void)
      {
        if (xticklabelmode.is ("auto"))
          calc_ticklabels (xtick, xticklabel, xscale.is ("log"));
      }
    void update_yticklabelmode (void)
      {
        if (yticklabelmode.is ("auto"))
          calc_ticklabels (ytick, yticklabel, yscale.is ("log"));
      }
    void update_zticklabelmode (void)
      {
        if (zticklabelmode.is ("auto"))
          calc_ticklabels (ztick, zticklabel, zscale.is ("log"));
      }

    void update_font (void);
    void update_fontname (void) { update_font (); }
    void update_fontsize (void) { update_font (); }
    void update_fontangle (void) { update_font (); }
    void update_fontweight (void) { update_font (); }

    void sync_positions (const Matrix& linset);
    void sync_positions (void);

    void update_outerposition (void)
    {
      set_activepositionproperty ("outerposition");
      sync_positions ();
    }

    void update_position (void)
    {
      set_activepositionproperty ("position");
      sync_positions ();
    }

    void update_looseinset (void) { sync_positions (); }

    double calc_tick_sep (double minval, double maxval);
    void calc_ticks_and_lims (array_property& lims, array_property& ticks, array_property& mticks,
                              bool limmode_is_auto, bool is_logscale);
    void calc_ticklabels (const array_property& ticks, any_property& labels, bool is_logscale);
    Matrix get_ticklabel_extents (const Matrix& ticks,
                                  const string_vector& ticklabels,
                                  const Matrix& limits);

    void fix_limits (array_property& lims)
    {
      if (lims.get ().is_empty ())
        return;

      Matrix l = lims.get ().matrix_value ();
      if (l(0) > l(1))
        {
          l(0) = 0;
          l(1) = 1;
          lims = l;
        }
      else if (l(0) == l(1))
        {
          l(0) -= 0.5;
          l(1) += 0.5;
          lims = l;
        }
    }

    Matrix calc_tightbox (const Matrix& init_pos);

  public:
    Matrix get_axis_limits (double xmin, double xmax,
                            double min_pos, double max_neg,
                            bool logscale);

    void update_xlim (bool do_clr_zoom = true)
    {
      if (xtickmode.is ("auto"))
        calc_ticks_and_lims (xlim, xtick, xmtick, xlimmode.is ("auto"), xscale.is ("log"));
      if (xticklabelmode.is ("auto"))
        calc_ticklabels (xtick, xticklabel, xscale.is ("log"));

      fix_limits (xlim);

      if (do_clr_zoom)
        zoom_stack.clear ();

      update_axes_layout ();
    }

    void update_ylim (bool do_clr_zoom = true)
    {
      if (ytickmode.is ("auto"))
        calc_ticks_and_lims (ylim, ytick, ymtick, ylimmode.is ("auto"), yscale.is ("log"));
      if (yticklabelmode.is ("auto"))
        calc_ticklabels (ytick, yticklabel, yscale.is ("log"));

      fix_limits (ylim);

      if (do_clr_zoom)
        zoom_stack.clear ();

      update_axes_layout ();
    }

    void update_zlim (void)
    {
      if (ztickmode.is ("auto"))
        calc_ticks_and_lims (zlim, ztick, zmtick, zlimmode.is ("auto"), zscale.is ("log"));
      if (zticklabelmode.is ("auto"))
        calc_ticklabels (ztick, zticklabel, zscale.is ("log"));

      fix_limits (zlim);

      zoom_stack.clear ();

      update_axes_layout ();
    }

  };

private:
  properties xproperties;

public:
  axes (const graphics_handle& mh, const graphics_handle& p)
    : base_graphics_object (), xproperties (mh, p), default_properties ()
  {
    xproperties.override_defaults (*this);
    xproperties.update_transform ();
  }

  ~axes (void) { }

  void override_defaults (base_graphics_object& obj)
  {
    // Allow parent (figure) to override first (properties knows how
    // to find the parent object).
    xproperties.override_defaults (obj);

    // Now override with our defaults.  If the default_properties
    // list includes the properties for all defaults (line,
    // surface, etc.) then we don't have to know the type of OBJ
    // here, we just call its set function and let it decide which
    // properties from the list to use.
    obj.set_from_list (default_properties);
  }

  void set (const caseless_str& name, const octave_value& value)
  {
    if (name.compare ("default", 7))
      // strip "default", pass rest to function that will
      // parse the remainder and add the element to the
      // default_properties map.
      default_properties.set (name.substr (7), value);
    else
      xproperties.set (name, value);
  }

  void set_defaults (const std::string& mode)
  {
    remove_all_listeners ();
    xproperties.set_defaults (*this, mode);
  }

  octave_value get (const caseless_str& name) const
  {
    octave_value retval;

    // FIXME -- finish this.
    if (name.compare ("default", 7))
      retval = get_default (name.substr (7));
    else
      retval = xproperties.get (name);

    return retval;
  }

  octave_value get_default (const caseless_str& name) const;

  octave_value get_defaults (void) const
  {
    return default_properties.as_struct ("default");
  }

  base_properties& get_properties (void) { return xproperties; }

  const base_properties& get_properties (void) const { return xproperties; }

  void update_axis_limits (const std::string& axis_type);

  void update_axis_limits (const std::string& axis_type,
                           const graphics_handle& h);

  bool valid_object (void) const { return true; }

  void reset_default_properties (void);

protected:
  void initialize (const graphics_object& go);

private:
  property_list default_properties;
};

// ---------------------------------------------------------------------

class OCTINTERP_API line : public base_graphics_object
{
public:
  class OCTINTERP_API properties : public base_properties
  {
  public:
    // See the genprops.awk script for an explanation of the
    // properties declarations.

    // properties which are not in matlab: interpreter

public:
  properties (const graphics_handle& mh, const graphics_handle& p);

  ~properties (void) { }

  void set (const caseless_str& pname, const octave_value& val);

  octave_value get (bool all = false) const;

  octave_value get (const caseless_str& pname) const;

  octave_value get (const std::string& pname) const
  {
    return get (caseless_str (pname));
  }

  octave_value get (const char *pname) const
  {
    return get (caseless_str (pname));
  }

  property get_property (const caseless_str& pname);

  std::string graphics_object_name (void) const { return go_name; }

  static property_list::pval_map_type factory_defaults (void);

private:
  static std::string go_name;

public:


  static std::set<std::string> core_property_names (void);

  static bool has_core_property (const caseless_str& pname);

  std::set<std::string> all_property_names (void) const;

  bool has_property (const caseless_str& pname) const;

private:

  row_vector_property xdata;
  row_vector_property ydata;
  row_vector_property zdata;
  string_property xdatasource;
  string_property ydatasource;
  string_property zdatasource;
  color_property color;
  radio_property linestyle;
  double_property linewidth;
  radio_property marker;
  color_property markeredgecolor;
  color_property markerfacecolor;
  double_property markersize;
  radio_property interpreter;
  string_property displayname;
  radio_property erasemode;
  row_vector_property xlim;
  row_vector_property ylim;
  row_vector_property zlim;
  bool_property xliminclude;
  bool_property yliminclude;
  bool_property zliminclude;

public:

  enum
  {
    ID_XDATA = 4000,
    ID_YDATA = 4001,
    ID_ZDATA = 4002,
    ID_XDATASOURCE = 4003,
    ID_YDATASOURCE = 4004,
    ID_ZDATASOURCE = 4005,
    ID_COLOR = 4006,
    ID_LINESTYLE = 4007,
    ID_LINEWIDTH = 4008,
    ID_MARKER = 4009,
    ID_MARKEREDGECOLOR = 4010,
    ID_MARKERFACECOLOR = 4011,
    ID_MARKERSIZE = 4012,
    ID_INTERPRETER = 4013,
    ID_DISPLAYNAME = 4014,
    ID_ERASEMODE = 4015,
    ID_XLIM = 4016,
    ID_YLIM = 4017,
    ID_ZLIM = 4018,
    ID_XLIMINCLUDE = 4019,
    ID_YLIMINCLUDE = 4020,
    ID_ZLIMINCLUDE = 4021
  };

  octave_value get_xdata (void) const { return xdata.get (); }

  octave_value get_ydata (void) const { return ydata.get (); }

  octave_value get_zdata (void) const { return zdata.get (); }

  std::string get_xdatasource (void) const { return xdatasource.string_value (); }

  std::string get_ydatasource (void) const { return ydatasource.string_value (); }

  std::string get_zdatasource (void) const { return zdatasource.string_value (); }

  bool color_is_rgb (void) const { return color.is_rgb (); }
  bool color_is (const std::string& v) const { return color.is (v); }
  Matrix get_color_rgb (void) const { return (color.is_rgb () ? color.rgb () : Matrix ()); }
  octave_value get_color (void) const { return color.get (); }

  bool linestyle_is (const std::string& v) const { return linestyle.is (v); }
  std::string get_linestyle (void) const { return linestyle.current_value (); }

  double get_linewidth (void) const { return linewidth.double_value (); }

  bool marker_is (const std::string& v) const { return marker.is (v); }
  std::string get_marker (void) const { return marker.current_value (); }

  bool markeredgecolor_is_rgb (void) const { return markeredgecolor.is_rgb (); }
  bool markeredgecolor_is (const std::string& v) const { return markeredgecolor.is (v); }
  Matrix get_markeredgecolor_rgb (void) const { return (markeredgecolor.is_rgb () ? markeredgecolor.rgb () : Matrix ()); }
  octave_value get_markeredgecolor (void) const { return markeredgecolor.get (); }

  bool markerfacecolor_is_rgb (void) const { return markerfacecolor.is_rgb (); }
  bool markerfacecolor_is (const std::string& v) const { return markerfacecolor.is (v); }
  Matrix get_markerfacecolor_rgb (void) const { return (markerfacecolor.is_rgb () ? markerfacecolor.rgb () : Matrix ()); }
  octave_value get_markerfacecolor (void) const { return markerfacecolor.get (); }

  double get_markersize (void) const { return markersize.double_value (); }

  bool interpreter_is (const std::string& v) const { return interpreter.is (v); }
  std::string get_interpreter (void) const { return interpreter.current_value (); }

  std::string get_displayname (void) const { return displayname.string_value (); }

  bool erasemode_is (const std::string& v) const { return erasemode.is (v); }
  std::string get_erasemode (void) const { return erasemode.current_value (); }

  octave_value get_xlim (void) const { return xlim.get (); }

  octave_value get_ylim (void) const { return ylim.get (); }

  octave_value get_zlim (void) const { return zlim.get (); }

  bool is_xliminclude (void) const { return xliminclude.is_on (); }
  std::string get_xliminclude (void) const { return xliminclude.current_value (); }

  bool is_yliminclude (void) const { return yliminclude.is_on (); }
  std::string get_yliminclude (void) const { return yliminclude.current_value (); }

  bool is_zliminclude (void) const { return zliminclude.is_on (); }
  std::string get_zliminclude (void) const { return zliminclude.current_value (); }


  void set_xdata (const octave_value& val)
  {
    if (! error_state)
      {
        if (xdata.set (val, true))
          {
            update_xdata ();
            mark_modified ();
          }
      }
  }

  void set_ydata (const octave_value& val)
  {
    if (! error_state)
      {
        if (ydata.set (val, true))
          {
            update_ydata ();
            mark_modified ();
          }
      }
  }

  void set_zdata (const octave_value& val)
  {
    if (! error_state)
      {
        if (zdata.set (val, true))
          {
            update_zdata ();
            mark_modified ();
          }
      }
  }

  void set_xdatasource (const octave_value& val)
  {
    if (! error_state)
      {
        if (xdatasource.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_ydatasource (const octave_value& val)
  {
    if (! error_state)
      {
        if (ydatasource.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_zdatasource (const octave_value& val)
  {
    if (! error_state)
      {
        if (zdatasource.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_color (const octave_value& val)
  {
    if (! error_state)
      {
        if (color.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_linestyle (const octave_value& val)
  {
    if (! error_state)
      {
        if (linestyle.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_linewidth (const octave_value& val)
  {
    if (! error_state)
      {
        if (linewidth.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_marker (const octave_value& val)
  {
    if (! error_state)
      {
        if (marker.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_markeredgecolor (const octave_value& val)
  {
    if (! error_state)
      {
        if (markeredgecolor.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_markerfacecolor (const octave_value& val)
  {
    if (! error_state)
      {
        if (markerfacecolor.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_markersize (const octave_value& val)
  {
    if (! error_state)
      {
        if (markersize.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_interpreter (const octave_value& val)
  {
    if (! error_state)
      {
        if (interpreter.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_displayname (const octave_value& val)
  {
    if (! error_state)
      {
        if (displayname.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_erasemode (const octave_value& val)
  {
    if (! error_state)
      {
        if (erasemode.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_xlim (const octave_value& val)
  {
    if (! error_state)
      {
        if (xlim.set (val, false))
          {
            update_axis_limits ("xlim");
            xlim.run_listeners (POSTSET);
            mark_modified ();
          }
      }
  }

  void set_ylim (const octave_value& val)
  {
    if (! error_state)
      {
        if (ylim.set (val, false))
          {
            update_axis_limits ("ylim");
            ylim.run_listeners (POSTSET);
            mark_modified ();
          }
      }
  }

  void set_zlim (const octave_value& val)
  {
    if (! error_state)
      {
        if (zlim.set (val, false))
          {
            update_axis_limits ("zlim");
            zlim.run_listeners (POSTSET);
            mark_modified ();
          }
      }
  }

  void set_xliminclude (const octave_value& val)
  {
    if (! error_state)
      {
        if (xliminclude.set (val, false))
          {
            update_axis_limits ("xliminclude");
            xliminclude.run_listeners (POSTSET);
            mark_modified ();
          }
      }
  }

  void set_yliminclude (const octave_value& val)
  {
    if (! error_state)
      {
        if (yliminclude.set (val, false))
          {
            update_axis_limits ("yliminclude");
            yliminclude.run_listeners (POSTSET);
            mark_modified ();
          }
      }
  }

  void set_zliminclude (const octave_value& val)
  {
    if (! error_state)
      {
        if (zliminclude.set (val, false))
          {
            update_axis_limits ("zliminclude");
            zliminclude.run_listeners (POSTSET);
            mark_modified ();
          }
      }
  }


  private:
    Matrix compute_xlim (void) const;
    Matrix compute_ylim (void) const;

    void update_xdata (void) { set_xlim (compute_xlim ()); }

    void update_ydata (void) { set_ylim (compute_ylim ()); }

    void update_zdata (void)
      {
        set_zlim (zdata.get_limits ());
        set_zliminclude (get_zdata ().numel () > 0);
      }
  };

private:
  properties xproperties;

public:
  line (const graphics_handle& mh, const graphics_handle& p)
    : base_graphics_object (), xproperties (mh, p)
  {
    xproperties.override_defaults (*this);
  }

  ~line (void) { }

  base_properties& get_properties (void) { return xproperties; }

  const base_properties& get_properties (void) const { return xproperties; }

  bool valid_object (void) const { return true; }
};

// ---------------------------------------------------------------------

class OCTINTERP_API text : public base_graphics_object
{
public:
  class OCTINTERP_API properties : public base_properties
  {
  public:
    double get_fontsize_points (double box_pix_height = 0) const;

    // See the genprops.awk script for an explanation of the
    // properties declarations.

public:
  properties (const graphics_handle& mh, const graphics_handle& p);

  ~properties (void) { }

  void set (const caseless_str& pname, const octave_value& val);

  octave_value get (bool all = false) const;

  octave_value get (const caseless_str& pname) const;

  octave_value get (const std::string& pname) const
  {
    return get (caseless_str (pname));
  }

  octave_value get (const char *pname) const
  {
    return get (caseless_str (pname));
  }

  property get_property (const caseless_str& pname);

  std::string graphics_object_name (void) const { return go_name; }

  static property_list::pval_map_type factory_defaults (void);

private:
  static std::string go_name;

public:


  static std::set<std::string> core_property_names (void);

  static bool has_core_property (const caseless_str& pname);

  std::set<std::string> all_property_names (void) const;

  bool has_property (const caseless_str& pname) const;

private:

  text_label_property string;
  radio_property units;
  array_property position;
  double_property rotation;
  radio_property horizontalalignment;
  color_property color;
  string_property fontname;
  double_property fontsize;
  radio_property fontangle;
  radio_property fontweight;
  radio_property interpreter;
  color_property backgroundcolor;
  string_property displayname;
  color_property edgecolor;
  radio_property erasemode;
  bool_property editing;
  radio_property fontunits;
  radio_property linestyle;
  double_property linewidth;
  double_property margin;
  radio_property verticalalignment;
  array_property extent;
  row_vector_property xlim;
  row_vector_property ylim;
  row_vector_property zlim;
  bool_property xliminclude;
  bool_property yliminclude;
  bool_property zliminclude;
  radio_property positionmode;
  radio_property rotationmode;
  radio_property horizontalalignmentmode;
  radio_property verticalalignmentmode;
  radio_property autopos_tag;

public:

  enum
  {
    ID_STRING = 5000,
    ID_UNITS = 5001,
    ID_POSITION = 5002,
    ID_ROTATION = 5003,
    ID_HORIZONTALALIGNMENT = 5004,
    ID_COLOR = 5005,
    ID_FONTNAME = 5006,
    ID_FONTSIZE = 5007,
    ID_FONTANGLE = 5008,
    ID_FONTWEIGHT = 5009,
    ID_INTERPRETER = 5010,
    ID_BACKGROUNDCOLOR = 5011,
    ID_DISPLAYNAME = 5012,
    ID_EDGECOLOR = 5013,
    ID_ERASEMODE = 5014,
    ID_EDITING = 5015,
    ID_FONTUNITS = 5016,
    ID_LINESTYLE = 5017,
    ID_LINEWIDTH = 5018,
    ID_MARGIN = 5019,
    ID_VERTICALALIGNMENT = 5020,
    ID_EXTENT = 5021,
    ID_XLIM = 5022,
    ID_YLIM = 5023,
    ID_ZLIM = 5024,
    ID_XLIMINCLUDE = 5025,
    ID_YLIMINCLUDE = 5026,
    ID_ZLIMINCLUDE = 5027,
    ID_POSITIONMODE = 5028,
    ID_ROTATIONMODE = 5029,
    ID_HORIZONTALALIGNMENTMODE = 5030,
    ID_VERTICALALIGNMENTMODE = 5031,
    ID_AUTOPOS_TAG = 5032
  };

  octave_value get_string (void) const { return string.get (); }

  bool units_is (const std::string& v) const { return units.is (v); }
  std::string get_units (void) const { return units.current_value (); }

  octave_value get_position (void) const { return position.get (); }

  double get_rotation (void) const { return rotation.double_value (); }

  bool horizontalalignment_is (const std::string& v) const { return horizontalalignment.is (v); }
  std::string get_horizontalalignment (void) const { return horizontalalignment.current_value (); }

  bool color_is_rgb (void) const { return color.is_rgb (); }
  bool color_is (const std::string& v) const { return color.is (v); }
  Matrix get_color_rgb (void) const { return (color.is_rgb () ? color.rgb () : Matrix ()); }
  octave_value get_color (void) const { return color.get (); }

  std::string get_fontname (void) const { return fontname.string_value (); }

  double get_fontsize (void) const { return fontsize.double_value (); }

  bool fontangle_is (const std::string& v) const { return fontangle.is (v); }
  std::string get_fontangle (void) const { return fontangle.current_value (); }

  bool fontweight_is (const std::string& v) const { return fontweight.is (v); }
  std::string get_fontweight (void) const { return fontweight.current_value (); }

  bool interpreter_is (const std::string& v) const { return interpreter.is (v); }
  std::string get_interpreter (void) const { return interpreter.current_value (); }

  bool backgroundcolor_is_rgb (void) const { return backgroundcolor.is_rgb (); }
  bool backgroundcolor_is (const std::string& v) const { return backgroundcolor.is (v); }
  Matrix get_backgroundcolor_rgb (void) const { return (backgroundcolor.is_rgb () ? backgroundcolor.rgb () : Matrix ()); }
  octave_value get_backgroundcolor (void) const { return backgroundcolor.get (); }

  std::string get_displayname (void) const { return displayname.string_value (); }

  bool edgecolor_is_rgb (void) const { return edgecolor.is_rgb (); }
  bool edgecolor_is (const std::string& v) const { return edgecolor.is (v); }
  Matrix get_edgecolor_rgb (void) const { return (edgecolor.is_rgb () ? edgecolor.rgb () : Matrix ()); }
  octave_value get_edgecolor (void) const { return edgecolor.get (); }

  bool erasemode_is (const std::string& v) const { return erasemode.is (v); }
  std::string get_erasemode (void) const { return erasemode.current_value (); }

  bool is_editing (void) const { return editing.is_on (); }
  std::string get_editing (void) const { return editing.current_value (); }

  bool fontunits_is (const std::string& v) const { return fontunits.is (v); }
  std::string get_fontunits (void) const { return fontunits.current_value (); }

  bool linestyle_is (const std::string& v) const { return linestyle.is (v); }
  std::string get_linestyle (void) const { return linestyle.current_value (); }

  double get_linewidth (void) const { return linewidth.double_value (); }

  double get_margin (void) const { return margin.double_value (); }

  bool verticalalignment_is (const std::string& v) const { return verticalalignment.is (v); }
  std::string get_verticalalignment (void) const { return verticalalignment.current_value (); }

  octave_value get_extent (void) const;

  octave_value get_xlim (void) const { return xlim.get (); }

  octave_value get_ylim (void) const { return ylim.get (); }

  octave_value get_zlim (void) const { return zlim.get (); }

  bool is_xliminclude (void) const { return xliminclude.is_on (); }
  std::string get_xliminclude (void) const { return xliminclude.current_value (); }

  bool is_yliminclude (void) const { return yliminclude.is_on (); }
  std::string get_yliminclude (void) const { return yliminclude.current_value (); }

  bool is_zliminclude (void) const { return zliminclude.is_on (); }
  std::string get_zliminclude (void) const { return zliminclude.current_value (); }

  bool positionmode_is (const std::string& v) const { return positionmode.is (v); }
  std::string get_positionmode (void) const { return positionmode.current_value (); }

  bool rotationmode_is (const std::string& v) const { return rotationmode.is (v); }
  std::string get_rotationmode (void) const { return rotationmode.current_value (); }

  bool horizontalalignmentmode_is (const std::string& v) const { return horizontalalignmentmode.is (v); }
  std::string get_horizontalalignmentmode (void) const { return horizontalalignmentmode.current_value (); }

  bool verticalalignmentmode_is (const std::string& v) const { return verticalalignmentmode.is (v); }
  std::string get_verticalalignmentmode (void) const { return verticalalignmentmode.current_value (); }

  bool autopos_tag_is (const std::string& v) const { return autopos_tag.is (v); }
  std::string get_autopos_tag (void) const { return autopos_tag.current_value (); }


  void set_string (const octave_value& val)
  {
    if (! error_state)
      {
        if (string.set (val, true))
          {
            update_string ();
            mark_modified ();
          }
      }
  }

  void set_units (const octave_value& val)
  {
    if (! error_state)
      {
        if (units.set (val, true))
          {
            update_units ();
            mark_modified ();
          }
      }
  }

  void set_position (const octave_value& val)
  {
    if (! error_state)
      {
        if (position.set (val, false))
          {
            set_positionmode ("manual");
            update_position ();
            position.run_listeners (POSTSET);
            mark_modified ();
          }
        else
          set_positionmode ("manual");
      }
  }

  void set_rotation (const octave_value& val)
  {
    if (! error_state)
      {
        if (rotation.set (val, false))
          {
            set_rotationmode ("manual");
            update_rotation ();
            rotation.run_listeners (POSTSET);
            mark_modified ();
          }
        else
          set_rotationmode ("manual");
      }
  }

  void set_horizontalalignment (const octave_value& val)
  {
    if (! error_state)
      {
        if (horizontalalignment.set (val, false))
          {
            set_horizontalalignmentmode ("manual");
            update_horizontalalignment ();
            horizontalalignment.run_listeners (POSTSET);
            mark_modified ();
          }
        else
          set_horizontalalignmentmode ("manual");
      }
  }

  void set_color (const octave_value& val)
  {
    if (! error_state)
      {
        if (color.set (val, true))
          {
            update_color ();
            mark_modified ();
          }
      }
  }

  void set_fontname (const octave_value& val)
  {
    if (! error_state)
      {
        if (fontname.set (val, true))
          {
            update_fontname ();
            mark_modified ();
          }
      }
  }

  void set_fontsize (const octave_value& val)
  {
    if (! error_state)
      {
        if (fontsize.set (val, true))
          {
            update_fontsize ();
            mark_modified ();
          }
      }
  }

  void set_fontangle (const octave_value& val)
  {
    if (! error_state)
      {
        if (fontangle.set (val, true))
          {
            update_fontangle ();
            mark_modified ();
          }
      }
  }

  void set_fontweight (const octave_value& val)
  {
    if (! error_state)
      {
        if (fontweight.set (val, true))
          {
            update_fontweight ();
            mark_modified ();
          }
      }
  }

  void set_interpreter (const octave_value& val)
  {
    if (! error_state)
      {
        if (interpreter.set (val, true))
          {
            update_interpreter ();
            mark_modified ();
          }
      }
  }

  void set_backgroundcolor (const octave_value& val)
  {
    if (! error_state)
      {
        if (backgroundcolor.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_displayname (const octave_value& val)
  {
    if (! error_state)
      {
        if (displayname.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_edgecolor (const octave_value& val)
  {
    if (! error_state)
      {
        if (edgecolor.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_erasemode (const octave_value& val)
  {
    if (! error_state)
      {
        if (erasemode.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_editing (const octave_value& val)
  {
    if (! error_state)
      {
        if (editing.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_fontunits (const octave_value& val)
  {
    if (! error_state)
      {
        if (fontunits.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_linestyle (const octave_value& val)
  {
    if (! error_state)
      {
        if (linestyle.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_linewidth (const octave_value& val)
  {
    if (! error_state)
      {
        if (linewidth.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_margin (const octave_value& val)
  {
    if (! error_state)
      {
        if (margin.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_verticalalignment (const octave_value& val)
  {
    if (! error_state)
      {
        if (verticalalignment.set (val, false))
          {
            set_verticalalignmentmode ("manual");
            update_verticalalignment ();
            verticalalignment.run_listeners (POSTSET);
            mark_modified ();
          }
        else
          set_verticalalignmentmode ("manual");
      }
  }

  void set_extent (const octave_value& val)
  {
    if (! error_state)
      {
        if (extent.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_xlim (const octave_value& val)
  {
    if (! error_state)
      {
        if (xlim.set (val, false))
          {
            update_axis_limits ("xlim");
            xlim.run_listeners (POSTSET);
            mark_modified ();
          }
      }
  }

  void set_ylim (const octave_value& val)
  {
    if (! error_state)
      {
        if (ylim.set (val, false))
          {
            update_axis_limits ("ylim");
            ylim.run_listeners (POSTSET);
            mark_modified ();
          }
      }
  }

  void set_zlim (const octave_value& val)
  {
    if (! error_state)
      {
        if (zlim.set (val, false))
          {
            update_axis_limits ("zlim");
            zlim.run_listeners (POSTSET);
            mark_modified ();
          }
      }
  }

  void set_xliminclude (const octave_value& val)
  {
    if (! error_state)
      {
        if (xliminclude.set (val, false))
          {
            update_axis_limits ("xliminclude");
            xliminclude.run_listeners (POSTSET);
            mark_modified ();
          }
      }
  }

  void set_yliminclude (const octave_value& val)
  {
    if (! error_state)
      {
        if (yliminclude.set (val, false))
          {
            update_axis_limits ("yliminclude");
            yliminclude.run_listeners (POSTSET);
            mark_modified ();
          }
      }
  }

  void set_zliminclude (const octave_value& val)
  {
    if (! error_state)
      {
        if (zliminclude.set (val, false))
          {
            update_axis_limits ("zliminclude");
            zliminclude.run_listeners (POSTSET);
            mark_modified ();
          }
      }
  }

  void set_positionmode (const octave_value& val)
  {
    if (! error_state)
      {
        if (positionmode.set (val, true))
          {
            update_positionmode ();
            mark_modified ();
          }
      }
  }

  void set_rotationmode (const octave_value& val)
  {
    if (! error_state)
      {
        if (rotationmode.set (val, true))
          {
            update_rotationmode ();
            mark_modified ();
          }
      }
  }

  void set_horizontalalignmentmode (const octave_value& val)
  {
    if (! error_state)
      {
        if (horizontalalignmentmode.set (val, true))
          {
            update_horizontalalignmentmode ();
            mark_modified ();
          }
      }
  }

  void set_verticalalignmentmode (const octave_value& val)
  {
    if (! error_state)
      {
        if (verticalalignmentmode.set (val, true))
          {
            update_verticalalignmentmode ();
            mark_modified ();
          }
      }
  }

  void set_autopos_tag (const octave_value& val)
  {
    if (! error_state)
      {
        if (autopos_tag.set (val, true))
          {
            mark_modified ();
          }
      }
  }


    Matrix get_data_position (void) const;
    Matrix get_extent_matrix (void) const;
    const uint8NDArray& get_pixels (void) const { return pixels; }
#if HAVE_FREETYPE
    // freetype renderer, used for calculation of text size
    ft_render renderer;
#endif

  protected:
    void init (void)
      {
        position.add_constraint (dim_vector (1, 2));
        position.add_constraint (dim_vector (1, 3));
        cached_units = get_units ();
        update_font ();
      }

  private:
    void update_position (void)
      {
        Matrix pos = get_data_position ();
        Matrix lim;

        lim = Matrix (1, 3, pos(0));
        lim(2) = (lim(2) <= 0 ? octave_Inf : lim(2));
        set_xlim (lim);

        lim = Matrix (1, 3, pos(1));
        lim(2) = (lim(2) <= 0 ? octave_Inf : lim(2));
        set_ylim (lim);

        if (pos.numel () == 3)
          {
            lim = Matrix (1, 3, pos(2));
            lim(2) = (lim(2) <= 0 ? octave_Inf : lim(2));
            set_zliminclude ("on");
            set_zlim (lim);
          }
        else
          set_zliminclude ("off");
      }

    void update_text_extent (void);

    void request_autopos (void);
    void update_positionmode (void) { request_autopos (); }
    void update_rotationmode (void) { request_autopos (); }
    void update_horizontalalignmentmode (void) { request_autopos (); }
    void update_verticalalignmentmode (void) { request_autopos (); }

    void update_font (void);
    void update_string (void) { request_autopos (); update_text_extent (); }
    void update_rotation (void) { update_text_extent (); }
    void update_color (void) { update_font (); }
    void update_fontname (void) { update_font (); update_text_extent (); }
    void update_fontsize (void) { update_font (); update_text_extent (); }
    void update_fontangle (void) { update_font (); update_text_extent (); }
    void update_fontweight (void) { update_font (); update_text_extent (); }
    void update_interpreter (void) { update_text_extent (); }
    void update_horizontalalignment (void) { update_text_extent (); }
    void update_verticalalignment (void) { update_text_extent (); }

    void update_units (void);

  private:
    std::string cached_units;
    uint8NDArray pixels;
  };

private:
  properties xproperties;

public:
  text (const graphics_handle& mh, const graphics_handle& p)
    : base_graphics_object (), xproperties (mh, p)
  {
    xproperties.set_clipping ("off");
    xproperties.override_defaults (*this);
  }

  ~text (void) { }

  base_properties& get_properties (void) { return xproperties; }

  const base_properties& get_properties (void) const { return xproperties; }

  bool valid_object (void) const { return true; }
};

// ---------------------------------------------------------------------

class OCTINTERP_API image : public base_graphics_object
{
public:
  class OCTINTERP_API properties : public base_properties
  {
  public:
    bool is_climinclude (void) const
      { return (climinclude.is_on () && cdatamapping.is ("scaled")); }
    std::string get_climinclude (void) const
      { return climinclude.current_value (); }

    octave_value get_color_data (void) const;

    // See the genprops.awk script for an explanation of the
    // properties declarations.

public:
  properties (const graphics_handle& mh, const graphics_handle& p);

  ~properties (void) { }

  void set (const caseless_str& pname, const octave_value& val);

  octave_value get (bool all = false) const;

  octave_value get (const caseless_str& pname) const;

  octave_value get (const std::string& pname) const
  {
    return get (caseless_str (pname));
  }

  octave_value get (const char *pname) const
  {
    return get (caseless_str (pname));
  }

  property get_property (const caseless_str& pname);

  std::string graphics_object_name (void) const { return go_name; }

  static property_list::pval_map_type factory_defaults (void);

private:
  static std::string go_name;

public:


  static std::set<std::string> core_property_names (void);

  static bool has_core_property (const caseless_str& pname);

  std::set<std::string> all_property_names (void) const;

  bool has_property (const caseless_str& pname) const;

private:

  row_vector_property xdata;
  row_vector_property ydata;
  array_property cdata;
  radio_property cdatamapping;
  row_vector_property xlim;
  row_vector_property ylim;
  row_vector_property clim;
  bool_property xliminclude;
  bool_property yliminclude;
  bool_property climinclude;

public:

  enum
  {
    ID_XDATA = 6000,
    ID_YDATA = 6001,
    ID_CDATA = 6002,
    ID_CDATAMAPPING = 6003,
    ID_XLIM = 6004,
    ID_YLIM = 6005,
    ID_CLIM = 6006,
    ID_XLIMINCLUDE = 6007,
    ID_YLIMINCLUDE = 6008,
    ID_CLIMINCLUDE = 6009
  };

  octave_value get_xdata (void) const { return xdata.get (); }

  octave_value get_ydata (void) const { return ydata.get (); }

  octave_value get_cdata (void) const { return cdata.get (); }

  bool cdatamapping_is (const std::string& v) const { return cdatamapping.is (v); }
  std::string get_cdatamapping (void) const { return cdatamapping.current_value (); }

  octave_value get_xlim (void) const { return xlim.get (); }

  octave_value get_ylim (void) const { return ylim.get (); }

  octave_value get_clim (void) const { return clim.get (); }

  bool is_xliminclude (void) const { return xliminclude.is_on (); }
  std::string get_xliminclude (void) const { return xliminclude.current_value (); }

  bool is_yliminclude (void) const { return yliminclude.is_on (); }
  std::string get_yliminclude (void) const { return yliminclude.current_value (); }


  void set_xdata (const octave_value& val)
  {
    if (! error_state)
      {
        if (xdata.set (val, true))
          {
            update_xdata ();
            mark_modified ();
          }
      }
  }

  void set_ydata (const octave_value& val)
  {
    if (! error_state)
      {
        if (ydata.set (val, true))
          {
            update_ydata ();
            mark_modified ();
          }
      }
  }

  void set_cdata (const octave_value& val)
  {
    if (! error_state)
      {
        if (cdata.set (val, true))
          {
            update_cdata ();
            mark_modified ();
          }
      }
  }

  void set_cdatamapping (const octave_value& val)
  {
    if (! error_state)
      {
        if (cdatamapping.set (val, false))
          {
            update_axis_limits ("cdatamapping");
            cdatamapping.run_listeners (POSTSET);
            mark_modified ();
          }
      }
  }

  void set_xlim (const octave_value& val)
  {
    if (! error_state)
      {
        if (xlim.set (val, false))
          {
            update_axis_limits ("xlim");
            xlim.run_listeners (POSTSET);
            mark_modified ();
          }
      }
  }

  void set_ylim (const octave_value& val)
  {
    if (! error_state)
      {
        if (ylim.set (val, false))
          {
            update_axis_limits ("ylim");
            ylim.run_listeners (POSTSET);
            mark_modified ();
          }
      }
  }

  void set_clim (const octave_value& val)
  {
    if (! error_state)
      {
        if (clim.set (val, false))
          {
            update_axis_limits ("clim");
            clim.run_listeners (POSTSET);
            mark_modified ();
          }
      }
  }

  void set_xliminclude (const octave_value& val)
  {
    if (! error_state)
      {
        if (xliminclude.set (val, false))
          {
            update_axis_limits ("xliminclude");
            xliminclude.run_listeners (POSTSET);
            mark_modified ();
          }
      }
  }

  void set_yliminclude (const octave_value& val)
  {
    if (! error_state)
      {
        if (yliminclude.set (val, false))
          {
            update_axis_limits ("yliminclude");
            yliminclude.run_listeners (POSTSET);
            mark_modified ();
          }
      }
  }

  void set_climinclude (const octave_value& val)
  {
    if (! error_state)
      {
        if (climinclude.set (val, false))
          {
            update_axis_limits ("climinclude");
            climinclude.run_listeners (POSTSET);
            mark_modified ();
          }
      }
  }


  protected:
    void init (void)
      {
        xdata.add_constraint (2);
        ydata.add_constraint (2);
        cdata.add_constraint ("double");
        cdata.add_constraint ("single");
        cdata.add_constraint ("logical");
        cdata.add_constraint ("uint8");
        cdata.add_constraint ("uint16");
        cdata.add_constraint ("int16");
        cdata.add_constraint (dim_vector (-1, -1));
        cdata.add_constraint (dim_vector (-1, -1, 3));
      }

  private:
    void update_xdata (void)
    {
      Matrix limits = xdata.get_limits ();
      float dp = pixel_xsize ();

      limits(0) = limits(0) - dp;
      limits(1) = limits(1) + dp;
      set_xlim (limits);
    }

    void update_ydata (void)
    {
      Matrix limits = ydata.get_limits ();
      float dp = pixel_ysize ();

      limits(0) = limits(0) - dp;
      limits(1) = limits(1) + dp;
      set_ylim (limits);
    }

    void update_cdata (void)
      {
        if (cdatamapping_is ("scaled"))
          set_clim (cdata.get_limits ());
        else
          clim = cdata.get_limits ();
      }

    float pixel_size (octave_idx_type dim, const Matrix limits)
    {
      octave_idx_type l = dim - 1;
      float dp;

      if (l > 0 && limits(0) != limits(1))
        dp = (limits(1) - limits(0))/(2*l);
      else
        {
          if (limits(1) == limits(2))
            dp = 0.5;
          else
            dp = (limits(1) - limits(0))/2;
        }
      return dp;
    }

  public:
    float  pixel_xsize (void)
    {
      return pixel_size ((get_cdata ().dims ())(1), xdata.get_limits ());
    }

    float pixel_ysize (void)
    {
      return pixel_size ((get_cdata ().dims ())(0), ydata.get_limits ());
    }
  };

private:
  properties xproperties;

public:
  image (const graphics_handle& mh, const graphics_handle& p)
    : base_graphics_object (), xproperties (mh, p)
  {
    xproperties.override_defaults (*this);
  }

  ~image (void) { }

  base_properties& get_properties (void) { return xproperties; }

  const base_properties& get_properties (void) const { return xproperties; }

  bool valid_object (void) const { return true; }
};

// ---------------------------------------------------------------------

class OCTINTERP_API patch : public base_graphics_object
{
public:
  class OCTINTERP_API properties : public base_properties
  {
  public:
    octave_value get_color_data (void) const;

    bool is_climinclude (void) const
      { return (climinclude.is_on () && cdatamapping.is ("scaled")); }
    std::string get_climinclude (void) const
      { return climinclude.current_value (); }

    bool is_aliminclude (void) const
      { return (aliminclude.is_on () && alphadatamapping.is ("scaled")); }
    std::string get_aliminclude (void) const
      { return aliminclude.current_value (); }

    // See the genprops.awk script for an explanation of the
    // properties declarations.

public:
  properties (const graphics_handle& mh, const graphics_handle& p);

  ~properties (void) { }

  void set (const caseless_str& pname, const octave_value& val);

  octave_value get (bool all = false) const;

  octave_value get (const caseless_str& pname) const;

  octave_value get (const std::string& pname) const
  {
    return get (caseless_str (pname));
  }

  octave_value get (const char *pname) const
  {
    return get (caseless_str (pname));
  }

  property get_property (const caseless_str& pname);

  std::string graphics_object_name (void) const { return go_name; }

  static property_list::pval_map_type factory_defaults (void);

private:
  static std::string go_name;

public:


  static std::set<std::string> core_property_names (void);

  static bool has_core_property (const caseless_str& pname);

  std::set<std::string> all_property_names (void) const;

  bool has_property (const caseless_str& pname) const;

private:

  array_property xdata;
  array_property ydata;
  array_property zdata;
  array_property cdata;
  radio_property cdatamapping;
  array_property faces;
  array_property facevertexalphadata;
  array_property facevertexcdata;
  array_property vertices;
  array_property vertexnormals;
  radio_property normalmode;
  color_property facecolor;
  double_radio_property facealpha;
  radio_property facelighting;
  color_property edgecolor;
  double_radio_property edgealpha;
  radio_property edgelighting;
  radio_property backfacelighting;
  double_property ambientstrength;
  double_property diffusestrength;
  double_property specularstrength;
  double_property specularexponent;
  double_property specularcolorreflectance;
  radio_property erasemode;
  radio_property linestyle;
  double_property linewidth;
  radio_property marker;
  color_property markeredgecolor;
  color_property markerfacecolor;
  double_property markersize;
  radio_property interpreter;
  string_property displayname;
  radio_property alphadatamapping;
  row_vector_property xlim;
  row_vector_property ylim;
  row_vector_property zlim;
  row_vector_property clim;
  row_vector_property alim;
  bool_property xliminclude;
  bool_property yliminclude;
  bool_property zliminclude;
  bool_property climinclude;
  bool_property aliminclude;

public:

  enum
  {
    ID_XDATA = 7000,
    ID_YDATA = 7001,
    ID_ZDATA = 7002,
    ID_CDATA = 7003,
    ID_CDATAMAPPING = 7004,
    ID_FACES = 7005,
    ID_FACEVERTEXALPHADATA = 7006,
    ID_FACEVERTEXCDATA = 7007,
    ID_VERTICES = 7008,
    ID_VERTEXNORMALS = 7009,
    ID_NORMALMODE = 7010,
    ID_FACECOLOR = 7011,
    ID_FACEALPHA = 7012,
    ID_FACELIGHTING = 7013,
    ID_EDGECOLOR = 7014,
    ID_EDGEALPHA = 7015,
    ID_EDGELIGHTING = 7016,
    ID_BACKFACELIGHTING = 7017,
    ID_AMBIENTSTRENGTH = 7018,
    ID_DIFFUSESTRENGTH = 7019,
    ID_SPECULARSTRENGTH = 7020,
    ID_SPECULAREXPONENT = 7021,
    ID_SPECULARCOLORREFLECTANCE = 7022,
    ID_ERASEMODE = 7023,
    ID_LINESTYLE = 7024,
    ID_LINEWIDTH = 7025,
    ID_MARKER = 7026,
    ID_MARKEREDGECOLOR = 7027,
    ID_MARKERFACECOLOR = 7028,
    ID_MARKERSIZE = 7029,
    ID_INTERPRETER = 7030,
    ID_DISPLAYNAME = 7031,
    ID_ALPHADATAMAPPING = 7032,
    ID_XLIM = 7033,
    ID_YLIM = 7034,
    ID_ZLIM = 7035,
    ID_CLIM = 7036,
    ID_ALIM = 7037,
    ID_XLIMINCLUDE = 7038,
    ID_YLIMINCLUDE = 7039,
    ID_ZLIMINCLUDE = 7040,
    ID_CLIMINCLUDE = 7041,
    ID_ALIMINCLUDE = 7042
  };

  octave_value get_xdata (void) const { return xdata.get (); }

  octave_value get_ydata (void) const { return ydata.get (); }

  octave_value get_zdata (void) const { return zdata.get (); }

  octave_value get_cdata (void) const { return cdata.get (); }

  bool cdatamapping_is (const std::string& v) const { return cdatamapping.is (v); }
  std::string get_cdatamapping (void) const { return cdatamapping.current_value (); }

  octave_value get_faces (void) const { return faces.get (); }

  octave_value get_facevertexalphadata (void) const { return facevertexalphadata.get (); }

  octave_value get_facevertexcdata (void) const { return facevertexcdata.get (); }

  octave_value get_vertices (void) const { return vertices.get (); }

  octave_value get_vertexnormals (void) const { return vertexnormals.get (); }

  bool normalmode_is (const std::string& v) const { return normalmode.is (v); }
  std::string get_normalmode (void) const { return normalmode.current_value (); }

  bool facecolor_is_rgb (void) const { return facecolor.is_rgb (); }
  bool facecolor_is (const std::string& v) const { return facecolor.is (v); }
  Matrix get_facecolor_rgb (void) const { return (facecolor.is_rgb () ? facecolor.rgb () : Matrix ()); }
  octave_value get_facecolor (void) const { return facecolor.get (); }

  bool facealpha_is_double (void) const { return facealpha.is_double (); }
  bool facealpha_is (const std::string& v) const { return facealpha.is (v); }
  double get_facealpha_double (void) const { return (facealpha.is_double () ? facealpha.double_value () : 0); }
  octave_value get_facealpha (void) const { return facealpha.get (); }

  bool facelighting_is (const std::string& v) const { return facelighting.is (v); }
  std::string get_facelighting (void) const { return facelighting.current_value (); }

  bool edgecolor_is_rgb (void) const { return edgecolor.is_rgb (); }
  bool edgecolor_is (const std::string& v) const { return edgecolor.is (v); }
  Matrix get_edgecolor_rgb (void) const { return (edgecolor.is_rgb () ? edgecolor.rgb () : Matrix ()); }
  octave_value get_edgecolor (void) const { return edgecolor.get (); }

  bool edgealpha_is_double (void) const { return edgealpha.is_double (); }
  bool edgealpha_is (const std::string& v) const { return edgealpha.is (v); }
  double get_edgealpha_double (void) const { return (edgealpha.is_double () ? edgealpha.double_value () : 0); }
  octave_value get_edgealpha (void) const { return edgealpha.get (); }

  bool edgelighting_is (const std::string& v) const { return edgelighting.is (v); }
  std::string get_edgelighting (void) const { return edgelighting.current_value (); }

  bool backfacelighting_is (const std::string& v) const { return backfacelighting.is (v); }
  std::string get_backfacelighting (void) const { return backfacelighting.current_value (); }

  double get_ambientstrength (void) const { return ambientstrength.double_value (); }

  double get_diffusestrength (void) const { return diffusestrength.double_value (); }

  double get_specularstrength (void) const { return specularstrength.double_value (); }

  double get_specularexponent (void) const { return specularexponent.double_value (); }

  double get_specularcolorreflectance (void) const { return specularcolorreflectance.double_value (); }

  bool erasemode_is (const std::string& v) const { return erasemode.is (v); }
  std::string get_erasemode (void) const { return erasemode.current_value (); }

  bool linestyle_is (const std::string& v) const { return linestyle.is (v); }
  std::string get_linestyle (void) const { return linestyle.current_value (); }

  double get_linewidth (void) const { return linewidth.double_value (); }

  bool marker_is (const std::string& v) const { return marker.is (v); }
  std::string get_marker (void) const { return marker.current_value (); }

  bool markeredgecolor_is_rgb (void) const { return markeredgecolor.is_rgb (); }
  bool markeredgecolor_is (const std::string& v) const { return markeredgecolor.is (v); }
  Matrix get_markeredgecolor_rgb (void) const { return (markeredgecolor.is_rgb () ? markeredgecolor.rgb () : Matrix ()); }
  octave_value get_markeredgecolor (void) const { return markeredgecolor.get (); }

  bool markerfacecolor_is_rgb (void) const { return markerfacecolor.is_rgb (); }
  bool markerfacecolor_is (const std::string& v) const { return markerfacecolor.is (v); }
  Matrix get_markerfacecolor_rgb (void) const { return (markerfacecolor.is_rgb () ? markerfacecolor.rgb () : Matrix ()); }
  octave_value get_markerfacecolor (void) const { return markerfacecolor.get (); }

  double get_markersize (void) const { return markersize.double_value (); }

  bool interpreter_is (const std::string& v) const { return interpreter.is (v); }
  std::string get_interpreter (void) const { return interpreter.current_value (); }

  std::string get_displayname (void) const { return displayname.string_value (); }

  bool alphadatamapping_is (const std::string& v) const { return alphadatamapping.is (v); }
  std::string get_alphadatamapping (void) const { return alphadatamapping.current_value (); }

  octave_value get_xlim (void) const { return xlim.get (); }

  octave_value get_ylim (void) const { return ylim.get (); }

  octave_value get_zlim (void) const { return zlim.get (); }

  octave_value get_clim (void) const { return clim.get (); }

  octave_value get_alim (void) const { return alim.get (); }

  bool is_xliminclude (void) const { return xliminclude.is_on (); }
  std::string get_xliminclude (void) const { return xliminclude.current_value (); }

  bool is_yliminclude (void) const { return yliminclude.is_on (); }
  std::string get_yliminclude (void) const { return yliminclude.current_value (); }

  bool is_zliminclude (void) const { return zliminclude.is_on (); }
  std::string get_zliminclude (void) const { return zliminclude.current_value (); }


  void set_xdata (const octave_value& val)
  {
    if (! error_state)
      {
        if (xdata.set (val, true))
          {
            update_xdata ();
            mark_modified ();
          }
      }
  }

  void set_ydata (const octave_value& val)
  {
    if (! error_state)
      {
        if (ydata.set (val, true))
          {
            update_ydata ();
            mark_modified ();
          }
      }
  }

  void set_zdata (const octave_value& val)
  {
    if (! error_state)
      {
        if (zdata.set (val, true))
          {
            update_zdata ();
            mark_modified ();
          }
      }
  }

  void set_cdata (const octave_value& val)
  {
    if (! error_state)
      {
        if (cdata.set (val, true))
          {
            update_cdata ();
            mark_modified ();
          }
      }
  }

  void set_cdatamapping (const octave_value& val)
  {
    if (! error_state)
      {
        if (cdatamapping.set (val, false))
          {
            update_axis_limits ("cdatamapping");
            cdatamapping.run_listeners (POSTSET);
            mark_modified ();
          }
      }
  }

  void set_faces (const octave_value& val)
  {
    if (! error_state)
      {
        if (faces.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_facevertexalphadata (const octave_value& val)
  {
    if (! error_state)
      {
        if (facevertexalphadata.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_facevertexcdata (const octave_value& val)
  {
    if (! error_state)
      {
        if (facevertexcdata.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_vertices (const octave_value& val)
  {
    if (! error_state)
      {
        if (vertices.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_vertexnormals (const octave_value& val)
  {
    if (! error_state)
      {
        if (vertexnormals.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_normalmode (const octave_value& val)
  {
    if (! error_state)
      {
        if (normalmode.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_facecolor (const octave_value& val)
  {
    if (! error_state)
      {
        if (facecolor.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_facealpha (const octave_value& val)
  {
    if (! error_state)
      {
        if (facealpha.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_facelighting (const octave_value& val)
  {
    if (! error_state)
      {
        if (facelighting.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_edgecolor (const octave_value& val)
  {
    if (! error_state)
      {
        if (edgecolor.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_edgealpha (const octave_value& val)
  {
    if (! error_state)
      {
        if (edgealpha.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_edgelighting (const octave_value& val)
  {
    if (! error_state)
      {
        if (edgelighting.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_backfacelighting (const octave_value& val)
  {
    if (! error_state)
      {
        if (backfacelighting.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_ambientstrength (const octave_value& val)
  {
    if (! error_state)
      {
        if (ambientstrength.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_diffusestrength (const octave_value& val)
  {
    if (! error_state)
      {
        if (diffusestrength.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_specularstrength (const octave_value& val)
  {
    if (! error_state)
      {
        if (specularstrength.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_specularexponent (const octave_value& val)
  {
    if (! error_state)
      {
        if (specularexponent.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_specularcolorreflectance (const octave_value& val)
  {
    if (! error_state)
      {
        if (specularcolorreflectance.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_erasemode (const octave_value& val)
  {
    if (! error_state)
      {
        if (erasemode.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_linestyle (const octave_value& val)
  {
    if (! error_state)
      {
        if (linestyle.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_linewidth (const octave_value& val)
  {
    if (! error_state)
      {
        if (linewidth.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_marker (const octave_value& val)
  {
    if (! error_state)
      {
        if (marker.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_markeredgecolor (const octave_value& val)
  {
    if (! error_state)
      {
        if (markeredgecolor.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_markerfacecolor (const octave_value& val)
  {
    if (! error_state)
      {
        if (markerfacecolor.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_markersize (const octave_value& val)
  {
    if (! error_state)
      {
        if (markersize.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_interpreter (const octave_value& val)
  {
    if (! error_state)
      {
        if (interpreter.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_displayname (const octave_value& val)
  {
    if (! error_state)
      {
        if (displayname.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_alphadatamapping (const octave_value& val)
  {
    if (! error_state)
      {
        if (alphadatamapping.set (val, false))
          {
            update_axis_limits ("alphadatamapping");
            alphadatamapping.run_listeners (POSTSET);
            mark_modified ();
          }
      }
  }

  void set_xlim (const octave_value& val)
  {
    if (! error_state)
      {
        if (xlim.set (val, false))
          {
            update_axis_limits ("xlim");
            xlim.run_listeners (POSTSET);
            mark_modified ();
          }
      }
  }

  void set_ylim (const octave_value& val)
  {
    if (! error_state)
      {
        if (ylim.set (val, false))
          {
            update_axis_limits ("ylim");
            ylim.run_listeners (POSTSET);
            mark_modified ();
          }
      }
  }

  void set_zlim (const octave_value& val)
  {
    if (! error_state)
      {
        if (zlim.set (val, false))
          {
            update_axis_limits ("zlim");
            zlim.run_listeners (POSTSET);
            mark_modified ();
          }
      }
  }

  void set_clim (const octave_value& val)
  {
    if (! error_state)
      {
        if (clim.set (val, false))
          {
            update_axis_limits ("clim");
            clim.run_listeners (POSTSET);
            mark_modified ();
          }
      }
  }

  void set_alim (const octave_value& val)
  {
    if (! error_state)
      {
        if (alim.set (val, false))
          {
            update_axis_limits ("alim");
            alim.run_listeners (POSTSET);
            mark_modified ();
          }
      }
  }

  void set_xliminclude (const octave_value& val)
  {
    if (! error_state)
      {
        if (xliminclude.set (val, false))
          {
            update_axis_limits ("xliminclude");
            xliminclude.run_listeners (POSTSET);
            mark_modified ();
          }
      }
  }

  void set_yliminclude (const octave_value& val)
  {
    if (! error_state)
      {
        if (yliminclude.set (val, false))
          {
            update_axis_limits ("yliminclude");
            yliminclude.run_listeners (POSTSET);
            mark_modified ();
          }
      }
  }

  void set_zliminclude (const octave_value& val)
  {
    if (! error_state)
      {
        if (zliminclude.set (val, false))
          {
            update_axis_limits ("zliminclude");
            zliminclude.run_listeners (POSTSET);
            mark_modified ();
          }
      }
  }

  void set_climinclude (const octave_value& val)
  {
    if (! error_state)
      {
        if (climinclude.set (val, false))
          {
            update_axis_limits ("climinclude");
            climinclude.run_listeners (POSTSET);
            mark_modified ();
          }
      }
  }

  void set_aliminclude (const octave_value& val)
  {
    if (! error_state)
      {
        if (aliminclude.set (val, false))
          {
            update_axis_limits ("aliminclude");
            aliminclude.run_listeners (POSTSET);
            mark_modified ();
          }
      }
  }


  protected:
    void init (void)
      {
        xdata.add_constraint (dim_vector (-1, -1));
        ydata.add_constraint (dim_vector (-1, -1));
        zdata.add_constraint (dim_vector (-1, -1));
        vertices.add_constraint (dim_vector (-1, 2));
        vertices.add_constraint (dim_vector (-1, 3));
        cdata.add_constraint (dim_vector (-1, -1));
        cdata.add_constraint (dim_vector (-1, -1, 3));
        facevertexcdata.add_constraint (dim_vector (-1, 1));
        facevertexcdata.add_constraint (dim_vector (-1, 3));
        facevertexalphadata.add_constraint (dim_vector (-1, 1));
      }

  private:
    void update_xdata (void) { set_xlim (xdata.get_limits ()); }
    void update_ydata (void) { set_ylim (ydata.get_limits ()); }
    void update_zdata (void) { set_zlim (zdata.get_limits ()); }

    void update_cdata (void)
      {
        if (cdatamapping_is ("scaled"))
          set_clim (cdata.get_limits ());
        else
          clim = cdata.get_limits ();
      }
  };

private:
  properties xproperties;

public:
  patch (const graphics_handle& mh, const graphics_handle& p)
    : base_graphics_object (), xproperties (mh, p)
  {
    xproperties.override_defaults (*this);
  }

  ~patch (void) { }

  base_properties& get_properties (void) { return xproperties; }

  const base_properties& get_properties (void) const { return xproperties; }

  bool valid_object (void) const { return true; }
};

// ---------------------------------------------------------------------

class OCTINTERP_API surface : public base_graphics_object
{
public:
  class OCTINTERP_API properties : public base_properties
  {
  public:
    octave_value get_color_data (void) const;

    bool is_climinclude (void) const
      { return (climinclude.is_on () && cdatamapping.is ("scaled")); }
    std::string get_climinclude (void) const
      { return climinclude.current_value (); }

    bool is_aliminclude (void) const
      { return (aliminclude.is_on () && alphadatamapping.is ("scaled")); }
    std::string get_aliminclude (void) const
      { return aliminclude.current_value (); }

    // See the genprops.awk script for an explanation of the
    // properties declarations.

public:
  properties (const graphics_handle& mh, const graphics_handle& p);

  ~properties (void) { }

  void set (const caseless_str& pname, const octave_value& val);

  octave_value get (bool all = false) const;

  octave_value get (const caseless_str& pname) const;

  octave_value get (const std::string& pname) const
  {
    return get (caseless_str (pname));
  }

  octave_value get (const char *pname) const
  {
    return get (caseless_str (pname));
  }

  property get_property (const caseless_str& pname);

  std::string graphics_object_name (void) const { return go_name; }

  static property_list::pval_map_type factory_defaults (void);

private:
  static std::string go_name;

public:


  static std::set<std::string> core_property_names (void);

  static bool has_core_property (const caseless_str& pname);

  std::set<std::string> all_property_names (void) const;

  bool has_property (const caseless_str& pname) const;

private:

  array_property xdata;
  array_property ydata;
  array_property zdata;
  array_property cdata;
  radio_property cdatamapping;
  string_property xdatasource;
  string_property ydatasource;
  string_property zdatasource;
  string_property cdatasource;
  color_property facecolor;
  double_radio_property facealpha;
  color_property edgecolor;
  radio_property linestyle;
  double_property linewidth;
  radio_property marker;
  color_property markeredgecolor;
  color_property markerfacecolor;
  double_property markersize;
  radio_property interpreter;
  string_property displayname;
  array_property alphadata;
  radio_property alphadatamapping;
  double_property ambientstrength;
  radio_property backfacelighting;
  double_property diffusestrength;
  double_radio_property edgealpha;
  radio_property edgelighting;
  radio_property erasemode;
  radio_property facelighting;
  radio_property meshstyle;
  radio_property normalmode;
  double_property specularcolorreflectance;
  double_property specularexponent;
  double_property specularstrength;
  array_property vertexnormals;
  row_vector_property xlim;
  row_vector_property ylim;
  row_vector_property zlim;
  row_vector_property clim;
  row_vector_property alim;
  bool_property xliminclude;
  bool_property yliminclude;
  bool_property zliminclude;
  bool_property climinclude;
  bool_property aliminclude;

public:

  enum
  {
    ID_XDATA = 8000,
    ID_YDATA = 8001,
    ID_ZDATA = 8002,
    ID_CDATA = 8003,
    ID_CDATAMAPPING = 8004,
    ID_XDATASOURCE = 8005,
    ID_YDATASOURCE = 8006,
    ID_ZDATASOURCE = 8007,
    ID_CDATASOURCE = 8008,
    ID_FACECOLOR = 8009,
    ID_FACEALPHA = 8010,
    ID_EDGECOLOR = 8011,
    ID_LINESTYLE = 8012,
    ID_LINEWIDTH = 8013,
    ID_MARKER = 8014,
    ID_MARKEREDGECOLOR = 8015,
    ID_MARKERFACECOLOR = 8016,
    ID_MARKERSIZE = 8017,
    ID_INTERPRETER = 8018,
    ID_DISPLAYNAME = 8019,
    ID_ALPHADATA = 8020,
    ID_ALPHADATAMAPPING = 8021,
    ID_AMBIENTSTRENGTH = 8022,
    ID_BACKFACELIGHTING = 8023,
    ID_DIFFUSESTRENGTH = 8024,
    ID_EDGEALPHA = 8025,
    ID_EDGELIGHTING = 8026,
    ID_ERASEMODE = 8027,
    ID_FACELIGHTING = 8028,
    ID_MESHSTYLE = 8029,
    ID_NORMALMODE = 8030,
    ID_SPECULARCOLORREFLECTANCE = 8031,
    ID_SPECULAREXPONENT = 8032,
    ID_SPECULARSTRENGTH = 8033,
    ID_VERTEXNORMALS = 8034,
    ID_XLIM = 8035,
    ID_YLIM = 8036,
    ID_ZLIM = 8037,
    ID_CLIM = 8038,
    ID_ALIM = 8039,
    ID_XLIMINCLUDE = 8040,
    ID_YLIMINCLUDE = 8041,
    ID_ZLIMINCLUDE = 8042,
    ID_CLIMINCLUDE = 8043,
    ID_ALIMINCLUDE = 8044
  };

  octave_value get_xdata (void) const { return xdata.get (); }

  octave_value get_ydata (void) const { return ydata.get (); }

  octave_value get_zdata (void) const { return zdata.get (); }

  octave_value get_cdata (void) const { return cdata.get (); }

  bool cdatamapping_is (const std::string& v) const { return cdatamapping.is (v); }
  std::string get_cdatamapping (void) const { return cdatamapping.current_value (); }

  std::string get_xdatasource (void) const { return xdatasource.string_value (); }

  std::string get_ydatasource (void) const { return ydatasource.string_value (); }

  std::string get_zdatasource (void) const { return zdatasource.string_value (); }

  std::string get_cdatasource (void) const { return cdatasource.string_value (); }

  bool facecolor_is_rgb (void) const { return facecolor.is_rgb (); }
  bool facecolor_is (const std::string& v) const { return facecolor.is (v); }
  Matrix get_facecolor_rgb (void) const { return (facecolor.is_rgb () ? facecolor.rgb () : Matrix ()); }
  octave_value get_facecolor (void) const { return facecolor.get (); }

  bool facealpha_is_double (void) const { return facealpha.is_double (); }
  bool facealpha_is (const std::string& v) const { return facealpha.is (v); }
  double get_facealpha_double (void) const { return (facealpha.is_double () ? facealpha.double_value () : 0); }
  octave_value get_facealpha (void) const { return facealpha.get (); }

  bool edgecolor_is_rgb (void) const { return edgecolor.is_rgb (); }
  bool edgecolor_is (const std::string& v) const { return edgecolor.is (v); }
  Matrix get_edgecolor_rgb (void) const { return (edgecolor.is_rgb () ? edgecolor.rgb () : Matrix ()); }
  octave_value get_edgecolor (void) const { return edgecolor.get (); }

  bool linestyle_is (const std::string& v) const { return linestyle.is (v); }
  std::string get_linestyle (void) const { return linestyle.current_value (); }

  double get_linewidth (void) const { return linewidth.double_value (); }

  bool marker_is (const std::string& v) const { return marker.is (v); }
  std::string get_marker (void) const { return marker.current_value (); }

  bool markeredgecolor_is_rgb (void) const { return markeredgecolor.is_rgb (); }
  bool markeredgecolor_is (const std::string& v) const { return markeredgecolor.is (v); }
  Matrix get_markeredgecolor_rgb (void) const { return (markeredgecolor.is_rgb () ? markeredgecolor.rgb () : Matrix ()); }
  octave_value get_markeredgecolor (void) const { return markeredgecolor.get (); }

  bool markerfacecolor_is_rgb (void) const { return markerfacecolor.is_rgb (); }
  bool markerfacecolor_is (const std::string& v) const { return markerfacecolor.is (v); }
  Matrix get_markerfacecolor_rgb (void) const { return (markerfacecolor.is_rgb () ? markerfacecolor.rgb () : Matrix ()); }
  octave_value get_markerfacecolor (void) const { return markerfacecolor.get (); }

  double get_markersize (void) const { return markersize.double_value (); }

  bool interpreter_is (const std::string& v) const { return interpreter.is (v); }
  std::string get_interpreter (void) const { return interpreter.current_value (); }

  std::string get_displayname (void) const { return displayname.string_value (); }

  octave_value get_alphadata (void) const { return alphadata.get (); }

  bool alphadatamapping_is (const std::string& v) const { return alphadatamapping.is (v); }
  std::string get_alphadatamapping (void) const { return alphadatamapping.current_value (); }

  double get_ambientstrength (void) const { return ambientstrength.double_value (); }

  bool backfacelighting_is (const std::string& v) const { return backfacelighting.is (v); }
  std::string get_backfacelighting (void) const { return backfacelighting.current_value (); }

  double get_diffusestrength (void) const { return diffusestrength.double_value (); }

  bool edgealpha_is_double (void) const { return edgealpha.is_double (); }
  bool edgealpha_is (const std::string& v) const { return edgealpha.is (v); }
  double get_edgealpha_double (void) const { return (edgealpha.is_double () ? edgealpha.double_value () : 0); }
  octave_value get_edgealpha (void) const { return edgealpha.get (); }

  bool edgelighting_is (const std::string& v) const { return edgelighting.is (v); }
  std::string get_edgelighting (void) const { return edgelighting.current_value (); }

  bool erasemode_is (const std::string& v) const { return erasemode.is (v); }
  std::string get_erasemode (void) const { return erasemode.current_value (); }

  bool facelighting_is (const std::string& v) const { return facelighting.is (v); }
  std::string get_facelighting (void) const { return facelighting.current_value (); }

  bool meshstyle_is (const std::string& v) const { return meshstyle.is (v); }
  std::string get_meshstyle (void) const { return meshstyle.current_value (); }

  bool normalmode_is (const std::string& v) const { return normalmode.is (v); }
  std::string get_normalmode (void) const { return normalmode.current_value (); }

  double get_specularcolorreflectance (void) const { return specularcolorreflectance.double_value (); }

  double get_specularexponent (void) const { return specularexponent.double_value (); }

  double get_specularstrength (void) const { return specularstrength.double_value (); }

  octave_value get_vertexnormals (void) const { return vertexnormals.get (); }

  octave_value get_xlim (void) const { return xlim.get (); }

  octave_value get_ylim (void) const { return ylim.get (); }

  octave_value get_zlim (void) const { return zlim.get (); }

  octave_value get_clim (void) const { return clim.get (); }

  octave_value get_alim (void) const { return alim.get (); }

  bool is_xliminclude (void) const { return xliminclude.is_on (); }
  std::string get_xliminclude (void) const { return xliminclude.current_value (); }

  bool is_yliminclude (void) const { return yliminclude.is_on (); }
  std::string get_yliminclude (void) const { return yliminclude.current_value (); }

  bool is_zliminclude (void) const { return zliminclude.is_on (); }
  std::string get_zliminclude (void) const { return zliminclude.current_value (); }


  void set_xdata (const octave_value& val)
  {
    if (! error_state)
      {
        if (xdata.set (val, true))
          {
            update_xdata ();
            mark_modified ();
          }
      }
  }

  void set_ydata (const octave_value& val)
  {
    if (! error_state)
      {
        if (ydata.set (val, true))
          {
            update_ydata ();
            mark_modified ();
          }
      }
  }

  void set_zdata (const octave_value& val)
  {
    if (! error_state)
      {
        if (zdata.set (val, true))
          {
            update_zdata ();
            mark_modified ();
          }
      }
  }

  void set_cdata (const octave_value& val)
  {
    if (! error_state)
      {
        if (cdata.set (val, true))
          {
            update_cdata ();
            mark_modified ();
          }
      }
  }

  void set_cdatamapping (const octave_value& val)
  {
    if (! error_state)
      {
        if (cdatamapping.set (val, false))
          {
            update_axis_limits ("cdatamapping");
            cdatamapping.run_listeners (POSTSET);
            mark_modified ();
          }
      }
  }

  void set_xdatasource (const octave_value& val)
  {
    if (! error_state)
      {
        if (xdatasource.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_ydatasource (const octave_value& val)
  {
    if (! error_state)
      {
        if (ydatasource.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_zdatasource (const octave_value& val)
  {
    if (! error_state)
      {
        if (zdatasource.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_cdatasource (const octave_value& val)
  {
    if (! error_state)
      {
        if (cdatasource.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_facecolor (const octave_value& val)
  {
    if (! error_state)
      {
        if (facecolor.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_facealpha (const octave_value& val)
  {
    if (! error_state)
      {
        if (facealpha.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_edgecolor (const octave_value& val)
  {
    if (! error_state)
      {
        if (edgecolor.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_linestyle (const octave_value& val)
  {
    if (! error_state)
      {
        if (linestyle.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_linewidth (const octave_value& val)
  {
    if (! error_state)
      {
        if (linewidth.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_marker (const octave_value& val)
  {
    if (! error_state)
      {
        if (marker.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_markeredgecolor (const octave_value& val)
  {
    if (! error_state)
      {
        if (markeredgecolor.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_markerfacecolor (const octave_value& val)
  {
    if (! error_state)
      {
        if (markerfacecolor.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_markersize (const octave_value& val)
  {
    if (! error_state)
      {
        if (markersize.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_interpreter (const octave_value& val)
  {
    if (! error_state)
      {
        if (interpreter.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_displayname (const octave_value& val)
  {
    if (! error_state)
      {
        if (displayname.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_alphadata (const octave_value& val)
  {
    if (! error_state)
      {
        if (alphadata.set (val, true))
          {
            update_alphadata ();
            mark_modified ();
          }
      }
  }

  void set_alphadatamapping (const octave_value& val)
  {
    if (! error_state)
      {
        if (alphadatamapping.set (val, false))
          {
            update_axis_limits ("alphadatamapping");
            alphadatamapping.run_listeners (POSTSET);
            mark_modified ();
          }
      }
  }

  void set_ambientstrength (const octave_value& val)
  {
    if (! error_state)
      {
        if (ambientstrength.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_backfacelighting (const octave_value& val)
  {
    if (! error_state)
      {
        if (backfacelighting.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_diffusestrength (const octave_value& val)
  {
    if (! error_state)
      {
        if (diffusestrength.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_edgealpha (const octave_value& val)
  {
    if (! error_state)
      {
        if (edgealpha.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_edgelighting (const octave_value& val)
  {
    if (! error_state)
      {
        if (edgelighting.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_erasemode (const octave_value& val)
  {
    if (! error_state)
      {
        if (erasemode.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_facelighting (const octave_value& val)
  {
    if (! error_state)
      {
        if (facelighting.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_meshstyle (const octave_value& val)
  {
    if (! error_state)
      {
        if (meshstyle.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_normalmode (const octave_value& val)
  {
    if (! error_state)
      {
        if (normalmode.set (val, true))
          {
            update_normalmode ();
            mark_modified ();
          }
      }
  }

  void set_specularcolorreflectance (const octave_value& val)
  {
    if (! error_state)
      {
        if (specularcolorreflectance.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_specularexponent (const octave_value& val)
  {
    if (! error_state)
      {
        if (specularexponent.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_specularstrength (const octave_value& val)
  {
    if (! error_state)
      {
        if (specularstrength.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_vertexnormals (const octave_value& val)
  {
    if (! error_state)
      {
        if (vertexnormals.set (val, true))
          {
            update_vertexnormals ();
            mark_modified ();
          }
      }
  }

  void set_xlim (const octave_value& val)
  {
    if (! error_state)
      {
        if (xlim.set (val, false))
          {
            update_axis_limits ("xlim");
            xlim.run_listeners (POSTSET);
            mark_modified ();
          }
      }
  }

  void set_ylim (const octave_value& val)
  {
    if (! error_state)
      {
        if (ylim.set (val, false))
          {
            update_axis_limits ("ylim");
            ylim.run_listeners (POSTSET);
            mark_modified ();
          }
      }
  }

  void set_zlim (const octave_value& val)
  {
    if (! error_state)
      {
        if (zlim.set (val, false))
          {
            update_axis_limits ("zlim");
            zlim.run_listeners (POSTSET);
            mark_modified ();
          }
      }
  }

  void set_clim (const octave_value& val)
  {
    if (! error_state)
      {
        if (clim.set (val, false))
          {
            update_axis_limits ("clim");
            clim.run_listeners (POSTSET);
            mark_modified ();
          }
      }
  }

  void set_alim (const octave_value& val)
  {
    if (! error_state)
      {
        if (alim.set (val, false))
          {
            update_axis_limits ("alim");
            alim.run_listeners (POSTSET);
            mark_modified ();
          }
      }
  }

  void set_xliminclude (const octave_value& val)
  {
    if (! error_state)
      {
        if (xliminclude.set (val, false))
          {
            update_axis_limits ("xliminclude");
            xliminclude.run_listeners (POSTSET);
            mark_modified ();
          }
      }
  }

  void set_yliminclude (const octave_value& val)
  {
    if (! error_state)
      {
        if (yliminclude.set (val, false))
          {
            update_axis_limits ("yliminclude");
            yliminclude.run_listeners (POSTSET);
            mark_modified ();
          }
      }
  }

  void set_zliminclude (const octave_value& val)
  {
    if (! error_state)
      {
        if (zliminclude.set (val, false))
          {
            update_axis_limits ("zliminclude");
            zliminclude.run_listeners (POSTSET);
            mark_modified ();
          }
      }
  }

  void set_climinclude (const octave_value& val)
  {
    if (! error_state)
      {
        if (climinclude.set (val, false))
          {
            update_axis_limits ("climinclude");
            climinclude.run_listeners (POSTSET);
            mark_modified ();
          }
      }
  }

  void set_aliminclude (const octave_value& val)
  {
    if (! error_state)
      {
        if (aliminclude.set (val, false))
          {
            update_axis_limits ("aliminclude");
            aliminclude.run_listeners (POSTSET);
            mark_modified ();
          }
      }
  }


  protected:
    void init (void)
      {
        xdata.add_constraint (dim_vector (-1, -1));
        ydata.add_constraint (dim_vector (-1, -1));
        zdata.add_constraint (dim_vector (-1, -1));
        alphadata.add_constraint ("single");
        alphadata.add_constraint ("double");
        alphadata.add_constraint ("uint8");
        alphadata.add_constraint (dim_vector (-1, -1));
        vertexnormals.add_constraint (dim_vector (-1, -1, 3));
        cdata.add_constraint ("single");
        cdata.add_constraint ("double");
        cdata.add_constraint ("uint8");
        cdata.add_constraint (dim_vector (-1, -1));
        cdata.add_constraint (dim_vector (-1, -1, 3));
      }

  private:
    void update_normals (void);

    void update_xdata (void)
      {
        update_normals ();
        set_xlim (xdata.get_limits ());
      }

    void update_ydata (void)
      {
        update_normals ();
        set_ylim (ydata.get_limits ());
      }

    void update_zdata (void)
      {
        update_normals ();
        set_zlim (zdata.get_limits ());
      }

    void update_cdata (void)
      {
        if (cdatamapping_is ("scaled"))
          set_clim (cdata.get_limits ());
        else
          clim = cdata.get_limits ();
      }

    void update_alphadata (void)
      {
        if (alphadatamapping_is ("scaled"))
          set_alim (alphadata.get_limits ());
        else
          alim = alphadata.get_limits ();
      }

    void update_normalmode (void)
      { update_normals (); }

    void update_vertexnormals (void)
      { set_normalmode ("manual"); }
  };

private:
  properties xproperties;

public:
  surface (const graphics_handle& mh, const graphics_handle& p)
    : base_graphics_object (), xproperties (mh, p)
  {
    xproperties.override_defaults (*this);
  }

  ~surface (void) { }

  base_properties& get_properties (void) { return xproperties; }

  const base_properties& get_properties (void) const { return xproperties; }

  bool valid_object (void) const { return true; }
};

// ---------------------------------------------------------------------

class OCTINTERP_API hggroup : public base_graphics_object
{
public:
  class OCTINTERP_API properties : public base_properties
  {
  public:
    void remove_child (const graphics_handle& h)
      {
        base_properties::remove_child (h);
        update_limits ();
      }

    void adopt (const graphics_handle& h)
      {

        base_properties::adopt (h);
        update_limits (h);
      }

    // See the genprops.awk script for an explanation of the
    // properties declarations.

public:
  properties (const graphics_handle& mh, const graphics_handle& p);

  ~properties (void) { }

  void set (const caseless_str& pname, const octave_value& val);

  octave_value get (bool all = false) const;

  octave_value get (const caseless_str& pname) const;

  octave_value get (const std::string& pname) const
  {
    return get (caseless_str (pname));
  }

  octave_value get (const char *pname) const
  {
    return get (caseless_str (pname));
  }

  property get_property (const caseless_str& pname);

  std::string graphics_object_name (void) const { return go_name; }

  static property_list::pval_map_type factory_defaults (void);

private:
  static std::string go_name;

public:


  static std::set<std::string> core_property_names (void);

  static bool has_core_property (const caseless_str& pname);

  std::set<std::string> all_property_names (void) const;

  bool has_property (const caseless_str& pname) const;

private:

  row_vector_property xlim;
  row_vector_property ylim;
  row_vector_property zlim;
  row_vector_property clim;
  row_vector_property alim;
  bool_property xliminclude;
  bool_property yliminclude;
  bool_property zliminclude;
  bool_property climinclude;
  bool_property aliminclude;

public:

  enum
  {
    ID_XLIM = 9000,
    ID_YLIM = 9001,
    ID_ZLIM = 9002,
    ID_CLIM = 9003,
    ID_ALIM = 9004,
    ID_XLIMINCLUDE = 9005,
    ID_YLIMINCLUDE = 9006,
    ID_ZLIMINCLUDE = 9007,
    ID_CLIMINCLUDE = 9008,
    ID_ALIMINCLUDE = 9009
  };

  octave_value get_xlim (void) const { return xlim.get (); }

  octave_value get_ylim (void) const { return ylim.get (); }

  octave_value get_zlim (void) const { return zlim.get (); }

  octave_value get_clim (void) const { return clim.get (); }

  octave_value get_alim (void) const { return alim.get (); }

  bool is_xliminclude (void) const { return xliminclude.is_on (); }
  std::string get_xliminclude (void) const { return xliminclude.current_value (); }

  bool is_yliminclude (void) const { return yliminclude.is_on (); }
  std::string get_yliminclude (void) const { return yliminclude.current_value (); }

  bool is_zliminclude (void) const { return zliminclude.is_on (); }
  std::string get_zliminclude (void) const { return zliminclude.current_value (); }

  bool is_climinclude (void) const { return climinclude.is_on (); }
  std::string get_climinclude (void) const { return climinclude.current_value (); }

  bool is_aliminclude (void) const { return aliminclude.is_on (); }
  std::string get_aliminclude (void) const { return aliminclude.current_value (); }


  void set_xlim (const octave_value& val)
  {
    if (! error_state)
      {
        if (xlim.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_ylim (const octave_value& val)
  {
    if (! error_state)
      {
        if (ylim.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_zlim (const octave_value& val)
  {
    if (! error_state)
      {
        if (zlim.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_clim (const octave_value& val)
  {
    if (! error_state)
      {
        if (clim.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_alim (const octave_value& val)
  {
    if (! error_state)
      {
        if (alim.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_xliminclude (const octave_value& val)
  {
    if (! error_state)
      {
        if (xliminclude.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_yliminclude (const octave_value& val)
  {
    if (! error_state)
      {
        if (yliminclude.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_zliminclude (const octave_value& val)
  {
    if (! error_state)
      {
        if (zliminclude.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_climinclude (const octave_value& val)
  {
    if (! error_state)
      {
        if (climinclude.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_aliminclude (const octave_value& val)
  {
    if (! error_state)
      {
        if (aliminclude.set (val, true))
          {
            mark_modified ();
          }
      }
  }


  private:
      void update_limits (void) const;

      void update_limits (const graphics_handle& h) const;

  protected:
    void init (void)
      { }

  };

private:
  properties xproperties;

public:
  hggroup (const graphics_handle& mh, const graphics_handle& p)
    : base_graphics_object (), xproperties (mh, p)
  {
    xproperties.override_defaults (*this);
  }

  ~hggroup (void) { }

  base_properties& get_properties (void) { return xproperties; }

  const base_properties& get_properties (void) const { return xproperties; }

  bool valid_object (void) const { return true; }

  void update_axis_limits (const std::string& axis_type);

  void update_axis_limits (const std::string& axis_type,
                           const graphics_handle& h);

};

// ---------------------------------------------------------------------

class OCTINTERP_API uimenu : public base_graphics_object
{
public:
  class OCTINTERP_API properties : public base_properties
  {
  public:
    void remove_child (const graphics_handle& h)
      {
        base_properties::remove_child (h);
      }

    void adopt (const graphics_handle& h)
      {
        base_properties::adopt (h);
      }

    // See the genprops.awk script for an explanation of the
    // properties declarations.

public:
  properties (const graphics_handle& mh, const graphics_handle& p);

  ~properties (void) { }

  void set (const caseless_str& pname, const octave_value& val);

  octave_value get (bool all = false) const;

  octave_value get (const caseless_str& pname) const;

  octave_value get (const std::string& pname) const
  {
    return get (caseless_str (pname));
  }

  octave_value get (const char *pname) const
  {
    return get (caseless_str (pname));
  }

  property get_property (const caseless_str& pname);

  std::string graphics_object_name (void) const { return go_name; }

  static property_list::pval_map_type factory_defaults (void);

private:
  static std::string go_name;

public:


  static std::set<std::string> core_property_names (void);

  static bool has_core_property (const caseless_str& pname);

  std::set<std::string> all_property_names (void) const;

  bool has_property (const caseless_str& pname) const;

private:

  any_property __object__;
  string_property accelerator;
  callback_property callback;
  bool_property checked;
  bool_property enable;
  color_property foregroundcolor;
  string_property label;
  double_property position;
  bool_property separator;
  string_property fltk_label;

public:

  enum
  {
    ID___OBJECT__ = 10000,
    ID_ACCELERATOR = 10001,
    ID_CALLBACK = 10002,
    ID_CHECKED = 10003,
    ID_ENABLE = 10004,
    ID_FOREGROUNDCOLOR = 10005,
    ID_LABEL = 10006,
    ID_POSITION = 10007,
    ID_SEPARATOR = 10008,
    ID_FLTK_LABEL = 10009
  };

  octave_value get___object__ (void) const { return __object__.get (); }

  std::string get_accelerator (void) const { return accelerator.string_value (); }

  void execute_callback (const octave_value& data = octave_value ()) const { callback.execute (data); }
  octave_value get_callback (void) const { return callback.get (); }

  bool is_checked (void) const { return checked.is_on (); }
  std::string get_checked (void) const { return checked.current_value (); }

  bool is_enable (void) const { return enable.is_on (); }
  std::string get_enable (void) const { return enable.current_value (); }

  bool foregroundcolor_is_rgb (void) const { return foregroundcolor.is_rgb (); }
  bool foregroundcolor_is (const std::string& v) const { return foregroundcolor.is (v); }
  Matrix get_foregroundcolor_rgb (void) const { return (foregroundcolor.is_rgb () ? foregroundcolor.rgb () : Matrix ()); }
  octave_value get_foregroundcolor (void) const { return foregroundcolor.get (); }

  std::string get_label (void) const { return label.string_value (); }

  double get_position (void) const { return position.double_value (); }

  bool is_separator (void) const { return separator.is_on (); }
  std::string get_separator (void) const { return separator.current_value (); }

  std::string get_fltk_label (void) const { return fltk_label.string_value (); }


  void set___object__ (const octave_value& val)
  {
    if (! error_state)
      {
        if (__object__.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_accelerator (const octave_value& val)
  {
    if (! error_state)
      {
        if (accelerator.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_callback (const octave_value& val)
  {
    if (! error_state)
      {
        if (callback.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_checked (const octave_value& val)
  {
    if (! error_state)
      {
        if (checked.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_enable (const octave_value& val)
  {
    if (! error_state)
      {
        if (enable.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_foregroundcolor (const octave_value& val)
  {
    if (! error_state)
      {
        if (foregroundcolor.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_label (const octave_value& val)
  {
    if (! error_state)
      {
        if (label.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_position (const octave_value& val)
  {
    if (! error_state)
      {
        if (position.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_separator (const octave_value& val)
  {
    if (! error_state)
      {
        if (separator.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_fltk_label (const octave_value& val)
  {
    if (! error_state)
      {
        if (fltk_label.set (val, true))
          {
            mark_modified ();
          }
      }
  }


  protected:
    void init (void)
      { }
  };

private:
  properties xproperties;

public:
  uimenu (const graphics_handle& mh, const graphics_handle& p)
    : base_graphics_object (), xproperties (mh, p)
  {
    xproperties.override_defaults (*this);
  }

  ~uimenu (void) { }

  base_properties& get_properties (void) { return xproperties; }

  const base_properties& get_properties (void) const { return xproperties; }

  bool valid_object (void) const { return true; }

};

// ---------------------------------------------------------------------

class OCTINTERP_API uicontextmenu : public base_graphics_object
{
public:
  class OCTINTERP_API properties : public base_properties
  {
  public:
    // See the genprops.awk script for an explanation of the
    // properties declarations.

public:
  properties (const graphics_handle& mh, const graphics_handle& p);

  ~properties (void) { }

  void set (const caseless_str& pname, const octave_value& val);

  octave_value get (bool all = false) const;

  octave_value get (const caseless_str& pname) const;

  octave_value get (const std::string& pname) const
  {
    return get (caseless_str (pname));
  }

  octave_value get (const char *pname) const
  {
    return get (caseless_str (pname));
  }

  property get_property (const caseless_str& pname);

  std::string graphics_object_name (void) const { return go_name; }

  static property_list::pval_map_type factory_defaults (void);

private:
  static std::string go_name;

public:


  static std::set<std::string> core_property_names (void);

  static bool has_core_property (const caseless_str& pname);

  std::set<std::string> all_property_names (void) const;

  bool has_property (const caseless_str& pname) const;

private:

  any_property __object__;
  callback_property callback;
  array_property position;

public:

  enum
  {
    ID___OBJECT__ = 11000,
    ID_CALLBACK = 11001,
    ID_POSITION = 11002
  };

  octave_value get___object__ (void) const { return __object__.get (); }

  void execute_callback (const octave_value& data = octave_value ()) const { callback.execute (data); }
  octave_value get_callback (void) const { return callback.get (); }

  octave_value get_position (void) const { return position.get (); }


  void set___object__ (const octave_value& val)
  {
    if (! error_state)
      {
        if (__object__.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_callback (const octave_value& val)
  {
    if (! error_state)
      {
        if (callback.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_position (const octave_value& val)
  {
    if (! error_state)
      {
        if (position.set (val, true))
          {
            mark_modified ();
          }
      }
  }


  protected:
    void init (void)
      {
        position.add_constraint (dim_vector (1, 2));
        position.add_constraint (dim_vector (2, 1));
        visible.set (octave_value (true));
      }
  };

private:
  properties xproperties;

public:
  uicontextmenu (const graphics_handle& mh, const graphics_handle& p)
    : base_graphics_object (), xproperties (mh, p)
  {
    xproperties.override_defaults (*this);
  }

  ~uicontextmenu (void) { }

  base_properties& get_properties (void) { return xproperties; }

  const base_properties& get_properties (void) const { return xproperties; }

  bool valid_object (void) const { return true; }

};

// ---------------------------------------------------------------------

class OCTINTERP_API uicontrol : public base_graphics_object
{
public:
  class OCTINTERP_API properties : public base_properties
  {
  public:
    Matrix get_boundingbox (bool internal = false,
                            const Matrix& parent_pix_size = Matrix ()) const;

    double get_fontsize_points (double box_pix_height = 0) const;

    // See the genprops.awk script for an explanation of the
    // properties declarations.

public:
  properties (const graphics_handle& mh, const graphics_handle& p);

  ~properties (void) { }

  void set (const caseless_str& pname, const octave_value& val);

  octave_value get (bool all = false) const;

  octave_value get (const caseless_str& pname) const;

  octave_value get (const std::string& pname) const
  {
    return get (caseless_str (pname));
  }

  octave_value get (const char *pname) const
  {
    return get (caseless_str (pname));
  }

  property get_property (const caseless_str& pname);

  std::string graphics_object_name (void) const { return go_name; }

  static property_list::pval_map_type factory_defaults (void);

private:
  static std::string go_name;

public:


  static std::set<std::string> core_property_names (void);

  static bool has_core_property (const caseless_str& pname);

  std::set<std::string> all_property_names (void) const;

  bool has_property (const caseless_str& pname) const;

private:

  any_property __object__;
  color_property backgroundcolor;
  callback_property callback;
  array_property cdata;
  bool_property clipping;
  radio_property enable;
  array_property extent;
  radio_property fontangle;
  string_property fontname;
  double_property fontsize;
  radio_property fontunits;
  radio_property fontweight;
  color_property foregroundcolor;
  radio_property horizontalalignment;
  callback_property keypressfcn;
  double_property listboxtop;
  double_property max;
  double_property min;
  array_property position;
  array_property sliderstep;
  string_array_property string;
  radio_property style;
  string_property tooltipstring;
  radio_property units;
  row_vector_property value;
  radio_property verticalalignment;

public:

  enum
  {
    ID___OBJECT__ = 12000,
    ID_BACKGROUNDCOLOR = 12001,
    ID_CALLBACK = 12002,
    ID_CDATA = 12003,
    ID_CLIPPING = 12004,
    ID_ENABLE = 12005,
    ID_EXTENT = 12006,
    ID_FONTANGLE = 12007,
    ID_FONTNAME = 12008,
    ID_FONTSIZE = 12009,
    ID_FONTUNITS = 12010,
    ID_FONTWEIGHT = 12011,
    ID_FOREGROUNDCOLOR = 12012,
    ID_HORIZONTALALIGNMENT = 12013,
    ID_KEYPRESSFCN = 12014,
    ID_LISTBOXTOP = 12015,
    ID_MAX = 12016,
    ID_MIN = 12017,
    ID_POSITION = 12018,
    ID_SLIDERSTEP = 12019,
    ID_STRING = 12020,
    ID_STYLE = 12021,
    ID_TOOLTIPSTRING = 12022,
    ID_UNITS = 12023,
    ID_VALUE = 12024,
    ID_VERTICALALIGNMENT = 12025
  };

  octave_value get___object__ (void) const { return __object__.get (); }

  bool backgroundcolor_is_rgb (void) const { return backgroundcolor.is_rgb (); }
  bool backgroundcolor_is (const std::string& v) const { return backgroundcolor.is (v); }
  Matrix get_backgroundcolor_rgb (void) const { return (backgroundcolor.is_rgb () ? backgroundcolor.rgb () : Matrix ()); }
  octave_value get_backgroundcolor (void) const { return backgroundcolor.get (); }

  void execute_callback (const octave_value& data = octave_value ()) const { callback.execute (data); }
  octave_value get_callback (void) const { return callback.get (); }

  octave_value get_cdata (void) const { return cdata.get (); }

  bool is_clipping (void) const { return clipping.is_on (); }
  std::string get_clipping (void) const { return clipping.current_value (); }

  bool enable_is (const std::string& v) const { return enable.is (v); }
  std::string get_enable (void) const { return enable.current_value (); }

  octave_value get_extent (void) const;

  bool fontangle_is (const std::string& v) const { return fontangle.is (v); }
  std::string get_fontangle (void) const { return fontangle.current_value (); }

  std::string get_fontname (void) const { return fontname.string_value (); }

  double get_fontsize (void) const { return fontsize.double_value (); }

  bool fontunits_is (const std::string& v) const { return fontunits.is (v); }
  std::string get_fontunits (void) const { return fontunits.current_value (); }

  bool fontweight_is (const std::string& v) const { return fontweight.is (v); }
  std::string get_fontweight (void) const { return fontweight.current_value (); }

  bool foregroundcolor_is_rgb (void) const { return foregroundcolor.is_rgb (); }
  bool foregroundcolor_is (const std::string& v) const { return foregroundcolor.is (v); }
  Matrix get_foregroundcolor_rgb (void) const { return (foregroundcolor.is_rgb () ? foregroundcolor.rgb () : Matrix ()); }
  octave_value get_foregroundcolor (void) const { return foregroundcolor.get (); }

  bool horizontalalignment_is (const std::string& v) const { return horizontalalignment.is (v); }
  std::string get_horizontalalignment (void) const { return horizontalalignment.current_value (); }

  void execute_keypressfcn (const octave_value& data = octave_value ()) const { keypressfcn.execute (data); }
  octave_value get_keypressfcn (void) const { return keypressfcn.get (); }

  double get_listboxtop (void) const { return listboxtop.double_value (); }

  double get_max (void) const { return max.double_value (); }

  double get_min (void) const { return min.double_value (); }

  octave_value get_position (void) const { return position.get (); }

  octave_value get_sliderstep (void) const { return sliderstep.get (); }

  std::string get_string_string (void) const { return string.string_value (); }
  string_vector get_string_vector (void) const { return string.string_vector_value (); }
  octave_value get_string (void) const { return string.get (); }

  bool style_is (const std::string& v) const { return style.is (v); }
  std::string get_style (void) const { return style.current_value (); }

  std::string get_tooltipstring (void) const { return tooltipstring.string_value (); }

  bool units_is (const std::string& v) const { return units.is (v); }
  std::string get_units (void) const { return units.current_value (); }

  octave_value get_value (void) const { return value.get (); }

  bool verticalalignment_is (const std::string& v) const { return verticalalignment.is (v); }
  std::string get_verticalalignment (void) const { return verticalalignment.current_value (); }


  void set___object__ (const octave_value& val)
  {
    if (! error_state)
      {
        if (__object__.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_backgroundcolor (const octave_value& val)
  {
    if (! error_state)
      {
        if (backgroundcolor.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_callback (const octave_value& val)
  {
    if (! error_state)
      {
        if (callback.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_cdata (const octave_value& val)
  {
    if (! error_state)
      {
        if (cdata.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_clipping (const octave_value& val)
  {
    if (! error_state)
      {
        if (clipping.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_enable (const octave_value& val)
  {
    if (! error_state)
      {
        if (enable.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_extent (const octave_value& val)
  {
    if (! error_state)
      {
        if (extent.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_fontangle (const octave_value& val)
  {
    if (! error_state)
      {
        if (fontangle.set (val, true))
          {
            update_fontangle ();
            mark_modified ();
          }
      }
  }

  void set_fontname (const octave_value& val)
  {
    if (! error_state)
      {
        if (fontname.set (val, true))
          {
            update_fontname ();
            mark_modified ();
          }
      }
  }

  void set_fontsize (const octave_value& val)
  {
    if (! error_state)
      {
        if (fontsize.set (val, true))
          {
            update_fontsize ();
            mark_modified ();
          }
      }
  }

  void set_fontunits (const octave_value& val);

  void set_fontweight (const octave_value& val)
  {
    if (! error_state)
      {
        if (fontweight.set (val, true))
          {
            update_fontweight ();
            mark_modified ();
          }
      }
  }

  void set_foregroundcolor (const octave_value& val)
  {
    if (! error_state)
      {
        if (foregroundcolor.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_horizontalalignment (const octave_value& val)
  {
    if (! error_state)
      {
        if (horizontalalignment.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_keypressfcn (const octave_value& val)
  {
    if (! error_state)
      {
        if (keypressfcn.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_listboxtop (const octave_value& val)
  {
    if (! error_state)
      {
        if (listboxtop.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_max (const octave_value& val)
  {
    if (! error_state)
      {
        if (max.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_min (const octave_value& val)
  {
    if (! error_state)
      {
        if (min.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_position (const octave_value& val)
  {
    if (! error_state)
      {
        if (position.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_sliderstep (const octave_value& val)
  {
    if (! error_state)
      {
        if (sliderstep.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_string (const octave_value& val)
  {
    if (! error_state)
      {
        if (string.set (val, true))
          {
            update_string ();
            mark_modified ();
          }
      }
  }

  void set_style (const octave_value& val);

  void set_tooltipstring (const octave_value& val)
  {
    if (! error_state)
      {
        if (tooltipstring.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_units (const octave_value& val)
  {
    if (! error_state)
      {
        if (units.set (val, true))
          {
            update_units ();
            mark_modified ();
          }
      }
  }

  void set_value (const octave_value& val)
  {
    if (! error_state)
      {
        if (value.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_verticalalignment (const octave_value& val)
  {
    if (! error_state)
      {
        if (verticalalignment.set (val, true))
          {
            mark_modified ();
          }
      }
  }


  private:
    std::string cached_units;

  protected:
    void init (void)
      {
        cdata.add_constraint ("double");
        cdata.add_constraint ("single");
        cdata.add_constraint ("uint8");
        cdata.add_constraint (dim_vector (-1, -1, 3));
        position.add_constraint (dim_vector (1, 4));
        sliderstep.add_constraint (dim_vector (1, 2));
        cached_units = get_units ();
      }
    
    void update_text_extent (void);

    void update_string (void) { update_text_extent (); }
    void update_fontname (void) { update_text_extent (); }
    void update_fontsize (void) { update_text_extent (); }
    void update_fontangle (void) { update_text_extent (); }
    void update_fontweight (void) { update_text_extent (); }
    void update_fontunits (const caseless_str& old_units);

    void update_units (void);

  };

private:
  properties xproperties;

public:
  uicontrol (const graphics_handle& mh, const graphics_handle& p)
    : base_graphics_object (), xproperties (mh, p)
  {
    xproperties.override_defaults (*this);
  }

  ~uicontrol (void) { }

  base_properties& get_properties (void) { return xproperties; }

  const base_properties& get_properties (void) const { return xproperties; }

  bool valid_object (void) const { return true; }
};

// ---------------------------------------------------------------------

class OCTINTERP_API uipanel : public base_graphics_object
{
public:
  class OCTINTERP_API properties : public base_properties
  {
  public:
    Matrix get_boundingbox (bool internal = false,
                            const Matrix& parent_pix_size = Matrix ()) const;

    double get_fontsize_points (double box_pix_height = 0) const;

    // See the genprops.awk script for an explanation of the
    // properties declarations.

public:
  properties (const graphics_handle& mh, const graphics_handle& p);

  ~properties (void) { }

  void set (const caseless_str& pname, const octave_value& val);

  octave_value get (bool all = false) const;

  octave_value get (const caseless_str& pname) const;

  octave_value get (const std::string& pname) const
  {
    return get (caseless_str (pname));
  }

  octave_value get (const char *pname) const
  {
    return get (caseless_str (pname));
  }

  property get_property (const caseless_str& pname);

  std::string graphics_object_name (void) const { return go_name; }

  static property_list::pval_map_type factory_defaults (void);

private:
  static std::string go_name;

public:


  static std::set<std::string> core_property_names (void);

  static bool has_core_property (const caseless_str& pname);

  std::set<std::string> all_property_names (void) const;

  bool has_property (const caseless_str& pname) const;

private:

  any_property __object__;
  color_property backgroundcolor;
  radio_property bordertype;
  double_property borderwidth;
  radio_property fontangle;
  string_property fontname;
  double_property fontsize;
  radio_property fontunits;
  radio_property fontweight;
  color_property foregroundcolor;
  color_property highlightcolor;
  array_property position;
  callback_property resizefcn;
  color_property shadowcolor;
  string_property title;
  radio_property titleposition;
  radio_property units;

public:

  enum
  {
    ID___OBJECT__ = 13000,
    ID_BACKGROUNDCOLOR = 13001,
    ID_BORDERTYPE = 13002,
    ID_BORDERWIDTH = 13003,
    ID_FONTANGLE = 13004,
    ID_FONTNAME = 13005,
    ID_FONTSIZE = 13006,
    ID_FONTUNITS = 13007,
    ID_FONTWEIGHT = 13008,
    ID_FOREGROUNDCOLOR = 13009,
    ID_HIGHLIGHTCOLOR = 13010,
    ID_POSITION = 13011,
    ID_RESIZEFCN = 13012,
    ID_SHADOWCOLOR = 13013,
    ID_TITLE = 13014,
    ID_TITLEPOSITION = 13015,
    ID_UNITS = 13016
  };

  octave_value get___object__ (void) const { return __object__.get (); }

  bool backgroundcolor_is_rgb (void) const { return backgroundcolor.is_rgb (); }
  bool backgroundcolor_is (const std::string& v) const { return backgroundcolor.is (v); }
  Matrix get_backgroundcolor_rgb (void) const { return (backgroundcolor.is_rgb () ? backgroundcolor.rgb () : Matrix ()); }
  octave_value get_backgroundcolor (void) const { return backgroundcolor.get (); }

  bool bordertype_is (const std::string& v) const { return bordertype.is (v); }
  std::string get_bordertype (void) const { return bordertype.current_value (); }

  double get_borderwidth (void) const { return borderwidth.double_value (); }

  bool fontangle_is (const std::string& v) const { return fontangle.is (v); }
  std::string get_fontangle (void) const { return fontangle.current_value (); }

  std::string get_fontname (void) const { return fontname.string_value (); }

  double get_fontsize (void) const { return fontsize.double_value (); }

  bool fontunits_is (const std::string& v) const { return fontunits.is (v); }
  std::string get_fontunits (void) const { return fontunits.current_value (); }

  bool fontweight_is (const std::string& v) const { return fontweight.is (v); }
  std::string get_fontweight (void) const { return fontweight.current_value (); }

  bool foregroundcolor_is_rgb (void) const { return foregroundcolor.is_rgb (); }
  bool foregroundcolor_is (const std::string& v) const { return foregroundcolor.is (v); }
  Matrix get_foregroundcolor_rgb (void) const { return (foregroundcolor.is_rgb () ? foregroundcolor.rgb () : Matrix ()); }
  octave_value get_foregroundcolor (void) const { return foregroundcolor.get (); }

  bool highlightcolor_is_rgb (void) const { return highlightcolor.is_rgb (); }
  bool highlightcolor_is (const std::string& v) const { return highlightcolor.is (v); }
  Matrix get_highlightcolor_rgb (void) const { return (highlightcolor.is_rgb () ? highlightcolor.rgb () : Matrix ()); }
  octave_value get_highlightcolor (void) const { return highlightcolor.get (); }

  octave_value get_position (void) const { return position.get (); }

  void execute_resizefcn (const octave_value& data = octave_value ()) const { resizefcn.execute (data); }
  octave_value get_resizefcn (void) const { return resizefcn.get (); }

  bool shadowcolor_is_rgb (void) const { return shadowcolor.is_rgb (); }
  bool shadowcolor_is (const std::string& v) const { return shadowcolor.is (v); }
  Matrix get_shadowcolor_rgb (void) const { return (shadowcolor.is_rgb () ? shadowcolor.rgb () : Matrix ()); }
  octave_value get_shadowcolor (void) const { return shadowcolor.get (); }

  std::string get_title (void) const { return title.string_value (); }

  bool titleposition_is (const std::string& v) const { return titleposition.is (v); }
  std::string get_titleposition (void) const { return titleposition.current_value (); }

  bool units_is (const std::string& v) const { return units.is (v); }
  std::string get_units (void) const { return units.current_value (); }


  void set___object__ (const octave_value& val)
  {
    if (! error_state)
      {
        if (__object__.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_backgroundcolor (const octave_value& val)
  {
    if (! error_state)
      {
        if (backgroundcolor.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_bordertype (const octave_value& val)
  {
    if (! error_state)
      {
        if (bordertype.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_borderwidth (const octave_value& val)
  {
    if (! error_state)
      {
        if (borderwidth.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_fontangle (const octave_value& val)
  {
    if (! error_state)
      {
        if (fontangle.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_fontname (const octave_value& val)
  {
    if (! error_state)
      {
        if (fontname.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_fontsize (const octave_value& val)
  {
    if (! error_state)
      {
        if (fontsize.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_fontunits (const octave_value& val);

  void set_fontweight (const octave_value& val)
  {
    if (! error_state)
      {
        if (fontweight.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_foregroundcolor (const octave_value& val)
  {
    if (! error_state)
      {
        if (foregroundcolor.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_highlightcolor (const octave_value& val)
  {
    if (! error_state)
      {
        if (highlightcolor.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_position (const octave_value& val)
  {
    if (! error_state)
      {
        if (position.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_resizefcn (const octave_value& val)
  {
    if (! error_state)
      {
        if (resizefcn.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_shadowcolor (const octave_value& val)
  {
    if (! error_state)
      {
        if (shadowcolor.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_title (const octave_value& val)
  {
    if (! error_state)
      {
        if (title.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_titleposition (const octave_value& val)
  {
    if (! error_state)
      {
        if (titleposition.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_units (const octave_value& val);


  protected:
    void init (void)
      {
        position.add_constraint (dim_vector (1, 4));
      }
    
    void update_units (const caseless_str& old_units);
    void update_fontunits (const caseless_str& old_units);

  };

private:
  properties xproperties;

public:
  uipanel (const graphics_handle& mh, const graphics_handle& p)
    : base_graphics_object (), xproperties (mh, p)
  {
    xproperties.override_defaults (*this);
  }

  ~uipanel (void) { }

  base_properties& get_properties (void) { return xproperties; }

  const base_properties& get_properties (void) const { return xproperties; }

  bool valid_object (void) const { return true; }
};

// ---------------------------------------------------------------------

class OCTINTERP_API uitoolbar : public base_graphics_object
{
public:
  class OCTINTERP_API properties : public base_properties
  {
  public:
    // See the genprops.awk script for an explanation of the
    // properties declarations.

public:
  properties (const graphics_handle& mh, const graphics_handle& p);

  ~properties (void) { }

  void set (const caseless_str& pname, const octave_value& val);

  octave_value get (bool all = false) const;

  octave_value get (const caseless_str& pname) const;

  octave_value get (const std::string& pname) const
  {
    return get (caseless_str (pname));
  }

  octave_value get (const char *pname) const
  {
    return get (caseless_str (pname));
  }

  property get_property (const caseless_str& pname);

  std::string graphics_object_name (void) const { return go_name; }

  static property_list::pval_map_type factory_defaults (void);

private:
  static std::string go_name;

public:


  static std::set<std::string> core_property_names (void);

  static bool has_core_property (const caseless_str& pname);

  std::set<std::string> all_property_names (void) const;

  bool has_property (const caseless_str& pname) const;

private:

  any_property __object__;

public:

  enum
  {
    ID___OBJECT__ = 14000
  };

  octave_value get___object__ (void) const { return __object__.get (); }


  void set___object__ (const octave_value& val)
  {
    if (! error_state)
      {
        if (__object__.set (val, true))
          {
            mark_modified ();
          }
      }
  }


  protected:
    void init (void)
      { }
  };

private:
  properties xproperties;

public:
  uitoolbar (const graphics_handle& mh, const graphics_handle& p)
    : base_graphics_object (), xproperties (mh, p), default_properties ()
  {
    xproperties.override_defaults (*this);
  }

  ~uitoolbar (void) { }

  void override_defaults (base_graphics_object& obj)
  {
    // Allow parent (figure) to override first (properties knows how
    // to find the parent object).
    xproperties.override_defaults (obj);

    // Now override with our defaults.  If the default_properties
    // list includes the properties for all defaults (line,
    // surface, etc.) then we don't have to know the type of OBJ
    // here, we just call its set function and let it decide which
    // properties from the list to use.
    obj.set_from_list (default_properties);
  }

  void set (const caseless_str& name, const octave_value& value)
  {
    if (name.compare ("default", 7))
      // strip "default", pass rest to function that will
      // parse the remainder and add the element to the
      // default_properties map.
      default_properties.set (name.substr (7), value);
    else
      xproperties.set (name, value);
  }

  octave_value get (const caseless_str& name) const
  {
    octave_value retval;

    if (name.compare ("default", 7))
      retval = get_default (name.substr (7));
    else
      retval = xproperties.get (name);

    return retval;
  }

  octave_value get_default (const caseless_str& name) const;

  octave_value get_defaults (void) const
  {
    return default_properties.as_struct ("default");
  }

  base_properties& get_properties (void) { return xproperties; }

  const base_properties& get_properties (void) const { return xproperties; }

  bool valid_object (void) const { return true; }

  void reset_default_properties (void);

private:
  property_list default_properties;
};

// ---------------------------------------------------------------------

class OCTINTERP_API uipushtool : public base_graphics_object
{
public:
  class OCTINTERP_API properties : public base_properties
  {
  public:
    // See the genprops.awk script for an explanation of the
    // properties declarations.

public:
  properties (const graphics_handle& mh, const graphics_handle& p);

  ~properties (void) { }

  void set (const caseless_str& pname, const octave_value& val);

  octave_value get (bool all = false) const;

  octave_value get (const caseless_str& pname) const;

  octave_value get (const std::string& pname) const
  {
    return get (caseless_str (pname));
  }

  octave_value get (const char *pname) const
  {
    return get (caseless_str (pname));
  }

  property get_property (const caseless_str& pname);

  std::string graphics_object_name (void) const { return go_name; }

  static property_list::pval_map_type factory_defaults (void);

private:
  static std::string go_name;

public:


  static std::set<std::string> core_property_names (void);

  static bool has_core_property (const caseless_str& pname);

  std::set<std::string> all_property_names (void) const;

  bool has_property (const caseless_str& pname) const;

private:

  any_property __object__;
  array_property cdata;
  callback_property clickedcallback;
  bool_property enable;
  bool_property separator;
  string_property tooltipstring;

public:

  enum
  {
    ID___OBJECT__ = 15000,
    ID_CDATA = 15001,
    ID_CLICKEDCALLBACK = 15002,
    ID_ENABLE = 15003,
    ID_SEPARATOR = 15004,
    ID_TOOLTIPSTRING = 15005
  };

  octave_value get___object__ (void) const { return __object__.get (); }

  octave_value get_cdata (void) const { return cdata.get (); }

  void execute_clickedcallback (const octave_value& data = octave_value ()) const { clickedcallback.execute (data); }
  octave_value get_clickedcallback (void) const { return clickedcallback.get (); }

  bool is_enable (void) const { return enable.is_on (); }
  std::string get_enable (void) const { return enable.current_value (); }

  bool is_separator (void) const { return separator.is_on (); }
  std::string get_separator (void) const { return separator.current_value (); }

  std::string get_tooltipstring (void) const { return tooltipstring.string_value (); }


  void set___object__ (const octave_value& val)
  {
    if (! error_state)
      {
        if (__object__.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_cdata (const octave_value& val)
  {
    if (! error_state)
      {
        if (cdata.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_clickedcallback (const octave_value& val)
  {
    if (! error_state)
      {
        if (clickedcallback.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_enable (const octave_value& val)
  {
    if (! error_state)
      {
        if (enable.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_separator (const octave_value& val)
  {
    if (! error_state)
      {
        if (separator.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_tooltipstring (const octave_value& val)
  {
    if (! error_state)
      {
        if (tooltipstring.set (val, true))
          {
            mark_modified ();
          }
      }
  }


  protected:
    void init (void)
      {
        cdata.add_constraint ("double");
        cdata.add_constraint ("single");
        cdata.add_constraint ("uint8");
        cdata.add_constraint (dim_vector (-1, -1, 3));
      }
  };

private:
  properties xproperties;

public:
  uipushtool (const graphics_handle& mh, const graphics_handle& p)
    : base_graphics_object (), xproperties (mh, p)
  {
    xproperties.override_defaults (*this);
  }

  ~uipushtool (void) { }

  base_properties& get_properties (void) { return xproperties; }

  const base_properties& get_properties (void) const { return xproperties; }

  bool valid_object (void) const { return true; }

};

// ---------------------------------------------------------------------

class OCTINTERP_API uitoggletool : public base_graphics_object
{
public:
  class OCTINTERP_API properties : public base_properties
  {
  public:
    // See the genprops.awk script for an explanation of the
    // properties declarations.

public:
  properties (const graphics_handle& mh, const graphics_handle& p);

  ~properties (void) { }

  void set (const caseless_str& pname, const octave_value& val);

  octave_value get (bool all = false) const;

  octave_value get (const caseless_str& pname) const;

  octave_value get (const std::string& pname) const
  {
    return get (caseless_str (pname));
  }

  octave_value get (const char *pname) const
  {
    return get (caseless_str (pname));
  }

  property get_property (const caseless_str& pname);

  std::string graphics_object_name (void) const { return go_name; }

  static property_list::pval_map_type factory_defaults (void);

private:
  static std::string go_name;

public:


  static std::set<std::string> core_property_names (void);

  static bool has_core_property (const caseless_str& pname);

  std::set<std::string> all_property_names (void) const;

  bool has_property (const caseless_str& pname) const;

private:

  any_property __object__;
  array_property cdata;
  callback_property clickedcallback;
  bool_property enable;
  callback_property offcallback;
  callback_property oncallback;
  bool_property separator;
  bool_property state;
  string_property tooltipstring;

public:

  enum
  {
    ID___OBJECT__ = 16000,
    ID_CDATA = 16001,
    ID_CLICKEDCALLBACK = 16002,
    ID_ENABLE = 16003,
    ID_OFFCALLBACK = 16004,
    ID_ONCALLBACK = 16005,
    ID_SEPARATOR = 16006,
    ID_STATE = 16007,
    ID_TOOLTIPSTRING = 16008
  };

  octave_value get___object__ (void) const { return __object__.get (); }

  octave_value get_cdata (void) const { return cdata.get (); }

  void execute_clickedcallback (const octave_value& data = octave_value ()) const { clickedcallback.execute (data); }
  octave_value get_clickedcallback (void) const { return clickedcallback.get (); }

  bool is_enable (void) const { return enable.is_on (); }
  std::string get_enable (void) const { return enable.current_value (); }

  void execute_offcallback (const octave_value& data = octave_value ()) const { offcallback.execute (data); }
  octave_value get_offcallback (void) const { return offcallback.get (); }

  void execute_oncallback (const octave_value& data = octave_value ()) const { oncallback.execute (data); }
  octave_value get_oncallback (void) const { return oncallback.get (); }

  bool is_separator (void) const { return separator.is_on (); }
  std::string get_separator (void) const { return separator.current_value (); }

  bool is_state (void) const { return state.is_on (); }
  std::string get_state (void) const { return state.current_value (); }

  std::string get_tooltipstring (void) const { return tooltipstring.string_value (); }


  void set___object__ (const octave_value& val)
  {
    if (! error_state)
      {
        if (__object__.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_cdata (const octave_value& val)
  {
    if (! error_state)
      {
        if (cdata.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_clickedcallback (const octave_value& val)
  {
    if (! error_state)
      {
        if (clickedcallback.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_enable (const octave_value& val)
  {
    if (! error_state)
      {
        if (enable.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_offcallback (const octave_value& val)
  {
    if (! error_state)
      {
        if (offcallback.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_oncallback (const octave_value& val)
  {
    if (! error_state)
      {
        if (oncallback.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_separator (const octave_value& val)
  {
    if (! error_state)
      {
        if (separator.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_state (const octave_value& val)
  {
    if (! error_state)
      {
        if (state.set (val, true))
          {
            mark_modified ();
          }
      }
  }

  void set_tooltipstring (const octave_value& val)
  {
    if (! error_state)
      {
        if (tooltipstring.set (val, true))
          {
            mark_modified ();
          }
      }
  }


  protected:
    void init (void)
      {
        cdata.add_constraint ("double");
        cdata.add_constraint ("single");
        cdata.add_constraint ("uint8");
        cdata.add_constraint (dim_vector (-1, -1, 3));
      }
  };

private:
  properties xproperties;

public:
  uitoggletool (const graphics_handle& mh, const graphics_handle& p)
    : base_graphics_object (), xproperties (mh, p)
  {
    xproperties.override_defaults (*this);
  }

  ~uitoggletool (void) { }

  base_properties& get_properties (void) { return xproperties; }

  const base_properties& get_properties (void) const { return xproperties; }

  bool valid_object (void) const { return true; }

};

// ---------------------------------------------------------------------

octave_value
get_property_from_handle (double handle, const std::string &property,
                          const std::string &func);
bool
set_property_in_handle (double handle, const std::string &property,
                        const octave_value &arg, const std::string &func);

// ---------------------------------------------------------------------

class graphics_event;

class
base_graphics_event
{
public:
  friend class graphics_event;

  base_graphics_event (void) : count (1) { }

  virtual ~base_graphics_event (void) { }

  virtual void execute (void) = 0;

private:
  octave_refcount<int> count;
};

class
graphics_event
{
public:
  typedef void (*event_fcn) (void*);

  graphics_event (void) : rep (0) { }

  graphics_event (const graphics_event& e) : rep (e.rep)
    {
      rep->count++;
    }

  ~graphics_event (void)
    {
      if (rep && --rep->count == 0)
        delete rep;
    }

  graphics_event& operator = (const graphics_event& e)
    {
      if (rep != e.rep)
        {
          if (rep && --rep->count == 0)
            delete rep;

          rep = e.rep;
          if (rep)
            rep->count++;
        }

      return *this;
    }

  void execute (void)
    { if (rep) rep->execute (); }

  bool ok (void) const
    { return (rep != 0); }

  static graphics_event
      create_callback_event (const graphics_handle& h,
                             const std::string& name,
                             const octave_value& data = Matrix ());
  
  static graphics_event
      create_callback_event (const graphics_handle& h,
                             const octave_value& cb,
                             const octave_value& data = Matrix ());

  static graphics_event
      create_function_event (event_fcn fcn, void *data = 0);

  static graphics_event
      create_set_event (const graphics_handle& h, const std::string& name,
                        const octave_value& value,
                        bool notify_toolkit = true);
private:
  base_graphics_event *rep;
};

class OCTINTERP_API gh_manager
{
protected:

  gh_manager (void);

public:

  static void create_instance (void);

  static bool instance_ok (void)
  {
    bool retval = true;

    if (! instance)
      create_instance ();

    if (! instance)
      {
        ::error ("unable to create gh_manager!");

        retval = false;
      }

    return retval;
  }

  static void cleanup_instance (void) { delete instance; instance = 0; }

  static graphics_handle get_handle (bool integer_figure_handle)
  {
    return instance_ok ()
      ? instance->do_get_handle (integer_figure_handle) : graphics_handle ();
  }

  static void free (const graphics_handle& h)
  {
    if (instance_ok ())
      instance->do_free (h);
  }

  static void renumber_figure (const graphics_handle& old_gh,
                               const graphics_handle& new_gh)
  {
    if (instance_ok ())
      instance->do_renumber_figure (old_gh, new_gh);
  }

  static graphics_handle lookup (double val)
  {
    return instance_ok () ? instance->do_lookup (val) : graphics_handle ();
  }

  static graphics_handle lookup (const octave_value& val)
  {
    return val.is_real_scalar ()
      ? lookup (val.double_value ()) : graphics_handle ();
  }

  static graphics_object get_object (double val)
  {
    return get_object (lookup (val));
  }

  static graphics_object get_object (const graphics_handle& h)
  {
    return instance_ok () ? instance->do_get_object (h) : graphics_object ();
  }

  static graphics_handle
  make_graphics_handle (const std::string& go_name,
                        const graphics_handle& parent,
                        bool integer_figure_handle = false,
                        bool do_createfcn = true,
                        bool do_notify_toolkit = true)
  {
    return instance_ok ()
      ? instance->do_make_graphics_handle (go_name, parent,
                                           integer_figure_handle,
                                           do_createfcn, do_notify_toolkit)
      : graphics_handle ();
  }

  static graphics_handle make_figure_handle (double val,
                                             bool do_notify_toolkit = true)
  {
    return instance_ok ()
      ? instance->do_make_figure_handle (val, do_notify_toolkit)
      : graphics_handle ();
  }

  static void push_figure (const graphics_handle& h)
  {
    if (instance_ok ())
      instance->do_push_figure (h);
  }

  static void pop_figure (const graphics_handle& h)
  {
    if (instance_ok ())
      instance->do_pop_figure (h);
  }

  static graphics_handle current_figure (void)
  {
    return instance_ok ()
      ? instance->do_current_figure () : graphics_handle ();
  }

  static Matrix handle_list (bool show_hidden = false)
  {
    return instance_ok ()
      ? instance->do_handle_list (show_hidden) : Matrix ();
  }

  static void lock (void)
  {
    if (instance_ok ())
      instance->do_lock ();
  }

  static bool try_lock (void)
  {
    if (instance_ok ())
      return instance->do_try_lock ();
    else
      return false;
  }

  static void unlock (void)
  {
    if (instance_ok ())
      instance->do_unlock ();
  }
  
  static Matrix figure_handle_list (bool show_hidden = false)
  {
    return instance_ok ()
      ? instance->do_figure_handle_list (show_hidden) : Matrix ();
  }

  static void execute_listener (const graphics_handle& h,
                                const octave_value& l)
  {
    if (instance_ok ())
      instance->do_execute_listener (h, l);
  }

  static void execute_callback (const graphics_handle& h,
                                const std::string& name,
                                const octave_value& data = Matrix ())
  {
    octave_value cb;

    if (true)
      {
        gh_manager::auto_lock lock;

        graphics_object go = get_object (h);

        if (go.valid_object ())
          cb = go.get (name);
      }

    if (! error_state)
      execute_callback (h, cb, data);
  }

  static void execute_callback (const graphics_handle& h,
                                const octave_value& cb,
                                const octave_value& data = Matrix ())
  {
    if (instance_ok ())
      instance->do_execute_callback (h, cb, data);
  }

  static void post_callback (const graphics_handle& h,
                             const std::string& name,
                             const octave_value& data = Matrix ())
  {
    if (instance_ok ())
      instance->do_post_callback (h, name, data);
  }
  
  static void post_function (graphics_event::event_fcn fcn, void* data = 0)
  {
    if (instance_ok ())
      instance->do_post_function (fcn, data);
  }

  static void post_set (const graphics_handle& h, const std::string& name,
                        const octave_value& value, bool notify_toolkit = true)
  {
    if (instance_ok ())
      instance->do_post_set (h, name, value, notify_toolkit);
  }

  static int process_events (void)
  {
    return (instance_ok () ?  instance->do_process_events () : 0);
  }

  static int flush_events (void)
  {
    return (instance_ok () ?  instance->do_process_events (true) : 0);
  }

  static void enable_event_processing (bool enable = true)
    {
      if (instance_ok ())
        instance->do_enable_event_processing (enable);
    }

  static bool is_handle_visible (const graphics_handle& h)
  {
    bool retval = false;

    graphics_object go = get_object (h);

    if (go.valid_object ())
      retval = go.is_handle_visible ();

    return retval;
  }

  static void close_all_figures (void)
  {
    if (instance_ok ())
      instance->do_close_all_figures ();
  }

public:
  class auto_lock : public octave_autolock
  {
  public:
    auto_lock (bool wait = true)
      : octave_autolock (instance_ok ()
                         ? instance->graphics_lock
                         : octave_mutex (),
                         wait)
      { }

  private:

    // No copying!
    auto_lock (const auto_lock&);
    auto_lock& operator = (const auto_lock&);
  };

private:

  static gh_manager *instance;

  typedef std::map<graphics_handle, graphics_object>::iterator iterator;
  typedef std::map<graphics_handle, graphics_object>::const_iterator const_iterator;

  typedef std::set<graphics_handle>::iterator free_list_iterator;
  typedef std::set<graphics_handle>::const_iterator const_free_list_iterator;

  typedef std::list<graphics_handle>::iterator figure_list_iterator;
  typedef std::list<graphics_handle>::const_iterator const_figure_list_iterator;

  // A map of handles to graphics objects.
  std::map<graphics_handle, graphics_object> handle_map;

  // The available graphics handles.
  std::set<graphics_handle> handle_free_list;

  // The next handle available if handle_free_list is empty.
  double next_handle;

  // The allocated figure handles.  Top of the stack is most recently
  // created.
  std::list<graphics_handle> figure_list;

  // The lock for accessing the graphics sytsem.
  octave_mutex graphics_lock;

  // The list of events queued by graphics toolkits.
  std::list<graphics_event> event_queue;

  // The stack of callback objects.
  std::list<graphics_object> callback_objects;

  // A flag telling whether event processing must be constantly on.
  int event_processing;

  graphics_handle do_get_handle (bool integer_figure_handle);

  void do_free (const graphics_handle& h);

  void do_renumber_figure (const graphics_handle& old_gh,
                           const graphics_handle& new_gh);

  graphics_handle do_lookup (double val)
  {
    iterator p = (xisnan (val) ? handle_map.end () : handle_map.find (val));

    return (p != handle_map.end ()) ? p->first : graphics_handle ();
  }

  graphics_object do_get_object (const graphics_handle& h)
  {
    iterator p = (h.ok () ? handle_map.find (h) : handle_map.end ());

    return (p != handle_map.end ()) ? p->second : graphics_object ();
  }

  graphics_handle do_make_graphics_handle (const std::string& go_name,
                                           const graphics_handle& p,
                                           bool integer_figure_handle,
                                           bool do_createfcn,
                                           bool do_notify_toolkit);

  graphics_handle do_make_figure_handle (double val, bool do_notify_toolkit);

  Matrix do_handle_list (bool show_hidden)
  {
    Matrix retval (1, handle_map.size ());

    octave_idx_type i = 0;
    for (const_iterator p = handle_map.begin (); p != handle_map.end (); p++)
      {
        graphics_handle h = p->first;

        if (show_hidden || is_handle_visible (h))
          retval(i++) = h.value ();
      }

    retval.resize (1, i);

    return retval;
  }

  Matrix do_figure_handle_list (bool show_hidden)
  {
    Matrix retval (1, figure_list.size ());

    octave_idx_type i = 0;
    for (const_figure_list_iterator p = figure_list.begin ();
         p != figure_list.end ();
         p++)
      {
        graphics_handle h = *p;

        if (show_hidden || is_handle_visible (h))
          retval(i++) = h.value ();
      }

    retval.resize (1, i);

    return retval;
  }

  void do_push_figure (const graphics_handle& h);

  void do_pop_figure (const graphics_handle& h);

  graphics_handle do_current_figure (void) const
  {
    graphics_handle retval;

    for (const_figure_list_iterator p = figure_list.begin ();
         p != figure_list.end ();
         p++)
      {
        graphics_handle h = *p;

        if (is_handle_visible (h))
          retval = h;
      }

    return retval;
  }

  void do_lock (void) { graphics_lock.lock (); }

  bool do_try_lock (void) { return graphics_lock.try_lock (); }

  void do_unlock (void) { graphics_lock.unlock (); }

  void do_execute_listener (const graphics_handle& h, const octave_value& l);

  void do_execute_callback (const graphics_handle& h, const octave_value& cb,
                            const octave_value& data);

  void do_post_callback (const graphics_handle& h, const std::string name,
                         const octave_value& data);
  
  void do_post_function (graphics_event::event_fcn fcn, void* fcn_data);

  void do_post_set (const graphics_handle& h, const std::string name,
                    const octave_value& value, bool notify_toolkit = true);

  int do_process_events (bool force = false);

  void do_close_all_figures (void);

  static void restore_gcbo (void)
  {
    if (instance_ok ())
      instance->do_restore_gcbo ();
  }

  void do_restore_gcbo (void);

  void do_post_event (const graphics_event& e);

  void do_enable_event_processing (bool enable = true);
};

void get_children_limits (double& min_val, double& max_val,
                          double& min_pos, double& max_neg,
                          const Matrix& kids, char limit_type);

OCTINTERP_API int calc_dimensions (const graphics_object& gh);

// This function is NOT equivalent to the scripting language function gcf.
OCTINTERP_API graphics_handle gcf (void);

// This function is NOT equivalent to the scripting language function gca.
OCTINTERP_API graphics_handle gca (void);

OCTINTERP_API void close_all_figures (void);

#endif
