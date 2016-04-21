function viewmaps(action)

%VIEWMAPS  GUI demonstrating map projections
%
%  Synopsis:  viewmaps
%
%  VIEWMAPS is used to display various map projections.  You can alter the
%  projection origin and orientation, and then view the resulting map.
%  This demo allows a rapid comparison of many different map projections.

%  Copyright 1996-2003 The MathWorks, Inc.
%  Written by:  E. Byrns, E. Brown
%  $Revision: 1.1.6.1 $  $Date: 2003/12/13 02:55:13 $


if nargin == 0;   action = 'initialize';   end


if strcmp(action,'initialize')

%  Initialize the interface window and save the object handles.

      hndls = viewpanl;

%  Load the necessary continent data and topography data

      load coast
	  load topo
	  demcmap(topo)

	  axes(hndls(1))
	  plot(long,lat,'b','LineWidth',0.2,...
	       'ButtonDownFcn','viewmaps(''setorigin'')');
	  axis tight

	  set(hndls(14),'UserData',topo)
      set(hndls(15),'UserData',[lat long])
	  set(gcf,'UserData',hndls,'Visible','on')

	  axes(hndls(2));
	  axesm('mapprojection','miller');   % Initialize map axes so first clma works
                                         % First clma happens on first press of show btn
      viewmaps('projection')    %  Update the projection edit box
      viewmaps('origin')        %  Initialize the origin/orientation marker

% disable uimaptbx interactions in demos

	  huimaptbx = findobj(gcf,'buttondownfcn','uimaptbx'); 
	  set(huimaptbx,'buttondownfcn','')
	  
	  viewmaps('show')

elseif strcmp(action,'projection') 	  %  Projection popup callback

      hndls    = get(gcf,'UserData');
	  projstr  = get(hndls(4),'UserData');
	  projindx = get(hndls(4),'Value');
      eval(['mapstruct = ',deblank(projstr(projindx,:)),'(defaultm);'])

	  parallels = mapstruct.mapparallels;
	  if mapstruct.nparallels == 1 & size(parallels,2)~=1
	  		parallels = 30;
	  elseif mapstruct.nparallels == 2 & size(parallels,2)~=2
	  		parallels = [-30 30];
	  end

	  set(hndls(3),'UserData',parallels); % use default parallels when switching projections

	  if mapstruct.nparallels == 0             %  Set the projection edit box(es)
	       set(hndls(10:12),'Visible','off')   %  to the proper visible state
	  elseif mapstruct.nparallels == 1
	       set(hndls(10:11),'Visible','on')
	       set(hndls(12),'Visible','off')
		   set(hndls(11),'String',num2str(parallels(1)))
	  else
	       set(hndls(10:12),'Visible','on')
		   set(hndls(11),'String',num2str(parallels(1)))
		   set(hndls(12),'String',num2str(parallels(2)))
      end

elseif strcmp(action,'parallels') 	    %  Parallel edit callback

      num = str2num(get(gco,'String'));    %  Allow parallels to be empty
	  if ~isempty(num);   num = min(max(num,-90),90);  end
      set(gco,'String',num2str(num));

elseif strcmp(action,'origin') 	  %  Test the origin and orientation entries

	  hndls = get(gcf,'UserData');
      origin1 = str2num(get(hndls(6),'String'));
	  if ~isempty(origin1)
	       origin(1) = min(max(origin1,-90),90);
	  else
	       origin(1) = 0;           %  Origin can not be empty
	  end
      set(hndls(6),'String',num2str(origin(1)));  %  Update edit box

      origin2 = str2num(get(hndls(7),'String'));
	  if ~isempty(origin2)
	       origin(2) = min(max(origin2,-180),180);
	  else
	       origin(2) = 0;           %  Origin can not be empty
	  end
      set(hndls(7),'String',num2str(origin(2)));  %  Update edit box

      origin3 = str2num(get(hndls(9),'String'));
	  if ~isempty(origin3)
	       origin(3) = min(max(origin3,-180),180);
	  else
	       origin(3) = 0;           %  Orientation can not be empty
	  end
      set(hndls(9),'String',num2str(origin(3)));  %  Update edit box


      axes(hndls(1));          %  Update the origin marker display
	  indx = findobj(gca,'Tag','OriginMarker');

	  if isempty(indx)  % Initial display of marker
		     h1 = plot(origin(2),origin(1),'r.','EraseMode','xor',...
	             'MarkerSize',20,'Tag','OriginMarker',...
				 'ButtonDownFcn','viewmaps(''originmove'')' );
      else
             set(indx,'Xdata',origin(2),'Ydata',origin(1))
			 h1 = [];
	  end

	  indx = findobj(gca,'Tag','OrientMarker');    %  Update orientation marker
      angle = pi/2 - origin(3)*pi/180;             %  Compute the direction for
      xvec = origin(2) + [0 25*cos(angle)];        %  the north pole pointer
	  yvec = origin(1) + [0 25*sin(angle)];

	  if isempty(indx)  % Initial display of marker
	         h2 = plot(xvec,yvec,'r-','EraseMode','xor',...
	              'LineWidth',2,'Tag','OrientMarker',...
				  'ButtonDownFcn','viewmaps(''originmove'')' );
      else
             set(indx,'Xdata',xvec,'Ydata',yvec)
			 h2 = [];
	  end

      if isempty(indx)     %  Save the marker handles for color updating later
	         set([h1; h2],'UserData',[h1;h2])
	  end

