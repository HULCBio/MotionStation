## Copyright (C) 2012 Moreno Marzolla
##
## This file is part of the queueing toolbox.
##
## The queueing toolbox is free software: you can redistribute it and/or
## modify it under the terms of the GNU General Public License as
## published by the Free Software Foundation, either version 3 of the
## License, or (at your option) any later version.
##
## The queueing toolbox is distributed in the hope that it will be
## useful, but WITHOUT ANY WARRANTY; without even the implied warranty
## of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with the queueing toolbox. If not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
##
## @deftypefn {Function File} {[@var{r} @var{s}] =} dtmc_is_irreducible (@var{P})
##
## This function is deprecated. Please use @code{dtmcisir} instead.
## 
## @seealso{dtmcisir}
##
## @end deftypefn

## Author: Moreno Marzolla <marzolla(at)cs.unibo.it>
## Web: http://www.moreno.marzolla.name/

function [r s] = dtmc_is_irreducible( P )
  persistent warned = false;
  if (!warned)
    warned = true;
    warning("qn:deprecated-function",
	    "dtmc_is_irreducible is deprecated. Please use dtmcisir instead");
  endif
  [r s] = dtmcisir( P );
endfunction
%!test
%! P = [0 .5 0; 0 0 0];
%! fail( "dtmc_is_irresudible(P)" );

%!test
%! P = [0 1 0; 0 .5 .5; 0 1 0];
%! [r s] = dtmc_is_irreducible(P);
%! assert( r == 0 );
%! assert( max(s), 2 );
%! assert( min(s), 1 );

%!test
%! P = [.5 .5 0; .2 .3 .5; 0 .2 .8];
%! [r s] = dtmc_is_irreducible(P);
%! assert( r == 1 );
%! assert( max(s), 1 );
%! assert( min(s), 1 );

## FIXME: (mosty) copied from qnvisits.m; use a better algorithm for SCC
## (e.g.,
## http://pmtksupport.googlecode.com/svn/trunk/gaimc1.0-graphAlgo/scomponents.m
function s = __scc(G)
  assert(issquare(G));
  N = rows(G);
  GF = (G>0);
  GB = (G'>0);
  s = zeros(N,1);
  c=1;
  for n=1:N
    if (s(n) == 0)
      fw = __dfs(GF,n);
      bw = __dfs(GB,n);
      r = (fw & bw);
      s(r) = c++;
    endif
  endfor
endfunction

## FIXME: (mosty) copied from qnvisits.m
function v = __dfs(G, s)
  assert( issquare(G) );
  N = rows(G);
  v = stack = zeros(1,N); ## v(i) == 1 iff node i has been visited
  q = 1; # first empty slot in queue
  stack(q++) = s; v(s) = 1;
  while( q>1 )
    n = stack(--q);
    ## explore neighbors of n: all f in G(n,:) such that v(f) == 0
    
    ## The following instruction is equivalent to:
    ##    for f=find(G(n,:))
    ##      if ( v(f) == 0 )
    for f = find ( G(n,:) & (v==0) )
      stack(q++) = f;
      v(f) = 1;
    endfor
  endwhile
endfunction
