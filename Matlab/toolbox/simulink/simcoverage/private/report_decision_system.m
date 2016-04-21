function [decData,flags,decObjs] = report_decision_system(sysEntry,currDecCount)
% DECISION_SYSTEM - Synthesize decision coverage data
% for a non-leaf model node.

% Copyright 1990-2003 The MathWorks, Inc.
% $Revision: 1.1.6.1 $  $Date: 2003/09/18 18:06:47 $

    global gdecision gFrmt;
    persistent MetricVal;
    
    if isempty(MetricVal)
        MetricVal = cv_metric_names('all','struct');
    end
    
    gFrmt.txtDetail = 2;
    
    [decObjs,localIdx,localCnt,totalIdx,totalCnt] = cv('MetricGet',sysEntry.cvId, MetricVal.decision,  ...
                                        '.baseObjs', ...
                                        '.dataIdx.shallow','.dataCnt.shallow', ...
                                        '.dataIdx.deep','.dataCnt.deep');
    
    if isempty(totalCnt) | totalCnt==0
		flags = [];
        decData = [];
        return;
    end
    
    decData.decisionIdx = currDecCount+(1:length(decObjs));
    if localIdx==-1
        decData.outlocalCnts = [];
    else
        decData.outlocalCnts = gdecision(localIdx+1,:);
    end
    decData.totalLocalCnts = localCnt;
    decData.outTotalCnts = gdecision(totalIdx+1,:);
    decData.totalTotalCnts = totalCnt;

    if (decData.outTotalCnts(end) == totalCnt)
        flags.fullCoverage = 1;     
        flags.noCoverage = 0;
        flags.leafUncov = 0;
    else
        flags.fullCoverage = 0;
        if (~isempty(decData.outlocalCnts) & (decData.outlocalCnts(end) ~= localCnt))     
            flags.leafUncov = 1;
        else
            flags.leafUncov = 0;
        end
        if decData.outTotalCnts==0
            flags.noCoverage = 1;
        end
    end



