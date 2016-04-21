## Copyright (c) 2003-2005 Peter Kovesi
## School of Computer Science & Software Engineering
## The University of Western Australia
## http://www.csse.uwa.edu.au/
##
## Permission is hereby granted, free of charge, to any person obtaining a copy
## of this software and associated documentation files (the "Software"), to deal
## in the Software without restriction, including without limitation the rights
## to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
## copies of the Software, and to permit persons to whom the Software is
## furnished to do so, subject to the following conditions:
##
## The above copyright notice and this permission notice shall be included in
## all copies or substantial portions of the Software.
##
## The software is provided "as is", without warranty of any kind, express or
## implied, including but not limited to the warranties of merchantability,
## fitness for a particular purpose and noninfringement. In no event shall the
## authors or copyright holders be liable for any claim, damages or other
## liability, whether in an action of contract, tort or otherwise, arising from,
## out of or in connection with the software or the use or other dealings in the
## software.
##
## I've made minor changes compared to the original 'nonmaxsuppts' function developed
## by Peter Kovesi. The original is available at
## http://www.csse.uwa.edu.au/~pk/research/matlabfns/Spatial/nonmaxsuppts.m
##    -- Søren Hauberg, 2008

## -*- texinfo -*-
## @deftypefn {Function File} {[@var{r}, @var{c}] =} immaximas (@var{im}, @var{radius})
## @deftypefnx{Function File} {[@var{r}, @var{c}] =} immaximas (@var{im}, @var{radius}, @var{thresh})
## @deftypefnx{Function File} {[@var{r}, @var{c}, @dots{}] =} immaximas (@dots{})
## @deftypefnx{Function File} {[@dots{}, @var{val}] =} immaximas (@dots{})
## Finds local spatial maximas of the given image. A local spatial maxima is
## defined as an image point with a value that is larger than all neighbouring
## values in a square region of width 2*@var{radius}+1. By default @var{radius}
## is 1, such that a 3 by 3 neighbourhood is searched. If the @var{thresh} input
## argument is supplied, only local maximas with a value greater than @var{thresh}
## are retained.
## 
## The output vectors @var{r} and @var{c} contain the row-column coordinates
## of the local maximas. The actual values are computed to sub-pixel precision
## by fitting a parabola to the data around the pixel. If @var{im} is 
## @math{N}-dimensional, then @math{N} vectors will be returned.
##
## If @var{im} is @math{N}-dimensional, and @math{N}+1 outputs are requested,
## then the last output will contain the image values at the maximas. Currently
## this value is not interpolated.
##
## @seealso{ordfilt2, ordfiltn}
## @end deftypefn

function varargout = immaximas(im, radius, thresh)
  ## Check input
  if (nargin == 0)
    error("immaximas: not enough input arguments");
  endif
  if (nargin <= 1 || isempty(radius))
    radius = 1;
  endif
  if (nargin <= 2)
    thresh = [];
  endif
  if (!ismatrix(im))
    error("immaximas: first input argument must be an array");
  endif
  if (!isscalar(radius))
    error("immaximas: second input argument must be a scalar or an empty matrix");
  endif
  if (!isscalar(thresh) && !isempty(thresh))
    error("immaximas: third input argument must be a scalar or an empty matrix");
  endif
  
  ## Find local maximas
  nd = ndims(im);
  s = size(im);
  sze = 2*radius+1;
  mx  = ordfiltn(im, sze^nd,   ones(repmat(sze,1, nd), "logical"), "reflect");
  mx2 = ordfiltn(im, sze^nd-1, ones(repmat(sze,1, nd), "logical"), "reflect");

  # Find maxima, threshold
  immx = (im == mx) & (im != mx2);
  if (!isempty(thresh))
    immx &= (im>thresh);
  endif
    
  ## Find local maximas and fit parabolas locally
  ind = find(immx);
  [sub{1:nd}] = ind2sub(s, ind);
  if (!isempty(ind))
    w = 1; # Width that we look out on each side of the feature point to fit a local parabola
    ws = w*cumprod([1; s(:)]);
    
    ## We fit a parabola to the points in each dimension
    for d = 1:nd
      ## Indices of points above, below, left and right of feature point
      indminus1 = max(ind-ws(d), 1);
      indplus1  = min(ind+ws(d), numel(immx));

      ## Solve quadratic
      c = im(ind);
      a = (im(indminus1) + im(indplus1))/2 - c;
      b = a + c - im(indminus1);
      shift = -w*b./(2*a); # Maxima of quadradic 
      
      ## Move point   
      sub{d} += shift;
    endfor
  endif
  
  ## Output
  varargout(1:nd) = sub(1:nd);
  if (nargout > nd)
    varargout{nd+1} = im(ind);
  endif
endfunction
