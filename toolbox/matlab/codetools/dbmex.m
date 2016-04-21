function dbmex(arg)
%DBMEX  Debug MEX-files (UNIX only).
%   DBMEX ON enables MEX-file debugging.
%   DBMEX OFF disables MEX-file debugging.
%   DBMEX STOP returns to debugger prompt.
%   DBMEX PRINT displays MEX-file debugging information.
%
%   DBMEX doesn't work on the PC.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $  $Date: 2002/09/26 01:50:34 $

if strncmp(computer,'PC',2)
  disp(sprintf(['DBMEX doesn''t work on the PC.  See the MATLAB External\n',...
        'Interfaces Guide for details on how to debug MEX-files.']));
  
elseif any(getenv('MATLAB_DEBUG')) 
    if nargin < 1, arg = 'on'; end
    if strcmp(arg,'stop')
        system_dependent(9);
    elseif strcmp(arg,'print')
        system_dependent(8,2);
    else
        system_dependent(8,real(strcmp(arg,'on')));
    end
else
    disp(' ')
    disp('In order to debug MEX-files, MATLAB must be run within a debugger.');
    disp(' ')
    disp('    To run MATLAB within a debugger start it by typing:');
    disp('           matlab -Ddebugger');
    disp('    where "debugger" is the name of the debugger you wish to use.');
    disp(' ')
end
