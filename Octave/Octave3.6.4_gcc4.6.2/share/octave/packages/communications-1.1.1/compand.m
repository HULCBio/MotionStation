## Copyright (C) 2001 Paul Kienzle
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
## @deftypefn {Function File} {@var{y} = } compand (@var{x}, @var{mu}, @var{V}, 'mu/compressor')
## @deftypefnx {Function File} {@var{y} = } compand (@var{x}, @var{mu}, @var{V}, 'mu/expander')
## @deftypefnx {Function File} {@var{y} = } compand (@var{x}, @var{mu}, @var{V}, 'A/compressor')
## @deftypefnx {Function File} {@var{y} = } compand (@var{x}, @var{mu}, @var{V}, 'A/expander')
##
## Compresses and expanding the dynamic range of a signal using a mu-law or
## or A-law algorithm.
##
## The mu-law compressor/expander for reducing the dynamic range, is used
## if the fourth argument of @dfn{compand} starts with 'mu/'. Whereas the
## A-law compressor/expander is used if @dfn{compand} starts with 'A/'.
## The mu-law algorithm uses the formulation
##
## @iftex
## @tex
## $$
## y = {V log (1 + \\mu / V \\|x\\|) \\over log (1 + \\mu)} sgn(x)
## $$
## @end tex
## @end iftex
## @ifinfo
## @example
##
##         V log (1 + \mu/V |x|)
##     y = -------------------- sgn(x)
##             log (1 + \mu)
##
## @end example
## @end ifinfo
##
## while the A-law algorithm used the formulation
##
## @iftex
## @tex
## $$
## y = { \\left\{  \\matrix{ {A / (1 + log A) x}, & 0 <= \\|x\\| <= V/A \\cr
##                  & \\cr  
##                  {V log (1 + log(A/V \\|x\\|) ) \\over 1 + logA}, &
##                  V/A < \\|x\\| <= V} \\right. }
## $$
## @end tex
## @end iftex
## @ifinfo
## @example
##
##         /    A / (1 + log A) x,               0 <= |x| <= V/A  
##         | 
##     y = <    V ( 1 + log (A/V |x|) )
##         |    ----------------------- sgn(x),  V/A < |x| <= V
##         \        1 + log A
## @end example
## @end ifinfo
##
## Neither converts from or to audio file ulaw format. Use mu2lin or lin2mu
## instead.
##
## @end deftypefn
## @seealso{m2ulin, lin2mu}

function y = compand(x, mu, V, stype)

  if (nargin != 3 && nargin != 4)
    usage('y=compand(x,[mu|A],V,stype);'); 
  endif
  if (nargin < 4) 
    stype = 'mu/compressor';
  else 
    stype = tolower(stype);
  endif

  if strcmp(stype, 'mu/compressor')
    y = (V/log(1+mu)) * log(1+(mu/V)*abs(x)) .* sign(x);
  elseif strcmp(stype, 'mu/expander')
    y = (V/mu) * ( exp (abs(x) * (log(1+mu)/V)) - 1 ) .* sign(x);
  elseif strcmp(stype, 'a/compressor')
    y = zeros(size(x));
    idx = find (abs(x) <= V/mu);
    if (idx)
      y(idx) = (mu/(1+log(mu))) * abs(x(idx));
    endif
    idx = find (abs(x) > V/mu);
    if (idx)
      y(idx) = (V/(1+log(mu))) * (1 + log ((mu/V) * abs(x(idx))));
    endif
    y = y .* sign(x);
  elseif strcmp(stype, 'a/expander')
    y = zeros(size(x));
    idx = find (abs(x) <= V/(1+log(mu)));
    if (idx)
      y(idx) = ((1+log(mu))/mu) * abs(x(idx));
    endif
    idx = find (abs(x) > V/(1+log(mu)));
    if (idx)
      y(idx) = exp (((1+log(mu))/V) * abs(x(idx)) - 1) * (V/mu);
    endif
    y = y .* sign(x);
  endif

endfunction

