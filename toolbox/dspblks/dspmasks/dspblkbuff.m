function varargout = dspblkbuff(action)
% DSPBLKBUFF Signal Processing Blockset Buffer block helper function
% for mask parameters.

% Copyright 1995-2003 The MathWorks, Inc.
% $Revision: 1.5.4.2 $ $Date: 2004/04/12 23:06:03 $

if nargin==0, action = 'dynamic'; end

switch action
case 'dynamic'
   
   blk = gcbh;
   frame_based  = get_param(blk,'frame');
   mask_enables = get_param(blk,'MaskEnables');
 	mask_prompts = get_param(blk,'MaskPrompts');
    
   isFrame = strcmp(frame_based,'on');

   if isFrame,
      mask_enables{5} = 'on';
      mask_prompts{1} = 'Buffer size (number of frames):';
      mask_prompts{2} = 'Buffer overlap  (number of frames):';
   else
      mask_enables{5} = 'off';
      mask_prompts{1} = 'Buffer size (number of samples):';
      mask_prompts{2} = 'Buffer overlap  (number of samples):';
   end

	set_param(blk,'MaskEnables',mask_enables);
	set_param(blk,'MaskPrompts',mask_prompts);

   
case 'icon'

	x = [0 NaN 100 NaN 12 28 28 32 28 28 NaN 32 36 36 40 36 36 NaN 24 24 28 NaN 40 44 44 48 44 44,...
        NaN 52 48 52 52 56 52 52 NaN 56 64 64 57 64 71 NaN 48 80 80 48 48 NaN 56 72 NaN 56 72 NaN,...
	     56 72 NaN 56 72 NaN 56 72];

	y = [0 NaN 100 NaN 92 92 94 92 90 92 NaN 92 92 94 92 90 92 NaN 92 92 92 NaN 92 92 94 92 90 92,...
        NaN 92 92 92 94 92 90 92 NaN 92 92 69 76 69 76 NaN 64 64 12 12 64 NaN 56 56 NaN 48 48 NaN,...
     	  40 40 NaN 32 32 NaN 24 24];

   varargout(1:2) = {x,y};
   
end
