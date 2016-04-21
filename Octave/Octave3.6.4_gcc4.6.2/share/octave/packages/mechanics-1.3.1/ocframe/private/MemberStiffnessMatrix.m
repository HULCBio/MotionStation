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

function k=MemberStiffnessMatrix(L,E,I,A)
	k=[A*E/L,0,0,-A*E/L,0,0;
	0,12*E*I/L^3,6*E*I/L^2,0,-12*E*I/L^3,6*E*I/L^2;
	0,6*E*I/L^2,4*E*I/L,0,-6*E*I/L^2,2*E*I/L;
	-A*E/L,0,0,A*E/L,0,0;
	0,-12*E*I/L^3,-6*E*I/L^2,0,12*E*I/L^3,-6*E*I/L^2;
	0,6*E*I/L^2,2*E*I/L,0,-6*E*I/L^2,4*E*I/L];
end