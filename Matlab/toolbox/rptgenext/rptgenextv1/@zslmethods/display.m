function display(z)
%DISPLAY shows the object

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:22:29 $

dStruct=rgstoredata(z);

disp(' ');
disp([inputname(1), ' = '])
disp(' ');
disp(dStruct)
disp(' ');