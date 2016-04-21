### Copyright (C) 2003 Joerg Huber
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
## @deftypefn {Function File} {irsa_check.m}
## [@var{N}, @var{cols}, @var{reg}, @var{Tm}] = irsa_check
## (@var{xp}, [@var{yp}])  
##
## Check for consistency of the timeseries and compute some characterisitic
## parameters 
## 
## Input:
##
## @var{xp}   : Columnvector of sampling points corresponding to @var{yp} 
##
## @var{yp}   : Matrix with the timeseries values in its columns 
##
## Output:
##
## @var{N}    : Scalar -- length of timeseries
## 
## @var{cols} : Scalar -- number of columns of @var{yp}
##
## @var{reg}  : Boolean -- true if the sampling is regular (equidistant) 
##
## @var{Tm}   : Scalar -- Mean sampling distance
## @end deftypefn

function [N, cols, reg, Tm] = irsa_check (xp, yp)

  if( nargin < 1 || nargin > 2 )
    usage( "[N, cols, reg, Tm] = irsa_size (xp, [yp])" );
  endif

  xp = xp(:);   	# Assure to have a column vector
  [N, colsxp] = size( xp );
  if( colsxp > 1 )
    error( "Only a vector of sampling points \'XP\' can be used." );
  endif 
  if( !all( xp .- sort(xp) < eps ) )
    error( "Sampling points have to be sorted in ascending order" );
  endif 

  if( nargin == 2 )
    [Nyp, cols] = size( yp );
    if( N != Nyp )
      error( "Number of sampling points and number of corresponding values \
	  have to be equal." );
    endif
  else
    cols = [];
  endif  
     
  if( nargout > 2 )
    [reg, Tm] = irsa_isregular(xp);
  endif
  
endfunction

### Local Variables:
### mode: octave
### End:
