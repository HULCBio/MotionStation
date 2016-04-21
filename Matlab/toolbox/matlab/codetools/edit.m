function edit(varargin)
%EDIT Edit M-file.
%   EDIT FUN opens the file FUN.M in a text editor.  FUN must be the
%   name of an M-file or a MATLABPATH relative partial pathname (see
%   PARTIALPATH).
%
%   EDIT FILE.EXT opens the specified file.  MAT and MDL files will
%   only be opened if the extension is specified.  P and MEX files
%   are binary and cannot be directly edited.
%
%   EDIT X Y Z ... will attempt to open all specified files in an
%   editor.  Each argument is treated independently.
%
%   EDIT, by itself, opens up a new editor window.
%
%   By default, the MATLAB built-in editor is used.  The user may
%   specify a different editor by modifying the Editor/Debugger
%   Preferences.
%
%   If the specified file does not exist and the user is using the
%   MATLAB built-in editor, an empty file may be opened depending on
%   the Editor/Debugger Preferences.  If the user has specified a
%   different editor, the name of the non-existent file will always
%   be passed to the other editor.

%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.7 $  $Date: 2004/02/01 22:02:31 $

if ~iscellstr(varargin)
    error(makeErrID('NotString'), 'The input must be a string.');
    return;
end

if (nargin == 0)
    [errMessage, errID] = openEditor;
    if ~isempty(errMessage)
        error(makeErrID(errID), '%s', errMessage);
    end
else
    for i = 1:nargin
        argName = strtrim(varargin{i});

        % Note about use of evalin: it is necessary to use evalin when doing calls
        % to which and exist.  When doing a which, it is important to look for
        % private methods that exist in the scope of the workspace from which
        % edit was called.  Most of the time, edit will be called from the
        % base workspace.  However, if the user is debugging a file when he/she calls
        % edit, we want to do which (and exist) in the context of the file that
        % is being debugged.  For this reason, we use evalin to get the caller's
        % workspace. This also means that evalin cannot be called from a subfunction,
        % forcing all this code to be in the main loop

        % Store the original name for error messages.
        origName = argName;

        %Get format with quotes around it
        whichArg = convertFilename(argName);

        % Check if directory.
        [message, errID] = isDirectory(whichArg);

        if (isempty(message))

            % Check for bad extensions (p, mex types).
            [message, errID] = endsWithBadExtension(argName);

            if (isempty(message))

                % If file exists exactly as typed, go ahead and open.
                [fExists, errMessage, errID] = openFileIfExists(whichArg, argName);
                if (fExists == 1)
                    if ~isempty(errMessage)
                        error(makeErrID(errID), '%s', errMessage);
                    end
                    continue;
                end

                % Do a which and exist open file if possible.
                fName = evalin('caller', ['which(' whichArg ')']);

                % if which/exist agree that something exists, check further
                % skip if variable, built-in, mex, or p
                if ~isempty(fName)
                    % Results of exist that we are interested in.
                    DoesNotExistResult = 0;
                    VariableExistResult = 1;
                    MFileExistResult = 2;
                    MexFileExistResult = 3;
                    MdlExistResult = 4;
                    PFileExistResult = 6;
                    % It is necessary to do exist now on the argument returned from which
                    % because exist of whichArg may return the directory code if there is
                    % both a directory and a function with the same name in the current directory
                    % (even though which returns the function file, ending in .m).
                    exists = evalin('caller', ['exist(' convertFilename(fName) ')']);

                    if (exists ~= DoesNotExistResult ...
                            && exists ~= VariableExistResult ...
                            && exists ~= MexFileExistResult ...
                            && exists ~= PFileExistResult)
                        if (hasExtension(argName) == 0) % if no extension was specified, don't open MDL or MAT files.
                            if (exists == MdlExistResult)
                                error(makeErrID('MdlErr'), 'Can''t edit the MDL-file ''%s'' unless you include the ''.mdl'' file extension.', argName);
                                continue;
                            end
                            % Note: don't need to worry about MAT files here because which will not return a MAT file
                            % unless the .mat extension was specified.
                        end
                        if (exists == MFileExistResult || exists == MdlExistResult)
                            [errMessage, errID] = openEditor(fName);
                            if ~isempty(errMessage)
                                error(makeErrID(errID), '%s', errMessage);
                            end
                            continue;
                        end
                    end
                end
                % If file did not have an extension, continue on and try adding ".m" to it.
                if (hasExtension(argName) == 0)


                    % Add .m to filename.
                    argName= [argName '.m'];

                    whichArg = convertFilename(argName);

                    % If file exists as typed (with .m added), go ahead and open.
                    [fExists, errMessage, errID] = openFileIfExists(whichArg, argName);
                    if (fExists == 1)
                        if ~isempty(errMessage)
                            error(makeErrID(errID), '%s', errMessage);
                        end
                        continue;
                    end

                    % Now do a which of the new filename (with the .m)
                    fName = evalin('caller', ['which(' whichArg ')']);

                    % Check to see if the result is non-empty.
                    if (~isempty(fName))
                        % Since we added the .m already and got a result from which, we know that
                        % we have a file that exists.
                        [errMessage, errID] = openEditor(fName);
                        if ~isempty(errMessage)
                            error(makeErrID(errID), '%s', errMessage);
                        end

                    else % which did not return anything useful.
                        % Displaying a non-existant file.
                        [errMessage, errID] = showEmptyFile(argName, origName);
                        if (~isempty(errMessage))
                            error(makeErrID(errID), '%s', errMessage);
                        end
                    end
                    continue;
                else % User has specified a file extension, so we know that the file does not exist.
                    [errMessage, errID] = showEmptyFile(argName, origName); % display empty file according to user prefs
                    if (~isempty(errMessage))
                        error(makeErrID(errID), '%s', errMessage);
                    end
                    continue;
                end
            else %argument specified ended in a bad extension (p, mex, dll) -- display error and return
                error(makeErrID(errID), '%s', message);
                return;
            end
        else % argument specified was a directory -- display error and return
            error(makeErrID(errID), '%s', message);
            continue;
        end % end of directory check
    end % end of for loop
