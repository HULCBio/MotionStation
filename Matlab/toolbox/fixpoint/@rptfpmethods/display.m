function display(z)
%DISPLAY shows the object

% Copyright 1994-2002 The MathWorks, Inc.
%   $Revision: 1.6 $  $Date: 2002/04/10 16:56:25 $

dStruct=rgstoredata(z);
if isempty(dStruct) | ~isstruct(dStruct)
   initialize(z);
   dStruct=rgstoredata(z);
end

disp(' ');
disp([inputname(1), ' = '])
disp(' ');
disp(dStruct)
disp(' ');