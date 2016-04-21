## Copyright (C) 2008 Soren Hauberg <soren@hauberg.org>
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
## @deftypefn {Function File} @var{B} = imcomplement(@var{A})
## Computes the complement image. Intuitively this corresponds to the intensity
## of bright and dark regions being reversed.
##
## For binary images, the complement is computed as @code{!@var{A}}, for floating
## point images it is computed as @code{1 - @var{A}}, and for integer images as
## @code{intmax(class(@var{A})) - @var{A}}.
## @seealso{imadd, imdivide, imlincomb, immultiply, imsubtract}
## @end deftypefn

function B = imcomplement(A)
  ## Check input
  if (nargin != 1)
    error("imcomplement: not enough input arguments");
  endif
  if (!ismatrix(A))
    error("imcomplement: input must be an array");
  endif

  ## Take action depending on the class of A
  if (isa(A, "double") || isa(A, "single"))
    B = 1 - A;
  elseif (islogical(A))
    B = !A;
  elseif (isinteger(A))
    B = intmax(class(A)) - A;
  else
    error("imcomplement: unsupported input class: '%s'", class(A));
  endif
endfunction
