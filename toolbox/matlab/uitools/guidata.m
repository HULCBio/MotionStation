function data = guidata(h, data_in)
%GUIDATA Store or retrieve application data.
%   GUIDATA(H, DATA) stores the specified data in the figure's
%   application data.
%
%   H is a handle that identifies the figure - it can be the figure
%   itself, or any object contained in the figure.
%
%   DATA can be anything an application wishes to store for later
%   retrieval.
%
%   DATA = GUIDATA(H) returns previously stored data, or an empty
%   matrix if nothing was previously stored.
%
%   GUIDATA provides application authors with a convenient interface
%   to a figure's application data. You can access the data from a
%   callback subfunction using the component's handle, without needing
%   to find the figure's handle.  You can also avoid having to create
%   and maintain a hardcoded property name for the application data
%   throughout your source code.  GUIDATA is particularly useful in
%   conjunction with GUIHANDLES, which returns a structure containing
%   handles of all the components in a GUI listed by tag.
%
%   Example:
%
%   Suppose an application creates a figure with handle F, containing
%   a slider and an editable text uicontrol whose tags are
%   'valueSlider' and 'valueEdit' respectively.  The following
%   excerpts from the application's M-file illustrate the use of
%   GUIDATA to access a structure containing handles returned by
%   GUIHANDLES, plus additional application-specific data added during
%   initialization and callbacks:
%
%   ... excerpt from the GUI setup code ...
%
%   f = openfig('mygui.fig');
%   data = guihandles(f); % initialize it to contain handles
%   data.errorString = 'Total number of mistakes: ';
%   data.numberOfErrors = 0;
%   guidata(f, data);  % store the structure
%
%   ... excerpt from the slider's callback ...
%
%   data = guidata(gcbo); % get the struct, use the handles:
%   set(data.valueEdit, 'String',...
%       num2str(get(data.valueSlider, 'Value')));
%
%   ... excerpt from the edit's callback ...
%
%   data = guidata(gcbo); % need handles, may need error info
%   val = str2double(get(data.valueEdit,'String'));
%   if isnumeric(val) & length(val)==1 & ...
%      val >= get(data.valueSlider, 'Min') & ...
%      val <= get(data.valueSlider, 'Max')
%     set(data.valueSlider, 'Value', val);
%   else
%     % increment the error count, and display it
%     data.numberOfErrors = data.numberOfErrors + 1;
%     set(handles.valueEdit, 'String',...
%      [ data.errorString, num2str(data.numberOfErrors) ]);
%     guidata(gcbo, data); % store the changes...
%   end
%
%   Note that GUIDE generates callback functions to which a structure
%   of handles is passed automatically as an input argument.  This
%   eliminates the need to call "data = guidata(gcbo);" in callbacks
%   written using GUIDE, unlike the example above.
%
%  See also GUIHANDLES, GUIDE, OPENFIG, GETAPPDATA, SETAPPDATA.

%   Damian T. Packer 6-8-2000
%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.7 $  $Date: 2002/04/15 03:27:17 $

% choose a unique name for our application data property.
% This M-file should be the only place using it.
PROP_NAME = 'UsedByGUIData_m';

error(nargchk(1, 2, nargin));
if (nargin == 2)
  error(nargoutchk(0, 0, nargout));
end

fig = [];
if ishandle(h) & length(h) == 1
  fig = getParentFigure(h);
end
if isempty(fig)
  error('H must be the handle to a figure or figure descendent.');
end

if nargin == 1 % GET
  data = getappdata(fig, PROP_NAME);
else % (nargin == 2) SET
  setappdata(fig, PROP_NAME, data_in);
end


function fig = getParentFigure(fig)
% if the object is a figure or figure descendent, return the
% figure.  Otherwise return [].
while ~isempty(fig) & ~strcmp('figure', get(fig,'type'))
  fig = get(fig,'parent');
end
