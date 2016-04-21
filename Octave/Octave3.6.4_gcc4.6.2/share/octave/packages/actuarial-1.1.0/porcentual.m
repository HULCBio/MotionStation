## Copyright (C) 2009 Esteban Cervetto <estebancster@gmail.com>
##
## Octave is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or (at
## your option) any later version.
##
## Octave is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with Octave; see the file COPYING.  If not, see
## <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {@var{M} =} porcentual (@var{a}, @var{dim})
## Auxiliar funcion. Calcs de porcentual distribution by cols (@var{a}=1) or rows (@var{a}=2)
## of the matrix @var{a}
## @end deftypefn

## Author: Act. Esteban Cervetto ARG <estebancster@gmail.com>
##
## Maintainer: Act. Esteban Cervetto ARG <estebancster@gmail.com>
##
## Created: jul-2009
##
## Version: 1.1.0 
##
## Keywords: actuarial reserves insurance bornhuetter ferguson chainladder

function [M] = porcentual (a,dim)

if (nargin==0)
 usage("no data");
end  

[m,n] = size(a);

if (nargin == 1) 
 M = a./sum(sum(a));
else
 if (dim ==1)
 M = a./ (ones(1,m)'*sum(a));
 elseif (dim==2)
 M = (a'./ (ones(1,n)'*sum(a')))';
 else
 usage("invalid dimension");
end

end
