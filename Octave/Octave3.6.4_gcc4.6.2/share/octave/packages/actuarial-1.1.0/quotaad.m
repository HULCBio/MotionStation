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
## @deftypefn {Function File} {@var{quotas} =} quotaad (@var{s},@var{v})
## Calculate the cumulative quotas by the Additive method.
##
## @var{s} is a mxn matrix that contains the run-off triangle, where m is the number of accident-years
## and n is the number of periods to final development. @var{s} may contain u = m-n complete years.
## The value @var{s}(i,k), 1<=i<=m, 0<=k<=n-1 represents the cumulative losses from accident-period i
## settled with a delay of at most k years. 
## The values @var{s}(i,k) with i + k > m must be zero because is future time. 
## @var{v} is an mx1 vector of known volume measures (like premiums or the number of contracts).
##  
## The Additive method asumes that exists a development pattern on the incremental loss ratios (IRL).
## This means that the identity 
## @group
## @example                
##            E[Z(i,k) ] 
## IRL(k) =  ------------
##               V(i)    
## @end example
## @end group
## holds for all k = {0,...,n-1} and for all i = {1,...,m}. 
## Z represents the incremental losses; then losses satisfy 
## Z(k) = (S(k) - S(k-1) ),Z(0) = S(0) for all i = {1,...,m}.
##
## @var{quotas} returns a row vector with the cumulative quotas. The transformation
## from incremental loss ratios to cumulative quotas is:
## @group
## @example
##                    l=k        
##                     E   IRL(l)
##                    l=0            
## @var{quotas}(k) =  -----------
##                   l=n-1            
##                     E   IRL(l)
##                    l=0             
## @end example
## @end group
##
## @seealso {bferguson, quotald, quotapanning}
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

function [quotas] = quotaad (S,V)

[m,n] = size (S);           #triangle with m years (i=1,2,u,...u+1,u+2,....m) and n periods (k=0,1,2,...n-1)
u = m - n;                                     #rows of the upper square
S = fliplr(triu(fliplr(S),-u));                   #ensure S is triangular  
if (size(V) ~= [m,1])
 usage(strcat("volume V must be of size [",num2str(m),",1]" ));
end  

# Z triangle
Z = [S(:,1), S(:,2:n)-S(:,1:n-1)];
Z = fliplr(triu(fliplr(Z),-u));                #clean Z

# calc the empirical incremental loss ratios
LRI = Z ./ repmat (V,1,n);
 
#weights V(i)/sum(1,n-k,V(i))
W = repmat(V,1,n);                             #numerator
W =fliplr(triu(fliplr(W),-u));                 #clean low triangle
a = repmat(sum(W),m,1);                        #denominator
a = fliplr(triu(fliplr(a),-u));                #clean low triangle
W = W./a;                                      #divide by
W = fliplr(triu(fliplr(W),-u));

# incremental Loss Ratios AD
LRI_AD  = diag(LRI' * W)';                     #weighted product
quotas = cumsum(porcentual(LRI_AD));           #calc cumulated quota 

end
