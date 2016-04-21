function  mobjects(action,newval)

%MOBJECTS  GUI for manipulating objects displayed on an axes
%
%  MOBJECTS allows interactive manipulating of object sets on the
%  current axes.  Each object set is defined as all objects with
%  identical tags.  If no tags are supplied, then the set is
%  defined by the object type.
%
%  MOBJECTS(hndl) associates the object set tool with the axes
%  specified by the input handle hndl.
%
%  See also MLAYERS

%  Copyright 1996-2003 The MathWorks, Inc.
%  $Revision: 1.13.4.1 $  $Date: 2003/08/01 18:19:01 $
%  Written by:  E. Byrns, E. Brown


if nargin == 0
     hndl = get(get(0,'CurrentFigure'),'CurrentAxes');
     action = 'initialize';
elseif ~isstr(action)
     hndl = action;     action = 'initialize';
end

%  Set the newval input if it is not provided.
%  The input newval is used only with the 'update' calls.

if nargin ~= 2;   newval = 1;   end


switch action
case 'initialize'          %  Initialize layer mod GUI
    if ~(length(hndl) == 1 & ishandle(hndl) & ...   %  Test for a
         strcmp(get(hndl,'type'),'axes') )          %  axes handle
            uiwait(errordlg('Valid axes handle required','Object Set Error','modal'))
				return
    end

    objects = get(hndl,'Children');          % Get the axes children
    if isempty(objects)
	     uiwait(errordlg('No objects on axes','Object Set Error','modal'))
		  return
	 end

%  Eliminate objects from list if their handles are hidden.

    hidden = get(objects,'HandleVisibility');
    indx = strmatch('callback',char(hidden));
    if ~isempty(indx);   objects(indx) = [];   end

    if ~isempty(objects)            %  Initialize layer mod box
        mobjectsbox(hndl);          %  if objects are present on
        mobjects('update')          %  the axes
    else
	    uiwait(errordlg('No objects on axes','Object Set Error','modal'))
    end
	set(gcf,'HandleVisibility','Callback')
	
case 'update'          %  Update the display with the list of current objects

    h = getGUIhandles;             %  Get handles
    if isempty(h);  return;  end   %  Axes gone, abort

    objects = get(h.axes,'Children');    % Get the axes children

%  Eliminate objects from list if their handles are hidden.

    hidden = get(objects,'HandleVisibility');
    indx = strmatch('callback',char(hidden));
    if ~isempty(indx);   objects(indx) = [];   end

%  Set the object list or exit if nothing is left
%  Ensure that the value index is within the range of names.
%  This test is necessary as users change (or clear) object tags,
%  the length of the name list may shorten.

    if ~isempty(objects)
        objnames = namem(objects);
		spacechar = ' ';
		[r,c] = size(objnames);
		objnames = [spacechar(ones(r,2)) objnames];
	    if isstr(newval)         newval = strmatch(newval,objnames,'exact');
		    elseif newval > 0;   newval = min(newval,size(objnames,1));
		end

        for i = 1:r
		    objstr = deblank(objnames(i,3:c+2));
			if isempty(objstr);   objstr = ' ';  end

			hndl = handlem(objstr,h.axes);
		    if strcmp(get(hndl(1),'Visible'),'on');   objnames(i,1) = '*';
				else;                                 objnames(i,1) = 'h';
			end
	    end

		set(h.list,'String',objnames,'Value',newval);  drawnow
		mobjects('object')
    else
        delete(get(0,'CurrentFigure'))
		  uiwait(errordlg('No objects on axes','Object Set Error','modal'))
    end

