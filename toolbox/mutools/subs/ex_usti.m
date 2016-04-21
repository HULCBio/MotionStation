%  file: ex_usti.m

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

 systemnames = 'K1';
 inputvar = '[ ref; e ]';
 outputvar = '[ e; K1; K1 ]';
 input_to_K1 = '[ -ref+e ]';
 sysoutname = 'olp1';
 cleanupsysic = 'yes';
 sysic

 systemnames = 'K2';
 inputvar = '[ ref; e ]';
 outputvar = '[ e; K2; K2 ]';
 input_to_K2 = '[ -ref+e ]';
 sysoutname = 'olp2';
 cleanupsysic = 'yes';
 sysic