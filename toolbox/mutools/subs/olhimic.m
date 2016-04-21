% olhimic.m

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

echo off
systemnames = 'himat';
inputvar = '[dist{2}; control{2}]';
outputvar = '[ control; himat + dist; himat + dist ]';
input_to_himat = '[ control ]';
sysoutname = 'olsim_himat';
cleanupsysic = 'yes';
sysic

echo on
%
%