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
## @deftypefn {Function File} {irsa_mdsp.m}
## @var{mdxp} = irsa_mdsp (@var{md}, @var{rd}, @var{N}, [@var{rfunc}])
##
## Generate @var{N} sampling points with a minimum distance @var{md} and
## an additional random distance @var{rd} with random distribution
## @var{rfunc}
## 
## Input:
##
## @var{md}   : Scalar -- minimum distance
##
## @var{rd}   : Scalar -- mean of the random distance
##
## @var{N}    : Scalar -- number of sampling points to generate
## 
## @var{rfunc}: String -- random distribution function for the random
## part. Has to take the number of rows as the first and the number of 
## columns as the second argument. Default is 'rand'.
##
## Output:
##
## @var{mdxp} : Columnvector -- sampling points with a minimum distance
##
## @emph{Note:}
##
## The first sampling point is 0 and the last @code{(N-1)*(md + rd)}.   
## @end deftypefn

function mdxp = irsa_mdsp( md, rd, N, rfunc )

  if( nargin < 3 || nargin > 4 )
    usage( "mdsp = irsa_mdsp( md, rd, N [, rfunc] )" );
  endif

  if( nargin < 4 )
    rfunc = "rand";
  endif

  r = feval( rfunc, N-1, 1 );
  ## Scale the distribution of r 
  r -= min(r);			# r has only positive values including 0
  r /= mean(r);			# r has the mean value 1
  r *= rd;			# r has the mean value rd

  mdxp = zeros(N,1);
  mdxp(2:N) = cumsum( md + r );
endfunction

## demo section
%!demo
%! N = 25;
%! eqxp = irsa_mdsp( 1  , 0 , N ); # Should be the same as [0:1:N-1].'
%! mdxp = irsa_mdsp( .2 , .8, N, "randn" );
%! o = ones(N,1);
%! ## Plot 
%! figure();
%! subplot( 211 );
%! plot( eqxp, o, '^b', eqxp, o, '*b' ); text(); title("");
%! title( "Irregular Minimum Distance Sampling versus regular (equidistant) sampling" );
%! legend('off');
%! axis ([-0.5,19.5,0,1.5]);
%! text( 5,1.25, 'regular sampling with distance = 1' );
%! subplot( 212 );
%! plot( mdxp, o, '^r', mdxp, o, 'xr' ); text; 
%! xlabel( "Time" );
%! text( 5,1.25, 'minimum distance sampling with md = 0.2 and rd = 0.8' );
%! legend('off');
%! axis ([-0.5,19.5,0,1.5]);

### Local Variables:
### mode: octave
### End:
