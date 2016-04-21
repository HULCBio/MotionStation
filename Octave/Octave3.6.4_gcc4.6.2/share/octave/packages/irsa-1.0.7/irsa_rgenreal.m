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
## @deftypefn {Function File} {irsa_rgenreal.m}
## [@var{yp,fxp,fyp}] = irsa_rgenreal (@var{xp}, @var{fmax}, @var{arfunc},
## @var{prfunc})    
## 
## Generate a real-valued band-limited timeseries with sampling points
## @var{xp} and maximum frequency @var{fmax}.
## 
## Input:
##
## @var{xp}    : Vector -- sampling points 
##
## @var{fmax}  : Scalar -- maximum (band-limiting) frequency 
## 
## @var{arfunc}: String -- name of random number generator with desired
## distribution for the generated frequency amplitudes. Default is
## @code{randn}. 
##
## @var{prfunc}: String -- name of random number generator with desired
## distribution for the generated frequency phases taken
## times @code{2*@var{pi}}. Default is @code{rand}.
##
## The random number generators have to take the number of rows as the first
## and the number of columns as the second argument.
##
## Output:
##
## @var{yp}  : Columnvector -- sampling values
## 
## @var{fxp} : Columnvector -- frequency points
##
## @var{fyp} : Columnvector -- frequency values
## @end deftypefn

function [yp, fxp, fyp] = irsa_rgenreal( xp, fmax, arfunc, prfunc )

  if( nargin < 2 || nargin > 4 )
    usage( "yp = irsa_rgenreal (xp, fmax, arand, prand)" );
  endif
  if( nargin < 3 || isempty( arfunc ) )
    arfunc = "randn";
  endif
  if( nargin < 4 || isempty( prfunc ) )
    prfunc = "rand";
  endif
  
  [N, dummy, regular, Tm] = irsa_check( xp );  
  [xpn, fmaxn, xp1, nfac] = irsa_normalize( xp, fmax );
  if( fmaxn < 1 )
    error( "fmax was too small to result in a discrete freqency." );
  endif
  Namp = fmaxn + 1;		# Number of amplitudes
  Ne = fmod(N+1,2);		# Ne is 1 if N is even and 0 otherwise
  Nphi = fmaxn - Ne;		# Number of phases
  fxp = [[0:1:fmaxn],-[fmaxn:-1:1]]';
  Nf = length( fxp );
  ## Generate random amplitudes and phases
  amp = feval( arfunc, Namp, 1 );
  phi = feval( prfunc, Nphi, 1 );
  ## Use them to build the spectrum
  pfyp = amp;			# Positive part
  if( Ne )
    pfyp(Namp) /= 2;
  endif
  if( Nphi > 0 );		# Avoid operations with empty arrays
    pfyp(2:Namp - Ne) .*= exp( 2*pi*I*phi );
  endif
  ## Symmetry for real valued signals determines the negative part
  nfyp = conj(flipud(pfyp(2:Namp)));  
  ## if fmax is the Nyquist frequency of a regular signal fmax and -fmax merge 
  if( regular && (N == (Namp + Nphi)) && Ne )
    fxp = [[0:1:fmaxn],-[fmaxn-1:-1:1]]';
    pfyp(Namp) *= 2;
    nfyp = nfyp(2:fmaxn);
    merged = 1;
  else
    merged = 0;
  endif
  fyp = [pfyp;nfyp];

  if( regular )
    yp = real( ifft( [pfyp;zeros(N-Nf+merged,1);nfyp] ) );
  else
    yp = real( irsa_idft( fxp, fyp, xpn, true ) );
  endif  
  ## Adjust frequency representation
  fxp /= nfac;
  fyp .*= exp( -2*pi*I*xp1*fxp );

endfunction

%!demo
%! N = 32;
%! xp1 = 1.5;
%! xp = linspace(0,N-1,N) + xp1;
%! longxp = linspace( 0, N-(1/16), N*16 ) + xp1;
%! [yp, fxp, fyp] = irsa_rgenreal( xp, 1/8 );
%! longyp = irsa_idft( fxp, fyp, longxp, true )*16;
%! figure();
%! plot( longxp, longyp, '-r', xp, yp, '*b' );
%! title( sprintf"Regular timeseries with spacing 1 and fmax = 1/8" );
%! xlabel( "Sampling points" ); 
%! ylabel( "Sampling values" );
%! legend('off');
%! hold on;
%! input("Press Enter to see the spectrum up to the band-limit");
%! irsa_plotdft( fxp, fyp ); 
%! input("Press Enter to see the whole spectrum computed via FFT");
%! irsa_plotdft( irsa_dftfp( xp ), fft(yp) ); 

%!demo
%! N = 32; xp1 = 1.5; ofac = 16;
%! xp = irsa_mdsp( 0.01, 0.99, N, "rand" ) + xp1;
%! longxp = linspace( 0, N-(1/ofac), N*ofac ) + xp1;
%! [yp, fxp, fyp] = irsa_rgenreal( xp, 1/8 ); 
%! longyp = irsa_idft( fxp, fyp, longxp, true )*16;
%! figure();
%! plot( longxp, longyp, '-r', xp, yp, '*b' ); 
%! title( "Irregular timeseries with mean spacing 1 and fmax = 1/8" );
%! xlabel( "Sampling points" ); 
%! ylabel( "Sampling values" );
%! legend('off');
%! hold on;
%! input("Press Enter to see the spectrum up to the band-limit");
%! irsa_plotdft( fxp, fyp ); 
%! input("Press Enter to see the spectrum via DFT");
%! fxp = irsa_dftfp( xp );
%! fyp = irsa_dft( xp, yp, fxp );
%! irsa_plotdft( fxp, fyp ); 

### Local Variables:
### mode: octave
### End:
