## -*- texinfo -*-
## @deftypefn {Function File} {} ocframe_ex2() 
## Example of a beam.
##
## @end deftypefn
function [P,D,MemF]=ocframe_ex2()
	joints=[0,0,1,1,0;
	4,0,0,1,0;
	8,0,0,1,0];
	%Each 4 meter a node => 0,0 and 4,0 and 8,0 are the coordinates.
	%The first node is a hinge and thus supported in the x and y direction => 1,1,0 for the constraints
	%The following nodes are just rollers and thus supported in the y direction => 0,1,0 for the constraints 

	EIA=[200e6,200e6*(10^-3)^4,6000*(10^-3)^2];
	%EIA as a single vector to be used afterwards

	members=[1,2,EIA;2,3,EIA];
	%2 members, connection node 1 to node 2 and node 2 to node 3

	nodeloads=[];
	%there aren't nodal nodes in this example

	dist=[1,0,-4e3,0,-4e3,0,0,1;
	2,0,-4e3,0,-4e3,0,0,1];
	%both members have a distributed load which takes the full length of the member. Notice the - sign caused
	%by the axes conventions
	%as we are working with newtons and meters the load is -4e3 N and not -4 kN
	

	[P,D,MemF]=SolveFrame(joints,members,nodeloads,dist,[])
	%solve the frame with 
	% P: reactions
	% D: displacements
	% MemF: the member end forces
	
end