case 'object'          %  Update the Object String

    h = getGUIhandles;             %  Get handles
    if isempty(h);  return;  end   %  Axes gone, abort

    objnames = get(h.list,'String');        %  Determine object name
	indx     = get(h.list,'Value');         %  and handle (handle may
    object   = deblank(objnames(indx,:));   %  be a vector).
    object(1:min(2,length(object))) = [];

    if isempty(object)     %  Spaces used as tags (can happen when
	     object = ' ';     %  using mlayers to display objects)
	end

	if indx == 1      %  Activate the proper stacking order buttons
	    set([h.top;h.up],'Enable','off');  set([h.bottom;h.down],'Enable','on')
	elseif indx == size(objnames,1)
	    set([h.top;h.up],'Enable','on');   set([h.bottom;h.down],'Enable','off')
	else
	    set([h.top;h.up;h.bottom;h.down],'Enable','on')
	end

    [h.obj,msg] = handlem(object,h.axes);    %  Save handles for later use.

    if isempty(msg)    %  handle found the object

        hidden = get(h.obj,'HandleVisibility');
        hindx = strmatch('callback',char(hidden));
        if ~isempty(hindx);   h.obj(hindx) = [];   end

        set(h.fig,'UserData',h);
        set(get(h.axes,'Parent'),'CurrentObject',h.obj(1));  %  Make handle current
        highlightstate(h)
        if strcmp(get(h.obj(1),'Visible'),'on')      %  Set the hide
             set(h.hide,'String','Hide')             %  and show button
             objnames(indx,1) = '*';                 %  label
			 set(h.list,'String',objnames,'Value',indx)
		else
		     set(h.hide,'String','Show')
             objnames(indx,1) = 'h';
			 set(h.list,'String',objnames,'Value',indx)
	    end
    else
        uiwait(errordlg('Object has been deleted from axes',...
		                  'Object Set Warning','modal'))
		  mobjects('update')
    end

case 'hideshow'          %  Hide&Show button

    h = getGUIhandles;             %  Get handles
    if isempty(h);  return;  end   %  Axes gone, abort
	objnames = get(h.list,'String');
    indx = get(h.list,'Value');

    switch get(gco,'String')
       case 'Hide',   set(h.obj,'Visible','off')
	                  set(gco,'String','Show')
					  objnames(indx,1) = 'h';
					  set(h.list,'String',objnames,'Value',indx)
       case 'Show',   set(h.obj,'Visible','on')
	                  set(gco,'String','Hide')
					  objnames(indx,1) = '*';
					  set(h.list,'String',objnames,'Value',indx)
    end

case 'delete'          %  Delete button

    h = getGUIhandles;             %  Get handles
    if isempty(h);  return;  end   %  Axes gone, abort

%  Prompt to confirm object deletion

    quest = strvcat(['Delete Object:  ',namem(h.obj)],' ','Are You Sure?');
    ButtonName = questdlg(quest,'Confirm Deletion','Yes','No','No');

    if strcmp(ButtonName,'Yes')   %  Delete if confirmed
        delete(h.obj);            %  Delete object
	    mobjects('update')        %  Update the object list
    end

case 'emode'          %  Erase Mode button

    h = getGUIhandles;             %  Get handles
    if isempty(h);  return;  end   %  Axes gone, abort
    setemode(h.obj);     % Modal GUI for Erase Mode

case 'tag'          %  Tag button

    h = getGUIhandles;             %  Get handles
    if isempty(h);  return;  end   %  Axes gone, abort

    tagm(h.obj(1));      % Modal GUI for modifying the tag

    if length(h.obj) > 1                       %  Update all tags if h.obj
        set(h.obj,'Tag',get(h.obj(1),'Tag'))   %  is a vector.
    end

    mobjects('update',get(h.list,'Value'))    %  Update the object display

case 'zdata'          %  Zdata button
    h = getGUIhandles;             %  Get handles
    if isempty(h);  return;  end   %  Axes gone, abort
    zdatam(h.obj);      % Modal GUI for modifying the zdata

case 'property'          %  Property button
    h = getGUIhandles;             %  Get handles
    if isempty(h);  return;  end   %  Axes gone, abort

    str0 = '';   indx = 1;   %  Initialize variables

	while 1   %  Prompt for properties.  Remain until no errors or cancelled
	    hmodal = PropertyEditBox(h.obj,str0,indx);    uiwait(hmodal.figure);

       if ~ishandle(hmodal.figure);   return;   end

      str0 = get(hmodal.edit,'String');   %  Get the properties.  Make single row vector
		str0 = str0';   str0 = str0(:)';   str0 = str0(find(str0));

		hndlarray = get(hmodal.popup,'UserData');   %  Get other needed info
		indx = get(hmodal.popup,'Value');
		hndls = hndlarray{indx};         %  Objects to apply properties to
        btn   = get(hmodal.figure,'CurrentObject');

        delete(hmodal.figure)   %  Get rid of the modal window

        if  btn == hmodal.apply   %  Apply the properties
            lasterr('')
            eval(['set(hndls,',str0,');'],...
				     'uiwait(errordlg(lasterr,''Object Set Error'',''modal''))')
            if isempty(lasterr);   break;   end
		else
		    break
	    end
    end

