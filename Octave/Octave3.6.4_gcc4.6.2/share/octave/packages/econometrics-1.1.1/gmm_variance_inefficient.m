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

## GMM variance, which assumes weights are not optimal

function V = gmm_variance_inefficient(theta, data, weight, omega, moments, momentargs)
	D = numgradient("average_moments", {theta, data, moments, momentargs});
	D = D';

	n = rows(data);

	J = D*weight*D';
	J = inv(J);
	I = D*weight*omega*weight*D';
	V = (1/n)*J*I*J;
endfunction
