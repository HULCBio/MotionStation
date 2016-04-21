function addpz(CompData,Type,Zeros,Poles)
%ADDPZ  Adds new pole/zero group to the compensator.

%   Author(s): P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.7 $ $Date: 2002/04/10 04:54:40 $

% Create new PZ group
NewGroup = sisodata.pzgroup;
set(NewGroup,'Type',Type,'Zero',Zeros(:),'Pole',Poles(:));

% Add to groups
CompData.PZGroup = [CompData.PZGroup ; NewGroup];
