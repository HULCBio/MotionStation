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

## Example to show how to use NLS

# Generate data
n = 100; # how many observations?

# the explanatory variables: note that they have unequal scales
x = [ones(n,1) rand(n,2)];
theta = 1:3; # true coefficients are 1,2,3
theta = theta';

lambda = exp(x*theta);
y = randp(lambda); # generate the dependent variable

# example objective function for nls
function [obj_contrib, score] = nls_example_obj(theta, data, otherargs)
	y = data(:,1);
	x = data(:,2:columns(data));
	lambda = exp(x*theta);
	errors =  y - lambda;
	obj_contrib = errors .* errors;
	score = "na";
endfunction


#####################################
# define arguments for nls_estimate #
#####################################
# starting values
theta = zeros(3,1);
# data
data = [y, x];
# name of model to estimate
model = "nls_example_obj";
modelargs = {}; # none required for this obj fn.
# controls for bfgsmin - limit to 50 iters, and print final results
control = {50,1};

####################################
# do the estimation		   #
####################################
printf("\nNLS estimation example\n");
[theta, obj_value, convergence] = nls_estimate(theta, data, model, modelargs, control);
