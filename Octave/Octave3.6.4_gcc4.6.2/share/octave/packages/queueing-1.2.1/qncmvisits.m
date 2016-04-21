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
## @deftypefn {Function File} {[@var{V} @var{ch}] =} qncmvisits (@var{P})
## @deftypefnx {Function File} {[@var{V} @var{ch}] =} qncmvisits (@var{P}, @var{r})
##
## Compute the average number of visits to the service centers of a closed multiclass network with @math{K} service centers and @math{C} customer classes.
##
## @strong{INPUTS}
##
## @table @var
##
## @item P
## @code{@var{P}(r,i,s,j)} is the probability that a
## class @math{r} request which completed service at center @math{i} is
## routed to center @math{j} as a class @math{s} request. Class switching
## is allowed.
##
## @item r
## @code{@var{r}(c)} is the index of class @math{c} reference station,
## @math{r(c) \in @{1, @dots{}, K@}}, @math{c \in @{1, \@dots{}, C@}}.
## The class @math{c} visit count to server @code{@var{r}(c)}
## (@code{@var{V}(c,r(c))}) is conventionally set to 1. The reference
## station serves two purposes: (i) its throughput is assumed to be the
## system throughput, and (ii) a job returning to the reference station
## is assumed to have completed one cycle. Default is to consider
## station 1 as the reference station for all classes.
##
## @end table
##
## @strong{OUTPUTS}
##
## @table @var
##
## @item V
## @code{@var{V}(c,i)} is the number of visits of class @math{c}
## requests at center @math{i}.
##
## @item ch
## @code{@var{ch}(c)} is the chain number that class @math{c} belongs
## to. Different classes can belong to the same chain. Chains are
## numbered sequentially starting from 1 (@math{1, 2, @dots{}}). The
## total number of chains is @code{max(@var{ch})}.
##
## @end table
## 
## @end deftypefn

## Author: Moreno Marzolla <marzolla(at)cs.unibo.it>
## Web: http://www.moreno.marzolla.name/

function [V chains] = qncmvisits( P, r )

  if ( nargin < 1 || nargin > 2 )
    print_usage();
  endif

  ndims(P) == 4 || \
      error("P must be a 4-dimensional matrix");

  [C, K, C2, K2] = size( P );
  (K == K2 && C == C2) || \
      error( "P must be a [C,K,C,K] matrix");

  if ( nargin < 2)
    r = ones(1,C);
  else
    isvector(r) && length(r) == C || \
	error("r must be a vector with %d elements",C);
    all( r>=1 && r<=K ) || \
	error("elements in r must be in the range 1 - %d",K);
    r = r(:)';
  endif

  ## solve the traffic equations: V(s,j) = sum_r sum_i V(r,i) *
  ## P(r,i,s,j), for all s,j V(s,r(s)) = 1 for all s.
  A = reshape(P,[K*C K*C])-eye(K*C);
  b = zeros(1,K*C);

  CH = __scc(reshape(P,[C*K C*K])>0);
  nCH = max(CH); # number of chains
  CH = reshape(CH,C,K); # CH(c,k) is the chain that class c at center k belongs to

  chains = zeros(1,C);
  
  for k=1:K
    for c=1:C
      if ( chains(c) == 0 )
        chains(c) = CH(c,k);
      else
        ( CH(c,k) == 0 || chains(c) == CH(c,k) ) || \
            error("Class %d belongs to different chains",c);
      endif
    endfor
  endfor

  constraints = zeros(1,nCH); # constraint(cc) = 1 iff we set a constraint for a class belonging to chain cc; we only set one constraint per chain

  for c=1:C
    cc = CH(c,r(c));
    if ( cc == 0 || constraints(cc) == 0 ) 
      ii = sub2ind([C K],c,r(c));
      A(:,ii) = 0;
      A(ii,ii) = 1;
      if ( cc > 0 ) ## if r(c) is not an isolated node
	constraints(cc) = 1;
	b(ii) = 1;
      endif
    endif
  endfor

  V = reshape(b/A, C, K);
  ## Make sure that no negative values appear (sometimes, numerical
  ## errors produce tiny negative values instead of zeros)
  V = max(0,V);
endfunction

%!test
%!
%! ## Closed, multiclass network
%!
%! C = 2; K = 3; 
%! P = zeros(C,K,C,K);
%! P(1,1,1,2) = 1;
%! P(1,2,1,1) = 1;
%! P(2,1,2,3) = 1;
%! P(2,3,2,1) = 1;
%! V = qncmvisits(P);
%! for c=1:C
%!   for k=1:K
%!     assert(V(c,k), sum(sum(V .* P(:,:,c,k))), 1e-5);
%!   endfor
%! endfor

%!test
%!
%! ## Test multiclass network. Example from Schwetman (figure 7, page 9 of
%! ## http://docs.lib.purdue.edu/cgi/viewcontent.cgi?article=1258&context=cstech
%! ## "Testing network-of-queues software, technical report CSD-TR 330,
%! ## Purdue University).
%!
%! C = 2; K = 4;
%! P = zeros(C,K,C,K);
%! # class 1 routing
%! P(1,1,1,1) = .05;
%! P(1,1,1,2) = .45;
%! P(1,1,1,3) = .5;
%! P(1,2,1,1) = 1;
%! P(1,3,1,1) = 1;
%! # class 2 routing
%! P(2,1,2,1) = .01;
%! P(2,1,2,3) = .5;
%! P(2,1,2,4) = .49;
%! P(2,3,2,1) = 1;
%! P(2,4,2,1) = 1;
%! V = qncmvisits(P);
%! for c=1:C
%!   for i=1:K
%!     assert(V(c,i), sum(sum(V .* P(:,:,c,i))), 1e-5);
%!   endfor
%! endfor

