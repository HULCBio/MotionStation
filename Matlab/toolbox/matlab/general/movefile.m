function varargout=movefile(SourceFile,DestinationFile,varargin)
%MOVEFILE Move file or directory.
%   [STATUS,MESSAGE,MESSAGEID] = MOVEFILE(SOURCE,DESTINATION,MODE) moves the
%   file or directory SOURCE to the new file or directory DESTINATION. Both
%   SOURCE and DESTINATION may be either an absolute pathname or a pathname
%   relative to the current directory. When MODE is used, MOVEFILE moves SOURCE
%   to DESTINATION, even when DESTINATION is read-only. The DESTINATION's
%   writable attribute state is preserved. See NOTE 1.
%
%   [STATUS,MESSAGE,MESSAGEID] = MOVEFILE(SOURCE)  moves the source to the
%   current directory. See NOTE 2.
%
%   [STATUS,MESSAGE,MESSAGEID] = MOVEFILE(SOURCE,DESTINATION) attempts to move
%   SOURCE to DESTINATION. If SOURCE ends in the wildcard *, all matching file
%   objects are moved to DESTINATION (see NOTE 3). If DESTINATION is a directory,
%   MOVEFILE moves SOURCE under DESTINATION. If SOURCE is a directory or ends in
%   a *, and DESTINATION does not exist, MOVEFILE creates DESTINATION as a
%   directory and moves SOURCE under DESTINATION. If SOURCE is a single file and
%   DESTINATION is not a directory or does not exist, SOURCE is effectively
%   renamed to DESTINATION.
%
%   [STATUS,MESSAGE,MESSAGEID] = MOVEFILE(SOURCE,DESTINATION,'f') attempts to
%   move SOURCE to DESTINATION, as above, even if DESTINATION is read-only. The
%   status of the writable attribute of DESTINATION will be preserved.
%
%   INPUT PARAMETERS:
%       SOURCE:      1 x n string defining the source file or directory. See NOTE 4.
%       DESTINATION: 1 x n string defining destination file or directory. See
%                    NOTE 4.
%       MODE:        character scalar defining copy mode.
%                    'f' : force SOURCE to be written to DESTINATION. See NOTE 5.
%                    If omitted, MOVEFILE respects the current writable status
%                    of DESTINATION.
%
%   RETURN PARAMETERS:
%       SUCCESS:     logical scalar, defining the outcome of MOVEFILE.
%                    1 : MOVEFILE executed successfully.
%                    0 : an error occurred.
%       MESSAGE:     string, defining the error or warning message.
%                    empty string : MOVEFILE executed successfully.
%                    message : an error or warning message, as applicable.
%       MESSAGEID:   string, defining the error or warning identifier.
%                    empty string : MOVEFILE executed successfully.
%                    message id: the MATLAB error or warning message identifier
%                    (see ERROR, LASTERR, WARNING, LASTWARN).
%
%   NOTE 1: Except where otherwise stated, the rules of the underlying operating
%           system on the preservation of attributes are followed when moving
%           files and directories.
%   NOTE 2: MOVEFILE cannot move a file onto itself.
%   NOTE 3: MOVEFILE cannot move multiple files onto one file.
%   NOTE 4: UNC paths are supported. The * wildcard, as a suffix to the last name
%           or the extension to the last name in a path string, is supported.
%   NOTE 5: 'writable' is being deprecated, but still supported for backwards
%           compatibility.
%
%   See also CD, COPYFILE, DELETE, DIR, FILEATTRIB, MKDIR, RMDIR.

%   JP Barnard
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.8.4.7 $ $Date: 2004/03/12 18:07:33 $
%------------------------------------------------------------------------------
% Set up MOVEFLE

% initialise variables
CurrentDirectory = '';
ErrorMessage='';  % annotations to raw OS error message
ErrorMessageReturn='';
ErrorID='';
Status = 0;
Success = true;
OSMessage = '';   % raw OS message
mode = '';        % default "force write attribute" is off
DestinationReadOnly = [];
SourceParentReadOnly = [];
CheckForMoveOverSelf = false;

% handle input arguments
% number of inputs from 1 through 3.
ArgError = nargchk(1,3,nargin);
if ~isempty(ArgError)
   error('MATLAB:MOVEFILE:NumberOfInputArguments',ArgError);
end

% default destination is the current directory
if ~exist('DestinationFile') | isempty(DestinationFile)
   DestinationFile = pwd;
   CheckForMoveOverSelf = true;
end

% test if source and destination arguments are strings
if ~all([ischar(SourceFile),ischar(DestinationFile)])
    error('MATLAB:MOVEFILE:DirectoryName',...
       'Directory name must be a string.')
end
% check if additional arguments are strings
if ~isempty(varargin) & ~iscellstr(varargin)
    error('MATLAB:MOVEFILE:ArgumentType',...
       'Additional arguments must be strings.')
end

% handle output arguments
% we can't have more than three output arguments
ArgOutError = nargoutchk(0,3,nargout);
if ~isempty(ArgOutError)
   error('MATLAB:MOVEFILE:NumberOfOutputArguments',ArgOutError);
end