end % end of case where at least one argument was specified


%------------------------------------------
% Helper function that displays an empty file -- taken from the previous edit.m
% Now passes error message to main function for display through error.
function [errMessage, errID] = showEmptyFile(file, origArg)

errMessage = '';
errID = '';

% If nothing is found in the MATLAB workspace or directories,
% open a blank buffer only if a simple filename is specified.
% We do this because the directories specified may not exist, and
% it would be too difficult to deal with all the cases.
if isSimpleFile(file)
    valid = localCheckValidName(file);
    if (valid == 1)
        err = javachk('mwt', 'The MATLAB Editor');
        if ~isempty(err)
            % You must have mwt to run the editor on the PC
            if ~isunix
                errMessage = err.message; % cannot cannot call miedit on Windows
                errID = err.identifier;
                % If there is no mwt on Unix, try to run user's default editor
            else
                system_dependent('miedit', file);
            end;
            return;
        else
            % if we are using the built-in editor and don't show empty buffers
            % then display error message
            if com.mathworks.mde.editor.EditorOptions.getNamedBufferOption == 2 ...
                    && com.mathworks.mde.editor.EditorOptions.getBuiltinEditor ~= 0
                [errMessage, errID] = showFileNotFound(file, origArg);
                return;
            end;
        end;
        [errMessage, errID] = openEditor(file);
    else
        errMessage = sprintf('File ''%s'' contains invalid characters.', file);
        errID = 'BadChars';
    end
else
    [errMessage, errID] = showFileNotFound(file, origArg);
end


%------------------------------------------
% Helper function that calls the java editor.  Taken from the original edit.m.
% Did modify to pass non-existent files to outside editors if
% user has chosen not to use the built-in editor.
% Also now passing out all error messages for proper display through error.
function [errMessage, errID] = openEditor(file)
% OPENEDITOR  Open file in user specified editor

errMessage = '';
errID = '';

% Make sure our environment supports the editor
% Need mwt to get com.mathworks classes (they may depend on mwt).
err = javachk('mwt', 'The MATLAB Editor');
if ~isempty(err)
    if ~isunix
        errMessage = err.message; % cannot cannot call miedit on Windows
        errID = err.identifier;
    else
        if nargin==0    % nargin = 0 means no file specified at all.  This case is ok.
            system_dependent('miedit', '');
        else
            system_dependent('miedit', file);
        end
    end
    return
end

