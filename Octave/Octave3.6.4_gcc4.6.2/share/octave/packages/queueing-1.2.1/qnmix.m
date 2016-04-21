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
## @deftypefn {Function File} {[@var{U}, @var{R}, @var{Q}, @var{X}] =} qnmix (@var{lambda}, @var{N}, @var{S}, @var{V}, @var{m})
##
## @cindex Mean Value Analysys (MVA)
## @cindex mixed network
##
## Solution of mixed queueing networks through MVA. The network consists
## of @math{K} service centers (single-server or delay centers) and
## @math{C} independent customer chains. Both open and closed chains
## are possible. @var{lambda} is the vector of per-chain
## arrival rates (open classes); @var{N} is the vector of populations
## for closed chains.
##
## @quotation Note
## In this implementation class switching is @strong{not} allowed. Each
## customer class @emph{must} correspond to an independent chain.
## @end quotation
##
## If the network is made of open or closed classes only, then this
## function calls @code{qnom} or @code{qncmmva}
## respectively, and prints a warning message.
##
## @strong{INPUTS}
##
## @table @var
##
## @item lambda
## @itemx N
## For each customer chain @math{c}:
##
## @itemize
##
## @item if @math{c} is a closed chain, then @code{@var{N}(c)>0} is the
## number of class @math{c} requests and @code{@var{lambda}(c)} must be
## zero;
##
## @item If @math{c} is an open chain,
## @code{@var{lambda}(c)>0} is the arrival rate of class @math{c}
## requests and @code{@var{N}(c)} must be zero;
##
## @end itemize
##
## @noindent In other words, for each class @math{c} the following must hold:
##
## @example
## (@var{lambda}(c)>0 && @var{N}(c)==0) || (@var{lambda}(c)==0 && @var{N}(c)>0)
## @end example
##
## @item S
## @code{@var{S}(c,k)} is the mean class @math{c} service time at center
## @math{k}, @code{@var{S}(c,k) @geq{} 0}. For FCFS nodes, service times
## must be class-independent.
##
## @item V
## @code{@var{V}(c,k)} is the average number of visits of class @math{c}
## customers to center @math{k} (@code{@var{V}(c,k) @geq{} 0}).
##
## @item m
## @code{@var{m}(k)} is the number of servers at center @math{k}. Only
## single-server (@code{@var{m}(k)==1}) or IS (Infinite Server) nodes
## (@code{@var{m}(k)<1}) are supported. If omitted, each center
## is assumed to be of type @math{M/M/1}-FCFS. Queueing discipline for
## single-server nodes can be FCFS, PS or LCFS-PR.
##
## @end table
##
## @strong{OUTPUTS}
##
## @table @var
##
## @item U
## @code{@var{U}(c,k)} is class @math{c} utilization at center @math{k}.
##
## @item R
## @code{@var{R}(c,k)} is class @math{c} response time at center @math{k}.
##
## @item Q
## @code{@var{Q}(c,k)} is the average number of
## class @math{c} requests at center @math{k}.
##
## @item X
## @code{@var{X}(c,k)} is class @math{c} throughput at center @math{k}.
##
## @end table
##
## @seealso{qncmmva, qncm}
##
## @end deftypefn

## Author: Moreno Marzolla <marzolla(at)cs.unibo.it>
## Web: http://www.moreno.marzolla.name/

