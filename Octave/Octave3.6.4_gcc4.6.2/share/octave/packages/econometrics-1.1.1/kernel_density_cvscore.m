## Copyright (C) 2006 Michael Creel <michael.creel@uab.es>
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

## cvscore = kernel_density_cvscore(bandwidth, data, kernel)

function cvscore = kernel_density_cvscore(bandwidth, data, kernel)
		dens = kernel_density(data, data, exp(bandwidth), true, 0, 0, chol(cov(data)), kernel);
		dens = dens + eps; # some kernels can assign zero density
		cvscore = -mean(log(dens));
endfunction

