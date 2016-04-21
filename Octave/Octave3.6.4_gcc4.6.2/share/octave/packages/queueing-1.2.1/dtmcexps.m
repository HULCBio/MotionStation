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
## @deftypefn {Function File} {@var{L} =} dtmcexps (@var{P}, @var{n}, @var{p0})
## @deftypefnx {Function File} {@var{L} =} dtmcexps (@var{P}, @var{p0})
##
## @cindex expected sojourn times, DTMC
## @cindex DTMC
## @cindex discrete time Markov chain
## @cindex Markov chain, discrete time
##
## Compute the expected number of visits to each state during the first
## @var{n} transitions, or until abrosption.
##
## @strong{INPUTS}
##
## @table @var
##
## @item P
## @math{N \times N} transition probability matrix.
##
## @item n
## Number of steps during which the expected number of visits are
## computed (@math{@var{n} @geq{} 0}). If @code{@var{n}=0}, returns
## @var{p0}. If @code{@var{n} > 0}, returns the expected number of
## visits after exactly @var{n} transitions.
##
## @item p0
## Initial state occupancy probability.
##
## @end table
##
## @strong{OUTPUTS}
##
## @table @var
##
## @item L
## When called with two arguments, @code{@var{L}(i)} is the expected
## number of visits to transient state @math{i} before absorption. When
## called with three arguments, @code{@var{L}(i)} is the expected number
## of visits to state @math{i} during the first @var{n} transitions,
## given initial occupancy probability @var{p0}.
##
## @end table
##
## @seealso{ctmcexps}
##
## @end deftypefn

## Author: Moreno Marzolla <marzolla(at)cs.unibo.it>
## Web: http://www.moreno.marzolla.name/

function L = dtmcexps ( P, varargin )

  persistent epsilon = 10*eps;

  if ( nargin < 2 || nargin > 3 )
    print_usage();
  endif

  [K err] = dtmcchkP(P);

  (K>0) || \
      error(err);

  if ( nargin == 2 )
    p0 = varargin{1};
  else
    n = varargin{1};
    p0 = varargin{2};
  endif

  ( isvector(p0) && length(p0) == K && all(p0>=0) && abs(sum(p0)-1.0)<epsilon ) || \
      error( "p0 must be a state occupancy probability vector" );

  p0 = p0(:)'; # make p0 a row vector

  if ( nargin == 3 )
    isscalar(n) && n>=0 || \
	error("n must be >=0");
    n = fix(n);
    L = zeros(sizeof(p0));

    ## It is know that 
    ##
    ## I + P + P^2 + P^3 + ... + P^n = (I-P)^-1 * (I-P^(n+1))
    ##
    ## and therefore we could succintly write
    ##
    ## L = p0*inv(eye(K)-P)*(eye(K)-P^(n+1));
    ##
    ## Unfortunatly, the method above is numerically unstable (at least
    ## for small values of n), so we use the crude approach below.

    PP = p0;
    L = zeros(1,K);
    for p=0:n
      L += PP;
      PP *= P;
    endfor
  else
    ## identify transient states
    tr = find(diag(P) < 1);
    k = length(tr); # number of transient states
    if ( k == K )
      error("There are no absorbing states");
    endif
    
    N = zeros(size(P));
    
    ## Source: Grinstead, Charles M.; Snell, J. Laurie (July 1997). "Ch.
    ## 11: Markov Chains". Introduction to Probability. American
    ## Mathematical Society. ISBN 978-0821807491.
    
    ## http://www.cs.virginia.edu/~gfx/Courses/2006/DataDriven/bib/texsyn/Chapter11.pdf
    tmpN = inv(eye(k) - P(tr,tr)); # matrix N = (I-Q)^-1
    N(tr,tr) = tmpN;
    L = p0*N;
  endif
endfunction
%!test
%! P = dtmcbd([1 1 1 1], [0 0 0 0]);
%! L = dtmcexps(P,[1 0 0 0 0]);
%! t = dtmcmtta(P,[1 0 0 0 0]);
%! assert( L, [1 1 1 1 0] );
%! assert( sum(L), t );

%!test
%! P = dtmcbd(linspace(0.1,0.4,5),linspace(0.4,0.1,5));
%! p0 = [1 0 0 0 0 0];
%! L = dtmcexps(P,0,p0);
%! assert( L, p0 );