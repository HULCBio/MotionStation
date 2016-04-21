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
## @deftypefn {Function File} {@var{h} = } suppportFunction (@var{polygon})
## @deftypefnx {Function File} {@var{h} = } suppportFunction (@var{polygon}, @var{n})
## @deftypefnx {Function File} {@var{h} = } suppportFunction (@var{polygon}, @var{v})
## Compute support function of a polygon
##
##   H = supportFunction(POLYGON, N)
##   uses N points for suport function approximation
##
##   H = supportFunction(POLYGON)
##   assume 24 points for approximation
##
##   H = supportFunction(POLYGON, V)
##   where V is a vector, uses vector V of angles to compute support
##   function.
##
## @seealso{convexification}
## @end deftypefn

function h = supportFunction(polygon, varargin)
  N = 24;
  u = (0:2*pi/N:2*pi*(1-1/N)).';

  if length(varargin)==1
      var = varargin{1};
      if length(var)==1
          N = var;
          u = (0:2*pi/N:2*pi*(1-1/N)).';
      else
          u = var(:);
      end
  end


  h = zeros(size(u));

  for i=1:length(u)

      v = repmat([cos(u(i)) sin(u(i))], [size(polygon, 1), 1]);

      h(i) = max(dot(polygon, v, 2));
  end

endfunction
