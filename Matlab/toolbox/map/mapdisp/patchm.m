function [hndl,msg] = patchm(varargin)

%PATCHM  Project patch objects onto the current map axes
%
%  PATCHM(lat,lon,cdata) projects 2D patch objects onto the current
%  map axes.  The input latitude and longitude data must be in the same
%  units as specified in the current map axes.  The input cdata defines
%  the patch face color.  If the input vectors are NaN clipped, then
%  a single patch is drawn with multiple faces.  Unlike FILLM and
%  FILL3M, PATCHM will always add the patches to the current map,
%  regardless of the current hold state.
%
%  PATCHM(lat,lon,z,cdata) projects a 3D patch.
%
%  PATCHM(...,'PropertyName',PropertyValue,...) uses the patch
%  properties supplied to display the patch.  Except for xdata, ydata
%  and zdata, all patch properties available through PATCH are supported
%  by PATCHM.
%
%  h = PATCHM(...) returns the handles to the patch objects drawn.
%
%  [h,msg] = PATCHM(...) returns a string indicating any error encountered.
%
%  PATCHM, without any inputs, activates a GUI for projecting patches
%  onto the current axes.
%
%  See also FILLM, FILL3M, PATCHESM, PATCH

%  Copyright 1996-2003 The MathWorks, Inc.
%  Written by:  E. Byrns, E. Brown
%  $Revision: 1.16.4.1 $  $Date: 2003/08/01 18:19:12 $


if nargin == 0
    patchmui;   return

elseif nargin < 3
    msg = 'Incorrect number of arguments';
	if nargout < 2;  error(msg);  end
	return
else
    lat = varargin{1};    lon = varargin{2};
    if nargin == 3
	    z = 0;               cdata = varargin{3};   varargin(1:3) = [];
    elseif isstr(varargin{3})
        if rem(nargin,2)        % patchm(lat,lon,'cdata','prop',val,...)
		      z = 0;      cdata = varargin{3};   varargin(1:3) = [];
        else                        % patchm(lat,lon,'prop',val,...)
		      z = 0;      cdata = 'red';         varargin(1:2) = [];
		end
    elseif ~isstr(varargin{3})
        if rem(nargin,2)        % patchm(lat,lon,z,'prop',val,...)
		      z = varargin{3};   cdata = 'red';         varargin(1:3) = [];
        else                        % patchm(lat,lon,z,'cdata','prop',val,...)
		      z = varargin{3};   cdata = varargin{4};   varargin(1:4) = [];
		end
    end
end


%  Initialize outputs

if nargout ~= 0;  hndl = [];   msg = [];   end

%  Argument size tests

if any([ndims(lat) ndims(lon)] > 2)
    msg = 'Patch data must not contain pages';
	if nargout < 2;  error(msg);  end
	return

elseif ~isequal(size(lat),size(lon))
    msg = 'Inconsistent dimensions on input data';
	if nargout < 2;  error(msg);  end
	return

elseif length(z) ~= 1
    msg = 'Altitude data must be a scalar';
	if nargout < 2;  error(msg);  end
	return
end

% Handle matrix inputs (like from scircle1)

if min(size(lat))~=1
	lat(size(lat,1)+1,:) = NaN;
	lon(size(lon,1)+1,:) = NaN;
end

%  Ensure that the input vectors are in column format

lat = lat(:);    lon = lon(:);

%  Test for a map axes

[mstruct,msg] = gcm;
if ~isempty(msg)
    if nargout < 2;  error(msg);   end
	return
end


for i = 1:size(lat,2)
   
   %  Get the vector of patch items and remove any NaN padding
   %  at the beginning or end of the column.  This eliminates potential
   %  multiple NaNs at the beginning and end of the patches.
   
   latvec = lat(:,i);   lonvec = lon(:,i);
   
   while isnan(latvec(1)) | isnan(lonvec(1))
      latvec(1) = [];   lonvec(1) = [];
   end
   while isnan(latvec(length(latvec))) | isnan(lonvec(length(lonvec)));
      latvec(length(latvec)) = [];   lonvec(length(lonvec)) = [];
   end
   
   %  Add a NaN to the end of the data vector.  Necessary for processing
   %  of multiple patches.
   
   latvec(length(latvec)+1) = NaN;   lonvec(length(lonvec)+1) = NaN;
   
   %  Project the patch data.  Ensure that the patch is closed by
   %  repeating the first point at the end of the data set.
   
   [x,y,zout,savepts] = mfwdtran(mstruct,latvec,lonvec,z,'patch');
   
   % remove duplicate runs of points (mostly at the corners of the 
   % map frame from trimming). The reverse transformation goes back the
   % the original data anyway, and we'll save some of memory when
   % displaying 50,000+ point countries along the periphery of a patch
   % map display using worldhi data.
   
   dupindx = find(diff(x) == 0 & diff(y) == 0 );
   x(dupindx) = [];
   y(dupindx) = [];
   zout(dupindx) = [];
   
   %  Determine the vertices of the faces for this map
   
   faces = setfaces(x,y);
   
   %  Display the map.
   
	hndl0(i) = patch('Faces',faces,'Vertices',[x y zout],'FaceColor',cdata);
    set(hndl0(i),'UserData',savepts,'ButtonDownFcn','uimaptbx')
