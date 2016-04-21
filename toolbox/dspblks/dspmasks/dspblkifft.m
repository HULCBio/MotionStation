function dspblkifft
% DSPBLKIFFT Signal Processing Blockset IFFT block helper function.

% Copyright 1995-2003 The MathWorks, Inc.
% $Revision: 1.5.4.2 $ $Date: 2004/04/12 23:06:40 $

blk   = gcbh;
realout = strcmp(get_param(blk,'mode'),'Real');


% Dynamic dialog callback:
mask_enables = get_param(blk,'maskenables');
if realout,
   mask_enables{2} = 'on';
else
   mask_enables{2} = 'off';
end
set_param(blk,'maskenables',mask_enables);

