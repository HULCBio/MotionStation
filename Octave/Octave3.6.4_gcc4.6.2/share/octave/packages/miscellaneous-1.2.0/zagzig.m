## Copyright (C) 2006 Fredrik Bulow <fredrik.bulow@gmail.com>
##
## This program is free software; you can redistribute it and/or modify it under
## the terms of the GNU General Public License as published by the Free Software
## Foundation; either version 3 of the License, or (at your option) any later
## version.
##
## This program is distributed in the hope that it will be useful, but WITHOUT
## ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
## FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
## details.
##
## You should have received a copy of the GNU General Public License along with
## this program; if not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {} zagzig (@var{mtrx})
## Returns zagzig walk-off of the elements of @var{mtrx}.
## Essentially it walks the matrix in a Z-fashion.
##  
## mat = 
##   1   4   7
##   2   5   8
##   3   6   9
## then zagzag(mat) gives the output,
## [1 4 2 3 5 7 8 6 9], by walking as
## shown in the figure from pt 1 in that order of output.
## The argument @var{mtrx} should be a MxN matrix. One use of
## zagzig the use with picking up DCT coefficients
## like in the JPEG algorithm for compression.
##
## An example of zagzig use:
## @example
## @group
## mat = reshape(1:9,3,3);
## zagzag(mat)
## ans =[1 4 2 3 5 7 8 6 9]
##
## @end group
## @end example
##
## @end deftypefn
## @seealso{zigzag}

function rval = zagzig(mtrx)

  if nargin != 1 #Checking arguments.
    print_usage;
  endif

  if issquare(mtrx) #Square matrix (quick case)
    n=length(mtrx);
    ##We create a matrix of the same size as mtrx where odd elements are
    ##1, others 0.
    odd=kron(ones(n,n),eye(2))((1:n),(1:n));

    ##We transpose even elements only.
    mtrx = (mtrx.*odd)' + (mtrx.*(1-odd));

    ##Now we mirror the matrix. The desired vector is now the
    ##concatenation of the diagonals.
    mtrx=mtrx(:,1+size(mtrx,2)-(1:size(mtrx,2)));

    ##Picking out the diagonals.
    rval  = [];
    for i = n-1:-1:1-n
      rval=[rval diag(mtrx,i)'];
    endfor

  else #Not square (Slow cases)
    n=size(mtrx);
    mtrx=mtrx(:,1+size(mtrx,2)-(1:size(mtrx,2)));

    ##Picking out the diagonals and reversing odd ones manually.
    rval  = [];
    for i = n(2)-1:-1:1-n(1)
      new = diag(mtrx,i);
      if floor(i/2)==i/2 ##Even?
        rval=[rval new((1+length(new))-(1:length(new)))'];
      else                ##Odd!
        rval=[rval new'];
      endif
    endfor
  endif
endfunction

%!assert(zagzig(reshape(1:9,3,3)),[1 4 2 3 5 7 8 6 9])
