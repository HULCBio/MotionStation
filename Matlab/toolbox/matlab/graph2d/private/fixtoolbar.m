function fixtoolbar(fig)
%FIXTOOLBAR  Plot Editor helper function

%   Copyright 1984-2002 The MathWorks, Inc.   
%   $Revision: 1.6 $  $Date: 2002/04/15 04:05:35 $

if ~isempty(findall(fig,'Tag','ScribeSelectToolBtn'))
   set(fig, 'Toolbar', 'figure');
end