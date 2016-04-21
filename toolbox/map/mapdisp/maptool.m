function h = maptool(varargin)

%MAPTOOL  Creates a figure window with a map axes and associated tools
%
%  MAPTOOL creates a figure window with a map axes and activates
%  the interactive tool for specifying a map projection.
%
%  MAPTOOL ProjectionName creates a figure window with the default
%  projection specified by ProjectionName.
%
%  MAPTOOL('MapPropertyName',MapPropertyValue,...) creates a figure
%  window and defines a map axes using the supplied Map properties.
%  MAPTOOL supports all the same properties as AXESM.
%
%  h = MAPTOOL(...) returns a two element vector containing the
%  handle of the Maptool figure window and the handle of the map axes.
%
%  See also  AXESM

%  Written by:  E. Byrns, E. Brown
%  $Revision: 1.19.4.1 $ $Date: 2003/08/01 18:18:53 $
%  Copyright 1996-2003 The MathWorks, Inc.


if nargin == 0 | ~isempty(varargin{1})
       hndl = INITmaptool(varargin{:});   %  Initialize the map figure window
	   if isstr(hndl);     error(hndl);
	       else;           if nargout == 1;  h = hndl;  end
	   end
elseif isempty(varargin{1}) & nargin >= 2
       mapcalls(varargin{:})          %  Figurem callback
end


%*************************************************************************
%*************************************************************************
%*************************************************************************


function hndl = INITmaptool(varargin)

%  INITMAPTOOL initializes the maptool window, mouse tools uicontrols,
%  the tool menu choices and the colormap menu.  A map axes
%  is also created, with a Robinson projection specified as
%  a default.

%  Create a new figure window.
%  Ensure V5 color defaults

% hndl(1) = figure('Tag','Map Tool Window',...
%                  'ButtonDownFcn','uimaptbx',...
%                  'CloseRequestFcn','maptool([],''close'')');
hndl(1) = gcf;

% Turn off the plot edit Tools menu
plotedit(hndl(1),'hidetoolsmenu');

if strcmp(get(hndl(1),'Tag'),'Map Tool Window')
	error('Maptools already applied to figure')
end
set(hndl(1),'Tag','Map Tool Window',...
                 'ButtonDownFcn','uimaptbx',...
                 'CloseRequestFcn','maptool([],''close'')');

%  Colors for the uicontrols

framecolor = brighten(get(hndl(1),'Color'),0.8);

%  Ensure that fonts look OK across platforms

FontScaling =  guifactm('fonts');

%  Create the mouse tool box and radio buttons.  Initially, these
%  controls are visible, but no tool is selected

uicontrol(hndl(1),'Style','Frame',...
              'Units','Normalized','Position',[.01 .78 .14 .20],...
			  'ForegroundColor', 'black', 'BackgroundColor', framecolor);

uicontrol(hndl(1),'Style','Push','String','Zoom',...
              'Units','Normalized','Position',[.02 .91 .12 .06],...
			  'FontWeight','normal',  'FontSize',FontScaling*10, ...
			  'HorizontalAlignment', 'left', 'Tag','off', ...
			  'ForegroundColor', 'black', 'BackgroundColor', framecolor,...
			  'Interruptible','on', 'CallBack','maptool([],''zoom'')');

uicontrol(hndl(1),'Style','Push','String','Rotate',...
              'Units','Normalized','Position',[.02 .85 .12 .06],...
			  'FontWeight','normal',  'FontSize',FontScaling*10, ...
			  'HorizontalAlignment', 'left', 'Tag','off', ...
			  'ForegroundColor', 'black', 'BackgroundColor', framecolor,...
			  'Interruptible','on', 'CallBack','maptool([],''rotate'')');

uicontrol(hndl(1),'Style','Push','String','Origin',...
              'Units','Normalized','Position',[.02 .79 .12 .06],...
			  'FontWeight','normal',  'FontSize',FontScaling*10, ...
			  'HorizontalAlignment', 'left', 'Tag','off', ...
			  'ForegroundColor', 'black', 'BackgroundColor', framecolor,...
			  'Interruptible','on', 'CallBack','maptool([],''origin'')');

%  Create the session menu and its submenu items
%  Set the parts of the load callback strings

