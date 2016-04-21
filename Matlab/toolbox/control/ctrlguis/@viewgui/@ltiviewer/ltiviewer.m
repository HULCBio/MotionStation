function this = ltiviewer
% LTIVIEWER constructor for @ltiviewer class
% H = VIEWGUI.LTIVIEWER creates a @ltiviewer object 
%
%  Author(s): Kamesh Subbarao
%  Copyright 1986-2002 The MathWorks, Inc.
%   $Revision: 1.7.4.1 $  $Date: 2002/11/11 22:22:58 $

% Create class instance
this = viewgui.ltiviewer; 
% Initialize graphics
initialize(this)
% Add toolbar
toolbar(this)
% Install listeners
addlisteners(this)
