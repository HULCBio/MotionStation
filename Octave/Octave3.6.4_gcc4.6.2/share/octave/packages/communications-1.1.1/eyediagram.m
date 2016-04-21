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
## @deftypefn {Function File} {} eyediagram (@var{x},@var{n})
## @deftypefnx {Function File} {} eyediagram (@var{x},@var{n},@var{per})
## @deftypefnx {Function File} {} eyediagram (@var{x},@var{n},@var{per},@var{off})
## @deftypefnx {Function File} {} eyediagram (@var{x},@var{n},@var{per},@var{off},@var{str})
## @deftypefnx {Function File} {} eyediagram (@var{x},@var{n},@var{per},@var{off},@var{str},@var{h})
## @deftypefnx {Function File} {@var{h} =} eyediagram (@var{...})
##
## Plot the eye-diagram of a signal. The signal @var{x} can be either in one
## of three forms
##
## @table @asis
## @item A real vector
## In this case the signal is assumed to be real and represented by the vector
## @var{x}. A single eye-diagram representing this signal is plotted.
## @item A complex vector
## In this case the in-phase and quadrature components of the signal are 
## plotted seperately.
## @item A matrix with two columns
## In this case the first column represents the in-phase and the second the
## quadrature components of a complex signal.
## @end table
##
## Each line of the eye-diagram has @var{n} elements and the period is assumed
## to be given by @var{per}. The time axis is then [-@var{per}/2 @var{per}/2].
## By default @var{per} is 1.
##
## By default the signal is assumed to start at -@var{per}/2. This can be
## overridden by the @var{off} variable, which gives the number of samples
## to delay the signal.
##
## The string @var{str} is a plot style string (example 'r+'),
## and by default is the default gnuplot line style.
##
## The figure handle to use can be defined by @var{h}. If @var{h} is not 
## given, then the next available figure handle is used. The figure handle
## used in returned on @var{hout}.
## @end deftypefn
## @seealso{scatterplot}

## 2005-04-23 Dmitri A. Sergatskov <dasergatskov@gmail.com>
##     * modified for new gnuplot interface (octave > 2.9.0)

function varargout = eyediagram (x, n, _per, _off, str, h)

  if ((nargin < 2) || (nargin > 6))
    usage (" h = eyediagram (x, n [, per [, off [, str [, h]]]])");
  endif
  
  if (isreal(x))
    if (min(size(x)) == 1)
      signal = "real";
      xr = x(:);
    elseif (size(x,2) == 2)
      signal = "complex";
      xr = x(:,1);
      xr = x(:,2);
    else
      error ("eyediagram: real signal input must be a vector");
    endif
  else
    signal = "complex";
    if (min(size(x)) != 1)
      error ("eyediagram: complex signal input must be a vector");
    endif
    xr = real(x(:));
    xi = imag(x(:));
  endif
  
  if (!length(xr))
    error ("eyediagram: zero length signal");
  endif
  
  if (!isscalar(n) || !isreal(n) || (floor(n) != n) || (n < 1))
    error ("eyediagram: n must be a positive non-zero integer");
  endif

  if (nargin > 2)
    if (isempty(_per))
      per = 1;
    elseif (isscalar(_per) && isreal(_per))
      per = _per;
    else
      error ("eyediagram: period must be a real scalar");
    endif
  else
    per = 1;
  endif

  if (nargin > 3)
    if (isempty(_off))
      off = 0;
    elseif (!isscalar(_off) || !isreal(_off) || (floor(_off) != _off) || ...
	          (_off < 0) || (_off > (n-1)))
      error ("eyediagram: offset must be an integer between 0 and n");
    else
      off = _off;
    endif
  else
    off = 0;
  endif

  if (nargin > 4)
    if (isempty(str))
      fmt = "-r";
    elseif (ischar(str))
      fmt = str;
    else
      error ("eyediagram: plot format must be a string");
    endif
  else
    fmt = "-r";
  endif

  if (nargin > 5)
    if (isempty(h))
      hout = figure ();
    else
      hout = figure (h);
    endif
  else
    hout = figure ();
  endif

  horiz = (per*[0:n]/n - per/2)';
  if (2*floor(n/2) != n)
    horiz = horiz - per / n / 2;
  endif
  lx = length(xr);
  off = mod(off+ceil(n/2),n);
  Nn = ceil((off + lx) / n);
  post = Nn*n - off - lx;
  xr = reshape([NaN * ones(off,1); xr; NaN * ones(post,1)],n,Nn);
  xr = [xr ; [xr(1,2:end), NaN]];
  xr = [xr; NaN*ones(1,Nn)];
  if (all(isnan(xr(2:end,end))))
    xr(:,end) = [];
    horiz = [repmat(horiz(1:n+1),1,Nn-1);NaN*ones(1,Nn-1)](:);
  else
    horiz = [repmat(horiz(1:n+1),1,Nn);NaN*ones(1,Nn)](:);
  endif

  if (strcmp(signal,"complex"))
    xi = reshape([NaN * ones(off,1); xi; NaN * ones(post,1)],n,Nn);
    xi = [xi ; [xi(1,2:end), NaN]];
    xi = [xi; NaN*ones(1,Nn)];
    if (all(isnan(xi(2:end,end))))
      xi(:,end) = [];
    endif
  endif

  if (strcmp(signal,"complex"))
    subplot(2,1,1);
    plot(horiz,xr(:),fmt);
    title("Eye-diagram for in-phase signal");
    xlabel("Time");
    ylabel("Amplitude");
    subplot(2,1,2);
    plot(horiz,xi(:),fmt);
    title("Eye-diagram for quadrature signal");
    xlabel("Time");
    ylabel("Amplitude");
  else
    plot(horiz,xr(:),fmt);
    title("Eye-diagram for signal");
    xlabel("Time");
    ylabel("Amplitude");
  endif

  if (nargout > 0)
    varargout{1} = hout;
  endif

endfunction

%!demo
%! n = 50;
%! ovsp=50;
%! x = 1:n;
%! xi = [1:1/ovsp:n-0.1];
%! y = randsrc(1,n,[1 + 1i, 1 - 1i, -1 - 1i, -1 + 1i]) ;
%! yi = interp1(x,y,xi);
%! noisy = awgn(yi,15,"measured");
%! eyediagram(noisy,ovsp);
