## Copyright (C) 2007 Sylvain Pelissier <sylvain.pelissier@gmail.com>
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
## @deftypefn {Function File} {@var{y} =} bsc (@var{data}, @var{p})
## Send @var{data} into a binary symetric channel with probability
## @var{p} of error one each symbol.
## @end deftypefn

function [ndata] = bsc(data,p)
	if (nargin < 1); usage('ndata = bsc(data,p)'); end
	
	if(isscalar(p) ~= 1 || p > 1 || p < 0)
		error('p muste be a positive scalar less than one');
		exit;
	end
	if(any(data(:) ~= floor(data(:))) || any(data(:) > 1) || any(data(:) < 0))
		error('data must be a binary sequence');
		exit;
	end
	
	ndata = data;
	ndata(find(data == 0)) = randsrc(size(ndata(find(data == 0)),1),size(ndata(find(data == 0)),2),[-1 -2;1-p p]);
	ndata(find(data == 1)) = randsrc(size(ndata(find(data == 1)),1),size(ndata(find(data == 1)),2),[1 0;1-p p]);
	ndata(find(ndata == -1)) = 0;
	ndata(find(ndata == -2)) = 1;
	
