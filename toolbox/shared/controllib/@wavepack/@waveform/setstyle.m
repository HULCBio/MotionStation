function setstyle(this,varargin)
%SETSTYLE  Applies user-defined style to @waveform instance.
%
%  SETSTYLE(WF,'r-x') specifies a color/linestyle/marker string.
%
%  SETSTYLE(WF,'Property1',Value1,...) specifies individual style 
%  attributes.  Valid properties include Color, LineStyle, LineWidth, 
%  and Marker.

%  Author(s): P. Gahinet, Karen Gondoly
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:26:22 $

if ~isempty(varargin{1})
   % Create new @style instance to avoid corrupting style 
   % manager's style pool
   Style = wavepack.wavestyle;
   Style.setstyle(varargin{:});
   % Apply style
   this.Style = Style;
end