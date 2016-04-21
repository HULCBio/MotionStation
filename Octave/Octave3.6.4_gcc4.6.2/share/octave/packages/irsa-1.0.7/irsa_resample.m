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
## @var{newyp} = irsa_resample (@var{xp}, @var{yp}, @var{newxp}, [@var{lm}])
##
## Resample the signal represented by the timeseries [@var{XP},@var{yp}]
## on arbitrary samplepoints.
## @var{newxp}
## 
## Input:
##
## @var{xp}    : Columnvector -- sampling points
##
## @var{yp}    : Columnvector -- timeseries values 
##
## @var{newxp} : Vector -- sampling points for the resampling
##
## @var{lm}    : Boolean -- use lesser memory if 'true' (slower).
## Default is 'false'.  
## 
## Output:
##
## @var{newyp} : Columnvector -- timeseries values of the resampling
## @end deftypefn

function newyp = irsa_resample (xp, yp, newxp, lm )

  if( nargin < 3 || nargin > 4 )
    usage( "newyp = irsa_resample (xp, yp, newxp, [lm] )" );
  endif

  if( nargin < 4 || isempty( lm ) )
    lm = false;
  endif
  
  [N,cols,regular] = irsa_check( xp, yp );
  xp1 = xp(1); 
  xp -= xp1;
  newxp -= xp1;
  fxp = irsa_dftfp( xp );  
  if( regular )
    fyp = fft( yp );
  else
    warning( "resampling from an irregular time series produces \
      	errors. Try to use reconstruction." );
    fyp = irsa_dft( xp, yp, fxp, lm);
  endif
  newyp = irsa_idft( fxp, fyp, newxp, lm ) * (length(newxp)/N);
  ## The transformation of a real signal to the complex frequency domain
  ## and back to the real time domain does involve numerical errors
  ## which result in spurious imaginary parts of the result. Remove them.  
  if( isreal( yp ) )		
    newyp = real( newyp );
  endif

endfunction

%!demo
%! N = 32; ofac = 16; xp1 = 1.5;
%! xp = linspace(0,N-1,N)' + xp1;
%! yp = irsa_rgenreal(xp, 0.5);
%! [N,cols,regular,T] = irsa_check( xp, yp );
%! longxp = linspace(0,N-(1/ofac),N*ofac)' + xp1;
%! longyp = irsa_resample( xp, yp, longxp );
%! title( "Signal and regular sampling points" ); 
%! plot( xp, yp, '@*3', xp, yp, '^3', longxp, longyp, '-1');
%! input( "Press <enter> to proceed" );
%! mdxp = irsa_mdsp( 0.1,1.9,N/2 ) + xp1;
%! mdyp = irsa_resample( xp, yp, mdxp );
%! title( "Signal and arbitrary sample points" );
%! plot( mdxp, mdyp, '@*3', mdxp, mdyp, '^3', longxp, longyp, '-1');
### Local Variables:
### mode: octave
### End:
