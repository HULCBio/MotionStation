function [x,y,str] = dspblkvlat(action)
% DSPBLKVLAT Mask dynamic dialog function for Time-Varying
% Lattice filter block


% Copyright 1995-2002 The MathWorks, Inc.
% $Date: 2002/04/14 20:56:45 $ $Revision: 1.7 $

if nargin==0, action = 'dynamic'; end
frame_based = get_param(gcb, 'frame');

switch action
   case 1  % MA
      str.i1 = 2;  str.s1 = '';
      str.i2 = 2;  str.s2 = 'MA';
      [x,y] = lattice;
      x = 1.0 - x;
   case 2  % AR
      str.i1 = 2;  str.s1 = '';
      str.i2 = 2;  str.s2 = 'AR';
      [x,y] = lattice;
   case 'dynamic'     
      % Execute dynamic dialogs
      
      % The third dialog (checkbox for frame-based inputs)
      % disables/enables the fourth and fifth dialogs 
      % (number of channels and filter update rate).
      
      % Get status of frame checkbox
      mask_enables = get_param(gcb,'maskenables');
      mask_enables{4} = frame_based;
      mask_enables{5} = frame_based;
      set_param(gcb,'maskenables',mask_enables);
      
   otherwise
      error('unhandled case');
end
   
function [x,y] = lattice
   
x = [.2 .8 .725 .725 .575 .675 .575 .675 .425 .525 .425 .525 .375 .275];
y = [.7 .7 .7   .3   .3   .7   .7   .3   .3   .7   .7   .3   .3   .7];  

   
% end of dspblkvlat.m
