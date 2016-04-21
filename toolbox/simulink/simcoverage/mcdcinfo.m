function varargout = mcdcinfo(data,block,ignoreDecendents)
%TABLEINFO - Decision coverage information for a model object
%
%   COVERAGE = MCDCINFO(DATA, BLOCK) Find the condition coverage
%   for BLOCK within the cvdata coverage object DATA.  COVERAGE is returned 
%   as a 2 element vector: [covered_cases total_cases].  If information 
%   about BLOCK is not part of DATA then COVERAGE is empty.
%  
%   The BLOCK parameter that specifies the model object that is analyzed
%   can take the following forms:
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
%   COVERAGE = MCDCINFO(DATA, BLOCK, IGNORE_DECENDENTS) 
%   Find the condition coverage for BLOCK and ignore the coverage 
%   in decendent objects if IGNORE_DECENDENTS is true.
%  
%   [COVERAGE,DESCRIPTION] = MCDCINFO(DATA, BLOCK) Find the 
%   coverage and produce a structure array DESCRIPTION containing a 
%   text descripion of each boolean equation and the conditions
%   within that equation, a flag indicating if each condition was 
%   democstrated to independently change the equation outcome and a 
%   string representing the set of condition values that achieved the 
%   True result and another string for the false result.

%   Bill Aldrich
%   Copyright 1990-2004 The MathWorks, Inc.
%   $Revision: 1.3.2.5 $  $Date: 2004/04/15 00:37:04 $

    if check_cv_license==0
        error(['Failed to check out Simulink Verification and Validation license,', ...
               ' required for model coverage']);
    end

    persistent mcdcEnum;
    
    if isempty(mcdcEnum)
        mcdcEnum =  cv('Private','cv_metric_names','mcdc');
    end
 
    if nargin<2,
        error('MCDCINFO requires two input arguments');
    end

    if nargin<3 | isempty(ignoreDecendents)
        ignoreDecendents = 0;
    end

    if ~isa(data,'cvdata')
        error('First argument must be a cvdata object');
    end

    rootId = data.rootID;
    dataMat = data.metrics.mcdc;
    blockCvId = find_block_cv_id(rootId,block);
    if ischar(blockCvId)
        error(blockCvId);
    end
    
    if blockCvId==0 | isempty(dataMat),
        varargout{1} = [];
        if nargout>1
            varargout{2} = [];
        end
        return
    end
    
    [localIdx,localCnt,totalIdx,totalCnt] = cv('MetricGet',blockCvId, mcdcEnum, ...
                                        '.dataIdx.shallow','.dataCnt.shallow', ...
                                        '.dataIdx.deep','.dataCnt.deep');

    if isempty(totalCnt)
        localIdx = -1;
        totalIdx = -1;
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
        mcdcentries = cv('MetricGet', blockCvId, mcdcEnum, '.baseObjs');

        descriptions = [];
        for mcdcId =  mcdcentries(:)'
            mcdcEntry.text = cv('TextOf',mcdcId,-1,[],txtDetail); 
            [conditions,achevIdx,truePathIdx,falsePathIdx]  = cv('get',mcdcId ...
            			,'.conditions' ...
            			,'.dataBaseIdx.predSatisfied' ...
            			,'.dataBaseIdx.trueTableEntry' ...
            			,'.dataBaseIdx.falseTableEntry');
            for i=1:length(conditions)
            	condId = conditions(i);
            	condEntry.text = cv('TextOf',condId,-1,[],txtDetail); 
            	condValEnum = dataMat(achevIdx+i,:);
            	condEntry.acheived = condValEnum==4;
            	switch(condValEnum)
            	case 1,
	            	condEntry.trueRslt = ['(' cv('McdcPathText',mcdcId,dataMat(truePathIdx+i,end)) ')'];
	            	condEntry.falseRslt = ['(' cv('McdcPathText',mcdcId,dataMat(falsePathIdx+i,end)) ')'];
            	case 2,
	            	condEntry.trueRslt = cv('McdcPathText',mcdcId,dataMat(truePathIdx+i,end));
	            	condEntry.falseRslt = ['(' cv('McdcPathText',mcdcId,dataMat(falsePathIdx+i,end)) ')'];
            	case 3, 
	            	condEntry.trueRslt = ['(' cv('McdcPathText',mcdcId,dataMat(truePathIdx+i,end)) ')'];
	            	condEntry.falseRslt = cv('McdcPathText',mcdcId,dataMat(falsePathIdx+i,end));
            	case 4,
	            	condEntry.trueRslt = cv('McdcPathText',mcdcId,dataMat(truePathIdx+i,end));
	            	condEntry.falseRslt = cv('McdcPathText',mcdcId,dataMat(falsePathIdx+i,end));
            	otherwise,
	            	condEntry.trueRslt = 'N/A';
	            	condEntry.falseRslt = 'N/A';
            	end 
            	
		        mcdcEntry.condition(i) = condEntry;
	        end
	
            if isempty(descriptions)
                descriptions = mcdcEntry;
            else
                descriptions(end+1) = mcdcEntry;
            end
            
        end           
        
        varargout{2} = descriptions;
    end

    
         



