function semaphore = setfilesemaphore(fileList)
%SETFILESEMAPHORE  Set semaphore for file access.
%   SEMAPHORE = SETFILESEMAPHORE(FILENAME) sets a semaphore to get
%   exclusive access on file FILE. The semaphore is realized by generating
%   a simple Matlab data file after checking that no other semaphores are
%   existing. The function exits if the semaphore is set. Exclusive file
%   access is of course only guaranteed if all other Matlab processes use
%   semaphores to access the same file.
%
%   The output variable SEMAPHORE is needed to correctly remove the file
%   semaphore after file access. It is an error to call function
%   SETFILESEMAPHORE without output arguments.
%
%   SEMAPHORE = SETFILESEMAPHORE(FILELIST) sets semaphores for all files
%   given in cell array FILELIST. Note that function SETFILESEMAPHORE waits
%   for exclusive file access on ALL files in the list before exiting.
%
%		Note: A semaphore older than 20 seconds is considered as invalid and
%		will immediately be deleted.
%   
%		Markus Buehren
%		Last modified 13.11.2007
%
%   See also REMOVEFILESEMAPHORE.

% set times (all in seconds)
semaphoreOldTime = 20;
fixedWaitTime    = 0.01;
checkWaitTime    = 0.1;
maxRandomTime    = 0.3;

if nargout ~= 1
	error('Function %s must be called with one output argument!', mfilename);
end

if ischar(fileList)
	% single file given
	fileList = {fileList};
end

nOfFiles = length(fileList);
semaphore = cell(nOfFiles, 1);
for fileNr = 1:nOfFiles
	
	fileName = fileList{fileNr};

	% check if given file is itself a semaphore file
	if ~isempty(regexp(fileName, '\.semaphore\.\w+\.\d{32}\.mat$', 'once'))
		semaphore{fileNr, 1} = '';
		continue
	end

	% generate semaphore file name and pattern
	[ignore, randomStr] = generaterandomnumber; %#ok
	semaphoreFileName = [fileName, '.semaphore.', randomStr, '.mat'];
	semaphorePattern  = [fileName, '.semaphore.', '*',       '.mat'];
	semaphorePatternPath = fileparts(semaphorePattern);

	while 1
		dirStruct = dir(semaphorePattern);
		
		if ~isempty(dirStruct)
			% other semaphore file(s) existing
			% check if any semaphore is very old
			allSemaphoresOld = true;
			for k=1:length(dirStruct)
				if now - datenum2(dirStruct(k).date) > semaphoreOldTime / (3600*24)
					% remove semaphore
					disp(sprintf('Warning: Removing old semaphore file %s.', dirStruct(k).name));
					oldSemaphoreFileName = fullfile(semaphorePatternPath, dirStruct(k).name);
					if exist(oldSemaphoreFileName, 'file')
						delete(oldSemaphoreFileName);
					end
				else
					allSemaphoresOld = false;
				end
			end
			
			if allSemaphoresOld
				continue
			end

			% wait before checking again
			pause(checkWaitTime);
			
		else
			% set own semaphore file
			try
 				save(semaphoreFileName, 'randomStr');
			catch
				disp(sprintf('An error occured while accessing semaphore file %s:', semaphoreFileName));
				displayerrorstruct;
				
				% in very very very unlikely cases two processes might have
				% generated the same semaphore file name
				[randomNr, randomStr] = generaterandomnumber; %#ok
				pause(0.2+maxRandomTime * randomNr);
				semaphoreFileName = [fileName, '.semaphore.', randomStr, '.mat'];
				save(semaphoreFileName, 'randomStr');
			end
			
			% wait fixed time
			pause(fixedWaitTime);

			% in very unlikely cases, two semaphore files might have been created
			% at the same time
			dirStruct = dir(semaphorePattern);
			if length(dirStruct) > 1
				% remove own semaphore file
				delete(semaphoreFileName);

				% wait RANDOM time before checking again
				pause(maxRandomTime * generaterandomnumber);

			else
				% exclusive file access is guaranteed
				% save semaphore file name and leave while loop
				semaphore{fileNr, 1} = semaphoreFileName;
				break
			end
		end % if ~isempty(dirStruct)
	end % while 1
