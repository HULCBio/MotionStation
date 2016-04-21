## Copyright (C) 2010 Johan Beke
##
## This software is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or (at
## your option) any later version.
##
## This software is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this software; see the file COPYING.  If not, see
## <http://www.gnu.org/licenses/>.

function T_array=MemberTransformationMatrices(joints,members)

	T_array = cell(rows(members),1); # is one column better than one row?

	for member=1:rows(members)
		N=members(member,1);
		F=members(member,2);
		xN=joints(N,1);
		yN=joints(N,2);
		xF=joints(F,1);
		yF=joints(F,2);
		T_array{member,1}=TransformationMatrix(xN,yN,xF,yF);
	end
end
