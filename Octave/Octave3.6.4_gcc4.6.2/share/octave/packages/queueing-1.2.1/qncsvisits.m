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
## @deftypefn {Function File} {@var{V} =} qncsvisits (@var{P})
## @deftypefnx {Function File} {@var{V} =} qncsvisits (@var{P}, @var{r})
##
## Compute the mean number of visits to the service centers of a
## single class, closed network with @math{K} service centers.
##
## @strong{INPUTS}
##
## @table @var
##
## @item P
## @code{@var{P}(i,j)} is the probability that a request which completed
## service at center @math{i} is routed to center @math{j}. For closed
## networks it must hold that @code{sum(@var{P},2)==1}. The routing
## graph must be strongly connected, meaning that each node must be
## reachable from every other node.
##
## @item r
## Index of the reference station, @math{r \in @{1, @dots{}, K@}};
## Default @code{@var{r}=1}. The traffic equations are solved by
## imposing the condition @code{@var{V}(r) = 1}. A request returning to
## the reference station completes its activity cycle.
##
## @end table
##
## @strong{OUTPUTS}
##
## @table @var
##
## @item V
## @code{@var{V}(i)} is the average number of visits to service center
## @math{i}, assuming center @math{r} as the reference station.
##
## @end table
## 
## @end deftypefn

## Author: Moreno Marzolla <marzolla(at)cs.unibo.it>
## Web: http://www.moreno.marzolla.name/

function V = qncsvisits( P, r )

  if ( nargin < 1 || nargin > 2 )
    print_usage();
  endif

  issquare(P) || \
      error("P must be a square matrix");

  [res err] = dtmcchkP(P);
  (res>0) || \
      error( "invalid transition probability matrix P" );

  K = rows(P);

  if ( nargin < 2 )
    r = 1;
  else
    isscalar(r) || \
	error("r must be a scalar");

    (r>=1 && r<=K) || \
	error("r must be an integer in the range 1 - %d",K);
  endif

  V = zeros(size(P));
  A = P-eye(K);
  b = zeros(1,K);
  A(:,r) = 0; A(r,r) = 1;
  b(r) = 1;
  V = b/A;
  ## Make sure that no negative values appear (sometimes, numerical
  ## errors produce tiny negative values instead of zeros)
  V = max(0,V);
endfunction
%!test
%! P = [-1 0; 0 0];
%! fail( "qncsvisits(P)", "invalid" );
%! P = [1 0; 0.5 0];
%! fail( "qncsvisits(P)", "invalid" );
%! P = [1 2 3; 1 2 3];
%! fail( "qncsvisits(P)", "square" );
%! P = [0 1; 1 0]; 
%! fail( "qncsvisits(P,0)", "range" );
%! fail( "qncsvisits(P,3)", "range" );

%!test
%!
%! ## Closed, single class network
%!
%! P = [0 0.3 0.7; 1 0 0; 1 0 0];
%! V = qncsvisits(P);
%! assert( V*P,V,1e-5 );
%! assert( V, [1 0.3 0.7], 1e-5 );

%!test
%!
%! ## Test tolerance of the qncsvisits() function. 
%! ## This test builds transition probability matrices and tries
%! ## to compute the visit counts on them. 
%!
%! for k=[5, 10, 20, 50]
%!   P = reshape(1:k^2, k, k);
%!   P = P ./ repmat(sum(P,2),1,k);
%!   V = qncsvisits(P);
%!   assert( V*P, V, 1e-5 );
%! endfor

%!demo
%! P = [0 0.3 0.7; \
%!      1 0   0  ; \
%!      1 0   0  ];
%! V = qncsvisits(P)

