function L = horzcat(L1,L2)
%HORZCAT  Metadata management in horizontal concatenation.

%   Author(s):  P. Gahinet, 5-27-96
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/10 23:12:26 $
L = L1;
if nargin==1,
   % Parser call to HORZCAT with single argument in [L , SYSJ.dynamicsys]
   return
end

% Notes and UserData
L.Notes = {};
L.UserData = [];
L.Name = '';

% Append input groups:
lind = length(L.InputName) + (1:length(L2.InputName));
L.InputGroup = groupcat(L1.InputGroup,L2.InputGroup,lind);

% Append input names
L.InputName = [L1.InputName ; L2.InputName];

% OutputName: check compatibility and merge
[L.OutputName,OutputNameClash] = mrgname(L1.OutputName,L2.OutputName);
if OutputNameClash,
   warning('control:ioNameClash','Name clash. All output names deleted.')
   EmptyStr = {''};
   L.OutputName = EmptyStr(ones(length(L.OutputName),1),1);
end

% OutputGroup: check compatibility 
[L.OutputGroup,OutputGroupClash] = mrggroup(L1.OutputGroup,L2.OutputGroup);
if OutputGroupClash,
   warning('control:GroupClash','Group clash. All output groups deleted.')
   L.OutputGroup = struct;
end

