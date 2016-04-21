function mexdebug(arg)
%MEXDEBUG Debug MEX-files. 
%   MEXDEBUG ON enables MEX-file debugging.
%   MEXDEBUG OFF disables MEX-file debugging.
%   MEXDEBUG STOP returns to debugger prompt.
%   MEXDEBUG PRINT displays MEX-file debugging information.
%
%   See also MEX, PERL, JAVA.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 5.12.4.1 $  $Date: 2004/03/17 20:05:25 $

warning('MATLAB:mexdebug:ObsoleteFunction', ...
    'MEXDEBUG is obsolete.  Use DBMEX instead.')

if any(getenv('MATLAB_DEBUG'))  
    if nargin < 1, arg = 'on'; end
    if strcmp(arg,'stop')
        system_dependent(9);
    elseif strcmp(arg,'print')
        system_dependent(8,2);
    else
        system_dependent(8,strcmp(arg,'on'));
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
