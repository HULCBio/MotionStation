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
## @deftypefn {Function File} {} hartley_entropy (@var{P})
##
## Compute the Hartley entropy using Reyni entropy of order 0,
## for the given probability distribution.
##
## @math{H\alpha(P(x)) = log{\sum_i (Pi(x)^\alpha)}/(1-\alpha)}
##
## special-cases include, and when alpha=0, it reduces 
## to Hartley entropy.
##
## Hartley entropy H0(X) = log|X|, where X=n(P), cardinality of P,
## the pdf of random variable x.
##
## @example
## @group
##          hartley_entropy([0.2 0.3 0.5])
##          @result{}   ans = 1.0986
## @end group
## @end example
## @end deftypefn

function R=hartley_entropy(P)
  if (nargin ~= 1)
     print_usage();
  end
  R=renyi_entropy(0,P);
end
%!assert( hartley_entropy([0.2 0.3 0.5]), 1.0986, 1e-3 )
