## Copyright (C) 2012 Juan Pablo Carbajal <carbajal@ifi.uzh.ch>
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
## @deftypefn {Function File} {@var{polyline} = } curve2polyline (@var{curve})
## @deftypefnx {Function File} {@var{polyline} = } curve2polyline (@dots{},@var{property},@var{value},@dots{})
## Adaptive sampling of a parametric curve.
##
## The @var{curve} is described as a 2-by-N matrix. Rows correspond to the
## polynomial (compatible with @code{polyval}) describing the respective component
## of the curve. The curve must be parametrized in the interval [0,1].
## The vertices of the polyline are accumulated in regions of the curve where
## the curvature is higher.
##
## @strong{Parameters}
## @table @samp
## @item 'Nmax'
## Maximum number of vertices. Not used.
## @item 'Tol'
## Tolerance for the error criteria. Default value @code{1e-4}.
## @item 'MaxIter'
## Maximum number of iterations. Default value @code{10}.
## @item 'Method'
## Not implemented.
## @end table
##
## @seealso{shape2polygon, curveval}
## @end deftypefn

## This function is based on the algorithm described in
## L. H. de Figueiredo (1993). "Adaptive Sampling of Parametric Curves". Graphic Gems III.
## I had to remove the recursion so this version could be improved.
## Thursday, April 12 2012 -- JuanPi

function [polyline t bump]= curve2polyline (curve, varargin)
## TODO make tolerance relative to the "diameter" of the curve.

  # --- Parse arguments --- #
  parser = inputParser ();
  parser.FunctionName = "curve2polyline";
  parser = addParamValue (parser,'Nmax', 32, @(x)x>0);
  parser = addParamValue (parser,'Tol', 1e-4, @(x)x>0);
  parser = addParamValue (parser,'MaxIter', 10, @(x)x>0);
  parser = parse(parser,varargin{:});

  Nmax      = parser.Results.Nmax;
  tol       = parser.Results.Tol;
  MaxIter   = parser.Results.MaxIter;

  clear parser toldef
  # ------ #

  t = [0; 1];
  tf = 1;
  points = 1;
  for iter = 1:MaxIter
    # Add parameter values where error is still bigger than tol.
    t = interleave(t, tf);
    nt = length(t);

    # Update error
    polyline = curveval (curve,t);
    bump = bumpyness(polyline);

    # Check which intervals must be subdivided
    idx = find(bump > tol);
    # The position of the bumps mpas into intervals
    # 1 -> 1 2
    # 2 -> 3 4
    # 3 -> 5 6
    # and so on
    idx = [2*(idx-1)+1; 2*idx](:);
    tf = false (nt-1,1);
    tf(idx) = true;

    if all (!tf)
      break;
    end

  end

endfunction

function f = bumpyness (p)
## Check for co-linearity
## TODO implement various method for this
## -- Area of the triangle close to zero (used currently).
## -- Angle close to pi.
## -- abs(p0-pt) + abs(pt-p1) - abs(p0-p1) almost zero.
## -- Curve's tange at 0,t,1 are almost parallel.
## -- pt is in chord p0 -> p1.
## Do this in isParallel.m and remove this function

  PL = p(1:2:end-2,:);
  PC = p(2:2:end-1,:);
  PR = p(3:2:end,:);

  a = PL - PC;
  b = PR - PC;

  f = (a(:,1).*b(:,2) - a(:,2).*b(:,1)).^2;

endfunction

function tt = interleave (t,varargin)

 nt   = length(t);
 ntt = 2 * nt -1;
 tt = zeros(ntt,1);
 tt(1:2:ntt) = t;
 beta = 0.4 + 0.2*rand(nt-1, 1);
 tt(2:2:ntt) = t(1:end-1) + beta.*(t(2:end)-t(1:end-1));

 if nargin > 1
  tf = true (ntt,1);
  tf(2:2:ntt) = varargin{1};
  tt(!tf) = [];
 end

endfunction

%!demo
%! curve    = [0 0 1 0;1 -0.3-1 0.3 0];
%! polyline = curve2polyline(curve,'tol',1e-8);
%!
%! t  = linspace(0,1,100)';
%! pc = curveval(curve,t);
%!
%! plot(polyline(:,1),polyline(:,2),'-o',pc(:,1),pc(:,2),'-r')
