% Copyright (C) 2008  VZLU Prague, a.s., Czech Republic
% 
% Author: Jaroslav Hajek <highegg@gmail.com>
% 
% This file is part of OctGPR.
% 
% OctGPR is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 3 of the License, or
% (at your option) any later version.
% 
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with this software; see the file COPYING.  If not, see
% <http://www.gnu.org/licenses/>.
% 

% -*- texinfo -*- 
% @deftypefn {Function File} demo_octgpr (1, nsamp = 150)
% @deftypefnx {Function File} demo_octgpr (2, ncnt = 20, npt = 500)
% @deftypefnx {Function File} demo_octgpr (3, ncnt = 50, nsamp = 500)
% OctGPR package demo function.
% First argument selects available demos:
%
% @itemize
% @item 1. GPR regression demo @*
% A function is sampled (with small noise), then reconstructed using GPR
% regression.  @var{nsamp} specifies the number of samples.
% @seealso{gpr_train, gpr_predict}
% @item 2. RBF centers selection demo @*
% Radial basis centers are selected amongst random points.
% @var{ncnt} specifies number of centers, @var{npt} number of points.
% @item 2. PGP regression demo @*
% A function is densely sampled (with small noise), 
% radial basis centers are selected, then the function is reconstructed 
% using PGP regression.  @var{nsamp} specifies the number of samples,
% @var{ncnt} specifies number of centers.
% @end itemize
% @end deftypefn
function demo_octgpr (number, varargin)
  
  global prntfmt = '';

  if (nargin < 1)
    print_usage ();
  elseif (ischar (number))
    prntfmt = number;
  elseif (isscalar (number))
    figure ();
    if (! isempty (prntfmt))
      figure (gcf, "visible", "off");
    endif

    switch (number)
    case 1
      demo_octgpr1 (varargin{:})
    case 2
      demo_octgpr2 (varargin{:})
    case 3
      demo_octgpr3 (varargin{:})
    otherwise
      error ("demo_octgpr: invalid demo number")
    endswitch
  else
    print_usage ();
  endif

endfunction

function demo_octgpr_pause (idemo, iplot)
  global prntfmt;
  if (isempty (prntfmt))
    pause;
  else
    print (sprintf (prntfmt, idemo, iplot));
    fflush (stdout);
  endif
endfunction

% define the test function (the well-known matlab "peaks" plus some sines)
function z = testfun1 (x, y)
  z = 4 + 3 * (1-x).^2 .* exp(-(x.^2) - (y+1).^2) ...
      + 10 * (x/5 - x.^3 - y.^5) .* exp(-x.^2 - y.^2) ...
      - 1/3 * exp(-(x+1).^2 - y.^2) ...
      + 2*sin (x + y + 1e-1*x.*y);
endfunction

function demo_octgpr1 (nsamp = 150)
  global prntfmt;
  tit = "a peaked surface";
  disp (tit);

  % create the mesh onto which to interpolate
  t = linspace (-3, 3, 50);
  [xi,yi] = meshgrid (t, t);

  % evaluate
  zi = testfun1 (xi, yi);
  zimax = max (vec (zi)); zimin = min (vec (zi));
  subplot (2, 2, 1);
  mesh (xi, yi, zi);
  title (tit);
  subplot (2, 2, 3);
  contourf (xi, yi, zi, 20);
  demo_octgpr_pause (1, 1);

  tit = sprintf ("sampled at %d random points", nsamp);
  disp (tit);
  % create random samples
  xs = rand (nsamp,1); ys = rand (nsamp,1);
  xs = 6*xs-3; ys = 6*ys - 3;
  % evaluate at random samples
  zs = testfun1 (xs, ys);
  xys = [xs ys];

  subplot (2, 2, 2);
  plot3 (xs, ys, zs, ".+");
  title (tit);
  subplot (2, 2, 3);
  hold on
  plot (xs, ys, "+6");
  hold off
  subplot (2, 2, 4);
  plot (xs, ys, ".+");
  demo_octgpr_pause (1, 2);

  tit = "GPR model with heuristic hypers";
  disp (tit);
  ths = 1 ./ std (xys);
  GPM = gpr_train (xys, zs, ths, 1e-5);
  zm = gpr_predict (GPM, [vec(xi) vec(yi)]);
  zm = reshape (zm, size(zi));
  zm = min (zm, zimax); zm = max (zm, zimin);
  subplot (2, 2, 2);
  mesh (xi, yi, zm);
  title (tit);
  subplot(2, 2, 4);
  hold on
  contourf (xi, yi, zm, 20);
  plot (xs, ys, "+6");
  hold off
  demo_octgpr_pause (1, 3);

  tit = "GPR model with MLE training";
  disp (tit);
  fflush (stdout);
  GPM = gpr_train (xys, zs, ths, 1e-5, {"tol", 1e-5, "maxev", 400, "numin", 1e-8});
  zm = gpr_predict (GPM, [vec(xi) vec(yi)]);
  zm = reshape (zm, size (zi));
  zm = min (zm, zimax); zm = max (zm, zimin);
  subplot (2, 2, 2);
  mesh (xi, yi, zm);
  title (tit);
  subplot(2, 2, 4);
  hold on
  contourf (xi, yi, zm, 20);
  plot (xs, ys, "+6");
  hold off
  demo_octgpr_pause (1, 4);
  close

