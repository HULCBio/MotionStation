function tornado_callback_handler (varargin)
% TORNADO_CALLBACK_HANDLER - RTW GUI Tornado callback handler
%
%       Copyright 1994-2003 The MathWorks, Inc.
%       $Revision: 1.2.2.3 $

if (nargin == 0)
  dialogFig = get (gcbo, 'Parent');
else
  dialogFig = varargin{1};
end

%
% Get the object handles for these mutually exclusive dialog options.
%
ExtMode = findobj (dialogFig, 'Tag', 'External mode_CheckboxTag');
Smode   = findobj (dialogFig, 'Tag', 'StethoScope_CheckboxTag');

%
% The external mode controls should only be enabled when the
% external mode checkbox has been set.
%
ExtModeTransport  = findobj(dialogFig,'Tag','Transport_PopupFieldTag');
ExtModeStatic     = findobj(dialogFig,'Tag','Static memory allocation_CheckboxTag');
ExtModeStaticSize = findobj(dialogFig,'Tag','Static memory buffer size_EditFieldTag');

val = get(ExtMode,'Value');
if val == 1;
  set(ExtModeTransport,  'Enable', 'on');
  set(ExtModeStatic,     'Enable', 'on');

  valStatic = get(ExtModeStatic,'Value');
  if valStatic == 1;
    valStatic='on';
  else;
    valStatic='off';
  end;
  set(ExtModeStaticSize, 'Enable', valStatic);
        
else;
  set(ExtModeTransport,  'Enable', 'off');
  set(ExtModeStatic,     'Enable', 'off');
  set(ExtModeStaticSize, 'Enable', 'off');
end;

if (isequal(get(ExtMode,'Value'),0))
  % If external mode is off, we don't care what Stethoscope's value is.
  return;
else
  % Else, ExtMode is on.
  if (gcbo == ExtMode)
    % If external mode was the one who called this function, that
    % means it was just turned on, which means we must make sure that
    % Stethoscope is off.
    set(Smode, 'Value', 0);
  else
    % It must be Stethoscope that called this function, which
    % means that it will now be on and we must shut off external mode.
    set(ExtMode, 'Value', 0);
    set(ExtModeTransport,  'Enable', 'off');
    set(ExtModeStatic,     'Enable', 'off');
    set(ExtModeStaticSize, 'Enable', 'off');
  end
end
  
  

