function setzoomstate(hFig, varargin)
%SETZOOMSTATE Function to set or reset the axes state.
% 
%  This function is called when the analysis changes. This is required as
%  the UICSMenu has to be restored between analyses.
%
%  Input:
%    hFig - Handle to the figure.
%    varargin - is empty or 'none' when called from FVTool.

%   Author(s): R. Malladi
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.10 $  $Date: 2002/08/26 19:39:23 $ 

hZoom = siggetappdata(hFig,'siggui','mousezoom');

% If zoom has not been turned on yet, return.
if isempty(hZoom)
    return;
end

if strcmpi(get(hZoom,'zoomState'),'none')
    return;
end

resetState = '';
if ~isempty(varargin)
    % resetState = 'none'. This is called from the analyses callback fcn.
    resetState = varargin{1};
end

% resetState is empty when called from update (to reset the axesState).
% call the setzoomstate method
setzoomstate(hZoom,resetState);

% [EOF]
