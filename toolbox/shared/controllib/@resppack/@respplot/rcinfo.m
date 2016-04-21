function str = rcinfo(this,RowName,ColName)
%RCINFO  Constructs data tip text locating component in axes grid.

%   Author(s): Pascal Gahinet
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:22:39 $

if isnumeric(RowName)
   % RowName = row index in axes grid. Display as Out(*)
   RowName = sprintf('Out(%d)',RowName);
end
if isnumeric(ColName)
   % ColName = column index in axes grid. Display as In(*)
   ColName = sprintf('In(%d)',ColName);
end

if isempty(ColName)
   str = sprintf('Output: %s',RowName);
elseif isempty(RowName)
   str = sprintf('Input: %s',ColName);
else
   str = sprintf('I/O: %s to %s',ColName,RowName);
end