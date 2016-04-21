## Copyright (C) 2008 Soren Hauberg <soren@hauberg.org>
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
## @deftypefn {Function File} @var{H} = houghtf (@var{bw})
## @deftypefnx{Function File} @var{H} = houghtf (@var{bw}, @var{method})
## @deftypefnx{Function File} @var{H} = houghtf (@var{bw}, @var{method}, @var{arg})
## Perform the Hough transform for lines or circles.
##
## The @var{method} argument chooses between the Hough transform for lines and
## circles. It can be either "line" (default) or "circle".
##
## @strong{Line Detection}
##
## If @var{method} is "line", the function will compute the Hough transform for
## lines. A line is parametrised in @var{r} and @var{theta} as
## @example
## @var{r} = x*cos(@var{theta}) + y*sin(@var{theta}),
## @end example
## where @var{r} is distance between the line and the origin, while @var{theta}
## is the angle of the vector from the origin to this closest point. The result
## @var{H} is an @var{N} by @var{M} matrix containing the Hough transform. Here,
## @var{N} is the number different values of @var{r} that has been attempted.
## This is computed as @code{2*diag_length - 1}, where @code{diag_length} is
## the length of the diagonal of the input image. @var{M} is the number of
## different values of @var{theta}. These can be set through the third input
## argument @var{arg}. This must be a vector of real numbers, and is by default
## @code{pi*(-90:90)/180}.
##
## @strong{Circle Detection}
##
## If @var{method} is "circle" the function will compute the Hough transform for
## circles. The circles are parametrised in @var{r} which denotes the radius of
## the circle. The third input argument @var{arg} must be a real vector containing
## the possible values of @var{r}.
## If the input image is @var{N} by @var{M}, then the result @var{H} will be an
## @var{N} by @var{M} by @var{K} array, where @var{K} denotes the number of
## different values of @var{r}.
##
## As an example, the following shows how to compute the Hough transform for circles
## with radius 3 or 7 in the image @var{im}
## @example
## bw = edge(im);
## H = houghtf(bw, "circle", [3, 7]);
## @end example
## Here @var{H} will be an NxMx2 array, where @var{H}(:,:,1) will contain the
## Hough transform for circles with radius 3, and @var{H}(:,:,2) for radius 7.
## To find good circles you now need to find local maximas in @var{H}. If you
## find a local maxima in @var{H}(row, col, 1) it means that a good circle exists
## with center (row,col) and radius 3. One way to locate maximas is to use the
## @code{immaximas} function.
##
## @seealso{hough_line, hough_circle, immaximas}
## @end deftypefn

function [accum, R] = houghtf(bw, varargin)
  ## Default arguments
  method = "line";
  args = {};
  
  ## Check input arguments
  if (nargin == 0)
    error("houghtf: not enough input arguments");
  endif

  if (!ismatrix(bw) || ndims(bw) != 2)
    error("houghtf: first arguments must be a 2-dimensional matrix");
  endif

  if (nargin > 1)
    if (ischar(varargin{1}))
      method = varargin{1};
      args = varargin(2:end);
    else
      args = varargin;
    endif
  endif
  
  ## Choose method
  switch (lower(method))
    case "line"
      [accum, R] = hough_line(bw, args{:});
    case "circle"
      accum = hough_circle(bw, args{:});
    otherwise
      error("houghtf: unsupported method '%s'", method);
  endswitch

endfunction
