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

## GMM variance, which assumes weights are optimal

function V = gmm_variance(theta, data, weight, moments, momentargs)
	D = numgradient("average_moments", {theta, data, moments, momentargs});
	D = D';
	m = feval(moments, theta, data, momentargs); # find out how many obsns. we have
	n = rows(m);
	V = (1/n)*inv(D*weight*D');
endfunction
