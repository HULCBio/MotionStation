## Copyright (C) 1999 Andy Adler <adler@sce.carleton.ca>
## Copyright (C) 2008 Søren Hauberg <soren@hauberg.org>
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
## @deftypefn {Function File} {@var{bw} =} edge (@var{im}, @var{method})
## @deftypefnx{Function File} {@var{bw} =} edge (@var{im}, @var{method}, @var{arg1}, @var{arg2})
## @deftypefnx{Function File} {[@var{bw}, @var{thresh}] =} edge (@dots{})
## Detect edges in the given image using various methods. The first input @var{im}
## is the gray scale image in which edges are to be detected. The second argument
## controls which method is used for detecting the edges. The rest of the input
## arguments depend on the selected method. The first output @var{bw} is a 
## @code{logical} image containing the edges. Most methods also returns an automatically
## computed threshold as the second output.
##
## The @var{method} input argument can any of the following strings (the default
## value is "Sobel")
##
## @table @asis
## @item "Sobel"
## Finds the edges in @var{im} using the Sobel approximation to the
## derivatives. Edge points are defined as points where the length of
## the gradient exceeds a threshold and is larger than it's neighbours
## in either the horizontal or vertical direction. The threshold is passed to
## the method in the third input argument @var{arg1}. If one is not given, a
## threshold is automatically computed as 4*@math{M}, where @math{M} is the mean
## of the gradient of the entire image. The optional 4th input argument controls
## the direction in which the gradient is approximated. It can be either
## "horizontal", "vertical", or "both" (default).
##
## @item "Prewitt"
## Finds the edges in @var{im} using the Prewitt approximation to the
## derivatives. This method works just like "Sobel" except a different aproximation
## the gradient is used.
##
## @item "Roberts"
## Finds the edges in @var{im} using the Roberts approximation to the
## derivatives. Edge points are defined as points where the length of
## the gradient exceeds a threshold and is larger than it's neighbours
## in either the horizontal or vertical direction. The threshold is passed to
## the method in the third input argument @var{arg1}. If one is not given, a
## threshold is automatically computed as 6*@math{M}, where @math{M} is the mean
## of the gradient of the entire image. The optional 4th input argument can be
## either "thinning" (default) or "nothinning". If it is "thinning" a simple
## thinning procedure is applied to the edge image such that the edges are only
## one pixel wide. If @var{arg2} is "nothinning", this procedure is not applied.
##
## @item "Kirsch"
## Finds the edges in @var{im} using the Kirsch approximation to the
## derivatives. Edge points are defined as points where the length of
## the gradient exceeds a threshold and is larger than it's neighbours
## in either the horizontal or vertical direction. The threshold is passed to
## the method in the third input argument @var{arg1}. If one is not given, a
## threshold is automatically computed as @math{M}, where @math{M} is the mean
## of the gradient of the entire image. The optional 4th input argument controls
## the direction in which the gradient is approximated. It can be either
## "horizontal", "vertical", or "both" (default).
##
## @item "LoG"
## Finds edges in @var{im} by convolving with the Laplacian of Gaussian (LoG)
## filter, and finding zero crossings. Only zero crossings where the 
## filter response is larger than an automatically computed threshold are retained.
## The threshold is passed to the method in the third input argument @var{arg1}.
## If one is not given, a threshold is automatically computed as 0.75*@math{M},
## where @math{M} is the mean of absolute value of LoG filter response. The
## optional 4th input argument sets the spread of the LoG filter. By default
## this value is 2.
##
## @item "Zerocross"
## Finds edges in the image @var{im} by convolving it with the user-supplied filter
## @var{arg2} and finding zero crossings larger than the threshold @var{arg1}. If
## @var{arg1} is [] a threshold is computed as the mean value of the absolute
## filter response.
##
## @item "Canny"
## Finds edges using the Canny edge detector. The optional third input argument
## @var{arg1} sets the thresholds used in the hysteresis thresholding. If 
## @var{arg1} is a two dimensional vector it's first element is used as the lower
## threshold, while the second element is used as the high threshold. If, on the
## other hand, @var{arg1} is a single scalar it is used as the high threshold,
## while the lower threshold is 0.4*@var{arg1}. The optional 4th input argument
## @var{arg2} is the spread of the low-pass Gaussian filter that is used to smooth
## the input image prior to estimating gradients. By default this scale parameter
## is 2.
##
## @item "Lindeberg"
## Finds edges using in @var{im} using the differential geometric single-scale edge
## detector given by Tony Lindeberg. The optional third input argument @var{arg1}
## is the scale (spread of Gaussian filter) at which the edges are computed. By
## default this 2.
##
## @item "Andy"
## A.Adler's idea (c) 1999. Somewhat based on the canny method. The steps are
## @enumerate
## @item
## Do a Sobel edge detection and to generate an image at
## a high and low threshold.
## @item
## Edge extend all edges in the LT image by several pixels,
## in the vertical, horizontal, and 45 degree directions.
## Combine these into edge extended (EE) image.
## @item
## Dilate the EE image by 1 step.
## @item
## Select all EE features that are connected to features in
## the HT image.
## @end enumerate
## 
## The parameters for the method is given in a vector:
## @table @asis
## @item params(1)==0 or 4 or 8
## Perform x connected dilatation (step 3).
## @item params(2)
## Dilatation coeficient (threshold) in step 3.
## @item params(3)
## Length of edge extention convolution (step 2).
## @item params(4)
## Coeficient of extention convolution in step 2.
## @end table
## defaults = [8, 1, 3, 3]
##
## @end table
##
## @seealso{fspecial, nonmax_supress}
## @end deftypefn

