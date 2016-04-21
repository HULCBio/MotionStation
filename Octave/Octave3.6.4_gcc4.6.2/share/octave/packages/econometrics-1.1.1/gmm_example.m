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

## GMM example file, shows initial consistent estimator,
## estimation of efficient weight, and second round
## efficient estimator

n = 1000;
k = 5;

x = [ones(n,1) randn(n,k-1)];
w = [x, rand(n,1)];
theta_true = ones(k,1);
lambda = exp(x*theta_true);
y = poissrnd(lambda);
[xs, scalecoef] = scale_data(x);

# The arguments for gmm_estimate
theta = zeros(k,1);
data = [y xs w];
weight = eye(columns(w));
moments = "poisson_moments";
momentargs = {k}; # needed to know where x ends and w starts

# additional args for gmm_results
names = char("theta1", "theta2", "theta3", "theta4", "theta5");
gmmtitle = "Poisson GMM trial";
control = {100,0,1,1};


# initial consistent estimate: only used to get efficient weight matrix, no screen output
[theta, obj_value, convergence] = gmm_estimate(theta, data, weight, moments, momentargs, control);

# efficient weight matrix
# this method is valid when moments are not autocorrelated
# the user is reponsible to properly estimate the efficient weight
m = feval(moments, theta, data, momentargs);
weight = inverse(cov(m));

# second round efficient estimator
gmm_results(theta, data, weight, moments, momentargs, names, gmmtitle, scalecoef, control);
printf("\nThe true parameter values used to generate the data:\n");
prettyprint(theta_true, names, "value");

# Example doing estimation in parallel on a cluster (requires MPITB)
# uncomment the following if you have MPITB installed
# nslaves = 1;
# theta = zeros(k,1);
# nslaves = 1;
# title = "GMM estimation done in parallel";
# gmm_results(theta, data, weight, moments, momentargs, names, gmmtitle, scalecoef, control, nslaves);
