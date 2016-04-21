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
## @deftypefn {Function File} {@var{h} = } drawPolygon (@var{coord})
## @deftypefnx {Function File} {@var{h} = } drawPolygon (@var{px}, @var{py})
## @deftypefnx {Function File} {@var{h} = } drawPolygon (@var{polys})
## Draw a polygon specified by a list of points.
##
##   drawPolygon(COORD);
##   Packs coordinates in a single [N*2] array.
##
##   drawPolygon(PX, PY);
##   Specifies coordinates in separate arrays.
##
##   drawPolygon(POLYS)
##   Packs coordinate of several polygons in a cell array. Each element of
##   the array is a Ni*2 double array.
##
##   H = drawPolygon(...);
##   Also return a handle to the list of line objects.
##
##
##   @seealso{polygons2d, drawCurve}
## @end deftypefn

function varargout = drawPolygon(varargin)

  # check input
  if isempty(varargin)
      error('need to specify a polygon');
  end

  var = varargin{1};

  ## Manage cell arrays of polygons

  # case of a set of polygons stored in a cell array
  if iscell(var)
      N = length(var);
      h = zeros(N, 1);
      for i = 1:N
          state = ishold(gca);
          hold on;
          # check for empty polygons
          if ~isempty(var{i})
              h(i) = drawPolygon(var{i}, varargin{2:end});
          end
          if ~state
              hold off
          end
      end

      if nargout > 0
          varargout = {h};
      end

      return;
  end


  ## Parse coordinates and options

  # Extract coordinates of polygon vertices
  if size(var, 2) > 1
      # first argument is a polygon array
      px = var(:, 1);
      py = var(:, 2);
      varargin(1) = [];
  else
      # arguments 1 and 2 correspond to x and y coordinate respectively
      if length(varargin) < 2
          error('Should specify either a N-by-2 array, or 2 N-by-1 vectors');
      end
      
      px = varargin{1};
      py = varargin{2};
      varargin(1:2) = [];
  end    

  # set default line format
  if isempty(varargin)
      varargin = {'b-'};
  end

  # check case of polygons with holes
  if sum(isnan(px(:))) > 0
      polygons = splitPolygons([px py]);
      h = drawPolygon(polygons);

      if nargout > 0
          varargout = {h};
      end

      return;
  end


  ## Draw the polygon

  # ensure last point is the same as the first one
  px(size(px, 1)+1, :) = px(1,:);
  py(size(py, 1)+1, :) = py(1,:);

  # draw the polygon outline
  h = plot(px, py, varargin{:});

  # format output arg
  if nargout > 0
      varargout = {h};
  end

endfunction

