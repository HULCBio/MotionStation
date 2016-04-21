## -*- texinfo -*-
## @deftypefn {Function File} {} ocframe_ex3() 
## Example of a planar frame.
##
## @end deftypefn
function [P,D,MemF]=ocframe_ex3()
	UNP120=[210e9,363.990e-8,17.000e-4];
	RHS=[210e9,28.900e-8,8.730e-4];
	joints=[0,0,1,1,0;
	1.25,0,0,0,0;
	1.575,0,0,0,0;
	2.5,0,0,0,0;
	3.425,0,0,0,0;
	3.75,0,0,0,0;
	5.,0,0,1,0;
	0,1.5,0,0,0;
	1.25,1.5,0,0,0;
	2.5,1.5,0,0,0;
	3.75,1.5,0,0,0;
	5,1.5,0,0,0];
	members=[1,2,UNP120;
	2,3,UNP120;
	3,4,UNP120;
	4,5,UNP120;
	5,6,UNP120;
	6,7,UNP120;
	8,9,UNP120;
	9,10,UNP120;
	10,11,UNP120;
	11,12,UNP120;
	1,8,RHS;
	2,9,RHS;
	4,10,RHS;
	6,11,RHS;
	7,12,RHS];

	nodeloads=[3,0,-30e3,0;
	5,0,-30e3,0;
	12,30e3,0,0];
	
	if (nargout>0)
		[P,D,MemF]=SolveFrame(joints,members,nodeloads,[],[]);
	else
		[P,D,MemF]=SolveFrame(joints,members,nodeloads,[],[])
		PlotFrame(joints,members,D,1);
	end
end
