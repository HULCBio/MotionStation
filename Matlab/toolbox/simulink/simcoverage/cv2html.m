function cv2html(fileName,varargin)
% cv2html.m   New design of html reporting capabilities
%
%

%   Copyright 1990-2003 The MathWorks, Inc.
%   $Revision: 1.3.2.2 $  $Date: 2004/04/15 00:36:54 $

    global gcondition gdecision grelation gmcdc gsigRange gtableExec;

    %%%%%%%%%%%%%%%%%%%%%
    % Check arguments
    if ~ischar(fileName)
        error('File name should be a string');
    end
    
    if nargin < 2,
        error('At least one cvdata argument is needed');
    end
    
    detail = 2;
    
    if nargin > 2
        switch(class(varargin{end})),
        case 'double'
            detail = varargin{end};
            lastTest = nargin-1;
            if length(detail)>1 | detail <0 | detail > 3
                error('Detail level should be specified as a scalar between 0 and 3.');
            end
        case 'cvdata'
            lastTest = nargin;
        otherwise,
            error('Unknown class for last input argument');
        end
    else
        lastTest = nargin;
    end
            
    for i=2:lastTest
        if ~isa(varargin{i-1},'cvdata'),
            error(sprintf('Argument %d should be a cvdata object',i));
        end
        allTests{i-1} = varargin{i-1};
    end
    
    
    %%%%%%%%%%%%%%%%%%%%%
    % Make sure all cvdata 
    % args are compatible
    rootId = varargin{1}.rootId;
    for i=3:lastTest
        if rootId~=varargin{i-1}.rootId,
            error(sprintf('Argument %d is incompatible with the preceding cvdata arguments',i));
        end
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
        allTests{i+1} = total;
    end


    %%%%%%%%%%%%%%%%%%%%%
    % Determine which metrics 
    % to include and process 
    % data
    metricNames = {};
    if length(allTests)==1,
        masterData = allTests{1};
    else
        masterData = total;
    end
        
    names = fieldnames(masterData.metrics);
    for i=1:length(names)
        if ~isempty(getfield(masterData.metrics,names{i}))
            metricNames = [metricNames names(i)];
            feval([names{i} '_setup'],allTests{:});
        end
    end
    
    %%%%%%%%%%%%%%%%%%%%%
    % Check that the model
    % is open and the handles
    % are up to date.
    modelcovId = cv('get',rootId,'.modelcov');
    [modelH,modelName] = cv('get',modelcovId,'.handle','.name');
    if ~ishandle(modelH)    
        prevError = lasterr;
        try
            h = get_param(modelName,'Handle');
        catch
            lasterr(prevError);
            h = 0;
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
    
    %%%%%%%%%%%%%%%%%%%%%
    % Build the coverage data
    % structure.
    modelcovId = cv('get',rootId,'.modelcov');
    [modelH,modelName] = cv('get',modelcovId,'.handle','.name');

    cvstruct.root.cvId = rootId;
    cvstruct.tests = testIds;
    cvstruct.model.name = modelName;
    topCvId = cv('get',rootId,'.topSlsf');
    cvstruct = traverse_systems(cvstruct, topCvId, 0, 1, metricNames);
    
    %%%%%%%%%%%%%%%%%%%%%
    % Open the output file
    %
    [path,name,ext,ver] = fileparts(fileName);
    if (isempty(path))
        path = pwd;
    end
    fileName = fullfile(path,[name '.html']);
    outFile = fopen(fileName,'w');
    if (outFile==-1)
        error('Could not create the output file');
    end


    dump_html(outFile, cvstruct,metricNames);
    fclose(outFile);
    
    if usejava('mwt')
        % Java support means we can use the MATLAB web browser to display
        % the output.
        web(fileName);
    else
        disp(['Unable to open coverage report in the MATLAB Web Browser. ' ...
         'Hyper-links to Simulink models will only work in the MATLAB ' ...
         'Web Browser.']);
    end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                        DATA_SYNTHESIS_FUNCTIONS                        %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%    The data will be organized into one large structure
