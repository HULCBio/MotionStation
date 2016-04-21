function [tlcTargetType, tlcLanguage, codeFormat, matFileLogging, ...
          maxStackSize, maxStackVariableSize, divideStackByRate] = ...
      LocGetOptionsFromTargetFile(h, systemTargetFileName, optionsArray)
% LOCGETOPTIONSFROMTARGETFILE:
%    Using the TLC server, query values from the system target file.
%
%   Note: It's not recommended to be overloaded in subclass.

%   Copyright 2002-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2004/04/15 00:23:52 $

tlcH = tlc('new');
try
    for i=1:length(optionsArray)
        tlc('execstring', tlcH, ['%assign ', optionsArray(i).name, ...
                '=', optionsArray(i).value]);
    end
catch
    error('Loading system targetfile options: %s', lasterr);
end
fid = fopen(systemTargetFileName);
if fid == -1
    error('Unable to open system target file ''%s''', systemTargetFileName);
end
fstring = fread(fid, '*char')';
fclose(fid);
try
    tlc('execstring', tlcH, fstring);
catch
    lasterr('');
end
try
    tlcTargetType = tlc('query', tlcH, 'TargetType');
catch
    tlc('close', tlcH);
    error('%s', ['TargetType not specified in ', systemTargetFileName]);
end
try
    tlcLanguage = tlc('query', tlcH, 'Language');
catch
    tlc('close', tlcH);
    error('%s', ['Language not specified in ', systemTargetFileName]);
end

% Load CodeFormat. Note, S-Function CodeFormat is changed to
% Accelerator_S-Function if generating an Accelerator S-function.
try
    codeFormat = tlc('query', tlcH, 'CodeFormat');
    if strcmp(codeFormat,'S-Function')
        try
            accelerator = tlc('query', tlcH, 'Accelerator');
        catch
            accelerator = 0;
            lasterr('');
        end
        if accelerator
            % Convert code format from S-Function to Accelerator_S-Function
            % if this is the S-function form of the accelerator target
            codeFormat = 'Accelerator_S-Function';
        end
    end
catch
    codeFormat = 'RealTime'; % default if not specified.
    lasterr('');
end

if any(findstr(fstring, 'MatFileLogging'))
    try
      matFileLogging = tlc('query', tlcH, 'MatFileLogging');
    catch
      warnStatus = [warning; warning('query','backtrace')];
      warning off backtrace;
      warning on;
      warning(['Unable to determine the value of MatFileLogging ', ...
               'being set in system target file ''%s''. MatFileLogging ', ...
               'will be assigned to 0. '], ...
              systemTargetFileName);
      warning(warnStatus);
      lasterr('');
      matFileLogging = 0;
    end
else
    matFileLogging = 0;
end

if any(findstr(fstring, 'MaxStackSize'))
    try
        maxStackSize = tlc('query', tlcH, 'MaxStackSize');
    catch
        if any(findstr(fstring, '%assign MaxStackSize = '))
            warnStatus = [warning; warning('query','backtrace')];
            warning off backtrace;
            warning on;
            warning(['Unable to determine maximum stack size in ', ...
                    'system target file ''%s''. The maximum ', ...
                    'stack size will be assigned to inf. '], ...
                systemTargetFileName);
            warning(warnStatus);
        end
        lasterr('');
        maxStackSize = inf;
    end
else
    maxStackSize = inf;
end

if any(findstr(fstring, 'MaxStackVariableSize'))
    try
        maxStackVariableSize = tlc('query', tlcH, 'MaxStackVariableSize');
    catch
        if any(findstr(fstring, '%assign MaxStackVariableSize'))
            warnStatus = [warning; warning('query','backtrace')];
            warning off backtrace;
            warning on;
            warning(['Unable to determin maximum stack variable size in ', ...
                    'system target file ''%s''. The maximum ', ...
                    'stack variable size will be assigned to inf. '], ...
                systemTargetFileName);
            warning(warnStatus);
        end
        lasterr('');
        maxStackVariableSize = inf;
    end
else
    maxStackVariableSize = inf;
end

if any(findstr(fstring, 'DivideStackByRate'))
    try
        divideStackByRate = tlc('query', tlcH, 'DivideStackByRate');
    catch
        if any(findstr(fstring, '%assign DivideStackByRate'))
            warnStatus = [warning; warning('query','backtrace')];
            warning off backtrace;
            warning on;
            warning(['Unable to determin DivideStackByRate option in ', ...
                    'system target file ''%s''. The default value TLC_FALSE ', ...
                    'will be used for DivideStackByRate. ']);
            warning(warnStatus);
        end
        lasterr('');
        divideStackByRate = 0;
    end
else
    divideStackByRate = 0;
end

tlc('close', tlcH);

if ~any(strcmp(tlcTargetType,{'RT','NRT'}))
    error('%s', ['TargetType defined in ', systemTargetFileName, ...
            ' must be RT or NRT']);
end

%endfunction LocGetOptionsFromTargetFile
