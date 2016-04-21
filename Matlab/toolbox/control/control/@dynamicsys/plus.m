function L = plus(L1,L2)
%PLUS  Meta data management for system addition.

%   Author(s):  P. Gahinet
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/10 23:12:32 $
EmptyStr = {''};
L = L1;

% Notes and UserData
L.Notes = {};
L.UserData = [];
L.Name = '';

% InputName
[L.InputName,clash] = mrgname(L1.InputName,L2.InputName);
if clash,
   warning('control:ioNameClash','Name clash. All input names deleted.');
   L.InputName = EmptyStr(ones(length(L1.InputName),1),1);
end

% InputGroup: check compatibility 
[L.InputGroup,clash] = mrggroup(L1.InputGroup,L2.InputGroup);
if clash, 
   warning('control:GroupClash','Group clash. All input groups deleted.')
   L.InputGroup = struct;
end

% OutputName
[L.OutputName,clash] = mrgname(L1.OutputName,L2.OutputName);
if clash,
   warning('control:ioNameClash','Name clash. All output names deleted.');
   L.OutputName = EmptyStr(ones(length(L1.OutputName),1),1);
end

% InputGroup: check compatibility 
[L.OutputGroup,clash] = mrggroup(L1.OutputGroup,L2.OutputGroup);
if clash, 
   warning('control:GroupClash','Group clash. All output groups deleted.')
   L.OutputGroup = struct;
end