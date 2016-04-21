function varargout=fileattrib(varargin)
%FILEATTRIB    Set or get attributes of files and directories.
%   [SUCCESS,MESSAGE,MESSAGEID] = FILEATTRIB(FILE,MODE,USERS,MODIFIER) sets the
%   attributes of FILE, in similar fashion as ATTRIB for DOS or CHMOD for UNIX
%   and LINUX. Several attributes, delimited by spaces, may be specified at
%   once. FILE may point at a file or directory and may contain an absolute
%   pathname or a pathname relative to the current directory. 
%
%   [SUCCESS,MESSAGE,MESSAGEID] = FILEATTRIB  gets, according to the field
%   definitions of MESSAGE, the attributes of the current directory itself. See
%   RETURN PARAMETERS. See NOTE 1. 
%
%   INPUT PARAMETERS:
%       FILE:      1 x n string, defining the file or directory. See NOTE 2.
%       MODE:      space-delimited string, defining the mode of the file or
%                  directory. See NOTE 3. 
%                  'a' : archive (Windows/DOS only).
%                  'h' : hidden file (Windows/DOS only).
%                  's' : system file (Windows/DOS only).
%                  'w' : write access.
%                  'x' : executable (UNIX only).
%                  Either '+' or '-' must be added in front of each file mode to set
%                  or clear an attribute. 
%       USERS:     space-delimited string, defining which users are
%                  affected by the attribute setting. (UNIX only)
%                  'a' : all users. 
%                  'g' : group of users.
%                  'o' : other users.
%                  'u' : current user.
%                  Default attribute is dependent upon the UNIX umask.
%       MODIFIER:  character scalar, modifying the behavior of FILEATTRIB. 
%                  's' : operate recursively on files and directories in the
%                        directory subtree. See NOTE 4.
%                        Default - MODIFIER is absent or the empty string.
%
%   RETURN PARAMETERS:
%       SUCCESS:   logical scalar, defining the outcome of FILEATTRIB.
%                  1 : FILEATTRIB executed successfully.
%                  0 : an error occurred. 
%       MESSAGE:   structure array; when requesting attributes, defines file
%                  attributes in terms of the following fields (see NOTE 5):
%
%            Name: string vector containing name of file or directory
%         archive: 0 or 1 or NaN 
%          system: 0 or 1 or NaN 
%          hidden: 0 or 1 or NaN 
%       directory: 0 or 1 or NaN 
%        UserRead: 0 or 1 or NaN 
%       UserWrite: 0 or 1 or NaN 
%     UserExecute: 0 or 1 or NaN 
%       GroupRead: 0 or 1 or NaN 
%      GroupWrite: 0 or 1 or NaN 
%    GroupExecute: 0 or 1 or NaN 
%       OtherRead: 0 or 1 or NaN 
%      OtherWrite: 0 or 1 or NaN 
%    OtherExecute: 0 or 1 or NaN 
%
%       MESSAGE:   string, defining the error or warning message.
%                  empty string : FILEATTRIB executed successfully.
%                  message : error or warning message, as applicable.
%       MESSAGEID: string, defining the error or warning identifier.
%                  empty string : FILEATTRIB executed successfully.
%                  message id: error or warning message identifier.
%                  (see ERROR, LASTERR, WARNING, LASTWARN).
%
%   EXAMPLES:
%
%   fileattrib mydir\*  recursively displays the attributes of 'mydir'
%   and its contents. 
%
%   fileattrib myfile -w -s  sets the 'read-only' attribute and revokes
%   the 'system file' attribute of 'myfile'. 
%
%   fileattrib 'mydir' -x  revokes the 'executable' attribute of 'mydir'.
%
%   fileattrib mydir '-w -h'  sets read-only and revokes hidden attributes
%   of 'mydir'. 
%
%   fileattrib mydir -w a s  revokes, for all users, the 'writable'
%   attribute from 'mydir' as well as its subdirectory tree.
%
%   fileattrib mydir +w '' s  sets 'mydir', as well as its subdirectory tree,
%   writable. 
%
%   fileattrib myfile '+w +x' 'o g'  sets the 'writable' and 'executable'
%   attributes of 'myfile' for other users as well as group.
%
%   [SUCCESS,MESSAGE,MESSAGEID] = fileattrib('mydir\*'); if successful,
%   returns the success status 1 in SUCCESS, the attributes of 'mydir' and its
%   subdirectory tree in the structure array MESSAGE. If a warning was issued,
%   MESSAGE contains the warning, while MESSAGEID contains the warning message
%   identifier. In case of failure, SUCCESS contains success status 0, MESSAGE
%   contains the error message, and MESSAGEID contains the error message
%   identifier. 
%
%   [SUCCESS,MESSAGE,MESSAGEID] = fileattrib('myfile','+w +x','o g') sets the
%   'writable' and 'executable' attributes of 'myfile' for other users as well
%   as group. 
%
%
%   NOTE 1: When FILEATTRIB is called without return arguments and an error
%           has occurred while executing FILEATTRIB, the error message is
%           displayed.
%   NOTE 2: UNC paths are supported. The * wildcard, as a suffix to the last
%           name or the extension  to the last name in a path string, is
%           supported.
%   NOTE 3: Operating system specific attribute modifiers apply; therefore
%           specifying invalid modifiers will result in error messages.
%   NOTE 4: On Windows 2000 and later: equivalent to ATTRIB switches /s /d. 
%           The MODIFIER, 's', is not supported on pre-Windows 2000 platforms.
%           Specifying the MODIFIER 's' on pre-Windows 2000 platforms causes a
%           warning.
%   NOTE 5: Attribute field values are type logical. NaN indicates that an
%           attribute is not defined for a particular operating system. 
%
%   See also CD, COPYFILE, DELETE, DIR, MKDIR, MOVEFILE, RMDIR.

