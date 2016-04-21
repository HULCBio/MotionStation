%
% load for the Structured Singular Value Example
%

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

echo off

load muexampa.dat
load muexampb.dat
load muexampc.dat

muexampa = reshape(muexampa,14,14);
muexampb = reshape(muexampb,14,9);
muexampc = reshape(muexampc,9,14);

g = pck(muexampa,muexampb,muexampc);