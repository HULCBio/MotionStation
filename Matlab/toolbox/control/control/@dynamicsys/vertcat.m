function L = vertcat(L1,L2)
%VERTCAT  Metadata management in vertical concatenation.

%       Author(s):  P. Gahinet, 5-27-96
%       Copyright 1986-2003 The MathWorks, Inc.
%       $Revision: 1.1.6.2 $  $Date: 2004/04/10 23:13:08 $
L = L1;
if nargin==1,
   % Parser call to HORZCAT with single argument in [L ; SYSJ.dynamicsys]
   return
end

% Notes and UserData
L.Notes = {};
L.UserData = [];
L.Name = '';

% Append output groups:
lind = length(L1.OutputName) + (1:length(L2.OutputName));
L.OutputGroup = groupcat(L1.OutputGroup,L2.OutputGroup,lind);
   
% Append output names
L.OutputName = [L1.OutputName ; L2.OutputName];

% InputName: check compatibility and merge
[L.InputName,InputNameClash] = mrgname(L1.InputName,L2.InputName);
if InputNameClash,
   warning('control:ioNameClash','Name clash. All input name(s) deleted.')
   EmptyStr = {''};
   L.InputName = EmptyStr(ones(length(L.InputName),1),1);
end
   
% InputGroup: check compatibility 
[L.InputGroup,InputGroupClash] = mrggroup(L1.InputGroup,L2.InputGroup);
if InputGroupClash,
   warning('control:GroupClash','Group clash. All input groups deleted.')
   L.InputGroup = struct;
end

