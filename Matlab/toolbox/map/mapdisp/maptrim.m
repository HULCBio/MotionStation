function maptrim(varargin)

%MAPTRIM  Interactive trimming of a map data set
%
%  MAPTRIM(lat,long) will display the supplied data in a new
%  figure window.  Using the menu choices and interactive zooming,
%  a region of the map can be defined and the appropriate map data
%  variables saved in the workspace.  The inputs lat and long must
%  be vector map data.  If a patch map output is selected, then the
%  input lat and long must originally represent patch map data.
%
%  MAPTRIM(lat,long,'LineSpec') displays the vector map data using
%  the LineSpec string.
%
%  MAPTRIM(map,maplegend) displays the matrix map data in a new figure
%  window and allows a subset of this map to be selected and saved.  The
%  output map will be a regular matrix map.  Only even multiples of the
%  input map scale can be selected as output resolutions.
%
%  MAPTRIM(map,maplegend,'PropertyName',PropertyValue,...) displays the
%  matrix map data using the surface properties provided.  The 'Tag',
%  'UserData' and 'EdgeColor' properties can not be set.
%
%  See also MAPTRIML, MAPTRIMP, MAPTRIMS, COLORM, SEEDM


%  Copyright 1996-2003 The MathWorks, Inc.
% $Revision: 1.8.4.1 $
%  Written by:  E. Byrns, E. Brown


if nargin == 0
    error('Incorrect number of arguments')
elseif nargin == 1
    action = varargin{1};
else
    if isstr(varargin{1})
	    action = varargin{1};  varargin(1)=[];
	else
	    if isequal(size(varargin{1}),size(varargin{2}))  %  Vector maps
		     action = 'VectorInitialize';
	         lat = varargin{1};   lat = lat(:);
			 lon = varargin{2};   lon = lon(:);
		     varargin(1:2) = [];
        elseif ndims(varargin{1}) == 2 & min(size(varargin{1})) ~= 1 & ...
		       length(varargin{2}) == 3  %  Map/maplegend usage
		     action = 'MatrixInitialize';
	         map = varargin{1};
			 maplegend = varargin{2};    maplegend = maplegend(:)';
		     varargin(1:2) = [];
        else
              error('Incorrect inputs')
        end
    end
end


switch action
case 'VectorInitialize'    %  Plot the data in a new window
      h = figure('Name','Customize Map','CloseRequestFcn','maptrim(''close'')');
      if isempty(varargin)
	        plot(lon,lat,'Tag','OriginalLineMapData')
	  else
	        plot(lon,lat,varargin{:},'Tag','OriginalLineMapData')
	  end

	  xlabel('Longitude'); ylabel('Latitude')
      panzoom('on')

      hmenu = uimenu(h,'Label','Customize');   %  Add the menu items
	  uimenu(hmenu,'Label','Zoom Off','Callback','maptrim(''zoomoff'')')
	  uimenu(hmenu,'Label','Limits','Callback','maptrim(''limits'')')
	  hsub = uimenu(hmenu,'Label','Save As');
	  uimenu(hsub,'Label','Line',...
	              'Callback','maptrim(''vector'',''line'',char(who))')
	  uimenu(hsub,'Label','Patch',...
	              'Callback','maptrim(''vector'',''patch'',char(who))')
	  uimenu(hsub,'Label','Regular Surface',...
	              'Callback','maptrim(''surface'',char(who))')


case 'MatrixInitialize'    %  Plot the data in a new window
      h = figure('Name','Customize Map','CloseRequestFcn','maptrim(''close'')');
      [lat,lon] = meshgrat(map,maplegend);

      m = pcolor(lon,lat,map);
      if ~isempty(varargin);   set(m,varargin{:});    end
	  set(m,'Tag','OriginalMatrixMapData','EdgeColor','none','UserData',maplegend)

	  xlabel('Longitude'); ylabel('Latitude')
      panzoom('on')

      hmenu = uimenu(h,'Label','Customize');   %  Add the menu items
	  uimenu(hmenu,'Label','Zoom Off','Callback','maptrim(''zoomoff'')')
	  uimenu(hmenu,'Label','Limits','Callback','maptrim(''limits'')')
	  hsub = uimenu(hmenu,'Label','Save As');
	  uimenu(hsub,'Label','Regular Surface',...
	              'Callback','maptrim(''matrix'',char(who))')


