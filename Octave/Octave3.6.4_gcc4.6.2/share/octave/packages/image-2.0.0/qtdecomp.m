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
## @deftypefn {Function File} {@var{S} =} qtdecomp (@var{I})
## @deftypefnx {Function File} {@var{S} =} qtdecomp (@var{I}, @var{threshold})
## @deftypefnx {Function File} {@var{S} =} qtdecomp (@var{I}, @var{threshold}, @var{mindim})
## @deftypefnx {Function File} {@var{S} =} qtdecomp (@var{I}, @var{threshold}, [@var{mindim} @var{maxdim}])
## @deftypefnx {Function File} {@var{S} =} qtdecomp (@var{I}, @var{fun})
## @deftypefnx {Function File} {@var{S} =} qtdecomp (@var{I}, @var{fun}, @var{P1}, @var{P2}, @dots{})
## Performs quadtree decomposition.
##
## qtdecomp decomposes a square image @var{I} into four equal-sized
## blocks. Then it performs some kind of test on each block to decide if
## it should decompose them further. This process is repeated
## iteratively until there's no block left to be decomposed.
##
## Note that blocks are not decomposed if their dimensions are not even.
##
## The output is a sparse matrix whose non-zero elements determine the
## position of the block (the element is at top-left position in the
## block) and size of each block (the value of the element determines
## length of a side of the square-shaped block).
##
## S = qtdecomp(I) decomposes an intensity image @var{I} as described
## above. By default it doesn't split a block if all elements are equal.
##
## S = qtdecomp(I, threshold) decomposes an image as decribed, but only
## splits a block if the maximum value in the block minus the minimum
## value is greater than @var{threshold}, which is a value between 0 and
## 1. If @var{I} is of class uint8, @var{threshold} is multiplied by 255
## before use. Also, if@var{I} is of class uint16, @var{threshold} is 
## multiplied by 65535.
##
## S = qtdecomp(I, threshold, mindim) decomposes an image using the
## @var{threshold} as just described, but doesn't produce blocks smaller
## than mindim.
##
## S = qtdecomp(I, threshold, [mindim maxdim]) decomposes an image as
## described, but produces blocks that can't be bigger than maxdim. It
## decomposes to maxdim even if it isn't needed if only @var{threshold}
## was considered.
##
## S = qtdecomp(I, fun) decomposes an image @var{I} and uses function
## @var{fun} to decide if a block should be splitted or not. @var{fun}
## is called with a m-by-m-by-k  array of m-by-m blocks to be
## considered, and should return a vector of size k, whose elements
## represent each block in the stacked array. @var{fun} sets the
## corresponding value to 1 if the block should be split, and 0
## otherwise.
##
## S = qtdecomp(I, fun, @dots{}) behaves as qtdecomp(I, fun) but passes
## extra parameters to @var{fun}.
##
## @seealso{qtgetblk, qtsetblk}
## @end deftypefn

function S = qtdecomp (I, p1, varargin)
  if (nargin < 1)
    print_usage;
  elseif (!ismatrix(I) || size(I,1)!=size(I,2))
    error("qtdecomp: I should be a square matrix.");
  endif

  ## current size (assumed to be square)
  curr_size=size(I,1);

  ## initial mindim to a sensible value
  mindim=1;
 
  ## sensible default maxdim value
  maxdim=curr_size;

  if (nargin<2)
    ## Initialize decision method variable
    ## We could have implemented threshold as a function and use an
    ## uniform interface (function handle) to decide whether to split or
    ## not blocks. We have decided not to do so because block
    ## rearrangement that is needed as a parameter to functions is
    ## expensive.
    decision_method=0;
  elseif (isreal(p1))
    ## p1 is threshold
    threshold=p1;
    decision_method=1;

    if(strcmp(typeinfo(I), 'uint8 matrix'))
      threshold*=255;
    elseif(strcmp(typeinfo(I), 'uint16 matrix'))
      threshold*=65535;
    endif

    if (nargin>3)
      print_usage;
    elseif (nargin==3)
      dims=varargin{1};
      if (isvector(dims)&&length(dims)==2)
        mindim=dims(1);
        maxdim=dims(2);
      elseif (isreal(dims))
        mindim=dims;
      else
        error("qtdecomp: third parameter must be 'mindim' or '[mindim maxdim]'");
      endif
      ## we won't check if mindim or maxdim are powers of 2. It's too
      ## restrictive and don't need it at all.
    endif
    
  elseif strcmp(typeinfo(p1),"function handle") ...
          || strcmp(typeinfo(p1),"inline function")
    ## function handles seem to return true to isscalar
    fun=p1;
    decision_method=2;
  else
    error("qtdecomp: second parameter must be a integer (threshold) or a function handle (fun).");
  endif
  
  ## initialize results matrices
  res=[];

  ## bool to flag end
  finished=false;

  ## array of offsets to blocks to evaluate
  offsets=[1,1];

  if (maxdim<mindim)
    error("qtdecomp: mindim must be smaller than maxdim.");
  endif

  ## See if we have to split a minimum regarless other considerations.
  if (maxdim<curr_size)
    initial_splits=ceil(log2(curr_size/maxdim));
    if(initial_splits>0)
      divs=2^initial_splits;
      if (rem(curr_size,divs)!=0)
        error("qtdecomp: Can't decompose I enough times to fulfill maxdim requirement.");
      endif
      ## update curr_size
      curr_size/=divs;
      if(curr_size<mindim)
        error("qtdecomp: maxdim restriction collides with mindim restriction.");
      endif
      els=([0:divs-1]*curr_size+1).';
      offsets=[kron(els,ones(divs,1)), kron(ones(divs,1),els)];
    endif
  endif

  while(!finished && rows(offsets)>0)
    ## check other ending conditions:
    ## is size is odd?
    ## is splitted size < than mindim?
    if ((rem(curr_size,2)!=0)||((curr_size/2)<mindim))
      ## can't continue, lets add current evaluation blocks to results
      res=[res; offsets, ones(size(offsets,1),1)*curr_size];
      finished = true;
    else
      if (decision_method<2)
        db=logical(ones(rows(offsets),1));
        for r=1:rows(offsets)
          o=offsets(r,:);
          fo=offsets(r,:)+curr_size-1;

          if(decision_method==0)
            ## is everything equal?
            if (all(I(o(1),o(2))==I(o(1):fo(1),o(2):fo(2))))
              db(r)=0;
            endif
          else
            ## check threshold
            t=I(o(1):fo(1),o(2):fo(2));
            t=t(:);
            if ((max(t)-min(t))<=threshold)
              db(r)=0;
            endif
          endif
        endfor
      elseif(decision_method==2)
        ## function handle decision method
        ## build blocks
        b=zeros(curr_size,curr_size,rows(offsets));
        rbc=offsets(:,1:2)+curr_size-1;
        for r=1:rows(offsets)
          b(:,:,r)=I(offsets(r,1):rbc(r,1),offsets(r,2):rbc(r,2));
        endfor

        db=feval(fun, b, varargin{:});
      else
        error("qtdecomp: execution shouldn't reach here. Please report this as a bug.");
      endif

      ## Add blocks that won't divide to results
      nd=offsets(find(!db),:);
      res=[res; nd, ones(size(nd,1),1)*curr_size];
      
      ## Update curr_size for next iteration
      curr_size/=2;
      
      ## Prepare offsets for next iteration
      otemp=offsets(find(db),:);
      hs=ones(rows(otemp),1)*curr_size;
      zs=zeros(size(hs));
      offsets=[otemp;otemp+[hs,zs];otemp+[zs,hs];otemp+[hs,hs]];
    endif
  endwhile

  S=sparse(res(:,1),res(:,2),res(:,3),size(I,1),size(I,2));
