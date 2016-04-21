function [mcdcData,flags,mcdcObjs] = report_mcdc_system(sysEntry,currMcdcCnt)
% MCDC_SYSTEM - Synthesize condition coverage data
% for a non-leaf model node.

% Copyright 2003 The MathWorks, Inc.

    global gmcdc gFrmt;
    persistent MetricVal;
    
    if isempty(MetricVal)
        MetricVal = cv_metric_names('all','struct');
    end
    
    flags = [];

    gFrmt.txtDetail = 2;
    
    [mcdcObjs,localIdx,localCnt,totalIdx,totalCnt] = cv('MetricGet',sysEntry.cvId, ...
                                        MetricVal.mcdc,'.baseObjs', ...
                                        '.dataIdx.shallow','.dataCnt.shallow', ...
                                        '.dataIdx.deep','.dataCnt.deep');

    if isempty(totalCnt)
        localIdx = -1;
        totalIdx = -1;
        totalCnt = 0;
        localCnt = 0;
    end
    
    if totalCnt==0
        mcdcData = [];
        return;
    end
    
    mcdcData.mcdcIndex = currMcdcCnt + (1:length(mcdcObjs));
    if localIdx==-1
        mcdcData.localHits = [];
    else
        mcdcData.localHits = gmcdc(localIdx+1,:);
    end
    mcdcData.localCnt = localCnt;
    mcdcData.totalHits = gmcdc(totalIdx+1,:);
    mcdcData.totalCnt = totalCnt;

    if (mcdcData.totalHits(end) == totalCnt)
        flags.fullCoverage = 1;     
        flags.noCoverage = 0;
        flags.leafUncov = 0;
    else
        flags.fullCoverage = 0;
        if (~isempty(mcdcData.localHits) & (mcdcData.localHits(end) ~= localCnt))     
        	flags.leafUncov = 1;
        else
        	flags.leafUncov = 0;
		end        	
        if mcdcData.totalHits(end)==0
            flags.noCoverage = 1;
        else
            flags.noCoverage = 0;
        end
    end