%   JP Barnard
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.15.4.8 $ $Date: 2004/03/12 18:07:30 $
%-------------------------------------------------------------------------------
% Set up FILEATTRIB

% initialise variables
File = '';
CurrentDirectory = '';
Mode = '';                       % file Mode
ModeSwitch = '';                 % optional command switches
Users = '';                      % users attribute of file or directory
Message = '';
ErrorID = '';                    % Identification code of error
Status = 0;                      % OS call status
Success = true;                  % FILEATTRIB success status
OSMessage = '';                  % raw OS message
GetAttributes = 0;               % flag indicating to get file attributes
FileAttributeThisFile = [];
FileAttributes = [];
AttributeVector = [];
ValidUnixModes = ' +-wx';        % allowed file modes
ValidWinModes = ' +-ashw';       % allowed file modes
ValidUsers = ' +-augo';          % allowed user groups
ThisFile = '';
WinSwitches = [];

% Handle input arguments
% we can't have more than 4 inputs
ArgError = nargchk(0,4,nargin); 
if ~isempty(ArgError)
   error('MATLAB:FILEATTRIB:NumberOfInputArguments',ArgError);
end

% test if input arguments are strings
if ~ischar(File)   
    error('MATLAB:FILEATTRIB:ArgumentType','FILE must be a string.')
end

% check if additional arguments are strings
if ~isempty(varargin) & ~iscellstr(varargin) 
    error('MATLAB:FILEATTRIB:ArgumentType',...
	  'Additional arguments must be strings.')
end

% handle output arguments
% we can't have more than three output arguments
ArgOutError = nargoutchk(0,3,nargout); 
if ~isempty(ArgOutError)
   error('MATLAB:FILEATTRIB:NumberOfOutputArguments',ArgOutError);
end

% extract optional arguments
if ~isempty(varargin)  % get settings for new file attributes
   
   if size(varargin,2)>=1
      File = varargin{1};end
   if size(varargin,2)>=2,
      Mode = lower(varargin{2});end
   if size(varargin,2)>=3,
      Users = lower(varargin{3});end
   if size(varargin,2)>=4,
      ModeSwitch  = lower(varargin{4});end
end

