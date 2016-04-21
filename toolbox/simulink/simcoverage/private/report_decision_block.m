function [decData,flags,decObjs] = report_decision_block(blockInfo,currDecCount)
% DECISION_BLOCK - Synthesize decision coverage data
% for a leaf model object.

% Copyright 1990-2003 The MathWorks, Inc.
% $Revision: 1.1.6.1 $  $Date: 2003/09/18 18:06:44 $

    global gdecision gFrmt;
    persistent MetricVal;
    
    if isempty(MetricVal)
        MetricVal = cv_metric_names('all','struct');
    end
    
    flags = [];

    gFrmt.txtDetail = 2;
    
    [decObjs,localIdx,localCnt] = cv('MetricGet',blockInfo.cvId,MetricVal.decision,'.baseObjs', ...
                                        '.dataIdx.shallow','.dataCnt.shallow');
    if isempty(decObjs)
        decData = [];
        return;
    end

    decData.decisionIdx = currDecCount + (1:length(decObjs));
    decData.outHitCnts = gdecision(localIdx+1,:);
    decData.totalCnts = localCnt;

    if (decData.outHitCnts(end) == localCnt)
        flags.fullCoverage = 1;     
        flags.noCoverage = 0;
        flags.leafUncov = 0;
    else
        flags.fullCoverage = 0;     
        flags.leafUncov = 1;
        if decData.outHitCnts(end) == 0
            flags.noCoverage = 1;
        end
    end




