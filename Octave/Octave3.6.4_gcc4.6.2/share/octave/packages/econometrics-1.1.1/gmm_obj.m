## Copyright (C) 2003, 2004, 2005 Michael Creel <michael.creel@uab.es>
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

## The GMM objective function, for internal use by gmm_estimate
## This is scaled so that it converges to a finite number.
## To get the chi-square specification
## test you need to multiply by n (the sample size)

function obj_value = gmm_obj(theta, data, weight, moments, momentargs)

	m = average_moments(theta, data, moments, momentargs);
	
	obj_value = m' * weight *m;

	if (((abs(obj_value) == Inf)) || (isnan(obj_value)))
		obj_value = realmax;
	endif	

endfunction	
