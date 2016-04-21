function updategrid(this,varargin)
%UPDATEGRID  Redraws custom grid.

%   Author: P. Gahinet
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:17:23 $
% RE: Callback for LimitChanged event
if ~isempty(this.GridFcn) & strcmp(this.Grid,'on')
    
    % Clear existing grid
    cleargrid(this)

    % Save current zoom mode
    zoommode = zoom(double(this.Parent),'getmode');
    
    % Evaluate GridFcn to redraw custom grid
    GridHandles = feval(this.GridFcn{:});
    this.GridLines = handle(GridHandles(:));
    
    % Restore zoommode if necessary
    if strcmpi('in',zoommode),
        zoom(double(this.Parent),'on');
    elseif strcmpi('out',zoommode),
        zoom(double(this.Parent),'outmode');
    end
    
end