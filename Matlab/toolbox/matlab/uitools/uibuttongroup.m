function h = uibuttongroup(varargin)

% Copyright 2003 The MathWorks, Inc.

% UIBUTTONGROUP Component to exclusively manage radiobuttons/togglebuttons.
%
% UIBUTTONGROUP('PropertyName1, Value1, 'PropertyName2', Value2, ...)
% creates a visible group component in the current figure window. This
% component is capable of managing exclusive selection behavior for
% uicontrols of style 'Radiobutton' and 'Togglebutton'. Other styles of
% uicontrols may be added to the UIBUTTONGROUP, but they will not be
% managed by the component.
%
% HANDLE = UIBUTTONGROUP(...)
% creates a group component and returns a handle to it in HANDLE.
%
% Run GET(HANDLE) to see a list of properties and their current values.
% Execute SET(HANDLE) to see a list of object properties and their legal
% values. See the reference guide for detailed property information.
%

h = uitools.uibuttongroup(varargin{:});
h = double(h);
