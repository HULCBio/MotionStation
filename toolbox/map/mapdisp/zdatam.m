function zdatam(hndl,zdata)

%ZDATAM  Adjusts the zdata property of displayed map objects
%
%  ZDATAM(h,zdata) will alter the zdata property of displayed map objects.
%  This function allows quick manipulation of the z plane in which a
%  map object is displayed.  If zdata is omitted, then a modal dialog
%  box prompts for the zdata entry.
%
%  If a scalar handle is supplied, then zdata can be either a scalar
%  (z plane definition), or a zdata matrix of appropriate dimension
%  for the displayed object.  If hndl is a vector, then zdata can be
%  a scalar or a vector of the same dimension as hndl.  If zdata is
%  a scalar, then all objects in hndl are drawn on the zdata plane.  If
%  zdata is a vector, then each object in hndl is drawn on the plane
%  defined by the corresponding zdata element.
%
%  ZDATAM('str',zdata) identifies the objects by the input'str', where
%  'str' is any string recognized by HANDLEM.
%
%  ZDATAM(h) and ZDATAM('str') displays a Graphical User Interface
%  to modify the zdata of the object(s) specified by the input.
%
%  ZDATAM displays a Graphical User Interface for selected an object
%  from the current axes and modifying its zdata.
%
%  See also SETM, SET, HANDLEM

%  Copyright 1996-2003 The MathWorks, Inc.
%  Written by:  E. Byrns, E. Brown
%  $Revision: 1.14.4.1 $  $Date: 2003/08/01 18:23:25 $

if nargin == 0
    hndl = handlem('taglist');
    if isempty(hndl);   return;   end
    zdataui(hndl);    return

elseif nargin == 1
    if isstr(hndl);   hndl = handlem(hndl);   end
    zdataui(hndl);    return

elseif nargin == 2
    if isstr(hndl);   hndl = handlem(hndl);   end
	 if length(zdata) == 1;   zdata = zdata(ones(size(hndl)));  end
end

%  Input dimension tests

if min(size(hndl)) ~= 1  | ndims(hndl) > 2  | any(~ishandle(hndl))
    error('Vector of handles required')

elseif max(size(hndl)) ~= 1 & ~isequal(size(hndl),size(zdata))
    error('Inconsistent handles and zdata')

end

%  Adjust the zdata level for each graphic object

for i = 1: length(hndl)

	  switch get(hndl(i),'Type')
      case 'patch'
           vertices = get(hndl(i),'Vertices');
           if size(vertices,2)==3
	           oldzdata    = vertices(:,3);
           else
               oldzdata = [];
           end
	  case 'text'
           position = get(hndl(i),'Position');
           oldzdata    = position(:,3);
      otherwise
           oldzdata = get(hndl(i),'Zdata');        %  Original zdata
      end

      if max(size(hndl)) == 1 & max(size(zdata)) ~= 1   %  ZDATA matrix specified
	       if all(size(zdata) == size(oldzdata))
		      newzdata = zdata;
		   else
		      error('New zdata matrix different size from displayed zdata')
		   end

	  elseif isempty(oldzdata)                 %  No zdata to begin with
           xdata    = get(hndl(i),'Xdata');
           newzdata = zdata(i);
		   newzdata = newzdata(ones(size(xdata)));

	  else                                     %  Line object.  New z level
           newzdata = zdata(i);
		   newzdata = newzdata(ones(size(oldzdata)));
	  end

  	  switch get(hndl(i),'Type')
	  case 'patch'
           vertices(:,3) = newzdata;
           set(hndl(i),'Vertices',vertices)
      case 'text'
           position(:,3) = newzdata;
           set(hndl(i),'Position',position)
      otherwise
           set(hndl(i),'Zdata',newzdata)       %  Update zdata property
      end
end


%*************************************************************************
%*************************************************************************
%*************************************************************************


function zdataui(hndl)

%  ZDATAUI creates the dialog box to allow the user to enter in
%  the variable names for a zdata command.  It is called when
%  ZDATAM is executed with no input arguments.


%  Display the variable prompt dialog box

%  Ensure that the input is a valid scalar handle

if any(~ishandle(hndl(:)))
      uiwait(errordlg('Valid handle(s) required','Object Specification','modal'))
		return
end

%  Initialize the entries of the dialog box

str1 = '';


while 1      %  Loop until no error break or cancel break

    lasterr('')     %  Reset the last error function

	h = ZdataBox(hndl,str1);    uiwait(h.fig)

   if ~ishandle(h.fig);   return;   end

