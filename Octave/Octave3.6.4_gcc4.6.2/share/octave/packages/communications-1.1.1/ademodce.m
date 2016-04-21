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
## @deftypefn {Function File} {@var{y} =} ademodce (@var{x},@var{Fs},'amdsb-tc',offset)
## @deftypefnx {Function File} {@var{y} =} ademodce (@var{x},@var{Fs},'amdsb-tc/costas',offset)
## @deftypefnx {Function File} {@var{y} =} ademodce (@var{x},@var{Fs},'amdsb-sc')
## @deftypefnx {Function File} {@var{y} =} ademodce (@var{x},@var{Fs},'amdsb-sc/costas')
## @deftypefnx {Function File} {@var{y} =} ademodce (@var{x},@var{Fs},'amssb')
## @deftypefnx {Function File} {@var{y} =} ademodce (@var{x},@var{Fs},'qam')
## @deftypefnx {Function File} {@var{y} =} ademodce (@var{x},@var{Fs},'qam/cmplx')
## @deftypefnx {Function File} {@var{y} =} ademodce (@var{x},@var{Fs},'fm',@var{dev})
## @deftypefnx {Function File} {@var{y} =} ademodce (@var{x},@var{Fs},'pm',@var{dev})
## @deftypefnx {Function File} {@var{y} =} ademodce (@var{x},[@var{Fs},@var{iphs}],@var{...})
## @deftypefnx {Function File} {@var{y} =} ademodce (@var{...},@var{num},@var{den})
##
## Baseband demodulator for analog signals. The input signal is specified by
## @var{x}, its sampling frequency by @var{Fs} and the type of modulation
## by the third argument, @var{typ}. The default values of @var{Fs} is 1 and 
## @var{typ} is 'amdsb-tc'.
##
## If the argument @var{Fs} is a two element vector, the the first element
## represents the sampling rate and the second the initial phase.
##
## The different types of demodulations that are available are
##
## @table @asis
## @item 'am'
## @itemx 'amdsb-tc'
## Double-sideband with carrier
## @item 'amdsb-tc/costas'
## Double-sideband with carrier and Costas phase locked loop
## @item 'amdsb-sc'
## Double-sideband with suppressed carrier
## @item 'amssb'
## Single-sideband with frequency domain Hilbert filtering
## @item 'qam'
## Quadrature amplitude demodulation. In-phase in odd-columns and quadrature
## in even-columns
## @item 'qam/cmplx'
## Quadrature amplitude demodulation with complex return value.
## @item 'fm'
## Frequency demodulation
## @item 'pm'
## Phase demodulation
## @end table
##
## Additional arguments are available for the demodulations 'amdsb-tc', 'fm', 
## 'pm'. These arguments are
##
## @table @code
## @item offset
## The offset in the input signal for the transmitted carrier.
## @item dev
## The deviation of the phase and frequency modulation
## @end table
##
## It is possible to specify a low-pass filter, by the numerator @var{num} 
## and denominator @var{den} that will be applied to the returned vector.
##
## @end deftypefn
## @seealso{ademodce,dmodce}

function y = ademodce (x, Fs, typ, varargin)

  if (nargin < 1)
    help("ademodce");
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
      error ("ademodce: sampling frequency must be a scalar or 2-element vector");
    endif
    Fs = Fs(1);
    iphs = Fs(2);
  endif

  ## Pass the optional arguments
  dev = 1;
  num = [];
  den = [];
  narg = 1;
  if (!ischar(typ))
    error ("ademodce: modulation type must be a string");
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
    error ("ademodce: must specify must numerator and denominator of transfer function");
  elseif (length(varargin) == narg+1)
    num = varargin{narg};
    den = varargin{narg+1};
  elseif (length(varargin) != narg - 1)
    error ("ademodce: too many arguments");
  endif

  if (strcmp(typ,"am") || findstr(typ,"amdsb-tc"))
    if (findstr(typ,"/costas"))
      error ("ademodce: Costas phase locked loop not implemented");
    endif
    y = real(x * exp(-1i * iphs));
    if (exist("offset","var"))
      y = y - offset;
    else
      if (min(size(y)) == 1)
	      y = y - mean(y);
      else
	      for i=1:size(y,2)
	        y(:,i) = y(:,i) - mean(y(:,i));
	      end
      endif
    endif
  elseif (strcmp(typ,"amdsb-sc"))
    y = real(x * exp(-1i * iphs));
  elseif (findstr(typ,"amssb"))
    if (findstr(typ,"/costas"))
      error ("ademodce: Costas phase locked loop not implemented");
    endif
    y = real(x * exp(-1i * iphs));
  elseif (strcmp(typ,"qam"))
    y1 = x * exp(-1i * iphs);
    y = zeros(size(y1,1),2*size(y1,2));
    y(:,1:2:size(y,2)) = real(y1);
    y(:,2:2:size(y,2)) = imag(y1);
  elseif (strcmp(typ,"qam/cmplx"))
    y = x * exp(-1i * iphs);
  elseif (strcmp(typ,"pm"))
    y = ( -1i * log(x) + iphs) / dev;
  elseif (strcmp(typ,"fm"))
    ## This can't work as it doesn't take into account the
    ## phase wrapping in the modulation process. Therefore 
    ## we'll get some of the demodulated values in error, with
    ## most of the values being correct..
    ##
    ## Not sure the best approach to fixing this. Perhaps implement
    ## a PLL with the ouput of the phase detector being the demodulated
    ## signal...
    warning("ademodce: FM demodulation broken!!")
    pm = Fs / dev / pi * ( - 1i * log(x) + iphs)
    y = [pm(:,1), (pm(:,2:size(pm,2)) - pm(:,1:size(pm,2)-1))]; 
  else
    error ("ademodce: unknown demodulation specified");
  endif

  if (!isempty(num) && !isempty(dem))
    ## Low-pass filter the output
    if (min(size(y)) == 1)
      y = filter(num,den, y);
    else    
      for i=1:size(y,2)
	      y(:,i) = filter(num, den, y(:,i));
      end
    endif
  endif

endfunction

