function display(s,showHeader)
%DISPLAY shows the contents of the setup file

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:17:11 $

if nargin<2
   showHeader=logical(1);
end

if showHeader
   disp(' ');
   disp([inputname(1), ' = '])
   disp(' ');
end

disp(struct(s))

   

