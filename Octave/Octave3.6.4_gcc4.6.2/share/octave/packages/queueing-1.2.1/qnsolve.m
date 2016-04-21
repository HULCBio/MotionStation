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
## @deftypefn {Function File} {[@var{U}, @var{R}, @var{Q}, @var{X}] =} qnsolve (@var{"closed"}, @var{N}, @var{QQ}, @var{V})
## @deftypefnx {Function File} {[@var{U}, @var{R}, @var{Q}, @var{X}] =} qnsolve (@var{"closed"}, @var{N}, @var{QQ}, @var{V}, @var{Z})
## @deftypefnx {Function File} {[@var{U}, @var{R}, @var{Q}, @var{X}] =} qnsolve (@var{"open"}, @var{lambda}, @var{QQ}, @var{V})
## @deftypefnx {Function File} {[@var{U}, @var{R}, @var{Q}, @var{X}] =} qnsolve (@var{"mixed"}, @var{lambda}, @var{N}, @var{QQ}, @var{V})
##
## High-level function for analyzing QN models.
##
## @itemize
##
## @item For @strong{closed} networks, the following server types are
## supported: @math{M/M/m}--FCFS, @math{-/G/\infty}, @math{-/G/1}--LCFS-PR,
## @math{-/G/1}--PS and load-dependent variants.
##
## @item For @strong{open} networks, the following server types are supported:
## @math{M/M/m}--FCFS, @math{-/G/\infty} and @math{-/G/1}--PS. General
## load-dependent nodes are @emph{not} supported. Multiclass open networks
## do not support multiple server @math{M/M/m} nodes, but only
## single server @math{M/M/1}--FCFS.
##
## @item For @strong{mixed} networks, the following server types are supported:
## @math{M/M/1}--FCFS, @math{-/G/\infty} and @math{-/G/1}--PS. General
## load-dependent nodes are @emph{not} supported.
##
## @end itemize
##
## @strong{INPUTS}
##
## @table @var
##
## @item N
## Number of requests in the system for closed networks. For
## single-class networks, @var{N} must be a scalar. For multiclass
## networks, @code{@var{N}(c)} is the population size of closed class
## @math{c}.
##
## @item lambda
## External arrival rate (scalar) for open networks. For single-class
## networks, @var{lambda} must be a scalar. For multiclass networks,
## @code{@var{lambda}(c)} is the class @math{c} overall arrival rate.
##
## @item QQ
## List of queues in the network. This must be a cell array 
## with @math{N} elements, such that @code{@var{QQ}@{i@}} is
## a struct produced by the @code{qnmknode} function.
##
## @item Z
## External delay ("think time") for closed networks. Default 0.
##
## @end table
##
## @strong{OUTPUTS}
##
## @table @var
##
## @item U
## If @math{i} is a FCFS node, then @code{@var{U}(i)} is the utilization
## of service center @math{i}. If @math{i} is an IS node, then
## @code{@var{U}(i)} is the @emph{traffic intensity} defined as
## @code{@var{X}(i)*@var{S}(i)}.
##
## @item R
## @code{@var{R}(i)} is the average response time of service center @math{i}.
##
## @item Q
## @code{@var{Q}(i)} is the average number of customers in service center
## @math{i}.
##
## @item X
## @code{@var{X}(i)} is the throughput of service center @math{i}.
##
## @end table
##
## Note that for multiclass networks, the computed results are per-class
## utilization, response time, number of customers and throughput:
## @code{@var{U}(c,k)}, @code{@var{R}(c,k)}, @code{@var{Q}(c,k)},
## @code{@var{X}(c,k)},
##
## @end deftypefn

## Author: Moreno Marzolla <marzolla(at)cs.unibo.it>
## Web: http://www.moreno.marzolla.name/

