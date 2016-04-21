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
## @deftypefn {Function File} {[@var{z}] =} genqamdemod(@var{y},@var{const})
##	Compute the general quadrature amplitude demodulation of y.
## @seealso{genqammod,qammod,qamdemod}
## @end deftypefn

function z = genqamdemod(y,const)
	if ( nargin < 1 || nargin > 2)
		error('usage : z = genqamdemod(y,const)');
	end
	
	if(isvector(const) ~= 1)
		error('const must be a vector');
	end
	
	for k = 1:size(y,1)
		for l = 1:size(y,2)
			[val z(k,l)] = min(abs(y(k,l)-const));
		end
	end
	
	z = z -1;
	
