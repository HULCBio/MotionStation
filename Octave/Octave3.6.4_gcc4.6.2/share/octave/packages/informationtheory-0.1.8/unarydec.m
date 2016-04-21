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
## @deftypefn {Function File} {} unarydec (@var{value})
##
## This function decodes the unary encoded value.
## Useful if you are trying to perform golomb-rice coding
## value needs to be a number or row-vector. For example
##
## @example
## @group
##  message = [5   4   4   1   1   1]
##  coded = unaryenc(message)
##        @result{} [62   30   30    2    2    2]
##  unarydec(coded)
##        @result{} [5   4   4   1   1   1]
## @end group
## @end example
## @end deftypefn
## @seealso{unaryenc}

function rval=unarydec(val)
     rval=log2(val+2)-1;
end
%!assert(unarydec([62   30   30    2    2    2],[5   4   4   1   1 1],1))

