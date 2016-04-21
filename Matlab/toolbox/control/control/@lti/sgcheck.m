function [L1,L2] = sgcheck(L1,L2,sflags)
%SGCHECK  Adjusts the sample time of static gains to avoid
%         undesirable clashes in the various LTI operations.
%
%   [L1,L2] = SGCHECK(L1,L2,SFLAGS)  adjusts the sample
%   times L1.Ts and L2.Ts of the LTI models SYS1 and SYS2
%   based on the flags SFLAGS:
%      SFLAGS(1) = 1  ---> SYS1 is a static gain
%      SFLAGS(2) = 1  ---> SYS2 is a static gain
%
%   L1 and L2 are the LTI parents of SYS1 and SYS2.
%
%   LOW-LEVEL UTILITY.

%       Author(s):  P. Gahinet, 5-23-96
%       Copyright 1986-2002 The MathWorks, Inc. 
%       $Revision: 1.8 $  $Date: 2002/04/10 05:48:20 $


% Extract sample times and "static gain" flags
Ts1 = L1.Ts; 
Ts2 = L2.Ts;

% Quick exit if 
%   * neither model is a static gain
%   * both are static gains with positive and distinct sample times
if ~any(sflags) | (all(sflags) & Ts1~=Ts2 & Ts1>0 & Ts2>0)
   return
end

% Determine common sample time TS as follows:
%   * if SYS1 is not static, pick TS = SYS1.TS
%   * if SYS2 is not static, pick TS = SYS2.TS
%   * if both are static gains, apply the rules
%       (a) discrete sample times wins over Ts=0
%       (b) if TS1 and TS2 are discrete, take MAX(TS1,TS2)
%           (at this point either TS1==TS2 or one of the two 
%            is -1 for unspecified)
%
Ts = (~sflags(1))*Ts1 + (~sflags(2))*Ts2 + ...
     (sflags(1)&sflags(2)) * (xor(Ts1,Ts2)*(Ts1+Ts2) + (Ts1&Ts2) * max(Ts1,Ts2)); 
L1.Ts = Ts;
L2.Ts = Ts;

