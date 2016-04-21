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

function [F1,F2,F3,F4,F5,F6]=test_FixedEndForcesDist(l,FxN,FyN,FxF,FyF,a,b)
	% distributed load in local coords.
	% a: distance from Near
	% b: distance from Far
	% FxN, FyN forces on start of load in local coordinates
	% FxF, FyF forces on end of load in local coordinates
	
	x=linspace(a,l-b,100); #generate 100 intervals for riemann integration
	dx=x(2)-x(1);
	S=[];
	for i=1:columns(x)
		Fy = (FyF-FyN)/(l-b-a)*(x(i)-a)+FyN;
		Fx = (FxF-FxN)/(l-b-a)*(x(i)-a)+FxN;
		[ F1,F2,F3,F4,F5,F6 ] = test_FixedEndForcesPnt(l,x(i),Fx,Fy);
		S=[S;[ F1,F2,F3,F4,F5,F6 ]];
	end
	for i=1:columns(S)
		S(1,i)/=2;
		S(rows(S),i)/=2;
	end
	F1 = sum(S(:,1))*dx;
	F2 = sum(S(:,2))*dx;
	F3 = sum(S(:,3))*dx;
	F4 = sum(S(:,4))*dx;
	F5 = sum(S(:,5))*dx;
	F6 = sum(S(:,6))*dx;
end
