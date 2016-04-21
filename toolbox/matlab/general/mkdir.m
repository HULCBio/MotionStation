function varargout=mkdir(varargin)
%MKDIR Make new directory.
%   [SUCCESS,MESSAGE,MESSAGEID] = MKDIR(PARENTDIR,NEWDIR) makes a new directory,
%   NEWDIR, under the parent, PARENTDIR. While PARENTDIR may be an absolute
%   path, NEWDIR must be a relative path. When NEWDIR exists, MKDIR returns
%   SUCCESS = 1 and issues to the user a warning that the directory already
%   exists.
%
%   [SUCCESS,MESSAGE,MESSAGEID] = MKDIR(NEWDIR) creates the directory NEWDIR
%   in the current directory, if NEWDIR represents a relative path. Otherwise,
%   NEWDIR represents an absolute path and MKDIR attempts to create the absolute
%   directory NEWDIR in the root of the current volume. An absolute path starts
%   in any one of a Windows drive letter, a UNC path '\\' string or a UNIX '/'
%   character. 
%
%   [SUCCESS,MESSAGE,MESSAGEID] = MKDIR(PARENTDIR,NEWDIR) creates the
%   directory NEWDIR in the existing directory PARENTDIR. 
%
%   INPUT PARAMETERS:
%       PARENTDIR: string specifying the parent directory. See NOTE 1.
%       NEWDIR:    string specifying the new directory. 
%
%   RETURN PARAMETERS:
%       SUCCESS:   logical scalar, defining the outcome of MKDIR. 
%                  1 : MKDIR executed successfully.
%                  0 : an error occurred.
%       MESSAGE:   string, defining the error or warning message. 
%                  empty string : MKDIR executed successfully.
%                  mescsage : an error or warning message, as applicable.
%       MESSAGEID: string, defining the error or warning identifier.
%                  empty string : MKDIR executed successfully.
%                  message id: the MATLAB error or warning message identifier
%                  (see ERROR, LASTERR, WARNING, LASTWARN).
%
%   NOTE 1: UNC paths are supported. 
%
%   See also CD, COPYFILE, DELETE, DIR, FILEATTRIB, MOVEFILE, RMDIR.

%   JP Barnard
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.37.4.6 $ $Date: 2004/01/28 23:10:58 $
% -----------------------------------------------------------------------------

% Set up MKDIR

% test if source and destination arguments are strings
% handle input arguments
ArgError = nargchk(1,2,nargin);  % Number of input arguments must be 1 of 2.
if ~isempty(ArgError)
   error('MATLAB:MKDIR:NumberOfInputArguments',ArgError);
end

% check if additional arguments are strings
if ~isempty(varargin) & ~iscellstr(varargin) 
   error('MATLAB:MKDIR:ArgumentType','Arguments must be strings')
end

% handle output arguments
% Number of output arguments must be 1 to 3.
ArgOutError = nargoutchk(-1,3,nargout);  
if ~isempty(ArgOutError)
   error('MATLAB:MKDIR:NumberOfOutputArguments',ArgOutError);
end

% Initialise variables.
Success = true;
OldDir = '';
ErrorMessage='';  % annotations to raw OS error message
ErrorID = '';
Status = 0;
OSMessage = '';   % raw OS message

% handle input arguments
if nargin == 1
   % Mode 1: create a new directory inside current directory,
   % except when the input argument is a full path.
   if isempty(regexp(varargin{1},'^(\w:|\\\\)')) && ...
           isempty(regexp(varargin{1},'^/|~'))
       % the first input parameter contains a relative path. 
       Parentdir = pwd;
       NewDirName = varargin{1};
   else
       % the first input parameter contains a full path
       % assume parent directory is the current directory
       Parentdir = '';
       NewDirName = varargin{1};
   end
elseif nargin == 2
   % Mode 2: create a new directory inside a specified directory
   if ~isempty(varargin{2})
      Parentdir = varargin{1};
      NewDirName = varargin{2};
      
   else
      error('MATLAB:MKDIR:ArgumentIndeterminate',...
         'Second directory argument is an empty string.');
   end
end

% -----------------------------------------------------------------------------
% Attempt to make directory
try
    % Build full path that has valid path syntax.
    Directory = constructabspath(Parentdir,NewDirName);
    
    % Test for existance of directory
    if isdir(strrep(Directory,'"',''))
        WarningMessage = sprintf('Directory %s already exists.', Directory);
        WarningID = 'MATLAB:MKDIR:DirectoryExists';
        
        if nargout
            varargout{1} = Success;
            varargout{2} = WarningMessage;
            varargout{3} = WarningID;
        else
            warning(WarningID, '%s', WarningMessage);
        end
        return
    end
    
    if isunix
        %
        % UNIX file system
        %
    
        % ensure correct file separator
        Directory = strrep(Directory,'\',filesep);
        
        % make directory structure
        [Status, OSMessage] = unix(['mkdir -p ' Directory]); 
        
    elseif ispc
        %
        % MS DOS file system
        %
        
        % ensure correct file separator
        Directory = strrep(Directory,'/',filesep);
        try
            % make directory structure
            [Status, OSMessage] = dos(['mkdir ' Directory]);
        catch
            % Change to safe directory in Windows when UNC path cause failures
             CurrentDirectory = pwd; % store current directory
             cd(getenv('windir')); % change to safe directory (OS root directory)
             [Status, OSMessage] = dos(['mkdir ' Directory]);
             cd(CurrentDirectory);
        end       
    end % if computer type
    
    % throw applicable OS errors if an error occured (e.g., Status != 0)
    Success = Status == 0;
    if ~Success
        error('MATLAB:MKDIR:OSError','%s',OSMessage) 
    end
    
catch
    Success = false;
    [ErrorMessage,ErrorID] = lasterr;
    
    % throw error if no output arguments are specified
    if ~nargout
        rethrow(lasterror);
    end
end

if nargout,
  varargout = { Success, ErrorMessage, ErrorID };
end

%==============================================================================
% end of MKDIR

% CONSTRUCTABSPATH - makes absolute directory name from parent and new dir
% 
% Input:
%        Parentdir: string defining parent directory
%        NewDirName: string defining new directory
% Return:
%        Directory: string defining full path to new directory
%------------------------------------------------------------------------------
function [Directory] = constructabspath(Parentdir,NewDirName)
%------------------------------------------------------------------------------
% Add double quotes around the source and destination files 
%       so as to support file names containing spaces. 
  
if ~isempty(Parentdir)
    % Throw error if UNC path is found in new directory name
    % and parent is not empty.
    if strncmp('\\',NewDirName,2)
        error('MATLAB:MKDIR:DirectoryIsUNC',...
            'Cannot create UNC directory inside %s',Parentdir);
        
    elseif ~isempty(Parentdir) && ~isempty(regexp(NewDirName,'^(.:)'))
        % Throw error if new directory name implies an absolute path
        % and parent dirctory name is not empty.
        error('MATLAB:MKDIR:DirectoryContainsDriveLetter',...
            'Cannot create absolute directory inside %s',Parentdir);
        
    elseif isunix && ~isempty(Parentdir) && strncmp(NewDirName,'/',1)
        % Throw error if new directory name implies an absolute path
        % and parent dirctory name is not empty.
        error('MATLAB:MKDIR:DirectoryIsAbsolute',...
            'Cannot create absolute directory inside %s',Parentdir);
    end
end

Directory = validpath(fullfile(Parentdir,NewDirName),'quoted');

return
%===============================================================================
