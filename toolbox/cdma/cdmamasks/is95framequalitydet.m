% IS95FRAMEQUALITYDET IS-95A Frame Quality Detection helper function

% Copyright 2000-2002 The MathWorks, Inc. and ALGOREX, Inc.
% $Revision: 1.13 $ $Date: 2002/04/14 16:31:54 $

switch chType
case 1
   % Sync
   set_param(sprintf([gcb '/IS-95A Syndrome\nDetector']),'chType','Sync');
case 2
   % Paging
   set_param(sprintf([gcb '/IS-95A Syndrome\nDetector']),'chType','Paging');
case 3
   % Access
   set_param(sprintf([gcb '/IS-95A Syndrome\nDetector']),'chType','Access');
case 4
   % Traffic
   set_param(sprintf([gcb '/IS-95A Syndrome\nDetector']),'chType','Traffic');
end;
switch rateSet
case 1
   % Rate Set I
   set_param(sprintf([gcb '/IS-95A Syndrome\nDetector']),'rate_set','Rate Set I');
case 2
   % Rate Set II
   set_param(sprintf([gcb '/IS-95A Syndrome\nDetector']),'rate_set','Rate Set II');
end;
