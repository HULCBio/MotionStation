function helpwin(topic,pagetitle,helptitle,varargin)
%HELPWIN Online help displayed in the Help window
%   HELPWIN TOPIC displays the help text for the specified TOPIC inside the desktop
%   Help window.  Links are created to functions referenced in the 'See Also'
%   line of the help text.
%
%   HELPWIN(HELP_STR,TITLE) displays the string HELP_STR in the help
%   window.  HELP_STR may be passed in as a string with each line separated
%   by carriage returns, a column vector cell array of strings with each cell
%   (row) representing a line or as a string matrix with each row representing
%   a line.  The optional string TITLE will appear in the title banner.
%
%   HELPWIN({TITLE1 HELP_STR1;TITLE2 HELP_STR2;...},PAGE) displays one page
%   of multi-page help text.  Note: this calling sequence is deprecated and 
%   is provided only for compatibility with previous versions of HELPWIN.
%   The multi-page help text is passed in as a
%   cell array of strings or cells containing TITLE and HELP_STR pairs.
%   Each row of the multi-page help text cell array (dimensioned number of
%   pages by 2) consists of a title string paired with a string, cell array
%   or string matrix of help text.  The second argument PAGE is a string 
%   which must match one of the TITLE entries in the multi-page help text.
%   The matching TITLE represents the page that is to be displayed first.
%   If no second argument is given, the first page is displayed.
%
%   HELPWIN creates a temporary HTML file with the help you want in it and then 
%   displays it in the help browser.
%
%   See also HELP, DOC, LOOKFOR, WHAT, WHICH, DIR, MORE.

%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.9 $ $Date: 2004/04/10 23:29:35 $


if ~usejava('mwt')
   % Use previous version of helpwin if the Help browser is not available.
   if nargin < 1
      helpwin_figwin;
   elseif nargin < 2
      helpwin_figwin(topic);
   elseif nargin < 3
      helpwin_figwin(topic,pagetitle);
   elseif nargin < 4
      helpwin_figwin(topic,pagetitle,helptitle);
   else
      helpwin_figwin(topic,pagetitle,helptitle,varargin);
   end
   return;
end


% Some initializations
nameChars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_/';
CR = sprintf('\n');
TAB = sprintf('\t');
delimChars = [ '., ' CR ];
hdrStart = '<table width="100%" border=0 cellspacing=0 bgcolor=d0d0f0><tr><td>';
hdrEnd = '</td><td align=right><a href="matlab:helpwin">Default Topics</a>&#32;&#32;</td></table>';

% This function has to support the old helpwin syntax, which
% provides for three disparate cases.  
% Case 1: HELPWIN TOPIC, to display function or topic help (same as HELP function).
% Case 2: HELPWIN(HELP_STR,TITLE), to display an arbitrary help string.  
% Case 3: HELPWIN({TITLE1 HELP_STR1;TITLE2 HELP_STR2;...},PAGE) 
% to display multi-page help.


% Is this multi-page help text?  (case 3 above)
if nargin>0 && iscell(topic) && (size(topic,2) > 1)
    if nargin < 2
       pagetitle = '';
       helptitle = '';
    elseif nargin < 3
       helptitle = pagetitle;
    end
    handle_multipage_help(topic,pagetitle,helptitle,varargin)
    return;
end


% Is this a help string to display? (case 2 above)
% If so, construct an HTML output stream and pass it to the Help browser.
if nargin>0 && (iscell(topic) || any(find(topic==32)) || size(topic,1) > 1 || any(find(topic==CR)))

    % Set title to default, or use the one provided
    if nargin < 2
       pgtitle = 'MATLAB Help';
    else
       if isempty(pagetitle)
          pgtitle = 'MATLAB Help';
       else
          pgtitle = pagetitle;
       end
    end
    pgtitle = strrep(pgtitle, '<', '&lt;');
    pgtitle = strrep(pgtitle, '>', '&gt;');

    % Build HTML output
    if iscell(topic) || size(topic,1) > 1
       topicstr = '';
       for y = 1:size(topic,1)
          topicstr = [ topicstr deblank(char(topic(y,:))) CR ];
       end
    else
       topicstr = char(topic);
    end
    topicstr = strrep(topicstr, '&', '&amp;');
    topicstr = strrep(topicstr, '<', '&lt;');
    topicstr = strrep(topicstr, '>', '&gt;');
    
    outStr = sprintf('<html><title>%s</title><body>\n', pgtitle);
    outStr = [outStr sprintf('%s', [hdrStart '<b>' pgtitle '</b>' hdrEnd])];
    topicstr = ['<pre>' topicstr '</pre>' CR];
    outStr = [outStr sprintf('<br>\n<code>%s</code>', topicstr)];
    outStr = [outStr '</body></html>'];
    
    web(['text://' outStr], '-helpbrowser');
    return;
