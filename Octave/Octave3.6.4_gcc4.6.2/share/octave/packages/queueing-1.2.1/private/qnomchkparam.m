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
## @deftypefn {Function File} {[@var{err} @var{lambda} @var{S} @var{V} @var{m} @var{Z}] = } qnomchkparam( lambda, S, ... )
##
## Validate input parameters for open, multiclass network.
## @var{err} is the empty string on success, or a suitable error message
## string on failure.
##
## @end deftypefn

## Author: Moreno Marzolla <marzolla(at)cs.unibo.it>
## Web: http://www.moreno.marzolla.name/

function [err lambda S V m] = qnomchkparam( varargin )
  
  err = "";

  assert( nargin >= 2 );

  lambda = varargin{1};

  S = varargin{2};

  [V m] = deal(0);

  if ( !isvector(lambda) || length(lambda)==0 )
    err = "lambda must be a nonempty vector";
    return;
  endif

  if ( any(lambda<=0) )
    err = "lambda must contain positive values";
    return;
  endif

  lambda = lambda(:)';

  C = length(lambda); ## Number of classes

  if ( !ismatrix(S) || rows(S) != C )
    err = sprintf("S must be a matrix with %d rows",C);
    return;
  endif

  if ( any(S(:)<0) )
    err = "S must contain nonnegative values";
    return;
  endif

  K = columns(S);

  if ( nargin < 3 )
    V = ones(size(S));
  else
    V = varargin{3};
    if ( !ismatrix(V) || rows(V) != C || columns(V) != K )
      err = sprintf("V must be a %d x %d matrix", C, K );
      return;
    endif

    if ( any(V(:)<0) )
      err = "V must contain nonnegative values";
      return;
    endif
  endif

  if ( nargin < 4 ) 
    m = ones(1,K);
  else
    m = varargin{4};
    if (!isvector(m) || length(m) != K ) 
      err = sprintf("m must be a vector with %d elements", K );
      return;
    endif
    m = m(:)';
  endif

endfunction
