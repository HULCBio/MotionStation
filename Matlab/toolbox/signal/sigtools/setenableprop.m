function setenableprop(h,enableState,update)
%SETENABLEPROP Sets the enable property of uicontrols while maintaining the 
%              correct background color.
% Inputs:
%   h           - handle to uicontrol to enable/disable.
%   enableState - enable property value: 'on' or 'off'.
%   update      - boolean flag.  when true, DRAWNOW will be called.  true
%                 by default
%
%   If uistyle is not specified.  This function will determine which control is
%   being set and take the appropriate action.  If a vector of handles is passed
%   in with no uistyle specified, the appropriate action will be taken for each
%   of the controls.
%
% Outputs:
%   none

%   Author(s): P. Pacheco
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.11.4.3 $  $Date: 2004/04/13 00:32:47 $ 

error(nargchk(2,3,nargin));

if isempty(h), return; end

% Background colors.
enabledColor = 'White';
disabledColor = get(0,'defaultUicontrolBackgroundColor');

if strcmp(lower(enableState),'on'), bgColor = enabledColor;
else                                bgColor = disabledColor;
end

for indx = 1:length(h),

    % If the object is not a uicontrol, do not change it's backgroundcolor
    if isprop(h(indx), 'Style'), uistyle = get(h(indx), 'Style');
    else,                        uistyle = 'nostyle'; end

    switch uistyle
    case {'edit','popupmenu','listbox'}
        set(h(indx), 'Enable', enableState, 'Background', bgColor);
        
    otherwise  % In case someone uses this function for other uis.
        set(h(indx), 'Enable', enableState);
    end
end

if nargin == 2 | update, drawnow; end

% [EOF] setenableprop.m