end

% Otherwise, this is meant as a help topic. (case 1 above)
% Get the output from the help function
if nargin==0
    topic = '';
    fcnName = 'Default Help Page';
    helpStr = help;
else
    fcnName = topic;
    helpStr = help(fcnName);
end

itemLoc = which(fcnName);
if (strcmp(itemLoc,'built-in'))
   itemLoc = which([fcnName '.m']);
end
% Isolate the function name in case a full pathname was passed in
[pathname fcnName unused unused] = fileparts(fcnName);
% Is this topic a function?
itemIsFunction = length(itemLoc);


% Handle characters that are special to HTML 
helpStr = strrep(helpStr, '&', '&amp;');
helpStr = strrep(helpStr, '<', '&lt;');
helpStr = strrep(helpStr, '>', '&gt;');


% Is there help for this topic?
if isempty(length(helpStr))
    outStr = sprintf('<html><title>M-File Help: %s</title><body>\n<p>', fcnName);
    if exist(fcnName) == 4
       outStr = [outStr sprintf('<b>%s</b> is a Simulink model</p>\n', fcnName)];
    else
       outStr = [outStr sprintf('Topic <b>%s</b> was not found</p>\n', fcnName)];
    end
    outStr = [outStr sprintf('</body>\n</html>\n')];

    web(['text://' outStr], '-helpbrowser');
    return;
end

% Determine location within help tree
productDocDir = ['techdoc' filesep 'ref'];
if findstr(itemLoc,'toolbox')
   if findstr(itemLoc,'matlab')
      productDocDir = ['techdoc' filesep 'ref'];
   elseif findstr(itemLoc,'control')
      productDocDir = ['toolbox' filesep 'control' filesep 'ref'];
   else
      productDocDir = itemLoc(findstr(itemLoc,'toolbox')+8:length(itemLoc));
      productDocDir = ['toolbox' filesep productDocDir(1:findstr(productDocDir,filesep)-1)];
   end
end



% Highlight occurrences of the function name
if ~isempty(fcnName) && ~strcmpi(fcnName,'matlab')
   helpStr = strrep(helpStr,[' ' upper(fcnName) '('],[' <b>' lower(fcnName) '</b>(']);
   helpStr = strrep(helpStr,[' ' upper(fcnName) ' '],[' <b>' lower(fcnName) '</b> ']);
end


if (strcmp(topic, '') == 1)
    title = 'M-File Help: Default Topics';
else
    title = sprintf('M-File Help: %s', topic);
end

% Begin writing HTML output into the stream
outStr = sprintf('<html><title>%s</title><body>', title);


% Prepend warning about empty docroot, if we've been called by doc.m
if isempty(docroot)
   dbStackInfo = dbstack;
   if(length(dbStackInfo)>1)
       if strcmp(dbStackInfo(2).name,'doc')
           warnStr = ['<table><tr><td width="5%"><img src="file:///' fullfile(matlabroot,'toolbox','matlab','icons','warning.gif') '">&nbsp;</td>' ...
                      '<td bgcolor="ffffco"><font size=+3><b>Warning - Documentation Files Not Found</b></font></td></tr></table>' ...
                      '<p>MATLAB cannot find your HTML help documents based on your current <b>Documentation location</b> setting. ' ...
                      'Click <a href="file:///' fullfile(matlabroot,'toolbox','local','helperr.html') '">here</a> for more information. '...
                      'The M-file help for <code>' topic '</code> appears below.</p><br>'];  
           outStr = [outStr warnStr];
       end
   end
end


% Write out header, starting with topic name.
% Determine location qualifier if not given.
%outStr = [outStr sprintf('%s', hdrStart)];
qualified_topic = topic;
if (strcmp(topic, fcnName) && (~strcmp(itemLoc, '')))
   toolbxPos = findstr(itemLoc, sprintf('toolbox'));
   if length(toolbxPos) > 0 
      qualified_topic = itemLoc(toolbxPos(1)+8:length(itemLoc));
   else
      qualified_topic = itemLoc;
   end
end

% Start with some defaults for the header.
leftText = '';
leftAction = '';
centerHtml = '';

% Include link to HTML ref page, if there is one
refPageUrl = char(com.mathworks.mlwidgets.help.HelpInfo.getReferencePageUrl([fcnName '.html']));
if ~isempty(refPageUrl)
    centerHtml = sprintf('&nbsp;&nbsp;&nbsp;<a href="%s">Go to online doc for <b>%s</b></a>', refPageUrl, fcnName);
end