% extract optional arguments
for i = 1:length(varargin)
   if strcmp(varargin{i},'f')
      mode = 'writable';
   else
      error('MATLAB:MOVEFILE:InvalidOption',...
         '''%s'' is an invalid option string.',varargin{i})
   end
end

%------------------------------------------------------------------------------
% Attempt file move action
try

    % Build file path that has valid path syntax.
    % For the PC and UNIX, add double quotes around the source and
    % destination files so as to support file names containing spaces
    Source = validpath(SourceFile,'quoted');
    Destination = validpath(DestinationFile,'quoted');

   % verify existence of source, before continuing
   if ~ismember('*',Source) & ~exist(strrep(Source,'"',''),'file')
      Success = false;
      error('MATLAB:MOVEFILE:CannotFindFile',...
         'Cannot find source file or directory to move.')
   end

   % check if destination is the source
   if CheckForMoveOverSelf
      [filepath,filename,ext] = fileparts(strrep(SourceFile,'"',''));
      if ~isempty(dir([fullfile(DestinationFile,filename),ext]))
         error('MATLAB:MOVEFILE:FileObjectExist',...
            'Directory or File cannot be moved onto itself.')
      end
      clear filepath filename    % deallocate these variables
   end

   % check writable attribute of Destination
   [DestinationAttributes,DestinationReadOnly] = ...
      check_writable(Source,Destination,mode);

   % check writable attribute of Source parent
   [SourceParentAttributes,SourceParentReadOnly] = ...
      check_parent_writable(Source,mode);

   % check writable attribute of Source parent
   [DestinationParentAttributes,DestinationParentReadOnly] = ...
      check_parent_writable(Destination,mode);

   % set parent writable
   set_parent_writable(DestinationParentAttributes,DestinationParentReadOnly);
   set_parent_writable(SourceParentAttributes,SourceParentReadOnly);

   % create destination if not existing and source is a directory
   if ismember('*',Source)...
         & ~exist(strrep(Destination,'"',''),'file')
     [Status, OSMessage] = mkdir(strrep(Destination,'"',''));
   end

   % UNIX file systems
   if isunix

      % set destination writable
      set_unix_writable(DestinationAttributes,DestinationReadOnly)

      % do file move
      [Status, OSMessage] = unix(['mv ' Source ' ' Destination]);

      restore_unix_writable(DestinationAttributes,DestinationReadOnly);

   % MS DOS file systems
   elseif ispc

      % Change to safe directory in Windows when UNC path cause failures
      CurrentDirectory = cdsafewindir;

      % set DOS MOVE switches according to version of Windows
      WinSwitches = setwinmove;

      % get destination file attributes and change to writable, if so required
      if any(DestinationReadOnly)
         set_win_writable(DestinationAttributes,DestinationReadOnly);
      end

      % preWin2000 does not allow moving file over existing file
      if WinSwitches.PreWin2000 & (exist(strrep(Destination,'"',''),'file') == 2) & ...
            ~ismember('*',Source)
         delete(strrep(Destination,'"',''))
      end

      % execute DOS move command
      [Status, OSMessage] = dos(['move ' WinSwitches.Move  Source ' '  Destination]);

      % restore directory attributes of destination
      restore_win_writable(DestinationAttributes,DestinationReadOnly);

      if ~isempty(CurrentDirectory) % restore current directory
         cd(CurrentDirectory);
      end
   end % if computer type

   restore_parent_writable(SourceParentAttributes,SourceParentReadOnly);
   restore_parent_writable(DestinationParentAttributes,DestinationParentReadOnly);

   %------------------------------------------------------------------------------
   % Consolidate OS status reply.
   % We consistently return Success = false if an error or warning was incurred
   Success = Status == 0;
   if ispc && Success 
     if strncmpi(OSMessage, 'access', length('access')),
       Success = false;
     end
   end

   % on failure, throw error.
   if ~Success
      error('MATLAB:MOVEFILE:OSError','%s',strvcat(OSMessage,ErrorMessage))
   end

catch
   Success = false;
   [ErrorMessage,ErrorID] = lasterr;
   if ~isempty(ErrorMessage)
     ErrorMessageReturn = strread(ErrorMessage,'%s','delimiter','\n');
	 if length(ErrorMessageReturn) > 1
		ErrorMessageReturn = strvcat(ErrorMessageReturn(2:end));
	 end
   end
   if ~isempty(ErrorID)
     ErrorID = strread(ErrorID,'%s','delimiter',':');
	   if ~isempty(ErrorID)
		   ErrorID = ['MATLAB:MOVEFILE:' ErrorID{end}];
	   end
   end
	if isempty(ErrorID)
		ErrorID = 'MATLAB:MOVEFILE:UnidentifiedError';
	end
   % throw error if no output arguments are specified
   if ~nargout
      rethrow(lasterror);
   end
end

%------------------------------------------------------------------------------
% parse output values to output parameters, if outout arguments are specified
if nargout
   varargout = { Success, ErrorMessageReturn, ErrorID };
end

%------------------------------------------------------------------------------
return
% end of MOVEFILE
%==============================================================================

% SETWINMOVE. Set MOVE switches for various Windows platforms
% Return:
%        WinMoveSwitches: struct scalar defining copy and xcopy switches
%           .PreWin2000: logical scalar defining pre or post Windows 2000 (0 or 1)
%           .Move: string defining MOVE switches
%------------------------------------------------------------------------------
function [WinMoveSwitches]=setwinmove
%------------------------------------------------------------------------------

persistent Switches;
if isempty(Switches)
    % find version of Windows
    % XXX what happens if Status is 0 (e.g., what happens if the dos command
    % XXX fails?)
    [Status,WinVersion] = dos('ver');

    % MOVE switches:
    %      /y: Suppresses prompting to confirm you want to overwrite an existing
    %          destination file.
    %
    if length(strfind(WinVersion,'Windows NT'))
       Switches.PreWin2000 = true;
       Switches.Move = '';
    else
       Switches.PreWin2000 = false;
       Switches.Move = '/y ';
    end
end

WinMoveSwitches = Switches;
%-------------------------------------------------------------------------------
return
%===============================================================================