case 'highlightON'          %  Highlight button
    h = getGUIhandles;             %  Get handles
    if isempty(h);  return;  end   %  Axes gone, abort

    set(h.obj,'Selected','on','SelectionHighlight','on')
    set(h.highlight,'String','Normal','CallBack','mobjects(''highlightOFF'')')

case 'highlightOFF'          %  Normal button
    h = getGUIhandles;             %  Get handles
    if isempty(h);  return;  end   %  Axes gone, abort

    set(h.obj,'Selected','on','SelectionHighlight','off')
    set(h.obj,'Selected','off')
    set(h.highlight,'String','Highlight','CallBack','mobjects(''highlightON'')')

case 'top'          %  Top button
    h = getGUIhandles;             %  Get handles
    if isempty(h);  return;  end   %  Axes gone, abort

%  Eliminate hidden handle children from the working array.  Append these
%  handles to the end of the list when done.

    children = get(h.axes,'children');
    hidden = get(children,'HandleVisibility');
    indx = strmatch('callback',char(hidden));
    if ~isempty(indx);   hiddenchild = children(indx);  children(indx) = [];
        else;            hiddenchild = [];
    end

    for i = 1:length(h.obj)
        indx = find(h.obj(i) == children);
        children(indx) = [];
    end

    set(h.axes,'children',[h.obj;children;hiddenchild])
    mobjects('update')

case 'up'          %  Up button
    h = getGUIhandles;             %  Get handles
    if isempty(h);  return;  end   %  Axes gone, abort

%  Eliminate hidden handle children from the working array.  Append these
%  handles to the end of the list when done.

    children = get(h.axes,'children');
    hidden = get(children,'HandleVisibility');
    indx = strmatch('callback',char(hidden));
    if ~isempty(indx);   hiddenchild = children(indx);  children(indx) = [];
        else;            hiddenchild = [];
    end

%  Get the list of the axes objects

    objnames = get(h.list,'String') ;       %  Reorder list elements
	indx     = get(h.list,'Value');
    newrows  = [1:indx-2 indx indx-1 indx+1:size(objnames,1)];
    newrows  = newrows(find(newrows));
	objnames = objnames(newrows,:);

%  Reorder the axes children based upon the new order of the object list

    newchildren = [];
    for i = 1:size(objnames,1)
	    object = deblank(objnames(i,:));
        object(1:min(2,length(object))) = [];
        if isempty(object);    object = ' ';    end
        [hndls,msg] = handlem(object,h.axes);

        hidden = get(hndls,'HandleVisibility');
        hindx = strmatch('callback',char(hidden));
        if ~isempty(hindx);   hndls(hindx) = [];   end

        newchildren = [newchildren; hndls];
    end

%  Update the display

    set(h.list,'String',objnames)
	set(h.axes,'children',[newchildren;hiddenchild])
    mobjects('update',['  ',namem(h.obj)])

case 'down'          %  Down button
    h = getGUIhandles;             %  Get handles
    if isempty(h);  return;  end   %  Axes gone, abort

%  Eliminate hidden handle children from the working array.  Append these
%  handles to the end of the list when done.

    children = get(h.axes,'children');
    hidden = get(children,'HandleVisibility');
    indx = strmatch('callback',char(hidden));
    if ~isempty(indx);   hiddenchild = children(indx);  children(indx) = [];
        else;            hiddenchild = [];
    end

%  Get the list of the axes objects

    objnames = get(h.list,'String');        %  Reorder list elements
	indx     = get(h.list,'Value');
    newrows  = [1:indx-1 indx+1 indx indx+2:size(objnames,1)];
    newrows  = newrows(find(newrows<=size(objnames,1)));
	objnames = objnames(newrows,:);

%  Reorder the axes children based upon the new order of the object list

    newchildren = [];
    for i = 1:size(objnames,1)
	    object = deblank(objnames(i,:));
        object(1:min(2,length(object))) = [];
        if isempty(object);    object = ' ';    end
        [hndls,msg] = handlem(object,h.axes);

        hidden = get(hndls,'HandleVisibility');
        hindx = strmatch('callback',char(hidden));
        if ~isempty(hindx);   hndls(hindx) = [];   end

        newchildren = [newchildren; hndls];
    end

