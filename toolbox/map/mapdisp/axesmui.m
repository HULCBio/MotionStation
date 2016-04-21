function cancelflag = axesmui(callback,action)
%AXESMUI Interactive tool for manipulating map axes properties.
%   AXESMUI provides an interactive tool for manipulating map properties
%   of the current axes.  AXESMUI(hndl) will manipulate the map properties
%   of the axes specified by hndl.
%
%   C = AXESM(...) provides an optional output argument indicating if
%   the dialog window was closed by the cancel button.  If the Cancel
%   button is pushed, C = 1.  Otherwise, C = 0.
%
%   See also AXESM.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.15.4.1 $  $Date: 2003/08/01 18:17:46 $
%   Written by:  E. Byrns, E. Brown, A. Kim


%  Parse the inputs

if nargin == 0
      hndl = gca;           callback = 'initialize';
elseif nargin == 1
    if ~ischar(callback)
       hndl = callback;     callback = 'initialize';
	end
end


%  Initialize the output cancel flag if necessary.

if nargout == 1;  cancelflag = [];   end


switch callback      %  Basic switchyard
case 'initialize'

%  Test for a valid axis handle

      if isempty(hndl);   hndl = gca;   end

      if ~ishandle(hndl) | ~strcmp(get(hndl,'type'),'axes')
           uiwait(errordlg('Valid axis handle required',...
		                   'Initialization Error','modal'));  return
      end

%  Get the map structure

	  [mstruct,msg] = gcm(hndl);
	  if ~isempty(msg)
	      uiwait(errordlg(msg,'Initialization Error','modal'));  return
	  end

%  Display the dialog box, initialize the entries, and wait until dialog
%  is closed

      errorcondition = 0;
      workstruct = mstruct;
      while 1
          h = AxesmuiDialog(hndl);   %  Main dialog window

          set(h.hiddenaxes,'UserData',workstruct)	   %  Working map structure
		  axesmui('MainDialog','AxesEntries')
	      uiwait(h.fig)
          if ~ishandle(h.fig)
	         figure(get(h.axes,'Parent'))
             if errorcondition; setm(h.axes,get(h.axes,'UserData'));  end
			 if nargout == 1;  cancelflag = 1;  end
             return
		  end

		  axesmui('MainDialog','AxesUpdate')          %  Update structure based on dialog entries
          workstruct = get(h.hiddenaxes,'UserData');  %  Working map structure
          btn = get(h.fig,'CurrentObject');
		  delete(h.fig)

          if btn == h.apply
             lasterr('')
			 eval('setm(h.axes,workstruct)',...
			      'uiwait(errordlg(lasterr,''Mapping Error'',''modal''))')

			 if isempty(lasterr);    axes(h.axes)
			                         if nargout == 1;  cancelflag = 0;  end
				                     break
		         else;               errorcondition = 1;
			 end
         else    %  Canceled.  Reset map axes if an error condition existed
	         figure(get(h.axes,'Parent'))
             if errorcondition; setm(h.axes,get(h.axes,'UserData'));  end
			 if nargout == 1;  cancelflag = 1;  end
			 break
         end
    end
    
    h = findobj(gcf,'Type','uicontrol','Tag','TextObjectToDelete');
    if ishandle(h); delete(h); end
    
case 'numbercheck'      %  Check for valid numbers in selected edit boxes
                        %  These boxes can be linked to others so that emptying
						%  one empties its links too.  (such as Map Lat Limits)
	  obj=get(get(0,'CurrentFigure'),'CurrentObject');
	  linkobjects = get(obj,'UserData');
	  if isempty(linkobjects);   linkobjects = obj;   end

	  str = get(obj,'String');
	  if isempty(str);   set(linkobjects,'String','');  end

