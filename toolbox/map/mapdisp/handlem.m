function [hndl,msg] = handlem(object,axishndl,method)

%HANDLEM  Returns the graphics handle for identified objects
%
%
%  HANDLEM displays a Graphical User Interface to select displayed
%  object handles.  The selections choices are determined from the
%  object tags.
%
%  HANDLEM PROMPT displays a Graphical User Interface to select displayed
%  object handles.  The selection choices are determined from all the
%  recognized HANDLEM string inputs.
%
%  HANDLEM ALL returns the handles for all children of the current axes
%  HANDLEM CLABEL returns the handles for map contour labels.
%  HANDLEM CONTOUR returns the handles for the map contour lines.
%  HANDLEM FRAME returns the handle for the map frame.
%  HANDLEM GRID returns the handles for the map grid lines
%  HANDLEM HIDDEN returns the handles for all hidden map objects.
%  HANDLEM IMAGE returns the handles for untagged image objects.
%  HANDLEM LIGHT returns the handles for untagged light objects.
%  HANDLEM LINE returns the handles for untagged line objects.
%  HANDLEM MAP returns the handles for map objects, excluding the frame and grid.
%  HANDLEM MERIDIAN returns the handles for meridian grid lines
%  HANDLEM MLABEL returns the handles for meridian labels.
%  HANDLEM PARALLEL returns the handles for parallel grid lines.
%  HANDLEM PATCH returns the handles for untagged patch objects.
%  HANDLEM PLABEL returns the handles for parallel labels.
%  HANDLEM SURFACE returns the handles for untagged surface objects.
%  HANDLEM TEXT returns the handles for untagged text objects.
%  HANDLEM TISSOT returns the handles for tissot indicatricies.
%  HANDLEM VISIBLE returns the handles for all visible objects.
%
%  HANDLEM('str') returns the handles for any objects whose tag matches
%  the input 'str'.
%
%  HANDLEM('str',axesh) seaches within the axes specified by the input handle
%  axesh.
%
%  HANDLEM('str',axesh,'searchmethod') controls the method used to match the 
%  'str' input. If omitted, 'exact' is assumed. Search method 'strmatch' 
%  searches for matches at the beginning of the tag, similar to the MATLAB 
%  STRMATCH function.  Search method 'findstr' searches within the tag, 
%  similar to the MATLAB FINDSTR function. 
%
%  [h,msg] = HANDLEM(...)  returns a string msg indicating any error
%  encountered.
%
%  A prefix of 'all' may be applied to strings defining a Handle Graphics
%  Object type (image, line, surface patch, text) to find  all object
%  handles which meet the type criteria (eg. all lines, etc), and not 
%  just the objects with empty tag properties (normal operation).
%
%  See also CLMO, HIDE, SHOWM, NAMEM, TAGM

%  Copyright 1996-2003 The MathWorks, Inc.
%  Written by:  E. Byrns, E. Brown
%  $Revision: 1.11.4.1 $    $Date: 2003/08/01 18:18:33 $

%  Define recognized names.  Note that this definition process
%  is significantly faster than strvcat, where the padding
%  must be computed

names = [
         'all       '
         'clabel    '
         'contour   '
         'frame     '
         'grid      '
         'hidden    '
         'image     '
         'light     '
         'line      '
         'map       '
         'meridian  '
         'mlabel    '
         'parallel  '
         'patch     '
         'plabel    '
		 'scaleruler'
         'surface   '
         'text      '
         'tissot    '
         'visible   '
		];

%  Initialize outputs

hndl = [];   msg = [];

%  Initialize input arguments if necessary

if nargin == 0 | isempty(object) | strcmp(lower(object),'taglist')
      hndl = PromptFromTags;  return
elseif strcmp(lower(object),'prompt')
    object = PromptForName(names);
     if isempty(object);   return;   end
end

if nargin < 3; method = 'exact'; end

switch lower(method)
case{'exact','findstr','strmatch'}
otherwise
	error('Search method must be ''exact'',''findstr'', or ''strmatch''')
end

%  Test if an axis handle has been provided

if nargin < 2
    axishndl = gca;
