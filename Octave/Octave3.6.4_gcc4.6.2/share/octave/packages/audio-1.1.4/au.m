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

## y = au(x, fs, lo [, hi])
##
## Extract data from x for time range lo to hi in milliseconds.  If lo
## is [], start at the beginning.  If hi is [], go to the end.  If hi is
## not specified, return the single element at lo.  If lo<0, prepad the
## signal to time lo.  If hi is beyond the end, postpad the signal to
## time hi.

## TODO: modify prepad and postpad so that they accept matrices.
function y=au(x,fs,lo,hi)
  if nargin<3 || nargin>4,
    usage("y = au(x, fs, lo [,hi])");
  endif

  if nargin<4, hi=lo; endif
  if isempty(lo), 
    lo=1; 
  else
    lo=fix(lo*fs/1000)+1;
  endif
  if isempty(hi),
    hi=length(x);
  else
    hi=fix(hi*fs/1000)+1;
  endif
  if hi<lo, t=hi; hi=lo; lo=hi; endif
  if (size(x,1)==1 || size(x,2)==1)
    y=x(max(lo,1):min(hi,length(x)));
    if (lo<1), y=prepad(y,length(y)-lo+1); endif
    if (hi>length(x)), y=postpad(y,length(y)+hi-length(x)); endif
  else
    y=x(max(lo,1):min(hi,length(x)), :);
    if (lo<1), y=[zeros(size(x,2),-lo+1) ; y]; endif
    if (hi>length(x)), y=[y ; zeros(size(x,2),hi-length(x))]; endif
  endif
endfunction
