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
## @deftypefn {Function File} {@var{h} = } drawPoint (@var{x}, @var{y})
## @deftypefnx {Function File} {@var{h} = } drawPoint (@var{coord})
## @deftypefnx {Function File} {@var{h} = } drawPoint (@dots{}, @var{opt})
## Draw the point on the axis.
#
#   Draws points defined by coordinates @var{x} and @var{y}Y.
#   @var{x} and @var{y} should be array the same size. Coordinates can be 
#   packed coordinates in a single [N*2] array @var{coord}. Options @var{opt}
#   are passed to the @code{plot} function.
#
#   @seealso{points2d, clipPoints}
#
## @end deftypefn

function varargout = drawPoint(varargin)

  # process input arguments
  var = varargin{1};
  if size(var, 2)==1
      # points stored in separate arrays
      px = varargin{1};
      py = varargin{2};
      varargin(1:2) = [];
  else
      # points packed in one array
      px = var(:, 1);
      py = var(:, 2);
      varargin(1) = [];
  end

  # ensure we have column vectors
  px = px(:);
  py = py(:);

  # default drawing options, but keep specified options if it has the form of
  # a bundled string
  if length(varargin)~=1
      varargin = [{'linestyle', 'none', 'marker', 'o', 'color', 'b'}, varargin];
  end

  # plot the points, using specified drawing options
  h = plot(px(:), py(:), varargin{:});

  # process output arguments
  if nargout>0
      varargout{1}=h;
  end

endfunction

%!demo
%!   drawPoint(10, 10);

%!demo
%!   t = linspace(0, 2*pi, 20)';
%!   drawPoint([5*cos(t)+10 3*sin(t)+10], 'r+');

