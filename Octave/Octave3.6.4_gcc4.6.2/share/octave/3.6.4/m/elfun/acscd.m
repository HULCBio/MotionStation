## Copyright (C) 2006-2012 David Bateman
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
## @deftypefn {Function File} {} acscd (@var{x})
## Compute the inverse cosecant in degrees for each element of @var{x}.
## @seealso{cscd, acsc}
## @end deftypefn

## Author: David Bateman <dbateman@free.fr>

function y = acscd (x)
  if (nargin != 1)
    print_usage ();
  endif
  y = acsc(x) .* 180 ./ pi;
endfunction

%!error(acscd())
%!error(acscd(1,2))
%!assert(acscd(0:10:90),180/pi*acsc(0:10:90),-10*eps)
