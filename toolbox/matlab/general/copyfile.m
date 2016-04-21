function varargout=copyfile(SourceFile,DestinationFile,varargin)
%COPYFILE   Copy file or directory.
%   [SUCCESS,MESSAGE,MESSAGEID] = COPYFILE(SOURCE,DESTINATION,MODE) copies the
%   file or directory SOURCE to the new file or directory DESTINATION. Both
%   SOURCE and DESTINATION may be either an absolute pathname or a pathname
%   relative to the current directory. When the MODE is set, COPYFILE copies
%   SOURCE to DESTINATION, even when DESTINATION is read-only. The DESTINATION's
%   writable attribute state is preserved. See NOTE 1.
%
%   [SUCCESS,MESSAGE,MESSAGEID] = COPYFILE(SOURCE) attempts to copy SOURCE to
%   the current directory.
%
%   [SUCCESS,MESSAGE,MESSAGEID] = COPYFILE(SOURCE, DESTINATION) attempts to copy
%   SOURCE to DESTINATION. If SOURCE constitutes a directory or multiple files
%   and DESTINATION does not exist, COPYFILE attempts to create DESTINATION as a
%   directory and copy SOURCE to DESTINATION. If SOURCE constitutes a directory
%   or multiple files and DESTINATION exists as a directory, COPYFILE attempts
%   to copy SOURCE to DESTINATION. If SOURCE constitutes a directory or multiple
%   files and none of the above cases on DESTINATION applies, COPYFILE fails.
%
%   [SUCCESS,MESSAGE,MESSAGEID] = COPYFILE(SOURCE,DESTINATION,'f') attempts to
%   copy SOURCE to DESTINATION, as above, even if DESTINATION is read-only. The
%   status of the writable attribute of DESTINATION will be preserved.
%
%   INPUT PARAMETERS:
%       SOURCE:      1 x n string, defining the source file or directory.
%                    See NOTE 2 and 3.
%       DESTINATION: 1 x n string, defining destination file or directory.
%                    The default is the current directory. See NOTE 3.
%       MODE:        character scalar defining copy mode.
%                    'f' : force SOURCE to be written to DESTINATION. If omitted,
%                    COPYFILE respects the current writable status of DESTINATION.
%                    See NOTE 4.
%
%   RETURN PARAMETERS:
%       SUCCESS:     logical scalar, defining the outcome of COPYFILE.
%                    1 : COPYFILE executed successfully.
%                    0 : an error occurred.
%       MESSAGE:     string, defining the error or warning message.
%                    empty string : COPYFILE executed successfully.
%                    message : an error or warning message, as applicable.
%       MESSAGEID:   string, defining the error or warning identifier.
%                    empty string : COPYFILE executed successfully.
%                    message id: the MATLAB error or warning message identifier
%                    (see ERROR, LASTERR, WARNING, LASTWARN).
%
%   NOTE 1: Currently, SOURCE attributes are not preserved under copying on a
%           Windows platform. Except where otherwise stated, the rules of the
%           underlying system on the preservation of attributes are followed
%           when copying files and directories.
%   NOTE 2: The * wildcard, as a suffix to the last name or the extension to the
%           last name in a path string, is supported. Current behaviour of
%           COPYFILE differs between UNIX and Windows when using the wildcard *
%           or copying directories. See DOC COPYFILE for details.
%   NOTE 3: UNC paths are supported.
%   NOTE 4: 'writable' is being deprecated, but is still supported for backwards
%           compatibility.
%
%   See also CD, DELETE, DIR, FILEATTRIB, MKDIR, MOVEFILE, RMDIR.

%   JP Barnard
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.28.4.5 $ $Date: 2004/03/12 18:07:28 $
%-------------------------------------------------------------------------------
% Set up COPYFILE

% initialise variables
CurrentDirectory = '';
ErrorMessage='';                                % annotations to raw OS error message
ErrorID = '';                                   % COPYFILE error ID
Status = 0;                                             % OS call status
Success = true;                         % COPYFILE success status
OSMessage = '';                         % raw OS message
mode = '';                                              % default "force write attribute" is off
DestinationReadOnly = false;
CheckForCopyOverSelf = false;

% handle input arguments
% we can't have less than one input argument
ArgError = nargchk(1,3,nargin);
if ~isempty(ArgError)
   error('MATLAB:COPYFILE:NumberOfInputArguments',ArgError);
end

