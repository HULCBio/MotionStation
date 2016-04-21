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
## @deftypefn {Function File} {irsa_normalize.m}
## [@var{xpn},@var{fmaxn},@var{xp1},@var{nfac}] = irsa_normalize( @var{xp},
## [@var{fmax}] ) 
##
## Normalize @var{xp} to [0, (N-1)/N], compute the last
## frequency point below or equal to the given bandlimiting frequency
## @var{fmax} and scale it according to the normalization.  
## 
## Input:
##
## @var{xp}     : Vector -- sampling points 
##
## @var{fmax}   : Scalar -- band limiting frequency of signal sampled at
## @var{xp} 
##
## Output:
##
## @var{xpn}    : Vector -- normalized sampling points
##
## @var{fmaxn}  : Scalar -- last discrete frequency corresponding to @var{xpn}
## 
## @var{xp1}    : Scalar -- offset of @var{xp} ( xp(1) )
## 
## @var{nfac}   : Scalar -- normalization factor
##
## @emph{Note:} 
## 
## You get @var{xp} from @var{xpn} by computing @code{@var{xp} =
## @var{xpn}*@var{nfac}+ @var{xp1}}. Due to discretization the actually
## used @var{fmax} for @var{xp} is @code{@var{fmaxn}/@var{nfac}}.
## @end deftypefn

function [xpn, fmaxn, xp1, nfac] = irsa_normalize( xp, fmax )

  if( nargin < 1 || nargin > 2 )
    usage( "[xpn, fmaxn, xp1, nfac] = irsa_normalize (xp, fmax)" );
  endif
  
  N = length(xp);
  xp1 = xp(1);
  xpn = xp - xp1;
  nfac = xpn(N)*N/(N-1);
  xpn /= nfac;			# Now xpn is in [0,(N-1)/N]
  if( nargout > 1 )
    if( nargin < 2 )
      error( "\'fmax\' required to compute \'fmaxn\'" );
    endif
    fmaxn = floor(fmax*nfac*(1+eps));
  endif
		    
endfunction
### Local Variables:
### mode: octave
### End:
