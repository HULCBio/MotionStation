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

## usage: [obj_value, score] = nls_obj(theta, data, model, modelargs, nslaves)
##
## Returns the average sum of squared errors for a specified model
## This is for internal use by nls_estimate

function [obj_value, score] = nls_obj(theta, data, model, modelargs, nslaves)

	n = rows(data);

	if nslaves > 0
		global NEWORLD NSLAVES TAG
		nn = floor(n/(NSLAVES + 1)); # number of obsns per slave

		# The command that the slave nodes will execute
    		cmd=['contrib = nls_obj_nodes(theta, data, model, modelargs, nn); ',...
        	 'MPI_Send(contrib,0,TAG,NEWORLD);'];

		# send items to slaves
		NumCmds_Send({"theta", "nn", "cmd"}, {theta, nn, cmd});

		# evaluate last block on master while slaves are busy
	  	obj_value = nls_obj_nodes(theta, data, model, modelargs, nn);

		# collect slaves' results
		contrib = 0.0; # must be initialized to use MPI_Recv
	  	for i = 1:NSLAVES
			MPI_Recv(contrib,i,TAG,NEWORLD);
			obj_value = obj_value + contrib;
		endfor

		# compute the average
  		obj_value = obj_value / n;
  		score = "na"; # fix this later to allow analytic score in parallel

	else # serial version
    		[contribs, score] = feval(model, theta, data, modelargs);
		obj_value = mean(contribs);
    		if isnumeric(score) score = mean(score)'; endif # model passes "na" when score not available
  	endif

	# let's bullet-proof this in case the model goes nuts
	if (((abs(obj_value) == Inf)) || (isnan(obj_value))) obj_value = realmax; endif

endfunction
