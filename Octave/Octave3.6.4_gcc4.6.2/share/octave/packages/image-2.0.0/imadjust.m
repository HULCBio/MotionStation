## Copyright (C) 1999,2000 Kai Habel <kai.habel@gmx.de>
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
## @deftypefn {Function File} {@var{J} =} imadjust (@var{I})
## @deftypefnx {Function File} {@var{J} =} imadjust (@var{I},[@var{low_in};@var{high_in}])
## @deftypefnx {Function File} {@var{J} =} imadjust (@var{I},[@var{low_in};@var{high_in}],[@var{low_out};@var{high_out}])
## @deftypefnx {Function File} {@var{J} =} imadjust (@dots{}, @var{gamma})
## @deftypefnx {Function File} {@var{newmap} =} imadjust (@var{map}, @dots{})
## @deftypefnx {Function File} {@var{RGB_out} =} imadjust (@var{RGB}, @dots{})
## Adjust image or colormap values to a specified range.
##
## @code{J=imadjust(I)} adjusts intensity image @var{I} values so that
## 1% of data on lower and higher values (2% in total) of the image is
## saturated; choosing for that the corresponding lower and higher
## bounds (using @code{stretchlim}) and mapping them to 0 and 1. @var{J}
## is an image of the same size as @var{I} which contains mapped values.
## This is equivalent to @code{imadjust(I,stretchlim(I))}.
##
## @code{J=imadjust(I,[low_in;high_in])} behaves as described but uses
## @var{low_in} and @var{high_in} values instead of calculating them. It
## maps those values to 0 and 1; saturates values lower than first limit
## to 0 and values higher than second to 1; and finally maps all values
## between limits linearly to a value between 0 and 1. If @code{[]} is
## passes as @code{[low_in;high_in]} value, then @code{[0;1]} is taken
## as a default value.
##
## @code{J=imadjust(I,[low_in;high_in],[low_out;high_out])} behaves as
## described but maps output values between @var{low_out} and
## @var{high_out} instead of 0 and 1. A default value @code{[]} can also
## be used for this parameter, which is taken as @code{[0;1]}.
##
## @code{J=imadjust(@dots{},gamma)} takes, in addition of 3 parameters
## explained above, an extra parameter @var{gamma}, which specifies the
## shape of the mapping curve between input elements and output
## elements, which is linear (as taken if this parameter is omitted). If
## @var{gamma} is above 1, then function is weighted towards lower
## values, and if below 1, towards higher values.
##
## @code{newmap=imadjust(map,@dots{})} applies a transformation to a
## colormap @var{map}, which output is @var{newmap}. This transformation
## is the same as explained above, just using a map instead of an image.
## @var{low_in}, @var{high_in}, @var{low_out}, @var{high_out} and
## @var{gamma} can be scalars, in which case the same values are applied
## for all three color components of a map; or it can be 1-by-3
## vectors, to define unique mappings for each component.
##
## @code{RGB_out=imadjust(RGB,@dots{})} adjust RGB image @var{RGB} (a
## M-by-N-by-3 array) the same way as specified in images and colormaps.
## Here too @var{low_in}, @var{high_in}, @var{low_out}, @var{high_out} and
## @var{gamma} can be scalars or 1-by-3 matrices, to specify the same
## mapping for all planes, or unique mappings for each.
##
## The formula used to realize the mapping (if we omit saturation) is:
##
## @code{J = low_out + (high_out - low_out) .* ((I - low_in) / (high_in - low_in)) .^ gamma;}
##
## @strong{Compatibility notes:}
##
## @itemize @bullet
## @item
## Prior versions of imadjust allowed @code{[low_in; high_in]} and
## @code{[low_out; high_out]} to be row vectors. Compatibility with this
## behaviour has been keeped, although preferred form is vertical vector
## (since it extends nicely to 2-by-3 matrices for RGB images and
## colormaps).
## @item
## Previous version of imadjust, if @code{low_in>high_in} it "negated" output.
## Now it is negated if @code{low_out>high_out}, for compatibility with
## MATLAB.
## @item
## Class of @var{I} is not considered, so limit values are not
## modified depending on class of the image, just treated "as is". When
## Octave 2.1.58 is out, limits will be multiplied by 255 for uint8
## images and by 65535 for uint16 as in MATLAB.
## @end itemize
## 
## @seealso{stretchlim, brighten}
## @end deftypefn

## TODO: When Octave 2.1.58 is out multiply indices if input argument is
## TODO: of class int* or uint*.

function ret = imadjust (image, in = stretchlim (image), out = [0;1], gamma = 1)

  if (nargin < 1 || nargin > 4)
    print_usage;
  endif

  if !(ismatrix(image))
    error ("imadjust(image,...) first parameter must be a image matrix or colormap");
  endif

  if !((ismatrix(in) || isempty(in)) && (ismatrix(out) || isempty(out)) )
    print_usage;
  endif

  if (isempty(in))
    in=[0;1];               ## default in
  endif

  simage=size(image);
  if (length(simage)==3 && simage(3)==3)
    ## image is rgb
    [in, out, gamma]=__imadjust_check_3d_args__(in, out, gamma);

    ## make room
    ret=zeros(size(image));

    ## process each plane
    for i=1:3
      ret(:,:,i)=__imadjust_plane__(image(:,:,i),in(1,i),in(2,i),out(1,i),out(2,i),gamma(1,i));
    endfor

  elseif (length(simage)==2)
    if(simage(2)==3 && \ 
       (size(in)==[2,3] || size(out)==[2,3] || size(gamma)==[1,3]) )
      ## image is a colormap
      [in, out, gamma]=__imadjust_check_3d_args__(in, out, gamma);

      ret=[];
      ## process each color
      for i=1:3
        ret=horzcat(ret,__imadjust_plane__(image(:,i),in(1,i),in(2,i),out(1,i),out(2,i),gamma(i)));
      endfor

    else
      ## image is a intensity image
      if( !isvector(in) || length(in)!=2 || !isvector(out) || length(out)!=2 || !isscalar(gamma) || (gamma<0) || (gamma==Inf) )
        error("imadjust: on an intensity image, in and out must be 2-by-1 and gamma a positive scalar.");
      endif
      ret=__imadjust_plane__(image,in(1),in(2),out(1),out(2),gamma);
    endif

  else
    error("imadjust: first parameter must be a colormap, an intensity image or a RGB image");
  endif
endfunction

## This does all the work. I has a plane; li and hi input low and high
## values; and lo and ho, output bottom and top values.
## Image negative is computed if ho<lo although nothing special is
## needed, since formula automatically handles it.
function ret=__imadjust_plane__(I, li, hi, lo, ho, gamma)
  ret = (I < li) .* lo;
  ret = ret + (I >= li & I < hi) .* (lo + (ho - lo) .* ((I - li) / (hi - li)) .^ gamma);
  ret = ret + (I >= hi) .* ho;
endfunction