function [U R Q X] = qnsolve( network_type, varargin )
  if ( nargin < 2 )
    print_usage();
  endif

  ischar(network_type) || \
      error("First parameter must be a string");

  network_type = tolower(network_type);

  if ( strcmp(network_type, "open" ) )
    [U R Q X] = __qnsolve_open( varargin{:} );
  elseif ( strcmp(network_type, "closed" ) )
    [U R Q X] = __qnsolve_closed( varargin{:} );
  elseif (strcmp(network_type, "mixed" ) )
    [U R Q X] = __qnsolve_mixed( varargin{:} );
  else
    error( "Invalid network type %s: must be one of \"open\", \"closed\" or \"mixed\"", network_type );
  endif
endfunction

##############################################################################
## Dispatcher function for open networks
function [U R Q X] = __qnsolve_open( lambda, varargin )
  if ( isscalar(lambda) )
    [U R Q X] = __qnsolve_open_single( lambda, varargin{:} );
  else
    [U R Q X] = __qnsolve_open_multi( lambda, varargin{:} );
  endif
endfunction

##############################################################################
## Worker function for open, single class networks
function [U R Q X] = __qnsolve_open_single( lambda, QQ, V )

  if ( nargin != 3 )
    print_usage();
  endif

  ( isscalar(lambda) && (lambda>0) ) || \
      error( "lambda must be a scalar > 0" );
  
  iscell(QQ) || \
      error( "QQ must be a cell array" );

  N = length(QQ);

  ( isvector(V) && length(V) == N ) || \
      error( "V must be a vector of length %d", N );

  V = V(:); # make V a row vector
  all(V>=0) || \
      error( "V must be >= 0" );

  ## Initialize vectors
  S = zeros(size(V));
  m = ones(size(V));
  for i=1:N
    QQ{i}.c == 1 || \
	error( "Multiclass networks are not supported by this function" );
    S(i) = QQ{i}.S;
    if __is_li(QQ{i})
      ; # nothing to do
    elseif __is_multi(QQ{i})
      m(i) = QQ{i}.m;
    elseif __is_is(QQ{i})
      m(i) = -1;
    else
      error( "Unsupported type \"%s\" for node %d", QQ{i}.node, i );
    endif
  endfor

  [U R Q X] = qnos( lambda, S, V, m );
  __prettyprint( 0, lambda, QQ, V, U, R, Q, X );
endfunction


##############################################################################
## Worker function for open, multiclass networks
function [U R Q X] = __qnsolve_open_multi( lambda, QQ, V )
  if ( nargin != 3 )
    print_usage();
  endif
  isvector(lambda) && all(lambda > 0) || \
      error( "lambda must be a vector >0" );
  lambda = lambda(:)'; # make lambda a row vector
  iscell(QQ) || \
      error( "QQ must be a cell array" );
  C = length(lambda);
  K = length(QQ);
  [C,K] == size(V) || \
      error( "V size mismatch" );
  all( all( V>= 0 ) ) || \
      error( "V must be >= 0 " );

  S = zeros(C,K);
  m = ones(1,K);
  for i=1:K
    QQ{i}.c == C || \
	error( "Wrong number of classes for center %d (is %d, should be %d)", i, QQ{i}.c, C );
    S(:,i) = QQ{i}.S(:);
    if __is_li(QQ{i})
      ; # nothing to do
    elseif __is_is(QQ{i})
      m(i) = -1;
    else
      error( "Unsupported type \"%s\" for node %d", QQ{i}.node, i );
    endif  
  endfor

  [U R Q X] = qnom( lambda, S, V, m );
  __prettyprint( 0, lambda, QQ, V, U, R, Q, X );
endfunction


##############################################################################
## Dispatcher function for closed networks
function [U R Q X] = __qnsolve_closed( N, varargin )
  if ( isscalar(N) )
    [U R Q X] = __qnsolve_closed_single( N, varargin{:} );
  else
    [U R Q X] = __qnsolve_closed_multi( N, varargin{:} );
  endif
endfunction


