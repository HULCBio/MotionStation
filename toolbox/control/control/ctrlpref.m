function ctrlpref
%CTRLPREF  Open GUI for setting Control System Toolbox Preferences.
%
%   CTRLPREF opens a Graphical User Interface (GUI) which allows the user
%   to change preferences for the Control System Toolbox.  Preferences set
%   in this GUI affect future plots only (existing plots are not altered).
%
%   The user's preferences are stored to disk (in a system-dependent
%   location) and will be automatically reloaded in future MATLAB sessions
%   using the Control System Toolbox.
%
%   See also SISOTOOL, LTIVIEW.

%   Authors: A. DiVergilio
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.6 $  $Date: 2002/04/10 06:25:59 $

edit(cstprefs.tbxprefs);
