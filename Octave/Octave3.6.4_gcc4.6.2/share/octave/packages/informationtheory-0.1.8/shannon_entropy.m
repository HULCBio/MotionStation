## Copyright (C) 2007 Muthiah Annamalai <muthiah.annamalai@uta.edu>
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
## @deftypefn {Function File} {} shannon_entropy (@var{P})
##
## Redirects Shannon Entropy to entropy function. This is consistent
## with the definition of Renyi entropy.
##
## @end deftypefn

function E=shannon_entropy(P)
  if nargin < 1, print_usage(), end;
  E=entropy(P);
  return
end
%!assert(shannon_entropy([0.5 0.5]),1,1e-4)
