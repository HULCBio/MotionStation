% file: ex_unic.m

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

 G = nd2sys(1,[1 -1]);
 Wu = nd2sys([0.5 1],[0.03125 1],.25);
 Wp = nd2sys([.25 0.6],[1 0.006]);
 systemnames = 'G Wu Wp';
    sysoutname = 'P';
    inputvar = '[ z; d; u ]';
    input_to_G = '[ z + u ]';
    input_to_Wu = '[ u ]';
    input_to_Wp = '[ d + G ]';
    outputvar = '[ Wu; Wp; G + d ]';
    cleanupsysic = 'yes';
 sysic