% Setup the left side link (view code for...)
if ~strcmp(fcnName, 'Default Help Page')
    if itemIsFunction
        leftText = sprintf('View code for %s', fcnName);
        leftAction = sprintf('edit %s', qualified_topic);
    else
        leftText = qualified_topic;
    end
end

% The right side link is always the Default Topics page.
rightText = 'Default Topics';
rightAction = 'helpwin';

% Construct the header.
outStr = [outStr makeHeader(leftText,leftAction,centerHtml,rightText,rightAction)];

% Make "see also", "overloaded methods", etc. hyperlinks.
helpStr = makehelphyper('helpwin', pathname, fcnName, helpStr);

% Enclose help string in <PRE> tag
helpStr = ['<pre>' helpStr '</pre>' CR];

% Write out the help material and close the file
outStr = [outStr sprintf('<br> <br>\n<code>%s\n</code>',helpStr)];
outStr = [outStr sprintf('</body></html>')];

web(['text://' outStr], '-helpbrowser');


function handle_multipage_help(topic,pagetitle,helptitle,varargin)

  % Alternate between multiple temp files (starting with matlabTemp1.html).
  % Multiple files are needed because a single file won't refresh properly,
  % and to allow for a certain level of "Back" operations in the browser.
  % You have to pass the browser a new file name each time to get it to reload.

  dirName = char(com.mathworks.services.Prefs.getPropertyDirectory);
  currFile = char(com.mathworks.mlservices.MLHelpServices.getCurrentLocation);
  if length(findstr(currFile,'matlabTemp1')) > 0
    fileName = fullfile(dirName, 'matlabTemp2.html');
  elseif length(findstr(currFile,'matlabTemp2')) > 0
    fileName = fullfile(dirName, 'matlabTemp3.html');
  elseif length(findstr(currFile,'matlabTemp3')) > 0
    fileName = fullfile(dirName, 'matlabTemp4.html');
  elseif length(findstr(currFile,'matlabTemp4')) > 0
    fileName = fullfile(dirName, 'matlabTemp5.html');
  else
    fileName = fullfile(dirName,'matlabTemp1.html');
  end

  hdrStart = '<table width="100%" border=0 cellspacing=0 bgcolor=d0d0f0><tr><td>';
  hdrEnd = '</td></table>';

  % Workaround for ICE bug involving named anchors
  fnPos = findstr(fileName, 'matlabTemp');
  shortName = fileName(fnPos:length(fileName));

  % Starting building HTML output, beginning with optional title banner.
  % At top put header with links to each page.
  % Only show header if more than one page.
  fid = fopen(fileName,'w');
  fprintf(fid, '<html><title>%s</title><body>\n', helptitle);
  if ~strcmp(helptitle,pagetitle)
     fprintf(fid,'%s', [hdrStart '<b>' helptitle '</b>' hdrEnd] );
  end
  numpages = size(topic,1);
  if numpages > 1
     for x = 1:numpages 
        pgtitle = char(topic(x,1));
        fprintf(fid, '<a href="%s#topic%u">%s</a>', shortName, x, pgtitle);
        fprintf(fid, '&#32;&#32;&#32;');
     end
  end

  % Now display each page in turn, along with its title.
  CR = sprintf('\n');
  for x = 1:numpages 
     pgtitle = char(topic(x,1));
     fprintf(fid, '<br>\n<hr>\n');
     fprintf(fid, '<a name="topic%u"></a><b>%s</b><br>', x, pgtitle);
     hs_lines = char(topic{x,2});
     helpStr = '';
     for y = 1:size(hs_lines,1)
        helpStr = [ helpStr hs_lines(y,:) CR ];
     end
     helpStr = strrep(helpStr, '<', '&lt;');
     helpStr = strrep(helpStr, '>', '&gt;');
     helpStr = ['<pre>' helpStr '</pre>' CR];
     fprintf(fid,'<br>\n<code>%s\n</code>',helpStr);
  end

  % Finish up HTML output 
  fprintf(fid, '</body></html>');
  fclose(fid);

  % Get the index for the requested page from the cell array.
  % Display the appropriate page.
  ind = strmatch(pagetitle,topic(:,1),'exact');
  if isempty(ind), ind = 1; end
  if ind == 1
     web(fileName, '-helpbrowser');
  else
     namedAnchor = sprintf('#topic%u',ind);
     web([fileName namedAnchor ], '-helpbrowser');
  end

  return;



% What follows is the Release 11 version of helpwin.m, which
% displays output in a figure window.

function helpwin_figwin(topic,pagetitle,helptitle,varargin)

% If no arguments are given, load up the Home help page.
if nargin==0
   topic = 'HelpwinHome';
end

% Switchyard on 'topic'.  It is either a command or a help entry.
if iscell(topic), 
   cmd = char(topic(1,1));
else
   cmd = char(topic(1,:));
end

switch cmd