else
    if ~(length(axishndl) == 1 & ishandle(axishndl) & ...   %  Test for a
         strcmp(get(axishndl,'type'),'axes') )              %  axes handle
             msg = 'Valid axes handle required';
	         if nargout ~= 2;  error(msg);   end
	end
end

%  Test for valid handles if input is a numeric vector

if ~isstr(object)
    indx = find(ishandle(object));
	if isempty(indx)
        msg = 'Object not found on current axes';
	    if nargout ~= 2;  error(msg);   end
    else
	    hndl = object(indx);
	end
	return
end

%  Test for a valid string input

if ~isstr(object) | min(size(object)) ~= 1
    msg = 'String vector required';
	if nargout ~= 2;  error(msg);   end
	return

else
    object = object(:)';    %  Enforce row string vector
	                        %  Allow object to retain letter case for
							%  otherwise matches of tags.

%  Test if prefix of all is applied

    allflag = 0;
	if length(object) >= 3
	    if strcmp(lower(object(1:3)),'all') &  ...
		 			~isempty(strmatch(object(4:length(object)),...
								{'image', 'line', 'surface', 'patch', 'text'},'exact'))
		  allflag = 1;    object(1:3) = [];
		end
    end

% test for keyword object. Require exact match

	strindx = strmatch(lower(object),names,'exact');      %  Test for a string match
		
	keywordmatch = 0;
    if length(strindx) == 0 | ~strcmp(method,'exact')
        name = object;		
    elseif length(strindx) == 1 & strcmp(method,'exact')
        name = deblank(names(strindx,:));   %  Set the name string
		keywordmatch = 1;
    elseif length(strindx) > 1
        msg = ['Object not found on current axes:  ',object];
	    if nargout < 2;  error(msg);  end
	    return
    end
end

%  Get the children of the current axes

children = get(axishndl,'Children');

%  Set the appropriate handle vector. Use an obfuscated method of enforcing new match method to avoid
%  restructuring code.

if keywordmatch
	
	switch name
    case 'all'
         hndl = children;

    case 'clabel'
         hndl = findobj(children,'Tag','Clabels');

    case 'contour'
         hndl = findobj(children,'Tag','Contours');

    case 'frame'
         hndl = findobj(children,'Tag','Frame');

    case 'grid'
         lathndl  = findobj(children,'Tag','Parallel');
         lonhndl  = findobj(children,'Tag','Meridian');
         hndl = [lathndl; lonhndl];
         if isempty(hndl);  hndl = findobj(children,'Tag',object);   end

    case 'hidden'
         hndl = findobj(children,'Visible','off');

    case 'image'
         if allflag
		     hndl = findobj(children,'Type','image');
         else
		     hndl = findobj(children,'Type','image','Tag','');
		 end

    case 'light'
         if allflag
             hndl = findobj(children,'Type','light');
         else
             hndl = findobj(children,'Type','light','Tag','');
         end

    case 'line'
         if allflag
             hndl = findobj(children,'Type','line');
         else
             hndl = findobj(children,'Type','line','Tag','');
         end

    case 'map'
         [mstruct,msg] = gcm;   %  Enforce a map axes here
		 if ~isempty(msg)
		       if nargout < 2;  error(msg);  end
			   return
		 end

         border = findobj(children,'Tag','Frame');
         lathndl  = findobj(children,'Tag','Parallel');
         lonhndl  = findobj(children,'Tag','Meridian');
	     hndl = children;

         if ~isempty(border);   hndl( find(hndl == border) )  = [];  end
         if ~isempty(lathndl);  hndl( find(hndl == lathndl) ) = [];  end
         if ~isempty(lonhndl);  hndl( find(hndl == lonhndl) ) = [];  end

    case 'meridian'
         hndl = findobj(children,'Tag','Meridian');

    case 'mlabel'
         hndl = findobj(children,'Tag','MLabel');

    case 'patch'
         if allflag
             hndl = findobj(children,'Type','patch');
         else
             hndl = findobj(children,'Type','patch','Tag','');
		 end

    case 'parallel'
         hndl = findobj(children,'Tag','Parallel');

    case 'plabel'
         hndl = findobj(children,'Tag','PLabel');

    case 'surface'
         if allflag
             hndl = findobj(children,'Type','surface');
		 else
             hndl = findobj(children,'Type','surface','Tag','');
		 end

    case 'text'
         if allflag
             hndl = findobj(children,'Type','text');
         else
             hndl = findobj(children,'Type','text','Tag','');
		 end

    case 'tissot'
         hndl = findobj(children,'Tag','Tissot');

    case 'visible'
         hndl = findobj(children,'Visible','on');
	case 'scaleruler'

		hndl = [];
		for i=1:20 % don't expect more than 20 distinct scalerulers
			tagstr = ['scaleruler' num2str(i)];
			hexists = findall(gca,'tag',tagstr,'HandleVisibility','on');
			if ~isempty(hexists); hndl = [hndl hexists]; end
		end

	end
		