elseif strcmp(action,'setorigin')  %  User has selected a point on the display
                                   %  Mouse clicking to set the origin
      hndls = get(gcf,'UserData');
      selection = get(gcf,'SelectionType');

      axes(hndls(1));
	  pt = fix(get(gca,'CurrentPoint'));

      if strcmp(selection,'normal')               %  Move the origin point
           pt(1,1) = min(max(pt(1,1),-180),180);  %  Set the origin location
	       pt(1,2) = min(max(pt(1,2),-90),90);
           set(hndls(6),'String',num2str(pt(1,2)));
           set(hndls(7),'String',num2str(pt(1,1)));

           indx = findobj(gca,'Tag','OriginMarker');  %  Update Display
	       set(indx,'Xdata',pt(1,1),'Ydata',pt(1,2))

	       indx = findobj(gca,'Tag','OrientMarker');   %  Update orientation marker

           orient = str2num(get(hndls(9),'String'));
           angle = pi/2 - orient*pi/180;             %  Compute the direction for
           xvec = pt(1,1) + [0 25*cos(angle)];        %  the north pole pointer
	       yvec = pt(1,2) + [0 25*sin(angle)];

	       set(indx,'Xdata',xvec,'Ydata',yvec)

	  else                %  Move the orientation display
	       indx = findobj(gca,'Tag','OrientMarker');  %  Get the original orientation
	       xvec = get(indx,'Xdata');                  %  marker data
		   yvec = get(indx,'Ydata');

           pt(1,1) = min(max(pt(1,1),-180),180);      %  Compute new orientation
	       pt(1,2) = min(max(pt(1,2),-90),90);        %  based on mouse location

           angle = atan2(pt(1,2)-yvec(1), pt(1,1)-xvec(1));

		   orient = fix(rad2deg(npi2pi(...               %  Compute and set
		            pi/2 - angle,'radians','exact') ));  %  the orientation entry
           set(hndls(9),'String',num2str(orient));

           xvec(2) = xvec(1) + 25*cos(angle);      %  Update the orientation marker
		   yvec(2) = yvec(1) + 25*sin(angle);      %  display
	       set(indx,'Xdata',xvec,'Ydata',yvec)

	  end

elseif strcmp(action,'originmove')    %  Marker selected.  Continuous origin update

      set(gcf,'WindowButtonUpFcn', 'viewmaps(''buttonup'')', ...
              'WindowButtonMotionFcn', 'viewmaps(''setorigin'')');

	  obj = get(gcf,'CurrentObject');
	  h = get(obj,'UserData');    %  Highlight the origin marker to signify
	  set(h,'Color','green');     %  its selection

	  viewmaps('setorigin')    %  Updata based upon the initial selection

elseif strcmp(action,'buttonup')    %  Marker released

      set(gcf,'WindowButtonUpFcn', '','WindowButtonMotionFcn', '');
	  obj = get(gcf,'CurrentObject');
	  h = get(obj,'UserData');     %  Turn off marker highlight
	  set(h,'Color','red');

elseif strcmp(action,'show') 	  %  Display the specified map

	  hndls = get(gcf,'UserData');

%  Retrieve the necessary data

	  parallels = get(hndls(3),'UserData');
	  projstr   = get(hndls(4),'UserData');
	  projindx  = get(hndls(4),'Value');

	  parallel1 = str2num(get(hndls(11),'String')) ; %  Allow for empty parallel
	  parallel2 = str2num(get(hndls(12),'String')) ; %  entries.

      parallel = [];      %  Build up the correct (per axesm) parallel vector
      if strcmp(get(hndls(11),'Visible'),'on');  parallel = [parallel parallel1];  end
      if strcmp(get(hndls(12),'Visible'),'on');  parallel = [parallel parallel2];  end

      origin(1) = str2num(get(hndls(6),'String'));
      origin(2) = str2num(get(hndls(7),'String'));
      origin(3) = str2num(get(hndls(9),'String'));