%  Update the display

    set(h.list,'String',objnames)
	set(h.axes,'children',[newchildren;hiddenchild])
    mobjects('update',['  ',namem(h.obj)])

case 'bottom'          %  Bottom button
    h = getGUIhandles;             %  Get handles
    if isempty(h);  return;  end   %  Axes gone, abort

%  Eliminate hidden handle children from the working array.  Append these
%  handles to the end of the list when done.

    children = get(h.axes,'children');
    hidden = get(children,'HandleVisibility');
    indx = strmatch('callback',char(hidden));
    if ~isempty(indx);   hiddenchild = children(indx);  children(indx) = [];
        else;            hiddenchild = [];
    end

    for i = 1:length(h.obj)
        indx = find(h.obj(i) == children);
        children(indx) = [];
    end

    set(h.axes,'children',[children; h.obj; hiddenchild])
    mobjects('update',length([children; h.obj]))

case 'close'          %  Close Request function
    h = get(get(0,'CurrentFigure'),'UserData');  %  Get GUI handles
    if ishandle(h.axes)
	    prompt = strvcat(['Close:  ',get(get(0,'CurrentFigure'),'Name')],' ',...
		                  'Are You Sure?');
        ButtonName = questdlg(prompt,'Confirm Closing','Yes','No','No');
        if strcmp(ButtonName,'Yes')
		     delete(get(0,'CurrentFigure'))
			 figure(get(h.axes,'Parent'))
		end
    else
        delete(h.fig);
    end
end


%*********************************************************************
%*********************************************************************
%*********************************************************************


function h = mobjectsbox(hndl)

%  MLAYERSBOX  Displays the MLAYERS GUI.


%  Compute the Pixel and Font Scaling Factors so
%  GUI figure windows and fonts look OK across all platforms

PixelFactor = guifactm('pixels');
FontScaling =  guifactm('fonts');

%  Create the figure window

h.fig = figure('Name','Object Sets', 'NumberTitle','off',...
           'IntegerHandle','on', 'Resize','on',...
           'Units','Points',  'Position',PixelFactor*72*[0.01 1.0 2.2 3.4],...
		   'Tag','ObjectTool',...
		   'CloseRequestFcn','mobjects(''close'')', 'Visible','off');
colordef(h.fig,'white');
figclr = get(h.fig,'Color');

% shift window if it comes up partly offscreen

shiftwin(h.fig)

%  Create the list box

h.list = uicontrol(h.fig,'Style','List', 'String','place holder',...
	        'Units','Normalized', 'Position',[0.10  0.55  0.80  0.40], ...
			'Max',1, 'Value',1,...
			'FontWeight','normal',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment','center', ...
			'ForegroundColor','black', 'BackgroundColor',figclr,...
			'CallBack','mobjects(''object'')');

%  Hide/Show button

h.hide = uicontrol(h.fig,'Style','Push', 'String','Hide', ...
	        'Units', 'Normalized', 'Position', [0.10  0.43  0.40  0.08], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment','center',...
			'ForegroundColor','black', 'BackgroundColor',figclr,...
			'CallBack','mobjects(''hideshow'')');

%  Delete button

h.delete = uicontrol(h.fig,'Style','Push', 'String','Delete', ...
	        'Units', 'Normalized', 'Position', [0.50  0.43  0.40  0.08], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment','center',...
			'ForegroundColor','black', 'BackgroundColor',figclr,...
			'Interruptible','on',...
			'CallBack','mobjects(''delete'')');

%  Zdata button

h.zdata = uicontrol(h.fig,'Style','Push', 'String','Zdata', ...
	        'Units', 'Normalized', 'Position', [0.10  0.35  0.40  0.08], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment','center',...
			'ForegroundColor','black', 'BackgroundColor',figclr,...
			'Interruptible','on',...
			'CallBack','mobjects(''zdata'')');

%  Erase Mode button

h.emode = uicontrol(h.fig,'Style','Push', 'String','Emode', ...
	        'Units', 'Normalized', 'Position', [0.50  0.35  0.40  0.08], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment','center',...
			'ForegroundColor','black', 'BackgroundColor',figclr,...
			'CallBack','mobjects(''emode'')');

