function startmulticoreslave(multicoreDir)
%STARTMULTICORESLAVE  Start multi-core processing slave process.
%   STARTMULTICORESLAVE(DIRNAME) starts a slave process for function
%   STARTMULTICOREMASTER. The given directory DIRNAME is checked for data
%   files including which function to run and which parameters to use.
%
%   STARTMULTICORESLAVE (without input arguments) uses the directory
%   <TEMPDIR>/multicorefiles, where <TEMPDIR> is the directory returned by
%   function tempdir.
%
%		Markus Buehren
%		Last modified 13.11.2007
%
%   See also STARTMULTICOREMASTER.

firstWarnTime = 10;
startWarnTime = 10*60;
maxWarnTime   = 24*3600;
startWaitTime = 0.5;
maxWaitTime   = 5;

lastEvalEndClock = clock;
lastWarnClock    = clock;
firstRun         = true;
curWarnTime      = firstWarnTime;
curWaitTime      = startWaitTime;

% get slave file directory name
if ~exist('multicoreDir', 'var') || isempty(multicoreDir)
	multicoreDir = fullfile(tempdir2, 'multicorefiles');
end
if ~exist(multicoreDir, 'dir')
	try
		mkdir(multicoreDir);
	catch
		error('Unable to create slave file directory %s.', multicoreDir);
	end
end

while 1
	parameterFileList = findfiles(multicoreDir, 'parameters_*.mat');

	% get last file that is not a semaphore file
	parameterFileName = '';
	for fileNr = length(parameterFileList):-1:1
		if isempty(strfind(parameterFileList{fileNr}, 'semaphore'))
			parameterFileName = parameterFileList{fileNr};
			break
		end
	end

	if ~isempty(parameterFileName)

		% load and delete last parameter file
		sem = setfilesemaphore(parameterFileName);
		loadSuccessful = true;
		if existfile(parameterFileName)
			try
				load(parameterFileName, 'functionHandle', 'parameters');
				delete(parameterFileName);
			catch
				disp(sprintf('Error loading or deleting file %s.', parameterFileName));
				loadSuccessful = false;
			end
		else
			loadSuccessful = false;
		end
		removefilesemaphore(sem);

		% check if variables are existing
		if loadSuccessful && (~exist('functionHandle', 'var') || ~exist('parameters', 'var'))
			disp(sprintf('Warning: Either variable ''%s'' or ''%s'' not existing after loading file %s.', ...
				'functionHandle', 'parameters', parameterFileName));
			loadSuccessful = false;
		end

		% continue if loading was not successful
		if ~loadSuccessful
			continue
		end

		%%%%%%%%%%%%%%%%%%%%%
		% evaluate function %
		%%%%%%%%%%%%%%%%%%%%%
		if firstRun
			disp(sprintf('First function evaluation (%s)', datestr(clock, 'mmm dd, HH:MM')));
			firstRun = false;
		elseif etime(clock, lastEvalEndClock) > 60
			disp(sprintf('First function evaluation after %s (%s)', ...
				formattime(etime(clock, lastEvalEndClock)), datestr(clock, 'mmm dd, HH:MM')));
		end

		% evaluate function
		if iscell(parameters) %#ok
			result = feval(functionHandle, parameters{:}); %#ok
		else
			result = feval(functionHandle, parameters); %#ok
		end

		% save result
		resultFileName = strrep(parameterFileName, 'parameters', 'result');
		sem = setfilesemaphore({parameterFileName, resultFileName});
		save(resultFileName, 'result');
		removefilesemaphore(sem);

		% save time
		lastEvalEndClock = clock;
		curWarnTime = startWarnTime;
		curWaitTime = startWaitTime;

		% remove variables before next run
		clear result functionHandle parameters

	else
		% display message if idle for long time
		timeSinceLastEvaluation = etime(clock, lastEvalEndClock);
		if min(timeSinceLastEvaluation, etime(clock, lastWarnClock)) > curWarnTime
			if timeSinceLastEvaluation >= 10*60
				% round to minutes
				timeSinceLastEvaluation = 60 * round(timeSinceLastEvaluation / 60);
			end
			disp(sprintf('Warning: No slave files found in last %s (%s).', formattime(timeSinceLastEvaluation), datestr(clock, 'mmm dd, HH:MM')));
			lastWarnClock = clock;
			if firstRun
				curWarnTime = startWarnTime;
			else
				curWarnTime = min(curWarnTime * 2, maxWarnTime);
			end
			curWaitTime = min(curWaitTime + 0.5, maxWaitTime);
		end

		% wait before next check
		pause(curWaitTime);

	end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function timeString = formattime(time, mode)