endfunction

function demo_octgpr2 (ncnt = 50, npt = 500)

  global prntfmt;
  npt = ncnt*ceil (npt/ncnt);
  U = rand (ncnt, 2);
  cs = min (pdist2_mw (U, 2) + diag (Inf (ncnt, 1)));
  X = repmat (U, npt/ncnt, 1) + repmat (cs', npt/ncnt, 2) .* randn (npt, 2);
  disp ("slightly clustered random points")
  plot (X(:,1), X(:,2), "+");
  demo_octgpr_pause (2, 1);

  [U, ur] = rbf_centers(X, ncnt);

  fi = linspace (0, 2*pi, 20);
  ncolors = rows (colormap);
  hold on
  for i = 1:rows (U)
    xc = U(i,1) + ur(i) * cos (fi);
    yc = U(i,2) + ur(i) * sin (fi);
    line (xc, yc);
  endfor
  hold off
  demo_octgpr_pause (2, 2);
  close

endfunction

function demo_octgpr3 (ncnt = 100, nsamp = 1000)

  global prntfmt;
  tit = "a peaked surface";
  disp (tit);

  % create the mesh onto which to interpolate
  t = linspace (-3, 3, 50);
  [xi,yi] = meshgrid (t, t);

  % evaluate
  zi = testfun1 (xi, yi);
  zimax = max (vec (zi)); zimin = min (vec (zi));
  subplot (2, 2, 1);
  mesh (xi, yi, zi);
  title (tit);
  subplot (2, 2, 3);
  contourf (xi, yi, zi, 20);
  demo_octgpr_pause (1, 1);

  tit = sprintf ("sampled at %d random points, selected %d centers", nsamp, ncnt);
  disp (tit);
  % create random samples
  xs = rand (nsamp,1); ys = rand (nsamp,1);
  xs = 6*xs-3; ys = 6*ys - 3;
  % evaluate at random samples
  zs = testfun1 (xs, ys);
  xys = [xs ys];

  % select centers using k-means
  xyc = rbf_centers (xys, ncnt);
  xc = xyc(:,1); yc = xyc(:,2);

  subplot (2, 2, 2);
  plot3 (xs, ys, zs, ".+");
  title (tit);
  subplot (2, 2, 3);
  hold on
  plot (xs, ys, "+6");
  hold off
  subplot (2, 2, 4);
  hold on
  plot (xs, ys, "+");
  plot (xc, yc, "o2");
  hold off
  demo_octgpr_pause (1, 2);

  tit = "PGP model with heuristic hypers";
  disp (tit);
  ths = 1 ./ std (xyc);
  GPM = pgp_train (xys, xyc, zs, ths, 1e-5);
  zm = pgp_predict (GPM, [vec(xi) vec(yi)]);
  zm = reshape (zm, size(zi));
  zm = min (zm, zimax); zm = max (zm, zimin);
  subplot (2, 2, 2);
  mesh (xi, yi, zm);
  title (tit);
  subplot(2, 2, 4);
  hold on
  contourf (xi, yi, zm, 20);
  plot (xs, ys, "+6");
  plot (xc, yc, "o5");
  hold off
  demo_octgpr_pause (1, 3);

  tit = "PGP model with MLE training";
  disp (tit);
  fflush (stdout);
  GPM = pgp_train (xys, xyc, zs, ths, 1e-3, {"tol", 1e-5, "maxev", 400});
  zm = pgp_predict (GPM, [vec(xi) vec(yi)]);
  zm = reshape (zm, size (zi));
  zm = min (zm, zimax); zm = max (zm, zimin);
  subplot (2, 2, 2);
  mesh (xi, yi, zm);
  title (tit);
  subplot(2, 2, 4);
  hold on
  contourf (xi, yi, zm, 20);
  plot (xs, ys, "+6");
  plot (xc, yc, "o5");
  hold off
  demo_octgpr_pause (1, 4);
  close

endfunction
