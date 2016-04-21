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
## @deftypefn {Function File} {} apkconst (@var{nsig})
## @deftypefnx {Function File} {} apkconst (@var{nsig},@var{amp})
## @deftypefnx {Function File} {} apkconst (@var{nsig},@var{amp},@var{phs})
## @deftypefnx {Function File} {} apkconst (@var{...},"n")
## @deftypefnx {Function File} {} apkconst (@var{...},@var{str})
## @deftypefnx {Function File} {@var{y} = } apkconst (@var{...})
##
## Plots a ASK/PSK signal constellation. Argument @var{nsig} is a real vector
## whose length determines the number of ASK radii in the constellation.
## The values of vector @var{nsig} determine the number of points in each 
## ASK radii. 
##
## By default the radii of each ASK modulated level is given by the index of 
## @var{nsig}. The amplitudes can be defined explictly in the variable
## @var{amp}, which  is a vector of the same length as @var{nsig}.
##
## By default the first point in each ASK radii has zero phase, and following
## points are coding in an anti-clockwise manner. If @var{phs} is defined then
## it is a vector of the same length as @var{nsig} defining the initial phase
## in each ASK radii.
##
## In addition @dfn{apkconst} takes two string arguments 'n' and and @var{str}.
## If the string 'n' is included in the arguments, then a number is printed
## next to each constellation point giving the symbol value that would be
## mapped to this point by the @dfn{modmap} function. The argument @var{str}
## is a plot style string (example 'r+') and determines the default gnuplot
## point style to use for plot points in the constellation.
##
## If @dfn{apskconst} is called with a return argument, then no plot is
## created. However the return value is a vector giving the in-phase and
## quadrature values of the symbols in the constellation.
## @end deftypefn
## @seealso{dmod,ddemod,modmap,demodmap}


## 2005-04-23 Dmitri A. Sergatskov <dasergatskov@gmail.com>
##     * modified for new gnuplot interface (octave > 2.9.0)



function yout = apkconst(varargin)

  if ((nargin < 1) || (nargin > 5))
    error ("apkconst: incorrect number of arguments");
  endif

  numargs = 0;
  printnums = 0;
  fmt = "+r";
  amp = [];
  phs = [];

  for i=1:length(varargin)
    arg = varargin{i};
    if (ischar(arg))
      if (strcmp(arg,"n"))
	      try
	        text();
	        printnums = 1;
	      catch
	        printnums = 0;
	      end
      else
	      fmt = arg;
      endif
    else
      numargs++;
      switch (numargs)
	      case 1,
	        nsig = arg; 
	      case 2,
	        amp = arg; 
	      case 3,
	        phs = arg; 
	      otherwise
	        error ("apkconst: too many numerical arguments");
      endswitch
    endif
  end

  if (numargs < 1)
    error ("apkconst: must have at least one vector argument");
  endif

  if (isempty(amp))
    amp = 1:length(nsig);
  endif

  if (isempty(phs))
    phs = zeros(size(amp));
  endif

  if (!isvector(nsig) || !isvector(amp) || !isvector(phs) || ...
      (length(nsig) != length(amp)) || (length(nsig) != length(phs)))
    error ("apkconst: numerical arguments must be vectors of the same length");
  endif

  if (length(nsig) == 0)
    error ("apkconst: first numerical argument must have non-zero length");
  endif

  y = [];
  for i=1:length(nsig)
    if (nsig(i) < 1)
      error ("apkconst: must have at least one point in ASK radii");
    endif
    y = [y; amp(i) * [cos(2*pi*[0:nsig(i)-1]'/nsig(i) + phs(i)) + ...
		                  1i*sin(2*pi*[0:nsig(i)-1]'/nsig(i) + phs(i))]];
  end

  if (nargout == 0)
    r = [0:0.02:2]'*pi;
    x0 = cos(r) * amp;
    y0 = sin(r) * amp;
    plot(x0, y0, "b");
    yy = [real(y), imag(y)];
    hold on;
    if (printnums)
      xd = 0.05 * max(real(y));
      for i=1:length(y)
	      text(real(y(i))+xd,imag(y(i)),num2str(i-1));
      end
    endif
    plot (real(y), imag(y), fmt);

    title("ASK/PSK Constellation");
    xlabel("In-phase");
    ylabel("Quadrature");
  else
    yout = y;
  endif

endfunction