%    
%    cvstruct.root               - Top level info
%    cvstruct.systems            - Hierarchy and structural info
%    cvstruct.blocks             - Specific sl and sf constructs
%    cvstruct.*metricObjs*       - Documentation for a coverage metric construct
%    cvstruct.*metricObjs*
    

function cvstruct = traverse_systems(cvstruct, cvId, depth, sysNum, metricNames)    

    children = cv('ChildrenOf',cvId);
    children = children(children~=cvId);
    isLeaf = (cv('get',children,'.treeNode.child') == 0);
    
    subSystemIds = children(~isLeaf);
    blockIds = children(isLeaf);
    
    noData = 1;
 
    %%%%%%%%%%%%%%%%%%%%%
    % Produce the standard 
    % system fields
    sysEntry.cvId = cvId;
    sysEntry.name = cv('get',cvId,'.name');
    sysEntry.sysNum = sysNum;
    sysEntry.depth = depth;
    sysEntry.subsystemIdx = zeros(1,length(subSystemIds));
    sysEntry.blockIdx = [];


    %%%%%%%%%%%%%%%%%%%%%
    % Analyze metrics for
    % this system
    for i=1:length(metricNames)
        thisMetric =  metricNames{i};
        [cvstruct,data] = feval([thisMetric '_system'],cvstruct,sysEntry);
        sysEntry = setfield(sysEntry,thisMetric,data);
        if ~isempty(data) & noData
            noData = 0;
        end
    end
    
    %%%%%%%%%%%%%%%%%%%%%
    % Return early if there
    % is no coverage information
    % in this system.
    if noData
        return;
    end
    
    %%%%%%%%%%%%%%%%%%%%%
    % Traverse to leaf nodes
    for i = 1:length(blockIds)
        [cvstruct,blockIdx] = new_block(cvstruct, blockIds(i), sysNum, metricNames);
        if blockIdx>0
            sysEntry.blockIdx = [sysEntry.blockIdx blockIdx];
        end
    end
    
    if sysNum==1,
        cvstruct.system = sysEntry;
    end
    
    %%%%%%%%%%%%%%%%%%%%%
    % Traverse to subsystems
    nextSysNum = sysNum+1;
    for i = 1:length(subSystemIds),
        cvstruct = traverse_systems(cvstruct, subSystemIds(i), depth+1, nextSysNum, metricNames);    
        sysEntry.subsystemIdx(i) = nextSysNum;
        nextSysNum = length(cvstruct.system)+1;
    end
    
    cvstruct.system(sysNum) = sysEntry;
   

