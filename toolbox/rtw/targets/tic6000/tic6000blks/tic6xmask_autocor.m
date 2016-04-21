function tic6xmask_autocor()
% TIC6XMASK_AUTOCOR TI C62/C64 DSPLIB Blockset Autocorrelation block
% mask helper function.

% Copyright 2002-2003 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2004/01/22 18:29:48 $

blk = gcbh;
AllPositiveLags = get_param(blk,'allposlag');
   
mask_enables = get_param(blk,'maskenables');
      
if strcmp(AllPositiveLags,'on'),
    mask_enables(2) = {'off'};
else
    mask_enables(2) = {'on'};
end

set_param(blk,'maskenables',mask_enables);