% when only a file name is specified, 
%    the user wants the attributes of that file/directory
if isempty(varargin) || (isempty(Mode) && isempty(Users))
   GetAttributes = 1; % set flag to get specified file attributes
end

% Build a file path that has valid, full path syntax.

%-------------------------------------------------------------------------------
% Attemp setting or getting file|directory attributes
try
   File = validpath(File);

   % verify existence of File, before continuing
   if isempty(regexp(File, '\*','once')) && ~exist(File,'file')
      Success = false;
      OSMessage = 'Can not find specified file or directory.';
      error('MATLAB:FILEATTRIB:CannotFindFile',OSMessage)
   end

   if isunix
      % for UNIX   
      % validate file mode vector
      if ~GetAttributes && ~all(ismember(Mode,ValidUnixModes))
         error('MATLAB:FILEATTRIB:SyntaxError',...
            'Illegal file mode characters for UNIX.')
      end
      if ~GetAttributes && ~all(ismember(Users,ValidUsers))
         error('MATLAB:FILEATTRIB:SyntaxError',...
            'Illegal file user characters.')
      end

      % validate FILEATTRIB modifier
      % either the user specify 's' or use wildcard * to terminate File string
      
      if (~isempty(ModeSwitch) && strcmpi(ModeSwitch,'s')) || ...
              strcmp(File(end-1:end),'/*')
         ModeSwitch = '-R ';
      elseif ~isempty(ModeSwitch) % the user specified an invalid modifier character
         error('MATLAB:FILEATTRIB:SyntaxError','Illegal FILEATTRIB modifier string.');
      end
      
      % remove all spaces from Mode. UNIX errors out on spaces in the mode string
      Mode = strrep(Mode,' ',''); 
      
      % Getting specified file attributes
      if GetAttributes
         [Status,OSMessage]=unixgetattrib(File,ModeSwitch);
      else
         % set file attributes
         [Status, OSMessage] = unix(['chmod ', ModeSwitch,Users,Mode, ' ', ...
               validpath(File,'quoted')]);
      end
      
   else  %PC
      % validate file mode vector
      if ~GetAttributes && ~all(ismember(Mode,ValidWinModes))
         error('MATLAB:FILEATTRIB:SyntaxError',...
            'Illegal file mode characters for Windows.')
      end
      if ~GetAttributes && ~isempty(Users)
         warning('MATLAB:FILEATTRIB:SyntaxWarning',...
            'File user characters ignored on Windows.')
      end
      
      % find version of Windows
      try
          WinSwitches=setwinfileattrib;
      catch
          %first place DOS commands are used.  Might fail, in which case we
          %do a cdsafewindir and retry
          
           % Change to safe directory in Windows when UNC path cause
           % failures
          CurrentDirectory = pwd; % store current directory
          cd(getenv('windir')); % change to safe directory (OS root directory)
          WinSwitches=setwinfileattrib;
          cd(CurrentDirectory);
      end
      
      % validate FILEATTRIB modifier
      % either the user specify 's' or use wildcard * to terminate File string
      if (~isempty(ModeSwitch) && strcmpi(ModeSwitch,'s')) || ...
              strcmp(File(end-1:end),'\*')
          if ~WinSwitches.Win2000
              % Warn about behavior of ATTRIB on non Windows 2000 platforms
              warning('MATLAB:FILEATTRIB:ModeSwitch',...
                  ['Pre-Windows 2000 OS does not ',... 
                      'set or get attributes of subdirectories.'])
          end
          % set mode switch of ATTRIB
          ModeSwitch = WinSwitches.Subdir;
          
      elseif ~isempty(ModeSwitch) 
          % the user specified an invalid modifier character
          error('MATLAB:FILEATTRIB:SyntaxError',...
              'Illegal FILEATTRIB modifier string.');
      end
    
      try
          if GetAttributes
             % Get file attributes
             [Status,OSMessage]=wingetattrib(File,ModeSwitch);
          else 
             [Status,OSMessage]=winsetattrib(File,Mode,Users,ModeSwitch);   
          end
      catch
          %may be first place DOS commands are used.  Might fail, in which case we
          %do a cdsafewindir and retry
          
           % Change to safe directory in Windows when UNC path cause
           % failures
          CurrentDirectory = pwd; % store current directory
          cd(getenv('windir')); % change to safe directory (OS root directory)
          if GetAttributes
             % Get file attributes
             [Status,OSMessage]=wingetattrib(File,ModeSwitch);
          else 
             [Status,OSMessage]=winsetattrib(File,Mode,Users,ModeSwitch);   
          end
          cd(CurrentDirectory);
      end          
   end % if computer type
   
   Success = Status == 0;
   if ispc,
     [Success, OSMessage] = ...
         RectifyWinFileAttribStatus(Success,OSMessage,GetAttributes,...
                                    WinSwitches.Win2000,File); 
   end
   
   % on failure, throw error.
   if ~Success
      error('MATLAB:FILEATTRIB:OSError','%s',OSMessage)
   end
   
