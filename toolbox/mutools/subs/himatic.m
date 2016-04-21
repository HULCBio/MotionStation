
%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

echo off
systemnames = 'himat wdel wp';
inputvar = '[pert(2); dist(2); control(2)]';
outputvar = '[ wdel ; wp; himat + dist ]';
input_to_himat = '[ control + pert ]';
input_to_wdel = '[ control ]';
input_to_wp = '[ himat + dist ]';
sysoutname = 'himat_ic';
cleanupsysic = 'yes';
sysic

echo on
%
%