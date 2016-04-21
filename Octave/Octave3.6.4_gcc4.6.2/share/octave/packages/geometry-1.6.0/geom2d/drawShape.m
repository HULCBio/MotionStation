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
## @deftypefn {Function File} drawShape (@var{type}, @var{param})
## @deftypefnx {Function File} drawShape (@dots{}, @var{option})
##  Draw various types of shapes (circles, polygons...).
##
##   drawShape(TYPE, PARAM)
##   Draw the shape of type TYPE, specified by given parameter PARAM. TYPE
##   can be one of 'circle', 'ellipse', 'rect', 'polygon', 'curve'
##   PARAM depend on the type. For example, if TYPE is 'circle', PARAM will
##   contain [x0 y0 R].
##
##   Examples :
##   @example
##   drawShape('circle', [20 10 30]);
##   Draw circle centered on [20 10] with radius 10.
##   drawShape('rect', [20 20 40 10 pi/3]);
##   Draw rectangle centered on [20 20] with length 40 and width 10, and
##   oriented pi/3 wrt axis Ox.
## @end example
##
##   drawShape(..., OPTION)
##   also specifies drawing options. OPTION can be 'draw' (default) or
##   'fill'.
## @end deftypefn
function varargout = drawShape(type, param, varargin)

  if ~iscell(type)
      type = {type};
  end
  if ~iscell(param)
      tmp = cell(1, size(param, 1));
      for i=1:size(param, 1)
          tmp{i} = param(i,:);
      end
      param = tmp;
  end

  option = 'draw';
  if ~isempty(varargin)
      var = varargin{1};
      if strcmpi(var, 'fill')
          option = 'fill';
      end
  end

      
  # transform each shape into a polygon
  shape = cell(1,length(type));
  for i=1:length(type)    
      if strcmpi(type{i}, 'circle')
          shape{i} = circleAsPolygon(param{i}, 128);
      elseif strcmpi(type{i}, 'rect')
          shape{i} = rectAsPolygon(param{i});
      elseif strcmpi(type{i}, 'polygon')
          shape{i} = param{i};        
      end
  end


  hold on;
  h = zeros(length(shape), 1);
  if strcmp(option, 'draw')
      for i=1:length(shape)
          h(i) = drawPolygon(shape{i});
      end
  else
      for i=1:length(shape)
          h(i) = fillPolygon(shape{i});
      end
  end

  if nargout>0
      varargout{1}=h;
  end

endfunction

