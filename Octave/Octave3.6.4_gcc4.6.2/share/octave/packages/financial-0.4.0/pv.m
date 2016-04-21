## Copyright (C) 1995-1996, 1998, 2000, 2002, 2004-2007 Kurt Hornik <Kurt.Hornik@wu-wien.ac.at>
##
## This program is free software; you can redistribute it and/or modify it under
## the terms of the GNU General Public License as published by the Free Software
## Foundation; either version 3 of the License, or (at your option) any later
## version.
##
## This program is distributed in the hope that it will be useful, but WITHOUT
## ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
## FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
## details.
##
## You should have received a copy of the GNU General Public License along with
## this program; if not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {} pv (@var{r}, @var{n}, @var{p}, @var{l}, @var{method})
## Returns the present value of an investment that will pay off @var{p} for @var{n}
## consecutive periods, assuming an interest @var{r}.
##
## The optional argument @var{l} may be used to specify an additional
## lump-sum payment made at the end of @var{n} periods.
##
## The optional argument @var{method} may be used to specify whether
## payments are made at the end (@code{"e"}, default) or at the
## beginning (@code{"b"}) of each period.
##
## Note that the rate @var{r} is specified as a fraction (i.e., 0.05,
## not 5 percent).
## @seealso{pmt, nper, rate, npv}
## @end deftypefn

function v = pv (r, n, p, l, m)

  if (nargin < 3 || nargin > 5)
    print_usage ();
  endif

  if (! (isscalar (r) && r > -1))
    error ("pv: r must be a scalar > -1");
  elseif (! (isscalar (n) && n > 0))
    error ("pv: n must be a positive scalar");
  elseif (! isscalar (p))
    error ("pv: p must be a scalar");
  endif

  if (r != 0)
    v = p * (1 - (1 + r)^(-n)) / r;
  else
    v = p * n;
  endif

  if (nargin > 3)
    if (nargin == 5)
      if (! ischar (m))
        error ("pv: `method' must be a string");
      endif
    elseif (ischar (l))
      m = l;
      l = 0;
    else
      m = "e";
    endif
    if (strcmp (m, "b"))
      v = v * (1 + r);
    endif
    if (isscalar (l))
      v = v + pvl (r, n, l);
    else
      error ("pv: l must be a scalar");
    endif
  endif

endfunction
