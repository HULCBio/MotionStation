function h = propeditor(TabLabels)
%EDITDLG  Constructor for the Response Plot Property Editor.

%   Author(s): A. DiVergilio
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:15:41 $

%---Create class instance
h = cstprefs.propeditor;

%---Watch on
fig = watchon;

% Build dialog
build(h,TabLabels)

%---Turn off watch
watchoff(fig);