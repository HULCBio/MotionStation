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
## @deftypefn {Function File} {} PlotFrame(@var{joints}, @var{members}, @var{D}, @var{factor}) 
##
##
## Plots a 2D frame (with displacements if needed) using
## the following input parameters:
##
##    joints = [x , y, constraints ; ...]
##
##    constraints=[x , y, rotation] free=0, supported=1
##
##    members = [nodeN, nodeF, E, I, A; ...]
##
##	  Optional arguments:
##
##    D = [x,y,rotation;...] Displacements as returned by SolveFrame
##
##    factor= Scaling factor for the discplacements (default: 10)
##
## @end deftypefn

function PlotFrame(joints,members,D,factor)
	if (nargin < 2)
		usage("PlotFrame(joints,members,D,factor) D and factor ar optional. Use the help command for more information");
	end
	%during development some errors occured on windows: http://wiki.octave.org/wiki.pl?OctaveForWindows see oct2mat and plot package
	newplot();
	clf();
	set (gca(), "dataaspectratio", [1,1,1]);
	for i=1:rows(members)
		N=members(i,1); %near joint
		F=members(i,2);	%far joint
		%make line from near to far joint
		line([joints(N,1),joints(F,1)],[joints(N,2),joints(F,2)],"color","blue");
		hold on;
		if (nargin>=3)
			%plot also displacements
			if (nargin==3)
				% default factor
				factor=10;
			end
			cN=node2code(N);
			cF=node2code(F);
			line([joints(N,1)+D(N,1)*factor,joints(F,1)+D(F,1)*factor],[joints(N,2)+D(N,2)*factor,joints(F,2)+D(F,2)*factor],"color","red");
			hold on;
		end
	end
	%one meter extra as a border
	set (gca (), "xlim", [min(joints(:,1))-1,max(joints(:,1))+1]);
	set (gca (), "ylim", [min(joints(:,2))-1,max(joints(:,2))+1]);

	%plot coord numbers
	for i=1:rows(joints)
		text(joints(i,1),joints(i,2),int2str(i)); %'color','blue'
		hold on;
	end
	%plot member numbers
	for i=1:rows(members)
		text((joints(members(i,1),1)+joints(members(i,2),1))/2,(joints(members(i,1),2)+joints(members(i,2),2))/2,int2str(i),'color','blue');
	end
	hold off;
end