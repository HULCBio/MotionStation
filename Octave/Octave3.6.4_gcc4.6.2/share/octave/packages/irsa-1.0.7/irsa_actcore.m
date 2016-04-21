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
## @deftypefn {Function File} {irsa_actcore.m}
## [@var{rfyp},@var{err}] = irsa_actcore (@var{xpn}, @var{yp},
## @var{fmaxn}, [@var{itmax}], [@var{thresh}])  
## 
## Reconstruction of the frequency representation (i.e. the spectrum)
## of a band-limited signal from an irregular sampled timeseries using
## Adaptive weights, Conjugate gradients and Toeplitz matrices.
## 
## Input:
##
## @var{xpn}   : Vector -- sampling points in [0,(N-1)/N]
##
## @var{yp}    : Vector -- corresponding sampling values
##
## @var{fmaxn} : Scalar -- maximum (band-limiting) frequency. Due to the
## scaling of @var{xpn} it has to be a positive integer.
## 
## @var{itmax} : Scalar -- maximum number of reconstruction iterations.
## Default is twice the number of the frequencies.
##
## @var{thresh}: Scalar -- threshold for conjugate gradients (stop
## criterion). Default is machine precision.
##
## Output:
##
## @var{rfyp}  : Columnvector -- reconstructed spectrum
## 
## @var{err}   : Columnvector -- error for each iteration step
##
## @emph{Note:}
## 
## The use of this function requires normalized sampling points
## @var{xpn} in @code{[0,(N-1)/N]} and the knowledge of
## @var{fmaxn}. Use the function @code{irsa_normalize} for this task.
##
## @end deftypefn

## This function is an implementation of the ACT-algorithm. Its
## based on the related publications and on the ideas of the
## MATLAB-implementation 'act.m' from Thomas Strohmer, who kindly
## permitted this implementation. But all potential implementation
## errors are only my fault.  
##
## The mathematical theory for this algorithm is published in the following
## reference and in references therein:
##
## Feichtinger, H.G. ,Groechenig, K. and Strohmer, T.,
## Efficient Numerical Methods in Non-uniform Sampling Theory, 
## Numerische Mathematik, vol.69, pp.423-440, 1995.  
##
## The previous PhD-Thesis of Thomas Strohmer is also helpful:
##
## Thomas Strohmer, Efficient Methods for Digital Signal and Image
## Reconstruction from Nonuniform Samples, Institut fuer Mathematik der
## Universitaet Wien, 1993.

function [rfyp, err] = irsa_actcore( xpn, yp, fmaxn, itmax, thresh )
  
  ## Input handling
  if( nargin < 3 || nargin > 5 )
    usage( "[rfyp, err] = irsa_actcore( xpn, yp, fmaxn, itmax, thresh )" );
  endif 
  if( round( fmaxn ) != fmaxn || fmaxn < 1 )
    error( "fmaxn has to be a positive integer value." );
  endif
  
  xpn=xpn(:)'; yp=yp(:).';	# assure to have vectors of row type
  N = length(xpn);
  Nf = 2*fmaxn+1;		# Number of frequency points
  rfxp = [0:1:Nf-1];   		# frequency points for the Toeplitz matrix
  rfxps = -fmaxn:1:fmaxn;	# Sorted frequency points
    
  ## Optional input handling
  if( nargin < 4 || isempty(itmax) )
    itmax = 2*Nf;
  endif 
  if( nargin < 5 || isempty(thresh) )
    thresh = eps;
  endif 
  thresh2 = thresh^2;
  ## Adaptive weights with mean 1
  w = ( [xpn(2:N),1] .-  [-1/N,xpn(1:N-1)] ) * 0.5 * N;
  
  ## First row of Toepliz matrix and the vector necessary to the
  ## reconstruction  
  toepw = irsa_dft( xpn, w', rfxp, true )'/N;
  r = irsa_dft( xpn, (w.*yp)', rfxps, true )';
  
  ## Pad vectors with zeros to next power of 2 to use the most efficient FFT
  Nfpad = 2^(nextpow2(2*Nf-1)) - 2*Nf+1;	# length of frequency padding
  pad = zeros(1,Nf-1+Nfpad);	# time padding
  ftoepw_pad = real( fft( [toepw, zeros(1,Nfpad), conj(toepw(Nf:-1:2))] ) );
  
  ## Reconstruction with conjugate gradients 
  p = 0; beta = 0;
  rr = r * r';
  k = 1;
  rfyp = zeros(1,Nf);
  do
    p = r + beta * p;
    q_pad = ifft(ftoepw_pad .* fft([p, pad]));
    q = q_pad(1:Nf);
    alpha = rr / (p * q');
    if( nargout > 1 )		# compute and store error for each step
      rfyp_old = rfyp;
      rfyp += alpha * p;
      err(k,1) = norm(rfyp - rfyp_old) / (norm(rfyp)*sqrt(N));
    else
      rfyp += alpha * p;
    endif	
    r -= alpha * q;
    rr_old=rr;
    rr = r*r';
    beta = rr / rr_old; 
  until( rr < thresh2 || k++ >= itmax ) 
  rfyp = shift( rfyp', -fmaxn );
endfunction 

%!demo
%! N = 20; ofac = 16; Tmean = 0.9, jit = 0.99; xp1 = 1; fmax = 0.5;
%! xp = irsa_jitsp( Tmean, N, jit ) + xp1; 
%! [yp,fxp,fyp] = irsa_randgenreal( xp, fmax );
%! xplong = linspace( 0, N-(1/ofac), N*ofac )*Tmean + xp1;
%! yplong = irsa_idft( fxp, fyp, xplong, true )*ofac;
%! plot( xplong, yplong,'-1', xp, yp, '^3', xp, yp, '@*3' );
%! input( "Press Enter to see the original spectrum" );
%! irsa_plotdft( fxp, fyp );
%! [xpn, fmaxn,xp1,nfac] = irsa_normalize( xp, fmax );
%! rfyp = irsa_actcore( xpn, yp, fmaxn );
%! rfyp .*= exp( -2*pi*I*xp1*fxp );
%! input( "Press Enter to see the reconstruced spectrum" );
%! irsa_plotdft( fxp, rfyp );
%! input( "Press enter to see reconstruction error for the spectrum" );
%! irsa_plotdft( fxp, rfyp .- fyp );

### Local Variables:
### mode: octave
### End:
