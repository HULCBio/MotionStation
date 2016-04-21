## Copyright (C) 2007 Michael Creel <michael.creel@uab.es>
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

## kernel_example: examples of how to use kernel density and regression functions
## requires the optim and plot packages from Octave Forge
##
## usage: kernel_example;

# sample size (default n = 500) - should get better fit (on average)
# as this increases, supposing that you allow the optimal window width
# to be found, by uncommenting the relevant lines
n = 500;

# set this to greater than 0 to try parallel computations (requires MPITB)
compute_nodes = 0;
nodes = compute_nodes + 1; # count master node

close all;
hold off;

############################################################
# kernel regression example
# uniformly spaced data points on [0,2]
x = 1:n;
x = x';
x = 2*x/n;
# generate dependent variable
trueline =  x + (x.^2)/2 - 3.1*(x.^3)/3 + 1.2*(x.^4)/4;
sig = 0.5;
y = trueline + sig*randn(n,1);
tic;
fit = kernel_regression(x, y, x); # use the default bandwidth
t1 = toc;
printf("\n");
printf("########################################################################\n");
printf("time for kernel regression example using %d data points and %d compute nodes: %f\n", n, nodes, t1);
plot(x, fit, ";fit;", x, trueline,";true;");
grid("on");
title("Example 1: Kernel regression fit");

############################################################
# kernel density example: univariate - fit to Chi^2(3) data
data = sumsq(randn(n,3),2);
# evaluation point are on a grid for plotting
stepsize = 0.2;
grid_x = (-1:stepsize:11)';
bandwidth = 0.55;
# get optimal bandwidth (time consuming, uncomment if you want to try it)
# bandwidth = kernel_optimal_bandwidth(data);
# get the fitted density and do a plot
tic;
dens = kernel_density(grid_x, data, bandwidth, "kernel_normal", false, false, compute_nodes);
t1 = toc;
printf("\n");
printf("########################################################################\n");
printf("time for univariate kernel density example using %d data points and %d compute nodes: %f\n", n, nodes, t1);
printf("A rough integration under the fitted univariate density is %f\n", sum(dens)*stepsize);
figure();
plot(grid_x, dens, ";fitted density;", grid_x, chi2pdf(grid_x,3), ";true density;");
title("Example 2: Kernel density fit: Univariate Chi^2(3) data");

############################################################
# kernel density example: bivariate
# X ~ N(0,1)
# Y ~ Chi squared(3)
# X, Y are dependent
d = randn(n,3);
data = [d(:,1) sumsq(d,2)];
# evaluation points are on a grid for plotting
stepsize = 0.2;
a = (-5:stepsize:5)'; # for the N(0,1)
b = (-1:stepsize:9)';  # for the Chi squared(3)
gridsize = rows(a);
[grid_x, grid_y] = meshgrid(a, b);
eval_points = [vec(grid_x) vec(grid_y)];
bandwidth = 0.85;
# get optimal bandwidth (time consuming, uncomment if you want to try it)
# bandwidth = kernel_optimal_bandwidth(data);
# get the fitted density and do a plot
tic;
dens = kernel_density(eval_points, data, bandwidth, "kernel_normal", false, false, compute_nodes);
t1 = toc;
printf("\n");
printf("########################################################################\n");
printf("time for multivariate kernel density example using %d data points and %d compute nodes: %f\n", n, nodes, t1);
dens = reshape(dens, gridsize, gridsize);
printf("A rough integration under the fitted bivariate density is %f\n", sum(sum(dens))*stepsize^2);
figure();
surf(grid_x, grid_y, dens);
title("Example 3: Kernel density fit: dependent bivariate data");
xlabel("true marginal density is N(0,1)");
ylabel("true marginal density is Chi^2(3)");
# more extensive test of parallel
if compute_nodes > 0 # only try this if parallel is available
	ns =[4000; 8000; 10000; 12000; 16000; 20000];
	printf("\n");
	printf("########################################################################\n");
	printf("kernel regression example with several sample sizes serial/parallel timings\n");
	figure();
	clf;
	title("Compute time versus nodes, kernel regression with different sample sizes");
	xlabel("nodes");
	ylabel("time (sec)");
	hold on;
	ts = zeros(rows(ns),4);
	for i = 1:rows(ns)
		for compute_nodes = 0:3
			nodes = compute_nodes + 1;
			n = ns(i,:);
			x = 1:n;
			x = x';
			x = 2*x/n;
			# generate dependent variable
			trueline =  x + (x.^2)/2 - 3.1*(x.^3)/3 + 1.2*(x.^4)/4;
			sig = 0.5;
			y = trueline + sig*randn(n,1);
			bandwidth = 0.45;
			tic;
			fit = kernel_regression(x, y, x, bandwidth, "kernel_normal", false, false, compute_nodes);
			t1 = toc;
			ts(i, nodes) = t1;
			plot(nodes, t1, "*");
			printf(" %d data points and %d compute nodes: %f\n", n, nodes, t1);
		endfor
		plot(ts(i,:)');
	endfor
	hold off;
endif