%-----------------------------------------------------------------------
case 'HelpwinPage'
   % This case is used to link a page to others pages in the text entry.
   TopicPop = gcbo;
   val = get(TopicPop,'value');
   if val~=1
      refstr = get(TopicPop,'string');
      ref = deblank(refstr{val});
      topic = get(TopicPop,'userdata');
      helpwin_figwin(topic,ref);
   end

%-----------------------------------------------------------------------
case 'HelpwinSeealso'
   % This case is used to link a page to others referenced in the
   % See Also text.
   SeeAlsoPop = gcbo;
   val = get(SeeAlsoPop,'value');
   if val~=1
      set(SeeAlsoPop,'value',1);
      refstr = get(SeeAlsoPop,'string');
      ref = deblank(refstr{val});
      str = sscanf(ref,xlate('More %s help (HTML)'));
      if ~isempty(str)
         doc(str);
      else
         helpwin_figwin(ref);
      end
   end
   
%-----------------------------------------------------------------------
case 'HelpwinBack'
   % This case is used to go back one page in the stack.
   BackBtn = gcbo;
   fig = gcbf;
   fud = get(fig,'UserData');
   pgtitle = get(findobj(fig,'tag','CurHelpEdit'),'string');
   if pgtitle(1) == ' ', pgtitle(1) = []; end  % remove first char if space
   match = max(strmatch(pgtitle,{fud.pagetitle},'exact'));
   ref = fud(match+1);
   set(BackBtn,'UserData',1);  % set flag to indicate Back call
   helpwin_figwin(ref.topic,ref.pagetitle,ref.helptitle);
   
%-----------------------------------------------------------------------
case 'HelpwinForward'
   % This case is used to go forward one page in the stack.
   fig = gcbf;
   BackBtn = findobj(fig,'Tag','BackBtn');
   fud = get(fig,'UserData');
   pgtitle = get(findobj(fig,'tag','CurHelpEdit'),'string');
   if pgtitle(1) == ' ', pgtitle(1) = []; end  % remove first char if space
   match = min(strmatch(pgtitle,{fud.pagetitle},'exact'));
   ref = fud(match-1);
   set(BackBtn,'UserData',1);  % set flag to indicate Back/Forw call to
   helpwin_figwin(ref.topic,ref.pagetitle,ref.helptitle);
   
%-----------------------------------------------------------------------
case 'HelpwinHome'
   % This case is used to go to the Home help screen.
   str = help;
   helpwin_figwin({str},'MATLAB Help Topics');
   