msg = '{''''Operation successful.'''','''' '''',''''Use Session/Variables to view workspace variables.''''}';
titlestr = '''''Status Report''''';
str = ['uiwait(msgbox(',msg,',',titlestr,',''''modal''''))'''];
errorstr = '''uiwait(errordlg(lasterr,''''Operation Error'''',''''modal''''))''';


h = uimenu(hndl(1),'Label','Session');
hsub = uimenu(h,'Label','Load');
uimenu(hsub,'Label','Coast Lines',...
       'CallBack',['eval(''load coast;',str,',',errorstr,' )'])
uimenu(hsub,'Label','World Topo Data', ...
       'CallBack',['eval(''load topo;',str,',',errorstr,' )'])
uimenu(hsub,'Label','World Geoid Data', ...
       'CallBack',['eval(''load geoid;',str,',',errorstr,' )'])
uimenu(hsub,'Label','Moon Topo Data', ...
       'CallBack',['eval(''load moontopo;',str,',',errorstr,' )'])
uimenu(hsub,'Label','Cape Cod Topo Data', ...
       'CallBack',['eval(''loadcape;',str,',',errorstr,' )'])
uimenu(hsub,'Label','World Political Matrix Map', ...
       'CallBack',['eval(''load worldmtx;',str,',',errorstr,' )'])
uimenu(hsub,'Label','USA Political Matrix Map', ...
       'CallBack',['eval(''load usamtx;',str,',',errorstr,' )'])
uimenu(hsub,'Label','Specify Workspace','Interruptible','on', ...
                    'CallBack','maptool([],''loadvar'')')
hsub = uimenu(h,'Label','Layers');
uimenu(hsub,'Label','World LoRes','Interruptible','on',...
       'CallBack',['eval(''mlayers worldlo;'',',errorstr,' )'])
uimenu(hsub,'Label','World HiRes','Interruptible','on',...
       'CallBack',['eval(''mlayers worldhi;'',',errorstr,' )'])
uimenu(hsub,'Label','USA LoRes','Interruptible','on',...
       'CallBack',['eval(''mlayers usalo;'',',errorstr,' )'])
uimenu(hsub,'Label','USA HiRes','Interruptible','on',...
       'CallBack',['eval(''mlayers usahi;'',',errorstr,' )'])
uimenu(hsub,'Label','Workspace','Interruptible','on',...
       'CallBack',['eval(''rootlayr;mlayers(ans);'',',errorstr,' )'])
uimenu(hsub,'Label','Other','Interruptible','on',...
              'CallBack','maptool([],''loadlayer'')')
uimenu(h,'Label','Renderer','Separator','on', 'Interruptible','on',...
            'CallBack','maptool([],''renderer'',who)');
uimenu(h,'Label','Variables',...
                 'CallBack','maptool([],''variables'',who)');
uimenu(h,'Label','Command','Interruptible','on','CallBack','maptool([],''createvar'')');
hsub = uimenu(h,'Label','Clear', 'Separator','on');
uimenu(hsub,'Label','Specify Variables','Interruptible','on', 'CallBack','maptool([],''clearvar'')')
uimenu(hsub,'Label','Workspace',...
       'CallBack',['eval(''clear;',str,',',errorstr,' )'])
uimenu(hsub,'Label','Globals',...
       'CallBack',['eval(''clear global;',str,',',errorstr,' )'])
uimenu(hsub,'Label','Functions',...
       'CallBack',['eval(''clear functions;',str,',',errorstr,' )'])
uimenu(hsub,'Label','Mex',...
       'CallBack',['eval(''clear mex;',str,',',errorstr,' )'])
uimenu(hsub,'Label','All',...
       'CallBack',['eval(''clear all;',str,',',errorstr,' )'])

%  Create the project menu and its submenu items

h = uimenu(hndl(1),'Label','Map');
uimenu(h,'Label','Lines','Interruptible','on','CallBack','linem')
uimenu(h,'Label','Patches','Interruptible','on','CallBack','patchesm')
uimenu(h,'Label','Regular Surfaces','Interruptible','on','CallBack','meshm','Separator','on')
uimenu(h,'Label','General Surfaces','Interruptible','on','CallBack','surfacem')
uimenu(h,'Label','Regular Shaded Relief','Interruptible','on','CallBack','meshlsrm','Separator','on')
uimenu(h,'Label','General  Shaded Relief','Interruptible','on','CallBack','surflsrm')
uimenu(h,'Label','Comet','Interruptible','on', 'CallBack','comet3m','Separator','on')
uimenu(h,'Label','Contour Lines','Interruptible','on', 'CallBack','contor3m')
uimenu(h,'Label','Filled Contours','Interruptible','on', 'CallBack','contourfm')
uimenu(h,'Label','Quiver 2D','Interruptible','on','CallBack','quiverm');
uimenu(h,'Label','Quiver 3D','Interruptible','on','CallBack','quiver3m');
uimenu(h,'Label','Stem','Interruptible','on','CallBack','stem3m')
uimenu(h,'Label','Scatter','Interruptible','on','CallBack','scatterm')
uimenu(h,'Label','Text','Interruptible','on','Separator','on','CallBack','textm')
uimenu(h,'Label','Light','Interruptible','on','CallBack','lightm')

