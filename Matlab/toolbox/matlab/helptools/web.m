function varargout=web(varargin)
%WEB Open Web browser on site or files.
%   WEB opens up an empty internal web browser.  The default internal web 
%   browser includes a toolbar with standard web browser icons, and an address
%   box showing the current address.
%
%   WEB URL displays the specified URL (Uniform Resource Locator) in an
%   internal web browser window.  If one or more internal web browsers are
%   already running, the last active browser (determined by the last
%   browser which had focus) will be reused.  If the URL is located underneath
%   docroot, then it will automatically be displayed inside the Help browser.
%
%   WEB URL -NEW displays the specified URL in a new internal web browser
%   window.
%
%   WEB URL -NOTOOLBAR displays the specified URL in an internal web
%   browser without a toolbar (and address box).
%
%   WEB URL -NOADDRESSBOX displays the specified URL in an internal web
%   browser without an address box (but does include a toolbar with standard 
%   web browser icons).
%
%   WEB URL -HELPBROWSER displays the specified URL in the Help browser.
%
%   STAT = WEB(...) -BROWSER returns the status of the WEB command in the
%   variable STAT. STAT = 0 indicates successful execution. STAT = 1 indicates
%   that the browser was not found. STAT = 2 indicates that the browser was
%   found, but could not be launched.
%
%   [STAT, BROWSER] = WEB returns the status, and a handle to the last active
%   browser.
%
%   [STAT, BROWSER, URL] = WEB returns the status, a handle to the last active
%   browser, and the URL of the current location.
%
%   WEB URL -BROWSER opens a System Web browser and loads the file or Web site
%   specified in the URL (Uniform Resource Locator).  The URL can be of any form
%   that your browser can support.  Generally, it can specify a local  file or a
%   Web site on the Internet.  On UNIX (excluding the Mac), the Web browser used
%   is specified in the DOCOPT M-file. On Windows and Macintosh, the Web browser
%   is determined by the operating system.
%
%   Examples:
%      web file:///disk/dir1/dir2/foo.html
%         opens the file foo.html in an internal browser.
%
%      web(['file:///' which('foo.html')]);
%         opens the file foo.html if it is on the MATLAB path.
%
%      web('text://<html>Hello World</html>');
%         displays the html formatted text inside an internal browser.
%
%      web('http://www.mathworks.com', '-new');
%         loads The MathWorks Web page into a new internal browser.
%
%      web('http://www.mathworks.com', '-new', '-notoolbar');
%         loads The MathWorks Web page into a new internal browser without
%         a toolbar or address box.
%
%      web('file:///disk/helpfile.html', '-helpbrowser');
%         opens the file helpfile.html in the Help browser.
%
%      web('file:///disk/dir1/dir2/foo.html', '-browser');
%         opens the file foo.html in a system browser.
%
%      web mailto:email_address
%         uses your system browser to send mail.
%
%   See also DOC, DOCOPT.

%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.10 $


% Initialize error status.
stat = 0;
   
% Initialize defaults.
useSystemBrowser = 0;
useHelpBrowser = 0;
newBrowser = 0;
showToolbar = 1;
showAddressBox = 1;
waitForNetscape = 0;
html_file = [];

for i = 1:nargin
    argName = strtrim(varargin{i});
    if strcmp(argName, '-browser') == 1
        useSystemBrowser = 1;
    elseif strcmp(argName, '-helpbrowser') == 1
        useHelpBrowser = 1;
    elseif strcmp(argName, '-new') == 1
        newBrowser = 1;
    elseif strcmp(argName, '-notoolbar') == 1
        showToolbar = 0;
    elseif strcmp(argName, '-noaddressbox') == 1
        showAddressBox = 0;
    elseif strcmp(argName, '1') == 1
        % assume this is the 'waitForNetscape' argument for the system browser.
        waitForNetscape = 1;
    else
        % assume this is the filename.
        html_file = argName;
        % if the file is under docroot, use the help browser.
        if strfind(html_file, docroot)
            useHelpBrowser = 1;
        end
    end
end

% If no argument is specified with system browser, complain and exit.
if nargin==0 && useSystemBrowser == 1
   disp('No URL specified.');
   if nargout > 0
      varargout(1) = {stat};
   end;
   return;
end

if ~isempty(html_file)
    if length(html_file) < 7 || ~(strcmp('text://', html_file(1:7)) == 1 || strcmp('http://', html_file(1:7)) == 1)
        % If the file is on MATLAB's search path, get the real filename.
        fullpath = which(html_file);
        if ~isempty(fullpath)
            % This means the file is on the path somewhere.
            html_file = fullpath;
        end
    end
end
    
% Handle matlab: protocol by passing the command to evalin.
if strncmp(html_file, 'matlab:', 7)
    evalin('caller', html_file(8:end));
    return;
end

