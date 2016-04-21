function launchfv(hFig, tag, toolname)
%LAUNCHFV Utility for launching the help bowser.
%   LAUNCHFV(HFIG, TAG, TOOLNAME) attempts to bring up the TOOLNAME help
%   corresponding to the TAG string. Provides appropriate error messages
%   on failure.
%
%   TAG should include the toolbox.  If it finds more information beyond
%   the toolbox name it assumes that it is the whole path to the map file.
%
%   TAG can also be an HTML file from the documentation.

%   Author(s): V.Pellissier
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.3.4.3 $  $Date: 2004/04/13 00:32:01 $

error(nargchk(3,3,nargin));

if isempty(docroot)
    helpError(hFig, tag, toolname);
    return;
end

try,
    [path, name, ext] = fileparts(tag);
    if ~strcmpi(ext, '.html'),

        [tag toolbox] = strtok(tag,filesep);
        if isempty(toolbox),
            toolbox = ['signal' filesep 'signal'];
        else
            toolbox(1) = [];
        end
        if isempty(findstr(toolbox, filesep)), toolbox = [toolbox filesep toolbox]; end
        helpview(fullfile(docroot, 'toolbox', [toolbox '.map']), tag);
    else

        % If the tag is already an html file, just show it.
        helpview(tag);
    end

catch,

    helpError(hFig, tag, toolname);
end

% -------------------------------------------------------------------------
function helpError(hFig, tag, toolname)

% Help failed
% Do some basic debugging of the help system:
msg = {'';
    'Failed to find on-line help entry:';
    ['   "' tag '"'];
    ''};

if isempty(docroot),
    msg = [msg; {'The "docroot" command is used to identify the on-line documentation';
        'path, and it has returned an empty string.  This usually indicates';
        'that you have not installed on-line help, or you have not properly';
        'set up the MATLAB Preferences.';
        ''}];
else
    msg = [msg; {'The "docroot" command is used to identify the on-line documentation';
        'path, and it has returned a non-empty string.  This generally indicates';
        'that you have installed on-line help, but the specified directory path';
        'may be incorrect.';
        ''}];
end

msg = [msg;
    {'To modify your preference settings for the documentation path, go';
    'to the File menu in the Command Window, and choose "Preferences".';
    'Select "Help Browser", then check the "Documentation Location"';
    'directory path to ensure it points the location of your on-line';
    'help.'}];

hmsg = errordlg(msg,[toolname ' Help Error'],'modal');
centerfigonfig(hFig, hmsg);

% [EOF]
