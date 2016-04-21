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

## usage: [V,scorecontribs,J_inv] =
##  mle_variance(theta, data, model, modelargs)
##
## This is for internal use by mle_results

# sandwich form of var-cov matrix
function [V, scorecontribs, J_inv] = mle_variance(theta, data, model, modelargs)
	scorecontribs = numgradient(model, {theta, data, modelargs});
	n = rows(scorecontribs);
	I = scorecontribs'*scorecontribs / n;
	J = numhessian("mle_obj", {theta, data, model, modelargs});
	J_inv = inverse(J);
	V = J_inv*I*J_inv/n;
endfunction
