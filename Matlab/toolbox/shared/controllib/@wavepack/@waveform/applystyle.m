function applystyle(this,varargin)
%APPLYSTYLE  Applies style settings to @waveform instance.

%  Author(s): John Glass
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:26:07 $
rdim = this.RowIndex; 
cdim = this.ColumnIndex; 
style = this.Style;

% Apply to each view
for ct=1:length(this.View)
    this.View(ct).applystyle(style,rdim,cdim,ct);
end

% Apply to wave characteristics
for c=this.Characteristics'
   for ct = 1:length(c.View)
      c.View(ct).applystyle(style,rdim,cdim,ct);
   end
end