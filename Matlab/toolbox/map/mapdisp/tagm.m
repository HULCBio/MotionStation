function msg = tagm(hndl,tagstr)

%TAGM  Sets the name (tag property) for graphics objects
%
%  TAGM displays a Graphical User Interface for selecting an object
%  from the current axes and modifying its tag.
%
%  TAGM(h) displays a Graphical User Interface to modify the tag of
%  the object(s) specified by the input handles h.  If a vector is
%  supplied, all objects will be given the same tag.
%
%  TAGM(h,'str') sets the tag of the objects specified by the handles h
%  to the input string str.  If 'str' is a string matrix, it must
%  have the same rows as the number of entries in h.
%
%  msg = TAGM(...)   returns a string msg indicating any error
%  encountered.
%
%  See also CLMO, HIDE, SHOWM, NAMEM, HANDLEM

%  Copyright 1996-2003 The MathWorks, Inc.
%  Written by:  E. Byrns, E. Brown
%  $Revision: 1.10.4.1 $  $Date: 2003/08/01 18:22:56 $

%  Test inputs

if nargin == 0
     hndl = handlem('taglist');
     if isempty(hndl);   return;   end
     [tagstr,cancelled] = PromptForTag(hndl);
     if cancelled;   return;   end

elseif nargin == 1
     [tagstr,cancelled] = PromptForTag(hndl);
     if cancelled;   return;   end
end

%  Initialize outputs

if nargout ~= 0;  msg = [];   end

%  Enforce a vector input

hndl = hndl(:);

%  Allow for single tag string and multiple handles

if size(tagstr,1) == 1;   tagstr = tagstr(ones([length(hndl) 1]),:);   end

%  Input tests

if isstr(hndl)
    msg = 'Vector of handles required';
	if nargout < 1;  error(msg);   end
	return
elseif any(~ishandle(hndl))
    msg = 'Vector of handles required';
	if nargout < 1;  error(msg);   end
	return
elseif ~isempty(tagstr) & ~isstr(tagstr)
    msg = 'Tag strings required';
	if nargout < 1;  error(msg);   end
	return
elseif ~isempty(tagstr) & length(hndl) ~= size(tagstr,1)
    msg = 'Inconsistent number of handles and tags';
	if nargout < 1;  error(msg);   end
	return
end

%  Set the tag properties

for i = 1:length(hndl)
    if isempty(tagstr);     set(hndl(i),'Tag','');
        else;               set(hndl(i),'Tag',tagstr(i,:));
    end
end


%*********************************************************************
%*********************************************************************
%*********************************************************************


function [str,cancelled] = PromptForTag(hndl)

%  PROMPTFORTAG will produce a modal dialog box which
%  allows the user to edit an object tag.


str = [];   cancelled = 1;   %  Initialize the outputs

%  Compute the Pixel and Font Scaling Factors so
%  GUI figure windows and fonts look OK across all platforms

PixelFactor = guifactm('pixels');
FontScaling =  guifactm('fonts');

%  Create the dialog box.  Make visible when all objects are drawn

h.fig = dialog('Name','Edit Tag',...
           'Units','Points',  'Position',PixelFactor*72*[2 1 3 1.5],...
		   'Visible','off');
colordef(h.fig,'white');
figclr = get(h.fig,'Color');


%  Object Name and Tag

h.title = uicontrol(h.fig,'Style','Text','String','Enter New Tag String:', ...
            'Units','Normalized','Position', [0.05  0.80  0.90  0.15], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'left', ...
			'ForegroundColor', 'black','BackgroundColor', figclr);

%  Tag Edit Box

h.edit = uicontrol(h.fig,'Style','Edit','String', get(hndl(1),'Tag'), ...
            'Units','Normalized','Position', [0.05  .53  0.90  0.19], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'left', 'Max',1,...
			'ForegroundColor', 'black','BackgroundColor', figclr);


%  Buttons to exit the modal dialog

h.apply = uicontrol(h.fig,'Style','Push','String', 'Apply', ...
	        'Units','Points',  'Position',PixelFactor*72*[0.30  0.10  1.05  0.40], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'center', ...
			'ForegroundColor', 'black', 'BackgroundColor', figclr,...
			'CallBack','uiresume');


h.cancel = uicontrol(h.fig,'Style','Push','String', 'Cancel', ...
	        'Units','Points',  'Position',PixelFactor*72*[1.65  0.10  1.05  0.40], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'center', ...
			'ForegroundColor', 'black','BackgroundColor', figclr,...
			'CallBack','uiresume');


%  Turn dialog box on.  Then wait unit a button is pushed

set(h.fig,'Visible','on');     uiwait(h.fig)

if ~ishandle(h.fig);   return;   end

%  If the accept button has been pushed, then
%  first determine if the object edit box has a string in
%  it.  If it does not, then get the name from the
%  popup menu with the name list.  Finally, check
%  to see if the all match option is selected.  If so,
%  append 'all' to the string.

if get(h.fig,'CurrentObject') == h.apply
		str = get(h.edit,'String');   cancelled = 0;
end

%  Close the dialog box

delete(h.fig)
