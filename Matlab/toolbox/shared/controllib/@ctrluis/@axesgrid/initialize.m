function initialize(this,hgaxes)
%INITIALIZE  Configures axes grid.

%   Author: P. Gahinet
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:16:48 $

nr = prod(this.Size([1 3]));  % total number of rows in axes grid
nc = prod(this.Size([2 4]));  % total number of columns in axes grid

% Create supporting plotarray instances
this.Axes = ctrluis.plotarray(this.Size,hgaxes(:));   % private
this.Axes4d = getaxes(this.Axes);  % array of HG axes of size GRIDSIZE
this.Axes2d = reshape(permute(this.Axes4d,[3 1 4 2]),[nr,nc]);

% Settings inherited from template axes
this.XLimMode = hgaxes(1).XLimMode;
this.YLimMode = hgaxes(1).YLimMode;
this.NextPlot = hgaxes(1).NextPlot;
this.ColumnLabel = repmat({''},[nc 1]);
this.RowLabel = repmat({''},[nr 1]);

% Configure axes
set(this.Axes2d,'Units','normalized','Box','on',...
   'XtickMode','auto','YtickMode','auto',...
   'XScale',hgaxes(1).XScale,'YScale',hgaxes(1).YScale,...
   'Xlim',hgaxes(1).Xlim,'Ylim',hgaxes(1).Ylim,...
   'NextPlot',this.NextPlot,'UIContextMenu',this.UIContextMenu,...
   'XGrid','off','YGrid','off',struct(this.AxesStyle));

% Add listeners
addlisteners(this)

% Add bypass for TITLE, AXIS,...
addbypass(this)