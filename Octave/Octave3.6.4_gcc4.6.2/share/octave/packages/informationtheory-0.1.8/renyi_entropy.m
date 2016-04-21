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
## @deftypefn {Function File} {} renyi_entropy (@var{alpha}, @var{P})
##
## Compute the Renyi entropy of order @var{alpha},
## for the given probability distribution @var{P}.
##
## @math{Halpha(P(x)) = log{\sum_i{(P(x_i)^alpha)}/(1-alpha)}}
##
## special-cases include, when @var{alpha}=1, it reduces to
## regular definition of shannon entropy, and when @var{alpha}=0,
## it reduces to hartley entropy.
##
## @example
## @group
##          renyi_entropy(0,[0.2 0.3 0.5])
##          @result{}   ans = 1.0986
## @end group
## @end example
## @end deftypefn

function R=renyi_entropy(alpha,P)
  if( nargin ~= 2 )
     print_usage();
  end
  if ( alpha == 1 )
    R=entropy(P);
  else
    S=sum(P.^alpha);
    R=log(S)/(1-alpha);
  end
  return
end
%!assert( renyi_entropy(0,[0.2 0.3 0.5]), 1.0986 , 1e-3 )
