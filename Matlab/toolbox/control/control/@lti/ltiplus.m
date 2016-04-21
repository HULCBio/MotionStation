function [L,sys1,sys2] = ltiplus(L1,L2,sys1,sys2)
%LTIPLUS  LTI property management for LTI model addition.
% 
%   [SYS.LTI,SYS1,SYS2] = LTIPLUS(SYS1.LTI,SYS2.LTI,SYS1,SYS2)
%   sets the LTI properties of the model SYS = SYS1 + SYS2.
%   In discrete time, conflicting delays are removed using 
%   DELAY2Z (SYS1 and SYS2 are then updated accordingly).
%
%   See also TF/PLUS.

%   Author(s):  P. Gahinet, 5-23-96
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.14.4.1 $  $Date: 2003/01/07 19:32:12 $

%RE: Not called lti/plus because of extra LTI inputs SYS1 and SYS2
%    (would prevent dispatch to @lti)
EmptyStr = {''};
L = L1;

% Notes and UserData
L.Notes = {};
L.UserData = [];

% InputName
[L.InputName,clash] = mrgname(L1.InputName,L2.InputName);
if clash,
   warning('Name clash. All input name(s) deleted.');
   L.InputName = EmptyStr(ones(length(L1.InputName),1),1);
end

% InputGroup: check compatibility 
[L.InputGroup,clash] = mrggroup(L1.InputGroup,L2.InputGroup);
if clash, 
   warning('Group clash. All input groups deleted.')
   L.InputGroup = struct;
end

% OutputName
[L.OutputName,clash] = mrgname(L1.OutputName,L2.OutputName);
if clash,
   warning('Name clash. All output name(s) deleted.');
   L.OutputName = EmptyStr(ones(length(L1.OutputName),1),1);
end

% InputGroup: check compatibility 
[L.OutputGroup,clash] = mrggroup(L1.OutputGroup,L2.OutputGroup);
if clash, 
   warning('Group clash. All output groups deleted.')
   L.OutputGroup = struct;
end

% Sample time managament
% RE: Assumes that the sample time of static gains 
%     has already been adjusted
%
if (L1.Ts==-1 & L2.Ts>0) | (L2.Ts==-1 & L1.Ts>0),
   % Discrete/discrete with one unspecified sample time
   L.Ts = max(L1.Ts,L2.Ts);
elseif L1.Ts~=L2.Ts,
   error('In SYS1+SYS2, both models must have the same sample time.')
end


% Merge input delays
[L.InputDelay,L1,L2] = iodmerge('i',L1.InputDelay,L2.InputDelay,L1,L2);

% Merge output delays
[L.OutputDelay,L1,L2] = iodmerge('o',L1.OutputDelay,L2.OutputDelay,L1,L2);


% Check I/O delay compatibility
%------------------------------
Dm1 = L1.ioDelay;
Dm2 = L2.ioDelay;
Dm12 = ndops('add',Dm1,-Dm2);

% Compute resulting delay
if all(abs(Dm12(:))<1e3*eps),
   % Matching I/O delays
   Dm = Dm1;
elseif L.Ts | isa(sys1,'frd')
   % I/O delay mismatch in discrete time: map offending delays to poles at z=0
   % RE: Blows away LTI properties of sys1 and sys2 (no longer used in PLUS)
   Dm = ndops('min',Dm1,Dm2);
   sys1.InputDelay = zeros(size(Dm,2),1);
   sys1.OutputDelay = zeros(size(Dm,1),1);
   sys1.ioDelay = ndops('add',Dm1,-Dm);
   sys1 = delay2z(sys1);
   sys2.InputDelay = zeros(size(Dm,2),1);
   sys2.OutputDelay = zeros(size(Dm,1),1);
   sys2.ioDelay = ndops('add',Dm2,-Dm);
   sys2 = delay2z(sys2);
else
   error('In SYS1+SYS2, SYS1 and SYS2 must have identical delay times.')
end

% Set resulting I/O delay matrix
L.ioDelay = tdcheck(Dm);
