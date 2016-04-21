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
## @deftypefn {Function File} {@var{BF} =} bferguson (@var{s}, @var{quotas}, @var{ultimate}, @var{k})
## Calculate the extended Bornhuetter-Ferguson method for reserves.
## @var{BF} provides a column vector with the elements of @var{k}-th period of development. 
## @var{s} is a mxn matrix that contains the run-off triangle, where m is the number of accident-years
## and n is the number of periods to final development. @var{s} may contain u = m-n complete years.
## @var{k} may vary from 0 (first period) to n-1 (final period).
##
## The Bornhuetter-Ferguson predictors of the losses S(i,@var{k}) with i + @var{k} > n are defined as
## @tex
## @example
## @group
## $$
##  S _{i,k}^BF (hat %gamma, hat %alfa) = S _{i,n-i} + (%gamma_{k} - %gamma_{n-i})%alfa_{i}
## $$
## @end group
## @end example
## @end tex
## @ifnottex
## @example
## @group
## S(i,@var{k})= S(i,n-i)+ (@var{quotas}(@var{k})- @var{quotas}(n-i))* @var{ultimate}(i)
## @end group
## @end example
## @end ifnottex
##
## @seealso {bfanalysis}
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


function [BF] = bferguson (S, quotas,ultimate,k)

[m,n] = size (S);        #triangle with m years (i=1,2,u,...u+1,u+2,....m) and n periods (k=0,1,2,...n-1)
if (size(quotas) ~= [1,n])
    usage(strcat("quotas must be of size [1,",num2str(n),"]" ))
end
if (size(ultimate) ~= [m,1])
    usage(strcat("ultimate must be of size [",num2str(m),",1]" ))
end

u = m - n;                #rows of the upper square 
S = fliplr(triu(fliplr(S),-u));                   #ensure S is triangular  
diagS = diag(fliplr(S),-u);

#calcs the proyection by the bornhuetter-ferguson method
BF = diagS((n-k+1):n,1) + (quotas(k+1)*ones(1,k) - quotas(k:-1:1))' .* ultimate((m-k+1):m);
BF = [S(1:m-k,k+1); BF];

end
