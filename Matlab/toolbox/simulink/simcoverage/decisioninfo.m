function varargout = decisioninfo(data,block,ignoreDecendents)
%DECISIONINFO - Decision coverage information for a model object
%
%   COVERAGE = DECISIONINFO(DATA, BLOCK) Find the decision coverage
%   for BLOCK within the cvdata coverage object DATA.  COVERAGE is returned
%   as a 2 element vector: [covered_outcomes total_outcomes].  If 
%   information about BLOCK is not part of DATA then COVERAGE is empty.
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
%   COVERAGE = DECISIONINFO(DATA, BLOCK, IGNORE_DESCENDENTS) 
%   Find the decision coverage for BLOCK and ignore the coverage 
%   in descendent objects if IGNORE_DESCENDENTS is true.
%  
%   [COVERAGE,DESCRIPTION] = DECISIONINFO(DATA, BLOCK) Find the 
%   coverage and produce a structured description of the decisions
%   and conditions within BLOCK.  DESCRIPTION is a structure 
%   containing textual descriptions of each decision and descriptions
%   and execution counts for each outcome within BLOCK.

%   Bill Aldrich
%   Copyright 1990-2004 The MathWorks, Inc.
%   $Revision: 1.6.2.5 $  $Date: 2004/04/15 00:37:03 $

    persistent dcEnum;
    
    if isempty(dcEnum)
        dcEnum =  cv('Private','cv_metric_names','decision');
    end
 
    if check_cv_license==0
        error(['Failed to check out Simulink Verification and Validation license,', ...
               ' required for model coverage']);
    end

    if nargin<2,
        error('DECISIONINFO requires two input arguments');
    end

    if nargin<3 | isempty(ignoreDecendents)
        ignoreDecendents = 0;
    end

    if ~isa(data,'cvdata')
        error('First argument must be a cvdata object');
    end

    rootId = data.rootID;
    dataMat = data.metrics.decision;
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
    
%    [totalCnt,totalIdx,localCnt,localIdx] = cv('get',blockCvId,'.coverage.dc.totalCnt', ...
%                                                        '.coverage.dc.totalIdx', ...
%                                                        '.coverage.dc.localCnt', ...
%                                                        '.coverage.dc.localIdx');

    [totalCnt,totalIdx,localCnt,localIdx] = cv('MetricGet',blockCvId,dcEnum, ...
                                               '.dataCnt.deep','.dataIdx.deep','.dataCnt.shallow','.dataIdx.shallow');
    if isempty(totalCnt)
        varargout{1} = [];
        if nargout>1
            varargout{2} = [];
        end
        return
    end
    
    if ignoreDecendents
        if ~isempty(localIdx) & localIdx>=0
            hits = dataMat(localIdx+1);
        else
            hits = 0;
        end
        varargout{1} = [hits localCnt];
    else
        if ~isempty(totalIdx) & totalIdx>=0
            hits = dataMat(totalIdx+1);
        else
            hits = 0;
        end
        varargout{1} = [hits totalCnt];
    end

    if nargout>1,
        txtDetail = 1;
        description = [];
        decisions = cv('MetricGet', blockCvId, dcEnum, '.baseObjs');
%        decisions = cv('get',blockCvId,'.decisions');
        for decId = decisions(:)'
            d.text = cv('TextOf',decId,-1,[],txtDetail); 
            [outcomes,startIdx]  = cv('get',decId,'.dc.numOutcomes','.dc.baseIdx');
            for i = 0:(outcomes-1);
                out.text = cv('TextOf',decId,i,[],txtDetail);
                out.executionCount = dataMat(startIdx+i+1);
                if ~isfield(d,'outcome')
                    d.outcome = out;
                else
                    d.outcome(end+1) = out;
                end
            end

            if isempty(description)
                description.decision = d;
            else
                description.decision(end+1) = d;
            end
            clear('d');
        end
        varargout{2} = description;
    end

