%FINISHDLG  Display a dialog to cancel quitting
%   Change the name of this file to FINISH.M and 
%   put it anywhere on your MATLAB path. When you 
%   quit MATLAB this file will be executed.

%   Copyright 1984-2000 The MathWorks, Inc. 
%   $Revision: 1.6 $  $Date: 2000/06/01 16:19:26 $

button = questdlg('Ready to quit?', ...
                  'Exit Dialog','Yes','No','No');
switch button
  case 'Yes',
    disp('Exiting MATLAB');
      %Save variables to matlab.mat
      save 
  case 'No',
    quit cancel;
end
