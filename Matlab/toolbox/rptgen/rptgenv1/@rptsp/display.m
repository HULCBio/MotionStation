function display(p)
%DISPLAY display file contents to screen
%   

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:17:17 $

disp(' ');
disp([inputname(1), ' = '])
disp(' ');

disp(sprintf('Setup File Pointer: %s', num2str(p.h)));
disp('');

if ishandle(p.h)
   ud=get(p.h,'UserData');
else
   ud='  Error: Not a handle';
end

if isa(ud,'rptsetupfile')
   display(ud,logical(0));
else
   display(ud)
end
