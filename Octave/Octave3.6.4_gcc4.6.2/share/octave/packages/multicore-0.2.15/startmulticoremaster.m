function resultCell = startmulticoremaster(functionHandleCell, parameterCell, ...
	multicoreDir, maxMasterEvaluations)
%STARTMULTICOREMASTER  Start multi-core processing master process.
%   RESULTCELL = STARTMULTICOREMASTER(FHANDLE, PARAMETERCELL, DIRNAME)
%   starts a multi-core processing master process. The function specified
%   by the given function handle is evaluated with the parameters saved in
%   each cell of PARAMETERCELL. Each cell may include parameters in any
%   form or another cell array which is expanded to an argument list using
%   the {:} notation to pass multiple input arguments. The outputs of the
%   function are returned in cell array RESULTCELL of the same size as
%   PARAMETERCELL. Only the first output argument of the function is
%   returned. If you need to get multiple outputs, write a small adapter
%   function which puts the outputs of your function into a cell array.
%
%   To make use of multiple cores/machines, function STARTMULTICOREMASTER
%   saves files with the function handle and the parameters to the given
%   directory DIRNAME. These files are loaded by function
%   STARTMULTICORESLAVE running on other Matlab processes which have access
%   to the same directory. The slave processes evaluate the given function
%   with the saved parameters and save the result in another file into the
%   same directory. The results are later collected by the master process.
%
%		RESULTCELL = STARTMULTICOREMASTER(FHANDLE, PARAMETERCELL, DIRNAME,
%		MAXMASTEREVALUATIONS) restricts the number of function evaluations done
%		by the master process to MAXMASTEREVALUATIONS. After the given number
%		of evaluations is reached, the master process waits for other processes
%		to complete instead of working down the list of parameter sets itself.
%		Use this value if the overall number of function evaluations is quite
%		small or the duration of a single evaluation is very long. However,
%		note that if the slave process is interrupted, the master process will
%		never terminate the computations!
%
%   Note that you can make use of multiple cores on a single machine or on
%   different machines with a commonly accessible directory/network share
%   or a combination of both.
%
%   RESULTCELL = STARTMULTICOREMASTER(FHANDLE, PARAMETERCELL) uses the
%   directory <TEMPDIR2>/multicorefiles, where <TEMPDIR2> is the directory
%   returned by function TEMPDIR2. Use this form if you are running on
%   multiple cores on a single machine.
%
%   RESULTCELL = STARTMULTICOREMASTER(FHANDLECELL, PARAMETERCELL, ...),
%   with a cell array FHANDLECELL including function handles, allows to
%   evaluate different functions.
%
%   Example: If you have your parameters saved in parameter cell
%   PARAMETERCELL, the for-loop
%
%   	for k=1:numel(PARAMETERCELL)
%   		RESULTCELL{k} = FHANDLE(PARAMETERCELL{k});
%   	end
%
%   which you would run in a single process can be run in parallel on
%   different cores/machines using STARTMULTICOREMASTER and
%   STARTMULTICORESLAVE. Run
%
%   	RESULTCELL = STARTMULTICOREMASTER(FHANDLE, PARAMETERCELL, DIRNAME)
%
%   in one Matlab process and
%
%   	STARTMULTICORESLAVE(DIRNAME)
%
%   in other Matlab processes.
%
%		Markus Buehren
%		Last modified 13.11.2007
%
%   See also STARTMULTICORESLAVE, FUNCTION_HANDLE.

startWaitTime = 0.1;
maxWaitTime   = 2;

% check input arguments
if isa(functionHandleCell, 'function_handle')
	functionHandleCell = repmat({functionHandleCell}, size(parameterCell));
else
	if ~iscell(functionHandleCell)
		error('First input argument must be a function handle or a cell array of function handles.');
	elseif any(size(functionHandleCell) ~= size(parameterCell))
		error('Input cell arrays functionHandleCell and parameterCell must be of the same size.');
	end
end
nOfFiles = numel(functionHandleCell);
if ~iscell(parameterCell)
	error('Second input argument must be a cell array.');
end
if ~exist('multicoreDir', 'var')
	multicoreDir = '';
elseif ~ischar(multicoreDir)
	error('Third input argument must be a string.');
