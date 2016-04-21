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
## @deftypefn {Function File} {@var{outdata} =} helscanintrlv (@var{data}, @var{nrows}, @var{ncols},@var{Nshift})
## @var{nrows}-by-@var{ncols}.
## @seealso{helscandeintrlv}
## @end deftypefn

function outdata = helscanintrlv(data,Nrows,Ncols,Nshift)
	
	if(nargin ~= 4 )
		error('usage : interlvd = helscanintrlv(data,Nrows,Ncols,Nshift)');
	end

	if(~isscalar(Nrows) || ~isscalar(Ncols))
		error("Nrows and Ncols must be integers");
	end
	
	if( Nrows ~= floor(Nrows)|| Ncols ~= floor(Ncols))
		error("Nrows and Ncols must be integers");
	end

	didTranspose=0;
	if ( isvector(data) && columns(data) > rows(data) )
		data = data.';
		didTranspose=1;
	end

	s = size(data);

	if size(data,1) ~= Nrows*Ncols
		error("The length of data must be equals to Ncols*Nrows");
	end

	# create the interleaving indices 
	idx0 = 0:Nrows*Ncols-1; 
	idxMod = rem(idx0,Ncols); 
	idxFlr = idx0 - idxMod;
	inds = 1+rem(idxFlr + idxMod * Ncols * Nshift + idxMod,Nrows*Ncols);

	# for each column
	for k = 1:s(2)
		outdata(:,k) = data(inds,k);
	end

	if didTranspose
		outdata = outdata.';
	end
