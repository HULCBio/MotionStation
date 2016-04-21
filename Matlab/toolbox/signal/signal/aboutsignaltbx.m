function aboutsignaltbx
%ABOUTSIGNALTBX About the Signal Processing Toolbox.
%   ABOUTSIGNALTBX Displays the version number of the Signal Processing
%   Toolbox and the copyright notice in a modal dialog box.

%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.4 $ $Date: 2002/04/15 01:19:30 $ 

icon = load('aboutspt.mat');
tlbx = ver('signal');
str = sprintf([tlbx.Name ' ' tlbx.Version '\n',...
	'Copyright 1988-' datestr(tlbx.Date,10) ' The MathWorks, Inc.']);
msgbox(str,tlbx.Name,'custom',icon.specgram,hot(64),'modal');

% [EOF] aboutsignaltbx.m