end
if exist('maxMasterEvaluations', 'var')
	if isempty(maxMasterEvaluations) || maxMasterEvaluations > nOfFiles
		maxMasterEvaluations = nOfFiles;
	elseif maxMasterEvaluations < 0
		error('Maximum number of master evaluations must not be negative.');
	end
else
	maxMasterEvaluations = nOfFiles;
end

% create slave file directory if not existing
if isempty(multicoreDir)
	multicoreDir = fullfile(tempdir2, 'multicorefiles');
end
if ~exist(multicoreDir, 'dir')
	try
		mkdir(multicoreDir);
	catch
		error('Unable to create slave file directory %s.', multicoreDir);
	end
end

% remove all existing parameter files
existingSlaveFiles = [findfiles(multicoreDir, 'parameters_*.mat'), findfiles(multicoreDir, 'result_*.mat')];
for k=1:length(existingSlaveFiles)
	deletewithsemaphores(existingSlaveFiles{k});
end

% build parameter file name (including the date is important because slave
% processes might still be working with old parameters)
dateStr = sprintf('%04d%02d%02d%02d%02d%02d', round(clock));
parameterFileNameTemplate = fullfile(multicoreDir, sprintf('parameters_%s_XX.mat', dateStr));

% generate parameter files
if maxMasterEvaluations == nOfFiles
	% save parameter files with all parameter sets except the first one
	% save files with highest numbers first
	fileIndex = nOfFiles:-1:2;
else
	% only save parameter files for slave processes
	fileIndex = nOfFiles:-1:maxMasterEvaluations+1;
end
for fileNr = fileIndex
	parameterFileName = strrep(parameterFileNameTemplate, 'XX', sprintf('%04d', fileNr));
	functionHandle = functionHandleCell{fileNr}; %#ok
	parameters     = parameterCell     {fileNr}; %#ok
	sem = setfilesemaphore(parameterFileName);
	save(parameterFileName, 'functionHandle', 'parameters');
	removefilesemaphore(sem);
end

% evaluate function
resultCell = cell(size(functionHandleCell));
for fileNr = 1:maxMasterEvaluations
	parameterFileName = strrep(parameterFileNameTemplate, 'XX', sprintf('%04d', fileNr));
	resultFileName    = strrep(parameterFileName, 'parameters', 'result');

	% remove parameter file if existing, so that a slave process does not load it
	sem = setfilesemaphore(parameterFileName);
	if existfile(parameterFileName)
		delete(parameterFileName);
	end
	removefilesemaphore(sem);

	% check if the current parameter set was evaluated before by a slave process
	resultLoaded = false;
	sem = setfilesemaphore(resultFileName);
	if existfile(resultFileName)
		load(resultFileName, 'result');
		delete(resultFileName);
		resultCell{fileNr} = result;
		resultLoaded = true;
	end
	removefilesemaphore(sem);

	% evaluate function if the result could not be loaded
	if ~resultLoaded
		functionHandle = functionHandleCell{fileNr}; %#ok
		parameters     = parameterCell     {fileNr}; %#ok
		if iscell(parameters)
			resultCell{fileNr} = feval(functionHandle, parameters{:});
		else
			resultCell{fileNr} = feval(functionHandle, parameters);
		end
	end
end

% if number of master evaluations is restricted, wait for results of slaves
if maxMasterEvaluations < nOfFiles
	for fileNr = nOfFiles:-1:maxMasterEvaluations+1
		parameterFileName = strrep(parameterFileNameTemplate, 'XX', sprintf('%04d', fileNr));
		resultFileName    = strrep(parameterFileName, 'parameters', 'result');

		resultLoaded = false;
		curWaitTime = startWaitTime;
		while 1
			sem = setfilesemaphore(resultFileName);
			if existfile(resultFileName)
				load(resultFileName, 'result');
				delete(resultFileName);
				resultCell{fileNr} = result;
				resultLoaded = true;
			end
			removefilesemaphore(sem);
			if resultLoaded
				break
			end

			% wait a moment before checking again
			pause(curWaitTime);
			curWaitTime = min(maxWaitTime, curWaitTime + startWaitTime);
		end
	end
end

