## -*- texinfo -*-
## @deftypefn {Function File} {} ocframe_ex1() 
## Example of a planar frame.
##
## @end deftypefn
function [P,D,MemF]=ocframe_ex1()
	joints=[0,0,1,1,1;
	4,4,0,0,0;
	8,4,1,1,0];

	EIA=[210e9,23130*(10^-2)^4,84.5*(10^-2)^2];%IPE400

	members=[1,2,EIA;2,3,EIA];

	nodeloads=[];

	dist=[1,0,-2e3,0,-2e3,0,0,0;2,0,-4e3,0,-4e3,0,0,1];
	point=[];%1,0,-3e4,3,1

	[P,D,MemF]=SolveFrame(joints,members,nodeloads,dist,point);
	%PlotFrame(joints,members,D,10);
	%plot moment diagram
	PlotDiagrams(joints,members,dist,point,MemF,"S");
end
