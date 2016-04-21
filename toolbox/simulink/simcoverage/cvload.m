function [tests, data] = cvload(fileName, varargin)
%CVLOAD Load coverage tests and results from file
%
%   [TESTS, DATA] = CVLOAD(FILENAME) Load the tests and 
%   data stored in the text file FILENAME.CVT The tests that are 
%   successfully loaded are returned in TESTS, a cell array of 
%   cvtest objects. DATA is a cell array of cvdata objects that 
%   were successfully loaded.  DATA has the same size as TESTS 
%   but may contain empty elements if a particular test has no 
%   results. 
%
%   [TESTS, DATA] = CVLOAD(FILENAME, RESTORETOTAL) If RESTORETOTAL
%   is 1, the cumulative results from prior runs are restored.  If
%   RESTORETOTAL is unspecified or zero, the model's cumulative 
%   results are cleared.
%
%   Special Considerations:
%
%   1. If a model with the same name exists in the coverage
%      database, only the compatible results will be loaded
%      from file and they will reference the existing model
%      to prevent duplication.
%
%   2. If the Simulink model(s) referenced from file are open 
%      but do not exist in the coverage database the coverage 
%      tool will resolve the links to the existing models.  
%
%   3. When loading several files that reference the same model,
%      only the results that are consistent with the earlier files
%      will be loaded.
%
%   See also CVDATA, CVTEST, CVSAVE.

%   Bill Aldrich
%   Copyright 1990-2004 The MathWorks, Inc.
%   $Revision: 1.20.2.3 $  $Date: 2004/04/15 00:36:57 $

if check_cv_license==0
    error(['Failed to check out Simulink Verification and Validation license,', ...
           ' required for model coverage']);
end


%
% Check the input araguments and make sure the files exist.
%

if ~ischar(fileName)
    error('First argument should be a filename');
end

[fileRootName,isValid] = check_ext(fileName,'cvt');

if ~isValid
    error(sprintf('Bad file extension in %s',fileName));
end

txtHandle = fopen([fileRootName '.cvt'],'r');
if (txtHandle == -1),
    error(sprintf('Could not open file %s',fileName));
end
fclose(txtHandle);

%Determine if totals need to be cleared
restoreTotal = 0;
if length(varargin) > 0
	restoreTotal = varargin{1};
end; %if

%
% Load the objects.
%
newObjects = cv('load',[fileRootName '.cvt'],'CV_Database');

%
% Loop through each model and merge with existing results.
%
validTests = [];
newModels = cv('get',newObjects,'modelcov.id');
for newModel = newModels,
    modName = cv('get',newModel,'modelcov.name');
    cv('FormatLink',newModel);

    % Check if the model is loaded
    prevError = lasterr;
    try
        slModel = get_param(modName,'Handle');
    catch
        slModel = 0;
    end
    lasterr(prevError);
    if slModel
        set_param(slModel,'CoverageId',newModel);
        status = refresh_model_handles(newModel,modName);
        if status==0,
            disp(sprintf('The structure of model "%s" is not consistent with the results in file "%s"',modName,fileName));
            disp('It will not be possible to fully map results back to the diagrams');
        end
    end       

    matching_models = cv('find','all','modelcov.name',modName);
    origModel = matching_models(matching_models~=newModel);
    switch length(origModel),
    case 0
        validTests = [validTests cv('TestsIn',newModel)];
        cv('set',newModel,'modelcov.handle',slModel);
        cv('CheckConsistency',newModel);

        %If not restore then clear running total
        if ~restoreTotal
            clearRunningTotal(newModel);
        end; %if

    case 1
        newTests = cv('TestsIn',newModel);

        %If not restore then clear running total
        if ~restoreTotal
            clearRunningTotal(newModel);
        end; %if

        cv('MergeModels',origModel,newModel);
        allTests =  cv('TestsIn',origModel);
        testIntersection = find_intersection(newTests,allTests);
        validTests = [validTests testIntersection];
        cv('delete',newModel);

        % Restore the original modelcovId in Simulink if the model is open
        if slModel
            set_param(slModel,'CoverageId',origModel);
            cv('set',origModel,'modelcov.handle',slModel);  % In case model was reloaded
            status = refresh_model_handles(origModel,modName);
            if status==0,
                disp(sprintf('The structure of model "%s" is not consistent with the results in file "%s"',modName,fileName));
                disp('It will not be possible to fully map results back to the diagrams');
            end
            cv('CheckConsistency',origModel);
        end
    otherwise
        error('Consistency problem, two existing models have the same name');
    end  
end

%
% Prepare the output variables.
%
tests = cell(1,length(validTests));
data = cell(1,length(validTests));
hasResults = cv('HasResults',validTests);

for i=1:length(validTests)
    tests{i} = cvtest(validTests(i));
    % check if results exist
    if hasResults(i)
        data{i} = cvdata(validTests(i));
        %If derived data, null respective test
        if cv('get', validTests(i), '.isDerived')
            tests{i} = {};
        end;
    end
end

function clearRunningTotal(model)

%'set' does not support vector operations
roots = cv('RootsIn', model);
for i = 1:length(roots)
    cv('set', roots(i), '.runningTotal', 0);
end; %for


function [baseName, isValid] = check_ext(fileName,extension),

    isValid = 1;

    periodIndices = find(fileName == '.');

    if isempty(periodIndices)
        baseName = fileName;
        return;
    end

    if length(periodIndices) > 1
        isValid = 0;
        baseName = '';
        return;
    end

    if strcmp(extension, fileName((periodIndices+1):end))
        baseName = fileName(1:(periodIndices-1));
    else
        isValid = 0;
        baseName = '';
        return;
    end
    
function out = find_intersection(s1,s2),
	if isempty(s1) | isempty(s2), 
	    if isstr(s1),
	        out=''; 
	    else,
	        out = [];
	    end,
	    return, 
	end
    out = [];
	% Make sure s1 and s2 contain unique elements.
	s1 = sort(s1(:));
	s2 = sort(s2(:));
	% Find matching entries
	s = sort([s1;s2]);
	N = length(s);
	if N>1
		d = find(s(1:N-1)==s(2:N));
		out = s(d)';
	end

