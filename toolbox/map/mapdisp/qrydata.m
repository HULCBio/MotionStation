function qrydata(varargin)

%QRYDATA  Links data variables for interactive queries
%
%  QRYDATA(cellarray,...) provides a GUI to explore data sets
%  specified in the cellarray (see below).  X and Y coordinates
%  can be input and the data corresponding to this coordinate
%  is displayed.  In addition, the results of functional operations
%  using the (x,y) coordinate can be supplied, depending on the
%  definition of the cellarray.  Multiple cellarray inputs can be
%  provided, each specifying a data query to be performed.
%
%  QRYDATA(titlestr,cellarray,...) uses the string titlestr to
%  label the figure window.
%
%  QRYDATA(hndl,cellarray,...) and QRYDATA(hndl,titlestr,cellarray,...)
%  link the data queries to the axes specified by hndl.  In this
%  usage, coordinates of interest can then be specified by clicking
%  on the appropriate location of the axes specified by hndl.
%
%  The CELLARRAY input is used to define the type and data for the
%  query operation.  The first cell must contain the string used
%  to label the data line in the query window.  The second cell must
%  contain either one of the pre-defined query operations, or a valid
%  user-created function name.  The pre-defined operations are 'matrix',
%  'vector', 'mapmatrix' and 'mapvector'.
%
%  For the 'matrix' operation,  the query executes an interp2 command on
%  a data matrix.  The CELLARRAY input is {'label','matrix',x,y,z,'method'}.
%  The method string is optional (default is nearest).
%
%  For the 'vector' operation, the query executes an interp2 command
%  (method == 'nearest') on a data matrix to determine the value at
%  the specified x and y entry.  This value is then used as
%  to index the vector of desired data.  The CELLARRAY input is
%  {'label','vector',x,y,z,vector}.
%
%  For the 'mapmatrix' operation, the query executes a ltln2val command
%  on the supplied data matrix.  The CELLARRAY input is {'label',
%  'mapmatrix',map,maplegend,'method'}.  The method string is
%  optional (default is nearest).
%
%  For the 'mapvector' operation, the query executes an ltln2val command
%  (method == 'nearest') on a data matrix to determine the value at
%  the specified lat and lon entry.  This value is then used as
%  to index the vector of desired data.  The CELLARRAY input is
%  {'label','mapvector',map,maplegend,vector}.
%
%  If a user-created function name is supplied in the CELLARRAY, then
%  this must refer to an m-file of the form z = fcn(x,y,other arguments...).
%  The other arguments are the remaining elements (3 and above) of the
%  initial cell array.  The output z must be a scalar.

%  Copyright 1996-2003 The MathWorks, Inc.
%  $Revision: 1.9.4.1 $  $Date: 2003/08/01 18:22:27 $
%  Written by:  E. Byrns, E. Brown



%  Test the input arguments

if nargin == 0 | (nargin == 1 & ~isstr(varargin{1}))
    error('Incorrect number of arguments')

elseif nargin == 1
    action = varargin{1};

else
    action = 'initialize';
	if ~iscell(varargin{2})
	       hndl = varargin{1};   titlestr = varargin{2};   varargin(1:2) = [];

    elseif ~iscell(varargin{1})
           if isstr(varargin{1})
		          hndl = [];     titlestr = varargin{1};   varargin(1) = [];
		   else
		          hndl = varargin{1};     titlestr = [];   varargin(1) = [];
		   end
    else
	       hndl = [];       titlestr = [];
	end
end


%  Switch on the appropriate action


switch action
case 'initialize'
	if ~isempty(hndl) & ...
	       (max(size(hndl)) ~= 1 | ~ishandle(hndl) | ...
	           ~strcmp(get(hndl,'Type'),'axes'))
                error('Input argument must be  an axes handle')
	else
          qryinit(hndl,titlestr,varargin{:})
    end


case 'get'
    qryfig = gcf;  h = get(gcf,'UserData');

	axes(get(gco,'UserData'))
	if ismap;     [x,y] = inputm(1);
	    else;          [x,y] = ginput(1);
	end

	set(h(1),'String',roundn(x,-2),'UserData',roundn(x,-2));
	set(h(2),'String',roundn(y,-2),'UserData',roundn(x,-2));

    figure(qryfig);

