## Copyright (C) 2010 Mark Borgerding <mark@borgerding.net>
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

## -*- texinfo -*-
## @deftypefn {Function File} {@var{outdata} =} helintrlv (@var{data}, @var{col}, @var{ngrp},@var{stp})
## @var{col}-by-@var{ngrp}.
## @seealso{heldeintrlv}
## @end deftypefn

function [outdata,outstate] = helintrlv(data,col,ngrp,stp,init_state)

	if (nargin < 4  ||nargin>5)
		error('usage : interlvd = helintrlv(data,col,ngrp,stp)');
	end

	if(~isscalar(col) || ~isscalar(ngrp))
		error("col and ngrp must be integers");
	end
	
	if( col ~= floor(col)|| ngrp ~= floor(ngrp))
		error("col and ngrp must be integers");
	end

	didTranspose=0;
	if ( isvector(data) && columns(data) > rows(data) )
		data = data.';
		didTranspose=1;
	end

	s = size(data);

	if s(1) ~= col*ngrp
		error("The length of data must be equals to ngrp*col");
	end

	if nargin==4
		init_state = zeros(stp*col*(col-1)/2,s(2));
	end

	outstate =[];
	# for each column
	for k = 1:s(2)
		tmp = reshape( data(:,k) , ngrp, col );
		instate = init_state(:,k);
		outstateCol=[];
		for k1=2:col
			curStepSize = (k1-1)*stp;
			tmpCol= [instate(1:curStepSize) ;tmp(:,k1)];
			tmp(:,k1) = tmpCol(1:ngrp);
			outstateCol=[outstateCol;tmpCol(end+1-curStepSize:end)];
			instate = instate(curStepSize+1:end);
		end
		outdata(:,k) = reshape(tmp.',s(1),1);
		outstate =  [outstate outstateCol];
	end

	if didTranspose
		outdata = outdata.';
	end
