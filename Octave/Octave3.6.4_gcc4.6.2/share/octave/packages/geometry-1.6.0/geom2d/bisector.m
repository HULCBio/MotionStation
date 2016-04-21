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
## @deftypefn {Function File} {@var{ray} = } bisector (@var{line1}, @var{line2})
## @deftypefnx {Function File} {@var{ray} = } bisector (@var{p1}, @var{p2}, @var{p3})
## Return the bisector of two lines, or 3 points.
##
##   Creates the bisector of the two lines, given as [x0 y0 dx dy].
##
##   create the bisector of lines (@var{p2} @var{p1}) and (@var{p2} @var{p3}).
##
##   The result has the form [x0 y0 dx dy], with [x0 y0] being the origin
##   point ans [dx dy] being the direction vector, normalized to have unit
##   norm.
##
##   @seealso{lines2d, rays2d}
## @end deftypefn

function ray = bisector(varargin)

  if length(varargin)==2
      # two lines
      line1 = varargin{1};
      line2 = varargin{2};

      point = intersectLines(line1, line2);

  elseif length(varargin)==3
      # three points
      p1 = varargin{1};
      p2 = varargin{2};
      p3 = varargin{3};

      line1 = createLine(p2, p1);
      line2 = createLine(p2, p3);
      point = p2;

  elseif length(varargin)==1
      # three points, given in one array
      var = varargin{1};
      p1 = var(1, :);
      p2 = var(2, :);
      p3 = var(3, :);

      line1 = createLine(p2, p1);
      line2 = createLine(p2, p3);
      point = p2;
  end

  # compute line angles
  a1 = lineAngle(line1);
  a2 = lineAngle(line2);

  # compute bisector angle (angle of first line + half angle between lines)
  angle = mod(a1 + mod(a2-a1+2*pi, 2*pi)/2, pi*2);

  # create the resulting ray
  ray = [point cos(angle) sin(angle)];

endfunction

%!shared privpath
%! privpath = [fileparts(which('geom2d_Contents')) filesep() 'private'];

%!test
%!  addpath (privpath,'-end')
%!  p0 = [0 0];
%!  p1 = [10 0];
%!  p2 = [0 10];
%!  line1 = createLine(p0, p1);
%!  line2 = createLine(p0, p2);
%!  ray = bisector(line1, line2);
%!  assertElementsAlmostEqual([0 0], ray(1,1:2));
%!  assertAlmostEqual(pi/4, lineAngle(ray));
%!  rmpath (privpath);

%!test
%!  addpath (privpath,'-end')
%!  p0 = [0 0];
%!  p1 = [10 0];
%!  p2 = [0 10];
%!  ray = bisector(p1, p0, p2);
%!  assertElementsAlmostEqual([0 0], ray(1,1:2));
%!  assertAlmostEqual(pi/4, lineAngle(ray));
%!  rmpath (privpath);

%!test
%!  addpath (privpath,'-end')
%!  p0 = [0 0];
%!  p1 = [10 0];
%!  p2 = [0 10];
%!  ray = bisector([p1; p0; p2]);
%!  assertElementsAlmostEqual([0 0], ray(1,1:2));
%!  assertAlmostEqual(pi/4, lineAngle(ray));
%!  rmpath (privpath);
