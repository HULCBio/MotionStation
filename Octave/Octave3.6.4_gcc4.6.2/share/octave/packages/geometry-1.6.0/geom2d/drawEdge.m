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
## @deftypefn {Function File} {@var{h} = } drawEdge (@var{x1}, @var{y1}, @var{x2}, @var{y2})
## @deftypefnx {Function File} {@var{h} = } drawEdge ([@var{x1} @var{y1} @var{x2} @var{y2}])
## @deftypefnx {Function File} {@var{h} = } drawEdge ([@var{x1} @var{y1}], [@var{x2} @var{y2}])
## @deftypefnx {Function File} {@var{h} = } drawEdge (@var{x1}, @var{y1}, @var{z1}, @var{x2}, @var{y2}, @var{z2})
## @deftypefnx {Function File} {@var{h} = } drawEdge ([@var{x1} @var{y1} @var{z1} @var{x2} @var{y2} @var{z2}])
## @deftypefnx {Function File} {@var{h} = } drawEdge ([@var{x1} @var{y1} @var{z1}], [@var{x2} @var{y2} @var{z2}])
## @deftypefnx {Function File} {@var{h} = } drawEdge (@dots{}, @var{opt})
## Draw an edge given by 2 points.
##
##   Draw an edge between the points (x1 y1) and  (x2 y2). Data can be bundled as an edge.
##   The function supports 3D edges.
##   Arguments can be single values or array of size [Nx1]. In this case,
##   the function draws multiple edges.
##   @var{opt}, being a set of pairwise options, can
##   specify color, line width and so on. These are passed to function @code{line}.
##   The function returns handle(s) to created edges(s).
##
##   @seealso{edges2d, drawCenteredEdge, drawLine, line}
## @end deftypefn

function varargout = drawEdge(varargin)

  # separate edge and optional arguments
  [edge options] = parseInputArguments(varargin{:});

  # draw the edges
  if size(edge, 2)==4
      h = drawEdge_2d(edge, options);
  else
      h = drawEdge_3d(edge, options);
  end

  # eventually return handle to created edges
  if nargout>0
      varargout{1}=h;
  end

endfunction

function h = drawEdge_2d(edge, options)

  h = -1*ones(size(edge, 1), 1);

  for i=1:size(edge, 1)
      if isnan(edge(i,1))
          continue;
      end
      h(i) = line(...
          [edge(i, 1) edge(i, 3)], ...
          [edge(i, 2) edge(i, 4)], options{:});
  end

endfunction

function h = drawEdge_3d(edge, options)

  h = -1*ones(size(edge, 1), 1);

  for i=1:size(edge, 1)
      if isnan(edge(i,1))
          continue;
      end
      h(i) = line( ...
          [edge(i, 1) edge(i, 4)], ...
          [edge(i, 2) edge(i, 5)], ...
          [edge(i, 3) edge(i, 6)], options{:});
  end

endfunction
    
function [edge options] = parseInputArguments(varargin)

  # default values for parameters
  edge = [];

  # find the number of arguments defining edges
  nbVal=0;
  for i=1:nargin
      if isnumeric(varargin{i})
          nbVal = nbVal+1;
      else
          # stop at the first non-numeric value
          break;
      end
  end

  # extract drawing options
  options = varargin(nbVal+1:end);

  # ensure drawing options have correct format
  if length(options)==1
      options = [{'color'}, options];
  end

  # extract edges characteristics
  if nbVal==1
      # all parameters in a single array
      edge = varargin{1};

  elseif nbVal==2
      # parameters are two points, or two arrays of points, of size N*2.
      p1 = varargin{1};
      p2 = varargin{2};
      edge = [p1 p2];
      
  elseif nbVal==4
      # parameters are 4 parameters of the edge : x1 y1 x2 and y2
      edge = [varargin{1} varargin{2} varargin{3} varargin{4}];
      
  elseif nbVal==6
      # parameters are 6 parameters of the edge : x1 y1 z1 x2 y2 and z2
      edge = [varargin{1} varargin{2} varargin{3} varargin{4} varargin{5} varargin{6}];
  end

endfunction

%!demo
%!  close
%!  points = rand(4,4);
%!  colorstr = 'rgbm';
%!  for i=1:4
%!    drawEdge (points(i,:),'color',colorstr(i),'linewidth',2);
%!  end
%!  axis tight;

%!demo
%!  close
%!  drawEdge (rand(10,4),'linewidth',2);
%!  axis tight;

