function [val,ok]=getparam(z,objList,param)
%GETPARAM is a safe version of get_param
%   VALUES=GETPARAM(ZSLMETHODS,OBJLIST,PARAM)
%   OBJLIST is a cell array or vector of handles
%   PARAM is a single parameter name
% 
%   Values will always be returned in a cell array,
%   regardless of the size of OBJLIST

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:22:33 $

if isnumeric(objList)
   numericFlag=logical(1);
   objList=objList(:);
elseif iscell(objList)
   numericFlag=logical(0);
   objList=objList(:);
else
   numericFlag=logical(0);
   objList={objList};
end

try
   val=get_param(objList,param);
   ok=logical(1);
   if numericFlag & length(objList)==1
      val={val};
   end
catch
   ok=logical(0);
   for i=length(objList):-1:1
      try
         if numericFlag
            val{i,1}=get_param(objList(i),param);
         else
            val{i,1}=get_param(objList{i},param);
         end
      catch
         val{i,1}='N/A';
      end
   end 
end