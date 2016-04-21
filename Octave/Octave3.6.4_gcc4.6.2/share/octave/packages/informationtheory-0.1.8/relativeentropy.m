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
## @deftypefn {Function File} {} relativeentropy (@var{p}, @var{q})
##
## Computes the relative entropy between the 2 given pdf's. 
## @code{d(@var{p} || @var{q})} is the Kullback-Leiber distance
## between 2 probability, distributions, is relative entropy. 
## Not a real measure as its not symmetric. wherever infinity is 
## present, we reduce it to zeros
## @end deftypefn
## @seealso{entropy, conditionalentropy}

function val=relativeentropy(p,q)
  if nargin < 2 || size(p)~=size(q) || ~isvector(p) || ~isvector(q)
    error('usage: relativeentropy(p,q) of equal length');
  end  
  val=zeros(1,max(size(p)));
  p_by_q=p./q;
  p_by_q(p_by_q == inf)=0;
  nonzero_idx=(p_by_q > 0 );
  val(nonzero_idx)= p(nonzero_idx).*log2(p_by_q(nonzero_idx));
  return
end
%!assert(relativeentropy([0.5 0.5],[0.3 0.7]),[0.36848, -0.24271],[1e-5,1e-5])
%!


