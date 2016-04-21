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

## usage: [theta, V, obj_value] =
##  gmm_results(theta, data, weight, moments, momentargs, names, title, unscale, control, nslaves)
##
## inputs:
##      theta: column vector initial parameters
##       data: data matrix
##     weight: the GMM weight matrix
##    moments: name of function computes the moments
##             (should return nXg matrix of contributions)
## momentargs: (cell) additional inputs needed to compute moments.
##             May be empty ("")
##      names: vector of parameter names
##             e.g., names = char("param1", "param2");
##      title: string, describes model estimated
##    unscale: (optional) cell that holds means and std. dev. of data
##             (see scale_data)
##    control: (optional) BFGS or SA controls (see bfgsmin and samin). May be empty ("").
##    nslaves: (optional) number of slaves if executed in parallel
##             (requires MPITB)
##
## outputs:
## theta: GMM estimated parameters
## V: estimate of covariance of parameters. Assumes the weight matrix
##    is optimal (inverse of covariance of moments)
## obj_value: the value of the GMM objective function
##
## please type "gmm_example" while in octave to see an example

function [theta, V, obj_value] = gmm_results(theta, data, weight, moments, momentargs, names, title, unscale, control, nslaves)

  if nargin < 10 nslaves = 0; endif # serial by default

	if nargin < 9
		[theta, obj_value, convergence] = gmm_estimate(theta, data, weight, moments, momentargs, "", nslaves);
	else
		[theta, obj_value, convergence] = gmm_estimate(theta, data, weight, moments, momentargs, control, nslaves);
	endif


	m = feval(moments, theta, data, momentargs); # find out how many obsns. we have
	n = rows(m);

	if convergence == 1
		convergence="Normal convergence";
	else
		convergence="No convergence";
	endif

	V = gmm_variance(theta, data, weight, moments, momentargs);

	# unscale results if argument has been passed
	# this puts coefficients into scale corresponding to the original data
	if nargin > 7
		if iscell(unscale)
			[theta, V] = unscale_parameters(theta, V, unscale);
		endif
	endif

	[theta, V] = delta_method("parameterize", theta, {data, moments, momentargs}, V);

	k = rows(theta);
	se = sqrt(diag(V));

	printf("\n\n******************************************************\n");
	disp(title);
	printf("\nGMM Estimation Results\n");
	printf("BFGS convergence: %s\n", convergence);
	printf("\nObjective function value: %f\n", obj_value);
	printf("Observations: %d\n", n);

	junk = "X^2 test";
	df = n - k;
	if df > 0
		clabels = char("Value","df","p-value");
		a = [n*obj_value, df, 1 - chi2cdf(n*obj_value, df)];
		printf("\n");
		prettyprint(a, junk, clabels);
	else
		disp("\nExactly identified, no spec. test");
	end;

	# results for parameters
	a =[theta, se, theta./se, 2 - 2*normcdf(abs(theta ./ se))];
	clabels = char("estimate", "st. err", "t-stat", "p-value");
	printf("\n");
	prettyprint(a, names, clabels);

	printf("******************************************************\n");
endfunction
