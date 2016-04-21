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
## @deftypefn {Function File} {} {idsim ([@var{u} @var{e}], @var{th})}
##
## Simulate the effects of the MISO system defined by @var{th}.
## @var{e} is the noise in the input.  It is scaled by @math{sqrt(v)}, where @var{v} is 
## the noise variance given when you created the model, so for proper 
## effect, @var{e} should have mean 0 and variance 1.
##
## If @var{e} is not given, then a noise free simulation is run.
##
## @end deftypefn
## @seealso {poly2th, idplot}

function y = idsim(u, th)

  if nargin!=2,
    usage("y = idsim(u, th)");
  endif
  n = rows(u);
  nu = columns(u);
  na = columns(th.a);
  nb = columns(th.b);

  if na!=1
    error("idsim: only SISO/MISO systems have been implemented");
  endif

  if (nu != nb && nu != nb+na)
    error("idsim: wrong number of input columns in u");
  endif

  inp = zeros(n,1);
  for i=1:nb
    inp = inp + filter(th.b(:,i), th.f(:,i), u(:,i));
  endfor

  if (nu != nb)
    inp = inp + filter(th.c, th.d, u(:,nb+1) * sqrt(th.v));
  endif

  y = filter(1, th.a, inp);

endfunction
