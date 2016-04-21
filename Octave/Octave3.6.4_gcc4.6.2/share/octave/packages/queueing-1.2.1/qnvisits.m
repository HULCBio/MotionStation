## Copyright (C) 2008, 2009, 2010, 2011, 2012 Moreno Marzolla
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
## @deftypefn {Function File} {[@var{V} @var{ch}] =} qnvisits (@var{P})
## @deftypefnx {Function File} {@var{V} =} qnvisits (@var{P}, @var{lambda})
##
## Compute the average number of visits to the service centers of a single class, open or closed Queueing Network with @math{N} service centers.
##
## @strong{INPUTS}
##
## @table @var
##
## @item P
## Routing probability matrix. For single class networks,
## @code{@var{P}(i,j)} is the probability that a request which completed
## service at center @math{i} is routed to center @math{j}. For closed
## networks it must hold that @code{sum(@var{P},2)==1}. The routing
## graph myst be strongly connected, meaning that it must be possible to
## eventually reach each node starting from each node. For multiple
## class networks, @code{@var{P}(r,i,s,j)} is the probability that a
## class @math{r} request which completed service at center @math{i} is
## routed to center @math{j} as a class @math{s} request. Class switching
## is supported.
##
## @item lambda
## (open networks only) vector of external arrivals. For single class
## networks, @code{@var{lambda}(i)} is the external arrival rate to
## center @math{i}. For multiple class networks,
## @code{@var{lambda}(r,i)} is the arrival rate of class @math{r}
## requests to center @math{i}. If this function is called with a single
## argument, the network is assumed to be closed.
##
## @end table
##
## @strong{OUTPUTS}
##
## @table @var
##
## @item V
## For single class networks, @code{@var{V}(i)} is the average number of
## visits to server @math{i}, assuming center 1 as the reference station
## (i.e., @code{@var{V}(1) = 1}). For multiple class networks,
## @code{@var{V}(r,i)} is the number of visits of class @math{r}
## requests at center @math{i}.
##
## @item ch
## (For closed networks only). @code{@var{ch}(c)} is the chain number
## that class @math{c} belongs to. Different classes can belong to the
## same chain. Chains are numbered sequentially starting from 1
## (@math{1, 2, @dots{}}). The total number of chains is
## @code{max(@var{ch})}.
##
## @end table
## 
## @end deftypefn

## Author: Moreno Marzolla <marzolla(at)cs.unibo.it>
## Web: http://www.moreno.marzolla.name/

function [V ch] = qnvisits( P, varargin )

  persistent warned = false;
  if (!warned)
    warned = true;
    warning("qn:deprecated-function",
	    "qnvisits is deprecated. Please use one of qncsvisits, qnosvisits, qncmvisits, qnomvisits instead");
  endif

  if ( nargin < 1 || nargin > 2 )
    print_usage();
  endif

  ( ndims(P) == 2 || ndims(P) == 4 ) || \
      error("P must be a 2- or 4-dimensional matrix");

  if ( ndims(P) == 2 ) 
    V = __qnvisitssingle( P, varargin{:} );
    ch = [1];
  else
    [V ch] = __qnvisitsmulti( P, varargin{:} );
  endif
endfunction
%!test
%! P = [-1 0; 0 0];
%! fail( "qnvisits(P)", "not a transition probability" );
%! P = [1 0; 0.5 0];
%! fail( "qnvisits(P)", "not a transition probability" );
%! P = [1 0; 0 1]; lambda=[0 -1];
%! fail( "qnvisits(P,lambda)", "contains negative" );

%!test
%!
%! ## Closed, single class network
%!
%! P = [0 0.3 0.7; 1 0 0; 1 0 0];
%! V = qnvisits(P);
%! assert( V*P,V,1e-5 );
%! assert( V, [1 0.3 0.7], 1e-5 );

%!test
%!
%! ## Open, single class network
%!
%! P = [0 0.2 0.5; 1 0 0; 1 0 0];
%! lambda = [ 0.1 0.3 0.2 ];
%! V = qnvisits(P,lambda);
%! assert( V*P+lambda/sum(lambda),V,1e-5 );

