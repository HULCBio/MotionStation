## Copyright (C) 2004-2012 David Bateman and Andy Adler
##
## This file is part of Octave.
##
## Octave is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or (at
## your option) any later version.
##
## Octave is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with Octave; see the file COPYING.  If not, see
## <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {@var{x} =} spconvert (@var{m})
## This function converts for a simple sparse matrix format easily
## produced by other programs into Octave's internal sparse format.  The
## input @var{x} is either a 3 or 4 column real matrix, containing
## the row, column, real and imaginary parts of the elements of the
## sparse matrix.  An element with a zero real and imaginary part can
## be used to force a particular matrix size.
## @end deftypefn

function s = spconvert (m)

  if (issparse (m))
    s = m;
  else
    sz = size (m);
    if (nargin != 1 || ! ismatrix (m) || ! isreal (m)
        || length (sz) != 2 || (sz(2) != 3 && sz(2) != 4))
      error ("spconvert: argument must be sparse or real matrix with 3 or 4 columns");
    elseif (sz(2) == 3)
      s = sparse (m(:,1), m(:,2), m(:,3));
    else
      s = sparse (m(:,1), m(:,2), m(:,3) + 1i*m(:,4));
    endif
  endif

endfunction


%!test
%! i = [1; 3; 5];
%! j = [2; 4; 6];
%! v = [7; 8; 9];
%! s = spconvert ([i, j, v]);
%! assert (issparse (s));
%! [fi, fj, fv] = find (s);
%! assert (isequal (i, fi) && isequal (j, fj) && isequal (v, fv));
%! s = spconvert ([i, j, v, j]);
%! [fi, fj, fv] = find (s);
%! assert (isequal (i, fi) && isequal (j, fj) && isequal (complex (v, j), fv));
%! assert (size (spconvert ([1, 1, 3; 5, 15, 0])), [5, 15]);

%% Test input validation
%!error spconvert ()
%!error spconvert (1, 2)
%!error spconvert ({[1 2 3]})
%!error spconvert ([1 2])
%!error spconvert ([1 2 3i])
%!error spconvert ([1 2 3 4 5])
