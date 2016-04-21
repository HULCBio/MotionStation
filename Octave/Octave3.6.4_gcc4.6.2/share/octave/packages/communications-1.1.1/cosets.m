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
## @deftypefn {Function File} {} cosets (@var{m}, @var{prim})
##
## Finds the elements of GF(2^@var{m}) with primitive polynomial
## @var{prim}, that share the same minimum polynomial. Returns a 
## cell array of the paratitioning of GF(2^@var{m}).
## @end deftypefn

function c = cosets(m, prim)

  if (nargin == 1)
    prim = 0; ## This flags to use default primitive
  elseif (nargin != 2)
    error ("usage: c = cosets (m [, prim])");
  endif

  n = 2^m-1;
  found = zeros(1,n);
  c{1} = gf(1,m,prim);
  found(1) = 1;
  nc = 2;
  f = log(gf(1:n,m,prim));

  while ((!all(found)))
    t = find(!found);
    idx = f(t(find(f(t) == min(f(t).x)))).x;
    set = idx;
    r = rem(idx*2,n);
    while (r > idx)
      set =[set,r];
      r = rem(r*2,n);
    end
    c{nc} = gf(sort(exp(gf(set,m,prim)).x),m,prim);
    found(c{nc}.x) = ones(1,length(c{nc}));
    nc = nc + 1;
  end

endfunction