%  If the accept button is pushed, build up a window change function which
%  will delete the modal dialog and then execute the plotting commands.
%  The change function is used instead of the delete function since
%  the delete function property processes the callback before destroying
%  the window.  Thus, all plotting commands would be directed to the
%  current axes (non-existant) in the modal UI dialog box.  We want to
%  destroy the window first,then process the callback so that the proper
%  axes are used.

    if get(h.fig,'CurrentObject') == h.apply
        str1 = get(h.zedit,'String');    %  Get the dialog entries

%  Construct the zdata callback string.  Set the object handles in the
%  user data slot of the modal dialog window

	    set(h.fig,'UserData',hndl(:))
		 userstr = 'get(get(0,''''CurrentFigure''''),''''UserData'''')';
       zdatastr = ['zdatam(', userstr, ',',str1,');'];
       evalstr = ['evalin(''base'','' ',zdatastr,' '', '''' );'];

        set(h.fig,'CloseRequestFcn',[evalstr, 'delete(get(0,''CurrentFigure''))'])

		close(h.fig);
		if isempty(lasterr);     break;
		    else;                uiwait(errordlg(lasterr,'Map Plane Specification','modal'))
		end
   else
        delete(h.fig)     %  Close the modal dialog box
		break             %  Exit the loop
   end
end


%*********************************************************************
%*********************************************************************
%*********************************************************************


function h = ZdataBox(hndl,zlevel0)

%  ZDATABOX will produce a modal dialog box which
%  allows the user to edit the zdata property


objname = namem(hndl);   %  Names of current object.

%  Compute the Pixel and Font Scaling Factors so
%  GUI figure windows and fonts look OK across all platforms

PixelFactor = guifactm('pixels');
FontScaling =  guifactm('fonts');

%  Create the dialog box.  Make visible when all objects are drawn

h.fig = dialog('Name','Specify Zdata',...
           'Units','Points',  'Position',PixelFactor*72*[2 1 3.5 1.7],...
		   'Visible','off');
colordef(h.fig,'white')
figclr = get(h.fig,'Color');

%  Object Name and Tag (objname is a string matrix if hndl is a vector)

if size(objname,1) == 1;    objstr = ['Object:  ',deblank(objname(1,:))];
    else                    objstr = ['Objects:  ',deblank(objname(1,:)),' ...'];
end

h.txtlabel = uicontrol(h.fig,'Style','Text','String',objstr, ...
         'Units','Normalized', 'Position', [0.05  0.83  0.90  0.13], ...
         'FontWeight','bold',  'FontSize',FontScaling*10, ...
         'HorizontalAlignment','left', ...
         'ForegroundColor','black', 'BackgroundColor',figclr);

%  Zdata Variable and Edit Box

h.zlabel = uicontrol(h.fig,'Style','Text','String', 'Zdata Variable:', ...
          'Units','Normalized', 'Position', [0.05  0.66  0.90  0.13], ...
	       'FontWeight','bold',  'FontSize',FontScaling*10, ...
          'HorizontalAlignment','left', ...
          'ForegroundColor','black', 'BackgroundColor',figclr);

h.zedit = uicontrol(h.fig,'Style','Edit','String', zlevel0, ...
         'Units','Normalized', 'Position', [0.05  0.46  0.70  0.17], ...
         'FontWeight','bold',  'FontSize',FontScaling*10, ...
         'HorizontalAlignment','left', ...
         'ForegroundColor','black', 'BackgroundColor',figclr);

h.zlist = uicontrol(h.fig,'Style','Push','String', 'List', ...
         'Units','Normalized','Position', [0.77  0.46  0.18  0.17], ...
         'FontWeight','bold',  'FontSize',FontScaling*9, ...
         'ForegroundColor', 'black','BackgroundColor', figclr,...
         'Interruptible','on', 'UserData',h.zedit,...
         'CallBack','varpick(who,get(gco,''UserData''))');

%  Buttons to exit the modal dialog

h.apply = uicontrol(h.fig,'Style','Push', 'String','Apply', ...    %  Accept Button
	      'Units','Points',  'Position',PixelFactor*72*[0.30  0.10  1.05  0.40], ...
         'FontWeight','bold',  'FontSize',FontScaling*10,...
         'HorizontalAlignment','center',...
         'ForegroundColor','black', 'BackgroundColor',figclr,...
         'Interruptible','on', 'CallBack','uiresume');

h.cancel = uicontrol(h.fig,'Style','Push', 'String','Cancel', ...    %  Cancel Button
	      'Units','Points',  'Position',PixelFactor*72*[1.65  0.10  1.05  0.40], ...
         'FontWeight','bold',  'FontSize',FontScaling*10, ...
         'HorizontalAlignment','center', ...
         'ForegroundColor','black', 'BackgroundColor',figclr,...
         'CallBack','uiresume');

set(h.fig,'Visible','on','UserData',hndl(:))

