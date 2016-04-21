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
## @deftypefn {Function File} {@var{pos} =} linePosition (@var{point}, @var{line})
## Position of a point on a line.
## 
##   Computes position of point @var{point} on the line @var{line}, relative to origin
##   point and direction vector of the line.
##   @var{line} has the form [x0 y0 dx dy],
##   @var{point} has the form [x y], and is assumed to belong to line.
##
##   If @var{line} is an array of NL lines, return NL positions, corresponding to
##   each line.
##
##   If @var{point} is an array of NP points, return NP positions, corresponding
##   to each point.
##
##   If @var{point} is an array of NP points and @var{line}S is an array of NL lines,
##   return an array of [NP NL] position, corresponding to each couple
##   point-line.
##
## Example
##
## @example
##   line = createLine([10 30], [30 90]);
##   linePosition([20 60], line)
##   ans =
##       .5
## @end example
##
## @seealso{lines2d, createLine, projPointOnLine, isPointOnLine}
## @end deftypefn

function d = linePosition(point, lin)

  # number of inputs
  Nl = size(lin, 1);
  Np = size(point, 1);

  if Np == Nl
      # if both inputs have the same size, no problem
      dxl = lin(:, 3);
      dyl = lin(:, 4);
      dxp = point(:, 1) - lin(:, 1);
      dyp = point(:, 2) - lin(:, 2);

  elseif Np == 1
      # one point, several lines
      dxl = lin(:, 3);
      dyl = lin(:, 4);
      dxp = point(ones(Nl, 1), 1) - lin(:, 1);
      dyp = point(ones(Nl, 1), 2) - lin(:, 2);
      
  elseif Nl == 1
      # one lin, several points
      dxl = lin(ones(Np, 1), 3);
      dyl = lin(ones(Np, 1), 4);
      dxp = point(:, 1) - lin(1);
      dyp = point(:, 2) - lin(2);
      
  else
      # expand one of the array to have the same size
      dxl = repmat(lin(:,3)', Np, 1);
      dyl = repmat(lin(:,4)', Np, 1);
      dxp = repmat(point(:,1), 1, Nl) - repmat(lin(:,1)', Np, 1);
      dyp = repmat(point(:,2), 1, Nl) - repmat(lin(:,2)', Np, 1);
  end

  # compute position
  d = (dxp.*dxl + dyp.*dyl) ./ (dxl.^2 + dyl.^2);

endfunction

%!demo
%!  point = [20 60;10 30;25 75];
%!  lin = createLine([10 30], [30 90]);
%!  pos = linePosition(point, lin)
%!  
%!  plot(point(:,1),point(:,2),'ok');
%!  hold on
%!  drawLine(lin,'color','r');
%!  plot(lin(1)+lin(3)*pos,lin(2)+lin(4)*pos,'xb')
%!  hold off

%!test
%!  point = [20 60];
%!  lin = createLine([10 30], [30 90]);
%!  res = .5;
%!  pos = linePosition(point, lin);
%!  assert (res, pos);

%!test
%!  point = [20 60;10 30;25 75];
%!  lin = createLine([10 30], [30 90]);
%!  res = [.5; 0; .75];
%!  pos = linePosition(point, lin);
%!  assert (res, pos);

%!test
%!  point = [20 60];
%!  lin1 = createLine([10 30], [30 90]);
%!  lin2 = createLine([0 0], [20 60]);
%!  lin3 = createLine([20 60], [40 120]);
%!  lines = [lin1;lin2;lin3];
%!  res = [.5; 1; 0];
%!  pos = linePosition(point, lines);
%!  assert (res, pos);

