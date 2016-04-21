function  mlayers(varargin)

%MLAYERS  GUI for display layers of a geographic data structure
%
%  MLAYERS allows interactive display of Mapping Toolbox Geographic
%  Data Structures.  The data structure is either stored in a workspace
%  or provided as a cell array input to MLAYERS.
%
%  MLAYERS(Workspace) will search the data in Workspace.mat for layer
%  structures.  If found, these layers will be associated with the
%  current map axes.  The input Workspace must be a string.
%
%  MLAYERS(Workspace,hndl) will assign the layers in Workspace.mat to
%  the map axes specified by hndl.
%
%  MLAYERS(CellArray) will take the layers specified in CellArray and
%  associate them with the current map axes.  The CellArray must be n by 2.
%  Each row of the cell array represents a layer.  The first column
%  must contain the layer structure and the second column must contain
%  the name of the layer structure.
%
%  This CellArray can be prepared from structures in the current
%  workspace using ROOTLAYR. The calling sequence in this case would be
%  rootlayr;mlayers(ans)
%
%  MLAYERS(CellArray,hndl) will take the layers specified in CellArray
%  to the map axes specified by hndl.
%
%  For further details on creating a Geographic Data Structure, consult
%  the Mapping Toolbox User Guide.
%
%  See also ROOTLAYR, MOBJECTS, DISPLAYM, EXTRACTM

%  Copyright 1996-2003 The MathWorks, Inc.
%  $Revision: 1.13.4.1 $  $Date: 2003/08/01 18:19:00 $
%  Written by:  E. Byrns, E. Brown


%  Parse the inputs

if nargin == 0
     error('Incorrect number of inputs')

elseif nargin == 1
     workspace = varargin{1};
     hndl = get(get(0,'CurrentFigure'),'CurrentAxes');
     action = 'initialize';
     varargin(1)=[];

elseif nargin == 2
     if isstr(varargin{1}) | iscell(varargin{1})
		  workspace = varargin{1};    hndl = varargin{2};
		  action = 'initialize';      varargin(1:2)=[];
     elseif isempty(varargin{1})
		  action = varargin{2};      varargin(1:2)=[];
	 else
		  error('Incorrect number of inputs')
	 end
end

%  Programmers note:  The way mlayers works..........
%  Build up a userdata cell array which will save each structure
%  found in the workspace.  Each structure is saved in a cell array
%  so that the value of the list dialog uicontrol can be used to
%  recall the data for each layer.  The second column of the cell
%  array is used to store the plot state of that layer.
%  Plotstate = 0 indicates unplotted, 1 means shown, 2 means hidden.
%  The third column of the cell array is used to store the handles
%  to the objects displayed for that layer.  These handles may
%  not always all be valid since the user has many ways to delete
%  objects from an axes, not just using this GUI tool.

switch action
case 'initialize'          %  Initialize layer mod GUI
    if ~(length(hndl) == 1 & ismap(hndl))   %  Test for map axes
         error('Axis associated with mlayers is not a valid map axes')
    end

