function draw(this, Data,NormalRefresh)
%DRAW  Draws time response curves.
%
%  DRAW(VIEW,DATA) maps the response data in DATA to the curves in VIEW.

%  Author(s): John Glass, Bora Eryilmaz
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:25:54 $

% Time:      Ns x 1
% Amplitude: Ns x Ny x Nu

% Input and output sizes
[Ny, Nu] = size(this.Curves);

% Redraw the curves
if strcmp(this.AxesGrid.YNormalization,'on')
   % RE: Defer to ADJUSTVIEW:postlim for normalized case (requires finalized X limits)
   set(double(this.Curves),'XData',[],'YData',[])
else
   % Map data to curves
   switch this.Style
   case 'line'
      for ct = 1:Ny*Nu
         set(double(this.Curves(ct)), 'XData', Data.Time, ...
            'YData', Data.Amplitude(:,ct));
      end
   case 'stairs'
      for ct = 1:Ny*Nu
         [T,Y] = stairs(Data.Time,Data.Amplitude(:,ct));
         set(double(this.Curves(ct)), 'XData', T, 'YData', Y);
      end
   end
end