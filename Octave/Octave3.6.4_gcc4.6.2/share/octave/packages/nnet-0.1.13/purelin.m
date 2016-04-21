## Copyright (C) 2005 Michel D. Schmid  <michaelschmid@users.sourceforge.net>
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
## @deftypefn {Function File} {}@var{a}= purelin (@var{n})
## @code{purelin} is a linear transfer function used
## by neural networks
## @end deftypefn

## Author: Michel D. Schmid

function a = purelin(n)

   a = n;

endfunction

%!assert(purelin(2),2);
%!assert(purelin(-2),-2);
%!assert(purelin(0),0);

%!error  # this test must throw an error!
%! assert(purelin(2),1);