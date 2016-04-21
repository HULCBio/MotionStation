## Copyright (C) 2009 Esteban Cervetto <estebancster@gmail.com>
##
## Octave is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or (at
## your option) any later version.
##
## Octave is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with Octave; see the file COPYING.  If not, see
## <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {@var{ultimate} =} ultimatepanning (@var{s},@var{quotas})
## Calculate the ultimate value by the Panning method.
##
## @var{s} is a mxn matrix that contains the run-off triangle, where m is the number of accident-years
## and n is the number of periods to final development. @var{s} may contain u = m-n complete years.
## The value @var{s}(i,k), 1<=i<=m, 0<=k<=n-1 represents the cumulative losses from accident-period i
## settled with a delay of at most k years. 
## The values @var{s}(i,k) with i + k > m must be zero because is future time. 
## The 1xn vector @var{quotas} is a set of cumulative quotas calculated by some method.
##
## The Panning method asumes that exists a development pattern on the incremental ratios.
## This means that the identity 
## @group
## @example
##          E[Z(i,k) ]
## B(k) =  ------------
##          E[Z(i,0) ]
## @end example
## @end group
## holds for all k = {0,...,n-1} and for all i = {1,...,m}. 
## Z represents the incremental losses; then losses satisfy 
## Z(k) = (S(k) - S(k-1) ),Z(0) = S(0) for all i = {1,...,m}.
##
## @var{ultimate} returns a column vector with the ultimate values. Their values are:
## @group
## @example
## @var{ultimate}(i) = Z(i,0)*quotas(0)
## @end example
## @end group
##
## @seealso {bferguson, quotapanning, quotald, quotaad}
## @end deftypefn

## Author: Act. Esteban Cervetto ARG <estebancster@gmail.com>
##
## Maintainer: Act. Esteban Cervetto ARG <estebancster@gmail.com>
##
## Created: jul-2009
##
## Version: 1.1.0 
##
## Keywords: actuarial reserves insurance bornhuetter ferguson chainladder

function [ultimate] = ultimatepanning (S,quotas)

[m,n] = size (S);           #triangle with m years (i=1,2,u,...u+1,u+2,....m) and n periods (k=0,1,2,...n-1)
u = m - n;                                     #rows of the upper square
S = fliplr(triu(fliplr(S),-u));                   #ensure S is triangular  

if (size(quotas) ~= [1,n])
 usage(strcat("quotas must be of size [1,",num2str(n),"]" ));
end  

ultimate = S(:,1) / quotas(1);

end
