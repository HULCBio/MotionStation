## -*- texinfo -*-
## @deftypefn {Function File} {} ocframe_exLC() 
## Example of a beam with generation of eurocode ULS
## load cases
##
## @end deftypefn

function ocframe_exLC()

	joints=[0,0,1,1,0;
		4,0,0,1,0;
		8,0,0,1,0;
		12,0,0,1,0;
		16,0,0,1,0];

	EIA=[200e6,200e6*(10^-3)^4,6000*(10^-3)^2];
	members=[1,2,EIA;
	2,3,EIA;
	3,4,EIA;
	4,5,EIA];

	%there is a variable load 4kN/m to be combined with 2kN/m permanent
	%eurocode ULS
	%Permanent actions: if favourable 1 if not 1,35
	%Variable actions: if favourable 0 if not 1,5
	%Category A: domestic phi0 = 0,7	phi1 = 0,5 phi2 = 0,3
	% each case consists of permanent load * 1,35 plus one of the variable cases
	% which makes 16 cases (try for each variable load 0 and 1,5 as the factor)
	loadcases={};
	for i=0:15
		lc=toascii(dec2bin(i,4)).-48;
		%no point loads and nodal loads
		loadcases(i+1).nodeloads=[];
		loadcases(i+1).point=[];
		%dist load depends on case
		dist=[];
		for j=1:4
			%add permanent
			dist=[dist;[j,0,-2e3*1.35,0,-2e3*1.35,0,0,1]];
			if (lc(j)==1)
				dist=[dist;[j,0,-4e3*0.7*1.5,0,-4e3*0.7*1.5,0,0,1]];
			end
			loadcases(i+1).dist=dist;
		end
	end

	[results]=SolveFrameCases(joints,members,loadcases);

	%moment diagram envelope
	moments=[];
	for lc=1:16
		x=[];
		M=[];
		for i=1:4
			[u,Mo]=MSNForces(joints,members,loadcases(lc).dist,loadcases(lc).point,results(lc).MemF,i,40);
			x=[x,u.+(4*(i-1))];
			M=[M,Mo];
		end
		moments=[moments;M];
	end

	plot(x,max(moments),x,min(moments))

end



	