## Copyright (C) 2003 David Bateman
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
## @deftypefn {Function File} {} scatterplot (@var{x})
## @deftypefnx {Function File} {} scatterplot (@var{x},@var{n})
## @deftypefnx {Function File} {} scatterplot (@var{x},@var{n},@var{off})
## @deftypefnx {Function File} {} scatterplot (@var{x},@var{n},@var{off},@var{str})
## @deftypefnx {Function File} {} scatterplot (@var{x},@var{n},@var{off},@var{str},@var{h})
## @deftypefnx {Function File} {@var{h} =} scatterplot (@var{...})
##
## Display the scatter plot of a signal. The signal @var{x} can be either in
## one of three forms
##
## @table @asis
## @item A real vector
## In this case the signal is assumed to be real and represented by the vector
## @var{x}. The scatterplot is plotted along the x axis only.
## @item A complex vector
## In this case the in-phase and quadrature components of the signal are 
## plotted seperately on the x and y axes respectively.
## @item A matrix with two columns
## In this case the first column represents the in-phase and the second the
## quadrature components of a complex signal and are plotted on the x and
## y axes respectively.
## @end table
##
## Each point of the scatter plot is assumed to be seperated by @var{n} 
## elements in the signal. The first element of the signal to plot is 
## determined by @var{off}. By default @var{n} is 1 and @var{off} is 0.
##
## The string @var{str} is a plot style string (example 'r+'),
## and by default is the default gnuplot point style.
##
## The figure handle to use can be defined by @var{h}. If @var{h} is not 
## given, then the next available figure handle is used. The figure handle
## used in returned on @var{hout}.
## @end deftypefn
## @seealso{eyediagram}

## 2005-04-23 Dmitri A. Sergatskov <dasergatskov@gmail.com>
##     * modified for new gnuplot interface (octave > 2.9.0)

function varargout = scatterplot (x, n, _off, str, h)

  if ((nargin < 1) || (nargin > 5))
    usage (" h = scatterplot (x, n [, off [, str [, h]]]])");
  endif
  
  if (isreal(x))
    if (min(size(x)) == 1)
      signal = "real";
      xr = x(:);
      xi = zeros(size(xr));
    elseif (size(x,2) == 2)
      signal = "complex";
      xr = x(:,1);
      xi = x(:,2);
    else
      error ("scatterplot: real signal input must be a vector");
    endif
  else
    signal = "complex";
    if (min(size(x)) != 1)
      error ("scatterplot: complex signal input must be a vector");
    endif
    xr = real(x(:));
    xi = imag(x(:));
  endif
  
  if (!length(xr))
    error ("scatterplot: zero length signal");
  endif
  
  if (nargin > 1)
    if (!isscalar(n) || !isreal(n) || (floor(n) != n) || (n < 1))
      error ("scatterplot: n must be a positive non-zero integer");
    endif
  else
    n = 1;
  endif
  
  if (nargin > 2)
    if (!isscalar(_off) || !isreal(_off) || (floor(_off) != _off) || ...
	(_off < 0) || (_off > length(x)-1))
      error ("scatterplot: offset must be an integer between 0 and length(x)-1");
    endif
    off = _off;
  else
    off = 0;
  endif

  if (nargin > 3)
    if (isempty(str))
      fmt = "-r";
    elseif (ischar(str))
      fmt = str;
    else
      error ("scatterplot: plot format must be a string");
    endif
  else
    fmt = "-r";
  endif

  if (nargin > 4)
    hout = figure (h);
  else
    hout = figure ();
  endif

  xr = xr(off+1:n:rows(xr));
  xi = xi(off+1:n:rows(xi));

  plot(xr,xi,fmt);
  if (!strcmp(signal,"complex"))
    ## FIXME: What is the appropriate xrange
    xmax = max(xr);
    xmin = min(xr);
    xran = xmax - xmin
    xmax =  ceil(2 * xmax / xran) / 2 * xran;
    xmin = floor(2 * xmin / xran) / 2 * xran;
    axis([xmin, xmax, -1, 1]);
  endif
  title("Scatter plot");
  xlabel("In-phase");
  ylabel("Quadrature");
  legend("off");

  if (nargout > 0)
    varargout{1} = hout;
  endif

endfunction

%!demo
%! n = 200;
%! ovsp=5;
%! x = 1:n;
%! xi = [1:1/ovsp:n-0.1];
%! y = randsrc(1,n,[1 + 1i, 1 - 1i, -1 - 1i, -1 + 1i]) ;
%! yi = interp1(x,y,xi);
%! noisy = awgn(yi,15,"measured");
%! hold off;
%! h = scatterplot(noisy,1,0,"b",1);
%! hold on;
%! scatterplot(noisy,ovsp,0,"r+",h);
