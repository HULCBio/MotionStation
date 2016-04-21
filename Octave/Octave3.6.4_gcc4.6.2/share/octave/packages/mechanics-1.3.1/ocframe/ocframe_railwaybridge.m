## -*- texinfo -*-
## @deftypefn {Function File} {} ocframe_railwaybridge() 
## Example taken from a real railwaybridge.
##
## @end deftypefn
function [P,D,MemF]=ocframe_railwaybridge()
	joints=[0:5.3636:59;zeros(4,12)]';
	joints(1,3:4)=[1,1];
	joints(12,3:4)=[1,1];

	temp=[];
	%parabola with height = 8 m => f(x)=(32*x)/59-(32*x^2)/3481
	for i=2:11
		temp=[temp;joints(i,1),(32*joints(i,1))/59-(32*joints(i,1)^2)/3481,0,0,0];
	end

	joints=[joints;temp];

	%EIA
	beam1=[200e9,135.7*(0.1)^4,3.204*(0.1)^2];
	beam2=[200e9,80.5*(0.1)^4,2.011*(0.1)^2];
	members=[];
	for i=1:11
		members=[members;i,i+1,beam1];
	end
	members=[members;1,13,beam1];
	for i=13:21
		members=[members;i,i+1,beam1];
	end
	members=[members;22,12,beam1];

	for i=2:11
		members=[members;i,i+11,beam2];
	end

	%own weight of beams neglected
	
	%some forces
	nodeloads=[6,0,-50e3,0;7,0,-50e3,0];
	
	tic
	[P,D,MemF]=SolveFrame(joints,members,nodeloads,[],[]);
	toc
	
	%PlotFrame(joints,members,D,100);
end