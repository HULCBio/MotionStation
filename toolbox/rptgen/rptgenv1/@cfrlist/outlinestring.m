function strout=outlinestring(c)
%OUTLINESTRING returns a short description of the component

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:13:36 $

strout=[];

if strcmp(c.att.ListStyle,'ItemizedList')
   strout=[strout,xlate('Bulleted list')];
else
   strout=[strout,xlate('Numbered list')];
end

if numsubcomps(c)==0
   strout=[strout,' - ' xlate(c.att.SourceVariableName)];   
else
   strout=[strout,xlate(' - from subcomponents')];   
end
