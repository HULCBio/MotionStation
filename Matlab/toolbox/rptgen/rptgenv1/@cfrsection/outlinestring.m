function strout=outlinestring(c)
%OUTLINESTRING returns a short description of the component
%   OLSTR=OUTLINESTRING(C)

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:13:51 $


d=getsectiondepth(c);

if c.att.isTitleFromSubComponent
   tString='<Title from SubComponent1>';
else
   tString=c.att.SectionTitle;
end

if d>0 & d<=size(c.ref.allTypes,1)
   sectName=c.ref.allTypes{d,2};
else
   sectName='Chapter/Subsection';
end

strout= sprintf('%s - %s',xlate(sectName) ,xlate(tString));