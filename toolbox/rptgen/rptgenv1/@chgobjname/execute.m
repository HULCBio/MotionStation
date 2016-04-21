function out=execute(c)
%EXECUTE generate report output
%   OUT=EXECUTE(C)

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:14:25 $

currObj=subsref(c.zhgmethods,substruct('.',c.att.ObjType));

if length(currObj)==1
   out=objname(c.zhgmethods,currObj);
   
   if ~strcmp(c.att.renderAs,'n')
      
      oType=get(currObj,'type');
      if strcmp(oType,'uicontrol')
         oType=get(currObj,'style');
      end
      oType(1)=upper(oType(1));
      
      
      switch c.att.renderAs
      case 't n'
         out=[oType ' ' out];
      case 't-n'
         out=[oType ' - ' out];
      case 't:n'
         out=[oType ': ' out];
      %otherwise %case 'n'
         %   out=out;   
      end
   end
else
   status(c,sprintf('Warning - %s not found.',c.att.ObjType),2);
   out='';
end