function [U R Q X] = qnmix( lambda, N, S, V, m )
  if ( nargin < 4 || nargin > 5 )
    print_usage();
  endif
  isvector(lambda) || \
      error( "lambda must be a vector" );
  lambda = lambda(:)';
  isvector(N) || \
      error( "N must be a vector" );
  N = N(:)';
  size_equal(lambda,N) || \
      error( "lambda and N must be of equal length" );
  ( !any( lambda>0 & N>0 ) ) || \
      error("A class cannot be open and closed at the same time. Check lambda and N" );
  ( all( lambda>0 | N>0 ) ) || \
      error( "A class cannot be neither open nor closed. Check lambda and N" );
  size_equal(S,V) || \
      error( "S and V must have the same size" );
  C = length(lambda); # number of classes
  K = columns(S); # number of service centers
  rows(S) == C || \
      error( "S must have %d rows", C );
  if ( nargin < 5 ) 
    m = ones(1,K);
  else
    isvector( m ) || \
        error( "m must be a vector" );
    m = m(:)';
    size_equal(lambda,m) || \
        error( "lambda and m must be of equal length" );
  endif
  all( m<=1 ) || \
      error( "This function supports single-server and delay centers only. Check m" );
  if ( !any(lambda>0) ) 
    warning( "qnmix(): There are no open classes. Using qncmmva()" );
    [U R Q X] = qncmmva( N, S, V, m );
    return;
  endif
  if ( !any(N>0) ) 
    warning( "qnmix(): There are no closed classes. Using qnom()" );
    [U R Q X] = qnom( lambda, S, V, m );
    return;
  endif

  D = S.*V; # service demands
  op = find( lambda>0 ); # indexes of open networks
  cl = find( N>0 ); # indexes of closed networks
  
  ## Initialize results
  U = R = Q = X = zeros(C,K);
  U(op,:) = diag( lambda(op) )* D(op,:); # U(c,:) = lambda(c)*D(c,:);
  Uo = sum(U,1); # Total utilization for open classes on service center k
  ## Build closed model to solve
  Ncl = N(cl);
  Scl = S;
  for c=cl
    Scl(c,:) = Scl(c,:) ./ (1-Uo);
  endfor
  Scl = Scl(cl,:); # select only rows for closed classes
  Vcl = V(cl,:);
  [Ucl Rcl Qcl Xcl] = qncmmva(Ncl, Scl, Vcl, m );
  ## Results for closed classes
  X(cl,:) = Xcl;
  Q(cl,:) = Qcl;
  R(cl,:) = Rcl;
  U(cl,:) = X(cl,:) .* D(cl,:);
  ## Results for open classes
  Qc = sum(Q(cl,:),1);
  i_single=find(m==1);
  i_multi=find(m<1);
  for c=op
    R(c,i_single) = S(c,i_single).*(1+Qc) ./ (1-Uo); # This is the Response time, _not_ the residence time
    R(c,i_multi) = S(c,i_multi);
  endfor
  Q(op,:) = (diag(lambda(op))*V(op,:)).*R(op,:); # Q(c,k) = lambda(c)*V(c,k)*R(c,k)
  ## The following is needed to avoid division by zero
  idx = false(size(X));
  idx(op,:) = ( S(op,:)>0 & V(op,:)>0 );
  X(idx) = U(idx) ./ S(idx);
endfunction
%!test
%! lambda = [1 0 0];
%! N = [1 1 1];
%! S = V = [1 1 1; 1 1 1; 1 1 1];
%! fail( "qnmix( lambda, N, S, V)", "same time");
%! N = [0 0 1];
%! fail( "qnmix( lambda, N, S, V)", "open nor closed" );
%! N = [0 1 2];
%! m = [ 1 1 2 ];
%! fail( "qnmix( lambda, N, S, V, m)", "single-server and delay" );
%! S = V = [1 1 1; 1 1 1];
%! fail( "qnmix( lambda, N, S, V)", "rows" );

%!test
%! # Example p. 148 Zahorjan et al.
%! lambda = [1 1/2 0 0];
%! N = [0 0 1 1];
%! V = [1 1; 1 1; 1 1; 1 1];
%! S = [1/4 1/6; 1/2 1; 1/2 1; 1 4/3];
%! [U R Q X] = qnmix(lambda, N, S, V );
%! assert( Q(3,1), 4/19, 1e-4 );
%! assert( Q(3,2), 15/19, 1e-4 );
%! assert( Q(4,1), 5/19, 1e-4 );
%! assert( Q(4,2), 14/19, 1e-4 );
%! assert( Q, R.*X, 1e-5 ); # Little's Law

%!test
%! # Example 8.6 p. 345 Bolch et al.
%! lambda = [0.5 0.25 0 0];
%! N = [0 0 1 1];
%! V = [2 1; 2.5 1.5; 1 0.5; 1 0.4];
%! S = [0.4 0.6; 0.8 1.6; 0.3 0.5; 0.5 0.8];
%! [U R Q X] = qnmix( lambda, N, S, V );
%! assert( U([1 2],:), [0.4 0.3; 0.5 0.6], 1e-3 );
%! assert( R([3 4],:), [4.829 6.951; 7.727 11.636], 1e-3 );
%! assert( Q([3 4],:), [0.582 0.418; 0.624 0.376], 1e-3 );
%! assert( Q([1 2],:), [8.822 5.383; 11.028 10.766], 1e-3 ); #FIXME
%! assert( R([1 2],:), [8.822 10.766; 17.645 28.710], 1e-3 );
%! assert( X(3,1)/V(3,1), 0.120, 1e-3 );
%! assert( X(4,1)/V(4,1), 0.081, 1e-3 );
%! assert( Q, R.*X, 1e-5 ); # Little's Law

%!test
%! ## example figure 10 p. 26 Schwetman, "Implementing the Mean Value
%! ## Analysis for the Solution of Queueing Network Models", Technical
%! ## Report CSD-TR-355, feb 15, 1982, Purdue University. 
%! S = [.25 0; .25 .10];
%! V = [1 0; 1 1];
%! lambda = [1 0];
%! N = [0 3];
%! [U R Q X] = qnmix( lambda, N, S, V );
%! assert( U(1,1), .25, 1e-3 );
%! assert( X(1,1), 1.0, 1e-3 );
%! assert( [R(1,1) R(2,1) R(2,2)], [1.201 0.885 0.135], 1e-3 );
%! assert( Q, R.*X, 1e-5 ); # Little's Law
