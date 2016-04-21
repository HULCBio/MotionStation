function aboutidenttbx
%ABOUTIDENTTBX About the System Identification Toolbox.
%   ABOUTIDENTTBX Displays the version number of the System Identification
%   Toolbox and the copyright notice in a modal dialog box.

%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.1 $ $Date: 2003/09/23 14:23:03 $ 

tlbx = ver('ident');
str = sprintf([tlbx.Name ' ' tlbx.Version '\n',...
	'Copyright 1988-' datestr(tlbx.Date,10) ' The MathWorks, Inc.']);
msgbox(str,tlbx.Name,'modal');

% [EOF] aboutidenttbx.m
