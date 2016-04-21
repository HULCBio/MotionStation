function output = LocMapMakeVarsToTLCVars(h, makeString)
% LocMapMakeVarsToTLCVars - Add options for TLC based on make (build) arguments.
%   Note: It's not recommended to be overloaded in subclass.

%   Copyright 2002 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2002/09/23 16:27:13 $

if h.LocalFindStr(makeString,'MSFCN=1')
    error('%s', ['The MSFCN=1 make option is no longer supported. ' ...
            'To call an M-file (or Fortran) S-function as a C-MEX ',...
            'S-function, ',...
            'create a sfunction_name.tlc file in the same directory as your ',...
            'S-function which contains (on the first line):',sprintf('\n'),...
            '  %% CallAsCMexLevel1',sprintf('\n'),...
            'or',sprintf('\n'),...
            '  %% CallAsCMexLevel2',sprintf('\n'),...
            'and remove the MSFCN=1 make option']);
end

% For backwards compatibility, check for EXT_MODE=1 in the build arguments.
% If present, make sure we add ExtMode=1 for TLC.
map(1).makename = 'EXT_MODE';
map(1).makevalue = '1';
map(1).tlcname = 'ExtMode';
map(1).tlcvalue = '1';

% For backwards compatibility, check for MAT_FILE=1 in the build
% arguments. If present, tell TLC to add support for mat file logging.
map(2).makename = 'MAT_FILE';
map(2).makevalue = '1';
map(2).tlcname = 'MatFileLogging';
map(2).tlcvalue = '1';

% For backwards compatibility, check for STETHOSCOPE=1 in the build
% arguments. If present, tell TLC to add support for StethoScope.
map(3).makename = 'STETHOSCOPE';
map(3).makevalue = '1';
map(3).tlcname = 'StethoScope';
map(3).tlcvalue = '1';

output = [];
makeString = [' ', makeString];

for j = 1:length(map)
    token = [' ',map(j).makename '=' map(j).makevalue];
    if length(makeString) >= length(token)
        location = findstr(makeString, token);
    else
        location = [];
    end
    if (~isempty(location))
        output = [output ' -a' map(j).tlcname '=' map(j).tlcvalue];
    end
end

%endfunction LocMapMakeVarsToTLCVars
