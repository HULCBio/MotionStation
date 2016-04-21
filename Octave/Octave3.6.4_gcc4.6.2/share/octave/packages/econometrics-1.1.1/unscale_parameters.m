## Copyright (C) 2003, 2004 Michael Creel <michael.creel@uab.es>
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

## Unscales parameters that were estimated using scaled data
## primarily for use by BFGS

function [theta_us, vartheta_us] = unscale_parameters(theta, vartheta, scalecoefs);
	k = rows(theta);
	A = scalecoefs {1};
	b = scalecoefs {2};
	
	kk = rows(b);
	B = zeros(kk-1,kk);
	B = [b'; B];
	
	C = A + B;
	
	# allow for parameters that aren't associated with x
	if (k > kk)
		D = zeros(kk, k - kk);
		C = [C, D; D', eye(k - kk)];
	endif;	
	
	
	
	theta_us = C*theta;
	vartheta_us = C * vartheta * C';
endfunction
