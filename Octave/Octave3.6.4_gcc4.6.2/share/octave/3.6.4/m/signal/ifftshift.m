## Copyright (C) 1997-2012 Vincent Cautaerts
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
## @deftypefn  {Function File} {} ifftshift (@var{x})
## @deftypefnx {Function File} {} ifftshift (@var{x}, @var{dim})
## Undo the action of the @code{fftshift} function.  For even length
## @var{x}, @code{fftshift} is its own inverse, but odd lengths differ
## slightly.
## @end deftypefn

## Author: Vincent Cautaerts <vincent@comf5.comm.eng.osaka-u.ac.jp>
## Created: July 1997
## Adapted-By: jwe
## Modified-By: Paul Kienzle, converted from fftshift
## Modified-By: David Bateman, add NDArray capability and option dim arg

function retval = ifftshift (x, dim)

  retval = 0;

  if (nargin != 1 && nargin != 2)
    print_usage ();
  endif

  if (nargin == 2)
    if (! isscalar (dim))
      error ("ifftshift: dimension must be an integer scalar");
    endif
    nd = ndims (x);
    sz = size (x);
    sz2 = floor (sz(dim) / 2);
    idx = repmat ({':'}, nd, 1);
    idx{dim} = [sz2+1:sz(dim), 1:sz2];
    retval = x(idx{:});
  else
    if (isvector (x))
      xl = length (x);
      xx = floor (xl/2);
      retval = x([xx+1:xl, 1:xx]);
    elseif (ismatrix (x))
      nd = ndims (x);
      sz = size (x);
      sz2 = floor (sz ./ 2);
      idx = cell ();
      for i = 1:nd
        idx{i} = [sz2(i)+1:sz(i), 1:sz2(i)];
      endfor
      retval = x(idx{:});
    else
      error ("ifftshift: expecting vector or matrix argument");
    endif
  endif

endfunction

%!test
%!  x = [0:7];
%!  y = ifftshift (x);
%!  assert(y, [4 5 6 7 0 1 2 3]);
%!  assert(ifftshift (y), x);

%!test
%!  x = [0:6];
%!  y = ifftshift (x);
%!  assert(y, [3 4 5 6 0 1 2]);
%!  assert(ifftshift (y), [6 0 1 2 3 4 5]);

%!test
%!  x = [0:7]';
%!  y = ifftshift (x);
%!  assert(y, [4;5;6;7;0;1;2;3]);
%!  assert(ifftshift (y), x);

%!test
%!  x = [0:6]';
%!  y = ifftshift (x);
%!  assert(y, [3;4;5;6;0;1;2]);
%!  assert(ifftshift (y), [6;0;1;2;3;4;5]);

%!test
%!  x = [0:3];
%!  x = [x;2*x;3*x+1;4*x+1];
%!  y = ifftshift (x);
%!  assert(y, [[7 10 1 4];[9 13 1 5];[2 3 0 1];[4 6 0 2]]);
%!  assert(ifftshift (y), x);

%!test
%!  x = [0:3];
%!  x = [x;2*x;3*x+1;4*x+1];
%!  y = ifftshift (x,1);
%!  assert(y, [[1 4 7 10];[1 5 9 13];[0 1 2 3];[0 2 4 6]]);
%!  assert(ifftshift (y,1), x);

%!test
%!  x = [0:3];
%!  x = [x;2*x;3*x+1;4*x+1];
%!  y = ifftshift (x,2);
%!  assert(y, [[2 3 0 1];[4 6 0 2];[7 10 1 4];[9 13 1 5]]);
%!  assert(ifftshift (y,2), x);