catch
   Success = false;
   [OSMessage,ErrorID] = lasterr;
   if nargout < 3
       rethrow(lasterror);
   end
end
%-------------------------------------------------------------------------------

% Convert OS reply on file attributes to a consistent attribute array

if Success && GetAttributes
   % transfer file attribute structure to message field of FILEATTRIB
   try
       Message = parseattrib(File,OSMessage,WinSwitches);
   catch
        rethrow(lasterror);
   end
else
   Message = OSMessage;
end %

%------------------------------------------------------------------------------
% Handle output from FILEATTRIB

% Parse output values to output parameters, if output arguments are specified
if nargout
   if ~Success		% repack error message into desired format
      Message = strread(Message,'%s','delimiter','\n');
      Message = strvcat(Message(2:end)); 
   end
   varargout = { Success, Message, ErrorID };

else		% output results to the MATLAB Command Window
	% only skip a line on screen when there is a message
   if ~isempty(Message)          
      fprintf('\n'); 
   end

   if isstruct(Message)	% display attribute structure per element
      for i = 1:length(Message)
			% display each file object's attribute structure
         disp(Message(i)) 
      end

   else
      disp(Message) % display OS or MATLAB message
   end
end
  
%==============================================================================

% RectifyWinFileAttribStatus. Correct the OS status reply on Windows.
% Different Windows versions are inconsistent regarding status and
% errors.  We consistently return logical 1 on success and 0 on failure.  
% Success =
% ConsolidateFileAttribStatus(Status,OSMessage,GetAttributes,Win2000) 
% Input:
%        Status: scalar double defining the status output from OS calls
%        OSMessage: string array defining OS call message outputs
%        GetAttributes: logical scalar indicating retrieval of file attributes 
%        Win2000: logical scalar indicating if it's Windows 2000 we're
%                 running on
% Return:
%        Success: logical scalar defining outcome of COPYFILE
%------------------------------------------------------------------------------
function [Success, OSMessage] = RectifyWinFileAttribStatus(Success,OSMessage,...
                                                  GetAttributes,Win2000,File)
%------------------------------------------------------------------------------
if (isempty(OSMessage))
    return;
end

if Success,
  if ~GetAttributes && Win2000
    Success = false; % an error occurred in DOS around setting attributes.
    
  elseif isdir(File) && ... 
        ~isempty(strfind(lower(OSMessage),'file not found'))
    % Win98, WinME and DOS shell command causes false error when
    % directory is empty. Set the default attrib return string on the
    % file object. This is the best we can do. Also, DOS attrib does
    % not give us the info for the root directory.
    OSMessage = ['           ', File];
    
  elseif GetAttributes && length(OSMessage)>6 
      if regexp(OSMessage(1:6),'[^RASH\s]','once') 
        Success = false; % an error occurred in DOS around getting attributes.
      end
  end
end
%------------------------------------------------------------------------------
return
% end of RectifyWinFileAttribStatus
%==============================================================================

% SETWINFILEATTRIB. Set ATTRIB switches for various Windows platforms
% Return:
%        WinCopySwitches: struct scalar defining copy and xcopy switches
%           .Win2000: logical scalar defining post Windows 2000
%           .Subdir:  string indicating that attributes of subdirectories will be
%                     retrieved
%
% JP Barnard
%------------------------------------------------------------------------------
function [WinFileAttribSwitches]=setwinfileattrib
%------------------------------------------------------------------------------

