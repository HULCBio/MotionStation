function setstyle(this,src,varargin)
%SETSTYLE  User-friendy specification of style attributes.
%
%  SETSTYLE(ViewObj,SYSTEM,'r-x') specifies a color/linestyle/marker 
%  for the system with handle SYSTEM (@respsource).
%
%  SETSTYLE(ViewObj,SYSTEM,'Property1',Value1,...) specifies individual  
%  style attributes.  Valid properties include Color, LineStyle, LineWidth, 
%  and Marker.

%  Author(s): P. Gahinet
%  Copyright 1986-2002 The MathWorks, Inc.
%  $Revision: 1.8 $  $Date: 2002/05/04 02:08:27 $

% Dissociate style from StyleManager
% RE: Direct setting leads to aliasing (changing the style of Systems(8) also 
%     changes the style of Systems(1) and corrupts the first style in the 
%     StyleManager)
NewStyle = wavepack.wavestyle;
NewStyle.setstyle(varargin{:});

% Find and replace old style
idx = find(this.Systems==src);
OldStyle = this.Styles(idx);
for v=cat(1,this.PlotCells{:})'
   if isa(v,'resppack.respplot') & ~isempty(v.Responses)
      set(find(v.Responses,'DataSrc',src),'Style',NewStyle)
   end
end

% Update Styles list
Styles = this.Styles;
Styles(idx) = NewStyle;
this.Styles = Styles;