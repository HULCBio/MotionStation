function helpDir = docroot(new_docroot)
%DOCROOT A utility to get or set the root directory of MATLAB Help
%   DOCROOT returns the current docroot.
%   DOCROOT(NEW_DOCROOT) sets the docroot to the new docroot.
%
%   The documentation root directory is set by default to be
%   MATLABROOT/help.  This value should not need to be changed, since
%   documentation in other locations may not be compatible with the running
%   version. However, if documentation from another location is desired,
%   docroot can be changed by calling this function to set the value to
%   another directory. This value is not saved in between sessions.  To set
%   this value everytime MATLAB is run, a call to docroot can be inserted
%   into startup.m.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $  $Date: 2004/04/10 23:29:32 $

% If at least one argument is passed in, set user docpath
if nargin > 0
    if (usejava('mwt') == 1)
        com.mathworks.mlservices.MLHelpServices.setDocRoot(new_docroot);
    else
        disp('See ''help docopt'' for instructions on how to set docroot on this platform.');
    end
end

% Get the docroot.
if usejava('mwt')
    helpDir = char(com.mathworks.mlservices.MLHelpServices.getDocRoot);
else
    if (strncmp(computer,'PC',2))
        helpDir = getprofl('Matlab Settings', 'Help Dir', '', 'matlab.ini');
    else
        [unused,unused,helpDir] = docopt;
    end
    % try default if helpDir is still empty
    if(isempty(helpDir))
       helpDir = fullfile(matlabroot,'help','');
    end
end
    
% verify user docpath
if (~isempty(helpDir))
    % remove trailing directory separator
    if (helpDir(end)==filesep)
        helpDir = helpDir(1:end-1);
    end
    
    % see if user docpath is valid
    if ((exist(fullfile(helpDir,'toolbox')) ~= 7) && (exist(fullfile(helpDir,'techdoc','ref')) ~= 7))
        if nargin > 0
            warning('MATLAB:docroot:InvalidDirectory', 'directory does not exist; docroot not set.');
        end
        helpDir = '';
    end
end
