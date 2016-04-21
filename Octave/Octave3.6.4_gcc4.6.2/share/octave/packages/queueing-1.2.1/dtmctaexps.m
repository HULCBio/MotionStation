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
## @deftypefn {Function File} {@var{L} =} dtmctaexps (@var{P}, @var{n}, @var{p0})
## @deftypefnx {Function File} {@var{L} =} dtmctaexps (@var{P}, @var{p0})
##
## @cindex time-alveraged sojourn time, DTMC
## @cindex discrete time Markov chain
## @cindex Markov chain, discrete time
## @cindex DTMC
##
## Compute the @emph{time-averaged sojourn time} @code{@var{M}(i)},
## defined as the fraction of time steps @math{@{0, 1, @dots{}, n@}} (or
## until absorption) spent in state @math{i}, assuming that the state
## occupancy probabilities at time 0 are @var{p0}.
##
## @strong{INPUTS}
##
## @table @var
##
## @item P
## @math{N \times N} transition probability matrix.
##
## @item n
## Number of transitions during which the time-averaged expected sojourn times
## are computed (@math{@var{n} @geq{} 0}). if @math{@var{n} = 0},
## returns @var{p0}.
##
## @item p0
## Initial state occupancy probabilities.
##
## @end table
##
## @strong{OUTPUTS}
##
## @table @var
##
## @item M
## If this function is called with three arguments, @code{@var{M}(i)} is
## the expected fraction of steps @math{@{0, 1, @dots{}, n@}} spent in
## state @math{i}, assuming that the state occupancy probabilities at
## time zero are @var{p0}. If this function is called with two
## arguments, @code{@var{M}(i)} is the expected fraction of steps spent
## in state @math{i} until absorption.
##
## @end table
##
## @seealso{ctmctaexps}
##
## @end deftypefn

## Author: Moreno Marzolla <marzolla(at)cs.unibo.it>
## Web: http://www.moreno.marzolla.name/

function M = dtmctaexps( P, varargin )

  persistent epsilon = 10*eps;

  if ( nargin < 2 || nargin > 3 )
    print_usage();
  endif

  L = dtmcexps(P,varargin{:});
  M = L ./ sum(L);
endfunction
%!test
%! P = dtmcbd([1 1 1 1], [0 0 0 0]);
%! p0 = [1 0 0 0 0];
%! L = dtmctaexps(P,p0);
%! assert( L, [.25 .25 .25 .25 0], 10*eps );

