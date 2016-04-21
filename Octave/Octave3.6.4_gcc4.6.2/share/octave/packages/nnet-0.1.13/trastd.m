## Copyright (C) 2005 Michel D. Schmid  <michaelschmid@users.sourceforge.net>
##
##
## This program is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2, or (at your option)
## any later version.
##
## This program is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; see the file COPYING.  If not, see
## <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {}@var{pn} = trastd (@var{p},@var{meanp},@var{stdp})
## @code{trastd} preprocess additional data for neural network simulation.
##
## @example
##   @code{p}    : test input data
##   @code{meanp}: vector with standardization parameters of prestd(...)
##   @code{stdp} : vector with standardization parameters of prestd(...)
##
##   meanp = [2.5; 6.5];
##   stdp = [1.2910; 1.2910];
##   p = [1 4; 2 5];
##
##   pn = trastd(p,meanp,stdp);
## @end example
## @noindent
## @end deftypefn

## @seealso{prestd, poststd}

## Author: Michel D. Schmid

function [Pn] = trastd(Pp,meanp,stdp)

  ## check number of inputs
  error(nargchk(3,3,nargin));

  
  [nRows,nColumns]=size(Pp);
  rowOnes = ones(1,nColumns);
  
  ## now set all standard deviations which are zero to 1
  [nRowsII, nColumnsII] = size(stdp);
  rowZeros = zeros(nRowsII,1);
  findZeros = find(stdp==0);
  rowZeros(findZeros)=1;
  equal = rowZeros;
  nequal = !equal;
  if ( sum(equal) != 0 )
    warning("Some standard deviations are zero. Those inputs won't be transformed.");
    meanp = meanp.*nequal;
    stdp = stdp.*nequal + 1*equal;
  end

  Pn = (Pp-meanp*rowOnes)./(stdp*rowOnes);

endfunction

##
## >> mInput = [1 2 3 4; 5 6 7 8]
##
## mInput =
##
##      1     2     3     4
##      5     6     7     8
##
## >> [pn,meanp,stdp] = prestd(mInput)
##
## pn =
##
##    -1.1619   -0.3873    0.3873    1.1619
##    -1.1619   -0.3873    0.3873    1.1619
##
##
## meanp =
##
##     2.5000
##     6.5000
##
##
## stdp =
##
##     1.2910
##     1.2910