## Checks in, out and gamma to see if they are ok for colormap and RGB
## cases.
function [in, out, gamma]=__imadjust_check_3d_args__(in, out, gamma)
  switch(size(in)) 
    case([2,3]) 
      ## ok!
    case([2,1])
      in=repmat(in,1,3);
    case([1,2]) ## Compatibility behaviour!
      in=repmat(in',1,3);
    otherwise
      error("imadjust: in must be 2-by-3 or 2-by-1.");
  endswitch
  
  switch(size(out))
    case([2,3])
      ## ok!
    case([2,1])
      out=repmat(out,1,3);
    case([1,2]) ## Compatibility behaviour!
      out=repmat(out',1,3);
    otherwise
      error("imadjust: out must be 2-by-3 or 2-by-1.");
  endswitch
  
  switch(size(gamma))
    case([1,3])
      ## ok!
    case([1,1])
      gamma=repmat(gamma,1,3);
    otherwise
      error("imadjust: gamma must be a scalar or a 1-by-3 matrix.");
  endswitch
  
  ## check gamma allowed range
  if(!all((gamma>=0)&(gamma<Inf)))
    error("imadjust: gamma values must be in the range [0,Inf]");
  endif

endfunction

# bad arguments

# bad images
%!error(imadjust("bad argument"));
%!error(imadjust(zeros(10,10,3,2)));
%!error(imadjust(zeros(10,10,4)));
%!error(imadjust("bad argument"));

# bad 2d, 3d or 4th argument
%!error(imadjust([1:100],"bad argument",[0;1],1));
%!error(imadjust([1:100],[0,1,1],[0;1],1));
%!error(imadjust([1:100],[0;1],[0,1,1],1));
%!error(imadjust([1:100],[0;1],[0;1],[0;1]));
%!error(imadjust([1:100],[0;1],[0;1],-1));

%!# 1% on each end saturated
%!assert(imadjust([1:100]),[0,linspace(0,1,98),1]);

%!# test with only input arg
%!assert(sum(abs((imadjust(linspace(0,1,100),[1/99;98/99]) - \
%!                [0,linspace(0,1,98),1] )(:))) < 1e-10);

%!# a test with input and output args
%!assert(imadjust([1:100],[50;90],[-50;-30]), \
%!       [-50*ones(1,49), linspace(-50,-30,90-50+1), -30*ones(1,10)]);

%!# a test with input and output args in a row vector (Compatibility behaviour)
%!assert(imadjust([1:100],[50,90],[-50,-30]), \
%!       [-50*ones(1,49), linspace(-50,-30,90-50+1), -30*ones(1,10)]);

%!# the previous test, "negated"
%!assert(imadjust([1:100],[50;90],[-30;-50]), \
%!       [-30*ones(1,49), linspace(-30,-50,90-50+1), -50*ones(1,10)]);

%!shared cm,cmn
%! cm=[[1:10]',[2:11]',[3:12]'];
%! cmn=([[1:10]',[2:11]',[3:12]']-1)/11;

%!# a colormap
%!assert(imadjust(cmn,[0;1],[10;11]),cmn+10);

%!# a colormap with params in row (Compatibility behaviour)
%!assert(imadjust(cmn,[0,1],[10,11]),cmn+10);

%!# a colormap, different output on each
%!assert(imadjust(cmn,[0;1],[10,20,30;11,21,31]),cmn+repmat([10,20,30],10,1));

%!# a colormap, different input on each, we need increased tolerance for this test
%!assert(sum(abs((imadjust(cm,[2,4,6;7,9,11],[0;1]) -                   \
%!       [[0,linspace(0,1,6),1,1,1]',                                   \
%!        [0,0,linspace(0,1,6),1,1]',                                   \
%!        [0,0,0,linspace(0,1,6),1]']                                   \
%!       ))(:)) < 1e-10                                                 \
%!       );

%!# a colormap, different input and output on each
%!assert(sum(abs((imadjust(cm,[2,4,6;7,9,11],[0,1,2;1,2,3]) -           \
%!       [[0,linspace(0,1,6),1,1,1]',                                   \
%!        [0,0,linspace(0,1,6),1,1]'+1,                                 \
%!        [0,0,0,linspace(0,1,6),1]'+2]                                 \
%!       ))(:)) < 1e-10                                                 \
%!       );

%!# a colormap, different gamma, input and output on each
%!assert(sum(abs((imadjust(cm,[2,4,6;7,9,11],[0,1,2;1,2,3],[1,2,3]) -   \
%!       [[0,linspace(0,1,6),1,1,1]',                                   \
%!        [0,0,linspace(0,1,6).^2,1,1]'+1,                              \
%!        [0,0,0,linspace(0,1,6).^3,1]'+2]                              \
%!       )(:))) < 1e-10                                                 \
%!       );

%!shared iRGB,iRGBn,oRGB
%! iRGB=zeros(10,1,3);
%! iRGB(:,:,1)=[1:10]';
%! iRGB(:,:,2)=[2:11]';
%! iRGB(:,:,3)=[3:12]';
%! iRGBn=(iRGB-1)/11;
%! oRGB=zeros(10,1,3);
%! oRGB(:,:,1)=[0,linspace(0,1,6),1,1,1]';
%! oRGB(:,:,2)=[0,0,linspace(0,1,6),1,1]';
%! oRGB(:,:,3)=[0,0,0,linspace(0,1,6),1]';

%!# a RGB image
%!assert(imadjust(iRGBn,[0;1],[10;11]),iRGBn+10);

%!# a RGB image, params in row (compatibility behaviour)
%!assert(imadjust(iRGBn,[0,1],[10,11]),iRGBn+10);

%!# a RGB, different output on each
%!test
%! t=iRGBn;
%! t(:,:,1)+=10;
%! t(:,:,2)+=20;
%! t(:,:,3)+=30;
%! assert(imadjust(iRGBn,[0;1],[10,20,30;11,21,31]),t);

%!# a RGB, different input on each, we need increased tolerance for this test
%!assert(sum(abs((imadjust(iRGB,[2,4,6;7,9,11],[0;1]) - oRGB)(:))) < 1e-10);

%!# a RGB, different input and output on each
%!test
%! t=oRGB;
%! t(:,:,2)+=1;
%! t(:,:,3)+=2;
%! assert(sum(abs((imadjust(iRGB,[2,4,6;7,9,11],[0,1,2;1,2,3]) - t)(:))) < 1e-10);

%!# a RGB, different gamma, input and output on each
%!test
%! t=oRGB;
%! t(:,:,2)=t(:,:,2).^2+1;
%! t(:,:,3)=t(:,:,3).^3+2;
%! assert(sum(abs((imadjust(iRGB,[2,4,6;7,9,11],[0,1,2;1,2,3],[1,2,3]) - t)(:))) < 1e-10);
