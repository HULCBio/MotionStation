function updateDisplay(hThis,evd)
%UPDATEDISPLAY

% Copyright 2003 The MathWorks, Inc.

% debug(hThis,'@cursorbar\updateDisplay.m start updateDisplay')

hText = get(hThis,'DisplayHandle');

if strcmp(hThis.ShowText,'off') 
    if ~isempty(hText)
        delete(hText);
        hThis.DisplayHandle = [];
        % debug(hThis,'@cursorbar\updateDisplay.m ShowText is off, DisplayHandle is not empty, return early')
        return
    end
    % debug(hThis,'@cursorbar\updateDisplay.m ShowText is off, DisplayHandle is empty, return early')
    return    
end

hBehavior = hggetbehavior(hThis,'datacursor');

if ~isempty(hThis.UpdateFcn)
    % debug(hThis,'@cursorbar\updateDisplay.m call cursorbar''s UpdateFcn')
    feval(hThis.UpdateFcn,hThis);
elseif ~isempty(hBehavior)
    % debug(hThis,'@cursorbar\updateDisplay.m call behavior object''s UpdateFcn')
    feval(hBehavior.UpdateFcn,hThis);
elseif ismethod(hThis,'defaultUpdateFcn')
    % debug(hThis,'@cursorbar\updateDisplay.m call cursorbar''s defaultUpdateFcn')
    defaultUpdateFcn(hThis);
end

% debug(hThis,'@cursorbar\updateDisplay.m end updateDisplay')