%  Create the display menu and its submenu items

h = uimenu(hndl(1),'Label','Display');
uimenu(h,'Label','Projection','Interruptible','on', 'CallBack','axesmui');
uimenu(h,'Label','Graticule','Interruptible','on','Separator','on',...
                 'CallBack','maptool([],''meshgrat'')')
uimenu(h,'Label','Legend','Interruptible','on',...
                 'CallBack','maptool([],''legendON'')')
uimenu(h,'Label','Frame','Interruptible','on','Separator','on','CallBack','framem');
uimenu(h,'Label','Grid','Interruptible','on','CallBack','gridm');
uimenu(h,'Label','Meridian Labels','Interruptible','on','CallBack','mlabel');
uimenu(h,'Label','Parallel Labels','Interruptible','on','CallBack','plabel');
uimenu(h,'Label','Tracks','Interruptible','on',...
         'Separator','on','CallBack','trackui(gca)');
uimenu(h,'Label','Small Circles','Interruptible','on',...
         'CallBack','scirclui(gca)');
uimenu(h,'Label','Surface Distances','Interruptible','on',...
         'CallBack','surfdist(gca)');

hsub = uimenu(h,'Label','Map Distortion','Separator','on');
uimenu(hsub,'Label','Angles', 'CallBack','mdistort angles')
uimenu(hsub,'Label','Area', 'CallBack','mdistort area')
uimenu(hsub,'Label','Scale', 'CallBack','mdistort scale')
uimenu(hsub,'Label','Off', 'CallBack','mdistort off')

uimenu(h,'Label','Scale Ruler', 'CallBack','scaleruler'); % toggle

hsub = uimenu(h,'Label','Print Preview','Separator','on','CallBack','previewmap');

%  Create the tool menu and its submenu items

h = uimenu(hndl(1),'Label','Tools');
uimenu(h,'Label','Hide','CallBack','maptool([],''toolhide'')');
uimenu(h,'Label','Off','CallBack','maptool([],''tooloff'')');
uimenu(h,'Label','Rotate','Separator','on','Interruptible','on',...
              'CallBack','maptool([],''rotate'')');
uimenu(h,'Label','Origin','Interruptible','on',...
              'CallBack','maptool([],''origin'')');
uimenu(h,'Label','Parallels','Interruptible','on',...
              'CallBack','maptool([],''parallel'')');
uimenu(h,'Label','Zoom Tool','Interruptible','on',...
              'Separator','on','CallBack','maptool([],''zoom'')');
uimenu(h,'Label','Set Limits', 'CallBack','panzoom setlimits');
uimenu(h,'Label','Full View', 'CallBack','panzoom fullview');

uimenu(h,'Label','2D View','Interruptible','on',...
              'Separator','on','CallBack','view(2)');

uimenu(h,'Label','Tight Map', 'CallBack','tightmap','Separator','on');
uimenu(h,'Label','Loose Map', 'CallBack','axis auto');
uimenu(h,'Label','Fill Figure', 'Separator','on',...
	'CallBack','units = get(gca,''Units''); set(gca,''Units'',''normalized'',''Position'',[0 0 1 1]); set(gca,''Units'',units)')
uimenu(h,'Label','Default Size',...
	'CallBack','units = get(gca,''Units''); set(gca,''Units'',''normalized'',''Position'',get(0,''factoryAxesPosition'')); set(gca,''Units'',units)')

uimenu(h,'Label','Objects','Interruptible','on',...
              'Separator','on','CallBack','mobjects(gca)');