%  Get the structure variable names

    if iscell(workspace)  %  Variables inputed as a cell array
        if isempty(workspace)
            error('No structures in workspace')
		elseif size(workspace,2) ~= 2
			error('Input cell array must be n by 2')
		end

		indx = [];
		namearray = workspace(:,2);   workspace(:,2) = [];
	    for i = 1:length(workspace)   %  Keep only the structures
		    if ~isstruct(workspace{i});  indx = [indx; i];  end
		end
        workspace(indx) = [];   namearray(indx) = [];
		if ~isempty(workspace)     %  Initialize layer mod box
            userdata = cell(length(workspace),3);  %  Save each structure
			userdata(:,1) = workspace;   userdata(:,2) = {0};

	        h = mlayersbox(hndl,'Workspace');
			namearray = char(namearray);  %  Add spaces to name array
			spacechar = ' ';                  %  These spaces used for plot symbols
			spacechar = spacechar(ones([size(namearray,1) 2]));

            set(h.list,'String',[spacechar namearray],'Value',1,'UserData',userdata)
			mlayers([],'object')
        else
		    error('No structures in input cells')
		end

    else   %  Workspace name provided.  Load and test
	    eval(['load ',workspace],'error(lasterr)')
		vars = who;    indx = [];
		for i = 1:length(vars)      %  Keep only the structures in workspace
		    if eval(['~isstruct(',vars{i},')']);  indx = [indx; i];  end
		end
        vars(indx) = [];

	    if ~isempty(vars)     %  Initialize layer mod box
            userdata = cell(length(vars),3);  %  Save each structure
			for i = 1:length(vars);   userdata{i,1} = eval(vars{i});   end
			userdata(:,2) = {0};

			h = mlayersbox(hndl,workspace);
			vars = char(vars);  %  Add spaces to name array
			spacechar = ' ';        %  These spaces used for plot symbols
			spacechar = spacechar(ones([size(vars,1) 2]));
            set(h.list,'String',[spacechar vars],'Value',1,'UserData',userdata)
			mlayers([],'object')
        else
		    error(['No structures in workspace ',workspace])
		end
    end
	set(gcf,'HandleVisibility','Callback')


case 'object'          %  Update the Object String.  Callback for the list box
    h = getGUIhandles;             %  Get handles
    if isempty(h);  return;  end   %  Axes gone, abort
    indx     = get(h.list,'Value');          %  Get layer index
    userdata = get(h.list,'UserData');       %  and its structure data
    namelist = get(h.list,'String');

    switch userdata{indx,2}
    case 0
	    namelist(indx,1) = ' ';
        set(h.list,'String',namelist,'Value',indx)
        set(h.hide,'String','Plot','CallBack','mlayers([],''plot'')');
        set([h.zdata;h.emode;h.highlight;h.delete;h.property],'Enable','off')
		set(h.highlight,'String','Highlight','CallBack','mlayers([],''highlightON'')')
    case 1
	    namelist(indx,1) = '*';
        set(h.list,'String',namelist,'Value',indx)
		set(h.hide,'String','Hide','CallBack','mlayers([],''hide'')');
		set([h.zdata;h.emode;h.highlight;h.delete;h.property],'Enable','on')
		highlightstate(h)
    case 2
	    namelist(indx,1) = 'h';
        set(h.list,'String',namelist,'Value',indx)
        set(h.hide,'String','Show','CallBack','mlayers([],''show'')');
        set([h.zdata;h.emode;h.highlight;h.delete;h.property],'Enable','on')
        highlightstate(h)
    end

case 'plot'          %  Plot button
    h = getGUIhandles;             %  Get handles
    if isempty(h);  return;  end   %  Axes gone, abort
    indx     = get(h.list,'Value');          %  Get layer index
    userdata = get(h.list,'UserData');       %  and its structure data

    set(0,'CurrentFigure',get(h.axes,'Parent'))
	 set(get(0,'CurrentFigure'),'CurrentAxes',h.axes)

    datastruct = userdata{indx,1};

    lasterr('')
	 [h0,msg]=displaym(userdata{indx,1});

    if ~isempty(msg)
	     uiwait(errordlg(msg,'Layer Tool Plotting Error','modal'));  return
    end

    set(0,'CurrentFigure',h.fig)   % Return to the layer tool GUI

    userdata{indx,2} = 1;    %  Update the saved data structure
    userdata{indx,3} = h0;
    set(h.list,'UserData',userdata)
    mlayers([],'object');    %  Update the plot state

case 'hide'          %  Hide button
    h = getGUIhandles;             %  Get handles
    if isempty(h);  return;  end   %  Axes gone, abort
	indx     = get(h.list,'Value');          %  Get layer index
    userdata = get(h.list,'UserData');       %  and its structure data
    objects = validhandles(h);               %  Set valid object handles
    if isempty(objects);  return;  end       %  No objects remain on plot

    set(objects,'Visible','off');
    userdata{indx,2} = 2;
    set(h.list,'UserData',userdata)
    mlayers([],'object');

