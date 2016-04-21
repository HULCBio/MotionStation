function checkin(fileNames, varargin)
%CHECKIN Check a file or files into the version control system.
%   CHECKIN(FILENAME, 'COMMENTS', COMMENT_TEXT) 
%   Checks FILENAME into the source control system with the comments
%   in string COMMENT_TEXT.  FILENAME must be the full path
%   of the file. FILENAME can also be a cell array of files. Save 
%   the file before checking it in.
%   CHECKIN(FILENAME, 'COMMENTS', COMMENT_TEXT, OPTION1, VALUE1, ...
%      OPTION2, VALUE2)
%
%   OPTIONS can be:
%      lock - Locks the file upon checkin so the file remains checked out.
%       The default is off.  Values for lock are:
%          on
%          off
%
%   Examples:
%      checkin('\filepath\file.ext','comments','A sample comment')
%      Checks \filepath\file.ext into the version control tool.
%
%      checkin({'\filepath\file1.ext','\filepath\file2.ext'},'comments',...
%         'A sample comment')
%      Checks \filepath\file1.ext and \filepath\file2.ext into the
%      version control system, using the same comments for both files.
%
%   See also CHECKOUT, UNDOCHECKOUT, and CMOPTS.
%

%   Copyright 1998-2002 The MathWorks, Inc.
%   $Revision: 1.20 $ $Date: 2002/03/27 13:44:15 $

[sc, system] = issourcecontrolconfigured;             % Check for Source control system
if (sc == 0)
	 error('No source control system specified. Set in preferences.');
end

if (isempty(fileNames))                               % If no file name is supplied error out.
   error('No file name supplied');
end

if (ischar(fileNames))                                % Convert the fileNames to a cell array.
   fileNames = cellstr(fileNames);
end

% Create a 2x2 cell array of arguments
x = 0;
arguments    = cell(length(varargin) / 2 + 1, 2);
for i = 1 : 2 : length(varargin)
   parameter = lower(varargin{i});
   value     = deblank(varargin{i + 1});			  % Removing leading and 
   value     = fliplr(deblank(fliplr(value)));		  % trailing spaces
   if (strcmp(parameter, 'comments'))
      % RCS does not take in empty comments. 
      if (isempty(value))
         value = '_'; 
      end
   end
   x = x + 1;
   arguments{x, 1} = parameter;
   arguments{x, 2} = value;
end

if (isempty(arguments(find(strcmp(arguments, 'comments')))))
   error('No Comments supplied. Please supply a comment.');
end

x           = x + 1;
arguments{x, 1} = 'action';
arguments{x, 2} = 'checkin';

% If the lock option is not supplied assume 'off'
if (isempty(arguments(find(strcmp(arguments, 'lock')))))
   x = x + 1;
   arguments{x, 1} = 'lock';
   arguments{x, 2} = 'off';
end

feval(system, fileNames, arguments);