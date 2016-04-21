function draw(this, Data,NormalRefresh)
%DRAW  Draws time response curves.
%
%  DRAW(VIEW,DATA) maps the response data in DATA to the curves in VIEW.

%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:23:43 $

%  Time:      Ns x 1
%	Amplitude: Ns x 1

% Redraw the curves
if isempty(Data.Time) | strcmp(this.AxesGrid.YNormalization,'on')
   % RE: Defer to ADJUSTVIEW:postlim for normalized case (requires finalized X limits)
   set(this.Curves,'XData',[],'YData',[])
else
   % Map data to curves
   switch this.Style
   case 'line'
      set(double(this.Curves), 'XData', Data.Time,'YData', Data.Amplitude);
   case 'stairs'
      [T,Y] = stairs(Data.Time,Data.Amplitude);
      set(double(this.Curves), 'XData', T, 'YData', Y);
   end
end