function init_prop(this,ax,gridsize)
%INIT_PROP  Generic initialization of response plot properties.

%  Author(s): P. Gahinet
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:26:36 $

% REVISIT: do in one shot when this.ChannelName(1:x,1) = ... works
ChannelName(1:gridsize(1),1) = {''};
this.ChannelName    = ChannelName; 
ChannelVisible(1:gridsize(1),1) = {'on'};
this.ChannelVisible = ChannelVisible;

% Create Style DataBase
this.StyleManager = wavepack.WaveStyleManager;

% Plot visibility
this.Visible = get(ax, 'Visible');

