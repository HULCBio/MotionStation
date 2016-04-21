function h = sptlinetip(LINE, varargin)
%SPTLINETIP  Linetip wrapper function.
%
%   h = SPTLINETIP(LINE,'PropertyName1',value1,'PropertyName2,'value2,...) 
%   will activate linetip with the following options:
%
%      LINE:       handle of line to be scanned.

%   SPTLINETIP is a copy of the LINETIP.M function from the Control
%   System Toolbox.  

%  Author(s): John Glass
%  Copyright 1988-2002 The MathWorks, Inc.
%  $Revision: 1.3 $  $Date: 2002/11/21 15:36:13 $

% Create linetip
try
    h=spttippack.linetip(LINE);
catch
    error('Linetip can only be a child of a line object.')
    return
end
% Set Properties
set(h,varargin{:});

% Populate h.X, h.Y if they are not specified by the user
if isempty(varargin)
    curr = get(h.getaxes,'CurrentPoint');
    h.X = curr(1,1);
    h.Y = curr(1,2);
end

if ~max(strcmpi(varargin,'X')) | isempty(varargin)
    curr = get(get(LINE,'Parent'),'CurrentPoint');
    h.X = curr(1,1); 
end

if ~max(strcmpi(varargin,'Y')) | isempty(varargin)
    curr = get(get(LINE,'Parent'),'CurrentPoint');
    h.Y = curr(1,2);
end

% Draw linetip
h.initialize;
h.draw('on');
h.movetofront;
h.findorientation;

h.addmenu('alignment','fontsize','movable');
h.addlinetipmenu('interpolation','trackmode');

% Add Delete and Delete All to the bottom of the Context-menu
h.addmenu('delete','delete_all');

setappdata(h.MarkerHandle, 'zoomable', 'off');