else % not keyword match

     namecopy = deblank(name);
     if isempty(namecopy);  namecopy = name;  end     %  Using tag lists, name may be padded with trailing spaces

	switch method
	case 'exact'
	     hndl = findobj(children,'Tag',namecopy) ;

	 otherwise
		
		% get the associated tags
		
		tagcellarray = get(children,'tag');
		tagstrmat = str2mat(tagcellarray{:});
		
		% search for matches 
		
		indx = findstrmat(tagstrmat,namecopy,method);
		
		hndl = children(indx);


	end

		 
     if isempty(hndl)
	     msg = ['Unrecognized object name:  ',name];
		 if nargout < 2;  error(msg);   end
     end
end


%*********************************************************************
%*********************************************************************
%*********************************************************************


function str = PromptForName(namelist)

%  PROMPTFORNAME will produce a modal dialog box which
%  allows the user to select from the recognized HANDLEM.
%  name list or enter their own object tag name.


str = [];
children = get(gca,'Children');

%  Eliminate objects from list if their handles are hidden.

if length(children) == 1
    if strcmp(get(children,'HandleVisibility'),'callback');   indx = 1;
         else;                                                indx = [];
    end
else
    hidden = get(children,'HandleVisibility');
    indx = strmatch('callback',char(hidden));
end
if ~isempty(indx);   children(indx) = [];   end

if isempty(children)
     uiwait(errordlg('No objects on current axes',...
	                  'Object Specification','modal'));  return
end

objnames = namem(children);   %  Names of objects on current axes

%  Compute the Pixel and Font Scaling Factors so
%  GUI figure windows and fonts look OK across all platforms

PixelFactor = guifactm('pixels');
FontScaling =  guifactm('fonts');

%  Create the dialog box.  Make visible when all objects are drawn

h = dialog('Name','Specify Object',...
           'Units','Points',  'Position',PixelFactor*72*[2 1 3 3.5],...
		   'Visible','off');
colordef(h,'white');
figclr = get(h,'Color');


%  Object Name Title and Frame

uicontrol(h,'Style','Frame',...
            'Units','Points',  'Position',PixelFactor*72*[0.03  1.85  2.94  1.45], ...
			'ForegroundColor', 'black','BackgroundColor', figclr);

uicontrol(h,'Style','Text','String','Object', ...
            'Units','Points',  'Position',PixelFactor*72*[0.09  3.26  0.90  0.20], ...
			'FontWeight','bold',  'FontSize',FontScaling*12, ...
			'HorizontalAlignment', 'center', ...
			'ForegroundColor', 'black','BackgroundColor', figclr);

%  Object Name Text and Popup Menu

uicontrol(h,'Style','Text','String', 'Name:', ...
            'Units','Points',  'Position',PixelFactor*72*[0.18  2.90  0.90  0.24], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'right', ...
			'ForegroundColor', 'black','BackgroundColor', figclr);

p = uicontrol(h,'Style','Popup','String', namelist,'Value', 1, ...
                'Units','Points',  'Position',PixelFactor*72*[1.20  2.86  1.50  0.32], ...
			    'FontWeight','bold',  'FontSize',FontScaling*10, ...
			    'HorizontalAlignment', 'center',...
			    'ForegroundColor', 'black','BackgroundColor', figclr);