end


%  Set properties if necessary

if ~isempty(varargin);  set(hndl0,varargin{:});  end

%  Set handle return argument if necessary

if nargout ~= 0;    hndl = hndl0;   end


%*************************************************************************
%*************************************************************************
%*************************************************************************


function patchmui

%  PATCHMUI creates the dialog box to allow the user to enter in
%  the variable names for a patchm command.  It is called when
%  PATCHM is executed with no input arguments.


%  Define map for current axes if necessary.  Note that if the
%  user cancels this operation, the display dialog is aborted.

%  Create axes if none found

if isempty(get(get(0,'CurrentFigure'),'CurrentAxes'))
    Btn = questdlg('Create Map Axes in Current Figure?','No Map Axes',...
	                'Yes','No','Yes');
    if strcmp(Btn,'No');    return;   end
	 axes;
end

%  Create map definition if necessary

if ~ismap
     cancelflag = axesm;
     if cancelflag;   clma purge;  return;   end
end

%  Initialize the entries of the dialog box

str1 = 'lat';     str2 = 'long';     str3 = '''red''';
str4 = '';        str5 = '';

while 1      %  Loop until no error break or cancel break

    lasterr('')     %  Reset the last error function

%  Display the variable prompt dialog box

	h = PatchmUIBox(str1,str2,str3,str4,str5);  uiwait(h.fig)

   if ~ishandle(h.fig);   return;   end

%  If the accept button is pushed, build up the command string and
%  evaluate it in the base workspace.  Delete the modal dialog box
%  before evaluating the command so that the proper axes are used.
%  The proper axes were current before the modal dialog was created.

    if get(h.fig,'CurrentObject') == h.apply
        str1 = get(h.latedit,'String');    %  Get the dialog entries
		str2 = get(h.lonedit,'String');
        str3 = get(h.cdedit,'String');
        str4 = get(h.altedit,'String');
		str5 = get(h.propedit,'String');
        delete(h.fig)

%  Make the other property string into a single row vector.
%  Eliminate any padding 0s since they mess up a string

		str5 = str5';   str5 = str5(:)';   str5 = str5(find(str5));

%  Construct the appropriate plotting string and assemble the callback string

        if isempty(str4) & isempty(str5)
            plotstr = ['patchm(',str1,',',str2,',',str3,')'];
        elseif isempty(str4) & ~isempty(str5)
            plotstr = ['patchm(',str1,',',str2,',',str3,',',str5,')'];
        elseif ~isempty(str4) & isempty(str5)
            plotstr = ['patchm(',str1,',',str2,',',str4,',',str3,')'];
        elseif ~isempty(str4) & ~isempty(str5)
            plotstr = ['patchm(',str1,',',str2,',',str4,',',str3,',',str5,');'];
        end

	    evalin('base',plotstr,...
		        'uiwait(errordlg(lasterr,''Map Projection Error'',''modal''))')
		if isempty(lasterr);   break;   end  %  Break loop with no errors
   else
        delete(h.fig)     %  Close the modal dialog box
		break             %  Exit the loop
   end
end


%*************************************************************************
%*************************************************************************
%*************************************************************************

function h = PatchmUIBox(lat0,lon0,cdata0,alt0,prop0)

%  PATCHMUIBOX creates the dialog box and places the appropriate
%  objects for the PATCHMUI function.


%  Compute the Pixel and Font Scaling Factors so
%  GUI figure windows and fonts look OK across all platforms

PixelFactor = guifactm('pixels');
FontScaling =  guifactm('fonts');

%  Create the dialog box.  Make visible when all objects are drawn

h.fig = dialog('Name','Patch Map Input',...
           'Units','Points',  'Position',PixelFactor*72*[2 1 3 3.7], ...
		   'Visible','off');
colordef(h.fig,'white');
figclr = get(h.fig,'Color');

% shift window if it comes up partly offscreen

shiftwin(h.fig)

%  Latitude Text and Edit Box

h.latlabel = uicontrol(h.fig,'Style','Text','String','Latitude variable:', ...
            'Units','Normalized','Position', [0.05  0.925  0.90  0.06], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'left',...
			'ForegroundColor', 'black','BackgroundColor', figclr);

h.latedit = uicontrol(h.fig,'Style','Edit','String', lat0, ...
            'Units','Normalized','Position', [0.05  .85  0.70  0.07], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'left', ...
			'ForegroundColor', 'black','BackgroundColor', figclr);

