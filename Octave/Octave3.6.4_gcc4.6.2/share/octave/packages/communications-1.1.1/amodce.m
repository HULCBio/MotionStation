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
## @deftypefn {Function File} {@var{y} =} amodce (@var{x},@var{Fs},'amdsb-tc',offset)
## @deftypefnx {Function File} {@var{y} =} amodce (@var{x},@var{Fs},'amdsb-sc')
## @deftypefnx {Function File} {@var{y} =} amodce (@var{x},@var{Fs},'amssb')
## @deftypefnx {Function File} {@var{y} =} amodce (@var{x},@var{Fs},'amssb/time',@var{num},@var{den})
## @deftypefnx {Function File} {@var{y} =} amodce (@var{x},@var{Fs},'qam')
## @deftypefnx {Function File} {@var{y} =} amodce (@var{x},@var{Fs},'fm',@var{dev})
## @deftypefnx {Function File} {@var{y} =} amodce (@var{x},@var{Fs},'pm',@var{dev})
## @deftypefnx {Function File} {@var{y} =} amodce (@var{x},[@var{Fs},@var{iphs}],@var{...})
##
## Baseband modulator for analog signals. The input signal is specified by
## @var{x}, its sampling frequency by @var{Fs} and the type of modulation
## by the third argument, @var{typ}. The default values of @var{Fs} is 1 and 
## @var{typ} is 'amdsb-tc'.
##
## If the argument @var{Fs} is a two element vector, the the first element
## represents the sampling rate and the second the initial phase.
##
## The different types of modulations that are available are
##
## @table @asis
## @item 'am'
## @itemx 'amdsb-tc'
## Double-sideband with carrier
## @item 'amdsb-sc'
## Double-sideband with suppressed carrier
## @item 'amssb'
## Single-sideband with frequency domain Hilbert filtering
## @item 'amssb/time'
## Single-sideband with time domain filtering. Hilbert filter is used by 
## default, but the filter can be specified
## @item 'qam'
## Quadrature amplitude modulation
## @item 'fm'
## Frequency modulation
## @item 'pm'
## Phase modulation
## @end table
##
## Additional arguments are available for the modulations 'amdsb-tc', 'fm, 
## 'pm' and 'amssb/time'. These arguments are
##
## @table @code
## @item offset
## The offset in the input signal for the transmitted carrier.
## @item dev
## The deviation of the phase and frequency modulation
## @item num
## @itemx den
## The numerator and denominator of the filter transfer function for the
## time domain filtering of the SSB modulation
## @end table
##
## @end deftypefn
## @seealso{ademodce,dmodce}

function y = amodce (x, Fs, typ, varargin)

  if (nargin < 1)
    help("amodce");
  elseif (nargin < 2)
    Fs = 1;
    typ = "am";
  elseif (nargin < 3)
    typ = "am";
  endif

  if (isempty(Fs))
    Fs = 1;
    iphs = 0;
  elseif (isscalar(Fs))
    iphs = 0;
  else
    if ((max(size(Fs)) != 2) || (min(size(Fs)) != 1))
      error ("amodce: sampling frequency must be a scalar or 2-element vector");
    endif
    Fs = Fs(1);
    iphs = Fs(2);
  endif

  ## Pass the optional arguments
  offset = min(x(:));
  dev = 1;
  num = [];
  den = [];
  narg = 1;
  if (!ischar(typ))
    error ("amodce: modulation type must be a string");
  elseif (strcmp(typ,"am") || strcmp(typ,"amdsb-tc"))
    if (length(varargin) > 0)
      offset = varargin{1};
      narg = narg + 1;
    endif
  elseif (strcmp(typ,"fm") || strcmp(typ,"pm"))
    if (length(varargin) > 0)
      dev = varargin{1};
      narg = narg + 1;
    endif
  endif    
  if (length(varargin) == narg)
    error ("amodce: must specify must numerator and denominator of transfer function");
  elseif (length(varargin) == narg+1)
    num = varargin{narg};
    den = varargin{narg+1};
  elseif (length(varargin) != narg - 1)
    error ("amodce: too many arguments");
  endif

  if (strcmp(typ,"am") || strcmp(typ,"amdsb-tc"))
    y = (x + offset) * exp(1i * iphs);
  elseif (strcmp(typ,"amdsb-sc"))
    y = x * exp(1i * iphs);
  elseif (strcmp(typ,"amssb"))
    if (!isreal(x))
      error ("amodce: SSB modulated signal must be real");
    endif
    ## Damn, must treat Hilbert transform row-by-row!!!
    y = zeros(size(x));
    for i=1:size(x,2)
      y(:,i) = hilbert(x(:,i)) * exp(1i * iphs);
    end
  elseif (strcmp(typ,"amssb/time"))
    if (isempty(num) || isempty(dem))
      error ("amodce: have not implemented Hilbert transform in time domain yet");
    endif
    y = zeros(size(x));
    for i=1:size(x,2)
      y(:,i) = filter(num, den, x(:,i));
      y(:,i) = (x(:,i) + 1i*y(:,i)) * exp(1i * iphs);
    end
  elseif (strcmp(typ,"qam"))
    if (isreal(x))
      if (floor(size(x,2)/2) != (size(x,2)/2))
	      error ("amodce: QAM modulation must have an even number of columns for real signals");
      endif
      y = (x(:,1:2:size(x,2)) + 1i * x(:,2:2:size(x,2))); 
    else
      y = x;
    endif
    y = y * exp(1i * iphs);
  elseif (strcmp(typ,"pm"))
    y = exp(1i * (dev*x + iphs));
  elseif (strcmp(typ,"fm"))
    ## To convert to PM signal, need to evaluate 
    ##    p(t) = \int_0^t dev * x(T) dT 
    ## As x(t) is discrete and not a function, the only way to perform the
    ## above integration is with Simpson's rule. Note \Delta T = 2 * pi / Fs.
    pm = pi / Fs * dev * (cumsum([zeros(1,size(x,2));x(1:size(x,1)-1,:)]) ...
			                    + cumsum(x));
    y = exp(1i * (pm + iphs));
  else
    error ("amodce: unknown modulation specified");
  endif

endfunction

