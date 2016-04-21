function draw(this, Data,NormalRefresh)
% Draws input data.

%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:23:38 $

%  Time:      Ns x 1
%	Amplitude: Ns x Nu 

% Redraw the curves
if isempty(Data.Time) || strcmp(this.AxesGrid.YNormalization,'on')
   % RE: Defer to ADJUSTVIEW:postlim for normalized case (requires finalized X limits)
   set(this.Curves,'XData',[],'YData',[])
else
   % Map data to curves
   Nu = size(Data.Amplitude,2);
   switch this.Style
      case 'line'
         for ct=1:Nu
            set(double(this.Curves(ct)), 'XData', Data.Time,'YData', Data.Amplitude(:,ct));
         end
      case 'stairs'
         for ct=1:Nu
            [T,Y] = stairs(Data.Time,Data.Amplitude(:,ct));
            set(double(this.Curves(ct)), 'XData', T, 'YData', Y);
         end
   end
end
