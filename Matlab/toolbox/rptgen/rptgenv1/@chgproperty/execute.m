function out=execute(c)
%EXECUTE generate report output

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:14:32 $

objType=c.att.ObjectType;
propName=getfield(c.att,[objType 'Property']);

currObj=subsref(c.zhgmethods,substruct('.',objType));
if ~isempty(currObj)
   
   propTag=feval(['prop' lower(objType)],...
      c,...
      'GetPropValue',...
      currObj,...
      propName);
   
   %must use SGMLTAGs here because propTag may
   %not necessarily be text.
   switch c.att.Render
   case 1 %value
      out=propTag;
   case 2 %property:value
      out=[sgmltag([propName ':']),propTag];
   case 3
      out=[set(sgmltag,...
            'data',propName,...
            'tag','emphasis'),...
            propTag];
   end
else
   out='';
   status(c,sprintf('Warning - no %s found.',c.att.ObjectType),2);
end