##############################################################################
## Worker function for closed, single-class networks
function [U R Q X] = __qnsolve_closed_single( N, QQ, V, Z )

  if ( nargin < 3 || nargin > 4 )
    error();
  endif

  isscalar(N) || \
      error( "Multiclass networks are not supported by this function" );

  iscell(QQ) || \
      error( "QQ must be a cell array" );

  if ( nargin < 4 ) 
    Z = 0;
  else
    isscalar(Z) && Z >= 0 || \
        error( "Z must be >= 0" );
  endif

  K = length(QQ);
  
  ( isvector(V) && length(V) == K ) || \
      error( "V must be a vector of length %d", K );

  found_ld = false;
  for k=1:K
    if ( __is_ld(QQ{k}) )
      found_ld = true;
      break;
    endif
  endfor

  if ( found_ld )
    S = zeros(K, N);
    for k=1:K
      ( QQ{k}.c == 1 ) || \
	  error( "Multiclass networks are not supported by this function" );
      if __is_li(QQ{k})
	S(k,:) = QQ{k}.S;
      elseif __is_multi(QQ{k})
	S(k,:) = QQ{k}.S ./ min(1:N,QQ{k}.m);
      elseif __is_is(QQ{k})
	S(k,:) = QQ{k}.S ./ (1:N);
      elseif __is_ld(QQ{k})
	S(k,:) = QQ{k}.S;
      else
	error( "Unsupported type \"%s\" for node %d", QQ{k}.node, k );
      endif      
    endfor
    [U R Q X] = qncsmvald(N, S, V, Z);
  else
    S = zeros(1,K);
    m = ones(1,K);
    for k=1:K
      ( QQ{k}.c == 1 ) || \
	  error( "Multiclass networks are not supported by this function" );
      S(k) = QQ{k}.S;
      if __is_li(QQ{k})
	# nothing to do
      elseif __is_multi(QQ{k})
	m(k) = QQ{k}.m;
      elseif __is_is(QQ{k})
	m(k) = -1;
      else
	error( "Unsupported type \"%s\" for node %d", QQ{k}.node, k );
      endif
    endfor
    [U R Q X] = qncsmva(N, S, V, m, Z);
  endif

#{

  ## TODO: remove this

  ## Initialize vectors
  i_single = i_multi = i_delay = i_ld = [];
  for i=1:K
    ( QQ{i}.c == 1 ) || \
	error( "Multiclass networks are not supported by this function" );
    if __is_li(QQ{i})
      i_single = [i_single i];
    elseif __is_multi(QQ{i})
      i_multi = [i_multi i];
    elseif __is_is(QQ{i})
      i_delay = [i_delay i];
    elseif __is_ld(QQ{i})
      i_ld = [i_ld i];
    else
      error( "Unsupported type \"%s\" for node %d", QQ{i}.node, i );
    endif
  endfor
  p = cell( 1, K );

  for i=i_multi
    p{i} = zeros(1,QQ{i}.m+1); # p(i,j+1) is the probability that there are j jobs at server i
    p{i}(1) = 1;
  endfor

  for i=i_ld
    p{i} = zeros(1,N+1); # p(i,j+1) is the probability that there are j jobs at server i
    p{i}(1) = 1;
  endfor

  U = R = Q = X = zeros( 1, K );
  ## Trivial case of empty population: just return all zeros
  if ( N == 0 )
    return;
  endif
  X_s = 0;              # System throughput

  ## Main MVA loop, iterates over the population size
  for n=1:N 

    ## Single server nodes
    for i=i_single
      R(i) = QQ{i}.S .* (1 + Q(i)); 
    endfor

    ## Multiple server nodes
    for i=i_multi
      j=0:QQ{i}.m-2;
      R(i) = QQ{i}.S / QQ{i}.m * (1+Q(i)+dot( QQ{i}.m-j-1, p{i}( 1+j ) ) );
    endfor

    ## General load-dependent nodes
    for i=i_ld
      j=1:n;
      R(i) = sum( j.*QQ{i}.S(j).*p{i}(j) );
    endfor
    
    ## Delay centers (IS)
    for i=i_delay
      R(i) = QQ{i}.S;
    endfor

    R_s = dot( V, R ); # System response time
    X_s = n / ( Z + R_s ); # System Throughput
    Q = X_s * ( V .* R );

    ## prepare for next iteration
    lambda_i = V * X_s; # lambda_i(i) is the node i throughput

    ## Update probabilities for multiple server nodes
    for i=i_multi
      j=1:QQ{i}.m-1; # range
      p{i}(j+1) = lambda_i(i) .* QQ{i}.S ./ min( j,QQ{i}.m ) .* p{i}(j);
      p{i}(1) = 1 - 1/QQ{i}.m * ...
          (V(i)*QQ{i}.S*X_s + dot( QQ{i}.m-j, p{i}(j+1)) );
    endfor

    ## Update probabilities for load-dependent nodes
    for i=i_ld
      j=1:n;
      p{i}(1+j) = X_s * QQ{i}.S(j) .* p{i}(j) * V(i);      
      p{i}(1) = 1-sum(p{i}(1+j));
    endfor    

  endfor
  X = X_s * V; # Service centers throughput

  ## Single server or IS nodes
  for i=[i_single i_delay]
    U(i) = X(i) .* QQ{i}.S;
  endfor

  ## Multiple server nodes
  for i=i_multi
    U(i) = X(i) .* QQ{i}.S ./ QQ{i}.m;
  endfor

  ## General load-dependent nodes
  for i=i_ld
    U(i) = 1-p{i}(1);
  endfor
