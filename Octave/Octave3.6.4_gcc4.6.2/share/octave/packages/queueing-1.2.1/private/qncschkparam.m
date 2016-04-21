## Copyright (C) 2012, 2013 Moreno Marzolla
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
## @deftypefn {Function File} {[@var{err} @var{Nout} @var{Sout} @var{Vout} @var{mout} @var{Zout}] = } qncschkparam( N, S, V, m, Z )
##
## Validate input parameters for closed, single class networks.
## @var{err} is the empty string on success, or a suitable error message
## string on failure.
##
## @end deftypefn

## Author: Moreno Marzolla <marzolla(at)cs.unibo.it>
## Web: http://www.moreno.marzolla.name/

function [err Nout Sout Vout mout Zout] = qncschkparam( N, S, V, m, Z )
  
  err = "";
  [Nout Sout Vout mout Zout] = deal(0);

  if ( nargin < 2 || nargin > 5)
    err = "Wrong number of parameters (min 2, max 5)";
    return;
  endif

  if ( !isscalar(N) || N<0 || N != fix(N) )
    err = "N must be a nonnegative integer";  
    return;
  endif

  Nout = N;

  if ( !isvector(S) || length(S)<=0 )
    err = "S must be a nonempty vector";
    return;
  endif

  if ( any(S<0) )
    err = "S must contain nonnegative values";
    return;
  endif

  Sout = S(:)';

  if ( nargin < 3 )
    Vout = ones(size(Sout));
  else
    if ( ! isvector(V) )
      err =  "V must be a vector";
      return;
    endif
    if ( any(V<0) )
      err =  "V must contain nonnegative values";
      return;
    endif
    Vout = V(:)';
  endif

  if ( nargin < 4 ) 
    mout = ones(size(Sout));
  else
    if ( ! isvector(m) )
      err = "m must be a vector";
      return;
    endif
    mout = m(:)';
  endif

  [er Sout Vout mout] = common_size(Sout, Vout, mout);
  if (er != 0 )
    err = "S, V and m are of incompatible size";
    return;
  endif

  if ( nargin < 5 )
    Zout = 0;
  else
    if ! ( isscalar(Z) && Z >= 0 )
      err = "Z must be a nonnegative scalar";
      return;
    endif
    Zout = Z;
  endif
endfunction
