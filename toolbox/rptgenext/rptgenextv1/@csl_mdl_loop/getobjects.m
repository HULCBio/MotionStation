function oList=getobjects(c,isVerify);
%GETOBJECTS returns a list of objects to be included in report

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:20:08 $

mdlStruct=getfield(c.att,[c.att.LoopType 'Models']);
mdlStruct=loopmodel(c,mdlStruct);

if isVerify
   oList={};
   errMsg={};
   for i=1:length(mdlStruct)
      %verify that the models exist
      obj=mdlStruct(i).MdlName;
      try
         open_system(obj);
         ok=strcmp(get_param(obj,'Type'),'block_diagram');
      catch
         ok=0;
      end
      
      if ok
         oList{end+1,1}=obj;
      else
         errMsg{end+1,1}=...
            sprintf('Warning - Could not open model "%s"',obj);
      end
   end
   
   if ~isempty(errMsg)
      status(c,errMsg,2);
   end
else
   oList={mdlStruct.MdlName};
   oList=oList(:);
end