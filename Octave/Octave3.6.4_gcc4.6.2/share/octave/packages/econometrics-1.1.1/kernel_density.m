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

## kernel_density: multivariate kernel density estimator
##
## usage:
##       dens = kernel_density(eval_points, data, bandwidth)
##
## inputs:
##       eval_points: PxK matrix of points at which to calculate the density
##       data: NxK matrix of data points
##       bandwidth: positive scalar, the smoothing parameter. The fit
##               is more smooth as the bandwidth increases.
##       kernel (optional): string. Name of the kernel function. Default is
##               Gaussian kernel.
##       prewhiten bool (optional): default false. If true, rotate data
##               using Choleski decomposition of inverse of covariance,
##               to approximate independence after the transformation, which
##               makes a product kernel a reasonable choice.
##       do_cv: bool (optional). default false. If true, calculate leave-1-out
##                density for cross validation
##       computenodes: int (optional, default 0).
##               Number of compute nodes for parallel evaluation
##       debug: bool (optional, default false). show results on compute nodes if doing
##               a parallel run
## outputs:
##       dens: Px1 vector: the fitted density value at each of the P evaluation points.
##
## References:
## Wand, M.P. and Jones, M.C. (1995), 'Kernel smoothing'.
## http://www.xplore-stat.de/ebooks/scripts/spm/html/spmhtmlframe73.html

function z = kernel_density(eval_points, data, bandwidth, kernel, prewhiten, do_cv, computenodes, debug)

	if nargin < 2; error("kernel_density: at least 2 arguments are required"); endif

	n = rows(data);
	k = columns(data);


	# set defaults for optional args
	if (nargin < 3) bandwidth = (n ^ (-1/(4+k))); endif	# bandwidth - see Li and Racine pg. 26
	if (nargin < 4) kernel = "kernel_normal"; endif # what kernel?
	if (nargin < 5) prewhiten = false; endif 	# automatic prewhitening?
	if (nargin < 6)	do_cv = false; endif 		# ordinary or leave-1-out
	if (nargin < 7)	computenodes = 0; endif		# parallel?
	if (nargin < 8)	debug = false; endif;		# debug?

	nn = rows(eval_points);
	n = rows(data);
	if prewhiten
		H = bandwidth*chol(cov(data));
 	else
		H = bandwidth;
	endif

	# Inverse bandwidth matrix H_inv
	H_inv = inv(H);

	# weight by inverse bandwidth matrix
	eval_points = eval_points*H_inv;
	data = data*H_inv;

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
		z = kernel_density_nodes(eval_points, data, do_cv, kernel, points_per_node, computenodes, debug);
	else # parallel version
		z = zeros(nn,1);
		points_per_node = floor(nn/(NSLAVES + 1)); # number of obsns per slave
		# The command that the slave nodes will execute
		cmd=['z_on_node = kernel_density_nodes(eval_points, data, do_cv, kernel, points_per_node, computenodes, debug); ',...
		'MPI_Send(z_on_node, 0, TAG, NEWORLD);'];

		# send items to slaves

		NumCmds_Send({"eval_points", "data", "do_cv", "kernel", "points_per_node", "computenodes", "debug","cmd"}, {eval_points, data, do_cv, kernel, points_per_node, computenodes, debug, cmd});

		# evaluate last block on master while slaves are busy
		z_on_node = kernel_density_nodes(eval_points, data, do_cv, kernel, points_per_node, computenodes, debug);
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
	z = z*det(H_inv);
endfunction
