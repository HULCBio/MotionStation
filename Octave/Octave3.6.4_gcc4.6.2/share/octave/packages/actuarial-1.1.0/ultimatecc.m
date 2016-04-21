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
## @deftypefn {Function File} {@var{ultimate} =} ultimatecc (@var{s},@var{v},@var{quotas})
## Calculate the ultimate values by the Cape Cod method.
##
## @var{s} is a mxn matrix that contains the run-off triangle, where m is the number of accident-years
## and n is the number of periods to final development. @var{s} may contain u = m-n complete years.
## The value @var{s}(i,k), 1<=i<=m, 0<=k<=n-1 represents the cumulative losses from accident-period i
## settled with a delay of at most k years. 
## The values @var{s}(i,k) with i + k > m must be zero because is future time. 
## @var{v} is an mx1 vector of known volume measures (like premiums or the number of contracts).
## @var{quotas} is an 1xn vector of cumulatives quotas. 
## 
## The Cape Cod method asumes that exists a development pattern on the cumulative quotas (Q).
## This means that the identity 
## @group
## @example
##          E[S(i,k) ]
## Q(k) = -------------
##          E[S(i,n) ]
## @end example
## @end group
## holds for all k = {0,...,n-1} and for all i = {1,...,m}.
## 
## Also, the Cape Cod Method asumes the existence of a value "H" in a way that satisfy
## @group
## @example
##        S(i,n)
## H = E [------]
##         V(i)
## @end example
## @end group
## holds for all i = {1,...,m}.
## H is called the Cape Cod loss ratio and it can be prove this value is
## @group
## @example
##                    j=n-1        
##                     E   S(j,n-j)
##                    j=0            
## @var{quotas}(k) =  ----------------
##                   j=n-1            
##                     E   Q(n-j)V(j)
##                    j=0             
## @end example
## @end group
##
## @var{ultimate} returns a row column with the ultimate values. Their values are:
## @group
## @example
## @var{ultimate}(i) = H * @var{v}(i)
## @end example
## @end group
##
## @seealso {bferguson}
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

function ultimate = ultimatecc (S,V,quotas)

[m,n] = size (S);           #triangle with m years (i=1,2,u,...u+1,u+2,....m) and n periods (k=0,1,2,...n-1)
u = m - n;                                     #rows of the upper square
S = fliplr(triu(fliplr(S),-u));                   #ensure S is triangular  

if (size(V) ~= [m,1])
 usage(strcat("volume V must be of size [",num2str(m),",1]" ));
end  
if (size(quotas) ~= [1,n])
 usage("quotas must be of dimension [1,n]");
end  

# CapeCods K   K = S(i+k = n)/quotas*V

if (u==0)
K = sum(diag(fliplr(S))')/ (fliplr(quotas)*V);
else
K = sum([diag(fliplr(S),-u)' S(1:u,n)])/ (fliplr([quotas ones(u)])*V);
end

#ultimate value
ultimate = K * V;

end