case 'limits'     %  Set the latitude or longitude limits of the display

%  Get the map limits

      prompt={'Latitude Limits (eg: [#, #]):','Longitude Limits (eg: [#, #]):'};
      answer={['[' num2str(get(gca,'Ylim'),'%5.2f  ') ']' ],['[' num2str(get(gca,'Xlim'),'%5.2f  ') ']' ]};
      title='Enter the Map limits';
      lineNo=1;

	  while ~isempty(answer)   %  Prompt until correct, or cancel
	      answer=inputdlg(prompt,title,lineNo,answer);

          if ~isempty(answer)   % OK button pushed
              if ~isempty(answer{1})   %  Valid latitude limits?
			       latlim = str2num(answer{1});
				   if isempty(latlim) | length(latlim) ~= 2
				       latlim = [];
		               uiwait(errordlg('Latitude limits must be a 2 element vector',...
			                       'Customize Error','modal'))
				   end
			  else
			       latlim = get(gca,'Ylim');
			  end

              if ~isempty(answer{2})   %  Valid longitude limits?
			       lonlim = str2num(answer{2});
				   if isempty(lonlim) | length(lonlim) ~= 2
				       lonlim = [];
		               uiwait(errordlg('Longitude limits must be a 2 element vector',...
			                       'Customize Error','modal'))
				   end
			  else
			       lonlim = get(gca,'Xlim');
			  end

			  if ~isempty(latlim) & ~isempty(lonlim)
			       break
		      end
		  end
      end

      if isempty(answer);   return;   end   %  Cancel pushed

%  Set the map limits

      set(gca,'Xlim',sort(lonlim),'Ylim',sort(latlim))


case 'vector'     %  Save map as line or patch variables

%  Get the variable name inputs

      prompt={'Latitude Variable:','Longitude Variable:',...
	          'Resolution (blank is default):',...
			  'Latitude Limits (Optional):', 'Longitude Limits (Optional):'};
      answer={'lat','long','','',''};
      lineNo=1;
      switch varargin{1}
	      case 'line',   title='Enter the Line Map variable names';
	      case 'patch',  title='Enter the Patch Map variable names';
	  end


	  while ~isempty(answer)  %  Prompt until correct, or cancel
	      answer=inputdlg(prompt,title,lineNo,answer);

          breakflag = 1;
		  if ~isempty(answer)   % OK button pushed
              if isempty(answer{1}) | isempty(answer{2})
		           breakflag = 0;
				   uiwait(errordlg('Variable names must be supplied',...
			                       'Customize Error','modal'))
		      elseif ~isempty(answer{3}) & ...
			         (isempty(str2num(answer{3})) | length(str2num(answer{3})) ~= 1)
		           breakflag = 0;
				   uiwait(errordlg('Resolution must be a scalar or blank',...
			                       'Customize Error','modal'))
			  else
                   latmatch = strmatch(answer{1},varargin{2});
                   lonmatch = strmatch(answer{2},varargin{2});
				   if ~isempty(answer{4})
                       latlimmatch = strmatch(answer{4},varargin{2});
				   else
				       latlimmatch = [];
				   end
				   if ~isempty(answer{5})
                       lonlimmatch = strmatch(answer{5},varargin{2});
				   else
				       lonlimmatch = [];
				   end

                   if ~isempty(latmatch)    | ~isempty(lonmatch) | ...
				      ~isempty(latlimmatch) | ~isempty(lonlimmatch)
                        Btn=questdlg('Replace existing variables?', ...
 	                                 'Save Map Data', 'Yes','No','No');
                        if strcmp(Btn,'No');   breakflag = 0;  end
				  end
		      end
		  end

		  if breakflag;  break;   end
      end

      if isempty(answer);   return;   end   %  Cancel pushed
      latname    = answer{1};
      lonname    = answer{2};
      resolution = str2num(answer{3});
	  latlimname = answer{4};
      lonlimname = answer{5};

