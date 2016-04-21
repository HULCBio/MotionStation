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
## @deftypefn {Function File} {@var{h} =} drawEdge (@var{edge})
## Draw 3D edge in the current Window
##
##   draw the edge EDGE on the current axis. EDGE has the form:
##   [x1 y1 z1 x2 y2 z2].
##   No clipping is performed.
##
## @end deftypefn

function varargout = drawEdge3d(varargin)

  # extract edges from input arguments
  nCol = size(varargin{1}, 2);
  if nCol==6
      # all parameters in a single array
      edges = varargin{1};
      options = varargin(2:end);
  elseif nCol==3
      # parameters are two points, or two arrays of points, of size N*3.
      edges = [varargin{1} varargin{2}];
      options = varargin(3:end);
  elseif nCol==6
      # parameters are 6 parameters of the edge : x1 y1 z1 x2 y2 and z2
      edges = [varargin{1} varargin{2} varargin{3} varargin{4} varargin{5} varargin{6}];
      options = varargin(7:end);
  end

  # draw edges
  h = line(   [edges(:, 1) edges(:, 4)]', ...
              [edges(:, 2) edges(:, 5)]', ...
              [edges(:, 3) edges(:, 6)]', 'color', 'b');
      
  # apply optional drawing style
  if ~isempty(options)
      set(h, options{:});
  end

  # return handle to created Edges
  if nargout>0
      varargout{1}=h;
  end

endfunction
