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
## Calculate the cumulative quotas by the Mack method.
##
## @var{s} is a mxn matrix that contains the run-off triangle, where m is the number of accident-years
## and n is the number of periods to final development. @var{s} may contain u = m-n complete years.
## The value @var{s}(i,k), 1<=i<=m, 0<=k<=n-1 represents the cumulative losses from accident-period i
## settled with a delay of at most k years. 
## The values @var{s}(i,k) with i + k > m must be zero because is future time. 
## @var{v} is a mx1 vector of known volume measures (like premiums or the number of contracts).
##  
## The Mack method asumes that exists a vector @var{v} and a vector P(i) 1<=i<=m of parameters 
## such that holds for all i = {1,...,m} the next identity:
##
## @group
## @example
## ultimate(i) = V(i)*P(i)
## @end example
## @end group
##
## where
## 
## @group
## @example
##                   l=n-1            
## P(i)= O_mack(i) *   E   IRL_Mack(l)
##                    l=0             
## @end example
## @end group
##
## ,
##
## @group
## @example
##                   l=n-k-1             
##                     E     Z(j,k)      
##                    j=0                
## IRL_Mack(i)   =  ---------------------
##                   l=n-k-1                 
##                     E   V(i)*O_Mack(l)    
##                    l=0                
## @end example
## @end group
##
## and
##
## @group
## @example
##                   l=n-i-1                                                      
##                     E     Z(i,l)                                               
##                    l=0                                                         
## O_Mack(i)     =  ------------------                                            
##                   l=n-1                                                         
##                     E   V(i)*IRL(l)    (see IRL definition in quotaad function)
##                    l=0                                                               
## @end example
## @end group
## 
## Z represents the incremental losses; then losses satisfy 
## Z(k) = (S(k) - S(k-1) ),Z(0) = S(0) for all i = {1,...,m}.
##
## @var{quotas} returns a row vector with the cumulative quotas. The formula is:
## @group
## @example
##                    l=k               
##                     E   IRL_Mack(l)  
##                    l=0                
## @var{quotas}(k) =  ------------------
##                   l=n-1              
##                     E   IRL_Mack(l)  
##                    l=0               
## @end example
## @end group
## 
## @seealso {bferguson, quotald, quotapanning, quotaad}
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

function [quotas] = quotamack (S,V)

[m,n] = size (S);           #triangle with m years (i=1,2,u,...u+1,u+2,....m) and n periods (k=0,1,2,...n-1)
u = m - n;                                     #rows of the upper square
S = fliplr(triu(fliplr(S),-u));                   #ensure S is triangular  

if (size(V) ~= [m,1])
 usage(strcat("volume V must be of size [",num2str(m),",1]" ));
end  

# Z triangle 
Z = [S(:,1), S(:,2:n)-S(:,1:n-1)];
Z = fliplr(triu(fliplr(Z),-u));             #clean Z

# calculate empirical individual loss ratios
a = repmat (V,1,n);
LRI = Z ./ a;

# weights V(i)/sum(1,n-k,V(i)) 
num =fliplr(triu(fliplr(a),-u));            #numerator and clean low triangle
den = repmat(sum(num),m,1);                 #denominator
den = fliplr(triu(fliplr(den),-u));         #clean low triangle
W = num./den;                               #divide by
W = fliplr(triu(fliplr(W),-u));

# incremental Loss Ratios AD
LRI_AD  = diag(LRI' * W)';                  #weighted product

if (u==0)
b = (diag(fliplr(S),-u) ./ flipud(cumsum(LRI_AD)') ) ./ V;
else
b = ([S(1:u,n); diag(fliplr(S),-u)] ./ [sum(LRI_AD)*ones(1,u);flipud(cumsum(LRI_AD)')] ) ./ V;
end

sZ = sum (Z);                              #sum of Z
sb = repmat(b,1,n);
sb = fliplr(triu(fliplr(sb),-u));
sV = repmat(V,1,n);
sV = fliplr(triu(fliplr(sV),-u));

LRI_Mack = sZ ./ (diag(sb'*sV))';
quotas = cumsum(porcentual(LRI_Mack));     #calculate cumulated  quota  

end
