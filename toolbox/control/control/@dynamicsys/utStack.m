function L = utStack(L1,L2)
% Metadata management for stacking of dynamic systems.

%   Author(s):  P. Gahinet, 5-27-96
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/10 23:13:06 $
L = L1;

% Notes and UserData
L.Notes = {};
L.UserData = [];
L.Name = '';

% I/O channel names should match 
[L.InputName,InputNameClash] = mrgname(L1.InputName,L2.InputName);
if InputNameClash,
   warning('control:ioNameClash','Name clash. All input names deleted.')
   L.InputName(:,1) = {''}; 
end

[L.OutputName,OutputNameClash] = mrgname(L1.OutputName,L2.OutputName);
if OutputNameClash,
   warning('control:ioNameClash','Name clash. All output names deleted.')
   L.OutputName(:,1) = {''}; 
end

% I/O groups should match
[L.InputGroup,InputGroupClash] = mrggroup(L1.InputGroup,L2.InputGroup);
if InputGroupClash,
   warning('control:GroupClash','Group clash. All input groups deleted.')
   L.InputGroup = struct;
end

[L.OutputGroup,OutputGroupClash] = mrggroup(L1.OutputGroup,L2.OutputGroup);
if OutputGroupClash,
   warning('control:GroupClash','Group clash. All output groups deleted.')
   L.OutputGroup = struct;
end