if ~useSystemBrowser && usejava('mwt') && ~strncmp(html_file,'mailto:',7)
    % If in Java environment, use an ICE-based browser,
    % except for "mailto:", which is not supported in ICE.
    
    % If no protocol specified, or an absolute/UNC pathname is not given, 
    % include explicit 'http:'.  Otherwise ICE assumes 'file:'
    if ~isempty(html_file) && isempty(findstr(html_file,':')) && ~strcmp(html_file(1:2),'\\') && ~strcmp(html_file(1),'/') 
        html_file = ['http://' html_file];
    end
    
    % The file should be displayed inside the help browser
    if useHelpBrowser
        if strncmp(html_file,'text://',7)
            com.mathworks.mlservices.MLHelpServices.setHtmlText(html_file(8:end));
        else
            com.mathworks.mlservices.MLHelpServices.setCurrentLocation(html_file);
        end
    else
        activeBrowser = [];
        if ~newBrowser
            % User doesn't want a new browser, so find the active browser.
            activeBrowser = com.mathworks.mde.webbrowser.WebBrowser.getActiveBrowser;
        end
        if isempty(activeBrowser)
            % If there is no active browser, create a new one.
            activeBrowser = com.mathworks.mde.webbrowser.WebBrowser.createBrowser(showToolbar, showAddressBox);
        end
        
        if ~isempty(html_file)
            if strncmp(html_file,'text://',7)
                activeBrowser.setHtmlText(html_file(8:end));
            else
                activeBrowser.setCurrentLocation(html_file);
            end
        else
            html_file = char(activeBrowser.getCurrentLocation);
        end
    end
    if nargout > 0
        varargout = {stat activeBrowser html_file};
    end
    return;
end


% Otherwise, use system web browser.  Check that correct argument was given.

% determine what computer we're on
if (~isunix && ~ispc)
    error('WEB not available for this architecture: %s.', computer)
end

% get options
[doccmd,options] = docopt;

% open HTML file in browser
if strncmp(computer,'MAC',3)  %if is mac
   % Since we're opening the system browser using the NextStep open command, 
   % we must specify a syntactically valid URL, even if the user didn't
   % specify one.  We choose The MathWorks web site as the default.
   if isempty(html_file)
      html_file = 'http://www.mathworks.com';
   else
      % If no protocol specified, or an absolute/UNC pathname is not given, 
      % include explicit 'http:'.  MAC command needs the http://.
      if isempty(findstr(html_file,':')) && ~strcmp(html_file(1:2),'\\') && ~strcmp(html_file(1),'/') 
         html_file = ['http://' html_file];
      end
   end
   unix(['open ' html_file]);
elseif isunix
   % The unix command has a bunch of problems when we try to handle errors.
   % Assume we submit to unix:
   %
   %    mozilla file &
   %
   %    1. We don't know what shell is being used. It depends on the platform.
   %    2. The unix command does not save stderr
   %    3. You cannot save output since this blocks the return of the MATLAB
   %    prompt.
   %    4. You will always get the pid message and if there is a error message
   %    it will be cryptic one from the system.
   %    5. Status is always successful.
   %
   % Because of the above problems, there is no error handling. The user
   % will have to figure out things from the system error message.

   
   %determine what kind of shell we are running
   shell = getenv('SHELL');
   [unused, shellname] = fileparts(shell);
   %construct shell specific command
   if isequal(shellname, 'tcsh') || isequal(shellname, 'csh') 
       shellarg ='>& /dev/null &';
   elseif isequal(shellname,'sh') || isequal(shellname, 'ksh') || isequal(shellname, 'bash')
       shellarg ='> /dev/null 2>&1 & ';
   else
       shellarg ='& ';
   end
   
   disp('To learn how to configure your Web browser type ''help docopt''');
   comm = [doccmd ' ' options ' -remote "openURL(' html_file ')" ' shellarg];
   
   % separate the path from the filename for netscape
   [unused,fname,unused]=fileparts(doccmd);

   if strmatch(fname, strvcat('netscape', 'Netscape'))
      % We need to explicitly use /bin/ls because ls might be aliased to ls -F
      lockfile = [getenv('HOME') '/.netscape/lock' sprintf('\n')];
      [unused,result]=unix(['/bin/ls ' lockfile]);
      if length(findstr(result,lockfile)) > 0
         % if the netscape lock file exists than try to open 
         % html_file in an existing netscape session
         status = unix(comm);
      else
         status=1;
      end
   else
      % Mosaic or Arena must be the browser can not look for netscape lock file
      % To the best of my knowledge Mosaic & Arena don't support -remote  bmb
      % so just start a new session
      status=1;
   end

   if status
      % browser not running, then start it up.
      comm = [doccmd ' ' options ' ' html_file ' ' shellarg];
      status = unix(comm);
      if status
         stat = 1;
      end
      
      %
      % if waitForNetscape is nonzero, hang around in a loop until
      % netscape launches and connects to the X-server.  I do this by
      % exploiting the fact that the remote commands operate throuth the
      % netscape global translation table.  I chose 'undefined-key' as a
      % no-op to test for netscape being alive and running.
      %
      if waitForNetscape,
         comm = [doccmd ' ' options ' -remote "undefined-key()" ' shellarg];
         while ~status,
            status = unix(comm);
            pause(1);
         end
      end
   end
   
elseif ispc
   stat = ibrowse(html_file);
end

if nargout > 0
   varargout(1) = {stat};
end;

