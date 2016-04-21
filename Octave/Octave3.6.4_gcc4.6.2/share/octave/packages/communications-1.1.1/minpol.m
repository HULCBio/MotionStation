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
## @deftypefn {Function File} {} minpol (@var{v})
##
## Finds the minimum polynomial for elements of a Galois Field. For  a 
## vector @var{v} with @math{N} components, representing @math{N} values 
## in a Galois Field GF(2^@var{m}), return the minimum polynomial in GF(2)
## representing thos values.
## @end deftypefn

function r = minpol (v)

  if (nargin != 1)
    error("usage: r = minpol(v)");
  endif

  if (!isgalois(v))
    error("minpol: argument must be a galois variable");
  endif

  if (min (size (v)) > 1 || nargin != 1)
    usage ("minpol (v), where v is a galois vector");
  endif

  n = length (v);
  m = v.m;
  prim_poly = v.prim_poly;
  r = zeros(n,m+1);

  ## Find cosets of GF(2^m) and convert from cell array to matrix
  cyclocoset = cosets(m, prim_poly);
  cyclomat = zeros(max(size(cyclocoset)),m);
  for j=1:max(size(cyclocoset))
    cyclomat(j,1:length(cyclocoset{j})) = cyclocoset{j};
  end
  
  for j =1:n
    if (v(j) == 0)
      ## Special case
      r(j,m-1) = 1;
    else
      ## Find the coset within which the current element falls
      [rc, ignored] = find(cyclomat == v(j));

      rv = cyclomat(rc,:);

      ## Create the minimum polynomial from its roots 
      ptmp = gf([1,rv(1)], m, prim_poly);
      for i=2:length(rv)
        ptmp = conv(ptmp, [1,rv(i)]);
      end

      ## Need to left-shift polynomial to divide by x while can
      i = 0;
      while (!ptmp(m+1-i))
        i = i + 1;
      end
      ptmp = [zeros(1,i), ptmp(1:m+1-i)];
      r(j,:) = ptmp;
    endif
  end

  ## Ok, now put the return value into GF(2)
  r = gf(r,1);
  
endfunction
