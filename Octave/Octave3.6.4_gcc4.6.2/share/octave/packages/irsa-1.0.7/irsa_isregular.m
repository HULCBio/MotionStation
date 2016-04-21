## Copyright (C) 2003 Joerg Huber
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; If not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {irsa_isregular.m}
## [@var{regular},@var{Tm}] = irsa_isregular (@var{xp})
##
## Check if the sampling points @var{xp} are regular sampled and compute
## the mean sampling period 
## 
## Input:
##
## @var{xp}     : Columnvector -- sampling points 
##
## Output:
##
## @var{regular}: Boolean -- true if the sampling is regular (equidistant)
##
## @var{Tm}  : Scalar -- Mean sampling period
## @end deftypefn

## TODO: After some tests it showed up, that the multiplication by N
## seems to be necessary if regular timeseries shouldn't be identified
## as irregular ones occasionaly. Why? May have something to do with
## 'diff'.

function [regular, Tm] = irsa_isregular (xp)

  if( nargin != 1 || isempty( xp ) )
    usage( "[regular, Tm] = irsa_isregular (xp)" );
  endif
  
  ## Compute mean spacing between sampling points
  N = length( xp );
  Tm = (xp(N) - xp(1)) / (N - 1);

  ## Regular time series? Compare every spacing with the mean spacing
  if( all( diff(xp) .- Tm < eps*Tm*N ) ) 
    regular = true;
  else
    regular = false;
  endif

endfunction

### Local Variables:
### mode: octave
### End:
