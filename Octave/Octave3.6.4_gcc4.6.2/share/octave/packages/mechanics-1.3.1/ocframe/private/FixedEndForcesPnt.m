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

function [F1,F2,F3,F4,F5,F6]=FixedEndForcesPnt(l,a,Fx,Fy)
	% point load in local coords.
	% a: distance from Near
	% l: length
	% FxN, FyN forces on start of load in local coordinates
	% FxF, FyF forces on end of load in local coordinates
	
	% b: distance from Far
	b=l-a;
	
	F1=-b*Fx/l;
	F2=-Fy*(b/l-a^2*b/l^3+a*b^2/l^3);
	F3=-Fy*a*b^2/l^2;
	F4=-a*Fx/l;
	F5=-Fy*(a/l+a^2*b/l^3-a*b^2/l^3);
	F6=Fy*a^2*b/l^2;
end