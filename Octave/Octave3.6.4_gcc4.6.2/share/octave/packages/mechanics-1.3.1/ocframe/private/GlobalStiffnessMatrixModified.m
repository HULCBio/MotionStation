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

function [ Kmod, Kcor ] = GlobalStiffnessMatrixModified(joints,members,supported)
	%% \cite{Felippa2010} : "To apply support conditions without rearranging the equations we clear (set to zero) rows and columns
	%% corresponding to prescribed zero displacements as well as the corresponding force components, and place
	%% ones on the diagonal to maintain non-singularity. The resulting system is called the modified set of master
	%% stiffness equations. "
	
	%% joints: [x, y, constraints; ...] 1= fixed
	%% members [nodeN, nodeF, E, I, A; ...]
	%% supported: vector with the supported (fixed) code numbers
	
	%% Kmod + Kcor = K
	
	%% Kcor is the correction matrix to make K
	
	Kmod=GlobalStiffnessMatrix(joints,members);
	Kcor=sparse(rows(joints)*3,rows(joints)*3);
	
	%% Creat Kcor
	for i=1:columns(supported)
		Kcor(:,i)=Kmod(:,i);
		Kcor(i,:)=Kmod(i,:);
	end
	%% delete rows and columns. This might be not the fastest method.
	for i=1:columns(supported)
		Kmod(:,i)=zeros(rows(joints)*3,1);
		Kmod(i,:)=zeros(1,rows(joints)*3);
		
		%set 1 and -1 in Kmod and Kcor 
		Kmod(i,i)+=1;
		Kcor(i,i)-=1;
	end
end
