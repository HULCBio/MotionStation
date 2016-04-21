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
## @deftypefn {Function File} {}  bscchannel (@var{p})
## 
## Returns the transition matrix for a Binary Symmetric
## Channel with error probability, @var{p}.
## @end deftypefn
## @seealso{entropy}

function transmat=bscchannel(p)
  transmat=[ 1-p p; p 1-p];
  return
end
%!assert(bscchannel(0.5),0.5*ones(2),1)