%  Clear current map and define the new on

      axes(hndls(2)); clma all
      if ~isempty(parallel)
	      axesm('mapprojection',projstr(projindx,:),...
		        'mapparallels',parallel, 'origin',origin)
      else
	      axesm('mapprojection',projstr(projindx,:),'origin',origin)
	  end

      if get(hndls(14),'Value')    %  Topo display
	        topo = get(hndls(14),'UserData');
	        [latg,long] = meshgrat([-90 90],[0 360],[100 100]);
			surfacem(latg,long,topo,-1)
	  end

      if get(hndls(15),'Value')    %  Coast line display
	        latlon = get(hndls(15),'UserData');
			plotm(latlon(:,1),latlon(:,2),'m-')
	  end

      if get(hndls(16),'Value')    %  Grid line display
	        gridm('r:')
	  end

      if get(hndls(17),'Value')    %  North pole display
			plotm(90,0,'m*','MarkerSize',8)
	  end

      if get(hndls(18),'Value')    %  Tissot circles display
	        tissot('y-')
	  end

% disable uimaptbx interactions in demos

	  huimaptbx = findobj(gcf,'buttondownfcn','uimaptbx'); 
	  set(huimaptbx,'buttondownfcn','')

	  axis tight
end


%*********************************************************************
%*********************************************************************
%*********************************************************************


function hndl = viewpanl

%VIEWPANL  Creates the interface objects for the VIEWMAPS GUI
%
%  The data for the operation of this demo is stored in
%  various user data positions in the interface objects.


%  Get the projections to use in this demo

[idstring,fullname] = maplist;

%  Compute the Pixel and Font Scaling Factors so
%  GUI figure windows and fonts look OK across all platforms

PixelFactor = guifactm('pixels');
FontScaling =  guifactm('fonts');

%  Create the interface window.

figure('Visible','off',...
       'Units','Points',...
	   'Resize','on',    'Name','Mapping Toolbox Projections',...
	   'Numbertitle','off');

%  Set the default colors to V5 settings

colordef(gcf,'white');
figclr = get(gcf,'Color');

%  Axes for the cartesian display of the continents

hndl(1) = axes('Units','normalized', 'Position',[0.15  0.02  0.50  0.20],...
               'Box','on', 'NextPlot','add',...
			   'Xcolor','white', 'Xtick',[],...
			   'Ycolor','white', 'Ytick',[],...
			   'ButtonDownFcn','viewmaps(''setorigin'')');


%  Axes for the projected display of the continents

hndl(2) = axes('Units','normalized', 'Position',[0.02  0.28  0.70  0.70],...
               'Visible','off');

%  Projection selection popup menu

hndl(3) = uicontrol(gcf, 'Style','text',...
		  'Units','Normalized',  'Position',[0.75  0.93  0.20  0.04], ...
		  'String','Projection',  'HorizontalAlignment','left',...
		  'BackgroundColor',figclr, 'Foregroundcolor','black');

hndl(4) = uicontrol(gcf, 'Style','popup',...
		  'Units','Normalized', 'Position',[0.75  0.87  0.22  0.05],...
		  'Value',1, 'String',fullname,...
		  'UserData',idstring,...
		  'CallBack','viewmaps(''projection'')');


%  Origin settings

hndl(5) = uicontrol(gcf, 'Style','text',...
		  'Units','Normalized',  'Position',[0.75  0.81  0.25  0.04], ...
		  'String', 'Origin: Lat & Lon (deg)', 'HorizontalAlignment','left',...
		  'BackgroundColor',figclr, 'Foregroundcolor','black');

hndl(6) = uicontrol(gcf, 'Style','edit',...
		  'Units','Normalized',  'Position',[0.75  0.75  0.07  0.05], ...
		  'String','0', 'CallBack','viewmaps(''origin'')');

hndl(7) = uicontrol(gcf, 'Style','edit',...
		 'Units','Normalized',  'Position',[0.85  0.75  0.07  0.05], ...
		 'String','0', 'CallBack','viewmaps(''origin'')');


%  Orientation settings

hndl(8) = uicontrol(gcf, 'Style','text',...
		 'Units','Normalized', 'Position',[0.75  0.69  0.19  0.04], ...
		 'String','Orientation (deg)', 'HorizontalAlignment','left',...
		 'BackgroundColor',figclr, 'Foregroundcolor','black');

