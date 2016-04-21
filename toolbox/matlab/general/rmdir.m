function [varargout] = rmdir(directory,varargin)
%RMDIR Remove directory.
%   [SUCCESS,MESSAGE,MESSAGEID] = RMDIR(DIRECTORY,MODE) removes DIRECTORY from
%   the parent directory, subject to access rights. RMDIR can remove
%   subdirectories recursively.
%
%   [SUCCESS,MESSAGE,MESSAGEID] = RMDIR(DIRECTORY) removes DIRECTORY from the
%   parent directory, only if DIRECTORY is an empty directory.
%
%   [SUCCESS,MESSAGE,MESSAGEID] = RMDIR(DIRECTORY, 's') removes DIRECTORY,
%   including the subdirectory tree, from the parent directory. See NOTE 1.
%
%   INPUT PARAMETERS:
%       DIRECTORY: string specifying a directory, relative or absolute.
%                  See NOTE 2.
%       MODE:      character scalar indicating the mode of operation.
%                  's': indicates that the subdirectory tree, implied by DIRECTORY,
%                  will be removed recursively. See NOTE 3.
%
%   RETURN PARAMETERS:
%       SUCCESS:   logical scalar, defining the outcome of RMDIR.
%                  1 : RMDIR executed successfully.
%                  0 : an error occurred.
%       MESSAGE:   string, defining the error or warning message.
%                  empty string : RMDIR executed successfully.
%                  message : an error or warning message, as applicable.
%       MESSAGEID: string, defining the error or warning identifier.
%                  empty string : RMDIR executed successfully.
%                  message id: the MATLAB error or warning message identifier
%                  (see ERROR, LASTERR, WARNING, LASTWARN).
%
%   NOTE 1: The subdirectory tree will be removed, regardless of the write
%           attribute of any contained file or subdirectory.
%   NOTE 2: UNC paths are supported. RMDIR does not support the wildcard *.
%   NOTE 3: RMDIR does not support the 's' mode under Windows 98 or
%           Millennium.
%
%   See also CD, COPYFILE, DELETE, DIR, FILEATTRIB, MKDIR, MOVEFILE.

%   JP Barnard
%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.8.4.6 $ $Date: 2004/03/12 18:07:34 $
%------------------------------------------------------------------------------
% Set up RMDIR

% handle input arguments
% we can't have less than one input argument or more than 2
ArgError = nargchk(1,2,nargin);
if ~isempty(ArgError)
    error('MATLAB:RMDIR:NumberOfInputArguments',ArgError);
end

if ~ischar(directory)   % test if directory argument is a string
    error('MATLAB:RMDIR:DirectoryName','Directory name must be a string.')
end

% check if additional arguments are strings
if ~isempty(varargin) & ~iscellstr(varargin)
    error('MATLAB:RMDIR:ArgumentType','Additional arguments must be strings.')
end

% handle output arguments
% we can't have more than three output arguments
ArgOutError = nargoutchk(0,3,nargout);
if ~isempty(ArgOutError)
    error('MATLAB:RMDIR:NumberOfOutputArguments',ArgOutError);
end

% initialise variables
rmsubdir = false;                       % Flag for "remove subdirectory structure"
mode = '';                              % Flag to enforce removal of directory
CurrentDirectory = '';
ErrorMessage='';                        % annotations to OS message
ErrorID = '';                           % RMDIR error ID
Status = 0;                             % error status.
Success = true;                         % RMDIR success status
OSMessage = '';                         % OS message

% parse additional arguments
if ~isempty(varargin)
    if ~isempty(strmatch('s',varargin{1},'exact'))
        rmsubdir = true;
        mode = 'writable';
    else
        error('MATLAB:RMDIR:InvalidOption',...
            '"%s" is an invalid option string.',varargin{1});
    end
end

