function varargout=initialize(z,coutlineHandle);
%INITIALIZE initialize static information before generation

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:17:41 $


d.Figure=[];
d.Axes=[];
d.Object=[];

allFigs=findall(allchild(0),'type','figure');

if isempty(allFigs)
   allFigs=-1;
end

d.PreRunOpenFigures=allFigs;

if nargout==1
   varargout{1}=d;
else
   rgstoredata(z,d);
end