case 'show'          %  Show button
    h = getGUIhandles;             %  Get handles
    if isempty(h);  return;  end   %  Axes gone, abort
    indx     = get(h.list,'Value');          %  Get layer index
    userdata = get(h.list,'UserData');       %  and its structure data
    objects = validhandles(h);               %  Set valid object handles
    if isempty(objects);  return;  end       %  No objects remain on plot

    set(objects,'Visible','on');
	userdata{indx,2} = 1;
    set(h.list,'UserData',userdata)
	mlayers([],'object');

case 'delete'          %  Delete button
    h = getGUIhandles;             %  Get handles
    if isempty(h);  return;  end   %  Axes gone, abort
    indx     = get(h.list,'Value');          %  Get layer index
    userdata = get(h.list,'UserData');       %  and its structure data
    namelist = get(h.list,'String');
    objects = validhandles(h);               %  Set valid object handles
    if isempty(objects);  return;  end       %  No objects remain on plot

    layername = namelist(indx,:);        layername(1:2) = [];
    quest = strvcat(['Delete Layer:  ',layername],' ','Are You Sure?');
    ButtonName = questdlg(quest,'Confirm Deletion','Yes','No','No');

    if strcmp(ButtonName,'Yes')   %  Delete if confirmed
	    delete(objects)
		namelist(indx,1) = ' ';
		userdata{indx,2} = 0;
        set(h.list,'UserData',userdata,'String',namelist,'Value',indx)
		mlayers([],'object');
    end

case 'emode'          %  Erase Mode button
    h = getGUIhandles;             %  Get handles
    if isempty(h);  return;  end   %  Axes gone, abort
    objects = validhandles(h);               %  Set valid object handles
    if isempty(objects);  return;  end       %  No objects remain on plot

    setemode(objects);   % Modal GUI for Erase Mode

case 'zdata'          %  Zdata button
    h = getGUIhandles;             %  Get handles
    if isempty(h);  return;  end   %  Axes gone, abort
    objects = validhandles(h);              %  Set valid object handles
    if isempty(objects);  return;  end       %  No objects remain on plot

    savetag = get(objects(1),'Tag');         %  Set up the tag
    indx     = get(h.list,'Value');          %  so that zdata GUI
    liststr  = get(h.list,'String');         %  has reasonable string
    set(objects(1),'Tag',liststr(indx,3:size(liststr,2)))

    zdatam(objects);      % Modal GUI for modifying the zdata
    set(objects(1),'Tag',savetag)    %  Restore original tag

case 'highlightON'          %  Highlight button
    h = getGUIhandles;             %  Get handles
    if isempty(h);  return;  end   %  Axes gone, abort
    objects = validhandles(h);               %  Set valid object handles
    if isempty(objects);  return;  end       %  No objects remain on plot

    set(objects,'Selected','on','SelectionHighlight','on')
    set(h.highlight,'String','Normal','CallBack','mlayers([],''highlightOFF'')')

case 'highlightOFF'          %  Normal button
    h = getGUIhandles;             %  Get handles
    if isempty(h);  return;  end   %  Axes gone, abort
    objects = validhandles(h);               %  Set valid object handles
    if isempty(objects);  return;  end       %  No objects remain on plot

    set(objects,'Selected','on','SelectionHighlight','off')
    set(objects,'Selected','off')
    set(h.highlight,'String','Highlight','CallBack','mlayers([],''highlightON'')')