%------------------------------------------------------------------------------
% Attempt removing a directory
try
    % build a directory path of valid syntax
    directory = validpath(directory,'quoted');

    % verify existence of source, before continuing
    if ~ismember('*',directory) && ~exist(strrep(directory,'"',''),'file')
        Success = false;
        error('MATLAB:RMDIR:CanNotFindFile', ...
            'Cannot find the specified directory, %s .',directory)
    end
    
    % if directory is on the MATLAB path, warn and remove
    curpath = path;
    wstate = warning('off','MATLAB:rmpath:DirNotFound');
	[lastMess lastID] = lastwarn;
    rmpath(strrep(directory,'"',''));
    warning(wstate);
	lastwarn(lastMess, lastID);
	
    if ~isequal(curpath,path)
        warning('MATLAB:RMDIR:RemovedFromPath', ...
            ['Removed %s from the MATLAB path for this MATLAB session.\n' ...
             '         See "doc path" for more information.'], directory)
    end
    
    if isunix
        %
        % UNIX file system
        %
        
        % ensure correct file separator
        directory = strrep(directory,'\',filesep);
        
        % check read-only attribute of target directory
        [DirectoryAttributes,DirectoryReadOnly] = check_writable('',directory,mode);
    
        % set destination writable
        set_unix_writable(DirectoryAttributes,DirectoryReadOnly)
        
        %
        % build the rmdir command, adding the appropriate switches when
        % we're being directed to recusively remove directories
        %
        if rmsubdir
            rmCmd = 'rm -r -f ';
        else
            rmCmd = 'rmdir ';
        end
        
        [Status, OSMessage] = unix([rmCmd, directory]);
        
        restore_unix_writable(DirectoryAttributes,DirectoryReadOnly)
        
    elseif ispc
        %
        % MS DOS file system
        %
              
        % ensure correct file separator
        directory = strrep(directory,'/',filesep);
		check_writable('',directory,mode);
        %
        % build the rmdir command, adding the appropriate switches when
        % we're being directed to recusively remove directories
        %
        if rmsubdir
            rmCmd = 'rmdir /s /q ';
        else
            rmCmd = 'rmdir ';
        end
        try
            [Status, OSMessage] = dos([rmCmd, directory]);
        catch
             % Change to safe directory in Windows when UNC path cause failures
            CurrentDirectory = pwd; % store current directory
            cd(getenv('windir')); % change to safe directory (OS root directory)
            [Status, OSMessage] = dos([rmCmd, directory]);
            cd(CurrentDirectory);
        end;
        
        % reloads non-toolbox directories. Required under Windows
        % when handling private directories
        rehash path
    end
    
    % throw applicable OS errors if an error occured (e.g., Status != 0)
    Success = Status == 0;
    if ~Success
		if Status == 5 %Access is denied.
			OSMessage = sprintf('%sUse rmdir with ''s'' mode.',OSMessage);
		end
        error('MATLAB:RMDIR:OSError','%s',OSMessage)
    end
    
catch
    Success = false;
    [ErrorMessage,ErrorID] = lasterr;
    
    %
    % reconstruct the error message/id so that it looks like it came
    % from rmdir - the first line of the error message is the MATLAB
    % error prefix, which needs to be culled from the message before
    % it's thrown again in the call to error below
    %
    if ~isempty(ErrorMessage)
	    if (strfind(ErrorMessage, 'Error using') == 1)
			[unusedLHS, ErrorMessage] = strtok(ErrorMessage,sprintf('\n'));
			if ~isempty(ErrorMessage)
			     ErrorMessage(1) = '';
			end
		end
		ErrorID = strread(ErrorID,'%s','delimiter',':');
		if ~isempty(ErrorID) && isequal(ErrorID{end}, 'WriteProtected')
			ErrorMessage = ...
				strrep(ErrorMessage,'Enforce writable','');
		ErrorMessage = sprintf('%s\nUse rmdir with ''s'' mode.', ErrorMessage);
		end
        if ~isempty(ErrorID)
			ErrorID = ['MATLAB:RMDIR:' ErrorID{end}];
		else
			ErrorID = 'MATLAB:RMDIR:UnidentifiedError';
		end
    end

    % throw error if no output arguments are specified
    if ~nargout
        error(ErrorID, '%s', ErrorMessage);
	else
		lasterr(ErrorMessage, ErrorID);
    end
end

if nargout
    varargout = { Success, ErrorMessage, ErrorID };
end

%==========================================================================
% end of RMDIR
