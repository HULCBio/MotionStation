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

## usage: [theta, obj_value, convergence, iters] =
##           gmm_estimate(theta, data, weight, moments, momentargs, control, nslaves)
##
## inputs:
##      theta: column vector initial parameters
##       data: data matrix
##     weight: the GMM weight matrix
##    moments: name of function computes the moments
##	      (should return nXg matrix of contributions)
## momentargs: (cell) additional inputs needed to compute moments.
## 	      May be empty ("")
##    control: (optional) BFGS or SA controls (see bfgsmin and samin).
##             May be empty ("").
##    nslaves: (optional) number of slaves if executed in parallel
##             (requires MPITB)
##
## outputs:
## theta: GMM estimate of parameters
## obj_value: the value of the gmm obj. function
## convergence: return code from bfgsmin
##              (1 means success, see bfgsmin for details)
## iters: number of BFGS iteration used
##
## please type "gmm_example" while in octave to see an example

## call the minimizing routine
function [theta, obj_value, convergence, iters] = gmm_estimate(theta, data, weight, moments, momentargs, control, nslaves)

	if nargin < 5 error("gmm_estimate: 5 arguments required"); endif
	if nargin < 6 control = {-1}; endif # default controls
	if !iscell(control) control = {-1}; endif # default controls if receive placeholder
	if nargin < 7 nslaves = 0; endif

 	if nslaves > 0
		global NSLAVES PARALLEL NEWORLD NSLAVES TAG;
		LAM_Init(nslaves);
		# Send the data to all nodes
		NumCmds_Send({"data", "weight", "moments", "momentargs"}, {data, weight, moments, momentargs});
	endif

	# bfgs or sa?
	if (size(control,1)*size(control,2) == 0) # use default bfgs if no control
		control = {Inf,0,1,1};
		method = "bfgs";
	elseif (size(control,1)*size(control,2) < 11)
		method = "bfgs";
	else method = "sa";
	endif


	if strcmp(method, "bfgs")
		[theta, obj_value, convergence, iters] = bfgsmin("gmm_obj", {theta, data, weight, moments, momentargs}, control);
	elseif strcmp(method, "sa")
	  	[theta, obj_value, convergence] = samin("gmm_obj", {theta, data, weight, moments, momentargs}, control);
	endif

	if nslaves > 0 LAM_Finalize; endif # clean up

endfunction
