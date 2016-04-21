function L = feedback(L1,L2,sflags)
%FEEDBACK  Manages LTI properties in FEEDBACK operation
%
%   SYS.LTI = FEEDBACK(SYS1.LTI,SYS2.LTI,SFLAGS)  sets 
%   the LTI properties of the system
%             SYS = FEEDBACK(SYS1,SYS2)
%
%   The two-entry vector SFLAGS flags static gains:
%      * SFLAGS(1) = 1 --> SYS1 is a static gain
%      * SFLAGS(2) = 1 --> SYS2 is a static gain

%   Author(s): P. Gahinet, 5-28-96
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.10 $  $Date: 2002/04/10 05:50:58 $


% Adjust sample time of static gains to avoid unwarranted clashes
if nargin>2 & any(sflags),
   [L1,L2] = sgcheck(L1,L2,sflags);
end
L = L1;

% Delete Notes and UserData
L.Notes = {};
L.UserData = [];

% Sample time managament
if (L1.Ts==-1 & L2.Ts>0) | (L2.Ts==-1 & L1.Ts>0),
   % Discrete/discrete with one unspecified sample time
   L.Ts = max(L1.Ts,L2.Ts);
elseif L1.Ts~=L2.Ts,
   error('In FEEDBACK, models must have identical sampling times.')
end

% Set all delays to zero
[ny,nu] = size(L1.ioDelay(:,:,1));
L.ioDelay = zeros(ny,nu);
L.InputDelay = zeros(nu,1);
L.OutputDelay = zeros(ny,1);