hsub = uimenu(h,'Label','Edit','Separator','on');
uimenu(hsub,'Label','Current Object','Interruptible','on',...
              'CallBack',['get(get(0,''CurrentFigure''),''CurrentObject'');',...
			  'if ~isempty(ans);propedit(ans);else;',...
			   'uiwait(errordlg(''No current object'',''Edit Error'',''modal'')); end']);
uimenu(hsub,'Label','Select Object','Interruptible','on',...
              'CallBack',...
			  'handlem taglist;if ~isempty(ans);propedit(ans(1));end');
uimenu(hsub,'Label','Last Object','Interruptible','on',...
              'CallBack','maptool([],''lastobject'')')
hsub = uimenu(h,'Label','Show');
uimenu(hsub,'Label','All','Interruptible','on','CallBack','showm(''hidden'')');
uimenu(hsub,'Label','Object','Interruptible','on','CallBack','showm(''taglist'')');
hsub = uimenu(h,'Label','Hide');
uimenu(hsub,'Label','All','Interruptible','on','CallBack','hidem(''all'')');
uimenu(hsub,'Label','Map','Interruptible','on','CallBack','hidem(''map'')');
uimenu(hsub,'Label','Object','Interruptible','on','CallBack','hidem(''taglist'')');
hsub = uimenu(h,'Label','Delete');
uimenu(hsub,'Label','All','Interruptible','on','CallBack','clma(''all'')');
uimenu(hsub,'Label','Map','Interruptible','on','CallBack','clma');
uimenu(hsub,'Label','Object','Interruptible','on','CallBack','clmo(''taglist'')');

hsub = uimenu(h,'Label','Axes','Separator','on');
uimenu(hsub,'Label','Show', 'CallBack','showaxes(''on'')')
uimenu(hsub,'Label','Hide', 'CallBack','showaxes(''off'')')
uimenu(hsub,'Label','Visible', 'CallBack','showm(gca)')
uimenu(hsub,'Label','Invisible', 'CallBack','hidem(gca)')
uimenu(hsub,'Label','Color','Interruptible','on', ...
            'CallBack',...
			'showaxes(uisetcolor(get(gca,''XColor''),''Axes Color''));')

%  Add the colormap menu bar

clrmenu

%  Initialize the map axes

hndl(2) = gca;
% set(gca,'Position',[0.13  0.20  0.775  0.72]);


if isempty(varargin);   
	if ~ismap(gca);
		cancelflag = axesm;
        if cancelflag; clma purge ;  end % was delete(hndl(1))
	end
else;               
	if ismap(gca);
		if mod(length(varargin),2)==0
			setm(gca,varargin{:});
		else
			setm(gca,'MapProjection',varargin{:});
		end
	else
		[h,msg] = axesm(varargin{:});
		if ~isempty(msg); delete(hndl(1));  hndl=msg;  return; end
	end
end




%*************************************************************************
%*************************************************************************
%*************************************************************************

function mapcalls(varargin)

%  MAPCALLS performs all the callbacks for MAPTOOL.

%  The empty first input is used to indicate a mapcall callback
%  versus a maptool call with map axes property inputs.  The action
%  string is contained in the second input postion.


%  For each tool action below, the following steps are taken:
%     1.  Determine if the callback originated at the radio button
%         or the menu item
%     2.  Set the handle to the radio button uicontrol
%     3.  Turn on or off the tool.  If the tool is turned on, then
%         turn off any other tool which may be on.

switch varargin{2}
case 'close'         %  Close workspace
     ButtonName = questdlg('Are You Sure?','Confirm Closing','Yes','No','No');
     if strcmp(ButtonName,'Yes');   delete(get(0,'CurrentFigure'));   end

case 'variables'         %  List the variables in the root workspace
    varlist(varargin{3})

case 'renderer'         %  Set the figure renderer
    setrenderer;

case 'loadlayer'         %  Load a data layer workspace
    prompt   = 'Workspace With Layer Data';
	titlestr = 'Specify Layer Workspace';
	answer = {' '};
    while 1
	    lasterr('')
	    answer=inputdlg(prompt,titlestr,1,answer(1));
	    if ~isempty(answer)
	         eval(['mlayers ',answer{1}],...
				      'uiwait(errordlg(lasterr,''Load Layer Error'',''modal''))')
        end
        if isempty(lasterr);   break;   end
    end

case 'clearvar'         %  Clear workspace variables selection

%  Workspacedlg is needed to perform the operations in the
%  user workspace and not the local workspace for this function

 	workspacedlg('Specify variables:','Variables To Clear','',1)

