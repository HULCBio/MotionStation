function originui(action,delta,direction)

%ORIGINUI  Tool for interactively modifying a map origin
%
%  ORIGINUI provides a tool to modify the origin of a displayed map
%  projection.  A marker (dot) is displayed where the origin is
%  currently located.  This dot can be moved and the map reprojected with
%  the identified point as the new origin.
%
%  ORIGINUI automatically toggles the current axes into a mode where
%  only actions recognized by ORIGINUI are executed.  Upon exit of
%  this mode, all prior ButtonDown functions are restored to the
%  current axes and its children.
%
%  ORIGINUI ON activates origin tool.  ORIGINUI OFF de-activates
%  the tool.  ORIGINUI will toggle between these two states.
%
%  ORIGINUI recognizes the following keystrokes.  RETURN will reproject
%  the map with the identified origin and remain in the originui mode.
%  ENTER reprojects the map with the identified origin and exits the
%  originui mode.  DELETE and ESCAPE will exit the origin mode
%  (same as ORIGINUI OFF).  N,S,E,W Keys move the marker North, South,
%  East or West by 10.0 degrees for each keystroke.  n,s,e,w keys move
%  the marker in the respective directions by 1 degree per keystroke.
%
%  ORIGINUI recognizes the following mouse actions when the cursor is on
%  the origin marker.  Single click and hold moves the origin marker.
%  Double click on the marker reprojects the map with the specified
%  map origin and remains in the origin mode (same as ORIGINUI RETURN).
%  Extended click moves the marker along the cartesian X or Y direction
%  only (depending on the direction of greatest movement).  Alternative
%  click exits the origin tool (same as ORIGINUI OFF).
%
%  For Macintosh:   Extend click - Shift click mouse button
%                   Alternate click - Option click mouse button
%
%  For MS-Windows:  Extend click - Shift click left button or both buttons
%                   Alternate click - Control click left button or right button
%
%  For X-Windows:   Extend click - Shift click left button or middle button
%                   Alternate click - Control click left button or right button
%
%  See also  SETM, AXESM

%  Copyright 1996-2003 The MathWorks, Inc.
% $Revision: 1.10.4.1 $
%  Written by:  E. Byrns, E. Brown



%  Default data

markersize = [25 40];
markerclr  = 'red';

%  Test input arguments

if nargin == 0
   clr = markerclr;     action = 'toggle';
elseif nargin == 1 & isstr(action)
   clr = markerclr;
elseif nargin == 1 & ~isstr(action)
   clr = action;    action = 'toggle';
end

%  Ensure that the plot is in a 2D view

if any(get(gca,'view') ~= [0 90])
    btn = questdlg( strvcat('Must be in 2D view for operation.',...
	                        'Change to 2D view?'),...
				    'Incorrect View','Change','Cancel','Change');

    switch btn
	    case 'Change',      view(2);
		case 'Cancel',      return
    end
end

%  Switch yard

switch action
case 'on'          %  Turn origin marker on

     hmark = findobj(gca,'Tag','originmarker');   %  Delete old marker if exists
     if ~isempty(hmark)                           %  Save any old function calls
	      fcns = get(hmark,'UserData');  delete(hmark)
	 else
	      fcns.windowdown = get(gcf,'WindowButtonDownFcn');
	      fcns.windowup   = get(gcf,'WindowButtonUpFcn');
	      fcns.windowmove = get(gcf,'WindowButtonMotionFcn');
	      fcns.windowkey  = get(gcf,'KeyPressFcn');
	 end

     mstruct = gcm;
	 origin = mstruct.origin;
	 [x,y]  = mfwdtran(mstruct,origin(1),origin(2),0,'none');

	 line('Xdata',x,'Ydata',y,'Zdata',max(get(gca,'Zlim')),...
	       'Marker','.',...
		   'MarkerFaceColor',clr,...
		   'MarkerEdgeColor',clr,...
	       'MarkerSize',markersize(1),...
		   'EraseMode','xor',...
		   'Tag', 'originmarker',...
		   'ButtonDownFcn','originui(''origindown'')',...
		   'UserData', fcns )


	 xlim = get(gca,'Xlim');   ylim = get(gca,'Ylim');
	 if x < xlim(1) | x > xlim(2) | y < ylim(1) | y > ylim(2)
	     showaxes on               %  Toggle axes to ensure dot is included
	     showaxes off              %  on current axes (eg:  conic projections
	 							   %  with lat origin 0, may not have trim
	 end					       %  limits at equator).