%!test
%!
%! ## Test tolerance of the qnvisits() function. 
%! ## This test builds transition probability matrices and tries
%! ## to compute the visit counts on them. 
%!
%! for k=[5, 10, 20, 50]
%!   P = reshape(1:k^2, k, k);
%!   P = P ./ repmat(sum(P,2),1,k);
%!   V = qnvisits(P);
%!   assert( V*P, V, 1e-5 );
%! endfor

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
%! V = qnvisits(P);
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
%! V = qnvisits(P);
%! for c=1:C
%!   for i=1:K
%!     assert(V(c,i), sum(sum(V .* P(:,:,c,i))), 1e-5);
%!   endfor
%! endfor

%!test
%! C = 2; K = 4;
%! P = zeros(C,K,C,K);
%! # class 1 routing
%! P(1,1,1,1) = .05;
%! P(1,1,1,2) = .45;
%! P(1,1,1,3) = .5;
%! P(1,2,1,1) = 0.1;
%! P(1,3,1,1) = 0.2;
%! # class 2 routing
%! P(2,1,2,1) = .01;
%! P(2,1,2,3) = .5;
%! P(2,1,2,4) = .49;
%! P(2,3,2,1) = 0.2;
%! P(2,4,2,1) = 0.16;
%! lambda = [0.1 0 0 0.1 ; 0 0 0.2 0.1];
%! lambda_sum = sum(lambda(:));
%! V = qnvisits(P, lambda);
%! assert( all(V(:)>=0) );
%! for i=1:K
%!   for c=1:C
%!     assert(V(c,i), lambda(c,i) / lambda_sum + sum(sum(V .* P(:,:,c,i))), 1e-5);
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
%! V = qnvisits(P);
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
%! [nc r] = qnvisits(P);
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
%! [nc r] = qnvisits(P);
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
%! fail( "qnvisits(P)", "different");

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
%! V = qnvisits(P);
%! assert( V, [1 0 1; 0 1 1], 1e-5 );

%!test
%! C = 2;
%! K = 3;
%! P = zeros(C,K,C,K);
%! P(1,1,1,2) = 1;
%! P(1,2,1,3) = 1;
%! P(1,3,2,2) = 1;
%! P(2,2,1,1) = 1;
%! [V ch] = qnvisits(P);
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
%! [V ch] = qnvisits(P);
%! assert( ch, [1 1] );

%!demo
%! P = [0 0.3 0.7; \
%!      1 0   0  ; \
%!      1 0   0  ];
%! V = qnvisits(P)

%!demo
%! p = 0.3;
%! lambda = 1.2
%! P = [0 0.3 0.5; \
%!      1 0   0  ; \
%!      1 0   0  ];
%! V = qnvisits(P,[1.2 0 0])

%!demo
%! P = [ 0 0.4 0.6 0; \
%!       0.2 0 0.2 0.6; \
%!       0 0 0 1; \
%!       0 0 0 0 ];
%! lambda = [0.1 0 0 0.3];
%! V = qnvisits(P,lambda);
%! S = [2 1 2 1.8];
%! m = [3 1 1 2];
%! [U R Q X] = qnos( sum(lambda), S, V, m );

