## Copyright (C) 2005 Michael Creel <michael.creel@uab.es>
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

## usage:
## [theta, obj_value, conv, iters] = nls_estimate(theta, data, model, modelargs, control, nslaves)
##
## inputs:
## theta: column vector of model parameters
## data: data matrix
## model: name of function that computes the vector of sums of squared errors
## modelargs: (cell) additional inputs needed by model. May be empty ("")
## control: (optional) BFGS or SA controls (see bfgsmin and samin). May be empty ("").
## nslaves: (optional) number of slaves if executed in parallel (requires MPITB)
##
## outputs:
## theta: NLS estimated value of parameters
## obj_value: the value of the sum of squared errors at NLS estimate
## conv: return code from bfgsmin (1 means success, see bfgsmin for details)
## iters: number of BFGS iteration used
##
## please see nls_example.m for examples of how to use this

function [theta, obj_value, convergence, iters] = nls_estimate(theta, data, model, modelargs, control, nslaves)

	if nargin < 3
		error("nls_estimate: 3 arguments required");
	endif

	if nargin < 4 modelargs = {}; endif # create placeholder if not used
	if !iscell(modelargs) modelargs = {}; endif # default controls if receive placeholder
	if nargin < 5 control = {Inf,0,1,1}; endif # default controls and method
	if !iscell(control) control = {Inf,0,1,1}; endif # default controls if receive placeholder
	if nargin < 6 nslaves = 0; endif

	if nslaves > 0
		global NSLAVES PARALLEL NEWORLD TAG
		LAM_Init(nslaves);
		# Send the data to all nodes
		NumCmds_Send({"data", "model", "modelargs"}, {data, model, modelargs});
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
	  [theta, obj_value, convergence, iters] = bfgsmin("nls_obj", {theta, data, model, modelargs, nslaves}, control);
	elseif strcmp(method, "sa")
	  [theta, obj_value, convergence] = samin("nls_obj", {theta, data, model, modelargs, nslaves}, control);
	endif

	# cleanup
	if nslaves > 0 LAM_Finalize; endif
endfunction