% Determine which editor to run.  Assume builtin editor to begin with.
builtinEd = 1;

% Get the MATLAB editor preference.
if com.mathworks.mde.editor.EditorOptions.getBuiltinEditor == 0,
    editor = char(com.mathworks.mde.editor.EditorOptions.getOtherEditor);
    % This flag should be followed by a java class that implements
    % the External Editor Interface
    if length(deblank(editor)) > 0
        if ~strncmp(editor, '-eei', 4)
            builtinEd = 0;
        end
    end
end


if builtinEd == 1
    %make call to Java
    % Try to open the Editor
    try
        if nargin==0
            com.mathworks.mlservices.MLEditorServices.newDocument;
        else
            com.mathworks.mlservices.MLEditorServices.openDocument(file);
        end % if nargin
    catch
        % Failed. Bail
        errMessage = 'Failed to open editor. Load of Java classes failed.';
        errID = 'JavaErr';
    end
    return
else
    % User-specified editor
    if ispc
        % On Windows, we need to wrap the editor command in double quotes
        % in case it contains spaces
        if nargin == 0
            eval(['!"' editor '" &'])
        else
            eval(['!"' editor '" "' file '" &'])
        end
    elseif isunix && ~strncmp(computer,'MAC',3)
        % Special case for vi
        if strcmp(editor,'vi') == 1
            editor = 'xterm -e vi';
        end

        % On UNIX, we don't want to use quotes in case the user's editor
        % command contains arguments (like "xterm -e vi")
        if nargin == 0
            eval(['!' editor ' &'])
        else
            eval(['!' editor ' "' file '" &'])
        end
    else
        % Run on Macintosh
        if nargin == 0
            openFileOnMac(editor)
        else
            openFileOnMac(editor, file);
        end
    end
end


%------------------------------------------
% Helper method to run an external editor from the Mac
function openFileOnMac(applicationName, absPath)

% Put app name in quotes
appInQuotes = ['"' applicationName '"'];

% Is this a .app -style application, or a BSD exectuable?
% If the former, use it to open the file (if any) via the 
% BSD OPEN command.
if length(applicationName) > 4 && strcmp(applicationName(end-3:end), ...
        '.app')
    % Make sure that the .app actually exists.
    if exist(applicationName) ~= 7
        error(makeErrID('ExternalEditorNotFound'), ...
            ['Could not find external editor ' applicationName]);
    end
    if nargin == 1 || isempty(absPath)
        unix(['open -a ' appInQuotes]);
    else
        unix(['open -a ' appInQuotes ' "' absPath '"']);
    end
    return;
end

% At this point, it must be BSD a executable (or possibly nonexistent)
% Can we find it?
[status, result] = unix(['which ' appInQuotes ]);

% UNIX found the application
if status == 0
    % Special case for vi and emacs since they need a shell
    if ~isempty(strfind(applicationName,'/vi')) || ...
            strcmp(applicationName, 'vi') == 1
        appInQuotes = ['xterm -e ' appInQuotes];
    elseif ~isempty(strfind(applicationName, '/emacs')) || ...
            strcmp(applicationName, 'emacs') == 1
        appInQuotes = ['xterm -e ' appInQuotes];
    end

    if nargin == 1 || isempty(absPath)
        command = [appInQuotes ' &'];
    else
        command = [appInQuotes ' "' absPath '" &'];
    end

    % We think that we have constructed a viable command.  Execute it,
    % and error if it fails.
    [status, result] = unix([command]);
    if status ~= 0
        error(makeErrID('ExternalEditorFailure'), ...
            ['Could not open external editor ' result]);
    end
    return;
else
    % We could not find a BSD executable.  Error.
    error(makeErrID('ExternalEditorNotFound'), ...
        ['Could not find external editor ' result]);
end


%------------------------------------------
% Helper function that trims spaces from a string.  Taken from the original
% edit.m
function s1 = strtrim(s)
%STRTRIM Trim spaces from string.

if isempty(s)
    s1 = s;
else
    % remove leading and trailing blanks (including nulls)
    c = find(s ~= ' ' & s ~= 0);
    s1 = s(min(c):max(c));
end


%--------------------------------------------
% Return 1 if argument is a valid name; otherwise return 0.
% Taken from the original edit.m
function returnVal = localCheckValidName(s)