case 'createvar'        %  Create workspace variables
 	workspacedlg('Statements to execute:','Workspace Commands','',0)

case 'loadvar'        %  Load workspace variables
 	workspacedlg('Workspace name:','Load Workspace','',2)
    if isempty(lasterr)

	end

case 'meshgrat'         %  Reset the Graticule of a regular surface map
    hndl = get(gcf,'CurrentObject');

	if isempty(hndl)
         uiwait(errordlg('No current object available','Selection Error','modal'))
	elseif ~ismapped(hndl)
         uiwait(errordlg('Current object is not mapped','Selection Error','modal'))
    else
         userdata = get(hndl,'UserData');
         mfields = char(fieldnames(userdata));
         indx = strmatch('maplegend',mfields,'exact');
         if length(indx) ~= 1
             uiwait(errordlg('Current object is not a regular surface map',...
				                 'Selection Error','modal'))
	     else
	        prompt   = 'Edit Graticule size (2 element vector):';
	        titlestr = 'Graticule Mesh';
			  answer = {['[',num2str(size(get(hndl,'Xdata'))),']']};

			while 1
	            lasterr('')
				answer=inputdlg(prompt,titlestr,1,answer(1));

		        if ~isempty(answer)
			        eval(['setm(hndl,''MeshGrat'',',answer{1},');'],...
		 	              'uiwait(errordlg(lasterr,''Graticule Mesh Error'',''modal''))')
				    if isempty(lasterr);   break;   end
			    else
		            break
                end
			end
	     end
     end

case 'zoom'         %  Pan Zoom selection

	 if strcmp(get(gco,'Type'),'uicontrol');     hndl = gco;
	    else;   hndl = findobj(gcf,'Type','uicontrol','String','Zoom');
		        set(hndl,'Value',~get(hndl,'Value'))
	 end

     if strcmp(get(hndl,'FontWeight'),'normal')
	        set(hndl,'FontWeight','bold','Tag','on');
			tooloff(hndl);  panzoom('on')
	 else
	        set(hndl,'FontWeight','normal','Tag','off');
	        panzoom('off')
     end

case 'rotate'       %  Rotate3D selection
	 if strcmp(get(gco,'Type'),'uicontrol');     hndl = gco;
	    else;   hndl = findobj(gcf,'Type','uicontrol','String','Rotate');
		        set(hndl,'Value',~get(hndl,'Value'))
	 end

     if strcmp(get(hndl,'FontWeight'),'normal')
	        set(hndl,'FontWeight','bold','Tag','on');
			tooloff(hndl);  rotate3d('on')
	 else
	        set(hndl,'FontWeight','normal','Tag','off');
	        rotate3d('off')
     end
 
case 'parallel'       %  parallelui selection
	 parallelui % toggle
case 'origin'      %  Originui selection
	 if strcmp(get(gco,'Type'),'uicontrol');     hndl = gco;
	    else;   hndl = findobj(gcf,'Type','uicontrol','String','Origin');
		        set(hndl,'Value',~get(hndl,'Value'))
	 end

     if strcmp(get(hndl,'FontWeight'),'normal')
	        set(hndl,'FontWeight','bold','Tag','on');
			tooloff(hndl);  originui('on')
	 else
	        set(hndl,'FontWeight','normal','Tag','off');
	        originui('off')
     end

case 'toolhide'      %  Hide the mouse tool uicontrols (menu choice)
     set(gcbo,'Label','Show','CallBack','maptool([],''toolshow'')');
     set(findobj(gcf,'Type','uicontrol'),'Visible','off')
% 	  if ismap;set(gca,'Units','Normalized','Position',[0.13  0.11  0.775  0.815]);end

case 'toolshow'      %  Show the mouse tool uicontrols (menu choice)
     set(gcbo,'Label','Hide','CallBack','maptool([],''toolhide'')');
     set(findobj(gcf,'Type','uicontrol'),'Visible','on')
% 	  if ismap; set(gca,'Units','Normalized','Position',[0.13  0.20  0.775  0.72]); end


case 'tooloff', tooloff       %  Turn off the mouse tools (menu choice)

case 'lastobject'

     children = get(gca,'children');

%  Eliminate objects from list if their handles are hidden.

    if length(children) == 1
        if strcmp(get(children,'HandleVisibility'),'off');   indx = 1;
             else;                                       indx = [];
        end
    elseif length(children) ~= 0
        hidden = get(children,'HandleVisibility');
        indx = strmatch('off',char(hidden));
    else
	    indx = [];
	end
    if ~isempty(indx);   children(indx) = [];   end

