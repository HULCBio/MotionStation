## Copyright (C) 2008 Jonathan Stickel <jonathan.stickel@nrel.gov>
##
## This program is free software; you can redistribute it and/or modify it under
## the terms of the GNU General Public License as published by the Free Software
## Foundation; either version 3 of the License, or (at your option) any later
## version.
##
## This program is distributed in the hope that it will be useful, but WITHOUT
## ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
## FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
## details.
##
## You should have received a copy of the GNU General Public License along with
## this program; if not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
##@deftypefn {Function File} {[@var{yhat}, @var{v}] =} rgdtsmcore (@var{x}, @var{y}, @var{d}, @var{lambda}, [@var{options}])
##
## Smooths @var{y} vs. @var{x} values by Tikhonov regularization.
## Although this function can be used directly, the more feature rich
## function "regdatasmooth" should be used instead.  In addition to
## @var{x} and @var{y}, required input includes the smoothing derivative
## @var{d} and the regularization parameter @var{lambda}.  The smooth
## y-values are returned as @var{yhat}.  The generalized cross
## validation variance @var{v} may also be returned.
##
## Note:  the options have changed!
## Currently supported input options are (multiple options are allowed):
##
## @table @code
## @item "xhat", @var{vector}
##  A vector of x-values to use for the smooth curve; must be
##  monotonically increasing and must at least span the data
## @item "weights", @var{vector}
##  A vector of weighting values for fitting each point in the data.
## @item "relative"
##  use relative differences for the goodnes of fit term.  Conflicts
##  with the "weights" option.
## @item "midpointrule"
##  use the midpoint rule for the integration terms rather than a direct
##  sum; this option conflicts with the option "xhat"
## @end table
##
## References:  Anal. Chem. (2003) 75, 3631; AIChE J. (2006) 52, 325
## @seealso{regdatasmooth}
## @end deftypefn


function [yhat, v] = rgdtsmcore (x, y, d, lambda, varargin)

  if (nargin < 4)
    print_usage;
  endif

  ## Defaults if not provided
  xhatprov = 0;
  xhat = x;
  weights = 0;
  relative = 0;
  midpr = 0;
  
  ## parse the provided options
  if ( length(varargin) )
    for i = 1:length(varargin)
      arg = varargin{i};
      if ischar(arg)
        switch arg
          case "xhat"
            xhatprov = 1;
            xhat = varargin{i+1};
          case "weights"
            weights = 1;
            weightv = varargin{i+1};
          case "relative"
            relative = 1;
          case "midpointrule"
            midpr = 1;
          otherwise
            printf("Option '%s' is not implemented;\n", arg)
        endswitch
      endif
    endfor
  endif
  if (xhatprov && midpr)
    warning("midpointrule is currently not used if xhat is provided (since x,y may be scattered)")
    midpr = 0;
  endif
  if (weights && relative)
    warning("relative differences is not used if a weighting vector is provided")
  endif
  
  N = length(x);
  Nhat = length(xhat);
  
  ## test that xhat is increasing
  if !all(diff(xhat)>0)
    if xhatprov
      error("xhat must be monotonically increasing")
    else
      error("x must be monotonically increasing if xhat is not provided")
    endif
  endif
  ## test that xhat spans x
  if ( min(x) < min(xhat) || max(xhat) < max(x) )
    error("xhat must at least span the data")
  endif

  ## construct M, D
  M = speye(Nhat);
  idx = interp1(xhat,1:Nhat,x,"nearest"); # works for unequally spaced xhat
  M = M(idx,:);
  D = ddmat(xhat,d);

  ## construct "weighting" matrices W and U
  if (weights)
    ## use arbitrary weighting as provided
    W = diag(weightv);
  elseif (relative)
    ## use relative differences
    Yinv = sparse(diag(1./y));
    W = Yinv^2;
  else
    W = speye(N);
  endif
  ## use midpoint rule integration (rather than simple sums)
  if (midpr)
    Bhat = sparse(diag(-ones(N-1,1),-1)) + sparse(diag(ones(N-1,1),1));
    Bhat(1,1) = -1;
    Bhat(N,N) = 1;
    B = 1/2*sparse(diag(Bhat*x));
    if ( floor(d/2) == d/2 ) # test if d is even
      dh = d/2;
      Btilda = B(dh+1:N-dh,dh+1:N-dh);
    else # d is odd
      dh = ceil(d/2);
      Btilda = B(dh:N-dh,dh:N-dh);
    endif
    W = W*B;
    U = Btilda;
  else
    ## W = W*speye(Nhat);
    U = speye(Nhat-d);
  endif
  
  ## Smoothing
  delta = trace(D'*D)/Nhat^(2+d);  # using "relative" or other weighting affects this!
  yhat = (M'*W*M + lambda*delta^(-1)*D'*U*D) \ M'*W*y;
  #[R,P,S] = splchol(M'*W*M + lambda*delta^(-1)*D'*U*D);
  #yhat = S*(R'\(R\(S'*M'*W*y)));
  
  ## Computation of hat diagonal and cross-validation
  if (nargout > 1)
    ## from AIChE J. (2006) 52, 325
    ## note: chol factorization does not help speed up the computation of H;
    ## should implement Eiler's partial H computation if many point smoothing by GCV is needed
    ##H = M*(S*(R'\(R\(S'*M'*W))));
    H = M*((M'*W*M + lambda*delta^(-1)*D'*U*D)\M'*W);
    ## note: this is variance, squared of the standard error that Eilers uses
    v = (M*yhat - y)'*(M*yhat - y)/N / (1 - trace(H)/N)^2;
  endif
  
  ## test mapping
  ##figure(5)
  ##plot(x,y,'o',x,M*yhat,'x')

endfunction