% find version of Windows
% XXX what happens if Status is 0 (e.g., what happens if the dos command
% XXX fails?)
persistent Switches;
if isempty(Switches)
    
    [Status,WinVersion] = dos('ver');

    % set DOS attrib subdirectory switch
    if length(strfind(WinVersion,'Windows 2000')) || length(strfind(WinVersion,'Windows XP')) 
       Switches.Subdir = ' /s /d';  
       Switches.Win2000 = true;
    else
       Switches.Win2000 = false;
       Switches.Subdir = ' /s';
    end
end
    WinFileAttribSwitches = Switches;
return
%===============================================================================

% WINGETATTRIB. get file and directory attributes on various Windows platforms
% 
% Input:
%        File: string defining file path
%        ModeSwitch: string indicating retrieval of attributes of directory
%                    contents
% Return:
%        Status: OS command status
%        OSMessage: string containing OS message, if any.
%------------------------------------------------------------------------------
function [Status,OSMessage]=wingetattrib(File,ModeSwitch)
%------------------------------------------------------------------------------
% Get file attributes
if strcmp(File(end-1:end),'\*')
   % user specified directory name with wildcard; 
   % apply mode switch s
   [Status,OSMessage]=dos(['attrib ',validpath(File,'quoted'), ModeSwitch]);
elseif isdir(File) ... 
      && length(strfind(ModeSwitch,'s'))...
      && ~strcmp(File(end-1:end),'\*')
   % user specified directory name with mode-switch s
   % replace closing double quote with '\*"' string
   File = [File '\*'];
   [Status,OSMessage]=dos(['attrib ',validpath(File,'quoted'), ModeSwitch]);
else
   [Status,OSMessage]=dos(['attrib ',validpath(File,'quoted')]);
end
%-------------------------------------------------------------------------------
return
%===============================================================================

% WINSETATTRIB. set file and directory attributes on various Windows platforms
% 
% Input:
%        File: string defining file path
%        Mode: string defining file or directory attributes to be set
%        Users: string defining users with access to file objects in File to be
%               set
%        ModeSwitch: string indicating retrieval of attributes of directory
%                    contents
% Return:
%        Status: OS command status
%        OSMessage: string containing OS message, if any.
%------------------------------------------------------------------------------
function [Status,OSMessage]=winsetattrib(File,Mode,Users,ModeSwitch)
%------------------------------------------------------------------------------
% Set file attributes
% translate writable file attribute
if ismember('w',Mode)
   Mode = strrep(Mode,'+w','-r'); % read-only is switched off
   Mode = strrep(Mode,'-w','+r'); % read-only is switched on
end

% If specified, issue warning: File User attributes are ignored for DOS. 
if ~isempty(Users)
   warning('MATLAB:FILEATTRIB:SyntaxWarning',...
      'User attributes are ignored for DOS.')
end

% set attribute of file|directory
[Status, OSMessage] = dos(['attrib ', Mode, ' ', validpath(File, 'quoted')]);

%Undo the translation above!
OSMessage = strrep(OSMessage,'Invalid switch - -r', 'Invalid switch: +w');
OSMessage = strrep(OSMessage,'Invalid switch - +r', 'Invalid switch: -w');

% set attributes for a directory under the influence of ModeSwitch.
if isdir(File) && length(strfind(ModeSwitch,'s'))
   % set attributes of subdirectories and files in parent directory
   [Status, OSMessage] = dos(['attrib ', Mode,' ',validpath(File, 'quoted'),...
           '\*', ModeSwitch]); 
end
%-------------------------------------------------------------------------------
return
%===============================================================================

