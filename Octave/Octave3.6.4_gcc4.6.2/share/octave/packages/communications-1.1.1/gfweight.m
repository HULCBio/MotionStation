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
## @deftypefn {Function File} {@var{w} = } gfweight (@var{gen})
## @deftypefnx {Function File} {@var{w} = } gfweight (@var{gen},'gen')
## @deftypefnx {Function File} {@var{w} = } gfweight (@var{par},'par')
## @deftypefnx {Function File} {@var{w} = } gfweight (@var{p},n)
##
## Calculate the minimum weight or distance of a linear block code. The
## code can be either defined by its generator or parity check matrix, or
## its generator polynomial. By default if the first argument is a matrix,
## it is assumed to be the generator matrix of the code. The type of the
## matrix can be defined by a flag 'gen' for the generator matrix or
## 'par' for the parity check matrix.
##
## If the first argument is a vector, it is assumed that it defines the
## generator polynomial of the code. In this case a second argument is
## required that defines the codeword length.
##
## @end deftypefn
## @seealso{hammgen,cyclpoly,bchpoly}

function w = gfweight (arg1, arg2)

  if ((nargin < 1) || (nargin > 2))
    usage ("gfweight(mat,typ) or gfweight(poly,n)");
  endif

  if (isvector(arg1))
    if (nargin != 2)
      error ("gfweight: need the codeword length if passing generator polynomial");
    endif
    [ign, gen] = cyclgen(arg2, arg1);
  elseif (ismatrix(arg1))
    if (nargin == 2)
      if (ischar(arg2))
	if (strcmp(arg2,"gen"))
	  gen = arg1;
	elseif (strcmp(arg2,"par"))
	  gen = gen2par(arg1);
	else
	  error ("gfweight: unrecognized string argument");
	endif
      else
	error ("gfweight: if first argument is a matrix, the second must be a string");
      endif
    else
      gen = arg1;
    endif
  else
    error ("gfweight: first argument must be a matrix or a vector");
  endif

  [k, n] = size(gen);
  if (n < k)
    error ("gfweight: generator matrix in an illegal form");
  endif

  ## We only need to test codewords 1:2^k-1 against the zero code word
  ## We do the equivalent of 
  ## w = min(sum((mod(de2bi([1:2^k-1]') * gen, 2))'));
  ## But in a more memory efficient manner in an oct-file
  w = __gfweight__(gen);

endfunction