%-----------------------------------------------------------------------
case 'HelpwinOpen'
   % This case is used to open another link from a double-click in
   % the list box.

   % Determine whether this is a double click.
   fig = gcbf;
   if strcmp(get(fig,'SelectionType'),'open')
      ListBox = findobj(fig,'Tag','ListBox');
      SeeAlsoPop = findobj(fig,'tag','SeeAlsoPop');

      ln = get(ListBox,'value');
      helpstr = get(ListBox,'string');      
      
      % Check to see if we are looking at a MATLAB Tour help file
      if strmatch(' MATLAB Tour Partial Function Help:  ',helpstr(2,:))
         istour=1;
         tourfile=deblank(helpstr(2,38:end));
      else
         istour=0;
      end
      
      % Find the function link index or the See Also index.
      hstr = helpstr';
      hstr = lower(hstr(:)');
      cols = size(helpstr,2);
      seealso = floor((findstr(xlate('see also'),hstr)/cols) + 1);
      if isempty(seealso)
         seealso = floor((findstr('see also',hstr)/cols) + 1);
      end
      dash = floor((findstr(' - ',hstr)/cols) + 1);

      % If there is a 'See Also', follow the 'See also' index
      if ~isempty(seealso)
         if ln == seealso
            % Determine which item in the list is a the first in the 
            % 'See also' text list.
            poplist = get(SeeAlsoPop,'string');
            str = sscanf(poplist{2},xlate('More %s help (HTML)'));
            if ~isempty(str)
               val = 3;
            else
               val = 2;
            end
            helpwin_figwin(poplist{val});  % gets first reference in 'See also' list.
         end
      end

      % If there are dashes follow the function link.
      if ~isempty(dash)
         if any(ln == dash)
            loc = min(findstr('-',helpstr(ln,:)));
            ref = deblank(helpstr(ln,1:loc-1));
            ind = min(find(isletter(ref)));
            ref = ref(ind:end);
            % Redirect links within a tour file to subfunctions
            if istour
               ref=strrep(ref,'/','_');
               ref=strrep(ref,'\','_');
               ref=[tourfile '/' ref];
            end
            % Process a 'Readme' tag.
            if strcmp(ref,'Readme')
               CurHelpEdit = findobj(fig,'Tag','CurHelpEdit');
               pre = deblank(get(CurHelpEdit,'string'));
               if (pre(1)==' '), pre(1) = []; end
               helpwin_figwin([pre filesep ref]);
            % Else, just follow the link.   
            else
               helpwin_figwin(ref);
            end
         end
      end

   end

%-----------------------------------------------------------------------
case 'HelpwinHelpDesk'
   % This case is used to link HTML-based documentaion.
   doc;   
   
%-----------------------------------------------------------------------
case 'HelpwinMoreHelp'
   % This case is used to link HTML-based documentaion.
   nexttopic = get(findobj(gcbf,'tag','CurHelpEdit'),'string');
   if nexttopic(1) == ' ', nexttopic(1) = []; end  % remove first char if space
   doc(nexttopic);

%-----------------------------------------------------------------------
case 'HelpwinResize'
   % This case is used to reset the position of the buttons and the
   % frames is the helpwin figure is resized.

   % Get the new figure position in points.
   fig = gcbf;
   pos = get(fig,'Position');
   figwidth = pos(3);

   % Get all of the necessary handles.
   ListBox = findobj(fig,'tag','ListBox');
   CurHelpEdit = findobj(fig,'tag','CurHelpEdit');
   SeeAlsoPop = findobj(fig,'tag','SeeAlsoPop');
   HomeBtn = findobj(fig,'tag','HomeBtn');
   BackBtn = findobj(fig,'tag','BackBtn');
   ForwardBtn = findobj(fig,'tag','ForwardBtn');
   HelpDeskBtn = findobj(fig,'tag','HelpDeskBtn');
   HelpBtn = findobj(fig,'tag','HelpBtn');
   CloseBtn = findobj(fig,'tag','CloseBtn');
   
   % Set the top frame and buttons to their correct positions.
   wid2 = 60; spc = 8;
   ht = 21;   frmht = 54;
   [unused,unused,bdr] = goodfonts(computer);

   set(CurHelpEdit,'Position',[spc pos(4)-frmht+ht+8 2*wid2+spc ht]);
   set(SeeAlsoPop,'Position',[2*wid2+3*spc pos(4)-frmht+ht+8 2*wid2+spc ht]);
   set(HomeBtn,'Position',[2*wid2+3*spc pos(4)-frmht+4 wid2 ht]);
   set(BackBtn,'Position',[spc pos(4)-frmht+4 wid2 ht]);
   set(ForwardBtn,'Position',[wid2+2*spc pos(4)-frmht+4 wid2 ht]);
   set(HelpDeskBtn,'Position',[figwidth-2*(wid2+spc) pos(4)-frmht+ht+8 2*wid2+spc ht]);
   set(HelpBtn,'Position',[figwidth-2*(wid2+spc) pos(4)-frmht+4 wid2 ht]);
   set(CloseBtn,'Position',[figwidth-(wid2+spc) pos(4)-frmht+4 wid2 ht]);
   
   % Set the list box to fill the rest of the figure.
   set(ListBox,'Position',[bdr 0 pos(3) pos(4)-frmht]);
      
%-----------------------------------------------------------------------
otherwise

   % Try to find the figure.  Note the awkward spelling of the tag to prevent
   % others from accidentally grabing this hidden figure.
   fig = findobj(allchild(0),'tag','MiniHelPFigurE');
   CR = sprintf('\n');

   % Determine if the input consists of a cell array or paged help text.
   topic_is_cell = iscell(topic);
   multi_page_text = topic_is_cell & (size(topic,2) > 1);
   
   % Strip off the first character if it is a space.  The space is inserted
   % on purpose for better display in the edit box.
   if ~topic_is_cell && size(topic,1) == 1 && topic(1)==' ' , topic(1) = []; end

   % Create the figure if it doesn't exist.
   if isempty(fig),
      % Params.
      wid2 = 60; spc = 8;
      ht = 21;   frmht = 54;

      % Get a good font and figure size for this platform.
      [fname,fsize,bdr] = goodfonts(computer);
      
      % Create the figure.
      fig = figure( ...
         'Visible','off', ...
         'HandleVisibility','off', ...
         'MenuBar','none', ...
         'Name','MATLAB Help Window', ...
         'Color',get(0,'defaultuicontrolbackgroundcolor'), ...
         'NumberTitle','off', ...
         'IntegerHandle','off', ...
         'Units','Points', ...
         'ResizeFcn','helpwin(''HelpwinResize'')', ...
         'CreateFcn','', ...
         'Tag','MiniHelPFigurE');
      
      % Test the chosen font to get the best figure width.
      str = ['01234567890123456789012345678901234567890123456789012345678901234567890123456789'];
      t = uicontrol('Parent',fig, ...
         'Units','points', ...
         'FontName',fname, ...
         'FontSize',fsize, ...
         'String',str);
      figwidth = get(t,'extent');
      figwidth = figwidth(3);
      delete(t);
      pos = get(fig,'position');  % Gets default figure position in points.
      bdr = bdr * get(0,'ScreenPixelsPerInch') / 72;  % Convert Pixels to Points.
      figpos = [(2*pos(1) + pos(3) - figwidth)/2 pos(2) figwidth pos(4)] + ...
               [-bdr 0 bdr 0];
      
      % Set the best figure position.
      set(fig,'Position',figpos);
      
      % Create the rest of the UIs.
      ListBox = uicontrol('Parent',fig, ...
         'BackgroundColor',[1 1 1], ...
         'CallBack','helpwin(''HelpwinOpen'');', ...
         'FontName',fname, ...
         'FontSize',fsize, ...
         'Max',2, ...
         'Units','Points', ...
         'Position',[bdr 0 figwidth pos(4)-frmht], ...
         'String',' ', ...
         'Style','listbox', ...
         'Tag','ListBox', ...
         'Value',[]);
      CurHelpEdit = uicontrol('Parent',fig, ...
         'BackgroundColor',[1 1 1], ...
         'Units','Points', ...
         'Position',[spc pos(4)-frmht+ht+8 2*wid2+spc ht], ...
         'Style','edit', ...
         'HorizontalAlignment','left', ...
         'Tag','CurHelpEdit', ...
         'Callback','helpwin(get(gcbo,''string''));');
      SeeAlsoPop = uicontrol('Parent',fig, ...
         'BackgroundColor',[1 1 1], ...
         'CallBack','helpwin(''HelpwinSeealso'');', ...
         'Min',1, ...
         'Units','Points', ...
         'Position',[2*wid2+3*spc pos(4)-frmht+ht+8 2*wid2+spc ht], ...
         'String','See also', ...
         'Style','popupmenu', ...
         'HorizontalAlignment','left', ...
         'Tag','SeeAlsoPop', ...
         'Value',1);
      HomeBtn = uicontrol('Parent',fig, ...
         'CallBack','helpwin(''HelpwinHome'');', ...
         'Units','Points', ...
         'Position',[2*wid2+3*spc pos(4)-frmht+4 wid2 ht], ...
         'String','Home', ...
         'Tag','HomeBtn');
      BackBtn = uicontrol('Parent',fig, ...
         'CallBack','helpwin(''HelpwinBack'');', ...
         'Units','Points', ...
         'Position',[spc pos(4)-frmht+4 wid2 ht], ...
         'String','Back', ...
         'UserData',0, ...
         'Tag','BackBtn');
      ForwardBtn = uicontrol('Parent',fig, ...
         'CallBack','helpwin(''HelpwinForward'');', ...
         'Units','Points', ...
         'Position',[wid2+2*spc pos(4)-frmht+4 wid2 ht], ...
         'String','Forward', ...
         'Tag','ForwardBtn');
      HelpDeskBtn = uicontrol('Parent',fig, ...
         'Units','Points', ...
         'Position',[figwidth-2*(wid2+spc) pos(4)-frmht+ht+8 2*wid2+spc ht], ...
         'Style','Pushbutton', ...
         'HorizontalAlignment','center', ...
         'String','Go to Help Desk', ...
         'Tag','HelpDeskBtn', ...
         'Callback','helpwin(''HelpwinHelpDesk'');');
      HelpBtn = uicontrol('Parent',fig, ...
         'CallBack','helpwin(''helpinfo'');', ...
         'Units','Points', ...
         'Position',[figwidth-2*(wid2+spc) pos(4)-frmht+4 wid2 ht], ...
         'String','Tips', ...
         'Tag','HelpBtn');
      CloseBtn = uicontrol('Parent',fig, ...
         'CallBack','set(gcbf,''visible'',''off'')', ...
         'Units','Points', ...
         'Position',[figwidth-(wid2+spc) pos(4)-frmht+4 wid2 ht], ...
         'String','Close', ...
         'Tag','CloseBtn');
      
      % Set 'Busy Action, Queue' and 'Interruptible, Off' on all objects.
      set(findobj(fig),'BusyAction','queue','Interruptible','off');

   else
      figure(fig);
      ListBox = findobj(fig,'tag','ListBox');
      CurHelpEdit = findobj(fig,'tag','CurHelpEdit');
      SeeAlsoPop = findobj(fig,'tag','SeeAlsoPop');
      HomeBtn = findobj(fig,'tag','HomeBtn');
      BackBtn = findobj(fig,'tag','BackBtn');
      ForwardBtn = findobj(fig,'tag','ForwardBtn');
      HelpDeskBtn = findobj(fig,'tag','HelpDeskBtn');      

   end
   
   % Turn on figure visiblity.
   set(fig,'visible','on');

   % Create Page popup if not necessary and non-existent.  Otherwise, simply
   % load up the help string with the help text for the requested topic.
   if multi_page_text
      % Get the help text for the requested topic from the cell array.
      if nargin < 2
         pagetitle = topic{1,1};
      elseif isempty(pagetitle)
         pagetitle = topic{1,1};
      end
      ind = strmatch(pagetitle,topic(:,1),'exact');
      if isempty(ind), ind = 1; end

      helpstr = char(topic{ind,2});
      slash_n = find(helpstr==CR);
      if slash_n
         % Replace pipes with '!' for display if necessary,
         % replace the carriage returns in the help string with pipes
         % so that the list box can correctly interpret them.
         % Add one extra line to top of display.  
         helpstr(find(helpstr == '|')) = '!';
         helpstr(slash_n) = '|';
         helpstr = ['|' helpstr];
      else
         % Add one extra line to top of display.  
         helpstr = str2mat('',helpstr);
      end

      % Set the popup string.
      ref = [{'Topics'}; topic(:,1)];
      if length(ref) < 2
         set(SeeAlsoPop,'string',ref,...
             'enable','off');
      else
         set(SeeAlsoPop,'string',ref, ...
             'callback','helpwin(''HelpwinPage'');', ...
             'enable','on',...
             'value',1,...
             'userdata',topic);
      end

      % Set the current topic.
      pgtitle = topic{ind,1};
      
   elseif (iscell(topic) || any(find(topic==32)) || ...
           size(topic,1) > 1 || any(find(topic==CR)))
      helpstr = char(topic);
      slash_n = find(helpstr==CR);
      if slash_n
         % Replace pipes with '!' for display if necessary,
         % replace the carriage returns in the help string with pipes
         % so that the list box can correctly interpret them.
         % Add one extra line to top of display.  
         helpstr(find(helpstr == '|')) = '!';
         helpstr(slash_n) = '|';
         helpstr = ['|' helpstr];
      else
         % Add one extra line to top of display.  
         helpstr = str2mat('',helpstr);
      end

      if nargin < 2
         pgtitle = 'MATLAB Help';
      else
         if isempty(pagetitle)
            pgtitle = 'MATLAB Help';
         else
            pgtitle = pagetitle;
         end
      end
      
   else
      % Get the help text for the requested topic.
      if exist(topic)==4, 
         helpstr = sprintf('   ''%s'' is a Simulink model.',topic);
      else
         helpstr = help(topic);
      end    
      slash_n = 1;
      pgtitle = topic;

      % Error handling.  If topic not found, send an error message to the window.
      if isempty(helpstr)
         helpstr = [CR ' Topic ''' pgtitle ''' was not found.'];
      end

      % Replace pipes with '!' for display if necessary,
      % replace the carriage returns in the help string with pipes
      % so that the list box can correctly interpret them.
      % Add one extra line to top of display.  
      helpstr(find(helpstr == '|')) = '!';
      helpstr(find(helpstr==CR)) = '|';
      helpstr = ['|' helpstr];
         
   end
      
   % Store the arguments in the userdata of the figure.  This is a stack
   % which enables the Back button to work for the last few selections.
   fud = get(fig,'UserData');
   curArg = struct('topic',{[]},'pagetitle',{[]},'helptitle',{[]});
   curArg.topic = topic;
   curArg.pagetitle = pgtitle;
   if nargin >= 3
      curArg.helptitle = helptitle;
   end
   if isempty(fud)
      fud = curArg;  % protects for first time through code.
   else
      backflag = get(BackBtn,'UserData');  % flag to indicate that Back/Forw button was
      if backflag == 0                     % pressed.
         str = get(CurHelpEdit,'string');
         if str(1) == ' ', str(1) = []; end;  % remove first char is space
         match = strmatch(str,{fud.pagetitle},'exact');
         if ~isempty(match)
            fud(1:match(1)-1) = [];     % eliminate the items 'above' the selected items
         end
         fud = [curArg fud];
         if length(fud) >= 7         % limits stack to 6 elements
            fud(7) = [];             % or 5 Back button presses
         end
      else
         set(BackBtn,'UserData',0);  % clear backflag
      end
   end
   set(fig,'UserData',fud);

   % Check to see whether the Back and Forward buttons should be disabled.
   match = strmatch(pgtitle,{fud.pagetitle},'exact');
   if max(match) == length(fud)
      set(BackBtn,'enable','off');
   else
      set(BackBtn,'enable','on');
   end
   if min(match) == 1
      set(ForwardBtn,'enable','off');
   else
      set(ForwardBtn,'enable','on');
   end
   
   % Replace all tabs with single spaces.
   helpstr(find(helpstr==9)) = ' ';
   
   % Set the listbox string to the help string and set the topic name in the
   % edit box.
   set(CurHelpEdit,'string',[' ' pgtitle]);  % extra space for better display.
   set(ListBox,'value',[],'string',helpstr,'ListBoxTop',1);
   
   if any(slash_n) && ~multi_page_text
      % Set up the string for the See Also pop-up
      cnt=1;
      ref={'See also'};
      if ~(any(find(pgtitle==filesep)) || ...
           any(find(pgtitle=='/')) || ...
           any(find(pgtitle(2:end)==' ')))
         ref = {'See also' sprintf('More %s help (HTML)',pgtitle)};
         cnt = cnt + 1;
      end
      
      % Enable links to the related topics found after the 'See Also'.
      seealso=max(findstr(helpstr,xlate('See also')));  % Finds LAST 'See Also'.
      if isempty(seealso)
         seealso=max(findstr(helpstr,'See also'));
      end
      overind = max(findstr(helpstr,'| Overloaded methods'));
      if ~isempty(seealso)
         p=seealso+length(xlate('See also'));
         lmask=[zeros(1,p-1) isletter(helpstr(p:end))];
         umask=helpstr==upper(helpstr);
         undmask=helpstr=='_';
         nmask = [zeros(1,p-1) ...
               ((helpstr(p:end) >= '0') & (helpstr(p:end) <= '9'))];
         rmask=lmask&umask | undmask | nmask;
         ln=length(helpstr);
         if ~isempty(overind), ln=overind-1; end
         while 1
            while ~rmask(p) && p<ln
               p=p+1;
            end
            q=p+1;
            if q>=ln, break; end
            while rmask(q)
               q=q+1;
            end
            cnt=cnt+1;
            if q>p+1,  % Protects against single letter references.
               ref{cnt}=lower(helpstr(p:q-1));
            end
            p=q;
         end
      end
   
      % Enable link to overloaded methods.
      if ~isempty(overind)
         ln = length(helpstr);
         eol = find(helpstr(overind+1:ln)=='|');
         p = findstr(helpstr(overind:ln),'help ');
         for i=1:length(p)
            cnt = cnt + 1;
            ref{cnt} = helpstr(overind+p(i)+4:overind+eol(i+1)-1);
         end
         
      end
   
      % Set the See Also popup values.
      set(SeeAlsoPop,'value',1);
      if size(ref,2) < 2
         set(SeeAlsoPop,'string',ref,...
             'enable','off');
      else
         set(SeeAlsoPop,'string',ref, ...
             'callback','helpwin(''HelpwinSeealso'');', ...
             'enable','on');
      end

   elseif ~multi_page_text 
      set(SeeAlsoPop,'string',{'See also'},...
          'enable','off');

   end   

   % Set the figure title if supplied.
   if nargin >= 3
      if isempty(helptitle)
         set(fig,'Name','MATLAB Help Window');
      else
         set(fig,'Name',helptitle);
      end
   else
      set(fig,'Name','MATLAB Help Window');
   end

   % Set any HG properties that were passed in.
   if ~isempty(varargin)
      narg = length(varargin);
      set(ListBox,varargin(1:2:narg),varargin(2:2:narg))
   end

end

% Done.

%===============================================================================
function h = makeHeader(leftText,leftAction,centerHtml,rightText,rightAction)

% Left chunk.
leftData = ['<b>' leftText '</b>'];
if ~isempty(leftAction)
   leftData = ['<a href="matlab:' leftAction '">' leftData '</a>'];
end
leftData = ['<td>&nbsp;' leftData '</td>'];

% Center chunk.
centerData = ['<td valign="left">' centerHtml '</td>'];

% Right chunk.
rightData = ['<b>' rightText '</b>'];
if ~isempty(rightAction)
   rightData = ['<a href="matlab:' rightAction '">' rightData '</a>'];
end
rightData = ['<td align=right>' rightData '&nbsp;</td>'];

beginTable = '<table width="100%" border=0 cellspacing=0 bgcolor=d0d0f0><tr>';
endTable = '</tr></table>';

h = [beginTable leftData centerData rightData endTable];


%-----------------Function GOODFONTS-----------------
function [fname,fsize,listboxbdr] = goodfonts(computer)
%       Returns a good font for a list box on this platform
%       and return the resulting figure width for an 80 column
%       display.

% fname - string
% fsize - points
% listboxbdr - pixels for frame

switch computer

case 'PCWIN'
   fname = 'FixedWidth';
   fsize = 10;
   listboxbdr = 0;

otherwise
   fname = 'Courier';
   fsize = 10;
   listboxbdr = 0;

end