##############################################################################
## Solve the visit equation for multiclass networks with class switching
## P(r,i,s,j) is the probability that a class-r customer on service
## center i moves to service center j as a class-s customer. lambda(r,i)
## is the arrival rate of class-r customers on service center i
function [V chains] = __qnvisitsmulti( P, lambda )
  [C, K, C2, K2] = size( P );
  (K == K2 && C == C2) || \
      error( "P must be a [C,K,C,K] matrix");

  chains = [];

  if ( nargin == 1 ) 
    ## closed network: solve the traffic equations: V(s,j) = sum_r sum_i
    ## V(r,i) * P(r,i,s,j), for all s,j V(s,j) = 1 for all s and for a
    ## chosen server j visited by chain s requests (see below)
    A = reshape(P,[K*C K*C])-eye(K*C);
    b = zeros(1,K*C);

    CH = __scc(reshape(P,[C*K C*K])>0);
    nCH = max(CH); # number of chains
    CH = reshape(CH,C,K); # chains

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

    ## Since there may be queueing centers which are never
    ## visited by some chain(s), we must be careful here. Consider the
    ## following example:

    ##  +---------------------------+  
    ##  |  +---+    +---+    +---+  | Class 1
    ##  +--|   |----|   |----|   |--+
    ##     | 1 |    | 2 |    | 3 |
    ##     |   |  ..|   |....|   |..
    ##     +---+  . +---+    +---+ .  Class 2
    ##            ..................

    ## There are two classes, 1 and 2. These must correspond to two
    ## chains; note that server 1 is never visited by class 2. In the
    ## situation above, CH(2,1) = 0. Obviously, we also have V(2,1) = 0.

    ## To find a solution to the linear system V(s,j) = sum_r sum_i
    ## V(r,i) P(r,i,s,j) we must set some constraints (otherwise the
    ## system may be under defined). If center k is never visited by
    ## class c, we set the constraint V(c,k) = 0; If node k is visited
    ## by class c as part of chain q, we set constraints(q)=1 and V(c,k)
    ## = 1.

    constraints = zeros(1,nCH); # we put one constraint per chain 

    for c=1:C
      for k=1:K
        cc = CH(c,k);
        if ( cc == 0 || constraints(cc) == 0 )
	  ii = sub2ind([C K],c,k);
	  A(:,ii) = 0;
	  A(ii,ii) = 1;
	  if ( cc > 0 )
            ## we put one constraint for this chain
	    constraints(cc) = 1;
	    b(ii) = 1;
          else
            b(ii) = 0;
	  endif
        endif
      endfor
    endfor
    V = reshape(b/A, C, K);
  else
    ## open network: solve the traffic equations: V(s,j) = lambda(s,j) /
    ## lambda + sum_r sum_i V(r,i) * P(r,i,s,j), for all s,j where
    ## lambda is defined as sum_r sum_i lambda(r,i)
  
    [C,K] == size(lambda) || \
        error( "lambda size mismatch" );
    
    ## solve the traffic equation
    A = eye(K*C) - reshape(P,[K*C K*C]);
    b = reshape(lambda / sum(lambda(:)), [1,K*C]);
    V = reshape(b/A, [C, K]);
  endif
  ## Make sure that no negative values appear (sometimes, numerical
  ## errors produce tiny negative values instead of zeros)
  V = max(0,V);
endfunction

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

##############################################################################
## Solve the visit equation for single class networks.
function V = __qnvisitssingle( P, lambda )

  persistent epsilon = 10*eps;

  issquare(P)  || \
      error( "P must be a square matrix" );

  N = size(P,1);
  V = zeros(N,N);

  if ( nargin < 2 )
    ##
    ## Closed network
    ##
    [res err] = dtmcchkP(P);
    (res>0) || \
        error( "P is not a transition probability matrix for closed networks" );

    A = P-eye(N);
    b = zeros(1,N);
    i = 1; # reference station
    A(:,i) = 0; A(i,i) = 1;
    b(i) = 1;
    V = b/A;
  else
    ##
    ## Open network
    ##
    all(P(:)>=0) && all( sum(P,2)<=1+1e-5 ) || \
	error( "P is not a transition probability matrix for open networks" );

    ( isvector(lambda) && length(lambda) == N ) || \
        error( "lambda size mismatch" );
    all( lambda>= 0 ) || \
        error( "lambda contains negative values" );

    A = eye(N)-P;
    b = lambda / sum(lambda);
    V = b/A;
  endif
  ## Make sure that no negative values appear (sometimes, numerical
  ## errors produce tiny negative values instead of zeros)
  V = max(0,V);
endfunction

