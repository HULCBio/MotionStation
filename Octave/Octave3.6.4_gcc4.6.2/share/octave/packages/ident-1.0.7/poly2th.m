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

## -*- texinfo -*-
## @deftypefn {Function File} {} {poly2th (@var{a}, @var{b}, @var{c}, @var{d}, @var{f}, @var{v}, @var{T})}
##
## Represent the generalized Multi-Input, Single-Output (MISO) system
## defined as follows:
##
##
## @math{ A_j(q)y(t) = \sum_{i=1}^{bn} \left( \frac{B_i(q)}{F_i(q)} u_i(t) \right) + \frac{C(q)}{D(q)}e_j(t)}
## where 
## e is white noise
## u is the input signal
## y is the output signal
##
## @var{v} is the variance on the noise (default is 1)
## @var{T} is the sampling interval (default is 1)
##
## @end deftypefn
## @seealso {mktheta, idsim}

## TODO: incorporate delays: if system is discrete (T>0), then delay for
## TODO: input i is the number of leading zeros in b(:,i)
function th = poly2th(a,b,c,d,f,v,T)
  if nargin<1 || nargin>7,
    usage("th = poly2th(a,b,c,d,f,v,T)");
  endif
  th.a = a;
  if nargin<2, th.b=[]; else th.b = b; endif
  if nargin<3, th.c=1;  else th.c=c; endif
  if nargin<4, th.d=1;  else th.d=d; endif
  if nargin<5, th.f=[]; else th.f=f; endif
  if nargin<6, th.v=1;  else th.v=v; endif
  if nargin<7, th.T=1;  else th.T=T; endif

  if size(th.a,1) == 1, th.a = th.a.'; endif
  if size(th.b,1) == 1, th.b = th.b.'; endif
  if size(th.c,1) == 1, th.c = th.c.'; endif
  if size(th.d,1) == 1, th.d = th.d.'; endif
  if size(th.f,1) == 1, th.f = th.f.'; endif

  if isempty(th.f), th.f = ones(1,columns(th.b)); endif

  na = columns(th.a);
  nb = columns(th.b);
  nc = columns(th.c);
  nd = columns(th.d);
  nf = columns(th.f);
  
  if nf != nb
    error("poly2th f and b must have the same number of columns");
  endif

  if nc>1 || nd>1
    error("poly2th: c and d may only have one column");
  endif
endfunction
