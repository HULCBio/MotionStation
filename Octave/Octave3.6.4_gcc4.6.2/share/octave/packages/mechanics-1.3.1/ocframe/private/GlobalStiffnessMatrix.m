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

function K=GlobalStiffnessMatrix(joints,members,memberstiffnessmatrices,membertransformationmatrices)
	K=sparse(rows(joints)*3,rows(joints)*3);

	# sparse matrix is even usefull for small frames:
	#  example:
	#  Attr Name           Size                     Bytes  Class
	#  ==== ====           ====                     =====  ===== 
	#       K_full        36x36                     10368  double
	#       K_sparse      36x36                      2836  double

	if (nargin==2)
		#joints: [x, y, constraints; ...] 1= fixed
		#members [nodeN,nodeF,E,I,A; ...]
		for member=1:rows(members)
			N=members(member,1);
			F=members(member,2);
			xN=joints(N,1);
			yN=joints(N,2);
			xF=joints(F,1);
			yF=joints(F,2);
			%T=TransformationMatrix(xN,yN,xF,yF);
			%k=transpose(T)*MemberStiffnessMatrix(sqrt((xN-xF)**2+(yN-yF)**2),members(member,3),members(member,4),members(member,5))*T;
			c=[node2code(N),node2code(F)];
		
			%TransformationMatrix stuff
			L=sqrt((xN-xF)^2+(yN-yF)^2);
			l=(xF-xN)/L;
			m=(yF-yN)/L;
			%MemberStiffnessMatrix stuff
			E=members(member,3);
			I=members(member,4);
			A=members(member,5);
		
			%for i=1:rows(k)
			%	for j=1:columns(k)
			%		K(c(i),c(j))=K(c(i),c(j))+k(i,j);
			%	end
			%end
		
			%fill Global Stiffness Matrix
			K(c(1),c(1))+=(l^2*A*E)/L+(12*m^2*E*I)/L^3;
			K(c(1),c(2))+=(l*m*A*E)/L-(12*l*m*E*I)/L^3;
			K(c(1),c(3))+=-(6*m*E*I)/L^2;
			K(c(1),c(4))+=-(l^2*A*E)/L-(12*m^2*E*I)/L^3;
			K(c(1),c(5))+=(12*l*m*E*I)/L^3-(l*m*A*E)/L;
			K(c(1),c(6))+=-(6*m*E*I)/L^2;
			K(c(2),c(1))+=(l*m*A*E)/L-(12*l*m*E*I)/L^3;
			K(c(2),c(2))+=(m^2*A*E)/L+(12*l^2*E*I)/L^3;
			K(c(2),c(3))+=(6*l*E*I)/L^2;
			K(c(2),c(4))+=(12*l*m*E*I)/L^3-(l*m*A*E)/L;
			K(c(2),c(5))+=-(m^2*A*E)/L-(12*l^2*E*I)/L^3;
			K(c(2),c(6))+=(6*l*E*I)/L^2;
			K(c(3),c(1))+=-(6*m*E*I)/L^2;
			K(c(3),c(2))+=(6*l*E*I)/L^2;
			K(c(3),c(3))+=(4*E*I)/L;
			K(c(3),c(4))+=(6*m*E*I)/L^2;
			K(c(3),c(5))+=-(6*l*E*I)/L^2;
			K(c(3),c(6))+=(2*E*I)/L;
			K(c(4),c(1))+=-(l^2*A*E)/L-(12*m^2*E*I)/L^3;
			K(c(4),c(2))+=(12*l*m*E*I)/L^3-(l*m*A*E)/L;
			K(c(4),c(3))+=(6*m*E*I)/L^2;
			K(c(4),c(4))+=(l^2*A*E)/L+(12*m^2*E*I)/L^3;
			K(c(4),c(5))+=(l*m*A*E)/L-(12*l*m*E*I)/L^3;
			K(c(4),c(6))+=(6*m*E*I)/L^2;
			K(c(5),c(1))+=(12*l*m*E*I)/L^3-(l*m*A*E)/L;
			K(c(5),c(2))+=-(m^2*A*E)/L-(12*l^2*E*I)/L^3;
			K(c(5),c(3))+=-(6*l*E*I)/L^2;
			K(c(5),c(4))+=(l*m*A*E)/L-(12*l*m*E*I)/L^3;
			K(c(5),c(5))+=(m^2*A*E)/L+(12*l^2*E*I)/L^3;
			K(c(5),c(6))+=-(6*l*E*I)/L^2;
			K(c(6),c(1))+=-(6*m*E*I)/L^2;
			K(c(6),c(2))+=(6*l*E*I)/L^2;
			K(c(6),c(3))+=(2*E*I)/L;
			K(c(6),c(4))+=(6*m*E*I)/L^2;
			K(c(6),c(5))+=-(6*l*E*I)/L^2;
			K(c(6),c(6))+=(4*E*I)/L;
		end
	end
	if (nargin==4)
		#joints: [x, y, constraints; ...] 1= fixed
		#members [nodeN,nodeF,E,I,A; ...]
		for member=1:rows(members)
			N=members(member,1);
			F=members(member,2);
			c=[node2code(N),node2code(F)];

			xN=joints(N,1);
			yN=joints(N,2);
			xF=joints(F,1);
			yF=joints(F,2);
			%T=TransformationMatrix(xN,yN,xF,yF);
			%k=transpose(T)*MemberStiffnessMatrix(sqrt((xN-xF)**2+(yN-yF)**2),members(member,3),members(member,4),members(member,5))*T;
			k=transpose(membertransformationmatrices{member,1})*memberstiffnessmatrices{member,1}*membertransformationmatrices{member,1};
		
			for i=1:rows(k)
				for j=1:columns(k)
					K(c(i),c(j))=K(c(i),c(j))+k(i,j);
				end
			end
		end
	end
end