%  Highlight button

h.highlight = uicontrol(h.fig,'Style','Push', 'String','Highlight', ...
	        'Units', 'Normalized', 'Position', [0.10  0.27  0.40  0.08], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment','center',...
			'ForegroundColor','black', 'BackgroundColor',figclr,...
			'CallBack','mobjects(''highlightON'')');

%  Property button

h.property = uicontrol(h.fig,'Style','Push', 'String','Property', ...
	        'Units', 'Normalized', 'Position', [0.50  0.27  0.40  0.08], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment','center',...
			'ForegroundColor','black', 'BackgroundColor',figclr,...
			'CallBack','mobjects(''property'')');

%  Tag button

h.tag = uicontrol(h.fig,'Style','Push', 'String','Tag', ...
	        'Units', 'Normalized', 'Position', [0.10  0.19  0.40  0.08], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment','center',...
			'ForegroundColor','black', 'BackgroundColor',figclr,...
			'Interruptible','on',...
			'CallBack','mobjects(''tag'')');

%  Update button

h.update = uicontrol(h.fig,'Style','Push', 'String','Update', ...
	        'Units', 'Normalized', 'Position', [0.50  0.19  0.40  0.08], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment','center',...
			'ForegroundColor','black', 'BackgroundColor',figclr,...
			'CallBack','mobjects(''update'')');

%  Stacking Order Text and Buttons

h.stcktext = uicontrol(h.fig,'Style','text', 'String','Stacking Order', ...
	        'Units', 'Normalized', 'Position', [0.10  0.115  0.80  0.06], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment','center',...
			'ForegroundColor','black', 'BackgroundColor',figclr);

h.top = uicontrol(h.fig,'Style','Push', 'String','Top', ...
	        'Units', 'Normalized', 'Position', [0.10  0.03  0.20  0.08], ...
			'FontWeight','bold',  'FontSize',FontScaling*9, ...
			'HorizontalAlignment','center',...
			'ForegroundColor','black', 'BackgroundColor',figclr,...
			'CallBack','mobjects(''top'')');

h.up = uicontrol(h.fig,'Style','Push', 'String','Up', ...
	        'Units', 'Normalized', 'Position', [0.30  0.03  0.20  0.08], ...
			'FontWeight','bold',  'FontSize',FontScaling*9, ...
			'HorizontalAlignment','center',...
			'ForegroundColor','black', 'BackgroundColor',figclr,...
			'CallBack','mobjects(''up'')');

h.down = uicontrol(h.fig,'Style','Push', 'String','Dwn', ...
	        'Units', 'Normalized', 'Position', [0.50  0.03  0.20  0.08], ...
			'FontWeight','bold',  'FontSize',FontScaling*9, ...
			'HorizontalAlignment','center',...
			'ForegroundColor','black', 'BackgroundColor',figclr,...
			'CallBack','mobjects(''down'')');

h.bottom = uicontrol(h.fig,'Style','Push', 'String','Btm', ...
	        'Units', 'Normalized', 'Position', [0.70  0.03  0.20  0.08], ...
			'FontWeight','bold',  'FontSize',FontScaling*9, ...
			'HorizontalAlignment','center',...
			'ForegroundColor','black', 'BackgroundColor',figclr,...
			'CallBack','mobjects(''bottom'')');

%  Save the axes handle and all handles for this GUI

h.axes = hndl;
set(h.fig,'UserData',h,'Visible','on')


%*********************************************************************
%*********************************************************************
%*********************************************************************


function setemode(objects)

%SETEMODE  Dialog GUI to set an objects erase mode
%
%  SETEMODE will allow the user to change the erase modes of
%  objects on an axes.  This is called from MLAYERS and is
%  slightly different from the setemode local to mobjects.


if nargin ~= 1;   error('Incorrect number of arguments');  end

%  Determine the current erase mode for the object

emodestring = strvcat('normal','none','xor','background');
indx = strmatch(get(objects(1),'EraseMode'),emodestring);

%  Compute the Pixel and Font Scaling Factors so
%  GUI figure windows and fonts look OK across all platforms

PixelFactor = guifactm('pixels');
FontScaling =  guifactm('fonts');

h = dialog('Name','Object Erase Mode',...
           'Units','Points',  'Position',PixelFactor*72*[2 2 2.2 2.5],...
		   'Visible','off');