end % for fileNr = 1:nOfFiles

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [randomNr, randomStr] = generaterandomnumber
%GENERATERANDOMNUMBER
%   in very unlikely cases, it might happen that the random states of rand
%   and randn are equal in two Matlab processes calling function
%   SETSEMAPHORE. For this reason, the system and cpu time are used to create
%   different random numbers even in this unlikely case.

nOfDigits = 8; % length of random string will be 4*nOfDigits

randNr    = rand;
randnNr   = mod(randn+0.5, 1);
cputimeNr = mod(cputime, 100)/100;
nowNr     = mod(rem(now,1)*3600*24, 100)/100;

% random number is used for random pause after conflict
randomNr = 0.25 * (randNr + randnNr + cputimeNr + nowNr);

% random string is used for the semaphore file name
if nargout > 1
	ee = 10^nOfDigits;
	randomStr = [...
		num2str(ee * randNr,    '%.0f'), ...
		num2str(ee * randnNr,   '%.0f'), ...
		num2str(ee * cputimeNr, '%.0f'), ...
		num2str(ee * nowNr,     '%.0f'), ...
		];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function dateNr = datenum2(dateStr)
%DATENUM2  Return serial date number.
%   DATENUM2(STR) returns the serial date number for the given date string
%   STR. Function DATENUM2 is a wrapper for DATENUM which replaces german
%   month abbreviations like "Okt" by the english versions like "Oct"
%   before forwarding the string to function DATENUM.
%
%   Function DATENUM2 first tries to build a date vector from the given
%   string for performance reasons. However, only date format 0
%   (dd-mmm-yyyy HH:MM:SS) is supported for this. If the given date string
%   is in a different format, the string is forwarded to function DATENUM.

tokenCell = regexp(dateStr, '(\d+)-(\w+)-(\d+) (\d+):(\d+):(\d+)', 'tokens');
tokenCell = tokenCell{1};
if length(tokenCell) == 6
	% supported date format (at least it seems so)

	% get month
	switch tokenCell{2}
		case 'Jan'
			month = 1;
		case 'Feb'
			month = 2;
		case {'Mar', 'Mär', 'Mrz'}
			month = 3;
		case 'Apr'
			month = 4;
		case {'May', 'Mai'}
			month = 5;
		case 'Jun'
			month = 6;
		case 'Jul'
			month = 7;
		case 'Aug'
			month = 8;
		case 'Sep'
			month = 9;
		case {'Oct', 'Okt'}
			month = 10;
		case 'Nov'
			month = 11;
		case {'Dec', 'Dez'}
			month = 12;
		otherwise
			% obviously the data format is not supported
			disp('Date format not supported (1)');
			dateNr = datenum(translatedatestr(dateStr));
			return
	end

	dateVec = [...
		str2double(tokenCell{3}), ... % year
		month, ...                    % month
		str2double(tokenCell{1}), ... % day
		str2double(tokenCell{4}), ... % hours
		str2double(tokenCell{5}), ... % minutes
		str2double(tokenCell{6}), ... % seconds
		];
	dateNr = datenum(dateVec);

else
	% unknown date format
	dateNr = datenum(translatedatestr(dateStr));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function dateStr = translatedatestr(dateStr)
%TRANSLATEDATESTR  Translate german date string to english version.
%		STR = TRANSLATEDATESTR(STR) converts a german date string like 
%		  13-Mär-2006 15:55:00
%		to the english version
%		  13-Mar-2006 15:55:00.
%		This is needed on some systems if function DIR returns german date
%		strings.
%
%		Markus Buehren
%
%		See also DATENUM2.

dateStr = strrep(dateStr, 'Mrz', 'Mar');
dateStr = strrep(dateStr, 'Mär', 'Mar');
dateStr = strrep(dateStr, 'Mai', 'May');
dateStr = strrep(dateStr, 'Okt', 'Oct');
dateStr = strrep(dateStr, 'Dez', 'Dec');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function displayerrorstruct(errorStruct)
%DISPLAYERRORSTRUCT  Display structure returned by function lasterror.
%		DISPLAYERRORSTRUCT displays the structure returned by function
%		LASTERROR. Useful when catching errors.
%
%		Markus Buehren
%
%   See also LASTERROR.

if nargin == 0
	errorStruct = lasterror;
end

disp(errorStruct.message);
errorStack = errorStruct.stack;
for k=1:length(errorStack)
	disp(sprintf('Error in ==> %s at %d.', errorStack(k).name, errorStack(k).line));
end