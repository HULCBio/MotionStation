## Copyright (C) 2000 Kai Habel <kai.habel@gmx.de>
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
## @deftypefn {Function File} @var{s}= std2 (@var{I})
## Returns the standard deviation for a 2d real type matrix.
## Uses @code{std (I(:))}
## @seealso{mean2,std}
## @end deftypefn

function s = std2 (I)

  if !(nargin == 1)
    print_usage ();
  endif

  if !(ismatrix(I) && isreal(I))
    error("std2: argument must be a real type matrix");
  endif

  s = std (I(:));
endfunction
