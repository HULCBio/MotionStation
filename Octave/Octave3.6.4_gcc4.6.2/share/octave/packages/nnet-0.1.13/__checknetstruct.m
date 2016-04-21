## Copyright (C) 2006 Michel D. Schmid  <michaelschmid@users.sourceforge.net>
##
##
## This program is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2, or (at your option)
## any later version.
##
## This program is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; see the file COPYING.  If not, see
## <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {}[@var{isTrue}] = __checknetstruct (@var{net})
## This function will check if a valid structure seems to be a neural network
## structure
##
## @noindent
##
## left side arguments:
## @noindent
##
## right side arguments:
## @noindent
##
##
## @noindent
## are equivalent.
## @end deftypefn

## @seealso{newff,prestd,trastd}

## Author: Michel D. Schmid


function isTrue = __checknetstruct(net)

  isTrue = 0;
  ## first check, if it's a structure
  if (isstruct(net) && isfield(net,"networkType"))
    isTrue = 1;
  endif

endfunction