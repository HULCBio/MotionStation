## Copyright (C) 2006 Muthiah Annamalai <muthiah.annamalai@uta.edu>
## 
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; If not, see <http://www.gnu.org/licenses/>.
##

## -*- texinfo -*-
## @deftypefn {Function File} {} marginalc (@var{xy})
##
## Computes marginal  probabilities along columns. Where @var{xy} is the
## transition matrix
## @end deftypefn
## @seealso{marginalr}

function val=marginalc(XY)
  val=sum(XY);
  return
end
%!assert(marginalc([0.7 0.1 0.2; 0.1 0.7 0.2; 0.2 0.2 0.6]),[1 1 1],1)