%!test
%!
%! ## Network with class switching.
%! ## This is example in figure 9 of
%! ## Schwetman, "Implementing the Mean Value Analysis
%! ## Algorithm fort the solution of Queueing Network Models", Technical
%! ## Report CSD-TR-355, Department of Computer Science, Purdue Univrsity,
%! ## Feb 15, 1982
%! ## http://docs.lib.purdue.edu/cgi/viewcontent.cgi?article=1285&context=cstech
%!
%! C = 2; K = 3;
%! S = [.01 .07 .10; \
%!      .05 0.7 .10 ];
%! P = zeros(C,K,C,K);
%! P(1,1,1,2) = .7;
%! P(1,1,1,3) = .2;
%! P(1,1,2,1) = .1;
%! P(2,1,2,2) = .3;
%! P(2,1,2,3) = .5;
%! P(2,1,1,1) = .2;
%! P(1,2,1,1) = P(1,3,1,1) = 1;
%! P(2,2,2,1) = P(2,3,2,1) = 1;
%! N = [3 0];
%! V = qncmvisits(P);
%! VV = [10 7 2; 5 1.5 2.5]; # result given in Schwetman; our function computes something different, but that's ok since visit counts are actually ratios
%! assert( V ./ repmat(V(:,1),1,K), VV ./ repmat(VV(:,1),1,K), 1e-5 );

%!test
%!
%! ## two disjoint classes: must produce two disjoing chains
%!
%! C = 2; K = 3;
%! P = zeros(C,K,C,K);
%! P(1,1,1,2) = 1;
%! P(1,2,1,1) = 1;
%! P(2,1,2,3) = 1;
%! P(2,3,2,1) = 1;
%! [nc r] = qncmvisits(P);
%! assert( r(1) != r(2) );

%!test
%!
%! ## two classes, one chain
%!
%! C = 2; K = 3;
%! P = zeros(C,K,C,K);
%! P(1,1,1,2) = .5;
%! P(1,2,2,1) = 1;
%! P(2,1,2,3) = .5;
%! P(2,3,1,1) = 1;
%! [nc r] = qncmvisits(P);
%! assert( r(1) == r(2) );

%!test
%! 
%! ## a "Moebius strip". Note that this configuration is invalid, and
%! ## therefore our algorithm must raise an error. This is because this
%! ## network has two chains, but both chains contain both classes
%!
%! C = 2; K = 2;
%! P = zeros(C,K,C,K);
%! P(1,1,2,2) = 1;
%! P(2,2,1,1) = 1;
%! P(2,1,1,2) = 1;
%! P(1,2,2,1) = 1;
%! fail( "qncmvisits(P)", "different");

%!test
%!
%! ## Network with two classes representing independent chains.
%! ## This is example in figure 8 of
%! ## Schwetman, "Implementing the Mean Value Analysis
%! ## Algorithm fort the solution of Queueing Network Models", Technical
%! ## Report CSD-TR-355, Department of Computer Science, Purdue Univrsity,
%! ## Feb 15, 1982
%! ## http://docs.lib.purdue.edu/cgi/viewcontent.cgi?article=1285&context=cstech
%! 
%! C = 2; K = 2;
%! P = zeros(C,K,C,K);
%! P(1,1,1,3) = P(1,3,1,1) = 1;
%! P(2,2,2,3) = P(2,3,2,2) = 1;
%! V = qncmvisits(P,[1,2]);
%! assert( V, [1 0 1; 0 1 1], 1e-5 );

%!test
%! C = 2;
%! K = 3;
%! P = zeros(C,K,C,K);
%! P(1,1,1,2) = 1;
%! P(1,2,1,3) = 1;
%! P(1,3,2,2) = 1;
%! P(2,2,1,1) = 1;
%! [V ch] = qncmvisits(P);
%! assert( ch, [1 1] );

## The following transition probability matrix is not well formed: note
## that there is an outgoing transition from center 1, class 1 but not
## incoming transition.
%!test
%! C = 2;
%! K = 3;
%! P = zeros(C,K,C,K);
%! P(1,1,1,2) = 1;
%! P(1,2,1,3) = 1;
%! P(1,3,2,2) = 1;
%! P(2,2,2,1) = 1;
%! P(2,1,1,2) = 1;
%! [V ch] = qncmvisits(P);
%! assert( ch, [1 1] );

%!demo
%! P = [ 0 0.4 0.6 0; \
%!       0.2 0 0.2 0.6; \
%!       0 0 0 1; \
%!       0 0 0 0 ];
%! lambda = [0.1 0 0 0.3];
%! V = qncmvisits(P,lambda);
%! S = [2 1 2 1.8];
%! m = [3 1 1 2];
%! [U R Q X] = qnos( sum(lambda), S, V, m );

## compute strongly connected components using Kosaraju's algorithm,
## which requires two DFS visits. A better solution would be to use
## Tarjan's algorithm.
##
## In this implementation, an isolated node without self loops will NOT
## belong to any SCC. Although this is not formally correct from the
## graph theoretic point of view, it is necessary to compute chains
## correctly.
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
      if (any(r))
	s(r) = c++;
      endif
    endif
  endfor
endfunction

## Executes a dfs visit on graph G, starting from source node s
function v = __dfs(G, s)
  assert( issquare(G) );
  N = rows(G);
  v = stack = zeros(1,N); ## v(i) == 1 iff node i has been visited
  q = 1; # first empty slot in queue
  stack(q++) = s;
  ## Note: node s is NOT marked as visited; it will me marked as visited
  ## only if we visit it again. This is necessary to ensure that
  ## isolated nodes without self loops will not belong to any SCC.
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