function  [cvstruct,blockIdx] = new_block(cvstruct, cvId, sysNum, metricNames)
    
    if ~isfield(cvstruct,'blocks')
        blockIdx = 1;
    else
        blockIdx = length(cvstruct.blocks) + 1;
    end
    
    noData = 1;

    blockEntry.cvId = cvId;
    blockEntry.sysIdx = sysNum;
    blockEntry.name = cv('get',cvId,'.name');
    blockEntry.index = blockIdx;

    %%%%%%%%%%%%%%%%%%%%%
    % Analyze metrics for
    % this block
    for i=1:length(metricNames)
        thisMetric =  metricNames{i};
        [cvstruct,data] = feval([thisMetric '_block'],cvstruct,blockEntry);
        blockEntry = setfield(blockEntry,thisMetric,data);
        if ~isempty(data) & noData
            noData = 0;
        end
    end

    %%%%%%%%%%%%%%%%%%%%%
    % Return early if there
    % is no coverage information
    % in this block.
    if noData,
        blockIdx = -1;
        return;
    end
    
    
    if blockIdx==1,
        cvstruct.blocks = blockEntry;
    else
        cvstruct.blocks(blockIdx) = blockEntry;
    end
    
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                         HTML_OUTPUT_GENERATION                         %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function dump_html(outFile, cvstruct, metricNames)

    fprintf(outFile,'<HTML>\n');
    fprintf(outFile,'<HEAD>\n'); 
    fprintf(outFile,'<TITLE> %s Coverage Report </TITLE>\n',cvstruct.model.name); 
    fprintf(outFile,'</HEAD>\n'); 
    fprintf(outFile,'\n'); 
    fprintf(outFile,'<BODY>\n'); 
    fprintf(outFile,'<H1>Coverage Report for %s</H1>\n',cvstruct.model.name); 
    fprintf(outFile,'<H2>Summary</H2>\n'); 

    % System table template
    testCnt = length(cvstruct.tests);
    if testCnt>1
        columnCnt = testCnt+1;
    else
        columnCnt = 1;
    end
    
      
    totalIdx = testCnt+1;

    % Arrange the columns based on the coverage metrics
    metricCount = 0;
    if any(strcmp(metricNames,'decision'))
        metricCount = 1;
        metricTitles = {'$<B>D1</B>'};
        metricData = {{'?',{'&isempty','#decision'}, ...
                        '$N/A', ...
                        {{'&in_covperratios','#decision.outTotalCnts','#decision.totalTotalCnts','@1'}}, ...
                     }};
    end

    if any(strcmp(metricNames,'condition'))
        metricCount = metricCount+1;
        metricTitles = [metricTitles {'$<B>C1</B>'}];
        metricData = [metricData ...
                     {{'?',{'&isempty','#condition'}, ...
                        '$N/A', ...
                        {{'&in_covperratios','#condition.totalHits','#condition.totalCnt','@1'}}, ...
                     }}];
    end

    columnData = [{'ForN',columnCnt} metricData {'$&nbsp'}];
   
    rowEntries = {'ForEach','#system', ...
                    {'C', ...
                        {'&in_tocentry',{'&in_href','#name','#cvId'},{'=','@1',1,'$+'},'#depth'}, ...
                        1, ...
                        '$left' ...
                    }, ...    
                    columnData, ...
                    '\n' ...
                 };
    
    sysTableTemplate = {'$<B>Model Hierarchy:</B>', ...
                        {'ForN',testCnt, ...
                            {'C', ...
                                {'[','$<B>Test ',{'=','@1',1,'$+'},'$</B>'}, ...
                                metricCount ...
                            }, ...
                            '$&nbsp' ...
                        }, ...
                        {'?',{'=',testCnt,1,'$>'}, ...
                            {{'C', ...
                                '$<B>Total</B>', ...
                                metricCount ...
                            }} ...
                        }, ...
                        '\n', ...
                        '$ ', ...
                        {'ForN',columnCnt, metricTitles{:}, '$&nbsp'}, ...
                        '\n', ...
                        rowEntries ...
                       };
 
    systableInfo.formatStr.rows{1} = ' ALIGN="CENTER" ';
    systableInfo.formatStr.table = '  CELLPADDING="2" CELLSPACING="1"';
   
    
    tableStr = sf('Private','html_table',cvstruct,sysTableTemplate,systableInfo);
    fprintf(outFile,'%s',tableStr);
    fprintf(outFile,'<H2>Details:</H2>\n'); 
      


    sysSummary.mainTemplate = {'$<B>Metric</B>',   '$<B>Coverage (this object)</B>',     '$<B>Coverage (inc. decendents)</B>',  '\n'};

    blkSummary.mainTemplate = {'$<B>Metric</B>',   '$<B>Coverage</B>', '\n'};

    for i=1:length(metricNames)
        thisMetric =  metricNames{i};
        [sysTemp,blkTemp] = feval([thisMetric '_summary'],testCnt);
        sysSummary = setfield(sysSummary,thisMetric,sysTemp);
        blkSummary = setfield(blkSummary,thisMetric,blkTemp);
    end
    
   
    % Loop through each system and itemize coverage
    for i=1:length(cvstruct.system);
        sysEntry = cvstruct.system(i);
        
        fprintf(outFile,'%s<h3>%d. %s</h3>\n', ...
                    obj_anchor(sysEntry.cvId,''), ...
                    sysEntry.sysNum, ...
                    object_titleStr_and_link(sysEntry.cvId));
        
        produce_summary_table(outFile,sysEntry,sysSummary,metricNames);

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Put links to child systems
        %
        if ~isempty(sysEntry.subsystemIdx),
            str = 'Child Systems: ';
            for childIdx = sysEntry.subsystemIdx,
                str = [str  '&nbsp; ' obj_named_link(cvstruct.system(childIdx).cvId) ', '];
            end
            fprintf(outFile,'%s<BR>\n\n',str(1:(end-2)));
        end
       
        
        decision_details(outFile,sysEntry,cvstruct);
        condition_details(outFile,sysEntry,cvstruct);

        for blockI = sysEntry.blockIdx(:)'
            blkEntry = cvstruct.blocks(blockI);
            fprintf(outFile,'%s<h4>%s</h3>\n', ...
                    obj_anchor(blkEntry.cvId,''), ...
                    object_titleStr_and_link(blkEntry.cvId));
            
            produce_summary_table(outFile,blkEntry,blkSummary,metricNames);
            
            % WISH Abstract this so it works for all metrics:
            decision_details(outFile,blkEntry,cvstruct);
            condition_details(outFile,blkEntry,cvstruct);
        end
    end

    fprintf(outFile,'</BODY>\n');
    fprintf(outFile,'</HTML>\n'); 
    fprintf(outFile,'\n');      




    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                         HTML_UTILITY_FUNCTIONS                         %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function produce_summary_table(outFile,dataEntry,summaryTemplates,metricNames);

    template = summaryTemplates.mainTemplate;
    
    for i=1:length(metricNames)
        thisMetric =  metricNames{i};
        if ~isempty(getfield(dataEntry,thisMetric))
            template = [template getfield(summaryTemplates,thisMetric)];
        end
    end
    
    tableInfo.formatStr.cols{1} = 'ALIGN="LEFT" WIDTH=200';

    tableStr = sf('Private','html_table',dataEntry,template,tableInfo);
    fprintf(outFile,'%s',tableStr);
    

