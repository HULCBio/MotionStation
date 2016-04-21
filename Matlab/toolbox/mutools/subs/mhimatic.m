% mhimatic
%
% Make up `himat_ic' for the H-infinity example
%

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

echo off
 WDEL = nd2sys([50,5000],[1,10000]);
 WP = nd2sys([0.5,1.5],[1,0.03]);
 WDEL = daug(WDEL,WDEL);
 WP = daug(WP,WP);
 mkhimat

echo off
systemnames = 'himat WDEL WP';
inputvar = '[pert(2); dist(2); control(2)]';
outputvar = '[ WDEL ; WP; himat + dist ]';
input_to_himat = '[ control + pert ]';
input_to_WDEL = '[ control ]';
input_to_WP = '[ himat + dist ]';
sysoutname = 'himat_ic';
cleanupsysic = 'yes';
sysic

%
%
echo on