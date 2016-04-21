## Copyright (C) 2007 Michel D. Schmid <michaelschmid@users.sourceforge.net>
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
## along with this program; see the file COPYING.  If not, write to the Free
## Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
## 02110-1301, USA.

## -*- texinfo -*-
## @deftypefn {Function File} {}[@var{a} = dsatlin (@var{n})
##
## @end deftypefn

## @seealso{dpurelin,dtansig,dlogsig}

## Author: Michel D. Schmid


function a = dsatlin(n)


  # the derivative of satlin is easy:
  # where satlin is constant, the derivative is 0
  # else, because without variable n, the derivative is 1
  if (n>=0 && n<=1)
    a = 1;
  else
    a = 0;
  endif

endfunction