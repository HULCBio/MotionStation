function display(Hq)
%DISPLAY   Default display of QFILT object

%   Thomas A. Bryan, 24 June 1999
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.13 $  $Date: 2002/04/14 15:30:52 $

name = inputname(1);
if isempty(name)
  name = 'ans';
end

disp(' ')
disp([name, ' = ']);
disp(Hq);
