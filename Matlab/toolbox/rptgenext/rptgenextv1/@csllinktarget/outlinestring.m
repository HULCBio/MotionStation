function strout=outlinestring(c)
%OUTLINESTRING returns a short description of the component

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:21:25 $


if strcmp(c.att.ObjectType,'Automatic')
   oType='Simulink';
   postString='';
else
   oType=c.att.ObjectType;
   postString=' (Simulink)';
end

strout=sprintf('%s Linking Anchor%s',oType, postString);