function [hDatatip] = createDatatip(hThis,hTarget)

% Copyright 2003 The MathWorks, Inc.

if(hThis.Debug)
  disp('createDatatip')
end

if strcmpi(get(hThis,'SnapToDataVertex'),'on')
   interp_on = 'off';
else
   interp_on = 'on';
end

% Get behavior object from target
hBehavior = hggetbehavior(hTarget,'DataCursor','-peek');

% Call datatip constructor
% Setting 'ZStackMinimum' property at constructor time avoids
% an additional call to 'movetofront' method.
if get(hThis,'EnableZStacking')
   hDatatip = graphics.datatip(hTarget,...
                        'Interpolate',interp_on,...
                        'EnableZStacking',true,...
                        'ZStackMinimum',get(hThis,'ZStackMinimum'));
else  
   hDatatip = graphics.datatip(hTarget,'Interpolate',interp_on);
end

set(hDatatip,'EnableAxesStacking',get(hThis,'EnableAxesStacking'));

% Make datatip visible 
set(hDatatip,'Visible','on');

% Add to vector
set(hThis,'DataCursors',[hDatatip; get(hThis,'DataCursors')]);

% Make current
set(hThis,'CurrentDataCursor',hDatatip);

% Add deletion listener
hListener = handle.listener(hDatatip,...
                    'ObjectBeingDestroyed', ...
                    {@localDeleteDatatip,hDatatip,hThis});
addlistener(hDatatip,hListener);

% UpdateFcn is documented to return an empty first argument
set(hDatatip,'EmptyArgUpdateFcn',get(hThis,'UpdateFcn'));
   
% HiddenUpdateFcn (internal use only) takes precedence
set(hDatatip,'UpdateFcn',get(hThis,'HiddenUpdateFcn'));

set(hThis,'NewDataCursor',false);

% Throw CreateFcn event to behavior object
fcn = get(hBehavior,'CreateFcn');
if ~isempty(fcn)
   hgfeval(fcn,hDatatip,[]);
end

%---------------------------------------------%
function localDeleteDatatip(obj,evd,hDatatip,hTool)

% Delete datatip
removeDataCursor(hTool,hDatatip);
