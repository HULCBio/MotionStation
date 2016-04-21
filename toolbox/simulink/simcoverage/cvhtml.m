function varargout = cvhtml(fileName,varargin)
%CVHTML - Generate HTML coverage report.
%
%   CVHTML(FILE,DATA) Create an HTML report of the coverage
%   results in the cvdata object DATA.  The report will be 
%   written to FILE.
%
%   CVHTML(FILE,DATA1,DATA2,...) Create a combined report
%   of several data objects.  The results from each object
%   will be displayed in a separate column.  Each data object
%   must correspond to the same root subsystem or the function 
%   will produce errors.
%
%   CVHTML(FILE,DATA1,DATA2,...,OPTIONS) Specify the report
%   generation options using an encoded string.  The options
%   string has a space separated list of the form -XXX=1 or 
%   -XXX=0.  A description of options can be produced with the
%   command: cvhtml help options
%
%   CVHTML(FILE,DATA1,DATA2,...,OPTIONS,DETAIL) Specify the detail
%   level of the report with the value of DETAIL, an integer
%   between 0 and 3.  Greater numbers indicate greater detail.
%   The default value is 2.
%
%   See also CVDATA, CVREPORT

%   Bill Aldrich
%   Copyright 1990-2003 The MathWorks, Inc.
%   $Revision: 1.56.4.17 $  $Date: 2004/04/13 00:34:33 $


    % Global vars for coverage metrics
    global gcondition gdecision grelation gmcdc gsigrange gtableExec;

    % Global vars for report settings (copy changes to set_global_options)
    global gAllTestInMdlSumm gBarGrInMdlSumm gTwoColorBarGraphs gBarGraphBorder;
    global gHitCntInMdlSumm gCombineCndTF gElimFullCov gNoCCwithMCDC;
    global gComplexInSumm gComplexInBlkTable;
    
    % Other global variables
    global gImageSubDirectory gPerformTiming gMathWorksTesting gtableDataCache;
    global gCovDisplayOnModel gCumulativeReport;
    
    persistent optionsTable MetricVal;
    
   
    if isempty(optionsTable)

        % The optionsTable is an nx4 cell array containing a list of 
        % boolean options for HTML report generation.  The table is 
        % used to generate a set of checkboxes for customizing the 
        % HTML report.  Each row contains:
        % 
        %   1. Checkbox text
        %   2. Global var name used within this file
        %   3. Unique text string used to serialize settings and save in mdl file
        %   4. Default value
        % 
        % If a row begins with '>----------' in the first column it represents a
        % dividing line within the GUI.
        %
        % New options require a new row here and global declarations in this function
        % and any other place the flag will be accessed.
    
        optionsTable = { ...
'Include each test in the model summary',                   'gAllTestInMdlSumm',    'aTS',  1; ...
'Produce bar graphs in the model summary',                  'gBarGrInMdlSumm',      'bRG',  1; ...
'Use two color bar graphs (red,blue)',                      'gTwoColorBarGraphs',   'bTC',  0; ...
'Display hit/count ratio in the model summary',             'gHitCntInMdlSumm',     'hTR',  0; ...        
'Do not report fully covered model objects',                'gElimFullCov',         'nFC',  0; ...
'Include cyclomatic complexity numbers in summary',         'gComplexInSumm',       'scm',  1; ...
'Include cyclomatic complexity numbers in block details',   'gComplexInBlkTable',   'bcm',  1; ...
        };
        
        [rows,col] = size(optionsTable);
        for i=1:rows
            optionsTable{i} = xlate(optionsTable{i});
        end
        MetricVal = cv_metric_names('all','struct');
    end
    
    gImageSubDirectory = 'scv_images';
    suppressBrowser = 0;
    gBarGraphBorder = 1;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Look for the variable 
    % 'do_cvhtml_timing_analysis' to
    % enable timing
    try,
        prevLastErr = lasterr;
        gPerformTiming = evalin('base','do_cvhtml_timing_analysis');
    catch
        lasterr(prevLastErr);
        gPerformTiming = 0;
    end
    
          
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Look for the variable 
    % 'BnT_simcoverage_testing' to
    % enable timing
    try,
        prevLastErr = lasterr;
        gMathWorksTesting = evalin('base','BnT_simcoverage_testing');
    catch
        lasterr(prevLastErr);
        gMathWorksTesting = 0;
    end
    
          
    %%%%%%%%%%%%%%%%%%%%%
    % Check arguments
    if ~ischar(fileName)
        error('File name should be a string');
    end
    
    
    %%%%%%%%%%%%%%%%%%%%%
    % The options table is 
    % extracted with the 
    % command cvhtml('optionsTable')
    if nargin < 2,
        if strcmp(fileName,'optionsTable')
            varargout{1} = optionsTable;
            return;
        else
            error('At least one cvdata argument is needed');
        end
    end
    
    
    %%%%%%%%%%%%%%%%%%%%%
    % Check if this is a call 
    % to generate a table map 
    % for a large look-up table
    if strcmp(fileName,'@table_link')
        tableIdx = varargin{1};
        if ischar(tableIdx)
            tableIdx = str2num(tableIdx);
        end
            
        tableInfo = html_info_mgr('get','lookupTableInfo',tableIdx);
        if ~isempty(tableInfo{1})
            local_browser_mgr('displayFile', tableInfo{1});
        else
            filePath = local_browser_mgr('rootCovFile',varargin);
            filePath = file_url_2_path(filePath);
            filePath = strrep(filePath,'.html','');
            childFileName = [filePath '_t' num2str(tableIdx) '.html'];
            outFile = fopen(childFileName,'w');
            
            fprintf(outFile,'<HTML>\n');
            fprintf(outFile,'<HEAD>\n'); 
            fprintf(outFile,'<TITLE> Look-up Table Coverage Details </TITLE>\n'); 
            fprintf(outFile,'</HEAD>\n'); 
            fprintf(outFile,'\n'); 
            fprintf(outFile,'<BODY>\n'); 

            fprintf(outFile,'\n<BR> &nbsp; <B> Look-up Table Details </B> <BR>\n');
            fprintf(outFile,'<table cellpadding=8 border=0> <tr> <td>\n');
    
            % Table map showing execution counts for each interval
            [fileNames, cntThresh] = prepare_table_mapping_output(tableInfo{3});
    
            outStr = table_map( tableInfo{2}, ...
                                tableInfo{3}, ...
                                tableInfo{4}, ...
                                tableInfo{5}, ...
                                gImageSubDirectory, ...
                                fileNames, ...
                                cntThresh);

            fprintf(outFile,'%s',outStr);
            fprintf(outFile,'\n</td><td>\n');
            
            % Table legend explaining the signifigance of each color
            make_table_map_legend(outFile,[],[]);
    
            fprintf(outFile,'\n</td></tr> </table>\n');
            fprintf(outFile,'<BR>\n\n'); % Vertical space
            
            [fileDir, fileName, fileExt] = fileparts(filePath);
            baseName = [fileName '.html'];
            fprintf(outFile,'<A HREF="%s#refobj%d">Back to main report </A>',baseName,tableInfo{6});
            fprintf(outFile,'</BODY>\n');
            fprintf(outFile,'</HTML>\n'); 
            fprintf(outFile,'\n');      

            fclose(outFile);
            tableInfo{1} = childFileName;
            html_info_mgr('set',1,tableInfo,'lookupTableInfo',tableIdx); 
            html_info_mgr('childpage',childFileName);
            
            local_browser_mgr('displayFile', childFileName);
        end
        return;
    end
    
    
    
    %%%%%%%%%%%%%%%%%%%%%
    % Look for special case 
    % cvhtml('help','options')
    if nargin==2 & strcmp(fileName,'help') & ischar(varargin{1}) & ...
        strcmp(varargin{1},'options')
        disp(' ');
        disp(' ');
        
        disp('  String   Description                                                  Default');
        disp('  -----------------------------------------------------------------------------');
        
        [rowCnt,colCnt] = size(optionsTable);
        for i=1:rowCnt
            if strcmp(optionsTable{i,1},'>----------')
                disp(' ');
            else
                if optionsTable{i,4}==1
                    defaultStr = '[ON]';
                else
                    defaultStr = '[OFF]';
                end
                dispStr = sprintf('  %s      %s%s %s', ...
                                    optionsTable{i,3}, ...
                                    optionsTable{i,1}, ...
                                    char(32*ones(1,60-length(optionsTable{i,1}))), ...
                                    defaultStr);
                disp(dispStr);
            end
        end
        disp(' ');
        disp(' ');
        return;
    end
    
    detail = 2;
    
    useDefaultOptions = 1;

    %Assume no cumulative report
    gCumulativeReport = 0;
    
    %Assume no tests found
    allTests = {};

	for i = 1:length(varargin)
		arg = varargin{i};
		switch(class(arg))
		case 'double'
			if length(arg) > 1 | arg < 0 | arg > 3
				error('Detail level should be specified as a scalar between 0 and 3.');
			end; %if
		case 'char'
			if strcmp(arg, '-Cumulative_Report')
				gCumulativeReport = 1;
			else
				set_global_options(optionsTable, arg);
				useDefaultOptions = 0;
			end; %if
		case 'cvdata'
			if ~isempty(allTests)
				if allTests{1}.rootId ~= arg.rootId
					error(sprintf('Argument %d is incompatible with the preceding cvdata arguments', i));
				end; %if
			end; %if
			allTests{end + 1} = arg;
		end; %switch
	end; %for

    if useDefaultOptions
        set_global_options(optionsTable,'');
    end
    
    
    %%%%%%%%%%%%%%%%%%%%%
    % Produce a data total object
    testIds = allTests{1}.id;
    if length(allTests)>1
        total = allTests{1};
        for i=2:length(allTests)
            total = total + allTests{i};
            testIds = [testIds allTests{i}.id];
        end

        %Total passed in for cumulative report, computer for normal reports
        if gCumulativeReport
            total = allTests{end};
        else
            allTests{i+1} = total;
        end; %if
    end
	
    %%%%%%%%%%%%%%%%%%%%%
    % Determine which metrics 
    % to include and process 
    % data
	
	% Metrics will be subset of 1st test's metrics
	metricNames = non_empty_fieldnames(allTests{1})';
	
	% Take intersection of metric names for all tests
	if length(allTests) > 1
		for i = 1:length(allTests)
			thisMetrics = non_empty_fieldnames(allTests{i})';
			metricNames = intersect(metricNames, thisMetrics);
		end
	end
	
	% Setup metrics
	for i = 1:length(metricNames)
		feval(['report_' lower(metricNames{i}) '_setup'], allTests{:});
	end; %for
   
    %%%%%%%%%%%%%%%%%%%%%
    % Check that the model
    % is open and the handles
    % are up to date.
    modelcovId = cv('get',allTests{1}.rootId,'.modelcov');
    [modelH,modelName] = cv('get',modelcovId,'.handle','.name');
    if (modelH==0)    
        prevError = lasterr;
        try
            h = get_param(modelName,'Handle');
        catch
            lasterr(prevError);
            prevError = lasterr;
            try
                eval([modelName,'([],[],[],''load'');'], '');
                h = get_param(modelName,'Handle');
            catch
                h = 0;
            end
        end
        if h > 0,
            status = refresh_model_handles(modelcovId,modelName);
            if status==0,
                warning(sprintf('The structure within %s has changed since the coverage data was collected.',modelName));
            end
            gModelIsOpen = 1;
        else
            gModelIsOpen = 0;
        end
    else
        gModelIsOpen = 1;
    end
    
    tStartInfoBuid = clock;
    if gMathWorksTesting
        waitbarH = [];
    else
        waitbarH = waitbar(0,'Collecting Coverage Data');
    end
    
    [cvstruct,sysCvIds] = report_create_structured_data(allTests, testIds, metricNames,waitbarH,1);
    
    % Return early if there is nothing to report
    topCvId = cv('get',allTests{1}.rootId,'.topSlsf');
    noData =((~any(strcmp(metricNames,'decision')) || (cv('MetricGet',topCvId,MetricVal.decision,'.dataCnt.deep') == 0)) & ...
             (~any(strcmp(metricNames,'condition')) || (cv('MetricGet',topCvId,MetricVal.condition,'.dataCnt.deep') == 0)) & ...
             (~any(strcmp(metricNames,'mcdc')) || (cv('MetricGet',topCvId,MetricVal.mcdc,'.dataCnt.deep') == 0)) & ...
             (~any(strcmp(metricNames,'tableExec')) || (cv('MetricGet',topCvId,MetricVal.tableExec,'.dataCnt.deep') == 0)) & ...
             (~any(strcmp(metricNames,'sigrange'))));
    
	if isempty(noData)
		noData = 1;
	end

    if (noData)
        if ~isempty(waitbarH)
            delete(waitbarH);
        end
        if ~strcmp(get_param(0,'ForceModelCoverage'),'on')
            disp(sprintf('The model "%s" has no coverage information to report.',modelName));
        end
        return;
    end
    
    
    if gPerformTiming
        disp(sprintf('Built the model coverage info struct in %g seconds',etime(clock,tStartInfoBuid)));
    end
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Look for the variable 
    % 'feature_new_cv_ui_display' to
    % new UI display.
    if isempty(gCovDisplayOnModel)
        gCovDisplayOnModel = 0;    
    end
    
	try,
        prevLastErr = lasterr;
	    useNewUi = slfeature('CoverageDiagramUI') && gCovDisplayOnModel && ~gMathWorksTesting;
	catch
        lasterr(prevLastErr);
        useNewUi = 0;
    end
    
    if (useNewUi) && (  any(strcmp(metricNames,'decision')) || ...
                        any(strcmp(metricNames,'condition')) || ...
                        any(strcmp(metricNames,'sigrange')))
        informerUddObj = get_informer;
        informerUddObj.title = ['Coverage: ' cvstruct.model.name];
        informerUddObj.defaultText = default_informer_text;
        informerUddObj.show;
        cv('set',cvstruct.model.cvId ,'modelcov.currentDisplay.informer',  informerUddObj);
        cv_display_on_model(cvstruct, metricNames, informerUddObj);
        informer_add_close_callback(informerUddObj, cvstruct.model.cvId);
    end
   
    
    % Return early if there is no file to create
    if isempty(fileName)
        % Clear persistent 
        % memory in the metric
        % detail functions
        condition_details;
        decision_details;
        mcdc_details;
        return;
    end


    [path,name,ext,ver] = fileparts(fileName);
    if (isempty(path))
        path = pwd;
    end
    baseFileName = fullfile(path,[name '.html']);
    tStartHTML = clock;
    outFile = fopen(baseFileName,'w');
    if (outFile==-1)
        error('Could not create the output file');
    end

    uncovIdArray = list_leaf_uncovered(cvstruct);    
    htmlData.linkTable = create_hlmtl_link_table(allTests{1}.rootId);

    sections = dump_html(outFile, cvstruct,metricNames,uncovIdArray,allTests,waitbarH);
        
    if ~isempty(gtableDataCache)
        htmlData.lookupTableInfo = gtableDataCache;
    end
    
    add_persistent_data_to_html(outFile, htmlData);
    fclose(outFile);
    prepare_image_files;    
    gAddNavigationAids = 1;

    if (gAddNavigationAids) 
        extraFileDir = tempdir;
        % See Geck 118176
        % mainFileName = fullfile(extraFileDir,[modelName '_main.html']);
        % navFileName = fullfile(extraFileDir,[modelName '_navigation.html']);
        mainFileName = [tempname '_' modelName '_main.html'];
        navFileName = [tempname '_' modelName '_navigation.html'];
        mainFile = fopen(mainFileName,'w');
        navFile = fopen(navFileName,'w');
        if (mainFile == -1) | (navFile == -1)
            error('Unable to create HTML report file.');
        end;
        
        % =========================== Main File ===============================        

        fprintf(mainFile,'<HTML>\n');
        fprintf(mainFile,'<HEAD>\n');
        fprintf(mainFile,'<TITLE> %s Coverage Report </TITLE>\n',modelName);
        fprintf(mainFile,'</HEAD>\n');
        fprintf(mainFile,'\n');
        fprintf(mainFile,'<frameset rows="25,*">\n');
        fprintf(mainFile,'    <frame src="file:///%s" marginheight=3 marginwidth=15 noresize frameborder="no" scrolling="no">\n',navFileName);
        fprintf(mainFile,'    <frame name="mainFrame" src="file:///%s" frameborder="no">\n',baseFileName);
        fprintf(mainFile,'</frameset>\n');
        fprintf(mainFile,'</HTML>\n');
        fprintf(mainFile,'\n');
        fclose(mainFile);        
        
        % ========================= Navigation File ===========================        

        fprintf(navFile,'<HTML>\n');
        fprintf(navFile,'<HEAD>\n');
        fprintf(navFile,'</HEAD>\n');
        fprintf(navFile,'<BODY>\n');
        
        for i=1:length(sections)
            sectionHtmlTag = lower(sections{i});
            sectionHtmlTag = strrep(sectionHtmlTag,' ','_');

            fprintf(navFile,'<a href="file:///%s#%s" target="mainFrame"> %s </a>\n', ...
                            baseFileName, ...
                            sectionHtmlTag, ...
                            sections{i});
            
            if (i ~= length(sections))
                fprintf(navFile,' &nbsp; | &nbsp;\n');
            end
        end

        if ~isempty(docroot)
            fprintf(navFile,[' &nbsp; | &nbsp; <a href="matlab:helpview([docroot ''/toolbox/slvnv/slvnv.map'']' ...
                             ', ''modelcoverage_report'');" target="mainFrame"> Help </a>\n']); 
        end
        
        fprintf(navFile,'</BODY>\n');
        fprintf(navFile,'</HTML>\n');
        fclose(navFile);        
        browserLoc = mainFileName;
    else
        browserLoc = baseFileName;
    end

    
    if ~isempty(waitbarH)
        delete(waitbarH);
    end
    
    if gPerformTiming
        disp(sprintf('Created the HTML file in %g seconds',etime(clock,tStartHTML)));
    end
     
    %%%%%%%%%%%%%%%%%%%%%
    % Clear persistent 
    % memory in the metric
    % detail functions
    condition_details;
    decision_details;
    mcdc_details;
    

    %%%%%%%%%%%%%%%%%%%%%
    % Load the generated
    % file in the help
    % browser.
    if(gMathWorksTesting || isempty(browserLoc))
        return;
    end

    hBrowser = local_browser_mgr('displayFile',browserLoc);
    if ~isempty(hBrowser)
        % Load the htmlinfo into the persistent data of the info mgr function
        html_info_mgr('load',browserLoc,htmlData);

        % Install information about this report in cv.dll to enable 
        % bi-directional linking
        cv('set', modelcovId ...
            ,'modelcov.currentDisplay.baseReportName',  baseFileName ...
            ,'modelcov.currentDisplay.browserWindow',   hBrowser);
    else
        disp(['Unable to open coverage report in the MATLAB Help Browser. ' ...
         'Hyper-links to Simulink models will only work in the MATLAB ' ...
         'Help Browser.']);
    end



