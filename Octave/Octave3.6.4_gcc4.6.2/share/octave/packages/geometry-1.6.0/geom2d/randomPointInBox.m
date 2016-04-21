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
## @deftypefn {Function File} {@var{points} =} randomPointInBox (@var{box})
## @deftypefnx {Function File} {@var{points} =} randomPointInBox (@var{box}, @var{n})
## Generate random points within a box.
## 
##   Generate a random point within the box @var{box}. The result is a 1-by-2 row
## vector. If @var{n} is given, generates @var{n} points. The result is a
## @var{n}-by-2 array.
##
##   Example
##
## @example
##     # draw points within a box
##     box = [10 80 20 60];
##     pts =  randomPointInBox(box, 500);
##     figure(1); clf; hold on;
##     drawBox(box);
##     drawPoint(pts, '.');
##     axis('equal');
##     axis([0 100 0 100]);
## @end example
##
## @seealso{edges2d, boxes2d, clipLine}
## @end deftypefn

function points = randomPointInBox(box, N=1, varargin)

  # extract box bounds
  xmin = box(1);
  xmax = box(2);
  ymin = box(3);
  ymax = box(4);

  # compute size of box
  dx = xmax - xmin;
  dy = ymax - ymin;

  # compute point coordinates
  points = [rand(N, 1)*dx+xmin , rand(N, 1)*dy+ymin];

endfunction

%!demo
%!     # draw points within a box
%!     bb = [10 80 20 60];
%!     pts =  randomPointInBox(bb, 500);
%!     figure(1); clf; hold on;
%!     drawBox(bb);
%!     drawPoint(pts, '.');
%!     axis equal
%!     axis([0 100 0 100]);

