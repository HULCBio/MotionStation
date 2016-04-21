function strout=outlinestring(c)
%OUTLINESTRING displays a representation of the component in the outline

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:22:14 $

if strcmp(c.att.ObjectType,'Automatic')
   oType='Simulink';
   postString='';
else
   oType=c.att.ObjectType;
   postString=' (Simulink)';
end

strout=sprintf('%s Name%s',oType, postString);