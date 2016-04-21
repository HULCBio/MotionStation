function out=execute(c)
%EXECUTE generates report contents

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:21:30 $

objType=c.att.ObjectType;
propName=getfield(c.att,[objType 'Property']);

currObj=subsref(c.zslmethods,substruct('.',objType));

if length(currObj)>0
   if ischar(currObj)
      currObj={currObj};
   end
   
   propTag=feval(['prop' lower(objType)],...
      c,...
      'GetPropValue',...
      currObj,...
      propName);
else
   propTag=sprintf('<No %s>',objType);
end


switch c.att.Render
case 1 %value
   out=propTag;
case 2 %property:value
   out=[sgmltag([propName ':']),propTag];
case 3
   out=[set(sgmltag,'data',propName,'tag','emphasis'),...
         propTag];
end