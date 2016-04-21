function BrowseButton = browsebutton(this) 
% Create an configure the browse button for browsing for files.

%   Author(s): Craig Buhr, John Glass
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:16:15 $

import com.mathworks.mwswing.*;

BrowseButton = MJButton('Browse');
BrowseButton.setName('Browse');
h = handle( BrowseButton, 'callbackproperties');
h.ActionPerformedCallback = {@LocalBrowseFiles this};

%% ------------------------------------------------------------------------%
%% Function: LocalBrowseFiles
%% Purpose:  File browser
%% ------------------------------------------------------------------------%
function LocalBrowseFiles(hSrc, event, this)

CurrentPath=pwd;
if ~isempty(this.LastPath),
    cd(this.LastPath);
end

[FileName, PathName] = uigetfile('*.mat','Import file:');

if ~isempty(this.LastPath),
    cd(CurrentPath);
end

if ~isequal(FileName,0)
    %% Store the last path name
    this.FileName = FileName;
    %% Store the last path name
    this.LastPath = PathName;
    % Note: although setText is threadsafe according to JAVA documentation
    % matlab throws a thread warning currently, this line can be rewritten
    % as a direct java method call if warning is turned off
    awtinvoke(this.Handles.FileEdit, 'setText', java.lang.String(FileName));
    this.getmatfilevars;
end

