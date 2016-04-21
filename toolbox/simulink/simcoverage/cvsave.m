function cvsave(fileName, varargin)
%CVSAVE Save coverage tests and results to file
%
%   CVSAVE(FILENAME,MODEL) Save all the tests and results
%   related to MODEL in the text file FILENAME.CVT.  
%
%   CVSAVE(FILENAME, TEST1, TEST2, ...) Save the specified tests 
%   in the text file FILENAME.CVT.  Information about the
%   referenced model(s) will also be saved.
%
%   CVSAVE(FILENAME, DATA1, DATA2, ...) Save the specified data 
%   objects, the tests that created them and the referenced model(s) 
%   structure in the text file FILENAME.CVT.  
%
%   See also CVDATA, CVLOAD, CVTEST.

%   Bill Aldrich
%   Copyright 1990-2004 The MathWorks, Inc.
%   $Revision: 1.14.2.2 $  $Date: 2004/04/15 00:37:00 $


if check_cv_license==0
    error(['Failed to check out Simulink Verification and Validation license,', ...
           ' required for model coverage']);
end

if ~ischar(fileName)
    error('Destination file name must be a string');
end

if any(fileName== '.')
    warning('File name should not have an extension');
    pointChars = find(fileName== '.');
    baseFileName = fileName(1:(pointChar(1)-1));
else
    baseFileName = fileName;

end

if nargin == 2 & ischar(varargin{1})
    try
        bdHandle = get_param('varargin{1}','Handle');
        bdHandle = get_param(bdroot(bdHandle),'Handle');
        modelId = get_param(bdHandle,'CoverageId');
    catch
        modelId = cv('find','all','modelcov.name',varargin{1});
        if isempty(modelId)
            error('The specified model is not loaded in the coverage data dictionary');
        end
    end

    saveContext = capture_model_testdata_structure(modelId);
    packModelRunningTotal(modelId)
    cv('SaveModelData', modelId, [baseFileName '.cvt']);
    restore_model_testdata_structure(modelId, saveContext);
    return;

else
    TestOnly = 0;
    tests = [];
    for i=1:(nargin-1)
        switch(class(varargin{i})),
        case 'cvtest'
            TestOnly = 1;
            tests = [tests varargin{i}.id];
        case 'cvdata'
			% Commit derived data not in data dictionary
			if (varargin{i}.id == 0)
				varargin{i} = commitdd(varargin{i});
			end;
            tests = [tests varargin{i}.id];
        otherwise
            error('Bad input argument');
        end
    end
	
    %
    % Make sure all tests have the same modelcov
    %
    modelId = cv('get',tests(1),'.modelcov');
    for i=2:length(tests)
        if(modelId ~= cv('get',tests(i),'.modelcov'))
            error('All tests must be from the same model');
        end
    end
end



savedContext = capture_model_testdata_structure(modelId);

%
% Arrange the data dictionary to only reference the tests
% which should be saved
%
if (~TestOnly)
    [roots,lists] = sort_testdata_by_root(modelId,tests);
    for i= 1:length(roots)
        if ~any(cv('get', roots(i), '.runningTotal') == lists{i})
            cv('set', roots(i), '.runningTotal', 0);
        end;
        cv('SetTestList',roots(i),lists{i});
    end
    
    cv('SaveModelData',modelId,[baseFileName '.cvt']);
else
    cv('set',modelId,'.rootTree.child',0);
    cv('SetTestList',modelId,tests);
    cv('save',[baseFileName '.cvt'],'w',[modelId tests],'CV_Database');
end

restore_model_testdata_structure(modelId,savedContext);
%
% Perform a consistency check to insure the model is back
% to normal
%
cv('CheckConsistency',modelId);


function packModelRunningTotal(modelcovId)
    roots = cv('RootsIn', modelcovId);
    for i = 1:length(roots)
        runningTotalID = cv('get', roots(i), '.runningTotal');
        if runningTotalID > 0
            tests  = cv('TestsIn', roots(i));
            rmTest = 0;
            j      = 1;
            while j <= length(tests)
                if cv('get', tests(j), '.isDerived') & (runningTotalID ~= tests(j))
                    tests(j) = [];
                    rmTest   = 1;
                end; %if
                j = j + 1;
            end; %for j
            if rmTest
                cv('SetTestList', roots(i), tests);
            end; %if
        end; %if
    end %for i

function context = capture_model_testdata_structure(modelcovId),
    context.roots = cv('RootsIn',modelcovId);
    rootCount = length(context.roots);
    context.testLists = cell(rootCount,1);

    for i=1:rootCount
        context.testLists{i} = cv('TestsIn',context.roots(i));
    end
    context.pendingTests = cv('TestsIn',modelcovId,1);
    context.firstRoot = cv('get',modelcovId,'.rootTree.child');
    context.runningTotals = cv('get', context.roots, '.runningTotal');

function restore_model_testdata_structure(modelcovId,context),
    rootCount = length(context.roots);

    for i=1:rootCount
        cv('set',context.testLists{i},'.linkNode.parent',context.roots(i));
        cv('SetTestList',context.roots(i),context.testLists{i});
    end
    cv('SetTestList',modelcovId,context.pendingTests);
    cv('set',modelcovId,'.rootTree.child',context.firstRoot);
    cv('set', context.roots, '.runningTotal', context.runningTotals);
    

function [roots,lists] = sort_testdata_by_root(modelcovid,tests),
    roots = cv('RootsIn',modelcovid);
    lists = cell(length(roots),1);

    for testId = tests(:)'
        parent = cv('get',testId,'.linkNode.parent');
        listNum = find(roots==parent);
        lists{listNum} = [lists{listNum} testId];
    end


