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
## @deftypefn {Function File} {@var{ultimate} =} ultimateld (@var{s},@var{quotas})
## Calculate the ultimate values by the Loss Development (Chainladder) method.
##
## @var{s} is a mxn matrix that contains the run-off triangle, where m is the number of accident-years
## and n is the number of periods to final development. @var{s} may contain u = m-n complete years.
## The value @var{s}(i,k), 1<=i<=m, 0<=k<=n-1 represents the cumulative losses from accident-period i
## settled with a delay of at most k years. 
## The values @var{s}(i,k) with i + k > m must be zero because is future time. 
## The 1xn vector @var{quotas} is a set of cumulative quotas calculated by some method.
##
## The LD method asumes that exists a development pattern on the individual factors.
## This means that the identity 
## @group
## @example
##             E[S(i,k) ]
## LDI(k) =   -------------
##            E[S(i,k-1) ]
## @end example
## @end group
## holds for all k = {0,...,n-1} and for all i = {1,...,m}.
##
## This follows to 
## @quotas
## @example
##                    l=n-1    1
## @var{quotas}(k) =  II    -------
##                    l=k+1  LDI(l) 
## @end example
## @end group
## and the ultimate value is
## @quotas
## @example
## @var{ultimate}(i) = @var{s}(i,n-i-1) / @var{quotas}(n-i-1)
## @end example
## @end group
##
## @seealso {bferguson, quotaad, quotapanning}
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

function ultimate = ultimateld (S,quotas)

[m,n] = size (S);           #triangle with m years (i=1,2,u,...u+1,u+2,....m) and n periods (k=0,1,2,...n-1)
u = m - n;                                     #rows of the upper square
S = fliplr(triu(fliplr(S),-u));                   #ensure S is triangular  

if (size(quotas) ~= [1,n])
 usage(strcat("quotas must be of size [1,",num2str(n),"]" ));
end  

#calculate the ultimate value

if (u==0)
ultimate = flipud(diag(fliplr(S))) ./ quotas';
else
ultimate = [(flipud(diag(fliplr(S),-u)) ./ quotas')', S(1:u,n)]';
end
ultimate = flipud(ultimate);

end
