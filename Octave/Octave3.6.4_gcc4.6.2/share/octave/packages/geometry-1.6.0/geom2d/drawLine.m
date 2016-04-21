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
## @deftypefn {Function File} {@var{h} =} drawLine (@var{line})
## @deftypefnx {Function File} {@var{h} =} drawLine (@var{line}, @var{param},@var{value})
## Draw the line on the current axis.
##
##   Draws the line LINE on the current axis, by using current axis to clip
##   the line. Extra @var{param},@var{value} pairs are passed to the @code{line} function.
##   Returns a handle to the created line object. If clipped line is not
##   contained in the axis, the function returns -1.
##
## Example
##
## @example
##   figure; hold on; axis equal;
##   axis([0 100 0 100]);
##   drawLine([30 40 10 20]);
##   drawLine([30 40 20 -10], 'color', 'm', 'linewidth', 2);
## @end example
##
## @seealso{lines2d, createLine, drawEdge}
## @end deftypefn

function varargout = drawLine(lin, varargin)

  # default style for drawing lines
  varargin = [{'color', 'b'}, varargin];

  # extract bounding box of the current axis
  xlim = get(gca, 'xlim');
  ylim = get(gca, 'ylim');

  # clip lines with current axis box
  clip = clipLine(lin, [xlim ylim]);
  ok   = isfinite(clip(:,1));

  # initialize result array to invalide handles
  h = -1*ones(size(lin, 1), 1);

  # draw valid lines
  h(ok) = line(clip(ok, [1 3])', clip(ok, [2 4])', varargin{:});

  # return line handle if needed
  if nargout>0
      varargout{1}=h;
  end

endfunction

%!demo
%!   figure; hold on; axis equal;
%!   axis([0 100 0 100]);
%!   drawLine([30 40 10 20]);
%!   drawLine([30 40 20 -10], 'color', 'm', 'linewidth', 2);

%!shared privpath
%! privpath = [fileparts(which('geom2d_Contents')) filesep() 'private'];

%!test
%!  addpath (privpath,'-end')
%!  box = [0 100 0 100];
%!  hf = figure('visible','off');
%!  axis(box);
%!  line = [30 40 10 0];
%!  edge = [0 40 100 40];
%!  hl = drawLine(line);
%!  assertElementsAlmostEqual(edge([1 3]), get(hl, 'xdata'));
%!  assertElementsAlmostEqual(edge([2 4]), get(hl, 'ydata'));
%!  rmpath (privpath);

%!test
%!  addpath (privpath,'-end')
%!  box = [0 100 0 100];
%!  hf = figure('visible','off');
%!  axis(box);
%!  line = [30 40 -10 0];
%!  edge = [100 40 0 40];
%!  hl = drawLine(line);
%!  assertElementsAlmostEqual(edge([1 3]), get(hl, 'xdata'));
%!  assertElementsAlmostEqual(edge([2 4]), get(hl, 'ydata'));
%!  rmpath (privpath);

%!test
%!  addpath (privpath,'-end')
%!  box = [0 100 0 100];
%!  hf = figure('visible','off');
%!  axis(box);
%!  line = [30 140 10 0];
%!  hl = drawLine(line);
%!  assertEqual(-1, hl);
%!  rmpath (privpath);

%!test
%!  addpath (privpath,'-end')
%!  box = [0 100 0 100];
%!  hf = figure('visible','off');
%!  axis(box);
%!  line = [30 40 0 10];
%!  edge = [30 0 30 100];
%!  hl = drawLine(line);
%!  assertElementsAlmostEqual(edge([1 3]), get(hl, 'xdata'));
%!  assertElementsAlmostEqual(edge([2 4]), get(hl, 'ydata'));
%!  rmpath (privpath);

%!test
%!  addpath (privpath,'-end')
%!  box = [0 100 0 100];
%!  hf = figure('visible','off');
%!  axis(box);
%!  line = [30 40 0 -10];
%!  edge = [30 100 30 0];
%!  hl = drawLine(line);
%!  assertElementsAlmostEqual(edge([1 3]), get(hl, 'xdata'));
%!  assertElementsAlmostEqual(edge([2 4]), get(hl, 'ydata'));
%!  rmpath (privpath);

%!test
%!  addpath (privpath,'-end')
%!  box = [0 100 0 100];
%!  hf = figure('visible','off');
%!  axis(box);
%!  line = [140 30 0 10];
%!  hl = drawLine(line);
%!  assertEqual(-1, hl);
%!  rmpath (privpath);

%!test
%!  addpath (privpath,'-end')
%!  box = [0 100 0 100];
%!  hf = figure('visible','off');
%!  axis(box);
%!  line = [80 30 10 10];
%!  edge = [50 0 100 50];
%!  hl = drawLine(line);
%!  assertElementsAlmostEqual(edge([1 3]), get(hl, 'xdata'));
%!  assertElementsAlmostEqual(edge([2 4]), get(hl, 'ydata'));
%!  rmpath (privpath);

%!test
%!  addpath (privpath,'-end')
%!  box = [0 100 0 100];
%!  hf = figure('visible','off');
%!  axis(box);
%!  line = [20 70 10 10];
%!  edge = [0 50 50 100];
%!  hl = drawLine(line);
%!  assertElementsAlmostEqual(edge([1 3]), get(hl, 'xdata'));
%!  assertElementsAlmostEqual(edge([2 4]), get(hl, 'ydata'));
%!  rmpath (privpath);

%!test
%!  addpath (privpath,'-end')
%!  box = [0 100 0 100];
%!  hf = figure('visible','off');
%!  axis(box);
%!  line = [140 -30 10 10];
%!  hl = drawLine(line);
%!  assertEqual(-1, hl);
%!  line = [-40 130 10 10];
%!  hl = drawLine(line);
%!  assertEqual(-1, hl);
%!  rmpath (privpath);

%!test
%!  addpath (privpath,'-end')
%!  box = [0 100 0 100];
%!  hf = figure('visible','off');
%!  axis(box);
%!  line = [...
%!      80 30 10 10; ...
%!      20 70 10 10; ...
%!      140 -30 10 10; ...
%!      -40 130 10 10];
%!  edge = [...
%!      50 0 100 50; ...
%!      0 50 50 100];
%!  hl = drawLine(line);
%!  assertEqual(4, length(hl));
%!  assertElementsAlmostEqual(edge(1, [1 3]), get(hl(1), 'xdata'));
%!  assertElementsAlmostEqual(edge(1, [2 4]), get(hl(1), 'ydata'));
%!  assertElementsAlmostEqual(edge(2, [1 3]), get(hl(2), 'xdata'));
%!  assertElementsAlmostEqual(edge(2, [2 4]), get(hl(2), 'ydata'));
%!  assertEqual(-1, hl(3));
%!  assertEqual(-1, hl(4));
%!  rmpath (privpath);