% UNIXGETATTRIB. get file and directory attributes on UNIX platforms
% 
% Input:
%        File: string defining file path
%        ModeSwitch: string indicating retrieval of attributes of directory
%                    contents
% Return:
%        Status: OS command status
%        OSMessage: string containing OS message, if any.
%------------------------------------------------------------------------------
function [Status,OSMessage]=unixgetattrib(File,ModeSwitch)
%------------------------------------------------------------------------------
% Get file attributes
% use \ls ... to bypass aliases to ls.
if strcmp(File(end-1:end),'/*')
   % user specified directory name with wildcard; 
   % apply mode switch
   File = validpath(File(1:end-2), 'quoted');
   [Status,OSMessage]=unix(['\ls -l ',ModeSwitch, File]);
elseif isdir(File) ... 
      && length(strfind(ModeSwitch,'-R'))...
      && ~strcmp(File(end-1:end),'/*')
   % The user specified directory name with mode-switch.
   % Replace closing double quote with '/"*' string.
   % The user did not indicate pwd by using '.'
   if ~length(strfind(File,'.'))
      [Status,OSMessage]=unix(['\ls -l ',ModeSwitch,validpath(File,'quoted')]);
   else
      % the use did indicate pwd by using '.'
      [Status,OSMessage]=unix(['\ls -l ',ModeSwitch,validpath(File,'quoted')]);
   end   
else
   [Status,OSMessage]=unix(['\ls -l -d ',validpath(File,'quoted')]);
end

%-------------------------------------------------------------------------------
return
%===============================================================================

% PARSEATTRIB. parse file and directory attributes into a struct array
% 
% Input:
%        OSMessage: string containing OS message, if any.
%        WinSwitches: struct scalar defining pre-Win2000 platform
% Return:
%        FileAttributes: struct array containing file object attributes 
%                           OR
%                        string containing OS message
%------------------------------------------------------------------------------
function [FileAttributes]=parseattrib(File,OSMessage,WinSwitches)
%------------------------------------------------------------------------------

FileAttributeThisFile = [];
FileAttributes = [];
AttributeVector = [];
ThisFile = '';
ThisFilename = '';
ThisFileParent = '';
UNIXFieldsToFilename = 9;

% parse OS message into a structure defining file attributes
% For empty text array of file attributes, return empty attributes array.
if isempty(OSMessage)
    FileAttributes = [];
    return;
end

% ensure full path for filename
if ~isempty(File) && File(1)~='/';
   File = strrep(fullfile(pwd,File),'//','/');
end

% clean File of * or . 
if ~isempty(File)
	if File(end) =='.'
		File = File(1:end-1);
	end
	if File(end) =='*'
		File = File(1:end-1);
	end
end

% Parse directory listing into cell string array
FileAttributeArray = strread(OSMessage,'%s','delimiter','\n','whitespace',''); 

% initialise valid entries index vector
keepentries = true(size(FileAttributeArray)); 

if isunix
     [Status,OSMessage1]=unix(['\ls -al ']);
     FileArray = strread(OSMessage1,'%s','delimiter','\n','whitespace',''); 
     FirstFile = strread(FileArray{2},'%s','whitespace',' ');
     if isequal(char(FirstFile(end)),'.')
         UNIXFieldsToFilename = length(FirstFile);
     end
