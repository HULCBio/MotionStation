%QUIT Quit MATLAB session.
%   QUIT terminates MATLAB after running the script FINISH.M,
%   if it exists. The workspace information will not be saved 
%   unless FINISH.M calls SAVE. If an error occurs while 
%   executing FINISH.M, quitting is cancelled.
%
%   QUIT FORCE can be used to bypass an errant FINISH.M that 
%   will not let you quit. 
%
%   QUIT CANCEL can be used in FINISH.M to cancel quitting. 
%   It has no effect anywhere else.
%
%   Example
%      Put the following lines of code in your FINISH.M file to 
%      display a dialog that allows you to cancel quitting.
%
%         button = questdlg('Ready to quit?', ...
%                           'Exit Dialog','Yes','No','No');
%         switch button
%           case 'Yes',
%             disp('Exiting MATLAB');
%             %Save variables to matlab.mat
%             save 
%           case 'No',
%             quit cancel;
%         end
%
%   Note: When using Handle Graphics in FINISH.M make sure 
%   to use UIWAIT, WAITFOR, or DRAWNOW so that figures are
%   visible.
%
%   See also EXIT.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 5.12.4.1 $  $Date: 2004/03/17 20:05:30 $
%   Built-in function.
