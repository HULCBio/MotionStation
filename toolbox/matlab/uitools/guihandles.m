function handles = guihandles(h)
%GUIHANDLES Return a structure of handles.
%   HANDLES = GUIHANDLES(H) returns a structure containing handles of
%   objects in a figure, using their tags as fieldnames.  Objects
%   are excluded if their tags are empty, or are not legal variable
%   names.  If several objects have the same tag, that field in the
%   structure contains a vector of handles.  Objects with hidden
%   handles are included in the structure.
%
%   H is a handle that identifies the figure - it can be the figure
%   itself, or any object contained in the figure.
%
%   HANDLES = GUIHANDLES returns a structure of handles for the
%   current figure.
%
%   Example:
%
%   Suppose an application creates a figure with handle F, containing
%   a slider and an editable text uicontrol whose tags are 'valueSlider'
%   and 'valueEdit' respectively.  The following excerpts from the
%   application's M-file illustrate the use of GUIHANDLES in callbacks:
%
%   ... excerpt from the GUI setup code ...
%
%   f = figure;
%   uicontrol('Style','slider','Tag','valueSlider', ...);
%   uicontrol('Style','edit','Tag','valueEdit',...);
%
%   ... excerpt from the slider's callback ...
%
%   handles = guihandles(gcbo); % generate handles struct
%   set(handles.valueEdit, 'string',...
%       num2str(get(handles.valueSlider, 'value')));
%
%   ... excerpt from the edit's callback ...
%
%   handles = guihandles(gcbo);
%   val = str2double(get(handles.valueEdit,'String'));
%   if isnumeric(val) & length(val)==1 & ...
%      val >= get(handles.valueSlider, 'Min') & ...
%      val <= get(handles.valueSlider, 'Max')
%     % update the slider's value if the edit's value is OK:
%     set(handles.valueSlider, 'Value', val);
%   else
%     % flush the bad string out of the edit; replace with slider's
%     % current value:
%     set(handles.valueEdit, 'String',...
%       num2str(get(handles.valueSlider, 'Value')));
%   end
%
%   Note that in this example, the structure of handles is created
%   each time a callback executes.  See the GUIDATA help for an
%   example in which the structure is created only once, and cached
%   for subsequent use.
%
%  See also GUIDATA, GUIDE, OPENFIG.

%   Damian T. Packer 6-8-2000
%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.7.4.1 $  $Date: 2002/09/26 01:55:03 $

if nargin == 0 % use GCF
  fig = gcf;
else % nargin == 1: obtain a figure handle from H
  fig = [];
  if ishandle(h) & length(h) == 1
    fig = getParentFigure(h);
  end
  if isempty(fig)
    error('H must be the handle to a figure or figure descendent.');
  end
end

% the structure creation is handled in a subfunction:
handles = createHandles(fig);


function fig = getParentFigure(fig)
% if the object is a figure or figure descendent, return the
% figure.  Otherwise return [].
while ~isempty(fig) & ~strcmp('figure', get(fig,'type'))
  fig = get(fig,'parent');
end


function handles = createHandles(fig)
% Assemble a struct using all the legal tag names in the figure as
% fieldnames.  Each field contains the handles of the objects using
% that tag.
all_h = findall(fig);
handles = [];

% loop across all objects in figure, looking for legal tags:
for this_h = all_h'
  tag = get(this_h,'tag');
  if ~isempty(tag) & isvarname(tag) % can it be used as a fieldname?
    
    % if a field of this name already exists, get its contents
    if isfield(handles, tag)
      prev_h = handles.(tag);
    else
      prev_h = [];
    end

    % if this uicontrol is a proxy for external controls, replace it with
    % that control
    if isappdata(this_h, 'Control')
        control = getappdata(this_h, 'Control');
        this_h = control.Instance;
    end

    % append our handle to whatever was there before. If nothing
    % was there before, SETFIELD will create the field.
    handles.(tag) = [prev_h this_h];
  
  end % if legal tag
end % loop

