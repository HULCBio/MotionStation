function resize(this,varargin)
%RESIZE  Dynamic resizing of axes grid.

%   Author: P. Gahinet
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:16:51 $

% Turn grid off
GridState = this.Grid;
this.Grid = 'off';

% Clear all listeners
delete(this.LimitListeners)
this.LimitListeners = [];
delete(this.Listeners)
this.Listeners = [];

% Delete size-dependent GUIs
delete(this.AxesSelector)
this.AxesSelector = [];

% Determine visibility of model (1,1) axes subgrid
Size = this.Size;
Vis = {'off';'on'};
lr = length(this.RowVisible);
RowVis = any(reshape(strcmp(this.RowVisible,'on'),Size(3),lr/Size(3)),2);
if ~any(RowVis)
   RowVis(:) = true;
end
lc = length(this.ColumnVisible);
ColVis = any(reshape(strcmp(this.ColumnVisible,'on'),Size(4),lc/Size(4)),2);
if ~any(ColVis)
   ColVis(:) = true;
end

% Update size-dependent properties
this.XScale = repmat(this.XScale(1:Size(4)),[Size(2) 1]);
this.YScale = repmat(this.YScale(1:Size(3)),[Size(1) 1]);
this.ColumnVisible = repmat(Vis(1+ColVis),[Size(2) 1]);
this.RowVisible = repmat(Vis(1+RowVis),[Size(1) 1]);

% Adjust number of axes
ax = this.Axes4d(:);
nax0 = length(ax);
nax = prod(Size);
delete(ax(nax+1:nax0));

% Reconfigure template axes with appropriate defaults
set(ax(1),'XlimMode','auto','YlimMode','auto','NextPlot','replace','Position',this.Position)

% Reinitialize size-dependent settings
initialize(this,ax(1:min(nax,nax0)))

% Reapply geometry (normally triggered by change in this.Geometry)
setgeometry(this)

% Apply axes scales
hgax = this.Axes2d;
for ct=1:size(hgax,2)
   set(hgax(:,ct),'XScale',this.XScale{ct});
end
for ct=1:size(hgax,1)
   set(hgax(ct,:),'YScale',this.YScale{ct});
end

% Propagate ButtonDown fcn
set(hgax,'ButtonDownFcn',ax(1).ButtonDownFcn)

% Refresh
refresh(this)

% Notify peers (before resetting grid to correctly 
% update background lines, cf. g132408)
this.send('SizeChanged')

% Restore grid state
this.Grid = GridState;

% Reinstall limit manager (after resetting grid to 
% avoid triggering limit update before data has been 
% updated, cf. g132408)
addlimitmgr(this)