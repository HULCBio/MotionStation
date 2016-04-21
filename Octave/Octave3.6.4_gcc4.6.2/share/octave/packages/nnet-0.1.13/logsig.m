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
## along with this program; see the file COPYING.  If not, see
## <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {}@var{a} = logsig (@var{n})
## @code{logsig} is a non-linear transfer function used to train
## neural networks.
## This function can be used in newff(...) to create a new feed forward
## multi-layer neural network.
##
## @end deftypefn

## @seealso{purelin,tansig}

## Author: Michel D. Schmid


function a = logsig(n)


  a = 1 ./ (1 + exp(-n));
  ## attention with critical values ==> infinite values
  ## must be set to 1! Still the same problem as in "tansig"
  i = find(!finite(a));
  a(i) = sign(n(i));

endfunction