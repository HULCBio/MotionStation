function [x,y,str] = dspblkvlat2(action)
% DSPBLKVLAT2 Mask dynamic dialog function for Time-Varying
% Lattice filter block


% Copyright 1995-2002 The MathWorks, Inc.
% $Date: 2002/04/14 20:57:57 $ $Revision: 1.5 $

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
      
   otherwise
      error('unhandled case');
end
   
function [x,y] = lattice
   
x = [.2 .8 .725 .725 .575 .675 .575 .675 .425 .525 .425 .525 .375 .275];
y = [.7 .7 .7   .3   .3   .7   .7   .3   .3   .7   .7   .3   .3   .7];  

   
% end of dspblkvlat2.m
