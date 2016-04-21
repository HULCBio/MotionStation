function [condData,flags,condObjs] = report_condition_system(sysEntry,currCondCnt)
% CONDITION_SYSTEM - Synthesize condition coverage data
% for a non-leaf model node.

% Copyright 1990-2003 The MathWorks, Inc.
% $Revision: 1.1.6.1 $  $Date: 2003/09/18 18:06:42 $

    global gcondition gFrmt;
    persistent MetricVal;
    
    if isempty(MetricVal)
        MetricVal = cv_metric_names('all','struct');
    end
    
    flags = [];

    gFrmt.txtDetail = 2;
    
    [condObjs,localIdx,localCnt,totalIdx,totalCnt] = cv('MetricGet',sysEntry.cvId, ...
                                        MetricVal.condition, '.baseObjs', ...
                                        '.dataIdx.shallow','.dataCnt.shallow', ...
                                        '.dataIdx.deep','.dataCnt.deep');

    if isempty(totalCnt) | totalCnt==0
        condData = [];
        return;
    end
    
    condData.conditionIdx = currCondCnt + (1:length(condObjs));;
    if localIdx==-1
        condData.localHits = [];
    else
        condData.localHits = gcondition(localIdx+1,:);
    end
    condData.localCnt = localCnt;
    condData.totalHits = gcondition(totalIdx+1,:);
    condData.totalCnt = totalCnt;
    condData.condCount = length(condObjs);

    if (condData.totalHits(end) == totalCnt)
        flags.fullCoverage = 1;     
        flags.noCoverage = 0;
        flags.leafUncov = 0;
    else
        flags.fullCoverage = 0;
        if (~isempty(condData.localHits) & (condData.localHits(end) ~= localCnt))     
            flags.leafUncov = 1;
        else
            flags.leafUncov = 0;
        end
        if condData.totalHits(end) == 0
            flags.noCoverage = 1;
        else
            flags.noCoverage = 0;
        end
    end


