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
## @deftypefn {Function File} {@var{B} =} im2col (@var{A}, [@var{m}, @var{n}], @var{block_type})
## @deftypefnx {Function File} {@var{B} =} im2col (@var{A}, [@var{m}, @var{n}])
## @deftypefnx {Function File} {@var{B} =} im2col (@var{A}, 'indexed', @dots{})
## Rearranges image blocks into columns.
##
## @code{B=im2col(A, [m, n], blocktype)} rearranges blocks in @var{A}
## into columns in a way that's determined by @var{block_type}, which
## can take the following values:
##
## @table @code
## @item distinct
## Rearranges each distinct @var{m}-by-@var{n} block in image @var{A}
## into a column of @var{B}. Blocks are scanned from left to right and
## the up to bottom in @var{A}, and columns are added to @var{B} from
## left to right. If @var{A}'s size is not multiple @var{m}-by-@var{n}
## it is padded.
## @item sliding
## Rearranges any @var{m}-by-@var{n} sliding block of @var{A} in a
## column of @var{B}, without any padding, so only sliding blocks which
## can be built using a full @var{m}-by-@var{n} neighbourhood are taken.
## In consequence, @var{B} has @var{m}*@var{n} rows and
## (@var{mm}-@var{m}+1)*(@var{nn}-@var{n}+1) columns (where @var{mm} and
## @var{nn} are the size of @var{A}).
##
## This case is thought to be used applying operations on columns of
## @var{B} (for instance using sum(:)), so that result is a
## 1-by-(@var{mm}-@var{m}+1)*(@var{nn}-@var{n}+1) vector, that is what
## the complementary function @code{col2im} expects.
## @end table
##
## @code{B=im2col(A,[m,n])} takes @code{distinct} as a default value for
## @var{block_type}. 
##
## @code{B=im2col(A,'indexed', @dots{})} will treat @var{A} as an indexed
## image, so it will pad using 1 if @var{A} is double. All other cases
## (incluing indexed matrices with uint8 and uint16 types and
## non-indexed images) will use 0 as padding value.
##
## Any padding needed in 'distinct' processing will be added at right
## and bottom edges of the image.
##
## @seealso{col2im}
## @end deftypefn

function B = im2col (A, varargin)
  if(nargin < 2 || nargin > 4)
    print_usage;
  endif

  ## check 'indexed' presence
  indexed=false;
  p=1;
  if(ischar(varargin{1}) && strcmp(varargin{1}, "indexed"))
    if(nargin<3)
      print_usage;
    endif
    indexed=true;
    p+=1;
    if(isa(A,"uint8") || isa(A,"uint16"))
      padval=0;
    else
      padval=1;
    endif
  else
    padval=0;
  endif

  ## check [m,n]
  if(!isvector(varargin{p}))
    error("im2col: expected [m,n] but param is not a vector.");
  endif
  if(length(varargin{p})!=2)
    error("im2col: expected [m,n] but param has wrong length.");
  endif
  m=varargin{p}(1);
  n=varargin{p}(2);
  p+=1;

  block_type='sliding';
  if(nargin>p)
    ## we have block_type param
    if(!ischar(varargin{p}))
      error("im2col: invalid parameter block_type.");
    endif
    block_type=varargin{p};
    p+=1;
  endif

  ## if we didn't have 'indexed' but had 4 parameters there's an error
  if(nargin>p)
    print_usage;
  endif
  
  ## common checks
  if(!ismatrix(A))
    error("im2col: A should be a matrix (or vector).");
  endif

  switch(block_type)
    case('distinct')
      ## calc needed padding
      sp=mod(-size(A)',[m;n]);

      if(any(sp))
        A=padarray(A,sp,padval,'post');
      endif

      ## iterate through all blocks
      B=[];
      for i=1:m:size(A,1) ## up to bottom
        for j=1:n:size(A,2) ## left to right
          ## TODO: check if we can horzcat([],uint8([10;11])) in a
          ## future Octave version > 2.1.58
          if(isempty(B))
            B=A(i:i+m-1,j:j+n-1)(:);
          else
            B=horzcat(B, A(i:i+m-1,j:j+n-1)(:));
          endif
        endfor
      endfor
      
    case('sliding')
      if(indexed)
        disp("WARNING: 'indexed' has no sense when using sliding.");
      endif
      if(m>size(A,1) || n>size(A,2))
        error("im2col: block size can't be greater than image size in sliding");
      endif
      ## TODO: check if matlab uses top-down and left-right order
      B=[];
      for j=1:1:size(A,2)-n+1 ## left to right
        for i=1:1:size(A,1)-m+1 ## up to bottom
          ## TODO: check if we can horzcat([],uint8([10;11])) in a
          ## future Octave version > 2.1.58
          if(isempty(B))
            B=A(i:i+m-1,j:j+n-1)(:);
          else
            B=horzcat(B, A(i:i+m-1,j:j+n-1)(:));
          endif
        endfor
      endfor
      
    otherwise
      error("im2col: invalid block_type.");
  endswitch

endfunction

%!demo
%! A=[1:10;11:20;21:30;31:40]
%! B=im2col(A,[2,5],'distinct')
%! C=col2im(B,[2,5],[4,10],'distinct')
%! # Divide A using distinct blocks and reverse operation

%!shared B, A, Bs, As, Ap, Bp0, Bp1
%! v=[1:10]';
%! r=reshape(v,2,5);
%! B=[v, v+10, v+20, v+30, v+40, v+50];
%! A=[r, r+10; r+20, r+30; r+40, r+50];
%! As=[1,2,3,4,5;6,7,8,9,10;11,12,13,14,15];
%! b1=As(1:2,1:4)(:);
%! b2=As(2:3,1:4)(:);
%! b3=As(1:2,2:5)(:);
%! b4=As(2:3,2:5)(:);
%! Bs=[b1,b2,b3,b4];
%! Ap=A(:,1:9);
%! Bp1=Bp0=B;
%! Bp0([9:10],[2,4,6])=0;
%! Bp1([9:10],[2,4,6])=1;

%!# bad block_type
%!error(im2col(A,[2,5],'wrong_block_type'));

%!# distinct
%!assert(im2col(A,[2,5],'distinct'), B);

%!# padding
%!assert(im2col(Ap,[2,5],'distinct'), Bp0);
%!assert(im2col(Ap,'indexed',[2,5],'distinct'), Bp1);

%!# now sliding
%!assert(im2col(As,[2,4]), Bs);
%!assert(im2col(As,[2,4],'sliding'), Bs);
%!assert(im2col(As,[3,5],'sliding'), As(:));

%!# disctint uint8 & uint16
%!assert(im2col(uint8(A),[2,5],'distinct'), uint8(B));
%!assert(im2col(uint16(A),[2,5],'distinct'), uint16(B));

%!# padding uint8 & uint16 (to 0 even in indexed case)
%!assert(im2col(uint8(Ap),[2,5],'distinct'), uint8(Bp0));
%!assert(im2col(uint8(Ap),'indexed',[2,5],'distinct'), uint8(Bp0));
%!assert(im2col(uint16(Ap),[2,5],'distinct'), uint16(Bp0));
%!assert(im2col(uint16(Ap),'indexed',[2,5],'distinct'), uint16(Bp0));

%!# now sliding uint8 & uint16
%!assert(im2col(uint8(As),[2,4],'sliding'), uint8(Bs));
%!assert(im2col(uint16(As),[2,4],'sliding'), uint16(Bs));