%  Activate propedit if at least one object remains

    if ~isempty(children);     propedit(children(1))
	    else;                   uiwait(errordlg('No objects on axes',...
		                         'Selection Error','modal'))
	end

case 'legendON'

     children = get(gca,'children');
     legndhndl = findobj(gcf,'Type','axes','Tag','legend');

%  Allow abort if legend already exists

     if ~isempty(legndhndl)
         btn = questdlg('Legend will be deleted.  Continue?','Confirm Legend','Yes','No','No');
         if strcmp(btn,'No')
             set(gcbo,'Label','Legend Off','CallBack','maptool([],''legendOFF'')' )
             return
         end
     end

%  Loop through the children and keep only the line handles
%  Get their name (tag or handle) to use for the legend string

    hndl = [];   linename = [];
    for i = 1:length(children)
	     if strcmp(get(children(i),'type'),'line')
		       if isempty(hndl)
			      hndl = children(i);
			      linename = namem(children(i));
			   else
			      hndl = [hndl;children(i)];
			      linename = str2mat(linename,namem(children(i)));
			   end
		 end
    end

%  If no lines remain, simply warn and end

	 if isempty(hndl)
	      uiwait(errordlg('No Lines on Map Axes','MapTool Warning','modal'));  return
	  end

%  Add the legend object off the axes

     legend(hndl,linename,-1);

%  Assign the SCRIBE callbacks to the legend objects

% The following block of code needs to be reviewed and updated to allow
% scribe interaction to work. 19971101/wms

%      legndhndl = findobj(gcf,'Type','axes','Tag','legend');
%      children = get(legndhndl,'Children');
%      for i = 1:length(children)
%         switch get(children(i),'Type')
% 	        case 'line',     set(children(i),'ButtonDownFcn','uimaptbx(''linemod'')')
% 		    case 'text',     set(children(i),'ButtonDownFcn','uimaptbx(''textmod'')')
% 	    end
%      end



%  Set the menu to delete the displayed legend

     set(gcbo,'Label','Legend Off','CallBack','maptool([],''legendOFF'')' )

case 'legendOFF'   %  Delete the shown legend

     legend off
     set(gcbo,'Label','Legend','CallBack','maptool([],''legendON'')' )

end


%*************************************************************************
%*************************************************************************
%*************************************************************************


function tooloff(except)

%  TOOLOFF turns off the mouse tools and sets the corresponding
%  radio button value to zero.  The exception to turning off the
%  tools may be provided by the input arugment.  This allows
%  one tool to be left on.  This operation provides the mutual
%  exclusiveness necessary for the radio button operation.  Note
%  that the RadioGroup property can not be used with the radio
%  buttons because the tool function must also be turned off
%  when the button value is set to zero.


if nargin == 0;   except = [];   end   %  Default is all off

%  Determine the handles of the radio buttons.  Eliminate an
%  exception button from this list.

hindx = findobj(gcf,'Type','uicontrol','Tag','on');
if ~isempty(except);  hindx(find(hindx == except)) = [];   end

%  Determine any other radio buttons which may be on

if ~isempty(hindx)         %  Turn these buttons (and operations) off
     set(hindx,'Tag','off','FontWeight','normal');
     switch get(hindx,'String')     %  Turn off the appropriate tool
	     case 'Zoom',      panzoom('off')
		 case 'Rotate',    rotate3d('off')
		 case 'Origin',    originui('off')
		 case 'Parallel',    disp('No parallel option in TOOLOFF')
		 otherwise
		      uiwait(errordlg('Unrecognized radio button string in TOOLOFF',...
				         'MapTool Error','modal'))
	 end
end


%*************************************************************************
%*************************************************************************
%*************************************************************************

function workspacedlg(prompt,titlestr,def,option)

%  WORKSPACEDLG creates the dialog box to allow the user to enter in
%  the workspaces command.  It is called from MAPTOOL to
%  workr variables in the USER's WORKSPACE not the workspace local
%  to MAPTOOL.m


while 1      %  Loop until no error break or cancel break

    lasterr('')     %  Reset the last error function

