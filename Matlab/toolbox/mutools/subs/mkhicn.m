% mkhicn

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

echo off
himat = [ ...
   -0.0226  -36.6000  -18.9000  -32.1000         0         0    4.0000;
         0   -1.9000    0.9830         0   -0.4140         0         0;
    0.0123  -11.7000   -2.6300         0  -77.8000   22.4000         0;
         0         0    1.0000         0         0         0         0;
         0   57.3000         0         0         0         0         0;
         0         0         0   57.3000         0         0         0;
         0         0         0         0         0         0      -Inf];



systemnames = 'himat wdel wp wn';

% ORIGINAL MULTIPLICATIVE UNCERTAINTY WEIGHT
wdel = nd2sys([50 5000],[1 10000]);

% SLIGHTLY RELAXED PERFORMANCE OBJECTIVE
wp = nd2sys([0.5 1.5*0.6],[1 0.03*0.6]);

% NEW SENSOR NOISE WEIGHT
poleloc = 320;
wn = nd2sys([2 .008*poleloc],[1 poleloc]);

wdel = daug(wdel,wdel);
wp = daug(wp,wp);
wn = daug(wn,wn);

inputvar = '[pert{2}; dist{4}; control{2}]';
outputvar = '[ wdel ; wp; himat + dist(1:2) + wn ]';
input_to_himat = '[ control + pert ]';
input_to_wdel = '[ control ]';
input_to_wp = '[ himat+dist(1:2) ]';
input_to_wn = '[ dist(3:4) ]';
sysoutname = 'himat_ic';
cleanupsysic = 'yes';
sysic

%
%