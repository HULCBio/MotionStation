function fcns = zoom_cbs(hFig,varargin)
%ZOOM_CBS "Zoom" toolbar buttons and menus callbacks.
%
%  Also create the mousezoom object and change the zoom callbacks.
% 

%   Author(s): R. Malladi
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.9 $  $Date: 2002/11/21 15:35:16 $ 

% "Export" the handles to all local functions via a structure.
% The caller will get this, and grab the handles they need.
% This will allow callers to gain direct access to local functions.

if nargin > 1
    Tag = varargin{1};
    clickedObj = findall(hFig,'tag',Tag,'type','uitoggletool');
    zoom_clickedcb(clickedObj,[],hFig);
else
    fcns.zoom_clickedcb = {@zoom_clickedcb, hFig};
end

%-------------------------------------------------------------------------
function zoom_clickedcb(hcbo, eventStruct, hFig)
%ZOOM_CLICKEDCB 
% Callback for both the "Zoom" toolbar buttons and the "Zoom" menus
%
%  Create the mousezoom object when any of the zoom buttons or the zoom 
%  menus are clicked. This is done to avoid object instantiation
%  at startup (which would slow down the rendering of the GUI).
%

hZoom = createsignalzoom(hFig, hcbo);

% Set the zoom state of the object/figure.
setzoomstate(hZoom,hcbo);

if strcmpi(get(hcbo, 'tag'), 'fullview');
    zoom2fullview(hZoom);
end

% Set the 'OnCallback' of the scribe toolbar buttons to keep the zoom
% buttons in sync with the scribe buttons.
sToolBtn = findall(hFig,'Tag','ScribeToolBtn');
sSelToolBtn = findall(hFig,'Tag','ScribeSelectToolBtn');
set([sToolBtn(:); sSelToolBtn], 'OnCallBack', {@lclsetzoomstate, hZoom});


%--------------------------------------------------------------------------
function lclsetzoomstate(h, e, hZoom)
%LCLSETZOOMSTATE Call the setzoomstate method of the object to uncheck the
%                zoom buttons and menus when scribe buttons are checked.
% 
if strcmpi(hZoom.zoomState,'none')
    return;
end

set(hZoom,'zoomState', 'none');

% To uncheck the zoom buttons, setzoomstate is called with two inputs. The
% second input should be a valid handle. Hence the figure handle is passed.
setzoomstate(hZoom, hZoom.FigureHandle);

% [EOF]
