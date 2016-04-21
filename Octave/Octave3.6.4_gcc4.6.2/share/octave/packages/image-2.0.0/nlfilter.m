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
## @deftypefn {Function File} {@var{B} = } nlfilter (@var{A}, [@var{m},@var{n}], @var{fun})
## @deftypefnx {Function File} {@var{B} = } nlfilter (@var{A}, [@var{m},@var{n}], @var{fun}, @dots{})
## @deftypefnx {Function File} {@var{B} = } nlfilter (@var{A},'indexed', @dots{})
## Processes image in sliding blocks using user-supplied function.
##
## @code{B=nlfilter(A,[m,n],fun)} passes sliding @var{m}-by-@var{n}
## blocks to user-supplied function @var{fun}. A block is build for
## every pixel in @var{A}, such as it is centered within the block.
## @var{fun} must return a scalar, and it is used to create matrix
## @var{B}. @var{nlfilter} pads the @var{m}-by-@var{n} block at the
## edges if necessary.
## 
## Center of block is taken at ceil([@var{m},@var{n}]/2).
##
## @code{B=nlfilter(A,[m,n],fun, @dots{})} behaves as described above but
## passes extra parameters to function @var{fun}.
##
## @code{B=nlfilter(A,'indexed', @dots{})} assumes that @var{A} is an indexed
## image, so it pads the image using proper value: 0 for uint8 and
## uint16 images and 1 for double images. Keep in mind that if 'indexed'
## is not specified padding is always done using 0.
##
## @seealso{colfilt,blkproc,inline}
## @end deftypefn

function B = nlfilter(A, varargin)
  if(nargin<3)
    error("nlfilter: invalid number of parameters.");
  endif
  
  ## check 'indexed' presence
  indexed=false;
  p=1;
  if(ischar(varargin{1}) && strcmp(varargin{1}, "indexed"))
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
    error("nlfilter: expected [m,n] but param is not a vector.");
  endif
  if(length(varargin{p})!=2)
    error("nlfilter: expected [m,n] but param has wrong length.");
  endif
  sblk=varargin{p}(:);
  p+=1;

  ## check fun
  ## TODO: add proper checks for this one
  if(nargin<p)
    error("nlfilter: required parameters haven't been supplied.");
  endif
  fun=varargin{p};
  
  ## remaining params are params to fun
  ## extra params are p+1:nargin-1

  ## We take an easy approach... feel free to optimize it (coding this
  ## in C++ would be a great idea).
  
  ## Calculate center of block
  c=ceil(sblk/2);
  
  ## Pre-padding
  prepad=c-ones(2,1);
  
  ## Post-padding
  postpad=sblk-c;
  
  ## Save A size
  as=size(A);

  ## Pad data
  if(all(prepad==postpad))
    if(any(prepad>0))
      A=padarray(A,prepad,padval,'both');
    endif
  else
    if(any(prepad>0))
      A=padarray(A,prepad,padval,'pre');
    endif
    if(any(postpad>0))
      A=padarray(A,postpad,padval,'post');
    endif
  endif

  ## calc end offsets
  me=postpad(1)+prepad(1);
  ne=postpad(2)+prepad(2);

  ## We concatenate everything to preserve fun return type
  for i=1:as(1)
    r=feval(fun,A(i:i+me,1:1+ne),varargin{p+1:nargin-1});
    for j=2:as(2)
      r=horzcat(r,feval(fun,A(i:i+me,j:j+ne),varargin{p+1:nargin-1}));
    endfor
    if(i==1)
      B=r;
    else
      B=vertcat(B,r);
    endif
  endfor

endfunction

%!demo
%! nlfilter(eye(10),[3,3],inline("any(x(:)>0)","x"))
%! # creates a "wide" diagonal

%!assert(nlfilter(eye(4),[2,3],inline("sum(x(:))","x")),[2,2,1,0;1,2,2,1;0,1,2,2;0,0,1,1]);
%!assert(nlfilter(eye(4),'indexed',[2,3],inline("sum(x(:))","x")),[4,2,1,2;3,2,2,3;2,1,2,4;4,3,4,5]);
%!assert(nlfilter(eye(4),'indexed',[2,3],inline("sum(x(:))==y","x","y"),2),[0,1,0,1;0,1,1,0;1,0,1,0;0,0,0,0]!=0);

% Check uint8 and uint16 padding
%!assert(nlfilter(uint8(eye(4)),'indexed',[2,3],inline("sum(x(:))","x")),[2,2,1,0;1,2,2,1;0,1,2,2;0,0,1,1]);
%!assert(nlfilter(uint16(eye(4)),'indexed',[2,3],inline("sum(x(:))","x")),[2,2,1,0;1,2,2,1;0,1,2,2;0,0,1,1]);

% Check if function class is preserved
%!assert(nlfilter(uint8(eye(4)),'indexed',[2,3],inline("int8(sum(x(:)))","x")),int8([2,2,1,0;1,2,2,1;0,1,2,2;0,0,1,1]));