%  Set the origin text string.  Delete an old one if it exists

     hlabel = findobj(gcf,'Tag','originstring');
	 if ~isempty(hlabel);   delete(hlabel);   end

%  Angl2str is a time consuming call.  Vectorize to minimize time spent

     anglstr = angl2str([origin(1);origin(2)],'none',mstruct.angleunits,-1);
	 textstr = ['Lat: ',anglstr(1,:),'  Lon: ',anglstr(2,:)];
     textstr = strrep(textstr,degchar,'');

%  Compute the Pixel and Font Scaling Factors so
%  GUI figure windows and fonts look OK across all platforms

		PixelFactor = guifactm('pixels');
		FontScaling =  guifactm('fonts');

%  Add the origin text string

     uicontrol(gcf,'Style','text', 'String',textstr,...
              'Units','Points',  'Position',PixelFactor*[2 2 300 20], ...
			  'FontWeight','normal',  'FontSize',FontScaling*12, ...
			  'HorizontalAlignment','left',  'Tag','originstring',...
			  'ForegroundColor','black', 'BackgroundColor', get(gcf,'Color'));

     set(gcf,'WindowButtonDownFcn','',...                    %  Set the
             'WindowButtonUpFcn','',...                      %  needed
             'WindowButtonMotionFcn','',...                  %  window
			 'KeyPressFcn','originui(''key'')')              %  functions

case 'toggle'         %  Toggle origin marker visible and invisible
       hmark = findobj(gca,'Tag','originmarker');
	   if isempty(hmark)           %  Initial call.  No marker exists
            if ~ismap;  error('Not a valid map axes');  end
	        originui('on')
	   elseif strcmp(get(hmark,'Visible'),'on')    %  Turn off
	        originui('off')
	   elseif strcmp(get(hmark,'Visible'),'off')    %  Turn on
	        originui('on')
	   end


case 'origindown'       %  Process the button down event properly

     switch get(gcf,'SelectionType')
		      case 'alt',    originui('off')
			  case 'extend', originui('origin')
			  case 'open',   originui('apply')
			  case 'normal', originui('origin')
     end

case 'key'             %  Key strokes recognized
	  keychar = abs(get(gcf,'CurrentCharacter'));
	  if isempty(keychar); return; end
      switch keychar
	     case 3,      originui('apply');  originui('off')  %  Enter key
	     case 13,     originui('apply')                    %  Return key
	     case 27,     originui('off')                      %  Escape key
	     case 8,      originui('off')                      %  Delete key
	     case 127,    originui('off')                      %  Delete key (on PC)
		 case 28,     originui('keyorigin',-0.1,'ew')      %  Left Arrow
		 case 119,    originui('keyorigin',-1.0,'ew')      %  w key
		 case 87,     originui('keyorigin',-10.,'ew')      %  W key
		 case 29,     originui('keyorigin',+0.1,'ew')      %  Right Arrow
		 case 101,    originui('keyorigin',+1.0,'ew')      %  e key
		 case 69,     originui('keyorigin',+10.,'ew')      %  E key
		 case 30,     originui('keyorigin',+0.1,'ns')      %  Up Arrow
		 case 110,    originui('keyorigin',+1.0,'ns')      %  n key
		 case 78,     originui('keyorigin',+10.,'ns')      %  N key
		 case 31,     originui('keyorigin',-0.1,'ns')      %  Down Arrow
		 case 115,    originui('keyorigin',-1.0,'ns')      %  s key
		 case 83,     originui('keyorigin',-10.,'ns')      %  S key
     end

 case 'apply'      %  Reproject the map

	 oldor = getm(gca,'origin'); 
     hobject = findobj(gca,'Tag','originmarker');
     x = get(hobject,'Xdata');
	 y = get(hobject,'Ydata');

	 [lat,lon] = minvtran(x,y,0);
     setm(gca,'Origin',[roundn([lat lon]) oldor(3)] );
     originui('on');

