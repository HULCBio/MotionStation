function initialize(this,Axes)
%INITIALIZE  Initialization for @TimeFinalValueView class

%  Author(s): John Glass
%  Revised  : Kamesh Subbarao
%  Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:20:10 $

[s1,s2] = size(Axes(:,:,1)); 
HLines = zeros([s1 s2]);

for ct=1:s1*s2
   % Plot dc lines lines
   % RE: Set Z=-10 to make sure dc lines don't obscure response lines
   HLines(ct) = line(NaN,NaN,-10,...
      'Parent',Axes(ct),...
      'Visible','off',...
      'LineStyle',':',...
      'Selected','off',...
      'XlimInclude','off', 'YlimInclude','off',...
      'HandleVisibility','off','HitTest','off',...
      'Color','k');
end

this.HLines = handle(HLines);