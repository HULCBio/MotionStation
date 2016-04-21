function option=makeoptionstruct(c,simparam,model)
%MAKEOPTIONSSTRUCT creates a structure to pass to the sim command

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:21:46 $

if nargin<3
   model=c.zslmethods.Model;
   if nargin<2
      simparam=c.att.simparam;
   end
end

mdlName=openmodel(c,model);


if isempty(mdlName)
   option=simget;
else
   try
      option=simget(mdlName);
   catch
      option=simget;
   end
end

option=simset(option,simparam{:});