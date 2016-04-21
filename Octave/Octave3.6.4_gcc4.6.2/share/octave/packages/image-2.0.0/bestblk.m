## Copyright (C) 2004 Josep Mones i Teixidor <jmones@puntbarra.com>
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
## @deftypefn {Function File} {@var{siz} = } bestblk ([@var{m} @var{n}], @var{k})
## @deftypefnx {Function File} {[@var{mb} @var{nb}] = } bestblk ([@var{m} @var{n}], @var{k})
## Calculates the best size of block for block processing.
##
## @code{siz=bestblk([m,n],k)} calculates the optimal block size for block
## processing for a @var{m}-by-@var{n} image. @var{k} is the maximum
## side dimension of the block. Its default value is 100. @var{siz} is a
## row vector which contains row and column dimensions for the block.
##
## @code{[mb,nb]=bestblk([m,n],k)} behaves as described above but
## returns block dimensions to @var{mb} and @var{nb}.
##
## @strong{Algorithm:}
##
## For each dimension (@var{m} and @var{n}), it follows this algorithm:
##
## 1.- If dimension is less or equal than @var{k}, it returns the
## dimension value.
##
## 2.- If not then returns the value between
## @code{round(min(dimension/10,k/2))} which minimizes padding.
##
##
## @seealso{blockproc}
## @end deftypefn

function [varargout] = bestblk (ims, k = 100)
  if (nargin < 1 || nargin > 2 || nargout > 2)
    print_usage;
  elseif (!isvector (ims))
    error("bestblk: first parameter is not a vector.");
  endif
  ims=ims(:);
  if(length(ims)!=2)
    error("bestblk: length of first parameter is not 2.");
  endif

  mb=mi=ims(1);
  p=mi;
  if(mi>k)
    for i=round(min(mi/10,k/2)):k
      pt=rem(mi,i);
      if(pt<p)
        p=pt;
        mb=i;
      endif
    endfor
  endif

  nb=ni=ims(2);
  p=ni;
  if(ni>k)
    for i=round(min(ni/10,k/2)):k
      pt=rem(ni,i);
      if(pt<p)
        p=pt;
        nb=i;
      endif
    endfor
  endif

  if(nargout<=1)
    varargout{1}=[mb;nb];
  else
    varargout{1}=mb;
    varargout{2}=nb;
  endif

endfunction

%!demo
%! siz = bestblk ([200; 10], 50);
%! disp (siz)

%!assert(bestblk([300;100],150),[30;100]);
%!assert(bestblk([256,128],17),[16;16]);
