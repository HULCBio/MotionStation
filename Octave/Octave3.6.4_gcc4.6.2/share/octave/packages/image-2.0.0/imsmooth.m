## Copyright (C) 2007 Soren Hauberg <soren@hauberg.org>
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
## @deftypefn {Function File} @var{J} = imsmooth(@var{I}, @var{name}, @var{options})
## Smooth the given image using several different algorithms.
##
## The first input argument @var{I} is the image to be smoothed. If it is an RGB
## image, each color plane is treated separately.
## The variable @var{name} must be a string that determines which algorithm will
## be used in the smoothing. It can be any of the following strings
##
## @table @asis
## @item  "Gaussian"
## Isotropic Gaussian smoothing. This is the default.
## @item  "Average"
## Smoothing using a rectangular averaging linear filter.
## @item  "Disk"
## Smoothing using a circular averaging linear filter.
## @item  "Median"
## Median filtering.
## @item  "Bilateral"
## Gaussian bilateral filtering.
## @item  "Perona & Malik"
## @itemx "Perona and Malik"
## @itemx "P&M"
## Smoothing using nonlinear isotropic diffusion as described by Perona and Malik.
## @item "Custom Gaussian"
## Gaussian smoothing with a spatially varying covariance matrix.
## @end table
##
## In all algorithms the computation is done in double precision floating point
## numbers, but the result has the same type as the input. Also, the size of the
## smoothed image is the same as the input image.
##
## @strong{Isotropic Gaussian smoothing}
##
## The image is convolved with a Gaussian filter with spread @var{sigma}.
## By default @var{sigma} is @math{0.5}, but this can be changed. If the third
## input argument is a scalar it is used as the filter spread.
##
## The image is extrapolated symmetrically before the convolution operation.
##
## @strong{Rectangular averaging linear filter}
##
## The image is convolved with @var{N} by @var{M} rectangular averaging filter.
## By default a 3 by 3 filter is used, but this can e changed. If the third
## input argument is a scalar @var{N} a @var{N} by @var{N} filter is used. If the third
## input argument is a two-vector @code{[@var{N}, @var{M}]} a @var{N} by @var{M}
## filter is used.
##
## The image is extrapolated symmetrically before the convolution operation.
##
## @strong{Circular averaging linear filter}
##
## The image is convolved with circular averaging filter. By default the filter
## has a radius of 5, but this can e changed. If the third input argument is a
## scalar @var{r} the radius will be @var{r}.
##
## The image is extrapolated symmetrically before the convolution operation.
##
## @strong{Median filtering}
##
## Each pixel is replaced with the median of the pixels in the local area. By
## default, this area is 3 by 3, but this can be changed. If the third input
## argument is a scalar @var{N} the area will be @var{N} by @var{N}, and if it's
## a two-vector [@var{N}, @var{M}] the area will be @var{N} by @var{M}.
## 
## The image is extrapolated symmetrically before the filtering is performed.
##
## @strong{Gaussian bilateral filtering}
##
## The image is smoothed using Gaussian bilateral filtering as described by
## Tomasi and Manduchi [2]. The filtering result is computed as
## @example
## @var{J}(x0, y0) = k * SUM SUM @var{I}(x,y) * w(x, y, x0, y0, @var{I}(x0,y0), @var{I}(x,y))
##                  x   y        
## @end example
## where @code{k} a normalisation variable, and
## @example
## w(x, y, x0, y0, @var{I}(x0,y0), @var{I}(x,y))
##   = exp(-0.5*d([x0,y0],[x,y])^2/@var{sigma_d}^2)
##     * exp(-0.5*d(@var{I}(x0,y0),@var{I}(x,y))^2/@var{sigma_r}^2),
## @end example
## with @code{d} being the Euclidian distance function. The two paramteres
## @var{sigma_d} and @var{sigma_r} control the amount of smoothing. @var{sigma_d}
## is the size of the spatial smoothing filter, while @var{sigma_r} is the size
## of the range filter. When @var{sigma_r} is large the filter behaves almost
## like the isotropic Gaussian filter with spread @var{sigma_d}, and when it is
## small edges are preserved better. By default @var{sigma_d} is 2, and @var{sigma_r}
## is @math{10/255} for floating points images (with integer images this is
## multiplied with the maximal possible value representable by the integer class).
## 
## The image is extrapolated symmetrically before the filtering is performed.
##
## @strong{Perona and Malik}
##
## The image is smoothed using nonlinear isotropic diffusion as described by Perona and
## Malik [1]. The algorithm iteratively updates the image using
##
## @example
## I += lambda * (g(dN).*dN + g(dS).*dS + g(dE).*dE + g(dW).*dW)
## @end example
##
## @noindent
## where @code{dN} is the spatial derivative of the image in the North direction,
## and so forth. The function @var{g} determines the behaviour of the diffusion.
## If @math{g(x) = 1} this is standard isotropic diffusion.
##
## The above update equation is repeated @var{iter} times, which by default is 10
## times. If the third input argument is a positive scalar, that number of updates
## will be performed.
##
## The update parameter @var{lambda} affects how much smoothing happens in each
## iteration. The algorithm can only be proved stable is @var{lambda} is between
## 0 and 0.25, and by default it is 0.25. If the fourth input argument is given
## this parameter can be changed.
##
## The function @var{g} in the update equation determines the type of the result.
## By default @code{@var{g}(@var{d}) = exp(-(@var{d}./@var{K}).^2)} where @var{K} = 25.
## This choice gives privileges to high-contrast edges over low-contrast ones.
## An alternative is to set @code{@var{g}(@var{d}) = 1./(1 + (@var{d}./@var{K}).^2)},
## which gives privileges to wide regions over smaller ones. The choice of @var{g}
## can be controlled through the fifth input argument. If it is the string
## @code{"method1"}, the first mentioned function is used, and if it is @var{"method2"}
## the second one is used. The argument can also be a function handle, in which case
## the given function is used. It should be noted that for stability reasons,
## @var{g} should return values between 0 and 1.
##
## The following example shows how to set
## @code{@var{g}(@var{d}) = exp(-(@var{d}./@var{K}).^2)} where @var{K} = 50.
## The update will be repeated 25 times, with @var{lambda} = 0.25.
##
## @example
## @var{g} = @@(@var{d}) exp(-(@var{d}./50).^2);
## @var{J} = imsmooth(@var{I}, "p&m", 25, 0.25, @var{g});
## @end example
##
## @strong{Custom Gaussian Smoothing}
##
## The image is smoothed using a Gaussian filter with a spatially varying covariance
## matrix. The third and fourth input arguments contain the Eigenvalues of the
## covariance matrix, while the fifth contains the rotation of the Gaussian.
## These arguments can be matrices of the same size as the input image, or scalars.
## In the last case the scalar is used in all pixels. If the rotation is not given
## it defaults to zero.
##
## The following example shows how to increase the size of an Gaussian
## filter, such that it is small near the upper right corner of the image, and
## large near the lower left corner.
##
## @example
## [@var{lambda1}, @var{lambda2}] = meshgrid (linspace (0, 25, columns (@var{I})), linspace (0, 25, rows (@var{I})));
## @var{J} = imsmooth (@var{I}, "Custom Gaussian", @var{lambda1}, @var{lambda2});
## @end example
##
## The implementation uses an elliptic filter, where only neighbouring pixels
## with a Mahalanobis' distance to the current pixel that is less than 3 are
## used to compute the response. The response is computed using double precision
## floating points, but the result is of the same class as the input image.
##
## @strong{References}
##
## [1] P. Perona and J. Malik,
## "Scale-space and edge detection using anisotropic diffusion",
## IEEE Transactions on Pattern Analysis and Machine Intelligence,
## 12(7):629-639, 1990.
##
## [2] C. Tomasi and R. Manduchi,
## "Bilateral Filtering for Gray and Color Images",
## Proceedings of the 1998 IEEE International Conference on Computer Vision, Bombay, India.
##
## @seealso{imfilter, fspecial}
## @end deftypefn

