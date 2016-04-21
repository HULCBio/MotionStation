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
## @deftypefn {Function File} {irsa_act.m}
## [@var{rxp},@var{ryp},@var{err}] = irsa_act (@var{xp}, @var{yp}, @var{fmax},
## [@var{Nout}], [@var{itmax}],[@var{thresh}])  
## 
## Reconstructs a band-limited signal from an irregular sampled timeseries
## using Adaptive weights, Conjugate gradients and Toeplitz matrices.
## 
## Input:
##
## @var{xp}    : Vector -- sampling points
##
## @var{yp}    : Vector -- corresponding sampling values
##
## @var{fmax}  : Scalar -- maximum (band-limiting) frequency
##
## @var{Nout}  : Vector -- Number of sampling points for the
## representation of the reconstruced signal. Default is the shortest
## possible representation.
## 
## @var{itmax} : Scalar -- maximum number of reconstruction iterations.
## Default is twice the number of the frequencies.
##
## @var{thresh}: Scalar -- threshold for conjugate gradients (stop
##               criterion). Default is machine precision.
##
## Output:
##
## @var{rfyp}  : Columnvector -- reconstructed spectrum
## 
## @var{err}   : Columnvector -- error for each iteration step
##
## @end deftypefn

## This function relies on the function @code{irsa_actcore}.
## See the corresponding file for informations about the algorithm.

function [rxp,ryp,err] = irsa_act(xp,yp,fmax,Nout,itmax,thresh) 
  
  ## Check for syntax errors 
  if( nargin < 3 || nargin > 6 )
    usage( "[rxp,ryp,err] = irsa_act(xp,yp,fmax,Nout,itmax,thresh)" );
  endif
  if( nargin < 4  )
    Nout = [];
  endif
  if( nargin < 5 )
    itmax = [];
  endif
  if( nargin < 6 )
    thresh = [];
  endif
  
  ## Check for semantic errors
  [N,cols] = irsa_check(xp, yp);
  if( cols > 1 )
    error( "Only one timeseries can be reconstructed." );
  endif  
  iseven =  fmod(N+1,2);
  [xpn,fmaxn,xp1,nfac] = irsa_normalize(xp,fmax);
  if( isempty( Nout ) )
    Nout = 2*fmaxn+1 - iseven;
  endif
  if( Nout < 2*fmaxn+1 - iseven )
    error( "Nout is to short to contain the full information of the \
	signal." );
  endif
  
  ## Reconstruct the signal in the frequency domain
  ## The real work is done in irsa_actcore
  if( nargout < 3 )
    rfyp = irsa_actcore( xpn, yp, fmaxn, itmax, thresh );
  else
    [rfyp,err] = irsa_actcore( xpn, yp, fmaxn, itmax, thresh );
  endif  
  
  ## Compute the time representation of the reconstruction
  Nf = length( rfyp );
  lpfi = floor( Nf/2 ) + 1;	# last positive frequency index
  prfyp = rfyp(1:lpfi);		# positive part of spectrum
  nrfyp = rfyp(lpfi+1:Nf);	# negative part "     "
  ## special case: fmax is Nyquist-frequency
  if( iseven && Nf-1 == Nout  ) 
    prfyp(lpfi) *= 2;
    nrfyp = nrfyp(2:Nf-lpfi);
    Nf--;
  endif
  ryp = real(ifft([prfyp;zeros(Nout-Nf,1);nrfyp])) * (Nout/N);
  rxp = linspace(0,(Nout-1)/Nout,Nout)' * nfac + xp1;
endfunction 

%!demo
%! N = 20; fmax = 0.5; Tmean = 0.95; jit = 0.99; xp1 = 1; ofac = 16;
%! xp = irsa_jitsp( Tmean, N, jit ) + xp1; 
%! [yp,fxp,fyp] = irsa_randgenreal( xp, fmax );
%! xplong = linspace( 0, N-(1/ofac), N*ofac )'*Tmean + xp1;
%! yplong = irsa_idft( fxp, fyp, xplong, true )*ofac;
%! titlestr = sprintf( "Jittered sampling of a band-limited signal (fmax=%g) with mean spacing %g and jitter %g ", fmax, Tmean, jit );
%! plot( xplong, yplong,'-1', xp, yp, '^3', xp, yp, '@*3' ); title("");
%! title( titlestr ); xlabel( "time" ); ylabel( "value" ); legend('off');
%! hold on;
%! [rxp,ryp] = irsa_act( xp, yp, fmax, N );
%! input( "Press Enter to see the reconstruction" );
%! title( "Reconstruction" );
%! plot( xplong, yplong,'-1', rxp, ryp, '^3', rxp, ryp, '@*3' ); title("");

### Local Variables:
### mode: octave
### End:
