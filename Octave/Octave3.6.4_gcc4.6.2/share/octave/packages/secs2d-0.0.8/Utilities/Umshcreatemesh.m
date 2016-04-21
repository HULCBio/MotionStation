function omesh=Umshcreatemesh(geometry,scalefactor,refine);

##
##
## omesh=Umshcreatemesh(geometry,scalefactor);
##
##

if nargin==2
  refine =1;
end

system(["gmsh -format msh1 -2 -scale " num2str(scalefactor) " -clscale ",...
	num2str(refine) " " geometry ".geo"]);

omesh= Umsh2pdetool(geometry);
omesh = Umeshproperties(omesh);
