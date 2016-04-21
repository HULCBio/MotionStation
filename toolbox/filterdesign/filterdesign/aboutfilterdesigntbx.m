function aboutfilterdesigntbx
%ABOUTFILTERDESIGNTBX About the Filter Design Toolbox.
%   ABOUTFILTERDESIGNTBX Displays the version number of the Filter Design
%   Toolbox and the copyright notice in a modal dialog box.

%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.2 $ $Date: 2002/04/14 15:42:18 $ 

icon = load('aboutfdt.mat');
tlbx = ver('filterdesign');
str = sprintf([tlbx.Name ' ' tlbx.Version '\n',...
	'Copyright 1999-' datestr(tlbx.Date,10) ' The MathWorks, Inc.']);
msgbox(str,tlbx.Name,'custom',icon.nb_lowpass,hot(64),'modal');

% [EOF]
