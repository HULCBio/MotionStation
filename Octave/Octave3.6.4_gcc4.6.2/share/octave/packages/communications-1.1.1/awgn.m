## Copyright (C) 2002 David Bateman
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
## @deftypefn {Function File} {@var{y} =} awgn (@var{x},@var{snr})
## @deftypefnx {Function File} {@var{y} =} awgn (@var{x},@var{snr},@var{pwr})
## @deftypefnx {Function File} {@var{y} =} awgn (@var{x},@var{snr}, @var{pwr},@var{seed})
## @deftypefnx {Function File} {@var{y} =} awgn (@var{...}, '@var{type}')
##
## Add white Gaussian noise to a voltage signal.
##
## The input @var{x} is assumed to be a real or complex voltage  signal. The
## returned value @var{y} will be the same form and size as @var{x} but with 
## Gaussian noise added. Unless the power is specified in @var{pwr}, the 
## signal power is assumed to be 0dBW, and the noise of @var{snr} dB will be
## added with respect to this. If @var{pwr} is a numeric value then the signal
## @var{x} is assumed to be @var{pwr} dBW, otherwise if @var{pwr} is 
## 'measured', then the power in the signal will be measured and the noise
## added relative to this measured power.
##
## If @var{seed} is specified, then the random number generator seed is 
## initialized with this value
##
## By default the @var{snr} and @var{pwr} are assumed to be in dB and dBW
## respectively. This default behaviour can be chosen with @var{type} 
## set to 'dB'. In the case where @var{type} is set to 'linear', @var{pwr}
## is assumed to be in Watts and @var{snr} is a ratio.
## @end deftypefn
## @seealso{randn,wgn}

## 2003-01-28
##   initial release

function y = awgn (x, snr, varargin)

  if ((nargin < 2) || (nargin > 5))
    error ("usage: awgn(x, snr, p, seed, type");
  endif

  [m,n] = size(x);
  if (isreal(x))
    out = "real";
  else
    out = "complex";
  endif

  p = 0;
  seed = [];
  type = "dB";
  meas = 0;
  narg = 0;
  
  for i=1:length(varargin)
    arg = varargin{i};
    if (ischar(arg))
      if (strcmp(arg,"measured"))
        meas = 1;  
      elseif (strcmp(arg,"dB"))
        type = "dB";  
      elseif (strcmp(arg,"linear"))
        type = "linear";  
      else
        error ("awgn: invalid argument");
      endif
    else
      narg++;
      switch (narg)
	      case 1,
	        p = arg;
	      case 2,
	        seed = arg;
	      otherwise
	        error ("wgn: too many arguments");
      endswitch
    endif
  end

  if (isempty(p))
    p = 0;
  endif

  if (!isempty(seed))
    if (!isscalar(seed) || !isreal(seed) || (seed < 0) || 
        ((seed-floor(seed)) != 0))
      error ("awgn: random seed must be integer");
    endif
  endif

  if (!isscalar(p) || !isreal(p))
    error("awgn: invalid power");
  endif
  if (strcmp(type,"linear") && (p < 0))
    error("awgn: invalid power");
  endif

  if (!isscalar(snr) || !isreal(snr))
    error("awgn: invalid snr");
  endif
  if (strcmp(type,"linear") && (snr < 0))
    error("awgn: invalid snr");
  endif

  if(!isempty(seed))
    randn("state",seed);
  endif

  if (meas == 1)
    p = sum( abs( x(:)) .^ 2) / length(x(:));
    if (strcmp(type,"dB"))
      p = 10 * log10(p);
    endif
  endif

  if (strcmp(type,"linear"))
    np = p / snr;
  else
    np = p - snr;
  endif
  
  y = x + wgn (m, n, np, 1, seed, type, out);
  
endfunction

                                %!shared x, y, noisy
                                %!       x = [0:0.01:2*pi]; y = sin (x);
                                %!       noisy = awgn (y, 20, "dB", "measured");

## Test of noisy is pretty arbitrary, but should pickup most errors
                                %!error awgn ();
                                %!error awgn (1);
                                %!error awgn (1,1,1,1,1);
                                %!assert (isreal(noisy));
                                %!assert (iscomplex(awgn(y+1i,20,"dB","measured")));
                                %!assert (size(y) == size(noisy))
                                %!assert (abs(10*log10(mean(y.^2)/mean((y-noisy).^ 2)) - 20) < 1);