function add_persistent_data_to_html(outFile, htmlData)

    % Add the persistent link info to the HTML file
    linkTableStr = sf('Private','mx2str',htmlData);    
    linkTableStr = strrep(linkTableStr,'\','\\');
    linkTableStr = strrep(linkTableStr,'"','\"');
    linkTableStr = strrep(linkTableStr,char(10),'\n');
    nLines = ceil(length(linkTableStr)/80); 
    
    if (nLines==1)
        fprintf(outFile,'\n\n<MX2STR STRING="%s">',linkTableStr);
    else
        startCharIdx = 1;
        endCharIdx = 80;
        nextLength = 80;

        if linkTableStr(endCharIdx) == '\'
            endCharIdx = endCharIdx + 1;
        end
        
        fprintf(outFile,'\n\n<MX2STR STRING="%s"',linkTableStr(startCharIdx:endCharIdx));
        
        while((endCharIdx+80)<length(linkTableStr))
            startCharIdx = endCharIdx+1;
            endCharIdx = startCharIdx+80;
            if (linkTableStr(endCharIdx) == '\')
                endCharIdx = endCharIdx + 1;
            end
            fprintf(outFile,'\n\t"%s"',linkTableStr(startCharIdx:endCharIdx));

        end
        fprintf(outFile,'\n\t"%s">',linkTableStr((endCharIdx+1):end));
    end



function names = non_empty_fieldnames(cvdata_obj)

names = {};

% Get list of all metrics
allNames = fieldnames(cvdata_obj.metrics)';

for i = 1 : length(allNames)
	if (~isempty(getfield(cvdata_obj.metrics, allNames{i}))) & (is_cvtest_metric_enabled(cvdata_obj, allNames{i}))
		names = [names {allNames{i}}];
	end;
end; %for

function result = is_cvtest_metric_enabled(cvdata_obj, metric_name)

if isDerived(cvdata_obj)
	result = 1;
else
	cvtest_obj = cvtest(cvdata_obj.id);
	result = eval(['cvtest_obj.settings.' metric_name]);
end;
	

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%                        DATA_SYNTHESIS_FUNCTIONS                        %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [removeSystems,cvstruct] = fix_eml_script_hierarchy(removeSystems,cvstruct)

    cfChartIsa = sf('get','default','chart.isa');
    
    for sysIdx = 1:length(cvstruct.system)
        [origin,sfId,sfIsa] = cv('get',cvstruct.system(sysIdx).cvId,'.origin','.handle','.refClass');
        if (origin==2 && sfIsa==cfChartIsa) % Stateflow chart object
            if sf('get',sfId,'.type')==2  % EML Chart
                emlFcnBlockIdx = cvstruct.system(sysIdx).blockIdx;
                emlFcnCvId = cvstruct.block(emlFcnBlockIdx).cvId;
                parentSysIdx = sysIdx - 1;
                
                cvstruct.system(parentSysIdx).blockIdx = emlFcnBlockIdx;
                removeSystems(sysIdx) = 1;
            end
        end
    end
    

function out = intersection(s1,s2)
    r = sort([s1(:);s2(:)]);
    I = (r(1:(end-1))==r(2:end));
    out = r(I);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FIND_FULL_COVERAGE_SYSTEMS - Eliminate systems 
% that were fully covered

function removeSystem = find_full_coverage_systems(cvstruct),

	sysCnt = length(cvstruct.system);
	removeSystem = zeros(sysCnt,1);
	
	for i=1:sysCnt
		if (cvstruct.system(i).flags.fullCoverage==1)
			removeSystem(i) = 1;
		end
	end

    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FIND_INDEX_VALS - Return a vector that indicates if
% a set value exists in testSet.  The function assumes
% that every element of testset exists in set.

function isMatched = find_index_vals(set,testset)

    [sortSet,reverseSort] = sort(set(:));
    remove = sort([sortSet testset(:)]);
    remove = (remove == [remove(2:end);NaN]);
    isMatched = remove + [remove(2:end);0];
    isMatched(remove) = [];
    
    


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                         HTML_OUTPUT_GENERATION                         %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LIST_LEAF_UNCOVERED - Traverse the agregate data 
% structure and capture an array of IDs of for objects
% that have uncovered constructs.

function uncovIdArray = list_leaf_uncovered(cvstruct)

    uncovIdArray = [];
    
    if isempty(cvstruct) || ~isfield(cvstruct,'system') || isempty(cvstruct.system)
        return;
    end
    
    for i=1:length(cvstruct.system);
        sysEntry = cvstruct.system(i);

        if (sysEntry.flags.leafUncov ==1)
            uncovIdArray = [uncovIdArray sysEntry.cvId];
        end
        
        for blockI = sysEntry.blockIdx(:)'
            blkEntry = cvstruct.block(blockI);
        
            if (blkEntry.flags.leafUncov ==1)
                uncovIdArray = [uncovIdArray blkEntry.cvId];
            end
        end
    end
    



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DUMP_HTML - Main routine to produce HTML.  Return a 
%             cell array with the report sections that
%             should be linked in the navigation frame
%
function sections = dump_html(outFile, cvstruct, metricNames, uncovIdArray, allTests, waitbarH)

    global gCumulativeReport;

    fprintf(outFile,'<HTML>\n');
    fprintf(outFile,'<HEAD>\n'); 
    fprintf(outFile,'<TITLE> %s Coverage Report </TITLE>\n',cvstruct.model.name); 
    fprintf(outFile,'</HEAD>\n'); 
    fprintf(outFile,'\n'); 
    fprintf(outFile,'<BODY>\n'); 
    fprintf(outFile,'<H1>Coverage Report for %s</H1>\n',cvstruct.model.name); 
        
    % System table template
    testCnt = length(cvstruct.tests);
    if testCnt>1
        if gCumulativeReport
            columnCnt = testCnt;
            totalIdx = testCnt;
        else
        columnCnt = testCnt+1;
        totalIdx = testCnt+1;
        end
    else
        columnCnt = 1;
        totalIdx = 1;
    end
    
    %%%%%%%%%%%%%%%%%%%%%
    % Create the Test List
    %
    fprintf(outFile,'<H2>Tests</H2>\n'); 
    for i=1:testCnt
        report_test(outFile,allTests{i}.id,i);
    end
   
    %%%%%%%%%%%%%%%%%%%%
    % Structural coverage
    %
    if isfield(cvstruct,'system') && ~isempty(cvstruct.system)
        dump_structural_coverage(outFile, cvstruct, metricNames, uncovIdArray, allTests, waitbarH);
        sections = {'Summary','Details'};
    else 
        sections = {};
    end

    %%%%%%%%%%%%%%%%%%%%
    % Signal Ranges
    %
    if any(strcmp(metricNames,'sigrange'))
        topCvId = cv('get',cvstruct.root.cvId,'.topSlsf');
        dump_model_signal_range(outFile, topCvId, waitbarH);
        sections{end+1} = 'Signal Ranges';
    end

    if (outFile ~= -1)
        fprintf(outFile,'</BODY>\n');
        fprintf(outFile,'</HTML>\n'); 
        fprintf(outFile,'\n');      
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DUMP_STRUCTURAL_COVERAGE - Create all coverage that is reported on the model
%                            hierarchy.
%
function dump_structural_coverage(outFile, cvstruct, metricNames, uncovIdArray, allTests, waitbarH)

    % Global vars for report settings (copy changes to set_global_options)
    global gAllTestInMdlSumm gBarGrInMdlSumm gHitCntInMdlSumm gCombineCndTF gElimFullCov;
    global gNoCCwithMCDC;
    global gComplexInSumm gComplexInBlkTable;
    global gImageSubDirectory gTwoColorBarGraphs gBarGraphBorder;
    global gCumulativeReport;

    canHaveTruthTables = (sfversion('Full_Number') > 5.100e7);
    hasDecisionInfo = any(strcmp(metricNames,'decision'));
    hasMcdcInfo = any(strcmp(metricNames,'mcdc'));
    hasConditionInfo = any(strcmp(metricNames,'condition'));
    hasTableExecInfo = any(strcmp(metricNames,'tableExec'));

    % System table template
    testCnt = length(cvstruct.tests);
    if testCnt>1
        if gCumulativeReport
            columnCnt = testCnt;
            totalIdx = testCnt;
        else
        columnCnt = testCnt+1;
        totalIdx = testCnt+1;
        end
    else
        columnCnt = 1;
        totalIdx = 1;
    end
    
    fprintf(outFile,'<A NAME=summary></A><H2>Summary</H2>\n'); 

    % Determine how the data will be formatted in the table
    if gHitCntInMdlSumm
        metDispFcn = '&in_covperratios';
    else
        metDispFcn = '&in_covpercent';
    end    

    if gAllTestInMdlSumm
        colIndexVar = '@1';
    else
        colIndexVar = totalIdx;
    end

    % Arrange the columns based on the coverage metrics
    metricCount = 0;
    if hasDecisionInfo
        metricCount = 1;
        if gBarGrInMdlSumm
            metricTitles = {{'CellFormat','$<B>D1</B>',2}};
            metricData = {{'If',{'&isempty','#decision'}, ...
                                 {'CellFormat','$NA',2}, ...
                           'Else', ...
                                 {metDispFcn,'#decision.outTotalCnts','#decision.totalTotalCnts',colIndexVar}, ...
                                 {'&in_bargraph','#decision.outTotalCnts','#decision.totalTotalCnts',colIndexVar}, ...
                         }};
        else
            metricTitles = {'$<B>D1</B>'};
            metricData = {{'If',{'&isempty','#decision'}, ...
                              '$NA', ...
                           'Else', ...
                              {metDispFcn,'#decision.outTotalCnts','#decision.totalTotalCnts',colIndexVar}, ...
                         }};
        end
    else
        metricTitles = [];
        metricData = [];
    end

    if hasConditionInfo
        metricCount = metricCount+1;
        if gBarGrInMdlSumm
            metricTitles = [metricTitles {{'CellFormat','$<B>C1</B>',2}}];
            metricData = [metricData ...
                         {{'If',{'&isempty','#condition'}, ...
                                {'CellFormat','$NA',2}, ...
                           'Else', ...
                                {metDispFcn,'#condition.totalHits','#condition.totalCnt',colIndexVar}, ...
                                {'&in_bargraph','#condition.totalHits','#condition.totalCnt',colIndexVar}, ...
                         }}];
        else
            metricTitles = [metricTitles {'$<B>C1</B>'}];
            metricData = [metricData ...
                         {{'If',{'&isempty','#condition'}, ...
                                '$NA', ...
                           'Else', ...
                                {metDispFcn,'#condition.totalHits','#condition.totalCnt',colIndexVar}, ...
                         }}];
        end
    end

    if hasMcdcInfo
        metricCount = metricCount+1;
        if gBarGrInMdlSumm
            metricTitles = [metricTitles {{'CellFormat','$<B>MCDC</B>',2}}];
            metricData = [metricData ...
                         {{'If',{'&isempty','#mcdc'}, ...
                                {'CellFormat','$NA',2}, ...
                           'Else', ...
                                {metDispFcn,'#mcdc.totalHits','#mcdc.totalCnt',colIndexVar}, ...
                                {'&in_bargraph','#mcdc.totalHits','#mcdc.totalCnt',colIndexVar}, ...
                         }}];
        else
            metricTitles = [metricTitles {'$<B>MCDC</B>'}];
            metricData = [metricData ...
                         {{'If',{'&isempty','#mcdc'}, ...
                                '$NA', ...
                           'Else', ...
                                {metDispFcn,'#mcdc.totalHits','#mcdc.totalCnt',colIndexVar}, ...
                         }}];
        end
    end

    if any(strcmp(metricNames,'tableExec'))
        metricCount = metricCount+1;
        if gBarGrInMdlSumm
            metricTitles = [metricTitles {{'CellFormat','$<B>TBL</B>',2}}];
            metricData = [metricData ...
                         {{'If',{'&isempty','#tableExec'}, ...
                                {'CellFormat','$NA',2}, ...
                           'Else', ...
                                {metDispFcn,'#tableExec.totalHits','#tableExec.totalCnt',colIndexVar}, ...
                                {'&in_bargraph','#tableExec.totalHits','#tableExec.totalCnt',colIndexVar}, ...
                         }}];
        else
            metricTitles = [metricTitles {'$<B>TBL</B>'}];
            metricData = [metricData ...
                         {{'If',{'&isempty','#tableExec'}, ...
                                '$NA', ...
                           'Else', ...
                                {metDispFcn,'#tableExec.totalHits','#tableExec.totalCnt',colIndexVar}, ...
                         }}];
        end
    end


    if gBarGrInMdlSumm
        colPerTest = 2*metricCount;
    else
        colPerTest = metricCount;
    end
    
    
    if gAllTestInMdlSumm
        columnData = [{'ForN',columnCnt} metricData {'$&nbsp'}];
    else
        columnData = [{'ForN',1} metricData];
    end
   

    if gComplexInSumm
        rowEntries = {'ForEach','#system', ...
                        {'CellFormat', ...
                            {'&in_tocentry',{'&in_href','#name','#cvId'},'@1','#depth'}, ...
                            1, ...
                            '$left' ...
                        }, ...    
                        { 'If', '#complexity.isModule', ...
                            {'Cat', '$<B>', '#complexity.deep', '$</B>'}, ...
                          'Else', ...
                            '#complexity.deep' ...
                        }, ...
                        columnData, ...
                        '\n' ...
                     };
                     
        heading =  {'CellFormat', ...
                        '$<B>Model Hierarchy/Complexity:</B>', ...
                        2 ...
                    };
        colSpacing = {'$ ', '$ '};
    else
        rowEntries = {'ForEach','#system', ...
                        {'CellFormat', ...
                            {'&in_tocentry',{'&in_href','#name','#cvId'},'@1','#depth'}, ...
                            1, ...
                            '$left' ...
                        }, ...    
                        columnData, ...
                        '\n' ...
                     };
                     
        heading = '$<B>Model Hierarchy:</B>';
        colSpacing = {'$ '};
    end


    if gAllTestInMdlSumm
        if gCumulativeReport
            sysTableTemplate = {heading, ...
                                {'CellFormat', '$<B>Current Run</B>',  colPerTest}, '$&nbsp', ...
                                {'CellFormat', '$<B>Delta</B>',      colPerTest}, '$&nbsp', ...
                                {'CellFormat', '$<B>Cumulative</B>', colPerTest}, '$&nbsp', ...
                                '\n', ...
                                colSpacing{:}, ...
                                {'ForN',columnCnt, metricTitles{:}, '$&nbsp'}, ...
                                '\n', ...
                                rowEntries ...
                               };
        else
            sysTableTemplate = {heading, ...
                                {'ForN',testCnt, ...
                                    {'CellFormat', ...
                                        {'Cat','$<B>Test ','@1','$</B>'}, ...
                                        colPerTest ...
                                    }, ...
                                    '$&nbsp' ...
                                }, ...
                                {'If',{'RpnExpr',testCnt,1,'>'}, ...
                                    {'CellFormat', ...
                                        '$<B>Total</B>', ...
                                        colPerTest ...
                                    } ...
                                }, ...
                                '\n', ...
                                colSpacing{:}, ...
                                {'ForN',columnCnt, metricTitles{:}, '$&nbsp'}, ...
                                '\n', ...
                                rowEntries ...
                               };
        end; %if
    else
        sysTableTemplate = {heading, ...
                            {'CellFormat', ...
                                '$<B>Total</B>', ...
                                colPerTest ...
                            }, ...
                            '\n', ...
                            colSpacing{:}, ...
                            metricTitles{:}, ...
							'$&nbsp', ...
                            '\n', ...
                            rowEntries ...
                           };
    end

    systableInfo.cols.align = 'CENTER';
    systableInfo.table = '  CELLPADDING="2" CELLSPACING="1"';
    systableInfo.textSize = 2;
    systableInfo.twoColorBarGraphs = gTwoColorBarGraphs;
    systableInfo.barGraphBorder = gBarGraphBorder;
    systableInfo.imageDir = gImageSubDirectory;
    
    tableStr = html_table(cvstruct,sysTableTemplate,systableInfo);
    fprintf(outFile,'%s',tableStr);
    fprintf(outFile,'<A NAME=details></A><H2>Details:</H2>\n'); 

    if gComplexInBlkTable
        sysSummary.mainTemplate = {'$<B>Metric</B>',   '$<B>Coverage (this object)</B>',     '$<B>Coverage (inc. descendants)</B>',  '\n', ...
                                   '$Cyclomatic Complexity',  ...
                                    {'If', '#complexity.isModule', ...
                                            {'Cat', '$<B>', '#complexity.shallow', '$</B>'}, {'Cat', '$<B>', '#complexity.deep', '$</B>'}, ...
                                    'Else', ...
                                    '#complexity.shallow','#complexity.deep' ...
                                     }, '\n' ...
                                   };
    else
        sysSummary.mainTemplate = {'$<B>Metric</B>',   '$<B>Coverage (this object)</B>',     '$<B>Coverage (inc. descendants)</B>',  '\n'};
    end
    
    if gComplexInBlkTable
        blkSummary.mainTemplate = {'$<B>Metric</B>',            '$<B>Coverage</B>',     '\n', ...
                                   '$Cyclomatic Complexity',    '#complexity.shallow',  '\n'};
    else
        blkSummary.mainTemplate = {'$<B>Metric</B>',   '$<B>Coverage</B>', '\n'};
    end
    
    for i=1:length(metricNames)
        thisMetric =  metricNames{i};
        if ~strcmp(thisMetric,'sigrange')
            [sysTemp,blkTemp] = feval([thisMetric '_summary'],testCnt);
            sysSummary = setfield(sysSummary,thisMetric,sysTemp);
            blkSummary = setfield(blkSummary,thisMetric,blkTemp);
        end
    end


    if (~isempty(waitbarH))
        waitbar(0,waitbarH,'Reporting structural coverage');
    end
   
    % Loop through each system and itemize coverage
    newSysCnt = length(cvstruct.system);
    for i=1:newSysCnt;
        sysEntry = cvstruct.system(i);
        
        fprintf(outFile,'%s<h3>%d. %s</h3>\n', ...
                    obj_anchor(sysEntry.cvId,''), ...
                    i, ...
                    object_titleStr_and_link(sysEntry.cvId));
        
        fprintf(outFile,'<table> <tr> <td width="25"> </td> <td>\n');


        produce_navigation_table(outFile,cvstruct,sysEntry,uncovIdArray);
        fprintf(outFile,'<BR>\n\n'); % Vertical space
        produce_summary_table(outFile,sysEntry,sysSummary,metricNames);

        if hasDecisionInfo
            decision_details(outFile,sysEntry,cvstruct);
        end

        if hasConditionInfo
            condition_details(outFile,sysEntry,cvstruct);
        end

        if hasTableExecInfo
            tableExec_details(outFile,sysEntry,cvstruct);
        end
        
        if hasMcdcInfo
            mcdc_details(outFile,sysEntry,cvstruct);
        end

        fprintf(outFile,'</td> </tr> </table>\n');
        fprintf(outFile,'<BR>\n'); % Vertical space

        % Perform a special post processing when displaying Truth Tables
        % from Stateflow.
        if canHaveTruthTables
            if cv('get',sysEntry.cvId,'.origin')==2
                try,
                    sfId = cv('get',sysEntry.cvId,'.handle');
                    if (sf('get',sfId,'.isa')==sf('get','default','state.isa'))
                        is_a_truth_table = sf('get',sfId,'.truthTable.isTruthTable');
                    else
                        is_a_truth_table = 0;
                    end
                catch   
                    is_a_truth_table = 0;
                end
            else
                is_a_truth_table = 0;
            end
        else
            is_a_truth_table = 0;
        end
        
        if is_a_truth_table
            fprintf(outFile,'<table> <tr> <td width="25"> </td> <td>\n');
            fprintf(outFile,'\n<BR> &nbsp; <B> Predicate table analysis (missing values are in parentheses) </B> <BR>\n');
            tableStr = truth_table_html_cov(sysEntry.cvId, sfId, allTests{totalIdx});
            fprintf(outFile,'%s\n',tableStr);
            fprintf(outFile,'</td> </tr> </table>\n');
            fprintf(outFile,'<BR>\n'); % Vertical space
        else
            for blockI = sysEntry.blockIdx(:)'
                blkEntry = cvstruct.block(blockI);
                %
                %
                %   SKIP BLOCKS THAT ARE FULLY COVERED
                %
                %
                if ~(gElimFullCov & blkEntry.flags.fullCoverage==1)

                    fprintf(outFile,'%s<h4> &nbsp; &nbsp;%s</h4>\n', ...
                            obj_anchor(blkEntry.cvId,''), ...
                            object_titleStr_and_link(blkEntry.cvId));
                    fprintf(outFile,'<table> <tr> <td width="25"> </td> <td>\n');

                    produce_navigation_table(outFile,cvstruct,blkEntry,uncovIdArray);
                    fprintf(outFile,'<BR>\n\n'); % Vertical space
                    produce_summary_table(outFile,blkEntry,blkSummary,metricNames);

                    % Special handling for EML scripts
                    codeBlock = cv('get',blkEntry.cvId,'.code');
                    if (codeBlock>0)
                    
                        lineStart = cv('get',codeBlock,'.lineStartInd');
                        
                        if ~isfield(blkEntry,'decision') || isempty(blkEntry.decision)
                            decIdx = [];
                            decCovered = [];
                            decIds = [];
                            decLines = [];
                        else
                            decIdx = blkEntry.decision.decisionIdx;
                            decCovered = logical([cvstruct.decisions.covered]);
                            decCovered = decCovered(decIdx);
                            decIds = [cvstruct.decisions.cvId];
                            decIds = decIds(decIdx);
                            decLines = cv('CodeBloc','objLines',codeBlock,decIds);
                        end
                        
                        if ~isfield(blkEntry,'condition') || isempty(blkEntry.condition)
                            condIdx = [];
                            condCovered = [];
                            condIds = [];
                            condLines = [];
                        else
                            condIdx = blkEntry.condition.conditionIdx;
                            condCovered = logical([cvstruct.conditions.covered]);
                            condCovered = condCovered(condIdx);
                            condIds = [cvstruct.conditions.cvId];
                            condIds = condIds(condIdx);
                            condLines = cv('CodeBloc','objLines',codeBlock,condIds);
                        end
                        
                        if ~isfield(blkEntry,'mcdc') || isempty(blkEntry.mcdc)
                            mcdcIdx = [];
                            mcdcCovered = [];
                            mcdcIds = [];
                            mcdcLines = [];
                        else
                            mcdcIdx = blkEntry.mcdc.mcdcIndex;
                            mcdcIds = [cvstruct.mcdcentries.cvId];
                            mcdcIds = mcdcIds(mcdcIdx);
                            mcdcLines = cv('CodeBloc','objLines',codeBlock,mcdcIds);
                        end
                        
                        allCovered = [decIds(decCovered) condIds(condCovered)];
                        uncovered = [decIds(~decCovered) condIds(~condCovered)];
                    
                        cv('CodeBloc','refresh',codeBlock);
                        cv('CodeBloc','covered',codeBlock,allCovered);
                        cv('CodeBloc','uncovered',codeBlock,uncovered);
                        cv('CodeBloc','missingStatementHighlight',codeBlock,allTests{totalIdx}.metrics.decision);
                        allLines = unique([decLines condLines mcdcLines]);
                        
                        linkTemplate = ['#refobj' num2str(blkEntry.cvId) '_%d'];
                        cv('set',codeBlock,'.hyperlink.line',allLines,'.hyperlink.sTemplate',linkTemplate);
                        scriptHtml = cv('CodeBloc','html',codeBlock,1,1,1);
                        fprintf(outFile,'%s\n',scriptHtml);
                        
                        
                        for lineNum = allLines
                            subBlkEntry = blkEntry;
                            subBlkEntry.decision.decisionIdx = decIdx(decLines==lineNum);
                            subBlkEntry.condition.conditionIdx = condIdx(condLines==lineNum);
                            subBlkEntry.mcdc.mcdcIndex = mcdcIdx(mcdcLines==lineNum);
                            
                            if lineNum==1
                                charStart = 0;
                            else
                                charStart = lineStart(lineNum)+1;
                            end 
                            
                            if (lineNum == length(lineStart))
                                script = cv('get',codeBlock,'.code');
                                charEnd = length(script);
                            else
                                charEnd = lineStart(lineNum+1);
                            end

                            lineTxt = ['#' num2str(lineNum) ': ' str_to_html(cv('CodeBloc','getLine',codeBlock,lineNum))];
                            
                            fprintf(outFile,'%s<h4>%s</h4>\n', ...
                                    obj_anchor([blkEntry.cvId lineNum],''), ...
                                    object_titleStr_and_link([blkEntry.cvId charStart charEnd],lineTxt));

                            if hasDecisionInfo
                                decision_details(outFile,subBlkEntry,cvstruct,0);
                            end
        
                            if hasConditionInfo
                                condition_details(outFile,subBlkEntry,cvstruct);
                            end
        
                            if hasTableExecInfo
                                tableExec_details(outFile,subBlkEntry,cvstruct);
                            end
                            
                            if hasMcdcInfo
                                mcdc_details(outFile,subBlkEntry,cvstruct);
                            end
                            
                            fprintf(outFile,'<BR>\n'); % Vertical space
                       end
                        
                    else
                        % WISH Abstract this so it works for all metrics:
                        if hasDecisionInfo
                            decision_details(outFile,blkEntry,cvstruct);
                        end
    
                        if hasConditionInfo
                            condition_details(outFile,blkEntry,cvstruct);
                        end
    
                        if hasTableExecInfo
                            tableExec_details(outFile,blkEntry,cvstruct);
                        end
                        
                        if hasMcdcInfo
                            mcdc_details(outFile,blkEntry,cvstruct);
                        end

                    end

                    fprintf(outFile,'</td> </tr> </table>\n');

                    fprintf(outFile,'<BR>\n'); % Vertical space
                end
            end
        end
        if (~isempty(waitbarH))
            waitbar(i/newSysCnt,waitbarH);
        end
    end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PRODUCE_SUMMARY_TABLE - Generate a summary table 
% with the coverage numbers for each metric. Dump the
% table directly to the HTML output file.

function produce_summary_table(outFile,dataEntry,summaryTemplates,metricNames);

    global gImageSubDirectory

    template = summaryTemplates.mainTemplate;
    
    for i=1:length(metricNames)
        thisMetric =  metricNames{i};
        if ~isempty(getfield(dataEntry,thisMetric))
            template = [template getfield(summaryTemplates,thisMetric)];
        end
    end
    
    tableInfo.cols.align = 'LEFT';
    tableInfo.cols.width = 200;
    tableInfo.imageDir = gImageSubDirectory;

    tableStr = html_table(dataEntry,template,tableInfo);
    fprintf(outFile,'%s',tableStr);
    


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PRODUCE_NAVIGATION_TABLE - Generate a navigation table
% containing hyperlinks to the parent node, child systems
% and adjacent uncovered objects. Dump the table directly 
% to the HTML output file.

function produce_navigation_table(outFile,cvstruct,nodeEntry,uncovIdArray)
    global gElimFullCov;

    fprintf(outFile,'<table>\n');
    
    if (nodeEntry.sysCvId>0)
    fprintf(outFile,'  <tr><td width="150"><B>Parent: <B></td>\n');  
    fprintf(outFile,'      <td>%s</td></tr>\n', obj_full_path_link(nodeEntry.sysCvId)); 
    end  
  
    if isfield(nodeEntry,'subsystemCvId') & ~isempty(nodeEntry.subsystemCvId)
    fprintf(outFile,'  <tr valign="top"><td width="150"><B>Child Systems: <B></td>\n');  
    fprintf(outFile,'      <td>'); 
        childStr = [];
        for childId = nodeEntry.subsystemCvId(:)'
            childStr = [childStr obj_named_link(childId) ', &nbsp;'];
        end
    fprintf(outFile,'%s</td></tr>\n',childStr(1:(end-8))); 
    end  
  
    if (nodeEntry.flags.leafUncov==1)
    fprintf(outFile,'  <tr><td><B>Uncovered Links: <B></td>\n');  
    fprintf(outFile,'      <td>%s</td></tr>\n', generate_uncov_links(nodeEntry.cvId,uncovIdArray)); 
    end  
  
    fprintf(outFile,'</table>\n');




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% OBJECT_TITLESTR_AND_LINK - Produce a description of
% this model node and a quoted hyperlink back to the 
% model, e.g., Saturation block "Limit Ouput"

function titleStr = object_titleStr_and_link(idPos,addtxt)
    if nargin<2
        addtxt = [];
    end

    if ~isempty(addtxt)
        titleStr = obj_diag_named_link(idPos,addtxt);
        return;
    end
    
    id = idPos(1);
    [org,type,name,] = cv('get',id,  '.origin','.refClass', '.name');

    if (org==1)
        if (type==0)
            if( cv('get',id,'.treeNode.parent')==0 & strcmp(name,cv('get',cv('get',id,'.modelcov'),'.name')) )
                titleStr = sprintf('Model "%s"',name);
            else
                titleStr = sprintf('Subsystem "%s"',obj_diag_named_link(id));
            end
        else
            titleStr = sprintf('%s block "%s"',get_blk_typ_str(type),obj_diag_named_link(id));
        end
    elseif (org==2)
        sfClass = get_sf_class(type,id);        
        % Special case a transition
        if strcmp(sfClass,'Transition')
            sfId = cv('get',id,'.handle');
            [srcSfId,destSfId] = sf('get',sfId,'.src.id','.dst.id');
            if (srcSfId==0)
                titleStr = sprintf('Transition "%s" to %s', ...
                                    obj_diag_named_link(id),sf_obj_link(destSfId));
            else
                titleStr = sprintf('Transition "%s" from %s to %s', ...
                                    obj_diag_named_link(id),sf_obj_link(srcSfId),sf_obj_link(destSfId));
            end
        else
            titleStr = sprintf('%s "%s"',sfClass,obj_diag_named_link(idPos,addtxt));
        end
    else
        error('Origin not set properly');
    end


function str = sf_obj_link(sfId)
    if (sf('get',sfId,'.isa')==sf('get','default','state.isa'))
        % This is a state
        cvId = cv('find','all','slsfobj.handle',sfId);
        str = ['"' obj_diag_named_link(cvId(1)) '"'];
    else
        % This is a junction
        str = ['Junction #' num2str(sf('get',sfId,'.number'))];
    end


    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                      PERSISTENT_DATA_FUNCTIONS                         %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function PERSISTENT_DATA_FUNCTIONS

function varargout = cvstruct_value(value)

    persistent cvstruct;
    
    if nargin>0
        cvstruct = value;
    end
    
    if nargout>0
        varargout{1} = cvstruct;
    end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                         HTML_UTILITY_FUNCTIONS                         %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function HTML_UTILITY_FUNCTIONS

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% REPORT_TEST - Create a table with the 
% properties of a test.
%

function report_test(templateFile,testId,index),

    global gCumulativeReport;

    [label,startTime,stopTime,mlSetupCmd ] = cv('get',testId,'testdata.label', ...
                                                'testdata.startTime','testdata.stopTime', ...
                                                'testdata.mlSetupCmd');

    if gCumulativeReport
        nameStr = label;
    else
        nameStr = ['Test ' num2str(index)];
        if ~isempty(label)
            nameStr = [nameStr ', ' label];
        end
    end; %if
    
    fprintf(templateFile,'<H3> %s </H3>\n',obj_anchor(testId,nameStr));
    fprintf(templateFile,'<TABLE>\n');
    fprintf(templateFile,'<TR> <TD> Started Execution: <TD> %s </TR>\n',startTime);
    fprintf(templateFile,'<TR> <TD> Ended Execution: <TD> %s </TR>\n',stopTime);
    if ~isempty(mlSetupCmd)
    fprintf(templateFile,'<TR> <TD> Setup Command: <TD> %s </TR>\n',mlSetupCmd);
    end
    fprintf(templateFile,'</TABLE>\n');

    


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GENERATE_UNCOV_LINKS - Create links to the next and
% prev uncovered objects in the report.

function str = generate_uncov_links(id,uncovArray)

    index = find(id==uncovArray);
    
    %str = '&nbsp Uncovered objects: ';
    str = '';
    
    if (index>1)
        prevId = uncovArray(index-1);
        str = [str  '&nbsp;' image_with_text('left_arrow.gif','Previous uncovered object',prevId)];
    end

    if (index < length(uncovArray))
        nextId = uncovArray(index+1);
        str = [str  '&nbsp;' image_with_text('right_arrow.gif','Next uncovered object',nextId)];
    end

    str = [str '<br>' 10];
  
   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% IMAGE_WITH_TEXT - Create an inlined HTML image with 
% alt text and possibly a link

function out = image_with_text(file,text,linkId),

    global gImageSubDirectory

    if isempty(text)
        textIn = '';
    else
        textIn = sprintf(' ALT="%s"',text);
    end
    if isempty(linkId)
        out = sprintf('<IMG SRC="%s"%s>',file,textIn);
    else
       out = sprintf('<A HREF=#refobj%d><IMG SRC="%s/%s"%s border=0></A>', ...
                        linkId,gImageSubDirectory,file,textIn);
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% OBJ_DIAG_LINK - Create an HTML link to an object

function out = obj_diag_link(id,str),
    num = cv('get',id(1),'.number');
    if length(id)>1
        out = sprintf('<A href="matlab: cvdisplay([%d %d %d]);">%s</A>',num,id(2),id(3),str);
    else
        out = sprintf('<A href="matlab: cvdisplay(%d);">%s</A>',num,str);
    end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% OBJ_DIAG_NAMED_LINK - Create an HTML link to an object using
% the name as the label.

function out = obj_diag_named_link(id,addtxt),
    if nargin<2
        addtxt = [];
    end

    if ~isempty(addtxt)
        str = addtxt;
        maxLength = 80;
    else
        str = cr_to_space(cv('get',id(1),'.name'));
        maxLength = 40;
    end
    
    if length(str) > maxLength
        str = [str(1:maxLength) '...'];
    end
        
    if (id==0)
        out = 'NA ';
    else
        out = obj_diag_link(id,str);
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% OBJ_ANCHOR - Create the HTML anchor for an object

function out = obj_anchor(id,str),
    if length(id)>1
        out = sprintf('<A NAME=refobj%d_%d>%s</A>',id(1),id(2),str);
    else
        out = sprintf('<A NAME=refobj%d>%s</A>',id,str);
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% OBJ_LINK - Create an HTML link to an object

function out = obj_link(id,str),
    if length(id)>1
        out = sprintf('<A HREF=#refobj%d_%d>%s</A>',id(1),id(2),str);
    else
        out = sprintf('<A HREF=#refobj%d>%s</A>',id,str);
    end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% OBJ_NAMED_LINK - Create an HTML link to an object using
% the name as the label.

function out = obj_named_link(id),
    if (id==0)
        out = 'NA ';
    else
        if length(id)>1
            out = obj_link(id,[cr_to_space(cv('get',id,'.name')) ' (#' num2str(id(2)) ')']);
        else
            out = obj_link(id,cr_to_space(cv('get',id,'.name')));
        end
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% OBJ_FULL_PATH_LINK - Create an HTML link to an object using
% the full path as the label.

function out = obj_full_path_link(id),
    if (id==0)
        out = 'NA ';
    else
        if (cv('get',id,'.origin')==1 )  % This is a SL id
            slH = cv('get',id,'.handle');
            label = [cr_to_space(get_param(slH,'Parent')) '/' cr_to_space(cv('get',id,'.name')) ];
        else
            sfId = cv('get',id,'.handle');
            label = sf('FullNameOf',sfId,'.');
        end
        out = obj_link(id,label);
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% OBJ_NAMED_TRUNC_LINK - Create an HTML link to an object using
% the name as the label, but truncate the label after n chars

function out = obj_named_trunc_link(id,n),
    str = cr_to_space(cv('get',id,'.name'));
    if length(str) > n
        str = [str(1:n) '...'];
    end
    if (id==0)
        out = 'NA ';
    else
        out = obj_link(id,str);
    end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PREPARE_IMAGE_FILES - Image files are placed in the
% directory scv_images.  If this directory does not exist
% it is created with the report.  The image files are 
% copied into this directory the first time the report is
% created and a text file version###.txt is created, where
% ### is replaced with the current version string.  This
% file indicates that the directory has all the needed files 
% and images will not need to be copied.  If the version
% file is out of date all the image files are updated to 
% ensure the report will display correctly.

function prepare_image_files

    currentVersion = '100';
    localImageDir = fullfile(pwd,'scv_images');
    
    if (exist(localImageDir)==7)
        if(exist(fullfile(localImageDir,['version' currentVersion '.txt']))==2)
            return;
        else
            copyAllFiles = 1;
        end
    else
        mkdir('scv_images');
        copyAllFiles = 1;
    end

    if (copyAllFiles)
        imageDir = fullfile(matlabroot,'toolbox','simulink','simcoverage','private');


        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % ADD NEW IMAGE FILES HERE!! AND INCREMENT THE
        % currentVersion string above.
        imageFiles =    { ...
                            'grn01.gif', ...
                            'grn02.gif', ...
                            'grn03.gif', ...
                            'grn04.gif', ...
                            'grn05.gif', ...
                            'grn06.gif', ...
                            'grn07.gif', ...
                            'grn08.gif', ...
                            'grn09.gif', ...
                            'red.gif', ...
                            'purple.gif', ...
                            'trans.gif', ...
                            'blue.gif', ...
                            'ltblue.gif', ...
                            'ltgrn.gif', ...
                            'yellow.gif', ...
                            'black.gif', ...
                            'dkgrn.gif', ...
                            'horz_line.gif', ...
                            'vert_line.gif', ...
                            'right_arrow.gif', ...
                            'left_arrow.gif' ...
                        };

        for file = imageFiles
            copyfile(fullfile(imageDir,file{1}),fullfile(localImageDir,file{1}));
        end
        
        copyfile(fullfile(imageDir,'version.txt'), ...
                 fullfile(localImageDir,['version' currentVersion '.txt']));
    end


function sfblockPath = find_block_sf_anccestor(blockH)
    
    while blockH ~= bdroot(blockH)
        if strcmp(get_param(blockH,'MaskType'),'Stateflow') 
            sfblockPath = getfullname(blockH);
            return;
        else
            blockH = get_param(get_param(blockH,'Parent'),'Handle');
        end
    end
    sfblockPath = '';
    
function out = create_hlmtl_link_table(rootId)

    topSlsfId = cv('get',rootId,'.topSlsf');
    cv('NumberTree',topSlsfId);
    
    allSlsf = [topSlsfId cv('DecendentsOf',topSlsfId)];
    nmbrs = cv('get',allSlsf,'slsfobj.number');
    
    % Put the IDs in sequence
    [nmbrs,sortI] = sort(nmbrs);
    allSlsf = allSlsf(sortI);
    handles = cv('get',allSlsf,'slsfobj.handle');
    
    % Create the cell array and fill the first two columns
    out = num2cell([allSlsf(:) handles(:)]);
    out = [out cell(length(allSlsf),1)];
    
    % Now we need to create the string entries
    isSl = cv('get',allSlsf,'.origin')==1;
    
    slHandles = handles(isSl);
    slFullPaths = getfullname(slHandles);
    if ~iscell(slFullPaths)
        slFullPaths = {slFullPaths};
    end
    out(find(isSl),3) = slFullPaths;
    
    isChart = ~isSl & [cv('get',allSlsf,'.refClass')==sf('get','default','chart.isa')];
    sfNoChartIds = handles(~isSl & ~isChart);

    isState = ~isSl & [cv('get',allSlsf,'.refClass')==sf('get','default','state.isa')];
    isTrans = ~isSl & ~isChart & ~isState;

    % The instance fullpath is the same as the Simulink subsystem block that
    % immeadiately precedes the set of SF Ids
    startSfIdx = find([isSl(:);0]==1 & [isSl(2:end);1;1]==0 );   % find i, s.t. obj(i)=Simulink, obj(i+1)=Stateflow
    endSfIdx = find([1;isSl(:)]==0 & [isSl(:);1]==1 );           % find i, s.t. obj(i-1)=Stateflow, obj(i)=Simulink
    instancePaths = {};
    for i=1:length(startSfIdx)
        count = endSfIdx(i) - startSfIdx(i) - 1;
        this_instance_path = {find_block_sf_anccestor(out{startSfIdx(i),2})};
        instancePaths = [instancePaths;this_instance_path(ones(count,1))];
    end
        
    init = {'C'};
    classInitial(isChart) = init(ones(sum(isChart),1));
    init = {'T'};
    classInitial(isTrans) = init(ones(sum(isTrans),1));
    init = {'S'};
    classInitial(isState) = init(ones(sum(isState),1));

    % Fix the end if needed
    if (isSl(end))
        classInitial{length(isSl)} = [];
    end

    % WISH, make sure the machines have parsed info here!!
	stateIds = handles(isState);
	[uniqueStateIds,map] = find_unique(stateIds);
    uniqueNmbrs = sf('get',uniqueStateIds,'.number');
    stateNmbrs = uniqueNmbrs(map);
    stateNmbrTxt = cellstr(num2str(stateNmbrs(:)));
    stateNmbrTxt = strrep(stateNmbrTxt,' ','');
    classInitial(isState) = strcat(classInitial(isState),stateNmbrTxt');
    
    
	transIds = handles(isTrans);
	[uniqueTransIds,map] = find_unique(transIds);
    uniqueNmbrs = sf('get',uniqueTransIds,'.number');
    transNmbrs = uniqueNmbrs(map);
    transNmbrTxt = cellstr(num2str(transNmbrs(:)));
    transNmbrTxt = strrep(transNmbrTxt,' ','');
    classInitial(isTrans) = strcat(classInitial(isTrans),transNmbrTxt');
	classInitial = classInitial';
    out(~isSl,3) = strcat(instancePaths,'/',classInitial(~isSl));
    
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                        STRING_UTILITY_FUNCTIONS                        %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function STRING_UTILITY_FUNCTIONS

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CR_TO_SPACE - Convert carraige returns to spaces

function out = cr_to_space(in),
	
    out = in;
    if ~isempty(in)
    	out(in==10) = char(32);
    	out=str_to_html(out);     % Fix for IceBrowser rendering problems!
    end

    

function out = str_to_html(in)

    out = strrep(in,'&','&amp;');
    out = strrep(out,'<','&lt;');
    out = strrep(out,'>','&gt;');
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                       ANALYSIS_METRICS_FUNCTIONS                       %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ANALYSIS_METRICS_FUNCTIONS
%    Each analysis metric will require three functions.  One function will
%    setup global data to be used during model traversals. Another function will 
%    produce data structures and fields for a system.  The other will produce
%    the data structures and fields for a block.
%    
%    *metric*_setup(cvstruct,data1,data2, ...)
%       
%        Analyze the coverage data from each test and setup a global variable to store
%        the data.  The global data will be accessed as each system and block are 
%        traversed and analyzed.
%
%    [cvstruct,*metric*,flags] = *metric*_system(cvstruct,sysEntry)
%
%        Produce a structured entry for the coverage metric relating to the system 
%        descrbed in sysEntry.  This function should refer to the global data created in the
%        setup function.  The flags return arguement should be a structure with the following
%        
%            flags.fullCoverage: A boolean to indicate if the system had full coverage
%            flags.noCoverage:   A boolean to indicate if the system had no (0) coverage 
%            flags.leafUncov:    A boolean to indicate if this should be linked as an uncovered
%
%        If a field is missing it is assumed to have a 0 value.
%        
%    [cvstruct,*metric*,flags] = *metric*_block(cvstruct,blockEntry)
%        
%        Produce a structured entry for the coverage metric relating to the system 
%        descrbed in sysEntry.  This function should refer to the global data created in the
%        setup function. The flags return arguement should be a structure with the following
%        
%            flags.fullCoverage: A boolean to indicate if the system had full coverage
%            flags.noCoverage:   A boolean to indicate if the system had no (0) coverage 
%            flags.leafUncov:    A boolean to indicate if this should be linked as an uncovered
%
%        If a field is missing it is assumed to have a 0 value.
%        
%
%    *metric*_details(outFile,dataEntry,cvstruct)
%        
%        Produce a detailed HTML description for the coverage in the block or system.
%
%    [sysEntry, blkEntry] = *metric*_summary_template()
%        
%        Produce template strings that are used to summarize the metric results for a single block
%        or system conforming to the standard set of columns:
%
%            METRIC  COVERAGE(TOTAL)     COVERAGE(THIS OBJ)      CONSTRUCTS        
%        


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DECISION_SUMMARY - Produce HTML table templates to
% be combined with templates for other metrics to 
% form master templates for block and sytem summary
% tables.

function [sysSummary, blkSummary] = decision_summary(testCnt)

    global  gCumulativeReport;

    if testCnt==1
        totalCol = 1;
    elseif gCumulativeReport
        totalCol = 3;
    else
        totalCol = testCnt+1;
    end

    blkSummary = { ...
                    '$Decision (D1)', ...
                    {'Cat', ...
                        {'&in_covperratios',{'#decision.outHitCnts',totalCol},'#decision.totalCnts'}, ...
                        '$ decision outcomes' ...
                    }, '\n'  ...
                 };
                 
    sysSummary = { ...
                    '$Decision (D1)', ...
                    {'If',{'&isempty','#decision.outlocalCnts'}, ...
                            '$NA', ...
                     'Else', ...
                            {'Cat', ...
                                {'&in_covperratios',{'#decision.outlocalCnts',totalCol},'#decision.totalLocalCnts'}, ...
                                '$ decision outcomes' ...
                            } ...
                    } ...
                    {'Cat',{'&in_covperratios',{'#decision.outTotalCnts',totalCol},'#decision.totalTotalCnts'},'$ decision outcomes'}, ...
                    '\n'  ...
                 };
                 
    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DECISION_DETAILS - Generate the detailed decision
% coverage information for a model node.

function  decision_details(outFile,blkEntry,cvstruct,addSpace)

    global gImageSubDirectory gElimFullCov gCumulativeReport;

    % If we have no arguments, clear the persistent variables
    if nargin==0,
        tableInfo = [];
        dTableTemplate = [];
        return;
    end
        
    if nargin < 4
        addSpace = 1;
    end

    totalCol = length(cvstruct.tests)+1;

	%Total col is last col
	if gCumulativeReport
		totalCol = totalCol - 1;
	end;

    if totalCol==2  % We never have just 2 cols!!
        totalCol = 1;
    end
    
    %
    % Formatting and layout for the table of decision details
    %

    tableInfo.table = 'BORDER="1" CELLPADDING="5" CELLSPACING="1" RULES=GROUPS';
    tableInfo.cols = struct('align','LEFT', 'width',380);
    tableInfo.cols(2) = struct('align','CENTER', 'width',60);
    tableInfo.imageDir = gImageSubDirectory;
    tableInfo.useRowGroups = 1;
    if( ~isempty(blkEntry.decision) & isfield(blkEntry.decision,'decisionIdx') & ...
		~isempty(blkEntry.decision.decisionIdx)	)
    	numDecisions = length(blkEntry.decision.decisionIdx);
    else
    	numDecisions = 0;
    end

    outEntry = {'ForEach','#outcome', ...
                {'If',{'RpnExpr',{'#execCount',totalCol},'!'} ,'&in_startred'}, ...
                {'Cat','$&nbsp; &nbsp; &nbsp; ','#text'}, ...
                {'&in_covratios','#execCount','#<totals'}, ...
                {'If',{'RpnExpr',{'#execCount',totalCol},'!'}  ,'&in_endred'}, ...
                '\n' ...
               };
               
    decEntry = { 'ForEach','#.', ...
                 {'Cat','$&nbsp; ','#text'}, {'&in_covpercent','#outCnts','#numOutcomes'},'\n', ...
                 outEntry, ...
                 {'If',{'RpnExpr','@1',numDecisions,'<'}, '&in_newrowgroup'} ...
               };
    
    dTableTemplate = {decEntry};

    % Print the decision table
    decData = [];
    if( ~isempty(blkEntry.decision) & isfield(blkEntry.decision,'decisionIdx') & ...
		~isempty(blkEntry.decision.decisionIdx)	)
		if isfield(blkEntry.decision,'outlocalCnts')
		    if (~gElimFullCov | blkEntry.decision.outlocalCnts(end)~=blkEntry.decision.totalLocalCnts)
                decData = cvstruct.decisions(blkEntry.decision.decisionIdx);
		    end
		else
		    if (~gElimFullCov | blkEntry.decision.outHitCnts(end)~=blkEntry.decision.totalCnts)
                decData = cvstruct.decisions(blkEntry.decision.decisionIdx);
		    end
		end
    end
    
    
    if ~isempty(decData)
        if (addSpace)
            fprintf(outFile,'\n<BR> ');
        end
        fprintf(outFile,'&nbsp; <B> Decisions analyzed:<BR>\n');
        tableStr = html_table(decData,dTableTemplate,tableInfo);
        fprintf(outFile,'%s',tableStr);
    end
    
% --------------------------- Condition Coverage --------------------------- %


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CONDITION_SUMMARY - Produce HTML table templates to
% be combined with templates for other metrics to 
% form master templates for block and sytem summary
% tables.

function [sysSummary, blkSummary] = condition_summary(testCnt)

    global  gCumulativeReport;

    if testCnt==1
        totalCol = 1;
    elseif gCumulativeReport
        totalCol = 3;
    else
        totalCol = testCnt+1;
    end

    blkSummary = { ...
                    '$Condition (C1)', ...
                    {'Cat', ...
                        {'&in_covperratios',{'#condition.localHits',totalCol},'#condition.localCnt'}, ...
                        '$ condition outcomes' ...
                    }, '\n'  ...
                 };
                 
    sysSummary = { ...
                    '$Condition (C1)', ...
                    {'If',{'&isempty','#condition.localHits'}, ...
                            '$NA', ...
                     'Else', ...
                            {'Cat', ...
                                {'&in_covperratios',{'#condition.localHits',totalCol},'#condition.localCnt'}, ...
                                '$ condition outcomes' ...
                            } ...
                    }, ...
                    {'Cat',{'&in_covperratios',{'#condition.totalHits',totalCol},'#condition.totalCnt'}, '$ condition outcomes'}, ...
                    '\n'  ...
                 };
                 
    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CONDITION_DETAILS - Generate the detailed condition
% coverage information for a model node.

function  condition_details(outFile,blkEntry,cvstruct)

    global gImageSubDirectory gElimFullCov gNoCCwithMCDC gCumulativeReport;

    persistent tableInfo cTableTemplate

    % If we have no arguments, clear the persistent variables
    if nargin==0,
        tableInfo = [];
        cTableTemplate = [];
        return;
    end
    
    if (gNoCCwithMCDC & isfield(blkEntry,'mcdc'))
        return;
    end
        
    testCnt = length(cvstruct.tests);
    if testCnt==1,
        coumnCnt = 1;
    else
        coumnCnt = testCnt+1;
    end
    	%Total col is last col
	if gCumulativeReport
		coumnCnt = coumnCnt - 1;
	end;

    
	if (gElimFullCov & isfield(blkEntry.condition,'conditionIdx') & ...
		~isempty(blkEntry.condition.conditionIdx) & ...
		(blkEntry.condition.localHits(end) == blkEntry.condition.localCnt))
		return;
	end
	
	  
    if isempty(tableInfo) | isempty(cTableTemplate)   
        
        %
        % Formatting and layout for the table of decision details
        %

        tableInfo.table = 'BORDER="1" CELLPADDING="5" CELLSPACING="1" ';
        tableInfo.cols = struct('align','LEFT', 'width',300);
        tableInfo.cols(2) = struct('align','CENTER', 'width',35);
        tableInfo.imageDir = gImageSubDirectory;

        execData = {'ForN',coumnCnt, ...
                    {'#trueCnts','@1'}, ...
                    {'#falseCnts','@1'}, ...
                   };
                   
        condEntry = { 'ForEach','#.', ...
                     {'If',{'RpnExpr','#covered','!'},'&in_startred'}, ...
                     {'Cat','$&nbsp; ','#text'},  ...
                     execData, ...
                     {'If',{'RpnExpr','#covered','!'},'&in_endred'}, ...
                      '\n' ...
                   };
        
        colHead = { '$<B>Description:</B>',{'ForN',coumnCnt-1,{'Cat','$<B>#','@1','$ T</B>'},{'Cat','$<B>#','@1','$ F</B>'}}};
        if testCnt>1
            colHead = [colHead {'$<B>Tot T</B>','$<B>Tot F</B>','\n'}];
        else
             colHead = [colHead {'$<B>True</B>','$<B>False</B>','\n'}];
           
        end
        
        cTableTemplate = [colHead {condEntry}]; 
    end

    % Print the condition table
    if( ~isempty(blkEntry.condition) & isfield(blkEntry.condition,'conditionIdx') & ...
		~isempty(blkEntry.condition.conditionIdx))
        condData = cvstruct.conditions(blkEntry.condition.conditionIdx);
    else
        condData = [];
    end
    
    if ~isempty(condData)
        fprintf(outFile,'\n<BR> &nbsp; <B> Conditions analyzed: </B> <BR>\n');
        tableStr = html_table(condData,cTableTemplate,tableInfo);
        fprintf(outFile,'%s',tableStr);
    end
    
% --------------------------- MCDC Coverage --------------------------- %


    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MCDC_SUMMARY - Produce HTML table templates to
% be combined with templates for other metrics to 
% form master templates for block and sytem summary
% tables.

function [sysSummary, blkSummary] = mcdc_summary(testCnt)

    global  gCumulativeReport;

    if testCnt==1
        totalCol = 1;
    elseif gCumulativeReport
        totalCol = 3;
    else
        totalCol = testCnt+1;
    end

    blkSummary = { ...
                    '$MCDC (C1)', ...
                    {'Cat', ...
                        {'&in_covperratios',{'#mcdc.localHits',totalCol},'#mcdc.localCnt'}, ...
                        '$ conditions reversed the outcome' ...
                    }, '\n'  ...
                 };
                 
    sysSummary = { ...
                    '$MCDC (C1)', ...
                    {'If',{'&isempty','#mcdc.localHits'}, ...
                            '$NA', ...
                     'Else', ...
                            {'Cat', ...
                                {'&in_covperratios',{'#mcdc.localHits',totalCol},'#mcdc.localCnt'}, ...
                                '$ conditions reversed the outcome' ...
                            } ...
                    }, ...
                    {'Cat', {'&in_covperratios',{'#mcdc.totalHits',totalCol},'#mcdc.totalCnt'}, '$ conditions reversed the outcome'}, ...
                    '\n'  ...
                 };
                 
    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MCDC_DETAILS - Generate the detailed MCDC
% coverage information for a model node.

function  mcdc_details(outFile,blkEntry,cvstruct)

    global gImageSubDirectory gElimFullCov gCumulativeReport;

    persistent tableInfo mcdcTableTemplate

    % If we have no arguments, clear the persistent variables
    if nargin==0,
        tableInfo = [];
        mcdcTableTemplate = [];
        return;
    end
        
    testCnt = length(cvstruct.tests);
    if testCnt==1,
        coumnCnt = 1;
    else
        coumnCnt = testCnt+1;
    end
    
	%Total col is last col
	if gCumulativeReport
		coumnCnt = testCnt;
	end;

    % Return early if all decisions are covered and we are not reporting full coverage
  	if (gElimFullCov & isfield(blkEntry.mcdc,'decisionIdx') & ...
  		~isempty(blkEntry.mcdc.mcdcIndex) & ...
  		blkEntry.mcdc.localHits(end) == blkEntry.mcdc.localCnt)
  		return;
  	else
  		if isfield(blkEntry.mcdc,'decisionIdx')
  			numDecisions = length(blkEntry.mcdc.mcdcIndex);
  		else
  			numDecisions = 0;
  		end
  	end
  	
  
        
    %
    % Formatting and layout for the table of decision details
    %

	tableInfo.table = 'BORDER="1" CELLPADDING="5" CELLSPACING="1" RULES=GROUPS';
    tableInfo.cols = struct('align','LEFT', 'width',250);
    tableInfo.cols(2) = struct('align','CENTER', 'width',70);
    tableInfo.imageDir = gImageSubDirectory;

    if testCnt>1
        execData = {{'ForN',coumnCnt, ...
                     {'#trueCombo','@1'}, ...
                     {'#falseCombo','@1'} ...
                    } ...
                   };
    else
        execData = {{'#trueCombo',1},{'#falseCombo',1}};
    end
    
               
    condEntry = { 'ForEach','#predicate', ...
                 {'If',{'RpnExpr',{'#acheived',coumnCnt},'!'},'&in_startred'}, ...
                 {'Cat','$&nbsp; &nbsp; &nbsp; ','#text'},  ...
                 execData{:}, ...
                 {'If',{'RpnExpr',{'#acheived',coumnCnt},'!'},'&in_endred'}, ...
                  '\n' ...
               };
    
    mcdcEntry = { 'ForEach','#.', ...
                  '#text', ...
                  {'CellFormat','$ ',2*testCnt+(testCnt~=coumnCnt)}, ...
                  '\n', ...
                  condEntry, ...
             	  {'If',{'RpnExpr','@1',numDecisions,'<'}, '&in_newrowgroup'} ...
                };
                  
    colHead = { '$<B>Decision/Condition:</B>',{'ForN',coumnCnt-1,{'Cat','$<B>#','@1','$ True Out</B>'},{'Cat','$<B>#','@1','$ False Out</B>'}}};
    if testCnt>1
        colHead = [colHead {'$<B>Total Out T</B>','$<B>Total Out F</B>','\n'}];
    else
         colHead = [colHead {'$<B>True Out</B>','$<B>False Out</B>','&in_newrowgroup'}];
    end
    
    mcdcTableTemplate = [colHead {mcdcEntry}]; 

    % Print the mcdc table
    if( ~isempty(blkEntry.mcdc) & isfield(blkEntry.mcdc,'mcdcIndex') & ...
		~isempty(blkEntry.mcdc.mcdcIndex))
        mcdcData = cvstruct.mcdcentries(blkEntry.mcdc.mcdcIndex);
    else
        mcdcData = [];
    end
    
    if ~isempty(mcdcData)
        fprintf(outFile,'\n<BR> &nbsp; <B> MC/DC analysis (combinations in parentheses did not occur) </B> <BR>\n');
        tableStr = html_table(mcdcData,mcdcTableTemplate,tableInfo);
        fprintf(outFile,'%s',tableStr);
        fprintf(outFile,'<BR>\n\n'); % Vertical space
    end
    
% --------------------------- Look-up Table Coverage --------------------------- %


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TABLEEXEC_SUMMARY_TEMPLATE - Produce HTML table templates to
% be combined with templates for other metrics to 
% form master templates for block and sytem summary
% tables.
%

function [sysSummary, blkSummary] = tableExec_summary(testCnt)

    global  gCumulativeReport;

    if testCnt==1
        totalCol = 1;
    elseif gCumulativeReport
        totalCol = 3;
    else
        totalCol = testCnt+1;
    end

    blkSummary = { ...
                    '$Look-up Table', ...
                    {'Cat', ...
                        {'&in_covperratios',{'#tableExec.localHits',totalCol},'#tableExec.localCnt'}, ...
                        '$ interpolation intervals' ...
                    }, '\n'  ...
                 };
                 
    sysSummary = { ...
                    '$Look-up Table', ...
                    {'If',{'&isempty','#tableExec.localHits'}, ...
                            '$NA', ...
                     'Else', ...
                            {'Cat', ...
                                {'&in_covperratios',{'#tableExec.localHits',totalCol},'#tableExec.localCnt'}, ...
                                '$ interpolation intervals' ...
                            } ...
                    }, ...
                    {'Cat',{'&in_covperratios',{'#tableExec.totalHits',totalCol},'#tableExec.totalCnt'}, '$ interpolation intervals'}, ...
                    '\n'  ...
                 };
                 
    


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TABLEEXEC_DETAILS - Generate the detailed look-up table
% coverage information for a model node.
%

function  tableExec_details(outFile,blkEntry,cvstruct)

    global gImageSubDirectory gtableDataCache gCumulativeReport;

    persistent tableInfo cTableTemplate

    testCnt = length(cvstruct.tests);
    if testCnt==1,
        coumnCnt = 1;
    else
        coumnCnt = testCnt+1;
    end
    
	%Total col is last col
	if gCumulativeReport
		coumnCnt = testCnt;
	end;
    
    % Print the decision table
    tableData = [];
    if( ~isempty(blkEntry.tableExec) & isfield(blkEntry.tableExec,'tableIdx') & ...
		~isempty(blkEntry.tableExec.tableIdx))
    	if ( blkEntry.tableExec.localHits(end) ~= blkEntry.tableExec.localCnt)
        	tableData = cvstruct.tables(blkEntry.tableExec.tableIdx);
        end
    end
    
    if ~isempty(tableData) 
    
        if prod(size(tableData.testData(end).execCnt))>400
            if isempty(gtableDataCache)
                tableIdx = 1;
            else
                [rows,cols] = size(gtableDataCache);
                tableIdx = rows+1;
            end
            fprintf(outFile,'\n<BR> Table map was not generated due to the table size.\n');
            fprintf(outFile,'\n<BR> <A HREF="matlab:cvhtml @table_link %d"> Force Map Generation.</A>\n',tableIdx);
            if (tableIdx>1)
                gtableDataCache(tableIdx,:) = { '', blkEntry.cvId, tableData.testData(end).execCnt, ...
                                            tableData.breakPtValues, ...
                                            tableData.testData(end).breakPtEquality, ...
                                            blkEntry.cvId};
            else
                gtableDataCache = { '', blkEntry.cvId, tableData.testData(end).execCnt, ...
                                            tableData.breakPtValues, ...
                                            tableData.testData(end).breakPtEquality, ...
                                            blkEntry.cvId};
            end

        else
            fprintf(outFile,'\n<BR> &nbsp; <B> Look-up Table Details </B> <BR>\n');
            fprintf(outFile,'<table cellpadding=8 border=0> <tr> <td>\n');
    
            % Table map showing execution counts for each interval
            [fileNames, cntThresh] = prepare_table_mapping_output(tableData.testData(end).execCnt);
    
            outStr = table_map( blkEntry.cvId, ...
                                tableData.testData(end).execCnt, ...
                                tableData.breakPtValues, ...
                                tableData.testData(end).breakPtEquality, ...
                                gImageSubDirectory, ...
                                fileNames, ...
                                cntThresh);

            fprintf(outFile,'%s',outStr);
            
            fprintf(outFile,'\n</td><td>\n');
            
            % Table legend explaining the signifigance of each color
            make_table_map_legend(outFile,[],[]);
    
            fprintf(outFile,'\n</td></tr> </table>\n');
         
        end
    end
    

% --------------------------- Signal Range Coverage --------------------------- %

function  sigrange_details(outFile,blkEntry,cvstruct)
    % Do nothing
    return;

function cvstruct = sigrange_info(cvstruct,sigranges)
    % Do nothing
    return;


    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PREPARE_TABLE_MAPPING_OUTPUT - Determine a mapping 
% from execution counts to an image file and place
% this info so that it will be used when making the map.

function [fileNames, cntThresh] = prepare_table_mapping_output(execCounts);

    global gImageSubDirectory;

    fileNames = {'trans.gif','grn01.gif','grn03.gif','grn05.gif',  ...
                 'grn07.gif','grn09.gif'};
    
    fileNames = strcat([gImageSubDirectory '/'],fileNames);
    cntThresh = determine_thresholds(execCounts,length(fileNames));
    
    
    cnt_to_filename(cntThresh,fileNames);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DETERMINE_THRESHOLDS - Select intervals for the set
% of samples so that they can be mapped to a finite 
% coloring
%

function thresh = determine_thresholds(samples,buckets)

    maxSample = max(max(samples));
    interval = maxSample/buckets;

    % Round the interval value so it is a mult of 1,2 or 5
    if interval > 2
        interval = nearest_125(interval);
    else
        interval = 1;
    end

    thresh = interval*(0:(buckets-2));




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% NEAREST_125 - Round a number to the nearest 1,2,5 * 10^n 
% 
function out = nearest_125(x)

    decade = ceil(log10(x));
    m = x/(10^decade);

    if m < 0.2
        m = 0.2;
    elseif m < 0.5
        m = 0.5;
    else
        m = 1;
    end

    out = m*(10^decade);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MAKE_TABLE_MAP_LEGEND - Create a legend to explain the 
% colors portrayed in the table coverage map.
% 
function make_table_map_legend(outFile,rows,cols)

    [brkValues,fileNames] = cnt_to_filename;

    fprintf(outFile,'<table cellpadding=2 border=0>\n<tr>');

    label = '0';
    file = fileNames{1};
    fprintf(outFile,'<td width=16 align="left"> <IMG src="%s" width=12 height=12 border=1> </td> <td> %s </td>',file,label);

    fprintf(outFile,'</tr> \n <tr>'); % WISH this must depend on row and col values    
    for i=2:length(brkValues)    
        label = [num2str(brkValues(i-1)+1) ' - ' num2str(brkValues(i))];
        file = fileNames{i};
        fprintf(outFile,'<td width=16 align="left"> <IMG src="%s" width=12 height=12 border=1> </td> <td> %s </td>',file,label);
        fprintf(outFile,'</tr> \n <tr>'); % WISH this must depend on row and col values    

    end
    
    label = ['> ' num2str(brkValues(end))];
    file = fileNames{end};
    fprintf(outFile,'<td width=16 align="left"> <IMG src="%s" width=12 height=12 border=1> </td> <td> %s </td>',file,label);
    
    
    fprintf(outFile,'</tr> </table>');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SET_GLOBAL_OPTIONS - Update the values of global 
% format variables based on a parameter string.

function set_global_options(optionsTable,optionStr);

    % Global vars for report settings (copy changes to set_global_options)
    global gAllTestInMdlSumm gBarGrInMdlSumm gHitCntInMdlSumm gCombineCndTF gElimFullCov;

    [rowCnt,colCnt] = size(optionsTable);

    for i=1:rowCnt
		if ~strcmp(optionsTable{i,1},'>----------')
            charIdx = findstr(optionStr,optionsTable{i,3});
            
            if isempty(charIdx) 
                assignin('caller',optionsTable{i,2},optionsTable{i,4});
            else
                endIdx = [find(optionStr=='-')  length(optionStr)];          
                endIdx(endIdx<charIdx(1)) = [];
            
                val = sscanf( optionStr( (charIdx(1)+3):(endIdx(1)) ), '=%d' );
                assignin('caller',optionsTable{i,2},val);
            end
        end
    end
    


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CONVERT_NON_EVALED_TO_NAN
% look for i,j such that in(i,j)=inf, in(i=1,j)=-inf, i is odd
% and replace in(i,j), in(i=1,j) with NaN.
%
function out = convert_non_evaled_to_nan(in)
    in_single = in(:);
    oddIdx = 1:2:length(in_single);
    evenIdx = oddIdx + 1;
    nanIdx = find(in_single(oddIdx)==inf & in_single(evenIdx)==-inf);
    nanIdx = [nanIdx*2 (2*nanIdx-1)];
    in_single(nanIdx) = NaN;
    out = reshape(in_single,[size(in)]);


function dump_model_signal_range(outFile, cvId, waitbarH)

    global gsigrange;
	allmetrics = cv_metric_names;
    
    if iscell(gsigrange)
        rawData = gsigrange{end};
    else
%        rawData = gsigrange(:,end);
        rawData = gsigrange;
    end

    rawData = convert_non_evaled_to_nan(rawData);
	testCnt = size(gsigrange,2);
    
    srIsa = cv('get','default','sigranger.isa');

    % Order the set of coverage IDs
    [allIds,depths] = cv('DfsOrder',cvId,'require',allmetrics.MTRC_SIGRANGE);
    origins = cv('get', allIds, 'slsfobj.origin');
    
    % Find the ID for the block diagram, otherwise set it to -1
    bdH = cv('get',cvId,'.handle');
    if (bdH == bdroot(bdH))
        bdId = cvId;
    else
        bdId = -1;
    end
    
    idLength = length(allIds);
    
    dataStruct = struct('name',{},'depth',{},'data',{},'portSizes',{},'startIdx',{});
    
    if (~isempty(waitbarH) && idLength>10)
        waitbar(0,waitbarH,'Reporting signal ranges');
    else 
        waitbarH = [];
    end
    
    for idx = 1:idLength
        if (allIds(idx) == bdId)
            name = cv('get',bdId,'.name');
        else
            name = obj_diag_named_link(allIds(idx));
        end
        [srId,isaVal] = cv('MetricGet',allIds(idx),allmetrics.MTRC_SIGRANGE,'.id','.isa');
        
        
        if isaVal==srIsa
            [portSizes,baseIdx] = cv('get',srId,'.cov.allWidths','.cov.baseIdx');
            startIdx = [1 cumsum(2*portSizes)+1];
            
            
            if (origins(idx)==2)  
            	% This is a stateflow object (should be a chart)
            	sfChartId = cv('get',allIds(idx),'.handle');
            	[dnames,dwidths,dnumbers] = cv_sf_chart_data(sfChartId);
	            [notUsed,sortI] = sort(dnumbers);
            	varCnt = length(dnames);
            	dnumbers = 0:(varCnt-1);
            	dnames = dnames(sortI);
            	dwidths = dwidths(sortI);
            	
		        % When we find a stateflow chart we need to create entries for each 
		        % of the data  objects within the chart
		        for varIdx = 1:varCnt
	                objData = rawData(baseIdx + startIdx(dnumbers(varIdx)+1) + (0:(2*dwidths(varIdx)-1)),:);
		            dataStruct(end+1) = struct( 'name',         dnames(varIdx), ...
		                                        'depth',        depths(idx)+1, ...
		                                        'data',         objData, ...
		                                        'portSizes',    dwidths(varIdx), ...
		                                        'startIdx',     1);
		        end
            else
	            if isempty(portSizes)
	                objData = [];
	            else
	                objData = rawData(baseIdx + (1:(2*sum(portSizes))),:);
	            end
	            
	            dataStruct(end+1) = struct( 'name',         name, ...
	                                        'depth',        depths(idx), ...
	                                        'data',         objData, ...
	                                        'portSizes',    portSizes, ...
	                                        'startIdx',     startIdx);
			end
        else
            dataStruct(end+1) = struct( 'name',     name, ...
                                        'depth',depths(idx), ...
                                        'data',[], ...
                                        'portSizes',[], ...
                                        'startIdx',[]);
        end

        if (~isempty(waitbarH)) 
            waitbar(0.5*idx/idLength,waitbarH);
        end 
    end

    if testCnt == 1
        entryTemplate = ...
        { {'Cat',{'&in_tabstr','#name','#depth'}, '$ &nbsp; '}, ...
            {'If',{'RpnExpr',{'&isempty','#data'},'!'}, ...
                {'If',{'RpnExpr',{'&length','#data'},3,'<'}, ...
                    {'#data',1}, ...
                    {'#data',2}, ...
                    '\n', ...
                'Else', ...
                    '\n', ...
                    {'ForN',{'&length','#portSizes'}, ...
                        {'ForN',{'#portSizes','@1'}, ...
                            {'&in_tabstr',{'Cat','$out','@2','$[','@1','$]'},{'RpnExpr','#depth',1,'+'}}, ...
                            {'#data',{'RpnExpr',{'#startIdx','@2'},'@1',1,'-',2,'*','+'}}, ...
                            {'#data',{'RpnExpr',{'#startIdx','@2'},'@1',1,'-',2,'*','+',1,'+'}}, ...
                            '\n', ...
                        } ...
                    } ...
                } ...
            'Else', ...
                '\n', ...
            } ...
        };
    else
        entryTemplate = ...
        { {'Cat',{'&in_tabstr','#name','#depth'}, '$ &nbsp; '}, ...
            {'If',{'RpnExpr',{'&isempty','#data'},'!'}, ...
                {'If',{'RpnExpr',{'&size','#data',1},3,'<'}, ...
                    {'ForN',testCnt, ...
                        {'#data',1,'@1'}, ...
                        {'#data',2,'@1'} ...
                    }, ...
                    '\n', ...
                'Else', ...
                    '\n', ...
                    {'ForN',{'&length','#portSizes'}, ...
                        {'ForN',{'#portSizes','@1'}, ...
                            {'&in_tabstr',{'Cat','$out','@2','$[','@1','$]'},{'RpnExpr','#depth',1,'+'}}, ...
                            {'ForN',testCnt, ...
                                {'#data',{'RpnExpr',{'#startIdx','@3'},'@2',1,'-',2,'*','+'},'@1'}, ...
                                {'#data',{'RpnExpr',{'#startIdx','@3'},'@2',1,'-',2,'*','+',1,'+'},'@1'} ...
                            }, ...
                            '\n', ...
                        } ...
                    } ...
                } ...
            'Else', ...
                '\n', ...
            } ...
        };
    end
    
    if testCnt == 1
        titleRows = {'$<B>Hierarchy</B>','$<B>Min value</B>','$<B>Max value</B>','\n'};
    else
        titleRows = {   '$<B>Hierarchy</B>', ...
                        {'ForN', testCnt-1,  ...
                            {'CellFormat', ...
                                {'Cat','$<B>Test ','@1', '$</B>'}, ...
                                2 ...
                            } ...
                         }, ...
                         {'CellFormat', '$<B>Overall</B>',2}, ...
                     '\n', ...
                     '$ ', {'ForN', testCnt, '$<B>Min</B>', '$<B>Max</B>'}, '\n'};
    end
    
    
    template =  {titleRows{:}, ...
                 {'ForEach','#.',entryTemplate{:}}};
            
    systableInfo.cols(1).align = 'LEFT';
    systableInfo.cols(2).align = 'CENTER';
    systableInfo.table = '  CELLPADDING="2" CELLSPACING="1"';
    systableInfo.textSize = 2;

    tableStr = html_table(dataStruct,template,systableInfo);
    if ~isempty(waitbarH) 
        waitbar(1,waitbarH);
    end 

    fprintf(outFile,'<A NAME=signal_ranges></A><H2>Signal Ranges:</H2>\n'); 
    fprintf(outFile,'%s',tableStr);


function fileName = file_url_2_path(url)    
    fileName = strrep(url,'localhost/','');             
    fileName = strrep(fileName,'file:/','');                  
    fileName = strrep(fileName,'///','/');                    
    fileName = strrep(fileName,'//','');                    
    fileName = strtok(fileName,'#');

    

    