hndl(9) = uicontrol(gcf, 'Style','edit',...
		  'Units','Normalized', 'Position',[0.93  0.685  0.07  0.05], ...
		  'String','0', 'CallBack','viewmaps(''origin'')');

%  Parallels settings

hndl(10) = uicontrol(gcf, 'Style','text',...
		   'Units','Normalized', 'Position',[0.75  0.62  0.22  0.04], ...
		   'String','Parallels: Lats (deg)', 'HorizontalAlignment','left',...
		   'BackgroundColor',figclr, 'Foregroundcolor','black');

hndl(11) = uicontrol(gcf, 'Style','edit',...
		  'Units','Normalized', 'Position',[0.75  0.56  0.07  0.05], ...
		  'String','0', 'CallBack','viewmaps(''parallels'')');

hndl(12) = uicontrol(gcf, 'Style','edit',...
		   'Units','Normalized', 'Position',[0.85  0.56  0.07  0.05], ...
		   'String','0', 'CallBack','viewmaps(''parallels'')');

%  Display objects

hndl(13) = uicontrol(gcf, 'Style','text',...
		  'Units','Normalized', 'Position',[0.75  0.50  0.22  0.04], ...
		  'String','Displays:', 'HorizontalAlignment','left',...
		  'BackgroundColor',figclr, 'Foregroundcolor','black');

hndl(14) = uicontrol(gcf, 'Style','check',...
		   'Units','Normalized',  'Position',[0.75  0.46  0.22  0.04], ...
		   'String','Topography', 'Value',1,...
		   'HorizontalAlignment','left',...
		   'BackgroundColor',figclr, 'Foregroundcolor','black');

hndl(15) = uicontrol(gcf, 'Style','check',...
		   'Units','Normalized', 'Position',[0.75  0.41  0.22  0.04], ...
		   'String','Continents', 'Value',0,...
		   'HorizontalAlignment','left',...
		   'BackgroundColor',figclr, 'Foregroundcolor','black');

hndl(16) = uicontrol(gcf, 'Style','check',...
		   'Units','Normalized', 'Position',[0.75  0.36  0.22  0.04], ...
		   'String','Grid Lines', 'Value',0,...
		   'HorizontalAlignment','left',...
		   'BackgroundColor',figclr, 'Foregroundcolor','black');

hndl(17) = uicontrol(gcf, 'Style','check',...
		   'Units','Normalized', 'Position',[0.75  0.31  0.22  0.04], ...
		   'String','North Pole', 'Value',0,...
		   'HorizontalAlignment','left',...
		   'BackgroundColor',figclr, 'Foregroundcolor','black');

hndl(18) = uicontrol(gcf, 'Style','check',...
		   'Units','Normalized', 'Position',[0.75  0.26  0.22  0.04], ...
		   'String','Tissot Circles', 'Value',0,...
		   'HorizontalAlignment','left',...
		   'BackgroundColor',figclr, 'Foregroundcolor','black');

%  Show Button

hndl(19) = uicontrol(gcf,'Style','push',...
		   'Units','Normalized', 'Position',[0.75  0.14  0.22  0.07], ...
		   'String','Apply', 'CallBack','viewmaps(''show'')');

%  Exit Button

hndl(20) = uicontrol(gcf, 'Style','push',...
		   'Units','Normalized',  'Position',[0.75  0.05  0.22  0.07], ...
		   'String', 'Close', 'CallBack','close');


%*********************************************************************
%*********************************************************************
%*********************************************************************


function [idstring,fullname] = maplist

%  Construct the list of map projections to use with viewmaps.

idstring = strvcat('eqacylin','eqdcylin','mercator','miller',...
                   'pcarree','goode','loximuth','mollweid',...
                   'robinson','sinusoid','eqaconic','eqdconic',...
                   'lambert','polycon','vgrint1','bonne','werner',...
                   'eqaazim','eqdazim','gnomonic','ortho','stereo');


fullname = strvcat('Equal Area Cylindrical',  'Equidistant Cylindrical',...
                   'Mercator Cylindrical',    'Miller Cylindrical',...
                   'Plate Carree',            'Goode Homolosine',...
                   'Loximuthal',              'Mollweide',...
                   'Robinson',                'Sinusoidal',...
                   'Equal Area Conic',        'Equidistant Conic',...
                   'Lambert Conformal Conic', 'Polyconic',...
                   'Van Der Grinten I',       'Bonne',...
                   'Werner',                  'Equal Area Azimuthal',...
                   'Equidistant Azimuthal',   'Gnomonic',...
                   'Orthographic',            'Stereographic');