function titleStr = object_titleStr_and_link(id)

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
        titleStr = sprintf('%s "%s"',get_sf_class(type,id),obj_diag_named_link(id));
    else
        error('Origin not set properly');
    end




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                       ANALYSIS_METRICS_FUNCTIONS                       %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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
%    [cvstruct,*metric*] = *metric*_system(cvstruct,sysEntry)
%
%        Produce a structured entry for the coverage metric relating to the system 
%        descrbed in sysEntry.  This function should refer to the global data created in the
%        setup function.
%        
%    [cvstruct,*metric*] = *metric*_block(cvstruct,blockEntry)
%        
%        Produce a structured entry for the coverage metric relating to the system 
%        descrbed in sysEntry.  This function should refer to the global data created in the
%        setup function.
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


function decision_setup(varargin)

    global gdecision;
    
    gdecision = varargin{1}.metrics.decision;
    
    for i=2:length(varargin)
        gdecision = [gdecision varargin{i}.metrics.decision];
    end
    
    
function [cvstruct,decData] = decision_block(cvstruct,blockInfo)

    global gdecision gFrmt;

    gFrmt.txtDetail = 2;
    
    [decisions,localIdx,localCnt] = cv('get',blockInfo.cvId,'.decisions', ...
                                        '.coverage.dc.localIdx','.coverage.dc.localCnt');
    if isempty(decisions)
        decData = [];
        return;
    end

    decIndex = [];
    totDecCovered = 0;
    for decId = decisions(:)'
        decEntry.cvId = decId; 
        decEntry.text = cv('TextOf',decId,-1,[],gFrmt.txtDetail); 
        [outcomes,startIdx]  = cv('get',decId,'.dc.numOutcomes','.dc.baseIdx');
        decEntry.numOutcomes = outcomes;
        decEntry.totals = sum(gdecision((startIdx+1):(startIdx+outcomes),:));
        decEntry.outCnts = sum(gdecision((startIdx+1):(startIdx+outcomes),:)>0);
        decEntry.covered = (decEntry.outCnts(end)==outcomes);
        totDecCovered = totDecCovered + decEntry.covered;
        if (outcomes>1)
            for i = 1:outcomes;
                decEntry.outcome(i).execCount = gdecision(startIdx+i,:);
                decEntry.outcome(i).text = cv('TextOf',decId,i-1,[],gFrmt.txtDetail);
            end
        end
        decEntry.blockIdx = blockInfo.index;
        decEntry.sysIdx = 0;
        if ~isfield(cvstruct,'decisions')
            decIndex = 1;
            cvstruct.decisions = decEntry;
        else
            decIndex = [decIndex length(cvstruct.decisions)+1];
            cvstruct.decisions(decIndex(end)) = decEntry;
        end
    end

    decData.decisionIdx = decIndex;
    decData.outHitCnts = gdecision(localIdx+1,:);
    decData.totalCnts = localCnt;
    decData.fullCoveredObjs = totDecCovered;




