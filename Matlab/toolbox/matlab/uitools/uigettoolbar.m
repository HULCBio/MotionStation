function [out] = uigettoolbar(fig,id)
% DEPRECATED, DO NOT USE

% Copyright 2002 The MathWorks, Inc.

% C = UIGETTOOLBAR(H,'GroupName.ComponentName')
%     H is a figure or toolbar handle
%     'GroupName' is the name of the toolbar group
%     'ComponentName' is the name of the toolbar component
%     C is a toolbar component
%
%  Enter UITOOLBARFACTORY with no arguments to see a full listing
%  of possible Groups and Components.
%
% Example:
%
% h = figure;
% c = uigettoolbar(h,'Exploration.ZoomIn');
%
% See also UITOOLBARFACTORY

% Note: All code here must have fast performance
% since this function will be used in callbacks.
htoolbar = findall(fig,'type','uitoolbar');
out = findall(htoolbar,'Tag',id);
