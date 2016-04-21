function strout=outlinestring(c)
%OUTLINESTRING returns a short description of the component

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:13:16 $


info=getinfo(c);
strout=[xlate(info.Name),' - '];

if numsubcomps(c)>0
   strout=sprintf('%stext from subcomponents',strout);
else
   strout=[strout,xlate(c.att.headertext)];
end
