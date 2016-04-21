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
## @deftypefn {Function File} {@var{h} =} drawPolyline3d (@var{poly})
## @deftypefnx {Function File} {@var{h} =} drawPolyline3d (@var{px},@var{py},@var{pz})
## @deftypefnx {Function File} {@var{h} =} drawPolyline3d (@dots{},@var{closed})
## @deftypefnx {Function File} {@var{h} =} drawPolyline3d (@dots{},@var{param},@var{value})
## Draw a 3D polyline specified by a list of vertices
##
##   drawPolyline3d(POLY);
##   packs coordinates in a single N-by-3 array.
##
##   drawPolyline3d(PX, PY, PZ);
##   specify coordinates in separate arrays.
##
##   drawPolyline3d(..., CLOSED);
##   Specifies if the polyline is closed or open. CLOSED can be one of:
##   - 'closed'
##   - 'open'    (the default)
##   - a boolean variable with value TRUE for closed polylines.
##
##   drawPolyline3d(..., PARAM, VALUE);
##   Specifies style options to draw the polyline, see plot for details.
##
##   H = drawPolyline3d(...);
##   also return a handle to the list of line objects.
##
## @seealso{polygons3d, drawPolygon3d, fillPolygon3d}
## @end deftypefn

function varargout = drawPolyline3d(varargin)

  ## Process input arguments

  # check case we want to draw several curves, stored in a cell array
  var = varargin{1};
  if iscell(var)
      hold on;
      h = [];
      for i = 1:length(var(:))
          h = [h; drawPolyline3d(var{i}, varargin{2:end})]; ##ok<AGROW>
      end
      if nargout > 0
          varargout = {h};
      end
      return;
  end

  # extract curve coordinates
  if size(var, 2) == 1
      # first argument contains x coord, second argument contains y coord
      # and third one the z coord
      px = var;
      if length(varargin) < 3
          error('Wrong number of arguments in drawPolyline3d');
      end
      py = varargin{2};
      pz = varargin{3};
      varargin = varargin(4:end);
      
  else
      # all coordinates are grouped in the first argument
      px = var(:, 1);
      py = var(:, 2);
      pz = var(:, 3);
      varargin = varargin(2:end);
  end

  # check if curve is closed or open (default is open)
  closed = false;
  if ~isempty(varargin)
      var = varargin{1};
      if islogical(var)
          # check boolean flag
          closed = var;
          varargin = varargin(2:end);
          
      elseif ischar(var)
          # check string indicating close or open
          if strncmpi(var, 'close', 5)
              closed = true;
              varargin = varargin(2:end);
              
          elseif strncmpi(var, 'open', 4)
              closed = false;
              varargin = varargin(2:end);
          end
          
      end
  end


  ## draw the curve

  # for closed curve, add the first point at the end to close curve
  if closed
      px = [px; px(1)];
      py = [py; py(1)];
      pz = [pz; pz(1)];
  end

  h = plot3(px, py, pz, varargin{:});

  if nargout > 0
      varargout = {h};
  end

endfunction