case 'purge'          %  Purge button
    h = getGUIhandles;             %  Get handles
    if isempty(h);  return;  end   %  Axes gone, abort
	indx     = get(h.list,'Value');          %  Get layer index
    userdata = get(h.list,'UserData');       %  and its structure data
    liststr  = get(h.list,'String');
    objects = validhandles(h);               %  Set valid object handles

    if ~isempty(objects)   % Purge data and mapped objects
	    quest = strvcat('Purge Layer Data and Map Objects',' ','Are You Sure?');
        ButtonName = questdlg(quest,'Confirm Purge','Yes','Data Only','No','No');

        if ~strcmp(ButtonName,'No')  %  Purge if confirmed
		    if strcmp(ButtonName,'Yes');  delete(objects);  end
			userdata(indx,:) = [];    liststr(indx,:) = [];
			if ~isempty(liststr)
			    set(h.list,'String',liststr,'Value',1,'UserData',userdata)
				mlayers([],'object')
			else
				uiwait(errordlg(['All layers purged from ',get(h.fig,'Name')],...
				                 'Layer Tool Warning','modal'))
				delete(h.fig)
			end
		end
    else        %  Purge layer data only
        quest = strvcat('Purge Layer Data',' ','Are You Sure?');
        ButtonName = questdlg(quest,'Confirm Purge','Yes','No','No');

        if strcmp(ButtonName,'Yes')   % Purge if confirmed
		    userdata(indx,:) = [];    liststr(indx,:) = [];
			if ~isempty(liststr)
			     set(h.list,'String',liststr,'Value',1,'UserData',userdata)
				 mlayers([],'object')
			else
			     uiwait(errordlg(['All layers purged from ',get(h.fig,'Name')],...
				                  'Layer Tool Warning','modal'))
				 delete(h.fig)
			end
	   end
    end

case 'members'          %  Member button
    h = getGUIhandles;             %  Get handles
    if isempty(h);  return;  end   %  Axes gone, abort
    indx     = get(h.list,'Value');          %  Get layer index
    userdata = get(h.list,'UserData');       %  and its structure data
    liststr  = get(h.list,'String');

    memberlist(liststr(indx,3:size(liststr,2)),userdata{indx,1})


case 'property'          %  Property button
    h = getGUIhandles;             %  Get handles
    if isempty(h);  return;  end   %  Axes gone, abort
    indx     = get(h.list,'Value');          %  Get layer index
    liststr  = get(h.list,'String');
    objects = validhandles(h);               %  Set valid object handles
    if isempty(objects);  return;  end       %  No objects remain on plot

    str0 = '';   indx = 1;   %  Initialize variables

	while 1   %  Prompt for properties.  Remain until no errors or cancelled
	    hmodal = PropertyEditBox(objects,str0,indx);    uiwait(hmodal.figure);

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
				      'uiwait(errordlg(lasterr,''Layer Tool Error'',''modal''))')
            if isempty(lasterr);   break;   end
		else
		    break
	    end
    end

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


function h = mlayersbox(hndl,workspace)

%  MLAYERSBOX  Displays the MLAYERS GUI.


%  Compute the Pixel and Font Scaling Factors so
%  GUI figure windows and fonts look OK across all platforms

PixelFactor = guifactm('pixels');
FontScaling =  guifactm('fonts');

%  Create the figure window

h.fig = figure('Name',workspace, 'NumberTitle','off',...
           'IntegerHandle','on', 'Resize','on',...
           'Units','Points',  'Position',PixelFactor*72*[0.01 2 2.2 3],...
		   'CloseRequestFcn','mlayers([],''close'')', 'Visible','off');
colordef(h.fig,'white');
figclr = get(h.fig,'Color');

% shift window if it comes up partly offscreen

shiftwin(h.fig)

%  Create the list box

h.list = uicontrol(h.fig,'Style','List', 'String','place holder',...
	        'Units','Normalized', 'Position',[0.10  0.50  0.80  0.45], ...
			'Max',1, 'Value',1,...
			'FontWeight','normal',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment','center', ...
			'ForegroundColor','black', 'BackgroundColor',figclr,...
			'CallBack','mlayers([],''object'')');

