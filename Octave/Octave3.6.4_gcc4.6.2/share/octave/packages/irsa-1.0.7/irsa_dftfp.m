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
## @deftypefn {Function File} {irsa_dftfp.m}
## [@var{fxp},@var{Nf},@var{fxps},@var{Nfe}] = irsa_dft (@var{xp},
## [@var{hifac}], [@var{ofac}])
##
## Compute frequency points for the Discrete Fourier Transformations of
## irregular sampled time series 
## 
## Input:
##
## @var{xp}   : Columnvector -- sampling points 
##
## @var{hifac}: Scalar -- factor for the amount of higher frequencies
##
## @var{ofac} : Scalar -- factor for the oversampling rate
##
## Output:
##
## @var{fxp}  : Columnvector -- frequency points corresponding to the
## order the DFT or FFT are assuming. 
##
## @var{Nf}   : Scalar -- length of fxp (only a convenience)
##
## @var{fxps} : Columnvector -- frequency points in ascending order
## 
## @var{Nfe}  : Scalar -- true (1) if Nf is even or false (0) if not.
##
## Notice: @var{fxps} and @var{Nfe} are convenient for example for plotting
## spectra: There you may need the frequency series in a sorted order
## and you get it with @code{[fxps, shift(fyp, floor(Nf/2) - Nfe)]}
## @end deftypefn

## TODO: Look for a better estimation of the highest frequency, because
## the current limit is much to high in most cases.
 
function [fxp, Nf, fxps, Nfe] = irsa_dftfp (xp, hifac, ofac )

  if( nargin < 1 || nargin > 3 )
    usage( "[fxp, fxps, Nf, Nfe ] = irsa_dftfp (xp, [hifac], [ofac])" );
  endif

  if( nargin < 3 || isempty( ofac ) )
    ofac = 1;
  endif
  if( nargin < 2 || isempty( hifac ) );
    hifac = 1;
  endif
  
  N = length(xp);
  
  Tmean = (xp(N) - xp(1)) / (N-1);
  Df = 1 / ( Tmean*N*ofac );      
  if( hifac == 0 )
    ## Take the smallest time intervall to compute the highest frequency
    ## taken into account.
    fhighest = 1 / ( min( diff( xp ) ) * N * ofac );
    hifac = (fhighest/Df);
  endif
  Nf = ceil(ofac*hifac*N);
  lastnu = floor(Nf/2);
  Nfe = fmod(Nf/2+1,1);
  pfxp = [0:Df:lastnu*Df].';
  nfxp = flipud(-pfxp(2:Nf-lastnu));
  fxp = [pfxp;nfxp];
  fxps = [nfxp;pfxp];
endfunction

### Local Variables:
### mode: octave
### End:
