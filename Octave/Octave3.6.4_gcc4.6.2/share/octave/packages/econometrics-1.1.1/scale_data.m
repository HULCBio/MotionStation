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

## Standardizes and normalizes data matrix,
## primarily for use by BFGS

function [zz, scalecoefs] = scale_data(z);

	n = rows(z);
	k = columns(z);

	# Scale data
	s = std(z)';
	test = s != 0;
	s = s + (1 - test); # don't scale if column is a constant (avoid div by zero)
	A = diag(1 ./ s);

	# De-mean all variables except constant, if a constant is present
	test = std(z(:,1)) != 0;
	if test
		bb = zeros(n,k);
		b = zeros(k,1);
	else
		b = -mean(z)';
		test = std(z)' != 0;
		# don't take out mean if the column is a constant, to preserve identification
		b = b .* test;
		b = A*b;
		bb = (diag(b) * ones(k,n))';
	endif
	zz = z*A + bb;
	scalecoefs = {A,b};
endfunction