%  Plot/Hide/Show button

h.hide = uicontrol(h.fig,'Style','Push', 'String','Plot', ...
	        'Units', 'Normalized', 'Position', [0.10  0.35  0.40  0.10], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment','center',...
			'ForegroundColor','black', 'BackgroundColor',figclr,...
			'CallBack','mlayers([],''plot'')');

%  Delete button

h.delete = uicontrol(h.fig,'Style','Push', 'String','Delete', ...
	        'Units', 'Normalized', 'Position', [0.50  0.35  0.40  0.10], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment','center',...
			'ForegroundColor','black', 'BackgroundColor',figclr,...
			'Interruptible','on',...
			'CallBack','mlayers([],''delete'')');

%  Zdata button

h.zdata = uicontrol(h.fig,'Style','Push', 'String','Zdata', ...
	        'Units', 'Normalized', 'Position', [0.10  0.25  0.40  0.10], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment','center',...
			'ForegroundColor','black', 'BackgroundColor',figclr,...
			'Interruptible','on',...
			'CallBack','mlayers([],''zdata'')');

%  Erase Mode button

h.emode = uicontrol(h.fig,'Style','Push', 'String','Emode', ...
	        'Units', 'Normalized', 'Position', [0.50  0.25  0.40  0.10], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment','center',...
			'ForegroundColor','black', 'BackgroundColor',figclr,...
			'CallBack','mlayers([],''emode'')');

%  Highlight button

h.highlight = uicontrol(h.fig,'Style','Push', 'String','Highlight', ...
	        'Units', 'Normalized', 'Position',[0.10  0.15  0.40  0.10], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment','center',...
			'ForegroundColor','black', 'BackgroundColor',figclr,...
			'CallBack','mlayers([],''highlightON'')');

%  Property button

h.property = uicontrol(h.fig,'Style','Push', 'String','Property', ...
	        'Units', 'Normalized', 'Position', [0.50  0.15  0.40  0.10], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment','center',...
			'ForegroundColor','black', 'BackgroundColor',figclr,...
			'CallBack','mlayers([],''property'')');

%  Members button

h.members = uicontrol(h.fig,'Style','Push', 'String','Members', ...
	        'Units', 'Normalized', 'Position', [0.10  0.05  0.40  0.10], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment','center',...
			'ForegroundColor','black', 'BackgroundColor',figclr,...
			'Interruptible','on',...
			'CallBack','mlayers([],''members'')');

%  Purge button

h.purge = uicontrol(h.fig,'Style','Push', 'String','Purge', ...
	        'Units', 'Normalized', 'Position',[0.50  0.05  0.40  0.10], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment','center',...
			'ForegroundColor','black', 'BackgroundColor',figclr,...
			'CallBack','mlayers([],''purge'')');

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

h = dialog('Name','Layer Erase Mode',...
           'Units','Points',  'Position',PixelFactor*72*[2 2 2 2.5],...
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
			'FontWeight','bold',  'FontSize',FontScaling*12, ...
			'HorizontalAlignment','center', ...
			'ForegroundColor','black', 'BackgroundColor',figclr,...
			'CallBack','uiresume');

