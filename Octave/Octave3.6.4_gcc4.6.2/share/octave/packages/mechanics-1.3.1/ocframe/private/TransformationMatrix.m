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

function T=TransformationMatrix(x1,y1,x2,y2)
	#Displacement transformation matrix = T
	#Force transformation = T transposed
	L=sqrt((x1-x2)^2+(y1-y2)^2);
	l=(x2-x1)/L;
	m=(y2-y1)/L;
	T=[l,m,0,0,0,0;
	-m,l,0,0,0,0;
	0,0,1,0,0,0;
	0,0,0,l,m,0;
	0,0,0,-m,l,0;
	0,0,0,0,0,1];
end