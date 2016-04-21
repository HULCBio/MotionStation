function display(m)
%DISPLAY show component at command line

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:16:40 $

dStruct=struct(m);

disp(' ');
disp([inputname(1), ' = '])
disp(' ');
disp(dStruct)
disp(' ');