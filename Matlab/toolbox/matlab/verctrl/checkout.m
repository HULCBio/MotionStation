function checkout(fileNames, varargin)
%CHECKOUT Check a file or files out of the revision control system.
%   CHECKOUT(FILENAME) Checks FILENAME out of the revision control
%   system.  FILENAME must be the full path of the file. FILENAME
%   can be a cell array of files. By default, all files are 
%   locked upon checkout.
%
%   CHECKOUT(FILENAME, OPTION1, VALUE1, OPTION2, VALUE2, ...)
%
%   OPTIONS can be:
%      lock - Locks the file upon checkout. The default is on. Values for lock are:
%          on
%          off
%
%      revision - Checks out the specified revision of the file.
%
%   Examples:
%      checkout('\filepath\file.ext')
%      Checks out the current revision of \filepath\file.ext from the revision control system.
%      
%      checkout('\filepath\file.ext', 'revision', 'VALUE1')
%      Checks out the specified revision (VALUE1) of \filepath\file.ext from revision control system.
%
%      checkout({'\filepath\file1.ext','\filepath\file2.ext'})
%      Checks out the current revisions of \filepath\file1.ext and \filepath\file2.ext from the
%      revision control system.
%

%   See also CHECKIN, UNDOCHECKOUT, and CMOPTS.
%

%   Copyright 1998-2002 The MathWorks, Inc.
%   $Revision: 1.22 $ $Date: 2002/03/27 13:44:17 $

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

x = 0;
arguments    = cell(length(varargin) / 2 + 1, 2);
for i = 1 : 2 : length(varargin)
   parameter = lower(varargin{i});
   value     = deblank(varargin{i + 1});			  % Removing leading and 
   value     = fliplr(deblank(fliplr(value)));		  % trailing spaces
   if (strcmp(parameter, 'comments'))
      warning('Ignoring comments');
   end
   x         = x + 1;
   arguments{x, 1} = parameter;
   arguments{x, 2} = value;
end

x = x + 1;
arguments{x, 1} = 'action';
arguments{x, 2} = 'checkout';

% If the lock option is not supplied assume 'on'
if (isempty(arguments(find(strcmp(arguments, 'lock')))))
   x = x + 1;
   arguments{x, 1} = 'lock';
   arguments{x, 2} = 'on';
end

feval(system, fileNames, arguments);