%  Display the variable prompt dialog box

    h = workspacebox(prompt,titlestr,def,option);   uiwait(h.fig)

    if ~ishandle(h.fig);   return;   end

    str = get(h.txtedit,'String');  def = str;  %  Get the string entry and save a copy
	 btn = get(h.fig,'CurrentObject');
	 delete(h.fig)

    if btn == h.apply

	    if ~isempty(str)
	        indx = find(str == 0);     %  Replace nulls, but not blanks
           if ~isempty(indx);  str(indx) = ' ';  end

	        switch option
			   case 0            %  Command to execute
		         str(:,size(str,2)+1) = ';';
               str = str';   str = str(:)';   str = str(find(str));
		       case 1           %  Clear variable
		         str(:,size(str,2)+1) = ' '; str = str';    str = str(:)';
               str = str';   str = str(:)';   str = str(find(str));
			      str = ['clear ',str];

		       case 2           %  Workspace Load Command
		         str(:,size(str,2)+1) = ' '; str = str';    str = str(:)';
               str = str';   str = str(:)';   str = str(find(str));
			      str = ['load ',str];
		     end

			  evalin('base',str,...
			         'uiwait(errordlg(lasterr,''Statement Error'',''modal''))');

		    if isempty(lasterr)
               uiwait(msgbox(...
					       {'Operation successful.',' ',...
					        'Use Session/Variables to view workspace variables'},...
			                 'Status Report','modal'))
			      break      %  Break loop with no errors
		    end
       end
   else
	   break             %  Exit the loop
   end
end


%*************************************************************************
%*************************************************************************
%*************************************************************************


function h = workspacebox(prompt,titlestr,def,option)

%  WORKSPACEBOX creates the dialog box and places the appropriate
%  objects for the WORKSPACEDLG function.

%  Compute the Pixel and Font Scaling Factors so
%  GUI figure windows and fonts look OK across all platforms

PixelFactor = guifactm('pixels');
FontScaling =  guifactm('fonts');

%  Create the dialog box.  Make visible when all objects are drawn

h.fig = dialog('Name',titlestr,...
           'Units','Points',  'Position',PixelFactor*72*[2 1.5 4 1.5], 'Visible','off');
colordef(h.fig,'white')
figclr = get(h.fig,'Color');

%  Text and Edit Box

h.txtlabel = uicontrol(h.fig,'Style','Text', 'String',prompt, ...
            'Units','Normalized','Position',[0.05  0.85  0.90  0.12], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment','left',...
			'ForegroundColor','black', 'BackgroundColor',figclr);

h.txtedit = uicontrol(h.fig,'Style','Edit', 'String',def, ...
            'Units','Normalized', 'Position',[0.05  .40  0.90  0.40], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, 'Tag','OK',...
			'HorizontalAlignment','left', 'Max',2,...
			'ForegroundColor','black', 'BackgroundColor',figclr);

if option == 1
    set(h.txtedit,'Position',[0.05  .50  0.70  0.20]);
	h.txtlist = uicontrol(h.fig,'Style','Push','String', 'List', ...
            'Units','Normalized','Position', [0.77  .50  0.18  0.20], ...
			'FontWeight','bold',  'FontSize',FontScaling*9, ...
			'ForegroundColor', 'black','BackgroundColor', figclr,...
			'Interruptible','on', 'UserData',h.txtedit,...
			'CallBack','varpick(who,get(gco,''UserData''))');
end

%  Compute the Pixel and Font Scaling Factors so
%  GUI figure windows and fonts look OK across all platforms

PixelFactor = guifactm('pixels');
FontScaling =  guifactm('fonts');

%  Buttons to exit the modal dialog

h.apply = uicontrol(h.fig,'Style','Push', 'String','Apply', ...    %  Apply Button
	        'Units','Points',  'Position',PixelFactor*72*[0.60  0.05  1.10  0.40], ...
			'FontWeight','bold',  'FontSize',FontScaling*12, ...
			'HorizontalAlignment','center', 'Tag','OK',...
			'ForegroundColor','black', 'BackgroundColor',figclr,...
			'Interruptible','on', 'CallBack','uiresume');

h.cancel = uicontrol(h.fig,'Style','Push', 'String','Cancel', ...    %  Cancel Button
	        'Units','Points',  'Position',PixelFactor*72*[2.30  0.05  1.10  0.40], ...
			'FontWeight','bold',  'FontSize',FontScaling*12, ...
			'HorizontalAlignment','center', ...
			'ForegroundColor','black', 'BackgroundColor',figclr,...
			'CallBack','uiresume');