endfunction

%!demo
%! full(qtdecomp(eye(8)))
%! %It finds 2 big blocks of 0 and it decomposes further where 0 and 1 are mixed.

%!# Test if odd-sized limits split
%!assert(full(qtdecomp(eye(5))), reshape([5,zeros(1,24)],5,5));
%!assert(full(qtdecomp(eye(6))), repmat(reshape([3,zeros(1,8)],3,3),2,2));

%!# Test 'equal' method
%!test
%! a=ones(2,2);
%! b=[2,0;0,0];
%! assert(full(qtdecomp(eye(4))), [a,b;b,a]);

%!shared A, B2, B4, f
%! A=[ 1, 4, 2, 5,54,55,61,62;
%!     3, 6, 3, 1,58,53,67,65;
%!     3, 6, 3, 1,58,53,67,65;
%!     3, 6, 3, 1,58,53,67,65;
%!    23,42,42,42,99,99,99,99;
%!    27,42,42,42,99,99,99,99;
%!    23,22,26,25,99,99,99,99;
%!    22,22,24,22,99,99,99,99];
%! B2=[2,0;0,0];
%! B4=zeros(4); B4(1,1)=4;

%!test
%! R=[ones(4,8); [ones(2),B2;ones(2,4)], B4];
%! assert(full(qtdecomp(A)), R);
%! assert(full(qtdecomp(A,0)), R);

%!# Test 'threshold' method
%!test
%! R=[ones(4,8); [ones(2),B2;B2,ones(2)],B4];
%! assert(full(qtdecomp(A,1)), R);

%!test
%! R=[[B4,[B2,B2;B2,B2]]; [[ones(2),B2;B2,B2],B4]];
%! assert(full(qtdecomp(A,10)), R);

%!test
%! R=[[B4,[B2,B2;B2,B2]]; [[B2,B2;B2,B2],B4]];
%! assert(full(qtdecomp(A,10,2)), R);
%!
%! assert(full(qtdecomp(A,100,[2, 4])), [B4,B4;B4,B4]);

%!test
%! f = @(A, c1 = 54, c2 = 0, c3 = 0) y = (A (1, 1, :) != ((c1+c2+c3) * ones (1, 1, size (A, 3))))(:);
%!
%! assert(full(qtdecomp(A,f)),[ones(4),B4;ones(4,8)]); 
%! assert(full(qtdecomp(A,f,54)),[ones(4),B4;ones(4,8)]);
%! assert(full(qtdecomp(A,f,4,40,10)),[ones(4),B4;ones(4,8)]);

%!test
%!# no params
%! first_eq=inline("(A(1,1,:)!=(54*ones(1,1,size(A,3))))(:)","A");
%! assert(full(qtdecomp(A,first_eq)),[ones(4),B4;ones(4,8)]);

%!test
%!# 1 param
%! first_eq=inline("(A(1,1,:)!=(c*ones(1,1,size(A,3))))(:)","A","c");
%! assert(full(qtdecomp(A,first_eq,54)),[ones(4),B4;ones(4,8)]);

%!test
%!# 3 params
%! first_eq=inline("(A(1,1,:)!=((c1+c2+c3)*ones(1,1,size(A,3))))(:)","A","c1","c2","c3");
%! assert(full(qtdecomp(A,first_eq,4,40,10)),[ones(4),B4;ones(4,8)]);
