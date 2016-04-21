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
## @deftypefn {Function File} {[@var{x}, @var{M}, @var{S}, @var{N}] =} MSNForces(@var{joints}, @var{members}, @var{dist}, @var{point}, @var{MemF}, @var{membernum}, @var{divisions}) 
## 
## This function returns the internal forces of a member for each position x. The member
## is divided in 20 subelements if the argument is not given. The used sign convention is displayed in the help file.
##
## Input parameters are similar as with SolveFrame and PlotFrame with extra arguments:
##    membernum = Number of the member to calculate
##    divisions = Number of divisions for the member
##
## @end deftypefn

function [x,M,S,N]=MSNForces(joints,members,dist,point,MemF,membernum,divisions)
	if (nargin < 6)
		usage("[x,M,S,N]=MSNForces(joints,members,dist,point,MemF,membernum,divisions) use the help command for more information");
	end
	if (nargin<7)
		divisions=20;
	end
	Near=members(membernum,1);
	Far=members(membernum,2);
	L=sqrt((joints(Near,1)-joints(Far,1))^2+(joints(Near,2)-joints(Far,2))^2);
	x=0:L/divisions:L;
	M=zeros(1,columns(x));
	S=zeros(1,columns(x));
	N=zeros(1,columns(x));
	FxN_end=MemF(membernum,1);
	FyN_end=MemF(membernum,2);
	MzN_end=MemF(membernum,3);
	
	%Moment forces
	for i=1:columns(x)
		%due to end forces
		M(i)+=-MzN_end+FyN_end*x(i);
		%due to dist
		for j=1:rows(dist)
			if (dist(j,1)==membernum)
				FxN=dist(j,2);
				FyN=dist(j,3);
				FxF=dist(j,4);
				FyF=dist(j,5);
				a=dist(j,6);
				b=dist(j,7);
				local=dist(j,8);
				if (local==0)
					%convert FxN,... to local axes
					temp=[FxN,FyN,0,FxF,FyF,0];
					temp=(TransformationMatrix(joints(Near,1),joints(Near,2),joints(Far,1),joints(Far,2))')^-1*temp';
					FxN=temp(1);
					FyN=temp(2);
					FxF=temp(4);
					FyF=temp(5);
				end
				if (x(i)>L-b)
					M(i)+= (FyN+FyF)/2*(L-a-b)* (x(i)-((FyN+2*FyF)*L+(2*a-b)*FyN+(a-2*b)*FyF)/(3*FyN+3*FyF));
				end
				if (x(i)>a && x(i)<=L-b)
					%% bug :S zie bug.m
					%M(i)+=(((3*FyN*x(i)+3*a*FyN)*L+(2*FyF-2*FyN)*x(i)^2+((-3*b-2*a)*FyN-a*FyF)*x(i)+(-3*a*b-2*a^2)*FyN-a^2*FyF)*((2*FyN*x(i)*L+(FyF-FyN)*x(i)^2+(-2*b*FyN-2*a*FyF)*x(i))/(2*L-2*b-2*a)-(2*a*FyN*L+(-2*a*b-a^2)*FyN-a^2*FyF)/(2*L-2*b-2*a)))/(6*FyN*L+(3*FyF-3*FyN)*x(i)+(-6*b-3*a)*FyN-3*a*FyF);
					M(i)+=((3*FyN*x(i)^2-6*a*FyN*x(i)+3*a^2*FyN)*L+(FyF-FyN)*x(i)^3+(-3*b*FyN-3*a*FyF)*x(i)^2+((6*a*b+3*a^2)*FyN+3*a^2*FyF)*x(i)+(-3*a^2*b-2*a^3)*FyN-a^3*FyF)/(6*L-6*b-6*a);
				end
			end
		end
		%due to point load on member
		for j=1:rows(point)
			if (point(j,1)==membernum)
				Fx=point(j,2);
				Fy=point(j,3);
				a=point(j,4);
				local=point(j,5);
				if (local==0)
					%convert to global axes
					temp=[Fx,Fy,0,0,0,0];
					temp=(TransformationMatrix(joints(Near,1),joints(Near,2),joints(Far,1),joints(Far,2))')^-1*temp';
					Fx=temp(1);
					Fy=temp(2);
				end
				if (x(i)>a)
					M(i)+=(x(i)-a)*Fy;
				end
			end
		end
		
	end
	M=M.*-1; %sign convention changed during development

	%Shear forces
	for i=1:columns(x)
		%due to end forces
		S(i)+=FyN_end;
		%due to dist
		for j=1:rows(dist)
			if (dist(j,1)==membernum)
				FxN=dist(j,2);
				FyN=dist(j,3);
				FxF=dist(j,4);
				FyF=dist(j,5);
				a=dist(j,6);
				b=dist(j,7);
				local=dist(j,8);
				if (local==0)
					%convert FxN,... to local axes
					temp=[FxN,FyN,0,FxF,FyF,0];
					temp=(TransformationMatrix(joints(Near,1),joints(Near,2),joints(Far,1),joints(Far,2))')^-1*temp';
					FxN=temp(1);
					FyN=temp(2);
					FxF=temp(4);
					FyF=temp(5);
				end
				if (x(i)>L-b)
					S(i)+=((FyN+FyF)*L^2+((-2*b-2*a)*FyF-2*b*FyN)*L+b^2*FyN+(b^2+2*a*b)*FyF)/(2*L-2*b-2*a)-(2*a*FyN*L+(-2*a*b-a^2)*FyN-a^2*FyF)/(2*L-2*b-2*a);
				end
				if (x(i)>a && x(i)<=L-b)
					S(i)+=(2*FyN*x(i)*L+(FyF-FyN)*x(i)^2+(-2*b*FyN-2*a*FyF)*x(i))/(2*L-2*b-2*a)-(2*a*FyN*L+(-2*a*b-a^2)*FyN-a^2*FyF)/(2*L-2*b-2*a);
				end
			end
		end
		%due to point load on member
		for j=1:rows(point)
			if (point(j,1)==membernum)
				Fx=point(j,2);
				Fy=point(j,3);
				a=point(j,4);
				local=point(j,5);
				if (local==0)
					%convert to global axes
					temp=[Fx,Fy,0,0,0,0];
					temp=(TransformationMatrix(joints(Near,1),joints(Near,2),joints(Far,1),joints(Far,2))')^-1*temp';
					Fx=temp(1);
					Fy=temp(2);
				end
				if (x(i)>a)
					S(i)+=Fy;
				end
			end
		end
	end
	%Normal forces
	for i=1:columns(x)
		%due to end forces
		N(i)+=-FxN_end;
		%due to dist
		for j=1:rows(dist)
			if (dist(j,1)==membernum)
				FxN=dist(j,2);
				FyN=dist(j,3);
				FxF=dist(j,4);
				FyF=dist(j,5);
				a=dist(j,6);
				b=dist(j,7);
				local=dist(j,8);
				if (local==0)
					%convert FxN,... to local axes
					temp=[FxN,FyN,0,FxF,FyF,0];
					temp=(TransformationMatrix(joints(Near,1),joints(Near,2),joints(Far,1),joints(Far,2))')^-1*temp';
					FxN=temp(1);
					FyN=temp(2);
					FxF=temp(4);
					FyF=temp(5);
				end
				if (x(i)>L-b)
					N(i)-=((FxN+FxF)*L^2+((-2*b-2*a)*FxF-2*b*FxN)*L+b^2*FxN+(b^2+2*a*b)*FxF)/(2*L-2*b-2*a)-(2*a*FxN*L+(-2*a*b-a^2)*FxN-a^2*FxF)/(2*L-2*b-2*a);
				end
				if (x(i)>a && x(i)<=L-b)
					N(i)-=(2*FxN*x(i)*L+(FxF-FxN)*x(i)^2+(-2*b*FxN-2*a*FxF)*x(i))/(2*L-2*b-2*a)-(2*a*FxN*L+(-2*a*b-a^2)*FxN-a^2*FxF)/(2*L-2*b-2*a);
				end
			end
		end
		%due to point load on member
		for j=1:rows(point)
			if (point(j,1)==membernum)
				Fx=point(j,2);
				Fy=point(j,3);
				a=point(j,4);
				local=point(j,5);
				if (local==0)
					%convert to global axes
					temp=[Fx,Fy,0,0,0,0];
					temp=(TransformationMatrix(joints(Near,1),joints(Near,2),joints(Far,1),joints(Far,2))')^-1*temp';
					Fx=temp(1);
					Fy=temp(2);
				end
				if (x(i)>a)
					N(i)-=Fx;
				end
			end
		end
	end
end
