function varargout = dspblkedetect(action)
% DSPBLKEDETECT Signal Processing Blockset Edge Detection block helper function.

% Copyright 1995-2003 The MathWorks, Inc.
% $Revision: 1.8.4.2 $ $Date: 2004/04/12 23:06:23 $

if nargin==0, action = 'dynamic'; end

blk   = gcbh;
fullblk = getfullname(blk);
frame = strcmp(get_param(blk,'Frame'),'on');

switch action 
case 'icon'
   x = [.1 .2 .2 .5 .5 .7 .7 .8 .8 .9 NaN ...
        .1 .9 NaN .2 .2 NaN .7 .7];
   y = [.6 .6 .9 .9 .6 .6 .9 .9 .6 .6 NaN ...
        .1 .1 NaN .1 .5 NaN .1 .5];
   varargout = {x,y};
   
case 'update'
   % Update delay block:
   delay_blk = [fullblk '/Integer Delay'];
   if frame,
      set_param(delay_blk,'Frame','on');
   else
      set_param(delay_blk,'Frame','off');
   end
   
   
case 'dynamic'
   % Dynamic dialog callback:
   
   mask_enables = get_param(blk,'maskenables');
   if frame,
      mask_enables{2} = 'on';
   else
      mask_enables{2} = 'off';
   end
   set_param(blk,'maskenables',mask_enables);
end