## TODO: Implement Joachim Weickert's anisotropic diffusion (it's soo cool)

function J = imsmooth(I, name = "Gaussian", varargin)
  ## Check inputs
  if (nargin == 0)
    print_usage();
  endif
  if (!ismatrix(I))
    error("imsmooth: first input argument must be an image");
  endif
  [imrows, imcols, imchannels, tmp] = size(I);
  if ((imchannels != 1 && imchannels != 3) || tmp != 1)
    error("imsmooth: first input argument must be an image");
  endif
  if (nargin == 2 && isscalar (name))
    varargin {1} = name;
    name = "Gaussian";
  endif
  if (!ischar(name))
    error("imsmooth: second input must be a string");
  endif
  len = length(varargin);
  
  ## Save information for later
  C = class(I);
  
  ## Take action depending on 'name'
  switch (lower(name))
    ##############################
    ###   Gaussian smoothing   ###
    ##############################
    case "gaussian"
      ## Check input
      s = 0.5;
      if (len > 0)
        if (isscalar(varargin{1}) && varargin{1} > 0)
          s = varargin{1};
        else
          error("imsmooth: third input argument must be a positive scalar when performing Gaussian smoothing");
        endif
      endif
      ## Compute filter
      h = ceil(3*s);
      f = exp( (-(-h:h).^2)./(2*s^2) ); f /= sum(f);
      ## Pad image
      I = double(impad(I, h, h, "symmetric"));
      ## Perform the filtering
      for i = imchannels:-1:1
        J(:,:,i) = conv2(f, f, I(:,:,i), "valid");
      endfor

    ############################
    ###   Square averaging   ###
    ############################
    case "average"
      ## Check input
      s = [3, 3];
      if (len > 0)
        if (isscalar(varargin{1}) && varargin{1} > 0)
          s = [varargin{1}, varargin{1}];
        elseif (isvector(varargin{1}) && length(varargin{1}) == 2 && all(varargin{1} > 0))
          s = varargin{1};
        else
          error("imsmooth: third input argument must be a positive scalar or two-vector when performing averaging");
        endif
      endif
      ## Compute filter
      f2 = ones(1,s(1))/s(1);
      f1 = ones(1,s(2))/s(2);
      ## Pad image
      I = impad(double(I), floor([s(2), s(2)-1]/2), floor([s(1), s(1)-1]/2), "symmetric");
      ## Perform the filtering
      for i = imchannels:-1:1
        J(:,:,i) = conv2(f1, f2, I(:,:,i), "valid");
      endfor
      
    ##############################
    ###   Circular averaging   ###
    ##############################
    case "disk"
      ## Check input
      r = 5;
      if (len > 0)
        if (isscalar(varargin{1}) && varargin{1} > 0)
          r = varargin{1};
        else
          error("imsmooth: third input argument must be a positive scalar when performing averaging");
        endif
      endif
      ## Compute filter
      f = fspecial("disk", r);
      ## Pad image
      I = impad(double(I), r, r, "symmetric");
      ## Perform the filtering
      for i = imchannels:-1:1
        J(:,:,i) = conv2(I(:,:,i), f, "valid");
      endfor
    
    ############################
    ###   Median Filtering   ###
    ############################
    case "median"
      ## Check input
      s = [3, 3];
      if (len > 0)
        opt = varargin{1};
        if (isscalar(opt) && opt > 0)
          s = [opt, opt];
        elseif (isvector(opt) && numel(opt) == 2 && all(opt>0))
          s = opt;
        else
          error("imsmooth: third input argument must be a positive scalar or two-vector");
        endif
        s = round(s); # just in case the use supplies non-integers.
      endif
      ## Perform the filtering
      for i = imchannels:-1:1
        J(:,:,i) = medfilt2(I(:,:,i), s, "symmetric");
      endfor
    
    ###############################
    ###   Bilateral Filtering   ###
    ###############################
    case "bilateral"
      ## Check input
      if (len > 0 && !isempty(varargin{1}))
        if (isscalar(varargin{1}) && varargin{1} > 0)
          sigma_d = varargin{1};
        else
          error("imsmooth: spread of closeness function must be a positive scalar");
        endif
      else
        sigma_d = 2;
      endif
      if (len > 1 && !isempty(varargin{2}))
        if (isscalar(varargin{2}) && varargin{2} > 0)
          sigma_r = varargin{2};
        else
          error("imsmooth: spread of similarity function must be a positive scalar");
        endif
      else
        sigma_r = 10/255;
        if (isinteger(I)), sigma_r *= intmax(C); endif
      endif
      ## Pad image
      s = max([round(3*sigma_d),1]);
      I = impad(I, s, s, "symmetric");
      ## Perform the filtering
      J = __bilateral__(I, sigma_d, sigma_r);
    
    ############################
    ###   Perona and Malik   ###
    ############################
    case {"perona & malik", "perona and malik", "p&m"}
      ## Check input
      K = 25;
      method1 = @(d) exp(-(d./K).^2);
      method2 = @(d) 1./(1 + (d./K).^2);
      method = method1;
      lambda = 0.25;
      iter = 10;
      if (len > 0 && !isempty(varargin{1}))
        if (isscalar(varargin{1}) && varargin{1} > 0)
          iter = varargin{1};
        else
          error("imsmooth: number of iterations must be a positive scalar");
        endif
      endif
      if (len > 1 && !isempty(varargin{2}))
        if (isscalar(varargin{2}) && varargin{2} > 0)
          lambda = varargin{2};
        else
          error("imsmooth: fourth input argument must be a scalar when using 'Perona & Malik'");
        endif
      endif
      if (len > 2 && !isempty(varargin{3}))
        fail = false;
        if (ischar(varargin{3}))
          if (strcmpi(varargin{3}, "method1"))
            method = method1;
          elseif (strcmpi(varargin{3}, "method2"))
            method = method2;
          else
            fail = true;
          endif
        elseif (strcmp(typeinfo(varargin{3}), "function handle"))
          method = varargin{3};
        else
          fail = true;
        endif
        if (fail)
          error("imsmooth: fifth input argument must be a function handle or the string 'method1' or 'method2' when using 'Perona & Malik'");
        endif
      endif
      ## Perform the filtering
      I = double(I);
      for i = imchannels:-1:1
        J(:,:,i) = pm(I(:,:,i), iter, lambda, method);
      endfor
    
    #####################################
    ###   Custom Gaussian Smoothing   ###
    #####################################
    case "custom gaussian"
      ## Check input
      if (length (varargin) < 2)
        error ("imsmooth: not enough input arguments");
      elseif (length (varargin) == 2)
        varargin {3} = 0; # default theta value
      endif
      arg_names = {"third", "fourth", "fifth"};
      for k = 1:3
        if (isscalar (varargin {k}))
          varargin {k} = repmat (varargin {k}, imrows, imcols);
        elseif (ismatrix (varargin {k}) && ndims (varargin {k}) == 2)
          if (rows (varargin {k}) != imrows || columns (varargin {k}) != imcols)
            error (["imsmooth: %s input argument must have same number of rows "
                    "and columns as the input image"], arg_names {k});
          endif
        else
          error ("imsmooth: %s input argument must be a scalar or a matrix", arg_names {k});
        endif
        if (!strcmp (class (varargin {k}), "double"))
          error ("imsmooth: %s input argument must be of class 'double'", arg_names {k});
        endif
      endfor
      
      ## Perform the smoothing
      for i = imchannels:-1:1
        J(:,:,i) = __custom_gaussian_smoothing__ (I(:,:,i), varargin {:});
      endfor
    
    ######################################
    ###   Mean Shift Based Smoothing   ###
    ######################################  
    # NOT YET IMPLEMENTED
    #case "mean shift"
    #  J = mean_shift(I, varargin{:});

    #############################
    ###   Unknown filtering   ###
    #############################
    otherwise
      error("imsmooth: unsupported smoothing type '%s'", name);
  endswitch
  
  ## Cast the result to the same class as the input
  J = cast(J, C);