otherwise               %  Switch for all other actions, including nested dialogs
     eval([callback,'(''',action,''')'])

end


%**************************************************************************
%**************************************************************************
%**************************************************************************


function MainDialog(action)

%  MAINDIALOG contains the switch yard for almost all actions occuring
%  during the AXESMUI CallBacks.  The only other switches are above in
%  the AXESMUI function.

%  These callbacks typically assume that a hidden axes has been placed
%  on the dialog window (visible off, h.hiddenaxes) where a copy of
%  the map structure is kept.  This is the working copy of the map
%  structure which is different than the current map structure used
%  to display the current map.  If the map dialog is accepted, then
%  this working structure is transferred (and used to reproject) the
%  current map.


switch action
case 'AxesEntries'   %  Set the main dialog entries using the current map structure

	  h = get(get(0,'CurrentFigure'),'UserData');   %  Dialog object handles
      mstruct = get(h.hiddenaxes,'UserData');       %  Working map structure

	  listdata = get(h.projection,'UserData');
	  indx = strmatch(mstruct.mapprojection,listdata.idstr);

	  listdata.offset = fix(indx/listdata.pagelength);
	  stindx  = listdata.offset*listdata.pagelength + 1;
      endindx = min((listdata.offset+1)*listdata.pagelength,size(listdata.namestr,1));

	  set(h.projection,'String',listdata.namestr(stindx:endindx,:),...
	                   'Value',indx-stindx+1,'UserData',listdata)

	  indx = strmatch(mstruct.angleunits,get(h.angleunits,'String'),'exact');
	  set(h.angleunits,'Value',indx)       %  Set the angle units value

	  indx = strmatch(mstruct.aspect,get(h.aspect,'String'));
	  set(h.aspect,'Value',indx)       %  Set the aspect value

      set(h.maplat(1),'String',mstruct.maplatlimit(1))	 %  Map Limits
      set(h.maplat(2),'String',mstruct.maplatlimit(2))
      set(h.maplon(1),'String',mstruct.maplonlimit(1))
      set(h.maplon(2),'String',mstruct.maplonlimit(2))

      set(h.frmlat(1),'String',mstruct.flatlimit(1))	 %  Frame Limits
      set(h.frmlat(2),'String',mstruct.flatlimit(2))
      set(h.frmlon(1),'String',mstruct.flonlimit(1))
      set(h.frmlon(2),'String',mstruct.flonlimit(2))

      switch length(mstruct.origin)  %  Origin may not be length == 3 during gui callbacks
	  case 1
	     set(h.origin(1),'String',mstruct.origin(1))
      case 2
	     set(h.origin(1),'String',mstruct.origin(1))
	     set(h.origin(2),'String',mstruct.origin(2))
	  case 3
	     set(h.origin(1),'String',mstruct.origin(1))	 %  Map origin
	     set(h.origin(2),'String',mstruct.origin(2))	 %  Orientation is editable
         set(h.origin(3),'String',mstruct.origin(3))	 %  only if not fixed
	  end
	  if isempty(mstruct.fixedorient);   set(h.origin(3),'Enable','on')
	     else;                           set(h.origin(3),'Enable','off')
	  end

      switch mstruct.nparallels     %  Enable edit if parallels can be modified
	     case 0,   %  Show defaults even if they can't be edited
		      switch length(mstruct.mapparallels)
			      case 0,  set(h.parallel(1),'String','None','Enable','off')
		                   set(h.parallel(2),'String','','Visible','off')
			      case 1,  set(h.parallel(1),'String',mstruct.mapparallels(1),'Enable','off')
		                   set(h.parallel(2),'String','','Visible','off')
			      case 2,  set(h.parallel(1),'String',mstruct.mapparallels(1),'Enable','off')
		                   set(h.parallel(2),'String',mstruct.mapparallels(2),...
		                                     'Enable','off','Visible','on')
			  end
	     case 1,   set(h.parallel(1),'String',mstruct.mapparallels(1),'Enable','on')
		           set(h.parallel(2),'String','','Visible','off')
	 	 case 2,   set(h.parallel(1),'String',mstruct.mapparallels(1),'Enable','on')
            if length(mstruct.mapparallels) == 2
                  set(h.parallel(2),'String',mstruct.mapparallels(2),...
                                    'Enable','on','Visible','on')
            end
      end

%%  new code: added properties

	  if strcmp(mstruct.mapprojection,'utm') | strcmp(mstruct.mapprojection,'ups')
		  swtch1 = 'on';   swtch2 = 'off';
	  else
		  swtch1 = 'off';  swtch2 = 'on';
	  end
	  if strcmp(mstruct.mapprojection,'utm')
		  swtch3 = 'on';
	  else
		  swtch3 = 'off';
	  end

      set(h.zone,'String',mstruct.zone,'Enable',swtch1)
      set(h.zonebtn,'Enable',swtch3)
	  set(h.falseE,'String',mstruct.falseeasting,'Enable',swtch2)
      set(h.falseN,'String',mstruct.falsenorthing,'Enable',swtch2)
      set(h.sf,'String',mstruct.scalefactor,'Enable',swtch2)
	  set(h.origin(1),'Enable',swtch2)
	  set(h.origin(2),'Enable',swtch2)
	  set(h.origin(3),'Enable',swtch2)

%%  new code: geoid

	  set(h.geoid(1),'String',num2str(mstruct.geoid(1),7))
	  set(h.geoid(2),'String',num2str(mstruct.geoid(2),7))

	  set(h.geoid(1),'Userdata',mstruct.geoid)

	  [ptr,list] = geoidupdate(mstruct.zone,mstruct.geoid);
	  set(h.geoidpop,'String',list,'Value',ptr)

case 'AxesUpdate'      %  Update the properties associated with the main dialog

	  h = get(get(0,'CurrentFigure'),'UserData');   %  Dialog object handles
      mstruct = get(h.hiddenaxes,'UserData');       %  Working map structure

      listdata = get(h.projection,'UserData');    %  Map projection
	  indx = listdata.offset*listdata.pagelength + get(h.projection,'Value');
	  mstruct.mapprojection = deblank(listdata.idstr(indx,:));

      angleunits = get(h.angleunits,'String');   %  Angle units
	  indx = get(h.angleunits,'Value');
	  mstruct.angleunits = deblank(angleunits(indx,:));

      aspectstr = get(h.aspect,'String');   %  Aspect String
	  indx = get(h.aspect,'Value');
	  mstruct.aspect = deblank(aspectstr(indx,:));

	  origin1 = str2num(get(h.origin(1),'String'));   %  Allow for blank origin
	  origin2 = str2num(get(h.origin(2),'String'));   %  entries
	  origin3 = str2num(get(h.origin(3),'String'));
	  if length(origin1) >  1;   origin1 = origin1(1);   end
	  if length(origin2) == 0;   origin2 = 0;            end
	  if length(origin2) >  1;   origin2 = origin2(1);   end
	  if length(origin3) >  1;   origin3 = origin3(1);   end
	  mstruct.origin = [origin1  origin2  origin3];

	  limit1 = str2num(get(h.maplat(1),'String'));   %  Allow for blank limit
	  limit2 = str2num(get(h.maplat(2),'String'));   %  entries
	  if length(limit1) > 1;  limit1 = limit1(1);   end
	  if length(limit2) > 1;  limit2 = limit2(1);   end
	  mstruct.maplatlimit = [limit1 limit2];

	  limit1 = str2num(get(h.maplon(1),'String'));   %  Allow for blank limit
	  limit2 = str2num(get(h.maplon(2),'String'));   %  entries
	  if length(limit1) > 1;  limit1 = limit1(1);   end
	  if length(limit2) > 1;  limit2 = limit2(1);   end
	  mstruct.maplonlimit = [limit1 limit2];

	  limit1 = str2num(get(h.frmlat(1),'String'));   %  Allow for blank limit
	  limit2 = str2num(get(h.frmlat(2),'String'));   %  entries
	  if length(limit1) > 1;  limit1 = limit1(1);   end
	  if length(limit2) > 1;  limit2 = limit2(1);   end
	  mstruct.flatlimit = [limit1 limit2];

	  limit1 = str2num(get(h.frmlon(1),'String'));   %  Allow for blank limit
	  limit2 = str2num(get(h.frmlon(2),'String'));   %  entries
	  if length(limit1) > 1;  limit1 = limit1(1);   end
	  if length(limit2) > 1;  limit2 = limit2(1);   end
	  mstruct.flonlimit = [limit1 limit2];

      if mstruct.nparallels > 0
	     parallel = [];
	     for i = 1:mstruct.nparallels
	          pnum = str2num(get(h.parallel(i),'String'));
		      if length(pnum) > 1;  pnum = pnum(1);  end
              parallel = [parallel pnum];
	      end
         mstruct.mapparallels = parallel;
	  end

%%  new code: added properties

	  mstruct.zone = get(h.zone,'String');

	  falseE = str2num(get(h.falseE,'String'));   %  Allow for blank limit
	  falseN = str2num(get(h.falseN,'String'));   %  entries
	  sf = str2num(get(h.sf,'String'));
	  if length(falseE) > 1;  falseE = falseE(1);   end
	  if length(falseN) > 1;  falseN = falseN(1);   end
	  if length(sf) > 1;  sf = sf(1);   end
	  mstruct.falseeasting = falseE;
	  mstruct.falsenorthing = falseN;
	  mstruct.scalefactor = sf;

%%  new code: geoid

	  mstruct.geoid = get(h.geoid(1),'UserData');

      set(h.hiddenaxes,'UserData',mstruct)	   %  Update working map structure

case 'Projection'    %  Callback to set defaults when moving between projections
      axesmui('MainDialog','AxesUpdate')    %  Update the working map
	                                        %  structure before setting
                                            %  any remaining defaults
      h = get(get(0,'CurrentFigure'),'UserData');   %  Dialog object handles
      mstruct = get(h.hiddenaxes,'UserData');       %  Working map structure

      listdata = get(h.projection,'UserData');    %  Map projection
	  indx = listdata.offset*listdata.pagelength + get(h.projection,'Value');

     if strcmp('Page Down',deblank(listdata.idstr(indx,:)))
            listdata.offset = listdata.offset+1;
            if listdata.offset > listdata.maxoffset;  listdata.offset = 0; end
            stindx  = listdata.offset*listdata.pagelength + 1;
            endindx = (listdata.offset+1)*listdata.pagelength;
            endindx = min(endindx,size(listdata.namestr,1));
            indx = stindx + 1;

            set(h.projection,'String',listdata.namestr(stindx:endindx,:),...
                             'Value',indx-stindx+1,'UserData',listdata)

     elseif strcmp('Page Up',deblank(listdata.idstr(indx,:)))
            listdata.offset = listdata.offset-1;
            if listdata.offset < 0;  listdata.offset = listdata.maxoffset; end
            stindx  = listdata.offset*listdata.pagelength + 1;
            endindx = (listdata.offset+1)*listdata.pagelength;
            endindx = min(endindx,size(listdata.namestr,1));
            indx = endindx - 1;

            set(h.projection,'String',listdata.namestr(stindx:endindx,:),...
                             'Value',indx-stindx+1,'UserData',listdata)
    end

	 mstruct.mapprojection = deblank(listdata.idstr(indx,:));

	 mstruct.zone = [];
	 mstruct.geoid = [];

	 mstruct = feval(mstruct.mapprojection,mstruct);
	 mstruct = defaultm(mstruct);

     set(h.hiddenaxes,'UserData',mstruct)	   %  Update working map structure
	 axesmui('MainDialog','AxesEntries');

     % update fields for default frame latitude and longitude limits 06272002
     minlat = num2str(mstruct.trimlat(1));
     maxlat = num2str(mstruct.trimlat(2));
     minlon = num2str(mstruct.trimlon(1));
     maxlon = num2str(mstruct.trimlon(2));
     set(findobj(gcf,'Tag','frminlat'),'String',minlat)
     set(findobj(gcf,'Tag','frmaxlat'),'String',maxlat)
     set(findobj(gcf,'Tag','frminlon'),'String',minlon)
     set(findobj(gcf,'Tag','frmaxlon'),'String',maxlon)
     
case 'Zone'   %  new code: Callback for the zone edit box on main window
      h = get(get(0,'CurrentFigure'),'UserData');   %  Dialog object handles
      mstruct = get(h.hiddenaxes,'UserData');       %  Working map structure

	  oldzone = mstruct.zone;

	  if strcmp(mstruct.mapprojection,'utm')
	  		mstruct.zone = upper(get(h.zone,'String'));
	  elseif strcmp(mstruct.mapprojection,'ups')
	  		mstruct.zone = lower(get(h.zone,'String'));
	  end

	  lasterr('')
	  eval('mstruct = zoneupdate(mstruct);','')

	  if isempty(lasterr)
		  if strcmp(mstruct.mapprojection,'utm')
		  	[geoid,geoidstr] = utmgeoid(mstruct.zone);
		  	mstruct.geoid = geoid(1,:);
		  end
		  mstruct.mlabelparallel = [];	%  Ensures that these are set to the 
		  mstruct.plabelmeridian = [];	%  appropriate defaults
		  set(h.geoid(1),'UserData',mstruct.geoid)

		  set(h.hiddenaxes,'UserData',mstruct)
		  set(h.zone,'String',mstruct.zone)
		  axesmui('MainDialog','AxesEntries');	%  Update working map structure
	  else
		  uiwait(errordlg(lasterr,'Zone','modal'))

		  set(h.zone,'String',oldzone)			%  Set the zone back to the default
		  axesmui('MainDialog','AxesUpdate')	%  Update the working map
	  end

case 'Zonebtn'   %  new code: Callback for the zone push button on main window
      h = get(get(0,'CurrentFigure'),'UserData');   %  Dialog object handles
      mstruct = get(h.hiddenaxes,'UserData');       %  Working map structure

	  if strcmp(mstruct.mapprojection,'utm')
	  		oldzone = upper(get(h.zone,'String'));
	  elseif strcmp(mstruct.mapprojection,'ups')
	  		oldzone = lower(get(h.zone,'String'));
	  end

      h.windowstyle = get(h.fig,'WindowStyle');
	  if ~strcmp(computer,'MAC2') & ~strcmp(computer,'PCWIN')
            set(h.fig,'WindowStyle','normal')
	  end

	  [mstruct.zone,txtmsg] = utmzoneui(oldzone);

	  set(h.fig,'WindowStyle',h.windowstyle)

	  lasterr('')
	  eval('mstruct = zoneupdate(mstruct);','')

	  if isempty(lasterr)
		  [geoid,geoidstr] = utmgeoid(mstruct.zone);
		  mstruct.geoid = geoid(1,:);
		  mstruct.mlabelparallel = [];	%  Ensures that these are set to the 
		  mstruct.plabelmeridian = [];	%  appropriate defaults
		  set(h.geoid(1),'UserData',mstruct.geoid)

		  set(h.hiddenaxes,'UserData',mstruct)
		  set(h.zone,'String',mstruct.zone)
		  axesmui('MainDialog','AxesEntries');	%  Update working map structure
	  else
		  uiwait(errordlg(txtmsg,'Zone','modal'))

		  set(h.zone,'String',oldzone)			%  Set the zone back to the default
		  axesmui('MainDialog','AxesUpdate')	%  Update the working map
	  end
  
case 'Geoid'  % new code: Callback for geoid edit boxes on main window
      h = get(get(0,'CurrentFigure'),'UserData');   %  Dialog object handles
      mstruct = get(h.hiddenaxes,'UserData');       %  Working map structure

	  oldgeoid = mstruct.geoid;
	  geoid(1) = str2num(get(h.geoid(1),'String'));
	  geoid(2) = str2num(get(h.geoid(2),'String'));

	  txtmsg = [];
	  if geoid(1)<=0 | geoid(2)<0 | geoid(2)>=1
		  txtmsg = 'Invalid geoid definition';
	  end

	  if isempty(txtmsg)
		  mstruct.geoid = geoid;
		  set(h.geoid(1),'UserData',geoid)
		  set(h.hiddenaxes,'UserData',mstruct)
		  axesmui('MainDialog','AxesEntries');	%  Update working map structure
	  else
		  uiwait(errordlg(txtmsg,'Geoid','modal'))

		  set(h.geoid(1),'String',num2str(oldgeoid(1),7))		%  Set the zone back to the default
		  set(h.geoid(2),'String',num2str(oldgeoid(2),7))		%  Set the zone back to the default
		  axesmui('MainDialog','AxesUpdate')	%  Update the working map
	  end

case 'Geoidpop'  % new code: Callback for geoid popup on main window
      h = get(get(0,'CurrentFigure'),'UserData');   %  Dialog object handles
      mstruct = get(h.hiddenaxes,'UserData');       %  Working map structure

	  oldgeoid = mstruct.geoid;
	  ptr = get(h.geoidpop,'Value');

	  switch ptr
	  
	  case 1,  geoid = [1 0];
	  case 2,  geoid = almanac('earth','sphere');
	  case 3,  geoid = almanac('earth','airy');
	  case 4,  geoid = almanac('earth','bessel');
	  case 5,  geoid = almanac('earth','clarke66');
	  case 6,  geoid = almanac('earth','clarke80');
	  case 7,  geoid = almanac('earth','everest');
	  case 8,  geoid = almanac('earth','grs80');
	  case 9,  geoid = almanac('earth','iau65');
	  case 10, geoid = almanac('earth','iau68');
	  case 11, geoid = almanac('earth','international');
	  case 12, geoid = almanac('earth','krasovsky');
	  case 13, geoid = almanac('earth','wgs60');
	  case 14, geoid = almanac('earth','wgs66');
	  case 15, geoid = almanac('earth','wgs72');
	  case 16, geoid = almanac('sun','sphere');
	  case 17, geoid = almanac('moon','sphere');
	  case 18, geoid = almanac('mercury','sphere');
	  case 19, geoid = almanac('venus','sphere');
	  case 20, geoid = almanac('mars','sphere');
	  case 21, geoid = almanac('mars','geoid');
	  case 22, geoid = almanac('jupiter','sphere');
	  case 23, geoid = almanac('jupiter','geoid');
	  case 24, geoid = almanac('saturn','sphere');
	  case 25, geoid = almanac('saturn','geoid');
	  case 26, geoid = almanac('uranus','sphere');
	  case 27, geoid = almanac('uranus','geoid');
	  case 28, geoid = almanac('neptune','sphere');
	  case 29, geoid = almanac('neptune','geoid');
	  case 30, geoid = almanac('pluto','sphere');
	  otherwise, geoid = [nan nan];

	  end
  
	  if strcmp(mstruct.mapprojection,'utm') | strcmp(mstruct.mapprojection,'ups')
		  geoid(1) = geoid(1)*1e3;
	  end
	  
	  mstruct.geoid = geoid;
	  set(h.geoid(1),'UserData',geoid)
	  set(h.hiddenaxes,'UserData',mstruct)
	  axesmui('MainDialog','AxesEntries');	%  Update working map structure

case 'AngleUnits'   %  Callback for the angle units popup on main window
      h = get(get(0,'CurrentFigure'),'UserData');   %  Dialog object handles
      mstruct = get(h.hiddenaxes,'UserData');       %  Working map structure

      oldunits = mstruct.angleunits;

      axesmui('MainDialog','AxesUpdate')         %  Update the working map
	  mstruct = get(h.hiddenaxes,'UserData');    %  structure before changing
                                                 %  angle units

      lasterr('')
	  eval('mstruct = mapangles(mstruct,oldunits);','')

      if isempty(lasterr)
	      set(h.hiddenaxes,'UserData',mstruct)	   %  Update working map structure
	      axesmui('MainDialog','AxesEntries');
      else
		  uiwait(errordlg(lasterr,'Angle Units','modal'))

	      indx = strmatch(oldunits,get(h.angleunits,'String'),'exact');
	      set(h.angleunits,'Value',indx)       %  Set the angle units value
          axesmui('MainDialog','AxesUpdate')         %  Update the working map
	  end

case 'Reset'   %  Callback for the reset button on main window
      h = get(get(0,'CurrentFigure'),'UserData');   %  Dialog object handles
      mstruct = get(h.hiddenaxes,'UserData');       %  Working map structure

      prompt = strvcat('Changes Can Not Be Undone.',' ','Reset Map Settings?');
      ButtonName = questdlg(prompt,'Confirm Reset','Yes','No','No');

      if strcmp(ButtonName,'Yes')
	       set(0,'CurrentFigure',get(h.axes,'Parent'));
	       newstruct = defaultm;
	       newstruct.mapprojection = mstruct.mapprojection;
	       newstruct = feval(mstruct.mapprojection,newstruct);
	       newstruct = defaultm(newstruct);

	       set(0,'CurrentFigure',get(h.hiddenaxes,'Parent'));
           set(h.hiddenaxes,'UserData',newstruct)   %  Update working map structure
	       axesmui('MainDialog','AxesEntries');
      end

case 'Default'   %  Callback for the default button on main window
      axesmui('MainDialog','AxesUpdate')    %  Update the working map
	                                        %  structure before setting
                                            %  any remaining defaults
      h = get(get(0,'CurrentFigure'),'UserData');   %  Dialog object handles
      mstruct = get(h.hiddenaxes,'UserData');       %  Working map structure
	  mstruct = defaultm(mstruct);

      set(h.hiddenaxes,'UserData',mstruct)   %  Update working map structure
	  axesmui('MainDialog','AxesEntries')

case 'Frame'    %  Callback for the frame button on main window
    h = get(get(0,'CurrentFigure'),'UserData');   %  Dialog object handles
    mstruct = get(h.hiddenaxes,'UserData');       %  Working map structure

    copystruct = mstruct;
    while 1  %  Loop until valid entries or cancel pushed
        hmodal = FrameBox(copystruct);      uiwait(hmodal.fig);  %  Display modal dialog
        if ~ishandle(hmodal.fig);  return;   end

	    btn = get(hmodal.fig,'CurrentObject');        %  Get needed items before
	    frameon = get(hmodal.frameon,'Value');        %  destroying window
	    faceclr = get(hmodal.facecolor,'UserData');
	    edgeclr = get(hmodal.edgecolor,'UserData');

        linesizestr = get(hmodal.widthedit,'String');
		fillstr = get(hmodal.filledit,'String');
		linesize = str2num(linesizestr);
        fillpts = str2num(fillstr);

	    delete(hmodal.fig)

%  Update the copied map structure.  Use the string form of the
%  edit entries in case they're needed during the error looping.

        if frameon;      copystruct.frame = 'on';    %  Save entries in the
		    else;        copystruct.frame = 'off';   %  copied structure array
	    end

	    copystruct.ffacecolor = faceclr.val;    copystruct.fedgecolor = edgeclr.val;
        copystruct.flinewidth  = linesizestr;   copystruct.ffill = fillstr;

	    if btn == hmodal.apply     %  If apply, check for valid data
		    msg = [];
			if isempty(linesize) & ~isempty(linesizestr) | ...
			   length(linesize) > 1 | linesize <= 0
                msg = ['Frame edge width must be a single number greater than 0.'];
	        elseif isempty(fillpts) & ~isempty(fillstr) | ...
			       length(fillpts) > 1 | fillpts <= 0
                msg = ['Frame points per edge must be a single number greater than 0.'];
            end

			if ~isempty(msg)   %  Error condition
			    uiwait(errordlg(msg,'Invalid Frame Parameter','modal'))
            else
                copystruct.flinewidth  = linesize;  %  Replace text with
				copystruct.ffill = fillpts;         %  valid numerical entries
		        set(h.hiddenaxes,'UserData',copystruct)
				break         %  Valid frame parameters
		   end
        else
		   break      %  Cancel button pushed
        end
    end

case 'Grid'     %  Callback for the grid button on main window
    h = get(get(0,'CurrentFigure'),'UserData');   %  Dialog object handles
    mstruct = get(h.hiddenaxes,'UserData');       %  Working map structure

    copystruct = mstruct;
    while 1  %  Loop until valid entries or cancel pushed
        hmodal = GridBox(copystruct);      uiwait(hmodal.fig);  %  Display modal dialog
        if ~ishandle(hmodal.fig);  return;   end

	    btn = get(hmodal.fig,'CurrentObject');        %  Get needed items before
	    gridon = get(hmodal.gridon,'Value');          %  destroying window
	    gridclr = get(hmodal.color,'UserData');
        styles  = get(hmodal.style,'UserData');
		styleindx = get(hmodal.style,'Value');
        linesizestr = get(hmodal.widthedit,'String');
		altstr = lower(get(hmodal.altedit,'String'));
		linesize = str2num(linesizestr);
        altitude = str2num(altstr);

%  Get an updated copy of the map structure.  The parallel and meridan
%  settings may have been altered while waiting on the grid dialog.

		copystruct = get(hmodal.hiddenaxes,'UserData');

	    delete(hmodal.fig)

%  Update the copied map structure.  Use the string form of the
%  edit entries in case they're needed during the error looping.

        if gridon;       copystruct.grid = 'on';    %  Save entries in the
		    else;        copystruct.grid = 'off';   %  copied structure array
	    end

	    copystruct.gcolor     = gridclr.val;
		copystruct.glinestyle = deblank(styles(styleindx,:));
        copystruct.glinewidth = linesizestr;
		copystruct.galtitude  = altstr;

	    if btn == hmodal.apply     %  If apply, check for valid data
           msg = [];
		   if isempty(linesize) & ~isempty(linesizestr) | ...
		      length(linesize) > 1 | linesize <= 0
                msg = ['Grid line width must be a single number greater than 0.'];

%  The following line is commented out and substituted with the one that follows.
%  This works around a unix uicontrol bug in which the implicit num2str conversion
%  produces garbage, which then causes causes an error. This workaround should go
%  away with the bug.

% 	       elseif isempty(altitude) & ~isempty(altstr) | length(altitude) > 1

 			elseif length(altitude) > 1
                msg = ['Grid altitude must be a single number or INF.'];
           end

           if ~isempty(msg)
			    uiwait(errordlg(msg,'Invalid Grid Parameter','modal'))
           else
                copystruct.glinewidth = linesize;    %  Replace text with
				copystruct.galtitude = altitude;     %  valid numerical entries
		        set(h.hiddenaxes,'UserData',copystruct)
				break         %  Valid frame parameters
		   end
        else
		   break      %  Cancel button pushed
        end
    end

case 'Meridian&Parallel'   %  Callback for the Meridian&Parallel settings from Grid dialog
    hgrid = get(get(0,'CurrentFigure'),'UserData');   %  Grid Dialog object handles
    mstruct = get(hgrid.hiddenaxes,'UserData');       %  Working map structure

    copystruct = mstruct;
    while 1  %  Loop until valid entries or cancel pushed
        hmodal = GridPropBox(copystruct);      uiwait(hmodal.fig);  %  Display modal dialog
        if ~ishandle(hmodal.fig);  return;   end

	    btn = get(hmodal.fig,'CurrentObject');
	    meridianon = get(hmodal.meridianon,'Value');   %  Get needed meridian items
        mlocatestr = get(hmodal.longedit,'String');
        mlimitstr = get(hmodal.mlimitedit,'String');
        mexcptstr = get(hmodal.longexcedit,'String');
		mfillstr  = get(hmodal.mfilledit,'String');

	    parallelon = get(hmodal.parallelon,'Value');   %  Get needed parallel items
        plocatestr = get(hmodal.latedit,'String');
        plimitstr = get(hmodal.plimitedit,'String');
        pexcptstr = get(hmodal.latexcedit,'String');
		pfillstr  = get(hmodal.pfilledit,'String');

        delete(hmodal.fig)      %  Delete the modal dialog

%  Make potential multi-line entries into a single row vector

		mlocatestr = mlocatestr';                mexcptstr = mexcptstr';
		mlocatestr = mlocatestr(:)';             mexcptstr = mexcptstr(:)';
        mlocatestr(find(mlocatestr==0)) = [];    mexcptstr(find(mexcptstr ==0)) = [];

		plocatestr = plocatestr';                pexcptstr = pexcptstr';
		plocatestr = plocatestr(:)';             pexcptstr = pexcptstr(:)';
        plocatestr(find(plocatestr==0)) = [];    pexcptstr(find(pexcptstr ==0)) = [];

%  Convert strings to numbers.

		mlocate = str2num(mlocatestr);     mlimit = str2num(mlimitstr);
		mexcpt = str2num(mexcptstr);       mfill = str2num(mfillstr);

		plocate = str2num(plocatestr);     plimit = str2num(plimitstr);
		pexcpt = str2num(pexcptstr);       pfill = str2num(pfillstr);

%  Update the copied map structure.  Use the string form of the
%  edit entries in case they're needed during the error looping.

        if meridianon;       copystruct.mlinevisible = 'on';
		    else;            copystruct.mlinevisible = 'off';
	    end

        if parallelon;       copystruct.plinevisible = 'on';
		    else;            copystruct.plinevisible = 'off';
	    end

	    copystruct.mlinelocation = mlocatestr;
		copystruct.mlinelimit = mlimitstr;
        copystruct.mlineexception = mexcptstr;
		copystruct.mlinefill  = mfillstr;

	    copystruct.plinelocation = plocatestr;
		copystruct.plinelimit = plimitstr;
        copystruct.plineexception = pexcptstr;
		copystruct.plinefill  = pfillstr;

	    if btn == hmodal.apply     %  If apply, check for valid data
		    msg = [];
		    if isempty(mlocate) & ~isempty(mlocatestr)
                msg = ['Meridian locations must be a valid number or vector.'];
		    elseif isempty(mlimit) & ~isempty(mlimitstr) | ...
			       (length(mlimit) ~= 0 & length(mlimit) ~= 2)
                msg = ['Meridian limits must be empty or a two element vector.'];
		    elseif isempty(mexcpt) & ~isempty(mexcptstr)
                msg = ['Meridian exceptions must be a valid number or vector.'];
            elseif isempty(mfill) & ~isempty(mfillstr) | ...
			       length(mfill) > 1 | mfill <= 0
                msg = ['Meridian fill points must be a single number greater than 0.'];
		    elseif isempty(plocate) & ~isempty(plocatestr)
                msg = ['Parallel locations must be a valid number or vector.'];
		    elseif isempty(plimit) & ~isempty(plimitstr) | ...
			       (length(plimit) ~= 0 & length(plimit) ~= 2)
                msg = ['Parallel limits must be empty or a two element vector.'];
		    elseif isempty(pexcpt) & ~isempty(pexcptstr)
                msg = ['Parallel exceptions must be a valid number or vector.'];
            elseif isempty(pfill) & ~isempty(pfillstr) | ...
			       length(pfill) > 1 | pfill <= 0
                msg = ['Parallel fill points must be a single number greater than 0.'];
			end

           if ~isempty(msg)
			    uiwait(errordlg(msg,'Invalid Grid Parameter','modal'))
           else
	            copystruct.mlinelocation = mlocate;    %  Replace text with
		        copystruct.mlinelimit = mlimit;        %  valid numerical entries
                copystruct.mlineexception = mexcpt;
		        copystruct.mlinefill  = mfill;
	            copystruct.plinelocation = plocate;
		        copystruct.plinelimit = plimit;
                copystruct.plineexception = pexcpt;
		        copystruct.plinefill  = pfill;

		        set(hgrid.hiddenaxes,'UserData',copystruct)
				break         %  Valid frame parameters
		   end
        else
		   break      %  Cancel button pushed
        end
    end

case 'Labels'    %  Callback for the labels button on main window
    h = get(get(0,'CurrentFigure'),'UserData');   %  Dialog object handles
    mstruct = get(h.hiddenaxes,'UserData');       %  Working map structure

    copystruct = mstruct;
    while 1  %  Loop until valid entries or cancel pushed
        hmodal = LabelBox(copystruct);      uiwait(hmodal.fig);  %  Display modal dialog
        if ~ishandle(hmodal.fig);  return;   end

	    btn = get(hmodal.fig,'CurrentObject');        %  Get needed items before
	    meridianon = get(hmodal.meridianon,'Value');  %  destroying window
	    parallelon = get(hmodal.parallelon,'Value');
        labelformat = get(hmodal.format,'String');
		labelindx   = get(hmodal.format,'Value');

		labelunit = get(hmodal.units,'String');
		unitindx = get(hmodal.units,'Value');

		fontname = get(hmodal.fontedit,'String');
		fontsizestr = get(hmodal.sizeedit,'String');
		fontsize = str2num(fontsizestr);
	    fontclr = get(hmodal.fontclr,'UserData');

		fontunit = get(hmodal.fontunits,'String');
		fontindx = get(hmodal.fontunits,'Value');

		fontweights = get(hmodal.fontwt,'String');
		weightindx = get(hmodal.fontwt,'Value');

		fontangle = get(hmodal.fontangle,'String');
		angleindx = get(hmodal.fontangle,'Value');

%  Get an updated copy of the map structure.  The parallel and meridan
%  settings may have been altered while waiting on the font dialog.

		copystruct = get(hmodal.hiddenaxes,'UserData');

	    delete(hmodal.fig)

%  Update the copied map structure.  Use the string form of the
%  edit entries in case they're needed during the error looping.

        if meridianon;   copystruct.meridianlabel = 'on';    %  Save entries in the
		    else;        copystruct.meridianlabel = 'off';   %  copied structure array
	    end

        if parallelon;   copystruct.parallellabel = 'on';
		    else;        copystruct.parallellabel = 'off';
        end

	    copystruct.fontname    = fontname;
	    copystruct.fontsize    = fontsizestr;
		copystruct.fontangle   = deblank(fontangle(angleindx,:));
		copystruct.fontunits   = deblank(fontunit(fontindx,:));
		copystruct.fontweight  = deblank(fontweights(weightindx,:));
		copystruct.labelformat = deblank(labelformat(labelindx,:));
		copystruct.labelunits  = deblank(labelunit(unitindx,:));

	    if btn == hmodal.apply     %  If apply, check for valid data
           msg = [];
		   if isempty(fontsize) & ~isempty(fontsizestr) | ...
		      length(fontsize) > 1 | fontsize <= 0
                msg = ['Font size must be a single number greater than 0.'];
           end

           if ~isempty(msg)
			    uiwait(errordlg(msg,'Invalid Font or Label Parameter','modal'))
           else
	            copystruct.fontsize  = fontsize;
	            copystruct.fontcolor = fontclr.val;
		        set(h.hiddenaxes,'UserData',copystruct)
				break         %  Valid frame parameters
		   end
        else
		   break      %  Cancel button pushed
        end
    end

case 'LabelSettings'    %  Callback for the Parallel and Meridian Label settings
    hfont = get(get(0,'CurrentFigure'),'UserData');   %  Grid Dialog object handles
    mstruct = get(hfont.hiddenaxes,'UserData');       %  Working map structure

    copystruct = mstruct;
    while 1  %  Loop until valid entries or cancel pushed
        hmodal = LabelPropBox(copystruct);      uiwait(hmodal.fig);  %  Display modal dialog
        if ~ishandle(hmodal.fig);  return;   end

	    btn = get(hmodal.fig,'CurrentObject');
        mlocatestr = get(hmodal.mlocateedit,'String');   %  Get needed meridian items
		mroundstr  = get(hmodal.mroundedit,'String');

        mparallelstr = get(hmodal.mparalleledit,'String');
		mparalleloptions = get(hmodal.mparallelpopup,'String');
		mindx = get(hmodal.mparallelpopup,'Value');

        plocatestr = get(hmodal.plocateedit,'String');   %  Get needed parallel items
		proundstr  = get(hmodal.proundedit,'String');

        pmeridianstr = get(hmodal.pmeridianedit,'String');
		pmeridianoptions = get(hmodal.pmeridianpopup,'String');
		pindx = get(hmodal.pmeridianpopup,'Value');

        delete(hmodal.fig)      %  Delete the modal dialog

%  Make potential multi-line entries into a single row vector

		mlocatestr = mlocatestr';                plocatestr = plocatestr';
		mlocatestr = mlocatestr(:)';             plocatestr = plocatestr(:)';
        mlocatestr(find(mlocatestr==0)) = [];    plocatestr(find(plocatestr==0)) = [];

%  Convert strings to numbers.

		mlocate = str2num(mlocatestr);     mround = str2num(mroundstr);
        if ~isempty(mparallelstr);   mparallel = str2num(mparallelstr);
		   else;                     mparallel = deblank(mparalleloptions(mindx,:));
        end

		plocate = str2num(plocatestr);     pround = str2num(proundstr);
        if ~isempty(pmeridianstr);   pmeridian = str2num(pmeridianstr);
		   else;                     pmeridian = deblank(pmeridianoptions(pindx,:));
        end

%  Update the copied map structure.  Use the string form of the
%  edit entries in case they're needed during the error looping.

	    copystruct.mlabellocation = mlocatestr;
        copystruct.mlabelparallel = mparallelstr;
		copystruct.mlabelround  = mroundstr;

	    copystruct.plabellocation = plocatestr;
        copystruct.plabelmeridian = pmeridianstr;
		copystruct.plabelround  = proundstr;

	    if btn == hmodal.apply     %  If apply, check for valid data
		    msg = [];
		    if isempty(mlocate) & ~isempty(mlocatestr)
                msg = ['Meridian label locations must be a valid number or vector.'];
		    elseif isempty(mround) & ~isempty(mroundstr) | length(mround) > 1
                msg = ['Meridian round value must be a single number.'];
		    elseif isempty(mparallel) & ~isempty(mparallelstr) | ...
			       (~ischar(mparallel) & length(mparallel) > 1)
                msg = ['Display parallel must be a single number.'];
		    elseif isempty(plocate) & ~isempty(plocatestr)
                msg = ['Parallel label locations must be a valid number or vector.'];
		    elseif isempty(pround) & ~isempty(proundstr) | length(pround) > 1
                msg = ['Parallel round value must be a single number.'];
		    elseif isempty(pmeridian) & ~isempty(pmeridianstr) | ...
			       (~ischar(pmeridian) & length(pmeridian) > 1)
                msg = ['Display meridian must be a single number.'];
			end

           if ~isempty(msg)
			    uiwait(errordlg(msg,'Invalid Grid Parameter','modal'))
           else
	            copystruct.mlabellocation = mlocate;     %  Replace text with
		        copystruct.mlabelparallel = mparallel;   %  valid numerical entries
                copystruct.mlabelround = mround;

	            copystruct.plabellocation = plocate;
		        copystruct.plabelmeridian = pmeridian;
                copystruct.plabelround = pround;

		        set(hfont.hiddenaxes,'UserData',copystruct)
				break         %  Valid frame parameters
		   end
        else
		   break      %  Cancel button pushed
        end
    end

case 'FontPreview'   %  Callback to preview the selected font (Label Dialog)
      hmodal = get(get(0,'CurrentFigure'),'UserData');   %  Dialog object handles
      fontname = get(hmodal.fontedit,'String');
	  fontsize = str2num(get(hmodal.sizeedit,'String'));
	  if isempty(fontsize);  fontsize = 10;  end

      fontweights = get(hmodal.fontwt,'String');
	  weightindx = get(hmodal.fontwt,'Value');

	  fontangle = get(hmodal.fontangle,'String');
	  angleindx = get(hmodal.fontangle,'Value');

	  PixelFactor = guifactm('pixels');
	  FontScaling =  guifactm('fonts');

	  fighndl = dialog('Units','Points',  'Position',PixelFactor*72*[2 2 3 1.5],...
	                   'Name',[fontname,'  Preview'],'MenuBar','none',...
					   'Visible','on');
      colordef(fighndl,'white');
	  figclr = get(fighndl,'Color');

	  texthndl = uicontrol(fighndl,'Style','text', 'String','Aa Bb Cc Dd Ee Ff',...
	             'Units','normalized', 'Position',[0.05 0.3 0.90 0.60],...
	             'FontSize',FontScaling*10,    'FontWeight','bold', ...
	             'HorizontalAlignment','left', ...
				 'FontName', fontname, 'FontSize',FontScaling*fontsize, ...
				 'FontWeight',deblank(fontweights(weightindx,:)),...
				 'FontAngle', deblank(fontangle(angleindx,:)),...
	             'BackgroundColor',figclr, 'ForegroundColor','black');

	  okbtn = uicontrol(fighndl,'Style','push', 'String','OK',...
	             'Units','normalized', 'Position',[0.40 0.03 0.20 0.20],...
	             'FontSize',FontScaling*10,    'FontWeight','bold', ...
	             'HorizontalAlignment','left', ...
	             'BackgroundColor',figclr, 'ForegroundColor','black',...
				 'CallBack','delete(get(0,''CurrentFigure''))');

	  set(fighndl,'Visible','on')
	  uiwait(fighndl)
end


%*************************************************************************
%*************************************************************************
%*************************************************************************


function h = AxesmuiDialog(hndl)

%  AXESMUIDIALOG produces the main dialog box for the axesmui
%  function.  A rough cut of this code was generated using TOOLPAL
%  of the UITOOLS, and then the code was editted to produce the
%  desired interface.


%  Determine and insert page breaks into the name and idstring list.
%  Use key words of "Page Up" and "Page Down" to shift the popup
%  menu list.  This is necessary because X-Windows popup lists will
%  not scroll if the list exceeds the monitor window length

namestr = maps('namelist');    idstr   = maps('idlist');
classcodes = maps('classcodes');
colonstr = setstr(58*ones(size(classcodes,1),1));
blankstr = blanks(size(classcodes,1))';
namestr = [classcodes colonstr blankstr namestr];

if strcmp(computer,'MAC2') | strcmp(computer,'PCWIN')
     pagelength = 200;   %  Platforms where popups can scroll
else
     pagelength = 20;    %  Allow 20 name entries, + 2 key words, when popups can't scroll
end


rows = size(namestr,1);
if rows < pagelength;  inserts = 0;
   else;               inserts = ceil(rows/pagelength);   %  # of inserts to be placed
end

%  Expand the key word strings and append to the name lists

if inserts ~= 0
    pageupstr   = 'Page Up';      pageupstr   = pageupstr(ones(inserts,1),:);
    pagedownstr = 'Page Down';    pagedownstr = pagedownstr(ones(inserts,1),:);
    newnames = str2mat(namestr,pagedownstr,pageupstr);
    newids   = str2mat(idstr,pagedownstr,pageupstr);
else
    newnames = namestr;    newids   = idstr;
end

%  Determine the array indexing to properly place the key word strings

indx = [];
for i = 1:inserts
     stindx = (i-1)*pagelength + 1;    endindx = min(i*pagelength,rows);
     if i ~= inserts
	      indx = [indx;(stindx:endindx)'; rows+i; rows+inserts+i];
	 else
	      indx = [rows+inserts+i;indx;(stindx:endindx)';rows+i];
	 end
end

%  Reorder the name lists if page ups and downs have been placed

if inserts ~= 0
    newnames = newnames(indx,:);    newids   = newids(indx,:);
end

%  Save the needed data as a structure to be placed in the popup
%  menu UserData slot.

listdata.idstr = newids;              listdata.namestr = newnames;
listdata.offset = 0;                  listdata.maxoffset = inserts-1;
listdata.pagelength = pagelength+2;

%  Save the associated axes handle and the current map data structure

h.axes = hndl;

%  Compute the Pixel and Font Scaling Factors so
%  GUI figure windows and fonts have the same
%  proportions across all pllatforms

PixelFactor = guifactm('pixels');
FontScaling =  guifactm('fonts');

%  Create the dialog window

h.fig = figure('Units','Points',  'Position',PixelFactor*[50 265 530 325], ...
               'Name','Projection Control', 'NumberTitle','off',...
			   'Resize','off',...
			   'WindowStyle','modal', 'MenuBar','none',...
			   'Visible','off');

%
%adjust window position if corners are offscreen
%
shiftwin(h.fig)

colordef(h.fig,'white');
figclr = get(h.fig,'Color');
frameclr = brighten(figclr,0.5);

h.hiddenaxes = axes('Visible','off');

%  Projection Definition

uicontrol(h.fig, 'Style','frame', ...
	             'Units','Points',  'Position',PixelFactor*[10 290 340 30], ...
	             'FontSize',FontScaling*10,  'FontWeight','bold', ...
	             'BackgroundColor',frameclr, 'ForegroundColor','black');

h.projectionlabel = uicontrol(h.fig, 'Style','text', 'String','Map Projection', ...
	             'Units','Points',  'Position',PixelFactor*[15 298 95 15], ...
	             'FontSize',FontScaling*10,  'FontWeight','bold', ...
	             'HorizontalAlignment','left', ...
	             'BackgroundColor',frameclr, 'ForegroundColor','black');

h.projection = uicontrol(h.fig, 'Style','popupmenu', 'String','place holder', ...
	             'Units','Points',  'Position',PixelFactor*[115 295 225 20], ...
	             'FontSize',FontScaling*10,  'FontWeight','bold', ...
	             'HorizontalAlignment','left', 'UserData',listdata, ...
	             'BackgroundColor',figclr, 'ForegroundColor','black',...
				 'CallBack','axesmui(''MainDialog'',''Projection'')');

%%  new code: Zone Control

uicontrol(h.fig, 'Style','frame', ...
	             'Units','Points',  'Position',PixelFactor*[360 290 165 30], ...
	             'FontSize',FontScaling*10,  'FontWeight','bold', ...
	             'BackgroundColor',frameclr, 'ForegroundColor','black');

h.zonebtn = uicontrol(h.fig, 'Style','push', 'String','Zone', 'Units','Points', ...
	             'Position',PixelFactor*[380 295 60 20], ...
	             'FontSize',FontScaling*10,  'FontWeight','bold', ...
	             'HorizontalAlignment','left', 'Interruptible','on', ...
	             'BackgroundColor',figclr, 'ForegroundColor','black',...
				 'CallBack','axesmui(''MainDialog'',''Zonebtn'')');

h.zone = uicontrol(h.fig, 'Style','edit', 'Units','Points', ...
	             'Position',PixelFactor*[460 295 45 20], ...
	             'FontSize',FontScaling*9,  'FontWeight','bold', ...
	             'HorizontalAlignment','center', ...
	             'BackgroundColor',figclr, 'ForegroundColor','black',...
				 'CallBack','axesmui(''MainDialog'',''Zone'')');

%%  new code: Geoid Control

uicontrol(h.fig, 'Style','frame', ...
	             'Units','Points',  'Position',PixelFactor*[10 250 340 30], ...
	             'FontSize',FontScaling*10,  'FontWeight','bold', ...
	             'BackgroundColor',frameclr, 'ForegroundColor','black');

h.geoidlabel = uicontrol(h.fig, 'Style','text', 'String','Geoid', ...
	             'Units','Points',  'Position',PixelFactor*[15 258 40 15], ...
	             'FontSize',FontScaling*10,  'FontWeight','bold', ...
	             'HorizontalAlignment','left', ...
	             'BackgroundColor',frameclr, 'ForegroundColor','black');

h.geoid(1) = uicontrol(h.fig, 'Style','edit',  'Units','Points', ...
	             'Position',PixelFactor*[60 255 65 20], ...
	             'FontSize',FontScaling*9,  'FontWeight','bold', ...
	             'HorizontalAlignment','left', ...
	             'BackgroundColor',figclr, 'ForegroundColor','black',...
 				 'CallBack','axesmui(''numbercheck''); axesmui(''MainDialog'',''Geoid'')');

h.geoid(2) = uicontrol(h.fig, 'Style','edit',  'Units','Points', ...
	             'Position',PixelFactor*[135 255 65 20], ...
	             'FontSize',FontScaling*9,  'FontWeight','bold', ...
	             'HorizontalAlignment','left', ...
	             'BackgroundColor',figclr, 'ForegroundColor','black',...
 				 'CallBack','axesmui(''numbercheck''); axesmui(''MainDialog'',''Geoid'')');

h.geoidpop = uicontrol(h.fig, 'Style','popupmenu', 'String','place holder', ...
	             'Units','Points',  'Position',PixelFactor*[210 255 130 20], ...
	             'FontSize',FontScaling*10,  'FontWeight','bold', ...
	             'HorizontalAlignment','left', 'Interruptible','on',...
	             'BackgroundColor',figclr, 'ForegroundColor','black',...
				 'CallBack','axesmui(''MainDialog'',''Geoidpop'')');

%  Angle Units Control

uicontrol(h.fig, 'Style','frame', ...
	             'Units','Points',  'Position',PixelFactor*[360 250 165 30], ...
	             'FontSize',FontScaling*10,  'FontWeight','bold', ...
	             'BackgroundColor',frameclr, 'ForegroundColor','black');

h.anglelabel = uicontrol(h.fig, 'Style','text', 'String','Angle Units', ...
	             'Units','Points',  'Position',PixelFactor*[365 258 74 15], ...
	             'FontSize',FontScaling*10,  'FontWeight','bold', ...
	             'HorizontalAlignment','left', ...
	             'BackgroundColor',frameclr, 'ForegroundColor','black');

h.angleunits = uicontrol(h.fig, 'Style','popupmenu', ...
                 'String','degrees|dm|dms|radians', ...
	             'Units','Points',  'Position',PixelFactor*[440 255 75 20], ...
	             'FontSize',FontScaling*10,  'FontWeight','bold', ...
	             'HorizontalAlignment','left', 'Interruptible','on',...
	             'BackgroundColor',figclr, 'ForegroundColor','black',...
				 'CallBack','axesmui(''MainDialog'',''AngleUnits'')');

%  Map Limits Control

uicontrol(h.fig, 'Style','frame', ...
	             'Units','Points',  'Position',PixelFactor*[10 170 250 70], ...
	             'FontSize',FontScaling*10,  'FontWeight','bold', ...
	             'BackgroundColor',frameclr, 'ForegroundColor','black');

h.mlimitlabel = uicontrol(h.fig, 'Style','text', 'String','Map Limits', ...
	             'Units','Points',  'Position',PixelFactor*[15 221 95 15], ...
	             'FontSize',FontScaling*10,  'FontWeight','bold', ...
	             'HorizontalAlignment','left', ...
	             'BackgroundColor',frameclr, 'ForegroundColor','black');

h.maplatlabel = uicontrol(h.fig, 'Style','text', 'String','Latitude', ...
	             'Units','Points',  'Position',PixelFactor*[15 200 60 15], ...
	             'FontSize',FontScaling*10,  'FontWeight','bold', ...
	             'HorizontalAlignment','left', ...
	             'BackgroundColor',frameclr, 'ForegroundColor','black');

h.maplat(1) = uicontrol(h.fig, 'Style','edit', 'String',' ', ...
	             'Units','Points',  'Position',PixelFactor*[80 200 80 20], ...
	             'FontSize',FontScaling*9,  'FontWeight','bold', ...
	             'HorizontalAlignment','left', ...
	             'BackgroundColor',figclr, 'ForegroundColor','black',...
				 'CallBack','axesmui(''numbercheck'')');

h.maplat(2) = uicontrol(h.fig, 'Style','edit', 'String',' ', ...
	             'Units','Points',  'Position',PixelFactor*[170 200 80 20], ...
	             'FontSize',FontScaling*9,  'FontWeight','bold', ...
	             'HorizontalAlignment','left', ...
	             'BackgroundColor',figclr, 'ForegroundColor','black',...
				 'CallBack','axesmui(''numbercheck'')');

h.maplonlabel = uicontrol(h.fig, 'Style','text', 'String','Longitude', ...
	             'Units','Points',  'Position',PixelFactor*[15 175 60 15], ...
	             'FontSize',FontScaling*10,  'FontWeight','bold', ...
	             'HorizontalAlignment','left', ...
	             'BackgroundColor',frameclr, 'ForegroundColor','black');

h.maplon(1) = uicontrol(h.fig, 'Style','edit', 'String',' ', ...
	             'Units','Points',  'Position',PixelFactor*[80 175 80 20], ...
	             'FontSize',FontScaling*9,  'FontWeight','bold', ...
	             'HorizontalAlignment','left', ...
	             'BackgroundColor',figclr, 'ForegroundColor','black',...
				 'CallBack','axesmui(''numbercheck'')');

h.maplon(2) = uicontrol(h.fig, 'Style','edit', 'String',' ', ...
	             'Units','Points',  'Position',PixelFactor*[170 175 80 20], ...
	             'FontSize',FontScaling*9,  'FontWeight','bold', ...
	             'HorizontalAlignment','left', ...
	             'BackgroundColor',figclr, 'ForegroundColor','black',...
				 'CallBack','axesmui(''numbercheck'')');

%  Frame Limits Control

uicontrol(h.fig, 'Style','frame', ...
	             'Units','Points',  'Position',PixelFactor*[275 170 250 70], ...
	             'FontSize',FontScaling*10,  'FontWeight','bold', ...
	             'BackgroundColor',frameclr, 'ForegroundColor','black');

h.flimitlabel = uicontrol(h.fig, 'Style','text', 'String','Frame Limits', ...
	             'Units','Points',  'Position',PixelFactor*[280 221 95 15], ...
	             'FontSize',FontScaling*10,  'FontWeight','bold', ...
	             'HorizontalAlignment','left', ...
	             'BackgroundColor',frameclr, 'ForegroundColor','black');

h.frmlatlabel = uicontrol(h.fig, 'Style','text', 'String','Latitude', ...
	             'Units','Points',  'Position',PixelFactor*[280 200 60 15], ...
	             'FontSize',FontScaling*10,  'FontWeight','bold', ...
	             'HorizontalAlignment','left', ...
	             'BackgroundColor',frameclr, 'ForegroundColor','black');

h.frmlat(1) = uicontrol(h.fig, 'Style','edit', 'String',' ', ...
	             'Units','Points',  'Position',PixelFactor*[345 200 80 20], ...
	             'FontSize',FontScaling*9,  'FontWeight','bold', ...
	             'HorizontalAlignment','left', 'Tag','frminlat', ...
	             'BackgroundColor',figclr, 'ForegroundColor','black',...
				 'CallBack','axesmui(''numbercheck'')');

h.frmlat(2) = uicontrol(h.fig, 'Style','edit', 'String',' ', ...
	             'Units','Points',  'Position',PixelFactor*[435 200 80 20], ...
	             'FontSize',FontScaling*9,  'FontWeight','bold', ...
	             'HorizontalAlignment','left', 'Tag','frmaxlat', ...
	             'BackgroundColor',figclr, 'ForegroundColor','black',...
				 'CallBack','axesmui(''numbercheck'')');

h.frmlonlabel = uicontrol(h.fig, 'Style','text', 'String','Longitude', ...
	             'Units','Points',  'Position',PixelFactor*[280 175 60 15], ...
	             'FontSize',FontScaling*10,  'FontWeight','bold', ...
	             'HorizontalAlignment','left', ...
	             'BackgroundColor',frameclr, 'ForegroundColor','black');

h.frmlon(1) = uicontrol(h.fig, 'Style','edit', 'String',' ', ...
	             'Units','Points',  'Position',PixelFactor*[345 175 80 20], ...
	             'FontSize',FontScaling*9,  'FontWeight','bold', ...
	             'HorizontalAlignment','left', 'Tag','frminlon', ...
	             'BackgroundColor',figclr, 'ForegroundColor','black',...
				 'CallBack','axesmui(''numbercheck'')');

h.frmlon(2) = uicontrol(h.fig, 'Style','edit', 'String',' ', ...
	             'Units','Points',  'Position',PixelFactor*[435 175 80 20], ...
	             'FontSize',FontScaling*9,  'FontWeight','bold', ...
	             'HorizontalAlignment','left', 'Tag','frmaxlon', ...
	             'BackgroundColor',figclr, 'ForegroundColor','black',...
				 'CallBack','axesmui(''numbercheck'')');

%  Map Origin Control

uicontrol(h.fig, 'Style','frame', ...
	             'Units','Points',  'Position',PixelFactor*[10 90 250 70], ...
	             'FontSize',FontScaling*10,  'FontWeight','bold', ...
	             'BackgroundColor',frameclr, 'ForegroundColor','black');

h.originlabel = uicontrol(h.fig, 'Style','text', 'String','Map Origin', ...
	             'Units','Points',  'Position',PixelFactor*[15 141 120 15], ...
	             'FontSize',FontScaling*10,  'FontWeight','bold', ...
	             'HorizontalAlignment','left', ...
	             'BackgroundColor',frameclr, 'ForegroundColor','black');

h.originlatlon = uicontrol(h.fig, 'Style','text', 'String','Lat and Long', ...
	             'Units','Points',  'Position',PixelFactor*[15 120 80 15], ...
	             'FontSize',FontScaling*10,  'FontWeight','bold', ...
	             'HorizontalAlignment','left', ...
	             'BackgroundColor',frameclr, 'ForegroundColor','black');

h.origin(1) = uicontrol(h.fig, 'Style','edit', 'String',' ', ...
	             'Units','Points',  'Position',PixelFactor*[100 120 70 20], ...
	             'FontSize',FontScaling*9,  'FontWeight','bold', ...
	             'HorizontalAlignment','left', ...
	             'BackgroundColor',figclr, 'ForegroundColor','black',...
				 'CallBack','axesmui(''numbercheck'')');

h.origin(2) = uicontrol(h.fig, 'Style','edit', 'String',' ', ...
	             'Units','Points',  'Position',PixelFactor*[180 120 70 20], ...
	             'FontSize',FontScaling*9,  'FontWeight','bold', ...
	             'HorizontalAlignment','left', ...
	             'BackgroundColor',figclr, 'ForegroundColor','black',...
				 'CallBack','axesmui(''numbercheck'')');

h.orientation = uicontrol(h.fig, 'Style','text', 'String','Orientation', ...
	             'Units','Points',  'Position',PixelFactor*[15 95 80 15], ...
	             'FontSize',FontScaling*10,  'FontWeight','bold', ...
	             'HorizontalAlignment','left', ...
	             'BackgroundColor',frameclr, 'ForegroundColor','black');

h.origin(3) = uicontrol(h.fig, 'Style','edit', 'String',' ', ...
	             'Units','Points',  'Position',PixelFactor*[100 95 70 20], ...
	             'FontSize',FontScaling*9,  'FontWeight','bold', ...
	             'HorizontalAlignment','left', ...
	             'BackgroundColor',figclr, 'ForegroundColor','black',...
				 'CallBack','axesmui(''numbercheck'')');

%%  new code: Cartesian Origin Control

uicontrol(h.fig, 'Style','frame', ...
	             'Units','Points',  'Position',PixelFactor*[275 90 250 70], ...
	             'FontSize',FontScaling*10,  'FontWeight','bold', ...
	             'BackgroundColor',frameclr, 'ForegroundColor','black');

h.paramlabel = uicontrol(h.fig, 'Style','text', 'String','Cartesian Origin', ...
	             'Units','Points',  'Position',PixelFactor*[280 141 180 15], ...
	             'FontSize',FontScaling*10,  'FontWeight','bold', ...
	             'HorizontalAlignment','left', ...
	             'BackgroundColor',frameclr, 'ForegroundColor','black');

h.falseENlabel = uicontrol(h.fig, 'Style','text', 'String','False E and N', ...
	             'Units','Points',  'Position',PixelFactor*[280 120 80 15], ...
	             'FontSize',FontScaling*10,  'FontWeight','bold', ...
	             'HorizontalAlignment','left', ...
	             'BackgroundColor',frameclr, 'ForegroundColor','black');

h.falseE = uicontrol(h.fig, 'Style','edit',  'Units','Points', ...
	             'Position',PixelFactor*[365 120 70 20], ...
	             'FontSize',FontScaling*9,  'FontWeight','bold', ...
	             'HorizontalAlignment','left', ...
	             'BackgroundColor',figclr, 'ForegroundColor','black',...
				 'CallBack','axesmui(''numbercheck'')');

h.falseN = uicontrol(h.fig, 'Style','edit',  'Units','Points', ...
	             'Units','Points',  'Position',PixelFactor*[445 120 70 20], ...
	             'FontSize',FontScaling*9,  'FontWeight','bold', ...
	             'HorizontalAlignment','left', ...
	             'BackgroundColor',figclr, 'ForegroundColor','black',...
				 'CallBack','axesmui(''numbercheck'')');

h.sflabel = uicontrol(h.fig, 'Style','text', 'String','Scalefactor', ...
	             'Units','Points',  'Position',PixelFactor*[280 95 80 15], ...
	             'FontSize',FontScaling*10,  'FontWeight','bold', ...
	             'HorizontalAlignment','left', ...
	             'BackgroundColor',frameclr, 'ForegroundColor','black');

h.sf = uicontrol(h.fig, 'Style','edit',  'Units','Points', ...
	             'Position',PixelFactor*[365 95 70 20], ...
	             'FontSize',FontScaling*9,  'FontWeight','bold', ...
	             'HorizontalAlignment','left', ...
	             'BackgroundColor',figclr, 'ForegroundColor','black',...
 				 'CallBack','axesmui(''numbercheck'')');

%  Parallels Control

uicontrol(h.fig, 'Style','frame', ...
	             'Units','Points',  'Position',PixelFactor*[10 50 250 30], ...
	             'FontSize',FontScaling*10,  'FontWeight','bold', ...
	             'BackgroundColor',frameclr, 'ForegroundColor','black');

h.parallellabel = uicontrol(h.fig, 'Style','text', 'String','Parallels', ...
	             'Units','Points',  'Position',PixelFactor*[15 57 60 15], ...
	             'FontSize',FontScaling*10,  'FontWeight','bold', ...
	             'HorizontalAlignment','left', ...
	             'BackgroundColor',frameclr, 'ForegroundColor','black');

h.parallel(1) = uicontrol(h.fig, 'Style','edit', 'String',' ', ...
	             'Units','Points',  'Position',PixelFactor*[80 55 80 20], ...
	             'FontSize',FontScaling*9,  'FontWeight','bold', ...
	             'HorizontalAlignment','left', ...
	             'BackgroundColor',figclr, 'ForegroundColor','black',...
				 'CallBack','axesmui(''numbercheck'')');

h.parallel(2) = uicontrol(h.fig, 'Style','edit', 'String',' ', ...
	             'Units','Points',  'Position',PixelFactor*[170 55 80 20], ...
	             'FontSize',FontScaling*9,  'FontWeight','bold', ...
	             'HorizontalAlignment','left', ...
	             'BackgroundColor',figclr, 'ForegroundColor','black',...
				 'CallBack','axesmui(''numbercheck'')');

%  Aspect Control

uicontrol(h.fig, 'Style','frame', ...
	             'Units','Points',  'Position',PixelFactor*[275 50 250 30], ...
	             'FontSize',FontScaling*10,  'FontWeight','bold', ...
	             'BackgroundColor',frameclr, 'ForegroundColor','black');

h.aspectlbl = uicontrol(h.fig, 'Style','text', 'String','Aspect', ...
	             'Units','Points',  'Position',PixelFactor*[280 55 60 15], ...
	             'FontSize',FontScaling*10,  'FontWeight','bold', ...
	             'HorizontalAlignment','left', ...
	             'BackgroundColor',frameclr, 'ForegroundColor','black');

h.aspect = uicontrol(h.fig, 'Style','popup', 'String','normal|transverse', ...
	             'Units','Points',  'Position',PixelFactor*[345 55 120 20], ...
	             'FontSize',FontScaling*10,  'FontWeight','bold', ...
	             'HorizontalAlignment','left', ...
	             'BackgroundColor',figclr, 'ForegroundColor','black');

%  Button Bar

h.framebtn = uicontrol(h.fig, 'Style','push', 'String','Frame', ...
	             'Units','Points',  'Position',PixelFactor*[10 05 50 30], ...
	             'FontSize',FontScaling*10,  'FontWeight','bold', ...
	             'HorizontalAlignment','left', 'Interruptible','on', ...
	             'BackgroundColor',figclr, 'ForegroundColor','black',...
				 'CallBack','axesmui(''MainDialog'',''Frame'')');

h.gridbtn = uicontrol(h.fig, 'Style','push', 'String','Grid', ...
	             'Units','Points',  'Position',PixelFactor*[60 05 50 30], ...
	             'FontSize',FontScaling*10,  'FontWeight','bold', ...
	             'HorizontalAlignment','left', 'Interruptible','on', ...
	             'BackgroundColor',figclr, 'ForegroundColor','black',...
				 'CallBack','axesmui(''MainDialog'',''Grid'')');

h.labelbtn = uicontrol(h.fig, 'Style','push', 'String','Labels', ...
	             'Units','Points',  'Position',PixelFactor*[110 05 50 30], ...
	             'FontSize',FontScaling*10,  'FontWeight','bold', ...
	             'HorizontalAlignment','left', 'Interruptible','on', ...
	             'BackgroundColor',figclr, 'ForegroundColor','black',...
				 'CallBack','axesmui(''MainDialog'',''Labels'')');

h.defaultbtn = uicontrol(h.fig, 'Style','push', 'String','Fill in', ...
	             'Units','Points',  'Position',PixelFactor*[190 05 50 30], ...
	             'FontSize',FontScaling*10,  'FontWeight','bold', ...
	             'HorizontalAlignment','left', 'Interruptible','on', ...
	             'BackgroundColor',figclr, 'ForegroundColor','black',...
				 'CallBack','axesmui(''MainDialog'',''Default'')');

h.resetbtn = uicontrol(h.fig, 'Style','push', 'String','Reset', ...
	             'Units','Points',  'Position',PixelFactor*[240 05 50 30], ...
	             'FontSize',FontScaling*10,  'FontWeight','bold', ...
	             'HorizontalAlignment','left', 'Interruptible','on', ...
	             'BackgroundColor',figclr, 'ForegroundColor','black',...
				 'CallBack','axesmui(''MainDialog'',''Reset'')');

%  Apply, Help and Cancel Buttons

h.apply = uicontrol(h.fig, 'Style','push', 'String','Apply', ...
	             'Units','Points',  'Position',PixelFactor*[330 05 60 30], ...
	             'FontSize',FontScaling*12,  'FontWeight','bold', ...
	             'HorizontalAlignment','left', ...
	             'BackgroundColor',figclr, 'ForegroundColor','black',...
				 'CallBack','uiresume');

h.help = uicontrol(h.fig, 'Style','push', 'String','Help', ...
	             'Units','Points',  'Position',PixelFactor*[395 05 60 30], ...
	             'FontSize',FontScaling*12,  'FontWeight','bold', ...
	             'HorizontalAlignment','left', ...
	             'BackgroundColor',figclr, 'ForegroundColor','black',...
				 'CallBack','maphlp3(''initialize'',''axesmui'')');

h.cancel = uicontrol(h.fig, 'Style','push', 'String','Cancel', ...
	             'Units','Points',  'Position',PixelFactor*[460 05 60 30], ...
	             'FontSize',FontScaling*12,  'FontWeight','bold', ...
	             'HorizontalAlignment','left', ...
	             'BackgroundColor',figclr, 'ForegroundColor','black',...
				 'CallBack','uiresume');


%  Set up linked edit field user data for the numbercheck callback

set(h.maplat,'UserData',h.maplat)
set(h.maplon,'UserData',h.maplon)
set(h.frmlat,'UserData',h.frmlat)
set(h.frmlon,'UserData',h.frmlon)

%  Save the GUI handles

set(h.fig,'Visible','on','UserData',h)


%*****************************************************************************
%*****************************************************************************
%*****************************************************************************


function h = FrameBox(mstruct)

%  FRAMEBOX will create the dialog box for editting Map Frame properties


%  Initialize the frame radio buttons

if strcmp(lower(mstruct.frame),'on');    frameINIT = [1 0];
	else;                                frameINIT = [0 1];
end

%  Construct the color rgb values and popup menu items and
%  determine the edge or face colors

LineColors  = strvcat('custom','black','white','red','cyan','green',...
                      'yellow','blue','magenta','none');
edgeclr.rgb = [NaN NaN NaN; 0 0 0; 1 1 1; 1 0 0; 0 1 1;
                            0 1 0; 1 1 0; 0 0 1; 1 0 1;
							2 0 0];   % '2' signals  or 'none'
edgeclr.val = mstruct.fedgecolor;
faceclr.rgb = edgeclr.rgb;
faceclr.val = mstruct.ffacecolor;

%  Determine the initial value for the edge and face color popup menu

if ~ischar(edgeclr.val)
     edgepopup = find(edgeclr.rgb(:,1) == edgeclr.val(1) & ...
                      edgeclr.rgb(:,2) == edgeclr.val(2) & ...
                      edgeclr.rgb(:,3) == edgeclr.val(3) );
     if isempty(edgepopup); edgepopup = 1;  end      %  Initial custom color
else
     edgepopup = strmatch(edgeclr.val,LineColors);
	 if all(edgeclr.rgb(edgepopup,:)>=0 & edgeclr.rgb(edgepopup,:)<=1)
	      edgeclr.val = edgeclr.rgb(edgepopup,:);
	 end
end

if ~ischar(faceclr.val)
     facepopup = find(faceclr.rgb(:,1) == faceclr.val(1) & ...
                      faceclr.rgb(:,2) == faceclr.val(2) & ...
                      faceclr.rgb(:,3) == faceclr.val(3) );
     if isempty(facepopup); facepopup = 1;  end      %  Initial custom color
else
     facepopup = strmatch(faceclr.val,LineColors);
	 if all(faceclr.rgb(facepopup,:)>=0 & faceclr.rgb(facepopup,:)<=1)
	      faceclr.val = faceclr.rgb(facepopup,:);
	 end
end

%  Create the figure window.  Make window visible only after
%  all objects are drawn

PixelFactor = guifactm('pixels');
FontScaling =  guifactm('fonts');

h.fig = dialog('NumberTitle','off',   'Name','Map Frame Properties', ...
       'Units','Points', 'Position',PixelFactor*72*[2 3 4 3], ...
       'Resize','off',        'Visible','off');
%
%adjust window position if corners are offscreen
%
shiftwin(h.fig)

colordef(h.fig,'white')
figclr = get(h.fig,'Color');
frameclr = brighten(figclr,0.5);

%  Frame On/Off frame, title and radio buttons

h.frame = uicontrol(h.fig, 'Style','frame', ...
	'Units','normalized', 'Position',[0.05 0.82 0.90 0.14], ...
	'BackgroundColor',frameclr, 'ForegroundColor','black');

h.frametitle = uicontrol(h.fig, 'Style','text', 'String', 'Frame:', ...
	'Units','normalized', 'Position',[0.10 0.86 0.30 0.07], ...
	'BackgroundColor',frameclr, 'ForegroundColor','black', ...
	'FontSize',FontScaling*10,  'FontWeight','bold', 'HorizontalAlignment','left');

h.frameon = uicontrol(h.fig, 'Style','radio', 'String', 'On', ...
	'Units','normalized', 'Position',[0.45 0.85 0.20 0.08], ...
	'BackgroundColor',frameclr, 'ForegroundColor','black', 'Value',frameINIT(1), ...
	'FontSize',FontScaling*10,  'FontWeight', 'bold', 'HorizontalAlignment','left', ...
	'CallBack',...
	'set(gco,''Value'',1);set(get(gco,''UserData''),''Value'',0)');

h.frameoff = uicontrol(h.fig, 'Style','radio', 'String', 'Off', ...
	'Units','normalized', 'Position',[0.70 0.85 0.20 0.08], ...
	'BackgroundColor',frameclr, 'ForegroundColor','black', 'Value',frameINIT(2), ...
	'FontSize',FontScaling*10,  'FontWeight','bold', 'HorizontalAlignment','left', ...
	'CallBack',...
	'set(gco,''Value'',1);set(get(gco,''UserData''),''Value'',0)');

set(h.frameon,'UserData',h.frameoff)     %  Set userdata for callback operation
set(h.frameoff,'UserData',h.frameon)

%  Face and Edge Color Frame, Text and Popups

h.colorframe = uicontrol(h.fig, 'Style','frame', ...
	'Units','normalized', 'Position',[0.05 0.52 0.90 0.25], ...
	'BackgroundColor',frameclr, 'ForegroundColor','black');

h.facetext = uicontrol(h.fig,'Style','Text', 'String','Face Color:', ...
              'Units','Normalized', 'Position',[0.10  0.67  0.30  0.07], ...
			  'FontWeight','bold',  'FontSize',FontScaling*10, ...
			  'HorizontalAlignment','left', ...
			  'ForegroundColor','black', 'BackgroundColor',frameclr);

h.facecolor = uicontrol(h.fig,'Style','Popup', 'String',LineColors, ...
              'Units','Normalized', 'Position',[0.45  0.66  0.40  0.08], ...
			  'FontWeight','bold',  'FontSize',FontScaling*10, ...
 			  'HorizontalAlignment','center', 'Value',facepopup, ...
              'UserData',faceclr, ...
			  'ForegroundColor','black', 'BackgroundColor',figclr,...
			  'Interruptible','on', 'CallBack','clrpopup');

h.edgetext = uicontrol(h.fig,'Style','Text', 'String','Edge Color:', ...
              'Units','Normalized', 'Position',[0.10  0.56  0.30  0.07], ...
			  'FontWeight','bold',  'FontSize',FontScaling*10, ...
			  'HorizontalAlignment','left', ...
			  'ForegroundColor','black', 'BackgroundColor',frameclr);

h.edgecolor = uicontrol(h.fig,'Style','Popup', 'String',LineColors, ...
              'Units','Normalized', 'Position',[0.45  0.55  0.40  0.08], ...
			  'FontWeight','bold',  'FontSize',FontScaling*10, ...
 			  'HorizontalAlignment','center', 'Value',edgepopup, ...
              'UserData',edgeclr, ...
			  'ForegroundColor','black', 'BackgroundColor',figclr,...
			  'Interruptible','on', 'CallBack','clrpopup');

%  Edge Width & Fill Points frame, text and edit boxes

h.colorframe = uicontrol(h.fig, 'Style','frame', ...
	'Units','normalized', 'Position',[0.05 0.22 0.90 0.25], ...
	'BackgroundColor',frameclr, 'ForegroundColor','black');

h.widthtext = uicontrol(h.fig,'Style','Text', 'String','Edge Width (pts):', ...
              'Units','Normalized', 'Position',[0.10  0.37  0.40  0.07], ...
			  'FontWeight','bold',  'FontSize',FontScaling*10, ...
			  'HorizontalAlignment','left', ...
			  'ForegroundColor','black', 'BackgroundColor',frameclr);

h.widthedit = uicontrol(h.fig,'Style','edit', 'String',mstruct.flinewidth, ...
              'Units','Normalized', 'Position',[0.55  0.36  0.30  0.08], ...
			  'FontWeight','bold',  'FontSize',FontScaling*9, ...
			  'HorizontalAlignment','left', 'Max',1, ...
			  'ForegroundColor','black', 'BackgroundColor',figclr,...
			  'CallBack','axesmui(''numbercheck'')');

h.filltext = uicontrol(h.fig,'Style','Text', 'String','Points per Edge:', ...
              'Units','Normalized', 'Position',[0.10  0.26  0.40  0.07], ...
			  'FontWeight','bold',  'FontSize',FontScaling*10, ...
			  'HorizontalAlignment','left', ...
			  'ForegroundColor','black', 'BackgroundColor',frameclr);

h.filledit = uicontrol(h.fig,'Style','edit', 'String',mstruct.ffill, ...
              'Units','Normalized', 'Position',[0.55  0.25  0.30  0.08], ...
			  'FontWeight','bold',  'FontSize',FontScaling*9, ...
			  'HorizontalAlignment','left', 'Max',1, ...
			  'ForegroundColor','black', 'BackgroundColor',figclr,...
			  'CallBack','axesmui(''numbercheck'')');

%  Buttons to exit the modal dialog box

h.apply = uicontrol(h.fig, 'Style','push', 'String','Accept', ...
	        'Units','normalized', 'Position',[0.10  0.02 0.24  0.15], ...
	        'ForegroundColor','black', 'BackgroundColor',figclr, ...
	        'FontName','Helvetica', 'FontSize',FontScaling*10, 'FontWeight','bold', ...
	        'CallBack','uiresume');

h.help = uicontrol(h.fig, 'Style','push', 'String','Help', ...
	        'Units','normalized', 'Position',[0.38  0.02 0.24  0.15], ...
	        'ForegroundColor','black', 'BackgroundColor',figclr, ...
	        'FontName','Helvetica', 'FontSize',FontScaling*10, 'FontWeight','bold', ...
	        'Interruptible','on', 'CallBack','maphlp3(''initialize'',''frame'')');

h.cancel = uicontrol(h.fig, 'Style','push', 'String','Cancel', ...
	        'Units','normalized', 'Position',[0.66  0.02 0.24  0.15], ...
	        'ForegroundColor','black', 'BackgroundColor',figclr, ...
	        'FontName','Helvetica', 'FontSize',FontScaling*10, 'FontWeight','bold', ...
	        'CallBack','uiresume');

%  Save the object handles and turn window on

set(h.fig,'Visible','on','UserData',h)


%*****************************************************************************
%*****************************************************************************
%*****************************************************************************


function h = GridBox(mstruct)

%  GRIDBOX will create the dialog box for editting Map Grid properties


%  Initialize the grid radio buttons

if strcmp(mstruct.grid,'on');    gridINIT = [1 0];
	else;                        gridINIT = [0 1];
end

%  Construct the line style property strings and popup menu items

LineStyleChar = strvcat('-','--',':','-.','none');
gridstyle     = strvcat('Solid','Dashed','Dotted','Dash-Dot','None');
gridval       = strmatch(mstruct.glinestyle,LineStyleChar,'exact');
if isempty(gridval);  gridval = 5;   end

%  Construct the color rgb values and popup menu items and
%  determine the line colors

LineColors  = strvcat('custom','black','white','red','cyan','green',...
                      'yellow','blue','magenta');
gridclr.rgb = [NaN NaN NaN; 0 0 0; 1 1 1; 1 0 0; 0 1 1;
                            0 1 0; 1 1 0; 0 0 1; 1 0 1];
gridclr.val = mstruct.gcolor;

%  Determine the initial value for the edge and face color popup menu

if ~ischar(gridclr.val)
     gridpopup = find(gridclr.rgb(:,1) == gridclr.val(1) & ...
                      gridclr.rgb(:,2) == gridclr.val(2) & ...
                      gridclr.rgb(:,3) == gridclr.val(3) );
     if isempty(gridpopup); gridpopup = 1;  end      %  Initial custom color
else
     gridpopup = strmatch(gridclr.val,LineColors);
end

%  Create the figure window.  Make window visible only after
%  all objects are drawn

PixelFactor = guifactm('pixels');
FontScaling =  guifactm('fonts');

h.fig = dialog('NumberTitle','off',   'Name','Map Grid Properties', ...
       'Units','Points', 'Position',PixelFactor*72*[2 3 4 3], ...
       'Resize','off',        'Visible','off');

%
%adjust window position if corners are offscreen
%
shiftwin(h.fig)

colordef(h.fig,'white')
figclr = get(h.fig,'Color');
frameclr = brighten(figclr,0.5);

%  Create a hidden axes to store the current map structure.  This is
%  necessary since the meridians and parallels button may alter
%  the properties while waiting on this dialog label.

h.hiddenaxes = axes('Visible','off','UserData',mstruct);

%  Grid On/Off frame, title and radio buttons

h.gridframe = uicontrol(h.fig, 'Style','frame', ...
	'Units','normalized', 'Position',[0.05 0.82 0.90 0.14], ...
	'BackgroundColor',frameclr, 'ForegroundColor','black');

h.gridtitle = uicontrol(h.fig, 'Style','text', 'String', 'Grid:', ...
	'Units','normalized', 'Position',[0.10 0.86 0.30 0.07], ...
	'BackgroundColor',frameclr, 'ForegroundColor','black', ...
	'FontSize',FontScaling*10,  'FontWeight','bold', 'HorizontalAlignment','left');

h.gridon = uicontrol(h.fig, 'Style','radio', 'String', 'On', ...
	'Units','normalized', 'Position',[0.45 0.85 0.20 0.08], ...
	'BackgroundColor',frameclr, 'ForegroundColor','black', 'Value',gridINIT(1), ...
	'FontSize',FontScaling*10,  'FontWeight', 'bold', 'HorizontalAlignment','left', ...
	'CallBack',...
	'set(gco,''Value'',1);set(get(gco,''UserData''),''Value'',0)');

h.gridoff = uicontrol(h.fig, 'Style','radio', 'String', 'Off', ...
	'Units','normalized', 'Position',[0.70 0.85 0.20 0.08], ...
	'BackgroundColor',frameclr, 'ForegroundColor','black', 'Value',gridINIT(2), ...
	'FontSize',FontScaling*10,  'FontWeight','bold', 'HorizontalAlignment','left', ...
	'CallBack',...
	'set(gco,''Value'',1);set(get(gco,''UserData''),''Value'',0)');

set(h.gridon,'UserData',h.gridoff)     %  Set userdata for callback operation
set(h.gridoff,'UserData',h.gridon)

%  Grid Properties, Text and Popups

h.propframe = uicontrol(h.fig, 'Style','frame', ...
	'Units','normalized', 'Position',[0.05 0.30 0.90 0.47], ...
	'BackgroundColor',frameclr, 'ForegroundColor','black');

h.colortext = uicontrol(gcf,'Style','Text', 'String','Color:', ...
              'Units','Normalized', 'Position',[0.10  0.67  0.30  0.07], ...
			  'FontWeight','bold',  'FontSize',FontScaling*10, ...
			  'HorizontalAlignment','left', ...
			  'ForegroundColor','black', 'BackgroundColor',frameclr);

h.color = uicontrol(h.fig,'Style','Popup', 'String',LineColors, ...
              'Units','Normalized', 'Position',[0.45  0.66  0.40  0.08], ...
			  'FontWeight','bold',  'FontSize',FontScaling*10, ...
 			  'HorizontalAlignment','center', 'Value',gridpopup, ...
              'UserData',gridclr, ...
			  'ForegroundColor','black', 'BackgroundColor',figclr,...
			  'Interruptible','on', 'CallBack','clrpopup');

h.styletext = uicontrol(h.fig,'Style','Text', 'String','Style:', ...
              'Units','Normalized', 'Position',[0.10  0.56  0.30  0.07], ...
			  'FontWeight','bold',  'FontSize',FontScaling*10, ...
			  'HorizontalAlignment','left', ...
			  'ForegroundColor','black', 'BackgroundColor',frameclr);

h.style = uicontrol(h.fig,'Style','Popup', 'String',gridstyle, ...
              'Units','Normalized', 'Position',[0.45  0.55  0.40  0.08], ...
			  'FontWeight','bold',  'FontSize',FontScaling*10, ...
 			  'HorizontalAlignment','center', 'Value',gridval, ...
              'UserData',LineStyleChar, ...
			  'ForegroundColor','black', 'BackgroundColor',figclr);

h.widthtext = uicontrol(h.fig,'Style','Text', 'String','Line Width (pts):', ...
              'Units','Normalized', 'Position',[0.10  0.45  0.40  0.07], ...
			  'FontWeight','bold',  'FontSize',FontScaling*10, ...
			  'HorizontalAlignment','left', ...
			  'ForegroundColor','black', 'BackgroundColor',frameclr);

h.widthedit = uicontrol(h.fig,'Style','edit', 'String',mstruct.glinewidth, ...
              'Units','Normalized', 'Position',[0.55  0.44  0.30  0.08], ...
			  'FontWeight','bold',  'FontSize',FontScaling*9, ...
			  'HorizontalAlignment','left', 'Max',1, ...
			  'ForegroundColor','black', 'BackgroundColor',figclr,...
			  'CallBack','axesmui(''numbercheck'')');

h.alttext = uicontrol(h.fig,'Style','Text', 'String','Grid Altitude:', ...
              'Units','Normalized', 'Position',[0.10  0.34  0.40  0.07], ...
			  'FontWeight','bold',  'FontSize',FontScaling*10, ...
			  'HorizontalAlignment','left', ...
			  'ForegroundColor','black', 'BackgroundColor',frameclr);

h.altedit = uicontrol(h.fig,'Style','edit', 'String',mstruct.galtitude, ...
              'Units','Normalized', 'Position',[0.55  0.33  0.30  0.08], ...
			  'FontWeight','bold',  'FontSize',FontScaling*9, ...
			  'HorizontalAlignment','left', 'Max',1, ...
			  'ForegroundColor','black', 'BackgroundColor',figclr,...
			  'CallBack','axesmui(''numbercheck'')');

%  Parallels and Meridians Button

h.settings = uicontrol(h.fig, 'Style','push', ...
            'String','Meridian and Parallel Settings', ...
	        'Units','normalized', 'Position',[0.10  0.16 0.80  0.11], ...
	        'ForegroundColor','black', 'BackgroundColor',figclr, ...
	        'FontName','Helvetica', 'FontSize',FontScaling*10, 'FontWeight','bold', ...
	        'Interruptible','on', ...
			'CallBack','axesmui(''MainDialog'',''Meridian&Parallel'')');

%  Buttons to exit the modal dialog box

h.apply = uicontrol(h.fig, 'Style','push', 'String','Accept', ...
	        'Units','normalized', 'Position',[0.10  0.01 0.24  0.12], ...
	        'ForegroundColor','black', 'BackgroundColor',figclr, ...
	        'FontName','Helvetica', 'FontSize',FontScaling*10, 'FontWeight','bold', ...
	        'CallBack','uiresume');

h.help = uicontrol(h.fig, 'Style','push', 'String','Help', ...
	        'Units','normalized', 'Position',[0.38  0.01 0.24  0.12], ...
	        'ForegroundColor','black', 'BackgroundColor',figclr, ...
	        'FontName','Helvetica', 'FontSize',FontScaling*10, 'FontWeight','bold', ...
	        'Interruptible','on', 'CallBack','maphlp3(''initialize'',''grid'')');

h.cancel = uicontrol(h.fig, 'Style','push', 'String','Cancel', ...
	        'Units','normalized', 'Position',[0.66  0.01 0.24  0.12], ...
	        'ForegroundColor','black', 'BackgroundColor',figclr, ...
	        'FontName','Helvetica', 'FontSize',FontScaling*10, 'FontWeight','bold', ...
	        'CallBack','uiresume');

%  Save the object handles and turn window on

set(h.fig,'Visible','on', 'UserData',h)  %  UserData needed for settings callback


%*****************************************************************************
%*****************************************************************************
%*****************************************************************************


function h = GridPropBox(mstruct)

%  GRIDPROPBOX will create the dialog box for editting Meridian and
%  Parallel properties


%  Initialize the meridian and parallel radio buttons

if strcmp(mstruct.mlinevisible,'on');    meridianINIT = [1 0];
	else;                                meridianINIT = [0 1];
end
if strcmp(mstruct.plinevisible,'on');    parallelINIT = [1 0];
	else;                                parallelINIT = [0 1];
end

%  Create the figure window.  Make window visible only after
%  all objects are drawn

PixelFactor = guifactm('pixels');
FontScaling =  guifactm('fonts');

h.fig = dialog('NumberTitle','off',   'Name','Meridian and Parallel Properties', ...
       'Units','Points', 'Position',PixelFactor*72*[1 2 7 4], ...
       'Resize','off',        'Visible','off');

%
%adjust window position if corners are offscreen
%
shiftwin(h.fig)

colordef(h.fig,'white')
figclr = get(h.fig,'Color');
frameclr = brighten(figclr,0.5);

%  Meridians frame and title

h.mframe = uicontrol(h.fig, 'Style','frame', ...
	'Units','normalized', 'Position',[0.02 0.17 0.47 0.79], ...
	'BackgroundColor',frameclr, 'ForegroundColor','black');

h.mtitle = uicontrol(h.fig, 'Style','text', 'String', 'Meridians:', ...
	'Units','normalized', 'Position',[0.05 0.87 0.20 0.07], ...
	'BackgroundColor',frameclr, 'ForegroundColor','black', ...
	'FontSize',FontScaling*10,  'FontWeight','bold', 'HorizontalAlignment','left');

h.meridianon = uicontrol(h.fig, 'Style','radio', 'String', 'On', ...
   'Units','normalized', 'Position',[0.26 0.87 0.1 0.08], ...
	'BackgroundColor',frameclr, 'ForegroundColor','black', 'Value',meridianINIT(1), ...
	'FontSize',FontScaling*10,  'FontWeight', 'bold', 'HorizontalAlignment','left', ...
	'CallBack',...
	'set(gco,''Value'',1);set(get(gco,''UserData''),''Value'',0)');

h.meridianoff = uicontrol(h.fig, 'Style','radio', 'String', 'Off', ...
   'Units','normalized', 'Position',[0.35 0.87 0.1 0.08], ...
	'BackgroundColor',frameclr, 'ForegroundColor','black', 'Value',meridianINIT(2), ...
	'FontSize',FontScaling*10,  'FontWeight','bold', 'HorizontalAlignment','left', ...
	'CallBack',...
	'set(gco,''Value'',1);set(get(gco,''UserData''),''Value'',0)');

set(h.meridianon,'UserData',h.meridianoff)     %  Set userdata for callback operation
set(h.meridianoff,'UserData',h.meridianon)

%  Longitude location text and edit

h.longtext = uicontrol(h.fig,'Style','text', 'String','Longitude Location(s):', ...
              'Units','Normalized', 'Position',[0.05  0.79  0.30  0.07], ...
			  'FontWeight','bold',  'FontSize',FontScaling*10, ...
			  'HorizontalAlignment','left', ...
			  'ForegroundColor','black', 'BackgroundColor',frameclr);

h.longedit = uicontrol(h.fig,'Style','edit', 'String',num2str(mstruct.mlinelocation(:)'), ...
              'Units','Normalized', 'Position',[0.05  0.66  0.41  0.12], ...
			  'FontWeight','bold',  'FontSize',FontScaling*10, ...
			  'HorizontalAlignment','left',  'Max',2, ...
			  'ForegroundColor','black', 'BackgroundColor',figclr,...
			  'CallBack','axesmui(''numbercheck'')');

%  Limits text, labels and edits

h.mlimits = uicontrol(h.fig, 'Style','text', 'String', 'Latitude Limits:', ...
	'Units','normalized', 'Position',[0.05 0.58 0.30 0.07], ...
	'BackgroundColor',frameclr, 'ForegroundColor','black', ...
	'FontSize',FontScaling*10,  'FontWeight','bold', 'HorizontalAlignment','left');

h.mlimitedit = uicontrol(h.fig,'Style','edit', 'String',num2str(mstruct.mlinelimit), ...
              'Units','Normalized', 'Position',[0.05  0.50  0.41  0.07], ...
			  'FontWeight','bold',  'FontSize',FontScaling*10, ...
			  'HorizontalAlignment','left', 'Max',1,...
			  'ForegroundColor','black', 'BackgroundColor',figclr,...
			  'CallBack','axesmui(''numbercheck'')');

%  Longitude exceptions text and edits

h.longexctext = uicontrol(h.fig,'Style','text', 'String','Longitude Exceptions:', ...
              'Units','Normalized', 'Position',[0.05  0.41  0.30  0.07], ...
			  'FontWeight','bold',  'FontSize',FontScaling*10, ...
			  'HorizontalAlignment','left', ...
			  'ForegroundColor','black', 'BackgroundColor',frameclr);

h.longexcedit = uicontrol(h.fig,'Style','edit', 'String',num2str(mstruct.mlineexception), ...
              'Units','Normalized', 'Position',[0.05  0.28  0.41  0.12], ...
			  'FontWeight','bold',  'FontSize',FontScaling*10, ...
			  'HorizontalAlignment','left',  'Max',2, ...
			  'ForegroundColor','black', 'BackgroundColor',figclr,...
			  'CallBack','axesmui(''numbercheck'')');

%  Points per meridian text and edit

h.mfilltext = uicontrol(h.fig,'Style','text', 'String','Points per Line:', ...
              'Units','Normalized', 'Position',[0.05  0.19  0.21  0.07], ...
			  'FontWeight','bold',  'FontSize',FontScaling*10, ...
			  'HorizontalAlignment','left', ...
			  'ForegroundColor','black', 'BackgroundColor',frameclr);

h.mfilledit = uicontrol(h.fig,'Style','edit', 'String',mstruct.mlinefill, ...
              'Units','Normalized', 'Position',[0.27  0.20  0.19  0.07], ...
			  'FontWeight','bold',  'FontSize',FontScaling*10, ...
			  'HorizontalAlignment','left', 'Max',1, ...
			  'ForegroundColor','black', 'BackgroundColor',figclr,...
			  'CallBack','axesmui(''numbercheck'')');

%  Parallels frame and title

h.pframe = uicontrol(h.fig, 'Style','frame', ...
	'Units','normalized', 'Position',[0.51 0.17 0.47 0.79], ...
	'BackgroundColor',frameclr, 'ForegroundColor','black');

h.ptitle = uicontrol(h.fig, 'Style','text', 'String', 'Parallels:', ...
	'Units','normalized', 'Position',[0.54 0.87 0.20 0.07], ...
	'BackgroundColor',frameclr, 'ForegroundColor','black', ...
	'FontSize',FontScaling*10,  'FontWeight','bold', 'HorizontalAlignment','left');

h.parallelon = uicontrol(h.fig, 'Style','radio', 'String', 'On', ...
   'Units','normalized', 'Position',[0.75 0.87 0.10 0.08], ...
	'BackgroundColor',frameclr, 'ForegroundColor','black', 'Value',parallelINIT(1), ...
	'FontSize',FontScaling*10,  'FontWeight', 'bold', 'HorizontalAlignment','left', ...
	'CallBack',...
	'set(gco,''Value'',1);set(get(gco,''UserData''),''Value'',0)');

h.paralleloff = uicontrol(h.fig, 'Style','radio', 'String', 'Off', ...
   'Units','normalized', 'Position',[0.84 0.87 0.10 0.08], ...
	'BackgroundColor',frameclr, 'ForegroundColor','black', 'Value',parallelINIT(2), ...
	'FontSize',FontScaling*10,  'FontWeight','bold', 'HorizontalAlignment','left', ...
	'CallBack',...
	'set(gco,''Value'',1);set(get(gco,''UserData''),''Value'',0)');

set(h.parallelon,'UserData',h.paralleloff)     %  Set userdata for callback operation
set(h.paralleloff,'UserData',h.parallelon)

%  Latitude location text and edit

h.lattext = uicontrol(h.fig,'Style','text', 'String','Latitude Location(s):', ...
              'Units','Normalized', 'Position',[0.54  0.79  0.30  0.07], ...
			  'FontWeight','bold',  'FontSize',FontScaling*10, ...
			  'HorizontalAlignment','left', ...
			  'ForegroundColor','black', 'BackgroundColor',frameclr);

h.latedit = uicontrol(h.fig,'Style','edit', 'String',num2str(mstruct.plinelocation), ...
              'Units','Normalized', 'Position',[0.54  0.66  0.41  0.12], ...
			  'FontWeight','bold',  'FontSize',FontScaling*10, ...
			  'HorizontalAlignment','left',  'Max',2, ...
			  'ForegroundColor','black', 'BackgroundColor',figclr,...
			  'CallBack','axesmui(''numbercheck'')');

%  Limits text, labels and edits

h.plimits = uicontrol(h.fig, 'Style','text', 'String', 'Longitude Limits:', ...
	'Units','normalized', 'Position',[0.54 0.58 0.30 0.07], ...
	'BackgroundColor',frameclr, 'ForegroundColor','black', ...
	'FontSize',FontScaling*10,  'FontWeight','bold', 'HorizontalAlignment','left');

h.plimitedit = uicontrol(h.fig,'Style','edit', 'String',num2str(mstruct.plinelimit), ...
              'Units','Normalized', 'Position',[0.54  0.50  0.41  0.07], ...
			  'FontWeight','bold',  'FontSize',FontScaling*10, ...
			  'HorizontalAlignment','left', 'Max',1,...
			  'ForegroundColor','black', 'BackgroundColor',figclr,...
			  'CallBack','axesmui(''numbercheck'')');

%  Latitude exceptions text and edits

h.latexctext = uicontrol(h.fig,'Style','text', 'String','Latitude Exceptions:', ...
              'Units','Normalized', 'Position',[0.54  0.41  0.30  0.07], ...
			  'FontWeight','bold',  'FontSize',FontScaling*10, ...
			  'HorizontalAlignment','left', ...
			  'ForegroundColor','black', 'BackgroundColor',frameclr);

h.latexcedit = uicontrol(h.fig,'Style','edit', 'String',num2str(mstruct.plineexception), ...
              'Units','Normalized', 'Position',[0.54  0.28  0.41  0.12], ...
			  'FontWeight','bold',  'FontSize',FontScaling*10, ...
			  'HorizontalAlignment','left',  'Max',2, ...
			  'ForegroundColor','black', 'BackgroundColor',figclr,...
			  'CallBack','axesmui(''numbercheck'')');

%  Points per parallel text and edit

h.pfilltext = uicontrol(h.fig,'Style','text', 'String','Points per Line:', ...
              'Units','Normalized', 'Position',[0.54  0.19  0.21  0.07], ...
			  'FontWeight','bold',  'FontSize',FontScaling*10, ...
			  'HorizontalAlignment','left', ...
			  'ForegroundColor','black', 'BackgroundColor',frameclr);

h.pfilledit = uicontrol(h.fig,'Style','edit', 'String',mstruct.plinefill, ...
              'Units','Normalized', 'Position',[0.76  0.20  0.19  0.07], ...
			  'FontWeight','bold',  'FontSize',FontScaling*10, ...
			  'HorizontalAlignment','left', 'Max',1, ...
			  'ForegroundColor','black', 'BackgroundColor',figclr,...
			  'CallBack','axesmui(''numbercheck'')');

%  Buttons to exit the modal dialog box

h.apply = uicontrol(h.fig, 'Style','push', 'String','Accept', ...
	        'Units','normalized', 'Position',[0.28  0.03 0.12  0.10], ...
	        'ForegroundColor','black', 'BackgroundColor',figclr, ...
	        'FontName','Helvetica', 'FontSize',FontScaling*10, 'FontWeight','bold', ...
	        'CallBack','uiresume');

h.help = uicontrol(h.fig, 'Style','push', 'String','Help', ...
	        'Units','normalized', 'Position',[0.44  0.03 0.12  0.10], ...
	        'ForegroundColor','black', 'BackgroundColor',figclr, ...
	        'FontName','Helvetica', 'FontSize',FontScaling*10, 'FontWeight','bold', ...
	        'Interruptible','on', 'CallBack','maphlp3(''initialize'',''gridsetting'')');

h.cancel = uicontrol(h.fig, 'Style','push', 'String','Cancel', ...
	        'Units','normalized', 'Position',[0.60  0.03 0.12  0.10], ...
	        'ForegroundColor','black', 'BackgroundColor',figclr, ...
	        'FontName','Helvetica', 'FontSize',FontScaling*10, 'FontWeight','bold', ...
	        'CallBack','uiresume');

%  Turn window on

set(h.fig,'Visible','on','UserData',h)


%*****************************************************************************
%*****************************************************************************
%*****************************************************************************


function h = LabelBox(mstruct)

%  LABELBOX will create the dialog box for editting Map Label properties


%  Initialize the meridian and parallel radio buttons

if strcmp(mstruct.meridianlabel,'on');    meridianINIT = [1 0];
	else;                                 meridianINIT = [0 1];
end
if strcmp(mstruct.parallellabel,'on');    parallelINIT = [1 0];
	else;                                 parallelINIT = [0 1];
end

%  Initialize the label format popup menu

labelformats = strvcat('compass','signed','none');
formatindx = strmatch(mstruct.labelformat,labelformats);

%  Initialize the label format popup menu

labelunits = strvcat('degrees','dm','dms','radians');
unitindx = strmatch(mstruct.labelunits,labelunits,'exact');

%  Construct the color rgb values and popup menu items and
%  determine the line colors

FontColors  = strvcat('custom','black','white','red','cyan','green',...
                      'yellow','blue','magenta');
fontclr.rgb = [NaN NaN NaN; 0 0 0; 1 1 1; 1 0 0; 0 1 1;
                            0 1 0; 1 1 0; 0 0 1; 1 0 1];
fontclr.val = mstruct.fontcolor;

%  Determine the initial value for the edge and face color popup menu

if ~ischar(fontclr.val)
     fontpopup = find(fontclr.rgb(:,1) == fontclr.val(1) & ...
                      fontclr.rgb(:,2) == fontclr.val(2) & ...
                      fontclr.rgb(:,3) == fontclr.val(3) );
     if isempty(fontpopup); fontpopup = 1;  end      %  Initial custom color
else
     fontpopup = strmatch(fontclr.val,FontColors);
end

%  Initialize the font unit popup menu

fontunits = strvcat('inches','centimeters','normalized','points','pixels');
fontunitsindx = strmatch(mstruct.fontunits,fontunits);

%  Determine the font weight popup menu value

weights = strvcat('normal','bold','demi','light');
wtindx = strmatch(mstruct.fontweight,weights);

%  Determine the font angle popup menu value

angles = strvcat('normal','italic','oblique');
anglindx = strmatch(mstruct.fontangle,angles);


%  Create the figure window.  Make window visible only after
%  all objects are drawn

PixelFactor = guifactm('pixels');
FontScaling =  guifactm('fonts');

h.fig = dialog('NumberTitle','off',   'Name','Map Label Properties', ...
       'Units','Points', 'Position',PixelFactor*72*[2 2.5 5 3.5], ...
       'Resize','off',        'Visible','on');

%
%adjust window position if corners are offscreen
%
shiftwin(h.fig)

colordef(h.fig,'white')
figclr = get(h.fig,'Color');
frameclr = brighten(figclr,0.5);

%  Create a hidden axes to store the current map structure.  This is
%  necessary since the meridians and parallels button may alter
%  the properties while waiting on this dialog window.

h.hiddenaxes = axes('Visible','off','UserData',mstruct);

%  Label frame

h.labelframe = uicontrol(h.fig, 'Style','frame', ...
	'Units','normalized', 'Position',[0.05 0.75 0.90 0.21], ...
	'BackgroundColor',frameclr, 'ForegroundColor','black');

%  Meridian label title and radio buttons

h.meridiantitle = uicontrol(h.fig, 'Style','text', 'String', 'Meridian:', ...
	'Units','normalized', 'Position',[0.07 0.87 0.17 0.07], ...
	'BackgroundColor',frameclr, 'ForegroundColor','black', ...
	'FontSize',FontScaling*10,  'FontWeight','bold', 'HorizontalAlignment','right');

h.meridianon = uicontrol(h.fig, 'Style','radio', 'String', 'On', ...
   'Units','normalized', 'Position',[0.25 0.87 0.12 0.08], ...
	'BackgroundColor',frameclr, 'ForegroundColor','black', 'Value',meridianINIT(1), ...
   'FontSize',FontScaling*9,  'FontWeight', 'bold', 'HorizontalAlignment','left', ...
	'CallBack',...
	'set(gco,''Value'',1);set(get(gco,''UserData''),''Value'',0)');

h.meridianoff = uicontrol(h.fig, 'Style','radio', 'String', 'Off', ...
   'Units','normalized', 'Position',[0.37 0.87 0.12 0.08], ...
	'BackgroundColor',frameclr, 'ForegroundColor','black', 'Value',meridianINIT(2), ...
   'FontSize',FontScaling*9,  'FontWeight','bold', 'HorizontalAlignment','left', ...
	'CallBack',...
	'set(gco,''Value'',1);set(get(gco,''UserData''),''Value'',0)');

set(h.meridianon,'UserData',h.meridianoff)     %  Set userdata for callback operation
set(h.meridianoff,'UserData',h.meridianon)

%  Parallel label title and radio buttons

h.paralleltitle = uicontrol(h.fig, 'Style','text', 'String', 'Parallel:', ...
	'Units','normalized', 'Position',[0.52 0.87 0.17 0.07], ...
	'BackgroundColor',frameclr, 'ForegroundColor','black', ...
	'FontSize',FontScaling*10,  'FontWeight','bold', 'HorizontalAlignment','right');

h.parallelon = uicontrol(h.fig, 'Style','radio', 'String', 'On', ...
   'Units','normalized', 'Position',[0.70 0.87 0.12 0.08], ...
	'BackgroundColor',frameclr, 'ForegroundColor','black', 'Value',parallelINIT(1), ...
	'FontSize',FontScaling*10,  'FontWeight', 'bold', 'HorizontalAlignment','left', ...
	'CallBack',...
	'set(gco,''Value'',1);set(get(gco,''UserData''),''Value'',0)');

h.paralleloff = uicontrol(h.fig, 'Style','radio', 'String', 'Off', ...
   'Units','normalized', 'Position',[0.82 0.87 0.12 0.08], ...
	'BackgroundColor',frameclr, 'ForegroundColor','black', 'Value',parallelINIT(2), ...
	'FontSize',FontScaling*10,  'FontWeight','bold', 'HorizontalAlignment','left', ...
	'CallBack',...
	'set(gco,''Value'',1);set(get(gco,''UserData''),''Value'',0)');

set(h.parallelon,'UserData',h.paralleloff)     %  Set userdata for callback operation
set(h.paralleloff,'UserData',h.parallelon)

%  Label format title and popup

h.formattitle = uicontrol(h.fig, 'Style','text', 'String', 'Format:', ...
	'Units','normalized', 'Position',[0.07 0.77 0.17 0.07], ...
	'BackgroundColor',frameclr, 'ForegroundColor','black', ...
	'FontSize',FontScaling*10,  'FontWeight','bold', 'HorizontalAlignment','right');

h.format = uicontrol(h.fig, 'Style','popup', 'String', labelformats, ...
	'Units','normalized', 'Position',[0.25 0.77 0.24 0.08], ...
	'BackgroundColor',frameclr, 'ForegroundColor','black', 'Value',formatindx, ...
	'FontSize',FontScaling*10,  'FontWeight', 'bold', 'HorizontalAlignment','left');

%  Label units title and popup

h.unitstitle = uicontrol(h.fig, 'Style','text', 'String', 'Units:', ...
	'Units','normalized', 'Position',[0.52 0.77 0.17 0.07], ...
	'BackgroundColor',frameclr, 'ForegroundColor','black', ...
	'FontSize',FontScaling*10,  'FontWeight','bold', 'HorizontalAlignment','right');

h.units = uicontrol(h.fig, 'Style','popup', 'String', labelunits, ...
	'Units','normalized', 'Position',[0.70 0.77 0.23 0.08], ...
	'BackgroundColor',frameclr, 'ForegroundColor','black', 'Value',unitindx, ...
	'FontSize',FontScaling*10,  'FontWeight', 'bold', 'HorizontalAlignment','left');

%  Font frame

h.labelframe = uicontrol(h.fig, 'Style','frame', ...
	'Units','normalized', 'Position',[0.05 0.38 0.90 0.32], ...
	'BackgroundColor',frameclr, 'ForegroundColor','black');

%  Font Name Edit Box

h.fonttitle = uicontrol(h.fig, 'Style','push', 'String', 'Font:', ...
	'Units','normalized', 'Position',[0.07 0.60 0.12 0.08], ...
	'BackgroundColor',frameclr, 'ForegroundColor','black', ...
	'FontSize',FontScaling*10,  'FontWeight','bold', ...
	'HorizontalAlignment','center', 'Interruptible','on',...
	'CallBack','axesmui(''MainDialog'',''FontPreview'')');

h.fontedit = uicontrol(h.fig, 'Style','edit', 'String', mstruct.fontname, ...
	'Units','normalized', 'Position',[0.20 0.60 0.34 0.08], ...
	'BackgroundColor',frameclr, 'ForegroundColor','black', ...
	'FontSize',FontScaling*10,  'FontWeight', 'bold', 'HorizontalAlignment','left');

%  Font Size Edit Box

h.sizetitle = uicontrol(h.fig, 'Style','text', 'String', 'Size:', ...
	'Units','normalized', 'Position',[0.59 0.60 0.10 0.07], ...
	'BackgroundColor',frameclr, 'ForegroundColor','black', ...
	'FontSize',FontScaling*10,  'FontWeight','bold', 'HorizontalAlignment','right');

h.sizeedit = uicontrol(h.fig, 'Style','edit', 'String', mstruct.fontsize, ...
	'Units','normalized', 'Position',[0.71 0.60 0.15 0.08], ...
	'BackgroundColor',frameclr, 'ForegroundColor','black', ...
	'FontSize',FontScaling*10,  'FontWeight', 'bold', 'HorizontalAlignment','left',...
	'CallBack','axesmui(''numbercheck'')');

%  Font Color title and popup menu

h.fontclrtitle = uicontrol(h.fig, 'Style','text', 'String', 'Color:', ...
	'Units','normalized', 'Position',[0.07 0.50 0.14 0.07], ...
	'BackgroundColor',frameclr, 'ForegroundColor','black', ...
	'FontSize',FontScaling*10,  'FontWeight','bold', 'HorizontalAlignment','right');

h.fontclr = uicontrol(h.fig, 'Style','popup', 'String', FontColors, ...
	'Units','normalized', 'Position',[0.22 0.50 0.25 0.08], ...
	'BackgroundColor',frameclr, 'ForegroundColor','black', 'Value',fontpopup,...
	'FontSize',FontScaling*10,  'FontWeight', 'bold', 'HorizontalAlignment','left',...
	'UserData',fontclr, 'CallBack','clrpopup');

%  Font units title and popup menu

h.fontunitstitle = uicontrol(h.fig, 'Style','text', 'String', 'Units:', ...
	'Units','normalized', 'Position',[0.50 0.50 0.12 0.07], ...
	'BackgroundColor',frameclr, 'ForegroundColor','black', ...
	'FontSize',FontScaling*10,  'FontWeight','bold', 'HorizontalAlignment','right');

h.fontunits = uicontrol(h.fig, 'Style','popup', 'String', fontunits, ...
	'Units','normalized', 'Position',[0.63 0.50 0.30 0.08], ...
	'BackgroundColor',frameclr, 'ForegroundColor','black', 'Value',fontunitsindx,...
	'FontSize',FontScaling*10,  'FontWeight', 'bold', 'HorizontalAlignment','left');

%  Font Weight title and popup menu

h.fontwttitle = uicontrol(h.fig, 'Style','text', 'String', 'Weight:', ...
	'Units','normalized', 'Position',[0.07 0.40 0.14 0.07], ...
	'BackgroundColor',frameclr, 'ForegroundColor','black', ...
	'FontSize',FontScaling*10,  'FontWeight','bold', 'HorizontalAlignment','right');

h.fontwt = uicontrol(h.fig, 'Style','popup', 'String', weights, ...
	'Units','normalized', 'Position',[0.22 0.40 0.25 0.08], ...
	'BackgroundColor',frameclr, 'ForegroundColor','black', 'Value',wtindx,...
	'FontSize',FontScaling*10,  'FontWeight', 'bold', 'HorizontalAlignment','left');

%  Font angle title and popup menu

h.fontangtitle = uicontrol(h.fig, 'Style','text', 'String', 'Angle:', ...
	'Units','normalized', 'Position',[0.50 0.40 0.12 0.07], ...
	'BackgroundColor',frameclr, 'ForegroundColor','black', ...
	'FontSize',FontScaling*10,  'FontWeight','bold', 'HorizontalAlignment','right');

h.fontangle = uicontrol(h.fig, 'Style','popup', 'String', angles, ...
	'Units','normalized', 'Position',[0.63 0.40 0.30 0.08], ...
	'BackgroundColor',frameclr, 'ForegroundColor','black', 'Value',anglindx,...
	'FontSize',FontScaling*10,  'FontWeight', 'bold', 'HorizontalAlignment','left');

%  Parallels and Meridians Button

h.settings = uicontrol(h.fig, 'Style','push', ...
            'String','Meridian and Parallel Settings', ...
	        'Units','normalized', 'Position',[0.10  0.20 0.80  0.11], ...
	        'ForegroundColor','black', 'BackgroundColor',figclr, ...
	        'FontName','Helvetica', 'FontSize',FontScaling*10, 'FontWeight','bold', ...
	        'Interruptible','on', ...
			'CallBack','axesmui(''MainDialog'',''LabelSettings'')');

%  Buttons to exit the modal dialog box

h.apply = uicontrol(h.fig, 'Style','push', 'String','Accept', ...
	        'Units','normalized', 'Position',[0.10  0.03 0.24  0.12], ...
	        'ForegroundColor','black', 'BackgroundColor',figclr, ...
	        'FontName','Helvetica', 'FontSize',FontScaling*10, 'FontWeight','bold', ...
	        'CallBack','uiresume');

h.help = uicontrol(h.fig, 'Style','push', 'String','Help', ...
	        'Units','normalized', 'Position',[0.38  0.03 0.24  0.12], ...
	        'ForegroundColor','black', 'BackgroundColor',figclr, ...
	        'FontName','Helvetica', 'FontSize',FontScaling*10, 'FontWeight','bold', ...
	        'Interruptible','on', 'CallBack','maphlp3(''initialize'',''labels'')');

h.cancel = uicontrol(h.fig, 'Style','push', 'String','Cancel', ...
	        'Units','normalized', 'Position',[0.66  0.03 0.24  0.12], ...
	        'ForegroundColor','black', 'BackgroundColor',figclr, ...
	        'FontName','Helvetica', 'FontSize',FontScaling*10, 'FontWeight','bold', ...
	        'CallBack','uiresume');

%  Save the object handles and turn window on

set(h.fig,'Visible','on', 'UserData',h)  %  UserData needed for settings callback


%*****************************************************************************
%*****************************************************************************
%*****************************************************************************


function h = LabelPropBox(mstruct)

%  LABELPROPBOX will create the dialog box for editting Meridian and
%  Parallel label properties


%  Create the figure window.  Make window visible only after
%  all objects are drawn

PixelFactor = guifactm('pixels');
FontScaling =  guifactm('fonts');

h.fig = dialog('NumberTitle','off',   'Name','Meridian and Parallel Label Properties', ...
       'Units','Points', 'Position',PixelFactor*72*[1 3 7 3], ...
       'Resize','off',        'Visible','on');

%
%adjust window position if corners are offscreen
%
shiftwin(h.fig)

colordef(h.fig,'white')
figclr = get(h.fig,'Color');
frameclr = brighten(figclr,0.5);

%  Meridian labels frame and title

h.mframe = uicontrol(h.fig, 'Style','frame', ...
	'Units','normalized', 'Position',[0.02 0.27 0.47 0.69], ...
	'BackgroundColor',frameclr, 'ForegroundColor','black');

h.mtitle = uicontrol(h.fig, 'Style','text', 'String', 'Meridians Labels:', ...
	'Units','normalized', 'Position',[0.05 0.86 0.25 0.08], ...
	'BackgroundColor',frameclr, 'ForegroundColor','black', ...
	'FontSize',FontScaling*10,  'FontWeight','bold', 'HorizontalAlignment','left');

%  Longitude location text and edit

h.mlocatetext = uicontrol(h.fig,'Style','text', 'String','Longitude Location(s):', ...
              'Units','Normalized', 'Position',[0.05  0.76  0.30  0.08], ...
			  'FontWeight','bold',  'FontSize',FontScaling*10, ...
			  'HorizontalAlignment','left', ...
			  'ForegroundColor','black', 'BackgroundColor',frameclr);

h.mlocateedit = uicontrol(h.fig,'Style','edit', 'String',num2str(mstruct.mlabellocation(:)'), ...
              'Units','Normalized', 'Position',[0.05  0.63  0.41  0.12], ...
			  'FontWeight','bold',  'FontSize',FontScaling*10, ...
			  'HorizontalAlignment','left',  'Max',2, ...
			  'ForegroundColor','black', 'BackgroundColor',figclr,...
			  'CallBack','axesmui(''numbercheck'')');

%  Display latitude title, popup and edit

h.mparalleltext = uicontrol(h.fig,'Style','text', 'String','Display Parallel:', ...
              'Units','Normalized', 'Position',[0.05  0.53  0.30  0.08], ...
			  'FontWeight','bold',  'FontSize',FontScaling*10, ...
			  'HorizontalAlignment','left', ...
			  'ForegroundColor','black', 'BackgroundColor',frameclr);

h.mparallelpopup = uicontrol(h.fig,'Style','popup', 'String','north|south|equator', ...
              'Units','Normalized', 'Position',[0.05  0.42  0.20  0.09], ...
			  'FontWeight','bold',  'FontSize',FontScaling*10, ...
			  'HorizontalAlignment','left',  'Value',1, ...
			  'ForegroundColor','black', 'BackgroundColor',figclr,...
			  'CallBack','set(get(gco,''UserData''),''String'','''')');

h.mparalleledit = uicontrol(h.fig,'Style','edit', ...
              'String',mstruct.mlabelparallel, ...
              'Units','Normalized', 'Position',[0.27  0.42  0.18  0.09], ...
			  'FontWeight','bold',  'FontSize',FontScaling*10, ...
			  'HorizontalAlignment','left',  'Max',1, ...
			  'ForegroundColor','black', 'BackgroundColor',figclr,...
			  'UserData',h.mparallelpopup,...
			  'CallBack',['if isempty(get(gco,''String''));',...
			             'set(get(gco,''UserData''),''Enable'',''on'');',...
						 'else;set(get(gco,''UserData''),''Enable'',''off'');end']);
set(h.mparallelpopup,'UserData',h.mparalleledit)

%  Meridian rounding title and edit

h.mroundtext = uicontrol(h.fig,'Style','text', 'String','Decimal Round:', ...
              'Units','Normalized', 'Position',[0.05  0.29  0.20  0.08], ...
			  'FontWeight','bold',  'FontSize',FontScaling*10, ...
			  'HorizontalAlignment','left', ...
			  'ForegroundColor','black', 'BackgroundColor',frameclr);

h.mroundedit = uicontrol(h.fig,'Style','edit', 'String',mstruct.mlabelround, ...
              'Units','Normalized', 'Position',[0.27  0.29  0.10  0.09], ...
			  'FontWeight','bold',  'FontSize',FontScaling*10, ...
			  'HorizontalAlignment','left',  'Max',1, ...
			  'ForegroundColor','black', 'BackgroundColor',figclr,...
			  'CallBack','axesmui(''numbercheck'')');

%  Parallel labels frame and title

h.pframe = uicontrol(h.fig, 'Style','frame', ...
	'Units','normalized', 'Position',[0.51 0.27 0.47 0.69], ...
	'BackgroundColor',frameclr, 'ForegroundColor','black');

h.ptitle = uicontrol(h.fig, 'Style','text', 'String', 'Parallel Labels:', ...
	'Units','normalized', 'Position',[0.54 0.86 0.25 0.08], ...
	'BackgroundColor',frameclr, 'ForegroundColor','black', ...
	'FontSize',FontScaling*10,  'FontWeight','bold', 'HorizontalAlignment','left');

%  Longitude location text and edit

h.plocatetext = uicontrol(h.fig,'Style','text', 'String','Latitude Location(s):', ...
              'Units','Normalized', 'Position',[0.54  0.76  0.30  0.08], ...
			  'FontWeight','bold',  'FontSize',FontScaling*10, ...
			  'HorizontalAlignment','left', ...
			  'ForegroundColor','black', 'BackgroundColor',frameclr);

h.plocateedit = uicontrol(h.fig,'Style','edit', 'String',num2str(mstruct.plabellocation(:)'), ...
              'Units','Normalized', 'Position',[0.54  0.63  0.41  0.12], ...
			  'FontWeight','bold',  'FontSize',FontScaling*10, ...
			  'HorizontalAlignment','left',  'Max',2, ...
			  'ForegroundColor','black', 'BackgroundColor',figclr,...
			  'CallBack','axesmui(''numbercheck'')');

%  Display longitude title, popup and edit

h.pmeridiantext = uicontrol(h.fig,'Style','text', 'String','Display Meridian:', ...
              'Units','Normalized', 'Position',[0.54  0.53  0.30  0.08], ...
			  'FontWeight','bold',  'FontSize',FontScaling*10, ...
			  'HorizontalAlignment','left', ...
			  'ForegroundColor','black', 'BackgroundColor',frameclr);

h.pmeridianpopup = uicontrol(h.fig,'Style','popup', 'String','east|west|prime', ...
              'Units','Normalized', 'Position',[0.54  0.42  0.20  0.09], ...
			  'FontWeight','bold',  'FontSize',FontScaling*10, ...
			  'HorizontalAlignment','left',  'Value',1, ...
			  'ForegroundColor','black', 'BackgroundColor',figclr,...
			  'CallBack','set(get(gco,''UserData''),''String'','''')');

h.pmeridianedit = uicontrol(h.fig,'Style','edit', ...
              'String',mstruct.plabelmeridian, ...
              'Units','Normalized', 'Position',[0.76  0.42  0.18  0.09], ...
			  'FontWeight','bold',  'FontSize',FontScaling*10, ...
			  'HorizontalAlignment','left',  'Max',1, ...
			  'ForegroundColor','black', 'BackgroundColor',figclr,...
			  'UserData',h.pmeridianpopup,...
			  'CallBack',['if isempty(get(gco,''String''));',...
			             'set(get(gco,''UserData''),''Enable'',''on'');',...
						 'else;set(get(gco,''UserData''),''Enable'',''off'');end']);
set(h.pmeridianpopup,'UserData',h.pmeridianedit)

%  Parallel rounding title and edit

h.proundtext = uicontrol(h.fig,'Style','text', 'String','Decimal Round:', ...
              'Units','Normalized', 'Position',[0.54  0.29  0.20  0.08], ...
			  'FontWeight','bold',  'FontSize',FontScaling*10, ...
			  'HorizontalAlignment','left', ...
			  'ForegroundColor','black', 'BackgroundColor',frameclr);

h.proundedit = uicontrol(h.fig,'Style','edit', 'String',mstruct.plabelround, ...
              'Units','Normalized', 'Position',[0.76  0.29  0.10  0.09], ...
			  'FontWeight','bold',  'FontSize',FontScaling*10, ...
			  'HorizontalAlignment','left',  'Max',1, ...
			  'ForegroundColor','black', 'BackgroundColor',figclr,...
			  'CallBack','axesmui(''numbercheck'')');

%  Buttons to exit the modal dialog box

h.apply = uicontrol(h.fig, 'Style','push', 'String','Accept', ...
	        'Units','normalized', 'Position',[0.28  0.06 0.12  0.15], ...
	        'ForegroundColor','black', 'BackgroundColor',figclr, ...
	        'FontName','Helvetica', 'FontSize',FontScaling*10, 'FontWeight','bold', ...
	        'CallBack','uiresume');

h.help = uicontrol(h.fig, 'Style','push', 'String','Help', ...
	        'Units','normalized', 'Position',[0.44  0.06 0.12  0.15], ...
	        'ForegroundColor','black', 'BackgroundColor',figclr, ...
	        'FontName','Helvetica', 'FontSize',FontScaling*10, 'FontWeight','bold', ...
	        'Interruptible','on', 'CallBack','maphlp3(''initialize'',''labelsetting'')');

h.cancel = uicontrol(h.fig, 'Style','push', 'String','Cancel', ...
	        'Units','normalized', 'Position',[0.60  0.06 0.12  0.15], ...
	        'ForegroundColor','black', 'BackgroundColor',figclr, ...
	        'FontName','Helvetica', 'FontSize',FontScaling*10, 'FontWeight','bold', ...
	        'CallBack','uiresume');

%  Turn window on

set(h.fig,'Visible','on','UserData',h)


%*****************************************************************************
%*****************************************************************************
%*****************************************************************************

function mstruct = mapangles(mstruct,oldunits)

%MAPANGLES  Changes the angle units of a map structure
%
%  MAPANGLES changes the angle units of the appropriate elements of
%  a map structure from the oldunits (input) to the mstruct.angleunits
%  (new units).  This is necessary if a user changes the angle units
%  using the AXESMUI dialog.  This local function is identical to
%  mapangles contained in AXESM.  However, it was decided that it is
%  better to keep these two functions local, so as to ensure the
%  operation of the dialog independent of the AXESM/SETM command
%  line operation.


newunits = mstruct.angleunits;

mstruct.fixedorient    = angledim(mstruct.fixedorient,oldunits,newunits);
mstruct.maplatlimit    = angledim(mstruct.maplatlimit,oldunits,newunits);
mstruct.maplonlimit    = angledim(mstruct.maplonlimit,oldunits,newunits);
mstruct.mapparallels   = angledim(mstruct.mapparallels,oldunits,newunits);
mstruct.origin         = angledim(mstruct.origin,oldunits,newunits);
mstruct.flatlimit      = angledim(mstruct.flatlimit,oldunits,newunits);
mstruct.flonlimit      = angledim(mstruct.flonlimit,oldunits,newunits);
mstruct.mlineexception = angledim(mstruct.mlineexception,oldunits,newunits);
mstruct.mlinelimit     = angledim(mstruct.mlinelimit,oldunits,newunits);
mstruct.mlinelocation  = angledim(mstruct.mlinelocation,oldunits,newunits);
mstruct.plineexception = angledim(mstruct.plineexception,oldunits,newunits);
mstruct.plinelimit     = angledim(mstruct.plinelimit,oldunits,newunits);
mstruct.plinelocation  = angledim(mstruct.plinelocation,oldunits,newunits);
mstruct.mlabellocation = angledim(mstruct.mlabellocation,oldunits,newunits);
mstruct.mlabelparallel = angledim(mstruct.mlabelparallel,oldunits,newunits);
mstruct.plabellocation = angledim(mstruct.plabellocation,oldunits,newunits);
mstruct.plabelmeridian = angledim(mstruct.plabelmeridian,oldunits,newunits);
mstruct.trimlat        = angledim(mstruct.trimlat,oldunits,newunits);
mstruct.trimlon        = angledim(mstruct.trimlon,oldunits,newunits);


%*****************************************************************************
%*****************************************************************************
%*****************************************************************************

function mstruct = zoneupdate(mstruct)

%ZONEUPDATE  Changes all the properties associated with a zone update
%
%  ZONEUPDATE updates all the properties that are affected by a change in zone.
%  This function also updates these properties to the specified angle units.


zone = mstruct.zone;
angleunits = mstruct.angleunits;

if strcmp(mstruct.mapprojection,'utm')

	[ltlim,lnlim,txtmsg] = utmzone(zone);

	if isempty(txtmsg)

		mstruct.maplatlimit    = angledim(ltlim,'degrees',angleunits);
		mstruct.maplonlimit    = angledim(lnlim,'degrees',angleunits);
		mstruct.origin         = angledim([0 min(lnlim)+3 0],'degrees',angleunits);
		mstruct.flatlimit      = angledim(ltlim,'degrees',angleunits);

		if min(ltlim)>=0 & max(ltlim)>0		% zone in southern hemisphere
			mstruct.falsenorthing = 0;
		elseif min(ltlim)<0 & max(ltlim)<=0	% zone in northern hemisphere
			mstruct.falsenorthing = 1e6;
		else								% zone in both
			mstruct.falsenorthing = 0;		%* set to this for now
		end

	else
      eid = sprintf('%s:%s:invalidUTMZONE', getcomp, mfilename);
		error(eid,'%s',txtmsg)

	end

elseif strcmp(mstruct.mapprojection,'ups')

	if strmatch(mstruct.zone,'north')
		mstruct.zone	   	   = 'north';
		mstruct.trimlat   	   = angledim([-Inf 6],'degrees',angleunits);
		mstruct.maplatlimit    = angledim([84 90],'degrees',angleunits);
		mstruct.maplonlimit    = angledim([-180 180],'degrees',angleunits);
		mstruct.origin         = angledim([90 0 0],'degrees',angleunits);
		mstruct.flatlimit      = angledim([-Inf 6],'degrees',angleunits);
		mstruct.mlinelimit	   = angledim([84 89],'degrees',angleunits);
	elseif strmatch(mstruct.zone,'south')
		mstruct.zone	   	   = 'south';
		mstruct.trimlat   	   = angledim([-Inf 10],'degrees',angleunits);
		mstruct.maplatlimit    = angledim([-90 -80],'degrees',angleunits);
		mstruct.maplonlimit    = angledim([-180 180],'degrees',angleunits);
		mstruct.origin         = angledim([-90 0 0],'degrees',angleunits);
		mstruct.flatlimit      = angledim([-Inf 10],'degrees',angleunits);
		mstruct.mlinelimit	   = angledim([-89 -80],'degrees',angleunits);
	else
      eid = sprintf('%s:%s:invalidUPSZONE', getcomp, mfilename);
		error(eid,'%s','Incorrect UPS zone designation. Recognized zones are ''north'' and ''south''.')
	end

end


%*****************************************************************************
%*****************************************************************************
%*****************************************************************************

function [ptr,list] = geoidupdate(zone,geoid)

%GEOIDUPDATE  Update geoid definitions
%
%  GEOIDUPDATE returns a pointer to the geoid definition in the geoid list box.
%  It also highlights the geoid definitions particular to a UTM zone.


l1 = 'unit sphere|earth: sphere|earth: airy|earth: bessel|earth: clarke66|';
l2 = 'earth: clarke80|earth: everest|earth: grs80|earth: iau65|earth: iau68|';
l3 = 'earth: international|earth: krasovsky|earth: wgs60|earth: wgs66|earth: wgs72|';
l4 = 'sun: sphere|moon: sphere|mercury: sphere|venus: sphere|mars: sphere|';
l5 = 'mars: ellipsoid|jupiter: sphere|jupiter: ellipsoid|saturn: sphere|';
l6 = 'saturn: ellipsoid|uranus: sphere|uranus: ellipsoid|neptune: sphere|';
l7 = 'neptune: ellipsoid|pluto: sphere|user defined';
geoidlist = [l1 l2 l3 l4 l5 l6 l7];

indx = [find(geoidlist=='|') length(geoidlist)+1];
geoidvec = [1 0];
for n=1:length(indx)-2
	str = geoidlist(indx(n)+1:indx(n+1)-1);
	i = find(str==':');
	planet = str(1:i-1);
	param = str(i+2:length(str));
	if strcmp(param,'ellipsoid'), param = 'geoid'; end
	geoidvec(n+1,:) = almanac(planet,param);
end
tmpgeoid = geoid;
if ~isempty(zone),  tmpgeoid = [geoid(1)/1000 geoid(2)];  end
ptr = find(geoidvec(:,1)==tmpgeoid(1) & geoidvec(:,2)==tmpgeoid(2));
if isempty(ptr),	ptr = 31;	end

if ~isempty(zone) & length(zone)<=3

	[geoids,geoidstr] = utmgeoid(zone);

	ngeoids = length(geoids(:,1));

	for n=1:ngeoids
		i = find(geoidvec(:,1)==geoids(n,1)/1000 & geoidvec(:,2)==geoids(n,2));
		start(n) = indx(i-1);
	end

	start = fliplr(sort(start));

	list = geoidlist;
	for n=1:ngeoids
		list = [list(1:start(n)) '*' list(start(n)+1:length(list))];
	end

else

	list = geoidlist;

end
