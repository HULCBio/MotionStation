function out = niclims(action,varargin)
%NICLIMS  Adjusts axis limits to account for Nichols chart.
%
%   XLIM = NICLIMS('phase',XLIM,UNITS) or YLIM = NICLIMS('mag',YLIM,UNITS) 
%   adjusts the supplied limit values XLIM or YLIM to show entire 180 deg
%   portions of the Nichols chart.
%
%   See also NICHOLS, NICCHART.

%   Authors: P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.5 $ $Date: 2002/04/10 04:42:52 $

if isempty(varargin{1})
   out = []; 
   return
end

switch action
   
case 'phase'
   % Adjust phase limits
   [Xlim,Units] = deal(varargin{1:2});
   % Adjust X limits so that grid is clipped at multiples of 180 degrees
   switch Units
   case 'deg'
      Pi = 180;  TwoPi = 360;
   case 'rad'
      Pi = pi;   TwoPi = 2*pi;
   end
   Pmax = TwoPi*ceil(Xlim(2)/TwoPi);
   Pmin = min(Pmax-TwoPi,TwoPi*floor(Xlim(1)/TwoPi));
   if Pmax-Pmin>TwoPi,
      % Delete empty 180 degree portions
      Pmax = Pi*ceil(Xlim(2)/Pi);
      Pmin = Pi*floor(Xlim(1)/Pi);
   end
   out = [Pmin Pmax];
   
case 'mag'
   % Adjust gain limits
   [Ylim,Units] = deal(varargin{1:2});
   switch Units
   case 'dB'
      Gmin = min([-20 20*floor(Ylim(1)/20)]);
      Gmax = max([40 20*ceil(Ylim(2)/20)]);
   otherwise
      Gmin = Ylim(1);
      Gmax = Ylim(2);
   end
   out = [Gmin Gmax];
   
end