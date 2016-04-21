## Copyright (C) 2006,2007,2008,2009,2010  Carlo de Falco, Massimiliano Culpo
##
## This file is part of:
##     BIM - Diffusion Advection Reaction PDE Solver
##
##  BIM is free software; you can redistribute it and/or modify
##  it under the terms of the GNU General Public License as published by
##  the Free Software Foundation; either version 2 of the License, or
##  (at your option) any later version.
##
##  BIM is distributed in the hope that it will be useful,
##  but WITHOUT ANY WARRANTY; without even the implied warranty of
##  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
##  GNU General Public License for more details.
##
##  You should have received a copy of the GNU General Public License
##  along with BIM; If not, see <http://www.gnu.org/licenses/>.
##
##  author: Carlo de Falco     <cdf _AT_ users.sourceforge.net>
##  author: Massimiliano Culpo <culpo _AT_ users.sourceforge.net>

## -*- texinfo -*-
## @deftypefn {Function File} @
## {[@var{T}]} = bimu_logm (@var{t1},@var{t2})
## 
## Input:
## @itemize @minus
## @item @var{t1}:
## @item @var{t2}:
## @end itemize
##
## Output:
## @itemize @minus
## @item @var{T}:
## @end itemize
##
## @seealso{bimu_bern}
## @end deftypefn

function [T] = bimu_logm(t1,t2)

  ## Check input
  if nargin != 2
    error("bimu_logm: wrong number of input parameters.");
  elseif size(t1) != size(t2)
    error("bimu_logm: t1 and t2 are of different size.");
  endif

  T = zeros(size(t2));
  
  sing     = abs(t2-t1)< 100*eps ;
  T(sing)  = (t2(sing)+t1(sing))/2;
  T(~sing) = (t2(~sing)-t1(~sing))./log(t2(~sing)./t1(~sing));

endfunction
