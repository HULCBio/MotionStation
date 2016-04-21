% IS95REVCHMODSPREAD IS-95A Rev Ch Walsh Modulation and Spreading 
% helper function

% Copyright 2000-2002 The MathWorks, Inc. and ALGOREX, Inc.
% $Revision: 1.13 $ $Date: 2002/04/14 16:31:34 $

switch chType
case 1
   % Access
   set_param(sprintf([gcb '/IS-95A Rev Ch\nBurst Randomizer']),'chType','Access');
case 2
   % Traffic
   set_param(sprintf([gcb '/IS-95A Rev Ch\nBurst Randomizer']),'chType','Traffic');
end;

% Check for maximum walsh order 
if (wlshOrd > 10)
error('Block does not support Walsh Order higher than 10');
end;
