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

function [F1,F2,F3,F4,F5,F6]=FixedEndForcesDist(l,FxN,FyN,FxF,FyF,a,b)
	% distributed load in local coords.
	% a: distance from Near
	% b: distance from Far
	% FxN, FyN forces on start of load in local coordinates
	% FxF, FyF forces on end of load in local coordinates
	
	% formulas found by integrating the formulas for a point load with maxima maxima.sourceforge.net
	F1=-((2*FxN+FxF)*l^2+((-b-4*a)*FxN+(b-2*a)*FxF)*l+(-b^2+a*b+2*a^2)*FxN+(-2*b^2-a*b+a^2)*FxF)/(6*l);
	F2=-1*(((7*FyN+3*FyF)*l^4+((-3*b-13*a)*FyN+(3*b-7*a)*FyF)*l^3+((-3*b^2+4*a*b-3*a^2)*FyN+(3*b^2-4*a*b+3*a^2)*FyF)*l^2+
((-3*b^3+a*b^2+a^2*b+17*a^3)*FyN+(-17*b^3-a*b^2-a^2*b+3*a^3)*FyF)*l+(2*b^4-2*a*b^3+2*a^2*b^2-2*a^3*b-8*a^4)*FyN+(8*b^4+2*a*b^3-2*a^2*b^2+2*a^3*b-2*a^4)*
FyF)/(20*l^3));
	F3=-1*(((3*FyN+2*FyF)*l^4+((3*a-2*b)*FyN+(2*b-3*a)*FyF)*l^3+((-2*b^2+a*b-27*a^2)*FyN+(2*b^2-a*b-3*a^2)*FyF)*l^2+
((-2*b^3-a*b^2+4*a^2*b+33*a^3)*FyN+(-18*b^3+a*b^2-4*a^2*b+7*a^3)*FyF)*l+(3*b^4-3*a*b^3+3*a^2*b^2-3*a^3*b-12*a^4)*FyN+
(12*b^4+3*a*b^3-3*a^2*b^2+3*a^3*b-3*a^4)*FyF)/(60*l^2));
	F4=-((FxN+2*FxF)*l^2+((a-2*b)*FxN+(-4*b-a)*FxF)*l+(b^2-a*b-2*a^2)*FxN+(2*b^2+a*b-a^2)*FxF)/(6*l);
	F5=-1*(((3*FyN+7*FyF)*l^4+((3*a-7*b)*FyN+(-13*b-3*a)*FyF)*l^3+((3*b^2-4*a*b+3*a^2)*FyN+(-3*b^2+4*a*b-3*a^2)*FyF)*l^2+
((3*b^3-a*b^2-a^2*b-17*a^3)*FyN+(17*b^3+a*b^2+a^2*b-3*a^3)*FyF)*l+(-2*b^4+2*a*b^3-2*a^2*b^2+2*a^3*b+8*a^4)*FyN+(-8*b^4-2*a*b^3+2*a^2*b^2-2*a^3*b+2*a^4)*
FyF)/(20*l^3));
	F6=-1*(-((2*FyN+3*FyF)*l^4+((2*a-3*b)*FyN+(3*b-2*a)*FyF)*l^3+((-3*b^2-a*b+2*a^2)*FyN+(-27*b^2+a*b-2*a^2)*FyF)*l^2+
((7*b^3-4*a*b^2+a^2*b-18*a^3)*FyN+(33*b^3+4*a*b^2-a^2*b-2*a^3)*FyF)*l+(-3*b^4+3*a*b^3-3*a^2*b^2+3*a^3*b+12*a^4)*FyN+
(-12*b^4-3*a*b^3+3*a^2*b^2-3*a^3*b+3*a^4)*FyF)/(60*l^2));
end