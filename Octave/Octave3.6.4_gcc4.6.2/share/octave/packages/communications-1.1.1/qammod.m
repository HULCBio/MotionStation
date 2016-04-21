## Copyright (C) 2007 Sylvain Pelissier <sylvain.pelissier@gmail.com>
##
## This program is free software; you can redistribute it and/or modify it under
## the terms of the GNU General Public License as published by the Free Software
## Foundation; either version 3 of the License, or (at your option) any later
## version.
##
## This program is distributed in the hope that it will be useful, but WITHOUT
## ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
## FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
## details.
##
## You should have received a copy of the GNU General Public License along with
## this program; if not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} qammod (@var{x},@var{m})
## Create the QAM modulation of x with a size of alphabet m.
## @seealso{qamdemod,pskmod,pskdemod}
## @end deftypefn

function y = qammod(x,m)
   if(nargin < 2)
	usage('y = qammod(x,m)');
	exit;
   end
   if(any(x >= m))
        error('values of x must be in range [0,M-1]');
        exit;
    end
    
    if(~any(x == fix(x)))
        error('values of x must be integer');
        exit;
    end
    c = sqrt(m);
    if(c ~= fix(c)  || log2(c) ~= fix(log2(c)))
        error('m must be a square of a power of 2');
        exit;
    end
    b = -2.*mod(x,(c))+c-1;
    a = 2.*floor(x./(c))-c+1;
    y = a + i.*b;