#}
  __prettyprint( N, 0, QQ, V, U, R, Q, X );
endfunction

##############################################################################
## Worker function for closed, multi-class networks
function [U R Q X] = __qnsolve_closed_multi( N, QQ, V, Z )

  if ( nargin < 3 || nargin > 4 )
    print_usage();
  endif

  isvector(N) && all( N>0 ) || \
      error( "N must be >0" );

  iscell(QQ) || \
      error( "QQ must be a cell array" );

  C = length(N); ## Number of classes
  K = length(QQ); ## Number of service centers
  size(V) == [C,K] || \
      error( "V size mismatch" );

  if ( nargin < 4 )
    Z = zeros(1,C);
  else
    isvector(Z) && length(Z) == C || \
	error( "Z size mismatch" );
  endif

  ## Check consistence of parameters
  all( all( V >= 0 ) ) || \
      error( "V must be >=0" );

  ## Initialize vectors
  i_single = i_multi = i_delay = i_ld = [];
  S = zeros(C,K);
  for i=1:K
    ( QQ{i}.c == C ) || \
	error( "Service center %d has wrong number of classes (is %d, should be %d)", i, QQ{i}.c, C );

    if __is_li(QQ{i})
      i_single = [i_single i];
      ( !strcmpi( QQ{i}.node, "m/m/m-fcfs" ) || all( QQ{i}.S(1) == QQ{i}.S )) || \
	  error( "Service times at FIFO node %d are not class-independent", i );
    elseif __is_multi(QQ{i})
      i_multi = [i_multi i];
    elseif __is_is(QQ{i})
      i_delay = [i_delay i];
    elseif __is_ld(QQ{i})
      columns( QQ{i}.S ) == sum(N) || \
	  error( "Load-dependent center %d has insufficient data (is %d, should be %d", i, columns(QQ{i}.S), sum(N) );
      i_ld = [i_ld i];
    else
      error( "Unknown or unsupported type \"%s\" for node %d", QQ{i}.node, i );
    endif
  endfor

  ## Initialize results
  U = R = zeros( C, K );
  X = zeros( 1, C );
  Q_next = Q = sparse( prod(N+1),K );
  p = cell(1,K);
  for k=i_multi
    ## p{i}(j+1,k+1) is the probability to have j jobs at node i
    ## where the network is in state k
    p{k} = zeros( QQ{k}.m+1,prod(N+1) );
    p{k}(1,__get_idx( N, 0*N )) = 1;
  endfor

  for k=i_ld
    ## p{i}(j+1,k+1) is the probability to have j jobs at node i
    ## where the network is in state k
    p{k} = zeros( columns(QQ{k}.S )+1, prod(N+1) );
    p{k}(1,__get_idx( N, 0*N )) = 1;
  endfor
  
  ## Main loop
  for n=1:sum(N)
    feasible_set = qncmpopmix( n, N );
    for nn=1:rows(feasible_set)
      n_bar = feasible_set(nn,:);
      for c=1:C
	if ( n_bar(c) > 0 )

	  ## single server nodes
          for k=i_single
            n_bar_c = __minusonec(n_bar,c);
            idx = __get_idx( N, n_bar_c );
            R(c,k) = QQ{k}.S(c)*(1 + Q( idx, k ) );  
            ## for FCFS nodes with class-dependent service times,
            ## it is possible to use the following approximation
            ## (p. 469 Bolch et al.)
            ##
            ## R(c,k) = S(c,k) + sum( S(:,k) * Q(idx(:), k) );
	  endfor
	  
	  ## multi server nodes
	  for k=i_multi
            n_bar_c = __minusonec(n_bar,c);
            idx = __get_idx( N, n_bar_c );
            j=0:QQ{k}.m-2; # range
            R(c,k) = QQ{k}.S(c)/QQ{k}.m*(1 + Q( idx, k ) + ...
					 dot(QQ{k}.m-j-1,p{k}(j+1,idx) ) );
	  endfor

	  ## General load-dependent nodes
	  for k=i_ld
            n_bar_c = __minusonec(n_bar,c);
            idx = __get_idx( N, n_bar_c );
            j=1:sum(n_bar); # range
            R(c,k) = sum( j .* QQ{k}.S(c,j) .* p{k}(j,idx)' );
	  endfor
	endif

	## delay centers
	for k=i_delay
          R(c,k) = QQ{k}.S(c);
        endfor
 
      endfor # c
      X = n_bar ./ ( Z .+ dot(R,V,2)' ); # X(c) = N(c) / ( Z(c) + sum_k R(c,k) * V(c,k) )

      idx = __get_idx( N, n_bar );
      ## Q_k = sum_c X(c) * R(c,k)
      for k=1:K
        Q_next( idx, k ) = dot( X, R(:,k) .* V(:,k) );
      endfor

      ## Adjust probabilities for multiple server nodes
      for k=i_multi
        s=0; # it is actually a vector
        j=1:QQ{k}.m-1;
        for r=find(n_bar>0) # I don't know how to vectorize this
          ii = __minusonec(n_bar,r);
          s+=QQ{k}.S(r)*V(r,k)*X(r)*p{k}(j,__get_idx(N,ii));
        endfor
        p{k}(j+1,idx) = s./j;
        p{k}(1,idx) = 1-1/QQ{k}.m*(sum( QQ{k}.S(:) .* V(:,k) .* X(:) ) + ...
                                   dot( QQ{k}.m-j, p{k}(j+1,idx) ) );
      endfor

      ## Adjust probabilities for general load-dependent server nodes
      for k=i_ld
        s=0; # it is actually a vector
        j=1:sum(n_bar);
        for r=find(n_bar>0)
          ii = __minusonec(n_bar,r);
          s+=QQ{k}.S(r,sum(n_bar))*V(r,k)*X(r)*p{k}(j,__get_idx(N,ii));
        endfor
        p{k}(j+1,idx) = s;
        p{k}(1,idx) = 1-sum(p{k}(1+j,idx));	  
      endfor
    endfor
    Q = Q_next;
    Q_next = sparse( prod(N+1), K );
  endfor
  for k=1:K
    if __is_ld(QQ{k})
      U(:,k) = 1-p{k}(1, __get_idx(N,N));
    else
      U(:,k) = X(:) .* QQ{k}.S(:) .* V(:,k); # U(c,k) = X(c)*D(c,k)
    endif
  endfor
  Q = (diag(X)*R).*V; # dmult(X,R).*V;
  X = diag(X)*V; # dmult(X,V);
endfunction

##############################################################################
## Compute the linear index corresponding to vector i from a population
## of N.
function idx = __get_idx( N, i )
  i_cell = num2cell( i+1 );
  idx = sub2ind( N+1, i_cell{:} );
endfunction

##############################################################################
## Given an input vector n, returns an output vector r which is equal to
## n except that the element at the c-th position is decreased by one:
## r(c) = n(c)-1. Warning: no check is made on the parameters
function r = __minusonec( n, c )
  r = n; r(c) -= 1;
endfunction


##############################################################################
## Worker function for mixed networks. This function delegates to qnmix
function [U R Q X] = __qnsolve_mixed( lambda, N, QQ, V )
  if ( nargin != 4 )
    print_usage();
  endif
  ( isvector(lambda) && isvector(N) && size_equal(lambda,N) ) || \
      error( "lambda and N must be vectors of the same size" );
  ( iscell(QQ) && length(QQ) == length(lambda) ) || \
      error( "QQ size mismatch (is %d, should be %d)", length(QQ), length(lambda) );

  C = length(lambda); # number of classes
  K = length(QQ); # number of service centers
  S = zeros(C,K);
  m = ones(1,K);
  ## fill S matrix
  for k=1:K
    if __is_ld(QQ{k})
      error( "General load-dependent service center %d is not supported", k );
    elseif __is_is(QQ{k})
      m(k) = -1;
    else
      m(k) = QQ{k}.m;
    endif
    S(:,k) = QQ{k}.S;
  endfor
  [U R Q X] = qnmix( lambda, N, S, V, m );
  __prettyprint( N, lambda, QQ, V, U, R, Q, X );
endfunction

##############################################################################
## return true iff Q is an infinite server (IS) node
function result = __is_is( Q )
  result = strcmp(Q.node, "-/g/inf" );
endfunction

##############################################################################
## return true iff Q is a multi-server FIFO node
function result = __is_multi( Q )
  result =  (strcmp(Q.node, "m/m/m-fcfs") && Q.m>1);
endfunction

##############################################################################
## return true iff Q is a single-server, load-dependent node
function result = __is_ld( Q )
  result = ( (strcmp(Q.node, "m/m/m-fcfs") || \
	      strcmp(Q.node, "-/g/1-lcfs-pr") || \
	      strcmp(Q.node, "-/g/1-ps" ) ) && \
	    columns( Q.S ) > 1 );
endfunction

##############################################################################
## return ture iff Q is a single-server, load-independent node
function result = __is_li( Q )
  result = ((Q.m==1) && (1 == columns( Q.S )) && !strcmp( Q.node, "-/g/inf" ) );
endfunction

##############################################################################
## This function is used to "pretty-print" a solved network. Used for
## debugging
function __prettyprint( N, lambda, QQ, V, U, R, Q, X )
  return; ## immediately return
  [errorcode, N, lambda] = common_size( N, lambda );
  if ( errorcode)
    error( "N and lambda are of incompatible size" );
  endif
  ( isvector(N) && isvector(lambda) && size_equal(lambda,N) ) || \
      error( "N and lambda must be vector of the same length" );
  C = length(N);  
  K = length(QQ); # number of service centers

  [C,K] == size(V) || \
      error( "V size mismatch" );
  [C,K] == size(U) || \
      error( "U size mismatch" );
  [C,K] == size(R) || \
      error( "R size mismatch" );
  [C,K] == size(Q) || \
      error( "Q size mismatch" );
  [C,K] == size(X) || \
      error( "X size mismatch" );

  for c=1:C     
    printf("\n");
    printf("=== CLASS %d ===\n", c );
    if ( N(c)>0 )
      printf("Type: CLOSED\nPopulation: %d\n", N(c))
    else
      printf("Type: OPEN\nRequests arrival rate: %6.2f\n", lambda(c))
    endif
    printf("\n");
    printf("+---+---------------+---+------+------+------+------+------+------+\n");
    printf("| i |     Node type | m | S(i) | V(i) | U(i) | R(i) | Q(i) | X(i) |\n");
    printf("+---+---------------+---+------+------+------+------+------+------+\n");
    for i=1:K
      if ( isscalar(QQ{i}.S(c)) )
	serv = sprintf("%6.2f",QQ{i}.S(c));
      else
	serv = "LD";
      endif
      printf("|%3d|%-33s|      |      |      |      |\n", i, QQ{i}.comment);
      printf("|   |%15s|%3d|%6s|%6.2f|%6.4f|%6.2f|%6.2f|%6.2f|\n",
	     QQ{i}.node, QQ{i}.m, serv, V(c,i), U(c,i), R(c,i), Q(c,i), X(c,i) ); 
      
    endfor
    printf("+---+---------------+---+------+------+------+------+------+------+\n");
    printf("|               THIS CLASS STATISTICS | ---- |%6.2f|%6.2f|%6.2f|\n",
	   dot(R(c,:),V(c,:)), sum(Q(c,:)), X(c,1)/V(c,1) );
    printf("+---+---------------+---+------+------+------+------+------+------+\n\n");
  endfor
endfunction

%!test
%! # Example 8.7 p. 349 Bolch et al.
%! N = 3;
%! Q1 = qnmknode( "m/m/m-fcfs", .5, 2 );
%! Q2 = qnmknode( "m/m/m-fcfs", 1/1.667 );
%! Q3 = qnmknode( "m/m/m-fcfs", 1/1.25 );
%! Q4 = qnmknode( "m/m/m-fcfs", 1./[1 2 3] );
%! V = [ 1 .5 .5 1 ];
%! [U R Q X] = qnsolve("closed",N, { Q1, Q2, Q3, Q4 }, V);
%! assert( Q, [0.624 0.473 0.686 1.217], 1e-3 );
%! assert( R, [0.512 0.776 1.127 1], 1e-3 );

%!test
%! # Example 8.7 p. 349 Bolch et al.
%! N = 3;
%! Q1 = qnmknode( "m/m/m-fcfs", 1/2, 2 );
%! Q2 = qnmknode( "m/m/m-fcfs", 1/1.667 );
%! Q3 = qnmknode( "m/m/m-fcfs", 1/1.25 );
%! Q4 = qnmknode( "-/g/inf", 1 );
%! V = [ 1 .5 .5 1 ];
%! [U R Q X] = qnsolve("closed",N, { Q1, Q2, Q3, Q4 }, V);
%! assert( Q, [0.624 0.473 0.686 1.217], 1e-3 );
%! assert( R, [0.512 0.776 1.127 1], 1e-3 );

%!test
%! # Example 8.4 p. 333 Bolch et al.
%! N = 3;
%! Q1 = qnmknode( "m/m/m-fcfs", .5, 2 );
%! Q2 = qnmknode( "m/m/m-fcfs", .6 );
%! Q3 = qnmknode( "m/m/m-fcfs", .8 );
%! Q4 = qnmknode( "-/g/inf", 1 );
%! V = [ 1 .5 .5 1 ];
%! [U R Q X] = qnsolve("closed",N, { Q1, Q2, Q3, Q4 }, V);
%! assert( U(1:3), [.304 .365 .487], 1e-3 );
%! assert( X, [1.218 0.609 0.609 1.218], 1e-3 );

%!test
%! # Same as above, with center 1 replaced with a load-dependent service center
%! N = 3;
%! Q1 = qnmknode( "m/m/m-fcfs", [.5 .25 .25] );
%! Q2 = qnmknode( "m/m/m-fcfs", .6 );
%! Q3 = qnmknode( "m/m/m-fcfs", .8 );
%! Q4 = qnmknode( "m/m/m-fcfs", [1 1/2 1/3] );
%! V = [ 1 .5 .5 1 ];
%! [U R Q X] = qnsolve("closed",N, { Q1, Q2, Q3, Q4 }, V);
%! assert( U(2:3), [.365 .487], 1e-3 ); ## NOTE: Utilization U(1) is computed differently from M/M/m nodes and load-dependent M/M/1 nodes
%! assert( X, [1.218 0.609 0.609 1.218], 1e-3 );

%!test
%! # Example 7.4 p. 287 Bolch et al.
%! QQ = { qnmknode( "m/m/m-fcfs", 0.04 ), \
%!        qnmknode( "m/m/m-fcfs", 0.03 ), \
%!        qnmknode( "m/m/m-fcfs", 0.06 ), \
%!        qnmknode( "m/m/m-fcfs", 0.05 ) };
%! P = [ 0 0.5 0.5 0; 1 0 0 0; 0.6 0 0 0; 1 0 0 0 ];
%! lambda = [0 0 0 4];
%! [U R Q X] = qnsolve("open", sum(lambda), QQ, qnosvisits(P,lambda) );
%! assert( X, [20 10 10 4], 1e-4 );
%! assert( U, [0.8 0.3 0.6 0.2], 1e-2 );
%! assert( R, [0.2 0.043 0.15 0.0625], 1e-3 );
%! assert( Q, [4, 0.429 1.5 0.25], 1e-3 );

%!test
%! V = [1 1; 1 1];
%! Q1 = qnmknode( "m/m/m-fcfs", [1;2] );
%! Q2 = qnmknode( "m/m/m-fcfs", [3;4] );
%! lambda = [3/19 2/19];
%! [U R Q] = qnsolve("open", lambda, { Q1, Q2 }, V);
%! assert( U(1,1), 3/19, 1e-6 );
%! assert( U(2,1), 4/19, 1e-6 );
%! assert( R(1,1), 19/12, 1e-6 );
%! assert( R(1,2), 57/2, 1e-6 );
%! assert( Q(1,1), .25, 1e-6 );

## Example 9.5 p. 337, Bolch et al.
%!test
%! QQ = { qnmknode( "m/m/m-fcfs", [0.2; 0.2], 2 ), \
%!        qnmknode( "-/g/1-ps", [0.4; 0.6] ), \
%!        qnmknode( "-/g/inf", [1; 2] ) };
%! V = [ 1 0.6 0.4; 1 0.3 0.7 ];
%! N = [ 2 1 ];
%! [U R Q X] = qnsolve( "closed", N, QQ, V );
%! assert( Q, [ 0.428 0.726 0.845; 0.108 0.158 0.734 ], 1e-3 );
%! assert( X(1,1), 2.113, 1e-3 ); # CHECK
%! assert( X(2,1), 0.524, 1e-3 ); # CHECK
%! assert( all( all(U(:,[1,2])<=1) ) );

## Same as above, but with general load-dependent centers
%!test
%! QQ = { qnmknode( "m/m/m-fcfs", [0.2 0.1 0.1; 0.2 0.1 0.1] ), \
%!        qnmknode( "-/g/1-ps", [0.4; 0.6] ), \
%!        qnmknode( "-/g/inf", [1; 2] ) };
%! V = [ 1 0.6 0.4; 1 0.3 0.7 ];
%! N = [ 2 1 ];
%! [U R Q X] = qnsolve( "closed", N, QQ, V );
%! assert( Q, [ 0.428 0.726 0.845; 0.108 0.158 0.734 ], 1e-3 );
%! assert( X(1,1), 2.113, 1e-3 ); # CHECK
%! assert( X(2,1), 0.524, 1e-3 ); # CHECK
%! assert( all( all(U(:,[1,2])<=1) ) );

%!test
%! # example p. 26 Schwetman
%! QQ = { qnmknode( "m/m/m-fcfs", [.25; .25] ),
%!        qnmknode( "-/g/1-ps", [0; .1] ) };
%! V = [1 0; 1 1];
%! lambda = [1 0];
%! N = [0 3];
%! [U R Q X] = qnsolve( "mixed", lambda, N, QQ, V );
%! assert( U(1,1), .25, 1e-3 );
%! assert( X(1,1), 1.0, 1e-3 );
%! assert( [R(1,1) R(2,1) R(2,2)], [1.201 0.885 0.135], 1e-3 );

%!demo
%! QQ = { qnmknode( "m/m/m-fcfs", [0.2 0.1 0.1; 0.2 0.1 0.1] ), \
%!        qnmknode( "-/g/1-ps", [0.4; 0.6] ), \
%!        qnmknode( "-/g/inf", [1; 2] ) };
%! V = [ 1 0.6 0.4; \
%!       1 0.3 0.7 ];
%! N = [ 2 1 ];
%! [U R Q X] = qnsolve( "closed", N, QQ, V );
