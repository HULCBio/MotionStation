function str = dspblkvdf2t(action)
% DSPBLKVDF2T Mask dynamic dialog function for Time-Varying Direct-Form II
% Transpose filter block


% Copyright 1995-2002 The MathWorks, Inc.
% $Date: 2002/04/14 20:56:32 $ $Revision: 1.10 $

if nargin==0, action = 'dynamic'; end
frame_based = get_param(gcb, 'frame');

switch action
   case 1  % Pole Zero
      str.i1 = 2;  str.s1 = 'Num';
      str.i2 = 3;  str.s2 = 'Den';
      str.x = [.2 .8 .7 .7 .5 .5 .3 .3  .7  .3  .3 .7 .3 .3  .7  .3  .3 .7];
      str.y = [.7 .7 .7 .1 .1 .7 .7 .55 .55 .55 .4 .4 .4 .25 .25 .25 .1 .1];
      str.icon = 'IIR';
    case 2  % FIR
      str.i1 = 2;  str.s1 = '';
      str.i2 = 2;  str.s2 = 'Num';
      str.x = [.3 .8 .7 .5 .6 .5 .5 .4 .3 .5 .2];
      str.y = [.1 .1 .1 .7 .1 .1 .7 .1 .1 .7 .7];
      str.icon = 'FIR';
   case 3  % All Pole
      str.i1 = 2;  str.s1 = '';
      str.i2 = 2;  str.s2 = 'Den';
      str.x = [.2 .8 .6 .6 .4 .4 .4  .6  .4  .4 .6 .4 .4  .6  .4  .4 .6];
      str.y = [.7 .7 .7 .1 .1 .7 .55 .55 .55 .4 .4 .4 .25 .25 .25 .1 .1];
      str.icon = 'AR';      
   case 'dynamic'     
      % Execute dynamic dialogs
      
      % The third dialog (checkbox for frame-based inputs)
      % disables/enables the fourth and fifth dialogs 
      % (number of channels and filter update rate).
      
      % Get status of frame checkbox
      mask_enables = get_param(gcb,'maskenables');
      mask_enables{5} = frame_based;
      mask_enables{6} = frame_based;
      set_param(gcb,'maskenables',mask_enables);
      
   otherwise
      error('unhandled case');
end
   
% end of dspblkvdf2t.m