function [cvstruct,decData] = decision_system(cvstruct,sysEntry)

    global gdecision gFrmt;

    gFrmt.txtDetail = 2;
    
    [decisions,localIdx,localCnt,totalIdx,totalCnt] = cv('get',sysEntry.cvId,'.decisions', ...
                                        '.coverage.dc.localIdx','.coverage.dc.localCnt', ...
                                        '.coverage.dc.totalIdx','.coverage.dc.totalCnt');
    
    if totalCnt==0
        decData = [];
        return;
    end
    
    decIndex = [];
    totDecCovered = 0;
    for decId = decisions(:)'
        decEntry.cvId = decId; 
        decEntry.text = cv('TextOf',decId,-1,[],gFrmt.txtDetail); 
        [outcomes,startIdx]  = cv('get',decId,'.dc.numOutcomes','.dc.baseIdx');
        decEntry.numOutcomes = outcomes;
        decEntry.totals = sum(gdecision((startIdx+1):(startIdx+outcomes),:));
        decEntry.outCnts = sum(gdecision((startIdx+1):(startIdx+outcomes),:)>0);
        decEntry.covered = (decEntry.outCnts(end)==outcomes);
        totDecCovered = totDecCovered + decEntry.covered;
        if (outcomes>1)
            for i = 1:outcomes;
                decEntry.outcome(i).execCount = gdecision(startIdx+i,:);
                decEntry.outcome(i).text = cv('TextOf',decId,i-1,[],gFrmt.txtDetail);
            end
        else
            decEntry.outcome = [];
        end
        decEntry.blockIdx = 0;
        decEntry.sysIdx = sysEntry.sysNum;
        if ~isfield(cvstruct,'decisions')
            decIndex = 1;
            cvstruct.decisions = decEntry;
        else
            decIndex = [decIndex length(cvstruct.decisions)+1];
            cvstruct.decisions(decIndex(end)) = decEntry;
        end
    end

    decData.decisionIdx = decIndex;
    if localIdx==-1
        decData.outlocalCnts = [];
    else
        decData.outlocalCnts = gdecision(localIdx+1,:);
    end
    decData.totalLocalCnts = localCnt;
    decData.outTotalCnts = gdecision(totalIdx+1,:);
    decData.totalTotalCnts = totalCnt;
    decData.fullCoveredObjs = totDecCovered;


function [sysSummary, blkSummary] = decision_summary(testCnt)

    blkSummary = { ...
                    '$Decision (D1)', ...
                    {'[', ...
                        {'&in_covperratios',{'#decision.outHitCnts',testCnt+1},'#decision.totalCnts'}, ...
                        '$, ', ...
                        {'&in_covratios','#decision.fullCoveredObjs',{'&length','#decision.decisionIdx'}}, ...
                        '$ decisions' ...
                    }, '\n'  ...
                 };
                 
    sysSummary = { ...
                    '$Decision (D1)', ...
                    {'?',{'&isempty','#decision.outlocalCnts'},'$N/A', ...
                        {{'[', ...
                            {'&in_covperratios',{'#decision.outlocalCnts',testCnt+1},'#decision.totalLocalCnts'}, ...
                            '$, ', ...
                            {'&in_covratios','#decision.fullCoveredObjs',{'&length','#decision.decisionIdx'}}, ...
                            '$ decisions' ...
                        }} ...
                    } ...
                    {'&in_covperratios',{'#decision.outTotalCnts',testCnt+1},'#decision.totalTotalCnts'}, ...
                    '\n'  ...
                 };
                 
    

