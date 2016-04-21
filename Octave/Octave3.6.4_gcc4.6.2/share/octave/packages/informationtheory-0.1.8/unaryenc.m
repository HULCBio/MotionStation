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
## @deftypefn {Function File} {} unaryenc (@var{value})
##
## This function encodes the decimal value.
## Useful if you are trying to perform golomb-rice coding
## value needs to be a number or row-vector. @var{value}
## is a non-negative number.
##
## Unary encoding of a +ve number N is done as follows,
## use N-ones followed by one zero. For instance, the  
## unary coded value of 5 will be then (111110) in base2 
## which is 31x2 = 62. From this definition, decoding follows.
##
## @example
## @group
##  message = [5   4   4   1   1   1]
##  coded = unaryenc(message)
##        @result{}  [62   30   30    2    2    2]
##  unarydec(coded)
##        @result{}  [5   4   4   1   1   1]
## @end group
## @end example
## @end deftypefn
## @seealso{unarydec}

##
## Optimal for exponential sequences
## pow(2,-n) kind of sequences this is optimal.
##
function rval=unaryenc(val)
     if val==0
        rval=val;
        return
     end
     rval=2.^(val)-1; % add somany 1's
     rval=rval*2;    % append 0
end
%!assert(unaryenc([5   4   4   1   1   1]), [62   30   30    2    2 2],1)
