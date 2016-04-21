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
## @deftypefn {Function File} {@var{h} = } drawArrow (@var{x1}, @var{y1}, @var{x2}, @var{y2})
## @deftypefnx {Function File} {@var{h} = } drawArrow ([@var{ @var{x1}} @var{ @var{y1}} @var{x2} @var{y2}])
## @deftypefnx {Function File} {@var{h} = } drawArrow (@dots{}, @var{L}, @var{W})
## @deftypefnx {Function File} {@var{h} = } drawArrow (@dots{}, @var{L}, @var{W},@var{TYPE})
## Draw an arrow on the current axis.
##
##   draw an arrow between the points (@var{x1} @var{y1}) and (@var{x2} @var{y2}).
## The points can be given as a single array. @var{L}, @var{W} specify length
## and width of the arrow.
##
##   Also specify arrow type. @var{TYPE} can be one of the following :
##   0: draw only two strokes
##   1: fill a triangle
##   .5: draw a half arrow (try it to see ...)
##
##   Arguments can be single values or array of size [N*1]. In this case,
##   the function draws multiple arrows.
##
## @end deftypefn

function varargout = drawArrow(varargin)

  if isempty(varargin)
      error('should specify at least one argument');
  end

  # parse arrow coordinate
  if size(varargin{1}, 2)==4
      x1 = varargin{1}(:,1);
      y1 = varargin{1}(:,2);
      x2 = varargin{1}(:,3);
      y2 = varargin{1}(:,4);
      varargin = varargin(2:end);
  elseif length(varargin)>3
      x1 = varargin{1};
      y1 = varargin{2};
      x2 = varargin{3};
      y2 = varargin{4};
      varargin = varargin(5:end);
  else
      error('wrong number of arguments, please read the doc');
  end

  l = 10*size(size(x1));
  w = 5*ones(size(x1));
  h = zeros(size(x1));

  # exctract length of arrow
  if ~isempty(varargin)
      l = varargin{1};
      if length(x1)>length(l)
          l = l(1)*ones(size(x1));
      end
  end

  # extract width of arrow
  if length(varargin)>1
      w = varargin{2};
      if length(x1)>length(w)
          w = w(1)*ones(size(x1));
      end
  end

  # extract 'ratio' of arrow
  if length(varargin)>2
      h = varargin{3};
      if length(x1)>length(h)
          h = h(1)*ones(size(x1));
      end
  end

  hold on;
  axis equal;

  # angle of the edge
  theta = atan2(y2-y1, x2-x1);

  # point on the 'left'
  xa1 = x2 - l.*cos(theta) - w.*sin(theta)/2;
  ya1 = y2 - l.*sin(theta) + w.*cos(theta)/2;
  # point on the 'right'
  xa2 = x2 - l.*cos(theta) + w.*sin(theta)/2;
  ya2 = y2 - l.*sin(theta) - w.*cos(theta)/2;
  # point on the middle of the arrow
  xa3 = x2 - l.*cos(theta).*h;
  ya3 = y2 - l.*sin(theta).*h;

  # draw main edge
  tmp = line([x1'; x2'], [y1'; y2'], 'color', [0 0 1]);
  handle.body = tmp;

  # draw only 2 wings
  ind = find(h==0);
  if !isempty (ind)
    tmp = line([xa1(ind)'; x2(ind)'], [ya1(ind)'; y2(ind)'], 'color', [0 0 1]);
    handle.wing(:,1) = tmp;

    tmp = line([xa2(ind)'; x2(ind)'], [ya2(ind)'; y2(ind)'], 'color', [0 0 1]);
    handle.wing(:,2) = tmp;
  end


  # draw a full arrow
  ind = find(h~=0);
  if !isempty (ind)
    tmp = patch([x2(ind) xa1(ind) xa3(ind) xa2(ind) x2(ind)]', ...
        [y2(ind) ya1(ind) ya3(ind) ya2(ind) y2(ind)]', [0 0 1]);
    handle.head = tmp;
  end

  if nargout>0
      varargout{1} = handle;
  end

endfunction

%!demo
%! # Orthogonal projection respect to vector b
%! dim = 2;
%! b   = 2*rand(dim,1);
%! P   = eye(dim) - (b*b')/(b'*b);
%! v   = 2*rand(dim,1)-1;
%! Pv  = P*v;
%!
%! # Draw the vectors
%! clf;
%! h = drawArrow ([zeros(3,dim) [b'; v'; Pv']],0.1,0.1);
%!
%! # Color them
%! arrayfun(@(x,y)set(x,'color',y), [h.body; h.wing(:)],repmat(['rgb']',3,1));
%! # Name them
%! legend (h.body, {'b','v','Pv'},'location','northoutside','orientation','horizontal');