function  decision_details(outFile,blkEntry,cvstruct)

    persistent tableInfo dTableTemplate

    testCnt = length(cvstruct.tests)+1;
  
    if isempty(tableInfo) | isempty(dTableTemplate)   
        
        %
        % Formatting and layout for the table of decision details
        %

        tableInfo.formatStr.table = 'BORDER="1" CELLPADDING="5" CELLSPACING="1" ';
        tableInfo.formatStr.cols{1} = 'ALIGN="LEFT" WIDTH=380';
        tableInfo.formatStr.cols{2} = 'ALIGN="CENTER" WIDTH=60';

        outEntry = {'ForEach','#outcome', ...
                    {'?',{'=',{'#execCount',testCnt},'$!'} ,'&in_startred'}, ...
                    {'&in_tabstr','#text',1}, ...
                    {'&in_covratios','#execCount','#<totals'}, ...
                    {'?',{'=',{'#execCount',testCnt},'$!'}  ,'&in_endred'}, ...
                    '\n' ...
                   };
                   
        decEntry = { 'ForEach','#.', ...
                     {'[','$&nbsp; ','#text'}, {'&in_covpercent','#outCnts','#numOutcomes'},'\n' ...
                     outEntry ...
                   };
        
        dTableTemplate = {decEntry};
    end

    % Print the decision table
    if( ~isempty(blkEntry.decision) & isfield(blkEntry.decision,'decisionIdx') )
        decData = cvstruct.decisions(blkEntry.decision.decisionIdx);
    else
        decData = [];
    end
    
    
    if ~isempty(decData)
        fprintf(outFile,'\n<BR>Decision Coverage Details:<BR>\n');
        tableStr = sf('Private','html_table',decData,dTableTemplate,tableInfo);
        fprintf(outFile,'%s',tableStr);
    end
    


function condition_setup(varargin)

    global gcondition;
    
    gcondition = varargin{1}.metrics.condition;
    
    for i=2:length(varargin)
        gcondition = [gcondition varargin{i}.metrics.condition];
    end
    
    
function [cvstruct,condData] = condition_block(cvstruct,blockInfo)

    global gcondition gFrmt;

    gFrmt.txtDetail = 2;
    
    [conditions,localIdx,localCnt] = cv('get',blockInfo.cvId,'.conditions', ...
                                        '.coverage.cc.localIdx','.coverage.cc.localCnt');
    if localCnt==0
        condData = [];
        return;
    end

    condIndex = [];
    totcondCovered = 0;
    for condId = conditions(:)'
        condEntry.cvId = condId; 
        condEntry.text = cv('TextOf',condId,-1,[],gFrmt.txtDetail); 
        [trueCountIdx,falseCountIdx]  = cv('get',condId,'.coverage.trueCountIdx','.coverage.falseCountIdx');
        condEntry.trueCnts = gcondition(trueCountIdx+1,:);
        condEntry.falseCnts = gcondition(falseCountIdx+1,:);
        condEntry.covered = condEntry.trueCnts(end)>0 & condEntry.falseCnts(end)>0;
        condEntry.blockIdx = blockInfo.index;
        condEntry.sysIdx = 0;

        totcondCovered = totcondCovered + condEntry.covered;

        if ~isfield(cvstruct,'conditions')
            condIndex = 1;
            cvstruct.conditions = condEntry;
        else
            condIndex = [condIndex length(cvstruct.conditions)+1];
            cvstruct.conditions(condIndex(end)) = condEntry;
        end
    end

    % Sometimes a decision will also count as a condition, check for these
    decEqvCnt = 0;
    if (isfield(blockInfo,'decision') & ~isempty(blockInfo.decision) )
        for dIdx = blockInfo.decision.decisionIdx(:)'
            if cvstruct.decisions(dIdx).numOutcomes==2
                decEqvCnt = decEqvCnt + 1;
                if cvstruct.decisions(dIdx).covered
                    totcondCovered = totcondCovered + 1;
                end
            end
        end
    end
    
    condData.conditionIdx = condIndex;
    condData.localHits = gcondition(localIdx+1,:);
    condData.localCnt = localCnt;
    condData.fullCoveredObjs = totcondCovered;
    condData.condCount = length(condIndex) + decEqvCnt;




