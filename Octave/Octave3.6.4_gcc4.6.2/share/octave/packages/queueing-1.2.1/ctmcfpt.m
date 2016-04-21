## Copyright (C) 2011, 2012 Moreno Marzolla
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
## @deftypefn {Function File} {@var{M} =} ctmcfpt (@var{Q})
## @deftypefnx {Function File} {@var{m} =} ctmcfpt (@var{Q}, @var{i}, @var{j})
##
## @cindex first passage times, CTMC
## @cindex CTMC
## @cindex continuous time Markov chain
## @cindex Markov chain, continuous time
##
## Compute mean first passage times for an irreducible continuous-time
## Markov chain.
##
## @strong{INPUTS}
##
## @table @var
##
## @item Q
## Infinitesimal generator matrix. @var{Q} is a @math{N \times N} square
## matrix where @code{@var{Q}(i,j)} is the transition rate from state
## @math{i} to state @math{j}, for @math{1 @leq{} i \neq j @leq{} N}.
## Transition rates must be nonnegative, and @math{\sum_{j=1}^N Q_{i j} = 0}
##
## @item i
## Initial state.
##
## @item j
## Destination state.
##
## @end table
##
## @strong{OUTPUTS}
##
## @table @var
##
## @item M
## @code{@var{M}(i,j)} is the average time before state
## @var{j} is visited for the first time, starting from state @var{i}.
## We set @code{@var{M}(i,i) = 0}.
##
## @item m
## @var{m} is the average time before state @var{j} is visited for the first 
## time, starting from state @var{i}.
##
## @end table
##
## @seealso{dtmcfpt}
##
## @end deftypefn

## Author: Moreno Marzolla <marzolla(at)cs.unibo.it>
## Web: http://www.moreno.marzolla.name/

function result = ctmcfpt( Q, i, j )

  persistent epsilon = 10*eps;

  if ( nargin != 1 && nargin != 3 )
    print_usage();
  endif

  [N err] = ctmcchkQ(Q);
  
  (N>0) || \
      error(err);

  if ( nargin == 1 ) 
    result = zeros(N,N);
    for j=1:N
      QQ = Q;
      QQ(j,:) = 0; # make state j absorbing
      for i=1:N
	p0 = zeros(1,N); p0(i) = 1;
	result(i,j) = ctmcmtta(QQ,p0);
      endfor
    endfor
  else
    (isscalar(i) && i>=1 && j<=N) || error("i must be an integer in the range 1..%d", N);
    (isvector(j) && all(j>=1) && all(j<=N)) || error("j must be an integer or vector with elements in 1..%d", N);
    j = j(:)'; # make j a row vector
    Q(j,:) = 0; # make state(s) j absorbing
    p0 = zeros(1,N); p0(i) = 1;
    result = ctmcmtta(Q,p0);    
  endif
endfunction
%!demo
%! Q = [ -1.0  0.9  0.1; \
%!        0.1 -1.0  0.9; \
%!        0.9  0.1 -1.0 ];
%! M = ctmcfpt(Q)
%! m = ctmcfpt(Q,1,3)

%!test
%! N = 10;
%! Q = reshape(1:N^2,N,N);
%! Q(1:N+1:end) = 0;
%! Q -= diag(sum(Q,2));
%! M = ctmcfpt(Q);
%! assert( all(diag(M) < 10*eps) );
