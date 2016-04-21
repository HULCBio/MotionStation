function mapfile = ctrlguihelp(topickey)
%CTRLGUIHELP  Help support for Control System Toolbox GUIs.

%   Author(s): P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc.
%   $Revision: 1.4 $  $Date: 2002/04/10 04:43:18 $

% Get MAPFILE name
helpdir = docroot;
if ~isempty(helpdir)
    mapfile = sprintf('%s/mapfiles/control.map',helpdir);
else
    mapfile = '';
end

if nargin
    % Pass help topic to help browser
    try
        helpview(mapfile,topickey);
    end
end
