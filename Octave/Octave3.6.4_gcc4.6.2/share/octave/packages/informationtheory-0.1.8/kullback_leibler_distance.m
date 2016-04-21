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
## @deftypefn {Function File} {} kullback_leibler_distance (@var{P}, @var{Q})
##
## @var{P} and @var{Q} are probability distribution functions of the 
## @math{Dkl(P,Q) = \sum_x{ -P(x).log(Q(x)) + P(x).log(P(x))}
##          = \sum_x{ -P(x).log(P(x)/Q(x))}}
##
## Compute the Kullback-Leibler distance of two probability distributions
## given, P & Q.
## @example
## @group
##          kullback_leibler_distance([0.2 0.3 0.5],[0.1 0.8 0.1]) 
##          @result{}   ans = 0.64910 
## @end group
## @end example
## @end deftypefn

function dist=kullback_leibler_distance(P,Q)
  if (nargin < 2)
    print_usage();
  end
  PQ=P./Q;
  idx=[find(P == 0), find(Q == 0)];
  PQ(idx)=[];
  P(idx)=[];
  dist=dot(P,log(PQ));
end
%!
%!assert(kullback_leibler_distance([0.2 0.3 0.5],[0.1 0.8 0.1]) ,0.64910,1e-5)
%!
