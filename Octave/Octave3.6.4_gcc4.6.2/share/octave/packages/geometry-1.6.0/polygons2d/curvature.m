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
## @deftypefn {Function File} {@var{kappa} = } curvature (@var{t}, @var{px}, @var{py},@var{method},@var{degree})
## @deftypefnx {Function File} {@var{kappa} = } curvature (@var{t}, @var{poly},@var{method},@var{degree})
## @deftypefnx {Function File} {@var{kappa} = } curvature (@var{px}, @var{py},@var{method},@var{degree})
## @deftypefnx {Function File} {@var{kappa} = } curvature (@var{points},@var{method},@var{degree})
## @deftypefnx {Function File} {[@var{kappa} @var{poly} @var{t}] = } curvature (@dots{})
## Estimate curvature of a polyline defined by points.
##
## First compute an approximation of the curve given by PX and PY, with
## the parametrization @var{t}. Then compute the curvature of approximated curve
## for each point.
## @var{method} used for approximation can be only: 'polynom', with specified degree.
## Further methods will be provided in a future version.
## @var{t}, @var{px}, and @var{py} are N-by-1 array of the same length. The points
## can be specified as a single N-by-2 array.
##
## If the argument @var{t} is not given, the parametrization is estimated using
## function @code{parametrize}.
##
## If requested, @var{poly} contains the approximating polygon evlauted at the
## parametrization @var{t}.
##
## @seealso{parametrize, polygons2d}
## @end deftypefn

function [kappa, varargout] = curvature(varargin)

  # default values
  degree = 5;
  t=0;                    # parametrization of curve
  tc=0;                   # indices of points wished for curvature


  # =================================================================

  # Extract method and degree ------------------------------

  nargin = length(varargin);
  varN = varargin{nargin};
  varN2 = varargin{nargin-1};

  if ischar(varN2)
      # method and degree are specified
      method = varN2;
      degree = varN;
      varargin = varargin(1:nargin-2);
  elseif ischar(varN)
      # only method is specified, use degree 6 as default
      method = varN;
      varargin = varargin{1:nargin-1};
  else
      # method and degree are implicit : use 'polynom' and 6
      method = 'polynom';
  end

  # extract input parametrization and curve. -----------------------
  nargin = length(varargin);
  if nargin==1
      # parameters are just the points -> compute caracterization.
      var = varargin{1};
      px = var(:,1);
      py = var(:,2);
  elseif nargin==2
      var = varargin{2};
      if size(var, 2)==2
          # parameters are t and POINTS
          px = var(:,1);
          py = var(:,2);
          t = varargin{1};
      else
          # parameters are px and py
          px = varargin{1};
          py = var;
      end
  elseif nargin==3
      var = varargin{2};
      if size(var, 2)==2
          # parameters are t, POINTS, and tc
          px = var(:,1);
          py = var(:,2);
          t = varargin{1};
      else
          # parameters are t, px and py
          t = varargin{1};
          px = var;
          py = varargin{3};
      end
  elseif nargin==4
      # parameters are t, px, py and tc
      t  = varargin{1};
      px = varargin{2};
      py = varargin{3};
      tc = varargin{4};
  end

  # compute implicit parameters --------------------------

  # if t and/or tc are not computed, use implicit definition
  if t==0
      t = parametrize(px, py, 'norm');
  end

  # if tc not defined, compute curvature for all points
  if tc==0
      tc = t;
  else
      # else convert from indices to parametrization values
      tc = t(tc);
  end


  # =================================================================
  #    compute curvature for each point of the curve

  if strcmp(method, 'polynom')
      # compute coefficients of interpolation functions
      x0 = polyfit(t, px, degree);
      y0 = polyfit(t, py, degree);

      # compute coefficients of first and second derivatives. In the case of a
      # polynom, it is possible to compute coefficient of derivative by
      # multiplying with a matrix.
      derive = diag(degree:-1:0);
      xp = circshift(x0*derive, [0 1]);
      yp = circshift(y0*derive, [0 1]);
      xs = circshift(xp*derive, [0 1]);
      ys = circshift(yp*derive, [0 1]);

      # compute values of first and second derivatives for needed points
      xprime = polyval(xp, tc);
      yprime = polyval(yp, tc);
      xsec = polyval(xs, tc);
      ysec = polyval(ys, tc);

      # compute value of curvature
      kappa = (xprime.*ysec - xsec.*yprime)./ ...
          power(xprime.*xprime + yprime.*yprime, 3/2);

      if nargout > 1
        varargout{1} = [polyval(x0,tc(:)) polyval(y0,tc(:))];
        if nargout > 2
          varargout{2} = tc;
        end
      end
  else
      error('unknown method');
  end

endfunction