function [bw, out_threshold, g45_out, g135_out] = edge (im, method, varargin)
  ## Get the image
  if (nargin == 0)
    error("edge: not enough input arguments");
  endif
  if ( !isgray(im) )
    error("edge: first input must be a gray-scale image");
  endif

  ## Get the method
  if (nargin == 1)
    method = "Sobel";
  endif
  if (!ischar(method))
    error("edge: second argument must be a string");
  endif
  method = lower(method);

  ## Perform the actual edge detection
  switch (method)
    #####################################
    ## S O B E L
    #####################################
    case "sobel"
      ## Get the direction argument
      direction = get_direction(varargin{:});
      ## Create filters;
      h1 = fspecial("sobel"); # horizontal
      h3 = h1'; # vertical
      ## Compute edge strength
      switch(direction)
        case "horizontal"
          strength = abs( conv2(im, h1, "same") );
        case "vertical"
          strength = abs( conv2(im, h3, "same") );
        case "both"
          strength = sqrt( conv2(im, h1, "same").^2 + ...
                           conv2(im, h3, "same").^2 );
      endswitch
      ## Get threshold
      if (nargin > 2 && isscalar(varargin{1}))
        thresh = varargin{1};
      else
        thresh = 2*mean(strength(:));
      endif
      ## Perform thresholding and simple thinning
      strength(strength<=thresh) = 0;
      bw = simple_thinning(strength);

    #####################################
    ## P R E W I T T
    #####################################
    case "prewitt"
      ## Get the direction argument
      direction = get_direction(varargin{:});
      ## Create filters;
      h1 = fspecial("prewitt"); # vertical
      h3 = h1'; # horizontal
      ## Compute edge strength
      switch(direction)
        case "vertical"
          strength = abs( conv2(im, h1, "same") );
        case "horizontal"
          strength = abs( conv2(im, h3, "same") );
        case "both"
          strength = sqrt( conv2(im, h1, "same").^2 + ...
                           conv2(im, h3, "same").^2 );
      endswitch
      ## Get threshold
      if (nargin > 2 && isscalar(varargin{1}))
        thresh = varargin{1};
      else
        thresh = 4*mean(strength(:));
      endif
      ## Perform thresholding and simple thinning
      strength(strength<=thresh) = 0;
      bw = simple_thinning(strength);
    
    #####################################
    ## K I R S C H
    #####################################
    case "kirsch"
      ## Get the direction argument
      direction = get_direction(varargin{:});
      ## Create filters;
      h1 = fspecial("kirsch"); # vertical
      h3 = h1'; # horizontal
      ## Compute edge strength
      switch(direction)
        case "vertical"
          strength = abs( conv2(im, h1, "same") );
        case "horizontal"
          strength = abs( conv2(im, h3, "same") );
        case "both"
          strength = sqrt( conv2(im, h1, "same").^2 + ...
                           conv2(im, h3, "same").^2 );
      endswitch
      ## Get threshold
      if nargin > 2 && isscalar(varargin{1})
        thresh = varargin{1};
      else
        thresh = mean(strength(:));
      endif
      ## Perform thresholding and simple thinning
      strength(strength<=thresh) = 0;
      bw = simple_thinning(strength);

    #####################################
    ## R O B E R T S
    #####################################
    case "roberts"
      ## Get the thinning argument (option)
      if (nargin == 4)
        option = varargin{2};
        if (!ischar(option))
          error("edge: 'option' must be a string");
        endif
        option = lower(option);
        if (!any(strcmp(option, {"thinning", "nothinning"})))
          error("edge: 'option' must be either 'thinning', or 'nothinning'");
        endif
      else
        option = "thinning";
      endif
      ## Create filters;
      h1 = [1 0; 0 -1]; 
      h2 = [0 1; -1 0]; 
      ## Compute edge strength
      g45  = conv2(im, h1, "same");
      g135 = conv2(im, h2, "same");
      strength = abs( g45 ) + abs( g135 );
      ## Get threshold
      if (nargin > 2 && isscalar(varargin{1}))
        thresh = varargin{1};
      else
        thresh = 6*mean(strength(:));
      endif
      ## Perform thresholding and simple thinning
      strength(strength<=thresh) = 0;
      if (strcmp(option, "thinning"))
        bw = simple_thinning(strength);
      else
        bw = (strength > 0);
      endif
      ## Check if g45 and g135 should be returned
      if (nargout == 4)
        g45_out  = g45;
        g135_out = g135;
      endif
    
    #####################################
    ## L A P L A C I A N   O F   G A U S S I A N
    #####################################
    case "log"
      ## Get sigma
      if (nargin == 4 && isscalar(varargin{2}))
        sigma = varargin{2};
      else
        sigma = 2;
      endif
      ## Create the filter
      s = ceil(3*sigma);
      %[x y] = meshgrid(-s:s);
      %f = (x.^2 + y.^2 - sigma^2) .* exp(-(x.^2 + y.^2)/(2*sigma^2));
      %f = f/sum(f(:));
      f = fspecial("log", 2*s+1, sigma);
      ## Perform convolution with the filter f
      g = conv2(im, f, "same");
      ## Get threshold
      if (nargin > 2 && isscalar(varargin{1}))
        thresh = varargin{1};
      else
        thresh = 0.75*mean(abs(g(:)));
      endif
      ## Find zero crossings
      zc = zerocrossings(g);
      bw = (abs(g) >= thresh) & zc;
    
    #####################################
    ## Z E R O   C R O S S I N G 
    #####################################
    case "zerocross"
      ## Get the filter
      if (nargin == 4 && ismatrix(varargin{2}))
        f = varargin{2};
      else
        error("edge: a filter must be given as the fourth argument when 'zerocross' is used");
      endif
      ## Perform convolution with the filter f
      g = conv2(im, f, "same");
      ## Get threshold
      if (nargin > 2 && isscalar(varargin{1}))
        thresh = varargin{1};
      else
        thresh = mean(abs(g(:)));
      endif
      ## Find zero crossings
      zc = zerocrossings(g);
      bw = (abs(g) >= thresh) & zc;

    #####################################
    ## C A N N Y 
    #####################################
    case "canny"
      ## Get sigma
      if (nargin == 4 && isscalar(varargin{2}))
        sigma = varargin{2};
      else
        sigma = 2;
      endif

      ## Change scale
      J = imsmooth(double(im), "Gaussian", sigma);

      ## Canny enhancer
      p = [1 0 -1]/2;
      Jx = conv2(J, p,  "same");
      Jy = conv2(J, p', "same");
      Es = sqrt( Jx.^2 + Jy.^2 );
      Eo = pi - mod (atan2 (Jy, Jx) - pi, pi);

      ## Get thresholds
      if (nargin > 2 && isscalar(varargin{1}))
        thresh = [0.4*varargin{1}, varargin{1}];
      elseif (nargin > 2 && ismatrix (varargin{1}) && length (varargin{1}(:)) == 2)
        thresh = varargin{1}(:);
      else
        tmp = mean(abs(Es(:)));
        thresh = [0.4*tmp, tmp];
      endif
      bw = nonmax_supress(Es, Eo, thresh(1), thresh(2));

    #####################################
    ## L I N D E B E R G 
    #####################################
    case "lindeberg"
      ## In case the user asks for more then 1 output argument
      ## we define thresh to be -1.
      thresh = -1;
      ## Get sigma
      if (nargin > 2 && isscalar(varargin{1}))
        sigma = varargin{1};
      else
        sigma = 2;
      endif
      ## Filters for computing the derivatives
      Px   = [-1 0 1; -1 0 1; -1 0 1];
      Py   = [1 1 1; 0 0 0; -1 -1 -1];
      Pxx  = conv2(Px,  Px, "full");
      Pyy  = conv2(Py,  Py, "full");
      Pxy  = conv2(Px,  Py, "full");
      Pxxx = conv2(Pxx, Px, "full");
      Pyyy = conv2(Pyy, Py, "full");
      Pxxy = conv2(Pxx, Py, "full");
      Pxyy = conv2(Pyy, Px, "full");
      ## Change scale
      L = imsmooth(double(im), "Gaussian", sigma);
      ## Compute derivatives
      Lx   = conv2(L, Px,   "same");
      Ly   = conv2(L, Py,   "same");
      Lxx  = conv2(L, Pxx,  "same");
      Lyy  = conv2(L, Pyy,  "same");
      Lxy  = conv2(L, Pxy,  "same");
      Lxxx = conv2(L, Pxxx, "same");
      Lyyy = conv2(L, Pyyy, "same");
      Lxxy = conv2(L, Pxxy, "same");
      Lxyy = conv2(L, Pxyy, "same");
      ## Compute directional derivatives
      Lvv  = Lx.^2.*Lxx + 2.*Lx.*Ly.*Lxy + Ly.^2.*Lyy;
      Lvvv = Lx.^3.*Lxxx + 3.*Lx.^2.*Ly.*Lxxy ...
           + 3.*Lx.*Ly.^2.*Lxyy + 3.*Ly.^3.*Lyyy;
      ## Perform edge detection
      bw = zerocrossings(Lvv) & Lvvv < 0;

    #####################################
    ## A N D Y
    #####################################
    case "andy"
      [bw, out_threshold] = andy (im, method, varargin{:});
    
    otherwise
      error("edge: unsupported edge detector: %s", method);
  endswitch
  
  if (nargout > 1)
    out_threshold = thresh;
  endif
endfunction

## An auxilary function that parses the 'direction' argument from 'varargin'
function direction = get_direction(varargin)
  if (nargin >= 2)
    direction = varargin{2};
    if (!ischar(direction))
      error("edge: direction must be a string");
    endif
    direction = lower(direction);
    if (!any(strcmp(direction, {"horizontal", "vertical", "both"})))
      error("edge :direction must be either 'horizontal', 'vertical', or 'both'");
    endif
  else
    direction = "both";
  endif
endfunction

## An auxilary function that performs a very simple thinning.
## Strength is an image containing the edge strength.
## bw contains a 1 in (r,c) if
##  1) strength(r,c) is greater than both neighbours in the
##     vertical direction, OR
##  2) strength(r,c) is greater than both neighbours in the
##     horizontal direction.
## Note the use of OR.
function bw = simple_thinning(strength)
  [r c] = size(strength);
  x = ( strength > [ zeros(r,1) strength(:,1:end-1) ] & ...
        strength > [ strength(:,2:end) zeros(r,1) ] );
  y = ( strength > [ zeros(1,c); strength(1:end-1,:) ] & ...
        strength > [ strength(2:end,:); zeros(1,c) ] );
  bw = x | y;
endfunction

## Auxilary function. Finds the zero crossings of the 
## 2-dimensional function f. (By Etienne Grossmann)
function z = zerocrossings(f)
  z0 = f<0;                 ## Negative
  [R,C] = size(f);
  z = zeros(R,C);
  z(1:R-1,:) |= z0(2:R,:);  ## Grow
  z(2:R,:) |= z0(1:R-1,:);
  z(:,1:C-1) |= z0(:,2:C);
  z(:,2:C) |= z0(:,1:C-1);

  z &= !z0;                  ## "Positive zero-crossings"?
endfunction

## The 'andy' edge detector that was present in older versions of 'edge'.
## The function body has simply been copied from the old implementation.
##   -- Soren Hauberg, march 11th, 2008
function [imout, thresh] = andy(im, method, thresh, param2)
   [n,m]= size(im);
   xx= 2:m-1;
   yy= 2:n-1;

   filt= [1 2 1;0 0 0; -1 -2 -1]/8;  tv= 2;
   imo= conv2(im, rot90(filt), 'same').^2 + conv2(im, filt, 'same').^2;
   if nargin<3 || thresh==[];
      thresh= sqrt( tv* mean(mean( imo(yy,xx) ))  );
   end
#     sum( imo(:)>thresh ) / prod(size(imo))
   dilate= [1 1 1;1 1 1;1 1 1]; tt= 1; sz=3; dt=3;
   if nargin>=4
      # 0 or 4 or 8 connected dilation
      if length(param2) > 0
         if      param2(1)==4 ; dilate= [0 1 0;1 1 1;0 1 0];
         elseif  param2(1)==0 ; dilate= 1;
         end
      end
      # dilation threshold
      if length(param2) > 2; tt= param2(2); end
      # edge extention length
      if length(param2) > 2; sz= param2(3); end
      # edge extention threshold
      if length(param2) > 3; dt= param2(4); end
      
   end
   fobliq= [0 0 0 0 1;0 0 0 .5 .5;0 0 0 1 0;0 0 .5 .5 0;0 0 1 0 0; 
                      0 .5 .5 0 0;0 1 0 0 0;.5 .5 0 0 0;1 0 0 0 0];
   fobliq= fobliq( 5-sz:5+sz, 3-ceil(sz/2):3+ceil(sz/2) );

   xpeak= imo(yy,xx-1) <= imo(yy,xx) & imo(yy,xx) > imo(yy,xx+1) ;
   ypeak= imo(yy-1,xx) <= imo(yy,xx) & imo(yy,xx) > imo(yy+1,xx) ;

   imht= ( imo >= thresh^2 * 2); # high threshold image   
   imht(yy,xx)= imht(yy,xx) & ( xpeak | ypeak );
   imht([1,n],:)=0; imht(:,[1,m])=0;

%  imlt= ( imo >= thresh^2 / 2); # low threshold image   
   imlt= ( imo >= thresh^2 / 1); # low threshold image   
   imlt(yy,xx)= imlt(yy,xx) & ( xpeak | ypeak );
   imlt([1,n],:)=0; imlt(:,[1,m])=0;

# now we edge extend the low thresh image in 4 directions

   imee= ( conv2( imlt, ones(2*sz+1,1)    , 'same') > tt ) | ...
         ( conv2( imlt, ones(1,2*sz+1)    , 'same') > tt ) | ...
         ( conv2( imlt, eye(2*sz+1)       , 'same') > tt ) | ...
         ( conv2( imlt, rot90(eye(2*sz+1)), 'same') > tt ) | ...
         ( conv2( imlt, fobliq            , 'same') > tt ) | ...
         ( conv2( imlt, fobliq'           , 'same') > tt ) | ...
         ( conv2( imlt, rot90(fobliq)     , 'same') > tt ) | ...
         ( conv2( imlt, flipud(fobliq)    , 'same') > tt );
#  imee(yy,xx)= conv2(imee(yy,xx),ones(3),'same') & ( xpeak | ypeak );
   imee= conv2(imee,dilate,'same') > dt; #

%  ff= find( imht==1 );
%  imout = bwselect( imee, rem(ff-1, n)+1, ceil(ff/n), 8);  
   imout = imee;

endfunction
