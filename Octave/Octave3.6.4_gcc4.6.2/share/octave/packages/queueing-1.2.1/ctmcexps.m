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
## @deftypefn {Function File} {@var{L} =} ctmcexps (@var{Q}, @var{t}, @var{p} )
## @deftypefnx {Function File} {@var{L} =} ctmcexps (@var{Q}, @var{p})
##
## @cindex Markov chain, continuous time
## @cindex expected sojourn time, CTMC
##
## With three arguments, compute the expected times @code{@var{L}(i)}
## spent in each state @math{i} during the time interval @math{[0,t]},
## assuming that the initial occupancy vector is @var{p}. With two
## arguments, compute the expected time @code{@var{L}(i)} spent in each
## transient state @math{i} until absorption.
##
## @strong{INPUTS}
##
## @table @var
##
## @item Q
## @math{N \times N} infinitesimal generator matrix. @code{@var{Q}(i,j)}
## is the transition rate from state @math{i} to state @math{j}, @math{1
## @leq{} i \neq j @leq{} N}. The matrix @var{Q} must also satisfy the
## condition @math{\sum_{j=1}^N Q_{ij} = 0}.
##
## @item t
## If given, compute the expected sojourn times in @math{[0,t]}
##
## @item p
## Initial occupancy probability vector; @code{@var{p}(i)} is the
## probability the system is in state @math{i} at time 0, @math{i = 1,
## @dots{}, N}
##
## @end table
##
## @strong{OUTPUTS}
##
## @table @var
##
## @item L
## If this function is called with three arguments, @code{@var{L}(i)} is
## the expected time spent in state @math{i} during the interval
## @math{[0,t]}. If this function is called with two arguments
## @code{@var{L}(i)} is the expected time spent in transient state
## @math{i} until absorption; if state @math{i} is absorbing,
## @code{@var{L}(i)} is zero.
##
## @end table
##
## @seealso{dtmcexps}
##
## @end deftypefn

## Author: Moreno Marzolla <marzolla(at)cs.unibo.it>
## Web: http://www.moreno.marzolla.name/

function L = ctmcexps( Q, varargin )

  persistent epsilon = 10*eps;

  if ( nargin < 2 || nargin > 3 )
    print_usage();
  endif

  [N err] = ctmcchkQ(Q);

  (N>0) || \
      error(err);

  if ( nargin == 2 )
    p = varargin{1};
  else
    t = varargin{1};
    p = varargin{2};
  endif

  ( isvector(p) && length(p) == size(Q,1) && all(p>=0) && abs(sum(p)-1.0)<epsilon ) || \
      error( "p must be a probability vector" );

  p = p(:)'; # make p a row vector

  if ( nargin == 3 ) # non-absorbing case
    if ( isscalar(t) )
      (t >= 0 ) || \
	  error( "t must be >= 0" );
      ## F(x) are the transient state occupancy probabilities at time x
      ## F(x) = p*expm(Q*x) (see function ctmc()).
      F = @(x) (p*expm(Q*x));
      L = quadv(F,0,t);
    else
      ## FIXME: deprecate this?
      ( isvector(t) && abs(t(1)) < epsilon ) || \
	  error( "t must be a vector, and t(1) must be 0.0" );
      t = t(:)'; # make tt a row vector
      ff = @(x,t) (x(:)'*Q+p);
      fj = @(x,t) (Q);
      L = lsode( {ff, fj}, zeros(size(p)), t );
    endif
  else # absorbing case

    ## Identify transient states. If all states are transient, then
    ## raise an error since we can't deal with non-absorbing chains
    ## here.

    N = rows(Q);
    tr = find( any( abs(Q) > epsilon, 2 ) );
    if ( length( tr ) == N )
      error( "There are no absorbing states" );
    endif
    
    QN = Q(tr,tr);
    pN = p(tr);
    LN = -pN*inv(QN);
    L = zeros(1,N);
    L(tr) = LN;
  endif
endfunction
%!test
%! Q = [-1 1; 1 -1];
%! L = ctmcexps(Q,10,[1 0]);
%! L = ctmcexps(Q,linspace(0,10,100),[1 0]);

%!test
%! Q = ctmcbd( [1 2 3], [3 2 1] );
%! p0 = [1 0 0 0];
%! t = linspace(0,10,10);
%! L1 = L2 = zeros(length(t),4);
%! # compute L using the differential equation formulation
%! ff = @(x,t) (x(:)'*Q+p0);
%! fj = @(x,t) (Q);
%! L1 = lsode( {ff, fj}, zeros(size(p0)), t );
%! # compute L using ctmcexps (integral formulation)
%! for i=1:length(t)
%!   L2(i,:) = ctmcexps(Q,t(i),p0);
%! endfor
%! assert( L1, L2, 1e-5);

%!demo
%! lambda = 0.5;
%! N = 4;
%! b = lambda*[1:N-1];
%! d = zeros(size(b));
%! Q = ctmcbd(b,d);
%! t = linspace(0,10,100);
%! p0 = zeros(1,N); p0(1)=1;
%! L = zeros(length(t),N);
%! for i=1:length(t)
%!   L(i,:) = ctmcexps(Q,t(i),p0);
%! endfor
%! plot( t, L(:,1), ";State 1;", "linewidth", 2, \
%!       t, L(:,2), ";State 2;", "linewidth", 2, \
%!       t, L(:,3), ";State 3;", "linewidth", 2, \
%!       t, L(:,4), ";State 4;", "linewidth", 2 );
%! legend("location","northwest");
%! xlabel("Time");
%! ylabel("Expected sojourn time");

%!demo
%! lambda = 0.5;
%! N = 4;
%! b = lambda*[1:N-1];
%! d = zeros(size(b));
%! Q = ctmcbd(b,d);
%! p0 = zeros(1,N); p0(1)=1;
%! L = ctmcexps(Q,p0);
%! disp(L);