case 'off'       %  Delete origin marker and exit origin mode
       hlabel = findobj(gcf,'Tag','originstring');
	   if ~isempty(hlabel);   delete(hlabel);   end

       hmark = findobj(gca,'Tag','originmarker');
	   if ~isempty(hmark)
	        fcns = get(hmark,'UserData');  delete(hmark);

            set(gcf,'WindowButtonDownFcn',fcns.windowdown,...   %  Reset all
	                'WindowButtonMotionFcn',fcns.windowmove,... %  window fcns
	                'WindowButtonUpFcn',fcns.windowup,...       %  which may have
			        'KeyPressFcn',fcns.windowkey)               %  been altered
       end
%       showaxes on;  showaxes off;

case 'origin'    %  Mouse clicks on the origin marker

    set(gco,'MarkerSize',markersize(2))

    if strcmp(get(gcf,'SelectionType'),'open')
	    originui('apply');  return
    else
	    set(gcf,'WindowButtonMotionFcn','originui(''moveorigin'')',...
	            'WindowButtonUpFcn','originui(''uporigin'')')
    end


case 'moveorigin'    %  Move the origin marker by the mouse

     hobject = get(gcf,'CurrentObject');
     hlabel  = findobj(gcf,'Tag','originstring');
     mstruct = get(gca,'UserData');

	 units   = mstruct.angleunits;

     pt = get(gca,'CurrentPoint');

     x  = get(hobject,'Xdata');
	 y  = get(hobject,'Ydata');

     delx = abs(x - pt(1,1));
	 dely = abs(y - pt(1,2));

%  A call to minvtran is time consuming.  Vectorize to increase efficiency.

	 [lats,lons] = minvtran(mstruct,[x;pt(1,1)],[y;pt(1,2)],0);

     if strcmp(get(gcf,'SelectionType'),'extend')
	     if delx > dely
		       x0   = pt(1,1);     y0   = y;
			   lat0 = lats(1);     lon0 = lons(2);
		 else
		       x0   = x;           y0   = pt(1,2);
			   lat0 = lats(2);     lon0 = lons(1);
		 end
	 else
         x0   = pt(1,1);     y0   = pt(1,2);
	     lat0 = lats(2);     lon0 = lons(2);
	 end

     set(hobject,'Xdata',x0,'Ydata',y0);

%  Angl2str is a time consuming call.  Vectorize to minimize time spent

     anglstr = angl2str([lat0;lon0],'none',units,-1);
	 textstr = ['Lat: ',anglstr(1,:),'  Lon: ',anglstr(2,:)];
     textstr = strrep(textstr,degchar,'');
	 set(hlabel,'String',textstr)

case 'uporigin'   %  Mouse release of the origin marker
     hobject   = get(gcf,'CurrentObject');
	 set(hobject,'MarkerSize',markersize(1))
	 set(gcf,'WindowButtonMotionFcn','',...
	         'WindowButtonUpFcn','')

case 'keyorigin'             %  Move origin by keystroke
     hobject = findobj(gca,'Tag','originmarker');
     hlabel  = findobj(gcf,'Tag','originstring');
   	 mstruct = get(gca,'UserData');           %  Speed up calls to transformations
	 units   = mstruct.angleunits;

     x = get(hobject,'Xdata');
	 y = get(hobject,'Ydata');

	 [lat,lon] = minvtran(mstruct,x,y,0);

	 if strcmp(direction,'ew')
	     lon = angledim(lon,units,'degrees');
	     lon = round( (lon+delta)/abs(delta)) * abs(delta);
	     lon = angledim(lon,'degrees',units);
	 else
	     lat = angledim(lat,units,'degrees');
	     lat = round( (lat+delta)/abs(delta)) * abs(delta);
	     lat = angledim(lat,'degrees',units);
	 end

     [x,y,z] = mfwdtran(mstruct,lat,lon,0,'none');
     set(hobject,'Xdata',x,'Ydata',y)

%  Angl2str is a time consuming call.  Vectorize to minimize time spent

     anglstr = angl2str([lat;lon],'none',units,-1);
     textstr = ['Lat: ',anglstr(1,:),'  Lon: ',anglstr(2,:)];
     textstr = strrep(textstr,degchar,'');
     set(hlabel,'String',textstr)
end