function [cvstruct,condData] = condition_system(cvstruct,sysEntry)

    global gcondition gFrmt;

    gFrmt.txtDetail = 2;
    
    [conditions,localIdx,localCnt,totalIdx,totalCnt] = cv('get',sysEntry.cvId,'.conditions', ...
                                        '.coverage.cc.localIdx','.coverage.cc.localCnt', ...
                                        '.coverage.cc.totalIdx','.coverage.cc.totalCnt');
    
    if totalCnt==0
        condData = [];
        return;
    end
    
    condIndex = [];
    totcondCovered = 0;
    for condId = conditions(:)'
        condEntry.cvId = condId; 
        condEntry.text = cv('TextOf',condId,-1,[],gFrmt.txtDetail); 
        [trueCountIdx,falseCountIdx]  = cv('get',condId,'.coverage.trueCountIdx','.coverage.falseCountIdx');
        condEntry.trueCnts = gcondition(trueCountIdx+1,:);
        condEntry.falseCnts = gcondition(falseCountIdx+1,:);
        condEntry.covered = ((condEntry.trueCnts(end)>0) & (condEntry.falseCnts(end)>0));
        condEntry.blockIdx = 0;
        condEntry.sysIdx = sysEntry.sysNum;

        totcondCovered = totcondCovered + condEntry.covered;

        if ~isfield(cvstruct,'conditions')
            condIndex = 1;
            cvstruct.conditions = condEntry;
        else
            condIndex = [condIndex length(cvstruct.conditions)+1];
            cvstruct.conditions(condIndex(end)) = condEntry;
        end
    end

    % Sometimes a decision will also count as a condition, check for these
    decEqvCnt = 0;
    if (isfield(sysEntry,'decision') & ~isempty(sysEntry.decision) )
        for dIdx = sysEntry.decision.decisionIdx(:)'
            if cvstruct.decisions(dIdx).numOutcomes==2
                decEqvCnt = decEqvCnt + 1;
                if cvstruct.decisions(dIdx).covered
                    totcondCovered = totcondCovered + 1;
                end
            end
        end
    end
    

    condData.conditionIdx = condIndex;
    if localIdx==-1
        condData.localHits = [];
    else
        condData.localHits = gcondition(localIdx+1,:);
    end
    condData.localCnt = localCnt;
    condData.totalHits = gcondition(totalIdx+1,:);
    condData.totalCnt = totalCnt;
    condData.fullCoveredObjs = totcondCovered;
    condData.condCount = length(condIndex) + decEqvCnt;


function [sysSummary, blkSummary] = condition_summary(testCnt)

    blkSummary = { ...
                    '$Condition (C1)', ...
                    {'[', ...
                        {'&in_covperratios',{'#condition.localHits',testCnt+1},'#condition.localCnt'}, ...
                        '$, ', ...
                        {'&in_covratios','#condition.fullCoveredObjs','#condition.condCount'}, ...
                        '$ conditions' ...
                    }, '\n'  ...
                 };
                 
    sysSummary = { ...
                    '$Condition (C1)', ...
                    {'?',{'&isempty','#condition.localHits'},'$N/A', ...
                        {{'[', ...
                            {'&in_covperratios',{'#condition.localHits',testCnt+1},'#condition.localCnt'}, ...
                            '$, ', ...
                            {'&in_covratios','#condition.fullCoveredObjs','#condition.condCount'}, ...
                            '$ conditions' ...
                        }} ...
                    }, ...
                    {'&in_covperratios',{'#condition.totalHits',testCnt+1},'#condition.totalCnt'}, ...
                    '\n'  ...
                 };
                 
    