%  Other Tag and Edit Box

uicontrol(h,'Style','Text','String', 'Other Tag:', ...
            'Units','Points',  'Position',PixelFactor*72*[0.18  2.46  0.90  0.24], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'right', ...
			'ForegroundColor', 'black','BackgroundColor', figclr);

callbackstr = ['if ~isempty(get(gco,''String''));'                   ,...
               '     set(get(gco,''UserData''),''Enable'',''off'');' ,...
			   'else;  set(get(gco,''UserData''),''Enable'',''on'');end'];

e = uicontrol(h,'Style','Edit','String', '', ...
            'Units','Points',  'Position',PixelFactor*72*[1.20  2.42  1.50  0.32], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'left', ...
			'ForegroundColor', 'black','BackgroundColor', figclr,...
			'UserData',p,'CallBack',callbackstr);

%  Namelist select button

callbackstr = [
     'get(gco,''UserData'');',...
	 'ans.indx = listdlg(''ListString'',cellstr(ans.objnames),''SelectionMode'',''single'',',...
	 '''ListSize'',[160 170],''Name'',''Select Object'');',...
     'if ~isempty(ans.indx);  ans.ud = get(gco,''UserData'');',...
	 'set(ans.ud.hndl(1),''String'',deblank(ans.objnames(ans.indx,:)));',...
	 'set(ans.ud.hndl(2),''Enable'',''off'');end;clear ans'];

userdata.hndl = [e p];   userdata.objnames = objnames;

uicontrol(h,'Style','Push','String', 'Select', ...
	        'Units','Points',  'Position',PixelFactor*72*[1.40  2.00  1.10  0.30], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'center',...
			'UserData', userdata,...
			'ForegroundColor', 'black', 'BackgroundColor', figclr,...
			'Interruptible','on','CallBack',callbackstr);


%  Match Title and Frame

uicontrol(h,'Style','Frame',...
            'Units','Points',  'Position',PixelFactor*72*[0.03  0.70  2.94  0.90], ...
			'ForegroundColor', 'black','BackgroundColor', figclr);

uicontrol(h,'Style','Text', 'String','Match', ...
            'Units','Points',  'Position',PixelFactor*72*[0.09  1.5  0.90  0.20], ...
			'FontWeight','bold',  'FontSize',FontScaling*12, ...
			'HorizontalAlignment', 'center', ...
			'ForegroundColor', 'black','BackgroundColor', figclr);

%  Match Radio Buttons

r1 = uicontrol(h,'Style','Radio','String','Untagged Objects', 'Value',1,...
                 'Units','Points',  'Position',PixelFactor*72*[0.18 1.14 2.00 0.32],...
			     'FontWeight','bold',  'FontSize',FontScaling*10, ...
			     'HorizontalAlignment', 'left', ...
			     'ForegroundColor', 'black','BackgroundColor', figclr);

r2 = uicontrol(h,'Style','Radio', 'String','All Objects', 'Value',0,...
                 'Units','Points',  'Position',PixelFactor*72*[0.18 0.85 2.00 0.32],...
			     'FontWeight','bold',  'FontSize',FontScaling*10, ...
			     'HorizontalAlignment','left', 'Tag','AllObjects', ...
			     'ForegroundColor', 'black','BackgroundColor', figclr,...
			     'Interruptible','on','Enable','off');

%  Set the user data properties and callbacks for the radio buttons

callbackstr = 'set(gco,''Value'',1);set(get(gco,''UserData''),''Value'',0);';

set(r1,'UserData',r2,'CallBack',callbackstr)
set(r2,'UserData',r1,'CallBack',callbackstr)

%  Buttons to exit the modal dialog

uicontrol(h,'Style','Push','String', 'Apply', ...    %  Apply Button
	        'Units','Points',  'Position',PixelFactor*72*[0.30  0.10  1.05  0.40], ...
			'FontWeight','bold',  'FontSize',FontScaling*12, ...
			'HorizontalAlignment', 'center', ...
			'ForegroundColor', 'black', 'BackgroundColor', figclr,...
			'CallBack','uiresume');


uicontrol(h,'Style','Push','String', 'Cancel', ...    %  Cancel Button
	        'Units','Points',  'Position',PixelFactor*72*[1.65  0.10  1.05  0.40], ...
			'FontWeight','bold',  'FontSize',FontScaling*12, ...
			'HorizontalAlignment', 'center', ...
			'ForegroundColor', 'black','BackgroundColor', figclr,...
			'CallBack','uiresume');


%  Set the callback for the popup menu.  Disable all match option
%  if not a handle graphics child of an axes.

callbackstr = [
    'get(gco,''String'');deblank(ans(get(gco,''Value''),:));',...
	'if strcmp(ans,''text'') | strcmp(ans,''patch'') | '     ,...
	'strcmp(ans,''surface'') | strcmp(ans,''image'') | '     ,...
	'strcmp(ans,''light'') | strcmp(ans,''line'');'          ,...
	'get(gco,''UserData'');set(ans(2),''Enable'',''on'');'   ,...
    'else;get(gco,''UserData'');set(ans(1),''Value'',1);'    ,...
	'set(ans(2),''Enable'',''off'',''Value'',0);end;clear ans'];

set(p,'UserData',[r1 r2],'CallBack',callbackstr)


%  Turn dialog box on.  Then wait unit a button is pushed

set(h,'Visible','on');     uiwait(h)

if ~ishandle(h);   return;   end

%  If the accept button has been pushed, then
%  first determine if the object edit box has a string in
%  it.  If it does not, then get the name from the
%  popup menu with the name list.  Finally, check
%  to see if the all match option is selected.  If so,
%  append 'all' to the string.

if strcmp(get(get(h,'CurrentObject'),'String'),'Apply')
		str = get(e,'String');
		if isempty(str);   str = deblank(namelist(get(p,'Value'),:));   end
		if get(r2,'Value');     str = ['All', str];    end
end

%  Close the dialog box

delete(h)



%*********************************************************************
%*********************************************************************
%*********************************************************************


function hndl = PromptFromTags

%  PROMPTFROMTAGS will produce a modal dialog box which
%  allows the user to select from the recognized object TAGS on
%  the current axes.


hndl = [];
children = get(gca,'Children');
if isempty(children);
    uiwait(errordlg('No objects on current axes',...
	                 'Object Specification','modal'));  return;
end

%  Eliminate objects from list if their handles are hidden.

if length(children) == 1
    if strcmp(get(children,'HandleVisibility'),'callback');   indx = 1;
         else;                                                indx = [];
    end
else
    hidden = get(children,'HandleVisibility');
    indx = strmatch('callback',char(hidden));
end
if ~isempty(indx);   children(indx) = [];   end

%  Display the list dialog if children remain without hidden handles

if ~isempty(children)
    objnames = namem(children);
    indx = listdlg('ListString',cellstr(objnames),...
                   'SelectionMode','multiple',...
					    'ListSize',[160 170],...
					    'Name','Select Object');
    if ~isempty(indx)
	      for i = 1:length(indx)
			    hndl0 = handlem(deblank(objnames(indx(i),:)));
				 hndl = [hndl;hndl0];
			end
    end

else
    uiwait(errordlg('No objects on current axes',...
	                 'Object Specification','modal'));  return;
end


%*********************************************************************
%*********************************************************************
%*********************************************************************

function indx = findstrmat(strmat,searchstr,method)

strmat(:,end+1) = 13; % add a lineending character to prevent matches across rows


% find matches in vector

switch method
case 'findstr'
	% make string matrix a vector
	sz = size(strmat);
	strmat = strmat';
	strvec = strmat(:)';
	vecindx = findstr(searchstr,strvec);
	% vector indices to row indices
	indx = unique(ceil(vecindx/sz(2)));
case 'strmatch'
	indx = strmatch(searchstr,strmat);
case 'exact'
	searchstr(end+1) = 13; % added a lineending character above to prevent matches across rows
	indx = strmatch(searchstr,strmat,'exact');
end


