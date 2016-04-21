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
## @deftypefn {Function File} {@var{J} =} qtsetblk (@var{I}, @var{S}, @var{dim}, @var{vals})
## Set block values in a quadtree decomposition.
##
## J=qtsetblk(I,S,dim,vals) sets all the @var{dim}-by-@var{dim} blocks
## in the quadtree decomposition (@var{S} returned by qtdecomp) of
## @var{I} to @var{dim}-by-@var{dim} blocks in @var{vals}, which is
## itself a @var{dim}-by-@var{dim}-by-k array. k is the number of
## @var{dim}-by-@var{dim} blocks in the quadtree decomposition.
## @seealso{qtdecomp, qtgetblk}
## @end deftypefn

function J = qtsetblk (I, S, dim, vals)
  if (nargin != 4)
    print_usage;
  endif

  ## get blocks
  [ii,ji,v]=find(S);

  ## filter the ones which match dim
  idx=find(v==dim);
  if(size(vals,3)<length(idx)) ## we won't complain if k>num blocks
    error("qtsetblk: k (vals 3rd dimension) is not equal to number of blocks.");
  endif
  ii=ii(idx);
  ji=ji(idx);
  
  ## calc end vertex
  ie=ii+dim-1;
  je=ji+dim-1;

  J=I;
  for b=1:length(idx)
    J(ii(b):ie(b),ji(b):je(b))=vals(:,:,b);
  endfor
endfunction

%!demo
%! J=qtsetblk(eye(4),qtdecomp(eye(4)),2,ones(2,2,2))
%! % Sets upper-right and lower-left blocks of 2*2 zeros to ones

%!shared A, S
%! A=[ 1, 4, 2, 5,54,55,61,62;
%!     3, 6, 3, 1,58,53,67,65;
%!     3, 6, 3, 1,58,53,67,65;
%!     3, 6, 3, 1,58,53,67,65;
%!    23,42,42,42,99,99,99,99;
%!    27,42,42,42,99,99,99,99;
%!    23,22,26,25,99,99,99,99;
%!    22,22,24,22,99,99,99,99];
%! S = qtdecomp (A, 10);

%!test
%! R=A;
%! vals=zeros(4,4,2);
%! vals(:,:,1)=reshape([1:16],4,4);
%! vals(:,:,2)=reshape([21:36],4,4);
%! R(1:4,1:4)=reshape([1:16],4,4);
%! R(5:8,5:8)=reshape([21:36],4,4);
%! assert(qtsetblk(A,S,4,vals),R);

%!test
%! R=A;
%! R(1:4,5:8)=1;
%! R(7:8,1:4)=1;
%! R(5:6,3:4)=1;
%! assert(qtsetblk(A,S,2,ones(2,2,7)),R);

%!test
%! R=A;
%! R(5:6,1:2)=10;
%! assert(qtsetblk(A,S,1,ones(1,1,4)*10),R);
