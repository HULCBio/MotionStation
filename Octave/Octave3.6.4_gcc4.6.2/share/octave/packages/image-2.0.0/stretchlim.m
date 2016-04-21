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
## @deftypefn {Function File} {@var{LOW_HIGH} = } stretchlim (@var{I},@var{TOL})
## @deftypefnx {Function File} {@var{LOW_HIGH} = } stretchlim (@var{I})
## @deftypefnx {Function File} {@var{LOW_HIGH} = } stretchlim (@var{RGB},@var{TOL})
## @deftypefnx {Function File} {@var{LOW_HIGH} = } stretchlim (@var{RGB})
## Finds limits to contrast stretch an image
##
## @code{LOW_HIGH=stretchlim(I,TOL)} returns a vector @var{LOW_HIGH}
## which contains a pair of intensities which can be used in
## @code{imadjust} to stretch the contrast of an image, first of them
## will be lower value (@code{imadjust} would assign 0 to it) and second
## is the upper bound. @var{TOL} specifies the fraction of the image to
## saturate at lower and upper limits. It can be a vector of length 2:
## @code{[LOW_FRACT, HIGH_FRACT]}, or it can be a scalar, in that case
## @code{[LOW_FRACT, HIGH_FRACT]=[TOL, 1-TOL]}.
##
## @var{TOL} can't be larger than 0.50 and for TOL=0 then
## @code{LOW_HIGH=[min(I(:)), max(I(:))]}.
##
## @code{LOW_HIGH=stretchlim(I)} behaves as described but defaults
## @var{TOL} to @code{[0.01, 0.99]}.
##
## @code{LOW_HIGH=stretchlim(RGB,TOL)} returns a 2-by-3 matrix in
## @var{LOW_HIGH} of lower and upper values to saturate for each plane
## of the RGB image in M-by-N-by-3 array @var{RGB}. @var{TOL} is a
## vector or a scalar, as described above, and the same fractions are
## applied for each plane.
##
## @code{LOW_HIGH=stretchlim(RGB)} uses @code{[0.01, 0.99]} as default
## value for @var{TOL}.
##
## @strong{Notes:}
##
## Values in @var{LOW_HIGH} are of type double and comprised between 0
## and 1 regardless class of input image.
##
## @strong{Compatibility notes:}
##
## @itemize @bullet
## @item
## int* and uint* types are still not implemented (waiting for support
## in Octave 2.1.58).
## @item
## This function tries to find limits that are nearer to saturate
## requested interval. So, for instance, if you requested a 5% and it
## has to choose between discarding a 1% and a 7%, it will choose the
## later despite being more than requested. This should be test against
## MATLAB behaviour.
## @end itemize
##
## @seealso{imadjust}
## @end deftypefn

function LOW_HIGH = stretchlim(image, TOL)
  if (nargin<1 || nargin>2)
    print_usage;
  endif
  
  if(!ismatrix(image) || ischar(image))
    error("stretchlim: image should be a matrix");
  endif
  
  ## Prepare limits
  if(nargin==1)
    low_count=0.01;
    high_count=0.01;                ## we use this definition in __stretchlim_plane__
  else
    if(isscalar(TOL))
      if(TOL<0 || TOL>=0.5)
        error("stretchlim: TOL out of bounds. Expected: 0<=TOL<0.5");
      endif
      low_count=TOL;
      high_count=TOL;               ## as before...
    elseif(isvector(TOL))
      if(length(TOL)!=2)
        error("stretchlim: TOL length must be 2.");
      endif
      low_count=TOL(1);
      high_count=1-TOL(2);          ## as before...
    else
      error("stretchlim: TOL contains an invalid value.");
    endif
  endif

  ## well use size of image several times...
  simage=size(image);

  ## Convert fractions to pixels
  psimage=prod(simage(1:2));
  low_count*=psimage;
  high_count*=psimage;

  if(length(simage)<=2)
    ## intensity
    LOW_HIGH=__stretchlim_plane__(image, low_count, high_count);
  elseif(length(simage)==3 && simage(3)==3)
    ## RGB
    LOW_HIGH=zeros(2,3);
    for i=1:3
      LOW_HIGH(:,i)=__stretchlim_plane__(image(:,:,i), low_count, ...
                                         high_count);
    endfor
  else
    error("stretchlim: invalid image.");
  endif
endfunction


## Processes a plane
## high_count is defined so that high_count=elements is the same as
## low_count=elements (and not total_elements-elements)
function LOW_HIGH = __stretchlim_plane__(plane, low_count, high_count)
  ## check exceptions
  if(low_count==0 && high_count==0)
    LOW_HIGH=[min(plane(:)); max(plane(:))];
  else

    ## we sort values
    sorted=sort(plane(:));
    
    low=sorted(round(low_count+1));
    pos=find(sorted>low);
    if(length(pos)>0)
      low2=sorted(pos(1));
      d1=low_count-sum(sorted<low);
      d2=sum(sorted<low2)-low_count;
      if(d2<d1)
        low=low2;
      endif
    endif
      
    high=sorted(end-round(high_count));
    pos=find(sorted<high);
    if(length(pos)>0)
      high2=sorted(pos(end));
      d1=high_count-sum(sorted>high);
      d2=sum(sorted>high2)-high_count;
      if(d2<d1)
        high=high2;
      endif
    endif

    ## set result variable
    LOW_HIGH=[low;high];
  endif
endfunction

%!demo
%! stretchlim([1:100])
%! # This discards 1% of data from each end, 1 and 100.
%! # So result should be [2;99]

%!# some invalid params
%!error(stretchlim());
%!error(stretchlim("bad parameter"));
%!error(stretchlim(zeros(10,10,4)));
%!error(stretchlim(zeros(10,10,3,2)));
%!error(stretchlim(zeros(10,10),"bad parameter"));
%!error(stretchlim(zeros(10,10),0.01,2));


%!# default param
%!assert(stretchlim([1:100]),[2;99]);

%!# scalar TOL
%!assert(stretchlim([1:100],0.01),[2;99]);

%!# vector TOL
%!assert(stretchlim([1:100],[0.01,0.98]),[2;98]);

%!# TOL=0
%!assert(stretchlim([1:100],0),[1;100]);

%!# non uniform histogram tests
%!assert(stretchlim([1,ones(1,90)*2,92:100],0.05),[2;95]);
%!assert(stretchlim([1,ones(1,4)*2,6:100],0.05),[6;95]);

%!# test limit rounding...
%!assert(stretchlim([1,ones(1,5)*2,7:100],0.05),[7;95]); # 6% lost 
%!assert(stretchlim([1,ones(1,6)*2,8:100],0.05),[8;95]); # 7% lost
%!assert(stretchlim([1,ones(1,7)*2,9:100],0.05),[9;95]); # 8% lost
%!assert(stretchlim([1,ones(1,8)*2,10:100],0.05),[2;95]); # now he limit at 2 => 1% lost

%!# test RGB
%!test
%! RGB=zeros(100,1,3);
%! RGB(:,:,1)=[1:100];
%! RGB(:,:,2)=[2:2:200];
%! RGB(:,:,3)=[4:4:400];
%! assert(stretchlim(RGB),[2,4,8;99,198,396]);
