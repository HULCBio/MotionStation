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

## kernel_regression: kernel regression estimator
##
## usage:
##      fit = kernel_regression(eval_points, depvar, condvars, bandwidth)
##
## inputs:
##      eval_points: PxK matrix of points at which to calculate the density
##      depvar: Nx1 vector of observations of the dependent variable
##      condvars: NxK matrix of data points
##      bandwidth (optional): positive scalar, the smoothing parameter.
##              Default is N ^ (-1/(4+K))
##      kernel (optional): string. Name of the kernel function. Default is
##              Gaussian kernel.
##      prewhiten bool (optional): default true. If true, rotate data
##              using Choleski decomposition of inverse of covariance,
##              to approximate independence after the transformation, which
##              makes a product kernel a reasonable choice.
##      do_cv: bool (optional). default false. If true, calculate leave-1-out
##               fit to calculate the cross validation score
##      computenodes: int (optional, default 0).
##              Number of compute nodes for parallel evaluation
##      debug: bool (optional, default false). show results on compute nodes if doing
##              a parallel run
## outputs:
##      fit: Px1 vector: the fitted value at each of the P evaluation points.

function z = kernel_regression(eval_points, depvar, condvars, bandwidth, kernel, prewhiten, do_cv, computenodes, debug)

	if nargin < 3; error("kernel_regression: at least 3 arguments are required"); endif

	n = rows(condvars);
	k = columns(condvars);

	# set defaults for optional args
	if (nargin < 4) bandwidth = (n ^ (-1/(4+k))); endif	# bandwidth - see Li and Racine pg. 66
	if (nargin < 5) kernel = "kernel_normal"; endif 	# what kernel?
	if (nargin < 6) prewhiten = true; endif 		# automatic prewhitening?
	if (nargin < 7)	do_cv = false; endif 			# ordinary or leave-1-out
	if (nargin < 8)	computenodes = 0; endif			# parallel?
	if (nargin < 9)	debug = false; endif;			# debug?


	nn = rows(eval_points);
	n = rows(depvar);

	if prewhiten
		H = bandwidth*chol(cov(condvars));
 	else
		H = bandwidth;
	endif
	H_inv = inv(H);

	# weight by inverse bandwidth matrix
	eval_points = eval_points*H_inv;
	condvars = condvars*H_inv;

	data = [depvar condvars]; # put it all together for sending to nodes

	# check if doing this parallel or serial
	global PARALLEL NSLAVES NEWORLD NSLAVES TAG
	PARALLEL = 0;

	if computenodes > 0
		PARALLEL = 1;
		NSLAVES = computenodes;
		LAM_Init(computenodes, debug);
	endif

	if !PARALLEL # ordinary serial version
		points_per_node = nn; # do the all on this node
		z = kernel_regression_nodes(eval_points, data, do_cv, kernel, points_per_node, computenodes, debug);
	else # parallel version
		z = zeros(nn,1);
		points_per_node = floor(nn/(NSLAVES + 1)); # number of obsns per slave
		# The command that the slave nodes will execute
		cmd=['z_on_node = kernel_regression_nodes(eval_points, data, do_cv, kernel, points_per_node, computenodes, debug); ',...
		'MPI_Send(z_on_node, 0, TAG, NEWORLD);'];

		# send items to slaves

		NumCmds_Send({"eval_points", "data", "do_cv", "kernel", "points_per_node", "computenodes", "debug","cmd"}, {eval_points, data, do_cv, kernel, points_per_node, computenodes, debug, cmd});

		# evaluate last block on master while slaves are busy
		z_on_node = kernel_regression_nodes(eval_points, data, do_cv, kernel, points_per_node, computenodes, debug);
		startblock = NSLAVES*points_per_node + 1;
		endblock = nn;
		z(startblock:endblock,:) = z(startblock:endblock,:) + z_on_node;

		# collect slaves' results
		z_on_node = zeros(points_per_node,1); # size may differ between master and compute nodes - reset here
		for i = 1:NSLAVES
			MPI_Recv(z_on_node,i,TAG,NEWORLD);
			startblock = i*points_per_node - points_per_node + 1;
			endblock = i*points_per_node;
			z(startblock:endblock,:) = z(startblock:endblock,:) + z_on_node;
		endfor

		# clean up after parallel
		LAM_Finalize;
	endif
endfunction