case 'process'         %  The data linking is determined here

     h = get(gcf,'UserData');

	 x = str2num(get(h(1),'String'));
	 y = str2num(get(h(2),'String'));

	 for i = 3:length(h)
          cellarray = get(h(i),'UserData');
          fcn = cellarray{1};     cellarray(1) = [];

		  switch lower(fcn)
		  case 'matrix'      %  Matrix search
		       if length(cellarray) == 3
			        result = interp2(cellarray{1},cellarray{2},cellarray{3},x,y,...
					                 'nearest');
			   elseif length(cellarray) == 4
			        result = interp2(cellarray{1},cellarray{2},cellarray{3},x,y,...
					                 cellarray{4});
			   else
			        result = 'Incorrect MATRIX cell array';  warning(result)
			   end

		  case 'vector'      %  Indexed vector search
		       if length(cellarray) == 4
			        indx = round(interp2(cellarray{1},cellarray{2},cellarray{3},...
					                     x,y,'nearest'));
					if indx > 0 & indx <= prod(size(cellarray{4}))
					       result = cellarray{4}(indx,:);
					else
					       result = 'Index exceeds array length';  warning(result)
					end
			   else
			        result = 'Incorrect VECTOR cell array';  warning(result)
			   end

		  case 'mapvector'      %  Indexed map vector search
		       if length(cellarray) == 3
			        indx = round(ltln2val(cellarray{1},cellarray{2},x,y,'nearest'));
					if indx > 0 & indx <= prod(size(cellarray{3}))
					       result = cellarray{3}(indx,:);
					else
					       result = 'Index exceeds array length';  warning(result)
					end
			   else
			        result = 'Incorrect MAPVECTOR cell array';  warning(result)
			   end

		  case 'mapmatrix'      %  Map matrix search
		       if length(cellarray) == 2
			        result = ltln2val(cellarray{1},cellarray{2},x,y);
			   elseif length(cellarray) == 3
			        result = ltln2val(cellarray{1},cellarray{2},x,y,cellarray{3});
			   else
			        result = 'Incorrect MAPMATRIX cell array';  warning(result)
			   end

		  otherwise           %  User defined function search
		       if exist(fcn,'file') == 2
			        result = feval(fcn,x,y,cellarray{:});
               else
					result = 'Function not found';  warning(result)
			   end
		  end

		  set(h(i),'String',result)  %  Display the result
     end

case 'numcheck'     %  Check for valid number entries in the edit boxes
    if isempty(str2num(get(gco,'String')))
	       set(gco,'String',get(gco,'UserData'))
	else
	       set(gco,'UserData',str2num(get(gco,'String')))
	end

case 'close'     %  Close and return to associated figure (if appropriate)
    hndl = findobj(gcf,'Type','uicontrol','String','Close');
	fighndl = get(hndl,'UserData');
	delete(gcf)

    if ~isempty(fighndl) & ishandle(fighndl);   figure(fighndl);  end
end


%***************************************************************************
%***************************************************************************
%***************************************************************************


function qryinit(hndl,qrytitle,varargin)

%QRYINIT  Initializes the data query GUI
%
%  QRYINIT determines the properties of the object specified
%  by the input handle, creates the line editing GUI and
%  initializes all GUI objects to their correct value.
%
%  The input hndl must be empty or refer to a valid axes object.  This
%  is tested in the calling routine QRYDATA.


%  Default title and compute the box height

if isempty(qrytitle);   qrytitle = 'Data Query';   end
height   = (length(varargin) + 1)*0.4 + 0.7;

%  Compute the Pixel and Font Scaling Factors so
%  GUI figure windows and fonts look OK across all platforms

PixelFactor = guifactm('pixels');
FontScaling =  guifactm('fonts');

%  Draw the figure window

figh = figure('NumberTitle','off',   'Name',qrytitle, ...
       'Units','Points',  'Position',PixelFactor*72*[1 1 4 height], ...
       'Resize','on', 'CloseRequestFcn','qrydata(''close'')',...
	   'Visible','off');
colordef(figh,'white');
figclr = get(figh,'Color');

%  Push Buttons.  If an axes is associated, then display the
%  get button.  Otherwise, display the process button.

if isempty(hndl)
     uicontrol(gcf, 'Style','push', 'String','Process',...
		       'Units','Points',  'Position',PixelFactor*72*[0.6  0.1  1.2  0.4], ...
			   'FontWeight','bold',  'FontSize',FontScaling*10, ...
			   'CallBack','qrydata(''process'')' );

     uicontrol(gcf, 'Style','push', 'String','Close',...
		       'Units','Points',  'Position',PixelFactor*72*[2.4  0.1  1.2  0.4], ...
			   'FontWeight','bold',  'FontSize',FontScaling*10, ...
			   'CallBack','close' );
