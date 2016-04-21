% IS95NONCOHDETECTOR IS-95A Noncoherent Rake Receiver helper function

% Copyright 2000-2002 The MathWorks, Inc. and ALGOREX, Inc.
% $Revision: 1.13 $ $Date: 2002/04/14 16:32:29 $

switch chType
case 1
   % Access
   set_param(sprintf([gcb ,'/Rev Ch Randomizer\nGating Signal Generator/IS-95A Rev Ch\nBurst Randomizer']),'chType','Access');
case 2
   % Traffic
   set_param(sprintf([gcb ,'/Rev Ch Randomizer\nGating Signal Generator/IS-95A Rev Ch\nBurst Randomizer']),'chType','Traffic');
end;

N = 1;
M = 1;
