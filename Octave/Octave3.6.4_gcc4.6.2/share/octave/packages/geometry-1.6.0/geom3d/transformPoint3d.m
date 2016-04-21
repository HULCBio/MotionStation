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
## @deftypefn {Function File} {@var{pt2} =} transformPoint3d (@var{pt1}, @var{trans})
## @deftypefnx {Function File} {@var{pt2} =} transformPoint3d (@var{x1},@var{y1},@var{z1}, @var{trans})
## @deftypefnx {Function File} {[@var{x2},@var{y2},@var{z2}] =} transformPoint3d (@dots{})
## Transform a point with a 3D affine transform
##
##   PT2 = transformPoint3d(PT1, TRANS);
##   PT2 = transformPoint3d(X1, Y1, Z1, TRANS);
##   where PT1 has the form [xp yp zp], and TRANS is a [3x3], [3x4], [4x4]
##   matrix, return the point transformed according to the affine transform
##   specified by TRANS.
##
##   Format of TRANS is a 4-by-4 matrix.
##
##   The function accepts transforms given using the following formats:
##   [a b c]   ,   [a b c j] , or [a b c j]
##   [d e f]       [d e f k]      [d e f k]
##   [g h i]       [g h i l]      [g h i l]
##                                [0 0 0 1]
##
##   PT2 = transformPoint3d(PT1, TRANS)
##   also work when PT1 is a [Nx3xMxPxETC] array of double. In this case,
##   PT2 has the same size as PT1.
##
##   PT2 = transformPoint3d(X1, Y1, Z1, TRANS);
##   also work when X1, Y1 and Z1 are 3 arrays with the same size. In this
##   case, PT2 will be a 1-by-3 cell containing @{X Y Z@} outputs of size(X1).
##
##   [X2 Y2 Z2] = transformPoint3d(@dots{});
##   returns the result in 3 different arrays the same size as the input.
##   This form can be useful when used with functions like meshgrid or warp.
##
## @seealso{points3d, transforms3d, translation3d,meshgrid}
## @end deftypefn

function varargout = transformPoint3d(varargin)

  # process input arguments
  if length(varargin) == 2
      # Point coordinates are given in a single N-by-3-by-M-by-etc argument.
      # Preallocate x, y, and z to size N-by-1-by-M-by-etc, then fill them in
      dim = size(varargin{1});
      dim(2) = 1;
      [x,y,z] = deal(zeros(dim,class(varargin{1})));
      x(:) = varargin{1}(:,1,:);
      y(:) = varargin{1}(:,2,:);
      z(:) = varargin{1}(:,3,:);
      trans  = varargin{2};

  elseif length(varargin) == 4
      # Point coordinates are given in 3 different arrays
      x = varargin{1};
      y = varargin{2};
      z = varargin{3};
      dim = size(x);
      trans = varargin{4};
  end

  # eventually add null translation
  if size(trans, 2) == 3
      trans = [trans zeros(size(trans, 1), 1)];
  end

  # eventually add normalization
  if size(trans, 1) == 3
      trans = [trans;0 0 0 1];
  end

  # convert coordinates
  NP  = numel(x);
  try
      # vectorial processing, if there is enough memory
      #res = (trans*[x(:) y(:) z(:) ones(NP, 1)]')';
      #res = [x(:) y(:) z(:) ones(NP, 1)]*trans';
      res = [x(:) y(:) z(:) ones(NP,1,class(x))] * trans';

      # Back-fill x,y,z with new result (saves calling costly reshape())
      x(:) = res(:,1);
      y(:) = res(:,2);
      z(:) = res(:,3);
  catch ME
      disp(ME.message)
      # process each point one by one, writing in existing array
      for i = 1:NP
          res = [x(i) y(i) z(i) 1] * trans';
          x(i) = res(1);
          y(i) = res(2);
          z(i) = res(3);
      end
  end

  # process output arguments
  if nargout <= 1
      # results are stored in a unique array
      if length(dim) > 2 && dim(2) > 1
          warning('geom3d:shapeMismatch',...
              'Shape mismatch: Non-vector xyz input should have multiple x,y,z output arguments. Cell {x,y,z} returned instead.')
          varargout{1} = {x,y,z};
      else
          varargout{1} = [x y z];
      end

  elseif nargout == 3
      varargout{1} = x;
      varargout{2} = y;
      varargout{3} = z;
  end

endfunction
