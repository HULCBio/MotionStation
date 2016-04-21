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

## -*- texinfo -*-
## @deftypefn {Function File} {} narysource (@var{probability_dist},@var{n_order})
##
## This function creates a N-ary order source using the given
## @var{probability_dist}  (as a column vector) of a 1-order source
## building a probability distribution of size
## len(@var{probability_dist})^@var{order}. Basically
## if you have X-symbol distribution with a N-ary source then we have,
## in the resultant N-ary source with a X^N symbols. The function is equivalent
## to the definitions of a q-ary order source.
##
## @example
## @group
##  pdist=[1 2 3 4]./10;
##  ndist = narysource(pdist,2)
##        @result{}  [ 0.010000   0.020000   0.030000   0.040000   0.020000 0.040000   0.060000   0.080000   0.030000   0.060000    0.090000   0.120000   0.040000   0.080000   0.120000   0.160000]
## @end group
## @end example
## @end deftypefn
## @seealso{entropy}

function opdist=narysource(pdist,order)
  if(nargin < 2)
    error('usage: ndist=narysource(pdist,order_n);')
  end

## #Method 1
##  opdist=pdist;
##  for idx=1:(order-1)
##    L=length(opdist);
##    ndist=[];
##    for idy=1:L
##      ndist=[ndist opdist(idy)*[pdist]];
##    end
##    opdist=ndist;
##  end
##

## tic; narysource([1:4]./10,4); toc
## tic; narysource([1:4]./10,10);toc

## #Method 2
  L=length(pdist);
  opdist=pdist;## 1XN
  pdist=pdist';## Nx1
  for idx=2:order
    opdist=pdist*opdist;## Nx1 * 1XN^k
    opdist=reshape(opdist,1,L^idx);## 1xN^(k+1)
  end

  return
end
%!
%!assert(narysource([1:4]./10,2),[ 0.010000   0.020000   0.030000   0.040000   0.020000 0.040000   0.060000   0.080000   0.030000   0.060000    0.090000   0.120000   0.040000   0.080000   0.120000   0.160000],1e-5);
%!

