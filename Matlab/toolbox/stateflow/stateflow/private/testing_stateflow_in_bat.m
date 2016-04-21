function flag = testing_stateflow_in_bat(flag),
%
% Maintains info on whether the session is a BAT testing session

%   Vijay Raghavan
%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.5.2.1 $  $Date: 2004/04/15 01:01:08 $

persistent sTestingStatus

if(isempty(sTestingStatus))
   sTestingStatus = 0;
   mlock;
end

if(nargin==0) 
   flag = sTestingStatus;
else
   sTestingStatus = flag;
end



