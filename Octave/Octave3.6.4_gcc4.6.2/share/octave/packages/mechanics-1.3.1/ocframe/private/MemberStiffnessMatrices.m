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

#MemberStiffnessMatrix(L,E,I,A)
function k_array=MemberStiffnessMatrices(joints,members)

	k_array = cell(rows(members),1); # is one column better than one row?
	for member=1:rows(members)
		N=members(member,1);
		F=members(member,2);
		xN=joints(N,1);
		yN=joints(N,2);
		xF=joints(F,1);
		yF=joints(F,2);
		
		# calculate the member stiffness matrix in local coordinates and add to array
		k_array{member,1}=MemberStiffnessMatrix(sqrt((xN-xF)**2+(yN-yF)**2),members(member,3),members(member,4),members(member,5));
	end
end
