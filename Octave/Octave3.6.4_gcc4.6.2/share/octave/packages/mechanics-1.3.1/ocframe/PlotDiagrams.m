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
## @deftypefn {Function File} {} PlotDiagrams(@var{joints}, @var{members}, @var{dist}, @var{point}, @var{MemF}, @var{diagram}, @var{divisions}, @var{scale}) 
##
## This function plots the internal forces for all members. The force to be plotted can be selected with @var{diagram} 
## which will be "M", "S" or "N" for the moment, shear or normal forces.
##
## Input parameters are similar as with SolveFrame and PlotFrame.
## @end deftypefn

function PlotDiagrams(joints,members,dist,point,MemF,diagram,divisions,scale)
	%during development some errors occured on windows: http://wiki.octave.org/wiki.pl?OctaveForWindows see oct2mat and plot package
	
	%% scaling goes wrong when there al members have end moment 0
	if (nargin < 6)
		usage("PlotDiagrams(joints,members,dist,point,MemF,diagram,scale) use the help command for more information");
	end
	if (nargin<7)
		divisions=20;
	end
	if (diagram=="M")
		if (nargin<8)
			scale=2/max(max(abs(MemF(:,[3,6]))))
		end
		%plot frame first
		newplot();
		clf();
		hold off;
		set (gca(), "dataaspectratio", [1,1,1]);
		hold on;
		
		for i=1:rows(members)
			Near=members(i,1); %near joint
			Far=members(i,2);	%far joint
			%make line from near to far joint
			line([joints(Near,1),joints(Far,1)],[joints(Near,2),joints(Far,2)],"color","blue");
			
		end
		%plot coord numbers
		for i=1:rows(joints)
			text(joints(i,1),joints(i,2),int2str(i)); %'color','blue'
			hold on;
		end
		%plot member numbers
		for i=1:rows(members)
			text((joints(members(i,1),1)+joints(members(i,2),1))/2,(joints(members(i,1),2)+joints(members(i,2),2))/2,int2str(i),'color','blue');
		end
		
		for i=1:rows(members)
			[x,M]=MSNForces(joints,members,dist,point,MemF,i,divisions);
			%finding maximum and minimum
			[M_max,x_max]=max(M);
			[M_min,x_min]=min(M);
			%scale example scale factor: 2/max moment 
			M=M.*scale; % moment curve consistent with deformation
			Near=members(i,1);
			Far=members(i,2);

			%transformation to real member position!
			L=sqrt((joints(Near,1)-joints(Far,1))^2+(joints(Near,2)-joints(Far,2))^2);
			l=(joints(Far,1)-joints(Near,1))/L;
			m=(joints(Far,2)-joints(Near,2))/L;
			T=[l,m;-m,l]';
			for i=1:columns(x)
				temp=T*[x(i);M(i)]; %rotation
				x(i)=temp(1)+joints(Near,1); %displacement x and y
				M(i)=temp(2)+joints(Near,2);
			end
			plot(x,M,'r-');
			%plot max and min
			text(x(x_max),M(x_max),num2str(M_max,'%g'),'color','red');
			text(x(x_min),M(x_min),num2str(M_min,'%g'),'color','red');
		end
	end
	if (diagram=="S")
		if (nargin<8)
			scale=2/max(max(abs(MemF(:,[2,5]))));
		end
		%plot frame first
		newplot();
		clf();
		hold off;
		set (gca(), "dataaspectratio", [1,1,1]);
		hold on;
		
		for i=1:rows(members)
			Near=members(i,1); %near joint
			Far=members(i,2);	%far joint
			%make line from near to far joint
			line([joints(Near,1),joints(Far,1)],[joints(Near,2),joints(Far,2)],"color","blue");
			
		end
		%plot coord numbers
		for i=1:rows(joints)
			text(joints(i,1),joints(i,2),int2str(i)); %'color','blue'
			hold on;
		end
		%plot member numbers
		for i=1:rows(members)
			text((joints(members(i,1),1)+joints(members(i,2),1))/2,(joints(members(i,1),2)+joints(members(i,2),2))/2,int2str(i),'color','blue');
		end
		
		for i=1:rows(members)
			[x,M,S]=MSNForces(joints,members,dist,point,MemF,i,divisions);
			%finding maximum and minimum
			[S_max,x_max]=max(S);
			[S_min,x_min]=min(S);
			%scale example scale factor: 2/max moment 
			S=S.*scale;
			Near=members(i,1);
			Far=members(i,2);

			%transformation to real member position!
			L=sqrt((joints(Near,1)-joints(Far,1))^2+(joints(Near,2)-joints(Far,2))^2);
			l=(joints(Far,1)-joints(Near,1))/L;
			m=(joints(Far,2)-joints(Near,2))/L;
			T=[l,m;-m,l]';
			for i=1:columns(x)
				temp=T*[x(i);S(i)];
				x(i)=temp(1)+joints(Near,1);
				S(i)=temp(2)+joints(Near,2);
			end
			plot(x,S,'r-');
			%plot max and min
			text(x(x_max),S(x_max),num2str(S_max,'%g'),'color','red');
			text(x(x_min),S(x_min),num2str(S_min,'%g'),'color','red');
		end
	end
	if (diagram=="N")
		if (nargin<8)
			scale=2/max(max(abs(MemF(:,[1,4]))));
		end
		%plot frame first
		newplot();
		clf();
		hold off;
		set (gca(), "dataaspectratio", [1,1,1]);
		hold on;
		
		for i=1:rows(members)
			Near=members(i,1); %near joint
			Far=members(i,2);	%far joint
			%make line from near to far joint
			line([joints(Near,1),joints(Far,1)],[joints(Near,2),joints(Far,2)],"color","blue");
			
		end
		%plot coord numbers
		for i=1:rows(joints)
			text(joints(i,1),joints(i,2),int2str(i)); %'color','blue'
			hold on;
		end
		%plot member numbers
		for i=1:rows(members)
			text((joints(members(i,1),1)+joints(members(i,2),1))/2,(joints(members(i,1),2)+joints(members(i,2),2))/2,int2str(i),'color','blue');
		end
		
		for i=1:rows(members)
			[x,M,S,N]=MSNForces(joints,members,dist,point,MemF,i,divisions);
			%finding maximum and minimum
			[N_max,x_max]=max(N);
			[N_min,x_min]=min(N);
			%scale example scale factor: 2/max moment 
			N=N.*scale;
			Near=members(i,1);
			Far=members(i,2);

			%transformation to real member position!
			L=sqrt((joints(Near,1)-joints(Far,1))^2+(joints(Near,2)-joints(Far,2))^2);
			l=(joints(Far,1)-joints(Near,1))/L;
			m=(joints(Far,2)-joints(Near,2))/L;
			T=[l,m;-m,l]';
			for i=1:columns(x)
				temp=T*[x(i);N(i)];
				x(i)=temp(1)+joints(Near,1);
				N(i)=temp(2)+joints(Near,2);
			end
			plot(x,N,'r-');
			%plot max and min
			text(x(x_max),N(x_max),num2str(N_max,'%g'),'color','red');
			text(x(x_min),N(x_min),num2str(N_min,'%g'),'color','red');
		end
	end
end
