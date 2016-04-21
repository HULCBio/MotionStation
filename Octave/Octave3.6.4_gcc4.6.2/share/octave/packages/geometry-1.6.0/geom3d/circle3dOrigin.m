## Copyright (C) 2004-2011 David Legland <david.legland@grignon.inra.fr>
## Copyright (C) 2004-2011 INRA - CEPIA Nantes - MIAJ (Jouy-en-Josas)
## Copyright (C) 2012 Adapted to Octave by Juan Pablo Carbajal <carbajal@ifi.uzh.ch>
## All rights reserved.
##
## Redistribution and use in source and binary forms, with or without
## modification, are permitted provided that the following conditions are met:
##
##     1 Redistributions of source code must retain the above copyright notice,
##       this list of conditions and the following disclaimer.
##     2 Redistributions in binary form must reproduce the above copyright
##       notice, this list of conditions and the following disclaimer in the
##       documentation and/or other materials provided with the distribution.
##
## THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS ''AS IS''
## AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
## IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
## ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE FOR
## ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
## DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
## SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
## CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
## OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
## OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

## -*- texinfo -*-
## @deftypefn {Function File} {@var{p} =} circle3dOrigin([@var{xc} @var{yc} @var{zc} @var{r} @var{theta} @var{phi}])
## @deftypefnx {Function File} {@var{p} =} circle3dOrigin([@var{xc} @var{yc} @var{zc} @var{r} @var{theta} @var{phi} @var{psi}])
## Return the first point of a 3D circle
##
##   Returns the origin point of the circle, i.e. the first point used for
##   drawing circle.
##
## @seealso{circles3d, points3d, circle3dPosition}
## @end deftypefn

function ori = circle3dOrigin(varargin)

  # get center and radius
  circle = varargin{1};
  xc = circle(:,1);
  yc = circle(:,2);
  zc = circle(:,3);
  r  = circle(:,4);

  # get angle of normal
  theta   = circle(:,5);
  phi     = circle(:,6);

  # get roll
  if size(circle, 2)==7
      psi = circle(:,7);
  else
      psi = zeros(size(circle, 1), 1);
  end

  # create origin point
  pt0 = [r 0 0];

  # compute transformation from local basis to world basis
  trans   = localToGlobal3d(xc, yc, zc, theta, phi, psi);

  # transform the point
  ori = transformPoint3d(pt0, trans);

endfunction
