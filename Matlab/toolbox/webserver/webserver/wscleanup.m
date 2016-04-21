function deletecount = wscleanup(filespec, timewindow, direc)
%WSCLEANUP Purge stale files from directory.
%   DELETECOUNT = WSCLEANUP(FILESPEC, TIMEWINDOW, DIREC) deletes all
%   files matching FILESPEC in directory DIREC that are older than
%   the number of hours specified in TIMEWINDOW.  Returns the number
%   of files that were deleted.
%   DELETECOUNT = WSCLEANUP(FILESPEC, TIMEWINDOW) Deletes all
%   files matching FILESPEC in current default directory that are 
%   older than the number of hours specified in TIMEWINDOW. Returns
%   the number of files that were deleted.  All errors are thrown.
%
%   FILESPEC = file specification
%   TIMEWINDOW = hours old to keep files
%   DIREC = (optional) valid directory
%

%  Author(s): Charlie Bassignani, M. Greenstein 8 August 1997
%  Copyright 1998-2001 The MathWorks, Inc.
%  $Revision: 1.8 $     $Date: 2001/04/25 18:49:33 $

% Initialization
deletecount = 0;

% CHECK ARGUMENTS
% Check the number of arguments.
error(nargchk(2, 3, nargin));

% Use current working directory if no third argument.
if (nargin < 3), direc = pwd; end

% Check for valid directory.
if (~isdir(direc))
   error([direc ' is not a valid directory.']); 
end

% Check type of second parameter.
if (~isnumeric(timewindow))
   error('The timewindow argument must be a scalar.'); 
end 

% Time window can't be negative.  Make whole number.
if (timewindow < 0), timewindow = abs(timewindow); end
timewindow = round(timewindow); 

% Build directory structure and vectors prior to for loop.
% Get total number of files with matching file extension.
location = fullfile(direc, filespec);
direcstruct = dir(location);
if (isempty(direcstruct)) % Directory doesn't contain any of the specified files.
    return;
end
isfile = find(~[direcstruct.isdir]);
tfile = {direcstruct(isfile).date};
namefile = {direcstruct(isfile).name};

% Make delete time, converting timewindow to real hours.
deletetime = now - timewindow/24;

% Evaluate each file with respect to the time it was made.
for i = 1:length(tfile)
   filetime = datenum(tfile{i});
	if (deletetime > filetime)
      xfilename = namefile{i};
      delete(fullfile(direc, xfilename));
     	deletecount = deletecount + 1;
	end
end % for i

%end of function
