function str = rcinfo(this,RowName,ColName)
%RCINFO  Constructs data tip text locating component in axes grid.

%   Author(s): Pascal Gahinet
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:26:37 $
if isnumeric(RowName)
   % RowName = row index in axes grid. Display as Ch(*)
   RowName = sprintf('Ch(%d)',RowName);
end
str = sprintf('Channel: %s',RowName);
