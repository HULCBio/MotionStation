## Copyright (C) 2008 Muthiah Annamalai <muthiah.annamalai@uta.edu>
## 
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; If not, see <http://www.gnu.org/licenses/>.
##

## -*- texinfo -*-
## @deftypefn {Function File} {}  grayenc (@var{p})
##
## Encodes the binary code @var{p} to the
## gray code. Also @var{p} can be a decimal number
## which is automatically converted to binary.
## 
## @end deftypefn
## @seealso{graydec}

function v_c=grayenc(v_a)
	if(max(v_a) > 1)
		##convert from decimal to bitvector
		##this returns vector in MSB->LSB sense
		##
		L=floor(log2(v_a))+1;
		v_a=[bitand(v_a,2.^(L-1:-1:0))>0];
	end

	v_c=zeros(1,length(v_a));
	v_c(1)=v_a(1);
	v_c(2:end)=xor(v_a(1:end-1),v_a(2:end));
	return;
end
%!assert(grayenc([0 1 1]),[0 1 0])