%  Extract and trim the map data
%  If a resolution is provided, extract a slightly larger region, then
%  ensure the resolution and then trim to the desired limits.  This will
%  prevent drop-offs at the edge of the map when a resolution is given

      hline = findobj(gca,'Type','line','Tag','OriginalLineMapData');
      lon = get(hline,'Xdata');   lonlim = get(gca,'Xlim');
      lat = get(hline,'Ydata');   latlim = get(gca,'Ylim');

      if ~isempty(resolution)
          latlim1 = latlim + [-10 10]*resolution;
          lonlim1 = lonlim + [-10 10]*resolution;
      else
          latlim1 = latlim;   lonlim1 = lonlim;
      end

      switch varargin{1}   %  Trim map, rough cut if resolution given
         case 'line',    [lat,lon] = maptriml(lat,lon,latlim1,lonlim1);
	     case 'patch',   [lat,lon] = maptrimp(lat,lon,latlim1,lonlim1);
      end

      if ~isempty(resolution)   %  Interpolate and retrim if necessary
          [lat,lon]= interpm(lat,lon,resolution);
          switch varargin{1}
             case 'line',    [lat,lon] = maptriml(lat,lon,latlim,lonlim);
	         case 'patch',   [lat,lon] = maptrimp(lat,lon,latlim,lonlim);
          end
      end

%  Save as variables in the base workspace

      assignin('base',latname,lat)
      assignin('base',lonname,lon)
      if ~isempty(latlimname);  assignin('base',latlimname,latlim);  end
      if ~isempty(lonlimname);  assignin('base',lonlimname,lonlim);  end

case 'surface'     %  Save map as regular surface map from vector data input

%  Get the variable name inputs

      prompt={'Map Variable:','Map Legend Variable:',...
	          'Scale (cells/degree):',...
			  'Latitude Limits (Optional):', 'Longitude Limits (Optional):'};
      answer={'map','maplegend','1','',''};
      lineNo=1;
      title='Enter the Surface Map variable names';


	  while ~isempty(answer)   %  Prompt until correct, or cancel
	      answer=inputdlg(prompt,title,lineNo,answer);

          breakflag = 1;
		  if ~isempty(answer)   % OK button pushed
              if isempty(answer{1}) | isempty(answer{2})
		           breakflag = 0;
				   uiwait(errordlg('Variable names must be supplied',...
			                       'Customize Error','modal'))
		      elseif isempty(str2num(answer{3})) | ...
			         length(str2num(answer{3})) ~= 1
		           breakflag = 0;
				   uiwait(errordlg('Scale must be a scalar',...
			                       'Customize Error','modal'))
			  else
                   mapmatch = strmatch(answer{1},varargin{1});
                   legmatch = strmatch(answer{2},varargin{1});

				   if ~isempty(answer{4})
                       latlimmatch = strmatch(answer{4},varargin{1});
				   else
				       latlimmatch = [];
				   end
				   if ~isempty(answer{5})
                       lonlimmatch = strmatch(answer{5},varargin{1});
				   else
				       lonlimmatch = [];
				   end

                   if ~isempty(mapmatch)    | ~isempty(legmatch) | ...
				      ~isempty(latlimmatch) | ~isempty(lonlimmatch)
                        Btn=questdlg('Replace existing variables?', ...
 	                                 'Save Map Data', 'Yes','No','No');
                        if strcmp(Btn,'No');   breakflag = 0;  end
				  end
		      end
		  end

		  if breakflag;  break;   end
      end

      if isempty(answer);   return;   end   %  Cancel pushed
      mapname    = answer{1};
	  legendname = answer{2};
      scale      = str2num(answer{3});
	  latlimname = answer{4};
      lonlimname = answer{5};

%  Extract and trim the map data
%  Trim to a region larger than the desired map (rough cut).  Then
%  interpolate to the desired resolution (1/scale).  Finally trim to
%  the specified map.  This prevents segments from terminating before
%  the edge of the map.  And it provides for connected segments throughout
%  the matrix map.

      hline = findobj(gca,'Type','line','Tag','OriginalLineMapData');
      lon = get(hline,'Xdata');   lonlim = get(gca,'Xlim');
      lat = get(hline,'Ydata');   latlim = get(gca,'Ylim');

      latlim1 = latlim + [-10 10]*(1/scale);
      lonlim1 = lonlim + [-10 10]*(1/scale);

      [lat,lon] = maptriml(lat,lon,latlim1,lonlim1);
      [lat,lon] = interpm(lat,lon,(0.9/scale));

      [map,maplegend] = zerom(latlim1,lonlim1,scale);
      map = imbedm(lat,lon,1,map,maplegend);    %  Make matrix map

	  [map,maplegend] = maptrims(map,maplegend,latlim,lonlim);

%  Save as variables in the base workspace

      assignin('base',mapname,map)
      assignin('base',legendname,maplegend)
      if ~isempty(latlimname);  assignin('base',latlimname,latlim);  end
      if ~isempty(lonlimname);  assignin('base',lonlimname,lonlim);  end

case 'matrix'     %  Save map as regular surface map from matrix data input

%  Extract the map data.  Maplegend(1) needed as a default input to
%  the dialog box

              hmap = findobj(gca,'Type','surface','Tag','OriginalMatrixMapData');
              lon = get(hmap,'Xdata');   lonlim = get(gca,'Xlim');
              lat = get(hmap,'Ydata');   latlim = get(gca,'Ylim');
              map = get(hmap,'Cdata');   maplegend = get(hmap,'UserData');

%  Get the variable name inputs

      prompt={'Map Variable:','Map Legend Variable:',...
	          'Scale (cells/degree):',...
			  'Latitude Limits (Optional):', 'Longitude Limits (Optional):'};
      answer={'map','maplegend',num2str(maplegend(1)),'',''};
      lineNo=1;
      title='Enter the Surface Map variable names';


	  while 1   %  Prompt until correct, or cancel
	      answer=inputdlg(prompt,title,lineNo,answer);

          trimflag = 1;
		  if ~isempty(answer)   % OK button pushed
              if isempty(answer{1}) | isempty(answer{2})
		           trimflag = 0;
				   uiwait(errordlg('Variable names must be supplied',...
			                       'Customize Error','modal'))
		      elseif isempty(str2num(answer{3})) | ...
			         length(str2num(answer{3})) ~= 1
		           trimflag = 0;
				   uiwait(errordlg('Scale must be a scalar',...
			                       'Customize Error','modal'))
			  else
                   mapmatch = strmatch(answer{1},varargin{1});
                   legmatch = strmatch(answer{2},varargin{1});
				   if ~isempty(answer{4})
                       latlimmatch = strmatch(answer{4},varargin{1});
				   else
				       latlimmatch = [];
				   end
				   if ~isempty(answer{5})
                       lonlimmatch = strmatch(answer{5},varargin{1});
				   else
				       lonlimmatch = [];
				   end

                   if ~isempty(mapmatch)    | ~isempty(legmatch) | ...
				      ~isempty(latlimmatch) | ~isempty(lonlimmatch)
                        Btn=questdlg('Replace existing variables?', ...
 	                                 'Save Map Data', 'Yes','No','No');
                        if strcmp(Btn,'No');   trimflag = 0;  end
				  end
		      end
		  end

		  if trimflag
              if isempty(answer);   return;   end   %  Cancel pushed
		      lasterr('')

              mapname    = answer{1};
	          legendname = answer{2};
              scale      = str2num(answer{3});
	          latlimname = answer{4};
              lonlimname = answer{5};

%  Trim the map data

              eval(['[submap,sublegend] = maptrims(map,maplegend,latlim,',...
			        'lonlim,scale);'],'uiwait(errordlg(lasterr))')

              if isempty(lasterr);  break;  end
		  end
      end

%  Save as variables in the base workspace

      assignin('base',mapname,submap)
      assignin('base',legendname,sublegend)
      if ~isempty(latlimname);  assignin('base',latlimname,latlim);  end
      if ~isempty(lonlimname);  assignin('base',lonlimname,lonlim);  end

case 'zoomoff'     %  Turn panzoom off
      hmenu = findobj(get(0,'CurrentFigure'),'type','uimenu','label','Zoom Off');

	  panzoom('off')
	  set(hmenu,'Label','Zoom On','Callback','maptrim(''zoomon'')')

case 'zoomon'      %  Turn panzoom on
      hmenu = findobj(get(0,'CurrentFigure'),'type','uimenu','label','Zoom On');

	  panzoom('on')
	  set(hmenu,'Label','Zoom Off','Callback','maptrim(''zoomoff'')')

case 'close'         %  Close figure
     ButtonName = questdlg('Are You Sure?','Confirm Closing','Yes','No','No');
     if strcmp(ButtonName,'Yes');   delete(get(0,'CurrentFigure'));   end
end