h.latlist = uicontrol(h.fig,'Style','Push','String', 'List', ...
            'Units','Normalized','Position', [0.77  .85  0.18  0.07], ...
			'FontWeight','bold',  'FontSize',FontScaling*9, ...
			'ForegroundColor', 'black','BackgroundColor', figclr,...
			'Interruptible','on', 'UserData',h.latedit,...
			'CallBack','varpick(who,get(gco,''UserData''))');

%  Longitude Text and Edit Box

h.lonlabel = uicontrol(h.fig,'Style','Text','String','Longitude variable:', ...
            'Units','Normalized','Position', [0.05  0.775  0.90  0.06], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'left', ...
			'ForegroundColor', 'black','BackgroundColor', figclr);

h.lonedit = uicontrol(h.fig,'Style','Edit','String', lon0, ...
            'Units','Normalized','Position', [0.05  .70  0.70  0.07], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'left', ...
			'ForegroundColor', 'black','BackgroundColor', figclr);

h.lonlist = uicontrol(h.fig,'Style','Push','String', 'List', ...
            'Units','Normalized','Position', [0.77  .70  0.18  0.07], ...
			'FontWeight','bold',  'FontSize',FontScaling*9, ...
			'ForegroundColor', 'black','BackgroundColor', figclr,...
			'Interruptible','on', 'UserData',h.lonedit,...
			'CallBack','varpick(who,get(gco,''UserData''))');

%  Altitude Text and Edit Box

h.altlabel = uicontrol(h.fig,'Style','Text','String','Scalar Altitude (optional):', ...
            'Units','Normalized','Position', [0.05  0.625  0.90  0.06], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'left', ...
			'ForegroundColor', 'black','BackgroundColor', figclr);

h.altedit = uicontrol(h.fig,'Style','Edit','String', alt0, ...
            'Units','Normalized','Position', [0.05  .55  0.70  0.07], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'left', ...
			'ForegroundColor', 'black','BackgroundColor', figclr);

h.altlist = uicontrol(h.fig,'Style','Push','String', 'List', ...
            'Units','Normalized','Position', [0.77  .55  0.18  0.07], ...
			'FontWeight','bold',  'FontSize',FontScaling*9, ...
			'ForegroundColor', 'black','BackgroundColor', figclr,...
			'Interruptible','on', 'UserData',h.altedit,...
			'CallBack','varpick(who,get(gco,''UserData''))');

%  Cdata Text and Edit Box

h.cdlabel = uicontrol(h.fig,'Style','Text','String','Face Color:', ...
            'Units','Normalized','Position', [0.05  0.475  0.90  0.06], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'left', ...
			'ForegroundColor', 'black','BackgroundColor', figclr);

h.cdedit = uicontrol(h.fig,'Style','Edit','String', cdata0, ...
            'Units','Normalized','Position', [0.05  .40  0.90  0.07], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'left', ...
			'ForegroundColor', 'black','BackgroundColor', figclr);

%  Other Properties Text and Edit Box

h.proplabel = uicontrol(h.fig,'Style','Text','String','Other Properties:', ...
            'Units','Normalized','Position', [0.05  0.325  0.90  0.06], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'left', ...
			'ForegroundColor', 'black','BackgroundColor', figclr);

h.propedit = uicontrol(h.fig,'Style','Edit','String', prop0, ...
            'Units','Normalized','Position', [0.05  .16  0.90  0.16], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'left', 'Max',2,...
			'ForegroundColor', 'black','BackgroundColor', figclr);

%  Buttons to exit the modal dialog

h.apply = uicontrol(h.fig,'Style','Push','String', 'Apply', ...
	        'Units', 'Normalized','Position', [0.06  0.02  0.26  0.10], ...
			'FontWeight','bold',  'FontSize',FontScaling*10,...
			'HorizontalAlignment', 'center',...
			'ForegroundColor', 'black', 'BackgroundColor', figclr,...
			'CallBack','uiresume');

h.help = uicontrol(h.fig,'Style','Push','String', 'Help', ...
	        'Units', 'Normalized','Position', [0.37  0.02  0.26  0.10], ...
			'FontWeight','bold',  'FontSize',FontScaling*10,...
			'HorizontalAlignment', 'center', 'Interruptible','on',...
			'ForegroundColor', 'black', 'BackgroundColor', figclr,...
			'CallBack','maphlp1(''initialize'',''patchmui'')');

h.cancel = uicontrol(h.fig,'Style','Push','String', 'Cancel', ...
	        'Units', 'Normalized','Position', [0.68  0.02  0.26  0.10], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'center', ...
			'ForegroundColor', 'black','BackgroundColor', figclr,...
			'CallBack','uiresume');


set(h.fig,'Visible','on','UserData',h)