%FORMATTIME  Return formatted time string.
%   STR = FORMATTIME(TIME) returns a formatted time string for the given
%   time difference TIME in seconds, i.e. '1 hour and 5 minutes' for TIME =
%   3900.
%
%   FORMATTIME(TIME, MODE) uses the specified display mode ('long' or
%   'short'). Default is long display.
%
%   FORMATTIME (without input arguments) shows examples.

if nargin == 0
	disp(sprintf('\nExamples for strings returned by function %s.m:', mfilename));
	time = [0 1e-4 0.1 1 1.1 2 60 61 62 120 121 122 3600 3660 3720 7200 7260 7320 ...
		3600*24 3600*25 3600*26 3600*48 3600*49 3600*50];
	for k=1:length(time)
		disp(sprintf('time = %6g, timeString = ''%s''', time(k), formattime(time(k))));
	end
	if nargout > 0
		timeString = '';
	end
	return
end

if ~exist('mode', 'var')
	mode = 'long';
end

if time < 0
	disp('Warning: Time must be greater or equal zero.');
	timeString = '';
elseif time >= 3600*24
	days = floor(time / (3600*24));
	if days > 1
		dayString = 'days';
	else
		dayString = 'day';
	end
	hours = floor(mod(time, 3600*24) / 3600);
	if hours == 0
		timeString = sprintf('%d %s', days, dayString);
	else
		if hours > 1
			hourString = 'hours';
		else
			hourString = 'hour';
		end
		timeString = sprintf('%d %s and %d %s', days, dayString, hours, hourString);
	end

elseif time >= 3600
	hours = floor(mod(time, 3600*24) / 3600);
	if hours > 1
		hourString = 'hours';
	else
		hourString = 'hour';
	end
	minutes = floor(mod(time, 3600) / 60);
	if minutes == 0
		timeString = sprintf('%d %s', hours, hourString);
	else
		if minutes > 1
			minuteString = 'minutes';
		else
			minuteString = 'minute';
		end
		timeString = sprintf('%d %s and %d %s', hours, hourString, minutes, minuteString);
	end

elseif time >= 60
	minutes = floor(time / 60);
	if minutes > 1
		minuteString = 'minutes';
	else
		minuteString = 'minute';
	end
	seconds = floor(mod(time, 60));
	if seconds == 0
		timeString = sprintf('%d %s', minutes, minuteString);
	else
		if seconds > 1
			secondString = 'seconds';
		else
			secondString = 'second';
		end
		timeString = sprintf('%d %s and %d %s', minutes, minuteString, seconds, secondString);
	end

else
	if time > 10
		seconds = floor(time);
	else
		seconds = floor(time * 100) / 100;
	end
	if seconds > 0
		if seconds ~= 1
			timeString = sprintf('%.4g seconds', seconds);
		else
			timeString = '1 second';
		end
	else
		timeString = sprintf('%.4g seconds', time);
	end
end

switch mode
	case 'long'
		% do nothing
	case 'short'
		timeString = strrep(timeString, ' and ', ' ');
		timeString = strrep(timeString, ' days', 'd');
		timeString = strrep(timeString, ' day', 'd');
		timeString = strrep(timeString, ' hours', 'h');
		timeString = strrep(timeString, ' hour', 'h');
		timeString = strrep(timeString, ' minutes', 'm');
		timeString = strrep(timeString, ' minute', 'm');
		timeString = strrep(timeString, ' seconds', 's');
		timeString = strrep(timeString, ' second', 's');
	otherwise
		error('Mode ''%s'' unknown in function %s.', mode, mfilename);
end