function  condition_details(outFile,blkEntry,cvstruct)

    persistent tableInfo cTableTemplate

    testCnt = length(cvstruct.tests);
    if testCnt==1,
        coumnCnt = 1;
    else
        coumnCnt = testCnt+1;
    end
    
  
    if isempty(tableInfo) | isempty(cTableTemplate)   
        
        %
        % Formatting and layout for the table of decision details
        %

        tableInfo.formatStr.table = 'BORDER="1" CELLPADDING="5" CELLSPACING="1" ';
        tableInfo.formatStr.cols{1} = 'ALIGN="LEFT" WIDTH=300';
        tableInfo.formatStr.cols{2} = 'ALIGN="CENTER" WIDTH=35';

        execData = {'ForN',coumnCnt, ...
                    {'#trueCnts',{'=',1,'@1','$+'}}, ...
                    {'#falseCnts',{'=',1,'@1','$+'}}, ...
                   };
                   
        condEntry = { 'ForEach','#.', ...
                     {'?',{'=','#covered','$!'},'&in_startred'}, ...
                     {'[','$&nbsp; ','#text'},  ...
                     execData, ...
                     {'?',{'=','#covered','$!'},'&in_endred'}, ...
                      '\n' ...
                   };
        
        colHead = { '$<B>Description:</B>',{'ForN',testCnt,{'[','$<B>#',{'=',1,'@1','$+'},'$ T</B>'},{'[','$<B>#',{'=',1,'@1','$+'},'$ F</B>'}}};
        if testCnt>1
            colHead = [colHead {'$<B>Tot T</B>','$<B>Tot F</B>','\n'}];
        else
             colHead = [colHead {'\n'}];
           
        end
        
        cTableTemplate = [colHead {condEntry}]; 
    end

    % Print the decision table
    if( ~isempty(blkEntry.condition) & isfield(blkEntry.condition,'conditionIdx') )
        condData = cvstruct.conditions(blkEntry.condition.conditionIdx);
    else
        condData = [];
    end
    
    if ~isempty(condData)
        fprintf(outFile,'\n<BR>Condition Coverage Details:<BR>\n');
        tableStr = sf('Private','html_table',condData,cTableTemplate,tableInfo);
        fprintf(outFile,'%s',tableStr);
    end
    


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% OBJ_DIAG_LINK - Create an HTML link to an object
%

function out = obj_diag_link(id,str),
    out = sprintf('<A href="matlab: cvdisplay(%d);">%s</A>',id,str);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% OBJ_DIAG_NAMED_LINK - Create an HTML link to an object using
% the name as the label.
%

function out = obj_diag_named_link(id),
    if (id==0)
        out = 'N/A ';
    else
        out = obj_diag_link(id,cr_to_space(cv('get',id,'.name')));
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CR_TO_SPACE - Convert carraige returns to spaces
%

function out = cr_to_space(in),
	
    out = in;
    if ~isempty(in)
    	out(in==10) = char(32);
    end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% OBJ_ANCHOR - Create the HTML anchor for an object
%

function out = obj_anchor(id,str),
    out = sprintf('<A NAME=refobj%d>%s</A>',id,str);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% OBJ_LINK - Create an HTML link to an object
%

function out = obj_link(id,str),
    out = sprintf('<A HREF=#refobj%d>%s</A>',id,str);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% OBJ_NAMED_LINK - Create an HTML link to an object using
% the name as the label.
%

function out = obj_named_link(id),
    if (id==0)
        out = 'N/A ';
    else
        out = obj_link(id,cr_to_space(cv('get',id,'.name')));
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% OBJ_NAMED_TRUNC_LINK - Create an HTML link to an object using
% the name as the label, but truncate the label after n chars
%

function out = obj_named_trunc_link(id,n),
    str = cr_to_space(cv('get',id,'.name'));
    if length(str) > n
        str = [str(1:n) '...'];
    end
    if (id==0)
        out = 'N/A ';
    else
        out = obj_link(id,str);
    end



