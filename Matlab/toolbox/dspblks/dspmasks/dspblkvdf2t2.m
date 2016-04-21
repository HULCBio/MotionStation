function str = dspblkvdf2t2(action)
% DSPBLKVDF2T2 Mask dynamic dialog function for Time-Varying Direct-Form II
% Transpose filter block


% Copyright 1995-2002 The MathWorks, Inc.
% $Date: 2002/04/14 20:57:52 $ $Revision: 1.5 $

if nargin==0, action = 'dynamic'; end

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
   otherwise
      error('unhandled case');
end
   
% end of dspblkvdf2t2.m
