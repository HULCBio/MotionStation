function playbackdemo(demo_name)
%PLAYBACKDEMO  Launch demo playback device
%   This utility is used to launch playback demos.
%   PLAYBACKDEMO(DEMO_NAME)
%     DEMO_NAME = name of playback demo in 
%                 matlabroot/demos/.
%
%   For example:
%   playbackdemo('import')

%   $Revision: 1.11.4.2 $  $Date: 2004/02/11 19:33:38 $
%   Copyright 1984-2004 The MathWorks, Inc.

% Define constants.
REL_PATH = 'demos';
mlroot = matlabroot;

% Assemble file paths
html_file = strcat(fullfile(mlroot,REL_PATH,demo_name),'.html');

% Error out if the file doesn't exist
if exist(html_file,'file')==0
    errordlg(sprintf('Can''t find %s',html_file));
    return
end

% Convert the filename to a URL.
url = ['file:///' strrep(html_file,'\','/')];

% Launch browser
evalc('stat = web(url,''-browser'');');
if (stat==2)
   errordlg(['Could not launch Web browser. Please make sure that'  sprintf('\n') ...
   'you have enough free memory to launch the browser.']);
elseif (stat)
   errordlg(['Could not load HTML file into Web browser. Please make sure that'  sprintf('\n') ...
   'you have a Web browser properly installed on your system.']);
end