% Is this a valid filename?
if isunix
    returnVal = 1;
else
    invalid = '/\:*"?<>|';
    [a b] = strtok(s,invalid);
    returnVal = strcmp(a, s);
end


%------------------------------------------
% Helper method that checks if a string specified is a directory.
% If it is a directory, a non-empty error message is returned.
function [errMessage, errID] = isDirectory(s)

errMessage = '';
errID = '';

% If argument specified is a simple filename, don't check to
% see if it is a directory (will treat as a filename only).
if isSimpleFile(s)
    return;
end

dir_result = eval(['dir(' s ')']); % need to use eval because s has quotes around it

if ~isempty(dir_result)
    dims = size(dir_result);
    if (dims(1) > 1)
        errMessage = sprintf('Can''t edit the directory %s.', s);
        errID = 'BadDir';
        return;
    else
        if (dir_result.isdir == 1)
            errMessage = sprintf('Can''t edit the directory %s.', s);
            errID = 'BadDir';
            return;
        end
    end
end


%------------------------------------------
% Helper method that checks if a file exists (exactly as typed).
% Returns 1 if exists, 0 otherwise.
function [result, absPathname] = fileExists(s, argName)

dir_result = eval(['dir(' s ')']);

% Default return arguments
result = 0;
absPathname = argName;

if ~isempty(dir_result)
    dims = size(dir_result);
    if (dims(1) == 1)
        if dir_result.isdir == 0
            result = 1;  % File exists
            % If file exists in the current directory, return absolute path
            if (isSimpleFile(s))
                absPathname = [pwd filesep dir_result.name];
            end
        end
    end
end


%------------------------------------------
% Helper method that determines if filename specified has an extension.
% Returns 1 if filename does have an extension, 0 otherwise
function result = hasExtension(s)

[pathname,name,ext] = fileparts(s);
if (isempty(ext))
    result = 0;
    return;
end
result = 1;


%--------------------------------------------
% Helper method that returns error message for file not found
%
function [errMessage, errID] = showFileNotFound(file, origArg)

if (strcmp(file, origArg))                  % we did not change the original argument
    errMessage = sprintf('File ''%s'' not found.', file);
    errID = 'FileNotFound';
else        % we couldn't find original argument, so we also tried modifying the name
    errMessage = sprintf('Neither ''%s'' nor ''%s'' could be found.', origArg, file);
    errID = 'FilesNotFound';
end


%------------------------------------------
% Helper method that checks if filename specified ends in .mex or .p.
% For mex, actually checks if extension BEGINS with .mex to cover different forms.
% If any of those bad cases are true, returns a non-empty error message.
function [errMessage, errID] = endsWithBadExtension(s)

[pathname,name,ext] = fileparts(s);
ext = lower(ext);
if (strcmp(ext, '.p') == 1)
    errMessage = sprintf('Can''t edit the P-file ''%s''.', s);
    errID = 'PFile';
    return;
end
if (~isempty(strfind(ext, '.mex')) || strcmp(ext, '.dll') == 1)
    errMessage = sprintf('Can''t edit the MEX-file ''%s''.', s);
    errID = 'MexFile';
    return;
end
errMessage = '';
errID = '';


%------------------------------------------
% Helper method that converts filename to form with
% double quotes, suitable for which
function whichArg = convertFilename(filename)

whichArg = ['''' strrep(filename, '''', '''''') ''''];


%------------------------------------------
% Helper method that checks to see if a file exists
% exactly.  If it does, tries to open file.
function [fExists, errMessage, errID] = openFileIfExists(whichArg, argName)

errMessage = '';
errID = '';
[fExists, pathName] = fileExists(whichArg, argName);

if (fExists == 1)
    [errMessage, errID] = openEditor(pathName);
end

%------------------------------------------
% Helper method that checks for directory seps.
function result = isSimpleFile(file)

result = 0;
if isunix
    if isempty(findstr(file, '/'))
        result = 1;
    end
else % on windows be more restrictive
    if isempty(findstr(file, '\')) && isempty(findstr(file, '/'))...
            && isempty(findstr(file, ':')) % need to keep : for c: case
        result = 1;
    end
end

%------------------------------------------
% Helper method for error messageID display
function realErrID = makeErrID(errIDin)

realErrID = ['MATLABeditor:'  errIDin];
