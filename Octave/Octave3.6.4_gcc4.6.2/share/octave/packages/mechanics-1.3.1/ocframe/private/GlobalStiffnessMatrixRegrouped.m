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

function [ K_ff, K_sf, K_ss, K_fs  ] = GlobalStiffnessMatrixRegrouped (joints, members,free,supported,memberstiffnessmatrices,membertransformationmatrices)
	%% Returns the components of the global stiffness matrix regrouped as in the following equation:
	%% { P_f }   [ K_ff   K_fs ]   { Delta_f }
	%% {     } = [             ] . {         }
	%% { P_s }   [ K_sf   K_ss ]   { Delta_s }
	
	%% joints: [x, y, constraints; ...] 1= fixed
	%% members [nodeN, nodeF, E, I, A; ...]
	%% free: vector with the free code numbers
	%% supported: vector with the supported (fixed) code numbers
	
	%zeros(row,col)
	
	%number of free en supported joints
	
	%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	%TODO: for large systems this function is still slow
	%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	if (nargin>4)
		K=GlobalStiffnessMatrix(joints,members,memberstiffnessmatrices,membertransformationmatrices);
	else
		K=GlobalStiffnessMatrix(joints,members);
	end
	
	%K_ff
	K_ff=K(free,free);
	
	%K_sf
	K_sf=K(supported,free);
	
	
	%K_ss
	if (nargout>=3)
		K_ss=K(supported,supported);
	end
	
	%K_fs
	if (nargout==4)
		K_fs=K(free,supported);
	end
end
