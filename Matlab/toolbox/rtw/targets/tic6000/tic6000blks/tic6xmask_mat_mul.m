function tic6xmask_mat_mul()
% TIC6XMASK_MAT_MUL TIC62/C64 DSPLIB Blockset Matrix Multiply block
% mask helper function.

% Copyright 2001-2003 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/08 21:00:54 $

blk = gcbh;
s = get_param(blk,'out_method');
   
mask_enables = get_param(blk,'maskenables');
      
if strcmp(s,'User-defined'),
    mask_enables(2) = {'on'};
else
    mask_enables(2) = {'off'};
end

set_param(blk,'maskenables',mask_enables);

% EOF tic6xmask_mat_mul.m
