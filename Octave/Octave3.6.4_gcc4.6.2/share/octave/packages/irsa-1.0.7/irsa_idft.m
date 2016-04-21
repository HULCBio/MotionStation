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
## @deftypefn {Function File} {irsa_idft.m}
## @var{yp} = irsa_dft (@var{fxp}, @var{fyp}, @var{xp}, [@var{lm}])
##
## Compute Inverse Discrete Fourier Transformations of spectra
## [@var{fxp},@var{fyp}] 
## using @code{@var{yp}(t) = (1/N) * sum_(k=1)^N @var{fyp}[k] *
## exp(2*pi*I*@var{fxp}[k]*t)} for every t in @var{xp}
## 
## Input:
##
## @var{fxp} : Columnvector -- frequency points
##
## @var{fyp} : Matrix with the spectrum values in its columns 
##
## @var{xp}  : Vector -- sampling points for the resulting timeseries
##
## @var{lm}  : Boolean -- use lesser memory if 'true' (slower). Default
## is 'false'.  
##
## Output:
##
## @var{yp}   : Matrix with values of the IDFTs in its columns
## @end deftypefn

function yp = irsa_idft (fxp, fyp, xp, lm)

  ## input error handling
  if( nargin < 3 || nargin > 4 || isempty(fxp) || isempty(fyp) || isempty(xp) )
    usage( "yp = irsa_idft (fxp, fyp, xp, [lm])" );
  endif
  
  if( nargin < 4 || isempty( lm ) )
    lm = false;
  endif

  fxp = fxp(:);	xp = xp(:);	# Assure to have column vectors
  [N, cols] = size(xp);
  if( cols != 1 )
    error( "The new sampling points have to be given in a vector" );
  endif
  if( length( fxp ) != rows( fyp ) )
    error( "\'FXP\' and \'FYP\' have to have the same length." );
  endif
  
  if( !lm )
    ## Use matrix operations to compute IDFT.
    ## Needs a matrix of size [length(fxp),length(xp)].
    yp = exp( pi*I*2*xp*fxp' ) * fyp;
  else
    ## Iterate explicitly over each sampling point
    yp = zeros(N,cols);
    pii2fxp = pi*I*2*fxp';
    for k = 1:N
      yp(k,:) = exp( xp(k)*pii2fxp ) * fyp;
    endfor 
  endif
  yp /= N;			
endfunction

### Local Variables:
### mode: octave
### End:
