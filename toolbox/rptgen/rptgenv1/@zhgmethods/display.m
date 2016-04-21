function display(m)
%DISPLAY display component information to screen

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:17:38 $

dStruct=rgstoredata(m);

disp(' ');
disp([inputname(1), ' = '])
disp(' ');
disp(dStruct)
disp(' ');