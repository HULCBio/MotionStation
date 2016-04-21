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

## for internal use by gmm_estimate 

## average moments (separate function so it can be differentiated)
function m = average_moments(theta, data, moments, momentargs)
	
	global NSLAVES PARALLEL NEWORLD NSLAVES TAG;

	n = rows(data);

	if PARALLEL
    		nn = floor(n/(NSLAVES + 1)); # save some work for master
    
		#  The command that the slave nodes will execute
    		cmd=['contrib = sum_moments_nodes(theta, data, moments, momentargs, nn); ',...	
         		'MPI_Send(contrib,0,TAG,NEWORLD);'];	

		# send items to slaves
		NumCmds_Send({"theta", "nn", "cmd"},{theta, nn, cmd});

		# evaluate last block on master while slaves are busy
   		m = feval("sum_moments_nodes", theta, data, moments, momentargs, nn);

		# collect slaves' results
		contrib = zeros(1,columns(m));
    		for i = 1:NSLAVES
			MPI_Recv(contrib,i,TAG,NEWORLD);
			m = m + contrib;
    		endfor

		m = m'; # we want a column vector, please
		m = m/n; # average please, not sum

	else # serial version
		m = feval(moments, theta, data, momentargs);
		m = mean(m)';  # returns Gx1 moment vector
	endif
	
endfunction
