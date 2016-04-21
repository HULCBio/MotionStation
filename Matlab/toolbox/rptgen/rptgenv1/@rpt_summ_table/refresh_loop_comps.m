function c=refresh_loop_comps(r,c)
%REFRESH_LOOP_COMPS runs constructor for loop component
%   c=refresh_loop_comps(r,c) runs the constructor
%   for all loop component (c.att.FooComponent) structures
%   then breaks the resulting component back into a
%   structure.

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:16:46 $

att=c.att;
for i=length(r.Table):-1:1
   fName=[r.Table(i).id 'Component'];
   cStruct=getfield(att,fName);
   typeInfo = r.Table(i);
   if iscell(typeInfo.componentName)
      loopCompName = typeInfo.componentName{1};
      extraArgs = typeInfo.componentName(2:end);
	else
      loopCompName = typeInfo.componentName;
      extraArgs = {};
	end
   
   cStruct=struct(unpoint(feval(loopCompName,cStruct)));
   
   for i=1:2:length(extraArgs)
		cStruct.att = setfield(cStruct.att,extraArgs{i},extraArgs{i+1});      
   end
   
   att=setfield(att,fName,cStruct);
end
c.att=att;

