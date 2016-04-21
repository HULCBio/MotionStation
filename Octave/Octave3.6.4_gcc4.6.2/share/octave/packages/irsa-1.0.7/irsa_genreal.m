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
## @deftypefn {Function File} {irsa_genreal.m}
## [@var{yp,fxp,fyp}] = irsa_genreal (@var{xp}, @var{amp}, @var{phi})    
## 
## Generate values for a real-valued band-limited timeseries at the
## sampling points @var{xp} with amplitudes @var{amp} and phases
## @code{2*@var{pi}*@var{phi}}   
## 
## Input:
##
## @var{xp}  : Vector -- sampling points 
##
## @var{amp} : Vector -- positive amplitudes of the spectrum
##
## @var{phi} : Vector -- positive phases of the spectrum in @code{rad /
## 2*@var{pi}}.
## 
## Output:
##
## @var{yp}  : Columnvector -- sampling values
## 
## @var{fxp} : Columnvector -- frequency points
##
## @var{fyp} : Columnvector -- frequency values
##
## @emph{Note:}
## 
## If @var{xp} doesn't start at 0 the spectrum will be phase
## shifted. The function assumes, that this phase shift is neglected when
## giving the spectrum in @var{amp} and @var{phi}, but computes the
## correct phase shifted values in @var{fyp}.
## @end deftypefn

function [yp, fxp, fyp] = irsa_genreal( xp, amp, phi )

  if( nargin != 3 )
    usage( "yp = irsa_genreal (xp, amp, phi)" );
  endif
  [N, dummy, regular, Tm] = irsa_check( xp );  
  Namp = length(amp);	
  Nphi = length(phi);
  Nf = Namp + Nphi;		# Number of frequency points
  nyquist = false;		# Default
  if( Namp - Nphi == 2 )
    if( Nf != N )
      warning( "The last entry of 'AMP' is not the Nyquist frequency of the resulting time series." );
    else
      nyquist = true;
    endif
  endif
  if( Nphi < Namp-1-nyquist || Nphi > Namp-1 )
    error( "'PHI' has to be one or (if Nyquist frequency included) two entries shorter than 'AMP'." ); 
  endif
  if( N < Nf )
    error( "'XP has to be at least as long as 'AMP' and 'PHI' together.");
  endif
  amp = amp(:); phi = phi(:);  
  [xpn, dummy, xp1, nfac] = irsa_normalize( xp, 0 );
  fxp = [[0:1:Namp-1],-[Nphi:-1:1]]';
  
  ## Build the spectrum
  pfyp = amp;			# Positive part
  if( Nphi > 0 );		# Avoid operations with empty arrays
    pfyp(2:Namp-nyquist) .*= exp( 2*pi*I*phi );
  endif
  ## Symmetry for real valued signals determines the negative part
  nfyp = conj(flipud(pfyp(2:Namp-nyquist)));  
  fyp = [pfyp;nfyp];

  if( regular )
    yp = real( ifft( [pfyp;zeros(N-Nf,1);nfyp] ) );
  else
    yp = real( irsa_idft( fxp, fyp, xpn, true ) );
  endif  
  ## Adjust spectrum
  fxp /= nfac;
  fyp .*= exp( -2*pi*I*xp1*fxp );
endfunction
### Local Variables:
### mode: octave
### End:

