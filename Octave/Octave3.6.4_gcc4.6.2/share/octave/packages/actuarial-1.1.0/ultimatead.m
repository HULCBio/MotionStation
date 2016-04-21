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
## @deftypefn {Function File} {@var{ultimate} =} ultimatead (@var{s},@var{v})
## Calculate the ultimate values by the Additive method.
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
## @var{ultimate} returns a column vector with the ultimate values. Their values are:
## @group
## @example
## @var{ultimate}(i) = ultimatecc(@var{s},@var{v},quotaad(@var{s},@var{v}))(i)
## @end example
## @end group
## It may be seen it match with the ultimate calculated by the Cape Cod Method.
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

function [ultimate] = ultimatead (S,V)

ultimate = ultimatecc(S,V,quotaad(S,V));

end
