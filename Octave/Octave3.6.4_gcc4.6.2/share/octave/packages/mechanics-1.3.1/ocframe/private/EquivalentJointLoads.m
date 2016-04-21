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

function [P_F,MemFEF]=EquivalentJointLoads(joints,members,dist,point)
	% joints: [x, y, constraints; ...] 1= fixed
	% members [nodeN,nodeF,E,I,A; ...]
	% dist containts distributed loads on members
	%	[membernum,FxN,FyN,FxF,FyF,a,b,local ; ...]
	% point contains the point loads on members
	%   [membernum,Fx,Fy,a,local; ...]
	% local=1 if in local coords

	P_F=zeros(rows(joints)*3,1);
	MemFEF=zeros(rows(members),6);
	%distributed loads
	for i=1:rows(dist)
		membernum=dist(i,1);
		FxN=dist(i,2);
		FyN=dist(i,3);
		FxF=dist(i,4);
		FyF=dist(i,5);
		a=dist(i,6);
		b=dist(i,7);
		local=dist(i,8);
		N=members(membernum,1);
		F=members(membernum,2);
		if (local==0)
			%convert FxN,... to local axes
			temp=[FxN,FyN,0,FxF,FyF,0];
			temp=(TransformationMatrix(joints(N,1),joints(N,2),joints(F,1),joints(F,2))')^-1*temp';
			FxN=temp(1);
			FyN=temp(2);
			FxF=temp(4);
			FyF=temp(5);
		end
		[F1,F2,F3,F4,F5,F6]=FixedEndForcesDist(sqrt((joints(N,1)-joints(F,1))^2+(joints(F,2)-joints(N,2))^2),FxN,FyN,FxF,FyF,a,b);
		F_local=[F1,F2,F3,F4,F5,F6];
		F_global=((TransformationMatrix(joints(N,1),joints(N,2),joints(F,1),joints(F,2))')*F_local')';
		
		c=[node2code(N),node2code(F)];
		for j=1:6
			P_F(c(j))+=F_global(j);
			MemFEF(membernum,j)+=F_local(j);
		end
	end
	for i=1:rows(point)
		%[membernum,Fx,Fy,a,local; ...]
		membernum=point(i,1);
		Fx=point(i,2);
		Fy=point(i,3);
		a=point(i,4);
		local=point(i,5);
		N=members(membernum,1);
		F=members(membernum,2);
		if (local==0)
			%convert to global axes
			temp=[Fx,Fy,0,0,0,0];
			temp=(TransformationMatrix(joints(N,1),joints(N,2),joints(F,1),joints(F,2))')^-1*temp';
			Fx=temp(1);
			Fy=temp(2);
		end
		%FixedEndForcesPnt(l,a,Fx,Fy)
		[F1,F2,F3,F4,F5,F6]=FixedEndForcesPnt(sqrt((joints(N,1)-joints(F,1))^2+(joints(F,2)-joints(N,2))^2),a,Fx,Fy);
		F_local=[F1,F2,F3,F4,F5,F6];
		F_global=((TransformationMatrix(joints(N,1),joints(N,2),joints(F,1),joints(F,2))')*F_local')';
		
		c=[node2code(N),node2code(F)];
		for j=1:6
			P_F(c(j))+=F_global(j);
			MemFEF(membernum,j)+=F_local(j);
		end
	end
end
