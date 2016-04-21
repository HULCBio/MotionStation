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
## @deftypefn {Function File} {[@var{Xl}, @var{Xu}, @var{Rl}, @var{Ru}] =} qnomaba (@var{lambda}, @var{D})
## @deftypefnx {Function File} {[@var{Xl}, @var{Xu}, @var{Rl}, @var{Rl}] =} qnomaba (@var{lambda}, @var{S}, @var{V})
##
## @cindex bounds, asymptotic
## @cindex open network
## @cindex multiclass network, open
##
## Compute Asymptotic Bounds for open, multiclass networks.
##
## @strong{INPUTS}
##
## @table @var
##
## @item lambda
## @code{@var{lambda}(c)} is the class @math{c} arrival rate to the
## system.
##
## @item D
## @code{@var{D}(c, k)} is class @math{c} service demand 
## at center @math{k}. (@code{@var{D}(c, k) @geq{} 0} for all
## @math{k}).
##
## @item S
## @code{@var{S}(c, k)} is the mean service time of class @math{c}
## requests at center @math{k}. (@code{@var{S}(c, k) @geq{} 0} for all
## @math{k}).
##
## @item V
## @code{@var{V}(c, k)} is the mean number of visits of class @math{c}
## requests at center @math{k}. (@code{@var{V}(c, k) @geq{} 0} for all
## @math{k}).
##
## @end table
##
## @strong{OUTPUTS}
##
## @table @var
##
## @item Xl
## @item Xu
## Per-class lower and upper throughput bounds. For example,
## @code{@var{Xu}(c)} is the upper bound for class @math{c} throughput.
## @code{Xl} is always @math{0} since there can be no lower bound
## on the throughput of open networks.
##
## @item Rl
## @item Ru
## Per-class lower and upper response time bounds. 
## @code{Ru} is always @code{+inf} since there can be no upper bound
## on the response time of open networks.
##
## @end table
##
## @seealso{qnombsb}
##
## @end deftypefn

## Author: Moreno Marzolla <marzolla(at)cs.unibo.it>
## Web: http://www.moreno.marzolla.name/

function [X_lower X_upper R_lower R_upper] = qnomaba( lambda, S, V )
  if ( nargin < 2 || nargin > 3 )
    print_usage();
  endif
  (isvector(lambda) && length(lambda)>0) || \
      error( "lambda must be a nonempty vector" );
  all(lambda > 0) || \
      error( "lambda must contain nonnegative values" );
  lambda = lambda(:)';
  C = length(lambda);
  ( ismatrix(S) && rows(S)==C ) || \
      error( "S/D must be a matrix >=0 with %d rows", C );
  all(S(:)>=0) || \
      error( "S/D must contain nonnegative values" );
  K = columns(S);
  if ( nargin < 3 )
    V = ones(size(S));
  else
    ( ismatrix(V) && size_equal(S,V) ) || \
	error( "V must be a %d x %d matrix", C, K);
    all(V(:)>=0) || \
	error( "V must contain nonnegative values" );
  endif

  D = S.*V;
  X_lower = zeros(1,C);
  X_upper = 1./max(D,[],2)';
  R_lower = sum(D,2)';
  R_upper = +inf(1,C);
endfunction

%!test
%! fail( "qnomaba( [1 1], [1 1 1; 1 1 1; 1 1 1] )", "2 rows" );
