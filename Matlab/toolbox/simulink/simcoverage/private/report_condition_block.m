function [condData,flags,condObjs] = report_condition_block(blockInfo,currCondCnt)
% CONDITION_BLOCK - Synthesize decision coverage data
% for a leaf model object.

% Copyright 1990-2003 The MathWorks, Inc.
% $Revision: 1.1.6.1 $  $Date: 2003/09/18 18:06:39 $

    global gcondition gFrmt;
    persistent MetricVal;
    
    if isempty(MetricVal)
        MetricVal = cv_metric_names('all','struct');
    end
    
    flags = [];

    gFrmt.txtDetail = 2;
    
	
    [condObjs,localIdx,localCnt] = cv('MetricGet',blockInfo.cvId,MetricVal.condition,'.baseObjs', ...
                                        '.dataIdx.shallow','.dataCnt.shallow');
    if isempty(localCnt) | localCnt==0
        condData = [];
        return;
    end

    condData.conditionIdx = currCondCnt + (1:length(condObjs));
    condData.localHits = gcondition(localIdx+1,:);
    condData.localCnt = localCnt;
    condData.condCount = length(condObjs);

    if (condData.localHits(end) == localCnt)
        flags.fullCoverage = 1;     
        flags.noCoverage = 0;
        flags.leafUncov = 0;
    else
        flags.fullCoverage = 0;     
        flags.leafUncov = 1;
        if condData.localHits(end)==0
            flags.noCoverage = 1;
        else
            flags.noCoverage = 0;
        end
    end



