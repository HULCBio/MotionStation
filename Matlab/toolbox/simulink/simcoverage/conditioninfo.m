function varargout = conditioninfo(data,block,ignoreDecendents)
%CONDITIONINFO - Condition coverage information for a model object
%
%   COVERAGE = CONDITIONINFO(DATA, BLOCK) Find the condition coverage
%   for BLOCK within the cvdata coverage object DATA. COVERAGE is returned 
%   as a 2 element vector: [covered_cases total_cases].  If information 
%   about BLOCK is not part of DATA then COVERAGE is empty.
%  
%   The BLOCK parameter that specifies the model object can take 
%   the following forms:
%   
%       BlockPath           - Full path to a Simulink block or model
%       BlockHandle         - Simulink block or model handle
%       SimulinkObj         - Simulink object API handle.
%       StateflowID         - Stateflow ID (Should be from a singly 
%                             instantiated chart.)
%       StateflowObj        - Stateflow object API handle. (Should be  
%                             from a singly instantiated chart.)
%      {BlockPath, sfID}    - Cell array with the path to a Stateflow block
%                             and the ID of an object contained in that 
%                             chart instance.
%      {BlockPath, sfObj}   - Path to a Stateflow block and a Stateflow 
%                             object API handle contained in that chart.
%      [BlockHandle sfID]   - Array with a Stateflow block handle and the 
%                             ID of an object contained in that chart 
%                             instance.
%                            
%   COVERAGE = CONDITIONINFO(DATA, BLOCK, IGNORE_DECENDENTS) 
%   Find the condition coverage for BLOCK and ignore the coverage 
%   in decendent objects if IGNORE_DECENDENTS is true.
%  
%   [COVERAGE,DESCRIPTION] = CONDITIONINFO(DATA, BLOCK) Find the 
%   coverage and produce a structure array DESCRIPTION containing a 
%   text descripion  of each condition and the number of true and 
%   false counts.

%   Bill Aldrich
%   Copyright 1990-2004 The MathWorks, Inc.
%   $Revision: 1.4.2.4 $  $Date: 2004/04/15 00:36:53 $

    if check_cv_license==0
    error(['Failed to check out Simulink Verification and Validation license,', ...
               ' required for model coverage']);
    end

    persistent ccEnum;
    
    if isempty(ccEnum)
        ccEnum =  cv('Private','cv_metric_names','condition');
    end
 
    if nargin<2,
        error('CONDITIONINFO requires two input arguments');
    end

    if nargin<3 | isempty(ignoreDecendents)
        ignoreDecendents = 0;
    end

    if ~isa(data,'cvdata')
        error('First argument must be a cvdata object');
    end

    rootId = data.rootID;
    dataMat = data.metrics.condition;
    blockCvId = find_block_cv_id(rootId,block);
    if ischar(blockCvId)
        error(blockCvId);
    end
    
    if blockCvId==0,
        varargout{1} = [];
        if nargout>1
            varargout{2} = [];
        end
        return
    end
    
    [totalCnt,totalIdx,localCnt,localIdx] = cv('MetricGet',blockCvId,ccEnum, ...
                                               '.dataCnt.deep','.dataIdx.deep','.dataCnt.shallow','.dataIdx.shallow');
    if isempty(totalCnt)
        totalIdx = -1;
        localIdx = -1;
        totalCnt = 0;
        localCnt = 0;
    end
    
    if ignoreDecendents
        if localIdx>=0
            hits = dataMat(localIdx+1);
        else
            hits = 0;
        end
        varargout{1} = [hits localCnt];
    else
        if totalIdx>=0
            hits = dataMat(totalIdx+1);
        else
            hits = 0;
        end
        varargout{1} = [hits totalCnt];
    end


    if nargout>1,
        txtDetail = 1;
        conditions = cv('MetricGet', blockCvId, ccEnum, '.baseObjs');
%        conditions = cv('get',blockCvId,'.conditions');

        descriptions = [];
        for condId =  conditions(:)'
            condEntry.text = cv('TextOf',condId,-1,[],txtDetail); 
            [trueCountIdx,falseCountIdx]  = cv('get',condId,'.coverage.trueCountIdx','.coverage.falseCountIdx');
            condEntry.trueCnts = dataMat(trueCountIdx+1,:);
            condEntry.falseCnts = dataMat(falseCountIdx+1,:);

            if isempty(descriptions)
                descriptions = condEntry;
            else
                descriptions(end+1) = condEntry;
            end
            
        end           
        
        varargout{2} = descriptions;
    end

    
         



