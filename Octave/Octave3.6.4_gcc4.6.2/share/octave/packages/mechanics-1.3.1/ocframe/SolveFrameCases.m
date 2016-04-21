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

## -*- texinfo -*-
## @deftypefn {Function File} {[@var{results}] =} SolveFrameCases (@var{joints}, @var{members}, @var{loadcases}) 
##
##
## Solves a 2D frame with the matrix displacement method for
## the following input parameters:
##
##    joints = [x , y, constraints ; ...]
##
##    constraints=[x , y, rotation] free=0, supported=1
##
##    members = [nodeN, nodeF, E, I, A; ...]
##
##    loadcases is a struct array with for each loadcase the fields
##
##     - nodeloads = [node, Fx, Fy, Mz; ...]
##
##     - dist = [membernum,FxN,FyN,FxF,FyF,a,b,local ; ...]
##
##     - point = [membernum,Fx,Fy,a,local; ...]
##
##    input is as for the function SolveFrame.
## 
##    Output is a struct array with the fields: Displacements, Reactions and MemF  
##
##    (output formated as for the function SolveFrame.)
## @end deftypefn

function [results]=SolveFrameCases(joints,members,loadcases)
	if (nargin != 3)
		usage("[Reactions,Displacements,MemF]=SolveFrame(joints,members,loadcases) Use the help command for more information");
	end
	
	free=[]; %contains unconstrainted codenumbers
	supported=[]; %contains constrainted codenumbers
	for node=1:rows(joints)
		c=node2code(node);
		for i=3:5
			if (joints(node,i)==0)
				free=[free,c(i-2)];
			else
				supported=[supported,c(i-2)];
			end
		end
	end
	
	%stiffness matrix
	[ K_ff, K_sf ] = GlobalStiffnessMatrixRegrouped (joints, members,free,supported); %K_ss, K_fs are not used and if not calculated script is faster

	%from now  nodeloads,dist,point must depend on case: implement with ? !!!!!!!!
	for lc=1:length(loadcases)

		%convert loadcases to other variables
		nodeloads=loadcases(lc).nodeloads;
		dist=loadcases(lc).dist;
		point=loadcases(lc).point;
	
		P=D=zeros(rows(joints)*3,1);
		%add nodal loads to P matrix
		for load=1:rows(nodeloads)
			c=node2code(nodeloads(load,1));
			for i=0:2
				P(c(1+i))=P(c(1+i))+nodeloads(load,2+i);
			end
		end

		%nodal forces and equivalent nodal ones
		[P_F,MemFEF]=EquivalentJointLoads(joints,members,dist,point);
		

		%reduced matrices
		P_f=P(free,:);
		P_s=P(supported,:);
		
		P_F_f=P_F(free,:);
		P_F_s=P_F(supported,:);
		

		%solution: find unknown displacements
		%can be quicker for large systems with sparse matrix ! 
		
		[D_f, flag] = pcg(K_ff,P_f-P_F_f,1e-6,1000);
		if (flag==1)
			%max iteration
			printf('max iteration');
			try
				%A X = B => solve with cholesky => X = R\(R'\B)
				r = chol (K_ff);
				D_f=r\(r'\(P_f-P_F_f)); 
			catch
				error("System is unstable because K_ff is singular. Please check the support constraints!");
			end_try_catch
		end
		if (flag==3)
			%K_ff was found not positive defnite
			error("System is unstable because K_ff is singular. Please check the support constraints!");
		end
		
		
		
		D(free,1)=D_f;
		
		%solution: find unknown (reaction) forces
		P_s=K_sf*D_f+P_F_s;
		P(supported,1)=P_s;
		
		
		%find unknown member forces
		MemF=[];
		for member=1:rows(members)
			N=members(member,1);
			F=members(member,2);
			xN=joints(N,1);
			yN=joints(N,2);
			xF=joints(F,1);
			yF=joints(F,2);
			T=TransformationMatrix(xN,yN,xF,yF);
			k=MemberStiffnessMatrix(sqrt((xN-xF)**2+(yN-yF)**2),members(member,3),members(member,4),members(member,5));
			c=[node2code(N),node2code(F)];
			MemF=[MemF;(k*T*D(c'))'];
		end
		MemF=MemF+MemFEF;%+fixed end forces

		%format codenumbers to real output
		Displacements=[];
		Reactions=[];
		for i=0:rows(joints)-1
			Displacements=[Displacements;D(1+3*i:3+3*i)'];
			Reactions=[Reactions;P(1+3*i:3+3*i)'];
		end
		for i=1:rows(Reactions)
			for j=1:columns(Reactions)
				if (joints(i,j+2)==0)
					Reactions(i,j)=NaN;
				end
			end
		end
		results(lc).Displacements=Displacements;
		results(lc).Reactions=Reactions;
		results(lc).MemF=MemF;
	end
end