colordef(h,'white');
figclr = get(h,'Color');


% shift window if it comes up partly offscreen

shiftwin(h)

%  Place objects in the dialog box

uicontrol(h,'Style','Text', 'String','Define Erase Mode', ...
              'Units','Normalized', 'Position',[0.10  0.85  0.80  0.10], ...
			  'HorizontalAlignment','center', ...
 			  'FontWeight','bold',  'FontSize',FontScaling*10, ...
			  'ForegroundColor','black', 'BackgroundColor',figclr);


for i = 1:size(emodestring,1)
	 r(i) = uicontrol(h,'Style','Radio', 'String',deblank(emodestring(i,:)), ...
              'Units','Normalized', 'Position',[.1 .83-0.13*i .8 .1], ...
			  'HorizontalAlignment','left', 'Value',0, ...
 			  'FontWeight','bold',  'FontSize',FontScaling*10, ...
			  'ForegroundColor','black', 'BackgroundColor',figclr);
     if indx == i;  set(r(i),'Value',1);  end
end

%  Set the user data to make radio buttons mutually exclusive

for i = 1:size(emodestring,1)
     userdata = r;  userdata(i) = [];   set(r(i),'UserData',userdata);
end

%  Set the radio button callback string

set(r,'CallBack','set(gco,''Value'',1);set(get(gco,''UserData''),''Value'',0);clear ans');

%  Push Buttons with uiresume command

uicontrol(h,'Style','Push', 'String', 'Apply', ...    %  Apply Button
	        'Units','Normalized', 'Position',[.06 .05 .40 .18], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment','center', ...
			'ForegroundColor','black', 'BackgroundColor',figclr,...
			'CallBack','uiresume');

uicontrol(h,'Style','Push', 'String', 'Cancel', ...    %  Cancel Button
	        'Units','Normalized', 'Position',[.54 .05 .40 .18], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment','center', ...
			'ForegroundColor','black', 'BackgroundColor',figclr,...
			'CallBack','uiresume');

%  Turn dialog box on.  Then wait unit a button is pushed

set(h,'Visible','on');     uiwait(h)

if ~ishandle(h);   return;   end

%  Set the erase mode if the apply button is pressed

if strcmp(get(get(h,'CurrentObject'),'String'),'Apply')
    emode = get(findobj(h,'Type','uicontrol','Value',1),'String');
	set(objects,'EraseMode',emode)
end

%  Close the dialog box

delete(h)




%*********************************************************************
%*********************************************************************
%*********************************************************************


function highlightstate(h)

%  HIGHLIGHTSTATE sets the highlight button to correspond with the
%  objects current highlight state


highlight = get(h.obj(1),'SelectionHighlight');
selected = get(h.obj(1),'Selected');

if strcmp(highlight,'yes') & strcmp(selected,'on')
    set(h.highlight,'String','Normal','CallBack','mobjects(''highlightOFF'')')
else
    set(h.highlight,'String','Highlight','CallBack','mobjects(''highlightON'')')
end


%*********************************************************************
%*********************************************************************
%*********************************************************************


function h = getGUIhandles

%  GETGUIHANDLES  Gets the handles associated with the mobject GUI and
%  also test to ensure that the associated axes still exists.


fighndl = get(0,'CurrentFigure');

%  May have clicked out of tool while callbacks are processing.
%  The user clicks to the map window while drawing during a stacking
%  order change (where this problem calls), which is processed before
%  another internal call to mobjects gets executed.  In this
%  case, the current figure is messed up and this is a recovery attempt.
%  This recovery won't work is multiple object tools are up.

if ~strcmp(get(fighndl,'Tag'),'ObjectTool')
      fighndl = findobj(0,'Type','figure','Tag','ObjectTool');
end

h = get(fighndl,'UserData');  %  Get GUI handles


if ~ishandle(h.axes)     %  Abort tool if axes is gone
    uiwait(errordlg({'Associated Map Axes has been deleted',' ',...
					      'Object Tool No Longer Appropriate'},...
						   'Object Set Error','modal'));
    delete(h.fig);
	h = [];
end


%*********************************************************************
%*********************************************************************
%*********************************************************************


function h = PropertyEditBox(hndls,str0,indx)

