function init_prop(this,ax,gridsize)
%INIT_PROP  Generic initialization of response plot properties.

%  Author(s): Bora Eryilmaz
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.3 $  $Date: 2004/04/16 22:20:04 $
[hasFixedRowSize,hasFixedColSize] = hasFixedSize(this);

% REVISIT: do in one shot when this.InputName(1:x,1) = ... works
if ~hasFixedColSize
   InputName(1:gridsize(2),1) = {''};
   this.InputName     = InputName;
   InputVisible(1:gridsize(2),1) = {'on'};
   this.InputVisible  = InputVisible;
end
if ~hasFixedRowSize
   OutputName(1:gridsize(1),1) = {''};
   this.OutputName    = OutputName; 
   OutputVisible(1:gridsize(1),1) = {'on'};
   this.OutputVisible = OutputVisible;
end

% Create Style DataBase
this.StyleManager = wavepack.WaveStyleManager;

% Plot visibility inherited from template axes
if ~isempty(ax)
   this.Visible = get(ax, 'Visible');
end
