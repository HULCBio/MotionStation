## Copyright (C) 2011 David Bateman
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
## @deftypefn {Loadable Function} {y =} filter (@var{b}, @var{a}, @var{x})
## @deftypefnx {Loadable Function} {[@var{y}, @var{sf}] =} filter (@var{b}, @var{a}, @var{x}, @var{si})
## 
## Digital filtering of vectors in a Galois Field. Returns the solution to
## the following linear, time-invariant difference equation over a Galois
## Field:
## @iftex
## @tex
## $$
## \\sum_{k=0}^N a_{k+1} y_{n-k} = \\sum_{k=0}^M b_{k+1} x_{n-k}, \\qquad
##  1 \\le n \\le P
## $$
## @end tex
## @end iftex
## @ifinfo
## 
## @smallexample
##    N                   M
##   SUM a(k+1) y(n-k) = SUM b(k+1) x(n-k)      for 1<=n<=length(x)
##   k=0                 k=0
## @end smallexample
## @end ifinfo
## 
## @noindent
## where
## @ifinfo
##  N=length(a)-1 and M=length(b)-1.
## @end ifinfo
## @iftex
## @tex
##  $a \\in \\Re^{N-1}$, $b \\in \\Re^{M-1}$, and $x \\in \\Re^P$.
## @end tex
## @end iftex
## An equivalent form of this equation is:
## @iftex
## @tex
## $$
## y_n = -\\sum_{k=1}^N c_{k+1} y_{n-k} + \\sum_{k=0}^M d_{k+1} x_{n-k}, \\qquad
##  1 \\le n \\le P
## $$
## @end tex
## @end iftex
## @ifinfo
## 
## @smallexample
##             N                   M
##   y(n) = - SUM c(k+1) y(n-k) + SUM d(k+1) x(n-k)  for 1<=n<=length(x)
##            k=1                 k=0
## @end smallexample
## @end ifinfo
## 
## @noindent
## where
## @ifinfo
##  c = a/a(1) and d = b/a(1).
## @end ifinfo
## @iftex
## @tex
## $c = a/a_1$ and $d = b/a_1$.
## @end tex
## @end iftex
## 
## If the fourth argument @var{si} is provided, it is taken as the
## initial state of the system and the final state is returned as
## @var{sf}.  The state vector is a column vector whose length is
## equal to the length of the longest coefficient vector minus one.
## If @var{si} is not supplied, the initial state vector is set to all
## zeros.
## @end deftypefn

function varargout = filter (varargin)
  varargout = cell (1, max(1, nargout));
  [varargout{:}] = gfilter (varargin{:});
endfunction