%  PROPERTYEDITBOX will construct the modal dialog allowing the
%  specification of properties for all objects referenced by hndls.


%  Initialize variables

deleterow = [];
objstr = strvcat('All','Line','Patch','Surface','Text','Light');

%  Get the types of objects referenced by hndls

hndlarray{1} = hndls;
if length(hndls) == 1;     objtypes = get(hndls,'Type');
   else;                   objtypes = char(get(hndls,'Type'));
end

%  Determine the object types contained in hndls.  Keep only
%  these objects in the popup menu string.  Save the corresponding
%  subset of handles

for i = 2:size(objstr,1)
    indxmatch = strmatch(lower(deblank(objstr(i,:))),objtypes);
	if ~isempty(indxmatch);    hndlarray{length(hndlarray)+1} = hndls(indxmatch);
	    else;                  deleterow = [deleterow; i];
    end
end

%  Clear the unnecessary rows of the popup menu string.  If only
%  two rows remain ("All" will always remain), then the objects in
%  hndls are all alike.  In this case, get rid of the all option
%  and make the popup menu into a text object (done later).

if ~isempty(deleterow);     objstr(deleterow,:) = [];    end
if length(hndlarray) == 2;  hndlarray(1) = [];      objstr(1,:) = [];  end

%  Compute the Pixel and Font Scaling Factors so
%  GUI figure windows and fonts look OK across all platforms

PixelFactor = guifactm('pixels');
FontScaling =  guifactm('fonts');

%  Create the dialog window

h.figure = dialog('Name','Define Object Properties', ...
                  'Units','Points',  'Position',PixelFactor*72*[1 1 3.5 2.5], ...
				  'Visible','on');
colordef(h.figure,'white');
figclr = get(h.figure,'Color');

% shift window if it comes up partly offscreen

shiftwin(h.figure)


%  Object type and popup (or text) box

h.popuplabel = uicontrol(h.figure, 'Style','text', 'String','Object Type:',...
            'Units','normalized', 'Position',[.05 .84 .40 .10], ...
	        'BackgroundColor',figclr, 'ForegroundColor','black', ...
	        'FontSize',FontScaling*10,  'FontWeight','bold', 'HorizontalAlignment','left');

h.popup = uicontrol(h.figure, 'Style','popup', 'String',objstr,...
            'Units','normalized', 'Position',[.48 .85 .47 .10], ...
	        'BackgroundColor',figclr, 'ForegroundColor','black', ...
			'HorizontalAlignment','left', 'Value',indx,...
	        'FontSize',FontScaling*10,  'FontWeight','bold', ...
			'UserData', hndlarray);
if length(hndlarray) == 1
      set(h.popup,'Style','text','Position',[.48 .84 .47 .10])
end

%  Object Property label and edit box

h.editlabel = uicontrol(h.figure, 'Style','text', ...
            'String','Object Properties (eg: ''Color'',''blue''):',...
            'Units','normalized', 'Position',[.05 .70 .90 .10], ...
	        'BackgroundColor',figclr, 'ForegroundColor','black', ...
	        'FontSize',FontScaling*10,  'FontWeight','bold', 'HorizontalAlignment','left');

h.edit = uicontrol(h.figure, 'Style','edit', 'String',str0,...
            'Units','normalized', 'Position',[.05 .33 .90 .32], ...
	        'BackgroundColor',figclr, 'ForegroundColor','black', 'Max',2,...
	        'FontSize',FontScaling*10,  'FontWeight','bold', 'HorizontalAlignment','left');

%  Apply, help and cancel buttons

h.apply = uicontrol(h.figure, 'Style','push', 'String', 'Apply', ...
	'Units','normalized', 'Position',[0.15 0.05 0.25 0.20], ...
	'BackgroundColor',figclr, 'ForegroundColor','black', ...
	'FontSize',FontScaling*10,  'FontWeight','bold',...
	'Callback', 'uiresume');

h.cancel = uicontrol(h.figure, 'Style','push', 'String', 'Cancel', ...
	'Units','normalized', 'Position',[0.60 0.05 0.25 0.20], ...
	'BackgroundColor',figclr, 'ForegroundColor','black', ...
	'FontSize',FontScaling*10,  'FontWeight','bold', ...
	'Callback', 'uiresume');

%  Turn dialog on and save object handles

set(h.figure,'Visible','on','UserData',h)

