%  file: ex_usti2.m

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

 systemnames = 'K1dk';
 inputvar = '[ ref; e ]';
 outputvar = '[ e; K1dk; K1dk ]';
 input_to_K1dk = '[ -ref+e ]';
 sysoutname = 'olp1';
 cleanupsysic = 'yes';
 sysic

 systemnames = 'K3dk';
 inputvar = '[ ref; e ]';
 outputvar = '[ e; K3dk; K3dk ]';
 input_to_K3dk = '[ -ref+e ]';
 sysoutname = 'olp3';
 cleanupsysic = 'yes';
 sysic