% default destination is the current directory
if (nargin < 2) || isempty(DestinationFile)
   DestinationFile = pwd;
   CheckForCopyOverSelf = true;
end

% test if source and destination arguments are strings
if ~all([ischar(SourceFile),ischar(DestinationFile)])
    error('MATLAB:COPYFILE:DirectoryName',...
       'Directory or file name must be a string.')
end

% check if additional arguments are strings
if ~isempty(varargin) & ~iscellstr(varargin)
    error('MATLAB:COPYFILE:ArgumentType',...
       'Additional arguments must be strings.')
end

% handle output arguments
% we can't have more than three output arguments
ArgOutError = nargoutchk(0,3,nargout);
if ~isempty(ArgOutError)
   error('MATLAB:COPYFILE:NumberOfOutputArguments',ArgOutError);
end

% extract optional arguments
for i = 1:length(varargin)
   if strcmp(lower(varargin{i}),'f')|...
         strcmp(lower(varargin{i}),'writable')
      mode = 'writable';
   else
      error('MATLAB:COPYFILE:InvalidOption',...
         '"%s" is an invalid option string.',varargin{i})
   end
end

%-------------------------------------------------------------------------------
% Attempt copy action
try
   % test if source is specified
   if (nargin < 1) || isempty(SourceFile)
      error('MATLAB:COPYFILE:SourceArgumentIsEmpty',...
         'Source argument is empty.')
   end

   % Build file path that has valid path syntax.
   % Add double quotes around the source and destination files so as to support
   %  file names containing spaces.
   Source = validpath(SourceFile,'quoted');
   Destination = validpath(DestinationFile,'quoted');

   % verify existence of source, before continuing
   source2 = strrep(Source,'"','');
   member =  ~isempty(regexp(Source, '\*','once'));   %ismember('*',Source);
   if ~member &&  ~exist(source2,'file')
      error('MATLAB:COPYFILE:CannotFindFile',...
         'Cannot find the source file or directory specified.')
   end
   % check if destination is a directory when source implies multiple file
   % objects or a directory.
   dest2 = strrep(Destination,'"','');
   if (member || isdir(source2)) && ...
         (exist(dest2,'file')==2)
      error('MATLAB:COPYFILE:NotValidDestination','%s',...
      ['Attempting to copy a directory or multiple file objects but ',...
      'Destination is not a valid directory.'])
   end

   % check if destination is the source
   if CheckForCopyOverSelf
      [filepath,filename,ext] = fileparts(strrep(SourceFile,'"',''));
      if ~isempty(dir([fullfile(DestinationFile,filename),ext]))
         error('MATLAB:COPYFILE:FileObjectExist','%s',...
            'Directory or File cannot be copied onto itself.')
      end
      clear filepath filename    % deallocate these variables
   end

   % check and set writable attribute of parent
   [ParentAttributes, ParentReadOnly] = check_parent_writable(Destination,mode);
   set_parent_writable(ParentAttributes,ParentReadOnly);

   % check writable attribute of Destination
   [DestinationAttributes,DestinationReadOnly] = ...
      check_writable(Source,Destination,mode);

   if isunix

      % test and set destination writable, if requested
      if strcmp(mode,'writable')
         set_unix_writable(DestinationAttributes,DestinationReadOnly);
      end

      % create destination if it should be a directory and it does not exist
      if (member || isdir(source2))...
            && ~exist(dest2,'file')
         [Status, OSMessage] = unix(['mkdir ' Destination]);
      end
      Source = regexprep(Source,'\"\*\"\.\"\*\"\"$','"*""','once');
      % copy file or directory, preserving atributes, rights and ACL
      if isdir(strrep(Source,'"',''))
         % for directory, copy contents to Destination
         [Status, OSMessage] = unix(['cp -r ' Source '/* ' Destination]);
      else
         [Status, OSMessage] = unix(['cp -r ' Source ' ' Destination]);
      end

      % restore Read-only file/directory attribute
      if any(DestinationReadOnly)
         restore_unix_writable(DestinationAttributes,DestinationReadOnly);
      end

   else  %PC

      % Change to safe directory in Windows when UNC path cause failures
      CurrentDirectory = cdsafewindir; % store current directory

      % set DOS xcopy and copy switches according to version of Windows
      WinSwitches = setwincopy;

      % get destination file attributes and change to writable, if so required
      if any(DestinationReadOnly)
         set_win_writable(DestinationAttributes,DestinationReadOnly);
      end

      % If source is a directory or multiple files are copied, use XCOPY
      if isdir(source2) || ...
            (member  && ~exist(dest2,'file'))
         % copy a directory or several directory objects, preserving atributes,
         % rights and ACL
         if strcmp(mode,'writable') % use XCOPY with overwrite switch on
            [Status, OSMessage] = ...
               dos(['xcopy ', Source, ' ', Destination, WinSwitches.XCopyOverwrite]);

         else % use XCOPY without overwrite switch
            [Status, OSMessage] = ...
               dos(['xcopy ' Source ' '  Destination, WinSwitches.XCopy]);
         end

      else
         % use simple COPY for files. XCOPY responds with an undesirable prompt
         %      to the user to state the type of the destination.
         [Status, OSMessage] = ...
            dos(['copy ' WinSwitches.Copy ' ' Source ' '  Destination]);
      end

      % restore directory attributes of destination
      if any(DestinationReadOnly)
         restore_win_writable(DestinationAttributes,DestinationReadOnly);
      end

      % conditionally restore to original current directory
      if ~isempty(CurrentDirectory)
         cd(CurrentDirectory);
      end
   end % if computer type

   if ParentReadOnly
      restore_parent_writable(ParentAttributes,ParentReadOnly);
   end

   % throw applicable OS errors if an error occured (e.g., Status ~= 0)
   Success = Status == 0;
   if ispc && Success 
     if ~isempty(strfind(OSMessage,' 0 file'))
       Success = false;
     end
   end
   
   % throw error on failure
   if ~Success
      error('MATLAB:COPYFILE:OSError','%s',strvcat(OSMessage,ErrorMessage)')
   end

catch
   Success = false;
   [ErrorMessage,ErrorID] = lasterr;
   if ~isempty(ErrorMessage)
	   if (strfind(ErrorMessage, 'Error using') == 1)
			[unusedLHS, ErrorMessage] = strtok(ErrorMessage,sprintf('\n'));
			if ~isempty(ErrorMessage)
			     ErrorMessage(1) = '';
			end
	   end
   end
   if ~isempty(ErrorID)
     ErrorID = strread(ErrorID,'%s','delimiter',':');
     if ~isempty(ErrorID)
		 ErrorID = ['MATLAB:COPYFILE:' ErrorID{end}];
	 else
       ErrorID = 'MATLAB:COPYFILE:UnidentifiedError';
	 end
   else
       ErrorID = 'MATLAB:COPYFILE:UnidentifiedError';
   end

   % throw error if no output arguments are specified
   if ~nargout
     error(ErrorID,'%s',[ErrorMessage repmat(sprintf('\n'),size(ErrorMessage,1),1)]);
   end
end

%------------------------------------------------------------------------------
% parse output values to output parameters, if outout arguments are specified
if nargout
   varargout = { Success, ErrorMessage, ErrorID };
end

%------------------------------------------------------------------------------
return
%==============================================================================

% SETWINCOPY. Set copy and xcopy switches for various Windows platforms
% Return:
%        WinCopySwitches: struct scalar defining copy and xcopy switches
%           .XCopyOverwrite: string defining XCOPY switches for overwrite
%           .XCopy: string defining XCOPY switches for not overwrite
%           .Copy: string defining COPY switches
%------------------------------------------------------------------------------
function [WinCopySwitches]=setwincopy
%------------------------------------------------------------------------------

% find version of Windows
% XXX what happens if Status is 0 (e.g., what happens if the dos command
% XXX fails?)
persistent Switches;
if isempty(Switches)
    [Status,WinVersion] = dos('ver');

    %       XCOPY switches:
    %       /e: copy all subdirectories - empty or full.
    %       /q: suppress any dialogue.
    %       /i: assume destination is a non-existing directory when copying
    %           multiple files
    %       /r: Overwrites read-only files.
    %       /y: Suppresses prompting to confirm you want to overwrite an existing
    %           destination file.

    if ~isempty(strfind(WinVersion,'Windows NT'))
      promptSuppress = '';
    else
      promptSuppress = ' /y';
    end  

    Switches.XCopyOverwrite = [' /e /q /i /r' promptSuppress];
    Switches.XCopy          = [' /e /q /i' promptSuppress ];
    Switches.Copy           = ['' promptSuppress ];
end
WinCopySwitches = Switches;
%-------------------------------------------------------------------------------
return
%===============================================================================
