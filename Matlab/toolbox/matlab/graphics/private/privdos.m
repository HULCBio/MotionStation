function [status, result] = privdos( varargin )
%DOS Execute DOS command in save current directory and return result.
%   Uses built-in DOS command after changing the current directory to
%   one that is not a UNC path or nested too deeply to work reliably.
%
%   See also DOS.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.6 $  $Date: 2002/04/10 17:09:34 $

if ~strncmp(computer,'PC',2),
    error('Printjob DOS method called on non-DOS based platform.')
end

wasErr = 0;
dberror = disabledberror;
try
    %Check to see if cwd is going to be a problem.
    %UNC test is new (DOS doesn't work on UNC path), CD test is from Jason:
    %If cwd is bad, move to what is considered the temporary directory
    %or c:\ if tempdir is itself a UNC directory.
    if strncmp(tempdir, '\\', 2)
        tdir = 'c:\';
    else
        tdir = tempdir;
    end
    OldDir = pwd;
    if strncmp( OldDir, '\\', 2 ) %i.e. path starts with \\
        cd(tdir)
    else
        % This is to check and see if the dos command is working.  In Win95
        % if the current directory is a deeply nested directory or sometimes
        % for TAS served file systems, the output pipe does not work.  The 
        % solution is to make the current directory safe, C:\ and put it back
        % when we are done.  The test is the cd command, which should always
        % return something.
	try
	  [status, result] = dos('cd');
	catch
	  result = '';
	end
	if isempty(result)
            cd(tdir)
        else
            OldDir = [];
        end
    end

    %Execute the given DOS command.
    try
      [status, result] = dos(varargin{2:end});
    catch
      % Try dos with one output if last command fails.
      status = dos(varargin{2:end});
      result = '';
    end
catch
    wasErr = 1;
end
enabledberror(dberror);

%Move back if neccesary.
if ~isempty(OldDir)
    cd(OldDir);
end

if wasErr
    error(lasterr)
end

