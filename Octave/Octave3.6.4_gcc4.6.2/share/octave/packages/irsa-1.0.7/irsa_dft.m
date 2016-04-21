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
## @deftypefn {Function File} {irsa_dft.m}
## @var{fyp} = irsa_dft (@var{xp}, @var{yp}, @var{fxp}, [@var{lm}])
##
## Compute Discrete Fourier Transformations of irregular sampled time series
## @code{[@var{xp},@var{yp}]} 
## using @code{@var{dft}(f) = sum_(k=1)^N @var{yp}[k] *
## exp(-2*pi*I*@var{xp}[k]*f)} for every f in @var{fxp}
## 
## Input:
##
## @var{xp}  : Columnvector -- sampling points 
##
## @var{yp}  : Matrix with the timeseries values in its columns 
##
## @var{fxp} : Vector -- frequency points for the DFT
##
## @var{lm}  : Boolean -- use lesser memory if 'true' (slower). Default
## is 'false'.  
##
## Output:
##
## @var{fyp} : Matrix with values of the DFTs in its columns
## @end deftypefn

function fyp = irsa_dft( xp, yp, fxp, lm )

  ## input error handling
  if( nargin < 3 || nargin > 4 )
    usage( "fyp = irsa_dft( xp, yp, fxp, [lm] )" );
  endif

  if( nargin < 4 || isempty( lm ) )
    lm = 0;
  endif
  
  xp = xp(:); fxp = fxp(:);	# Assure to have column vectors	
  [N,cols,regular] = irsa_check( xp, yp );
  
  if( !lm )
    ## Use matrix operations to compute DFT.
    ## Needs a matrix of size [length(xp),length(fxp)].
    fyp = exp( -pi*I*2*fxp*xp' ) * yp;
  else
    ## Iterate explicitly over each frequency point
    Nf = length( fxp );
    fyp = zeros(Nf,cols);
    mpii2xp = -pi*I*2*xp';
    for k = 1:Nf
      fyp(k,:) = exp(mpii2xp*fxp(k)) * yp;
    endfor 
  endif
endfunction

%!demo
%! N = 100;
%! eqxp = [0:1:N-1].';
%! mdxp = irsa_mdsp( .8 , .2, N, "randn" );
%! yp = ones(N,1);
%! hifac = 5; ofac = 1;
%! eqfxp = irsa_dftfp( eqxp, hifac, ofac );
%! eqfyp = irsa_dft( eqxp, yp, eqfxp ); 
%! [eqfxp,idx] = sort( eqfxp ); eqfyp = eqfyp(idx);
%! ## Plot 
%! figure();
%! subplot( 211 )
%! plot( eqfxp, abs(eqfyp)/N, '-b' ); text();
%! title( "|DFT| of regular timeseries of ones (with spacing 1 and therefore a Nyquist frequency of 0.5)" );
%! text( -1.5, 1.1, "The usual comb" );
%! axis([-2.5,2.5,0,1.2]);
%! legend('off');
%! mdfxp = irsa_dftfp( mdxp, hifac, ofac );
%! mdfyp = irsa_dft( mdxp, yp, mdfxp ); 
%! [mdfxp,idx] = sort( mdfxp ); mdfyp = mdfyp(idx);
%! subplot( 212 )
%! plot( mdfxp, abs(mdfyp)/N, '-r' ); text();
%! title( "|DFT| of irregular timeseries of ones (minimum distance sampling with md = 0.8 and random part = 0.2)" );
%! text( -1.5, 1.1, "The irregularity destroys the comb" );
%! text( -0.5,0.3,"blue noise"); text( 0.1,0.3,"blue noise" );
%! xlabel( "Frequency" );
%! axis([-2.5,2.5,0,1.2]);
%! legend('off');

### Local Variables:
### mode: octave
### End:


 