else
     uicontrol(gcf, 'Style','push', 'String','Get',...
		       'Units','Points',  'Position',PixelFactor*72*[0.6  0.1  1.2  0.4], ...
			   'FontWeight','bold',  'FontSize',FontScaling*10, ...
			   'UserData',hndl, 'CallBack','qrydata(''get'');qrydata(''process'')' );

     uicontrol(gcf, 'Style','push', 'String','Close',...
		       'Units','Points',  'Position',PixelFactor*72*[2.4  0.1  1.2  0.4], ...
			   'FontWeight','bold',  'FontSize',FontScaling*10, ...
			   'UserData',get(hndl,'Parent'), 'CallBack','close' );
end

%  Current location in x and y or latitude and longitude

if isempty(hndl) | ~ismap(hndl)
      str1 = 'Xloc:';    str2 = 'Yloc:';
else
      str1 = 'Lat:';     str2 = 'Lon:';
end

uicontrol(gcf, 'Style','Text', 'String',str1, ...
			   'Units','Points',  'Position',PixelFactor*72*[0.3  height-0.4  0.4  0.2],...
			   'FontWeight','bold',  'FontSize',FontScaling*10, ...
			   'HorizontalAlignment','right', 'Tag','NormalizeMe',...
			   'ForegroundColor','black', 'BackgroundColor',figclr);
uicontrol(gcf, 'Style','Text', 'String',str2,...
			   'Units','Points',  'Position',PixelFactor*72*[2.0  height-0.4  0.4  0.2],...
			   'FontWeight','bold',  'FontSize',FontScaling*10, ...
			   'HorizontalAlignment','right', 'Tag','NormalizeMe',...
			   'ForegroundColor','black', 'BackgroundColor',figclr);

%  Location edit boxes if no associated axes.  Otherwise, make
%  these objects simple text

if isempty(hndl)
    h(1) = uicontrol(gcf, 'Style','Edit', 'String','',...
			   'Units','Points',  'Position',PixelFactor*72*[0.8  height-0.425  1.0  0.25],...
			   'FontWeight','bold',  'FontSize',FontScaling*10, ...
			   'HorizontalAlignment','left', 'Tag','NormalizeMe',...
			   'ForegroundColor','black', 'BackgroundColor',figclr,...
			   'CallBack','qrydata(''numcheck'')');
    h(2) = uicontrol(gcf, 'Style','Edit', 'String','',...
			   'Units','Points',  'Position',PixelFactor*72*[2.5  height-0.425  1.0  0.25],...
			   'FontWeight','bold',  'FontSize',FontScaling*10, ...
			   'HorizontalAlignment','left', 'Tag','NormalizeMe',...
			   'ForegroundColor','black', 'BackgroundColor',figclr,...
			   'CallBack','qrydata(''numcheck'')');
else
    h(1) = uicontrol(gcf, 'Style','Text', 'String','',...
			   'Units','Points',  'Position',PixelFactor*72*[0.8  height-0.425  1.0  0.25],...
			   'FontWeight','bold',  'FontSize',FontScaling*10, ...
			   'HorizontalAlignment','left', 'Tag','NormalizeMe',...
			   'ForegroundColor','black', 'BackgroundColor',figclr);
    h(2) = uicontrol(gcf, 'Style','Text', 'String','',...
			   'Units','Points',  'Position',PixelFactor*72*[2.5  height-0.425  1.0  0.25],...
			   'FontWeight','bold',  'FontSize',FontScaling*10, ...
			   'HorizontalAlignment','left', 'Tag','NormalizeMe',...
			   'ForegroundColor','black', 'BackgroundColor',figclr);
end

%  Add the display titles and the display text objects (initially blank)

for i = 1:length(varargin)
         qrycell = varargin{i};    titlestr = qrycell{1};  qrycell(1) = [];
         uicontrol(gcf, 'Style','Text', 'String',titlestr, ...
		       'Units','Points',  'Position',PixelFactor*72*[0.5 height-0.4*(i+1) 1.2 0.2],...
			   'FontWeight','bold',  'FontSize',FontScaling*10, ...
			   'HorizontalAlign','left', 'Tag','NormalizeMe',...
			   'ForegroundColor','black', 'BackgroundColor',figclr);

          h(2+i) = uicontrol(gcf, 'Style','Text', 'String','',...
		       'Units','Points',  'Position',PixelFactor*72*[1.9 height-0.4*(i+1) 1.6 0.2],...
			   'FontWeight','bold',  'FontSize',FontScaling*10, ...
			   'HorizontalAlign','left', 'UserData',qrycell, ...
               'Tag','NormalizeMe',...
			   'ForegroundColor','black', 'BackgroundColor',figclr);
end

%  Switch to normalized units, then make the window visible

hndls = findobj(gcf,'Type','uicontrol','Tag','NormalizeMe');
set(hndls,'Units','Normalized');

set(gcf,'UserData',h,'Visible','on');

