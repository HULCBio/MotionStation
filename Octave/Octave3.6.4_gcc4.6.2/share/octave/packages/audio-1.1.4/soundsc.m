## Copyright (C) 2000 Paul Kienzle
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; If not, see <http://www.gnu.org/licenses/>.

## usage: soundsc(x, fs, limit) or soundsc(x, fs, [ lo, hi ])
##
## soundsc(x)
##    Scale the signal so that [min(x), max(x)] -> [-1, 1], then 
##    play it through the speakers at 8000 Hz sampling rate.  The
##    signal has one column per channel.  
##
## soundsc(x,fs)
##    Scale the signal and play it at sampling rate fs.
##
## soundsc(x, fs, limit)
##    Scale the signal so that [-|limit|, |limit|] -> [-1, 1], then
##    play it at sampling rate fs.  If fs is empty, then the default
##    8000 Hz sampling rate is used.
##
## soundsc(x, fs, [ lo, hi ])
##    Scale the signal so that [lo, hi] -> [-1, 1], then play it
##    at sampling rate fs.  If fs is empty, then the default 8000 Hz
##    sampling rate is used.
##
## y=soundsc(...)
##    return the scaled waveform rather than play it.
##
## See sound for more information.

function data_r = soundsc(data, rate, range)

  if nargin < 1 || nargin > 3, usage("soundsc(x, fs, [lo, hi])") endif
  if nargin < 2, rate = []; endif
  if nargin < 3, range = [min(data(:)), max(data(:))]; endif
  if isscalar(range), range = [-abs(range), abs(range)]; endif
  
  data=(data - mean(range))/((range(2)-range(1))/2);
  if nargout > 0
    data_r = data;
  else
    sound(data, rate);
  endif
endfunction


%!demo
%! [x, fs] = auload(file_in_loadpath("sample.wav"));
%! soundsc(x,fs);

%!shared y
%! [x, fs] = auload(file_in_loadpath("sample.wav"));
%! y=soundsc(x);
%!assert (min(y(:)), -1, eps)
%!assert (max(y(:)), 1, eps)
