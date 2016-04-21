## Copyright (C) 2010 Alex Opie <lx_op@orcon.net.nz>
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
##
## @defun {@var{P} =} phantom ('Shepp-Logan', @var{n})
##
## Produces the Shepp-Logan phantom, with size @var{n} x @var{n}.
## If @var{n} is omitted, 256 is used.
##
## @defunx {@var{P} =} phantom ('Modified Shepp-Logan', @var{n})
##
## Produces a modified version of the Shepp-Logan phantom which has
## higher contrast than the original,  with size @var{n} x @var{n}.
## If @var{n} is omitted, 256 is used.
##
## @defunx {@var{P} =} phantom (@var{ellipses}, @var{n})
##
## Produces a custom phantom using the ellipses described in @var{ellipses}.
## Each row of @var{ellipses} describes one ellipse, and must have 6 columns:
## @{I, a, b, x0, y0, phi@}:
##  @table @abbr
##  @item I
##    is the additive intensity of the ellipse
##
##  @item a
##    is the length of the major axis
##
##  @item b
##    is the length of the minor axis
##
##  @item x0
##    is the horizontal offset of the centre of the ellipse
##
##  @item y0
##    is the vercal offset of the centre of the ellipse
##
##  @item phi
##    is the counterclockwise rotation of the ellipse in degrees,
##    measured as the angle between the x axis and the ellipse major axis.
##
## @end table
##
## The image bounding box in the algorithm is @{[-1, -1], [1, 1]@}, so the
## values of a, b, x0, y0 should all be specified with this in mind.
## If @var{n} is omitted, 256 is used.
##
## @defunx {@var{P} =} phantom (@var{n})
##
## Creates a modified Shepp-Logan phantom with size @var{n} x @var{n}.
##
## @defunx {@var{P} = } phantom ()
##
## Creates a modified Shepp-Logan phantom with size 256 x 256.
## @end defun
##
## Create a Shepp-Logan or modified Shepp-Logan phantom.
##
## A phantom is a known object (either real or purely mathematical) that
## is used for testing image reconstruction algorithms.  The Shepp-Logan
## phantom is a popular mathematical model of a cranial slice, made up
## of a set of ellipses.  This allows rigorous testing of computed 
## tomography (CT) algorithms as it can be analytically transformed with
## the radon transform (see the function @command{radon}).
##
## Example:
## 
## @example
##   P = phantom (512);
##   imshow (P, []);
## @end example
##
## References:
##
##  Shepp, L. A.; Logan, B. F.; Reconstructing Interior Head Tissue 
##  from X-Ray Transmissions, IEEE Transactions on Nuclear Science,
##  Feb. 1974, p. 232.
##
##  Toft, P.; "The Radon Transform - Theory and Implementation", Ph.D. thesis,
##  Department of Mathematical Modelling, Technical University 
##  of Denmark, June 1996.

function p = phantom (varargin)

  [n, ellipses] = read_args (varargin {:});

  # Blank image
  p = zeros (n);

  # Create the pixel grid
  xvals = (-1 : 2 / (n - 1) : 1);
  xgrid = repmat (xvals, n, 1);

  for i = 1:size (ellipses, 1)    
    I   = ellipses (i, 1);
    a2  = ellipses (i, 2)^2;
    b2  = ellipses (i, 3)^2;
    x0  = ellipses (i, 4);
    y0  = ellipses (i, 5);
    phi = ellipses (i, 6) * pi / 180;  # Rotation angle in radians
    
    # Create the offset x and y values for the grid
    x = xgrid - x0;
    y = rot90 (xgrid) - y0;
    
    cos_p = cos (phi); 
    sin_p = sin (phi);
    
    # Find the pixels within the ellipse
    locs = find (((x .* cos_p + y .* sin_p).^2) ./ a2 ...
     + ((y .* cos_p - x .* sin_p).^2) ./ b2 <= 1);
    
    # Add the ellipse intensity to those pixels
    p (locs) = p (locs) + I;
  endfor
endfunction

function [n, ellip] = read_args (varargin)
  n = 256;
  ellip = mod_shepp_logan ();
  
  if (nargin == 1)
    if (ischar (varargin {1}))
      ellip = select_phantom (varargin {1});
    elseif (numel (varargin {1}) == 1)
      n = varargin {1};
    else
      if (size (varargin {1}, 2) != 6)
        error ("Wrong number of columns in user phantom");
      endif
      ellip = varargin {1};
    endif
  elseif (nargin == 2)
    n = varargin {2};
    if (ischar (varargin {1}))
      ellip = select_phantom (varargin {1});
    else
      if (size (varargin {1}, 2) != 6)
        error ("Wrong number of columns in user phantom");
      endif
      ellip = varargin {1};
    endif
  elseif (nargin > 2)
    warning ("Extra arguments passed to phantom were ignored");
  endif
endfunction

function e = select_phantom (name)
  if (strcmpi (name, 'shepp-logan'))
    e = shepp_logan ();
  elseif (strcmpi (name, 'modified shepp-logan'))
    e = mod_shepp_logan ();
  else
    error ("Unknown phantom type: %s", name);
  endif
endfunction

function e = shepp_logan
  #  Standard head phantom, taken from Shepp & Logan
  e = [  2,   .69,   .92,    0,      0,   0;  
      -.98, .6624, .8740,    0, -.0184,   0;
      -.02, .1100, .3100,  .22,      0, -18;
      -.02, .1600, .4100, -.22,      0,  18;
       .01, .2100, .2500,    0,    .35,   0;
       .01, .0460, .0460,    0,     .1,   0;
       .02, .0460, .0460,    0,    -.1,   0;
       .01, .0460, .0230, -.08,  -.605,   0; 
       .01, .0230, .0230,    0,  -.606,   0;
       .01, .0230, .0460,  .06,  -.605,   0];
endfunction

function e = mod_shepp_logan
  #  Modified version of Shepp & Logan's head phantom, 
  #  adjusted to improve contrast.  Taken from Toft.
  e = [  1,   .69,   .92,    0,      0,   0;
      -.80, .6624, .8740,    0, -.0184,   0;
      -.20, .1100, .3100,  .22,      0, -18;
      -.20, .1600, .4100, -.22,      0,  18;
       .10, .2100, .2500,    0,    .35,   0;
       .10, .0460, .0460,    0,     .1,   0;
       .10, .0460, .0460,    0,    -.1,   0;
       .10, .0460, .0230, -.08,  -.605,   0; 
       .10, .0230, .0230,    0,  -.606,   0;
       .10, .0230, .0460,  .06,  -.605,   0];
endfunction

#function e = ??
#  # Add any further phantoms of interest here
#  e = [ 0, 0, 0, 0, 0, 0;
#        0, 0, 0, 0, 0, 0];
#endfunction

%!demo
%! P = phantom (512);
%! imshow (P, []);
