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
##@deftypefn {Function File} {[@var{yhat}, @var{lambda}] =} regdatasmooth (@var{x}, @var{y}, [@var{options}])
##
## Smooths the @var{y} vs. @var{x} values of 1D data by Tikhonov
## regularization. The smooth y-values are returned as @var{yhat}. The
## regularization parameter @var{lambda} that was used for the smoothing
## may also be returned.
##
## Note:  the options have changed!
## Currently supported input options are (multiple options are allowed):
##
##@table @code
##@item "d", @var{value}
## the smoothing derivative to use (default = 2)
##@item "lambda", @var{value}
## the regularization paramater to use
##@item "stdev", @var{value}
## the standard deviation of the measurement of @var{y}; an optimal
## value for lambda will be determined by matching the provided
## @var{value} with the standard devation of @var{yhat}-@var{y};
## if the option "relative" is also used, then a relative standard
## deviation is inferred
##@item "gcv"
## use generalized cross-validation to determine the optimal value for
## lambda; if neither "lambda" nor "stdev" options are given, this
## option is implied
##@item "lguess", @var{value}
## the initial value for lambda to use in the iterative minimization
## algorithm to find the optimal value (default = 1)
## @item "xhat", @var{vector}
##  A vector of x-values to use for the smooth curve; must be
##  monotonically increasing and must at least span the data
## @item "weights", @var{vector}
##  A vector of weighting values for fitting each point in the data.
## @item "relative"
##  use relative differences for the goodnes of fit term.  Conflicts
##  with the "weights" option.
##@item "midpointrule"
## use the midpoint rule for the integration terms rather than a direct
## sum; this option conflicts with the option "xhat"
##@end table
##
## Please run the demos for example usage.
##
## References:  Anal. Chem. (2003) 75, 3631; AIChE J. (2006) 52, 325
## @seealso{rgdtsmcorewrap, rgdtsmcore}
## @end deftypefn

function [yhat, lambda] = regdatasmooth (x, y, varargin)

  if (nargin < 2)
    print_usage;
  elseif ( length(x) != length(y) )
    error("x and y must be equal length vectors")
  endif
  if ( isrow(x) ) x = x'; endif
  if ( isrow(y) ) y = y'; endif

  ## defaults
  d = 2;
  lambda = 0;
  stdev = 0;
  guess = 0;

  ## parse options for d, lambda, stdev, gcv, lguess;
  ## remaining options (gridx, Nhat, range, relative, midpointrule)
  ## will be sent directly to the core function
  idx = [];
  if ( nargin > 2)
    for i = 1:nargin-2
      arg = varargin{i};
      if ischar(arg)
        switch arg
          case "d"
            d = varargin{i+1};
            idx = [idx,i,i+1];
          case "lambda"
            lambda = varargin{i+1};
            idx = [idx,i,i+1];
          case "stdev"
            stdev = varargin{i+1};
            idx = [idx,i,i+1];
          case "gcv"
            idx = [idx,i];
          case "lguess"
            guess = log10(varargin{i+1});
            idx = [idx,i,i+1];
        endswitch
      endif
    endfor
  endif
  varargin(idx) = [];
  options = varargin;
  ## add warning if more than one gcv, lambda, or stdev options provided?

  maxiter = 50;
  if (lambda)
    ## do nothing and use the provided lambda
  else
    ## find the "optimal" lambda
    if ( stdev )
      ## match standard deviation
      fhandle = @(log10lambda) rgdtsmcorewrap (log10lambda, x, y, d, {"stdev", stdev}, options{:});
    else
      ## perform cross-validation
      fhandle = @(log10lambda) rgdtsmcorewrap (log10lambda, x, y, d, {"cve"}, options{:});
    endif
    ## "fminunc" works OK, but a derivative-free method (below) is better for this problem
    ##opt = optimset("TolFun",1e-6,"MaxFunEvals",maxiter);
    ##[log10lambda,fout,exitflag] = fminunc (fhandle, guess, opt);
    ##[log10lambda,fout,exitflag] = fminunc_compat (fhandle, guess, opt);
    ## derivative-free optimization; should use "fminsearch" for Matlab
    ## compatibility, but fminsearch needs updates to be more compatible itself
    [log10lambda, fout, niter] = nelder_mead_min (fhandle, guess, "ftol", 1e-6, "maxev", maxiter);
    if (niter > maxiter)
      exitflag = 0;
    else
      exitflag = 1;
    endif
    if (!exitflag)
      warning("Iteration limit of %i exceeded\n",maxiter)
    endif
    lambda = 10^log10lambda;
  endif
  
  yhat = rgdtsmcore (x, y, d, lambda, options{:});
  
endfunction

%!demo
%! npts = 100;
%! x = linspace(0,2*pi,npts)';
%! x = x + 2*pi/npts*(rand(npts,1)-0.5);
%! y = sin(x);
%! y = y + 1e-1*randn(npts,1);
%! yp = ddmat(x,1)*y;
%! y2p = ddmat(x,2)*y;
%! [yh, lambda] = regdatasmooth (x, y, "d",4,"stdev",1e-1,"midpointrule");
%! lambda
%! yhp = ddmat(x,1)*yh;  
%! yh2p = ddmat(x,2)*yh;
%! clf
%! subplot(221)
%! plot(x,y,'o','markersize',5,x,yh,x,sin(x))
%! title("y(x)")
%! legend("noisy","smoothed","sin(x)","location","northeast");
%! subplot(222)
%! plot(x(1:end-1),[yp,yhp,cos(x(1:end-1))])
%! axis([min(x),max(x),min(yhp)-abs(min(yhp)),max(yhp)*2])
%! title("y'(x)")
%! legend("noisy","smoothed","cos(x)","location","southeast");
%! subplot(223)
%! plot(x(2:end-1),[y2p,yh2p,-sin(x(2:end-1))])
%! axis([min(x),max(x),min(yh2p)-abs(min(yh2p)),max(yh2p)*2])
%! title("y''(x)")
%! legend("noisy","smoothed","-sin(x)","location","southeast");
%! %--------------------------------------------------------
%! % smoothing of monotonic data, using "stdev" to determine the optimal lambda

%!demo
%! npts = 20;
%! x = rand(npts,1)*2*pi;
%! y = sin(x);
%! y = y + 1e-1*randn(npts,1);
%! xh = linspace(0,2*pi,200)';
%! [yh, lambda] = regdatasmooth (x, y, "d", 3, "xhat", xh);
%! lambda
%! clf
%! figure(1);
%! plot(x,y,'o','markersize',10,xh,yh,xh,sin(xh))
%! title("y(x)")
%! legend("noisy","smoothed","sin(x)","location","northeast");
%! %--------------------------------------------------------
%! % smoothing of scattered data, using "gcv" to determine the optimal lambda