endfunction

## Perona and Malik for gray-scale images
function J = pm(I, iter, lambda, g)
  ## Initialisation
  [imrows, imcols] = size(I);
  J = I;
  
  for i = 1:iter
    ## Pad image
    padded = impad(J, 1, 1, "replicate");

    ## Spatial derivatives
    dN = padded(1:imrows, 2:imcols+1) - J;
    dS = padded(3:imrows+2, 2:imcols+1) - J;
    dE = padded(2:imrows+1, 3:imcols+2) - J;
    dW = padded(2:imrows+1, 1:imcols) - J;

    gN = g(dN);
    gS = g(dS);
    gE = g(dE);
    gW = g(dW);

    ## Update
    J += lambda*(gN.*dN + gS.*dS + gE.*dE + gW.*dW);
  endfor
endfunction

## Mean Shift smoothing for gray-scale images
## XXX: This function doesn't work!!
#{
function J = mean_shift(I, s1, s2)
  sz = [size(I,2), size(I,1)];
  ## Mean Shift
  [x, y] = meshgrid(1:sz(1), 1:sz(2));
  f = ones(s1);
  tmp = conv2(ones(sz(2), sz(1)), f, "same"); # We use normalised convolution to handle the border
  m00 = conv2(I, f, "same")./tmp;
  m10 = conv2(I.*x, f, "same")./tmp;
  m01 = conv2(I.*y, f, "same")./tmp;
  ms_x = round( m10./m00 ); # konverter ms_x og ms_y til linære indices og arbejd med dem!
  ms_y = round( m01./m00 );
  
  ms = sub2ind(sz, ms_y, ms_x);
  %for i = 1:10
  i = 0;
  while (true)
    disp(++i)
    ms(ms) = ms;
    #new_ms = ms(ms);
    if (i >200), break; endif
    #idx = ( abs(I(ms)-I(new_ms)) < s2 );
    #ms(idx) = new_ms(idx);
    %for j = 1:length(ms)
    %  if (abs(I(ms(j))-I(ms(ms(j)))) < s2)
    %    ms(j) = ms(ms(j));
    %  endif
    %endfor
  endwhile
  %endfor
  
  ## Compute result
  J = I(ms);
endfunction
#}