set(h.fig,'Visible','on');


%*************************************************************************
%*************************************************************************
%*************************************************************************


function varlist(vars)

%VARLIST  Dialog displaying the current variables in the workspace
%
%  VARLIST is used by MAPTOOLS to display the current variables
%  in the workspace.

if nargin ~= 1;  error('Incorrect number of arguments');  end

%  Make the variable list into a string matrix.

if isempty(vars);    vars = ' ';
    else;            vars = char(vars);  end

%  Empty argument tests

titlestr = 'Current Variables';
figsize  = [3 2 2.5 3];
nselect  = 1;

%  Compute the Pixel and Font Scaling Factors so
%  GUI figure windows and fonts look OK across all platforms

PixelFactor = guifactm('pixels');
FontScaling =  guifactm('fonts');

%  Create the list box in case the select button is pushed

h = dialog('Name',titlestr,...
           'Units','Points',  'Position',PixelFactor*72*figsize,...
		   'Visible','off');
colordef(h,'white');
figclr = get(h,'Color');

%  Create the list box

listh = uicontrol(h,'Style','List', 'String',vars ,...
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


function setrenderer

%SETRENDERER  Dialog GUI to set the renderer for the maptool figure window

%  Compute the Pixel and Font Scaling Factors so
%  GUI figure windows and fonts look OK across all platforms

PixelFactor = guifactm('pixels');
FontScaling =  guifactm('fonts');

%  Determine the current erase mode for the object

fighndl = get(0,'CurrentFigure');
renderer = strvcat('zbuffer','painters');
indx = strmatch(get(fighndl,'Renderer'),renderer);

h.fig = dialog('Name','Figure Renderer',...
           'Units','Points',  'Position',PixelFactor*72*[2 2 2 2],...
		   'Visible','off');
colordef(h.fig,'white');
figclr = get(h.fig,'Color');


%  Place objects in the dialog box

uicontrol(h.fig,'Style','Text', 'String','Define Render Mode', ...
              'Units','Normalized', 'Position',[0.05  0.80  0.90  0.15], ...
			  'HorizontalAlignment','center', ...
 			  'FontWeight','bold',  'FontSize',FontScaling*10, ...
			  'ForegroundColor','black', 'BackgroundColor',figclr);


for i = 1:size(renderer,1)
	 h.radio(i) = uicontrol(h.fig,'Style','Radio', 'String',deblank(renderer(i,:)), ...
              'Units','Normalized', 'Position',[.1 .80-0.15*i .8 .13], ...
			  'HorizontalAlignment','left', 'Value',0, ...
 			  'FontWeight','bold',  'FontSize',FontScaling*10, ...
			  'ForegroundColor','black', 'BackgroundColor',figclr);
     if indx == i;  set(h.radio(i),'Value',1);  end
end

%  Set the user data to make radio buttons mutually exclusive

for i = 1:size(renderer,1)
     userdata = h.radio;  userdata(i) = [];   set(h.radio(i),'UserData',userdata);
end

%  Set the radio button callback string

set(h.radio,'CallBack','set(gco,''Value'',1);set(get(gco,''UserData''),''Value'',0)');

%  Push Buttons with uiresume command

h.apply = uicontrol(h.fig,'Style','Push', 'String', 'Apply', ...    %  Apply Button
	        'Units','Normalized', 'Position',[.06 .10 .40 .18], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment','center', ...
			'ForegroundColor','black', 'BackgroundColor',figclr,...
			'CallBack','uiresume');

h.cancel = uicontrol(h.fig,'Style','Push', 'String', 'Cancel', ...    %  Cancel Button
	        'Units','Normalized', 'Position',[.54 .10 .40 .18], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment','center', ...
			'ForegroundColor','black', 'BackgroundColor',figclr,...
			'CallBack','uiresume');

%  Turn dialog box on.  Then wait unit a button is pushed

set(h.fig,'Visible','on');     uiwait(h.fig)

if ~ishandle(h.fig);   return;   end

%  Set the figure renderer if the apply button is pressed

if get(h.fig,'CurrentObject') == h.apply
    for i = 1:length(h.radio)
	    if get(h.radio(i),'Value')
	         set(fighndl,'Renderer',get(h.radio(i),'String'))
			 break
        end
    end
end

%  Close the dialog box

delete(h.fig)

