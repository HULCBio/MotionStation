function hZoom = createsignalzoom(hFig, hcbo)
%CREATESIGNALZOOM Create the zoom object given a figure

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2002/09/24 20:26:51 $ 

hZoom = siggetappdata(hFig, 'siggui', 'mousezoom');

if isempty(hZoom),
    
    if nargin < 2,
        tag = 'none';
    else
        tag = get(hcbo, 'tag');
    end
    
    sigguiData = siggetappdata(hFig,'siggui');
    
    % Create a mousezoom object
    hZoom = siggui.mousezoom(hFig, tag,...
        sigguiData.ZoomBtns, sigguiData.ZoomMenus);
    
    % Set the callbacks of the zoom buttons and zoom menu items to the methods
    % of the mousezoom object.
    callbacks(hZoom);
    
    % Store the object in the application data of the figure
    sigsetappdata(hFig,'siggui','mousezoom',hZoom);
end

% [EOF]
