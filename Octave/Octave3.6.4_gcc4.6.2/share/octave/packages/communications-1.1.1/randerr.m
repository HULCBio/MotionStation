## Copyright (C) 2003 David Bateman
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
## @deftypefn {Function File} {@var{b} = } randerr (@var{n})
## @deftypefnx {Function File} {@var{b} = } randerr (@var{n},@var{m})
## @deftypefnx {Function File} {@var{b} = } randerr (@var{n},@var{m},@var{err})
## @deftypefnx {Function File} {@var{b} = } randerr (@var{n},@var{m},@var{err},@var{seed})
##
## Generate a matrix of random bit errors. The size of the matrix is
## @var{n} rows by @var{m} columns. By default @var{m} is equal to @var{n}.
## Bit errors in the matrix are indicated by a 1.
##
## The variable @var{err} determines the number of errors per row. By
## default the return matrix @var{b} has exactly one bit error per row.
## If @var{err} is a scalar, there each row of @var{b} has exactly this
## number of errors per row. If @var{err} is a vector then each row has
## a number of errors that is in this vector. Each number of errors has    
## an equal probability. If @var{err} is a matrix with two rows, then 
## the first row determines the number of errors and the second their
## probabilities.
##
## The variable @var{seed} allows the random number generator to be seeded
## with a fixed value. The initial seed will be restored when returning.
## @end deftypefn

## 2003 FEB 13
##   initial release

function b = randerr (n, m, err, seed)

  switch (nargin)
    case 0,
      m = 1;
      n = 1;
      err = 1;
      seed = Inf;
    case 1,
      m = n;
      err = 1;
      seed = Inf;
    case 2,
      err = 1;
      seed = Inf;
    case 3,
      seed = Inf;      
    case 4,
    otherwise
      usage ("b = randerr (n, [m, [err, [seed]]])");
  endswitch

  ## Check error vector
  [ar,ac] = size (err);
  if (ac == 1) 
    if (ar > 1)
      err = err';
    endif
  elseif ((ac > 1) && (ar != 1) && (ar != 2))
    error ("randerr: err must be a scalar, vector or two row matrix");
  endif
  for i=1:ac
    if (err(1,i) > m)
      error ("randerr: illegal number of errors per row");
    endif
  end
    
  # Use randsrc to calculate the number of errors per row
  nerrs = randsrc (n, 1, err, seed);
  
  # Now put to errors into place in the return matrix
  b = zeros (n, m);
  for i=1:n
    if (nerrs(i) > 0)
      if (nerrs(i) == 1)
        indx = sort(randint(1,nerrs(i),m,seed));
      else
        do
          indx = sort(randint(1,nerrs(i),m,seed));
        until (! any(indx(1:nerrs(i)-1) == indx(2:nerrs(i))))
      endif
      b(i,indx+1) = ones(1,nerrs(i)); 
    endif
  end
endfunction


%!shared n, err1, err2, seed, a1, a2, a3, a4, a5, a6
%!    n = 10; err1 = 2; err2 = [1,2;0.7,0.3] ; seed = 1; 
%!    a1 = randerr(n); a2 = randerr(n,n);
%!    a3 = randerr(n,n,err1); a4 = randerr(n,n,err2); 
%!    a5 = randerr(n,n,err1,seed); a6 = randerr(n,n,err1,seed);

%!error randerr (n,n,n,n,n);
%!assert (size(a1) == [n, n] && size(a2) == [n, n]);
%!assert (all (sum (a1.') == 1) && all (sum (a2.') == 1))
%!assert (all((a1(:) == 1 | a1(:) == 0)) &&all((a2(:) == 1 | a2(:) == 0)))
%!assert (size(a3) == [n, n] && size(a4) == [n, n]);
%!assert (all (sum (a3.') == err1))
%!assert (all((a3(:) == 1 | a3(:) == 0)))
%!assert (all ((sum (a4.') == err2(1,1)) | (sum (a4.') == err2(1,2))))
%!assert (all((a4(:) == 1 | a4(:) == 0)))
%!assert (a5(:) == a6(:));
