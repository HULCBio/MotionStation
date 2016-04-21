function dspblkrebuff(action)
% DSPBLKREBUFF Signal Processing Blockset Rebuffer block helper function.

% Copyright 1995-2003 The MathWorks, Inc.
% $Revision: 1.6.4.2 $ $Date: 2004/04/12 23:07:07 $

if nargin==0, action = 'dynamic'; end

blk   = gcbh;
fullblk = getfullname(blk);
specify_out_size = strcmp(get_param(blk,'Specify_Out_Size'),'on');
frame = strcmp(get_param(blk,'Frame'),'on');

switch action 
case 'dynamic'
   % Dynamic dialog callback:
   mask_enables = get_param(blk,'maskenables');
   
   if specify_out_size,
      mask_enables{2} = 'on';
   else
      mask_enables{2} = 'off';
   end
   
   if frame,
      mask_enables{6} = 'on';
   else
      mask_enables{6} = 'off';
   end
   set_param(blk,'maskenables',mask_enables);
end
