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
## @deftypefn {Function File} {@var{cve} =} rgdtsmcorewrap (@var{log10lambda}, @var{x}, @var{y}, @var{d}, @var{mincell}, @var{options})
## @deftypefnx {Function File} {@var{stdevdif} =} rgdtsmcorewrap (@var{log10lambda}, @var{x}, @var{y}, @var{d}, @var{mincell}, @var{options})
##
##  Wrapper function for rgdtsmcore in order to minimize over
##  @var{lambda} w.r.t. cross-validation error OR the squared difference
##  between the standard deviation of (@var{y}-@var{yhat}) and the given
##  standard deviation.  This function is called from regdatasmooth.
## @seealso{regdatasmooth}
## @end deftypefn

function out = rgdtsmcorewrap (log10lambda, x, y, d, mincell, varargin)

  if (nargin < 5)
    print_usage;
  endif

  lambda = 10^(log10lambda);

  if ( length(mincell) == 2 ) # using stdev to find optimal lambda
    stdev = mincell{2};
    yhat  = rgdtsmcore (x, y, d, lambda, varargin{:});

    xhatprov = 0;
    relative = 0;
    for i = 1:length(varargin)
      if strcmp(varargin{i},"relative")
        relative = 1;
      elseif strcmp(varargin{i},"xhat")
        xhatprov = 1;
        xhat = varargin{i+1};
      endif
    endfor

    if (xhatprov)
      idx = interp1(xhat,1:length(xhat),x,"nearest");
      if relative
        stdevd = std((y-yhat(idx))./y);
      else
        stdevd = std(y-yhat(idx));
      endif
    else
      if (relative)
        stdevd = std((y-yhat)./y);
      else
        stdevd = std(y-yhat);
      endif
    endif

    out = (stdevd - stdev)^2;

  else # use gcv to find optimal lambda
    [yhat, out] = rgdtsmcore (x, y, d, lambda, varargin{:});
  endif

endfunction
