function L = horzcat(L1,L2)
%HORZCAT  LTI property management in horizontal concatenation.
% 
%   SYS.LTI = HORZCAT(SYS1.LTI,SYS2.LTI,...) sets the LTI 
%   properties of 
%                 SYS = [SYS1 , SYS2, ...].

%   Author(s):  P. Gahinet, 5-27-96
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.11.4.1 $  $Date: 2003/01/07 19:32:03 $


L = L1;
if nargin==1,
   % Parser call to HORZCAT with single argument in [SLTI ; SYSJ.LTI]
   return
end

% Notes and UserData
L.Notes = {};
L.UserData = [];

% Sample time managament
% RE: Assumes that the sample time of static gains 
%     has already been adjusted
if (L1.Ts==-1 & L2.Ts>0) | (L2.Ts==-1 & L1.Ts>0),
   % Discrete/discrete with one unspecified sample time
   L.Ts = max(L1.Ts,L2.Ts);
elseif L1.Ts~=L2.Ts,
   error('Sampling time mismatch in concatenation.')
end

% Delay times
L.InputDelay = ndops('vcat',L1.InputDelay,L2.InputDelay);
[L.OutputDelay,L1,L2] = iodmerge('o',L1.OutputDelay,L2.OutputDelay,L1,L2);
L.ioDelay = ndops('hcat',L1.ioDelay,L2.ioDelay);
    
% Append input groups:
lind = length(L.InputName) + (1:length(L2.InputName));
L.InputGroup = groupcat(L1.InputGroup,L2.InputGroup,lind);

% Append input names
L.InputName = [L1.InputName ; L2.InputName];

% OutputName: check compatibility and merge
[L.OutputName,OutputNameClash] = mrgname(L1.OutputName,L2.OutputName);
if OutputNameClash,
   warning('Name clash. All output names deleted.')
   EmptyStr = {''};
   L.OutputName = EmptyStr(ones(length(L.OutputName),1),1);
end

% OutputGroup: check compatibility 
[L.OutputGroup,OutputGroupClash] = mrggroup(L1.OutputGroup,L2.OutputGroup);
if OutputGroupClash,
   warning('Group clash. All output groups deleted.')
   L.OutputGroup = struct;
end