end
% locate specified file in directory listing
for i = 1:length(FileAttributeArray)
   
   if isempty(FileAttributeArray{i}),
      % set flag exclude this row from attrib struct array
      keepentries(i) = false;  
      continue, 
   end
   if length(strfind(lower(OSMessage),'file not found'))
      % set flag exclude this row from attrib struct array
      keepentries(i) = false;
      continue
   end
   
   % pick this file's attribute string
   FileAttributeThisFile = FileAttributeArray{i};      
   
   % extract file name from file attribute string
   ThisFile = strread(FileAttributeThisFile,'%s','whitespace',' ');

   % handle UNIX file system specific attribute string
   if isunix 
      
      % extract the partial directory of the ls listing for the current
      % file object 
      if ~isempty(ThisFile)
		  if strfind(ThisFile{1},':')
			 ThisFileParent = strrep(strtok(ThisFile{1},':'),'.','');
		  end
	  end
      % build file attributes structure from attribute string of specified file
      if length(FileAttributeThisFile)>10 && ...
            (any(FileAttributeThisFile(1:10)=='drwxrwxrwx') || ...
            any(FileAttributeThisFile(1:10)=='----------'))

         % extract filename
         % Assumption 1: POSIX specify the number fields in ls -l
         % Assumption 2: The time field, as all fields, is delimited by a
         % space from the path string that follows.
         % Assumption 3: The time field in a line of ls -l output is unique.
         if length(ThisFile)>=UNIXFieldsToFilename
            [idxOfDate] = strfind(FileAttributeThisFile,...
                          ThisFile{UNIXFieldsToFilename-1});
            ThisFilename = FileAttributeThisFile(idxOfDate+...
                           length(ThisFile{UNIXFieldsToFilename-1})+1:end);
         end
         
         % construct a full file path of file object from ls listing
         if isempty(ThisFileParent) && ~isempty(ThisFilename) && ThisFilename(1)~='/'
            % The ls file item does not list an absolute path and its
            % parent is empty.
            ThisFileParent = File;
            
         elseif ~isempty(ThisFileParent) && ThisFileParent(1)~='/' ...
               && ~isempty(ThisFilename) && ThisFilename(1)~='/'
            % The ls file item and its parent path are not absolute. 
            ThisFileParent = ...
               strrep(fullfile(pwd,ThisFileParent),'//','/');
         end
         % The ls file item lists an absolute path to the file object.
         ThisFilename = strrep(fullfile(ThisFileParent,ThisFilename),'//','/');;
         
         % set array of matching attribute string into cellarray
         AttributeVector = num2cell(FileAttributeThisFile(1:10)=='drwxrwxrwx');
         
         % prepend NaN non-Unix file attributes
         AttributeVector = [{NaN},{NaN},{NaN},AttributeVector]; 
      else
         keepentries(i) = false; % set flag to exclude annotation entries
         continue
      end
      
      % handle PC file system specific attribute string   
   elseif ispc
      
       % for valid attribute entries
       if any(FileAttributeThisFile([3,6:8])=='ASHR') || ...
               any(FileAttributeThisFile([1,4:6])=='ASHR') || ...
               any(FileAttributeThisFile([3,6:8])=='    ') || ...
               any(FileAttributeThisFile([1,4:6])=='    ')
            
           % extract filename from file attribute string
           % The Windows/DOS ATTRIB output always displays the full path of
           % a file or directory.
           ThisFilename = ...
           FileAttributeThisFile(regexp(FileAttributeThisFile,'(.:|\\\\)'):end);
                      
           % for PC, parse information about file from OS reply
           AttributeVectorPC = num2cell(FileAttributeThisFile([1,4:6])=='ASHR');
           
           AttributeVector = ...
               [AttributeVectorPC(1:3),...   % PC specific attributes
                   {isdir(ThisFilename)},...      % is this file a directory?
                   {1},...                    % all files are readable on PC 
                   {~AttributeVectorPC{4}},...% Read-only flip writeable attribute
                   {1},...                    % all files are executable on PC
                   {NaN, NaN, NaN, NaN, NaN, NaN}];  % append NaN for non-PC file attributes
       else
           keepentries(i) = false; % set flag to exclude annotation entries
           continue
       end

   end
   
   % build file attribute structure
   FileAttributes(i).Name = ThisFilename;
   [FileAttributes(i).archive,...
         FileAttributes(i).system,...
         FileAttributes(i).hidden,...
         FileAttributes(i).directory,...
         FileAttributes(i).UserRead,...
         FileAttributes(i).UserWrite,...
         FileAttributes(i).UserExecute,...
         FileAttributes(i).GroupRead,...
         FileAttributes(i).GroupWrite,...
         FileAttributes(i).GroupExecute,...
         FileAttributes(i).OtherRead,...
         FileAttributes(i).OtherWrite,...
         FileAttributes(i).OtherExecute] = deal(AttributeVector{:});
end

% remove empty cells
FileAttributes = FileAttributes(keepentries); 

%-------------------------------------------------------------------------------
return
%==========================================================================
