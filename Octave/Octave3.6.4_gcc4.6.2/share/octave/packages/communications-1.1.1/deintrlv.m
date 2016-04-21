## Copyright (C) 2008 Sylvain Pelissier <sylvain.pelissier@gmail.com>
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
## @deftypefn {Function File} {@var{deintrlvd} =} deintrlv (@var{data}, @var{elements})
## Restore elements of @var{data} according to @var{elements}.
## @seealso{intrlv}
## @end deftypefn

function deintrlvd = deintrlv(data,elements)
	if(nargin < 2 || nargin >2)
		error('usage : deinterlvd = deinterlv(data,elements)');
	end
	
	if(~isvector(elements))
		error("Elements must be a vector");
	end
	
	ind = 1:length(elements);
	invperm(elements) = ind;
	
	if(isvector(data))
		if(length(elements) ~= length(data) || any(sort(elements) ~= 1:length(data)))
			error("elements must be a permutation of data indices");
		end
		deintrlvd = data(invperm);
	else
		if(length(elements) ~= size(data,1) || any(sort(elements) ~= 1:size(data,1)))
			error("elements must be a permutation of data indices");
		end
		deintrlvd = data(invperm,:);
	end
