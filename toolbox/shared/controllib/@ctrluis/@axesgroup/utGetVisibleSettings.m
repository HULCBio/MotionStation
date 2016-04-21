function [Vis,arglist] = utGetVisibleSettings(this,Vis,arglist)
% Finds 'Visible',Value pairs in P/V list and removes them

%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:17:25 $
idel = [];
for ct=1:2:length(arglist)
   if strncmpi(arglist{ct},'Visible',length(arglist{ct}))
      idel = [idel,ct];
   end
end
if length(idel)
   Vis = arglist{idel(end)+1};
   arglist(:,[idel idel+1]) = [];
end
