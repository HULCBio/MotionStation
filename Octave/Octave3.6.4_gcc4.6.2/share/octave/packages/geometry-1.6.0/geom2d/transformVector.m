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
## @deftypefn {Function File} {@var{v2} = } transformVector (@var{v}, @var{T})
## @deftypefnx {Function File} {[@var{x2} @var{y2}] = } transformVector (@var{x},@var{y}, @var{T})
## Transform a vector with an affine transform
##
##   @var{v} has the form [xv yv], and @var{T} is a [2x2], [2x3] or [3x3]
##   matrix, returns the vector transformed with affine transform @var{T}.
##
##   Format of @var{T} can be one of :
## @group
##   [a b]   ,   [a b c] , or [a b c]
##   [d e]       [d e f]      [d e f]
##                            [0 0 1]
## @end group
##
##   Also works when @var{v} is a [Nx2] array of double. In this case, @var{v2} has
##   the same size as @var{v}.
##
##   Also works when @var{x} and @var{y} are arrays the same size. The function
##   transform each couple of (@var{x}, @var{y}), and return the result in 
##   (@var{x2}, @var{y2}), which is the same size as (@var{x}, @var{y}).
##
##   @seealso{vectors2d, transforms2d, rotateVector, transformPoint}
## @end deftypefn

function varargout = transformVector(varargin)

  if length(varargin)==2
      var = varargin{1};
      vx = var(:,1);
      vy = var(:,2);
      trans = varargin{2};
  elseif length(varargin)==3
      vx = varargin{1};
      vy = varargin{2};
      trans = varargin{3};
  else
      error('wrong number of arguments in "transformVector"');
  end


  # compute new position of vector
  vx2 = vx*trans(1,1) + vy*trans(1,2);
  vy2 = vx*trans(2,1) + vy*trans(2,2);

  if size(trans, 2) == 3
    vx2 = vx2 + trans(1,3);
    vy2 = vy2 + trans(2,3);
  end
  
  # format output
  if nargout==0 || nargout==1
      varargout{1} = [vx2 vy2];
  elseif nargout==2
      varargout{1} = vx2;
      varargout{2} = vy2;
  end

endfunction

%!demo
%! t1 = [2 0 0; 0 2 0];
%! t2 = [1 0 1; 0 1 1];
%! t3 = [0.5 0 1; 0 0.5 1; 0 0 1];
%!
%! triangle = [-0.5 -1/3; 0.5 -1/3; 0 2/3; -0.5 -1/3];
%! tr1 = transformVector(triangle,t1);
%! tr2 = transformVector(triangle,t2);
%! tr3 = transformVector(triangle,t3);
%!
%! plot(triangle(:,1),triangle(:,2),'k-', ...
%!      tr1(:,1),tr1(:,2),'g-;scaled up;', ...
%!      tr2(:,1),tr2(:,2),'m-;translated;', ...
%!      tr3(:,1),tr3(:,2),'b-;scaled down and translated;')