uicontrol(h,'Style','Push', 'String', 'Cancel', ...    %  Cancel Button
	        'Units','Normalized', 'Position',[.54 .05 .40 .18], ...
			'FontWeight','bold',  'FontSize',FontScaling*12, ...
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


function objects = validhandles(h)

%  VALIDHANDLES  Gets valid object handles for the MLAYERS function.
%
%  This handle list stored in the userdata slot may not
%  contain all valid handles since users can delete individual objects
%  while working with a map without exclusively using the mlayers gui tool


indx     = get(h.list,'Value');              %  Get layer index
userdata = get(h.list,'UserData');           %  and its structure data
liststring = get(h.list,'String');           %  and the string list

objects = userdata{indx,3};                  %  Get only objects
objects( find(~ishandle(objects)) ) = [];    %  which still exist

if isempty(objects)   %  Build the error/warning string if no objects remain
    listentry = deblank(liststring(indx,:));     %  Selected list item
    uiwait(errordlg(['No members of ',listentry(2:length(listentry)),' are mapped'],...
	                 'Layer Tool Error','modal'))

	userdata{indx,2} = 0 ;             %  Update the plot state flag and save
	liststring(indx,1) = ' ';
    set(h.list,'UserData',userdata,'String',liststring,'Value',indx)
	mlayers([],'object')
end


%*********************************************************************
%*********************************************************************
%*********************************************************************


function memberlist(listentry,datastruct)

%  MEMBERLIST displays a list with all members of a layer object


%  Determine the unique tags in the data structure

members = unique(strvcat(datastruct(:).tag),'rows');

%  Compute the Pixel and Font Scaling Factors so
%  GUI figure windows and fonts look OK across all platforms

PixelFactor = guifactm('pixels');
FontScaling =  guifactm('fonts');

%  Create the list box in case the select button is pushed

figsize = [3 2 3 3];
h = dialog('Name',['Object Sets in ',deblank(listentry)],...
           'Units','Points',  'Position',PixelFactor*72*figsize,...
		   'Visible','off');

% shift window if it comes up partly offscreen

shiftwin(h)

%  Ensure V5 color defaults

colordef(h,'white');
figclr = get(h,'Color');

%  Create the list box

listh = uicontrol(h,'Style','List', 'String',members ,...
	        'Units','Normalized', 'Position',[0.10  0.30  0.80  0.60], ...
			'Max',1, ...
			'FontWeight','normal',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment','center', ...
			'ForegroundColor','black', 'BackgroundColor',figclr);

%  Buttons to exit the modal dialog

buttonsize = [0.875  0.5];      %  Button size in inches
xoffset = (figsize(3) - buttonsize(1) )/2;
btnpos = [xoffset 0.15 buttonsize];   %  Button Position in inches

uicontrol(h,'Style','Push', 'String', 'Close', ...    %  Close Button
	        'Units','Points',  'Position',PixelFactor*72*btnpos, ...
			'FontWeight','bold',  'FontSize',FontScaling*12, ...
			'HorizontalAlignment','center', ...
			'ForegroundColor','black', 'BackgroundColor',figclr,...
			'CallBack','uiresume');

%  Turn dialog box on.  Then wait unit a button is pushed

set(h,'Visible','on');     uiwait(h)

if ~ishandle(h);   return;   end

%  Close the dialog box

delete(h)


%*********************************************************************
%*********************************************************************
%*********************************************************************


function highlightstate(h)

%  HIGHLIGHTSTATE sets the highlight button to correspond with the
%  objects current highlight state


objects = validhandles(h);   %  Set valid object handles
if isempty(objects);  return;  end

highlight = get(objects(1),'SelectionHighlight');
selected = get(objects(1),'Selected');

if strcmp(highlight,'on') & strcmp(selected,'on')
    set(h.highlight,'String','Normal','CallBack','mlayers([],''highlightOFF'')')
else
    set(h.highlight,'String','Highlight','CallBack','mlayers([],''highlightON'')')
end


%*********************************************************************
%*********************************************************************
%*********************************************************************


function h = getGUIhandles

%  GETGUIHANDLES  Gets the handles associated with the mlayers GUI and
%  also test to ensure that the associated axes still exists.


h = get(get(0,'CurrentFigure'),'UserData');  %  Get GUI handles
if ~ishandle(h.axes)     %  Abort tool if axes is gone
    uiwait(errordlg({'Associated Map Axes has been deleted',' ',...
					     'Layer Tool No Longer Appropriate'},...
						  'Layer Tool Error','modal'));
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

h.figure = dialog('Name','Define Layer Properties', ...
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






