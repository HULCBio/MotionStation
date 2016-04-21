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
## @deftypefn {Function File} {@var{pt2} = } transformPoint (@var{pt1}, @var{Trans})
## @deftypefnx {Function File} {[@var{px2} @var{py2}]= } transformPoint (@var{px1}, @var{py1}, @var{Trans})
## Transform a point with an affine transform.
##
##   where @var{pt1} has the form [xp yp], and @var{Trans} is a [2x2], [2x3] or [3x3]
##   matrix, returns the point transformed with affine transform @var{Trans}.
##
##   Format of @var{Trans} can be one of :
##   [a b]   ,   [a b c] , or [a b c]
##   [d e]       [d e f]      [d e f]
##                            [0 0 1]
##
##   Also works when @var{pt1} is a [Nx2] array of double. In this case, @var{pt2} has
##   the same size as @var{pt1}.
##
##   Also works when @var{px1} and @var{py1} are arrays the same size. The function
##   transform each couple of (@var{px1}, @var{py1}), and return the result in 
##   (@var{px2}, @var{py2}), which is the same size as (@var{px1} @var{py1}).
##
##   @seealso{points2d, transforms2d, createTranslation, createRotation}
## @end deftypefn

function varargout = transformPoint(varargin)

  if length(varargin)==2
      var = varargin{1};
      px = var(:,1);
      py = var(:,2);
      trans = varargin{2};
  elseif length(varargin)==3
      px = varargin{1};
      py = varargin{2};
      trans = varargin{3};
  else
      error('wrong number of arguments in "transformPoint"');
  end


  # compute position
  px2 = px*trans(1,1) + py*trans(1,2);
  py2 = px*trans(2,1) + py*trans(2,2);

  # add translation vector, if exist
  if size(trans, 2)>2
      px2 = px2 + trans(1,3);
      py2 = py2 + trans(2,3);
  end


  if nargout==0 || nargout==1
      varargout{1} = [px2 py2];
  elseif nargout==2
      varargout{1} = px2;
      varargout{2} = py2;
  end

endfunction

