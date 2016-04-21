function prefspanel
%PREFSPANEL Registers a preferences control panel.
%   PREFSPANEL registers a Preferences Control panel with the MATLAB IDE.
%
%   See also AUDIOPLAYER, AUDIORECORDER.

%   Author: BJW
%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2003/12/04 19:01:10 $

%   Register Object-based Context menus items in the Workspace Browser for 
%   MATLAB's audio objects, AUDIOPLAYER and AUDIORECORDER.
%
%   Class:  audioplayer
%     Audio Controls ->
%       Play
%       Pause
%       Resume
%       Stop
%
%   Class: audiorecorder
%     Audio Controls ->
%       Record
%       Pause
%       Resume
%       Stop
%       ------
%       Get Audio Data
%       Plot Signal

%   Methods of MatlabObjectMenuRegistry are unsupported.  Calls to these
%   methods will become errors in future releases.
com.mathworks.mlwidgets.workspace.MatlabCustomClassRegistry.registerClassCallbacks(...
    {'audioplayer'},...
    'Audio Controls',...
    {'Play','Pause','Resume','Stop'},...
    {'play($1);','pause($1);','resume($1);','stop($1);'} );

com.mathworks.mlwidgets.workspace.MatlabCustomClassRegistry.registerClassCallbacks(...
    {'audiorecorder'},...
    'Audio Controls',...
    {'Record','Pause','Resume','Stop','Play','-','Get Audio Data','Plot Signal'},...
    {'record($1);','pause($1);','resume($1);','stop($1);',...
        'audiouniquename(play($1),''$1_audioplayer'',''base'');',...
        '','audiouniquename(getaudiodata($1), ''$1_audiodata'',''base'');',...
        'plot(getaudiodata($1));'} );

% [EOF]
